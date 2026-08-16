# AETHER v1.0

**Automated Epic Theorem Hypothesis Engine & Research**

AETHER is an autonomous mathematical research system that:
1. **Discovers** a research direction (weighted-random from the future-directions pool, with inverse-frequency domain balancing)
2. **Dispatches** a structured proof request to Aristotle (Harmonic's verified reasoning agent)
3. **Integrates** successful Lean 4 proofs back into the Catalog
4. **Packages** results into a publication-ready article, paper, demo, and widgets (Phase B)
5. **Repeats** — each cycle seeds new future directions from the results

---

## Quick Start

Aether runs from the `Aether/` directory. It needs API keys in a `.env` file (see `.env.example`): at minimum `ARISTOTLE_API_KEY`. An LLM tier key (`OLLAMA_API_KEY` and/or `OPENROUTER_API_KEY`) is used for Pi-Agent concept generation and evaluation.

```bash
cd Aether/
cp .env.example .env        # then fill in your keys
pip install -r requirements.txt

# Continuous loop: poll → integrate → dispatch → rebuild website → commit → push
python3 aether_tick.py --loop --ollama-cloud --max-inflight 6 --novelty-slots 2 --interval 900 --serve

# Single one-shot tick (no loop):
python3 aether_tick.py --ollama-cloud
```

Flags:
- `--max-inflight N` — max concurrent Aristotle jobs (default 6; **do not exceed 6** or Aristotle may hang jobs)
- `--novelty-slots N` — dispatch slots reserved for Novelty directions (default 3)
- `--interval SECONDS` — sleep between ticks in `--loop` mode (default 21600)
- `--ollama-cloud` — enable the Ollama Cloud LLM tier
- `--serve` — start a local docs HTTP server at `http://localhost:8000`
- `--serve-port PORT` — docs server port (default 8000)

Tests: `pip install -r requirements-dev.txt && pytest`

---

## Architecture

```
AETHER/
├── aether_tick.py         # Main tick loop: poll → integrate → dispatch → website → git
├── knowledge_extractor.py # Orchestrates discover → execute → integrate; Phase B promotion gate
├── pi_agent_client.py     # Pi-Agent: writes Aristotle prompts; LLM 2-tier fallback (Ollama Cloud → OpenRouter)
├── research_memory.py     # FutureDirectionsManager: available/in_progress/completed/pruned, dedup, domain decay
├── aristotle_loop.py      # UCB-based domain selection, cross-domain synergy tracking
├── aristotle_sdk_client.py# Aristotle API client (submit/poll/download)
├── quality_evaluator.py   # Quality scoring + adversarial critic
├── eval_cache.py          # Content-hash eval cache (LLM-reduction lever)
├── output_organizer.py    # normalize_domain(); maps results into Catalog directories
├── catalog_analyzer.py    # Analyzes existing Catalog theorems for context
├── lineage_extractor.py   # Builds the knowledge graph (provenance edges)
├── config.yaml            # Research arcs, API keys, LLM tiers, stall caps, llm_reduction
├── .aether_workspace/     # Runtime state (inflight jobs, future directions, reasoning logs, eval cache)
└── CLAUDE.md              # Full developer documentation
```

Aether expects a sibling Catalog layout (`../Packages/`) for integration and website rebuild.

---

## Research Arcs

AETHER follows 8 core research programs (see `config.yaml` `research.arcs` for the full, growing list):

| Arc | Description | Frontier |
|-----|-------------|----------|
| Gravitational Factoring | Geometric structures for integer factorization | Tropical analogues of gravitational lenses |
| Quantum Pythagoras | Quantum computing on Berggren trees | QDF (Quantum Diophantine Factoring) |
| Tropical Langlands | Tropical geometry meets representation theory | Tropical automorphic forms |
| Neural Proof Mining | ML-guided theorem discovery | RSIL adaptive distillation |
| Temporal Computation | Time-travel logic and reversible computation | OISCC oracle hierarchies |
| EML Cosmology | Emergent meta-language as universe model | Self-pairing in curved spacetime |
| Cryptographic Gravity | Post-quantum crypto via geometric invariants | Lattice reduction in Berggren trees |
| Speculative Sci-Fi | Science-fictional mathematical concepts | Hyperspace, alien computation |

---

## Integration Pipeline

```
AETHER dispatches → Aristotle (Lean 4 proofs, FUTURE_DIRECTIONS.md)
                       ↓
   knowledge_extractor integrates → Catalog/{domain}/{Package}/
                       ↓
   Phase B (top ~30% by quality) → ARTICLE.md, RESEARCH_PAPER.md, demo, widgets, PACKAGE.json
                       ↓
   update_index.py rebuilds website → docs/ synced → git commit & push
                       ↓
   Next cycle: newly-seeded future directions are picked up
```

This creates a **closed loop** of autonomous mathematical discovery. Phase B articles are written as standalone, publication-ready prose (no references to Lean, the Catalog, or formal-proof identifiers).

---

## LLM Usage Reduction

To cut API cost and rate-limit pressure without losing research throughput, the tick loop applies call-reduction levers, config-gated under `llm_reduction` (v1.0 final state):

- **Critic skip-gate** (`critic_gate: off`) — the adversarial critic always runs in v1.0.
- **Lint batch gate** (`lint_gate: enabled`) — skip the integration file-review LLM call when every file in the batch is a non-empty `.lean` with a theorem/lemma.
- **Content-hash eval cache** (`eval_cache: on`) — cache the full eval by `sha256(lean + concept + prompt_version)` so retries/duplicates skip re-eval.
- **Pruning rules-first** (`pruning_rules: on`) — auto-prune clearly-worthless directions by rule before the LLM cleanup batch.
- **Static quality gate** — removed for v1.0 (count-based gating was proven non-viable; see `CLAUDE.md`).

A per-tick `[LLM] calls=... | skipped=...` log line reports actual LLM dispatches by category and calls avoided by gates/caches, checkable against the `[Quality]` rolling avg_Q. See `CLAUDE.md` for details.

---

## Stall / Zombie Handling

Dispatched jobs that hang server-side are handled by wall-clock caps in the `stall:` config block: a 24h hard cap (quarantines the direction), a 60-min no-progress zombie cap (returns the direction to available), a 30-min preparing timeout, and a 90-min stall warning. Aristotle exposes no project-cancel API, so these free the local slot and re-queue the direction rather than killing the remote project.

---

## Dependencies

- Python 3.10+
- `httpx`, `requests`, `PyYAML`, `aristotlelib>=2.0.0`, `pydantic` (see `requirements.txt`)
- No Lean toolchain needed — the production tick never compiles Lean (theorem/sorry counts are regex-based; Aristotle compiles remotely and strips build artifacts on upload). `lake` is only used by the legacy verify path in `integrator.py`, which the tick does not call.
- Aristotle API key from Harmonic; an LLM tier key (Ollama Cloud and/or OpenRouter)

---

## Limitations

`aristotle_client.py` (demo mode), `cycle_master.py` (stub theorem), and `generator.py` (complexity-bound TODO) contain placeholder content for legacy/demo paths and are not exercised by the production tick loop.

---

## License

Same as the parent Catalog project.

---

*AETHER v1.0 — autonomous mathematical research.*