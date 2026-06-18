# 📓 Research Notes: The Algebraic Theory of Electricity

## Session 1: What Algebraic Structure Does a Circuit Have?

### Observation 1: Impedances form a field
Consider impedances in AC circuit analysis:
- Resistor: Z_R = R (real)
- Capacitor: Z_C = 1/(jωC) (imaginary)
- Inductor: Z_L = jωL (imaginary)

These are elements of ℂ. Series combination is addition; parallel combination is
the "harmonic sum" Z₁ ‖ Z₂ = (Z₁⁻¹ + Z₂⁻¹)⁻¹ = Z₁Z₂/(Z₁ + Z₂).

**Key insight:** The parallel operator is NOT a new binary operation — it's
*derived* from the field operations. Specifically, ‖ is the harmonic mean
transported through the field inverse. This means we don't need a new algebraic
structure; the field ℂ is sufficient.

**Theorem (Impedance Field):** The set of complex impedances, under series (addition)
and the inherited field structure of ℂ, forms a field. The parallel operation is a
derived operation: a ‖ b = (a⁻¹ + b⁻¹)⁻¹.

### Observation 2: Kirchhoff's laws are linear algebra
Given a circuit graph G = (V, E):
- KCL (Current Law): For each node, Σ currents = 0 → currents ∈ ker(∂₁)
- KVL (Voltage Law): Around each loop, Σ voltages = 0 → voltages ∈ ker(∂₁*)

Here ∂₁: C₁(G) → C₀(G) is the boundary map of the graph's chain complex.
KCL says current is a 1-cycle; KVL says voltage is a 1-cocycle.

**This is homological algebra!**

### Observation 3: The graph Laplacian encodes everything
The graph Laplacian L = ∂₁∂₁ᵀ (or equivalently D - A where D is degree matrix,
A is adjacency matrix) contains all the topological information:
- rank(L) = |V| - (number of connected components)
- nullity(L) = number of connected components
- The eigenvalues of L determine the network's natural frequencies

**Connection to physics:** The Laplacian is the discrete analog of the
continuous Laplacian ∇², which governs electrostatics (∇²φ = -ρ/ε₀).

---

## Session 2: Maxwell's Equations as Algebraic Identities

### The differential forms perspective
Let M be a 4-dimensional spacetime manifold. Define:
- A ∈ Ω¹(M) — the electromagnetic potential (1-form)
- F = dA ∈ Ω²(M) — the field strength (2-form)
- J ∈ Ω³(M) — the current density (3-form)

Maxwell's equations become:
1. **dF = 0** (Bianchi identity — automatic since d² = 0)
2. **d★F = J** (dynamical equation)

That's it. Two equations. The entire theory of electromagnetism.

### The algebraic content
- **d** is the exterior derivative: a graded derivation on Ω*(M)
- **★** is the Hodge star: depends on the metric (constitutive relations)
- **d² = 0** is an algebraic identity — it gives us the Bianchi identity *for free*
- The **de Rham cohomology** H*(M) = ker(d)/im(d) classifies topological charges

### The gauge symmetry
A ↦ A + dχ leaves F = dA invariant (since d(dχ) = 0).
This is the U(1) gauge symmetry. Algebraically, it says the physics lives in
the cohomology class [A], not in A itself.

**Profound:** Charge quantization follows from the topology of U(1).
Since π₁(U(1)) = ℤ, charges come in integer multiples of e.

---

## Session 3: The Circuit-Maxwell Connection

### Discrete → Continuous
| Circuit (Discrete) | Maxwell (Continuous) |
|---|---|
| Graph G = (V, E) | Manifold M |
| Chain complex C*(G) | de Rham complex Ω*(M) |
| Boundary map ∂ | Exterior derivative d |
| Graph Laplacian L | Laplace-de Rham Δ = dδ + δd |
| KCL (cycle condition) | dF = 0 (Bianchi) |
| KVL (cocycle condition) | d★F = J (dynamics) |
| Current (1-chain) | Current 3-form J |
| Voltage (0-cochain) | Potential 1-form A |

This is not merely analogy — it's a *functor* from the category of graphs
to the category of chain complexes, which is the *same functor* that maps
manifolds to their de Rham complexes.

### The Key Theorem
**Theorem (Algebraic Electricity):** Let G be a connected circuit graph with
n nodes and m edges. Then:
1. dim(cycle space) = m - n + 1 (= first Betti number β₁)
2. dim(cocycle space) = n - 1
3. The circuit equations Ohm + Kirchhoff are equivalent to the equation
   (∂₁ᵀ Z ∂₁) v = ∂₁ᵀ Z e, where Z is the diagonal impedance matrix and
   e is the source vector.
