# Future Directions: EML Category Theory

## Conjecture 1: Log-Affine Normal Form for the Multiplicative Positive Fragment

**Conjecture.** Every scalar EML expression on `PosVec n` built without addition is equivalent to a log-affine normal form `x ↦ exp(∑ᵢ wᵢ · log(xᵢ) + c)`.

More precisely: define the *multiplicative positive fragment* as the sub-inductive of `ScalarEML` restricted to `coord`, `posConst`, `mul`, `exp`, `log`, and `comp` (no `add`). Then every expression in this fragment, when restricted to positive inputs, agrees with a log-affine function.

**Test.** We have partially verified this in `LogAffineNormal.lean` for the `PosEMLExpr` syntax (coord, posConst, mul, rpow). To falsify the full conjecture, enumerate bounded-depth multiplicative EML expressions including compositions through intermediate spaces and check whether the log-affine normal form identity holds. A counterexample would be an expression using `exp` of a product (not a sum) that cannot be reduced to log-affine form.

**Impact.** If true, this gives a complete *decidable equivalence* for the multiplicative fragment: two expressions are equivalent iff their weight vectors and constants agree. This would yield a polynomial-time simplifier for a nontrivial fragment of symbolic computation.

---

## Conjecture 2: Parameterized Weak Cartesian Closure

**Conjecture.** For every `n, m, k`, every EML-computable family `(Fin k → ℝ) → ((Fin n → ℝ) → (Fin m → ℝ))` is representable by an EML-computable map on the combined input space `Fin (k + n) → ℝ → Fin m → ℝ`, and conversely.

That is, `VecEMLComp (k + n) m f` is equivalent to the existence of a curried family where for each `θ : Fin k → ℝ`, the specialized map `x ↦ f(θ, x)` is `VecEMLComp n m`. We have proved one direction (currying, `vecEMLComp_curry`). The uncurrying direction asserts that any "smoothly parameterized" EML family can be written as a single EML expression on the joint space.

**Test.** Construct an explicit EML family (e.g., `θ ↦ (x ↦ exp(θ₁ · x₁ + θ₂ · x₂))`) and verify that the joint map `(θ, x) ↦ exp(θ₁ · x₁ + θ₂ · x₂)` is `ScalarEML (k+n)`. Then search for families where uncurrying fails — these would be "non-representable" families.

**Impact.** Full weak Cartesian closure would make EML a genuine programming language semantics: every higher-order EML function decomposes into a first-order one on a combined input space. This connects to denotational semantics of differentiable programming languages.

---

## Conjecture 3: Tropical Limit of the Log-Affine Fragment

**Conjecture.** For a sum of log-affine expressions `f(x) = ∑ⱼ exp(∑ᵢ wⱼᵢ · log(xᵢ) + cⱼ)`, the tropical limit `limₜ→∞ (1/t) · log f(x^t)` equals `maxⱼ(∑ᵢ wⱼᵢ · log(xᵢ) + cⱼ)`.

This asserts that the "log-sum-exp" of log-affine functions tropicalizes to the piecewise-linear maximum of affine functions in log coordinates.

**Test.** For fixed weight matrices and constants, numerically compute `(1/t) · log(∑ⱼ exp(t · (∑ᵢ wⱼᵢ · yᵢ + cⱼ)))` as `t → ∞` and verify convergence to the pointwise maximum. A counterexample would require the limit to not exist or to differ from the maximum.

**Impact.** This would provide a formal bridge between EML computation and tropical geometry, connecting differentiable models to piecewise-linear optimization. It would formalize the "softmax → hardmax" limit used throughout machine learning.

---

## Conjecture 4: Analyticity of EML-Computable Maps

**Conjecture.** Every `ScalarEML n` function is real-analytic on its natural domain of definition (all of `ℝⁿ` for the full fragment, or `(ℝ₊)ⁿ` for the positive fragment with log).

**Test.** Prove by induction on the `ScalarEML` derivation that each constructor preserves analyticity: projections are polynomial (analytic), constants are analytic, sums/products of analytic functions are analytic, exp of analytic is analytic, and composition of analytic functions is analytic. This reduces to checking that Mathlib has `AnalyticAt` lemmas for each operation.

**Impact.** Analyticity would separate EML-computable functions from merely continuous ones, giving the category of EML maps a geometric character (analytic manifold morphisms). It would also imply that EML functions are determined by their Taylor series, enabling symbolic-numeric verification methods.

---

## Conjecture 5: EML Category as a Subcategory of Smooth Maps

**Conjecture.** Define `EML_Cat` as the category with objects `ℕ` (representing `Fin n → ℝ`) and morphisms `Hom(n, m) = {f : (Fin n → ℝ) → (Fin m → ℝ) | VecEMLComp n m f}`. Then the forgetful functor `EML_Cat → Diff` (to the category of smooth manifolds and smooth maps) is faithful and preserves finite products.

**Test.** Faithfulness requires showing that two EML-computable maps that agree as set-theoretic functions are equal as morphisms (trivial since morphisms are functions). Product preservation requires showing that the EML product `Fin (m+k) → ℝ` with projection/pairing maps agrees with the categorical product in `Diff`. The nontrivial content is that EML projections are smooth, which follows from analyticity (Conjecture 4).

**Impact.** This would embed EML computation into differential geometry, making tools from smooth manifold theory (tangent spaces, differential forms, Riemannian metrics) available for analyzing EML programs. It would ground differentiable programming in genuine differential geometry rather than ad hoc automatic differentiation.
