# Lean — Autonomous Mathematical Research System

Aether is an autonomous research system that discovers, formalizes, and accumulates mathematical knowledge using a two-phase pipeline. Phase A produces Lean 4 proofs and FUTURE_DIRECTIONS.md; Phase B packages results for humans as articles, papers, interactive demos, and visualizations.

## Quick Start

### Install the git hooks

After cloning, install the tracked hooks so versioning, catalog-lean updates, and pushes happen automatically on every commit:

```bash
bash Aether/.aether_workspace/git-hooks/install-hooks.sh
```

### Run the Research Loop

```bash
cd Aether && python3 aether_tick.py --loop --max-inflight 9 --novelty-slots 3 --interval 1800 --serve --log .aether_workspace/aether.log
```

This is the standard startup command. It runs continuously: each tick polls for completed jobs, integrates them, dispatches new ones, rebuilds the website (`update_index.py`), syncs to `docs/`, commits, and pushes to git. The `--serve` flag starts a local docs HTTP server at `http://localhost:8000`. The `--log` flag tees all output to a log file while still printing to the console.

| Flag | Default | Description |
|------|---------|-------------|
| `--max-inflight N` | 9 | Max concurrent Aristotle jobs |
| `--novelty-slots N` | 3 | Dispatch slots reserved for novelty/wild directions |
| `--interval SECONDS` | 21600 | Sleep between ticks (21600 = 6h, 1800 = 30min) |
| `--loop` | off | Run continuously (single tick otherwise) |
| `--serve` | off | Start local docs HTTP server alongside Aether |
| `--serve-port PORT` | 8000 | Docs server port |
| `--log PATH` | off | Tee all output (stdout + stderr) to a log file; relative paths resolve from the Aether directory |

Single run (no loop):
```bash
cd Aether && python3 aether_tick.py
```

### View the Knowledge Graph

Open `Packages/index.html` in a browser, or visit the GitHub Pages deployment. The frontend supports light and dark themes with tabbed package views, interactive demos, auto-run visualizations, and a regenerate button for edited outputs.

## Architecture

```
Discover → Phase A (Execute) → Phase B (Package) → Integrate → Repeat
     │              │                    │                │
     ▼              ▼                    ▼                ▼
FutureDirections  Lean 4 proofs    Article, Paper,     Catalog +
                  + FUTURE_         Demo, PACKAGE.json  new directions
                  DIRECTIONS.md
```

Aether is fully self-managing: it detects its own code changes via mtime watchdogs, restarts itself after `git pull`, maintains a long-term archive of every Aristotle project, and publishes both a lean-only branch (`catalog-lean`) and a GitHub Pages site from `docs/`.

### Two-Phase Research Pipeline

**Phase A** — Formalization and Discovery:
- Aristotle receives a research concept and produces Lean 4 proofs, FUTURE_DIRECTIONS.md, and raw research artifacts
- FUTURE_DIRECTIONS.md is extracted and fed into the future directions pool for subsequent cycles
- Anti-triviality rules reject commutativity proofs, wrapper theorems, and simp-only proofs

**Phase B** — Packaging for Humans:
- Takes Phase A results and produces a polished package: ARTICLE.md, RESEARCH_PAPER.md, interactive demos, visualizations, algorithms, and a structured PACKAGE.json
- PACKAGE.json schema includes: `algorithms`, `visualizations`, `demos`, `interactive_demos` — all must be real implementations, never placeholder strings
- Self-contained articles include the full Lean 4 proof source inline so packages can be read without external files
- Phase B results are not subject to salvage mode (which only applies to Phase A)

### Cycle Flow

