Produce a single focused Lean 4 file formalizing an explicit matrix-growth certificate for Berggren generation of primitive Pythagorean triples. Do not develop unrelated algebraic statistics or Markov basis material.

Mathematical target:
1. Define the three standard Berggren generator matrices `A B C : Matrix (Fin 3) (Fin 3) ℤ`.
2. Define a row-sum absolute-value norm on integer matrices. Prefer a natural-valued definition if it simplifies proofs, e.g.
   `rowNormNat M = max_{i} ∑_j Int.natAbs (M i j)`
   or an integer-valued version if cleaner. Keep the API minimal and explicit.
3. Prove submultiplicativity for compatible matrices:
   `rowNorm (M ⬝ N) ≤ rowNorm M * rowNorm N`.
   Use only elementary inequalities: expand a row of `M ⬝ N`, apply `|sum| ≤ sum |.|`, then bound each inner column contribution by the row norm of `N`.
4. Compute concrete bounds for the three generators. Check the actual values by direct row computation and prove a uniform theorem of the form
   `rowNorm A ≤ 3`, `rowNorm B ≤ 3`, `rowNorm C ≤ 3`.
   Do not insist on the previous constant 2 unless it is actually true for your chosen norm.
5. Introduce words in the generators as a list / free monoid encoding, define `wordMatrix : List Generator → Matrix (Fin 3) (Fin 3) ℤ`, and prove
   `rowNorm (wordMatrix w) ≤ 3 ^ w.length`.
6. Define the root vector `root : Fin 3 → ℤ` corresponding to `(3,4,5)` and the action of a word on this vector. Define `hypotenuse` as the third coordinate.
7. Prove a clean certificate bounding the hypotenuse of any generated triple by the matrix norm, e.g.
   `hypotenuse (act w root) ≤ 5 * 3 ^ w.length`.
   A sufficient route is to prove each coordinate of `M.mulVec root` is bounded in absolute value by `rowNorm M * 5`, using that all entries of `root` have absolute value ≤ 5.
8. Derive a depth lower bound theorem: if a Berggren word produces a triple with hypotenuse `c ≥ 0`, then `c ≤ 5 * 3^n` where `n = w.length`; equivalently formulate a usable corollary that any word producing hypotenuse `c` must have length at least the least `n` with `c ≤ 5 * 3^n`. If a formalized `ceil_log` is awkward, state the bound in this equivalent existential/minimal form rather than forcing logarithms.

Engineering constraints:
- Keep the file self-contained, short, and complete.
- No theorem stubs, no unrelated sections, no placeholder abstractions.
- Prefer `Matrix (Fin 3) (Fin 3) ℤ` and explicit `Fin.cases` / `native_decide` / `norm_num` style calculations where appropriate.
- If exact primitive-triple generation is too far for one file, it is enough to formalize the matrix certificate for words in the Berggren generators acting on the root triple.
- Include clear theorem names for the dependency chain, such as `rowNorm_mul_le`, `rowNorm_generator_le`, `rowNorm_wordMatrix_le`, `hypotenuse_le_rowNorm_mul_root`, and `hypotenuse_of_word_le`.

Why this revision: the prior attempt drifted into an unrelated Markov-basis file and also targeted an implausible constant. This version is narrower, falsifiable, and aligned with a realistic Lean proof strategy.