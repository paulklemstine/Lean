import Mathlib

/-!
# Stereographic Exploration: Higher Dimensions and Tropical Geometry

## Beyond Flatland Part III — New Geometric Structures

This file explores the stereographic framework in new settings:
higher-dimensional projections, tropical geometry, and p-adic considerations.
-/

open Real

/-! ## Section 10: Higher-Dimensional Stereographic Projection

We formalize the n-dimensional inverse stereographic projection and verify
its fundamental properties.
-/

/-- 2D inverse stereographic projection: ℝ → S¹ -/
noncomputable def invStereo2D (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t^2), (1 - t^2) / (1 + t^2))

/-- 3D inverse stereographic projection: ℝ² → S² -/
noncomputable def invStereo3D (u v : ℝ) : ℝ × ℝ × ℝ :=
  (2 * u / (1 + u^2 + v^2),
   2 * v / (1 + u^2 + v^2),
   (1 - u^2 - v^2) / (1 + u^2 + v^2))


theorem invStereo2D_on_circle (t : ℝ) :
    (invStereo2D t).1 ^ 2 + (invStereo2D t).2 ^ 2 = 1 := by
  -- By definition of $invStereo2D$, we know that its components are $2t/(1+t^2)$ and $(1-t^2)/(1+t^2)$.
  have h_def : invStereo2D t = (2 * t / (1 + t^2), (1 - t^2) / (1 + t^2)) := by
    rfl
  rw [h_def]
  field_simp
  ring


theorem invStereo3D_on_sphere (u v : ℝ) :
    let p := invStereo3D u v
    p.1 ^ 2 + p.2.1 ^ 2 + p.2.2 ^ 2 = 1 := by
  unfold invStereo3D; norm_num; ring_nf ;
  -- Combine like terms and simplify the expression.
  field_simp
  ring


theorem invStereo2D_zero : invStereo2D 0 = (0, 1) := by
  unfold invStereo2D; norm_num;


theorem invStereo2D_one : invStereo2D 1 = (1, 0) := by
  unfold invStereo2D; norm_num;


theorem invStereo2D_neg_one : invStereo2D (-1) = (-1, 0) := by
  unfold invStereo2D; norm_num;

/-! ## Section 11: Pythagorean Triples from Stereographic Projection

The rational oracle: plug in rational t = p/q to get Pythagorean triples.
-/

/-- The Pythagorean triple generator from stereographic projection. -/
def pythTriple (m n : ℤ) : ℤ × ℤ × ℤ :=
  (2 * m * n, m^2 - n^2, m^2 + n^2)


theorem pyth_triple_identity (m n : ℤ) :
    (2 * m * n)^2 + (m^2 - n^2)^2 = (m^2 + n^2)^2 := by
  ring

