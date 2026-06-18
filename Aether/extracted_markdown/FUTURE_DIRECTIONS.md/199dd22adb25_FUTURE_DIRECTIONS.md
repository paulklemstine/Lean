# Future Directions: Tropical Determinants and Spectral Theory

## Synthesis

This research cycle established a rigorous foundation for tropical determinant theory, connecting three previously separate threads: (1) the assignment problem via tropical determinants, (2) tropical eigenvalues via the Perron-Frobenius theorem, and (3) a novel signed parity structure via the tropical signed determinant. The key bridge is the **tropical spectral polytope** P(A,λ), which geometrizes the relationship between the one-shot assignment problem (tropDet) and the asymptotic eigenvalue (λ(A)): nonemptiness of P(A,λ) implies tropDet(A) ≤ nλ.

The most promising cross-domain connection is between the **sign gap phase diagram** and **tropical geometry**. The locus where tropSignGap = 0 is a tropical hypersurface in parameter space, and its combinatorial type encodes how assignment parity changes under perturbation. This connects tropical linear algebra to tropical algebraic geometry in a way that has not been explored.

The Cauchy-Binet inequality — tropDet(A⊗B) ≥ tropDet(A) + tropDet(B) — is strictly stronger than the classical multiplicativity and creates a "synergy gap" that measures how much better the composed assignment is than the product of individual optima. Understanding this gap is the highest-impact direction: it would provide new bounds for multi-stage optimization problems and connect to the tropical Satake isomorphism program already in the catalog.

---

### Direction 1: Tropical Cauchy-Binet Equality Conditions

**Conjecture**: tropDet(A⊗B) = tropDet(A) + tropDet(B) if and only if there exists a permutation τ such that: (a) the optimal σ* for tropDet(A) and the optimal ρ* for tropDet(B) satisfy σ*∘ρ* achieves tropDet(A⊗B), and (b) the "witnesses" k_i = σ*(i) used in the Cauchy-Binet proof are individually optimal in each row of A⊗B.

**Test**: For 3×3 matrices over {0,1,...,9}, enumerate all pairs (A,B) where the Cauchy-Binet gap is zero and verify the structural condition. Compare with pairs where the gap is positive.

**Impact**: Characterizing equality would provide a tropical analogue of the Binet-Cauchy formula and give necessary/sufficient conditions for when multi-stage assignment problems decompose into independent stages. This would have applications in supply chain optimization and network flow.

**Catalog References**: `Tropical.EigenDet.Defs`, `tropCauchyBinet`, existing `Tropical.PerronFrobenius.lean`

**Proof Strategy**: Start by formalizing "compatible assignments" — pairs (σ,τ) where σ∘τ is also optimal for the product. Show that compatibility is necessary for equality. For sufficiency, show that if the Cauchy-Binet witness inequality is tight in every row, then equality holds.

**Domain Bridges**: Tropical determinants <-> Combinatorial optimization (Hungarian algorithm duality), Tropical Cauchy-Binet <-> Tropical Satake (GL_n Hecke algebras)

**Lineage**: Builds on tropCauchyBinet and tropDet_eq_permWeight from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Sign Gap Extremality and Tropical Hypersurfaces

**Conjecture**: For n×n matrices with entries in [0,M], |tropSignGap(A)| ≤ ⌊n/2⌋ · M. Moreover, the sign gap zero locus {A : tropSignGap(A) = 0} is a tropical hypersurface of degree (n-1)! in the space of matrix entries.

**Test**: Enumerate all 3×3 and 4×4 matrices with small integer entries and verify the bound computationally. Compute the fan structure of the zero locus for n=3 using polymake or TOPCOM.

**Impact**: This would establish the sign gap as a well-behaved tropical invariant with geometric meaning. The hypersurface structure would connect to tropical intersection theory and could provide new tools for sensitivity analysis of the assignment problem.

**Catalog References**: `Tropical.EigenDet.Defs` (tropSignGap), `Tropical.IntersectionTheory/`

**Proof Strategy**: For the upper bound, use the sandwich theorem (tropDet ≤ Σ max_j A_{ij}) applied separately to even and odd permutations. For the hypersurface structure, analyze the tropical polynomial whose terms correspond to even vs. odd permutation weights.

**Domain Bridges**: Sign gap <-> Tropical geometry (tropical hypersurfaces), Assignment parity <-> Representation theory (alternating group actions)

**Lineage**: Builds on tropDet_eq_max_sdet_adet and tropSignGap_diag_dominant from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Spectral Polytope Volume and Eigenvalue Sensitivity

