# Computational evidence

All numbers below were produced by exact integer polynomial arithmetic (recursive exact division
`Φ_n = (X^n − 1) / ∏_{d ∣ n, d < n} Φ_d`).  They guided the choice of theorems; **the statements
that are claimed as results are the ones proved in Lean** in `Catalog/Algebra/PMFrame*.lean`.
The three explicit polynomials used in the Lean proofs (`Φ₁₀₅`, `Φ₂₃₁`, `Φ₃₈₅`) were additionally
re-verified inside Lean by the Möbius identity that the formal proof cancels.

## 1. Heights `A(n) = max_k |a_k(Φ_n)|` for `n ≤ 400`

Orders with `A(n) > 1`:

| n | A(n) | odd prime divisors |
|---|------|--------------------|
| 105 | 2 | 3, 5, 7 |
| 165 | 2 | 3, 5, 11 |
| 195 | 2 | 3, 5, 13 |
| 210 | 2 | 3, 5, 7 |
| 255 | 2 | 3, 5, 17 |
| 273 | 2 | 3, 7, 13 |
| 285 | 2 | 3, 5, 19 |
| 315 | 2 | 3, 5, 7 |
| 330 | 2 | 3, 5, 11 |
| 345 | 2 | 3, 5, 23 |
| 357 | 2 | 3, 7, 17 |
| 385 | 3 | 5, 7, 11 |
| 390 | 2 | 3, 5, 13 |

Observations that became theorems:

* `max { A(n) : n ≤ 400, n has ≤ 2 odd prime divisors } = 1`
  → proved in general: `PMFrameFlat.flatFrame_of_card_odd_primeFactors_le_two`.
* `A(105) = A(210) = A(420) = 2` and `A(105) = A(315) = 2`
  → proved in general: heights depend only on the odd radical
  (`PMFrameHeight.frameBoundedBy_iff_oddRad`), and the whole family `2^a 3^b 5^c 7^d` has height
  exactly `2` (`PMFrameHeight.isLeast_height_family`).
* `385 = 5·7·11` has height `3` — consistent with Bang's bound `A(pqr) ≤ p − 1 = 4`, and showing
  that height `2` is *not* the universal ternary ceiling.
  → proved: `PMFrame385.isLeast_height_pmFrame_385` (height exactly `3`) and
  `PMFrame385.isLeast_height_family_385` (the whole family `2^a 5^b 7^c 11^d`).

## 2. Counterexample hunt for the converse

Is `A(n) = 1` *equivalent* to "the odd part of `n` has at most two prime divisors"?  **No.**
The first counterexamples with three odd prime divisors and height `1` are

```
n = 231 = 3 · 7 · 11 ,   n = 399 = 3 · 7 · 19 .
```

This is why the Lean development states the classification as a one-way implication and adds the
flat ternary example `PMFrame231.flat_not_characterised_by_two_odd_primes`.

## 3. The two explicit polynomials

`Φ₁₀₅` (degree 48, coefficients indexed `0 … 48`):

```
1, 1, 1, 0, 0, -1, -1, -2, -1, -1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, -1, 0, -1, 0, -1, 0, -1, 0,
-1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, -1, -1, -2, -1, -1, 0, 0, 1, 1, 1
```

Height `2`, attained exactly at `X^7` and `X^41` (palindromic).  Verified in Lean:
`PMFrame105.pmFrame_105_eq`, `PMFrame105.isLeast_height_pmFrame_105`.

`Φ₂₃₁` (degree 120) is flat; its coefficient list is `PMFrame231.c231`, and the Lean proof
`PMFrame231.pmFrame_231_eq` certifies it via the same Möbius cancellation.

`Φ₃₈₅` (degree 240) has height `3`; its coefficient list is `PMFrame385.c385`, and the Lean proof
`PMFrame385.pmFrame_385_eq` certifies it by cancelling
`Φ₃₈₅ · (X−1)(X³⁵−1)(X⁵⁵−1)(X⁷⁷−1) = (X⁵−1)(X⁷−1)(X¹¹−1)(X³⁸⁵−1)`.
The extreme value `−3` occurs exactly three times in a row, at `X¹¹⁹`, `X¹²⁰`, `X¹²¹` (the middle
of the palindrome), so no truncated low-degree recursion can reach it — the full polynomial is
needed.  Together with `Φ₂₃₁` (height `1`) and `Φ₁₀₅` (height `2`) this gives three ternary orders
of three different heights: `PMFrameSpectrum.ternary_height_trichotomy`.

## 4. Low-order recursion used in the `Φ₁₀₅` proof

From `Φ₁₀₅ · (X−1) ≡ (1−X³)(1−X⁵)(1−X⁷) (mod X¹⁵)` one gets `c_k − c_{k+1} = w_{k+1}` with
`w = (−1, 0, 0, 1, 0, 1, 0, 1, …)`, hence

```
c₀ … c₇  =  1, 1, 1, 0, 0, −1, −1, −2 .
```

This is exactly the chain formalised in `PMFrameTernary.coeff_pmFrame_105_initial`, and it is where
the value `−2` — the first failure of flatness — appears.

## 5. OEIS

The coefficient sequence of `Φ₁₀₅` and the sequence of heights `A(n)` are catalogued in OEIS
(heights of cyclotomic polynomials); no new sequence is claimed here.
