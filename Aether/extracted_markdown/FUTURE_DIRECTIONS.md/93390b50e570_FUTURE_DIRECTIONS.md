# Future Directions — Tropical Amoebas, Ronkin Functions, and the Maslov Deformation

## Synthesis

The existing file `Catalog/Tropical/AmoebaRonkin.lean` established the *static* picture of
the amoeba of a Laurent polynomial: the tropical polynomial `trop f = max_i A_i` (the amoeba
spine) is convex and piecewise-linear, each amoeba-complement region carries a constant
integer slope (the order map), and the Maslov–Ronkin smoothing
`R_t = t · log Σ_i exp(A_i/t)` converges to the spine as `t → 0⁺`.

This cycle (`Catalog/Tropical/AmoebaRonkinMultiplicativity.lean`) adds the *dynamic and
algebraic* picture. Three structural facts now sit on top of that foundation:

1. **The Maslov deformation is a `(×) → (+)` homomorphism at every temperature.**
   `ronkinDeform_mul` shows `R_t(f·g) = R_t(f) + R_t(g)` for *all* `t`, and `tropPoly_mul`
   shows `trop(f·g) = trop f + trop g`. The tropical statement is literally the `t → 0⁺`
   shadow of the analytic one — the same homomorphism survives dequantization.

2. **The family `{R_t}` is monotone in temperature.** `ronkinDeform_mono_temp` proves
   `R_s ≤ R_t` for `0 < s ≤ t`, via finite superadditivity `Σ uᵢ^p ≤ (Σ uᵢ)^p`
   (`sum_rpow_le_rpow_sum`, the `ℓ^p ≤ ℓ^1` mechanism).

3. **The spine is the variational infimum of the family.** `tropPoly_isGLB` upgrades
   "lower bound + limit" into `trop f = inf_{t>0} R_t`, an exact greatest-lower-bound
   characterisation of the amoeba spine.

Together these say: the amoeba spine is the order-preserving, multiplicative limit of a
monotone family of smooth convex functions — a clean Grothendieck-style restatement of
"tropical geometry is zero-temperature classical geometry."

## Results Summary

| Theorem | Statement |
|---|---|
| `affFun_prod_index` | log-modulus of a product monomial splits additively |
| `tropPoly_mul` | `trop(f·g) = trop f + trop g` (spine multiplicativity) |
| `ronkinDeform_mul` | `R_t(f·g) = R_t(f) + R_t(g)` for every `t` |
| `sum_rpow_le_rpow_sum` | `Σ uᵢ^p ≤ (Σ uᵢ)^p` for `p ≥ 1`, `uᵢ ≥ 0` |
| `ronkinDeform_mono_temp` | `R_s ≤ R_t` for `0 < s ≤ t` |
| `tropPoly_isGLB` | `trop f = inf_{t>0} R_t` |

All six compile with `sorry = 0` and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

## Research Directions

### 1. The temperature derivative is the Gibbs entropy of the dominance weights
Define the softmax weights `wᵢ(t,x) = exp(Aᵢ(x)/t) / Σⱼ exp(Aⱼ(x)/t)`. The conjecture is
that `d/dt R_t(x) = -Σᵢ wᵢ log wᵢ ≥ 0` (the Shannon entropy of the weight distribution),
giving a *second*, differential proof of `ronkinDeform_mono_temp` and a quantitative gap
`R_t - trop f`. **The key insight is** that monotonicity in temperature is not an analytic
accident but the statement that entropy is nonnegative, so the Ronkin gap is literally a
free-energy/entropy budget. **Why now?** `ronkinDeform_mono_temp` already isolates the
monotone family and `sum_rpow_le_rpow_sum` supplies the convexity backbone; the only new
ingredient is differentiating the log-sum-exp, which Mathlib's `Real.hasDerivAt_exp` and
quotient rule support directly.

### 2. A tropical Newton-polytope homomorphism into `(ℝⁿ, +)` slopes
`tropPoly_slope_on_dominant` (in `AmoebaRonkin.lean`) assigns to each dominance region an
integer slope `mₖ`; `tropPoly_mul` shows spines add under products. The conjecture is that
the induced "slope set" map `f ↦ {mₖ}` sends products to Minkowski sums of Newton polytopes,
i.e. it is a monoid homomorphism `(Laurent polynomials, ×) → (lattice polytopes, ⊕)`.
**The key insight is** that the order map and spine multiplicativity are two faces of one
homomorphism — the corner locus of `trop(f·g)` is the common refinement of those of `trop f`
and `trop g`. **Why now?** Both halves (slopes via `tropPoly_slope_on_dominant`, additivity
via `tropPoly_mul`) are already formal; what remains is to define the finite slope set and
prove the Minkowski-sum identity, a purely combinatorial `Finset` argument.

### 3. Strict convexity of `R_t` away from the spine, and its collapse at `t = 0`
The boundary `example` in `AmoebaRonkin.lean` shows the spine is affine (not strictly convex)
on a single-monomial region. The conjecture is the sharp dichotomy: for every `t > 0` and at
least two non-parallel monomials, `R_t` is *strictly* convex transverse to the spine, while
the `t → 0⁺` limit destroys strict convexity exactly on the dominance regions. **The key
insight is** that strict convexity is the analytic signature of "more than one monomial
competing," and dequantization is precisely the loss of that signature on each complement
component. **Why now?** `ronkinDeform_convexOn` already proves convexity via Hölder; the
strict version needs only the equality case of Hölder, for which Mathlib has
`inner_le_Lp_mul_Lq` and strict-convexity lemmas for `Real.exp`.

### 4. Lipschitz/quantitative dequantization in the sup norm over a compact box
`maslov_dequantization_rate` gives the pointwise bound `|R_t - trop f| ≤ t·log N`. The
conjecture strengthens this to a *uniform* statement: on any compact box `K ⊆ ℝⁿ`,
`‖R_t - trop f‖_{∞,K} ≤ t·log N` and `R_t → trop f` uniformly, so the spine inherits the
(common) Lipschitz constant `max_i ‖mᵢ‖` of the `R_t`. **The key insight is** that the
dequantization error is already temperature-controlled *independently of `x`*, so uniform
convergence is free once phrased on a compact set. **Why now?** The pointwise rate is formal
and `t·log N` carries no `x`; lifting to `‖·‖_∞` is a `Metric`/`tendstoUniformly` packaging
exercise that needs no new analysis.

### 5. A semiring-homomorphism statement: the Ronkin transform as a functor of monoids
Directions 1–2 hint at a single abstract object: for each `t ≥ 0`, the map sending a finite
monomial support (with log-coefficients) to its value `R_t(x)` is a homomorphism from the
multiplicative monoid of Laurent polynomials to `(ℝ, +)`, *natural in `t`*, degenerating at
`t = 0` to the tropical semiring homomorphism into `(ℝ, max)`. The conjecture is that this
assembles into a functor from the tropical semiring to a family of additive monoids, with
`maslov_tendsto` as the natural transformation realising the `t → 0` limit. **The key insight
is** that `ronkinDeform_mul` + `tropPoly_mul` + `maslov_tendsto` are the object-map,
morphism-map, and naturality of one functor, unifying the analytic and tropical pictures in a
single categorical statement. **Why now?** All three component theorems are now formal and
sorry-free; the remaining work is to choose the right Mathlib monoid/category encoding and
re-express the existing lemmas as its structure fields — packaging, not new mathematics.
