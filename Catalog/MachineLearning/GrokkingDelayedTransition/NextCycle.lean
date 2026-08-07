import Mathlib
import MachineLearning.GrokkingDelayedTransition.GradientFlowThreshold
import MachineLearning.GrokkingDelayedTransition.VectorMargin

/-!
# Closing the three next-cycle sub-conjectures of the grokking thread

`FUTURE_DIRECTIONS.md` of the previous cycle listed three concrete sub-conjectures
(N1)–(N3), and a sharpness half for Conjecture 4.  This file resolves all of
them, building directly on the definitions of
`GrokkingDelayedTransition/GradientFlowThreshold.lean` and
`GrokkingDelayedTransition/VectorMargin.lean`.

* **(N1) Filter-level divergence of the delay.**  `crossTime_tendsto_atTop`:
  the crossing time of the weight-decayed gradient flow tends to `+∞` as the
  weight decay increases to its critical value `λ_c = s/θ`.  This upgrades the
  purely existential `crossTime_diverges_at_criticality` to a genuine limit
  statement along the filter `𝓝[<] λ_c`.

* **(N2) An exact `1/m` width law.**  `zeroBias_sharp_threshold`: for a network
  with vanishing hidden biases the *sandwich* `delay_scaling_sandwich` collapses
  to an **equality**, the sharp delay being exactly `|c| / S` with
  `S = ∑ⱼ aⱼ gⱼ` the total signal.  Specialized to a symmetric width-`m`
  network (`symNet_sharp_threshold`) this gives `τ(m) = |c| / (m a g)`, hence
  the exact width law `m · τ(m) = |c|/(a g)` (`symNet_delay_width_law`) and
  `τ(m) → 0` (`symNet_delay_tendsto_zero`).

* **(N3) Grokking can happen twice.**  `hatNet_failure_set` computes the failure
  set of an explicit *sign-indefinite* width-three network to be exactly
  `(-∞, 1/2] ∪ [3/2, ∞)`, and `hatNet_failure_not_convex` shows it is not
  convex.  So the nonnegativity of the output weights in `netRamp_convexOn` /
  `failure_set_convex` cannot be dropped: with signed output weights a network
  can grok, un-grok and re-grok.

* **Sharpness of the robustness bound.**  `perturbed_threshold_shift_exact`:
  the displacement `ε/κ` of `perturbed_delayed_transition` is attained by the
  constant perturbation `-ε`, so that bound is sharp.
-/

namespace GrokkingNextCycle

open Filter Topology Set

/-! ### (N1) The delay diverges, as a limit along `𝓝[<] λ_c` -/

