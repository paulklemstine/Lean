# Theorem Trace — Diffusion Models as SDEs (anti-hallucination ledger)

This internal file lists every theorem, lemma, and definition name appearing in
the Phase A Lean output (the source of truth), its mathematical statement, and
where it is referenced in `ARTICLE.md` and `RESEARCH_PAPER.md`. No result is
stated in the prose that is not in this table.

## From `FokkerPlanck.lean` (full source provided)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `gaussianDensity` | def | `gaussianDensity m v x = exp(-log(2πv)/2 - (x-m)²/(2v))`, exp-log Gaussian `N(m,v)` | yes | yes (Def 1) |
| `gaussian_pos` | thm | `0 < gaussianDensity m v x` | yes | yes (Prop) |
| `gaussianDensity_eq_sqrt` | thm | For `v>0`, `gaussianDensity m v x = (√(2πv))⁻¹ exp(-(x-m)²/(2v))` | yes | yes (Prop) |
| `hasDerivAt_gaussian_x` | thm | `∂ₓ p = p·(-(x-m)/v)` (density × score) | yes | yes (Lemma) |
| `gaussianDx` | def | `gaussianDx m v x = gaussianDensity m v x · (-(x-m)/v)` | — | yes (Def) |
| `hasDerivAt_gaussian_xx` | thm | `∂ₓₓ p = p·((x-m)²-v)/v²` | yes | yes (Lemma) |
| `hasDerivAt_gaussian_t` | thm | `∂ₜ p = p·((x-m)/v·m' + ((x-m)²-v)/(2v²)·v')` (two-parameter chain rule) | yes | yes (Lemma) |
| `ouDensity` | def | `ouDensity θ σ² m0 v0 x t = gaussianDensity (ouMean) (ouVar) x` | yes | yes (Def) |
| `ou_fokker_planck` | thm | `∂ₜ p = θ ∂ₓ(x·p) + (σ²/2) ∂ₓₓ p` for OU marginals (needs `θ≠0`, `v(t)>0`) | yes (MAIN) | yes (Thm, MAIN) |
| `stationary_fokker_planck` | thm | `L p∞ = 0` for `p∞ = N(0, σ²/2θ)` (stated in module header) | yes | yes (Thm) |

## From `OUProcess.lean` (referenced by future directions & imports)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `ouMean` | def | `m(t) = m0·e^{-θt}` | yes | yes (Def) |
| `ouVar` | def | `v(t) = v0·e^{-2θt} + (σ²/2θ)(1-e^{-2θt})` | yes | yes (Def) |
| `ouMean_hasDerivAt` | thm | `m'(t) = -θ·m(t)` | yes | yes (Lemma) |
| `ouVar_hasDerivAt` | thm | `v'(t) = -2θ·v(t) + σ²` | yes | yes (Lemma) |
| `ouMean_tendsto` | thm | `m(t) → 0` as `t→∞` | yes | yes (Thm) |
| `ouVar_tendsto` | thm | `v(t) → σ²/2θ` as `t→∞` | yes | yes (Thm) |

## From `ReverseTime.lean` (referenced by future directions)

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| (Gaussian Stein score) | thm | `∂ₓ log p = -(x-m)/v` for `N(m,v)` | yes | yes (Lemma) |
| `ou_reverse_fokker_planck` | thm | Anderson reverse-time FP with reverse drift `b = θx + σ²·score`, recovers data law | yes | yes (Thm) |

Notes:
- Only the moment ODEs, the spatial/temporal derivatives, the forward & stationary
  FP equations, the Gaussian score, the convergence limits, and the reverse-time
  FP equation are claimed. No quantitative convergence-rate or Girsanov bound is
  claimed as proved (those are listed only as future conjectures).
