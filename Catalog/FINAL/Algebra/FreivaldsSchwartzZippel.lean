/-
  # Freivalds as a Corollary of Schwartz–Zippel over Finite Fields

  This file formalizes the conceptual bridge between Freivalds' randomized matrix
  verification algorithm and the Schwartz–Zippel polynomial identity testing lemma.

  The key insight: the one-sided error guarantee of Freivalds' algorithm is precisely
  the degree-1 specialization of the Schwartz–Zippel lemma over finite fields. A nonzero
  row of a matrix defines a nonzero linear polynomial, and the kernel of the matrix is
  contained in the zero set of that polynomial. The Schwartz–Zippel bound at degree 1
  then gives the error bound.

  ## Main results

  - `linearRowPoly`: constructs the multivariate linear polynomial ∑ w_j X_j
  - `eval_linearRowPoly`: evaluation computes the dot product
  - `linearRowPoly_ne_zero`: nonzero coefficients give nonzero polynomial
  - `totalDegree_linearRowPoly_le_one`: the polynomial has total degree ≤ 1
  - `card_solutions_linear_form_le`: |{r | ∑ w_j r_j = 0}| ≤ q^(p-1)
  - `freivalds_from_schwartz_zippel`: |ker(M)| ≤ q^(p-1) for nonzero M

  ## Cross-domain significance

  This theorem bridges four domains:
  1. **Randomized algorithms**: Freivalds' verification guarantee becomes a zero-set bound
  2. **Polynomial identity testing**: Freivalds is a degree-1 case of PIT
  3. **Coding theory**: bounds the fraction of words satisfying a parity check
  4. **Algebraic complexity**: degree controls both circuit depth and vanishing probability
-/

import Mathlib
import Algebra.CircuitComplexity.SchwartzZippel

open Classical

noncomputable section

namespace FreivaldsSchwartzZippel

open MvPolynomial Finset BigOperators Matrix

variable {q : ℕ} [Fact q.Prime]

/-! ## The Linear Row Polynomial -/

/-- The linear polynomial associated to a coefficient vector `w`:
    `linearRowPoly w = ∑ j, C(w j) * X j`.
    This is the degree-1 multivariate polynomial whose zero set
    corresponds to solutions of the linear equation `∑ w_j r_j = 0`. -/
def linearRowPoly {p : ℕ} (w : Fin p → ZMod q) :
    MvPolynomial (Fin p) (ZMod q) :=
  ∑ j, MvPolynomial.C (w j) * MvPolynomial.X j

/-- Evaluating `linearRowPoly w` at `r` gives the dot product `∑ j, w j * r j`. -/
theorem eval_linearRowPoly {p : ℕ} (w r : Fin p → ZMod q) :
    MvPolynomial.eval r (linearRowPoly w) = ∑ j, w j * r j := by
  simp [linearRowPoly, map_sum, mul_comm]

/-- A nonzero coefficient vector produces a nonzero linear polynomial. -/
theorem linearRowPoly_ne_zero {p : ℕ} (w : Fin p → ZMod q) (hw : w ≠ 0) :
    linearRowPoly w ≠ 0 := by
  intro h; apply hw; ext j
  have : MvPolynomial.eval (fun i => if i = j then 1 else 0 : Fin p → ZMod q)
    (linearRowPoly w) = 0 := by rw [h]; simp
  rw [eval_linearRowPoly] at this; simp at this; exact this

/-- The total degree of `linearRowPoly w` is at most 1. -/
theorem totalDegree_linearRowPoly_le_one {p : ℕ} (w : Fin p → ZMod q) :
    (linearRowPoly w).totalDegree ≤ 1 := by
  unfold linearRowPoly
  refine le_trans (MvPolynomial.totalDegree_finset_sum _ _) (Finset.sup_le fun j _ => ?_)
  by_cases hw : w j = 0
  · simp [hw]
  · calc (MvPolynomial.C (w j) * MvPolynomial.X j).totalDegree
        ≤ (MvPolynomial.C (w j)).totalDegree + (MvPolynomial.X j).totalDegree :=
          MvPolynomial.totalDegree_mul _ _
      _ = 0 + 1 := by rw [MvPolynomial.totalDegree_C, MvPolynomial.totalDegree_X]
      _ = 1 := by ring

