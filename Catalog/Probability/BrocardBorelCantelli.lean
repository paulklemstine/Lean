/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Brocard's Problem through a Probabilistic (Borel–Cantelli) Lens

Brocard's problem asks for which `n` the equation `n! + 1 = m²` has a solution.
The known solutions are `n = 4, 5, 7` (the *Brown numbers*), and it is a famous
open conjecture that there are no others.

This file approaches the problem from the **Probability** domain.  The standard
heuristic for why only finitely many Brown numbers are expected is a
*Borel–Cantelli* argument: the "probability" that a number near `n!` is a perfect
square has order `1 / √(n!)`, and `∑ₙ 1/√(n!) < ∞`, so a Borel–Cantelli model
predicts that only finitely many `n` can satisfy the equation.

We make this heuristic completely rigorous as an abstract probability statement
(`brocard_heuristic_finite` / `brocard_heuristic_ae_finite`), and we supplement it
with the elementary number theory of the equation and an exhaustive finite
verification.

-- !-- Lab Notes -- !--
Hypotheses explored in this cycle:
  (H1)  The Brocard density heuristic `∑ 1/√(n!)` converges.            [PROVED]
  (H2)  Convergence + Borel–Cantelli ⇒ a.s. finitely many "hits".       [PROVED]
  (H3)  No Brown numbers below 1000 other than {4,5,7}.                 [PROVED, native_decide]
  (H4)  Structural constraints: m odd, (m-1)(m+1) = n!.                 [PROVED]
  (H5)  Wilson obstruction: if n = p-1 is prime, then p ∣ m (so m ≥ p). [PROVED]
Failure analysis / dead ends:
  * Trying `Summable.of_nonneg_of_le` with the geometric series stated as
    `(√2)⁻¹ ^ n * √2` confused unification (the comparison function must be the
    SECOND explicit argument, the dominating series).  Fixed by dominating with
    `fun n => (2 : ℝ)⁻¹ ^ (n/... )`-style bound; ultimately the clean route is
    `n! ≥ 2^(n-1)` ⇒ `1/√(n!) ≤ √2 · (√2)⁻¹ ^ n`, a geometric comparison.
  * `native_decide` scales fine to range 1000 even though 1000! has ~2568 digits,
    because `Nat.sqrt` is logarithmic in the number of bignum multiplications.
Insight:
  The probabilistic finiteness is *unconditional* as an abstract measure
  statement; the only non-rigorous step in the real heuristic is the modelling
  assumption `μ(Eₙ) ≲ 1/√(n!)`, which we expose explicitly as a hypothesis.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open scoped BigOperators
open MeasureTheory Filter

namespace BrocardBorelCantelli

/-! ## A decidable perfect-square test -/

/-- Boolean perfect-square test, used for exhaustive finite verification. -/
def isPerfectSquareB (n : ℕ) : Bool := Nat.sqrt n * Nat.sqrt n == n

/-! ## Section 1 — The three known Brown numbers -/

/-- `4! + 1 = 5²`. -/
theorem brown_four : Nat.factorial 4 + 1 = 5 ^ 2 := by decide

/-- `5! + 1 = 11²`. -/
theorem brown_five : Nat.factorial 5 + 1 = 11 ^ 2 := by decide

/-- `7! + 1 = 71²`. -/
theorem brown_seven : Nat.factorial 7 + 1 = 71 ^ 2 := by decide

/-! ## Section 2 — Exhaustive finite verification -/

/-- There are no Brown numbers below `1000` other than `4, 5, 7`. -/
theorem brocard_no_others_below_1000 :
    (List.range 1000).filter (fun n => isPerfectSquareB (Nat.factorial n + 1)) = [4, 5, 7] := by
  native_decide

/-! ## Section 3 — Elementary structural constraints -/

/-
For `n ≥ 2`, any solution of Brocard's equation has `m` odd.
-/
theorem brocard_m_odd {n m : ℕ} (hn : 2 ≤ n) (h : Nat.factorial n + 1 = m ^ 2) :
    Odd m := by
  by_contra h_even_m;
  replace h := congr_arg ( · % 4 ) h; rcases Nat.even_or_odd' m with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mod_eq_zero_of_dvd ( Nat.dvd_factorial ( by decide ) ( show 4 ≤ n by contrapose! h_even_m; interval_cases n <;> norm_num at * ) ) ] at *;

/-
The Brocard equation factors as `(m-1)(m+1) = n!`.
-/
theorem brocard_factor {n m : ℕ} (hm : 1 ≤ m) (h : Nat.factorial n + 1 = m ^ 2) :
    (m - 1) * (m + 1) = Nat.factorial n := by
  cases m <;> norm_num at * ; linarith

/-
**Wilson obstruction.** If `p` is prime and `n = p - 1` is a Brown number,
then `p ∣ m`.  Indeed Wilson's theorem gives `(p-1)! ≡ -1 (mod p)`, so
`p ∣ (p-1)! + 1 = m²`, and primality forces `p ∣ m`.  In particular `m ≥ p`.
-/
theorem brocard_wilson_dvd {p m : ℕ} (hp : p.Prime)
    (h : Nat.factorial (p - 1) + 1 = m ^ 2) : p ∣ m := by
  -- By Wilson's theorem, we have $p \mid (p - 1)! + 1$.
  have h_wilson : p ∣ (p - 1).factorial + 1 := by
    haveI := Fact.mk hp; simp +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  exact hp.dvd_of_dvd_pow <| h ▸ h_wilson

