/-
# Novikov Self-Consistency as a Fixed-Point Theorem

This module formalizes Novikov's self-consistency principle for time travel
using the Banach fixed-point theorem. The key insight is that a closed timelike
curve (CTC) imposes a boundary condition: the state of the universe at the
"departure" event must equal the state at the "arrival" event after evolution
through the CTC. A self-consistent history is precisely a fixed point of the
associated causal evolution map.

## Main Definitions

- `CausalLoop`: A causal evolution map on a metric space with a contraction bound
- `NovikovConsistent`: The property that a causal loop admits a self-consistent solution
- `PolynomialCausalMap`: A polynomial map modeling causal evolution, with conditions
  ensuring contraction on a bounded domain
- `TimeTravelBVP`: Boundary value problem formulation of time travel consistency
-/

import Mathlib

open Metric Set Function NNReal

noncomputable section

/-! ## Causal Loop Structure -/

/-- A `CausalLoop` models a closed timelike curve in spacetime.
The map `evolve` represents how the state of the universe transforms
as it traverses the CTC. A self-consistent history is a fixed point of `evolve`.

The key physical insight: if the evolution map is a contraction (dissipative dynamics),
then Banach's theorem guarantees exactly one self-consistent history exists. -/
structure CausalLoop (α : Type*) [MetricSpace α] where
  /-- The causal evolution map through the closed timelike curve -/
  evolve : α → α
  /-- Lipschitz constant of the evolution map -/
  lipK : ℝ≥0
  /-- The evolution is a contraction -/
  contracting : ContractingWith lipK evolve

/-- A causal loop is Novikov-consistent if its evolution map has a fixed point. -/
def NovikovConsistent {α : Type*} [MetricSpace α] (C : CausalLoop α) : Prop :=
  ∃ x : α, IsFixedPt C.evolve x

/-! ## Polynomial Causal Maps -/

/-- A polynomial causal map of degree 1 (affine): f(x) = a * x + b.
When |a| < 1, this is a contraction and models dissipative causal evolution. -/
structure AffineCausalMap where
  /-- Slope parameter -/
  a : ℝ
  /-- Intercept parameter -/
  b : ℝ
  /-- Contraction condition: |a| < 1 -/
  ha : |a| < 1

/-- Evaluate an affine causal map -/
def AffineCausalMap.eval (f : AffineCausalMap) (x : ℝ) : ℝ := f.a * x + f.b

/-- The unique fixed point of an affine causal map: x = b / (1 - a) -/
def AffineCausalMap.fixedPoint (f : AffineCausalMap) : ℝ :=
  f.b / (1 - f.a)

/-! ## Time Travel Boundary Value Problem -/

/-- A time-travel boundary value problem.
Given a causal evolution map F on a complete metric space,
finding a self-consistent history is equivalent to solving F(x) = x.

This structure bundles the evolution map with the completeness and
contraction hypotheses needed to apply the Banach fixed-point theorem. -/
structure TimeTravelBVP (α : Type*) [MetricSpace α] [CompleteSpace α] [Nonempty α] where
  /-- The causal evolution through the CTC -/
  evolve : α → α
  /-- Contraction constant -/
  K : ℝ≥0
  /-- The evolution is contracting -/
  hContract : ContractingWith K evolve

/-- The guaranteed self-consistent solution from Banach's theorem -/
def TimeTravelBVP.solution {α : Type*} [MetricSpace α] [CompleteSpace α] [Nonempty α]
    (bvp : TimeTravelBVP α) : α :=
  ContractingWith.fixedPoint bvp.evolve bvp.hContract

/-! ## Composition of Causal Loops -/

/-- Composition of two causal loops (sequential traversal of two CTCs).
If F₁ has Lipschitz constant K₁ and F₂ has Lipschitz constant K₂,
then F₂ ∘ F₁ has Lipschitz constant K₁ * K₂. The composition is
contracting when K₁ * K₂ < 1. -/
structure ComposedCausalLoop (α : Type*) [MetricSpace α] where
  loop₁ : CausalLoop α
  loop₂ : CausalLoop α
  hProd : loop₁.lipK * loop₂.lipK < 1

/-! ## Damped Polynomial Causal Map -/

/-- A damped polynomial causal map: f(x) = c * g(x) where g is Lipschitz
and |c| < 1/L where L is the Lipschitz constant of g. This models
causal evolution with a damping factor that ensures contraction. -/
structure DampedCausalMap (α : Type*) [MetricSpace α] where
  /-- The undamped dynamics -/
  g : α → α
  /-- Lipschitz constant of g -/
  Lg : ℝ≥0
  /-- g is Lipschitz -/
  hLip : LipschitzWith Lg g
  /-- Damping factor as NNReal -/
  dampK : ℝ≥0
  /-- Product of damping and Lipschitz constant is < 1 -/
  hDamp : dampK * Lg < 1

end