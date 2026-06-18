# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The results in this cycle establish a new connection between computational complexity and Hodge-theoretic positivity. We proved that recursive Lorentzian recognition requires exponentially many certificate checks when the degree is unbounded, and we built the structural bridge (via SAT-branch correspondence) that connects this combinatorial explosion to Boolean satisfiability. These results open a systematic research program: the **complexity theory of Hodge predicates**. Each direction below extends a different facet of this program — from completing the SAT reduction (Direction 1), to exploring certificate compression (Direction 2), to bridging into statistical physics (Direction 3), to extending the framework to other positivity predicates (Direction 4), to developing practical parameterized algorithms (Direction 5). Together, they define a field that did not exist before this cycle.

---

## Direction 1: Complete SAT-to-Lorentzian Reduction (Grand Challenge)

**Conjecture:** There exists a polynomial-time computable map f from CNF formulas to homogeneous polynomials with nonneg integer coefficients such that f(φ) is Lorentzian if and only if φ is unsatisfiable. This would establish coNP-hardness of unrestricted-degree Lorentzian recognition.

**Test:** Implement f for small CNF instances (m ≤ 8 variables) and verify the equivalence by brute-force SAT checking and exhaustive Hessian eigenvalue computation. A single counterexample disproves the conjecture.

**Impact:** This would be the first complexity lower bound for any Hodge-theoretic positivity predicate, opening an entirely new chapter in both algebraic combinatorics and computational complexity.

**Catalog References:** `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — Theorem `sat_branch_obstruction_correspondence`, Definition `CNFFormula`, Theorem `multiindex_exponential_lower_bound`; `Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`, `card_multiindex_le_pow`

**Proof Strategy:** Define P_φ as a sum over clause-variable incidences weighted by slack variables enforcing homogeneity. Show that directional derivatives along variable-axis directions correspond to fixing Boolean values. Use the reversed Cauchy-Schwarz inequality (`lorentzian_reversed_cauchy_schwarz` from the catalog) to prove that Lorentzianity forces clause satisfaction.

**Domain Bridges:** Computational complexity (Cook-Levin theorem, NP-completeness), proof complexity (resolution lower bounds), algebraic geometry (Hodge-Riemann relations)

**Lineage:** Extends `sat_branch_obstruction_correspondence` and `certificate_exponential_lower_bound` from this cycle.

**Ambition:** Grand challenge — paradigm-shifting if proved. Would create a permanent bridge between two major mathematical fields.

**The key insight is:** the derivative tree of a Lorentzian polynomial has the same branching structure as a resolution refutation tree, and the Hessian sign condition at leaves plays the role of clause satisfaction.

**Why now?** The Boolean-to-multiindex injection and SAT-branch correspondence proved in this cycle provide the structural foundation. The remaining gap is the algebraic construction of P_φ and the sign-condition analysis.

---

## Direction 2: Certificate Compression and Proof Complexity

**Conjecture:** There exist homogeneous polynomials with nonneg coefficients for which no Lorentzian certificate (of any form, not just derivative-tree based) has size polynomial in n and d. Equivalently, the "Lorentzian proof system" has no polynomial-size proofs for certain instances.

**Test:** For the product polynomial p = (x₁ + x₂)^d, compare derivative-tree certificate size C(d, d-2) with any alternative certificate construction. If alternative certificates can be exponentially smaller, the conjecture is false.

**Impact:** Would establish that Lorentzian recognition is not in coNP (stronger than coNP-hardness alone), or reveal a polynomial compression principle that would revolutionize the algorithmic theory.

**Catalog References:** `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — `certificate_superpolynomial`, `minCertificateSize`, `phase_transition_certificate_size`

**Proof Strategy:** Adapt techniques from proof complexity (communication complexity lower bounds, feasible interpolation) to the algebraic certificate setting. The key difficulty is defining "Lorentzian proof system" abstractly enough to capture all possible certificate structures.

**Domain Bridges:** Proof complexity (Razborov-Rudich natural proofs barrier, resolution lower bounds), communication complexity, algebraic proof systems

**Lineage:** Extends `certificate_superpolynomial` by asking whether the derivative-tree lower bound applies to ALL certificate types.

**Ambition:** Grand challenge — proving unconditional proof-system lower bounds is notoriously difficult.

**The key insight is:** the derivative tree is only one possible proof system for Lorentzianity. The question is whether the exponential barrier is an artifact of the tree structure or an intrinsic property of the Lorentzian predicate.

**Why now?** The formalized certificate complexity framework from this cycle provides the definitions needed to state and attack the question precisely.

---

## Direction 3: Statistical Physics and Partition Function Hardness

**Conjecture:** For the partition function Z_G(x) of a graph G (encoding the independent set polynomial), checking Lorentzianity of Z_G is at least as hard as counting independent sets, which is #P-hard.

**Test:** Compute the Lorentzianity of Z_G for all graphs on ≤ 8 vertices. Correlate with known #P-hard instances. Check whether the phase transition in Lorentzianity matches the known phase transition in independent set counting.

