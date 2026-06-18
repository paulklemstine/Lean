# Future Research Directions

## Synthesis

This research cycle established the theory of **nonlinear tropical hash functions** through NTSHA — the Nonlinear Tropical Secure Hash Algorithm, which augments the standard tropical hash TSHA(m, h) = min_i(m_i + h_i) with modular reduction: NTSHA_p(m, h) = min_i((m_i + h_i) mod p). We proved that this modification breaks the shift equivariance that makes TSHA cryptographically trivial, while revealing a periodic lattice structure (pℤ)^k in preimage fibers. The exact fiber counting formula S_p(y, k) = (p-y)^k - (p-y-1)^k was established, showing fiber sizes telescope to p^k and decrease monotonically with hash value y.

The most promising cross-domain connection is between **tropical fiber geometry** and **lattice cryptography**. The fiber periodicity theorem shows that NTSHA preimage sets are unions of cosets of (pℤ)^k ⊂ ℤ^k. If finding short representatives in these coset structures can be reduced to the Closest Vector Problem (CVP) or Shortest Vector Problem (SVP), then NTSHA would inherit conjectured post-quantum hardness. This connects to the Catalog's existing work in `Tropical/MinPlusAlgebra.lean` (min-plus matrix algebra) and `Tropical/CPASecurity.lean` (CPA security from tropical extractors). The fiber counting results connect to the combinatorics of order statistics, and the antitonicity theorem reveals convexity properties of the fiber size function.

The highest breakthrough potential lies in **Direction 1** (Tropical-Lattice Security Reduction), because a formal reduction from NTSHA preimage-finding to CVP would establish the first rigorous post-quantum security guarantee for a tropical cryptographic primitive. **Direction 3** (Multi-Round NTSHA Avalanche Optimization) addresses the most significant practical limitation discovered in this cycle: the high zero-avalanche rate (~63% for k=3), which must be reduced for practical deployment.

---

### Direction 1: Tropical-Lattice Security Reduction for NTSHA Preimage Problems

**Conjecture**: For prime p ≥ 5 and dimension k ≥ 3, finding m ∈ ℤ^k with ||m||_∞ ≤ B < p/2 and NTSHA_p(m, h) = y (for uniformly random h ∈ {0,...,p-1}^k and y ∈ {0,...,p-1}) is at least as hard as CVP in the lattice (pℤ)^k with target determined by h and y. Formally: any algorithm solving bounded-NTSHA-preimage in time T can be converted to a CVP solver in time O(T · k).

**Test**: Construct an explicit reduction. Given a CVP instance (lattice Λ = (pℤ)^k, target t), define h and y such that finding a short NTSHA preimage gives a close lattice vector. Verify the reduction preserves approximation factors by checking on known CVP instances with p ∈ {7, 11, 13} and k ∈ {3, 4, 5}.

**Impact**: If true, this would be the first post-quantum security guarantee for any tropical cryptographic primitive. It would validate the tropical approach to cryptography and open a new family of lattice-based constructions. If false, the failure would identify exactly which structural properties of NTSHA make it weaker than generic lattice problems, guiding the design of stronger tropical primitives.

**Catalog References**: `Tropical/MinPlusAlgebra.lean`, `Tropical/CPASecurity.lean`, `Cryptography/TropicalOneWayFoundations.lean`

**Proof Strategy**: (1) Define the short-preimage problem formally as a decision problem. (2) Construct a polynomial-time reduction from approximate CVP to bounded-NTSHA-preimage. (3) Show the reduction preserves approximation factors within a polynomial. Key lemma needed: the NTSHA preimage fiber intersected with the ball ||m||_∞ ≤ B has at most polynomially many elements when B < p/2.

**Domain Bridges**: Tropical Algebra ↔ Lattice Cryptography ↔ Post-Quantum Security

**Lineage**: Builds on ntsha_fiber_lattice_invariance and ntsha_collision_exists from this cycle's NTSHACore.lean.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Fiber Entropy and Information-Theoretic Security Bounds

**Conjecture**: The min-entropy of NTSHA_p output (with uniform input on {0,...,p-1}^k and fixed key h = 0) is exactly:

H_∞ = -log₂(max_y P(NTSHA = y)) = -log₂((p^k - (p-1)^k) / p^k) = k · log₂(p) - log₂(p^k - (p-1)^k)

and this satisfies H_∞ ≥ log₂(p) - log₂(k) - 1 for all p ≥ 2 and k ≥ 2. The gap between H_∞ and log₂(p) quantifies the security loss from tropical bias, and for fixed p, this gap is Θ(log k).

**Test**: Compute H_∞ for p ∈ {5, 7, 11, 13, 17, 19, 23} and k ∈ {2, 3, ..., 20}. Verify the bound H_∞ ≥ log₂(p) - log₂(k) - 1 holds in all cases. The tightest case should occur at small p and large k.

**Impact**: An exact entropy characterization would provide the foundation for information-theoretic security proofs of NTSHA-based protocols. The Θ(log k) gap shows that increasing dimension *decreases* per-output entropy, creating an interesting tension with the lattice hardness (which *increases* with dimension).

**Catalog References**: `Shared/NTSHAFiber.lean` (ntshaFiberSize_at_zero, ntsha_output_bias_lower_bound), `Tropical/CPASecurity.lean` (statDist framework)

**Proof Strategy**: (1) Express P(NTSHA = 0) = (p^k - (p-1)^k)/p^k = 1 - (1-1/p)^k. (2) Use the bound 1 - (1-1/p)^k ≤ k/p (union bound) to get H_∞ ≥ log₂(p/k). (3) Tighten using more precise asymptotics of (1-1/p)^k ≈ e^{-k/p}.

