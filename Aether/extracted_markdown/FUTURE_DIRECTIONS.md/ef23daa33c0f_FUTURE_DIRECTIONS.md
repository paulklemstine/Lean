# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The results in this cycle establish the first exponential lower bounds for derivative-tree Lorentzian recognition, bridge Boolean satisfiability structure to derivative branches via binary multiindices, and characterize diagonal spectral obstruction exactly. Together, these results delineate a *complexity phase transition* between the fixed-degree (polynomial) and unbounded-degree (exponential) regimes.

The five directions below form a coherent research program: Direction 1 completes the SAT reduction to establish formal coNP-hardness; Direction 2 investigates whether structured certificates can bypass the lower bound; Direction 3 places Lorentzian recognition in the parameterized complexity hierarchy; Direction 4 bridges to proof complexity; Direction 5 connects to statistical physics and optimization. Each direction builds on proven catalog theorems and leverages the SAT-branch correspondence and spectral obstruction machinery developed here.

---

## Direction 1: Complete SAT-to-Lorentzian Reduction (Grand Challenge)

**Conjecture**: There exists a polynomial-time computable function mapping CNF formulas to homogeneous polynomials such that the polynomial is Lorentzian if and only if the formula is unsatisfiable. Formally:
```
∃ f : CNFFormula → Σ n, MvPolynomial (Fin n) ℕ,
  polynomial_time f ∧
  ∀ φ, IsLorentzianHomogeneous (f φ).2 ↔ ¬ CNFSatisfiable φ
```

**Test**: Implement the candidate encoding `P_φ` for small CNF instances (n ≤ 6, m ≤ 10 clauses). Verify computationally that P_φ passes all quadratic leaf Hessian checks iff φ is unsatisfiable. A single counterexample — a satisfiable φ whose P_φ passes all checks, or an unsatisfiable φ whose P_φ fails — would disprove the conjecture.

**Impact**: Would establish coNP-hardness of unbounded-degree Lorentzian recognition, the first complexity lower bound for a Hodge-theoretic positivity predicate. Would definitively prove that Hodge positivity can encode Boolean unsatisfiability.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardnessLowerBounds.lean` (binary_indicator_injective, count_assignments_of_weight), `Catalog/Bridges/LorentzianRecognition.lean` (quadratic_leaf_count_le).

**Proof Strategy**: (Strategy A from the architecture.) Define P_φ using clause-variable incidence encoding with slack variables enforcing homogeneity. Show derivative branches at binary multiindices recover truth assignments. Use the diagonal spectral obstruction (two_positive_diagonal_not_lorentzian) to prove that satisfied clauses create Lorentzian-violating Hessians. The forward direction (UNSAT → Lorentzian) is harder and may require a new "universal Lorentzian certificate" construction.

**Domain Bridges**: Computational complexity (Cook-Levin theory), propositional logic, algebraic geometry.

**Lineage**: Extends binary_indicator_injective and count_assignments_of_weight from this cycle.

**Ambition**: Grand challenge. If achieved, opens an entire field of "complexity of Hodge predicates."

---

## Direction 2: Certificate Compression and the Tightness Question

**Conjecture** (Branch-Complexity Barrier): There exists c > 0 such that for every recursive Lorentzian certificate structure (not just the standard derivative tree), the certificate size for the worst-case degree-*d* polynomial is at least exp(c·d).

**Test**: For d = 4, 5, 6, 7, 8, implement a certificate search that tries to verify Lorentzianity using fewer than C(n, d-2) checks by exploiting algebraic identities among derivative leaves. Measure the minimum number of checks needed for random polynomials. If minimum certificate size grows sub-exponentially, the conjecture is false.

**Impact**: Would distinguish between "the standard algorithm is bad" and "the problem is hard." A negative answer (certificates can be compressed) would suggest P ≠ coNP does not follow from this route, but would itself be interesting algorithmically.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardnessLowerBounds.lean` (leaf_count_exponential_in_degree, central_choose_ge_two_pow), `Catalog/Pythagorean/SparseLorentzianCertificates.lean`, `Catalog/Pythagorean/CertificateCompression.lean`.

**Proof Strategy**: Use the support exchange property (SupportSatisfiesExchange from LorentzianRecognitionComplete) to show that algebraic dependencies among derivative leaves are constrained by matroid structure. Prove that matroid exchange forces certificate size ≥ rank of the exchange matroid. Connect to matroid basis enumeration lower bounds.

**Domain Bridges**: Matroid theory, communication complexity, circuit complexity.

**Lineage**: Builds on multiindex_count_ge_choose and the upper/lower bound sandwich.

**Ambition**: Solid extension with potential for surprising negative results.

---

## Direction 3: Parameterized Complexity of Lorentzian Recognition

**Conjecture**: Lorentzian recognition parameterized by degree is fixed-parameter tractable (FPT) with running time f(d) · n^O(1), but is W[1]-hard when parameterized by treewidth of the support hypergraph.

