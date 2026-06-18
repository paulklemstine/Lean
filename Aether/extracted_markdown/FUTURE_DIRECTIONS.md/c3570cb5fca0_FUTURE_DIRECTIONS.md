# Future Directions

## Synthesis

This research cycle established **Substitution Tiling Algebras** as a novel algebraic framework for studying aperiodic monotiles. The core insight is that aperiodicity in substitution tilings is fundamentally a spectral property of the substitution matrix — not a geometric property of individual tiles. This was demonstrated through three interconnected results: (1) the Spectral Transfer Theorem, showing that aperiodicity certificates propagate across continuous families of tiles sharing the same matrix; (2) the exponential growth theorem, proving that expanding substitution systems have growth incompatible with periodicity; and (3) the Fibonacci recurrence recovery, showing the framework correctly captures classical examples.

The most promising cross-domain connection emerged between our substitution matrix framework and the catalog's cellular automata results. The theorem `rule204_all_periodic` establishes periodicity for the identity cellular automaton — corresponding to substitution matrix = identity (eigenvalue 1, rational). This suggests a spectral classification boundary: rational dominant eigenvalue → periodic, irrational → aperiodic. The boundary between these regimes connects tiling theory to dynamical systems and number theory in a way that could yield new classification results.

The highest breakthrough potential lies in Direction 1 (weakening the expanding condition via Perron-Frobenius theory), because it would bring systems like Fibonacci and Thue-Morse fully into the certificate framework and connect to deep results in ergodic theory.

---

### Direction 1: Perron-Frobenius Aperiodicity Certificates

**Conjecture**: A primitive substitution system is aperiodic (generates no periodic infinite words) if and only if the Perron-Frobenius eigenvalue of its substitution matrix is irrational. Equivalently, the spectral aperiodicity certificate can be weakened from "all rules have length ≥ 2" to "the dominant eigenvalue λ₁ of the substitution matrix satisfies λ₁ ∉ ℚ."

**Test**: Formalize the Perron-Frobenius theorem for non-negative integer matrices in Lean 4. Then construct specific substitution systems with rational dominant eigenvalue that DO admit periodic tilings, and systems with irrational eigenvalue that do NOT. The Fibonacci system (eigenvalue φ = (1+√5)/2, irrational, known aperiodic) and the "doubling" system a→aa, b→bb (eigenvalue 2, rational, trivially periodic) serve as test cases.

**Impact**: If true, this gives a complete spectral classification of aperiodic substitution systems, reducing the aperiodicity question to a number-theoretic property of the substitution matrix. If false, the failure mode reveals which additional algebraic invariants beyond the eigenvalue are needed.

**Catalog References**: `Novelty/SubstitutionTilingAlgebra.lean` (SpectralAperiodicityCert), `Bridges/PeriodicOrbitVarieties.lean` (rule204_all_periodic)

**Proof Strategy**: First formalize Perron-Frobenius for ℕ-matrices (existence of dominant real eigenvalue for primitive matrices). Then show: (1) if λ₁ ∈ ℚ, construct a periodic word with period related to the denominator of λ₁; (2) if λ₁ ∉ ℚ, show that letter frequencies in any periodic fixed point would force λ₁ to be rational, contradiction.

**Domain Bridges**: Tiling Theory ↔ Number Theory (irrationality of eigenvalues), Tiling Theory ↔ Ergodic Theory (unique ergodicity of substitution systems)

**Lineage**: Builds on the Substitution Tiling Algebra framework from this cycle, specifically extending `SpectralAperiodicityCert` with a weaker certificate condition.

**Ambition**: grand_challenge

---

### Direction 2: Substitution Matrix Characteristic Polynomial of the Hat

**Conjecture**: The characteristic polynomial of the hat substitution matrix M = [[4,2,1,1],[1,1,0,0],[1,0,1,0],[1,0,0,1]] is p(x) = x⁴ - 7x³ + 14x² - 8x + 1, and its roots include 2 + √3 (approximately 3.732) and 2 - √3 (approximately 0.268). The irrationality of the dominant root 2 + √3 is the algebraic reason the hat tiling is aperiodic.

**Test**: Compute det(M - xI) formally in Lean 4 using Mathlib's matrix determinant and polynomial arithmetic. Then prove that 2 + √3 is a root, and that √3 is irrational (this is in Mathlib), hence the root is irrational.

**Impact**: This would give the first fully formal proof that the hat substitution matrix has an irrational dominant eigenvalue, which is the key algebraic ingredient for aperiodicity. Combined with Direction 1, it would yield a complete formal aperiodicity proof for the hat tiling (modulo geometric tile-fitting).

**Catalog References**: `Novelty/SubstitutionTilingAlgebra.lean` (HatSubst, hat_substMatrix_H_H)

**Proof Strategy**: (1) Define the 4×4 matrix over ℤ[x] or ℝ. (2) Compute the determinant using cofactor expansion or Mathlib's `Matrix.det`. (3) Factor the polynomial. (4) Show 2 + √3 is a root by direct substitution. (5) Conclude irrationality from irrationality of √3.

**Domain Bridges**: Tiling Theory ↔ Algebraic Number Theory (characteristic polynomials), Tiling Theory ↔ Linear Algebra (eigenvalue computation)

