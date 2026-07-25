/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Empirical Rademacher Complexity of Finite Hypothesis Classes

This file formalizes the **empirical Rademacher complexity** of a finite hypothesis
class, represented by the *behavior of each hypothesis on the sample*: a hypothesis
is identified with the vector `(f(x₁), …, f(xₙ)) : Fin n → ℝ` of its values on the
`n` sample points.  The empirical Rademacher complexity is the average, over all
`2ⁿ` sign patterns `σ ∈ {±1}ⁿ`, of the best (sup) correlation between a sign pattern
and a hypothesis:

  `empRad F = (1/(2ⁿ · n)) · Σ_σ  sup_{v ∈ F}  Σᵢ σᵢ · vᵢ`.

This is exactly the empirical Rademacher complexity used in statistical learning
theory; the finite-behavior representation makes it fully rigorous and computable.

This extends the algebraic-learning-theory development in
`Catalog/MachineLearning/Foundations.lean`, which discusses Rademacher complexity
abstractly but does not pin down the empirical quantity itself.

## Main results

* `signSum_coord_eq_zero`  — for each coordinate the signs cancel over all patterns.
* `empRad_singleton`       — a *single* hypothesis has empirical Rademacher complexity 0.
* `empRad_nonneg`          — if `0 ∈ F` the complexity is nonnegative.
* `empRad_mono`            — monotone in the hypothesis class.
* `empRad_le_of_bounded`   — the trivial uniform upper bound `empRad F ≤ B`.

A finite-class (Massart) refinement is stated as a `conjecture` with `sorry`.
-/
import Mathlib

open Finset

namespace RademacherSpectral

variable {n : ℕ}

/-- The Rademacher sign of a boolean: `true ↦ +1`, `false ↦ -1`. -/
def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] lemma sgn_true : sgn true = 1 := rfl
@[simp] lemma sgn_false : sgn false = -1 := rfl

lemma sgn_not (b : Bool) : sgn (!b) = - sgn b := by cases b <;> simp [sgn]

lemma abs_sgn (b : Bool) : |sgn b| = 1 := by cases b <;> simp [sgn]

/-- Correlation of a sign pattern `σ` with a behavior vector `v`. -/
def corr (σ : Fin n → Bool) (v : Fin n → ℝ) : ℝ := ∑ i, sgn (σ i) * v i

/-- **Empirical Rademacher complexity** of a nonempty finite hypothesis class `F`,
where each hypothesis is represented by its vector of values on the `n` sample points. -/
noncomputable def empRad (F : Finset (Fin n → ℝ)) (hF : F.Nonempty) : ℝ :=
  (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v)) / (2 ^ n * n)

-- !-- Lab Notebook: signSum_coord_eq_zero -- !--
-- !-- Hypothesis: Summing the Rademacher sign at a fixed coordinate over all 2ⁿ patterns cancels. -- !--
-- !-- Result: Proved by the coordinate-flip involution σ ↦ update σ i (!σ i). -- !--
-- !-- Insight: Equiv.sum_comp over an involution forces S = -S, hence S = 0; this is the seed of every cancellation in the theory. -- !--
-- !-- Failure analysis: Direct sum_nbij' bookkeeping failed; packaging the flip as Function.Involutive.toPerm was the clean route. -- !--
-- !-- End Lab Notebook -- !--

-- !-- For each coordinate `i`, the signs `σ i` sum to zero over all sign patterns,
-- !-- via the involution flipping coordinate `i`. -- !--
/-- The signs at a fixed coordinate cancel when summed over all `2ⁿ` patterns. -/
lemma signSum_coord_eq_zero (i : Fin n) :
    ∑ σ : Fin n → Bool, sgn (σ i) = 0 := by
  have hinv : Function.Involutive (fun σ : Fin n → Bool => Function.update σ i (!(σ i))) := by
    intro σ; funext j; by_cases h : j = i <;> simp [Function.update, h]
  set e := Function.Involutive.toPerm _ hinv with he
  have hcomp : ∑ σ : Fin n → Bool, sgn ((e σ) i) = ∑ σ : Fin n → Bool, sgn (σ i) :=
    Equiv.sum_comp e (fun σ => sgn (σ i))
  have hval : ∀ σ : Fin n → Bool, sgn ((e σ) i) = - sgn (σ i) := by
    intro σ
    have hev : e σ = Function.update σ i (!(σ i)) := by rw [he]; rfl
    rw [hev]
    have : (Function.update σ i (!(σ i))) i = !(σ i) := by simp
    rw [this, sgn_not]
  rw [Finset.sum_congr rfl (fun σ _ => hval σ), Finset.sum_neg_distrib] at hcomp
  linarith [hcomp]