**Domain Bridges**: Combinatorics ↔ Information Theory ↔ Cryptographic Security

**Lineage**: Builds on ntshaFiberSize_at_zero and ntsha_output_bias_lower_bound from this cycle.

**Ambition**: extension

---

### Direction 3: Multi-Round NTSHA and Avalanche Optimization

**Conjecture**: Define the r-round NTSHA as NTSHA^{(r)}_p(m, h₁, ..., h_r) where the output of each round feeds into the next as a scalar broadcast (added to each component of the next key). For r ≥ ⌈log₂(p)⌉ rounds with independently random keys, the zero-avalanche proportion drops below 1/p, achieving near-ideal avalanche behavior.

Formally: let Z(r, p, k) = Pr_{m ∈ {0,...,p-1}^k}[NTSHA^{(r)}(m+e_j, h) = NTSHA^{(r)}(m, h)]. Conjecture: Z(⌈log₂(p)⌉, p, k) ≤ 1/p for all k ≥ 2.

**Test**: Implement multi-round NTSHA and compute Z(r, p, k) for p = 7, k = 3, and r = 1, 2, 3, 4, 5. The single-round value is Z(1, 7, 3) ≈ 0.63. The conjecture predicts Z(3, 7, 3) ≤ 1/7 ≈ 0.143.

**Impact**: If true, this provides a practical recipe for building NTSHA into a full hash function with standard security properties. The number of rounds needed (logarithmic in p) is efficient. If false, it identifies a fundamental barrier to tropical hash avalanche, suggesting that fundamentally different mixing strategies are needed.

**Catalog References**: `Shared/NTSHACore.lean` (avalancheDeficiency, avalancheDeficiency_bounded)

**Proof Strategy**: (1) Define multi-round NTSHA formally. (2) Analyze the probability that the minimizing index changes between rounds. (3) Show that after r rounds, the probability that no round changes the minimizer is ≤ (1 - 1/k)^r, and for r = Θ(k log p), this is ≤ 1/p.

**Domain Bridges**: Tropical Algebra ↔ Symmetric Cryptography ↔ Dynamical Systems

**Lineage**: Builds on avalancheDeficiency_bounded and the computational avalanche analysis from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Fiber Varieties and Intersection Theory

**Conjecture**: The boundary of the region where NTSHA_p(m, 0) = y (within the fundamental domain {0,...,p-1}^k) is a tropical hypersurface of degree k-1, and the number of vertices of this tropical variety equals the Eulerian number A(k-1, y). This would connect NTSHA fiber geometry to the combinatorics of permutations.

**Test**: For k = 3, p = 7, enumerate the boundary cells of each fiber region in {0,...,6}³ and count vertices. Compare with Eulerian numbers A(2, 0) = 1, A(2, 1) = 1. For k = 4, compare vertex counts with A(3, y) = 1, 4, 1.

**Impact**: A connection between NTSHA fiber geometry and Eulerian numbers would establish a deep link between tropical cryptography and enumerative combinatorics. It would also provide tools from tropical intersection theory for analyzing hash collision structure.

**Catalog References**: `Tropical/MinPlusAlgebra.lean`, `Shared/NTSHAFiber.lean` (ntshaFiberSize_antitone)

**Proof Strategy**: (1) Define the "tropical fiber variety" as the closure of the boundary between adjacent fiber regions. (2) Show this is a tropical hypersurface by exhibiting it as the tropical zero locus of a tropical polynomial. (3) Count vertices using the duality between tropical varieties and regular subdivisions of Newton polytopes.

**Domain Bridges**: Tropical Geometry ↔ Enumerative Combinatorics ↔ Cryptographic Hash Design

**Lineage**: Builds on ntsha_locally_determined (which identifies the piecewise-linear structure) from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: NTSHA over Tropical Matrix Groups

**Conjecture**: Define matrix NTSHA as M-NTSHA_p(M, H) = min_{i,j}((M_{ij} + H_{ij}) mod p) for n×n matrices M, H with entries in ℤ. The preimage fiber of M-NTSHA is invariant under (pℤ)^{n²} and the fiber size formula generalizes to S_p(y, n²). However, the *algebraic* structure of the matrix preimage fiber — when restricted to matrices with tropical rank ≤ r — has smaller fiber size bounded by O(p^{r(2n-r)} · S_p(y, r(2n-r))), connecting to the tropical Grassmannian.

**Test**: For n = 3, p = 5, enumerate 3×3 matrices with tropical rank ≤ 2 in {0,...,4}^{3×3} and verify the fiber size formula. Compare with the tropical Grassmannian dimension prediction.

**Impact**: Extending NTSHA to matrices would create a much richer cryptographic primitive where the tropical rank adds an additional security parameter. If the fiber size depends on tropical rank, this would provide a quantitative connection between algebraic complexity and cryptographic hardness.

**Catalog References**: `Tropical/MinPlusAlgebra.lean` (tropMatMul, tropMatMul_assoc), `Cryptography/TropicalOneWayFoundations.lean`

**Proof Strategy**: (1) Define M-NTSHA and prove basic properties (range, periodicity) by direct analogy with scalar NTSHA. (2) Define tropical rank for matrices over ℤ/pℤ. (3) Analyze fiber sizes restricted to rank-bounded matrices using the tropical Grassmannian structure.

**Domain Bridges**: Tropical Geometry ↔ Matrix Cryptography ↔ Algebraic Complexity Theory

**Lineage**: Builds on ntsha_fiber_lattice_invariance and ntshaFiberSize_sum from this cycle, plus tropMatMul from the Catalog.

**Ambition**: extension
