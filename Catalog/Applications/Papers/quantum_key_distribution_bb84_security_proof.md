# Computational Evidence — BB84 Security (Key-Rate Threshold & Privacy Amplification)

All evidence below was produced with Lean `#eval` on `Float`/`ℚ`/`ℤ` before the
formal proofs were attempted, and every numeric claim used in a proof was reduced
to an exact integer/rational inequality that Lean checks with `norm_num`.

## 1. The secret-key rate and the ≈ 11% threshold

The one-way BB84 secret fraction is `r(Q) = 1 − 2 H₂(Q)` (bits), where `H₂` is the
binary entropy in bits. Working in **nats** (Mathlib's `Real.binEntropy`, with
`binEntropy ½ = log 2`), security `r(Q) > 0` is exactly `binEntropy Q < (log 2)/2`.

Float evaluation of `binEntropy Q − (log 2)/2` (root = threshold `p*`):

| Q       | binEntropy Q − (log 2)/2 |
|---------|--------------------------|
| 0.05    | −0.148058                |
| 1/16    | −0.112782                |
| 0.10    | −0.021491                |
| 0.11    | −0.000058  (≈ root)      |
| 0.115   | +0.010269                |
| 1/8     | +0.030197                |
| 0.12    | +0.020351                |
| 1/4     | +0.215762                |

So `p* ≈ 0.1100`, i.e. the textbook **≈ 11% QBER threshold**, and it is bracketed
by the rationals `1/16 < p* < 1/8` (6.25% – 12.5%).

### Reduction of the bracket to integer inequalities (key trick)

Using `binEntropy p = p·log p⁻¹ + (1−p)·log(1−p)⁻¹` and `log(aᵏ) = k·log a`:

* `binEntropy(1/8) > (log 2)/2  ⟺  7·log 7 < 20·log 2  ⟺  7^7 < 2^20`
  i.e. `823543 < 1048576`  ✓
* `binEntropy(1/16) < (log 2)/2 ⟺ 56·log 2 < 15·log 15 ⟺ 2^56 < 15^15`
  i.e. `72057594037927936 < 437893890380859375`  ✓
* `binEntropy(1/4) > (log 2)/2  ⟺  log 3 < log 4  ⟺  3 < 4`  ✓

These are exactly the `norm_num`-checkable facts that drive the Lean proofs of
`binEntropy_one_eighth_gt`, `binEntropy_one_sixteenth_lt`, `binEntropy_one_quarter_gt`.
**No floating-point or interval arithmetic on `log` is needed** — the transcendental
threshold is certified by integer comparisons.

## 2. Intercept–resend attack QBER

Modeling Eve's intercept–resend: conditional Bob error is `0` if Eve guessed the
basis, `1/2` otherwise; averaging over Eve's uniform basis gives
`QBER = ½·0 + ½·½ = 1/4 = 25%`, independent of the basis. Since `1/4 > 1/8 > p*`,
the attack is always above threshold (`r(1/4) < 0`).

## 3. Privacy amplification — Cauchy–Schwarz / counterexample hunt

Claim: for `p` with `∑ p = 1`, `∑ᵢ |pᵢ − 1/M| ≤ √(M·∑ᵢ pᵢ² − 1)`.

Counterexample hunt (does it ever fail?):

* **Point mass** `p = δⱼ`: LHS `= 2(1 − 1/M)`, RHS `= √(M − 1)`. For `M ≥ 2`,
  `2(1 − 1/M) ≤ √(M − 1)` holds (e.g. M=2: 1 ≤ 1; M=4: 1.5 ≤ 1.732; M=8: 1.75 ≤ 2.646).
* **Uniform** `p = 1/M`: LHS `= 0`, RHS `= 0`. Tight.
* **Two-point spikes** and random normalized vectors: bound always holds with slack.

No counterexample found — consistent with the Cauchy–Schwarz proof. Crucially the
search also revealed the bound never used `p ≥ 0`, so that hypothesis was dropped:
the statement is a pure second-moment inequality for any vector summing to 1.

Exponential corollary: with `M = 2^ℓ` and collision `∑ pᵢ² ≤ 2^{−k}`,
RHS `≤ √(2^{ℓ−k})`, exponentially small as the entropy gap `k − ℓ` grows.
