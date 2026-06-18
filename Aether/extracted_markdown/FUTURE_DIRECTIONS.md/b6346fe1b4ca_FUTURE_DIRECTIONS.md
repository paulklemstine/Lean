# Future Directions — Scaling Laws from a Power-Law Kernel Spectrum

## Synthesis

`ScalingLaws.lean` proves, from a cold start, the spectral mechanism behind neural /
Gaussian-process **scaling laws**. For a kernel with a power-law eigenspectrum
`λ_i = i^(-α)` (`α > 1`) we establish that the spectral truncation error

```
E(n) = ∑_{i > n} λ_i = ∑_{i ≥ n+1} i^(-α)
```

— the proxy for the generalization error of a learner that has resolved the top `n`
eigendirections — obeys a genuine two-sided power law,

```
c · (n+1)^(1-α)  ≤  E(n)  ≤  C · n^(1-α),
```

so `E(n) = Θ(n^(1-α))` and the scaling exponent is **exactly `α - 1`**. The whole
result rests on one fact — antitone-function/integral comparison — applied in both
directions, with the exponent `α - 1 = -(r+1)` falling straight out of
`integral_rpow`. We also prove the finite-trace dichotomy: the total spectral power
`∑_i i^(-α)` is finite iff `α > 1`.

## Results summary

| Theorem | Statement |
|---|---|
| `summable_plaw_iff` | trace `∑_i i^(-α)` finite ⇔ `α > 1` |
| `plawFun_antitoneOn` | `x ↦ x^(-α)` antitone on `[1,∞)` for `α > 0` |
| `plawTail_le` | `E(n) ≤ n^(1-α)/(α-1)` for `n ≥ 1` (upper bound) |
| `plawTail_ge` | `E(n) ≥ (1 - 2^(1-α))/(α-1) · (n+1)^(1-α)` (lower bound) |
| `scaling_law` | `∃ 0 < c ≤ C`, `c·(n+1)^(1-α) ≤ E(n) ≤ C·n^(1-α)` — i.e. `E(n) = Θ(n^(1-α))` |

This bridges two existing catalog packages. `NTKSpectral.lean` shows the *spectrum*
of the NTK Gram matrix governs the *optimization* contraction rate; the present file
shows the *decay rate* of that same spectrum governs the *generalization* error
scaling law. It is also the non-parametric counterpart of `AsymptoticRate.lean`'s
`Θ(d/n)` parametric PAC-Bayes rate, replacing it with a spectral `Θ(n^(1-α))` rate.

## Research directions

### 1. Sharpen the lower bound to the exact leading constant `1/(α-1)`.
Our lower bound uses the single finite window `[n+1, 2(n+1)]`, giving the correct
*order* `(n+1)^(1-α)` but the constant `(1 - 2^(1-α))/(α-1)` rather than the optimal
`1/(α-1)`. **The key insight is** that summing the integral-comparison inequality over
*all* windows `[n+k, n+k+1]` and passing to the limit (`le_of_tendsto` against
`tendsto_rpow_neg_atTop`) collapses the telescoping integral to `n^(1-α)/(α-1)`,
matching the upper bound to the leading constant. This is *falsifiable*: one would
prove `∀ ε>0, ∃ N, ∀ n ≥ N, E(n) ≥ (1-ε)·n^(1-α)/(α-1)`. **Why now?** All ingredients
already live in the file (`AntitoneOn.integral_le_sum`, `Summable.sum_le_tsum`); only
the improper-integral limit, deliberately avoided for robustness, remains.

### 2. Asymptotic equivalence: `E(n) ~ n^(1-α)/(α-1)` as `n → ∞`.
Combining a tightened Direction 1 with `plawTail_le` yields a true asymptotic
`Filter.Tendsto (fun n => E(n) / (n^(1-α)/(α-1))) atTop (𝓝 1)`. **The key insight is**
that the upper and lower integral comparisons trap `E(n)` in an interval whose
endpoints have ratio `→ 1`, so the squeeze theorem delivers the equivalence directly.
This is *falsifiable* (the ratio either converges to `1` or it does not). **Why now?**
This is the natural capstone once the constants match; it upgrades `Θ` to `~` and is
the form practitioners quote for scaling-law exponents.

### 3. Log-corrected scaling at the critical exponent `α = 1`.
At `α = 1` the trace *diverges*, but a regularized/truncated error still scales — the
partial trace `∑_{i=1}^n i^(-1) = H_n ~ log n`. **The key insight is** that the same
integral comparison applied to `1/x` produces logarithmic rather than power-law growth,
giving `∑_{i=1}^n i^(-1) = log n + O(1)` (Mathlib already has harmonic-number /
`Real.log` asymptotics to build on). This is *falsifiable*: prove
`(∑_{i=1}^n i^(-1)) - log n` is bounded, and divergence of the full trace. **Why now?**
It closes the `α > 1` / `α = 1` / `α < 1` trichotomy started by `summable_plaw_iff`
and explains the empirically observed "log-slowdown" at the critical exponent.

### 4. Effective dimension and the optimal early-stopping/truncation rule.
Define the effective dimension `d_eff(n) = (∑_{i≤n} λ_i)² / ∑_{i≤n} λ_i²` and the
bias–variance tradeoff `R(n) = E(n) + σ²·n/N` for `N` samples and noise `σ²`. **The
key insight is** that substituting the proven `E(n) = Θ(n^(1-α))` into `R(n)` and
minimizing over `n` gives an optimal truncation `n* = Θ(N^{1/α})` and an excess risk
`R(n*) = Θ(N^{-(α-1)/α})` — a *compute-optimal* scaling law derived purely from the
spectrum. This is *falsifiable* via the explicit minimizer. **Why now?** It connects
this file's generalization scaling to `AsymptoticRate.lean`'s sample-complexity `n/N`
term, producing the cross-domain "Chinchilla-style" compute-optimal exponent.

### 5. From power laws to general regularly-varying spectra.
Replace `λ_i = i^(-α)` by `λ_i = i^(-α) · ℓ(i)` with `ℓ` slowly varying (e.g.
`ℓ(i) = (log i)^β`). **The key insight is** that the integral-comparison engine is
*agnostic to the slowly varying factor*: Karamata's theorem guarantees
`E(n) ~ n^(1-α)ℓ(n)/(α-1)`, so the proof skeleton of `plawTail_le`/`plawTail_ge`
transfers with `ℓ` carried through the integral. This is *falsifiable* by testing the
predicted `(log n)^β` correction against the integral comparison. **Why now?** Real
kernels rarely have exact power-law spectra; abstracting to regular variation makes
the catalog's scaling-law result apply to the spectra actually measured in practice.
