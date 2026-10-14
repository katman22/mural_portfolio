# Mural Portfolio

A small standalone Rails foundation for one mural artist. The gallery and full
admin editing UI are deliberately deferred.

## Baseline

- Rails 8.1.4, Ruby 3.3.12, Bundler 2.6.9.
- PostgreSQL 18 for development, test, and the eventual Render deployment.
- PostgreSQL adapter, Propshaft, Importmap, Turbo, Stimulus, and Minitest.
- Active Storage with image_processing and libvips variants.
- No Redis, Solid Cable, separate infrastructure databases, or authentication gem.

## Local setup

Install the pinned Ruby (rbenv is supported), PostgreSQL 18, and libvips. For example:

```sh
brew install postgresql@18 vips
bundle install
```

This foundation was validated using an independent PostgreSQL 18 cluster on port
5433; another local application already used port 5432. The database config
defaults to localhost:5433. Set PGPORT=5432 if your PostgreSQL 18 server uses that
port. Use the explicit postgresql@18 binaries when multiple versions are installed.
PGUSER/PGPASSWORD follow normal libpq environment behavior; without PGUSER, the
local OS role is used. Do not point local/test commands at a production URL.

```sh
bin/rails db:create db:migrate
RAILS_ENV=test bin/rails db:migrate
bin/rails test test/models
bin/rails test test/controllers
bin/rails test
bin/rails zeitwerk:check
bin/rails server
```

There is one database per environment: mural_portfolio_development and
mural_portfolio_test. CI explicitly uses postgres:18. Render PostgreSQL 18 is the
production target; no existing Render database upgrade is part of this repository.

On the current Intel development machine, libvips 8.18.7 was built with
JPEG/PNG/WebP support and installed at /usr/local/opt/mural-libvips-8.18.7.
Shared-library links in /usr/local/lib let ruby-vips load it without per-command
environment overrides. Other machines can use the normal Homebrew vips package.

## Domain foundation

Mural contains title, stable unique slug, optional location/year/client/plain-text
description, position (default 0), published (default false), and timestamps.
MuralPhoto belongs to a mural, has alt text and position, and attaches one image.
Both use explicit ordered scopes by position then id; associated photos are ordered.

Slugs are generated at creation, lowercase/hyphenated, and read-only afterward.
Duplicate titles receive distinct suffixes. The unique database index remains
authoritative; a bounded savepoint retry handles insertion races without aborting
an enclosing transaction. A title that normalizes to nothing uses mural as its base.

Drafts may be incomplete. Publication requires at least one photo, with an attached
image and meaningful alt text for every photo. Supported uploads are JPEG, PNG, and
WebP, up to 20 MB. Originals are retained; thumbnail and hero variants are defined
without implementing the gallery UI. A published-photo validation is enforced when
publishing its mural as well as when editing the photo.

## Public/admin shells

- `/`: artist-specific placeholder, not a mural gallery.
- `/murals/:slug`: published mural title placeholder; drafts/missing slugs return 404.
- `/admin`: session-protected administration placeholder; no CRUD interface yet.
- `/admin/login`: GET splash and POST login; `/admin/logout`: DELETE sign out.
- `/up`: Rails health check.

Administration now uses PostgreSQL User records and Rails encrypted cookie sessions.
`/admin/login` is the Whare Pūmanawa sign-in splash. Users must be active; incorrect,
unknown and inactive credentials receive the same error. Successful login resets
the session and redirects to /admin. Sign out clears the session. HTTP Basic and
ADMIN_USER/ADMIN_PASSWORD are no longer used. Passwords are bcrypt hashes; use
at least 12 characters. Usernames are stripped and lowercased.

Create the first user interactively in the Rails console for the intended database:

```ruby
require "io/console"
print "Username: "
username = STDIN.gets.chomp
password = STDIN.getpass("Password (12+ characters): "); nil
confirmation = STDIN.getpass("Confirm password: "); nil
User.create!(username: username, password: password, password_confirmation: confirmation); nil
password = confirmation = nil
```

