/-
Copyright (c) 2025. All rights reserved.

# Jacobian Conjecture: Dimension 2 Quadratic Case

## Main Results

- `jacobianDet_identity_plus_2d`: Explicit 2D Jacobian determinant formula.
- `jac_sum_zero_2d`: Jacobian condition decomposes into trace + det = 0.
- `quadratic_shear_is_auto`: Triangular shear is an automorphism.
- `rank_one_quadratic_inverse_2d`: Non-trivial rank-1 quadratic inverse.
- `rank_one_quadratic_jacobian_det_one`: Rank-1 map has unit Jacobian.
- `jacobian_2d_homog_quad_eval_inverse`: Inverse formula at eval level.

## Keywords
Jacobian conjecture, dimension 2, quadratic maps, polynomial automorphism
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix Finset

variable {K : Type*} [Field K] [CharZero K]

/-! ### Dimension 2: Explicit Jacobian computation -/

/-- For F = (X 0 + H₀, X 1 + H₁), the Jacobian determinant. -/
theorem jacobianDet_identity_plus_2d
    (H : Fin 2 → MvPolynomial (Fin 2) K) :
    jacobianDet (fun i => X i + H i) =
      1 + (pderiv 0) (H 0) + (pderiv 1) (H 1)
        + ((pderiv 0) (H 0) * (pderiv 1) (H 1)
         - (pderiv 1) (H 0) * (pderiv 0) (H 1)) := by
  unfold jacobianDet jacobianMatrix;
  simp +decide [ Fin.sum_univ_succ, Matrix.det_succ_row_zero ];
  ring

/-- The Jacobian condition det(J(I+H)) = 1 forces tr(JH) + det(JH) = 0. -/
theorem jac_sum_zero_2d
    (H : Fin 2 → MvPolynomial (Fin 2) K)
    (h_jac : jacobianDet (fun i => X i + H i) = 1) :
    (pderiv 0) (H 0) + (pderiv 1) (H 1)
      + ((pderiv 0) (H 0) * (pderiv 1) (H 1)
       - (pderiv 1) (H 0) * (pderiv 0) (H 1)) = 0 := by
  convert congr_arg (fun x : MvPolynomial (Fin 2) K => x - 1) h_jac using 1 <;> [rw [jacobianDet_identity_plus_2d]; skip] <;> ring

/-! ### Concrete verified automorphisms -/

/-- Triangular shear F(x,y) = (x + c·y², y) is a polynomial automorphism. -/
theorem quadratic_shear_is_auto (c : K) :
    isPolynomialAutomorphism
      (fun i => (![X (0 : Fin 2) + C c * X 1 ^ 2, X 1]) i) := by
  refine ⟨fun i => if i = 0 then X 0 - C c * X 1 ^ 2 else X 1, ?_, ?_⟩ <;>
    simp +decide [funext_iff, Fin.forall_fin_two] <;>
    simp +decide [polyMapComp, polyMapId]

