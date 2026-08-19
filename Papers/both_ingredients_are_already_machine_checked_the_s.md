# Computational evidence

All numbers below were obtained by exhaustive enumeration (Python, brute force over vertex
subsets) *before* the Lean formalisation; every claim that survived is now a machine-checked
theorem in `Catalog/Novelty/`.  The enumeration itself is exploratory and is **not** the
verification: the verification is the Lean development (0 `sorry`, no `native_decide`).

## 1. Where can a 1-sum lose independence?

For a 1-sum `G = G₁ ⊕_v G₂` with sides of sizes `n₁, n₂` and independence numbers `α₁, α₂`,
the exact independence number is

```
α(G) = max( α(G₁ - v) + α(G₂ - v) ,  α_v(G₁) + α_v(G₂) - 1 )
```

(`α_v` = largest independent set containing `v`).  A parameter sweep over
`(nᵢ, αᵢ, α(Gᵢ - v))` shows that an amalgam of two graphs with `i(Gᵢ) ≥ 1/4` can only fall
below `1/4` when, on both sides,

* `4αᵢ - nᵢ ≤ 1` (the side sits essentially exactly on the threshold), and
* `α(Gᵢ - v) = αᵢ - 1` (every maximum independent set uses the cut vertex).

The smallest graph meeting both conditions is `K₈` minus an edge, with `v` an endpoint of the
missing edge: `n = 8`, `α = 2`, `α(G - v) = 1`, `i = 2/8 = 1/4`.

## 2. The two-part counterexample (exhaustive check)

Glue two copies of `K₈ - e` at an endpoint of the missing edge; the amalgam has `15` vertices.
Enumerating all `2¹⁵` subsets:

| object | vertices `n` | independence number `α` | ratio `i = α/n` |
|---|---|---|---|
| `K₈ - e` (each side) | 8 | 2 (e.g. `{0,1}`) | `1/4` |
| amalgam `Glue` | 15 | 3 (e.g. `{0,1,8}`) | `1/5 = 0.2` |

So `i` drops from `1/4` to `1/5`, i.e. **the property `i ≥ 1/4` is not closed under 1-sums**
(formalised in `Catalog/Novelty/OneSumIndepRatioCounterexample.lean`).  Note
`1/4 - (1 - 1/4)/15 = 1/5` exactly: the drop equals the general defect term.

## 3. The `m`-fold family `StarK8 m`

Glue `m` copies of `K₈ - e` at one common vertex (`n = 7m + 1`).  Brute force for `m ≤ 3`
confirms the predicted `α = m + 1`:

| `m` | `n = 7m+1` | `α` (brute force) | `α` predicted | `i = α/n` | `i - 1/7` |
|---|---|---|---|---|---|
| 1 | 8 | 2 | 2 | `1/4` = 0.25000 | `3/28` |
| 2 | 15 | 3 | 3 | `1/5` = 0.20000 | `2/35` |
| 3 | 22 | 4 | 4 | `2/11` ≈ 0.18182 | `3/77` |
| 4 | 29 | — | 5 | `5/29` ≈ 0.17241 | `6/203` |
| 5 | 36 | — | 6 | `1/6` ≈ 0.16667 | `1/42` |
| 7 | 50 | — | 8 | `4/25` = 0.16000 | `3/175` |
| 10 | 71 | — | 11 | `11/71` ≈ 0.15493 | `6/497` |

The differences match the closed form `i - 1/7 = 6/(7(7m+1))` exactly — this identity is now
the theorem `SimpleGraph.StarFamily.starIndepRatio_sub_seventh`, and `α = m+1` for *all* `m` is
`SimpleGraph.StarFamily.starIndepNum` (proved by a blockwise injection argument, not by
enumeration).

## 4. Counterexample hunt against the *colouring* side

No counterexample exists, and none can: `k`-colourability is closed under 1-sums and under
star amalgams (`SimpleGraph.IsOneSum.colorable`, `SimpleGraph.IsStarSum.colorable`).  A random
search over pairs of `4`-colourable graphs on ≤ 9 vertices with a marked cut vertex found, as
predicted, no amalgam with `i < 1/4`.  Consistently, the sides of the counterexample above are
*not* `4`-colourable: `K₈ - e` contains `K₇` (`K8me_not_colorable_four`).

## 5. Sequences

`α(StarK8 m) = m + 1` and `n = 7m+1` are arithmetic progressions; the ratio sequence
`2/8, 3/15, 4/22, 5/29, …` is `(m+1)/(7m+1)`.  No OEIS entry is needed for such a linear
family, and none is claimed.

## 6. Locating the amalgamation floor (second cycle)

To find the *absolute* floor of the ratio over all star amalgams of parts of density `≥ 1/4`,
one minimises the per-side contribution.  Deleting the cut vertex, a side of size `N` with an
independent set of size `≥ ⌈N/4⌉` contributes at least `max(⌈N/4⌉ - 1, 1)` vertices out of the
`N - 1` non-cut vertices of that side:

| side size `N` | 2 | 4 | 5 | 6 | 7 | 8 | 9 | 12 | 16 | 20 | 40 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `max(⌈N/4⌉-1, 1)` | 1 | 1 | 1 | 1 | 1 | 1 | 2 | 2 | 3 | 4 | 9 |
| contribution `/(N-1)` | 1.000 | 0.333 | 0.250 | 0.200 | 0.167 | **0.1429** | 0.250 | 0.182 | 0.200 | 0.211 | 0.231 |

The unique minimum over `2 ≤ N ≤ 40` is at `N = 8`, value `1/7 ≈ 0.14286`; the two regimes
(`N ≤ 7`, where the contribution is `1/(N-1)`, and `N ≥ 8`, where it is `(N-4)/(4(N-1))`) meet
exactly there.  This is precisely the case split of the formal proof in
`Catalog/Novelty/StarAmalgamSeventhBarrier.lean`, and it explains why `K₈ - e` — and no smaller
graph — is the extremal part.

Sanity check of the resulting bound against the explicit family: for `StarK8 m` the table of
§3 gives `i = (m+1)/(7m+1) ≥ 1/7` for every `m`, with the gap `6/(7(7m+1))` shrinking to `0`.
Both halves are theorems: `SimpleGraph.IsStarSum.indepRatio_ge_seventh` and
`SimpleGraph.StarFamily.seventh_barrier_optimal`.
