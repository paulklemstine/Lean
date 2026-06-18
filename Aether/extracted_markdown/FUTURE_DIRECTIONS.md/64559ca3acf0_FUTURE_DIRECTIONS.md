# Future Directions: Completing Amari's Dually-Flat Geometry in Lean

The new module `Catalog/Bridges/ExponentialFamilyBregmanBridge.lean` closes the
loop between three previously disconnected catalog developments — the Riemannian
Fisher metric (`Bridges.FisherInformationRiemannian`), the abstract Bregman /
mirror-descent machinery (`Bridges.InformationGeometryOptimization`), and the
exponential-family scaffolding (`Geometry.InformationGeometry.Defs`). The keystone
identity `KL_expFamily_eq_bregman` shows that, for an exponential family, the
statistical Kullback–Leibler divergence **is** the convex-analytic Bregman
divergence of the log-partition function `ψ`, with gradient the expectation
parameter `η = ∇ψ`. From this single equation we obtained convexity of `ψ`
(`logPartition_convex`), the Fisher = covariance identity (`fisher_expFamily_eq_cov`),
and the generalized Pythagorean theorem (`KL_expFamily_pythagorean`). The
following directions extend that frontier.

## 1. The Legendre duality `η ↔ θ` and the dual (mixture) coordinate KL

Prove that the expectation map `η = ∇ψ` is a bijection from natural parameters to
the interior of the marginal polytope, with inverse `θ = ∇φ` where `φ` is the
negative Shannon entropy (the convex conjugate of `ψ`), and that the *same* KL
divergence equals the Bregman divergence of `φ` in the dual coordinates:
`KL(p_θ ‖ p_θ') = D_φ(η(θ) ‖ η(θ'))`. This is the dually-flat structure: KL is a
*canonical* divergence expressible in either coordinate chart.

The key insight is that the keystone identity already gives one half of the
Fenchel–Young equality `ψ(θ) + φ(η) = ⟨θ, η⟩`; differentiating it (using
`fisher_expFamily_eq_cov` to show `∇²ψ = Cov(T) ≻ 0`, hence `∇ψ` is a local
diffeomorphism) yields the inverse map and the dual Bregman form by a purely
formal Legendre transform argument.

Why now? Convex conjugation, `Real.add_pow_le_pow_mul_pow_of_sqrt`-style Fenchel
inequalities, and the implicit/inverse function theorem are all available in
Mathlib at this version, and the positive-definiteness of the Hessian that makes
the Legendre transform well-defined is now a *proved* catalog fact rather than an
assumption.

## 2. Pythagorean projection ⇒ existence and uniqueness of the I-projection

Upgrade `KL_expFamily_pythagorean` from an identity-under-orthogonality into an
existence/optimality theorem: for a closed convex constraint set `C` in the
expectation-parameter polytope, the KL-minimizer (information projection) `θ*`
exists, is unique, and is characterized by the orthogonality condition that makes
the Pythagorean relation hold for every competitor.

The key insight is that `logPartition_convex` makes `θ ↦ KL(p_θ ‖ p_θ')` a
strictly convex coercive function on the open natural-parameter domain, so a
minimizer over a closed convex `C` exists by the direct method and the
first-order optimality condition is *exactly* the orthogonality hypothesis already
isolated in `KL_expFamily_pythagorean`.

Why now? The strict convexity needed for uniqueness is the just-proved
`fisher_expFamily_eq_cov` (positive-definite Hessian), and Mathlib's
`InnerProductSpace` / convex-optimization API (`IsCompact.exists_isMinOn`,
`StrictConvexOn`) is mature enough to discharge existence and uniqueness without
new analytic infrastructure.

## 3. Chentsov uniqueness from Markov-morphism invariance

Formalize a finite version of Chentsov's theorem: among all families of symmetric
positive-semidefinite `(0,2)`-tensors on finite statistical simplices that are
*monotone non-increasing under stochastic (Markov) maps* and additive over
independent products, the Fisher metric is unique up to a positive scalar.

The key insight is that the catalog already contains both invariance ingredients
in usable form — tensoriality / congruence transformation
(`FisherCramerRao.gfisher_reparam`) and additivity over independent data
(`FisherCramerRao.gfisher_prod_eq`) — so Chentsov's characterization reduces to
showing that monotonicity under the two generating classes of Markov morphisms
(permutations and deterministic coarse-grainings) pins down the tensor on a
spanning set of tangent directions.

Why now? `FisherMonotonicity.lean` already proves the data-processing/monotonicity
direction for the Fisher metric; combining it with the existing reparametrization
and tensorization lemmas means the *hard analytic content is done* and the
remaining work is the linear-algebra rigidity argument over the finite simplex.

## 4. Cramér–Rao efficiency ⇔ exponential family (a converse bridge)

The catalog's `FisherCramerRao.cramer_rao_equality_iff` shows that an estimator is
efficient iff its centered value is proportional to the score *at a point*.
Conjecture the global converse: a one-parameter model admitting a uniformly
efficient unbiased estimator (equality in Cramér–Rao for all `θ`) must be an
exponential family with that estimator as its natural sufficient statistic.

The key insight is that pointwise proportionality `T − E_θ[T] = c(θ)·score_θ` is a
separable ODE for `log p`; integrating in `θ` forces `log p(x;θ) = a(θ)T(x) + b(θ)
+ k(x)`, which is precisely the exponential-family form, and `fisher_expFamily_eq_cov`
identifies the resulting Fisher information with `Var(T)`.

Why now? The local equality case is already a proved catalog theorem, and the
score is here a finite explicit object, so the "integrate the ODE" step becomes a
finite telescoping/summation argument rather than a genuine differential-equations
problem — exactly the regime the theorem prover handles well.

## 5. Second-order expansion: KL ≈ ½ Fisher quadratic form

Prove the local quadratic approximation `KL(p_θ ‖ p_{θ+εv}) = ½ ε² ⟨v, G(θ) v⟩ +
o(ε²)` for exponential families, making rigorous the slogan "the Fisher metric is
the infinitesimal KL". Concretely: the Hessian at `θ` of `θ' ↦ KL(p_θ ‖ p_θ')` is
the Fisher matrix.

The key insight is that, via `KL_expFamily_eq_bregman`, this is the second-order
Taylor expansion of the *single smooth function* `ψ` whose Hessian is, by
`fisher_expFamily_eq_cov`, exactly `Cov(T) = G`; so the statistical statement
collapses to a one-line consequence of Taylor's theorem applied to `ψ`.

Why now? Mathlib's `taylorWithinEval` / `HasFTaylorSeriesUpTo` and the
`iteratedFDeriv` calculus are available, and the only model-specific fact needed —
that `∇²ψ` is the Fisher metric — is now proved, so the remaining step is a generic
smooth-function Taylor expansion rather than bespoke probabilistic analysis.
