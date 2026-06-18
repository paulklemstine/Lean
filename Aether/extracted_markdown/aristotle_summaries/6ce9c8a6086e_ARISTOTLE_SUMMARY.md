# Summary of changes for run 9f27c3dd-132a-435a-af97-c77ceb99161f
Added a new self-contained Lean 4 development plus a research roadmap.

**New file:** `Bridges/ClosureCapacitySubmodularity.lean` (compiles cleanly, `sorry = 0`, all theorems verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

It introduces a `SetClosureOperator` and a `ClosureCapacity` (monotone, normalized, closure-invariant real set function), the energy functional `E` on the closed-set lattice, a `Submodular` predicate, and a closure-stable `ProbeFamily`, then proves:

1. `energy_mono` — the energy functional is monotone on the closed-set lattice.
2. `submodular_on_closed` — a submodular capacity induces the lattice diminishing-returns law `E(cl(C∩D)) + E(cl(C∪D)) ≤ E(C) + E(D)` (stated for all C, D — a strengthening, since closedness is not needed).
3. `reconstruction` — if a probe family is stable under closure and two capacities agree on every probe, they agree everywhere; the energy is reconstructible from finitely many probe values.
4. `exists_minimizer` — on a finite closure system the energy attains a minimum over closed sets.
5. `minimizer_meet_join_stable` — under submodularity the set of energy minimizers is a sublattice (stable under closure-of-intersection and closure-of-union).

The file also includes a concrete `idClosure` instance and two worked `example` blocks, with one-to-two sentence proof sketches written as `-- !-- ... -- !--` comment blocks. It conceptually builds on the catalog's closure infrastructure (`SetClosureOperator`, `FiniteClosureSystem`, `ProbeFamily`, `ClosureStableProbe`).

**Roadmap:** `Bridges/FUTURE_DIRECTIONS.md` (and a copy named `Bridges/ClosureCapacitySubmodularity_FUTURE_DIRECTIONS.md`) gives 5 falsifiable conjectures extending the work — Lovász extension / convexity, submodular strong duality via probes, quantitative robustness of reconstruction, matroid rank as a canonical instance, and a greedy (1−1/e) approximation guarantee — each with a "key insight" and a "why now" justification.