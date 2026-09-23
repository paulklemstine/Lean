import Cryptography.NonabelianTypeChannel.Fields
import Cryptography.NonabelianTypeChannel.Completeness

/-!
# Which of the six fields have complete channels, and why

`Completeness.lean` characterises attainment of the abelianization cap: the channel
delivers all of `log₂[G : G']` exactly when the splitting type determines the coset.
This file checks that criterion field by field, so that the exact values of
`Fields.lean` are matched by a structural explanation.

* `S₃` and `S₄` are complete, because the parity of a permutation is a function of its
  cycle type.
* `A₄`, `D₄`, `V₄` and `C₄` are not: in each case a single splitting type occurs in two
  different cosets, and the resulting shortfall is the "loss" column of the law table.
* Conversely, `S₄` shows the opposite failure: a single coset (`A₄`) carries several
  types, so the channel is strictly below the *type* entropy.
-/

namespace TypeChannel

open Finset Real

set_option maxRecDepth 4000000

/-- In `S₃` the splitting type determines the parity. -/
theorem S3_type_determines_coset :
    ∀ a ∈ S3, ∀ b ∈ S3, splitType a = splitType b → signIdx a = signIdx b := by decide

/-- In `S₄` the splitting type determines the parity. -/
theorem S4_type_determines_coset :
    ∀ a ∈ S4, ∀ b ∈ S4, splitType a = splitType b → signIdx a = signIdx b := by decide

/-- Structural version of `S4_channel`: the `S₄` channel attains its cap because the
type determines the coset. -/
theorem S4_complete :
    mutualInfo S4 signIdx splitType = logb 2 (S4.image signIdx).card :=
  (typeChannel_complete_iff S4_isSubgroup A4_isSubgroup (by decide) S4_coset).mpr
    S4_type_determines_coset

theorem S3_complete :
    mutualInfo S3 signIdx splitType = logb 2 (S3.image signIdx).card :=
  (typeChannel_complete_iff S3_isSubgroup A3_isSubgroup (by decide) S3_coset).mpr
    S3_type_determines_coset

/-- In `A₄` the type `[2,2]` and the type `[1,1,1,1]` both live in the trivial coset,
but the type `[3,1]` occupies two different cosets: the type does *not* determine the
coset, so the `A₄` channel misses its cap. -/
theorem A4_type_does_not_determine_coset :
    ¬ (∀ a ∈ A4, ∀ b ∈ A4, splitType a = splitType b → pairIdx a = pairIdx b) := by decide

theorem A4_incomplete :
    mutualInfo A4 pairIdx splitType ≠ logb 2 (A4.image pairIdx).card := by
  intro h
  exact A4_type_does_not_determine_coset
    ((typeChannel_complete_iff A4_isSubgroup V4_isSubgroup (by decide) A4_coset).mp h)

theorem D4_type_does_not_determine_coset :
    ¬ (∀ a ∈ D4, ∀ b ∈ D4, splitType a = splitType b → d4Idx a = d4Idx b) := by decide

theorem D4_incomplete :
    mutualInfo D4 d4Idx splitType ≠ logb 2 (D4.image d4Idx).card := by
  intro h
  exact D4_type_does_not_determine_coset
    ((typeChannel_complete_iff D4_isSubgroup Z4c_isSubgroup (by decide) D4_coset).mp h)

/-- `V₄` and `C₄` are abelian, so their channels carry the entire splitting entropy —
a structural reproof of `V4_channel` and `C4_channel`. -/
theorem V4_abelian_complete : mutualInfo V4 rootIdx splitType = entropy V4 splitType :=
  typeChannel_abelian_eq_entropy V4_isSubgroup (by decide) V4_derived V4_coset splitType

theorem C4_abelian_complete : mutualInfo C4 rootIdx splitType = entropy C4 splitType :=
  typeChannel_abelian_eq_entropy C4_isSubgroup (by decide) C4_derived C4_coset splitType

/-- Structural version of `S4_cap_strict`: the even coset of `S₄` carries both the
identity type `[1,1,1,1]` and the type `[2,2]`, so the channel is strictly below the
splitting entropy. -/
theorem S4_below_type_entropy : mutualInfo S4 signIdx splitType < entropy S4 splitType := by
  refine typeChannel_lt_entropy_of_coset_splits (a := 1)
    (b := Equiv.swap 0 1 * Equiv.swap 2 3) (by decide) (by decide) (by decide) (by decide)

end TypeChannel