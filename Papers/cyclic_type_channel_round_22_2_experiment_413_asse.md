# Computational Evidence — Cyclic splitting-type channel

All numbers below were produced by an independent Python re-implementation of the catalog
definitions in `Catalog/Computation/CyclicTypeChannel.lean`
(`typ n x = n / gcd(n,x)`, `HT`, `Hnr`, `Hpair`, `HpairGivenN`, `Ipair = Hpair − HpairGivenN`),
by exhaustive enumeration of the unit group `Z/n` and of all ordered pairs.  They are
*evidence*, not verification: every claim that appears as a theorem in `Catalog/Physics/` is
proved in Lean with 0 sorries, and the two agree everywhere they overlap
(e.g. the Lean closed form gives `HT 16 = 15/8 = 1.875`, matching the table below and the
independently enumerated catalog value `HT_sixteen`).

## 1. Small-case table

| n | H(T) | H(nr) | log₂ d(n) | log₂ n | I_pair | n prime |
|---|---|---|---|---|---|---|
| 1 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | 0.0000 | no |
| 2 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 | yes |
| 3 | 0.9183 | 0.9183 | 1.0000 | 1.5850 | 0.4739 | yes |
| 4 | 1.5000 | 0.8113 | 1.5850 | 2.0000 | 1.2500 | no |
| 5 | 0.7219 | 0.7219 | 1.0000 | 2.3219 | 0.2027 | yes |
| 6 | 1.9183 | 0.6500 | 2.0000 | 2.5850 | 1.4739 | no |
| 7 | 0.5917 | 0.5917 | 1.0000 | 2.8074 | 0.1141 | yes |
| 8 | 1.7500 | 0.5436 | 2.0000 | 3.0000 | 1.3125 | no |
| 9 | 1.2244 | 0.5033 | 1.5850 | 3.1699 | 0.5265 | no |
| 10 | 1.7219 | 0.4690 | 2.0000 | 3.3219 | 1.2027 | no |
| 11 | 0.4395 | 0.4395 | 1.0000 | 3.4594 | 0.0519 | yes |
| 12 | 2.4183 | 0.4138 | 2.5850 | 3.5850 | 1.7239 | no |
| 13 | 0.3912 | 0.3912 | 1.0000 | 3.7004 | 0.0386 | yes |
| 14 | 1.5917 | 0.3712 | 2.0000 | 3.8074 | 1.1141 | no |
| 15 | 1.6402 | 0.3534 | 2.0000 | 3.9069 | 0.6766 | no |
| 16 | 1.8750 | 0.3373 | 2.3219 | 4.0000 | 1.3281 | no |
| 17 | 0.3228 | 0.3228 | 1.0000 | 4.0875 | 0.0240 | yes |
| 18 | 2.2244 | 0.3095 | 2.5850 | 4.1699 | 1.5265 | no |
| 19 | 0.2975 | 0.2975 | 1.0000 | 4.2479 | 0.0197 | yes |
| 20 | 2.2219 | 0.2864 | 2.5850 | 4.3219 | 1.4527 | no |

Observations, each of which became a Lean theorem:

* `H(nr) ≤ H(T) ≤ log₂ d(n) ≤ log₂ n` holds on the whole range, with equality in the first
  slot exactly at the primes and equality in the last two exactly for `n ≤ 2`
  → `Hnr_lt_HT_iff`, `HT_le_logb_card_divisors`, `HT_lt_logb_card_divisors`,
  `HT_le_logb_self`, `HT_lt_logb_self`.
* `H(T)` is positive from `n = 2` on → `HT_pos`.

## 2. The prime type-pair channel: closed form

Exact enumeration versus the Lean closed form
`I_pair(p) = log₂p − ((p−1)(2p−1)/p²)·log₂(p−1) + ((p−1)(p−2)/p²)·log₂(p−2)`
(`CyclicType.Ipair_prime`):

| p | enumerated | closed form | agree to 1e−9 |
|---|---|---|---|
| 2 | 1.000000 | 1.000000 | yes |
| 3 | 0.473851 | 0.473851 | yes |
| 5 | 0.202710 | 0.202710 | yes |
| 7 | 0.114105 | 0.114105 | yes |
| 11 | 0.051897 | 0.051897 | yes |
| 13 | 0.038642 | 0.038642 | yes |
| 17 | 0.023981 | 0.023981 | yes |
| 19 | 0.019655 | 0.019655 | yes |
| 23 | 0.013946 | 0.013946 | yes |

