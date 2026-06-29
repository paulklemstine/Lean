/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# Inhomogeneous minicenter Delaunay refinement with additive contraction defect

This file develops the theory of an *inhomogeneous* contraction recurrence

  `d (k+1) ≤ a · d k + b`,   with `0 ≤ a < 1` and `b ≥ 0`,

the natural generalization of the homogeneous Delaunay contraction theory in
`Contraction.lean` (`d (k+1) ≤ (1/λ) · d k`). Geometrically, `d k` models the
maximum simplex diameter after `k` rounds of minicenter refinement, the factor
`a` is the per-step contraction of the geometry, and the *additive defect* `b`
models a persistent bounded perturbation introduced at every step by the
insertion of fresh Steiner points (each insertion can enlarge a local
neighbourhood by at most `b`).

## Main results

* `d_le_closedForm` : the exact closed-form upper bound
  `d k ≤ a^k · d 0 + b · (1 - a^k) / (1 - a)`, proved by induction.
* `excess_le_pow` : the transient `d k - L` decays geometrically,
  `d k - L ≤ a^k · (d 0 - L)`, where `L = b/(1-a)` is the steady state.
* `closedFormBound_tendsto` / `eventually_lt_fixedPoint_add` : the closed-form
  bound converges to `L = b/(1-a)`, so the iterates are eventually trapped in the
  band `[0, L + ε]`.
* `tendsto_of_exact`, `dist_le_pow_of_exact` : **genuine** convergence to
  `b/(1-a)` and a two-sided geometric decay rate hold under the *exact*
  recurrence `d (k+1) = a · d k + b`. (With only the inequality this can fail,
  e.g. `d ≡ 0` when `b > 0`, so the equality hypothesis is essential.)
* `d_le_uniform`, `perturbation_le` : the "bounded neighbourhood perturbation"
  picture — every iterate stays in `[0, d 0 + L]` and each step perturbs by `≤ b`.
* `affine_isFixedPt`, `fixedPoint_unique`, `affine_dist` : the fixed-point
  theory connection. The update map `x ↦ a·x + b` is a contraction with unique
  fixed point `b/(1-a)`.
* `affineIteration` : a concrete process realizing the exact recurrence, showing
  the bounds are tight.
-/

namespace DelaunayContraction.Inhomogeneous

open Filter Topology

/-- An *inhomogeneous contraction process*: a nonnegative real sequence (think:
maximum simplex diameter after `k` minicenter refinements) that contracts by a
uniform factor `0 ≤ a < 1` each step, up to a persistent additive defect `b ≥ 0`
(the bounded perturbation introduced by Steiner-point insertion). -/
structure InhomogeneousContractionProcess where
  /-- The quantity being contracted (e.g. maximum simplex diameter at step `k`). -/
  d : ℕ → ℝ
  /-- The (multiplicative) contraction factor. -/
  a : ℝ
  /-- The additive contraction defect (steady-state perturbation strength). -/
  b : ℝ
  a_nonneg : 0 ≤ a
  a_lt_one : a < 1
  b_nonneg : 0 ≤ b
  d_nonneg : ∀ k, 0 ≤ d k
  contracts : ∀ k, d (k + 1) ≤ a * d k + b

namespace InhomogeneousContractionProcess

variable (P : InhomogeneousContractionProcess)

/-
The denominator `1 - a` is positive.
-/
theorem one_sub_a_pos : 0 < 1 - P.a := by
  linarith [ P.a_lt_one ]

/-- The steady state / fixed point `L = b / (1 - a)`. -/
noncomputable def fixedPoint : ℝ := P.b / (1 - P.a)

/-
The steady state is nonnegative.
-/
theorem fixedPoint_nonneg : 0 ≤ P.fixedPoint := by
  exact div_nonneg P.b_nonneg ( sub_nonneg.2 P.a_lt_one.le )

