# Lean — Autonomous Mathematical Research System

Aether is an autonomous research system that discovers, formalizes, and accumulates mathematical knowledge using a two-phase pipeline. Phase A produces Lean 4 proofs and FUTURE_DIRECTIONS.md; Phase B packages results for humans as articles, papers, interactive demos, and visualizations.

## Quick Start

### Run the Research Loop

```bash
cd Aether && python3 aether_tick.py --loop --ollama-cloud --max-inflight 9 --novelty-slots 2 --interval 1800 --serve
```

This is the standard startup command. It runs continuously: each tick polls for completed jobs, integrates them, dispatches new ones, rebuilds the website (`update_index.py`), syncs to `docs/`, commits, and pushes to git. The `--serve` flag starts a local docs HTTP server at `http://localhost:8000`.

| Flag | Default | Description |
|------|---------|-------------|
| `--max-inflight N` | 9 | Max concurrent Aristotle jobs |
| `--novelty-slots N` | 2 | Dispatch slots reserved for Novelty directions |
| `--interval SECONDS` | 21600 | Sleep between ticks (21600 = 6h, 1800 = 30min) |
| `--ollama-cloud` | off | Enable Ollama cloud backend |
| `--loop` | off | Run continuously (single tick otherwise) |
| `--serve` | off | Start local docs HTTP server alongside Aether |
| `--serve-port PORT` | 8000 | Docs server port |

Single run (no loop):
```bash
cd Aether && python3 aether_tick.py --ollama-cloud
```

### View the Knowledge Graph

Open `Catalog/Applications/Packages/index.html` in a browser, or visit the GitHub Pages deployment. The frontend supports light and dark themes with tabbed package views.

## Architecture

```
Discover → Phase A (Execute) → Phase B (Package) → Integrate → Repeat
     │              │                    │                │
     ▼              ▼                    ▼                ▼
FutureDirections  Lean 4 proofs    Article, Paper,     Catalog +
                  + FUTURE_         Demo, PACKAGE.json  new directions
                  DIRECTIONS.md
```

### Two-Phase Research Pipeline

**Phase A** — Formalization and Discovery:
- Aristotle receives a research concept and produces Lean 4 proofs, FUTURE_DIRECTIONS.md, and raw research artifacts
- FUTURE_DIRECTIONS.md is extracted and fed into the future directions pool for subsequent cycles
- Anti-triviality rules reject commutativity proofs, wrapper theorems, and simp-only proofs

**Phase B** — Packaging for Humans:
- Takes Phase A results and produces a polished package: ARTICLE.md, RESEARCH_PAPER.md, interactive demos, visualizations, algorithms, and a structured PACKAGE.json
- PACKAGE.json schema includes: `algorithms`, `visualizations`, `demos`, `interactive_demos` — all must be real implementations, never placeholder strings
- Phase B results are not subject to salvage mode (which only applies to Phase A)

### Cycle Flow

1. **Discover** — `knowledge_extractor.discover()` pops a weighted-random future direction (with inverse-frequency domain balancing), builds a `ResearchConcept`, and creates a `ResearchJob`
2. **Execute (Phase A)** — Aristotle produces Lean 4 proofs, articles, research papers, demos, and FUTURE_DIRECTIONS.md
3. **Package (Phase B)** — Results are packaged for human consumption with full interactive content
4. **Integrate** — `knowledge_extractor.run_single_cycle()` unpacks artifacts into the Catalog, extracts new future directions, and marks the consumed direction as completed
5. **Repeat** — The next cycle picks up newly seeded directions

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `Aether/` | Core research pipeline — discovery, dispatch, evaluation, integration |
| `Catalog/` | Published research packages (JSON + Lean) + web visualization |
| `docs/` | GitHub Pages website (synced from `Catalog/Applications/Packages/`) |

## Key Files

| File | Purpose |
|------|---------|
| `Aether/aether_tick.py` | Main pipeline entry point — loop mode, rebuild, commit, push; dispatches Phase A and Phase B |
| `Aether/knowledge_extractor.py` | Orchestrates the full cycle: discover → Phase A → Phase B → integrate; salvage mode; future directions extraction |
| `Aether/pi_agent_client.py` | Builds research prompts for Phase A (`write_aristotle_prompt`) and Phase B (`_build_phase_b_package_prompt`) |
| `Aether/research_memory.py` | Tracks future directions (available/in_progress/completed/pruned) with quality scoring and anti-repetition |
| `Aether/lineage_extractor.py` | Builds knowledge graph (provenance edges) |
| `Aether/catalog_analyzer.py` | Analyzes existing Catalog theorems for context |
| `Aether/output_organizer.py` | Maps domain names to Catalog directories; `DOMAIN_DIRS` — valid domain list |
| `Aether/aristotle_loop.py` | UCB-based domain selection, cross-domain synergy tracking |
| `Aether/seed_directions.py` | 201 seed directions including 97 novelty-tagged directions |
| `Catalog/Applications/Packages/update_index.py` | Bundles packages into `packages_db.js`, adds quality scores |
| `Catalog/Applications/Packages/js/packages.js` | Frontend rendering — tabbed views, interactive demos, light/dark themes |
| `Catalog/Applications/Packages/style.css` | Frontend styling — fixed sidebar layout, gradient titles, responsive design |

