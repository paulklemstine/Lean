# Computational Evidence

All claims in `DreamtimeKinshipGL.lean` are proved for general `n`, but the
finite instances were checked numerically before formalization.

## 1. Order of the kinship group `Kin n = (ℤ/2)ⁿ`

`|Kin n| = 2ⁿ`:

| n | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| `2ⁿ` | 2 | 4 | 8 | 16 |

`n = 2` is the four-section (Kariera) system, `n = 3` the eight-subsection
(Aranda/Warlpiri) system, matching the anthropological data.

## 2. Kinship spectrum (admissible marriage rules) `= 2ⁿ − 1`

Number of nonzero involutions:

| n | 1 | 2 | 3 |
|---|---|---|---|
| `2ⁿ − 1` | 1 | 3 | 7 |

For the four-section system there are exactly 3 nonzero sections, i.e. 3
possible marriage rules — the three permutations of the nonzero classes.

## 3. Symmetry group order `|GL(n, 𝔽₂)| = ∏ᵢ (2ⁿ − 2ⁱ)`

| n | product | value |
|---|---------|-------|
| 1 | (2−1) | 1 |
| 2 | (4−1)(4−2) | 6 |
| 3 | (8−1)(8−2)(8−4) | 168 |
| 4 | (16−1)(16−2)(16−4)(16−8) | 20160 |

These are the orders of `GL(n, 𝔽₂)` (OEIS **A002884**: 1, 6, 168, 20160, ...).
The `n = 2` value `6 = 3!` confirms `GL(2, 𝔽₂) ≅ S₃` — the four-section symmetry
group permutes the three nonzero sections freely. Verified in Lean by
`card_addAut_two` and `karieraSymmetry_card` (`decide`).

## 4. Counterexample hunt

- **"Is the section group cyclic?"** Checked `IsAddCyclic (Kin n)`: false for
  `n ≥ 2` since the maximal order of an element is `2 < 2ⁿ`. Formalized as
  `kin_not_addCyclic`.
- **"Does marriage leave the moiety?"** For all tested generators lying in the
  moiety kernel (last coordinate `0`), translation preserves the moiety coset:
  no counterexample. Formalized as `marriage_preserves_moiety`, with
  `marriageMoiety_index = 2`.
- **"Is the forgetful kernel bigger than `ℤ/2`?"** No: it is exactly `ℤ/2`
  (`forget_ker_card = 2`), so `Kin (n+1)` is a genuine double cover of `Kin n`.

No counterexamples were found to any universal claim; each was then proved for
all `n`.
