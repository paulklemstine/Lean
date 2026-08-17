/-
# The exact sequence of a regular covering, and group extensions as coverings

Continuing the covering thread of the catalog, this file assembles the classical short
exact sequence attached to a regular covering of a `K(G,1)`,

  `1 → π₁(total space) → π₁(base) → Deck → 1`,

and reads it backwards as a dictionary between group extensions and regular coverings:
a surjection `φ : G →* Q` with kernel `N` is exactly the data of a regular covering of
`K(G,1)` whose total space is a `K(N,1)` and whose deck group is `Q`.

Main results:

* `regularCovering_exact`: the four statements making up the exact sequence — the
  fundamental group of the covering injects into that of the base, with image exactly
  `H`, the deck homomorphism is onto, and its kernel is exactly `H`;
* `deckMulEquivOfSurjective`: the deck group of the covering attached to a surjection
  `φ : G →* Q` is `Q`;
* `extension_as_covering`: the packaged dictionary between extensions and coverings.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringDeck
import Bridges.FundamentalGroupCoveringExamples

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

variable {G : Type u} [Group G]

/-! ## The exact sequence of a regular covering -/

section Exact

variable (H : Subgroup G)

/-- The fundamental group of the total space of the covering classified by `H`, mapped
into the fundamental group of the base. -/
noncomputable def piCovering :
    Aut (ActionCategory.objEquiv G (G ⧸ H) (((1 : G) : G ⧸ H))) → G :=
  fun a => ((autMulEquivStabilizer (((1 : G) : G ⧸ H))) a : G)

theorem piCovering_injective : Function.Injective (piCovering H) :=
  pi_injective (((1 : G) : G ⧸ H))

theorem piCovering_range : Set.range (piCovering H) = (H : Set G) := by
  have h := pi_range (G := G) (X := G ⧸ H) (((1 : G) : G ⧸ H))
  have hst : ((stabilizer G (((1 : G) : G ⧸ H)) : Subgroup G) : Set G) = (H : Set G) := by
    rw [MulAction.stabilizer_quotient]
  exact h.trans hst

variable [H.Normal]

/-- **The short exact sequence of a regular covering.**
`1 → π₁(covering) → π₁(base) → Deck → 1`: the first map is injective with image `H`, the
second is surjective, and its kernel is exactly the image of the first. -/
theorem regularCovering_exact :
    Function.Injective (piCovering H) ∧
      Set.range (piCovering H) = (H : Set G) ∧
      Function.Surjective (deckHomOfNormal H) ∧
      ((deckHomOfNormal H).ker : Set G) = Set.range (piCovering H) := by
  refine ⟨piCovering_injective H, piCovering_range H, deckHomOfNormal_surjective H, ?_⟩
  rw [piCovering_range, deckHomOfNormal_ker]

end Exact

/-! ## Group extensions as regular coverings -/

section Extension

variable {Q : Type u} [Group Q] (phi : G →* Q)

/-- **The deck group of the covering attached to a surjection `φ : G →* Q` is `Q`.** -/
noncomputable def deckMulEquivOfSurjective (hphi : Function.Surjective phi) :
    DeckSubgroup G (G ⧸ phi.ker) ≃* Q :=
  (deckRegularMulEquiv phi.ker).symm.trans
    (QuotientGroup.quotientKerEquivOfSurjective phi hphi)

/-- The fundamental group of the total space of that covering is the kernel of `φ`. -/
noncomputable def autCoveringMulEquivKer :
    Aut (ActionCategory.objEquiv G (G ⧸ phi.ker) (((1 : G) : G ⧸ phi.ker))) ≃* phi.ker :=
  (autMulEquivStabilizer (((1 : G) : G ⧸ phi.ker))).trans
    (MulEquiv.subgroupCongr (MulAction.stabilizer_quotient phi.ker))

/-- **Group extensions are regular coverings.**  A surjection `φ : G →* Q` gives a
connected covering of the `K(G,1)` whose total space is a `K(N,1)` for `N = ker φ`, whose
deck group is `Q`, and which is regular. -/
theorem extension_as_covering (hphi : Function.Surjective phi) :
    Nonempty (Aut (ActionCategory.objEquiv G (G ⧸ phi.ker) (((1 : G) : G ⧸ phi.ker)))
        ≃* phi.ker) ∧
      Nonempty (DeckSubgroup G (G ⧸ phi.ker) ≃* Q) ∧
      (∀ p q : G ⧸ phi.ker, ∃ f ∈ DeckSubgroup G (G ⧸ phi.ker), f p = q) :=
  ⟨⟨autCoveringMulEquivKer phi⟩, ⟨deckMulEquivOfSurjective phi hphi⟩,
    (deck_transitive_iff_normal phi.ker).mpr inferInstance⟩

end Extension

/-! ## Isomorphism of quotient coverings -/

section QuotientCoverings

variable (H K : Subgroup G)

/-- **Two quotient coverings are isomorphic exactly when their subgroups are
conjugate.**  This is the Galois correspondence in its most concrete form. -/
theorem quotient_coverings_iso_iff_conj :
    Nonempty (GEquiv G (G ⧸ H) (G ⧸ K)) ↔
      ∃ g : G, K = H.map (MulAut.conj g).toMonoidHom := by
  have h := nonempty_gEquiv_iff_isConj (G := G) (X := G ⧸ H) (Y := G ⧸ K)
    (((1 : G) : G ⧸ H)) (((1 : G) : G ⧸ K))
  rw [MulAction.stabilizer_quotient, MulAction.stabilizer_quotient] at h
  exact h

end QuotientCoverings

end FundamentalGroupCovering