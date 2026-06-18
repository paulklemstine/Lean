# Summary of changes for run 2455644b-a99f-40f9-8dd8-f85dacb8e48a
## Result: Ramanujan's 1729 as a Sum of Three Cubes — conjecture refuted

The mission's central conjecture ("1729 has no representation as a sum of three nonzero integer cubes") is **FALSE**. I established this with fully proved, axiom-clean Lean 4 theorems (only `propext`, `Classical.choice`, `Quot.sound`; no `sorry`, no `native_decide`).

### Files added (under `Catalog/Logic/Taxicab1729/`)
- `Core.lean` — the two-cube taxicab facts: `1729 = 10³+9³ = 12³+1³` (`taxicab_two_ways`), the two summand pairs are genuinely distinct (`taxicab_pairs_distinct`), and there is no all-equal `3x³ = 1729` representation (`taxicab_not_three_equal_cubes`, via a divisibility argument + `omega`).
- `ThreeCubes.lean` — the three-cube analysis:
  - `cube_residue_mod9` — every integer cube is ≡ 0, 1, or 8 (mod 9).
  - `sum_three_cubes_not_4_5_mod9` — the classical obstruction: a sum of three cubes is never ≡ 4 or 5 (mod 9) (case analysis on `ZMod 9` + `push_cast`).
  - `taxicab_outside_obstruction` — 1729 ≡ 1 (mod 9), so it evades the obstruction.
  - `taxicab_three_cubes_exists` — **the refutation**: explicit nonzero solution `13³ + (-7)³ + (-5)³ = 1729`, with all bases nonzero and not all equal.
  - `taxicab_three_cubes_two_solutions` — a second, essentially distinct solution `208³ + 98³ + (-215)³ = 1729`.
  - `taxicab_no_positive_three_cubes` — there is **no** all-positive three-cube representation (bound each base by 12 since 13³ > 1729, then `interval_cases … omega`), so every genuine representation must use a negative base.
  - `taxicab_three_cubes_base_sum_mod3` — necessary condition: in any representation, x+y+z ≡ 1 (mod 3) (via a³ ≡ a mod 3).
- `FUTURE_DIRECTIONS.md` — 5 bold, falsifiable follow-on conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

Each file contains `-- !-- Lab Notes -- !--` blocks documenting the Hypothesize / Experiment / Analyze / Critique / Synthesize team loop, including the brute-force counterexample search and the adversarial review (every claim survived an explicit attempted counterexample).

### Build/infrastructure note
The buildable Lean library lives in the `Catalog/` subtree; its Mathlib dependency was uncached, so I populated it from the already-built copy in the project (identical commit/toolchain) and confirmed both new modules compile. The mathematical results were determined via computational search (the only nonzero three-cube representations within a large height bound are the two listed) and then proved formally with insight-bearing tactics (`ZMod` case analysis, `push_cast`, `gcongr`, `nlinarith`, `interval_cases`, `omega`).