# Future Directions: Multi-Sorted Rewriting and Typed Algebra

## Synthesis

The Multi-Sorted Master Theorem opens a nexus connecting type theory, universal algebra, and computational optimization. The five directions below form a coherent research program: Direction 1 extends the equational machinery (completion), Direction 2 enriches the type structure (higher-order), Direction 3 bridges to computational algebra (Gröbner bases), Direction 4 connects to categorical composition (operads), and Direction 5 addresses practical efficiency bounds (complexity). Together, they aim to build a *verified multi-sorted algebraic computation stack* — from equational specification through completion to certified optimization — covering applications from compiler verification to robotics.

Each direction builds on the formalized catalog theorems, enabling incremental formalization: prove each conjecture, add it to the catalog, and use it as a building block for the next.

---

## Direction 1: Multi-Sorted Knuth-Bendix Completion

**Conjecture:** Given a finite set E of multi-sorted equations over a signature with k sorts and a sort-compatible reduction ordering ≻, the multi-sorted Knuth-Bendix completion procedure terminates with a convergent rewrite system R whenever the single-sorted completion of the coproduct encoding terminates. Moreover, |R| ≤ |R'| where R' is the single-sorted completion, with strict inequality when sort constraints eliminate critical pairs.

**Test:** Implement multi-sorted KB completion for 50 randomly generated equational theories with 2-4 sorts and 5-15 equations. Compare the number of rules in the completed system against the coproduct encoding completion. Measure the ratio |R_multi| / |R_single| and verify it is always ≤ 1.

**Impact:** This would provide the first formally verified multi-sorted completion procedure, enabling automatic generation of convergent rewrite systems from equational specifications. Combined with the Master Theorem, this gives an end-to-end pipeline: equations → completion → convergent system → certified normalization.

**Catalog References:**
- `Catalog/Pythagorean/ConvergentRewriteSystems.lean`: `Convergent`, `DerivedFrom`, `convergent_nf_preserves_eval`
- `Catalog/Pythagorean/KnuthBendixCompletion.lean`: single-sorted completion infrastructure
- `Pythagorean/MultiSortedMaster.lean`: `MSConvergent`, `MSDerivedFrom`, `ms_convergent_nf_preserves_eval`

**Proof Strategy:** Adapt the single-sorted completion proof by adding sort-indexed critical pair computation. The key lemma is that sort-incompatible overlaps cannot produce valid critical pairs, reducing the search space. Use the sort-graded complexity measure `MTerm.sortGradedSize` to show that sort constraints provide a tighter termination bound.

**Domain Bridges:** Term rewriting ↔ Automated theorem proving (multi-sorted resolution)

**Lineage:** Extends `ConvergentRewriteSystems.lean` + `KnuthBendixCompletion.lean` → multi-sorted KB

**Ambition:** ★★★☆☆ (Extension of existing techniques to new setting)

---

## Direction 2: Higher-Order Multi-Sorted Rewriting and the Curry-Howard Bridge

**Conjecture (Grand Challenge):** The Multi-Sorted Master Theorem extends to simply-typed λ-calculus with base types corresponding to sorts, where β-reduction and sort-preserving rewrite rules interact. Specifically: for any convergent higher-order rewrite system R over a simply-typed signature, the normal form of a well-typed term evaluates identically to the original in every higher-order model (set-theoretic or domain-theoretic).

**Test:** Formalize a fragment: simply-typed λ-calculus with two base types and 3-5 rewrite rules. Verify evaluation preservation for all terms of depth ≤ 6. If any counterexample is found, identify whether the failure is in confluence, termination, or the interaction between β and R.

**Impact:** This would unify the subject reduction theorems for typed λ-calculi (Wright-Felleisen) with the Master Theorem for rewriting, providing a single framework for verified compilation of functional programming languages. It would subsume both β-reduction preservation and algebraic optimization in one theorem.

**Catalog References:**
- `Pythagorean/MultiSortedMaster.lean`: `subject_reduction`, `ms_convergent_nf_preserves_eval`
- `Catalog/Pythagorean/STLCDefs.lean`: simply-typed λ-calculus definitions
- `Catalog/Pythagorean/StrongNormBisimulation.lean`: strong normalization and bisimulation

**Proof Strategy:** Define higher-order multi-sorted terms as `MTermHO S s` with an additional constructor for λ-abstraction. The key difficulty is the interaction between substitution for λ-variables and substitution for rewrite variables. Use the technique of *higher-order pattern matching* (Miller patterns) to restrict to a decidable fragment. Prove the higher-order substitution lemma by induction on the term structure, with de Bruijn indices for bound variables.

**Domain Bridges:** Type theory ↔ Universal algebra ↔ Programming language semantics

**Lineage:** Extends subject_reduction + STLCDefs → higher-order Master Theorem

**Ambition:** ★★★★★ (Paradigm-shifting unification of two major theories)

---

## Direction 3: Sorted Gröbner Bases for Mixed-Type Polynomial Systems

**Conjecture:** For a multi-sorted polynomial ring R[x₁:s₁, ..., xₙ:sₙ] where variables have assigned sorts and multiplication respects a sort compatibility relation, the Buchberger algorithm adapted with sort-aware S-pair selection terminates and produces a sorted Gröbner basis. The sorted basis has at most C(k,2) · |G|² elements fewer than the unsorted basis, where k is the number of sorts and G is the unsorted basis.

