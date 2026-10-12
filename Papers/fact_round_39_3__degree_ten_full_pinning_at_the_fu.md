# Computational Evidence — Degree ten, full cyclotomic field Q(ζ₁₁) (paper 141, exp 473)

All numbers in this file come from short Python scripts (exact `fractions`/`collections`
arithmetic over the groups, and a sieve for the prime census). They were used to *find*
the statements. The statements themselves are then proved in Lean in
`Catalog/Cryptography/DegreeTenCyclotomic/`. The prime census and the Monte-Carlo
semiprime estimate (§2, §3) are exploratory only and are **not** Lean-verified.

## 1. Small cases: the group model C₁₀ ≅ (ℤ/11)ˣ

| residue g | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| ord₁₁(g) = T | 1 | 10 | 5 | 5 | 5 | 10 | 10 | 10 | 5 | 2 |

The type multiplicities are 1, 1, 4, 4 = φ(1), φ(2), φ(5), φ(10). Proved in Lean: `deg10_type_counts`, and in general `cyclic_type_fiber_card`.
The entropy is H(T) = log₂5 − 3/5 = 1.721928… Proved in Lean: `deg10_type_entropy`, with enclosure `deg10_channel_numeric`.

Factor patterns of Φ₁₁ mod p (proved for **all** primes p ≠ 11 in `cyclotomic11_pattern`, plus explicit witnesses):

| p | p mod 11 | ord | pattern | Lean |
|---|---|---|---|---|
| 23 | 1 | 1 | [1¹⁰] | `cyclotomic11_mod23` |
| 43 | 10 | 2 | [2⁵] | `cyclotomic11_mod43` |
| 3 | 3 | 5 | [5,5] | `cyclotomic11_mod3` |
| 2 | 2 | 10 | [10] (irreducible) | `cyclotomic11_mod2`, `cyclotomic11_irreducible_mod2` |

## 2. Prime census (exploratory, not Lean-verified)

The census covers the primes p ≤ 2·10⁶ with p ≠ 11 (148,932 primes):

| T | 1 | 2 | 5 | 10 |
|---|---|---|---|---|
| empirical density | 0.1001 | 0.0999 | 0.3998 | 0.4002 |
| Chebotarev φ(d)/10 | 0.1 | 0.1 | 0.4 | 0.4 |

The empirical value I(p mod 11 ; T) = 1.72198 bits. The exact law is 1.72193 bits.

## 3. Semiprime channel

These are exact enumerations over C₁₀ × C₁₀ (100 cells).
- The unordered pair has 10 classes with counts [1,2,8,8,1,8,8,16,32,16]. The joint readout (N mod 11, pair) has 34 classes.
- **I(N mod 11 ; {T(p),T(q)}) = log₂5 + (12/25)log₂3 − 47/25 = 1.2027101…** Proved in Lean: `semi_channel`, with enclosure `semi_channel_numeric`.
- The ordered pair gives the same value, so the which-factor wall is exactly 0. Proved in Lean: `semi_which_factor_wall`, and structurally for every Galois group in `which_factor_wall_coset`.
- Monte-Carlo with seed 20260823 over 200,000 random prime pairs (p, q ≤ 2·10⁶) gives an empirical value of 1.2019. This is consistent with sampling bias below the exact 1.2027 (exploratory).

**Counterexample hunt / audit of the reported numbers.** The reported "fresh enumeration law 1.1999" is *not* the exact law. The exact law is 1.20271, which is the paper-78 anchor 1.2027. Lean proves `1.2002 < I` and `|I − 1.2027| < 3·10⁻⁵`. The reported "wall 0.0005" is a gap between two estimates. It is not a which-factor wall, which is provably 0.

## 4. Ladder table: other prime conductors ℓ, full cyclotomic fields (exact enumeration)

| ℓ | degree | H(T) | I_semi (unordered) | I_semi (ordered) | wall |
|---|---|---|---|---|---|
| 3 | 2 | 1.00000 | 1.00000 | 1.00000 | 0 |
| 5 | 4 | 1.50000 | 1.25000 | 1.25000 | 0 |
| 7 | 6 | 1.91830 | 1.47385 | 1.47385 | 0 |
| 11 | 10 | 1.72193 | 1.20271 | 1.20271 | 0 |
| 13 | 12 | 2.41830 | 1.72385 | 1.72385 | 0 |
| 17 | 16 | 1.87500 | 1.32812 | 1.32812 | 0 |
| 19 | 18 | 2.22439 | 1.52650 | 1.52650 | 0 |
| 23 | 22 | 1.43950 | 1.05190 | 1.05190 | 0 |
| 29 | 28 | 2.09167 | 1.36411 | 1.36411 | 0 |
| 31 | 30 | 2.64022 | 1.67656 | 1.67656 | 0 |

No counterexample to "wall = 0" was found. That claim is now a theorem.

## 5. Tower gap H(T_{Q(ζ_p)}) − H(T_{Q(ζ_p)⁺})

| p | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| gap | 1 | 0.5 | 1 | 1 | 0.5 | 0.125 | 1 | 1 | 0.5 | 1 | 0.5 | 0.25 | 1 |

The data match gap = 2^{1−v₂(p−1)}. For p = 11 the gap is 1 bit, proved in Lean as `tower_bit`. The general formula is in FUTURE_DIRECTIONS.

CRT additivity H(C_{mn}) = H(C_m) + H(C_n) holds numerically for coprime (m,n) and fails for (2,4) and (3,9). The case C₁₀ = C₂ × C₅ is proved in Lean as `deg10_crt_split`.

OEIS: not applicable; the objects are finite entropy values, not integer sequences.
