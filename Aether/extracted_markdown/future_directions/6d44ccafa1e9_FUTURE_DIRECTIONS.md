# Future Directions: Complexity of Lorentzian Recognition

## Synthesis

The theorems proved in this cycle — tangent-space negativity, certificate-size bounds, reversed Cauchy–Schwarz, and certificate soundness — establish the first formal bridge between Lorentzian polynomial theory and computational complexity. They reveal that Lorentzianity has a clean fixed-parameter-tractable recognition algorithm for fixed degree, while the recursive structure strongly constrains what unrestricted-degree algorithms can achieve.

The five directions below form a coherent research program: Direction 1 (hardness) establishes the upper complexity barrier, Direction 2 (sparse certificates) lowers the practical cost for structured inputs, Direction 3 (completeness) closes the theoretical gap between our recursive predicate and the full Brändén–Huh definition, Direction 4 (sampling) applies certified Lorentzianity to algorithmic combinatorics, and Direction 5 (numerical stability) brings the theory to engineering practice. Together, they would create a complete pipeline from abstract Hodge-theoretic positivity to practical certified computation.

---

## Direction 1: Hardness of Unrestricted-Degree Lorentzian Recognition

**Conjecture.** When the degree d is part of the input (not fixed), deciding whether a homogeneous polynomial with nonneg integer coefficients is Lorentzian is coNP-hard.

**Test.** Reduce a known coNP-hard problem — such as verifying that a symmetric matrix has no positive eigenvalue (which is coNP-complete for matrices given in factored form) — to Lorentzian recognition. Construct explicit polynomial families where any recursive certificate must examine at least n^{Ω(d)} quadratic leaves. A disproof would exhibit a polynomial-time algorithm for unrestricted-degree recognition.

**Impact.** This would be the first formal hardness result for any Hodge-theoretic positivity predicate, creating a new complexity class boundary. It would definitively separate "fixed-degree tractable" from "unrestricted-degree hard" and motivate the development of approximation algorithms.

**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `card_multiindex_le_pow`, `quadratic_leaf_count_le` (upper bounds that the hardness would complement).

**Proof Strategy.** Encode 3-SAT unsatisfiability as a Lorentzian recognition instance. Given a 3-SAT formula φ on m clauses, construct a degree-(m+2) polynomial P_φ in n variables such that P_φ is Lorentzian iff φ is unsatisfiable. The construction uses the clause-variable incidence structure to define derivative branches that are Lorentzian iff the clause is satisfied.

**Domain Bridges.** Computational complexity → algebraic combinatorics. Connects the Cook–Levin theory of NP-completeness to Hodge-theoretic positivity.

**Lineage.** Builds on `quadratic_leaf_count_le` (polynomial upper bound) to show the bound is tight in degree.

**Ambition.** Grand challenge. A positive resolution would be a landmark in algebraic complexity theory.

---

## Direction 2: Sparse-Support Certificate Compression

**Conjecture.** For matroid basis generating polynomials of rank r on ground set [n], the number of nonzero quadratic leaves is O(n^2 · r^{d-4}) rather than n^{d-2}, where d is the degree.

**Test.** Compute derivative leaves for uniform matroids U_{r,n}, graphic matroids of sparse graphs, and transversal matroids. Count the number of nonzero quadratic leaves and compare to the worst-case bound n^{d-2}. A disproof would exhibit a matroid family where the nonzero leaf count matches the worst case.

**Impact.** This would make Lorentzian recognition practical for partition-function polynomials arising in combinatorial optimization and statistical physics, where support is typically sparse relative to the ambient monomial space.

**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `multiIndexSet`, `numberOfQuadraticLeaves`; `Speculative/AutoResearch/LorentzianMConvex.lean`: `NewtonSupport`, `IsMConvexExchangeNat`.

**Proof Strategy.** Use the M-convex exchange property of the Newton support (from the existing catalog) to show that many derivative branches have zero coefficient. The exchange property constrains which multiindices can appear in the support of iterated derivatives, dramatically pruning the recursion tree.

**Domain Bridges.** Matroid theory → algorithmic complexity → statistical physics (partition functions of matroids).

**Lineage.** Builds on the M-convex support theorem in `LorentzianMConvex.lean` and the leaf-counting bound in this cycle.

**Ambition.** Solid extension. The uniform matroid case should be provable; general matroids require new structural lemmas.

---

## Direction 3: Completeness of Recursive Spectral Certificates

**Conjecture.** The recursive spectral predicate (all quadratic leaves have Lorentzian Hessian signature) is equivalent to the Brändén–Huh definition of Lorentzianity for homogeneous polynomials with nonneg coefficients.

