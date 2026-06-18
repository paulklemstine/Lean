# Summary of changes for run cc3a987f-90df-4bc5-a99e-d30174c515df
Created a single, self-contained Lean 4 file `Catalog/Tropical/MaxPlusPolyFoundation.lean` (module `Tropical.MaxPlusPolyFoundation`) providing a basic max-plus tropical polynomial foundation over `ℝ`. It compiles without `sorry` and depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Contents (in `namespace Tropical`):
- `piece (a : Fin (n+1) → ℝ) (i) (x) : ℝ := a i + (i : ℝ) * x` — the affine piece.
- `tropPolyFun (a : Fin (n+1) → ℝ) (x) : ℝ` — the max-plus tropical polynomial function, defined as `Finset.univ.sup' Finset.univ_nonempty (fun i => piece a i x)`, i.e. the finite maximum of the pieces over the nonempty index type `Fin (n+1)`.

Proved lemmas (all fully proved):
1. `piece_apply` — `piece a i x = a i + (i : ℝ) * x` by `rfl` (tagged `@[simp]`).
2. `piece_le_tropPolyFun` — each piece is `≤ tropPolyFun a x` (via `Finset.le_sup'`).
3. `exists_eq_tropPolyFun_piece` — the maximum is attained: there exists `i` with `tropPolyFun a x = piece a i x` (via `Finset.exists_mem_eq_sup'`).
4. `tropPolyFun_fin_one` — singleton case (`Fin 1`): `tropPolyFun a x = a 0`.

The file uses `import Mathlib` and adds no unrelated material. It was verified to build with `lake build Tropical.MaxPlusPolyFoundation` and confirmed sorry-free.