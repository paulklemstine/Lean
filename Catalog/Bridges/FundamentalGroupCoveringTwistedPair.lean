/-
# A universal source of coverings that π₁ cannot distinguish

The Klein four group example of `FundamentalGroupCoveringExamples` exhibits *one* pair of
double coverings with homotopy equivalent total spaces that are not isomorphic as
coverings.  This file shows that the phenomenon is not an accident of that small group:
it happens for **every** group `G` that admits a surjection onto `C₂`, and it happens over
non-abelian bases as well.

Given a surjection `φ : G →* C₂`, work over the base `K(G × C₂, 1)`.  Inside `G × C₂`
there are two natural subgroups of index two:

* the *untwisted* one `NBase = ker (pr₂)`, i.e. `G × 1`;
* the *twisted* one `NTwist φ = ker ((φ ∘ pr₁) · pr₂)`, i.e. the graph `{(g, φ g)}`.

Both are isomorphic to `G` (`nbaseMulEquiv`, `ntwistMulEquiv`), so the two double
coverings they classify have *the same* total homotopy `1`-type, namely a `K(G,1)`
(`twistedPair_groupoid_equivalent`).  Both are normal, so — regardless of whether the base
is abelian — the two coverings are **not** isomorphic (`twistedPair_not_isomorphic`),
because index-two subgroups are normal and conjugation cannot move one onto the other.

Main results:

* `map_conj_eq_of_normal`, `index_two_gEquiv_iff_eq`: over *any* base, two double
  coverings are isomorphic exactly when their index-two subgroups coincide;
* `twistedPair_theorem`: for every `G` surjecting onto `C₂` the `K(G × C₂,1)` carries two
  distinct double coverings with equivalent total `1`-types;
* `s3_twistedPair`: the non-abelian instance `G = S₃`, giving two non-isomorphic double
  coverings of a `K(S₃ × C₂,1)`, both with total space a `K(S₃,1)`.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringExactSequence
import Bridges.FundamentalGroupCompleteInvariant

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

/-! ## Double coverings over an arbitrary base -/

section General

variable {K : Type u} [Group K]

/-- Conjugation fixes a normal subgroup. -/
theorem map_conj_eq_of_normal (H : Subgroup K) [H.Normal] (g : K) :
    H.map (MulAut.conj g).toMonoidHom = H := by
  ext x
  constructor
  · rintro ⟨h, hh, rfl⟩
    exact Subgroup.Normal.conj_mem ‹H.Normal› h hh g
  · intro hx
    refine ⟨g⁻¹ * x * g, ?_, ?_⟩
    · simpa using Subgroup.Normal.conj_mem ‹H.Normal› x hx g⁻¹
    · show g * (g⁻¹ * x * g) * g⁻¹ = x
      group

/-- **Over any base, two double coverings are isomorphic exactly when their index-two
subgroups are equal.**  Index-two subgroups are normal, so conjugation — the only freedom
in the Galois correspondence — acts trivially on them. -/
theorem index_two_gEquiv_iff_eq {H L : Subgroup K} (hH : H.index = 2) :
    Nonempty (GEquiv K (K ⧸ H) (K ⧸ L)) ↔ L = H := by
  haveI : H.Normal := Subgroup.normal_of_index_eq_two hH
  rw [quotient_coverings_iso_iff_conj]
  constructor
  · rintro ⟨g, rfl⟩
    exact map_conj_eq_of_normal H g
  · intro h
    exact ⟨1, by rw [h, map_conj_eq_of_normal]⟩

/-- The fundamental group of the covering classified by `H` is `H` itself. -/
noncomputable def autQuotientMulEquiv (H : Subgroup K) :
    Aut (ActionCategory.objEquiv K (K ⧸ H) (((1 : K) : K ⧸ H))) ≃* H :=
  (autMulEquivStabilizer (((1 : K) : K ⧸ H))).trans
    (MulEquiv.subgroupCongr (MulAction.stabilizer_quotient H))

