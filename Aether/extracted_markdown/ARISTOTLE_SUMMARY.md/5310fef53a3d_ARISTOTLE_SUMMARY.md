# Summary of changes for run 6779599c-6f82-4b1d-be2f-fe4de532beaa
Added a complete, self-contained formalization of finite information geometry in `Catalog/MachineLearning/FiniteInfoGeometry.lean`, culminating in a theorem that statistical/geometric complexity is detected by Fisher rank. Everything compiles with no `sorry`, no warnings, and only the standard axioms.

Core definitions (namespace `FiniteInfoGeometry.FiniteStatModel`):
- `FiniteStatModel`: a finite statistical model on a `Fintype` sample space `Ω` and parameter type `Θ`, with `pmf : Θ → Ω → ℝ`, bundled nonnegativity (`pmf_nonneg`) and normalization (`pmf_normalized`), and score data `score : Θ → Ω → Fin n → ℝ`.
- `expectation`: the pmf-weighted expectation of an observable, a reusable building block.
- `fisherMatrix`: the Fisher information matrix `I θ i j = ∑_ω pmf θ ω · scoreᵢ · scoreⱼ` (a pmf-weighted Gram matrix), via `Matrix.of`.
- `weightedScore`: the matrix `S ω i = √(pmf θ ω) · scoreᵢ`, whose Gram matrix is the Fisher matrix.

Proved theorem package:
- `fisherMatrix_symm_apply` / `fisherMatrix_isSymm`: the Fisher matrix is symmetric.
- `fisherMatrix_eq_gram` / `fisherMatrix_eq_gram'`: the Gram decomposition `I = Sᵀ S` (and the `ᴴ` form, since over ℝ conjugate-transpose = transpose).
- `fisher_quadForm`: the explicit quadratic-form identity `vᵀ I v = ∑_ω pmf θ ω · (∑ᵢ scoreᵢ · vᵢ)²`.
- `fisher_quadForm_nonneg`: hence `vᵀ I v ≥ 0` (the requested coordinate quadratic-form nonnegativity).
- `fisherMatrix_posSemidef`: `Matrix.PosSemidef` for the Fisher matrix.
- `fisher_mulVec_zero_iff`: under full support, the kernel of the Fisher matrix equals the common annihilator of all score vectors — the geometric heart of the development.
- `fisherMatrix_rank_eq`: the rank of the Fisher matrix equals the rank of the weighted score matrix.
- `weightedScore_row_eq`: a helper identifying weighted score rows as scaled score vectors.
- `rank_fisherMatrix_ge`: the concrete lower bound — under full support, `k` linearly independent score vectors force `rank (fisherMatrix θ) ≥ k`.

There are no placeholder declarations or unfinished structures; no `logLik` or logarithm consistency axiom was introduced since none was needed.

I also fixed a pre-existing project configuration bug: `lakefile.toml` was missing `srcDir = "Catalog"` (all sources live under `Catalog/`), which prevented the libraries from building at all. Adding it makes the layout consistent with the existing `import` paths and lets the new module build via `lake build MachineLearning.FiniteInfoGeometry`.