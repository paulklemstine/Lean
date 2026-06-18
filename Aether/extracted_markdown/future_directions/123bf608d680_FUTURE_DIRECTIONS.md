# Future Directions: Multi-Sorted Quotient Optimizers

## Synthesis

The fibrational correctness theorem for sort-selective normalization reveals a deep connection between modular optimization of multi-sorted expressions and classical algebraic constructions (change of rings, Grothendieck fibrations). The five directions below extend this connection along complementary axes: (1) generalizing the number of sorts, (2) strengthening the normalizer, (3) characterizing completeness boundaries, (4) formalizing the categorical structure, and (5) applying the theory to verified compilation. Together, they trace a path from our two-sorted ring-module formalization toward a general theory of modular verification for typed algebraic systems. Each direction is grounded in specific, falsifiable predictions that can be tested computationally or formally.

---

## Direction 1: Three-Sorted Extension — Ring-Module-Homomorphism

**Conjecture:** For a three-sorted signature with sorts (Ring R, Module M, Module Homomorphism Hom(M,M)), sort-selective normalization of only the ring sort preserves evaluation correctness, provided: (a) ring congruence is compatible with scalar multiplication (as in the two-sorted case), and (b) ring congruence is compatible with the induced action on homomorphisms (if `r₁ ∼ r₂` then `r₁ • φ = r₂ • φ` for all `φ : M →ₗ[R] M`).

**Test:** Instantiate with R = ℤ/6ℤ, M = (ℤ/6ℤ)², Hom = Mat₂(ℤ/6ℤ). Generate 1,000 three-sorted expressions mixing scalar multiplication and homomorphism application. Verify that ring-literal normalization (mod 6) preserves evaluation for all test cases. Then check whether the two compatibility conditions are *independent* by finding a congruence satisfying (a) but not (b).

**Impact:** Validates that the fibrational framework scales beyond two sorts without combinatorial explosion of compatibility conditions.

**Catalog References:** `Pythagorean/MultiSortedQuotientOptimizer.lean` (TwoSortedCongruence, sort_selective_preserves_eval)

**Proof Strategy:** Extend RMExpr with `homVar`, `homApply`, `homSmul` constructors. The induction has two new cases: `homApply` requires compatibility of ring congruence with homomorphism evaluation; `homSmul` requires compatibility of ring congruence with the R-module structure on Hom(M,M).

**Domain Bridges:** Linear algebra (endomorphism rings), representation theory (R-actions on Hom spaces)

**Lineage:** Direct extension of sort_selective_preserves_eval from 2 sorts to 3 sorts

**Ambition:** Extension — solidifies the framework for practical multi-sorted applications

---

## Direction 2: Expression-Level Ring Normalization (Constant Folding)

**Conjecture:** Extending the normalizer from literal-only normalization to full *expression-level* ring normalization (e.g., `ringAdd (ringLit 2) (ringLit 3)` → `ringLit 5`) preserves the fibrational correctness theorem, provided the expression-level normalizer is sound with respect to ring evaluation.

**Test:** Implement a constant-folding normalizer that evaluates pure ring subexpressions (containing no variables) to their literal values. Verify on 5,000 random expressions that: (a) the constant-folded expression evaluates to a congruent ring value and equal module value, and (b) constant folding is idempotent.

**Impact:** Bridges the gap between the current literal-only normalizer and practical compiler optimizations, which perform constant folding and algebraic simplification.

**Catalog References:** `Pythagorean/MultiSortedQuotientOptimizer.lean` (normalizeExpr, normalize_idempotent)

**Proof Strategy:** Define `normalizeExprFull` that recursively evaluates pure-ring subtrees. The induction is similar but requires a lemma that evaluating a pure-ring subtree and then re-embedding as a literal produces a congruent value.

**Domain Bridges:** Compiler optimization (constant folding, partial evaluation), abstract interpretation

**Lineage:** Strengthens normalizeExpr from literal transformation to expression transformation

**Ambition:** Extension — moves toward practical verified optimization

---

## Direction 3: Completeness Characterization for Restricted Expression Classes

**Conjecture (Grand Challenge):** Sort-selective normalization *is* complete for observational equivalence on the class of *linear* module expressions — those built from `modVar`, `smul (ringLit n) e`, and `modAdd` only (no ring variables, no ring multiplication, no nested smul). That is, for linear module expressions `e₁` and `e₂`, if `evalExpr env e₁ = evalExpr env e₂` for all environments, then `normalizeExpr norm e₁ = normalizeExpr norm e₂` (up to commutativity and associativity of addition).

