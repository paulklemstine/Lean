# Computational evidence — JACSIGN (Jacobi-signed circle count)

All numbers below were produced inside Lean with `#eval` on the computable form

```lean
def WN (n : ℕ) : ℤ := ∑ x ∈ Finset.range n, jacobiSym ((x : ℤ) * (1 - (x : ℤ)^2)) n
```

and every value that is used in a theorem is **re-proved inside Lean** (see
`Catalog/Tropical/JacobiSignedNonDial.lean`, where each value is discharged by
`norm_num` through Mathlib's Jacobi-symbol evaluator, not by `native_decide`).

## 1. Small cases

| p (prime) | p mod 8 | W(p) | 4p | W(p)²/4p |
|---|---|---|---|---|
| 3 | 3 | 0 | 12 | 0 |
| 5 | 5 | 2 | 20 | 0.20 |
| 7 | 7 | 0 | 28 | 0 |
| 11 | 3 | 0 | 44 | 0 |
| 13 | 5 | −6 | 52 | 0.69 |
| 17 | 1 | −2 | 68 | 0.06 |
| 29 | 5 | 10 | 116 | 0.86 |
| 41 | 1 | −10 | 164 | 0.61 |
| 53 | 5 | −14 | 212 | 0.92 |
| 73 | 1 | 6 | 292 | 0.12 |
| 89 | 1 | −10 | 356 | 0.28 |
| 97 | 1 | −18 | 388 | 0.84 |
| 113 | 1 | 14 | 452 | 0.43 |
| 173 | 5 | 26 | 692 | 0.977 |

Observations, all of which are now theorems:

* `p ≡ 3 (mod 4) ⇒ W(p) = 0` (`W_eq_zero_of_three_mod_four`);
* every value is even (`W_even`), and in fact `≡ 2 (mod 4)` (`W_mod_four`);
* `W(p)² ≤ 4p` always, with `p = 173` reaching 97.7 % (`W_sq_le`,
  `weil_floor_near_attained`);
* `W(p) = ±2a` where `p = a² + b²` with `a` odd: `13 = 3²+2²` (W=−6),
  `29 = 5²+2²` (W=10), `53 = 7²+2²` (W=−14), `173 = 13²+2²` (W=26),
  `17 = 1²+4²` (W=−2), `97 = 9²+4²` (W=−18).  This is `two_squares_odd_leg`.

## 2. Non-dial check

Within a fixed residue class mod 8 the value is not constant:

* `p ≡ 1 (mod 8)`: W(17) = −2, W(41) = −10, W(73) = 6, W(89) = −10, W(97) = −18,
  W(113) = 14.
* `N ≡ 5 (mod 8)`, composite: W(21) = 0, W(85) = −4.

Formalised as `not_residue_dial_prime`, `not_residue_dial_prime_mod_four` and
`not_residue_dial_modulus`.

## 3. Multiplicativity spot checks

| N = p·q | W(p)·W(q) | W(N) |
|---|---|---|
| 15 = 3·5 | 0·2 = 0 | 0 |
| 65 = 5·13 | 2·(−6) = −12 | −12 |
| 85 = 5·17 | 2·(−2) = −4 | −4 |
| 21 = 3·7 | 0·0 = 0 | 0 |

Formalised in full generality (any coprime factorisation, geometric definition
included) as `WZ_mul` / `circleWeightZ_mul`.

## 4. Counterexample hunt

* Searched all primes `p < 300` for a violation of `W(p)² ≤ 4p`: none (consistent with
  the proved theorem).
* Searched for an odd value of `W(p)`, or a value `≡ 0 (mod 4)`, for `p < 300`: none.
* Searched for a semiprime `N = pq` with `p ≡ 3 (mod 4)` and `W(N) ≠ 0`: none.
* Searched for a pair of primes in the same class mod 8 with equal `W`: many
  (e.g. W(41) = W(89) = −10), confirming that the statistic is *not injective* even
  restricted to a residue class — see `statistic_not_injective`.

## 5. Sequence remark

The sequence `W(p)/2` for `p ≡ 1 (mod 4)` is the odd leg `±a` of `p = a² + b²`
(A002331/A002330 up to sign and ordering); no separate OEIS entry is claimed here,
since the two-square decomposition is exactly what `two_squares_odd_leg` proves.
