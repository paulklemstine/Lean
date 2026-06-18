# Future Research Directions

## Synthesis

This research cycle formalized the structural theory of MDS (Maximum Distance Separable) matrices, establishing machine-verified proofs of key results: the MDS inverse theorem (M MDS implies M⁻¹ MDS), diagonal scaling invariance, Vandermonde structural identities, the polynomial evaluation support bound, and the finite field size bound n ≤ q + 1. Two novel definitions were introduced: the MDS rank (measuring depth of submatrix invertibility) and the evaluation uncertainty structure (packaging the polynomial root bound as an uncertainty principle).

The most promising cross-domain connection from this cycle is the complete chain from polynomial algebra through Vandermonde matrices to uncertainty principles. Specifically, the polynomial root bound (formalized as `polynomial_eval_support_lower_bound`) connects algebra to combinatorics, the Vandermonde structural identity (`vandermonde_submatrix_rows_eq`) connects linear algebra to evaluation codes, and the MDS-Uncertainty equivalence (from `Algebra/MDSUncertainty.lean`) connects coding theory to harmonic analysis. The missing link — proving that specific matrix constructions (DFT matrices, Cauchy matrices) are MDS — would complete the chain and connect all existing results into a single unified proof pipeline from roots of unity to uncertainty.

The MDS conjecture from finite geometry offers the richest vein for future work. Our finite field bound (`mds_size_bound_finite_field`) establishes the upper limit n ≤ q + 1, but the precise conditions under which equality holds remain open. Resolving even partial cases (e.g., showing the bound is tight for prime fields via explicit Reed-Solomon constructions) would have implications across coding theory, finite geometry, and cryptographic design.

---

### Direction 1: Cauchy Matrices Are MDS

**Conjecture**: For a field F and distinct sequences x₁,...,xₙ and y₁,...,yₙ in F with xᵢ + yⱼ ≠ 0 for all i,j, the Cauchy matrix C with entries C_{i,j} = 1/(xᵢ + yⱼ) is MDS. That is, every square submatrix of C has nonzero determinant.

**Test**: (a) Verify computationally for small cases (n ≤ 6) over ℚ with random distinct x,y sequences. (b) Attempt to formalize the Cauchy determinant formula for submatrices: det(C[I,J]) = (∏_{i<j in I} (xⱼ-xᵢ))(∏_{i<j in J} (yⱼ-yᵢ)) / (∏_{i∈I,j∈J} (xᵢ+yⱼ)), which is manifestly nonzero when x's are distinct, y's are distinct, and all xᵢ+yⱼ ≠ 0.

**Impact**: Cauchy matrices provide the most natural infinite family of MDS matrices. Formalizing their MDS property would complete one branch of the MDS-Uncertainty chain, giving concrete constructions that achieve the optimal uncertainty bound. Combined with `mds_iff_uncertainty` from `MDSUncertainty.lean`, this yields explicit matrices satisfying the discrete uncertainty principle.

**Catalog References**: `Algebra/MDSUncertainty.lean` (IsMDS, mds_iff_uncertainty), `Algebra/MDSStructure.lean` (IsMDSMatrix, mds_matrix_inverse, mds_left_diagonal_mul)

**Proof Strategy**: 
1. Define the Cauchy matrix as a Matrix (Fin n) (Fin n) F
2. Prove the Cauchy determinant formula for the full matrix (product formula)
3. Show the submatrix of a Cauchy matrix is again a Cauchy matrix (with restricted index sets)
4. Conclude each submatrix determinant is nonzero from the product formula

**Domain Bridges**: Linear algebra (Cauchy determinant) ↔ Coding theory (generalized RS codes) ↔ Harmonic analysis (uncertainty)

**Lineage**: Extends `mds_iff_uncertainty` and `mds_left_diagonal_mul` from this cycle. The diagonal scaling theorem shows that Cauchy matrices (which are diagonal conjugates of simpler structured matrices) inherit MDS from their base forms.

