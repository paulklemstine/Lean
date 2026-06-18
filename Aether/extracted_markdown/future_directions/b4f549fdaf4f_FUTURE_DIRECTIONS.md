# Future Directions: Lorentzian Polynomials in Statistical Physics and Probability

## Synthesis

The results in this cycle establish a verified pipeline from PSD kernel matrices through DPP generating polynomials to negative dependence inequalities. The central objects — the partition function Z_K = det(I + diag(x)K), its spectral bridge Z_K(t,...,t) = det(I+tK), and the pairwise inequality det K_{ij} ≤ K_ii·K_jj — are now machine-verified. The next frontier is to close the gap between these algebraic results and the full Lorentzian polynomial theory of Brändén–Huh, and then to extend the framework to higher-order dependence, quantum systems, and algorithmic applications. The five directions below form a coherent research program: Direction 1 fills the main gap (real stability → Lorentzianity), Directions 2-3 extend the scope (higher-order dependence, matroids), Direction 4 bridges to quantum information, and Direction 5 develops the computational infrastructure for applications.

---

## Direction 1: Real Stability of Determinantal Polynomials and the Full Lorentzianity Bridge

**Conjecture**: For any symmetric PSD matrix K ∈ ℝ^{n×n}, the polynomial Z_K(x) = det(I + diag(x)K) is real stable (no zeros in the open upper half-plane ℍ^n). Combined with the Brändén–Huh theorem (real stable + nonneg coefficients ⟹ Lorentzian), this would prove our Lorentzianity conjecture.

**Test**: Formalize the following chain: (1) For z ∈ ℍ^n, the matrix I + diag(z)K has positive definite Hermitian part. (2) Positive definite matrices have nonzero determinant. (3) Therefore Z_K(z) ≠ 0 on ℍ^n. Each step can be verified by constructing the Hermitian part explicitly and using `PosDef.det_ne_zero`.

**Impact**: This completes the main theorem of the project — that DPP generating polynomials are Lorentzian — and unlocks the full cascade of Hodge-type inequalities for DPP coefficient arrays.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (IsBrandenHuhLorentzian definition and recursive spectral certificate equivalence).

**Proof Strategy**: Define real stability as a predicate on MvPolynomial. Prove that for PSD K and z ∈ ℍ^n, the matrix I + diag(z)K has positive definite Hermitian part (this requires formalizing Im(z_i·K_{ij}) terms). Then invoke `det_ne_zero` for positive definite matrices. The Brändén–Huh direction (stable → Lorentzian for homogeneous components with nonneg coefficients) requires formalizing the closure theorem, which is the main technical challenge.

**Domain Bridges**: Statistical physics (partition function stability) ↔ Algebraic geometry (Lorentzian/Hodge theory) ↔ Probability (negative association).

**The key insight is** that the positive semidefiniteness of K translates directly into the half-plane stability of the partition function, which in turn implies Lorentzianity — creating a clean algebraic pipeline from linear algebra to Hodge-theoretic geometry.

**Why now?** The Brändén–Huh theory is now mature (5+ years since publication), Mathlib has extensive matrix theory infrastructure, and our verified definitions provide the exact formalization targets.

**Lineage**: Extends `dpp_partition_function_lorentzian` (currently sorry'd) and builds on `dpp_uniformSpecialization` (verified).

**Ambition**: Grand challenge — completing this would be the first machine-verified proof that determinantal partition functions are Lorentzian.

---

## Direction 2: Higher-Order Negative Association for DPPs

**Conjecture**: DPPs satisfy the full **negative association** (NA) property: for any two increasing functions f, g on disjoint sets of coordinates, Cov(f(X_A), g(X_B)) ≤ 0. This is strictly stronger than pairwise negative dependence and has deeper implications for concentration inequalities.

**Test**: (1) Formalize the NA property as a predicate on probability measures. (2) Prove NA for product measures (diagonal DPPs). (3) Extend to rank-one DPPs. (4) Attempt the general case via the BBL (Borcea–Brändén–Liggett) theorem connecting real stability to NA.

**Impact**: Full NA unlocks Chernoff-type concentration bounds for DPP statistics, FKG-type correlation inequalities, and stochastic domination results.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian signature), `Pythagorean/DPPLorentzian.lean` (DPP definitions and pairwise result).

**Proof Strategy**: The BBL theorem states that strongly Rayleigh measures (whose generating polynomial is real stable) satisfy NA. If Direction 1 succeeds, DPPs are strongly Rayleigh, and NA follows. The key formalization challenge is the BBL proof itself, which uses multivariate analytic continuation arguments.

**Domain Bridges**: Probability theory (negative association) ↔ Statistical mechanics (FKG inequalities) ↔ Algorithms (concentration bounds for randomized algorithms).

**The key insight is** that negative association is not merely a statistical property but a geometric consequence of the polynomial's stability, which forces all monotone correlations to have the correct sign.

**Why now?** Our pairwise result provides the base case, and the BBL theorem provides the roadmap.

**Lineage**: Extends `dpp_pairwise_negative_dependence` (verified) to all monotone functions, not just indicator functions.

**Ambition**: Solid extension — the BBL theorem is well-understood mathematically, though formalizing multivariate analytic arguments is technically demanding.

---

## Direction 3: Matroid Exchange Property and Lorentzian Support Theory

**Conjecture**: The support of every homogeneous component of a DPP generating polynomial satisfies the symmetric exchange property (is a matroid basis set). This would connect DPP theory to matroid Hodge theory (Adiprasito–Huh–Katz).

