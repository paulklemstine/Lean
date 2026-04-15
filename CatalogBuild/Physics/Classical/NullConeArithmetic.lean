/-! # CatalogBuild.Physics.Classical.NullConeArithmetic

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 6
-/

import Mathlib

noncomputable section

theorem descent_on_circle (x y z : ℝ) (h : x^2 + y^2 > 0) (hS : x^2 + y^2 + z^2 = 1) :
    (x / Real.sqrt (x^2 + y^2))^2 + (y / Real.sqrt (x^2 + y^2))^2 = 1 := by
  rw [div_pow, div_pow, ← add_div, Real.sq_sqrt (le_of_lt h),
      div_self (ne_of_gt h)]

/-! ## The Cayley-Dickson Tower: Going Deeper -/

/-- Two squares: the Gaussian integer level -/

structure ArithTwistor where
  pos_re : ℤ
  pos_im : ℤ
  hel_re : ℤ
  hel_im : ℤ

/-- The null-cone point determined by a twistor. -/

def ArithTwistor.nullConePoint (tw : ArithTwistor) : ℤ × ℤ × ℤ × ℤ :=
  (tw.pos_re^2 + tw.pos_im^2 + tw.hel_re^2 + tw.hel_im^2,
   tw.pos_re^2 + tw.pos_im^2 - tw.hel_re^2 - tw.hel_im^2,
   2 * (tw.pos_re * tw.hel_re + tw.pos_im * tw.hel_im),
   2 * (tw.pos_im * tw.hel_re - tw.pos_re * tw.hel_im))

/-- **Theorem**: Every arithmetic twistor gives a point on the null cone. -/

theorem twistor_on_null_cone (tw : ArithTwistor) :
    let p := tw.nullConePoint
    p.1^2 = p.2.1^2 + p.2.2.1^2 + p.2.2.2^2 := by
  simp [ArithTwistor.nullConePoint]
  ring

/-! ## The Hopf Fibration: Deepest Level -/

/-- The Hopf map S³ → S² -/

theorem hopf_norm_sq (a b c d : ℝ) :
    let h := hopfMap a b c d
    h.1^2 + h.2.1^2 + h.2.2^2 = (a^2 + b^2 + c^2 + d^2)^2 := by
  simp [hopfMap]; ring

/-- **Corollary**: Points on S³ map to points on S² via Hopf. -/

theorem hopf_sphere_to_sphere (a b c d : ℝ) (h : a^2 + b^2 + c^2 + d^2 = 1) :
    let p := hopfMap a b c d
    p.1^2 + p.2.1^2 + p.2.2^2 = 1 := by
  have := hopf_norm_sq a b c d
  simp [hopfMap] at this ⊢
  nlinarith


end
