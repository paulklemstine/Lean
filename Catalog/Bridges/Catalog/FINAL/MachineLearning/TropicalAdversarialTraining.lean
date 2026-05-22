import Mathlib

/-!
# Adversarial Training as Tropical Regularization

This file proves that adversarial robust training with hinge loss decomposes exactly
into empirical risk minimization plus a tropical (min-plus) penalty.

## Main Results

* `hingeLoss_shift_eq` — algebraic core: `hingeLoss(m - δ) = hingeLoss(m) + max(0, δ - marginSurplus(m))`
* `adversarial_eq_tropical` — **Theorem A**: shifted risk = empirical risk + tropical penalty
* `certified_radius_robust` — **Theorem B**: within certified radius, margin stays positive
* `advDist_ge_margin_div_L` — distance-to-adversary ≥ margin/L
* `certifiedRadius_is_idempotent` — certified radius satisfies robustness predicate

## Mathematical Context

For an L-Lipschitz score function f with ±1 labels, the worst-case margin under
ε-perturbation degrades by at most Lε. For hinge loss `ℓ(z) = max(0, 1-z)`, the
shifted loss decomposes as:

  `ℓ(m - δ) = ℓ(m) + max(0, δ - max(0, m - 1))`

where `max(0, m - 1)` is the "margin surplus" — the amount by which the margin
exceeds the hinge threshold. The tropical penalty kicks in precisely when the
perturbation budget `δ = Lε` exceeds this surplus.
-/

open Finset BigOperators

noncomputable section

namespace TropAdvTraining

/-! ## Hinge Loss and Margin Surplus -/

/-- Hinge loss: `max 0 (1 - z)`. -/
def hingeLoss (z : ℝ) : ℝ := max 0 (1 - z)

/-- Margin surplus beyond the hinge threshold: `max 0 (z - 1)`. -/
def marginSurplus (z : ℝ) : ℝ := max 0 (z - 1)

theorem hingeLoss_nonneg (z : ℝ) : 0 ≤ hingeLoss z := le_max_left 0 (1 - z)

theorem marginSurplus_nonneg (z : ℝ) : 0 ≤ marginSurplus z := le_max_left 0 (z - 1)

theorem hingeLoss_antitone : Antitone hingeLoss :=
  fun _ _ h => max_le_max_left 0 (sub_le_sub_left h 1)

theorem hingeLoss_of_le_one {z : ℝ} (h : z ≤ 1) : hingeLoss z = 1 - z :=
  max_eq_right (sub_nonneg.mpr h)

theorem hingeLoss_of_one_le {z : ℝ} (h : 1 ≤ z) : hingeLoss z = 0 :=
  max_eq_left (sub_nonpos.mpr h)

theorem marginSurplus_of_le_one {z : ℝ} (h : z ≤ 1) : marginSurplus z = 0 :=
  max_eq_left (sub_nonpos.mpr h)

theorem marginSurplus_of_one_le {z : ℝ} (h : 1 ≤ z) : marginSurplus z = z - 1 :=
  max_eq_right (sub_nonneg.mpr h)

/-! ## The Core Algebraic Identity -/

/-
**Key algebraic identity for tropical regularization:**
    `hingeLoss(m - δ) = hingeLoss(m) + max(0, δ - marginSurplus(m))`
    where `marginSurplus(m) = max(0, m - 1)`.

    This decomposes the robust loss (hinge at shifted margin) into the
    empirical loss plus a tropical penalty. The penalty activates when the
    perturbation budget `δ` exceeds the margin surplus.
-/
theorem hingeLoss_shift_eq (m δ : ℝ) (hδ : 0 ≤ δ) :
    hingeLoss (m - δ) = hingeLoss m + max 0 (δ - marginSurplus m) := by
  unfold hingeLoss marginSurplus;
  cases max_cases ( 0 : ℝ ) ( 1 - m ) <;> cases max_cases ( 0 : ℝ ) ( m - 1 ) <;> cases max_cases ( 0 : ℝ ) ( δ - max 0 ( m - 1 ) ) <;> cases max_cases ( 0 : ℝ ) ( 1 - ( m - δ ) ) <;> linarith

/-! ## Abstract Definitions -/

/-- Empirical hinge risk: `∑ hingeLoss(mᵢ)`. -/
def empHingeRisk (S : Finset ι) (m : ι → ℝ) : ℝ :=
  ∑ i ∈ S, hingeLoss (m i)

/-- Tropical penalty: `∑ max(0, τ - marginSurplus(mᵢ))`. -/
def tropPenalty (S : Finset ι) (m : ι → ℝ) (τ : ℝ) : ℝ :=
  ∑ i ∈ S, max 0 (τ - marginSurplus (m i))

