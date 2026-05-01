import EML.EMLv17Advanced
import EML.EMLv17Core
import EML.EMLv18Advanced
import EML.EMLv18Core
import EML.EMLv19Core
import Mathlib

/-! # CatalogBuild.EML.EMLv19Advanced

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 28
-/

noncomputable section

/-- σ-EML is surjective. -/
theorem sigmaEml_surjective : Function.Surjective sigmaEml :=
  sigmaEml_continuous.surjective sigmaEml_tendsto_atTop sigmaEml_tendsto_atBot

/-- σ-EML is bijective. -/
theorem sigmaEml_bijective : Function.Bijective sigmaEml :=
  ⟨sigmaEml_strictMono.injective, sigmaEml_surjective⟩

/-- eml(tx, 1) ≥ 1 + tx. -/
theorem eml_markov_bound (t x : ℝ) :
    eml (t * x) 1 ≥ 1 + t * x := eml_at_one_ge (t * x)

/-- eml(t, 1) ≥ 1 + t. -/
theorem eml_chernoff_lower (t : ℝ) :
    eml t 1 ≥ 1 + t := eml_at_one_ge t

/-- The difference quotient of eml in x. -/
theorem eml_diff_quotient (x h y : ℝ) :
    (eml (x + h) y - eml x y) / h = exp x * (exp h - 1) / h := by
  rw [eml_translation_x]