**Ambition**: extension

---

### Direction 2: DFT Matrices over Prime Fields Are MDS

**Conjecture**: Over Z/pZ (p prime), the n × n DFT matrix F with entries F_{j,k} = ω^{jk} (where ω is a primitive n-th root of unity and n | p-1) is MDS.

**Test**: (a) Computationally verify for p = 5, n = 4 (ω = 2); p = 7, n = 6 (ω = 3); p = 13, n = 12. (b) If n = p (the full DFT), verify Tao's result that the Fourier uncertainty principle holds with the tightest bound.

**Impact**: This would formally connect the Fourier uncertainty principle (already formalized in `Algebra/FourierAnalysis/Theorems.lean`) to the MDS equivalence (`MDSUncertainty.lean`), completing the cross-domain chain: Fourier analysis ↔ MDS matrices ↔ coding theory. It would also provide the formal basis for Tao's celebrated 2005 result.

**Catalog References**: `Algebra/FourierAnalysis/Theorems.lean`, `Algebra/FourierAnalysis/Defs.lean`, `Algebra/MDSUncertainty.lean`, `Algebra/MDSStructure.lean`

**Proof Strategy**:
1. Define DFT matrix over Z/pZ using primitive roots of unity
2. Show every submatrix determinant is a product involving Vandermonde-like factors and roots of unity
3. Use the Chebotarev theorem on roots of unity (every minor of the DFT matrix is nonzero) or reduce to the polynomial root bound over Z/pZ
4. Alternative: use the Cauchy matrix representation of the DFT (after appropriate diagonal scaling), then apply the Cauchy MDS result from Direction 1

**Domain Bridges**: Harmonic analysis (Fourier transform) ↔ Number theory (roots of unity in Z/pZ) ↔ Coding theory (Reed-Solomon = evaluation at roots of unity) ↔ Linear algebra (MDS submatrix invertibility)

**Lineage**: Builds on `Algebra/FourierAnalysis/` and `Algebra/MDSUncertainty.lean` from the Catalog, plus `mds_left_diagonal_mul` and `mds_size_bound_finite_field` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: MDS Rank Distribution in Random Matrices

**Conjecture**: For an n × n matrix with entries uniformly random from F_q (q > n), the expected MDS rank satisfies E[mdsRank(M)] ≥ n - O(n/q). In the limit q → ∞, the MDS rank converges to n in probability (i.e., random matrices over large fields are MDS with high probability).

**Test**: (a) Computationally sample 10,000 random 4×4 matrices over F_7, F_{11}, F_{13} and compute the MDS rank distribution. (b) Compare the empirical distribution to the Poisson heuristic: the probability of a k×k submatrix being singular is approximately q^{-1}, and there are C(n,k)² such submatrices, so the expected number of singular submatrices at level k is C(n,k)²/q.

**Impact**: Understanding the distribution of MDS rank would quantify the "typicality" of the MDS property. If random matrices are nearly MDS over large fields, this validates the use of random codes as near-optimal error-correcting codes. The MDS rank distribution also connects to random matrix theory and the distribution of minors.

**Catalog References**: `Algebra/MDSStructure.lean` (mdsRank, mdsRank_le, mdsRank_eq_of_isMDS)

**Proof Strategy**:
1. Formalize the probability space of random matrices over F_q
2. Bound the probability that a specific k×k submatrix is singular (≈ 1/q by Schwartz-Zippel)
3. Apply union bound over all C(n,k)² submatrices
4. Sum over k to bound the probability that mdsRank < n

**Domain Bridges**: Probability theory (random matrices) ↔ Coding theory (random linear codes) ↔ Algebra (MDS rank) ↔ Combinatorics (submatrix counting)

**Lineage**: Extends `mdsRank` from this cycle. Uses `Algebra/CircuitComplexity/Freivalds.lean` (nonzero_linear_form_zero_set_bound) for the Schwartz-Zippel component.

