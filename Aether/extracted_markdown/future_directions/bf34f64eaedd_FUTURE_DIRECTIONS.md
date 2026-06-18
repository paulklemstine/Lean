# Future Directions — Chaos and the Three-Body Problem: Lyapunov Exponent Bounds (Cycle 2)

## Synthesis

This cycle extended `Catalog/Physics/LyapunovChaos.lean` from a one-sided,
infinitesimal description of chaos to a structured, two-sided, and *finite-distance*
theory of uniform expansion. The catalog had already established the multiplicative
chain-rule cocycle (`deriv_iterate_eq_prod`), its Birkhoff-sum logarithm, a uniform
lower bound on iterate stretching (`abs_deriv_iterate_ge`), positivity of the
finite-time Lyapunov exponent (`ftle_ge_log`), and the periodic-orbit entropy
(`entropy_periodic_growth`). The structural gap was that none of these results
expressed the *algebra* of how stretching composes over time, nor did they bound the
Lyapunov exponent from above, nor did they translate infinitesimal expansion into an
actual statement about how far apart two genuine orbits get.

We closed all three gaps. The additive cocycle identity `cocycle_deriv_iterate` and
its logarithmic form `log_cocycle_deriv_iterate` exhibit the exact subadditive/additive
structure `S_{m+n} = S_m ∘ σⁿ + S_n` that is the hypothesis of Kingman's subadditive
ergodic theorem and of the Oseledets multiplicative ergodic theorem — i.e. they are the
precise algebraic doorway through which the *asymptotic* (infinite-time) Lyapunov
exponent would be built. The matching upper bound `abs_deriv_iterate_le` and the
two-sided `ftle_sandwich` show the finite-time exponent is pinned in `[log c, log C]`,
making "chaos" (`ftle > 0`) the clean special case `c > 1`. The growth-rate robustness
lemma `growth_rate_of_subexponential` explains *why* the catalog's `dⁿ − 1` count gives
exactly `log d`: bounded multiplicative corrections are entropy-invisible. Finally,
`expansion_separation` upgrades infinitesimal expansion to the rigorous butterfly
effect — `cⁿ·|x−y| ≤ |fⁿx − fⁿy|` — via the mean value theorem; the decisive ingredient
is that the lower bound on `|f'|` holds *everywhere*, so we can control the derivative
at the unknown mean-value point.

What did not fully close: every result here is for one-dimensional smooth maps with a
*uniform* derivative bound. The genuine three-body problem is a flow on a high-dimensional
symplectic phase space with *non-uniform* hyperbolicity, where positivity of the maximal
Lyapunov exponent holds only on a positive-measure set, not everywhere. The cocycle
algebra we built is dimension-agnostic and is the right scaffold for the matrix
(Oseledets) generalization; the uniform-bound hypotheses are exactly what must be
relaxed next.

## Results Summary

- `cocycle_deriv_iterate`: proved — the multiplicative cocycle `(f^{m+n})'(x) = (f^m)'(f^n x)·(f^n)'(x)`, the algebraic backbone of Lyapunov theory.
- `log_cocycle_deriv_iterate`: proved — its additive (logarithmic) form, matching the hypothesis of the subadditive/multiplicative ergodic theorems.
- `abs_deriv_iterate_le`: proved — uniform upper bound `|(f^n)'| ≤ Cⁿ`, the missing counterpart to the catalog lower bound.
- `ftle_sandwich`: proved — two-sided bound `log c ≤ ftle ≤ log C`, generalizing the catalog's one-sided positivity into a quantitative window.
- `growth_rate_of_subexponential`: proved — exponential growth rate is `log d` for any sequence pinned to `dⁿ` up to a bounded factor, explaining and generalizing `entropy_periodic_growth`.
- `expansion_separation`: proved — rigorous sensitive dependence on initial conditions, `cⁿ·|x−y| ≤ |fⁿx − fⁿy|`, the finite-distance butterfly effect via the mean value theorem.

## Research Directions

### Direction 1: Asymptotic Lyapunov exponent via the cocycle
**Hypothesis**: For a `C¹` map with `0 < c ≤ |f'| ≤ C` everywhere, the limit
`λ(x) = lim_{n→∞} (1/n)·log|(f^n)'(x)|` exists for every `x` and lies in `[log c, log C]`.
**Test**: Define the additive observable `g(y) = log|f'(y)|` and the Birkhoff sums
`S_n = Σ_{i<n} g(f^i x)`; `log_cocycle_deriv_iterate` shows `S_n` is exactly the additive
cocycle. Prove the limit exists by showing the sequence `S_n/n` is Cauchy under the
two-sided bound, or by importing a Mathlib Birkhoff/Kingman result if one exists; verify
the bound via `ftle_sandwich`.
**Why now**: This cycle produced both the additive cocycle (`log_cocycle_deriv_iterate`)
and the uniform two-sided enclosure (`ftle_sandwich`) — the two ingredients an existence
proof needs. The key insight is that the *finite-time* sandwich already traps every tail,
so existence reduces to a monotonicity/Cauchy argument on a bounded sequence.
**If true**: Promotes the entire file from finite-time to genuine (asymptotic) Lyapunov
exponents, the object actually quoted for the three-body problem.
**If false**: Would reveal a map with persistent oscillation of `S_n/n` inside `[log c, log C]`,
a concrete obstruction (non-uniqueness of the exponent) worth isolating.

