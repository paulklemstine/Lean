/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Closing the loop: field orders carry affine planes

This capstone combines the two halves of the cycle.

* `Physics.OrthogonalNets.FieldMOLS` builds, for every finite field `K`, a family of
  `|K| - 1` mutually orthogonal Latin squares of order `|K|` — a family *saturating* the
  Euler–MacNeish ceiling.
* `Physics.OrthogonalNets.AffinePlane` shows that a saturated family coordinatizes an
  affine plane: two distinct cells lie on exactly one line, every line has `n` points, and
  there are `n² + n` lines in `n + 1` parallel classes.

Putting them together gives `affinePlane_of_field` and its prime specialization
`affinePlane_of_prime`: the incidence axioms of an affine plane of order `n` are satisfied
by the grid `Fin n × Fin n` whenever `n` is the cardinality of a finite field.
-/

import Physics.OrthogonalNets.AffinePlane
import Physics.OrthogonalNets.FieldMOLS

namespace Catalog.Physics.OrthogonalNets

open Function
open Catalog.Computation.ReticulationMOLS

/-- **An affine plane of order `|K|` from a finite field `K`.**  The saturated MOLS family
`fieldMOLS K` turns the grid into an affine plane: any two distinct cells lie on exactly one
line, every line carries exactly `|K|` cells, two lines of the same parallel class are
disjoint, two lines of different classes meet exactly once, and there are `|K|² + |K|`
lines in total. -/
theorem affinePlane_of_field (K : Type*) [Field K] [Fintype K] [DecidableEq K]
    (hK : 1 ≤ Fintype.card K) :
    (∀ p q : Fin (Fintype.card K) × Fin (Fintype.card K), p ≠ q →
        ∃! ℓ : Line (Fintype.card K) (Fintype.card K - 1),
          OnLine (fieldMOLS K) ℓ p ∧ OnLine (fieldMOLS K) ℓ q)
      ∧ (∀ ℓ : Line (Fintype.card K) (Fintype.card K - 1),
          Nat.card {p // OnLine (fieldMOLS K) ℓ p} = Fintype.card K)
      ∧ (∀ ℓ₁ ℓ₂ : Line (Fintype.card K) (Fintype.card K - 1), ℓ₁.cls = ℓ₂.cls → ℓ₁ ≠ ℓ₂ →
          ∀ p, ¬(OnLine (fieldMOLS K) ℓ₁ p ∧ OnLine (fieldMOLS K) ℓ₂ p))
      ∧ (∀ ℓ₁ ℓ₂ : Line (Fintype.card K) (Fintype.card K - 1), ℓ₁.cls ≠ ℓ₂.cls →
          ∃! p, OnLine (fieldMOLS K) ℓ₁ p ∧ OnLine (fieldMOLS K) ℓ₂ p)
      ∧ Fintype.card (Line (Fintype.card K) (Fintype.card K - 1))
          = Fintype.card K ^ 2 + Fintype.card K :=
  ⟨fun _ _ hpq => existsUnique_line_join rfl hpq,
   card_line (fieldMOLS K),
   fun _ _ hcls hne => disjoint_of_cls_eq (fieldMOLS K) hcls hne,
   fun _ _ hcls => existsUnique_meet (fieldMOLS K) hcls,
   card_Line_saturated rfl hK⟩

/-- **An affine plane of prime order.**  For every prime `p` the grid `Fin p × Fin p`
carries an affine plane of order `p`, coordinatized by the `p - 1` mutually orthogonal
Latin squares `L a i j = a * i + j` over `ZMod p`. -/
theorem affinePlane_of_prime (p : ℕ) (hp : p.Prime) :
    ∃ S : MOLS p (p - 1),
      (∀ x y : Fin p × Fin p, x ≠ y → ∃! ℓ : Line p (p - 1), OnLine S ℓ x ∧ OnLine S ℓ y)
        ∧ (∀ ℓ : Line p (p - 1), Nat.card {x // OnLine S ℓ x} = p)
        ∧ Fintype.card (Line p (p - 1)) = p ^ 2 + p := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  obtain ⟨S⟩ : Nonempty (MOLS p (p - 1)) := by
    have h := exists_saturated_MOLS_of_field (ZMod p)
    rwa [hcard] at h
  exact ⟨S, fun _ _ hxy => existsUnique_line_join rfl hxy, card_line S,
    card_Line_saturated rfl hp.pos⟩

/-- **An affine plane of prime-power order.**  For every prime power `n = p ^ m` the grid
`Fin n × Fin n` carries an affine plane of order `n`, coordinatized by a saturated family of
`n - 1` mutually orthogonal Latin squares over the Galois field of order `n`. -/
theorem affinePlane_of_prime_pow (p m : ℕ) [Fact p.Prime] (hm : m ≠ 0) :
    ∃ S : MOLS (p ^ m) (p ^ m - 1),
      (∀ x y : Fin (p ^ m) × Fin (p ^ m), x ≠ y →
          ∃! ℓ : Line (p ^ m) (p ^ m - 1), OnLine S ℓ x ∧ OnLine S ℓ y)
        ∧ (∀ ℓ : Line (p ^ m) (p ^ m - 1), Nat.card {x // OnLine S ℓ x} = p ^ m)
        ∧ Fintype.card (Line (p ^ m) (p ^ m - 1)) = (p ^ m) ^ 2 + p ^ m := by
  obtain ⟨S⟩ : Nonempty (MOLS (p ^ m) (p ^ m - 1)) := (MOLS_sharp_prime_pow p m hm).1
  exact ⟨S, fun _ _ hxy => existsUnique_line_join rfl hxy, card_line S,
    card_Line_saturated rfl (Nat.one_le_pow _ _ (Fact.out (p := p.Prime)).pos)⟩

end Catalog.Physics.OrthogonalNets