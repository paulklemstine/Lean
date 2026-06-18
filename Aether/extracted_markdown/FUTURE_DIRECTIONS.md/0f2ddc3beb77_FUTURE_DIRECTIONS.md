# Future Directions: Complexity Theory of Hodge Predicates

## Synthesis

The formally verified phase transition in Lorentzian recognition certificate complexity opens a new research program at the intersection of algebraic combinatorics, computational complexity, and Hodge theory. The core discovery — that Lorentzian positivity transitions from tractable to intractable as degree becomes unbounded — suggests that many positivity predicates in algebraic geometry may harbor hidden computational complexity. The five directions below form a coherent research agenda: Direction 1 completes the hardness reduction, Direction 2 develops algorithmic responses, Directions 3–4 extend the theory to related positivity notions and structural parameters, and Direction 5 bridges to proof complexity. Together, they would establish "computational Hodge theory" as a subfield.

---

## Direction 1: Exact coNP-Hardness via SAT-to-Lorentzian Encoding

**Conjecture:** There exists a polynomial-time computable function *f* mapping CNF formulas φ to homogeneous polynomials P_φ such that P_φ is Lorentzian if and only if φ is unsatisfiable.

**Test:** For all 3-SAT instances on ≤ 6 variables (tractable to enumerate), construct P_φ and verify the correspondence by brute-force Lorentzian checking and SAT solving. Any counterexample disproves the encoding.

**Impact:** Would be the first coNP-hardness result for a Hodge-theoretic positivity predicate. It would prove that Lorentzian recognition is coNP-hard for unbounded degree, establishing the exact computational complexity.

**Catalog References:** `Pythagorean/LorentzianComplexityBarrier.lean` (sat_obstruction_duality, hessian_recovers_matrix), `Bridges/LorentzianHardness.lean` (spectral_obstruction_non_lorentzian).

**Proof Strategy:** Use the Hessian spectral encoding theorem to construct P_φ as a sum of clause polynomials. Each clause contributes a term whose derivative-leaf Hessian has Lorentzian signature iff the corresponding assignment falsifies the clause. The key technical challenge is ensuring homogeneity and nonnegativity of all coefficients.

**Domain Bridges:** Computational complexity (Cook-Levin theorem), algebraic geometry (Hodge theory), proof complexity.

**Lineage:** Extends sat_obstruction_duality + hessian_recovers_matrix + no_uniform_polynomial_bound.

**The key insight is** that the Hessian spectral encoding provides a concrete mechanism for translating Boolean constraints into eigenvalue conditions, and the SAT-obstruction duality provides the structural framework for the reduction.

**Why now?** The formal verification of the phase transition and the Hessian encoding theorem provides the first rigorous foundation for this reduction. Previous informal arguments lacked the precision to ensure the encoding preserves the Lorentzian ↔ UNSAT correspondence.

**Ambition:** Grand challenge — would create a new subfield.

---

## Direction 2: Approximation Algorithms for Lorentzian Recognition

**Conjecture:** There exists a polynomial-time algorithm that, given a homogeneous polynomial f of degree d in n variables with nonneg coefficients, outputs "YES" if f is Lorentzian and "MAYBE" otherwise, with the property that on random polynomials with Lorentzian structure, it outputs "YES" with probability ≥ 1 − ε for any desired ε > 0.

**Test:** Implement a spectral sampling algorithm that checks random subsets of quadratic leaves. Measure false negative rate on known Lorentzian families (elementary symmetric polynomials, volume polynomials of convex bodies) as a function of sample size.

**Impact:** Would provide practical polynomial-time testing for Lorentzianity, bypassing the exponential barrier for most instances. Directly applicable to log-concavity verification in combinatorics and statistical physics.

**Catalog References:** `Pythagorean/LorentzianComplexityBarrier.lean` (complexity_phase_transition_sharp, multiindex_count_ge_two_pow).

**Proof Strategy:** Sample O(poly(n, 1/ε)) random multiindices and check Lorentzian signature at the corresponding leaves. Use concentration inequalities (Chernoff bounds) to show that if a constant fraction of leaves violate Lorentzianity, the sampled set will detect a violation w.h.p.

**Domain Bridges:** Randomized algorithms, property testing (Goldreich-Goldwasser-Ron), machine learning (PAC learning of geometric properties).

**Lineage:** Motivated by the exponential lower bound in quadratic_leaf_count_lower_bound.

**The key insight is** that while worst-case recognition requires exponential checks, average-case recognition might be tractable if violations are spread across many leaves rather than concentrated on a few.

**Why now?** The formal lower bound shows exact recognition is infeasible, creating demand for approximation. Standard techniques from property testing can now be applied with rigorous complexity guarantees.

**Ambition:** Solid extension — directly builds on catalog results.

---

## Direction 3: Phase Transitions for Related Hodge Predicates

**Conjecture:** The complexity phase transition (polynomial for fixed degree, exponential for unbounded degree) holds for the following positivity notions: (a) completely log-concave polynomials, (b) strongly log-concave polynomials, (c) ultra-log-concave polynomials, (d) Schur-log-concave polynomials.

