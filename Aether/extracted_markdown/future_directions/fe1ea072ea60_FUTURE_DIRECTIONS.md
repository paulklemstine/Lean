# Future Directions — BB84 Security, the QBER Threshold, and Privacy Amplification

## Synthesis

The file `Cryptography/QuantumSecurity/BB84Security.lean` formalizes the
information-theoretic security core of the BB84 quantum key distribution
protocol through Mathlib's `Real.binEntropy` toolkit. Concretely, it defines the
Shor–Preskill secret-key rate `R(Q) = 1 - 2·H₂(Q)` (with the base-2 conversion
`H₂(Q) = binEntropy(Q)/log 2` tracked exactly), reduces the security boundary to
the clean transcendental equation `binEntropy Q = log 2 / 2`
(`secureKeyRate_eq_zero_iff`), and from there proves the existence and uniqueness
of a QBER security threshold `Q⋆ ∈ (0, 1/2)`
(`bb84_secureKeyRate_root_existsUnique`). The headline novelty is a **certified
rational sandwich** `Q⋆ ∈ (1/16, 1/8) = (6.25%, 12.5%)`
(`bb84_threshold_bracket`), bracketing the textbook `≈ 11%` without any
floating-point bound on `log`: the two bracket lemmas collapse, after writing
`binEntropy` at a dyadic rational in closed form (`binEntropy_inv8_eq`,
`binEntropy_inv16_eq`), to the *integer* inequalities `7^7 < 2^20` and
`2^56 < 15^15`, both decided by `norm_num`. The same closed-form technique shows
the intercept–resend attack at `Q = 1/4` is always detectable
(`secureKeyRate_quarter_neg`, via `binEntropy_quarter_gt` ⇐ `3 < 4`), that
privacy amplification drives the eavesdropper's distinguishing advantage
exponentially to zero (`privacy_amplification_decay`, the `(1/2)√(2^{-t})`
leftover-hash bound recast as a decaying exponential), and records the
Pythagorean mutual-unbiasedness overlap `cos²(π/4) = 1/2` (`mub_overlap_half`).
Together these connect the `Real.binEntropy` analysis API to the catalog's
`Cryptography/LeftoverHash.lean` extraction layer
(`key_derivation_security_bound`, `leftover_hash_lemma_quantitative`).

## Results summary

| Theorem | Statement | Engine |
|---|---|---|
| `secureKeyRate_eq_zero_iff` | `R(Q)=0 ↔ binEntropy Q = log 2 / 2` | field algebra, `log 2 > 0` |
| `bb84_secureKeyRate_root_existsUnique` | unique `Q⋆ ∈ (0,1/2)` with `R(Q⋆)=0` | IVT + strict monotonicity |
| `bb84_threshold_bracket` | `∃ Q ∈ (1/16,1/8), R(Q)=0` | IVT + `7^7<2^20`, `2^56<15^15` |
| `secureKeyRate_quarter_neg` | `R(1/4) < 0` | `binEntropy(1/4) > log 2 / 2` |
| `privacy_amplification_decay` | `eveAdvantage → 0` at `atTop` | `exp` composition |
| `mub_overlap_half` | `cos²(π/4) = 1/2` | `cos_pi_div_four` |

All main results depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## 1. Pin the threshold to the true `≈ 11%` by a rational-log squeeze

The bracket `binEntropy(1/16) < log 2 / 2 < binEntropy(1/8)` was obtained with no
numerical `log` estimate — only the rational comparisons `7^7 < 2^20` and
`2^56 < 15^15`. The conjecture is that one can drive the bracket to
`Q⋆ ∈ (0.1098, 0.1101)` purely by such certified integer comparisons
`a^k ⋚ b^m`, with no appeal to `Real.log` numerics. **The key insight is** that
`binEntropy(p) - log 2 / 2` at a rational `p = a/b` reduces, after clearing the
`(1/2)log 2` term as in `binEntropy_inv8_eq`/`binEntropy_inv16_eq`, to a single
comparison `k·log(a/b) ⋚ m·log 2`, i.e. to the integer inequality
`(a/b)^k ⋚ 2^m`, which `norm_num` decides. **Why now?** We have a working,
reproducible instance of the technique; generalizing it to a tactic-driven search
over `(a,b,k,m)` turns the historically "numerical" 11% constant into a *certified*
rational sandwich — something no existing QKD formalization provides. A natural
first milestone: prove `binEntropy(7/64) < log 2 / 2 < binEntropy(8/64)` to halve
the current interval.

## 2. The six-state protocol threshold (`≈ 12.62%`)

