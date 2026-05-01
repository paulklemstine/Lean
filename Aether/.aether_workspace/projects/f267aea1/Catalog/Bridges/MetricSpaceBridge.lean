import Mathlib

/-! # Metric Space Bridge

Proves fundamental results about metric spaces:
1. Metric axioms: d(x,x) = 0, d(x,y) = d(y,x), triangle inequality
2. Complete metric spaces are Baire (Baire Category Theorem)
3. Distance non-negativity and identity of indiscernibles
-/

namespace MetricSpaceBridge

/-! ## Section 1: Metric Axioms -/

/-- Self-distance is zero: d(x, x) = 0. -/
theorem dist_self_eq_zero {X : Type*} [PseudoMetricSpace X] (x : X) :
    dist x x = 0 :=
  dist_self x

/-- Symmetry: d(x, y) = d(y, x). -/
theorem dist_symm {X : Type*} [PseudoMetricSpace X] (x y : X) :
    dist x y = dist y x :=
  dist_comm x y

/-- **Triangle inequality**: d(x, z) ≤ d(x, y) + d(y, z).
    THE most important inequality in all of analysis. -/
theorem triangle_inequality {X : Type*} [PseudoMetricSpace X] (x y z : X) :
    dist x z ≤ dist x y + dist y z :=
  dist_triangle x y z

/-! ## Section 2: Complete ⟹ Baire -/

/-- **Complete metric spaces are Baire** (Baire Category Theorem).
    Countable intersection of dense open sets in a complete metric space
    is dense. One of the deepest results in general topology. -/
theorem complete_metric_is_baire {X : Type*} [MetricSpace X] [CompleteSpace X] :
    BaireSpace X :=
  BaireSpace.of_completelyPseudoMetrizable

/-! ## Section 3: Distance Properties -/

/-- Distance is non-negative. -/
theorem dist_nonneg' {X : Type*} [PseudoMetricSpace X] {x y : X} :
    0 ≤ dist x y :=
  dist_nonneg

/-- In a metric space, d(x,y) = 0 implies x = y. -/
theorem dist_eq_zero_imp_eq {X : Type*} [MetricSpace X] {x y : X}
    (h : dist x y = 0) :
    x = y :=
  dist_eq_zero.mp h

end MetricSpaceBridge
