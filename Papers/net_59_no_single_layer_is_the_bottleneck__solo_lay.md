# Computational evidence — NET-59 solo-ablation profiles

All numbers below are exact rationals produced by evaluating the Lean
definitions in `Catalog/Probability/NET59*.lean` (no floating point, no
sampling).  They were computed with `#eval` inside the project; the depth-11
instances are additionally re-proved as theorems in the `LabNotes` section of
`Catalog/Probability/NET59NonIdentifiability.lean`, and the depth-24 instances
are proved in `net59_nonidentifiability`.

## 1. The object being tested

A layer is a Markov channel on a finite state space; a stack is a list of
channels; damage is total variation distance between the output law of the
intact stack and the output law of the ablated stack.  Three quantities:

* **solo cost** of layer `j` — prune only layer `j` (this is the NET-59
  measurement);
* **joint cost** — prune every layer;
* **point cost** of layer `j` — the damage layer `j` does to *its own* output
  law, at the intact upstream state.

## 2. The witness family (`fullStack n` / `prunedStack n t`)

`n` transparent layers followed by one totally forgetful layer; pruning turns
each transparent layer into a constant `Bernoulli(t)` layer and turns the
forgetful layer into a transparent one.

Depth 11 (`n = 10`), pruning strength `t = 17/1000` (the NET-50/NET-59 measured
joint cost of 1.7%):

| quantity | value |
|---|---|
| solo profile, all 11 layers | `[0,0,0,0,0,0,0,0,0,0,0]` |
| joint cost | `17/1000` |
| point profile, the 10 prunable layers | `[17/1000, …, 17/1000]` |
| joint cost of the same family at `t = 1` | `1` |

So: the solo profile is *perfectly* flat (flatter than the measured `0.6`-point
spread), while the joint cost of the identically-flat-profile family ranges over
the whole interval `[0,1]` as `t` varies.  The point profile — the honest
per-layer damage — is flat at `t`, not at `0`; the entire discrepancy is
downstream masking.

Depth 24 is not evaluated: the naive evaluator for a chain of `m` binary
channels is exponential in `m` (each `push` re-evaluates its predecessor at both
states, so depth 24 costs ≈ 2²⁴ rational operations).  The depth-24 statements
are therefore proved symbolically (`net59_nonidentifiability`), which is
stronger than evaluation anyway.

## 3. Counterexample hunt: is the joint cost ever bounded by the solo profile?

Two searches, both successful, i.e. both directions of the natural inference
fail:

* *joint ≫ Σ solo*: the witness family at `t = 1` has all 24 solo costs `0` and
  joint cost `1` (`no_subadditivity_law`).
* *joint ≪ max solo*: the two-layer stack `[id, id]` pruned to `[flip, flip]`
  has solo costs

  ```
  tv(chain [id,id] δ₀, chain [flip,id] δ₀) = 1
  tv(chain [id,id] δ₀, chain [id,flip] δ₀) = 1
  ```

  and joint cost

  ```
  tv(chain [id,id] δ₀, chain [flip,flip] δ₀) = 0
  ```

  (`cancellation_joint_zero`).  Two maximal solo damages cancel exactly.

No counterexample was found to the *contraction* bounds (`tv_push_le`,
`tv_push_le_dobrushin`, `solo_le_point`), which are proved.

## 4. Masking arithmetic behind `contraction_masks_maximal_damage`

With Dobrushin coefficient `δ = 1/2` per downstream layer and a layer sitting
`11` layers before the output of a 24-layer stack:

```
(1/2)^11 = 1/2048 ≈ 0.000488  <  0.0006 = (0.6 points)/10
```

so a layer whose point cost is the maximum possible `1` registers a solo cost
more than ten times smaller than the entire spread NET-59 was able to resolve.
This is an exact rational inequality, discharged by `norm_num` inside the
theorem.

## 5. What the evidence does not show

The model is a Markov chain on a finite state space with total-variation damage;
it is a faithful model of "layer = stochastic map, damage = distance between
output laws", not of transformer perplexity.  The evidence therefore supports a
statement about what solo-ablation data can *imply*, not a claim about the
particular network measured in NET-59.

## 6. Round 13 — the pair-ablation experiment (exact evaluations)

Same witness family, depth `6` (`n = 5`), evaluated exactly in `ℚ` with `#eval`
on the Lean definitions (`Catalog/Probability/NET59PairIdentifiability.lean`);
the depth-`24` statements are proved symbolically in `net59_pair_identifiability`.

| experiment | `t = 17/1000` | `t = 1` |
|---|---|---|
| solo profile, all 6 layers | `[0,0,0,0,0,0]` | `[0,0,0,0,0,0]` |
| pair profile `{j, tail}`, the 5 transparent layers | `[17/1000, …]` | `[1,1,1,1,1]` |

Arity `1` returns the same table (all zeros) for the two prunings; arity `2`
separates them by `983/1000` at every layer.  This is the computational content
of `net59_minimal_informative_arity`.

## 7. Round 14 — the geometric damping series

`∑_{i<n} 2^{-i}` evaluated exactly for `n = 0 … 24`:

