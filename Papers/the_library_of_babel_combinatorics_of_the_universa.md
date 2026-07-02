# Computational Evidence — Combinatorics of the Universal Library

We model the Library of Babel as `Volume A L = Fin L → Fin A`: all strings of
length `L` over an alphabet of `A` symbols. Borges' parameters are `A = 25`,
`L = 1312000`, giving `25^1312000` volumes.

## 1. Library size and constrained-content counts

| A | L | volumes `A^L` | fix 1 symbol → `A^(L-1)` |
|---|---|---------------|--------------------------|
| 2 | 3 | 8             | 4                        |
| 4 | 2 | 16            | 4                        |
| 3 | 3 | 27            | 9                        |

Fixing `d` positions always divides the population by `A^d`
(→ `card_matchesOn : A^(L - d)`).

## 2. Probability of finding a fixed passage (union bound)

For a fixed passage `p` of length `m`, a fixed window matches an `A^{-m}`
fraction of volumes; there are `L - m + 1` windows.

Enumeration check, `A = 2, L = 3`, pattern `p = 11`:
strings of length 3 containing `11` as a window = {`110`, `011`, `111`} → 3.
- Exact probability `3/8 = 0.375`.
- Union bound `(L-m+1)/A^m = (3-2+1)/2^2 = 2/4 = 0.5`.
- `0.375 ≤ 0.5` ✓ (bound is genuine because overlapping windows are over-counted).

`A = 2, L = 4`, pattern `p = 11`: strings containing `11` = 8 of 16 → `0.5`;
bound `(4-2+1)/4 = 3/4` ✓.

This confirms `prob_containsPattern_le : count / A^L ≤ (L - m + 1) / A^m`.

**Correction to the heuristic.** The mission text estimates the probability as
`|T| · A^{-k}`, i.e. a leading factor of `|T| = m`. The honest combinatorial
prefactor is the number of *placements* `L - m + 1 ≈ L` (for `m ≪ L`), not `m`.
We prove the corrected inequality.

## 3. The diagonal argument (finite Cantor)

Number of possible catalogs (subsets of the Library) is `2^(A^L)`; number of
volumes is `A^L`. Since `n < 2^n` for all `n`, we get `A^L < 2^(A^L)`.

| A | L | volumes `A^L` | catalogs `2^(A^L)` |
|---|---|---------------|--------------------|
| 2 | 1 | 2             | 4                  |
| 2 | 2 | 4             | 16                 |
| 2 | 3 | 8             | 256                |

Hence no single volume can be assigned a distinct complete catalog
(→ `no_complete_self_catalog`).

## 4. Distributed catalog threshold

A distributed catalog `c : Fin N → Volume` is complete iff it is surjective.
Since each catalog volume identifies exactly one library volume, completeness
needs `N ≥ A^L` (→ `distributed_catalog_iff`).

Mini-Library `A = 4, L = 16`: `A^L = 4^16 = 4294967296`.
- Heuristic threshold `A^L / (L·log₂A) = 4^16 / (16·2) = 4^16/32 ≈ 1.34e8`.
- True threshold `A^L = 4.29e9`.
- The heuristic underestimates by a factor `L·log₂A = 32`.

## 5. de Bruijn catalog capacity (mini-Library `A = 4`)

A single index volume of length `L` displays at most `A^k` distinct length-`k`
codes (subword-complexity bound), and once `L ≥ A^k + k` a code must repeat.

| A | k | distinct codes `A^k` | de Bruijn length `A^k + k - 1` |
|---|---|----------------------|--------------------------------|
| 4 | 1 | 4                    | 4                              |
| 4 | 2 | 16                   | 17                             |
| 4 | 3 | 64                   | 66                             |

`B(4,2)` (cyclic length `16`) contains each of the `16` length-2 codes exactly
once; its linearisation has length `17 = 4^2 + 2 - 1`, matching the collision
threshold (→ `catalog_codes_le`, `catalog_forces_collision`).

## Counterexample hunt

No counterexamples were found to the four proved inequalities across all tested
small cases (`A ≤ 4`, `L ≤ 6`, `m, k ≤ L`). The single refuted claim was the
mission's heuristic prefactor `|T|`, replaced by the correct `L - |T| + 1`.
