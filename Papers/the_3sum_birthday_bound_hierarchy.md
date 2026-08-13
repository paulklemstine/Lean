# Computational Evidence

All numbers below were produced with Lean `#eval` and the load-bearing ones are
re-proved by kernel-checked `decide` inside `Catalog/Logic/*.lean`, so they are
verified, not merely computed.

## 1. 3SUM mod-p factor reveal, `N = 143 = 11 · 13`

Enumeration of all triples `1 ≤ a < b < c ≤ 11` (165 triples):

| quantity | value |
| total triples | 165 |
| triples with `11 ∣ a+b+c` (mod-`p`-only) | **15** |
| triples with `143 ∣ a+b+c` (mod-both) | **0** |
| triples with `gcd(a+b+c, 143) = 11` | **15** |

Formal counterparts (kernel-checked by `decide`):
`ThreeSumBirthday.count_modP_143`, `count_modBoth_143`, `all_modP_triples_reveal`
in `Catalog/Logic/ThreeSumBirthdayHierarchy.lean`.

*Note on the source claim.* The mission statement quotes "19 mod-p-only triples
vs 0 mod-both for `N = 143`".  We could not reproduce 19 under any of the
natural enumeration conventions we tried (`a<b<c` or `a≤b≤c`, ranges starting at
0 or 1, ranges of length 8–15); e.g. `1 ≤ a<b<c ≤ 11` gives 15, `1 ≤ a<b<c ≤ 12`
gives 20, `0 ≤ a<b<c ≤ 11` gives 15.  The *qualitative* claim (many mod-`p`-only
triples, zero mod-both, every mod-`p`-only triple reveals `11`) is confirmed and
formalised; we report our own verified count of 15 rather than the unreproduced 19.

Other semiprimes (same convention, range `1..n`):

| `N` | `n` | total | `p ∣ s` | `N ∣ s` | reveal `p` |
| `143 = 11·13` | 11 | 165 | 15 | 0 | 15 |
| `391 = 17·23` | 20 | 1140 | 67 | 0 | 67 |
| `143 = 11·13` | 30 | 4060 | 369 | 0 | 369 |
| `15 = 3·5` | 10 | 120 | 42 | 10 | 32 |

The last row is the informative one: as soon as the range exceeds `N`, the
mod-both triples appear (10 of them) and exactly those fail to reveal —
matching the density theorem `count_revealing_witnesses`
(`q - 1` of every `q` mod-`p` witnesses per period reveal; here `42 - 10 = 32`).

## 2. Reveal density

For `N = p·q` and `0 < s ≤ N`: exactly `q` values satisfy `p ∣ s` and exactly
one of them (`s = N`) fails.  For `N = 143`: 13 witnesses, 12 reveals — proved
as `reveal_density_143`.

## 3. Threshold table (minimal search-set size `k` with `p < C(k,r)`)

| `p` | arity `r = 1` | `r = 2` | `r = 3` |
| 100 | 101 | 15 | 10 |
| 1000 | 1001 | 46 | 20 |

The search set shrinks like `p^{1/r}`, but the number of enumerated tuples
`C(k,r)` stays above `p` in every row (`101`, `105`, `120` for `p = 100`).
Formalised as `threshold_arity_one/two/three` and `cost_invariance_table`.

## 4. Counterexample hunt

* *Is `gcd(a+b+c, N) = p` automatic once `p ∣ a+b+c`?*  No: the row `N = 15`,
  `n = 10` above exhibits 10 explicit failures (`s` divisible by 15), so the
  hypothesis `q ∤ s` is necessary.  This is why the classification theorem
  `gcd_semiprime_classification` covers all four cases.
* *Is the deterministic `> p` cost bound also a randomised bound?*  No — this is
  the one place where the source table overstates.  Counting shows the collision
  probability with `m` tuples is `≤ C(m,2)/p`, so at `p = 10007`, `m = 100`
  already leaves a majority of evaluations collision-free while `m ≈ √p`
  suffices for constant success probability.  Formalised as
  `randomized_barrier` / `barrier_gap_10007`.

## 5. OEIS

The counts of mod-`p` triples in an initial range are the "number of triples
`a<b<c ≤ n` with `p ∣ a+b+c`" quasi-polynomials (`15, 20, 26, 33, 41, 51, …` for
`p = 11`, `n = 11, 12, …`); we found no distinctive OEIS entry for this
`p`-parametrised family and make no OEIS claim.