```
0, 1, 3/2, 7/4, 15/8, 31/16, …, 16777215/8388608
```

The value at the measured depth `24` is `16777215/8388608 < 2`, against the
additive prediction `24`.  So with intact-layer contraction `1/2` and a uniform
per-layer budget `c`, joint pruning damage is at most `2c` rather than `24c`
(`geometric_subadditivity_uniform`, `geometric_beats_additive`): a forced
sub-additivity factor of at least `12`, comfortably covering the measured factor
`4.8% / 1.7% ≈ 2.8`, which in this model corresponds to intact layers with
contraction coefficient about `0.64`.

## 8. Round 15 — the arity hierarchy (two masking layers)

`twoMaskStack n`: `n` transparent layers followed by **two** totally forgetful
layers.  Exact `#eval` at depth `6` (`n = 4`), pruning strength `t = 17/1000`:

| experiment | value |
|---|---|
| arity-1 profile, all 6 layers | `[0,0,0,0,0,0]` |
| arity-2 profile, all 15 pairs | `[0,…,0]` (15 zeros) |
| arity-3 cost `{j, 4, 5}`, the 4 transparent layers | `[17/1000, …]` |

With one masking layer, arity `2` separated the two prunings by `983/1000`
(section 6); with two masking layers arity `2` separates them by `0` and only
arity `3` resolves anything.  The depth-`24` statements are proved symbolically
in `net59_arity_three_needed`.

## 9. Round 16 — the general arity hierarchy

`stackFrom (baseLayer n) 0 (n+m)`: `n` transparent layers followed by `m`
forgetful layers; ablation on an arbitrary index set `S`.  Exact `#eval` with
`n = 3`, `m = 2` (depth `5`), `t = 17/1000`:

| experiment | value |
|---|---|
| all 16 ablation sets of size `≤ 2` | `[0, …, 0]` |
| arity-3 sets `{j} ∪ {3,4}`, `j < 3` | `[17/1000, 17/1000, 17/1000]` |

This is the computational instance of `masker_arity_blind` and
`masker_arity_recovers`, which are proved for every `n`, `m` and every ablation
set; `net59_arity_hierarchy` states both at the measured depth `24` for any
split `n + m = 24`.  Consequently no ablation protocol of fixed arity is sound
for all stacks.

## 10. Round 17 — the geometric bound is attained, and the estimator

The affine layer `x ↦ Bernoulli(s + δ·x)` has Dobrushin coefficient exactly `δ`
and acts on the Bernoulli parameter by `q ↦ s + δ q`.  Running `n` copies from
`Bernoulli(0)` with `s = 0` (intact) and `s = c` (pruned) leaves parameters `0`
and `c · Σ_{i<n} δ^i`, so the joint damage equals the bound of
`chain_tv_le_geometric` **with equality** at every depth and every admissible
`(δ, c)` — proved as `geometric_bound_attained`, whence
`geometric_constant_sharp`.

Exact rational evaluation at the measured depth `24`, `δ = 8/9`:

```
Σ_{i<24} (8/9)^i = 75044076594002864649665 / 8862938119652501095929
                 ≈ 8.46718
```

With uniform per-layer budget `c = 1/500` (a `0.2%` solo cost):

| quantity | exact value | decimal |
|---|---|---|
| additive prediction `24c` | `24/500` | `4.8%` |
| joint damage `c·Σ` | `15008815318800572929933 / 886293811965250109592900` | `1.6935%` |
| sub-additivity factor `24/Σ` | — | `2.8345` |

The measured NET-50/NET-59 pair is `4.8%` versus `1.7%`, factor `≈ 2.82`.  The
stack realising it here has `24` *identical* layers, so the measurement is
consistent with a complete absence of per-layer structure.  Note this corrects
section 7's reading of the factor (`δ ≈ 0.64`), which omitted the depth factor;
the correct relation is `additive/joint = n(1-δ)/(1-δ^n)`, giving `δ ≈ 0.89` at
`n = 24`.  Proved as `net59_contraction_estimator`
(`169/10000 < joint < 170/10000`).

## 11. Round 18 — fractional masking and the resolution threshold

Probe stack: the layer under study (point damage `c`), then `m - k` intact
masking layers of contraction `δ`, then `k` ablated (identity) ones.  The
measured cost is exactly `δ^(m-k) · c` (`probe_cost`), so the round-4 masking
bound `solo ≤ δ^m · point` is attained (`masking_bound_attained`).

Exact `#eval` at `δ = 1/2`, `m = 11`, point damage `c = 1/2`, resolution
`6/1000` (the reported `0.6`-point spread):

```
k :   0       1       2       3       4       5      …  11
cost: 1/4096  1/2048  1/1024  1/512   1/256   1/128  …  1/2
    ≈ .000244 .000488 .000977 .001953 .003906 .007813   .5
```

The first five experiments (arity `1`–`5`) are below the resolution and the
sixth is above it: the minimal informative arity is `6`, fixed entirely by the
contraction spectrum.  Proved as `net59_resolution_threshold`.
