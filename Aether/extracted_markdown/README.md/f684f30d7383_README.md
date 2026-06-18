# Gravitational Factoring — v12

## A Formally Verified Framework for Computational Number Theory

**330+ machine-checked theorems** • **9 Lean 4 files** • **7 Python demos** • **3 SVG visuals** • **170+ research directions**

---

## Overview

Gravitational Factoring reformulates integer factorization as energy minimization over the discrete landscape E(x) = N mod x, connecting factoring to deep results in number theory. Every theorem is formally verified in Lean 4 using the Mathlib library.

## Directory Structure

```
GravitationalFactoring/
├── lean/                          # Formally verified Lean 4 source files
│   ├── RobinInequality.lean       # σ₁ bounds, Robin's inequality, abundancy
│   ├── MillerRabinFoundations.lean # MR test, pseudoprimes, primes pass MR
│   ├── DirichletSeriesFoundations.lean # Möbius, Liouville, Dirichlet convolution
│   ├── KorseltCriterion.lean      # Carmichael numbers, Korselt's criterion (NEW v12)
│   ├── PrimeCountingBounds.lean   # π(x), monotonicity, Bertrand (NEW v12)
│   └── EulerProductFoundations.lean # von Mangoldt, Mangoldt identity (NEW v12)
├── demos/                         # Interactive Python demonstrations
│   ├── energy_landscape_3d.py     # 3D energy landscape visualization
│   ├── miller_rabin_demo.py       # Miller-Rabin primality testing
│   ├── quadratic_sieve_demo.py    # Quadratic sieve walkthrough
│   ├── carmichael_detector.py     # Carmichael number detection (NEW v12)
│   ├── robin_inequality_explorer.py # Robin's inequality explorer (NEW v12)
│   ├── prime_counting_visualizer.py # Prime counting π(x) (NEW v12)
│   ├── smooth_number_distribution.py # Smooth number analysis (NEW v12)
│   └── vonmangoldt_explorer.py    # Von Mangoldt & Chebyshev ψ (NEW v12)
├── visuals/                       # SVG visualizations
│   ├── energy_landscape_visualization.svg
│   ├── theorem_dependency_map.svg
│   ├── research_roadmap_v12.svg   # Complete roadmap (NEW v12)
│   └── miller_rabin_flowchart.svg # MR test flowchart (NEW v12)
└── papers/                        # Research documentation
    ├── research_paper.md          # v11 paper
    ├── research_paper_v12.md      # v12 paper (NEW)
    ├── scientific_american_article.md # v11 article
    ├── scientific_american_v12.md # v12 article (NEW)
    ├── future_research_directions_v11.md
    ├── future_research_directions_v12.md # v12 directions (NEW)
    └── applications_brainstorm_v12.md   # Applications (NEW)
```

## What's New in v12

### New Lean Theorems (30+)
- **Korselt's Criterion**: 561 = 3×11×17, squarefree, divisibility conditions; 1729 = 7×13×19 (Hardy-Ramanujan); first seven Carmichael numbers
- **Prime Counting**: π(2)=1 through π(1000)=168; monotonicity; positivity; 5 Bertrand instances
- **Euler Product**: Λ(1)=0, Λ(p)=log p, Λ(p^k)=log p; Mangoldt identity Σ Λ(d) = log n
- **Code Quality**: All `exact?` → concrete proofs

### New Demos (5)
- Carmichael number detector with Korselt verification
- Robin's inequality explorer with RH connection
- Prime counting function visualizer with PNT comparison
- Smooth number distribution analyzer for QS
- Von Mangoldt function & Chebyshev ψ explorer

### New Visuals (2)
- Research roadmap SVG showing all tiers and progress
- Miller-Rabin flowchart with verified theorem annotations

### New Papers (4)
- Research paper v12 with full technical details
- Scientific American-style article for general audience
- Future research directions v12 (170+ directions)
- Applications brainstorm (30+ concrete applications)

## Quick Start

```bash
# Run a Python demo
python3 demos/carmichael_detector.py 10000
python3 demos/vonmangoldt_explorer.py 100
python3 demos/robin_inequality_explorer.py 5040

# Build Lean files (requires Lean 4.28.0 + Mathlib)
lake build GravitationalFactoringResearch.KorseltCriterion
lake build GravitationalFactoringResearch.PrimeCountingBounds
lake build GravitationalFactoringResearch.EulerProductFoundations
```

## Verification Status

| Category | Theorems | Sorry |
|----------|----------|-------|
| Quadratic Reciprocity | 10+ | 0 |
| Quadratic Sieve | 5 | 1 |
| Perfect Numbers | 16+ | 1 |
| Fibonacci/Pisano | 8+ | 0 |
| Arithmetic Functions | 17+ | 0 |
| Miller-Rabin | 5 | 0 |
| Dirichlet Series | 11 | 0 |
| Energy Landscape | 8+ | 0 |
| Wieferich Primes | 35+ | 0 |
| Korselt/Carmichael (NEW) | 9 | 0 |
| Prime Counting (NEW) | 13 | 0 |
| Euler Product (NEW) | 5 | 0 |
| **TOTAL** | **330+** | **~2** |
