# Summary of changes for run d691e4d5-b24b-4796-ac43-eac5576f2a6f
Produced a self-contained, fully-proved Lean 4 development plus a research roadmap, all building cleanly against the project's Mathlib.

**New Lean file:** `Catalog/Speculative/AutoResearch/TopologicalCodes.lean` (placed in the `Speculative` library, a default build target). It formalizes the topological/geometric invariant split conjectured for "topological error-correcting codes from exotic smooth structures" using the cleanest fully-formal incarnation: cycle codes of graphs over `ZMod 2` (the 1-D homological/CSS codes).

**Theorems (0 sorries, standard axioms only — `propext`, `Classical.choice`, `Quot.sound`):**
- `cycleBoundary_eq_zero_iff` — the cycle space of `C_n` is exactly `{0, 𝟙}` (the structural core: in characteristic 2 the cycle condition forces global constancy around the loop).
- `cycleCode_card` — the logical dimension is `k = 1 = b₁(C_n)`, a topological invariant (the harmonic-kernel/Betti number of the catalog's discrete-Hodge thread).
- `allOnes_hammingNorm` — the nontrivial logical operator has weight `n`.
- `cycleDistance_eq` — the code distance is `d = n`, a refinement-sensitive (geometric) invariant.
- `distance_not_homological_invariant` (headline) — `C₃` and `C₄` have equal `k` but unequal `d`, so distance is *not* a function of homology.
- `distance_scales_with_refinement` (headline) — edge-subdivision `C_n → C_{2n}` pins `k` while doubling `d`.

This makes precise and machine-checks the conjecture's dichotomy (`k` lives in homology; `d` lives one level finer) and adds the quantum-information layer on top of the catalog's existing discrete-Hodge results (`HodgeBettiRank`, `HodgeFullDecomposition`), which had computed the harmonic sector but never read it as a code space. Computational sanity checks (`#eval (cycleCode 3).card = 2`, etc.) confirm the definitions are effective.

**Documentation deliverables:** the file contains a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and per-theorem `-- !-- ... -- !--` proof sketches. `FUTURE_DIRECTIONS.md` (project root) gives a synthesis, results table, and 5 falsifiable research directions (2-D toric codes, subdivision chain-homotopy invariance, spectral-gap distance bounds, a decidable code-equivalence checker, and the `k`-forces-`d` obstruction), each with a "key insight" and "Why now?" justification.