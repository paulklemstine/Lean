# THEOREM_TRACE (internal — anti-hallucination ledger)

Every result below is taken verbatim from the Phase A Lean sources. No theorem is
invented or renamed into a grander claim. Files:

- `Catalog/Cryptography/BB84/KeyRateThreshold.lean`
- `Catalog/Cryptography/BB84/Protocol.lean`
- `Catalog/Cryptography/BB84/PrivacyAmplification.lean`
- `Catalog/Cryptography/InnerProductHash.lean` (Phase A output, namespace `InnerProductHash`)

| Lean name | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|
| `secureKeyRate` (def) | `r(Q) = log 2 − 2·binEntropy Q` (nats); `= 1 − 2H₂(Q)` in bits | yes | yes |
| `secureKeyRate_pos_iff` | `0 < secureKeyRate Q ↔ binEntropy Q < (log 2)/2` | yes | yes |
| `secureKeyRate_strictAntiOn` | `secureKeyRate` strictly decreasing on `[0, 1/2]` | yes | yes |
| `binEntropy_one_eighth_gt` | `(log 2)/2 < binEntropy(1/8)`, via `7^7 < 2^20` | yes | yes |
| `binEntropy_one_sixteenth_lt` | `binEntropy(1/16) < (log 2)/2`, via `2^56 < 15^15` | yes | yes |
| `binEntropy_one_quarter_gt` | `(log 2)/2 < binEntropy(1/4)` | no | yes |
| `exists_threshold` | `∃ p ∈ (1/16, 1/8), secureKeyRate p = 0` | yes | yes |
| `threshold_unique` | the critical `p*` is unique on `[0, 1/2]` | yes | yes |
| `secureKeyRate_one_quarter_neg` | `secureKeyRate(1/4) < 0` | yes | yes |
| `bobErrorProb` (def) | `0` if Eve guessed basis else `1/2` | yes | yes |
| `interceptResendQBER` (def) | expected Bob-error over Eve's uniform basis | yes | yes |
| `interceptResendQBER_eq` | `interceptResendQBER a = 1/4` | yes | yes |
| `interceptResend_insecure` | `secureKeyRate (interceptResendQBER a) < 0` | yes | yes |
| `threshold_lt_interceptResend` | `p* < interceptResendQBER a` | no | yes |
| `statDist_le_collision` | `∑|p i − 1/M| ≤ √(M·∑ p i² − 1)` | yes | yes |
| `privacyAmplification_exp_bound` | `∑|p i − 2^{−ℓ}| ≤ √(2^{ℓ−k})` when `∑ p² ≤ 2^{−k}` | yes | yes |
| `injective_extractor_impossible` | no deterministic compression is injective | yes | yes |
| `innerHash` (def) | `innerHash a x = ∑ i a_i x_i` over `ZMod 2` | yes | yes |
| `two_universal` | `2·#{a : innerHash a x = innerHash a y} = 2^n` for `x ≠ y` | yes | yes |
| `two_universal_k` | `2^k·#{A : ∀r, collision} = (2^n)^k` | yes | yes |
