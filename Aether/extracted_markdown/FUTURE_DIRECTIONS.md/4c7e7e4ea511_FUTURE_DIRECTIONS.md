# Future Directions: E-Graph Extraction as Quotient Section

## Synthesis

The formalization of e-graph extraction as a quotient section opens a systematic research program connecting equality saturation to universal algebra, categorical semantics, and approximation theory. The four core theorems — extraction invariance, the reduction to congruence soundness, cost-optimality invariance, and the factorization theorem — provide the foundation. Each future direction below extends one of these theorems into new mathematical territory or applies it to a new computational domain. The unifying theme is that **e-graphs are quotient algebra objects**, and extraction is a section of the quotient map. Every direction is falsifiable, every test is concrete, and every conjecture connects back to the formalized catalog.

---

## Direction 1: Approximate Section Stability Under Partial Saturation

**Conjecture.** For finite equational theories over finite signatures, if an e-graph is partially saturated to depth `k` and extraction is locally cost-optimal, then the semantic extraction error (measured as the fraction of interpretations where `eval(extract(q)) ≠ eval(t)` for `t` in class `q`) is monotonically non-increasing as `k` increases.

**Test.** Generate 1,000 random terms of depth ≤ 6 over the AC theory with 3 variables. For each term, build e-graphs saturated to depths k = 1, 2, ..., 10. Extract the minimum-size representative at each depth. Evaluate both the original term and the extracted term in 100 random commutative semigroups of order 5. Plot the error rate as a function of k.

**Disproof criterion.** Any observed increase in error rate from depth k to depth k+1 disproves the conjecture. A single counterexample term with non-monotone error suffices.

**Impact.** If true, this provides a convergence rate for incomplete equality saturation, giving compiler writers a principled stopping criterion: saturate until the error rate drops below a threshold.

**Catalog References.** `Pythagorean/EGraph/Extraction.lean`: `approximate_section_of_sound` establishes the base case (exact soundness gives zero error). `extraction_eval_invariant` is the limiting theorem.

**Proof Strategy.** Show that deeper saturation can only merge more terms, so the congruence at depth k+1 refines that at depth k. Apply `modelClass_antitone` and `extraction_factors_through_coarser` to argue that the factored evaluation becomes more determined.

**Domain Bridges.** Connects to numerical analysis (convergence rates), information theory (rate-distortion), compiler optimization (saturation budgets).

**Lineage.** Extends `approximate_section_of_sound` → `extraction_eval_invariant` chain.

**Ambition.** ★★★★☆ — High impact if proved, moderately difficult.

---

## Direction 2: Unique Semantic Normal Forms in Idempotent Commutative Semigroups

**Conjecture.** For finite idempotent commutative semigroups (where x·x = x, x·y = y·x), every sound e-class admits a unique semantic value. Furthermore, the minimum-size representative is unique up to variable permutation in >99.9% of random bounded terms.

**Test.** Enumerate all idempotent commutative semigroups of order ≤ 6 (these form semilattices). Generate 10,000 random terms of depth ≤ 5 over 3 variables. For each term and each semigroup, compute all AC-equivalent terms and verify evaluation uniqueness. Count the fraction of terms where the minimum-size representative is unique.

**Disproof criterion.** Find two minimum-size terms in the same AC-class that evaluate differently in some idempotent commutative semigroup. (Note: by Theorem 3, this cannot happen if they are in the same *sound* class — so a counterexample would require an unsound congruence or a bug in the implementation.)

**Impact.** If true, this shows that for a natural class of algebras, syntactic normal forms and semantic normal forms coincide, providing a bridge between rewriting and evaluation.

**Catalog References.** `Pythagorean/EGraph/Extraction.lean`: `optimal_extract_semantics_unique` guarantees evaluation equality of cost-minimal terms; this direction investigates syntactic uniqueness.

**Proof Strategy.** Use the lattice structure of semilattices: every idempotent commutative semigroup is a meet-semilattice. Terms compute meets, and the AC normal form (sorted multiset) corresponds to the set of variables, since x·x = x eliminates duplicates.

**Domain Bridges.** Connects to lattice theory, database query optimization (semilattice operations in CRDTs), and topology (meet operations on open sets).

**Lineage.** Extends `optimal_extract_semantics_unique`.

**Ambition.** ★★★☆☆ — Solid extension with clean algebraic structure.

---

## Direction 3: Categorical Semantics of Extraction as Coequalizer Section

**Conjecture.** In the category **Set**, the e-graph quotient `Term/≈` is the coequalizer of the two projection maps from the relation `{(t₁, t₂) | t₁ ≈ t₂}` to `Term`. Extraction is a section of this coequalizer. The factored evaluation map is the unique mediating morphism guaranteed by the universal property.

**Test.** Formalize the coequalizer construction in Lean using Mathlib's category theory library. Prove that `Quotient.lift` is the mediating morphism. Show that `ExtractionSection.extract` is a section of the coequalizer projection.

