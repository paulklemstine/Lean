import EML.Lean.AdvancedTheorems
import EML.Lean.ExtendedTheorems
import EML.Lean.NewTheorems
import EML.Lean.OpenQuestions
import EML.Lean.ShefferAlgebra
import EML.Lean.SoftplusBasic
import Mathlib

/-! # CatalogBuild.EML.StructuralProperties

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17
-/

noncomputable section

/-- The Sheffer algebra contains the zero function -/
theorem sheffer_zero' : (fun _ : ℝ => (0 : ℝ)) ∈ ShefferAlgebra :=
  const_mem_sheffer 0

/-- The Sheffer algebra is closed under addition (restated for emphasis) -/
theorem sheffer_add' {f g : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (hg : g ∈ ShefferAlgebra) :
    (fun x => f x + g x) ∈ ShefferAlgebra :=
  sheffer_add_closed hf hg

/-- The Sheffer algebra is closed under scalar multiplication (restated) -/
theorem sheffer_smul' {f : ℝ → ℝ} (c : ℝ) (hf : f ∈ ShefferAlgebra) :
    (fun x => c * f x) ∈ ShefferAlgebra :=
  sheffer_smul_closed hf c

/-- Left identity for composition: id ∘ f = f -/
theorem sheffer_comp_id_left (f : ℝ → ℝ) :
    (fun x => (fun y : ℝ => y) (f x)) = f := by
  ext x; simp

/-- Right identity for composition: f ∘ id = f -/
theorem sheffer_comp_id_right (f : ℝ → ℝ) :
    (fun x => f ((fun y : ℝ => y) x)) = f := by
  ext x; simp

/-- Composition is associative: (f ∘ g) ∘ h = f ∘ (g ∘ h) -/
theorem sheffer_comp_assoc (f g h : ℝ → ℝ) :
    (fun x => f (g (h x))) = (fun x => (fun y => f (g y)) (h x)) := by
  ext x; simp

/-- Softplus maps ℝ onto Set.Ioi 0 -/
theorem softplus_range : Set.range softplus = Set.Ioi 0 := by
  ext y
  simp [Set.mem_Ioi]
  constructor
  · rintro ⟨x, rfl⟩
    exact softplus_pos x
  · intro hy
    exact softplus_surjective_pos y hy

/-- Iterated softplus is strictly greater than the starting point for n ≥ 1. -/
theorem softplus_iter_gt (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus_iter n x > x := by
  induction n with
  | zero => omega
  | succ k ih =>
    simp only [softplus_iter, Function.comp]
    by_cases hk : k = 0
    · subst hk; simp [softplus_iter]; exact softplus_gt_id x
    · have hk1 : k ≥ 1 := Nat.one_le_iff_ne_zero.mpr hk
      calc x < softplus_iter k x := ih hk1
        _ < softplus (softplus_iter k x) := softplus_gt_id _

/-- The softplus dynamical system is fixed-point-free: σⁿ(x) ≠ x for all n ≥ 1. -/
theorem softplus_iter_no_periodic (n : ℕ) (hn : n ≥ 1) (x : ℝ) :
    softplus_iter n x ≠ x :=
  ne_of_gt (softplus_iter_gt n hn x)

/-- Every orbit of the softplus dynamical system is strictly increasing. -/
theorem softplus_orbit_increasing (x : ℝ) (n : ℕ) :
    softplus_iter n x < softplus_iter (n + 1) x := by
  simp only [softplus_iter, Function.comp]
  exact softplus_gt_id (softplus_iter n x)

/-- σ(x) + c is in the Sheffer algebra for any c -/
theorem softplus_add_const_mem (c : ℝ) :
    (fun x => softplus x + c) ∈ ShefferAlgebra := by
  exact sheffer_add_const_closed softplus_mem_sheffer c

/-- cσ(x) is in the Sheffer algebra for any c -/
theorem softplus_smul_mem (c : ℝ) :
    (fun x => c * softplus x) ∈ ShefferAlgebra := by
  exact sheffer_smul_closed softplus_mem_sheffer c

/-- σ(σ(x)) is in the Sheffer algebra -/
theorem softplus_comp_mem : (fun x => softplus (softplus x)) ∈ ShefferAlgebra := by
  exact sheffer_comp_closed softplus_mem_sheffer softplus_mem_sheffer

/-- The function x ↦ σ(x) - σ(-x) = x is the identity
(via the reflection property). -/
theorem softplus_diff_neg_is_id :
    (fun x : ℝ => softplus x - softplus (-x)) = (fun x => x) := by
  ext x
  have := softplus_reflection x
  linarith

/-- The logistic sigmoid satisfies S(x) = 1 - S(-x). -/
theorem sigmoid_reflection' (x : ℝ) :
    logisticSigmoid x = 1 - logisticSigmoid (-x) := by
  linarith [logisticSigmoid_symmetry x]

/-- The identity function can be expressed with depth 1 and width 2.
x = σ(x) - σ(-x) uses two base softplus operations. -/
theorem id_sheffer_width_le_two :
    ∃ e : ShefferExpr, (∀ x, e.eval x = x) ∧ e.width ≤ 2 := by
  refine ⟨ShefferExpr.affine_comb 1 (-1) 0
    ShefferExpr.base
    (ShefferExpr.affine_pre (-1) 0 ShefferExpr.base), ?_, ?_⟩
  · intro x
    simp [ShefferExpr.eval]
    have := softplus_reflection x
    linarith
  · simp [ShefferExpr.width]

/-- Constants can be expressed with depth 1 and width 2. -/
theorem const_sheffer_width_le_two (c : ℝ) :
    ∃ e : ShefferExpr, (∀ x, e.eval x = c) ∧ e.width ≤ 2 := by
  refine ⟨ShefferExpr.affine_comb 1 (-1) c ShefferExpr.base ShefferExpr.base, ?_, ?_⟩
  · intro x
    simp [ShefferExpr.eval]
  · simp [ShefferExpr.width]

end
