# Future Directions: E-Graph Extraction Correctness

## Synthesis

The extraction correctness theorem establishes a formal bridge between convergent term rewriting and e-graph-based optimization. This opens five research directions, ranging from immediate extensions (AC-rewriting, congruence closure) to paradigm-shifting conjectures (extraction as a universal optimizer, categorical semantics of saturation). All directions build on the core insight: the normalizer congruence is the finest sound congruence for a convergent system, and extraction sections preserve evaluation. The grand challenges push toward formalizing the correctness of entire compiler pipelines and connecting equality saturation to deep results in order theory and category theory.

---

## Direction 1: Global Cost Optimality Under Monotone Extraction

**Conjecture**: For a convergent rewrite system R with a monotone cost function c, the normal-form extraction always yields the globally minimum-cost term in each equivalence class: `∀ t₁ t₂, nf(t₁) = nf(t₂) → cost(nf(t₁)) ≤ cost(t₂)`.

**Test**: Generate 1000 random convergent TRS (≤5 rules, 3-symbol signature). For each, construct a saturated e-graph with 500 random terms of depth ≤5. For each e-class, exhaustively enumerate all members and check `cost(nf(t)) ≤ cost(t')` for all t' in the class. Any counterexample disproves the conjecture. If no counterexample is found, attempt a proof by structural induction on the reduction relation.

**Impact**: If true, this would upgrade extraction from "semantics-preserving" to "semantics-preserving AND optimal" — a strictly stronger guarantee. This would certify that equality saturation not only preserves meaning but finds the best program, which is the assumption underlying all practical e-graph optimizers.

**Catalog References**: `Pythagorean/EGraph/ExtractionCorrectness.lean`: `conjecture_monotone_cost_gives_global_min`, `conjecture_holds_for_self`, `cost_mono_rtc`

**Proof Strategy**: Show that for any t₂ with nf(t₁) = nf(t₂), there exists a reduction path from t₂ to nf(t₂) = nf(t₁). By cost monotonicity along this path, cost(nf(t₁)) = cost(nf(t₂)) ≤ cost(t₂). The key insight is that both t₁ and t₂ reduce to the same normal form, so cost monotonicity along t₂'s reduction path gives the bound.

**Domain Bridges**: Optimization theory ↔ term rewriting, lattice theory ↔ cost models

**Lineage**: Extends `cost_mono_rtc` and `conjecture_holds_for_self` from the current formalization.

**Ambition**: ★★★ (Medium — likely true, proof should be straightforward if the path insight is correct)

---

## Direction 2: Extraction Correctness for AC-Rewriting (Grand Challenge)

**Conjecture**: The extraction correctness theorem generalizes to associative-commutative (AC) rewriting: for a convergent AC-rewrite system R with sound rules, extraction from a saturated e-graph modulo AC preserves evaluation.

**Test**: Implement AC-matching and AC-completion for polynomial ring expressions. Generate 100 random polynomial identities, saturate an e-graph modulo AC, and verify that extraction preserves evaluation over Z[x,y,z] for 1000 random variable assignments. Any semantic mismatch refutes the conjecture.

**Impact**: AC-rewriting covers most algebraic simplification (polynomials, Boolean algebra, matrix expressions). Formalizing extraction correctness for AC-rewriting would certify a much broader class of compiler optimizations, including those used in SMT solvers and computer algebra systems. This would be a paradigm shift from "verification of specific rules" to "verification of entire equational theories."

**Catalog References**: `Pythagorean/ConvergentRewriteOptimizer.lean`: `nf_constant_on_eqvGen`, `convergent_rewrite_induces_optimizer`; `Pythagorean/EGraph/ExtractionCorrectness.lean`: `normalizer_extraction_preserves_eval`

**Proof Strategy**: 
1. Define AC-congruence closure as the finest congruence containing R ∪ AC.
2. Use ordered completion (Bachmair & Dershowitz, 1994) to transform R ∪ AC into a convergent system modulo AC.
3. Define a normalizer for the completed system and apply the extraction correctness theorem.
4. The main difficulty is formalizing AC-matching and proving it correct.

**Domain Bridges**: Universal algebra ↔ compiler optimization, Gröbner bases ↔ AC-completion

**Lineage**: Directly extends `normalizer_extraction_preserves_eval` to the AC setting.

**Ambition**: ★★★★★ (Grand Challenge — requires formalizing AC-completion, a significant undertaking)

---

## Direction 3: Categorical Semantics of Saturation (Grand Challenge)

**Conjecture**: The saturation operator on the lattice of equivalence relations is a monad, and the saturated e-graph is the initial algebra for this monad. Extraction is the unique algebra morphism from the initial algebra to any model.

