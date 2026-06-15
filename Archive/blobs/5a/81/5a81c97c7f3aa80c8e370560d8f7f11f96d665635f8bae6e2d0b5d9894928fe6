Produce a small, self-contained Lean 4 file that completely removes the partiality of the previous attempt by focusing only on local theorems that are already supported by Mathlib and `Algebra.CircuitComplexity.AlgebraicCircuitComplexity`. Do not attempt a broad `NullstellensatzPIT` development. Do not state any theorem unless you can prove it completely in the file. The goal is a complete, compiling artifact with zero `sorry`s.

Create a new file, preferably under an Applications or Algebra path, with the following narrow scope:

1. Either reuse `AlgCircuit R n` directly, or define a tiny inductive language `SpExpr (n : ℕ)` with constructors `zero`, `one`, `atom : Fin n → SpExpr n`, `add`, and `mul`.
2. Define an interpretation of `SpExpr` into `MvPolynomial (Fin n) R` for `[CommSemiring R]`.
3. Define a semantic evaluation of `SpExpr` on assignments `Fin n → R`.
4. Prove the evaluation/interpretation compatibility theorem: evaluating the polynomial interpretation equals semantic evaluation.
5. Deduce the local PIT lemma: if the polynomial interpretation is `0`, then semantic evaluation is `0` for every assignment.
6. If using `AlgCircuit`, it is also acceptable to prove only the already-local theorem
   `theorem circuit_zero_poly_vanishes [CommSemiring R] (C : AlgCircuit R n) (h : C.toMvPolynomial = 0) : ∀ v, C.eval v = 0`
   and perhaps one or two tiny corollaries. But keep the file minimal and complete.

Important constraints:
- No finite-field converse PIT.
- No Schwartz–Zippel, root bounds, degree counting, or cardinality assumptions.
- No ideal membership, varieties, or Nullstellensatz statements.
- No placeholder theorem headers for future work.
- No cross-domain narrative unless directly tied to proved lemmas.
- Prefer very short proofs using existing lemmas such as `eval_eq_mvpolynomial_eval`, `map_zero`, and structural induction.

Mathematically, the file should present one precise bridge theorem: syntax-level coefficient expressions agree with polynomial evaluation, hence zero polynomial interpretation implies universal vanishing. This is enough to salvage the original concept in a falsifiable and complete way.

If you define `SpExpr`, include only the minimum API needed for the main theorem. Keep theorem names clear and local. Ensure the final file compiles standalone with imports from Mathlib and, if needed, `Algebra.CircuitComplexity.AlgebraicCircuitComplexity`.