**Impact:** Would connect Lorentzian positivity to computational counting problems, opening applications in statistical mechanics, sampling algorithms, and approximate counting.

**Catalog References:** `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — `HasLorentzianSignature`, `identity_not_lorentzian`, `neg_semidef_lorentzian`; `Catalog/Bridges/LorentzianRecognition.lean` — `lorentzian_reversed_cauchy_schwarz`

**Proof Strategy:** Use the connection between strongly Rayleigh measures and Lorentzian polynomials. The partition function of a strongly Rayleigh measure is Lorentzian. Show that the converse direction — testing whether a given partition function is Lorentzian — encodes counting information.

**Domain Bridges:** Statistical physics (Ising model, partition functions), counting complexity (#P, approximate counting), probability (strongly Rayleigh measures, determinantal point processes)

**Lineage:** Extends the spectral obstruction theorems from this cycle into the physics domain.

**Ambition:** Solid extension — builds on well-established connections between Lorentzian polynomials and statistical physics.

**The key insight is:** Lorentzian polynomials characterize a phase of matter (the strongly Rayleigh phase), and phase detection is computationally equivalent to counting.

**Why now?** Recent advances in the algorithmic theory of strongly Rayleigh measures (Anari-Oveis Gharan-Vinzant) provide new tools for connecting Lorentzianity to counting problems.

---

## Direction 4: Complexity Classification of Hodge Predicates

**Conjecture:** There exists a complexity-theoretic hierarchy among Hodge positivity predicates: log-concavity (P) → ultra-log-concavity (P) → Lorentzian (coNP-hard for unbounded degree) → Hodge-Riemann (undecidable?).

**Test:** Formalize each predicate and prove complexity separations. Start with log-concavity of a sequence (a₀, ..., aₙ): checking aᵢ² ≥ aᵢ₋₁aᵢ₊₁ is clearly polynomial. Then show that each successive predicate is strictly harder.

**Impact:** Would create the first systematic complexity taxonomy of mathematical positivity conditions, analogous to the algebraic complexity taxonomy of Bürgisser-Clausen-Shokrollahi.

**Catalog References:** `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — all main theorems; `Catalog/Pythagorean/HigherOrderLogConcavity.lean`; `Catalog/Pythagorean/DirectionalLogConcavity.lean`

**Proof Strategy:** For each predicate, determine the certificate structure. Log-concavity is checkable in O(n) comparisons. Ultra-log-concavity may require Newton-inequality chains. Lorentzianity requires the exponential derivative tree (as we proved). Hodge-Riemann relations involve higher-degree positivity conditions that may require even more complex certificates.

**Domain Bridges:** Algebraic geometry (Hodge theory, Lefschetz theorems), computational complexity (complexity zoo taxonomy), convexity theory

**Lineage:** Extends the phase transition framework to a family of related predicates.

**Ambition:** Solid extension with grand-challenge elements at the upper levels of the hierarchy.

**The key insight is:** different Hodge positivity predicates have different "certificate depths" — the number of levels of derivative descent required — and this depth controls the computational complexity.

**Why now?** The Lorentzian lower bound provides the first non-trivial entry in the hierarchy. Earlier work on log-concavity provides the trivial end.

---

## Direction 5: Parameterized Algorithms and Practical Lorentzian Recognition

**Conjecture:** Lorentzian recognition is fixed-parameter tractable with parameters (degree, treewidth of support), with running time f(d, tw) · poly(n) where f is computable.

**Test:** Implement a treewidth-based recognition algorithm for sparse polynomials (support size ≪ n^d). Compare running time against the full derivative tree on matroids with known treewidth bounds.

**Impact:** Would provide practical algorithms for Lorentzian recognition in algebraic combinatorics, enabling computational verification of Lorentzian conjectures for specific polynomial families.

**Catalog References:** `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — `phase_transition_certificate_size`, `multiIndexCount_mono_n`; `Catalog/Pythagorean/TreewidthCertificateTheorems.lean`; `Catalog/Pythagorean/SparseLorentzianCertificates.lean`

**Proof Strategy:** Exploit sparsity: if the polynomial has support of size s, only O(s^{d-2}) multiindices produce nonzero derivatives. For bounded treewidth, the dynamic-programming approach of Courcelle's theorem may apply to the derivative tree.

**Domain Bridges:** Parameterized complexity (Downey-Fellows theory), graph algorithms (treewidth, tree decomposition), algebraic combinatorics (matroid support structure)

**Lineage:** Directly addresses the question: given that unbounded degree is hard, what structural parameters make the problem tractable?

**Ambition:** Solid extension — practically important and theoretically grounded.

**The key insight is:** the exponential barrier is triggered by dense, high-degree polynomials. Sparse, structured polynomials (like matroid basis generating polynomials) may have exploitable structure that bypasses the worst case.

**Why now?** The phase transition theorem provides the theoretical framework for understanding which parameters matter, and the formalized certificate-size definitions enable rigorous analysis.
