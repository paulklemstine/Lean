# Future Directions: Tropical Linear Algebra

## Synthesis

This research cycle established a formally verified foundation for tropical determinant theory, proving the superadditivity theorem (`tdet(A⊗B) ≥ tdet(A) + tdet(B)`) and connecting it to the optimal assignment problem and the tropical Perron-Frobenius eigenvalue. The most surprising discovery was the tight interplay between the superadditivity gap and the composability of optimal permutations — this gap measures a fundamental obstruction to decomposing optimization problems, with connections to total unimodularity and the Hungarian algorithm's dual variables.

The most promising cross-domain connection is between the superadditivity theorem and the theory of valuated matroids. The tropical determinant, viewed as a function on the set of all square matrices, satisfies the tropical Plücker relations — this makes it a valuated matroid. The superadditivity theorem is a shadow of the matroid exchange property. Pursuing this connection could unify tropical spectral theory with matroid theory, potentially yielding new algorithms for optimization problems on matroids.

The cycle also revealed a key boundary: the tropical trace is NOT bounded by the tropical determinant (unlike the classical case), which means tropical spectral bounds require different techniques than their classical analogs. This boundary condition should guide future formalization efforts.

---

### Direction 1: Tropical Cayley-Hamilton Theorem

**Conjecture**: Every (n+1)×(n+1) tropical matrix A satisfies its tropical characteristic polynomial: the tropical identity `A^{n+1} ⊕ c_n ⊗ A^n ⊕ ... ⊕ c_0 ⊗ I = A^{n+1} ⊕ c_n ⊗ A^n ⊕ ... ⊕ c_0 ⊗ I` holds where c_k is the maximum weight of a k-element partial permutation (k×k tropical minor). Specifically, the tropical characteristic polynomial `χ_A(x) = tdet(x⊗I ⊕ A)` evaluated at A (in the tropical sense) should yield a matrix identity.

**Test**: Formalize tropical minors (k×k subpermanents), define the tropical characteristic polynomial, and prove the Cayley-Hamilton identity for 2×2 and 3×3 matrices computationally, then prove the general case.

**Impact**: If true, this gives a tropical analog of the minimal polynomial and connects to the theory of tropical eigenvalues (roots of the characteristic polynomial). If the naive statement is false (which is possible — the tropical Cayley-Hamilton is subtle), understanding the correct formulation would be a contribution in itself.

**Catalog References**: `Catalog/Tropical/PerronFrobenius.lean`, `Tropical/TropicalLinearAlgebra.lean`

**Proof Strategy**: Define tropical k-minors as max over k-element partial permutations. The characteristic polynomial coefficients are the tropical elementary symmetric functions of the eigenvalues. Use the power growth theorem and Perron-Frobenius convergence to relate the coefficients to the matrix powers.

**Domain Bridges**: Tropical algebra <-> Matroid theory (tropical minors are valuated matroid bases)

**Lineage**: Builds on `tropDet_superadditive` and `tropPow'_add` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Equality Characterization in Superadditivity

**Conjecture**: `tdet(A ⊗ B) = tdet(A) + tdet(B)` if and only if there exist optimal permutations σ for A and τ for B such that τ ∘ σ is optimal for A ⊗ B. Equivalently, the optimal assignment for the product decomposes into optimal assignments for the factors.

**Test**: Formalize the characterization and prove it for 2×2 matrices. For the general case, connect to the complementary slackness conditions of the LP relaxation of the assignment problem.

**Impact**: This characterizes exactly when tropical determinants are "multiplicative" (i.e., the semiring homomorphism property holds). It would connect tropical algebra to LP duality theory and the structure of the Birkhoff polytope.

**Catalog References**: `Tropical/TropicalLinearAlgebra.lean` (tropDet_superadditive)

**Proof Strategy**: The forward direction follows from examining the proof of superadditivity — equality holds iff the witness permutation τ∘σ achieves the maximum for A⊗B. The reverse direction requires showing that if every optimal A⊗B permutation decomposes, then σ and τ must be individually optimal.

