# Future Directions: Galois Theory of Cellular Automata

## Synthesis

This cycle established the foundational algebraic framework for reversible cellular automata on periodic configurations: the **Centralizer = Reversibility theorem** reduces the study of reversible CAs to the centralizer of the shift permutation, and the **Prime Orbit Theorem** connects the orbit structure to Fermat's little theorem and necklace counting. The **Galois connection** between subgroups and fixed configurations, combined with the **discrete Liouville theorem**, reveals that the reversibility group governs both the symmetry structure and the information-theoretic properties of discrete dynamical systems.

The most promising cross-domain connection is the bridge between **cellular automata dynamics** and **representation theory**: the observable action theorem establishes a group representation of the reversibility group on ℝ^{|α|^n}, and the decomposition of this representation into irreducibles would connect CA dynamics to harmonic analysis on finite groups. This links to the Catalog's existing work on Galois obstruction theory (`Catalog/Algebra/GaloisObstruction`) and group-theoretic depth measures (`Catalog/Bridges/GaloisDeepLearning.lean`).

The cycle also revealed a computational pattern: the set of "universally reversible" elementary CA rules (reversible on all sufficiently large periods) is exactly {15, 51, 85, 170, 204, 240}, which corresponds to the 6 affine permutations of the 3-bit neighborhood. Understanding why affinity is the barrier to universal reversibility is a key open question.

---

### Direction 1: Character Theory of the Reversibility Group and Spectral Decomposition of CA Dynamics

**Conjecture**: The irreducible representations of Rev(n, {0,1}) over ℂ are indexed by the shift orbits (necklaces) of {0,1}^n, and the character of the observable representation decomposes as a sum over necklace types with multiplicities determined by the orbit sizes.

**Test**: For n = 3, compute the character table of Rev(3, {0,1}) (a group of order 36) and verify that the permutation representation on ℝ^8 decomposes into irreducibles corresponding to the 4 binary necklaces of length 3. The multiplicity of each irreducible should equal the number of orbits of the corresponding necklace type under the complement action.

**Impact**: If true, this would provide a complete "Fourier theory" for reversible CA dynamics — every observable decomposes into modes that transform independently under the reversibility group. This would enable spectral analysis of CA dynamics analogous to Fourier analysis on groups.

**Catalog References**: `Catalog/Geometry/CellularAutomataGalois.lean`, `Catalog/Bridges/GaloisDeepLearning.lean` (depth_from_group_order)

**Proof Strategy**: Use the Burnside lemma to count orbits of the action of Rev(n) on configurations. The permutation character is ∑ |Fix(g)|. Decompose using the orthogonality relations for characters. Key lemma needed: the centralizer of a cyclic permutation has a known character theory in terms of the cycle type.

**Domain Bridges**: Cellular Automata Dynamics ↔ Harmonic Analysis on Finite Groups ↔ Representation Theory

**Lineage**: Builds on Theorems 3.2 (Centralizer = Reversibility) and 8.1 (Observable Action) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Affinity Barrier for Universal Reversibility

**Conjecture**: An elementary CA rule (radius 1, binary) is "universally reversible" (reversible on ℤ/nℤ for all n ≥ 3) if and only if its local rule is an affine function over GF(2). Specifically, a local rule f : {0,1}³ → {0,1} is universally reversible iff f(x₁, x₂, x₃) = a₁x₁ + a₂x₂ + a₃x₃ + b (mod 2) for some a₁, a₂, a₃, b ∈ {0,1}.

**Test**: Verify computationally that the 6 universally reversible rules {15, 51, 85, 170, 204, 240} are exactly the affine functions on {0,1}³. Then prove in Lean that affine local rules induce bijective global maps on ℤ/nℤ for all n, and that non-affine rules fail to be bijective for some specific period.

**Impact**: If true, this explains the "affinity barrier" — the reason that exactly 6 out of 256 elementary rules survive the reversibility sieve. It would also generalize: for radius r, the universally reversible rules would be exactly the affine functions on {0,1}^{2r+1}, giving 2^{2r+2} universally reversible rules out of 2^{2^{2r+1}} total.

**Catalog References**: `Catalog/Geometry/CellularAutomataGalois.lean`, `Catalog/Algebra/Basic.lean`

**Proof Strategy**: Forward direction: show that affine maps over GF(2) induce linear maps on GF(2)^n, which are bijective iff the corresponding matrix has nonzero determinant; compute this determinant as a circulant. Backward direction: construct a specific period n where a non-affine rule fails injectivity by finding a collision.

**Domain Bridges**: Cellular Automata ↔ Linear Algebra over Finite Fields ↔ Circulant Matrices

**Lineage**: Builds on the computational sieve results from Demo 1 and the Centralizer Theorem.

