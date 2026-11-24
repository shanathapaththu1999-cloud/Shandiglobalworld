-- SHANDI DIGITAL NETWORK: complete Supabase schema and Row Level Security
-- Apply once in Supabase SQL Editor or by migration tooling.

create extension if not exists pgcrypto;
create type public.app_role as enum ('customer', 'business', 'administrator');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  phone text,
  bio text,
  language text not null default 'en' check (language in ('en','si')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  approved boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path=public
as $$ select exists (select 1 from public.user_roles where user_id=auth.uid() and role='administrator' and approved) $$;

create or replace function public.has_role(required_role public.app_role)
returns boolean language sql stable security definer set search_path=public
as $$ select exists (select 1 from public.user_roles where user_id=auth.uid() and role=required_role and approved) $$;

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null, description text, category text, phone text, whatsapp text, email text, logo_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','suspended')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.service_categories (
  id uuid primary key default gen_random_uuid(), name text not null unique, name_si text, description text,
  sort_order integer not null default 0, created_at timestamptz not null default now()
);
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(), provider_id uuid not null references auth.users(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete set null,
  category_id uuid references public.service_categories(id) on delete set null,
  title text not null, title_si text, description text, description_si text, image_url text, phone text, whatsapp text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','suspended')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.marketplace_listings (
  id uuid primary key default gen_random_uuid(), seller_id uuid not null references auth.users(id) on delete cascade,
  title text not null, description text, category text, price text, image_urls text[] not null default '{}', whatsapp text,
  status text not null default 'pending' check (status in ('draft','pending','approved','rejected','suspended')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(), author_id uuid not null references auth.users(id) on delete cascade,
  content text not null, image_url text, video_url text,
  status text not null default 'approved' check (status in ('draft','pending','approved','rejected')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(), post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete cascade, content text not null,
  status text not null default 'approved' check (status in ('pending','approved','rejected')), created_at timestamptz not null default now()
);
create table if not exists public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(post_id,user_id)
);
create table if not exists public.videos (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null, description text, category text, external_url text, youtube_url text, storage_path text, thumbnail_url text,
  status text not null default 'pending' check (status in ('draft','pending','approved','rejected','suspended')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint video_source check (external_url is not null or youtube_url is not null or storage_path is not null)
);
create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(), sender_id uuid references auth.users(id) on delete set null,
  provider_id uuid references auth.users(id) on delete set null, service_id uuid references public.services(id) on delete set null,
  name text not null, email text not null, phone text, message text not null,
  status text not null default 'new' check (status in ('new','read','responded','closed','spam')), created_at timestamptz not null default now()
);
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(), reporter_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null, target_id uuid not null, reason text not null, details text,
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')), created_at timestamptz not null default now()
);
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  title text not null, body text, link text, read boolean not null default false, created_at timestamptz not null default now()
);

