# Future Directions: Certified Novelty Detection via Theorem Embedding Uniqueness

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update the knowledge base, and iterate. Each direction below is specific enough for a team to pick up immediately.

---

## Direction 1: Semantic Theorem Embeddings via Dependency Graphs

### Hypothesis
Theorem descriptors based on the dependency graph (which prior lemmas a theorem imports, the DAG structure of its proof) capture mathematical meaning far more faithfully than syntactic features like symbol count or arity.

### Proof Strategy
1. Define a `DependencyDescriptor` type that records the multiset of imported lemma names, proof tree depth, and branching factor.
2. Embed dependency graphs into ℝⁿ using graph kernels (Weisfeiler-Leman, random walk) and prove Lipschitz bounds for the kernel embedding.
3. Formalize in Lean: if two theorems share the same dependency graph up to isomorphism, they embed within δ. Prove the novelty certification theorem for this richer descriptor.
4. Validate empirically: extract dependency graphs from Mathlib theorems and measure whether the embedding separates semantically distinct results better than the syntactic descriptor.

### Cross-Domain Connections
- **Graph theory:** Weisfeiler-Leman graph isomorphism testing provides certified distinguishing power.
- **Sheaf theory:** `reconstruction_correct_and_unique` from the ClosureSheafLearningDuality catalog can formalize the idea that local dependency data reconstructs global theorem identity.
- **Machine learning:** Graph neural networks for theorem embeddings, with Lipschitz certification providing the δ bound.

### Key Milestone
A Lean-verified theorem: `novelty_of_dependency_graph_gap : ∀ x y, ¬ GraphIso (depGraph x) (depGraph y) → ¬ Equivalent x y`.

---

## Direction 2: Coding-Theoretic Bounds for Theorem Catalog Capacity

### Hypothesis
The maximum number of certifiably distinct theorems in a feature space of dimension n, under equivalence radius δ and a complexity budget B, is bounded by sphere-packing and volume arguments analogous to the Hamming bound in coding theory.

### Proof Strategy
1. Define `certifiedCapacity(n, δ, B)` as the maximum |K| such that K can be 2δ-separated in the ball of radius B in ℝⁿ.
2. Prove an upper bound: `certifiedCapacity(n, δ, B) ≤ Vol(B_B) / Vol(B_δ)` where B_r is the ball of radius r.
3. Prove a lower bound using greedy packing: `certifiedCapacity(n, δ, B) ≥ (B/2δ)ⁿ` (or similar).
4. Connect to `region_budget_exponential_bound` from the ArithmeticBerkovichCellDecomposition catalog to obtain exponential bounds under arithmetic complexity budgets.

### Cross-Domain Connections
- **Information theory:** Rate-distortion theory provides asymptotic bounds.
- **Combinatorial geometry:** Packing and covering problems.
- **Complexity theory:** Kolmogorov complexity of theorems as a natural "budget" measure.

### Key Milestone
A Lean-verified bound: `certified_region_count_bound : ∀ n δ B, certifiedCapacity n δ B ≤ C * (B / δ) ^ n`.

---

## Direction 3: Novelty Certificates Modulo Definitional Equality and Renaming

### Hypothesis
The equivalence relation can be tightened to account for definitional equality (α-equivalence, β-reduction, δ-unfolding) in dependent type theory, making the framework robust to trivial renamings while still detecting genuine novelty.

### Proof Strategy
1. Define `DefEquiv : Expr → Expr → Prop` capturing definitional equality in the Lean kernel.
2. Prove that DefEquiv is an equivalence relation (reflexive, symmetric, transitive).
3. Define descriptors that are invariant under DefEquiv: features that do not change under variable renaming, unfolding definitions, or β-reduction.
4. Prove the embedding soundness axiom: `DefEquiv x y → dist(E x, E y) = 0` (exact invariance, not approximate).
5. This yields a stronger certification: any positive distance certifies non-equivalence.

