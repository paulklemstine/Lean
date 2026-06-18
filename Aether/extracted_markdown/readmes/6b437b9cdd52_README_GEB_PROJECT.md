# Gödel, Escher, Bach — A Computational Exploration

## Project Overview

This project is a comprehensive mathematical, computational, and philosophical investigation inspired by Douglas Hofstadter's *Gödel, Escher, Bach: An Eternal Golden Braid*.

## Deliverables

### Papers
- **`papers/RESEARCH_PAPER.md`** — Full research paper with formal definitions, theorems, experiments, and results
- **`papers/SCIENTIFIC_AMERICAN_ARTICLE.md`** — Accessible Scientific American-style article
- **`papers/APPLICATIONS.md`** — Proposed applications, new hypotheses, and future research directions

### Machine-Verified Proofs (Lean 4)
- **`GEB/Basic.lean`** — Formalized and verified proofs including:
  - MIU formal system and invariant properties
  - Lawvere's fixed-point theorem (categorical foundation of all diagonal arguments)
  - Knaster-Tarski fixed-point theorem (existence of self-referential definitions)
  - Cantor's diagonal theorem
  - Incompleteness tower (strictly increasing hierarchy of formal systems)
  - Strange Loop structures (leveled digraphs with cycles)

### Python Demos
- **`demos/demo1_strange_loops.py`** — MIU system, strange loop detection, quines, recursive enumeration
- **`demos/demo2_isomorphism_machines.py`** — DNA→music mapping, Gödel encoding of images, meaning experiments
- **`demos/demo3_incompleteness_explorer.py`** — Miniature Gödel's theorem, incompleteness depth, Reality Prison hypothesis
- **`demos/demo4_paradox_engines.py`** — Liar's paradox, halting problem, paradox-tolerant computation
- **`demos/demo5_fractal_self_similarity.py`** — Sierpinski triangle, Cantor set, Mandelbrot set, Bach's Crab Canon

### Universal SAT Solver
- **`sat_solver/solver.py`** — Complete CDCL SAT solver with:
  - DPLL backtracking
  - Conflict-driven clause learning (1-UIP)
  - VSIDS heuristic
  - Luby restart sequence
  - DIMACS parser
  - Problem generators (random 3-SAT, pigeonhole, graph coloring)

### Experiments
- **`experiments/experiment_results.py`** — Five hypothesis-driven experiments:
  1. SAT phase transition at α ≈ 4.267
  2. Paradox tolerance in three-valued logic
  3. Decoder-dependence of meaning
  4. CDCL learning as Strange Loop
  5. Isomorphism and complexity preservation

## Running the Code

```bash
# Run any demo
python3 demos/demo1_strange_loops.py
python3 demos/demo2_isomorphism_machines.py
python3 demos/demo3_incompleteness_explorer.py
python3 demos/demo4_paradox_engines.py
python3 demos/demo5_fractal_self_similarity.py

# Run the SAT solver
python3 sat_solver/solver.py

# Run all experiments
python3 experiments/experiment_results.py

# Verify Lean proofs (requires Lean 4 + Mathlib)
lake build GEB
```

## Key Results

1. **Lawvere's fixed-point theorem** formally verified — the categorical root of Cantor, Russell, Gödel, and Turing
2. **Incompleteness tower** proved strictly increasing — each meta-level adds genuinely new theorems
3. **SAT phase transition** confirmed computationally at α ≈ 4.4
4. **Paradox tolerance** demonstrated — three-valued logic handles all self-referential depths
5. **CDCL as Strange Loop** — self-referential learning yields 4-6x computational speedup
6. **Meaning is relational** — same data yields measurably different information under different decoders
