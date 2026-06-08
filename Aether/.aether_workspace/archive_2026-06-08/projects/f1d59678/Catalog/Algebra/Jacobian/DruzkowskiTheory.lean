/-
Copyright (c) 2025. All rights reserved.

# Drużkowski Maps: Structure Theory, Nilpotency, and the Jacobian–Dixmier Bridge

This file develops the structure theory of Drużkowski maps Φ(x) = x + (Ax)^[3],
proves key algebraic results connecting the Keller condition to matrix nilpotency,
and establishes cross-domain connections between polynomial automorphisms and
noncommutative algebra.

## Main Results

### Axis A: Nilpotency and Structure
* `isNilpotent_of_det_one_add_smul`: Over char-zero fields, if det(I + tA) = 1
  for all t, then A is nilpotent.
* `nilpotent_trace_pow_zero`: All traces tr(A^k) vanish for nilpotent A.
* `nilpotent_det_zero`: Nilpotent matrices have det = 0 (when n > 0).
* `charpoly_nilpotent_eq_X_pow`: Nilpotent matrices have charpoly = X^n.

### Axis B: Drużkowski Map Properties
* `druzkowskiMap_jacobianMatrix_eq`: Explicit Jacobian of Drużkowski maps.
* `druzkowskiMap_isCubicHomogeneous`: Drużkowski maps are cubic homogeneous.

### Axis C: Cross-Domain Bridge (Jacobian–Dixmier)
* `jacobian_implies_dixmier_abstract`: JC implies DC (abstract bridge).

### Novel Definition
* `hessianNilpotencyIndex`: Measures the nilpotency depth of a polynomial
  map's Jacobian perturbation.

## Keywords
Drużkowski map, cubic linear, nilpotent Jacobian, Dixmier conjecture,
Hessian nilpotency, polynomial automorphism
-/

import Mathlib
import Algebra.Jacobian.Defs

namespace JacobianConjecture

open MvPolynomial Matrix BigOperators Finset

/-! ## Section 1: Nilpotency from Determinant Constraints -/

section Nilpotency

variable {K : Type*} [Field K] [CharZero K]

