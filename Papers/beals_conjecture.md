# Computational evidence for the Beal / Fermat–Catalan / `abc` cluster

All numbers below were produced by `#eval` inside Lean 4 (kernel-independent evaluation) or,
where indicated, by a `decide` proof that the Lean **kernel** checked.  Statements marked
*(kernel-verified)* are backed by a theorem in the `.lean` files; the rest are exploratory
computations only.

## 1. Search for coprime Beal solutions

Search over `1 ≤ A ≤ B ≤ 40`, `gcd(A,B) = 1`, `3 ≤ x, y, z ≤ 7`, testing whether `A^x + B^y`
is a perfect `z`-th power:

```
number of coprime solutions found : 0
```

No counterexample to Beal's conjecture exists in this box.

*(kernel-verified)* The sub-box `A, B ≤ 10`, `C ≤ 40`, `3 ≤ x, y, z ≤ 5` is verified inside Lean
by `Beal.beal_verified_small_box` (proved through a `decide` exhaustive check, so the Lean kernel
re-executes the whole enumeration).

## 2. Search for Beal solutions *with* a common factor

Same search without the coprimality filter, over `1 ≤ A ≤ B ≤ 30`, `3 ≤ x, y, z ≤ 6`:
18 solutions were found, e.g.

| `A` | `B` | `C` | `x` | `y` | `z` | identity |
|----|----|----|----|----|----|----------|
| 3 | 6 | 3 | 3 | 3 | 5 | `27 + 216 = 243` |
| 4 | 4 | 8 | 4 | 4 | 3 | `256 + 256 = 512` |
| 7 | 7 | 14 | 4 | 3 | 3 | `2401 + 343 = 2744` |
| 8 | 8 | 4 | 3 | 3 | 5 | `512 + 512 = 1024` |
| 9 | 18 | 9 | 3 | 3 | 4 | `729 + 5832 = 6561` |
| 15 | 15 | 30 | 5 | 4 | 4 | `759375 + 50625 = 810000` |
| 16 | 16 | 32 | 6 | 6 | 5 | `16^6 + 16^6 = 32^5` |
| 26 | 26 | 78 | 4 | 3 | 3 | `456976 + 17576 = 474552` |

Every one of them has a common prime factor, as Beal's conjecture predicts.  Note the strong
empirical pattern: in this range *all* solutions have `A = B` or `B = 2A`, i.e. they come from
the identity `a^n + a^n = 2a^n` or `a^n + (2a)^n = a^n(1+2^n)` after absorbing the cofactor into
a power.  The `A = B` family is proved unconditionally in
`Beal.beal_holds_of_bases_eq`, and an infinite scaled family is exhibited in
`Beal.infinitely_many_beal_solutions`.

## 3. Fermat–Catalan solutions with one exponent equal to `2`

These *do* exist and are coprime; they are the reason Beal's hypothesis `x, y, z ≥ 3` cannot be
weakened.  All four identities below were checked in Lean and each is used in a theorem
(`Beal.beal_false_with_first_exponent_two`, `..._middle_...`, `..._last_...`):

```
7^3 + 13^2 = 343 + 169 = 512   = 2^9
2^5 + 7^2  =  32 +  49 =  81   = 3^4
2^7 + 17^3 = 128 + 4913 = 5041 = 71^2
1^n + 2^3  =   1 +   8 =   9   = 3^2   (any n)
```

The known list of Fermat–Catalan solutions (10 known, all with an exponent equal to `2`) is a
strong empirical indication that the Fermat–Catalan conjecture — and hence, by
`Beal.finite_of_fermatCatalan_finite`, the finiteness of Beal counterexamples — is plausible.

## 4. Exponent arithmetic behind the `abc` argument

For `x, y, z ≥ 3` one has `1/x + 1/y + 1/z ≤ 1`, with equality only at `(3,3,3)`; since FLT₃
excludes `(3,3,3)`, every Beal solution satisfies `1/x + 1/y + 1/z ≤ 11/12`
(`Beal.exponent_sum_le_eleven_twelfths`).  Numerically:

| `(x,y,z)` | `1/x+1/y+1/z` |
|-----------|----------------|
| (3,3,3)   | 1 (impossible by FLT₃) |
| (3,3,4)   | 11/12 ≈ 0.9167 |
| (3,3,5)   | 13/15 ≈ 0.8667 |
| (3,4,4)   | 5/6 ≈ 0.8333 |
| (4,4,4)   | 3/4 |

The gap `1 − 11/12 = 1/12` is precisely the room needed to run the `abc` inequality with
`ε = 1/12`, which is how `Beal.counterexample_bounded_of_abcBound` obtains `C^z ≤ K^12`.

## 5. Function-field side

Over `ℚ[X]` the analogue of Beal is a theorem (`Beal.polynomial_beal`).  The scaled example
`(3X^5)^3 + (6X^5)^3 = (3X^3)^5` (obtained from `3^3 + 6^3 = 3^5` by multiplying by `X^15`)
shows the polynomial statement is not vacuous, and its entries indeed share the factor `X`.
