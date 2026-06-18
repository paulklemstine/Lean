# Future Research Directions: Gap Automaton Spectral Theory

## Synthesis

This research cycle established the Walk-Matrix Correspondence — the fundamental theorem connecting combinatorial walk counting in directed multigraphs to matrix powers — and applied it to gap automata from prime sieve theory. We proved nine theorems forming a complete algebraic toolkit: walk-matrix correspondence, walk decomposition, closed walk-trace identity, entrywise monotonicity of multiplication and powers, self-loop growth bounds, alphabet monotonicity, walk growth monotonicity, and word growth at zero.

The most promising cross-domain connection is between the **entrywise matrix lattice** and the **hierarchy of prime sieves**. The entrywise ordering on ℕ-valued matrices, which we proved is preserved under multiplication and exponentiation, provides a rigorous framework for comparing gap automata at different sieve depths and alphabet sizes. This creates a monotone functor from the poset of (sieve depth, alphabet size) pairs to the poset of transfer matrices, with entropy as a monotone invariant. This connects to the Catalog's existing tropical spectral theory (`FINAL/Tropical/SpectralTheory.lean`) and Perron-Frobenius infrastructure (`FINAL/Tropical/PerronFrobenius.lean`).

Direction 1 has the highest breakthrough potential because formalizing the Perron-Frobenius eigenvalue bound for ℕ-valued matrices would unlock the entropy computation and connect the combinatorial walk-counting framework to the analytic theory of spectral radii. Direction 2 would provide the first rigorous comparison between gap automata at different sieve depths, potentially yielding new constraints on prime gap distributions.

---

### Direction 1: Perron-Frobenius Eigenvalue and Entropy Computation for Gap Automata

**Conjecture**: For any irreducible nonneg integer matrix A of dimension d with spectral radius ρ, the word growth function W(k) = ∑_{s,t} (A^k)(s,t) satisfies ρ^k ≤ W(k) ≤ d² · ρ^k for all k ≥ 1. Consequently, the topological entropy h = lim (1/k) log W(k) = log ρ.

**Test**: For the sieve-6 transfer matrix [[1,2],[2,1]] with ρ = 3, verify computationally that W(k)/3^k ∈ [1, 4] for k = 1, ..., 20. Then attempt to formalize the upper bound using the Perron-Frobenius theorem for ℕ-valued matrices.

**Impact**: This would provide a complete formal proof that the topological entropy of a gap automaton equals the log of its spectral radius, connecting walk counting (combinatorics) to eigenvalue theory (analysis). It would also yield computable entropy values for any sieve depth.

**Catalog References**: `FINAL/Tropical/PerronFrobenius.lean` (tropical Perron-Frobenius), `FINAL/Tropical/SpectralTheory.lean` (spectral bounds), `Tropical/GapAutomatonSpectral.lean` (walk-matrix correspondence from this cycle)

**Proof Strategy**: 
1. Formalize the Gelfand formula: ρ(A) = lim_{k→∞} ‖A^k‖^{1/k} for operator norms.
2. Use the entrywise bound: max entry of A^k ≤ ρ^k · polynomial(k).
3. Show W(k) ≤ d² · (max entry of A^k) for the upper bound.
4. Use diagonal_pow_lower_bound for the lower bound.
5. Conclude h = log ρ by the squeeze theorem.

**Domain Bridges**: Combinatorics (walk counting) ↔ Analysis (spectral radius) ↔ Dynamical Systems (topological entropy)

**Lineage**: Builds on `walkCount_eq_pow`, `diagonal_pow_lower_bound`, and `totalWalks_ge_trace` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Gap Monotonicity Across Sieve Depths

**Conjecture**: Let S_k = {2, 3, ..., p_k} be the first k primes, m_k = ∏ S_k the primorial, and T_k the transfer matrix of the gap automaton with modulus m_k and alphabet Σ_k = {2, 4, ..., 2p_{k+1}}. Then the spectral gap Δ_k = λ₁(T_k) - |λ₂(T_k)| is strictly increasing in k.

**Test**: 
- k=1 (sieve {2}, m=2): T = [1] restricted to admissible, Δ₁ = 0.
- k=2 (sieve {2,3}, m=6): T = [[1,2],[2,1]], eigenvalues 3, -1, Δ₂ = 4.
- k=3 (sieve {2,3,5}, m=30): Compute T₃ (8×8 matrix on admissible residues mod 30), find eigenvalues, compute Δ₃.
- Verify Δ₁ < Δ₂ < Δ₃.

**Impact**: If true, deeper sieves produce more rapidly mixing gap sequences. This would imply that the prime gap distribution becomes "more random" (in the spectral sense) as we sieve deeper — a quantitative form of the heuristic that "primes behave like random numbers coprime to small primes."

**Catalog References**: `FINAL/Tropical/MixingTheory.lean` (mixing from spectral gap), `Tropical/GapAutomatonSpectral.lean` (walk-matrix and monotonicity)

**Proof Strategy**:
1. Compute T_k for k = 1, 2, 3, 4 using the explicit residue class arithmetic.
2. Verify the conjecture computationally for small k.
3. For a theoretical proof, analyze the block structure of T_k: when passing from k to k+1, the state space grows by a factor of p_{k+1} - 1 (Chinese Remainder Theorem), and the alphabet gains new elements. Relate Δ_{k+1} to Δ_k via the tensor product / Kronecker structure.

