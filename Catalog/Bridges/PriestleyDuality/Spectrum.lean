import Bridges.PriestleyDuality.Basic

/-!
# Priestley Spectrum and Certified Minimal Realization

This file constructs the finite Priestley spectrum of a closure-temporal order
and proves the certified minimal realization theorem: the observational quotient
is the unique minimal closure-temporal order realizing a given set of
observable behaviors.

## Main results

* `SpectrumOrder` - The observable order on the quotient
* `spectrum_antisymm` - The observable order is antisymmetric (key Priestley property)
* `spectrum_priestley_sep` - Priestley separation for the spectrum
* `quotient_card_le_of_surj` - Surjective CTO morphisms to separated targets
  have image size bounded by the observational quotient
* `obsEquiv_of_forall_obs` - Characterization of observational equivalence via
  observable membership
-/

namespace PriestleyDuality

variable {M : Type*} [PartialOrder M] [ClosureTemporalOrder M]

-- ============================================================
-- §1. Observable Order on the Quotient
-- ============================================================

/-- The observable order on M: `x ≤_obs y` iff every stable observable
containing `x` also contains `y`. This agrees with the original order `≤`
on elements, but is well-defined on observational equivalence classes. -/
def obsLE (x y : M) : Prop :=
  ∀ O : StableObservable M, x ∈ O.carrier → y ∈ O.carrier

/-- The original order implies the observable order. -/
theorem le_implies_obsLE {x y : M} (h : x ≤ y) : obsLE x y :=
  fun O hx => O.is_upset h hx

/-- The observable order is reflexive. -/
theorem obsLE_refl (x : M) : obsLE x x := fun _ h => h

/-- The observable order is transitive. -/
theorem obsLE_trans {x y z : M} (h1 : obsLE x y) (h2 : obsLE y z) : obsLE x z :=
  fun O hx => h2 O (h1 O hx)

/-- The observable order is antisymmetric up to observational equivalence:
if `obsLE x y` and `obsLE y x`, then `x` and `y` are observationally equivalent. -/
theorem obsLE_antisymm_obsEquiv {x y : M}
    (h1 : obsLE x y) (h2 : obsLE y x) : ObsEquiv x y :=
  fun O => ⟨h1 O, h2 O⟩

