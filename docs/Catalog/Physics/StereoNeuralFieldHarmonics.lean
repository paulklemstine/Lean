import Mathlib
import Physics.StereoNeuralFieldCalculus

/-!
# Stereographic neural fields II: the chart, its conformal factor, and pulled-back harmonics

Let `σ : ℝ² → S² ⊆ ℝ³` be inverse stereographic projection from the north pole,

`σ(x,y) = (2xW, 2yW, (x²+y²-1)W)`,  `W = (1+x²+y²)⁻¹`.

Two structural theorems are proved first.

* `pullback_metric_xx`, `pullback_metric_yy`, `pullback_metric_xy`: the pullback of the
  Euclidean metric of `ℝ³` under `σ` is `4W²(dx² + dy²)`.  This is the conformal weight
  used to transport a neural-field PDE from the cortical sphere to the plane; because the
  chart is two-dimensional, `Δ_g = (4W²)⁻¹ Δ_euclid`.
* `chart_x/y/z_isCoord` and the orthogonality lemmas: the three chart coordinates satisfy
  `Δ σ_i = -2 (4W²) σ_i` and `∇σ_i · ∇σ_j = 4W² (δ_ij - σ_i σ_j)`.  The second identity is
  the *induced metric identity* of the round sphere, written in the plane chart.

Everything else is derived from these by the syntactic Leibniz rules of
`Physics.StereoNeuralFieldCalculus`: the generic lemmas `lap_coord_mul`, `lap_coord_sq`,
`lap_coord_cube`, `lap_coord_mul_sq`, `lap_coord_mul_mul` compute the Laplacian of any
quadratic or cubic monomial in the chart coordinates once, and the fifteen real spherical
harmonics of degrees `1, 2, 3` inherit the Laplace–Beltrami eigenvalue relation

`Δ_euclid u = -l(l+1) (4W²) u`,  i.e.  `Δ_{S²} (u ∘ σ⁻¹) = -l(l+1) (u ∘ σ⁻¹)`,

with no further rational-function computation.  Linear independence of each family is
proved as well, so the degree-`l` pattern space genuinely has dimension at least `2l+1`.
-/

namespace StereoNeuralField

noncomputable section

open NExpr

/-! ## The inverse stereographic chart as syntax -/

/-- First chart coordinate `σ₁ = 2xW`. -/
def chartX : NExpr := const 2 * X * Wt

/-- Second chart coordinate `σ₂ = 2yW`. -/
def chartY : NExpr := const 2 * Y * Wt

/-- Third chart coordinate `σ₃ = (x²+y²-1)W`; it tends to the north-pole value `1`
as the plane point escapes to infinity. -/
def chartZ : NExpr := (X * X + Y * Y - const 1) * Wt

@[simp] theorem evalAt_chartX (x y : ℝ) : evalAt chartX x y = 2 * x * W x y := rfl
@[simp] theorem evalAt_chartY (x y : ℝ) : evalAt chartY x y = 2 * y * W x y := rfl

@[simp] theorem evalAt_chartZ (x y : ℝ) :
    evalAt chartZ x y = (x ^ 2 + y ^ 2 - 1) * W x y := by
  show (x * x + y * y + (-1) * 1) * W x y = _
  ring

