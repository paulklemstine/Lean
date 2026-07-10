import Mathlib

/-!
# Universal Objects and the Uniqueness of the Optimal Resolution

The metric theory of surprise (see `JokeHumorMetric`) measures *how much* a resolution
subverts a setup. Here we address a complementary, structural question: given a fixed
setup, is there a *canonical* subverting resolution, and in what sense is it unique?

We model the resolutions compatible with a fixed setup as the objects of a category
`C`, with morphisms recording refinements between resolutions. A **universal
resolution** is then a *terminal object*: an object into which every other resolution
maps in exactly one way. This captures the informal claim that the optimal resolution
of a setup is the one every other resolution ultimately defers to.

Main results:

* `universal_hom_unique` : every resolution refines to the universal one in a *unique*
  way — the "unique natural transformation" property.
* `universal_from_unique_existence` : existence-and-uniqueness of the refinement, stated
  as `∃!`.
* `universal_endo_id` : the universal resolution has no nontrivial self-refinement.
* `universal_unique_up_to_iso` : any two universal resolutions of the same setup are
  canonically isomorphic, and
* `universal_iso_coherent` : that canonical isomorphism is coherent (its round trip is
  the identity).
* `punit_isUniversal` : the trivial one-point resolution is universal among sets — a
  concrete witness that universal resolutions exist.

-- !-- Lab Notes -- !--
Hypothesis: "the optimal resolution of a setup is unique." We formalise optimality as
terminality in the category of compatible resolutions and test whether terminality
forces the strong uniqueness one expects of a genuinely canonical object.

Experiment: working in an arbitrary `Category C`, we derived each uniqueness statement
from the single primitive `IsTerminal.hom_ext`, and exhibited a concrete terminal
object (`PUnit`) to rule out vacuity.

Analysis: terminality yields three graded uniqueness statements — of morphisms
(`universal_hom_unique`), of the object up to isomorphism
(`universal_unique_up_to_iso`), and coherence of that isomorphism
(`universal_iso_coherent`). The endomorphism rigidity `universal_endo_id` shows the
universal resolution is *rigid*: it cannot be nontrivially reinterpreted.

Critique: terminality is a strong hypothesis; not every setup admits a universal
resolution. The concrete witness `punit_isUniversal` guarantees the theory is not
vacuous, and the abstract results apply to any category that does have one.

Synthesis: when a canonical (terminal) resolution exists, it is unique in the
strongest available sense — up to a unique, coherent isomorphism — matching the
intuition that the optimal reading of a setup is essentially forced.
-/

open CategoryTheory CategoryTheory.Limits

namespace UniversalJoke

variable {C : Type*} [Category C]

/-- **Unique refinement.** Every resolution refines to a universal resolution in exactly
one way. -/
theorem universal_hom_unique {T : C} (hT : IsTerminal T) {X : C} (f g : X ⟶ T) :
    f = g := hT.hom_ext f g

/-- Existence and uniqueness of the refinement into a universal resolution. -/
theorem universal_from_unique_existence {T : C} (hT : IsTerminal T) (X : C) :
    ∃! _f : X ⟶ T, True := by
  refine ⟨hT.from X, trivial, ?_⟩
  intro y _
  exact hT.hom_ext y (hT.from X)

/-- **Rigidity.** A universal resolution admits no nontrivial self-refinement. -/
theorem universal_endo_id {T : C} (hT : IsTerminal T) (f : T ⟶ T) : f = 𝟙 T :=
  hT.hom_ext f (𝟙 T)

/-- Any two universal resolutions of a setup are canonically isomorphic. -/
noncomputable def universal_unique_up_to_iso {T T' : C} (hT : IsTerminal T)
    (hT' : IsTerminal T') : T ≅ T' :=
  hT.uniqueUpToIso hT'

/-- The canonical isomorphism between two universal resolutions is coherent: its round
trip is the identity. -/
theorem universal_iso_coherent {T T' : C} (hT : IsTerminal T) (hT' : IsTerminal T') :
    (universal_unique_up_to_iso hT hT').hom ≫ (universal_unique_up_to_iso hT hT').inv
      = 𝟙 T := by
  simp [universal_unique_up_to_iso]

/-- **Concrete witness.** The trivial one-point resolution is universal among sets. -/
noncomputable def punit_isUniversal : IsTerminal (PUnit : Type) :=
  Types.isTerminalPUnit

end UniversalJoke