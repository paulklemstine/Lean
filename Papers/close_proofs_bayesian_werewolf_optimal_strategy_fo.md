# Computational Evidence — Bayesian Werewolf ↔ Vandermonde bridge

The bridge file `BayesianWerewolfHypergeometric.lean` claims two facts about the
hypergeometric weights

```
hyp n k t j = C(k,j) · C(n-k, t-j) / C(n,t)
```

(the probability that a random `t`-committee among `n` players, `k` of whom are
werewolves, contains exactly `j` werewolves):

1. **Normalization**: `∑_{j=0}^{t} hyp n k t j = 1`.
2. **Mean**: `∑_{j=0}^{t} j · hyp n k t j = t·k / n`.

## 1. Small-case calculations

### Normalization (= Vandermonde `∑_j C(k,j)C(n-k,t-j) = C(n,t)`)

| n | k | t | `∑_j C(k,j)C(n-k,t-j)` | `C(n,t)` | equal? |
|---|---|---|------------------------|----------|--------|
| 5 | 2 | 2 | C(2,0)C(3,2)+C(2,1)C(3,1)+C(2,2)C(3,0)=3+6+1=10 | C(5,2)=10 | ✓ |
| 6 | 3 | 3 | C(3,0)C(3,3)+C(3,1)C(3,2)+C(3,2)C(3,1)+C(3,3)C(3,0)=1+9+9+1=20 | C(6,3)=20 | ✓ |
| 7 | 2 | 3 | C(2,0)C(5,3)+C(2,1)C(5,2)+C(2,2)C(5,1)=10+20+5=35 | C(7,3)=35 | ✓ |
| 4 | 1 | 2 | C(1,0)C(3,2)+C(1,1)C(3,1)=3+3=6 | C(4,2)=6 | ✓ |

### Mean (= `t·k/n`)

| n | k | t | `∑_j j·C(k,j)C(n-k,t-j)` | `k·C(n-1,t-1)` | `mean = sum/C(n,t)` | `t·k/n` | equal? |
|---|---|---|--------------------------|----------------|----------------------|---------|--------|
| 5 | 2 | 2 | 0 + 1·(2·3) + 2·(1·1)=6+2=8 | 2·C(4,1)=8 | 8/10 = 4/5 | 2·2/5=4/5 | ✓ |
| 6 | 3 | 3 | 1·9 + 2·9 + 3·1 = 9+18+3=30 | 3·C(5,2)=30 | 30/20 = 3/2 | 3·3/6=3/2 | ✓ |
| 7 | 2 | 3 | 1·20 + 2·5 = 30 | 2·C(6,2)=30 | 30/35 = 6/7 | 3·2/7=6/7 | ✓ |
| 4 | 1 | 2 | 1·3 = 3 | 1·C(3,1)=3 | 3/6 = 1/2 | 2·1/4=1/2 | ✓ |

### Social-deduction corollary (`t = 1`)

For `t = 1` the mean collapses to `k/n`, the classical "prior = posterior" detection
probability. E.g. `n=5, k=2`: `hyp 5 2 1 1 = C(2,1)C(3,0)/C(5,1) = 2/5 = k/n`. ✓

## 2. OEIS

No new integer sequence is introduced; the identities used are the classical
Vandermonde convolution and binomial absorption, both standard.

## 3. Counterexample hunt

Both claims were checked over all `(n,k,t)` with `1 ≤ k ≤ n ≤ 8`, `1 ≤ t ≤ n`
(hand/`#eval`-style enumeration): no counterexample. The formal Lean proofs
`hyp_sum_one` and `hyp_mean` cover all `n,k,t` in the stated ranges unconditionally.

## 4. Notes

The tables confirm the reductions are *exact* — the probabilistic moments equal the
combinatorial closed forms with no error term — which is precisely why the bridge is a
clean identity rather than an approximation.
