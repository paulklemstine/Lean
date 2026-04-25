/-! # CatalogBuild.Algebra.TopologyDynamics

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 20
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.TopologyDynamics
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 20] -/
theorem metric_hausdorff (X : Type*) [MetricSpace X] : T2Space X := by
  infer_instance





/-- [Section: # CatalogBuild.Algebra.TopologyDynamics
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 20] -/
theorem ball_open {X : Type*} [MetricSpace X] (x : X) (r : ℝ) :
    IsOpen (Metric.ball x r) := by
  exact Metric.isOpen_ball





/-- [Section: # CatalogBuild.Algebra.TopologyDynamics
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 20] -/
theorem empty_open {X : Type*} [TopologicalSpace X] :
    IsOpen (∅ : Set X) := by
  exact isOpen_empty





theorem univ_open {X : Type*} [TopologicalSpace X] :
    IsOpen (Set.univ : Set X) := by
  exact isOpen_univ





theorem inter_open {X : Type*} [TopologicalSpace X]
    (U V : Set X) (hU : IsOpen U) (hV : IsOpen V) :
    IsOpen (U ∩ V) := by
  exact hU.inter hV





theorem union_of_open {X : Type*} [TopologicalSpace X]
    (U V : Set X) (hU : IsOpen U) (hV : IsOpen V) :
    IsOpen (U ∪ V) := by
  exact IsOpen.union hU hV





theorem closed_compact {X : Type*} [TopologicalSpace X] [CompactSpace X]
    (S : Set X) (hS : IsClosed S) : IsCompact S := by
  exact hS.isCompact





theorem real_noncompact : ¬ CompactSpace ℝ := by
  exact fun h => by have := h.isCompact_univ; exact absurd this ( by exact fun h' => by exact absurd ( h'.ne_univ ) ( by norm_num ) ) ;





theorem icc_compact : IsCompact (Set.Icc (0 : ℝ) 1) := by
  exact CompactIccSpace.isCompact_Icc





theorem real_conn : ConnectedSpace ℝ := by
  infer_instance





theorem int_totally_disc :
    TotallyDisconnectedSpace ℤ := by
  exact?





theorem contraction_unique
    (f : ℝ → ℝ) (c : ℝ) (hc : c < 1) (hc0 : 0 ≤ c)
    (hf : ∀ x y : ℝ, |f x - f y| ≤ c * |x - y|)
    (x y : ℝ) (hx : f x = x) (hy : f y = y) :
    x = y := by
  contrapose! hf with h;
  exact ⟨ x, y, by cases abs_cases ( x - y ) <;> cases abs_cases ( f x - f y ) <;> cases lt_or_gt_of_ne h <;> nlinarith ⟩





/-- Fixed point is preserved under iteration -/
theorem fixed_iterate {α : Type*} (f : α → α) (x : α) (hx : f x = x) (n : ℕ) :
    f^[n] x = x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp_apply, ih, hx]





/-- Period 2 orbit -/
theorem period2_iterate {α : Type*} (f : α → α) (x : α) (hx : f (f x) = x) (k : ℕ) :
    f^[2 * k] x = x := by
  induction k with
  | zero => rfl
  | succ k ih =>
    have h2 : 2 * (k + 1) = 2 * k + 1 + 1 := by ring
    rw [h2, Function.iterate_succ', Function.comp_apply,
        Function.iterate_succ', Function.comp_apply, ih, hx]





theorem euler_tetra : 4 - 6 + 4 = (2 : ℤ) := by norm_num




theorem euler_cub : 8 - 12 + 6 = (2 : ℤ) := by norm_num




theorem euler_oct : 6 - 12 + 8 = (2 : ℤ) := by norm_num




theorem euler_dodec : 20 - 30 + 12 = (2 : ℤ) := by norm_num




theorem euler_icos : 12 - 30 + 20 = (2 : ℤ) := by norm_num





theorem platonic_five :
    ∀ p q : ℕ, 3 ≤ p → 3 ≤ q → (2 * (p + q) > p * q) →
    (p = 3 ∧ q = 3) ∨ (p = 3 ∧ q = 4) ∨ (p = 4 ∧ q = 3) ∨
    (p = 3 ∧ q = 5) ∨ (p = 5 ∧ q = 3) := by
  intro p q hp hq h; rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> rcases q with ( _ | _ | _ | _ | _ | _ | q ) <;> norm_num at * <;> nlinarith;




