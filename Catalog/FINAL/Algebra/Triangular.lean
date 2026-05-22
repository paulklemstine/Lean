/-
Copyright (c) 2025. All rights reserved.

# Triangular Polynomial Maps are Automorphisms

## Main Results

- `jacobianMatrix_triangular_diag` : The diagonal of the Jacobian is `C(a_i)`.
- `jacobianMatrix_triangular_upper_zero` : Upper entries are zero.
- `jacobianDet_triangular` : The Jacobian determinant is `C(∏ a_i)`.
- `triangular_isKellerMap` : Triangular maps with nonzero diagonal are Keller.
- `polyMapComp_isPolyAuto` : Composition preserves polynomial automorphism.
- `elementary_isPolyAuto` : Elementary maps are automorphisms.
- `triangular_isPolyAuto` : Triangular maps with nonzero diagonal are automorphisms.

## Keywords
triangular map, tame automorphism, elementary map, polynomial inverse
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix Finset

variable {k : Type*} [Field k] {n : ℕ}

/-! ### Key lemma: bind₁ preserves polynomials on identity-mapped variables -/

/-
If `G j = X j` for all variables `j` appearing in `q` (i.e., `j ∈ q.vars`),
    then `bind₁ G q = q`.
-/
theorem bind₁_eq_self_of_vars
    {R : Type*} [CommRing R] {σ : Type*}
    (G : σ → MvPolynomial σ R) (q : MvPolynomial σ R)
    (hG : ∀ j ∈ q.vars, G j = MvPolynomial.X j) :
    MvPolynomial.bind₁ G q = q := by
  -- We will show that the polynomial `q` can be decomposed into monomials `monomial m (coeff m q)` for all `m ∈ q.support`.
  have h_decomp : q = ∑ m ∈ q.support, MvPolynomial.monomial m (MvPolynomial.coeff m q) := by
    exact as_sum q;
  -- Apply the linearity of `bind₁` to distribute it over the sum.
  have h_bind₁_sum : (bind₁ G) q = ∑ m ∈ q.support, (bind₁ G) (MvPolynomial.monomial m (MvPolynomial.coeff m q)) := by
    conv_lhs => rw [ h_decomp, map_sum ] ;
  -- By definition of `bind₁`, we know that `bind₁ G (monomial m (coeff m q)) = C (coeff m q) * ∏ j ∈ m.support, (G j)^(m j)`.
  have h_bind₁_monomial : ∀ m ∈ q.support, (bind₁ G) (MvPolynomial.monomial m (MvPolynomial.coeff m q)) = MvPolynomial.C (MvPolynomial.coeff m q) * ∏ j ∈ m.support, (G j)^(m j) := by
    simp +decide [ MvPolynomial.bind₁_monomial ];
  -- Since `G j = X j` for all `j ∈ q.vars`, we can replace `G j` with `X j` in the product.
  have h_replace : ∀ m ∈ q.support, ∏ j ∈ m.support, (G j)^(m j) = ∏ j ∈ m.support, (MvPolynomial.X j)^(m j) := by
    intro m hm
    apply Finset.prod_congr rfl
    intro j hj
    have h_j_vars : j ∈ q.vars := by
      simp +decide [ MvPolynomial.mem_vars, hj ];
      exact ⟨ m, Finsupp.mem_support_iff.mp hm, Finsupp.mem_support_iff.mp hj ⟩
    rw [hG j h_j_vars];
  rw [ h_bind₁_sum, Finset.sum_congr rfl fun m hm => by rw [ h_bind₁_monomial m hm, h_replace m hm ] ];
  convert h_decomp.symm using 2;
  simp +decide [ MvPolynomial.monomial_eq ]

/-- If `G j = X j` for all `j < idx`, and `q` depends only on variables `< idx`,
    then `bind₁ G q = q`. -/
theorem bind₁_eq_self_of_dependsOnlyBelow
    (G : PolyMap k n) (idx : Fin n) (q : MvPolynomial (Fin n) k)
    (hG : ∀ j : Fin n, j < idx → G j = MvPolynomial.X j)
    (hq : dependsOnlyBelow q idx) :
    MvPolynomial.bind₁ G q = q :=
  bind₁_eq_self_of_vars G q (fun j hj => hG j (hq j hj))

/-! ### Jacobian of triangular maps -/

theorem jacobianMatrix_triangular_diag
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a) (i : Fin n) :
    jacobianMatrix F i i = MvPolynomial.C (a i) := by
  have h_deriv_zero : ∀ q : MvPolynomial (Fin n) k, dependsOnlyBelow q i → MvPolynomial.pderiv i q = 0 := by
    intro q hq;
    convert MvPolynomial.pderiv_eq_zero_of_notMem_vars _;
    exact fun hi => lt_irrefl _ ( hq _ hi );
  convert congr_arg ( fun x => x + C ( a i ) ) ( h_deriv_zero ( F i - C ( a i ) * X i ) ( htri i ) ) using 1 ; simp +decide [ jacobianMatrix ];
  rw [ zero_add ]

