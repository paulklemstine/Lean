/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Direct Sums of Intersection Forms and the `E8 ⊕ E8` Obstruction

This file *generalizes* the algebra in `Applications.SmoothPoincare.IntersectionForms`
from a fixed `Fin n` index to an **arbitrary finite index type** `ι`, and then develops
the **monoidal (direct-sum) structure** of intersection forms.  This is the
Grothendieck-style conceptual move: the smooth/topological gap witnessed by a single
form (`E8`) becomes a statement about a *symmetric monoidal category* of integral
symmetric forms in which `Unimodular`, `IsEven`, and `StdDiagonalizable` are all
*structural* (additive / congruence-invariant) properties.

To keep the file self-contained and robust we re-state the `E8` Gram matrix and its
explicit integral inverse here (mirroring the catalog file
`Applications.SmoothPoincare.IntersectionForms`, on which this work conceptually builds
— see `SmoothPoincare.IntersectionForm.E8mat` there).

## Main results

* `GForm ι` — a symmetric integral Gram matrix over any finite index type `ι`,
  with the predicates `Unimodular`, `IsEven`, `StdDiagonalizable`.

* `even_not_stdDiagonalizable` — the **Donaldson obstruction**, over any nonempty `ι`:
  an even form is never diagonalizable to `⟨1⟩`.

* `dsum` and `dsum_value`, `dsum_even`, `dsum_unimodular`, `dsum_stdDiagonalizable` —
  the direct sum `Q ⊕ R` and the proofs that *each* of the three properties is closed
  under `⊕`: the additivity laws of the form category.

* `E8_sum_E8_obstruction` — the **capstone**: the rank-`16` form `E8 ⊕ E8` is
  unimodular, even, and **not** standard-diagonalizable.  This is the algebraic shadow
  of the spin obstruction at the boundary of Rokhlin's theorem and the `11/8`-conjecture:
  an even definite unimodular form of rank `16` cannot be the intersection form of a
  smooth closed simply-connected 4-manifold (Donaldson), even though Freedman realizes it
  topologically.

## References
* S. K. Donaldson, *An application of gauge theory to four-dimensional topology* (1983).
* V. A. Rokhlin, *New results in the theory of four-dimensional manifolds* (1952).
* M. Freedman, *The topology of four-dimensional manifolds* (1982).
-/

import Mathlib

open Matrix
open scoped BigOperators

noncomputable section

namespace SmoothPoincareDirectSum

universe u

/-- A symmetric integral bilinear (intersection) form over an arbitrary index type `ι`,
the Gram matrix of a cup-product pairing. -/
structure GForm (ι : Type u) where
  /-- The Gram matrix of the symmetric pairing. -/
  gram : Matrix ι ι ℤ
  /-- The pairing is symmetric. -/
  isSymm : gram.IsSymm

namespace GForm

variable {ι : Type u} {κ : Type u}

/-- The quadratic value `Q(v) = vᵀ G v`. -/
def value [Fintype ι] (Q : GForm ι) (v : ι → ℤ) : ℤ := v ⬝ᵥ Q.gram *ᵥ v

/-- **Poincaré duality**: the form is unimodular (`det` a unit in `ℤ`). -/
def Unimodular [Fintype ι] [DecidableEq ι] (Q : GForm ι) : Prop := IsUnit Q.gram.det

/-- An **even** (spin) form: `Q(v)` is even for every integer vector. -/
def IsEven [Fintype ι] (Q : GForm ι) : Prop := ∀ v : ι → ℤ, Even (Q.value v)

/-- `Q` is **standard-diagonalizable**: congruent over `ℤ` to the identity form `⟨1⟩`,
the conclusion of Donaldson's theorem in the positive-definite case. -/
def StdDiagonalizable [Fintype ι] [DecidableEq ι] (Q : GForm ι) : Prop :=
  ∃ T : Matrix ι ι ℤ, IsUnit T.det ∧ Tᵀ * Q.gram * T = 1

/-
!-- A basis change transports the quadratic value: `Q(Tv) = vᵀ(TᵀGT)v`, by the
`mulVec`/`dotProduct`/transpose identities. -- !--

