# Computational evidence — exp 559 (ADAPT-NULL-EQUALIZER / SKIP-FLIP-WINS)

Scope: the numerical checks that guided the four Lean files in `Catalog/Probability/`
(`AdaptiveQSAllocation`, `AdaptiveQSSkipFlip`, `AdaptiveQSDiscordance`,
`AdaptiveQSResidueRate`, `AdaptiveQSThresholdTradeoff`, `AdaptiveQSPrefixOptimality`,
`AdaptiveQSInversionMass`, `AdaptiveQSTieSlack`, `AdaptiveQSFactorBaseRate`).

Status legend:

* **[Lean]** — reproduced as a machine-checked theorem in this project (no `sorry`).
* **[explore]** — ad-hoc numerical exploration only; **not** verified.

---

## 1. The quadratic-residue mechanism is exact

Hit counts of `x² − N (mod p)` over one full period, `N = 8051 = 83 · 97`:

| p  | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 |
|----|---|---|---|----|----|----|----|----|----|----|
| hits/period | 0 | 2 | 2 | 0 | 2 | 0 | 0 | 2 | 0 | 0 |

Every count is `0` or `2`, never anything else — no statistical spread at all. **[explore]**
for the table; the dichotomy itself is **[Lean]**:
`card_sq_eq_two_of_isSquare` (exactly two solutions for an admissible odd prime with
`N ≢ 0`), `card_sq_eq_zero_of_not_isSquare` (exactly none otherwise),
`periodRate_eq_two_div` and `periodRate_eq_zero` (rate `= 2/p` resp. `= 0`), and
`nonresidue_not_dvd_qsValue` (no sieve value at all is divisible).

This is why the "hard tail" is unreachable rather than merely expensive.

## 2. Inverse-rate reallocation always loses

Relative yield change of `length ∝ 1/rate` against the uniform baseline, over 2000
random rate vectors with `r ~ U(0.2, 2.0)` **[explore]**:

| n  | worst | mean | best |
|----|-------|------|------|
| 4  | −61.2% | −20.9% | −0.010% |
| 8  | −55.5% | −24.9% | −1.17% |
| 16 | −47.8% | −26.9% | −3.21% |

The best case over 6000 trials is still negative — the sign never flips. That is exactly
the content of **[Lean]** `invRate_yield_le_uniform_yield` (`≤`, always) and
`invRate_yield_lt_uniform_yield` (`<`, whenever two rates differ): the policy yields
`B ·` harmonic mean against the baseline's `B ·` arithmetic mean.

## 3. The floor clip is monotone, not a tuning trick

Rates `(0.3, 0.7, 1.1, 2.0)`, budget `B = 4`, clipped policy
`ℓᵢ = f + (B − n f)(1/rᵢ)/Σ(1/r)` **[explore]**:

| floor f | 0 | 0.2 | 0.5 | 0.8 | 1.0 (= B/n) |
|---|---|---|---|---|---|
| yield | 2.593 | 2.894 | 3.346 | 3.799 | 4.100 |

Strictly increasing, ending exactly at the uniform baseline `4.100`. **[Lean]**
`clipYield_eq` (the yield is affine in `f`), `clipYield_mono`, `clipYield_strictMono`,
`clipInvAlloc_zero` (`f = 0` is the unclipped policy), `clipInvAlloc_full`
(`f = B/n` is the uniform baseline).

## 4. Skip-flip under a noisy dial

`n = 20` targets, `r ~ U(0,1)`, dial `d = r + U(−ε, ε)`, threshold at the 30th
percentile of `d`, 400 replicates **[explore]**:

| ε | retention | work fraction | discordant-pair fraction |
|---|-----------|---------------|--------------------------|
| 0.0 | 0.900 | 0.700 | 0.000 |
| 0.1 | 0.899 | 0.700 | 0.030 |
| 0.3 | 0.873 | 0.700 | 0.081 |
| 0.6 | 0.829 | 0.700 | 0.132 |

