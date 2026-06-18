# Summary of changes for run cce27d1d-addf-4fb8-95b4-96f40c6fa5bd
# Tight Depth Hierarchy for Inverse-Free EML Expressions

## Main Achievement

I proved the **tight depth separation theorem** for inverse-free EML expressions: **for all `D < n`, no inverse-free `EMLExpr` of `emlDepth ≤ D` can represent `iterExp n` on positive reals**. This closes the previous gap of `D + 3` down to the optimal `D + 1` threshold (i.e., `D < n` instead of `D + 3 ≤ n`).

The proof is fully formalized in Lean 4 with Mathlib, uses only standard axioms (propext, Classical.choice, Quot.sound), and contains **zero `sorry`** statements.

## Lean Proof (`Catalog/Speculative/TightDepthHierarchy/Main.lean`)

A single self-contained 448-line file with 39 formally verified theorems, including:

### New Definition: `ExpRankBound`
```
ExpRankBound f D := ∃ (C : ℝ) (k : ℕ), 0 < C ∧ ∀ x ≥ 1, |f x| ≤ iterExp D (C · x^k)
```
This classifies functions by their asymptotic growth relative to iterated exponential towers. At rank 0: polynomial growth. At rank D: D-fold iterated exponential of a polynomial.

### Key Theorems Proved

1. **Doubling Lemma** (`two_mul_iterExp_le`): For D ≥ 1 and t ≥ 0, `2 · iterExp D t ≤ iterExp D (t + 1)`.

2. **Sum Closure** (`iterExp_sum_le_iterExp`): `iterExp D s + iterExp D t ≤ iterExp D (s + t + 1)` for s, t ≥ 0.

3. **Product Closure** (`iterExp_mul_le_iterExp`): For D ≥ 1, `iterExp D s · iterExp D t ≤ iterExp D (s + t + 1)`.

4. **Growth Bound** (`invFree_expRankBound`): Every inverse-free EMLExpr `e` satisfies `ExpRankBound (e.eval) (e.emlDepth)`. Proved by structural induction using closure lemmas.

5. **Separation** (`iterExp_not_expRankBound`): For D < n, `¬ ExpRankBound (iterExp n) D`. Uses the composition `iterExp n = iterExp D ∘ iterExp (n-D)` and the fact that exp beats any polynomial.

6. **Main Theorem** (`no_invFree_repr_iterExp_of_depth_lt`): The tight depth separation.

7. **Depth Optimality** (`iterExp_depth_optimal`): `iterExp n` requires EML depth at least `n`.

8. **Strict Hierarchy** (`depth_hierarchy_strict`): For every D, `iterExp (D+1)` is representable at depth D+1 but not at depth D.

## Other Deliverables

- **ARTICLE.md**: Popular science article (no jargon, strong narrative)
- **RESEARCH_PAPER.md**: Technical research paper with full proof architecture, algorithms, and references
- **FUTURE_DIRECTIONS.md**: 5 testable conjectures including removing the inverse-free restriction and neural network depth separation
- **demo.py**: Interactive demonstrations of growth comparison, domination thresholds, doubling lemma verification, and rank testing
- **algorithms.py**: Rank certification algorithm, depth lower bound verification, expression enumeration
- **applications.py**: Symbolic regression bounds, neural network depth requirements, growth classification, compiler optimization limits
- **PACKAGE.json**: Complete JSON data package for web templating