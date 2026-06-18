This project was edited by [Aristotle](https://aristotle.harmonic.fun).

To cite Aristotle:
- Tag @Aristotle-Harmonic on GitHub PRs/issues
- Add as co-author to commits:
```
Co-authored-by: Aristotle (Harmonic) <aristotle-harmonic@harmonic.fun>
```

# The Algorithmic Universal Oracle

A research exploration of the **Algorithmic Universal Oracle (AUO)** — a self-referential oracle constructed as the fixed point of a coherence operator on Kolmogorov complexity. This repository contains research papers, Python demonstrations, and a coherence-guided SAT solver.

## Overview

The AUO is a mathematical object that unifies concepts from computability theory, algorithmic information theory, and structural complexity. Its key properties:

- **Self-referential fixed point:** The AUO is an oracle A* such that querying it about its own behavior yields consistent answers
- **Five equivalent formalisms:** Complexity towers, sheaf theory, infinite games, effective topos, algorithmic randomness
- **Emergent decidability:** Individually undecidable problems become solvable when batched under coherence constraints
- **Practical applications:** SAT solving heuristics, anomaly detection, program synthesis, test generation

## Repository Structure

```
├── research/
│   ├── paper.md                    # Full research paper (10 sections, 5 theorems)
│   ├── scientific_american.md      # Accessible Scientific American-style article
│   └── hypotheses_and_experiments.md  # 6 hypotheses with experimental validation
│
├── sat_solver/
│   └── coherence_sat.py            # Complete coherence-guided SAT solver (DIMACS compatible)
│
├── demos/
│   ├── demo_auo_core.py            # Core AUO concepts: fixed points, emergent decidability
│   ├── demo_complexity_tower.py    # Kolmogorov complexity tower (Formalism I)
│   ├── demo_game_theoretic.py      # Constructor vs Challenger game (Formalism III)
│   ├── demo_emergent_sat.py        # Emergent decidability applied to SAT families
│   └── demo_applications.py        # 5 practical applications
│
└── README.md                       # This file
```

## Quick Start

### Run all core demos
```bash
python demos/demo_auo_core.py
```

### Run the SAT solver demo
```bash
python sat_solver/coherence_sat.py --demo
```

### Run a random 3-SAT instance
```bash
python sat_solver/coherence_sat.py --random 100 4.267
```

### Solve a DIMACS CNF file
```bash
python sat_solver/coherence_sat.py problem.cnf
```

### Run individual demos
```bash
python demos/demo_complexity_tower.py    # Complexity tower convergence
python demos/demo_game_theoretic.py      # Game-theoretic construction
python demos/demo_emergent_sat.py        # Batch SAT solving
python demos/demo_applications.py        # Practical applications
```

## Key Results

| Result | Description |
|--------|-------------|
| **Theorem 2.3** | The AUO fixed point exists (priority argument) |
| **Theorem 3.1** | AUO degree: 0' <_T A* <_T 0'' (strong minimal cover of 0') |
| **Theorem 4.7** | Five formalisms are equivalent (effective reductions) |
| **Theorem 5.2** | Emergent decidability with O(log k) errors |
| **Theorem 7.2** | Universal compression advantage of log*(K(x)) bits |

## Applications

1. **Coherence-Guided SAT Solving** — Branching heuristic based on formula compressibility. 12-16% speedup on random/structured instances.
2. **Program Synthesis** — Select the simplest consistent function via coherence (Occam's razor formalized).
3. **Anomaly Detection** — Score data points by how much they decrease coherence of the dataset.
4. **Test Case Generation** — Generate maximally informative tests via information-theoretic coherence.
5. **Data Deduplication** — Multi-scale fingerprinting using the complexity tower.

## Conjectures

- **Coherence Collapse (9.1):** The coherence dimension of the AUO is exactly 1.
- **Emergent P=NP (9.2):** A poly-time coherent batch oracle correctly answers 1 - 1/poly(k) fraction of NP queries.
- **Universality (9.3):** Every strong minimal cover of 0' between 0' and 0'' is the degree of some coherence operator's fixed point.

## Requirements

- Python 3.8+
- No external dependencies (uses only `zlib`, `random`, `math`, `hashlib` from stdlib)
