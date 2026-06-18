# Future Directions: Composable Theorem Transport

## 1. Category of Research Theories with Formal Laws

**Goal**: Elevate the `ResearchTheory`/`TheoryHom` framework into a fully certified category.

**Concrete steps**:
- Define `ResearchCategory` bundling identity, composition, and proofs of associativity and unit laws.
- Prove that `TheoryHom.comp_assoc`, `TheoryHom.id_comp`, and `TheoryHom.comp_id` (already established) constitute a strict category.
- Define *isomorphisms* of research theories: morphisms with two-sided inverses.
- Prove that isomorphic theories have identical lower-bound spectra.
- Investigate whether `TheoryDominates` forms a partial order modulo isomorphism.

**Cross-domain connections**: Category-theoretic structure enables automated reasoning about which domains can borrow results from which others, establishing a formal "knowledge graph" of mathematical disciplines.

## 2. Adjoint Theorem Transport and Galois Connections

**Goal**: Identify theory morphism pairs that form Galois connections (adjunctions), enabling bidirectional transfer.

**Concrete steps**:
- Define `TheoryAdjunction` as a pair of morphisms φ : T → U and ψ : U → T satisfying the adjunction inequality: `U.Inv (φ.toFun x) ≤ n ↔ T.Inv x ≤ ψ.toFun_inv_bound n` (or a suitable reformulation).
- Prove that adjoint pairs enable *reflection* of upper bounds (not just preservation of lower bounds).
- Instantiate with existing catalog bridges: does the height-to-cell bridge admit a right adjoint?
- Connect to Galois insertions in Mathlib's order theory for lattice-valued invariants.

**Cross-domain connections**: Adjunctions formalize the intuition that some domain translations are "lossless" — a robustness guarantee in learning theory might be *exactly* equivalent to a structural invariant in topology, not just implied by it.

## 3. Automated Bridge Search and Compositional Proof Engines

**Goal**: Formalize a graph of theories and morphisms, then prove correctness of algorithms that compose bridges to transfer theorems automatically.

**Concrete steps**:
- Define `TheoryGraph` as a finite directed graph where nodes are `ResearchTheory` instances and edges are `TheoryHom`s.
- Implement a path-finding algorithm that, given source and target theories, finds a composable chain of morphisms.
- Prove that any path in the graph yields a valid `CertifiedTransfer` via iterated composition.
- Extend to weighted graphs where edge weights represent "information loss" (gap between source and target invariants).
- Prove that shortest-path composition minimizes total information loss.

**Cross-domain connections**: This would create the first formal "theorem search engine" — given a result in spectral geometry, automatically find whether it can be transported to cryptographic hardness via a chain of certified bridges.

## 4. Invariant Compression and Minimality Under Transport

**Goal**: Show that minimality notions (Nerode minimization, spectral rank compression, sheaf coarsening) are preserved or reflected by selected morphisms.

**Concrete steps**:
- Define `Minimal` objects: elements x such that no y with strictly smaller invariant maps to the same image under all morphisms.
- Prove that surjective theory morphisms reflect minimality: if φ(x) is minimal in U, then x is minimal in T (under appropriate conditions).
- Connect to the existing `HasBoundedDepth` / `no_morphism_from_gap` theorems to show that gap theorems obstruct compression below certain thresholds.
- Instantiate with Myhill-Nerode minimization: show that the minimum-state automaton is preserved by morphisms respecting language equivalence.

**Cross-domain connections**: Compression invariants unify state minimization in automata, rank reduction in spectral methods, and network pruning in deep learning. Formal transport would show these are instances of one phenomenon.

## 5. Cross-Domain Robustness Logic

**Goal**: Create a modal logic of "certified under transport" that connects robustness in learning, observability in quantum systems, and stability in topology.

**Concrete steps**:
- Define a `RobustProperty` as a predicate that is preserved by all morphisms in a specified class (e.g., all ε-perturbation morphisms).
- Prove closure properties: intersection, union, and existential quantification over robust properties.
- Show that `HasDepthAtLeast T n` is robust for all morphism classes (since all `TheoryHom`s are depth-monotone by definition).
- Define domain-specific robustness notions (Lipschitz stability, spectral gaps, quantum error thresholds) as instances of the general framework.
- Prove that compositional transfer preserves robustness: if P is robust in T₁ and φ preserves P ⇒ Q, then Q inherits a corresponding robustness property in T₂.

**Cross-domain connections**: This would formalize the remarkable empirical observation that "robust" objects tend to remain robust under reasonable domain translations — adversarial robustness in neural networks, fault tolerance in quantum computing, and structural stability in dynamical systems may all be manifestations of a single transportable invariant.