1. **Discover** — `knowledge_extractor.discover()` pops a weighted-random future direction (with inverse-frequency domain balancing), builds a `ResearchConcept`, and creates a `ResearchJob`
2. **Execute (Phase A)** — Aristotle produces Lean 4 proofs, articles, research papers, demos, and FUTURE_DIRECTIONS.md
3. **Adversarial Judge** — A separate judge scores the result for non-triviality, completeness, and novelty; low-scoring results are salvaged or discarded
4. **Package (Phase B)** — Results are packaged for human consumption with full interactive content
5. **Integrate** — `knowledge_extractor.run_single_cycle()` unpacks artifacts into the Catalog, extracts new future directions, and marks the consumed direction as completed
6. **Repeat** — The next cycle picks up newly seeded directions

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `Aether/` | Core research pipeline — discovery, dispatch, evaluation, integration |
| `Aether/.aether_workspace/` | Runtime state, logs, and tracked tooling (including git hooks and the archive DB) |
| `Archive/` | Long-term content-addressable archive of all Aristotle projects (can be split across WSL and external drives) |
| `Catalog/` | Published research packages (JSON + Lean) + web visualization. **Canonical frontend source.** |
| `docs/` | GitHub Pages website (synced from `Packages/`). **DO NOT EDIT DIRECTLY.** |

> [!WARNING]
> The `docs/` folder is automatically synchronized from `Packages/`. If you are making changes to the website frontend (HTML, JS, CSS), you **must** make them in `Packages/` to prevent them from being overwritten during the next Aether tick.

## Key Files

### Pipeline

| File | Purpose |
|------|---------|
| `Aether/aether_tick.py` | Main pipeline entry point — loop mode, rebuild, commit, push; dispatches Phase A and Phase B |
| `Aether/knowledge_extractor.py` | Orchestrates the full cycle: discover → Phase A → judge → Phase B → integrate; salvage mode; future directions extraction |
| `Aether/pi_agent_client.py` | Builds research prompts for Phase A (`write_aristotle_prompt`) and Phase B (`_build_phase_b_package_prompt`) |
| `Aether/quality_evaluator.py` | Adversarial judge / critic gate for Phase A results |
| `Aether/research_memory.py` | Tracks future directions (available/in_progress/completed/pruned) with quality scoring and anti-repetition |
| `Aether/aristotle_loop.py` | UCB-based domain selection, cross-domain synergy tracking |
| `Aether/seed_directions.py` | Seed directions including novelty-tagged directions |
| `Aether/git_automator.py` | Builds commits from the current pipeline state |

### Archive and Analysis

| File | Purpose |
|------|---------|
| `Aether/backfill_aristotle_archive.py` | One-shot backfill of all past Aristotle projects into the local archive |
| `Aether/archive_manager.py` | SQLite + blob archive manager with split-layout support |
| `Aether/theorem_extractor.py` | Lean theorem parser used by the archive for rich metadata |
| `Aether/archive_utils.py` | Shared streaming download / memory-cap helpers |
| `Aether/package_single_job.py` | Build or extract a research package for one Aristotle project |
| `Aether/planning_guide.py` | Interactive questionnaire that emits backfill/package commands |
| `Aether/catalog_analyzer.py` | Analyzes existing Catalog theorems for context |
| `Aether/lineage_extractor.py` | Builds knowledge graph (provenance edges) |
| `Aether/catalog_pruner.py` | Actively shrinks the catalog by grouping similar packages and keeping the best ones |
| `Aether/catalog_scorer.py` | Scores catalog packages for the quality dashboard |
| `Aether/output_organizer.py` | Maps domain names to Catalog directories; `DOMAIN_DIRS` — valid domain list |

### Git Hooks and Automation

| File | Purpose |
|------|---------|
| `Aether/.aether_workspace/git-hooks/pre-commit` | Tracked hook: bumps version badges, cache-busts query strings, rebuilds `catalog-lean` |
| `Aether/.aether_workspace/git-hooks/post-commit` | Tracked hook: pushes `catalog-lean` with stale-info guard (fetch, retry, then `--force`) |
| `Aether/.aether_workspace/git-hooks/install-hooks.sh` | Copies the tracked hooks into `.git/hooks` after cloning or updates |
| `Aether/.aether_workspace/update-catalog-branch.sh` | Rebuilds the lean-only `catalog-lean` branch on top of the current remote tip |

### Frontend

| File | Purpose |
|------|---------|
| `Packages/index.html` | Web viewer for all research packages |
| `Packages/update_index.py` | Regenerates the website index from `Packages/*.json` — `package_index.js`, `future_directions.js`, `catalog_tree.json` — and cache-busts `index.html` |
| `Packages/js/packages.js` | Frontend rendering — tabbed views, interactive demos, light/dark themes |
| `Packages/style.css` | Frontend styling — fixed sidebar layout, gradient titles, responsive design |

