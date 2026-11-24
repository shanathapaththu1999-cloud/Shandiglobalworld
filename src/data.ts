export type Role = 'customer' | 'business' | 'administrator';

export const serviceSeed = [
  ['ShanDi Photography', 'Photography and visual storytelling.', 'Photography'],
  ['ShanDi Tattoo Studio', 'Custom body art and tattoo consultations.', 'Tattoo'],
  ['ShanDi Salon', 'Beauty, grooming and salon services.', 'Beauty'],
  ['ShanDi Photo Editing', 'Professional image retouching and restoration.', 'Editing'],
  ['ShanDi Creative Arts', 'Original creative and artistic work.', 'Creative Arts'],
  ['ShanDi Digital Design', 'Digital graphics and brand-ready assets.', 'Digital Design'],
  ['Graphic Design', 'Logos, posters and visual identity.', 'Graphic Design'],
  ['Video Editing', 'Social, event and commercial video editing.', 'Video'],
  ['Web Development', 'Modern responsive website development.', 'Technology'],
  ['Digital Marketing', 'Strategy, social growth and campaign support.', 'Marketing']
] as const;

export const marketplaceSeed = [
  { id: 'market-1', title: 'Professional Camera Kit', category: 'Photography', price: 'Contact for price', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=900&auto=format&fit=crop', seller: 'ShanDi Store', description: 'Camera equipment and accessories available for enquiry.' },
  { id: 'market-2', title: 'Custom Creative Package', category: 'Creative Services', price: 'Custom quote', image: 'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=900&auto=format&fit=crop', seller: 'ShanDi Creative', description: 'A tailored design package for your brand.' },
  { id: 'market-3', title: 'Digital Artwork', category: 'Digital Products', price: 'LKR 4,500+', image: 'https://images.unsplash.com/photo-1618005198919-d3d4b5a92ead?w=900&auto=format&fit=crop', seller: 'ShanDi Arts', description: 'Original digital artwork and commercial-ready exports.' }
];

export const videoSeed = [
  { id: 'video-1', title: 'SHANDI Creative Network', description: 'A first look at the growing ShanDi creative community.', category: 'Network', youtube: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' },
  { id: 'video-2', title: 'Photography Showcase', description: 'Visual storytelling and photography concepts.', category: 'Photography', youtube: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
];
