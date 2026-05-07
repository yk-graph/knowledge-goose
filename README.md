# Knowledge Goose

[English](./README.md) | [日本語](./README.ja.md)

> Competitor analysis and insight visualization tool for an independent cafe in Vancouver.

## Overview

**Knowledge Goose** helps a single-store cafe owner understand their local competitive landscape through structured data collection and side-by-side visualization. By combining manual on-site observations with public Google Places data, it provides a factual baseline for hypothesis-driven decisions on customer acquisition.

This project is built as a 3-day MVP, as part of an experiment to ship a working product without writing the implementation code by hand — using [ClaudeCode](https://www.anthropic.com/claude-code) for the actual code generation and self-review while the human focuses on requirements, design, and validation.

## Key Features (MVP)

- **Map View** — All competitor stores pinned on a map with click-to-detail interaction
- **Time Series Chart** — Customer count, estimated revenue, and Google review trends over time
- **Comparison Table** — Side-by-side feature comparison between own store and up to 3 competitors

Out of scope for the MVP: deletion / editing of past observation records, CSV export, multi-language UI (planned post-MVP).

## Tech Stack

| Layer               | Technology                                           |
| ------------------- | ---------------------------------------------------- |
| Framework           | Next.js 16 (App Router)                              |
| Language            | TypeScript (strict mode)                             |
| Database            | PostgreSQL on AWS RDS / PostgreSQL on Docker (local) |
| ORM                 | Drizzle ORM                                          |
| Auth                | better-auth (email + password, Google OAuth)         |
| Transactional Email | Resend                                               |
| UI                  | Tailwind CSS + shadcn/ui                             |
| Forms               | react-hook-form + Zod                                |
| Map                 | Google Maps JavaScript API + Places API              |
| Charts              | Recharts                                             |
| Lint / Format       | ESLint + Prettier                                    |
| Hosting             | AWS Amplify Hosting                                  |

See [docs/stack.md](./docs/stack.md) for the rationale behind each choice.

## Prerequisites

- Node.js 24 LTS (use the version pinned in `.nvmrc`)
- pnpm 9+
- Docker (for the local PostgreSQL container)
- Google Cloud account with **Places API** and **Maps JavaScript API** enabled
- Resend account for transactional emails

## Getting Started

```bash
# Clone the repo
git clone git@github.com:yk-graph/knowledge-goose.git
cd knowledge-goose

# Install dependencies
pnpm install

# Copy and configure environment variables
cp .env.example .env.local
# Edit .env.local with your API keys and DB credentials

# Start the local PostgreSQL container
docker compose up -d

# Generate, apply migrations, and seed the database
pnpm db:generate
pnpm db:migrate
pnpm db:seed

# Run the development server
pnpm dev
```

The application should now be running at [http://localhost:3000](http://localhost:3000).

> **Note**: The first registered user is automatically assigned the `staff` role. To grant `admin` privileges, update the user's role directly in the database via SQL. See [docs/conventions.md](./docs/conventions.md) for details.

## Available Scripts

| Command            | Description                                     |
| ------------------ | ----------------------------------------------- |
| `pnpm dev`         | Start the development server                    |
| `pnpm build`       | Create a production build                       |
| `pnpm start`       | Run the production server                       |
| `pnpm lint`        | Run ESLint                                      |
| `pnpm format`      | Run Prettier                                    |
| `pnpm typecheck`   | Type-check without emitting files               |
| `pnpm db:generate` | Generate Drizzle migrations from schema changes |
| `pnpm db:migrate`  | Apply pending migrations                        |
| `pnpm db:seed`     | Insert seed data                                |
| `pnpm db:studio`   | Open Drizzle Studio (web-based DB GUI)          |

## Project Structure

```
knowledge-goose/
├── app/                  # Next.js App Router pages and layouts
├── components/           # React components (UI / feature-specific)
├── actions/              # Next.js Server Actions
├── db/                   # Drizzle schema and database client
├── lib/                  # External service integrations and utilities
├── schemas/              # Zod validation schemas
├── types/                # Shared TypeScript types
├── docs/                 # Design documentation (English / Japanese under ./ja)
├── notes/                # Development blog entries (EN/JA pairs)
├── drizzle/              # Auto-generated migration files
├── public/               # Static assets
├── .claude/              # ClaudeCode commands and skills
├── CLAUDE.md             # Project conventions for ClaudeCode
├── AGENTS.md             # Generic agent instructions
└── docker-compose.yml    # Local PostgreSQL setup
```

For the full architectural breakdown, see [docs/architecture.md](./docs/architecture.md).

## Documentation

All design documents live under `docs/`. English versions are primary; Japanese translations are mirrored under `docs/ja/`.

- [Product Requirements (PRD)](./docs/prd.md)
- [Data Model](./docs/data-model.md)
- [Tech Stack](./docs/stack.md)
- [Architecture](./docs/architecture.md)
- [Coding Conventions](./docs/conventions.md)
- [API Reference](./docs/api.md)
- [Test Strategy](./docs/test-strategy.md)
- [Deployment Guide](./docs/deployment.md)

## Development Blog

Build journal documenting decisions and lessons learned, published in both languages under `notes/`.

## Status

This project is under active development as a 3-day MVP. Features marked as "post-MVP" in the [PRD](./docs/prd.md) are not yet implemented and are planned for subsequent iterations. Top of the post-MVP backlog:

- Multi-language UI (Japanese + Korean)
- Excel / spreadsheet export for comparison data

## License

TBD — license file will be added before public release.
