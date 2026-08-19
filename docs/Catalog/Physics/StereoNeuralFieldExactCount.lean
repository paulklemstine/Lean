import Mathlib
import Physics.StereoNeuralFieldCalculus
import Physics.StereoNeuralFieldHarmonics

/-!
# Stereographic neural fields V: the matching upper bound ("exactly `2N+1`")

`Physics.StereoNeuralFieldSelection` produces `2N+1` linearly independent patterns of the
selected degree `N`, i.e. the *lower* bound of the conjectured count.  This file supplies
the matching *upper* bound inside the natural finite-dimensional ansatz of the model: the
polynomials of degree `≤ N` in the three chart coordinates, which is where a
Galerkin/amplitude-equation truncation of a neural-field model lives.

* `degree_one_exact`: an affine function of the chart coordinates is a degree-one
  Laplace–Beltrami eigenfunction if and only if its constant term vanishes.  Together with
  `degree_one_independent` this shows the degree-one pattern space is *exactly*
  three-dimensional, i.e. `2·1+1`.
* `degree_two_exact`: a general quadratic in the chart coordinates that is a degree-two
  eigenfunction necessarily has no linear part and has its constant term locked to minus a
  third of the trace, and it then lies in the span of the five patterns
  `H2xy, H2xz, H2yz, H2x2y2, H2z2`.  Since those five are independent, the degree-two
  pattern space inside the quadratic ansatz is *exactly* five-dimensional, i.e. `2·2+1`.

The two results turn the conjecture's "`2N+1`" from an inequality into an equality for
`N = 1, 2` without importing any spectral theory.
-/

namespace StereoNeuralField

noncomputable section

open NExpr

/-! ## Degree one -/

/-- General affine function of the chart coordinates. -/
def affineMode (c0 c1 c2 c3 : ℝ) : NExpr :=
  const c0 + (const c1 * chartX + (const c2 * chartY + const c3 * chartZ))

theorem lap_affineMode (c0 c1 c2 c3 x y : ℝ) :
    laplacian (evalAt (affineMode c0 c1 c2 c3)) x y
      = 4 * W x y ^ 2 * (-2 * (c1 * evalAt chartX x y + c2 * evalAt chartY x y
          + c3 * evalAt chartZ x y)) := by
  simp only [affineMode, laplacian_add, laplacian_const, laplacian_const_mul,
    chartX_isCoord.lap, chartY_isCoord.lap, chartZ_isCoord.lap]
  ring

/-- **Exactness in degree one.**  Inside the affine ansatz, being a degree-one
Laplace–Beltrami eigenfunction is equivalent to having zero constant term; the pattern
space is therefore exactly the three-dimensional span of the chart coordinates. -/
theorem degree_one_exact (c0 c1 c2 c3 : ℝ) :
    LapBeltrami (affineMode c0 c1 c2 c3) 1 ↔ c0 = 0 := by
  constructor
  · intro h
    have h0 := h 0 0
    rw [lap_affineMode] at h0
    simp only [affineMode, evalAt_add, evalAt_mul, evalAt_const, evalAt_chartX, evalAt_chartY,
      evalAt_chartZ, W] at h0
    norm_num at h0
    linarith
  · intro hc x y
    rw [lap_affineMode]
    simp only [affineMode, evalAt_add, evalAt_mul, evalAt_const, hc]
    push_cast
    ring

/-! ## Degree two -/

/-- General quadratic in the chart coordinates. -/
def quadMode (c0 c1 c2 c3 q11 q22 q33 q12 q13 q23 : ℝ) : NExpr :=
  const c0 + (const c1 * chartX + (const c2 * chartY + (const c3 * chartZ +
    (const q11 * (chartX * chartX) + (const q22 * (chartY * chartY) +
      (const q33 * (chartZ * chartZ) + (const q12 * (chartX * chartY) +
        (const q13 * (chartX * chartZ) + const q23 * (chartY * chartZ)))))))))

theorem lap_quadMode (c0 c1 c2 c3 q11 q22 q33 q12 q13 q23 x y : ℝ) :
    laplacian (evalAt (quadMode c0 c1 c2 c3 q11 q22 q33 q12 q13 q23)) x y
      = 4 * W x y ^ 2 *
          (-2 * (c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y)
            + q11 * (2 - 6 * evalAt chartX x y ^ 2) + q22 * (2 - 6 * evalAt chartY x y ^ 2)
            + q33 * (2 - 6 * evalAt chartZ x y ^ 2)
            - 6 * (q12 * (evalAt chartX x y * evalAt chartY x y)
              + q13 * (evalAt chartX x y * evalAt chartZ x y)
              + q23 * (evalAt chartY x y * evalAt chartZ x y))) := by
  simp only [quadMode, laplacian_add, laplacian_const, laplacian_const_mul,
    chartX_isCoord.lap, chartY_isCoord.lap, chartZ_isCoord.lap,
    lap_coord_sq chartX_isCoord, lap_coord_sq chartY_isCoord, lap_coord_sq chartZ_isCoord,
    lap_coord_mul chartX_isCoord chartY_isCoord chartXY_orth,
    lap_coord_mul chartX_isCoord chartZ_isCoord chartXZ_orth,
    lap_coord_mul chartY_isCoord chartZ_isCoord chartYZ_orth]
  ring