-- !-- Lab Notebook: empRad_singleton -- !--
-- !-- Hypothesis: One fixed hypothesis carries no Rademacher complexity (it cannot fit random noise on average). -- !--
-- !-- Result: Proved; numerator is Σ_σ Σ_i σ_i v_i = Σ_i v_i (Σ_σ σ_i) = 0 by signSum_coord_eq_zero. -- !--
-- !-- Insight: Empirical Rademacher complexity measures *richness of the class*, not of any single function; the singleton is the base case. -- !--
-- !-- Failure analysis: Needed Finset.sum_comm to move the σ-sum inside before applying the coordinate cancellation. -- !--
-- !-- End Lab Notebook -- !--

-- !-- sup' over a singleton is the value itself; swap the σ and i sums and apply
-- !-- signSum_coord_eq_zero coordinatewise. -- !--
/-- A single hypothesis has empirical Rademacher complexity exactly `0`. -/
theorem empRad_singleton (v : Fin n → ℝ) :
    empRad ({v} : Finset (Fin n → ℝ)) (singleton_nonempty v) = 0 := by
  unfold empRad
  have hnum : (∑ σ : Fin n → Bool,
      ({v} : Finset (Fin n → ℝ)).sup' (singleton_nonempty v) (fun w => corr σ w)) = 0 := by
    have : ∀ σ : Fin n → Bool,
        ({v} : Finset (Fin n → ℝ)).sup' (singleton_nonempty v) (fun w => corr σ w) = corr σ v := by
      intro σ; simp [Finset.sup'_singleton]
    rw [Finset.sum_congr rfl (fun σ _ => this σ)]
    unfold corr
    rw [Finset.sum_comm]
    have : ∀ i : Fin n, (∑ σ : Fin n → Bool, sgn (σ i) * v i) = 0 := by
      intro i
      rw [← Finset.sum_mul, signSum_coord_eq_zero i, zero_mul]
    rw [Finset.sum_congr rfl (fun i _ => this i), Finset.sum_const_zero]
  rw [hnum, zero_div]

-- !-- Lab Notebook: empRad_nonneg -- !--
-- !-- Hypothesis: A class containing the zero hypothesis has nonnegative empirical Rademacher complexity. -- !--
-- !-- Result: Proved; each sup' dominates the value at 0, which is 0, so the numerator and the nonneg denominator give the bound. -- !--
-- !-- Insight: Nonnegativity is a *containment* property, not automatic; it needs a witness (here 0 ∈ F). -- !--
-- !-- Failure analysis: Care with n = 0 where the denominator vanishes — div_nonneg still applies. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Each σ-term is ≥ corr σ 0 = 0 by le_sup'; sum and divide by the nonneg denom. -- !--
/-- If the zero hypothesis is in the class, the empirical Rademacher complexity is `≥ 0`. -/
theorem empRad_nonneg (F : Finset (Fin n → ℝ)) (hF : F.Nonempty)
    (h0 : (0 : Fin n → ℝ) ∈ F) : 0 ≤ empRad F hF := by
  unfold empRad
  apply div_nonneg
  · apply Finset.sum_nonneg
    intro σ _
    have hle : corr σ (0 : Fin n → ℝ) ≤ F.sup' hF (fun v => corr σ v) :=
      Finset.le_sup' (fun v => corr σ v) h0
    have : corr σ (0 : Fin n → ℝ) = 0 := by simp [corr]
    rw [this] at hle; exact hle
  · positivity

-- !-- Lab Notebook: empRad_mono -- !--
-- !-- Hypothesis: A richer hypothesis class has at least as much empirical Rademacher complexity. -- !--
-- !-- Result: Proved via Finset.sup'_mono pointwise in σ, then sum monotonicity and division by a nonneg denominator. -- !--
-- !-- Insight: Monotonicity is the structural backbone that lets one bound complex classes by simple supersets. -- !--
-- !-- Failure analysis: gcongr discharges the division step including the 0 ≤ denominator side goal. -- !--
-- !-- End Lab Notebook -- !--

-- !-- sup' is monotone in the Finset (Finset.sup'_mono); sum and divide. -- !--
/-- Empirical Rademacher complexity is monotone under class inclusion. -/
theorem empRad_mono (F G : Finset (Fin n → ℝ)) (hF : F.Nonempty) (hG : G.Nonempty)
    (hsub : F ⊆ G) : empRad F hF ≤ empRad G hG := by
  unfold empRad
  have hnum : (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v))
      ≤ ∑ σ : Fin n → Bool, G.sup' hG (fun v => corr σ v) := by
    apply Finset.sum_le_sum
    intro σ _
    exact Finset.sup'_mono (fun v => corr σ v) hsub hF
  gcongr

