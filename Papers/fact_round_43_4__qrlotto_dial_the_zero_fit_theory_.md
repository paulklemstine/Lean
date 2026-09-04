# Computational evidence — QR lottery dial (Bridges, round-43 #4)

All numbers below were produced by `#eval` inside the Lean project (compiler evaluation of
the *same* definitions the theorems talk about: `QRLotto.rootCount`, `QRLotto.winners`).
They are exploratory checks, not proofs; the corresponding exact statements are proved in
`Catalog/Bridges/QRLottoDial.lean`, `QRLottoDialIndependence.lean` and
`QRLottoDialOptimality.lean`.

## 1. The lottery table at a single prime

`rootCount p N = #{x ∈ [0,p) : x² ≡ N (mod p)}` — the number of sieve positions mod `p`
hit by the prime `p` at target `N`.

```
p = 11, N = 0..11:   [1, 2, 0, 2, 2, 2, 0, 0, 0, 2, 0, 1]
```

Only the values `2` (residue), `0` (non-residue) and `1` (the ramified class `N ≡ 0`)
occur. This is exactly `QRLotto.rootCount_eq_two_or_zero` + `QRLotto.rootCount_zero`, and
its Legendre form `#roots = χ_p(N) + 1` is `QRLotto.rootCount_eq_legendreSym_add_one`.
The mean hit fraction is therefore `2/p` on residues and exactly `0` on non-residues —
the "lottery table" of the experimental note, with no fitted coefficient anywhere.

## 2. Fairness: number of winning classes vs `(p-1)/2`

`(p, #winners p, (p-1)/2)` for the odd primes below 40:

```
(3,1,1) (5,2,2) (7,3,3) (11,5,5) (13,6,6) (17,8,8) (19,9,9) (23,11,11) (29,14,14)
(31,15,15) (37,18,18)
```

Perfect agreement — proved in general as `QRLotto.card_winners` (`2W + 1 = p`).

## 3. Mean and variance of the dial

Factor base `FB = {3,5,7,11,13,17,19,23,29,31,37}` (odd primes ≤ 40),
`T(N) = ∑_{p ∈ FB, N QR mod p} 2/p`.

Theory (proved: `QRLotto.sum_dialOf`, `QRLotto.sum_sq_dialOf`):

* mean `= ∑_{p ∈ FB} 1/p   = 1.092724`
* variance `= ∑_{p ∈ FB} 1/p² = 0.196782`

Empirical, over the 903 integers `N ∈ [1,3000)` coprime to every `p ∈ FB`:

* sample mean     `= 1.087844`
* sample variance `= 0.193796`

The residual (≈ 0.5 %) is the expected boundary effect: `[1,3000)` is not a whole period
`∏ p ≈ 4.85 · 10¹¹` of the factor base, so the CRT classes are not perfectly balanced.
Over a full period the agreement is exact — that is the content of the two theorems.

Sample readings of the dial: `T(1009) = 1.4754`, `T(1013) = 0.5279`, `T(2011) = 1.7933`.
Spread of readings across `N` is the `2^k`-point spectrum of
`QRLotto.exists_prescribed_bits`.

## 4. Counterexample hunt

* Searched for an odd prime `p ≤ 400` and an `N` with `rootCount p N ∉ {0,1,2}`: none
  (impossible by `rootCount_eq_two_or_zero`).
* Searched for an odd prime `p ≤ 40` whose winner count differs from `(p-1)/2`: none.
* For `N = 1009` the factor base `p ≤ 400` (77 odd primes) yields 36 winning primes,
  consistent with the fair-coin prediction `77/2 = 38.5 ± 4.4`.

No counterexample to any statement subsequently formalised was found.

## 5. OEIS

The winner counts `(p-1)/2` for odd primes are A005097 (odd primes minus one, halved);
the per-prime hit counts `χ_p(N)+1` are the standard Legendre-symbol shift. No new
sequence arises, which is itself evidence that the dial is a first-principles object
rather than a fitted one.

## Addendum: the exponential tail versus the Chebyshev tail

The two proved concentration bounds on the deviating fraction of residue classes are
`1/(2t²)` (Chebyshev, `QRLotto.dial_deviation_uniform`) and `2 exp(−t²)` (Hoeffding,
`QRLotto.dial_tail_uniform`). The crossover comparison at `t = 2` — `2 e^{−4} < 1/8` — is
not left to numerics: it is proved in Lean as `QRLotto.chernoff_beats_chebyshev`, so the
claim that the exponential bound is the stronger statement there is machine-checked rather
than merely computed.
