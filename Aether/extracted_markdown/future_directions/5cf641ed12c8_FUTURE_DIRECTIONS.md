# Future Directions: Tropical Post-Quantum Cryptography

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical Matrix Decomposition Hardness Lower Bound

**Theorem Statement**: For generic n×n tropical matrices A, B with A⊗B = B⊗A and spectral gap Δ > 0, any algorithm recovering (a, b) from A^a ⊗ B^b requires Ω(Δ^{n/2}) operations.

**Proof Strategy**:
- Define a tropical lattice embedding: map (a,b) ↦ A^a ⊗ B^b as a lattice point
- Show the lattice has minimum distance proportional to Δ
- Reduce to the Shortest Vector Problem (SVP) in the tropical lattice
- Use known SVP hardness results (Ajtai 1996) to establish lower bounds

**Why This Is Revolutionary**: Would be the first provable lower bound for any tropical cryptographic primitive, making tropical key exchange a candidate for NIST standardization.

**Catalog Leverage**: Build on `tropPow_tropPow_comm_of_comm`, `stickel_bilateral_key_agreement`

**Research Mode**: prove

**Estimated Depth**: 5

---

### 2. Deep ReLU Network Certified Robustness via Tropical Composition

**Theorem Statement**: For an L-layer ReLU network with weight matrices W₁,...,W_L, the total Lipschitz constant satisfies K ≤ ∏ᵢ max_j |W_i[j,·]|₁, and the certified robustness radius for margin m is r = m / K.

**Proof Strategy**:
- Formalize multi-variable tropical polynomial evaluation
- Extend `tropPolyEval_lipschitz_certified_robustness` to multiple variables
- Apply `tropicalLipschitz_composition` iteratively for L layers
- Prove the product bound is tight (exhibit achieving example)

**Why This Is Revolutionary**: First formally verified end-to-end certified robustness bound for deep ReLU networks with explicit, computable constants.

**Catalog Leverage**: `tropPolyEval_lipschitz_certified_robustness`, `tropicalLipschitz_composition`, `relu_one_lipschitz`

**Research Mode**: prove

**Estimated Depth**: 3

---

### 3. Tropical Eigenvalue Theory and Karp's Algorithm

**Theorem Statement**: The tropical eigenvalue λ(A) = min_{σ∈Cycles} (weight(σ)/length(σ)) satisfies A^n ⊗ v = λ(A)^n ⊗ v for the tropical eigenvector v, and can be computed in O(n³) time.

**Proof Strategy**:
- Define tropical eigenpairs: A ⊗ v = λ ⊗ v (entrywise min-plus)
- Prove existence for irreducible matrices via the fixed-point theorem
- Formalize Karp's algorithm as computing the max cycle mean
- Prove correctness by path decomposition into cycles + tails

**Why This Is Revolutionary**: Connects tropical spectral theory to both quantum Hamiltonian ground states (tight-binding model) and cryptographic security parameters.

**Catalog Leverage**: `tropMul_assoc`, `tropPow_right_mul`, `tropScalar_tropMul_left`

**Research Mode**: prove

**Estimated Depth**: 4

---

### 4. Tropical Variety Intersection and Neural Network Expressivity

**Theorem Statement**: A tropical polynomial map ℝ^n → ℝ with m terms has at most (m choose n) linear regions. The ReLU network computing this polynomial requires width ≥ m and depth ≥ ⌈log₂(m/n)⌉.

**Proof Strategy**:
- Define tropical hypersurfaces as loci where the minimum is achieved by ≥2 terms
- Prove the hyperplane arrangement theorem for tropical linear functions
- Count maximal cells using the theory of regular subdivisions
- Derive depth-width tradeoffs from the cell counting bound

**Why This Is Revolutionary**: First formal proof of neural network depth-width tradeoffs via tropical geometry, connecting expressivity theory to algebraic geometry.

**Catalog Leverage**: `tropPolyEval_lipschitz_certified_robustness`, `inf'_min_distrib`

**Research Mode**: prove

**Estimated Depth**: 4

---

### 5. Tropical Stickel Protocol with Polynomial Keys

**Theorem Statement**: For tropical polynomials p, q (formal min-plus expressions), if A⊗B = B⊗A then p(A) ⊗ q(B) = q(B) ⊗ p(A), and the generalized Stickel protocol with polynomial keys achieves key agreement.

**Proof Strategy**:
- Define formal tropical polynomial evaluation at matrices
- Prove distributivity of ⊗ over ⊕ for matrix expressions (already done!)
- Use distributivity to expand p(A) ⊗ q(B) into sum of monomials
- Apply `tropPow_tropPow_comm_of_comm` to each monomial pair

**Why This Is Revolutionary**: Extends the Stickel protocol from power-based keys to polynomial-based keys, exponentially increasing the key space and security.

**Catalog Leverage**: `tropMul_tropAdd_left_distrib`, `tropMul_tropAdd_right_distrib`, `tropPow_tropPow_comm_of_comm`

**Research Mode**: prove

**Estimated Depth**: 3

---

## Under-explored Territory

### Tropical Linear Algebra
- Many definitions (tropical determinant, rank, eigenvalues) lack deep theorems
- The tropical Cayley-Hamilton theorem is unformalized
- Connection to matroids and valuated matroids is unexplored

### Tropical Convexity
- Tropical convex sets are well-defined but lack formal theory
- Connection to optimal transport (Kantorovich duality has tropical flavor)
- Tropical Farkas lemma could yield new feasibility certificates

### Multi-variable Tropical Polynomials
- Our Lipschitz bounds are for single-variable polynomials
- Extension to ℝⁿ → ℝ requires tropical hyperplane arrangements
- This is exactly what's needed for deep neural network analysis

## Cross-Domain Bridges

### Tropical Algebra ↔ Quantum Computing
- Tropical eigenvalues ≈ ground state energies in tight-binding models
- Tropical spectral gap ≈ quantum energy gap (phase transition indicator)
- Conjecture: tropical matrix decomposition hardness implies quantum money security

### Tropical Algebra ↔ Optimal Transport
- Tropical linear programs are the "dequantized" versions of quantum optimal transport
- The tropical Wasserstein distance could unify geometric and algebraic approaches
- Connection to Sinkhorn algorithm for regularized transport

### Tropical Algebra ↔ Automata Theory
- Tropical semiring = the semiring of weighted automata over (min, +)
- Star-free regular expressions correspond to tropical rational functions
- Could yield new decidability results for weighted model checking

## Open Problems Encountered

### Problem 1: Tropical Identity Matrix
We avoided the tropical multiplicative identity (0 on diagonal, ∞ off-diagonal) by 
using the convention tropPow A 0 = A. A proper treatment requires extended reals 
(WithTop ℝ) or the EReal type, with significant API development.

### Problem 2: Tropical Polynomial Ring Structure  
Do formal tropical polynomials form a semiring? The tropical polynomial ring 
ℝ[x₁,...,xₙ]_trop has ⊕ = min and ⊗ = +, but the formal algebraic structure 
in Lean requires careful handling of the "zero" element (∞).

### Problem 3: Practical Security Parameters
What matrix dimension n and spectral gap Δ are needed for 256-bit security?
Our bound postQuantumSecurityBits ≥ n · log₂(Δ) is a lower bound; the true 
security could be much higher. Tight bounds require analyzing the best known 
attacks on tropical matrix decomposition.

### Problem 4: Resistance to Algebraic Attacks
Kotov and Ushakov (2018) showed that naive Stickel implementations are vulnerable 
to algebraic attacks. Characterizing which commuting pairs (A, B) resist these 
attacks is an open problem in tropical cryptanalysis.
