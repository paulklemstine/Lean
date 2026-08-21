import Novelty.BerggrenCausalSetPell

/-!
# The Berggren causal set: synthesis

A single place where the verdict of the five cycles is stated as three bundled theorems.

* `berggren_causal_set_axioms` — the Berggren tree satisfies the Bombelli–Lee–Meyer–Sorkin
  axioms: reflexivity, transitivity, antisymmetry, absence of closed causal curves and
  local finiteness.
* `berggren_lorentz_symmetry` — the model is Lorentzian: events are null vectors of
  `a² + b² − c²`, the moves act by integral Lorentz matrices, the action reproduces the
  tree, and the generated monoid is free of rank three.
* `berggren_not_minkowski_spacetime` — but it is *not* a discrete `2+1` Minkowski space:
  distinct events are always spacelike separated (so tree edges are not spacetime causal
  relations), interval volumes are exactly `k+1`, and consequently no Myrheim–Meyer
  dimension `≥ 2` exists.
-/

namespace BerggrenCausalSet

open scoped Matrix

/-- **The Berggren tree is a causal set.** -/
theorem berggren_causal_set_axioms :
    (∀ t : Event, Causal t t) ∧
    (∀ t u v : Event, Causal t u → Causal u v → Causal t v) ∧
    (∀ t u : Event, IsEvent t → Causal t u → Causal u t → t = u) ∧
    (∀ t : Event, IsEvent t → ∀ w : List BerggrenStep, w ≠ [] → run w t ≠ t) ∧
    (∀ t u : Event, IsEvent t → (causalInterval t u).Finite) :=
  ⟨causal_refl,
   fun _ _ _ h₁ h₂ => causal_trans h₁ h₂,
   fun _ _ ht h₁ h₂ => causal_antisymm ht h₁ h₂,
   fun _ ht _ hw => no_closed_causal_curve ht hw,
   fun _ _ ht => causalInterval_finite ht⟩

/-- **The model carries the Lorentz symmetry of `ℝ^{2,1}`.** -/
theorem berggren_lorentz_symmetry :
    (∀ t : Event, IsEvent t → lorentzQ t.1 t.2.1 t.2.2 = 0) ∧
    (∀ w : List BerggrenStep, (wordMat w)ᵀ * QLor * wordMat w = QLor) ∧
    (∀ (w : List BerggrenStep) (t : Event), (wordMat w).mulVec (vec t) = vec (run w t)) ∧
    Function.Injective wordMat :=
  ⟨fun _ h => event_null h, wordMat_lorentz, wordMat_action, wordMat_injective⟩

/-- **The Berggren causal set is not a discrete `2+1`-dimensional Minkowski space.** -/
theorem berggren_not_minkowski_spacetime :
    (∀ t u : Event, IsPrimEvent t → IsPrimEvent u → t ≠ u → 0 < mink t u) ∧
    (∀ k : ℕ, (causalInterval root (spine k)).ncard = k + 1) ∧
    (¬ ∃ rho : ℝ, 0 < rho ∧ ∀ k : ℕ,
      rho * (k : ℝ) ^ 2 ≤ ((causalInterval root (spine k)).ncard : ℝ)) :=
  ⟨fun _ _ ht hu hne => distinct_events_spacelike ht hu hne,
   interval_growth_linear,
   not_myrheim_meyer_dim_two⟩

end BerggrenCausalSet