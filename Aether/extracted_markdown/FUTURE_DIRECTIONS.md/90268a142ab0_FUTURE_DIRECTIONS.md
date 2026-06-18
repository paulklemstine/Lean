# Future Directions: Support Minor Theory for Polynomial Supports

## Synthesis

The establishment of deletion–contraction duality for M-convex polynomial supports opens a systematic program connecting discrete convex analysis to classical invariant theory. The five directions below form a coherent research arc: Direction 1 (universality) provides the algebraic foundation, Direction 2 (Lorentzian closure) tests the geometric boundary, Direction 3 (tropical minors) exports the framework to a new domain, Direction 4 (Hodge induction) applies the machinery to prove new inequalities, and Direction 5 (algorithmic decomposition) makes the theory computationally effective. Together, they constitute a program for building the polynomial-support analogue of the matroid theory revolution of the 1960s–1970s.

---

## Direction 1: Universal Support-Tutte Polynomial

**Conjecture:** Any support invariant F satisfying (i) multiplicativity on disjoint-coordinate direct sums and (ii) a deletion–contraction recurrence on M-convex supports factors uniquely through a universal support-Tutte polynomial T_S(x, y), i.e., F = φ ∘ T_S for some ring homomorphism φ.

**The key insight is** that the deletion–contraction recurrence on supports, combined with the loop/coloop trichotomy, generates a free algebraic structure indexed by "support activities" analogous to Tutte's internal/external activities. The universality would follow from showing that every M-convex support admits a canonical activity ordering.

**Why now?** The minor closure theorems (Theorems 3.1–3.4 in `Catalog/Pythagorean/SupportMinorTheory.lean`) guarantee that the recurrence is well-defined on the class of M-convex supports. This was the missing structural prerequisite.

**Test:** For all M-convex subsets of the degree-≤5 simplex on 4 variables, compute the support-Tutte polynomial using two different coordinate orderings. If the values agree in all cases, universality is strongly supported. A single disagreement would disprove universality and redirect toward a weaker theory (e.g., universality only for matroid-induced supports).

**Impact:** A universal support-Tutte polynomial would be a new algebraic invariant of M-convex sets, generalizing the classical Tutte polynomial and potentially capturing information invisible to matroid Tutte theory (e.g., degree information from non-{0,1} supports).

**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (SupportTutteInvariant structure, minor_step_card_le).

**Proof Strategy:** 
1. Define support activities via a total ordering on coordinates, analogous to Tutte (1954).
2. Show the activity-based expansion agrees with the deletion–contraction recurrence.
3. Prove uniqueness by induction on support cardinality.

**Domain Bridges:** Statistical physics (Potts model partition functions), knot theory (Jones polynomial via Tutte specialization).

**Lineage:** Direct extension of Theorem 3.4 (exchange_of_minor) in the current catalog.

**Ambition:** Grand challenge — would establish a new universal algebraic invariant.

---

## Direction 2: Lorentzian Minor Closure Conjecture

**Conjecture:** If S is the support of a Lorentzian polynomial (in the sense of Brändén–Huh), then every minor of S is realizable as the support of a Lorentzian polynomial.

**The key insight is** that Lorentzianity is a stronger condition than exchange (it additionally requires Hessian signature conditions on all degree-2 derivatives). The conjecture posits that this stronger condition is also minor-closed. If true, it would mean Lorentzian polynomials form a combinatorial species with both algebraic and geometric structure preserved under minors.

**Why now?** We have proved that exchange (the combinatorial shadow of Lorentzianity) is minor-closed. The remaining question is whether the analytic/geometric conditions are also preserved. Computational evidence from `demo.py` shows no counterexample for degree ≤ 6 on ≤ 5 variables.

**Test:** 
1. Enumerate all minors of supports of e_k(x_1,...,x_n) for n ≤ 7, k ≤ 4.
2. For each minor, attempt to construct a Lorentzian polynomial with that support using the recognition criteria from `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`.
3. Search for a counterexample: a minor support that satisfies exchange but admits no Lorentzian realization.

**Impact:** Would establish Lorentzian polynomials as a minor-closed combinatorial species, enabling inductive classification programs and connecting Hodge theory to matroid-type decomposition.

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange, IsBrandenHuhLorentzian), `Catalog/Pythagorean/SupportMinorTheory.lean` (exchange_of_minor).

**Proof Strategy:** 
1. Show deletion preserves Lorentzianity by analyzing Hessian signature under variable restriction.
2. Show contraction preserves Lorentzianity by analyzing the effect on quadratic forms.
3. Use the recursive spectral certificate (recursivelyLorentzian_iff_brandenHuh) to reduce to checking degree-2 leaves.

**Domain Bridges:** Algebraic geometry (Hodge index theorem), discrete convex analysis (M-convex optimization).

**Lineage:** Builds on both the minor theory (this paper) and the Lorentzian recognition (LorentzianRecognitionComplete.lean).

**Ambition:** Grand challenge — would unify Hodge theory with matroid minor theory.

---

## Direction 3: Tropical Minor Theory via Support Duality

**Conjecture:** Support deletion corresponds to tropicalization (restricting to a tropical hyperplane), and support contraction corresponds to tropical projection. The support minor lattice induces a "tropical minor lattice" on the associated tropical linear spaces, compatible with the valuated matroid structure of Dress–Wenzel.

