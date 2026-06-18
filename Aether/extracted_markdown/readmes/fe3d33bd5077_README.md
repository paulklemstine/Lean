# 🩺 AutoHeal — Self-Healing Software Library

**AutoHeal** embeds an AI-powered tail watcher into your Python application. It monitors log output in real-time, detects errors, generates source-code patches, recompiles, and hot-swaps live fixes — all without restarting your process.

```
The tail watches the head. When the head breaks, the tail fixes it.
```

## Quick Start

```python
import autoheal

healer = autoheal.AutoHealer("myapp.log", watch_dir="src/")
healer.start()
# ... your app runs normally ...
# When an error is logged, AutoHeal detects, patches, recompiles, and hot-swaps the fix.
healer.stop()
```

## Architecture

```
┌─────────────┐        ┌──────────────┐
│  Parent App  │──log──▶│  TailWatcher │
│  (the head)  │        │  (the tail)  │
└──────┬──────┘        └──────┬───────┘
       │                      │
       │  hot-swap            │ diagnose
       │◀─────────────────────┤
       │                      │
┌──────┴──────┐        ┌──────┴───────┐
│  ModuleSlot  │◀──────│  CodeSurgeon │
│  (live code) │ patch │  (AI fixer)  │
└─────────────┘        └──────────────┘
```

## Components

| Component | File | Purpose |
|-----------|------|---------|
| **TailWatcher** | `core/tail_watcher.py` | Async log-file tail with rotation detection |
| **Diagnostician** | `core/diagnostician.py` | Pattern-matching + AI error classifier |
| **CodeSurgeon** | `core/code_surgeon.py` | Patch generation (heuristic + Oracle) |
| **Compiler** | `core/compiler.py` | `py_compile` + `importlib.reload()` |
| **HotSwapper** | `core/hot_swapper.py` | In-place `__code__` replacement |
| **Oracle** | `core/oracle.py` | Single AI reasoning unit |
| **OracleTeam** | `core/oracle.py` | 6-oracle council (research → iterate) |
| **AutoHealer** | `core/auto_healer.py` | Top-level façade |

## Demos

```bash
python -m autoheal.demos.demo_basic          # Basic self-healing loop
python -m autoheal.demos.demo_hot_swap       # Live hot-swap in action
python -m autoheal.demos.demo_oracle_team    # Oracle council deliberation
python -m autoheal.demos.demo_full_pipeline  # Full end-to-end pipeline
```

## Visuals

```bash
python -m autoheal.visuals.generate_diagrams  # Generate architecture diagrams
```

## Tests

```bash
python -m pytest autoheal/tests/test_core.py -v
```

## Research

- [Oracle Team Research Notes](research/oracle_notes.md) — Detailed notes from the oracle council
- [Research Paper](research/research_paper.md) — Academic paper on the architecture
- [Scientific American Article](research/scientific_american_article.md) — Popular science writeup

## Oracle Team Roles

| Role | Purpose |
|------|---------|
| 🔬 **Researcher** | Gathers context, reads code, understands the domain |
| 🧠 **Hypothesizer** | Proposes ranked root-cause hypotheses |
| 🧪 **Experimenter** | Designs minimal experiments to test hypotheses |
| ✅ **Validator** | Checks correctness, safety, minimality |
| 🔄 **Updater** | Merges validated fixes into source |
| 🔁 **Iterator** | Decides: CONVERGED or RETRY |

## Safety

- **AST Gate** — patches must pass `ast.parse()` before application
- **Backup** — originals saved to `.autoheal.bak` before any write
- **Cooldown** — prevents infinite heal loops (configurable per-file timer)
- **Scope Limit** — only files within `watch_dir` may be modified
- **Rollback** — `HotSwapper.rollback()` undoes recent swaps

## Requirements

- Python 3.9+
- No external dependencies for core library
- Optional: `matplotlib` for visual diagram generation
- Optional: AI backend (any `(str) -> str` callable) for Oracle features
