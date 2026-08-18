# Computational evidence — kernel patterns, Bell numbers, and Pythagorean spectra

All computations below were run inside Lean 4 (`#eval`, or `decide` where a proof is
claimed).  Everything that is asserted as a *theorem* in the `.lean` files is proved; the
tables here record the exploratory data that motivated those theorems.

## 1. Counting kernel patterns (small cases)

`KernelPattern.canon f i` is the least index `j` with `f j = f i`; a *pattern* is a fixed
point of `canon`.  Evaluating the number of fixed points of `canon` on `Fin n → Fin n`:

| `n` | # patterns | `Nat.bell n` |
|----|-----------|--------------|
| 0  | 1         | 1            |
| 1  | 1         | 1            |
| 2  | 2         | 2            |
| 3  | 5         | 5            |
| 4  | 15        | 15           |
| 5  | 52        | 52           |

`#eval` of both columns gives `(1, 1, 2, 5, 15, 52)`; this is OEIS **A000110** (Bell
numbers).  The rows `n ≤ 5` are *proved* by `decide` in
`Catalog/Pythagorean/KernelPatterns.lean`
(`card_patterns_zero` … `card_patterns_five`, `card_patterns_eq_bell_of_le_five`).
The identity for **all** `n` is proved in `Catalog/Pythagorean/KernelPatternsBell.lean`
(`card_patterns_eq_bell`); it is not a numerical extrapolation.

## 2. Refinement by number of blocks (Stirling triangle)

Counting patterns of length `n` with exactly `k` blocks (`KernelPattern.stirling2`),
verified by `decide` in `Catalog/Pythagorean/KernelBlockCount.lean`:

| `n \ k` | 0 | 1 | 2  | 3  | 4  | 5 | row sum |
|--------|---|---|----|----|----|---|---------|
| 3      | 0 | 1 | 3  | 1  |    |   | 5       |
| 4      | 0 | 1 | 7  | 6  | 1  |   | 15      |
| 5      | 0 | 1 | 15 | 25 | 10 | 1 | 52      |

Row sums reproduce the Bell numbers, as proved in general by `sum_stirling2_eq_bell`.
(The rows are the Stirling numbers of the second kind, OEIS A008277.)

## 3. Counterexample hunt: which patterns do Pythagorean triples realise?

Exhaustive search over `0 ≤ a, b < 25`, `0 ≤ c < 40` with `a² + b² = c²`, recording
`canon ![a,b,c]`:

```
realised patterns : (0,0,0), (0,1,1), (0,1,0), (0,1,2)
missing pattern   : (0,0,2)      -- "the two legs agree, the hypotenuse differs"
```

Four of the `Nat.bell 3 = 5` patterns occur; the search found **no** counterexample to the
conjecture that `(0,0,2)` is impossible.  That conjecture is now the theorem
`PythagoreanKernel.pyth_kernel_spectrum` (with the arithmetic core
`isSquare_of_mul_sq_eq_sq`: `k·a² = c²` with `a ≠ 0` forces `k` to be a perfect square).

Witnesses for the four realised patterns (all verified by `decide` in the Lean files):

| pattern    | triple      |
|-----------|-------------|
| `(0,1,2)` | `(3, 4, 5)` |
| `(0,1,1)` | `(0, 1, 1)` |
| `(0,1,0)` | `(1, 0, 1)` |
| `(0,0,0)` | `(0, 0, 0)` |

## 4. Dimensional and exponential dependence

* Constant legs `∑_{i<k} a² = y²` with `a ≠ 0`: solvable iff `k` is a perfect square.
  Data: `k = 2` no, `k = 3` no, `k = 4` yes (`1+1+1+1 = 2²`), `k = 9` yes
  (`a = 1, y = 3`).  Proved: `PythagoreanKernel.constant_legs_iff`.
* Exponent `p`: for `p = 1` the triple `(1,1,2)` realises the "equal legs" pattern, so all
  five patterns occur; for every `p ≥ 2` that pattern is impossible (2-adic valuation
  argument).  Proved: `FermatKernel.spectrum_one`, `FermatKernel.two_mul_pow_ne_pow`.

## 5. Growth data for the Bell numbers

`Nat.bell` evaluated: `1, 1, 2, 5, 15, 52, 203, …`.  Strictly increasing from `n = 1`,
which is proved in general in `Catalog/Pythagorean/BellMonotone.lean`
(`Nat.bell_lt_bell_succ`) by an explicit injection of patterns, not by numerics.
