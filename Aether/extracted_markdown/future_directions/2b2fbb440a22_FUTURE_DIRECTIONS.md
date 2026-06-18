# Future Directions — Pinsker / Information-Geometry Cycle

These notes seed the next research cycle. The new Lean artifacts are in
`Catalog/Speculative/AutoResearch/PinskerInequality.lean` (self-contained), and the
back-fill of the previously-open conjecture lives in
`Catalog/Speculative/AutoResearch/FisherInformationMetric.lean`.

## Synthesis

This cycle closed the standing open conjecture `klDiv_ge_half_tv_sq` from the Fisher /
χ² sandwich file (`FisherInformationMetric.lean`), which had been left as a `sorry`
"research direction for the next cycle". That file already established the **upper**
two-sided control `0 ≤ KL(p‖q) ≤ χ²(p‖q) = g_q(p−q,p−q)` (Gibbs + Fisher form). The
missing piece was the **lower** control by the L¹ (total-variation) norm — Pinsker's
inequality `(1/2)(∑|pᵢ−qᵢ|)² ≤ KL(p‖q)`. We now have both sides, so KL is sandwiched
between the squared total-variation distance and the χ² / Fisher quadratic form for all
strictly positive normalised finite distributions.

The proof is organised around two reusable pillars. First, a **Bernoulli Pinsker
inequality** `2(p−q)² ≤ KL(Ber p ‖ Ber q)`, proved by a *factored-derivative*
monotonicity argument rather than convex duality: the gap `g q = klBer p q − 2(p−q)²`
has the exact derivative `g'(q) = (q−p)(1−2q)²/(q(1−q))`, whose perfect square `(1−2q)²`
forces `sign g' = sign(q−p)`, so `q = p` is the unique minimiser with value `0`. Second,
a **log-sum (data-processing) inequality** obtained from Jensen applied to the convex
`x ↦ x log x` (`Real.convexOn_mul_log`). The general inequality then follows by
projecting onto the single binary event `A = {i : qᵢ ≤ pᵢ}`: two applications of log-sum
collapse `KL(p‖q)` below to `klBer P_A Q_A`, and crucially `P_A − Q_A` equals the total
variation, so the generic data-processing bound becomes *tight* at this event.

The main structural lesson — recorded as a failure analysis in the Lab Notebooks — is
that **no termwise inequality works**: `2(pᵢ−qᵢ)² ≤ pᵢ log(pᵢ/qᵢ)` is false pointwise,
and `g` is not convex in `q` (its second derivative is not sign-definite). The result is
intrinsically an *aggregation* statement, which is why both the L¹ collapse and the
projection-to-binary step are essential rather than cosmetic. This same
"optimal-coarse-graining makes data-processing tight" pattern is the seed for several of
the directions below.

## Results Summary

- `PinskerInequality.bernoulli_pinsker`: **proved** — `2(p−q)² ≤ KL(Ber p ‖ Ber q)` for
  `p,q ∈ (0,1)`; the binary base case, via the factored derivative `(q−p)(1−2q)²/(q(1−q))`.
- `PinskerInequality.log_sum_ineq`: **proved** — the log-sum / data-processing inequality
  `(∑a)·log((∑a)/(∑b)) ≤ ∑ aᵢ log(aᵢ/bᵢ)` via Jensen on `x ↦ x log x`.
- `PinskerInequality.general_pinsker`: **proved** — `(1/2)(∑|pᵢ−qᵢ|)² ≤ KL(p‖q)` for
  strictly positive normalised finite distributions (general Pinsker).
- `FisherInformationMetric.klDiv_ge_half_tv_sq`: **proved** (was a `sorry`-conjecture) —
  discharged directly from `general_pinsker`, completing the KL sandwich
  `2·TV² ≤ KL ≤ χ²`.

## Research Directions

### Direction 1: Sharpened (higher-order) Pinsker — the Bretagnolle–Huber regime
**Hypothesis**: For finite distributions, `KL(p‖q) ≥ −log(1 − TV²)` where
`TV = (1/2)∑|pᵢ−qᵢ|`; equivalently `TV ≤ √(1 − e^{−KL})`, which dominates the plain
Pinsker bound `TV ≤ √(KL/2)` when `KL` is large.
**Test**: Prove the Bernoulli case `klBer p q ≥ −log(1 − (p−q)²)` by the *same*
factored-derivative method (the gap now has derivative with denominator `1−(p−x)²`),
then lift by the identical projection-to-binary argument used in `general_pinsker`.
**Why now**: The factored-derivative machinery and the projection lemma `log_sum_ineq`
are already in place; only the Bernoulli base inequality changes. The key insight is that
the same binary event `A = {q ≤ p}` is again the tight one, so the reduction is reusable
verbatim.
**If true**: Gives non-vacuous bounds in the high-divergence regime where Pinsker is weak,
unlocking sample-complexity lower bounds.
**If false**: Pinpoints where the binary projection stops being tight, teaching us which
divergences admit data-processing-tight reductions.

