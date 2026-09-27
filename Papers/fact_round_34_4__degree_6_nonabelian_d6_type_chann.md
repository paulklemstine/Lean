# Computational evidence: the D₆ type channel of x⁶ − 2 (paper 122)

The numbers in this file come from a Python sieve over the 17 982 primes 5 ≤ p < 200 000.
They are **exploratory and are not Lean-verified**. The Lean-verified counterparts are named
next to each item. The root count was computed in two ways, by brute force for the first
2 000 primes and by the criterion "2 is a sixth power mod p" for all of them, and the two
agreed on every prime where both were run.

## 1. Small cases
T(p) = #{x ∈ 𝔽_p : x⁶ = 2}:

| p | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 | 61 | 67 | 71 | 73 | 79 |
|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| T | 0 | 0 | 0 | 0 | 2 | 0 | 2 | 0 | **6** | 0 | 2 | 0 | 2 | 0 | 0 | 0 | 0 | 2 | 0 | 0 |

Lean: `rootCount6_table` checks T for p = 5, 7, 11, 13, 19, 23, 31, 47 by `decide`.
31 is the least prime p ≥ 5 with T = 6.

## 2. The type distribution
Empirically {0: 0.6676, 2: 0.2499, 6: 0.0825} with H(T) = 1.1861 bits. The prediction from D₆ is
{2/3, 1/4, 1/12}, which gives H(T) = (3/4)·log₂3 = 1.18872 bits.
Lean: `typeCounts_D6`, `typeEntropy_D6`.

## 3. Conditional type distributions by p mod 24 (counts)
| p mod 24 | T = 0 | T = 2 | T = 6 |
|---|---|---|---|
| 1 | 1484 | – | 728 |
| 5 | 2251 | – | – |
| 7 | 1516 | – | 756 |
| 11 | 2250 | – | – |
| 13 | 2260 | – | – |
| 17 | – | 2254 | – |
| 19 | 2244 | – | – |
| 23 | – | 2239 | – |

This matches `rootCount6_mod24` exactly. Six of the eight classes are pinned, and in the
classes 1 and 7 the split is ≈ 2:1, as the kernel coset {r0, r2, r4} predicts.
**No counterexample was found.**

## 4. Channels (empirical vs exact)
| quantity | empirical | exact (Lean) |
|---|---|---|
| I(p mod 3; T) | 0.36284 | log₂3/4 + (5/12)log₂5 − 1 = 0.36371 (`mutInfo_rotSign_D6`) |
| I(p mod 24; T) | 0.95771 | log₂3/2 + 1/6 = 0.95915 (`mutInfo_abMap_D6`) |
| I(p mod 72; T) | 0.95779 | ≤ 0.95915 for every abelian dial (`mutInfo_abelian_dial_le_D6`) |
| semiprime I(N mod 3; (T_p, T_q)) | 0.13239 | (3/8)log₂3 + (35/72)log₂5 + (17/72)log₂17 − 23/9 = 0.13262 (`mutInfo_pair_D6`) |
| Bayes error, no dial | 0.3324 | 4/12 (`constant_predictor_error_ge/eq`) |
| Bayes error, p mod 3 | 0.3324 | 4/12, so **no gain** (`rotSign_predictor_error_ge`) |
| Bayes error, p mod 24 | 0.0825 | 1/12 is the floor for all abelian dials (`abelian_predictor_error_ge`, `ab6_predictor_error_eq`) |

Refining p mod 24 to p mod 72 adds essentially nothing (0.95771 → 0.95779). This is
consistent with the abelian ceiling, since p mod 72 also factors through an abelian quotient.

## 5. OEIS
The primes with T(p) = 6 begin 31, 127, 223, 433, 439, 457, 601, 727, 919, 1327, 1399, 1423, …
(computed in Python, not Lean-verified). These are the primes that split completely in
ℚ(2^{1/6}, ζ₆), i.e. the primes p ≡ 1, 7 (mod 24) of the form x² + 27y². The second condition
is Gauss's classical criterion for 2 to be a cubic residue, and it is not a congruence
condition. We did not run an OEIS lookup in this cycle, so no A-number is claimed.
