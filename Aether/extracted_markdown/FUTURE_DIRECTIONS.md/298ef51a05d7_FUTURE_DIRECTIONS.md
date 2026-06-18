# Future Directions: Idempotent Probability and Large Deviations

## 1. Fenchel–Moreau Biconjugate Theorem

We proved that the biconjugate satisfies f★★(x) ≤ f(x) for all x. The natural next step is the **Fenchel–Moreau theorem**: f★★ = f if and only if f is convex and lower semicontinuous. The key insight is that this requires formalizing lower semicontinuity in Lean 4 (which Mathlib has as `LowerSemicontinuous`) and connecting it to the `sSup` characterization of the conjugate. The forward direction (convex + lsc ⟹ f★★ = f) is the hard part, requiring the Hahn–Banach separation theorem for epigraphs.

**Why now?** We have the inequality direction proved. Mathlib already has `LowerSemicontinuous` and `ConvexOn`. The missing piece is the epigraph separation argument, which is within reach using `geometric_hahn_banach` from Mathlib.

## 2. Tropical Varadhan Lemma

Varadhan's lemma states that for a sequence of measures satisfying an LDP with rate function I, the limit of log-moment generating functions is the Legendre–Fenchel transform: lim (1/n) log E[exp(nφ(X))] = sup_x {φ(x) - I(x)}. The key insight is that this is precisely a tropical integral: the right-hand side is the max-plus expectation of φ under the idempotent measure exp(-I). Formalizing this would make the tropical–LDP connection constructive rather than merely algebraic.

**Why now?** We have `LegFen`, `CGF.rateFunction`, and the Young–Fenchel inequality. The next step is to define `IdempotentMeasure` as a function ℝ → ℝ≥0∞ satisfying max-plus σ-additivity, and show that Varadhan's limit is its tropical integral.

## 3. Max-Plus Spectral Theory for Random Walk Rate Functions

For a max-plus random walk S_n = max(X_1, ..., X_n), the rate function can be computed via the max-plus spectral radius of the transition operator. The key insight is that the Perron–Frobenius eigenvalue in the max-plus semiring gives the exponential growth rate, and its Legendre–Fenchel transform gives the LDP rate function. This connects our `CGF` structure to the existing `Tropical.PerronFrobenius` development in this project.

**Why now?** The project already has `Tropical/PerronFrobenius/` with max-plus eigenvalue theory. Bridging this to `CGF.rateFunction` would unify two existing formalizations and yield a genuinely new result about tropical spectral characterization of rate functions.

## 4. Idempotent Measure-Theoretic Foundation

Define a σ-algebra of "tropically measurable" sets and an idempotent measure μ : Σ → ℝ∪{-∞} satisfying μ(A ∪ B) = max(μ(A), μ(B)) for disjoint A, B (the max-plus analog of σ-additivity). The key insight is that the "density" of such a measure is exactly the negative rate function -I(x), and "tropical integration" ⊕_x f(x) ⊗ dμ(x) = sup_x {f(x) + μ(x)} recovers the Legendre–Fenchel transform as a special case.

**Why now?** Mathlib's measure theory is mature enough to serve as a template. We can define `IdempotentMeasure` as a `sSup`-valued set function and prove the tropical analog of Fatou's lemma: for a sequence f_n → f pointwise, sup_x{f(x)+μ(x)} ≤ liminf sup_x{f_n(x)+μ(x)}.

## 5. Cramér's Theorem via Tropical Convolution

The full Cramér theorem states that S_n/n satisfies an LDP with rate function I = Λ★. The key insight is that the CGF of S_n/n is Λ itself (by independence and the additive property of log-MGFs), so the rate function is the single-step conjugate. In tropical terms, the n-fold max-plus convolution of exp(-I) concentrates around the mean — this is a tropical law of large numbers. Formalizing this requires defining tropical convolution (sup-convolution) and proving it interacts correctly with `LegFen`.

**Why now?** We have `cramer_algebraic_bound` giving one direction (upper bound). The lower bound requires showing that the rate function is tight, which can be approached via the `affine_convexOn` lemma and a covering argument. The sup-convolution `(f □ g)(x) = sup_y{f(y) + g(x-y)}` has a clean relationship with `LegFen`: (f □ g)★ = f★ + g★.
