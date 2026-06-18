# Future Directions: Rényi Divergence for Lattice Cryptography

The new module `RenyiDivergence.lean` formalizes the *multiplicative Rényi
divergence* `RD_α(P ‖ Q) = ∑ₓ P(x)^α Q(x)^{1-α}` over finite index sets and
proves its core structural properties: non-negativity, the diagonal value
`RD_α(P‖P) = ∑P`, **multiplicativity under independent products**, its
`m`-th-power behaviour for i.i.d. samples, the order-2 / collision-probability
bridge, and — as the analytic centrepiece — the **exact Gaussian shift
identity** `RD_α = exp(-π α(1-α)c²/s²) · ∑ᵢ ρ_s(latt i - αc)` together with the
flooding bound for `0 ≤ α ≤ 1`. A boundary counterexample shows independence is
essential, and a tightness witness shows the factor-`n` advantage loss cannot
be improved. These pieces suggest the following concrete next steps.

## 1. From the finite shift identity to a true smoothing-parameter bound

The proved identity `gaussian_renyiDiv_shift` reduces the Rényi divergence of a
shifted lattice Gaussian to a *recentred* lattice theta sum `∑ᵢ ρ_s(latt i - αc)`.
The remaining gap is to bound that recentred sum by the unshifted one,
`∑ᵢ ρ_s(latt i)`, up to a `(1+ε)` factor whenever `s` exceeds the smoothing
parameter `η_ε(Λ)`.

The key insight is that the recentred theta sum is a *translate* of the lattice
Gaussian, and the smoothing parameter is precisely the threshold above which the
lattice Gaussian is flat under translation (its Fourier transform off the dual
lattice is `≤ ε`). Combining this with our exact prefactor would upgrade
`gaussian_renyiDiv_flooding` from a conditional statement (assuming a sum bound
`Z`) into an unconditional `RD_α ≤ 1 + ε` bound — the form actually used in
security proofs.

Why now? `gaussian_renyiDiv_shift` already isolates the *only* non-algebraic
ingredient (translation-invariance of the theta sum). Mathlib's Poisson
summation (`Real.tsum_eq` / `EisensteinSeries` theta machinery) gives the dual
characterization needed, so the missing lemma is a self-contained analytic fact
rather than a from-scratch development.

## 2. Probability preservation under bounded Rényi divergence

A defining feature that makes Rényi divergence usable in cryptography is the
*probability preservation* property: if an event `E` has probability `p` under
`Q`, then under `P` it has probability at least `p^{α/(α-1)} / RD_α(P‖Q)^{1/(α-1)}`.
This is the lemma that converts a divergence bound into a security-loss bound.

The key insight is that probability preservation is exactly a reverse Hölder
inequality applied to the indicator of `E`: write `Q(E) = ∑_{x∈E} P(x)^{α/(α-1)·(α-1)/α}…`
and apply Hölder with exponents `(α, α/(α-1))`. Our `renyiDiv` definition already
uses `rpow`, so the statement lives in the same algebraic language.

Why now? The multiplicativity and `m`-th-power lemmas (`renyiDiv_multiplicative`,
`renyiDiv_pow_of_iid`) already give the *composition* half of the toolkit; the
probability-preservation lemma is the *consumption* half. Mathlib's
`inner_le_nnorm_mul_nnorm` / `NNReal.inner_le_iff` Hölder API is the only new
dependency, and the finite-support case avoids all measure-theoretic overhead.

## 3. Tightness of the Gaussian Rényi prefactor as α → 1

`gaussian_renyi_prefactor_le_one` shows the prefactor `exp(-π α(1-α)c²/s²) ≤ 1`
for `0 ≤ α ≤ 1`. The natural sharpening is a *two-sided* bound and a limiting
statement: as `α → 1⁺`, the logarithmic Rényi divergence
`R_α = log(RD_α)/(α-1)` converges to the KL divergence, and the leading term is
`π c²/s²`.

The key insight is that `log RD_α = -π α(1-α)c²/s² + log(theta ratio)`, so
`R_α = log(RD_α)/(α-1)` has the explicit closed form `π α c²/s² - (theta term)/(α-1)`;
differentiating at `α = 1` recovers the KL divergence `π c²/s²` exactly. This
makes the classical `R_α(N(c,σ²)‖N(0,σ²)) = α c²/(2σ²)` formula a *theorem about
our finite lattice object* in the smoothing limit.

Why now? The closed-form prefactor is already proved, so the limit is a
one-variable calculus fact (`Filter.Tendsto`, `deriv`) about an explicit
expression, not an analysis of an opaque divergence. The companion `theta ratio`
bound from Direction 1 supplies the only remaining input.

## 4. Rényi data-processing inequality for cryptographic post-processing

Reductions apply (possibly randomized) post-processing maps `f` to samples; a
divergence is only useful if it does not increase under such maps:
`RD_α(f∗P ‖ f∗Q) ≤ RD_α(P ‖ Q)` for `α ≥ 1`, where `f∗` is the pushforward.

The key insight is that for a deterministic surjection the pushforward groups the
sum into fibers, and the per-fiber inequality `(∑ pᵢ)^α (∑ qᵢ)^{1-α} ≤ ∑ pᵢ^α qᵢ^{1-α}`
is exactly the Rényi/Hölder convexity inequality already needed in Direction 2.
Thus data-processing is a *corollary* of the same reverse-Hölder lemma, applied
fiberwise and then summed.

Why now? Our `renyiDiv_multiplicative` proof already demonstrates the exact
`Finset` reindexing patterns (`Fintype.sum_prod_type`, `Finset.sum_mul_sum`)
needed to manipulate fibers via `Finset.sum_fiberwise`. Establishing
data-processing would make `renyiDiv` a genuine *monotone* security measure,
closing the gap between the algebraic toolkit and end-to-end reduction proofs.

## 5. Composed multi-step bound for the full search-to-decision reduction

The companion `SearchDecisionCore.lean` proves the per-coordinate pigeonhole
bound and `pigeonhole_bound_tight` shows the factor-`n` loss is optimal *for a
single extraction step*. The open quantitative question is the divergence cost of
the *entire* `n`-coordinate hybrid: combining `n` rerandomization steps, each
incurring a Rényi cost `RD_α ≤ 1+ε`, into a single end-to-end advantage bound.

The key insight is that the hybrid telescopes multiplicatively in the Rényi
metric — by `renyiDiv_pow_of_iid` the `n`-fold cost is `(1+ε)^n`, which stays
`≤ e^{nε} ≈ 1` precisely when `ε = O(1/n)`, exactly matching the parameter regime
where coordinate-by-coordinate reductions are believed tight.

Why now? Both endpoints already exist in the codebase: the combinatorial hybrid
infrastructure (`abstract_hybrid_telescope`, `search_to_decision_advantage_bound`)
and the multiplicative Rényi composition (`renyiDiv_pow_of_iid`). Bridging them
needs only the probability-preservation lemma of Direction 2, after which the
factor-`n` *advantage* loss and the `(1+ε)^n` *divergence* loss can be proved to
match — a fully formal, quantitatively tight search-to-decision theorem.
