/-! # CatalogBuild.EML.V6Theorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 45
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def eml6 (x y : ℝ) : ℝ := Real.exp x - Real.log y



/-- The diagonal map: d(z) = exp(z) - ln(z). -/
def diag6 (z : ℝ) : ℝ := Real.exp z - Real.log z



/-- The semigroup action T_c(x) = eml(x, c) = exp(x) - ln(c). -/
def semiT (c : ℝ) (x : ℝ) : ℝ := Real.exp x - Real.log c



/-- The 2D EML map Φ(x,y) = (eml(x,y), eml(y,x)). -/
def phi2D (p : ℝ × ℝ) : ℝ × ℝ :=
  (eml6 p.1 p.2, eml6 p.2 p.1)



/-- The sigmoid function σ(x) = 1/(1 + exp(-x)). -/
def eml_sigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))



/-- The e-tower: e↑↑n (iterated exponential). -/
def eTow6 : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (eTow6 n)



/-- The first derivative of the diagonal map is exp(x) - 1/x. -/
theorem diag6_deriv (x : ℝ) (hx : 0 < x) :
    HasDerivAt diag6 (Real.exp x - x⁻¹) x := by
  unfold diag6
  exact (Real.hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')



/-- The second derivative of the diagonal map is exp(x) + 1/x². -/
theorem diag6_second_deriv_pos (x : ℝ) (hx : 0 < x) :
    Real.exp x + x⁻¹ ^ 2 > 0 := by
  positivity



/-- [Section: # CatalogBuild.EML.V6Theorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 45] -/
theorem diag6_convex_on : ConvexOn ℝ (Ioi 0) diag6 := by
  apply_rules [ StrictConvexOn.convexOn ];
  apply strictConvexOn_of_deriv2_pos ( convex_Ioi 0 );
  · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( Real.continuousOn_log.mono fun x hx => ne_of_gt hx );
  · -- The second derivative of the diagonal map is exp(x) + 1/x².
    have h_second_deriv : ∀ x > 0, deriv^[2] diag6 x = Real.exp x + 1 / x^2 := by
      have h_deriv2 : ∀ x > 0, deriv (deriv diag6) x = deriv (fun x => Real.exp x - 1 / x) x := by
        exact fun x x_pos => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds x_pos ] with y hy using by simpa using HasDerivAt.deriv ( diag6_deriv y hy ) );
      exact fun x hx => by simpa [ hx.ne', Real.differentiableAt_exp, differentiableAt_inv ] using h_deriv2 x hx;
    exact fun x hx => h_second_deriv x ( interior_subset hx ) ▸ add_pos_of_pos_of_nonneg ( Real.exp_pos x ) ( by positivity )



theorem diag6_critical_point (x : ℝ) (hx : 0 < x)
    (hcrit : Real.exp x - x⁻¹ = 0) :
    x * Real.exp x = 1 := by
  nlinarith [ mul_inv_cancel₀ hx.ne' ]



theorem diag6_ge_two (x : ℝ) (hx : 0 < x) : diag6 x ≥ 2 := by
  unfold diag6;
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]



theorem diag6_no_fixed_points (x : ℝ) (hx : 0 < x) : diag6 x ≠ x := by
  by_contra h_contra;
  -- We'll use that $e^x \geq 1 + x + \frac{x^2}{2}$ for all $x \geq 0$.
  have h_exp_bound : ∀ x : ℝ, 0 ≤ x → Real.exp x ≥ 1 + x + x^2 / 2 := by
    exact?;
  unfold diag6 at h_contra;
  nlinarith [ h_exp_bound x hx.le, Real.log_le_sub_one_of_pos hx ]



/-- The Jacobian determinant formula for the 2D EML map. -/
theorem phi2D_jacobian_det (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Real.exp x * Real.exp y - (x * y)⁻¹ =
    Real.exp (x + y) - (x * y)⁻¹ := by
  rw [Real.exp_add]



theorem phi2D_jacobian_pos (x y : ℝ) (hx : 1 < x) (hy : 1 < y) :
    Real.exp (x + y) - (x * y)⁻¹ > 0 := by
  field_simp;
  nlinarith [ mul_pos ( sub_pos.mpr hx ) ( sub_pos.mpr hy ), Real.add_one_le_exp ( x + y ) ]



theorem phi2D_no_symmetric_fixed (x : ℝ) (hx : 0 < x) :
    phi2D (x, x) ≠ (x, x) := by
  exact fun h => diag6_no_fixed_points x hx <| by injection h;



/-- T_1(x) = exp(x) (the exponential map). -/
theorem semiT_one (x : ℝ) : semiT 1 x = Real.exp x := by
  simp [semiT, Real.log_one]



theorem semiT_strictMono (c : ℝ) : StrictMono (semiT c) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.2 hxy ) _



theorem semiT_one_no_fixed (x : ℝ) : semiT 1 x > x := by
  unfold semiT;
  norm_num;
  linarith [ Real.add_one_le_exp x ]



theorem semiT_noncomm : ∃ c₁ c₂ x : ℝ,
    semiT c₁ (semiT c₂ x) ≠ semiT c₂ (semiT c₁ x) := by
  use 1, Real.exp 1, 0;
  unfold semiT; norm_num;
  exact ne_of_lt ( by have := Real.exp_one_gt_d9.le; norm_num1 at *; linarith )



theorem semiT_no_idempotent (c : ℝ) (hc : 0 < c) :
    ∃ x : ℝ, semiT c (semiT c x) ≠ semiT c x := by
  by_cases h : c = Real.exp 1 <;> simp_all +decide [ sub_eq_iff_eq_add ];
  · unfold semiT; norm_num [ Real.exp_ne_zero, Real.exp_neg, Real.exp_add, Real.exp_log ] ; ring_nf;
    exact ⟨ 1, by linarith [ Real.add_one_lt_exp one_ne_zero ] ⟩;
  · contrapose! h;
    have := h 0; have := h 1; unfold semiT at *; norm_num at *;
    rw [ ← Real.exp_log hc, show Real.log c = 1 by linarith ]



theorem eml6_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml6 x (y * z) = eml6 x y - Real.log z := by
  unfold eml6; rw [ Real.log_mul hy.ne' hz.ne' ] ; ring;



theorem eml6_strictMono_fst (y : ℝ) : StrictMono (fun x => eml6 x y) := by
  exact fun x y hxy => sub_lt_sub_right ( Real.exp_lt_exp.2 hxy ) _



theorem eml6_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => eml6 x y) (Ioi 0) := by
  exact fun y hy z hz hyz => sub_lt_sub_left ( Real.log_lt_log hy hyz ) _



