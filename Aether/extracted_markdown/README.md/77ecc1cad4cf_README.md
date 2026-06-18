# MetaFactoring: A Unified Multi-Lens Framework for Integer Factorization

## Overview

MetaFactoring synthesizes **seven complementary factoring paradigms** into a single coherent framework. The key insight: each paradigm provides a different "lens" through which to view the factorization problem, and **combining lenses multiplicatively constrains the search space** far more than any single method alone.

## The Seven Lenses

| Lens | Paradigm | Key Identity | Formalized? |
|------|----------|-------------|-------------|
| 1 | Fibonacci-Zeckendorf | F(k+2) < 2^k | ✓ |
| 2 | Hyperbolic Geometry | xy = N, AM-GM | ✓ |
| 3 | Orbit Dynamics | Pollard rho collisions | ✓ |
| 4 | Spectral Harmonic | Fermat's little theorem | ✓ |
| 5 | Division Algebra | Brahmagupta/Euler/Degen | ✓ |
| 6 | Lattice Reduction | Bézout's identity | ✓ |
| 7 | Congruence of Squares | x²−y² = (x−y)(x+y) | ✓ |

## Project Structure

### Lean 4 Formalizations (all sorry-free, axiom-clean)

- **`Core.lean`** — Original formalization: 15+ theorems covering all seven lenses
- **`NewTheorems.lean`** — New theorem candidates: 20+ theorems including Degen 8-square identity, Pisano periodicity, AM-GM for divisors, Euler's criterion, and more
- **`BridgeTheorems.lean`** — Bridge theorems connecting lenses: Cassini's identity, Fibonacci addition formula, orbit size bounds, composite minimum factor bounds, Fibonacci ratio bounds, GCD properties

### Python Demonstrations

- **`demo_metafactoring.py`** — Full MetaFactoring engine with 7 demos showing lens complementarity
- **`demo_new_theorems.py`** — Computational exploration of 7 new theorem candidates
- **`demo_bridge_theorems.py`** — Bridge theorem verification: Cassini's identity, Pisano periods, correlation matrix, constraint convergence, norm channels

### SVG Visualizations (15 files in `visuals/`)

**Original Suite:**
- `seven_lenses_architecture.svg` — Hub-and-spoke architecture diagram
- `constraint_intersection.svg` — Progressive search space reduction
- `hyperbola_divisors.svg` — Divisor pairs on xy = N
- `fibonacci_carry_cascade.svg` — Bidirectional carry propagation
- `norm_sphere_collision.svg` — Sum-of-squares collision geometry
- `lens_effectiveness_radar.svg` — Radar chart of lens effectiveness

**New Theorem Visuals:**
- `dimension_barrier.svg` — Hurwitz dimension hierarchy
- `pisano_spiral.svg` — Pisano period structure
- `bridge_network.svg` — Inter-lens bridge theorem network

**Research Direction Visuals:**
- `future_research_roadmap.svg` — 5-year research timeline with milestones
- `correlation_matrix.svg` — 7×7 inter-lens independence matrix
- `cayley_dickson_hierarchy.svg` — ℝ → ℂ → ℍ → 𝕆 norm channel tower
- `quantum_extension.svg` — Quantum MetaFactoring (8th lens) diagram
- `applications_map.svg` — Application landscape map
- `constraint_convergence_chart.svg` — Bar chart of exponential reduction

### Written Content

- **`research_paper.md`** — Full research paper with 10 sections including new theorem candidates
- **`scientific_american_article.md`** — Popular science article for general audiences
- **`applications_brainstorm.md`** — Extensive brainstorm of applications across domains
- **`future_research_directions.md`** — Comprehensive 5-year research roadmap with 5 major thrusts
- **`team_research_plan.md`** — Team formation plan with 7 roles, sprint schedule, and success metrics

### Visual Generation Scripts

- **`generate_visuals.py`** — Original visualization generator
- **`generate_new_visuals.py`** — New theorem visualization generator
- **`generate_all_visuals.py`** — Complete visual suite generator

## New Theorem Candidates

Seven new theorem candidates extend the framework:

1. **Inter-Lens Correlation Bound** — Conjectured O(1/√N) decay makes lenses asymptotically independent
2. **Fibonacci-Spectral Duality** — Pisano period π(m) related to spectral gap (Pisano periodicity formally proved)
3. **Hyperbolic-Lattice Correspondence** — AM-GM bound 4N ≤ (d+N/d)² formally proved
4. **Orbit-Norm Collision** — Two-representation norm square identity formally proved
5. **Division Algebra Dimension Barrier** — Hurwitz's theorem; 2-, 4-, 8-square identities all formally proved
6. **Zeckendorf Product Spread** — Fibonacci growth bounds (linear and exponential) formally proved
7. **Seven-Lens Completeness** — Universal quartic-root factoring bound conjectured

## Bridge Theorems (NEW)

Formally verified connections between lenses:

- **Cassini's Identity** (Lens 1 ↔ Lens 6): F(n+1)·F(n-1) - F(n)² = (-1)^n
- **Fibonacci Addition** (Lens 1 ↔ modular arithmetic): F(m+n) = F(m)·F(n+1) + F(m-1)·F(n)
- **Fibonacci GCD** (Lens 1 ↔ divisibility): gcd(F(m), F(n)) = F(gcd(m,n))
- **Euler Totient** (Lens 4 ↔ Lens 7): φ(pq) = φ(p)·φ(q) for coprime p,q
- **Orbit Pigeonhole** (Lens 3): Orbit size ≤ domain size
- **Composite Min Factor** (Lens 2): minFac(n) ≤ √n for composites
- **Fibonacci Ratio** (Lens 1): F(n+1) ≤ 2·F(n), confirming φ < 2

## Future Research Directions

Five major research thrusts identified:

1. **Tightening Constraint Intersection** — Correlation bounds, Bayesian lens selection, new lenses
2. **Fibonacci-Spectral Duality** — Proving the connection between Pisano periods and spectral gaps
3. **Division Algebra Hierarchy** — Quaternionic factoring, Cayley-Dickson extensions, E₈ connections
4. **Quantum MetaFactoring** — Shor's algorithm as 8th lens, hybrid protocols, Grover speedup
5. **Formal Verification** — Jacobi's four-square theorem, quadratic sieve, ECM, NFS

## Formal Verification Status

All Lean 4 files compile without errors and contain **zero `sorry` statements**. All proofs use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

| File | Theorems | Status |
|------|----------|--------|
| `Core.lean` | 15+ | ✅ All proved |
| `NewTheorems.lean` | 20+ | ✅ All proved |
| `BridgeTheorems.lean` | 12+ | ✅ All proved |

## Quick Start

```bash
# Run Python demos
python MetaFactoring/demo_metafactoring.py
python MetaFactoring/demo_new_theorems.py
python MetaFactoring/demo_bridge_theorems.py

# Generate all SVG visuals
python MetaFactoring/generate_all_visuals.py

# Build Lean formalizations
lake build MetaFactoring
```
