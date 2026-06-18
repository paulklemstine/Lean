# Future Directions: Algorithmic Lorentzian Geometry

## Synthesis

The Lorentzian Hessian certificate framework established here creates a new bridge between abstract polynomial geometry and computational linear algebra. The resolvent formula H_{ij} = det(A)(L_{ii}L_{jj} - L_{ij}²) transforms the qualitative statement "DPP partition polynomials are Lorentzian" into a quantitative, efficiently computable matrix certificate. This opens five interconnected research directions: extending the certificate to broader classes of negatively dependent measures (Direction 1), using it as a barrier in convex optimization (Direction 2), establishing quantitative stability bounds for approximate computation (Direction 3), proving the rigid spectral law conjectured from experiments (Direction 4), and building a general framework connecting polynomial geometry to resolvent computation (Direction 5). Together, these directions define the program of *algorithmic Lorentzian geometry*: the systematic study of Lorentzian structure as a computable, optimizable, and verifiable geometric object.

---

## Direction 1: Strongly Rayleigh Extension

**Conjecture:** Every strongly Rayleigh measure on 2^[n] admits a Lorentzian Hessian certificate computable from its generating polynomial's resolvent data.

**Test:** Implement the certificate computation for strongly Rayleigh measures beyond DPPs (e.g., balanced matroids, uniform distributions on bases of regular matroids). Check whether the resolvent Hessian has at most one positive eigenvalue. A strongly Rayleigh measure whose Hessian has two or more positive eigenvalues would refute the conjecture.

