import Mathlib

/-!
# Chebyshev Radius of Tropical Margin Cells

This file proves that the maximal certified robustness radius for a tropical affine
classifier equals the minimum Euclidean distance from the classification point to the
pairwise decision boundaries. This is the geometric bridge from tropical classification
to convex-body geometry.

## Main Results

* `tropMarginDiff_lipschitz` — Cauchy–Schwarz control: the margin variation between
  two points is bounded by `‖W_i - W_j‖ * ‖y - x‖`.
* `ball_in_tropMarginCell` — A closed ball of radius equal to the minimum pairwise
  boundary distance is contained in the margin cell.
* `tropMarginCell_sharpness` — For any ε > 0, there exists a point at distance
  `r + ε` from the center that leaves the margin cell.
* `chebyshev_radius_eq_min_boundary_dist` — The exact characterization combining
  inclusion and sharpness.

## Concrete Definitions

We also provide `score`, `marginDiff`, `marginCell`, `rowDiff` using explicit sums
over `Fin n → ℝ`, matching the standard tropical affine classifier formulation.
-/

noncomputable section

open Finset BigOperators

namespace TropicalChebyshev

/-! ## Abstract Inner Product Space Formulation -/

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
variable {m : ℕ}

/-- Score of class `i` at point `x`: `aᵢ + ⟨Wᵢ, x⟩`. -/
def tropScore (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m) (x : V) : ℝ :=
  a i + @inner ℝ V _ (W i) x

/-- Margin difference: `score_i(x) - score_j(x)`. -/
def tropMarginDiff (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m) (x : V) : ℝ :=
  tropScore a W i x - tropScore a W j x

/-- Row difference vector: `W_i - W_j`. -/
def tropRowDiff (W : Fin m → V) (i j : Fin m) : V := W i - W j

/-- Margin cell: the polyhedral region where class `i` dominates all others. -/
def tropMarginCell (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m) : Set V :=
  {x | ∀ j, tropMarginDiff a W i j x ≥ 0}

/-! ### Algebraic Identities -/

/-- The margin difference decomposes as a bias term plus inner product with the
row difference. -/
theorem tropMarginDiff_eq (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m) (x : V) :
    tropMarginDiff a W i j x =
      (a i - a j) + @inner ℝ V _ (tropRowDiff W i j) x := by
  simp only [tropMarginDiff, tropScore, tropRowDiff, inner_sub_left]
  ring

/-- Self-margin is always zero. -/
@[simp]
theorem tropMarginDiff_self (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m) (x : V) :
    tropMarginDiff a W i i x = 0 := by
  simp [tropMarginDiff, tropScore]

/-- Affine perturbation identity: shifting the input by `d` shifts the margin
by `⟨W_i - W_j, d⟩`. -/
theorem tropMarginDiff_add (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m) (x₀ d : V) :
    tropMarginDiff a W i j (x₀ + d) =
      tropMarginDiff a W i j x₀ + @inner ℝ V _ (tropRowDiff W i j) d := by
  simp only [tropMarginDiff_eq, inner_add_right]; ring

/-- The margin difference between two points equals the inner product of the row
difference with the displacement. -/
theorem tropMarginDiff_sub_eq (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m)
    (x y : V) :
    tropMarginDiff a W i j y - tropMarginDiff a W i j x =
      @inner ℝ V _ (tropRowDiff W i j) (y - x) := by
  simp only [tropMarginDiff_eq, inner_sub_right]; ring

/-! ### Cauchy–Schwarz Estimate -/

/-- **Cauchy–Schwarz control of margin variation**: the margin difference between
two points is bounded by `‖W_i - W_j‖ * ‖y - x‖`. -/
theorem tropMarginDiff_lipschitz (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m)
    (x y : V) :
    |tropMarginDiff a W i j y - tropMarginDiff a W i j x| ≤
      ‖tropRowDiff W i j‖ * ‖y - x‖ := by
  rw [tropMarginDiff_sub_eq]
  exact abs_real_inner_le_norm (tropRowDiff W i j) (y - x)

/-
Lower bound on margin at a nearby point.
-/
theorem tropMarginDiff_lower_bound (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m)
    (x₀ y : V) :
    tropMarginDiff a W i j y ≥
      tropMarginDiff a W i j x₀ - ‖tropRowDiff W i j‖ * ‖y - x₀‖ := by
  linarith [ abs_le.mp ( tropMarginDiff_lipschitz a W i j x₀ y ) ]

/-! ### Ball Inclusion for Single Halfspace -/

/-
If the radius is at most `margin / ‖normal‖`, then every point in the ball
satisfies the halfspace inequality.
-/
theorem halfspace_ball_inclusion (a : Fin m → ℝ) (W : Fin m → V) (i j : Fin m)
    (x₀ : V) (hx₀ : tropMarginDiff a W i j x₀ ≥ 0)
    (hij : tropRowDiff W i j ≠ 0) (r : ℝ) (hr : 0 ≤ r)
    (hrbound : r ≤ tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖) :
    ∀ x, ‖x - x₀‖ ≤ r → tropMarginDiff a W i j x ≥ 0 := by
  intro x hx;
  have := tropMarginDiff_lower_bound a W i j x₀ x;
  rw [ le_div_iff₀ ( norm_pos_iff.mpr hij ) ] at hrbound ; nlinarith [ norm_nonneg ( tropRowDiff W i j ) ]

