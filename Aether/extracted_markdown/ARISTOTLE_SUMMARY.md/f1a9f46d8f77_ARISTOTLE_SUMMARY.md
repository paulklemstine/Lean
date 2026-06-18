# Summary of changes for run de0b090e-e5c7-43cf-a9ab-63a341586b20
Completed one full scientific-team research cycle on "Cellular Automata at the Ordinals: Transfinite Computation," delivering two fully-proved Lean 4 files (0 sorries, only standard axioms) plus a future-directions document, all under `Catalog/Shared/`.

## Files delivered

**`Catalog/Shared/TransfiniteCellularAutomata.lean`** — self-contained theory of transfinite cellular automata (CA indexed by ordinals via `Ordinal.limitRecOn`):
- `run_zero`, `run_succ`, `run_natCast` — the ordinal evolution restricts to ordinary finite iteration `step^[n]` on ℕ.
- `run_limit`, `run_omega_add_nat` — limit-stage and post-ω behaviour.
- `ittm_run_omega` (flagship) — the Infinite-Time-Turing-Machine limit law realized cellularly: the cell value at stage ω equals the `limsup` (`∃ᶠ`, "cofinally on") of the finite history. A genuine iff, not a definitional unfolding.
- `ittmLim_tail_invariant`, `ittmLim_not_finitary` — the limit rule depends only on the tail and is provably *not* a finite-stage function (the formal core of the super-Turing separation).
- `ittm_toggle_super_turing` — a concrete super-Turing witness: the parity/local-flip automaton has a non-convergent finite orbit (cofinally on AND cofinally off) yet receives a definite value `true` at stage ω.
- `omega_mul_succ_limit`, `omega_sq_has_infinitely_many_limit_stages` — why ω² is the right clock: infinitely many limit stages ω·(k+1) are cofinal below ω², so an ω² computation stacks infinitely many ITTM limits.

**`Catalog/Shared/TransfiniteCAGardenOrdinalBridge.lean`** — the cross-domain bridge (satisfies the Extra Bridge Mandate). It imports and combines results from two different catalog domains:
- Logic: `Ordinal.nonincreasing_eventually_constant` from `Catalog/Logic/TransfiniteRefinement.lean`;
- Bridges: `IsGardenOfEden` from `Catalog/Bridges/GardenOfEden.lean`;
- Shared: the transfinite-CA `ittm_run_omega` from the core file.
The flagship `wellfounded_transfinite_ca_collapses` proves that a transfinite CA carrying an ordinal Lyapunov potential reaches, within finitely many (< ω) steps, a configuration that (a) is a genuine fixed point, (b) is not a Garden-of-Eden state, and (c) equals the transfinite ω-evolution — i.e. ordinal well-foundedness forbids Garden-of-Eden behaviour at the attractor and renders the transfinite clock redundant. This isolates the exact dividing line between ordinary and super-Turing transfinite computation: the existence of a descending ordinal potential.

**`Catalog/Shared/FUTURE_DIRECTIONS.md`** — five bold, falsifiable conjectures derived from this cycle's findings, each with a "The key insight is..." sentence and a "Why now?" justification (the potential dichotomy, an ω·k clock hierarchy, a genuine ordinal-limsup rule, Garden-of-Eden vs transfinite reachability, and an orbit-order-type complexity measure).

Each file contains `-- !-- Lab Notes -- !--` blocks documenting the Hypothesis / Experiment / Analysis / Critique / Synthesis loop, including the named files used in the bridge and the new connection they create. Every main theorem uses insight-bearing techniques (transfinite/ordinary induction, `by_contra`, frequently/eventually filters, ordinal arithmetic) — none is trivial, definitional, or `native_decide`-based. All new theorems were verified to depend only on `propext`, `Classical.choice`, and `Quot.sound`.