**Test.** Verify computationally for all homogeneous polynomials of degree ≤ 5 in ≤ 4 variables that the recursive predicate matches the full Brändén–Huh definition (which additionally requires the polynomial to be a limit of products of linear forms with nonneg coefficients). A disproof would exhibit a polynomial that satisfies the recursive predicate but is not Lorentzian in the full sense.

**Impact.** A positive resolution would show that our certified algorithm is not just sound but complete: it exactly characterizes Lorentzianity. This would be the first formal completeness result for any recursive characterization of Lorentzianity.

**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `IsRecursivelyLorentzian`, `RecursiveLorentzianCertificate`, `recursive_certificate_sound`.

**Proof Strategy.** For one direction (recursive ⟹ Lorentzian), use the characterization theorem of Brändén–Huh: a homogeneous polynomial with nonneg coefficients, support satisfying the exchange property, and Hessian signature condition on all quadratic leaves is Lorentzian. The converse (Lorentzian ⟹ recursive) follows from closure of Lorentzianity under partial differentiation.

**Domain Bridges.** Algebraic combinatorics ↔ spectral linear algebra.

**Lineage.** Direct continuation of `recursive_certificate_sound` (soundness).

**Ambition.** Solid extension. The key obstacle is formalizing enough of the Brändén–Huh theory in Lean.

---

## Direction 4: Efficient Sampling from Lorentzian Certificates

**Conjecture.** Given a degree-d Lorentzian polynomial f in n variables, one can sample from the probability distribution proportional to the coefficients of f in expected time O(n^{d+1} · log n), using the recursive certificate structure as a guide.

**Test.** Implement a certificate-guided sampling algorithm for matroid basis generating polynomials and compare runtime and mixing time to state-of-the-art methods (e.g., basis exchange walks). A disproof would show that certificate-guided sampling has provably worse mixing time than exchange walks for some matroid family.

**Impact.** This would create the first direct algorithmic application of Lorentzian certificates, connecting the complexity theory of recognition to the complexity of sampling.

**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `IsRecursivelyLorentzian`, `lorentzian_reversed_cauchy_schwarz` (the reversed Cauchy–Schwarz provides the key mixing-time bound).

**Proof Strategy.** Use the reversed Cauchy–Schwarz inequality to bound the spectral gap of a Markov chain defined by the derivative tree. At each internal node of the certificate tree, use the Lorentzian signature to construct a log-concave conditional distribution, then sample via rejection sampling with bounded rejection probability.

**Domain Bridges.** Algorithmic combinatorics → statistical physics → probability (Markov chain mixing).

**Lineage.** Extends `lorentzian_reversed_cauchy_schwarz` from a structural result to an algorithmic tool.

**Ambition.** Grand challenge. Connecting certificate structure to sampling efficiency would be a significant advance.

---

## Direction 5: Numerical Stability of Lorentzian Recognition

**Conjecture.** There exists ε₀ > 0 depending only on d such that if all quadratic leaves of a degree-d polynomial f satisfy the spectral condition with margin ε₀ (i.e., the second-largest eigenvalue of each Hessian is at most −ε₀ · ‖H‖), then f is Lorentzian even under O(ε₀²)-perturbations of the coefficients.

**Test.** Perturb the coefficients of known Lorentzian polynomials (elementary symmetric polynomials, matroid basis polynomials) by random noise of varying magnitude, and check how the eigenvalue gap of the quadratic leaves degrades. A disproof would exhibit a Lorentzian polynomial whose Lorentzianity is destroyed by arbitrarily small perturbations.

**Impact.** This would make Lorentzian recognition practical with floating-point arithmetic, enabling deployment in machine learning and optimization pipelines where exact computation is infeasible.

**Catalog References.** `Pythagorean/LorentzianRecognition.lean`: `HasAtMostOnePositiveEigenvalue`, `lorentzian_signature_tangent_neg_semidef` (the tangent-space theorem suggests spectral gaps persist under perturbation).

**Proof Strategy.** Use the tangent-space negativity theorem to establish that the spectral gap of the Hessian is lower-semicontinuous in the coefficients. The key inequality is: if Q(x) > 0 and the second eigenvalue of H has magnitude δ, then tangent-space negativity holds with margin δ · ‖x‖² / ‖Hx‖.

**Domain Bridges.** Numerical linear algebra → optimization → engineering applications (robust ML, robust control).

**Lineage.** Extends `lorentzian_signature_tangent_neg_semidef` to a quantitative/robust setting.

**Ambition.** Solid extension. The qualitative result (openness of Lorentzianity) is known; the quantitative bound is new.