/-! ### Ball Inclusion in Margin Cell -/

/-
The minimum pairwise boundary distance is nonneg when x₀ is in the margin cell.
-/
theorem min_boundary_dist_nonneg (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m) (x₀ : V)
    (hx₀ : x₀ ∈ tropMarginCell a W i)
    (hsep : ∀ j, j ≠ i → tropRowDiff W i j ≠ 0)
    (hne : (Finset.univ.erase i).Nonempty) :
    0 ≤ (Finset.univ.erase i).inf' hne
      (fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖) := by
  simp +zetaDelta at *;
  exact fun j hj => div_nonneg ( hx₀ j ) ( norm_nonneg _ )

/-
**Ball inclusion theorem**: A closed ball of radius equal to the minimum
pairwise boundary distance is contained in the margin cell.
-/
theorem ball_in_tropMarginCell (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m)
    (x₀ : V) (hx₀ : x₀ ∈ tropMarginCell a W i)
    (hsep : ∀ j, j ≠ i → tropRowDiff W i j ≠ 0)
    (hne : (Finset.univ.erase i).Nonempty) :
    let r := (Finset.univ.erase i).inf' hne
      (fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖)
    ∀ x, ‖x - x₀‖ ≤ r → x ∈ tropMarginCell a W i := by
  refine fun x hx j => ?_;
  by_cases hj : j = i;
  · simp +decide [ hj, tropMarginDiff_self ];
  · refine' halfspace_ball_inclusion a W i j x₀ ( hx₀ j ) ( hsep j hj ) _ _ _ x hx;
    · exact le_trans ( norm_nonneg _ ) hx;
    · exact Finset.inf'_le _ ( Finset.mem_erase_of_ne_of_mem hj ( Finset.mem_univ _ ) )

/-! ### Sharpness -/

/-
**Sharpness theorem**: For any ε > 0, there exists a point at distance `r + ε`
from `x₀` that leaves the margin cell. The witness is obtained by moving in the
direction opposite to the normal of the nearest boundary.
-/
theorem tropMarginCell_sharpness (a : Fin m → ℝ) (W : Fin m → V) (i : Fin m)
    (x₀ : V) (hx₀ : x₀ ∈ tropMarginCell a W i)
    (hsep : ∀ j, j ≠ i → tropRowDiff W i j ≠ 0)
    (hne : (Finset.univ.erase i).Nonempty) :
    let r := (Finset.univ.erase i).inf' hne
      (fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖)
    ∀ ε > 0, ∃ x, ‖x - x₀‖ ≤ r + ε ∧ x ∉ tropMarginCell a W i := by
  intro r ε hε
  obtain ⟨j_star, hj_star⟩ : ∃ j_star ∈ Finset.univ.erase i, tropMarginDiff a W i j_star x₀ / ‖tropRowDiff W i j_star‖ = r := by
    have := Finset.exists_min_image ( Finset.univ.erase i ) ( fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖ ) hne;
    exact ⟨ this.choose, this.choose_spec.1, le_antisymm ( Finset.le_inf' _ _ this.choose_spec.2 ) ( Finset.inf'_le _ this.choose_spec.1 ) ⟩;
  refine' ⟨ x₀ + ( - ( r + ε ) * ‖tropRowDiff W i j_star‖⁻¹ ) • tropRowDiff W i j_star, _, _ ⟩ <;> simp_all +decide [ norm_smul, mul_assoc, div_eq_mul_inv ];
  · rw [ abs_le ] ; constructor <;> linarith [ show 0 ≤ r by exact le_trans ( by norm_num ) ( min_boundary_dist_nonneg a W i x₀ hx₀ hsep hne ) ];
  · intro h
    have := h j_star
    simp_all +decide [ tropMarginDiff_add, tropMarginDiff_sub_eq ];
    simp_all +decide [ inner_smul_right, inner_self_eq_norm_sq_to_K ];
    simp_all +decide [ sq, mul_assoc, ne_of_gt ( norm_pos_iff.mpr ( hsep _ hj_star.1 ) ) ];
    nlinarith [ norm_pos_iff.mpr ( hsep j_star hj_star.1 ), mul_inv_cancel₀ ( ne_of_gt ( norm_pos_iff.mpr ( hsep j_star hj_star.1 ) ) ), hx₀ j_star, min_boundary_dist_nonneg a W i x₀ hx₀ hsep hne ]

/-! ### Main Theorem -/

/-- **Chebyshev radius = minimum boundary distance**.

The maximal closed Euclidean ball centered at `x₀` that is contained in the
margin cell has radius equal to the minimum over all competitors `j ≠ i` of
`marginDiff(i,j,x₀) / ‖W_i - W_j‖`.

