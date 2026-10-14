# Project guidance

## General approach
- Inspect existing patterns before changing code.
- Prefer the smallest change that satisfies the requirement.
- Do not introduce abstractions without demonstrated need.
- Do not refactor unrelated code.
- Explain broad or architectural changes before implementing them.

## Rails
- Follow Zeitwerk and Rails autoloading conventions.
- Keep controllers thin.
- Use normal Active Record validations and database constraints.
- Prefer standard Rails CRUD for straightforward admin flows.
- Avoid manual requires for application code unless clearly necessary.
- PostgreSQL 18 is the development, test, and production baseline.

## Views and frontend
- Use server-rendered ERB first.
- Use Stimulus for local interaction and Turbo where Rails naturally benefits.
- Do not introduce React, a headless API, or another frontend framework.
- Preserve progressive enhancement and accessibility.

## Testing
- Run narrow tests before broad suites.
- Add regression tests for new behavior.
- Do not weaken tests to make changes pass.
- Run bin/rails zeitwerk:check after namespacing or loading changes.

## Safety
- Do not modify production credentials or commit real credentials.
- Do not run destructive database commands.
- Do not provision cloud resources or introduce external services without approval.
- Keep the existing Git repository, origin, and main branch intact.

## Workflow
- Save review/completion summaries as descriptive text files in research/.
- Stage new task-created files before handoff; do not stage unrelated changes.
- Do not commit or push unless explicitly requested.
