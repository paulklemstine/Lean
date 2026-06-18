# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The exponential lower bound for recursive Lorentzian recognition (Theorem `multiindex_count_exponential_lower`) and the complexity phase transition (Theorem `complexity_phase_transition`) establish that Lorentzian polynomial recognition undergoes a sharp tractability transition: polynomial-time for fixed degree, exponential for unbounded degree. The cross-domain bridges to SAT (Theorem `sat_obstruction_duality`, Theorem `cnf_branch_lower_bound`) and spectral theory (Theorem `spectral_obstruction_non_lorentzian`) open three major research frontiers: (1) exact reductions establishing coNP-hardness, (2) extension to other Hodge-theoretic positivity predicates, and (3) connections to proof complexity and approximation algorithms. Each direction below builds on the formal infrastructure established in this cycle and aims to deepen the bridge between algebraic combinatorics and computational complexity.

---

## Direction 1: Exact SAT-to-Lorentzian Reduction (Grand Challenge)

**Conjecture.** There exists a polynomial-time computable function f mapping CNF formulas φ (over n variables, m clauses) to homogeneous polynomials P_φ ∈ ℕ[x₁,...,x_{n+k}] of degree O(n+m) such that P_φ is Lorentzian if and only if φ is unsatisfiable. If proved, this establishes that unrestricted-degree Lorentzian recognition is coNP-hard.

**Test.** Implement the candidate encoding P_φ = ∏_{clauses C} (∑_{literals ℓ ∈ C} x_{var(ℓ)}) + slack terms. For all 3-SAT instances with n ≤ 5, verify computationally that P_φ is Lorentzian (all Hessian leaves have ≤ 1 positive eigenvalue) iff φ is unsatisfiable. A single counterexample refutes this specific encoding.

**Impact.** This would be the first complexity lower bound for a Hodge-theoretic positivity predicate, creating a new field at the intersection of algebraic combinatorics and computational complexity. It would motivate parameterized complexity studies (FPT by degree, treewidth, or support size) and approximation algorithms.

**Catalog References.** `Bridges/LorentzianHardness.lean`: `cnf_branch_lower_bound`, `sat_obstruction_duality`, `multiindex_count_exponential_lower`. `Catalog/Bridges/LorentzianRecognition.lean`: `quadratic_leaf_count_le`, `card_multiindex_le_pow`.

**Proof Strategy.** (Strategy A from the main development.) Define P_φ whose monomials encode clause-variable incidences with slack variables for homogeneity. Show that iterated partial derivatives along "assignment directions" produce quadratic forms whose Hessian eigenvalue structure reflects clause satisfaction. The forward direction (unsat → Lorentzian) requires showing all leaves have Lorentzian signature; the reverse (sat → non-Lorentzian) requires constructing a leaf with ≥ 2 positive eigenvalues using the spectral obstruction theorem.

**Domain Bridges.** Computational complexity (Cook–Levin theory), proof complexity (resolution lower bounds), optimization (semidefinite relaxations of SAT).

**Lineage.** Builds directly on `cnf_branch_lower_bound` (this cycle) which establishes the numerical correspondence; the next step is semantic correspondence.

**Ambition.** Grand challenge — would be a landmark result connecting Hodge theory to complexity theory. Estimated 2–4 research cycles.

---

## Direction 2: Certificate Complexity Lower Bounds via Adversarial Arguments

**Conjecture.** For any recursive Lorentzian certificate scheme (not just the standard derivative-tree scheme), there exists a family of homogeneous polynomials with nonneg coefficients requiring certificates of size at least exp(c·d) for some universal constant c > 0.

**Test.** For the specific family p_d = (x₁ + x₂ + ... + x_d)^d (the power-sum polynomial), compute the minimum certificate size by exhaustive search over all partial derivative orderings for d = 3, 4, 5, 6, 7. If the minimum certificate size grows polynomially, the conjecture is refuted for this family.

