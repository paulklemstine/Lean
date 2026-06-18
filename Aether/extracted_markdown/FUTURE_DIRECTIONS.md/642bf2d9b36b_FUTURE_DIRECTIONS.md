# Future Directions: Matroid Hodge Theory and DPP Support Exchange

## Synthesis

This research cycle established the formal connection between determinantal point processes (DPPs), matroid theory, and Lorentzian polynomial geometry. The central insight is that the support of a DPP kernel — the collection of subsets with positive principal minors — has the combinatorial structure of a matroid. This was verified through several complementary results: symmetric exchange for singleton symmetric differences, the Cauchy-Schwarz inequality for PSD entries, rank-1 kernel PSD-ness, and uniform matroid symmetric exchange.

The most promising cross-domain connection is the three-way bridge between probability (DPP negative dependence), combinatorics (matroid exchange), and algebraic geometry (Lorentzian polynomial curvature). Each domain provides tools that illuminate the others: PSD factorization gives the matroid structure, matroid theory gives the exchange property, and Lorentzian theory gives the curvature conditions that unify both. The Frobenius norm identity (total negative dependence = matrix norm) exemplifies how probabilistic and algebraic perspectives converge.

The highest breakthrough potential lies in Direction 1 (Cholesky Matroid Formalization), which would complete the proof that DPP supports are exactly linear matroid bases. This requires formalizing Cholesky decomposition in Lean/Mathlib, which would be independently valuable infrastructure. Direction 2 (Lorentzian DPP Components) builds on `Speculative/AutoResearch/DPPLorentzian.lean` and would connect to the Fields Medal-winning work of Brändén-Huh. Direction 3 (Greedy Matroid Algorithms) would bring the theoretical results to bear on practical optimization.

---

### Direction 1: Cholesky Matroid Formalization

**Conjecture**: For a PSD matrix K of rank r with Cholesky factorization K = BᵀB, the DPP support of size d (subsets S with det(K_S) > 0) equals the collection of d-element subsets whose corresponding columns of B are linearly independent. This collection is precisely the bases of the linear matroid of B.

**Test**: Formalize Cholesky decomposition for PSD matrices in Lean, then prove that det(K_S) > 0 iff the columns of B indexed by S are linearly independent. The key step is showing det(K_S) = det(BᵀB)_S = det(B_S^ᵀ B_S) = det(B_S)² ≥ 0, with equality iff B_S has linearly dependent columns.

**Impact**: Would complete the proof that DPP supports are matroids, resolving the main conjecture of this cycle. Would also provide Cholesky decomposition infrastructure for Lean/Mathlib, which is currently missing and widely needed.

**Catalog References**: `Speculative/AutoResearch/DPPLorentzian.lean` (DPP kernel definitions), `Pythagorean/MatroidHodgeDPP.lean` (FinsetMatroid definition, DPPSupport definition), `Pythagorean/HigherOrderMinorPerturbation.lean` (principal minor perturbation theory).

**Proof Strategy**:
1. Formalize Cholesky decomposition: every PSD matrix K has K = BᵀB for some B ∈ ℝ^{r×n}.
2. Prove det(K_S) = det(B_S^ᵀ B_S) using the Cauchy-Binet formula.
3. Prove det(B_S^ᵀ B_S) > 0 iff rank(B_S) = |S| (i.e., columns of B indexed by S are linearly independent).
4. Show linear independence sets satisfy the exchange property via the Steinitz exchange lemma (already in Mathlib).

**Domain Bridges**: Linear Algebra ↔ Matroid Theory ↔ Probability

**Lineage**: Directly extends `FinsetMatroid` definition and `DPPSupport` from this cycle. Builds on `psd_submatrix_psd` and `psd_all_principal_minors_nonneg`.

**Ambition**: grand_challenge — Requires significant new Mathlib infrastructure (Cholesky decomposition).

---

### Direction 2: Lorentzian DPP Components

**Conjecture**: For a symmetric PSD kernel K, every homogeneous component of the DPP partition function Z_K(x) = det(I + diag(x)·K) is a Lorentzian polynomial in the sense of Brändén-Huh. Specifically, all degree-2 iterated derivative leaves have Hessian with at most one positive eigenvalue.

**Test**: For small n (n = 3, 4), compute the degree-d homogeneous components of det(I + diag(x)·K) for random PSD K. For each degree-2 leaf, compute the Hessian eigenvalues and verify at most one is positive. A single leaf with two positive eigenvalues would disprove the conjecture.

**Impact**: Would formally establish DPP generating polynomials as Lorentzian, connecting DPP theory to the Brändén-Huh framework. Combined with Direction 1, would give a complete Hodge-theoretic characterization of DPP polynomials.

**Catalog References**: `Speculative/AutoResearch/DPPLorentzian.lean` (IsDPPLorentzian definition, dpp_partition_function_lorentzian conjecture), `Pythagorean/LorentzianRecognitionComplete.lean` (IsBrandenHuhLorentzian definition, HasAtMostOnePositiveEigenvalue).

**Proof Strategy**:
1. Show det(I + diag(x)·K) is real stable when K is PSD (this is a known result, requires formalization of real stability).
2. Apply the Brändén-Huh theorem: stable polynomials with nonnegative coefficients are Lorentzian.
3. Show homogeneous components of Lorentzian polynomials are Lorentzian (closure under homogeneous projection).

