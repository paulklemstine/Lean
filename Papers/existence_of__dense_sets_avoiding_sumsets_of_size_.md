# Computational Evidence

All tables below were produced with exact integer arithmetic (`#eval` on `Nat` in this
project's Lean toolchain for §1, exact Python integers for §2–§3). The two rows marked
**(formalised)** are additionally backed by `sorry`-free theorems in
`Catalog/Bridges/DenseSumsetLower/Evidence.lean`; everything else in this file is
exploratory numerical data, **not** formally verified.

## 1. The greedy counting threshold

The criterion proved in `Catalog/Bridges/DenseSumsetLower/Core.lean`
(`DenseSumsetLower.exists_sumset_nat_range`) says:

> if `S ⊆ [0,n)` and `k · (2n)^k ≤ |S| · (|S| − k)^k`, then `S ⊇ A + B` for some
> `|A| = |B| = k`.

Let `K(n, s) = max { k : k · (2n)^k ≤ s · (s − k)^k }`, the sumset size guaranteed by the
criterion for a set of size `s` inside `[0,n)`:

| n | K(n, n/2) | K(n, n/4) | K(n, n/8) |
|---|---|---|---|
| 2^8  = 256      | 2 | 1 | 1 |
| 2^10 = 1024     | 3 | 2 | 1 |
| 2^12 = 4096     | 4 | 2 | 1 |
| 2^14 = 16384    | 5 | 3 | 2 |
| 2^16 = 65536    | 6 | 3 | 2 |
| 2^18 = 262144   | 7 | 4 | 3 |
| 2^20 = 1048576  | 7 **(formalised)** | 5 | 3 |
| 2^22 = 4194304  | 8 | 5 | 4 **(formalised)** |

Reading the columns: `K` grows linearly in `log n` with slope, in bits,
`1/log₂(2/δ) = 1/2, 1/3, 1/4` for `δ = 1/2, 1/4, 1/8` respectively — exactly the constant
`1/log(2/δ)` appearing in `DenseSumsetLower.eventually_exists_sumset_of_density`. For
`δ = 1/2` the entries increase by 1 for every ≈ 2 extra bits of `n`, for `δ = 1/8` by 1 for
every ≈ 4 bits. The `k`-factor and the `(|S| − k)` correction cost an additive
`O(log log n)`, which is invisible asymptotically.

**Formalised instances** (`Evidence.lean`, discharged by explicit arithmetic, no `sorry`):

* `sumset_seven_of_half_dense`: every `S ⊆ [0, 2^20)` with `|S| ≥ 2^19` contains `A + B`
  with `|A| = |B| = 7`;
* `sumset_four_of_eighth_dense`: every `S ⊆ [0, 2^22)` with `|S| ≥ 2^19` contains `A + B`
  with `|A| = |B| = 4`.

## 2. Interval loss versus group sharpness

In a finite abelian group the shift window is all of `G`, so the criterion reads
`k · |G|^k ≤ |S|(|S| − k)^k`, giving slope `1/log(1/δ)` instead of `1/log(2/δ)`. With
`|S| = |G|/2` resp. `|S| = n/2`:

| N = 2^m | group threshold `K_G(N, N/2)` | interval threshold `K(N, N/2)` |
|---|---|---|
| 2^8  | 4  | 2 |
| 2^12 | 7  | 4 |
| 2^16 | 11 | 6 |
| 2^20 | 15 | 7 |
| 2^22 | 16 | 8 |

The ratio is ≈ 2 = `log(2/δ)/log(1/δ)` at `δ = 1/2`, quantifying exactly the factor lost by
the `(−n, n)` shift window and matching the analysis behind
`DenseSumsetLower.exists_threshold_group` (constant `1/log(1/δ)`) versus
`DenseSumsetLower.eventually_exists_sumset_of_density` (constant `1/log(2/δ)`).

## 3. How conservative is the criterion? (counterexample hunt)

For random `S ⊆ [0,n)` of size `δn` we computed, by exhaustive depth-first search over shift
sets (search depth capped at 6, so the reported values are exact maxima whenever they are `< 6`),
the true largest `k` with `A + B ⊆ S`, `|A| = |B| = k`:

| n, δ | criterion `K` | true maximum (3 random samples) |
|---|---|---|
| n = 32, δ = 1/2 | 1 | 4, 3, 4 |
| n = 32, δ = 1/4 | 0 | 2, 2, 2 |
| n = 64, δ = 1/2 | 1 | 5, 5, 5 |
| n = 64, δ = 1/4 | 1 | 3, 3, 3 |

No counterexample to the criterion appeared (it is a theorem); what the data shows is that the
criterion is *conservative by an additive amount* at these sizes — the `k · |D|^k` union-bound
factor is wasteful for small `n`, while the observed slopes (4→5 as `n` doubles at `δ = 1/2`;
2→3 at `δ = 1/4`) are again consistent with a `Θ(log n)` growth with the predicted
`δ`-dependence. Nothing in the sample contradicts the conjecture that the true constant is
`1/log(1/δ)` rather than `1/log(2/δ)` even for intervals.

## 4. Upper-bound side

The first-moment construction in `Catalog/Bridges/DeltaDenseSumsetAvoidance.lean` needs
`n^3 · ⌈δn⌉^L < n^L` with `L = 2k − 1`. Solving for `k` gives
`k > (3/2)·log n/log(1/δ)·(1 + o(1))`, i.e. constant `3/2` rather than the previously recorded
`3`; the `o(1)` is exactly the buffer `θ` of `SumsetWindow.pow_cond_sharp`, admissible as soon as
`1/(δ n) ≤ θ log(1/δ)`. For `δ = 1/2` and `n = 2^20`, `1/(δn) ≈ 1.9·10⁻⁶` while
`log(1/δ) ≈ 0.693`, so `θ = 10⁻⁵` is already legitimate and the effective constant is
`3/2 + O(10⁻⁵)` at that size.

## 5. Closing the window: from `3/2` to `1`

The `3/2` of §4 comes from paying `n³` parameters `(t, d₁, d₂)` for a witness of only
`2k − 1` points. Writing `d₁ = g e₁`, `d₂ = g e₂` with `gcd(e₁, e₂) = 1` and
`Q = max(e₁, e₂)`, the sumset `apF a d₁ k + apF b d₂ k` in fact contains the block
`{t + i d₁ + j d₂ : i < k, j < min(Q, k)}`, of size `k · min(Q, k)` (this is
`DenseSumsetLower.card_blockWitness`, formally proved), while the number of parameter
tuples with a given `Q` stays `O(n²)`:

| `Q` | parameters with this `Q` | forced points | ratio (params : points) |
|---|---|---|---|
| 1 (`d₁ = d₂`) | `O(n²)` | `2k − 1` | `2 : 2k` |
| 2 | `O(n²)` | `2k` | `2 : 2k` |
| `Q ≥ 3`, `Q < k` | `O(n²)` per `Q` | `Q·k` | `2 : Qk` |
| `Q ≥ k` | `O(n²)` per `Q` | `k²` | `2 : k²` |

Every row has parameter-to-point ratio at most `2 : 2k = 1 : k`, so the union bound closes at
`k ≥ (1 + o(1))·log n/log(1/δ)` — the tail over `Q` being summable by the geometric estimate
`DenseSumsetLower.geom_tail_le`. This is the numerical content of the formal theorem
`DenseSumsetLower.eventually_avoiding_ap_sumsets_one`, and it matches the lower bound
`DenseSumsetLower.eventually_exists_sumset_sharp` (constant `1/log(1/δ)`, no interval loss),
so the two-sided window recorded in §2–§4 collapses to a point. The table above is a reading
of the formal proof, not an independent numerical experiment.

## 6. Multi-fold sums: how far does the cube go?

The iterated form of the greedy step (`DenseSumsetLower.exists_cube_family`) squares the
surviving density at every step, `|U_{j+1}| ≥ |U_j|²/(2|D|)`, so with `|D| ≈ 2n` and
`|S| = δn` the criterion for a `d`-dimensional affine cube is `(4/δ)^{2^d} ≤ 2n`:

| δ | n | largest `d` with `(4/δ)^{2^d} ≤ 2n` | smallest `n` admitting that `d` |
|---|---|---|---|
| 1/2 | 2^12 | 2 | 2^11 |
| 1/2 | 2^13 | 2 | 2^11 |
| 1/2 | 2^24 | 3 | 2^23 |
| 1/2 | 2^49 | 4 | 2^47 |
| 1/4 | 2^17 | 2 | 2^15 |
| 1/8 | 2^21 | 2 | 2^19 |

(Exact integer arithmetic; at `δ = 1/2` the criterion reads `3·2^d ≤ log₂(2n)`, so each extra
dimension roughly squares the required `n`.)

The doubly-exponential growth in `d` is intrinsic, not an artefact: the cube has `2^d`
points, so its first moment `δ^{2^d}` can only survive while `2^d ≲ log n/log(1/δ)` — the
*same* budget `log n/log(1/δ)` that the two-fold argument spends on `k` points.

**Formalised instance** (`Cube.lean`, explicit arithmetic, no `sorry`):
`cube_two_of_half_dense` — every `S ⊆ [0, 2^12)` with `|S| ≥ 2^11` contains `u, u + a,
u + b, u + a + b` with `a, b ≠ 0`; the numeric check is `2·(4·4096)³ = 2^43 ≤ 2048⁴ = 2^44`.

## 7. Proper cubes: the two sides of the dimension threshold

Two changes of this cycle are recorded here.  First, the existence criterion of §6 was
upgraded to *proper* cubes (all `2^d` subset sums distinct) at the cost of a factor `4^d`,
giving `(4/δ)^{2^d}·4^d ≤ 2n`; at `δ = 1/2` this reads `3·2^d + 2d ≤ log₂(2n)` instead of
`3·2^d ≤ log₂(2n)`.  Second, the opposite (first-moment) side was proved: a `δ`-dense
`S ⊆ [n]` avoiding all proper cubes of dimension `d` exists once
`(1+ε)(d+1)·log n ≤ 2^d·log(1/δ)`, i.e. at `δ = 1/2` once `(d+1)·log₂ n ≤ 2^d`.

| `δ = 1/2` | smallest `log₂ n` forcing a cube of dim `d` (plain, §6) | … forcing a *proper* cube of dim `d` |
|---|---|---|
| `d = 1` | 5 | 7 |
| `d = 2` | 11 | 15 |
| `d = 3` | 23 | 29 |
| `d = 4` | 47 | 55 |
| `d = 5` | 95 | 105 |

| `δ = 1/2` | largest `d` forced to occur | smallest `d` that can be avoided |
|---|---|---|
| `n = 2^20` | 2 | 8 |
| `n = 2^40` | 3 | 9 |
| `n = 2^80` | 4 | 10 |

Both thresholds are `log₂(log n / log(1/δ)) + O(log d)`; the residual gap is the additive
`log₂(d+1)` coming from the `d + 1` parameters (base point and generators) of the union
bound, which is the content of sub-conjecture 3 of `FUTURE_DIRECTIONS.md`.

The two tables are ordinary arithmetic evaluations of the two criteria, not machine-checked
statements.  The machine-checked instance of this cycle is
`DenseSumsetLower.proper_cube_two_of_half_dense` (`CubeProper.lean`): every
`S ⊆ [0, 32768)` with `|S| ≥ 16384` contains a two-dimensional cube with four *distinct*
points; the arithmetic check `2·4²·(4·32768)³ = 2^56 ≤ 16384⁴ = 2^56` is discharged inside
the Lean proof, and the entry `log₂ n = 15` of the first table is exactly that computation.