/-- The trace identity: eml(x,y) + eml(y,x) = exp(x) + exp(y) - ln(x) - ln(y). -/
theorem eml6_trace (x y : ℝ) :
    eml6 x y + eml6 y x = Real.exp x + Real.exp y - Real.log x - Real.log y := by
  unfold eml6; ring



/-- The anti-symmetry of the difference:
eml(x,y) - eml(y,x) = (exp(x) - exp(y)) + (ln(x) - ln(y)). -/
theorem eml6_antisym_diff (x y : ℝ) :
    eml6 x y - eml6 y x = (Real.exp x - Real.exp y) + (Real.log x - Real.log y) := by
  unfold eml6; ring



theorem eml6_hasDerivAt_fst (x y : ℝ) :
    HasDerivAt (fun x' => eml6 x' y) (Real.exp x) x := by
  convert HasDerivAt.sub ( Real.hasDerivAt_exp x ) ( hasDerivAt_const _ _ ) using 1;
  ring



theorem eml6_hasDerivAt_snd (x y : ℝ) (hy : 0 < y) :
    HasDerivAt (fun y' => eml6 x y') (-y⁻¹) y := by
  convert HasDerivAt.sub ( hasDerivAt_const _ _ ) ( Real.hasDerivAt_log ?_ ) using 1 <;> ring ; aesop



theorem eml_sigmoid_pos (x : ℝ) : 0 < eml_sigmoid x := by
  exact one_div_pos.mpr ( by positivity )



theorem eml_sigmoid_lt_one (x : ℝ) : eml_sigmoid x < 1 := by
  exact div_lt_one ( by positivity ) |>.2 ( by linarith [ Real.exp_pos ( -x ) ] )



/-- σ(0) = 1/2. -/
theorem eml_sigmoid_zero : eml_sigmoid 0 = 1 / 2 := by
  simp [eml_sigmoid]; ring



theorem depth_hierarchy_2_gt_1 :
    ¬ ∃ a b : ℝ, ∀ x : ℝ, Real.exp (Real.exp x) = Real.exp (a * x + b) := by
  norm_num [ Real.exp_ne_zero ];
  intro a b; by_contra! h; have := h 0; have := h 1; have := h ( -1 ) ; norm_num at *;
  linarith [ Real.add_one_le_exp 1, Real.exp_pos ( -1 ) ]



/-- The e-tower is always positive. -/
theorem eTow6_pos (n : ℕ) : 0 < eTow6 n := by
  induction n with
  | zero => simp [eTow6]
  | succ n _ => exact Real.exp_pos _



/-- The e-tower is strictly increasing. -/
theorem eTow6_strictMono : StrictMono eTow6 := by
  apply strictMono_nat_of_lt_succ
  intro n; simp only [eTow6]
  linarith [Real.add_one_le_exp (eTow6 n)]



