# Future Directions: Quantum Circuit Rewriting via Tensor Distributivity

## Synthesis

The theorems established in this work — soundness, expansion correctness, and confluence modulo AC for distributive quantum circuit rewriting — form the first layer of a much deeper theory. The key unifying thread is that **distributivity is the algebraic skeleton of quantum parallelism**, and this skeleton connects at least four major mathematical traditions: term rewriting theory, categorical quantum mechanics, quantum information theory, and computational complexity. Each future direction below extends one of these connections, using the formally verified results as a springboard. The overarching vision is a unified framework where quantum circuit optimization, equivalence checking, and entanglement analysis all reduce to operations on distributive normal forms — and where the correctness of these operations is guaranteed by algebraic structure alone.

---

## Direction 1: Gate-Specific Completion and Extended Confluence

**Conjecture:** The distributive rewrite system can be extended with gate-specific identities (HH = I, CNOT² = I, T⁸ = I) while preserving confluence modulo an appropriately extended AC equivalence, via Knuth-Bendix completion restricted to the finite gate alphabet.

**Test:** Implement Knuth-Bendix completion for the extended system. Enumerate all critical pairs between distributive rules and gate-identity rules. Verify joinability of each critical pair computationally for circuits of depth ≤ 6. If completion terminates, formalize the extended confluence theorem.

**Impact:** This would yield a complete equivalence-checking procedure for the Clifford+T fragment — the most practically important gate set for fault-tolerant quantum computing. It would subsume the soundness results of existing verified optimizers (e.g., VOQC) within a single algebraic framework.

**Catalog References:** `Pythagorean/TensorSortedRewrite.lean` (sorted rewrite invariants, normalization steps), `Pythagorean/KnuthBendixCompletion.lean` (abstract completion procedure), `Pythagorean/ConvergentRewriteSystems.lean` (convergent rewrite system foundations).

**Proof Strategy:** Start from the existing `QRewriteStep` relation. Add new constructors for gate identities. For each new rule, compute all overlaps with existing rules. Show joinability by explicit rewrite derivations (critical-pair lemmas). Use the existing `expand_perm_of_rewrite` machinery to lift confluence to the extended system.

**Domain Bridges:** Term rewriting theory ↔ quantum compilation; Knuth-Bendix procedure ↔ quantum gate algebra.

**Lineage:** Extends Theorems 8–9 (expansion invariance and confluence) from the current work.

**Ambition:** Grand challenge — if completion terminates, this resolves a major open problem in certified quantum compilation.

---

## Direction 2: Categorical Semantics and Coherence

**Conjecture:** The distributive normal form corresponds to a coherence theorem in the free distributive monoidal category: every diagram in the free category on objects {gate(0), ..., gate(k)} that commutes in all semiring models is witnessed by a sequence of distributive rewrites.

**Test:** Construct the free distributive monoidal category on a finite set of generators. Verify that the normal-form functor (expansion followed by canonical ordering) is a section of the quotient functor. Check that the unit and counit of this adjunction satisfy the triangle identities up to the appropriate natural isomorphism.

**Impact:** This would establish a precise relationship between quantum circuit rewriting and categorical quantum mechanics, potentially providing the first constructive coherence theorem for distributive monoidal categories. It would also connect to the graphical calculi (string diagrams) used in categorical quantum computing.

**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (denotation as semiring homomorphism, Theorem 6).

**Proof Strategy:** Define a category `QExprCat` whose objects are types and whose morphisms are QExpr equivalence classes. Show that `denote` defines a faithful functor to the category of R-modules. Use the expansion function to construct a section, and derive coherence from the universality of the free construction.

**Domain Bridges:** Category theory ↔ circuit optimization; coherence theorems ↔ canonical forms; monoidal categories ↔ tensor networks.

**Lineage:** Extends the cross-domain bridge (Theorem 6) from algebraic to categorical.

**Ambition:** Grand challenge — coherence theorems for non-symmetric monoidal categories are an active area of research, and a distributive version would be novel.

---

## Direction 3: Entanglement-Aware Normal Forms

**Conjecture:** Distributive normalization preserves the Schmidt rank of the operator it represents: if e →* n, then schmidt_rank(denote(e)) = schmidt_rank(denote(n)). More precisely, the Schmidt decomposition of the denotation can be read off from the structure of the normal form.

**Test:** Compute the Schmidt rank of denote(e) and denote(expand(e)) for all 2-qubit circuits of depth ≤ 4. Verify equality computationally. For circuits with Schmidt rank 1 (separable operators), verify that the normal form has a product structure (all monomials factor as tensor products of single-qubit gate sequences).

