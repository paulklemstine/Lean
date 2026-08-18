# Computational evidence — JACSIGN cycle 1

All numbers below were computed from the definition
`W(N) = ∑_{x mod N} ( x(1−x²) / N )` (Jacobi symbol), which for a prime modulus is the
Jacobi-signed circle count of `Catalog/Tropical/JacobiSigned*.lean`.
They were used to select and sanity-check the statements before formalising them;
every statement that is *claimed* in this cycle is proved in Lean (see
`Catalog/Pythagorean/JacobiSigned*.lean`), so the tables here are guidance, not evidence
of record.

## 1. `W(p)` and its 2-adic valuation at primes

| p | p mod 4 | W(p) | v₂(W(p)) | p = a²+b² |
|---|---------|------|----------|-----------|
| 3,7,11,19,23,31,… | 3 | 0 | — | — |
| 5 | 1 | 2 | 1 | 1²+2² |
| 13 | 1 | −6 | 1 | 3²+2² |
| 17 | 1 | −2 | 1 | 1²+4² |
| 29 | 1 | 10 | 1 | 5²+2² |
| 37 | 1 | 2 | 1 | 1²+6² |
| 41 | 1 | −10 | 1 | 5²+4² |
| 53 | 1 | −14 | 1 | 7²+2² |
| 61 | 1 | 10 | 1 | 5²+6² |
| 73 | 1 | 6 | 1 | 3²+8² |
| 89 | 1 | −10 | 1 | 5²+8² |
| 97 | 1 | −18 | 1 | 9²+4² |
| 101 | 1 | 2 | 1 | 1²+10² |
| 109 | 1 | −6 | 1 | 3²+10² |
| 113 | 1 | 14 | 1 | 7²+8² |
| 173 | 1 | 26 | 1 | 13²+2² |

Observations that became theorems:

* `v₂(W(p)) = 1` for every `p ≡ 1 (mod 4)` (catalog `W_mod_four`), and `|W(p)| = 2a`
  with `a` the **odd** leg.
* Deficiency `4p − W(p)² = 4b²` with `b` the even leg — always a multiple of 16, with
  the minimum 16 attained exactly when `b = ±2` (p = 13, 173, …).
  Formalised: `weil_deficiency`, `W_sq_le_four_p_sub_sixteen`, `improved_floor_sharp`.

## 2. Semiprimes `N = pq`, both factors `≡ 1 (mod 4)`

| N | p·q | W(N) | v₂ | odd Gaussian leg u of N | (W(N) ∓ 4u) mod 16 |
|---|-----|------|----|--------------------------|---------------------|
| 65 | 5·13 | −12 | 2 | 1 | 0 / 8 |
| 85 | 5·17 | −4 | 2 | 9 | 8 / 0 |
| 145 | 5·29 | 20 | 2 | 1 | 0 / 8 |
| 185 | 5·37 | 4 | 2 | 13 | 0 / 8 |
| 205 | 5·41 | −20 | 2 | 3 | 0 / 8 |
| 221 | 13·17 | 12 | 2 | 5 | 8 / 0 |
| 377 | 13·29 | −60 | 2 | 19 | 8 / 0 |
| 493 | 17·29 | −20 | 2 | 3 | 0 / 8 |
| 1189 | 29·41 | −100 | 2 | 33 | 8 / 0 |
| 2173 | 41·53 | 140 | 2 | 43 | 0 / 8 |

* `v₂(W(N)) = 2` in every case — formalised as `WZ_semiprime_two_adic`
  and `padicValInt_WZ_semiprime`.
* In every row exactly one of `W(N) − 4u`, `W(N) + 4u` is divisible by 16 (the sign of the
  Gaussian leg is only defined up to `±`).  Formalised as `WZ_semiprime_gaussian_leg`.
* Triples: `1105 = 5·13·17 → W = 24 (v₂ = 3)`, `1885 = 5·13·29 → −120 (v₂ = 3)`,
  `2465 = 5·17·29 → −40 (v₂ = 3)`.  Formalised as `padicValInt_WZ_squarefree`.

## 3. Counterexample hunt against the "publicly computable" half of C3

C3 claimed the 2-adic content of the statistic is *determined by `N mod 4`* for semiprimes.
Counterexample found immediately:

* `21 = 3·7`, `21 mod 4 = 1`, `W(21) = 0`;
* `85 = 5·17`, `85 mod 4 = 1`, `W(85) = −4`, `v₂ = 2`.

So `N mod 4` does not determine even whether the statistic vanishes.  Formalised (as a
refutation) in `vanishing_not_determined_by_mod_four` and `not_two_adic_dial_mod_four`.
The correct information-theoretic statement — constancy on the family with both factors
`≡ 1 (mod 4)` — is `two_adic_blind_to_split`.

## 4. Conic (degree-two) weights

For `Q_{r,s}(N) = ∑_x ((x−r)(x−s)/N)` and odd primes separating the roots, `Q = −1` at every
prime and hence `+1` at every semiprime — a constant, computed directly from
`chiSum_quadratic` of the catalog.  This kills the whole degree-two family before any Weil
bound is needed; formalised in `Qroots_prime_of_ne`, `conic_witness_blind`,
`Qroots_squarefree`.

## 5. OEIS

The sequence `W(p)` for `p ≡ 1 (mod 4)` (`2, −6, −2, 10, 2, −10, −14, 10, 6, …`) is, up to
sign convention, twice the odd Gaussian leg `a` of `p = a² + b²` with `a ≡ 1 (mod 4)` after
normalisation; the unsigned legs `1, 3, 1, 5, 1, 5, 7, 5, 3, …` match the classical "odd part
of the two-square representation" sequence.  No new sequence is claimed.