open GrokkingTraining in
/-- **Filter-level divergence of the grokking delay (N1).**  As the weight decay
`λ` increases to its critical value `λ_c = s/θ`, the crossing time of the
weight-decayed gradient flow tends to `+∞`.  This is the limit form of
`crossTime_diverges_at_criticality`. -/
theorem crossTime_tendsto_atTop (s theta w0 : ℝ) (hs : 0 < s) (hth : 0 < theta)
    (hw0 : w0 < theta) :
    Tendsto (fun lam => crossTime lam s w0 theta)
      (𝓝[<] (criticalDecay s theta)) atTop := by
  set c : ℝ := criticalDecay s theta with hc
  have hcpos : 0 < c := by rw [hc, criticalDecay]; positivity
  have hden : 0 < 2 * theta - w0 := by linarith
  set a : ℝ := s / (2 * theta - w0) with ha
  have hapos : 0 < a := by rw [ha]; positivity
  have hac : a < c := by
    rw [ha, hc, criticalDecay]
    exact div_lt_div_of_pos_left hs hth (by linarith)
  have hIoo : Ioo a c ∈ 𝓝[<] c := Ioo_mem_nhdsLT hac
  -- Elementary facts valid on the punctured left neighbourhood `(a, c)`.
  have hfacts : ∀ lam ∈ Ioo a c,
      0 < lam ∧ theta < s / lam ∧ s / lam < 2 * theta - w0 := by
    rintro lam ⟨h1, h2⟩
    have hlam : 0 < lam := lt_trans hapos h1
    refine ⟨hlam, ?_, ?_⟩
    · rw [lt_div_iff₀ hlam]
      have : lam * theta < s := by
        rw [hc, criticalDecay] at h2
        exact (lt_div_iff₀ hth).mp h2
      linarith
    · rw [div_lt_iff₀ hlam]
      have : s < lam * (2 * theta - w0) := by
        rw [ha, div_lt_iff₀ hden] at h1
        linarith
      linarith
  -- The bifurcation parameter tends to `0` from above.
  have hval : s / c - theta = 0 := by
    rw [hc, criticalDecay]; field_simp; ring
  have hcont : Tendsto (fun lam => bifParam lam s theta) (𝓝[<] c) (𝓝 0) := by
    have hca : ContinuousAt (fun lam : ℝ => s / lam - theta) c :=
      (continuousAt_const.div continuousAt_id (ne_of_gt hcpos)).sub continuousAt_const
    have h := hca.tendsto.mono_left (nhdsWithin_le_nhds (s := Iio c))
    rw [hval] at h
    simpa only [bifParam] using h
  have hwithin : ∀ᶠ lam in 𝓝[<] c, bifParam lam s theta ∈ Ioi (0 : ℝ) := by
    filter_upwards [hIoo] with lam hlam
    have h := hfacts lam hlam
    simp only [bifParam, mem_Ioi]
    linarith [h.2.1]
  have hgt : Tendsto (fun lam => bifParam lam s theta) (𝓝[<] c) (𝓝[>] (0 : ℝ)) :=
    tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ hcont hwithin
  have hinv : Tendsto (fun lam => (bifParam lam s theta)⁻¹) (𝓝[<] c) atTop :=
    tendsto_inv_nhdsGT_zero.comp hgt
  have hnum : Tendsto (fun lam => (theta - w0) / bifParam lam s theta)
      (𝓝[<] c) atTop := by
    have h := Tendsto.const_mul_atTop (show (0 : ℝ) < theta - w0 by linarith) hinv
    simpa only [div_eq_mul_inv] using h
  have hlog : Tendsto
      (fun lam => Real.log ((theta - w0) / bifParam lam s theta)) (𝓝[<] c) atTop :=
    Real.tendsto_log_atTop.comp hnum
  have hmul : Tendsto
      (fun lam => (1 / c) * Real.log ((theta - w0) / bifParam lam s theta))
      (𝓝[<] c) atTop :=
    Tendsto.const_mul_atTop (by positivity) hlog
  refine tendsto_atTop_mono' _ ?_ hmul
  filter_upwards [hIoo] with lam hlam
  obtain ⟨hlampos, hthlt, hsmall⟩ := hfacts lam hlam
  have hbifpos : 0 < bifParam lam s theta := by
    simp only [bifParam]; linarith
  have hbifsmall : bifParam lam s theta ≤ theta - w0 := by
    simp only [bifParam]; linarith
  have hratio : 1 ≤ (theta - w0) / bifParam lam s theta := by
    rw [le_div_iff₀ hbifpos]; linarith
  have hlogpos : 0 ≤ Real.log ((theta - w0) / bifParam lam s theta) :=
    Real.log_nonneg hratio
  have hlb := crossTime_lower_bound lam s w0 theta hlampos hw0 hthlt
  have hcompare : (1 / c) * Real.log ((theta - w0) / bifParam lam s theta)
      ≤ (1 / lam) * Real.log ((theta - w0) / bifParam lam s theta) :=
    mul_le_mul_of_nonneg_right
      (one_div_le_one_div_of_le hlampos (le_of_lt hlam.2)) hlogpos
  exact le_trans hcompare hlb

