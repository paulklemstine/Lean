# Oracle Bootstrap Frontier: Hypotheses H8–H12

## Overview

This directory investigates five new hypotheses arising from the Oracle Bootstrap framework:

| Hypothesis | Description | Status |
|-----------|-------------|--------|
| **H8** | Bootstrap on neural network weights → lottery ticket | Partially validated |
| **H9** | Convergence basin has fractal Julia set boundary | **Validated** (d ≈ 1.22) |
| **H10** | Meta-bootstrap with adaptive α optimizes convergence | Partially validated |
| **H11** | p-adic bootstrap discovers integer factorizations | **Validated** |
| **H12** | n-potent operators: Pⁿ = P ⟹ spectrum ⊆ {0} ∪ roots of unity | **Validated + Formally verified** |

## Contents

### Lean 4 Formalization
- `../OracleBootstrapFrontier/Main.lean` — 12 formally verified theorems (0 sorry)
  - n-Potent Spectrum Theorem
  - Oracle Spectrum (binary case)
  - Tripotent Spectrum {0, 1, -1}
  - n-Potent Hierarchy (divisibility lattice)
  - Bootstrap Symmetry f(1-x) = 1-f(x)
  - Bootstrap Fixed Points {0, 1/2, 1}
  - Bootstrap Family f_α uniqueness (α = 2)
  - Tripotent Decomposition (e₊, e₋ orthogonal idempotents)

### Python Experiments
- `demos/h8_lottery_ticket.py` — Neural network weight matrix bootstrap
- `demos/h9_oracle_julia_sets.py` — Fractal Julia set computation
- `demos/h10_meta_bootstrap.py` — Adaptive contraction parameter
- `demos/h11_padic_bootstrap.py` — Modular bootstrap and integer factoring
- `demos/h12_npotent_oracles.py` — n-Potent operator hierarchy
- `demos/run_all_experiments.py` — Master runner for all experiments

### Papers
- `ResearchPaper.md` — Full technical research paper
- `ScientificAmerican.md` — Popular science article

## Running

```bash
# Run all experiments
cd demos && python3 run_all_experiments.py

# Run individual experiments
python3 demos/h9_oracle_julia_sets.py
python3 demos/h11_padic_bootstrap.py
python3 demos/h12_npotent_oracles.py
```

## Key Results

1. **Oracle Julia Set** (H9): The map f(z) = 3z² - 2z³ on ℂ creates a connected Julia set with fractal dimension ≈ 1.22 and z↔1-z symmetry
2. **Integer Factoring** (H11): The bootstrap mod n discovers idempotents that reveal prime factorizations via gcd
3. **n-Potent Spectrum** (H12): Pⁿ = P ⟹ eigenvalues are (n-1)-th roots of unity ∪ {0}, with a hierarchy lattice
4. **Tripotent Decomposition** (H12): P³ = P decomposes as P = P₊ - P₋ with orthogonal idempotent components
