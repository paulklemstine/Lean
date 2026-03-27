# The Algorithmic Universal Oracle

## Overview

A comprehensive mathematical investigation of idempotent projections as the fundamental calculus of definite knowledge. The single equation **O(O(x)) = O(x)** unifies fixed-point theory, SAT solving, neural networks, compression, strange loops, and quantum measurement.

## Contents

### Lean 4 Formalization (0 sorries)
- **`AlgorithmicUniversalOracle.lean`** — Machine-verified proofs of 20+ theorems:
  - Master Equation: image(O) = Fix(O)
  - ReLU idempotency (tropical oracle)
  - Meta-oracle collapse theorem
  - Oracle composition (commuting case)
  - Projection matrix fixed-point theorem
  - Strange loop structure theorems
  - Zero-contraction on range
  - And more

### Research Papers
- **`RESEARCH_PAPER.md`** — Full academic paper with 12 sections
- **`SCIENTIFIC_AMERICAN_ARTICLE.md`** — Popular science article

### Python Demonstrations
- **`python/oracle_demos.py`** — 9 interactive demonstrations:
  1. Idempotent projections (floor, mod, clamp, GCD)
  2. Oracle hierarchy and meta-oracle collapse
  3. Kolmogorov oracle (compression as information oracle)
  4. Fixed-point iteration convergence
  5. Strange loop detector (Collatz, quines, Gödel)
  6. SAT phase transition as oracle phenomenon
  7. Tropical oracle (ReLU, neural networks)
  8. The Crystallizer (any function → oracle)
  9. Experimental hypothesis testing

- **`python/universal_sat_solver.py`** — Complete CDCL SAT solver:
  - Unit propagation, conflict analysis, VSIDS, Luby restarts
  - Solves N-Queens, graph coloring, pigeonhole principle
  - Handles random 3-SAT at the phase transition
  - Each component is an idempotent oracle projection

## Quick Start

```bash
# Run SAT solver demos
python3 UniversalOracle/python/universal_sat_solver.py

# Run oracle demos (all 9)
python3 UniversalOracle/python/oracle_demos.py

# Run specific demo (1-9)
python3 UniversalOracle/python/oracle_demos.py 7

# Verify Lean proofs
lake build UniversalOracle
```