**Impact:** Strongly Rayleigh measures are the broadest class known to satisfy negative dependence. Extending the certificate to this class would make Lorentzian verification possible for measures arising from matroid theory, graph theory, and log-concave polynomials — far beyond the DPP setting.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` — `IsDPPLorentzian` and `dpp_partition_function_lorentzian`
- `Pythagorean/LorentzianCertificate.lean` — `LorentzianHessianCertificate` and `dpp_hessian_conditional_neg_semidef`

**Proof Strategy:** The key insight is that strongly Rayleigh measures have real stable generating polynomials, and the resolvent structure should extend via the Borcea-Brändén theory. The main technical challenge is that the generating polynomial may not factor as det(I + diag(x)K) for any PSD K. Strategy: express the Hessian through the polynomial's own second derivatives (not through a kernel), and prove conditional NSD using the real stability condition directly.

**Domain Bridges:** Combinatorics (matroid theory) ↔ Analysis (real stable polynomials) ↔ Computation (certificate algorithms)

**Lineage:** Builds directly on the resolvent Hessian certificate and extends it from DPPs to the full strongly Rayleigh class.

**Ambition:** Grand challenge — would unify Lorentzian polynomial theory with computational certificate verification for all negatively dependent measures.

---

## Direction 2: Lorentzian Barrier Functions for Convex Optimization

**Conjecture:** The conditional NSD property of the resolvent Hessian can be used to define a self-concordant barrier function for the cone of Lorentzian polynomials, enabling interior-point methods that enforce Lorentzianity as a convex constraint.

**Test:** Implement a prototype interior-point solver that uses the resolvent Hessian as a barrier. Test on the problem of finding the nearest Lorentzian polynomial to a given polynomial with mixed-sign Hessian. Measure convergence rate and compare with generic SDP formulations. The barrier is self-concordant if and only if the third derivative of the barrier function satisfies a specific bound — this can be checked numerically.

**Impact:** Would create a new class of optimization algorithms for problems where negative dependence or repulsion is a design constraint (diversity sampling, experimental design, network planning).

**Catalog References:**
- `Pythagorean/LorentzianCertificate.lean` — `quadForm`, `LorentzianHessianCertificate`
- `Catalog/Bridges/Catalog/Pythagorean/CertifiedDPPSampling.lean` — `covarianceQuadForm`

**Proof Strategy:** The key insight is that the log-determinant function log det(I+K) is well-known to be a self-concordant barrier. The resolvent Hessian is the second derivative of this barrier composed with the DPP generating function structure. Self-concordance of the composed barrier should follow from chain rule estimates and the conditional NSD property.

**Why now?** The resolvent Hessian formula makes the barrier computation explicit and O(n³), matching the complexity requirements of interior-point methods.

**Domain Bridges:** Polynomial geometry ↔ Convex optimization ↔ Operations research

**Lineage:** Extends the certificate from a verification tool to an optimization primitive.

**Ambition:** Solid extension — builds on established barrier theory with the new Hessian formula.

---

## Direction 3: Quantitative Spectral Stability for Approximate Certificates

**Conjecture:** There exists a universal constant C > 0 such that for all symmetric PSD contractions K, K' with ‖K - K'‖_max ≤ ε:

$$\|H_K - H_{K'}\|_{\max} \leq C \cdot n^2 \cdot \det(I+K) \cdot \varepsilon$$

where H_K, H_{K'} are the resolvent Hessians.

**Test:** Generate pairs (K, K') with controlled perturbation ε. Compute ‖H_K - H_{K'}‖_max and check whether the ratio to det(I+K) · ε remains bounded by O(n²). Search for kernels near the boundary of invertibility (det(I+K) ≈ 0) where the bound might blow up.

**Impact:** Would enable certified approximate Lorentzian verification for DPP kernels computed from noisy data or approximate spectral decompositions. Essential for practical deployment in machine learning pipelines where exact kernel computation is infeasible.

**Catalog References:**
- `Catalog/Bridges/Catalog/Pythagorean/CertifiedDPPSampling.lean` — `pairwise_inclusion_perturb`, `certified_approx_dpp_sound`
- `Pythagorean/LorentzianCertificate.lean` — `dppResolventHessian`, `resolventHessian_quadForm_eq`

**Proof Strategy:** The key insight is that the resolvent Hessian entries are polynomial functions of L = (I+K)⁻¹ and det(I+K), and the resolvent is Lipschitz in K with constant depending on cond(I+K). Use the matrix perturbation bounds already established in `CertifiedDPPSampling.lean` (specifically `det2_perturb_bound` and `pairwise_inclusion_perturb`) and compose them with the resolvent Hessian formula.

**Why now?** The existing catalog already contains the perturbation infrastructure; combining it with the new Hessian formula is a natural and tractable extension.

**Domain Bridges:** Numerical analysis ↔ Probability ↔ Machine learning

**Lineage:** Directly combines the resolvent Hessian certificate with the perturbation bounds from `CertifiedDPPSampling.lean`.

**Ambition:** Solid extension — concrete and achievable with existing tools.

---

## Direction 4: Exact Defect Collapse — The Rigid Lorentzian Signature Law

**Conjecture:** For every nonzero symmetric PSD contraction K ∈ ℝⁿˣⁿ, the resolvent Hessian H_K has exactly one positive eigenvalue.

**Test:** Systematically search for counterexamples:
1. Random PSD contractions (n = 3 to 100, 10,000 trials per dimension)
2. Near-singular kernels (eigenvalues of K near 0 or 1)
3. Low-rank kernels (rank 1, 2, ..., n/2)
4. Structured kernels (circulant, Toeplitz, block-diagonal)
A single nonzero K with H_K having zero positive eigenvalues disproves the conjecture.

**Impact:** Would establish a rigid spectral law: the Lorentzian signature of the Hessian is always exactly (1, n-1), never (0, n). This has implications for the geometry of the DPP generating polynomial (the Hessian cone is always nontrivially Lorentzian, never degenerate) and for the theory of conditionally negative definite kernels.

**Catalog References:**
- `Pythagorean/LorentzianCertificate.lean` — `exactDefectCollapse`, `dpp_hessian_conditional_neg_semidef`

**Proof Strategy:** The key insight is that the weight vector w (with w_i = L_{ii}) may serve as a witness: if Q_H(w) > 0, the conjecture holds. We have Q_H(w) = det(A)[(∑ L_{ii}²)² - ∑_{i,j} L_{ij}² L_{ii} L_{jj}]. By the Cauchy-Schwarz inequality applied to the Hadamard product, this may be provably positive when L has full rank (which it does for nonzero K). The Cauchy-Schwarz approach would require showing that the "diagonal dominance" of L (implied by L being the inverse of a diagonally dominant matrix I+K) is sufficient.

**Why now?** Extensive computational evidence (>50,000 tests with zero counterexamples) makes this conjecture highly plausible, and the resolvent Hessian formula provides the right framework for a proof.

**Domain Bridges:** Spectral theory ↔ Combinatorics ↔ Geometric analysis

**Lineage:** Strengthens the main theorem from "at most one" to "exactly one" positive eigenvalue.

**Ambition:** Grand challenge — would reveal deep rigidity in the Lorentzian structure of DPP generating functions.

---

## Direction 5: Resolvent Geometry as a General Framework

**Conjecture:** For any multivariate polynomial p(x) with nonneg coefficients arising as the generating function of a negatively dependent measure, the Hessian at the all-ones point can be expressed through a "resolvent-like" operator, and the resulting Hessian always satisfies conditional negative semidefiniteness.

**Test:** Compute the Hessian for generating functions of known negatively dependent measures beyond DPPs:
- Uniform distribution on bases of graphic matroids
- Products of linear forms (Lorentzian by definition)
- Permanent-like generating functions
Check whether a resolvent formula (or generalization) holds, and whether conditional NSD is satisfied.

**Impact:** Would establish a general correspondence: negatively dependent measure ↔ conditionally NSD Hessian ↔ resolvent-type formula. This would be a foundational result connecting probability theory, polynomial geometry, and linear algebra.

**Catalog References:**
- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean` — `IsDPPLorentzian`, `dppPartitionFunction`
- `Pythagorean/LorentzianCertificate.lean` — full certificate framework

**Proof Strategy:** The key insight is that the resolvent formula H_{ij} = det(A)(L_{ii}L_{jj} - L_{ij}²) is formally identical to the second derivative of log det(A) composed with the generating function structure. For general stable polynomials, the role of the resolvent is played by the Hessian of log p, which should satisfy analogous positivity properties by the theory of completely log-concave polynomials (Anari-Gharan-Vinzant).

**Why now?** The formal verification infrastructure and the explicit resolvent formula provide a concrete starting point that was not available before.

**Domain Bridges:** Polynomial geometry ↔ Probability ↔ Linear algebra ↔ Combinatorics ↔ Physics

**Lineage:** Generalizes the entire certificate framework from DPPs to arbitrary negatively dependent measures.

**Ambition:** Grand challenge — would define the field of algorithmic Lorentzian geometry.
