# Computational evidence (exploratory; not machine-checked)

These numbers were produced by a short exploratory script (direct enumeration in
Python), *before* the Lean formalisation.  They are **not** part of the verified
artifact: everything asserted in the `.lean` files is proved from scratch and
compiles without `sorry`.  The tables below only motivated the constants that the
Lean statements carry.

## 1. Counting the Berggren-generated triples in the box `[1,H]³`

`#berg(H)` = triples obtained from the seed `(3,4,5)` by the three Berggren
matrices, all coordinates `≤ H` (breadth-first enumeration).
`#PPT_odd(H)` = primitive Pythagorean triples with odd first leg and `c ≤ H`
(enumerated through the `(m,n)` parametrisation).

| H | #berg(H) | #PPT_odd(H) | #berg(H)/H | proved upper bd `4H` | proved lower bd `H/200` | equal? |
|---:|---:|---:|---:|---:|---:|:--|
| 10 | 1 | 1 | 0.1000 | 40 | 0.05 | yes |
| 50 | 7 | 7 | 0.1400 | 200 | 0.25 | yes |
| 100 | 16 | 16 | 0.1600 | 400 | 0.50 | yes |
| 500 | 80 | 80 | 0.1600 | 2000 | 2.50 | yes |
| 1000 | 158 | 158 | 0.1580 | 4000 | 5.00 | yes |
| 5000 | 792 | 792 | 0.1584 | 20000 | 25.0 | yes |
| 10000 | 1593 | 1593 | 0.1593 | 40000 | 50.0 | yes |
| 50000 | 7960 | 7960 | 0.1592 | 200000 | 250.0 | yes |
| 100000 | 15919 | 15919 | 0.1592 | 400000 | 500.0 | yes |

Two observations, both of which became theorems:

* the two columns agree for every `H` tested — this is Berggren's completeness
  theorem, formalised as `BerggrenTree.reach_iff_valid` and
  `BerggrenBoxCounting.bergBox_eq_ppOddBox`;
* the ratio `#berg(H)/H` stabilises near `0.1592 ≈ 1/(2π)` (the classical
  Lehmer constant for primitive Pythagorean triples with `c ≤ H`), comfortably
  inside the interval `[1/200, 4]` that the Lean theorems
  `bergBox_card_ge` / `bergBox_card_le` establish unconditionally.
  The count is therefore `Θ(H)`, hence `o(H³)`.

Related OEIS sequence: the number of primitive Pythagorean triples with
hypotenuse `≤ 10^k` is A101929-adjacent; the asymptotic density `1/(2π)` is
classical (Lehmer, 1900).  Our proof does **not** use it: only the effective
two-sided bound is proved.

## 2. Coprime pairs of opposite parity (the arithmetic input)

`copOpp(X)` = pairs `1 ≤ n < m ≤ X`, `gcd(n,m) = 1`, `n+m` odd.

| X | copOpp(X) | copOpp(X)/X² | proved lower bound `(11X²−36)/144` |
|---:|---:|---:|---:|
| 10 | 22 | 0.2200 | 7.4 |
| 50 | 518 | 0.2072 | 190.7 |
| 100 | 2040 | 0.2040 | 763.6 |
| 500 | 50765 | 0.2031 | 19097.0 |
| 1000 | 202861 | 0.2029 | 76388.6 |

The true density is `2/π² ≈ 0.2026`; the elementary sieve bound proved in
`CoprimePairDensity.card_copOpp_ge` gives `11/144 ≈ 0.0764`, i.e. it is off by a
factor `≈ 2.65` but is completely explicit and needs no analytic input.

## 3. Counterexample hunt / corner cases

* `H < 5`: the box contains no Berggren triple at all, so a lower bound of the
  form `H ≤ c·#berg(H)` must assume `H ≥ 5`; the Lean statement carries exactly
  this hypothesis.
* Triples with **even** first leg (e.g. `(4,3,5)`) are primitive Pythagorean but
  never occur in the tree; they are exactly the swaps of the tree elements.  This
  is why `#ppBox(H) = 2 · #bergBox(H)` (theorem
  `card_ppBox_eq_two_mul_card_bergBox`) rather than `#ppBox = #bergBox`.
* Non-primitive triples such as `(6,8,10)` are in the box but never in the tree.

## 4. Depth of the tree inside the box

Maximal depth of a node with hypotenuse `≤ H`:

| H | max depth | `log₆(H/5)` | `√H/2` |
|---:|---:|---:|---:|
| 100 | 5 | 1.67 | 5.0 |
| 1000 | 20 | 2.96 | 15.8 |
| 10000 | 69 | 4.24 | 50.0 |
| 100000 | 222 | 5.53 | 158.1 |

The depth grows like `√H`, not like `log H`: the ternary tree is extremely
unbalanced.  Both sides of this phenomenon are formalised in
`BerggrenTreeGeometry.lean`: `hyp_le_of_reachIn` (`c ≤ 5·6^d`, so depth
`≥ log₆(c/5)`) and `spine_reachIn` (a branch of depth `k` with hypotenuse only
`4(k+1)²+1`).