theorem evalAt_quadMode (c0 c1 c2 c3 q11 q22 q33 q12 q13 q23 x y : ℝ) :
    evalAt (quadMode c0 c1 c2 c3 q11 q22 q33 q12 q13 q23) x y
      = c0 + c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y
        + q11 * evalAt chartX x y ^ 2 + q22 * evalAt chartY x y ^ 2
        + q33 * evalAt chartZ x y ^ 2 + q12 * (evalAt chartX x y * evalAt chartY x y)
        + q13 * (evalAt chartX x y * evalAt chartZ x y)
        + q23 * (evalAt chartY x y * evalAt chartZ x y) := by
  simp only [quadMode, evalAt_add, evalAt_mul, evalAt_const]
  ring

/-- The pointwise constraint imposed by the degree-two eigenvalue equation. -/
theorem quadMode_constraint {c0 c1 c2 c3 q11 q22 q33 q12 q13 q23 : ℝ}
    (h : LapBeltrami (quadMode c0 c1 c2 c3 q11 q22 q33 q12 q13 q23) 2) (x y : ℝ) :
    4 * (c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y)
      + 2 * (q11 + q22 + q33) + 6 * c0 = 0 := by
  have hx := h x y
  rw [lap_quadMode, evalAt_quadMode] at hx
  have hW : 0 < 4 * W x y ^ 2 := by
    have := W_pos x y
    positivity
  have hkey : 4 * W x y ^ 2 *
      (4 * (c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y)
        + 2 * (q11 + q22 + q33) + 6 * c0) = 0 := by
    push_cast at hx
    nlinarith [hx]
  rcases mul_eq_zero.mp hkey with h0 | h0
  · exact absurd h0 (ne_of_gt hW)
  · exact h0

/-- **Exactness in degree two.**  A quadratic in the chart coordinates that satisfies the
degree-two Laplace–Beltrami equation has no linear part, has its constant term determined
by the trace, and lies in the span of the five explicit quadrupolar patterns.  Combined
with `degree_two_independent`, the degree-two pattern space inside the quadratic ansatz is
exactly `2·2+1 = 5`-dimensional. -/
theorem degree_two_exact {c0 c1 c2 c3 q11 q22 q33 q12 q13 q23 : ℝ}
    (h : LapBeltrami (quadMode c0 c1 c2 c3 q11 q22 q33 q12 q13 q23) 2) :
    c1 = 0 ∧ c2 = 0 ∧ c3 = 0 ∧ 3 * c0 + (q11 + q22 + q33) = 0 ∧
      ∃ a b c d e : ℝ, ∀ x y : ℝ,
        evalAt (quadMode c0 c1 c2 c3 q11 q22 q33 q12 q13 q23) x y
          = a * evalAt H2xy x y + b * evalAt H2xz x y + c * evalAt H2yz x y
            + d * evalAt H2x2y2 x y + e * evalAt H2z2 x y := by
  have e00 := quadMode_constraint h 0 0
  have e10 := quadMode_constraint h 1 0
  have em10 := quadMode_constraint h (-1) 0
  have e01 := quadMode_constraint h 0 1
  have e0m1 := quadMode_constraint h 0 (-1)
  simp only [evalAt_chartX, evalAt_chartY, evalAt_chartZ, W] at e00 e10 em10 e01 e0m1
  norm_num at e00 e10 em10 e01 e0m1
  have hc1 : c1 = 0 := by linarith
  have hc2 : c2 = 0 := by linarith
  have htr : 2 * (q11 + q22 + q33) + 6 * c0 = 0 := by linarith
  have hc3 : c3 = 0 := by linarith
  refine ⟨hc1, hc2, hc3, by linarith, ?_⟩
  set T := q11 + q22 + q33 with hT
  refine ⟨q12, q13, q23, (q11 - T / 3) + (q33 - T / 3) / 2, (q33 - T / 3) / 2, ?_⟩
  intro x y
  have hsph := chart_on_sphere x y
  rw [evalAt_quadMode, hc1, hc2, hc3]
  simp only [H2xy, H2xz, H2yz, H2x2y2, H2z2, evalAt_sub, evalAt_mul, evalAt_const]
  have hc0 : c0 = -(T / 3) := by rw [hT]; linarith
  rw [hc0]
  linear_combination (T / 3 - (q33 - T / 3) / 2) * hsph


