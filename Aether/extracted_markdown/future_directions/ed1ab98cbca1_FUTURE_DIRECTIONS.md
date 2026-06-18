# Future Directions: Machine-Verified Spectral Theory of Quantum Matter

This document outlines concrete next steps for extending the hydrogen atom formalization
into a comprehensive framework for verified quantum mechanics.

---

## Direction 1: Full Self-Adjoint Operator Framework for Coulomb Hamiltonians

### Theorem Statement
```
theorem hydrogen_selfadjoint :
  IsSelfAdjoint (hydrogenHamiltonian : UnboundedOperator (L2 ℝ³ ℂ))
```

### Proof Strategy
1. Define unbounded operators on L² with dense domains (Sobolev spaces H²)
2. Establish the Kato–Rellich theorem: if V is relatively bounded w.r.t. -Δ
   with relative bound < 1, then -Δ + V is self-adjoint on dom(-Δ)
3. Prove that the Coulomb potential -2/r satisfies the Kato condition in 3D
4. Apply Kato–Rellich to conclude self-adjointness

### Dependencies
- Mathlib's `MeasureTheory.Lp` for L² spaces
- Sobolev space infrastructure (currently absent from Mathlib)
- Distribution theory for weak derivatives
- Kato–Rellich theorem (new formalization required)

### Cross-Domain Significance
Self-adjointness is the mathematical foundation guaranteeing real spectrum,
unitary time evolution, and the spectral theorem. This is prerequisite for:
- Scattering theory (continuous spectrum characterization)
- Time-dependent quantum mechanics
- Quantum information (unitary channels from Hamiltonians)
- Any rigorous spectral analysis of quantum systems

---

## Direction 2: Wigner–Eckart Theorem and Tensor Operators

### Theorem Statement
```
theorem wigner_eckart
  (T : TensorOperator k) (j j' : ℕ) (m m' q : ℤ)
  (hm : Int.natAbs m ≤ j) (hm' : Int.natAbs m' ≤ j') (hq : Int.natAbs q ≤ k) :
  ⟨j', m' | T q | j, m⟩ =
    clebschGordan j m k q j' m' * reducedMatrixElement T j j'
```

### Proof Strategy
1. Define irreducible tensor operators under SO(3) action
2. Formalize Clebsch–Gordan coefficients via the representation theory
   of su(2) highest-weight modules
3. Prove the Wigner–Eckart theorem by decomposing the matrix element
   into a geometric factor (Clebsch–Gordan) and a dynamical factor
   (reduced matrix element)
