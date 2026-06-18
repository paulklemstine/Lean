# Future Directions — Pinsker–Fisher Sandwich Cycle

## Synthesis

This cycle started from two already-completed catalog results — the **general Pinsker
inequality** (`PinskerInequality.general_pinsker`, the lower control of KL by squared
total variation) and the **Fisher/χ² upper sandwich**
(`FisherInformationMetric.klDiv_le_fisher`) — and asked whether they could be *fused*
into a single, sharper geometric statement rather than living as two unrelated halves.
The answer is yes, and the fusion is more than bookkeeping: composing the two
inequalities through KL and then **eliminating KL by transitivity** produces a purely
geometric inequality, `tv_sq_le_chiSquared`, that compares the L¹ (total-variation)
geometry of the probability simplex directly with its χ² (Pearson / Fisher) geometry,
with no information-theoretic term left in sight. The structural insight is that **KL
is an *intermediary*** that can be removed once it is squeezed from both sides; the two
catalog half-sandwiches are exactly the two ingredients needed to do this.

We then audited the entire chain in the **Bernoulli model**, where every divergence has
a closed form. The closed form `berChiSquared = (p−q)²/(q(1−q))` (`bernoulli_chiSquared_eq`)
exposes the single governing quantity — the Bernoulli variance `q(1−q)` — whose
reciprocal is the Fisher information of `Ber q`. The Bernoulli sandwich
(`bernoulli_sandwich`) shows the whole chain collapses to the numeric statement
`2(p−q)² ≤ KL(Ber) ≤ (p−q)²/(q(1−q))`, and its consistency is governed by the elementary
fact `q(1−q) ≤ 1/4`, i.e. the χ² ceiling `1/(q(1−q))` is always at least `4`, comfortably
above the Pinsker floor constant `2`.

What did *not* work cleanly: deriving the Bernoulli upper bound as a literal special
case of the general `klDiv_le_fisher` is awkward, because it forces one to materialise an
explicit two-point distribution family and reconcile definitional unfoldings; a direct
`log x ≤ x − 1` argument is shorter and more robust. This is a recurring lesson — a
"specialisation" is sometimes more expensive than a fresh elementary proof. The key
insight is that the *gap* between the Pinsker floor and the χ² ceiling is entirely
controlled by the local variance, and that gap blows up at the simplex boundary, which is
precisely where rare-event behaviour makes KL and TV diverge qualitatively.

## Results Summary

- `klDiv_two_sided`: proved — packages the Pinsker lower bound and the Fisher/χ² upper
  bound into one two-sided control `½‖p−q‖₁² ≤ KL(p‖q) ≤ g_q(p−q,p−q)`.
- `tv_sq_le_chiSquared`: proved — a KL-free corollary, `½‖p−q‖₁² ≤ χ²(p‖q)`, obtained by
  eliminating KL via transitivity through `klDiv_two_sided` and `chiSquared_eq_fisher`.
- `bernoulli_chiSquared_eq`: proved — closed form `χ²(Ber p‖Ber q) = (p−q)²/(q(1−q))`,
  isolating the Bernoulli variance as the sole governing quantity.
- `bernoulli_sandwich`: proved — the fully explicit binary chain
  `2(p−q)² ≤ KL(Ber p‖Ber q) ≤ (p−q)²/(q(1−q))`, with Pinsker as the floor and χ² as the
  ceiling.

## Research Directions

### Direction 1: Reverse Pinsker under a bounded density ratio
**Hypothesis**: If `α ≤ p i / q i ≤ β` for all `i` (a bounded likelihood-ratio
assumption), then there is a constant `C(α,β)` with `KL(p‖q) ≤ C(α,β) · ‖p−q‖₁²`, i.e.
a *reverse* Pinsker inequality matching the lower bound up to a ratio-dependent constant.
**Test**: Prove it by bounding each `log(p i/q i)` between two affine functions of
`p i/q i − 1` on `[α,β]` (Taylor with explicit remainder), then summing; disprove by
exhibiting a sequence where the ratio is unbounded and `KL/‖p−q‖₁² → ∞`.
**Why now**: This cycle already established `tv_sq_le_chiSquared` and the Bernoulli
closed form, so the machinery (`log x ≤ x − 1` plus its lower companion
`x − 1 − (x−1)²/(2α²) ≤ log x`) is exactly in scope. The key insight is that the loss in
Pinsker is governed by the *local variance*, which a bounded ratio makes uniformly
controllable.
**If true**: gives two-sided equivalence of KL and TV² on ratio-bounded families, a
quantitative concentration tool.
**If false**: pinpoints that the obstruction is unbounded likelihood ratios at the
simplex boundary, sharpening where TV and KL genuinely decouple.