**Disproof criterion.** This is a definitions-level conjecture and should be provable; the challenge is connecting Lean's `Quotient` to the categorical coequalizer. If the categorical framework doesn't align (e.g., because `Quotient` has different universe behavior), this would be discovered during formalization.

**Impact.** Opens the door to applying sheaf theory, topos theory, and functorial semantics to equality saturation. Could lead to a categorical theory of program optimization.

**Catalog References.** `Pythagorean/EGraph/Extraction.lean`: `eval_factors_through_egraph_quotient` is the universal property; `extraction_factors_through_coarser` is functoriality.

**Proof Strategy.** Use Mathlib's `CategoryTheory.Limits.Coequalizer`. Construct the fork from the relation and show `Quotient.mk` is the coequalizer map. The section property of extraction gives the section.

**Domain Bridges.** Connects to categorical logic, topos theory, denotational semantics, and the Curry-Howard-Lambek correspondence.

**Lineage.** Extends `eval_factors_through_egraph_quotient` into categorical semantics.

**Ambition.** ★★★★★ — Grand challenge, paradigm-shifting if fully realized.

---

## Direction 4: Congruence Lattice Classification of E-Graph Algorithms

**Conjecture.** Different e-graph implementations (egg, egglog, relational e-matching) compute different congruences on the same term algebra. These congruences form a sublattice of the full congruence lattice. For AC theories over finite terms, this sublattice is finite and can be explicitly computed.

**Test.** Implement three e-graph variants (standard, relational, pattern-based) and run them on the same set of 100 terms with the same axioms. For each pair of terms, record which implementations consider them equivalent. Compute the resulting congruences and verify they form a lattice under refinement.

**Disproof criterion.** Find that the computed congruences do not form a lattice (i.e., the meet or join of two computed congruences is not itself a computed congruence). This would mean the space of "efficiently computable" congruences is not algebraically closed.

**Impact.** Would provide a principled taxonomy of e-graph algorithms, replacing ad hoc comparisons with lattice-theoretic classification. Could identify "gaps" in the lattice where new algorithms should be designed.

**Catalog References.** `Pythagorean/EGraph/Defs.lean`: `CongruenceRefines`, `relInter`, `relInter_equiv`. `Pythagorean/EGraph/Extraction.lean`: `galois_connection_congruence_modelclass`, `modelClass_antitone`.

**Proof Strategy.** Use the Galois connection theorem to translate between congruences and model classes. Show that the image of the Galois connection on finite sets is a complete lattice (this follows from general Galois connection theory).

**Domain Bridges.** Connects to lattice theory, algorithm design, database theory (query optimization lattices), and abstract interpretation (Cousot's framework).

**Lineage.** Extends `galois_connection_congruence_modelclass` → `modelClass_antitone`.

**Ambition.** ★★★★☆ — High impact, requires algorithmic implementation and formal theory.

---

## Direction 5: Quantitative Convergence Rates for E-Graph Saturation

**Conjecture.** For the theory of commutative semirings (ℕ[x,y,z] modulo AC + distributivity), the number of equivalence classes in the e-graph after k saturation rounds on a term of size n is bounded by O(n^k · p(n)), where p(n) is the number of partitions of n. Furthermore, the error of extraction (measured as the fraction of interpretations where extracted ≠ original) decreases as O(1/k).

**Test.** Generate 500 random semiring expressions of sizes n = 5, 10, 15, 20. For each, run saturation to depths k = 1, ..., 10 and record: (a) number of e-classes, (b) extraction error rate over 100 random ℤ/p evaluations for p = 2, 3, 5, 7. Fit regression models to the data.

**Disproof criterion.** (a) The class count grows super-polynomially in k (disproving the bound), or (b) the error rate does not decrease monotonically (disproving the convergence claim), or (c) the error rate decreases faster than O(1/k) (refining the conjecture).

**Impact.** Would give the first quantitative convergence theory for equality saturation, enabling compiler engineers to predict optimization quality as a function of time budget.

**Catalog References.** `Pythagorean/EGraph/Extraction.lean`: `extraction_eval_invariant` (limiting case), `approximate_section_of_sound` (base case). Relates to `Pythagorean/ConvergentRewriteSystems.lean` for convergent rewriting.

**Proof Strategy.** Combine the finite model theory of commutative semirings with Ramsey-type bounds on the growth of congruence classes. Use the factorization theorem to reduce the problem to counting quotient elements.

**Domain Bridges.** Connects to combinatorics (partition functions), complexity theory (rewriting complexity), numerical analysis (convergence rates), and compiler engineering (time-quality tradeoffs).

**Lineage.** Grand challenge extending the entire framework toward quantitative predictions.

**Ambition.** ★★★★★ — Grand challenge, would transform equality saturation from a heuristic to a quantitative theory.