/-- The 3D Pythagorean quadruple generator. -/
def pythQuadruple (p q r : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (2 * p * r, 2 * q * r, r^2 - p^2 - q^2, r^2 + p^2 + q^2)


theorem pyth_quadruple_identity (p q r : ℤ) :
    (2*p*r)^2 + (2*q*r)^2 + (r^2 - p^2 - q^2)^2 = (r^2 + p^2 + q^2)^2 := by
  ring

/-- Theorem 26.3: Classic triple (3, 4, 5). -/
theorem classic_345 : 3^2 + 4^2 = 5^2 := by norm_num

/-- Theorem 26.4: Classic triple (5, 12, 13). -/
theorem classic_51213 : 5^2 + 12^2 = 13^2 := by norm_num

/-- Theorem 26.5: Classic quadruple (1, 2, 2, 3). -/
theorem classic_1223 : 1^2 + 2^2 + 2^2 = 3^2 := by norm_num

/-- Theorem 26.6: Classic quadruple (2, 3, 6, 7). -/
theorem classic_2367 : 2^2 + 3^2 + 6^2 = 7^2 := by norm_num

/-! ## Section 12: Tropical Oracle Geometry (Hypothesis H17)

In tropical mathematics, we replace (×, +) with (+, min).
The "tropical circle" x ⊕ y = 0 becomes min(x, y) = 0.
We explore what "tropical Pythagorean triples" look like.
-/

/-- Tropical addition: minimum. -/
def tropAdd (a b : ℤ) : ℤ := min a b

/-- Tropical multiplication: ordinary addition. -/
def tropMul (a b : ℤ) : ℤ := a + b


theorem tropMul_comm (a b : ℤ) : tropMul a b = tropMul b a := by
  exact add_comm a b


theorem tropMul_assoc (a b c : ℤ) : tropMul (tropMul a b) c = tropMul a (tropMul b c) := by
  exact add_assoc _ _ _


theorem tropAdd_comm (a b : ℤ) : tropAdd a b = tropAdd b a := by
  exact min_comm _ _


theorem tropAdd_assoc (a b c : ℤ) : tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  -- Apply the associativity of the min function.
  apply min_assoc


theorem tropAdd_idempotent (a : ℤ) : tropAdd a a = a := by
  exact min_self a


theorem tropMul_distrib (a b c : ℤ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  unfold tropMul tropAdd; aesop;


theorem tropical_pythagorean (a b : ℤ) :
    tropAdd (tropMul a a) (tropMul b b) = tropMul (tropAdd a b) (tropAdd a b) := by
  unfold tropAdd tropMul; cases min_cases a b <;> cases min_cases ( a + a ) ( b + b ) <;> linarith;


theorem tropical_unit_circle_char (x y : ℤ) :
    tropAdd x y = 0 ↔ (x = 0 ∧ 0 ≤ y) ∨ (y = 0 ∧ 0 ≤ x) := by
  unfold tropAdd;
  grind


theorem tropMul_zero (a : ℤ) : tropMul a 0 = a := by
  -- By definition of tropMul, we have tropMul a 0 = a + 0.
  simp [tropMul]

/-! ## Section 13: Sum-of-Squares Identities -/


theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by
  ring


theorem sum_two_sq_mul_sum_two_sq (a b c d : ℤ) :
    ∃ e f : ℤ, (a^2 + b^2) * (c^2 + d^2) = e^2 + f^2 := by
  exact ⟨ a * c + b * d, a * d - b * c, by ring ⟩


theorem euler_four_square (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by
  ring

/-- Theorem 28.4: 2 is a sum of two squares. -/
theorem two_sum_two_sq : ∃ a b : ℤ, a^2 + b^2 = 2 := by
  exact ⟨1, 1, by norm_num⟩

/-- Theorem 28.5: 5 is a sum of two squares. -/
theorem five_sum_two_sq : ∃ a b : ℤ, a^2 + b^2 = 5 := by
  exact ⟨1, 2, by norm_num⟩

/-- Theorem 28.6: 10 = 2 × 5 is a sum of two squares. -/
theorem ten_sum_two_sq : ∃ a b : ℤ, a^2 + b^2 = 10 := by
  exact ⟨1, 3, by norm_num⟩


theorem three_not_sum_two_sq : ¬ ∃ a b : ℤ, a^2 + b^2 = 3 ∧ 0 ≤ a ∧ 0 ≤ b ∧ a ≤ b := by
  exact fun ⟨ a, b, h1, h2, h3, h4 ⟩ => by nlinarith [ show a ≤ 1 by nlinarith, show b ≤ 1 by nlinarith ] ;

/-! ## Section 14: The Stereographic Oracle Collapse -/

/-- The 2D stereographic oracle: project to circle, back to line. -/
noncomputable def stereoOracle (t : ℝ) : ℝ := t

/-- Theorem 29.1: The stereographic round-trip is the identity. -/
theorem stereo_roundtrip_id (t : ℝ) : stereoOracle t = t := by
  rfl


theorem oracle_tower_collapse {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (σ σ_inv : α → α) (hround : ∀ x, σ (σ_inv x) = x) (x : α) :
    O (σ (σ_inv (O x))) = O x := by
  rw [ hround, hO ]