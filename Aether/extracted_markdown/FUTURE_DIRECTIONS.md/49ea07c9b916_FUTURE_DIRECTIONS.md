# Future Directions: Lorentzian CondNSD Spectral Theory

## Synthesis

The results established here — CondNSD closure under addition, the outer-product subtraction mechanism, the negative Hadamard square theorem, and the negative-of-Laplacian criterion — form a coherent algebraic foundation for a spectral theory of Lorentzian polynomials. The key unifying insight is that the log-Hessian at the all-ones point encodes a spectral shadow of Lorentzianity visible through a simple eigenvalue computation. The directions below push this foundation in five complementary ways: toward the full conjecture (Direction 1), toward quantitative spectral gap bounds (Direction 2), toward information geometry (Direction 3), toward algorithmic applications (Direction 4), and toward a grand unification with Hodge theory (Direction 5).

---

## Direction 1: Degree-2 Spectral Reduction and Inductive Proof

**Conjecture:** For homogeneous multilinear quadratic polynomials p(x) = ∑_{i<j} a_{ij} x_i x_j with nonneg coefficients and at most one positive eigenvalue of the coefficient matrix A, the log-Hessian at 1 is CondNSD.

**Test:** Enumerate all symmetric nonneg matrices A with at most one positive eigenvalue (by random sampling and spectral projection), compute L_p, and check CondNSD. A single counterexample disproves; passage through 10^6 random instances at each dimension n ≤ 20 builds strong evidence.

**The key insight is** that the degree-2 case is the atomic step of a potential inductive proof. If we can show that the CondNSD property propagates from degree-d derivatives to degree-(d+1) polynomials via Euler's homogeneity identity ∑ᵢ xᵢ ∂p/∂xᵢ = d·p, then the full conjecture follows by induction from the degree-2 base case.

**Why now?** The outer-product subtraction mechanism (Theorem 5.1) and the product stability (Theorem 4.1) provide the exact algebraic tools needed for the inductive step. What was missing was a formalization of the degree-2 spectral condition and its relation to CondNSD — now provided by the current framework.

**Impact:** Proves or disproves the Lorentzian CondNSD Conjecture in full generality.

**Catalog References:** `Pythagorean/LorentzianCondNSD/Basic.lean` (logHessian_condNegSemidef_of_hessian_condNegSemidef, condNegSemidef_of_product), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian).

**Proof Strategy:** (1) Prove the degree-2 case using the at-most-one-positive-eigenvalue condition. (2) Establish an Euler identity for the log-Hessian: relate L_p to a weighted average of L_{∂ᵢp}. (3) Propagate CondNSD upward through the derivative tree.

**Domain Bridges:** Hodge–Riemann relations (algebraic geometry) → spectral signature conditions (linear algebra) → CondNSD certificates (probability).

**Lineage:** Directly builds on the foundational theorems of this paper.

**Ambition:** Grand challenge — would resolve the central conjecture and establish a new spectral characterization of Lorentzian polynomials.

---

## Direction 2: Spectral Gap Bounds and Matroid Mixing Times

**Conjecture:** For the basis generating polynomial of a matroid M on n elements with rank k, the spectral gap of −L_p on the zero-sum subspace satisfies gap(M) ≥ c/(n·k) for a universal constant c > 0.

**Test:** Compute spectral gaps for all matroids on ≤ 9 elements (from matroid enumeration databases), fit the bound, and identify the extremal matroids.

**The key insight is** that the spectral gap of the log-Hessian controls the mixing time of a natural random walk on matroid bases. If −L_p acts as a graph Laplacian on centered perturbations, then the spectral gap gives a Poincaré inequality for the walk, yielding mixing time bounds of O(n²k/gap).

**Why now?** Recent breakthroughs by Anari, Liu, Oveis Gharan, and Vinzant on log-concave polynomials and matroid basis counting rely on spectral gap estimates obtained through sophisticated geometric arguments. The log-Hessian approach could provide a direct, computational alternative.

**Impact:** Quantitative mixing time bounds for matroid basis sampling; practical certification of MCMC convergence.

**Catalog References:** `Pythagorean/LorentzianCondNSD/Basic.lean` (condNegSemidef_dissipation, condNegSemidef_of_neg_laplacian).

**Proof Strategy:** (1) Establish Cheeger-type inequalities relating the log-Hessian spectral gap to combinatorial expansion of the matroid. (2) Use the product stability to bound the gap for product matroids. (3) Connect to the high-dimensional expander framework.

**Domain Bridges:** Matroid theory → spectral graph theory → Markov chain Monte Carlo.

**Lineage:** Extends the dissipation principle (Theorem in Basic.lean) to quantitative bounds.

**Ambition:** Solid extension — applies established tools to a concrete open problem.

---

## Direction 3: Lorentzian Information Geometry

**Conjecture:** The matrix −L_p defines a Riemannian metric on the simplex of exponential-family distributions parameterized by the all-ones point, and this metric is compatible with the Fisher information metric when p is the partition function of a log-linear model.

**Test:** Compute −L_p for parametric families of Lorentzian polynomials and compare with the Fisher information matrix. Check whether geodesic distances under −L_p satisfy triangle inequalities and Riemannian curvature bounds.

