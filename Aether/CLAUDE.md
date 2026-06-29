# Aether — Autonomous Research System

## Architecture

Aether is an autonomous mathematical research system that cycles through discovery, formalization, and knowledge accumulation. Each cycle:

1. **Discover** — `knowledge_extractor.discover()` pops a weighted-random future direction (with inverse-frequency domain balancing), builds a `ResearchConcept`, and creates a `ResearchJob`
2. **Execute** — Aristotle (via `pi_agent_client`) receives the concept and produces Lean 4 proofs, articles, research papers, demos, and FUTURE_DIRECTIONS.md
3. **Integrate** — `knowledge_extractor.run_single_cycle()` unpacks artifacts into the Catalog, extracts new future directions, and marks the consumed direction as completed
4. **Repeat** — The next cycle picks up newly seeded directions

## Key Files

| File | Purpose |
|------|---------|
| `research_memory.py` | `FutureDirectionsManager` — tracks research directions (available/in_progress/completed/pruned), dedup, domain decay, anti-repetition, inverse-frequency balancing |
| `seed_directions.py` | `get_seed_directions()` — 201 seed directions including 97 novelty-tagged directions |
| `pi_agent_client.py` | `PiAgentClient.write_aristotle_prompt()` — builds the research prompt; `ResearchConcept` dataclass |
| `knowledge_extractor.py` | `KnowledgeExtractor` — orchestrates the full cycle: discover → execute → integrate → update lineage |
| `lineage_extractor.py` | Builds the knowledge graph (provenance edges only, no heuristic edges) |
| `catalog_analyzer.py` | Analyzes existing Catalog theorems for context |
| `output_organizer.py` | `normalize_domain()` — maps domain names to Catalog directories; `DOMAIN_DIRS` — valid domain list |
| `aristotle_loop.py` | UCB-based domain selection, cross-domain synergy tracking, diminishing returns detection |
| `aether_tick.py` | Main tick loop: poll → integrate → dispatch → rebuild website → commit → push |

## TDD Policy

**All changes to the Future Directions system MUST follow test-driven development:**

1. Write or update tests in `tests/test_future_directions.py` FIRST
2. Run `pytest tests/test_future_directions.py -v` to see them fail
3. Implement the change in `research_memory.py` (or relevant module)
4. Run tests again to confirm they pass

Run the full test suite with:
```bash
pytest tests/test_future_directions.py -v
```

## Domain System

### Valid Domains (DOMAIN_DIRS)

`Algebra`, `Applications`, `Bridges`, `Computation`, `Cryptography`, `EML`, `Geometry`, `Logic`, `MachineLearning`, `Novelty`, `Physics`, `Pythagorean`, `Shared`, `Tropical`

Novelty is a first-class domain for wild/exploratory directions. Speculative is **not** a valid Catalog domain — sub-domains like TDA, Arithmetic Geometry, etc. map to real domains via `normalize_domain()`.

### Domain Normalization

`output_organizer.normalize_domain()` maps ~90 domain name variants (including sub-domains like "Arithmetic Geometry"→"Algebra", "TDA"→"Computation", "Novelty"→"Novelty") to the 14 valid Catalog directories. Any unrecognized domain falls through to "Speculative" as a last resort, but most known sub-domains are now mapped.

### Domain Routing

