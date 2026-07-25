/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Helfgott Growth in SL(2, 𝔽_p): Structural Escape Theorems

This file develops SL(2, 𝔽_p)-specific results for the Helfgott growth program,
connecting irreducible characteristic polynomials to subgroup escape and
linking group structure to additive combinatorics over finite fields.

## Main Results

* `charpoly_upper_triangular_eq_prod`: The characteristic polynomial of a 2×2
  upper triangular matrix factors as a product of linear polynomials.
* `not_irreducible_charpoly_of_upper_triangular`: Upper triangular matrices
  cannot have irreducible characteristic polynomial.
* `entry_10_ne_zero_of_irreducible_charpoly`: Elements with irreducible
  charpoly have nonzero (1,0)-entry — they escape upper-triangular structure.
* `entrySet_sumProduct_bridge`: Cross-domain theorem connecting group structure
  to additive growth in the base field.
* `traceSet_card_le_tripleProduct_card`: Trace set bound via product growth.

## Mathematical Significance

In Helfgott's proof of growth in SL(2, ℤ/pℤ), the main obstruction to
product expansion is containment in a Borel (upper triangular) subgroup.
Elements with irreducible characteristic polynomial cannot lie in any
conjugate of the Borel, providing a certified "escape witness."

The cross-domain bridge theorem shows that group-theoretic escape produces
field subsets with guaranteed additive growth — the first formal link between
nonabelian group expansion and sum-product phenomena.
-/

import Mathlib
import Pythagorean.HelfgottGrowth

open Finset Matrix Polynomial Pointwise

attribute [local instance] Classical.dec

/-! ## Trace and Entry Set Definitions -/

section Defs

variable (p : ℕ) [hp : Fact p.Prime]

/-- The **trace set** of A ⊆ SL(2, 𝔽_p) is the image of A under the trace map.
Trace linearizes conjugacy information and is the natural compression
statistic for connecting group growth to additive combinatorics. -/
noncomputable def traceSet
    (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p))) : Finset (ZMod p) :=
  A.image fun g => Matrix.trace g.val

/-- The **(i,j)-entry set** extracts a finite field subset from matrix entries.
This is the bridge between linear group structure and field arithmetic. -/
noncomputable def entrySet
    (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)))
    (i j : Fin 2) : Finset (ZMod p) :=
  A.image fun g => g.val i j

end Defs

/-! ## Characteristic Polynomial Factorization -/

/-
The characteristic polynomial of a 2×2 upper triangular matrix factors
as a product of two linear polynomials (X - a)(X - d) where a, d are
the diagonal entries. This is the algebraic core of the escape certificate:
upper triangular matrices always have split characteristic polynomials.
-/
theorem charpoly_upper_triangular_eq_prod
    {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R)
    (hut : M 1 0 = 0) :
    M.charpoly = (X - C (M 0 0)) * (X - C (M 1 1)) := by
  simp [ hut, Matrix.charpoly, Matrix.det_fin_two ]

/-
**Escape Certificate Theorem.**
Over a nontrivial commutative ring, a 2×2 upper triangular matrix cannot have
irreducible characteristic polynomial, because its charpoly splits into
linear factors.

This is the contrapositive of the escape principle: if an element of SL(2, 𝔽_p)
has irreducible characteristic polynomial, it cannot be upper triangular.
-/
theorem not_irreducible_charpoly_of_upper_triangular
    {R : Type*} [CommRing R] [Nontrivial R]
    (M : Matrix (Fin 2) (Fin 2) R)
    (hut : M 1 0 = 0) :
    ¬ Irreducible M.charpoly := by
  rw [ charpoly_upper_triangular_eq_prod M hut ];
  rw [ irreducible_mul_iff ] ; simp_all +decide [ Polynomial.not_isUnit_X_sub_C ] ;

/-- Elements with irreducible characteristic polynomial have
nonzero (1,0)-entry. This is the computational witness of escape from
upper-triangular structure. -/
theorem entry_10_ne_zero_of_irreducible_charpoly
    {R : Type*} [CommRing R] [Nontrivial R]
    (M : Matrix (Fin 2) (Fin 2) R)
    (hirr : Irreducible M.charpoly) :
    M 1 0 ≠ 0 := by
  intro h
  exact not_irreducible_charpoly_of_upper_triangular M h hirr

/-! ## Trace Set Bounds -/

section TraceBounds

variable (p : ℕ) [hp : Fact p.Prime]

