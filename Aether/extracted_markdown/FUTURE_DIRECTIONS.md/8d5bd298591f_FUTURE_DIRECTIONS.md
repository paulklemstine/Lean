# Future Directions: Galois Theory of Cellular Automata

## Synthesis

This research cycle established a complete, formally verified classification of reversible elementary cellular automata and characterized their group structure. The central discovery is that reversibility in elementary CAs is governed by an unexpectedly simple algebraic principle: a rule is reversible if and only if it is *single-input* — its output depends on exactly one of the three neighborhood cells through a bijection. The six reversible rules generate a group isomorphic to ℤ/nℤ × ℤ/2ℤ, the product of cyclic shifts and complement.

The most promising cross-domain connection emerging from this work lies at the intersection of **algebraic dynamics** and **information theory**. The reversibility index, introduced as a quantitative measure of information loss, creates a bridge between the discrete algebraic structure of CA groups and the continuous thermodynamic concept of entropy production. This connects to Landauer's principle (erasure costs energy) and suggests a formal framework linking computational reversibility to physical irreversibility — a direction with implications for both theoretical computer science and statistical mechanics.

The relationship to the existing Catalog is through `Bridges/BerggrenChronometricAutomata.lean`, which established that reversible automata factor through history groupoids. Our work provides the concrete group-theoretic content that the chronometric framework was missing: the reversibility group ℤ/nℤ × ℤ/2ℤ is the explicit automorphism group of the elementary CA dynamical system. The single-input classification theorem could serve as a base case for inductive arguments extending to higher-radius CAs, connecting to the algebraic word structures in `Catalog/Algebra/AffineWords.lean`.

---

### Direction 1: Reversibility Classification for Radius-2 Binary CAs

**Conjecture**: For radius-2 binary CAs (neighborhoods of size 5), a local rule f : Bool⁵ → Bool produces a bijective global map on periodic configurations of size n ≥ 11 if and only if the rule depends on at most one input through a bijection, OR the rule is a composition of single-input radius-1 rules applied at offset positions. Specifically, the reversible radius-2 rules are exactly the "block-decomposable" rules of the form f(a,b,c,d,e) = g(h(a,b,c), b, k(c,d,e)) where h,k are radius-1 reversible local rules. The reversibility group G₂(n) for radius-2 rules is strictly larger than G₁(n) but still abelian.

**Test**: Enumerate all 2³² = 4,294,967,296 radius-2 rules on configurations of size n = 11 (computationally expensive but feasible with GPU acceleration). For each rule, test bijectivity by checking that the 2¹¹ = 2048 images are distinct. Identify all reversible rules and verify whether they are block-decomposable. If a non-block-decomposable reversible rule exists, the conjecture is false.

**Impact**: If true, this would establish that reversibility in binary CAs is fundamentally *compositional* — all reversible dynamics arise from composing simple single-coordinate operations. This would support a "Galois correspondence" between reversible CAs and subgroups of the automorphism group of the shift dynamical system, potentially connecting to Hedlund's theorem in a constructive way.

**Catalog References**: `Bridges/GaloisCellularAutomata.lean` (single-input classification theorem), `Bridges/BerggrenChronometricAutomata.lean` (reversible automaton factorization), `Catalog/Algebra/AffineWords.lean` (word-based algebraic structures)

**Proof Strategy**: 
1. Define "block-decomposable" radius-2 rules formally.
2. Prove that block-decomposable rules produce bijective global maps (generalize `singleInput_bijective`).
3. For the converse, develop an obstruction theory: if a rule depends on two or more non-adjacent inputs, construct explicit collisions in the global map for large enough n.
4. The key technical lemma: for non-block-decomposable rules, the "defect set" (pairs of configs that collide) has density bounded away from zero as n → ∞.

**Domain Bridges**: Algebra <-> Computation, Dynamics <-> Combinatorics

