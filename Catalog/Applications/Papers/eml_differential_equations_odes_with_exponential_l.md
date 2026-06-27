# Computational Evidence — EML Riccati Solvable Family

Supporting `EML.EMLRiccatiSolvableFamily` and `EML.EMLGaloisSolutionSpace`.

## 1. The Riccati image map `g ↦ g′ + g²` (cleared form, q = 1)

For `v = g`, `q = 1`, the cleared Riccati identity
`p′q − pq′ + p² = f·q²` reduces (since `1′ = 0`) to `g′ + g² = f`. Small cases:

| `g`      | `g′`      | `g²`        | `f = g′ + g²`        | `deg f` |
|----------|-----------|-------------|----------------------|---------|
| `X`      | `1`       | `X²`        | `X² + 1`             | 2       |
| `X²`     | `2X`      | `X⁴`        | `X⁴ + 2X`            | 4       |
| `X³`     | `3X²`     | `X⁶`        | `X⁶ + 3X²`           | 6       |
| `Xⁿ`     | `nX^{n-1}`| `X^{2n}`    | `X^{2n} + nX^{n-1}`  | 2n      |

Observations:
- `g = X` reproduces exactly the catalog witness `X² + 1`
  (`EMLKovacicSharp.riccati_evenDeg_solvable`), confirming
  `evenWitness_eq_riccati_image`.
- Every `g = Xⁿ` (`n ≥ 1`) yields an even degree `2n`, so the solvable family
  meets every even degree `≥ 2`. This is `riccati_image_natDegree` /
  `parity_decision_every_degree`.

## 2. Degree-parity decision boundary (interleaving)

| degree `d` | example coefficient        | Kovacic first step |
|------------|----------------------------|--------------------|
| 1          | `X`                        | obstructed (odd)   |
| 2          | `X² + 1 = X′ + X²`         | solvable (`v = X`) |
| 3          | `X³`                       | obstructed (odd)   |
| 4          | `X⁴ + 2X = (X²)′ + (X²)²`  | solvable (`v = X²`)|
| 5          | `X⁵`                       | obstructed (odd)   |
| 2n         | `(Xⁿ)′ + (Xⁿ)²`            | solvable (`v = Xⁿ`)|
| 2n+1       | `X^{2n+1}`                 | obstructed         |

The odd column is the catalog's `no_rational_riccati_genAiry`; the even column is
this cycle's `riccati_image_solvable`. The decision flips at every degree.

## 3. Counterexample hunt

- Claim "all even-degree coefficients are solvable" is **not** asserted (and is
  false in general — e.g. `X²` alone: `v′ + v² = X²` would need `v ≈ X` but
  `X′ + X² = X² + 1 ≠ X²`). The theorems only assert solvability of the explicit
  *image* coefficients `g′ + g²`, which is exactly what is proved.
- The odd obstruction was probed against `f = X, X³, X⁵`: no rational solution in
  every case (formalized for all `X^{2k+1}`).

## 4. First-order solution line

For `y′ = a·y`, sampling `a` symbolically: any two nonzero solutions have constant
ratio (catalog `firstOrder_ratio_isConstant`), and reconstructing `y₁ = (y₁/y₂)·y₂`
holds whenever `y₂ ≠ 0` — verified symbolically by `field_simp`, giving the full
solution-line description `firstOrder_solSpace_iff`.
