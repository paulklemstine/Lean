import Bridges.FutureTheorems
import MachineLearning.ShefferFunction.Lean.ShefferAlgebra
-- import EML.Lean.SoftplusBasic
import Mathlib

/-! # CatalogBuild.EML.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 35
-/

noncomputable section

/-- The hyperbolic SPB operator. -/
def spbHA (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- n-fold SPB iteration. -/
def spbPowA (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbA x (spbPowA x n)

/-- [Section: # CatalogBuild.EML.AdvancedTheorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 35] -/
theorem spbPowA_zero (x : ℝ) : spbPowA x 0 = 0 := rfl

/-- [Section: # CatalogBuild.EML.AdvancedTheorems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 35] -/
theorem spbPowA_one (x : ℝ) : spbPowA x 1 = x := by simp [spbPowA, spbA]

theorem spbPowA_succ (x : ℝ) (n : ℕ) :
    spbPowA x (n + 1) = spbA x (spbPowA x n) := rfl

/-- arctan is an SPB homomorphism: arctan(spb(x, y)) = arctan(x) + arctan(y)
when xy < 1 (the principal branch condition). -/
theorem arctan_spbA (x y : ℝ) (hxy : x * y < 1) :
    arctan (spbA x y) = arctan x + arctan y := by
  rw [spbA]
  exact (Real.arctan_add hxy).symm

/-- The hyperbolic midpoint: spbHA(x, x) = 2x/(1+x²). -/
theorem spbHA_self (x : ℝ) : spbHA x x = 2 * x / (1 + x * x) := by
  unfold spbHA; ring

theorem weierstrass_cos (θ : ℝ) (h : cos (θ / 2) ≠ 0) :
    cos θ = (1 - tan (θ / 2) ^ 2) / (1 + tan (θ / 2) ^ 2) := by
  rw [ ← eq_comm, Real.tan_eq_sin_div_cos ];
  field_simp;
  rw [ Real.sin_sq, Real.cos_sq ] ; ring

theorem weierstrass_sin (θ : ℝ) (h : cos (θ / 2) ≠ 0) :
    sin θ = 2 * tan (θ / 2) / (1 + tan (θ / 2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.sin_two_mul, Real.tan_eq_sin_div_cos ];
  field_simp;
  norm_num

theorem spbHA_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    1 + x * y > 0 := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-- spbPowA(x, 2) = spbA(x, x). -/
theorem spbPowA_two (x : ℝ) : spbPowA x 2 = spbA x x := by
  simp [spbPowA, spbA]

theorem spbPowA_tan (θ : ℝ) (n : ℕ) (hcos : ∀ k : ℕ, k ≤ n → cos (k * θ) ≠ 0) :
    spbPowA (tan θ) n = tan (n * θ) := by
  -- Let's prove the auxiliary result that spbA(tan θ, tan kθ) = tan((k+1)θ) for any k ≤ n.
  have h_aux (k : ℕ) (hk : k ≤ n) : spbA (Real.tan θ) (Real.tan (k * θ)) = Real.tan ((k + 1) * θ) := by
    simp +decide only [spbA, tan_eq_sin_div_cos];
    by_cases h : Real.cos θ = 0 <;> by_cases h' : Real.cos ( k * θ ) = 0 <;> simp_all +decide [ add_mul, Real.sin_add, Real.cos_add, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
    · specialize hcos 1 ; aesop;
    · simp_all +decide [ mul_add, Real.sin_add, Real.cos_add, mul_assoc, mul_comm, mul_left_comm ];
      grind;
  induction' n with n ih <;> simp_all +decide [ spbPowA ];
  grind +splitIndPred

theorem cauchy_spb_invariance (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spbA x a ^ 2)⁻¹ * ((1 + a ^ 2) / (1 - x * a) ^ 2) =
    (1 + x ^ 2)⁻¹ := by
  -- Simplifying the left-hand side:
  unfold spbA;
  -- Combine and simplify the fractions in the left-hand side.
  field_simp
  ring

/-- Iterated softplus: σⁿ(x) = σ(σ(...σ(x)...)) -/
def softplus_iter : ℕ → ℝ → ℝ
  | 0 => id
  | n + 1 => softplus ∘ softplus_iter n

/-- Iterated softplus is positive for n ≥ 1 -/
theorem softplus_iter_pos (n : ℕ) (x : ℝ) : softplus_iter (n + 1) x > 0 := by
  induction n with
  | zero => exact softplus_pos x
  | succ n ih => exact softplus_pos (softplus_iter (n + 1) x)

/-- Iterated softplus is strictly monotone -/
theorem softplus_iter_strictMono (n : ℕ) : StrictMono (softplus_iter n) := by
  induction n with
  | zero => exact strictMono_id
  | succ n ih => exact softplus_strictMono.comp ih

/-- Iterated softplus is in the Sheffer algebra -/
theorem softplus_iter_mem_sheffer (n : ℕ) : (softplus_iter n) ∈ ShefferAlgebra := by
  induction n with
  | zero => convert id_mem_sheffer using 1
  | succ n ih =>
    have hσ := softplus_mem_sheffer
    have := sheffer_comp_closed hσ ih
    convert this using 1

theorem logisticSigmoid_differentiable : Differentiable ℝ logisticSigmoid := by
  exact fun x => DifferentiableAt.div ( Real.differentiableAt_exp ) ( by norm_num ) ( by positivity )

theorem sigmoid_deriv_eq (x : ℝ) :
    deriv logisticSigmoid x = logisticSigmoid x * (1 - logisticSigmoid x) := by
  unfold logisticSigmoid;
  ring;
  norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos x ) ) ] ; ring

theorem softplus_subadditive_nonneg (x y : ℝ) (_hx : x ≥ 0) (_hy : y ≥ 0) :
    softplus (x + y) ≤ softplus x + softplus y := by
  unfold softplus;
  rw [ ← Real.log_mul ( by positivity ) ( by positivity ) ] ; exact Real.log_le_log ( by positivity ) ( by rw [ Real.exp_add ] ; nlinarith [ Real.exp_pos x, Real.exp_pos y ] ) ;

theorem softplus_jensen (x y : ℝ) :
    softplus ((x + y) / 2) ≤ (softplus x + softplus y) / 2 := by
  -- Apply Jensen's inequality for the convex function σ with weights 1/2 and 1/2.
  have h_jensen : ConvexOn ℝ Set.univ softplus := by
    exact?;
  have := h_jensen.2 ( Set.mem_univ x ) ( Set.mem_univ y );
  convert @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) using 1 <;> norm_num <;> ring

theorem softplus_upper_bound (x : ℝ) : softplus x ≤ max x 0 + Real.log 2 := by
  by_cases hx : x ≥ 0;
  · unfold softplus;
    rw [ max_eq_left hx, Real.log_le_iff_le_exp ( by positivity ) ];
    rw [ Real.exp_add, Real.exp_log ] <;> linarith [ Real.add_one_le_exp x ];
  · simp_all +decide [ softplus ];
    exact le_add_of_nonneg_of_le ( by positivity ) ( Real.log_le_log ( by positivity ) ( by linarith [ Real.exp_le_one_iff.mpr hx.le ] ) )

theorem softplus_lower_bound_nonneg (x : ℝ) (hx : x ≥ 0) :
    softplus x ≥ x / 2 + Real.log 2 / 2 := by
  unfold softplus;
  -- We can use the fact that $log(1 + e^x) \geq log(2e^{x/2})$ for $x \geq 0$.
  have h_log_ineq : Real.log (1 + Real.exp x) ≥ Real.log (2 * Real.exp (x / 2)) := by
    exact Real.log_le_log ( by positivity ) ( by rw [ show Real.exp x = ( Real.exp ( x / 2 ) ) ^ 2 by rw [ ← Real.exp_nat_mul ] ; ring ] ; nlinarith [ Real.exp_pos ( x / 2 ), sq_nonneg ( Real.exp ( x / 2 ) - 1 ) ] );
  rw [ Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] at h_log_ineq ; linarith [ Real.log_nonneg one_le_two ]

/-- Double application: σ(σ(x)) > σ(x) (softplus maps to higher values) -/
theorem softplus_softplus_gt (x : ℝ) : softplus (softplus x) > softplus x :=
  softplus_gt_id (softplus x)

/-- exp(σ(σ(x))) = 1 + (1 + eˣ) = 2 + eˣ -/
theorem softplus_double_exp (x : ℝ) :
    exp (softplus (softplus x)) = 1 + (1 + exp x) := by
  rw [softplus_exp_identity, softplus_exp_identity]

theorem sheffer_expr_lipschitz (e : ShefferExpr) :
    ∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |e.eval x - e.eval y| ≤ C * |x - y| := by
  induction' e with e ih e₁ e₂ ih₁ ih₂ e₁ e₂ ih₁ ih₂;
  · exact ⟨ 1, by norm_num, fun x y => by simpa [ mul_comm ] using LipschitzWith.norm_sub_le ( softplus_lipschitz ) x y ⟩;
  · obtain ⟨ C, hC₀, hC ⟩ := e₂; use C * |e|; constructor <;> norm_num [ abs_mul ] at *;
    · positivity;
    · intro x y; convert hC ( e * x + ih ) ( e * y + ih ) using 1 ; ring;
      rw [ show x * e - y * e = e * ( x - y ) by ring, abs_mul ] ; ring;
  · rename_i h₁ h₂;
    rename_i h₃;
    obtain ⟨ C₂, hC₂₀, hC₂ ⟩ := ih₂
    obtain ⟨ C₁, hC₁₀, hC₁ ⟩ := h₂
    use |h₃| * C₂ + |h₁| * C₁;
    simp_all +decide [ ShefferExpr.eval ];
    exact ⟨ by positivity, fun x y => by rw [ abs_le ] ; constructor <;> cases abs_cases ( x - y ) <;> cases abs_cases h₃ <;> cases abs_cases h₁ <;> nlinarith [ abs_le.mp ( hC₂ x y ), abs_le.mp ( hC₁ x y ) ] ⟩;
  · rename_i e₁ e₂ ih₁ ih₂;
    obtain ⟨ C₁, hC₁, hC₁' ⟩ := ih₁; obtain ⟨ C₂, hC₂, hC₂' ⟩ := ih₂; use C₁ * C₂; exact ⟨ mul_nonneg hC₁ hC₂, fun x y => by simpa only [ mul_assoc ] using le_trans ( hC₁' _ _ ) ( mul_le_mul_of_nonneg_left ( hC₂' _ _ ) hC₁ ) ⟩ ;

