# Future Directions: Berggren Minor Trapdoors

## Breakthrough Opportunities (ranked by impact)

### 1. Full Berggren Tree Uniqueness Theorem

- **Theorem Statement**: For all words `w₁ w₂ : BerggrenWord`, if `packetOfWord w₁ = packetOfWord w₂` then `w₁ = w₂`. (Currently stated as `GlobalBerggrenWordInjectivity` conjecture.)
- **Proof Strategy**:
  - (a) Show that each generator maps triples into disjoint "sectors" characterized by sign patterns of `x + 2y - 2z`, `2x + y - 2z`.
  - (b) Prove that the inverse generator identification function `identifyGenerator` correctly recovers the last-applied generator for any non-root triple in the orbit.
  - (c) Use strong induction on hypotenuse (`thirdCoord`) combined with `evalGen_hypotenuse_growth` to show unique ancestry.
- **Why This Is Revolutionary**: Would upgrade the conditional collision resistance theorems to unconditional ones, completing the toy post-quantum cryptographic primitive.
- **Catalog Leverage**: Build on `evalGen_hypotenuse_growth`, `evalGenInv_left_inverse`, `no_return_to_root`.
- **Research Mode**: prove
- **Estimated Depth**: 3

### 2. Genuine Matrix Minor Profiles from SL(3,ℤ)

- **Theorem Statement**: Define `matrixOfGen : BerggrenGenerator → Matrix (Fin 3) (Fin 3) ℤ` and `matrixOfWord : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ` with `matrixOfWord (u ++ v) = matrixOfWord v * matrixOfWord u`. Extract genuine 2×2 submatrix minors and prove they form a richer invariant than the current synthetic minor profile.
- **Proof Strategy**:
  - Define the three Berggren matrices explicitly as `!![1,-2,2; 2,-1,2; 2,-2,3]` etc.
  - Prove `evalGen g t` equals the matrix-vector product `matrixOfGen g *ᵥ ![t.x, t.y, t.z]`.
  - Extract all nine 2×2 minors and analyze their injectivity/growth properties.
- **Why This Is Revolutionary**: Connects the toy model to genuine lattice theory, opening the door to lattice reduction attacks and security proofs.
- **Catalog Leverage**: `evalGen`, `evalGenInv_left_inverse`, `evalGenInv_right_inverse`.
- **Research Mode**: formalize
- **Estimated Depth**: 2

### 3. Average-Case Collision Exponents and Entropy Growth

- **Theorem Statement**: For a uniformly random word `w` of length `n`, the expected value of `log₂(thirdCoord(packetOfWord w))` grows as `Θ(n)` with explicit constants.
- **Proof Strategy**:
  - Compute the Lyapunov exponent of the Berggren random matrix product.
  - Use Furstenberg's theorem on products of random matrices to establish exponential growth a.s.
  - Derive entropy lower bounds for the minor profile distribution.
- **Why This Is Revolutionary**: Provides average-case security guarantees, not just worst-case, moving the toy model closer to a practical cryptographic primitive.
- **Catalog Leverage**: `evalGen_hypotenuse_growth`, `packetOfWord_nondegenerate`.
- **Research Mode**: formalize
- **Estimated Depth**: 4

### 4. Extension to Markov Triple Trees

- **Theorem Statement**: Define generators for the Markov tree (via Vieta involutions) and prove analogous orbit separation and parent uniqueness results.
- **Proof Strategy**:
  - The Markov tree has a different algebraic structure (quadratic relations vs. linear Pythagorean).
  - Define `MarkovGenerator`, `evalMarkov`, and analogous minor profiles.
  - Prove hypotenuse growth and parent uniqueness (the Markov uniqueness conjecture is open but proved for many cases).
- **Why This Is Revolutionary**: Extends the trapdoor paradigm to a new number-theoretic setting with connections to hyperbolic geometry, cluster algebras, and quantum Teichmüller theory.
- **Catalog Leverage**: General framework from `BerggrenMinorTrapdoors`.
- **Research Mode**: discover
- **Estimated Depth**: 5

### 5. Certified Robustness Interpretation for Arithmetic Hash Families

- **Theorem Statement**: For a family of hash functions `H_w(x) = minorProfile(evalWord w x)` parameterized by words `w`, prove Lipschitz bounds on the hash output as a function of input perturbation, with explicit constants depending on word length.
- **Proof Strategy**:
  - Each generator is a linear map, so `evalGen g` is Lipschitz with constant bounded by the operator norm of the Berggren matrix.
  - Compose Lipschitz bounds along the word to get `L^n` growth.
  - The minor profile extraction is itself Lipschitz (linear map).
- **Why This Is Revolutionary**: Provides a formal bridge between cryptographic hash families and certified robustness in ML verification, enabling dual-use mathematical infrastructure.
- **Catalog Leverage**: `evalGen_pythagorean`, `evalGen_positive`, `minorProfile_injective`.
- **Research Mode**: formalize
- **Estimated Depth**: 3

## Under-explored Territory

- **Tropical Berggren trees**: Replace integer arithmetic with tropical (min-plus) operations and study the resulting orbit structure.
- **p-adic Berggren dynamics**: Analyze the Berggren generators over ℤ_p and study p-adic convergence of orbits.
- **Quantum walk on Berggren tree**: Define a quantum walk on the tree and analyze its mixing time and spectral gap.

## Cross-Domain Bridges

- **Cryptography ↔ Hyperbolic geometry**: The Berggren tree is isomorphic to a Stern-Brocot-type tree, connecting to continued fractions and hyperbolic tessellations.
- **Lattice crypto ↔ Pythagorean number theory**: The pairwise-sum lattice decoding in our minor profile is a special case of the knapsack/subset-sum problem structure.
- **ML robustness ↔ Arithmetic dynamics**: Lipschitz bounds on Berggren word evaluation connect directly to certified perturbation analysis in neural network verification.

## Open Problems Encountered

1. **Sector classification**: Precisely characterizing which triples belong to the A, B, C sectors (needed for `identifyGenerator` correctness) requires careful case analysis of the inequalities `x + 2y > 2z`, `2x + y > 2z`.
2. **GCD preservation**: Proving that Berggren generators preserve `gcd(x,y) = 1` requires number-theoretic machinery (possibly `Int.gcd` manipulation with `Nat.Coprime` lemmas) that is somewhat unwieldy in current Mathlib.
3. **Exponential lower bound on hypotenuse**: Proving `2^n ≤ (packetOfWord w).z` for `w.length = n` requires careful analysis of the minimum hypotenuse growth factor across all generators, which varies (A and C grow less than B).
