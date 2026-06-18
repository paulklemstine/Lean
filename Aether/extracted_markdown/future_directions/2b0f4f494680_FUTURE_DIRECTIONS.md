# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The results in this cycle establish three pillars of a nascent complexity theory for Lorentzian (Hodge-theoretic) positivity predicates:

1. **Exponential lower bounds** on derivative-tree certificate size (Theorem A / `quadratic_leaf_count_lower_bound`)
2. **Structural duality** between Boolean satisfiability and Lorentzian branch obstruction (Theorem B / `branch_sat_duality`)
3. **Spectral obstruction mechanism** connecting positive-definite subspaces to Lorentzian failure (Theorem C / `positive_definite_not_lorentzian`)

Together, these form the infrastructure for a full complexity classification of Lorentzian recognition. Each future direction below extends one or more of these pillars toward a deeper result.

---

## Direction 1: Complete SAT-to-Lorentzian Reduction

**Conjecture**: There exists a polynomial-time computable map f from CNF formulas φ over n variables to homogeneous polynomials P_φ in O(n) variables such that P_φ is Lorentzian if and only if φ is unsatisfiable. This would establish coNP-hardness of unrestricted-degree Lorentzian recognition.

**Test**: Implement the candidate encoding (using clause-variable incidence matrices to define polynomial coefficients) and verify the correspondence on all 3-SAT instances with ≤ 6 variables by brute-force checking both satisfiability and Lorentzianity of the encoded polynomial.

**Impact**: This would be the first complexity hardness result for a Hodge-theoretic positivity predicate, opening the field of "computational Hodge theory." It would demonstrate that Lorentzian positivity is not merely an algebraic property but a computationally expressive language.

**Catalog References**: Builds directly on `Pythagorean/LorentzianHardness.lean` (branch_sat_duality, two_positive_directions_defeat_lorentzian), `Bridges/LorentzianRecognition.lean` (quadratic_leaf_count_le), `Pythagorean/LorentzianRecognitionComplete.lean` (recursivelyLorentzian_iff_brandenHuh).

**Proof Strategy**: Strategy A from the current work — direct CNF-to-derivative-tree reduction. The key missing piece is the explicit polynomial construction P_φ. Use slack variables to enforce homogeneity, clause-variable incidence to define coefficients, and prove that directional derivatives correspond to literal selections. The spectral obstruction theorem provides the mechanism for translating satisfying assignments into non-Lorentzian leaves.

**Domain Bridges**: Computational complexity ↔ algebraic geometry, Cook-Levin theory ↔ Hodge theory.

**Lineage**: This is the flagship endgame theorem that motivated the entire cycle. The current results provide all structural ingredients except the explicit encoding construction.

**Ambition**: Grand challenge — paradigm-shifting. If proved, it fundamentally changes how the algebraic combinatorics community thinks about Lorentzian polynomials.

**The key insight is**: The derivative tree of a polynomial is not merely an algebraic computation tree — it is a semantic computation tree whose branching structure can encode Boolean constraint satisfaction.

**Why now?** The Branch-SAT Duality and Spectral Obstruction theorems provide, for the first time, the formal bridge needed to translate between Boolean and algebraic obstruction.

---

## Direction 2: Parameterized Complexity of Lorentzian Recognition

**Conjecture**: Lorentzian recognition is fixed-parameter tractable (FPT) when parameterized by degree d (as established), but W[1]-hard when parameterized by the number of variables n with unbounded degree.

**Test**: Formalize the FPT result (already implicit in `quadratic_leaf_count_le`) and attempt to prove W[1]-hardness by reduction from k-Clique or k-Independent Set, encoding graph structure into polynomial derivative patterns.

**Impact**: Would establish a complete parameterized complexity map for Lorentzian recognition, guiding algorithm designers toward the right parameter regimes.

**Catalog References**: `Bridges/LorentzianRecognition.lean` (card_multiindex_le_pow, quadratic_leaf_count_le), `Pythagorean/LorentzianHardness.lean` (phase_transition, certificate_complexity_polynomial_upper).

**Proof Strategy**: For FPT in d: directly from `quadratic_leaf_count_le`, the number of checks is n^(d−2) with each check polynomial in n, giving n^O(d) total. For W[1]-hardness: encode k-Clique instances as polynomials whose degree equals the graph size, and show that Lorentzian recognition requires inspecting all k-tuples of vertices.

**Domain Bridges**: Parameterized complexity ↔ algebraic combinatorics, graph theory ↔ polynomial positivity.

**Lineage**: Direct extension of the phase transition theorem. The fixed-degree tractability is already proved; the hardness side needs formalization.

**Ambition**: Solid extension — builds systematically on catalog results.

**The key insight is**: The parameter that controls complexity is not the polynomial's "size" (number of monomials) but its *degree* — a purely algebraic quantity with no obvious combinatorial meaning a priori.

**Why now?** The phase transition theorem proves that degree is the critical parameter. The next step is to classify exactly how degree controls complexity in the parameterized sense.

---

## Direction 3: Proof Complexity of Lorentzian Certificates

**Conjecture**: Lower bounds on Lorentzian certificate size imply lower bounds in algebraic proof complexity. Specifically, the exponential lower bound on derivative-tree certificates translates to an exponential lower bound on the size of "Lorentzian proof trees" — a new proof system where axioms are spectral signature verifications and inference rules are derivative operations.

