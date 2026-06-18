# Future Directions

## Synthesis

The extraction optimality theorem for tensor normal forms opens a new paradigm: canonical forms as certified extraction optima. The five directions below explore this paradigm along complementary axes—extending the algebraic scope (Directions 1-2), connecting to other mathematical domains (Directions 3-4), and pursuing deep structural consequences (Direction 5). Together, they form a research program that could establish canonical normalization as a universal optimization principle across algebra, computation, and physics.

---

## Direction 1: Lexicographic Extraction Optimality for Full DAG Size

**Conjecture:** Among all expressions semantically equivalent to e with minimum sharing cost (distinct variable count), the canonical form normalizeCanon(e) also minimizes tree size. Equivalently, the canonical form is optimal under the lexicographic cost (distinctVars, treeSize).

**Test:** Generate 10,000 random expressions of size 5-20. For each, enumerate all expressions reachable by AC+distribution rewrites within fuel 200. Among those achieving minimum sharing cost, check whether any has strictly smaller tree size than the canonical form. A single example would refute the conjecture; absence of counterexamples across diverse expression distributions would provide strong evidence.

**Impact:** Would upgrade the current primary-dimension optimality to full lexicographic optimality, making canonical normalization a complete replacement for e-graph extraction in the ℤ-linear fragment. This would be the first proof that a polynomial-time normalizer achieves exact optimality under a multi-dimensional cost model.

**Catalog References:** `Pythagorean/TensorExtractionOptimality.lean` (normalizeCanon_sharingCost_le, ExtractionCost)

**Proof Strategy:** Define a refined buildSum that optimizes tree size (e.g., balanced binary trees instead of right-associated chains). Prove that the balanced canonical form has minimal tree size among all sorted-coefficient representations. Then show that any semantically equivalent expression with the same sharing cost must use the same variable set, hence admits a representation as a sorted-coefficient sum, hence has tree size ≥ the balanced canonical form.

**Domain Bridges:** Compiler optimization (instruction selection), circuit complexity (gate count minimization)

**Lineage:** Extends Theorem 3 (sharing cost optimality) to a stronger cost model

**Ambition:** Extension — builds directly on proven infrastructure

---

## Direction 2: Nonlinear Extension via Gröbner–Extraction Correspondence

**Conjecture:** For polynomial expressions modulo ideal membership (with multiplication), reduced Gröbner bases compute minimum-sharing representatives under a monomial-aware cost model. Specifically, the number of distinct monomials in the reduced Gröbner basis normal form is minimal among all ideal-equivalent representations.

**Test:** For random polynomial ideals over ℚ[x₁,...,x₅] with 3-5 generators of degree ≤ 4, compute the reduced Gröbner basis normal form of 1000 random polynomials. Compare the monomial count against that of alternative representations obtained by adding multiples of generators. Search for representations with fewer distinct monomials.

**Impact:** Would establish a deep connection between Gröbner basis theory and e-graph extraction, potentially unifying two of the most important simplification paradigms in computer algebra. Could lead to certified polynomial optimization in proof assistants.

**Catalog References:** `Pythagorean/TensorExtractionOptimality.lean` (the linear case as template), `Catalog/Pythagorean/EqualitySaturationExtraction.lean` (e-graph infrastructure)

**Proof Strategy:** Generalize the coefficient map to a "monomial support" map. Prove that the leading term elimination in Gröbner basis computation preserves minimality of monomial count. The key obstacle is that polynomial multiplication creates new monomials, breaking the linear structure that makes our current proof work.

**Domain Bridges:** Algebraic geometry (ideal variety correspondence), cryptography (Gröbner basis attacks on polynomial systems)

**Lineage:** Grand challenge generalization of the linear extraction optimality theorem

**Ambition:** Grand Challenge — requires fundamentally new techniques beyond the linear setting

---

## Direction 3: Thermodynamic Interpretation of Extraction Optimality

**Conjecture:** The sharing cost of a tensor expression, viewed as an energy function on the equivalence class, induces a Boltzmann distribution over equivalent expressions. The canonical form corresponds to the ground state (minimum energy configuration), and the e-graph rewrite dynamics approximate thermodynamic relaxation toward this ground state.

**The key insight is** that the effective support (variables with nonzero coefficient) plays the role of a "phase" in statistical mechanics—the minimal information content of the equivalence class. The sharing cost optimality theorem then becomes an analog of the second law: canonical normalization computes the minimum-entropy representative.

**Why now?** The formal verification of extraction optimality provides the first rigorous energy landscape for expression equivalence classes. Combined with recent work on probabilistic term rewriting (random walks on rewrite graphs), this enables a precise thermodynamic formulation.

**Test:** Simulate random walks on the AC rewrite graph starting from random expressions. Measure the distribution of sharing costs at equilibrium (long random walk). Compare against the Boltzmann distribution P(e) ∝ exp(-β · sharingCost(e)) for various inverse temperatures β. If the distributions match, the thermodynamic interpretation is validated.