create index if not exists businesses_owner_idx on public.businesses(owner_id);
create index if not exists services_provider_idx on public.services(provider_id);
create index if not exists marketplace_seller_idx on public.marketplace_listings(seller_id);
create index if not exists posts_author_idx on public.posts(author_id);
create index if not exists comments_post_idx on public.comments(post_id);
create index if not exists videos_owner_idx on public.videos(owner_id);
create index if not exists enquiries_provider_idx on public.enquiries(provider_id);
create index if not exists notifications_user_idx on public.notifications(user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.businesses enable row level security;
alter table public.service_categories enable row level security;
alter table public.services enable row level security;
alter table public.marketplace_listings enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.likes enable row level security;
alter table public.videos enable row level security;
alter table public.enquiries enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;

create policy if not exists profiles_read on public.profiles for select using(true);
create policy if not exists profiles_insert on public.profiles for insert with check(auth.uid()=id);
create policy if not exists profiles_update on public.profiles for update using(auth.uid()=id or public.is_admin()) with check(auth.uid()=id or public.is_admin());
create policy if not exists roles_read_own on public.user_roles for select using(auth.uid()=user_id or public.is_admin());
create policy if not exists roles_admin_insert on public.user_roles for insert with check(public.is_admin());
create policy if not exists roles_admin_update on public.user_roles for update using(public.is_admin()) with check(public.is_admin());
create policy if not exists roles_admin_delete on public.user_roles for delete using(public.is_admin());
create policy if not exists categories_public_read on public.service_categories for select using(true);
create policy if not exists categories_admin_insert on public.service_categories for insert with check(public.is_admin());
create policy if not exists categories_admin_update on public.service_categories for update using(public.is_admin()) with check(public.is_admin());
create policy if not exists categories_admin_delete on public.service_categories for delete using(public.is_admin());
create policy if not exists businesses_public_read on public.businesses for select using(status='approved' or owner_id=auth.uid() or public.is_admin());
create policy if not exists businesses_owner_insert on public.businesses for insert with check(auth.uid()=owner_id);
create policy if not exists businesses_owner_update on public.businesses for update using(auth.uid()=owner_id or public.is_admin()) with check(auth.uid()=owner_id or public.is_admin());
create policy if not exists businesses_admin_delete on public.businesses for delete using(public.is_admin());
create policy if not exists services_public_read on public.services for select using(status='approved' or provider_id=auth.uid() or public.is_admin());
create policy if not exists services_owner_insert on public.services for insert with check(auth.uid()=provider_id);
create policy if not exists services_owner_update on public.services for update using(auth.uid()=provider_id or public.is_admin()) with check(auth.uid()=provider_id or public.is_admin());
create policy if not exists services_owner_delete on public.services for delete using(auth.uid()=provider_id or public.is_admin());
create policy if not exists marketplace_public_read on public.marketplace_listings for select using(status='approved' or seller_id=auth.uid() or public.is_admin());
create policy if not exists marketplace_owner_insert on public.marketplace_listings for insert with check(auth.uid()=seller_id);
create policy if not exists marketplace_owner_update on public.marketplace_listings for update using(auth.uid()=seller_id or public.is_admin()) with check(auth.uid()=seller_id or public.is_admin());
create policy if not exists marketplace_owner_delete on public.marketplace_listings for delete using(auth.uid()=seller_id or public.is_admin());
create policy if not exists posts_public_read on public.posts for select using(status='approved' or author_id=auth.uid() or public.is_admin());
create policy if not exists posts_owner_insert on public.posts for insert with check(auth.uid()=author_id);
create policy if not exists posts_owner_update on public.posts for update using(auth.uid()=author_id or public.is_admin()) with check(auth.uid()=author_id or public.is_admin());
create policy if not exists posts_owner_delete on public.posts for delete using(auth.uid()=author_id or public.is_admin());
create policy if not exists comments_public_read on public.comments for select using(status='approved' or author_id=auth.uid() or public.is_admin());
create policy if not exists comments_owner_insert on public.comments for insert with check(auth.uid()=author_id);
create policy if not exists comments_owner_update on public.comments for update using(auth.uid()=author_id or public.is_admin()) with check(auth.uid()=author_id or public.is_admin());
create policy if not exists comments_owner_delete on public.comments for delete using(auth.uid()=author_id or public.is_admin());
create policy if not exists likes_read on public.likes for select using(true);
create policy if not exists likes_owner_insert on public.likes for insert with check(auth.uid()=user_id);
create policy if not exists likes_owner_delete on public.likes for delete using(auth.uid()=user_id);
create policy if not exists videos_public_read on public.videos for select using(status='approved' or owner_id=auth.uid() or public.is_admin());
create policy if not exists videos_owner_insert on public.videos for insert with check(auth.uid()=owner_id);
create policy if not exists videos_owner_update on public.videos for update using(auth.uid()=owner_id or public.is_admin()) with check(auth.uid()=owner_id or public.is_admin());
create policy if not exists videos_owner_delete on public.videos for delete using(auth.uid()=owner_id or public.is_admin());
create policy if not exists enquiries_insert on public.enquiries for insert with check(sender_id is null or auth.uid()=sender_id);
create policy if not exists enquiries_read on public.enquiries for select using(sender_id=auth.uid() or provider_id=auth.uid() or public.is_admin());
create policy if not exists enquiries_update on public.enquiries for update using(provider_id=auth.uid() or public.is_admin()) with check(provider_id=auth.uid() or public.is_admin());
create policy if not exists reports_insert on public.reports for insert with check(auth.uid()=reporter_id);
create policy if not exists reports_read on public.reports for select using(reporter_id=auth.uid() or public.is_admin());
create policy if not exists reports_admin_update on public.reports for update using(public.is_admin()) with check(public.is_admin());
create policy if not exists notifications_owner on public.notifications for select using(auth.uid()=user_id);
create policy if not exists notifications_owner_update on public.notifications for update using(auth.uid()=user_id) with check(auth.uid()=user_id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
declare requested_role public.app_role;
begin
  requested_role := case when new.raw_user_meta_data->>'role'='business' then 'business'::public.app_role else 'customer'::public.app_role end;
  insert into public.profiles(id,display_name,avatar_url)
  values(new.id,coalesce(new.raw_user_meta_data->>'full_name',new.email),new.raw_user_meta_data->>'avatar_url') on conflict(id) do nothing;
  insert into public.user_roles(user_id,role,approved) values(new.id,requested_role,true) on conflict(user_id,role) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

insert into public.service_categories(name,name_si,sort_order) values
('Photography','ඡායාරූපකරණය',1),('Tattoo','පච්ච ගැසුම්',2),('Salon','සැලන්',3),
('Photo Editing','ඡායාරූප සංස්කරණ',4),('Creative Arts','නිර්මාණ කලා',5),
('Digital Design','ඩිජිටල් සැලසුම්',6),('Graphic Design','චිත්‍රක සැලසුම්',7),
('Video Editing','වීඩියෝ සංස්කරණ',8),('Web Development','වෙබ් සංවර්ධනය',9),
('Digital Marketing','ඩිජිටල් අලෙවිකරණය',10)
on conflict(name) do update set name_si=excluded.name_si,sort_order=excluded.sort_order;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('shandi-media','shandi-media',true,10485760,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm'])
on conflict(id) do update set public=excluded.public,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
