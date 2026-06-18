# Summary of changes for run 7aec2d0d-f7c2-4dfa-84e2-a887c36cd3cd
Added a new, fully-proved Lean module and a research-directions note extending the project's cryptography catalog on the theme "One-Way Functions: Existence and Hierarchy".

New file: `Cryptography/OneWayHierarchy.lean` (module `Cryptography.OneWayHierarchy`), which builds on `Cryptography/HardnessHierarchy.lean` (reusing `CryptoLevel`, its `rank`, and `hierarchy_strict`) and complements `Cryptography/OneWay.lean`. It compiles cleanly (verified with a module build) with `sorry = 0` and every result depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (the order results use no axioms).

Main theorems proved:
- `exists_weakInverse` / `invFun_weakInverse`: every function over a nonempty domain has a weak inverse (`Function.invFun f`).
- `not_infoTheoreticOneWay`: the conceptual centerpiece — no function is information-theoretically one-way, i.e. one-wayness is necessarily computational, not information-theoretic.
- `weakInverse_inverts_all`: a weak inverter succeeds on all |α| inputs (perfect unbounded-adversary advantage).
- `exact_inversions_le_image`: any inverter recovers at most |Im f| inputs exactly (collision-limited capacity).
- `invFun_exact_inversions`: the canonical inverse attains that optimum |Im f|, via an explicit transversal bijection — the bridge between collision/fiber structure and inversion.
- `rank_injective`, `level_total`, `owf_weakest`, `enc_strongest`: upgrade the qualitative hierarchy OWF → PRG → PRF → ENC into a genuine total order with extremal elements (order-isomorphic skeleton to Fin 4).

The file follows the requested format: `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) per section and short `-- !-- comment -- !--` proof sketches on each theorem.

Companion file `Cryptography/OneWayHierarchy_FUTURE_DIRECTIONS.md` gives the synthesis, a results-summary table, and five falsifiable research directions, each with a "The key insight is…" sentence and a "Why now?" justification, all cross-referencing existing catalog results (`fiber_sum_eq_card`, `SecurityProfile`, `reduction_compose_loss`, `GGMTree`).

Note: the underlying Lean project root is the `Catalog/` subdirectory (it has its own lakefile), so the module path is `Cryptography.OneWayHierarchy`.