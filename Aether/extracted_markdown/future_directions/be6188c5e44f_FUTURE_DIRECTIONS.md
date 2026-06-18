# Future Directions: Tropical Amoebas, Ronkin Functions, and Maslov Dequantization

## Synthesis

The file `Catalog/Tropical/AmoebaRonkin.lean` isolates the purely analytic skeleton of
amoeba theory and proves it from first principles, with **zero `sorry`** on the main
results and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

The unifying object is the **Ronkin smoothing**
`ronkinSmooth s f t = (1/t)·log Σᵢ∈s exp(t·fᵢ)`,
a one-parameter deformation interpolating between the additive ("classical") world at
finite temperature and the max-plus ("tropical") world in the limit `t → ∞`. The four
theorems form a tight logical chain:

1. `sup'_le_log_sum_exp` and `log_sum_exp_le_sup'_add_log_card` — the two halves of the
   **finite-family log-sum-exp sandwich**, with structural slack `log #s`.
2. `sup'_smul` — the positive-scaling law `maxᵢ(t·fᵢ) = t·maxᵢ fᵢ`, the bridge that lets
   us insert the temperature `t` inside the tropical maximum.
3. `ronkin_sandwich` — combines (1) and (2) into
   `maxᵢ fᵢ ≤ ronkinSmooth ≤ maxᵢ fᵢ + (log #s)/t`.
4. `maslov_dequantization` — squeezes the sandwich to obtain the limit
   `ronkinSmooth ⟶ maxᵢ fᵢ`, the Maslov dequantization theorem.
5. `tropPoly_convexOn` — the tropical polynomial `x ↦ maxᵢ(aᵢ + ⟨mᵢ,x⟩)` is convex, the
   order-zero shadow of the convexity of the Ronkin function.

This **generalizes** the catalog's two-point dequantization in
`Catalog/Tropical/NeuralNetworks/NDimLogSumExp.lean`
(`logsumexp_two_point`, `scaled_logsumexp_dequant`, with its ad-hoc `log 2` slack) from
`n = 2` summands to an arbitrary finite family indexed by a `Finset`, and connects it to
the convex-geometric side of amoeba theory (`tropPoly_convexOn`).

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `sup'_le_log_sum_exp` | `maxᵢ fᵢ ≤ log Σ exp fᵢ` | proved |
| `log_sum_exp_le_sup'_add_log_card` | `log Σ exp fᵢ ≤ maxᵢ fᵢ + log #s` | proved |
| `sup'_smul` | `maxᵢ(t·fᵢ) = t·maxᵢ fᵢ` for `t ≥ 0` | proved |
| `ronkin_sandwich` | sandwich with slack `(log #s)/t` | proved |
| `maslov_dequantization` | `ronkinSmooth ⟶ maxᵢ fᵢ` as `t → ∞` | proved |
| `tropPoly_convexOn` | tropical polynomials are convex | proved |

## Research Directions

### 1. Quantitative uniform dequantization on compact sets

Right now `maslov_dequantization` is a pointwise limit in the argument family `f`. The
sandwich already gives the explicit error `(log #s)/t`, which is **independent of `f`**.
This should upgrade to a *uniform* statement: for the tropical polynomial
`tropPoly s hne a m` and its finite-temperature Ronkin smoothing, the sup-norm error over
the whole of `ℝⁿ` is bounded by `(log #s)/t`.
**The key insight is** that the slack `log #s` in `ronkin_sandwich` does not depend on the
point `x`, so the convergence is automatically uniform — no compactness is even required,
turning a soft limit into a hard rate.
**Why now?** The pointwise limit and the explicit slack are both already proved in this
file; the uniform version is a direct `Filter`-level repackaging using
`Metric.tendstoUniformly` and the existing `ronkin_sandwich`, with no new analysis.

### 2. The order map and locally-constant gradients (amoeba complement structure)

For a tropical polynomial `p(x) = maxᵢ(aᵢ + ⟨mᵢ,x⟩)`, define the *order set* at `x` as the
set of maximising indices `argmaxᵢ`. On the open region where a single index `i` strictly
dominates, `p` is the affine function `aᵢ + ⟨mᵢ,·⟩`, so its gradient is the constant integer
vector `mᵢ`. This is the tropical model of the classical theorem that the gradient of the
Ronkin function is locally constant (and integer-valued) on each connected component of the
amoeba complement.
**The key insight is** that the convexity already proved in `tropPoly_convexOn`, combined
with strict domination of one affine piece, forces local affineness — convexity plus local
affineness is exactly the rigidity that pins the gradient to a lattice point.
**Why now?** `tropPoly` and its convexity are in hand; the missing pieces (a `Finset.argmax`
predicate and an "eventually equals one affine piece" lemma) are elementary `Finset.sup'`
manipulations that the same techniques used for `sup'_smul` will dispatch.

### 3. Maslov dequantization of the tropical *product* (sub/super-additivity)

The Ronkin smoothing is a semiring deformation: `log-sum-exp` deforms `+` and ordinary `+`
deforms tropical `⊗`. One should prove the dequantization of the tropical *product*:
`ronkinSmooth` of a pointwise sum of two families converges to the sum of tropical maxima,
i.e. `max(f) + max(g) = max(f ⊗ g)` in the limit, together with the finite-temperature
sub/super-additivity inequalities that bound the gap.
**The key insight is** that `exp` turns the deforming sum into a product, so the tropical
distributive law becomes the ordinary one under the deformation, and the gap is again
controlled by a `log #s`-type slack.
**Why now?** The catalog already contains `LSEConvexity` (sub-additivity, shift invariance)
and the two-point gap bounds; the finite-family `ronkin_sandwich` is the exact tool needed
to lift these to the `Finset`-indexed product and close the semiring picture.

### 4. Newton polytope as the asymptotic cone of the tropical polynomial

The recession/asymptotic behaviour of `tropPoly s hne a m` is governed by the convex hull
of the exponent vectors `{mᵢ}` — the *Newton polytope*. Concretely, the directional growth
rate `lim_{r→∞} tropPoly(r·v)/r` should equal the support function of the Newton polytope
evaluated at `v`.
**The key insight is** that for large `r` the maximiser of `maxᵢ(aᵢ + r⟨mᵢ,v⟩)` is the
index maximising `⟨mᵢ,v⟩`, so the constant terms `aᵢ` wash out and the growth rate is purely
the support function — a clean limit that the squeeze machinery of `maslov_dequantization`
already models.
**Why now?** `tropPoly_convexOn` gives the convex-function framework, and the support
function `Finset.sup'` of linear forms is the same object as the tropical polynomial with
zero constant terms, so this is a structural identification rather than new theory.

### 5. From smoothing to genuine Ronkin integrals (toric averaging)

The deepest extension is to replace the finite sum `Σᵢ exp(t·fᵢ)` by the genuine torus
average `∫_{Log⁻¹(x)} log|f|` of amoeba theory, and recover `tropPoly` as its `t → ∞`
limit for an honest Laurent polynomial `f`. The finite-family result is precisely the
Riemann-sum / Jensen shadow of this integral.
**The key insight is** that the integral Ronkin function is, like its finite proxy, convex
and trapped between the tropical maximum and a slack term controlled by the number of
monomials — so the same sandwich-and-squeeze strategy should transfer once the torus measure
is set up.
**Why now?** Mathlib now has enough measure theory and convexity API (`MeasureTheory`,
`ConvexOn`, `intervalIntegral`) that the convexity half can be attempted immediately, using
`tropPoly_convexOn` as the target of the limit and `ronkin_sandwich` as the template for the
bounding argument.
