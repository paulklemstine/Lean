# Computational Evidence — Matsuno μ-Extension

All computations below are reproduced inside the Lean file
`Catalog/Applications/MatsunoMuExtension.lean` and were cross-checked with `#eval`.

## 1. Local μ-weights `2^{n_ℓ}`, `n_ℓ = v₂((ℓ²−1)/8)`

| ℓ  | (ℓ²−1)/8 | n_ℓ | muWeight = 2^{n_ℓ} |
|----|----------|-----|--------------------|
| 3  | 1        | 0   | 1                  |
| 5  | 3        | 0   | 1                  |
| 7  | 6        | 1   | 2                  |
| 17 | 36       | 2   | 4                  |

A single prime with `μ = 1` therefore shifts the sharp/flat λ-difference by exactly these
weights, confirming the μ-term is genuinely prime-supported and proportional to `μ`.

Depth law check: `8·2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}`, e.g. ℓ=7: `8·2 = 16 = 2^{1+3}`.

## 2. Sharp/flat degree sequences at p = 2 (Pollack–Kobayashi type)

`flatDeg n = Σ_{i<n} 4^i`, `sharpDeg n = Σ_{i<n} 2·4^i`.

| n | flatDeg | sharpDeg | 3·flatDeg+1 | 4^n | sharp+flat+1 |
|---|---------|----------|-------------|-----|--------------|
| 0 | 0       | 0        | 1           | 1   | 1            |
| 1 | 1       | 2        | 4           | 4   | 4            |
| 2 | 5       | 10       | 16          | 16  | 16           |
| 3 | 21      | 42       | 64          | 64  | 64           |
| 4 | 85      | 170      | 256         | 256 | 256          |

Verified: `3·flatDeg n + 1 = 4^n`, `sharpDeg = 2·flatDeg`, `sharp+flat+1 = 4^n`.

## 3. Jacobsthal sequence `Jₙ₊₂ = Jₙ₊₁ + 2Jₙ`

`J`: 0, 1, 1, 3, 5, 11, 21, 43, 85, ... — **OEIS A001045** (Jacobsthal numbers).

Checks:
- `3 Jₙ = 2ⁿ − (−1)ⁿ` for n = 0..8: all hold.
- `Jₙ + Jₙ₊₁ = 2ⁿ`: 1,2,4,8,16,32,... holds.
- `J₂ₙ = flatDeg n`: J₀=0, J₂=1, J₄=5, J₆=21, J₈=85 = flatDeg 0..4. Holds.

## 4. Counterexample hunt

- `lambdaDiffMu` additivity over coprime moduli: tested with representative coprime
  square-free pairs; no counterexample.
- Strict positivity `lambdaDiff < lambdaDiffMu` whenever `μ>0` and `D` has a prime factor:
  no counterexample (it is an equivalence, `muTerm_pos_iff`).

All finite claims are discharged in Lean by `decide`/`omega`/induction, so the evidence
above is backed by machine-checked proofs, not merely numerical sampling.
