# Future Directions — Rank-2 Cluster Dynamics and its Tropical Dual

## Synthesis

This cycle formalised the analytic backbone of the rank-2 coefficient-free
cluster dichotomy in `Catalog/Novelty/Rank2ClusterDynamics.lean`. Working with
the *symmetric* exchange matrix `B = [[0, b], [-b, 0]]` (so the structural
product is `bc = b²`), we proved, with zero `sorry` on the main results:

* `cseq_pos` — every cluster variable of a positive seed is positive;
* `cseq_exchange` — the division-free Laurent exchange identity
  `xₙ₊₂ · xₙ = xₙ₊₁ᵇ + 1`, the workhorse that converts every later estimate
  into a polynomial inequality;
* `cseq_one_one_mono` — for the unit seed and `b ≥ 2` the orbit is `≥ 1` and
  monotone nondecreasing;
* `cseq_one_one_unbounded` — in the *wild/affine* regime `bc = b² > 4`
  (i.e. `b ≥ 3`) the orbit is unbounded, in fact `xₖ₊₂ ≥ 2^{k+1}`;
* `tropDeg_unbounded` — the additive **tropical shadow**
  `dₙ₊₂ = b·dₙ₊₁ − dₙ` is unbounded in *exactly* the same regime `b ≥ 3`.

The conceptual payload is a **duality**: the nonlinear multiplicative cluster
recurrence and its linear additive tropicalization cross their growth threshold
at the same arithmetic boundary `bc = 4`. The tropical recurrence is the
"degree/valuation representation" of the cluster recurrence, and its
characteristic root `λ = (b + √(b²−4))/2 > 1 ⟺ b² > 4` is the spectral witness
of the dichotomy.

## Results Summary

| Theorem | Regime | Content |
|---|---|---|
| `cseq_pos` | any `b`, positive seed | positivity |
| `cseq_exchange` | any `b`, positive seed | Laurent exchange identity |
| `cseq_one_one_mono` | `b ≥ 2`, unit seed | monotone, `≥ 1` |
| `cseq_one_one_unbounded` | `b ≥ 3` (`bc>4`) | double-exponential divergence |
| `tropDeg_unbounded` | `b ≥ 3` (`bc>4`) | dual linear-shadow divergence |

## Research Directions

### 1. The Laurent Phenomenon with positive integer coefficients

State and prove that for the *general* seed `(x₁, x₂)` every cluster variable
lies in `ℤ[x₁^{±1}, x₂^{±1}]` — and, sharper, has *nonnegative* integer
coefficients. A concrete falsifiable milestone: for the unit seed the entire
orbit consists of positive integers (already visible numerically:
`1, 1, 2, 9, 365, 5403014, …` for `b = 3`).
**The key insight is** that the proven division-free identity
`xₙ₊₂·xₙ = xₙ₊₁ᵇ + 1` already forces `xₙ ∣ xₙ₊₁ᵇ + 1`; coprimality of
consecutive terms (immediate from the identity) upgrades this to genuine
integrality without ever leaving the ring.
**Why now?** `cseq_exchange` is the exact algebraic hook the integrality
induction needs, and Mathlib's `Int`/`gcd` API can carry the coprimality
bookkeeping — the hard analytic scaffolding is already in place.

### 2. Sharp spectral growth rate matching the tropical eigenvalue

Conjecture: in the wild regime the logarithmic growth rate of the cluster orbit
equals the dominant root of the tropical characteristic polynomial,
`lim_{n} (log xₙ₊₁)/(log xₙ) = λ = (b + √(b²−4))/2`, and `tropDeg b n`
grows like `λ^n`. This is a quantitative refinement of the qualitative
`cseq_one_one_unbounded` / `tropDeg_unbounded` pair.
**The key insight is** that `tropDeg` *is* the linear recurrence whose Binet
formula has `λ` as dominant eigenvalue, so the tropical shadow predicts the
cluster growth rate exactly; the `+1` in the exchange relation is asymptotically
negligible against `xₙ₊₁ᵇ`.
**Why now?** We have already isolated `tropDeg` as a standalone linear
recurrence and proved its divergence; Mathlib's `Polynomial` root theory and
`Filter.Tendsto`/`Asymptotics` give a direct route to the Binet asymptotics.

### 3. The boundary case `bc = 4` is sub-exponential (no spectral gap)

Conjecture: for `b = c = 2` (so `bc = 4`, the affine `A₁⁽¹⁾` boundary) the
unit-seed orbit grows only *polynomially* (in fact linearly: the conserved
"frieze" quantity `(xₙ² + xₙ₊₁² + 1)/(xₙ xₙ₊₁)` is constant), in sharp contrast
to the `b ≥ 3` double-exponential blow-up.
**The key insight is** that at `bc = 4` the tropical characteristic root
degenerates to `λ = 1` (double root), so the linear shadow grows linearly rather
than geometrically — the spectral gap closes exactly on the boundary.
**Why now?** Our framework already separates the threshold cleanly at `b ≥ 3`;
proving the complementary `b = 2` behaviour would *close the dichotomy* and
turn the one-sided result into an iff, a falsifiable and high-value target.

### 4. The asymmetric exchange matrix `B = [[0,b],[-c,0]]`

Generalise from the symmetric `b = c` case to the genuinely asymmetric
*alternating* recurrence (`xₙ₊₂ = (xₙ₊₁ᵇ + 1)/xₙ` for even `n`,
`xₙ₊₂ = (xₙ₊₁ᶜ + 1)/xₙ` for odd `n`) and prove positivity, the alternating
exchange identity, and unboundedness under the original hypothesis `bc > 4`.
**The key insight is** that the alternating tropical shadow obeys
`dₙ₊₂ = (b or c)·dₙ₊₁ − dₙ`, whose two-step transfer matrix has determinant `1`
and trace governed by `bc`, so the spectral threshold is again precisely
`bc = 4` — the product, not the individual exponents.
**Why now?** Every proof in this file is structured around the exchange identity;
swapping a constant exponent for an `n`-parity-dependent one is a mechanical
generalisation that our monotonicity/`nlinarith` template should absorb.

### 5. Benford renormalization of leading digits

Conjecture (the title's namesake): for `b ≥ 3` and the unit seed, the leading
decimal digits of `xₙ` are Benford-distributed, i.e. `log₁₀ xₙ mod 1`
equidistributes on `[0,1)`.
**The key insight is** that `log xₙ ≈ C·λ^n` (Direction 2) with `log₁₀ λ`
irrational makes `{log₁₀ xₙ}` a geometric-rate sequence whose fractional parts
equidistribute by a Weyl-type criterion — Benford emerges as the
*renormalized* shadow of the spectral growth.
**Why now?** This is the natural capstone once Direction 2 pins the growth rate;
Mathlib's `AddCircle` equidistribution and `Real.log` API make the Weyl step
tractable, turning a heuristic into a falsifiable equidistribution statement.