## Frontend Features

The package viewer at `Packages/index.html` provides:

- **Light/Dark Themes** — Toggle between themes with CSS custom properties; light mode uses appropriate gradients and backgrounds
- **Tabbed Package Views** — Lean 4 Proofs (with original file paths), Article, Paper, Future Directions, Interactive
- **Interactive Tab** — Shows algorithms, visualizations, and demos from PACKAGE.json (with Array.isArray guards for robustness)
- **Auto-run Demos** — Visualizations and interactive demos execute automatically when the tab opens
- **Regenerate Button** — Edited visualizations/demos can be refreshed in place without reloading the page
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

`Algebra`, `Applications`, `Bridges`, `Combinatorics`, `Computation`, `Cryptography`, `Geometry`, `Logic`, `MachineLearning`, `Novelty`, `NumberTheory`, `Physics`, `Probability`, `Pythagorean`, `Shared`, `Tropical`

Novelty is a first-class domain. `EML` and `Speculative` are deprecated: `normalize_domain()` routes them to `Applications` and `Novelty` respectively (the `EML/` and `Speculative/` Catalog dirs exist only for legacy content). Unknown or unrecognized sub-domains also fall through to `Novelty`.

### Domain Routing

`discover()` uses the **Aristotle loop's domain selection** (UCB-based), not the future direction's `domains[0]`. This prevents any single domain from dominating dispatch.

### Inverse-Frequency Balancing

`select_direction_weighted()` applies:
- Domains >30% of available pool: penalized `weight *= (1 - fraction)`
- Domains <10%: boosted `weight *= (1 + fraction)`

## Adversarial Judging

Phase A results are evaluated by an adversarial judge (`quality_evaluator.py`) that checks for:
- Trivial proofs (commutativity, wrapper theorems, simp-only)
- Missing definitions or insight
- Shallow results that don't advance the research frontier
- Lint-level correctness of generated artifacts

The judge returns a numeric score and a verdict. Low-scoring results are either salvaged (best theorems extracted) or discarded; high-scoring results proceed to Phase B packaging.

## GitHub Pages

The website is served from the `docs/` directory on the `master` branch (branch-based deployment, no Actions minutes). After each tick, `docs/` is synced from `Packages/`.

GitHub Pages settings: **Source → Deploy from a branch → master → /docs**

## The `catalog-lean` Branch

`catalog-lean` is a generated branch containing only the `.lean` files from `Catalog/` plus the root `README.md`. It gives GitHub and lean tools a clean, dependency-free view of all formalized theorems without build artifacts, HTML, JSON, or media.

The branch is rebuilt automatically by the pre-commit hook and pushed by the post-commit hook. If `origin/catalog-lean` was updated elsewhere, the hooks fetch the remote tip before pushing, and fall back to `--force` only as a last resort for this fully machine-generated branch.

To install or refresh the hooks:

```bash
bash Aether/.aether_workspace/git-hooks/install-hooks.sh
```

## Logging

All Aether output can be logged to a file with the `--log` flag. The `Tee` class duplicates `stdout` and `stderr` to the log file in line-buffered append mode, so output streams in real time while also being persisted to disk.

```bash
# Log to aether.log (relative to the Aether directory)
python3 aether_tick.py --loop --log .aether_workspace/aether.log

# Log to an absolute path
python3 aether_tick.py --loop --log /var/log/aether.log

# Tail the log live
tail -f .aether_workspace/aether.log
```

The log file includes every `[Tick]`, `[Poll]`, `[Dispatch]`, `[Evaluate]`, and `[Integrate]` message. To rotate or truncate the log, simply overwrite the file — the Tee writer opens in append mode and will keep writing.

## Backfilling the Aristotle Archive

`Aether/backfill_aristotle_archive.py` downloads every historical Aristotle project (input and result archives) and stores them in a local content-addressable archive under `Archive/`. This is useful when you want a local copy of every past project for offline analysis, catalog rebuilds, or theorem mining.

