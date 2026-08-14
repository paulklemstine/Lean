# Computational evidence — CM-ECM-ORDER (Gaussian CM curve `E : y² = x³ + x`)

All exploratory numbers below were produced by a brute-force point count over
`𝔽_p` (`#E(𝔽_p) = 1 + #{(x,y) : y² = x³ + x}`) for the primes `3 ≤ p < 200`.
They are **exploratory**; the statements that are actually *verified* are the
Lean theorems in `Catalog/Novelty/CmEcmOrderShadow.lean` and
`Catalog/Novelty/CmEcmOrderTwists.lean`, which are listed at the end of this
file together with the exploratory observation each one settles.

## 1. Small-case table

| `p` | `p mod 4` | `#E(𝔽_p)` | `a_p = p+1-#E` | `#E mod 4` |
|----|----|----|----|----|
| 3  | 3 | 4  | 0   | 0 |
| 5  | 1 | 4  | 2   | 0 |
| 7  | 3 | 8  | 0   | 0 |
| 11 | 3 | 12 | 0   | 0 |
| 13 | 1 | 20 | −6  | 0 |
| 17 | 1 | 16 | 2   | 0 |
| 19 | 3 | 20 | 0   | 0 |
| 23 | 3 | 24 | 0   | 0 |
| 29 | 1 | 20 | 10  | 0 |
| 31 | 3 | 32 | 0   | 0 |
| 37 | 1 | 36 | 2   | 0 |
| 41 | 1 | 32 | 10  | 0 |
| 43 | 3 | 44 | 0   | 0 |
| 47 | 3 | 48 | 0   | 0 |
| 53 | 1 | 68 | −14 | 0 |
| 59 | 3 | 60 | 0   | 0 |
| 61 | 1 | 52 | 10  | 0 |
| 67 | 3 | 68 | 0   | 0 |
| 71 | 3 | 72 | 0   | 0 |
| 73 | 1 | 80 | −6  | 0 |

Observations over all primes `3 ≤ p < 200`:

* `a_p = 0` for **every** inert prime `p ≡ 3 (mod 4)` (no exception).
* `a_p ≠ 0` and `a_p ≡ 2 (mod 4)` for **every** split prime `p ≡ 1 (mod 4)`.
* `4 ∣ #E(𝔽_p)` for **every** odd prime in the range.
* On the split half `|a_p| = 2a` where `p = a² + b²` and `a` is the odd member of
  the Gauss representation (checked for all `p ≡ 1 (mod 4)` below 200).
* Quadratic twist: `#E(A=1) + #E(A=u²) = 2p + 2` for a non-residue `u`
  (checked for all primes below 60).

The sequence `#E(𝔽_p)` for `p = 3, 5, 7, 11, 13, …` is `4, 4, 8, 12, 20, 16, …`;
on the inert half it is literally `p + 1`, so no separate OEIS entry is involved
there. No OEIS lookup was performed for the split-half subsequence.

## 2. Counterexample hunt

* Universal claim `4 ∣ #E`: tested on all odd primes `< 200` — **no counterexample**
  (now a theorem, `four_dvd_cmCard`).
* Claim "`a_p = 0` only on the inert half": tested on all split primes `< 200` —
  **no counterexample** (now a theorem, `cmTrace_eq_zero_iff`).
* Claim "the divisibility `3 ∣ #E` is a congruence condition on `p`": **false on
  the split half**, and this is where the hunt bites.  Counts for `3 ≤ p < 200`:

  | half | `p mod 12` | `3 ∣ #E` false | `3 ∣ #E` true |
  |----|----|----|----|
  | inert | 3  | 1  | 0  |
  | inert | 7  | 12 | 0  |
  | inert | 11 | 0  | 11 |
  | split | 5  | 12 | 0  |
  | split | 1  | 7  | 2  |

  On the inert half the event is *exactly* `p ≡ 11 (mod 12)` — a congruence, i.e.
  the `p + 1` channel.  On the split half the event is not a congruence class
  (`p ≡ 1 (mod 12)` splits 7 : 2): that part is the GL₂-hidden Hecke term.