`discover()` uses the **Aristotle loop's domain selection** (UCB-based), not the future direction's `domains[0]`. The direction provides the concept idea; the loop provides the domain target. This prevents Pythagorean (56% of directions' `domains[0]`) from dominating dispatch.

### Inverse-Frequency Domain Balancing

`select_direction_weighted()` applies inverse-frequency weighting:
- Domains occupying >30% of the available pool are penalized: `weight *= (1 - fraction)`
- Domains occupying <10% get a boost: `weight *= (1 + fraction)`

## Future Directions System

### Data Model

Each `FutureDirection` has:
- `id`, `title`, `description` — identity and content
- `source_exp_id`, `source_path` — provenance (where it came from)
- `domains` — tag list, **capped at 2** per direction (auto-inferred if not set)
- `priority_score` — 0.0–1.0, higher = popped first
- `status` — `available` | `in_progress` | `completed` | `pruned`
- `consumed_by_exp_id` — experiment that claimed this direction
- `timestamp` — set automatically on add

### Quality Scoring and Anti-Bias

- **Domain decay**: `0.25^min(1, (count-1)/6)` for overrepresented domains
- **First-time domain bonus**: +0.15 for domains with ≤2 completions
- **Anti-repetition penalty**: -0.03 per keyword appearing 3+ times in recent completions (capped at -0.15)
- **Auto-title cap**: Directions starting with "Direction N:" are capped at priority 0.60
- **Quality cap on creation**: `priority_score = min(priority_score, max(0.60, quality_score))`
- **Novelty protection**: Cleanup and auto-pruning skip directions tagged with "Novelty"
- **Seed protection**: Auto-pruning never removes seed directions
- **Conservative LLM pruning**: Reviews only bottom 30% by quality, requires justification for each removal, protects priority >= 0.80

### Novelty Track

- 2 dispatch slots reserved for Novelty-tagged directions by default (`--novelty-slots 2`)
- Auto-refill from `seed_directions.py` when <5 Novelty directions are available
- Novelty-tagged directions are protected from LLM cleanup pruning

### Lifecycle

```
available → in_progress (mark_direction_consumed) → completed (mark_direction_completed)
                                                         ↘ pruned (LLM cleanup or auto-prune)
```

### Reset/Reseed

```bash
python research_memory.py reset    # Abandon in-progress, seed with directions
python research_memory.py stats    # Show counts by status
```

## Aristotle Prompt

The research prompt has multiple versions, dispatched via A/B/C split:
- **v6 (40%)**: Correctness-first — brief plan, prove theorems, anti-patterns, novelty check
- **v7 (30%)**: Structured output — theorem declarations before code, completeness gate (proved/conjecture/proved_with_lemma_sorry)
- **v8 (30%)**: Research team framing — 5 roles (Hypothesizer, Experimenter, Analyst, Critic, Synthesist), scientific method loop, Lab Notebook blocks, structured FUTURE_DIRECTIONS.md, disproofs count as results

### v8 Research Team Protocol (key innovations)
- **5 roles**: Hypothesizer (bold conjectures), Experimenter (prove/disprove), Analyst (what survived/failed), Critic (find weaknesses, counterexamples), Synthesist (knowledge base upgrade)
- **Scientific method loop**: Hypothesize → Experiment → Analyze → Critique → Generalize → Iterate
- **Theorem declarations**: Name, Statement, Status (hypothesis/conjecture/proved/proved_with_lemma_sorry/disproved), Why it matters
- **Lab Notebook**: Required `-- !-- Lab Notebook -- !--` blocks in each .lean file with Hypothesis, Result, Insight, Failure analysis
- **Structured FUTURE_DIRECTIONS.md** (MANDATORY): ## Synthesis (2-3 paragraphs), ## Results Summary (bullet list: name, status, significance), Research Directions with Hypothesis/Test/Why now/**If true**/**If false**. Missing sections = incomplete output.
- **Critic step**: Mandatory — find weakest assumption, boundary case, conjecture for generalization
- **Disproofs count**: Finding a counterexample is as valuable as a proof
- **v8 Metrics tracking**: Lab_Notebooks, hypotheses, disproved_theorems (regex), disproved_keywords (loose), Synthesis/Results_Summary/If_true compliance, Critic_refs, LN_Insights, LN_Failures

All versions share:
- **Anti-Triviality Rules**: Rejects commutativity proofs, wrapper theorems, simp-only proofs, definitions without insight
- **No cross-domain mandate**: Removed — the LLM naturally connects domains when relevant
- **No Speculative in classification**: Classification uses 14 real domains including Novelty
- **No FILE RICHNESS MANDATE**: Removed line-count incentives that caused bloat
- **Novelty from direction metrics**: `novelty_estimate` comes from `priority_score`, not hardcoded 0.85

### Removed Biases

The following biases were removed:
- Hardcoded cross-domain examples ("number theory + tropical geometry, algebra + physics") that steered every cycle toward tropical/physics
- "Bridge" anti-triviality rule that penalized cross-domain theorems
- Speculative as a Catalog domain (now maps to real domains via `normalize_domain()`)
- FILE RICHNESS MANDATE that incentivized 500+ lines and 20+ theorems per file
- Hardcoded `novelty_estimate=0.85` that told the LLM every direction was highly novel
- Duplicate Depth Requirements and Anti-Triviality Rules (appeared twice in the prompt)

## Running the Research Loop

### Local loop (no GitHub Actions minutes)

```bash
cd Aether && python3 aether_tick.py --loop --ollama-cloud --max-inflight 9 --novelty-slots 2 --interval 1800 --serve
```

This is the standard startup command. It runs continuously: each tick polls for completed jobs, integrates them, dispatches new ones, rebuilds the website (`update_index.py`), syncs to `docs/`, commits, and pushes to git. The `--serve` flag starts a local docs HTTP server at `http://localhost:8000`.

Other flags:
- `--max-inflight N` — max concurrent Aristotle jobs (default 9)
- `--novelty-slots N` — dispatch slots reserved for Novelty directions (default 3)
- `--interval SECONDS` — sleep between ticks (default 21600 = 6h)
- `--serve` — start local docs server alongside Aether
- `--serve-port PORT` — docs server port (default 8000)
- Single run (no loop): `python3 aether_tick.py --ollama-cloud`

### Oracle Cloud Free Tier Deployment

ARM Ampere A1 instance with 1 OCPU, 6 GB RAM, Ubuntu 22.04:
1. Create VM on Oracle Cloud dashboard (Compute → Instances → Create Instance)
2. SSH in, install Python/git/dependencies
3. Clone repo, set up venv, install requirements
4. Configure `.env` with API keys (ARISTOTLE_API_KEY, POLLINATIONS_API_KEY)
5. Set up systemd service for continuous operation
6. Transfer existing workspace data if migrating from local

### GitHub Pages

The website is served from the `docs/` directory on the `master` branch (branch-based deployment, no Actions minutes). After each tick, `docs/` is synced from `Packages/`. Ensure GitHub Pages settings are configured: **Source → Deploy from a branch → master → /docs**.

## Code Conventions

- Python 3.10+ with type hints
- Dataclasses for structured data
- JSON file persistence in `.aether_workspace/`
- Domain inference uses keyword matching against a known domain list, capped at 2 domains per direction
- Dedup by title exact match OR description word overlap > 0.7
- UCB bandit for domain selection in AristotleLoop (no hardcoded priorities)
- Cross-domain synergy learned from data only (no hardcoded KNOWN_SYNERGIES)

## LLM Usage Reduction

A set of levers cut LLM call volume (cost + rate-limit pressure) while keeping
research throughput/quality. Config-gated under `llm_reduction`.

### Per-tick accounting (Phase 0)
`pi_agent.llm_stats` counts every `_call_ollama` dispatch by category
(`eval`/`breakthrough`/`critic`/`critic_tiebreak`/`lint`/`pruning`/`other`) plus
calls avoided by gates/caches (`skipped`). Reset each tick; printed at tick end
as a `[LLM] calls=... | skipped=...` line next to `[State]`. Use it to verify
call reduction against quality drift (quality_score distribution is in the
existing `[Quality]` rolling metrics).

### Levers (v1.0 final state)
- **Static quality gate (Phase 1)** — **REMOVED for v1.0.** The count-based
  gate (`_static_quality_gate`) was proven non-viable: a 461-cycle audit showed
  `sorry_count` was 0 in every sampled cycle (truncated stubs aren't "sorry")
  and `theorem_count` (declaration count) spans all LLM grades, so no
  count-based clear-fail/clear-pass can predict the LLM's rubric. Re-enabling
  would require a new pre-eval signal (e.g. completed-proof ratio) plus fresh
  shadow validation. Use the eval cache (Phase 3) for eval-skip on repeated
  content.
- **Critic skip-gate (Phase 2, `llm_reduction.critic_gate`)** — `off` for v1.0:
  the adversarial critic always runs. (The skip-gate code remains; set
  `enabled` to skip the critic when the structural composite is decisive
  >0.85 or <0.15.)
- **Lint batch gate (Phase 2, `llm_reduction.lint_gate`)** — `enabled`: skips
  the `_review_file_batch` LLM review when every file in the batch is a
  non-empty `.lean` with a `theorem`/`lemma` declaration (auto-accept).
- **Content-hash eval cache (Phase 3, `llm_reduction.eval_cache`)** — `on`:
  `eval_cache.EvalCache` (`eval_cache.json`) keyed by
  `sha256(result_lean + concept identity + prompt_version)`. On a hit (TTL 7
  days, cap 5000 entries) the full eval (LLM + critic) is restored and skipped.
- **Pruning rules-first (Phase 4, `llm_reduction.pruning_rules`)** — `on`:
  `KnowledgeExtractor._rule_prunable` auto-prunes very-low-quality directions
  (<0.20 + empty/junk description + unprotected), shrinking the LLM review
  batch in `_cleanup_future_directions`.

### Note
The standalone `shadow_watch.py` monitor and its session cron were removed for
v1.0 (the only remaining shadow candidate, `critic_gate`, was set to `off`).
The `[LLM]` line proves call reduction; `[Quality]` proves performance held.