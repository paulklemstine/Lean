import Mathlib
import Tropical.PolyhedralRobustness.TropicalCells

/-!
# Polyhedral Robustness for Tropical Classifiers

This file proves the core robustness theorem: if a point `x` belongs to the
tropical cell for class `k` with strictly positive margins, then perturbations
within the normalized margin radius preserve the classification.

## Main Results

* `single_competitor_robustness` — robustness against a single competitor
* `ball_subset_tropicalCell` — ball of certified radius stays in the cell
* `label_invariant_under_certified_perturbation` — label preservation
* `tropicalCell_mem_interior` — strict winners are in the interior
-/

open scoped InnerProductSpace
open Metric Set

noncomputable section

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
  {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]

/-
**Single-competitor robustness**: if `ℓ_k(x) ≥ ℓ_j(x)` and `a_j ≠ a_k` and
`‖y - x‖ < (ℓ_k(x) - ℓ_j(x)) / ‖a_k - a_j‖`, then `ℓ_j(y) ≤ ℓ_k(y)`.

The key idea is that `ℓ_k(y) - ℓ_j(y) = ℓ_k(x) - ℓ_j(x) + ⟪a_k - a_j, y - x⟫`,
and `|⟪a_k - a_j, y - x⟫| ≤ ‖a_k - a_j‖ · ‖y - x‖` by Cauchy-Schwarz.
-/
omit [Fintype ι] [DecidableEq ι] [FiniteDimensional ℝ E] in
theorem single_competitor_robustness
    (a : ι → E) (b : ι → ℝ) (k j : ι) (x y : E)
    (hne : a j ≠ a k)
    (_hx : ⟪a j, x⟫_ℝ + b j ≤ ⟪a k, x⟫_ℝ + b k)
    (hy : ‖y - x‖ < ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖) :
    ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k := by
  rw [ lt_div_iff₀ ( norm_pos_iff.mpr ( sub_ne_zero.mpr hne.symm ) ) ] at hy;
  have := abs_le.mp ( abs_real_inner_le_norm ( a k - a j ) ( y - x ) );
  norm_num [ inner_sub_left, inner_sub_right ] at * ; linarith

/-
**Ball subset tropical cell**: if `x` is in the tropical cell for `k` with
appropriate margin bounds, then a ball of the certified radius stays in the cell.
-/
omit [Fintype ι] [FiniteDimensional ℝ E] in
theorem ball_subset_tropicalCell
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E) (r : ℝ)
    (hx : x ∈ tropicalCell a b k)
    (hbound : ∀ j, j ≠ k → a j ≠ a k →
      r ≤ ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖)
    (hequal : ∀ j, j ≠ k → a j = a k → b j ≤ b k) :
    Metric.ball x r ⊆ tropicalCell a b k := by
  -- By definition of ball, we know that for any y in the ball, ‖y - x‖ < r.
  intro y hy
  rw [mem_tropicalCell_iff];
  intro j
  by_cases hj : j = k;
  · rw [ hj ];
  · by_cases h : a j = a k <;> simp_all +decide [ dist_eq_norm ];
    exact single_competitor_robustness a b k j x y h ( hx j ) ( lt_of_lt_of_le hy ( hbound j hj h ) )

/-
**Label invariance under certified perturbation**: if `y` is within the
certified radius of `x`, then `y` is in the same tropical cell.
-/
omit [Fintype ι] [FiniteDimensional ℝ E] in
theorem label_invariant_under_certified_perturbation
    (a : ι → E) (b : ι → ℝ) (k : ι) (x y : E)
    (hx : x ∈ tropicalCell a b k)
    (hbound : ∀ j, j ≠ k → a j ≠ a k →
      ‖y - x‖ < ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖)
    (hequal : ∀ j, j ≠ k → a j = a k → b j ≤ b k) :
    y ∈ tropicalCell a b k := by
  intro j;
  by_cases hj : j = k <;> by_cases hj' : a j = a k <;> simp_all +decide;
  convert single_competitor_robustness a b k j x y hj' ( hx j ) ( hbound j hj hj' ) using 1

/-
A strict winner is in the interior of the tropical cell.
-/
omit [FiniteDimensional ℝ E] in
theorem tropicalCell_mem_interior
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E)
    (_hx : x ∈ tropicalCell a b k)
    (hstrict : ∀ j, j ≠ k → ⟪a j, x⟫_ℝ + b j < ⟪a k, x⟫_ℝ + b k) :
    x ∈ interior (tropicalCell a b k) := by
  refine' mem_interior_iff_mem_nhds.mpr _;
  -- By definition of $tropicalCell$, we know that $tropicalCell a b k$ is the intersection of closed half-spaces.
  have h_halfspaces : tropicalCell a b k = ⋂ j ≠ k, {y : E | ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k} := by
    ext y; simp [tropicalCell];
    exact ⟨ fun h j hj => h j, fun h j => if hj : j = k then hj.symm ▸ le_rfl else h j hj ⟩;
  -- Since $x$ is in the interior of each closed half-space, it is in the interior of their intersection.
  have h_interior : ∀ j ≠ k, x ∈ interior {y : E | ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k} := by
    intro j hj_ne_k
    have h_cont : Continuous (fun y : E => ⟪a j, y⟫_ℝ + b j - (⟪a k, y⟫_ℝ + b k)) := by
      fun_prop;
    exact mem_interior_iff_mem_nhds.mpr ( Filter.mem_of_superset ( h_cont.continuousAt.eventually ( gt_mem_nhds <| sub_neg_of_lt <| hstrict j hj_ne_k ) ) fun y hy => by norm_num at *; linarith );
  rw [ h_halfspaces ];
  refine' Filter.mem_of_superset ( IsOpen.mem_nhds _ _ ) _;
  exact ⋂ j ≠ k, interior { y : E | ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k };
  · exact isOpen_iInter_of_finite fun j => isOpen_iInter_of_finite fun hj => isOpen_interior;
  · exact Set.mem_iInter₂.2 h_interior;
  · exact Set.iInter₂_mono fun j hj => interior_subset

end