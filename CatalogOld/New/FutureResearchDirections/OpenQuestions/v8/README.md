# Gravitational Factoring Research — Version 8

## Overview

Version 8 adds **62 new formally verified theorems** across 6 Lean files with **zero remaining sorries**, 5 Python demos, 3 SVG visualizations, and comprehensive documentation. Combined with v1-v7, the project now contains **170+ machine-verified theorems**.

## New Lean Files

| File | Theorems | Sorries | Domain |
|------|----------|---------|--------|
| `EulerDirectionComplete.lean` | 10 | 0 | Euler direction completion |
| `QuadraticResidueFactoring.lean` | 9 | 0 | QR theory, smooth numbers |
| `WallSunSun.lean` | 12 | 0 | WSS conjecture, Wieferich |
| `EnergyLandscapeAdvanced.lean` | 10 | 0 | Topology of E(x) |
| `LatticeFactoring.lean` | 8 | 0 | Lattice methods, Coppersmith |
| `SigmaArithmetic.lean` | 13 | 0 | σ₁ bounds, abundancy |

## Key New Results

### Headline Theorems
- **euler_m_equals_mersenne**: m = 2^(k+1) - 1 in even perfect factorization
- **mersenne_prime_exponent_prime**: If 2^p - 1 prime, then p prime
- **wieferich_1093/3511**: Verified Wieferich primes
- **wss_check_{7..29}**: Wall-Sun-Sun conjecture for small primes
- **qr_mul_qr**: Quadratic residue product closure
- **sigma1_gt_self'**: σ₁(n) > n for n > 1
- **energy_global_min_at_divisor**: Divisors are global minima of E(x)

### Open Questions Answered (v8)
1. m = 2^(k+1) - 1 in Euler direction ✓
2. Mersenne prime exponents are prime ✓
3. 1093 and 3511 are Wieferich primes ✓
4. Wall-Sun-Sun conjecture holds for p ≤ 29 ✓
5. QR products are QRs ✓
6. Smooth products are smooth ✓
7. σ₁(n) > n for n > 1 ✓
8. Divisors are global energy minima ✓
9. Level-0 Euler characteristic = τ(N) ✓
10. All primes are deficient ✓

## Python Demos

- `demos/demo_energy_landscape_3d.py` — Energy landscape with Morse theory
- `demos/demo_quadratic_sieve.py` — Quadratic sieve factoring
- `demos/demo_wall_sun_sun.py` — Wall-Sun-Sun and Fibonacci pseudoprimes
- `demos/demo_perfect_numbers.py` — Perfect number theory
- `demos/demo_lattice_factoring.py` — LLL-based factoring

## SVG Visuals

- `visuals/research_roadmap_v8.svg` — Research roadmap
- `visuals/theorem_dependency_v8.svg` — Theorem dependency graph
- `visuals/energy_landscape_topology.svg` — Energy landscape visualization

## Documentation

- `research_paper_v8.md` — Full research paper
- `scientific_american_v8.md` — Popular science article
- `future_research_directions_v8.md` — 100 research directions
- `answers_to_open_questions_v8.md` — 23 answered questions
- `applications_brainstorm_v8.md` — Applications and discoveries

## Building

```bash
lake build FutureResearchDirections.OpenQuestions.v8.EulerDirectionComplete
lake build FutureResearchDirections.OpenQuestions.v8.QuadraticResidueFactoring
lake build FutureResearchDirections.OpenQuestions.v8.WallSunSun
lake build FutureResearchDirections.OpenQuestions.v8.EnergyLandscapeAdvanced
lake build FutureResearchDirections.OpenQuestions.v8.LatticeFactoring
lake build FutureResearchDirections.OpenQuestions.v8.SigmaArithmetic
```

## Running Demos

```bash
python3 demos/demo_energy_landscape_3d.py
python3 demos/demo_quadratic_sieve.py
python3 demos/demo_wall_sun_sun.py
python3 demos/demo_perfect_numbers.py
python3 demos/demo_lattice_factoring.py
```
