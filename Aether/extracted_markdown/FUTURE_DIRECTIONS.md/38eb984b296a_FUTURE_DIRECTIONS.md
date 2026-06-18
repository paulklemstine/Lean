# Future Research Directions: Tropical Linear Algebra

## Synthesis

This research cycle established a rigorous foundation for tropical (max-plus) linear algebra, proving the determinant-permanent identity, super-multiplicativity of the tropical determinant, associativity and distributivity of tropical matrix operations, and basic spectral properties (diagonal superadditivity, cycle mean bounds, translation invariance). The key structural insight is that the tropical semiring's lack of additive inverses causes the sign structure of permutations to collapse, making the determinant and permanent identical — with profound implications for computational complexity.

The most promising cross-domain connection is the **bridge between tropical algebra and combinatorial optimization**: the tropical determinant IS the assignment problem, and super-multiplicativity provides algebraic certificates for optimization bounds. This connects to the Catalog's existing work on tropical Perron-Frobenius (`Catalog/Tropical/PerronFrobenius.lean`), tropical cryptography (`Catalog/Cryptography/`), and the tropical Satake isomorphism (`Catalog/Tropical/SatakeGLn.lean`). The diagonal superadditivity theorem, in particular, is the engine behind both the convergence proof in Perron-Frobenius and Karp's algorithm for maximum cycle mean — unifying algebraic and algorithmic perspectives.

The direction with highest breakthrough potential is **tropical Cayley-Hamilton**: formalizing the tropical characteristic polynomial and proving that every matrix satisfies it would be a landmark result connecting tropical algebra to tropical algebraic geometry, with applications to control theory and discrete event systems.

---

### Direction 1: Tropical Cayley-Hamilton Theorem

**Conjecture**: For an (n+1)×(n+1) matrix A over the max-plus semiring, define the tropical characteristic polynomial as χ_A(λ) = tropDet(λI ⊕ A), where λI is the matrix with λ on the diagonal and -∞ off-diagonal. Then A satisfies its tropical characteristic polynomial in the sense that:
```
tropPow' A n ⊕ c_{n-1} ⊗ tropPow' A (n-1) ⊕ ... ⊕ c₀ ⊗ I ≤ tropPow' A n
```
where the c_i are the coefficients of χ_A (tropical elementary symmetric functions of the eigenvalues).

**Test**: First verify computationally for 2×2 and 3×3 matrices using `#eval` in Lean. Then attempt the general proof by induction on matrix size, using the cofactor expansion of the tropical determinant.

**Impact**: If true, this provides a tropical analog of one of the most fundamental theorems in linear algebra. It would give algebraic certificates for the cycle time of discrete event systems and connect tropical matrix algebra to tropical algebraic geometry (where tropical polynomials define tropical varieties).

**Catalog References**: `Catalog/Tropical/PerronFrobenius.lean` (tropPow, maxCycleMean), `Catalog/Tropical/Matrix/Defs.lean` (tropMatMul, tropTrace)

**Proof Strategy**: Define tropical elementary symmetric functions e_k(A) as the maximum weight over all k-element subsets of a permutation. Show that the tropical characteristic polynomial's coefficients are these symmetric functions. Then prove the Cayley-Hamilton inequality using the inclusion-exclusion principle tropicalized (which becomes a max-min alternation).

**Domain Bridges**: Tropical algebra ↔ Combinatorial optimization (the coefficients e_k are k-assignment values), Tropical algebra ↔ Control theory (the Cayley-Hamilton inequality bounds the transient behavior of max-plus linear systems)

**Lineage**: Builds on this cycle's tropDet, tropPow'_add, tropPow'_diag_superadd.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Rank Theory and Separation

**Conjecture**: The Barvinok rank (minimum number of rank-1 tropical matrices whose max equals A) and the Kapranov rank (minimum classical rank over all lifts) differ for generic 3×3 matrices. Specifically, there exists a 3×3 tropical matrix with Barvinok rank 2 and Kapranov rank 3.

**Test**: Construct an explicit 3×3 matrix A where:
(a) A = max(u₁ ⊗ v₁ᵀ, u₂ ⊗ v₂ᵀ) for some vectors u₁, v₁, u₂, v₂ (Barvinok rank ≤ 2)
(b) For any classical matrix M with trop(M) = A, rank(M) ≥ 3

Verify (a) computationally. For (b), use the fact that 3×3 matrices with all 2×2 tropical minors achieving their maximum must have classical rank 3.

**Impact**: If true, this proves that different notions of tropical rank are genuinely distinct, settling a question in tropical geometry. If false for 3×3, characterize the smallest dimension where separation occurs.

**Catalog References**: `Catalog/Tropical/Matrix/Defs.lean`, `Catalog/Tropical/FactorRank.lean`, `Catalog/Tropical/RankGrowth.lean`

**Proof Strategy**: Use the Develin-Santos-Sturmfels classification of tropical rank for small matrices. Formalize the rank-1 tropical matrix (outer max-plus product) and prove basic properties. Then construct the separating example and verify both rank conditions.