### Cross-Domain Connections
- **Type theory:** De Bruijn indices, normalization by evaluation.
- **Proof theory:** Cut elimination as a canonical form.
- **Algebraic invariant theory:** `krull_height_theorem_security_prime` as inspiration for invariants that detect structural differences.

### Key Milestone
A tactic `certify_novelty` that, given a theorem term, computes its DefEquiv-invariant descriptor, compares to a catalog, and returns a proof of `Novel`.

---

## Direction 4: Cryptographic Commitments to Theorem Identity

### Hypothesis
A novelty certificate can be combined with a cryptographic hash commitment to create an **unforgeable priority claim**: proof that a novel theorem existed at a certain time, without revealing its content.

### Proof Strategy
1. Define `Commit(desc, nonce) := Hash(desc || nonce)` as a commitment to a theorem descriptor.
2. Prove: `Commit(x, n₁) = Commit(y, n₂) → x = y` (under collision resistance).
3. Combine with novelty certification: `Commit(x, n) ∧ Novel(K, x) → PriorityClaim(x, timestamp)`.
4. Formalize the security model: an adversary who sees the commitment cannot determine which theorem is committed (hiding), and cannot produce a valid opening for a different theorem (binding).
5. Connect to `krull_height_theorem_security_prime`: algebraic invariants as commitment schemes.

### Cross-Domain Connections
- **Cryptography:** Hash-based commitments, zero-knowledge proofs.
- **Blockchain:** Timestamped commitments for priority claims.
- **Intellectual property:** Formal foundations for mathematical IP.

### Key Milestone
A protocol specification and security proof: `commitment_binding : ∀ x y n₁ n₂, Commit x n₁ = Commit y n₂ → x = y`.

---

## Direction 5: Self-Improving Theorem Provers with Novelty-Guided Search

### Hypothesis
Automated theorem provers that maintain a live novelty catalog and preferentially explore directions with high novelty scores will discover more genuinely new results per unit of computation than undirected search.

### Proof Strategy
1. Define a **novelty-weighted search heuristic**: when choosing which subgoal to explore, weight by `noveltyScore(candidate_descriptor, current_catalog)`.
2. Implement in a tactic framework: after proving a lemma, compute its descriptor, check novelty, and add to the catalog if certified novel.
3. Prove a **monotonicity theorem**: as the catalog grows, the novelty score of any fixed candidate can only decrease (since the catalog can only get closer).
4. Prove a **convergence theorem**: under boundedness of the feature space, the catalog saturates — eventually no new certifiably novel theorems exist in the space.
5. Formalize: `catalog_saturation : ∀ ε > 0, ∃ N, ∀ K with |K| ≥ N and K separated, ∀ x, nearestDist(x, K) ≤ ε`.

### Cross-Domain Connections
- **Reinforcement learning:** Novelty-seeking exploration (curiosity-driven RL).
- **Information gain:** Optimal experiment design.
- **Complexity theory:** Bounds on the number of "interesting" theorems of bounded complexity, via `region_budget_exponential_bound`.

### Key Milestone
A prototype automated discovery system that maintains a catalog, certifies each discovery, and reports the certified discovery rate over time.

---

## Summary Table

| Direction | Domain Bridge | Key Theorem | Difficulty | Impact |
|-----------|--------------|-------------|------------|--------|
| 1. Dependency graph embeddings | Graph theory ↔ Proof theory | Dependency gap ⇒ non-equivalence | Medium | High |
| 2. Coding-theoretic capacity | Information theory ↔ Metric geometry | Packing bound on catalog size | Medium | High |
| 3. Modulo definitional equality | Type theory ↔ Algebraic invariants | Exact invariance under DefEquiv | Hard | Very High |
| 4. Cryptographic commitments | Cryptography ↔ Formal verification | Binding + hiding for theorem identity | Medium | High |
| 5. Novelty-guided search | RL/exploration ↔ Proof search | Catalog saturation theorem | Hard | Very High |
