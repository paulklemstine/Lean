# Computational evidence — portfolio regret over an invisible channel (exp 560)

All numbers marked **[Lean]** are theorems in `Catalog/Probability/`, proved with
exact rational arithmetic and no `sorry`, `native_decide`, or extra axioms.
Numbers marked *(exploratory)* come from a small ad-hoc enumeration and are
**not** machine-verified; they were used only to pick the witnesses that are
verified in Lean.

## 1. The exp-560 portfolio, exactly

Model: hidden powersmoothness class `c ∈ {ρ, p−1@256, PM1@1024, Fermat, TD}`
with masses `(0.580, 0.345, 0.045, 0.028, 0.002)`, an independent observable bit,
cost `1` on the owned class and `penalty = 1179/140 ≈ 8.4214` elsewhere.

| quantity | value | status |
| --- | --- | --- |
| oracle cost, every instance | `1` | **[Lean]** `exp560_oracle` |
| oracle winner shares | `0.580, 0.345, 0.045, 0.028, 0.002` | **[Lean]** `exp560_winner_shares` |
| best static member | `ρ`, expected cost `4117/1000 = 4.117` | **[Lean]** `exp560_bestConstant` |
| static regret | `3117/1000 = 3.117` | **[Lean]** `exp560_staticRegret` |
| best dial rule (reads the observable) | never below `4.117`, i.e. `Δ = 0` | **[Lean]** `exp560_no_dial_edge` |
| two-armed "learned" rule | `279385/56000 ≈ 4.98902`, strictly worse | **[Lean]** `exp560_ml_rule_strictly_worse` |
| paid probe worth its price iff | `κ < 3.117` | **[Lean]** `exp560_probe_threshold` |
| mass of the losing minority for `ρ` | `≥ 0.42`, forced by the mean | **[Lean]** `exp560_tail_mass_forced` |

The penalty `1179/140` was chosen so that the model's static regret is *exactly*
the measured `3.117`; the winner shares are the measured ones rescaled to exact
rationals summing to `1` (`580 + 345 + 45 + 28 + 2 = 1000`).

## 2. Median-vs-mean separation

Two-instance family with weights `(3/4, 1/4)` and costs
`cost = [[1, 8M+8], [4M+4, 1]]`:

| `M` | best static member | median regret ratio | mean regret ratio |
| --- | --- | --- | --- |
| `0` | member `0` | `1` | `7/4` |
| `1` | member `0` | `1` | `11/4` |
| `10` | member `0` | `1` | `47/4` |
| general `M ≥ 0` | member `0` | `1` | `M + 7/4 > M` |

**[Lean]** `median_one_mean_unbounded` proves the general row: the median regret
ratio is pinned at `1` while the mean is unbounded, so the reported
"median regret 1.000 for all strategies" carries no information about the loss.

## 3. Mean order vs dominance in distribution (the H3 ledger entry)

Counterexample used: `X ∈ {0, 10}` with probability `(1/2, 1/2)` versus the
constant `Y ≡ 6`.

* `E[X] = 5 < 6 = E[Y]` — a mean elimination would delete `Y`;
* `P(X > 6) = 1/2 > 0 = P(Y > 6)` — no stochastic dominance.

**[Lean]** `mean_lt_not_stochDom`; the valid converse direction
(`StochDom → mean inequality`) is **[Lean]** `ev_le_of_stochDom`, proved through
the exact finite layer-cake identity `ev_nat_layercake`.

A portfolio version: with weights `(3/4, 1/4)` and costs `[[1,5],[5,1]]`, member
`1` has mean `4` against member `0`'s mean `2`, yet deleting member `1` doubles
the oracle's expected cost from `1` to `2` — **[Lean]** `mean_elimination_unsafe`.

## 4. The hidden channel is genuinely `N`-invisible

Verified witnesses (**[Lean]** `smoothness_invisible_at_bitlength_11`):

| instance | factors | `p−1`, `q−1` | `256`-powersmooth? | `N` | bits |
| --- | --- | --- | --- | --- | --- |
| smooth | `1051 · 1033` | `1050 = 2·3·5²·7`, `1032 = 2³·3·43` | yes / yes | `1085683` | 21 |
| rough | `1319 · 1307` | `1318 = 2·659`, `1306 = 2·653` | no / no | `1723933` | 21 |

Both moduli have exactly 21 bits and all four prime factors exactly 11 bits, so
the pair `(bit length, balance)` — the entire `N`-visible profile used by the
dial rules — takes the same value on the two instances while the hidden
coordinate differs.

*(exploratory)* Census of the `137` primes in `[2^10, 2^11)`, by largest prime
power dividing `p − 1`:

| bound `B` | count with `p−1` `B`-powersmooth | fraction |
| --- | --- | --- |
| 64 | 65 | 0.474 |
| 128 | 90 | 0.657 |
| 256 | 106 | 0.774 |
| 512 | 123 | 0.898 |
| 1024 | 137 | 1.000 |

Median largest prime power of `p − 1`: `71`.  Both classes are populated at every
bit length in the range, which is what makes the invisibility hypothesis
plausible beyond the single verified witness pair.

## 5. Why a probe fixes it

**[Lean]** `dvd_pow_lcmUpTo_sub_one`: if `p − 1` is `B`-powersmooth then
`p ∣ a^{lcm(1..B)} − 1` for every `a` prime to `p`.  So the short-capped `p − 1`
probe *is* an observation of the hidden coordinate, and the value-of-information
theorems (`paid_probe_beneficial_iff`, `dialValue_mono_of_refines`) apply to a
non-vacuous observation.

