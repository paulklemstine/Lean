# Future Directions — Scaling Laws from Statistical Mechanics

## Synthesis

The file `Catalog/MachineLearning/ScalingLaws.lean` establishes, fully formally
and with no `sorry`, that a Gaussian-Process / kernel model whose spectrum follows
a power law `λ_i = i^(-α)` produces a generalisation (truncation) loss

```
        L(N) = Σ_{i > N} λ_i = Σ_{i ≥ N+1} i^(-α)
```

that obeys a *sharp two-sided power law* for every resolution `N ≥ 1`:

```
        (N+1)^(1-α)/(α-1)  ≤  L(N)  ≤  N^(1-α)/(α-1).
```

The engine of the whole development is a single mathematical idea — the
sum–integral comparison for an antitone integrand — paired with one closed-form
evaluation, `∫_{x>c} x^(-α) dx = c^(1-α)/(α-1)`. Around this core we proved:

* `lam_summable` — the spectrum is summable **iff** `α > 1` (the convergent
  regime), i.e. exactly the condition under which a finite loss exists;
* `tailLoss_le` / `le_tailLoss` / `tailLoss_two_sided` — the sharp two-sided
  bound, hence the loss decays as exactly `N^(-(α-1))`;
* `tailLoss_antitone` — more resolved modes never increase the loss;
* `tailLoss_tendsto_zero` — the infinite-resolution (infinite-data) limit `L(N) → 0`;
* `tailLoss_asymptotic` — the strengthening `L(N) ∼ N^(1-α)/(α-1)`, i.e. the ratio
  `L(N) / (N^(1-α)/(α-1)) → 1`, pinning the leading constant to `1/(α-1)`.

This connects to the catalog's spectral / machine-learning line of work
(`Catalog/MachineLearning/NTKSpectral.lean`, `AsymptoticRate.lean`): the
neural-tangent-kernel spectrum is precisely the object whose power-law decay our
bounds turn into a quantitative loss law. The reusable atoms produced here —
`rpow_neg_antitoneOn` (antitonicity of `x ↦ x^(-α)`), `integral_Ioi_rpow_neg`
(the exact tail integral), and `summable_shift` (index-shift summability) — are
deliberately generic so that the next cycle can plug in richer spectra unchanged.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `lam_summable` | `Summable (λ_·) ↔ 1 < α` | proved |
| `tailLoss_two_sided` | `(N+1)^{1-α}/(α-1) ≤ L(N) ≤ N^{1-α}/(α-1)` for `N ≥ 1` | proved |
| `tailLoss_antitone` | `L` is antitone in `N` | proved |
| `tailLoss_tendsto_zero` | `L(N) → 0` | proved |
| `tailLoss_asymptotic` | `L(N)/(N^{1-α}/(α-1)) → 1` | proved |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. A verified Chinchilla-type compute-optimal frontier

Real training spends a finite compute budget `C` split between model size `M`
(number of resolved modes) and dataset size `D`. A realistic loss model is
`L(M, D) = A·M^(-(α-1)) + B·D^(-(β-1)) + L_∞` — an approximation tail (our
`tailLoss`) plus an estimation tail with its own exponent `β`, plus an irreducible
floor. Minimising under `M·D = C` is a one-dimensional convex problem whose
solution is itself a power law `M*(C) ∝ C^a`, `D*(C) ∝ C^b` with `a + b = 1`.
**The key insight is** that the optimal allocation exponents `a, b` are rational
functions of the two spectral exponents `α, β` *alone*, so the compute-optimal
frontier is fully determined by the kernel spectrum and reachable by the same
sum–integral machinery already verified here. **Why now?** The exact tail bounds
and their asymptotics are in Lean; what remains is a finite-dimensional
convexity/Lagrange argument for which Mathlib's `StrictConvexOn` / `IsMinOn` API
is mature. This is a falsifiable claim: it predicts a *specific* slope
`a = (β-1)/(α+β-2)` for the optimal model-size scaling, testable against the
empirical Chinchilla exponent.

### 2. Effective-exponent corrections at finite resolution

