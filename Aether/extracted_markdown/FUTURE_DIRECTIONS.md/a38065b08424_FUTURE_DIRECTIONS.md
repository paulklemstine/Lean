# Future Directions

## Synthesis

This work establishes a verified foundation for lambda calculus metatheory: confluence via parallel reduction, uniqueness of normal forms, and computational Böhm tree approximants. The next cycle should build on these foundations in three directions: (1) completing the strong normalization proof for STLC, (2) connecting reduction complexity to type structure, and (3) bridging lambda calculus semantics to existing catalog results in tropical proof theory and temporal fixpoint semantics.

---

### Direction 1: Strong Normalization for STLC via Reducibility Candidates

**Conjecture**: Every well-typed simply-typed lambda term is strongly normalizing, provable via Tait's reducibility method with a formal semantic interpretation indexed by types.

**Test**: Define `Red : Ty → Lam → Prop` by recursion on types. Prove the fundamental theorem: every well-typed term under a reducible substitution is reducible. Instantiate with identity to get SN. If any step fails, the reducibility predicate needs adjustment.

**Impact**: Completes the theoretical stack from syntax to proof theory. SN is the gateway to decidable type checking, canonicity, and certified compilation.

**Catalog References**: `Logic/LambdaCalculus/STLC.lean` (skeleton), `Catalog/FINAL/Logic/TropicalCurryHoward.lean` (normalization as semantics precedent).

**Proof Strategy**: Define reducibility by recursion on Ty. Base type: SN. Arrow type: closed under application to reducible arguments. Prove closure properties (CR1-CR3). Prove fundamental theorem by induction on typing derivations.

**Domain Bridges**: Connects to proof theory (Curry-Howard), certified compilation, and type-theoretic foundations.

**Lineage**: Builds directly on the confluence and substitution calculus established in this cycle.

**Ambition**: ★★★★☆ — Classical result but technically demanding formalization.

---

### Direction 2: Reduction Tree Branching Bounded by Type Complexity

**Conjecture**: For closed simply-typed lambda terms of size n with maximum type depth d, the number of distinct β-reducts reachable within k steps grows as O(n^d) rather than exponentially.

**Test**: Enumerate simply-typed closed terms up to size 15. For each, compute `|reductsUpToDepth(t, k)|` and compare against n^d and 2^k. A single family achieving exponential growth falsifies the conjecture.

**Impact**: Would establish a formal complexity-theoretic separation between typed and untyped reduction, connecting type theory to computational complexity.

**Catalog References**: `Catalog/FINAL/Logic/QueryComplexity.lean` (binary tree bounds), `Catalog/FINAL/Logic/EntanglementDifficulty.lean` (branching processes).

**Proof Strategy**: Define a weight function on typed terms that decreases under reduction. Show the weight bounds the branching factor at each step. Use the catalog's `binary_tree_leaves_bound` to bound total reachable terms.

**Domain Bridges**: Connects lambda calculus to query complexity, branching processes, and computational complexity theory.

**Lineage**: Builds on reduction tree definitions from this cycle and type structure from STLC.

**Ambition**: ★★★★★ — Would be a novel result connecting type theory to complexity.

---

### Direction 3: Böhm Approximant Separation Depth is Linear

**Conjecture**: For closed lambda terms of size ≤ N, if t and u are not βη-equivalent, then there exists n ≤ 2N such that `bohmApprox n t ≠ bohmApprox n u`.

**Test**: Enumerate all closed terms up to size N = 10. For each pair, compute approximants up to depth 2N. Any pair that is inequivalent but indistinguishable at depth 2N falsifies the conjecture.

**Impact**: Would give a practical decidability criterion for equivalence within bounded term classes, connecting infinitary semantics to finite computation.

**Catalog References**: `Logic/LambdaCalculus/Bohm.lean` (Böhm approximants).

**Proof Strategy**: Relate separation depth to the structure of head normal forms. Show that the "depth" of the first point of disagreement in Böhm trees is bounded by term size via a structural argument.

**Domain Bridges**: Connects Böhm tree semantics to computational decidability and observational equivalence.

**Lineage**: Builds directly on the Böhm approximant framework from this cycle.

**Ambition**: ★★★☆☆ — Testable and likely true for small terms, but may fail for pathological examples.

---

### Direction 4: Tropical Energy Interpretation of Normalization

**Conjecture**: There exists a function `tropicalPotential : STm Γ A → ℕ` such that every typed β-reduction step strictly decreases the potential, providing an "energy dissipation" interpretation of normalization.

**Test**: Define candidate potentials (e.g., sum of subterm sizes weighted by type depth). Verify monotone decrease on all reduction steps for terms up to size 20. A single counterexample (increase under reduction) falsifies the candidate.

**Impact**: Would create a formal bridge between normalization and tropical/energy semantics, connecting proof theory to optimization.

**Catalog References**: `Catalog/FINAL/Logic/TropicalCurryHoward.lean` (normalization as semantics, tropical confluence).

**Proof Strategy**: Mirror the architecture of `normalization_is_semantics` from the tropical Curry-Howard module. Define potential as a tropical cost function. Prove monotone decrease by case analysis on typed reduction rules.

**Domain Bridges**: Connects lambda calculus to tropical geometry, optimization theory, and energy-based models of computation.

**Lineage**: Combines the confluence framework from this cycle with the tropical proof theory in the catalog.

**Ambition**: ★★★★★ — Grand challenge connecting disparate mathematical domains.

---

### Direction 5: Behavioral Equivalence via Finite Transition Systems

**Conjecture**: β-equivalent lambda terms induce bisimilar finite transition systems under a bounded reduction semantics, connecting Church-Rosser to behavioral equivalence in temporal logic.

**Test**: Define `toFTS : Lam → FTS` mapping terms to finite transition systems (states = reducts up to depth d, transitions = one-step β). Verify that β-equivalent terms produce bisimilar FTS for d ≤ 10.

**Impact**: Would formally bridge operational semantics of lambda calculus to model checking and temporal logic, enabling verification of higher-order programs via finite-state methods.

**Catalog References**: `Catalog/FINAL/Logic/TemporalFixpointSemantics.lean` (behavioral equivalence), `Catalog/FINAL/Logic/TemporalStoneBridge.lean` (temporal-stone duality).

**Proof Strategy**: Use Church-Rosser to show that β-equivalent terms have isomorphic reduction DAGs up to any finite depth. Transfer this isomorphism to FTS bisimulation using the catalog's `behavEquivTLF_equivalence`.

**Domain Bridges**: Connects lambda calculus to temporal logic, model checking, and process algebra.

**Lineage**: Combines the confluence theorem from this cycle with temporal semantics from the catalog.

**Ambition**: ★★★★☆ — Novel cross-domain connection with practical implications.