/-- The chart lands on the unit sphere. -/
theorem chart_on_sphere (x y : ℝ) :
    evalAt chartX x y ^ 2 + evalAt chartY x y ^ 2 + evalAt chartZ x y ^ 2 = 1 := by
  simp only [evalAt_chartX, evalAt_chartY, evalAt_chartZ, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

/-! ## The conformal factor of the chart -/

/-- `|∂ₓσ|² = 4W²`: the `x`-diagonal entry of the pullback metric. -/
theorem pullback_metric_xx (x y : ℝ) :
    deriv (fun s => evalAt chartX s y) x ^ 2 + deriv (fun s => evalAt chartY s y) x ^ 2 +
      deriv (fun s => evalAt chartZ s y) x ^ 2 = 4 * W x y ^ 2 := by
  rw [deriv_evalAt_x, deriv_evalAt_x, deriv_evalAt_x]
  simp only [chartX, chartY, chartZ, dx, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

/-- `|∂_yσ|² = 4W²`: the `y`-diagonal entry of the pullback metric. -/
theorem pullback_metric_yy (x y : ℝ) :
    deriv (fun t => evalAt chartX x t) y ^ 2 + deriv (fun t => evalAt chartY x t) y ^ 2 +
      deriv (fun t => evalAt chartZ x t) y ^ 2 = 4 * W x y ^ 2 := by
  rw [deriv_evalAt_y, deriv_evalAt_y, deriv_evalAt_y]
  simp only [chartX, chartY, chartZ, dy, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

/-- `∂ₓσ · ∂_yσ = 0`: the chart is orthogonal, hence conformal. -/
theorem pullback_metric_xy (x y : ℝ) :
    deriv (fun s => evalAt chartX s y) x * deriv (fun t => evalAt chartX x t) y +
      deriv (fun s => evalAt chartY s y) x * deriv (fun t => evalAt chartY x t) y +
      deriv (fun s => evalAt chartZ s y) x * deriv (fun t => evalAt chartZ x t) y = 0 := by
  rw [deriv_evalAt_x, deriv_evalAt_x, deriv_evalAt_x, deriv_evalAt_y, deriv_evalAt_y,
    deriv_evalAt_y]
  simp only [chartX, chartY, chartZ, dx, dy, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

/-! ## Chart coordinates as Laplace–Beltrami eigenfunctions -/

/-- A syntactic function behaves like a chart coordinate of the round sphere: it is a
degree-one eigenfunction of the conformal Laplacian and its gradient has the length
prescribed by the induced metric of `S²`. -/
structure IsChartCoord (a : NExpr) : Prop where
  lap : ∀ x y, laplacian (evalAt a) x y = -2 * (4 * W x y ^ 2) * evalAt a x y
  selfDot : ∀ x y, gradDot (evalAt a) (evalAt a) x y
      = 4 * W x y ^ 2 * (1 - evalAt a x y ^ 2)

/-- Two chart coordinates are orthogonal in the induced metric. -/
def OrthCoord (a b : NExpr) : Prop :=
  ∀ x y, gradDot (evalAt a) (evalAt b) x y = 4 * W x y ^ 2 * (-(evalAt a x y * evalAt b x y))

theorem gradDot_comm (a b : NExpr) (x y : ℝ) :
    gradDot (evalAt a) (evalAt b) x y = gradDot (evalAt b) (evalAt a) x y := by
  unfold gradDot; ring

theorem OrthCoord.symm {a b : NExpr} (h : OrthCoord a b) : OrthCoord b a := by
  intro x y
  rw [gradDot_comm, h x y]
  ring

theorem chartX_isCoord : IsChartCoord chartX := by
  constructor
  · intro x y
    rw [laplacian_evalAt]
    simp only [chartX, lapE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring
  · intro x y
    rw [gradDot_evalAt]
    simp only [chartX, dotE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring

theorem chartY_isCoord : IsChartCoord chartY := by
  constructor
  · intro x y
    rw [laplacian_evalAt]
    simp only [chartY, lapE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring
  · intro x y
    rw [gradDot_evalAt]
    simp only [chartY, dotE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring

theorem chartZ_isCoord : IsChartCoord chartZ := by
  constructor
  · intro x y
    rw [laplacian_evalAt]
    simp only [chartZ, lapE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring
  · intro x y
    rw [gradDot_evalAt]
    simp only [chartZ, dotE, dx, dy, evalAt, W]
    have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
    field_simp
    ring

theorem chartXY_orth : OrthCoord chartX chartY := by
  intro x y
  rw [gradDot_evalAt]
  simp only [chartX, chartY, dotE, dx, dy, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

theorem chartXZ_orth : OrthCoord chartX chartZ := by
  intro x y
  rw [gradDot_evalAt]
  simp only [chartX, chartZ, dotE, dx, dy, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

theorem chartYZ_orth : OrthCoord chartY chartZ := by
  intro x y
  rw [gradDot_evalAt]
  simp only [chartY, chartZ, dotE, dx, dy, evalAt, W]
  have h : (1 + x ^ 2 + y ^ 2) ≠ 0 := denom_ne_zero x y
  field_simp
  ring

/-! ## Generic Leibniz computations for monomials in the chart coordinates -/

@[simp] theorem evalAt_const (c x y : ℝ) : evalAt (const c) x y = c := rfl

theorem laplacian_const (c x y : ℝ) : laplacian (evalAt (const c)) x y = 0 := by
  rw [laplacian_evalAt]
  simp [lapE, dx, dy, evalAt]

/-- Laplacian of the square of a chart coordinate. -/
theorem lap_coord_sq {a : NExpr} (ha : IsChartCoord a) (x y : ℝ) :
    laplacian (evalAt (a * a)) x y = 4 * W x y ^ 2 * (2 - 6 * evalAt a x y ^ 2) := by
  rw [laplacian_mul, ha.lap, ha.selfDot]
  ring

/-- Laplacian of a product of two orthogonal chart coordinates: a degree-two eigenvalue. -/
theorem lap_coord_mul {a b : NExpr} (ha : IsChartCoord a) (hb : IsChartCoord b)
    (hab : OrthCoord a b) (x y : ℝ) :
    laplacian (evalAt (a * b)) x y
      = -6 * (4 * W x y ^ 2) * (evalAt a x y * evalAt b x y) := by
  rw [laplacian_mul, ha.lap, hb.lap, hab x y]
  ring

/-- Laplacian of the cube of a chart coordinate. -/
theorem lap_coord_cube {a : NExpr} (ha : IsChartCoord a) (x y : ℝ) :
    laplacian (evalAt (a * (a * a))) x y
      = 4 * W x y ^ 2 * (6 * evalAt a x y - 12 * evalAt a x y ^ 3) := by
  rw [laplacian_mul, lap_coord_sq ha, ha.lap, gradDot_mul_right, ha.selfDot]
  simp only [evalAt_mul]
  ring

/-- Laplacian of `a b²` for orthogonal chart coordinates `a ⟂ b`. -/
theorem lap_coord_mul_sq {a b : NExpr} (ha : IsChartCoord a) (hb : IsChartCoord b)
    (hab : OrthCoord a b) (x y : ℝ) :
    laplacian (evalAt (a * (b * b))) x y
      = 4 * W x y ^ 2 * (2 * evalAt a x y - 12 * evalAt a x y * evalAt b x y ^ 2) := by
  rw [laplacian_mul, lap_coord_sq hb, ha.lap, gradDot_mul_right, hab x y]
  simp only [evalAt_mul]
  ring

/-- Laplacian of `abc` for pairwise orthogonal chart coordinates: a degree-three
eigenvalue. -/
theorem lap_coord_mul_mul {a b c : NExpr} (ha : IsChartCoord a) (hb : IsChartCoord b)
    (hc : IsChartCoord c) (hab : OrthCoord a b) (hac : OrthCoord a c) (hbc : OrthCoord b c)
    (x y : ℝ) :
    laplacian (evalAt (a * (b * c))) x y
      = -12 * (4 * W x y ^ 2) * (evalAt a x y * (evalAt b x y * evalAt c x y)) := by
  rw [laplacian_mul, lap_coord_mul hb hc hbc, ha.lap, gradDot_mul_right, hab x y, hac x y]
  simp only [evalAt_mul]
  ring

/-! ## Laplace–Beltrami eigenfunctions of the pulled-back sphere -/

/-- `u` pulled back through the stereographic chart is a degree-`l` Laplace–Beltrami
eigenfunction of the round sphere.  Because the pullback metric is `4W²(dx²+dy²)` and the
chart is two-dimensional, `Δ_g = (4W²)⁻¹ Δ_euclid`, so this Euclidean identity says exactly
`Δ_{S²} Y = -l(l+1) Y`. -/
def LapBeltrami (u : NExpr) (l : ℕ) : Prop :=
  ∀ x y, laplacian (evalAt u) x y = -((l : ℝ) * (l + 1)) * (4 * W x y ^ 2) * evalAt u x y

/-- Eigenfunctions of a fixed degree form a linear space: sums. -/
theorem LapBeltrami.add {u v : NExpr} {l : ℕ} (hu : LapBeltrami u l) (hv : LapBeltrami v l) :
    LapBeltrami (u + v) l := by
  intro x y
  rw [laplacian_add, hu x y, hv x y]
  simp only [evalAt_add]
  ring

/-- Eigenfunctions of a fixed degree form a linear space: scalar multiples. -/
theorem LapBeltrami.smul {u : NExpr} {l : ℕ} (c : ℝ) (hu : LapBeltrami u l) :
    LapBeltrami (const c * u) l := by
  intro x y
  rw [laplacian_const_mul, hu x y]
  simp only [evalAt_mul, evalAt_const]
  ring

/-- Eigenfunctions of a fixed degree form a linear space: differences. -/
theorem LapBeltrami.sub {u v : NExpr} {l : ℕ} (hu : LapBeltrami u l) (hv : LapBeltrami v l) :
    LapBeltrami (u - v) l := by
  intro x y
  rw [laplacian_sub, hu x y, hv x y]
  simp only [evalAt_sub]
  ring

/-- Every chart coordinate is a degree-one eigenfunction. -/
theorem IsChartCoord.lapBeltrami {a : NExpr} (ha : IsChartCoord a) : LapBeltrami a 1 := by
  intro x y
  rw [ha.lap]
  norm_num

/-! ### Degree one: the three coordinate patterns -/

theorem chartX_deg1 : LapBeltrami chartX 1 := chartX_isCoord.lapBeltrami
theorem chartY_deg1 : LapBeltrami chartY 1 := chartY_isCoord.lapBeltrami
theorem chartZ_deg1 : LapBeltrami chartZ 1 := chartZ_isCoord.lapBeltrami

/-! ### Degree two: the five quadrupolar patterns -/

/-- `xy` mode. -/
def H2xy : NExpr := chartX * chartY
/-- `xz` mode. -/
def H2xz : NExpr := chartX * chartZ
/-- `yz` mode. -/
def H2yz : NExpr := chartY * chartZ
/-- `x² - y²` mode. -/
def H2x2y2 : NExpr := chartX * chartX - chartY * chartY
/-- `3z² - 1` mode. -/
def H2z2 : NExpr := const 3 * (chartZ * chartZ) - const 1

theorem H2xy_deg2 : LapBeltrami H2xy 2 := by
  intro x y
  rw [H2xy, lap_coord_mul chartX_isCoord chartY_isCoord chartXY_orth]
  simp only [evalAt_mul]
  norm_num

theorem H2xz_deg2 : LapBeltrami H2xz 2 := by
  intro x y
  rw [H2xz, lap_coord_mul chartX_isCoord chartZ_isCoord chartXZ_orth]
  simp only [evalAt_mul]
  norm_num

theorem H2yz_deg2 : LapBeltrami H2yz 2 := by
  intro x y
  rw [H2yz, lap_coord_mul chartY_isCoord chartZ_isCoord chartYZ_orth]
  simp only [evalAt_mul]
  norm_num

theorem H2x2y2_deg2 : LapBeltrami H2x2y2 2 := by
  intro x y
  rw [H2x2y2, laplacian_sub, lap_coord_sq chartX_isCoord, lap_coord_sq chartY_isCoord]
  simp only [evalAt_sub, evalAt_mul]
  norm_num
  ring

theorem H2z2_deg2 : LapBeltrami H2z2 2 := by
  intro x y
  rw [H2z2, laplacian_sub, laplacian_const_mul, lap_coord_sq chartZ_isCoord, laplacian_const]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

/-! ### Degree three: the seven octupolar patterns -/

/-- `x(x²-3y²)` mode (three-fold symmetric). -/
def H3a : NExpr := chartX * (chartX * chartX) - const 3 * (chartX * (chartY * chartY))
/-- `y(3x²-y²)` mode (three-fold symmetric). -/
def H3b : NExpr := const 3 * (chartY * (chartX * chartX)) - chartY * (chartY * chartY)
/-- `z(x²-y²)` mode. -/
def H3c : NExpr := chartZ * (chartX * chartX) - chartZ * (chartY * chartY)
/-- `xyz` mode. -/
def H3d : NExpr := chartX * (chartY * chartZ)
/-- `x(5z²-1)` mode. -/
def H3e : NExpr := const 5 * (chartX * (chartZ * chartZ)) - chartX
/-- `y(5z²-1)` mode. -/
def H3f : NExpr := const 5 * (chartY * (chartZ * chartZ)) - chartY
/-- `z(5z²-3)` mode (the zonal octupole). -/
def H3g : NExpr := const 5 * (chartZ * (chartZ * chartZ)) - const 3 * chartZ

theorem H3a_deg3 : LapBeltrami H3a 3 := by
  intro x y
  rw [H3a, laplacian_sub, laplacian_const_mul, lap_coord_cube chartX_isCoord,
    lap_coord_mul_sq chartX_isCoord chartY_isCoord chartXY_orth]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

theorem H3b_deg3 : LapBeltrami H3b 3 := by
  intro x y
  rw [H3b, laplacian_sub, laplacian_const_mul, lap_coord_cube chartY_isCoord,
    lap_coord_mul_sq chartY_isCoord chartX_isCoord chartXY_orth.symm]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

theorem H3c_deg3 : LapBeltrami H3c 3 := by
  intro x y
  rw [H3c, laplacian_sub, lap_coord_mul_sq chartZ_isCoord chartX_isCoord chartXZ_orth.symm,
    lap_coord_mul_sq chartZ_isCoord chartY_isCoord chartYZ_orth.symm]
  simp only [evalAt_sub, evalAt_mul]
  norm_num
  ring

theorem H3d_deg3 : LapBeltrami H3d 3 := by
  intro x y
  rw [H3d, lap_coord_mul_mul chartX_isCoord chartY_isCoord chartZ_isCoord chartXY_orth
    chartXZ_orth chartYZ_orth]
  simp only [evalAt_mul]
  norm_num

theorem H3e_deg3 : LapBeltrami H3e 3 := by
  intro x y
  rw [H3e, laplacian_sub, laplacian_const_mul,
    lap_coord_mul_sq chartX_isCoord chartZ_isCoord chartXZ_orth, chartX_isCoord.lap]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

theorem H3f_deg3 : LapBeltrami H3f 3 := by
  intro x y
  rw [H3f, laplacian_sub, laplacian_const_mul,
    lap_coord_mul_sq chartY_isCoord chartZ_isCoord chartYZ_orth, chartY_isCoord.lap]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

theorem H3g_deg3 : LapBeltrami H3g 3 := by
  intro x y
  rw [H3g, laplacian_sub, laplacian_const_mul, laplacian_const_mul,
    lap_coord_cube chartZ_isCoord, chartZ_isCoord.lap]
  simp only [evalAt_sub, evalAt_mul, evalAt_const]
  norm_num
  ring

/-! ## Linear independence: the degree-`l` pattern space really has dimension `2l+1` -/

/-- The three degree-one modes are linearly independent as functions on the plane. -/
theorem degree_one_independent (a b c : ℝ)
    (h : ∀ x y, a * evalAt chartX x y + b * evalAt chartY x y + c * evalAt chartZ x y = 0) :
    a = 0 ∧ b = 0 ∧ c = 0 := by
  have h0 := h 0 0
  have h1 := h 1 0
  have h2 := h 0 1
  norm_num [evalAt_chartX, evalAt_chartY, evalAt_chartZ, W] at h0 h1 h2
  exact ⟨h1, h2, h0⟩

/-- The five degree-two modes are linearly independent as functions on the plane. -/
theorem degree_two_independent (a b c d e : ℝ)
    (h : ∀ x y, a * evalAt H2xy x y + b * evalAt H2xz x y + c * evalAt H2yz x y
      + d * evalAt H2x2y2 x y + e * evalAt H2z2 x y = 0) :
    a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 ∧ e = 0 := by
  have h0 := h 0 0
  have h1 := h 1 0
  have h2 := h 2 0
  have h3 := h 0 2
  have h4 := h 1 1
  norm_num [H2xy, H2xz, H2yz, H2x2y2, H2z2, evalAt_sub, evalAt_mul, evalAt_const,
    evalAt_chartX, evalAt_chartY, evalAt_chartZ, W] at h0 h1 h2 h3 h4
  refine ⟨by linarith, by linarith, by linarith, by linarith, by linarith⟩

/-- The seven degree-three modes are linearly independent as functions on the plane. -/
theorem degree_three_independent (c1 c2 c3 c4 c5 c6 c7 : ℝ)
    (h : ∀ x y, c1 * evalAt H3a x y + c2 * evalAt H3b x y + c3 * evalAt H3c x y
      + c4 * evalAt H3d x y + c5 * evalAt H3e x y + c6 * evalAt H3f x y
      + c7 * evalAt H3g x y = 0) :
    c1 = 0 ∧ c2 = 0 ∧ c3 = 0 ∧ c4 = 0 ∧ c5 = 0 ∧ c6 = 0 ∧ c7 = 0 := by
  have h0 := h 0 0
  have h1 := h 1 0
  have h2 := h 0 1
  have h3 := h 2 0
  have h4 := h 0 2
  have h5 := h (1/2) 0
  have h6 := h 0 (1/2)
  have h7 := h 1 1
  norm_num [H3a, H3b, H3c, H3d, H3e, H3f, H3g, evalAt_sub, evalAt_mul, evalAt_const,
    evalAt_chartX, evalAt_chartY, evalAt_chartZ, W] at h0 h1 h2 h3 h4 h5 h6 h7
  refine ⟨by linarith, by linarith, by linarith, by linarith, by linarith, by linarith,
    by linarith⟩

end

end StereoNeuralField