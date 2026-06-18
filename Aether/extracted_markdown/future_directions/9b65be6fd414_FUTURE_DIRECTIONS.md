# Future Directions: Berggren Lattice Cryptography

## Breakthrough Opportunities (Ranked by Impact)

### 1. Berggren Path-Finding Hardness Reduction

**Theorem Statement**: For all n ≥ 3, there exists a polynomial-time reduction from factoring n-bit integers to finding the Berggren path from (3,4,5) to a target triple (a,b,c) with c ≡ 0 (mod n).

**Proof Strategy**:
- **Approach A**: Given n = pq, construct target triple via Euclid parametrization (m,n) = (p, q). The Berggren path encodes the continued fraction expansion of p/q, and recovering this expansion yields p and q.
- **Approach B**: Reduce to the word problem in the Berggren group (a finitely presented subgroup of O(2,1;ℤ)). The word problem for arithmetic groups in non-positive curvature is known to be hard.
- **Key Lemma**: `berggren_path_encodes_cf` — the Berggren path from root to Euclid(m,n) corresponds to the continued fraction [m/n].

**Why Revolutionary**: Would establish the first lattice-based cryptographic hardness assumption rooted purely in classical number theory (Pythagorean triples), rather than in worst-case lattice problems.

**Catalog Leverage**: `berggren_childA`, `berggren_childB`, `berggren_childC`, `matA_mul_inv`, `matB_mul_inv`, `matC_mul_inv`

**Research Mode**: prove
**Estimated Depth**: 5

---

### 2. Quantum Lower Bound via Hyperbolic Volume Growth

**Theorem Statement**: Any bounded-error quantum algorithm solving Berggren-SVP on the depth-d lattice requires Ω(3^{d/6}) queries, where the lower bound comes from the exponential volume growth of hyperbolic space.

**Proof Strategy**:
- **Approach A**: Apply the adversary method (Ambainis 2002). The key input: Berggren paths of length d form an exponentially large set (3^d elements) in a space with negative curvature, where geodesic divergence prevents efficient quantum interference.
- **Approach B**: Reduce to the non-abelian hidden subgroup problem for the Berggren group. The group's non-abelian structure (proved: AB ≠ BA) blocks standard quantum Fourier sampling.

**Why Revolutionary**: Would give the first quantum lower bound for a lattice problem derived from number-theoretic structure, as opposed to worst-case complexity assumptions.

**Catalog Leverage**: `berggren_nonabelian`, `pow3_ge_pow2`, `berggren_128bit_security`

**Research Mode**: prove
**Estimated Depth**: 5

---

### 3. Berggren Lattice Signatures

**Theorem Statement**: There exists a signature scheme where signing requires knowledge of a Berggren path (computable in O(d) matrix multiplications) and verification checks Lorentz invariance (computable in O(1) field operations), with unforgeability reducing to Berggren-SVP.

**Proof Strategy**:
- **Approach**: Define Sign(sk, m) = pathMatrix(sk) · Hash(m) where Hash maps messages to light-cone vectors. Verification checks Q(σ) = 0 and ‖σ‖ ≤ bound. Forging requires finding a short path — i.e., solving SVP.
- **Key Lemma**: The Lipschitz bound ‖Mv‖² ≤ 35·‖v‖² ensures signatures have bounded length.

**Why Revolutionary**: Would give a signature scheme with algebraic structure (Lorentz group) enabling efficient batch verification, unlike generic lattice signatures.

**Catalog Leverage**: `berggren_lipschitz_bound`, `lorentzNorm_step_invariant`, `depth1_lattice_volume`

**Research Mode**: prove
**Estimated Depth**: 4

---

### 4. Higher-Dimensional Berggren Lattices via O(n,1)

**Theorem Statement**: For each n ≥ 2, the group O(n,1;ℤ) acts on the integer light cone Q(x₁,...,x_{n+1}) = x₁² + ... + x_n² - x_{n+1}² = 0, generating lattices of rank (n+1) with Minkowski-bounded shortest vectors.

**Proof Strategy**:
- Generalize the Berggren matrices from O(2,1;ℤ) to O(n,1;ℤ) using Vinberg's algorithm for reflection groups.
- Prove the analog of `lorentz_product_preservation` for general signature (n,1).
- Establish that det = ±1 and the Frobenius norm scales as O(n²).