```bash
cd Aether
python3 backfill_aristotle_archive.py \
  --archive-root ../Archive \
  --log .aether_workspace/backfill_aristotle_archive.log
```

The backfill is **idempotent** — re-running it skips projects already present in `Archive/catalog.sqlite` and only fetches missing output archives.

| Flag | Default | Description |
|------|---------|-------------|
| `--archive-root PATH` | `../Archive` | Where the local archive (blobs + SQLite catalog) is stored |
| `--max-pages N` | unlimited | Stop after N API listing pages |
| `--page-size N` | 100 | Projects per API listing page |
| `--from-local-projects` | off | Archive from `.aether_workspace/projects` instead of the API |
| `--projects-root PATH` | `./.aether_workspace/projects` | Local project root for `--from-local-projects` |
| `--no-api` | off | Skip the API entirely |
| `--log PATH` | off | Persist output to a log file (still prints to stdout) |
| `--summary-every N` | 25 | Print a progress summary every N projects |
| `--max-memory-mb N` | 6000 | Cap process virtual memory so an OOM in the script raises `MemoryError` instead of killing the WSL2 VM |
| `--download-timeout N` | 600 | Seconds to wait while streaming a single project archive |
| `--extract-packages` | on | Store any `PACKAGE.json` found in project output |
| `--no-extract-packages` | off | Disable package extraction |
| `--extract-theorem-metadata` | on | Store rich theorem metadata (docstrings, statements, proofs) |
| `--no-extract-theorem-metadata` | off | Disable theorem metadata extraction |
| `--reprocess-existing` | off | Re-scan already-archived projects for packages/theorems |

### Memory-safe backfill on small VMs

If your machine has ≤8 GB RAM, run the backfill with a lower memory cap. The script uses streaming downloads, removes the unbounded theorem de-duplication cache, and forces garbage collection between projects to keep RSS low. If RSS still climbs, the `--max-memory-mb` cap causes a contained `MemoryError` rather than an OOM kill of the whole WSL2 VM.

Recommended settings:

```bash
cd Aether
python3 backfill_aristotle_archive.py \
  --archive-root ../Archive \
  --max-memory-mb 5500 \
  --download-timeout 600 \
  --log .aether_workspace/backfill_aristotle_archive.log
```

Then tail the log:

```bash
tail -f .aether_workspace/backfill_aristotle_archive.log
```

### Split archive: SQLite on WSL local disk, blobs on `E:`

The archive can grow to several gigabytes. The recommended layout keeps the SQLite catalog and manifests on WSL’s fast `ext4` disk while putting the content-addressable `blobs/` tree on a larger drive like `E:`:

```bash
# 1. Stop any running backfill/reprocess.
# 2. Create a local directory for the DB + manifests.
mkdir -p /home/raver1975/lean/Aether/.aether_workspace/archive_db

# 3. Move catalog.sqlite and manifests/ there.
mv /home/raver1975/lean/Archive/catalog.sqlite \
   /home/raver1975/lean/Archive/catalog.sqlite-* \
   /home/raver1975/lean/Aether/.aether_workspace/archive_db/
mv /home/raver1975/lean/Archive/manifests \
   /home/raver1975/lean/Aether/.aether_workspace/archive_db/

# 4. Leave the blobs tree on E: for space.
mkdir -p /mnt/e/AetherArchive/blobs
mv /home/raver1975/lean/Archive/blobs/* /mnt/e/AetherArchive/blobs/ 2>/dev/null || true

# 5. Repoint the Archive symlink and add a blobs symlink inside.
rm -f /home/raver1975/lean/Archive
ln -s /home/raver1975/lean/Aether/.aether_workspace/archive_db /home/raver1975/lean/Archive
ln -s /mnt/e/AetherArchive/blobs /home/raver1975/lean/Archive/blobs
```

Verify:

```bash
ls -la /home/raver1975/lean/Archive
cd Aether && python3 -c "
from archive_manager import ArchiveManager
from pathlib import Path
am = ArchiveManager(
    Path('/home/raver1975/lean/Aether/.aether_workspace/archive_db'),
    blobs_root=Path('/mnt/e/AetherArchive/blobs')
)
print(am.get_stats())
"
```

