# Future Directions

## Synthesis

This research cycle established a formal bridge between Lorentzian polynomial structure (algebraic geometry) and higher-order log-concavity (discrete analysis). The central discovery is that the k-fold log-concavity hierarchy has a clean multiplicative structure: the Hadamard product of two k-fold log-concave sequences is k-fold log-concave, and this depth is stable under geometric tilting. These results provide the first rigorous mechanism for translating between the algebraic characterization of Lorentzian polynomials (Hessian eigenvalue conditions) and the combinatorial structure of their coefficient sequences (iterated ratio inequalities).

The most promising cross-domain connection is between the Hadamard stability theorem and the partition function factorization principle in statistical mechanics. The existing Catalog contains infrastructure for both Lorentzian recognition (`Catalog/Pythagorean/LorentzianRecognitionComplete.lean`) and higher-order log-concavity (`Catalog/Pythagorean/HigherOrderLogConcavity.lean`), and our bridge file (`Catalog/Pythagorean/LorentzianLogConcavityBridge.lean`) provides the connecting tissue. The log-concavity signature structure enables compositional reasoning about certified depth, which could feed into the spectral certification algorithms from `LorentzianRecognitionComplete.lean`.

The highest breakthrough potential lies in Direction 1 (Strong Depth Additivity), because proving that the Hadamard product is depth-additive (rather than merely depth-preserving) would imply a sharp characterization of which coefficient sequences arise from products of Lorentzian polynomials. This would connect the multiplicative structure of the k-fold hierarchy to the geometry of the Lorentzian cone, potentially yielding new log-concavity proofs for open conjectures about graph polynomials.

---

### Direction 1: Strong Depth Additivity under Hadamard Product

**Conjecture**: For positive sequences a, b with k-fold log-concavity depths d₁ = depth(a) and d₂ = depth(b), the Hadamard product a·b satisfies depth(a·b) ≥ d₁ + d₂. That is, if KFoldLC d₁ a and KFoldLC d₂ b (and these are the maximal depths), then KFoldLC (d₁ + d₂) (fun n => a n * b n).

**Test**: Take a(n) = C(3,n) (coefficients of (1+x)³, depth = 1 because ratios 3, 1, 1/3 form a geometric-like sequence). Take b(n) = n+1 (depth = 1). Compute a·b = (1, 4, 6, 4) restricted. Check whether the depth of a·b is ≥ 2 by computing iterated ratio sequences and verifying log-concavity at depth 2. If depth(a·b) = 1, the conjecture is false.

**Impact**: If true, this would give a sharp lower bound on the depth of partition functions of composed systems and could be used to construct sequences of arbitrarily high depth by iterated Hadamard products. If false, the counterexample would reveal fundamental constraints on how algebraic structure accumulates under multiplication.

**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave, KFoldLogConcave.mul), `Catalog/Pythagorean/LorentzianLogConcavityBridge.lean` (hadamard_preserves_kfold, LogConcavitySignature)

**Proof Strategy**: The key step would be to show that the ratio sequence of a·b has depth ≥ d₁ + d₂ - 1. Using ratio(a·b) = ratio(a)·ratio(b), this reduces to showing depth(ratio(a)·ratio(b)) ≥ (d₁-1) + (d₂-1) = d₁+d₂-2. Apply induction. The base case requires showing that the product of a (d₁-1)-fold and a (d₂-1)-fold LC sequence has depth ≥ d₁+d₂-2. This is exactly the inductive hypothesis.

**Domain Bridges**: Algebra <-> Combinatorics, Statistical Mechanics <-> Discrete Analysis

**Lineage**: Builds on hadamard_preserves_kfold (this cycle) and KFoldLogConcave.mul from HigherOrderLogConcavity.lean

**Ambition**: grand_challenge

---

### Direction 2: Convolution Preservation of K-Fold Log-Concavity

**Conjecture**: The discrete convolution (Cauchy product) of two k-fold log-concave finite sequences is k-fold log-concave. Specifically, if a is supported on [0,d₁] and b on [0,d₂], both positive and k-fold log-concave, then c(n) = Σᵢ a(i)·b(n-i) is k-fold log-concave on [0, d₁+d₂].

**Test**: Take a = (1,2,1) (binomial C(2,·), 1-fold LC) and b = (1,3,3,1) (binomial C(3,·), 1-fold LC). Compute c = (1,5,10,10,5,1) = C(5,·). Check that c is 1-fold LC and compute its depth. Since C(5,·) is known to be at least 1-fold LC, this provides a positive test case.

**Impact**: Convolution corresponds to the product of polynomials. If convolution preserves k-fold LC, it would provide an algebraic proof technique: express a generating polynomial as a product of simpler factors, establish k-fold LC for each factor, and conclude k-fold LC for the product.

**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave), `Catalog/Pythagorean/LorentzianBivariateSpecialization.lean` (BivariateCoeffSeq, LogConcaveOn)

**Proof Strategy**: The classical proof of log-concavity preservation under convolution uses the FKG inequality or the theory of Pólya frequency functions. For k-fold, one would need to show that the ratio sequence of a convolution can be expressed in terms of the ratio sequences of the factors. This requires establishing a "convolution ratio decomposition" lemma. Alternatively, use the fact that convolution corresponds to polynomial multiplication and that the product of Lorentzian polynomials in disjoint variable sets is Lorentzian.

**Domain Bridges**: Algebra <-> Probability Theory, Combinatorics <-> Statistical Mechanics

