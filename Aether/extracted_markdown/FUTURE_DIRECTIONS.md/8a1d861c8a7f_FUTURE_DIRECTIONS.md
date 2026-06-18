# Future Directions: Tropical One-Way Functions from Matrix Powering

## Direction 1: Average-Case Hardness for Random Tropical Matrices

### Hypothesis
For random n×n tropical matrices with entries drawn uniformly from {0, 1, ..., M}, the probability that tropical squaring is invertible (in the sense that G is uniquely determined by G²) approaches 1 as M → ∞ for fixed n, and the inversion problem requires Ω(M^{n-1}) time for generic instances.

### Proof Strategy
1. **Visibility analysis**: Show that the number of invisible edges in a random matrix is O(1) as M → ∞ (with high probability, all edges are visible because large spread prevents ties).
2. **Counting preimages**: For each invisible edge, the constraint set from G² defines an interval of valid values. Count the total preimage space.
3. **Reduction to constraint satisfaction**: Model the inversion problem as a system of tropical polynomial equations and apply existing complexity results for tropical solving.

### Cross-Domain Connections
- Random matrix theory (tropical version, cf. Baccelli-Mairesse)
- Constraint satisfaction phase transitions
- Average-case complexity theory

### Concrete Next Step
Implement a large-scale computational experiment: generate 10,000 random 5×5 matrices for each M ∈ {10, 100, 1000, 10000}, compute G², count preimages via exhaustive search (feasible for 5×5), and plot the distribution of preimage counts as a function of M.

---

## Direction 2: Tropical Trapdoor Functions

### Hypothesis
There exist families of tropical matrices where inversion is hard without a trapdoor but efficient with knowledge of the original graph structure (e.g., a spanning tree decomposition).

### Proof Strategy
1. **Define trapdoor families**: Matrices G where the graph has a known decomposition (e.g., G = L + R for lower/upper triangular L, R in the tropical sense) such that G² can be efficiently inverted given L and R.
2. **Hardness without trapdoor**: Show that without the decomposition, inversion requires brute-force search.
3. **Protocol construction**: Build a public-key encryption scheme where:
   - Key generation: Choose L, R, compute G = L ⊗ R and publish G²
   - Encryption: Use orbit hash with random exponents
   - Decryption: Use knowledge of L, R to invert

### Cross-Domain Connections
- Lattice trapdoor functions (Ajtai, Micciancio-Peikert)
- Tropical factorization theory
- Graph decomposition algorithms

### Concrete Next Step
Formalize the definition of tropical matrix factorization G = L ⊗ R and prove basic properties (existence, non-uniqueness, relationship to graph structure). Test whether factorization-aware inversion is polynomial-time for structured instances.

---

## Direction 3: Min-Plus PRG Constructions from Orbit Iteration

### Hypothesis
The orbit hash construction G, G², G⁴, G⁸, ... (repeated squaring orbit) is a pseudorandom generator under the assumption that tropical squaring is a one-way function on the relevant instance family.

### Proof Strategy
1. **Hybrid argument**: Define hybrid distributions H₀ (real orbit), H₁ (replace last output with random), ..., Hₖ (fully random). Show that distinguishing Hᵢ from Hᵢ₊₁ implies inverting G^{2^i}.
2. **Entropy analysis**: Use the midpoint sum lower bound to show that each squaring step adds min-entropy to the output.
3. **Compression argument**: Show that if the orbit were compressible, it would yield an inverter for one of the intermediate powers.

### Cross-Domain Connections
- Goldreich-Levin theorem and hardcore predicates
- Blum-Micali PRG construction
- Tropical entropy and information theory

### Concrete Next Step
Implement the orbit hash PRG and conduct statistical tests (NIST test suite) on its output. Compare randomness quality with different matrix sizes and entry ranges. Formalize the one-step chain rule (already partially done in the codebase as `tropical_orbit_prg`).

---

## Direction 4: Reductions from Tropical Factorization to Control-System Identification

### Hypothesis
Inverting tropical matrix powering is at least as hard as the tropical system identification problem: given the input-output behavior of a discrete event system over k time steps, recover the system's transition matrix.

### Proof Strategy
1. **Encode system identification as power inversion**: A discrete event system with transition matrix G produces outputs G^k · x₀ for initial state x₀. Recovering G from {G^k · x₀ : k = 1, ..., T} is a special case of power inversion where only certain projections of the powers are observed.
2. **Reduction theorem**: Show that a power inverter for G² (with full matrix output) can be used to solve the system identification problem with quadratic blowup.
3. **Hardness evidence**: Connect to known undecidability results for max-plus linear systems.

### Cross-Domain Connections
- Max-plus linear systems theory (Cohen, Gaubert, Quadrat)
- System identification in control theory
- Weighted automata and formal series

### Concrete Next Step
Formalize the tropical discrete event system model and the identification problem. Prove the reduction from identification to power inversion for the case k=2. Connect to existing Catalog theorems on tropical automata (WeightedTraceSemantics, PolynomialMinimization).

---

## Direction 5: Formal Complexity Classes for Semiring Computation

### Hypothesis
There exists a natural complexity class "Tropical-P" of problems solvable in polynomial time with tropical arithmetic, and the tropical power inversion problem is complete for a related class under appropriate reductions.

### Proof Strategy
1. **Define Tropical-P**: Problems computable by polynomial-size tropical circuits (using min and +).
2. **Characterize expressiveness**: Show Tropical-P captures shortest-path-type problems and is contained in classical P but potentially not equal.
3. **Completeness**: Define an appropriate notion of tropical reduction and show power inversion is complete for a class corresponding to "inverting Tropical-P computations."
4. **Separation evidence**: Connect to existing results on min-plus circuit complexity and matrix multiplication lower bounds.

### Cross-Domain Connections
- Algebraic complexity theory (Valiant's VP vs VNP)
- Min-plus circuit complexity (Jukna-Sergeev)
- Tropical geometry and effective computation
- Descriptive complexity for semiring logics

### Concrete Next Step
Define Tropical-P formally and prove basic closure properties (under composition, tropical matrix multiplication). Show that shortest-path and all-pairs-shortest-path are in Tropical-P. Investigate whether the APSP conjecture (no truly subcubic algorithm) implies hardness of tropical power inversion.

---

## Cross-Cutting Theme: Idempotent Cryptography

All five directions contribute to founding a new branch of cryptography — **idempotent cryptography** — where hardness emerges from the idempotent structure of tropical algebra rather than from classical group inversion. The key distinguishing features are:

1. **Non-invertible operations**: min(x, x) = x destroys information structurally.
2. **Geometric hardness**: The tropical convex hull, tropical linear algebra, and tropical algebraic geometry provide natural "hard problems" distinct from lattice or number-theoretic ones.
3. **Natural connections to optimization**: Unlike classical cryptographic problems, tropical hard problems arise directly from real-world optimization, scheduling, and routing — creating a bridge between security and operations research.
4. **Potential quantum resistance**: Since tropical operations don't involve group structure, Shor's algorithm and its variants may not apply, offering a genuinely new post-quantum direction.

The ultimate goal is a complete tropical cryptographic toolkit: one-way functions, trapdoor permutations, pseudorandom generators, public-key encryption, and zero-knowledge proofs, all built on the mathematical foundations established in this work.