/-! ## The Degree-1 Schwartz–Zippel Bound -/

/-- **Key theorem (row-functional version)**: The number of solutions to a nonzero
    linear form over `ZMod q` is at most `q^(p-1)`. This is the degree-1 case of
    Schwartz–Zippel.

    For `w ≠ 0`, the polynomial `∑ w_j X_j` has degree 1 and is nonzero,
    so Schwartz–Zippel gives `|{r | ∑ w_j r_j = 0}| ≤ 1 · q^(p-1) = q^(p-1)`. -/
theorem card_solutions_linear_form_le {p : ℕ}
    (w : Fin p → ZMod q) (hw : w ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // ∑ j, w j * r j = 0} ≤ q ^ (p - 1) := by
  -- Apply the linear Schwartz–Zippel bound to the polynomial linearRowPoly w
  have hsz := SchwartzZippel.linear_schwartz_zippel
    (linearRowPoly w) (linearRowPoly_ne_zero w hw) (totalDegree_linearRowPoly_le_one w)
  rw [ZMod.card] at hsz
  -- Identify the zero sets via filter on Finset.univ
  rw [Fintype.card_subtype] at hsz ⊢
  convert hsz using 2
  ext r; simp [eval_linearRowPoly]

/-! ## Matrix Row Extraction -/

theorem exists_nonzero_row {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (hM : M ≠ 0) :
    ∃ i, M i ≠ 0 := by
  by_contra h; push_neg at h
  exact hM (Matrix.ext fun i j => by have := congr_fun (h i) j; simpa using this)

theorem mulVec_zero_implies_row_dot_zero {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (r : Fin p → ZMod q)
    (hr : M.mulVec r = 0) (i : Fin m) :
    ∑ j, M i j * r j = 0 := by
  have := congr_fun hr i
  simp [Matrix.mulVec, dotProduct] at this
  exact this

/-! ## The Main Result -/

/-- **Freivalds from Schwartz–Zippel**: For a nonzero matrix `M` of dimensions
    `m × p` over `ZMod q` (with `q` prime), the kernel has at most `q^(p-1)` elements.

    **Proof sketch**: Extract a nonzero row `w = M i` from `M ≠ 0`. Every vector `r`
    in `ker(M)` satisfies `∑ j, M i j * r j = 0`, so `ker(M)` injects into the zero set
    of the nonzero linear form defined by row `i`. By `card_solutions_linear_form_le`
    (the degree-1 Schwartz–Zippel bound), this zero set has at most `q^(p-1)` elements.

    This reclassifies the Freivalds error bound as a polynomial identity testing result:
    the matrix verification problem reduces to checking whether a degree-1 polynomial
    vanishes, and the error probability is bounded by Schwartz–Zippel. -/
theorem freivalds_from_schwartz_zippel {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} ≤ q ^ (p - 1) := by
  -- Extract a nonzero row
  obtain ⟨i, hi⟩ := exists_nonzero_row M hM
  -- The kernel of M injects into the zero set of row i
  have h_subset : ∀ r : Fin p → ZMod q, M.mulVec r = 0 → ∑ j, M i j * r j = 0 :=
    fun r hr => mulVec_zero_implies_row_dot_zero M r hr i
  -- Count: |ker(M)| ≤ |{r | ∑ M_i_j r_j = 0}| ≤ q^(p-1)
  calc Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card {r : Fin p → ZMod q // ∑ j, M i j * r j = 0} := by
        apply Fintype.card_le_of_injective (fun ⟨r, hr⟩ => ⟨r, h_subset r hr⟩)
        intro ⟨a, _⟩ ⟨b, _⟩ h; simp at h; exact Subtype.ext h
    _ ≤ q ^ (p - 1) := card_solutions_linear_form_le (M i) hi

end FreivaldsSchwartzZippel

end