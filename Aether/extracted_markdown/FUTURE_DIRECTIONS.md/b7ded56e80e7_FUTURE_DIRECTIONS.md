# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The results in this cycle establish a foundational framework: Lorentzian polynomial recognition exhibits a complexity phase transition between the fixed-degree (tractable) and unrestricted-degree (exponentially hard) regimes. The Boolean-to-multiindex encoding theorem bridges satisfiability to derivative-tree structure, while the exponential lower bounds prove intrinsic certificate complexity barriers.

The five directions below form a coherent research program: Direction 1 closes the SAT reduction gap using the algebraic structure we've uncovered. Direction 2 opens a second front via spectral embeddings. Directions 3–4 develop the parameterized and average-case theory that will eventually characterize the full complexity landscape. Direction 5 connects to proof complexity, creating a deep analogy between Lorentzian certificates and resolution proofs.

Together, these directions would establish **complexity theory of Hodge predicates** as a new subfield, with Lorentzian recognition as its first case study and satisfiability encoding as its foundational technique.

---

## Direction 1: Complete SAT-to-Lorentzian Reduction (Grand Challenge)

**Conjecture**: There exists a polynomial-time computable map from CNF formulas φ to homogeneous polynomials P_φ with nonneg integer coefficients such that P_φ is Lorentzian if and only if φ is unsatisfiable. This would establish coNP-hardness of unrestricted-degree Lorentzian recognition.

**Test**: For each 3-SAT instance on ≤ 6 variables, compute P_φ and verify the Lorentzian ↔ unsatisfiable equivalence by exhaustive Hessian checking. A single counterexample disproves the conjecture.

**Impact**: The first complexity-hardness result for a Hodge-theoretic positivity predicate. Would transform the field's understanding of what "algebraic positivity" means computationally.

**Catalog References**: `Pythagorean/LorentzianHardness.lean` — `boolean_assignment_multiindex_lower_bound`, `assignmentToMultiindex_injective`; `Catalog/Bridges/LorentzianRecognition.lean` — `IsRecursivelyLorentzian`, `hessianMatrix`.

**Proof Strategy**: Use the Boolean-to-multiindex encoding (Theorem C) as the assignment layer. Construct P_φ so that: (a) clause constraints appear as coefficient conditions on specific monomials, (b) unsatisfied assignments produce Hessians with two positive eigenvalues. The key algebraic challenge is designing the monomial structure so the Hessian sign condition at leaf α detects whether the assignment encoded by α satisfies all clauses.

**Domain Bridges**: Computational complexity (Cook–Levin theory) ↔ algebraic combinatorics (Lorentzian polynomials) ↔ spectral theory (Hessian eigenvalues).

**Lineage**: Builds directly on Theorems B and C of this cycle.

**Ambition**: Grand challenge — paradigm-shifting.

> **The key insight is** that the Boolean-to-multiindex injection we've proved provides the combinatorial backbone of a SAT reduction; what remains is the algebraic design of coefficient patterns that make Hessian signatures detect clause satisfaction.

> **Why now?** The formalization of the multiindex-assignment correspondence makes the reduction structure precise for the first time, reducing the problem from "design a reduction from scratch" to "design a polynomial with specified Hessian behavior at known points."

---

## Direction 2: Spectral Embedding — Matrix Positivity to Lorentzian Leaves

**Conjecture**: For any n×n symmetric rational matrix A, there exists a homogeneous polynomial P_A in n+2 variables such that P_A is Lorentzian if and only if A has at most one positive eigenvalue. The construction should be polynomial-time computable.

**Test**: For random 4×4 symmetric matrices, compute P_A and verify the eigenvalue-Lorentzian equivalence against numerical eigenvalue decomposition.

**Impact**: Creates a second reduction route to hardness (from matrix spectral problems) and connects Lorentzian theory to semialgebraic geometry and semidefinite programming.

**Catalog References**: `Catalog/Bridges/LorentzianRecognition.lean` — `HasAtMostOnePositiveEigenvalue`, `QuadForm`, `hessianMatrix`; `Pythagorean/LorentzianHardness.lean` — `multiindex_count_exponential_lower`.

**Proof Strategy**: Embed the matrix A into the Hessian of a carefully constructed quartic polynomial. The degree-2 derivative leaves of this quartic are quadratics whose Hessians are translates of A. If A has two positive eigenvalues, some leaf fails the Lorentzian condition.

**Domain Bridges**: Spectral graph theory ↔ Lorentzian polynomials ↔ semidefinite programming.

**Lineage**: Extends the tangent-space negativity theorem from the catalog.

**Ambition**: Solid extension — builds a new reduction route.

> **The key insight is** that the Hessian matrix of a Lorentzian polynomial's degree-2 leaf *is* the spectral object being tested, so embedding a target matrix into a leaf Hessian is algebraically natural — it's the reverse direction of the recognition procedure.

> **Why now?** The catalog's formalization of `hessianMatrix` and `HasAtMostOnePositiveEigenvalue` provides the exact interface needed for a spectral embedding theorem.

---

## Direction 3: Parameterized Complexity by Treewidth and Support Size

**Conjecture**: Lorentzian recognition is fixed-parameter tractable when parameterized by both degree d and the treewidth of the variable interaction graph (the graph where variables i and j are adjacent if some monomial involves both x_i and x_j). Specifically, for treewidth w and degree d, recognition can be decided in time O(n · w^d).

