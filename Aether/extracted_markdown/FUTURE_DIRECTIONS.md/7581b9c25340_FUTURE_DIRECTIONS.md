# Future Directions: Post-Idempotent Cryptography Research Roadmap

## Breakthrough Opportunities (ranked by impact)

### 1. Tropical LP NP-Completeness (Full Reduction)

**Theorem Statement**: For every 3-SAT instance φ on n variables with m clauses, there exists a tropical LP instance (A_φ, b_φ) of dimensions m × 2n such that φ is satisfiable if and only if ∃ x ∈ ℤ^{2n}, A_φ ⊗ x ≤ b_φ. The reduction is computable in O(mn) time.

**Proof Strategy**:
1. Encode each Boolean variable v_j as a pair (x_{2j}, x_{2j+1}) with the constraint that exactly one is 0 and the other is -1 (representing true/false).
2. For each clause (ℓ₁ ∨ ℓ₂ ∨ ℓ₃), construct a row of A where the "positive" literal columns have coefficient 0 and all others have coefficient -2.
3. Set b = 0 for all rows. A clause is satisfied iff at least one literal's variable contributes a non-negative term, making the max ≥ 0.
4. Key lemma: `clause_sat_iff_tropical_ineq` — satisfaction of clause c by assignment v ↔ the corresponding tropical inequality holds for boolToTropical(v).
5. Compose over all clauses using induction on the clause list.

**Why This Is Revolutionary**: Establishes the first formal proof linking tropical feasibility to NP-completeness, providing a rigorous foundation for claiming OWF hardness. Opens the door to formal complexity-theoretic security proofs.

**Catalog Leverage**: Build on `boolToTropical_injective`, `tropical_weak_duality`, `owf_inversion_implies_lp_feasible`.

**Research Mode**: prove
**Estimated Depth**: 4/5

---

### 2. Tropical Lattice-Based Key Exchange

**Theorem Statement**: Define a tropical lattice Λ ⊂ ℤ^n as the set of integer solutions to A ⊗ x = A ⊗ x (fixed under tropical multiplication by A). The Tropical Shortest Vector Problem (finding the shortest non-zero vector in Λ under L∞ norm) reduces to tropical LP feasibility.

**Proof Strategy**:
1. Define `TropicalLattice (A : Matrix (Fin m) (Fin n) ℤ) := {x : Fin n → ℤ | A ⊗ x = A ⊗ 0 + offset}`.
2. Show that finding a short vector reduces to bounded tropical LP: A ⊗ x ≤ b with |x_j| ≤ B.
3. The key exchange protocol: Alice picks secret x_A, publishes A ⊗ x_A. Bob picks secret x_B, publishes A ⊗ x_B. Shared secret is derived from the tropical scalar product.
4. Security reduces to tropical SVP via standard lattice-to-SVP reductions adapted to the max-plus setting.

**Why This Is Revolutionary**: Creates a tropical analogue of LWE-based cryptography where the hardness assumption is NP-hard (via Theorem 1), not merely conjectured hard. This would be the first cryptosystem with provable worst-case hardness in the post-quantum setting.

**Catalog Leverage**: Build on `TropicalLPInstance`, `tropicalMVP_mono`, `tropical_lp_feasible_mono`.

**Research Mode**: formalize
**Estimated Depth**: 5/5

---

### 3. Certified ReLU Network Robustness via Tropical Geometry

**Theorem Statement**: For a feedforward ReLU network f: ℝ^n → ℝ^m with weight matrices W₁, ..., W_L and biases b₁, ..., b_L, the Lipschitz constant of f in the L∞ norm satisfies Lip(f) ≤ ∏ᵢ ‖Wᵢ‖_{∞→∞}. Moreover, for any input x and perturbation δ, |f(x+δ) - f(x)|_∞ ≤ Lip(f) · |δ|_∞.

**Proof Strategy**:
1. Formalize that ReLU(x) = max(0, x) is a tropical addition operation.
2. Use `tropical_max_lipschitz` to establish that each ReLU layer is 1-Lipschitz.
3. Show that each affine layer x ↦ W·x + b has Lipschitz constant ‖W‖_{∞→∞}.
4. Compose Lipschitz constants across layers using the chain rule.
5. The certified robustness radius is ε = (classification margin) / Lip(f).

**Why This Is Revolutionary**: Provides machine-verified certificates for neural network robustness. Current certified robustness tools (e.g., CROWN, α-CROWN) use floating-point computation and lack formal guarantees. A Lean 4 formalization would provide the gold standard.

**Catalog Leverage**: Build on `tropical_max_lipschitz`, `tropMVP_lipschitz_linf` (to be proved), `tropicalMVP_mono`.

**Research Mode**: formalize
**Estimated Depth**: 3/5

---

### 4. Idempotent Quantum Error Correction Obstruction

