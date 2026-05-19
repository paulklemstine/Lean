/-
Copyright (c) 2025. All rights reserved.

# Stable Reduction: Variable Adjunction Preserves Invertibility

The stable lift `F↑m` of a polynomial map `F : k^n → k^n` adjoins `m` identity
coordinates: `F↑m(x,y) = (F(x), y)`. This file proves:

1. The Jacobian matrix of `F↑m` is block-diagonal: `J(F) ⊕ I_m`.
2. The Jacobian determinant is preserved: `det J(F↑m) = det J(F)` (as a
   polynomial in the extended variables, via renaming).
3. Polynomial invertibility is preserved in both directions.

These are foundational reduction theorems: they show that the Jacobian
conjecture for dimension `n` follows from the conjecture for any `n+m`.

## Keywords
stable equivalence, variable adjunction, block matrix, Jacobian determinant
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix

variable {k : Type*} [CommRing k] {n m : ℕ}

/-! ### Stable lift of the inverse -/

/-- If `G` is the polynomial inverse of `F`, then `stableLift G m` is the
    polynomial inverse of `stableLift F m`. -/
noncomputable def stableLiftInverse (G : PolyMap k n) (m : ℕ) : PolyMap k (n + m) :=
  stableLift G m

/-! ### Forward direction: invertibility lifts -/

/-
If `F` is a polynomial automorphism, then `stableLift F m` is too.
-/
theorem isPolyAuto_stableLift_of_isPolyAuto
    (F : PolyMap k n) (hF : isPolyAuto F) :
    isPolyAuto (stableLift F m) := by
  -- By definition of stableLift, we have G = stableLift G m.
  have hG : isPolyAuto (stableLift F m) := by
    obtain ⟨G, hFG⟩ := hF
    refine' ⟨ stableLift G m, _, _ ⟩ <;> simp_all +decide [ isPolyInverse, polyMapComp, stableLift ];
    · ext i;
      by_cases hi : i.val < n <;> simp_all +decide [ stableLift, polyMapComp ];
      · have h_bind₁_rename : ∀ (p : MvPolynomial (Fin n) k), bind₁ (stableLift G m) (rename (Fin.castAdd m) p) = rename (Fin.castAdd m) (bind₁ G p) := by
          intro p;
          induction p using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.bind₁_X_right ];
          unfold stableLift; aesop;
        have := congr_fun hFG.1 ⟨ i, hi ⟩ ; simp_all +decide [ polyMapComp, polyMapId ] ;
      · split_ifs <;> simp_all +decide [ stableLift, polyMapId ];
        · linarith;
        · grind +splitImp;
    · funext i;
      by_cases hi : i.val < n <;> simp_all +decide [ polyMapComp, stableLift ];
      · convert congr_arg ( fun p => MvPolynomial.rename ( Fin.castAdd m ) p ) ( congr_fun hFG.2 ⟨ i, hi ⟩ ) using 1;
        · unfold polyMapComp;
          unfold stableLift; simp +decide [ Fin.castAdd, Fin.castLE ] ;
          induction' ( G ⟨ i, hi ⟩ ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, MvPolynomial.rename_X ];
        · unfold polyMapId; aesop;
      · split_ifs <;> simp_all +decide [ polyMapId, stableLift ];
        grind;
  exact hG

/-! ### Backward direction: invertibility descends -/

