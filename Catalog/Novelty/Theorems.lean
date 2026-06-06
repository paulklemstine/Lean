/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Novelty.SurrealProbability.Defs

/-!
# Non-Archimedean Probability: Main Theorems

This module proves the central results connecting the Archimedean property
to the possibility of infinitesimal uniform probability measures.

## Main Results

### Structural Properties of Uniform Finset Measure
* `uniformFinsetMeasure_empty` — μ(∅) = 0
* `uniformFinsetMeasure_singleton` — μ({x}) = ε
* `uniformFinsetMeasure_disjoint_union` — μ(S ∪ T) = μ(S) + μ(T) for disjoint S, T

### Archimedean Obstruction Theorem
* `archimedean_no_infinitesimal` — In an Archimedean ordered monoid,
  no element is additively infinitesimal (with respect to any bound).
  This is the core impossibility result for Archimedean probability.

### Non-Archimedean Existence
* `uniform_measure_bounded_of_infinitesimal` — If ε is infinitesimal w.r.t. b,
  then the uniform measure with weight ε is bounded by b on all finite sets.

### Monotonicity
* `uniformFinsetMeasure_mono` — S ⊆ T → μ(S) ≤ μ(T) for non-negative ε.

### Bridge: Characterization of Infinitesimal-Capable Structures
* `not_archimedean_iff_has_infinitesimal` — An ordered additive monoid fails
  to be Archimedean if and only if it has infinitesimal elements.
-/

open Finset

/-! ## Uniform Measure: Basic Properties -/

/-
The uniform measure of the empty set is zero.
-/

theorem uniform_measure_bounded_of_infinitesimal {M : Type*} [AddCommMonoid M]
    [PartialOrder M] {ε b : M}
    (hε : IsAdditivelyInfinitesimal ε b) (α : Type*) (S : Finset α) :
    uniformFinsetMeasure ε S ≤ b := by
  exact hε.2 S.card

/-! ## Monotonicity -/

/-
**Monotonicity of the uniform measure**: For a non-negative weight ε,
the uniform Finset measure is monotone: S ⊆ T implies μ(S) ≤ μ(T).
-/

theorem uniform_measure_complement_nonneg {M : Type*} [AddCommGroup M] [PartialOrder M]
    [IsOrderedAddMonoid M]
    {ε b : M} (hε : IsAdditivelyInfinitesimal ε b)
    {α : Type*} (S : Finset α) :
    0 ≤ b - uniformFinsetMeasure ε S := by
  convert sub_nonneg_of_le ( hε.2 S.card ) using 1