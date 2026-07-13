# Computational Evidence — Cyclotomic Gauss-Sum Matrix Factorization

All checks below were run in Lean 4 (`#eval` / `decide`) and agree with the
formal theorems in `Catalog/Applications/GaussSumMatrixFactorization.lean`.

## 1. The factorization `A = W · D · Wᵀ`

Model: `n = 3`, ring `ℤ`, `ω = 2`, Gauss periods `η = (1, 3, 5)`.
Define `W i a = ω^(a·i)`, `D = diag η`, and
`A i j = ∑ₐ ηₐ · ω^(a·(i+j))`.

```
#eval decide (A = W * D * Wᵀ)   -- true      (A_factor)
#eval decide (Aᵀ = A)           -- true      (Amat_symm)
```

## 2. Determinant identity `det A = (det W)² · ∏ ηₐ`

Same model. `det W = ∏_{i<j}(ω^j - ω^i)` is the Vandermonde product.

```
#eval (A.det, (W.det)^2 * (η 0 * η 1 * η 2))   -- (540, 540)
#eval decide (A.det = (W.det)^2 * (η 0 * η 1 * η 2))   -- true   (Amat_det)
```

Here `W.det = (2^1-2^0)(2^2-2^0)(2^2-2^1) = 1·3·2 = 6`, so
`(det W)² · ∏η = 36 · 15 = 540`, matching `det A`.

## 3. DFT orthogonality and the refuted conjecture

`ω = 2` in `ZMod 7` is a **primitive cube root of unity** (`2³ = 1`, order 3).
Computing `Wᵀ W`:

```
#eval (W7ᵀ * W7)
-- ![![3, 0, 0],
--   ![0, 0, 3],
--   ![0, 3, 0]]
```

This equals `3 · P`, where `P` is the **reversal permutation** `a ↦ (n−a) mod n`
(`0 ↦ 0`, `1 ↦ 2`, `2 ↦ 1`), exactly as predicted by `Wmat_orthogonality`
(entry `n` iff `n ∣ a+b`, else `0`).

**Contrarian check.** The naïve conjecture `Wᵀ W = n · I` would require the
matrix `3 · I = ![![3,0,0],![0,3,0],![0,0,3]]`. The computed matrix differs in
the `(1,2)` and `(2,1)` entries (value `3`, not `0`), so the conjecture is
**false** — formalized as `WtW_ne_scalar`.

## OEIS

No new integer sequence is central to the result; the phenomena are structural
(matrix factorization and DFT orthogonality) rather than enumerative, so an OEIS
search is not applicable.