Backfill automatically detects the split via symlinks. If you use a non-standard layout, pass `--blobs-root`:

```bash
cd Aether
python3 backfill_aristotle_archive.py \
  --archive-root /home/raver1975/lean/Aether/.aether_workspace/archive_db \
  --blobs-root /mnt/e/AetherArchive/blobs \
  --max-memory-mb 5500
```

**Note:** The WSL2 virtual disk file (`ext4.vhdx`) on `C:` does not automatically shrink after files are deleted. To reclaim space on `C:`, shut down WSL2 and compact the VHDX from PowerShell (admin):

```powershell
wsl --shutdown
# Find your ext4.vhdx under %LOCALAPPDATA%\Packages\CanonicalGroupLimited...\LocalState\
# Compact it (Windows Pro / Hyper-V):
optimize-vhd -Path "C:\Users\paulk\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_...\LocalState\ext4.vhdx" -Mode Full
```

### WSL2 tuning

If the VM still dies from memory pressure, add this to `%UserProfile%\.wslconfig` on Windows and then run `wsl --shutdown`:

```ini
[wsl2]
memory=6GB
processors=4
swap=8GB
swapFile=C:\Users\<your-username>\wsl-swap.vhdx
```

Inside WSL you can also add a swap file:

```bash
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Package and theorem metadata extraction

The backfill now stores two additional things in `Archive/catalog.sqlite`:

1. **Research packages** — any `PACKAGE.json` found in a project's output is parsed and stored in the `packages` table.
2. **Rich theorem metadata** — every `.lean` file is scanned into the `theorems` table with docstrings, full statements, proof bodies, line numbers, and `sorry`/`admit` detection.

These are on by default. To disable them:

```bash
cd Aether
python3 backfill_aristotle_archive.py \
  --no-extract-packages \
  --no-extract-theorem-metadata
```

To reprocess already-archived projects without re-downloading (work in progress — currently logs a warning):

```bash
cd Aether
python3 backfill_aristotle_archive.py --reprocess-existing
```

### Packaging a single job

`Aether/package_single_job.py` turns one Aristotle project into a research package:

```bash
cd Aether
python3 package_single_job.py df33b02b \
  --archive-root ../Archive \
  --output ../Archive/packages/df33b02b.package.json
```

If the project already has a `PACKAGE.json`, that is stored. Otherwise a minimal package is built from the project's Lean files, Python demos/algorithms, and markdown artifacts.

### Interactive planning guide

`Aether/planning_guide.py` asks a few questions and produces a ready-to-run command or shell script:

```bash
cd Aether && python3 planning_guide.py
```

It detects RAM, suggests a `--max-memory-mb` cap, asks whether to reprocess the existing archive, and writes the plan to `.aether_workspace/run_plan.sh`.

### Quality improvement questionnaire

`Aether/quality_plan_questionnaire.html` is an interactive browser questionnaire for prioritizing improvements to Aether's scientific process. Answer sliders and checkboxes about pain points, proof quality, discovery strategy, and implementation appetite, then click **Generate Plan** to produce a Markdown action plan with quick wins, major projects, and a prioritized action list.

```bash
cd Aether && python3 quality_plan_questionnaire.py
```

The launcher starts a local server at `http://127.0.0.1:8765` and opens the questionnaire in your default browser. The generated plan can be copied as Markdown or downloaded as `aether_quality_plan_YYYY-MM-DD.md`.

### Querying the archived theorem database

Once the backfill has run, you can inspect the deduplicated theorem index:

```bash
cd Aether
python3 -c "
import sys
sys.path.insert(0, '.')
from archive_manager import ArchiveManager
from pathlib import Path
am = ArchiveManager(Path('../Archive'))
conn = am._connect()
print('Theorems by domain:')
for row in conn.execute('SELECT domain, COUNT(*) FROM theorems GROUP BY domain ORDER BY COUNT(*) DESC'):
    print(' ', row['domain'], row['COUNT(*)'])
print('Packages stored:', am.get_stats().get('packages'))
"
```

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