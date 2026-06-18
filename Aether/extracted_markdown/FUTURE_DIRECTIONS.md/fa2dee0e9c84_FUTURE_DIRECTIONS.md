# Future Directions: Galois Theory of Cellular Automata

## Synthesis

This research cycle established the complete algebraic classification of reversible elementary cellular automata: exactly 6 out of 256 rules are always-reversible, forming a group isomorphic to ℤ/nℤ × ℤ/2ℤ on lattices of size n. The key structural insight is that the two generators — spatial shift and bitwise complement — commute, forcing the group to be a direct product. We introduced the **reversibility spectrum** as a novel invariant mapping each CA rule to the set of lattice sizes on which it is bijective, and discovered that linear/affine rules have spectra governed by cyclotomic polynomial divisibility over GF(2).

The most promising cross-domain connection is between the reversibility spectrum and algebraic number theory. The spectrum of a linear CA encodes the factorization structure of its local rule polynomial modulo cyclotomic polynomials over GF(2). This connects cellular automata dynamics to the theory of finite fields, coding theory (through cyclic codes and their dual polynomials), and ultimately to the representation theory of cyclic groups over GF(2). The fact that Rule 150's spectrum is {n : 3 ∤ n} while Rule 45's spectrum is {n : 2 ∤ n} suggests a general "spectral factorization theorem" that would classify all reversibility spectra in terms of the roots of the local rule polynomial.

The direction with highest breakthrough potential is Direction 1 (Spectral Classification), because it would transform the reversibility question from a case-by-case computation into a single algebraic criterion, analogous to how Galois theory transforms the solvability of polynomials into a group-theoretic condition.

---

### Direction 1: Spectral Classification of Reversibility via Cyclotomic Polynomials

**Conjecture**: For any linear elementary CA with local rule polynomial p(x) ∈ GF(2)[x], the reversibility spectrum is RevSpec(p) = {n ∈ ℕ₊ : gcd(p(x), x^n − 1) = 1 in GF(2)[x]}. Equivalently, the CA is irreversible on period n if and only if some root of p(x) (in the algebraic closure of GF(2)) is an n-th root of unity.

**Test**: Compute RevSpec for all 16 linear elementary CAs (those whose local rule is a GF(2)-linear function of the three inputs). For each, verify that the spectrum matches the polynomial GCD prediction for n = 1, ..., 30. The 16 linear rules are those with Wolfram numbers of the form 2^a + 2^b + ... where the XOR decomposition involves only linear terms.

**Impact**: If true, this would provide a complete, polynomial-time algorithm for deciding reversibility of any linear CA on any lattice size, reducing an exponential computation to a GCD in GF(2)[x]. It would also connect CA reversibility to the theory of cyclic codes, since the set of "bad" periods is exactly the set of periods of cyclic codes whose generator polynomial divides the local rule polynomial.

**Catalog References**: `Algebra/CellularAutomataReversibility.lean` (shift_period, shift_iterate_eq, reversibility spectrum definition)

**Proof Strategy**: 
1. Formalize GF(2)-linear CAs as circulant matrices over GF(2).
2. Prove that the determinant of a circulant matrix equals the product of its eigenvalues.
3. Show that the eigenvalues of the CA circulant are evaluations of the local polynomial at roots of unity.
4. Connect polynomial roots to cyclotomic polynomial divisibility using Mathlib's `Polynomial.IsCoprime`.
5. Key lemma: `det(circ(p)) = 0 ↔ ∃ ω, ω^n = 1 ∧ p(ω) = 0` over the algebraic closure.

**Domain Bridges**: Algebra (polynomial rings over GF(2)) ↔ Computation (CA dynamics) ↔ Cryptography (cyclic codes)

**Lineage**: Builds on this cycle's reversibility spectrum definition and Rule 150 conjecture.

**Ambition**: grand_challenge

---

### Direction 2: Garden of Eden Asymptotics and Topological Entropy

**Conjecture**: For any elementary CA rule f, the limit λ(f) = lim_{n→∞} GoE(f,n)/2^n exists and equals 1 − 2^{−h(f)}, where h(f) is the topological entropy of f viewed as a shift-commuting endomorphism of {0,1}^ℤ. Moreover, h(f) = log₂|Im(f)| / n in the appropriate limit.

**Test**: Compute GoE(f,n)/2^n for rules 30, 90, 110, 150 up to n = 20. Fit the convergence rate. Compare the limiting ratio with known topological entropy values. For Rule 90 (known entropy log 2), verify that λ(90) approaches a specific rational value (computations suggest it alternates between 1/2 and 3/4 depending on parity, so the conjecture needs refinement).

**Impact**: If true, this would give a computable finite-lattice approximation to topological entropy, one of the most important dynamical invariants but notoriously hard to compute. It would also provide a bridge between the finite (Garden of Eden counting) and infinite (topological dynamics) perspectives on CAs.

**Catalog References**: `Algebra/CellularAutomataReversibility.lean` (gardenOfEdenCount, reversible_iff_no_goe, goe_zero_of_surjective)

**Proof Strategy**:
1. Formalize topological entropy for shift-commuting maps using Mathlib's topology.
2. Prove that |Im(F_n)| / 2^n is submultiplicative or superadditive in n.
3. Apply Fekete's lemma to establish limit existence.
4. Connect the limit to the topological entropy via the variational principle.

