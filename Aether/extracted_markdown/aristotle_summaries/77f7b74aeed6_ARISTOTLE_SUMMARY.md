# Summary of changes for run 9b8a9c92-f127-417e-ba94-ce932b19a77b
Added a new Lean module `Catalog/Bridges/FisherMonotonicity.lean` that deepens the project's information-geometry programme (building on `Catalog/Bridges/FisherInformationRiemannian.lean` and `Catalog/Bridges/FisherCramerRao.lean`), plus `Catalog/Bridges/FUTURE_DIRECTIONS.md` with 5 follow-up research conjectures.

Fix to make the project buildable: the package's `lakefile.toml` was missing its source directory, so the existing `import Bridges.X` statements (files live under `Catalog/`) did not resolve. I added `srcDir = "Catalog"`, which fixes import resolution for the whole catalog.

New results, all proved from scratch over an arbitrary finite sample space (no `sorry`, no added axioms — each main theorem depends only on `propext`, `Classical.choice`, `Quot.sound`):

1. `cramer_rao_directional` — a directional / multiparameter Cramér–Rao bound: for any statistic `f` and any tangent direction `w`, `(E[f·(w·score)])² ≤ Var(f)·(wᵀGw)`. This generalizes the catalog's scalar `cramer_rao`, recovered as the one-parameter case `cramer_rao_of_directional`.

2. `fisher_monotone_coarsegrain` — Chentsov monotonicity / the data-processing inequality for the Fisher metric, in explicit quadratic-form: coarse-graining the sample space by any map `T : S → S'` can only decrease the Fisher quadratic form. The core is a per-fiber Cauchy–Schwarz (`fiber_cauchy_schwarz`) expressing the Jensen contraction of conditional expectation.

3. `pushModel` + `gfisher_pushModel_le` — the coarse-grained model `T_*M` is packaged as a genuine statistical model (under surjectivity of `T`), carrying the conditional-expectation score `E[score | T]`, and monotonicity is stated as the Loewner inequality `G(T_*M) ⪯ G(M)`. The scalar corollary `gfisher_pushModel_le_scalar` records that Fisher information cannot increase under any data-processing map.

Each theorem carries a one–two sentence proof sketch in `-- !-- ... -- !--` comment blocks and a descriptive docstring. The module compiles successfully; the only diagnostic is a cosmetic "unused simp argument" linter note of the same kind already emitted across the catalog and its dependencies.

The `FUTURE_DIRECTIONS.md` lists five falsifiable conjectures (the Loewner matrix Cramér–Rao bound, the equality case of monotonicity characterizing sufficient statistics, extension to Markov-kernel coarse-graining, Chentsov uniqueness of the Fisher metric, and the dual-affine / KL-Pythagorean geometry), each with a "key insight" and a "why now" justification tied to existing catalog results.