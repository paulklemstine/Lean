# Computational evidence — METHOD-LOCALITY (round 28 #1)

All numbers below were produced by direct enumeration of the orbits; the two that the
formal development relies on (`p = 1009` and `p = 4093`) are *re-verified inside Lean*
by kernel computation (`rho_1009_nodup`, `rho_1009_collide`, `rho_4093_nodup`,
`rho_4093_collide`), so the Lean statements do not depend on the scratch computations
reported here.

## 1. Cofactor flatness of Pollard ρ (H1)

Iteration `x ↦ x² + 1`, seed `x₀ = 2`, run **modulo `N = p·q`** with `p = 4093` fixed,
watching the mod-`p` shadow.  `(i, n)` is the first repetition: state `n` repeats
state `i`.

| cofactor `q` | `N = 4093·q` | first mod-`p` repetition `(i, n)` |
|---|---|---|
| 1 (run mod `p`) | 4093 | (53, 70) |
| 3 | 12 279 | (53, 70) |
| 5 | 20 465 | (53, 70) |
| 101 | 413 393 | (53, 70) |
| 2¹⁴+27 | 67 170 223 | (53, 70) |
| 2¹⁷+9 | 536 615 533 | (53, 70) |
| 2²⁰+7 | 4 291 850 219 | (53, 70) |
| 2²³+9 | 34 334 609 381 | (53, 70) |

Flatness ratio **exactly 1.00** over 2²³ of cofactor growth, not the `×1.40` of the
median-based experiment: the residual spread there is seed/curve luck.  This is what
`MethodLocality.rho_cofactor_flat` proves in general, for every cofactor and seed.

## 2. `p`-scaling of the intrinsic ρ cost (H2)

| `p` | ρ steps | `√p` | ρ/`√p` | trial divisions `p−1` | advantage |
|---|---|---|---|---|---|
| 101 | 17 | 10.0 | 1.69 | 100 | 5.9× |
| 1009 | 49 | 31.8 | 1.54 | 1008 | 20.6× |
| 4093 | 70 | 64.0 | 1.09 | 4092 | 58.5× |
| 65537 | 172 | 256.0 | 0.67 | 65536 | 381× |
| 1000003 | 1289 | 1000.0 | 1.29 | 1000002 | 776× |

Least-squares-free two-point slope over the full range
(`p = 101 → 1000003`): `log₂(1289/17) / log₂(1000003/101) = 0.47`, reproducing the
reported `0.45`; the single-draw slope between the two adjacent anchors 1009 and 4093
is `0.26`, which is why per-cell medians (not single draws) are required before any
exponent claim.  The advantage column is the formal content of
`MethodLocalityRigid.advantage_grows` (20× and 58× proved at the two Lean anchors).

## 3. Non-flatness of trial division (counterexample hunt)

Same fixed factor `p = 4093`, varying cofactor:

| `q` | `N = 4093·q` | trial divisions to first factor |
|---|---|---|
| 3 | 12 279 | 2 |
| 5 | 20 465 | 4 |
| 4093 | 16 752 649 | 4092 |

A `2046×` spread with the hunted factor held fixed: trial division's ledger is a
function of the modulus, never of the factor.  Formalised twice, first as the explicit
counterexample `MethodLocality.trial_not_cofactor_flat` and then structurally as
`MethodLocalityRigid.rigidity_of_modulusDetermined_flat`.

## 4. Birthday window at the anchor

Uniform-model survival probability `∏_{i<k}(1 − i/4093)`:

| `k` | bound `exp(−k(k−1)/2p)` |
|---|---|
| 48 | 0.7591 |
| 64 | 0.6111 |
| 70 | 0.5543 |
| 76 | 0.4984 |

The measured `70` sits inside this window; `MethodLocality.birthday_half_4093` proves
the `k = 76` entry (`≤ 1/2`) and `birthday_prod_le_exp` the general bound.

## 5. Sequence lookups

The ρ-length sequence for `x² + 1`, `x₀ = 2` over successive primes
(17, 49, 70, 172, 1289, …) is seed- and prime-indexed rather than a standard integer
sequence; no OEIS entry is claimed for it.
