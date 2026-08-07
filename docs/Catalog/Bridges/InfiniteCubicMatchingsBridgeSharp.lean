/-
# Sharpness of the bridge dichotomy

`…BridgeParity.lean` proves that in a cubic graph satisfying any of the three properties every
bridge has two *infinite* sides, and `…Bridged.lean` produces `k4Chain`, an infinite cubic
graph with infinitely many bridges that nevertheless satisfies all three properties.  This file
puts the two together:

* `k4Chain_bridge_sides_infinite` : the bridges of `k4Chain` really do have two infinite sides
  — a corollary of the general theorem, so the general theorem is not vacuous on this example;
* `bridge_dichotomy` : the exact dichotomy for bridges of cubic graphs.  A bridge with a finite
  side kills all three properties, and this is the *only* obstruction a bridge can produce:
  there is an infinite cubic graph all of whose (infinitely many) bridges have two infinite
  sides and which satisfies all three properties.
-/
import Bridges.InfiniteCubicMatchingsBridged
import Bridges.InfiniteCubicMatchingsBridgeParity

namespace Bridges.InfiniteCubicMatchings

/-- Every bridge of the `K₄`-chain separates two infinite sides — as it must, since the chain
satisfies Berge–Fulkerson. -/
theorem k4Chain_bridge_sides_infinite (m : ℤ) :
    (bridgeSide k4Chain (m, (3 : Fin 4)) (m + 1, (0 : Fin 4))).Infinite ∧
      (bridgeSide k4Chain (m + 1, (0 : Fin 4)) (m, (3 : Fin 4))).Infinite :=
  bridge_sides_infinite_of_bergeFulkerson k4Chain_isCubic k4Chain_bergeFulkerson
    (k4Chain_isBridge m)

/-- **The bridge dichotomy for cubic graphs.**

1. A bridge with a *finite* side destroys all three properties (and its side is automatically
   of odd cardinality, by the half-edge count).
2. This is the only thing a bridge can do: there is an infinite cubic graph with infinitely
   many bridges — necessarily all with two infinite sides — satisfying all three properties.

So in the infinite setting the classical hypothesis "bridgeless" can be relaxed exactly to
"no bridge has a finite side". -/
theorem bridge_dichotomy :
    (∀ {V : Type} {G : SimpleGraph V} {u w : V}, IsCubic G → G.IsBridge s(u, w) →
        (bridgeSide G u w).Finite →
        ¬ BergeFulkerson G ∧ ¬ FanRaspaud G ∧ ¬ MacajovaSkoviera G) ∧
      (∃ (V : Type) (G : SimpleGraph V), IsCubic G ∧ {e | G.IsBridge e}.Infinite ∧
        (∀ u w : V, G.IsBridge s(u, w) → (bridgeSide G u w).Infinite) ∧
        BergeFulkerson G ∧ FanRaspaud G ∧ MacajovaSkoviera G) := by
  refine ⟨fun hG hbr hfin =>
    ⟨not_bergeFulkerson_of_bridge_with_finite_side hG hbr hfin,
     not_fanRaspaud_of_bridge_with_finite_side hG hbr hfin,
     not_macajovaSkoviera_of_bridge_with_finite_side hG hbr hfin⟩, ?_⟩
  refine ⟨ℤ × Fin 4, k4Chain, k4Chain_isCubic, k4Chain_bridges_infinite, ?_,
    k4Chain_bergeFulkerson, k4Chain_fanRaspaud, k4Chain_macajovaSkoviera⟩
  intro u w hbr
  exact (bridge_sides_infinite_of_bergeFulkerson k4Chain_isCubic k4Chain_bergeFulkerson hbr).1

end Bridges.InfiniteCubicMatchings