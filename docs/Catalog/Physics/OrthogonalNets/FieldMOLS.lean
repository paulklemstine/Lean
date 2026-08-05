/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Saturated MOLS families from finite fields

The pivot bound of `Catalog.Computation.ReticulationMOLS` and its window
refinement in `Physics.OrthogonalNets.PivotWindow` say that a family of
pairwise-orthogonal Latin squares of order `n` has at most `n - 1` members.
This file supplies the matching *lower* bound whenever the order carries a field
structure: for a finite field `K` with `|K| = n` the squares

  `L a i j = a * i + j`,  `a ∈ K \ {0}`,

form a family of `n - 1` mutually orthogonal Latin squares.  Orthogonality of
`L a` and `L b` is the invertibility of the `2 × 2` matrix `[[a,1],[b,1]]`, i.e.
`a - b ≠ 0`.

Consequences recorded here:

* `exists_saturated_MOLS_of_field` : a saturated family exists in every finite
  field order;
* `MOLS_sharp_of_field`            : the maximum size of a MOLS family of order
  `|K|` is *exactly* `|K| - 1`;
* `MOLS_sharp_prime`               : the prime-order specialization, via `ZMod p`.
-/

import Computation.PosetTheory.ReticulationMOLS

namespace Catalog.Physics.OrthogonalNets

open Function
open Catalog.Computation.ReticulationMOLS

section FieldConstruction

variable (K : Type*) [Field K] [Fintype K] [DecidableEq K]

/-- A chosen bijection between the symbol set `Fin |K|` and the field `K`. -/
noncomputable def fieldCoord : Fin (Fintype.card K) ≃ K := (Fintype.equivFin K).symm

