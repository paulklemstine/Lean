/-! # CatalogBuild.EML.EMLv19Core

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 39
-/

import EML.EMLv17Advanced
import EML.EMLv17Core
import EML.EMLv18Advanced
import EML.EMLv18Core
import Mathlib

noncomputable section

/-- [Section: ## §1. Strict Concavity of EML in y] -/
theorem eml_strictConvexOn_snd (x : ℝ) :
    StrictConvexOn ℝ (Ioi 0) (fun y => eml x y) := by
  refine' strictConvexOn_of_deriv2_pos' ( convex_Ioi 0 ) _ _;
  · exact ContinuousOn.sub continuousOn_const ( Real.continuousOn_log.mono fun y hy => ne_of_gt hy );
  · unfold eml;
    intro y hy; norm_num [ sub_eq_add_neg, hy.out.ne' ];
    nlinarith [ hy.out ]


/-- Convexity in y (weaker version). -/
theorem eml_convexOn_snd (x : ℝ) :
    ConvexOn ℝ (Ioi 0) (fun y => eml x y) :=
  (eml_strictConvexOn_snd x).convexOn


/-- By convexity in y: eml(x, t·a + (1-t)·b) ≤ t·eml(x,a) + (1-t)·eml(x,b). -/
theorem eml_jensen_snd (x a b t : ℝ) (ha : 0 < a) (hb : 0 < b)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eml x (t * a + (1 - t) * b) ≤ t * eml x a + (1 - t) * eml x b := by
  exact (eml_convexOn_snd x).2 ha hb ht0 (by linarith) (by linarith)


/-- EML with logSumExp input. -/
theorem eml_logSumExp (a b y : ℝ) :
    eml (logSumExp a b) y = exp a + exp b - log y := by
  unfold eml logSumExp
  rw [exp_log (by positivity : exp a + exp b > 0)]


/-- The α-scaled EML family: eml_α(x, y) = exp(α·x) - α·ln(y). -/
def emlAlpha (α x y : ℝ) : ℝ := exp (α * x) - α * log y


/-- [Section: ## §4. Parametric EML Family] -/
theorem emlAlpha_at_one (x y : ℝ) : emlAlpha 1 x y = eml x y := by
  unfold emlAlpha eml; ring_nf


theorem emlAlpha_at_zero (x y : ℝ) : emlAlpha 0 x y = 1 := by
  simp [emlAlpha]


/-- Scaling identity: emlAlpha α + emlAlpha (-α) = 2·cosh(αx). -/
theorem emlAlpha_sum_neg (α x y : ℝ) :
    emlAlpha α x y + emlAlpha (-α) x y = exp (α * x) + exp (-(α * x)) := by
  unfold emlAlpha; ring


/-- The EML entropy: H(p) = eml(ln p, p) = p - ln p for p > 0. -/
def emlEntropy (p : ℝ) : ℝ := eml (log p) p


/-- [Section: ## §5. EML Entropy Function] -/
theorem emlEntropy_eq (p : ℝ) (hp : 0 < p) : emlEntropy p = p - log p := by
  unfold emlEntropy eml; rw [exp_log hp]


theorem emlEntropy_ge_one (p : ℝ) (hp : 0 < p) : emlEntropy p ≥ 1 := by
  rw [emlEntropy_eq p hp]; exact sub_log_ge_one p hp


theorem emlEntropy_eq_one_iff (p : ℝ) (hp : 0 < p) : emlEntropy p = 1 ↔ p = 1 := by
  rw [emlEntropy_eq p hp]; exact sub_log_eq_one_iff p hp


theorem emlEntropy_strictConvexOn :
    StrictConvexOn ℝ (Ioi 0) emlEntropy := by
  have h_id_log : StrictConvexOn ℝ (Set.Ioi 0) (fun p : ℝ => p - Real.log p) := by
    apply strictConvexOn_of_deriv2_pos' ( convex_Ioi 0 );
    · exact continuousOn_of_forall_continuousAt fun p hp => ContinuousAt.sub continuousAt_id ( Real.continuousAt_log hp.out.ne' );
    · -- Let's calculate the second derivative of $f(p) = p - \log p$.
      have h_second_deriv : ∀ p : ℝ, 0 < p → deriv^[2] (fun p => p - Real.log p) p = 1 / p^2 := by
        have h_second_deriv : ∀ p : ℝ, 0 < p → deriv^[2] (fun p => p - Real.log p) p = deriv (fun p => 1 - 1 / p) p := by
          exact fun p hp => Filter.EventuallyEq.deriv_eq ( by filter_upwards [ lt_mem_nhds hp ] with x hx using by norm_num [ hx.ne' ] );
        intro p hp; rw [ h_second_deriv p hp ] ; norm_num [ sub_eq_add_neg, differentiableAt_inv, hp.ne' ] ;
      exact fun p hp => h_second_deriv p hp ▸ one_div_pos.mpr ( sq_pos_of_pos hp );
  exact h_id_log.congr fun x hx => by rw [ emlEntropy_eq _ hx ] ;


/-- EML at the harmonic mean. -/
theorem eml_harmonic_mean (x a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    eml x (2 * a * b / (a + b)) =
    exp x - log 2 - log a - log b + log (a + b) := by
  unfold eml
  rw [log_div (by positivity) (by positivity),
      log_mul (by positivity) (by positivity),
      log_mul (by positivity) (by positivity)]
  ring


/-- [Section: ## §7. Young's Inequality via EML] -/
theorem eml_young_bound (x y : ℝ) :
    exp ((x + y) / 2) ≤ (exp x + exp y) / 2 := by
  -- Apply Jensen's inequality for the convex function $\exp$ with weights $\frac{1}{2}$ and $\frac{1}{2}$.
  have h_jensen : ConvexOn ℝ (Set.univ : Set ℝ) Real.exp := by
    exact convexOn_exp;
  have := h_jensen.2 ( Set.mem_univ x ) ( Set.mem_univ y );
  convert @this ( 1 / 2 ) ( 1 / 2 ) ( by norm_num ) ( by norm_num ) ( by norm_num ) using 1 <;> norm_num <;> ring


/-- eml(eml(x,y), z) = exp(exp(x) - log(y)) - log(z). -/
theorem eml_compose (x y z : ℝ) :
    eml (eml x y) z = exp (exp x - log y) - log z := by
  simp [eml]


/-- eml(x, eml(0, y)) = exp(x) - log(1 - log(y)). -/
theorem eml_compose_snd' (x y : ℝ) :
    eml x (eml 0 y) = exp x - log (1 - log y) := by
  simp [eml]


/-- Reverse KL via EML entropy: p/q - 1 - log(p/q) = emlEntropy(p/q) - 1. -/
theorem reverse_kl_eml (p q : ℝ) (hp : 0 < p) (hq : 0 < q) :
    p / q - 1 - log (p / q) = emlEntropy (p / q) - 1 := by
  rw [emlEntropy_eq _ (div_pos hp hq)]; ring


/-- EML is C^∞ in x. -/
theorem eml_smooth_fst (y : ℝ) : ContDiff ℝ ⊤ (fun x => eml x y) := by
  unfold eml; exact contDiff_exp.sub contDiff_const


/-- EML is C^∞ in y on (0,∞). -/
theorem eml_smooth_snd (x : ℝ) :
    ContDiffOn ℝ ⊤ (fun y => eml x y) (Ioi 0) := by
  unfold eml
  exact contDiffOn_const.sub (contDiffOn_log.mono (fun y hy => (mem_Ioi.mp hy).ne'))


/-- eml(x + c, y) - eml(x, y) = exp(x)·(exp(c) - 1). -/
theorem eml_translation_x (x y c : ℝ) :
    eml (x + c) y - eml x y = exp x * (exp c - 1) := by
  unfold eml; rw [exp_add]; ring


/-- eml(x, c·y) = eml(x, y) - log(c) for c, y > 0. -/
theorem eml_scale_y (x y c : ℝ) (hy : 0 < y) (hc : 0 < c) :
    eml x (c * y) = eml x y - log c := by
  unfold eml; rw [log_mul hc.ne' hy.ne']; ring


/-- On the constraint exp(x) + y = S: eml(x,y) = S - y - log(y). -/
theorem eml_on_budget (x y S : ℝ) (hbudget : exp x + y = S) :
    eml x y = S - y - log y := by
  unfold eml; linarith


/-- eml(x + θ, y) = e^θ · eml(x,y) + (e^θ - 1)·log(y). -/
theorem eml_exp_tilt (x y θ : ℝ) :
    eml (x + θ) y = exp θ * eml x y + (exp θ - 1) * log y := by
  unfold eml; rw [exp_add]; ring


/-- eml(x, 1) ≥ 1 + x. -/
theorem eml_at_one_ge (x : ℝ) : eml x 1 ≥ 1 + x := by
  rw [eml_at_one]; linarith [add_one_le_exp x]


/-- eml(x, y) ≤ eml(x, z) iff z ≤ y, for y, z > 0. -/
theorem eml_le_iff_snd (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    eml x y ≤ eml x z ↔ z ≤ y := by
  simp only [eml]
  constructor
  · intro h
    by_contra hlt
    push_neg at hlt
    linarith [log_lt_log hy hlt]
  · intro h; linarith [log_le_log hz h]


/-- d/dt eml(f(t), y) = f'(t) · exp(f(t)). -/
theorem eml_chain_deriv {f : ℝ → ℝ} {f' : ℝ} {y t : ℝ} (hf : HasDerivAt f f' t) :
    HasDerivAt (fun s => eml (f s) y) (f' * exp (f t)) t := by
  unfold eml
  have := hf.exp.sub (hasDerivAt_const t (log y))
  convert this using 1; simp; ring


/-- d/dt eml(x, g(t)) = -g'(t)/g(t). -/
theorem eml_chain_deriv_snd {g : ℝ → ℝ} {g' : ℝ} {x t : ℝ}
    (hg : HasDerivAt g g' t) (hgt : 0 < g t) :
    HasDerivAt (fun s => eml x (g s)) (- g' / g t) t := by
  unfold eml
  have h := (hasDerivAt_const t (Real.exp x)).sub (hg.log hgt.ne')
  convert h using 1; simp; ring


/-- G(t) = eml(t, exp(-t)) = exp(t) + t. -/
theorem eml_generating (t : ℝ) : eml t (exp (-t)) = exp t + t := by
  unfold eml; rw [log_exp]; ring


/-- eml₃(x, y, z) = exp(x) - log(y) + z·log(z) - z + 1.
Specializes to eml(x,y) when z = 1. -/
def eml3 (x y z : ℝ) : ℝ := exp x - log y + z * log z - z + 1


/-- [Section: ## §17. Three-Variable Extension] -/
theorem eml3_at_z_one (x y : ℝ) : eml3 x y 1 = eml x y := by
  unfold eml3 eml; simp [log_one]


theorem eml3_fenchel_young (x z : ℝ) (hz : 0 < z) :
    eml3 x 1 z ≥ x * z := by
  have := fenchel_young_exp x z hz;
  unfold eml3; norm_num; linarith;


/-- [Section: ## §18. New Evaluation Identities] -/
theorem eml_eval_neg1_1 : eml (-1) 1 = exp (-1) := by simp [eml, log_one]

theorem eml_eval_0_2 : eml 0 2 = 1 - log 2 := by simp [eml]


theorem eml_eval_log2 : eml (log 2) 2 = 2 - log 2 := by
  unfold eml; rw [exp_log (by positivity : (2:ℝ) > 0)]


/-- σ-EML symmetry: σ(x) + σ(-x) = 2·cosh(x) - log((1+e^{-x})(1+e^x)). -/
theorem sigmaEml_sum_neg (x : ℝ) :
    sigmaEml x + sigmaEml (-x) =
    exp x + exp (-x) - log ((1 + exp (-x)) * (1 + exp x)) := by
  unfold sigmaEml
  rw [neg_neg, log_mul (by positivity) (by positivity)]
  ring


/-- For all x: σ-EML(x) ≤ exp(x). -/
theorem sigmaEml_le_exp (x : ℝ) : sigmaEml x ≤ exp x := by
  unfold sigmaEml
  linarith [log_nonneg (show (1 : ℝ) ≤ 1 + exp (-x) by linarith [exp_pos (-x)])]


/-- |eml(x₁,y) - eml(x₂,y)| = |exp(x₁) - exp(x₂)|. -/
theorem eml_diff_fst_abs (x₁ x₂ y : ℝ) :
    |eml x₁ y - eml x₂ y| = |exp x₁ - exp x₂| := by
  unfold eml; congr 1; ring


/-- [Section: ## §21. σ-EML Strict Convexity] -/
theorem sigmaEml_strictConvexOn :
    StrictConvexOn ℝ univ sigmaEml := by
  apply strictConvexOn_of_deriv2_pos ( convex_univ );
  · exact ContinuousOn.sub ( Real.continuousOn_exp ) ( ContinuousOn.log ( continuousOn_const.add ( Real.continuous_exp.comp_continuousOn ( continuousOn_id.neg ) ) ) fun x hx => by positivity );
  · unfold sigmaEml; norm_num [ Real.differentiableAt_exp ] ;
    intro x; rw [ show deriv ( fun x => rexp x - log ( 1 + rexp ( -x ) ) ) = fun x => deriv ( fun x => rexp x - log ( 1 + rexp ( -x ) ) ) x from rfl ] ; norm_num [ Real.exp_neg, Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos _ ) ) ] ;
    norm_num [ Real.exp_ne_zero, Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( inv_pos.mpr ( Real.exp_pos _ ) ) ), mul_comm, div_eq_mul_inv, sq ];
    field_simp;
    nlinarith [ Real.exp_pos x, Real.add_one_le_exp x, pow_pos ( Real.exp_pos x ) 3 ]


end
