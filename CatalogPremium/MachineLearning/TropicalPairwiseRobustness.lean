import Mathlib

/-!
# Tropical Certified Robustness via Monotone Min-Margin Score Aggregation

This file formalizes a compositional robustness theorem for multiclass
piecewise-linear/tropical networks. Certification is mediated by aggregated
pairwise class margins rather than by direct aggregation of logits.

## Mathematical Overview

For a classifier `f : (Fin d → ℝ) → Fin C → ℝ` producing logits over `C` classes,
and a predicted class `y`, the **margin vector** is

  `marginVec f y x = fun j => f x y - f x j`

An **aggregator** `Φ : Fin C → (Fin C → ℝ) → ℝ` combines these pairwise margins
(parameterized by the predicted class `y`) into a single certificate score.
The `y`-parameter lets the aggregator know which coordinate is the diagonal
(always zero) and should be excluded or treated specially.

We require:
1. **1-Lipschitz** w.r.t. `ℓ∞`: `|Φ y u - Φ y v| ≤ sup_i |u_i - v_i|`.
2. **Positivity propagation**: `Φ y v > 0 → ∀ j ≠ y, v j > 0`.

The main theorem shows that if `Φ y (marginVec f y x₀) > 2 K d ε`, then for
all `x` with `‖x - x₀‖ ≤ ε`, class `y` strictly beats all competitors.

## Main Results

* `robust_of_pairwise_aggregated_margin` — abstract bridge theorem
* `top1_stable_of_pairwise_aggregated_margin` — weak argmax corollary
* `aggregated_margin_lower_bound_under_perturbation` — certificate stability
* `positivity_from_min_domination` — min-domination implies positivity propagation
* `robust_of_pairwise_aggregated_margin_of_min_domination` — theorem using DominatesMin
* `robust_of_min_pairwise_margin` — specialization to `Φ = offDiagMin`
* `offDiagMin_lipschitz_one` — the off-diagonal min is 1-Lipschitz in ℓ∞

## References

The tropical approach to certified robustness originates in the analysis of ReLU
networks as tropical rational maps. This formalization extends the program to
arbitrary monotone 1-Lipschitz aggregators over pairwise margins.
-/

noncomputable section

open Finset

/-! ## Utility Lemmas -/

private lemma fin_univ_nonempty {C : ℕ} (hC : 0 < C) :
    (univ : Finset (Fin C)).Nonempty := by
  rwa [univ_nonempty_iff, ← Fin.pos_iff_nonempty]

private lemma filter_ne_nonempty {C : ℕ} (hC : 2 ≤ C) (y : Fin C) :
    ((univ : Finset (Fin C)).filter (· ≠ y)).Nonempty := by
  simp [filter_nonempty_iff]
  haveI : Nontrivial (Fin C) := by rw [Fin.nontrivial_iff_two_le]; exact hC
  exact exists_ne y

/-! ## Core Definitions -/

/-- Pairwise gap between logits of classes `i` and `j`. -/
def pairGap {α : Type*} {C : ℕ} (f : α → Fin C → ℝ) (i j : Fin C) (x : α) : ℝ :=
  f x i - f x j

/-- Margin vector: for predicted class `y`, the vector of gaps `f(x,y) - f(x,j)`. -/
def marginVec {α : Type*} {C : ℕ} (f : α → Fin C → ℝ) (y : Fin C) (x : α) : Fin C → ℝ :=
  fun j => f x y - f x j

/-- Positivity of `Φ y v` implies all off-diagonal coordinates `v j` (for `j ≠ y`)
    are positive. -/
def PositivityImpliesOffDiagPositive {C : ℕ} (Φ : Fin C → (Fin C → ℝ) → ℝ) : Prop :=
  ∀ ⦃y : Fin C⦄ ⦃v : Fin C → ℝ⦄, Φ y v > 0 → ∀ j, j ≠ y → v j > 0

/-- `Φ y v` is dominated by the off-diagonal minimum: `Φ y v ≤ min_{j≠y} v j`. -/
def DominatesMin {C : ℕ} (hC : 2 ≤ C) (Φ : Fin C → (Fin C → ℝ) → ℝ) : Prop :=
  ∀ (y : Fin C) (v : Fin C → ℝ),
    Φ y v ≤ (univ.filter (· ≠ y)).inf' (filter_ne_nonempty hC y) v

/-- The off-diagonal minimum aggregator: for predicted class `y`, takes
    `min_{j ≠ y} v j`. This is the canonical min-margin certificate. -/
