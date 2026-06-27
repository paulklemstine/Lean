# Computational Evidence — Landauer's Principle at the Nanoscale (v19a)

This cycle extends the existing Landauer development
(`Logic.JarzynskiLandauer`, `Physics.LandauerSecondLaw`,
`Physics.LandauerSaturation`, `Physics.LandauerRelativeEntropy`,
`Physics.LandauerThermodynamicLimit`) with two new finite-size results.

## 1. Exponential bound on second-law violations (Jarzynski / Chernoff)

**Claim.** With the finite Jarzynski equality `E[exp(-αW)] = exp(-αΔF)` and `α > 0`,
the total probability that the dissipated work falls *below* the free-energy bound by
a margin `ξ` is at most `exp(-α ξ)`:

    P(W < ΔF - ξ) ≤ exp(-α ξ).

**Two-outcome small case.** Take a single bit with `p = (1/2, 1/2)` and work values
`W = (w₀, w₁)`. The Jarzynski equality fixes

    ΔF = -(1/α) · log( (e^{-αw₀} + e^{-αw₁}) / 2 ).

For `α = 1`, `w₀ = 0`, `w₁ = 2`:
* `ΔF = -log((1 + e^{-2})/2) ≈ 0.566`.
* The only outcome with `W < ΔF - ξ` for `ξ = 0.3` is `ω₀` (`W = 0 < 0.266`),
  contributing probability `1/2 = 0.5`.
* Bound: `exp(-1·0.3) ≈ 0.741`.  Indeed `0.5 ≤ 0.741`. ✓

For `ξ = 0.6` the threshold `ΔF - ξ ≈ -0.034 < 0`, so no outcome qualifies, the
left side is `0`, and `0 ≤ exp(-0.6) ≈ 0.549`. ✓

The bound is the finite-size, fluctuation-theorem refinement of the statement
"erasure costs at least `kT log 2`": violations of the bound are not impossible, but
they are *exponentially rare* in the margin `ξ` (measured in units of `1/α = kT`).

## 2. Maximum-entropy / "uniform is worst case" bound

**Claim.** For any initial PMF `p` on a finite memory with `N` states,

    H(p) = log N − D(p ‖ uniform)   and hence   H(p) ≤ log N,

so the Landauer erasure cost `kT·H(p)` is maximised by the uniform distribution.

**Small cases.**
* `N = 2`, `p = (1/2,1/2)`: `H = log 2 ≈ 0.693 = log N`. Saturates. ✓
* `N = 2`, `p = (1, 0)` (already erased): `H = 0 ≤ log 2`. ✓
* `N = 4`, `p = (1/2,1/4,1/8,1/8)`: `H = 1.75·log 2 ≈ 1.213 ≤ log 4 ≈ 1.386`. ✓

The identity is the Gibbs-inequality identity `H(p) = log N − D(p‖u)`; nonnegativity of
`D` (proved in the catalog as `LandauerRelativeEntropy.relativeEntropy_nonneg`) gives
the max-entropy bound directly, so the uniform/`n`-bit cost analysed in
`LandauerThermodynamicLimit` is the most expensive erasure of an `N`-state memory.

Both claims are standard textbook facts; the numerics above are confirmatory sanity
checks. The formal proofs are in `Physics/LandauerFluctuationBound.lean` and
`Physics/LandauerMaxEntropy.lean`.
