# Summary of changes for run 8559ec19-4a11-444f-a9f3-a132e45ffa8d
## What was delivered

I added a new Lean 4 research file, `Catalog/Logic/ProofComplexity/DegreeAntichain.lean`, that establishes the **horizontal axis (infinite width)** of the order-theoretic Cook–Reckhow program already present in this catalog. It builds directly on the existing foundations in `Catalog/Logic/ProofComplexity/` — the simulation preorder (`Simulates`, `PolyMono`/`PolyBounded`), the generic separation template (`no_simulation_of_hard`), and especially the master reduction `simulates_sysOfSize_iff` and the meet/chain results in `DegreeLattice.lean` — rather than reproving any of them.

### Theorems proved (all `sorry`-free; axioms = `propext, Classical.choice, Quot.sound`)
- `spike_growth_gap` — the elementary estimate `(2^n + 2)^c < 2^(n²)` for `n ≥ c+1`.
- `spike_witness` — the explicit coprimality witness `n = p·(q·(c+1)+1)` is `p`-divisible, `q`-indivisible, and `≥ c+1`, for distinct primes `p ≠ q`.
- `not_simulates_spikeSystem` — one-directional non-simulation of the residue-class spike systems.
- `spikeSystem_incomparable` — distinct primes give two-sided incomparable p-degrees.
- `antichainSystem_incomparable` — the nth-prime-indexed family is pairwise incomparable.
- `infinite_antichain_pdegrees` — an injective ℕ-indexed pairwise-incomparable antichain inside the poset `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, i.e. the poset of p-degrees has **infinite width**, the dual of the existing infinite-height chain.

The construction is the residue-class spike `spikeSize p n = if p ∣ n then 2^(n²) else 2^n`: distinct primes place super-exponential bumps on disjoint residue classes, and via `simulates_sysOfSize_iff` incomparability reduces to the elementary arithmetic gap above.

### Other deliverables
- The file contains a **Lab Notebook** block (Hypothesis / Result / Insight / Failure analysis) and **`-- !-- comment -- !--` proof-sketch blocks** for each result.
- **`FUTURE_DIRECTIONS.md`** with a synthesis, a results-summary table, and five falsifiable research directions (joins fail / not a lattice; density; an order-embedding of ℕ×ℕ combining height and width; countable-universality; and a concrete bridge to named proof systems), each with a "The key insight is…" sentence and a "Why now?" justification.

### Build note
The repository's `lakefile.toml` `defaultTargets`/library globs did not match the actual `Catalog/...` source layout, so the modules were not part of any build target. I added a single additive `lean_lib` entry named `Catalog` (globs `Catalog.+`); this is what makes `Catalog.Logic.ProofComplexity.*` compile, and it leaves all pre-existing entries untouched. The new module builds successfully.