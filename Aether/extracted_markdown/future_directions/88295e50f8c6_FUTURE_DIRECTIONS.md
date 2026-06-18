# Future Directions: BB84 Security Mathematics

The file `BB84Security.lean` formalizes the analytic core of the BB84 security
proof: the binary entropy function `h`, the Devetak–Winter secret-key rate
`r(Q) = 1 − 2h(Q)`, the *existence* of the ≈ 11 % QBER threshold (the zero of `r`
in `(0, 1/2)`), and the exponential decay of the leftover-hash privacy-amplification
bound. The results below are the natural next layer of theorems. Each is
falsifiable: it is stated as a precise Lean proposition that either compiles or
does not.

## 1. Uniqueness of the threshold and the sharp ≈ 0.1100 enclosure

Right now `qber_threshold_exists` gives *a* zero of `r` in `(0, 1/2)`. The next
step is to prove the threshold is **unique** and to **pin its value** to a tight
rational interval, e.g. `p* ∈ (0.1100, 0.1101)`. Uniqueness follows from strict
monotonicity of `r` on `(0, 1/2)`: since `h` is strictly increasing there, `r`
is strictly decreasing, so it crosses `0` exactly once.

The key insight is that strict monotonicity of `h` on `(0, 1/2)` reduces to the
sign of `h'(p) = log₂((1−p)/p)`, which is positive precisely when `p < 1/2`; this
turns a geometric "crossing once" statement into a one-line derivative-sign
computation. Why now? The current file already establishes continuity and the two
bracketing signs; adding `Real.deriv` of `binEntropy` (Mathlib has `Real.deriv_log`)
and `StrictMonoOn` is the only missing ingredient, so uniqueness is within immediate
reach.

## 2. Concavity of binary entropy and the data-processing inequality

Prove `h` is **concave** on `[0,1]` (`ConcaveOn ℝ (Icc 0 1) binEntropy`) and
deduce that the key rate `r` is **convex**, hence that mixing two error rates can
only help an eavesdropper. Concavity is the engine behind essentially every
entropy inequality used in QKD security (Holevo bound, data processing).

The key insight is that concavity of `h` is exactly nonpositivity of its second
derivative `h''(p) = −1/(p(1−p) ln 2) ≤ 0`, so the whole qualitative theory of
entropy bounds collapses to a single elementary inequality on `(0,1)`. Why now?
Mathlib's `InnerLeOuter`/`ConcaveOn` API plus `Real.deriv_logb` make the
second-derivative test mechanical, and concavity immediately upgrades several of
our pointwise facts (e.g. `h ≤ 1`) to global ones.

## 3. Finite-key security: the leftover-hash bound with explicit parameters

Our `leftoverDistance gap = ½·2^(−gap/2)` is the asymptotic form. The falsifiable
refinement is the **finite-`n` Tomamichel–Renner** statement: for a string of
smooth min-entropy `H_min^ε` and output length `ℓ`, the trace distance from
uniform is `≤ ε + ½·2^(−(H_min^ε − ℓ)/2)`, and choosing `ℓ = ⌊H_min^ε − 2 log(1/ε)⌋`
makes the total `≤ 2ε`.

The key insight is that the entire finite-key rate is governed by a single
"extractable randomness" quantity `H_min − ℓ`, so security with a *concrete* block
length `n` becomes an explicit inequality between integers and a logarithm rather
than a limit. Why now? We have already proved monotonicity and the exponential
limit of `leftoverDistance`; replacing the abstract `gap` by `H_min^ε − ℓ` and
adding the additive `ε` term is a direct, self-contained generalization.

## 4. The Shor–Preskill bridge: CSS codes and the entropic threshold coincide

State and prove that the **phase-error correctability threshold** of the relevant
CSS (Calderbank–Shor–Steane) code coincides with the entropic threshold of
Direction 1. Concretely: a CSS code of rate `R` corrects a fraction `Q` of
phase errors with vanishing failure probability iff `R < 1 − h(Q)`, which—paired
with bit-error correction—reproduces `r(Q) = 1 − 2h(Q) > 0`.

The key insight is that BB84 security is *exactly* a statement about classical
linear codes on the binary symmetric channel: the quantum threshold is the
Shannon capacity `1 − h(Q)` of a BSC, so the "11 %" number is a purely classical
coding-theory constant in quantum disguise. Why now? Mathlib's growing linear-algebra
and coding infrastructure (`Matrix`, `LinearMap`, finite fields) lets us model CSS
codes as pairs of nested classical codes and connect their dimension to `1 − h(Q)`
using the entropy bounds already proved here.

## 5. Robustness of the threshold under detector inefficiency and dark counts

In any real device the observed QBER is a *perturbation* `Q + δ(η, d)` of the
intrinsic error, where `η` is detector efficiency and `d` the dark-count rate.
Prove a **stability theorem**: the positive-rate region is open, i.e. there is an
explicit `δ₀ > 0` such that `r(Q) > 0` and `|Q' − Q| < δ₀` imply `r(Q') > 0`.

The key insight is that because `r` is continuous and strictly negative-sloped at
the threshold, security is *structurally stable*—a quantitative `δ₀` can be read
directly off the local slope `|r'(p*)| = |2 log₂((1−p*)/p*)|`, turning an
experimental-robustness question into a Lipschitz estimate. Why now? Continuity of
`r` is already in the file, and once Direction 1 supplies the derivative sign, an
effective `δ₀` is a short `linarith`/`nlinarith` argument away, giving the first
machine-checked robustness guarantee for the BB84 rate.
