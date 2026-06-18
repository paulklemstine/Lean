# Summary of changes for run c81bab53-f994-40b8-97e2-6d71fd96732c
Created a complete, compiling Lean 4 file at `Catalog/Geometry/CoinductiveSelfSimilar.lean` formalizing coinductive self-similarity and geometric fixed points. Every requested result is stated with a full signature and proved with no `sorry` (verified to depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

Contents:
1. `geomStream a r : Stream' ℝ` — the geometric stream `a, a·r, a·r², …` defined via `Stream'.corec`, with its self-referential equation `geomStream_eq : geomStream a r = a :: geomStream (a*r) r` and helper lemmas `geomStream_head`, `geomStream_tail`.
2. `geomStream_get : (geomStream a r).get n = a * r ^ n` — closed form (induction).
3. `geomStream_selfSimilar : Stream'.map (· * r) (geomStream a r) = (geomStream a r).tail` — the central self-similarity result, proved using `Stream'.coinduction` (heads agree; tails agree, where the circular structure resolves).
4. `map_geomStream : Stream'.map (· * c) (geomStream a r) = geomStream (a*c) r` — rescaling.
5. `affineMap r b x = r*x + b`, `affineFix r b = b/(1-r)`, with `affine_fixed` (it is a fixed point) and `affine_fixed_unique` (uniqueness), both for `r ≠ 1`.
6. `contraction_fixed_point` — the Banach contraction principle on ℝ (`∃! x, f x = x` for a strict contraction), with existence via Mathlib's `ContractingWith.exists_fixedPoint` and uniqueness from the contraction inequality directly.
7. `affine_converges` — geometric convergence of the affine iteration to its fixed point in the ε–N form, using a helper `affineMap_iterate_sub : (affineMap r b)^[n] x₀ - affineFix r b = r^n * (x₀ - affineFix r b)` plus `tendsto_pow_atTop_nhds_zero_of_abs_lt_one`.

The file uses `Stream'.corec`, `Stream'.coinduction`, `Stream'.get/map/tail/head` and Mathlib's metric/limit API as requested, and imports `Mathlib`. It compiles against the project's prebuilt Mathlib. Note: the repository's catalog-wide `lake build` currently fails due to a pre-existing unrelated missing source file (`Catalog/Algebra/SpectralNovelty/CutMetric.lean`); this new file itself elaborates cleanly and is placed under the `Geometry` library (module `Geometry.CoinductiveSelfSimilar`).