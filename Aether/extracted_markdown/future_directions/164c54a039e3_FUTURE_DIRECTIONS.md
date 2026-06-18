# Future Directions — The KL–Bregman–Fisher Bridge

## Synthesis

This research cycle attacked the concept *"Information-Geometric Bridge: Fisher
Metric on Statistical Manifolds"* not by re-proving the Fisher-metric axioms (the
catalog already contains `Bridges/FisherInformationRiemannian.lean`, which builds the
Fisher metric from scratch and proves symmetry, positive-(semi)definiteness, the
score-covariance identity, the two-forms-of-Fisher Hessian identity, and Gibbs'
inequality), but by **connecting three previously disjoint islands** of the catalog:

1. `Geometry/InformationGeometry/Defs.lean` — a rich but **theorem-free** definition
   file (exponential families, `logPartition`, `expectationParameter`, `fisherMatrix`,
   `sufficientStatCov`, the Amari–Chentsov tensor, α-connections). An orphan.
2. `Bridges/FisherInformationRiemannian.lean` — the concrete Fisher/KL constructions.
3. `Bridges/InformationGeometryOptimization.lean` — the abstract `BregmanDivergence`
   of a convex potential, with `bregman_three_point` and `bregman_nonneg`.

The new module `Bridges/ExponentialFamilyBregmanKL.lean` is the bridge. Its
keystone, `klDiv_expFamily_eq_bregman`, proves the classical identity

> KL(p_θ ‖ p_θ') = ψ(θ') − ψ(θ) − ⟨θ' − θ, η(θ)⟩,

i.e. the Kullback–Leibler divergence between two members of an exponential family is
*exactly* the Bregman divergence of the log-partition function ψ, with gradient the
expectation parameter η = E[T]. Around it we proved that the orphaned
`sufficientStatCov` **is** the Fisher information of the canonical score
(`expFamily_fisher_eq_sufficientStatCov`), that it is therefore a symmetric
positive-semidefinite Riemannian tensor, and — as a free corollary of Gibbs'
inequality through the bridge — that ψ is convex with gradient η
(`logPartition_convex_firstOrder`). The slogan the cycle establishes is: *the Fisher
metric is the Hessian, and the KL divergence is the Bregman divergence, of one and the
same convex potential ψ.*

## Results Summary

Module `Bridges/ExponentialFamilyBregmanKL.lean` (sorry-free; axioms: `propext`,
`Classical.choice`, `Quot.sound`):

- `log_expFamilyPmf` — `log p_θ(ω) = ⟨θ,T(ω)⟩ + k(ω) − ψ(θ)`.
- `expFamily_score_mean_zero` — the canonical score `T − η` has zero mean.
- `expFamily_fisher_eq_sufficientStatCov` — Fisher information = covariance of the
  sufficient statistic (closes the orphan definitions of `Defs.lean`).
- `sufficientStatCov_symm`, `sufficientStatCov_posSemidef` — the covariance/Fisher
  tensor is a symmetric PSD metric.
- `klDiv_self_zero`, `klDiv_nonneg` — Gibbs' inequality over an arbitrary finite
  sample space (generalizing the `Fin n` version in the catalog).
- `klDiv_expFamily_eq_bregman` — **the centerpiece KL = Bregman identity.**
- `logPartition_convex_firstOrder` — convexity of the log-partition function.

## Research Directions for the Next Cycle

### 1. The Hessian identity: ∂²ψ = Fisher = Cov(T)

We proved the *integrated*, first-order convexity inequality
`logPartition_convex_firstOrder`. The local, infinitesimal companion is the cumulant
identity `∂_i∂_j ψ(θ) = Cov(T_i, T_j) = fisherMatrix(θ)_{ij}` — the precise statement
that the Fisher metric is literally the Hessian of ψ. This is a falsifiable target:
verify `HasFDerivAt`/`fderiv` of `θ ↦ logPartition E θ` equals `expectationParameter`,
and the second derivative equals `sufficientStatCov`. **The key insight is** that
log-sum-exp is smooth and its first two derivatives are the normalized first and
second cumulants, so the proof reduces to differentiating
`Real.log (∑ exp(⟨θ,T⟩+k))` coordinatewise — no measure theory needed on a finite
sample space. **Why now?** We have already isolated ψ as the master potential and
proved its first-order convexity *algebraically*; the only missing ingredient is
Mathlib's `Real.exp`/`Real.log` derivative API, which is fully available, so the gap
is purely a calculus bookkeeping exercise rather than new mathematics.

