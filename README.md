# Lean — Autonomous Mathematical Research System

Aether is an autonomous research system that discovers, formalizes, and accumulates mathematical knowledge. It cycles through discovery (popping future directions), execution (dispatching to Aristotle for Lean 4 proofs, articles, and research papers), and integration (unpacking artifacts into the Catalog and seeding new directions).

## Quick Start

### Run the Research Loop

```bash
cd Aether && python3 aether_tick.py --loop --ollama-cloud --interval 1800
```

This runs continuously — each tick polls for completed jobs, integrates them, dispatches new ones, rebuilds the website, syncs to `docs/`, commits, and pushes to git. Sleeps 30 minutes between ticks.

| Flag | Default | Description |
|------|---------|-------------|
| `--max-inflight N` | 9 | Max concurrent Aristotle jobs |
| `--interval SECONDS` | 21600 | Sleep between ticks (21600 = 6h, 1800 = 30min) |
| `--ollama-cloud` | off | Enable Ollama cloud backend |
| `--loop` | off | Run continuously (single tick otherwise) |

Single run (no loop):
```bash
cd Aether && python3 aether_tick.py --ollama-cloud
```

### View the Knowledge Graph

Open `Catalog/Applications/Packages/index.html` in a browser, or visit the GitHub Pages deployment.

## Architecture

```
Discover → Execute → Integrate → Repeat
   │          │          │
   ▼          ▼          ▼
FutureDirections  Aristotle  Catalog + new directions
```

1. **Discover** — `knowledge_extractor.discover()` pops the highest-priority future direction
2. **Execute** — Aristotle produces Lean 4 proofs, articles, research papers, demos
3. **Integrate** — Artifacts unpacked into Catalog, new future directions extracted
4. **Repeat** — Next cycle picks up newly seeded directions

## Project Structure

| Directory | Purpose |
|-----------|---------|
| `Aether/` | Core research pipeline — discovery, dispatch, evaluation, integration |
| `Catalog/` | Published research packages (JSON) + web visualization |
| `docs/` | GitHub Pages website (synced from `Catalog/Applications/Packages/`) |

## Key Files

| File | Purpose |
|------|---------|
| `Aether/aether_tick.py` | Main pipeline entry point — loop mode, rebuild, commit, push |
| `Aether/knowledge_extractor.py` | Orchestrates the full cycle: discover → execute → integrate |
| `Aether/research_memory.py` | Tracks future directions (available/in_progress/completed/abandoned) |
| `Aether/pi_agent_client.py` | Builds research prompts for Aristotle |
| `Aether/lineage_extractor.py` | Builds knowledge graph (provenance edges) |
| `Catalog/Applications/Packages/update_index.py` | Bundles packages into `packages_db.js`, adds quality scores |

## Knowledge Graph Visualization

The graph is a deep-space physics simulation with:
- Möbius-Klein bottle universe topology (non-orientable wrapping)
- N-body gravitational dynamics with elastic collisions
- Minimum enclosing circles (Welzl's algorithm) per connected component
- Logarithmic time dilation — time slows as you zoom in
- Quality scores from `autoresearch.jsonl` drive node size, brightness, and color
- Standout packages (score >= 0.65) get pulsing gold corona glow
- Directional laser streaks show provenance flow (source → target)
- Sidebar hover zooms into covering circles with node tracking
- Hard edge-crossing constraint — crossing edges are forbidden

## GitHub Pages

The website is served from the `docs/` directory on `master` (branch-based deployment, no Actions minutes used). After each tick, `docs/` is synced from `Catalog/Applications/Packages/`.

GitHub Pages settings: **Source → Deploy from a branch → master → /docs**

## Testing

```bash
cd Aether && pytest tests/test_future_directions.py -v
```

## Reset / Reseed Directions

```bash
cd Aether && python research_memory.py reset   # Abandon in-progress, reseed
cd Aether && python research_memory.py stats   # Show counts by status
```