# Future Directions: Lorentzian Equivalence via Hessian Descent

## Synthesis

The Hessian descent certificate program aims to convert the spectral characterization of Lorentzian polynomials into a purely combinatorial and algebraic framework. Our results establish the forward direction (Lorentzian ⇒ coefficient inequalities) and identify the precise obstruction to the converse (exchange support and derivative descent). The five directions below form a coherent research program: Direction 1 attacks the central conjecture through restricted cases, Direction 2 builds the algorithmic infrastructure needed for practical applications, Directions 3-4 export the framework to discrete optimization and statistical physics, and Direction 5 pursues the deepest mathematical generalization through connections to Hodge theory. Each direction reinforces the others — progress on the matroid case (Direction 1) would immediately yield algorithmic applications (Direction 2) and statistical physics consequences (Direction 4).

---

## Direction 1: Prove the Hessian Descent Conjecture for Multi-Affine Polynomials

**Conjecture:** For multi-affine homogeneous polynomials (where each variable appears with exponent at most 1) with positive coefficients, the Hessian descent certificate is equivalent to recursive Lorentzianity. That is:
$$\text{MixedLC} + \text{ExchangeSupport} + \text{FullDerivativeDescent} \iff \text{IsRecursivelyLorentzian}$$

**Test:** Implement exhaustive verification for all multi-affine polynomials in $n \leq 7$ variables with integer coefficients bounded by 20. For the matroid subcase, verify against known Lorentzian matroid catalogs. A single counterexample falsifies the conjecture; verification up to $n = 7$ provides strong evidence.

**Impact:** The multi-affine case is the most important for applications to matroid theory, graph theory, and combinatorial optimization. A positive resolution would immediately yield: (a) a combinatorial proof of the Brändén-Huh log-concavity theorem for matroids, (b) an efficient Lorentzian recognition algorithm for matroid basis polynomials, and (c) a bridge between Lorentzian polynomial theory and strongly Rayleigh measures.

**The key insight is** that multi-affine polynomials have the simplest possible support structure (subsets of $\{0,1\}^n$), making the exchange axiom identical to the matroid exchange property. This eliminates the "derivative descent" requirement because each differentiation step is an evaluation at 0 or 1, producing another multi-affine polynomial of lower degree.

**Why now?** The formal verification infrastructure for Lorentzian polynomials (recursive predicates, Brändén-Huh equivalence, support exchange) is now in place. The multi-affine restriction removes the most technically demanding aspects of the general conjecture while preserving all the applications.

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsRecursivelyLorentzian, recursivelyLorentzian_iff_brandenHuh), `Pythagorean/HessianDescentEquivalence.lean` (MixedDirectionalLogConcave, HasExchangeSupport, lorentzian_implies_pairwise_det)

**Proof Strategy:** Induction on the number of variables $n$. Base case $n \leq 2$ follows from `dim_two_equivalence`. Inductive step: restrict to a hyperplane $x_n = t$ and show the restricted polynomial inherits the certificate. Use the exchange property to control the support of the restriction.

**Domain Bridges:** Matroid theory (basis exchange ↔ support exchange), combinatorial optimization (matroid intersection algorithms)

**Lineage:** Extends `lorentzian_implies_pairwise_det` and `counterexample_not_lorentzian` (which shows the necessity of exchange support).

**Ambition:** Grand challenge — would resolve the key open question in the program.

---

## Direction 2: Efficient Algorithmic Certificate Verification with Formal Soundness

**Conjecture:** There exists a randomized algorithm that checks the Hessian descent certificate for a degree-$d$ polynomial in $n$ variables with $m$ nonzero terms in time $O(m \cdot n^2 \cdot \text{polylog}(m))$, with one-sided error.

**Test:** Implement the randomized checker using polynomial identity testing techniques. Benchmark against direct eigenvalue computation on random Lorentzian polynomials with $n \leq 50$, $d \leq 10$, $m \leq 10^4$. Measure wall-clock speedup and verify correctness against exact spectral methods.

**Impact:** Would make Lorentzian recognition practical for large-scale applications in optimization, machine learning (determinantal point processes), and symbolic computation.

**The key insight is** that the mixed LC condition $c_{ii} c_{jj} \leq c_{ij}^2$ can be checked in a streaming fashion — each inequality involves only 3 coefficient lookups, and the total number of inequalities is $O(n^2)$ per leaf. Combined with random sampling of derivative leaves, this yields a near-linear-time probabilistic certificate.

