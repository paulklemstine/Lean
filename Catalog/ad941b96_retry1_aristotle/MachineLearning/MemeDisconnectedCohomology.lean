/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import MachineLearning.MemeGraphCohomology

/-!
# Sheaf cohomology of meme propagation — the disconnected computation

Building on `MemeGraphCohomology.lean`, this file computes the dimensions of the two
cohomology groups of the constant sheaf on an **arbitrary** finite graph `G` (the social
network), *without* any connectivity assumption.

Write `q : V → Quotient (compSetoid src tgt)` for the map sending each person to their
connected component.  Pulling a function back along `q` gives the linear map
`LinearMap.funLeft K K q : (Quotient → K) →ₗ[K] (V → K)`, whose image is exactly the space
of interpretations that are constant on each component.

## Main results

* `MemeGraph.range_funLeft_eq_ker` — the image of the component-pullback map is exactly
  `H⁰ = ker δ`: an interpretation is globally consistent iff it is constant on each
  connected component.
* `MemeGraph.graph_dimH0_components` — **`dim H⁰ = #components(G)`**.
* `MemeGraph.graph_euler_components` — **`dim H¹ = |E| − |V| + #components(G)`**.

The last statement is the first Betti number of the graph: the number of independent
communication cycles across the whole network.
-/

namespace MemeGraph

open Module

variable {K : Type*} [Field K]
variable {V E : Type*} [Fintype V] [Fintype E] [DecidableEq V]

/-- The component-pullback map `(Quotient → K) →ₗ[K] (V → K)`, precomposition with the map
`q : V → Quotient (compSetoid src tgt)` sending a person to their connected component. -/
noncomputable def compPullback (src tgt : E → V) :
    (Quotient (compSetoid src tgt) → K) →ₗ[K] (V → K) :=
  LinearMap.funLeft K K (Quotient.mk (compSetoid src tgt))

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- **The image of the component-pullback map is exactly `H⁰`.**  An interpretation is
globally consistent (a section of the constant sheaf) precisely when it is constant on
each connected component of the social network. -/
theorem range_funLeft_eq_ker (src tgt : E → V) :
    LinearMap.range (compPullback (K := K) src tgt) = H0 (K := K) src tgt := by
  ext f
  constructor
  · rintro ⟨g, rfl⟩
    rw [mem_H0_iff]
    intro e
    -- `src e` and `tgt e` lie in the same component, so `g` agrees on their classes.
    show g (Quotient.mk _ (src e)) = g (Quotient.mk _ (tgt e))
    have h : (compSetoid src tgt).r (src e) (tgt e) :=
      Relation.ReflTransGen.single ⟨e, Or.inl ⟨rfl, rfl⟩⟩
    exact congrArg g (Quotient.sound h)
  · intro hf
    -- `f` is constant on components, so it factors through the quotient.
    refine ⟨Quotient.lift f (fun a b hab => H0_eq_of_reachable src tgt hf hab), ?_⟩
    funext v
    rfl

omit [Fintype E] [DecidableEq V] in
/-- **`dim H⁰ = #components(G)`.**  The number of globally consistent meme
interpretations equals the number of connected communities in the network. -/
theorem graph_dimH0_components (src tgt : E → V) :
    finrank K (H0 (K := K) src tgt) = components src tgt := by
  classical
  have hfin : Finite (Quotient (compSetoid src tgt)) := Quotient.finite _
  have : Fintype (Quotient (compSetoid src tgt)) := Fintype.ofFinite _
  -- `H⁰` is the injective image of `(Quotient → K)`, so they have equal dimension.
  rw [← range_funLeft_eq_ker]
  unfold compPullback
  rw [LinearMap.finrank_range_of_inj
    (LinearMap.funLeft_injective_of_surjective K K _ (Quotient.mk_surjective))]
  rw [Module.finrank_fintype_fun_eq_card]
  rw [components, Nat.card_eq_fintype_card]

omit [DecidableEq V] in
/-- **`dim H¹ = |E| − |V| + #components(G)`.**  The dimension of the obstruction space is
the first Betti number of the network: the number of independent communication cycles. -/
theorem graph_euler_components (src tgt : E → V) :
    (finrank K (H1 (K := K) src tgt) : ℤ)
      = (Fintype.card E : ℤ) - Fintype.card V + components src tgt := by
  have he := euler_characteristic (K := K) src tgt
  have h0 := graph_dimH0_components (K := K) src tgt
  rw [h0] at he
  omega

end MemeGraph