-- Inzozi Academy content platform. Authentication is provided by Supabase Auth.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null default '',
  full_name text not null default '',
  role text not null default 'contributor' check (role in ('super_admin','administrator','editor','contributor')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id), action text not null,
  entity_type text not null, entity_id text, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(), title text not null, slug text not null unique, summary text not null default '', content text not null default '',
  cover_image_id uuid, cover_image_url text, additional_photos text[] not null default '{}', published_at timestamptz, activity_date date,
  author_id uuid references public.profiles(id), category text not null default 'School story', tags text[] not null default '{}',
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')),
  featured boolean not null default false, guardian_consent_verified boolean not null default false,
  seo_title text, seo_description text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint article_public_photo_consent check(status<>'published' or not (cover_image_url is not null or cardinality(additional_photos)>0) or guardian_consent_verified)
);
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(), title text not null, slug text unique, description text not null default '', event_date date,
  start_time time, end_time time, location text not null default 'Inzozi Academy', cover_image_id uuid, cover_image_url text,
  additional_photos text[] not null default '{}', category text not null default 'School event', event_status text not null default 'upcoming' check(event_status in ('upcoming','ongoing','completed','cancelled')),
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')), featured boolean not null default false, registration_url text,
  author_id uuid references public.profiles(id), guardian_consent_verified boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint event_public_photo_consent check(status<>'published' or not (cover_image_url is not null or cardinality(additional_photos)>0) or guardian_consent_verified)
);
create table if not exists public.gallery_albums (
  id uuid primary key default gen_random_uuid(), title text not null, description text not null default '', category text not null default 'School life',
  cover_image_id uuid, cover_image_url text, video_url text, status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')),
  guardian_consent_verified boolean not null default false, published_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  constraint album_public_photo_consent check(status<>'published' or cover_image_url is null or guardian_consent_verified)
);
create table if not exists public.media_assets (
  id uuid primary key default gen_random_uuid(), storage_path text not null unique, file_name text not null, mime_type text not null, file_size bigint not null,
  caption text not null default '', alt_text text not null default '', category text not null default 'School life', album_id uuid references public.gallery_albums(id) on delete set null,
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')),
  guardian_consent_verified boolean not null default false, uploaded_by uuid references public.profiles(id), created_at timestamptz not null default now(),
  constraint media_public_photo_consent check(status<>'published' or guardian_consent_verified)
);
create table if not exists public.staff_members (
  id uuid primary key default gen_random_uuid(), full_name text not null unique, photo_url text, job_title text not null, department text not null default 'Teaching staff' check(department in ('Leadership','Teaching staff','Support staff')),
  biography text not null default '', display_order integer not null default 0, status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
-- Existing public staff directory and portraits from the school website assets.
insert into public.staff_members(full_name,photo_url,job_title,department,biography,display_order,status) values
('Hope Rutagengwa','/images/staff/hope-rutagengwa.jpg','Principal','Leadership','Leading Inzozi’s vision, ensuring that every child is known, nurtured and equipped to reach their dreams.',1,'published'),
('Winfred Nyamwiza','/images/staff/winfred-nyamwiza.jpg','Head of School','Leadership','',2,'published'),
('Kathy Munkittrick','/images/staff/kathy-munkittrick.jpg','Curriculum Development & Capacity Building','Leadership','',3,'published'),
('Seraphine Asiimwe','/images/staff/seraphine-asiimwe.jpg','Accounting & Operations','Leadership','',4,'published'),
('Simon Waiswa','/images/staff/simon-waiswa.jpg','Head of Academics','Leadership','',5,'published'),
('Doreen Mutamba','/images/staff/doreen-mutamba.jpg','School Manager','Leadership','',6,'published'),
('Fabiola La Douce','/images/staff/fabiola-la-douce.jpg','Primary 4 Teacher','Teaching staff','',1,'published'),
('Olivier Niyigena','/images/staff/olivier-niyigena.jpg','Primary 4 Assistant Teacher','Teaching staff','',2,'published'),
('Angelique Irankunda','/images/staff/angelique-irankunda.jpg','Primary 2 Teacher','Teaching staff','',3,'published'),
('Aimable Harerimana','/images/staff/aimable-harerimana.jpg','Primary Kinyarwanda Teacher & Nursery 2 Assistant','Teaching staff','',4,'published'),
('Esther Uwayo','/images/staff/esther-uwayo.jpg','Primary 1 Teacher','Teaching staff','',5,'published'),
('Kamaliza Merissa','/images/staff/kamaliza-merissa.jpg','Primary 1 Assistant Teacher','Teaching staff','',6,'published'),
('Mutesi Grace','/images/staff/mutesi-grace.jpg','Nursery 3 Assistant Teacher','Teaching staff','',7,'published'),
('Gemima Uwayo','/images/staff/gemima-uwayo.jpg','Nursery 2 Teacher','Teaching staff','',8,'published'),
('Frank Irakoze',null,'Nursery 2 Assistant Teacher','Teaching staff','',9,'published'),
('Mwamini Mary',null,'Nursery 1 Teacher','Teaching staff','',10,'published'),
('Dusenge Sifa','/images/staff/dusenge-sifa.jpg','Nursery 1 Assistant Teacher','Teaching staff','',11,'published'),
('Beatha Murekatete','/images/staff/beatha-murekatete.jpg','Kitchen Manager','Support staff','',1,'published'),
('Diane Tuyishime','/images/staff/diane-tuyishime.jpg','Support Staff','Support staff','',2,'published'),
('Eric Byamungu','/images/staff/eric-byamungu.jpg','Support Staff','Support staff','',3,'published'),
('Fridah Kakwezi','/images/staff/fridah-kakwezi.jpg','Support Staff','Support staff','',4,'published'),
('Rachel Uwishoreye','/images/staff/rachel-uwishoreye.jpg','Support Staff','Support staff','',5,'published'),
('Uwase Benitha','/images/staff/uwase-benitha.jpg','Support Staff','Support staff','',6,'published'),
('Uwera Vestine','/images/staff/uwera-vestine.jpg','Support Staff','Support staff','',7,'published')
on conflict(full_name) do nothing;
create table if not exists public.academic_programmes (
  id uuid primary key default gen_random_uuid(), name text not null, level text not null default '', description text not null default '', display_order integer not null default 0,
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.faqs (
  id uuid primary key default gen_random_uuid(), question text not null, answer text not null, category text not null default 'General', display_order integer not null default 0,
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.admission_enquiries (
  id uuid primary key default gen_random_uuid(), parent_name text not null, phone text not null, email text, intended_class text not null,
  contact_method text not null default 'Phone call', message text not null default '', status text not null default 'new' check(status in ('new','contacted','visit_scheduled','in_progress','closed')),
  internal_notes text not null default '', follow_up_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(), name text not null, relationship text not null default 'Parent', quote text not null,
  status text not null default 'draft' check(status in ('draft','pending_approval','published','archived')), created_at timestamptz not null default now()
);
create table if not exists public.website_settings (
  key text primary key, value text not null default '', label text not null default '', is_public boolean not null default true,
  updated_by uuid references public.profiles(id), updated_at timestamptz not null default now()
);
create table if not exists public.navigation_items (
  id uuid primary key default gen_random_uuid(), label text not null, href text not null, display_order integer not null default 0,
  status text not null default 'published' check(status in ('draft','pending_approval','published','archived'))
);

create index if not exists articles_status_published_idx on public.articles(status,published_at desc);
create index if not exists articles_category_idx on public.articles(category);
create index if not exists events_date_idx on public.events(event_date);
create index if not exists events_status_idx on public.events(status,event_status,event_date);
create index if not exists media_album_idx on public.media_assets(album_id);
create index if not exists staff_order_idx on public.staff_members(display_order);
create index if not exists enquiries_created_idx on public.admission_enquiries(created_at desc);
create index if not exists audit_created_idx on public.audit_logs(created_at desc);

insert into public.website_settings(key,value,label,is_public) values
('tagline','Nurturing big dreams, shaping bright futures.','Homepage headline',true),
('introduction','Inzozi means dreams, and we exist to help every child reach theirs. We are a Christ-centered preschool and primary school committed to nurturing each child’s academic, spiritual, physical, social and emotional growth.','School introduction',true),
('philosophy','Children learn best when they feel known, safe and curious. We combine Rwanda’s national curriculum with hands-on, student-centered learning inspired by Montessori principles.','Educational philosophy',true),
('mission','To nurture the whole child through high-quality learning, faith, care and character.','Mission',true),
('vision','A future where every child is equipped and inspired to reach their dreams.','Vision',true),
('address','Karama (Kanombe), Kicukiro, Kigali, Rwanda','School address',true),
('phone','+250 793 766 053','Admissions phone',true),
('email','info@inzoziacademy.rw','Official email',true),
('years_serving','4 years','Years serving Kigali',true),
('preschool_ratio','10 : 1','Preschool class ratio',true),
('primary_ratio','15 : 1','Primary class ratio',true),
('enrollment_levels','N1 – P6','Enrolment levels',true),
('faith_identity','We are a Christ-centered community that nurtures faith and character while warmly welcoming families of all backgrounds.','Faith identity',true),
('promise_1_title','Small classes','Homepage promise one title',true),
('promise_1_copy','A 10:1 preschool and 15:1 primary student–teacher ratio helps every child get the attention they need.','Homepage promise one',true),
('promise_2_title','Whole-child care','Homepage promise two title',true),
('promise_2_copy','Academic, spiritual, physical, social and emotional growth, grounded in faith and character.','Homepage promise two',true),
('promise_3_title','Literacy first','Homepage promise three title',true),
('promise_3_copy','Strong reading and language skills lay the foundation for a lifetime of learning.','Homepage promise three',true),
('promise_4_title','Always growing','Homepage promise four title',true),
('promise_4_copy','We keep building our facilities and investing in the people who make school special.','Homepage promise four',true),
('promise_1_image','/images/small-classes.jpg','Homepage promise one image',true),
('promise_2_image','/images/christ-centered.jpg','Homepage promise two image',true),
('promise_3_image','/images/literacy-first.jpg','Homepage promise three image',true),
('promise_4_image','/images/building-the-future.jpg','Homepage promise four image',true),
('intro_image','/images/classroom-learning.webp','Homepage introduction image',true),
('hero_image_url','/images/school-classroom-hero.jpg','Homepage hero image',true)
on conflict (key) do nothing;
insert into public.navigation_items(label,href,display_order,status) values
('Our story','/about',1,'published'),('Academics','/academics',2,'published'),('News & stories','/news',3,'published'),('School life','/gallery',4,'published'),('Our team','/team',5,'published'),('FAQs','/faq',6,'published'),('Admissions','/admissions',7,'published') on conflict do nothing;

-- Profiles default to contributor; an existing super administrator can promote accounts.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,email,full_name,role) values(new.id,coalesce(new.email,''),coalesce(new.raw_user_meta_data->>'full_name',''),'contributor') on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.audit_logs enable row level security;
alter table public.articles enable row level security;
alter table public.events enable row level security;
alter table public.gallery_albums enable row level security;
alter table public.media_assets enable row level security;
alter table public.staff_members enable row level security;
alter table public.academic_programmes enable row level security;
alter table public.faqs enable row level security;
alter table public.admission_enquiries enable row level security;
alter table public.testimonials enable row level security;
alter table public.website_settings enable row level security;
alter table public.navigation_items enable row level security;

create or replace function public.current_role() returns text language sql stable security definer set search_path=public as $$ select role from public.profiles where id=auth.uid() and is_active=true $$;
create or replace function public.has_staff_role(roles text[]) returns boolean language sql stable security definer set search_path=public as $$ select coalesce(public.current_role()=any(roles),false) $$;

create policy "profile self or administrator read" on public.profiles for select to authenticated using (id=auth.uid() or public.has_staff_role(array['super_admin','administrator']));
create policy "profile admin manage" on public.profiles for all to authenticated using (public.has_staff_role(array['super_admin'])) with check (public.has_staff_role(array['super_admin']));
create policy "audit administrators read" on public.audit_logs for select to authenticated using (public.has_staff_role(array['super_admin','administrator']));
create policy "audit authenticated insert" on public.audit_logs for insert to authenticated with check (actor_id=auth.uid());

-- Public can read published records; authenticated staff can review unpublished records.
do $$ declare t text; begin foreach t in array array['articles','events','gallery_albums','media_assets','staff_members','academic_programmes','faqs','testimonials','navigation_items'] loop
 execute format('create policy "public published read" on public.%I for select to anon,authenticated using (status=''published'')',t);
 execute format('create policy "staff content read" on public.%I for select to authenticated using (public.has_staff_role(array[''super_admin'',''administrator'',''editor'',''contributor'']))',t);
end loop; end $$;
create policy "editor article insert" on public.articles for insert to authenticated with check (
 (public.has_staff_role(array['super_admin','administrator'])) or
 (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or
 (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status in ('draft','pending_approval')));
create policy "editor article update" on public.articles for update to authenticated using (
 public.has_staff_role(array['super_admin','administrator','editor']) or
 (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status in ('draft','pending_approval')))
 with check ((public.has_staff_role(array['super_admin','administrator'])) or (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or (author_id=auth.uid() and status in ('draft','pending_approval')));
create policy "editor article delete" on public.articles for delete to authenticated using (public.has_staff_role(array['super_admin','administrator','editor']) or (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status='draft'));
create policy "editor event insert" on public.events for insert to authenticated with check ((public.has_staff_role(array['super_admin','administrator'])) or (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status in ('draft','pending_approval')));
create policy "editor event update" on public.events for update to authenticated using (public.has_staff_role(array['super_admin','administrator','editor']) or (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status in ('draft','pending_approval'))) with check ((public.has_staff_role(array['super_admin','administrator'])) or (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or (author_id=auth.uid() and status in ('draft','pending_approval')));
create policy "editor event delete" on public.events for delete to authenticated using (public.has_staff_role(array['super_admin','administrator','editor']) or (public.has_staff_role(array['contributor']) and author_id=auth.uid() and status='draft'));
-- Contributors may upload private draft media; publishing and content curation stays with editors and administrators.
create policy "staff media insert" on public.media_assets for insert to authenticated with check ((public.has_staff_role(array['super_admin','administrator'])) or (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or (public.has_staff_role(array['contributor']) and uploaded_by=auth.uid() and status in ('draft','pending_approval')));
create policy "staff media edit" on public.media_assets for update to authenticated using (public.has_staff_role(array['super_admin','administrator','editor']) or (public.has_staff_role(array['contributor']) and uploaded_by=auth.uid() and status in ('draft','pending_approval'))) with check ((public.has_staff_role(array['super_admin','administrator'])) or (public.has_staff_role(array['editor']) and status in ('draft','pending_approval')) or (uploaded_by=auth.uid() and status in ('draft','pending_approval')));
create policy "editor media delete" on public.media_assets for delete to authenticated using (public.has_staff_role(array['super_admin','administrator','editor']));
do $$ declare t text; begin foreach t in array array['gallery_albums','staff_members','academic_programmes','faqs','testimonials','navigation_items'] loop
 execute format('create policy "editor content insert" on public.%I for insert to authenticated with check (public.has_staff_role(array[''super_admin'',''administrator'']) or (public.has_staff_role(array[''editor'']) and status in (''draft'',''pending_approval'')))',t);
 execute format('create policy "editor content update" on public.%I for update to authenticated using (public.has_staff_role(array[''super_admin'',''administrator'',''editor''])) with check (public.has_staff_role(array[''super_admin'',''administrator'']) or (public.has_staff_role(array[''editor'']) and status in (''draft'',''pending_approval'')))',t);
 execute format('create policy "editor content delete" on public.%I for delete to authenticated using (public.has_staff_role(array[''super_admin'',''administrator'',''editor'']))',t);
end loop; end $$;
create policy "public settings read" on public.website_settings for select to anon,authenticated using (is_public=true);
create policy "admin settings manage" on public.website_settings for all to authenticated using (public.has_staff_role(array['super_admin','administrator'])) with check (public.has_staff_role(array['super_admin','administrator']));
create policy "admin enquiries manage" on public.admission_enquiries for all to authenticated using (public.has_staff_role(array['super_admin','administrator'])) with check (public.has_staff_role(array['super_admin','administrator']));

-- Private bucket: uploaded originals are never publicly addressable.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('school-media','school-media',false,10485760,array['image/jpeg','image/png','image/webp','image/avif']) on conflict(id) do nothing;
create policy "public approved school media read" on storage.objects for select to anon,authenticated using (
 bucket_id='school-media' and exists(select 1 from public.media_assets m where m.storage_path=name and m.status='published' and m.guardian_consent_verified=true));
create policy "active staff upload media" on storage.objects for insert to authenticated with check (bucket_id='school-media' and public.has_staff_role(array['super_admin','administrator','editor','contributor']));
create policy "staff access media" on storage.objects for select to authenticated using (bucket_id='school-media' and public.has_staff_role(array['super_admin','administrator','editor','contributor']));
create policy "staff remove media" on storage.objects for delete to authenticated using (bucket_id='school-media' and public.has_staff_role(array['super_admin','administrator','editor']));