/-! ### (N2) An exact delay formula, and the `1/m` width law -/

open GrokkingVector

/-- With vanishing hidden biases and nonnegative signals the ramped output is
*exactly* affine on nonnegative ramp times. -/
theorem netRamp_zeroBias_eq {m d : ℕ} (W : Fin m → Fin d → ℝ) (A : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (hsig : ∀ j, 0 ≤ signal W p j) {t : ℝ} (ht : 0 ≤ t) :
    netRamp W (fun _ => 0) A c p t = c + t * ∑ j, A j * signal W p j := by
  rw [netRamp_eq, Finset.mul_sum]
  congr 1
  refine Finset.sum_congr rfl fun j _ => ?_
  have hnn : 0 ≤ t * signal W p j := mul_nonneg ht (hsig j)
  have : relu (t * signal W p j + 0) = t * signal W p j := by
    simp only [relu, add_zero]
    exact max_eq_left hnn
  rw [this]; ring

/-- With vanishing hidden biases every hidden unit is silent at nonpositive ramp
times, so the output is the output bias. -/
theorem netRamp_zeroBias_nonpos {m d : ℕ} (W : Fin m → Fin d → ℝ) (A : Fin m → ℝ) (c : ℝ)
    (p : Fin d → ℝ) (hsig : ∀ j, 0 ≤ signal W p j) {t : ℝ} (ht : t ≤ 0) :
    netRamp W (fun _ => 0) A c p t = c := by
  rw [netRamp_eq]
  have h0 : ∀ j ∈ (Finset.univ : Finset (Fin m)),
      A j * relu (t * signal W p j + 0) = 0 := by
    intro j _
    have hle : t * signal W p j + 0 ≤ 0 := by
      have := mul_nonpos_of_nonpos_of_nonneg ht (hsig j)
      linarith
    rw [relu_of_nonpos hle, mul_zero]
  rw [Finset.sum_eq_zero h0, add_zero]

/-- **Exact delay formula (the sandwich collapses).**  For a two-layer ReLU
network with vanishing hidden biases, nonnegative output weights, nonnegative
signals, negative output bias `c` and positive total signal
`S = ∑ⱼ aⱼ gⱼ`, the sharp delay is *exactly* `|c| / S`. -/
theorem zeroBias_sharp_threshold {m d : ℕ} (W : Fin m → Fin d → ℝ) (A : Fin m → ℝ)
    (c : ℝ) (p : Fin d → ℝ) (hsig : ∀ j, 0 ≤ signal W p j) (hc : c < 0)
    (hS : 0 < ∑ j, A j * signal W p j) :
    (∀ t ≤ -c / (∑ j, A j * signal W p j), netRamp W (fun _ => 0) A c p t ≤ 0) ∧
      (∀ t, -c / (∑ j, A j * signal W p j) < t →
        0 < netRamp W (fun _ => 0) A c p t) := by
  set S : ℝ := ∑ j, A j * signal W p j with hSdef
  constructor
  · intro t ht
    rcases le_or_gt t 0 with h0 | h0
    · rw [netRamp_zeroBias_nonpos W A c p hsig h0]; linarith
    · rw [netRamp_zeroBias_eq W A c p hsig h0.le]
      have : t * S ≤ -c := by
        rw [le_div_iff₀ hS] at ht; linarith
      linarith
  · intro t ht
    have hpos : 0 < -c / S := div_pos (by linarith) hS
    have h0 : 0 < t := lt_trans hpos ht
    rw [netRamp_zeroBias_eq W A c p hsig h0.le]
    have : -c < t * S := by
      rw [div_lt_iff₀ hS] at ht; linarith
    linarith

/-- The symmetric width-`m` network: `m` identical hidden units with weight `g`,
zero hidden bias and output weight `A`, output bias `c`, probed along the ramp
`t ↦ t`. -/
noncomputable def symNet (m : ℕ) (A g c : ℝ) : ℝ → ℝ :=
  netRamp (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ => 0) (fun _ => A) c
    (fun _ : Fin 1 => 1)

/-- Every hidden unit of the symmetric network has signal `g`. -/
theorem symNet_signal (m : ℕ) (g : ℝ) (j : Fin m) :
    signal (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ : Fin 1 => (1 : ℝ)) j = g := by
  simp [signal]

/-- Total signal of the symmetric width-`m` network. -/
theorem symNet_totalSignal (m : ℕ) (A g : ℝ) :
    ∑ _j : Fin m, A * g = (m : ℝ) * (A * g) := by
  simp [Finset.sum_const, nsmul_eq_mul]

/-- The delay of the symmetric width-`m` network. -/
noncomputable def symDelay (m : ℕ) (A g c : ℝ) : ℝ := -c / ((m : ℝ) * (A * g))

/-- **Sharp delay of the symmetric width-`m` network.** -/
theorem symNet_sharp_threshold (m : ℕ) (A g c : ℝ) (hm : 0 < m) (hA : 0 < A)
    (hg : 0 < g) (hc : c < 0) :
    (∀ t ≤ symDelay m A g c, symNet m A g c t ≤ 0) ∧
      (∀ t, symDelay m A g c < t → 0 < symNet m A g c t) := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hsig : ∀ j : Fin m,
      0 ≤ signal (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ : Fin 1 => (1 : ℝ)) j := by
    intro j; rw [symNet_signal]; exact hg.le
  have hsum : (∑ j : Fin m, (fun _ : Fin m => A) j *
      signal (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ : Fin 1 => (1 : ℝ)) j)
      = (m : ℝ) * (A * g) := by
    have : ∀ j : Fin m, (fun _ : Fin m => A) j *
        signal (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ : Fin 1 => (1 : ℝ)) j = A * g := by
      intro j; rw [symNet_signal]
    rw [Finset.sum_congr rfl fun j _ => this j, symNet_totalSignal]
  have hS : 0 < ∑ j : Fin m, (fun _ : Fin m => A) j *
      signal (fun _ : Fin m => fun _ : Fin 1 => g) (fun _ : Fin 1 => (1 : ℝ)) j := by
    rw [hsum]; positivity
  have h := zeroBias_sharp_threshold (fun _ : Fin m => fun _ : Fin 1 => g)
    (fun _ => A) c (fun _ : Fin 1 => 1) hsig hc hS
  rw [hsum] at h
  exact h

/-- **Exact `1/m` width law (N2).**  The delay of the symmetric width-`m`
network is inversely proportional to the width: `m · τ(m)` does not depend on
`m`. -/
theorem symNet_delay_width_law (m : ℕ) (A g c : ℝ) (hm : 0 < m) (hA : 0 < A) (hg : 0 < g) :
    (m : ℝ) * symDelay m A g c = -c / (A * g) := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hAg : A * g ≠ 0 := by positivity
  simp only [symDelay]
  field_simp

/-- The delay of the symmetric network vanishes as the width grows. -/
theorem symNet_delay_tendsto_zero (A g c : ℝ) (hA : 0 < A) (hg : 0 < g) :
    Tendsto (fun m : ℕ => symDelay m A g c) atTop (𝓝 0) := by
  have hAg : (0 : ℝ) < A * g := by positivity
  have hrw : (fun m : ℕ => symDelay m A g c)
      = fun m : ℕ => (-c / (A * g)) / (m : ℝ) := by
    funext m
    simp only [symDelay]
    rw [div_div, mul_comm]
  rw [hrw]
  exact tendsto_const_div_atTop_nhds_zero_nat _

/-! ### (N3) A sign-indefinite network that groks twice -/

/-- Hidden weights of the "hat" network: three units, one input dimension. -/
def hatW : Fin 3 → Fin 1 → ℝ := fun _ _ => 1

/-- Hidden biases `0, -1, -2` of the hat network. -/
def hatB : Fin 3 → ℝ := ![0, -1, -2]

/-- **Sign-indefinite** output weights `1, -2, 1` of the hat network. -/
def hatA : Fin 3 → ℝ := ![1, -2, 1]

/-- The hat network has a negative output weight; the hypothesis `∀ j, 0 ≤ a j`
of `netRamp_convexOn` therefore fails for it. -/
theorem hatA_sign_indefinite : hatA 1 < 0 ∧ 0 < hatA 0 := by
  constructor <;> simp [hatA]

/-- The hat network: output bias `-1/2`, probed along the ramp `t ↦ t`. -/
noncomputable def hatNet : ℝ → ℝ :=
  netRamp hatW hatB hatA (-1 / 2) (fun _ : Fin 1 => 1)

theorem hatNet_eq (t : ℝ) :
    hatNet t = -1 / 2 + (relu t - 2 * relu (t - 1) + relu (t - 2)) := by
  have hsig : ∀ j : Fin 3, signal hatW (fun _ : Fin 1 => (1 : ℝ)) j = 1 := by
    intro j; simp [signal, hatW]
  rw [hatNet, netRamp_eq]
  rw [Fin.sum_univ_three]
  rw [hsig 0, hsig 1, hsig 2]
  have e0 : t * 1 + hatB 0 = t := by simp [hatB]
  have e1 : t * 1 + hatB 1 = t - 1 := by simp [hatB]; ring
  have e2 : t * 1 + hatB 2 = t - 2 := by simp [hatB, Matrix.cons_val]; ring
  rw [e0, e1, e2]
  simp [hatA, Matrix.cons_val]
  ring

/-- **The failure set of a sign-indefinite network need not be an interval
(N3).**  For the hat network it is exactly `(-∞, 1/2] ∪ [3/2, ∞)`: the network
groks at time `1/2`, un-groks at time `3/2`, and never recovers. -/
theorem hatNet_failure_set :
    {t : ℝ | hatNet t ≤ 0} = Iic (1 / 2 : ℝ) ∪ Ici (3 / 2 : ℝ) := by
  ext t
  simp only [mem_setOf_eq, mem_union, mem_Iic, mem_Ici, hatNet_eq]
  rcases le_total t 0 with h0 | h0
  · rw [relu_of_nonpos h0, relu_of_nonpos (by linarith : t - 1 ≤ 0),
      relu_of_nonpos (by linarith : t - 2 ≤ 0)]
    constructor
    · intro _; left; linarith
    · intro _; norm_num
  · have hr0 : relu t = t := max_eq_left h0
    rcases le_total t 1 with h1 | h1
    · rw [hr0, relu_of_nonpos (by linarith : t - 1 ≤ 0),
        relu_of_nonpos (by linarith : t - 2 ≤ 0)]
      constructor
      · intro h; left; linarith
      · rintro (h | h) <;> linarith
    · have hr1 : relu (t - 1) = t - 1 := max_eq_left (by linarith)
      rcases le_total t 2 with h2 | h2
      · rw [hr0, hr1, relu_of_nonpos (by linarith : t - 2 ≤ 0)]
        constructor
        · intro h; right; linarith
        · rintro (h | h) <;> linarith
      · have hr2 : relu (t - 2) = t - 2 := max_eq_left (by linarith)
        rw [hr0, hr1, hr2]
        constructor
        · intro _; right; linarith
        · intro _; linarith

/-- The failure set of the hat network is **not** convex: the network fails at
times `0` and `2` but succeeds at the intermediate time `1`.  Hence the
nonnegativity assumption on the output weights in `failure_set_convex` is
necessary. -/
theorem hatNet_failure_not_convex : ¬ Convex ℝ {t : ℝ | hatNet t ≤ 0} := by
  intro hconv
  have h0 : (0 : ℝ) ∈ {t : ℝ | hatNet t ≤ 0} := by
    rw [hatNet_failure_set]; left; norm_num
  have h2 : (2 : ℝ) ∈ {t : ℝ | hatNet t ≤ 0} := by
    rw [hatNet_failure_set]; right; norm_num
  have hmid := hconv h0 h2 (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2)
    (by norm_num)
  have h1 : (1 : ℝ) ∈ {t : ℝ | hatNet t ≤ 0} := by
    simpa using hmid
  rw [hatNet_failure_set] at h1
  rcases h1 with h | h <;> norm_num at h

/-- The hat network is positive on the whole open window `(1/2, 3/2)`: it does
generalize there, before relapsing. -/
theorem hatNet_pos_on_window {t : ℝ} (h1 : 1 / 2 < t) (h2 : t < 3 / 2) : 0 < hatNet t := by
  by_contra hcon
  push_neg at hcon
  have : t ∈ {s : ℝ | hatNet s ≤ 0} := hcon
  rw [hatNet_failure_set] at this
  rcases this with h | h <;> [exact absurd h (not_le.mpr h1); exact absurd h (not_le.mpr h2)]

/-! ### Sharpness of the robustness displacement bound -/

/-- A trajectory with exact linear growth `κ(t - τ)` after its threshold `τ`. -/
noncomputable def linTraj (kappa tau : ℝ) : ℝ → ℝ := fun t => kappa * (t - tau)

/-- The constant `-ε` perturbation of `linTraj`. -/
noncomputable def linTrajPerturbed (kappa tau eps : ℝ) : ℝ → ℝ :=
  fun t => kappa * (t - tau) - eps

/-- **The `ε/κ` displacement bound of `perturbed_delayed_transition` is
sharp.**  The exactly-linear trajectory satisfies all its hypotheses, and its
constant `-ε` perturbation has sharp threshold exactly `τ + ε/κ`. -/
theorem perturbed_threshold_shift_exact (kappa tau eps : ℝ) (hkappa : 0 < kappa)
    (heps : 0 ≤ eps) :
    (∀ t, |linTrajPerturbed kappa tau eps t - linTraj kappa tau t| ≤ eps) ∧
      (∀ t ≤ tau, linTraj kappa tau t ≤ 0) ∧
      (∀ t, tau < t → kappa * (t - tau) ≤ linTraj kappa tau t) ∧
      (∀ t ≤ tau + eps / kappa, linTrajPerturbed kappa tau eps t ≤ 0) ∧
      (∀ t, tau + eps / kappa < t → 0 < linTrajPerturbed kappa tau eps t) := by
  refine ⟨fun t => ?_, fun t ht => ?_, fun t _ => le_rfl, fun t ht => ?_, fun t ht => ?_⟩
  · simp only [linTrajPerturbed, linTraj]
    rw [show kappa * (t - tau) - eps - kappa * (t - tau) = -eps by ring, abs_neg,
      abs_of_nonneg heps]
  · simp only [linTraj]
    nlinarith
  · simp only [linTrajPerturbed]
    have h : t - tau ≤ eps / kappa := by linarith
    have := (le_div_iff₀ hkappa).mp h
    nlinarith
  · simp only [linTrajPerturbed]
    have h : eps / kappa < t - tau := by linarith
    have := (div_lt_iff₀ hkappa).mp h
    nlinarith

/-- The perturbed threshold of `perturbed_threshold_shift_exact` is *strictly*
later than the unperturbed one whenever `ε > 0`: the displacement `ε/κ` really
occurs. -/
theorem perturbed_threshold_strictly_later (kappa tau eps : ℝ) (hkappa : 0 < kappa)
    (heps : 0 < eps) : tau < tau + eps / kappa := by
  have : 0 < eps / kappa := div_pos heps hkappa
  linarith

end GrokkingNextCycle