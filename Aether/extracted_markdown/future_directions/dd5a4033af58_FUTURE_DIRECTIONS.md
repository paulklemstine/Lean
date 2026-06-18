# Future Directions — Stereographic Neural Attention (Weights cycle)

## Synthesis

The Core file established that the Cauchy kernel `K(q,k) = 1/(1 + ‖q−k‖²)` is the
conformal factor of stereographic projection: it is strictly positive
(`cauchyKernel_pos`), bounded by `1` (`cauchyKernel_le_one`), saturates exactly on the
diagonal (`cauchyKernel_eq_one_iff`), and equals one quarter of the squared chordal
distance from `σ(x)` to the north pole (`stereo_chordal_eq_kernel`).

This cycle (`Weights.lean`) promoted the kernel from a *score* to a full *attention
mechanism*. We proved that the normalized scores `w_i(q) = K(q,k_i)/∑_j K(q,k_j)` form a
genuine probability law — every weight is positive (`attnWeight_pos`) and the weights sum
to one (`attnWeight_sum_one`) over any nonempty finite key set — and that the attention
output `∑_i w_i • v_i` is a convex combination, hence norm-bounded by the largest value
norm (`attnOutput_norm_le`). We also recorded three structural symmetries of the kernel:
symmetry (`cauchyKernel_symm`), translation invariance (`cauchyKernel_translation`), and
antitonicity in distance (`cauchyKernel_antitone`), plus the fact that equidistant keys
collapse attention to the uniform distribution (`attnWeight_eq_uniform_of_const`).

The result is a clean statement: stereographic attention lands on the probability simplex
exactly like softmax, but it does so via Riemann-sphere geometry rather than
exponentiation, and it inherits Euclidean isometry-invariance for free.

## Conjectures

### 1. Lipschitz stability of the attention output in the query

The output map `q ↦ attnOutput q ks vs` should be Lipschitz continuous on every bounded
region of query space, with a modulus controlled by the spread of the keys and values.
Concretely: there is a constant `L`, depending only on `max_i ‖vs i‖` and the key
configuration, such that `‖attnOutput q ks vs − attnOutput q' ks vs‖ ≤ L · ‖q − q'‖`.
**The key insight is** that `cauchyKernel_antitone` already controls how a single weight
responds to query motion, and the simplex constraint `attnWeight_sum_one` keeps the total
mass fixed, so the only freedom is mass *transport* between keys — which is exactly what a
Lipschitz bound quantifies. **Why now?** We have the probability-law backbone in place;
adding a derivative/difference estimate on `cauchyKernel` turns the static simplex result
into a dynamic robustness theorem, the property practitioners actually care about for
adversarial stability.

### 2. Entropy lower bound and the temperature of the sphere

Define the attention entropy `H(q) = −∑_i w_i log w_i`. Conjecture: over a key set of
diameter `D`, the entropy is bounded below by an explicit decreasing function of `D`,
with equality on the equidistant configuration where `attnWeight_eq_uniform_of_const`
gives `H = log n`. **The key insight is** that `cauchyKernel`'s boundedness in `(0,1]`
caps the ratio between the largest and smallest weights, so attention can never become
arbitrarily peaked the way softmax can at low temperature — the sphere imposes an
intrinsic minimum temperature. **Why now?** The uniform-distribution theorem pins down the
maximum-entropy case exactly; quantifying the deviation from it is the natural next
measurement and connects directly to expressivity arguments.

### 3. Injectivity of the attention readout (a recovery theorem)

Fix generic keys `k_i` in general position. Conjecture: the map `q ↦ (w_1(q), …, w_n(q))`
is injective on a dense open set, so the full weight vector determines the query up to the
sphere's symmetry group. **The key insight is** that each level set `{q : K(q,k_i) = c}`
is a sphere centered at `k_i`, and `n` generic spheres intersect in at most one point;
`cauchyKernel_eq_one_iff` is the degenerate `n = 1`, `c = 1` instance of this. **Why now?**
With symmetry (`cauchyKernel_symm`) and translation invariance
(`cauchyKernel_translation`) formalized, the exact symmetry group obstructing injectivity
is identified, so the recovery statement can be made precise rather than aspirational.

### 4. Cross-domain bridge: stereographic attention as a Markov kernel

The weight matrix `W_{ij} = w_j(k_i)` (attention of key `i` to key `j`) is row-stochastic
by `attnWeight_sum_one` and strictly positive by `attnWeight_pos`, hence a primitive
Markov transition matrix. Conjecture: its stationary distribution and spectral gap are
governed by the geometry of the key cloud on the Riemann sphere, linking this file to the
catalog's expander/spectral-gap results (`Bridges/SpectralGap`, `Algebra/ExpanderWalk`).
**The key insight is** that positivity + stochasticity is exactly the Perron–Frobenius
hypothesis, so the entire spectral-gap toolkit already in the catalog applies verbatim once
`W` is recognized as a kernel. **Why now?** This cycle supplies the two hypotheses
(`attnWeight_pos`, `attnWeight_sum_one`) that the existing spectral machinery consumes,
making the bridge a matter of assembly rather than new theory.

### 5. The kernel is positive-definite (a reproducing-kernel structure)

Conjecture: `K(q,k) = 1/(1 + ‖q−k‖²)` is a positive-definite kernel on any inner-product
space, so it generates a reproducing-kernel Hilbert space in which stereographic attention
is an orthogonal-projection-like operation. **The key insight is** that `1/(1+t)` is the
Laplace transform of `e^{−s}` against `e^{−st}`, so the Cauchy kernel is an integral
mixture of Gaussian kernels `e^{−s‖q−k‖²}`, each of which is classically positive-definite;
positive-definiteness is preserved under such mixtures. **Why now?** Recognizing the kernel
as a Gaussian mixture connects the purely geometric Core results to the analytic
RKHS framework, opening the door to generalization-error bounds via the catalog's
PAC-Bayes and Rademacher infrastructure.
