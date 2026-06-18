# Future Directions: Equality Saturation Extraction Correctness

## Synthesis

The theorems established in this work — extraction soundness, certified cost-optimal extraction, and the quotient bridge to normal forms — open a unified research program connecting term rewriting, quotient semantics, and optimization theory. The five directions below form a coherent arc: Direction 1 extends the algebraic framework to handle the key algorithmic ingredient missing from our theory (congruence closure). Direction 2 pushes the theory into higher-order settings where equality saturation is most needed but least understood. Direction 3 attacks the fundamental complexity question of saturation depth. Direction 4 applies the theorems to produce verified compiler infrastructure. Direction 5 ventures into cross-domain territory, connecting extraction to physical optimization and categorical semantics.

Each direction is grounded in specific catalog theorems and can be falsified by concrete experiments.

---

## Direction 1: Congruence Closure Completeness for Typed E-Graphs

**Conjecture**: For a convergent rewrite system R on a typed first-order term algebra with n function symbols of bounded arity k, congruence closure on a saturated e-graph can be computed incrementally with at most O(n^k) merge operations per saturation step, and the resulting e-graph satisfies the completeness hypothesis of `SaturatedEGraphExtractor.complete_sameClass`.

**Test**: Implement typed congruence closure over random first-order signatures (3-10 function symbols, arities 0-3). Generate 1000 random convergent systems per signature size. Measure:
- Total merge operations to reach saturation.
- Whether completeness holds (compare e-graph classes to normal-form classes).
- Growth rate of merges as a function of signature complexity.

**Falsification**: Any signature where congruence closure fails to capture all EqvGen equivalences within the explored term universe, or where merge count grows super-polynomially in n^k, refutes the conjecture.

**Impact**: Would extend `extraction_semantics_preserved` from abstract e-graphs to concrete congruence-closure-based e-graphs, closing the gap between our formalization and practical implementations like egg.

**Catalog References**: `Pythagorean/EqualitySaturationExtraction.lean` (SaturatedEGraphExtractor, extraction_semantics_preserved), `Pythagorean/ConvergentRewriteOptimizer.lean` (nf_constant_on_eqvGen).

**Proof Strategy**: Define a CongruenceEGraph structure extending SaturatedEGraphExtractor with congruence axioms. Prove congruence closure preserves soundness by induction on merge steps. Prove completeness by showing the generated relation is closed under function application.

**Domain Bridges**: SMT solvers (congruence closure is the core of E-matching), automated theorem proving (paramodulation), abstract interpretation (abstract congruence).

**Lineage**: Extends extraction_semantics_preserved from abstract relations to constructive congruence closure.

**Ambition**: Grand challenge — congruence closure completeness for typed systems is open even informally for some type systems.

---

## Direction 2: Higher-Order Equality Saturation

**Conjecture**: The extraction soundness theorem (`extraction_semantics_preserved`) extends to higher-order rewrite systems on simply-typed lambda terms, where `EqvGen R` includes β-reduction and η-expansion, provided the e-graph's sameClass relation is sound for the higher-order EqvGen.

**Test**: Implement a higher-order e-graph over simply-typed lambda terms with β and η rules plus user-defined axioms. Generate 500 random well-typed lambda terms (types with depth ≤ 3, terms with depth ≤ 5). Run saturation with β, η, and 5 random equational axioms. Verify:
- Extraction preserves denotation in the standard set-theoretic model.
- Saturation terminates for strongly normalizing systems.
- Cost-optimal extraction finds smaller terms than β-normal forms.

**Falsification**: Any instance where extraction changes denotation in the set-theoretic model, or where saturation diverges for a strongly normalizing system within reasonable bounds (10^6 steps), refutes the conjecture.

**Impact**: Would enable verified optimization of functional programs, proof term simplification, and higher-order unification-based synthesis.

**Catalog References**: `Pythagorean/EqualitySaturationExtraction.lean` (extraction_semantics_preserved, extraction_agrees_with_quotient_nf_semantically).

**Proof Strategy**: Define HigherOrderTerm as an inductive type with App and Lam constructors. Define substitution and β-reduction. Instantiate SaturatedEGraphExtractor with the higher-order EqvGen. The key challenge is handling binders and α-equivalence in the e-graph representation.

**Domain Bridges**: Proof assistants (proof term optimization), functional compilers (GHC, MLton), program synthesis (type-guided search).

**Lineage**: Extends the first-order quotient framework to higher-order settings.

**Ambition**: Grand challenge — higher-order equality saturation is an active research frontier with no complete formalization.

---

## Direction 3: Polynomial Saturation Depth Bound

**Conjecture**: For every finite convergent rewrite system R with m rules of maximum size k over a finite alphabet of size n, and every seed set S of total size s, the saturation depth required to achieve completeness (`complete_sameClass`) is bounded by O(m · k² · s).

**Test**: Generate 200 random finite convergent systems with varying parameters (m ∈ {2,4,8,16}, k ∈ {2,3,4,5}, n ∈ {3,4,5}). For each, select 100 random seed sets of varying sizes (s ∈ {10, 50, 100, 500}). Compute:
- Exact saturation depth by running saturation to completion.
- Fit growth rate against m · k² · s.
- Search for outliers where depth exceeds the predicted bound.

**Falsification**: A family of systems where saturation depth grows as Ω(m · k² · s · log(s)) or faster would refute the linear bound. Even a single system with super-quadratic growth in s would be significant.

