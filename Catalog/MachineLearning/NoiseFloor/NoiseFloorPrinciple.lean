/-
# The Noise-Floor Principle, Part II: the universal floor of spectral learning

Round-6 hypothesis closure, Phase A.

A *spectral filter* is the abstract form of every linear estimator that acts
diagonally in the eigenbasis of the data covariance: ridge regression, spectral
cut-off (PCA regression), gradient-flow early stopping, Tikhonov-type shrinkage,
kernel smoothing.  Writing `a i ≥ 0` for the signal power in mode `i` and `b > 0`
for the per-mode noise power (`b = σ²/N` in the usual fixed-design regression
normalisation), the excess risk of the filter `t : ι → ℝ` is

  `filterRisk a b t = ∑ i, (a i * (1 - t i)^2 + b * (t i)^2)`
                       ^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^^^
                            bias                 variance

**The Noise-Floor Principle.** No spectral filter whatsoever — not just no ridge
parameter — can push the risk below

  `noiseFloor a b = b * effDim a b = ∑ i, a i * b / (a i + b)`,

and the bound is attained by exactly one filter, the Wiener filter
`t i = b / (a i + b)`.  Thus *the minimal achievable risk equals the noise level
times the effective dimension of the signal spectrum at that noise level*: the
trace functional of Part I is not merely an upper bound device, it is the exact
value of an optimisation problem.

## Main results

* `mode_gap_identity`        — the exact per-mode excess `((a+b)t - b)²/(a+b)`
* `filterRisk_ge_noiseFloor` — the noise-floor lower bound, for every filter
* `filterRisk_wiener`        — attainment by the Wiener filter
* `isLeast_filterRisk`       — the floor *is* the minimum of the risk functional
* `filterRisk_eq_noiseFloor_iff` — uniqueness of the optimal filter
* `noiseFloor_eq_sum`, `noiseFloor_le_min`, `half_count_le_noiseFloor`
* `noiseFloor_mono_level`, `noiseFloor_doubling` — the sample-size scaling law:
  the floor is monotone in the noise level and halving the data at most doubles it
* `ridge_optimal_iff_self_similar` — ridge attains the floor **iff** the spectrum
  satisfies the self-similarity relation `a i * μ i = b * λ` for all `i`
* `ridge_strict_gap_two_modes` — an explicit two-mode spectrum on which *every*
  ridge/constant filter is at least `4/3` times the floor: the frontier is strict.
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension

namespace Catalog.MachineLearning.NoiseFloor

open Finset

variable {ι : Type*} [Fintype ι]

/-- Excess risk of the diagonal (spectral) filter `t` against signal spectrum `a`
at noise level `b`: bias `a i (1 - t i)²` plus variance `b (t i)²`. -/
noncomputable def filterRisk (a : ι → ℝ) (b : ℝ) (t : ι → ℝ) : ℝ :=
  ∑ i, (a i * (1 - t i) ^ 2 + b * (t i) ^ 2)

/-- The Wiener (Bayes-optimal) filter for spectrum `a` at noise level `b`:
shrinkage by the per-mode signal-to-total ratio. -/
noncomputable def wienerFilter (a : ι → ℝ) (b : ℝ) : ι → ℝ := fun i => a i / (a i + b)

/-- The **noise floor**: noise level times effective dimension. -/
noncomputable def noiseFloor (a : ι → ℝ) (b : ℝ) : ℝ := b * effDim a b

/-- The ridge filter with regularisation `lam` for a covariance spectrum `mu`. -/
noncomputable def ridgeFilter (mu : ι → ℝ) (lam : ℝ) : ι → ℝ := fun i => mu i / (mu i + lam)

section Mode

variable {x b : ℝ}

