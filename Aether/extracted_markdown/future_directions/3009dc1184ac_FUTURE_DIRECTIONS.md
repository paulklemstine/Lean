# Future Directions: Berggren Tree Cryptographic Infrastructure

## Breakthrough Opportunities (ranked by impact)

### 1. Full Berggren Injectivity via Parent Recovery

- **Theorem Statement**: `∀ t : PrimTriple, t ≠ rootTriple → ∃! (p : PrimTriple) (s : BerggrenStep), actOnTriple s p = t ∧ p.c < t.c`
- **Proof Strategy**: 
  1. Define inverse branch maps by computing the three matrix inverses (possible since det = ±1)
  2. Show exactly one inverse produces a triple with all-positive components
  3. Prove hypotenuse strictly decreases under the inverse
  4. Conclude unique descent to root by well-founded induction on hypotenuse
- **Why This Is Revolutionary**: Establishes the Berggren tree as a canonical normal form for ALL primitive Pythagorean triples, not just those reachable from bounded-depth words. This converts a classical number-theory result into machine-verified infrastructure.
- **Catalog Leverage**: Builds on `step_preserves_pos`, `hyp_strictly_increases`, `berggren_step_det_unit`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 2. Arithmetic Hash Families from Berggren Encodings

- **Theorem Statement**: `∀ N, ∃ (H : BerggrenWord → ZMod p), collision_resistant H N` where collision resistance is formalized as a minimum-distance lower bound
- **Proof Strategy**:
  1. Define hash as `H(w) = berggrenEvalVec(w).c mod p` for suitable prime p
  2. Use `hyp_depth_bound` to show distinct words at different depths never collide
  3. Use `berggren_children_distinct` to handle same-depth separation
  4. Derive collision probability bounds from counting arguments
- **Why This Is Revolutionary**: Creates the first formally verified arithmetic hash family with provable collision bounds derived from Diophantine geometry.
- **Catalog Leverage**: `berggren_children_distinct`, `hyp_depth_bound`, `depth1_separation`
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 3. Spectral Analysis of Berggren Adjacency Operator

- **Theorem Statement**: The adjacency operator on the Berggren tree (restricted to depth N) has spectral gap ≥ f(N) for explicit f
- **Proof Strategy**:
  1. Define the depth-N adjacency matrix as a Fintype-indexed matrix
  2. Use hypotenuse growth bounds to control matrix entries
  3. Apply Perron-Frobenius or direct eigenvalue estimates
- **Why This Is Revolutionary**: Connects Berggren tree structure to random-walk mixing, enabling quantum-walk algorithms on arithmetic trees.
- **Catalog Leverage**: `berggrenEvalVec_pos`, `berggren_word_det`
- **Research Mode**: formalize
- **Estimated Depth**: 5

### 4. Tropical Embedding of Berggren Lattice

- **Theorem Statement**: `∃ φ : PrimTriple →+* TropicalSemiring ℤ, ∀ s t, φ (actOnTriple s t) = tropicalStep s (φ t)`
- **Proof Strategy**:
  1. Map (a,b,c) to the tropical triple (log a, log b, log c)
  2. Show Berggren matrix action becomes tropical linear
  3. Derive tropical collision bounds from integer separation
- **Why This Is Revolutionary**: Bridges Diophantine geometry to tropical algebraic geometry, opening connections to optimization and neural network theory.
- **Catalog Leverage**: `step_preserves_pyth`, coordinate formulas
- **Research Mode**: discover
- **Estimated Depth**: 4

### 5. Quantum Walk on Bounded Berggren Tree

- **Theorem Statement**: `∀ N (ψ : QuantumBerggrenState N), norm_sq (walk_step ψ) = norm_sq ψ` where `walk_step` is a quantum walk operator
- **Proof Strategy**:
  1. Define the quantum walk step as a sum of shift operators over BerggrenStep
  2. Use `prependBounded_injective` to show each shift is an isometry
  3. Prove the combined operator preserves norm via orthogonality
- **Why This Is Revolutionary**: First formal quantum walk on an arithmetic structure with provable norm preservation, enabling quantum search algorithms on number-theoretic trees.
- **Catalog Leverage**: `prependBounded_injective`, `basis_orthogonality`, `basisState`
- **Research Mode**: formalize
- **Estimated Depth**: 3

## Under-explored Territory

1. **Coprimality preservation**: We proved positivity and Pythagorean preservation but not coprimality preservation under Berggren action. This requires modular arithmetic arguments (gcd(a', b') = 1 when gcd(a, b) = 1).

2. **Exponential hypotenuse growth**: We proved linear growth (5 + depth). The actual growth is exponential with base ≈ 2.62 (the Perron root of certain companion matrices). Formalizing this requires eigenvalue analysis.

3. **Counting theorems**: How many primitive triples have hypotenuse ≤ N? The answer is asymptotically N/(2π), and the Berggren tree gives a constructive proof. Formalizing the asymptotics would connect to analytic number theory.

## Cross-Domain Bridges

1. **Berggren → Post-Quantum Crypto**: The injectivity + hypotenuse growth gives a concrete one-way function. Formalizing its security under standard complexity assumptions would create a new cryptographic primitive.

2. **Berggren → Machine Learning**: The Lipschitz bounds on evaluation (bounded L1 change under word perturbation) connect to certified robustness in adversarial ML. The Berggren tree could serve as a provably robust feature map.

3. **Berggren → Physics**: Pythagorean triples parametrize rational points on the unit circle, which connects to angular momentum quantization. The Berggren tree gives a canonical enumeration with quantum-mechanical structure.

## Open Problems Encountered

1. Whether the minimum L1 separation at depth N grows linearly, polynomially, or exponentially with N
2. Whether there exists a polynomial-time algorithm to recover the Berggren word from a triple (without the trapdoor)
3. The exact spectral radius of the 3-step Berggren Markov chain on the tree
4. Whether tropical Berggren embeddings admit efficient decoding
