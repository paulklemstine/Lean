# Future Directions: Scaling Laws from Spectral Decay

## Synthesis

This cold-start cycle built, from scratch, the elementary but rigorous backbone of
*neural scaling laws* — the empirical observation that test error decays as a power
law `N^{-c}` in the sample count `N`. The central structural insight is that the
whole phenomenon reduces to a one-line optimization: a kernel-truncation estimator
keeping the top `M` eigendirections of a kernel with power-law spectrum
`λ_k ~ k^{-α}` incurs a **bias** (the spectral tail `∑_{k>M} λ_k`) plus a
**variance** (`~ M/N`). The optimal trade-off, and hence the scaling exponent, is
governed entirely by an AM–GM inequality. We proved the bias tail telescopes
(`tail_sum_inv_sq_le`), that the α=2 risk `1/x + x/N` is bounded below by `2/√N`
and that this is tight (`amgm_bias_variance`, `amgm_bias_variance_min`), and — the
centerpiece — that for *general* decay `α = a+1 > 1` the risk `x^{-a} + x/N`
bottoms out at order `N^{-a/(a+1)} = N^{-(α-1)/α}` via *weighted* AM–GM with
weights chosen so the `x`-powers cancel exactly (`scaling_law_general`).

The most important methodological discovery is the **weight-cancellation
principle**: in a weighted geometric/arithmetic mean inequality, choosing the
weights so that the exponents of the free variable sum to zero collapses the bound
to a pure constant in that variable, instantly reading off the scaling exponent.
This single idea drove three of the six theorems. It generalized cleanly from the
two-term α=2 case to the real-exponent case, and again to the *three-term*
constrained (Chinchilla) case (`compute_optimal_allocation`), where splitting `1/M`
into two halves balances the `M`-powers against `M²/C` and yields the
compute-optimal `C^{-1/3}` law with allocation `M ~ C^{1/3}`, `N ~ C^{2/3}`.

What does *not* fit this template is equally instructive. The Critic's boundary
analysis (`double_descent_pole`) shows the AM–GM machinery has no purchase at the
interpolation threshold: once the variance is the interpolation-regime `M/(N-M)`
rather than `M/N`, the product `(1/M)·(M/(N-M)) = 1/(N-M)` is no longer constant in
`M`, so AM–GM yields no floor — instead the risk *diverges* as `M → N⁻`. We proved
this divergence rigorously. This is the mathematical seed of **double descent**:
the classical law is the left branch, the pole separates two qualitatively distinct
optimization regimes, and a genuinely different (non-AM–GM) argument is required on
the right branch. The directions below are ordered by how directly this cycle's
tools make them tractable.

## Results Summary

- `tail_sum_inv_sq_le`: proved — the α=2 spectral-tail bias `∑_{M<k≤N} 1/k²` telescopes to a bound `1/M`, the bias half of the scaling trade-off.
- `amgm_bias_variance`: proved — the α=2 risk `1/x + x/N ≥ 2/√N`, establishing the canonical `N^{-1/2}` scaling exponent.
- `amgm_bias_variance_min`: proved — the `2/√N` bound is attained at `x = √N`, so the exponent `-1/2` is exact and tight, not merely an upper bound.
- `scaling_law_general`: proved — for general spectral decay `α = a+1 > 1`, the risk `x^{-a} + x/N ≥ (a+1)·a^{-a/(a+1)}·N^{-a/(a+1)}`, giving the full `-(α-1)/α` family of scaling exponents via weight-cancellation AM–GM.
- `compute_optimal_allocation`: proved — under a compute budget `M·N = C`, the risk `1/M + M²/C ≥ (3/2^{2/3})·C^{-1/3}`, the Chinchilla-type compute-optimal `C^{-1/3}` law via three-term AM–GM.
- `double_descent_pole`: proved — replacing variance `M/N` with the interpolation-regime `M/(N-M)` forces the risk above any bound `B` as `M → N⁻`, rigorously locating where the classical scaling law breaks down.

## Research Directions

### Direction 1: General-α spectral tail via integral comparison
**Hypothesis**: For real `α > 1` and `M ≥ 1`, the eigenvalue tail satisfies
`∑_{k > M} k^{-α} ≤ M^{1-α}/(α-1)`, matching the bias exponent assumed in
`scaling_law_general`. The key insight is that `k^{-α} ≤ ∫_{k-1}^{k} x^{-α} dx`
turns the tail into a single improper integral `∫_M^∞ x^{-α} dx = M^{1-α}/(α-1)`,
so the discrete telescoping of `tail_sum_inv_sq_le` is replaced by the
fundamental theorem of calculus.
**Test**: Formalize the per-term integral bound and a monotone-convergence /
`tsum` argument over `[M,∞)`, then prove the closed-form `M^{1-α}/(α-1)`. Compare
numerically against `tail_sum_inv_sq_le` at `α=2` (both give `1/M`).
**Why now**: This cycle proved the discrete α=2 tail and the abstract general-α
*optimization*; only the general-α *bias bound* itself is still assumed. Mathlib's
`integral_rpow`, `MeasureTheory.tendsto_integral` and `Real.rpow` API are now mature
enough to close exactly this gap, finally connecting `tail_sum_inv_sq_le` to
`scaling_law_general` into one end-to-end theorem.
**If true**: We get a fully self-contained `error ≤ C·N^{-(α-1)/α}` from raw
spectral decay, with no assumed bias bound — a complete scaling-law pipeline.
**If false**: The constant `1/(α-1)` is wrong or the comparison fails near `α=1`,
teaching us that the `α→1⁺` boundary (logarithmic corrections) needs separate care.