4. The key step is showing that the space of intertwining operators
   between two irreps is at most one-dimensional (Schur's lemma)

### Dependencies
- Lie algebra representations of su(2)/so(3) (partially in Mathlib)
- Clebsch–Gordan decomposition (new)
- Schur's lemma for Lie algebra representations
- Current angular momentum commutation relations (from this work)

### Cross-Domain Significance
- **Selection rules**: The Wigner–Eckart theorem gives ALL selection rules
  for multipole transitions, not just the dipole rules proved here
- **Quantum information**: Symmetry-adapted bases for quantum error correction
- **Nuclear physics**: Nuclear matrix elements and transition rates
- **Atomic physics**: Systematic calculation of transition amplitudes

---

## Direction 3: Zeeman and Stark Perturbation Splittings

### Theorem Statement
```
theorem zeeman_first_order_splitting
  (n : ℕ+) (l : ℕ) (hl : l < n) (m : ℤ) (hm : Int.natAbs m ≤ l) (B : ℝ) :
  firstOrderEnergyCorrection (zeemanPerturbation B) (hydrogenEigenstate n l m) =
    (m : ℝ) * bohrMagneton * B

theorem stark_first_order_vanishing
  (n : ℕ+) (l : ℕ) (hl : l < n) (m : ℤ) (hm : Int.natAbs m ≤ l) :
  firstOrderEnergyCorrection (starkPerturbation) (hydrogenEigenstate n l m) = 0
```

### Proof Strategy
1. Formalize first-order perturbation theory: E⁽¹⁾ = ⟨ψ|V|ψ⟩
2. For Zeeman: V = -μ·B = (eB/2mₑ)Lz. Since Lz|n,l,m⟩ = m|n,l,m⟩,
   the first-order correction is proportional to m
3. For Stark: V = eEz = eEr cos θ. By parity, ⟨n,l,m|z|n,l,m⟩ = 0
   when the state has definite parity (which hydrogen eigenstates do)
4. Second-order Stark effect requires degenerate perturbation theory

### Dependencies
- Hydrogen eigenstates and eigenvalues (from this work)
- Inner product on L²(ℝ³)
- Parity operator formalization
- Selection rules (from this work, extended to quadrupole)

### Cross-Domain Significance
- **Spectroscopy**: Zeeman/Stark effects are the primary tools for
  measuring atomic energy levels and testing QED corrections
- **Quantum computing**: Stark effect is used for qubit control in
  Rydberg atom quantum computers
- **Astrophysics**: Zeeman splitting measures stellar magnetic fields

---

## Direction 4: Scattering States and Continuous Spectrum [0, ∞)

### Theorem Statement
```
theorem hydrogen_continuous_spectrum :
  essentialSpectrum hydrogenHamiltonian = Set.Ici 0

theorem hydrogen_full_spectrum :
  spectrum ℂ hydrogenHamiltonian =
    {z : ℂ | (∃ n : ℕ+, z = hydrogenEnergy n) ∨ (0 ≤ z.re ∧ z.im = 0)}
```

### Proof Strategy
1. Prove the Weyl criterion: E is in the essential spectrum iff there
   exists a Weyl sequence (approximate eigenvectors that escape to infinity)
2. Construct explicit Weyl sequences for E ≥ 0 using truncated plane waves
3. Show E < 0, E ∉ {-1/n²} is not in the spectrum by analyzing the
   radial ODE and showing no L² solution exists
4. Use the decomposition σ(H) = σ_pp(H) ∪ σ_ess(H)

### Dependencies
- Self-adjoint operator framework (Direction 1)
- Weyl criterion (new formalization)
- Asymptotic analysis of radial wavefunctions
- Sturm–Liouville theory

### Cross-Domain Significance
- **Scattering theory**: The continuous spectrum corresponds to
  scattering states (ionized electron)
- **Photoionization**: Cross-sections for photon absorption above
  the ionization threshold
- **Inverse problems**: Recovering potentials from scattering data

---

## Direction 5: Clebsch–Gordan Decomposition and Many-Electron Systems

### Theorem Statement
```
theorem clebsch_gordan_decomposition (j₁ j₂ : ℕ) :
  tensorProduct (irrep j₁) (irrep j₂) ≅
    ⨁ J in Finset.Icc (Int.natAbs (j₁ - j₂)) (j₁ + j₂), irrep J

theorem clebsch_gordan_orthogonality (j₁ j₂ J J' : ℕ) (M M' : ℤ) :
  ∑ m₁ m₂, clebschGordan j₁ m₁ j₂ m₂ J M * clebschGordan j₁ m₁ j₂ m₂ J' M' =
    if J = J' ∧ M = M' then 1 else 0
```

### Proof Strategy
1. Define the tensor product of two su(2) representations
2. Use highest-weight theory: find the highest-weight vectors in
   V_{j₁} ⊗ V_{j₂} by solving L₊(v₁ ⊗ v₂ + ...) = 0
3. Show the multiplicities are all 1 by dimension counting:
   (2j₁+1)(2j₂+1) = Σ_{J=|j₁-j₂|}^{j₁+j₂} (2J+1)
4. Construct Clebsch–Gordan coefficients recursively using ladder operators

### Dependencies
- su(2) representation theory (partially in Mathlib)
- Angular momentum algebra (from this work)
- Tensor product of representations
- Dimension formula (related to degeneracy count from this work)

### Cross-Domain Significance
- **Many-electron atoms**: Angular momentum coupling for multi-electron
  configurations (Russell–Saunders coupling, jj-coupling)
- **Nuclear physics**: Coupling of nuclear spins and orbital momenta
- **Quantum information**: Decomposition of multi-qubit symmetric subspaces
- **Particle physics**: SU(2) isospin decomposition

---

## Additional Directions (Lower Priority)

### 6. Associated Legendre Polynomials and Orthogonal Polynomial Theory
Formalize P_l^m(x) via Rodrigues' formula, prove the orthogonality relation
∫₋₁¹ P_l^m(x) P_l'^m(x) dx = δ_{ll'} · 2(l+m)!/((2l+1)(l-m)!),
connecting to the general theory of classical orthogonal polynomials.

### 7. Laguerre Polynomials and Radial Wavefunctions
Define generalized Laguerre polynomials L_n^α(x), prove orthogonality
with respect to the weight x^α e^{-x}, and show the radial hydrogen
wavefunctions R_{nl}(r) ∝ r^l e^{-r/n} L_{n-l-1}^{2l+1}(2r/n) satisfy
the radial Schrödinger equation.

### 8. Rydberg Formula and Spectral Series
Formally verify the Rydberg formula for all spectral series
(Lyman, Balmer, Paschen, Brackett, Pfund) and prove the series limits.
The Balmer series limit proved in this work is a prototype.

### 9. Hydrogen-like Ions
Generalize from hydrogen (Z=1) to hydrogen-like ions (arbitrary Z):
E_n(Z) = -Z²/n², with applications to He⁺, Li²⁺, etc.

### 10. Fine Structure and Relativistic Corrections
Formalize the leading relativistic corrections:
- Kinetic energy correction: -p⁴/(8m³c²)
- Spin-orbit coupling: (1/2m²c²)(1/r)(dV/dr)L·S
- Darwin term: (πℏ²/2m²c²)|ψ(0)|²
And prove the fine-structure formula E_{n,j} = E_n[1 + α²/n²(n/(j+1/2) - 3/4)].
