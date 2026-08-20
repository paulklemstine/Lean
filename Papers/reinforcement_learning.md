# Computational evidence (exploratory)

All numbers below were produced by direct enumeration in Lean (`#eval`, `Float`
arithmetic) *before* the corresponding theorems were proved.  They are exploratory
sanity checks, **not** verification: the verified artifacts are the `sorry`-free Lean
theorems in `Catalog/Combinatorics/RLHF*.lean`.

Setting: response space `Finset (Fin n)` (all `2^n` feature sets), uniform SFT reference,
counting reward `r S = a·|S|`, KL temperature `β`.  The aligned (Gibbs) policy is
`π S ∝ e^{a|S|/β} / 2^n`; write `θ = σ(a/β) = e^{a/β}/(1+e^{a/β})`.

## 1. Level masses of the aligned policy vs. the binomial law (`n = 5, a = 1, β = 1`)

`θ = σ(1) ≈ 0.731059`.  Left column: mass of `{S : |S| = k}` obtained by enumerating all
32 subsets and normalizing; right column: `C(5,k) θ^k (1-θ)^{5-k}`.

| k | enumerated mass | binomial formula |
|---|-----------------|------------------|
| 0 | 0.001407 | 0.001407 |
| 1 | 0.019123 | 0.019123 |
| 2 | 0.103963 | 0.103963 |
| 3 | 0.282600 | 0.282600 |
| 4 | 0.384093 | 0.384093 |
| 5 | 0.208815 | 0.208815 |

Total mass: `1.000000`.  This is the evidence behind `gibbs_level_mass` /
`gibbsPolicy_sizeReward` (aligned policy = i.i.d. Bernoulli features, reward statistic
binomial).

## 2. Mean of the reward statistic

Enumerated `𝔼|S| = 3.655293`; predicted `n θ = 5 · 0.731059 = 3.655293`.
Evidence for `expected_size_bernoulli` / `expected_reward_gibbs`.

## 3. Log-concavity of the level masses (unimodality hunt)

`m_{k+1}² − m_k m_{k+2}` for `k = 0,1,2,3` at `n = 5, θ = σ(1)`:

```
[0.000219, 0.005404, 0.039931, 0.088516]     (all > 0)
```

No counterexample was found over the sampled range; the general statement is proved as
`choose_log_concave` / `binomialLevel_log_concave`, and unimodality follows
(`binomialLevel_decreasing_persists`).

## 4. Reward-hacking / mode-collapse bound (`n = 5, a = 1`)

Mass on the maximal response `θ^n` versus the proved lower bound `1 − n e^{−a/β}`:

| β    | `θ^5` (top mass) | bound `1 − 5 e^{−1/β}` |
|------|------------------|------------------------|
| 0.5  | 0.530126 | 0.323324 |
| 0.2  | 0.966981 | 0.966310 |
| 0.1  | 0.999773 | 0.999773 |
| 0.05 | 1.000000 | 1.000000 |

The bound holds in every sampled case and is asymptotically tight as `β → 0⁺`; this is
`gibbs_top_mass_ge`.

## 5. Counterexample hunt (negative results)

* Log-concavity was also probed with `θ < 1/2` (i.e. `a < 0`) and with `n` up to 8 — no
  violation.  Note the proved statement `binomialLevel_log_concave` needs only
  `0 ≤ θ ≤ 1`, and the boundary cases `k+2 > n` are handled separately (the mass is `0`).
* Monotonicity of the aligned policy on the lattice (`bernoulliSubsets_monotone`) *fails*
  for `θ < 1/2`: e.g. `n = 2, θ = 0.3`, `S = ∅`, `T = {0,1}` gives `0.49 > 0.09`.  This is
  why the theorem carries the guard `1/2 ≤ θ`, equivalently `a ≥ 0`.
* No OEIS entry is relevant beyond the binomial coefficients themselves
  (A007318, Pascal's triangle), which appear as the level multiplicities.