### Direction 2: Sharp two-sided double-descent characterization
**Hypothesis**: The interpolation-regime risk `f(M) = 1/M + M/(N-M)` on `(0,N)` has
exactly one interior local minimum on the under-parametrized branch and is strictly
decreasing toward it then strictly increasing to `+∞`, producing the characteristic
double-descent shape; moreover its left-branch minimum still scales as `N^{-1/2}`
up to constants. The key insight is that `f'(M) = -1/M² + N/(N-M)²` has a unique
root in `(0,N)` obtainable in closed form, separating the two monotonic pieces.
**Test**: Compute `f'` with `HasDerivAt`, solve `f'(M)=0`, and prove monotonicity on
each side via `StrictMonoOn`/`StrictAntiOn`; combine with `double_descent_pole` for
the `M→N⁻` divergence.
**Why now**: `double_descent_pole` already nailed the divergence half rigorously;
the remaining content is single-variable calculus, which Mathlib's `deriv`/
`IsLocalMin` toolkit handles well.
**If true**: First rigorous derivation of double descent from a spectral risk model,
upgrading our qualitative pole result to a full landscape theorem.
**If false**: The minimum is non-unique or the left-branch rate degrades, revealing
that double descent needs more than a variance pole (e.g. effective-dimension terms).

### Direction 3: Multi-resource compute-optimal allocation for general α
**Hypothesis**: Under `M·N = C`, the general-α risk `M^{-(α-1)} + M/N = M^{-(α-1)} +
M²/C` is minimized at `M* ~ C^{α/(2α+1)}`, giving optimal error `~ C^{-(α-1)/(2α+1)}`.
The key insight is that the three-term split of `compute_optimal_allocation`
generalizes to an `(α-1)+? `-term weighted AM–GM: balancing the `(α-1)` powers of
`M^{-(α-1)}` against the two powers of `M²/C` via real weights cancels `M` and
exposes the `C^{α/(2α+1)}` exponent.
**Test**: Prove the lower bound `risk ≥ K(α)·C^{-(α-1)/(2α+1)}` by
`Real.geom_mean_le_arith_mean3_weighted` (or its general `inner_le_nnorm` form) with
weights solving `-(α-1)w₁ + 2w₂ = 0`, `w₁+w₂=1`.
**Why now**: `compute_optimal_allocation` (α=2, exponent `1/3`) and
`scaling_law_general` (real-exponent weight cancellation) are *both* in hand; this
direction just fuses their two techniques.
**If true**: A clean Chinchilla-type law `M* ~ C^{α/(2α+1)}` parameterized by the
spectral exponent — the headline applied result.
**If false**: The optimum lands on a boundary (`M=1` or `N=1`), teaching us the
constraint geometry matters and pure AM–GM is insufficient.

### Direction 4: Minimax lower bound matching the upper rate
**Hypothesis**: No estimator can beat `N^{-(α-1)/α}` when the target lies in the
RKHS unit ball with spectral decay `α`; i.e. the upper bound of
`scaling_law_general` is order-optimal. The key insight is a packing/Fano argument:
the eigenvalue decay controls the metric entropy of the RKHS ball, and a packing of
`~ exp(M)` functions distinguishable only with `~ N^{(α-1)/α}` samples forces any
estimator's worst-case error below the rate.
**Test**: Formalize a finite hypercube of perturbations `{±ε·φ_k}_{k≤M}`, lower-bound
their pairwise separation with the tail bound, and apply a Fano/Assouad inequality
from Mathlib's information-theory / KL-divergence API.
**Why now**: The upper-bound machinery is complete this cycle; Mathlib now has
`klDiv`, mutual-information scaffolding, and finite-product measures sufficient for a
first Assouad two-point or hypercube argument.
**If true**: A complete `Θ(N^{-(α-1)/α})` characterization — matching upper and
lower bounds — the gold standard for a learning rate.
**If false**: The packing number is mis-estimated, teaching us the effective
dimension (not the raw eigenvalue count) governs the lower bound.

### Direction 5: Deriving the decay exponent α from architecture (NNGP/NTK)
**Hypothesis**: For a one-hidden-layer ReLU network in the NNGP/NTK regime on the
sphere `S^{d-1}`, the Mercer eigenvalues decay as `k^{-(d+1)/d}`, so plugging
`α = (d+1)/d` into `scaling_law_general` predicts the architecture-specific exponent
`-(α-1)/α = -1/(d+1)`. The key insight is that the NNGP kernel is a dot-product
kernel whose spherical-harmonic (Gegenbauer) coefficients are fixed by the
activation's smoothness, so the decay rate is read off from the Funk–Hecke formula.
**Test**: Formalize the Funk–Hecke eigenvalue formula for a dot-product kernel on
`S^{d-1}`, compute the ReLU coefficients' asymptotics, and feed the resulting `α`
into `scaling_law_general`.
**Why now**: With `scaling_law_general` accepting *arbitrary* real `α`, the only
missing ingredient is the eigenvalue asymptotic; Mathlib's spherical-harmonics and
growing Gegenbauer/orthogonal-polynomial support make Funk–Hecke approachable.
**If true**: Closes the loop from raw architecture to scaling exponent — a fully
formal `architecture ⟹ data efficiency` theorem.
**If false**: The harmonic coefficients decay differently than predicted, revealing
that depth or normalization (not just activation smoothness) controls the exponent.
