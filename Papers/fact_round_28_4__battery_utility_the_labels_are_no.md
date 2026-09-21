# Computational evidence — BATTERY-UTILITY (round-28 #4, `THE-LABELS-ARE-NOT-FILTERS`)

Test polynomial: `f = X³ - 2`, the smallest non-abelian probe (splitting field `ℚ(∛2, ω)`,
Galois group `S₃`).  Label of a prime `p`: `cubicType p = #{x mod p : x³ ≡ 2}` ∈ `{0, 1, 3}`.

All numbers below are reproduced *inside Lean* (kernel `decide`, no external trust) in
`Catalog/Pythagorean/BatteryUtilityLabelsNotFilters.lean`; the exploratory enumeration that
found them is recorded here.

## 1. Small-case table

| p | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 | 61 | 67 | 71 | 73 | 79 |
|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| `p mod 3` | 2 | 1 | 2 | 1 | 2 | 1 | 2 | 2 | 1 | 1 | 2 | 1 | 2 | 2 | 2 | 1 | 1 | 2 | 1 | 1 |
| label | 1 | 0 | 1 | 0 | 1 | 0 | 1 | 1 | 3 | 0 | 1 | 3 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | 0 |

Observation, later proved: label `= 1` **iff** `p ≡ 2 (mod 3)`; for `p ≡ 1 (mod 3)` the label is
`0` or `3`, and *both* occur.

## 2. Counterexample hunt: is the label a function of the residue?

For each modulus `m`, search for two primes `p ≡ q (mod m)`, both `≡ 1 (mod 3)`, with different
labels.  A witness was found for **every** `m` in `2 … 24`, with all primes `< 200`:

```
m :  2      3      4      5       6      7       8      9      10
     7,31   7,31   7,31   13,43   7,31   31,73   7,31   13,31  13,43
m : 11      12     13       14      15      16      17      18
     31,97   7,31   79,157   31,73   13,43   31,79   7,109   13,31
m : 19       20       21      22      23       24
     13,127   43,103   31,73   31,97   19,157   7,31
```

(labels of the two members are always `0` and `3`).  No modulus in the scanned range admits a
residue → label table; these witnesses are the cases of `no_residue_type_map`.

## 3. The measured window (the `(6,2 | 5,2 | 5,1)` table)

The `21` primes `5 ≤ p < 200` with `p ≡ 1 (mod 3)`, cross-tabulated by residue mod `9` and
label:

| residue mod 9 | label 0 | label 3 | row total |
|---|---|---|---|
| 1 | 6 | 2 | 8 |
| 4 | 5 | 2 | 7 |
| 7 | 5 | 1 | 6 |
| **total** | **16** | **5** | **21** |

Every row is mixed — that is the within-class variation.  Verified in Lean as `window_census`
and `window_rows_mixed`.

## 4. Entropy readings of that table (natural logs)

```
H(T)   = 0.54887     (labels 16/21, 5/21)
H(T|R) = 0.54238     (row-wise conditional entropy)
I(R;T) = 0.00650     (≈ 1.2 % of the ceiling)
```

So `I ≪ H(T)`: the residue mod `9` explains barely one per cent of the label entropy of this
window, the rest being within-class.  The qualitative statement `0 < H(T|R)`, hence
`I < H(T)`, is the Lean theorem `measured_window_gap`; the decimal values above are numerical
exploration only and are *not* claimed as verified.

## 5. Equidistribution (Chebotarev) model

Densities inside `p ≡ 1 (mod 3)`: label `0` with `2/3`, label `3` with `1/3`, independent of the
residue mod `9`.  Then

```
I(R;T) = 0                H(T) = log 3 - (2/3) log 2 = 0.6365…
```

— the whole ceiling is within-class variation.  Both statements are proved
(`chebotarev_model_gap`).

## 6. OEIS

The label sequence of the primes `5, 7, 11, 13, …` — `1,0,1,0,1,0,1,1,3,0,1,3,…` — is the root
count of `x³ ≡ 2`; the underlying split of primes by cubic residuacity of `2` is the classical
`p = x² + 27y²` criterion (Gauss).  No new sequence is claimed.
