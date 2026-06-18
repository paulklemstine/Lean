# Future Directions: Tropical Proof Theory

This document outlines concrete, breakthrough-level research opportunities opened by the formalization of tropical Curry–Howard correspondences. Each direction is specific enough for immediate pursuit, with clear hypotheses, proof strategies, and cross-domain connections.

---

## 1. Typed Tropical Lambda Calculus with Cost Semantics

**Goal:** Extend the tropical proof calculus with variables, abstraction, and application to create a full tropical lambda calculus. Prove a tropical β-normalization theorem where reduction computes least-cost programs.

**Concrete next steps:**
- Add `var : Nat → TropTerm`, `lam : TropTerm → TropTerm`, `app : TropTerm → TropTerm → TropTerm` to the syntax.
- Define β-reduction: `app (lam t) s → subst t s`, with cost = cost of substituted body.
- Define a typed version where types carry tropical costs: `A ⊗ B` (tensor, costs add), `A & B` (with, costs take minimum).
- Prove strong normalization of the typed calculus via a typed polynomial interpretation.
- Prove subject reduction: typing is preserved under cost-aware β-reduction.

**Hypothesis:** The typed tropical lambda calculus has a decidable type-checking problem, and the principal type of a term encodes the optimal cost of all implementations of the same specification.

**Cross-domain connections:**
- **Resource-sensitive type systems:** Connects to linear types, bounded linear logic, and quantitative type theory (QTT).
- **Cost analysis:** Types as cost bounds; normalization as certified cost optimization.
- **Weighted automata:** Typed tropical programs correspond to weighted tree automata.

---

## 2. Confluence via Tropical Canonical Forms

**Goal:** Resolve the confluence gap identified in this work. The current rewrite system lacks syntactic uniqueness of normal forms because `min` is commutative and associative but these properties are not captured by directed rewrite rules.

**Concrete next steps:**
- Define a **canonical form** as a sorted, right-associated, deduplicated list of min-branches: `min(t₁, min(t₂, ... min(tₙ₋₁, tₙ)))` where each tᵢ is min-free and t₁ ≤ t₂ ≤ ... ≤ tₙ in a total order on TropTerm.
- Define an executable `canonicalize : TropTerm → TropTerm` function.
- Prove: `eval (canonicalize t) = eval t` and `Normal (canonicalize t)`.
- Prove: `ReflTransGen Step t (canonicalize t)` (the canonical form is reachable).
- Prove: `canonicalize u = canonicalize v` whenever `ReflTransGen Step t u ∧ Normal u ∧ ReflTransGen Step t v ∧ Normal v`.

**Hypothesis:** The canonical form is unique, giving syntactic confluence modulo AC of min. The canonicalization function is computable in O(n log n) time via sorting.

**Proof strategy:** Use the polynomial interpretation for termination of the extended system (with oriented AC rules). Prove local confluence by exhaustive critical pair analysis on the small rule set augmented with ordered commutativity and right-associativity.

---

## 3. Completeness Against Weighted Automata and Shortest-Path Algebras

**Goal:** Show that tropical proof terms correspond precisely to path expressions in finite weighted DAGs, establishing a formal bridge between proof theory and combinatorial optimization.

**Concrete next steps:**
- Define `TropDAG` as a weighted directed acyclic graph with a source and sink.
- Define `pathCost : TropDAG → Nat` as the minimum-weight source-to-sink path.
- Define `encode : TropDAG → TropTerm` that builds a proof term representing all paths.
- Prove: `eval (encode G) = pathCost G` for all DAGs G.
- Prove a **completeness theorem**: every TropTerm in normal form is the encoding of some DAG.
- Prove an **equivalence theorem**: two TropTerms have the same eval iff their corresponding DAGs have the same shortest path.

**Hypothesis:** The free idempotent semiring on n generators is isomorphic to the semiring of path expressions in DAGs with n edge labels. Tropical proof normalization is a syntactic manifestation of the algebraic normal form in this semiring.

**Cross-domain connections:**
- **Network optimization:** Certified shortest-path algorithms via proof normalization.
- **Viterbi algorithm:** The most likely state sequence in an HMM corresponds to a tropical normal form.
- **Algebraic path problems:** Generalize from (ℕ, min, +) to arbitrary closed semirings.

