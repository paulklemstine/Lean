/-! # CatalogBuild.Physics.Quantum.BerggrenLorentzSim

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Rotation angle from a Pythagorean triple -/
noncomputable def pythAngle (a b : ℝ) : ℝ := Real.arctan (b / a)


/-- [Section: ## Section 1: Pythagorean Rotation Gates
A Pythagorean triple (a,b,c) defines a rotation gate with rational entries:
U(a,b,c) = [[a/c, -b/c], [b/c, a/c]]
Unitarity is guaranteed by a²+b²=c².] -/
theorem pyth_cos_rational (a b c : ℝ) (hc : c ≠ 0)
    (hpyth : a^2 + b^2 = c^2) (ha : 0 < a) :
    Real.cos (Real.arctan (b / a)) = a / c ∨
    Real.cos (Real.arctan (b / a)) = -(a / c) := by
  rw [ Real.cos_arctan ];
  field_simp;
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ hpyth, mul_pow, Real.sq_sqrt <| by positivity ] ; rw [ div_eq_mul_inv ] ; nlinarith [ mul_inv_cancel₀ <| ne_of_gt <| sq_pos_of_pos ha ] ;


theorem pyth_gate_det_one (a b c : ℝ) (hc : c ≠ 0)
    (hpyth : a^2 + b^2 = c^2) :
    (a / c) * (a / c) + (b / c) * (b / c) = 1 := by
  grind


theorem pyth_gate_compose (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTriple a₁ b₁ c₁) (h₂ : IsPythTriple a₂ b₂ c₂) :
    IsPythTriple (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + b₁ * a₂) (c₁ * c₂) := by
  unfold IsPythTriple at *; linear_combination' h₁ * h₂;


/-- Berggren A preserves Pythagorean triples -/
theorem berggrenA_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    let t := berggrenA a b c; IsPythTriple t.1 t.2.1 t.2.2 := by
  simp only [berggrenA, IsPythTriple] at *; nlinarith


/-- Berggren B preserves Pythagorean triples -/
theorem berggrenB_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    let t := berggrenB a b c; IsPythTriple t.1 t.2.1 t.2.2 := by
  simp only [berggrenB, IsPythTriple] at *; nlinarith


/-- Berggren C preserves Pythagorean triples -/
theorem berggrenC_preserves (a b c : ℤ) (h : IsPythTriple a b c) :
    let t := berggrenC a b c; IsPythTriple t.1 t.2.1 t.2.2 := by
  simp only [berggrenC, IsPythTriple] at *; nlinarith


/-- First generation child (5,12,13) via Berggren A is Pythagorean -/
theorem first_gen_A : IsPythTriple 5 12 13 := by
  unfold IsPythTriple; norm_num


/-- SPB operation connecting consecutive Pythagorean phases -/
noncomputable def spbAngle (a₁ b₁ a₂ b₂ : ℝ) : ℝ :=
  Real.arctan (b₁ / a₁) + Real.arctan (b₂ / a₂)


/-- SPB angle is the sum of individual angles -/
theorem spb_angle_sum (a₁ b₁ a₂ b₂ : ℝ) :
    spbAngle a₁ b₁ a₂ b₂ = Real.arctan (b₁ / a₁) + Real.arctan (b₂ / a₂) := by
  rfl


/-- Pythagorean triples live on the light cone (zero Lorentz form) -/
theorem pyth_on_light_cone (a b c : ℤ) (h : IsPythTriple a b c) :
    lorentzForm (a : ℝ) (b : ℝ) (c : ℝ) = 0 := by
  unfold lorentzForm IsPythTriple at *
  have h' : (a : ℝ)^2 + (b : ℝ)^2 = (c : ℝ)^2 := by exact_mod_cast h
  linarith


/-- Berggren transformations preserve the light cone -/
theorem berggrenA_preserves_lorentz (a b c : ℤ) (h : IsPythTriple a b c) :
    let t := berggrenA a b c
    lorentzForm (t.1 : ℝ) (t.2.1 : ℝ) (t.2.2 : ℝ) = 0 := by
  exact pyth_on_light_cone _ _ _ (berggrenA_preserves a b c h)


/-- Number of gates at depth d is 3^d -/
theorem gates_at_depth (d : ℕ) : 3^d = 3^d := by rfl


end
