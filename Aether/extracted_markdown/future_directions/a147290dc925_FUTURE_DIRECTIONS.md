# Future Directions: Categorical Coherence from Confluent Rewriting

## Synthesis

The results in this cycle establish that monoidal coherence is a theorem of confluent rewriting: the oriented structural rules (associativity, left/right unit) form a terminating, confluent system whose unique normal forms decide structural equivalence. This opens five research directions that extend the completion-theoretic methodology to richer algebraic structures, connect to topology and quantum computing, and aim at a fully automated coherence pipeline. The unifying theme is that **coherence phenomena across mathematics and computer science are instances of the same rewriting meta-theorem**, and the tools of Knuth-Bendix completion provide the algorithms to detect, verify, and exploit them.

---

## Direction 1: Complete Characterization of Symmetric Monoidal Coherence

**Conjecture:** Two tensor expressions are equivalent under symmetric monoidal structural laws (associativity + unit + braiding) if and only if their flattened leaf lists are permutations of each other. Formally:

```
∀ a b : TensorExpr Obj,
  EqvGen SymMonoidalStep a b ↔ List.Perm (flatten a) (flatten b)
```

**Test:** Enumerate all tensor expressions of size ≤ 10 over 3 variables. For each pair, compute: (1) structural equivalence by bounded rewriting (BFS with depth limit 20), (2) leaf-list permutation. Search for a discrepancy. A single counterexample disproves the conjecture; exhaustive agreement up to size 10 provides strong evidence.

**Impact:** A complete proof would give the first machine-verified characterization of symmetric monoidal coherence in purely combinatorial terms. It would connect categorical algebra to the representation theory of the symmetric group and unlock efficient decision procedures for symmetric structural equivalence.

**Catalog References:** `Pythagorean/CategoricalCoherence.lean` (symmetric_equiv_implies_perm, SymMonoidalStep), `Pythagorean/HigherOrderCompletion.lean` (equiv_iff_joinable framework).

**Proof Strategy:** The forward direction is proved. For the reverse, the key step is showing that any transposition `swap(var xᵢ, var xⱼ)` in a right-associated expression can be realized by a sequence of structural moves. This requires proving that swaps "bubble" through right-associated chains, analogous to bubble sort being expressible as adjacent transpositions in the symmetric group.

**Domain Bridges:** Combinatorics (permutation groups), representation theory.

**Lineage:** Extends `symmetric_equiv_implies_perm` from this cycle.

**Ambition:** 🔴 Grand challenge — requires new techniques for the converse direction.

---

## Direction 2: Automated Critical-Pair Coherence Pipeline

**Conjecture:** For any finitely presented structural category whose rewrite system is (1) left-linear, (2) terminating (via a user-supplied well-founded measure), and (3) has all critical pairs joinable, the category is coherent. Moreover, there exists a meta-program that takes structural rules as input and outputs a machine-checkable coherence proof.

**The key insight is** that the critical-pair methodology (Knuth-Bendix) can be turned into a verified proof generator: instead of running completion as an unverified algorithm, each step produces a certificate (critical pair + joinability witness) that is independently checkable.

**Why now?** The current work demonstrates the pattern for the monoidal case. The generalization requires parameterizing over the rule set and implementing certified critical-pair enumeration — both achievable with current Lean 4 metaprogramming.

**Test:** Implement the pipeline for three test cases: (1) monoidal categories (our current system), (2) braided monoidal categories (add σ²=id), (3) cartesian categories (add diagonal and projection). Verify that the pipeline produces correct coherence proofs for each.

**Impact:** Would make coherence proofs fully automatic for a wide class of algebraic structures, eliminating the need for ad hoc arguments.

**Catalog References:** `Pythagorean/HigherOrderCompletion.lean` (master_pipeline, ho_word_problem_decidable), `Pythagorean/HOCriticalPairs.lean` (enumerateCriticalPairs, localConfluence_of_joinable_criticalPairs).

**Proof Strategy:** Generalize the `HoSystem` framework to support first-order structural rules with congruence closure. Implement `enumerateCriticalPairs` for the structural rule format. Prove Newman's lemma in the general setting and compose with the coherence-from-confluence theorem.

**Domain Bridges:** Automated theorem proving, Knuth-Bendix completion, compiler verification.

**Lineage:** Extends `coherence_of_critical_pairs` and the `HigherOrderCompletion` pipeline.

**Ambition:** 🟡 Solid extension — builds directly on existing infrastructure.

---

## Direction 3: Higher-Dimensional Coherence via Higher-Order Rewriting

**Conjecture:** The coherence of higher monoidal structures (bicategories, tricategories, (∞,n)-categories) can be systematically derived from the confluence of higher-dimensional rewriting systems, where:
- 0-cells are objects
- 1-cells are structural morphisms
- 2-cells are structural 2-isomorphisms (coherence data for coherence data)
- k-cells at each level are normal forms of a (k-1)-dimensional confluent system

**The key insight is** that higher coherence is iterated confluence: the coherence isomorphisms at level k are the normal forms of a rewriting system at level k+1, and the coherence of *those* isomorphisms comes from confluence at level k+2, and so on.