### 2. Cramér–Rao from positive-semidefiniteness

The catalog has `Bridges/FisherCramerRao.lean` and
`MachineLearning/PadicCramerRao.lean`, but the Euclidean Cramér–Rao bound is not yet
derived from the *constructed* Fisher matrix of this cycle. Conjecture: for any
unbiased estimator with score covariance equal to `sufficientStatCov`, the estimator
variance dominates the inverse Fisher information, i.e. `Var(θ̂) ⪰ I(θ)⁻¹` in the
Loewner order. **The key insight is** that Cramér–Rao is *nothing but* the
Cauchy–Schwarz/positive-semidefiniteness of the joint covariance of the estimator and
the score — exactly the `sufficientStatCov_posSemidef` engine of this cycle applied to
the augmented `(θ̂, score)` vector. **Why now?** We just proved Fisher = score
covariance and Fisher PSD; the CR bound is one Schur-complement away and would unify
the two orphaned Cramér–Rao files under a single constructed metric.

### 3. The generalized Pythagorean theorem for KL

`InformationGeometryOptimization.lean` proves the Bregman three-point identity
`bregman_three_point`. Via `klDiv_expFamily_eq_bregman`, that identity now transfers
verbatim to KL: `KL(p‖r) = KL(p‖q) + KL(q‖r) + ⟨∇ψ(q) − ∇ψ(r), θ_p − θ_q⟩`.
Conjecture: when q is the e-projection of p onto an m-flat submanifold containing r,
the cross term vanishes and `KL(p‖r) = KL(p‖q) + KL(q‖r)` (the information-geometric
Pythagorean theorem). **The key insight is** that "e/m-orthogonality" is precisely the
statement that the cross term `⟨∇ψ(q) − ∇ψ(r), θ_p − θ_q⟩` is zero, so the deep
geometric theorem collapses to an *algebraic* vanishing condition we can state and
discharge with the bridge already in hand. **Why now?** The KL = Bregman identity
makes the catalog's existing `bregman_three_point` immediately applicable to genuine
statistical divergences for the first time.

### 4. Legendre duality and the dual (negentropy) potential

η = ∇ψ maps natural parameters θ to mean parameters. Conjecture: under strict
convexity of ψ this map is injective, its image is the open marginal polytope, and the
Legendre dual ψ*(η) = ⟨θ,η⟩ − ψ(θ) is the *negative Shannon entropy* of p_θ, with
`KL(p_θ‖p_θ')` expressible as the Bregman divergence of ψ* in mean coordinates.
**The key insight is** that the same KL = Bregman identity, read in the dual chart,
turns the entropy into the convex potential — the two flat affine structures (e-flat in
θ, m-flat in η) are Legendre-conjugate, and `logPartition_convex_firstOrder` is exactly
the inequality certifying the conjugacy. **Why now?** We have the primal potential and
its convexity; strengthening convexity to *strict* convexity (a one-line upgrade once
the Hessian identity of Direction 1 lands) immediately unlocks the Legendre transform.

### 5. Amari–Chentsov tensor = third cumulant, and α-flatness

`Defs.lean` defines `amariChentsovTensor` (the third moment of the score) and
`alphaChristoffel`, and `InformationGeometryOptimization.lean` poses `ExpFamilyEFlat`
as an open conjecture. Conjecture: the Amari–Chentsov tensor equals the third
derivative `∂_i∂_j∂_k ψ`, and consequently the e-connection (α = 1) Christoffel symbols
vanish in natural coordinates, proving `ExpFamilyEFlat`. **The key insight is** that
the cumulants of an exponential family are *exactly* the successive derivatives of ψ,
so the entire α-connection geometry is encoded in the Taylor expansion of the single
function we have now identified as the master potential. **Why now?** Directions 1 and
4 establish ψ's first and second derivatives as η and Fisher; pushing to the third
derivative is the natural next term of the same expansion, and it discharges a conjecture
already written into the catalog.