**Impact.** Would establish that the exponential complexity is intrinsic to the Lorentzian predicate, not an artifact of the standard algorithm. This is the certificate-complexity analogue of circuit lower bounds.

**Catalog References.** `Bridges/LorentzianHardness.lean`: `certificate_complexity_exponential`, `complexity_phase_transition`. `Catalog/Bridges/LorentzianRecognition.lean`: `numberOfQuadraticLeaves`, `quadratic_leaf_count_le`.

**Proof Strategy.** (Strategy B.) Define an abstract certificate model where a certificate is a labeled tree whose leaves are quadratic forms with Lorentzian signature. Construct an adversarial polynomial family where any two distinct derivative orderings produce indistinguishable quadratic forms until depth Ω(d), forcing Ω(n^{Ω(d)}) leaves. Use information-theoretic counting: the number of distinguishable polynomials in the family exceeds the number of certificates of sub-exponential size.

**Domain Bridges.** Proof complexity (resolution width lower bounds), communication complexity (adversarial arguments), algebraic complexity theory (degree lower bounds).

**Lineage.** Extends `certificate_complexity_exponential` from lower bound on one specific scheme to all schemes.

**Ambition.** Solid extension — requires new techniques but follows established complexity-theoretic paradigms. Estimated 1–2 cycles.

---

## Direction 3: Phase Transitions for Other Hodge Predicates

**Conjecture.** The following Hodge-theoretic positivity predicates also exhibit exponential certificate complexity in unbounded degree: (a) complete log-concavity (CLC), (b) ultra-log-concavity, (c) Hodge–Riemann relations for matroids.

**The key insight is** that all three predicates involve checking spectral conditions (eigenvalue sign patterns) on derivative-induced objects, and the multiindex explosion proved in this cycle applies to the derivative tree structure regardless of which spectral condition is checked at the leaves.

**Why now?** The Boolean-to-multiindex injection (`boolToMultiindex_injective`) is predicate-agnostic — it bounds the number of derivative branches, not the spectral test at each branch. This means the exponential lower bound on branch count transfers immediately to CLC and ultra-log-concavity, provided their recognition also proceeds by derivative descent.

**Test.** For the CLC predicate, verify that the standard recognition procedure (derivative descent to quadratic CLC tests) has the same leaf structure as Lorentzian recognition. If so, `multiindex_count_exponential_lower` directly implies exponential CLC certificate complexity.

**Impact.** Would establish a universal complexity barrier for an entire class of algebraic positivity predicates, suggesting a deep connection between Hodge-theoretic structure and computational hardness.

**Catalog References.** `Bridges/LorentzianHardness.lean`: `multiindex_count_exponential_lower`, `boolToMultiindex_injective`.

**Proof Strategy.** Formalize the CLC and ultra-log-concavity predicates in Lean. Show that their recognition procedures use the same multiindex-labeled derivative trees. Apply the existing injection theorem to obtain exponential lower bounds.

**Domain Bridges.** Algebraic geometry (Hodge theory), matroid theory (Hodge–Riemann relations), probability (negative dependence, determinantal processes).

**Lineage.** Direct generalization of `multiindex_count_exponential_lower`.

**Ambition.** Solid extension — mostly definitional work plus reuse of existing lower bound. Estimated 1 cycle.

---

## Direction 4: Spectral Embedding and Matrix Hardness (Grand Challenge)

**Conjecture.** There exists a polynomial-time reduction from the problem of deciding whether a symmetric matrix has at most one positive eigenvalue to unrestricted-degree Lorentzian recognition, via an explicit polynomial encoding of the matrix into a higher-degree homogeneous polynomial whose Lorentzian status reflects the eigenvalue count.

**The key insight is** that the Hessian of a degree-2 polynomial *is* the matrix, so Lorentzian recognition of quadratics reduces exactly to eigenvalue-count certification. The challenge is lifting this from degree 2 to higher degrees via a controlled embedding.

