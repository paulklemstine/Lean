# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-09 08:24*

## Breakthrough Opportunities (ranked by impact)

### 1. Exponential Growth Bound for Berggren Word Products

- **Theorem Statement**: ∃ C > 0, ∀ w : BWord, w.length > 0 → BWordTriple w 2 ≥ C · 3^(w.length / 2)
- **Proof Strategy**:
  - Approach A (Eigenvalue analysis): Each Berggren matrix has spectral radius ≥ √3. Prove that ‖U_w · v‖ ≥ (√3)^k · ‖v‖ for words of length k, using submultiplicativity of norms.
  - Approach B (Component tracking): Track the minimum of (a+b+c) across applications. Show each generator maps (a+b+c) → (a'+b'+c') with a'+b'+c' ≥ 3(a+b+c) - O(c).
  - Approach C (Recursive bounds): Establish recurrences for the minimum hypotenuse at each depth and solve them.
- **Why This Is Revolutionary**: Upgrades the linear growth bound (5+2k) to exponential (C·3^(k/2)), giving a tight security parameter for the one-way function. This would establish that brute-force inversion requires Ω(3^(k/2)) operations.
- **Catalog Leverage**: Build on `berggren_hyp_linear_growth`, `berggren_hyp_increase_by_two`, `berggren_word_pos_pyth`
- **Research Mode**: prove
- **Estimated Depth**: 3

### 2. ε-Almost Universality of the Berggren Hash Family

- **Theorem Statement**: ∀ p prime ≥ 5, ∀ w₁ ≠ w₂ with |w₁| = |w₂| ≤ k, Pr_{p random}[H_p(w₁) = H_p(w₂)] ≤ 3k/p
- **Proof Strategy**:
  - Use `collision_nonzero_difference` to establish T(w₁) - T(w₂) ≠ 0 over ℤ.
  - Bound the number of prime factors of each component of the difference vector using the exponential growth bound.
  - Apply the Schwartz-Zippel-type argument: a nonzero integer of magnitude M has at most log(M)/log(p) prime factors ≥ p.
- **Why This Is Revolutionary**: Establishes concrete ε-universality with explicit ε, enabling provable security reductions for Berggren-based MACs and commitments.
- **Catalog Leverage**: Build on `berggren_collision_mod_p`, `collision_nonzero_difference`, `berggren_word_pythagorean`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 3. Tropical Ultrametric on the Berggren Tree

- **Theorem Statement**: Define d(x,y) = depth(LCA(x,y)) for triples x,y in the Berggren tree. Then d satisfies the ultrametric inequality: d(x,z) ≤ max(d(x,y), d(y,z)).
- **Proof Strategy**:
  - Formalize the lowest common ancestor (LCA) using prefix operations on Berggren words.
  - Use `berggren_word_action_free` to show the LCA is well-defined and unique.
  - The ultrametric inequality follows from the tree structure: any three nodes form an isoceles triangle in the tree metric.
- **Why This Is Revolutionary**: Connects Diophantine cryptography to tropical geometry, opening a bridge to min-plus algebra, tropical Hodge theory, and tropical curve counting.
- **Catalog Leverage**: Build on `berggren_word_action_free`, `BWordMatrix_append`, `berggren_fixed_length_injective`
- **Research Mode**: prove
- **Estimated Depth**: 2

### 4. Berggren Lattice and SIS Reduction

- **Theorem Statement**: For prime p, the lattice L_p = {v ∈ ℤ³ : ∃ w, U_w · (3,4,5)ᵀ ≡ v (mod p)} is a sublattice of ℤ³ with determinant dividing p³.
- **Proof Strategy**:
  - Show L_p is closed under ℤ-linear combinations (it's the image of a group homomorphism).
  - Compute the index [ℤ³ : L_p] using the Smith normal form of the reduction map.
  - Relate finding short vectors in L_p to the SIS (Short Integer Solution) problem.
- **Why This Is Revolutionary**: Provides a formal reduction from Berggren hash inversion to established post-quantum lattice problems, enabling hybrid security proofs.
- **Catalog Leverage**: Build on `berggren_collision_mod_p`, `BWordMatrix_append`, `berggren_word_matrix_isUnit`
- **Research Mode**: prove
- **Estimated Depth**: 4

### 5. Primitivity Preservation Under Berggren Action

- **Theorem Statement**: ∀ w : BWord, gcd(BWordTriple w 0, BWordTriple w 1, BWordTriple w 2) = 1
- **Proof Strategy**:
  - Approach A: Use the quadratic form invariance and det = ±1 to show primitivity is preserved.
  - Approach B: Direct induction, checking that each generator maps primitive triples to primitive triples.
  - Key lemma: If gcd(a,b,c) = 1 and a² + b² = c², then gcd(U_i · (a,b,c)) = 1.
- **Why This Is Revolutionary**: Completes the classification: Berggren words generate exactly the primitive Pythagorean triples, not just Pythagorean triples.
- **Catalog Leverage**: Build on `berggren_word_pythagorean`, `berggren_word_pos_pyth`, `berggren_det_isUnit`
- **Research Mode**: prove
- **Estimated Depth**: 3