/-- If the two subgroups are abstractly isomorphic, the two coverings have equivalent
total `1`-types: the fundamental group of the total space cannot separate them. -/
theorem quotient_coverings_groupoid_equivalent {H L : Subgroup K} (e : H ≃* L) :
    Nonempty (ActionCategory K (K ⧸ H) ≌ ActionCategory K (K ⧸ L)) :=
  FundamentalGroupCompleteInvariant.connectedGroupoids_equivalent_of_aut_mulEquiv
    (ActionCategory.objEquiv K (K ⧸ H) (((1 : K) : K ⧸ H)))
    (ActionCategory.objEquiv K (K ⧸ L) (((1 : K) : K ⧸ L)))
    (connectedAt_actionCategory _) (connectedAt_actionCategory _)
    (((autQuotientMulEquiv H).trans e).trans (autQuotientMulEquiv L).symm)

/-- A subgroup that is the kernel of a surjection onto `C₂` has index two. -/
theorem index_ker_eq_two {f : K →* C2} (hf : Function.Surjective f) : f.ker.index = 2 := by
  rw [Subgroup.index_ker, MonoidHom.range_eq_top.mpr hf, Subgroup.card_top, card_C2]

end General

/-! ## The twisted pair attached to a surjection onto `C₂` -/

section TwistedPair

variable {G : Type u} [Group G] (phi : G →* C2)

theorem C2_mul_self (a : C2) : a * a = 1 := by
  revert a; decide

theorem C2_inv_eq (a : C2) : a⁻¹ = a := by
  revert a; decide

/-- The untwisted index-two subgroup `G × 1` of `G × C₂`. -/
def NBase (G : Type u) [Group G] : Subgroup (G × C2) := (MonoidHom.snd G C2).ker

/-- The homomorphism `(g, c) ↦ φ g · c`. -/
def twistHom : (G × C2) →* C2 :=
  (phi.comp (MonoidHom.fst G C2)) * (MonoidHom.snd G C2)

/-- The twisted index-two subgroup, the graph `{(g, φ g)}` of `φ`. -/
def NTwist : Subgroup (G × C2) := (twistHom phi).ker

theorem mem_NBase (x : G × C2) : x ∈ NBase G ↔ x.2 = 1 := Iff.rfl

theorem mem_NTwist (x : G × C2) : x ∈ NTwist phi ↔ phi x.1 * x.2 = 1 := Iff.rfl

theorem snd_surjective : Function.Surjective (MonoidHom.snd G C2) :=
  fun c => ⟨(1, c), rfl⟩

theorem twistHom_surjective : Function.Surjective (twistHom phi) :=
  fun c => ⟨(1, c), by simp [twistHom]⟩

theorem index_NBase : (NBase G).index = 2 := index_ker_eq_two snd_surjective

theorem index_NTwist : (NTwist phi).index = 2 := index_ker_eq_two (twistHom_surjective phi)

/-- The untwisted subgroup is a copy of `G`. -/
def nbaseMulEquiv : G ≃* NBase G where
  toFun g := ⟨(g, 1), rfl⟩
  invFun x := (x : G × C2).1
  left_inv _ := rfl
  right_inv := by
    rintro ⟨⟨g, c⟩, hc⟩
    have : c = 1 := hc
    subst this
    rfl
  map_mul' _ _ := rfl

/-- The twisted subgroup is also a copy of `G`, via `g ↦ (g, φ g)`. -/
def ntwistMulEquiv : G ≃* NTwist phi where
  toFun g := ⟨(g, phi g), by
    show phi g * phi g = 1
    exact C2_mul_self _⟩
  invFun x := (x : G × C2).1
  left_inv _ := rfl
  right_inv := by
    rintro ⟨⟨g, c⟩, hc⟩
    have hc' : phi g * c = 1 := hc
    have : c = phi g := by
      have := eq_inv_of_mul_eq_one_right hc'
      rw [this, C2_inv_eq]
    subst this
    rfl
  map_mul' a b := by
    apply Subtype.ext
    show ((a * b, phi (a * b)) : G × C2) = (a * b, phi a * phi b)
    rw [map_mul]

/-- The two subgroups are different as soon as `φ` is onto. -/
theorem NBase_ne_NTwist (hphi : Function.Surjective phi) : NBase G ≠ NTwist phi := by
  obtain ⟨g, hg⟩ := hphi (Multiplicative.ofAdd (1 : ZMod 2))
  intro h
  have hmem : ((g, 1) : G × C2) ∈ NBase G := rfl
  rw [h, mem_NTwist] at hmem
  simp only [mul_one] at hmem
  rw [hg] at hmem
  exact absurd hmem (by decide)

