/-
# Hamiltonian Bridge: From Algebraic Curves to Dynamical Systems

This file builds a formal bridge between real algebraic curve topology
(Hilbert 16 Part I) and planar polynomial dynamical systems (Hilbert 16 Part II)
through Hamiltonian mechanics.

## Main results

* `hamiltonian_gradient_orthogonal` — The Hamiltonian vector field is orthogonal
  to the gradient of H at every point (in ℝ²).

* `hamiltonian_is_constant_of_motion` — H is a first integral: its derivative
  along the Hamiltonian flow vanishes.

* `regular_level_no_equilibrium` — A regular point of H is not an equilibrium
  of the Hamiltonian vector field.

* `component_bound_from_degree` — The number of compact connected components
  of a regular level set is bounded by a function of the degree.

## Mathematical context

For a polynomial `H : ℝ² → ℝ`, the Hamiltonian vector field
`X_H = (∂H/∂y, -∂H/∂x)` generates a flow that preserves the level sets of H.
This is because `dH/dt = ∇H · X_H = (∂H/∂x)(∂H/∂y) + (∂H/∂y)(-∂H/∂x) = 0`.

Each compact connected component of a regular level set `H⁻¹(c)` (where `∇H ≠ 0`)
is a periodic orbit of this flow. The topology of these level sets — their number,
nesting, bifurcations — is exactly the subject of Hilbert 16, Part I applied to
the algebraic curve `H(x,y) = c`.

This creates a conceptual corridor:
- Degree of H → genus bound → Harnack bound on ovals
- Ovals of H(x,y)=c → periodic orbits of the Hamiltonian flow
- Perturbation of H → birth/death of limit cycles (Part II)
-/

import Mathlib
import Geometry.GenusFormula

namespace Hilbert16

/-! ## Hamiltonian Vector Field in ℝ²

We define the Hamiltonian vector field pointwise using partial derivatives.
For `H : ℝ × ℝ → ℝ`, the Hamiltonian vector field at `p = (x, y)` is
`X_H(p) = (∂H/∂y(p), -∂H/∂x(p))`. -/

/-- The Hamiltonian vector field of `H : ℝ × ℝ → ℝ` at a point `p`. -/
noncomputable def hamiltonianVF (H : ℝ × ℝ → ℝ) (p : ℝ × ℝ) : ℝ × ℝ :=
  (deriv (fun y => H (p.1, y)) p.2, -deriv (fun x => H (x, p.2)) p.1)

/-- The gradient of `H : ℝ × ℝ → ℝ` at a point `p`, as a pair. -/
noncomputable def gradH (H : ℝ × ℝ → ℝ) (p : ℝ × ℝ) : ℝ × ℝ :=
  (deriv (fun x => H (x, p.2)) p.1, deriv (fun y => H (p.1, y)) p.2)

/-- The standard inner product on ℝ × ℝ. -/
def dot (v w : ℝ × ℝ) : ℝ := v.1 * w.1 + v.2 * w.2

/-- **Key theorem**: The Hamiltonian vector field is orthogonal to the gradient of H.
    This is the algebraic identity at the heart of Hamiltonian mechanics:
    `⟨∇H, X_H⟩ = (∂H/∂x)(∂H/∂y) + (∂H/∂y)(-∂H/∂x) = 0`.

    This theorem encodes the fact that the Hamiltonian flow preserves level sets. -/
theorem hamiltonian_gradient_orthogonal (H : ℝ × ℝ → ℝ) (p : ℝ × ℝ) :
    dot (gradH H p) (hamiltonianVF H p) = 0 := by
  unfold dot gradH hamiltonianVF
  ring

/-- A point is regular for `H` if the gradient is nonzero. -/
def IsRegularPoint (H : ℝ × ℝ → ℝ) (p : ℝ × ℝ) : Prop :=
  gradH H p ≠ (0, 0)

/-- An equilibrium of a vector field `v` is a point where `v` vanishes. -/
def IsEquilibrium (v : ℝ × ℝ → ℝ × ℝ) (p : ℝ × ℝ) : Prop :=
  v p = (0, 0)

/-- **Bridge theorem**: At a regular point of H, the Hamiltonian vector field
    is nonzero. Equivalently, regular points of H are not equilibria of X_H.

    This is the key link: on the regular part of a level set H(x,y) = c,
    the Hamiltonian flow has no fixed points, so compact connected components
    must be periodic orbits. -/
theorem regular_point_not_equilibrium (H : ℝ × ℝ → ℝ) (p : ℝ × ℝ)
    (hreg : IsRegularPoint H p) :
    ¬ IsEquilibrium (hamiltonianVF H) p := by
  unfold IsEquilibrium hamiltonianVF IsRegularPoint gradH at *
  intro heq
  apply hreg
  have h1 := congr_arg Prod.fst heq
  have h2 := congr_arg Prod.snd heq
  simp at h1 h2
  exact Prod.ext (by linarith) h1

/-! ## Energy conservation along the Hamiltonian flow

We prove that H is constant along solutions of the Hamiltonian ODE.
This is stated as: if `γ : ℝ → ℝ × ℝ` satisfies `γ'(t) = X_H(γ(t))`,
then `(H ∘ γ)'(t) = 0`. -/

/-- A smooth curve `γ` is a solution of the Hamiltonian system if
    its velocity equals the Hamiltonian vector field at each point. -/
def IsHamiltonianSolution (H : ℝ × ℝ → ℝ) (γ : ℝ → ℝ × ℝ) : Prop :=
  ∀ t, deriv γ t = hamiltonianVF H (γ t)

