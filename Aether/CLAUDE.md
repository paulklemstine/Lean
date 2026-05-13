# Aether — Autonomous Research System

## Architecture

Aether is an autonomous mathematical research system that cycles through discovery, formalization, and knowledge accumulation. Each cycle:

1. **Discover** — `knowledge_extractor.discover()` pops the highest-priority future direction, builds a `ResearchConcept`, and creates a `ResearchJob`
2. **Execute** — Aristotle (via `pi_agent_client`) receives the concept and produces Lean 4 proofs, articles, research papers, demos, and FUTURE_DIRECTIONS.md
3. **Integrate** — `knowledge_extractor.run_single_cycle()` unpacks artifacts into the Catalog, extracts new future directions, and marks the consumed direction as completed
4. **Repeat** — The next cycle picks up newly seeded directions

## Key Files

| File | Purpose |
|------|---------|
| `research_memory.py` | `FutureDirectionsManager` — tracks research directions (available/in_progress/completed/abandoned), dedup, persistence |
| `seed_directions.py` | `get_seed_directions()` — 22 seed directions covering millennial problems, computation, AI/ML, tropical math, cryptography, and speculative topics |
| `pi_agent_client.py` | `PiAgentClient.write_aristotle_prompt()` — builds the research prompt; `ResearchConcept` dataclass |
| `knowledge_extractor.py` | `KnowledgeExtractor` — orchestrates the full cycle: discover → execute → integrate → update lineage |
| `lineage_extractor.py` | Builds the knowledge graph (provenance edges only, no heuristic edges) |
| `catalog_analyzer.py` | Analyzes existing Catalog theorems for context |

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

## Future Directions System

### Data Model

Each `FutureDirection` has:
- `id`, `title`, `description` — identity and content
- `source_exp_id`, `source_path` — provenance (where it came from)
- `domains` — tag list (auto-inferred from description if not set)
- `priority_score` — 0.0–1.0, higher = popped first
- `status` — `available` | `in_progress` | `completed` | `abandoned`
- `consumed_by_exp_id` — experiment that claimed this direction
- `timestamp` — set automatically on add

### Lifecycle

```
available → in_progress (mark_direction_consumed) → completed (mark_direction_completed)
                                                         ↘ abandoned (mark_direction_abandoned)
```

### Reset/Reseed

```bash
python research_memory.py reset    # Abandon in-progress, seed with 22 directions
python research_memory.py stats    # Show counts by status
```

## Code Conventions

- Python 3.10+ with type hints
- Dataclasses for structured data
- JSON file persistence in `.aether_workspace/`
- Domain inference uses keyword matching against a known domain list
- Dedup by title exact match OR description word overlap > 0.7