## 3. The which-factor collision

`77 = 7 · 11` and `209 = 11 · 19` satisfy `77 ≡ 209 ≡ 5 (mod 12)`.  Orders:
`#E(𝔽₇) = 8`, `#E(𝔽₁₁) = 12`, `#E(𝔽₁₉) = 20`.  Both semiprimes satisfy the
*symmetric* event "3 divides the order at some factor", but the least-factor bit
is `false` for `77` and `true` for `209`.  Hence no function of `N mod 12`
recovers the which-factor bit.  Similarly `133 = 7 · 19` and `253 = 11 · 23` are
both `≡ 1 (mod 12)` while the symmetric event is false for the first and true for
the second.

## 4. What is Lean-verified

| exploratory observation | verified theorem |
|----|----|
| `a_p = 0` on the inert half | `CmEcmOrder.cmCard_inert` |
| `a_p ≠ 0` on the split half | `CmEcmOrder.cmTrace_ne_zero_split`, `CmEcmOrder.cmTrace_eq_zero_iff` |
| `4 ∣ #E` for all odd `p` | `CmEcmOrder.four_dvd_cmCard` |
| `a_p ≡ 2 (mod 4)` on the split half (Gauss parameter odd) | `CmEcmOrder.cmTrace_split_mod_four` |
| the inert event is the congruence `p ≡ −1 (mod ℓ)` | `CmEcmOrder.cmCard_dvd_iff_mod`, `CmEcmOrder.cm_shadow_is_congruence` |
| `N ≡ 5 (mod 12)` forces the symmetric event | `CmEcmOrder.symmetric_shadow_live` |
| the `77` / `209` collision | `CmEcmOrder.which_factor_bit_invisible` |
| the `133` / `253` collision | `CmEcmOrder.symmetric_shadow_partial` |
| `#E = p + 1` for the whole family `y² = x³ + Ax` | `CmEcmOrder.supersingular_inert_family` |
| twist sums `2p + 2` | `CmEcmOrder.curveCard_twist_sum`, `CmEcmOrder.cm_twist_five` |
| `#E(𝔽₅) = 4`, twist `8` | `CmEcmOrder.split_breaks_plusOne_channel`, `CmEcmOrder.cm_twist_five` (`decide`) |

Not formalised (and explicitly *not* claimed): the split-half Gauss law
`|a_p| = 2a` with `p = a² + b²`, and any mutual-information estimate.

## 5. The Eisenstein mirror `y² = x³ + 1` (cycle 3)

Same brute-force count for the `j = 0` curve, primes `5 ≤ p < 200`:

| `p` | `p mod 3` | `#E` | `a_p` | `3 ∣ #E` |
|----|----|----|----|----|
| 5  | 2 | 6  | 0   | yes |
| 7  | 1 | 12 | −4  | yes |
| 11 | 2 | 12 | 0   | yes |
| 13 | 1 | 12 | 2   | yes |
| 17 | 2 | 18 | 0   | yes |
| 19 | 1 | 12 | 8   | yes |
| 23 | 2 | 24 | 0   | yes |
| 29 | 2 | 30 | 0   | yes |
| 31 | 1 | 36 | −4  | yes |
| 37 | 1 | 48 | −10 | yes |

* `a_p = 0` for **every** `p ≡ 2 (mod 3)` in the range, and `a_p ≠ 0` for every
  `p ≡ 1 (mod 3)` — verified as `CmEcmOrder.eisTrace_eq_zero_iff`.
* `3 ∣ #E` for every prime in the range; on the split half this is the content of
  `CmEcmOrder.three_dvd_eisCard` (on the inert half it is `3 ∣ p + 1`).
* `#E(y² = x³ + B) = p + 1` for **all** `B ≠ 0` and all `p ≡ 2 (mod 3)` below 40 —
  verified as `CmEcmOrder.supersingular_eisenstein_family`.
* Independence of the two dichotomies: `p = 5` (Gaussian ordinary, Eisenstein
  supersingular) versus `p = 7` (the reverse) — verified as
  `CmEcmOrder.cm_dichotomies_independent`.
