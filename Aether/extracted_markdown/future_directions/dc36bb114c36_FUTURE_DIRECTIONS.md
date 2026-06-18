# Future Directions — BB84 Security, the QBER Threshold, and Privacy Amplification

The file `Catalog/Cryptography/QuantumSecurity/BB84Security.lean` formalizes the
Shor–Preskill secret-key rate `R(Q) = 1 - 2 H₂(Q)`, proves existence and
uniqueness of the QBER security threshold `Q⋆`, rigorously brackets it in
`(1/16, 1/8) = (6.25%, 12.5%)` (containing the textbook `≈ 11%`), shows the
intercept–resend attack (`Q = 1/4`) is always detectable, and proves that
privacy amplification drives an eavesdropper's distinguishing advantage
exponentially to zero. These results connect the `Real.binEntropy` analysis
toolkit to the catalog's `Cryptography/LeftoverHash.lean`
(`key_derivation_security_bound`, `leftover_hash_lemma_quantitative`). The
following directions extend that frontier; each is concrete, testable, and
falsifiable.

## 1. Pin the threshold to the true `≈ 11%` by a rational-log squeeze

Our brackets `binEntropy(1/16) < log2/2 < binEntropy(1/8)` were obtained
*without any floating-point bound on `log`*, using only the rational
inequalities `(8/7)^7 > 2` and `(16/15)^15 < 16`. The conjecture is that one can
drive the bracket to `Q⋆ ∈ (0.1098, 0.1101)` purely by such certified rational
comparisons of the form `(a/b)^n ⋚ 2^m`, with no appeal to numerical `Real.log`
estimates. **The key insight is** that `binEntropy(p) - log2/2` at a rational
`p = a/b` reduces, after clearing the `(1/2)log 2` term, to comparing a single
expression `k·log(a/b)` against `m·log 2`, i.e. to the rational inequality
`(a/b)^k ⋚ 2^m`, which `norm_num` decides on integers. **Why now?** We have a
*working, reproducible* instance of this technique (`binEntropy_inv16_lt`,
`binEntropy_inv8_gt`); generalizing it to a tactic-driven search over `(a,b,k,m)`
turns the historically "numerical" 11% constant into a *certified* rational
sandwich — something no existing QKD formalization provides.

## 2. The six-state protocol threshold (`≈ 12.62%`)

The six-state BB84 variant has secret-key rate
`R₆(Q) = 1 + (1 - 3Q/2)·log₂(1 - 3Q/2) + (3Q/2)·log₂(Q/2)`, with a higher noise
tolerance than BB84. The conjecture is that `R₆` has a unique root `Q⋆⁶ ∈ (0,1/2)`
strictly larger than the BB84 threshold `Q⋆`, i.e. **six-state QKD tolerates
strictly more noise**, and that `Q⋆⁶ ∈ (1/8, 5/32)`. **The key insight is** that
`R₆` can be re-expressed through `Real.binEntropy` and `Real.qaryEntropy` (already
in Mathlib) so that the *same* continuity + strict-monotonicity + IVT skeleton we
used for `bb84_secureKeyRate_root_existsUnique` applies verbatim, with the
strictness witnessed by `qaryEntropy_strictMonoOn`. **Why now?** Mathlib's
`qaryEntropy` API (concavity, monotonicity, derivative) landed recently and is
exactly the missing ingredient; our BB84 proof is a ready-made template to
specialize.

## 3. Finite-key security: an explicit extractable key length

Our `privacy_amplification_exp_bound` is asymptotic in the entropy gap `t`. The
conjecture is a *finite* statement: for a sift of `n` bits with observed error
rate `Q < Q⋆`, there is an explicit secure key length
`ℓ(n, Q, ε) = n·(1 - 2 H₂(Q)) - O(√n) - 2 log₂(1/ε)` such that the extracted key
is `ε`-close to uniform. **The key insight is** that the smooth min-entropy of
the raw key after error correction is `n·(1 - H₂(Q))` up to a Serfling/Hoeffding
sampling fluctuation, and feeding this gap into the leftover-hash bound
(`key_derivation_security_bound` composed with `privacy_amplification_exp_bound`)
yields the `2^{-t/2}` decay with `t = ℓ - (extractable min-entropy)`. **Why now?**
The catalog already contains both halves — `LeftoverHash.lean` for the extractor
side and our BB84 entropy-rate side — so the only new mathematics is a finite
concentration bound, which Mathlib's `Hoeffding`/`measure-theory` layer supports.

## 4. Convexity of the key-rate deficit and a one-sided robustness certificate

Because `Real.binEntropy` is strictly concave on `[0,1]`
(`strictConcave_binEntropy`), the key-rate deficit `D(Q) := 1 - R(Q) = 2 H₂(Q)`
is strictly *convex* on `[0,1/2]`. The conjecture is that this convexity yields a
*certified linear lower bound* on the key rate near any operating point `Q₀ < Q⋆`:
`R(Q) ≥ R(Q₀) - 2 H₂'(Q₀)·(Q - Q₀)` for all `Q`, giving a one-sided robustness
margin against error-rate misestimation. **The key insight is** that strict
convexity makes the first-order Taylor expansion a *global* under-estimator of the
deficit, so the derivative `deriv binEntropy Q₀ = log(1-Q₀) - log Q₀` (already a
clean closed form in Mathlib) becomes a verifiable security slope. **Why now?**
Mathlib exposes both `strictConcave_binEntropy` and the exact derivative
`deriv_binEntropy`, so the tangent-line certificate is a short formal step from
what we have, and it converts a qualitative "below threshold" guarantee into a
*quantitative* error-budget bound.

## 5. Mutual-unbiasedness forces the disturbance: a Pythagorean lower bound on QBER

Our `mub_overlap_half` records the Pythagorean overlap `cos²(π/4) = 1/2` of the
two BB84 bases. The conjecture is a quantitative information–disturbance law: any
intercept-and-measure strategy that extracts mutual information `I` about the key
necessarily induces a QBER `Q` obeying `I ≤ 1 - H₂(Q)`, with equality on the
optimal (Breidbart) basis where the disturbance is exactly the
`cos²(π/4) = 1/2`-driven `Q = 1/4` we proved detectable in
`secureKeyRate_quarter_neg`. **The key insight is** that the equal `1/2` overlap
of mutually unbiased bases is precisely the Pythagorean budget `sin² + cos² = 1`
that an adversary must "spend" as error whenever they gain which-basis
information — turning the geometric identity into an entropic inequality. **Why
now?** We already have the geometric fact formalized and the entropy/key-rate
scaffolding in place; the remaining work is a finite-dimensional inner-product
estimate, well within Mathlib's `InnerProductSpace` and `EuclideanSpace` APIs,
and it would be the first formal information–disturbance tradeoff in the catalog.
