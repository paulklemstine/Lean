Produce exactly one self-contained Lean file, tentatively `Catalog/Algebra/SpExprNormalization.lean`, with no `sorry` and no unrelated declarations. Build directly on the already successful local development around a tiny arithmetic-expression syntax and multivariate polynomial evaluation. Do not introduce finite fields, Schwartz–Zippel, ideals, varieties, Nullstellensatz, valuation theory, tropical geometry, or any external algebraic-geometry machinery.

Mathematical target:
Work over `R : Type*` with `[CommSemiring R]` and fixed `n : ℕ`. Define an inductive syntax
`SpExpr n := zero | one | atom (i : Fin n) | add e f | mul e f`.
Define:
- `interp : SpExpr n → MvPolynomial (Fin n) R`
- `sem : (Fin n → R) → SpExpr n → R`
using the obvious recursion.

Main theorems to formalize:
1. The core bridge theorem:
   `eval_interp : MvPolynomial.eval fun i => v i (interp e) = sem v e`
   or the equivalent `eval₂` formulation preferred by Mathlib.
2. Extensionality through polynomial interpretation:
   `interp_congr_sem : interp e = interp f → sem v e = sem v f`.
3. Constant-expression certification:
   `interp_eq_C_imp_sem_const : interp e = MvPolynomial.C r → sem v e = r`.
4. Variable-expression certification:
   `interp_eq_X_imp_sem_var : interp e = MvPolynomial.X i → sem v e = v i`.
5. Zero-expression certification (the local PIT corollary):
   `interp_eq_zero_imp_sem_zero : interp e = 0 → sem v e = 0`.
6. A small algorithmic wrapper:
   define `samePoly (e f : SpExpr n) : Prop := interp e = interp f` and prove
   `samePoly.sound : samePoly e f → ∀ v, sem v e = sem v f`.
   If convenient and typeclass support allows, make a boolean/`Decidable` version using the existing `DecidableEq` instance on `MvPolynomial` and prove the corresponding soundness theorem.

Optional but welcome, only if straightforward and still local:
- Define `normalize (e : SpExpr n) := interp e` and prove `normalize_sound : MvPolynomial.eval v (normalize e) = sem v e`.
- Add simple examples showing `samePoly.sound` on concrete expressions.

Requirements and scope control:
- The file must compile against Mathlib as a standalone artifact.
- Keep the development tightly local and elementary.
- Do not include any second experimental file, theorem stubs, or partially written declarations.
- Prefer short induction proofs and existing `MvPolynomial` lemmas.
- The final result should be judged on this one file alone.

Deliverable quality bar:
The file should go beyond the original basic bridge by clearly exhibiting a reusable semantic-equivalence/certification pipeline: polynomial interpretation is the canonical normal form, and equality of canonical forms implies equality of expression semantics on all assignments.