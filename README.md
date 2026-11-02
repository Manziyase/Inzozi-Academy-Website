# Inzozi Academy website and content studio

A responsive Next.js public site and staff-only CMS. Published public content, private admissions enquiries, staff roles, media, and audit records use Supabase PostgreSQL, Auth, and private Storage.

## Run locally

1. Install Node.js 20 or newer.
2. Copy `.env.example` to `.env.local` and enter the Supabase project URL, anon key, and server-only service-role key. Set `NEXT_PUBLIC_SITE_URL` to the local or production origin.
3. In Supabase SQL Editor, run `supabase/migrations/202611020001_initial_schema.sql`.
4. In Supabase Auth settings, allow the application origin and `/admin/reset-password` as redirect URLs. Configure an email provider for staff invitations and password-reset email.
5. Create the first staff login through Supabase Auth, then promote it in SQL Editor:

   ```sql
   update public.profiles
   set role = 'super_admin', is_active = true
   where email = 'admin@your-school-domain.rw';
   ```

6. Run `npm install`, then `npm run dev`. Open `http://localhost:3000`; the public site is at `/` and staff sign-in is at `/admin`.

The public registration route is intentionally absent. Super administrators invite staff from **Staff accounts**. The service-role key is used only by server routes for invitations and public enquiry writes; it must never be exposed as a `NEXT_PUBLIC_` variable.

## Roles and review

- Super administrators manage staff accounts, roles, settings, and all content.
- Administrators manage content and enquiries and can publish.
- Editors create and edit website content and submit it for approval.
- Contributors create their own article/event drafts and upload draft media.

Database Row Level Security enforces content roles in addition to the API checks. Contributors can only edit their own drafts or submitted content. Editors cannot publish. Only an administrator or super administrator can publish. Admissions enquiry rows are not publicly readable and can only be reviewed by administrators.

## Child photo privacy

Uploads are validated as images, compressed in the browser to WebP, limited to 10 MB, and stored in a private bucket. Unpublished images require an authenticated staff session. Public delivery checks that an image has published status and verified guardian consent; article and album publication also provide an explicit consent control. Never mark consent verified unless the school has recorded the appropriate parent/guardian permission.

## Deployment checklist

- Configure all three environment variables in the production host and set the real site origin.
- Apply the migration to the production Supabase project and configure Auth email templates/redirects for the hosted domain.
- Keep the Supabase service-role key server-only and rotate it if exposed.
- Configure managed database backups and test restore procedures in Supabase.
- Confirm the school’s privacy/consent process, policies, and approved photography before publishing images.
- Set an appropriate persistent, shared rate limiter/WAF for the public enquiry endpoint when deploying to multiple serverless instances. The included in-process limiter is a local/basic abuse guard, not a distributed rate limit.
- Verify production domain, HTTPS, email delivery, upload limits, social metadata, and mobile layouts before launch.

## Implementation notes

School-specific content is based on the [official school website](https://inzoziacademy.rw/) and its [public staff directory](https://inzoziacademy.rw/our-team/). News, event, and testimonial sections start empty rather than showing fabricated entries. The supplied `Images and Icons` school logo, classroom photos, and published staff portraits are reused in `public/images`. New CMS photo uploads remain private until staff verify consent and an administrator publishes them. The admissions form and account invitations need the server-only service key, and database-backed areas need valid Supabase project credentials before use.
