# Future Directions: Many-Sorted Convergent Optimization

## Synthesis

The many-sorted master theorem (`ms_nf_preserves_eval`) establishes that convergent normalization preserves denotation across all sorts in every sound algebra. This opens five research directions, each connecting the formal framework to a new mathematical or computational domain. The first two directions extend the theory internally (to higher-order types and to tensor sorts), while the latter three connect outward to representation theory, category-theoretic foundations, and scientific computing. Together, they form a coherent program: building a universal formal substrate for typed certified algebraic optimization.

---

## Direction 1: Simply-Typed Convergent Normalization

**Conjecture:** The many-sorted master theorem generalizes conservatively to simply-typed lambda calculi with algebraic base types. When restricted to first-order operation symbols with no binders, the higher-order semantic preservation theorem reduces exactly to `ms_nf_preserves_eval`.

**Test:** Implement a simply-typed syntax where `Sort := SimpleType` (base types plus function types). Define typed β-reduction alongside algebraic rewrite rules. Verify that on the first-order fragment (no λ-abstractions, no function types), the typed normalizer agrees with the many-sorted normalizer on 10,000 random terms.

**Impact:** This would unify the convergent rewrite framework with normalization-by-evaluation and typed lambda calculus semantics, creating a single formal platform for both algebraic simplification and functional program optimization.

**Catalog References:**
- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`: `ms_nf_preserves_eval`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_preserves_eval`, `CertifiedNormalizer`

**Proof Strategy:** Define `SimpleType := BaseSort | Arrow SimpleType SimpleType`. Interpret terms via a logical-relations argument over the type structure. Show that the first-order restriction collapses `SimpleType` to `BaseSort`, recovering the many-sorted definitions.

**Domain Bridges:** Type theory ↔ universal algebra ↔ compiler optimization

**Lineage:** Extends `ms_nf_preserves_eval` via Strategy C (logical relations)

**Ambition:** Grand challenge — would connect rewriting theory to the foundations of typed computation

---

## Direction 2: Tensor-Sorted Extension for Scientific Computing

**Conjecture:** Extending the sort system to include scalar, vector, and rank-2 tensor sorts yields a convergent rewrite fragment whose normal forms preserve bilinear energy expressions `E = v^T A v` across all tested numerical models.

**Test:** Define a three-sorted signature with sorts `{Scal, Vec, Mat}` and operations including matrix-vector multiplication, bilinear pairing, and tensor product. Implement 6-8 rewrite rules (including `A(v+w) → Av + Aw`, `(A+B)v → Av + Bv`, `α(Av) → (αA)v`). Generate 5,000 random tensor expressions and verify semantic preservation in models over ℚ and ℤ.

**Impact:** Would demonstrate that the many-sorted framework supports symbolic simplification in physics-inspired tensor calculi, opening a path to certified optimization in computational mechanics and quantum mechanics.

**Catalog References:**
- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`: `ModuleSig`, `ModRewrite`, `modRewrite_sound`

**Proof Strategy:** Extend `ModuleSig` with a `Mat` sort and matrix operations. Prove soundness of new rules using Mathlib's `Matrix` API. The many-sorted master theorem applies directly since it is parametric in the signature.

**Domain Bridges:** Physics ↔ linear algebra ↔ scientific computing

**Lineage:** Extends the module instantiation (Theorems 4-5) to higher-rank tensors

**Ambition:** Solid extension — builds directly on existing infrastructure

---

## Direction 3: Sortwise Canonical Forms and the Word Problem

**Conjecture:** For the two-sorted module rewrite system, every term of vector sort reduces to a unique linear-combination normal form: a sum of scalar-vector products where each vector variable appears at most once.

**Test:** Generate 10,000 random vector terms and normalize them from two different rewrite schedules (left-to-right vs. right-to-left). Compare the resulting normal forms syntactically. A single counterexample (two different normal forms from the same term) disproves confluence/canonicity.

**Impact:** If true, this solves the word problem for the free module over a free ring, giving a decision procedure for module expression equivalence. This would be a significant result in computational algebra.

**Catalog References:**
- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`: `ModRewrite`, `MSCertifiedNormalizer`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_unique_of_confluent`

**Proof Strategy:** Prove confluence of `ModRewrite` using a critical-pair analysis (Newman's Lemma). Show that normal forms are syntactically unique by induction on term structure, leveraging the fact that the distributivity rule is the only non-trivial rule and it strictly decreases the "smul-nesting depth."

**Domain Bridges:** Universal algebra ↔ computational algebra ↔ automated reasoning

**Lineage:** Extends confluence analysis from `nf_unique_of_confluent`

**Ambition:** Solid extension — precise and falsifiable

---

## Direction 4: Representation-Theoretic Invariant Detection

**Conjecture:** In module expressions carrying a finite group action, normal forms statistically increase the detection rate of invariant subexpressions (vectors fixed by all group elements) compared with raw syntax.

**Test:** Implement a model with `R = ℤ[G]` (group ring of a small group like `S₃` or `ℤ/3ℤ`) acting on a 3-dimensional representation. Generate 5,000 random expressions, normalize, and compare the rate at which invariant subexpressions (evaluating to vectors in the fixed subspace `V^G`) are syntactically identifiable before and after normalization.

**Impact:** Would demonstrate that algebraic normalization has representation-theoretic content: it doesn't just simplify — it reveals symmetry structure. This connects the rewrite framework to a deep mathematical domain.

**Catalog References:**
- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`: `moduleAlgebra`, `modRewrite_sound`

**Proof Strategy:** Define the group algebra as a concrete ring and the representation as a concrete module. The many-sorted master theorem guarantees that evaluation is preserved, so invariant detection rates should be equal (preserved invariants). The hypothesis is that normalized *syntax* makes invariants more *syntactically apparent*.

**Domain Bridges:** Representation theory ↔ module theory ↔ symbolic computation

**Lineage:** Builds on the module instantiation (Theorems 4-5)

**Ambition:** Grand challenge — connects algebra to symmetry detection

---

## Direction 5: Category-Theoretic Foundations via Initial Algebra Semantics

**Conjecture:** The many-sorted master theorem can be reformulated as a statement about initial algebras in a presheaf category over the sort set: the normal-form map is the unique homomorphism from the initial algebra to the quotient algebra modulo the rewrite congruence, and semantic preservation follows from the universal property.

**Test:** Formalize the category of `S`-sorted sets (presheaves on the discrete category `S`) in Lean 4. Define the initial `Sig`-algebra as the term algebra. Prove that the rewrite congruence defines a quotient algebra, and that the normal-form map factors through this quotient. Verify that the resulting theorem statement is definitionally equivalent to `ms_nf_preserves_eval`.

**Impact:** Would reveal the deep categorical structure underlying convergent normalization, potentially enabling generalization to rewriting in arbitrary categories (not just `Set`-valued algebras). This is the mathematically richest direction.

**Catalog References:**
- `Pythagorean/ManySortedConvergentRewriteOptimizer.lean`: `MSAlg`, `MSTerm.eval`, `ms_nf_preserves_eval`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `quotientNf`, `nf_constant_on_eqvGen`

**Proof Strategy:** Use Strategy B (family-of-quotients / fiberwise initial algebra). Regard each sort as a fiber. Show that the term system is the initial algebra in the category of `Sig`-algebras. The normal-form map is the composition of the unique homomorphism with a canonical section of the quotient.

**Domain Bridges:** Category theory ↔ universal algebra ↔ type theory

**Lineage:** Extends `quotientNf` and `nf_constant_on_eqvGen` to the many-sorted setting

**Ambition:** Grand challenge — foundational reconceptualization
