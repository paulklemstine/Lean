/-
# Fibre products of coverings of a `K(G,1)` and double cosets

This file continues the covering-space thread of the catalog
(`Bridges/FundamentalGroupCoveringGalois.lean`,
`Bridges/FundamentalGroupCoveringDeck.lean`,
`Bridges/FundamentalGroupCoveringExamples.lean`).

Given two connected coverings of a `K(G,1)`, classified by subgroups `H` and `K` of
`G = π₁`, their fibre product over the base is the `G`-set `(G ⧸ H) × (G ⧸ K)` with the
diagonal monodromy.  This covering is usually disconnected, and the classical answer
(Mackey's double coset formula) is:

* its connected components are indexed by the double cosets `H \ G / K`
  (`dosetEquivOrbits`), and
* the component through `(1·H, g·K)` is the connected covering classified by
  `H ∩ gKg⁻¹` (`stabilizer_prod_point`).

Consequently the fibre product is connected exactly when `G = H·K`
(`prod_isPretransitive_iff`), and taking `K = H` recovers the fact that a covering is
regular exactly when `H` is normal, from the deck-transformation side.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringDeck

open CategoryTheory MulAction

namespace FundamentalGroupCovering

universe u

section FibreProduct

variable {G : Type u} [Group G] (H K : Subgroup G)

/-- The stabiliser of a point of a product `G`-set is the intersection of the
stabilisers: the fundamental group of a fibre product is the intersection of the two
fundamental groups. -/
theorem stabilizer_prod {X Y : Type u} [MulAction G X] [MulAction G Y] (x : X) (y : Y) :
    stabilizer G ((x, y)) = stabilizer G x ⊓ stabilizer G y := by
  ext g
  constructor
  · intro hg
    have hg' : (g • x, g • y) = (x, y) := hg
    exact ⟨congrArg Prod.fst hg', congrArg Prod.snd hg'⟩
  · rintro ⟨h1, h2⟩
    have h1' : g • x = x := h1
    have h2' : g • y = y := h2
    show (g • x, g • y) = (x, y)
    rw [h1', h2']

/-- **The fundamental group of the component of the fibre product through `(1·H, g·K)`
is `H ∩ gKg⁻¹`.** -/
theorem stabilizer_prod_point (g : G) :
    stabilizer G ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K)))
      = H ⊓ K.map (MulAut.conj g).toMonoidHom := by
  rw [stabilizer_prod, MulAction.stabilizer_quotient]
  congr 1
  have hg : (((g : G) : G ⧸ K)) = g • (((1 : G) : G ⧸ K)) := by
    show (((g : G) : G ⧸ K)) = (((g * 1 : G) : G ⧸ K))
    rw [mul_one]
  rw [hg, stabilizer_smul_eq_stabilizer_map_conj, MulAction.stabilizer_quotient]

/-- Every point of the fibre product lies in the orbit of a normalised point
`(1·H, g·K)`. -/
theorem exists_normalised_rep (p : (G ⧸ H) × (G ⧸ K)) :
    ∃ g : G, (Quotient.mk (orbitRel G ((G ⧸ H) × (G ⧸ K))) p)
      = Quotient.mk _ ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K))) := by
  obtain ⟨p₁, p₂⟩ := p
  refine QuotientGroup.induction_on p₁ ?_
  intro a
  refine QuotientGroup.induction_on p₂ ?_
  intro b
  refine ⟨a⁻¹ * b, ?_⟩
  apply Quotient.sound
  show ((a : G ⧸ H), (b : G ⧸ K)) ∈ orbit G ((((1 : G) : G ⧸ H)), (((a⁻¹ * b : G) : G ⧸ K)))
  refine ⟨a, ?_⟩
  show (a • (((1 : G) : G ⧸ H)), a • (((a⁻¹ * b : G) : G ⧸ K))) = ((a : G ⧸ H), (b : G ⧸ K))
  have h1 : a • (((1 : G) : G ⧸ H)) = ((a : G) : G ⧸ H) := by
    show (((a * 1 : G) : G ⧸ H)) = ((a : G) : G ⧸ H)
    rw [mul_one]
  have h2 : a • (((a⁻¹ * b : G) : G ⧸ K)) = ((b : G) : G ⧸ K) := by
    show (((a * (a⁻¹ * b) : G) : G ⧸ K)) = ((b : G) : G ⧸ K)
    rw [← mul_assoc, mul_inv_cancel, one_mul]
  rw [h1, h2]

