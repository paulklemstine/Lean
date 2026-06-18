# Summary of changes for run 413790a5-c283-4189-baf6-1ef2057a4992
I added a self-contained, fully-proved Lean 4 formalization of a zero-knowledge proof system for graph 3-colorability, plus a research-directions document.

**New file: `Catalog/Cryptography/GraphThreeColoringZK.lean`** (imports only Mathlib; all theorems compile with only the standard axioms `propext`, `Classical.choice`, `Quot.sound` — no `sorry`, no `native_decide`).

It models one round of the classical Goldreich–Micali–Wigderson protocol: the prover recolors a proper 3-coloring by a random color permutation, the verifier queries an edge, the prover opens the two endpoint colors, and the verifier accepts iff they differ. The three defining ZK properties are proved:

- `properColoring_perm` — recoloring by any color permutation preserves properness (the prover's randomization is sound).
- `gmw_completeness` — an honest prover with a proper coloring always makes the verifier accept (on every edge, under every permutation).
- `gmw_soundness` and `gmw_soundness_error` — if the graph is not 3-colorable, every committed coloring has at least one monochromatic edge, giving the verifier a nonzero per-round catch probability `≥ 1/|edges|`.
- Zero knowledge via the simulation paradigm: `revealMap_bijective` shows the map `σ ↦ (σ a, σ b)` from color permutations onto ordered distinct color pairs is a bijection (the rigidity of `Fin 3`); `gmw_zk_uniform` deduces each revealed pair has exactly one preimage permutation (uniform view); `gmw_zk_indistinguishable` shows the transcript distribution is independent of the actual colors; and `gmw_simulator_sound` shows every simulated transcript actually occurs in the real protocol. Together these capture that the verifier learns nothing about the coloring.

It also includes a worked `K₃` example showing the triangle is 3-colorable and the protocol runs.

This extends the simulation-paradigm methodology of the existing `Catalog/Cryptography/TropicalZeroKnowledge.lean` (which handled an algebraic min-plus relation) to the combinatorial NP-complete relation of graph 3-colorability, and connects to the commitment-binding viewpoint of `Catalog/Cryptography/Commitments.lean`.

**Research directions:** `FUTURE_DIRECTIONS.md` (also mirrored next to the source as `Catalog/Cryptography/GraphThreeColoringZK_FUTURE_DIRECTIONS.md`) lays out five falsifiable conjectures — multi-round soundness amplification, distributional ZK as an exact PMF equality, the `k`-colorability rigidity threshold, hiding from concrete commitments, and a Fiat–Shamir NIZK collapse — each with a "key insight" and a "why now" justification.

Verification note: the project's lakefile expects modules at the repository root while the catalog sources live under `Catalog/`, so the default `lake build` cannot locate any module. Because the new file depends only on Mathlib, I verified it directly through the Lean server, confirming a clean compile and the axiom set above.