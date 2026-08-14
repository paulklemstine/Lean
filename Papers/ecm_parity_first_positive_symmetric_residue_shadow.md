# Computational evidence — ECM-PARITY (experiment 404 follow-up)

All statements below were first explored numerically and then either **proved in
Lean** (marked ✅, see `Catalog/Algebra/ECMParity*.lean`) or left as an
observation.  Exploratory counts were produced by a short sieve script over the
curve `E₀ : y² = x³ + x + 1`, using

`#E₀(𝔽_p) = 1 + Σ_x #{y : y² = x³+x+1}`.

Two of the numerical facts are additionally **machine-checked inside Lean** by
`decide` (kernel computation, not floating point):

* `ECMParity.rootSet_23 : rootSet (1 : ZMod 23) 1 = {4}` ✅
* `ECMParity.curveCard_23 : curveCard (1 : ZMod 23) 1 = 28` ✅

## 1. Root-count (Frobenius cycle type) census, `3 ≤ p < 4000`, `p ≠ 31`

| roots of `x³+x+1` mod p | Frobenius class | #primes | share |
|---|---|---|---|
| 0 | 3-cycle | 186 | 0.406 |
| 1 | transposition | 276 | 0.402 (of the odd-`r` mass) |
| 3 | identity | 86 | — |

Observed `P(2 ∣ #E₀) = (276+86)/548 = 0.661`, consistent with the Chebotarev
value `2/3` quoted in the experiment (`0.6493`).

* Every `r = 0` prime had **odd** `#E₀` — ✅ proved
  (`curveCard_odd_iff_no_root`).
* Every `r ∈ {1,3}` prime had **even** `#E₀` — ✅ proved
  (`two_dvd_curveCard_iff`).

## 2. The mod-4 face

| face | claim in the experiment | numerical result | status |
|---|---|---|---|
| `[1,1,1]` (`r=3`) | `4 ∣ #E` always | 126/126 primes `< 6000` ✔ | ✅ proved (`four_dvd_curveCard_of_three_roots`) |
| `[3]` (`r=0`) | `4 ∤ #E` | `#E` odd on all 186 primes ✔ | ✅ proved |
| `[1]` (`r=1`) | `#E ≡ 2 (mod 4)` | **FALSE**: 135 of 276 primes `< 4000` have `4 ∣ #E` | ✅ **refuted**, corrected law proved |

Smallest counterexamples on the transposition face (`p`, `#E₀`, unique root `a`,
`k = 3a²+1 mod p`):

```
(3, 4, 1, 1)    (23, 28, 4, 3)    (29, 36, 26, 28)   (37, 48, 25, 26)
(73, 72, 23, 55)  (89, 100, 14, 55)  (167, 144, 23, 85)  (179, 180, 149, 16)
```

In **every** counterexample `k = 3a² + 1` is a quadratic residue.  The refined
criterion

> on the transposition face, `#E ≡ 2 (mod 4)` **iff** `3a² + A` is a non-square,

was checked on all 389 transposition primes `p < 6000` (no exception) and is
✅ proved in full generality as
`ECMParity.curveCard_mod_four_of_unique_root`.

The Lean-internal check `curveCard (1 : ZMod 23) 1 = 28` with
`rootSet (1 : ZMod 23) 1 = {4}` is the kernel-verified counterexample.

## 3. Discriminant / Frobenius parity law (Stickelberger)

For all 781 primes `p < 6000` with `p ∤ 2·31` (exhaustive check):

* `r = 1  ⟺  (-31 | p) = -1`  (checked on all such primes),
* `r ∈ {0,3} ⟺ (-31 | p) = +1`.

✅ proved as `ECMParity.disc_not_isSquare_iff_card_eq_one` (the `r = 0 ⇒ Δ`
square direction is the substantial one and is proved via Frobenius invariance
of the root-difference product in `𝔽_{p³}`).

## 4. Residue dial and the symmetric shadow

`(-31|p) = (p mod 31 | 31)` was verified for all odd `p < 6000`, `p ≠ 31`
(✅ proved: `ECMParity.legendreSym_neg_of_three_mod_four`).  Consequently, for
semiprimes `N = pq` whose Jacobi symbol `(N|31) = -1`, the order of `E₀` was
even at one of the factors in 1499/1499 sampled semiprime pairs with `(N|31) = -1` — ✅ proved exactly
(`ECMParity.or_two_dvd_E0Card_of_jacobi`), matching the reported
`P(OR | (Δ|N) = −1) = 1.0000`.

## 5. Class-field face

For primes with `4p = A² + 31B²` (sampled `p < 6000`), `#E₀ mod 4 ∈ {0,1,3}`,
never `2` — ✅ proved (`ECMParity.E0Card_mod_four_ne_two_of_form`); the proof
only uses the elementary half of the class-field dictionary (representability
forces `(-31|p) = 1`).

## OEIS

The primes on the `[1,1,1]` face of `x³+x+1` begin
`47, 67, 131, 149, 173, 227, 283, 293, 349, 379, 431, 521`
(the primes that split completely in the Hilbert class field of `ℚ(√-31)`).
No OEIS lookup was performed and no new OEIS entry is claimed.