**Lineage**: Builds on the log-concavity preservation results of this cycle and the ultra-log-concavity theory from LorentzianBivariateSpecialization.lean

**Ambition**: grand_challenge

---

### Direction 3: Spectral Characterization of K-Fold Depth

**Conjecture**: For a homogeneous polynomial P of degree d with nonneg coefficients, the k-fold log-concavity depth of its bivariate specialization equals the minimal number of "Lorentzian layers" in a recursive decomposition of P. More precisely, define the Lorentzian depth of P as the maximum k such that all (d-2)-fold iterated partial derivatives of P have Hessians with at most k "positive eigenvalue layers." Then depth(P) = k-fold depth of the bivariate specialization coefficients.

**Test**: Compute the bivariate specialization of P(x,y,z) = x²y + xy² + x²z + xz² + y²z + yz² (the degree-3 symmetric polynomial). Check the k-fold depth of the resulting sequence and compare with the eigenvalue structure of the Hessian of P.

**Impact**: This would provide a complete dictionary between the algebraic (Hessian eigenvalue) and combinatorial (ratio sequence) perspectives on Lorentzian polynomials, extending the bridge from log-concavity to the full hierarchy.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (HasAtMostOnePositiveEigenvalue, IsRecursivelyLorentzian), `Catalog/Pythagorean/LorentzianLogConcavityBridge.lean` (KFoldLC, LogConcavitySignature)

**Proof Strategy**: Start by establishing the conjecture for degree-2 polynomials, where the Hessian is a 2×2 matrix and the eigenvalue structure is explicit. Then use the recursive structure of the Lorentzian predicate (each differentiation reduces degree by 1) to prove by induction on degree. The key lemma is: differentiation of P corresponds to taking the ratio sequence of the bivariate specialization.

**Domain Bridges**: Algebraic Geometry <-> Discrete Analysis, Spectral Theory <-> Combinatorics

**Lineage**: Builds on recursive_certificate_equiv_spectral_check from LorentzianRecognitionComplete.lean and the k-fold hierarchy from this cycle

**Ambition**: extension

---

### Direction 4: Tropical Geometry of the Log-Concavity Hierarchy

**Conjecture**: The k-fold log-concavity depth of a sequence a(0),...,a(d) equals the number of "bends" in the tropical curve of the associated polynomial Σ a(m)·x^m in the tropical semiring (ℝ ∪ {-∞}, max, +). Specifically, the Newton polygon of log(a(m)) has exactly k maximal concave regions if and only if the sequence has k-fold depth exactly k.

**Test**: For the sequence a = (1, 4, 6, 4, 1) (binomial C(4,·)), compute log(a) = (0, 1.39, 1.79, 1.39, 0). The Newton polygon of these values is concave (one concave arc), predicting depth ≥ 1. Verify computationally.

**Impact**: This would connect the log-concavity hierarchy to tropical geometry, opening a new avenue for proving log-concavity results using polyhedral methods. The Catalog already contains tropical geometry infrastructure in `Catalog/Tropical/`.

**Catalog References**: `Catalog/Pythagorean/TropicalLorentzianShadows.lean`, `Catalog/Tropical/` (tropical semiring definitions)

**Proof Strategy**: Define the tropical Newton polygon operator and show it commutes with the ratio sequence operator. Use the fact that taking ratios of a sequence corresponds to taking differences of the logs, and log-concavity of ratios corresponds to concavity of the second difference sequence. The tropical connection then follows from the piecewise-linear structure of tropical curves.

**Domain Bridges**: Tropical Geometry <-> Discrete Analysis, Algebraic Geometry <-> Combinatorics

**Lineage**: Builds on TropicalLorentzianShadows.lean from the Catalog and the k-fold hierarchy from this cycle

**Ambition**: extension

---

### Direction 5: Phase Transition Detection via Log-Concavity Depth

**Conjecture**: For the Ising model partition function Z_n(β) = Σ_k a_k(n)·e^{-β·k} on a graph with n vertices, the k-fold log-concavity depth of the energy level degeneracy sequence {a_k(n)} undergoes a discrete jump at the critical temperature β_c. Specifically, the depth is finite for β < β_c and infinite (i.e., the sequence becomes "geometric-like") at β = β_c.

**Test**: Compute the partition function for the Ising model on the complete graph K_n for n = 4, 6, 8 at various temperatures. Extract the energy level degeneracies and compute their k-fold depth. Look for a temperature at which the depth increases sharply.

**Impact**: This would provide a new, purely combinatorial characterization of phase transitions, complementing the thermodynamic (singularity of free energy) and information-theoretic (divergence of mutual information) characterizations. It could lead to efficient algorithms for detecting phase transitions via log-concavity depth computation.

**Catalog References**: `Catalog/Pythagorean/CertificateSampling.lean` (partition function infrastructure), `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (KFoldLogConcave)

**Proof Strategy**: For the complete graph, the partition function can be computed exactly using the eigenvalues of the adjacency matrix. Show that at β_c, the dominant contribution to the degeneracy sequence becomes a geometric progression (from the ground state and first excited state), forcing infinite depth. Below β_c, the contributions are non-geometric, giving finite depth.

**Domain Bridges**: Statistical Mechanics <-> Combinatorics, Phase Transitions <-> Algebraic Structure

**Lineage**: Builds on the Hadamard stability theorem (this cycle) and the partition function infrastructure in CertificateSampling.lean

**Ambition**: grand_challenge
