# Computational Evidence — Pfaffian Giambelli formula for shifted `t`-Schur functions

All computations below are reproduced as machine-checked Lean theorems in
`Pfaffian.lean`, `StrictPartitions.lean`, and `ShiftedTSchur.lean`; this note records
the small-case numerical evidence that guided the formalization.

## 1. Small-case Pfaffians (`k = 1`, `k = 2`)

For an alternating matrix the Pfaffian is the signed sum over perfect matchings:

* `k = 1` (`2 × 2`):  `Pf = a₀₁`,  and  `det = a₀₁²`.  ✓ (`pf2_sq_eq_det`)
* `k = 2` (`4 × 4`):  `Pf = a₀₁a₂₃ − a₀₂a₁₃ + a₀₃a₁₂`  (3 matchings, signs `+ − +`).

Determinant check (`pf4_sq_eq_det`): for the generic alternating matrix
`[[0,a,b,c],[−a,0,d,e],[−b,−d,0,f],[−c,−e,−f,0]]`,

```
det = (a f − b e + c d)²   = (Pf)²   ✓
```

Verified symbolically over `ℚ` and proved over an arbitrary commutative ring via the
hand-built `Matrix.det_fin_four` expansion + `ring`.

## 2. The `t`-deformation is quadratic with classical constant term

For a linear deformation `A + t·B` of the entries:

```
Pf(A + tB) = Pf A + t · mixedPf(A,B) + t² · Pf B
```

(`pf4_deform_expansion`).  Setting `t = 0` returns the classical Schur `Q`-function
`Pf A` (`pf4_deform_zero`).  This is the exact sense in which the shifted `t`-Schur
function generalizes the classical Schur `Q`-function.

## 3. Concrete strict realization over `ℚ`

Classical array `A = Acl` (a `4`-part strict shape), twist direction `B = Bdir`:

| quantity                     | value    |
|------------------------------|----------|
| `Pf A`  (classical, `t = 0`) | `8`      |
| `mixedPf(A,B)`               | `4`      |
| `Pf B`                       | `0`      |
| `Pf(deform t)`               | `8 + 4t` |
| `det(deform t)`              | `(8+4t)²`|

So `Pf(deform 1) = 12 ≠ 8 = Pf(deform 0)` — the deformation is **non-constant**
(`tSchur_nonconstant`), ruling out a vacuous formalization.

## 4. Index combinatorics (strict partitions)

For a strict partition `λ₁ > ⋯ > λ_k`, the shifted contents `λ_i − i` are strictly
decreasing, hence the fermionic-mode labels are pairwise distinct
(`shiftedContent_strictAnti`, `shiftedContent_injective`).

## 5. OEIS sequences

* Number of partitions of `n` (`p(n)`): `1, 1, 2, 3, 5, 7, 11, …` — **A000041**;
  appears via the catalog identity `|ConjClasses(Sₙ)| = p(n)`.
* Number of strict / distinct-part partitions of `n` (`q(n)`): `1, 1, 1, 2, 2, 3, 4,
  5, 6, 8, …` — **A000009**; these are the labels of the projective characters where
  Schur `Q`-functions live, and `q(n) ≤ p(n) = |ConjClasses(Sₙ)|`
  (`card_strictPartitions_le_card_conjClasses`).

## 6. Counterexample hunt

* "Is `Pf² = det` for merely *skew* (non-zero-diagonal) matrices?" — No in general
  outside characteristic `≠ 2`; the formalized statements correctly require the
  **alternating** hypothesis (zero diagonal).  The sign law `pf4_swap12_neg` needs
  only skewness, matching theory.
* "Is the `t`-deformation ever constant?" — Not for `mixedPf ≠ 0`; the explicit
  example certifies non-triviality.