/-
The defining identity of the fixed point: `a · L + b = L`.
-/
theorem fixedPoint_eq : P.a * P.fixedPoint + P.b = P.fixedPoint := by
  rw [ show P.fixedPoint = P.b / ( 1 - P.a ) from rfl, mul_div, div_add', div_eq_div_iff ] <;> nlinarith [ P.one_sub_a_pos ]

/-! ### Component 1: the exact closed-form bound (by induction) -/

/-
**Closed-form bound.** After `k` refinements,
`d k ≤ a^k · d 0 + b · (1 - a^k) / (1 - a)`.
Proved by induction: the base case `k = 0` is an equality, and the inductive step
combines `contracts` with the inductive hypothesis via the algebraic identity
`a · b(1-a^n)/(1-a) + b = b(1-a^{n+1})/(1-a)`.
-/
theorem d_le_closedForm (k : ℕ) :
    P.d k ≤ P.a ^ k * P.d 0 + P.b * (1 - P.a ^ k) / (1 - P.a) := by
      induction' k with k ih <;> simp_all +decide [ pow_succ _, mul_assoc ];
      convert le_trans ( P.contracts k ) ( add_le_add ( mul_le_mul_of_nonneg_left ih P.a_nonneg ) le_rfl ) using 1 ; ring_nf at *;
      linarith [ inv_mul_cancel_left₀ ( show ( 1 - P.a ) ≠ 0 by linarith [ P.a_lt_one ] ) P.b ]

/-
The closed-form bound rewritten around the fixed point `L`:
`a^k · d 0 + b(1-a^k)/(1-a) = a^k · (d 0 - L) + L`.
-/
theorem closedForm_eq (k : ℕ) :
    P.a ^ k * P.d 0 + P.b * (1 - P.a ^ k) / (1 - P.a)
      = P.a ^ k * (P.d 0 - P.fixedPoint) + P.fixedPoint := by
        rw [ show P.fixedPoint = P.b / ( 1 - P.a ) by rfl ] ; ring

/-
**Geometric decay of the transient.** The excess over the steady state decays
at least geometrically: `d k - L ≤ a^k · (d 0 - L)`.
-/
theorem excess_le_pow (k : ℕ) :
    P.d k - P.fixedPoint ≤ P.a ^ k * (P.d 0 - P.fixedPoint) := by
      linarith [ P.d_le_closedForm k, P.closedForm_eq k ]

/-! ### Component 2: convergence to the steady state `b/(1-a)` -/

/-
The closed-form bound converges to the fixed point `L = b/(1-a)`.
-/
theorem closedFormBound_tendsto :
    Tendsto (fun k => P.a ^ k * P.d 0 + P.b * (1 - P.a ^ k) / (1 - P.a))
      atTop (nhds P.fixedPoint) := by
        convert Filter.Tendsto.add ( Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one P.a_nonneg P.a_lt_one ) tendsto_const_nhds ) ( Filter.Tendsto.div_const ( tendsto_const_nhds.mul ( tendsto_const_nhds.sub ( tendsto_pow_atTop_nhds_zero_of_lt_one P.a_nonneg P.a_lt_one ) ) ) _ ) using 2 ;
        unfold InhomogeneousContractionProcess.fixedPoint; ring;

/-
**One-sided convergence (general inequality case).** For any tolerance
`ε > 0`, eventually every iterate lies below `L + ε`. (Only the upper side holds
in general: the inequality `d (k+1) ≤ a d k + b` does not force convergence — e.g.
`d ≡ 0` satisfies it when `b > 0` — so we cannot claim genuine convergence here.)
-/
theorem eventually_lt_fixedPoint_add (ε : ℝ) (hε : 0 < ε) :
    ∀ᶠ k in atTop, P.d k < P.fixedPoint + ε := by
      exact Filter.Eventually.mono ( P.closedFormBound_tendsto.eventually ( gt_mem_nhds <| show P.fixedPoint < P.fixedPoint + ε by linarith ) ) fun k hk => lt_of_le_of_lt ( P.d_le_closedForm k ) hk

