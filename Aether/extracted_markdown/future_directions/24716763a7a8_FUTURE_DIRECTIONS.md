# Future Directions: Tropical Proof-Net Realization Duality

## Overview

The Tropical Proof-Net Realization Duality theorem establishes a Myhill–Nerode style characterization of minimal weighted derivation structures. This opens several concrete research directions at the intersection of tropical algebra, proof theory, and computational logic.

---

## Direction 1: Tropical Sequent Calculus Realization Theorem

**Goal:** Extend the realization duality from Horn-style rules to full sequent calculus with weighted cuts.

**Precise Target Theorem:**

For a finitary weighted sequent calculus `S` over a finite formula set with weights in an idempotent semiring, the cut-elimination procedure induces a canonical quotient of the entailment kernel. The cut-free fragment realizes the same kernel matrix, and the quotient by residual profiles of cut-free derivations yields a minimal DAG realization that is unique up to cost-preserving bisimulation.

**Proof Strategy:**
1. Define weighted sequent rules with multi-premise/multi-conclusion structure.
2. Show that cut-elimination preserves the entailment kernel values (costs cannot increase).
3. Prove that the residual quotient of the cut-free fragment coincides with the residual quotient of the full system.
4. Apply the existing realization duality to the cut-free fragment.

**Key Lemma (formalizable):**
```
theorem cut_elimination_preserves_kernel
    (S : WeightedSequentSystem F W) (hcut : CutEliminable S) :
    ∀ p q, entailmentKernel S p q = entailmentKernel (cutFreeFragment S) p q
```

**Impact:** This would give a proof-theoretic content to the algebraic realization: the minimal derivation DAG IS the normal form of the proof system.

---

## Direction 2: Proof Complexity Lower Bounds via Tropical Rank

**Goal:** Establish lower bounds on weighted proof length/size using tropical rank of the entailment kernel.

**Precise Target Theorem:**

For a weighted Horn system `C` over `n` formulas with weights in `ℕ∞`, any derivation DAG realizing the entailment kernel must have at least `rank_trop(K)` vertices, where `rank_trop(K)` is the number of distinct rows of the kernel matrix. Moreover, if the kernel matrix has tropical rank `r` (in the semimodule-theoretic sense), then any realization has at least `r` internal vertices.

**Proof Strategy:**
1. Define tropical rank as the minimum number of generators for the row semimodule.
2. Show that each vertex of a realization DAG contributes at most one independent row to the kernel.
3. Conclude that the number of vertices is at least the tropical rank.

**Key Connection:** This mirrors the rank lower bound in algebraic circuit complexity — tropical rank of the entailment kernel is a lower bound on proof DAG size, just as matrix rank bounds circuit size.

**Formalization Target:**
```
theorem tropical_rank_lower_bound
    (C : WeightedConsequenceSystem F W) (D : DerivationDAG V F W)
    (hreal : realizesKernel D (entailmentKernel C)) :
    Fintype.card V ≥ tropicalRank (entailmentKernel C)
```

---

## Direction 3: Learning Minimal Proof-Nets from Entailment Observations

**Goal:** Give an algorithmic and query-complexity characterization of learning the minimal derivation DAG from oracle access to the entailment kernel.

**Precise Target Theorem:**

Given oracle access to `K(p,q)` for arbitrary `p,q ∈ F`, one can reconstruct the canonical quotient DAG using at most `O(|F|² · r)` queries, where `r` is the tropical rank. The algorithm proceeds by:
1. Computing all `|F|²` kernel entries.
2. Identifying residual classes by grouping equal rows (O(|F|² log |F|) time).
3. Constructing the quotient DAG in O(|F| · r) time.

Moreover, `Ω(|F| · r)` queries are necessary in the worst case (information-theoretic lower bound).

**Proof Strategy:**
1. Show that the full kernel matrix determines the quotient completely.
2. Prove that partial kernel information (fewer than |F|·r entries) can leave the quotient ambiguous.
3. Formalize the reconstruction algorithm as a decision procedure.

**Application:** This connects to the theory of learning weighted automata from behavioral observations, and to the problem of inferring logical structure from query access to a reasoning oracle (relevant to interpretability of AI systems).

---

## Direction 4: Categorical Duality for Weighted Consequence Operators

**Goal:** Establish a full categorical duality between the category of finite weighted consequence operators and the category of finite weighted derivation DAGs.

**Precise Target:**

Define:
- **WConOp**: the category whose objects are finite weighted consequence systems `(F, C)` and whose morphisms are cost-preserving maps `φ: F₁ → F₂` satisfying `K₂(φ(p), φ(q)) ≤ K₁(p, q)`.
- **WDAG**: the category whose objects are finite weighted derivation DAGs and whose morphisms are cost-preserving DAG morphisms.

Then the canonical realization functor `R: WConOp → WDAG` and the behavior functor `B: WDAG → WConOp` form an adjunction, and the minimal realization is the counit of this adjunction.

**Proof Strategy:**
1. Define the categories formally using Mathlib's category theory library.
2. Show that the quotient construction is functorial.
3. Prove the adjunction by verifying the universal property.

**Key Formalization:**
```
def realizationFunctor : WConOp ⥤ WDAG := ...
def behaviorFunctor : WDAG ⥤ WConOp := ...
theorem realization_behavior_adjunction : realizationFunctor ⊣ behaviorFunctor := ...
```

**Impact:** This would be the first categorical duality theorem for weighted proof systems, analogous to Stone duality for Boolean algebras or Pontryagin duality for abelian groups.

---

## Direction 5: Extension to Resource-Sensitive Logic and Linear Logic

**Goal:** Generalize the realization duality from Horn systems to multiplicative linear logic (MLL) proof nets.

**Precise Target:**

For MLL proof nets with tropical cost annotations, the entailment kernel becomes a matrix over a non-commutative tropical semiring (tracking resource consumption). The residual quotient construction still applies, but the resulting minimal proof net has richer structure: it is a DAG with tensor/par nodes preserving the linear logic structure.

**Key Challenge:** In linear logic, formulas are consumed by derivation, so the "singleton cost" must track resource budgets. The closure operator becomes a resource-sensitive map, and idempotency fails in general. The replacement axiom is **contractibility**: the closure is idempotent only on the contractible fragment.

**Proof Strategy:**
1. Define resource-annotated proof nets with tropical weights.
2. Identify the contractible sub-system where idempotency holds.
3. Apply the existing duality to the contractible fragment.
4. Extend to the full system using a coherence theorem for resource allocation.

**Impact:** This connects tropical proof theory to the deep structure of linear logic, potentially yielding new results in proof net theory and resource-sensitive reasoning.

---

## Cross-Cutting Technical Challenges

### Tropical Gröbner Bases for Consequence Compression
Define a tropical analogue of Gröbner bases for weighted consequence systems. A "tropical consequence Gröbner basis" would be a finite generating set for the kernel row semimodule that satisfies a normal form property. The division algorithm would correspond to proof simplification, and the S-polynomial criterion would correspond to critical pair analysis in proof search.

### Weighted Proof Search as Tropical Optimization
Frame proof search in weighted Horn systems as a tropical linear programming problem. The dual of finding a minimum-cost derivation is finding a maximum separation between formula costs, which corresponds to the tropical analogue of LP duality. This could yield new proof search algorithms with certified optimality.

### Connections to Tropical Geometry
The entailment kernel matrix defines a tropical variety (the set of cost valuations compatible with the consequence system). The minimal realization corresponds to a tropical fan structure. Investigate whether tools from tropical geometry (Newton polytopes, tropical Grassmannians) yield structural results about proof complexity.
