# Future Directions: Equality Saturation Extraction Correctness

## Synthesis

The extraction correctness theorems established here — soundness, cost-optimality, and agreement with normal forms — open a formal bridge between term rewriting, quotient semantics, and optimization theory. The key structural insight is that semantic correctness of extraction depends only on the *soundness* of the e-graph relation (which is easy), while the relationship to canonical normal forms requires *convergence* of the rewrite system (which is hard). This asymmetry suggests several directions: (1) extending the framework to non-convergent systems where soundness alone suffices, (2) formalizing the saturation algorithm itself to close the gap between abstract completeness and computation, (3) connecting cost-optimal extraction to broader optimization-theoretic frameworks, (4) exploring the combinatorial structure of saturation depth, and (5) scaling to higher-order and infinite rewriting. Each direction is both mathematically deep and computationally testable.

---

## Direction 1: Verified E-Graph Saturation Algorithm

**Conjecture:** There exists a formally verified implementation of the equality saturation algorithm (union-find-based e-graph with congruence closure) such that the output e-graph provably satisfies the `SaturatedEGraphExtractor` interface — i.e., its `sameClass` relation is sound for `EqvGen R.rel` and complete on the explored term universe.

**Test:** Implement a union-find-based e-graph in Lean 4 with a saturation loop. Define a `build_extractor` function that constructs a `SaturatedEGraphExtractor` from the saturated e-graph. Verify soundness by proving that every merge operation preserves the soundness invariant. Verify completeness for specific rewrite systems (e.g., associativity-commutativity) by proving that the saturation loop reaches a fixed point.

**Impact:** This would close the gap between our abstract theorems and computation, yielding a fully verified equality saturation engine. It would be the first such verified engine to our knowledge.

**Catalog References:** `Pythagorean/EqualitySaturationExtraction.lean` (SaturatedEGraphExtractor, extraction_semantics_preserved), `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean` (CertifiedNormalizer, nf_constant_on_eqvGen).

**Proof Strategy:** Define e-graph state as an inductive type with union-find operations. Prove soundness by induction on the saturation step count. Prove completeness for specific systems by showing the closure of applied rules subsumes all single-step rewrites.

**Domain Bridges:** Verified compilation (CompCert, CakeML), SMT solvers (Z3, cvc5), automated theorem proving.

**Lineage:** Extends `bounded_extractor_sound_of_complete` from abstract bounded extraction to concrete algorithmic extraction.

**Ambition:** ★★★★☆ (High — requires significant formalization of union-find and congruence closure in Lean)

---

## Direction 2: Polynomial Saturation Depth for Finite Convergent Systems

**Conjecture:** For every finite convergent rewrite system R with n elements and maximum rule size k, the saturation depth (number of rounds until the e-graph relation equals `EqvGen R.rel` on the reachable universe) is bounded by O(n^k).

**Test:** Generate 1000 random finite convergent systems with carrier sizes 5–50 and rule sizes 1–5. For each, compute the exact saturation depth and the size of the reachable normal-form closure. Fit the relationship depth = f(n, k) to polynomial and exponential models. A single family where depth grows super-polynomially in n for fixed k would falsify the conjecture.

**Impact:** A positive result would establish that equality saturation is always efficient for finite convergent systems, resolving a practical question about when e-graph-based optimization terminates quickly. A negative result would identify structural barriers to efficient saturation.

