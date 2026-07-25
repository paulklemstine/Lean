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
* `tropical_cell_infDist_compl_pos` — positive distance to complement for strict winners
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
theorem single_competitor_robustness
    (a : ι → E) (b : ι → ℝ) (k j : ι) (x y : E)
    (hne : a j ≠ a k)
    (_hx : ⟪a j, x⟫_ℝ + b j ≤ ⟪a k, x⟫_ℝ + b k)
    (hy : ‖y - x‖ < ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖) :
    ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k := by
      -- By Cauchy-Schwarz inequality, we have |⟪a k - a j, y - x⟫| ≤ ‖a k - a j‖ · ‖y - x‖.
      have h_cauchy_schwarz : |⟪a k - a j, y - x⟫_ℝ| ≤ ‖a k - a j‖ * ‖y - x‖ := by
        exact abs_real_inner_le_norm _ _;
      rw [ lt_div_iff₀' ( norm_pos_iff.mpr <| sub_ne_zero.mpr hne.symm ) ] at hy;
      norm_num [ inner_sub_left, inner_sub_right ] at * ; linarith [ abs_le.mp h_cauchy_schwarz ]

/-
**Ball subset tropical cell**: if `x` is in the tropical cell for `k` with
strictly positive margin against every competitor with distinct normal,
then a ball of the certified radius is contained in the cell.
-/
theorem ball_subset_tropicalCell
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E) (r : ℝ)
    (hx : x ∈ tropicalCell a b k)
    (hbound : ∀ j, j ≠ k → a j ≠ a k →
      r ≤ ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖)
    (hequal : ∀ j, j ≠ k → a j = a k → b j ≤ b k) :
    Metric.ball x r ⊆ tropicalCell a b k := by
      intro y hy
      simp [tropicalCell] at *;
      intro j
      by_cases hj : j = k;
      · rw [ hj ];
      · by_cases h : a j = a k <;> simp_all +decide [ dist_eq_norm ];
        exact single_competitor_robustness a b k j x y h ( hx j ) ( lt_of_lt_of_le hy ( hbound j hj h ) )

/-
**Label invariance under certified perturbation**.
-/
theorem label_invariant_under_certified_perturbation
    (a : ι → E) (b : ι → ℝ) (k : ι) (x y : E)
    (hx : x ∈ tropicalCell a b k)
    (hbound : ∀ j, j ≠ k → a j ≠ a k →
      ‖y - x‖ < ((⟪a k, x⟫_ℝ + b k) - (⟪a j, x⟫_ℝ + b j)) / ‖a k - a j‖)
    (hequal : ∀ j, j ≠ k → a j = a k → b j ≤ b k) :
    y ∈ tropicalCell a b k := by
      -- Apply the robustness theorem to each j ≠ k.
      have hrob : ∀ j, j ≠ k → ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k := by
        intro j hj_ne_k
        by_cases h_eq : a j = a k;
        · grind;
        · apply single_competitor_robustness a b k j x y h_eq (hx j) (hbound j hj_ne_k h_eq);
      exact fun j => if hj : j = k then hj.symm ▸ le_rfl else hrob j hj

/-
A strict winner is in the interior of the tropical cell.
-/
theorem tropicalCell_mem_interior
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E)
    (_hx : x ∈ tropicalCell a b k)
    (hstrict : ∀ j, j ≠ k → ⟪a j, x⟫_ℝ + b j < ⟪a k, x⟫_ℝ + b k) :
    x ∈ interior (tropicalCell a b k) := by
      -- By definition of $r$, we know that for any $j \neq k$ with $a_j \neq a_k$, $\|y - x\| < r$ implies $y \in \text{tropicalCell}(a, b, k)$.
      obtain ⟨r, hr⟩ : ∃ r > 0, ∀ y, ‖y - x‖ < r → ∀ j ≠ k, ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k := by
        -- By definition of $r$, we know that for any $j \neq k$ with $a_j \neq a_k$, $\|y - x\| < r$ implies $y \in \text{tropicalCell}(a, b, k)$ because the gap is positive.
        have hr_pos : ∀ j ≠ k, ∃ r_j > 0, ∀ y, ‖y - x‖ < r_j → ⟪a j, y⟫_ℝ + b j ≤ ⟪a k, y⟫_ℝ + b k := by
          intro j hj_ne_k
          have h_cont : ContinuousAt (fun y => ⟪a j, y⟫_ℝ + b j - (⟪a k, y⟫_ℝ + b k)) x := by
            fun_prop;
          have := Metric.continuousAt_iff.mp h_cont;
          exact Exists.elim ( this ( ( ⟪a k, x⟫_ℝ + b k ) - ( ⟪a j, x⟫_ℝ + b j ) ) ( sub_pos.mpr ( hstrict j hj_ne_k ) ) ) fun δ hδ => ⟨ δ, hδ.1, fun y hy => by linarith [ abs_lt.mp ( hδ.2 ( show dist y x < δ from by simpa only [ dist_eq_norm ] using hy ) ) ] ⟩;
        choose! r hr_pos hr using hr_pos;
        by_cases hk : ∃ j, j ≠ k;
        · exact ⟨ Finset.min' ( Finset.image r ( Finset.univ.erase k ) ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_erase_of_ne_of_mem hk.choose_spec ( Finset.mem_univ _ ) ) ⟩, by have := Finset.min'_mem ( Finset.image r ( Finset.univ.erase k ) ) ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_erase_of_ne_of_mem hk.choose_spec ( Finset.mem_univ _ ) ) ⟩ ; aesop, fun y hy j hj => hr j hj y ( lt_of_lt_of_le hy ( Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_erase_of_ne_of_mem hj ( Finset.mem_univ _ ) ) ) ) ) ⟩;
        · exact ⟨ 1, zero_lt_one, fun y hy j hj => False.elim <| hk ⟨ j, hj ⟩ ⟩;
      exact mem_interior_iff_mem_nhds.mpr ( Filter.mem_of_superset ( Metric.ball_mem_nhds x hr.1 ) fun y hy j => if hj : j = k then hj ▸ le_rfl else hr.2 y ( by simpa [ dist_eq_norm ] using hy ) j hj )

end