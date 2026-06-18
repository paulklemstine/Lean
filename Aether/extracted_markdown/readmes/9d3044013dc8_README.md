# MetaFactoring: Future Research Directions

## Overview

This directory contains formal explorations, computational demonstrations, and written analyses of the 25 open research directions from the MetaFactoring Phase II roadmap.

## Contents

### Lean 4 Formalizations
- **`OpenDirections.lean`** — 40+ theorems covering 15 of 25 directions (1 sorry remaining)
- **`CrossCollisionTheory.lean`** — Cross-collision probability and factor extraction (sorry-free)
- **`LagrangeFourSquare.lean`** — Lagrange's four-square theorem and quaternionic factoring (sorry-free)

### Python Demonstrations
- **`demos/demo_open_directions.py`** — Interactive demonstrations of 10 research directions
  - Genus dimension gap (Dir 1)
  - Sum-product phenomenon (Dir 3)
  - Information ceiling (Dir 4)
  - Tropical sieve (Dir 5)
  - Pisano-spectral correlation (Dir 7)
  - Hurwitz barrier (Dir 8)
  - Quantum hybrid savings (Dir 9)
  - Pisano complexity (Dir 21)
  - Hasse interval factoring (Dir 24)
  - Universal multi-lens theory (Dir 25)

### SVG Visualizations
- **`visuals/research_roadmap.svg`** — Full 25-direction research roadmap with timeline
- **`visuals/lens_independence.svg`** — Information ceiling and search space reduction
- **`visuals/cayley_dickson_hierarchy.svg`** — Cayley-Dickson hierarchy and Hurwitz barrier

### Research Papers
- **`research_paper_open_directions.md`** — Academic paper with theorems, answers, and priorities
- **`sciam_open_directions.md`** — Scientific American-style article on the frontiers
- **`applications_brainstorm_directions.md`** — 25+ application ideas across 8 categories

### Previously Created
- **`answers_to_open_questions.md`** — Detailed answers to key open questions
- **`future_research_directions.md`** — Extended analysis of all 25 directions
- **`scientific_american_article.md`** — General-audience article
- **`research_paper.md`** — Technical research paper

## Key Results

### Formally Proved (Lean 4)
| Theorem | Direction | Description |
|---------|-----------|-------------|
| `sufficient_lenses` | Dir 4 | ⌈log₂ N⌉ + 1 lenses eliminate all candidates |
| `information_ceiling` | Dir 4 | S/2^k = 0 when 2^k > S |
| `independent_lenses_exp_reduction` | Dir 4 | k lenses give strict reduction |
| `tropical_valuation_additive` | Dir 5 | v_p(ab) = v_p(a) + v_p(b) |
| `genus_dimension_gap` | Dir 1 | p^g₁ < p^g₂ for g₁ < g₂ |
| `hybrid_query_reduction` | Dir 9 | √(N/2^k) ≤ √N |
| `hurwitz_barrier_16` | Dir 8 | 16 ∉ {1, 2, 4, 8} |
| `rsa_totient` | Cross | φ(pq) = (p-1)(q-1) |
| `k_halvings` | Dir 25 | k halvings = S/2^k |
| `lcm_gcd_product` | Dir 21 | lcm·gcd = product |

### Open (1 sorry)
| Theorem | Direction | Status |
|---------|-----------|--------|
| `fib_entry_point` | Dir 7 | Fibonacci entry point theorem — deep NT result |

## Running the Demo

```bash
python3 demos/demo_open_directions.py
```

## Building the Lean Files

```bash
lake build FutureResearchDirections
```