**Domain Bridges**: Tropical algebra <-> Linear programming duality <-> Birkhoff polytope geometry

**Lineage**: Direct extension of tropDet_superadditive from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Rank and Factor Rank

**Conjecture**: The tropical rank of A (minimum r such that A = B ⊗ C with B having r columns) determines the growth rate of tdet(A^{m+1})/(m+1). Specifically, if tropRank(A) = r, then tdet(A^{m+1})/(m+1) converges to r times the maximum cycle mean rather than (n+1) times.

**Test**: Define tropical rank formally. Compute it for small examples (2×2, 3×3). Prove or disprove the growth rate connection.

**Impact**: If true, this connects the algebraic notion of rank (factorization width) to the spectral notion (eigenvalue multiplicity) in the tropical setting. This would be a tropical analog of the rank-nullity theorem.

**Catalog References**: `Catalog/Tropical/FactorRank.lean`, `Catalog/Tropical/RankGrowth.lean`, `Tropical/TropicalLinearAlgebra.lean`

**Proof Strategy**: The lower bound should follow from the superadditivity theorem applied to the factorization A = B⊗C. The upper bound requires understanding how the tropical rank constrains the set of achievable permutations.

**Domain Bridges**: Tropical algebra <-> Nonneg matrix factorization <-> Machine learning (NMF is widely used)

**Lineage**: Builds on tropDet_tropPow_lower from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Tropical Determinant over WithBot ℝ

**Conjecture**: All theorems in this cycle extend to matrices over `WithBot ℝ` (= ℝ ∪ {-∞}), the full tropical semiring. The tropical determinant over `WithBot ℝ` equals -∞ if and only if every permutation has at least one -∞ entry, which corresponds to the matrix's bipartite graph having no perfect matching.

**Test**: Redefine tropDet for `WithBot ℝ` matrices. Prove that tdet(A) = -∞ iff the bipartite graph of A has no perfect matching (Hall's theorem connection). Prove superadditivity in this extended setting.

**Impact**: This is the "correct" tropical setting. The restriction to ℝ (no -∞) corresponds to complete graphs, which avoids many subtleties. Extending to WithBot ℝ connects to Hall's marriage theorem and the Tutte matrix.

**Catalog References**: `Catalog/Tropical/PerronFrobenius.lean`, `Tropical/TropicalLinearAlgebra.lean`

**Proof Strategy**: Use Mathlib's `WithBot` type. The key difficulty is that `Finset.sup'` becomes `Finset.sup` (which can be ⊥). Superadditivity requires careful handling of the -∞ cases.

**Domain Bridges**: Tropical algebra <-> Matching theory (Hall's theorem) <-> Graph theory

**Lineage**: Direct generalization of all results from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Matrix Factorization Hardness

**Conjecture**: Deciding whether a tropical matrix A has tropical rank ≤ r is NP-hard for r ≥ 2, even when A has entries in {0, 1, -∞}. This is the tropical analog of the NP-hardness of nonneg matrix factorization.

**Test**: Reduce a known NP-hard problem (e.g., set cover or 3-coloring) to tropical rank computation. Formalize the reduction.

**Impact**: This would establish a complexity-theoretic barrier for tropical linear algebra, showing that unlike the tropical determinant (which is in P), the tropical rank is computationally intractable. This has implications for tropical convexity and tropical Grassmannians.

**Catalog References**: `Catalog/Tropical/FactorRankSeparation.lean`, `Catalog/Computation/TropicalComplexity/Defs.lean`

**Proof Strategy**: Model set cover as a tropical factorization problem. A set cover of size r corresponds to a tropical rank-r factorization where the factors encode set membership.

**Domain Bridges**: Tropical algebra <-> Computational complexity <-> Combinatorial optimization

**Lineage**: Motivated by the contrast between P-time tropical determinant and potentially hard tropical rank.

**Ambition**: extension
