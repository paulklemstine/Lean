/-
# Free-energy duality, annealing limits, and the exact PTX regression law

Second file of the neurosymbolic RLHF thread.  It builds on the catalog
definitions of `Speculative/AutoResearch/NeuroSymbolicRLHFObjective.lean`
(`tiltZ`, `gibbs`, `freeEnergy`, `rlhfObj`, `ptxTerm`) and on the oscillation
seminorm `oscil` introduced in `MachineLearning/RLHFHilbertIsometry.lean`.

Three independent layers, all about the *value function*
`F(β, r) = β log Z = max_p [𝔼_p r - β KL(p ‖ ref)]` of the InstructGPT
objective:

* **Level A — Legendre / Danskin duality (`hasDerivAt_freeEnergy`).**
  The directional derivative of the free energy with respect to the reward is
  the expectation of the direction under the *optimal* (tilted) policy:
  `d/dt|₀ F(β, r + t s) = 𝔼_{π_β(r)}[s]`.
  So the aligned policy is literally the gradient of the alignment value —
  an envelope theorem for RLHF.

* **Level B — annealing (thermodynamic limits).**
  Zero temperature: `max r + β log (min ref) ≤ F(β,r) ≤ max r`, hence
  `F(β,r) → max r` as `β → 0⁺` (reward maximisation, policy collapse).
  Infinite temperature: `0 ≤ F(β,r) - 𝔼_ref[r] ≤ (3/4)‖r‖_∞²/β` for
  `β ≥ ‖r‖_∞`, hence `F(β,r) → 𝔼_ref[r]` as `β → ∞` (the SFT model).
  Both limits come with explicit rates.

* **Level C — the exact PTX regression law (`ptx_at_gibbs`).**
  Evaluating the pre-training mix-in at the aligned policy gives the *identity*
  `𝔼_pre[log π_β(r)] = 𝔼_pre[log ref] + (𝔼_pre[r] - F(β,r))/β`.
  Hence RLHF regresses on the pre-training distribution exactly when the
  pre-training data scores below the free-energy level, and the regression is
  never worse than `γ · oscil r / β` — the same `1/β` scale that governs the
  Hilbert-metric drift of the policy itself.

No `sorry`, no `native_decide`.
-/
import MachineLearning.RLHFHilbertIsometry

open Finset Real BigOperators Filter Topology

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Level A: the free energy is the potential of the aligned policy -/

omit [Nonempty ι] in
/-- Derivative of the partition function along a reward perturbation. -/
theorem hasDerivAt_tiltZ (β : ℝ) (ref r s : ι → ℝ) :
    HasDerivAt (fun t : ℝ => tiltZ β ref (fun i => r i + t * s i))
      (∑ i, ref i * Real.exp (r i / β) * (s i / β)) 0 := by
  have hterm : ∀ i ∈ (univ : Finset ι),
      HasDerivAt (fun t : ℝ => ref i * Real.exp ((r i + t * s i) / β))
        (ref i * Real.exp (r i / β) * (s i / β)) 0 := by
    intro i _
    have h1 : HasDerivAt (fun t : ℝ => (r i + t * s i) / β) (s i / β) 0 := by
      have h0 : HasDerivAt (fun t : ℝ => r i + t * s i) (s i) 0 := by
        simpa using ((hasDerivAt_id (0 : ℝ)).mul_const (s i)).const_add (r i)
      simpa using h0.div_const β
    have h2 := (h1.exp).const_mul (ref i)
    simpa [← mul_assoc] using h2
  have hsum := HasDerivAt.sum hterm
  have hfun : (∑ i : ι, fun t : ℝ => ref i * Real.exp ((r i + t * s i) / β))
      = fun t : ℝ => tiltZ β ref (fun i => r i + t * s i) := by
    funext t
    simp [tiltZ, Finset.sum_apply]
  rwa [hfun] at hsum

