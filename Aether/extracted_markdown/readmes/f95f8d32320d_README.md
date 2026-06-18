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

### Lean 4 Formalizations (sorry-free, axiom-clean)
- **`Core.lean`** — Original formalization: 15+ theorems covering all seven lenses
- **`NewTheorems.lean`** — New theorem candidates: 20+ theorems including Degen 8-square identity, Pisano periodicity, AM-GM for divisors, Euler's criterion, and more

### Python Demonstrations
- **`demo_metafactoring.py`** — Full MetaFactoring engine with 7 demos showing lens complementarity
- **`demo_new_theorems.py`** — Computational exploration of 7 new theorem candidates

### SVG Visualizations (9 files in `visuals/`)
- `seven_lenses_architecture.svg` — Hub-and-spoke architecture diagram
- `constraint_intersection.svg` — Progressive search space reduction
- `hyperbola_divisors.svg` — Divisor pairs on xy = N
- `fibonacci_carry_cascade.svg` — Bidirectional carry propagation
- `norm_sphere_collision.svg` — Sum-of-squares collision geometry
- `lens_effectiveness_radar.svg` — Radar chart of lens effectiveness
- **`dimension_barrier.svg`** — Hurwitz dimension hierarchy (NEW)
- **`pisano_spiral.svg`** — Pisano period structure (NEW)
- **`bridge_network.svg`** — Inter-lens bridge theorem network (NEW)

### Written Content
- **`research_paper.md`** — Full research paper with 10 sections including new theorem candidates
- **`scientific_american_article.md`** — Popular science article for general audiences
- **`applications_brainstorm.md`** — Extensive brainstorm of applications across domains

## New Theorem Candidates

Seven new theorem candidates extend the framework:

1. **Inter-Lens Correlation Bound** — Correlation between lenses is O(1/√N) *(Conjecture)*
2. **Fibonacci-Spectral Duality** — Pisano period relates to spectral gap *(Conjecture)*
3. **Hyperbolic-Lattice Correspondence** — Divisor pairs ↔ short vectors *(Conjecture)*
4. **Orbit-Norm Collision** — O(N^{1/4}) hybrid factoring *(Conjecture)*
5. **Division Algebra Dimension Barrier** — No 16-square identity exists *(Theorem — PROVED)*
6. **Zeckendorf Product Spread** — Fibonacci multiplication is Ω(log) non-local *(Conjecture)*
7. **Seven-Lens Completeness** — Universal N^{1/4+ε} factoring bound *(Conjecture)*

## Key Results (Formally Verified)

All Lean proofs compile without `sorry` and use only standard axioms:

- **Fibonacci search reduction**: `fib(k+2) < 2^k` for k ≥ 2
- **Degen 8-square identity**: Product of sums of 8 squares = sum of 8 squares (octonion norm)
- **Pisano periodicity**: Fibonacci mod m is periodic for any m ≥ 2
- **AM-GM for divisors**: 4N ≤ (d + N/d)² for any divisor d
- **Orbit collision gives factor**: mod-p collision with mod-N non-collision → nontrivial GCD
- **Congruence of squares**: Full correctness theorem with both bounds
- **Euler's criterion**: a^((p-1)/2) ∈ {1, -1} for odd prime p
- **Wilson's theorem**: (p-1)! ≡ -1 (mod p) for prime p
- **Exponential advantage**: For any ε > 0, enough lenses make the search space < ε

## Running

```bash
# Generate SVG visuals
python3 MetaFactoring/generate_visuals.py
python3 MetaFactoring/generate_new_visuals.py

# Run the MetaFactoring engine demo
python3 MetaFactoring/demo_metafactoring.py

# Run the new theorem explorations
python3 MetaFactoring/demo_new_theorems.py

# Build and verify Lean formalizations
lake build MetaFactoring
```

## License

Research project — all code and formalizations are provided for academic use.