The six-state BB84 variant has secret-key rate
`R₆(Q) = 1 + (1 - 3Q/2)·log₂(1 - 3Q/2) + (3Q/2)·log₂(Q/2)`, with higher noise
tolerance. The conjecture is that `R₆` has a unique root `Q⋆⁶ ∈ (0,1/2)` strictly
larger than the BB84 threshold `Q⋆`, i.e. **six-state QKD tolerates strictly more
noise**, with `Q⋆⁶ ∈ (1/8, 5/32)`. **The key insight is** that `R₆` can be
re-expressed through `Real.binEntropy` and `Real.qaryEntropy` so the *same*
continuity + strict-monotonicity + IVT skeleton used in
`bb84_secureKeyRate_root_existsUnique` applies verbatim, with strictness
witnessed by `qaryEntropy_strictMonoOn`. **Why now?** Mathlib's `qaryEntropy`
API (concavity, monotonicity, derivative) is exactly the missing ingredient, and
our BB84 proof is a ready-made template to specialize. The strict ordering
`Q⋆ < Q⋆⁶` is the falsifiable headline: a single IVT comparison at `Q = 1/8`
where `R(1/8) > 0 > R₆(...)` would settle direction.

## 3. Finite-key security: an explicit extractable key length

`privacy_amplification_decay` is asymptotic in the entropy gap `t`. The
conjecture is a *finite* statement: for a sift of `n` bits with observed error
rate `Q < Q⋆`, there is an explicit secure key length
`ℓ(n, Q, ε) = n·(1 - 2 H₂(Q)) - O(√n) - 2 log₂(1/ε)` such that the extracted key
is `ε`-close to uniform. **The key insight is** that the smooth min-entropy of the
raw key after error correction is `n·(1 - H₂(Q))` up to a Serfling/Hoeffding
sampling fluctuation; feeding that gap into `key_derivation_security_bound`
composed with the `(1/2)√(2^{-t})` form already used in `eveAdvantage` yields the
`2^{-t/2}` decay with `t = ℓ - (extractable min-entropy)`. **Why now?** The
catalog already contains both halves — `LeftoverHash.lean` for the extractor and
our BB84 entropy-rate side — so the only genuinely new mathematics is a finite
concentration bound, supported by Mathlib's measure-theory layer.

## 4. Convexity of the key-rate deficit and a one-sided robustness certificate

Because `Real.binEntropy` is strictly concave on `[0,1]`
(`strictConcave_binEntropy`), the key-rate deficit `D(Q) := 1 - R(Q) = 2 H₂(Q)`
is strictly *convex* on `[0,1/2]`. The conjecture is a *certified linear lower
bound* on the rate near any operating point `Q₀ < Q⋆`:
`R(Q) ≥ R(Q₀) - 2 H₂'(Q₀)·(Q - Q₀)` for all `Q`. **The key insight is** that
strict convexity makes the first-order Taylor expansion a *global* under-estimator
of the deficit, so `deriv binEntropy Q₀ = log(1 - Q₀) - log Q₀` (the exact
`deriv_binEntropy` closed form) becomes a verifiable security slope. **Why now?**
Mathlib exposes both `strictConcave_binEntropy` and `deriv_binEntropy`, so the
tangent-line certificate is a short formal step from
`secureKeyRate_eq_zero_iff`, converting our qualitative "below threshold"
guarantee into a *quantitative* error-budget bound against QBER misestimation.

## 5. Mutual-unbiasedness forces the disturbance: a Pythagorean lower bound on QBER

`mub_overlap_half` records the Pythagorean overlap `cos²(π/4) = 1/2` of the two
BB84 bases. The conjecture is a quantitative information–disturbance law: any
intercept-and-measure strategy extracting mutual information `I` about the key
necessarily induces a QBER `Q` obeying `I ≤ 1 - H₂(Q)`, with equality on the
optimal (Breidbart) basis where the disturbance is exactly the
`cos²(π/4) = 1/2`-driven `Q = 1/4` we proved detectable in
`secureKeyRate_quarter_neg`. **The key insight is** that the equal `1/2` overlap
of mutually unbiased bases is precisely the Pythagorean budget `sin² + cos² = 1`
an adversary must "spend" as error whenever they gain which-basis information —
turning a geometric identity into an entropic inequality. **Why now?** We already
have the geometric fact and the entropy/key-rate scaffolding; the remaining work
is a finite-dimensional inner-product estimate, well within Mathlib's
`InnerProductSpace`/`EuclideanSpace` APIs, and it would be the first formal
information–disturbance tradeoff in the catalog.