theorem jacobianMatrix_triangular_upper_zero
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a)
    (i j : Fin n) (hij : i < j) :
    jacobianMatrix F i j = 0 := by
  -- By definition of jacobianMatrix, we have jacobianMatrix F i j = pderiv j (F i).
  have h_jacobian_def : jacobianMatrix F i j = MvPolynomial.pderiv j (F i) := by
    rfl;
  -- By definition of $IsTriangularMap$, we know that $F_i - C(a_i) * X_i$ depends only on variables less than $i$.
  have h_dependsOnlyBelow : dependsOnlyBelow (F i - MvPolynomial.C (a i) * MvPolynomial.X i) i := by
    exact htri i;
  -- Since $j > i$, we have $pderiv j (F i - C(a i) * X i) = 0$.
  have h_pderiv_zero : MvPolynomial.pderiv j (F i - MvPolynomial.C (a i) * MvPolynomial.X i) = 0 := by
    unfold dependsOnlyBelow at h_dependsOnlyBelow;
    rw [ MvPolynomial.pderiv_def ];
    grind +suggestions;
  grind +suggestions

theorem jacobianDet_triangular
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a) :
    jacobianDet F = MvPolynomial.C (∏ i, a i) := by
  unfold jacobianDet
  rw [Matrix.det_of_lowerTriangular (jacobianMatrix F)]
  · simp [jacobianMatrix_triangular_diag F a htri]
  · intro i j hij
    exact jacobianMatrix_triangular_upper_zero F a htri i j hij

theorem triangular_isKellerMap
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a)
    (hunit : ∀ i, a i ≠ 0) :
    isKellerMap F := by
  refine ⟨∏ i, a i, ?_, jacobianDet_triangular F a htri⟩
  exact (Finset.prod_ne_zero_iff.mpr (fun i _ => hunit i))

/-! ### Composition preserves automorphism -/

theorem polyMapComp_assoc (F G H : PolyMap k n) :
    polyMapComp (polyMapComp F G) H = polyMapComp F (polyMapComp G H) := by
  funext i
  apply MvPolynomial.bind₁_bind₁

