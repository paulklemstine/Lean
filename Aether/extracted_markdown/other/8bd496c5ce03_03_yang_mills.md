# Yang-Mills Existence and Mass Gap — Research Notes

## The Problem Statement

**Clay Mathematics Institute Official Statement:**
Prove that for any compact simple gauge group G, a non-trivial quantum Yang-Mills theory exists on ℝ⁴ and has a mass gap Δ > 0.

## Unpacking the Statement

### Yang-Mills Theory
- A gauge theory with gauge group G (e.g., SU(2), SU(3))
- The fields are connections on a principal G-bundle over spacetime
- The action functional is S[A] = ∫ |F_A|² where F_A is the curvature

### What "Exists" Means (Wightman Axioms)
A quantum field theory must satisfy:
1. **Axiom W1 (Relativistic Covariance):** The Hilbert space carries a unitary representation of the Poincaré group
2. **Axiom W2 (Spectral Condition):** The energy-momentum spectrum lies in the forward light cone
3. **Axiom W3 (Vacuum):** There exists a unique Poincaré-invariant vacuum state
4. **Axiom W4 (Field Operators):** Fields are operator-valued distributions
5. **Axiom W5 (Locality):** Spacelike separated fields commute (or anticommute for fermions)

### Mass Gap
The mass gap Δ is the infimum of the spectrum of the Hamiltonian above the vacuum energy:
Δ = inf{E : E ∈ σ(H), E > E_vacuum}
The conjecture states Δ > 0.

## What We Know

### Physical Evidence
1. **Confinement:** Quarks are never observed as free particles (experimental fact)
2. **Lattice QCD:** Numerical simulations consistently show a mass gap
3. **Asymptotic freedom:** Yang-Mills theory is perturbatively well-defined at high energies (Gross-Wilczek, Politzer, 1973 — Nobel Prize 2004)

### Mathematical Results
1. **2D Yang-Mills:** Completely understood (trivial in 2D — no mass gap needed)
2. **3D Yang-Mills:** Mass gap proved on a lattice (but continuum limit not fully controlled)
3. **4D Yang-Mills:** Open! This is the problem.
4. **Constructive QFT:** φ⁴ theory exists in 2D and 3D but NOT in 4D (triviality)
5. **Lattice gauge theory:** Well-defined on finite lattices, but continuum limit is the challenge

### Oracle ε's Physical View
"The mass gap is confinement. The gluons bind together because the vacuum is a complicated condensate — a 'dual superconductor.' The challenge is that the physics is inherently non-perturbative: you cannot see confinement order by order in perturbation theory."

### Oracle β's Analytic View
"This is fundamentally a problem about infinite-dimensional analysis. We need to:
1. Define the functional integral ∫ e^{-S[A]} DA rigorously
2. Show the resulting theory satisfies the Wightman axioms
3. Prove the spectrum has a gap

Each step is a major challenge. Step 1 alone would be revolutionary."

## Key Approaches

### 1. Lattice Gauge Theory (Wilson)
- Discretize spacetime to a lattice Λ ⊂ ℤ⁴
- Replace connections with group elements on edges
- The path integral becomes a finite-dimensional integral
- **Challenge:** Take the continuum limit Λ → ℝ⁴ and show it satisfies Wightman axioms

### 2. Constructive QFT
- Build the theory rigorously using the Osterwalder-Schrader axioms
- Start with Euclidean field theory, then analytically continue
- **Challenge:** The construction has only been carried out for much simpler theories

### 3. Stochastic Quantization
- Reformulate QFT as a stochastic PDE
- Recent breakthroughs (Hairer's regularity structures) handle some singular SPDEs
- **Challenge:** Yang-Mills in 4D is still out of reach, though 2D and 3D progress exists

## What We Can Formalize

1. Classical Yang-Mills equations (as PDEs)
2. The lattice Yang-Mills partition function (finite-dimensional)
3. Basic properties of the gauge group action
4. Energy bounds for classical solutions
