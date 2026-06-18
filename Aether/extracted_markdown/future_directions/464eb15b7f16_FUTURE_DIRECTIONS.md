# Future Directions

## Synthesis

The completeness theorem for typed congruence closure establishes a formal bridge between three fundamental perspectives on term equivalence: algebraic (congruence closure), computational (normal forms), and algorithmic (e-graph same-class). This bridge opens five distinct research directions, ranging from immediate extensions (n-ary operations, conditional rewriting) to paradigm-shifting conjectures (categorical semantics, higher-order congruence closure). Each direction is grounded in specific catalog theorems and can be tested through concrete computational or mathematical experiments. Together, they chart a path from the current result toward a complete formal theory of equality saturation across typed, conditional, and higher-order settings.

---

## Direction 1: N-Ary Typed Congruence Closure with Heterogeneous Arguments

**Conjecture.** The congruence closure characterization theorem (`congruenceClosure_iff_nf_eq`) extends from the current unary-operation abstraction to full n-ary many-sorted signatures with heterogeneous argument lists, via a dependent heterogeneous vector (HVec) encoding of typed argument tuples.

**Test.** Formalize a `ManySignature` structure with `FunSym`, `argSorts : FunSym → List Sort`, `resultSort : FunSym → Sort`, and define `CongruenceClosureN` with an n-ary `congr` constructor. Prove `CongruenceClosureN R σ a b ↔ nf a = nf b` for compatible convergent systems. Computationally, test on 500 random many-sorted signatures (2-5 sorts, 3-10 symbols, arities 0-4) that the n-ary congruence closure partition matches the normal-form partition on all terms up to depth 4.

**Impact.** Removes the currying requirement and directly models real e-graph implementations (egg, egglog) which operate on n-ary function symbols natively.

