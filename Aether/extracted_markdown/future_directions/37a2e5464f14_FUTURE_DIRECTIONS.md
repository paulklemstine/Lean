# Future Directions — Information-Geometric Bridge: Fisher Metric on Statistical Manifolds

## Synthesis

This cycle established, from first principles and with `sorry = 0`, that the
catalog's `fisherMatrix` (the second moment of the score, defined in
`Geometry.InformationGeometry.Defs`) is a *bona fide Riemannian metric* and wired
it to both statistical inference and the Kullback–Leibler divergence.  The new
module `Geometry.InformationGeometry.FisherRiemannian` proves:

- **The metric axioms.** `fisherMatrix_isHermitian` (symmetry) and
  `fisherMatrix_posSemidef` (positive-semidefiniteness), the latter via the
  Gram-matrix identity `fisher_quadForm_eq`: `vᵀ I(θ) v = ∑_ω p_ω · (v·s)²`.
- **The inference bridge.** `covarianceAt_sq_le` (weighted Cauchy–Schwarz) and
  `variance_dirScore_eq_quadForm` combine into `cramer_rao_directional`, the full
  multiparameter / directional Cramér–Rao bound
  `(Cov_θ(f, v·s))² ≤ Var_θ(f) · (vᵀ I v)`.
- **The divergence bridge.** `klDiv_self_zero` and `klDiv_nonneg` (Gibbs'
  inequality), establishing KL as a genuine divergence whose curvature is the
  Fisher metric.

The decisive structural lesson: *symmetry and positive-semidefiniteness require
no regularity at all* — they are pure Gram-matrix facts — whereas the mean-zero
score hypothesis (`RegularityHypotheses.score_mean_zero`) is exactly what upgrades
Cauchy–Schwarz into Cramér–Rao and identifies Fisher with the score covariance
(`fisherMatrix_eq_score_cov`).  This cleanly separates the *geometry* of the
manifold from the *statistics* of estimation.

## Results Summary

| Theorem | Statement | Hypotheses |
|---|---|---|
| `fisher_quadForm_eq` | metric = expected squared directional score | none |
| `fisherMatrix_isHermitian` | metric tensor is symmetric | none |
| `fisherMatrix_posSemidef` | metric tensor is PSD | none |
| `fisherMatrix_eq_score_cov` | Fisher = score covariance | mean-zero score |
| `covarianceAt_sq_le` | weighted Cauchy–Schwarz | none |
| `variance_dirScore_eq_quadForm` | `Var(v·s) = vᵀ I v` | mean-zero score |
| `cramer_rao_directional` | multiparameter Cramér–Rao | mean-zero score |
| `klDiv_self_zero` | `D(p‖p) = 0` | none |
| `klDiv_nonneg` | `D(p‖q) ≥ 0` (Gibbs) | `q > 0` |

## Research Directions

### 1. Strict positive-definiteness ⇔ score linear independence

`fisherMatrix_posSemidef` gives `≥ 0`; the metric is a *true* (non-degenerate)
Riemannian metric exactly when `vᵀ I v = 0 ⟹ v = 0`.  Conjecture: under
`RegularityHypotheses`, `(fisherMatrix M dlogp θ).PosDef` holds **iff** the score
components `{ω ↦ dlogp θ ω i}` are linearly independent in the weighted space
`L²(p_θ)`.  The key insight is that `fisher_quadForm_eq` already exhibits the
quadratic form as `∑_ω p_ω (v·s)²`, so degeneracy in direction `v` is *precisely*
the `p_θ`-a.e. vanishing of the directional score `v·s` — a kernel/identifiability
statement, not an analytic one.  Why now? The Gram-form identity is in hand and
`p_pos` makes the weighted inner product a genuine inner product, so PosDef
reduces to a finite-dimensional linear-independence check with no new analysis.

### 2. Cramér–Rao equality holds iff the estimator is affine in the score

`cramer_rao_directional` is Cauchy–Schwarz; equality in Cauchy–Schwarz is
proportionality.  Conjecture: `(Cov_θ(f, v·s))² = Var_θ(f) · (vᵀ I v)` (with
`Var_θ(f) > 0`) **iff** there exist scalars `a, b` with
`f ω = a + b·(v·s)(ω)` for `p_θ`-almost every `ω` (the efficiency / saturation
condition).  The key insight is that the proof already routes through
`Finset.sum_mul_sq_le_sq_mul_sq` on `√p·(f−Ef)` and `√p·(v·s)`, and Mathlib's
inner-product equality lemmas characterize the tight case by linear dependence of
those two vectors.  Why now? `covarianceAt_sq_le` isolates the exact Cauchy–Schwarz
instance, so the equality case is a localized add-on rather than a new inequality.

### 3. KL is locally the Fisher metric (second-order Taylor bridge)

For a *smooth* exponential family (`ExponentialFamily` in
`Geometry.InformationGeometry.Defs`), conjecture that the Hessian of
`θ' ↦ klDiv E.toStatModel θ θ'` at `θ' = θ` equals `fisherMatrix` at `θ`:
`D²_{θ'} D(p_θ ‖ p_{θ'})|_{θ'=θ} = I(θ)`.  The key insight is that for exponential
families `klDiv` is an explicit difference of log-partition functions plus a
linear term, and `logPartition` is smooth with Hessian equal to the
sufficient-statistic covariance — which `fisherMatrix_eq_score_cov` already
identifies with the Fisher matrix.  Why now? The KL functional and the exponential
family are both formalized here, and `fisherMatrix_eq_score_cov` supplies the
missing algebraic link, reducing the claim to differentiating `logPartition`
twice.

### 4. Chentsov monotonicity rebuilt on the `Defs` foundation

The catalog file `Bridges/FisherMonotonicity.lean` proves the data-processing
inequality but imports a non-existent `Bridges.FisherCramerRao`, so it does not
compile.  Conjecture: the entire monotonicity programme (`fiber_cauchy_schwarz`,
`fisher_monotone_coarsegrain`, the Loewner inequality `vᵀ I(T_*M) v ≤ vᵀ I(M) v`)
can be re-derived against the *compiling* `FiniteStatModel` / `fisherMatrix` API
used here, using `fisher_quadForm_eq` to express both forms as weighted sums of
squared scores.  The key insight is that coarse-graining by a statistic `T` is a
fibrewise conditional expectation, and the contraction is exactly the same
weighted Cauchy–Schwarz (`covarianceAt_sq_le` / `Finset.sum_mul_sq_le_sq_mul_sq`)
that already powers the Cramér–Rao bound.  Why now? The PSD/Gram infrastructure is
proven and stable, so monotonicity becomes a reuse of existing lemmas rather than
a fresh build on broken foundations.

### 5. α-connections: the dual-flat structure of exponential families

`Defs` defines `amariChentsovTensor` and `alphaChristoffel` but proves nothing
about them.  Conjecture: for an exponential family in its natural parameters the
(+1)-connection is flat (`PlusOneFlat`), i.e. the +1-Christoffel symbols vanish,
and dually the expectation parameters give a (−1)-flat coordinate system, with
`fisherMatrix` the metric relating the two.  The key insight is that the
Amari–Chentsov tensor is the third score moment, which for an exponential family
equals the third derivative of `logPartition`; flatness is then a vanishing-
coordinate statement provable from the explicit `expFamilyPmf`.  Why now? The
cubic tensor, the connection, and the flatness predicate already exist in `Defs`
and the score-moment identities developed this cycle (`fisher_quadForm_eq`,
`fisherMatrix_eq_score_cov`) are the degree-2 base case of exactly the moment
computation the degree-3 claim needs.
