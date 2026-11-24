# SHANDI DIGITAL NETWORK

## Android setup
1. Create a free Supabase project.
2. Open Supabase SQL Editor and run `supabase/migrations/202611240001_initial_shandi.sql`.
3. Create a Cloudflare Pages project from this GitHub repository.
4. Set build command `npm run build`, output directory `dist`, branch `main`.
5. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` only in Cloudflare environment variables.
6. Redeploy. The public URL may be `https://shandidigitalnetwork.pages.dev` only if Cloudflare confirms availability.

Never put a Supabase service-role key in this repository or Cloudflare frontend variables.

## Local development
```sh
npm install
npm run dev
```

## Build
```sh
npm run build
npm run preview
```

## Supabase authentication
- Copy the project URL and publishable/anon key.
- Add the deployed URL and `http://localhost:5173/**` to Authentication URL Configuration.
- Public registration only permits customer/business roles.
- Promote the first administrator in SQL only:

```sql
insert into public.user_roles(user_id,role,approved)
select id,'administrator',true from auth.users
where email='OWNER_EMAIL@example.com'
on conflict(user_id,role) do update set approved=true;
```

The migration enables RLS, secure role helpers, owner policies and public approved-content policies. Supabase Storage bucket `shandi-media` is restricted to a 10 MB size limit and supported image/video MIME types.
