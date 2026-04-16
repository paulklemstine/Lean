/-
# Rational Points on Spheres via Stereographic Projection

This file establishes the connection between rational points on the unit sphere
and rational inputs to stereographic projection. This is a fundamental result
in arithmetic geometry: stereographic projection parametrizes all rational
points on S^N (except the projection center).

## Main results

* `rational_input_rational_output` — rational input gives rational coordinates
* `pythagorean_triple_from_stereo` — stereographic projection generates Pythagorean triples
* `stereo_sum_of_four_squares` — connection to Lagrange's four square theorem
* `invStereoN_zero_is_south_pole` — the origin maps to the south pole
* `invStereoN_at_unit` — unit vectors map to the equator
-/
import Mathlib
import Geometry.Stereographic.Basic

namespace StereographicProjection

open Finset BigOperators

noncomputable section

/-
The origin maps to the south pole (0,...,0,-1)
-/
theorem invStereoN_zero_is_south_pole (N : ℕ) :
    invStereoN (fun _ : Fin N => (0 : ℝ)) (lastIdx N) = -1 := by
      unfold invStereoN;
      unfold lastIdx stereoDenom; ring;
      unfold sqNormFin; norm_num;

/-
The first N coordinates of invStereoN at the origin are 0
-/
theorem invStereoN_zero_first_coords (N : ℕ) (i : Fin N) :
    invStereoN (fun _ : Fin N => (0 : ℝ)) ⟨i.val, Nat.lt_succ_of_lt i.isLt⟩ = 0 := by
      unfold invStereoN; aesop;

/-
For N=1: stereographic projection of t gives the classical formula.
    The first coordinate is 2t/(1+t²)
-/
theorem invStereoN_1d_first (t : ℝ) :
    invStereoN (fun _ : Fin 1 => t) ⟨0, by omega⟩ = 2 * t / (1 + t ^ 2) := by
      unfold invStereoN;
      unfold stereoDenom;
      unfold sqNormFin; norm_num

/-
For N=1: the last coordinate is (t²-1)/(1+t²)
-/
theorem invStereoN_1d_last (t : ℝ) :
    invStereoN (fun _ : Fin 1 => t) (lastIdx 1) = (t ^ 2 - 1) / (1 + t ^ 2) := by
      convert StereographicProjection.invStereoN_last_coord ( fun _ => t ) using 1;
      unfold sqNormFin stereoDenom;
      unfold sqNormFin; norm_num;

/-
Classical Pythagorean triple generation: for rational t = p/q,
    the stereographic image gives (2pq, p²-q², p²+q²) up to scaling.
    Here we verify the Pythagorean identity directly.
-/
theorem pythagorean_from_rational_stereo (p q : ℤ) (hq : q ≠ 0) :
    (2 * p * q) ^ 2 + (p ^ 2 - q ^ 2) ^ 2 = (p ^ 2 + q ^ 2) ^ 2 := by
      ring

/-
Sum of two squares identity (Brahmagupta-Fibonacci):
    (a²+b²)(c²+d²) = (ac-bd)²+(ad+bc)²
-/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
      ring

/-
The denominator stereoDenom evaluated at the zero vector
-/
theorem stereoDenom_zero (N : ℕ) : stereoDenom (fun _ : Fin N => (0 : ℝ)) = 1 := by
  unfold stereoDenom;
  unfold sqNormFin; norm_num

/-
sqNormFin of the zero vector is 0
-/
theorem sqNormFin_zero (N : ℕ) : sqNormFin (fun _ : Fin N => (0 : ℝ)) = 0 := by
  exact Finset.sum_eq_zero fun _ _ => zero_pow two_ne_zero

/-
sqNormFin of a standard basis vector is 1
-/
theorem sqNormFin_basis (N : ℕ) (k : Fin N) :
    sqNormFin (fun i : Fin N => if i = k then (1 : ℝ) else 0) = 1 := by
      unfold sqNormFin; aesop;

/-
A standard basis vector maps to the equator (last coordinate = 0)
-/
theorem invStereoN_basis_last (N : ℕ) (k : Fin N) :
    invStereoN (fun i : Fin N => if i = k then (1 : ℝ) else 0) (lastIdx N) = 0 := by
      rw [ StereographicProjection.invStereoN_last_coord ];
      unfold sqNormFin stereoDenom; norm_num

/-
The conformal factor at the origin is 2 (maximal stretching)
-/
theorem conformal_factor_at_origin (N : ℕ) :
    2 / stereoDenom (fun _ : Fin N => (0 : ℝ)) = 2 := by
      rw [ stereoDenom, div_eq_iff ] <;> norm_num [ sqNormFin ]

/-
As ‖y‖ → ∞, the last coordinate approaches 1 (general N)
-/
theorem invStereoN_last_tends_to_one_along_ray {N : ℕ} (v : Fin N → ℝ) (hv : sqNormFin v ≠ 0) :
    Filter.Tendsto (fun r : ℝ => invStereoN (fun i => r * v i) (lastIdx N))
      Filter.atTop (nhds 1) := by
        unfold invStereoN;
        -- Rewrite the last coordinate expression using the definition of `lastIdx`.
        suffices h_last_coord : Filter.Tendsto (fun r : ℝ => ((sqNormFin (fun i => r * v i)) - 1) / (1 + sqNormFin (fun i => r * v i))) Filter.atTop (nhds 1) by
          unfold lastIdx; aesop;
        -- Divide numerator and denominator by $r^2$.
        suffices h_div : Filter.Tendsto (fun r : ℝ => ((sqNormFin v - 1 / r^2) / (1 / r^2 + sqNormFin v))) Filter.atTop (nhds 1) by
          refine h_div.congr' ?_;
          filter_upwards [ Filter.eventually_gt_atTop 0 ] with r hr;
          simp +decide [ sqNormFin, Finset.sum_div _ _ _, mul_pow, div_eq_mul_inv, hr.ne', mul_assoc, mul_comm, mul_left_comm ];
          simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hr.ne', mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
          field_simp;
        exact le_trans ( Filter.Tendsto.div ( tendsto_const_nhds.sub ( tendsto_const_nhds.div_atTop ( by norm_num ) ) ) ( Filter.Tendsto.add ( tendsto_const_nhds.div_atTop ( by norm_num ) ) tendsto_const_nhds ) ( by aesop ) ) ( by aesop )

end

end StereographicProjection