# Computational evidence: modal fraction vs. tie ceiling

All numbers below were produced with `#eval` inside the project (Lean 4 / mathlib4 v4.28.0),
using the catalog definitions `spearmanSq`, `spearman`, `dyadicBlocks`, `weightBlocks` and the
new `modalFrac`. They are exploratory; every claim that is *asserted* in this project is proved
in `Catalog/Applications/ModalFraction*.lean` with 0 sorries.

Notation: a profile `L` of tie-class sizes with total `n = L.sum`; modal fraction
`a = max L / n`; cube-mass fraction `c = Σ mⱼ³ / n³`; ceiling `ρ = √(spearmanSq L)`, and
`ρ² = (n³ - Σ mⱼ³)/(n³ - n)`.

## 1. The envelope of the ceiling at fixed modal fraction

Asymptotically `√(1-a²) ≤ ρ ≤ √(1-a³)`. The width `w(a) = √(1-a³) - √(1-a²)` is the *capacity*
of a law swap that does not move the modal fraction, and `x(a) = √(1-a³) - (1-a)` is the extra
slack available against a fully tied second law.

| a | w(a) | x(a) |
|---|------|------|
| 0.25 | 0.02391 | 0.24216 |
| 0.50 | 0.06939 | 0.43541 |
| 0.65 | 0.09176 | 0.50169 |
| 0.70 | 0.09641 | 0.51056 |
| 0.75 | 0.09891 | 0.51035 |
| 0.80 | 0.09857 | 0.49857 |
| 0.90 | 0.08469 | 0.42058 |

Readings: the equal-modal capacity peaks near `a ≈ 0.79` at `≈ 0.0987`; the cross-modal slack
peaks near `a ≈ 0.73` at `≈ 0.5103`. This is why the proved budget bracket is
`(0.51, 0.53]` and not `0`.

## 2. Counterexample family at equal modal fraction (`a = 1/2`)

`L = [m,m]` versus `L' = [m,1,…,1]` (both `n = 2m`, both `a = 1/2`):

| m | ρ(L') - ρ(L) |
|---|---------------|
| 4 | 0.065719 |
| 5 | 0.067049 |
| 6 | 0.067767 |
| 8 | 0.068478 |
| 9 | 0.068670 |
| ∞ | √(7/8) - √(3/4) = 0.069389 |

The gap *increases* with `n`; it does not vanish at rate `O(1/n)`. Formalised as
`equal_modal_ceiling_gap` (gap `> 1/20` for all `m ≥ 4`) and `no_modal_lipschitz_with_rate`.

## 3. Excess over the modal-fraction gap

`L = [3k, 1,…,1]` (a = 3/4, `n = 4k`) versus `L' = [4k]` (a' = 1, ρ' = 0); `|Δa| = 1/4`:

| k | ρ(L) - ρ(L') - Δa |
|---|--------------------|
| 1 | 0.524597 |
| 2 | 0.513763 |
| 4 | 0.511191 |
| 6 | 0.510720 |
| ∞ | 0.510345 |

So any universal additive constant must exceed `0.51` (`budget_constant_gt_fiftyone`), and the
proved upper constant `21/40 = 0.525` is within `0.015` of optimal.

## 4. The catalog law swap (balanced fixed-weight vs. uniform dyadic, bitlen `2v`)

`modalFrac (weightBlocks 10 5) = 1/2` and `modalFrac (dyadicBlocks 10) = 1/2` — exactly equal.

| v | ρ balanced | ρ uniform | Δρ |
|---|-----------|-----------|-----|
| 2 | 0.925820 | 0.927520 | -0.00170 |
| 3 | 0.920118 | 0.925931 | -0.00581 |
| 4 | 0.921273 | 0.925827 | -0.00455 |
| 5 | 0.922324 | 0.925821 | -0.00350 |
| 6 | 0.923009 | 0.925820 | -0.00281 |

Two readings:

1. The modal-fraction gap is **exactly zero** while `Δρ ≠ 0`. The conjectured budget predicts
   `|Δρ| ≤ 0 + O(1/n)`; the observed `|Δρ| ≈ 0.0058` at `v = 3` (`n ≥ 20`) is not `O(1/n)`-small
   compared with the family of §2, and the family of §2 shows movements up to `0.069` at the
   same zero modal gap. Conjecture falsified.
2. Both laws are half-modal, so the proved `half_modal_capacity` bound `0.07` applies, and the
   observed movements sit an order of magnitude inside it: the recorded `< 0.07` law-change
   capacity is a *structural* consequence of half-modality, not a coincidence of these two laws.

## 5. Counterexample hunt against the corrected statements

* Searched `m ∈ [2, 9]` for a violation of `ρ² ∈ [1-a², 1-a³+1/(n²-1)]`: none.
* Searched all profiles of the shapes `[m,m]`, `[m,1,…,1]`, `[3k,1,…,1]`, `[4k]`,
  `dyadicBlocks b` (b ≤ 12), `weightBlocks (2v) v` (v ≤ 6) for a violation of the cube-mass
  window `a³ ≤ c ≤ a²`: none. Both endpoints are attained (`window_sharp_upper`,
  `window_sharp_lower`).
* No OEIS sequence is involved: the objects here are two-parameter rational functions of the
  block sizes, not an integer sequence.
