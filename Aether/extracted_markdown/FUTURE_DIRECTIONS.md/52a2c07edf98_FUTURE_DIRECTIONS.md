# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the rigorous foundations of arithmetic on the Poincaré disk, proving 15 theorems about the conformal factor, Möbius addition, the Thomas gyration, hyperbolic area, and lattice counting. The most significant discovery is the formal verification that the Thomas gyration preserves normSq (Theorem `gyration_preserves_normSq`), which proves that the Poincaré disk is a *gyrogroup* — an algebraic structure where non-associativity is controlled by an isometric rotation. This connects to the Catalog's Berggren tree machinery (e.g., `Algebra/Berggren.lean`) and Lorentzian structures (`Pythagorean/BerggrenLorentz.lean`), since both PSL(2,ℤ) and the Berggren tree generate discrete subgroups of PGL(2,ℝ), and the Lorentz group SO(2,1) is locally isomorphic to PSL(2,ℝ).

The most promising cross-domain connection is between the lattice counting function (which counts orbit points of Fuchsian groups) and the spectral theory of automorphic forms. The Selberg trace formula connects lattice point asymptotics to eigenvalues of the Laplacian, and these eigenvalues are precisely the data encoded in Maass forms — the non-holomorphic cousins of modular forms already represented in the Catalog (`EML/ModularForms.lean`). Formalizing this connection would bridge hyperbolic geometry, number theory, and spectral theory in a single verified framework.

The direction with the highest breakthrough potential is Direction 1 (Gyrogroup Cohomology), because it defines a genuinely new mathematical structure — cohomology for non-associative algebraic objects — that could have applications ranging from quantum information to topological data analysis. The Thomas gyration cocycle provides a concrete, computable example that could anchor the theory.

---

### Direction 1: Gyrogroup Cohomology via the Thomas Cocycle

**Conjecture**: The Thomas gyration gyr[a,b] defines a 2-cocycle on the Poincaré disk gyrogroup satisfying:
  gyr[a, b ⊕ c] ∘ gyr[b, c] = gyr[a ⊕ b, gyr[a,b](c)] ∘ gyr[a, b]
This cocycle condition, analogous to the group cohomology 2-cocycle condition, generates a well-defined cohomology theory H^n_gyr(G, M) for gyrogroups G with coefficient module M.

**Test**: Verify the cocycle identity computationally for 1000 random triples (a, b, c) in the Poincaré disk with |a|, |b|, |c| < 0.9. If the identity fails for any triple, the formulation needs modification. If it holds, formalize the identity in Lean and build the first elements of the cohomology theory.

**Impact**: If true, this creates a new algebraic invariant for gyrogroups, potentially classifying extensions of gyrogroups in the same way group cohomology classifies group extensions. This would be the first rigorous cohomology theory for non-associative structures of this type.

**Catalog References**: `Algebra/Berggren.lean` (discrete group actions), `EML/ModularForms.lean` (modular group structure), `Logic/HyperbolicNumberTheory/Defs.lean` (gyration definition)

**Proof Strategy**: 
1. Verify the cocycle identity symbolically using the explicit formula for gyr[a,b].
2. Define cochain complexes C^n_gyr(G, M) with boundary maps incorporating gyration.
3. Prove d² = 0 for the boundary operator.
4. Compute H^1_gyr and H^2_gyr for specific examples (e.g., finite gyrogroups from Möbius arithmetic mod p).

**Domain Bridges**: Algebra <-> Geometry, NumberTheory <-> Topology

**Lineage**: Builds on `gyrationFactor_normSq` and `gyration_preserves_normSq` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Selberg Trace Formula and Spectral Lattice Counting

**Conjecture**: The lattice counting function N(R) for PSL(2,ℤ) satisfies the refined asymptotic:
  N(R) = (3/π)·e^R + Σⱼ (3/π)·(e^{sⱼR})/(sⱼ) + O(e^{2R/3})
where sⱼ are the exceptional eigenvalues of the Laplacian on SL(2,ℤ)\ℍ (eigenvalues λⱼ = sⱼ(1-sⱼ) with sⱼ > 1/2). For PSL(2,ℤ), there are no exceptional eigenvalues, so the error term is O(e^{2R/3}).

**Test**: Enumerate all SL(2,ℤ) matrices with a²+b²+c²+d² ≤ 2·cosh(R) for R = 5, 10, 15, 20. Compute N(R) - (3/π)·e^R and verify the remainder is O(e^{2R/3}). Specifically, check that |N(R) - (3/π)·e^R| / e^{2R/3} remains bounded as R grows.

**Impact**: Formalizing the Selberg trace formula in Lean would be a landmark achievement in formalized mathematics. Even partial results — formalizing the connection between lattice points and Laplacian eigenvalues — would significantly advance the Catalog.

**Catalog References**: `EML/ModularForms.lean` (T_sq, S_gen), `Computation/GravityOracle.lean` (oracle/spectral methods), `Logic/HyperbolicNumberTheory/Theorems.lean` (lattice counting)

**Proof Strategy**:
1. Define the hyperbolic Laplacian Δ = -y²(∂²/∂x² + ∂²/∂y²) on the upper half-plane.
2. Define automorphic forms and Maass forms for Γ = PSL(2,ℤ).
3. State the pre-trace formula: Σ_γ k(d(z, γ·z)) = Σ_j h(rⱼ) + continuous spectrum contribution.
4. Apply to the heat kernel to extract lattice counting asymptotics.
5. Formalize the error bound using known estimates on the spectral gap.

**Domain Bridges**: NumberTheory <-> Physics, Geometry <-> Computation

**Lineage**: Builds on `lattice_count_mono_R`, `lattice_count_mono_N`, `hypArea_strict_mono` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Berggren Tree as Fuchsian Group Orbit

