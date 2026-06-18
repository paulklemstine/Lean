# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The formal results in this cycle establish that Lorentzian polynomial recognition exhibits a complexity phase transition: polynomial-time for fixed degree, exponential for unbounded degree. This opens an entirely new research program connecting Hodge-theoretic positivity, computational complexity, and algebraic combinatorics. The five directions below span from direct extensions of the formal catalog to paradigm-shifting conjectures that would reshape our understanding of the boundary between geometry and computation. They are unified by a single vision: that positivity predicates arising in algebraic geometry form a natural hierarchy of computational complexity, and Lorentzian recognition is the first member of this hierarchy to be formally characterized.

---

## Direction 1: Full coNP-Hardness of Unrestricted-Degree Lorentzian Recognition

**Conjecture:** There exists a polynomial-time many-one reduction from CNF-UNSAT to Lorentzian recognition for unrestricted-degree homogeneous polynomials. That is, Lorentzian recognition is coNP-hard when the degree is part of the input.

**Test:** Implement the CNF-to-polynomial encoding from the branch-assignment correspondence and verify that for all 3-CNF formulas on ≤ 8 variables, the encoded polynomial is Lorentzian iff the formula is unsatisfiable. A single counterexample disproves the conjecture.

**Impact:** This would be the first complexity lower bound for a Hodge-theoretic positivity predicate, creating a new bridge between algebraic geometry and computational complexity theory. It would prove that the exponential barrier is not merely an artifact of the derivative-tree algorithm but reflects intrinsic computational hardness.

**Catalog References:** `Pythagorean/LorentzianHardness.lean` — `certificate_size_exponential_lower`, `branch_assignment_embedding`, `quadratic_leaf_explosion`.

**Proof Strategy:** Strategy A (direct CNF-to-derivative-tree reduction). Define a polynomial $P_\varphi$ whose monomials encode clause-variable incidences with slack variables enforcing homogeneity. Use the branch-assignment correspondence to translate derivative branches into partial assignments. Prove: (i) if $\varphi$ is UNSAT, every leaf Hessian is Lorentzian; (ii) if $\varphi$ is SAT, some leaf Hessian has two positive eigenvalues. The key difficulty is (i), which requires understanding how unsatisfiability constrains quadratic forms.

**Domain Bridges:** Computational complexity (Cook-Levin theory) ↔ Hodge theory (Lorentzian positivity) ↔ Proof complexity (certificate lower bounds).

**Lineage:** Extends `certificate_size_exponential_lower` from exponential tree size to actual computational hardness.

**Ambition:** Grand challenge. Would create a new field.

---

## Direction 2: Parameterized Complexity of Lorentzian Recognition

**Conjecture:** Lorentzian recognition is fixed-parameter tractable (FPT) when parameterized by treewidth of the support graph plus degree. Specifically, there exists an algorithm running in time $f(k, d) \cdot n^{O(1)}$ where $k$ is the treewidth and $d$ is the degree.

**Test:** Implement a dynamic-programming algorithm over tree decompositions of the support graph for polynomials with treewidth ≤ 4 and degree ≤ 10. Measure running time and compare to the naive $n^{d-2}$ bound.

**Impact:** This would precisely delineate the tractability boundary: degree alone is not enough for hardness; it's the interaction of degree with support structure that drives complexity. This would connect Lorentzian recognition to the Robertson-Seymour theory and graph minor theory.

**Catalog References:** `Catalog/Bridges/LorentzianRecognition.lean` — `card_multiindex_le_pow`, `quadratic_leaf_count_le`.

**Proof Strategy:** Strategy B (certificate-complexity approach). Define a "structured derivative tree" that respects the support graph's tree decomposition. Show that the number of distinct Hessian checks can be bounded by $f(k, d)$ using a separator-based argument. The formal verification would build on `multiindex_count_linear_lower` to establish that only treewidth-many "active" variables matter at each tree node.

**Domain Bridges:** Parameterized complexity theory ↔ Algebraic combinatorics ↔ Graph minor theory.

**Lineage:** Directly extends the phase transition established in `quadratic_leaf_explosion`.

**Ambition:** Solid extension. Within reach of current tools.

---

## Direction 3: Average-Case Lorentzian Recognition and Phase Transitions in Random Polynomials

**Conjecture:** For a random homogeneous polynomial of degree $d$ in $n$ variables with i.i.d. nonneg coefficients, there exists a critical degree $d^*(n) = \Theta(\sqrt{n})$ such that: (a) for $d \ll d^*(n)$, the polynomial is Lorentzian with high probability; (b) for $d \gg d^*(n)$, it is non-Lorentzian with high probability; (c) at $d = d^*(n)$, there is a sharp phase transition.

**The key insight is** that the number of Hessian eigenvalue sign patterns transitions from "almost all Lorentzian" to "almost all non-Lorentzian" as degree crosses a threshold, analogous to the satisfiability threshold in random $k$-SAT.

**Why now?** The formal infrastructure for counting derivative leaves and checking Lorentzian signature is now in place. The connection between Boolean assignments and derivative branches suggests that random polynomial models may exhibit SAT-like threshold behavior.

