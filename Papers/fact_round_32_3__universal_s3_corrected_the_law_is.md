# Computational Evidence — UNIVERSAL-S3-CORRECTED (paper 112)

## 1. Small-case table (exploratory `#eval`, not a proof)

Root counts `N(f, p) = #{x ∈ 𝔽_p : f(x) = 0}` for primes `5 ≤ p < 110`, computed with an
exploratory Lean `#eval` (list enumeration).  `sq(-31)` records whether `-31` is a square mod `p`.

| p | p mod 3 | N(x³−2) | p mod 31 | N(x³+x+1) | sq(−31) |
|---|---|---|---|---|---|
| 5 | 2 | 1 | 5 | 0 | yes |
| 7 | 1 | 0 | 7 | 0 | yes |
| 11 | 2 | 1 | 11 | 1 | no |
| 13 | 1 | 0 | 13 | 1 | no |
| 17 | 2 | 1 | 17 | 1 | no |
| 19 | 1 | 0 | 19 | 0 | yes |
| 23 | 2 | 1 | 23 | 1 | no |
| 29 | 2 | 1 | 29 | 1 | no |
| 31 | 1 | 3 | 0 | 2 (ramified) | yes |
| 37 | 1 | 0 | 6 | 1 | no |
| 41 | 2 | 1 | 10 | 0 | yes |
| 43 | 1 | 3 | 12 | 1 | no |
| 47 | 2 | 1 | 16 | 3 | yes |
| 53 | 2 | 1 | 22 | 1 | no |
| 59 | 2 | 1 | 28 | 0 | yes |
| 61 | 1 | 0 | 30 | 1 | no |
| 67 | 1 | 0 | 5 | 3 | yes |
| 71 | 2 | 1 | 9 | 0 | yes |
| 73 | 1 | 0 | 11 | 1 | no |
| 79 | 1 | 0 | 17 | 1 | no |
| 83 | 2 | 1 | 21 | 1 | no |
| 89 | 2 | 1 | 27 | 1 | no |
| 97 | 1 | 0 | 4 | 0 | yes |
| 101 | 2 | 1 | 8 | 0 | yes |
| 103 | 1 | 0 | 10 | 0 | yes |
| 107 | 2 | 1 | 14 | 0 | yes |
| 109 | 1 | 3 | 16 | 0 | yes |

Observations (then proved in Lean for **all** primes, see below):

* `N(x³−2, p) = 1` exactly when `p ≡ 2 (mod 3)`; otherwise `N ∈ {0, 3}`.
* `N(x³+x+1, p) = 1` exactly when `-31` is a non-square mod `p` (`p ≠ 2, 31`).
* `p mod 3` does **not** determine `N(x³+x+1, p) = 1`: e.g. `p = 5, 11` (both `≡ 2`).

## 2. What was turned into proofs

| Observation | Lean theorem | Status |
|---|---|---|
| `N(x³−2,p)=1 ↔ p≡2 (3)`, all primes `p>3` | `PureCubicSignConductor.card_cube_two_eq_one_iff` | proved |
| `-3` square mod `p` ↔ `p≡1 (3)` (via the cubic) | `PureCubicSignConductor.isSquare_neg_three_iff` | proved |
| Stickelberger sign law for cubics over `𝔽_p` | `CubicStickelbergerFrobenius.sign_law_Fp` | proved |
| `N(x³+x+1,p)=1 ↔ (p/31) = −1` | `TrinomialConductor31.trinomial_one_root_iff_legendre` | proved |
| `5, 11` separate conductor 3 from 31 | `TrinomialConductor31.conductor_separation` | proved |
| group-level 1-bit law for every surjection `G → ±1` | `S3SignChannelUniversal.sign_channel_universal` | proved |

## 3. OEIS

Primes with `x³−2` having exactly one root mod `p` are the primes `≡ 2 (mod 3)` (OEIS A003627);
primes at which `x³+x+1` splits completely begin `47, 67, …` (in agreement with the table).
These identifications are quoted from memory and were not re-checked online.

## 4. Counterexample hunt

The claim "the sign bit is a function of `p mod 3` for every S₃ field" was tested on the
table: it **fails** for `x³+x+1` (p = 5 vs 11; also 41, 47, 59 vs 17, 23, 29).  This is proved
formally (`PureCubicSignConductor.trinomial_sign_not_mod_three`,
`TrinomialConductor31.conductor_separation`).  The universal claim survives only at the level of
the group `S₃` (channel shape), not at the level of the conductor.
