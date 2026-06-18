# Future Directions: Certified Mathematical Significance Metrics

## Research Roadmap — Breakthrough Opportunities

This document outlines five concrete, actionable research directions opened by the formalized significance valuation theory. Each direction includes hypotheses, proof strategies, and cross-domain connections that a research team can immediately pursue.

---

## 1. Matroidal Independence of Research Contributions

**Hypothesis:** The modular valuation `σ(K₁ ∪ K₂) + σ(K₁ ∩ K₂) = σ(K₁) + σ(K₂)` extends to a full matroid rank function when weights are restricted to `{0, 1}`.

**Proof Strategy:**
- Define a matroid on `α` where independent sets are those whose `{0,1}`-weighted significance equals their cardinality.
- Prove the exchange axiom: if `|I₁| < |I₂|` and both are independent, there exists `a ∈ I₂ \ I₁` such that `I₁ ∪ {a}` is independent.
- Connect rank to significance: `rank(K) = σ_{0,1}(K)`.
- Formalize "redundant repackaging" as dependence in this matroid: a theorem that adds no independent weight is formally redundant.

**Cross-Domain Connections:**
- Matroid theory (Whitney, Tutte)
- Linear algebra rank
- Information-theoretic independence
- Greedy algorithm optimality for selecting maximally diverse theorem packages

**Deliverables:** Lean formalization of a significance-matroid, proof of the exchange property, and a greedy selection algorithm with certified optimality.

---

## 2. Formal Mutual Information Between Theorem Families

**Hypothesis:** Given two knowledge domains `D₁, D₂ : Finset α` with respective closures under a `ClosureOp`, the quantity `I(D₁; D₂) = σ(cl(D₁)) + σ(cl(D₂)) - σ(cl(D₁ ∪ D₂))` defines a non-negative, symmetric measure of shared inferential content.

**Proof Strategy:**
- Use the modularity theorem to express `I` in terms of intersection closures.
- Prove non-negativity from submodularity of closure-weighted significance (which may fail for general closures — characterize when it holds).
- Prove that `I(D₁; D₂) = 0` iff `cl(D₁) ∩ cl(D₂) = cl(∅)` under appropriate conditions.
- Connect to conditional entropy: define `H(D₁ | D₂) = σ(cl(D₁ ∪ D₂)) - σ(cl(D₂))`.

**Cross-Domain Connections:**
- Shannon information theory
- Kolmogorov complexity of proofs
- Data processing inequality for theorem transformations

**Deliverables:** Lean definitions of mutual information and conditional entropy for knowledge states, with proofs of basic properties (non-negativity, symmetry, chain rule).

---

## 3. Tropical / Max-Plus Significance Semantics

**Hypothesis:** Replacing the additive significance `σ(K) = Σ w(a)` with the tropical (max-plus) significance `σ_trop(K) = max_{a ∈ K} w(a)` yields a semiring valuation that captures "best breakthrough dimension dominates" semantics.

**Proof Strategy:**
- Define tropical significance using `Finset.sup` with the `WithBot ℕ` order.
- Prove monotonicity: `K₁ ⊆ K₂ → σ_trop(K₁) ≤ σ_trop(K₂)`.
- Prove the tropical valuation identity: `σ_trop(K₁ ∪ K₂) = max(σ_trop(K₁), σ_trop(K₂))`.
- Prove tropical threshold crossing: `σ_trop(K_old) < τ ≤ σ_trop(K_new)` implies existence of a "star theorem" with weight ≥ τ.
- Connect to existing tropical bridge theorems in the catalog.

**Cross-Domain Connections:**
- Tropical geometry and idempotent analysis
- Min-max optimization
- Bottleneck path problems in dependency graphs
- The catalog's `tropChar_class_function` as a witness

**Deliverables:** Formalized tropical significance with monotonicity and threshold theorems, explicit connection to the existing tropical algebraic catalog.

---

## 4. Dependency-Graph Spectral Significance

**Hypothesis:** The spectral radius (largest eigenvalue) of the adjacency matrix of the theorem dependency DAG provides a lower bound on significance that captures "network effect" — highly connected theorem clusters have disproportionate significance.

**Proof Strategy:**
- Model the dependency graph as a `SimpleGraph (Fin n)` or adjacency matrix `Matrix (Fin n) (Fin n) ℝ`.
- Define spectral significance as the Perron–Frobenius eigenvalue of the adjacency matrix.
- Prove that adding an edge (new dependency) can only increase the spectral radius (monotonicity under edge addition).
- Prove a lower bound: spectral significance ≥ average degree of the dependency graph.
- Connect to PageRank-style authority scores on theorems.

**Cross-Domain Connections:**
- Spectral graph theory (Chung, Spielman)
- PageRank and eigenvector centrality
- Algebraic graph theory
- The catalog's `key_dimension_lower_bound_from_height`

**Deliverables:** Lean formalization of spectral significance for finite dependency graphs, monotonicity under graph extension, and lower bounds from degree sequences.

---

## 5. Extraction from Actual Lean `Expr` Proof Terms

**Hypothesis:** The abstract `ProofShape` feature extraction can be instantiated on actual Lean 4 kernel expressions (`Lean.Expr`) to produce computable significance scores for real formalized mathematics.

**Proof Strategy:**
- Define a metaprogramming function `Lean.Expr → ProofShape Name` that maps kernel proof terms to abstract proof shapes by extracting constant references.
- Define `features` extraction on `Lean.Expr` directly, producing `Finset Name` of referenced declarations.
- Prove (in Lean's meta-theory) that the extracted features are sound: every name in `features(e)` is transitively referenced by the kernel term `e`.
- Build a `#eval`-able significance calculator that takes a declaration name and returns its significance score.
- Integrate with CI: a GitHub Action that computes significance deltas for each PR.

**Cross-Domain Connections:**
- Lean 4 metaprogramming and elaboration
- Static analysis of proof terms
- Software engineering metrics (cyclomatic complexity, coupling)
- The `ProofShape.features_card_le_size` bound as a sanity check

**Deliverables:** A Lean 4 meta-library that computes significance from real proof terms, with a command-line interface and CI integration template. This would be the first practical deployment of certified significance metrics.

---

## Timeline and Priority

| Direction | Difficulty | Impact | Recommended Order |
|-----------|-----------|--------|-------------------|
| 3. Tropical Significance | Medium | High | First (builds on existing catalog) |
| 1. Matroid Independence | Medium | Very High | Second (foundational theory) |
| 5. Expr Extraction | High (engineering) | Transformative | Third (practical deployment) |
| 2. Mutual Information | High | High | Fourth (deep theory) |
| 4. Spectral Significance | Very High | High | Fifth (requires linear algebra infra) |

---

## Iteration Protocol

Each direction should follow this cycle:

1. **Hypothesize**: State the main conjecture formally in Lean with `sorry`.
2. **Decompose**: Break into 3–8 helper lemmas.
3. **Validate**: Test with `#eval` on concrete examples.
4. **Prove**: Use the theorem-proving infrastructure to fill sorries.
5. **Connect**: Link to existing catalog theorems.
6. **Publish**: Write up as a standalone module with documentation.
7. **Repeat**: Each proved theorem suggests 2–3 new conjectures.

This creates a self-reinforcing research flywheel where each cycle strengthens the significance theory and validates its own predictions about knowledge growth.
