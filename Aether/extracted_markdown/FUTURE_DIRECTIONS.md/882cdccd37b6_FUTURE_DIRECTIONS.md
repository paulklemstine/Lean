# Future Directions: The Universal Algebra of Equality Saturation

## Synthesis

The theorems proved in this work establish that e-graph extraction is not an ad hoc search procedure but a mathematically inevitable operation: a section of the semantic quotient induced by congruence soundness. This opens a systematic research program connecting equality saturation to universal algebra, lattice theory, and approximation theory.

The five directions below form a coherent progression: Direction 1 extends the quotient framework to handle the practical reality of incomplete saturation; Direction 2 lifts the theory from flat terms to hierarchical module composition; Direction 3 connects to the deep structure theory of congruence lattices; Direction 4 bridges to categorical semantics; and Direction 5 tackles the grand challenge of characterizing when equality saturation terminates with a unique semantic answer.

Each direction builds directly on the catalog theorems (`extraction_eval_invariant`, `eval_factors_through_egraph_quotient`, `galois_connection_congruence_modelclass`) and is formulated as a falsifiable scientific hypothesis with concrete computational tests.

---

## Direction 1: Monotone Convergence of Approximate Sections Under Partial Saturation

**Conjecture.** For finite equational theories over finite signatures, if an e-graph is partially saturated to depth $k$ (applying rewrite rules up to $k$ times) and extraction is locally cost-optimal, then the semantic approximation error $\varepsilon_k$ (maximum discrepancy between extracted evaluation and true quotient value over all models) satisfies $\varepsilon_{k+1} \leq \varepsilon_k$, with $\varepsilon_k = 0$ for $k$ exceeding the saturation bound.

**Test.** Generate 10,000 random terms of depth ≤ 8 over {+, ×} with AC axioms. For each term, compute $\varepsilon_k$ for $k = 0, 1, \ldots, 20$ by evaluating in 100 random commutative semirings of size 5. Plot $\varepsilon_k$ vs $k$ and check monotonicity. Disproof: any instance where $\varepsilon_{k+1} > \varepsilon_k$.

**Impact.** Would provide the first formal convergence guarantee for incomplete equality saturation, directly applicable to compiler optimization timeouts (e.g., in MLIR, egg, egglog).

**Catalog References.**
- `Pythagorean/EGraph/Extraction.lean`: `approximate_section_of_exact`, `extraction_eval_invariant`
- `Pythagorean/EGraph/Defs.lean`: `ApproximateSection`

**Proof Strategy.** Define $\varepsilon_k$ as the maximum over all e-classes of $\max_{t \in [t]_k} |eval(extract_k(q)) - eval(t)|$ in a suitable metric. Show that each saturation step can only merge classes (making the quotient coarser), which by `modelClass_antitone` can only decrease the set of distinguishing models, hence decrease the maximum discrepancy.

**Domain Bridges.** Compiler optimization (timeout budgets), SMT solving (incremental congruence closure), approximation theory (convergence rates).

**Lineage.** Extends `ApproximateSection` and `approximate_section_of_exact` from exact to parametric setting.

**Ambition.** ★★★★☆ — Would resolve a major open question in the equality saturation community about the behavior of partial saturation.

---

## Direction 2: Compositional Extraction for Multi-Sorted Term Algebras

**Conjecture.** For multi-sorted equational theories (e.g., types + terms, or modules + functions), if each sort's congruence is independently sound, then the product extraction (extracting independently per sort) is globally semantically canonical, without requiring cross-sort congruence closure.

**Test.** Define a two-sorted signature: sort A (arithmetic expressions) and sort B (boolean guards). Generate random terms mixing both sorts. Build independent e-graphs per sort. Extract independently. Compare with joint extraction from a single e-graph with cross-sort congruence. Disproof: any term where independent extraction gives a different semantic value than joint extraction.

**Impact.** Would enable modular equality saturation for real compilers where different IR layers (e.g., tensor operations vs. control flow) are optimized independently.

**Catalog References.**
- `Pythagorean/EGraph/Extraction.lean`: `extraction_composition_sound`, `eval_factors_through_egraph_quotient`
- `Pythagorean/EGraph/Defs.lean`: `SoundCongruence`, `Sig`

**Proof Strategy.** Model the multi-sorted case as a product of quotients. Use `extraction_composition_sound` as the template: show that product extraction is a section of the product quotient, and that product soundness follows from component soundness when there are no cross-sort axioms.

**Domain Bridges.** Module systems in compilers, categorical products of algebras, multi-theory SMT integration (Nelson-Oppen).

**Lineage.** Generalizes `extraction_composition_sound` from refinement chains to product decompositions.

**Ambition.** ★★★☆☆ — Conceptually clear extension, but the formalization of multi-sorted signatures requires substantial infrastructure.

---

## Direction 3: The Congruence Lattice of E-Graphs and Birkhoff's HSP Theorem

