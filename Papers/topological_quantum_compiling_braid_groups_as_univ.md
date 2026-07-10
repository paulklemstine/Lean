# Computational Evidence: Reduced Burau representation of `B₄`

All computations below were carried out in Lean 4 / Mathlib over `ℚ` (exact
arithmetic, no floating point) and are reproduced by the theorems in
`BurauB4.lean`.

## 1. The representation and its matrices

For a parameter `t`, the reduced Burau representation of `B₄` is 3-dimensional
(`n − 1 = 3`), matching the "`3 × 3` matrices" of the prompt:

```
σ₁ ↦ [-t 0 0; 1 1 0; 0 0 1]
σ₂ ↦ [ 1 t 0; 0 -t 0; 0 1 1]
σ₃ ↦ [ 1 0 0; 0 1 t; 0 0 -t]
```

## 2. Braid relations hold for every parameter (small-case check)

Numerically checked `σ₁σ₂σ₁ = σ₂σ₁σ₂`, `σ₂σ₃σ₂ = σ₃σ₂σ₃`, `σ₁σ₃ = σ₃σ₁` at
`t ∈ {2, −1, 3, 5/7, 0}` — all `true`. This is then *proved for all `t`* over any
commutative ring (`braid_rel_12/23/13`).

Determinant: `det(σᵢ) = −t` for each generator (checked, then proved).

## 3. Counterexample hunt for "always universal"

The prompt suggests braiding is universal. We tested the parameter dependence.

* `t = 1`: `σᵢ² = I` for `i = 1,2,3` (checked and proved, `burau_involution_*`).
  The image is then the permutation representation of `S₄`, which is **finite**.
  → **Counterexample to "braiding is universal for every parameter".** The
  density conjecture is inherently parameter-dependent.

* `t = −1`: generators lie in `SL₃(ℤ)` (`det = 1`). We searched short words for
  an infinite-order element:
    - `σ₁σ₂σ₃` has char. poly `(x−1)(x²+1)` → eigenvalues `1, ±i` → **order 4**.
    - `σ₁σ₂` has char. poly `(x−1)(x²−x+1)` → 6th roots of unity → **finite**.
    - `σ₁σ₃ = [1 0 0; 1 1 −1; 0 0 1] = I + N` with `N ≠ 0`, `N² = 0`
      → **infinite order** (unipotent). Powers: `(σ₁σ₃)ⁿ = I + nN`, all distinct.

  This last element is the witness formalized as `braidW`; it proves the image is
  infinite (`braidW_infinite_order`, `braidW_pow_injective`).

* Non-commutativity: `σ₁σ₂ ≠ σ₂σ₁` at `t = −1` (checked, proved
  `burau_noncommute`), so the image is non-abelian.

## 4. Summary table (`t = −1`, over `ℚ`)

| element      | determinant | order       |
|--------------|-------------|-------------|
| `σ₁`         | 1           | ∞ (unipotent) |
| `σ₁σ₂`       | 1           | 6           |
| `σ₁σ₂σ₃`     | 1           | 4           |
| `σ₁σ₃`       | 1           | ∞ (unipotent) |

## 5. OEIS

No integer sequence was central to the formalized claims, so no OEIS lookup
applies. The entry sequence of `(σ₁σ₃)ⁿ` is simply `(σ₁σ₃)ⁿ_{2,1} = n`
(the identity map `n ↦ n`), which is what forces infinite order.
