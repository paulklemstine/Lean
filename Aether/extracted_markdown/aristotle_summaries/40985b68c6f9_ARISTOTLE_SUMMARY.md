# Summary of changes for run 4743ee35-3fcb-420f-bdc1-a03a1cafb108
## Hilbert 16 — Topology of Algebraic Curves: cycle deliverables

I extended the project's Hilbert-16 corner with new, fully-proved Lean theorems, filled the dangling `sorry`, and repaired the build. Everything below is verified to compile `sorry`-free and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### New Lean files (proofs + Lab Notebook + `-- !-- ... -- !--` proof sketches)

**`Catalog/Geometry/HarnackSharp.lean`** — sharp structure of the Harnack bound, building on `Geometry/GenusFormula.lean`:
- `planeCurveGenus_eq_choose`: the degree–genus formula as a binomial coefficient `g(d) = C(d-1,2)`.
- `planeCurveGenus_mono`, `harnackBound_mono`: monotonicity in the degree.
- `planeCurveGenus_strictMonoFrom`, `harnackBound_strictMonoFrom`: strict growth for `d ≥ 2`.
- `harnackBound_inj_from`: the Harnack bound determines the degree on `{d ≥ 2}`.

**`Catalog/Geometry/OvalParity.lean`** — parity partition and acyclicity of the nesting forest, building on `Geometry/OvalArrangement.lean` and `Geometry/GenusFormula.lean`:
- `ConcNestingForest.outer_inner_partition`: the even/odd (outer/inner) ovals partition the arrangement, `#even + #odd = n`.
- `ConcNestingForest.no_two_cycle`, `parent_ne_self`, `even_card_le`, `odd_card_le`: acyclicity/finiteness, with depth as a genuine rank.
- `OvalArrangement.numRoots_le_harnack`, `nested_le_genus`: root ovals obey the Harnack bound `g+1`, nested ovals are bounded by the genus `g`.

### Sorry filled
- `Bridges/ArrowCurvature/Defs.lean`: `arrow_curvature_conjecture`. I discovered its hypothesis (every profile has positive Condorcet curvature) is unsatisfiable — the constant profile yields a linear-order majority with zero curvature — so the statement is vacuously true; the proof constructs that profile and derives the contradiction, documented in-file.

### Build repairs (the project was previously unbuildable)
- Added `srcDir = "Catalog"` to `lakefile.toml` so the source tree under `Catalog/` resolves.
- Fixed a stale import in `Geometry/HamiltonianBridge.lean` (`Geometry.Hilbert16.GenusFormula` → `Geometry.GenusFormula`).

### Other deliverable
- `FUTURE_DIRECTIONS.md`: synthesis, results table, and five falsifiable research directions (Petrovskii inequalities, Gudkov's congruence for M-curves, full well-founded forest acyclicity, a quantitative weak Hilbert-16 bound via the Melnikov/Hamiltonian corridor, and forest realizability via dimension counting), each with a "key insight" and "why now" justification.

Note: a few unrelated pre-existing `sorry`s remain in other domains (e.g. the infinite-tail case of Carmichael's primitive-prime-divisor theorem and Miller–Rabin bounds); these are outside the Hilbert-16 research direction and are genuinely deep results, so I left them untouched.