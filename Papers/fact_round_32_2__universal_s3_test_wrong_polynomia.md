# Computational Evidence — UNIVERSAL-S3-TEST (paper 111)

Scope: the round-32 S₃ test measured `x⁵ − 2` (Galois group F₂₀ = AGL(1,5)) where it meant to
measure `x³ − 2` (Galois group S₃ ≅ AGL(1,3)). What follows is exploratory data, computed by
brute-force enumeration of residues. It motivated the Lean theorems but is **not** itself a
formal verification, except for the rows marked "(Lean)", which are proved in
`Catalog/Pythagorean/UniversalS3RootCount.lean` / `UniversalS3AffineMoments.lean`.

## 1. Root counts at the six dial moduli

| modulus | #roots x³−2 | #roots x⁵−2 | comment |
|---|---|---|---|
| 5  | 1 | 1 | x⁵−2 ≡ (x−2)⁵ mod 5 (ramified) |
| 8  | 0 | 0 | not a field |
| 9  | 0 | 1 | not a field |
| 11 | 1 | 0 | 11 ≡ 2 (mod 3), 11 ≡ 1 (mod 5) |
| 23 | 1 | 1 | the two polynomials look the same here (Lean: `dial23_indistinguishable`) |
| 31 | 3 | 0 | the two polynomials are told apart here (Lean: `dial31_separates`) |

## 2. Root-count frequencies over the 75 primes 7 ≤ p < 400

| polynomial | 0 roots | 1 root | top letter | top value | Chebotarev prediction |
|---|---|---|---|---|---|
| x³−2 | 26 (.347) | 38 (.507) | 11 (.147) | 3 | 1/3, 1/2, 1/6 |
| x⁵−2 | 14 (.187) | 58 (.773) | 3 (.040) | 5 | 1/5, 3/4, 1/20 |

Moments of the root count (empirical over these primes vs. the exact group value):

| moment | x³−2 empirical | S₃ exact | x⁵−2 empirical | F₂₀ exact |
|---|---|---|---|---|
| 1 | 0.947 | 1 | 0.973 | 1 |
| 2 | 1.83  | 2 | 1.77  | 2 |
| 3 | 4.47  | 5 | 5.77  | 7 |

The exact group values come from the Lean law `affine_moment`: the normalised moments of
AGL(1,q) are 1, 2 and q+2.

## 3. Counterexample hunt / certificates

* No prime p < 400 gives x³−2 more than 3 roots (Lean: `rootSet_card_le`, which holds for every field).
* First primes where x⁵−2 has five roots: **151, 241, 251**. Roots mod 151: 22, 25, 49, 90, 116
  (Lean: `quintic_five_roots_151`, `wrong_polynomial_detected_151`).
* Mod 31, 2⁶ ≡ 2 ≢ 1, so 2 is not a fifth power (Lean: `quintic_no_root_31`). Cube roots of 2
  mod 31: 4, 7, 20 (Lean: `cubic_three_roots_31`).

No OEIS lookup was done: the sequence of primes where x⁵−2 splits completely (151, 241, 251, …)
was not checked against OEIS here.

## 4. Exploratory check for Future Direction 3 (τ(n) second moment; not verified)

Prime average of N_p(x^n − a)² over primes 11 ≤ p < 3000:

| n, a | empirical | τ(n) prediction |
|---|---|---|
| 3, 2 | 1.953 | 2 |
| 5, 2 | 1.638 | 2 |
| 4, 3 | 2.751 | 3 |
| 4, 2 | 2.817 | 3 |
| 6, 3 | 3.474 | 4 |
| 6, 2 | 3.737 | 4 |

The values move in the predicted direction, but they converge slowly: the 5-split primes are rare,
with density 1/20. This table does not decide the conjecture.