**Test**: Define the Lorentzian proof system formally. Prove that it polynomially simulates resolution for encoded CNF formulas. Conversely, show that resolution lower bounds (e.g., for pigeonhole formulas) transfer to Lorentzian certificate lower bounds.

**Impact**: Would create a new proof system sitting between algebraic proof complexity (Polynomial Calculus, Sherali-Adams) and spectral methods, potentially yielding new lower bounds for existing systems via the algebraic-geometric lens.

**Catalog References**: `Pythagorean/LorentzianHardness.lean` (multiindex_count_ge_two_pow, certificate_complexity_exponential, branch_sat_duality).

**Proof Strategy**: Model Lorentzian certificates as derivation trees where each node performs a partial derivative and each leaf is verified by eigenvalue computation. Map resolution refutations to Lorentzian certificate constructions. Transfer Haken's exponential lower bound on resolution of PHP to a lower bound on Lorentzian certificates of the corresponding encoded polynomial.

**Domain Bridges**: Proof complexity ↔ Hodge theory, resolution ↔ derivative trees.

**Lineage**: The observation that "Lorentzian derivative trees behave like proof trees" from the current research vision.

**Ambition**: Grand challenge — this would open an entirely new proof system with connections to algebraic geometry.

**The key insight is**: A recursive Lorentzian certificate is literally a proof tree — a tree-structured argument where each leaf is a spectral axiom and each internal node is a differentiation inference step.

**Why now?** The certificate complexity lower bounds provide the first nontrivial quantitative statements about these proof trees. The Branch-SAT Duality shows the proof system has enough expressive power to encode propositional logic.

---

## Direction 4: Average-Case Lorentzian Recognition

**Conjecture**: For random homogeneous polynomials with i.i.d. nonneg coefficients in n variables of degree d, the probability of being Lorentzian undergoes a sharp threshold as a function of d/n. Below the threshold, almost all polynomials are Lorentzian; above it, almost none are.

**Test**: Sample random polynomials with nonneg integer coefficients and check Lorentzianity for various (n, d) pairs. Plot the fraction that are Lorentzian as a function of d/n. Look for a sharp transition around d/n ≈ c for some constant c.

**Impact**: Would establish that average-case recognition may be much easier than worst-case, motivating practical algorithms. Alternatively, if the average case is also hard, it would strengthen the hardness narrative significantly.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` (recursive_certificate_equiv_spectral_check), `Pythagorean/LorentzianHardness.lean` (phase_transition).

**Proof Strategy**: Use random matrix theory to analyze the distribution of Hessian eigenvalues for random quadratic leaves. The Wigner semicircle law gives the eigenvalue distribution; the probability of having ≤ 1 positive eigenvalue can be computed from the distribution's positive mass.

**Domain Bridges**: Random matrix theory ↔ algebraic combinatorics, statistical physics ↔ Hodge positivity.

**Lineage**: Motivated by the phase transition theorem — the worst-case transition naturally raises the question of the average-case transition.

**Ambition**: Solid extension with potentially surprising results from random matrix theory.

**The key insight is**: The Hessian of a random polynomial's derivative leaf is a structured random matrix, and random matrix universality may determine the threshold.

**Why now?** The formal framework for Lorentzian certificates makes it possible to precisely formulate the probability question. Random matrix theory has matured sufficiently to analyze structured random matrix ensembles.

---

## Direction 5: Lorentzian Approximation and Stability

**Conjecture**: There exists a polynomial-time algorithm that, given a polynomial p, computes a number δ(p) ∈ [0, 1] such that δ(p) = 0 iff p is Lorentzian, and δ(p) measures the "distance to Lorentzianity" in a natural metric (e.g., the maximum ratio of the second-largest eigenvalue to the largest across all derivative leaves).

**Test**: Implement the candidate δ-measure on the space of degree-4 polynomials in 3 variables. Verify that known Lorentzian polynomials (e.g., elementary symmetric polynomials, complete homogeneous symmetric polynomials) achieve δ = 0, and that small perturbations that break Lorentzianity achieve δ > 0 proportional to the perturbation size.

**Impact**: Would provide practical tools for approximate Lorentzian certification, bypassing the exponential exact-recognition barrier. Applications to optimization (approximate log-concavity certificates) and physics (stability margins for partition functions).

**Catalog References**: `Bridges/LorentzianRecognition.lean` (HasAtMostOnePositiveEigenvalue, lorentzian_signature_tangent_neg_semidef), `Pythagorean/LorentzianHardness.lean` (positive_definite_not_lorentzian).

**Proof Strategy**: Define δ(p) = max over leaves of (second-largest eigenvalue of Hessian / largest eigenvalue). For fixed degree, this is polynomial-time computable. Prove continuity of δ under coefficient perturbation using matrix perturbation theory (Weyl's inequality). The main challenge is showing δ is a good measure — that small δ implies approximate Lorentzianity in a useful sense.

**Domain Bridges**: Approximation algorithms ↔ Hodge theory, matrix perturbation theory ↔ polynomial positivity, optimization ↔ spectral geometry.

**Lineage**: Motivated by the hardness barrier — if exact recognition is hard, what can be computed efficiently?

**Ambition**: Solid extension with immediate practical applications.

**The key insight is**: The exact decision problem may be hard, but the *optimization* problem (how far from Lorentzian?) may be efficiently solvable, analogous to how checking integer factoring is hard but computing GCDs is easy.

**Why now?** The exponential lower bound proves exact recognition is hard, creating the motivation for approximation. The spectral obstruction theorem provides the natural distance measure (eigenvalue ratios).
