# Summary of changes for run 28c4070c-4f32-4d27-9080-836107d76903
Completed a full research cycle on the **Fibonacci rank of apparition** `z(m) = min{ k>0 : m ∣ F k }`, delivered as new Lean 4 code plus a research-directions narrative.

**New Lean file:** `Catalog/Applications/FibApparitionSelfIndex.lean`. It builds directly on the existing self-contained foundation `Catalog/Novelty/FibApparitionExistence.lean` (namespace `FibApparition`: the unconditional law of apparition `m ∣ F n ↔ z m ∣ n`). All results are `sorry`-free and depend only on `propext, Classical.choice, Quot.sound`.

Theorems proved (writing `z := FibApparition.apparitionRank`):
- `apparitionRank_lcm` — unrestricted join law `z(lcm a b) = lcm(z a, z b)` (no coprimality).
- `apparitionRank_monotone` — `a ∣ b → z a ∣ z b`.
- `apparitionRank_gcd_dvd` — meet bound `z(gcd a b) ∣ gcd(z a, z b)`.
- `apparitionRank_gcd_not_exact` — the meet bound is strict at `(4,6)`, so `z` is a join-morphism but not a meet-morphism.
- `apparitionRank_fib_self` — self-indexing `z(F n) = n` for `n ≥ 3` (sharp converse of `Nat.fib_dvd`); genuinely new relative to the catalog.
- `apparitionRank_fib_eq_self_iff` — the sharp form `z(F n) = n ↔ n ≠ 2`.

The file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and one-to-two-sentence `-- !-- ... -- !--` proof sketches on every theorem.

Why this re-derivation was needed: the prior catalog file `Catalog/Applications/FibonacciApparitionLattice.lean` states the lattice laws against a `Speculative.AutoResearch.FibonacciApparition` module whose source is absent from the repository, so it does not compile. The new file re-establishes the lattice morphism package against the buildable `FibApparition` foundation and adds the missing self-indexing theorem.

Notable correction (recorded in the notebook and FUTURE_DIRECTIONS): the floated conjecture that `z(m) = m` has solution set `{1,5}` is **false** — a computation shows the fixed-point set begins `1, 5, 12, 25, …` (`z(12)=12`, `z(25)=25`). Self-indexing only constrains moduli that are themselves Fibonacci numbers.

**`FUTURE_DIRECTIONS.md`** provides a freeform synthesis, a results table, and five falsifiable directions (each with a "The key insight is…" sentence and a "Why now?" justification): classifying the true self-apparition fixed-point set, the 2-adic structure of the gcd-defect, the prime-power tower / Wall–Sun–Sun link, transfer to general strong divisibility sequences, and a Pisano-period divisibility tower.

**Build note:** the project's `lakefile.toml` `lean_lib` globs pointed at root-level directories that do not exist (the sources live under `Catalog/`), so no target resolved. I added one `lean_lib` (`Applications`, `srcDir = "Catalog"`, globs `Applications.+`, `Novelty.+`) so the new and foundation modules build; it is not added to `defaultTargets`, leaving existing default behaviour unchanged. The new module compiles cleanly (verified with the build and an axiom check).