# Summary of changes for run 02e6c590-dd0f-4454-ba11-fd7e78143bdb
Repaired and extended the project's Beal's-conjecture development.

**Build fix.** The package was missing `srcDir = "Catalog"` in `lakefile.toml`, so every library glob (e.g. `MachineLearning.+`, `Speculative.+`) resolved to non-existent paths at the repo root and nothing compiled. Added the `srcDir` line. Additionally, the two existing Beal files (`Catalog/MachineLearning/Beal/PrimitiveReduction.lean` and `Catalog/MachineLearning/Beal/Monotonicity.lean`) imported `Speculative.Beal.Defs`, which did not exist — so they could not build. I created that missing module.

**New file `Catalog/Speculative/Beal/Defs.lean`** — supplies the two foundational definitions used across the development: `BealConjecture` and `PrimitiveResidueSolution N x y z` (unit solutions of `a^x+b^y=c^z` in `ZMod N`). Their signatures were reverse-engineered to exactly match how the existing files consume them; both existing files now compile cleanly.

**New file `Catalog/MachineLearning/Beal/ModularObstruction.lean`** — develops the modular-obstruction attack and proves a genuine special case. Main results (all `sorry`-free; `#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound`):
- `primitiveResidueSolution_of_coprime_solution`: the reduction bridge — a coprime integer solution descends to a unit residue solution mod any `N`.
- `no_primitiveResidueSolution_cubes_mod9`: decidable proof that `a³+b³=c³` has no unit solution in `ZMod 9`.
- `primitiveResidueSolution_cubes_mod5`: a contrasting explicit witness mod 5, showing the obstruction has real arithmetic content.
- `no_primitiveResidueSolution_cubes_of_nine_dvd`: the obstruction propagates to every multiple of 9 (reuses the catalog `Monotonicity` result).
- `flt3_no_coprime_to_three_solution` and `three_dvd_some_of_cubic_solution`: the first-case Fermat-for-cubes special case — `A³+B³=C³` forces `3` to divide one of `A,B,C`.
- `beal_common_factor_of_not_coprime_AB`: Beal's common-factor conclusion holds whenever the bases are not coprime (reuses the catalog `PrimitiveReduction` engine).

The file includes the requested `-- !-- ... -- !--` proof-sketch blocks for each theorem and a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis).

**`FUTURE_DIRECTIONS.md`** — a narrative synthesis plus five bold, falsifiable research directions (obstruction modulus for every odd-exponent triple; a residue-density equivalence for Beal; polynomial growth of the least obstructing modulus; collapse of obstructions when an exponent is 2, bridging to the Pythagorean catalog; and a certified `decide`-driven bounded verifier), each with a "The key insight is..." sentence and a "Why now?" justification.

All new modules build successfully and contain no `sorry`.