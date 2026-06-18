Research Brief: Submultiplicative Row-Sum Norm for Berggren Matrices

**Objective:** Formalize a submultiplicative row-sum norm on 3×3 integer matrices arising from Berggren's tree of primitive Pythagorean triples, and derive concrete bounds linking word length (depth) to the hypotenuse of the generated triple.

**Background:** The three Berggren matrices A, B, C (each 3×3 with integer entries) generate all primitive Pythagorean triples via multiplication from a root vector. Words over {A,B,C} correspond to paths in the tree. The goal is to obtain a depth/hypotenuse inequality: the length of a word (depth) is at most logarithmic in the hypotenuse of the resulting triple, plus a constant. This is a known combinatorial fact but has not been formalized in Lean with explicit matrix norm bounds.

**Definitions to formalize:**
- `Berggren.A`, `Berggren.B`, `Berggren.C` as `Matrix (Fin 3) (Fin 3) ℤ` with their standard entries.
- `rowNorm (M : Matrix (Fin 3) (Fin 3) ℤ) : ℕ` defined as `max i, ∑ j, |M i j|` (using `Int.natAbs`).
- `hypotenuse (v : Fin 3 → ℤ)` for a primitive Pythagorean triple vector (the third component).
- `wordMatrix (w : List Generator)` as the product of the corresponding matrices.

**Main theorems to prove:**
1. `rowNorm_mul_le (M N) : rowNorm (M * N) ≤ rowNorm M * rowNorm N` (submultiplicativity).
2. `generator_norms : rowNorm A ≤ 2 ∧ rowNorm B ≤ 2 ∧ rowNorm C ≤ 2` (by explicit computation, `decide` acceptable).
3. `rowNorm_wordMatrix_le (w : List Generator) : rowNorm (wordMatrix w) ≤ 2 ^ w.length` (by induction using 1 and 2).
4. `hyp_of_word_le (w) : hypotenuse (wordMatrix w *ᵥ root) ≤ (2 ^ w.length) * maxHyp` where `maxHyp` is the maximum hypotenuse among the generators applied to the root (a constant).
5. `depth_bound (w) : w.length ≤ log2 (hypotenuse (wordMatrix w *ᵥ root)) + C` for some explicit constant C (derived from 4).

**Proof strategy:** Use elementary arithmetic over ℕ and ℤ, with `Nat` and `Int` operations. The submultiplicativity proof will involve expanding matrix multiplication and using triangle inequality for absolute values. The generator norms are finite checks. The word bound is a simple induction. The hypotenuse bound follows from the row-norm bound and the fact that the hypotenuse is bounded by the row-norm of the matrix times the norm of the root vector. The depth bound is a rearrangement of the inequality.

**Requirements:** All proofs must be complete, with no `sorry` or placeholders. Use `decide` only for the finite computations on the three generator matrices. The file should be self-contained, importing only `Mathlib` for matrices and basic arithmetic.

**Catalog references:** If `Catalog/Bridges/` contains any existing definitions of Berggren matrices or theory morphisms, you may reuse them, but the focus is on the matrix norm and inequalities, not on theory morphisms. The file should be placed in `Catalog/Bridges/BerggrenMatrix.lean`.