/-- Non-trivial rank-1 quadratic: F(x,y) = (x + (x+y)², y - (x+y)²).
Inverse: G(x,y) = (x - (x+y)², y + (x+y)²). -/
theorem rank_one_quadratic_inverse_2d :
    isPolynomialInverse
      (fun i => (![X (0 : Fin 2) + (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2,
                   X (1 : Fin 2) - (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2]) i)
      (fun i => (![X (0 : Fin 2) - (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2,
                   X (1 : Fin 2) + (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2]) i) := by
  constructor <;> ext i <;> fin_cases i <;> norm_num [polyMapComp, polyMapId]

/-- The rank-1 map has Jacobian determinant 1. -/
theorem rank_one_quadratic_jacobian_det_one :
    jacobianDet
      (fun i => (![X (0 : Fin 2) + (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2,
                   X (1 : Fin 2) - (X 0 + X 1 : MvPolynomial (Fin 2) K) ^ 2]) i) =
      (1 : MvPolynomial (Fin 2) K) := by
  convert jacobianDet_identity_plus_2d _
  rotate_right
  exact fun i => if i = 0 then (X 0 + X 1) ^ 2 else -(X 0 + X 1) ^ 2
  · rename_i i; fin_cases i <;> simp +decide; ring
  · norm_num [sq]; ring
  · infer_instance

/-! ### Pointwise inverse formula -/

/-
**Key result:** For 2D homogeneous quadratic H with unit Jacobian,
the function-level inverse formula holds at every evaluation point.
This is the computational core of the quadratic Jacobian conjecture.
-/
set_option maxHeartbeats 800000 in
theorem jacobian_2d_homog_quad_eval_inverse
    (H : Fin 2 → MvPolynomial (Fin 2) K)
    (h_hom : ∀ i, (H i).IsHomogeneous 2)
    (h_jac : jacobianDet (fun i => X i + H i) = 1)
    (v : Fin 2 → K) (i : Fin 2) :
    MvPolynomial.eval (fun j => v j - MvPolynomial.eval v (H j))
      (X i + H i) = v i := by
  unfold jacobianDet at h_jac ; simp_all +decide [ Matrix.det_fin_two ];
  -- By definition of $H$, we know that $H_i$ is a homogeneous polynomial of degree 2.
  have h_homogeneous : ∀ i, ∃ a b c : K, H i = MvPolynomial.C a * X 0 ^ 2 + MvPolynomial.C b * X 0 * X 1 + MvPolynomial.C c * X 1 ^ 2 := by
    intro i
    have h_homogeneous_i : (H i).IsHomogeneous 2 := by
      fin_cases i <;> tauto;
    have h_homogeneous_i : ∀ m : Fin 2 →₀ ℕ, m ∈ (H i).support → m 0 + m 1 = 2 := by
      intro m hm; specialize h_homogeneous_i ( Finsupp.mem_support_iff.mp hm ) ; simp_all +decide [ Finsupp.sum_fintype ] ;
      simp_all +decide [ Finsupp.weight ];
      simp_all +decide [ Finsupp.linearCombination_apply, Finsupp.sum_fintype ];
    use (H i).coeff (Finsupp.single 0 2), (H i).coeff (Finsupp.single 0 1 + Finsupp.single 1 1), (H i).coeff (Finsupp.single 1 2);
    conv_lhs => rw [ MvPolynomial.as_sum ( H i ) ];
    rw [ Finset.sum_subset ( show ( H i |> MvPolynomial.support ) ⊆ { Finsupp.single 0 2, Finsupp.single 0 1 + Finsupp.single 1 1, Finsupp.single 1 2 } from ?_ ) ];
    · rw [ Finset.sum_insert, Finset.sum_insert ] <;> simp +decide [ MvPolynomial.monomial_eq ];
      · ring;
      · exact ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide );
      · exact ⟨ ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ), ne_of_apply_ne ( fun f => f 0 ) ( by simp +decide ) ⟩;
    · simp +contextual [ MvPolynomial.coeff_monomial ];
    · intro m hm; specialize h_homogeneous_i m hm; simp_all +decide [ Finsupp.ext_iff, Fin.forall_fin_two ] ;
      omega;
  choose a b c h using h_homogeneous; simp_all +decide [ jacobianMatrix ] ; ring;
  fin_cases i <;> simp +decide [ h ] <;> ring!;
  · have eq₁ := congr_arg ( MvPolynomial.eval ( fun i ↦ if i = 0 then 1 else 0 ) ) h_jac; have eq₂ := congr_arg ( MvPolynomial.eval ( fun i ↦ if i = 0 then 0 else 1 ) ) h_jac; have eq₃ := congr_arg ( MvPolynomial.eval ( fun i ↦ if i = 0 then 1 else 1 ) ) h_jac; have eq₄ := congr_arg ( MvPolynomial.eval ( fun i ↦ if i = 0 then 2 else 0 ) ) h_jac; have eq₅ := congr_arg ( MvPolynomial.eval ( fun i ↦ if i = 0 then 0 else 2 ) ) h_jac; norm_num at eq₁ eq₂ eq₃ eq₄ eq₅;
    grind +ring;
  · have eq₁ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 1 else 0 ) ) h_jac; have eq₂ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 0 else 1 ) ) h_jac; have eq₃ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 1 else 1 ) ) h_jac; have eq₄ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 2 else 0 ) ) h_jac; have eq₅ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 0 else 2 ) ) h_jac; have eq₆ := congr_arg ( MvPolynomial.eval ( fun i => if i = 0 then 2 else 2 ) ) h_jac; norm_num at eq₁ eq₂ eq₃ eq₄ eq₅ eq₆;
    grind +ring