Empirically measured exponents drift with scale: the local log-log slope
`s(N) = -d log L / d log N` approaches `α-1` but is not equal to it. Our two-sided
bound already brackets `s(N)`. **The key insight is** that the *gap* between the
upper and lower bounds is a controlled power series in `1/N` — precisely
`(1 + 1/N)^(1-α) → 1`, which is exactly the quantity squeezed in
`tailLoss_asymptotic` — so the finite-size correction to the exponent is `O(1/N)`
with an explicit constant `(α-1)/2`. Formalising `s(N) = (α-1) + c/N + o(1/N)`
turns the qualitative "exponents drift" folklore into a theorem. **Why now?**
`tailLoss_asymptotic` is already proved; extracting the *rate* of convergence only
requires a second-order Taylor estimate of `x ↦ x^(1-α)` at `x = 1`, which
`Real.hasDerivAt_rpow_const` supplies directly. Falsifiable: it predicts the sign
and `1/N` magnitude of the bias in any finite-`N` exponent fit.

### 3. Regularly varying spectra and logarithmic corrections

Pure power-law spectra are an idealisation; real kernels have
`λ_i = i^(-α)·ℓ(i)` with a slowly varying factor `ℓ` (e.g. log corrections from
feature learning). **The key insight is** that our entire argument depends only on
`λ` being antitone and integrable — captured abstractly by `rpow_neg_antitoneOn`
and `AntitoneOn.sum_le_integral` — not on `λ` being an exact power. Hence the loss
scaling is governed by the *regular-variation index* via Karamata's theorem:
`L(N) ∼ N·λ_N/(α-1)` whenever `λ` is regularly varying of index `-α`. This
subsumes the pure power law and predicts logarithmic scaling-law corrections.
**Why now?** Mathlib's `Filter`/`IsBigO` asymptotics framework is growing, and the
antitone comparison lemmas we used already accept an arbitrary antitone `λ`; the
generalisation is mostly a statement-level abstraction plus a Karamata tail lemma.
Falsifiable: it predicts that a `log i` factor in the spectrum yields a `log N`
factor (not a changed power) in the loss.

### 4. Ridge regularisation and the resolution–noise tradeoff

Kernel *ridge* regression with ridge `δ > 0` does not sharply resolve the top `N`
modes; it down-weights mode `i` by `λ_i/(λ_i + δ)`, giving the soft loss
`L(δ) = Σ_i δ²λ_i/(λ_i+δ)²`. **The key insight is** that for the power-law
spectrum this soft cutoff is equivalent, up to constants, to a *hard* cutoff at the
effective resolution `N_eff(δ) = δ^(-1/α)`, so the verified hard-cutoff bound
transfers directly and yields `L(δ) ∝ δ^((α-1)/α)`. This links the regularised
loss to implicit early-stopping / learning-rate schedules. **Why now?** The
summand `δ²λ_i/(λ_i+δ)²` is again antitone in `i` for the power-law spectrum, so
`rpow_neg_antitoneOn` + `AntitoneOn.sum_le_integral` apply verbatim; only the
closed-form integral changes (a Beta-function value supported by Mathlib's
`integral_rpow` / `Real.Gamma`). Falsifiable: predicts the exact ridge exponent
`(α-1)/α`, distinct from the hard-cutoff exponent `α-1`.

### 5. Second-order sharpness via Euler–Maclaurin

Our upper and lower constants differ only by the `(N+1)` vs `N` base; the true
asymptotic constant is `1/(α-1)` (proved in `tailLoss_asymptotic`). **The key
insight is** that a full Euler–Maclaurin expansion with the Bernoulli correction
term gives the *next* coefficient, `L(N) = N^(1-α)/(α-1) + (1/2)N^(-α) + …`,
quantitatively closing the gap between our two bounds. **Why now?** Mathlib
contains an Euler–Maclaurin / summation-by-parts development; pairing it with the
explicit derivatives of `x^(-α)` (all available via `Real.rpow`) makes a verified
second-order scaling law a natural, self-contained next milestone built directly
on the lemmas proved in this cycle. Falsifiable: predicts a *specific* `+½ N^(-α)`
sub-leading term whose sign and magnitude can be checked numerically.