/-- The number of nonzero elements of a finite field `K` is `|K| - 1`. -/
theorem card_nonzero : Fintype.card {a : K // a ≠ 0} = Fintype.card K - 1 := by
  rw [Fintype.card_subtype_compl]
  simp

/-- A chosen bijection between the index set `Fin (|K| - 1)` and the nonzero elements
of `K`. -/
noncomputable def fieldIndex : Fin (Fintype.card K - 1) ≃ {a : K // a ≠ 0} :=
  (Fintype.equivFinOfCardEq (card_nonzero K)).symm

/-- The affine family of Latin squares `L a i j = a * i + j` attached to a finite field,
indexed by the nonzero field elements. -/
noncomputable def fieldSquare (s : Fin (Fintype.card K - 1))
    (i j : Fin (Fintype.card K)) : Fin (Fintype.card K) :=
  (fieldCoord K).symm ((fieldIndex K s : K) * fieldCoord K i + fieldCoord K j)

/-- Each affine square `L a i j = a * i + j` with `a ≠ 0` is a Latin square. -/
theorem fieldSquare_isLatin (s : Fin (Fintype.card K - 1)) :
    IsLatin (Fintype.card K) (fieldSquare K s) := by
  constructor
  · intro i
    refine Finite.injective_iff_bijective.mp ?_
    intro j j' h
    simp only [fieldSquare] at h
    have h1 := (fieldCoord K).symm.injective h
    exact (fieldCoord K).injective (add_left_cancel h1)
  · intro j
    refine Finite.injective_iff_bijective.mp ?_
    intro i i' h
    simp only [fieldSquare] at h
    have h1 := (fieldCoord K).symm.injective h
    have h2 : (fieldIndex K s : K) * fieldCoord K i = (fieldIndex K s : K) * fieldCoord K i' :=
      add_right_cancel h1
    exact (fieldCoord K).injective (mul_left_cancel₀ (fieldIndex K s).2 h2)

/-- Two affine squares with distinct nonzero multipliers are orthogonal: the linear system
`a x + y = a x' + y'`, `b x + y = b x' + y'` has only the trivial solution when `a ≠ b`. -/
theorem fieldSquare_orthogonal {s t : Fin (Fintype.card K - 1)} (hst : s ≠ t) :
    Orthogonal (Fintype.card K) (fieldSquare K s) (fieldSquare K t) := by
  refine Finite.injective_iff_bijective.mp ?_
  rintro ⟨i, j⟩ ⟨i', j'⟩ h
  set a : K := (fieldIndex K s : K) with ha
  set b : K := (fieldIndex K t : K) with hb
  have hab : a ≠ b := by
    intro hab
    exact hst ((fieldIndex K).injective (Subtype.ext hab))
  simp only [Prod.mk.injEq, fieldSquare] at h
  obtain ⟨h1, h2⟩ := h
  have e1 : a * fieldCoord K i + fieldCoord K j = a * fieldCoord K i' + fieldCoord K j' :=
    (fieldCoord K).symm.injective h1
  have e2 : b * fieldCoord K i + fieldCoord K j = b * fieldCoord K i' + fieldCoord K j' :=
    (fieldCoord K).symm.injective h2
  have key : (a - b) * (fieldCoord K i - fieldCoord K i') = 0 := by linear_combination e1 - e2
  have hx : fieldCoord K i = fieldCoord K i' := by
    rcases mul_eq_zero.mp key with h' | h'
    · exact absurd (sub_eq_zero.mp h') hab
    · exact sub_eq_zero.mp h'
  have hi : i = i' := (fieldCoord K).injective hx
  have hj : j = j' := by
    apply (fieldCoord K).injective
    have := e1
    rw [hx] at this
    exact add_left_cancel this
  simp [hi, hj]

/-- **The saturated family of a finite field.**  For every finite field `K` the affine
squares `L a i j = a * i + j`, with `a` ranging over the nonzero elements, form a family
of `|K| - 1` mutually orthogonal Latin squares of order `|K|`. -/
noncomputable def fieldMOLS : MOLS (Fintype.card K) (Fintype.card K - 1) where
  L := fieldSquare K
  latin := fieldSquare_isLatin K
  ortho := fun _ _ hst => fieldSquare_orthogonal K hst

end FieldConstruction

/-- Existence of a saturated (`n - 1`-member) MOLS family in every finite field order. -/
theorem exists_saturated_MOLS_of_field (K : Type*) [Field K] [Fintype K] [DecidableEq K] :
    Nonempty (MOLS (Fintype.card K) (Fintype.card K - 1)) :=
  ⟨fieldMOLS K⟩

/-- **Sharpness of the Euler–MacNeish ceiling in field orders.**  For a finite field `K` of
order `n ≥ 2`, families of mutually orthogonal Latin squares of order `n` have at most
`n - 1` members, and this value is attained. -/
theorem MOLS_sharp_of_field (K : Type*) [Field K] [Fintype K] [DecidableEq K]
    (hK : 2 ≤ Fintype.card K) :
    IsGreatest {k : ℕ | Nonempty (MOLS (Fintype.card K) k)} (Fintype.card K - 1) :=
  ⟨exists_saturated_MOLS_of_field K, fun _ hk => main_MOLS_bound hK hk.some⟩

/-- **Sharpness in prime order.**  For a prime `p` the maximum number of mutually
orthogonal Latin squares of order `p` is exactly `p - 1`. -/
theorem MOLS_sharp_prime (p : ℕ) (hp : p.Prime) :
    IsGreatest {k : ℕ | Nonempty (MOLS p k)} (p - 1) := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have h := MOLS_sharp_of_field (ZMod p) (by rw [hcard]; exact hp.two_le)
  rwa [hcard] at h

/-- **Sharpness in prime-power order.**  For a prime power `p ^ m` (`m ≠ 0`) the maximum
number of mutually orthogonal Latin squares of order `p ^ m` is exactly `p ^ m - 1`; the
witness is the affine family over the Galois field of that order. -/
theorem MOLS_sharp_prime_pow (p m : ℕ) [Fact p.Prime] (hm : m ≠ 0) :
    IsGreatest {k : ℕ | Nonempty (MOLS (p ^ m) k)} (p ^ m - 1) := by
  classical
  letI : Fintype (GaloisField p m) := Fintype.ofFinite _
  have hcard : Fintype.card (GaloisField p m) = p ^ m := by
    rw [← Nat.card_eq_fintype_card]
    exact GaloisField.card p m hm
  have h2 : 2 ≤ Fintype.card (GaloisField p m) := by
    rw [hcard]
    exact Nat.one_lt_pow hm (Fact.out (p := p.Prime)).one_lt
  have h := MOLS_sharp_of_field (GaloisField p m) h2
  rwa [hcard] at h

end Catalog.Physics.OrthogonalNets