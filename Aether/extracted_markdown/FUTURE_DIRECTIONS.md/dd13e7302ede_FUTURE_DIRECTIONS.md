# Future Directions: Treewidth-Parameterized Lorentzian Recognition

## Synthesis

This research cycle established the foundational connection between treewidth (a structural graph parameter) and the complexity of Lorentzian polynomial recognition. The central discovery is that **the exponential blowup in recognition complexity is entirely explained by global variable interactions**: restricting the interaction graph's treewidth to w reduces the leaf count from exponential in d to polynomial (≤ C(n, w+1) · (d+1)^(w+1)).

This connects three previously independent domains:
1. **Algebraic combinatorics** (Lorentzian polynomials, Hodge theory)
2. **Structural graph theory** (treewidth, tree decompositions)
3. **Parameterized complexity** (FPT, W-hierarchy)

The most promising cross-domain connection is between treewidth-bounded Lorentzian recognition and **constraint satisfaction problems (CSP)**. Both exhibit the same phase transition: polynomial complexity for tree-structured instances, exponential for general instances. This parallel suggests deep structural reasons why treewidth controls algebraic certification complexity, potentially leading to a unified "structural complexity theory for algebraic positivity."

The results build on the catalog's exponential lower bounds (`Catalog/Pythagorean/LorentzianHardness.lean` — `leaf_count_exponential_lower_bound`, `multiindex_count_exponential_lower`) and the upper bound (`Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`), placing them in a refined complexity landscape parameterized by treewidth.

---

### Direction 1: Full FPT Lorentzian Recognition

**Conjecture**: Lorentzian recognition is fixed-parameter tractable (FPT) when parameterized by both treewidth w and degree d. Specifically, there exists a computable function f(w, d) such that recognition can be decided in time f(w, d) · poly(n).

**Test**: Implement the tree-decomposition-based Hessian check algorithm for explicit polynomial families with treewidth 2 (cycle-structured interactions) at degrees d = 4, 6, 8, 10. Measure whether the actual running time scales as predicted by the FPT bound. If the measured time exceeds polynomial growth in n for any fixed (w, d) pair, the conjecture is refuted.

**Impact**: If true, this would establish Lorentzian recognition as the first algebraic certification problem known to be FPT by treewidth. It would open the door to practical algorithms for polynomials arising in combinatorics and optimization, where interaction structures are typically sparse.

**Catalog References**: `Catalog/Bridges/LorentzianRecognition.lean` — `quadratic_leaf_count_le`, `card_multiindex_le_pow`; `Pythagorean/TreewidthFPT.lean` — `boundedSuppCount_le`, `treewidth_bounds_support`

**Proof Strategy**: The key missing ingredient is bounding the time per Hessian check. For a polynomial with interaction graph of treewidth w, the Hessian matrix at each leaf is (at most) n × n, but its nonzero structure is controlled by the tree decomposition. Use the fact that the Hessian restricted to variables in a bag has size ≤ (w+1) × (w+1), and apply dynamic programming on the tree decomposition to compute eigenvalue bounds. The spectral check (at most one positive eigenvalue) for structured Hessians can be performed in O(w^ω) time using Cholesky-like decompositions.

**Domain Bridges**: Parameterized Complexity ↔ Algebraic Combinatorics ↔ Numerical Linear Algebra

**Lineage**: Extends `boundedSuppCount_le` from counting leaves to bounding total computation time.

**Ambition**: grand_challenge

---

### Direction 2: Hardness for Large Treewidth — W[1]-Hardness

**Conjecture**: Lorentzian recognition parameterized by treewidth alone (with degree unbounded) is W[1]-hard. That is, there is no FPT algorithm parameterized by treewidth alone unless FPT = W[1].

**Test**: Construct a polynomial-time reduction from k-Clique (a canonical W[1]-complete problem) to Lorentzian recognition of polynomials with interaction graph of clique-width ≤ f(k). If the reduction preserves the parameter, W[1]-hardness follows.

