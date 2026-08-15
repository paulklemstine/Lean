# Computational evidence — "only bad primes" thread, cycles 6–7

All statements marked **[Lean]** are machine-checked in
`Catalog/Novelty/MordellApparitionEffective.lean` and
`Catalog/Novelty/MordellApparitionDensity.lean` (no `sorry`).
The tables below are *exploratory* computations (exact rational / modular arithmetic run
outside Lean); they are **not** verified artifacts and are reported only as evidence that
motivated the theorems.

## 1. Denominators along the orbit of `P = (9,28)` on `E_55 : y² = x³ + 55`

`den x(nP)` factors as a perfect square (`e_n²`); the small-prime part is listed as `(p, v_p)`.

| n | digits of `den x(nP)` | primes `p < 50` in the denominator |
|---|---|---|
| 1 | 1 | — (x = 9 is an integer) |
| 2 | 4 | (2,6), (7,2) |
| 3 | 9 | (3,6), (13,2) |
| 4 | 17 | (2,8), (7,2) |
| 5 | 26 | (5,2) |
| 6 | 37 | (2,6), (3,6), (7,2), (13,2), (17,4) |
| 7 | 51 | (43,2) |
| 8 | 68 | (2,10), (7,2) |
| 9 | 86 | (3,8), (13,2), (19,2) |
| 10 | 107 | (2,6), (5,2), (7,2) |
| 11 | 129 | (11,2) |
| 12 | 154 | (2,8), (3,6), (7,2), (13,2), (17,4) |

Observations.

* `7` appears exactly at even `n`, `13` exactly at multiples of `3`, `17` at multiples of `6`.
  Both patterns are arithmetic progressions through `0` — the apparition law.
* `7 · 13 = 91` divides `den x(nP)` exactly when `6 ∣ n`, i.e. the joint locus is the
  progression with modulus `lcm(2,3)`. **[Lean]** `joint_apparition_91_55`.
* Good primes (`7, 13, 17, 19, 43, …`) dominate the small-prime part, while the "allowed"
  primes `5, 11` occur rarely — the conjecture's predicted support is not what happens.

## 2. First apparition index vs. the proved bound `4ℓ`

For each good prime `ℓ` the first `n` with `ℓ ∣ den x(nP)` was computed two ways and agrees:
(i) exactly over `ℚ` for `n ≤ 24`, (ii) as the order of the reduction `P mod ℓ` in `E(F_ℓ)`.

| ℓ | first index m | proved bound `4ℓ` **[Lean]** | Hasse bound `ℓ+1+2√ℓ` |
|---|---|---|---|
| 7 | 2 | 28 | 12 |
| 13 | 3 | 52 | 20 |
| 17 | 6 | 68 | 26 |
| 19 | 9 | 76 | 28 |
| 23 | 24 | 92 | 32 |
| 29 | 15 | 116 | 40 |
| 31 | 43 | 124 | 42 |
| 37 | 37 | 148 | 50 |
| 41 | 14 | 164 | 54 |
| 43 | 7 | 172 | 56 |
| 47 | 16 | 188 | 60 |
| 53 | 54 | 212 | 68 |
| 61 | 61 | 244 | 76 |
| 73 | 3 | 292 | 90 |
| 83 | 12 | 332 | 102 |
| 101 | 102 | 404 | 122 |
| 113 | 57 | 452 | 134 |

No good prime `ℓ < 120` fails to appear, and every observed index is well below `4ℓ`; several
(`31, 37, 53, 61, 101`) sit just under the Hasse bound, so a bound of the shape `ℓ + O(√ℓ)`
is the true limit and `4ℓ` cannot be improved to anything below `ℓ + 1`.

## 3. Counterexample hunt against the theorems

* Searched all primes `5 ≤ ℓ < 120` with `ℓ ∤ 55` for a violation of the effective bound
  (an apparition index exceeding `4ℓ`, or a prime never appearing): none found — consistent
  with **[Lean]** `exists_small_multiple_dvd_den` and `non_appearing_primes_finite`.
* Searched for a collision of reductions whose difference escapes the kernel (the hypothesis of
  the collision lemma): none found; the `2`-torsion branch (`ℓ ∣ num y`) is genuinely needed and
  occurs, e.g. for `ℓ = 7`, `n = 1`: `y(P) = 28 = 4·7`, which is exactly why `7` enters at `n = 2`.

## 4. Sequence data

The square roots `e_n` of the denominators (`den x(nP) = e_n²`) begin
`1, 56, 25623, …` (e.g. `den x(3P) = 3⁶·13²·73² = 656538129 = 25623²`); this is the elliptic divisibility sequence of `(E_55, P)`. No OEIS
entry was consulted for this run, so no OEIS identifier is claimed.