**Catalog References:** `Pythagorean/EqualitySaturationExtraction.lean` (Convergent', BoundedEGraph), `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean` (IsConfluent, CertifiedNormalizer).

**Proof Strategy:** For an upper bound: analyze the number of distinct equivalence classes in the e-graph. Each saturation step must either merge two classes or add a new term. Since the carrier is finite with n elements, at most n-1 merges are possible. The depth is bounded by the longest chain of rule applications needed to discover all merges.

**Domain Bridges:** Complexity theory (decision procedures), automated reasoning (termination analysis), combinatorics (closure operators on finite lattices).

**Lineage:** Tests the computational content of `nf_constant_on_eqvGen'` — if normal forms are constant on EqvGen classes, how quickly does bounded saturation discover this?

**Ambition:** ★★★☆☆ (Medium — computational experiments are straightforward; proving the bound formally is hard)

---

## Direction 3: Extraction as Categorical Section with Cost Enrichment

**Conjecture (Grand Challenge):** The extraction map, viewed as a section of the quotient projection π : α → α/EqvGen, is the unique section minimizing a cost functional in the category of cost-enriched sets. Formally: there exists a cost-enriched category C where objects are sets with cost functions, morphisms are cost-non-increasing maps, and extraction is the terminal section of π in C.

**Test:** Define the category C in Lean 4 using Mathlib's category theory library. Construct the quotient projection as a morphism. Show that extraction, when it minimizes cost, satisfies a universal property (e.g., it is the unique morphism from the quotient to the original set that is a section of π and minimizes total cost). Verify computationally on 100 examples that the categorical construction agrees with the algorithmic extraction.

**Impact:** This would connect equality saturation to enriched category theory, opening applications to monoidal optimization, operadic rewriting, and cost-aware program transformation. It would be the first categorical characterization of e-graph extraction.

**Catalog References:** `Pythagorean/EqualitySaturationExtraction.lean` (CostModel', IsCheapestInClass', cheapest_extraction_sound_and_optimal).

**Proof Strategy:** Use Mathlib's `CategoryTheory.Section` or define sections manually. The key is showing that the cost-minimality condition characterizes a unique section when costs are distinct. When costs are not distinct, characterize the set of optimal sections.

**Domain Bridges:** Category theory (sections of functors), optimization theory (Lagrangian duality), information theory (rate-distortion theory as quotient optimization).

**Lineage:** Extends `extraction_induces_resource_abstraction` from an existence statement to a categorical characterization.

**Ambition:** ★★★★★ (Grand challenge — connecting e-graphs to enriched category theory is conceptually novel)

---

## Direction 4: Non-Convergent Extraction Soundness

**Conjecture:** Theorem 1 (extraction_semantics_preserved) holds without any convergence or confluence assumption — it depends only on soundness of the e-graph relation. Therefore, equality saturation is a correct optimization technique even for non-confluent, non-terminating rewrite systems, as long as the e-graph only merges truly equivalent terms.

**Test:** This is already proved in our formalization (Theorem 1 has no convergence hypothesis). The test is to verify that practical e-graph systems for non-confluent theories (e.g., lambda calculus with β-reduction, which is non-confluent in the presence of η) still satisfy the soundness hypothesis. Implement 50 non-confluent rewrite systems, build e-graphs, and verify that extraction preserves semantics over random models.

**Impact:** This clarifies that the power of equality saturation does not come from confluence but from the quotient structure of equivalence classes. It justifies the use of e-graphs in settings where classical rewrite theory does not apply.

**Catalog References:** `Pythagorean/EqualitySaturationExtraction.lean` (extraction_semantics_preserved — note: no Convergent' hypothesis).

**Proof Strategy:** Already proved. The extension is to formalize specific non-confluent systems (e.g., λ-calculus) and verify the soundness hypothesis holds for their e-graph implementations.

**Domain Bridges:** Lambda calculus (β-η optimization), logic programming (resolution as non-confluent rewriting), quantum computing (circuit equivalence under non-confluent gate identities).

**Lineage:** Directly uses `extraction_semantics_preserved` and `extract_eqvGen`.

**Ambition:** ★★☆☆☆ (Low — the abstract result is proved; the extension is about applications)

---

## Direction 5: Extraction as Free Energy Minimization

**Conjecture (Grand Challenge):** Define a "partition function" Z(C, β) = Σ_{x ∈ C} exp(-β · cost(x)) over an equivalence class C at inverse temperature β. As β → ∞, the Gibbs measure concentrates on the cheapest representative, recovering cost-optimal extraction as a zero-temperature limit. Conjecture: for finite classes, there exists a phase transition at a critical β* where the number of near-optimal representatives drops discontinuously.

**Test:** For 500 random equivalence classes (sizes 10–1000) with random cost functions, compute Z(C, β) for β ∈ [0.01, 100]. Plot the free energy F = -log(Z)/β and its derivatives. Identify phase transitions as discontinuities in ∂²F/∂β². Report the distribution of critical β* values. A smooth free energy landscape (no phase transitions) would falsify the conjecture.

**Impact:** This would establish a formal connection between optimization by equivalence-class search and statistical mechanics. It suggests that equality saturation engines could benefit from simulated annealing: start with high-temperature exploration (consider all representatives), then cool to zero temperature (select cheapest). Phase transitions would indicate structural barriers to optimization.

**Catalog References:** `Pythagorean/EqualitySaturationExtraction.lean` (CostModel', IsCheapestInClass', cheapest_extraction_sound_and_optimal).

**Proof Strategy:** Define the partition function and free energy in Lean using Mathlib's `Real.exp` and `Finset.sum`. Prove that the zero-temperature limit recovers the minimum-cost element. The phase transition conjecture is harder and may require combinatorial analysis of the cost distribution.

**Domain Bridges:** Statistical physics (partition functions, phase transitions), information theory (free energy and compression), machine learning (Boltzmann machines, energy-based models).

**Lineage:** Extends `extraction_induces_resource_abstraction` by adding a temperature parameter and connecting to thermodynamic formalism.

**Ambition:** ★★★★★ (Grand challenge — connecting e-graph optimization to statistical mechanics is highly novel)
