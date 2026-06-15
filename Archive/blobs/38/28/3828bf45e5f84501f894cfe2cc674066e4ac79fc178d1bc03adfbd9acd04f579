/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Intersection Forms, Donaldson's Obstruction, and the Smooth 4D Poincaré Story

The smooth 4-dimensional Poincaré conjecture — *is every smooth 4-manifold homotopy
equivalent to `S⁴` diffeomorphic to `S⁴`?* — remains open.  The entire subject is
governed by **Donaldson's diagonalization theorem**: the intersection form of a
smooth, closed, simply-connected, positive-definite 4-manifold is *standard*, i.e.
diagonalizable over `ℤ` to `⟨1⟩ⁿ`.  This places a sharp gauge-theoretic restriction
that topology alone (Freedman's classification) does not see, and is exactly the
mechanism that distinguishes smooth from topological 4-manifolds.

This file formalizes the **algebraic heart** of that mechanism in a fully verified,
`sorry`-free way:

* `IntersectionForm n` — a symmetric integral Gram matrix (the cup-product pairing on
  `H²`), with predicates `Unimodular` (Poincaré duality), `IsEven` (spin), and
  `StdDiagonalizable` (Donaldson's conclusion).

* `even_not_stdDiagonalizable` — **the obstruction**: a positive-rank *even* form can
  never be diagonalizable to the standard form `⟨1⟩ⁿ`.  This is the algebraic engine
  behind Donaldson's theorem: it forces a smooth definite manifold's form to be odd.

* The `E8` form — even, unimodular, positive-definite, rank `8` — and the corollary
  `E8_not_stdDiagonalizable`.  Combined with Donaldson's theorem (the deep analytic
  input), this says **`E8` is not the intersection form of any smooth closed
  simply-connected 4-manifold**, even though Freedman realizes it *topologically*.
  This is the cleanest known witness of the smooth/topological gap in dimension 4.

* `stdForm_not_even` — boundary case showing evenness is essential.

* `sphereForm` — the trivial (rank-`0`) form of `S⁴`, unimodular, even, and standard,
  illustrating that homological data alone cannot distinguish smooth structures.

## References
* S. K. Donaldson, *An application of gauge theory to four-dimensional topology* (1983).
* M. Freedman, *The topology of four-dimensional manifolds* (1982).
-/

import Mathlib

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincare

/-- The intersection form of a closed oriented 4-manifold, modeled as the Gram matrix
of the cup-product pairing on `H²(M;ℤ)/torsion`: a symmetric integer matrix. -/
structure IntersectionForm (n : ℕ) where
  /-- The Gram matrix of the symmetric bilinear pairing. -/
  gram : Matrix (Fin n) (Fin n) ℤ
  /-- The cup-product pairing is symmetric. -/
  isSymm : gram.IsSymm

namespace IntersectionForm

variable {n : ℕ}

/-- The quadratic value `Q(v) = vᵀ G v` of the form on an integer vector. -/
def value (Q : IntersectionForm n) (v : Fin n → ℤ) : ℤ := v ⬝ᵥ Q.gram *ᵥ v

/-- **Poincaré duality** forces the intersection form to be *unimodular*: its Gram
determinant is a unit in `ℤ` (equivalently `±1`). -/
def Unimodular (Q : IntersectionForm n) : Prop := IsUnit Q.gram.det

/-- An **even** form: `Q(v)` is even for every integer vector `v`.  This holds exactly
when the underlying manifold is spin. -/
def IsEven (Q : IntersectionForm n) : Prop := ∀ v : Fin n → ℤ, Even (Q.value v)

/-- `Q` is **standard-diagonalizable** over `ℤ`: there is a unimodular integral basis
change `T` with `Tᵀ G T = 1`, i.e. `Q` is equivalent to the diagonal form `⟨1⟩ⁿ`.
This is the conclusion of Donaldson's theorem in the positive-definite case. -/
def StdDiagonalizable (Q : IntersectionForm n) : Prop :=
  ∃ T : Matrix (Fin n) (Fin n) ℤ, IsUnit T.det ∧ Tᵀ * Q.gram * T = 1

-- !-- Change of basis on a quadratic form: `Q(Tv) = vᵀ (Tᵀ G T) v`, by the matrix
-- `mulVec`/`dotProduct`/transpose identities. -- !--
/-- A basis change `T` transports the quadratic value: `Q(T v) = (Tᵀ G T)(v)`. -/
theorem value_basisChange (Q : IntersectionForm n) (T : Matrix (Fin n) (Fin n) ℤ)
    (v : Fin n → ℤ) :
    Q.value (T *ᵥ v) = v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v := by
  unfold IntersectionForm.value
  simp +decide [Matrix.vecMul_mulVec, Matrix.dotProduct_mulVec]
  rw [Matrix.mul_assoc]

-- !-- A symmetric integer form with even diagonal is even: off-diagonal terms pair up
-- as `2·vᵢGᵢⱼvⱼ` by symmetry, and the diagonal terms `Gᵢᵢvᵢ²` are even. -- !--
/-- A symmetric integral form whose diagonal entries are all even is an even form. -/
theorem isEven_of_even_diag (Q : IntersectionForm n)
    (h : ∀ i, Even (Q.gram i i)) : Q.IsEven := by
  intro v
  -- `Q.value v = ∑ i, ∑ j, vᵢ Gᵢⱼ vⱼ`.
  have h_def : Q.value v = ∑ i, ∑ j, v i * Q.gram i j * v j := by
    unfold IntersectionForm.value
    simp +decide [Matrix.mulVec, dotProduct, mul_comm, mul_left_comm, Finset.mul_sum _ _ _]
  -- Split into the diagonal `∑ᵢ vᵢ² Gᵢᵢ` and twice the strictly-upper-triangular part.
  have h_symm : ∑ i, ∑ j, v i * Q.gram i j * v j
      = ∑ i, v i ^ 2 * Q.gram i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, v i * Q.gram i j * v j := by
    have h_symm : ∀ (n : ℕ) (f : Fin n → Fin n → ℤ), (∀ i j, f i j = f j i) →
        ∑ i, ∑ j, f i j = ∑ i, f i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, f i j := by
      intros n f hf_symm; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
      simp +decide [ Finset.sum_add_distrib, mul_two, ih _ fun i j => hf_symm _ _ ] ; ring;
    convert h_symm n _ _ using 3 <;> ring!;
    exact fun i j => by rw [ mul_right_comm, Q.isSymm.apply ] ;
  exact h_def ▸ h_symm ▸ even_iff_two_dvd.mpr
    (dvd_add (Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right (even_iff_two_dvd.mp (h i)) _)
      (dvd_mul_right _ _))

/-! ## The Donaldson obstruction -/

-- !-- If `Tᵀ G T = 1`, then for the standard basis vector `eₖ` we get
-- `Q(T eₖ) = eₖᵀ · 1 · eₖ = 1`, which is odd — contradicting evenness. -- !--
/-- **Donaldson's obstruction (algebraic core).** A positive-rank *even* intersection
form is never diagonalizable to the standard form `⟨1⟩ⁿ`.  This is the algebraic
mechanism by which gauge theory forbids even definite forms on smooth 4-manifolds. -/
theorem even_not_stdDiagonalizable (Q : IntersectionForm n) (hn : 0 < n)
    (hev : Q.IsEven) : ¬ Q.StdDiagonalizable := by
  intro h
  obtain ⟨T, hTref, hTeq⟩ := h
  -- The first standard basis vector and its image under `T`.
  set k : Fin n := ⟨0, hn⟩
  set v : Fin n → ℤ := Pi.single k 1
  set w : Fin n → ℤ := T.mulVec v
  -- Transport the value through `T`, then collapse `Tᵀ G T = 1`.
  have hQw : Q.value w = v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v :=
    value_basisChange Q T v
  have hQw_eq : Q.value w = v ⬝ᵥ v := by
    rw [hQw, hTeq, Matrix.one_mulVec]
  -- `v ⬝ᵥ v = 1` since `v` is a standard basis vector.
  have hvdotv : v ⬝ᵥ v = 1 := by
    simp [v, dotProduct, Pi.single_apply, Finset.sum_ite_eq']
  -- Evenness would force `Even (1 : ℤ)`, a contradiction.
  have h_even : Even (1 : ℤ) := hvdotv ▸ hQw_eq ▸ hev w
  exact absurd h_even (by decide)

/-! ## The standard odd form `⟨1⟩ⁿ` (boundary case) -/

/-- The standard positive-definite form `⟨1⟩ⁿ`, the intersection form of `#ⁿ ℂP²`. -/
def stdForm (n : ℕ) : IntersectionForm n := ⟨1, Matrix.isSymm_one⟩

-- !-- `Q(e₀) = e₀ᵀ · 1 · e₀ = 1`, which is odd, so the standard form is not even;
-- this shows evenness is genuinely needed in `even_not_stdDiagonalizable`. -- !--
/-- **Boundary case:** the standard form `⟨1⟩ⁿ` is *not* even for `n ≥ 1`. -/
theorem stdForm_not_even (hn : 0 < n) : ¬ (stdForm n).IsEven := by
  intro h
  convert h (Pi.single ⟨0, hn⟩ 1) using 1
  simp +decide [IntersectionForm.value, stdForm]

/-! ## The `E8` form -/

/-- The `E8` Cartan/Gram matrix: even, unimodular, positive-definite, rank `8`. -/
def E8mat : Matrix (Fin 8) (Fin 8) ℤ :=
  !![2,-1,0,0,0,0,0,0;
     -1,2,-1,0,0,0,0,0;
     0,-1,2,-1,0,0,0,0;
     0,0,-1,2,-1,0,0,0;
     0,0,0,-1,2,-1,0,-1;
     0,0,0,0,-1,2,-1,0;
     0,0,0,0,0,-1,2,0;
     0,0,0,0,-1,0,0,2]

/-- An explicit integral inverse of `E8mat`, witnessing unimodularity. -/
def E8inv : Matrix (Fin 8) (Fin 8) ℤ :=
  !![2,3,4,5,6,4,2,3;
     3,6,8,10,12,8,4,6;
     4,8,12,15,18,12,6,9;
     5,10,15,20,24,16,8,12;
     6,12,18,24,30,20,10,15;
     4,8,12,16,20,14,7,10;
     2,4,6,8,10,7,4,5;
     3,6,9,12,15,10,5,8]

set_option maxRecDepth 10000 in
/-- `E8mat` is symmetric. -/
theorem E8mat_isSymm : E8mat.IsSymm := by decide

/-- The `E8` intersection form. -/
def E8form : IntersectionForm 8 := ⟨E8mat, E8mat_isSymm⟩

set_option maxRecDepth 10000 in
/-- The explicit inverse really is a right inverse of `E8mat`. -/
theorem E8_mul_inv : E8mat * E8inv = 1 := by decide

-- !-- Taking determinants of `E8mat * E8inv = 1` gives `det E8mat · det E8inv = 1`,
-- so `det E8mat` is a unit. -- !--
/-- **`E8` is unimodular** (`det = ±1`), exhibited by an explicit integral inverse. -/
theorem E8_unimodular : E8form.Unimodular :=
  isUnit_iff_exists_inv.mpr
    ⟨Matrix.det E8inv, by simpa [Matrix.det_mul] using congr_arg Matrix.det E8_mul_inv⟩

-- !-- Every diagonal entry of `E8mat` is `2`, so `isEven_of_even_diag` applies. -- !--
/-- **`E8` is even**: all of its diagonal entries equal `2`. -/
theorem E8_even : E8form.IsEven :=
  isEven_of_even_diag _ fun i => by fin_cases i <;> decide

/-- **The smooth/topological gap, algebraic witness.** `E8` is unimodular, even, and
*not* standard-diagonalizable.  With Donaldson's theorem, this proves `E8` is not the
intersection form of any smooth closed simply-connected 4-manifold — though Freedman
realizes it as a *topological* one. -/
theorem E8_not_stdDiagonalizable : ¬ E8form.StdDiagonalizable :=
  even_not_stdDiagonalizable E8form (by norm_num) E8_even

/-! ## The sphere `S⁴` -/

/-- The intersection form of `S⁴`: rank `0` (since `H²(S⁴) = 0`). -/
def sphereForm : IntersectionForm 0 := ⟨1, Matrix.isSymm_one⟩

-- !-- Over `Fin 0` every matrix is the empty matrix, so `T = 1` works, `det = 1`,
-- and the empty quadratic value is `0` (hence even). -- !--
/-- **`S⁴`'s form is trivial:** it is unimodular, even, and standard-diagonalizable.
Homological data alone is consistent with the standard sphere — exactly why the smooth
4D Poincaré conjecture cannot be settled by intersection forms. -/
theorem sphere_intersection_trivial :
    sphereForm.Unimodular ∧ sphereForm.IsEven ∧ sphereForm.StdDiagonalizable := by
  refine ⟨?_, ?_, ?_⟩
  · exact isUnit_one
  · exact fun v => by fin_cases v; trivial
  · exists 1

end IntersectionForm

end SmoothPoincare