**Test**: (1) For random PSD matrices with n ≤ 10, extract the support of each homogeneous component. (2) Verify the exchange axiom: for any two d-subsets S, T in the support and any i ∈ S\T, there exists j ∈ T\S such that (S − i + j) and (T + i − j) are both in the support. (3) Identify the matroid (it should be the uniform matroid for generic K).

**Impact**: This would provide a new source of matroids — one arising from spectral data — and connect the Lorentzian polynomial theory to the matroid Hodge theory that resolved the Rota–Heron–Welsh conjecture.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (SupportSatisfiesExchange definition).

**Proof Strategy**: For generic PSD K, all principal minors of size d are nonzero, so the support is the set of all d-subsets = uniform matroid. The interesting case is degenerate K (low rank), where the support becomes a proper matroid. The Brändén–Huh theorem guarantees the exchange property for Lorentzian polynomial supports.

**Domain Bridges**: Algebraic combinatorics (matroid theory) ↔ Algebraic geometry (Hodge theory) ↔ Probability (DPP support structure).

**The key insight is** that the matroid exchange property of Lorentzian polynomial supports is not an abstract axiom but a concrete structural property of DPP coefficient arrays, visible in the rank structure of the kernel matrix.

**Why now?** The SupportSatisfiesExchange predicate already exists in the catalog.

**Lineage**: Builds on `dpp_partition_function_lorentzian` (conjecture) and connects to matroid theory.

**Ambition**: Solid extension — the exchange property for Lorentzian supports is already proved by Brändén–Huh; the formalization connects it to DPPs.

---

## Direction 4: Quantum DPPs and Entanglement Bounds via Lorentzian Geometry

**Conjecture**: The von Neumann entropy of a fermionic Gaussian state is bounded by a function of the Lorentzian signature of its generating polynomial. Specifically, the number of positive Hessian eigenvalues at degree-2 derivative leaves of Z_K provides a lower bound on the entanglement entropy across bipartitions.

**Test**: (1) Compute the von Neumann entropy S(ρ) = −Tr(ρ log ρ) for the reduced density matrix of a fermionic Gaussian state with covariance K. (2) Compute the Lorentzian Hessian signatures at all derivative leaves. (3) Test whether min(S(ρ)) over bipartitions correlates with max(num_positive_eigenvalues) over Hessian leaves.

**Impact**: This would create a new bridge between quantum information theory and Lorentzian polynomial geometry, potentially yielding computable entanglement witnesses from polynomial coefficient data.

**Catalog References**: `Pythagorean/DPPLorentzian.lean` (DPP kernel and partition function definitions).

**Proof Strategy**: Fermionic Gaussian states have correlation matrices that are DPP kernels. The partition function Z_K encodes the full statistics of particle number measurements. The Lorentzian condition constrains the fluctuation structure, which should bound entanglement. The key technical step is relating the Hessian signature (a polynomial-geometric object) to the entanglement spectrum (a quantum-informatic object).

**Domain Bridges**: Quantum information theory (entanglement) ↔ Statistical mechanics (fermionic systems) ↔ Algebraic geometry (Lorentzian polynomials).

**The key insight is** that entanglement in fermionic systems is dual to the Lorentzian signature of the partition function — both measure the "width" of the probability distribution over subset sizes.

**Why now?** Quantum computing is driving demand for computable entanglement bounds, and the DPP–Lorentzian connection provides a new algebraic tool.

**Lineage**: Extends the DPP framework to quantum systems.

**Ambition**: Grand challenge — paradigm-shifting if successful, connecting quantum information to Hodge theory.

---

## Direction 5: Certified DPP Sampling with Lorentzian Guarantees

**Conjecture**: There exists a polynomial-time algorithm that, given a PSD kernel K and parameters ε, δ, produces a sample S from a distribution within ε total variation distance of the DPP, together with a machine-checkable certificate that the sample satisfies negative dependence up to additive error δ.

**Test**: (1) Implement an approximate DPP sampler based on eigendecomposition. (2) For each sample, compute the empirical correlation ratio and compare to the theoretical bound of 1. (3) Generate a Lorentzian certificate by checking the Hessian signature condition for the empirical distribution.

**Impact**: Certified sampling would enable DPPs to be used in safety-critical applications (medical trial design, autonomous systems) where diversity guarantees must be provably correct.

**Catalog References**: `Pythagorean/DPPLorentzian.lean` (negative dependence theorem, spectral bridge), `algorithms.py` (Hessian recognizer).

**Proof Strategy**: The sampling algorithm uses the spectral decomposition K = UΛU^T to sample in eigenspace, then projects. The certificate consists of: (1) the eigendecomposition (verifiable by matrix multiplication), (2) the Hessian signature check (verifiable by eigenvalue computation), (3) the correlation ratio bound (verifiable by arithmetic). Each certificate is machine-checkable in O(n³) time.

**Domain Bridges**: Algorithm design (certified computation) ↔ Machine learning (DPP sampling) ↔ Formal verification (proof certificates).

**The key insight is** that the Lorentzian structure provides not just existence proofs but computational certificates — the Hessian signature test is a concrete, checkable condition that implies the probabilistic guarantee.

**Why now?** Trustworthy AI demands certified algorithms, and DPPs are among the most widely used probabilistic models with certifiable properties.

**Lineage**: Extends `certify_pairwise_negative_dependence` (implemented in Python) to full sampling with Lorentzian certificates.

**Ambition**: Solid extension — builds directly on verified theorems and existing algorithms.
