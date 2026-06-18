# Future Directions — Scaling Laws from Statistical Mechanics

The companion file `ScalingLaws.lean` proves, from first principles, that a
Gaussian-Process kernel with power-law spectrum `λ_i = i^(-α)` (spectral exponent
`α > 1`) produces a generalisation loss `L(N) = Σ_{i>N} λ_i` that obeys a sharp
two-sided power law,

```
        (N+1)^(1-α)/(α-1)  ≤  L(N)  ≤  N^(1-α)/(α-1),
```

so the loss decays with the resolved-mode count `N` as exactly `N^(-(α-1))`. We
proved the spectrum is summable iff `α > 1`, that the loss vanishes in the
infinite-data limit, that it is monotone in `N`, and (the strengthening) that
`L(N) ∼ N^(1-α)/(α-1)` asymptotically. The following directions extend this
verified core toward the full empirical scaling-law phenomenology.

## 1. The compute-optimal frontier (a verified Chinchilla-type law)

Real training spends a finite compute budget `C` split between model size `M`
(number of resolved modes) and dataset size `D` (number of training samples). A
realistic loss model is `L(M, D) = A·M^(-(α-1)) + B·D^(-(β-1)) + L_∞`, the sum of
an approximation-error tail (our `tailLoss`) and an estimation-error tail with its
own exponent `β`, plus an irreducible floor `L_∞`. Minimising `L` subject to a
compute constraint `M·D = C` is a one-dimensional convex optimisation whose
solution is itself a power law `M*(C) ∝ C^a`, `D*(C) ∝ C^b` with `a + b = 1`.
**The key insight is** that the optimal allocation exponents `a, b` are rational
functions of the two spectral exponents `α, β` alone, so the compute-optimal
frontier is fully determined by the kernel spectrum and can be derived by the same
sum–integral comparison machinery already verified here. **Why now?** We already
have the exact tail bounds and their asymptotics in Lean; the remaining step is a
finite-dimensional convexity/Lagrange argument, for which Mathlib's
`InnerLE`/`StrictConvexOn` and `IsMinOn` API is mature, making a fully formal
derivation of a Chinchilla-style law immediately within reach.

## 2. Effective-exponent corrections at finite resolution

Empirically measured exponents drift with scale: the local log-log slope
`s(N) = -d log L / d log N` is not exactly `α-1` but approaches it. Our two-sided
bound already brackets `s(N)` between `(1-α)·log((N+1)/N)/log(1)`-type corrections.
**The key insight is** that the *gap* between the upper and lower bounds is itself a
controlled power series in `1/N` — precisely `(1 + 1/N)^(1-α) → 1` — so the
finite-size correction to the exponent is `O(1/N)` with an explicit constant
`(α-1)/2`. Formalising `s(N) = (α-1) + c/N + o(1/N)` would turn the qualitative
"exponents drift" folklore into a theorem. **Why now?** The asymptotic ratio
theorem `tailLoss_asymptotic` is already proved; extracting the *rate* of
convergence only requires a second-order Taylor estimate of `x ↦ x^(1-α)` at
`x = 1`, which `Real.hasDerivAt_rpow_const` supplies directly.

## 3. Beyond pure power laws: regularly varying spectra

Power-law spectra are an idealisation; real kernels have `λ_i = i^(-α)·ℓ(i)` with a
slowly varying factor `ℓ` (e.g. logarithmic corrections from feature learning).
**The key insight is** that the entire sum–integral comparison argument depends
only on `λ` being antitone and integrable, not on it being an exact power, so the
loss scaling is governed by the *regular-variation index* of the spectrum via
Karamata's theorem: `L(N) ∼ N·λ_N/(α-1)` whenever `λ` is regularly varying of
index `-α`. Formalising this would subsume the pure power law as a special case and
predict logarithmic scaling-law corrections. **Why now?** Mathlib has a growing
asymptotics/`Filter`-based `IsBigO` framework; the antitone comparison lemmas we
used (`AntitoneOn.sum_le_integral`) are already general enough to plug a regularly
varying `λ` in unchanged, so the generalisation is mostly a statement-level rewrite
plus a Karamata tail lemma.

## 4. Ridge regularisation and the resolution–noise tradeoff

Kernel *ridge* regression with ridge `δ > 0` does not sharply resolve the top `N`
modes; instead it down-weights mode `i` by `λ_i/(λ_i + δ)`, giving a soft loss
`L(δ) = Σ_i δ²λ_i/(λ_i+δ)²`. **The key insight is** that with the power-law
spectrum this soft cutoff is equivalent, up to constants, to a *hard* cutoff at the
effective resolution `N_eff(δ) = δ^(-1/α)`, so the verified hard-cutoff bound
transfers directly and yields `L(δ) ∝ δ^((α-1)/α)`. This connects the regularised
loss to the implicit early-stopping / learning-rate schedules used in practice.
**Why now?** The summand `δ²λ_i/(λ_i+δ)²` is again antitone in `i` for the
power-law spectrum, so the same `AntitoneOn` sum–integral toolkit applies verbatim;
only the closed-form integral changes (a Beta-function evaluation that Mathlib's
`integral_rpow`/`Real.Gamma` API can support).

## 5. Two-sided sharpness and matching constants

Our upper and lower constants differ only by the `(N+1)` vs `N` base; the true
asymptotic constant is `1/(α-1)` and we proved the ratio tends to `1`. **The key
insight is** that a full Euler–Maclaurin expansion with the Bernoulli correction
term would give the *next* coefficient, `L(N) = N^(1-α)/(α-1) + (1/2)N^(-α) + …`,
matching the exact second-order behaviour and closing the gap between our two
bounds quantitatively. **Why now?** Mathlib already contains an Euler–Maclaurin /
`sum_Ico` summation-by-parts development; pairing it with the explicit derivatives
of `x^(-α)` (all available via `Real.rpow`) makes a verified second-order scaling
law a natural, self-contained next milestone built entirely on the lemmas proved
in this cycle.
