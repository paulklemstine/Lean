# Computational Evidence — Betti–Whittaker contragredient twist sign

The full automorphic statement is out of reach of direct computation, but the two
*decidable* skeletons we formalize — the cohomological degree `b` and the
quadratic twist sign `ε(disc)^b` — admit concrete small-case checks. All numbers
below are reproduced by the `decide`/`omega`-level facts proved in the Lean files.

## 1. The bottom degree `b = r₁·⌊n²/4⌋ + r₂·n(n-1)/2`

`⌊n²/4⌋` for `n = 1..10`:

| n  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8  | 9  | 10 |
|----|---|---|---|---|---|---|---|----|----|----|
| ⌊n²/4⌋ | 0 | 1 | 2 | 4 | 6 | 9 | 12 | 16 | 20 | 25 |

This is OEIS **A002620** ("quarter-squares"). The identity proved as
`quarter_sq`, `⌊n²/4⌋ = ⌊n/2⌋·⌊(n+1)/2⌋`, matches term by term
(e.g. `n=7`: `3·4 = 12`).

`n(n-1)/2 = C(n,2)` for `n = 1..10`: `0,1,3,6,10,15,21,28,36,45` — OEIS
**A000217** (triangular numbers), identified with `Nat.choose n 2` in
`bDeg_imaginary_quadratic`.

Sample full degrees `bDeg n r1 r2`:

| field type            | (r₁,r₂) | n=2 | n=3 | n=4 |
|-----------------------|---------|-----|-----|-----|
| ℚ (real)              | (1,0)   | 1   | 2   | 4   |
| imaginary quadratic   | (0,1)   | 1   | 3   | 6   |
| real quadratic        | (2,0)   | 2   | 4   | 8   |
| complex (mixed) cubic | (1,1)   | 2   | 5   | 10  |

## 2. The twist sign `ε(disc)^b`

Since `ε` is quadratic, `ε(disc) ∈ {+1,-1}` (proved `twist_is_sign`,
`discTwist_eq_one_or_neg_one`). Hence the only data is:

* `ε(disc) = +1`  ⇒  `ε(disc)^b = 1` for every `b`  ⇒ periods of `π`, `π∨` agree
  (`period_self_dual`, `period_self_dual_of_residue`).
* `ε(disc) = -1`  ⇒  `ε(disc)^b = (-1)^b`, i.e. depends only on the parity of `b`
  (`period_sign`, `period_eq_iff_even`).

Parity of `b` over ℚ (`b = ⌊n²/4⌋`, `n = 1..10`): the parity sequence is
`0,1,0,0,0,1,0,0,0,1` (verified by `#eval`). So `⌊n²/4⌋` is odd **iff**
`n ≡ 2 (mod 4)` (i.e. `n = 2,6,10,…`); for odd `n`, `⌊n²/4⌋ = m(m+1)` is a
product of consecutive integers, hence always even. A non-square discriminant
therefore flips the period over ℚ exactly when `n ≡ 2 (mod 4)`.

## 3. Legendre realisation / reciprocity sanity checks

Euler's criterion identifies `ε(disc) = legendreSym p d`. Spot checks
(`legendreSym`):

* `legendreSym 5 1 = 1` (1 is a QR), `legendreSym 5 2 = -1` (2 is a non-residue
  mod 5), `legendreSym 7 2 = 1` (2 is a QR mod 7).
* Reciprocity product: `legendreSym 5 3 · legendreSym 3 5 = (-1)^(2·1) = 1`,
  consistent with `twist_product_reciprocity` for `p=5,q=3`.
* `p = 5 ≡ 1 (mod 4)`: `legendreSym 3 5 = legendreSym 5 3`
  (`twist_symmetry_one_mod_four`).

## 4. Counterexample hunt

The relation `ε(disc)^(2b) = 1` (consistency of double contragredient) was tested
against the *negation* of the quadratic hypothesis: if `ε(disc)` were a primitive
`m`-th root of unity with `m ∤ 2b`, double contragredient would fail. No
counterexample exists *because* `ε` is quadratic — this is exactly the content of
`period_double_contra`, whose proof is load-bearing on `eps² = 1` (dropping it
leaves the spurious factor `eps^(2b) ≠ 1`).