-- !-- Lab Notebook: empRad_le_of_bounded -- !--
-- !-- Hypothesis: If every hypothesis is uniformly bounded by B in each coordinate, the complexity is ≤ B. -- !--
-- !-- Result: Proved; corr σ v ≤ Σ|vᵢ| ≤ nB pointwise, so each sup' ≤ nB, the numerator ≤ 2ⁿ·nB, and dividing gives B. -- !--
-- !-- Insight: This is the trivial uniform bound that the finite-class (Massart) refinement must beat by a √(log|F|) factor. -- !--
-- !-- Failure analysis: n = 0 collapses the denominator; handled because the numerator is then 0 and 0 ≤ B. -- !--
-- !-- End Lab Notebook -- !--

-- !-- corr σ v ≤ Σ_i |v i| ≤ n·B by abs_sgn and the bound; bound each sup' by n·B,
-- !-- so the sum is ≤ 2ⁿ·n·B and the quotient is ≤ B (n = 0 handled separately). -- !--
/-- The trivial uniform upper bound: a class bounded by `B` in every coordinate has
empirical Rademacher complexity at most `B`. -/
theorem empRad_le_of_bounded (F : Finset (Fin n → ℝ)) (hF : F.Nonempty)
    {B : ℝ} (hB : 0 ≤ B) (hbd : ∀ v ∈ F, ∀ i, |v i| ≤ B) :
    empRad F hF ≤ B := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    unfold empRad
    have : ∀ σ : Fin 0 → Bool,
        F.sup' hF (fun v => corr σ v) = 0 := by
      intro σ; simp [corr]
    simp [this]
    positivity
  · unfold empRad
    have hsupbd : ∀ σ : Fin n → Bool,
        F.sup' hF (fun v => corr σ v) ≤ (n : ℝ) * B := by
      intro σ
      apply Finset.sup'_le
      intro v hv
      have hco : corr σ v ≤ ∑ i, |v i| := by
        unfold corr
        apply Finset.sum_le_sum
        intro i _
        calc sgn (σ i) * v i ≤ |sgn (σ i) * v i| := le_abs_self _
          _ = |v i| := by rw [abs_mul, abs_sgn, one_mul]
      have hsum : (∑ i, |v i|) ≤ (n : ℝ) * B := by
        calc (∑ i : Fin n, |v i|) ≤ ∑ _i : Fin n, B :=
              Finset.sum_le_sum (fun i _ => hbd v hv i)
          _ = (n : ℝ) * B := by rw [Finset.sum_const]; simp [mul_comm]
      exact hco.trans hsum
    have hnum : (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v))
        ≤ (2 ^ n : ℝ) * ((n : ℝ) * B) := by
      calc (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v))
            ≤ ∑ _σ : Fin n → Bool, (n : ℝ) * B :=
            Finset.sum_le_sum (fun σ _ => hsupbd σ)
        _ = (2 ^ n : ℝ) * ((n : ℝ) * B) := by
            rw [Finset.sum_const]
            simp [mul_comm, mul_assoc]
    have hden : (0 : ℝ) < 2 ^ n * n := by positivity
    rw [div_le_iff₀ hden]
    calc (∑ σ : Fin n → Bool, F.sup' hF (fun v => corr σ v))
          ≤ (2 ^ n : ℝ) * ((n : ℝ) * B) := hnum
      _ = B * (2 ^ n * n) := by ring

/-- **Massart finite-class refinement (conjecture).**  For a finite class bounded by `B`
in each coordinate, the empirical Rademacher complexity is bounded by
`B · √(2 · log |F| / n)`, which beats the trivial bound `empRad_le_of_bounded` by a
`√(log |F| / n)` factor.  Stated here as a conjecture; the proof requires a
sub-Gaussian/MGF (Hoeffding) argument not yet formalized in this file. -/
theorem empRad_massart_conjecture (F : Finset (Fin n → ℝ)) (hF : F.Nonempty)
    {B : ℝ} (hB : 0 ≤ B) (hn : 0 < n) (hbd : ∀ v ∈ F, ∀ i, |v i| ≤ B) :
    empRad F hF ≤ B * Real.sqrt (2 * Real.log (F.card) / n) := by
  sorry

end RademacherSpectral