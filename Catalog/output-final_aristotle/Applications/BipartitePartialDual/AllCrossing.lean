/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# All-crossing directions and even hyperedges

In the medial map `M(H)` of an orientable hypermap `H`, each hyperedge `e` of length `ℓ`
bounds a face traversed as a closed walk of length `ℓ`. An **all-crossing direction**
must assign the two "crossing states" so that they alternate around this boundary walk;
consistency around the face is therefore possible exactly when the boundary can be
properly `2`-coloured, i.e. exactly when the cycle of length `ℓ` is bipartite.

This file records the resulting parity dichotomy, which is the **nonemptiness criterion**
for the all-crossing side of the characterization in `Characterization.lean`:

* `allCrossingLocal_iff_even` — a single hyperedge of length `ℓ ≥ 3` admits a consistent
  all-crossing direction iff `ℓ` is even (modelled as `2`-colourability of `cycleGraph ℓ`).
* `allCrossing_global_iff_even` — the medial map admits an all-crossing direction iff
  **every** hyperedge has even length. This is the "provided every hyperedge has even
  length" hypothesis of the main characterization.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The all-crossing constraint around a hyperedge is a proper
  2-colouring of its boundary cycle, so it is satisfiable iff the hyperedge length is
  even; globally, an all-crossing direction exists iff all hyperedges are even.
Experiment (Experimenter): Modelled the boundary of a length-`ℓ` hyperedge by
  `SimpleGraph.cycleGraph ℓ` and identified all-crossing consistency with `Colorable 2`.
  Used the Mathlib chromatic-number computations for even/odd cycles.
Analysis (Analyst): The odd direction is the interesting one — an odd cycle forces
  chromatic number `3`, contradicting `Colorable 2`; this is the genuine obstruction that
  makes the even-length hypothesis necessary. The global statement is a clean `∀`-transfer.
Critique (Critic): The bound `ℓ ≥ 3` avoids the degenerate `cycleGraph 0,1,2`; every real
  hyperedge boundary in a medial map has length `≥ 1`, and even ones of interest are `≥ 4`.
Synthesis (PI): This supplies the nonemptiness of the all-crossing family assumed in the
  bijection `crossingSet_bijOn` of `Characterization.lean`.
-/

namespace BipartitePartialDual

open SimpleGraph

/-
A single hyperedge of length `ℓ` admits a consistent **all-crossing direction**
(a proper `2`-colouring of its length-`ℓ` boundary cycle) iff `ℓ` is even.
-/
theorem allCrossingLocal_iff_even (ℓ : ℕ) (hℓ : 3 ≤ ℓ) :
    (SimpleGraph.cycleGraph ℓ).Colorable 2 ↔ Even ℓ := by
  constructor;
  · intro h
    by_contra h_odd
    have h_chromatic : (cycleGraph ℓ).chromaticNumber = 3 := by
      convert SimpleGraph.chromaticNumber_cycleGraph_of_odd ℓ ( by linarith ) ( by simpa using h_odd ) using 1;
    exact absurd ( h_chromatic ▸ h.chromaticNumber_le ) ( by decide );
  · intro h_even
    have h_chromatic : (cycleGraph ℓ).chromaticNumber = 2 := by
      convert SimpleGraph.chromaticNumber_cycleGraph_of_even ℓ ( by linarith ) h_even using 1;
    convert h_chromatic ▸ SimpleGraph.colorable_of_chromaticNumber_ne_top _;
    aesop

/-
The medial map `M(H)` of a hypermap whose hyperedges have lengths `len e ≥ 3` admits
an all-crossing direction (consistently on every hyperedge) **iff every hyperedge has
even length**.
-/
theorem allCrossing_global_iff_even {E : Type*} (len : E → ℕ) (h3 : ∀ e, 3 ≤ len e) :
    (∀ e, (SimpleGraph.cycleGraph (len e)).Colorable 2) ↔ (∀ e, Even (len e)) := by
  exact forall_congr' fun e => allCrossingLocal_iff_even ( len e ) ( h3 e )

end BipartitePartialDual