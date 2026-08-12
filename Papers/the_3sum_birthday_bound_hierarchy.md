# Computational evidence — 3SUM mod `p` and the birthday-bound hierarchy

All numbers below were produced by direct enumeration and were subsequently
re-derived inside Lean (either by kernel evaluation with `decide`, or as
corollaries of the general theorems, as indicated).

## 1. `N = 143 = 11 · 13` census

Triples `1 ≤ a < b < c ≤ 12`:

| quantity | value | status in Lean |
|---|---|---|
| triples with `11 ∣ a+b+c` | **20** | `ThreeSumFactoring.card_triples143` (`decide`) |
| of those, also `13 ∣ a+b+c` | **0** | `ThreeSumFactoring.card_triples143_modBoth` (`decide`) |
| distinct values of `gcd(a+b+c, 143)` over the census | `{11}` | `ThreeSumFactoring.triples143_reveal` (general theorem) |

*Note on the count.* The mission statement quotes `19` mod-`p`-only triples; with
the convention "strictly increasing triples drawn from `{1,…,12}`" the exact
count is `20`. The count is convention-dependent (range of entries, ordered vs.
unordered, repetitions allowed), whereas the qualitative claim — *every*
mod-`11`-only triple reveals the factor `11`, and the mod-both census is empty —
is convention-independent and is what the Lean theorems prove.

The emptiness of the "mod-both" column is not luck: any positive sum below
`N = 143` divisible by both `11` and `13` would be a positive multiple of `143`
below `143`. This is `ThreeSumFactoring.not_dvd_both_of_lt`, and it upgrades the
observation into the guarantee `ThreeSumFactoring.reveal_of_pos_lt`.

## 2. Exact density of the zero-sum set

Number of triples `(a,b,c) ∈ (ℤ/p)³` with `a + b + c ≡ 0`:

| `p` | count | `p²` |
|---|---|---|
| 5 | 25 | 25 |
| 7 | 49 | 49 |
| 11 | 121 | 121 |

Density is exactly `1/p`, and the same holds at every arity — proved in general
as `ThreeSumSearchSpace.card_zeroSum_tuples` (`p^r` solutions among `p^(r+1)`
tuples).

## 3. Sharpness of the collision threshold (`p = 11`)

Base-`k` family systems `A j i = i·k^j mod p`, sums over all `k^r` selections:

| `k` | `r` | `k^r` | distinct sums | collision? |
|---|---|---|---|---|
| 3 | 2 | 9  | 9  | none (`k^r ≤ p`) |
| 2 | 3 | 8  | 8  | none (`k^r ≤ p`) |
| 4 | 2 | 16 | 11 | forced (`k^r > p`) |
| 3 | 3 | 27 | 11 | forced (`k^r > p`) |

Random sampling: 2000 random systems with `k = 4, r = 2` mod `11`; **0** were
collision-free, consistent with the pigeonhole direction. The two directions are
proved as `BirthdayBoundHierarchy.collisionGuaranteed_of_lt` and
`BirthdayBoundHierarchy.exists_collisionFree`, and combined into the exact
threshold `BirthdayBoundHierarchy.collisionGuaranteed_iff` (`p < k^r`).

## 4. Reveal capacity check

`π(100) = 25` (verified in Lean by `decide` inside
`GcdRevealBarrier.small_case_missed_prime`), while a list of two values bounded
by `1024` can reveal at most `2 · log₂ 1024 = 20 < 25` primes — so some prime
below `100` necessarily escapes. This is the small-scale instance of the general
counting bound `GcdRevealBarrier.universal_work_lower_bound`.
