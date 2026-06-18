# Summary of changes for run 41957e2b-e256-45b0-bad8-73a1ed98015e
## What I produced

I extended the order-theoretic Cook–Reckhow development in `Catalog/Logic/ProofComplexity/` with a new, fully verified Lean file establishing the **horizontal geometry** of the poset of p-degrees — its *infinite width* — to complement the existing *infinite height* (chains) and *meet-semilattice* (binary meets) results.

### New file: `Catalog/Logic/ProofComplexity/DegreeAntichain.lean`
Builds on the catalog foundations `SimulationPreorder`, `SimulationDegrees`, and `DegreeLattice` (reusing `simulates_sysOfSize_iff`, `PolyMono`, `sysOfSize`, and the `Antisymmetrization` p-degree poset rather than reproving them).

Main results (all `sorry`-free, depending only on `propext, Classical.choice, Quot.sound`):
- `spike_growth_gap` — the core arithmetic: `(2^n + 2)^c < 2^(n²)` for `n ≥ c+1` (a super-polynomial spike beats any polynomial blow-up).
- `spike_witness` — `n = p·(q·(c+1)+1)` is divisible by `p`, not by `q` (via coprimality of distinct primes), and `≥ c+1`.
- `not_simulates_spikeSystem` / `spikeSystem_incomparable` — distinct primes `p ≠ q` give incomparable p-degrees via the residue-class spike `spikeSize p n = if p ∣ n then 2^(n²) else 2^n`.
- `antichainSystem_incomparable` and `infinite_antichain_pdegrees` — indexing the spikes by the `i`-th prime yields an injective ℕ-indexed **antichain** in `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, so the poset of p-degrees has **infinite width**.

The file includes the requested Lab Notebook block (Hypothesis / Result / Insight / Failure analysis) and one-line `-- !-- … -- !--` proof-sketch comments above each declaration.

### `FUTURE_DIRECTIONS.md`
A freeform narrative synthesizing the height/width picture and giving five falsifiable research directions (not-a-lattice / no joins, density, embedding the product order ℕ×ℕ, countable-poset universality, and a concrete named-proof-system bridge), each with a "The key insight is…" sentence and a "Why now?" justification grounded in the new `spike_growth_gap` and `simulates_sysOfSize_iff` machinery.

### Build fix
The repository's root `lakefile.toml` library globs did not match the actual `Catalog/` module layout (the `Catalog.*` module names used by every file's imports), so the project did not build via `lake`. I corrected it to a single `Catalog` library with glob `Catalog.+` and default target `Catalog`, which makes the `Catalog.*` modules resolve. The new file and its dependencies build successfully (`lake build Catalog.Logic.ProofComplexity.DegreeAntichain`).

No existing user content was deleted; only the build configuration was corrected and new material added.