**Domain Bridges**: Tropical algebra ↔ Algebraic geometry (Kapranov rank connects to initial ideals), Tropical algebra ↔ Statistics (nonneg matrix factorization is a classical analog)

**Lineage**: Builds on this cycle's tropDet (which computes the tropical "full rank" indicator) and tropMM.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Spectral Gap and Mixing Time

**Conjecture**: For an (n+1)×(n+1) matrix W over ℝ, define the tropical spectral gap as:
```
gap(W) = tropCycleMean(W) - second_tropCycleMean(W)
```
where the second cycle mean is the maximum over cycles that avoid the optimal cycle. Then the convergence rate in the tropical Perron-Frobenius theorem is controlled by gap(W): specifically, for all m ≥ N(gap), |tropPow' W m i j / (m+1) - tropCycleMean(W)| ≤ C/gap(W).

**Test**: Verify computationally for 3×3 and 4×4 matrices that the convergence rate is inversely proportional to the spectral gap. Then attempt to prove the bound using the existing Perron-Frobenius convergence proof.

**Impact**: This would give quantitative convergence rates for max-plus dynamical systems, analogous to the spectral gap theory for Markov chains. Applications to scheduling, manufacturing systems, and network optimization.

**Catalog References**: `Catalog/Tropical/PerronFrobenius.lean` (tropical_perron_frobenius, tropRate), `Catalog/Tropical/SpectralTheory.lean`

**Proof Strategy**: Analyze the convergence proof in PerronFrobenius.lean to extract explicit bounds. The key is showing that the "off-diagonal" terms in the squeeze argument decay at rate determined by gap(W). Use the superadditivity of diagonal entries to bound the transient period.

**Domain Bridges**: Tropical algebra ↔ Markov chain theory (spectral gap controls mixing), Tropical algebra ↔ Control theory (convergence rate controls settling time)

**Lineage**: Builds on this cycle's tropPow'_diag_superadd, tropTr_ge_diag_sum, and the existing tropical_perron_frobenius.

**Ambition**: extension

---

### Direction 4: Tropical Determinant over Valued Fields

**Conjecture**: For a non-Archimedean valued field (K, val), the tropicalization of the classical determinant equals the tropical determinant of the valuation matrix:
```
val(det(M)) = tropDet(val ∘ M) when M is "tropically generic"
```
where a matrix is tropically generic if the maximum in the tropical determinant is achieved by a unique permutation.

**Test**: Verify for p-adic fields (ℚ_p with p-adic valuation) for 2×2 and 3×3 matrices. Construct explicit examples of non-generic matrices where the identity fails.

**Impact**: This connects tropical linear algebra to number theory (p-adic analysis) and algebraic geometry (Berkovich spaces). It would justify the tropical determinant as a "shadow" of the classical determinant under valuation.

**Catalog References**: `Catalog/Tropical/PerronFrobenius.lean`, `Catalog/Tropical/PAdicTropical.lean`, `Catalog/Algebra/ArtinConjecture.lean`

**Proof Strategy**: For a 2×2 matrix [[a,b],[c,d]], det = ad - bc, and val(ad - bc) = min(val(ad), val(bc)) = min(val(a)+val(d), val(b)+val(c)) when the minimum is achieved uniquely (ultrametric inequality). This is exactly tropDet with the min-plus convention. Generalize to n×n using the valuation of a sum of products.

**Domain Bridges**: Tropical algebra ↔ Number theory (p-adic valuations), Tropical algebra ↔ Algebraic geometry (tropicalization of varieties)

**Lineage**: Builds on this cycle's tropDet and tropDet_achieved.

**Ambition**: extension

---

### Direction 5: Tropical Linear Programming Duality

**Conjecture**: There exists a tropical analog of LP duality: for a tropical linear program
```
maximize tropDet(A restricted to columns S) subject to |S| = k
```
the dual is a tropical covering problem, and strong duality holds: the tropical primal optimum equals the tropical dual optimum.

**Test**: Formalize the tropical primal and dual for 3×3 matrices with k=2. Verify computationally that strong duality holds for random instances. Attempt proof for general n.

**Impact**: This would establish tropical LP duality as a rigorous framework, connecting tropical algebra to operations research and providing new algorithms for assignment-type problems.

**Catalog References**: `Catalog/Tropical/Matrix/Defs.lean`, `Catalog/Tropical/Convexity/Basic.lean`, `Catalog/Tropical/DiffConstraints.lean`

**Proof Strategy**: Define the tropical primal (maximum weight k-assignment) and dual (minimum weight k-cover). Use König's theorem tropicalized to establish strong duality. The key is showing that the tropical max-flow min-cut theorem extends to weighted settings.

**Domain Bridges**: Tropical algebra ↔ Operations research (LP duality), Tropical algebra ↔ Combinatorics (König-Egerváry theorem)

**Lineage**: Builds on this cycle's tropDet, tropDet_achieved, and tropDet_product_ge.

**Ambition**: extension