**Why now?** The spectral obstruction theorem (`spectral_obstruction_non_lorentzian`) provides the bridge: non-Lorentzian behavior at a leaf corresponds to having ≥ 2 positive eigenvalue directions. A higher-degree polynomial whose derivative tree includes a leaf matching a given matrix would transfer spectral hardness upward.

**Test.** For random symmetric 5×5 matrices, construct the candidate encoded polynomial and verify that its Lorentzian status matches the eigenvalue count (at most 1 positive eigenvalue ↔ Lorentzian).

**Impact.** Would connect Lorentzian recognition to spectral problems (eigenvalue computation, positive semidefiniteness testing) and potentially to hardness results from real algebraic geometry.

**Catalog References.** `Bridges/LorentzianHardness.lean`: `spectral_obstruction_non_lorentzian`, `HasSecondPositiveDirection`. `Catalog/Bridges/LorentzianRecognition.lean`: `hessianMatrix`, `IsRecursivelyLorentzian`.

**Proof Strategy.** (Strategy C.) Define `matrixEncodedPolynomial(A)` as a degree-(n+2) polynomial whose iterated derivative along a specific multiindex produces a quadratic with Hessian equal to A. Prove that this construction is polynomial-time computable and that the Lorentzian status of the encoded polynomial reflects the eigenvalue structure of A.

**Domain Bridges.** Spectral graph theory (Laplacian eigenvalues), optimization (semidefinite programming), quantum information (entanglement witnesses).

**Lineage.** Builds on `spectral_obstruction_non_lorentzian` and the Hessian-based recognition framework.

**Ambition.** Grand challenge — requires novel algebraic constructions. Estimated 2–3 cycles.

---

## Direction 5: Approximation and Average-Case Lorentzian Recognition

**Conjecture.** While worst-case Lorentzian recognition requires exponential time for unbounded degree, there exists a polynomial-time algorithm that correctly recognizes Lorentzianity for a random homogeneous polynomial with nonneg coefficients with probability ≥ 1 - ε, for any fixed ε > 0, by inspecting O(poly(n, d, 1/ε)) randomly chosen derivative branches.

**The key insight is** that the exponential lower bound is a worst-case result driven by the injection from the Boolean hypercube. For random polynomials, most derivative branches may be highly correlated, allowing subsampling.

**Why now?** The phase transition theorem precisely identifies the hard regime (d ~ n). Understanding whether this hardness is worst-case or average-case has immediate algorithmic implications for log-concavity testing in statistics and machine learning.

**Test.** For random degree-d homogeneous polynomials with d = n (the hard regime), sample k = O(n²) random derivative branches, compute their Hessian eigenvalues, and check if the Lorentzian verdict matches the exact verdict. Measure the agreement rate as a function of k/2^n.

**Impact.** Would initiate the average-case complexity theory of Hodge predicates, with applications to computational statistics (testing log-concavity of empirical distributions) and optimization (certifying convexity of polynomial objectives).

**Catalog References.** `Bridges/LorentzianHardness.lean`: `complexity_phase_transition`, `multiindex_count_exponential_lower`.

**Proof Strategy.** Analyze the variance of the Hessian eigenvalue structure across randomly chosen multiindices. If the variance is low (eigenvalue structure is "self-averaging"), then Chebyshev's inequality gives concentration, and a polynomial sample suffices. If the variance is high, use Johnson–Lindenstrauss–type projections to reduce dimension before spectral testing.

**Domain Bridges.** Statistical learning theory (PAC learning, sample complexity), random matrix theory (Wigner semicircle law), compressed sensing (restricted isometry property).

**Lineage.** Motivated by the gap between worst-case exponential (`multiindex_count_exponential_lower`) and practical tractability for structured instances.

**Ambition.** Solid extension — combines existing lower bounds with standard probabilistic techniques. Estimated 1–2 cycles.
