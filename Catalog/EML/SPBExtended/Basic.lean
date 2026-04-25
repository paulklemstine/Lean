import Mathlib

/-! # CatalogBuild.EML.Basic

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 15
-/

noncomputable section

/-- The inverse for hyperbolic SPB is also negation. -/
theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
  simp [spbH]

/-- Wick duality: SPB with negated second argument equals the "difference"
in the hyperbolic SPB. This is the real-variable manifestation of the
Wick rotation t → it. -/
theorem wick_duality (x y : ℝ) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  simp only [spb]
  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [heq]; ring

/-- The tangent addition law IS the stereographic sum.
tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
  field_simp

/-- SPB expression trees — analogous to EML expression trees. -/
inductive SPBExpr where
  | zero : SPBExpr
  | one : SPBExpr
  | var : ℕ → SPBExpr
  | node : SPBExpr → SPBExpr → SPBExpr
  deriving Repr, BEq

/-- Evaluate an SPB expression. -/
def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
  match e with
  | .zero => 0
  | .one => 1
  | .var n => vars n
  | .node l r => spb (l.eval vars) (r.eval vars)

/-- Depth of an SPB expression. -/
def SPBExpr.depth : SPBExpr → ℕ
  | .zero => 0
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + max l.depth r.depth

/-- Leaf count. -/
def SPBExpr.leafCount : SPBExpr → ℕ
  | .zero => 1
  | .one => 1
  | .var _ => 1
  | .node l r => l.leafCount + r.leafCount

/-- Internal node count. -/
def SPBExpr.nodeCount : SPBExpr → ℕ
  | .zero => 0
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount

/-- Binary tree identity: leaves = internal nodes + 1. -/
theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
    e.leafCount = e.nodeCount + 1 := by
  induction e with
  | zero => rfl
  | one => rfl
  | var _ => rfl
  | node l r ihl ihr =>
    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
    omega

/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}

/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
  unfold logisticSigmoid
  rw [Real.exp_neg]
  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
  field_simp; ring

/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
  unfold softplus logisticSigmoid
  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
  simp at this
  exact this

/-- ShefferAlg is closed under affine pre-composition. -/
theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
    (fun x => f (a * x + b)) ∈ ShefferAlg := by
  obtain ⟨e, rfl⟩ := hf
  exact ⟨.affinePrecomp a b e, rfl⟩

/-- ShefferAlg is closed under affine combination. -/
theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
  obtain ⟨ef, rfl⟩ := hf
  obtain ⟨eg, rfl⟩ := hg
  exact ⟨.affineComb α β γ ef eg, rfl⟩

/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
  unfold softplus
  rw [Real.exp_neg]
  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
  rw [this, Real.log_exp]

end