### Direction 2: Matrix cocycles and a 2-D Oseledets bound
**Hypothesis**: For a `C¹` map `F : ℝ² → ℝ²` whose Jacobian `DF` satisfies a uniform
lower singular-value bound `σ_min(DF) ≥ c > 1`, the smallest singular value of `D(F^n)`
is at least `cⁿ`, so the minimal Lyapunov exponent is `≥ log c > 0`.
**Test**: Replace scalar `deriv` by the Jacobian and the scalar product by the matrix
cocycle `D(F^{m+n}) = D(F^m)∘F^n · D(F^n)` (the literal matrix analogue of
`cocycle_deriv_iterate`); bound `‖(D F^n) v‖ ≥ cⁿ‖v‖` by composing operator-norm lower
bounds. Formalize for `2×2` real matrices first.
**Why now**: The key insight is that `cocycle_deriv_iterate` is dimension-agnostic — its
proof used only `deriv_comp`/`iterate_add`, both of which have `fderiv` analogues. The
three-body problem is intrinsically multidimensional, so this is the first faithful step.
**If true**: Brings the formalization into the dimension regime of the real problem.
**If false**: Pinpoints where scalar intuition breaks — e.g. non-commuting Jacobians
where the product of lower bounds fails — which is itself the central subtlety of
multidimensional chaos.

### Direction 3: Non-uniform hyperbolicity on a positive-measure set
**Hypothesis**: If `|f'(y)| ≥ c > 1` only for `y` in a forward-invariant set `A` of full
measure (not everywhere), then for a.e. `x ∈ A`, `liminf (1/n) log|(f^n)'(x)| ≥ log c`.
**Test**: This is where `expansion_separation` *breaks*: the mean value point `ξ` may
leave `A`. Replace the pointwise MVT bound by a Birkhoff-average argument — bound the
*fraction* of orbit time spent in the expanding region using the pointwise ergodic
theorem, then average `log|f'|`.
**Why now**: The key insight is that `expansion_separation`'s critical dependence on a
*global* lower bound (documented in its Lab Notebook failure analysis) exactly localizes
the obstruction to generalization. Having the clean uniform proof tells us precisely
which step must be replaced by an ergodic-average step.
**If true**: This is the actual regularity class of the three-body problem (Pesin theory).
**If false**: Produces an explicit a.e.-expanding map whose Lyapunov exponent is
nonetheless `≤ 0`, a striking counterexample about the necessity of uniformity.

### Direction 4: Sharpness of the entropy-robustness window
**Hypothesis**: The bounded-factor hypothesis in `growth_rate_of_subexponential` is sharp:
if `a n` is pinned only to `dⁿ` up to a factor `Kₙ` growing like `nᵅ` (polynomial), the
growth rate is still `log d`; but if `Kₙ` grows like `eⁿ` (exponential), the rate changes.
**Test**: Re-run the squeeze with `K` replaced by a sequence `Kₙ`; the `±log Kₙ / n` terms
vanish iff `log Kₙ = o(n)`. Prove the positive case for `Kₙ = nᵅ` and *disprove* the
boundary by exhibiting `a n = dⁿ·eⁿ` with rate `log d + 1`.
**Why now**: The key insight is that this cycle's proof of `growth_rate_of_subexponential`
isolated the exact quantity that must vanish (`log Kₙ / n`), turning a qualitative
"subexponential corrections don't matter" into a precise `o(n)` threshold ready to test.
**If true**: A clean characterization of which perturbations preserve topological entropy.
**If false**: Reveals a subexponential-but-faster-than-polynomial correction that already
shifts the rate, refining the threshold.

### Direction 5: Lyapunov–entropy variational inequality (toward Pesin/Ruelle)
**Hypothesis**: For a `C¹` map with `|f'| ≤ C` everywhere, the topological entropy `h`
satisfies `h ≤ log C` (Ruelle's inequality, scalar case), i.e. entropy is bounded by the
*maximal* expansion rate, the upper companion to the Pesin identity in the catalog.
**Test**: Combine `abs_deriv_iterate_le` (which caps total stretching by `Cⁿ`) with a
covering/separated-set definition of topological entropy: a `Cⁿ`-Lipschitz iterate cannot
separate more than `~Cⁿ` distinguishable orbits in `n` steps, bounding the entropy growth.
Use `growth_rate_of_subexponential` to extract the rate.
**Why now**: The key insight is that this cycle supplied the upper stretching bound
`abs_deriv_iterate_le` for the first time, and Ruelle's inequality is precisely an
upper bound on entropy by expansion — the catalog's Pesin identity only handled the exact
uniform case, so the genuine inequality direction is now reachable.
**If true**: Establishes the inequality half of the Pesin/Ruelle entropy formula, a
genuine dynamical-systems theorem rather than a uniform-model identity.
**If false**: Would expose a map whose entropy exceeds its maximal Lyapunov exponent,
contradicting Ruelle and signalling an error in the entropy formalization.