**Why Revolutionary**: Higher-dimensional Berggren lattices provide a parameterized family of lattice problems with explicit geometric structure, potentially yielding tighter security proofs.

**Catalog Leverage**: `lorentz_product_preservation`, `berggren_uniform_frobenius`

**Research Mode**: discover
**Estimated Depth**: 4

---

### 5. Tropical Berggren Certified Robustness

**Theorem Statement**: For a ReLU neural network with L layers and width w, if the weight matrices are Berggren matrices, then the network has certified robustness radius δ = ε / (35^{L/2}) where ε is the classification margin.

**Proof Strategy**:
- Use the Lipschitz bound ‖Mv‖² ≤ 35·‖v‖² iterated L times to get ‖f(x) - f(x')‖ ≤ 35^{L/2} · ‖x - x'‖.
- The tropical analog max(a,b) - c provides the margin ε.
- Combine to get certified radius δ = ε / 35^{L/2}.

**Why Revolutionary**: Gives the first certified robustness bound derived from number-theoretic structure, with explicit constants (35 = Frobenius norm²).

**Catalog Leverage**: `berggren_lipschitz_bound`, `tropical_triangle_ineq`, `berggren_uniform_frobenius`

**Research Mode**: prove
**Estimated Depth**: 3

---

## Under-Explored Territory

### Berggren Group Theory
The Berggren matrices generate a subgroup of O(2,1;ℤ). Key questions:
- Is this subgroup of finite or infinite index?
- What is its presentation (generators and relations)?
- Does it contain all of SO(2,1;ℤ)?

### Spectral Theory of Berggren Matrices
We proved traces and Frobenius norms. Missing:
- Exact eigenvalues (roots of characteristic polynomial)
- Spectral radius bounds
- Connection to Selberg eigenvalue conjecture

### Berggren Tree Combinatorics
- Height function: prove that the hypotenuse of Berggren nodes grows monotonically along every path (partially done for depth 1)
- Counting: how many nodes have hypotenuse ≤ N? (Connects to prime counting)
- Distribution: are Berggren paths equidistributed in the Lorentz group?

## Cross-Domain Bridges

### Bridge 1: Berggren × Modular Forms
The group O(2,1;ℤ) acts on the upper half-plane model of hyperbolic geometry. Berggren lattice automorphic forms would be modular forms of weight 1 for a congruence subgroup. The Hecke eigenvalues should connect to the lengths of Berggren paths.

### Bridge 2: Berggren × Tropical Geometry × Neural Networks
The tropical Berggren tree (replacing + with max, × with +) defines a tropical curve whose dual subdivision gives the architecture of a piecewise-linear neural network. The Berggren Lipschitz bound becomes the Lipschitz constant of this network.

### Bridge 3: Berggren × Algebraic K-Theory
The Berggren group, as a subgroup of GL(3,ℤ), contributes to the algebraic K-group K₁(ℤ). The determinant map det: K₁(ℤ) → ℤ* restricts to the Berggren determinant trichotomy (+1, -1, +1).

## Open Problems Encountered

1. **Berggren primitivity propagation**: We did not formalize the proof that Berggren steps preserve primitivity (gcd = 1), though this is proved in the existing catalog. Formalizing it requires the inverse map and divisibility arguments.

2. **Exact SVP solution**: We proved lower bounds (normSq ≥ 338) but not that this is achieved. Proving the exact SVP solution requires showing (5,12,13) is the unique shortest vector.

3. **Path length vs. norm**: We conjecture that the norm of berggrenPathVec(path) grows as O(C^{|path|}) for some constant C > 1. The Lipschitz bound gives C ≤ √35, but the true constant should be smaller (related to the spectral radius).

4. **Commutativity conditions**: For the key exchange to be correct, we need Alice's and Bob's path matrices to commute. Characterizing when pathMatrix(π₁) · pathMatrix(π₂) = pathMatrix(π₂) · pathMatrix(π₁) is an open algebraic problem.

5. **Tropicalization functor**: We defined the tropical Lorentz form but did not prove it's functorial — that is, tropicalization commutes with Berggren matrix application. This requires defining tropical matrix multiplication.
