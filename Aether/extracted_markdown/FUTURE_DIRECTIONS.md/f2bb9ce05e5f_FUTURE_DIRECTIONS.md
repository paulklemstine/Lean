# Future Directions: Complexity of Hodge-Theoretic Positivity Predicates

## Synthesis

The results in this cycle establish a **complexity phase transition** for Lorentzian polynomial recognition: fixed-degree recognition is polynomial (n^{d-2} leaves), while unbounded-degree recognition faces an exponential barrier (≥ 2^d leaves when n ~ d). This phase transition, combined with the spectral obstruction theorems and the CNF satisfiability framework, opens a research program connecting three previously separate domains: **Hodge-theoretic positivity**, **computational complexity**, and **spectral theory**. The five directions below form a coherent research arc: Direction 1 completes the hardness reduction, Direction 2 exploits the parameterized structure, Direction 3 develops approximation theory, Direction 4 extends to other Hodge predicates, and Direction 5 bridges to proof complexity. Together, they define the new field of **computational Hodge complexity**.

---

## Direction 1: Exact SAT-to-Lorentzian Reduction (Grand Challenge)

**Conjecture**: There exists a polynomial-time computable function f mapping CNF formulas φ to homogeneous polynomials P_φ with nonneg coefficients such that P_φ is Lorentzian if and only if φ is unsatisfiable. This would establish that recognizing non-Lorentzianity with unbounded degree is coNP-hard.

**Test**: Implement the candidate encoding P_φ = Σ_{clauses C} Π_{literals ℓ∈C} x_{var(ℓ)}^{pol(ℓ)} (with appropriate homogenization) and verify the Lorentzian ↔ UNSAT equivalence for all 3-CNF formulas on ≤ 5 variables by exhaustive computation.

**Impact**: This would be the first complexity lower bound for a Hodge-theoretic positivity predicate, establishing a new bridge between algebraic geometry and computational complexity theory. It would motivate the study of approximation algorithms, parameterized complexity, and average-case analysis for Lorentzian recognition.

**Catalog References**: `Pythagorean/LorentzianHardnessReduction.lean` — `complexity_phase_transition`, `multiindex_count_exponential_lower`, CNF satisfiability framework. `Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`, `card_multiindex_le_pow`.

**Proof Strategy**: Encode each clause as a monomial contribution. The homogenization variable absorbs degree slack. Show that derivative branches correspond to partial assignments: each (d−2)-fold derivative direction selects a subset of clauses, and the resulting Hessian has Lorentzian signature iff the selected clauses are "satisfied" by the implicit assignment.

**Domain Bridges**: Computational complexity (Cook-Levin theorem, coNP), algebraic geometry (Hodge theory), proof complexity (resolution lower bounds).

**Lineage**: Builds directly on `complexity_phase_transition` (this cycle) and the CNF framework.

**Ambition**: Paradigm-shifting. Would establish the first known connection between Hodge positivity and NP-hardness.

---

## Direction 2: Parameterized Complexity by Support Treewidth

**Conjecture**: Lorentzian recognition for polynomials whose support has treewidth ≤ w is fixed-parameter tractable in w, with running time O(n^w · d^{O(1)}).

**Test**: For random sparse polynomials with support treewidth ≤ 3 and degrees up to 20, verify that a dynamic-programming algorithm based on tree decomposition of the support runs in polynomial time.

**Impact**: Would provide practical algorithms for Lorentzian recognition in structured cases (matroid theory, graph polynomials) where the support has bounded treewidth.

**Catalog References**: `Pythagorean/LorentzianHardnessReduction.lean` — `leaf_count_polynomial_fixed_degree` (the upper bound that gets refined). `Bridges/LorentzianRecognition.lean` — `multiIndexSet`, `numberOfQuadraticLeaves`.

**Proof Strategy**: Decompose the derivative tree along the tree decomposition of the support. Each bag of the decomposition contributes a bounded-size subproblem. The Hessian check at each leaf only involves variables within a bag and its neighborhood.