/-
**Iteration-count bound.** For any tolerance there is a finite number of steps
after which the iterate stays below `L + ε`.
-/
theorem exists_steps_below (ε : ℝ) (hε : 0 < ε) :
    ∃ N, ∀ k ≥ N, P.d k < P.fixedPoint + ε := by
      obtain ⟨ N, hN ⟩ := Filter.eventually_atTop.mp ( P.eventually_lt_fixedPoint_add ε hε ) ; exact ⟨ N, hN ⟩ ;

/-! ### Component 3: exponential decay under the exact recurrence

With only the inequality, genuine (two-sided) convergence can fail. Under the
*exact* recurrence `d (k+1) = a · d k + b` everything is sharp. -/

/-
Under the exact recurrence, the excess is *exactly* `a^k · (d 0 - L)`.
-/
theorem excess_eq_pow_of_exact (hexact : ∀ k, P.d (k + 1) = P.a * P.d k + P.b)
    (k : ℕ) : P.d k - P.fixedPoint = P.a ^ k * (P.d 0 - P.fixedPoint) := by
      induction' k with k ih <;> simp_all +decide [ pow_succ _, mul_assoc ];
      grind +suggestions

/-
**Genuine convergence.** Under the exact recurrence the sequence converges to
the steady state `b/(1-a)`.
-/
theorem tendsto_of_exact (hexact : ∀ k, P.d (k + 1) = P.a * P.d k + P.b) :
    Tendsto P.d atTop (nhds P.fixedPoint) := by
      have heq : ∀ k, P.d k = P.a ^ k * (P.d 0 - P.fixedPoint) + P.fixedPoint := by
        intro k; linarith [ P.excess_eq_pow_of_exact hexact k ] ;
      exact tendsto_iff_norm_sub_tendsto_zero.mpr ( by rw [ show P.d = _ from funext heq ] ; simpa using Filter.Tendsto.norm ( Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( P.a_nonneg ) ( P.a_lt_one ) ) tendsto_const_nhds ) )

/-
**Exponential decay rate.** Under the exact recurrence the distance to the
steady state decays exactly geometrically: `|d k - L| = a^k · |d 0 - L|`. In
particular convergence is exponential whenever `a > 0` and `d 0 ≠ L`.
-/
theorem dist_le_pow_of_exact (hexact : ∀ k, P.d (k + 1) = P.a * P.d k + P.b)
    (k : ℕ) : |P.d k - P.fixedPoint| = P.a ^ k * |P.d 0 - P.fixedPoint| := by
      rw [ ← abs_of_nonneg ( pow_nonneg P.a_nonneg _ ), ← abs_mul, ← excess_eq_pow_of_exact P hexact ]

/-! ### Component 4: bounded neighbourhood perturbation (geometric intuition) -/

/-
Each refinement step perturbs the quantity by at most the defect `b` beyond
pure contraction: `d (k+1) - a · d k ≤ b`. This is the formal content of
"persistent Steiner insertion introduces a bounded neighbourhood perturbation".
-/
theorem perturbation_le (k : ℕ) : P.d (k + 1) - P.a * P.d k ≤ P.b := by
  linarith [ P.contracts k ]

/-
**Uniform band.** Every iterate stays within the bounded neighbourhood
`[0, d 0 + L]`: contraction plus a bounded persistent perturbation keeps the
whole trajectory bounded.
-/
theorem d_le_uniform (k : ℕ) : P.d k ≤ P.d 0 + P.fixedPoint := by
  convert P.d_le_closedForm k |> le_trans <| ?_ using 1;
  convert add_le_add ?_ ?_ using 1;
  · infer_instance;
  · infer_instance;
  · exact mul_le_of_le_one_left ( P.d_nonneg 0 ) ( pow_le_one₀ P.a_nonneg P.a_lt_one.le );
  · convert div_le_div_of_nonneg_right ( mul_le_of_le_one_right P.b_nonneg ( sub_le_self _ ( pow_nonneg P.a_nonneg _ ) ) ) ( sub_nonneg.2 P.a_lt_one.le ) using 1

/-! ### Component 5: connection to fixed-point theorems -/