This is both an inclusion theorem (the ball of this radius stays in the cell)
and a sharpness theorem (any larger ball escapes). -/
theorem chebyshev_radius_eq_min_boundary_dist (a : Fin m → ℝ) (W : Fin m → V)
    (i : Fin m) (x₀ : V) (hx₀ : x₀ ∈ tropMarginCell a W i)
    (hsep : ∀ j, j ≠ i → tropRowDiff W i j ≠ 0)
    (hne : (Finset.univ.erase i).Nonempty) :
    let r := (Finset.univ.erase i).inf' hne
      (fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖)
    (∀ x, ‖x - x₀‖ ≤ r → x ∈ tropMarginCell a W i) ∧
    (∀ ε > 0, ∃ x, ‖x - x₀‖ ≤ r + ε ∧ x ∉ tropMarginCell a W i) :=
  ⟨ball_in_tropMarginCell a W i x₀ hx₀ hsep hne,
   tropMarginCell_sharpness a W i x₀ hx₀ hsep hne⟩

/-! ### Corollary: Positive Radius from Strict Margins -/

/-
If `x₀` lies in the strict interior of the margin cell (all pairwise margins
are strictly positive), then the Chebyshev radius is strictly positive.
-/
theorem chebyshev_radius_pos_of_strict_margins (a : Fin m → ℝ) (W : Fin m → V)
    (i : Fin m) (x₀ : V) (hx₀ : x₀ ∈ tropMarginCell a W i)
    (hsep : ∀ j, j ≠ i → tropRowDiff W i j ≠ 0)
    (hne : (Finset.univ.erase i).Nonempty)
    (hstrict : ∀ j, j ≠ i → tropMarginDiff a W i j x₀ > 0) :
    0 < (Finset.univ.erase i).inf' hne
      (fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖) := by
  -- Each term marginDiff(i,j,x₀)/‖rowDiff(i,j)‖ is strictly positive because marginDiff > 0 (from hstrict) and ‖rowDiff‖ > 0 (from hsep).
  have h_pos : ∀ j ∈ Finset.erase Finset.univ i, 0 < tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖ := by
    exact fun j hj => div_pos ( hstrict j ( Finset.ne_of_mem_erase hj ) ) ( norm_pos_iff.mpr ( hsep j ( Finset.ne_of_mem_erase hj ) ) );
  obtain ⟨ j, hj ⟩ := Finset.exists_min_image ( Finset.univ.erase i ) ( fun j => tropMarginDiff a W i j x₀ / ‖tropRowDiff W i j‖ ) hne;
  exact lt_of_lt_of_le ( h_pos j hj.1 ) ( Finset.le_inf' _ _ hj.2 )

/-! ## Concrete Definitions for `Fin n → ℝ` -/

/-- Score of class `i` at point `x`: `aᵢ + Σₖ Wᵢₖ · xₖ`. -/
def score {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ) (i : Fin m)
    (x : Fin n → ℝ) : ℝ :=
  a i + ∑ k, W i k * x k

/-- Margin difference using explicit sums. -/
def marginDiff {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ) (i j : Fin m)
    (x : Fin n → ℝ) : ℝ :=
  score a W i x - score a W j x

/-- Margin cell using explicit sums. -/
def marginCell {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ) (i : Fin m) :
    Set (Fin n → ℝ) :=
  {x | ∀ j, marginDiff a W i j x ≥ 0}

/-- Row difference as explicit function. -/
def rowDiff {m n : ℕ} (W : Fin m → Fin n → ℝ) (i j : Fin m) : Fin n → ℝ :=
  fun k => W i k - W j k

/-
Halfspace representation of the margin cell: membership is equivalent to
all pairwise affine functionals being nonneg.
-/
theorem mem_marginCell_iff {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ)
    (i : Fin m) (x : Fin n → ℝ) :
    x ∈ marginCell a W i ↔
      ∀ j, (a i - a j) + ∑ k, (W i k - W j k) * x k ≥ 0 := by
  -- By definition of margin cell, we have:
  unfold marginCell at *;
  unfold marginDiff at *;
  unfold score at *;
  simp [Finset.sum_sub_distrib, sub_mul] at *;
  constructor <;> intro h j <;> linarith [ h j ]

/-
The margin difference decomposes into a bias plus inner product with the row
difference. This relates the concrete sums to the abstract formulation.
-/
theorem marginDiff_eq_bias_plus_sum {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ)
    (i j : Fin m) (x : Fin n → ℝ) :
    marginDiff a W i j x = (a i - a j) + ∑ k, (W i k - W j k) * x k := by
  unfold marginDiff; simp +decide [ sub_mul ] ; ring;
  unfold score; ring

/-
Affine perturbation identity for the concrete margin difference.
-/
theorem marginDiff_sub {m n : ℕ} (a : Fin m → ℝ) (W : Fin m → Fin n → ℝ)
    (i j : Fin m) (x y : Fin n → ℝ) :
    marginDiff a W i j y =
      marginDiff a W i j x + ∑ k, (W i k - W j k) * (y k - x k) := by
  unfold marginDiff; ring;
  unfold score; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _ ] ; ring;

end TropicalChebyshev