**Conjecture**: The volume of P(A,λ) = {v ∈ ℝⁿ : A_{ij} + v_j ≤ v_i + λ} is a piecewise polynomial function of λ, with breakpoints at the tropical eigenvalues of submatrices of A. The volume is zero for λ < λ(A) (the maximum cycle mean) and positive for λ > λ(A).

**Test**: For 2×2 and 3×3 matrices, compute P(A,λ) explicitly as a polytope (using H-representation) and compute its volume as a function of λ. Verify the breakpoint structure.

**Impact**: A volume formula for the spectral polytope would provide a continuous measure of "spectral slack" — how much room there is in the eigenvalue constraint. This would connect to tropical Hodge theory and could provide new eigenvalue perturbation bounds.

**Catalog References**: `Tropical.EigenDet.Spectral` (TropSpectralPolytope), `Tropical.PerronFrobenius`

**Proof Strategy**: For n=2, the polytope P(A,λ) reduces to a system of 4 linear inequalities in 2 variables. Compute the vertex enumeration and volume explicitly. Generalize using the theory of hyperplane arrangements.

**Domain Bridges**: Spectral polytope volume <-> Tropical Hodge theory, Eigenvalue sensitivity <-> Perturbation theory (classical linear algebra)

**Lineage**: Builds on spectralPolytope_isClosed and tropDet_le_of_spectralPolytope_nonempty from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Determinant and Network Reliability

**Conjecture**: For the adjacency matrix A of a weighted directed graph G, tropDet(A^k)/k converges to λ(A) (the maximum cycle mean) as k → ∞. The convergence rate is O(1/k), and the constant depends on the "tropical condition number" — the gap between the two largest cycle means.

**Test**: Compute tropDet(A^k)/k for random weighted digraphs on 5-10 vertices and verify convergence. Measure the convergence rate and correlate with the cycle mean gap.

**Impact**: This would provide a deterministic alternative to Karp's algorithm for computing the maximum cycle mean, using only the tropical determinant oracle. The convergence rate bound would be new and practically useful.

**Catalog References**: `Tropical.PerronFrobenius` (tropical_perron_frobenius, tropRate), `Tropical.EigenDet.CauchyBinet` (tropDet_pow_ge)

**Proof Strategy**: Use the iterated Cauchy-Binet inequality (tropDet(A^k) ≥ (k+1)·tropDet(A)) for the lower bound. For the upper bound, use the sandwich theorem and the fact that row maxima of A^k grow at rate λ(A). The convergence rate bound follows from the Fekete subadditive lemma applied to -tropDet(A^k).

**Domain Bridges**: Tropical determinant convergence <-> Ergodic theory (Kingman's subadditive ergodic theorem), Network reliability <-> Graph theory (cycle structure)

**Lineage**: Builds on tropDet_pow_ge and tropDet_pow_superadd from this cycle, and the existing tropPow_diag_div_tendsto from the Perron-Frobenius file.

**Ambition**: extension

---

### Direction 5: Tropical Schur Complement and Block Elimination

**Conjecture**: Define the tropical Schur complement of a block matrix [[A, B], [C, D]] as S = D ⊕ C⊗A*⊗B, where A* is the Kleene star (tropical matrix inverse). Then tropDet([[A,B],[C,D]]) = tropDet(A) ⊕ tropDet(S), generalizing the classical Schur complement formula det(M) = det(A)·det(S).

**Test**: Verify computationally for 4×4 matrices partitioned into 2×2 blocks. The Kleene star A* = ⊕_{k≥0} A^k exists when A has no positive-weight cycles.

**Impact**: A tropical Schur complement formula would enable divide-and-conquer algorithms for the assignment problem, reducing n×n to two n/2 × n/2 problems. This would be a significant algorithmic advance and would connect tropical linear algebra to the theory of rational series in noncommutative algebra.

**Catalog References**: `Tropical.EigenDet.Defs` (tropDet), `Tropical.GraphTheory.KleeneStarUpdate`

**Proof Strategy**: First define the tropical Kleene star for matrices with non-positive cycle weights. Then prove the block formula by expanding both sides in terms of permutation weights and showing they match. The key technical lemma is that every permutation of {1,...,n} decomposes into a "block-respecting" and "block-crossing" component.

**Domain Bridges**: Tropical Schur complement <-> Systems theory (transfer functions), Block elimination <-> Computational algebra (Gaussian elimination)

**Lineage**: New direction, builds on the tropical determinant foundations from this cycle.

**Ambition**: grand_challenge