The values decay like `p⁻²` (0.2027·25 = 5.07, 0.1141·49 = 5.59, 0.0519·121 = 6.28,
0.0139·529 = 7.38 — growing slowly, consistent with the proved sandwich
`1/(p² log 2) ≤ I_pair(p) ≤ (log₂p + 5)/p²`).

## 3. Counterexample hunt

* **Sub-cap claim for primes.** No odd prime `p ≤ 23` reaches 1 bit; the maximum is
  `p = 3` at 0.4739.  Proved for all odd primes (`Ipair_prime_lt_one`), with
  `p = 2` the unique prime attaining the cap (`Ipair_prime_eq_one_iff_two`).
* **Cap-breaking hunt.** For `2 ≤ n ≤ 24`, `I_pair(n) > 1` holds **exactly** for the even
  `n ≥ 4`; every odd `n` stays below (max over odd: `n = 15` at 0.6766), and `n = 2` sits
  exactly at the cap.  No counterexample found to "even ≥ 4 ⇔ above the cap"; this is
  Conjecture 1 of `FUTURE_DIRECTIONS.md` (currently proved only for prime orders and the
  enumerated even instances `n = 4,…,16`).
* **Sylow decomposition.** `H(T)(n) = Σ_p H(T)(p^{v_p(n)})` was checked for every
  `2 ≤ n ≤ 40` — no failure.  Proved in general (`HT_eq_sum_primePow`).
* **I_pair coprime additivity (open).** Checked on
  (3,4),(4,5),(3,5),(2,9),(5,7),(3,8),(7,4),(9,5),(4,11) — exact agreement to 1e−9 in every
  case, e.g. `I_pair(12) = 1.723851 = I_pair(3) + I_pair(4)`.  No counterexample found;
  this is Conjecture 2 of `FUTURE_DIRECTIONS.md`.

## 4. The 2-adic tower

| k | I_pair(2^k) | (4/3)(1 − 4^{−k}) | H(T)(2^k) | 2 − 2^{1−k} |
|---|---|---|---|---|
| 1 | 1.000000 | 1.000000 | 1.0000 | 1.0000 |
| 2 | 1.250000 | 1.250000 | 1.5000 | 1.5000 |
| 3 | 1.312500 | 1.312500 | 1.7500 | 1.7500 |
| 4 | 1.328125 | 1.328125 | 1.8750 | 1.8750 |
| 5 | 1.332031 | 1.332031 | 1.9375 | 1.9375 |
| 6 | 1.333008 | 1.333008 | 1.9688 | 1.9688 |

The entropy column is now a theorem (`HT_two_pow`, with saturation `HT_two_pow_tendsto`);
the `I_pair` column matches `(4/3)(1 − 4^{−k})` on every tested `k` and remains open
(Conjecture 3).

## 5. Decay of the binary readout

The proved bound `H(nr)(n) ≤ (log₂ n + 2)/n` against the enumerated values of column
`H(nr)` above:

| n | H(nr) | (log₂ n + 2)/n |
|---|---|---|
| 4 | 0.8113 | 1.0000 |
| 8 | 0.5436 | 0.6250 |
| 12 | 0.4138 | 0.4654 |
| 16 | 0.3373 | 0.3750 |
| 20 | 0.2864 | 0.3161 |

The bound holds throughout and both sides tend to `0`, which is the content of
`Hnr_tendsto_zero`; combined with `HT_two_pow_tendsto` this gives
`H(T)(2^k) − H(nr)(2^k) → 2` (`HT_sub_Hnr_two_pow_tendsto`): asymptotically the root count
reports none of the two bits carried by the 2-primary splitting type.

## 6. Sequence notes

The type-state counts `d(n)` (number of splitting types of `C_n`) are the divisor-count
sequence, and the occupation numbers `φ(d)` are Euler's totient — both classical; no new
integer sequence arises from the entropies themselves, which are transcendental-looking
combinations of `log₂` of small integers.  The rational sub-sequences that *do* appear —
`H(T)(2^k) = 2 − 2^{1−k}` and the conjectured `I_pair(2^k) = (4/3)(1 − 4^{−k})` — are
elementary geometric families rather than OEIS entries in their own right.
