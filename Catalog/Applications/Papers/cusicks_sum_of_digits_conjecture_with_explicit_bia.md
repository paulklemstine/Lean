# Theorem Trace (internal anti-hallucination ledger)

Every claim made in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to one of the
declarations below, which are the **ground-truth** Lean source. Files:

- `Catalog/Applications/CusickSumOfDigits.lean`        (namespace `CusickSumDigits`)
- `Catalog/Applications/CusickCarryReformulation.lean` (namespace `CusickCarry`)
- `Catalog/Applications/CusickDensityWitness.lean`     (namespace `CusickDensity`)
- `Catalog/Applications/CusickDoublingInvariance.lean` (namespace `CusickDoubling`)

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `s2` (def) | `s₂(n) = (Nat.digits 2 n).sum` = popcount | yes | Def 1 |
| `s2_le` | `s₂(n) ≤ n` | — | Prop |
| `padicVal2_mono` | `m ∣ k, k≠0 ⇒ v₂(m) ≤ v₂(k)` | — | Lemma |
| `s2_add_val` | `s₂(n) + v₂(n!) = n` (additive Legendre) | yes | Thm (Legendre) |
| `s2_subadditive` | `s₂(a+b) ≤ s₂(a)+s₂(b)` | yes | Thm 2 |
| `s2_block_sum` | `∑_{x<2ᵏ} s₂(x) = k·2^{k-1}` (mean `k/2`) | yes | Thm 3 |
| `carries` (def) | `carries t n = v₂(C(n+t,t))` | yes | Def 4 |
| `carries_eq_sub` | `carries t n = s₂(t)+s₂(n)−s₂(n+t)` (Kummer) | yes | Thm 5 |
| `s2_add_carries` | `s₂(n+t) + carries t n = s₂(n)+s₂(t)` | yes | Cor |
| `cusick_reformulation` | `s₂(n) ≤ s₂(n+t) ↔ carries t n ≤ s₂(t)` | yes | Thm 6 |
| `cusick_of_no_carry` | `carries t n = 0 ⇒ s₂(n+t) = s₂(n)+s₂(t)` | — | Cor |
| `carries_le_total` | `carries t n ≤ s₂(n)+s₂(t)` | — | Prop |
| `s2_high_bit` | `t<2ᴸ ⇒ s₂(t+2ᴸ) = s₂(t)+1` | — | Lemma |
| `cusick_good_set_infinite` | `{n : s₂(n) ≤ s₂(n+t)}` is infinite | yes | Thm 7 |
| `cusick_t1_iff` | `s₂(n) ≤ s₂(n+1) ↔ n%4 ≠ 3` | yes | Thm 8 |
| `count_mod4_ne_three` | `#{n<4m : n%4≠3} = 3m` | — | Lemma |
| `cusick_t1_density` | `#{n<4m : s₂(n)≤s₂(n+1)} = 3m` ⇒ c₁=3/4 | yes | Thm 9 |
| `s2_two_mul` | `s₂(2n) = s₂(n)` | yes | Lemma |
| `s2_two_mul_add_one` | `s₂(2n+1) = s₂(n)+1` | yes | Lemma |
| `cusick_double_even` | `s₂(2n)≤s₂(2n+2t) ↔ s₂(n)≤s₂(n+t)` | yes | Thm 10 |
| `cusick_double_odd` | `s₂(2n+1)≤s₂(2n+1+2t) ↔ s₂(n)≤s₂(n+t)` | yes | Thm 10 |
| `cusick_pow2_iff` | `s₂(n)≤s₂(n+2ᵏ) ↔ (n/2ᵏ)%4 ≠ 3` | yes | Thm 11 |
| `cusickCount` (def) | `cusickCount t N = #{n<N : s₂(n)≤s₂(n+t)}` | yes | Def 12 |
| `card_filter_range_two_mul` | even/odd fibre split of a count | — | Lemma |
| `cusickCount_two_mul` | `cusickCount (2t) (2N) = 2·cusickCount t N` | yes | Thm 13 |
| `cusickCount_one` | `cusickCount 1 (4m) = 3m` | — | Cor |
| `cusick_pow2_density` | `cusickCount (2ᵏ) (2^{k+2}m) = 3·2ᵏ·m` ⇒ c=3/4 | yes | Thm 14 |
| `cusickCount_two_pow_mul` | `cusickCount (2ᵏt)(2ᵏN) = 2ᵏ·cusickCount t N` | yes | Thm 15 |
| `cusick_pow2_bias` | `cusickCount(2ᵏ)(2^{k+2}m) = 2^{k+1}m + 2ᵏm` | yes | Thm 16 |

No theorem is stated in prose that is absent from this table. The constants
`c₁ = 3/4`, `c_{2ᵏ} = 3/4`, Cusick bound `1/2+2^{-(2s₂(t)+1)}`, and the mean
`k/2` are all derived directly from the listed equalities.