def offDiagMin {C : ℕ} (hC : 2 ≤ C) (y : Fin C) (v : Fin C → ℝ) : ℝ :=
  (univ.filter (· ≠ y)).inf' (filter_ne_nonempty hC y) v

/-! ## Basic Properties -/

/-- The margin vector equals the pairwise gap. -/
theorem marginVec_eq_pairGap {α : Type*} {C : ℕ}
    (f : α → Fin C → ℝ) (y j : Fin C) (x : α) :
    marginVec f y x j = pairGap f y j x := rfl

/-- The diagonal entry of the margin vector is zero. -/
@[simp]
theorem marginVec_self {α : Type*} {C : ℕ}
    (f : α → Fin C → ℝ) (y : Fin C) (x : α) :
    marginVec f y x y = 0 := by simp [marginVec]

/-
All off-diagonal coordinates are positive when the off-diagonal inf is positive.
-/
theorem positive_offdiag_of_inf_pos
    {C : ℕ} (hC : 2 ≤ C) {y : Fin C} {v : Fin C → ℝ}
    (h : (univ.filter (· ≠ y)).inf' (filter_ne_nonempty hC y) v > 0) :
    ∀ j, j ≠ y → v j > 0 := by
  exact fun j hj => lt_of_lt_of_le h ( Finset.inf'_le _ <| by aesop )

/-
Min-domination implies the positivity propagation property.
-/
theorem positivity_from_min_domination
    {C : ℕ} (hC : 2 ≤ C)
    {Φ : Fin C → (Fin C → ℝ) → ℝ}
    (hdom : DominatesMin hC Φ) :
    PositivityImpliesOffDiagPositive Φ := by
  intro y v hv j hj; have := hdom y v; simp_all +decide;
  linarith [ this j hj ]

/-! ## Off-diagonal Min Properties -/

/-- The off-diagonal min aggregator trivially dominates itself. -/
theorem offDiagMin_dominates_min {C : ℕ} (hC : 2 ≤ C) :
    DominatesMin hC (offDiagMin hC) := fun _ _ => le_refl _

/-
The off-diagonal min is 1-Lipschitz in ℓ∞:
    `|min_{j≠y} u j - min_{j≠y} v j| ≤ sup_i |u_i - v_i|`.
-/
theorem offDiagMin_lipschitz_one
    {C : ℕ} (hC : 2 ≤ C) (y : Fin C) :
    ∀ u v : Fin C → ℝ,
      |offDiagMin hC y u - offDiagMin hC y v|
        ≤ univ.sup' (fin_univ_nonempty (by omega : 0 < C))
          (fun i : Fin C => |u i - v i|) := by
  intro u v;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( filter_ne_nonempty hC y ) ( fun i => v i );
    simp_all +decide [ offDiagMin ];
    exact ⟨ j, j, hj.1, by cases abs_cases ( u j - v j ) <;> linarith ⟩;
  · simp +decide [ offDiagMin ];
    have := Finset.exists_mem_eq_inf' ( filter_ne_nonempty hC y ) u;
    obtain ⟨ i, hi, hi' ⟩ := this; exact ⟨ i, i, by aesop, by cases abs_cases ( u i - v i ) <;> linarith ⟩ ;

/-! ## Certificate Stability -/

/-- Coordinatewise perturbation bound for margin vectors. -/
theorem marginVec_coord_perturb
    {C d : ℕ}
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K : ℝ)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y j : Fin C) :
    |marginVec f y x j - marginVec f y x₀ j| ≤ 2 * K * ↑d * ‖x - x₀‖ :=
  hgap x x₀ y j

/-
The sup of coordinatewise margin vector changes is bounded.
-/
theorem sup_pairwise_margin_change_le
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K ε : ℝ)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε) :
    univ.sup' (fin_univ_nonempty hC)
      (fun j : Fin C => |marginVec f y x j - marginVec f y x₀ j|) ≤ 2 * K * ↑d * ε := by
  by_cases h : 2 * K * d ≥ 0;
  · exact Finset.sup'_le _ _ fun i _ => le_trans ( marginVec_coord_perturb f K hgap x₀ x y i ) ( by nlinarith );
  · rcases d with ( _ | d ) <;> norm_num at *;
    have := hgap 0 1 y y; norm_num at this;
    linarith [ abs_le.mp this ]