**Catalog References.**
- `Pythagorean/TypedCongruenceClosure.lean`: `congruenceClosure_iff_nf_eq`, `Compatible`, `CongruenceClosure`
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_constant_on_eqvGen`

**Proof Strategy.** Generalize `Compatible` to `CompatibleN` using `∀ f : FunSym, ∀ args₁ args₂ : HVec (Term σ) (argSorts f), (∀ i, R (args₁[i]) (args₂[i])) → R (app f args₁) (app f args₂)`. The key lemma `eqvGen_compatible` should generalize by induction on `EqvGen`, swapping arguments one position at a time using transitivity.

**Domain Bridges.** Universal algebra (many-sorted Birkhoff theorem), SMT solvers (EUF with sorts), compiler optimization (typed IR optimization).

**Lineage.** Direct extension of Direction 1 results in `TypedCongruenceClosure.lean`.

**Ambition.** ★★★ (Solid extension — technically involved but mathematically incremental.)

---

## Direction 2: Conditional Congruence Closure and Guarded Rewriting

**Conjecture.** For conditional rewrite systems `R = {l → r | φ}` where conditions `φ` are decidable on the explored universe, the conditional congruence closure (congruence closure + condition checking) is complete for the conditional equational theory on the explored universe, provided the system is ground-convergent.

**Test.** Define `ConditionalRewriteSystem` with rules `(lhs, rhs, guard : α → Prop)` and `ConditionalCongruenceClosure` that adds a `guardedBase` constructor requiring the guard to hold. Implement in Python and test on 200 random conditional systems (2-5 conditional rules, guards involving sort checks and equality tests) that conditional congruence closure agrees with brute-force equational closure.

**Impact.** Conditional rewriting covers most practical rewrite systems (e.g., `x/x → 1 if x ≠ 0`). Formalizing completeness would directly impact SMT theory combination (Nelson-Oppen) and verified compiler passes with side conditions.

**Catalog References.**
- `Pythagorean/TypedCongruenceClosure.lean`: `congruenceClosure_le_of_compatible_equiv`, `incremental_merge_sound`
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: `SaturatedEGraphExtractor`

**Proof Strategy.** Modify the inductive definition to include guarded steps. The key challenge is handling the interaction between congruence propagation and guard evaluation: merging classes can make new guards true, triggering cascading merges. Prove a fixed-point theorem showing that iterating guard-check + merge reaches a fixed point.

**Domain Bridges.** SMT solving (theory combination), program verification (conditional optimization), abstract interpretation (guarded abstract domains).

**Lineage.** Extends `incremental_merge_sound` to conditional steps.

**Ambition.** ★★★★ (Significant extension — the guard interaction creates genuine mathematical subtlety.)

---

## Direction 3 (Grand Challenge): Higher-Order Congruence Closure

**Conjecture.** There exists a well-defined notion of "higher-order congruence closure" for simply-typed λ-calculus with β-reduction, such that the congruence closure of β-equivalence on a finite set of λ-terms (up to a given size bound) coincides with βη-equivalence, and this closure can be computed by an incremental algorithm analogous to first-order congruence closure.

**Test.** Formalize simply-typed λ-terms, define higher-order congruence closure (closing under β-reduction and congruence under λ-abstraction and application), and test computationally whether the resulting partition on all simply-typed terms of size ≤ 10 (for a fixed set of base types and constants) agrees with full βη-normalization. Any disagreement falsifies the conjecture.

**Impact.** Would enable certified equality saturation for functional programming languages and dependent type theories. Currently, higher-order e-graphs are an active research area with no formal completeness results.

**Catalog References.**
- `Pythagorean/TypedCongruenceClosure.lean`: `congruenceClosure_eq_eqvGen` (the key identification theorem to generalize)
- `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean`: `convergent_rewrite_induces_optimizer`

**Proof Strategy.** The main obstacle is that β-reduction is not a rewrite rule on first-order terms — it involves substitution. The strategy is to (a) define higher-order compatible relations using Kripke-style logical relations, (b) prove that βη-equivalence is compatible with application and abstraction, (c) show the higher-order congruence closure equals the equivalence generated by β-reduction. This may require restricting to a normalizing fragment (e.g., System F without general recursion).

**Domain Bridges.** Type theory (normalization by evaluation), functional programming (compiler optimization for Haskell/ML), proof assistants (tactic engines), category theory (cartesian closed categories).

**Lineage.** Paradigm shift from first-order to higher-order.

**Ambition.** ★★★★★ (Grand challenge — would be a major advance in the formal foundations of higher-order reasoning.)

---

## Direction 4 (Grand Challenge): Categorical Semantics of Congruence Closure

**Conjecture.** The congruence closure operation on relations is the left adjoint of the forgetful functor from the category of congruences over a fixed many-sorted signature to the category of binary relations, and this adjunction formally recovers the Birkhoff HSP theorem for varieties of algebras when instantiated to equational theories.

**Test.** Formalize the category of binary relations on a fixed set (with relation inclusion as morphisms), the category of congruences (equivalence relations compatible with a fixed set of operations), and the forgetful functor. Prove the adjunction. Then instantiate to show that the congruence closure of the rewrite relation of a convergent system generates the same variety as the equational theory. Test computationally on 100 random finite algebras (carrier size 5-20, 2-5 operations) that the generated variety (computed via HSP closure) agrees with the congruence closure partition.

**Impact.** Would provide the deepest possible mathematical foundation for equality saturation, connecting it to Lawvere's functorial semantics and enabling future work on categorical program optimization.

**Catalog References.**
- `Pythagorean/TypedCongruenceClosure.lean`: `congruenceClosure_le_of_compatible_equiv` (the minimality/universal property theorem)
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: `extraction_semantics_preserved`

**Proof Strategy.** The key is recognizing that `congruenceClosure_le_of_compatible_equiv` already proves the universal property of the congruence closure (it's the smallest compatible equivalence containing R). This IS the definition of left adjoint via the universal property. Formalize the categorical framework, then show the existing minimality theorem instantiates to the adjunction.

**Domain Bridges.** Category theory (adjunctions, monads), universal algebra (Birkhoff theorem), topos theory (quotient objects), algebraic geometry (scheme theory).

**Lineage.** Conceptual deepening of Direction 1 results.

**Ambition.** ★★★★★ (Grand challenge — would establish equality saturation within the framework of categorical algebra.)

---

## Direction 5: Quantitative Convergence Bounds for Congruence Closure Saturation

**Conjecture.** For a convergent typed rewrite system `R` with `n` function symbols of maximum arity `k` over an explored universe of `m` terms, the incremental congruence closure algorithm reaches saturation in at most `O(m² · n)` merge steps, and the total number of candidate congruence checks is at most `O(m² · n · m^k)`.

**Test.** Run the incremental congruence closure algorithm on 1000 random convergent typed rewrite systems (3-8 symbols, arities 0-3, 2-4 sorts, universe size 50-500) and measure: (a) total merge steps to saturation, (b) total candidate congruence checks, (c) wall-clock time. Fit the empirical growth rates against the conjectured bounds. Any super-polynomial family would falsify the polynomial bound conjecture.

**Impact.** Would provide the first formal complexity analysis of typed congruence closure, enabling performance guarantees for equality saturation engines and informing implementation strategies.

**Catalog References.**
- `Pythagorean/TypedCongruenceClosure.lean`: `candidate_tuples_bound`, `incremental_merge_sound`
- `Catalog/Pythagorean/EqualitySaturationExtraction.lean`: `BoundedEGraph`

**Proof Strategy.** The key insight is that the number of distinct equivalence classes can only decrease (each merge reduces the partition by one class), giving at most `m - 1` merge steps. Each merge triggers at most `n · m^{k-1}` congruence checks (one for each parent tuple containing the merged class). The total is bounded by `(m-1) · n · m^{k-1} ≤ n · m^k`. Formalize this using `Finset.card` arithmetic and the decreasing chain condition on partitions.

**Domain Bridges.** Computational complexity (amortized analysis), data structures (union-find), algorithm engineering (e-graph implementation), program optimization (compile-time bounds).

**Lineage.** Direct quantitative strengthening of `candidate_tuples_bound`.

**Ambition.** ★★★ (Solid extension — combines combinatorics with the existing algebraic framework.)