**Domain Bridges**: Algebraic Geometry ↔ Probability ↔ Spectral Theory

**Lineage**: Extends `dpp_partition_function_lorentzian` conjecture from `DPPLorentzian.lean`. Uses `recursivelyLorentzian_iff_brandenHuh` from `LorentzianRecognitionComplete.lean`.

**Ambition**: grand_challenge — Requires formalizing real stability theory, which is a substantial undertaking.

---

### Direction 3: Greedy Matroid Optimization

**Conjecture**: The greedy algorithm for maximizing a monotone submodular function subject to a matroid constraint achieves a 1/2-approximation ratio. When the matroid is the DPP support matroid, this gives certified diverse subset selection.

**Test**: Implement the greedy algorithm for DPP-based sensor placement with matroid constraint. Compare greedy solution value to the optimal (found by exhaustive search for small n) and verify the 1/2-approximation bound holds.

**Impact**: Would formalize the algorithmic consequence of the matroid structure of DPP supports. Would establish that practical DPP-based selection algorithms have provable guarantees, not just empirical performance.

**Catalog References**: `Pythagorean/MatroidHodgeDPP.lean` (FinsetMatroid, matroidRankFn_mono, matroidRankFn_le_card), `Computation/InfoEfficientAlgorithms.lean` (algorithmic framework).

**Proof Strategy**:
1. Formalize the greedy algorithm: iteratively add the element maximizing marginal gain while maintaining matroid feasibility.
2. Prove the exchange argument: for any basis B* of the optimal and the greedy basis B_G, use the exchange property to bound the approximation ratio.
3. Apply to DPPSupport to get concrete guarantees for DPP-based selection.

**Domain Bridges**: Combinatorial Optimization ↔ Matroid Theory ↔ Machine Learning

**Lineage**: Builds on `FinsetMatroid.exchange` and `matroidRankFn_mono` from this cycle.

**Ambition**: extension — The proof technique is classical (Edmonds/Rado); the novelty is the connection to DPP applications.

---

### Direction 4: Matroid Polytope and Ehrhart Theory

**Conjecture**: The matroid polytope of the DPP support matroid (the convex hull of characteristic vectors of bases) is a generalized permutohedron, and its Ehrhart series has nonneg h*-vector.

**Test**: For DPP supports computed from random PSD matrices (n = 5, 6), compute the matroid polytope vertices and verify that their convex hull is a generalized permutohedron (i.e., each edge is parallel to eᵢ - eⱼ for some i, j).

**Impact**: Would connect DPP matroid structure to the Ehrhart theory developed in `Pythagorean/LorentzianPermutohedra/EhrhartSeries.lean`, creating a new bridge between DPP probability and polyhedral combinatorics.

**Catalog References**: `Pythagorean/LorentzianPermutohedra/EhrhartSeries.lean` (Ehrhart count, h*-vector, lorentzian_support_nonempty_exchange), `Pythagorean/MatroidHodgeDPP.lean` (DPPSupport, FinsetMatroid).

**Proof Strategy**:
1. Show that DPP support matroid bases, when represented as 0-1 vectors, have convex hull with edges ∥ eᵢ - eⱼ (this follows from the exchange property).
2. Apply the IDP (integer decomposition property) theorem from `EhrhartIDP.lean` to the resulting polytope.
3. Conclude h*-nonnegativity from the IDP + Stanley's theorem.

**Domain Bridges**: Polyhedral Combinatorics ↔ Matroid Theory ↔ Probability

**Lineage**: Extends `lorentzian_support_nonempty_exchange` and `ehrhartCount_monotone_of_nonempty` from `EhrhartSeries.lean`. Connects to `FinsetMatroid` from this cycle.

**Ambition**: extension — Connects two existing formalizations through DPP matroid structure.

---

### Direction 5: Negative Dependence and Log-Concavity

**Conjecture**: The basis-generating polynomial of the DPP support matroid, f(t) = Σ_{B ∈ bases} t^{|B|}, has log-concave coefficients. Equivalently, if aₖ is the number of bases of size k, then aₖ² ≥ aₖ₋₁ · aₖ₊₁ for all k.

**Test**: For DPP supports from random PSD matrices, compute the sequence (a₀, a₁, ..., aₙ) and verify log-concavity. Note: for DPP supports, all bases have the same size d, so the generating polynomial is just aₐ · tᵈ, which is trivially log-concave. The non-trivial version: consider the *independent set generating polynomial* (not just bases), which counts all independent sets by size.

**Impact**: Would connect the DPP matroid structure to the Mason conjecture (now theorem, proved by Adiprasito-Huh-Katz using Lorentzian polynomials). Would establish that DPP independence numbers satisfy the strongest possible log-concavity.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` (IsBrandenHuhLorentzian, quadratic leaves), `Speculative/AutoResearch/DPPLorentzian.lean` (DPP generating polynomial).

**Proof Strategy**:
1. Define the independent set generating polynomial for DPP support matroids.
2. Show this equals a specialization of the DPP partition function.
3. Apply the Brändén-Huh characterization: Lorentzian polynomials have log-concave specializations.

**Domain Bridges**: Algebraic Combinatorics ↔ Probability ↔ Hodge Theory

**Lineage**: Extends the Lorentzian framework from `LorentzianRecognitionComplete.lean` and the DPP definitions from `DPPLorentzian.lean`.

**Ambition**: extension — Specializes known deep results to the DPP setting.
