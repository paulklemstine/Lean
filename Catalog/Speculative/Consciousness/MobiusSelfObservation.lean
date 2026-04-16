/-! # CatalogBuild.Speculative.Consciousness.MobiusSelfObservation

Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 13
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Consciousness.MobiusSelfObservation
Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 13] -/
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



def MobiusTrans.isFixedPoint (m : MobiusTrans) (z : ℂ) : Prop :=
  m.apply z = z



theorem mobius_fixed_point_equation (m : MobiusTrans) (z : ℂ)
    (hcz : m.c * z + m.d ≠ 0) :
    m.isFixedPoint z ↔ m.c * z ^ 2 + (m.d - m.a) * z - m.b = 0 := by
  unfold MobiusTrans.isFixedPoint MobiusTrans.apply
  rw [div_eq_iff hcz]
  grind



structure BinocularSelfObserver where
  left_eye : MobiusTrans
  right_eye : MobiusTrans



def BinocularSelfObserver.depth (B : BinocularSelfObserver) (z : ℂ) : ℂ :=
  B.left_eye.apply z - B.right_eye.apply z



theorem depth_zero_when_identical (m : MobiusTrans) (z : ℂ) :
    (BinocularSelfObserver.mk m m).depth z = 0 := by
  simp [BinocularSelfObserver.depth, sub_self]



def awarenessSymmetries (awareness : Set ℂ) : Set MobiusTrans :=
  { m | ∀ z ∈ awareness, m.apply z ∈ awareness }



theorem id_preserves_awareness (awareness : Set ℂ) :
    MobiusTrans.one ∈ awarenessSymmetries awareness := by
  intro z hz
  suffices MobiusTrans.one.apply z = z by rw [this]; exact hz
  simp [MobiusTrans.apply, MobiusTrans.one, zero_mul, zero_add, div_one]



def stereographicProj (x y z : ℝ) (hz : z ≠ 1) : ℂ :=
  ⟨x / (1 - z), y / (1 - z)⟩



def invStereographicProj (w : ℂ) : ℝ × ℝ × ℝ :=
  let r2 := w.re ^ 2 + w.im ^ 2
  (2 * w.re / (1 + r2), 2 * w.im / (1 + r2), (r2 - 1) / (1 + r2))



end