**Test**: Construct polynomial families with treewidth 2 (path-structured variable interactions) and verify that the Hessian checks factorize along the tree decomposition, reducing the effective leaf count.

**Impact**: Would show that the hardness barrier is not just about degree but about the *interaction complexity* of variables, connecting Lorentzian recognition to structural graph theory.

**Catalog References**: `Pythagorean/LorentzianHardness.lean` — `multiindex_count_exponential_lower`, `leaf_count_exponential_lower`; `Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`.

**Proof Strategy**: For tree-structured polynomials, the Hessian at each leaf decomposes into independent blocks corresponding to subtrees. Use dynamic programming on the tree decomposition to count only the O(w^d) "non-redundant" leaves.

**Domain Bridges**: Parameterized complexity theory ↔ structural graph theory ↔ algebraic combinatorics.

**Lineage**: Refines the upper bound from the catalog and the lower bound from this cycle.

**Ambition**: Solid extension — maps the complexity landscape.

> **The key insight is** that the exponential blowup in our lower bounds requires variables that interact globally (as in the binary-to-multiindex injection); restricting interactions to a tree should recover tractability, exactly as it does for constraint satisfaction problems.

> **Why now?** The explicit lower bound constructions reveal *where* the combinatorial explosion comes from (high-interaction multiindices), making it possible to identify structural parameters that tame it.

---

## Direction 4: Average-Case Lorentzian Recognition and Random Polynomials

**Conjecture**: For random homogeneous polynomials with i.i.d. nonneg coefficients, Lorentzian recognition can be decided in expected polynomial time for any fixed degree, and the probability of Lorentzianity undergoes a sharp threshold as the coefficient distribution varies.

**Test**: Sample 1000 random degree-6 homogeneous polynomials in 10 variables with coefficients drawn from Poisson(λ) for various λ. Measure the fraction that are Lorentzian and the average certificate size.

**Impact**: Would show that worst-case hardness does not preclude efficient average-case algorithms, potentially enabling practical Lorentzian recognition for naturally occurring polynomials.

**Catalog References**: `Pythagorean/LorentzianHardness.lean` — `ExponentialCertificateBarrierConjecture`; `Catalog/Bridges/LorentzianRecognition.lean` — `lorentzian_reversed_cauchy_schwarz`.

**Proof Strategy**: Use the reversed Cauchy–Schwarz inequality (from the catalog) to derive concentration bounds. For "generic" coefficients, the Hessian eigenvalues at each leaf are well-separated, allowing early termination of the spectral test.

**Domain Bridges**: Probability theory ↔ random matrix theory ↔ algebraic combinatorics.

**Lineage**: Motivated by the gap between worst-case lower bounds (this cycle) and practical recognition.

**Ambition**: Solid extension — addresses practical relevance.

> **The key insight is** that random polynomials have coefficient patterns that are far from the adversarial constructions needed for our lower bounds, so the *typical* certificate complexity may be much smaller than the worst case.

> **Why now?** The explicit lower bound families we construct are highly structured; understanding how generic polynomials differ will reveal whether the hardness barrier is ubiquitous or pathological.

---

## Direction 5: Proof Complexity of Lorentzian Certificates (Grand Challenge)

**Conjecture**: Lorentzian derivative trees and resolution proof trees obey parallel lower bounds. Specifically, if a homogeneous polynomial is not Lorentzian, the minimum-size certificate of non-Lorentzianity (a "bad" derivative branch) corresponds to a resolution refutation of a derived Boolean formula, and size lower bounds for resolution proofs transfer to size lower bounds for non-Lorentzian certificates.

**Test**: For the Pigeonhole Principle formulas PHP(n, n-1) (known to require exponential resolution proofs), construct the associated Lorentzian encoding and verify that the minimum non-Lorentzian certificate also has exponential size.

**Impact**: Would create a formal bridge between proof complexity and algebraic positivity, potentially importing decades of lower bound techniques from propositional proof theory into Hodge-theoretic complexity.

**Catalog References**: `Pythagorean/LorentzianHardness.lean` — `boolean_assignment_multiindex_lower_bound`, `CNFFormula`, `branchToMultiindex`; `Catalog/Bridges/LorentzianRecognition.lean` — `RecursiveLorentzianCertificate`.

**Proof Strategy**: Define a "Lorentzian resolution system" where inference steps correspond to derivative operations and contradictions correspond to Hessians with forbidden eigenvalue signatures. Show this system p-simulates (or is p-simulated by) standard resolution.

**Domain Bridges**: Proof complexity ↔ algebraic combinatorics ↔ Hodge theory ↔ computational complexity.

**Lineage**: Extends the Boolean encoding bridge (Theorem C) from representing assignments to representing proofs.

**Ambition**: Grand challenge — paradigm-shifting.

> **The key insight is** that a Lorentzian derivative tree *is* a proof tree — each node verifies a local condition (Hessian signature), and the tree's completeness certifies a global property (Lorentzianity). This structural parallel with resolution proofs is not accidental but reflects a deep correspondence between algebraic positivity and propositional satisfiability.

> **Why now?** The formalization of derivative branches and their connection to Boolean assignments provides the first rigorous framework for stating and testing this correspondence. The `branchToMultiindex` function and `CNFFormula` structure give the exact combinatorial interface needed.
