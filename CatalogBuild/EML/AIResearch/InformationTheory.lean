/-! # CatalogBuild.EML.AIResearch.InformationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Description Length and Compression] -/
def standardDescLength (layers width precision : ℕ) : ℕ :=
  layers * width * width * precision


def emlDescLength (depth width precision : ℕ) : ℕ :=
  4 * depth * width * precision


theorem eml_shorter_description (d w p : ℕ) (hw : 5 ≤ w) (hd : 0 < d) (hp : 0 < p) :
    emlDescLength d w p ≤ standardDescLength d w p := by
  unfold emlDescLength standardDescLength;
  nlinarith [ mul_le_mul_left' hw ( d * p ) ]


/-- [Section: ## §2. Information Bottleneck] -/
def infoRetained (alpha : ℝ) (l : ℕ) : ℝ := alpha ^ l


theorem eml_retains_more_info (alpha_eml alpha_std : ℝ) (l : ℕ)
    (halpha_s0 : 0 ≤ alpha_std) (halpha : alpha_std ≤ alpha_eml) :
    infoRetained alpha_std l ≤ infoRetained alpha_eml l := by
  exact pow_le_pow_left₀ halpha_s0 halpha l


theorem info_decays_with_depth (alpha : ℝ) (l1 l2 : ℕ) (halpha0 : 0 ≤ alpha) (halpha1 : alpha ≤ 1)
    (hl : l1 ≤ l2) :
    infoRetained alpha l2 ≤ infoRetained alpha l1 := by
  unfold infoRetained; exact pow_le_pow_of_le_one halpha0 halpha1 hl


/-- [Section: ## §3. Entropy of EML Representations] -/
def reprEntropy (states : ℕ) : ℝ := Real.log ↑states


theorem eml_higher_entropy (d : ℕ) (hd : 2 ≤ d) :
    d + 1 < 3 ^ d := by
  induction' hd with k hk <;> norm_num [ Nat.pow_succ' ] at * ; linarith [ pow_pos ( show 0 < 3 by norm_num ) k ]


/-- [Section: ## §4. Rate-Distortion for EML] -/
def rateFunction (variance D : ℝ) : ℝ := Real.log (variance / D) / 2


theorem rate_distortion_tradeoff (sigma_sq D1 D2 : ℝ) (hsigma : 0 < sigma_sq)
    (hD1 : 0 < D1) (hD2 : 0 < D2) (hD : D2 ≤ D1) :
    rateFunction sigma_sq D1 ≤ rateFunction sigma_sq D2 := by
  exact div_le_div_of_nonneg_right ( Real.log_le_log ( by positivity ) ( by gcongr ) ) ( by positivity )


def emlRate (variance D advantage : ℝ) : ℝ :=
  rateFunction variance D - advantage


theorem eml_rate_advantage (sigma_sq D adv : ℝ) (hadv : 0 ≤ adv) :
    emlRate sigma_sq D adv ≤ rateFunction sigma_sq D := by
  unfold emlRate; linarith


/-- [Section: ## §5. Generalization via Compression] -/
def pacBayesBound (kl : ℝ) (n : ℕ) : ℝ := Real.sqrt (kl / ↑n)


theorem pac_bayes_more_data (kl : ℝ) (n1 n2 : ℕ) (hkl : 0 ≤ kl) (hn1 : 0 < n1) (h : n1 ≤ n2) :
    pacBayesBound kl n2 ≤ pacBayesBound kl n1 := by
  exact Real.sqrt_le_sqrt <| div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by norm_cast )


theorem pac_bayes_simpler_model (kl1 kl2 : ℝ) (n : ℕ) (hn : 0 < n) (h : kl1 ≤ kl2) :
    pacBayesBound kl1 n ≤ pacBayesBound kl2 n := by
  exact Real.sqrt_le_sqrt ( div_le_div_of_nonneg_right h <| Nat.cast_nonneg _ )


def modelKL (params precision : ℕ) : ℝ := ↑params * Real.log ↑precision


theorem eml_lower_kl (d w p : ℕ) (hp : 1 < p) (hw : 5 ≤ w) :
    modelKL (4 * d * w) p ≤ modelKL (d * w * w) p := by
  -- Since $p > 1$, the logarithm term $\log p$ is positive. Therefore, we can divide both sides of the inequality by $\log p$ without changing the direction of the inequality.
  have h_div : 4 * d * w ≤ d * w * w := by
    nlinarith [ mul_le_mul_left' hw d ];
  exact mul_le_mul_of_nonneg_right ( mod_cast h_div ) ( Real.log_nonneg ( mod_cast hp.le ) )


end
