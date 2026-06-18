# Summary of changes for run df5ea632-ae35-406e-a1d0-6915c3eb1053
## Phase A delivered — Functoriality of the Fibonacci rank of apparition

### New Lean file: `Catalog/Novelty/FibEntryFunctoriality.lean` (0 sorries, standard axioms only)

This file extends the existing entry-point program (`Catalog/Novelty/FibonacciEntryPointDuality.lean`'s master duality `p ∣ F n ↔ z(p) ∣ n`, and `Catalog/Novelty/FibCarmichaelStructure.lean`'s totality/lcm laws and `fibStep`/`fibPair` phase machinery). It proves **6 theorems**, all verified `sorry`-free and depending only on `propext, Classical.choice, Quot.sound`:

1. `fibEntry_dvd_of_dvd` — **monotonicity/functoriality**: `m ∣ n → z(m) ∣ z(n)`. Promotes `z` from a morphism on the coprime monoid to a morphism of the full divisibility poset `(ℕ, ∣)` (the capstone from the previous cycle's direction #5).
2. `fibEntry_gcd_dvd` — lax meet law `z(gcd m n) ∣ gcd(z m)(z n)` for arbitrary `m,n` (no coprimality).
3. `fibEntry_dvd_lcm` — lax join law `lcm(z m)(z n) ∣ z(lcm m n)` for arbitrary `m,n`.
4. `fib_dvd_squarefree_iff` — **Fibonacci–Korselt reduction**: for squarefree `n`, `n ∣ F m ↔ ∀ p ∈ n.primeFactors, z(p) ∣ m` (direction #3).
5. `pisano` (definition) + `pisano_pos` — the **Pisano period** as `orderOf` of the invertible Fibonacci shift on `ZMod p × ZMod p`, shown positive.
6. `fibEntry_dvd_pisano` — `z(p) ∣ π(p)`: the rank of apparition divides the Pisano period, proved purely group-theoretically (direction #2).

The file includes brief `-- !--` proof-sketch blocks per theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), as required.

### `FUTURE_DIRECTIONS.md`
Freeform narrative with a Synthesis, Results Summary table, and **5 falsifiable research directions** (Pisano sandwich `z(p) ∣ π(p) ∣ z(p)·(p-1)`; strictness of the lattice inequalities; a complete Fibonacci–Carmichael criterion; prime-power apparition `z(p^e)`; Pisano monotonicity via `ZMod` reduction). Each direction contains a "The key insight is..." sentence and a "Why now?" justification, and cites the relevant catalog results to build on.

### Infrastructure fix
The project's `lakefile.toml` had no library target covering the `Catalog/` source tree (its targets pointed at nonexistent root directories) and required Mathlib via git while the manifest vendors it locally, so no `Catalog` file could build. I added a `Catalog` lean_lib (glob `Catalog.+`), set it as the default target, and pointed the Mathlib require at the vendored `.lake/packages/mathlib` path matching the manifest. The new file now builds cleanly (`lake build Catalog.Novelty.FibEntryFunctoriality`).

All catalog synthesis was done by extending existing definitions/lemmas (importing and reusing `fibEntry`, `fib_dvd_iff_fibEntry_dvd`, `fibEntry_squarefree`, `fibStep`, `fibPair_iterate`) rather than reproving anything from scratch.