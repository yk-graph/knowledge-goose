# Workflow Checklist: Shipping an App in 3 Days with ClaudeCode

> Available in: English | [日本語](./ja/workflow-checklist.md)
>
> **Approach**: Don't write the implementation code yourself. Have ClaudeCode write it. Understand the intent and meaning of the generated code, and instruct corrections when something is wrong.

---

## Overall Schedule (Estimate)

| Day                   | Phase                         | Time        |
| --------------------- | ----------------------------- | ----------- |
| Day 1 morning         | Phase 1: Requirements         | 2-3 hours   |
| Day 1 afternoon       | Phase 2: Design               | 3-4 hours   |
| Day 1 evening         | Phase 3: ClaudeCode setup     | 1-2 hours   |
| Day 2 morning         | Phase 4: Task breakdown       | 1-2 hours   |
| Day 2 - Day 3 morning | Phase 5: Implementation loop  | Main effort |
| Day 3 afternoon       | Phase 6: Deploy               | 2-3 hours   |
| Day 3 evening         | Buffer / release announcement | —           |

---

## Phase 1: Requirements (Before Starting ClaudeCode)

Tools: Claude.ai or pen and paper. Don't start ClaudeCode yet.

- [ ] Articulate the app idea in 3 lines (what / for whom / why)
- [ ] Create `docs/prd.md`
  - [ ] Product overview
  - [ ] Target users
  - [ ] User stories ("As a ..., I want to ..., so that ..." × 3 to 7)
  - [ ] Acceptance criteria (as a checklist)
  - [ ] **Items NOT in MVP (out of scope)** ← important
  - [ ] Success metrics (what to measure after release)

**Done criteria**: A reader other than yourself could understand what is being built by reading the PRD.

---

## Phase 2: Design

Tools: Claude.ai. Try ClaudeCode's Plan mode at the end of Phase 2.

- [ ] Create `docs/stack.md`
  - [ ] Bullet list of framework / UI / state / test / deploy choices
  - [ ] One-line rationale for each choice
- [ ] Create `docs/architecture.md`
  - [ ] Screen list
  - [ ] Screen transition diagram (Mermaid)
  - [ ] Component hierarchy
- [ ] Create `docs/data-model.md`
  - [ ] TypeScript `interface` for each entity
  - [ ] If a backend exists, list of API endpoints
- [ ] Create `docs/conventions.md`
  - [ ] Naming conventions
  - [ ] Directory structure
  - [ ] Import order
  - [ ] Test approach
  - [ ] Commit conventions / branching strategy
- [ ] (Optional) Run ClaudeCode in Plan mode to review the design

**Done criteria**: The four files above exist, and design ambiguities have been resolved.

---

## Phase 3: ClaudeCode Setup ★ This Is the Crucial Phase

Tools: Start ClaudeCode now.

### Repository Initialization

- [ ] Create the git repository, make the initial commit on `main`
- [ ] Generate the framework project skeleton
- [ ] Add basic files: `.gitignore`, `.editorconfig`, `.nvmrc`
- [ ] Outline the README

### Files ClaudeCode Reads on Every Session

- [ ] Create `CLAUDE.md` at the repository root
  - [ ] Project overview (2-3 lines)
  - [ ] Summary of directory structure
  - [ ] Build / test / lint / type-check commands
  - [ ] Coding convention summary (refer detailed rules to `docs/conventions.md`)
  - [ ] Common pitfalls / cautionary notes
  - [ ] **Keep it small** (target under 200 lines)

### Custom Slash Commands

- [ ] Create the `.claude/commands/` directory
- [ ] `feature.md` (template for adding a new feature)
- [ ] `review.md` (self-review)
- [ ] `fix-tests.md` (repair failing tests)
- [ ] `refactor.md` (refactor guidance)
- [ ] Add others tailored to your workflow as you find them

### MCP / Skills

- [ ] If needed, configure `.mcp.json` (GitHub / Figma, etc.)
- [ ] If needed, place specialized practice files under `.claude/skills/`

### Development Environment

- [ ] Lint (e.g., ESLint) runs via `npm run lint` (or equivalent)
- [ ] Formatter (e.g., Prettier) runs via `npm run format`
- [ ] Tests (e.g., Vitest / Jest) run via `npm run test`
- [ ] Type-check (`tsc --noEmit`) runs via `npm run typecheck`
- [ ] Git hooks (husky + lint-staged) run checks before commit
- [ ] **Make a commit at this point**

**Done criteria**: A fresh ClaudeCode session can pick up your tasks with the conventions and commands already understood.

---

## Phase 4: Task Breakdown

Tools: Claude.ai or ClaudeCode, either is fine.

- [ ] Break user stories from the PRD into epics
- [ ] Break epics into tasks
  - [ ] Each task should be **completable in a single PR**
  - [ ] Each task has a written "Definition of Done"
  - [ ] Note dependencies with arrows
- [ ] Register tasks in `TODO.md` or GitHub Issues
- [ ] Set milestones (MVP / α / β)
- [ ] Confirm the tasks scoped for the first milestone

**Done criteria**: The first task to tackle is clear; you can move into Phase 5 without hesitation.

---

## Phase 5: Implementation Loop (Repeat for Each Task)

Run the following as a single session per task:

- [ ] Reset context with `/clear`
- [ ] Paste the task spec (relevant portions of PRD and design docs)
- [ ] Use **Plan mode** (Shift+Tab) to have ClaudeCode plan the work
- [ ] Review the plan; adjust if needed
- [ ] Switch to normal mode and implement
- [ ] Add tests (or have ClaudeCode write them)
- [ ] Run tests → on failure, feed the log back to ClaudeCode for self-correction
- [ ] Pass type-check / lint
- [ ] Run `/review` for self-review
- [ ] Read the diff yourself (understand intent and meaning; instruct corrections as needed)
- [ ] Commit and open a PR
- [ ] Verify CI is green
- [ ] Merge
- [ ] Update `TODO.md` checkmarks

### Context Management (During a Session)

- [ ] If context gets long, summarize with `/compact`
- [ ] If still struggling, reset with `/clear` (offload essentials to `CLAUDE.md` or working notes)
- [ ] For parallel work, use `git worktree add` + a separate ClaudeCode session

### When You're Stuck

- [ ] Is the task granularity right (not too big)?
- [ ] Is the spec given to ClaudeCode specific enough?
- [ ] Has the design made tests difficult to write?
- [ ] Did you skip Plan mode?
- [ ] Has `CLAUDE.md` drifted out of sync with reality?

---

## Phase 6: Deploy

- [ ] Create `docs/deployment.md`
  - [ ] Environment variable list
  - [ ] Hosting target (Vercel / Cloudflare Pages / other)
  - [ ] Deploy procedure
- [ ] Create `.env.example`
- [ ] CI workflow (`.github/workflows/ci.yml`)
  - [ ] Runs lint / type-check / tests
- [ ] Hosting configuration
  - [ ] Connect the project to the hosting target
  - [ ] Register production environment variables
  - [ ] Verify the preview deployment
- [ ] Production deploy
- [ ] Verify behavior (manually walk through the main user stories)
- [ ] Polish the README
  - [ ] Project overview
  - [ ] Screenshots
  - [ ] How to run
  - [ ] How to deploy
  - [ ] License

---

## After Release

- [ ] Write a retrospective blog post
- [ ] Announce on X / LinkedIn / similar channels
- [ ] Note improvements in `BACKLOG.md` (input for next iteration)
- [ ] Review this checklist itself and turn it into a reusable template