/-
If det(J(I+H)) = 1 for homogeneous degree-2 H in 2 variables,
then det(J(I-H)) = 1 as well.
-/
theorem jacobianDet_neg_of_hom2
    (H : Fin 2 → MvPolynomial (Fin 2) K)
    (h_hom : ∀ i, (H i).IsHomogeneous 2)
    (h_jac : jacobianDet (fun i => X i + H i) = 1) :
    jacobianDet (fun i => X i - H i) = 1 := by
  have h_simplify : (pderiv 0 (H 0)) + (pderiv 1 (H 1)) = 0 ∧ (pderiv 0 (H 0) * pderiv 1 (H 1) - pderiv 1 (H 0) * pderiv 0 (H 1)) = 0 := by
    have h_deg : ∀ p : MvPolynomial (Fin 2) K, p.IsHomogeneous 2 → (pderiv 0 p).IsHomogeneous 1 ∧ (pderiv 1 p).IsHomogeneous 1 := by
      intro p hp
      have h_deg : ∀ i : Fin 2, (pderiv i p).IsHomogeneous 1 := by
        intro i
        have h_deg : (pderiv i p).IsHomogeneous (2 - 1) := by
          apply MvPolynomial.IsHomogeneous.pderiv hp
        exact h_deg
      exact ⟨h_deg 0, h_deg 1⟩;
    have h_deg : (pderiv 0 (H 0)) + (pderiv 1 (H 1)) + ((pderiv 0 (H 0)) * (pderiv 1 (H 1)) - (pderiv 1 (H 0)) * (pderiv 0 (H 1))) = 0 := by
      convert jac_sum_zero_2d H h_jac using 1;
    have h_deg : ∀ p : MvPolynomial (Fin 2) K, p.IsHomogeneous 1 → ∀ q : MvPolynomial (Fin 2) K, q.IsHomogeneous 2 → p + q = 0 → p = 0 ∧ q = 0 := by
      intros p hp q hq h_eq
      have h_deg : ∀ m : Fin 2 →₀ ℕ, m ∈ p.support → m ∈ q.support → False := by
        intro m hm₁ hm₂; have := hp ( by aesop : p.coeff m ≠ 0 ) ; have := hq ( by aesop : q.coeff m ≠ 0 ) ; simp_all +decide [ Finsupp.sum_fintype ] ;
      replace h_eq := congr_arg ( fun f => f.support ) h_eq ; simp_all +decide [ Finset.ext_iff ];
      constructor <;> ext m <;> specialize h_eq m <;> by_cases hm : coeff m p = 0 <;> aesop;
    apply h_deg;
    · exact MvPolynomial.IsHomogeneous.add ( ‹∀ p : MvPolynomial ( Fin 2 ) K, p.IsHomogeneous 2 → ( ( pderiv 0 ) p ).IsHomogeneous 1 ∧ ( ( pderiv 1 ) p ).IsHomogeneous 1› _ ( h_hom 0 ) |>.1 ) ( ‹∀ p : MvPolynomial ( Fin 2 ) K, p.IsHomogeneous 2 → ( ( pderiv 0 ) p ).IsHomogeneous 1 ∧ ( ( pderiv 1 ) p ).IsHomogeneous 1› _ ( h_hom 1 ) |>.2 );
    · grind +suggestions;
    · assumption;
  unfold jacobianDet;
  unfold jacobianMatrix; simp +decide [ *, Matrix.det_fin_two ] ;
  linear_combination' -h_simplify.1 + h_simplify.2

