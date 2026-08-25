# Computational evidence — exp569b pooling audit (round-75 #3, paper 220)

All numbers below were produced with Lean `#eval` (exact `ℚ` where marked, IEEE `Float`
otherwise) before the formal statements were written; each one is reproduced by a theorem in
`Catalog/Physics/`.  Nothing here is taken from a scratch script outside Lean.

## 1. Reported rates (rounding-slip check)

| quantity | exact evaluation | reported in run log |
|---|---|---|
| cut_1e5 point ratio `2280/2348` | `0.971039…` | `0.9710` (earlier print `0.981` was the rounded-numerator slip) |
| cut_1e6 point ratio `37255/38718` | `0.962214…` | `0.9623` |

The exact rates confirm the corrected values, and the letter-of-rule verdict
(both cluster-bootstrap intervals cover `1`) is unaffected.

## 2. Variance inflation from a nested (shared-stream) pool — exact `ℚ`

`inflation nS nT = (3 nS + nT)/(nS + nT)` is the factor by which the honest variance of an
inverse-variance pool of a prefix leg `S ⊆ T` exceeds the reported variance
(`Design.nested_ivw_inflation`).

| configuration | `nS` | `nT` | inflation |
|---|---|---|---|
| exp569 prefix inside exp569b | `150 000` | `600 000` | **`7/5`** exactly |
| one dataset counted twice | `n` | `n` | **`2`** exactly |
| pilot population inside B's pool | `24` | `128` | `25/19 ≈ 1.316` |

Honest-vs-reported CI half-width at the `7/5` point: `√1.4 = 1.183216…`
(`Design.quarter_prefix_width_ratio` brackets this between `1.1832` and `1.1833`).

## 3. Does the pooled `z` survive?

Corrected two-leg inverse-variance joint over pilot `0.9468 ± 0.0449` and B `0.9623 ± 0.0208`
(`Float`):

```
pooled r        = 0.959561      (run log: 0.9596)
pooled sigma    = 0.018873      (run log: ~0.0189)
z = (1-r)/sigma = 2.142644      (run log: ~2.14)
```

Paying for the shared stream at the audited nesting:

```
2.14 / sqrt(7/5) = 1.808630  <  1.96
```

so the exclusion of `1` dissolves.  This is exactly
`Design.gate_retracted_at_quarter_prefix`.

## 4. Nested pooling is worse than discarding the prefix — exact `ℚ`

`poolVsLong nS nT = (3 nS + nT) nT / (nS + nT)²` is the honest variance of the nested
inverse-variance pool divided by the variance of the long leg alone.

| `nS` | `nT` | ratio |
|---|---|---|
| `150 000` | `600 000` | `28/25 = 1.12` |
| `n` | `n` | `1` |

So the retracted three-leg joint was not merely mis-stated: at the audited geometry the pooled
estimator carried **12% more variance** than simply reporting exp569b.  Formalised as
`Design.nested_pool_worse_than_large_leg` and, at the optimum, `nested_optimal_weight_is_zero`.

## 5. How much of the 76.8M pairs is information?

Effective sample size `n_eff = k m / (1 + (m-1)ρ)` for the run's `k = 128` moduli and
`m = 600 000` samples per modulus (`Float`):

| intra-modulus correlation `ρ` | `n_eff` | vs nominal `76.8M` |
|---|---|---|
| `10⁻²` | `12 797.9` | `0.017%` |
| `10⁻³` | `127 787` | `0.17%` |
| `10⁻⁴` | `1 259 018` | `1.6%` |

The ceiling `n_eff ≤ k/ρ` is independent of `m`
(`ClusterModel.effectiveSampleSize_le`, `exp569b_effective_size_bound`), which is why the
cluster bootstrap over `128` moduli — not a naive interval over `76.8M` pairs — is the correct
uncertainty and why the decisive next leg must vary the master seed rather than lengthen the
run.

## 6. Counterexample hunt

The two claims most at risk of being false were tested before formalising:

* *"Naive pooling of a prefix with its superset is at least as good as the superset alone."*
  **False** — refuted at `nS = 1, nT = 4` (`28/25 > 1` above); the honest variance is larger.
  The Lean statement therefore asserts the inequality in the opposite direction.
* *"The corrected two-leg exclusion survives any reasonable correlation correction."*
  **False** at the audited nesting: `2.14/√1.4 < 1.96`.  The exclusion needs the legs to be
  independent, which the stream reconstruction denies.

No counterexample was found to the master bound `Var ≥ σ²/|U|` (§ `DistinctDrawBound.lean`);
it is proved in general from Chebyshev's sum inequality.

## 7. Second-cycle checks (population overlap and optimal weights)

Two further claims were checked numerically before formalising.

* **Population overlap.** With `24` pilot moduli nested in `B`'s `128` and *no shared draws*,
  the covariance predicted by the two-level identity is `ρσ²/128`, not `0`.  At an
  intra-modulus correlation of `ρ = 10⁻²` and unit `σ`, that is `7.8 × 10⁻⁵` — small in
  absolute terms but of the same order as the pooled variance `σ² ≈ 3.6 × 10⁻⁴` implied by the
  reported `σ = 0.0189`, i.e. a non-negligible fraction of the very quantity the exclusion
  rests on.  Formalised as `PopDesign.cov_legMean_of_nested_population` and, as a strict
  inequality, `cov_legMean_pos_of_nested_population`.
* **Optimal weights.** For the nested pair `v₁ = σ²/150000`, `v₂ = c = σ²/600000`, the GLS
  weight `(v₂ - c)/(v₁ + v₂ - 2c)` evaluates to `0` exactly, with floor `σ²/600000` — the long
  leg alone.  For a disjoint pair of equal size it evaluates to `1/2`, the inverse-variance
  weight.  Both are theorems: `Design.gls_weight_of_nested_eq_zero`,
  `Design.gls_weight_of_disjoint_eq_ivw`.
