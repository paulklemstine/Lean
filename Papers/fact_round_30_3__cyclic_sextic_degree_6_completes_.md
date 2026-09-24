# Computational evidence — degree-6 rung `Q(ζ₁₃)⁺`

These numbers came from a short exploratory Python enumeration run before the Lean work.
Every item marked **[Lean]** is also proved in `Catalog/Physics/AbelianLadderCyclicSextic.lean`
or `Catalog/Physics/AbelianLadderSexticCRT.lean`, with no `sorry`.

## 1. Residue degree of `p mod 13` in `Q(ζ₁₃)⁺`

The residue degree is the order of `u` in `(Z/13)ˣ/{±1}`, i.e. the least `k` with `u^k ≡ ±1 (mod 13)`.

| `u mod 13` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `T(u)`     | 1 | 6 | 3 | 3 | 2 | 6 | 6 | 2 | 3 | 3  | 6  | 1  |
| `T₂` (in `Q(√13)`) | 1 | 2 | 1 | 1 | 2 | 2 | 2 | 2 | 1 | 1 | 2 | 1 |
| `T₃` (in the cubic subfield) | 1 | 3 | 3 | 3 | 1 | 3 | 3 | 1 | 3 | 3 | 3 | 1 |

`T = T₂ · T₃` holds in every column **[Lean: `realDeg_13_eq_mul`]**.
The type counts are `(2, 2, 4, 4)` for `T = (1, 2, 3, 6)`, i.e. the rates `{1/6, 1/6, 1/3, 1/3}` **[Lean: `card_realDeg_13`]**.

## 2. Entropies (exact against reported)

| quantity | exact closed form | numeric | reported | verdict |
|---|---|---|---|---|
| `H(T₆)` | `1/3 + log₂ 3` | 1.9182958 | 1.9192 "exactly" | reported value is **not exact** (gap > 8·10⁻⁴) **[Lean: `reported_H_not_exact`]** |
| `H(T₂)` | `1` | 1 | — | **[Lean]** |
| `H(T₃)` | `log₂ 3 − 2/3` | 0.9182958 | — | **[Lean]** |
| `I(T ; p mod 13)` | `= H(T₆)` | 1.9182958 | = H(T) | full pinning holds **[Lean: `full_pinning_deg6`]** |
| `I(pair ; N mod 13)` | `log₂ 3 − 1/9` | 1.4738514 | 1.4704 | reported value is an under-estimate (gap > 3·10⁻³) **[Lean: `reported_Ipair_below_exact`]** |
| `I(split-count ; N mod 13)` | `log₂ 3 − (55/36) log₂ 5 + 19/9` | 0.1486835 | — | **[Lean: `Isplit_six_eq`, `Isplit_six_bracket`]** |

Python cross-check: brute-force `I(s)` on the 36-point box gives `0.14868346686546374`, and the closed form gives
`0.1486834668654642`.

## 3. Additivity check (counterexample hunt)

Claim: `H(T_{mn}) = H(T_m) + H(T_n)` for coprime `m, n`. We enumerated `typeEntropy` for all 199 ordered coprime pairs
with `m·n ≤ 60` and found no counterexample (tolerance `10⁻⁹`). The general statement is now **[Lean: `typeEntropy_mul_of_coprime`]**.

For non-coprime orders the additivity fails, e.g. `H(T₄) = 3/2 ≠ 2 = 2·H(T₂)`.

## 4. Split-count "blindness"

The split count `s` depends only on whether each exponent is `0`. So its law, and therefore
`Isplit n`, is given by one closed form for every `n`, prime or not. At `n = 6` the prime-degree formula
matches the direct value exactly **[Lean: `Isplit_six_matches_prime_formula`]**.

## 5. OEIS

The fibre-count vector `(φ(d))_{d | 6} = (1, 1, 2, 2)` is Euler's totient on the divisors (A000010). No new sequence came up.
