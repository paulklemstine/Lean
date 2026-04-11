# MetaFactoring: A Unified Multi-Lens Framework for Integer Factorization

## Overview

MetaFactoring synthesizes **seven complementary factoring paradigms** explored throughout this project into a single coherent framework. Each paradigm provides a different mathematical "lens" through which to view the factorization problem, and combining lenses multiplicatively constrains the search space.

### The Seven Lenses

| # | Lens | Mathematical Field | Key Mechanism |
|---|------|-------------------|---------------|
| 1 | **Fibonacci-Zeckendorf** | Combinatorics | Bidirectional carry constraints, non-adjacency |
| 2 | **Hyperbolic-Geometric** | Algebraic Geometry | Divisor pairs on xy = N |
| 3 | **Orbit-Dynamical** | Dynamical Systems | Pollard ρ collisions |
| 4 | **Spectral-Harmonic** | Harmonic Analysis | Character sums, smooth number bias |
| 5 | **Division-Algebra** | Abstract Algebra | Norm-multiplicativity (ℂ, ℍ, 𝕆) |
| 6 | **Lattice-Reduction** | Geometry of Numbers | Short vectors via LLL |
| 7 | **Congruence-of-Squares** | Number Theory | x² ≡ y² (mod N) endgame |

## Contents

### Lean 4 Formalization (`Core.lean`)
All core theorems are **formally verified** with zero sorry statements:
- Fibonacci search space reduction (fib(k+2) < 2^k)
- Bidirectional carry and adjacency identities
- Divisor hyperbola correspondence
- Orbit periodicity and collision factor extraction
- Fermat's little theorem
- Brahmagupta-Fibonacci and Euler four-square identities
- Sum-of-squares collision factoring theorem
- Bézout's identity and lattice structure
- Congruence of squares factoring theorem
- Unified correctness theorem
- k-lens constraint reduction theorem

### Python Demo (`demo_metafactoring.py`)
Seven interactive demonstrations:
1. Individual lens views of N = 10403 = 101 × 103
2. Full MetaFactoring engine on diverse composites
3. Progressive search space reduction visualization
4. Fibonacci bidirectional carry cascades
5. Division algebra norm collisions
6. Seven-lens comparison table
7. Timing comparison across difficulty levels

Run: `python3 demo_metafactoring.py`

### SVG Visuals (`visuals/`)
Six publication-quality SVG diagrams:
- `seven_lenses_architecture.svg` — Hub-and-spoke architecture diagram
- `constraint_intersection.svg` — Progressive search space reduction
- `hyperbola_divisors.svg` — Divisor pairs on xy = 210
- `fibonacci_carry_cascade.svg` — Binary vs Fibonacci carry propagation
- `norm_sphere_collision.svg` — Sum-of-squares collision geometry
- `lens_effectiveness_radar.svg` — Radar chart of lens complementarity

Generate: `python3 generate_visuals.py`

### Research Paper (`research_paper.md`)
Full academic paper with:
- Mathematical framework and definitions
- Individual lens analysis (7 sections)
- Constraint Intersection Theorem
- Bridge theorems connecting lenses
- Formal verification methodology
- Computational results

### Scientific American Article (`scientific_american_article.md`)
Accessible popular science article explaining MetaFactoring for a general audience.

### Applications Brainstorm (`applications_brainstorm.md`)
- Research team structure (4 teams)
- 10 exciting cross-domain applications
- 7 new theorem conjectures
- 24-month research roadmap
- Open questions

## Key Insight

> No single lens dominates across all composite types. MetaFactoring's power comes from the **complementarity** of paradigms: what one lens misses, another catches. The Constraint Intersection Theorem proves that k independent lenses reduce the search space by at least 2^k.