## 6. How sharp is the ε-invisibility bound?  (cycle 5)

Before proving `eps_invisible_gap_le` we searched the "anti-diagonal" family
`spreadCost n` (uniform weights on `Fin (n+1)`, cost `−1` on the diagonal and
`+1` off it, each instance its own fiber).  Every member has the same expected
cost, so the family is `1`-invisible with mean profile `m ≡ 0`, and the gap
between the best static member and the optimal dial is:

| `n` (members = fibers = `n+1`) | `bestConstant` | `dialValue` | gap `= 2n/(n+1)` |
| --- | --- | --- | --- |
| 1 | `0` | `−1` | `1` |
| 2 | `1/3` | `−1` | `4/3` |
| 3 | `1/2` | `−1` | `3/2` |
| 4 | `3/5` | `−1` | `8/5` |
| 9 | `8/10` | `−1` | `9/5` |
| 99 | `98/100` | `−1` | `99/50` |

The gap increases to `2` but never reaches it.  This ruled out the previous
cycle's conjectured constant `1` (already violated at `n = 2`) and pinned the
correct constant at `2`.

**[Lean]** All rows are instances of the proved identity `spread_gap`
(`bestConstant − dialValue = 2n/(n+1)`), and the limit statement is
`eps_invisible_two_sharp`; the matching upper bound is `eps_invisible_gap_le`.

## 7. What a null dial certifies, and where the gain comes from (cycles 6–7)

**Swap masses of the three-member witness.**  Instances `{x, y}` with uniform
weights, each its own fiber; members `0, 1` trade places and member `2` dominates.

| member | cost on `x` | cost on `y` | fiber value on `x` | fiber value on `y` | static cost |
| --- | --- | --- | --- | --- | --- |
| 0 | 1 | 3 | 1/2 | 3/2 | 2 |
| 1 | 3 | 1 | 3/2 | 1/2 | 2 |
| 2 | 0 | 0 | 0 | 0 | 0 |

Fiberwise minimum is `0` on both fibers, so `dialValue = 0 = bestConstant`: the
dial gain is exactly zero.  Yet the swap masses of the pair `(0,1)` are
`∑ (v₀ − v₁)⁺ = 1` and `∑ (v₁ − v₀)⁺ = 1`, so on the two-member sub-portfolio a
dial would gain `min(1,1) = 1`.

**[Lean]** `swap_hidden_by_third_member` (all six numbers above), together with
the exact identities `two_member_gap` (gain `= min` of the swap masses) and
`gap_eq_inf_fiberRegret` (gain `= min_s` fiberwise regret).  The equivalence
`gap = 0 ⟺ a fiberwise champion exists` is `gap_zero_iff_exists_fiberwise_optimal`.

**Threshold schedules.**  The `2 × 2` matrix `crossCost o s = [s = o]` (cost `1`
when the member index matches the quantile, `0` otherwise) has fiberwise optimal
members `1, 0` at quantiles `0, 1`: a *decreasing* schedule.  It also violates
decreasing differences, since
`crossCost 1 1 − crossCost 1 0 = 1 > −1 = crossCost 0 1 − crossCost 0 0`.
So single crossing is exactly what rules such matrices out.

**[Lean]** `leastArgmin_not_monotone_without_dd`; the positive direction is
`leastArgmin_monotone` / `exists_monotone_optimal_dial`.

## 8. Pairwise swaps versus the portfolio gain (cycle 8)

**Irredundant witness.**  Three instances (each its own fiber), uniform weights
`1/3`, three members; fiber values `v_s(o)` after weighting:

| member | fiber 0 | fiber 1 | fiber 2 | static cost |
| --- | --- | --- | --- | --- |
| 0 | 0 | 10/3 | 10/3 | 20/3 |
| 1 | 10/3 | 0 | 10/3 | 20/3 |
| 2 | e/3 | e/3 | 0 | 2e/3 |

No member is weakly beaten on every fiber (member `2` fails on fibers `0, 1`
because `e > 0`; members `0, 1` fail on their own fiber), so nothing is
eliminable.  The fiberwise minimum is `0` on all three fibers, so
`dialValue = 0` and the gain is `2e/3 → 0`, while the swap masses of the pair
`(0,1)` stay at `10/3`.

| `e` | dial gain `2e/3` | pairwise swap | ratio |
| --- | --- | --- | --- |
| `1` | `2/3` | `10/3` | `5` |
| `1/10` | `1/15` | `10/3` | `50` |
| `1/100` | `1/150` | `10/3` | `500` |
| `1/(M+1)` | `2/(3(M+1))` | `10/3` | `5(M+1)` |

**[Lean]** `irred_portfolio_irredundant`, `irred_gap`, `irred_swapMass` and the
unbounded-ratio statement `swap_unbounded_on_irredundant`.

**The reverse inequality.**  A random search over rational fiber-value matrices
(`2–4` members, `2–4` fibers, entries in `0..8`, 200 000 samples, *exploratory*)
found no violation of `gap ≤ (|S| − 1) · max pairwise swap`, with the ratio
reaching exactly `1` — attained already at `|S| = 2`, where the bound is the
proved identity `two_member_gap`.  That search motivated, and is now superseded
by, the proofs `gap_le_sum_pair_swaps` and `gap_le_card_mul_pair_swap`
**[Lean]**; the anti-diagonal family `spreadCost n` of cycle 5 attains the
factor `|S| − 1`.