**Impact:** This would be the first formal connection between algebraic rewriting and quantum entanglement theory. It would enable entanglement analysis via purely syntactic inspection of normal forms, without numerical computation of singular values.

**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (expansion soundness, Theorem 3).

**Proof Strategy:** Prove that each rewrite step preserves the bipartite structure of the operator tensor. Define a syntactic notion of "tensor factorability" for monomials (a monomial [g₁,...,gₖ] is factorable if each gᵢ acts on only one qubit). Show that the number of non-factorable monomials is an upper bound on Schmidt rank.

**Domain Bridges:** Rewriting theory ↔ quantum information theory; syntactic structure ↔ entanglement measures; normal forms ↔ Schmidt decomposition.

**Lineage:** Extends Theorem 3 (expansion soundness) to entanglement-theoretic invariants.

**Ambition:** Solid extension — the computational verification is straightforward, and the formal proof is within reach using the existing expansion machinery.

---

## Direction 4: Tropical and Idempotent Variants

**Conjecture:** The distributive normalization theory instantiates over the tropical semiring (ℝ ∪ {∞}, min, +) to produce a circuit-cost normal form: the expansion of a circuit over the tropical semiring computes the minimum-cost decomposition into sequential paths, and the confluence theorem guarantees that this minimum is independent of the rewrite order.

**Test:** Instantiate the expansion function with tropical arithmetic. Verify that the tropical normal form of a circuit assigns to each monomial its total gate cost (sum of individual gate costs), and that the minimum-cost monomial is the shortest path through the circuit DAG. Compare with Dijkstra/Bellman-Ford on the circuit graph.

**Impact:** The key insight is that the tropical instantiation transforms circuit optimization from a combinatorial search into an algebraic computation. This connects distributive rewriting to tropical geometry, optimal transport, and scheduling theory. Why now? The formal verification infrastructure (Theorems 1–9) is parametric over the semiring, so tropical instantiation is immediate.

**Catalog References:** `Pythagorean/TropicalTensorDistributivity.lean` (tropical tensor distributivity), `Pythagorean/QuantumCircuitRewriting.lean` (semiring-parametric soundness).

**Proof Strategy:** All theorems are already proved for arbitrary semirings. The tropical instantiation requires only defining the gate-cost environment `env : ℕ → ℝ_tropical` and applying the existing theorems. The connection to shortest paths follows from the well-known correspondence between tropical matrix multiplication and all-pairs shortest paths.

**Domain Bridges:** Tropical geometry ↔ circuit optimization; min-plus algebra ↔ scheduling theory; distributive normal forms ↔ shortest-path algorithms.

**Lineage:** Direct instantiation of the semiring-parametric theory (all 9 theorems).

**Ambition:** Solid extension — immediate from the existing parametric infrastructure.

---

## Direction 5: Scalable Normal Forms via Decision Diagrams

**Conjecture:** The distributive normal form admits a compressed representation as a binary decision diagram (BDD) on the monomial structure, achieving exponential compression for circuits with shared subexpressions, and the BDD operations (conjunction, disjunction) correspond exactly to the sequential and additive compositions of circuits.

**Test:** Implement BDD-based normal form representation. Compare memory usage and comparison time with explicit list representation for circuits of depth 6–10 over 4+ qubits. Measure the compression ratio and identify circuit families where BDD compression is most effective.

**Impact:** The key insight is that the monomial explosion in distributive expansion is analogous to the state explosion in model checking — and BDDs are the classical solution to state explosion. Why now? The correctness of the BDD representation follows from the confluence theorem (Theorem 9), which guarantees that the monomial multiset is canonical.

**Catalog References:** `Pythagorean/QuantumCircuitRewriting.lean` (expansion function, confluence theorem).

**Proof Strategy:** Define a BDD node type for monomials. Show that BDD canonical forms correspond to sorted monomial lists. Prove that BDD operations (apply, reduce) preserve the monomial multiset. The key lemma is that BDD reduction commutes with the expansion function.

**Domain Bridges:** Formal verification ↔ quantum compilation; BDD technology ↔ tensor network compression; model checking ↔ circuit equivalence.

**Lineage:** Extends the normalization algorithm (Definition 7) to a scalable data structure.

**Ambition:** Solid extension with grand-challenge potential — if BDD compression is effective for quantum circuits, this could enable practical equivalence checking for circuits beyond the 2-qubit fragment.
