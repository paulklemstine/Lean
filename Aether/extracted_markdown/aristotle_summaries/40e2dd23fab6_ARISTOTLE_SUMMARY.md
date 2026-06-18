# Summary of changes for run 458a50bd-2235-40aa-a556-463a2d8412db
Created and fully proved `Catalog/Tropical/Core/TropicalConvexity.lean`, which formalizes general-degree tropical polynomials over `ℝ` as finite maxima of affine pieces.

Definitions:
- `piece a i : ℝ → ℝ := fun x => a i + (i : ℝ) * x` (the i-th affine piece).
- `tropPolyFun a : ℝ → ℝ`, the finite supremum (`Finset.univ.sup'`) over `i : Fin (n+1)` of the pieces.

Theorems proved (no `sorry`, no axioms beyond `propext`, `Classical.choice`, `Quot.sound`):
1. `tropPoly_apply` — pointwise expansion as a `Finset.sup'`.
2. `piece_le_tropPoly` — each piece is bounded above by the polynomial.
3. `tropPoly_attained` — the supremum is attained at some index.
4. `piece_mono` — each piece is monotone (slope `i ≥ 0`).
5. `tropPolyFun_mono` — the polynomial is monotone (sup' of monotone functions).
6. `piece_convexOn` — each affine piece is `ConvexOn ℝ Set.univ`.
7. `tropPolyFun_convexOn` — the polynomial is `ConvexOn ℝ Set.univ` (sup' of convex pieces).

The proofs reduce everything to standard Mathlib facts about `Finset.sup'`, monotone maps, and convex functions on `ℝ`, as requested. The file compiles cleanly with zero placeholders.