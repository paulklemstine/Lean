/-
# The Kronecker–Weber realization direction, made explicit

The Kronecker–Weber theorem has two halves.  The deep half asserts that *every* finite abelian
extension of `ℚ` embeds into a cyclotomic field.  The constructive half — the one that makes
cyclotomic fields the universal source of abelian extensions — asserts the converse: every
subextension of a cyclotomic field `ℚ(ζₙ)` is itself abelian over `ℚ`.

This file formalizes that constructive half completely, building on the reciprocity data of
`Catalog.Novelty.CyclotomicGL1Langlands` (specifically `CyclotomicGL1.galois_abelian`, which
records that `Gal(ℚ(ζₙ)/ℚ)` is commutative).

Main results, for an arbitrary intermediate field `ℚ ≤ L ≤ ℚ(ζₙ)`:

* `KroneckerWeberRealization.fixingSubgroup_normal` — the fixing subgroup of `L` is normal in
  `Gal(ℚ(ζₙ)/ℚ)` (immediate from commutativity: conjugation is trivial).
* `KroneckerWeberRealization.intermediate_isGalois` — consequently `L/ℚ` is a Galois extension
  (via the Galois correspondence `InfiniteGalois.normal_iff_isGalois`).
* `KroneckerWeberRealization.intermediate_galois_abelian` — and its Galois group `Gal(L/ℚ)` is
  abelian, transported from `Gal(ℚ(ζₙ)/ℚ)` along the surjective restriction homomorphism.

Together these say: *the lattice of subfields of a cyclotomic field consists entirely of finite
abelian extensions of `ℚ`* — the "cyclotomic fields realize abelian extensions" content of
Kronecker–Weber.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Since `Gal(ℚ(ζₙ)/ℚ)` is abelian (catalog fact), *every* subgroup is
normal, so *every* intermediate field should be Galois over `ℚ` with an abelian Galois group.
This is the explicit "realization" half of Kronecker–Weber and should be fully provable.

Experiment (Experimenter): (1) Normality of the fixing subgroup was proved by hand from
`galois_abelian`: conjugation `g x g⁻¹ = x`. (2) Galoisness of `L` used the equivalence
`InfiniteGalois.normal_iff_isGalois`. (3) Abelianness of `Gal(L/ℚ)` used
`AlgEquiv.restrictNormalHom_surjective` to pull the identity back to the big group.  A subtlety:
the surjectivity lemma is stated as surjectivity of `restrictNormalHom` with `K₁ := L` (the
*small* field) and the *big* field as the explicit `E` argument.

Analysis (Analyst): "True and unconditional over the whole subfield lattice." The only genuine
input is commutativity of the top Galois group; everything else is the Galois correspondence.
Failure mode avoided: trying to state abelianness of `Gal(L/ℚ)` directly on a `CommGroup`
instance (Mathlib does not register one on `AlgEquiv`), which forced the surjection argument.

Critique (Critic): No triviality — the results quantify over *all* intermediate fields and use
`by_contra`-free but genuinely structural Galois theory.  We do not assume `L` finite-dimensional
separately; it is inherited from the finite cyclotomic tower.

Synthesis (PI): This is the reusable statement "subfields of cyclotomic fields are abelian over
ℚ", the exact converse content needed to complete a future Kronecker–Weber formalization.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.CyclotomicGL1Langlands

open Polynomial IntermediateField CyclotomicGL1

namespace KroneckerWeberRealization

variable (n : ℕ) [NeZero n]

/-- The `n`-th cyclotomic field is a (finite) Galois extension of `ℚ`. -/
instance cyclo_isGalois : IsGalois ℚ (CyclotomicField n ℚ) :=
  IsCyclotomicExtension.isGalois {n} ℚ (CyclotomicField n ℚ)

/-- **Every fixing subgroup is normal.**  For any intermediate field `ℚ ≤ L ≤ ℚ(ζₙ)`, its fixing
subgroup in `Gal(ℚ(ζₙ)/ℚ)` is normal — because the ambient Galois group is commutative, so
conjugation acts trivially. -/
theorem fixingSubgroup_normal (L : IntermediateField ℚ (CyclotomicField n ℚ)) :
    L.fixingSubgroup.Normal := by
  refine ⟨fun x hx g => ?_⟩
  have hxfix : g * x * g⁻¹ = x := by
    rw [galois_abelian n g x, mul_assoc, mul_inv_cancel, mul_one]
  rw [hxfix]; exact hx

/-- **Every subextension of a cyclotomic field is Galois over `ℚ`.**  This is one half of the
Galois-correspondence translation of `fixingSubgroup_normal`. -/
theorem intermediate_isGalois (L : IntermediateField ℚ (CyclotomicField n ℚ)) :
    IsGalois ℚ L :=
  (InfiniteGalois.normal_iff_isGalois L).mp (fixingSubgroup_normal n L)

/-- **Every subextension of a cyclotomic field is abelian over `ℚ`.**  The Galois group
`Gal(L/ℚ)` is commutative, transported from `Gal(ℚ(ζₙ)/ℚ)` along the surjective restriction
homomorphism.  This is the constructive ("realization") direction of Kronecker–Weber. -/
theorem intermediate_galois_abelian (L : IntermediateField ℚ (CyclotomicField n ℚ))
    (a b : L ≃ₐ[ℚ] L) : a * b = b * a := by
  haveI : IsGalois ℚ L := intermediate_isGalois n L
  haveI : Normal ℚ L := IsGalois.to_normal
  have hs := AlgEquiv.restrictNormalHom_surjective (F := ℚ) (K₁ := L) (CyclotomicField n ℚ)
  obtain ⟨a', rfl⟩ := hs a
  obtain ⟨b', rfl⟩ := hs b
  rw [← map_mul, ← map_mul, galois_abelian n a' b']

end KroneckerWeberRealization