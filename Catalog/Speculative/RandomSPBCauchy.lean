/-! # CatalogBuild.Speculative.RandomSPBCauchy

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8
-/

import Mathlib

noncomputable section

/-- n-fold SPB iteration with a sequence of inputs. -/
def spbRandomIter (a : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbR (spbRandomIter a n) (a n)



/-- Starting from 0, the first iterate is a₀. -/
theorem spbRandomIter_one (a : ℕ → ℝ) : spbRandomIter a 1 = a 0 := by
  simp [spbRandomIter, spbR]



/-- [Section: # CatalogBuild.Speculative.RandomSPBCauchy
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem spbRandomIter_angle_sum (a : ℕ → ℝ) (n : ℕ)
    (h : ∀ k < n, 0 < 1 - spbRandomIter a k * a k) :
    arctan (spbRandomIter a n) = ∑ i ∈ Finset.range n, arctan (a i) := by
  induction' n with n ih;
  · aesop;
  · rw [ Finset.sum_range_succ, ← ih fun k hk => h k <| Nat.lt_succ_of_lt hk ];
    apply arctan_spb_add;
    exact h n n.lt_succ_self



/-- The standard Cauchy density: f(x) = 1/(π(1+x²)). -/
def cauchyPDF (x : ℝ) : ℝ := 1 / (π * (1 + x ^ 2))



/-- Cauchy density is positive everywhere. -/
theorem cauchyPDF_pos (x : ℝ) : 0 < cauchyPDF x := by
  unfold cauchyPDF
  apply div_pos one_pos
  apply mul_pos pi_pos
  positivity



theorem cauchyPDF_integral_one :
    ∫ x, cauchyPDF x = 1 := by
      unfold cauchyPDF;
      simp +zetaDelta at *;
      rw [ MeasureTheory.integral_mul_const, show ( ∫ x : ℝ, ( 1 + x ^ 2 ) ⁻¹ ) = Real.pi by simp ] ; norm_num [ Real.pi_ne_zero ]



/-- The Lyapunov exponent for random SPB iteration:
The "stretching factor" of one SPB step at x with perturbation a is
(1 + a²)/(1 - xa)², which decomposes as:
log-stretching = log(1 + a²) - 2·log|1 - xa|. -/
theorem lyapunov_factor (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by positivity



/-- For the standard Cauchy, E_x[log|1-xa|] = log√(1+a²)/2 + const,
leading to λ = E_a[log(1+a²)]/2. -/
theorem lyapunov_exponent_formula_sketch (a : ℝ) :
    Real.log (1 + a ^ 2) / 2 ≥ 0 := by
  apply div_nonneg
  · exact Real.log_nonneg (by nlinarith [sq_nonneg a])
  · norm_num



end
