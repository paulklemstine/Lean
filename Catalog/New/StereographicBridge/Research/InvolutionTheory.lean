import Mathlib

/-!
# SPB Involutions and Functional Equations

This file studies the involutive properties of SPB and related functional equations.

## Main Results
- The half-angle SPB formula
- Triple product identity
- SPB conjugation
- SPB reflection identities
-/

noncomputable section
open Real

def spb_inv (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-! ## Half-Angle Formula -/

/-- spb(t, t) = 2t/(1-t²). -/
theorem spb_half_angle_identity (t : ℝ) (h : 1 - t ^ 2 ≠ 0) :
    spb_inv t t = 2 * t / (1 - t ^ 2) := by
  unfold spb_inv; field_simp; ring

/-! ## Iterated SPB Recurrence -/

def spb_iter (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb_inv x (spb_iter x n)

theorem spb_iter_zero (x : ℝ) : spb_iter x 0 = 0 := rfl
theorem spb_iter_one (x : ℝ) : spb_iter x 1 = x := by simp [spb_iter, spb_inv]

theorem spb_iter_two (x : ℝ) : spb_iter x 2 = 2 * x / (1 - x ^ 2) := by
  simp [spb_iter, spb_inv]; ring

/-! ## Triple SPB Identities -/

/-- The triple-SPB formula: spb(spb(x,y), z) expanded. -/
theorem spb_triple_expand (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - spb_inv x y * z ≠ 0) :
    spb_inv (spb_inv x y) z =
    (x + y + z - x * y * z) / (1 - x * y - x * z - y * z) := by
  unfold spb_inv; field_simp; ring

/-- The triple formula numerator is symmetric in x, y, z. -/
theorem spb_triple_symmetric (x y z : ℝ) :
    x + y + z - x * y * z = y + z + x - y * z * x := by ring

/-- The triple formula denominator is symmetric in x, y, z. -/
theorem spb_triple_denom_symmetric (x y z : ℝ) :
    1 - x * y - x * z - y * z = 1 - y * z - y * x - z * x := by ring

/-! ## SPB Conjugation -/

/-
Translating by a then by -a returns to start.
-/
theorem spb_conjugation_trivial (a x : ℝ)
    (h1 : 1 + a * x ≠ 0) (h2 : 1 - a * spb_inv x (-a) ≠ 0) :
    spb_inv a (spb_inv x (-a)) = x := by
  grind +locals

/-! ## SPB Reflection Identities -/

/-
SPB sum identity.
-/
theorem spb_sum_reflection (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_inv x y + spb_inv x (-y) =
    2 * x * (1 + y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb_inv;
  grind

/-
SPB product identity.
-/
theorem spb_product_reflection (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_inv x y * spb_inv x (-y) =
    (x ^ 2 - y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb_inv; rw [ div_mul_div_comm ] ; ring;

end