/-! ## Degree three -/

/-- General parity-odd cubic in the chart coordinates.  Degree-three spherical harmonics are
odd under the antipodal map, so this is the natural ansatz in degree three; the even part is
handled by the degree-two analysis. -/
def cubicOddMode (c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123 : ℝ) : NExpr :=
  const c1 * chartX + (const c2 * chartY + (const c3 * chartZ +
    (const t111 * (chartX * (chartX * chartX)) + (const t222 * (chartY * (chartY * chartY)) +
      (const t333 * (chartZ * (chartZ * chartZ)) +
        (const t112 * (chartY * (chartX * chartX)) +
          (const t113 * (chartZ * (chartX * chartX)) +
            (const t122 * (chartX * (chartY * chartY)) +
              (const t223 * (chartZ * (chartY * chartY)) +
                (const t133 * (chartX * (chartZ * chartZ)) +
                  (const t233 * (chartY * (chartZ * chartZ)) +
                    const t123 * (chartX * (chartY * chartZ)))))))))))))

theorem evalAt_cubicOddMode (c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123 x y : ℝ) :
    evalAt (cubicOddMode c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123) x y
      = c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y
        + t111 * evalAt chartX x y ^ 3 + t222 * evalAt chartY x y ^ 3
        + t333 * evalAt chartZ x y ^ 3
        + t112 * (evalAt chartY x y * evalAt chartX x y ^ 2)
        + t113 * (evalAt chartZ x y * evalAt chartX x y ^ 2)
        + t122 * (evalAt chartX x y * evalAt chartY x y ^ 2)
        + t223 * (evalAt chartZ x y * evalAt chartY x y ^ 2)
        + t133 * (evalAt chartX x y * evalAt chartZ x y ^ 2)
        + t233 * (evalAt chartY x y * evalAt chartZ x y ^ 2)
        + t123 * (evalAt chartX x y * (evalAt chartY x y * evalAt chartZ x y)) := by
  simp only [cubicOddMode, evalAt_add, evalAt_mul, evalAt_const]
  ring

theorem lap_cubicOddMode (c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123 x y : ℝ) :
    laplacian (evalAt (cubicOddMode c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123))
        x y
      = 4 * W x y ^ 2 *
          (-2 * (c1 * evalAt chartX x y + c2 * evalAt chartY x y + c3 * evalAt chartZ x y)
            + t111 * (6 * evalAt chartX x y - 12 * evalAt chartX x y ^ 3)
            + t222 * (6 * evalAt chartY x y - 12 * evalAt chartY x y ^ 3)
            + t333 * (6 * evalAt chartZ x y - 12 * evalAt chartZ x y ^ 3)
            + t112 * (2 * evalAt chartY x y - 12 * (evalAt chartY x y * evalAt chartX x y ^ 2))
            + t113 * (2 * evalAt chartZ x y - 12 * (evalAt chartZ x y * evalAt chartX x y ^ 2))
            + t122 * (2 * evalAt chartX x y - 12 * (evalAt chartX x y * evalAt chartY x y ^ 2))
            + t223 * (2 * evalAt chartZ x y - 12 * (evalAt chartZ x y * evalAt chartY x y ^ 2))
            + t133 * (2 * evalAt chartX x y - 12 * (evalAt chartX x y * evalAt chartZ x y ^ 2))
            + t233 * (2 * evalAt chartY x y - 12 * (evalAt chartY x y * evalAt chartZ x y ^ 2))
            + t123 * (-12 * (evalAt chartX x y * (evalAt chartY x y * evalAt chartZ x y)))) := by
  simp only [cubicOddMode, laplacian_add, laplacian_const_mul,
    chartX_isCoord.lap, chartY_isCoord.lap, chartZ_isCoord.lap,
    lap_coord_cube chartX_isCoord, lap_coord_cube chartY_isCoord, lap_coord_cube chartZ_isCoord,
    lap_coord_mul_sq chartY_isCoord chartX_isCoord chartXY_orth.symm,
    lap_coord_mul_sq chartZ_isCoord chartX_isCoord chartXZ_orth.symm,
    lap_coord_mul_sq chartX_isCoord chartY_isCoord chartXY_orth,
    lap_coord_mul_sq chartZ_isCoord chartY_isCoord chartYZ_orth.symm,
    lap_coord_mul_sq chartX_isCoord chartZ_isCoord chartXZ_orth,
    lap_coord_mul_sq chartY_isCoord chartZ_isCoord chartYZ_orth,
    lap_coord_mul_mul chartX_isCoord chartY_isCoord chartZ_isCoord chartXY_orth
      chartXZ_orth chartYZ_orth]
  ring

