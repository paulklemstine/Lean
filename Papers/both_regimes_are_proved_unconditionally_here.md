# Computational Evidence

All numbers below were produced inside Lean 4 (Mathlib v4.28.0) with `#eval` on the
definitions used in the formal statements, and the boxed subset is additionally **checked by
the Lean kernel** with `decide` in `Catalog/Novelty/KleinFourNumericalEvidence.lean`
(no `native_decide`, no external scripts).

## 1. The object

For a prime `p` and `d ∈ 𝔽_p^×` let `E_d : y² = x³ − 3 d² x`.  Its full 2-torsion group is

```
|E_d(𝔽_p)[2]| = 1 + #{ x ∈ 𝔽_p : x³ = 3 d² x }      (point at infinity + affine 2-torsion)
```

and the quantity under study is

```
sumV4(p) = Σ_{d ≠ 0} |E_d(𝔽_p)[2]|.
```

The companion quantity for the `j = 0` family `y² = x³ + b` is the summed number of roots of the
3-division polynomial `ψ₃ = 3X⁴ + 12bX`:

```
sumPsi3(p) = Σ_{b ≠ 0} #{ x ∈ 𝔽_p : 3x⁴ + 12 b x = 0 }.
```

## 2. Small-case table

| p  | p mod 12 | p mod 3 | sumV4(p) | 4(p−1) | 2(p−1) | sumPsi3(p) |
|----|----------|---------|----------|--------|--------|------------|
| 5  | 5        | 2       | 8        | 16     | 8      | 8          |
| 7  | 7        | 1       | 12       | 24     | 12     | 12         |
| 11 | 11       | 2       | 40       | 40     | 20     | 20         |
| 13 | 1        | 1       | 48       | 48     | 24     | 24         |
| 17 | 5        | 2       | 32       | 64     | 32     | 32         |
| 19 | 7        | 1       | 36       | 72     | 36     | 36         |
| 23 | 11       | 2       | 88       | 88     | 44     | 44         |
| 29 | 5        | 2       | 56       | 112    | 56     | 56         |
| 31 | 7        | 1       | 60       | 120    | 60     | 60         |
| 37 | 1        | 1       | 144      | 144    | 72     | 72         |
| 41 | 5        | 2       | 80       | 160    | 80     | 80         |
| 43 | 7        | 1       | 84       | 168    | 84     | 84         |
| 47 | 11       | 2       | 184      | 184    | 92     | 92         |
| 53 | 5        | 2       | 104      | 208    | 104    | 104        |

## 3. Readings of the data

1. **Exact dichotomy for `sumV4`.**  `sumV4(p) = 4(p−1)` precisely for `p ≡ 1, 11 mod 12`
   (13, 37 and 11, 23, 47 in the table) and `sumV4(p) = 2(p−1)` precisely for `p ≡ 5, 7 mod 12`.
   No prime in the sample deviates.  This is exactly the statement proved unconditionally in
   `KleinFourTwoTorsion.sum_card_V4_mod_twelve`.

2. **Regime-independence of `sumPsi3`.**  `sumPsi3(p) = 2(p−1)` for *every* prime in the sample,
   irrespective of `p mod 3`, even though the individual fibre counts are `2` when `p ≡ 2 mod 3`
   and jump to `4` for the cube-residue values of `−4b` when `p ≡ 1 mod 3`.  The individual
   variation cancels in the sum: this is the fibre-counting bijection `x ↦ −x³/4`, formalised as
   `DivisionPolynomialFibres.sum_card_psi3_roots`.

3. **Counterexample hunt.**  Searching all primes `5 ≤ p ≤ 53` for a violation of either law
   returned none.  The kernel-checked instances `p = 5, 7, 11, 13, 17, 19, 23` are recorded as
   theorems (`KleinFourNumericalEvidence.sum_card_V4_*`) so the table cannot silently drift from
   the definitions.

4. **Sequence remark.**  The split-value sequence `4(p−1)` for `p ≡ ±1 mod 12` and `2(p−1)`
   otherwise is not a standalone OEIS entry; the underlying index sequence of split primes
   `11, 13, 23, 37, 47, 59, 61, …` is the classical list of primes with `(3/p) = 1`.  No OEIS
   identifier is asserted here.

## 4. What the evidence did *not* settle

* Whether an analogous closed form exists for `Σ_{d ≠ 0} |E_d(𝔽_p)[3]|` (the `ψ₃` count above
  counts `x`-coordinates only, not points, and the point count involves the quadratic character
  of `x³ + b`, i.e. genuinely deeper `a_p`-type information).
* Whether the `mod 12` dichotomy persists for the higher division polynomials `ψ_n`, `n ≥ 4`,
  where the relevant factorisation is over the `n`-division field rather than `ℚ(√3)`.