**The key insight is** that a conditionally negative semidefinite matrix defines a Hilbertian embedding (by the Schoenberg theorem): the distances d(i,j) = √(L_ii + L_jj − 2L_ij) embed the variables into a Hilbert space. For Lorentzian polynomials, this embedding reflects the "repulsion geometry" — variables that co-occur less frequently are further apart.

**Why now?** The CondNSD theory provides the first rigorous framework for defining this metric. Previous work on information geometry of exponential families did not connect to Lorentzian structure.

**Impact:** A new "Lorentzian information geometry" connecting polynomial combinatorics to statistical estimation theory.

**Catalog References:** `Pythagorean/LorentzianCondNSD/Basic.lean` (logHessianMatrix_quadForm, condNegSemidef_neg_hadamard_sq).

**Proof Strategy:** (1) Formalize the Schoenberg embedding theorem for CondNSD matrices. (2) Compute the Riemannian curvature of the −L_p metric. (3) Connect to the Fisher metric via exponential family theory.

**Domain Bridges:** Lorentzian polynomials (algebra) → information geometry (statistics) → optimal transport (analysis).

**Lineage:** Extends the log-Hessian quadratic form identity to a geometric framework.

**Ambition:** Grand challenge — would create a new field at the intersection of combinatorics and information theory.

---

## Direction 4: Algorithmic Diversity Certification for DPPs

**Conjecture:** For a DPP with PSD kernel K, the spectral gap of −L_{Z_K} on the zero-sum subspace is at least λ_min(M)² where M = K(I+K)⁻¹, and this bound is tight for diagonal kernels.

**Test:** Compute spectral gaps for random PSD kernels of varying spectral profiles, compare with λ_min(M)², and identify the extremal kernel structures.

**The key insight is** that the negative Hadamard square theorem (Theorem 7.2) gives a formula for the DPP log-Hessian: L = −(M∘M). The spectral gap of −(M∘M) on the zero-sum subspace can be bounded using the eigenvalues of M, providing a direct diversity certificate.

**Why now?** DPPs are increasingly used in production machine learning systems for recommendation and subset selection. Quantitative diversity guarantees — "how diverse is the selected subset?" — are needed for fairness and quality assurance but currently lack efficient certification methods.

**Impact:** Practical O(n³) diversity certification for DPP-based algorithms.

**Catalog References:** `Pythagorean/LorentzianCondNSD/Basic.lean` (condNegSemidef_neg_hadamard_sq, dppCov_offdiag_nonpos), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (dpp_partitionFunction_eval_ones, dpp_pairwise_negative_dependence).

**Proof Strategy:** (1) Relate the spectrum of M∘M to the spectrum of M using the Schur product theorem and interlacing. (2) Prove the λ_min(M)² lower bound. (3) Show tightness for diagonal M.

**Domain Bridges:** DPP theory (probability) → spectral certification (linear algebra) → algorithmic fairness (computer science).

**Lineage:** Directly extends Theorem 7.2 and the DPP connection in §8.

**Ambition:** Solid extension — applies proven tools to a practical open problem.

---

## Direction 5: Hodge–Riemann Relations as CondNSD Certificates

**Conjecture:** The Hodge–Riemann relations for the degree map of a matroid, as formulated by Adiprasito, Huh, and Katz, imply CondNSD of the log-Hessian of the reduced characteristic polynomial at the all-ones point.

**Test:** For matroids with known Hodge–Riemann structure (uniform matroids, Boolean matroids, partition matroids), verify that the Hodge–Riemann bilinear form on primitive cohomology restricts to give the CondNSD condition on the log-Hessian.

**The key insight is** that the Hodge–Riemann relations are a positivity condition on a bilinear form restricted to primitive cohomology — a subspace defined by an annihilation condition analogous to zero-sum. If the log-Hessian can be identified with the Hodge–Riemann form under an appropriate change of basis, then CondNSD follows from Hodge theory.

**Why now?** The Adiprasito–Huh–Katz proof of the Rota–Welsh conjecture established the Hodge–Riemann relations for all matroids. Connecting these to the concrete matrix-level CondNSD condition would make the deep positivity theorems of Hodge theory computationally accessible.

**Impact:** Would transform abstract Hodge-theoretic positivity into finite-dimensional spectral certificates, potentially yielding algorithmic applications of Hodge theory.

**Catalog References:** `Pythagorean/LorentzianCondNSD/Basic.lean` (condNegSemidef_fin2_iff, condNegSemidef_of_neg_laplacian), `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian).

**Proof Strategy:** (1) Identify the primitive cohomology with the zero-sum subspace via the degree map. (2) Express the Hodge–Riemann form in coordinates matching the log-Hessian. (3) Apply the Adiprasito–Huh–Katz theorem to conclude CondNSD.

**Domain Bridges:** Hodge theory (algebraic geometry) → spectral certification (linear algebra) → matroid theory (combinatorics).

**Lineage:** The ultimate synthesis of the Lorentzian and CondNSD programs.

**Ambition:** Grand challenge — would be a paradigm-shifting connection between Hodge theory and computational algebra.
