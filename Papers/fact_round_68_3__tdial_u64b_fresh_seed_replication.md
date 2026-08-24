# Computational Evidence — TDIAL-U64B (exp 543, paper 190)

All numbers below were computed with exact rational arithmetic (`ℚ`) inside the Lean
toolchain via `#eval`, from the recorded summary of the fresh bitlen-64 uniform cell:

| quantity | symbol | value |
|---|---|---|
| pooled ρ(T, rate), fresh triple (seeds 20261210–12) | `pooled64b` | `0.641` |
| fresh CI | `[ci64bLow, ci64bHigh]` | `[0.619, 0.660]` |
| fresh pooled advantage over popcount | `adv64b` | `+0.044` |
| fresh advantage CI | `[advLow, advHigh]` | `[0.022, 0.066]` |
| pre-registered bar | `bar` | `+0.050` |
| six-seed ρT mean | `rhoMean6` | `0.644` |
| six-seed advantage mean / median | `advMean6`, `advMedian6` | `+0.059` / `+0.058` |
| bar counts | — | `1/3` fresh, `3/6` combined |
| paper-184 bitlen-64 pooled reading | `Novelty.ZeroFitDialU64.pooled` | `0.648` |

## 1. Small-case arithmetic driving the rigidity theorems

| derived quantity | expression | exact value | decimal |
|---|---|---|---|
| six-seed ρT mean as replication average | `(0.641 + 0.648)/2` | `1289/2000` | `0.6445` (reported `0.644`, drift `1/2000`) |
| legacy (paper-184) triple advantage mean | `2·0.059 − 0.044` | `37/500` | `0.074` |
| above-bar group mean floor | `2·advMean6 − bar` | `17/250` | `0.068` |
| median rigidity floor | `2·advMedian6 − bar` | `33/500` | `0.066` |
| legacy maximum floor | `(3·0.074 − 0.05)/2` | `43/500` | `0.086` |
| squared dial reading | `0.641²` | `410881/1000000` | `0.410881` |

Two coincidences visible in the table are what the formal work exploits.

* `2·advMedian6 − bar = 0.066 = advHigh` **exactly**: the median forces every winning seed
  to the *upper* endpoint of the fresh cell's own confidence interval.
* `0.410881 < 1/2`: the replicated reading is below the `1/√2` parity threshold of
  `Algebra.ZeroFitDialU72Parity`, and `0.410881 < 6/7`, below the dyadic tie ceiling of
  `Novelty.ZeroFitDialU64`.  Neither of the two older ceilings is active here.

## 2. Capacity table (`k·ρ² ≤ 1 + (k−1)γ` at ρ = 0.641)

Largest admissible family size `k` as a function of the pairwise-correlation cap `γ`
(`true` = the constraint is satisfiable, so `k` statistics may coexist):

| γ | k = 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| `0.0` | true | true | **false** | false | false |
| `0.1` | true | true | **false** | false | false |
| `0.2` | true | true | true | **false** | false |
| `0.3` | true | true | true | true | true |

Pair-correlation floors forced by a family all reading `0.641`:

* `k = 3`: `γ ≥ (3ρ²−1)/2 = 232643/2000000 ≈ 0.11632`
* `k = 4`: `γ ≥ (4ρ²−1)/3 = 53627/250000 ≈ 0.21451`

## 3. Decorrelation budgets (`1 − c ≥ α²/(2(1−ab))`)

| advantage α | reading product `ab` | budget `1 − c ≥` |
|---|---|---|
| `0.044` (fresh pooled) | `0.641 · 0.597 = 0.382677` | `968/617323 ≈ 0.0015681` |
| `0.086` (forced outlier) | `≥ 1/3` | `5547/1000000 = 0.005547` |

## 4. Counterexample hunt / consistency check

The published summary is a *system of constraints* on six unobserved per-seed
advantages.  Two questions were tested.

**(a) Can the record be flat?**  A record with all six advantages inside the fresh CI
`[0.022, 0.066]`, mean `0.059` and only three seeds above `0.05` would need
`∑ ≤ 3·0.066 + 3·0.05 = 0.348 < 0.354`.  No such record exists — formalised as
`no_flat_count_parity_record`.  This is the counterexample hunt coming back *empty*: the
"count parity" verdict cannot be explained by a uniformly mediocre advantage.

**(b) Is the summary self-consistent?**  Yes.  The explicit witness

```
witness = (0.016, 0.100, 0.106 | 0.016, 0.050, 0.066)      legacy | fresh
```

evaluates to `∑ = 177/500 = 0.354 = 6·0.059`, `∑_fresh = 33/250 = 0.132 = 3·0.044`,
`#{i : advantage > 0.05} = 3`, `#{i ∈ fresh : advantage > 0.05} = 1`, sorted order
`(0.016, 0.016, 0.050, 0.066, 0.100, 0.106)` with median `(0.050+0.066)/2 = 0.058`.
It is verified in Lean as `six_seed_record_consistent`.

A second witness `(0.050, 0.086, 0.086 | 0.020, 0.030, 0.082)` attains the legacy-maximum
floor `0.086` exactly, showing the rigidity bound is sharp (`six_seed_rigidity_sharp`).

