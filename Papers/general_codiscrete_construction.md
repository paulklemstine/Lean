# Computational evidence

All numbers below were produced with Lean `#eval` scripts (interpreted, exact integer
arithmetic) over explicit multiplication tables.  A *unital magma of order `n`* is encoded as a
table on `{0, …, n-1}` with `0` as a two-sided unit, so the free data is the `(n-1) × (n-1)`
block of products of non-units.  The *defect* is
`D(M) = #{(a,b,c) ∈ M³ : (a*b)*c ≠ a*(b*c)}`.

These computations guided the theorems in
`Catalog/Combinatorics/UnitalMagmaDefect.lean`; the theorems themselves are proved in Lean
without any appeal to these computations (except one `decide` corroboration of the
three-element example, which the kernel checks).

## 1. Order 3: complete enumeration (81 unital magmas)

| defect | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| count | 11 | 0 | 14 | 8 | 18 | 12 | 12 | 4 | 2 |

* Maximum `= 8 = (3-1)³`, attained twice — matching the proved bound
  `defect_le_of_unital` and its sharpness `exists_unital_magma_maximal_defect`.
* `11` magmas are monoids (defect `0`); by `strict_iff_defect_zero` these are exactly the ones
  whose codiscrete bicategory is strict.
* Value `1` does not occur at order 3.  (It *does* occur at order 4, see below, so no general
  "no isolated defect" law holds; the correct general statement is the parity theorem.)

## 2. Order 4: complete enumeration (4⁹ = 262144 unital magmas)

Defect histogram, index `0 … 27`:

```
156, 84, 264, 228, 843, 924, 1538, 2112, 3249, 4296, 5955, 7104, 9973, 12096,
15540, 17376, 21567, 24240, 27273, 26628, 26052, 21896, 15498, 10428, 4652,
1800, 288, 84
```

* Maximum `= 27 = (4-1)³`, attained by `84` tables (our shift-magma construction accounts for
  the `2³ = 8` fixed-point-free maps `σ` on the 3 non-units, plus `8` mirror images; the
  remaining maximisers are not of shift form — see Future Direction 1).
* Defect `1` occurs `84` times, and **none** of those magmas is commutative, exactly as the
  parity theorem `defect_even_of_comm` predicts.

## 3. Commutative unital magmas

| order `n` | # commutative tables searched | odd defects found | max defect | `(n-1)³ - (n-1)²` |
|---|---|---|---|---|
| 3 | 27 (exhaustive) | 0 | 4 | 4 |
| 4 | 4096 (exhaustive) | 0 | 18 | 18 |
| 5 | 20000 (random) | – | 48 | 48 |

* No commutative example with odd defect was ever found: proved as `defect_even_of_comm`.
* The maximum always equals `(n-1)³ - (n-1)²`: proved as an upper bound
  (`defect_le_of_comm_unital`) and, for `n - 1` odd, as an equality via the negation magma
  (`exists_comm_unital_magma_maximal_defect`).  For `n-1 ∈ {2, 4}` (even) the bound is attained
  computationally but our construction does not cover it — see Future Direction 2.

## 4. Spot checks of the constructions

* `ShiftMagma` on `Bool` (order 3, `σ = not`): defect `8`.  This is verified *inside Lean by
  `decide`* in `UnitalMagmaDefect.lean`, and also follows from `ShiftMagma.defect_eq_card`.
* `ShiftMagma` on `Fin 3` with `σ` a 3-cycle (order 4): defect `27`.
* Negation magma on `ZMod 3` (order 4): commutative, defect `18`.

## 5. OEIS

No OEIS lookup was performed (no network access in this environment), so the sequences
`2, 84, …` (number of order-`n` unital magmas of maximal defect) and
`11, 156, …` (number of order-`n` monoids with a labelled unit) are reported here as raw
computational data only, with no claim about their appearance in OEIS.