theorem exp_not_mem_sheffer : (fun x : ℝ => Real.exp x) ∉ ShefferAlgebra := by
  rintro ⟨ e, he ⟩;
  have h_exp_lip : ∃ C : ℝ, C ≥ 0 ∧ ∀ x y : ℝ, |Real.exp x - Real.exp y| ≤ C * |x - y| := by
    have := sheffer_expr_lipschitz e;
    grind +qlia;
  obtain ⟨ C, hC₀, hC ⟩ := h_exp_lip;
  -- Consider the limit of the ratio $\frac{e^x - e^0}{x - 0}$ as $x \to \infty$.
  have h_lim : Filter.Tendsto (fun x => (Real.exp x - 1) / x) Filter.atTop Filter.atTop := by
    have h_lim : Filter.Tendsto (fun x => Real.exp x / x) Filter.atTop Filter.atTop := by
      simpa using Real.tendsto_exp_div_pow_atTop 1;
    simp_all +decide [ sub_div ];
    exact Filter.Tendsto.atTop_add h_lim ( Filter.Tendsto.neg ( tendsto_inv_atTop_zero ) );
  have := h_lim.eventually_gt_atTop C;
  obtain ⟨ x, hx ⟩ := this.and ( Filter.eventually_gt_atTop 0 ) |> fun h => h.exists;
  rw [ lt_div_iff₀ ] at hx <;> have := hC x 0 <;> norm_num at * <;> cases abs_cases ( Real.exp x - 1 ) <;> cases abs_cases x <;> nlinarith