set_option maxHeartbeats 800000 in
/-- The eval-level formula for the G ∘ F direction: using -H. -/
theorem jacobian_2d_homog_quad_eval_inverse_neg
    (H : Fin 2 → MvPolynomial (Fin 2) K)
    (h_hom : ∀ i, (H i).IsHomogeneous 2)
    (h_jac : jacobianDet (fun i => X i + H i) = 1)
    (v : Fin 2 → K) (i : Fin 2) :
    MvPolynomial.eval (fun j => v j + MvPolynomial.eval v (H j))
      (X i - H i) = v i := by
  have h_neg_hom : ∀ i, (-H i).IsHomogeneous 2 := by
    -- Since $H_i$ is homogeneous of degree 2, $-H_i$ is also homogeneous of degree 2.
    intros i
    apply MvPolynomial.IsHomogeneous.neg
    apply h_hom
  have h_neg_jac : jacobianDet (fun i => X i - H i) = 1 := by
    convert jacobianDet_neg_of_hom2 H h_hom h_jac using 1
  have h_eval_neg : (eval (fun j => v j - (eval v (-H j))) (X i + (-H i))) = v i := by
    convert jacobian_2d_homog_quad_eval_inverse ( fun i => -H i ) h_neg_hom _ v i using 1;
    simpa only [ sub_eq_add_neg ] using h_neg_jac
  have h_eval : (eval (fun j => v j + (eval v (H j))) (X i - H i)) = v i := by
    grind
  exact h_eval

/-! ### The main dimension-2 result -/

/-
**Quadratic Jacobian Conjecture in Dimension 2.**
Every polynomial map F : K² → K² of the form F = I + H with H homogeneous
quadratic and det(JF) = 1, the map F admits a polynomial inverse.

The inverse is G = I - H. Both composition directions are verified
using the eval-level inverse formula and MvPolynomial.funext.
-/
theorem jacobian_conjecture_dim2_quadratic_homogeneous
    (H : Fin 2 → MvPolynomial (Fin 2) K)
    (h_hom : ∀ i, (H i).IsHomogeneous 2)
    (h_jac : jacobianDet (fun i => X i + H i) = 1) :
    isPolynomialAutomorphism (fun i => X i + H i) := by
  refine' ⟨ fun i => X i - H i, _, _ ⟩;
  · ext i
    simp [polyMapComp, polyMapId];
    -- By definition of bind₁, we have:
    have h_bind₁ : ∀ v : Fin 2 → K, MvPolynomial.eval v (MvPolynomial.bind₁ (fun i => X i - H i) (H i)) = MvPolynomial.eval (fun j => v j - MvPolynomial.eval v (H j)) (H i) := by
      intro v; induction' H i using MvPolynomial.induction_on with i p q hp hq; aesop;
      · simp +decide [ hp, hq ];
      · simp +decide [ *, MvPolynomial.eval_mul ];
    have h_eval : ∀ v : Fin 2 → K, MvPolynomial.eval v (MvPolynomial.bind₁ (fun i => X i - H i) (X i + H i)) = MvPolynomial.eval v (X i) := by
      intro v
      have := jacobian_2d_homog_quad_eval_inverse H h_hom h_jac v i
      simp_all +decide [ MvPolynomial.eval_add, MvPolynomial.eval_X ];
    have h_eval : MvPolynomial.bind₁ (fun i => X i - H i) (X i + H i) = X i := by
      exact MvPolynomial.funext fun v => by simpa using h_eval v;
    simp_all +decide [ MvPolynomial.bind₁_X_right ];
    grind;
  · ext i;
    -- By the properties of polynomial evaluation, if the evaluations are equal for all inputs, then the polynomials themselves must be equal.
    have h_poly_eq : ∀ v : Fin 2 → K, MvPolynomial.eval v (MvPolynomial.bind₁ (fun j => X j + H j) (X i - H i)) = MvPolynomial.eval v (X i) := by
      intro v;
      convert jacobian_2d_homog_quad_eval_inverse_neg H h_hom h_jac v i using 1;
      · induction' ( X i - H i ) using MvPolynomial.induction_on with i p q hp hq <;> simp_all +decide [ MvPolynomial.eval₂_add, MvPolynomial.eval₂_mul, MvPolynomial.eval₂_X ];
      · simp +decide;
    have h_poly_eq : MvPolynomial.bind₁ (fun j => X j + H j) (X i - H i) = X i := by
      exact MvPolynomial.funext fun v => by simpa using h_poly_eq v;
    exact congr_arg ( fun p => MvPolynomial.coeff ‹_› p ) h_poly_eq

end JacobianConjecture