**The key insight is** that the Newton polytope of a polynomial carries tropical geometric information: deletion at coordinate i intersects the Newton polytope with the hyperplane x_i = 0 (a tropical operation), while contraction projects along the x_i axis after dehomogenization. The minor-closure of exchange means that tropical linear spaces of M-convex origin are closed under these tropical operations.

**Why now?** The formal proof that coordinate face restrictions preserve exchange (exchange_of_multi_deletion) establishes the combinatorial foundation. The tropical connection requires only the geometric interpretation.

**Test:** For small tropical linear spaces (arising from uniform matroids U(k,n) with n ≤ 6), verify that the deletion–contraction on supports induces the correct operations on the dual tropical variety.

**Impact:** Would create a bridge between support minor theory and tropical geometry, with applications to tropical intersection theory and the study of Dressians.

**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (supportDeleteMulti, exchange_of_multi_deletion), `Catalog/Pythagorean/TropicalMConvexity.lean`.

**Proof Strategy:**
1. Define the Newton polytope map S ↦ conv(S).
2. Show D_i(S) ↦ conv(S) ∩ {x_i = 0} (face restriction).
3. Show C_i(S) ↦ π_i(conv(S) ∩ {x_i = μ}) (projection of a face).
4. Verify compatibility with the tropical operations on the dual variety.

**Domain Bridges:** Tropical geometry, algebraic geometry (Newton polytopes), optimization (M-convex function minimization).

**Lineage:** Extension of the multi-deletion theorem, building toward the tropical geometry connections described in Murota (2003) and Maclagan–Sturmfels.

**Ambition:** Solid extension with potential for surprising tropical-algebraic connections.

---

## Direction 4: Hodge-Theoretic Induction via Deletion–Contraction

**Conjecture:** The Hodge-type inequalities for Lorentzian polynomials (mixed discriminant positivity, ultra-log-concavity of coefficients) can be proved by induction on support minors, with the deletion–contraction recurrence providing the inductive step.

**The key insight is** that Hodge-type inequalities typically involve comparing coefficients of a polynomial across different degree components. The deletion–contraction recurrence expresses these coefficients recursively in terms of simpler supports. If the inequality holds for all minors (by induction) and is "compatible" with the deletion–contraction recurrence, it holds for the original support.

**Why now?** The formal minor theory provides the inductive framework. Previously, Hodge-type proofs relied on algebraic geometry (intersection theory on toric varieties) or combinatorial arguments without a systematic inductive structure.

**Test:** Prove the ultra-log-concavity inequality |a_k|² ≥ |a_{k-1}| · |a_{k+1}| for the sequence of coefficient sums by induction on support minors for the special case of elementary symmetric polynomials.

**Impact:** Would provide a new, purely combinatorial proof technique for Hodge-type inequalities, potentially applicable to settings where algebraic geometry is unavailable.

**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (exchange_of_minor), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (lorentzian_reversed_cauchy_schwarz).

**Proof Strategy:**
1. Formulate the target inequality as a property of exchange supports.
2. Verify the base case (empty or singleton supports).
3. Show the inductive step: if the inequality holds for D_i(S) and C_i(S), it holds for S.
4. Apply by well-founded induction on support cardinality.

**Domain Bridges:** Algebraic geometry (Hodge theory), combinatorics (log-concavity), convex geometry.

**Lineage:** Builds on the reversed Cauchy–Schwarz theorem in LorentzianRecognitionComplete.lean and the minor closure results.

**Ambition:** Solid extension — would provide new proof techniques for known results with potential to reach new ones.

---

## Direction 5: Algorithmic Support Decomposition

**Conjecture:** The deletion–contraction structure on M-convex supports yields efficient algorithms for:
(a) Counting the number of bases of a support (analogous to spanning tree counting via matrix-tree theorem),
(b) Optimization over M-convex supports via minor-guided branch-and-bound,
(c) Sampling from the uniform distribution on a support via deletion–contraction trees.

**The key insight is** that the deletion–contraction tree has depth at most |S| and branching factor at most |ι|, giving a search tree of manageable size. For matroid-induced supports, the tree structure recovers known polynomial-time algorithms; for general M-convex supports, it may yield new algorithms.

**Why now?** The cardinality bounds (supportDelete_card_lt, supportContract_card_le) formally guarantee that the recursion terminates and provide explicit depth bounds.

**Test:** 
1. Implement the deletion–contraction tree for degree-d simplices on n variables.
2. Compare counting speed against brute-force enumeration.
3. Measure the tree size as a function of |S| and n.

**Impact:** Would provide a new family of algorithms for discrete optimization on M-convex sets, complementing the exchange-based greedy algorithms of Murota (2003).

**Catalog References:** `Catalog/Pythagorean/SupportMinorTheory.lean` (supportDelete_card_lt, supportContract_card_le, minor_step_card_le), `Catalog/Pythagorean/MConvexOptimization.lean`.

**Proof Strategy:**
1. Formalize the deletion–contraction tree as a binary tree with leaves labeled by base cases.
2. Bound the depth by |S| and the width by appropriate measures.
3. Prove correctness of the counting algorithm by induction on tree structure.

**Domain Bridges:** Combinatorial optimization, randomized algorithms, statistical physics (partition function computation).

**Lineage:** Extension of the certified optimization results in MConvexOptimization.lean, using the new minor structure.

**Ambition:** Solid extension with immediate practical applicability.
