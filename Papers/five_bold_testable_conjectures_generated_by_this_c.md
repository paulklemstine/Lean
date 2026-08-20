# Computational evidence — layer 4 of the Mordell denominator tower

All data below were produced by exhaustive enumeration (exact integer / rational arithmetic)
*before* the Lean formalisation, and every claim they support is now a theorem in
`Catalog/NumberTheory/MordellDenominatorQuartic.lean`,
`Catalog/NumberTheory/MordellQuarticClassCount.lean` and
`Catalog/NumberTheory/MordellQuarticBarrier.lean`.  The formal statements checked inside Lean
by decision procedure are `MordellQuarticCount.layer4_totals_7_13_19` and
`MordellQuartic.quartic_denominator_primes_55`; the exploratory tables in this file are *not*
themselves machine-checked and are recorded only as the evidence that motivated the theorems.

## 1. The layer-4 criterion against real orbits

For `E_N : y² = x³ + N` and an integral point `P = (x, y)` we computed `4P` with exact rational
arithmetic and factored the denominator of `x(4P)`, comparing it with the factorisation of

`Ψ₄(N, x) = (x³ + N)(x⁶ + 20Nx³ - 8N²)`.

| `N` | `P` | primes of `den x(4P)` | primes of `Ψ₄(N,x)` |
|---|---|---|---|
| 55 | (9, 28) | 2, 7, 827, 1583 | 2, 7, 827, 1583 |
| 17 | (-2, 3) | 23 | 2, 3, 23 |
| -2 | (3, 5) | 2, 5, 383 | 5, 383 |
| 1 | (2, 3) | — | 2, 3 |
| 24 | (-2, 4) | 2, 131 | 2, 131 |

The two lists agree for **every prime ≥ 5** (the primes 2 and 3 are exactly the ones excluded by
the hypothesis `ℓ ≥ 5`).  This is `MordellQuartic.dvd_den_quadruple_point_iff`.

## 2. Layer-4 residue-class totals `∑_{c mod ℓ} #V₄(c)`

`V₄(c) = { x mod ℓ : ℓ ∣ (x³ + c)(x⁶ + 20cx³ - 8c²) }`.

| `ℓ` | `ℓ mod 12` | `∑_c #V₄(c)` | is `3` a square mod `ℓ`? | `3ℓ - 2` |
|---|---|---|---|---|
| 5 | 5 | 5 | no | 13 |
| 7 | 7 | 7 | no | 19 |
| 11 | 11 | 31 | yes | 31 |
| 13 | 1 | 37 | yes | 37 |
| 17 | 5 | 17 | no | 49 |
| 19 | 7 | 19 | no | 55 |
| 23 | 11 | 67 | yes | 67 |
| 29 | 5 | 29 | no | 85 |
| 31 | 7 | 31 | no | 91 |
| 37 | 1 | 109 | yes | 109 |
| 41 | 5 | 41 | no | 121 |
| 43 | 7 | 43 | no | 127 |

So the total is `3ℓ - 2` exactly when `3` is a quadratic residue (`ℓ ≡ ±1 mod 12`) and `ℓ`
otherwise.  Conjecture **D1** of the previous cycle predicted a single slope
`k = #{irreducible factors of ψ₄} = 2` with bounded error; the data show two slopes, `1` and
`3`.  Formalised as `sum_card_V4_of_isSquare_three`, `sum_card_V4_of_not_isSquare_three` and
`layer4_total_not_linear`.

The mean of the two values over the two (equidistributed) classes is `2ℓ - 1`, i.e. D1's
prediction holds *on average* — which is why the extrapolation looked plausible.

## 3. Active residues: layer 4 versus layer 2

`act_n(ℓ) = #{ c mod ℓ : V_n(c) ≠ ∅ }`.

| `ℓ` | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 | 61 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `act₂` | 5 | 3 | 11 | 5 | 17 | 7 | 23 | 29 | 11 | 13 | 41 | 15 | 47 | 53 | 59 | 21 |
| `act₄` | 5 | 3 | 11 | 5 | 17 | 7 | 23 | 29 | 11 | 13 | 41 | 15 | 47 | 53 | 59 | 21 |

They coincide in every case (checked exhaustively for all `c` and all `ℓ ≤ 43`).  This suggested
— and we then proved — that a root of the *new* sextic factor always produces a cube root of
`-c`, via the identity `-(5 + 3√3)/4 = ((-1-√3)/2)³` in `ℚ(√3)`
(`MordellQuarticCount.V4_nonempty_iff_V2_nonempty`).

## 4. Counterexample hunt

* Against C1 ("the exceptional constants at every layer are `{2,3}`-units"): we evaluated
  `φ₄` on both branches of `Ψ₄ = 0` symbolically.  The values are `3⁸N⁴x⁴` and
  `-2⁶3²N(x⁴-8Nx)(x³+N)³`; no prime `≥ 5` occurs.  No counterexample; C1's constant claim is
  now a theorem at `n = 4` (`not_dvd_phi4_of_dvd_Psi4`).
* Against C3 ("the criterion depends on `N` only mod `ℓ`"): `Ψ₄` is a polynomial in `N` with
  integer coefficients, so no dependence through `gcd(N, ℓ^k)` can appear.  No counterexample;
  proved at `n = 4` (`MordellQuarticBarrier.denominator_data_barrier_layer234`).
* Against D1: found, see §2.

## 5. OEIS

The sequence of layer-4 totals over primes `5, 7, 11, 13, …` is `5, 7, 31, 37, 17, 19, 67, …`;
it is the interleaving of `ℓ` and `3ℓ - 2` along the splitting of `ℓ` in `ℚ(√3)` and was not
matched to a catalogued sequence.  The auxiliary sequence of blind-residue counts
`2(ℓ-1)/3` at ordinary primes is elementary.
