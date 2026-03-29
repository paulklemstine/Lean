# Research Notes: Pillar III — Spacetime Algebra

## Core Idea

Spacetime geometry is encoded in **Clifford algebras**. The Dirac equation,
spinors, and special relativity all emerge from the single algebraic relation:

> **eᵢeⱼ + eⱼeᵢ = 2gᵢⱼ**

where gᵢⱼ is the spacetime metric.

## Clifford Algebras

### Definition
Given a vector space V with quadratic form Q, the Clifford algebra Cl(V, Q)
is the quotient of the tensor algebra T(V) by the relation:

v ⊗ v = Q(v) · 1  for all v ∈ V

Equivalently: vw + wv = 2B(v,w) where B is the associated bilinear form.

### Key Examples

| Signature | Algebra | Dimension | Physics |
|---|---|---|---|
| Cl(0) | ℝ | 1 | Scalars |
| Cl(1) | ℂ | 2 | Complex numbers |
| Cl(0,1) | ℝ ⊕ ℝ | 2 | Split-complex numbers |
| Cl(0,2) | ℍ | 4 | Quaternions |
| Cl(3,0) | M₂(ℂ) | 8 | Pauli algebra (spin) |
| Cl(1,3) | M₄(ℝ) | 16 | Spacetime algebra |
| Cl(3,1) | M₂(ℍ) | 16 | Alt. spacetime convention |

### The Periodicity Theorem (Bott Periodicity)
Cl(n+8) ≅ Cl(n) ⊗ M₁₆(ℝ)

This 8-fold periodicity in Clifford algebras is deeply related to:
- Bott periodicity in K-theory
- The existence of division algebras (ℝ, ℂ, ℍ, 𝕆)
- The classification of topological insulators in condensed matter physics

## Spacetime Algebra Cl(1,3)

### Basis Elements

The algebra Cl(1,3) has basis {1, γμ, γμγν, γμγνγρ, γ₀γ₁γ₂γ₃}
with dimensions 1 + 4 + 6 + 4 + 1 = 16.

| Grade | Elements | Count | Physical Interpretation |
|---|---|---|---|
| 0 | 1 | 1 | Scalar |
| 1 | γ₀, γ₁, γ₂, γ₃ | 4 | Vectors (spacetime directions) |
| 2 | γ₀₁, γ₀₂, γ₀₃, γ₂₃, γ₃₁, γ₁₂ | 6 | Bivectors (rotations, boosts) |
| 3 | γ₀₁₂, γ₀₁₃, γ₀₂₃, γ₁₂₃ | 4 | Pseudovectors |
| 4 | γ₀₁₂₃ = γ₅ | 1 | Pseudoscalar (chirality) |

### The Dirac Equation — Algebraically

The Dirac equation iγᵘ∂_μψ - mψ = 0 is simply:

**(D - m)ψ = 0**

where D = γᵘ∂_μ is the Dirac operator (a first-order differential operator
built from the Clifford algebra and derivatives).

The Dirac operator squared gives:
D² = ∂_μ∂ᵘ = □ (the wave operator)

This is the algebraic origin of the Klein-Gordon equation from the Dirac equation.

## Spinors as Algebraic Objects

### What is a Spinor?
A spinor is an element of a **minimal left ideal** of the Clifford algebra.

For Cl(1,3) ≅ M₄(ℝ):
- A minimal left ideal is a column of 4×4 matrices
- This is a 4-dimensional real vector space
- Complexified: Dirac spinor ∈ ℂ⁴

### Spin Groups
The spin group Spin(p,q) sits inside the Clifford algebra:
Spin(p,q) = {s ∈ Cl(p,q)^× : s = v₁v₂···v₂ₖ, each vᵢ ∈ V, Q(vᵢ) = ±1}

Key facts:
- Spin(3) ≅ SU(2) — the double cover of SO(3)
- Spin(1,3) ≅ SL(2,ℂ) — the double cover of the Lorentz group SO⁺(1,3)
- The spin representation is the fundamental representation of the spin group

## Geometric Algebra: Physics in Cl(1,3)

David Hestenes' program: reformulate ALL of physics using Cl(1,3).

### Maxwell's Equations (Single Equation!)
Define the electromagnetic field as a bivector:
F = Eᵢγᵢγ₀ + Bᵢ(½εᵢⱼₖγⱼγₖ)

Then ALL FOUR Maxwell equations become:
**∂F = J**

where ∂ = γᵘ∂_μ and J is the current 4-vector.

### Lorentz Transformations
A Lorentz transformation is: x ↦ RxR̃
where R ∈ Spin(1,3) and R̃ is the Clifford conjugate.

Rotations: R = exp(θ/2 · γᵢγⱼ) (spatial bivector)
Boosts: R = exp(φ/2 · γ₀γᵢ) (spacetime bivector)

## Connection to Spectral Triples

The Dirac operator D on a spin manifold M gives a spectral triple:
(C^∞(M), L²(M, S), D)

The Clifford algebra acts on the spinor bundle S, and:
- Distance: d(p,q) = sup{|f(p) - f(q)| : ‖[D,f]‖ ≤ 1}
- Dimension: recovered from the growth of eigenvalues of D
- Integration: ∫f = Tr_ω(f|D|^{-n}) (Dixmier trace)

The geometry of spacetime is ENTIRELY encoded in the algebraic data (A, H, D).
