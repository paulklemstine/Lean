# Iteration Log — Algebraic Theory of Magnetism

## Cycle 1: Hypothesis Formation

**Date:** Research Day 1

### What we proposed:
- Magnetic phenomena can be systematically organized by algebraic structures
- The Lie algebra 𝔰𝔲(2) is the fundamental building block
- All standard models are quotients/subalgebras of a universal structure

### What we tested:
- Verified that Ising, XY, Heisenberg models emerge from 𝔰𝔲(2) projections ✓
- Checked that the Clebsch-Gordan series correctly predicts ferro/antiferro ✓
- Confirmed that the Kitaev model requires going beyond simple 𝔰𝔲(2) ✓

### What we learned:
- The framework naturally accommodates all bilinear models
- The Kitaev model requires bond-dependent interactions → needs the full
  exchange tensor decomposition, not just isotropic coupling
- Compass models similarly need anisotropic exchange

### Updates:
- Extended the exchange tensor decomposition to include all 9 components
- Added the DM interaction as the antisymmetric part explicitly

---

## Cycle 2: Algebraic Order Parameters

**Date:** Research Day 2

### What we proposed:
- Order parameters are algebra homomorphisms φ: 𝔐 → 𝔄_order
- Phase transitions = changes in the kernel of φ

### What we tested:
- Ferromagnet: φ(S_total) = m ∈ ℝ³, breaks SO(3) → SO(2) ✓
- Antiferromagnet: φ(N_staggered) = n, breaks SO(3) × T → SO(2) ✓
- Spin liquid: φ trivial, order is in the center of a gauge algebra ✓

### What we learned:
- The algebraic order parameter framework subsumes Landau theory
- It also captures topological order (where φ is trivial)
- The coset space G/H naturally emerges from ker(φ)

### Updates:
- Formalized the stabilizer subalgebra concept
- Connected to the classification of symmetric spaces

---

## Cycle 3: Dynamics and Magnons

**Date:** Research Day 3

### What we proposed:
- Landau-Lifshitz equation is a coadjoint orbit flow
- Magnons arise from algebra contraction (𝔰𝔲(2) → Heisenberg-Weyl)

### What we tested:
- Verified LL equation on S² with correct symplectic structure ✓
- Holstein-Primakoff map is an algebra homomorphism (to leading order) ✓
- Magnon dispersion ω(k) = Dk² follows from the algebraic structure ✓

### What we learned:
- The coadjoint orbit picture gives a clean derivation of spin dynamics
- The 1/s expansion is systematically organized by algebra deformation theory
- Quantum corrections correspond to higher-order terms in the deformation

### Updates:
- Added the Dyson-Maleev representation as an alternative algebra map
- Connected to the theory of quantum groups (q-deformation with q = e^{i/s})

---

## Cycle 4: Topological Aspects

**Date:** Research Day 4

### What we proposed:
- Topological magnetic textures classified by homotopy groups of G/H
- These can be computed from the algebraic data

### What we tested:
- Skyrmions: π₂(S²) = ℤ gives integer topological charge ✓
- Domain walls: π₀(S⁰) = ℤ₂ for Ising, π₀(S¹) = 0 for XY ✓  
- Vortices: π₁(S¹) = ℤ for XY model (BKT transition) ✓
- Hedgehogs: π₂(S²) = ℤ in 3D Heisenberg ✓

### What we learned:
- The algebraic classification of order parameter spaces directly gives
  the topological defect classification
- This is a genuine prediction: given the exchange tensor, we can compute
  which topological textures are stable

### Updates:
- Created comprehensive table of magnetic textures × algebraic invariants
- Added connection to algebraic K-theory for topological insulators

---

## Cycle 5: Validation Against Known Results

**Date:** Research Day 5

### What we proposed:
- The algebraic theory should reproduce all classic results

### What we tested:
1. **Curie-Weiss mean field theory:**
   Algebraic mean field = project 𝔐_Λ → 𝔰𝔲(2)_eff via mean field map
   Result: Tc = zJs(s+1)/3 ✓ (matches standard result)

2. **Mermin-Wagner theorem:**
   No spontaneous breaking of continuous symmetry in d ≤ 2
   Algebraic proof: magnon number ⟨a†a⟩ diverges for d ≤ 2 ✓

3. **Bloch's T^{3/2} law:**
   Magnetization M(T) = M(0)(1 - BT^{3/2}) for 3D ferromagnet
   Follows from magnon density of states g(ω) ~ ω^{1/2} ✓

4. **Haldane conjecture:**
   Integer-spin chains are gapped; half-integer are gapless
   Algebraic origin: representation theory of 𝔰𝔲(2) distinguishes
   integer (real) vs half-integer (pseudoreal) representations ✓

### Updates:
- All classic results reproduced within the algebraic framework
- The framework provides a unifying perspective on seemingly disparate results

---

## Cycle 6: Novel Predictions

**Date:** Research Day 6

### Predictions from the algebraic theory:

**P1: Algebraic Spin Liquids**
For certain lattice geometries, the magnetic algebra has a non-trivial center
that supports deconfined gauge fields. The algebraic theory predicts the
gauge group from the lattice symmetry.

**P2: Representation-Theoretic Phase Boundaries**
Phase transitions between different magnetic orders correspond to level crossings
in the representation-theoretic spectrum. The algebraic theory predicts the
critical exchange ratios where transitions occur.

**P3: Higher-Order Multipole Magnets**
Beyond dipolar (vector) order, the algebraic theory predicts quadrupolar
(s ≥ 1), octupolar (s ≥ 3/2), and higher multipole phases, classified by
the symmetric tensor representations of 𝔰𝔲(2).

**P4: Algebraic Constraints on Magnon Interactions**
The Clebsch-Gordan decomposition constrains which magnon scattering processes
are allowed, predicting the form of magnon-magnon interactions from symmetry
alone.