**Test:** Generate 10,000 random homogeneous polynomials for each $(n, d)$ pair with $n \in \{5, 10, 20\}$ and $d \in \{2, \ldots, 2n\}$. Compute the fraction that are Lorentzian (by exact computation for small cases). Plot the phase transition curve and fit the critical degree $d^*(n)$.

**Impact:** Would establish the first average-case complexity result for a Hodge-theoretic predicate, connecting random matrix theory to algebraic combinatorics.

**Catalog References:** `Pythagorean/LorentzianHardness.lean` — `pos_def_not_lorentzian`, `spectral_obstruction_bilinear`.

**Proof Strategy:** Use the spectral obstruction theorem to show that for large $d$, random Hessians are likely positive definite (and hence non-Lorentzian by `pos_def_not_lorentzian`). For small $d$, use the reversed Cauchy-Schwarz to constrain the positive cone and show Lorentzianity holds.

**Domain Bridges:** Random matrix theory ↔ Statistical physics (percolation thresholds) ↔ Algebraic geometry.

**Lineage:** Builds on `pos_def_not_lorentzian` and `spectral_obstruction_bilinear`.

**Ambition:** Grand challenge. Would bridge random matrix theory and Hodge positivity.

---

## Direction 4: Certificate Compression and Proof Complexity

**Conjecture:** There exist polynomial families where the minimum-size recursive Lorentzian certificate has superpolynomial size, but there exists a non-recursive "algebraic certificate" (e.g., a sum-of-squares decomposition or a spectral certificate) of polynomial size.

**The key insight is** that the derivative-tree paradigm is one proof system for Lorentzianity, but algebraic geometry provides alternative proof systems. The complexity gap between proof systems would mirror the P vs. NP-type gaps studied in proof complexity.

**Why now?** The exponential lower bound on recursive certificates (`certificate_size_exponential_lower`) provides the first lower bound in this proof system. Comparing against algebraic alternatives is the natural next step.

**Test:** For the explicit polynomial family used in `completeMonomialSum`, attempt to find compact algebraic certificates (sum-of-squares, determinantal representations, or spectral certificates) whose size grows polynomially. If found, this proves a proof-complexity gap; if not, it supports the conjecture that all certificate systems face exponential barriers.

**Impact:** Would connect Lorentzian recognition to proof complexity theory, establishing that different "proof systems" for Hodge positivity have different power — a phenomenon well-studied for propositional logic but entirely new for algebraic positivity.

**Catalog References:** `Pythagorean/LorentzianHardness.lean` — `certificate_size_exponential_lower`, `completeMonomialSum_support_card_le`.

**Proof Strategy:** Define formal notions of "algebraic certificate" and "certificate size." Use the `completeMonomialSum` family as a test case. Prove lower bounds by reduction from known proof-complexity separations (e.g., resolution vs. extended Frege).

**Domain Bridges:** Proof complexity ↔ Algebraic geometry ↔ Optimization (SOS hierarchies).

**Lineage:** Extends `certificate_size_exponential_lower` from one proof system to a comparative study.

**Ambition:** Solid extension with grand-challenge potential.

---

## Direction 5: Lorentzian Recognition in Statistical Physics — Partition Function Stability

**Conjecture:** The partition function $Z_G(\beta) = \sum_{S} e^{-\beta H(S)}$ of a graph $G$ (where $H$ is a graph Hamiltonian) is Lorentzian as a polynomial in $(e^{-\beta}, 1)$ if and only if the system exhibits no phase transition in the ferromagnetic regime.

**The key insight is** that Lorentzianity of the partition function encodes stability (absence of zeros in a half-plane), connecting the Lee-Yang theorem from statistical physics to the derivative-tree recognition framework.

**Why now?** The spectral obstruction theorems provide a concrete test for non-Lorentzianity via eigenvalue analysis, which can be applied to Hessians of partition function derivatives. The branch-assignment correspondence suggests that phase transitions in the partition function map to structural changes in the derivative tree.

**Test:** Compute partition functions for complete graphs $K_n$ ($n = 3, \ldots, 10$) and check Lorentzianity of their homogenizations. Correlate with the known phase transition in the Ising model on complete graphs.

**Impact:** Would bridge Hodge theory and statistical mechanics, providing new tools for analyzing phase transitions using algebraic positivity and new physical interpretations of Lorentzian recognition complexity.

**Catalog References:** `Pythagorean/LorentzianHardness.lean` — `spectral_obstruction_bilinear`, `pos_def_not_lorentzian`.

**Proof Strategy:** Homogenize the partition function polynomial and apply the derivative-tree framework. Use `spectral_obstruction_bilinear` to detect phase transitions via eigenvalue sign changes in Hessians. Prove that Lee-Yang zeros correspond to non-Lorentzian leaves.

**Domain Bridges:** Statistical physics (Lee-Yang theory, phase transitions) ↔ Hodge theory ↔ Computational complexity.

**Lineage:** Uses `spectral_obstruction_bilinear` as the detection mechanism.

**Ambition:** Grand challenge. Would create a new interdisciplinary field.
