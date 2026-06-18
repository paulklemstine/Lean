Produce exactly one new Lean 4 file in the Tropical domain, small and self-contained, with no imports or material unrelated to tropical polynomials. The file should formalize max-plus tropical polynomial evaluation on `ℝ` for coefficients indexed by `Fin (n+1)`.

Requirements:

1. Define
   `piece (a : Fin (n+1) → ℝ) (i : Fin (n+1)) (x : ℝ) : ℝ := a i + (i : ℝ) * x`.

2. Define the tropical polynomial evaluation function as the finite maximum of these affine pieces over `Finset.univ`. You may use whichever Mathlib finite-maximum construction is most reliable and keeps the file sorry-free:
   - preferred if convenient: `Finset.sup Finset.univ ...` with the order structure on `ℝ`, or
   - alternatively: `Finset.max'` applied to the image of `Finset.univ` under `fun i => piece a i x`.
   The resulting function should be named `tropPolyFun`.

3. Prove only the core foundational lemmas needed for later tropical work:
   - `piece_le_tropPolyFun`: for every `i`, `piece a i x ≤ tropPolyFun a x`.
   - `exists_piece_eq_tropPolyFun`: there exists `i : Fin (n+1)` such that `tropPolyFun a x = piece a i x`.
     (Equivalent orientation `piece a i x = tropPolyFun a x` is also fine.)

4. If the above is completed cleanly and still short, add at most two tiny explicit lemmas, for example:
   - `tropPolyFun_zero`: when `n = 0`, `tropPolyFun a x = a 0`.
   - a simple `n = 1` characterization as `max (a 0) (a 1 + x)` after rewriting indices.
   These are optional extras, not mandatory.

5. Keep the file genuinely self-contained and minimal. Do not introduce convexity, continuity, roots, Newton polygons, Hodge theory, spectral methods, or any unrelated abstractions. No theorem inventory, no comments about future work, no placeholders: provide complete compilable Lean code only.

6. Prefer robust proofs that directly exploit finite-max lemmas from Mathlib for `Finset.univ` on `Fin (n+1)`, since this index type is nonempty by construction.

Goal: a small sorry-free foundation file that can serve as the base API for later tropical polynomial developments.