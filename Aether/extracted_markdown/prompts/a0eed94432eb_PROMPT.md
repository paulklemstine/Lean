Create a single Lean 4 file in the Tropical domain, and nothing else. The file should be self-contained, compile without `sorry`, and focus only on a basic max-plus tropical polynomial foundation over `ℝ`.

Target definitions:
- For `a : Fin (n+1) → ℝ`, define
  `piece (a : Fin (n+1) → ℝ) (i : Fin (n+1)) (x : ℝ) : ℝ := a i + (i : ℝ) * x`.
- Define `tropPolyFun (a : Fin (n+1) → ℝ) (x : ℝ) : ℝ` to be the maximum of the finite set `{ piece a i x | i : Fin (n+1) }`.

Important implementation guidance:
- Use the simplest robust Mathlib construction for finite maxima on `ℝ`.
- You do NOT need to force the definition through `Finset.sup` if `Finset.max'` or another finite-maximum API is easier to make compile.
- Since `Fin (n+1)` is nonempty, you can use that nonemptiness directly.
- Keep imports minimal.
- Do not include any unrelated categorical, persistence, neural, valuation, lambda-calculus, or other material.

Prove exactly these core lemmas, with complete proofs:
1. `piece` unfolds as an affine expression by `rfl`/simp-style lemmas.
2. Upper bound lemma: for every `i : Fin (n+1)`, `piece a i x ≤ tropPolyFun a x`.
3. Maximum attained lemma: for every `x`, there exists `i : Fin (n+1)` such that `tropPolyFun a x = piece a i x`.
4. Singleton case: when the coefficient index type is `Fin 1` (equivalently `n = 0`), prove `tropPolyFun a x = a 0`.

You may add a tiny number of helper lemmas if needed, but do not expand beyond this foundation. The goal is a coherent finished formalization, not an ambitious development.

Suggested file shape:
- namespace `Tropical`
- definition `piece`
- definition `tropPolyFun`
- theorem `piece_le_tropPolyFun`
- theorem `exists_eq_tropPolyFun_piece`
- theorem `tropPolyFun_fin_one`

Be careful to choose theorem statements that match the exact API you use for maxima, so that the file is easy to complete and typecheck. Prefer a smaller theorem set that is definitely provable over a broader but fragile interface.