**Domain Bridges**: Parameterized complexity (Courcelle's theorem), graph theory (treewidth), matroid theory (matroid support structure).

**Lineage**: Extends `leaf_count_polynomial_fixed_degree` from degree-parameterized to treewidth-parameterized bounds.

**Ambition**: Solid extension. Immediately applicable to matroids and graph polynomials.

---

## Direction 3: Approximate Lorentzian Recognition via SDP Relaxation

**Conjecture**: There exists a polynomial-time SDP-based algorithm that, given a homogeneous polynomial f, either certifies that f is Lorentzian, certifies that f is not Lorentzian, or outputs "inconclusive" — with the guarantee that the inconclusive region has measure zero among "generic" polynomials.

**Test**: Implement an SDP relaxation of the Hessian eigenvalue condition (using the sum-of-squares hierarchy) and measure the fraction of random degree-6 polynomials in 5 variables for which the relaxation is tight.

**Impact**: Would provide practical tools for Lorentzian recognition even in the hard regime, analogous to how SDP relaxations provide practical algorithms for MAX-CUT despite its NP-hardness.

**Catalog References**: `Pythagorean/LorentzianHardnessReduction.lean` — `positive_definite_not_lorentzian`, `neg_semidefinite_is_lorentzian` (spectral boundary conditions). `Bridges/LorentzianRecognition.lean` — `lorentzian_signature_tangent_neg_semidef`.

**Proof Strategy**: Replace the exact eigenvalue check "at most one positive eigenvalue" with a semidefinite feasibility condition. The SDP relaxation checks whether the Hessian can be written as a rank-1 PSD matrix minus a PSD matrix.

**Domain Bridges**: Optimization (SDP, sum-of-squares), real algebraic geometry (Positivstellensatz), machine learning (kernel methods).

**Lineage**: Builds on spectral obstruction theorems from this cycle.

**Ambition**: Solid extension with high practical impact.

---

## Direction 4: Complexity of Schur-Log-Concavity and Complete Log-Concavity (Grand Challenge)

**Conjecture**: The complexity phase transition established for Lorentzian recognition extends to other Hodge-theoretic positivity predicates. Specifically, recognizing Schur-log-concavity or complete log-concavity exhibits the same fixed-degree/unbounded-degree dichotomy.

**Test**: Compute the certificate complexity (number of minors or Schur function evaluations needed) for Schur-log-concavity of random degree-d polynomials in n variables, for d = n = 3,4,5,6,7, and verify exponential growth.

**Impact**: Would establish that the complexity phase transition is a *universal* feature of Hodge-theoretic positivity, not an accident of the Lorentzian definition. This would define the field of "computational Hodge complexity."

**Catalog References**: `Pythagorean/LorentzianHardnessReduction.lean` — `complexity_phase_transition` (template). `Bridges/LorentzianRecognition.lean` — `IsRecursivelyLorentzian` (model for recursive predicates).

**Proof Strategy**: The key insight is that all Hodge-theoretic positivity predicates share a common structure: recursive derivative descent to a base case checked by linear algebra. The multiindex counting argument transfers directly.

**Domain Bridges**: Algebraic combinatorics (Schur functions), representation theory (highest weight modules), tropical geometry (tropical Hodge theory).

**Lineage**: Direct generalization of the phase transition theorem.

**Ambition**: Paradigm-shifting. Would unify multiple Hodge-theoretic positivity notions under a single complexity framework.

---

## Direction 5: Proof Complexity of Lorentzian Certificates

**Conjecture**: There exists a family of non-Lorentzian polynomials (indexed by n) such that any tree-like refutation of their Lorentzianity requires exponential size. In other words, Lorentzian non-recognition certificates have proof complexity analogous to resolution refutations.

**Test**: For the "hard" polynomial families identified in the phase transition theorem, compute the minimal tree-like certificate of non-Lorentzianity and verify exponential growth. Compare with the resolution complexity of the corresponding CNF formulas (if the SAT reduction from Direction 1 is available).

**Impact**: Would establish the first connection between proof complexity and Hodge-theoretic positivity, suggesting that Lorentzian recognition certificates are as hard as resolution proofs.

**Catalog References**: `Pythagorean/LorentzianHardnessReduction.lean` — `certificate_complexity_exponential`, `branch_complexity_barrier`. `Bridges/LorentzianRecognition.lean` — `RecursiveLorentzianCertificate`.

**Proof Strategy**: The key insight is that derivative trees behave like proof trees. An unsatisfiability certificate (resolution tree) and a recursive Lorentzian certificate (derivative tree) may obey parallel lower bounds. Use the pigeonhole principle or random restriction arguments from proof complexity to establish the exponential lower bound.

**Domain Bridges**: Proof complexity (resolution, Frege systems), circuit complexity (monotone circuits), propositional logic.

**Lineage**: Extends `certificate_complexity_exponential` from counting-based to adversarial lower bounds.

**Ambition**: Grand challenge. Would create a new bridge between proof complexity and algebraic geometry.