/-
Lower bound on the aggregated certificate under perturbation.
-/
theorem aggregated_margin_lower_bound_under_perturbation
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : Fin C → (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (_hK : 0 ≤ K) (_hε : 0 ≤ ε)
    (hLip : ∀ (y : Fin C) (u v : Fin C → ℝ),
      |Φ y u - Φ y v| ≤ univ.sup' (fin_univ_nonempty hC)
        (fun i : Fin C => |u i - v i|))
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε) :
    Φ y (marginVec f y x) ≥ Φ y (marginVec f y x₀) - 2 * K * ↑d * ε := by
  -- Apply the Lipschitz condition to the margin vectors.
  have h_lip : |Φ y (marginVec f y x) - Φ y (marginVec f y x₀)| ≤ univ.sup' (fin_univ_nonempty hC) (fun j => |marginVec f y x j - marginVec f y x₀ j|) := by
    exact hLip y _ _;
  linarith [ abs_le.mp h_lip, sup_pairwise_margin_change_le hC f K ε hgap x₀ x y hball ]

/-! ## Main Theorems -/

/-- **Main theorem**: A positive aggregated pairwise margin certificate,
    large enough to absorb perturbation of all pairwise gaps, certifies
    preservation of the top-1 class on the whole ℓ∞-ball. -/
theorem robust_of_pairwise_aggregated_margin
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : Fin C → (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hLip : ∀ (y : Fin C) (u v : Fin C → ℝ),
      |Φ y u - Φ y v| ≤ univ.sup' (fin_univ_nonempty hC)
        (fun i : Fin C => |u i - v i|))
    (hpos : PositivityImpliesOffDiagPositive Φ)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε)
    (hcert : Φ y (marginVec f y x₀) > 2 * K * ↑d * ε) :
    ∀ j, j ≠ y → f x y > f x j := by
  intro j hj
  have hstab := aggregated_margin_lower_bound_under_perturbation
    hC f Φ K ε hK hε hLip hgap x₀ x y hball
  have hΦpos : Φ y (marginVec f y x) > 0 := by linarith
  have hcoord := hpos hΦpos j hj
  simp [marginVec] at hcoord
  linarith

/-- Weak argmax corollary: `f x j ≤ f x y` for all `j`. -/
theorem top1_stable_of_pairwise_aggregated_margin
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : Fin C → (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hLip : ∀ (y : Fin C) (u v : Fin C → ℝ),
      |Φ y u - Φ y v| ≤ univ.sup' (fin_univ_nonempty hC)
        (fun i : Fin C => |u i - v i|))
    (hpos : PositivityImpliesOffDiagPositive Φ)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε)
    (hcert : Φ y (marginVec f y x₀) > 2 * K * ↑d * ε) :
    ∀ j, f x j ≤ f x y := by
  intro j
  by_cases hj : j = y
  · rw [hj]
  · exact le_of_lt (robust_of_pairwise_aggregated_margin hC f Φ K ε hK hε
      hLip hpos hgap x₀ x y hball hcert j hj)

/-- Robustness from min-domination: uses `DominatesMin` instead of
    `PositivityImpliesOffDiagPositive` directly. -/
theorem robust_of_pairwise_aggregated_margin_of_min_domination
    {C d : ℕ} (hC : 2 ≤ C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : Fin C → (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hLip : ∀ (y : Fin C) (u v : Fin C → ℝ),
      |Φ y u - Φ y v| ≤ univ.sup' (fin_univ_nonempty (by omega : 0 < C))
        (fun i : Fin C => |u i - v i|))
    (hdom : DominatesMin hC Φ)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε)
    (hcert : Φ y (marginVec f y x₀) > 2 * K * ↑d * ε) :
    ∀ j, j ≠ y → f x y > f x j :=
  robust_of_pairwise_aggregated_margin (by omega) f Φ K ε hK hε hLip
    (positivity_from_min_domination hC hdom) hgap x₀ x y hball hcert

/-- Specialization to the off-diagonal minimum aggregator. -/
theorem robust_of_min_pairwise_margin
    {C d : ℕ} (hC : 2 ≤ C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hgap : ∀ x x' i j,
      |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * ↑d * ‖x - x'‖)
    (x₀ x : Fin d → ℝ) (y : Fin C)
    (hball : ‖x - x₀‖ ≤ ε)
    (hcert : offDiagMin hC y (marginVec f y x₀) > 2 * K * ↑d * ε) :
    ∀ j, j ≠ y → f x y > f x j :=
  robust_of_pairwise_aggregated_margin_of_min_domination hC f (offDiagMin hC) K ε hK hε
    (fun y' => offDiagMin_lipschitz_one hC y')
    (offDiagMin_dominates_min hC) hgap x₀ x y hball hcert

end