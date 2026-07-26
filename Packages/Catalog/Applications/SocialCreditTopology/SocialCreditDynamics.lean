import Mathlib

/-!
# Social credit scores as topological dynamics: theorems and counterexamples

A score-update rule is modeled honestly as a continuous self-map of a totally ordered
topological space.  The broad claim that continuity alone forces fixed-point attractors
is false.  We prove explicit counterexamples, then isolate a standard sufficient
hypothesis (an affine contraction) that really does force global convergence.

We also prove a topological obstruction to a nontrivial Cantor-like score range:
a continuous binary-valued score on a connected population is constant.  Thus a
Cantor attractor cannot follow merely from connectedness and continuity.
-/

namespace SocialCreditTopology

/-- A topological score-update system on a linearly ordered score space. -/
structure ScoreSystem (X : Type*) [TopologicalSpace X] [LinearOrder X] where
  update : X → X
  continuous_update : Continuous update

/-
**Counterexample to universal fixed points.** Translation by one is a continuous
score update on `ℝ`, but it has no fixed score.
-/
theorem continuous_update_without_fixed_point :
    ∃ S : ScoreSystem ℝ, ∀ x : ℝ, S.update x ≠ x := by
  use ⟨fun x => x + 1, continuous_id.add continuous_const⟩
  simp

/-
A second counterexample: on a finite discrete ordered score space, every update is
continuous, yet the Boolean swap has no fixed point.
-/
theorem finite_continuous_update_without_fixed_point :
    ∃ S : ScoreSystem (Fin 2), ∀ x, S.update x ≠ x := by
  refine ⟨⟨fun x => if x = 0 then 1 else 0, ?_⟩, ?_⟩
  · exact continuous_of_discreteTopology
  · intro x
    fin_cases x <;> norm_num

/-
Iterates of an affine update have a closed form.  This is the algebraic engine
behind the positive attractor theorem below.
-/
theorem affine_iterate_formula (a b x : ℝ) (n : ℕ) (ha : a ≠ 1) :
    (fun y : ℝ => a * y + b)^[n] x =
      a ^ n * x + b * (1 - a ^ n) / (1 - a) := by
  induction' n with n ih <;>
    simp_all +decide [Function.iterate_succ_apply', pow_succ, mul_assoc] <;>
    ring
  grind

/-
An affine contraction has exactly one fixed score.
-/
theorem affine_contraction_unique_fixed (a b x : ℝ) (ha : |a| < 1) :
    a * x + b = x ↔ x = b / (1 - a) := by
  constructor
  · intro h
    exact eq_div_of_mul_eq (by linarith [abs_lt.mp ha]) (by linarith)
  · intro h
    rw [eq_div_iff (by linarith [abs_lt.mp ha])] at h
    linarith

/-
**Positive attractor theorem.** Under the genuine dynamical assumption `|a| < 1`,
every initial score converges to the unique fixed score `b / (1-a)`.
-/
theorem affine_contraction_global_attractor (a b x : ℝ) (ha : |a| < 1) :
    Filter.Tendsto (fun n => (fun y : ℝ => a * y + b)^[n] x)
      Filter.atTop (nhds (b / (1 - a))) := by
  convert Filter.Tendsto.const_add (b / (1 - a))
      (Filter.Tendsto.const_mul ((a ^ 0) * (x - b / (1 - a)))
        (tendsto_pow_atTop_nhds_zero_of_abs_lt_one ha)) using 2 <;> ring
  convert affine_iterate_formula a b x _ _ using 1 <;> ring
  linarith [abs_lt.mp ha]

/-
A continuous score with only two separated values cannot vary on a connected
population.  This is a precise obstruction to obtaining a nontrivial totally
disconnected (Cantor-like) score range from continuity alone.
-/
theorem connected_binary_score_constant
    {X : Type*} [TopologicalSpace X] [ConnectedSpace X]
    (score : X → ℝ) (hscore : Continuous score)
    (hrange : ∀ x, score x = 0 ∨ score x = 1) :
    ∀ x y, score x = score y := by
  have h_ivt (a b : X) : score a = 0 → score b = 1 → False := by
    intro ha hb
    have hIcc := (isPreconnected_range hscore).Icc_subset
      (Set.mem_range_self a) (Set.mem_range_self b)
    simp_all +decide
    exact absurd (hIcc (show 1 / 2 ∈ Set.Icc 0 1 by norm_num)) (by
      rintro ⟨x, hx⟩
      cases hrange x <;> linarith)
  grind

/-- The usual sharp threshold, a simple model of a phase transition, is not continuous
at its transition point.  Hence phase transitions are not consequences of continuity;
they require a limiting process or weaker regularity. -/
noncomputable def hardThreshold (x : ℝ) : ℝ := if x < 0 then 0 else 1

theorem hardThreshold_not_continuous : ¬ Continuous hardThreshold := by
  rw [Metric.continuous_iff]
  norm_num [hardThreshold]
  exact ⟨0, 1, by norm_num, fun ε hε =>
    ⟨-ε / 2, abs_lt.mpr ⟨by linarith, by linarith⟩, by
      split_ifs <;> norm_num at * <;> linarith⟩⟩

/-- Exact small-case evidence for the contraction `x ↦ x/2`: the first four
nontrivial iterates from `8` are `4, 2, 1, 1/2`. -/
theorem half_score_first_iterates :
    (fun x : ℝ => x / 2)^[1] 8 = 4 ∧
    (fun x : ℝ => x / 2)^[2] 8 = 2 ∧
    (fun x : ℝ => x / 2)^[3] 8 = 1 ∧
    (fun x : ℝ => x / 2)^[4] 8 = 1 / 2 := by
  norm_num [Function.iterate_succ_apply']

end SocialCreditTopology