theorem eTow6_ge_exp_n (n : ℕ) : eTow6 n ≥ Real.exp 1 ^ n := by
  induction n <;> simp_all +decide [ pow_succ' ];
  · exact le_rfl;
  · rw [ ← Real.exp_add ];
    rename_i n hn;
    exact Real.exp_le_exp.mpr ( by linarith [ Real.add_one_le_exp n ] )



theorem eTow6_unbounded : ∀ M : ℝ, ∃ n : ℕ, eTow6 n > M := by
  intro M;
  -- By induction, we show that $eTow6 n ≥ n + 1$ for all $n$.
  have h_lower_bound : ∀ n : ℕ, eTow6 n ≥ n + 1 := by
    intro n; induction' n with n ih <;> norm_num [ *, eTow6 ] at *;
    linarith [ Real.add_one_le_exp ( eTow6 n ) ];
  exact ⟨ ⌊M⌋₊, by linarith [ Nat.lt_floor_add_one M, h_lower_bound ⌊M⌋₊ ] ⟩



/-- exp(x) = eml(x, 1). -/
theorem eml6_recovers_exp (x : ℝ) : eml6 x 1 = Real.exp x := by
  simp [eml6, Real.log_one]



/-- The subtraction identity: eml(ln(a), exp(b)) = a - b for a > 0. -/
theorem eml6_subtraction (a b : ℝ) (ha : 0 < a) :
    eml6 (Real.log a) (Real.exp b) = a - b := by
  unfold eml6; rw [Real.exp_log ha, Real.log_exp]



/-- The addition identity: eml(ln(a), exp(-b)) = a + b for a > 0. -/
theorem eml6_addition (a b : ℝ) (ha : 0 < a) :
    eml6 (Real.log a) (Real.exp (-b)) = a + b := by
  unfold eml6; rw [Real.exp_log ha, Real.log_exp]; ring



/-- eml(1, e^e) = 0 — zero generation at depth 3. -/
theorem eml6_zero : eml6 1 (Real.exp (Real.exp 1)) = 0 := by
  simp [eml6, Real.log_exp]



/-- The double negation identity: eml(0, exp(eml(0, exp(x)))) = x. -/
theorem eml6_double_neg (x : ℝ) : eml6 0 (Real.exp (eml6 0 (Real.exp x))) = x := by
  unfold eml6; simp [Real.log_exp]



theorem eml6_one_one_irrational : Irrational (eml6 1 1) := by
  -- By definition of $eml6$, we have $eml6 1 1 = exp 1 - ln 1$.
  simp [eml6];
  by_contra h_contra
  obtain ⟨p, q, hq_pos, hpq_eq⟩ : ∃ p q : ℕ, q > 0 ∧ Real.exp 1 = p / q := by
    obtain ⟨ p, hp ⟩ := Classical.not_not.1 h_contra;
    exact ⟨ p.num.natAbs, p.den, Nat.cast_pos.mpr p.pos, by simpa [ abs_of_nonneg ( Rat.num_nonneg.mpr ( show 0 ≤ p by exact_mod_cast hp.symm ▸ Real.exp_nonneg _ ) ), Rat.cast_def ] using hp.symm ⟩
  generalize_proofs at *;
  -- Consider the series expansion of $e$: $e = \sum_{n=0}^{\infty} \frac{1}{n!}$.
  have h_series : Real.exp 1 = ∑' n : ℕ, (1 : ℝ) / Nat.factorial n := by
    simp +decide [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ];
  -- Multiply both sides of the equation by $q!$ to get $q! \cdot e = \sum_{n=0}^{q} \frac{q!}{n!} + \sum_{n=q+1}^{\infty} \frac{q!}{n!}$.
  have h_mul : (Nat.factorial q : ℝ) * Real.exp 1 = ∑ n ∈ Finset.range (q + 1), (Nat.factorial q : ℝ) / Nat.factorial n + ∑' n : ℕ, (Nat.factorial q : ℝ) / Nat.factorial (n + q + 1) := by
    rw [ h_series, ← Summable.sum_add_tsum_nat_add ];
    rw [ mul_add, Finset.mul_sum _ _ _, ← tsum_mul_left ] ; congr ; ext n ; ring;
    · exact funext fun n => by ring;
    · simpa using Real.summable_pow_div_factorial 1;
  -- The first sum is an integer, and the second sum is strictly between 0 and 1.
  have h_bounds : 0 < ∑' n : ℕ, (Nat.factorial q : ℝ) / Nat.factorial (n + q + 1) ∧ ∑' n : ℕ, (Nat.factorial q : ℝ) / Nat.factorial (n + q + 1) < 1 := by
    -- The series $\sum_{n=q+1}^{\infty} \frac{q!}{n!}$ is a geometric series with the first term $\frac{q!}{(q+1)!} = \frac{1}{q+1}$ and common ratio $\frac{1}{q+2}$.
    have h_geo_series : ∑' n : ℕ, (Nat.factorial q : ℝ) / Nat.factorial (n + q + 1) ≤ ∑' n : ℕ, (1 : ℝ) / (q + 1) * (1 / (q + 2)) ^ n := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ mul_comm ] ; induction i <;> simp_all +decide [ Nat.factorial, pow_succ' ];
        norm_num [ Nat.succ_add, Nat.factorial_succ ] at *;
        field_simp at *;
        nlinarith [ ( by positivity : 0 < ( q + 1 : ℝ ) * q.factorial * ( q + 2 ) ^ ‹_› ) ];
      · exact Summable.mul_left _ <| by simpa using summable_nat_add_iff ( q + 1 ) |>.2 <| Real.summable_pow_div_factorial 1;
      · exact Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity ) <| by rw [ div_lt_iff₀ ] <;> linarith;
    refine' ⟨ _, lt_of_le_of_lt h_geo_series _ ⟩;
    · refine' Summable.tsum_pos ..;
      exacts [ Summable.mul_left _ <| by simpa using summable_nat_add_iff ( q + 1 ) |>.2 <| Real.summable_pow_div_factorial 1, fun _ => by positivity, 0, by positivity ];
    · rw [ tsum_mul_left, tsum_geometric_of_lt_one ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> linarith ) ];
      field_simp;
      rw [ div_lt_iff₀ ] <;> nlinarith only [ show ( q : ℝ ) ≥ 1 by norm_cast ];
  -- Since $q! \cdot e$ is an integer, the second sum must also be an integer.
  have h_second_sum_int : ∃ m : ℤ, ∑' n : ℕ, (Nat.factorial q : ℝ) / Nat.factorial (n + q + 1) = m := by
    have h_second_sum_int : ∃ m : ℤ, (Nat.factorial q : ℝ) * Real.exp 1 = m := by
      use p * Nat.factorial q / q;
      rw [ Int.cast_div ] <;> norm_num [ hpq_eq, mul_comm, hq_pos.ne' ];
      · ring;
      · exact dvd_mul_of_dvd_right ( mod_cast Nat.dvd_factorial ( by positivity ) ( by linarith ) ) _;
    obtain ⟨ m, hm ⟩ := h_second_sum_int; use m - ∑ n ∈ Finset.range ( q + 1 ), ( q.factorial : ℤ ) / n.factorial; push_cast; rw [ ← hm, h_mul ] ; ring;
    rw [ Finset.sum_congr rfl fun i hi => Int.cast_div ( by exact_mod_cast Nat.factorial_dvd_factorial <| by linarith [ Finset.mem_range.mp hi ] ) ( by positivity ) ] ; norm_num [ add_comm, add_left_comm, add_assoc ];
    ring!;
  obtain ⟨ m, hm ⟩ := h_second_sum_int; rcases m with ⟨ _ | _ | m ⟩ <;> norm_num at hm <;> linarith;



theorem eml6_double_tower_gt_four : eml6 (eml6 1 1) 1 > 4 := by
  -- We'll use that $e^e > 4$ to conclude the proof.
  have h_exp_exp : Real.exp (Real.exp 1) > 4 := by
    have := Real.exp_one_gt_d9.le;
    norm_num1 at *; rw [ show Real.exp ( Real.exp 1 ) = Real.exp 1 * Real.exp ( Real.exp 1 - 1 ) by rw [ ← Real.exp_add ] ; ring ] ; nlinarith [ Real.add_one_le_exp ( Real.exp 1 - 1 ) ] ;
  unfold eml6; aesop



/-- Composing eml with itself on the diagonal:
eml(eml(x,x), eml(x,x)) = exp(exp(x) - ln(x)) - ln(exp(x) - ln(x)). -/
theorem eml6_diag_compose (x : ℝ) :
    eml6 (diag6 x) (diag6 x) = diag6 (diag6 x) := by
  unfold eml6 diag6; ring



/-- The e-tower via iterated eml: eml(eml(1,1), 1) = e^e. -/
theorem eml6_ee : eml6 (eml6 1 1) 1 = Real.exp (Real.exp 1) := by
  simp [eml6, Real.log_one]



/-- The triple tower: eml(eml(eml(1,1),1), 1) = e^(e^e). -/
theorem eml6_eee : eml6 (eml6 (eml6 1 1) 1) 1 = Real.exp (Real.exp (Real.exp 1)) := by
  simp [eml6, Real.log_one]



end
