# Gravitational Factoring Research — Version 4

## Overview

This directory contains the v4 research output for the gravitational factoring program, building on v3 with new formally verified theorems, computational demos, visualizations, and research recommendations.

## New Formal Results (v4)

### `SigmaPrimePower.lean` — NEW
- `sigma1_prime_power`: σ₁(pⁿ) = Σᵢ₌₀ⁿ pⁱ for any prime p
- `sigma1_prime_power_formula`: σ₁(pⁿ)·(p-1) = p^{n+1}-1
- `sigma1_prime_cube`: σ₁(p³) = p³+p²+p+1
- `sigma1_semiprime`: σ₁(pq) = (p+1)(q+1) for distinct primes
- `sigma1_two_prime_powers`: σ₁(p^a·q^b) = σ₁(p^a)·σ₁(q^b)
- `berggren_geometric_general`: (b-1)·Σ bⁱ = b^{d+1}-1 for any b ≥ 2

### `OpenDirections.lean` — UPDATED
- `fib_cassini`: F(n+1)²-F(n)·F(n+2) = (-1)ⁿ (Cassini's identity)
- `fib_cassini_prime`: F(p-1)·F(p+1) = F(p)²-1 for odd primes
- `fib_entry_point`: p | F(p-1) ∨ p | F(p+1) (modulo fib_sq_mod_prime)
- Fixed `p_sub_one_dvd_p_sq_sub_one` and `p_add_one_dvd_p_sq_sub_one`

### Remaining Sorry
- `fib_sq_mod_prime`: (p : ℤ) ∣ (F(p)²-1) for prime p ≠ 5

## Written Deliverables

| File | Description |
|------|-------------|
| `research_paper_v4.md` | Formal research paper with all new results |
| `scientific_american_v4.md` | Popular science article |
| `applications_brainstorm_v4.md` | 30+ application ideas across 8 domains |
| `future_research_directions_v4.md` | 65 research directions, tiered and prioritized |
| `answers_to_open_questions_v4.md` | Comprehensive answers to all open questions |

## Computational Demos

| File | Description |
|------|-------------|
| `demos/gravitational_factoring_explorer.py` | 10 demos covering all major research areas |

Run with: `python3 demos/gravitational_factoring_explorer.py`

## Visualizations (SVG)

| File | Description |
|------|-------------|
| `visuals/sigma_prime_power.svg` | σ₁(pⁿ) formula and examples |
| `visuals/cassini_identity.svg` | Cassini → Entry Point proof chain |
| `visuals/research_roadmap_v4.svg` | Complete research roadmap with status |
| `visuals/channel_hierarchy_v4.svg` | Cayley-Dickson channel growth |

## Verification Status

- **Total verified theorems**: 53+
- **Remaining sorries**: 1 (fib_sq_mod_prime)
- **Build status**: ✓ All files compile with Lean 4.28.0 + Mathlib