**Test**: Implement the saturation monad for small term algebras (≤20 terms). Verify the monad laws (unit, multiplication, associativity) computationally for 50 random rewrite systems. Check that the universal property (unique morphism from initial algebra) holds for 20 random target algebras. Any violation of the monad laws or universal property refutes the conjecture.

**Impact**: This would establish a deep connection between equality saturation and categorical semantics, placing e-graphs in the same framework as abstract interpretation (Cousot & Cousot, 1977) and domain theory (Scott, 1970). It would enable transfer of results from category theory to compiler optimization and vice versa.

**Catalog References**: `Pythagorean/EGraph/ExtractionCorrectness.lean`: `nf_congruence_refines_any_closed` (the finest congruence theorem is the germ of the universal property)

**Proof Strategy**:
1. Define the category of equivalence relations on T with refinement as morphisms.
2. Show saturation is an endofunctor on this category.
3. Verify the monad laws using the Knaster-Tarski fixed-point theorem.
4. Construct the initial algebra as the least fixed point of saturation.
5. Prove the universal property using the initiality of the least fixed point.

**Domain Bridges**: Category theory ↔ compiler optimization, domain theory ↔ e-graphs, topos theory ↔ equational logic

**Lineage**: Extends `nf_congruence_refines_any_closed` from a lattice-theoretic statement to a categorical one.

**Ambition**: ★★★★★ (Grand Challenge — would connect two major areas of theoretical CS)

---

## Direction 4: Compositional Extraction for Multi-Pass Optimization

**Conjecture**: For a sequence of convergent rewrite systems R₁, ..., Rₖ with sound rules, the composition nf_k ∘ ... ∘ nf_1 preserves evaluation and achieves cost at most min(cost(nf_i(t))) over all i.

**Test**: Implement 3-pass optimization pipelines (constant folding → algebraic simplification → dead code elimination) for 500 random programs. Verify that the composition preserves semantics and achieves cost ≤ any single pass. Measure the cost gap between the composition and the theoretical optimum.

**Impact**: Real compilers use multiple optimization passes. Proving that compositions preserve correctness would certify entire optimization pipelines, not just individual passes. The cost bound would guide pass ordering — a long-standing open problem in compiler engineering.

**Catalog References**: `Pythagorean/EGraph/ExtractionCorrectness.lean`: `compose_extractions_preserves_eval`

**Proof Strategy**: Use `compose_extractions_preserves_eval` (already proven) as the base case. Extend by induction on the number of passes. The cost bound requires a separate argument about the monotonicity of composition.

**Domain Bridges**: Compiler engineering ↔ algebra, optimization theory ↔ pass ordering

**Lineage**: Directly extends `compose_extractions_preserves_eval` to k-fold composition.

**Ambition**: ★★★ (Medium — the correctness part is essentially done; the cost bound is the main challenge)

---

## Direction 5: Extraction Correctness for Higher-Order Terms

**Conjecture**: The extraction correctness theorem generalizes to simply-typed lambda calculus with beta-eta equality: for a convergent higher-order rewrite system with sound rules, extraction from a saturated e-graph preserves denotational semantics.

**Test**: Implement e-graph saturation for simply-typed lambda terms with beta-eta. Generate 200 random well-typed terms at types `Nat → Nat` and `(Nat → Nat) → Nat`. Saturate with beta-eta rules plus arithmetic simplifications. Verify that extraction preserves evaluation for 100 random inputs. Any mismatch refutes the conjecture.

**Impact**: Higher-order e-graphs are the frontier of equality saturation research (POPL 2024 workshops). Proving extraction correctness for lambda calculus would certify optimizations in functional language compilers (GHC, MLton) and proof assistants, directly impacting the tools used to verify other software.

**Catalog References**: `Pythagorean/EGraph/Defs.lean`: `CertifiedNormalizer`, `normalizer_extraction_preserves_eval`

**Proof Strategy**:
1. Define higher-order terms with de Bruijn indices.
2. Define beta-eta reduction as a rewrite system (convergent by normalization theorem for simply-typed lambda calculus).
3. Define denotational semantics in set-theoretic models.
4. Prove soundness of beta-eta for denotational semantics.
5. Apply the extraction correctness theorem.
6. The main challenge is formalizing the strong normalization theorem (already in Mathlib for some fragments).

**Domain Bridges**: Type theory ↔ compiler optimization, denotational semantics ↔ e-graphs, proof theory ↔ program optimization

**Lineage**: Extends the first-order `CertifiedNormalizer` to higher-order terms.

**Ambition**: ★★★★ (High — requires formalizing strong normalization, but builds on existing Mathlib infrastructure)