## 5. Aggregation, dispersion and the capacity staircase (cycles 5–7)

**Pooled advantage energy of the witness.**  `∑ witness_i² = 28604/1000000 = 0.028604`
(`advSeed_sq_sum`).  With reading products at least `1/3` the pooled headroom is at most
`6 − 2 = 4`, so the worst-case aggregated budget gives
`1 − cmin ≥ 0.028604/8 = 7151/2000000 ≈ 0.0035755`
(`six_seed_aggregate_decorrelation`).

**Summary-statistics-only route.**  Using nothing but `r = 6`, `ℓ = 3`, `μ = 0.059`,
`τ = 0.05`, `P = 1/3`:

| quantity | expression | exact value |
|---|---|---|
| dispersion floor (total squared deviation) | `r·ℓ/(r−ℓ)·(μ−τ)²` | `486/1000000` |
| per-seed energy floor | `μ² + ℓ/(r−ℓ)·(μ−τ)²` | `3562/1000000` |
| forced decorrelation | `(3/4)·3562/1000000` | `5343/2000000 ≈ 0.0026715` |

The gap `0.0035755 − 0.0026715` is exactly the information the individual seed values carry
beyond the published summary.

**Refutation of the mean-based aggregated budget.**  Search over small two-replication
configurations produced the violating record

```
a = (0.7, 1)   b = (-0.7, 1)   c = (0, 1)   alpha = (1.4, 0)   cbar = 0.5
```

Gram positivity holds in both replications (`0.98 ≤ 1` and `3 ≤ 3`), the advantages are
nonnegative and within the reading gaps, and the reading products are `-0.49` and `1`.
Pooled energy is `1.96`; the conjectured mean-based budget is
`2·(1−0.5)·(2−(−0.49)−1) = 1.49`.  Formalised as `aggregated_budget_needs_ordering`.
The two replications *monovary*: `(1−c) = (1, 0)` and `(1−ab) = (1.49, 0)`.

**Capacity staircase at `ρ = 0.641`.**  Closed form `K(ρ, γ) = ⌊(1−γ)/(ρ²−γ)⌋`:

| γ | `(1−γ)/(ρ²−γ)` | `K` |
|---|---|---|
| `0.1` | `900000/310881 ≈ 2.895` | `2` |
| `0.2` | `800000/210881 ≈ 3.794` | `3` |

verified as `u64b_capacity_floor_values`, with the risers
`dialThreshold 3 = 232643/2000000` and `dialThreshold 4 = 53627/250000` and the crossing
window `0.1 < 0.1163215 < 0.2 < 0.214508` (`u64b_capacity_jump_window`).  Both cells are
realisable *and* the next size up is impossible in every ambient dimension
(`u64b_capacity_exactly_two_at_gamma_tenth`,
`u64b_capacity_exactly_three_at_gamma_fifth`).

**Minimal dimension of the extremal triple.**  The explicit `k`-dimensional realiser uses
`A = √(1−γ)` and `B = (√(1+(k−1)γ) − A)/k`; at `k = 3`, `γ = 232643/2000000` this gives
`A ≈ 0.940042`, `B ≈ 0.056734`, unit vectors with pairwise inner product `γ` and reading
`0.641` against the uniform response `(1/√3, 1/√3, 1/√3)`.  Formalised as
`u64b_triple_realizable_in_three_dimensions`, together with the impossibility of any
ambient dimension below `3`.

**Mean-correlation floor (exact capacity law).**  From `(3ρ)² ≤ 3 + 2(γ₁₂+γ₁₃+γ₂₃)` with
`ρ = 0.641`: `9ρ² = 3.697929`, so `γ₁₂+γ₁₃+γ₂₃ ≥ 0.3489645 = 697929/2000000`, i.e. mean
pairwise correlation `≥ 0.1163215` — numerically identical to the triple threshold, but a
constraint on the *average* pair rather than the worst pair
(`u64b_triple_mean_correlation_floor`).

## 6. No OEIS entry

The objects here are real-valued correlation records, not integer sequences, so no OEIS
search applies.  The integer content of the cycle — the dyadic block profile
`(2^{b−1}, 2^{b−2}, …, 1, 1)` of trailing-zero counts — is already catalogued in
`Novelty.ZeroFitDialU64` and is unchanged by this replication.

## Status of these numbers

Everything in sections 1–5 that is used in a claim has a corresponding `sorry`-free Lean
theorem in one of

* `Catalog/Algebra/ZeroFitDialU64Replication.lean`
* `Catalog/Algebra/ZeroFitDialU64MedianCapacity.lean`
* `Catalog/Algebra/ZeroFitDialU64Aggregation.lean`
* `Catalog/Algebra/ZeroFitDialU64CapacityJump.lean`
* `Catalog/Algebra/ZeroFitDialU64Dispersion.lean`
* `Catalog/Algebra/ZeroFitDialU64ExtremalDimension.lean`
* `Catalog/Algebra/ZeroFitDialU64ExactCapacity.lean`

The tables themselves are exploratory `#eval` output and are reported as such.