**Test**: Implement FPT algorithm for small d with explicit f(d) running time. Compare against treewidth-parameterized approach for random sparse polynomials. If treewidth parameterization gives polynomial improvement on structured instances, the W[1]-hardness part of the conjecture may be wrong.

**Impact**: Would place Lorentzian recognition precisely in the parameterized complexity landscape, identifying which structural parameters make the problem tractable.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardnessLowerBounds.lean` (leaf_count_exponential_in_degree), `Catalog/Bridges/LorentzianRecognition.lean` (quadratic_leaf_count_le, card_multiindex_le_pow), `Catalog/Pythagorean/TreewidthCertificateDefs.lean`.

**Proof Strategy**: FPT in d follows from quadratic_leaf_count_le (n^(d-2) checks, each in poly(n) time). W[1]-hardness would follow from a parameterized reduction from Clique, using the spectral obstruction to encode edge constraints.

**Domain Bridges**: Parameterized complexity, graph theory, structural decomposition.

**Lineage**: Direct consequence of the phase transition identified in this cycle.

**Ambition**: Solid extension, likely achievable in one cycle.

---

## Direction 4: Proof Complexity of Lorentzian Certificates (Grand Challenge)

**Conjecture**: Recursive Lorentzian certificates are polynomially equivalent to tree-like resolution proofs. Specifically, the minimum certificate size for non-Lorentzianity of a polynomial P is polynomially related to the minimum tree-like resolution refutation size of the associated Boolean formula.

The key insight is that derivative trees in Lorentzian recognition have the same branching structure as resolution proof trees — both are recursively decomposed decision procedures where each branch corresponds to a variable choice.

**Why now?** The SAT-branch correspondence proved in this cycle (binary_indicator_injective, count_assignments_of_weight) shows that derivative branches and truth assignments are the same combinatorial object. The connection to proof trees is the natural next step.

**Test**: For known hard instances of tree-like resolution (e.g., pigeonhole formulas, random 3-SAT near threshold), construct the associated polynomial and measure Lorentzian certificate size. Compare with known resolution lower bounds.

**Impact**: Would create a formal bridge between algebraic positivity certification and propositional proof complexity, two areas with no known connection. Could transfer proof complexity lower bounds (exponential tree-like resolution for PHP) to Lorentzian certificate lower bounds.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardnessLowerBounds.lean` (all theorems), `Catalog/Pythagorean/ClauseSpaceTheorems.lean`.

**Proof Strategy**: Define a "Lorentzian resolution system" where inference rules correspond to derivative operations. Show soundness (each rule preserves Lorentzian obstruction) and completeness (every Lorentzian certificate can be converted to a resolution proof). Transfer Ben-Sasson–Wigderson space-width tradeoffs.

**Domain Bridges**: Proof complexity, propositional logic, circuit complexity.

**Lineage**: Extends the SAT-branch correspondence from this cycle to proof-theoretic setting.

**Ambition**: Grand challenge. Would open "proof complexity of algebraic predicates."

---

## Direction 5: Statistical Physics and Partition Function Positivity

**Conjecture**: For the partition function Z_G(q, v) of the Potts model on a graph G, Lorentzian recognition of Z_G (viewed as a polynomial in vertex activities) undergoes a complexity phase transition at the physical phase transition temperature.

The key insight is that Lorentzian positivity of partition functions is related to absence of phase transitions (Lee-Yang theory), so the complexity of verifying Lorentzianity should spike at critical points.

**Why now?** The spectral obstruction theorem (two_positive_diagonal_not_lorentzian) shows that having two positive Hessian eigenvalues is the precise failure mode. In statistical physics, multiple positive eigenvalues of the transfer matrix correspond to coexisting phases. The bridge is: phase coexistence ↔ spectral obstruction ↔ non-Lorentzianity.

**Test**: Compute Lorentzian certificate sizes for Z_G on small graphs (grid graphs, complete graphs) as a function of temperature. Plot certificate size vs temperature and look for a spike at the known critical temperature.

**Impact**: Would connect computational complexity of positivity testing to physical phase transitions, creating a new bridge between TCS and statistical physics.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardnessLowerBounds.lean` (diagonal_atMostOnePos_of_unique_pos, two_positive_diagonal_not_lorentzian), `Catalog/Pythagorean/DeterminantalStability.lean`.

**Proof Strategy**: Use the transfer matrix formalism. Show that the Hessian eigenvalues of iterated derivatives of Z_G correspond to eigenvalue ratios of the transfer matrix. Apply the diagonal spectral characterization at high/low temperature limits where the transfer matrix is approximately diagonal.

**Domain Bridges**: Statistical physics (Ising/Potts models), spectral graph theory, analytic combinatorics.

**Lineage**: Extends spectral obstruction theorems to physical setting.

**Ambition**: Grand challenge with potential for deep cross-disciplinary impact.