Run `RAILS_ENV=production bin/rails console` only in the mural application's runtime
with its own DATABASE_URL and after its migrations have run. The password is hidden; the trailing `nil` prevents console echo of assigned
password values. It must never be pasted as a literal console command or placed in source/seed files.
No production user is created by these instructions or this implementation.
Deactivate a user with `user.update!(active: false)`; subsequent protected requests
will reject its session. Logout clears this browser's session, not other browsers.
No signup, recovery, roles, remember-me or account-management UI is provided.
Login is limited to 10 attempts per IP per three minutes in process-local memory;
this limit is not coordinated between workers or retained across restarts.
Production HTTPS and a stable independent SECRET_KEY_BASE are required. The Rails
session cookie is HttpOnly, SameSite=Lax and Secure in production, and contains a
user ID rather than credentials. It has no persistent remember-me expiry.

The splash chooses one of seven supplied static photos on each render and keeps it
fixed. Desktop uses a large image beside the form; mobile stacks a height-bounded
image above it. `object-fit: contain` preserves portrait and landscape compositions.
The simple decorative koru-inspired curve is replaceable brand artwork.

`.env.example` is documentation only. This app does not auto-load dotenv files.
Local generated Rails credentials and master.key are ignored; do not stage secrets.

## Future production configuration (placeholders only)

No web service, database, bucket, domain, or production credentials were provisioned.
Production will reuse the existing PostgreSQL 18 service in the pumanawa_kam
Render project. Use a separate logical database (for example,
`mural_portfolio_production`) and the mural application's own DATABASE_URL.
The mural app owns its schema and migrations within that database. Do not connect
it to the existing pumanawa_kam application database/schema, share tables, or add
cross-application foreign keys. Service capacity and connection limits are assumed
sufficient, as confirmed by the project owner. No PostgreSQL upgrade or additional
database service is required by this foundation.

Required environment settings before a future deployment:

- DATABASE_URL: the mural application's own URL for its independent logical database
+  on the existing PostgreSQL 18 service in the pumanawa_kam Render project.
- SECRET_KEY_BASE: a separately generated production secret.
- ACTIVE_STORAGE_SERVICE=object_storage.
- OBJECT_STORAGE_BUCKET, OBJECT_STORAGE_REGION.
- OBJECT_STORAGE_ACCESS_KEY_ID / OBJECT_STORAGE_SECRET_ACCESS_KEY.
- OBJECT_STORAGE_ENDPOINT for an S3-compatible provider (omit for AWS S3).
- ARTIST_NAME optionally changes layout branding.

config/storage.yml contains an S3-compatible placeholder using the standard
aws-sdk-s3 adapter. Development/test use normal Disk services. Production defaults
to object_storage, never permanent storage on the ephemeral Render web filesystem.
Choose and configure the artist's bucket later; this file creates no infrastructure.
Back up both the database and originals. Variants can be regenerated from originals.

Active Storage uses the normal async Active Job adapter in development and the test
adapter in tests; no dedicated worker is needed here. A durable production strategy
for analysis/purge jobs remains a deployment decision, and must be resolved before
live uploads. Installed gems or this placeholder are not a running worker.

Active Storage signed file URLs are not private draft authorization. Private delivery
and direct uploads are intentionally deferred.

## Next phase

Gallery thumbnail/detail selection, gallery-responsive styling, full admin Mural CRUD,
photo upload/edit/remove forms, and artist-specific branding/content. No categories,
maps, commerce, contact forms, multi-user auth, blog, analytics, or JSON API.

## Foundation validation

Real image attachment, thumbnail/hero processing and Active Storage HTTP delivery
are covered by model/integration tests. See research/foundation_validation.txt
for results and deployment assumptions. Deployment will use Render's native Ruby
runtime; ensure native libvips is available there before enabling image uploads.