**Why now?** The formal soundness theorem (`certificate_implies_pairwise_ineq`) provides the correctness foundation, and the complexity comparison shows a factor-$n$ advantage over spectral methods.

**Catalog References:** `Pythagorean/HessianDescentEquivalence.lean` (certificate_implies_pairwise_ineq, HessianDescentCertificate)

**Proof Strategy:** Formalize the randomized algorithm in Lean using `Decidable` instances for rational coefficient comparisons. Prove that the deterministic checker is sound. For the randomized version, prove that a random sample of $O(n \log n)$ derivative leaves detects violations with high probability under uniform sampling.

**Domain Bridges:** Computational complexity (polynomial identity testing, PIT), randomized algorithms, symbolic computation

**Lineage:** Builds on `certificate_implies_pairwise_ineq` and the complexity analysis in the research paper.

**Ambition:** Solid extension — primarily engineering and formalization work.

---

## Direction 3: M-Convexity Bridge to Discrete Optimization

**Conjecture:** For homogeneous polynomials with positive coefficients, recursive Lorentzianity implies that the support is an M-convex set (in the sense of Murota's discrete convex analysis). Moreover, the coefficient function restricted to the M-convex support satisfies a discrete analogue of geodesic convexity.

**Test:** For all Lorentzian polynomials generated by random limits of products of linear forms (in $n \leq 6$ variables, $d \leq 8$), verify: (a) the support is M-convex, (b) the log-coefficient function $\alpha \mapsto \log c_\alpha$ satisfies the discrete midpoint convexity condition on the support.

**Impact:** Would establish a formal bridge between Lorentzian polynomial theory and discrete convex analysis, enabling: (a) application of discrete convex optimization algorithms (e.g., steepest descent on M-convex sets) to Lorentzian polynomial problems, (b) new proofs of matroid optimization results via Lorentzian certificates.

**The key insight is** that the exchange-closed support property (`HasExchangeSupport`) is precisely the combinatorial definition of M-convexity, and the mixed LC condition can be interpreted as a second-order discrete convexity condition on the log-coefficient function. Together, these make the coefficient landscape a "discrete Riemannian manifold" with curvature constraints.

**Why now?** The formalization of `HasExchangeSupport` and `lorentzian_implies_pairwise_det` provides the formal foundation. Murota's framework is well-developed but lacks Lean formalization, creating an opportunity for a first formal bridge.

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange), `Pythagorean/HessianDescentEquivalence.lean` (HasExchangeSupport, mixed_lc_geometric_mean)

**Proof Strategy:** Formalize M-convexity in Lean. Prove that `HasExchangeSupport` implies M-convexity (this should be definitional). For the discrete geodesic convexity, use the three-term chain inequality (`mixed_lc_three_term`) to establish the midpoint condition.

**Domain Bridges:** Discrete convex analysis (M-convexity, valuated matroids), combinatorial optimization (submodular function minimization), tropical geometry (tropical convexity)

**Lineage:** Extends `HasExchangeSupport`, `mixed_lc_three_term`, and `mixed_lc_geometric_mean`.

**Ambition:** Grand challenge — would create an entirely new formal connection between spectral algebra and discrete optimization.

---

## Direction 4: Negative Dependence and Partition Function Characterization

**Conjecture:** For multi-affine polynomials with positive coefficients, mixed directional log-concavity is equivalent to the *strongly Rayleigh* property: for every pair of sites $i, j$, the normalized coefficient measure satisfies
$$\mu(\sigma_i = 1, \sigma_j = 1) \cdot \mu(\sigma_i = 0, \sigma_j = 0) \leq \mu(\sigma_i = 1, \sigma_j = 0) \cdot \mu(\sigma_i = 0, \sigma_j = 1)$$

**Test:** For random multi-affine polynomials in $n \leq 8$ variables, compute: (a) the mixed LC condition, (b) the strongly Rayleigh condition, (c) pairwise correlations under the coefficient measure. Verify that mixed LC ⇒ negative correlations, and search for the converse or counterexample.