**Domain Bridges**: Number Theory (sieve hierarchy) ↔ Linear Algebra (spectral gap) ↔ Ergodic Theory (mixing rates)

**Lineage**: Builds on `gapSFT_alphabet_mono`, `entrywiseLe_pow_of_entrywiseLe`, and the sieve-6 concrete results from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Transfer Matrix and Max-Plus Entropy

**Conjecture**: The tropical (max-plus) analogue of the transfer matrix T^⊕, defined by T^⊕(s,t) = max{log g : g ∈ alphabet, (s+g) mod d = t}, has tropical spectral radius ρ^⊕ = max cycle mean in the state graph, and this satisfies ρ^⊕ ≤ log ρ(T) where ρ(T) is the classical spectral radius.

**Test**: For the sieve-6 automaton with alphabet {2,4,6,8,10}:
- Classical: ρ = 3, log ρ ≈ 1.099
- Tropical: T^⊕ = [[log 6, log 10], [log 8, log 6]], ρ^⊕ = max cycle mean
- Compute ρ^⊕ and verify ρ^⊕ ≤ log 3.

**Impact**: Would establish a formal bridge between classical and tropical spectral theory for gap automata, connecting to the existing tropical machinery in the Catalog.

**Catalog References**: `FINAL/Tropical/SpectralTheory.lean`, `FINAL/Tropical/PerronFrobenius.lean`, `FINAL/Tropical/MarkovTropicalBridge.lean`

**Proof Strategy**: 
1. Define the tropical transfer matrix using max-plus operations.
2. Compute the tropical eigenvalue as the maximum cycle mean (Karp's theorem).
3. Use the AM-GM inequality to relate tropical and classical spectral radii.

**Domain Bridges**: Tropical Geometry (max-plus algebra) ↔ Classical Spectral Theory ↔ Number Theory (sieve automata)

**Lineage**: Builds on the transfer matrix formalism from this cycle and the tropical spectral infrastructure in the Catalog.

**Ambition**: extension

---

### Direction 4: Transfer Matrix Factorization via Chinese Remainder Theorem

**Conjecture**: The transfer matrix T_k for sieve depth k (modulus m_k = ∏_{i=1}^k p_i) decomposes as a tensor product: T_k ≅ T_{k-1} ⊗ L_k, where L_k is a p_k × p_k matrix encoding the local constraints from the prime p_k. The spectral radius satisfies ρ(T_k) = ρ(T_{k-1}) · ρ(L_k).

**Test**: For k = 3 (adding prime 5 to the {2,3}-sieve):
- T₂ is 2×2 (admissible states mod 6: {1,5})
- L₃ should be 4×4 (admissible residues mod 5: {1,2,3,4})
- Check if T₃ ≅ T₂ ⊗ L₃ as a 8×8 matrix

**Impact**: A tensor factorization would reduce the spectral analysis of deep sieves to the analysis of small local factors, making the entropy computable in closed form for arbitrary sieve depth.

**Catalog References**: `Tropical/GapAutomatonSpectral.lean`, `FINAL/Tropical/SpectralTheory.lean`

**Proof Strategy**:
1. Use the Chinese Remainder Theorem to decompose Fin m_k ≅ Fin m_{k-1} × Fin p_k.
2. Show the admissibility predicate factors: admissible(s) ↔ admissible_{k-1}(s mod m_{k-1}) ∧ admissible_k(s mod p_k).
3. Show the transition function respects the factorization.
4. Conclude the transfer matrix is the Kronecker product (possibly after reindexing).

**Domain Bridges**: Algebra (CRT, tensor products) ↔ Number Theory (primorial factorization) ↔ Linear Algebra (Kronecker eigenvalues)

**Lineage**: Builds on the GapSFT structure and transfer matrix from this cycle.

**Ambition**: extension

---

### Direction 5: Admissible Tuple Counting via Walk Theory

**Conjecture**: The number of admissible k-tuples (in the Hardy-Littlewood sense) with entries in [0, N] and mutual differences in a gap alphabet Σ is asymptotically C · N · ρ(T)^{k-1} as N → ∞, where C is a computable constant depending on the sieve depth and ρ(T) is the spectral radius of the gap automaton's transfer matrix.

**Test**: For the sieve-6 automaton with alphabet {2, 4, 6}:
- Count admissible 3-tuples with entries in [0, 100].
- Verify the count ≈ C · 100 · ρ² for some constant C.

**Impact**: Would connect the gap automaton framework to the Hardy-Littlewood singular series, providing a new spectral interpretation of the classical prime tuple conjectures.

**Catalog References**: `Tropical/GapAutomatonSpectral.lean` (walk counting), `MachineLearning/PrimeGapFramework.lean` (gap density)

**Proof Strategy**:
1. Model admissible k-tuples as walks of length k-1 in the gap automaton.
2. Use the walk-matrix correspondence to count walks.
3. Sum over starting positions in [0, N] to get the asymptotic formula.
4. Identify C with the left Perron-Frobenius eigenvector components.

**Domain Bridges**: Number Theory (Hardy-Littlewood conjectures) ↔ Combinatorics (walk counting) ↔ Analysis (asymptotic enumeration)

**Lineage**: Builds on `walkCount_eq_pow` and the GapSFT framework from this cycle.

**Ambition**: grand_challenge