### Direction 2: Reverse Pinsker via the χ² ceiling already in the catalog
**Hypothesis**: With `α := minᵢ qᵢ > 0`, `KL(p‖q) ≤ (2/α)·TV²` (a reverse Pinsker bound),
combining with the proved Pinsker to give `2·TV² ≤ KL ≤ (2/α)·TV²`.
**Test**: Chain the *existing* upper sandwich `KL ≤ χ²(p‖q) = ∑(pᵢ−qᵢ)²/qᵢ`
(`FisherInformationMetric.klDiv_le_fisher`) with the elementary bound
`∑(pᵢ−qᵢ)²/qᵢ ≤ (1/α)∑|pᵢ−qᵢ|² ≤ (1/α)(∑|pᵢ−qᵢ|)² = (4/α)TV²`.
**Why now**: The χ² upper bound is already a proved catalog theorem; only a finite
Cauchy–Schwarz / `α`-uniform-lower-bound step remains. The key insight is that the χ²
form is the natural bridge between KL and L², so the reverse direction is a short hop from
results we already have.
**If true**: Yields two-sided KL ≍ TV² equivalence on the interior of the simplex,
directly tightening the PAC-Bayes bounds referenced in the catalog.
**If false**: Forces a dependence worse than `1/α`, clarifying the true modulus of
continuity of KL near the boundary of the simplex.

### Direction 3: Data-processing inequality for arbitrary stochastic maps
**Hypothesis**: For any column-stochastic matrix (channel) `K : ι → κ → ℝ` (entries ≥ 0,
columns summing to 1) and distributions `p, q`, `KL(Kp ‖ Kq) ≤ KL(p‖q)`.
**Test**: Generalise `log_sum_ineq` from a single coarse-graining partition to a full
stochastic kernel; the per-output-coordinate bound is exactly one application of the
already-proved log-sum inequality, summed over outputs.
**Why now**: `log_sum_ineq` is precisely the two-block special case (lumping outcomes);
the general channel is a finite indexed family of such lumpings. The key insight is that
`general_pinsker` already *used* data processing for the optimal binary channel, so the
abstract statement is a clean factorisation of the work just done.
**If true**: Provides the canonical monotonicity backbone for information theory in the
catalog and makes every downstream divergence bound "free" under post-processing.
**If false**: Would contradict convexity of `x log x`; a counterexample would expose a
hidden normalisation bug — a valuable stress test of the formalised definitions.

### Direction 4: Joint convexity of KL and the Fisher = Hessian-of-KL identity
**Hypothesis**: `klDiv` is jointly convex in `(p, q)` on the product of open simplices,
and its Hessian at the diagonal `p = q` equals the Fisher form `fisherForm` from the
catalog (the infinitesimal version of the proved sandwich).
**Test**: Prove joint convexity from convexity of the perspective of `x ↦ x log x`
(`(x,y) ↦ x log(x/y)`), then compute the second-order Taylor expansion of `klDiv` along
`q = p + t·v` and match it termwise to `fisherForm p v v` (already defined and shown
positive-definite).
**Why now**: The catalog states "Fisher metric = Hessian of KL" only as the *global*
sandwich `KL ≤ g`; with both sandwich sides now proved, the infinitesimal equality is the
natural completion. The key insight is that the two-sided bound forces the quadratic terms
to agree, so the Hessian identity is squeezed out of the inequalities we already have.
**If true**: Rigorously connects the catalog's `fisherForm` Riemannian metric to KL as a
genuine second-order object, grounding information geometry in the catalog.
**If false**: Reveals a coefficient mismatch (e.g. a factor of 2) between the sandwich
constants and the metric normalisation — important for any later curvature computations.

### Direction 5: Concentration / sub-Gaussian tail bound from Pinsker (transport route)
**Hypothesis**: Pinsker implies a `T₁` transportation-cost inequality for the uniform
distribution on a finite set, hence McDiarmid-type concentration: any 1-Lipschitz (in
Hamming distance) function `f` satisfies a sub-Gaussian tail `P(f − E f ≥ t) ≤ e^{−t²/2}`.
**Test**: Derive the Csiszár–Kullback–Pinsker `W₁(p,q) ≤ diam·TV ≤ diam·√(KL/2)` bound
from `general_pinsker`, then run the Marton/Bobkov–Götze argument to get the tail.
**Why now**: `general_pinsker` supplies the single analytic inequality that the entire
transport-entropy chain rests on. The key insight is that concentration of measure is
"just" Pinsker plus a Lipschitz-duality argument, so the hard analytic core is already
done. **If true**: Bridges this information-theoretic file to the catalog's combinatorial
concentration results (expander/LLL files). **If false**: Localises the obstruction to
the transport-duality step, indicating that finite-state concentration needs more than the
scalar Pinsker bound.