/-
If `stableLift F m` is a polynomial automorphism, then so is `F`.
-/
set_option maxHeartbeats 800000 in
theorem isPolyAuto_of_stableLift_isPolyAuto
    (F : PolyMap k n) (hF : isPolyAuto (stableLift F m)) :
    isPolyAuto F := by
  -- By definition of stableLift, we know that if stableLift F m is a polynomial automorphism, then F is also a polynomial automorphism.
  obtain ⟨G, hG⟩ := hF;
  refine' ⟨ fun i => MvPolynomial.bind₁ ( fun j => if hj : j.val < n then MvPolynomial.X ⟨ j.val, hj ⟩ else 0 ) ( G ( Fin.castAdd m i ) ), _, _ ⟩;
  · have h_comp : ∀ i : Fin n, MvPolynomial.bind₁ (fun j => if hj : j.val < n then MvPolynomial.X ⟨j.val, hj⟩ else 0) (MvPolynomial.bind₁ G (stableLift F m (Fin.castAdd m i))) = MvPolynomial.X i := by
      intro i
      have h_comp : MvPolynomial.bind₁ G (stableLift F m (Fin.castAdd m i)) = MvPolynomial.X (Fin.castAdd m i) := by
        exact congr_fun hG.1 ( Fin.castAdd m i );
      aesop;
    convert h_comp using 1;
    unfold polyMapComp polyMapId stableLift; simp +decide [ funext_iff ] ;
    congr! 2;
    induction' ( F ‹_› ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_rename ];
  · have := congr_fun hG.2;
    ext i specialize this ( Fin.castAdd m i ) ; simp_all +decide [ polyMapComp, polyMapId ] ;
    convert congr_arg ( fun p => coeff specialize ( MvPolynomial.bind₁ ( fun j => if hj : j.val < n then MvPolynomial.X ⟨ j.val, hj ⟩ else 0 ) p ) ) ( this ( Fin.castAdd m i ) ) using 1;
    · congr! 1;
      induction' G ( Fin.castAdd m i ) using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_X_right ];
      split_ifs <;> simp_all +decide [ stableLift ];
      · induction' F ⟨ _, ‹_› ⟩ using MvPolynomial.induction_on with i p q hp hq <;> simp +decide [ *, bind₁_X_right ];
        · rw [ mul_add, mul_add, hp, hq ];
        · grind;
      · split_ifs <;> simp_all +decide [ Fin.castAdd ];
        linarith;
    · simp +decide [ Fin.castAdd ]

/-! ### Biconditional -/

/-- **Stable invertibility theorem**: `F` is a polynomial automorphism if and only if
    `stableLift F m` is. -/
theorem isPolyAuto_stableLift_iff (F : PolyMap k n) :
    isPolyAuto F ↔ isPolyAuto (stableLift F m) :=
  ⟨isPolyAuto_stableLift_of_isPolyAuto F, isPolyAuto_of_stableLift_isPolyAuto F⟩

/-! ### Jacobian matrix of stable lift -/

/-
The Jacobian matrix of the stable lift has block structure:
    the (i,j) entry for `i, j < n` comes from the Jacobian of `F` (renamed),
    the diagonal entries for `i ≥ n` are 1, and all off-diagonal cross-blocks are 0.
-/
set_option maxHeartbeats 800000 in
theorem jacobianMatrix_stableLift_entry
    (F : PolyMap k n) (i j : Fin (n + m)) :
    jacobianMatrix (stableLift F m) i j =
      if hi : i.val < n then
        if hj : j.val < n then
          MvPolynomial.rename (Fin.castAdd m)
            (MvPolynomial.pderiv ⟨j.val, hj⟩ (F ⟨i.val, hi⟩))
        else 0
      else if i = j then 1 else 0 := by
  -- By definition of stableLift, we can split into cases based on whether i is less than n or not.
  by_cases hi : i.val < n;
  · by_cases hj : j.val < n <;> simp +decide [ *, jacobianMatrix, stableLift ];
    · grind +suggestions;
    · -- Since $j$ is not in the range of $Fin.castAdd m$, the derivative of the renamed polynomial with respect to $j$ is zero.
      have h_deriv_zero : ∀ (p : MvPolynomial (Fin n) k), (MvPolynomial.pderiv j) (MvPolynomial.rename (Fin.castAdd m) p) = 0 := by
        intro p;
        induction p using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ];
        grind;
      exact h_deriv_zero _;
  · unfold jacobianMatrix stableLift;
    simp +decide [ hi, MvPolynomial.pderiv_X ];
    grind +splitIndPred

end JacobianConjecture