**Test:** Generate 100 random sorted polynomial systems with 2-3 sorts and 4-8 variables. Compute Gröbner bases with and without sort constraints. Verify that: (1) sorted computation always terminates, (2) the sorted basis generates the same ideal restricted to well-sorted polynomials, (3) the sorted basis is never larger than the unsorted basis.

**Impact:** Would enable efficient computation in mixed-type polynomial systems arising in robotics (scalar-angle-position systems), quantum mechanics (amplitude-phase systems), and control theory (state-input systems). The sort constraints would prune the basis computation significantly.

**Catalog References:**
- `Pythagorean/MultiSortedDefs.lean`: `MSig`, `MTerm`, `MAlg`
- `Pythagorean/MultiSortedMaster.lean`: `MSSimplifying`, `ms_simplifying_step_nonincreasing`

**Proof Strategy:** Define sorted polynomials as multi-sorted terms over a ring signature with sorts for each polynomial type. Show that the S-pair criterion adapted for sorts still detects all non-trivial syzygies. Use the sort-graded complexity measure to bound the degree of intermediate polynomials.

**Domain Bridges:** Commutative algebra ↔ Multi-sorted rewriting ↔ Robotics/control theory

**Lineage:** Extends MSig + MSSimplifying → sorted computational algebra

**Ambition:** ★★★★☆ (Novel application domain with concrete practical impact)

---

## Direction 4: Operad-Valued Rewriting and Compositional Systems

**Conjecture (Grand Challenge):** Multi-sorted rewrite systems are morphisms in the category of colored operads, and the Master Theorem is a natural transformation between the identity functor and the normalization functor on the category of operad algebras. Moreover, the composition of convergent rewrite systems (via operad composition) is convergent, with the number of rules bounded by the product of the constituent rule counts times the maximum arity.

**Test:** Formalize the 2-colored operad for a vector space (scalar and vector operations) and verify that composition of "distribute scalar multiplication" and "commute vector addition" rewrite systems yields a convergent system with the expected number of rules. Check for 20 randomly generated 2-3 colored operads.

**Impact:** Would provide a compositional framework for building complex verified optimizers from simple certified components. Each component rewrite system is verified independently, and the composition theorem guarantees correctness of the combined system. This is the algebraic foundation for modular compiler verification.

**Catalog References:**
- `Pythagorean/MultiSortedMaster.lean`: `MSOptimizer`, `MSOptimizer.preserves_eval`
- `Catalog/Pythagorean/MonadAlgebraNormalization.lean`: monadic normalization

**Proof Strategy:** Define colored operads as multi-sorted signatures with a composition structure. Show that operad composition preserves the derivation-from-equations property. The key lemma is that critical pairs of the composed system decompose into critical pairs of the components plus "cross-critical pairs" at composition boundaries. Use the sort-graded complexity to bound cross-critical pairs.

**Domain Bridges:** Category theory ↔ Term rewriting ↔ Modular software verification

**Lineage:** Extends MSOptimizer + MonadAlgebraNormalization → compositional rewriting

**Ambition:** ★★★★★ (Deep categorical insight with practical software engineering impact)

---

## Direction 5: Sort-Aware Complexity Bounds and the Sorted Confluence Conjecture

**Conjecture:** For a multi-sorted signature with k sorts, maximum arity a, and n rewrite rules, the number of sort-respecting critical pairs is at most C(k,2) · a² · n². Furthermore, if the rewrite system is sort-decreasing (result sort ≤ max argument sort in a total order on sorts), the bound improves to k · a · n².

**Test:** Generate 1000 random multi-sorted rewrite systems with parameters k ∈ {2,3,4,5}, a ∈ {1,2,3,4}, n ∈ {3,5,10,15,20}. For each, enumerate all sort-respecting critical pairs and record the count. Plot count vs. the conjectured bound. Report any violations.

For the sort-decreasing refinement: impose a total order on sorts and generate rules where resultSort(lhs) ≤ max argSort. Verify the tighter bound.

**Impact:** Polynomial bounds on critical pair counts directly translate to complexity bounds for completion algorithms. For sort-decreasing systems, the improved bound means completion is feasible for much larger rule sets — important for industrial-scale compiler optimization where rule sets can have hundreds of entries.

**Catalog References:**
- `Pythagorean/MultiSortedMaster.lean`: `sorted_critical_pair_bound_conjecture`, `MTerm.sortGradedSize`, `MTerm.sortGradedSize_sum_eq_size`
- `Catalog/Pythagorean/ConvergentRewriteSystems.lean`: `Confluent`, `Convergent`

**Proof Strategy:** Count overlaps between left-hand sides. Two rules can overlap only if there exists a sort-compatible unifier at the overlap position. The number of sort-compatible positions is bounded by the number of sort-matching argument positions, which is at most a per rule pair. The C(k,2) factor comes from the fact that cross-sort overlaps require sort compatibility between the two rules' sorts.

**Domain Bridges:** Combinatorics ↔ Computational complexity ↔ Compiler optimization

**Lineage:** Extends sorted_critical_pair_bound_conjecture → verified complexity bounds

**Ambition:** ★★★☆☆ (Concrete bound with direct practical applicability)