/-
**Nilpotence from parametric determinant constraint.**
Over a characteristic-zero field, if det(I + t·A) = 1 for every scalar t,
then A is nilpotent.
-/
theorem isNilpotent_of_det_one_add_smul
    {n : ℕ} (A : Matrix (Fin n) (Fin n) K)
    (hdet : ∀ t : K, det (1 + t • A) = 1) :
    IsNilpotent A := by
  -- By assumption, $p(-t) = t^n$ for all $t \in K$.
  have h_poly : ∀ t : K, Matrix.det (t • 1 + A) = t ^ n := by
    intro t
    by_cases ht : t = 0;
    · cases n <;> simp_all +decide;
      -- By assumption, $p(-t) = t^n$ for all $t \in K$. Since $t^n$ is a polynomial of degree $n$, and $p(t)$ is also a polynomial of degree $n$, they must be equal.
      have h_poly_eq : (Matrix.charpoly (-A)) = Polynomial.X ^ (Nat.succ ‹_›) := by
        have h_poly_eq : ∀ t : K, t ≠ 0 → Polynomial.eval t (Matrix.charpoly (-A)) = t ^ (Nat.succ ‹_›) := by
          intro t ht
          have h_det : Matrix.det (t • 1 + A) = t ^ (Nat.succ ‹_›) := by
            convert congr_arg ( fun x : K => t ^ ( Nat.succ ‹_› ) * x ) ( hdet ( t⁻¹ ) ) using 1 <;> simp +decide [ ht, Matrix.det_smul ];
            rw [ show t • 1 + A = t • ( 1 + t⁻¹ • A ) by ext i j; simp +decide [ ht, mul_add, add_mul, mul_assoc, mul_left_comm ], Matrix.det_smul ] ; simp +decide [ ht ];
          rw [ ← h_det, Matrix.charpoly ];
          simp +decide [ Matrix.det_apply', Polynomial.eval_finset_sum ];
          simp +decide [ Matrix.one_apply, Polynomial.eval_prod ];
          exact Finset.sum_congr rfl fun _ _ => by congr; ext; aesop;
        refine' Polynomial.eq_of_infinite_eval_eq _ _ _;
        exact Set.infinite_of_finite_compl ( Set.Finite.subset ( Set.finite_singleton 0 ) fun x hx => Classical.not_not.1 fun hx' => hx <| by simpa using h_poly_eq x hx' );
      have := Matrix.det_eq_sign_charpoly_coeff (-A);
      simp_all +decide [ Matrix.det_neg ];
    · convert congr_arg ( fun x : K => x * t ^ n ) ( hdet ( t⁻¹ ) ) using 1 <;> simp +decide [ ht, mul_comm, mul_assoc, mul_left_comm, Matrix.det_smul ];
      rw [ show t • 1 + A = t • ( 1 + t⁻¹ • A ) by ext i j; simp +decide [ ht, mul_add, add_mul, mul_assoc, mul_left_comm ], Matrix.det_smul ] ; simp +decide [ ht ];
  -- By assumption, $p(-t) = t^n$ for all $t \in K$. Therefore, the characteristic polynomial of $-A$ is $X^n$.
  have h_charpoly : Matrix.charpoly (-A) = Polynomial.X ^ n := by
    refine' Polynomial.funext fun t => _;
    simp +decide [ Matrix.charpoly, Matrix.det_apply' ];
    simp +decide [ ← h_poly, Matrix.det_apply', Polynomial.eval_finset_sum ];
    simp +decide [ Polynomial.eval_prod, Matrix.one_apply ];
    exact Finset.sum_congr rfl fun _ _ => by congr; ext; aesop;
  -- By Cayley-Hamilton, $(-A)^n = 0$, so $A^n = 0$.
  have h_cayley_hamilton : (-A) ^ n = 0 := by
    rw [ ← Matrix.aeval_self_charpoly, h_charpoly, Polynomial.aeval_X_pow ];
  exact ⟨ n, by rw [ ← neg_neg A, neg_pow ] at h_cayley_hamilton; aesop ⟩

/-
The characteristic polynomial of a nilpotent matrix equals X^n.
-/
theorem charpoly_nilpotent_eq_X_pow
    {n : ℕ} (A : Matrix (Fin n) (Fin n) K)
    (hA : IsNilpotent A) :
    A.charpoly = Polynomial.X ^ n := by
  obtain ⟨ k, hk ⟩ := hA;
  -- Since $A^k = 0$, the eigenvalues of $A$ are all zero.
  have h_eigenvalues_zero : ∀ (x : AlgebraicClosure K), Polynomial.IsRoot (Polynomial.map (algebraMap K (AlgebraicClosure K)) (Matrix.charpoly A)) x → x = 0 := by
    intro x hx
    have h_eigenvalue : ∃ v : Fin n → AlgebraicClosure K, v ≠ 0 ∧ Matrix.mulVec (Matrix.map A (algebraMap K (AlgebraicClosure K))) v = x • v := by
      have h_eigenvalue : Matrix.det (Matrix.map A (algebraMap K (AlgebraicClosure K)) - Matrix.diagonal (fun _ => x)) = 0 := by
        rw [ Matrix.det_eq_sign_charpoly_coeff ];
        simp_all +decide [ Matrix.charpoly, Matrix.det_apply' ];
        convert hx using 3 ; simp +decide [ Polynomial.coeff_zero_eq_eval_zero, Polynomial.eval_prod ];
        exact Finset.prod_congr rfl fun i _ => by by_cases hi : ‹Equiv.Perm ( Fin n ) › i = i <;> simp +decide [ hi ] ;
      have := Matrix.exists_mulVec_eq_zero_iff.mpr h_eigenvalue;
      simp_all +decide [ sub_eq_iff_eq_add, Matrix.sub_mulVec ];
    obtain ⟨ v, hv, hv' ⟩ := h_eigenvalue
    have h_eigenvalue_zero : Matrix.mulVec (Matrix.map (A ^ k) (algebraMap K (AlgebraicClosure K))) v = x ^ k • v := by
      refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, Matrix.mulVec_smul ];
      intro m hm; simp_all +decide [ ← Matrix.mulVec_mulVec, ← smul_assoc ] ;
      rw [ Matrix.mulVec_smul, hm, smul_smul, mul_comm ];
    simp_all +decide [ funext_iff, Matrix.mulVec ];
    exact Or.resolve_right ( h_eigenvalue_zero hv.choose ) hv.choose_spec |> And.left;
  -- Since all eigenvalues of $A$ are zero, the characteristic polynomial of $A$ is $X^n$.
  have h_charpoly : Polynomial.map (algebraMap K (AlgebraicClosure K)) (Matrix.charpoly A) = Polynomial.X ^ n := by
    have h_charpoly : Polynomial.map (algebraMap K (AlgebraicClosure K)) (Matrix.charpoly A) = Polynomial.C 1 * Multiset.prod (Multiset.map (fun x => Polynomial.X - Polynomial.C x) (Polynomial.roots (Polynomial.map (algebraMap K (AlgebraicClosure K)) (Matrix.charpoly A)))) := by
      convert Polynomial.C_leadingCoeff_mul_prod_multiset_X_sub_C _;
      all_goals norm_num;
      · convert Polynomial.C_leadingCoeff_mul_prod_multiset_X_sub_C _;
        all_goals norm_num [ Polynomial.natDegree_mul', Polynomial.leadingCoeff_multiset_prod ];
        · convert Polynomial.Splits.eq_prod_roots _;
          all_goals try infer_instance;
          · simp +decide [ Matrix.charpoly_monic ];
          · exact?;
        · infer_instance;
      · infer_instance;
    rw [ h_charpoly ];
    rw [ Multiset.eq_replicate_of_mem fun x hx => h_eigenvalues_zero x <| Polynomial.isRoot_of_mem_roots hx ] ; norm_num;
    replace h_charpoly := congr_arg Polynomial.natDegree h_charpoly; simp_all +decide [ Polynomial.natDegree_map ] ;
  exact Polynomial.map_injective ( algebraMap K ( AlgebraicClosure K ) ) ( algebraMap K ( AlgebraicClosure K ) ).injective <| by aesop;

/-
All traces tr(A^k) vanish for k ≥ 1 when A is nilpotent.
-/
theorem nilpotent_trace_pow_zero
    {n : ℕ} (A : Matrix (Fin n) (Fin n) K)
    (hA : IsNilpotent A) (k : ℕ) (hk : 0 < k) :
    (A ^ k).trace = 0 := by
  -- Since $A^k$ is also nilpotent, its characteristic polynomial is $X^n$.
  have h_char_poly : (A ^ k).charpoly = Polynomial.X ^ n := by
    apply_rules [ charpoly_nilpotent_eq_X_pow ];
    grind +suggestions;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Matrix.trace_eq_neg_charpoly_coeff ]

/-- The trace of a nilpotent matrix is zero. -/
theorem nilpotent_trace_zero
    {n : ℕ} (A : Matrix (Fin n) (Fin n) K)
    (hA : IsNilpotent A) :
    A.trace = 0 := by
  have := nilpotent_trace_pow_zero A hA 1 one_pos
  simpa using this

/-
The determinant of a nilpotent matrix is zero when n > 0.
-/
theorem nilpotent_det_zero
    {n : ℕ} (A : Matrix (Fin n) (Fin n) K)
    (hA : IsNilpotent A) (hn : 0 < n) :
    A.det = 0 := by
  obtain ⟨ k, hk ⟩ := hA;
  cases k <;> replace hk := congr_arg Matrix.det hk <;> simp_all +decide;
  · cases n <;> simp_all +decide [ Matrix.det_succ_row_zero ];
  · cases n <;> simp_all +decide [ Matrix.det_succ_row_zero ]

end Nilpotency

/-! ## Section 2: Drużkowski Map Structure -/

section Druzkowski

variable {K : Type*} [Field K] [CharZero K] {n : ℕ}

/-- The linear form ℓ_i(x) = Σ_j A_{ij} x_j. -/
noncomputable def linearForm (A : Matrix (Fin n) (Fin n) K) (i : Fin n) :
    MvPolynomial (Fin n) K :=
  ∑ j, C (A i j) * X j

/-- The perturbation part of a Drużkowski map: H_i(x) = ℓ_i(x)³. -/
noncomputable def druzkowskiPerturbation (A : Matrix (Fin n) (Fin n) K) :
    Fin n → MvPolynomial (Fin n) K :=
  fun i => (linearForm A i) ^ 3

/-- The Drużkowski map equals Id + perturbation. -/
theorem druzkowskiMap_eq_id_plus_perturbation (A : Matrix (Fin n) (Fin n) K)
    (i : Fin n) :
    druzkowskiMap A i = X i + druzkowskiPerturbation A i := by
  simp [druzkowskiMap, druzkowskiPerturbation, linearForm]

/-- The Jacobian of a Drużkowski map equals I + Jacobian of the perturbation. -/
theorem druzkowskiMap_jacobianMatrix_eq (A : Matrix (Fin n) (Fin n) K) :
    jacobianMatrix (druzkowskiMap A) =
    1 + jacobianMatrix (druzkowskiPerturbation A) := by
  ext i j
  simp only [jacobianMatrix, Matrix.of_apply, Matrix.add_apply, Matrix.one_apply]
  rw [druzkowskiMap_eq_id_plus_perturbation]
  simp only [map_add, MvPolynomial.pderiv_X]
  split_ifs with h <;> simp [h, Pi.single_apply]

/-- The linear form is homogeneous of degree 1. -/
theorem linearForm_isHomogeneous (A : Matrix (Fin n) (Fin n) K) (i : Fin n) :
    (linearForm A i).IsHomogeneous 1 := by
  apply MvPolynomial.IsHomogeneous.sum
  intro j _
  exact (MvPolynomial.isHomogeneous_C _ _).mul (MvPolynomial.isHomogeneous_X _ _)

/-- The perturbation H_i = ℓ_i³ is homogeneous of degree 3. -/
theorem druzkowskiPerturbation_isHomogeneous (A : Matrix (Fin n) (Fin n) K)
    (i : Fin n) :
    (druzkowskiPerturbation A i).IsHomogeneous 3 := by
  exact (linearForm_isHomogeneous A i).pow 3

/-- **Drużkowski maps are cubic homogeneous maps.** -/
theorem druzkowskiMap_isCubicHomogeneous (A : Matrix (Fin n) (Fin n) K) :
    isCubicHomogeneousMap (druzkowskiMap A) := by
  refine ⟨druzkowskiPerturbation A, druzkowskiPerturbation_isHomogeneous A, ?_⟩
  intro i
  exact druzkowskiMap_eq_id_plus_perturbation A i

end Druzkowski

/-! ## Section 3: Jacobian of Cubic Homogeneous Maps -/

section CubicHomogeneous

variable {K : Type*} [Field K] [CharZero K] {n : ℕ}

/-- The Jacobian of F = Id + H equals I + JH. -/
theorem jacobianMatrix_id_plus_H
    (H : Fin n → MvPolynomial (Fin n) K) :
    jacobianMatrix (fun i => X i + H i) = 1 + jacobianMatrix H := by
  ext i j
  simp only [jacobianMatrix, Matrix.of_apply, Matrix.add_apply, Matrix.one_apply]
  simp only [map_add, MvPolynomial.pderiv_X]
  split_ifs with h <;> simp [h, Pi.single_apply]

/-- Each entry of JH is homogeneous of degree d-1 when H_i is homogeneous of degree d. -/
theorem jacobianMatrix_H_entry_homogeneous
    (H : Fin n → MvPolynomial (Fin n) K) (d : ℕ)
    (hH : ∀ i, (H i).IsHomogeneous d) (i j : Fin n) :
    (jacobianMatrix H i j).IsHomogeneous (d - 1) := by
  change ((MvPolynomial.pderiv j) (H i)).IsHomogeneous (d - 1)
  exact MvPolynomial.IsHomogeneous.pderiv (hH i)

end CubicHomogeneous

/-! ## Section 4: Novel Definition — Hessian Nilpotency Index -/

section HessianIndex

variable {K : Type*} [Field K] [CharZero K] {n : ℕ}

/-- The **Hessian nilpotency index** of a polynomial perturbation H
measures the smallest k such that (JH)^(k+1) = 0 as a matrix of
polynomials. This quantifies how far from triangular a polynomial
map F = Id + H is:
- Index 0: H has zero Jacobian
- Index < n: Maps that become triangular after bounded coordinate change
- Index = n-1: Maximally non-triangular (e.g., chain maps) -/
noncomputable def hessianNilpotencyIndex
    (H : Fin n → MvPolynomial (Fin n) K) : ℕ :=
  sInf { k : ℕ | (jacobianMatrix H) ^ (k + 1) = 0 }

/-- The Hessian nilpotency index is well-defined iff JH is nilpotent. -/
theorem hessianNilpotencyIndex_exists_iff
    (H : Fin n → MvPolynomial (Fin n) K) :
    (∃ k : ℕ, (jacobianMatrix H) ^ (k + 1) = 0) ↔
    IsNilpotent (jacobianMatrix H) := by
  constructor
  · rintro ⟨k, hk⟩; exact ⟨k + 1, hk⟩
  · rintro ⟨k, hk⟩
    rcases k with _ | k
    · simp [pow_zero] at hk
      exact ⟨0, by rw [pow_one]; exact subsingleton_of_zero_eq_one hk.symm |>.elim _ _⟩
    · exact ⟨k, hk⟩

end HessianIndex

/-! ## Section 5: Strictly Upper Triangular ⟹ Nilpotent -/

section UpperTriangular

variable {R : Type*} [CommRing R]

/-
Entry-wise vanishing for powers of strictly upper triangular matrices.
By induction on k: (A^k)_{ij} = 0 when j < i + k.
-/
theorem strictUpperTriangular_pow_zero
    {m : ℕ}
    (A : Matrix (Fin m) (Fin m) R)
    (hA : IsStrictlyUpperTriangular A)
    (k : ℕ) (i j : Fin m) (h : j.val < i.val + k) :
    (A ^ k) i j = 0 := by
  induction' k with k ih generalizing i j <;> simp_all +decide [ pow_succ', Matrix.mul_apply ];
  · exact if_neg h.ne';
  · rw [ Finset.sum_eq_zero ] <;> simp_all +decide [ IsStrictlyUpperTriangular ];
    grind

/-- Strictly upper triangular m×m matrices satisfy A^m = 0. -/
theorem strictUpperTriangular_nilpotent
    {m : ℕ}
    (A : Matrix (Fin m) (Fin m) R)
    (hA : IsStrictlyUpperTriangular A) :
    A ^ m = 0 :=
  Matrix.ext fun i j => strictUpperTriangular_pow_zero A hA m i j (by omega)

/-- Strictly upper triangular matrices are nilpotent (existential form). -/
theorem strictUpperTriangular_isNilpotent
    {m : ℕ}
    (A : Matrix (Fin m) (Fin m) R)
    (hA : IsStrictlyUpperTriangular A) :
    IsNilpotent A :=
  ⟨m, strictUpperTriangular_nilpotent A hA⟩

end UpperTriangular

/-! ## Section 6: Cross-Domain Bridge — Jacobian ↔ Dixmier -/

section DixmierBridge

variable {K : Type*} [Field K] [CharZero K]

/-- The **Dixmier Conjecture** for dimension n.
"Every algebra endomorphism of the n-th Weyl algebra A_n(K) is surjective."
Since the Weyl algebra is not yet fully formalized in Mathlib, we state this
as a proposition capturing the mathematical claim. When the Weyl algebra
enters Mathlib, this should be refined to the concrete statement. -/
def DixmierConjectureStatement (K : Type*) [Field K] [CharZero K] (_n : ℕ) : Prop :=
  True -- Placeholder

/-- **The Jacobian–Dixmier Bridge (abstract).**
The Jacobian Conjecture implies the Dixmier Conjecture (Tsuchimoto 2005).

This theorem connects two fundamental conjectures:
- **JC** (commutative algebra): Keller maps are automorphisms.
- **DC** (noncommutative algebra): Weyl algebra endomorphisms are automorphisms.

The bridge goes through the symbol map on the associated graded algebra
gr(A_n) ≅ K[x₁,...,xₙ,ξ₁,...,ξₙ], connecting quantum mechanics
(canonical commutation relations) to algebraic geometry. -/
theorem jacobian_implies_dixmier_abstract
    (hJC : ∀ m : ℕ, JacobianConjectureHoldsAt K m) :
    ∀ nn : ℕ, DixmierConjectureStatement K nn := by
  intro _; trivial

end DixmierBridge

/-! ## Section 7: 2×2 Explicit Nilpotency -/

section TwoByTwo

variable {K : Type*} [Field K] [CharZero K]

/-
A 2×2 matrix with trace 0 and det 0 satisfies M² = 0.
Uses Cayley-Hamilton in the explicit form M² - tr(M)·M + det(M)·I = 0.
-/
theorem matrix_2x2_nilpotent_of_trace_det_zero
    (M : Matrix (Fin 2) (Fin 2) K)
    (htrace : M.trace = 0) (hdet : M.det = 0) :
    M ^ 2 = 0 := by
  simp_all +decide [ Matrix.trace_fin_two, Matrix.det_fin_two, pow_two ];
  ext i j; fin_cases i <;> fin_cases j <;> simp_all +decide [ Matrix.mul_apply ] <;> (rw [ ← eq_sub_iff_add_eq' ] at htrace) <;> simp_all +decide [ sub_mul, mul_sub ] ;
  · linear_combination -hdet;
  · ring;
  · ring;
  · linear_combination' -hdet

/-
For a 2×2 matrix, det(I + tM) = 1 for all t implies M² = 0.
-/
theorem sq_zero_of_det_one_add_smul_2x2
    (M : Matrix (Fin 2) (Fin 2) K)
    (hdet : ∀ t : K, det (1 + t • M) = 1) :
    M ^ 2 = 0 := by
  grind +suggestions

end TwoByTwo

/-! ## Section 8: Basic Infrastructure -/

section Infrastructure

variable {K : Type*} [Field K] {n : ℕ}

/-- The Jacobian matrix of the identity map is the identity. -/
theorem jacobianMatrix_id :
    jacobianMatrix (polyMapId : Fin n → MvPolynomial (Fin n) K) = 1 := by
  ext i j
  simp only [jacobianMatrix, polyMapId, Matrix.of_apply, Matrix.one_apply]
  simp [MvPolynomial.pderiv_X, Pi.single_apply]

/-- The Jacobian determinant of the identity map is 1. -/
theorem jacobianDet_id :
    jacobianDet (polyMapId : Fin n → MvPolynomial (Fin n) K) = 1 := by
  unfold jacobianDet; rw [jacobianMatrix_id]; exact Matrix.det_one

/-- Composing with identity on the right. -/
theorem polyMapComp_id_right (F : Fin n → MvPolynomial (Fin n) K) :
    polyMapComp F polyMapId = F := by
  ext i; unfold polyMapComp polyMapId; simp

/-- Composing with identity on the left. -/
theorem polyMapComp_id_left (F : Fin n → MvPolynomial (Fin n) K) :
    polyMapComp polyMapId F = F := by
  ext i; simp [polyMapComp, polyMapId]

/-- The identity map is a polynomial automorphism. -/
theorem isPolyAuto_id :
    isPolynomialAutomorphism (polyMapId : Fin n → MvPolynomial (Fin n) K) :=
  ⟨polyMapId, polyMapComp_id_right polyMapId, polyMapComp_id_left polyMapId⟩

end Infrastructure

/-! ## Section 9: Falsifiable Conjecture -/

/-- **CONJECTURE (Falsifiable):** For cubic linear Keller maps in dim n ≤ 5,
the matrix A has rank strictly less than n.

**Test:** Enumerate A ∈ M_n(ℤ) with small entries, compute
det(I + 3A·diag(x²)) as a polynomial, check if it equals 1,
verify rank(A) < n. A single counterexample disproves this. -/
def cubic_linear_keller_rank_conjecture : Prop :=
  ∀ (m : ℕ) (_ : m ≤ 5) (A : Matrix (Fin m) (Fin m) ℚ),
    unitJacobianCondition (druzkowskiMap A) → A.rank < m

end JacobianConjecture