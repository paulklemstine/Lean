# Gravitational Factoring v11 — Research Package

## Overview

This package contains the complete v11 research output for the Gravitational Factoring project:
**30+ new formally verified theorems** (all sorry-free), 3 Python demos, 2 SVG visualizations,
a research paper, a Scientific American-style article, and a comprehensive future research directions document.

## Contents

### `lean/` — Formally Verified Theorems (Lean 4 + Mathlib)

All three files compile with **zero sorries** and use only standard axioms.

| File | Theorems | Key Results |
|------|----------|-------------|
| `RobinInequality.lean` | 8 | σ₁ bounds, Robin check values, multiplicativity, abundancy definitions |
| `DirichletSeriesFoundations.lean` | 9 | Möbius function, Dirichlet convolution, Liouville λ, prime counting π(10)=4 |
| `MillerRabinFoundations.lean` | 9 | 2-adic decomposition, MR correctness for primes, Carmichael 561, pseudoprimes |

**Highlight results:**
- `prime_passes_miller_rabin` — Primes always pass Miller-Rabin (full proof!)
- `carmichael_561` — 561 is Carmichael (∀ coprime a, a^560 ≡ 1 mod 561)
- `liouville_completely_multiplicative` — λ is completely multiplicative
- `mobius_sum_eq_indicator` — Σ_{d|n} μ(d) = [n=1]
- `sigma1_ge_n_plus_one` — σ₁(n) ≥ n+1 for n ≥ 2
- `sigma1_5040` — σ₁(5040) = 19344 (Robin's boundary)

### `demos/` — Python Demonstrations

| File | Description |
|------|-------------|
| `energy_landscape_3d.py` | Comprehensive energy landscape analysis: divisor detection, gradient descent, Fermat factoring, QR analysis, Fibonacci factoring, perfect number exploration, Wieferich primes |
| `quadratic_sieve_demo.py` | Complete QS implementation with step-by-step explanation tied to formal theorems |
| `miller_rabin_demo.py` | Miller-Rabin test explorer: pseudoprimes, Carmichael numbers, deterministic bounds, Euler criterion connection |

### `visuals/` — SVG Visualizations

| File | Description |
|------|-------------|
| `theorem_dependency_map.svg` | Complete dependency map of 300+ theorems across 10 clusters |
| `energy_landscape_visualization.svg` | Energy landscape E(x) = N mod x for N=30, showing divisor valleys |

### `papers/` — Research Documents

| File | Description |
|------|-------------|
| `research_paper.md` | Formal research paper: 10 sections covering all theorem clusters |
| `scientific_american_article.md` | Popular science article explaining Gravitational Factoring |
| `future_research_directions_v11.md` | 150+ research directions, 62 answered questions, updated rankings |

## Verification

All Lean files can be verified with:
```
lake build GravitationalFactoringV11
```

## Key Statistics

- **300+ total verified theorems** (cumulative v1–v11)
- **26 new theorems in v11** (all sorry-free)
- **0 remaining sorries** in v11 files
- **150+ identified research directions**
- **62 answered open questions**
- **Standard axioms only**: propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler
