# Future Directions — Empirical Rademacher Complexity and Spectral Layer-Peeling

The file `MachineLearning/NeuralRademacher.lean` introduces a *fully finite, fully
rigorous* model of empirical Rademacher complexity `empRad F hF`, defined as the honest
uniform average over all `2ⁿ` sign patterns `Fin n → Bool` of the supremum of the signed
inner product `⟨σ, v⟩` over the realized output vectors `v ∈ F`. On this object we proved
six structural laws: singleton vanishing (`empRad_singleton`), monotonicity
(`empRad_mono`), nonnegativity (`empRad_nonneg`), positive homogeneity (`empRad_smul`),
bias invariance (`empRad_shift`), and the headline **spectral layer-peeling** identity
`empRad_iterate : empRad ((scaleClass c)^[L] F) = cᴸ · empRad F`. These give the exact
multiplicative law underlying the classical "complexity scales like `Cᴸ`" bound. The
directions below push from these exact algebraic laws toward the analytic `1/√n` decay and
the bridge to the catalog's algebraic learning theory.

## 1. Massart's finite-class bound: extracting the `√(log|F|)/√n` rate

We proved the *structural* laws but not yet a *quantitative decay* in `n`. The natural next
target is Massart's lemma: for a finite class `F` whose vectors satisfy `‖v‖₂ ≤ B`,
`empRad F hF ≤ B · √(2 · log |F|) / n`. Combined with `empRad_smul` and `empRad_iterate`
this yields the genuine `O(Cᴸ √(log width) / √n)` neural-network bound rather than only the
multiplicative skeleton.

The key insight is that the sign-flip symmetry already formalized as `signInner_sum_zero` is
the degenerate (`|F| = 1`) case of a sub-Gaussian moment-generating-function bound: each
coordinate `σ_i v_i` is bounded in `[-|v_i|, |v_i|]`, so `signInner σ v` is sub-Gaussian
with proxy variance `‖v‖₂²`, and a union bound over the finite `F` controls the supremum's
MGF. Why now? The finite-average definition makes the MGF `∑_σ exp(t·signInner σ v)` a
literal finite product `∏_i cosh(t v_i)`, so Hoeffding's lemma becomes a per-coordinate
convexity inequality that Lean's `Real` API and `Finset.prod` machinery can discharge
directly — no measure theory required.

## 2. Talagrand contraction for `1`-Lipschitz activations

`empRad_smul` handles *linear* rescaling, but real networks interleave nonlinear activations
(ReLU, tanh). The contraction principle states that for a `1`-Lipschitz `φ` fixing `0`,
the complexity of `φ ∘ F` is at most that of `F`. Proving `empRad (F.image (φ ∘ ·)) ≤
empRad F` would let `empRad_iterate` be upgraded from "linear layers" to "linear layers
with `1`-Lipschitz nonlinearities", i.e. actual feed-forward networks.

The key insight is that contraction is a *pairwise* statement: it suffices to compare, for
each fixed sign pattern and each pair `(u, v) ∈ F × F`, the quantity
`σᵢ(φ(uᵢ) − φ(vᵢ))` against `σᵢ(uᵢ − vᵢ)`, which the Lipschitz bound dominates coordinatewise.
Why now? Because our supremum is a `Finset.sup'` over an explicitly finite class, the usual
"split the sup into a max over a pair" induction is a finite `Finset.induction`, sidestepping
the measurable-selection subtleties that block the standard analytic proof.

## 3. McDiarmid concentration: from empirical to true Rademacher complexity

`empRad` is the *empirical* complexity on a fixed realized sample. The next layer is to show
it concentrates around its expectation over the data distribution, giving the two-sided
generalization bound `|train − test| ≤ 2·𝔼[empRad] + O(√(log(1/δ)/n))` with probability
`1 − δ`.

The key insight is that `empRad` viewed as a function of the `n` sample points has bounded
differences: changing one sample point `xᵢ` moves the supremum by at most `2B/n`, because the
prefactor is exactly `1/n` (visible in our definition) and each coordinate contributes a
single bounded summand. Why now? The bounded-difference constant falls straight out of the
already-proven `empRad_smul`/`empRad_shift` algebra (perturbing one coordinate is a rank-one
shift), so the hard analytic input reduces to a clean Azuma/McDiarmid inequality that can be
stated finitely.

## 4. Bridging to the catalog's algebraic surrogate `spectralComplexityBound`

`MachineLearning/Foundations.lean` defines `spectralComplexityBound` and
`spectral_complexity_le_card_spectrum` as an *algebraic* proxy for Rademacher complexity over
an arbitrary semiring, but never connects it to an analytic object. We can now prove a
comparison theorem: over `S = ℝ`, the analytic `empRad` of the hypothesis class induced by an
`AlgebraicHypothesisClass` is bounded by its `spectralComplexityBound` times a universal
`1/√n` factor.

The key insight is that the restriction map `ModuleRestrictionMap` from `Foundations.lean`
sends a module hypothesis to exactly the realized output vector `v ∈ Fin n → ℝ` that our
`empRad` consumes, so the two theories share a single underlying object and differ only in
how they *measure* it (spectral valuation vs. sign-average supremum). Why now? Both files are
in the same library at the same Mathlib version, and the linearity lemmas
(`embed_smul`, `embed_add`) on the algebraic side line up term-for-term with our
`empRad_smul` and `empRad_shift`, making the comparison a structural rewrite rather than new
analysis.

## 5. Width–depth tradeoff and the `√L` improvement over `Cᴸ`

Our `empRad_iterate` gives the exact `Cᴸ` scaling for uniform per-layer contraction `C`.
The frontier conjecture (Bartlett–Foster–Telgarsky) is that with a more refined
*covering-number* argument the dependence improves to roughly `C · √L` when the spectral
norms are balanced across layers — exponentially better in depth.

The key insight is that `empRad_iterate`'s product `∏ᵢ cᵢ` is tight only in the worst case;
allowing the per-layer factors `cᵢ` to interact through a covering net of the intermediate
representations replaces the product by a sum-of-squares `√(∑ᵢ cᵢ²)`, which is `√L · C` for
balanced layers. Why now? We already have the exact multiplicative baseline and the
finite-class machinery from Direction 1; the missing piece is a Lean formalization of metric
covering numbers for `Finset (Fin n → ℝ)`, which is a finite, computable notion (minimal
`ε`-net cardinality) that fits the same `Finset`-based style as the rest of this file and can
be tested on small explicit classes via `#eval`.
