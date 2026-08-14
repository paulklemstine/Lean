# Computational evidence: the cyclic splitting-type channel

All numbers below were first produced by direct enumeration over the finite cyclic model
(`ℤ/n` with `T(x) = ord(x) = n / gcd(n, x)`, the residue degree of a Frobenius element of
`Gal(ℚ(ζ_f)/ℚ) ≅ C_{f-1}`), and then **re-derived as exact closed forms inside Lean** by
finite enumeration over `Fin n × Fin n` (see `Catalog/Computation/CyclicTypeChannelValues.lean`).
Every entry marked *exact* is backed by a `sorry`-free Lean theorem.

## 1. Small-case calculations

`I_pair(n) = H(Π) − (1/n) Σ_c H(Π_c)`, where `Π` is the law of the unordered type pair
`{T(x), T(y)}` and `Π_c` is its law conditioned on the norm class `x + y = c`.

| n | #type states | H(T) | H(Π) | H(Π\|N) | I_pair (decimal) | I_pair (exact, Lean) |
|---|---|---|---|---|---|---|
| 2 | 2 | 1.0000 | 1.5000 | 0.5000 | 1.000000 | `1` |
| 3 | 2 | 0.9183 | — | — | 0.473851 | `log₂3 − 10/9` |
| 4 | 3 | 1.5000 | 2.3750 | 1.1250 | 1.250000 | `5/4` |
| 5 | 2 | 0.7219 | — | — | 0.202710 | `log₂5 + (12/25)log₂3 − 72/25` |
| 6 | 4 | 1.9183 | 3.1144 | 1.6405 | 1.473851 | `log₂3 − 1/9` |
| 7 | 2 | 0.5917 | — | — | 0.114105 | `log₂7 + (30/49)log₂5 − (78/49)log₂3 − 78/49` |
| 8 | 4 | 1.7500 | — | — | 1.312500 | `21/16` |
| 9 | 3 | 1.2244 | — | — | 0.526502 | `(10/9)log₂3 − 100/81` |
| 10 | 4 | 1.7219 | — | — | 1.202710 | `log₂5 + (12/25)log₂3 − 47/25` |
| 11 | 2 | 0.4395 | — | — | 0.051897 | `log₂11 + (180/121)log₂3 − (210/121)log₂5 − 210/121` |
| 12 | 6 | 2.4183 | — | — | 1.723851 | `log₂3 + 5/36` |
| 13 | 2 | 0.3912 | — | — | 0.038642 | `log₂13 − (300/169)log₂3 + (132/169)log₂11 − 600/169` |
| 14 | 4 | 1.5917 | — | — | 1.114105 | `log₂7 + (30/49)log₂5 − (78/49)log₂3 − 29/49` |
| 15 | 4 | 1.6402 | — | — | 0.676561 | `(37/25)log₂3 + log₂5 − 898/225` |
| 16 | 5 | 1.8750 | — | — | 1.328125 | `85/64` |
| 18 | 6 | 2.2244 | — | — | 1.526502 | `(10/9)log₂3 − 19/81` |
| 20 | 6 | 2.2219 | — | — | 1.452710 | `log₂5 + (12/25)log₂3 − 163/100` |

The decimal column reproduces the reported measurements
(C₄ 1.2500, C₆ 1.4739, C₁₀ 1.2027, C₁₂ 1.7239, C₁₆ 1.3281) to all printed digits.

## 2. Counterexample hunt for "every `n ≥ 4` exceeds 1 bit"

Enumeration for all `2 ≤ n ≤ 40` gives an immediate **counterexample to the unrestricted
claim**: every *odd* order lies strictly below the cap.

```
n :  2     3     4     5     6     7     8     9    10    11    12
I : 1.000 0.474 1.250 0.203 1.474 0.114 1.313 0.527 1.203 0.052 1.724
n : 13    14    15    16    17    18    19    20    21    22    23
I : 0.039 1.114 0.677 1.328 0.024 1.527 0.020 1.453 0.588 1.052 0.014
```

Pattern over `2 ≤ n ≤ 40`: `I_pair(n) > 1` **iff** `n` is even; `I_pair(n) < 1` for all odd `n`.
The corrected statement — even orders above the cap, odd orders below — is what is
formalised (`one_lt_Ipair_*` and `Ipair_*_lt_one` in `CyclicTypeChannelLaws.lean`).

## 3. Structural laws found in the data (and then proved for instances)

* **CRT additivity.** `I_pair(mn) = I_pair(m) + I_pair(n)` whenever `gcd(m,n) = 1`.
  Checked for all coprime splittings with `mn ≤ 40`; exact Lean instances:
  `12 = 4·3`, `10 = 2·5`, `15 = 3·5`, `14 = 2·7`, `20 = 4·5`, `18 = 2·9`.
* **Doubling law.** `I_pair(2m) = I_pair(m) + 1` for odd `m` (the special case `m` odd of the
  above, since `I_pair(2) = 1`). Exact Lean instances `m = 3, 5, 7, 9`.
* **2-adic growth law.** `I_pair(2^k) = (4/3)(1 − 4^{−k})`:
  `1, 5/4, 21/16, 85/64, 341/256, 1365/1024, …`, numerators `(4^k − 1)/3`
  (OEIS A002450), strictly increasing with supremum `4/3`.
  Proved in Lean for `1 ≤ k ≤ 4`; verified numerically to `k = 6`.
* **Euler-φ type law.** `P(T = d) = φ(d)/n` on the divisor lattice of `n`; proved in general
  (`typeCount_eq_totient`), and yielding the general entropy formula
  `H(T) = log₂ n − (1/n) Σ_{d ∣ n} φ(d) log₂ φ(d)` (`HT_divisor_formula`).
* **Root-count lossiness.** `H(nr)` (binary: splits completely or not) is
  `2 − (3/4)log₂3 = 0.8113` for `C₄` and `1 + log₂3 − (5/6)log₂5 = 0.6500` for `C₆`,
  strictly below `H(T) = 1.5` and `1.9183`.

## 4. Sanity checks

* `H(T)` from the general divisor formula agrees with the enumerated values, e.g.
  `n = 6`: `log₂6 − (1/6)(2·1 + 2·1) = 1/3 + log₂3 = 1.9183`.
* `I_pair(2) = 1` reproduces the quadratic (binary) fork cap exactly.
* The type is a function of the residue, so `I(residue ; T) = H(T)` exactly, and refining
  the modulus from `n` to `n·m` changes nothing (`typ_thickening`).
