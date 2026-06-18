# Summary of changes for run 49f1bd51-1473-4c3e-a143-d79f540cfca3
Delivered a self-contained Lean 4 development on the oracle counting barrier (the proof-search/oracle non-computability bridge), plus the required research notes.

## New Lean file: `Catalog/Speculative/OracleCountingBarrier.lean`
Formalizes three-valued oracles `Oracle N := Fin N → Fin 3` (false / true / unknown) and proves **five theorems with 0 sorries**, each verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`:

1. `oracle_card` — there are exactly `3^N` oracles on `N` statements.
2. `oracle_not_covered` — the abstract counting barrier: if a program space `P` has `card P < 3^N`, then no compiler `f : P → Oracle N` is surjective, so some oracle is uncomputable (proved via `Fintype.card_le_of_surjective`).
3. `budget_gap_exists` — for any fixed alphabet size `b` and length `k`, eventually `b^k < 3^N`, so fixed budgets are outrun.
4. `binary_insufficient` — `2^N < 3^N` for `N ≥ 1`: binary descriptions are information-theoretically too poor for three-valued oracles.
5. `computable_fraction_tendsto_zero` — with a fixed budget `C`, the computable fraction `C / 3^N → 0`; almost all oracles are non-computable.

The file follows the requested format: a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and per-theorem `-- !-- ... -- !--` proof sketches. The central, reusable insight recorded there is that the *coverage* obstruction is alphabet-agnostic (needs only size ≥ 2) while the "3" only powers the *information* obstruction — separating these makes every proof one or two lines.

## `Catalog/Speculative/FUTURE_DIRECTIONS.md`
Narrative synthesis, a results-summary table, and 5 falsifiable research directions (quantitative 3-vs-2 entropy gap; alphabet-generic barrier; logically consistent oracles still escape; composition as a finite jump; tropical solution oracles), each containing a "The key insight is..." sentence and a "Why now?" justification, with catalog cross-references.

## Build fix
The project's `lakefile.toml` was misconfigured: its library globs (`Algebra.+`, `Speculative.+`, ...) did not match the actual `Catalog/`-prefixed file layout, so no module — existing or new — could build. I added `srcDir = "Catalog"` to the package, which repairs the build for the whole catalog. The new module builds cleanly (`lake build Speculative.OracleCountingBarrier`) with no warnings and no sorries.