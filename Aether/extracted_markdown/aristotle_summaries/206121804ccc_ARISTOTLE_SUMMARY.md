# Summary of changes for run 12f533a1-70db-4a8d-8e12-45ac77a00c03
Produced a new self-contained Lean 4 file `Catalog/Speculative/AutoResearch/HodgeMessagePassingDynamics.lean` and a companion `Catalog/Speculative/AutoResearch/FUTURE_DIRECTIONS.md`, extending the existing `HodgeSpectralThreshold.lean` skeleton from single-trajectory energy facts to the global dynamics of the Hodge–Laplacian message-passing semigroup.

What was proved (all `sorry`-free; each verified to depend only on `propext`, `Classical.choice`, `Quot.sound`; the file builds cleanly with no warnings):

New results — exploiting that the layer `mpStep L α x = x − α(Lx)` is a *linear* operator:
- `mpStep_add`, `mpStep_smul`, `mpStep_sub` — linearity of one layer.
- `mpStep_iterate_add`, `mpStep_iterate_sub` — linearity of the depth-k iterate.
- `hodge_decomposition_dynamics` — the Hodge decomposition flow: for harmonic `h` (`L *ᵥ h = 0`), `(mpStep)^[k](h+r) = h + (mpStep)^[k] r`; the harmonic part is frozen while the residual evolves independently.
- `oversmoothing_limit` — under a residual contraction `ρ < 1`, every input is driven within any `ε` of its harmonic (cohomological) component in finitely many layers.
- `trajectory_stability` — the energy gap between two trajectories decays as `ρ^k`; the dynamics is a contraction modulo the harmonic kernel.

The file is self-contained (`import Mathlib` only), re-stating with proofs the catalog foundations it builds on (`mpStep`, `mpStep_iterate_fixes_harmonic`, `quadform_iterate_bound`, `spectral_depth_threshold`). Each theorem carries a brief `-- !-- ... -- !--` proof-sketch block, and the file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis). The conceptual thesis: oversmoothing in message passing is exactly a discrete Hodge decomposition of the semigroup — its fixed set is the harmonic kernel (a topological/cohomological invariant via the discrete Hodge theorem) and its complement is uniformly geometrically contracted.

`FUTURE_DIRECTIONS.md` records the synthesis, a results summary, and five falsifiable research directions (explicit depth-vs-accuracy rate; two-sided spectral sandwich; heat-semigroup/Euler-discretization consistency via the matrix exponential; residual connections defeating oversmoothing; and lifting to the full Hodge Laplacian to compute Betti ranks / cohomology), each with a "key insight" and a "Why now?" justification.

Note: the Lake project root is `Catalog/`; the new module compiles as `Speculative.AutoResearch.HodgeMessagePassingDynamics`.