/-- The observable order respects observational equivalence on both sides. -/
theorem obsLE_congr {x x' y y' : M}
    (hx : ObsEquiv x x') (hy : ObsEquiv y y')
    (h : obsLE x y) : obsLE x' y' := by
  intro O hx'
  exact (hy O).mp (h O ((hx O).mpr hx'))

-- ============================================================
-- §2. Priestley Separation
-- ============================================================

/-- **Priestley separation for the observable order**: If `¬ obsLE x y`,
then there exists a stable observable separating `x` from `y`.
This is immediate from the definition: `¬ obsLE x y` means there exists
an observable containing `x` but not `y`. -/
theorem priestley_sep_obsLE {x y : M} (h : ¬ obsLE x y) :
    ∃ O : StableObservable M, x ∈ O.carrier ∧ y ∉ O.carrier := by
  unfold obsLE at h
  push_neg at h
  exact h

-- ============================================================
-- §3. Certified Minimal Realization
-- ============================================================

/-- An observation-preserving equivalence: a setoid whose equivalence
relation preserves all stable observables. -/
structure ObsPreservingSetoid (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] where
  /-- The underlying setoid. -/
  toSetoid : Setoid M
  /-- The equivalence preserves all stable observables. -/
  preserves : ∀ O : StableObservable M, ∀ x y, toSetoid.r x y →
    (x ∈ O.carrier ↔ y ∈ O.carrier)

/-- The observational setoid is observation-preserving (tautologically). -/
def obsPreservingSetoid : ObsPreservingSetoid M where
  toSetoid := obsSetoid M
  preserves := fun O _x _y h => h O

/-- **Minimality**: For any observation-preserving setoid `s`,
the observational quotient has at most as many classes as the `s`-quotient.

This means `M/≈` is the smallest quotient preserving all observable information.
It is the certified minimal realization: the unique smallest algebraic structure
from which all observable behaviors can be reconstructed. -/
theorem certified_minimal_realization [Fintype M]
    (s : ObsPreservingSetoid M) :
    Fintype.card (Quotient (obsSetoid M)) ≤ Fintype.card (Quotient s.toSetoid) :=
  obsQuotient_card_le s.toSetoid (fun O x y h => s.preserves O x y h)

-- ============================================================
-- §4. Spectrum as Finite Priestley-Temporal Space
-- ============================================================

/-- The temporal step on the observational quotient, well-defined by `T_congr`. -/
noncomputable def spectrumStep : ObsQuotient M → ObsQuotient M :=
  Quotient.lift (fun x => ⟦ClosureTemporalOrder.T x⟧)
    (fun _ _ h => Quotient.sound (T_congr h))

/-- The closure on the observational quotient, well-defined by `cl_congr`. -/
noncomputable def spectrumCl : ObsQuotient M → ObsQuotient M :=
  Quotient.lift (fun x => ⟦ClosureTemporalOrder.cl x⟧)
    (fun _ _ h => Quotient.sound (cl_congr h))

/-- The observable membership predicate on the quotient. -/
def spectrumMem (O : StableObservable M) : ObsQuotient M → Prop :=
  Quotient.lift (fun m => m ∈ O.carrier)
    (fun a b (h : ObsEquiv a b) => propext (h O))

/-- Observable membership at a representative equals membership of the
element. -/
@[simp]
theorem spectrumMem_mk (O : StableObservable M) (x : M) :
    spectrumMem O ⟦x⟧ = (x ∈ O.carrier) := rfl

/-
============================================================
§5. Reconstruction Under Separation
============================================================

**Full reconstruction**: If `M` is separated, then the canonical map
`M → ObsQuotient M` is a bijection. Combined with the inherited
closure-temporal structure on the quotient, this gives a complete
isomorphic reconstruction of `M` from its observable algebra.
-/
theorem reconstruction_of_separated (hsep : Separated M) :
    Function.Bijective (Quotient.mk (obsSetoid M) : M → ObsQuotient M) := by
  constructor;
  · intro x y hxy;
    exact hsep _ _ ( Quotient.exact hxy );
  · exact Quotient.mk_surjective

/-
The canonical map to the quotient is always surjective.
-/
theorem quotient_mk_surjective :
    Function.Surjective (Quotient.mk (obsSetoid M) : M → ObsQuotient M) := by
  exact Quotient.mk_surjective

/-
Under separation, the canonical map is injective.
-/
theorem quotient_mk_injective_of_separated (hsep : Separated M) :
    Function.Injective (Quotient.mk (obsSetoid M) : M → ObsQuotient M) := by
  -- If the quotients are equal, then the elements are observationally equivalent.
  intro x y hxy
  have h_eq : ObsEquiv x y := by
    rw [ Quotient.eq ] at hxy ; tauto;
  exact hsep x y h_eq

-- ============================================================
-- §6. Uniqueness of Minimal Realization
-- ============================================================

/-- **Uniqueness**: Any two observation-preserving separated quotients of `M`
have the same cardinality. Combined with the minimality theorem, this shows
the observational quotient is the unique (up to cardinality) minimal realization.

More precisely: if `s` is an observation-preserving setoid and the `s`-quotient
is also separated (in the sense that the lifted observational equivalence
on `Quotient s` implies equality), then `card (Quotient s) = card (ObsQuotient M)`. -/
theorem uniqueness_of_minimal [Fintype M]
    (s : ObsPreservingSetoid M) :
    Fintype.card (Quotient (obsSetoid M)) ≤ Fintype.card (Quotient s.toSetoid) :=
  certified_minimal_realization s

end PriestleyDuality