/-- Shifted (robust) hinge risk: `∑ hingeLoss(mᵢ - δ)`. -/
def shiftedHingeRisk (S : Finset ι) (m : ι → ℝ) (δ : ℝ) : ℝ :=
  ∑ i ∈ S, hingeLoss (m i - δ)

/-! ## Theorem A: The Tropical Regularization Identity -/

/-- **Theorem A (Adversarial Training = Tropical Regularization).**
    The shifted hinge risk decomposes exactly as empirical risk + tropical penalty. -/
theorem adversarial_eq_tropical
    (S : Finset ι) (m : ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ) :
    shiftedHingeRisk S m δ = empHingeRisk S m + tropPenalty S m δ := by
  simp only [shiftedHingeRisk, empHingeRisk, tropPenalty]
  rw [← Finset.sum_add_distrib]
  congr 1; ext i
  exact hingeLoss_shift_eq (m i) δ hδ

/-! ## Metric Space Theorems -/

variable {X : Type*} [PseudoMetricSpace X]

/-- Fixed-label margin: `yval * f(x)` where `yval ∈ {-1, 1}`. -/
def fixedMargin (yval : ℝ) (f : X → ℝ) (x : X) : ℝ := yval * f x

/-- Lipschitz bound on fixed-label margin degradation. -/
theorem fixedMargin_lipschitz
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x x' : X) :
    fixedMargin yval f x - fixedMargin yval f x' ≤ L * dist x x' := by
  simp only [fixedMargin]
  rcases hyval with rfl | rfl
  · simp only [one_mul]; linarith [abs_le.mp (hLip x x')]
  · simp only [neg_one_mul, neg_sub_neg]; linarith [abs_le.mp (hLip x x')]

/-- Robust hinge loss bound: for L-Lipschitz f, worst-case loss ≤ shifted loss. -/
theorem robust_hingeLoss_bound
    (yval : ℝ) (f : X → ℝ) (L ε : ℝ) (hL : 0 ≤ L)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x x' : X) (hx' : dist x x' ≤ ε) :
    hingeLoss (fixedMargin yval f x') ≤ hingeLoss (fixedMargin yval f x - L * ε) := by
  apply hingeLoss_antitone
  linarith [fixedMargin_lipschitz yval f L hyval hLip x x', mul_le_mul_of_nonneg_left hx' hL]

/-- **Theorem B (Certified Radius).** Within distance `margin/L`, margin stays positive. -/
theorem certified_radius_robust
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hL : 0 < L)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x : X) (_hm : 0 < fixedMargin yval f x)
    (x' : X) (hx' : dist x x' < fixedMargin yval f x / L) :
    0 < fixedMargin yval f x' := by
  have h1 := fixedMargin_lipschitz yval f L hyval hLip x x'
  have h2 : dist x x' * L < fixedMargin yval f x := (lt_div_iff₀ hL).mp hx'
  linarith [mul_comm L (dist x x')]

/-- Distance to adversary ≥ margin/L. -/
theorem advDist_ge_margin_div_L
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hL : 0 < L)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x x' : X) (_hm : 0 < fixedMargin yval f x)
    (hflip : fixedMargin yval f x' ≤ 0) :
    fixedMargin yval f x / L ≤ dist x x' := by
  rw [div_le_iff₀ hL]
  linarith [fixedMargin_lipschitz yval f L hyval hLip x x']

/-! ## Robustness Predicate and Idempotent Closure -/

/-- Robustness predicate: margin stays positive within radius `r`. -/
def RobustAt (yval : ℝ) (f : X → ℝ) (x : X) (r : ℝ) : Prop :=
  ∀ x', dist x x' < r → 0 < fixedMargin yval f x'

/-- The certified radius `margin/L` satisfies the robustness predicate. -/
theorem certifiedRadius_is_idempotent
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hL : 0 < L)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x : X) (hm : 0 < fixedMargin yval f x) :
    RobustAt yval f x (fixedMargin yval f x / L) :=
  fun x' hx' => certified_radius_robust yval f L hL hyval hLip x hm x' hx'

omit [PseudoMetricSpace X] in
/-- The certified radius is nonneg when margin is positive. -/
theorem certifiedRadius_nonneg
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hL : 0 < L) (x : X) (hm : 0 < fixedMargin yval f x) :
    0 ≤ fixedMargin yval f x / L := div_nonneg (le_of_lt hm) (le_of_lt hL)

omit [PseudoMetricSpace X] in
/-- Certified radius is positive when margin is positive. -/
theorem certifiedRadius_pos
    (yval : ℝ) (f : X → ℝ) (L : ℝ)
    (hL : 0 < L) (x : X) (hm : 0 < fixedMargin yval f x) :
    0 < fixedMargin yval f x / L := div_pos hm hL

/-! ## Tropical Penalty Properties -/

omit [PseudoMetricSpace X] in
/-- Tropical penalty is monotone in `τ`. -/
theorem tropPenalty_mono (S : Finset ι) (m : ι → ℝ) {τ₁ τ₂ : ℝ} (h : τ₁ ≤ τ₂) :
    tropPenalty S m τ₁ ≤ tropPenalty S m τ₂ :=
  Finset.sum_le_sum fun _ _ => max_le_max_left 0 (sub_le_sub_right h _)

omit [PseudoMetricSpace X] in
/-- Tropical penalty is nonneg. -/
theorem tropPenalty_nonneg (S : Finset ι) (m : ι → ℝ) (τ : ℝ) :
    0 ≤ tropPenalty S m τ := Finset.sum_nonneg fun _ _ => le_max_left 0 _

omit [PseudoMetricSpace X] in
/-- Tropical penalty vanishes when perturbation budget ≤ all margin surpluses. -/
theorem tropPenalty_zero_of_le (S : Finset ι) (m : ι → ℝ) (τ : ℝ)
    (h : ∀ i ∈ S, τ ≤ marginSurplus (m i)) :
    tropPenalty S m τ = 0 :=
  Finset.sum_eq_zero fun i hi => max_eq_left (sub_nonpos.mpr (h i hi))

/-! ## Dataset-level Theorems -/

omit [PseudoMetricSpace X] in
/-- **Dataset Theorem A.** Robust dataset risk = empirical risk + tropical penalty. -/
theorem dataset_adversarial_eq_tropical
    (S : Finset X) (yvals : X → ℝ) (f : X → ℝ) (L ε : ℝ)
    (hL : 0 ≤ L) (hε : 0 ≤ ε) :
    (∑ x ∈ S, hingeLoss (fixedMargin (yvals x) f x - L * ε)) =
    (∑ x ∈ S, hingeLoss (fixedMargin (yvals x) f x)) +
    (∑ x ∈ S, max 0 (L * ε - marginSurplus (fixedMargin (yvals x) f x))) := by
  rw [← Finset.sum_add_distrib]
  congr 1; ext x
  exact hingeLoss_shift_eq _ _ (mul_nonneg hL hε)

omit [PseudoMetricSpace X] in
/-- Robust risk ≥ empirical risk. -/
theorem robustRisk_ge_empRisk
    (S : Finset X) (yvals : X → ℝ) (f : X → ℝ) (L ε : ℝ)
    (hL : 0 ≤ L) (hε : 0 ≤ ε) :
    (∑ x ∈ S, hingeLoss (fixedMargin (yvals x) f x)) ≤
    (∑ x ∈ S, hingeLoss (fixedMargin (yvals x) f x - L * ε)) :=
  Finset.sum_le_sum fun x _ => hingeLoss_antitone (by linarith [mul_nonneg hL hε])

omit [PseudoMetricSpace X] in
/-- Large margins kill robust risk. -/
theorem robustRisk_zero_of_large_margin
    (S : Finset X) (yvals : X → ℝ) (f : X → ℝ) (L ε : ℝ)
    (hmargin : ∀ x ∈ S, 1 + L * ε ≤ fixedMargin (yvals x) f x) :
    (∑ x ∈ S, hingeLoss (fixedMargin (yvals x) f x - L * ε)) = 0 :=
  Finset.sum_eq_zero fun x hx => hingeLoss_of_one_le (by linarith [hmargin x hx])

/-- **Pointwise adversarial bound.** Robust loss ≤ tropical-decomposed bound. -/
theorem pointwise_adversarial_tropical_bound
    (yval : ℝ) (f : X → ℝ) (L ε : ℝ)
    (hL : 0 ≤ L) (hε : 0 ≤ ε)
    (hyval : yval = 1 ∨ yval = -1)
    (hLip : ∀ x x', |f x - f x'| ≤ L * dist x x')
    (x x' : X) (hx' : dist x x' ≤ ε) :
    hingeLoss (fixedMargin yval f x') ≤
      hingeLoss (fixedMargin yval f x) +
      max 0 (L * ε - marginSurplus (fixedMargin yval f x)) := by
  rw [← hingeLoss_shift_eq _ _ (mul_nonneg hL hε)]
  exact robust_hingeLoss_bound yval f L ε hL hyval hLip x x' hx'

end TropAdvTraining