A basis change `T` transports the quadratic value: `Q(T v) = (Tᵀ G T)(v)`.
-/
theorem value_basisChange [Fintype ι] (Q : GForm ι) (T : Matrix ι ι ℤ) (v : ι → ℤ) :
    Q.value (T *ᵥ v) = v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v := by
  unfold GForm.value;
  simp +decide [ Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ]

/-
!-- For the basis vector `eₖ`, `Tᵀ G T = 1` forces `Q(T eₖ) = eₖ ⬝ eₖ = 1`, odd,
contradicting evenness. -- !--

**Donaldson's obstruction (general index).** A nonempty even form is never
standard-diagonalizable.
-/
theorem even_not_stdDiagonalizable [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (Q : GForm ι) (hev : Q.IsEven) : ¬ Q.StdDiagonalizable := by
  intro h
  obtain ⟨T, hTref, hTeq⟩ := h;
  have h_contradiction : ∀ v : ι → ℤ, Even (v ⬝ᵥ (Tᵀ * Q.gram * T) *ᵥ v) := by
    intro v
    have := hev (T *ᵥ v)
    simp_all +decide [ value_basisChange ];
  convert h_contradiction ( fun i => if i = Classical.arbitrary ι then 1 else 0 ) using 1 ; simp +decide [ hTeq ];
  simp +decide [ dotProduct ]

/-
!-- Symmetric integer form with even diagonal is even: by symmetry the value splits
as `∑ᵢ Gᵢᵢvᵢ² + 2·∑_{i<j} vᵢGᵢⱼvⱼ`, both summands even. -- !--

A symmetric integral form (over `Fin n`) whose diagonal entries are all even is an
even form.
-/
theorem isEven_of_even_diag {n : ℕ} (Q : GForm (Fin n))
    (h : ∀ i, Even (Q.gram i i)) : Q.IsEven := by
  have h_symm : ∀ (n : ℕ) (f : Fin n → Fin n → ℤ), (∀ i j, f i j = f j i) →
      ∑ i, ∑ j, f i j = ∑ i, f i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, f i j := by
        intro n f hf_symm; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
        simp +decide [ Finset.sum_add_distrib, mul_two, ih _ fun i j => hf_symm _ _ ] ; ring;
  intro v
  have h_def : Q.value v = ∑ i, ∑ j, v i * Q.gram i j * v j := by
    unfold GForm.value; simp +decide [ Matrix.mulVec, dotProduct, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;
  have h_symm : ∑ i, ∑ j, v i * Q.gram i j * v j
      = ∑ i, v i ^ 2 * Q.gram i i + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, v i * Q.gram i j * v j := by
        convert h_symm n _ _ using 3 <;> ring!;
        exact fun i j => by rw [ mul_right_comm, Q.isSymm.apply ] ;
  exact h_def ▸ h_symm ▸ even_iff_two_dvd.mpr
    (dvd_add (Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right (even_iff_two_dvd.mp (h i)) _)
      (dvd_mul_right _ _))

/-! ## The direct sum `Q ⊕ R` -/

/-
The **direct sum** (orthogonal block sum) of two intersection forms, with Gram
matrix the block-diagonal `fromBlocks G 0 0 H`.  Models the intersection form of a
connected sum `M # N`.
-/
def dsum [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    (Q : GForm ι) (R : GForm κ) : GForm (ι ⊕ κ) where
  gram := Matrix.fromBlocks Q.gram 0 0 R.gram
  isSymm := by
    simp +decide [ Matrix.IsSymm, fromBlocks_transpose ];
    exact ⟨ Q.isSymm, R.isSymm ⟩

/-
!-- Block-diagonal Gram matrix splits the quadratic value along the `Sum` index:
`dotProduct`/`mulVec` over `ι ⊕ κ` separate by `Fintype.sum_sum_type`. -- !--

The value of a direct sum splits orthogonally:
`(Q ⊕ R)(v) = Q(v∘inl) + R(v∘inr)`.
-/
theorem dsum_value [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    (Q : GForm ι) (R : GForm κ) (v : ι ⊕ κ → ℤ) :
    (dsum Q R).value v = Q.value (v ∘ Sum.inl) + R.value (v ∘ Sum.inr) := by
  unfold GForm.value;
  simp +decide [ Matrix.mulVec, dotProduct, dsum ]

-- !-- A sum of two even values is even; apply `dsum_value`. -- !--
/-- **Evenness is additive**: a direct sum of even forms is even. -/
theorem dsum_even [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    {Q : GForm ι} {R : GForm κ} (hQ : Q.IsEven) (hR : R.IsEven) :
    (dsum Q R).IsEven := by
  intro v
  rw [dsum_value]
  exact (hQ _).add (hR _)

/-
!-- `det (fromBlocks G 0 0 H) = det G · det H`; a product of units is a unit. -- !--

**Unimodularity is additive**: a direct sum of unimodular forms is unimodular.
-/
theorem dsum_unimodular [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    {Q : GForm ι} {R : GForm κ} (hQ : Q.Unimodular) (hR : R.Unimodular) :
    (dsum Q R).Unimodular := by
  unfold GForm.Unimodular at *;
  unfold dsum; simp +decide [ *, Matrix.det_fromBlocks_zero₂₁ ] ;

/-
!-- Block-diagonalize the two basis changes: `T = fromBlocks T₁ 0 0 T₂` satisfies
`TᵀGT = fromBlocks 1 0 0 1 = 1`, with unit determinant `det T₁ · det T₂`. -- !--

**Standard-diagonalizability is additive**: a direct sum of standard forms is
standard.
-/
theorem dsum_stdDiagonalizable [Fintype ι] [Fintype κ] [DecidableEq ι] [DecidableEq κ]
    {Q : GForm ι} {R : GForm κ} (hQ : Q.StdDiagonalizable) (hR : R.StdDiagonalizable) :
    (dsum Q R).StdDiagonalizable := by
  obtain ⟨T₁, hT₁⟩ := hQ
  obtain ⟨T₂, hT₂⟩ := hR
  use Matrix.fromBlocks T₁ 0 0 T₂;
  simp_all +decide [ Matrix.det_fromBlocks_zero₂₁, Matrix.fromBlocks_multiply, Matrix.fromBlocks_transpose, dsum ]

/-! ## The `E8` form (mirroring the catalog `SmoothPoincare.IntersectionForm.E8mat`) -/

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

set_option maxRecDepth 10000 in
/-- The explicit inverse really is a right inverse of `E8mat`. -/
theorem E8_mul_inv : E8mat * E8inv = 1 := by decide

/-- The `E8` form, in the general `GForm` framework. -/
def E8G : GForm (Fin 8) := ⟨E8mat, E8mat_isSymm⟩

-- !-- `det (E8mat · E8inv) = 1` forces `det E8mat` to be a unit. -- !--
/-- **`E8` is unimodular** (`det = ±1`), via the explicit integral inverse. -/
theorem E8G_unimodular : E8G.Unimodular :=
  isUnit_iff_exists_inv.mpr
    ⟨Matrix.det E8inv, by simpa [Matrix.det_mul] using congr_arg Matrix.det E8_mul_inv⟩

-- !-- Every diagonal entry of `E8mat` equals `2`, so `isEven_of_even_diag` applies. -- !--
/-- **`E8` is even**: all diagonal entries equal `2`. -/
theorem E8G_even : E8G.IsEven :=
  isEven_of_even_diag _ fun i => by fin_cases i <;> decide

/-! ## Capstone: the `E8 ⊕ E8` obstruction -/

-- !-- `E8 ⊕ E8` is even and unimodular by additivity (`dsum_even`, `dsum_unimodular`);
-- as a nonempty even form, `even_not_stdDiagonalizable` forbids diagonalization. -- !--
/-- **Capstone.** The rank-`16` form `E8 ⊕ E8` is unimodular, even, and *not*
standard-diagonalizable.  Combined with Donaldson's theorem, this even definite
unimodular form is not the intersection form of any smooth closed simply-connected
4-manifold, although Freedman realizes it topologically — the boundary case behind
Rokhlin divisibility and the `11/8`-conjecture. -/
theorem E8_sum_E8_obstruction :
    (dsum E8G E8G).Unimodular ∧ (dsum E8G E8G).IsEven ∧
      ¬ (dsum E8G E8G).StdDiagonalizable := by
  refine ⟨dsum_unimodular E8G_unimodular E8G_unimodular,
    dsum_even E8G_even E8G_even, ?_⟩
  exact even_not_stdDiagonalizable _ (dsum_even E8G_even E8G_even)

end GForm

end SmoothPoincareDirectSum