# Computational Evidence — Proof Automation: Custom Tactics

This note records the small-case checks that guided the three tactic-soundness
theorems before they were formalized.

## 1. `tropical_simp` (max-plus semiring)

Max-plus convention: addition `a ⊕ b = max a b`, multiplication `a ⊙ b = a + b`.

**Distributivity** `a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)`, i.e. `a + max b c = max (a+b) (a+c)`:

| a | b | c | a+max(b,c) | max(a+b,a+c) |
|---|---|---|-----------|--------------|
| 3 | 1 | 5 | 8 | 8 |
| 3 | 5 | 1 | 8 | 8 |
| -2| 4 | 4 | 2 | 2 |

**Tropical Horner** `max(a₀, a₁+x, a₂+2x) = a₀ ⊕ x⊙(a₁ ⊕ x⊙a₂)`:
with `a₀=0, a₁=1, a₂=2, x=3`:
- LHS `= max(0, 1+3, 2+6) = max(0,4,8) = 8`.
- RHS `= max(0, 3 + max(1, 3+2)) = max(0, 3 + max(1,5)) = max(0, 3+5) = 8`. ✓

All sampled cases match; the identity is exact (no approximation), consistent
with the algebraic proof via `max_add_add_left`.

## 2. `number_theory_decide` (trial-division primality)

Definition tested: `trialPrime n = (2 ≤ n) ∧ (no d with 2 ≤ d < n divides n)`.

- `trialPrime` on `2..30` returns exactly `{2,3,5,7,11,13,17,19,23,29}` — the
  primes below 30. The count of primes below 100 is 25, matching `π(100)=25`.
- Composite spot-checks: `91 = 7·13`, `65 = 5·13`, `1 = 1` all return `false`.
- Edge cases: `trialPrime 0 = false`, `trialPrime 1 = false` (both fail `2 ≤ n`),
  `trialPrime 2 = true` (empty divisor range).

No counterexample to `trialPrime n = true ↔ Nat.Prime n` was found on `0..500`,
which motivated the formal soundness proof via `Nat.prime_def_lt'`.

## 3. `spectral_bound` (row-sum eigenvalue estimate)

Claim tested: any real eigenvalue `λ` of `A` satisfies `|λ| ≤ maxᵢ Σⱼ |Aᵢⱼ|`.

- `A = [[2,1],[1,2]]`: eigenvalues `3, 1`; row sums both `3`; bound `3` holds
  and is tight at `λ=3`.
- `A = [[0,1],[-2,-3]]`: eigenvalues `-1,-2`; row sums `1` and `5`; bound `5`
  holds (`|−2| ≤ 5`).
- `A = [[5,0],[0,-4]]`: eigenvalues `5,-4`; row sums `5,4`; bound `5` holds and
  is attained.

Every sampled matrix satisfies `|λ| ≤ max row sum`, and the bound is attained by
diagonal matrices, confirming it is the best possible uniform row-sum bound.
This is the elementary (spectral-radius) half of the Gershgorin circle theorem.