Retention exceeds the work fraction at every noise level, and degrades *linearly* in the
inversion count. Compare the reported deployment point: `89.5%` retention at `71.7%` of
the work. **[Lean]** `retention_ge_work_fraction` and `skip_throughput_gt` (the exact
`ε = 0` statement), `approx_dial_retention` / `approx_dial_threshold_gain` (the `2ε`
degradation), and `retention_of_discordance` / `throughput_le_of_discordance` (the linear
discordance budget `M · |Disc|`).

## 5. A fully explicit instance, checked in Lean

Rates `(1, 2, 5)`, budget `3`. **[Lean]** (`labnote_invRate_loses`, `labnote_skip_gain`,
`labnote_concentrator_gain`):

* uniform yield `8`, inverse-rate yield `90/17 ≈ 5.29` (loss ≈ 34%);
* skipping the worst target: retention `7/8 = 87.5%` at `2/3 ≈ 66.7%` of the work,
  throughput `8/3 → 7/2`;
* concentrator yield `15`, equal to the oracle bound `B · max r`.

## 6. Prefix optimality of quota-constrained deferral (added cycle 2)

Rates `(3, 1, 0)` on three targets with relation quota `Q = 3`. **[Lean]**
(`labnote_quota_minimal`, `labnote_throughput`):

* the single top target `{0}` already clears the quota, and no schedule of smaller
  cardinality can (the empty schedule yields `0`), so the minimum work is `1` of `3`
  targets — `66.7%` of the work deferred at `100%` of the quota;
* throughput rises from `4/3` (all three targets) to `3` (top target only).

The general statement behind this instance — that no schedule can beat the top-`k`
schedule of the same size, and that any maximiser is separated — is not left to sampling:
it is the proved exchange argument `separated_of_max_sum`, so no numerical sweep is
reported here.

## 7. Cycle-3 instances, checked in Lean

**Inversion mass vs. the linear budget.**  Rates `(10, 3, 2)` with a dial ranking them
`(10, 2, 3)`: the dial is right about the dominant target and merely swaps the two nearly
equal small ones.  **[Lean]** (`massLab_discordantPairs`,
`labnote_inversion_mass_strictly_better`): exactly one inversion, refined penalty
`3 − 2 = 1`, old penalty `M · |Disc| = 10 · 1 = 10` — a factor `10` improvement on an
instance whose shape (one dominant target, a cluster of near-ties) is the shape of a real
factor base.

**Tie slack.**  Rates `(3, 3, 1)` with quota `Q = 3`.  **[Lean]**
(`tieLab_keepSet`, `labnote_tie_slack_is_one`): one target suffices, but the threshold at
`θ = 3` retains two, so the tie multiplicity is exactly `1`.  This is the term isolated by
`keepSet_card_eq_add_tie_slack`, and it is exactly what `periodRate_injOn_admissible`
rules out on a factor base.

**Aggregate rate of a real base.**  `N = 2`, factor base `{7, 17}`; both primes are
admissible because `2 = 3²` in `ZMod 7` and `2 = 6²` in `ZMod 17` (both decided, not
assumed).  **[Lean]** (`labFB_admissible`, `labnote_factorBase_seven_seventeen`,
`labnote_oracle_is_seven`): aggregate per-period rate `2/7 + 2/17 = 48/119 ≈ 0.4034`, and
the oracle target is the smaller prime `7` with rate `2/7 ≈ 0.2857`.  The headroom ratio
predicted by `headroom_ratio_eq` is `2 / (7 · (1/7 + 1/17)) = 2 · 17 / 24 ≈ 1.4167`, well
below the crude ceiling `|A| = 2` — the same qualitative gap as the measured `+74.8%`
headroom against a much larger combinatorial ceiling. **[explore]** for the decimal
values, **[Lean]** for the exact rationals.

## 8. Sequences

No new integer sequence arises: the only integer data here are the per-period solution
counts, which take the values `0` and `2` only (Section 1), so an OEIS lookup is not
informative.
