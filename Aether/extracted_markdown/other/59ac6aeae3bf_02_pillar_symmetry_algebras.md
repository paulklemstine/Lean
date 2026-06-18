# Research Notes: Pillar II — Symmetry Algebras

## Core Idea

**Every symmetry of a physical system is an automorphism of its observable algebra.**
Conservation laws are generators of continuous symmetry groups — this is Noether's theorem,
restated algebraically.

## The Algebraic Noether's Theorem

### Classical Version (Lie algebra homomorphism)
Given a Hamiltonian system (M, ω, H) with symmetry group G:
- G acts on M preserving ω (symplectomorphisms)
- The Lie algebra 𝔤 maps to Hamiltonian vector fields
- There exists a **moment map** μ : M → 𝔤* such that
  - For each ξ ∈ 𝔤, the function ⟨μ, ξ⟩ generates the flow of ξ_M
  - μ is G-equivariant

This gives: **𝔤 → (C^∞(M), {·,·})** is a Lie algebra homomorphism.

### Quantum Version (Derivations of C*-algebras)
Given a quantum system (A, αₜ) with symmetry group G:
- G acts on A by *-automorphisms: g ↦ α_g
- Infinitesimally: 𝔤 → Der(A), the Lie algebra of derivations
- Each ξ ∈ 𝔤 gives a derivation δ_ξ(a) = d/dt|_{t=0} α_{exp(tξ)}(a)
- If δ_ξ is inner (δ_ξ(a) = i[Q_ξ, a]), then Q_ξ is the conserved charge

### The Bridge
| Symmetry | Classical Generator | Quantum Generator |
|---|---|---|
| Time translation | Hamiltonian H | Hamiltonian Ĥ |
| Space translation | Momentum p | Momentum p̂ |
| Rotation | Angular momentum L | Angular momentum L̂ |
| U(1) gauge | Electric charge Q | Charge operator Q̂ |
| SU(3) gauge | Color charges | Gell-Mann matrices λᵢ |

## Representation Theory as Particle Physics

**The deepest insight:** Particles ARE irreducible representations of symmetry algebras.

### Wigner's Classification (1939)
Elementary particles = irreducible unitary representations of the Poincaré group
ISO(1,3) = SO(1,3) ⋉ ℝ⁴

Classified by two Casimir invariants:
1. **Mass:** m² = P_μ P^μ (eigenvalue of first Casimir)
2. **Spin:** s(s+1) = W_μ W^μ / m² (eigenvalue of second Casimir, W = Pauli-Lubanski)

| Representation | Particle |
|---|---|
| m > 0, s = 0 | Scalar (Higgs) |
| m > 0, s = 1/2 | Fermion (electron, quark) |
| m > 0, s = 1 | Massive vector (W±, Z) |
| m = 0, helicity ±1 | Photon, gluon |
| m = 0, helicity ±2 | Graviton (hypothetical) |

### Internal Symmetries
The quark model: representations of SU(3)_flavor

- **3** (fundamental): up, down, strange quarks
- **3̄** (conjugate): antiquarks
- **3 ⊗ 3̄ = 8 ⊕ 1**: meson octet + singlet
- **3 ⊗ 3 ⊗ 3 = 10 ⊕ 8 ⊕ 8 ⊕ 1**: baryon decuplet, octets, singlet

## The Lie Algebra Toolkit

### Key Lie Algebras in Physics

| Lie Algebra | Dimension | Physics |
|---|---|---|
| u(1) | 1 | Electromagnetism, phase symmetry |
| su(2) | 3 | Spin, isospin, weak force |
| su(3) | 8 | Strong force (QCD) |
| so(3) | 3 | Rotational symmetry |
| so(1,3) | 6 | Lorentz transformations |
| iso(1,3) | 10 | Poincaré symmetry (full spacetime) |
| sp(2n) | n(2n+1) | Canonical transformations |
| su(5) | 24 | Grand unification (Georgi-Glashow) |
| so(10) | 45 | Grand unification (SO(10) GUT) |
| e₈ | 248 | String theory, heterotic |

### Structure Constants
For su(2): [Jᵢ, Jⱼ] = iε_{ijk} Jₖ
For su(3): [Tᵃ, Tᵇ] = if^{abc} Tᶜ (8 generators, structure constants f^{abc})

## Key Algebraic Results

### Peter-Weyl Theorem
For a compact group G, L²(G) decomposes as:
L²(G) ≅ ⊕_π (dim π) · V_π
where π ranges over irreducible representations.

**Physical meaning:** The "harmonics" on a symmetry group are its representations.
Spherical harmonics are exactly this for SO(3).

### Schur's Lemma
If π is an irreducible representation and T commutes with all π(g), then T = λI.

**Physical meaning:** In a system with symmetry G, any observable commuting with all
symmetry operations must be a multiple of the identity on each irreducible subspace.
This is why quantum numbers are well-defined.

## Experimental Validation

The Eightfold Way: Gell-Mann predicted the Ω⁻ baryon (1962) purely from the
representation theory of SU(3). It was discovered in 1964.

This is the algebraic theory of physics in action: the algebra PREDICTED a particle.