/-- **Exact per-mode gap identity.**  The whole principle rests on this completed
square: the risk of a mode exceeds `x b /(x + b)` by exactly
`((x+b) t - b)² / (x+b)`. -/
lemma mode_gap_identity (hx : 0 ≤ x) (hb : 0 < b) (t : ℝ) :
    x * (1 - t) ^ 2 + b * t ^ 2 - x * b / (x + b) = ((x + b) * t - x) ^ 2 / (x + b) := by
  have hd : 0 < x + b := by linarith
  field_simp
  ring

/-- Per-mode noise floor. -/
lemma mode_risk_ge (hx : 0 ≤ x) (hb : 0 < b) (t : ℝ) :
    x * b / (x + b) ≤ x * (1 - t) ^ 2 + b * t ^ 2 := by
  have hd : 0 < x + b := by linarith
  have h := mode_gap_identity hx hb t
  have : 0 ≤ ((x + b) * t - x) ^ 2 / (x + b) := by positivity
  linarith

/-- Per-mode attainment by the Wiener coefficient. -/
lemma mode_risk_wiener (hx : 0 ≤ x) (hb : 0 < b) :
    x * (1 - x / (x + b)) ^ 2 + b * (x / (x + b)) ^ 2 = x * b / (x + b) := by
  have hd : 0 < x + b := by linarith
  field_simp
  ring

/-- Off the Wiener coefficient the per-mode inequality is strict. -/
lemma mode_risk_gt (hx : 0 ≤ x) (hb : 0 < b) {t : ℝ} (ht : t ≠ x / (x + b)) :
    x * b / (x + b) < x * (1 - t) ^ 2 + b * t ^ 2 := by
  have hd : 0 < x + b := by linarith
  have hne : (x + b) * t - x ≠ 0 := by
    intro h
    apply ht
    field_simp
    linarith
  have hpos : 0 < ((x + b) * t - x) ^ 2 / (x + b) := by positivity
  have h := mode_gap_identity hx hb t
  linarith

end Mode

section Floor

variable {a : ι → ℝ} {b : ℝ}