**Conjecture.** The set of sound congruences on a finite term algebra, ordered by refinement (`CongruenceRefines`), forms a complete lattice isomorphic to the congruence lattice of the free algebra modulo the equational theory. Moreover, the Galois connection `galois_connection_congruence_modelclass` extends to a lattice anti-isomorphism between the congruence lattice and the lattice of model classes, recovering Birkhoff's HSP theorem in the finite case.

**Test.** For the theory of commutative monoids over 2 generators, enumerate all congruences on terms of depth ≤ 3. Verify: (a) they form a lattice under refinement, (b) the Galois connection is an anti-isomorphism, (c) the lattice structure matches the known congruence lattice of the free commutative monoid on 2 generators. Disproof: any pair of congruences whose meet or join is not a congruence, or any failure of the anti-isomorphism.

**Impact.** Would establish e-graphs as computational tools for exploring Birkhoff's variety theorem, connecting PL optimization to the deepest results in universal algebra.

**Catalog References.**
- `Pythagorean/EGraph/Extraction.lean`: `galois_connection_congruence_modelclass`, `modelClass_antitone`
- `Pythagorean/EGraph/Defs.lean`: `CongruenceRefines`, `ModelClass`

**Proof Strategy.** Show that `CongruenceRefines` is a partial order (using `congruenceRefines_refl` and `congruenceRefines_trans` from the catalog). Define meet as intersection of relations (extending `relInter` from the catalog). Define join as the transitive closure of the union. Prove completeness. The anti-isomorphism follows from the Galois connection theorem plus completeness.

**Domain Bridges.** Universal algebra (Birkhoff's theorem), lattice theory, algebraic logic (Blok-Pigozzi), database theory (Chase and dependencies).

**Lineage.** Builds directly on `galois_connection_congruence_modelclass` and `modelClass_antitone`.

**Ambition.** ★★★★★ — Grand challenge. Would unify e-graph theory with classical universal algebra at the deepest level.

---

## Direction 4: Categorical Semantics of Extraction as Coequalizer Section

**Conjecture.** In the category of algebras for a given equational theory, the e-graph quotient is the coequalizer of the pair of projection maps from the relation to the carrier. Extraction is a section of the coequalizer map. The semantic canonicity theorem (`semantically_canonical_of_sound_section`) is the statement that any section of a coequalizer in a concrete category preserves the forgetful functor's image.

**Test.** Formalize the category of finite commutative semigroups in Lean. Construct the coequalizer of the e-graph relation. Show that the extraction section constructed in the current work satisfies the universal property. Disproof: construct a concrete algebra where the extraction section fails to commute with a homomorphism (this should be impossible by the theorem, so failure would indicate a formalization bug).

**Impact.** Would place equality saturation in the framework of categorical algebra, enabling connections to topos theory, sheaf models, and homotopy type theory.

**Catalog References.**
- `Pythagorean/EGraph/Extraction.lean`: `semantically_canonical_of_sound_section`, `eval_factorization_unique`
- `Pythagorean/EGraph/Defs.lean`: `SemanticallyCanonical`

**Proof Strategy.** Use Mathlib's category theory library. Define the functor from `Sig`-algebras to `Type`. Show that `Quotient.lift` provides the coequalizer. Use `eval_factorization_unique` to establish the universal property.

**Domain Bridges.** Category theory, topos theory, denotational semantics, homotopy type theory.

**Lineage.** Categorifies `eval_factors_through_egraph_quotient` and `eval_factorization_unique`.

**Ambition.** ★★★★☆ — Requires significant categorical infrastructure but is conceptually well-motivated.

---

## Direction 5: Unique Semantic Normal Forms for Finite Idempotent Theories

**Conjecture.** For finite equational theories where all operations are idempotent (f(x,x) = x), every sound e-class over a finite term algebra admits a unique semantic normal form: a single term that is the unique cost-minimal representative up to syntactic identity, and this normal form can be computed in polynomial time.

**Test.** Generate random idempotent binary operations on sets of size 3-7. Build term algebras of depth ≤ 4 over 2-3 generators. For each e-class in the fully saturated e-graph, count the number of distinct cost-minimal representatives. Disproof: any e-class with two distinct cost-minimal representatives. Check that the unique normal form can be computed without full saturation.

**Impact.** Would give a polynomial-time canonicalization algorithm for a significant class of algebraic theories, with applications to idempotent semirings (tropical algebra), lattice optimization, and database query normalization.

**Catalog References.**
- `Pythagorean/EGraph/Extraction.lean`: `optimal_extract_semantics_unique`, `extraction_idempotent`
- `Pythagorean/EGraph/Defs.lean`: `CostExtractionSection`

**Proof Strategy.** Use idempotency to show that in any e-class, the term of minimal depth is unique (idempotency allows collapsing repeated subterms). Show that this minimal-depth term is also cost-minimal. The polynomial-time algorithm follows from the bounded depth.

**Domain Bridges.** Tropical algebra, lattice theory, database query optimization, idempotent analysis.

**Lineage.** Specializes `optimal_extract_semantics_unique` to idempotent theories and strengthens semantic uniqueness to syntactic uniqueness.

**Ambition.** ★★★★★ — Grand challenge. If true, would give a new polynomial-time normal form algorithm for a broad class of algebraic theories.