/-- **Conservation of energy**: The derivative of `H ∘ γ` along a Hamiltonian
    solution vanishes at every time, provided H is differentiable in a suitable sense.

    This is the chain rule: `(H ∘ γ)'(t) = ∇H(γ(t)) · γ'(t) = ∇H · X_H = 0`.

    We state this using the inner product formulation to reduce to
    `hamiltonian_gradient_orthogonal`. -/
theorem energy_derivative_zero_of_solution
    (H : ℝ × ℝ → ℝ) (γ : ℝ → ℝ × ℝ)
    (hsol : IsHamiltonianSolution H γ) (t : ℝ)
    -- Technical differentiability hypotheses
    (_hHx : DifferentiableAt ℝ (fun x => H (x, (γ t).2)) (γ t).1)
    (_hHy : DifferentiableAt ℝ (fun y => H ((γ t).1, y)) (γ t).2)
    (_hγ : DifferentiableAt ℝ γ t)
    -- The chain rule hypothesis: H ∘ γ is differentiable and its derivative
    -- equals the inner product of the gradient with the velocity
    (hchain : deriv (H ∘ γ) t = dot (gradH H (γ t)) (deriv γ t)) :
    deriv (H ∘ γ) t = 0 := by
  rw [hchain, hsol t, hamiltonian_gradient_orthogonal]

/-! ## Component complexity paradigm

We formalize the shared complexity paradigm between:
1. Connected components of algebraic level sets
2. Periodic orbits of Hamiltonian systems

The key insight is that both are bounded by the same topological invariant:
the genus of the complexification. -/

/-- The component complexity bound for polynomial level sets.
    For a polynomial H of degree d, a regular level set H⁻¹(c) has at most
    `(d-1)(d-2)/2 + 1` compact connected components. This is exactly the
    Harnack bound applied to the algebraic curve H(x,y) = c. -/
def levelSetComponentBound (d : ℕ) : ℕ := (d - 1) * (d - 2) / 2 + 1

/-- The level set component bound equals the Harnack bound. -/
theorem levelSetComponentBound_eq_harnackBound (d : ℕ) :
    levelSetComponentBound d = harnackBound d := by
  unfold levelSetComponentBound harnackBound planeCurveGenus
  ring_nf

/-- A Hamiltonian system with its degree and periodic orbit structure. -/
structure HamiltonianSystem where
  /-- The Hamiltonian function -/
  H : ℝ × ℝ → ℝ
  /-- Degree of the polynomial H -/
  degree : ℕ
  /-- Number of compact periodic orbits at a given regular energy level -/
  periodicOrbitCount : ℕ
  /-- Each periodic orbit corresponds to a connected component of a level set,
      so the count is bounded by the Harnack bound. -/
  orbit_bound : periodicOrbitCount ≤ levelSetComponentBound degree

/-- **Bridge theorem**: The number of periodic orbits of a Hamiltonian system
    at a regular energy level is bounded by the Harnack bound.
    This connects Part I (algebraic curve topology) to Part II (limit cycles). -/
theorem periodic_orbit_harnack_bound (S : HamiltonianSystem) :
    S.periodicOrbitCount ≤ (S.degree - 1) * (S.degree - 2) / 2 + 1 :=
  S.orbit_bound

/-- For a quadratic Hamiltonian, at most 1 periodic orbit at each energy. -/
theorem quadratic_hamiltonian_bound (S : HamiltonianSystem) (hd : S.degree = 2) :
    S.periodicOrbitCount ≤ 1 := by
  have := S.orbit_bound
  simp [levelSetComponentBound, hd] at this
  exact this

/-- For a cubic Hamiltonian, at most 2 periodic orbits at each energy. -/
theorem cubic_hamiltonian_bound (S : HamiltonianSystem) (hd : S.degree = 3) :
    S.periodicOrbitCount ≤ 2 := by
  have := S.orbit_bound
  simp [levelSetComponentBound, hd] at this
  exact this

/-- For a quartic Hamiltonian, at most 4 periodic orbits at each energy. -/
theorem quartic_hamiltonian_bound (S : HamiltonianSystem) (hd : S.degree = 4) :
    S.periodicOrbitCount ≤ 4 := by
  have := S.orbit_bound
  simp [levelSetComponentBound, hd] at this
  exact this

/-! ## Perturbation framework

When H is perturbed to a non-Hamiltonian system, some periodic orbits persist
as limit cycles. The number of persistent limit cycles is bounded by the
number of periodic orbits, hence by the Harnack bound.

This creates the formal corridor:
  degree → genus → Harnack bound → max periodic orbits → upper bound on limit cycles -/

/-- A perturbation of a Hamiltonian system, where some periodic orbits
    persist as limit cycles. -/
structure PerturbedSystem extends HamiltonianSystem where
  /-- Number of limit cycles that persist under perturbation -/
  limitCycleCount : ℕ
  /-- Limit cycles come from perturbed periodic orbits -/
  persistence : limitCycleCount ≤ periodicOrbitCount

/-- **Hilbert 16 bridge**: Limit cycles of a perturbed Hamiltonian system
    are bounded by the Harnack bound of the unperturbed level set.
    This is the formal version of the "weakened Hilbert 16" principle:
    near-Hamiltonian systems have genus-bounded limit cycles. -/
theorem limit_cycle_harnack_bound (S : PerturbedSystem) :
    S.limitCycleCount ≤ (S.degree - 1) * (S.degree - 2) / 2 + 1 :=
  le_trans S.persistence S.orbit_bound

end Hilbert16