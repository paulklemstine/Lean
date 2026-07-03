/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Selmer Fan: Gaussian binomials as a rank-distribution model

This file develops the combinatorial core of a *fan-structured* model for the
distribution of Selmer ranks over `p`-cyclic extensions.

## Mathematical context

In the Klagsbrun–Mazur–Rubin circle of results (`KMR13`, `KMR14`) and in the
Swinnerton-Dyer twist heuristics (`SDtwists`), the statistical behaviour of the
`p`-Selmer group of a family of twists is governed by the *distribution of ranks*
of subgroups of a finite `𝔽_p`-vector space.  The number of subgroups of
`𝔽_p^n` of a fixed rank `k` is the Gaussian binomial coefficient `[n,k]_p`.  As
`k` ranges over `0..n` these counts form a symmetric "fan" of layers — the
combinatorial skeleton underlying the predicted Selmer rank distributions.

We define the Gaussian binomial coefficient by the `q`-Pascal recurrence and
prove:

* helper `gaussBinom_eq_zero_of_lt` — the fan has finite support;
* helper `gaussBinom_dual_rec` — the dual `q`-Pascal recurrence;
* **main** `gaussBinom_symm` — self-duality of the fan `[n,k]_q = [n,n-k]_q`;
* **main** `gaussBinom_one` — the classical limit `[n,k]_1 = C(n,k)`;
* corollary `gaussBinom_rank_one` — the rank-one layer is the `q`-integer.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the number of rank-`k` subspaces of `𝔽_q^n` obeys a
`q`-Pascal law and hence forms a symmetric fan whose apex sits at `k = n/2`;
it should degenerate to Pascal's triangle at `q = 1`.
Experiment (Experimenter): `#eval` confirmed `[4,·]_2 = 1,15,35,15,1`,
`[3,·]_3 = 1,13,13,1`, both `q`-Pascal recurrences for all `n,k ≤ 6`, self-duality
for `q = 2, n ≤ 4`, `[n,k]_1 = C(n,k)` for `n,k ≤ 7`, and `[n,1]_3 = ∑ 3^i`.
Analysis (Analyst): self-duality is the hard case — one induction on `n`
feeding the *forward* recurrence on the `k` side and the *dual* recurrence on
the `n-k` side, glued by `q^{n-(n-k)} = q^k`.  Truncated `ℕ` subtraction forces
`gaussBinom_eq_zero_of_lt` to be proved first so the dual recurrence is valid
for all `k`.
Critique (Critic): none of the results collapses to `rfl`/`decide`; the
self-duality genuinely requires the dual recurrence, and the `q = 1` statement
needs `Nat.succ_sub`-style bookkeeping.  Corner cases `k = 0`, `k > n` are
handled by `gaussBinom_eq_zero_of_lt`.
Synthesis: the fan is a bona fide symmetric, binomial-limiting rank model.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace SelmerFan

/-- The Gaussian binomial coefficient `[n,k]_q`, i.e. the number of rank-`k`
`𝔽_q`-subspaces of `𝔽_q^n`, defined by the forward `q`-Pascal recurrence. -/
def gaussBinom (q : ℕ) : ℕ → ℕ → ℕ
  | 0, 0 => 1
  | 0, _ + 1 => 0
  | _ + 1, 0 => 1
  | n + 1, k + 1 => gaussBinom q n k + q ^ (k + 1) * gaussBinom q n (k + 1)

@[simp] theorem gaussBinom_zero_right (q n : ℕ) : gaussBinom q n 0 = 1 := by
  cases n <;> rfl

@[simp] theorem gaussBinom_zero_succ (q k : ℕ) : gaussBinom q 0 (k + 1) = 0 := rfl

theorem gaussBinom_succ_succ (q n k : ℕ) :
    gaussBinom q (n + 1) (k + 1)
      = gaussBinom q n k + q ^ (k + 1) * gaussBinom q n (k + 1) := rfl

/-
The fan has finite support: there are no subspaces of rank exceeding the
ambient dimension.
-/
theorem gaussBinom_eq_zero_of_lt (q : ℕ) {n k : ℕ} (h : n < k) :
    gaussBinom q n k = 0 := by
  induction' n with n ih generalizing k;
  · cases k <;> aesop;
  · rcases k with ( _ | _ | k ) <;> simp_all +decide [ gaussBinom_succ_succ ];
    exact Or.inr ( ih ( by linarith ) )

/-
The *dual* `q`-Pascal recurrence.  Together with the definitional forward
recurrence this drives the self-duality of the Selmer fan.
-/
theorem gaussBinom_dual_rec (q n k : ℕ) :
    gaussBinom q (n + 1) (k + 1)
      = q ^ (n - k) * gaussBinom q n k + gaussBinom q n (k + 1) := by
  by_cases h : n < k;
  · grind +suggestions;
  · induction' n with n ih generalizing k;
    · cases k <;> simp_all +decide [ gaussBinom ];
    · cases lt_or_eq_of_le ( Nat.le_of_not_lt h ) <;> simp_all +decide [ Nat.succ_sub, pow_succ', mul_assoc ];
      · have := ih k ‹_›; have := ih ( k - 1 ) ( Nat.sub_le_of_le_add <| by linarith ) ; rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ', mul_assoc, gaussBinom_succ_succ ] ;
        · grind;
        · grind +splitIndPred;
      · grind +suggestions

/-
**Self-duality of the Selmer fan.**  The rank-`k` and rank-`(n-k)` layers
have equal size.
-/
theorem gaussBinom_symm (q : ℕ) {n k : ℕ} (h : k ≤ n) :
    gaussBinom q n k = gaussBinom q n (n - k) := by
  induction' n using Nat.strongRecOn with n ih generalizing k;
  rcases n with ( _ | n ) <;> rcases k with ( _ | k ) <;> simp_all +decide;
  · grind +suggestions;
  · by_cases hk : k = n;
    · simp +decide [ hk, gaussBinom_succ_succ ];
      simp +decide [ gaussBinom_eq_zero_of_lt ];
      exact ih n le_rfl le_rfl ▸ by simp +decide ;
    · rw [ gaussBinom_dual_rec ];
      rw [ show n - k = ( n - k - 1 ) + 1 by omega, gaussBinom_succ_succ ];
      grind

/-
**Classical limit.**  At `q = 1` the Gaussian binomial is the ordinary
binomial coefficient.
-/
theorem gaussBinom_one (n k : ℕ) : gaussBinom 1 n k = Nat.choose n k := by
  induction' n with n ih generalizing k;
  · cases k <;> simp +decide [ Nat.choose ];
  · rcases k with ( _ | k ) <;> simp_all +decide [ Nat.choose_succ_succ, gaussBinom_succ_succ ]

/-
**Rank-one layer.**  The number of rank-one subspaces (lines) of `𝔽_q^n`
is the `q`-integer `1 + q + ⋯ + q^{n-1}`.
-/
theorem gaussBinom_rank_one (q n : ℕ) :
    gaussBinom q n 1 = ∑ i ∈ Finset.range n, q ^ i := by
  induction' n with n ih <;> simp_all +decide [ Finset.sum_range_succ ];
  rw [ ← ih, gaussBinom_succ_succ ] ; simp +decide;
  nlinarith [ geom_sum_mul_neg ( q : ℤ ) n ]

end SelmerFan