/-- **Legendre / Danskin duality for RLHF.**  The reward-gradient of the free
energy is the aligned policy: perturbing the reward model by `s` changes the
optimal value at rate `𝔼_{π_β(r)}[s]`. -/
theorem hasDerivAt_freeEnergy {β : ℝ} (hβ : 0 < β) {ref : ι → ℝ} (href : IsPosProb ref)
    (r s : ι → ℝ) :
    HasDerivAt (fun t : ℝ => freeEnergy β ref (fun i => r i + t * s i))
      (∑ i, gibbs β ref r i * s i) 0 := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hZ0 : (tiltZ β ref fun i => r i + (0 : ℝ) * s i) = tiltZ β ref r := by
    simp
  have hd := hasDerivAt_tiltZ β ref r s
  have hlog := hd.log (by rw [hZ0]; exact hZ.ne')
  have hfin := hlog.const_mul β
  rw [hZ0] at hfin
  have hval : β * ((∑ i, ref i * Real.exp (r i / β) * (s i / β)) / tiltZ β ref r)
      = ∑ i, gibbs β ref r i * s i := by
    have h1 : ∑ i, gibbs β ref r i * s i
        = (∑ i, ref i * Real.exp (r i / β) * s i) / tiltZ β ref r := by
      rw [Finset.sum_div]
      exact Finset.sum_congr rfl fun i _ => by simp only [gibbs]; ring
    have h2 : (∑ i, ref i * Real.exp (r i / β) * (s i / β))
        = (∑ i, ref i * Real.exp (r i / β) * s i) / β := by
      rw [Finset.sum_div]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [h1, h2]
    field_simp
  rw [hval] at hfin
  simpa only [freeEnergy] using hfin

/-! ## Level B: annealing limits with explicit rates -/

/-- Zero-temperature lower bound: the free energy is within `β log (min ref)` of
the maximal reward. -/
theorem freeEnergy_ge_max_add {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} (href : IsPosProb ref) :
    (univ.sup' univ_nonempty r) + β * Real.log (univ.inf' univ_nonempty ref)
      ≤ freeEnergy β ref r := by
  obtain ⟨i₀, -, hi₀⟩ := Finset.exists_max_image (univ : Finset ι) r univ_nonempty
  have hsup : univ.sup' univ_nonempty r = r i₀ := by
    refine le_antisymm (Finset.sup'_le _ _ fun i _ => hi₀ i (mem_univ i)) (le_sup'_univ r i₀)
  have hZterm : ref i₀ * Real.exp (r i₀ / β) ≤ tiltZ β ref r := by
    refine Finset.single_le_sum (f := fun i => ref i * Real.exp (r i / β)) ?_ (mem_univ i₀)
    intro i _
    exact mul_nonneg (href.pos i).le (Real.exp_pos _).le
  have hpos : 0 < ref i₀ * Real.exp (r i₀ / β) :=
    mul_pos (href.pos i₀) (Real.exp_pos _)
  have hlog : Real.log (ref i₀) + r i₀ / β ≤ Real.log (tiltZ β ref r) := by
    have := Real.log_le_log hpos hZterm
    rwa [Real.log_mul (href.pos i₀).ne' (Real.exp_pos _).ne', Real.log_exp] at this
  have hinf : Real.log (univ.inf' univ_nonempty ref) ≤ Real.log (ref i₀) := by
    have hinfpos : 0 < univ.inf' univ_nonempty ref :=
      (Finset.lt_inf'_iff (s := univ) (H := univ_nonempty) (f := ref)).mpr
        fun i _ => href.pos i
    exact Real.log_le_log hinfpos (inf'_univ_le ref i₀)
  simp only [freeEnergy, hsup]
  have := mul_le_mul_of_nonneg_left hlog hβ.le
  have hexp : β * (Real.log (ref i₀) + r i₀ / β) = β * Real.log (ref i₀) + r i₀ := by
    field_simp
  nlinarith [mul_le_mul_of_nonneg_left hinf hβ.le]

/-- Zero-temperature upper bound: the free energy never exceeds the maximal
reward. -/
theorem freeEnergy_le_max {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} (href : IsPosProb ref) :
    freeEnergy β ref r ≤ univ.sup' univ_nonempty r :=
  freeEnergy_le_of_le hβ href (fun i => le_sup'_univ r i)

/-- **Annealing / policy-collapse limit.**  As the KL coefficient `β → 0⁺` the
optimal RLHF value converges to the maximal reward: with no regularisation the
aligned policy degenerates onto the reward argmax. -/
theorem tendsto_freeEnergy_zero {ref r : ι → ℝ} (href : IsPosProb ref) :
    Tendsto (fun β : ℝ => freeEnergy β ref r) (𝓝[>] (0 : ℝ))
      (𝓝 (univ.sup' univ_nonempty r)) := by
  set Mx := univ.sup' univ_nonempty r
  set L := Real.log (univ.inf' univ_nonempty ref)
  have hg : Tendsto (fun β : ℝ => Mx + β * L) (𝓝[>] (0 : ℝ)) (𝓝 Mx) := by
    have : Tendsto (fun β : ℝ => Mx + β * L) (𝓝 (0 : ℝ)) (𝓝 (Mx + 0 * L)) := by
      exact tendsto_const_nhds.add (Filter.Tendsto.mul_const L tendsto_id)
    simpa using this.mono_left nhdsWithin_le_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hg tendsto_const_nhds ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_ge_max_add hβ href
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_le_max hβ href

/-- Quadratic control of the exponential on `[-1,1]`, from Mathlib's Taylor
bound: `exp u ≤ 1 + u + (3/4) u²`. -/
theorem exp_le_quadratic {u : ℝ} (hu : |u| ≤ 1) :
    Real.exp u ≤ 1 + u + (3 / 4) * u ^ 2 := by
  have h := Real.exp_bound hu (n := 2) (by norm_num)
  have hsum : ∑ m ∈ Finset.range 2, u ^ m / (Nat.factorial m : ℝ) = 1 + u := by
    simp [Finset.sum_range_succ, Nat.factorial]
  rw [hsum] at h
  have h2 : Real.exp u - (1 + u) ≤ |u| ^ 2 * ((2 : ℕ).succ / ((Nat.factorial 2 : ℝ) * 2)) :=
    le_trans (le_abs_self _) h
  have habs : |u| ^ 2 = u ^ 2 := sq_abs u
  rw [habs] at h2
  norm_num [Nat.factorial] at h2
  linarith

/-- **High-temperature (large `β`) expansion.**  For `β` at least the sup-norm
of the reward, the optimal RLHF value exceeds the SFT value by at most
`(3/4)M²/β`: strong KL regularisation reduces alignment to the SFT model at
rate `1/β`. -/
theorem freeEnergy_sub_expected_le {β M : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref)
    (hM : ∀ i, |r i| ≤ M) (hMpos : 0 < M) (hβ : M ≤ β) :
    freeEnergy β ref r - (∑ i, ref i * r i) ≤ (3 / 4) * M ^ 2 / β := by
  have hβpos : 0 < β := lt_of_lt_of_le hMpos hβ
  have hu : ∀ i, |r i / β| ≤ 1 := by
    intro i
    rw [abs_div, abs_of_pos hβpos, div_le_one hβpos]
    exact le_trans (hM i) hβ
  have hZle : tiltZ β ref r ≤ 1 + (∑ i, ref i * r i) / β + (3 / 4) * M ^ 2 / β ^ 2 := by
    have hstep : ∀ i ∈ (univ : Finset ι),
        ref i * Real.exp (r i / β)
          ≤ ref i * (1 + r i / β + (3 / 4) * (M ^ 2 / β ^ 2)) := by
      intro i _
      refine mul_le_mul_of_nonneg_left ?_ (href.pos i).le
      refine le_trans (exp_le_quadratic (hu i)) ?_
      have hsq : (r i / β) ^ 2 ≤ M ^ 2 / β ^ 2 := by
        rw [div_pow, div_le_div_iff_of_pos_right (by positivity)]
        have := abs_le.mp (hM i)
        nlinarith [abs_nonneg (r i), sq_abs (r i), abs_le.mp (hM i)]
      linarith
    calc tiltZ β ref r ≤ ∑ i, ref i * (1 + r i / β + (3 / 4) * (M ^ 2 / β ^ 2)) :=
          Finset.sum_le_sum hstep
      _ = 1 + (∑ i, ref i * r i) / β + (3 / 4) * M ^ 2 / β ^ 2 := by
          have hA : ∑ i, ref i * (1 + r i / β + (3 / 4) * (M ^ 2 / β ^ 2))
              = ∑ i, (ref i + ref i * r i / β + ref i * ((3 / 4) * (M ^ 2 / β ^ 2))) :=
            Finset.sum_congr rfl fun i _ => by ring
          have h2 : ∑ i, ref i * r i / β = (∑ i, ref i * r i) / β := by
            rw [Finset.sum_div]
          have h3 : ∑ i, ref i * ((3 / 4) * (M ^ 2 / β ^ 2)) = (3 / 4) * M ^ 2 / β ^ 2 := by
            rw [← Finset.sum_mul, href.sum_one, one_mul]; ring
          rw [hA, Finset.sum_add_distrib, Finset.sum_add_distrib, href.sum_one, h2, h3]
  have hZpos : 0 < tiltZ β ref r := tiltZ_pos href
  have hlog : Real.log (tiltZ β ref r) ≤ tiltZ β ref r - 1 :=
    Real.log_le_sub_one_of_pos hZpos
  have hkey : Real.log (tiltZ β ref r) ≤ (∑ i, ref i * r i) / β + (3 / 4) * M ^ 2 / β ^ 2 := by
    linarith
  have := mul_le_mul_of_nonneg_left hkey hβpos.le
  simp only [freeEnergy]
  have hexp : β * ((∑ i, ref i * r i) / β + (3 / 4) * M ^ 2 / β ^ 2)
      = (∑ i, ref i * r i) + (3 / 4) * M ^ 2 / β := by
    field_simp
  linarith [hexp ▸ this]

/-- **Infinite-temperature limit.**  As `β → ∞` the optimal RLHF value converges
to the SFT expected reward: alignment vanishes and the tuned model reverts to
the reference. -/
theorem tendsto_freeEnergy_atTop {M : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref)
    (hM : ∀ i, |r i| ≤ M) (hMpos : 0 < M) :
    Tendsto (fun β : ℝ => freeEnergy β ref r) atTop (𝓝 (∑ i, ref i * r i)) := by
  set A := ∑ i, ref i * r i
  have hupper : Tendsto (fun β : ℝ => A + (3 / 4) * M ^ 2 / β) atTop (𝓝 A) := by
    have : Tendsto (fun β : ℝ => (3 / 4) * M ^ 2 / β) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop tendsto_id
    simpa using tendsto_const_nhds.add this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with β hβ
    exact expected_ref_le_freeEnergy hβ href
  · filter_upwards [eventually_ge_atTop M] with β hβ
    have := freeEnergy_sub_expected_le href hM hMpos hβ
    linarith

/-! ## Level C: the exact PTX regression law -/

/-- **Exact PTX identity.**  The pre-training log-likelihood of the aligned
policy equals that of the SFT reference, plus `(𝔼_pre[r] - F(β,r))/β`. -/
theorem ptx_at_gibbs {β : ℝ} (hβ : 0 < β) {ref r pre : ι → ℝ} (href : IsPosProb ref)
    (hpre : IsProb pre) :
    ∑ i, pre i * Real.log (gibbs β ref r i)
      = (∑ i, pre i * Real.log (ref i)) + ((∑ i, pre i * r i) - freeEnergy β ref r) / β := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hlog : ∀ i, Real.log (gibbs β ref r i)
      = Real.log (ref i) + r i / β - Real.log (tiltZ β ref r) := by
    intro i
    simp only [gibbs]
    rw [Real.log_div (mul_pos (href.pos i) (Real.exp_pos _)).ne' hZ.ne',
      Real.log_mul (href.pos i).ne' (Real.exp_pos _).ne', Real.log_exp]
  have hF : Real.log (tiltZ β ref r) = freeEnergy β ref r / β := by
    simp only [freeEnergy]
    field_simp
  calc ∑ i, pre i * Real.log (gibbs β ref r i)
      = ∑ i, (pre i * Real.log (ref i) + pre i * (r i / β)
          - pre i * Real.log (tiltZ β ref r)) := by
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [hlog i]; ring
    _ = (∑ i, pre i * Real.log (ref i)) + (∑ i, pre i * r i) / β
          - Real.log (tiltZ β ref r) := by
        rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul, hpre.sum_one,
          one_mul]
        have : ∑ i, pre i * (r i / β) = (∑ i, pre i * r i) / β := by
          rw [Finset.sum_div]
          exact Finset.sum_congr rfl fun i _ => by ring
        rw [this]
    _ = (∑ i, pre i * Real.log (ref i)) + ((∑ i, pre i * r i) - freeEnergy β ref r) / β := by
        rw [hF]; ring

/-- **PTX regression law.**  Aligning with reward `r` degrades the pre-training
mix-in term relative to the SFT model by exactly
`γ (F(β,r) - 𝔼_pre[r]) / β`; in particular the degradation is at most
`γ · oscil r / β`, the same `1/β` scale as the Hilbert-metric policy drift.
There is *no* pre-training regression at all when the pre-training data already
scores at or above the free-energy level. -/
theorem ptx_regression_le {β γ : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) {ref r pre : ι → ℝ}
    (href : IsPosProb ref) (hpre : IsProb pre) :
    ptxTerm γ pre ref - ptxTerm γ pre (gibbs β ref r) ≤ γ * oscil r / β := by
  have hid := ptx_at_gibbs (r := r) hβ href hpre
  have hFle : freeEnergy β ref r ≤ univ.sup' univ_nonempty r := freeEnergy_le_max hβ href
  have hEge : univ.inf' univ_nonempty r ≤ ∑ i, pre i * r i :=
    le_expectation hpre (fun i => inf'_univ_le r i)
  have hdiff : freeEnergy β ref r - (∑ i, pre i * r i) ≤ oscil r := by
    simp only [oscil]
    linarith
  have hstep : ptxTerm γ pre ref - ptxTerm γ pre (gibbs β ref r)
      = γ * ((freeEnergy β ref r - (∑ i, pre i * r i)) / β) := by
    simp only [ptxTerm]
    rw [hid]
    ring
  rw [hstep]
  have hpos : (freeEnergy β ref r - (∑ i, pre i * r i)) / β ≤ oscil r / β := by
    gcongr
  calc γ * ((freeEnergy β ref r - (∑ i, pre i * r i)) / β)
      ≤ γ * (oscil r / β) := mul_le_mul_of_nonneg_left hpos hγ
    _ = γ * oscil r / β := by ring

/-- **No-regression criterion (exact).**  The aligned policy is at least as good
as the SFT model on the pre-training objective *iff* the pre-training
distribution scores at least the free-energy level under the reward model. -/
theorem ptx_no_regression_iff {β γ : ℝ} (hβ : 0 < β) (hγ : 0 < γ) {ref r pre : ι → ℝ}
    (href : IsPosProb ref) (hpre : IsProb pre) :
    ptxTerm γ pre ref ≤ ptxTerm γ pre (gibbs β ref r)
      ↔ freeEnergy β ref r ≤ ∑ i, pre i * r i := by
  have hid := ptx_at_gibbs (r := r) hβ href hpre
  have hstep : ptxTerm γ pre (gibbs β ref r) - ptxTerm γ pre ref
      = γ * (((∑ i, pre i * r i) - freeEnergy β ref r) / β) := by
    simp only [ptxTerm]
    rw [hid]
    ring
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hneg : ((∑ i, pre i * r i) - freeEnergy β ref r) / β < 0 :=
      div_neg_of_neg_of_pos (by linarith) hβ
    have hmul := mul_neg_of_pos_of_neg hγ hneg
    rw [← hstep] at hmul
    linarith
  · intro h
    have h1 : 0 ≤ ((∑ i, pre i * r i) - freeEnergy β ref r) / β :=
      div_nonneg (by linarith) hβ.le
    have hmul := mul_nonneg hγ.le h1
    rw [← hstep] at hmul
    linarith

end NeuroSymbolicRLHF