4. This equation is the discrete Hodge-theoretic decomposition.

---

## Session 4: Symmetry and Conservation Laws

### Noether's Theorem for Circuits
Every continuous symmetry of the Lagrangian gives a conservation law:
- **U(1) gauge symmetry** → charge conservation (∂ₜρ + ∇·J = 0)
- **Time translation** → energy conservation (Poynting theorem)
- **Space translation** → momentum conservation (Maxwell stress tensor)

### Discrete symmetries in circuits
- **Duality** (series ↔ parallel, voltage source ↔ current source):
  This is an algebraic involution on the circuit algebra.
- **Reciprocity** (Lorentz reciprocity theorem):
  Transfer impedance is symmetric: Z₁₂ = Z₂₁.
  Algebraically, the impedance matrix is symmetric.
- **Thévenin-Norton equivalence**: Every one-port network is isomorphic
  to either a voltage source + series impedance OR current source + parallel
  impedance. These are the two canonical forms under the duality involution.

---

## Session 5: The Clifford Algebra of Electromagnetism

### Geometric algebra formulation
The electromagnetic field in geometric algebra Cl(1,3):
F = E + IB where I = e₀e₁e₂e₃ is the pseudoscalar.

Maxwell's equations unify to a single equation:
**∇F = J/ε₀**

where ∇ = eᵘ∂ᵘ is the spacetime gradient (a vector derivative in the algebra).

### Why Clifford algebra?
- It naturally encodes both E and B as parts of a single multivector
- The geometric product ab = a·b + a∧b unifies dot and cross products
- Rotations (Lorentz transformations) are: F ↦ RFR̃ where R is a rotor
- Energy density is a scalar: ½F†F = ½(E² + B²)
- Poynting vector is a bivector component of F†F

### The algebraic hierarchy
```
ℝ ⊂ ℂ ⊂ ℍ ⊂ Cl(3,0) ⊂ Cl(1,3)
 ↓    ↓    ↓      ↓         ↓
 DC   AC  Quat.  Space   Spacetime
      phasors     EM        EM
```

Each level adds algebraic structure to handle more physics:
- ℝ: DC circuits (resistive)
- ℂ: AC circuits (phasors, impedance)
- ℍ: Quaternionic representation (rotation of fields)
- Cl(3,0): Spatial electromagnetism (E, B as bivectors)
- Cl(1,3): Full relativistic electromagnetism

---

## Session 6: Quantization — From Algebra to Operators

### The Fock space construction
Start with the 1-particle Hilbert space H = L²(ℝ³) ⊗ ℂ² (spatial modes × polarization).
The photon Fock space is the symmetric (bosonic) algebra:

**F(H) = ⊕ₙ Sⁿ(H) = ℂ ⊕ H ⊕ S²(H) ⊕ ...**

This is literally the free commutative algebra generated by H!

### Creation and annihilation
- a†(f): S^n(H) → S^{n+1}(H) — creation (adds a photon)
- a(f): S^n(H) → S^{n-1}(H) — annihilation (removes a photon)
- [a(f), a†(g)] = ⟨f, g⟩ — the canonical commutation relation

**The CCR algebra is the algebraic core of QED.**

### The fine structure constant
α = e²/(4πε₀ℏc) ≈ 1/137

This dimensionless number is the *coupling constant* of the U(1) gauge theory.
It measures the strength of the electromagnetic interaction.

Algebraically, α determines the *representation theory* of the theory:
perturbation theory is an expansion in powers of √α.

---

## Key Theorems to Formalize

1. ✅ Impedance Field Theorem
2. ✅ Kirchhoff's Laws as Homological Conditions
3. ✅ Maxwell-de Rham Equivalence
4. ✅ Noether's Theorem (U(1) → charge conservation)
5. ✅ Thévenin-Norton Duality
6. ✅ Clifford Algebra Unification of E and B
7. ✅ Fock Space as Symmetric Algebra

## References
- Baez & Muniain, *Gauge Fields, Knots, and Gravity* (1994)
- Frankel, *The Geometry of Physics* (3rd ed., 2011)
- Hestenes, *Space-Time Algebra* (1966)
- Bollobás, *Modern Graph Theory* (1998)
- Weinberg, *The Quantum Theory of Fields, Vol. 1* (1995)