**Lineage**: Builds on the single-input classification (Theorem 3.11) and reversibility index framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Thermodynamic Reversibility Index and Landauer Bound

**Conjecture**: For any elementary CA rule f, the reversibility index ρ(F_f) on configurations of size n satisfies ρ(F_f) ≥ 2(2ⁿ − |Im(F_f)|), with equality when F_f has the "maximally uniform" image distribution (each image has equal multiplicity). Furthermore, the Shannon entropy of the image distribution H(F_f) satisfies n − H(F_f) ≥ log₂(1 + ρ(F_f)/2ⁿ), connecting information loss to the reversibility index.

**Test**: For all 256 elementary CA rules and n = 3,...,10, compute both ρ(F_f) and |Im(F_f)|. Verify the inequality ρ ≥ 2(2ⁿ − |Im|). Compute H(F_f) and check the entropy bound. Plot ρ vs (2ⁿ − |Im|) to visualize the relationship.

**Impact**: This would establish a quantitative connection between the algebraic reversibility index and information-theoretic entropy loss, providing a discrete analog of Landauer's principle. The bound would give a computable certificate of irreversibility that doesn't require checking all 2ⁿ configurations.

**Catalog References**: `Bridges/GaloisCellularAutomata.lean` (reversibilityIndex definition and properties), `Computation/InfoEfficientAlgorithms.lean` (information-efficient computation framework)

**Proof Strategy**:
1. Express ρ in terms of the multiplicity distribution {m₁, m₂, ...} of the global map.
2. Show ρ = Σ mⱼ for all j with mⱼ > 1, and |Im| = |{j : mⱼ ≥ 1}|.
3. Use the constraint Σ mⱼ = 2ⁿ and the Cauchy-Schwarz inequality to bound ρ from below.
4. For the entropy bound, use Jensen's inequality on the logarithmic function.

**Domain Bridges**: Computation <-> Physics, Algebra <-> Information Theory

**Lineage**: Builds on the reversibility index framework and the bijection theorem (ρ = 0 iff bijective).

**Ambition**: extension

---

### Direction 3: Categorical Galois Correspondence for CA Reversibility

**Conjecture**: There exists a Galois-type correspondence between:
- Closed subgroups of the automorphism group Aut(σ) of the full shift (σ : Boolℤ → Boolℤ)
- Closed sub-shift-of-finite-type (SFT) subsystems of the full shift

Under this correspondence, the reversibility group G(r, A) of radius-r CAs on alphabet A corresponds to the maximal SFT subsystem that is invariant under all reversible CAs of radius r. For elementary CAs, this maximal invariant SFT is the full shift itself (since the group is abelian and acts transitively).

**Test**: For radius-1 binary CAs, verify computationally that the only configurations invariant under all 6 reversible rules are the empty set and the full configuration space. For radius-2, compute the fixed-point set of each reversible rule and check whether their intersection is trivial.

**Impact**: This would establish a genuine Galois correspondence in dynamical systems theory, connecting the algebraic structure of reversible CAs to the topological structure of shift spaces. It would unify the combinatorial classification of reversible rules with the symbolic dynamics framework.

**Catalog References**: `Bridges/BerggrenChronometricAutomata.lean` (history groupoid factorization), `Bridges/AlgebraEMLClosureComputation.lean` (closure operators and fixpoints), `EML/EMLv17Core.lean` (categorical framework)

**Proof Strategy**:
1. Define the "invariant subshift" functor from Aut(σ) → SFT.
2. Define the "stabilizer" functor from SFT → Sub(Aut(σ)).
3. Prove these form a Galois connection (adjunction between posets).
4. Characterize the closed sets on both sides.
5. For elementary CAs, use the explicit ℤ/nℤ × ℤ/2ℤ structure to compute all invariant subshifts.

**Domain Bridges**: Algebra <-> Dynamics, Category Theory <-> Topology

**Lineage**: Builds on the group structure theorem (G(n) ≅ ℤ/nℤ × ℤ/2ℤ) and the "Galois theory" framing.

