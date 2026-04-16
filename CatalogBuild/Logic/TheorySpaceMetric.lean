/-! # CatalogBuild.Logic.TheorySpaceMetric

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15
-/

import Mathlib

noncomputable section

/-- A theory space is a type equipped with a simulation cost function
satisfying pseudometric axioms. -/
class TheorySpace (T : Type*) where
  /-- Simulation cost: how expensive to simulate theory b using theory a -/
  simCost : T → T → ℝ
  /-- Self-simulation is free -/
  simCost_self : ∀ a, simCost a a = 0
  /-- Non-negativity -/
  simCost_nonneg : ∀ a b, 0 ≤ simCost a b
  /-- Triangle inequality: can compose simulators -/
  simCost_triangle : ∀ a b c, simCost a c ≤ simCost a b + simCost b c



/-- [Section: # CatalogBuild.Logic.TheorySpaceMetric
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15] -/
theorem simCost_is_pseudometric {T : Type*} [TheorySpace T] :
    ∀ a b c : T,
      TheorySpace.simCost a a = 0 ∧
      0 ≤ TheorySpace.simCost a b ∧
      TheorySpace.simCost a c ≤ TheorySpace.simCost a b + TheorySpace.simCost b c := by
  exact fun a b c => ⟨ ‹TheorySpace T›.simCost_self a, ‹TheorySpace T›.simCost_nonneg a b, ‹TheorySpace T›.simCost_triangle a b c ⟩



/-- Two theories are dual if they have zero mutual simulation cost. -/
def isDual {T : Type*} [TheorySpace T] (a b : T) : Prop :=
  TheorySpace.simCost a b = 0 ∧ TheorySpace.simCost b a = 0



theorem isDual_refl {T : Type*} [TheorySpace T] (a : T) : isDual a a := by
  constructor <;> exact ( ‹TheorySpace T›.simCost_self a )



theorem isDual_symm {T : Type*} [TheorySpace T] {a b : T} (h : isDual a b) : isDual b a := by
  exact ⟨ h.2, h.1 ⟩



theorem isDual_trans {T : Type*} [TheorySpace T] {a b c : T}
    (hab : isDual a b) (hbc : isDual b c) : isDual a c := by
  constructor;
  · -- By the triangle inequality, we have simCost a c ≤ simCost a b + simCost b c.
    have h_triangle : (‹TheorySpace T›.simCost a c) ≤ (‹TheorySpace T›.simCost a b) + (‹TheorySpace T›.simCost b c) := by
      exact?;
    linarith [ hab.1, hab.2, hbc.1, hbc.2, ‹TheorySpace T›.simCost_nonneg a c ];
  · linarith [ ( ‹TheorySpace T› ).simCost_nonneg c a, ( ‹TheorySpace T› ).simCost_triangle c b a, hbc.2, hab.2 ]



theorem isDual_equivalence {T : Type*} [TheorySpace T] :
    Equivalence (isDual (T := T)) := by
  constructor;
  · exact fun x => ⟨ ‹TheorySpace T›.simCost_self x, ‹TheorySpace T›.simCost_self x ⟩;
  · exact fun h => ⟨ h.2, h.1 ⟩;
  · intro x y z hxy hyz
    unfold isDual at hxy hyz ⊢
    exact (by
    refine' ⟨ _, _ ⟩;
    · exact le_antisymm ( le_trans ( ‹TheorySpace T›.simCost_triangle x y z ) ( by linarith ) ) ( ‹TheorySpace T›.simCost_nonneg x z );
    · exact le_antisymm ( le_trans ( ‹TheorySpace T›.simCost_triangle _ _ _ ) ( by linarith ) ) ( ‹TheorySpace T›.simCost_nonneg _ _ ))



/-- A theory m is a midpoint between a and b if it minimizes the max distance to either. -/
def isMidpoint {T : Type*} [TheorySpace T] (m a b : T) : Prop :=
  TheorySpace.simCost a m = TheorySpace.simCost m b ∧
  TheorySpace.simCost a m + TheorySpace.simCost m b = TheorySpace.simCost a b



theorem midpoint_optimal {T : Type*} [TheorySpace T] {m a b : T}
    (h : isMidpoint m a b) :
    TheorySpace.simCost a m + TheorySpace.simCost m b = TheorySpace.simCost a b := by
  -- By definition of isMidpoint, we have that TheorySpace.simCost a m + TheorySpace.simCost m b = TheorySpace.simCost a b.
  apply h.2



theorem midpoint_half_distance {T : Type*} [TheorySpace T] {m a b : T}
    (h : isMidpoint m a b) :
    TheorySpace.simCost a m = TheorySpace.simCost a b / 2 := by
  linarith [ h.1, h.2 ]



theorem simulation_cost_from_expressiveness
    {states_A states_B : ℕ} (hA : 0 < states_A) (hB : 0 < states_B)
    (h : states_A ≤ states_B) :
    Real.log states_A ≤ Real.log states_B := by
  gcongr



theorem expressiveness_gap_nonneg
    {states_A states_B : ℕ} (hA : 0 < states_A) (hB : 0 < states_B)
    (h : states_A ≤ states_B) :
    0 ≤ Real.log states_B - Real.log states_A := by
  exact sub_nonneg_of_le <| Real.log_le_log ( by positivity ) <| mod_cast h



/-- We define curvature-like defect: the amount by which the triangle
inequality is strict. Positive defect means "curved" theory space. -/
noncomputable def triangleDefect {T : Type*} [TheorySpace T] (a b c : T) : ℝ :=
  (TheorySpace.simCost a b + TheorySpace.simCost b c) - TheorySpace.simCost a c



theorem triangleDefect_nonneg {T : Type*} [TheorySpace T] (a b c : T) :
    0 ≤ triangleDefect a b c := by
  exact sub_nonneg_of_le ( by exact ( ‹TheorySpace T›.simCost_triangle a b c ) )



theorem zero_defect_geodesic {T : Type*} [TheorySpace T] {a b c : T}
    (h : triangleDefect a b c = 0) :
    TheorySpace.simCost a c = TheorySpace.simCost a b + TheorySpace.simCost b c := by
  exact eq_of_sub_eq_zero h ▸ rfl


end