/-- **The two double coverings are not isomorphic**, whatever the base. -/
theorem twistedPair_not_isomorphic (hphi : Function.Surjective phi) :
    ¬ Nonempty (GEquiv (G × C2) ((G × C2) ⧸ NBase G) ((G × C2) ⧸ NTwist phi)) := by
  rw [index_two_gEquiv_iff_eq index_NBase]
  exact fun h => NBase_ne_NTwist phi hphi h.symm

/-- **...but their total spaces are both a `K(G,1)`**, hence homotopy equivalent. -/
theorem twistedPair_groupoid_equivalent :
    Nonempty (ActionCategory (G × C2) ((G × C2) ⧸ NBase G) ≌
      ActionCategory (G × C2) ((G × C2) ⧸ NTwist phi)) :=
  quotient_coverings_groupoid_equivalent
    ((nbaseMulEquiv (G := G)).symm.trans (ntwistMulEquiv phi))

/-- **The twisted pair theorem.**  For every group `G` admitting a surjection onto `C₂`,
the space `K(G × C₂, 1)` carries two connected double coverings whose total spaces are
both a `K(G,1)` — so they have isomorphic fundamental groups and the same number of
sheets — and which are nevertheless non-isomorphic as coverings.  Failure of π₁ to
classify coverings is therefore ubiquitous, not exceptional. -/
theorem twistedPair_theorem (hphi : Function.Surjective phi) :
    (NBase G).index = 2 ∧ (NTwist phi).index = 2 ∧
      Nonempty (↥(NBase G) ≃* G) ∧ Nonempty (↥(NTwist phi) ≃* G) ∧
      Nonempty (ActionCategory (G × C2) ((G × C2) ⧸ NBase G) ≌
        ActionCategory (G × C2) ((G × C2) ⧸ NTwist phi)) ∧
      ¬ Nonempty (GEquiv (G × C2) ((G × C2) ⧸ NBase G) ((G × C2) ⧸ NTwist phi)) :=
  ⟨index_NBase, index_NTwist phi, ⟨(nbaseMulEquiv (G := G)).symm⟩,
    ⟨(ntwistMulEquiv phi).symm⟩, twistedPair_groupoid_equivalent phi,
    twistedPair_not_isomorphic phi hphi⟩

end TwistedPair

/-! ## A non-abelian instance: the base `K(S₃ × C₂, 1)` -/

section S3Instance

/-- The sign character of `ℤˣ` with values in `C₂`. -/
def unitsToC2 : ℤˣ →* C2 where
  toFun u := if u = 1 then 1 else Multiplicative.ofAdd 1
  map_one' := by simp
  map_mul' := by decide

/-- The sign homomorphism `S₃ →* C₂`. -/
def signC2 : Equiv.Perm (Fin 3) →* C2 := unitsToC2.comp Equiv.Perm.sign

theorem signC2_surjective : Function.Surjective signC2 := by decide

/-- **A non-abelian instance of the twisted pair.**  Over the base `K(S₃ × C₂, 1)` there
are two distinct double coverings, both with total space a `K(S₃,1)`, which are not
isomorphic as coverings.  Since `S₃` is non-abelian, this is genuinely outside the reach
of the Klein four group example. -/
theorem s3_twistedPair :
    (NBase (Equiv.Perm (Fin 3))).index = 2 ∧ (NTwist signC2).index = 2 ∧
      Nonempty (ActionCategory (Equiv.Perm (Fin 3) × C2)
          ((Equiv.Perm (Fin 3) × C2) ⧸ NBase (Equiv.Perm (Fin 3))) ≌
        ActionCategory (Equiv.Perm (Fin 3) × C2)
          ((Equiv.Perm (Fin 3) × C2) ⧸ NTwist signC2)) ∧
      ¬ Nonempty (GEquiv (Equiv.Perm (Fin 3) × C2)
        ((Equiv.Perm (Fin 3) × C2) ⧸ NBase (Equiv.Perm (Fin 3)))
        ((Equiv.Perm (Fin 3) × C2) ⧸ NTwist signC2)) := by
  obtain ⟨h1, h2, _, _, h5, h6⟩ := twistedPair_theorem signC2 signC2_surjective
  exact ⟨h1, h2, h5, h6⟩

end S3Instance

end FundamentalGroupCovering