**Impact**: Would establish that equality saturation is not just correct but computationally tractable for convergent systems, justifying its use in performance-critical settings.

**Catalog References**: `Pythagorean/EqualitySaturationExtraction.lean` (SaturatedEGraphExtractor, cheapest_extraction_sound_and_optimal), `Pythagorean/ConvergentRewriteOptimizer.lean` (CertifiedNormalizer, nf_unique_of_confluent).

**Proof Strategy**: Use the fact that in a convergent system, every term has a unique normal form. The key insight is that the number of distinct normal forms reachable from S is bounded by |S|, and each normal-form class has bounded diameter in the rewrite graph. Bound the diameter using the termination order.

**Domain Bridges**: Computational complexity (decision procedures), automated reasoning (completion procedures), database theory (chase termination).

**Lineage**: Builds directly on bounded_extractor_sound_of_complete, seeking to make the "bounded" qualifier unnecessary for convergent systems.

**Ambition**: Solid extension — the linear bound is likely achievable for many natural systems but may fail for pathological ones.

---

## Direction 4: Verified Equality-Saturation Compiler Pass

**Conjecture**: The theorems `extraction_semantics_preserved` and `cheapest_extraction_sound_and_optimal` can be instantiated with a concrete term type (arithmetic expressions with +, ×, constants, variables), a concrete rewrite system (commutativity, associativity, distributivity, identity laws), and a concrete cost model (operation count) to produce a verified compiler optimization pass that provably preserves evaluation semantics while minimizing instruction count.

**Test**: Implement the concrete instantiation. Generate 10,000 random arithmetic expressions (depth 3-8). For each:
- Run the verified extractor.
- Verify semantics preservation under 100 random variable assignments.
- Compare extracted cost to normal-form cost and original cost.
- Measure compilation time.

**Falsification**: Any expression where the extracted result evaluates differently from the original under any assignment refutes the soundness instantiation. Any systematic failure to find lower-cost equivalents compared to normalization refutes the practical utility claim.

**Impact**: Would produce the first verified equality-saturation-based compiler pass, bridging the gap between our abstract theorems and practical compiler construction.

**Catalog References**: `Pythagorean/EqualitySaturationExtraction.lean` (all main theorems), `Pythagorean/ConvergentRewriteOptimizer.lean` (RingExpr, ring_rewrite_nf_preserves_eval, addComm_rewrite_sound).

**Proof Strategy**: Instantiate SaturatedEGraphExtractor with RingExpr from the catalog. Define the rewrite system as the union of commutativity, associativity, and identity rules. Prove soundness using addComm_rewrite_sound and analogous lemmas. Define cost as the number of Add and Mul nodes. Run the subagent on each instantiation lemma.

**Domain Bridges**: Verified compilation (CompCert, CakeML), hardware synthesis (circuit optimization), numerical computing (floating-point expression optimization).

**Lineage**: Direct application of the full theorem cluster to the RingExpr type from the convergent rewrite catalog.

**Ambition**: Solid extension — all components exist; the challenge is connecting them cleanly.

---

## Direction 5: Extraction as Free Energy Minimization on Symmetry Orbits

**Conjecture**: The quotient-optimization framework of equality saturation is isomorphic to ground-state selection in statistical mechanics: the equivalence class is a symmetry orbit, the cost model is the energy functional, and extraction is the selection of the minimum-energy state. Formally, for a finite group G acting on a finite set X with energy function E : X → ℝ, the ground-state selector g(O) = argmin_{x ∈ O} E(x) for each orbit O satisfies the same abstract axioms as our SaturatedEGraphExtractor.

**Test**: Implement the physics instantiation:
- Define G as the symmetric group S_n acting on n-tuples by permutation.
- Define energy as a random quadratic function on ℝ^n.
- Construct the "e-graph" as the orbit structure of G.
- Verify that ground-state selection satisfies soundness and optimality.
- Compare ground-state energy to the "normal form" energy (lexicographically smallest permutation).

**Falsification**: If the abstract axioms of SaturatedEGraphExtractor cannot be satisfied for group actions with non-trivial stabilizers, the isomorphism claim fails. Specifically, if the extraction function cannot be defined consistently across overlapping orbits (which shouldn't happen for group actions, but check for more general equivalence relations).

**Impact**: Would establish a formal bridge between computer science optimization and physics, suggesting that equality saturation engines are performing a form of simulated ground-state search.

**Catalog References**: `Pythagorean/EqualitySaturationExtraction.lean` (SaturatedEGraphExtractor, extraction_induces_resource_abstraction, cheapest_extraction_sound_and_optimal).

**Proof Strategy**: Define GroupActionExtractor as an instance of SaturatedEGraphExtractor where sameClass a b iff ∃ g ∈ G, g • a = b. Soundness follows from the group action being an equivalence relation. Completeness follows from the orbit being the full equivalence class. Extraction as argmin is well-defined on finite orbits.

**Domain Bridges**: Statistical mechanics (ground-state selection), quantum chemistry (molecular symmetry), materials science (crystal structure prediction), category theory (sections of quotient functors).

**Lineage**: Extends extraction_induces_resource_abstraction from abstract cost models to physical energy functionals.

**Ambition**: Grand challenge — connecting equality saturation to physics is speculative but potentially paradigm-shifting.
