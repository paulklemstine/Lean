# Computational Evidence — Bayesian Werewolf

## 1. Posterior collapses to the prior

For the symmetric-information posterior
`posterior n k = C(n-1,k-1) / C(n,k)` we verified numerically that it agrees
exactly with the prior `k/n`:

| n  | k | posterior           | prior k/n |
|----|---|---------------------|-----------|
| 7  | 2 | 2/7                 | 2/7       |
| 20 | 5 | 1/4                 | 1/4       |

This is the small-case shadow of the exact theorem `posterior_eq_prior`.

## 2. Consensus-elimination game values

`winProb (w+v) w v` is the exact villager win-probability of the
consensus-elimination model (each round one uniformly random living player is
removed; villagers win when no werewolf remains, werewolves win at parity
`w ≥ v`).  Exact rational values:

| population n | werewolves k | villagers v | villager win prob |
|--------------|--------------|-------------|-------------------|
| 7            | 2            | 5           | 3/7  ≈ 0.4286     |
| 10           | 3            | 7           | 2/5  = 0.40       |
| 8            | 1            | 7           | 3/4  = 0.75       |
| 6            | 2            | 4           | 1/3  ≈ 0.3333     |

All values lie in `[0,1]`, matching the proved bounds `winProb_nonneg`,
`winProb_le_one`.

**Note on the informal 0.36 figure.**  The mission's quoted `≈ 0.36` for
`n = 7, k = 2` assumes a full day/night ruleset with nightly werewolf kills; our
rigorously specified consensus-only variant yields the exact value `3/7`.  We
therefore prove *exact* structural facts (symmetry, monotonicity, the parity
threshold, and the probability bounds) rather than fitting the heuristic
`C·(1 - k/(n-k))²` envelope, which is model-dependent and not exact.

## 3. Survival law spot check

The exchangeability law `survivalProb n t = (n - t)/n` was verified as an exact
identity via the double-counting lemma; e.g. a player survives `t` of `n`
removals with probability `(n-t)/n`, independent of the removal order.
