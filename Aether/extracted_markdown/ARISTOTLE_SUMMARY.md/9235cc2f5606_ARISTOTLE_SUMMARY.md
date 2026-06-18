# Summary of changes for run f44683c5-bb28-48ce-a317-c2b0f684c698
Delivered a self-contained Lean 4 development of "The Oracle Counting Barrier" plus extensions, with a research roadmap.

**New Lean files (both compile cleanly via `lake env lean`, zero `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):**

1. `Catalog/Computation/OracleCountingBarrier.lean` — the foundational counting barrier, 8 theorems:
   - `oracle_card`: there are exactly `3 ^ N` three-valued oracles (`Fin N → Fin 3`).
   - `oracle_not_covered_generic`: the reusable, alphabet-agnostic coverage barrier — `card P < a ^ N` forces some oracle to escape every compilation `P → (Fin N → Fin a)`.
   - `oracle_not_covered`: the `a = 3` one-line corollary.
   - `budget_gap_exists`: any fixed budget `b ^ k` is eventually outrun by `3 ^ N`.
   - `binary_insufficient`: `2 ^ N < 3 ^ N` for `N ≥ 1` (boundary `N = 0` is exactly where it fails).
   - `computable_fraction_tendsto_zero`: `C / 3 ^ N → 0` for any constant budget.
   - `binary_fraction_eq`: the exact law `2 ^ N / 3 ^ N = (2/3) ^ N`.
   - `binary_fraction_tendsto_zero`: that fraction vanishes geometrically.

2. `Catalog/Computation/OracleBarrierExtensions.lean` — three new extension theorems advancing the open directions:
   - `oracle_diagonal_escape`: a *constructive* Cantor diagonal producing the escaping oracle explicitly, for any alphabet `a ≥ 2`.
   - `oracle_comp_card` / `oracle_comp_jump` / `oracle_comp_budget_gap`: the oracle-to-oracle space has exact size `3 ^ (N · 3 ^ N)`, strictly above the evaluation space `3 ^ N` for `N ≥ 1`, and beyond every fixed budget — a finite, fully constructive Turing jump from a bare cardinal inequality.
   - `consistent_oracles_escape`: the barrier survives any logical-consistency constraint that retains an independent `3 ^ k` block; a sub-`3 ^ k` program space still leaves a *consistent* oracle uncovered.

Each file carries `-- !-- comment -- !--` proof sketches per theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis, including the `omega` variable-modulus pitfall).

**`FUTURE_DIRECTIONS.md`** — narrative synthesis, results summary, and 5 falsifiable research directions (exact reachability spectrum and its phase transition; an iterated finite jump hierarchy; logically consistent oracles at scale via antichain width; confidence oracles via the discretization limit; tropical solution oracles), each with a "The key insight is..." sentence and a "Why now?" justification, citing the proved lemmas they build on and the catalog connections (`Computation/OracleBurden.lean`, `Computation/Oracles/Foundation.lean`, `Tropical/ComplexityTransfer.lean`).

Note: the project's `lakefile.toml` default-target build is misconfigured in this environment (it looks for library roots at the repository root rather than under `Catalog/`), so the two new files were authored to be self-contained (`import Mathlib`) and verified directly with the Lean compiler; I left the lakefile untouched.