**Test:** Enumerate all linear module expressions of depth ≤ 4 over ℤ/6ℤ with 3 module variables. For each pair evaluating equally on all 6³ = 216 environments, check whether their normalizations are equivalent up to AC-rewriting. If all pairs match, the conjecture holds for this finite domain.

**Impact:** If true, this would precisely delineate the boundary between complete and incomplete sort-selective normalization, identifying the structural features (ring variables, multiplication, nesting) that cause incompleteness.

**Catalog References:** `Pythagorean/MultiSortedQuotientOptimizer.lean` (completeness_conjecture_counterexample, normalizeExpr)

**Proof Strategy:** For linear expressions, every module expression has a canonical form Σᵢ nᵢ • mᵢ. Normalization maps nᵢ to norm(nᵢ). If norm is complete, two expressions with the same evaluation must have the same normalized coefficients. This reduces to a linear algebra argument over the quotient ring.

**Domain Bridges:** Linear algebra, Gröbner basis theory (canonical forms for polynomial modules), term rewriting (confluence)

**Lineage:** Resolves the open question raised by completeness_conjecture_counterexample

**Ambition:** Grand Challenge — would establish the exact scope of sort-selective methods

---

## Direction 4: Fibrational Beck-Chevalley Condition

**Conjecture (Grand Challenge):** The normalization section satisfies the *Beck-Chevalley condition* for pullbacks along sort-preserving algebra homomorphisms. Concretely: if `φ : A → B` is a two-sorted algebra homomorphism (preserving ring and module operations), and `norm_A`, `norm_B` are sound normalizers for A and B respectively with `φ ∘ norm_A = norm_B ∘ φ` on ring elements, then for all well-sorted expressions `e`:

```
φ(evalExpr_A env_A (normalizeExpr norm_A e)) = evalExpr_B (φ ∘ env_A) (normalizeExpr norm_B e)
```

**Test:** Instantiate with A = (ℤ, ℤ³), B = (ℤ/6ℤ, (ℤ/6ℤ)³), φ = canonical projection, norm_A = id, norm_B = (· % 6). Verify on 1,000 expressions that the Beck-Chevalley square commutes.

**Impact:** Would establish that sort-selective normalization is *natural* in the categorical sense — it commutes with algebra homomorphisms. This is the key property needed for modular verification of composed systems.

**Catalog References:** `Pythagorean/MultiSortedQuotientOptimizer.lean` (sort_selective_preserves_eval, quotient_smul_exists)

**Proof Strategy:** Structural induction on expressions, with the additional hypothesis that φ is a homomorphism. Each case requires showing that φ commutes with the corresponding operation and with normalization. The smul case requires φ(r • m) = φ(r) • φ(m), which is the homomorphism property.

**Domain Bridges:** Category theory (Beck-Chevalley condition, fibered categories), topos theory, algebraic geometry (base change)

**Lineage:** Extends sort_selective_preserves_eval from a single algebra to a morphism of algebras

**Ambition:** Grand Challenge — connects computational normalization to deep categorical structure

---

## Direction 5: Application to Verified Type-Directed Partial Evaluation

**Conjecture:** For a simply-typed lambda calculus with base type `Int` and function type `Int → Int`, type-directed partial evaluation (normalizing base-type computations while leaving function-type computations symbolic) is a sound optimization, provable as an instance of sort-selective normalization with sorts = {Int, Int → Int} and cross-sort operation = function application.

**Test:** Implement a mini-language with integer arithmetic and first-class functions. Apply type-directed partial evaluation to 500 random programs. Verify that the optimized program computes the same output as the original on 100 random inputs each.

**Impact:** Would provide the first formally verified TDPE for a functional language based on multi-sorted algebraic semantics, connecting the abstract theory to practical programming language implementation.

**Catalog References:** `Pythagorean/MultiSortedQuotientOptimizer.lean` (sort_selective_preserves_eval, refinement_preserves_eval)

**Proof Strategy:** Model the simply-typed lambda calculus as a two-sorted algebra where sort 1 = Int values and sort 2 = function values. Application is the cross-sort operation. The compatibility condition becomes: if `n₁ ≡ n₂` (integer congruence), then `f(n₁) = f(n₂)` for all functions `f` in the language. This holds if the integer congruence is compatible with all built-in operations.

**Domain Bridges:** Programming language theory (TDPE, partial evaluation), denotational semantics, compiler verification

**Lineage:** Applies the abstract framework to a concrete programming language

**Ambition:** Extension — demonstrates practical applicability of the theory
