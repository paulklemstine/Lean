# Future Directions: Parametric Fixed-Point Theory

## 1. Lipschitz Parametric Banach Theorem with Explicit Constants

The parametric continuity theorem (`parametric_fixedPoint_continuous`) establishes that the fixed-point map is continuous when the family varies continuously. A stronger result should hold: if the family `t ↦ F(t)` is Lipschitz in a metric parameter space with constant `L` (i.e., `dist(F(s)(x), F(t)(x)) ≤ L · dist(s,t)` uniformly in `x`), then `t ↦ x⋆(t)` is Lipschitz with constant `L/(1-K)`.

The key insight is that the bound `dist(x⋆(s), x⋆(t)) ≤ sup_x dist(F(s)(x), F(t)(x)) / (1-K)` already implicit in our proof gives the Lipschitz constant directly — no additional machinery is needed beyond plugging in the uniform Lipschitz hypothesis on the family.

Why now? The `contraction_fixedPoint_stability` theorem already handles the pointwise case. The upgrade to Lipschitz families is a one-line corollary once the uniform bound is formalized. This would directly connect to the implicit function theorem via the parametric contraction mapping approach.

## 2. Hölder Continuity of Fixed Points for Non-Uniformly Contracting Families

When the contraction factor itself varies with the parameter — `K(t) < 1` for each `t` but `sup_t K(t) = 1` — the fixed-point map may still be continuous but loses Lipschitz regularity. The conjecture is that if `K(t) ≤ 1 - c · dist(t, t₀)^β` for some `β > 0`, then the fixed-point map is Hölder continuous with exponent depending on `β`.

The key insight is that the denominator `1 - K(t)` in the stability bound degenerates as `K(t) → 1`, creating a singularity that Hölder regularity can still control. This bridges our sharp K=1 counterexample with the smooth K<1 theory.

Why now? The sharpness result (`contraction_sharpness`) precisely identifies where the theory breaks down. Understanding the transition region between K<1 (guaranteed fixed points) and K=1 (possible failure) requires exactly this Hölder analysis. Mathlib's `HolderWith` API provides the formalization target.

## 3. Equivariant Fixed Points for Group-Parametrized Families

If a group `G` acts on both the parameter space and the metric space, and the family of contracting maps is equivariant (`F(g·t)(g·x) = g · F(t)(x)`), then the fixed-point map should be equivariant as well (`x⋆(g·t) = g · x⋆(t)`). This would formalize the principle that symmetries of the causal structure are inherited by self-consistent solutions.

The key insight is that uniqueness of fixed points forces equivariance: since `g · x⋆(t)` is a fixed point of `F(g·t)` (by equivariance of the family), it must equal the unique fixed point `x⋆(g·t)`. The proof is a direct application of `fixedPoint_unique`.

Why now? The composition theorem (`ContractingWith.comp`) shows that the algebraic structure of contracting maps is well-behaved. Group equivariance is the natural next algebraic property to formalize, and connects to Mathlib's extensive `MulAction` framework.

## 4. Nadler's Theorem: Set-Valued Contractions

For a set-valued map `F : α → Closeds α` that is contracting under the Hausdorff metric (i.e., `hausdorffDist(F(x), F(y)) ≤ K · dist(x,y)` with `K < 1`), Nadler's theorem guarantees existence of a fixed point `x ∈ F(x)`. This generalizes the Banach theorem to nondeterministic dynamics.

The key insight is that the Banach iteration can be adapted: choose `x₁ ∈ F(x₀)` closest to `x₀`, then `x₂ ∈ F(x₁)` closest to `x₁`, etc. The contraction on the Hausdorff metric ensures this sequence is Cauchy, and the limit is a fixed point. The challenge is formalizing the "choose closest point" step using Mathlib's `EMetric.hausdorffDist`.

Why now? Mathlib has `EMetric.hausdorffDist` and `TopologicalSpace.Closeds`. The gap is connecting the Hausdorff metric contraction to pointwise fixed-point existence. Our parametric framework provides the template for handling the iteration argument.

## 5. Rate-Optimal Iteration for Non-Autonomous Contractions

Given a sequence of contracting maps `f₁, f₂, ...` with possibly different contraction factors `K_n < 1`, the composition `f_n ∘ ... ∘ f₁` converges to a unique "target" point. The conjecture is that the convergence rate is `∏ᵢ Kᵢ`, and when `∑ᵢ (1 - Kᵢ) = ∞`, convergence is guaranteed even though individual factors may approach 1.

The key insight is that `ContractingWith.comp` gives `K₁ · K₂` as the factor for the composition of two contractions. Iterating this, the composition of `n` maps has factor `∏ᵢ₌₁ⁿ Kᵢ`. The divergence condition `∑(1-Kᵢ) = ∞` ensures `∏ Kᵢ → 0`, guaranteeing convergence even in the non-stationary case.

Why now? The composition theorem is now proved, giving the base case. The extension to infinite products connects to Mathlib's `HasProd` API and provides convergence guarantees for adaptive algorithms where the contraction factor changes at each step (e.g., learning rate schedules in optimization).
