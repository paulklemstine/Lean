/-
# Double coverings are mod-two characters

This file closes the loop on the double-covering strand of the thread.  Over an arbitrary
base `K(G,1)` we prove that

    { connected double coverings of K(G,1) } / iso  ≅  Hom(G, C₂) \ {1},

by an explicit bijection `indexTwoEquivNontrivialChar` between nontrivial homomorphisms
`G →* C₂` and subgroups of index two, sending a character to its kernel.  Together with
`index_two_gEquiv_iff_eq` (isomorphism of double coverings is *equality* of subgroups,
because index-two subgroups are normal) this identifies the set of isomorphism classes of
connected double coverings of a `K(G,1)` with the nonzero classes of `H¹(G; 𝔽₂) =
Hom(G, C₂)`.

Main results:

* `charOfIndexTwo`, `ker_charOfIndexTwo`: every index-two subgroup is the kernel of a
  character with values in `C₂`;
* `char_eq_of_ker_eq`: a `C₂`-valued character is determined by its kernel;
* `indexTwoEquivNontrivialChar`: the resulting bijection;
* `doubleCoverings_equiv_nontrivial_characters`: the covering-theoretic reading.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringTwistedPair

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

section Characters

variable {K : Type u} [Group K]

/-- Every element of `C₂` is either trivial or the generator. -/
theorem C2_eq_one_or (a : C2) : a = 1 ∨ a = Multiplicative.ofAdd (1 : ZMod 2) := by
  revert a; decide

/-- A nontrivial `C₂`-valued character is surjective. -/
theorem char_surjective_of_ne_one {phi : K →* C2} (h : phi ≠ 1) :
    Function.Surjective phi := by
  obtain ⟨g, hg⟩ : ∃ g : K, phi g ≠ 1 := by
    by_contra hc
    push_neg at hc
    exact h (MonoidHom.ext fun g => by simp [hc g])
  have hgen : phi g = Multiplicative.ofAdd (1 : ZMod 2) :=
    (C2_eq_one_or (phi g)).resolve_left hg
  intro c
  rcases C2_eq_one_or c with rfl | rfl
  · exact ⟨1, map_one phi⟩
  · exact ⟨g, hgen⟩

/-- The kernel of a nontrivial `C₂`-valued character has index two. -/
theorem index_ker_of_ne_one {phi : K →* C2} (h : phi ≠ 1) : phi.ker.index = 2 :=
  index_ker_eq_two (char_surjective_of_ne_one h)

/-- **A `C₂`-valued character is determined by its kernel.** -/
theorem char_eq_of_ker_eq {phi psi : K →* C2} (h : phi.ker = psi.ker) : phi = psi := by
  ext g
  have hiff : phi g = 1 ↔ psi g = 1 := by
    constructor
    · intro hg
      have : g ∈ psi.ker := by rw [← h]; exact hg
      exact this
    · intro hg
      have : g ∈ phi.ker := by rw [h]; exact hg
      exact this
  rcases C2_eq_one_or (phi g) with h1 | h1
  · rw [h1, (hiff.mp h1).symm]
  · have h2 : psi g ≠ 1 := fun hc => by
      rw [hiff.mpr hc] at h1
      exact absurd h1 (by decide)
    rw [h1, (C2_eq_one_or (psi g)).resolve_left h2]

/-- **The character attached to a subgroup of index two**: the quotient by an index-two
subgroup is a group of order two, hence a copy of `C₂`. -/
noncomputable def charOfIndexTwo {H : Subgroup K} (h : H.index = 2) : K →* C2 :=
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  haveI : H.Normal := Subgroup.normal_of_index_eq_two h
  (mulEquivOfPrimeCardEq (G := K ⧸ H) (G' := C2) (p := 2)
      (by rw [← Subgroup.index_eq_card]; exact h) card_C2).toMonoidHom.comp
    (QuotientGroup.mk' H)

/-- The character of an index-two subgroup has that subgroup as its kernel. -/
theorem ker_charOfIndexTwo {H : Subgroup K} (h : H.index = 2) :
    (charOfIndexTwo h).ker = H := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  haveI : H.Normal := Subgroup.normal_of_index_eq_two h
  set e := mulEquivOfPrimeCardEq (G := K ⧸ H) (G' := C2) (p := 2)
      (by rw [← Subgroup.index_eq_card]; exact h) card_C2 with he
  ext g
  constructor
  · intro hg
    have hg' : e (QuotientGroup.mk' H g) = 1 := hg
    have : (QuotientGroup.mk' H) g = 1 := by
      have := (MulEquiv.map_eq_one_iff e).mp hg'
      exact this
    exact (QuotientGroup.eq_one_iff g).mp this
  · intro hg
    show e (QuotientGroup.mk' H g) = 1
    have : (QuotientGroup.mk' H) g = 1 := (QuotientGroup.eq_one_iff g).mpr hg
    rw [this, map_one]

theorem charOfIndexTwo_ne_one {H : Subgroup K} (h : H.index = 2) :
    charOfIndexTwo h ≠ 1 := by
  intro hc
  have hker : (charOfIndexTwo h).ker = ⊤ := by rw [hc]; exact MonoidHom.ker_one
  rw [ker_charOfIndexTwo] at hker
  rw [hker, Subgroup.index_top] at h
  exact absurd h (by decide)

/-- **Nontrivial mod-two characters are exactly the subgroups of index two.** -/
noncomputable def indexTwoEquivNontrivialChar :
    {phi : K →* C2 // phi ≠ 1} ≃ {H : Subgroup K // H.index = 2} where
  toFun p := ⟨p.1.ker, index_ker_of_ne_one p.2⟩
  invFun H := ⟨charOfIndexTwo H.2, charOfIndexTwo_ne_one H.2⟩
  left_inv p := by
    apply Subtype.ext
    exact char_eq_of_ker_eq (ker_charOfIndexTwo (index_ker_of_ne_one p.2))
  right_inv H := by
    apply Subtype.ext
    exact ker_charOfIndexTwo H.2

/-- **Isomorphism classes of connected double coverings of a `K(G,1)` are exactly the
nonzero mod-two characters of `G`.**  The bijection is "take the subgroup of the covering",
and it is well defined on isomorphism classes because index-two subgroups are normal, so
that isomorphism of double coverings is plain equality of subgroups. -/
theorem doubleCoverings_equiv_nontrivial_characters :
    Nonempty ({phi : K →* C2 // phi ≠ 1} ≃ {H : Subgroup K // H.index = 2}) ∧
      ∀ H L : Subgroup K, H.index = 2 →
        (Nonempty (GEquiv K (K ⧸ H) (K ⧸ L)) ↔ H = L) :=
  ⟨⟨indexTwoEquivNontrivialChar⟩, fun _ _ hH =>
    (index_two_gEquiv_iff_eq hH).trans eq_comm⟩

end Characters

end FundamentalGroupCovering