**Impact:** Would provide a formal bridge between Lorentzian polynomial theory and statistical physics, specifically: (a) characterizing which partition functions have negatively correlated Gibbs measures, (b) proving concentration inequalities for determinantal point processes via coefficient certificates, (c) developing sampling algorithms for negatively dependent distributions using the certificate structure.

**The key insight is** that the mixed LC condition $c_{ii} c_{jj} \leq c_{ij}^2$ is, for multi-affine polynomials, exactly the condition that the normalized coefficients form a negatively dependent probability measure. The theorem `mixed_lc_reversed_cauchy_schwarz` is the degree-2 specialization of this correspondence.

**Why now?** The connection between Lorentzian polynomials and strongly Rayleigh measures was observed by Brändén (2007) and Borcea-Brändén (2009), but a formal proof using coefficient certificates is new.

**Catalog References:** `Pythagorean/HessianDescentEquivalence.lean` (mixed_lc_reversed_cauchy_schwarz, MixedDirectionalLogConcave), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, logConcaveN_mul)

**Proof Strategy:** Formalize the strongly Rayleigh property. For the forward direction, use `mixed_lc_reversed_cauchy_schwarz` to derive the negative correlation inequality. For the converse, specialize the multi-affine case and use the fact that each differentiation is an evaluation.

**Domain Bridges:** Statistical physics (negative dependence, FKG inequality), probability theory (determinantal point processes), machine learning (DPP sampling)

**Lineage:** Extends `mixed_lc_reversed_cauchy_schwarz` and connects to `KFoldLogConcave` through ratio sequence analysis.

**Ambition:** Solid extension with grand-challenge potential if the full equivalence is proved.

---

## Direction 5: Hodge-Riemann Relations via Coefficient Descent

**Conjecture:** The Hodge-Riemann relations for projective toric varieties (as formulated by Adiprasito-Huh-Katz 2018) can be reformulated as a hierarchy of coefficient inequalities on the volume polynomial, generalizing the mixed LC condition to a full Lefschetz-type theory.

**Test:** For the volume polynomial of a smooth projective toric variety associated to a simple polytope $P$ in $\mathbb{R}^d$ ($d \leq 5$): (a) verify that the mixed volumes satisfy the mixed LC condition, (b) verify that the Lefschetz operator (multiplication by a linear form) preserves the certificate structure, (c) compare the coefficient-inequality formulation with the known Hodge-Riemann bilinear relations.

**Impact:** Would provide an elementary, combinatorial reformulation of the Hodge-Riemann relations — one of the deepest results in algebraic geometry — purely in terms of volume inequalities. This would: (a) make the Hodge-Riemann machinery accessible to combinatorialists, (b) suggest new log-concavity results beyond the matroid setting, (c) potentially lead to new proofs of the Kähler package for non-realizable matroids.

**The key insight is** that the Hodge-Riemann bilinear relations, when specialized to the diagonal of the coefficient matrix, reduce to exactly the mixed LC condition. The full Hodge-Riemann theory corresponds to a "graded" version of the Hessian descent certificate, where the certificate is compatible with a filtration by degree.

**Why now?** The Adiprasito-Huh-Katz proof of the Rota-Welsh conjecture uses Hodge-Riemann relations in an essential way. A coefficient-inequality reformulation would make this proof accessible without algebraic geometry, and our formal infrastructure provides the foundation for such a reformulation.

**Catalog References:** `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsBrandenHuhLorentzian, recursivelyLorentzian_iff_brandenHuh), `Pythagorean/HessianDescentEquivalence.lean` (MixedDirectionalLogConcave, mixed_lc_three_term)

**Proof Strategy:** Formalize the volume polynomial of a polytope. Define the Lefschetz operator as multiplication by a linear form. Show that the Hard Lefschetz theorem implies the mixed LC condition at every derivative level. For the converse, use the Hodge-Riemann bilinear relations to reconstruct the Lorentzian signature from the coefficient inequalities.

**Domain Bridges:** Algebraic geometry (Hodge theory, Kähler manifolds), combinatorial topology (simplicial complexes, face rings), convex geometry (mixed volumes, Aleksandrov-Fenchel inequalities)

**Lineage:** Would extend the entire Hessian descent program to a geometric setting, connecting `mixed_lc_three_term` to the Aleksandrov-Fenchel inequalities.

**Ambition:** Grand challenge — would rewrite a chapter of algebraic geometry in combinatorial terms.