**Lineage**: Direct extension of the hat metatile system formalized in this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Substitution Systems and Min-Plus Tiling

**Conjecture**: There exists a "tropical substitution system" — a substitution system over the min-plus (tropical) semiring where the substitution matrix entries are tropical numbers (elements of ℝ ∪ {∞} with operations min and +) — that generates aperiodic tropical tilings. Moreover, the tropical analogue of the Perron-Frobenius eigenvalue (the tropical eigenvalue = minimum cycle mean) determines tropical aperiodicity.

**Test**: Define tropical substitution matrices in Lean 4, building on the existing `Tropical` catalog. Compute the tropical eigenvalue for the hat matrix (interpreting entries tropically) and compare with the classical eigenvalue. Check whether tropical aperiodicity (no tropical periodic point) corresponds to classical aperiodicity.

**Impact**: This would create a genuine bridge between tropical geometry and tiling theory — two fields with no known formal connection. If tropical and classical aperiodicity correspond, it reveals a deep structural parallel. If they diverge, it identifies which properties are semiring-specific.

**Catalog References**: `Tropical/PeriodicOrbits.lean` (periodic_point_with_constraint), `Novelty/SubstitutionTilingAlgebra.lean` (SubstSystem)

**Proof Strategy**: (1) Define TropicalSubstSystem by analogy with SubstSystem but over tropical semiring. (2) Define tropical iteration and growth. (3) Compute tropical eigenvalue = min of average cycle weights. (4) Prove tropical version of growth bounds. (5) Compare with classical results.

**Domain Bridges**: Tiling Theory ↔ Tropical Geometry (min-plus algebra), Number Theory ↔ Tropical Geometry (tropical eigenvalues)

**Lineage**: Builds on both the Substitution Tiling Algebra framework and the Tropical catalog entries.

**Ambition**: grand_challenge

---

### Direction 4: Automata-Theoretic Characterization of Substitution Growth

**Conjecture**: The growth sequence g(a, n) = |σⁿ(a)| of any primitive substitution system on k letters is a linear recurrence of order ≤ k. Specifically, g(a, n) satisfies a recurrence whose characteristic polynomial divides the characteristic polynomial of the substitution matrix.

**Test**: Verify this for the Fibonacci system (order 2, Fibonacci recurrence — already proved in this cycle), the hat system (should be order ≤ 4), and the Thue-Morse system (order ≤ 2). Formalize the general result by expressing g(a, n) as a coordinate of M^n · e_a where M is the substitution matrix and e_a is a unit vector.

**Impact**: This connects substitution tilings to the theory of linear recurrences and hence to automatic sequences, D-finite functions, and the algebra of linear differential equations. It would show that growth sequences of substitution systems are always "algebraic" in a precise sense.

**Catalog References**: `Novelty/SubstitutionTilingAlgebra.lean` (fib_growth_recurrence, growthSeq_succ)

**Proof Strategy**: (1) Show that the vector v(n) = (count(0, σⁿ(a)), count(1, σⁿ(a)), ..., count(k-1, σⁿ(a))) satisfies v(n+1) = M · v(n) using letterCount_applyWord. (2) Show g(a, n) = 1ᵀ · v(n). (3) Apply Cayley-Hamilton to conclude g satisfies a recurrence of order ≤ k.

**Domain Bridges**: Tiling Theory ↔ Automata Theory (automatic sequences), Linear Algebra ↔ Combinatorics (Cayley-Hamilton)

**Lineage**: Direct generalization of fib_growth_recurrence from this cycle.

**Ambition**: extension

---

### Direction 5: Substitution Entropy and Phase Transitions

**Conjecture**: The topological entropy of the subshift generated by a primitive substitution system equals log(λ₁) where λ₁ is the Perron-Frobenius eigenvalue of the substitution matrix. Furthermore, there exists a "phase transition" in the space of substitution matrices: systems with λ₁ < 1 generate finite languages, systems with λ₁ = 1 generate languages of polynomial growth, and systems with λ₁ > 1 generate languages of exponential growth.

**Test**: Compute topological entropy for the Fibonacci (should be log φ ≈ 0.481), hat (should be log(2+√3) ≈ 1.317), and identity (should be 0) substitution systems. Verify the phase transition boundary at λ₁ = 1.

**Impact**: This connects substitution tilings to thermodynamic formalism and statistical mechanics. The "phase transition" at λ₁ = 1 would be a precise mathematical analogue of the transition between ordered (periodic) and disordered (aperiodic) phases in physical systems.

**Catalog References**: `Novelty/SubstitutionTilingAlgebra.lean` (growthSeq_exponential_lower), `EML/DiagonalPhaseTransition.lean` (exists_uncompressible_family_of_not_all_compressible)

**Proof Strategy**: (1) Define the language of a substitution system (set of all finite subwords of iterWord(a, n) for all n). (2) Define topological entropy as lim sup of log(complexity)/n. (3) Show complexity grows as λ₁ⁿ using the substitution matrix. (4) Conclude h_top = log λ₁.

**Domain Bridges**: Tiling Theory ↔ Ergodic Theory (topological entropy), Statistical Mechanics ↔ Combinatorics (phase transitions in language complexity)

**Lineage**: Extends the growth analysis from this cycle (exponential lower bound, factor complexity) toward a full entropy computation.

**Ambition**: extension
