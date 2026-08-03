/-
# Maynard–Tao: verified finite and reduction components

This file collects the parts of the bounded-prime-gap argument that follow from
results currently available in the catalog and Mathlib:

* the exact finite-dimensional GPY/Maynard weight optimization;
* exact partition and zero-sum identities for prime-count discrepancies in
  arithmetic progressions;
* the reduction from arbitrarily large prime pairs at distance at most `246` to
  the corresponding `liminf` bound.

The unconditional production of those bounded prime pairs requires the analytic
Maynard–Tao sieve, including a Bombieri–Vinogradov level-of-distribution estimate.
That analytic theorem is not asserted here as an assumption-free result.
-/
import Mathlib
import Novelty.Admissible
import Novelty.BoundedGaps
import MachineLearning.PrimeGaps.Optimization

namespace TwinPrimeGaps

open Finset BigOperators

/-! ## The finite-dimensional variational problem -/

/-- Values attained by the finite GPY Rayleigh quotient in dimension `k`. -/
def gpyAttainedValues (k : ℕ) : Set ℝ :=
  {r | ∃ w : Fin k → ℝ, 0 < S1 w ∧ r = S2 w / S1 w}

/-- The GPY variational value is the supremum of the attained quotients. -/
noncomputable def gpyVariationalValue (k : ℕ) : ℝ :=
  sSup (gpyAttainedValues k)

/-- Every admissible finite-dimensional GPY quotient is at most the dimension. -/
theorem gpyAttainedValues_le_dimension {k : ℕ} (hk : 0 < k)
    {r : ℝ} (hr : r ∈ gpyAttainedValues k) : r ≤ k := by
  obtain ⟨w, hw, rfl⟩ := hr
  exact rayleigh_quotient_bound w hk (ne_of_gt hw)

/-- Constant weights attain the upper bound `k`. -/
theorem dimension_mem_gpyAttainedValues {k : ℕ} (hk : 0 < k) :
    (k : ℝ) ∈ gpyAttainedValues k := by
  refine ⟨fun _ => 1, ?_, ?_⟩
  · simp [S1]
    exact_mod_cast hk
  · simp [S1, S2]
    field_simp

/-- The finite GPY variational problem has exact optimum `k`. -/
theorem gpyVariationalValue_eq_dimension {k : ℕ} (hk : 0 < k) :
    gpyVariationalValue k = k := by
  apply (show IsGreatest (gpyAttainedValues k) (k : ℝ) from
    ⟨dimension_mem_gpyAttainedValues hk, fun _ hr => gpyAttainedValues_le_dimension hk hr⟩).csSup_eq

/-- The strict threshold formulation of the same variational result. -/
theorem gpy_variational_threshold_iff {k : ℕ} (hk : 0 < k) (τ : ℝ) :
    (∃ w : Fin k → ℝ, 0 < S1 w ∧ τ < S2 w / S1 w) ↔ τ < k := by
  simpa [PositiveWeightProfile] using positiveWeightProfile_exists_iff hk τ

/-! ## Exact arithmetic-progression bookkeeping -/

/-- Number of primes at most `x` in the residue class `a mod q`. -/
def primeAPCount (x q a : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter fun n => n.Prime ∧ n % q = a).card

/-- Number of primes at most `x`. -/
def primeCountUpTo (x : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter Nat.Prime).card

/-- Residue classes partition the primes up to `x`. -/
theorem sum_primeAPCount (x q : ℕ) (hq : 0 < q) :
    ∑ a ∈ Finset.range q, primeAPCount x q a = primeCountUpTo x := by
  simp only [primeAPCount, primeCountUpTo]
  symm
  rw [Finset.card_eq_sum_card_fiberwise
    (f := fun n => n % q) (t := Finset.range q)]
  · apply Finset.sum_congr rfl
    intro a ha
    congr 1
    ext n
    simp [and_left_comm, and_comm]
  · intro n hn
    simpa using Nat.mod_lt n hq

/-- Discrepancy from the average over all residue classes modulo `q`. -/
noncomputable def primeAPDiscrepancy (x q a : ℕ) : ℝ :=
  primeAPCount x q a - (primeCountUpTo x : ℝ) / q

/-- The arithmetic-progression discrepancies have total sum zero. -/
theorem sum_primeAPDiscrepancy (x q : ℕ) (hq : 0 < q) :
    ∑ a ∈ Finset.range q, primeAPDiscrepancy x q a = 0 := by
  simp only [primeAPDiscrepancy]
  rw [Finset.sum_sub_distrib]
  simp only [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  rw [show (∑ a ∈ Finset.range q, (primeAPCount x q a : ℝ)) = primeCountUpTo x by
    exact_mod_cast sum_primeAPCount x q hq]
  field_simp
  ring

/-! ## The bounded-pair-to-liminf reduction -/

/-- The exact prime-pair output needed from the analytic sieve at bound `B`. -/
def ArbitrarilyLargePrimePairs (B : ℕ) : Prop :=
  ∀ N : ℕ, ∃ p q : ℕ,
    p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + B

/-- The analytic output at `246` implies the advertised consecutive-gap bound. -/
theorem liminf_primeGap_le_246_of_maynard_output
    (h : ArbitrarilyLargePrimePairs 246) :
    Filter.atTop.liminf primeGap ≤ 246 := by
  exact liminf_primeGap_le_246 h

/-- Realizing a fixed prime pair difference infinitely often supplies bounded pairs. -/
theorem fixed_difference_gives_bounded_pairs {d : ℕ} (hd : 0 < d)
    (h : ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ n.Prime ∧ (n + d).Prime) :
    ArbitrarilyLargePrimePairs d := by
  intro N
  obtain ⟨n, hn, hp, hpd⟩ := h N
  exact ⟨n, n + d, hp, hpd, hn, Nat.lt_add_of_pos_right hd, le_rfl⟩

end TwinPrimeGaps