import Mathlib

/-!
# Tropical Cells as Polyhedral Sets

For finitely many affine forms `ℓ_i(x) = ⟪a_i, x⟫ + b_i` on a finite-dimensional
inner product space, the tropical cell

  `C_k = {x | ∀ j, ℓ_j(x) ≤ ℓ_k(x)}`

is a finite intersection of closed halfspaces and therefore convex and closed.

## Main Results

* `tropicalCell_eq_iInter` — tropical cell as indexed intersection of halfspaces
* `tropicalCell_convex` — convexity of tropical cells
* `tropicalCell_isClosed` — closedness of tropical cells
-/

open scoped InnerProductSpace
open Set

noncomputable section

variable {ι : Type*} [Fintype ι] {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- The tropical cell for index `k`: the set of points where affine form `k` dominates
all other affine forms. -/
def tropicalCell (a : ι → E) (b : ι → ℝ) (k : ι) : Set E :=
  {x : E | ∀ j, ⟪a j, x⟫_ℝ + b j ≤ ⟪a k, x⟫_ℝ + b k}

/-
Each constraint in the tropical cell is a closed halfspace with normal `a j - a k`.
-/
lemma tropicalCell_eq_iInter (a : ι → E) (b : ι → ℝ) (k : ι) :
    tropicalCell a b k = ⋂ j, {x : E | ⟪a j - a k, x⟫_ℝ ≤ b k - b j} := by
      -- By definition of set equality, we need to show that every element of the tropical cell is in the intersection and vice versa.
      ext x;
      constructor <;> intro h <;> simp_all +decide [ tropicalCell, inner_sub_left ];
      · exact fun j => by linarith [ h j ] ;
      · exact fun j => by linarith [ h j ] ;

/-
Tropical cells are convex.
-/
theorem tropicalCell_convex (a : ι → E) (b : ι → ℝ) (k : ι) :
    Convex ℝ (tropicalCell a b k) := by
      refine' convex_iff_forall_pos.2 fun x hx y hy a b ha hb hab => _;
      intro j;
      convert add_le_add ( mul_le_mul_of_nonneg_left ( hx j ) ha.le ) ( mul_le_mul_of_nonneg_left ( hy j ) hb.le ) using 1 ; simp +decide [ inner_add_right, inner_add_left, inner_smul_left, inner_smul_right, ← eq_sub_iff_add_eq' ] ; ring;
      · linear_combination -hab * ‹ι → ℝ› j;
      · simp +decide [ inner_add_right, inner_smul_right, mul_add ] ; rw [ ← eq_sub_iff_add_eq' ] at hab ; subst_vars ; ring

/-
Tropical cells are closed.
-/
theorem tropicalCell_isClosed (a : ι → E) (b : ι → ℝ) (k : ι) :
    IsClosed (tropicalCell a b k) := by
      apply isClosed_of_closure_subset
      intro x hx
      simp [tropicalCell] at hx;
      rw [ mem_closure_iff_seq_limit ] at hx;
      rcases hx with ⟨ y, hy, hxy ⟩ ; intro j; exact le_of_tendsto_of_tendsto' ( Filter.Tendsto.add ( Filter.Tendsto.inner tendsto_const_nhds hxy ) tendsto_const_nhds ) ( Filter.Tendsto.add ( Filter.Tendsto.inner tendsto_const_nhds hxy ) tendsto_const_nhds ) fun n => hy n j;

end

/-- Membership in a tropical cell is equivalent to all score gaps being nonneg. -/
lemma mem_tropicalCell_iff {ι : Type*} {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (a : ι → E) (b : ι → ℝ) (k : ι) (x : E) :
    x ∈ tropicalCell a b k ↔ ∀ j, ⟪a j, x⟫_ℝ + b j ≤ ⟪a k, x⟫_ℝ + b k := by
  rfl