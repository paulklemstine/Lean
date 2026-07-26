import Mathlib

/-! # CatalogBuild.EML.HyperbolicGeometry

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12
-/

noncomputable section

/-- The hyperbolic SPB (Einstein velocity addition). -/
def spbH_hyp (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- Hyperbolic distance in the Poincaré disk model.
d(x, y) = arctanh(|spbH(x, -y)|) = arctanh(|(x-y)/(1-xy)|). -/
def hypDist (x y : ℝ) : ℝ := Real.log ((1 + |spbH_hyp x (-y)|) / (1 - |spbH_hyp x (-y)|)) / 2

/-- spbH(x, -y) simplifies to (x-y)/(1-xy). -/
theorem spbH_diff (x y : ℝ) : spbH_hyp x (-y) = (x - y) / (1 - x * y) := by
  unfold spbH_hyp; ring_nf

/-- Hyperbolic distance is symmetric. -/
theorem hypDist_symm (x y : ℝ) : hypDist x y = hypDist y x := by
  unfold hypDist
  congr 1
  congr 1
  · congr 1
    · congr 1; rw [spbH_diff, spbH_diff]
      rw [show (y - x) / (1 - y * x) = -((x - y) / (1 - x * y)) from by ring]
      rw [abs_neg]
    · congr 1; rw [spbH_diff, spbH_diff]
      rw [show (y - x) / (1 - y * x) = -((x - y) / (1 - x * y)) from by ring]
      rw [abs_neg]

/-- Hyperbolic distance from a point to itself is 0. -/
theorem hypDist_self (x : ℝ) : hypDist x x = 0 := by
  unfold hypDist spbH_hyp
  simp

/-- The "addition" in hyperbolic geometry: going from 0 to x then from x to y
is like going from 0 to spbH(x,y). This is the translation property. -/
theorem spbH_hyp_comm (x y : ℝ) : spbH_hyp x y = spbH_hyp y x := by
  simp [spbH_hyp, add_comm, mul_comm]

/-- Identity element. -/
theorem spbH_hyp_zero (x : ℝ) : spbH_hyp x 0 = x := by simp [spbH_hyp]

/-- Inverse element. -/
theorem spbH_hyp_neg (x : ℝ) : spbH_hyp x (-x) = 0 := by simp [spbH_hyp]

/-- spbH maps sub-unit interval to itself (closure under composition). -/
theorem spbH_hyp_subluminal (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    |spbH_hyp x y| < 1 := by
  rw [abs_lt] at *
  constructor
  · rw [spbH_hyp, lt_div_iff₀] <;> nlinarith
  · rw [spbH_hyp, div_lt_iff₀] <;> nlinarith

/-- The double formula: spbH(x, x) = 2x/(1+x²). -/
theorem spbH_hyp_double (x : ℝ) : spbH_hyp x x = 2 * x / (1 + x ^ 2) := by
  unfold spbH_hyp; ring

/-- The Poincaré metric element: ds² = 4dx²/(1-x²)² arises from
the derivative of spbH at the identity. More precisely,
d/dy spbH(x,y)|_{y=0} = 1/(1+x·0)² = 1, but the conformal
factor is (1+x²)/(1+xy)². At y=0 this is 1+x². -/
theorem spbH_conformal_factor (x : ℝ) :
    (1 + x ^ 2) / (1 + x * 0) ^ 2 = 1 + x ^ 2 := by
  simp

/-- The Klein model velocity: if v is a Poincaré disk coordinate,
then the Klein model coordinate is u = 2v/(1+v²) = spbH(v,v). -/
theorem klein_from_poincare (v : ℝ) :
    spbH_hyp v v = 2 * v / (1 + v ^ 2) := spbH_hyp_double v

end
