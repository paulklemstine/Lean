# Future Directions: Diophantine Cryptography Research Roadmap

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

## Under-explored Territory

### Berggren Matrices as Möbius Transformations
The Berggren matrices act on the upper half-plane via Möbius transformations. The connection between the Berggren tree and the modular group PSL₂(ℤ) is largely unexplored in the formal setting. This could connect to:
- Modular forms and L-functions
- Hyperbolic geometry and the Farey tessellation
- Hecke operators and spectral theory

### Non-commutative Cryptography
The Berggren monoid is free and non-commutative. This suggests connections to:
- Braid group cryptography
- Non-commutative lattice problems  
- Conjugacy search problems

### Berggren Dynamics and Ergodic Theory
The map from triples to their Berggren parent defines a dynamical system. Questions:
- What is the invariant measure?
- Does equidistribution hold for the Berggren tree?
- What is the entropy of the descent map?

## Cross-Domain Bridges

### Berggren ↔ Tropical Geometry
- The Berggren tree admits a tropical metric (ultrametric from tree distance)
- Tropical Pythagorean triples: min(a,b) = c in the tropical semiring
- Conjectured: the tropical Berggren tree is a tropical curve of genus 0

### Berggren ↔ Quantum Computing
- The Minkowski form Q(a,b,c) = a² + b² - c² defines a quantum observable
- Berggren matrices are elements of O(2,1;ℤ), which embeds into SU(1,1)
- Conjectured: Berggren word evaluation can be implemented as a quantum circuit of depth O(k)

### Berggren ↔ Neural Network Certification
- The Lipschitz constant of the Berggren map (word → triple) is bounded by the spectral norm
- This could provide certified robustness bounds for networks operating on Pythagorean-structured data
- The quadratic form provides a natural loss function with verified properties

## Open Problems Encountered

### Problem 1: Exact Exponential Growth Rate
We proved hyp ≥ 5 + 2k (linear), but computational evidence suggests hyp ≥ C · φ^k where φ = (1+√5)/2 is the golden ratio. The exact growth rate depends on the eigenvalues of the Berggren matrices, which involve algebraic numbers of degree 3.

### Problem 2: Modular Image Size
For prime p, how large is the image of H_p restricted to words of length ≤ k? We conjecture |Im(H_p|_{≤k})| ≥ min(3^k, p²/9) but proving the second bound requires showing the Berggren subgroup of GL₃(ℤ/pℤ) acts transitively on a large subset of (ℤ/pℤ)³.

### Problem 3: Children Hypotenuse Distinctness
We proved that distinct generators yield distinct children (via generator uniqueness), but the stronger statement — that the hypotenuses are also distinct — requires proving that a = b is impossible for Pythagorean triples (equivalent to irrationality of √2). This is true but requires a different proof technique than nlinarith.

### Problem 4: Berggren Surjectivity
The classical theorem of Hall (1970) states that the Berggren tree generates *all* primitive Pythagorean triples. Formalizing this requires:
- A characterization of primitive triples via the Euclid parametrization
- Showing every primitive triple has a Berggren parent
- Establishing the well-foundedness of the descent

This is a substantial formalization effort (estimated depth 5).
