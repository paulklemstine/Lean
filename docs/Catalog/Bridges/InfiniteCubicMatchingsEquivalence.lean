/-
# The finite and the infinite Berge–Fulkerson conjectures are equivalent

The paper's headline claim is that the *finite* versions of the Berge–Fulkerson, Fan–Raspaud
and Máčajová–Škoviera conjectures are equivalent to their *infinite* versions.  One direction
is trivial (a finite graph is a graph); the substance is the converse, which is a compactness
argument fed by *finite local models*.

This file isolates the class of graphs for which the argument goes through,

  `HasFiniteLocalModels G` : around every finite set of vertices, `G` looks locally exactly
  like some finite cubic bridgeless graph,

and proves the equivalence

  `finiteBergeFulkerson_iff` :
      FiniteBergeFulkersonConjecture
        ↔ every locally finite graph without isolated vertices that has finite local models
          satisfies Berge–Fulkerson.

The forward implication is the compactness transfer `bergeFulkerson_of_finite_local_models`;
the backward implication uses `hasFiniteLocalModels_self`, i.e. a finite cubic bridgeless
graph is its own local model.  The class is genuinely larger than the finite graphs:
`hasFiniteLocalModels_of_covering` shows that every covering of a finite cubic bridgeless
graph — for instance the infinite ℤ-voltage lifts of `InfiniteCubicMatchingsPetersenLift` and
the Cayley graphs of `InfiniteCubicMatchingsCayley` — belongs to it.
-/
import Bridges.InfiniteCubicMatchingsCovers

namespace Bridges.InfiniteCubicMatchings

universe u

variable {V : Type u} {G : SimpleGraph V}

/-- `G` *has finite local models* if around every finite set of vertices it is locally
isomorphic to a finite cubic bridgeless graph. -/
def HasFiniteLocalModels (G : SimpleGraph V) : Prop :=
  ∀ T : Finset V, ∃ (W : Type) (_ : Fintype W) (K : SimpleGraph W) (φ : V → W),
    IsCubic K ∧ Bridgeless K ∧ ∀ v ∈ T, IsLocalIsoAt G K φ v

/-- The identity is a local isomorphism at every vertex. -/
theorem isLocalIsoAt_id (G : SimpleGraph V) (v : V) : IsLocalIsoAt G G id v where
  adj := fun _ h => h
  inj := fun _ _ _ _ h => h
  surj := fun y h => ⟨y, h, rfl⟩

/-- A finite cubic bridgeless graph is its own finite local model. -/
theorem hasFiniteLocalModels_self {W : Type} [Fintype W] (K : SimpleGraph W) (hc : IsCubic K)
    (hb : Bridgeless K) : HasFiniteLocalModels K :=
  fun _ => ⟨W, inferInstance, K, id, hc, hb, fun v _ => isLocalIsoAt_id K v⟩

/-- Any covering of a finite cubic bridgeless graph has finite local models. -/
theorem hasFiniteLocalModels_of_covering {W : Type} [Fintype W] {K : SimpleGraph W}
    (φ : V → W) (hcov : ∀ v, IsLocalIsoAt G K φ v) (hc : IsCubic K) (hb : Bridgeless K) :
    HasFiniteLocalModels G :=
  fun _ => ⟨W, inferInstance, K, φ, hc, hb, fun v _ => hcov v⟩

/-- In a cubic graph no vertex is isolated. -/
theorem neighborSet_nonempty_of_isCubic (hc : IsCubic G) (v : V) :
    (G.neighborSet v).Nonempty := by
  rw [Set.nonempty_iff_ne_empty]
  intro h
  have h3 := hc v
  rw [h, Set.ncard_empty] at h3
  exact absurd h3 (by norm_num)

/-- **The finite Berge–Fulkerson conjecture is equivalent to its infinite version** on the
class of locally finite graphs without isolated vertices that admit finite cubic bridgeless
local models.

`←` is immediate because a finite cubic bridgeless graph is its own local model; `→` is the
compactness transfer. -/
theorem finiteBergeFulkerson_iff :
    FiniteBergeFulkersonConjecture ↔
      ∀ (V : Type) (G : SimpleGraph V), (∀ v : V, (G.neighborSet v).Finite) →
        (∀ v : V, (G.neighborSet v).Nonempty) → HasFiniteLocalModels G → BergeFulkerson G := by
  constructor
  · intro hBF V G hlf hne hmod
    exact bergeFulkerson_of_finite_local_models hlf hne hBF hmod
  · intro h W hW K hc hb
    haveI := hW
    exact h W K (fun _ => Set.toFinite _) (neighborSet_nonempty_of_isCubic hc)
      (hasFiniteLocalModels_self K hc hb)

/-- **The finite Fan–Raspaud conjecture is equivalent to its infinite version** on the same
class of graphs. -/
theorem finiteFanRaspaud_iff :
    FiniteFanRaspaudConjecture ↔
      ∀ (V : Type) (G : SimpleGraph V), (∀ v : V, (G.neighborSet v).Finite) →
        (∀ v : V, (G.neighborSet v).Nonempty) → HasFiniteLocalModels G → FanRaspaud G := by
  constructor
  · intro hFR V G hlf hne hmod
    exact fanRaspaud_of_finite_local_models hlf hne hFR hmod
  · intro h W hW K hc hb
    haveI := hW
    exact h W K (fun _ => Set.toFinite _) (neighborSet_nonempty_of_isCubic hc)
      (hasFiniteLocalModels_self K hc hb)

/-- Máčajová–Škoviera for the same class, from the finite Fan–Raspaud conjecture. -/
theorem macajovaSkoviera_of_finiteFanRaspaud (hFR : FiniteFanRaspaudConjecture)
    (hlf : ∀ v : V, (G.neighborSet v).Finite) (hne : ∀ v : V, (G.neighborSet v).Nonempty)
    (hmod : HasFiniteLocalModels G) : MacajovaSkoviera G :=
  (fanRaspaud_of_finite_local_models hlf hne hFR hmod).macajovaSkoviera

end Bridges.InfiniteCubicMatchings