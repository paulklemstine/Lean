# Summary of changes for run 0f4ad680-6f45-482c-8e05-368af8a02907
Delivered a new self-contained Lean 4 research file and a future-directions narrative.

**New file: `Catalog/Speculative/AutoResearch/TopologicalCodes.lean`**
Formalizes the homological (cycle) error-correcting code of the n-cycle graph `C_n` over `ZMod 2`, modeling 1-chains as maps `ZMod n → ZMod 2` with cyclic boundary `(∂x) j = x j + x (j+1)`. It proves the "topological/geometric split" — that the code's logical dimension `k` is a topological invariant while its distance `d` is a strictly finer geometric one — with six theorems, all sorry-free and depending only on the allowed axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `cycleBoundary_eq_zero_iff` — the cycle space (kernel of the boundary) is exactly `{0, 𝟙}`.
- `cycleCode_card` — the logical dimension is `k = 1` (`#code = 2`), the first Betti number `b₁(C_n)`, a topological invariant (connects to the catalog's `HodgeBettiRank.hodge_betti`).
- `allOnes_hammingNorm` — the all-ones cycle has Hamming weight `n`.
- `cycleDistance_eq` — the code distance is `d = n` (the girth), a geometric invariant.
- `distance_not_homological_invariant` — headline split: `C₃` and `C₄` share `k` but have unequal `d`.
- `distance_scales_with_refinement` — edge subdivision `C_n → C_{2n}` fixes `k` and doubles `d`.

The file includes the required `-- !--` proof-sketch comments and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), and reads the catalog's discrete-Hodge thread as a quantum-information code-space layer.

**New file: `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`**
A freeform narrative with Synthesis, a Results Summary table, and five falsifiable research directions (2D toric codes; subdivision-as-chain-homotopy invariance of `k`; spectral/Laplacian distance bounds; a decidable code-equivalence checker provably blind to distance; and characterizing when `k` forces `d`), each containing a "The key insight is..." sentence and a "Why now?" justification.

Verification note: an initial draft used `by positivity` inside a type-level instance for `NeZero (2*n)`, which silently failed and injected `sorryAx`; this was caught via axiom inspection and replaced with an `omega`-based proof, after which all theorems check clean.