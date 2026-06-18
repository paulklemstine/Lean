# Summary of changes for run 6c59c042-6dea-47e0-b445-7858b4ac9db8
Built a new bridge connecting the catalog's coalgebraic neural Myhill–Nerode theory to its Cook–Reckhow proof-complexity simulation/degree-lattice machinery.

## New file: `Catalog/Bridges/NeuralProofComplexitySimulation.lean` (sorry = 0; axioms: only propext, Classical.choice, Quot.sound)

Core construction: a finite-depth behavioral preorder `behavioral_le N k s t` on the states of a `NeuralObservationSystem` whose observations live in a `Preorder β` — the genuinely *directed* ("inclusion of observations") refinement of the catalog's equality-based `neural_equiv_upto`. Defined recursively (depth 0 compares observations; depth k+1 additionally requires preservation under every one-step `neural_derivative`).

Theorems proved (all the requested targets, plus supporting calculus):
- `behavioral_preorder_trans` (Target 1) — transitivity.
- `derivative_monotone` (Target 2) — depth-(k+1) relation descends to depth-k on one-step derivatives.
- `induced_simulates` (Target 3) — the all-depth behavioral preorder is a genuine coalgebraic simulation (`IsNeuralSimulation`).
- `coalgebra_morphism_preserves_simulation` (Target 4) — a `NeuralHom` transports `behavioral_le`, reusing the catalog's `neural_hom_preserves_behavior`.
- `induced_degree_monotone` (Target 5) — the cross-domain payoff: for single-symbol, ℕ-valued neural systems, behavioral inclusion pushes forward to the p-simulation preorder `ProofComplexity.Simulates` of the trace `sysOfSize` proof systems, with the *identity* polynomial blow-up. This directly reuses the catalog's `simulates_sysOfSize_iff` and `polyMono_id`, so nonexpansiveness is inherited from the neural derivative rather than imposed.
- Supporting: `behavioral_le_refl`, `behavioral_le_antitone`, `behavioral_le_of_le`, `behavioral_le_observe`, and the master characterisation `behavioral_le_iff` (linking the preorder to pointwise `≤` of `neural_behavior` on bounded-length words).

The file includes the required `-- !-- Lab Notebook -- !--` block (Hypothesis/Result/Insight/Failure analysis) and `-- !-- comment -- !--` one–two-sentence proof sketches on each result.

## `FUTURE_DIRECTIONS.md`
A narrative synthesis, a results-summary table, and 5 falsifiable research directions (each with a "The key insight is…" sentence and a "Why now?" justification): a quantitative 1-Lipschitz disagreement pseudometric (the optional Target 6), a neural-trace factory for discharging `PolyBounded`/`PolyMono` obligations, a homotopical path-space reframing of the truncation tower, localization inverting behavioral equivalences, and cross-alphabet rank realising the `powSystem` infinite-height ladder.

## Build note
The project's `lakefile.toml` library globs (e.g. `Bridges.+`) did not match the actual on-disk module layout (modules are named `Catalog.*` under `Catalog/`), so no catalog module could be compiled by `lake build`. I added one library entry `Catalog` with glob `Catalog.+` (no existing entries removed) so the modules build by name; `lake build Catalog.Bridges.NeuralProofComplexitySimulation` now compiles the new file and its dependencies cleanly.