/-- The three linear constraints imposed by the degree-three eigenvalue equation.  They are
extracted with no computation beyond linear independence of the chart coordinates. -/
theorem cubicOdd_constraints {c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123 : ℝ}
    (h : LapBeltrami (cubicOddMode c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123) 3) :
    10 * c1 + 6 * t111 + 2 * t122 + 2 * t133 = 0 ∧
      10 * c2 + 6 * t222 + 2 * t112 + 2 * t233 = 0 ∧
        10 * c3 + 6 * t333 + 2 * t113 + 2 * t223 = 0 := by
  have hlin : ∀ x y : ℝ,
      (10 * c1 + 6 * t111 + 2 * t122 + 2 * t133) * evalAt chartX x y
        + (10 * c2 + 6 * t222 + 2 * t112 + 2 * t233) * evalAt chartY x y
        + (10 * c3 + 6 * t333 + 2 * t113 + 2 * t223) * evalAt chartZ x y = 0 := by
    intro x y
    have hx := h x y
    rw [lap_cubicOddMode, evalAt_cubicOddMode] at hx
    push_cast at hx
    have hW : (0 : ℝ) < 4 * W x y ^ 2 := by
      have := W_pos x y
      positivity
    have key : 4 * W x y ^ 2 *
        ((10 * c1 + 6 * t111 + 2 * t122 + 2 * t133) * evalAt chartX x y
          + (10 * c2 + 6 * t222 + 2 * t112 + 2 * t233) * evalAt chartY x y
          + (10 * c3 + 6 * t333 + 2 * t113 + 2 * t223) * evalAt chartZ x y) = 0 := by
      linear_combination hx
    rcases mul_eq_zero.mp key with h0 | h0
    · exact absurd h0 (ne_of_gt hW)
    · exact h0
  exact degree_one_independent _ _ _ hlin

/-- **Exactness in degree three.**  A parity-odd cubic in the chart coordinates satisfying
the degree-three Laplace–Beltrami equation lies in the span of the seven explicit octupolar
patterns.  With `degree_three_independent` this makes the degree-three pattern space
exactly `2·3+1 = 7`-dimensional inside the cubic ansatz. -/
theorem degree_three_exact {c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123 : ℝ}
    (h : LapBeltrami (cubicOddMode c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123) 3) :
    ∃ a1 a2 a3 a4 a5 a6 a7 : ℝ, ∀ x y : ℝ,
      evalAt (cubicOddMode c1 c2 c3 t111 t222 t333 t112 t113 t122 t223 t133 t233 t123) x y
        = a1 * evalAt H3a x y + a2 * evalAt H3b x y + a3 * evalAt H3c x y
          + a4 * evalAt H3d x y + a5 * evalAt H3e x y + a6 * evalAt H3f x y
          + a7 * evalAt H3g x y := by
  obtain ⟨k1, k2, k3⟩ := cubicOdd_constraints h
  refine ⟨(t111 - t122) / 4, (t112 - t222) / 4, (t113 - t223) / 2, t123,
    (t133 - (3 * t111 + t122) / 4) / 5, (t233 - (3 * t222 + t112) / 4) / 5,
    (t333 - (t113 + t223) / 2) / 5, ?_⟩
  intro x y
  have hsph := chart_on_sphere x y
  rw [evalAt_cubicOddMode]
  simp only [H3a, H3b, H3c, H3d, H3e, H3f, H3g, evalAt_sub, evalAt_mul, evalAt_const]
  linear_combination
    (((3 * t111 + t122) / 4) * evalAt chartX x y + ((3 * t222 + t112) / 4) * evalAt chartY x y
      + ((t113 + t223) / 2) * evalAt chartZ x y) * hsph
    + (evalAt chartX x y / 10) * k1 + (evalAt chartY x y / 10) * k2
    + (evalAt chartZ x y / 10) * k3

/-- Non-vacuity check: the quadratic ansatz really does contain degree-two eigenfunctions
(here the `xy` quadrupole), so `degree_two_exact` is not vacuous. -/
theorem quadMode_eigen_example : LapBeltrami (quadMode 0 0 0 0 0 0 0 1 0 0) 2 := by
  intro x y
  rw [lap_quadMode, evalAt_quadMode]
  push_cast
  ring

/-- Non-vacuity check: the odd cubic ansatz contains the sectoral octupole, so
`degree_three_exact` is not vacuous. -/
theorem cubicOddMode_eigen_example :
    LapBeltrami (cubicOddMode 0 0 0 1 0 0 0 0 (-3) 0 0 0 0) 3 := by
  intro x y
  rw [lap_cubicOddMode, evalAt_cubicOddMode]
  push_cast
  ring

/-- Non-vacuity check in degree one. -/
theorem affineMode_eigen_example : LapBeltrami (affineMode 0 1 0 0) 1 :=
  (degree_one_exact 0 1 0 0).mpr rfl

end

end StereoNeuralField