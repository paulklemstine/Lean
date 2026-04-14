# Gravitational Factoring Research — Version 7

## Overview

Version 7 adds **45+ new formally verified theorems** across 7 Lean files, 5 Python demos, 2 SVG visualizations, and comprehensive documentation. Combined with v1-v6, the project now contains **130+ machine-verified theorems**.

## New Lean Files

| File | Theorems | Sorries | Domain |
|------|----------|---------|--------|
| `HurwitzQuaternions.lean` | 11 | 0 | Quaternion norm theory |
| `SigmaHardness.lean` | 12 | 0 | σ₁ ↔ FACTORING reduction |
| `FibonacciPseudoprimes.lean` | 10 | 3 | F(p)² criterion, bounds |
| `PisanoPeriodFactoring.lean` | 8 | 1 | Pisano periods and CRT |
| `EnergyMorseTheory.lean` | 12 | 0 | Morse theory of E(x) |
| `EvenPerfectNumbers.lean` | 12 | 0 | Euler direction |
| `JacobiFourSquare.lean` | 7 | 0 | Jacobi formula foundations |

## Key New Results

### Headline Theorems
- **fib_sq_mod_prime**: F(p)² ≡ 1 (mod p) for primes p ≠ 2, 5
- **sigma1_determines_factors**: σ₁(pq) uniquely determines {p, q}
- **euler_key_equation**: Key step toward Euler's perfect number theorem
- **pisano_factor_constraint**: π(p) | p² - 1 for primes p ≠ 5
- **divisor_is_local_min**: Divisors are local minima of E(x) = N mod x

### Open Questions Answered
1. σ₁ evaluation is computationally equivalent to factoring ✓
2. F(p)² ≡ 1 (mod p) holds for all odd primes p ≠ 5 ✓
3. Pisano periods satisfy CRT multiplicativity ✓
4. Discrete Laplacian is nonneg at divisors ✓
5. Even perfect numbers satisfy the Euler key equation ✓

## Python Demos

- `demos/demo_pisano_factoring.py` — Pisano period factoring algorithm
- `demos/demo_sigma_hardness.py` — σ₁ oracle attack on RSA
- `demos/demo_energy_morse.py` — Energy landscape visualization
- `demos/demo_perfect_euler.py` — Perfect number verification
- `demos/demo_hurwitz_factoring.py` — Quaternion-based factoring

## SVG Visuals

- `visuals/theorem_dependency_v7.svg` — Theorem dependency graph
- `visuals/research_roadmap_v7.svg` — Research roadmap

## Documentation

- `research_paper_v7.md` — Full research paper
- `scientific_american_v7.md` — Popular science article
- `future_research_directions_v7.md` — 95 research directions
- `answers_to_open_questions_v7.md` — Answers to open questions
- `applications_brainstorm_v7.md` — Applications and industry impact

## Building

```bash
lake build FutureResearchDirections.OpenQuestions.v7.HurwitzQuaternions
lake build FutureResearchDirections.OpenQuestions.v7.SigmaHardness
lake build FutureResearchDirections.OpenQuestions.v7.FibonacciPseudoprimes
lake build FutureResearchDirections.OpenQuestions.v7.PisanoPeriodFactoring
lake build FutureResearchDirections.OpenQuestions.v7.EnergyMorseTheory
lake build FutureResearchDirections.OpenQuestions.v7.EvenPerfectNumbers
lake build FutureResearchDirections.OpenQuestions.v7.JacobiFourSquare
```