**Conjecture**: The Berggren tree of primitive Pythagorean triples is isomorphic, as a rooted tree, to the orbit tree of a specific index-6 subgroup Γ_B of PSL(2,ℤ) acting on the Poincaré disk. The three Berggren matrices B₁, B₂, B₃ correspond to generators of Γ_B, and the Stern-Brocot structure of the Berggren tree reflects the hyperbolic tessellation of the disk by Γ_B.

**Test**: Compute the first 4 levels of the Berggren tree (3-4-5 → children → grandchildren → great-grandchildren, giving 1 + 3 + 9 + 27 = 40 triples). For each triple (a,b,c), compute the corresponding point on the Poincaré disk via the map (a,b,c) ↦ (a+bi)/c. Verify that these 40 points are exactly the orbit of (3+4i)/5 under the first 40 elements of Γ_B.

**Impact**: This would unify two major threads in the Catalog — the Berggren tree machinery and hyperbolic number theory — showing that Pythagorean triples are literally hyperbolic integers for a specific Fuchsian group. This would also connect the Catalog's Lorentzian structures to hyperbolic geometry via the isomorphism SO(2,1) ≅ PSL(2,ℝ).

**Catalog References**: `Algebra/Berggren.lean` (applyB₁, A_iter, A_closed), `Pythagorean/BerggrenLorentz.lean`, `Cryptography/BerggrenDiophantineLattice.lean` (lorentzForm, IsPythagoreanVec)

**Proof Strategy**:
1. Express the Berggren matrices B₁, B₂, B₃ as elements of PSL(2,ℤ) (after the Cayley isomorphism SO(2,1) → PSL(2,ℝ)).
2. Verify the resulting subgroup Γ_B has index 6 in PSL(2,ℤ).
3. Show the tree structure of the Berggren orbit matches the group-theoretic tree of cosets.
4. Prove the bijection between primitive Pythagorean triples and Γ_B-orbit points.

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Cryptography

**Lineage**: Builds on Berggren tree catalog entries and `mobiusAdd_zero_left`, `mobiusAdd_neg_self` from this cycle.

**Ambition**: extension

---

### Direction 4: Finite Hyperbolic Arithmetic (Möbius Addition mod p)

**Conjecture**: For a prime p ≡ 1 (mod 4), the set 𝔽_p[i]* equipped with Möbius addition modulo p forms a finite gyrogroup of order p² - 1. The number of "hyperbolic primes" (generators of this gyrogroup under Möbius addition) is exactly φ(p² - 1), where φ is Euler's totient function.

**Test**: For p = 5, 13, 17, 29, enumerate all elements of 𝔽_p[i]* and compute the Möbius addition table. Verify the gyrogroup axioms (left identity, left inverse, gyroassociativity). Count generators and compare with φ(p² - 1).

**Impact**: This would create a finite model of hyperbolic number theory amenable to exhaustive computation, potentially revealing patterns invisible in the infinite case. Finite gyrogroups could also have applications to post-quantum cryptography (analogous to elliptic curve groups over finite fields).

**Catalog References**: `Algebra/CyclicGroupSubgroups.lean` (cyclic_group_unique_subgroup_of_card), `Cryptography/BerggrenLatticeCryptography.lean`

**Proof Strategy**:
1. Define Möbius addition on 𝔽_p[i] = 𝔽_p(√-1) for p ≡ 1 (mod 4).
2. Verify well-definedness (denominator 1 + z̄w ≠ 0 for generic z, w).
3. Prove the gyrogroup axioms by direct computation over the finite field.
4. Count generators by analyzing the order structure.

**Domain Bridges**: NumberTheory <-> Cryptography, Algebra <-> Computation

**Lineage**: Builds on `mobiusAdd_zero_left`, `mobiusAdd_zero_right`, `mobiusAdd_neg_self`, `gyration_preserves_normSq` from this cycle.

**Ambition**: extension

---

### Direction 5: Hyperbolic Zeta Function and Functional Equation

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{γ ∈ Γ\{id}} d_H(z₀, γ·z₀)^{-2s} for Γ = PSL(2,ℤ) converges for Re(s) > 1/2 and admits meromorphic continuation to all of ℂ. It satisfies a functional equation relating ζ_H(s) to ζ_H(1-s), with the critical line at Re(s) = 1/2.

**Test**: Compute ζ_H(s) for s = 0.6, 0.7, ..., 2.0 using the first 10,000 lattice distances. Verify convergence by comparing partial sums with N = 5000 and N = 10000. If the partial sums do not stabilize for Re(s) > 1/2, the convergence abscissa is different from conjectured.

**Impact**: A functional equation for ζ_H would be a major analytic result connecting hyperbolic geometry to L-functions. The Selberg zeta function (a related but different object) is known to satisfy a functional equation; establishing one for ζ_H would clarify the relationship between these objects.

**Catalog References**: `Logic/HyperbolicNumberTheory/Theorems.lean` (lattice_growth_conjecture, hypZetaPartial in Catalog), `Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**:
1. Establish the convergence abscissa using lattice counting asymptotics (N(R) ~ e^R/V).
2. Express ζ_H as a Mellin transform of the lattice counting function.
3. Use the lattice point kernel and its spectral expansion to derive the functional equation.
4. Connect to the Selberg zeta function via the identity relating distance sums to trace formulas.

**Domain Bridges**: NumberTheory <-> Physics, Algebra <-> Geometry

**Lineage**: Builds on `lattice_growth_conjecture` and `hypArea_exp_bound` from this cycle, and `critical_line_implies_unit_disk` from the Catalog.

**Ambition**: grand_challenge