/-- The update map `x ↦ a · x + b` fixes the steady state `L = b/(1-a)`. -/
theorem affine_isFixedPt : P.a * P.fixedPoint + P.b = P.fixedPoint :=
  P.fixedPoint_eq

/-
**Uniqueness of the fixed point.** Any fixed point of `x ↦ a · x + b` equals
`b/(1-a)`.
-/
theorem fixedPoint_unique (x : ℝ) (hx : P.a * x + P.b = x) : x = P.fixedPoint := by
  exact eq_div_of_mul_eq ( by linarith [ P.one_sub_a_pos ] ) ( by linarith )

/-
The update map `x ↦ a · x + b` is a contraction with ratio `a`:
`dist (a x + b) (a y + b) = a · dist x y`. This is the metric-space fixed-point
mechanism underlying the convergence (Banach fixed-point theorem on `ℝ`).
-/
theorem affine_dist (x y : ℝ) :
    dist (P.a * x + P.b) (P.a * y + P.b) = P.a * dist x y := by
      norm_num [ Real.dist_eq ];
      rw [ ← mul_sub, abs_mul, abs_of_nonneg P.a_nonneg ]

end InhomogeneousContractionProcess

/-! ### A concrete realization: the affine iteration

The exact recurrence is realized by `d k = a^k · (D - L) + L` for any starting
value `D ≥ L`, exhibiting tightness of all the bounds above. -/

/-- The exact affine iteration started at `D ≥ b/(1-a)`. Its trajectory is
`d k = a^k · (D - b/(1-a)) + b/(1-a)`, converging to `b/(1-a)`. -/
noncomputable def affineIteration (a b D : ℝ) (ha0 : 0 ≤ a) (ha1 : a < 1)
    (hb : 0 ≤ b) (hD : b / (1 - a) ≤ D) : InhomogeneousContractionProcess where
  d k := a ^ k * (D - b / (1 - a)) + b / (1 - a)
  a := a
  b := b
  a_nonneg := ha0
  a_lt_one := ha1
  b_nonneg := hb
  d_nonneg := fun k => by
    have hpos : (0 : ℝ) < 1 - a := by linarith
    have h1 : (0 : ℝ) ≤ a ^ k := pow_nonneg ha0 k
    have h2 : (0 : ℝ) ≤ D - b / (1 - a) := by linarith
    have h3 : (0 : ℝ) ≤ b / (1 - a) := div_nonneg hb hpos.le
    nlinarith [mul_nonneg h1 h2]
  contracts := fun k => by
    have hpos : (0 : ℝ) < 1 - a := by linarith
    have hne : (1 - a) ≠ 0 := ne_of_gt hpos
    have key : a * (b / (1 - a)) + b = b / (1 - a) := by field_simp; ring
    have hid : a * (a ^ k * (D - b / (1 - a)) + b / (1 - a)) + b
        - (a ^ (k + 1) * (D - b / (1 - a)) + b / (1 - a))
        = a * (b / (1 - a)) + b - b / (1 - a) := by rw [pow_succ]; ring
    linarith [key, hid]

/-- The affine iteration does satisfy the exact recurrence. -/
theorem affineIteration_exact (a b D : ℝ) (ha0 : 0 ≤ a) (ha1 : a < 1)
    (hb : 0 ≤ b) (hD : b / (1 - a) ≤ D) (k : ℕ) :
    (affineIteration a b D ha0 ha1 hb hD).d (k + 1)
      = a * (affineIteration a b D ha0 ha1 hb hD).d k + b := by
  have hpos : (0 : ℝ) < 1 - a := by linarith
  have hne : (1 - a) ≠ 0 := ne_of_gt hpos
  have key : a * (b / (1 - a)) + b = b / (1 - a) := by field_simp; ring
  show a ^ (k + 1) * (D - b / (1 - a)) + b / (1 - a)
      = a * (a ^ k * (D - b / (1 - a)) + b / (1 - a)) + b
  rw [pow_succ]; linear_combination -key

end DelaunayContraction.Inhomogeneous