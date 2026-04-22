import Mathlib

/-! # CatalogBuild.EML.AIResearch.DiffusionModelTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 48
-/

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.DiffusionModelTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 35] -/
def noiseSchedule (beta t : ℝ) : ℝ := Real.exp (-beta * t)

/-- [Section: # CatalogBuild.EML.AIResearch.DiffusionModelTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 48] -/
theorem noise_schedule_pos (beta t : ℝ) : 0 < noiseSchedule beta t :=
  Real.exp_pos _

theorem higher_beta_more_noise (b1 b2 t : ℝ) (hb : b1 ≤ b2) (ht : 0 ≤ t) :
    noiseSchedule b2 t ≤ noiseSchedule b1 t := by
  unfold noiseSchedule; apply Real.exp_le_exp.mpr; nlinarith

theorem noise_increases_with_time (beta t1 t2 : ℝ) (hb : 0 ≤ beta) (ht : t1 ≤ t2) :
    noiseSchedule beta t2 ≤ noiseSchedule beta t1 := by
  unfold noiseSchedule; apply Real.exp_le_exp.mpr; nlinarith

theorem noise_schedule_initial (beta : ℝ) : noiseSchedule beta 0 = 1 := by
  unfold noiseSchedule; simp

def stdDenoiserParams (channels depth : ℕ) : ℕ := depth * channels * channels

def emlDenoiserParams (channels depth : ℕ) : ℕ := depth * 4 * channels

theorem eml_denoiser_efficiency (c d : ℕ) (hc : 4 ≤ c) :
    emlDenoiserParams c d ≤ stdDenoiserParams c d := by
  unfold emlDenoiserParams stdDenoiserParams
  have : d * 4 ≤ d * c := Nat.mul_le_mul_left d hc
  exact Nat.mul_le_mul_right c this

def stdScoreParams (dataDim hiddenDim : ℕ) : ℕ := 2 * dataDim * hiddenDim

def emlScoreParams (dataDim : ℕ) : ℕ := 4 * dataDim

theorem eml_score_efficiency (d h : ℕ) (hh : 2 ≤ h) :
    emlScoreParams d ≤ stdScoreParams d h := by
  unfold emlScoreParams stdScoreParams; nlinarith

def ddpmSamplingCost (numSteps networkCost : ℕ) : ℕ := numSteps * networkCost

def emlSamplingCost (numSteps networkCost : ℕ) : ℕ := numSteps * networkCost

theorem eml_sampling_cheaper (steps_eml steps_std cost_eml cost_std : ℕ)
    (hs : steps_eml ≤ steps_std) (hc : cost_eml ≤ cost_std) :
    emlSamplingCost steps_eml cost_eml ≤ ddpmSamplingCost steps_std cost_std := by
  unfold emlSamplingCost ddpmSamplingCost; exact Nat.mul_le_mul hs hc

def cfgCost (networkParams : ℕ) : ℕ := 2 * networkParams

def emlCFGCost (networkParams guidanceDim : ℕ) : ℕ := networkParams + 4 * guidanceDim

theorem eml_cfg_cheaper (p g : ℕ) (hg : 4 * g ≤ p) :
    emlCFGCost p g ≤ cfgCost p := by
  unfold emlCFGCost cfgCost; omega

def snr (alpha_t : ℝ) : ℝ := alpha_t / (1 - alpha_t)

theorem snr_monotone (a1 a2 : ℝ) (h0 : 0 < a1) (h1 : a1 ≤ a2) (h2 : a2 < 1) :
    snr a1 ≤ snr a2 := by
  unfold snr
  rw [div_le_div_iff₀ (by linarith) (by linarith)]
  nlinarith

def stdEncoderParams (inputDim latentDim : ℕ) : ℕ := inputDim * latentDim

def emlEncoderParams (latentDim : ℕ) : ℕ := 4 * latentDim

theorem eml_encoder_efficiency (inputDim latentDim : ℕ) (h : 4 ≤ inputDim) :
    emlEncoderParams latentDim ≤ stdEncoderParams inputDim latentDim := by
  unfold emlEncoderParams stdEncoderParams; exact Nat.mul_le_mul_right latentDim h

def reconstructionBound (encoderError decoderError : ℝ) : ℝ := encoderError + decoderError

theorem better_encoder_better_elbo (e1 e2 d : ℝ) (he : e1 ≤ e2) :
    reconstructionBound e1 d ≤ reconstructionBound e2 d := by
  unfold reconstructionBound; linarith

theorem better_decoder_better_elbo (e d1 d2 : ℝ) (hd : d1 ≤ d2) :
    reconstructionBound e d1 ≤ reconstructionBound e d2 := by
  unfold reconstructionBound; linarith

def consistencyDistillCost (teacherCost studentCost numPairs : ℕ) : ℕ :=
  numPairs * (teacherCost + studentCost)

def emlConsistencyCost (teacherCost emlStudentCost numPairs : ℕ) : ℕ :=
  numPairs * (teacherCost + emlStudentCost)

theorem eml_consistency_cheaper (tCost sCost_eml sCost_std n : ℕ)
    (hs : sCost_eml ≤ sCost_std) :
    emlConsistencyCost tCost sCost_eml n ≤ consistencyDistillCost tCost sCost_std n := by
  unfold emlConsistencyCost consistencyDistillCost; exact Nat.mul_le_mul_left n (by omega)

def noisePredCost (d_model : ℕ) : ℕ := d_model * d_model

def emlNoisePredCost (d_model : ℕ) : ℕ := 4 * d_model

theorem eml_noise_pred_cheaper (d : ℕ) (hd : 4 ≤ d) :
    emlNoisePredCost d ≤ noisePredCost d := by
  unfold emlNoisePredCost noisePredCost; nlinarith

def linearSchedule (beta_min beta_max t : ℝ) : ℝ := beta_min + t * (beta_max - beta_min)

theorem linear_schedule_monotone (bmin bmax t1 t2 : ℝ) (hb : bmin ≤ bmax) (ht : t1 ≤ t2) :
    linearSchedule bmin bmax t1 ≤ linearSchedule bmin bmax t2 := by
  unfold linearSchedule; nlinarith

theorem linear_schedule_initial (bmin bmax : ℝ) : linearSchedule bmin bmax 0 = bmin := by
  unfold linearSchedule; ring

theorem linear_schedule_final (bmin bmax : ℝ) : linearSchedule bmin bmax 1 = bmax := by
  unfold linearSchedule; ring

theorem noise_schedule_le_one (β : ℝ) (t : ℕ) (hβ : 0 ≤ β) :
    noiseSchedule β t ≤ 1 := by
  unfold noiseSchedule
  rw [← Real.exp_zero]
  exact Real.exp_le_exp.mpr (by nlinarith [Nat.cast_nonneg (α := ℝ) t])

theorem noise_decays (β : ℝ) (t1 t2 : ℕ) (hβ : 0 < β) (ht : t1 ≤ t2) :
    noiseSchedule β t2 ≤ noiseSchedule β t1 := by
  unfold noiseSchedule
  exact Real.exp_le_exp.mpr (by nlinarith [Nat.cast_le (α := ℝ).mpr ht])

/-- [Section: ## §2. Score Network] -/
def stdScoreNetParams (channels depth d_model : ℕ) : ℕ :=
  depth * channels * d_model * d_model

def emlScoreNetParams (channels depth d_model : ℕ) : ℕ :=
  depth * channels * (4 * d_model)

theorem eml_score_net_compact (c dep dm : ℕ) (hd : 4 ≤ dm) :
    emlScoreNetParams c dep dm ≤ stdScoreNetParams c dep dm := by
  unfold emlScoreNetParams stdScoreNetParams
  calc dep * c * (4 * dm) = (dep * c) * (4 * dm) := by ring
    _ ≤ (dep * c) * (dm * dm) := Nat.mul_le_mul_left _ (by nlinarith)
    _ = dep * c * dm * dm := by ring

/-- [Section: ## §3. Denoising Steps] -/
def totalSamplingCost (numSteps modelParams : ℕ) : ℕ := numSteps * modelParams

theorem fewer_steps_cheaper (T1 T2 p : ℕ) (hT : T1 ≤ T2) :
    totalSamplingCost T1 p ≤ totalSamplingCost T2 p := by
  unfold totalSamplingCost; exact Nat.mul_le_mul_right p hT

/-- [Section: ## §5. Latent Diffusion] -/
def stdLatentEncoderParams (inputDim latentDim : ℕ) : ℕ := inputDim * latentDim

def emlLatentEncoderParams (latentDim : ℕ) : ℕ := 4 * latentDim

theorem eml_latent_encoder_compact (id ld : ℕ) (hi : 4 ≤ id) :
    emlLatentEncoderParams ld ≤ stdLatentEncoderParams id ld := by
  unfold emlLatentEncoderParams stdLatentEncoderParams
  exact Nat.mul_le_mul_right ld hi

/-- [Section: ## §6. Training Loss] -/
def denoisingLoss (prediction target : ℝ) : ℝ := (prediction - target) ^ 2

theorem denoising_loss_nonneg (p t : ℝ) : 0 ≤ denoisingLoss p t := by
  unfold denoisingLoss; exact sq_nonneg _

theorem denoising_loss_zero_iff_match (p t : ℝ) :
    denoisingLoss p t = 0 ↔ p = t := by
  unfold denoisingLoss; constructor
  · intro h; nlinarith [sq_nonneg (p - t)]
  · intro h; simp [h]

end
