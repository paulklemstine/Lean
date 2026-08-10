# Computational evidence — `M × N` toric code

All numbers below were produced **inside Lean**, by `#eval` on the very
definitions that the theorems are stated about (`ToricCode.d1`, `ToricCode.d2`,
`hammingNorm`), so there is no separate model to trust.  The enumeration is a
complete brute force over all `2^(2L²)` binary one-chains.

```lean
import ToricCode.Dual
open Matrix ToricCode

def brute (L : ℕ) [NeZero L] : Option ℕ × ℕ × ℕ :=
  let cyc := (Finset.univ : Finset (Edge L → F2)).filter (fun z => d1 L *ᵥ z = 0)
  let bnd := (Finset.univ : Finset (Face L → F2)).image (fun g => d2 L *ᵥ g)
  (((cyc \ bnd).image hammingNorm).min, cyc.card, bnd.card)

def bruteDual (L : ℕ) [NeZero L] : Option ℕ × ℕ × ℕ :=
  let cyc := (Finset.univ : Finset (Edge L → F2)).filter (fun z => (d2 L)ᵀ *ᵥ z = 0)
  let bnd := (Finset.univ : Finset (Vert L → F2)).image (fun g => (d1 L)ᵀ *ᵥ g)
  (((cyc \ bnd).image hammingNorm).min, cyc.card, bnd.card)
```

## 1. Small-case calculations

| `L` | `n = 2L²` | `#cycles` | `2^(L²+1)` | `#boundaries` | `2^(L²−1)` | min weight of a non-boundary cycle | dual min |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 1 | 2  | 4    | 4    | 1   | 1   | **1** | 1 |
| 2 | 8  | 32   | 32   | 8   | 8   | **2** | 2 |
| 3 | 18 | 1024 | 1024 | 256 | 256 | **3** | 3 |

`L = 4` needs `2³² ≈ 4·10⁹` chains and was not enumerated; the general theorem
`ToricCode.toric_distance` supersedes it for all `L`.

Consequences visible already in the table, and later proved in general:

* `dim ker d₁ = L² + 1` and `dim im d₂ = L² − 1`, hence `dim H₁ = 2` — matching
  `ToricCode.finrank_cycles`, `ToricCode.finrank_boundaries`,
  `ToricCode.toric_homologyRank`.
* `d_Z = d_X = L` — matching `ToricCode.toric_distance` and
  `ToricCode.toric_dualDistance`.  The exact coincidence of the *whole* primal
  and dual data is explained by the quarter-turn self-duality
  `ToricCode.dualLogicalWeights_eq`.
* `k · d² = 2 · L² = n` exactly — `ToricCode.toric_BPT_saturation`.

## 2. Sequence / OEIS

The distances form the sequence `1, 2, 3, 4, …` (A000027) as a function of `L`,
and the block lengths `2, 8, 18, 32, …` are `2n²` (A001105).  Neither is
informative: the content of the result is the *pair* `(n, d) = (2L², L)`, i.e.
the exact relation `2d² = n`, not either sequence separately.  No OEIS lookup is
needed or useful here.

## 3. Counterexample hunt

The universal claim under test was

> for every `L ≥ 1`, every cellular one-cycle on the `L × L` square torus that
> is not a boundary has Hamming weight at least `L`.

The brute force above checks this claim *exhaustively* for `L ≤ 3` — every one
of the `2^(2L²)` chains is examined, not a sample.  No counterexample exists in
that range.  Two natural strengthenings were also tested and **refuted**, which
is why they do not appear as theorems:

* "weight `> L`": refuted at every `L` by the row loop `loopH`, weight exactly
  `L`.
* "every non-boundary cycle has weight exactly `L`": refuted already at `L = 2`.
  The full logical weight spectra (sorted, computed by the same enumeration) are

  | `L` | attained weights of non-boundary cycles |
  |---:|:---|
  | 1 | `1, 2` |
  | 2 | `2, 4, 6` |
  | 3 | `3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 18` |

  so only the *infimum* is `L`.  For instance at `L = 2` the sum of a row loop
  and a column loop is a weight-`4` logical operator.

## 4. What the evidence did *not* settle

The evidence is silent about the mechanism.  In particular it gave no hint that
the clean route to the lower bound is a *dimension count* (the winding map has
`(L²−1)`-dimensional kernel, which equals the boundary space) rather than an
explicit construction of a bounding face chain.  That observation came from the
failed attempt at the direct construction and is recorded in the Lab Notes of
`Catalog/Geometry/ToricCode/Distance.lean`.

## 5. Rectangular tori (this cycle)

The same exhaustive enumeration, run on the general `M × N` grid with the
rectangular definitions, over all `2^(2MN)` chains:

| `M` | `N` | `n = 2MN` | `#cycles` | `#boundaries` | `Z`-spectrum | `X`-spectrum |
|---:|---:|---:|---:|---:|:---|:---|
| 1 | 2 | 4  | 8   | 2  | `1, 2, 3, 4` | `1, 2, 3, 4` |
| 1 | 3 | 6  | 16  | 4  | `1, 3, 4, 5, 6` | `1, 3, 4, 5, 6` |
| 2 | 2 | 8  | 32  | 8  | `2, 4, 6` | `2, 4, 6` |
| 2 | 3 | 12 | 128 | 32 | `2, 3, 4, 5, 6, 7, 8, 9, 12` | `2, 3, 4, 5, 6, 7, 8, 9, 12` |

Every minimum equals `min M N`, matching `ToricCode.toric_distance`, and the
primal and dual spectra coincide **as sets** in every case, matching
`ToricCode.dualLogicalWeights_eq` (now derived from the abstract
`BinaryCSS.SelfDual.logicalWeights_eq`).  Note `#cycles = 2^(MN+1)` and
`#boundaries = 2^(MN−1)` throughout, i.e. `dim H₁ = 2`.

## 6. Weights inside a single homology class

Restricting the enumeration to the diagonal class (both winding parities
nonzero):

| `M` | `N` | `M + N` | attained weights in the diagonal class |
|---:|---:|---:|:---|
| 1 | 2 | 3 | `3` |
| 1 | 3 | 4 | `4, 6` |
| 2 | 2 | 4 | `4` |
| 2 | 3 | 5 | `5, 7, 9` |
| 3 | 3 | 6 | `6, 8, 10, 12, 14, 18` |

The minimum is `M + N` in every case — `ToricCode.diagonal_class_distance` —
strictly above the code distance `min M N`.

## 7. Counting the distance optimisers

Number of logical operators of the minimal weight `min M N`, compared with the
`N` row loops:

| `M` | `N` | `#minimum-weight logicals` | `#row loops` | equal as sets? |
|---:|---:|---:|---:|:---|
| 1 | 2 | 2 | 2 | yes |
| 1 | 3 | 3 | 3 | yes |
| 2 | 3 | 3 | 3 | yes |
| 2 | 2 | 4 | 2 | **no** |

This is exactly `ToricCode.min_weight_logicals_card`, and the last row shows why
its hypothesis `M < N` cannot be dropped: on the square torus the `L` column
loops attain the distance as well, giving `2L` optimisers.