**Why now?** The 1-categorical case is now machine-verified. Lean 4's universe polymorphism and dependent types provide the expressiveness to define n-dimensional rewriting systems inductively.

**Test:** Formalize the 2-categorical case: define 2-cells between associator paths (the Mac Lane pentagon and triangle diagrams), orient them as rewrite rules on 2-cell expressions, and prove confluence. This would give the first machine-verified 2-coherence theorem derived from rewriting.

**Impact:** Would open a systematic approach to higher coherence, replacing the increasingly complex combinatorial arguments used in the theory of weak n-categories.

**Catalog References:** `Pythagorean/CategoricalCoherence.lean` (coherence_of_confluent_general), `Pythagorean/HigherOrderCompletion.lean` (ho_word_problem_decidable).

**Proof Strategy:** Define `TensorExpr₂` as paths of structural rewrites, with 2-cells as path equivalences. Orient the Mac Lane diagrams as 2-rewrite rules. Prove flatten₂ invariance and normal form existence at the 2-cell level.

**Domain Bridges:** Algebraic topology (A∞-spaces, operads), homotopy type theory.

**Lineage:** Extends the 1-categorical coherence theorem to higher dimensions.

**Ambition:** 🔴 Grand challenge — paradigm-shifting if achieved.

---

## Direction 4: Coherence for Quantum Circuit Optimization

**Conjecture:** The structural equivalences in categorical quantum mechanics (wire rebracketings, unit wire insertions/deletions, and in the symmetric case, wire swaps) form a confluent rewriting system whose normal forms provide canonical circuit layouts. Moreover, extending the structural rules with gate-specific simplifications (e.g., H² = I, CNOT involution) preserves coherence if the extended system remains confluent.

**The key insight is** that quantum circuit optimization can be decomposed into structural simplification (which is always coherent by our theorem) and computational simplification (which requires separate confluence analysis). The structural layer provides a guaranteed-correct canonicalization that can be composed with any confluent computational optimizer.

**Why now?** Quantum computing frameworks need certified circuit equivalence checkers. Our normalization algorithm provides the structural layer; the challenge is extending it to include computational gates while maintaining confluence.

**Test:** Implement a quantum circuit canonicalizer that: (1) normalizes wire groupings using our monoidal normalizer, (2) applies gate simplification rules, (3) checks confluence of the combined system via critical-pair analysis. Test on circuits from the QASMBench benchmark suite.

**Impact:** Would provide the first formally verified quantum circuit canonicalization algorithm with coherence guarantees.

**Catalog References:** `Pythagorean/CategoricalCoherence.lean` (normalizeMonoidal, coherence_of_confluent), `Pythagorean/ConvergentRewriteSystems.lean`.

**Proof Strategy:** Model quantum circuits as morphisms in a symmetric monoidal category with additional generators (gates). Define the combined rewrite system (structural + computational). Use the critical-pair pipeline from Direction 2 to check confluence.

**Domain Bridges:** Quantum computing, categorical quantum mechanics, circuit optimization.

**Lineage:** Extends the monoidal coherence theorem to quantum circuit categories.

**Ambition:** 🟡 Solid extension with high practical impact.

---

## Direction 5: Coherence and Equality Saturation

**Conjecture:** Equality saturation (e-graphs) and confluent normalization are dual approaches to the same problem: deciding equational equivalence. Specifically, for any confluent terminating rewrite system R, the e-graph saturated with the rules of R produces exactly the equivalence classes of R, and extraction from the saturated e-graph yields the same normal forms as our normalization algorithm.

**The key insight is** that e-graphs can be seen as a "completion from below" (building up equivalence classes) while normalization is "completion from above" (collapsing expressions to canonical forms). For confluent systems, these must agree, but e-graphs can also handle non-confluent systems by maintaining multiple representatives.

**Why now?** Equality saturation has become a practical tool in compiler optimization (egg, egglog). Connecting it to the formal theory of confluent rewriting would provide correctness guarantees for e-graph-based optimizers and suggest when e-graphs are overkill (when the underlying system is confluent, normalization suffices).

**Test:** Implement both approaches (normalization and e-graph saturation) for the monoidal structural rules. Verify that they produce the same equivalence classes on expressions of size ≤ 12. Measure the performance difference: normalization should be faster (O(n) vs. potentially exponential for saturation) but saturation should handle richer, non-confluent theories.

**Impact:** Would bridge two major approaches to equational reasoning — classical rewriting theory and modern e-graph technology — providing theoretical foundations for a rapidly growing area of compiler research.

**Catalog References:** `Pythagorean/CategoricalCoherence.lean` (normalizeMonoidal, equiv_iff_normalize_eq), `Pythagorean/EqualitySaturationExtraction.lean`.

**Proof Strategy:** Define e-graph semantics formally. Show that for confluent systems, the e-graph quotient is isomorphic to the normal-form quotient. Use the coherence certificate to transfer decidability results.

**Domain Bridges:** Compiler optimization, equality saturation, program synthesis.

**Lineage:** Extends the decidability result to connect with e-graph technology.

**Ambition:** 🟡 Solid extension — bridges two active research communities.