**Test:** For each predicate, compute the certificate size (number of conditions to check) for small (n, d) pairs and verify exponential growth in the balanced regime d = n.

**Impact:** Would establish a universal complexity-theoretic law for Hodge positivity predicates: bounded degree ⟹ tractable, unbounded degree ⟹ intractable. This would unify the complexity theory of algebraic positivity.

**Catalog References:** `Pythagorean/LorentzianComplexityBarrier.lean` (all theorems — the entire proof architecture transfers).

**Proof Strategy:** For each predicate, identify the recursive characterization (analogue of "all derivative leaves have Lorentzian Hessian") and count the number of recursive checks. The counting argument should transfer directly via the multiindex injection.

**Domain Bridges:** Algebraic geometry (Hodge theory, Lefschetz decomposition), combinatorics (matroid theory, partition functions), convex geometry.

**Lineage:** Direct generalization of the entire Lorentzian complexity barrier framework.

**The key insight is** that the phase transition is driven by the combinatorial structure of derivative trees, not by specific properties of Lorentzian signatures. Any predicate with a recursive derivative characterization should exhibit the same transition.

**Why now?** The successful formalization for Lorentzian polynomials provides a template that can be instantiated for other predicates with minimal modification.

**Ambition:** Solid extension — high probability of success.

---

## Direction 4: Parameterized Complexity by Support Size and Treewidth

**Conjecture:** Lorentzian recognition is fixed-parameter tractable (FPT) when parameterized by the support size (number of nonzero monomials) |supp(f)|, even for unbounded degree. Specifically, the number of non-redundant quadratic leaves is at most poly(|supp(f)|).

**Test:** For sparse polynomials (|supp(f)| = O(n)) with large degree, count the number of quadratic leaves that produce nonzero quadratic forms. If this count is polynomial in |supp(f)|, the conjecture holds.

**Impact:** Would show that the exponential barrier only applies to dense polynomials, and that most "natural" polynomials (which tend to be sparse) admit efficient recognition. This would reconcile the theoretical hardness with practical tractability.

**Catalog References:** `Pythagorean/LorentzianComplexityBarrier.lean` (multiindex_count_monotone, certificate_complexity analysis), `Bridges/LorentzianRecognition.lean` (quadratic_leaf_count_le).

**Proof Strategy:** Show that a derivative ∂^α f is nonzero only if α ≤ β componentwise for some monomial x^β in supp(f). This restricts the set of "active" leaves. Use the structure of the support to bound the number of active leaves.

**Domain Bridges:** Parameterized complexity (Downey-Fellows theory), algebraic complexity (circuit complexity of polynomials), graph theory (treewidth of support hypergraphs).

**Lineage:** Refines the phase transition by introducing structural parameters beyond (n, d).

**The key insight is** that the exponential lower bound constructs polynomials with full support (all possible monomials nonzero). Real-world polynomials are much sparser, and sparsity should compress the derivative tree.

**Why now?** The phase transition identifies the *worst case* precisely, creating the opportunity to ask: when does the worst case actually occur?

**Ambition:** Solid extension — directly applicable to practice.

---

## Direction 5: Proof Complexity of Lorentzian Certificates

**Conjecture:** The minimum size of a Lorentzian certificate for the polynomial P_PHP (encoding the Pigeonhole Principle) is 2^Ω(n), matching the resolution proof complexity lower bound for PHP.

**Test:** Construct P_PHP for small n (3 pigeons/2 holes, 4 pigeons/3 holes) and find the minimum-size certificate by exhaustive search. Compare with known resolution proof sizes.

**Impact:** Would establish a formal correspondence between Lorentzian certificate complexity and resolution proof complexity, opening a new bridge between algebraic combinatorics and proof complexity. This is the most paradigm-shifting direction: it would show that Lorentzian certificates are a new proof system whose strength can be measured against known systems.

**Catalog References:** `Pythagorean/LorentzianComplexityBarrier.lean` (sat_obstruction_duality, conditional_hardness), `Bridges/LorentzianHardness.lean` (cnf_branch_lower_bound).

**Proof Strategy:** Define the Lorentzian proof system formally: a proof of "f is Lorentzian" is a collection of (multiindex, witness) pairs where each witness certifies Lorentzian signature of the corresponding quadratic leaf. Show that for P_PHP, the number of required witnesses matches the number of resolution steps in tree-like resolution refutations of PHP.

**Domain Bridges:** Proof complexity (resolution, cutting planes, algebraic proof systems), circuit complexity (monotone circuit lower bounds), combinatorial optimization.

**Lineage:** Connects sat_obstruction_duality to proof complexity lower bounds.

**The key insight is** that a Lorentzian certificate is formally a proof in an algebraic proof system, and the exponential lower bound on certificate size is formally a lower bound on proof length. This reframes Lorentzian recognition as proof search.

**Why now?** The formal connection between SAT structure and derivative-tree structure, established in this work, provides the first rigorous basis for comparing these proof systems.

**Ambition:** Grand challenge — would create a new bridge between algebraic combinatorics and proof complexity theory.