theorem polyMapComp_isPolyAuto (F G : PolyMap k n)
    (hF : isPolyAuto F) (hG : isPolyAuto G) :
    isPolyAuto (polyMapComp F G) := by
  obtain ⟨ F', hF' ⟩ := hF
  obtain ⟨ G', hG' ⟩ := hG
  use polyMapComp G' F'
  constructor <;> simp_all +decide [ isPolyInverse ]
  · simp_all +decide [ polyMapComp_assoc ]
    simp_all +decide [ ← polyMapComp_assoc ]
    simp_all +decide [ polyMapComp_id_right ]
  · convert congr_arg ( fun f => polyMapComp G' f ) ( congr_arg ( fun f => polyMapComp f G ) hF'.2 ) using 1
    · convert polyMapComp_assoc _ _ _ using 2
      exact polyMapComp_assoc _ _ _
    · simp +decide [ polyMapComp_id_right, hG'.2 ]
      rw [ polyMapComp_id_left, hG'.2 ]

/-! ### Elementary maps -/

noncomputable def elementaryMap (idx : Fin n)
    (a : k) (p : MvPolynomial (Fin n) k) : PolyMap k n :=
  fun i => if i = idx then MvPolynomial.C a * MvPolynomial.X i + p
           else MvPolynomial.X i

noncomputable def elementaryMapInv (idx : Fin n)
    (a : k) (p : MvPolynomial (Fin n) k) : PolyMap k n :=
  fun i => if i = idx then MvPolynomial.C a⁻¹ * (MvPolynomial.X i - p)
           else MvPolynomial.X i

theorem elementaryMap_comp_inv (idx : Fin n)
    (a : k) (ha : a ≠ 0) (p : MvPolynomial (Fin n) k)
    (hp : dependsOnlyBelow p idx) :
    polyMapComp (elementaryMap idx a p) (elementaryMapInv idx a p) = polyMapId := by
  nontriviality;
  ext i;
  by_cases hi : i = idx <;> simp +decide [ hi, polyMapComp, polyMapId, elementaryMap, elementaryMapInv ];
  -- By definition of bind₁, we know that bind₁ (elementaryMapInv idx a p) p = p.
  have h_bind₁ : bind₁ (elementaryMapInv idx a p) p = p := by
    apply bind₁_eq_self_of_dependsOnlyBelow;
    exacts [ fun j hj => if_neg hj.ne, hp ];
  simp +decide [ ← mul_assoc, ha, h_bind₁ ]

theorem elementaryMapInv_comp (idx : Fin n)
    (a : k) (ha : a ≠ 0) (p : MvPolynomial (Fin n) k)
    (hp : dependsOnlyBelow p idx) :
    polyMapComp (elementaryMapInv idx a p) (elementaryMap idx a p) = polyMapId := by
  ext i;
  by_cases hi : i = idx <;> simp +decide [ *, polyMapComp, polyMapId, elementaryMap, elementaryMapInv ];
  -- By definition of bind₁, we know that bind₁ (elementaryMap idx a p) p = p.
  have h_bind₁ : MvPolynomial.bind₁ (elementaryMap idx a p) p = p := by
    apply bind₁_eq_self_of_dependsOnlyBelow;
    exacts [ fun j hj => if_neg hj.ne, hp ];
  grind

theorem elementary_isPolyAuto (idx : Fin n)
    (a : k) (ha : a ≠ 0) (p : MvPolynomial (Fin n) k)
    (hp : dependsOnlyBelow p idx) :
    isPolyAuto (elementaryMap idx a p) :=
  ⟨elementaryMapInv idx a p,
   elementaryMap_comp_inv idx a ha p hp,
   elementaryMapInv_comp idx a ha p hp⟩

/-! ### Triangular maps are automorphisms -/

/-
Helper: bind₁ of an elementary map on a polynomial not involving the changed variable.
-/
theorem bind₁_elementaryMap_of_not_mem_vars (idx : Fin n)
    (a : k) (p q : MvPolynomial (Fin n) k)
    (hq : idx ∉ q.vars) :
    MvPolynomial.bind₁ (elementaryMap idx a p) q = q := by
  -- For j ∈ q.vars, j ≠ idx, so elementaryMap idx a p j = X j. Therefore bind₁ (elementaryMap ...) q = q by bind₁_eq_self_of_vars (since on the relevant variables, the substitution is identity).
  apply bind₁_eq_self_of_vars
  intro j hj
  simp [elementaryMap, hq, hj];
  grind

/-- Partial triangular map: agrees with F on indices ≤ k, is identity above k. -/
noncomputable def partialTriangularMap
    (F : PolyMap k n) (k_idx : ℕ) : PolyMap k n :=
  fun i => if i.val < k_idx then F i else MvPolynomial.X i

/-- The partial triangular map at 0 is the identity. -/
theorem partialTriangularMap_zero (F : PolyMap k n) :
    partialTriangularMap F 0 = polyMapId := by
  ext i; simp [partialTriangularMap, polyMapId]

/-- The partial triangular map at n is F itself. -/
theorem partialTriangularMap_n (F : PolyMap k n) :
    partialTriangularMap F n = F := by
  ext i; simp [partialTriangularMap, i.isLt]

/-
Key step: partialTriangularMap F (k+1) = polyMapComp (partialTriangularMap F k) (elementaryMap ...)
-/
theorem partialTriangularMap_succ
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a)
    (k_idx : ℕ) (hk : k_idx < n) :
    partialTriangularMap F (k_idx + 1) =
      polyMapComp (partialTriangularMap F k_idx)
        (elementaryMap ⟨k_idx, hk⟩ (a ⟨k_idx, hk⟩)
          (F ⟨k_idx, hk⟩ - MvPolynomial.C (a ⟨k_idx, hk⟩) * MvPolynomial.X ⟨k_idx, hk⟩)) := by
  ext i;
  by_cases hi : i.val < k_idx <;> by_cases hi' : i.val = k_idx <;> simp_all +decide [ partialTriangularMap, polyMapComp, elementaryMap ];
  · rw [ if_pos hi.le, bind₁_elementaryMap_of_not_mem_vars ];
    have := htri i;
    intro h;
    have := this ⟨ k_idx, hk ⟩ ?_ <;> simp_all +decide [ dependsOnlyBelow ];
    · grind;
    · grind +suggestions;
  · cases i ; aesop;
  · rw [ if_neg ( not_le_of_gt ( lt_of_le_of_ne hi ( Ne.symm hi' ) ) ), if_neg ( not_lt_of_ge hi ) ];
    unfold elementaryMap; aesop;

/-
The partial triangular map at k is a polynomial automorphism.
-/
theorem partialTriangularMap_isPolyAuto
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a)
    (hunit : ∀ i, a i ≠ 0) (k_idx : ℕ) (hk : k_idx ≤ n) :
    isPolyAuto (partialTriangularMap F k_idx) := by
  induction' k_idx with k ih;
  · exact isPolyAuto_id;
  · convert polyMapComp_isPolyAuto _ _ _ _;
    convert partialTriangularMap_succ F a htri k ( Nat.lt_of_succ_le hk );
    · exact ih ( Nat.le_of_succ_le hk );
    · exact elementary_isPolyAuto _ _ ( hunit _ ) _ ( htri _ )

/-- **Main theorem: Triangular polynomial maps with nonzero diagonal coefficients
    are polynomial automorphisms.** -/
theorem triangular_isPolyAuto
    (F : PolyMap k n) (a : Fin n → k) (htri : IsTriangularMap F a)
    (hunit : ∀ i, a i ≠ 0) :
    isPolyAuto F := by
  rw [← partialTriangularMap_n F]
  exact partialTriangularMap_isPolyAuto F a htri hunit n le_rfl

end JacobianConjecture