**Ambition**: extension

---

### Direction 4: Quantum MDS Codes and the Quantum Singleton Bound

**Conjecture**: Every classical n × n MDS matrix M over F_q (with q = p^2 a perfect square) gives rise to a quantum MDS code [[n, n-2d+2, d]]_q that achieves the quantum Singleton bound, via the CSS (Calderbank-Shor-Steane) or Hermitian construction. The structural properties of classical MDS (inverse stability, diagonal invariance) transfer to the quantum setting.

**Test**: (a) For q = 4, n = 5, construct the classical MDS matrix (via Reed-Solomon over GF(4)) and verify the CSS construction yields a valid quantum code. (b) Verify that the quantum Singleton bound d ≤ ⌊n/2⌋ + 1 is achieved.

**Impact**: This would bridge classical coding theory (formalized in `MDSUncertainty.lean` and `MDSStructure.lean`) to quantum information theory. Quantum MDS codes are crucial for fault-tolerant quantum computation, and formalizing their existence from classical MDS matrices would establish a verified pipeline from polynomial algebra to quantum error correction.

**Catalog References**: `Algebra/MDSUncertainty.lean`, `Algebra/MDSStructure.lean` (mds_matrix_inverse, mds_left_diagonal_mul)

**Proof Strategy**:
1. Define quantum stabilizer codes in Lean using the symplectic framework
2. Define the CSS construction from a pair of classical codes C₂ ⊂ C₁
3. Show that when C₁ and C₂ are MDS, the resulting quantum code achieves the quantum Singleton bound
4. Transfer classical MDS structural properties (inverse, diagonal) to quantum invariants

**Domain Bridges**: Classical coding theory (MDS codes) ↔ Quantum information (stabilizer codes) ↔ Symplectic geometry (symplectic self-orthogonality) ↔ Algebra (Hermitian inner products over F_{q²})

**Lineage**: Extends `mds_iff_uncertainty` and `mds_matrix_inverse` from the Catalog into quantum territory. No prior quantum coding formalization exists in the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Tropical MDS and Valuated Matroids

**Conjecture**: The tropicalization of an MDS matrix (replacing field arithmetic with the tropical semiring: addition becomes min, multiplication becomes addition) yields a valuated matroid where every basis has the same valuation. Conversely, a valuated matroid with this "uniform valuation" property lifts to an MDS matrix over any sufficiently large valued field.

**Test**: (a) Tropicalize the 3×3 Cauchy matrix over ℚ with the p-adic valuation for p = 2, 3, 5. Verify that all 3×3 minors have the same tropical determinant. (b) Construct a counterexample: a matrix that is "tropically MDS" but whose lift over ℚ_p is not MDS.

**Impact**: This would connect the MDS theory to tropical geometry, opening a new domain bridge. Tropical MDS matrices would provide a combinatorial shadow of the algebraic MDS property, potentially simplifying the MDS conjecture by reducing it to a combinatorial statement about valuated matroids.

**Catalog References**: `Tropical/FreivaldsLocal.lean` (tropical Schwartz-Zippel), `Algebra/TropicalBSDEquality.lean`, `Algebra/MDSStructure.lean`

**Proof Strategy**:
1. Define tropical MDS using the tropical determinant (permanent of the tropical matrix)
2. Show that a classically MDS matrix is tropically MDS under any valuation
3. Investigate the converse: when does tropical MDS lift to classical MDS?
4. Use the connection between valuated matroids and tropical Grassmannians

**Domain Bridges**: Tropical geometry (tropical determinant, valuated matroids) ↔ Algebraic geometry (Grassmannians) ↔ Coding theory (MDS codes) ↔ Number theory (p-adic valuations)

**Lineage**: Extends `mds_size_bound_finite_field` and connects to the existing tropical algebra in the Catalog (`Tropical/`).

**Ambition**: grand_challenge
