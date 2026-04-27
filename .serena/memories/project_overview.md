# Aether v3: Pi-Agent Centered Research Engine

## Architecture
- **pi_orchestrator.py** — Central 10-phase orchestrator (replaces cycle_master.py)
- **pi_agent_client.py** — LLM brain using glm-5.1:cloud via ollama HTTP API (replaces v2 client)
- **catalog_analyzer.py** — Scans 2,721 .lean files, selects @ references for Aristotle prompts
- **output_organizer.py** — Professional artifact routing (Papers/, Demos/, Visuals/, Articles/) (replaces smart_integrator.py)
- **autoresearch_bridge.py** — Python interface to pi-autoresearch optimization loop
- **git_automator.py** — Extracted GitAutomator for reuse
- **aristotle_sdk_client.py** — Kept from v2 (proven stable)
- **lean_catalog_builder.py** — Kept from v2
- **research_memory.py** — Kept from v2

## Key v3 Principles
1. Pi-Agent is THE brain — all decisions go through it (domain, concept, prompt, quality, placement)
2. Dynamic prompt writing — no templates, Pi-Agent writes full Aristotle research briefs
3. Research modes: prove, formalize, counterexample, sorry_fill
4. @ file references — key Catalog files included as context in Aristotle prompts
5. Professional output routing — theorems to domains, papers to Papers/, demos to Demos/, etc.
6. ollama HTTP API (httpx) instead of subprocess CLI
7. Model: glm-5.1:cloud

## Catalog Stats
- 13 domains, 2,721 .lean files, 45,887 declarations, 382 sorries remaining

## v2 Files Still Present (not yet removed)
- cycle_master.py, prompt_engine.py, smart_integrator.py — replaced by v3 equivalents
- engine.py, daemon.py, generator.py, integrator.py, miner.py — v1/v2 legacy