**Ambition**: grand_challenge

---

### Direction 3: Quantum Cellular Automata and Unitary Reversibility Groups

**Conjecture**: The quantum analogue of the reversibility group — the group of shift-equivariant unitary operators on (ℂ^d)^{⊗n} — is a compact Lie group whose dimension equals n · (d² - 1) + 1 for d ≥ 2 and n ≥ 3.

**Test**: For d = 2 (qubits) and n = 3, the quantum reversibility group should be a subgroup of U(8) of dimension 10 = 3 · (4-1) + 1. Verify by computing the Lie algebra: it consists of shift-invariant Hermitian operators, which form a vector space of the predicted dimension.

**Impact**: If true, this extends the classical Centralizer = Reversibility theorem to the quantum setting, providing a rigorous framework for quantum cellular automata. The dimension formula would characterize the "degrees of freedom" of quantum reversible dynamics on finite rings.

**Catalog References**: `Catalog/Geometry/CellularAutomataGalois.lean`, `Catalog/Geometry/QuantumGravityErrorCorrection.lean`

**Proof Strategy**: The shift-equivariant unitaries form the centralizer of the shift representation in U(d^n). Use Schur's lemma: the centralizer decomposes as a direct sum of matrix algebras indexed by the irreducible representations of ℤ/nℤ. Count dimensions using the character of the shift on (ℂ^d)^{⊗n}.

**Domain Bridges**: Cellular Automata ↔ Quantum Information Theory ↔ Lie Group Theory

**Lineage**: Builds on Theorem 3.2 (classical centralizer characterization) and generalizes to the quantum/continuous setting.

**Ambition**: grand_challenge

---

### Direction 4: Reversibility Groups for Higher Radii and the Generation Conjecture

**Conjecture**: For binary CAs of radius r ≥ 2 on sufficiently large period n, the reversibility group Rev(n, r, {0,1}) properly contains the group generated by all radius-r affine CA rules, and the quotient has a structure related to the automorphism group of the de Bruijn graph B(2, 2r+1).

**Test**: For r = 2 (radius 2, neighborhoods of size 5), enumerate the 2^32 rules and identify which are reversible on period 10. Compute the group generated by their local rules' permutations and compare to the affine subgroup. The quotient should be non-trivial and related to Aut(B(2, 5)).

**Impact**: Understanding the generation structure for r ≥ 2 would resolve the open conjecture from the research direction that G(r, {0,1}) = S_{2^{2r+1}} for r ≥ 2, or provide a counterexample.

**Catalog References**: `Catalog/Geometry/CellularAutomataGalois.lean`

**Proof Strategy**: For r ≥ 2, construct non-affine reversible rules by explicit construction (e.g., using permutation matrices on the de Bruijn graph). Show that their compositions generate additional permutations beyond the affine group. Key lemma: the de Bruijn graph automorphisms inject into the reversibility group.

**Domain Bridges**: Cellular Automata ↔ Graph Theory (de Bruijn Graphs) ↔ Combinatorial Group Theory

**Lineage**: Builds on the Centralizer Theorem and the affinity barrier investigation.

**Ambition**: extension

---

### Direction 5: Tropical Reversibility and Min-Plus Cellular Automata

**Conjecture**: Define a "tropical cellular automaton" where the local rule uses min and + instead of Boolean operations. The tropical reversibility group on ℤ_max^n (where ℤ_max = ℤ ∪ {-∞} with max as addition and + as multiplication) is isomorphic to the group of shift-equivariant tropical linear isomorphisms, which equals GL_n(ℤ_max) ∩ C(σ).

**Test**: For n = 3, compute the tropical reversibility group and verify it equals the centralizer of the tropical shift matrix in GL_3(ℤ_max). The tropical shift matrix is the circulant matrix with (0, -∞, ..., -∞, 0) as first row.

**Impact**: This would bridge cellular automata theory with tropical geometry and optimization, connecting reversible dynamics to the tropical linear algebra that underlies shortest-path algorithms and scheduling problems.

**Catalog References**: `Catalog/Tropical/HashInversion.lean` (tropicalMatMul), `Catalog/Geometry/CellularAutomataGalois.lean`

**Proof Strategy**: Formalize tropical matrices using WithTop ℤ (already available in the Catalog). Define tropical shift-equivariance. Prove the tropical Centralizer = Reversibility theorem by adapting the classical proof. Key challenge: tropical "invertibility" requires a different notion than classical invertibility.

**Domain Bridges**: Cellular Automata ↔ Tropical Geometry ↔ Combinatorial Optimization

**Lineage**: Builds on both the CA Galois theory and the Catalog's tropical matrix infrastructure.

**Ambition**: extension
