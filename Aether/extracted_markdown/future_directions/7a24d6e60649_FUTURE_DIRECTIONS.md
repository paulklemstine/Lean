# Future Directions: Tropical Normal Form Completion

## 1. Canonical Dominance Elimination via Polyhedral Comparison

**Goal**: Extend the normal form from a list of affine forms to a *canonical* list where dominated terms are removed.

An affine form `a` is **dominated** by another `b` if `a.eval x ≥ b.eval x` for all `x`. In this case, `min(a.eval x, b.eval x) = b.eval x`, so `a` can be removed without changing the semantics.

- Define a decidable dominance relation on affine forms (comparing constant and coefficient fields).
- Add a filtering pass to `normalize` that removes dominated forms.
- Sort the remaining forms lexicographically to obtain a canonical representative.
- Prove `normalize_complete`: two expressions have the same normal form if and only if they are semantically equal.

**Hypothesis**: For the natural-multiplicity fragment (coefficients in ℕ), dominance between affine forms is decidable via a finite linear programming check, making full canonicalization algorithmic.

**Cross-domain impact**: This connects to tropical convex hull computation, which is central to tropical geometry and to max-plus spectral theory.

## 2. Extension to Integer and Rational Slopes

**Goal**: Generalize from natural-number multiplicities (arising from syntactic addition of variables) to integer or rational coefficients.

- Replace `coeff : Fin n → ℕ` with `coeff : Fin n → ℤ` (or `ℚ`).
- Introduce a `sub` (tropical division) operation: `sub e₁ e₂` with semantics `eval e₁ x - eval e₂ x`.
- Prove the extended normalization theorem: every expression with subtraction still normalizes to a minimum of affine forms with integer slopes.
- This requires careful handling of the non-cancellative nature of tropical addition (the existing `tropical_add_not_cancellative` theorem constrains the approach).

**Hypothesis**: The normalization procedure extends to the full tropical semifield (ℝ, min, +, −) with rational slopes, yielding a canonical "tropical rational function" normal form.

**Cross-domain impact**: Integer slopes arise naturally in tropical curve theory (Newton polygons), optimization (piecewise-linear objectives), and neural network analysis (ReLU slopes).

## 3. Tropical Matrix Expression Normalization

**Goal**: Lift the scalar normalization theorem to matrices over the tropical semiring.

- Define `TropMatExpr (m n k : ℕ)` for tropical matrix expressions with min-plus multiplication.
- A tropical matrix normal form would represent each entry as a minimum of affine forms.
- Prove soundness: `normalize_mat_sound : TropMatExpr.eval M = TropMatNF.eval (normalize_mat M)`.
- Connect to the Kleene star (tropical matrix closure) for shortest-path computations.

**Hypothesis**: The entry-wise normalization extends to matrix products via the min-plus matrix multiplication identity, and the Kleene star has a normal form computable by tropical Gaussian elimination.

**Cross-domain impact**: This directly enables certified shortest-path algorithms, tropical spectral theory (eigenvalue computation), and formal verification of dynamic programming recurrences.

## 4. A `norm_tropical` Tactic for Lean

**Goal**: Build a Lean tactic that automatically decides tropical expression equalities by normalization.

- Implement `normalize` as a computable (non-`noncomputable`) function using decidable arithmetic.
- Reflect tropical expressions from Lean goals into `TropExpr` syntax.
- Use `normalize_sound` and `normalize_eq_implies_eval_eq` to close goals of the form `TropExpr.eval e₁ = TropExpr.eval e₂` by `native_decide` on the normal forms.
- This would be the tropical analogue of `ring`, `omega`, or `norm_num`.

**Hypothesis**: The normalization procedure is polynomial-time in the expression size (exponential in the worst case due to distributive expansion, but with heuristic pruning via dominance elimination, practical expressions normalize efficiently).

**Cross-domain impact**: This creates reusable proof automation for tropical mathematics, optimization, and neural network verification within Lean.

## 5. Decidability of Tropical Expression Equivalence

**Goal**: Prove the full decidability theorem:

```
theorem tropical_expr_decidable_eq_semantics
  {n : ℕ} (e₁ e₂ : TropExpr n) :
  Decidable (TropExpr.eval e₁ = TropExpr.eval e₂)
```

- This requires canonical normal forms (Direction 1) plus a decidable equality on canonical representatives.
- The key mathematical content is that two minima of affine forms are equal as functions if and only if they have the same set of "non-dominated" affine forms (up to permutation).
- This is equivalent to decidability of the equational theory of the tropical semiring, which is known to be decidable but has not been formally verified.

**Hypothesis**: The equational theory of the tropical semiring (ℝ, min, +) restricted to the natural-multiplicity fragment is decidable by canonical normal form comparison, and the full theory (with real coefficients) is decidable by reduction to linear programming feasibility.

**Cross-domain impact**: This would be the first formally verified decision procedure for an idempotent semiring theory, with applications to:
- Tropical polynomial identity testing
- Certified equivalence of piecewise-linear functions
- Formal tropical geometry computations
- Symbolic neural network verification (ReLU/max-affine equivalence)