/-- The noise floor as a sum of per-mode harmonic terms. -/
lemma noiseFloor_eq_sum (a : ι → ℝ) (b : ℝ) :
    noiseFloor a b = ∑ i, a i * b / (a i + b) := by
  rw [noiseFloor, effDim, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **The Noise-Floor Principle.**  No spectral filter — ridge, spectral cut-off,
early stopping, or anything else diagonal — achieves risk below the floor. -/
theorem filterRisk_ge_noiseFloor (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (t : ι → ℝ) :
    noiseFloor a b ≤ filterRisk a b t := by
  rw [noiseFloor_eq_sum]
  exact Finset.sum_le_sum fun i _ => mode_risk_ge (ha i) hb (t i)

/-- **Attainment.**  The Wiener filter meets the floor exactly. -/
theorem filterRisk_wiener (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    filterRisk a b (wienerFilter a b) = noiseFloor a b := by
  rw [noiseFloor_eq_sum, filterRisk]
  exact Finset.sum_congr rfl fun i _ => mode_risk_wiener (ha i) hb

/-- The noise floor **is** the minimum of the risk functional over all spectral
filters: an exact variational characterisation of `b · d_eff`. -/
theorem isLeast_filterRisk (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    IsLeast (Set.range (filterRisk a b)) (noiseFloor a b) :=
  ⟨⟨wienerFilter a b, filterRisk_wiener ha hb⟩, by
    rintro r ⟨t, rfl⟩; exact filterRisk_ge_noiseFloor ha hb t⟩

/-- **Uniqueness of the optimal filter.**  The Wiener filter is the *only*
minimiser; every other spectral filter is strictly suboptimal. -/
theorem filterRisk_eq_noiseFloor_iff (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (t : ι → ℝ) :
    filterRisk a b t = noiseFloor a b ↔ t = wienerFilter a b := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨j, hj⟩ : ∃ j, t j ≠ wienerFilter a b j := by
      by_contra hall
      exact hne (funext fun i => not_not.1 fun hi => hall ⟨i, hi⟩)
    have hstrict : ∑ i, a i * b / (a i + b) < filterRisk a b t := by
      refine Finset.sum_lt_sum (fun i _ => mode_risk_ge (ha i) hb (t i)) ⟨j, mem_univ j, ?_⟩
      exact mode_risk_gt (ha j) hb hj
    rw [← noiseFloor_eq_sum, h] at hstrict
    exact lt_irrefl _ hstrict
  · rintro rfl
    exact filterRisk_wiener ha hb

end Floor

section Bounds

variable {a : ι → ℝ} {b : ℝ}

lemma noiseFloor_nonneg (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) : 0 ≤ noiseFloor a b :=
  mul_nonneg hb.le (effDim_nonneg ha hb)

/-- **Trace/dimension sandwich**: the floor never exceeds either the total signal
power or `n` times the noise level. -/
theorem noiseFloor_le_min (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    noiseFloor a b ≤ min (∑ i, a i) ((Fintype.card ι : ℝ) * b) := by
  refine le_min ?_ ?_
  · have := effDim_le_trace_div ha hb
    have : b * effDim a b ≤ b * ((∑ i, a i) / b) := by
      exact mul_le_mul_of_nonneg_left this hb.le
    rwa [mul_div_cancel₀ _ hb.ne'] at this
  · have h := effDim_le_card ha hb
    have : b * effDim a b ≤ b * (Fintype.card ι : ℝ) := mul_le_mul_of_nonneg_left h hb.le
    rw [noiseFloor]
    linarith [this]

/-- **Counting form of the noise-floor principle.**  Every mode whose power
exceeds the noise level costs at least `b/2` of irreducible risk: learning
`k` resolvable modes costs at least `k b / 2`. -/
theorem half_count_le_noiseFloor [DecidableEq ι] (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    b / 2 * ((univ.filter fun i => b ≤ a i).card : ℝ) ≤ noiseFloor a b := by
  have h := count_le_two_mul_effDim ha hb
  have := mul_le_mul_of_nonneg_left h (by positivity : (0:ℝ) ≤ b / 2)
  rw [noiseFloor]
  nlinarith [this]

/-- The floor grows with the signal spectrum. -/
theorem noiseFloor_mono_spectrum {a a' : ι → ℝ} (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (h : ∀ i, a i ≤ a' i) : noiseFloor a b ≤ noiseFloor a' b :=
  mul_le_mul_of_nonneg_left (effDim_mono_spectrum ha hb h) hb.le

/-- **Sample-size monotonicity.**  More data (smaller `b`) never raises the
floor. -/
theorem noiseFloor_mono_level (ha : ∀ i, 0 ≤ a i) {b₁ b₂ : ℝ} (hb₁ : 0 < b₁) (h : b₁ ≤ b₂) :
    noiseFloor a b₁ ≤ noiseFloor a b₂ := by
  rw [noiseFloor_eq_sum, noiseFloor_eq_sum]
  refine Finset.sum_le_sum fun i _ => ?_
  have h1 : 0 < a i + b₁ := by have := ha i; linarith
  have h2 : 0 < a i + b₂ := by have := ha i; linarith
  rw [div_le_div_iff₀ h1 h2]
  nlinarith [mul_nonneg (mul_nonneg (ha i) (ha i)) (sub_nonneg.2 h)]

/-- **Scaling law with doubling control.**  Halving the amount of data (doubling
the noise level) at most doubles the noise floor — the learning curve has no
cliff.  Combined with `noiseFloor_mono_level` this pins the floor between `N⁻¹`
and `N⁻¹`-times-a-constant behaviour on dyadic scales. -/
theorem noiseFloor_doubling (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) :
    noiseFloor a (2 * b) ≤ 2 * noiseFloor a b := by
  rw [noiseFloor_eq_sum, noiseFloor_eq_sum, Finset.mul_sum]
  refine Finset.sum_le_sum fun i _ => ?_
  have h1 : 0 < a i + 2 * b := by have := ha i; linarith
  have h2 : 0 < a i + b := by have := ha i; linarith
  have hrw : 2 * (a i * b / (a i + b)) = (2 * (a i * b)) / (a i + b) := by ring
  rw [hrw, div_le_div_iff₀ h1 h2]
  nlinarith [mul_nonneg (ha i) (mul_nonneg hb.le hb.le)]

/-- **Mixing bound.**  The floor is concave in the signal spectrum: averaging two
tasks cannot make the pooled task easier than the average of the two floors. -/
theorem noiseFloor_concave {a a' : ι → ℝ} (ha : ∀ i, 0 ≤ a i) (ha' : ∀ i, 0 ≤ a' i)
    (hb : 0 < b) {w : ℝ} (hw₀ : 0 ≤ w) (hw₁ : w ≤ 1) :
    w * noiseFloor a b + (1 - w) * noiseFloor a' b
      ≤ noiseFloor (fun i => w * a i + (1 - w) * a' i) b := by
  have h := effDim_concave ha ha' hb hw₀ hw₁
  have := mul_le_mul_of_nonneg_left h hb.le
  simp only [noiseFloor]
  nlinarith [this]

end Bounds

section Ridge

variable {a mu : ι → ℝ} {b lam : ℝ}

/-- Ridge regression obeys the noise-floor principle. -/
theorem ridge_ge_noiseFloor (ha : ∀ i, 0 ≤ a i) (hb : 0 < b) (mu : ι → ℝ) (lam : ℝ) :
    noiseFloor a b ≤ filterRisk a b (ridgeFilter mu lam) :=
  filterRisk_ge_noiseFloor ha hb _

/-- **Ridge optimality is a rigid spectral condition.**  For a positive covariance
spectrum `mu` and positive `lam`, the ridge filter attains the noise floor if and
only if the *isotropy relation* `a i * lam = mu i * b` holds in every mode.
(With `a i = θ i ^ 2 * mu i` this says exactly that the prior is isotropic,
`θ i ^ 2 ≡ b / lam`: ridge is Bayes-optimal precisely for a flat prior.) -/
theorem ridge_optimal_iff_self_similar (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (hmu : ∀ i, 0 < mu i) (hlam : 0 < lam) :
    filterRisk a b (ridgeFilter mu lam) = noiseFloor a b ↔ ∀ i, a i * lam = mu i * b := by
  rw [filterRisk_eq_noiseFloor_iff ha hb]
  constructor
  · intro h i
    have hi : mu i / (mu i + lam) = a i / (a i + b) := congrFun h i
    have h1 : 0 < mu i + lam := by have := hmu i; linarith
    have h2 : 0 < a i + b := by have := ha i; linarith
    rw [div_eq_div_iff h1.ne' h2.ne'] at hi
    nlinarith [hi]
  · intro h
    funext i
    have hi := h i
    have h1 : 0 < mu i + lam := by have := hmu i; linarith
    have h2 : 0 < a i + b := by have := ha i; linarith
    show mu i / (mu i + lam) = a i / (a i + b)
    rw [div_eq_div_iff h1.ne' h2.ne']
    nlinarith [hi]

/-- Total risk of a *constant* filter on the two-mode spectrum `a = (1, 0)` with
`b = 1`.  Ridge on a flat covariance spectrum produces exactly these filters. -/
lemma two_mode_const_risk (c : ℝ) :
    filterRisk (![1, 0] : Fin 2 → ℝ) 1 (fun _ => c) = (1 - c) ^ 2 + 2 * c ^ 2 := by
  simp [filterRisk, Fin.sum_univ_two]
  ring

lemma two_mode_noiseFloor : noiseFloor (![1, 0] : Fin 2 → ℝ) 1 = 1 / 2 := by
  rw [noiseFloor_eq_sum]
  simp [Fin.sum_univ_two]
  norm_num

/-- **The ridge frontier is strict.**  On the spectrum `a = (1,0)` with a flat
covariance `mu = (1,1)` and noise level `b = 1`, *every* ridge parameter (indeed
every constant filter, which is what a flat spectrum forces ridge to be) suffers
risk at least `4/3` times the noise floor.  Hence the Wiener optimum of
`filterRisk_wiener` is genuinely outside the ridge family: regularisation by a
single scalar is provably lossy. -/
theorem ridge_strict_gap_two_modes (c : ℝ) :
    4 / 3 * noiseFloor (![1, 0] : Fin 2 → ℝ) 1
      ≤ filterRisk (![1, 0] : Fin 2 → ℝ) 1 (fun _ => c) := by
  rw [two_mode_const_risk, two_mode_noiseFloor]
  nlinarith [sq_nonneg (3 * c - 1)]

/-- The gap of `ridge_strict_gap_two_modes` is attained: `c = 1/3` gives exactly
`2/3 = (4/3) · (1/2)`, so the constant `4/3` is sharp. -/
theorem ridge_gap_sharp :
    filterRisk (![1, 0] : Fin 2 → ℝ) 1 (fun _ => (1 : ℝ) / 3)
      = 4 / 3 * noiseFloor (![1, 0] : Fin 2 → ℝ) 1 := by
  rw [two_mode_const_risk, two_mode_noiseFloor]
  norm_num

/-- On this spectrum the true optimum is *not* constant: the Wiener filter is
`(1/2, 0)`. -/
theorem two_mode_wiener_not_constant :
    wienerFilter (![1, 0] : Fin 2 → ℝ) 1 0 ≠ wienerFilter (![1, 0] : Fin 2 → ℝ) 1 1 := by
  simp [wienerFilter]

end Ridge

section Threshold

variable {b : ℝ}

/-- The threshold in its raw scalar form: `αb/(α+b) ≥ b/2 ↔ α ≥ b`. -/
theorem mode_half_threshold (α : ℝ) (hα : 0 ≤ α) (hb : 0 < b) :
    b / 2 ≤ α * b / (α + b) ↔ b ≤ α := by
  have hd : 0 < α + b := by linarith
  rw [div_le_div_iff₀ (by norm_num) hd]
  constructor
  · intro h; nlinarith
  · intro h; nlinarith

/-- Constant spectra: the floor is `n · αb/(α+b)`. -/
lemma noiseFloor_const (α : ℝ) :
    noiseFloor (fun _ : ι => α) b = (Fintype.card ι : ℝ) * (α * b / (α + b)) := by
  rw [noiseFloor_eq_sum]
  simp [Finset.card_univ, Finset.sum_const, nsmul_eq_mul]

/-- **Sharp signal-to-noise threshold.**  For a flat spectrum the floor reaches
half of its saturation value `n·b` exactly when the per-mode signal power reaches
the noise level: a genuine phase transition at SNR `= 1`. -/
theorem noiseFloor_const_half_saturation_iff [Nonempty ι] (α : ℝ) (hα : 0 ≤ α) (hb : 0 < b) :
    ((Fintype.card ι : ℝ) * b / 2 ≤ noiseFloor (fun _ : ι => α) b) ↔ b ≤ α := by
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    exact_mod_cast Fintype.card_pos
  rw [noiseFloor_const α, ← mode_half_threshold α hα hb]
  constructor
  · intro h
    have h' : (Fintype.card ι : ℝ) * (b / 2) ≤ (Fintype.card ι : ℝ) * (α * b / (α + b)) := by
      linarith
    exact (mul_le_mul_iff_of_pos_left hcard).1 h'
  · intro h
    have := (mul_le_mul_iff_of_pos_left hcard).2 h
    linarith

end Threshold

end Catalog.MachineLearning.NoiseFloor