**Ambition**: grand_challenge

---

### Direction 4: Reversibility in Multi-State CAs and Permutation Groups

**Conjecture**: For k-state elementary CAs (alphabet = {0, 1, ..., k−1}, radius 1), the number of reversible rules equals 6k!/((k−1)!)³ when k is prime, and strictly less for composite k. The reversibility group on n-cell configurations is ℤ/nℤ × Sym(k)/Stab(shift), where Stab(shift) is the stabilizer of the shift automorphism in the symmetric group on neighborhoods.

**Test**: For k = 3 (ternary CAs), enumerate all 3²⁷ = 7,625,597,484,987 rules... this is infeasible by brute force. Instead, enumerate the single-input rules (3! × 3 = 18 candidates) and verify their reversibility. Then search for non-single-input reversible rules by random sampling with n = 7.

**Impact**: Understanding how reversibility scales with alphabet size would reveal whether the single-input characterization is a universal principle or a low-dimensional accident. For cryptographic applications, larger alphabets provide larger key spaces.

**Catalog References**: `Bridges/GaloisCellularAutomata.lean` (isSingleInput definition), `Cryptography/BerggrenGroupoidOrbit.lean` (group orbit computations)

**Proof Strategy**:
1. Generalize the `isSingleInput` definition to k-state alphabets (g : Fin k → Fin k bijective).
2. Prove the single-input → bijective direction for arbitrary k (should follow the same argument).
3. For the converse, adapt the collision argument: a rule depending on two inputs can merge k distinct neighborhoods into fewer than k outputs.
4. Count single-input rules: k! choices for g × 3 coordinate choices × correction for constant rules.

**Domain Bridges**: Algebra <-> Cryptography, Combinatorics <-> Group Theory

**Lineage**: Direct generalization of the binary single-input classification.

**Ambition**: extension

---

### Direction 5: Quantum Reversible CAs and Unitary Dynamics

**Conjecture**: The group of reversible quantum CAs (QCAs) on n qubits arranged in a ring, with radius 1, is isomorphic to the group of local unitary circuits of depth 1 that commute with the cyclic shift. This group has order |U(4)|ⁿ / |stabilizer| where U(4) is the 4×4 unitary group (acting on pairs of adjacent qubits). The classical reversible CA group ℤ/nℤ × ℤ/2ℤ embeds into this quantum group as the subgroup of permutation matrices.

**Test**: For n = 3 qubits, enumerate all 8×8 unitary matrices that:
(a) decompose as a tensor product of local 4×4 unitaries,
(b) commute with the cyclic shift operator, and
(c) map computational basis states to computational basis states.
Verify that the resulting group is ℤ/3ℤ × ℤ/2ℤ (order 6), matching the classical prediction.

**Impact**: This would bridge reversible CAs (classical computation) with quantum circuit theory, potentially revealing new families of quantum error-correcting codes based on the CA group structure. The embedding of classical reversible CAs into quantum dynamics would formalize the sense in which classical reversibility is a "shadow" of quantum unitarity.

**Catalog References**: `Physics/` (quantum mechanical foundations), `Bridges/GaloisCellularAutomata.lean` (classical reversibility group), `Computation/GravityOracle.lean` (oracle-based computation models)

**Proof Strategy**:
1. Define quantum configurations as vectors in (ℂ²)^⊗n.
2. Define a quantum CA local rule as a unitary U : ℂ⁴ → ℂ⁴ applied to adjacent pairs.
3. Characterize the commutant of the shift operator in the space of depth-1 local unitaries.
4. Show that permutation matrices (classical reversible CAs) form a subgroup.
5. Compute the index of this subgroup.

**Domain Bridges**: Computation <-> Physics, Algebra <-> Quantum Information

**Lineage**: Extends the reversibility group concept from classical to quantum dynamics.

**Ambition**: grand_challenge
