/-
# OISCC V11: EML Metric Space Geometry

The derived metric d(x,y) = |f(x) - f(y)| where f(x) = exp(x) - ln(x) - 1
defines a pseudo-metric on ℝ₊.
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

def f_met (x : ℝ) : ℝ := Real.exp x - Real.log x - 1

def d_met (x y : ℝ) : ℝ := |f_met x - f_met y|

theorem d_met_symm (x y : ℝ) : d_met x y = d_met y x := by
  simp [d_met, abs_sub_comm]

theorem d_met_self (x : ℝ) : d_met x x = 0 := by simp [d_met]

theorem d_met_triangle (x y z : ℝ) :
    d_met x z ≤ d_met x y + d_met y z := by
  simp only [d_met]
  calc |f_met x - f_met z|
      = |(f_met x - f_met y) + (f_met y - f_met z)| := by ring_nf
    _ ≤ |f_met x - f_met y| + |f_met y - f_met z| := abs_add_le _ _

theorem d_met_nonneg (x y : ℝ) : 0 ≤ d_met x y := abs_nonneg _

theorem d_met_eq_zero_iff (x y : ℝ) :
    d_met x y = 0 ↔ f_met x = f_met y := by
  simp [d_met, abs_eq_zero, sub_eq_zero]

theorem f_met_pos (x : ℝ) (hx : 0 < x) : f_met x > 0 := by
  unfold f_met
  nlinarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]

theorem f_met_ge_one (x : ℝ) (hx : 0 < x) : f_met x ≥ 1 := by
  unfold f_met
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]

theorem f_met_tendsto_atTop :
    Filter.Tendsto f_met atTop atTop := by
  refine' Filter.tendsto_atTop.mpr _;
  intro b
  unfold f_met;
  -- We'll use the fact that $e^x$ grows faster than any polynomial function.
  have h_exp_growth : Filter.Tendsto (fun x : ℝ => Real.exp x / x) Filter.atTop Filter.atTop := by
    simpa using Real.tendsto_exp_div_pow_atTop 1;
  filter_upwards [ h_exp_growth.eventually_gt_atTop ( |b| + 2 ), Filter.eventually_gt_atTop ( |b| + 2 ) ] with x hx₁ hx₂ using by cases abs_cases b <;> nlinarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos ( by linarith : 0 < x ), mul_div_cancel₀ ( Real.exp x ) ( by linarith : x ≠ 0 ) ] ;

theorem d_met_unbounded : ∀ M : ℝ, ∃ x y : ℝ, 0 < x ∧ 0 < y ∧ d_met x y > M := by
  intro M
  obtain ⟨x, hx⟩ : ∃ x : ℝ, 0 < x ∧ f_met x > (abs M) + f_met 1 + 1 := by
    have h_tendsto : Filter.Tendsto f_met atTop atTop := by
      exact?;
    exact Filter.Eventually.and ( Filter.eventually_gt_atTop 0 ) ( h_tendsto.eventually_gt_atTop _ ) |> fun h => h.exists;
  exact ⟨ x, 1, hx.1, by norm_num, by rw [ d_met ] ; rw [ abs_of_nonneg ] <;> cases abs_cases M <;> linarith ⟩

theorem f_met_strictMono_Ici : StrictMonoOn f_met (Ici 1) := by
  -- Let $x, y \in [1, \infty)$ with $x < y$. We need to show that $f_met(x) < f_met(y)$.
  intros x hx y hy hxy
  have h_deriv_pos : ∀ x : ℝ, 1 ≤ x → 0 < deriv f_met x := by
    intro x hx;
    unfold f_met; norm_num [ Real.differentiableAt_exp, ne_of_gt ( zero_lt_one.trans_le hx ) ] ; ring_nf; nlinarith [ Real.add_one_le_exp x, mul_inv_cancel₀ ( ne_of_gt ( zero_lt_one.trans_le hx ) ) ] ;
  -- Apply the mean value theorem to the interval $[x, y]$.
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Ioo x y, deriv f_met c = (f_met y - f_met x) / (y - x) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun z hz => by exact DifferentiableAt.continuousAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos z ( by linarith [ hx.out, hy.out, hz.1 ] ) ) ) ) ;
    · exact fun z hz => DifferentiableAt.differentiableWithinAt ( by exact differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_deriv_pos z ( by linarith [ hz.1, hx.out ] ) ) ) );
  have := h_deriv_pos c ( le_trans hx.out hc.1.1.le ) ; rw [ hc.2, lt_div_iff₀ ] at this <;> linarith;

theorem d_met_definite_on_Ici (x y : ℝ) (hx : 1 ≤ x) (hy : 1 ≤ y) :
    d_met x y = 0 ↔ x = y := by
  rw [d_met_eq_zero_iff]
  constructor
  · intro h; exact f_met_strictMono_Ici.injOn (mem_Ici.mpr hx) (mem_Ici.mpr hy) h
  · intro h; rw [h]

theorem f_met_one : f_met 1 = Real.exp 1 - 1 := by simp [f_met, Real.log_one]

def D_met (x y : ℝ) : ℝ := f_met x + f_met y

theorem D_ge_d (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    D_met x y ≥ d_met x y := by
  unfold D_met d_met;
  exact abs_le.mpr ⟨ by linarith [ f_met_pos x hx, f_met_pos y hy ], by linarith [ f_met_pos x hx, f_met_pos y hy ] ⟩

theorem D_decomposition (x y : ℝ) :
    D_met x y = d_met x y + 2 * min (f_met x) (f_met y) := by
  unfold D_met d_met
  by_cases h : f_met x ≤ f_met y
  · rw [min_eq_left h, abs_of_nonpos (sub_nonpos.mpr h)]; ring
  · push_neg at h
    rw [min_eq_right (le_of_lt h), abs_of_pos (sub_pos.mpr h)]; ring

end