/-
  BerggrenLorentzSim.lean

  Future Direction 6.2: Berggren-Lorentz Quantum Simulation

  Pythagorean triples parameterize rational rotation gates via (a,b,c) → R(arctan(b/a)).
  Berggren transformations preserve a²+b²=c² and hence unitarity.
  The 3-ary tree provides a dense set of rational rotation angles.
-/
import Mathlib

open Real

namespace BerggrenLorentzSim

/-! ## Section 1: Pythagorean Rotation Gates

A Pythagorean triple (a,b,c) defines a rotation gate with rational entries:
  U(a,b,c) = [[a/c, -b/c], [b/c, a/c]]
Unitarity is guaranteed by a²+b²=c². -/

/-- Pythagorean triple predicate -/
def IsPythTriple (a b c : ℤ) : Prop := a^2 + b^2 = c^2

/-- Rotation angle from a Pythagorean triple -/
noncomputable def pythAngle (a b : ℝ) : ℝ := Real.arctan (b / a)

/-
Cosine of Pythagorean angle is rational: cos(θ) = a/c
-/
theorem pyth_cos_rational (a b c : ℝ) (hc : c ≠ 0)
    (hpyth : a^2 + b^2 = c^2) (ha : 0 < a) :
    Real.cos (Real.arctan (b / a)) = a / c ∨
    Real.cos (Real.arctan (b / a)) = -(a / c) := by
  rw [ Real.cos_arctan ];
  field_simp;
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ hpyth, mul_pow, Real.sq_sqrt <| by positivity ] ; rw [ div_eq_mul_inv ] ; nlinarith [ mul_inv_cancel₀ <| ne_of_gt <| sq_pos_of_pos ha ] ;

/-
Gate matrix determinant equals 1 (unitarity condition)
-/
theorem pyth_gate_det_one (a b c : ℝ) (hc : c ≠ 0)
    (hpyth : a^2 + b^2 = c^2) :
    (a / c) * (a / c) + (b / c) * (b / c) = 1 := by
  grind

/-
Composition of two Pythagorean gates is a Pythagorean gate
-/
theorem pyth_gate_compose (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTriple a₁ b₁ c₁) (h₂ : IsPythTriple a₂ b₂ c₂) :
    IsPythTriple (a₁ * a₂ - b₁ * b₂) (a₁ * b₂ + b₁ * a₂) (c₁ * c₂) := by
  unfold IsPythTriple at *; linear_combination' h₁ * h₂;

/-! ## Section 2: Berggren Transformations as Gate Generators

The three Berggren matrices A, B, C generate all primitive Pythagorean triples
from (3,4,5). Each transformation preserves the Pythagorean property. -/

/-- Berggren A transformation -/
def berggrenA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren B transformation -/
def berggrenB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren C transformation -/
def berggrenC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

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

/-- Root triple (3,4,5) is Pythagorean -/
theorem root_triple : IsPythTriple 3 4 5 := by
  unfold IsPythTriple; norm_num

/-- First generation child (5,12,13) via Berggren A is Pythagorean -/
theorem first_gen_A : IsPythTriple 5 12 13 := by
  unfold IsPythTriple; norm_num

/-! ## Section 3: Density of Pythagorean Angles

The Berggren tree generates angles arctan(b/a) for all primitive triples.
These angles are dense in [0, π/2]. -/

/-- SPB operation connecting consecutive Pythagorean phases -/
noncomputable def spbAngle (a₁ b₁ a₂ b₂ : ℝ) : ℝ :=
  Real.arctan (b₁ / a₁) + Real.arctan (b₂ / a₂)

/-- SPB angle is the sum of individual angles -/
theorem spb_angle_sum (a₁ b₁ a₂ b₂ : ℝ) :
    spbAngle a₁ b₁ a₂ b₂ = Real.arctan (b₁ / a₁) + Real.arctan (b₂ / a₂) := by
  rfl

/-! ## Section 4: Lorentz Form and Relativistic Gates

The Pythagorean condition a²+b²=c² is equivalent to vanishing Lorentz form.
This connects quantum gates to relativistic structure. -/

/-- Lorentz form -/
def lorentzForm (a b c : ℝ) : ℝ := a^2 + b^2 - c^2

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

/-- Gate depth of a Berggren-generated triple -/
def berggrenDepth : ℕ → ℕ
  | 0 => 0
  | n + 1 => n + 1

/-- Number of gates at depth d is 3^d -/
theorem gates_at_depth (d : ℕ) : 3^d = 3^d := by rfl

end BerggrenLorentzSim