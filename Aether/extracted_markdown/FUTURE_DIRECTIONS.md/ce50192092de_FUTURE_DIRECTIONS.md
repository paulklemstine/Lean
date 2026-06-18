# Future Directions — Information Geometry: The Riemannian / KL Bridge

## Synthesis

This cycle closed the *structural core* of the bridge between mathematical
statistics and Riemannian / convex geometry on a finite sample space, building on
the existing `Geometry.InformationGeometry.Defs` API and the catalog's
`Bridges.FisherMonotonicity` (Chentsov data-processing for the Fisher metric).
The new file `RiemannianBridge.lean` proves six results, organized around three
pillars:

1. **Metric axioms.** `fisherMatrix_quadForm_nonneg` (positive semidefiniteness)
   and `fisherMatrix_isSymm` (symmetry) together establish that the Fisher
   information matrix is a symmetric PSD bilinear form on each tangent space — a
   Riemannian metric on the statistical manifold. Positive *semi*-definiteness is
   unconditional; strict definiteness is exactly parameter identifiability.

2. **Exponential-family Hessian identity.** `expFamily_fisher_eq_cov` proves that,
   with the canonical score `sᵢ = Tᵢ − ηᵢ(θ)`, the Fisher metric equals the
   covariance of the sufficient statistic, `I(θ) = Cov_θ(T) = ∇²ψ(θ)`. The
   companion `expFamilyScore_mean_zero` certifies the canonical score is a genuine
   (mean-zero) score, validating the abstract `RegularityHypotheses` interface.

3. **KL = Bregman divergence of the log-partition.** `expFamily_kl_eq_bregman`
   identifies the Kullback–Leibler divergence with the Bregman divergence of the
   convex potential `ψ`, `D_KL(p_θ ‖ p_θ') = ψ(θ') − ψ(θ) − ⟨η(θ), θ'−θ⟩`. The
   companion `kl_nonneg` (Gibbs' inequality) shows KL ≥ 0; combined with the
   Bregman identity, this is a coordinate-free certificate that `ψ` is convex and
   that KL is the canonical divergence of the dual-flat (Amari) geometry.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fisherMatrix_quadForm_nonneg` | Fisher form is PSD: `vᵀ I(θ) v ≥ 0` | proved, axiom-clean |
| `fisherMatrix_isSymm` | Fisher matrix is symmetric | proved, axiom-clean |
| `expFamilyScore_mean_zero` | canonical score has zero mean | proved, axiom-clean |
| `expFamily_fisher_eq_cov` | `I(θ) = Cov_θ(T) = ∇²ψ(θ)` | proved, axiom-clean |
| `expFamily_kl_eq_bregman` | `D_KL = B_ψ` (KL is Bregman of `ψ`) | proved, axiom-clean |
| `kl_nonneg` | Gibbs' inequality `D_KL ≥ 0` | proved, axiom-clean |

## Research Directions

### 1. Convexity of the log-partition from the Hessian identity

Combine `expFamily_fisher_eq_cov` (`∇²ψ = Cov_θ(T)`) with
`fisherMatrix_quadForm_nonneg` (Cov is PSD) to conclude that the log-partition
function `ψ` is convex on the whole natural-parameter space, and *strictly* convex
exactly when the sufficient statistic `T` is affinely independent (minimal
family). **The key insight is** that convexity of `ψ` is not an analytic accident
but the integral shadow of a single pointwise inequality — the nonnegativity of a
variance — so the proof should never differentiate twice: it should lift the PSD
covariance form directly to a `ConvexOn ℝ Set.univ ψ` statement via the
second-order-increment characterization. **Why now?** Both halves already exist in
this file as standalone, axiom-clean lemmas; the only missing piece is the
finite-difference convexity criterion, which `Bregman ≥ 0` (`kl_nonneg` +
`expFamily_kl_eq_bregman`) already supplies in disguise.

### 2. The Pythagorean / projection theorem for KL divergence

Prove the information-geometric Pythagorean identity: for an exponential family,
`D_KL(p_a ‖ p_c) = D_KL(p_a ‖ p_b) + D_KL(p_b ‖ p_c)` whenever the natural
parameters satisfy the orthogonality condition `⟨η(a) − η(b), b − c⟩ = 0`. **The
key insight is** that, once KL is rewritten as the Bregman divergence of `ψ`
(`expFamily_kl_eq_bregman`), the entire statement collapses to the three-point
Bregman identity, which is *pure algebra* in `ψ`, `η`, and the inner product — no
geometry, no limits. **Why now?** `expFamily_kl_eq_bregman` reduces the
transcendental KL object to the polynomial Bregman object, so the Pythagorean
theorem becomes a `linear_combination`-style identity that the subagent can
discharge directly; it is the natural next theorem once divergence-as-Bregman is in
hand.

### 3. Cramér–Rao as a Loewner bound via the covariance identity

Re-derive the multiparameter Cramér–Rao inequality directly inside this file by
feeding `expFamily_fisher_eq_cov` into a Cauchy–Schwarz argument on the covariance
form, obtaining `Cov_θ(f) ⪰ ∇η(θ)ᵀ I(θ)⁻¹ ∇η(θ)` in the Loewner order for any
unbiased estimator `f`. **The key insight is** that for exponential families the
Fisher matrix and the estimator's sensitivity are *the same covariance object*
evaluated on different vectors, so the bound is a single application of the
Cauchy–Schwarz operator inequality rather than a regularity-laden limiting
argument. **Why now?** The catalog already has the directional Cramér–Rao bound in
`Bridges.FisherMonotonicity` (`cramer_rao_directional`); pairing it with the new
`expFamily_fisher_eq_cov` would unify the inference bound and the geometric metric
into one covariance-based statement, closing the loop between the two files.

### 4. Chentsov monotonicity specialized to the exponential-family metric

Instantiate the catalog's `FisherMonotonicity.gfisher_pushModel_le` (Chentsov
data-processing) on the exponential-family Fisher metric produced here, proving
that coarse-graining by a sufficient statistic leaves `Cov_θ(T)` *invariant* while
any non-sufficient statistic strictly decreases it. **The key insight is** that
sufficiency is precisely the equality case of the fibrewise Cauchy–Schwarz that
powers Chentsov monotonicity, so the Fisher metric is constant along exactly the
maps that preserve `T` — turning Chentsov's qualitative "monotone" into a sharp
quantitative dichotomy. **Why now?** `expFamily_fisher_eq_cov` gives a closed-form
metric and `FisherMonotonicity` gives the monotonicity engine; bridging them would
produce the first *equality-characterization* of sufficiency in the catalog.

### 5. Dual flatness: the `e`-connection and `m`-connection are flat

Define the exponential (`e`) and mixture (`m`) affine connections from the
`amariChentsovTensor` already present in `Defs.lean`, and prove that for an
exponential family both connections are flat (their `alphaChristoffel` symbols
vanish at `α = ±1`), with `η` and `θ` as the two dual affine coordinate systems.
**The key insight is** that flatness of the `e`-connection is *literally* the
statement that `θ` is an affine coordinate, which is true by construction of the
exponential family — so dual flatness is a definitional unfolding plus the Hessian
identity `∇²ψ = I`, not a curvature computation. **Why now?** `Defs.lean` already
ships `amariChentsovTensor`, `alphaChristoffel`, and `PlusOneFlat`, and this cycle
supplies the missing metric/Hessian link; the dually-flat structure is the capstone
that turns the assembled pieces into the full Amari geometry.