---

## 4. Tropical Linear Logic Fragment

**Goal:** Replace naive `cut` with a resource-sensitive connective and prove a genuine linear Curry–Howard theorem with min-plus denotation.

**Concrete next steps:**
- Define a **linear tropical type system** where each hypothesis is used exactly once (no contraction or weakening).
- Separate `cut` into a multiplicative connective (⊗, tensor) and `min` into an additive connective (&, with).
- Define the proof rules so that tensor proofs compose costs and with proofs minimize costs.
- Prove a **linear cut elimination theorem**: cuts can be eliminated in the typed setting.
- Prove that linear tropical proofs correspond to single-use resource allocations with optimal cost.

**Hypothesis:** The linear fragment has a polynomial-time normalization procedure (no exponential blowup from distribution), making it suitable for certified cost analysis of linear programs.

**Cross-domain connections:**
- **Linear logic:** Connects Girard's linear logic to tropical geometry.
- **Petri nets:** Linear proofs correspond to Petri net executions with cost.
- **Quantum computing:** The no-cloning principle in quantum information parallels linearity; tropical costs model gate counts.

---

## 5. Certified Proof Search and Complexity Bounds

**Goal:** Extract an executable normalizer from the Lean formalization and prove tight complexity bounds on the normalization procedure.

**Concrete next steps:**
- Define `normalize : TropTerm → TropTerm` as a computable Lean function (using well-founded recursion on `interp`).
- Prove correctness: `eval (normalize t) = eval t`, `Normal (normalize t)`, and `ReflTransGen Step t (normalize t)`.
- Analyze worst-case complexity: normalization can produce exponentially larger terms (distribution duplicates subterms). Prove an upper bound on normal form size.
- Investigate polynomial-time fragments: identify syntactic restrictions (e.g., bounded depth, bounded branching) under which normalization is polynomial.
- Implement a Lean `#eval`-capable normalizer and benchmark on large terms.

**Hypothesis:** The worst-case normal form size is O(2^(cutMinDepth)) where cutMinDepth is the maximum nesting depth of cuts above mins. For fixed cutMinDepth, normalization is polynomial.

**Cross-domain connections:**
- **Verified optimization:** Extract certified optimizers from proofs.
- **Compilation:** Normalization as a compilation pass for min-plus programs.
- **Proof compression:** Measure the information content of tropical proofs.

---

## Cross-Cutting Themes

### Tropical Geometry Bridge
Normal forms in the tropical proof calculus correspond to tropical polynomials in canonical presentation. The evaluation function `eval` is a tropical polynomial evaluation. Proof equivalence classes (up to rewriting) correspond to the combinatorial types of tropical hypersurfaces. This suggests a deep connection between proof-theoretic normal forms and Newton polytopes.

### Weighted Proof Search
The tropical Curry–Howard correspondence suggests a new paradigm for automated theorem proving: instead of searching for *any* proof, search for the *cheapest* proof. The normalization procedure provides a certified way to simplify proofs and extract optimal cost, connecting to weighted model counting and probabilistic logic programming.

### Semiring Generalization
The current formalization uses (ℕ, min, +) — the tropical semiring. The same framework applies to:
- (ℝ≥0 ∪ {∞}, min, +) — the extended tropical semiring
- (ℝ, max, +) — the max-plus semiring (used in scheduling theory)
- (Bool, ∨, ∧) — Boolean semiring (classical logic)
- (ℕ ∪ {∞}, min, max) — the lattice semiring
- Matrices over tropical semirings — tropical linear algebra

Each instantiation gives a different "computational logic" with its own normalization theory.

---

## Team Directive

Each future direction should be pursued by a team that:
1. **Formalizes definitions and conjectures** in Lean 4, building on the existing `TropicalCurryHoward` module.
2. **Tests conjectures computationally** using Python prototypes before formal proof attempts.
3. **Proves helper lemmas** incrementally, validating the proof skeleton before attacking main theorems.
4. **Documents cross-domain connections** explicitly, maintaining the bridge between proof theory, algebra, and applications.
5. **Iterates** between formalization and mathematical insight, using failed proof attempts to refine conjectures.

The goal is not merely to prove theorems, but to develop **tropical proof theory** as a unified framework connecting logic, optimization, and computation.