**Impact:** Would provide a physical intuition for why canonical forms work: they are the thermodynamic equilibria of expression spaces. Could import techniques from statistical physics (simulated annealing, replica methods) into term rewriting and compiler optimization.

**Catalog References:** `Pythagorean/TensorExtractionOptimality.lean` (sharingCost as energy), `Catalog/Pythagorean/EqualitySaturationExtraction.lean` (rewrite dynamics)

**Proof Strategy:** Define a Markov chain on the equivalence class via AC rewrite steps. Prove detailed balance for a suitable transition kernel. Show that the stationary distribution concentrates on minimum-energy (canonical) configurations as β → ∞.

**Domain Bridges:** Statistical physics (Ising models, energy landscapes), information theory (minimum description length), molecular simulation (conformational sampling)

**Lineage:** Cross-domain bridge from algebraic rewriting to statistical mechanics

**Ambition:** Grand Challenge — requires developing new theory at the algebra/physics interface

---

## Direction 4: Categorical Extraction Functors and Proof Net Optimization

**Conjecture:** The canonical normalization map, viewed as a section of the quotient functor from TExpr to TExpr/SemEquiv, is the unique natural section that minimizes a monoidal cost functor. This categorifies the extraction optimality theorem and extends it to arbitrary algebraic theories with a cost structure.

**The key insight is** that canonical normalization is not just a function on expressions—it is a functorial construction that respects the algebraic structure. The optimality theorem says this functor is a "geodesic section" of the quotient, choosing the shortest representative in each fiber.

**Why now?** The formal verification provides the first rigorous example of a cost-optimal quotient section. Category theory provides the language to generalize this to arbitrary algebraic theories, connecting to proof nets in linear logic and string diagrams in monoidal categories.

**Test:** Formalize the categorical framework in Lean 4. Define the quotient functor, the cost functor, and the section property. Verify that normalizeCanon satisfies the universal property of the minimum-cost section for the ℤ-linear theory. Attempt to construct analogous sections for the free commutative monoid and free abelian group theories.

**Impact:** Would provide a unified framework for understanding canonical forms across mathematics. Any equational theory with a cost structure would automatically generate an extraction optimality question, and the categorical machinery would provide a systematic approach to answering it.

**Catalog References:** `Pythagorean/TensorExtractionOptimality.lean` (concrete instance), `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean` (quotient normalization framework)

**Proof Strategy:** Define a 2-category of equational theories with cost functors. Show that cost-optimal sections, when they exist, are unique (by the lattice structure of sections under pointwise cost comparison). Prove existence for finitely presented commutative theories using the coefficient map generalization.

**Domain Bridges:** Category theory (fibered categories, sections), linear logic (proof nets), quantum computing (string diagrams for quantum circuits)

**Lineage:** Categorical generalization building on the concrete extraction optimality theorem

**Ambition:** Grand Challenge — would establish a new subfield of "extraction geometry"

---

## Direction 5: Extraction Complexity Bounds and Phase Transitions

**Conjecture:** For random ℤ-linear expressions of size n with k variables, the expected sharing cost reduction (original cost minus canonical cost) exhibits a phase transition at k ≈ √n. Below this threshold, most expressions already have near-optimal sharing; above it, canonical normalization achieves significant compression.

**The key insight is** that the sharing cost reduction depends on the density of variable repetitions. When expressions are sparse (many variables, few repetitions), canonical normalization has little to improve. When expressions are dense (few variables, many repetitions), coefficient merging collapses many terms, yielding large savings. The transition between these regimes should be sharp.

**Why now?** The formal proof of sharing cost optimality guarantees that the canonical form is always at least as good as any alternative. This enables a clean analysis of the *gap* between original and canonical cost without worrying about whether better alternatives exist.

**Test:** Generate 10,000 random expressions for each (n, k) pair with n ∈ {10, 20, 50, 100} and k ∈ {2, ..., n}. Plot the average sharing cost reduction as a function of k/√n. If a phase transition exists, the curves for different n should collapse onto a single universal curve when rescaled by √n.

**Impact:** Would characterize when canonical normalization is most beneficial in practice, guiding compiler designers in deciding when to apply simplification passes. The phase transition, if it exists, would be a new universality phenomenon connecting algebraic rewriting to random matrix theory.

**Catalog References:** `Pythagorean/TensorExtractionOptimality.lean` (normalizeCanon, sharingCost)

**Proof Strategy:** Model random expressions as random walks on the coefficient space. Use concentration inequalities (Chernoff bounds, martingale methods) to bound the effective support size. Identify the critical density at which the expected number of zero-coefficient variables transitions from O(1) to Θ(k).

**Domain Bridges:** Random matrix theory (spectral transitions), percolation theory (connectivity thresholds), compiler optimization (pass scheduling)

**Lineage:** Quantitative extension of the sharing cost optimality theorem to random inputs

**Ambition:** Extension — builds directly on proven infrastructure with new probabilistic analysis