**Theorem Statement**: No quantum error-correcting code can protect a logical qubit encoded using idempotent operations. Specifically, if the encoding map E satisfies E² = E (idempotent), then E is a projection and the code distance is at most 1.

**Proof Strategy**:
1. Use `idempotent_eigenvalue_binary` to show the encoding map has eigenvalues in {0, 1}.
2. Show that a projection with eigenvalues {0, 1} divides the Hilbert space into protected and unprotected subspaces.
3. The code distance d is bounded by the dimension of the kernel: if dim(ker E) ≥ n-1, then d ≤ 1.
4. Conclude that idempotent encodings cannot correct even single-qubit errors.

**Why This Is Revolutionary**: Extends the quantum obstruction from algorithms (Grover) to error correction, showing that idempotent structure is fundamentally incompatible with quantum fault tolerance.

**Catalog Leverage**: Build on `idempotent_eigenvalue_binary`, `unitary_idem_identity`, `idempotent_trace_invariant`.

**Research Mode**: prove
**Estimated Depth**: 3/5

---

### 5. Tropical Signature Scheme

**Theorem Statement**: Define a tropical signature scheme where signing requires solving a tropical equation A ⊗ x = h(m) (where h is a hash function and m is the message) and verification checks that A ⊗ σ = h(m). Existential unforgeability under chosen message attack reduces to the hardness of tropical LP feasibility.

**Proof Strategy**:
1. Key generation: random matrix A, secret key is a collection of pre-solved equations.
2. Signing: for message m, find x such that A ⊗ x = h(m) using the secret key.
3. Verification: check A ⊗ σ = h(m) in O(mn) time.
4. Security: forging a signature for a new message requires solving a new tropical equation, which reduces to tropical LP.

**Why This Is Revolutionary**: Would provide the first digital signature scheme with security based on tropical hardness assumptions, complementing existing lattice-based and code-based signatures.

**Catalog Leverage**: Build on `TropicalOWFInstance`, `owf_inversion_implies_lp_feasible`, `boolToTropical_injective`.

**Research Mode**: formalize
**Estimated Depth**: 4/5

---

## Under-explored Territory

### Tropical Convex Geometry
- `tropicallyBetween` is defined but few deep theorems about tropical polytopes exist
- The tropical analogue of the simplex method is unexplored in our formalization
- Connection: tropical polytopes ↔ scheduling problems ↔ algorithmic game theory

### Idempotent Semimodule Theory
- We define `IdempotentSemiring` and `IdempotentAdd` but don't develop the module theory
- Tropical semimodules over idempotent semirings are the natural setting for tropical linear algebra
- Connection: semimodule homomorphisms ↔ tropical linear maps ↔ ReLU network layers

### Composition of Tropical One-Way Functions
- We prove idempotent compositions preserve idempotency when commutative
- Open: what happens with non-commutative compositions?
- Connection: tropical matrix semigroups ↔ iterated function systems ↔ fractal geometry

## Cross-Domain Bridges

### Tropical Algebra ↔ Neural Networks
- **Existing**: `tropical_max_lipschitz` proves 1-Lipschitz property of max
- **Needed**: Formalize that feedforward ReLU networks are tropical rational functions
- **Conjecture**: The decision boundary of a ReLU network is a tropical hypersurface, and its complexity (number of linear regions) equals the tropical degree

### Tropical Algebra ↔ Thermodynamics
- **Existing**: The idempotent law x ⊕ x = x is the "tropical free energy" principle
- **Needed**: Formalize the Maslov dequantization: classical mechanics is the tropical limit (ℏ → 0) of quantum mechanics
- **Conjecture**: The tropical OWF hardness is related to the thermodynamic irreversibility of the max operation (entropy increase)

### Cryptography ↔ Optimization
- **Existing**: Tropical LP feasibility reduces OWF inversion
- **Needed**: Formalize the dual tropical LP and strong duality
- **Conjecture**: The tropical LP dual gap provides a lower bound on the number of oracle queries needed for inversion

## Open Problems Encountered

### Problem 1: Tropical LP Strong Duality
We conjecture that tropical LP duality holds in a suitable sense, but the classical LP duality proof does not directly transfer because the max-plus semiring lacks additive inverses.

### Problem 2: Non-Injectivity of Tropical MVP
We stated `tropicalMVP_non_injective_of_tall` but did not prove it. The pigeonhole argument is complicated by the fact that tropical MVP is piecewise linear over ℤ, making simple counting arguments insufficient. A proof likely requires understanding the structure of tropical preimages as solutions to max-plus systems.

### Problem 3: Practical Security Parameters
While we prove n² < 2^n for n ≥ 7, determining the minimum n for 128-bit security against the best known tropical LP algorithms requires understanding the actual complexity of tropical feasibility algorithms, which is beyond our current formalization.

### Problem 4: Side-Channel Resistance
The max operation involves conditional branches (comparisons), which may leak information through timing side channels. Formalizing constant-time implementations of tropical operations would require a computational model with timing semantics.
