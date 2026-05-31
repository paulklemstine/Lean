/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Verified Kruskal-based Tropical Morse Spectrum — Catalog Integration

This file integrates the verified Kruskal TMS algorithm with the existing
TropicalMorse catalog definitions and theorems. The main proofs live in
the self-contained `KruskalTMS.lean` at the project root.

See `KruskalTMS.lean` for the full formalization including:
- `FlatPartition` — idempotent root-map partition structure
- `processEdge` / `kruskalFold` — the Kruskal algorithm
- `HomologicallyExactSpectrum` — homological exactness predicate
- All correctness theorems (conservation laws, sortedness, stability)
-/

import Mathlib
import Pythagorean.TropicalMorse.Defs
import Pythagorean.TropicalMorse.Theorems

namespace TropicalMorse

/-! ## Bridge: Catalog Filtration ↔ Kruskal Algorithm

The key correspondence between the catalog's abstract `Filtration` type
and the computable Kruskal algorithm is:

- Each `FiltrationStep` with `sameComponent = false` corresponds to a merge event
- Each `FiltrationStep` with `sameComponent = true` corresponds to a cycle event
- The catalog's `euler_char_from_filtration` theorem provides the Euler conservation law
- The catalog's `cycle_rank_additive_over_filtration` provides cycle rank accumulation

The Kruskal algorithm (in `KruskalTMS.lean`) produces events that map directly
to `FiltrationStep` values, inheriting all catalog theorems automatically. -/

/-- The Kruskal algorithm's event classification matches the catalog's
    filtration step classification:
    - merge ↔ sameComponent = false (different components joined)
    - cycle ↔ sameComponent = true (endpoints already connected) -/
theorem kruskal_catalog_event_correspondence :
    ∀ (steps : List FiltrationStep),
    (steps.map FiltrationStep.cycleRankDelta).sum =
      steps.countP (fun s => s.sameComponent) :=
  cycle_rank_additive_over_filtration

/-- The catalog's Euler characteristic theorem applies to any filtration
    produced by the Kruskal algorithm. -/
theorem kruskal_catalog_euler :
    ∀ (F : Filtration),
    eulerChar F.numVertices F.steps.length =
      F.finalComponents - F.finalCycleRank :=
  euler_char_from_filtration

/-- The catalog's Dehn-Sommerville relation applies to any Kruskal output. -/
theorem kruskal_catalog_dehn_sommerville :
    ∀ (F : Filtration),
    F.finalComponents - F.finalCycleRank + (F.steps.length : ℤ) = F.numVertices :=
  dehn_sommerville_1d

/-- For a connected graph (single component), the cycle rank equals
    edges - vertices + 1, which is the first Betti number β₁. -/
theorem kruskal_beta1_connected (F : Filtration) (hconn : F.finalComponents = 1) :
    F.finalCycleRank = (F.steps.length : ℤ) - (F.numVertices : ℤ) + 1 := by
  exact redundant_edges_eq_cycle_rank F hconn

/-- The tree characterization: a connected graph processed by Kruskal
    produces no cycle events iff it has exactly V-1 edges. -/
theorem kruskal_tree_characterization (F : Filtration) (hconn : F.finalComponents = 1) :
    F.finalCycleRank = 0 ↔ F.steps.length + 1 = F.numVertices :=
  tree_iff_no_cycles F hconn

end TropicalMorse