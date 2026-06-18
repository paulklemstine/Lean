# Summary of changes for run 942a474e-63fe-4814-9c5c-7b32e0234795
Delivered a new research cycle establishing that Hodge–Laplacian message passing is a discrete heat semigroup.

**New Lean file** `Catalog/Speculative/AutoResearch/HodgeHeatSemigroup.lean` (builds successfully, zero `sorry`), which extends the two existing catalog cycles (`HodgeSpectralThreshold.lean` and `HodgeMessagePassingConvergence.lean`) rather than reproving them — it imports and reuses their definitions (`depthMap`, `mpStep`, `hodgeLaplacian`) and lemmas (`mpStep_contraction`, `mpStep_iterate_contraction`, `mpStep_dist_to_harmonic_bound`, `contraction_factor_at_optimal`, `harmonic_iff`, `mpStep_iterate_harmonic_fixed`).

**Five theorems proved (no sorry on any result):**
1. `depthMap_semigroup` — the discrete semigroup law `T^(a+b) = T^a ∘ₗ T^b` (depth = discrete time).
2. `mpStep_energy_nonincreasing` — Lyapunov dissipation `⟪Tx,Tx⟫ ≤ ⟪x,x⟫`, the μ=0 reading of the contraction bound.
3. `mpStep_optimal_rate` — residual energy decays as `(1−μ/λ)ᵏ` at the spectral step `α=1/λ`.
4. `mpStep_tendsto_harmonic` — depth-k output converges in the norm topology to the harmonic (cohomology) component.
5. `hodge_heat_semigroup_fixed` — cross-file bridge: harmonic (closed-and-coclosed) cochains are exact fixed points of the flow at every depth.

Each theorem was confirmed via `#print axioms` to depend only on `propext`, `Classical.choice`, `Quot.sound`. The file includes the required `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and `-- !-- comment -- !--` one-to-two-sentence proof sketches per theorem.

**`FUTURE_DIRECTIONS.md`** (in the same `Speculative/AutoResearch/` directory) provides a narrative synthesis, a results-summary table, and five falsifiable research directions (steady-state = orthogonal harmonic projection; a strict discrete Łojasiewicz/coercivity bound; contraction under 1-Lipschitz nonlinear activations; a Lie–Trotter bridge to the continuous heat semigroup `e^{−tΔ}`; and closing the Carmichael primitive-divisor tail), each with a "The key insight is…" sentence and a "Why now?" justification.

Note on project layout: the actual Lean package lives in the `Catalog/` subdirectory (its `lakefile.toml`), which is where the build runs.