/-- [Section: ## §4. EML Strict Gibbs Inequality] -/
theorem eml_strict_gibbs (p q : ℝ) (hp : 0 < p) (hq : 0 < q) (hpq : p ≠ q) :
    emlEntropy (p / q) > 1 := by
  -- By definition of_entropy, we know emlEntropy(p/q) ≥ 1 for all p/q > 0 (emlEntropy_ge_one), and emlEntropy(p/q) = 1 iff p/q = 1 (emlEntropy_eq_one_iff).
  have emlEntropy_ge_one : emlEntropy (p / q) ≥ 1 := by
    exact emlEntropy_ge_one _ ( div_pos hp hq )
  have emlEntropy_eq_one_iff : emlEntropy (p / q) = 1 ↔ p / q = 1 := by
    exact emlEntropy_eq_one_iff ( p / q ) ( div_pos hp hq );
  exact lt_of_le_of_ne emlEntropy_ge_one ( Ne.symm <| by intro h; exact hpq <| eq_of_div_eq_one <| emlEntropy_eq_one_iff.mp h )

/-- eml(θ, exp(A_θ)) = exp(θ) - A_θ. -/
theorem eml_exp_family (theta A_theta : ℝ) :
    eml theta (exp A_theta) = exp theta - A_theta := by
  simp [eml, log_exp]

/-- eml(n·x, 1) = (exp(x))^n. -/
theorem eml_power_series_term (x : ℝ) (n : ℕ) :
    eml (↑n * x) 1 = (exp x) ^ n := by
  simp [eml, log_one, exp_nat_mul]

/-- x + y ≤ eml(x,1) + eml(y,1) - 1. -/
theorem eml_holder_type (x y : ℝ) :
    x + y ≤ eml x 1 + eml y 1 - 1 := by
  rw [eml_at_one, eml_at_one]
  linarith [add_one_le_exp x, add_one_le_exp y]

/-- eml(x₁ + x₂, y₁ · y₂) = exp(x₁)·exp(x₂) - log(y₁) - log(y₂). -/
theorem eml_product_decomp (x₁ x₂ y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂) :
    eml (x₁ + x₂) (y₁ * y₂) = exp x₁ * exp x₂ - log y₁ - log y₂ := by
  unfold eml; rw [exp_add, log_mul hy₁.ne' hy₂.ne']; ring

/-- Gaussian curvature numerator: exp(x₀) · y₀⁻² > 0. -/
theorem eml_gauss_curvature_pos (x₀ y₀ : ℝ) (hy₀ : 0 < y₀) :
    exp x₀ * y₀⁻¹ ^ 2 > 0 := by positivity

/-- eml(x,y) + eml(y,x) ≥ 2 for x, y > 0. -/
theorem eml_symm_lower (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    eml x y + eml y x ≥ 2 := by
  rw [eml_trace]
  linarith [add_one_le_exp x, add_one_le_exp y,
            log_le_sub_one_of_pos hx, log_le_sub_one_of_pos hy]

/-- eml(x₁,y) - eml(x₂,y) = exp(x₁) - exp(x₂). -/
theorem eml_bregman_via_diff (x₁ x₂ y : ℝ) :
    eml x₁ y - eml x₂ y = exp x₁ - exp x₂ := by
  unfold eml; ring

/-- eml(x, y) → -log(y) as x → -∞. -/
theorem eml_limit_neg_infty (y : ℝ) :
    Tendsto (fun x => eml x y) atBot (nhds (-log y)) := by
  unfold eml
  have : Tendsto (fun x => exp x - log y) atBot (nhds (0 - log y)) :=
    tendsto_exp_atBot.sub tendsto_const_nhds
  simp only [zero_sub] at this; exact this

/-- [Section: ## §12. EML Asymptotics] -/
theorem eml_limit_y_infty (x : ℝ) :
    Tendsto (fun y => eml x y) atTop atBot := by
  exact Filter.Tendsto.add_atBot ( tendsto_const_nhds ) ( Filter.tendsto_neg_atTop_atBot.comp ( Real.tendsto_log_atTop ) )

/-- The level set eml(x, y) = c is solved by y = exp(exp(x) - c). -/
theorem eml_level_set (x c : ℝ) :
    eml x (exp (exp x - c)) = c := by
  unfold eml; rw [log_exp]; ring

/-- eml(x,y) ≤ c iff exp(exp(x) - c) ≤ y. -/
theorem eml_sublevel_char (x c y : ℝ) (hy : 0 < y) :
    eml x y ≤ c ↔ exp (exp x - c) ≤ y := by
  constructor
  · intro h
    rw [← log_le_log_iff (exp_pos _) hy, log_exp]
    unfold eml at h; linarith
  · intro h
    unfold eml
    linarith [log_le_log (exp_pos _) h, log_exp (exp x - c)]

/-- eml(x, exp(y_sum)) = exp(x) - y_sum. -/
theorem eml_softmax_numerator (x y_sum : ℝ) :
    eml x (exp y_sum) = exp x - y_sum := by
  simp [eml, log_exp]

/-- eml is strictly increasing in x and strictly decreasing in y. -/
theorem eml_bimonotone (x₁ x₂ y₁ y₂ : ℝ) (hy₁ : 0 < y₁) (hy₂ : 0 < y₂)
    (hx : x₁ < x₂) (hy : y₂ < y₁) :
    eml x₁ y₁ < eml x₂ y₂ := by
  calc eml x₁ y₁ < eml x₂ y₁ := eml_strictMono_fst y₁ hx
    _ < eml x₂ y₂ := by unfold eml; linarith [log_lt_log hy₂ hy]

/-- exp(eml(x,y)) = exp(exp(x)) / y. -/
theorem eml_exp_value (x y : ℝ) (hy : 0 < y) :
    exp (eml x y) = exp (exp x) / y := by
  unfold eml; rw [exp_sub, exp_log hy]

/-- At a g-map fixed point z*: exp(z*) = exp(e) / z*. -/
theorem gmap_fixpoint_exp (z : ℝ) (hz : 0 < z) (hfix : emlGmap z = z) :
    exp z = exp (exp 1) / z := by
  have heml : eml 1 z = z := by
    unfold eml emlGmap at *; linarith
  have := eml_exp_value 1 z hz
  rw [heml] at this; exact this

/-- eml(x, C) satisfies f'(x) = f(x) + log(C). -/
theorem eml_ode_shifted (x C : ℝ) :
    HasDerivAt (fun x => eml x C) (eml x C + log C) x := by
  have h := eml_hasDerivAt_fst x C
  convert h using 1; unfold eml; ring

/-- eml(x, exp(x)) = exp(x) - x. -/
theorem eml_self_info (x : ℝ) : eml x (exp x) = exp x - x := eml_self_exp x

/-- eml(0, 1) = 1. -/
theorem eml_init : eml 0 1 = 1 := eml_eval_0_1

/-- [Section: ## §21. EML Quadratic Lower Bound] -/
theorem eml_quadratic_lower (x : ℝ) (hx : 0 ≤ x) :
    eml x 1 ≥ 1 + x + x ^ 2 / 2 := by
  unfold eml;
  norm_num [ Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div ] at *;
  exact le_trans ( by norm_num [ Finset.sum_range_succ ] ) ( Summable.sum_le_tsum ( Finset.range 3 ) ( fun _ _ => by positivity ) ( by simpa using Real.summable_pow_div_factorial x ) )

/-- [Section: ## §22. EML Strict Jensen in x] -/
theorem eml_strict_jensen_fst (x₁ x₂ y t : ℝ)
    (ht0 : 0 < t) (ht1 : t < 1) (hne : x₁ ≠ x₂) :
    eml (t * x₁ + (1 - t) * x₂) y < t * eml x₁ y + (1 - t) * eml x₂ y := by
  unfold eml;
  -- Apply the strict convexity of the exponential function.
  have h_exp_strict_convex : StrictConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
    exact strictConvexOn_exp;
  have := h_exp_strict_convex.2 ( Set.mem_univ x₁ ) ( Set.mem_univ x₂ ) hne;
  have := @this t ( 1 - t ) ht0 ( by linarith ) ( by linarith ) ; norm_num at * ; linarith;

/-- [Section: ## §23. EML Functional Iteration] -/
theorem eml_iterate_one (n : ℕ) (x : ℝ) :
    (fun x => eml x 1)^[n] x = emlTower n x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply', emlTower_succ ];
  · rfl;
  · unfold eml; norm_num;

/-- [Section: ## §24. σ-EML at log(2)] -/
theorem sigmaEml_at_log2 :
    sigmaEml (log 2) = 2 - log (3 / 2) := by
  unfold sigmaEml;
  norm_num [ Real.exp_neg, Real.exp_log ]

end