**Impact**: This would precisely delineate the tractability boundary: FPT in (treewidth, degree) jointly, but likely not in treewidth alone. This would parallel the known landscape for CSP, where treewidth alone suffices for bounded-domain instances but not for unbounded domains.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardness.lean` — `leaf_count_exponential_lower_bound`; `Pythagorean/TreewidthFPT.lean` — `unbounded_tractability_gap`

**Proof Strategy**: The lower bound proofs in the catalog encode Boolean assignments into multiindices. Extend this encoding to show that k-Clique instances can be encoded as Lorentzian recognition instances where the interaction graph has treewidth O(k). The key step: construct a polynomial p_G for each graph G such that p_G is Lorentzian iff G has no k-clique, and the interaction graph of p_G has treewidth bounded by a function of k.

**Domain Bridges**: Parameterized Complexity ↔ Graph Theory ↔ Algebraic Combinatorics

**Lineage**: Builds on the SAT encoding infrastructure in `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` — `CNFFormula`, `boolean_assignment_multiindex_lower_bound`.

**Ambition**: grand_challenge

---

### Direction 3: Treewidth of Matroid Interaction Graphs

**Conjecture**: For the basis-generating polynomial of a matroid of rank r on n elements, the variable interaction graph has treewidth at most r - 1. Consequently, Lorentzian recognition of matroid polynomials is FPT parameterized by rank.

**Test**: Compute the interaction graphs for all matroids on ≤ 9 elements (classified in the matroid database) and verify that treewidth ≤ rank - 1. Any counterexample refutes the conjecture.

**Impact**: Matroid polynomials are the primary source of Lorentzian polynomials in combinatorics. If their interaction graphs have bounded treewidth, our support-bounded counting results apply directly, giving efficient recognition algorithms for this important class.

**Catalog References**: `Pythagorean/TreewidthFPT.lean` — `treewidth_bounds_support`, `boundedSuppCount_le`

**Proof Strategy**: For a matroid M of rank r, every basis has exactly r elements, so every monomial in the basis-generating polynomial has support of size exactly r. The interaction graph is then a subgraph of the Johnson graph J(n, r). Bound the treewidth of this Johnson subgraph using the matroid's exchange axiom: the exchange property ensures that the interaction graph is "locally tree-like" in a precise sense.

**Domain Bridges**: Matroid Theory ↔ Graph Theory ↔ Parameterized Complexity

**Lineage**: Extends `support_forms_clique` to the matroid setting.

**Ambition**: extension

---

### Direction 4: Approximate Lorentzian Recognition via Treewidth

**Conjecture**: For polynomials with interaction graph of treewidth w, there exists an ε-approximate Lorentzian recognition test running in time poly(n, d, 1/ε) · f(w), where "ε-approximate" means the test accepts all Lorentzian polynomials and rejects polynomials that are ε-far from Lorentzian (in coefficient norm).

**Test**: Implement a randomized test that samples O(w^d · log(1/δ)) random derivative directions and checks the Hessian condition at each. For path-structured polynomials (w = 1), verify that O(d · log(n)) samples suffice for 99% accuracy on random test polynomials.

**Impact**: Even when exact recognition is tractable, approximate methods could be dramatically faster. This would make Lorentzian testing practical for large-scale polynomials arising in machine learning (DPP kernels) and physics (partition functions).

**Catalog References**: `Catalog/Bridges/LorentzianRecognition.lean` — `HasRecursiveLorentzianCertificate`, `recursive_certificate_sound`; `Pythagorean/TreewidthFPT.lean` — `bounded_support_polynomial_in_d`

**Proof Strategy**: Use the tree decomposition to define a sampling distribution over multiindices that concentrates on "informative" leaves. The key insight: most leaves are redundant because the Hessian condition varies smoothly along the tree. Use entropy methods to show that O(w^d) independent samples suffice to capture all distinct Hessian behaviors.

**Domain Bridges**: Approximation Algorithms ↔ Information Theory ↔ Algebraic Combinatorics

**Lineage**: Combines the counting bounds from this cycle with randomized testing ideas.

**Ambition**: extension

---

### Direction 5: Treewidth Lower Bounds from Lorentzian Hardness

**Conjecture**: For every k ≥ 3, there exists an explicit family of homogeneous polynomials {p_n} with n variables, degree d = Θ(n), and interaction graph of treewidth exactly k, such that Lorentzian recognition of p_n requires Ω(n · k^d) Hessian checks—matching the support-bounded upper bound up to constant factors.

**Test**: For k = 3 (treewidth 2), construct an explicit polynomial family over n variables of degree d with exactly C(n, 3) · (d-1)² leaf checks needed. Verify computationally for n ≤ 12 that no clever reordering of derivative directions reduces the count below C(n, 3) · (d-3).

**Impact**: This would show that our upper bounds are tight, completing the complexity picture for each treewidth level. It would demonstrate that the C(n, k) · (d+1)^k bound is the correct answer, not an artifact of our proof technique.

**Catalog References**: `Catalog/Pythagorean/LorentzianHardness.lean` — `multiindex_count_exponential_lower`, `binaryToMultiindex_injective`; `Pythagorean/TreewidthFPT.lean` — `boundedSuppCount_le`

**Proof Strategy**: Adapt the binary-string-to-multiindex injection from the exponential lower bound proofs. For treewidth k, construct multiindices whose support is exactly a specific (k+1)-clique in the interaction graph, and show that all such multiindices yield distinct Hessian conditions (no two give proportional Hessians). The injection must respect the treewidth constraint while maximizing the number of distinct leaves.

**Domain Bridges**: Combinatorial Optimization ↔ Algebraic Combinatorics ↔ Proof Complexity

**Lineage**: Refines the lower bound technique from `Catalog/Pythagorean/LorentzianHardnessBarrier.lean` to specific treewidth levels.

**Ambition**: extension
