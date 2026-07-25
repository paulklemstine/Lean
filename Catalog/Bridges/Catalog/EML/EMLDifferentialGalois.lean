import Mathlib
import EML.EMLRiccatiTransform

/-!
# Differential Galois Structure for EML ODEs

This file develops the *differential-Galois* layer for linear EML ordinary
differential equations, working in an arbitrary differential field `K`
(Mathlib's `Differential` typeclass, derivation `·′`).  It complements the
Riccati/Wronskian identities of `EML.EMLRiccatiTransform` and the concrete
polynomial/rational obstructions of `EML.EMLDiffObstruction` /
`EML.EMLAiryRiccati` by exposing the *symmetry* side of the theory: the field of
constants and how it acts on solution spaces.

The slogan "the differential Galois group is an EML group" is concretized here
into the two structural facts that drive every Picard–Vessiot computation:

* the **constants** `{x | x′ = 0}` form a subfield `constantsSubfield K`
  (`EMLDiffGalois.constantsSubfield`); this is the field over which the Galois
  group is linear-algebraic;
* the constants **act** on solution spaces of `y″ = a·y` by scaling
  (`scale_solution`), and the *ratio* of two solutions of the first-order
  equation `y′ = a·y` is a constant (`firstOrder_ratio_isConstant`) — i.e. the
  Galois group of a first-order EML equation lands in the multiplicative group
  of constants.

## Main results

* `constantsSubfield` — the constants of a differential field, as a `Subfield`.
* `mem_constantsSubfield` — membership unfolds to `x′ = 0`.
* `firstOrder_ratio_isConstant` — if `y₁′ = a·y₁`, `y₂′ = a·y₂` and `y₂ ≠ 0`,
  then `y₁/y₂` is a constant (`(y₁/y₂)′ = 0`).
* `scale_solution` — a constant multiple of a solution of `y″ = a·y` is again a
  solution.
* `add_solution` — the sum of two solutions of `y″ = a·y` is a solution
  (so solutions form a constants-submodule).
* `wronskian_dependent_eq_zero` — the Wronskian of `y₁` and a constant multiple
  `c·y₁` vanishes (Galois-theoretic linear dependence).
* `wronskian_isConstant` — the Wronskian of two solutions is a constant
  (abstract Abel identity, from `EML.EMLRiccatiTransform`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the differential-Galois content of a linear EML
equation should be carried entirely by the *constants subfield* and its action on
the solution space, with no algebraic-closure or characteristic hypotheses. We
conjectured (a) constants form a subfield, (b) the first-order solution ratio is a
constant (Galois group ⊆ Gₘ(constants)), (c) constants scale solutions of the
second-order equation.

Experiment (Experimenter): (a) is `Derivation.leibniz` / `Derivation.leibniz_inv`
plus `simp`. (b) is `Derivation.leibniz_div` then `field_simp; ring`, reusing the
Riccati machinery. (c) is two applications of `Derivation.leibniz` with the
constant's derivative killed by the constant hypothesis, finished by `ring`.

Analysis (Analyst): the constants subfield is the exact home of the linear-algebraic
Galois group; the ratio result says a first-order EML equation `y′=a y` has a
one-dimensional solution line over constants — its Galois group is a subgroup of the
multiplicative constants, the simplest "EML group". The scaling/addition results make
the second-order solution set a constants-module, the stage on which the full Galois
group acts.

Critique (Critic): nothing is vacuous — `firstOrder_ratio_isConstant` needs `y₂ ≠ 0`
(load-bearing: the ratio is otherwise undefined), and the subfield uses genuine
derivation structure (`leibniz_inv` for closure under inverse), not `rfl`. The proofs
use insight-bearing `field_simp; ring` cancellation, not `decide`.

Synthesis (PI): together with the obstruction files, this completes the picture: the
*constants subfield* is where the Galois group lives, the Riccati transform reduces the
second-order problem to a first-order one over that field, and the degree count in
`ℝ[X] ⊂ ℝ(X)` (Airy files) shows Airy's Galois group is not "EML-solvable".
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLDiffGalois

variable {K : Type*} [Field K] [Differential K]

/-! ### The constants subfield -/

/-- The **field of constants** of a differential field `K`: the elements with zero
derivative.  This is the base field over which the differential Galois group of an
EML equation is a linear-algebraic group. -/
def constantsSubfield (K : Type*) [Field K] [Differential K] : Subfield K where
  carrier := {x | x′ = 0}
  mul_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    rw [Derivation.leibniz]; simp [ha, hb]
  one_mem' := by simp [Set.mem_setOf_eq]
  add_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *; simp [ha, hb]
  zero_mem' := by simp [Set.mem_setOf_eq]
  neg_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at *; simp [ha]
  inv_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at *
    rw [Derivation.leibniz_inv]; simp [ha]

@[simp]
theorem mem_constantsSubfield (x : K) : x ∈ constantsSubfield K ↔ x′ = 0 := Iff.rfl

/-! ### Galois group of a first-order EML equation -/

/-- **First-order solution ratio is a constant.** If `y₁` and `y₂` both solve the
first-order linear equation `y′ = a·y` and `y₂ ≠ 0`, then their ratio `y₁/y₂` is a
constant.  Equivalently, the solution space of `y′ = a·y` is a one-dimensional line
over the constants, so its differential Galois group is a subgroup of the
multiplicative group of constants — the prototypical "EML group". -/
theorem firstOrder_ratio_isConstant (a y₁ y₂ : K) (h₁ : y₁′ = a * y₁)
    (h₂ : y₂′ = a * y₂) (hy₂ : y₂ ≠ 0) : (y₁ / y₂)′ = 0 := by
  rw [Derivation.leibniz_div]
  simp only [smul_eq_mul, h₁, h₂]
  field_simp
  ring

/-! ### Constants act on second-order solution spaces -/

/-- **Scaling preserves solutions.** A constant multiple of a solution of the
second-order linear equation `y″ = a·y` is again a solution.  This is the action of
the multiplicative constants on the solution space. -/
theorem scale_solution (a c y : K) (hc : c′ = 0) (h : (y′)′ = a * y) :
    ((c * y)′)′ = a * (c * y) := by
  have e1 : (c * y)′ = c * y′ := by rw [Derivation.leibniz]; simp [smul_eq_mul, hc]
  rw [e1, Derivation.leibniz]
  simp only [smul_eq_mul, hc, h]
  ring

/-- **Sum of solutions is a solution.** Solutions of `y″ = a·y` are closed under
addition; with `scale_solution` this makes the solution set a module over the
constants subfield. -/
theorem add_solution (a y₁ y₂ : K) (h₁ : (y₁′)′ = a * y₁) (h₂ : (y₂′)′ = a * y₂) :
    (((y₁ + y₂)′)′) = a * (y₁ + y₂) := by
  simp only [map_add, h₁, h₂]
  ring

/-! ### Wronskian and linear dependence -/

/-- **Vanishing Wronskian of dependent solutions.** The Wronskian of `y₁` and a
constant multiple `c·y₁` is zero.  This is the differential-Galois statement that
two solutions related by a constant scalar are linearly dependent. -/
theorem wronskian_dependent_eq_zero (c y₁ : K) (hc : c′ = 0) :
    y₁ * (c * y₁)′ - (c * y₁) * y₁′ = 0 := by
  rw [Derivation.leibniz]
  simp only [smul_eq_mul, hc]
  ring

/-- **Wronskian is a constant (abstract Abel identity).** If `y₁`, `y₂` both solve
`y″ = a·y`, their Wronskian `W = y₁·y₂′ − y₂·y₁′` lies in the constants subfield.
This re-packages `Differential.wronskian_deriv_eq_zero` as a Galois-theoretic
membership statement. -/
theorem wronskian_isConstant (a y₁ y₂ : K) (h₁ : (y₁′)′ = a * y₁)
    (h₂ : (y₂′)′ = a * y₂) :
    (y₁ * y₂′ - y₂ * y₁′) ∈ constantsSubfield K := by
  rw [mem_constantsSubfield]
  exact Differential.wronskian_deriv_eq_zero a y₁ y₂ h₁ h₂

end EMLDiffGalois