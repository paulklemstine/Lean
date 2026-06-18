# Future Directions

## Synthesis

This research cycle established the complete algebraic foundation for abstract rewrite systems: the diamond-to-confluence lifting (Strip Lemma), the Church-Rosser equivalence, normal form uniqueness and existence, the novel rewrite semilattice structure, and the compiler pass coherence theorem bridging rewriting theory with compiler verification. These results extend the existing confluence infrastructure in `Catalog/Pythagorean/ConvergentRewriteMaster.lean` (Newman's lemma, convergent normalizers) and `Catalog/Pythagorean/HigherOrderCompletion.lean` (higher-order critical pairs, bounded confluence certificates).

The most promising cross-domain connection discovered is the **rewrite semilattice ↔ lattice theory** bridge. The observation that a confluent terminating rewrite system's normal form map is precisely a closure/retraction operator opens the door to importing tools from lattice theory and order theory into rewriting, and vice versa. This is structurally analogous to the Algebra ↔ EML bridge identified in the Catalog analysis, where shared structures (lattice, order, monoid) exist without a formal connection. The rewrite semilattice provides the mathematical vocabulary to build that bridge.

The highest breakthrough potential lies in **Direction 1** (decreasing diagrams), which would remove the termination requirement from confluence and enable application to the full untyped lambda calculus, coinductive programs, and non-terminating type-level computation. The `LabeledARS` structure introduced in this cycle provides the starting point.

---

### Direction 1: Confluence Without Termination via Decreasing Diagrams

**Conjecture**: For every labeled abstract rewrite system (α, L, step) where L is well-ordered and every local peak has a decreasing diagram (all labels in the joining sequences are strictly smaller than the original peak labels), the underlying unlabeled system is confluent — without any termination hypothesis.

**Test**: (1) Formalize the decreasing diagram condition as a Lean predicate on `LabeledARS`. (2) Prove the theorem for the special case where L = ℕ and the system has finitely many rules (this is already the interesting case for applications). (3) Computationally validate: enumerate all 2-rule string rewriting systems over {a,b} with rules of length ≤ 3, assign optimal labels, check confluence of those with decreasing diagrams on strings up to length 10.

**Impact**: If true, this subsumes Newman's lemma, the Church-Rosser theorem for lambda calculus, and all known confluence criteria. It would be the most general formally verified confluence theorem. If false (which would contradict van Oostrom 1994), it would reveal a gap in the published proof.

**Catalog References**: `Catalog/Pythagorean/AbstractRewriteAlgebra.lean` (LabeledARS, DecreasingDiagram), `Catalog/Pythagorean/ConvergentRewriteMaster.lean` (newmans_lemma)

**Proof Strategy**: The key step is showing that if every local peak has a decreasing diagram, then any multi-step divergence has a decreasing diagram (by transfinite induction on the multiset of labels in the peak). This requires formalizing the multiset ordering on L (which is well-founded when L is well-ordered) and the composition of decreasing diagrams. The existing Mathlib formalization of `Multiset` and well-founded orderings should provide most of the infrastructure.

**Domain Bridges**: Rewriting ↔ Order Theory, Rewriting ↔ Lambda Calculus

**Lineage**: Builds on the LabeledARS definition from this cycle and Newman's lemma from `ConvergentRewriteMaster.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Knuth-Bendix Completion as a Certified Algorithm

**Conjecture**: The Knuth-Bendix completion procedure, when it terminates, produces a rewrite system that is a RewriteSemilattice for the input equational theory. Formally: given equations E and a termination ordering ≻, if KB(E, ≻) = R (a finite confluent terminating system), then R is a RewriteSemilattice whose nf map decides the word problem for E.

**Test**: Implement KB completion in Lean with a fuel parameter. Prove that the output system (when fuel suffices) satisfies the RewriteSemilattice axioms. Test on standard examples: group theory axioms, Boolean algebra, ring axioms.

**Impact**: A certified KB completion procedure would provide a push-button tool for deciding equational theories. Combined with the joinable_iff_nf_eq theorem, it would give a verified decision procedure for any equational theory where KB terminates.

**Catalog References**: `Catalog/Pythagorean/AbstractRewriteAlgebra.lean` (RewriteSemilattice, joinable_iff_nf_eq), `Catalog/Pythagorean/ConvergentRewriteMaster.lean` (CertifiedNormalizer, convergent_nf_preserves_eval)

**Proof Strategy**: (1) Define KB steps as operations on pairs (equations, rules). (2) Prove each KB step preserves the equational theory. (3) Prove termination of KB implies confluence + termination of the output. (4) Construct the RewriteSemilattice from the output. The main difficulty is the termination proof for KB itself, which requires showing that the multiset of equation sizes decreases.

**Domain Bridges**: Algebra ↔ Computation, Rewriting ↔ Automated Reasoning

**Lineage**: Builds on RewriteSemilattice and the CertifiedNormalizer from ConvergentRewriteMaster.

**Ambition**: extension

---

### Direction 3: Tropical Rewrite Algebras and Valuation-Weighted Confluence

**Conjecture**: A rewrite system with tropical semiring-weighted rules (where rule weights represent computational cost) admits a notion of *weighted confluence*: among all common reducts, there exists one of minimal total weight, computable by a tropical shortest-path algorithm on the rewrite graph.

**Test**: Define a `TropicalRewriteSemilattice` extending `RewriteSemilattice` with a weight function w : step → ℝ≥0 ∪ {∞}. Prove that the minimum-weight common reduct exists and equals the tropical product of individual step weights. Computationally validate on the distributive law system (where exponential blowup occurs) — the tropical analysis should predict which reduction paths minimize size.

**Impact**: This creates a bridge between rewriting theory and tropical geometry, a currently unexplored connection. It could provide new tools for analyzing the *complexity* of normalization, not just its correctness. The prediction is that the tropical structure captures the "geometry" of the rewrite graph in a way that classical confluence misses.

**Catalog References**: `Catalog/Pythagorean/AbstractRewriteAlgebra.lean` (RewriteSemilattice), `Catalog/Pythagorean/TropicalBridge/SheafPersistence.lean` (tropEvtProfile_below_all_critical), `Catalog/Tropical/` (tropical semiring infrastructure)

**Proof Strategy**: The minimum-weight common reduct is a shortest path problem in the rewrite graph. Use Dijkstra's algorithm formalized over the tropical semiring. The key lemma is that confluence guarantees the existence of a finite path between any two reducts, so the shortest path is well-defined.

**Domain Bridges**: Rewriting ↔ Tropical Geometry, Computation ↔ Optimization

**Lineage**: Builds on RewriteSemilattice from this cycle and tropical infrastructure from the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Higher-Order Rewrite Semilattices

**Conjecture**: The RewriteSemilattice structure lifts to simply-typed higher-order rewrite systems modulo β: if a higher-order system E has all critical pairs joinable (AllCriticalPairsJoinableGlobal) and is terminating, then the bounded normalization function `boundedNormalize` from `HigherOrderCompletion.lean` induces a RewriteSemilattice on closed terms.

**Test**: Construct a concrete RewriteSemilattice instance for the simply-typed lambda calculus with β-reduction (no additional rules). Verify that the nf_idempotent and nf_is_nf axioms hold using the β-normalization algorithm.

**Impact**: This would unify the first-order algebraic theory (this cycle) with the higher-order completion theory (previous cycle), providing a single algebraic framework for both. The joinable_iff_nf_eq theorem would then give a decision procedure for βη-equality of simply-typed lambda terms.

**Catalog References**: `Catalog/Pythagorean/HigherOrderCompletion.lean` (AllCriticalPairsJoinableGlobal, boundedNormalize, ho_completion_pipeline_sound), `Catalog/Pythagorean/AbstractRewriteAlgebra.lean` (RewriteSemilattice)

**Proof Strategy**: The main technical challenge is showing that `boundedNormalize` with sufficient fuel computes actual normal forms (not just approximations). This requires a fuel adequacy lemma: for terminating systems, there exists a fuel bound sufficient for any term. The existing `TerminatingOnClosedUpTo` predicate provides the starting point.

**Domain Bridges**: Rewriting ↔ Type Theory, Algebra ↔ Logic

**Lineage**: Builds directly on both this cycle's RewriteSemilattice and the HigherOrderCompletion infrastructure.

**Ambition**: extension

---

### Direction 5: Machine Learning Optimization Confluence

**Conjecture**: In neural network training, common optimization transformations (batch normalization fusion, operator fusion, quantization) form a confluent system when applied to computation graphs. Formally: define a rewrite system on DAG-structured computation graphs where rules represent standard ML graph optimizations, and prove that the system is confluent (or identify specific non-confluent rule pairs).

**Test**: Define 5-8 common ML optimization rules as rewrite rules on a simple expression language (Add, Mul, BatchNorm, Conv, ReLU). Enumerate critical pairs. Check joinability. If confluent, construct a RewriteSemilattice; if not, identify the minimal non-confluent subset.

**Impact**: If confluent, this would prove that ML compiler frameworks (TVM, XLA, MLIR) produce deterministic outputs regardless of optimization order — a property currently assumed but not verified. If non-confluent, the specific failure cases would guide ML compiler developers to fix or constrain their optimization passes.

**Catalog References**: `Catalog/Pythagorean/AbstractRewriteAlgebra.lean` (semantic_determinism, sound_pass_compose), `Catalog/MachineLearning/` (ML infrastructure)

**Proof Strategy**: Start with a minimal expression language. Define each optimization as a rewrite rule with a soundness proof (semantic preservation). Apply the critical pair algorithm. Use Newman's lemma (from ConvergentRewriteMaster) if the system is terminating.

**Domain Bridges**: Rewriting ↔ Machine Learning, Algebra ↔ MachineLearning

**Lineage**: Builds on compiler pass coherence from this cycle and the ML infrastructure in the Catalog.

**Ambition**: extension