/-
Consequence of the Wilson obstruction: in a Brown solution with `n = p - 1`
prime, the root `m` is at least `p`.
-/
theorem brocard_wilson_ge {p m : ℕ} (hp : p.Prime)
    (h : Nat.factorial (p - 1) + 1 = m ^ 2) : p ≤ m := by
  -- Also $m \mid (p-1)!$. Otherwise, $m$ is coprime to $(p-1)!$.
  have h_dvd : p ∣ m := by
    exact brocard_wilson_dvd hp h
  exact Nat.le_of_dvd (Nat.pos_of_ne_zero (by
  nlinarith [ Nat.factorial_pos ( p - 1 ) ])) h_dvd

/-! ## Section 4 — The analytic heart: convergence of the density heuristic -/

/-
The Brocard density heuristic `∑ₙ 1/√(n!)` converges.  This is the analytic
fact powering the probabilistic finiteness argument: the chance that a number of
size `n!` is a perfect square is of order `1/√(n!)`, and these chances sum.
-/
theorem summable_inv_sqrt_factorial :
    Summable (fun n : ℕ => 1 / Real.sqrt (Nat.factorial n)) := by
  refine' summable_of_ratio_norm_eventually_le _ _;
  exact 2 / 3;
  · norm_num;
  · norm_num [ Nat.factorial_succ ];
    exact ⟨ 8, fun n hn => by rw [ abs_of_nonneg ( Real.sqrt_nonneg _ ), abs_of_nonneg ( Real.sqrt_nonneg _ ) ] ; rw [ mul_comm ] ; exact mul_le_mul_of_nonneg_right ( by rw [ inv_le_comm₀ ] <;> norm_num <;> nlinarith [ Real.sqrt_nonneg ( n + 1 : ℝ ), Real.sq_sqrt ( show 0 ≤ ( n:ℝ ) + 1 by positivity ), show ( n:ℝ ) ≥ 8 by norm_cast ] ) ( by positivity ) ⟩

/-
Scaled version: for any constant `C`, `∑ₙ C/√(n!)` converges.
-/
theorem summable_const_div_sqrt_factorial (C : ℝ) :
    Summable (fun n : ℕ => C / Real.sqrt (Nat.factorial n)) := by
  simpa using Summable.mul_left _ ( summable_inv_sqrt_factorial )

/-
In `ℝ≥0∞`, the heuristic sum is finite.
-/
theorem tsum_ofReal_heuristic_ne_top (C : ℝ) (hC : 0 ≤ C) :
    (∑' n : ℕ, ENNReal.ofReal (C / Real.sqrt (Nat.factorial n))) ≠ ⊤ := by
  rw [ ← ENNReal.ofReal_tsum_of_nonneg ];
  · exact ENNReal.ofReal_ne_top;
  · exact fun n => by positivity;
  · convert summable_const_div_sqrt_factorial C using 1

/-! ## Section 5 — The probabilistic finiteness theorem (Borel–Cantelli) -/

/-
**Brocard–Borel–Cantelli (main probabilistic theorem).**
Work in an arbitrary outer-measure / probability space `μ`.  Model the event
`Eₙ = "n! + 1 is a perfect square"` by an arbitrary family of sets whose measures
obey the Brocard density bound `μ(Eₙ) ≤ C/√(n!)`.  Then the set of points that lie
in infinitely many `Eₙ` is null.  In probabilistic terms: almost surely only
finitely many of the events occur.
-/
theorem brocard_heuristic_finite
    {α : Type*} {F : Type*} [FunLike F (Set α) ENNReal] [OuterMeasureClass F α]
    {μ : F} (E : ℕ → Set α) (C : ℝ) (hC : 0 ≤ C)
    (hbound : ∀ n, μ (E n) ≤ ENNReal.ofReal (C / Real.sqrt (Nat.factorial n))) :
    μ {x | ∃ᶠ n in atTop, x ∈ E n} = 0 := by
  convert MeasureTheory.measure_setOf_frequently_eq_zero _;
  · infer_instance;
  · exact ne_of_lt ( lt_of_le_of_lt ( ENNReal.tsum_le_tsum hbound ) ( by exact lt_top_iff_ne_top.mpr ( tsum_ofReal_heuristic_ne_top C hC ) ) )

/-
Probabilistic restatement: under the Brocard density bound, almost every point
belongs to only finitely many of the events `Eₙ`.
-/
theorem brocard_heuristic_ae_finite
    {α : Type*} {F : Type*} [FunLike F (Set α) ENNReal] [OuterMeasureClass F α]
    {μ : F} (E : ℕ → Set α) (C : ℝ) (hC : 0 ≤ C)
    (hbound : ∀ n, μ (E n) ≤ ENNReal.ofReal (C / Real.sqrt (Nat.factorial n))) :
    ∀ᵐ x ∂μ, {n | x ∈ E n}.Finite := by
  convert MeasureTheory.ae_finite_setOf_mem ( show ∑' n : ℕ, μ (E n) ≠ ⊤ from ?_ );
  exact ne_of_lt ( lt_of_le_of_lt ( ENNReal.tsum_le_tsum hbound ) ( tsum_ofReal_heuristic_ne_top C hC |> lt_top_iff_ne_top.mpr ) )

end BrocardBorelCantelli