/-- The affine function x ↦ ax + b is in the Sheffer algebra -/
theorem affine_mem_sheffer (a b : ℝ) : (fun x : ℝ => a * x + b) ∈ ShefferAlgebra := by
  have hid := id_mem_sheffer
  have hc := const_mem_sheffer b
  have := sheffer_affine_comb_closed hid hc a 1 0
  convert this using 1
  ext x; ring

/-- A base expression has width exactly 1 -/
theorem sheffer_base_width : ShefferExpr.base.width = 1 := by
  simp [ShefferExpr.width]

/-- Every Sheffer expression has width ≥ 1 -/
theorem sheffer_width_pos (e : ShefferExpr) : e.width ≥ 1 := by
  induction e with
  | base => simp [ShefferExpr.width]
  | affine_pre a b e ih => simp [ShefferExpr.width]; exact ih
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ => simp [ShefferExpr.width]; omega
  | comp e₁ e₂ ih₁ ih₂ => simp [ShefferExpr.width]; omega

/-- Every Sheffer expression has depth ≥ 1 -/
theorem sheffer_depth_pos (e : ShefferExpr) : e.depth ≥ 1 := by
  induction e with
  | base => simp [ShefferExpr.depth]
  | affine_pre a b e ih => simp [ShefferExpr.depth]; exact ih
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
    simp [ShefferExpr.depth]; omega
  | comp e₁ e₂ ih₁ ih₂ => simp [ShefferExpr.depth]; omega

theorem softplus_temp_strictMono {β : ℝ} (hβ : β > 0) :
    StrictMono (softplus_temp β) := by
  intro x y hxy;
  unfold softplus_temp;
  gcongr

/-- Temperature softplus satisfies σ_β(0) = log(2)/β -/
theorem softplus_temp_zero {β : ℝ} (_hβ : β > 0) :
    softplus_temp β 0 = Real.log 2 / β := by
  unfold softplus_temp
  simp [mul_zero, exp_zero]
  ring

theorem softplus_ge_half_exp (x : ℝ) (hx : x ≤ 0) :
    softplus x ≥ Real.exp x / 2 := by
  unfold softplus;
  -- Let $y = \exp(x)$. Since $x \leq 0$, we have $0 < y \leq 1$.
  set y : ℝ := Real.exp x
  have hy : 0 < y ∧ y ≤ 1 := by
    exact ⟨ Real.exp_pos x, Real.exp_le_one_iff.mpr hx ⟩;
  nlinarith [ Real.log_inv ( 1 + y ), Real.log_le_sub_one_of_pos ( inv_pos.mpr ( by linarith : 0 < 1 + y ) ), mul_inv_cancel₀ ( by linarith : ( 1 + y ) ≠ 0 ) ]

theorem softplus_second_deriv_pos (x : ℝ) :
    deriv (deriv softplus) x > 0 := by
  unfold deriv;
  unfold softplus;
  norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos _ ) ) ];
  rw [ inv_mul_eq_div, div_mul_eq_mul_div, div_add_div, lt_div_iff₀ ] <;> nlinarith [ Real.exp_pos x, Real.add_one_le_exp x ]

end