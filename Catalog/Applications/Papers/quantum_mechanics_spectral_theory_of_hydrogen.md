# Computational Evidence — Hydrogen Spectral Theory

This note records the small-case checks performed before formalizing the
theorems in `HydrogenSpectrum.lean`, `HydrogenSelectionRules.lean`, and
`HydrogenAngularEigen.lean`.

## 1. Bohr energy levels `Eₙ = -1/n²` (Rydberg units)

| n | Eₙ = -1/n² |
|---|------------|
| 1 | -1         |
| 2 | -1/4       |
| 3 | -1/9       |
| 4 | -1/16      |
| 5 | -1/25      |

Confirms: strictly increasing toward 0, ground state `E₁ = -1`, all values in
`[-1, 0)`. Accumulation point is `0` (the ionization threshold).

## 2. Rydberg / transition gaps `1/m² - 1/n²`

For `m = 1` (Lyman) and `m = 2` (Balmer):

- `E_{2→1} = 1 - 1/4 = 3/4`
- `E_{3→2} = 1/4 - 1/9 = 5/36`

Both positive, confirming `photon_energy_pos`, and each `< 1/m²`
(`3/4 < 1`, `5/36 < 1/4`), confirming `photon_energy_lt_series_limit`.

## 3. Shell degeneracy `∑_{l=0}^{n-1}(2l+1) = n²`

Computed `(∑_{l<n}(2l+1), n²)` for `n = 0..4`:
`[(0,0), (1,1), (4,4), (9,9), (16,16)]` — exact match (sum of first `n` odd
numbers is `n²`). This is the orbital degeneracy of shell `n`. (OEIS A000290,
the squares; partial sums of A005408, the odd numbers.)

## 4. Selection-rule sanity checks

- `dipoleAllowed 1 0 0 0` (2p → 1s, Lyman-α): allowed (Δl = 1, Δm = 0). ✓
- `dipoleAllowed l l m m'`: always false (Δl = 0 forbidden). ✓
- Any allowed transition has `l + l'` odd (parity flip). ✓

All checks were performed with `#eval` over `ℚ`/`ℕ` and then proved in Lean.
