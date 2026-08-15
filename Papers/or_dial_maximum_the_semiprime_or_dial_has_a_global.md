# Computational Evidence — OR-DIAL-MAXIMUM

All numbers below come from an exploratory enumeration script (floating-point, run outside
Lean). **They are not machine-verified**; they were used only to shape and sanity-check the
conjectures. The mathematical content that *is* verified lives in the Lean files
`Catalog/Bridges/ORDialCap.lean`, `ORDialMaximum.lean`, `ORDialRealizations.lean` and
`ORDialClassification.lean`, whose theorems hold for **every** finite abelian class group
and **every** profile, so they subsume all the finite checks below.

## Model

For a class-rate profile `r : (ℤ/m)ˣ → [0,1]` put `s = 1 − r` and

```
f(c) = (1/φ(m)) Σ_a s(a) s(c a⁻¹),      μ = (1/φ(m)) Σ_a s(a),
Φ(r) = H(μ²) − (1/φ(m)) Σ_c H(f(c))        (bits).
```

The target constant is `g(2) = H(3/4) − ½H(1/2) = 0.31127812445913283` bits
(`orCap / log 2` in the Lean development; `orCap = (3/2)log 2 − (3/4)log 3` nats, and
`ORDial.orCap_bits_bounds` proves `0.3111 < orCap/log 2 < 0.3114`).

## 1. Exhaustive enumeration of all 0/1 profiles

Every one of the `2^φ(m)` deterministic profiles was enumerated for
`m = 3, 4, 5, 7, 8, 9, 11, 16, 21` (unit groups `C₂, C₂, C₄, C₆, C₂×C₂, C₆, C₁₀, C₂×C₄,
C₂×C₆`).

| m | φ(m) | unit group | max Φ (bits) |
|---|------|-----------|--------------|
| 3 | 2 | C₂ | 0.311278124 |
| 4 | 2 | C₂ | 0.311278124 |
| 5 | 4 | C₄ | 0.311278124 |
| 7 | 6 | C₆ | 0.311278124 |
| 8 | 4 | C₂×C₂ | 0.311278124 |
| 9 | 6 | C₆ | 0.311278124 |
| 11 | 10 | C₁₀ | 0.311278124 |
| 16 | 8 | C₂×C₄ | 0.311278124 |
| 21 | 12 | C₂×C₆ | 0.311278124 |

No profile exceeded `g(2)`; the maximum is attained on every modulus tested.

## 2. Counterexample hunt for the *classification*

Counting how many 0/1 profiles attain the cap exactly:

| m | #maximisers | #index-2 subgroups × 2 cosets |
|---|-------------|-------------------------------|
| 3, 4, 5, 7, 9, 11 | 2 | 1 × 2 |
| 8, 16, 21 | 6 | 3 × 2 |

This is exactly the count predicted by `ORDial.binary_max_iff_coset`: the maximisers are
precisely the cosets of index-two subgroups (a quadratic-character kernel and its
complement, one such pair per quadratic character). No extra maximiser was found — in
agreement with the theorem, which now proves that none can exist, on any finite abelian
group.

## 3. Non-deterministic profiles

Coordinate ascent over `[0,1]^{φ(m)}` (m = 7, 11, 16; random restarts) never exceeded the
cap, and every limit point found was 0/1-valued. This is now a theorem:
`ORDial.binary_of_max` shows a maximiser is automatically 0/1-valued, and
`ORDial.max_iff_coset_indicator` identifies all of them.

## 4. Subgroup law spot checks

For the kernel profile of a subgroup of index `n`, `Φ = H(1/n²) − (1/n)H(1/n)`
(`ORDial.orInfo_subgroupProfile`):

| n | Φ (bits) |
|---|----------|
| 2 | 0.311278 |
| 3 | 0.197160 |
| 4 | 0.134471 |
| 5 | 0.097907 |

This is the AND-companion family of the mission statement; it is strictly decreasing in
`n` on the range tested, and `ORDial.andLaw_le_orCap` proves that the whole family (all
`n ≥ 2`) is dominated by the `n = 2` entry `g(2)`.

## 5. Multi-prime dial (exploratory data for the new cycle)

Same model with `k` independent prime classes: `f_k = s^{⋆k}/…` (the `k`-fold class-group
convolution), `Φ_k = H(μ^k) − avg_c H(f_k(c))`.  Exhaustive enumeration of **all** `2^{φ(m)}`
0/1 profiles (floating point, exploratory — not machine-verified):

| m (unit group) | k = 2 | k = 3 | k = 4 | argmax |
|---|---|---|---|---|
| 5 (C₄) | 0.311278 | 0.137925 | 0.065508 | coset of the index-2 subgroup |
| 7 (C₆) | 0.311278 | 0.137925 | 0.065508 | coset of the index-2 subgroup |
| 8 (C₂×C₂) | 0.311278 | 0.137925 | 0.065508 | coset of an index-2 subgroup |
| 9 (C₆) | 0.311278 | 0.137925 | 0.065508 | coset of the index-2 subgroup |

The index-two kernel values `H(2^{-k}) − ½H(2^{-(k-1)})` (bits) are

| k | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|
| Φ_k | 0.311278 | 0.137925 | 0.065508 | 0.031977 | 0.015804 |

and this closed form is a theorem (`ORDial.multiInfo_subgroupProfile`, specialised by
`ORDial.multiInfo_index_two`).  What is now *proved* for all `k ≥ 2`, every profile and
every finite abelian class group is the cap `Φ_k ≤ g(2) = 0.311278…`
(`ORDial.multiInfo_le_orCap`), together with `Φ_k < g(2)` for the index-two kernels as soon
as `k ≥ 3` (`ORDial.multiInfo_index_two_lt_orCap`).  The table above suggests the sharper
statement recorded as Conjecture 1 of `FUTURE_DIRECTIONS.md`: for `k ≥ 3` the maximum over
all profiles is again attained exactly at the index-two cosets, with value
`H(2^{-k}) − ½H(2^{-(k-1)})`.  The proved intermediate bound
`Φ_k ≤ H(μ^k) − μ H(μ^{k-1})` peaks at `0.246` bits (at `μ ≈ 0.8`, `k = 3`), so it does not
yet decide that conjecture.