**Domain Bridges**: Computation (GoE counting) ↔ Physics (entropy, thermodynamics of CA) ↔ EML (information theory)

**Lineage**: Builds on this cycle's GoE formalization and computational GoE data.

**Ambition**: grand_challenge

---

### Direction 3: Radius-2 Reversibility Group — Phase Transition in Symmetry

**Conjecture**: For binary CAs of radius 2 (local rule f : {0,1}^5 → {0,1}), the group G(2, {0,1}) generated by the local rules of all always-reversible CAs, viewed as permutations of the 32-element neighborhood space, is strictly larger than the analogous group for radius 1. Specifically, G(2) contains elements that are not compositions of shifts and complements.

**Test**: Enumerate a computationally tractable subset of the 2^32 radius-2 rules. Focus on rules that are reversible on periods 3, 4, 5, 6, 7 simultaneously (a necessary condition for always-reversibility). Compute the permutation group generated by their local rules and determine its order and structure.

**Impact**: If the radius-2 group is the full symmetric group S_{32} (or close to it), this would confirm a phase transition: the rigid ℤ/nℤ × ℤ/2ℤ structure at radius 1 explodes into maximal symmetry at radius 2. This would have implications for the computational universality of reversible CAs.

**Catalog References**: `Algebra/CellularAutomataReversibility.lean` (shiftPerm, complPerm, group structure theorems)

**Proof Strategy**:
1. Extend the CA formalization to radius 2 (neighborhoods of size 5).
2. Enumerate candidate reversible rules using SAT solvers or constraint propagation.
3. Compute the permutation group computationally using GAP or similar.
4. If the group is S_{32}, prove it by exhibiting generators that produce all transpositions.

**Domain Bridges**: Algebra (permutation group theory) ↔ Computation (reversible computation, Toffoli gate universality)

**Lineage**: Extends the radius-1 classification from this cycle to higher radius.

**Ambition**: extension

---

### Direction 4: Nonlinear Reversibility Spectra — Do They Exist?

**Conjecture**: Every elementary CA rule with a non-trivial reversibility spectrum (reversible on some but not all periods n ≥ 2) is affine over GF(2). Equivalently, no nonlinear ECA has a non-trivial spectrum.

**Test**: For each of the 256 elementary rules, compute the reversibility spectrum up to n = 12. For any rule with a non-trivial spectrum, verify that it is affine (i.e., its truth table satisfies the affine condition f(a⊕b⊕c) = f(a)⊕f(b)⊕f(c)⊕f(0) for all inputs). Cross-check against the 16 affine functions on {0,1}^3.

**Impact**: If true, this would mean that partial reversibility is a purely linear phenomenon for elementary CAs, suggesting a fundamental barrier between linear and nonlinear dynamics. If false — if a nonlinear rule has a non-trivial spectrum — this would be extremely interesting, as it would show that nonlinear CAs can "accidentally" be reversible on certain lattice sizes.

**Catalog References**: `Algebra/CellularAutomataReversibility.lean` (RevSpectrum definition, spectrum computation algorithms)

**Proof Strategy**:
1. Exhaustive computation for all 256 rules up to period 12.
2. For any nonlinear rule found with non-trivial spectrum, analyze its local rule structure.
3. If the conjecture holds, attempt a proof using the structure theory of Boolean functions.

**Domain Bridges**: Algebra (Boolean function theory) ↔ Computation (CA dynamics) ↔ Cryptography (nonlinearity measures)

**Lineage**: Motivated by this cycle's observation that all non-trivial spectra found correspond to linear/affine rules.

**Ambition**: extension

---

### Direction 5: Reversibility Groups and Quantum Cellular Automata

**Conjecture**: The group of reversible CAs on a d-dimensional lattice ℤ^d with finite alphabet A, modulo the shift subgroup, is isomorphic to the automorphism group of a certain profinite completion. For d = 1 and A = {0,1}, this quotient is ℤ/2ℤ (the complement). For d ≥ 2, the quotient group is infinite and its structure encodes the topology of ℤ^d.

**Test**: For d = 2 with A = {0,1} and von Neumann neighborhood (radius 1), enumerate reversible rules on small tori (e.g., ℤ/3ℤ × ℤ/3ℤ). Compute the group they generate modulo shifts. Compare with the prediction.

**Impact**: Understanding the quotient group would bridge discrete dynamics (CAs) with continuous symmetry groups (the automorphism group of the shift dynamical system). This connects to quantum cellular automata, where the analogous classification involves the third cohomology group H³(ℤ^d, U(1)) — a deep connection between classical reversibility and quantum topology.

**Catalog References**: `Algebra/CellularAutomataReversibility.lean` (shiftPerm, complPerm, group structure), `Algebra/FutureExploration.lean` (symmetric_group_order)

**Proof Strategy**:
1. Formalize the shift subgroup as a normal subgroup of the reversible CA group.
2. Define the quotient group and compute it for small examples.
3. Use Mathlib's group theory (QuotientGroup) to formalize the quotient.
4. Connect to the classification of QCAs via the GNVW index.

**Domain Bridges**: Algebra (group cohomology) ↔ Physics (quantum cellular automata, topological phases) ↔ Computation (reversible computation)

**Lineage**: Extends the 1D group structure theorem to higher dimensions and the quantum setting.

**Ambition**: grand_challenge
