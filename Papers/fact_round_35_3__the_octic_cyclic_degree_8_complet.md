# Computational evidence — THE OCTIC CYCLIC RUNG (FACT round-35 #3, paper 124)

All values marked **[Lean]** are statements proved in
`Catalog/Novelty/OcticCyclicRung.lean` or `Catalog/Novelty/OcticTowerInformation.lean`
(no `sorry`, no `native_decide`; axioms `propext, Classical.choice, Quot.sound`).

## 1. Small cases: the octic splitting law mod 17  [Lean: `octic_splitting_law`]

| `p mod 17` | 1, 16 | 4, 13 | 2, 8, 9, 15 | 3, 5, 6, 7, 10, 11, 12, 14 |
|---|---|---|---|---|
| residue degree `T(p)` in `Q(ζ₁₇)⁺` | 1 | 2 | 4 | 8 |
| number of classes | 2 | 2 | 4 | 8 |
| density | 1/8 = 12.5 % | 1/8 = 12.5 % | 1/4 = 25 % | 1/2 = 50 % |

Census `{2,2,4,8}` = `2·φ(d)` for `d | 8` **[Lean: `octic_type_census`, `card_realDeg_eq`]**.
Examples **[Lean: `octic_examples`]**: `T(103) = 1`, `T(13) = 2`, `T(2) = 4`, `T(3) = 8`.

## 2. Entropies

| quantity | reported | exact | status |
|---|---|---|---|
| `H(T)` | 1.7474 | **7/4 = 1.75** | [Lean: `octic_entropy`, `octic_reported_value`: `1.7474 < 7/4`, gap `< 0.003`] |
| `I(p mod 17 ; T)` | 1.7474 | **7/4** | [Lean: `full_pinning_deg8_residue`] |
| `I(sign class ; T)` | — | **7/4** (`H(T|class) = 0`) | [Lean: `full_pinning_deg8`] |
| semiprime pair `Ipair 8` | 1.3097 | **21/16 = 1.3125** | [Lean: `octic_semiprime_channel`] |
| which-factor increment | 0.0002 | **0** | [Lean: `octic_semiprime_channel` via `Ipair_eq_IpairOrd`] |

Both reported values sit slightly *below* the exact ones, the sign expected of a
plug-in entropy estimate from finitely many primes.

## 3. The two-power ladder  [Lean: `typeEntropy_two_pow`]

`H(T_{2^m}) = 2 - 2^{1-m}`:

| m | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| degree | 1 | 2 | 4 | 8 | 16 | 32 |
| H(T) | 0 | 1 | 3/2 | **7/4** | 15/8 | 31/16 |

The `m = 5` value agrees with the catalog's independent enumeration
`typeEntropy_val_32 = 31/16`. Numerators `2^m - 1` are the Mersenne numbers
(OEIS A000225).
Fermat rungs `f = 2^{m+1}+1` **[Lean: `fermat_rung_entropy`, for any prime of that shape]**:
`f = 5 → 1`, `f = 17 → 7/4`, `f = 257 → 2 - 1/64`, `f = 65537 → 2 - 2^{-14}`
(the primality of 257 and 65537 is the standard fact, not re-proved here).

## 4. The tower filtration  [Lean: `octic_tower_information`]

| layer (degree) | observable | `H(T | layer)` | `I(T ; layer)` | `= H(T_{layer})` |
|---|---|---|---|---|
| `Q(√17)` (2) | `u⁸` (Legendre) | 3/4 | 1 | `typeEntropy 2 = 1` |
| `K₄` (4) | `u⁴` | 1/4 | 3/2 | `typeEntropy 4 = 3/2` |
| `Q(ζ₁₇)⁺` (8) | `u²` (sign class) | 0 | 7/4 | `typeEntropy 8 = 7/4` |

## 5. Counterexample hunt

* The universal claim "every abelian field shows full pinning" is a theorem for the
  Artin class (catalog `abelian_full_pinning`; here `full_pinning_deg8`).
* It **fails for coarser observables**: the Legendre symbol mod 17 leaves
  `H(T | Legendre) = 3/4 > 0` **[Lean: `legendre_does_not_pin_octic`]**. So "full
  pinning" describes the Artin class (or anything that determines it up to sign),
  not arbitrary residue features.
* No counterexample to `H(T) = typeEntropy((f-1)/2)` can exist: it is proved for every
  odd prime `f` **[Lean: `uEnt_realDeg_eq_typeEntropy`]**.
