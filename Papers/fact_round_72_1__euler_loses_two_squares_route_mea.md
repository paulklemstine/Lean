# Computational evidence — Euler's two-squares factorisation route

All numbers below were produced by a short exhaustive search (odd primes `3 ≤ p < q < 200`,
representations found by scanning `a` with `2a² ≤ n` and testing whether `n − a²` is a
square). They motivated — and are now *superseded by* — the Lean theorems in
`Catalog/Algebra/EulerTwoSquares{Core,Count,Cost}.lean`, which prove the general statements.

## 1. Small cases: how many essentially distinct representations does `n = p·q` have?

Representations are counted up to order (`0 < a ≤ b`, `a² + b² = n`).

| class of `(p mod 4, q mod 4)` | pairs tested | number of representations |
|---|---|---|
| `(1,1)` | 210 | **always exactly 2** |
| `(1,3)` | 240 | always 0 |
| `(3,1)` | 264 | always 0 |
| `(3,3)` | 276 | always 0 |
| `2·q`, `q ≡ 1 (4)` | all `q < 200` | always 1 |
| `2·q`, `q ≡ 3 (4)` | all `q < 200` | always 0 |
| `p²`, `p ≡ 1 (4)` | all `p < 200` | always 1 |

So among semiprimes with both factors odd, exactly the `(1,1)` cell is *eligible* for Euler's
method — one cell out of four, matching the reported eligible fraction `0.2500`.

Formalised as: `EulerTwoSquares.exactly_two_reps` (the `(1,1)` cell, exactly two) and
`EulerTwoSquares.euler_works_iff_both_one_mod_four` (the dichotomy for distinct odd primes),
with `EulerTwoSquares.no_rep_of_three_mod_four` covering the empty cells.

## 2. Does the extraction step always work?

For every `(1,1)` pair (`210` instances) with representations `(a,b)`, `(c,d)`:

```
gcd(|a·d − b·c|, p·q) ∈ {p, q}      210/210, no failures
gcd(|a·d − b·c|, N) · gcd(a·d + b·c, N) = N   (checked on the same sample)
```

Example: `N = 65 = 1² + 8² = 4² + 7²`, `ad − bc = 1·7 − 8·4 = −25`, `gcd(25,65) = 5`;
`ad + bc = 39`, `gcd(39,65) = 13`; `5 · 13 = 65`.

Formalised — and proved unconditionally, for *any* `N` with two essentially distinct
positive representations — as `EulerTwoSquares.euler_gcd_proper`
(`1 < gcd(ad−bc, N) < N`), `EulerTwoSquares.euler_extraction_semiprime` and
`EulerTwoSquares.euler_gcd_pair_factors`.

## 3. Counterexample hunt

* Sought a `(1,1)` semiprime with `≠ 2` representations: none in `210` instances (now proved
  impossible).
* Sought a pair of essentially distinct representations whose gcd is trivial (`1` or `N`):
  none (now proved impossible, with no primality hypothesis).
* Sought a representation of `p·q` with a factor `≡ 3 (mod 4)`: none (now proved impossible).
* Checked whether the extraction survives a zero part, e.g. `25 = 5² + 0² = 3² + 4²`:
  `gcd(5·4 − 0·3, 25) = 5`, still a proper divisor. Swept every `N < 3000` and every pair of
  essentially distinct **non-negative** representations: 0 counterexamples. This is now proved
  in Lean as `EulerTwoSquares.euler_gcd_proper_nonneg`.

## 4. Cost face

For `N = p·q` the Fermat scan starts at `⌈√N⌉` and stops at `(p+q)/2`. Sample of the excess
`(p+q)/2 − √(pq)` versus the proved bound `(q−p)²/(8√(pq))`:

| `p` | `q` | excess `(p+q)/2 − √(pq)` | upper bound `(q−p)²/(8√(pq))` | lower bound `(q−p)²/(8·max p q)` |
|---|---|---|---|---|
| 13 | 17 | 0.134 | 0.135 | 0.118 |
| 5 | 101 | 30.528 | 51.263 | 11.406 |
| 3 | 997 | 445.310 | 2258.263 | 123.876 |

The two proved inequalities `EulerTwoSquares.fermat_excess_le` and
`EulerTwoSquares.fermat_excess_ge` bracket the excess by `Θ((q−p)²/√N)` (respectively
`(q−p)²/(8 max p q)`), and `EulerTwoSquares.fermat_halts_immediately_iff` gives the exact
discrete criterion `(q−p)² < 4(p+q)` for the scan to succeed on its very first trial — the
"Fermat lands instantly on balanced pairs" phenomenon, now an exact statement rather than an
empirical observation. Note only the Lean statements are verified; the table above is
ordinary floating-point arithmetic and is reported as motivation, not as a verified result.

## 5. Which prime does the extraction return?

For `p = e²+f²`, `q = g²+h²` and the Brahmagupta parts `A = eg+fh`, `B = eh−fg`,
`C = eg−fh`, `D = eh+fg`, the signed cross terms were *never* composite and never trivial:

| `p` | `q` | `(e,f)` | `(g,h)` | `A·D − B·C` | `gcd(·, N)` | `A·D + B·C` | `gcd(·, N)` |
|---|---|---|---|---|---|---|---|
| 5 | 13 | (1,2) | (2,3) | `52 = 2·2·13` | 13 | `60 = 2·6·5` | 5 |
| 5 | 17 | (1,2) | (1,4) | `68 = 2·2·17` | 17 | `40 = 2·4·5` | 5 |
| 13 | 17 | (2,3) | (1,4) | `204 = 2·6·17` | 17 | `104 = 2·4·13` | 13 |

The pattern `A·D − B·C = 2·e·f·q` and `A·D + B·C = 2·g·h·p` held on every instance and is now
an exact `ring` identity in Lean (`EulerTwoSquares.cross_sub_factors`,
`EulerTwoSquares.cross_add_factors`), with the gcd consequences
`EulerTwoSquares.gcd_cross_sub_eq_q` and `EulerTwoSquares.gcd_cross_add_eq_p`.

## 6. How deep must a representation search go?

For all `666` eligible semiprimes `N = p·q` with `p < q < 400`, both `≡ 1 (mod 4)`, let `t` be
the larger of the two smaller parts (the depth at which an ascending scan has seen *both*
representations). The measured ratio `t / (2N)^{1/4}` never dropped below `1.1846`
(attained at `N = 65`, reps `(1,8)` and `(4,7)`, `t = 4`).

The strict inequality `t⁴ > 2N` is now a theorem — `EulerTwoSquares.euler_scan_quartic_bound`
— proved for *any* `N` with two essentially distinct representations, no primality needed.
The floating-point ratios above are motivation only; the inequality itself is the verified
statement.
