/-! # CatalogBuild.Speculative.Other.SciFiMathematics

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11
-/

import Mathlib

theorem koch_dimension_equation :
    Real.log 4 = (Real.log 4 / Real.log 3) * Real.log 3 := by
  rw [ div_mul_cancel₀ _ ( by positivity ) ]


theorem log_three_pos : (0 : ℝ) < Real.log 3 := by
  positivity


theorem log_four_pos : (0 : ℝ) < Real.log 4 := by
  positivity


theorem koch_dimension_irrational : Irrational (Real.log 4 / Real.log 3) := by
  -- Assume for contradiction that $\frac{\log 4}{\log 3}$ is rational. Then there exist positive integers $p$ and $q$ such that $\frac{\log 4}{\log 3} = \frac{p}{q}$.
  by_contra h_contra
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, p > 0 ∧ q > 0 ∧ (Real.log 4 / Real.log 3) = p / q := by
    -- By definition of irrationality, if $\frac{\log 4}{\log 3}$ is not irrational, then it must be rational.
    obtain ⟨r, hr⟩ : ∃ r : ℚ, (Real.log 4) / (Real.log 3) = r := by
      simpa [ eq_comm ] using Classical.not_not.1 h_contra;
    use r.num.natAbs, r.den;
    norm_num +zetaDelta at *;
    exact ⟨ by rintro rfl; norm_num at hr, r.pos, by rw [ hr, abs_of_nonneg ( mod_cast Rat.num_nonneg.mpr ( show 0 ≤ r by exact_mod_cast hr ▸ div_nonneg ( Real.log_nonneg ( by norm_num ) ) ( Real.log_nonneg ( by norm_num ) ) ) ), Rat.cast_def ] ⟩;
  -- Then we have $4^q = 3^p$.
  have h_exp : (4 : ℝ) ^ q = 3 ^ p := by
    rw [ div_eq_div_iff ] at hpq <;> norm_num at *;
    · rw [ ← Real.rpow_natCast, ← Real.rpow_natCast, Real.rpow_def_of_pos, Real.rpow_def_of_pos ] <;> norm_num ; linarith;
    · linarith;
  exact absurd h_exp ( mod_cast ne_of_apply_ne ( · % 2 ) ( by norm_num [ Nat.pow_mod, hpq.1.ne', hpq.2.1.ne' ] ) )


theorem hyperbolic_area_lower_bound (r : ℝ) (hr : 0 ≤ r) :
    Real.cosh r - 1 ≥ r ^ 2 / 2 := by
  -- Use the Taylor series expansion of cosh r, which is 1 + r^2 / 2! + r^4 / 4! + ...
  have h_cosh_expansion : ∀ r : ℝ, Real.cosh r = ∑' n, (r^(2*n)) / (Nat.factorial (2*n)) := by
    exact?;
  rw [ h_cosh_expansion r, Summable.tsum_eq_zero_add ] <;> norm_num;
  · refine' le_trans _ ( Summable.le_tsum _ 0 fun n _ => by positivity ) ; norm_num [ pow_mul ];
    exact Real.summable_pow_div_factorial _ |> Summable.comp_injective <| by aesop_cat;
  · exact Real.summable_pow_div_factorial _ |> Summable.comp_injective <| by aesop_cat;


theorem cosh_ge_one (r : ℝ) : Real.cosh r ≥ 1 := by
  exact Real.one_le_cosh r


theorem marchenko_pastur_edge (σ γ : ℝ) (hσ : 0 < σ) (hγ : 0 < γ) :
    σ ^ 2 * (1 + Real.sqrt γ) ^ 2 = σ ^ 2 * (1 + γ + 2 * Real.sqrt γ) := by
  grind


theorem det_mul_transpose_sq {n : Type*} [DecidableEq n] [Fintype n]
    (A : Matrix n n ℝ) : (A * A.transpose).det = A.det ^ 2 := by
  rw [ sq, Matrix.det_mul, Matrix.det_transpose ]


theorem koch_self_similarities (n : ℕ) :
    4 ^ n = (4 : ℕ) ^ n := by
  grind


theorem koch_piece_length (n : ℕ) :
    (1 : ℝ) / 3 ^ n = (1 / 3 : ℝ) ^ n := by
  norm_num +zetaDelta at *;
  rw [ one_div, inv_pow ]


theorem koch_length_diverges :
    Filter.Tendsto (fun n : ℕ => ((4 : ℝ) / 3) ^ n) Filter.atTop Filter.atTop := by
  exact tendsto_pow_atTop_atTop_of_one_lt ( by norm_num )
