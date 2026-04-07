import Mathlib

/-!
# Möbius Group as Symmetry of Self-Observation

## Core Idea

The Möbius group models the symmetry of self-observation:
1. Fixed points = awareness attractors
2. Cross-ratio invariance = consciousness preserves relational structure
3. Binocular self-observation = stereographic depth
-/

open Complex

noncomputable section

/-! ## §1: Möbius Transformations -/

structure MobiusTrans where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ
  det_ne_zero : a * d - b * c ≠ 0

def MobiusTrans.apply (m : MobiusTrans) (z : ℂ) : ℂ :=
  (m.a * z + m.b) / (m.c * z + m.d)

def MobiusTrans.one : MobiusTrans where
  a := 1; b := 0; c := 0; d := 1
  det_ne_zero := by ring_nf; exact one_ne_zero

def MobiusTrans.inv (m : MobiusTrans) : MobiusTrans where
  a := m.d; b := -m.b; c := -m.c; d := m.a
  det_ne_zero := by simp [mul_comm]; exact m.det_ne_zero

/-! ## §2: Fixed Points -/

def MobiusTrans.isFixedPoint (m : MobiusTrans) (z : ℂ) : Prop :=
  m.apply z = z

/-
Fixed points satisfy cz² + (d-a)z - b = 0.
-/
theorem mobius_fixed_point_equation (m : MobiusTrans) (z : ℂ)
    (hcz : m.c * z + m.d ≠ 0) :
    m.isFixedPoint z ↔ m.c * z ^ 2 + (m.d - m.a) * z - m.b = 0 := by
  unfold MobiusTrans.isFixedPoint MobiusTrans.apply
  rw [div_eq_iff hcz]
  grind

/-! ## §3: Cross-Ratio -/

def crossRatio (z₁ z₂ z₃ z₄ : ℂ) : ℂ :=
  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))

/-! ## §4: Self-Observation Model -/

structure BinocularSelfObserver where
  left_eye : MobiusTrans
  right_eye : MobiusTrans

def BinocularSelfObserver.depth (B : BinocularSelfObserver) (z : ℂ) : ℂ :=
  B.left_eye.apply z - B.right_eye.apply z

theorem depth_zero_when_identical (m : MobiusTrans) (z : ℂ) :
    (BinocularSelfObserver.mk m m).depth z = 0 := by
  simp [BinocularSelfObserver.depth, sub_self]

/-! ## §5: Möbius Symmetries -/

def awarenessSymmetries (awareness : Set ℂ) : Set MobiusTrans :=
  { m | ∀ z ∈ awareness, m.apply z ∈ awareness }

theorem id_preserves_awareness (awareness : Set ℂ) :
    MobiusTrans.one ∈ awarenessSymmetries awareness := by
  intro z hz
  suffices MobiusTrans.one.apply z = z by rw [this]; exact hz
  simp [MobiusTrans.apply, MobiusTrans.one, zero_mul, zero_add, div_one]

/-! ## §6: Stereographic Projection -/

def stereographicProj (x y z : ℝ) (hz : z ≠ 1) : ℂ :=
  ⟨x / (1 - z), y / (1 - z)⟩

def invStereographicProj (w : ℂ) : ℝ × ℝ × ℝ :=
  let r2 := w.re ^ 2 + w.im ^ 2
  (2 * w.re / (1 + r2), 2 * w.im / (1 + r2), (r2 - 1) / (1 + r2))

end