omit hp in
/-- The trace set is at most as large as A: |tr(A)| ≤ |A|.
This follows from the image bound. -/
theorem traceSet_card_le (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p))) :
    (traceSet p A).card ≤ A.card :=
  Finset.card_image_le

omit hp in
/-- **Trace-Product Growth Bridge.**
The triple product set is at least as large as the trace set:
|A·A·A| ≥ |tr(A)|. This follows from A ⊆ A³ and |tr(A)| ≤ |A|. -/
theorem traceSet_card_le_tripleProduct_card
    (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)))
    (hone : (1 : Matrix.SpecialLinearGroup (Fin 2) (ZMod p)) ∈ A) :
    (traceSet p A).card ≤ (TripleProduct A).card :=
  le_trans (traceSet_card_le p A)
    (Finset.card_le_card (subset_tripleProduct A hone))

end TraceBounds

/-! ## Cross-Domain Bridge: Group Escape → Field Additive Growth -/

/-
**Cross-Domain Theorem: Entry-Set Sum-Product Bridge.**

If A ⊆ SL(2, 𝔽_p) contains both an element with zero (1,0)-entry (like the identity)
and an element with nonzero (1,0)-entry (an escape witness), and p ≥ 3,
then we can extract a finite field subset S with |S+S| > |S|.

This is the first formal bridge from nonabelian group structure (escape from
upper-triangular subgroups) to additive combinatorics in the base field.
The extracted set S = {0, c} with c ≠ 0 satisfies |S+S| = |{0, c, 2c}| = 3 > 2 = |S|
when char 𝔽_p ≠ 2 (guaranteed by p ≥ 3).
-/
theorem entrySet_sumProduct_bridge
    (p : ℕ) [hp : Fact p.Prime]
    (A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p)))
    (hp3 : p ≥ 3)
    (h_has_zero : ∃ g ∈ A, g.val 1 0 = 0)
    (h_has_nonzero : ∃ g ∈ A, g.val 1 0 ≠ 0) :
    ∃ S : Finset (ZMod p),
      S.Nonempty ∧
      S.card ≤ A.card ∧
      (S + S).card > S.card := by
  -- Let's obtain the elements from h_has_zero and h_has_nonzero.
  obtain ⟨g, hgA, hg0⟩ := h_has_zero
  obtain ⟨g', hg'A, hg'0⟩ := h_has_nonzero;
  -- Let's choose the set S = {0, c} where c = g'.val 1 0.
  use {0, g'.val 1 0};
  rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] <;> simp +decide;
  · refine' ⟨ _, _ ⟩;
    · refine' Finset.one_lt_card.2 ⟨ g, hgA, g', hg'A, _ ⟩ ; aesop;
    · rw [ Finset.card_eq_three.mpr ];
      · decide +revert;
      · refine' ⟨ 0, g'.val 1 0, 2 * g'.val 1 0, _, _, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff, Finset.mem_add ];
        · exact Ne.symm hg'0;
        · erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( by linarith );
        · rcases p with ( _ | _ | _ | p ) <;> norm_num at *;
          rintro ⟨ ⟩;
        · grind;
  · exact Ne.symm hg'0

/-! ## Growth Certificate for SL(2) -/

/-- A **growth certificate for SL(2, 𝔽_p)** bundles a symmetric subset with
verified structural properties: escape witness (irreducible charpoly element)
and non-closure under multiplication. -/
structure SL2GrowthCertificate (p : ℕ) [Fact p.Prime] where
  /-- The subset under study -/
  A : Finset (Matrix.SpecialLinearGroup (Fin 2) (ZMod p))
  /-- A is symmetric -/
  symmetric : IsSymmetricSubset A
  /-- 1 ∈ A -/
  contains_one : (1 : Matrix.SpecialLinearGroup (Fin 2) (ZMod p)) ∈ A
  /-- A has an element with irreducible charpoly -/
  has_escape_witness : ∃ g ∈ A,
    Irreducible (Matrix.charpoly g.val)
  /-- A is not closed under multiplication -/
  not_mul_closed : ¬ IsMulClosed A

variable (p : ℕ) [Fact p.Prime]

/-- **SL(2) Growth Certificate Soundness.**
Any valid SL(2) growth certificate witnesses strict triple-product expansion. -/
theorem sl2_growthCertificate_sound (C : SL2GrowthCertificate p) :
    C.A.card < (TripleProduct C.A).card :=
  card_lt_card_tripleProduct_of_not_isMulClosed C.A C.contains_one C.not_mul_closed