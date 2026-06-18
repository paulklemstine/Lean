# Summary of changes for run a2458b95-ee8b-4a40-91cb-5d8dffa9638b
Built a self-contained, sorry-free Lean 4 formalization of softmax policy-gradient geometry and baseline variance-reduction theory, in a new `Catalog/MachineLearning/PolicyGradient/` directory. The directory and the lemmas the concept note assumed existed (`variance_shift_invariant`, `baseline_objective_quadratic`) did not actually exist in the project, so the foundation was built from scratch in the catalog's finite-action (`Fin n`, real-sum, `expectVal`) style.

Deliverables produced:

1. `Catalog/MachineLearning/PolicyGradient/Foundations.lean` — differential geometry of softmax PG (6 theorems): `softmaxPolicy_pos`, `softmaxPolicy_sum_one`, `softmaxScore_expect_zero` (the REINFORCE/log-derivative identity `E_π[ψ_j]=0`), `fisherInfo_eq` (closed form `F_{jk}=π_j δ_{jk}−π_j π_k`), `fisherInfo_symm`, and `fisherInfo_psd` (PSD realized as a genuine variance `vᵀFv = E_π[(⟨v,ψ⟩)²] ≥ 0`).

2. `Catalog/MachineLearning/PolicyGradient/VarianceReduction.lean` — control-variate baseline theory (5 theorems): `baseline_unbiased`, `secondMoment_quadratic` (`M(b)=A b²−2B b+C`), `variance_reduction_amount` (the completed square `M(b)−M(b⋆)=A(b−b⋆)²`), `optimal_baseline_min`, and `optimal_baseline_strict` (uniqueness of `b⋆=B/A`).

3. `Catalog/MachineLearning/PolicyGradient/FUTURE_DIRECTIONS.md` — a freeform narrative with a synthesis, results summary, and 5 falsifiable research directions (variance ratio `1−ρ²`; state-dependent baseline `b⋆(s)=V^π(s)`; natural gradient as gauge projection via `𝟙∈ker F`; Bellman γ-contraction fixed point; Pinsker + softmax-positivity KL trust region), each with a "key insight is…" statement and a "Why now" justification.

Each Lean file contains a `-- !-- Lab Notebook -- !--` block (Hypothesis/Result/Insight/Failure analysis) and concise `-- !-- … -- !--` proof sketches per theorem.

Verification: all 11 theorems are proved with no `sorry`, `admit`, `axiom`, or `@[implemented_by]` (confirmed by search), and both files elaborate against the project's Mathlib with zero diagnostics. One statement (`softmaxPolicy_sum_one`) was found false as originally written (vacuously the empty sum is 0 at n=0) and was corrected by adding a `[NeZero n]` nonemptiness hypothesis, as documented in the Failure analysis. The unused probability-nonnegativity hypothesis was dropped from `optimal_baseline_strict` to keep the statement minimal. The files follow the existing catalog convention (placed under `Catalog/`, using `import Mathlib`).