## Frontend Features

The package viewer at `Catalog/Applications/Packages/index.html` provides:

- **Light/Dark Themes** — Toggle between themes with CSS custom properties; light mode uses appropriate gradients and backgrounds
- **Tabbed Package Views** — Lean 4 Proofs (with original file paths), Article, Paper, Future Directions, Interactive
- **Interactive Tab** — Shows algorithms, visualizations, and demos from PACKAGE.json (with Array.isArray guards for robustness)
- **Fixed Sidebar Layout** — 320px fixed sidebar with natural-scrolling main content; responsive overlay on mobile
- **Knowledge Graph** — Deep-space physics simulation with Möbius-Klein topology, N-body gravity, quality-driven node sizing

## Future Directions System

### Data Model

Each `FutureDirection` has:
- `id`, `title`, `description` — identity and content
- `source_exp_id`, `source_path` — provenance
- `domains` — tag list, **capped at 2** per direction
- `priority_score` — 0.0–1.0, higher = popped first
- `status` — `available` | `in_progress` | `completed` | `pruned`

### Quality Scoring and Anti-Bias

- **Domain decay**: `0.25^min(1, (count-1)/6)` for overrepresented domains
- **First-time domain bonus**: +0.15 for domains with ≤2 completions
- **Anti-repetition penalty**: -0.03 per keyword appearing 3+ times in recent completions (capped at -0.15)
- **Auto-title cap**: Directions starting with "Direction N:" are capped at priority 0.60
- **Novelty protection**: Cleanup and auto-pruning skip directions tagged with "Novelty"
- **Seed protection**: Auto-pruning never removes seed directions
- **Conservative LLM pruning**: Reviews only bottom 30% by quality, requires justification for each removal

### Novelty Track

- Dispatch slots reserved for Novelty-tagged directions (`--novelty-slots 2`)
- Auto-refill from `seed_directions.py` when <5 Novelty directions are available
- Novelty-tagged directions are protected from LLM cleanup pruning

### Extraction Pipeline

Future directions are extracted from Phase A results in priority order:
1. `result_future_directions` field on the job result
2. `future_directions` array in PACKAGE.json
3. `.md` files in the project directory matching "future" in the filename
4. Inline Lean comment blocks (`-- FUTURE DIRECTIONS` and `/-! FUTURE DIRECTIONS...-/`) parsed from `result_lean`

## Salvage Mode

When Phase A produces Lean files with errors (e.g., `sorry` usage), `knowledge_extractor._salvage_best_theorems()` extracts valid theorems and creates a `SalvagedBest.lean` file. Key behaviors:
- Uses original Phase A file paths in `lean_proofs` (not SalvagedBest.lean) so the frontend shows the original source files
- Only applies to Phase A completions — Phase B results skip salvage mode entirely

## Domain System

### Valid Domains (DOMAIN_DIRS)

`Algebra`, `Applications`, `Bridges`, `Computation`, `Cryptography`, `EML`, `Geometry`, `Logic`, `MachineLearning`, `Novelty`, `Physics`, `Pythagorean`, `Shared`, `Tropical`

Novelty is a first-class domain. Speculative is **not** a valid Catalog domain — sub-domains map to real domains via `normalize_domain()`.

### Domain Routing

`discover()` uses the **Aristotle loop's domain selection** (UCB-based), not the future direction's `domains[0]`. This prevents any single domain from dominating dispatch.

### Inverse-Frequency Balancing

`select_direction_weighted()` applies:
- Domains >30% of available pool: penalized `weight *= (1 - fraction)`
- Domains <10%: boosted `weight *= (1 + fraction)`

## Adversarial Judging

Phase A results are evaluated by an adversarial judge that checks for:
- Trivial proofs (commutativity, wrapper theorems, simp-only)
- Missing definitions or insight
- Shallow results that don't advance the research frontier

Low-scoring results may be salvaged (best theorems extracted) rather than discarded entirely.

## GitHub Pages

The website is served from the `docs/` directory on the `master` branch (branch-based deployment, no Actions minutes). After each tick, `docs/` is synced from `Catalog/Applications/Packages/`.

GitHub Pages settings: **Source → Deploy from a branch → master → /docs**

## Testing

```bash
cd Aether && pytest tests/test_future_directions.py -v
```

**TDD Policy:** All changes to the Future Directions system MUST follow test-driven development — write tests first, see them fail, implement, confirm they pass.

## Reset / Reseed Directions

```bash
cd Aether && python research_memory.py reset   # Abandon in-progress, reseed
cd Aether && python research_memory.py stats   # Show counts by status
```

## Code Conventions

- Python 3.10+ with type hints
- Dataclasses for structured data
- JSON file persistence in `.aether_workspace/`
- Domain inference via keyword matching, capped at 2 domains per direction
- Dedup by title exact match OR description word overlap > 0.7
- UCB bandit for domain selection (no hardcoded priorities)
- Cross-domain synergy learned from data only (no hardcoded KNOWN_SYNERGIES)