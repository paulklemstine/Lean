# Research Notes: Pillar I — Observable Algebras

## Core Idea

The fundamental insight of algebraic quantum mechanics is that **physics is about
algebras of observables**, not wavefunctions or particles or fields.

## Historical Development

1. **1925 — Heisenberg:** Discovered matrix mechanics. Observables are matrices (a noncommutative algebra).
2. **1932 — von Neumann:** Formalized quantum mechanics using operators on Hilbert space.
3. **1943 — Gelfand & Naimark:** Proved that commutative C*-algebras are function algebras.
4. **1964 — Haag & Kastler:** Proposed Algebraic QFT — assign C*-algebras to spacetime regions.
5. **1994 — Connes:** Noncommutative geometry spectral action reproduces Standard Model.

## Key Definitions

### C*-algebra
A Banach algebra A over ℂ with an involution * such that:
- ‖a*a‖ = ‖a‖² (C*-identity)

This single axiom forces the algebra to behave like an algebra of operators.

### States
A state on A is a positive linear functional ω : A → ℂ with ω(1) = 1.

The **state space** S(A) is a convex set. Pure states are extreme points.

### GNS Construction
Every state ω on A gives a *-representation π_ω : A → B(H_ω).

This means: **states and representations are two faces of the same coin.**

## The Classical-Quantum Dictionary

| Classical Physics | Quantum Physics |
|---|---|
| Phase space (M, ω) | C*-algebra A |
| Points of M | Pure states on A |
| Smooth functions C^∞(M) | Self-adjoint elements of A |
| Poisson bracket {f,g} | Commutator (i/ℏ)[a,b] |
| Probability measure μ | Mixed state (density matrix) ρ |
| Observable = function | Observable = self-adjoint operator |
| Commutativity | Noncommutativity |

## Key Theorem: Gelfand-Naimark

**Theorem.** *If A is a commutative C*-algebra with unit, then A ≅ C(X) where X is
a compact Hausdorff space (the Gelfand spectrum of A).*

**Physical meaning:** Classical physics (commutative observables) is equivalent to
function theory on a space. The space IS the algebra. The algebra IS the space.

**Noncommutative generalization:** A noncommutative C*-algebra is a "quantum space" —
it has no underlying point set, yet retains algebraic structure analogous to topology.

## Examples

### Example 1: Classical Particle
- A = C(T*M) — continuous functions on phase space
- States = probability measures on T*M
- Dynamics: αₜ(f) = f ∘ φₜ where φₜ is Hamiltonian flow

### Example 2: Single Qubit
- A = M₂(ℂ) — 2×2 complex matrices
- States = density matrices: ρ ≥ 0, Tr(ρ) = 1
- Pure states = Bloch sphere S² ≅ ℂP¹
- Dynamics: αₜ(a) = e^{iHt} a e^{-iHt}

### Example 3: Quantum Field Theory
- A = ⊗_{x ∈ spacetime} A_x — tensor product over spacetime points
- Locality: [A_x, A_y] = 0 when x, y are spacelike separated
- Dynamics: Heisenberg evolution of field operators

## Experimental Validation

The algebraic framework makes identical predictions to standard quantum mechanics
because it IS standard quantum mechanics, just expressed differently. But it also:
- Naturally handles infinite-dimensional systems (no need for rigged Hilbert spaces)
- Makes superselection rules manifest
- Provides a rigorous framework for QFT (Haag-Kastler axioms)
- Naturally incorporates thermodynamics (KMS states)

## Notes for Formalization

Key structures to formalize in Lean:
1. C*-algebra (extends Banach algebra with involution)
2. States as positive linear functionals
3. GNS construction
4. Gelfand spectrum

Mathlib has: `CStarAlgebra`, `StarAlgebra`, `spectrum`, `NNNorm`