/-- Two normalised points of the fibre product are in the same orbit exactly when the
corresponding group elements lie in the same double coset. -/
theorem orbit_eq_iff_doubleCoset (g g' : G) :
    (Quotient.mk (orbitRel G ((G ⧸ H) × (G ⧸ K))) ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K))))
        = Quotient.mk _ ((((1 : G) : G ⧸ H)), (((g' : G) : G ⧸ K)))
      ↔ DoubleCoset.mk H K g = DoubleCoset.mk H K g' := by
  rw [DoubleCoset.eq]
  constructor
  · intro hq
    have hmem : ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K)))
        ∈ orbit G ((((1 : G) : G ⧸ H)), (((g' : G) : G ⧸ K))) := Quotient.exact hq
    obtain ⟨t, ht⟩ := hmem
    have ht1 : ((t : G) : G ⧸ H) = (((1 : G) : G ⧸ H)) := by
      have := congrArg Prod.fst ht
      show ((t : G) : G ⧸ H) = _
      calc ((t : G) : G ⧸ H) = (((t * 1 : G)) : G ⧸ H) := by rw [mul_one]
        _ = t • (((1 : G) : G ⧸ H)) := rfl
        _ = (((1 : G) : G ⧸ H)) := this
    have ht2 : (((t * g' : G)) : G ⧸ K) = ((g : G) : G ⧸ K) := congrArg Prod.snd ht
    have htH : t ∈ H := by
      have := QuotientGroup.eq.mp ht1
      simpa using this
    have hk : (t * g')⁻¹ * g ∈ K := QuotientGroup.eq.mp ht2
    refine ⟨t⁻¹, inv_mem htH, ((t * g')⁻¹ * g)⁻¹, inv_mem hk, ?_⟩
    group
  · rintro ⟨h, hh, k, hk, rfl⟩
    apply Quotient.sound
    show ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K)))
      ∈ orbit G ((((1 : G) : G ⧸ H)), (((h * g * k : G) : G ⧸ K)))
    refine ⟨h⁻¹, ?_⟩
    show (h⁻¹ • (((1 : G) : G ⧸ H)), h⁻¹ • (((h * g * k : G) : G ⧸ K)))
      = ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K)))
    have e1 : h⁻¹ • (((1 : G) : G ⧸ H)) = (((1 : G) : G ⧸ H)) := by
      show (((h⁻¹ * 1 : G) : G ⧸ H)) = (((1 : G) : G ⧸ H))
      refine QuotientGroup.eq.mpr ?_
      have hrw : (h⁻¹ * 1)⁻¹ * (1 : G) = h := by group
      rw [hrw]
      exact hh
    have e2 : h⁻¹ • (((h * g * k : G) : G ⧸ K)) = ((g : G) : G ⧸ K) := by
      show (((h⁻¹ * (h * g * k) : G) : G ⧸ K)) = ((g : G) : G ⧸ K)
      refine QuotientGroup.eq.mpr ?_
      have hrw : (h⁻¹ * (h * g * k))⁻¹ * g = k⁻¹ := by group
      rw [hrw]
      exact inv_mem hk
    rw [e1, e2]

/-- The map from double cosets to components of the fibre product. -/
def dosetToOrbit :
    DoubleCoset.Quotient (H : Set G) K → orbitRel.Quotient G ((G ⧸ H) × (G ⧸ K)) :=
  Quotient.lift
    (fun g => Quotient.mk (orbitRel G ((G ⧸ H) × (G ⧸ K)))
      ((((1 : G) : G ⧸ H)), (((g : G) : G ⧸ K))))
    (by
      intro g g' hgg'
      have : DoubleCoset.mk H K g = DoubleCoset.mk H K g' := Quotient.sound hgg'
      exact (orbit_eq_iff_doubleCoset H K g g').mpr this)

/-- **Mackey's double coset formula for coverings.**  The connected components of the
fibre product of the coverings classified by `H` and `K` are in bijection with the
double cosets `H \ G / K`. -/
noncomputable def dosetEquivOrbits :
    DoubleCoset.Quotient (H : Set G) K ≃ orbitRel.Quotient G ((G ⧸ H) × (G ⧸ K)) :=
  Equiv.ofBijective (dosetToOrbit H K) (by
    constructor
    · intro q q' hq
      refine Quotient.inductionOn q ?_ hq
      intro g hg
      refine Quotient.inductionOn q' ?_ hg
      intro g' hg'
      exact (orbit_eq_iff_doubleCoset H K g g').mp hg'
    · intro c
      refine Quotient.inductionOn c ?_
      intro p
      obtain ⟨g, hg⟩ := exists_normalised_rep H K p
      exact ⟨DoubleCoset.mk H K g, hg.symm⟩)

/-- **The fibre product of two connected coverings is connected exactly when the two
subgroups factor the fundamental group**, `G = H · K`. -/
theorem prod_isPretransitive_iff :
    IsPretransitive G ((G ⧸ H) × (G ⧸ K)) ↔ ∀ x : G, ∃ h ∈ H, ∃ k ∈ K, x = h * k := by
  constructor
  · intro htr x
    have hx : (Quotient.mk (orbitRel G ((G ⧸ H) × (G ⧸ K)))
        ((((1 : G) : G ⧸ H)), (((x : G) : G ⧸ K))))
        = Quotient.mk _ ((((1 : G) : G ⧸ H)), (((1 : G) : G ⧸ K))) := by
      apply Quotient.sound
      exact htr.exists_smul_eq _ _
    have hdc := (orbit_eq_iff_doubleCoset H K x 1).mp hx
    obtain ⟨h, hh, k, hk, hx'⟩ := (DoubleCoset.eq H K x 1).mp hdc
    refine ⟨h⁻¹, inv_mem hh, k⁻¹, inv_mem hk, ?_⟩
    have h2 : h * x * k = 1 := hx'.symm
    have h3 : x = h⁻¹ * (h * x * k) * k⁻¹ := by group
    rw [h2] at h3
    simpa using h3
  · intro hfac
    refine ⟨fun p q => ?_⟩
    obtain ⟨g, hg⟩ := exists_normalised_rep H K p
    obtain ⟨g', hg'⟩ := exists_normalised_rep H K q
    have hone : ∀ x : G, DoubleCoset.mk H K (1 : G) = DoubleCoset.mk H K x := by
      intro x
      obtain ⟨h, hh, k, hk, hx⟩ := hfac x
      refine (DoubleCoset.eq H K 1 x).mpr ⟨h, hh, k, hk, ?_⟩
      rw [hx, mul_one]
    have hdc : DoubleCoset.mk H K g = DoubleCoset.mk H K g' := (hone g).symm.trans (hone g')
    have hiff := (orbit_eq_iff_doubleCoset H K g g').mpr hdc
    have hpq : (Quotient.mk (orbitRel G ((G ⧸ H) × (G ⧸ K))) q) = Quotient.mk _ p := by
      rw [hg, hg', hiff]
    exact Quotient.exact hpq

end FibreProduct

end FundamentalGroupCovering