### Direction 2: Sharp constant in the Bernoulli Pinsker inequality
**Hypothesis**: The constant `2` in `2(p−q)² ≤ KL(Ber p‖Ber q)` is optimal: for every
`c > 2` there exist `p,q ∈ (0,1)` with `c(p−q)² > KL(Ber p‖Ber q)`.
**Test**: Take `q = 1/2` and analyse `KL(Ber p‖Ber ½)/(p−½)²` as `p → ½`; its limit is
exactly `2` (second-derivative / Fisher value `1/(q(1−q)) = 4`, halved). Formalise the
limit and conclude non-improvability.
**Why now**: `bernoulli_chiSquared_eq` already gives the exact local curvature `1/(q(1−q))`,
and `bernoulli_sandwich` brackets KL between `2(p−q)²` and `(p−q)²/(q(1−q))`; the key
insight is that the optimal global constant equals the *minimum* over `q` of half the
local Fisher information, attained at `q = 1/2`.
**If true**: certifies `2` as the universal sharp constant, closing the Bernoulli case.
**If false**: would reveal an unexpected improvement away from `q = 1/2`, contradicting
the variance-controls-the-gap picture.

### Direction 3: Multi-event projection and tightness of data processing
**Hypothesis**: For any partition `A₁,…,A_k` of the index set, `KL(p‖q) ≥ KL(P_A ‖ Q_A)`
where `P_A,Q_A` are the coarse-grained vectors, and the *binary* partition `{q ≤ p}` used
in `general_pinsker` is the one maximising the recovered TV² lower bound.
**Test**: Prove the general data-processing direction by iterating `log_sum_ineq`, then
prove optimality of the `{q ≤ p}` event by a rearrangement/exchange argument; disprove
optimality by a 3-point counterexample if some non-monotone event does better.
**Why now**: `log_sum_ineq` is already proved in the catalog and was the engine behind
`general_pinsker`; the key insight is that the Pinsker proof secretly chooses an
*optimal* coarse-graining, and making that optimality explicit is the natural next step.
**If true**: yields a clean "optimal binary projection" principle for divergence lower
bounds.
**If false**: a counterexample would show the binary event is merely convenient, not
optimal, redirecting attention to multi-way projections.

### Direction 4: f-divergence generalisation of the sandwich
**Hypothesis**: For any convex `f` with `f(1)=0`, the f-divergence `D_f(p‖q)` satisfies a
two-sided sandwich `c_f · ‖p−q‖₁² ≤ D_f(p‖q) ≤ C_f · χ²(p‖q)` with constants determined
by `f''(1)` and the convexity modulus of `f`.
**Test**: Specialise to `f(x)=x log x` (KL, this cycle), `f(x)=(x−1)²` (χ², trivial upper
side), and `f(x)=(√x−1)²` (squared Hellinger); prove the χ² upper bound via
`f(x) ≤ ½ f''(ξ)(x−1)²` and the TV lower bound via Pinsker-type convexity.
**Why now**: the KL instance is now fully proved end to end, giving a template; the key
insight is that both bounds depend only on local second-order data of `f` at `1`, exactly
the `f''(1)` that defines the Fisher metric for *every* f-divergence.
**If true**: unifies Pinsker, Hellinger, and χ² inequalities under one curvature
principle.
**If false**: identifies which f-divergences escape the χ² ceiling (e.g. those with
`f''(1)=∞`), mapping the boundary of the method.

### Direction 5: Quantitative concentration from the χ² corollary
**Hypothesis**: The KL-free inequality `tv_sq_le_chiSquared` yields a usable
concentration / mixing bound: for a Markov chain with stationary `q`, the TV distance to
stationarity at step `t` obeys `‖p_t − q‖₁ ≤ √(2 χ²(p_t‖q))`, and `χ²(p_t‖q)` decays
geometrically with rate the spectral gap.
**Test**: Combine `tv_sq_le_chiSquared` with the standard spectral decay
`χ²(p_t‖q) ≤ (1−γ)^{2t} χ²(p_0‖q)` to derive an explicit TV mixing-time bound; verify on a
two-state chain using `bernoulli_chiSquared_eq`.
**Why now**: this cycle produced precisely the `TV² ≤ χ²` link that bridges the spectral
(χ²) and statistical (TV) worlds; the key insight is that χ² is the contraction-friendly
divergence while TV is the operationally meaningful one, and our inequality is the exact
converter.
**If true**: turns a static geometric inequality into a dynamical mixing-time tool.
**If false**: would show the χ²→TV conversion loses too much for tight mixing bounds,
motivating direct TV-contraction estimates instead.
