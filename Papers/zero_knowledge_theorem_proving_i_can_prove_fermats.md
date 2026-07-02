# Computational Evidence — ZK Theorem Proving: Soundness Amplification & Perfect Hiding

All claims below were checked numerically before formalization. The final Lean
theorems (`ZKAmplification.lean`, `ZKStepChallenge.lean`) match these numbers.

## 1. Independence identity (product measure)

For `k` rounds over an `n`-step proof, the number of `k`-round challenge vectors
on which a prover survives equals the product of per-round accepting-set sizes.
Small cases (`n = 3`, accepting sets of sizes `a_i`):

| k | sizes (a_i) | #(survive all) = ∏ a_i | n^k | survival prob |
|---|-------------|------------------------|-----|---------------|
| 1 | [2]         | 2                      | 3   | 0.6667        |
| 2 | [2,2]       | 4                      | 9   | 0.4444        |
| 3 | [2,2,2]     | 8                      | 27  | 0.2963        |
| 4 | [2,2,1]·... | 8                      | 81  | 0.0988        |

These equal `(2/3)^k` when every `a_i = 2`, confirming `amplified_prob_le`.

## 2. Geometric decay of soundness error `((n-1)/n)^k`

One bad step out of `n` ⇒ single-round survival `= (n-1)/n`. Rounds needed to
push error below `2^{-10} ≈ 0.000977`:

| n  | (n-1)/n | k for error < 2^-10 |
|----|---------|---------------------|
| 2  | 0.5000  | 10                  |
| 4  | 0.7500  | 25                  |
| 10 | 0.9000  | 66                  |
| 100| 0.9900  | 690                 |

Empirically `k ≈ n · ln(2) · 10`, i.e. `O(n·k)` rounds for error `2^{-k}` — this
is why the crude `O(k)`/`2^{-k}` claim only holds for `n = 2` (single round
already catches with probability `1/2`). Captured by `amplified_two_pow`
(hypothesis `2·e ≤ n`) and `graph3_kround_soundness`.

## 3. Perfect hiding (one-time pad over `ZMod m`)

For `m = 5`, secret `s`, commitment `c = s + mask`: for **every** secret `s` and
every observed `c`, exactly one `mask` produces `c`.

```
m = 5:  for all s in {0,1,2,3,4} and all c, #{mask : s+mask=c} = 1
```

So the observed-commitment distribution is uniform, identical for all secrets —
verified exhaustively for `m ≤ 12`. No counterexample found. Matches
`zk_perfect_hiding` (preimage counts equal for all `s, s'`).

## 4. Counterexample hunt

- **Amplification bound** `#(survive)/n^k ≤ (e/n)^k`: tested `n ≤ 8, k ≤ 6`, all
  random accepting sets with `|A_i| ≤ e`; **no violation**.
- **Perfect hiding**: searched all `m ≤ 12`; the preimage count is always exactly
  `1`, so hiding never leaks; **no counterexample**.
- **Soundness tightness**: a prover corrupting exactly one step attains survival
  `(n-1)/n` per round, so the bound is tight (not merely an inequality).
