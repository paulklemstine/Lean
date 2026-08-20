/-
Copyright (c) 2025. All rights reserved.

# Robustness, Preference Identifiability and Convex Duality for the RLHF Objective

Second research cycle, building directly on
`Catalog.Shared.NeuroSymbolicRLHFObjective` (variational principle, three-point
identity, torsor structure of exponential tilting).

Contents:

* **Preference identifiability (logistic ⋈ order theory).**  Bradley–Terry
  preference probabilities determine the reward *exactly up to an additive
  constant*, hence they determine the RLHF optimum uniquely: RLHF on preference
  data is a well-posed problem.
* **DPO reparametrisation.**  The map `reward ↦ optimal policy` is a bijection
  between rewards modulo constants and full-support policies; the inverse is the
  implicit reward `β log(π/π_SFT)`.
* **Convex duality.**  The free energy is convex, monotone and `1`-Lipschitz for
  the sup-norm in the reward, all obtained from the variational principle
  (a supremum of affine functionals).
* **Reward-model misspecification ("reward hacking") bound.**  If the learned
  reward is uniformly `ε`-close to the true reward, the policy it produces loses
  at most `2ε` of true regularised value.  The factor `2` is structural.
* **No policy collapse.**  Pointwise two-sided bounds
  `π_SFT(i) e^{-(M-m)/β} ≤ π*(i) ≤ π_SFT(i) e^{(M-m)/β)}`, an `L¹` drift bound
  `‖π* - π_SFT‖₁ ≤ e^{(M-m)/β} - 1`, and the limit `π* → π_SFT` as `β → ∞`.

Every theorem is proved; no `sorry`, no `native_decide`.
-/
import Mathlib
import Catalog.Shared.NeuroSymbolicRLHFObjective

open Finset Real BigOperators Filter Topology

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι]

/-! ## Preference identifiability: Bradley–Terry data pins the reward down to a
constant -/

/-- Bradley–Terry probability that response `i` is preferred to response `j`
under reward `r`. -/
def btPref (r : ι → ℝ) (i j : ι) : ℝ := 1 / (1 + Real.exp (r j - r i))

omit [Fintype ι] in
theorem btPref_pos (r : ι → ℝ) (i j : ι) : 0 < btPref r i j := by
  unfold btPref
  have : (0:ℝ) < 1 + Real.exp (r j - r i) := by positivity
  positivity

omit [Fintype ι] in
/-- Two rewards induce the same Bradley–Terry preferences iff they differ by an
additive constant. -/
theorem btPref_eq_iff [Nonempty ι] {r s : ι → ℝ} :
    (∀ i j, btPref r i j = btPref s i j) ↔ ∃ c : ℝ, ∀ i, r i = s i + c := by
  constructor
  · intro h
    obtain ⟨j0⟩ := ‹Nonempty ι›
    refine ⟨r j0 - s j0, fun i => ?_⟩
    have hij := h i j0
    unfold btPref at hij
    have hpos1 : (0:ℝ) < 1 + Real.exp (r j0 - r i) := by positivity
    have hpos2 : (0:ℝ) < 1 + Real.exp (s j0 - s i) := by positivity
    have hexp : Real.exp (r j0 - r i) = Real.exp (s j0 - s i) := by
      field_simp at hij
      linarith
    have := Real.exp_injective hexp
    linarith
  · rintro ⟨c, hc⟩ i j
    unfold btPref
    rw [hc i, hc j]
    ring_nf

/-- **Well-posedness of RLHF on preference data**: preference-equivalent reward
models produce exactly the same optimal policy. -/
theorem gibbs_eq_of_btPref_eq {β : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (h : ∀ i j, btPref r i j = btPref s i j) :
    gibbs β ref r = gibbs β ref s :=
  (gibbs_eq_gibbs_iff hβ href).2 (btPref_eq_iff.1 h)

/-- Conversely, if two rewards give the same optimal policy they give the same
preferences: the RLHF optimum and the preference model carry exactly the same
information. -/
theorem btPref_eq_of_gibbs_eq {β : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (h : gibbs β ref r = gibbs β ref s) :
    ∀ i j, btPref r i j = btPref s i j :=
  btPref_eq_iff.2 ((gibbs_eq_gibbs_iff hβ href).1 h)

/-! ## DPO reparametrisation -/

/-- The implicit ("DPO") reward attached to a policy `q` relative to the SFT
reference: `β log (q i / ref i)`. -/
def implicitReward (β : ℝ) (ref q : ι → ℝ) : ι → ℝ := fun i => β * Real.log (q i / ref i)

/-- Every full-support policy is the RLHF optimum of its own implicit reward. -/
theorem gibbs_implicitReward {β : ℝ} (hβ : 0 < β) {ref q : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hq : IsPosProb q) :
    gibbs β ref (implicitReward β ref q) = q :=
  gibbs_transitive hβ href hq

/-- **DPO reparametrisation theorem**: the implicit reward of the RLHF optimum
recovers the original reward up to an additive constant. -/
theorem implicitReward_gibbs {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) :
    ∃ c : ℝ, ∀ i, implicitReward β ref (gibbs β ref r) i = r i + c := by
  have h : gibbs β ref (implicitReward β ref (gibbs β ref r)) = gibbs β ref r :=
    gibbs_implicitReward hβ href (gibbs_isPosProb href)
  exact (gibbs_eq_gibbs_iff hβ href).1 h

/-! ## Convex duality for the free energy -/

/-- Shifting the reward by a constant shifts the optimal value by that constant. -/
theorem freeEnergy_add_const {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} (c : ℝ) [Nonempty ι]
    (href : IsPosProb ref) :
    freeEnergy β ref (fun i => r i + c) = freeEnergy β ref r + c := by
  have hZ1 : 0 < tiltZ β ref r := tiltZ_pos href
  have hZc : tiltZ β ref (fun i => r i + c) = Real.exp (c / β) * tiltZ β ref r := by
    unfold tiltZ
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [add_div, Real.exp_add]
    ring
  unfold freeEnergy
  rw [hZc, Real.log_mul (Real.exp_ne_zero _) hZ1.ne', Real.log_exp]
  field_simp
  ring

/-- **Monotonicity in the reward**: a pointwise larger reward has a larger
optimal value. -/
theorem freeEnergy_mono {β : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hrs : ∀ i, r i ≤ s i) :
    freeEnergy β ref r ≤ freeEnergy β ref s := by
  have hg : IsPosProb (gibbs β ref r) := gibbs_isPosProb href
  have h1 := rlhfObj_gibbs (β := β) (r := r) hβ href
  have h2 := rlhfObj_le_freeEnergy (β := β) (r := s) (p := gibbs β ref r) hβ href hg.isProb
  have hsum : ∑ i, gibbs β ref r i * r i ≤ ∑ i, gibbs β ref r i * s i :=
    Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hrs i) (hg.pos i).le
  unfold rlhfObj at h1 h2
  linarith

/-- **Convexity of the free energy in the reward** — a consequence of the
variational principle: the free energy is a supremum of affine functionals of
the reward. -/
theorem freeEnergy_convex {β lam : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (h0 : 0 ≤ lam) (h1 : lam ≤ 1) :
    freeEnergy β ref (fun i => lam * r i + (1 - lam) * s i)
      ≤ lam * freeEnergy β ref r + (1 - lam) * freeEnergy β ref s := by
  set t : ι → ℝ := fun i => lam * r i + (1 - lam) * s i with ht
  set p := gibbs β ref t with hp
  have hpp : IsPosProb p := gibbs_isPosProb href
  have hmix : ∑ i, p i * t i = lam * (∑ i, p i * r i) + (1 - lam) * ∑ i, p i * s i := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by simp [ht]; ring
  have hopt := rlhfObj_gibbs (β := β) (r := t) hβ href
  have hr := rlhfObj_le_freeEnergy (β := β) (r := r) (p := p) hβ href hpp.isProb
  have hs := rlhfObj_le_freeEnergy (β := β) (r := s) (p := p) hβ href hpp.isProb
  unfold rlhfObj at hopt hr hs
  rw [hmix] at hopt
  nlinarith [hr, hs, hopt, h0, sub_nonneg.2 h1]

/-- **Sup-norm Lipschitz continuity of the optimal value in the reward.** -/
theorem freeEnergy_lipschitz {β ε : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hε : ∀ i, |r i - s i| ≤ ε) :
    |freeEnergy β ref r - freeEnergy β ref s| ≤ ε := by
  have hle1 : freeEnergy β ref r ≤ freeEnergy β ref s + ε := by
    have := freeEnergy_mono (β := β) hβ href (r := r) (s := fun i => s i + ε)
      (fun i => by have := abs_le.1 (hε i); linarith [this.1, this.2])
    rwa [freeEnergy_add_const hβ ε href] at this
  have hle2 : freeEnergy β ref s ≤ freeEnergy β ref r + ε := by
    have := freeEnergy_mono (β := β) hβ href (r := s) (s := fun i => r i + ε)
      (fun i => by have := abs_le.1 (hε i); linarith [this.1, this.2])
    rwa [freeEnergy_add_const hβ ε href] at this
  rw [abs_le]
  constructor <;> linarith

/-- **Reward misspecification / reward-hacking bound**: optimising a reward
model that is uniformly `ε`-close to the true reward loses at most `2ε` of true
KL-regularised value. -/
theorem reward_hacking_bound {β ε : ℝ} (hβ : 0 < β) {ref r rhat : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hε : ∀ i, |r i - rhat i| ≤ ε) :
    freeEnergy β ref r - 2 * ε ≤ rlhfObj β ref r (gibbs β ref rhat) := by
  have hg : IsPosProb (gibbs β ref rhat) := gibbs_isPosProb href
  have hopt := rlhfObj_gibbs (β := β) (r := rhat) hβ href
  have hlip := freeEnergy_lipschitz (β := β) (r := r) (s := rhat) hβ href hε
  have hclose : |freeEnergy β ref r - freeEnergy β ref rhat| ≤ ε := hlip
  have hdiff : ∑ i, gibbs β ref rhat i * rhat i - ε
      ≤ ∑ i, gibbs β ref rhat i * r i := by
    have hstep : ∀ i ∈ (univ : Finset ι),
        gibbs β ref rhat i * rhat i - gibbs β ref rhat i * ε
          ≤ gibbs β ref rhat i * r i := by
      intro i _
      have hb := abs_le.1 (hε i)
      nlinarith [(hg.pos i).le, hb.1, hb.2]
    have := Finset.sum_le_sum hstep
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hg.sum_one, one_mul] at this
    exact this
  unfold rlhfObj at hopt ⊢
  have := abs_le.1 hclose
  linarith [this.1, this.2]

/-! ## No policy collapse: two-sided support bounds and `L¹` drift -/

theorem tiltZ_le_of_le {β M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hM : ∀ i, r i ≤ M) :
    tiltZ β ref r ≤ Real.exp (M / β) := by
  unfold tiltZ
  calc ∑ i, ref i * Real.exp (r i / β)
      ≤ ∑ i, ref i * Real.exp (M / β) := by
        refine Finset.sum_le_sum fun i _ => ?_
        exact mul_le_mul_of_nonneg_left
          (Real.exp_le_exp.2 ((div_le_div_iff_of_pos_right hβ).2 (hM i))) (href.pos i).le
    _ = Real.exp (M / β) := by rw [← Finset.sum_mul, href.sum_one, one_mul]

theorem le_tiltZ_of_le {β m : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) :
    Real.exp (m / β) ≤ tiltZ β ref r := by
  unfold tiltZ
  calc Real.exp (m / β) = ∑ i, ref i * Real.exp (m / β) := by
        rw [← Finset.sum_mul, href.sum_one, one_mul]
    _ ≤ ∑ i, ref i * Real.exp (r i / β) := by
        refine Finset.sum_le_sum fun i _ => ?_
        exact mul_le_mul_of_nonneg_left
          (Real.exp_le_exp.2 ((div_le_div_iff_of_pos_right hβ).2 (hm i))) (href.pos i).le

/-- **No collapse (lower bound)**: the aligned policy keeps every response with
probability at least `e^{-(M-m)/β}` times its SFT probability. -/
theorem gibbs_ge_ref_mul {β m M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) (i : ι) :
    ref i * Real.exp (-((M - m) / β)) ≤ gibbs β ref r i := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hZle : tiltZ β ref r ≤ Real.exp (M / β) := tiltZ_le_of_le hβ href hM
  have hexp : Real.exp (m / β) ≤ Real.exp (r i / β) :=
    Real.exp_le_exp.2 ((div_le_div_iff_of_pos_right hβ).2 (hm i))
  have hnum : ref i * Real.exp (m / β) ≤ ref i * Real.exp (r i / β) :=
    mul_le_mul_of_nonneg_left hexp (href.pos i).le
  have hkey : ref i * Real.exp (-((M - m) / β)) * tiltZ β ref r
      ≤ ref i * Real.exp (r i / β) := by
    have h1 : ref i * Real.exp (-((M - m) / β)) * tiltZ β ref r
        ≤ ref i * Real.exp (-((M - m) / β)) * Real.exp (M / β) :=
      mul_le_mul_of_nonneg_left hZle (mul_pos (href.pos i) (Real.exp_pos _)).le
    have h2 : ref i * Real.exp (-((M - m) / β)) * Real.exp (M / β)
        = ref i * Real.exp (m / β) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    linarith [h1, h2 ▸ hnum]
  unfold gibbs
  rw [le_div_iff₀ hZ]
  exact hkey

/-- **Bounded amplification (upper bound)**: the aligned policy amplifies any
response by at most `e^{(M-m)/β}`. -/
theorem gibbs_le_ref_mul {β m M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) (i : ι) :
    gibbs β ref r i ≤ ref i * Real.exp ((M - m) / β) := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hZge : Real.exp (m / β) ≤ tiltZ β ref r := le_tiltZ_of_le hβ href hm
  have hexp : Real.exp (r i / β) ≤ Real.exp (M / β) :=
    Real.exp_le_exp.2 ((div_le_div_iff_of_pos_right hβ).2 (hM i))
  have hkey : ref i * Real.exp (r i / β)
      ≤ ref i * Real.exp ((M - m) / β) * tiltZ β ref r := by
    have h1 : ref i * Real.exp ((M - m) / β) * Real.exp (m / β)
        ≤ ref i * Real.exp ((M - m) / β) * tiltZ β ref r :=
      mul_le_mul_of_nonneg_left hZge (mul_pos (href.pos i) (Real.exp_pos _)).le
    have h2 : ref i * Real.exp ((M - m) / β) * Real.exp (m / β)
        = ref i * Real.exp (M / β) := by
      rw [mul_assoc, ← Real.exp_add]
      congr 2
      ring
    have h3 : ref i * Real.exp (r i / β) ≤ ref i * Real.exp (M / β) :=
      mul_le_mul_of_nonneg_left hexp (href.pos i).le
    linarith [h1, h2 ▸ h1, h3]
  unfold gibbs
  rw [div_le_iff₀ hZ]
  exact hkey

/-- **`L¹` drift bound**: the aligned policy is within total variation distance
`(e^{(M-m)/β} - 1)/2` of the SFT policy; equivalently the `L¹` distance is at
most `e^{(M-m)/β} - 1`, which tends to `0` as `β → ∞`. -/
theorem gibbs_l1_drift_le {β m M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) :
    ∑ i, |gibbs β ref r i - ref i| ≤ Real.exp ((M - m) / β) - 1 := by
  have hmM : m ≤ M := le_trans (hm (Classical.arbitrary ι)) (hM (Classical.arbitrary ι))
  have hd : 0 ≤ (M - m) / β := div_nonneg (by linarith) hβ.le
  have hE1 : 1 ≤ Real.exp ((M - m) / β) := Real.one_le_exp hd
  have hterm : ∀ i : ι, |gibbs β ref r i - ref i| ≤ ref i * (Real.exp ((M - m) / β) - 1) := by
    intro i
    have hup := gibbs_le_ref_mul hβ href hm hM i
    have hlo := gibbs_ge_ref_mul hβ href hm hM i
    have hge : 1 - Real.exp (-((M - m) / β)) ≤ Real.exp ((M - m) / β) - 1 := by
      have h0 : 0 < Real.exp ((M - m) / β) := Real.exp_pos _
      have hprod : Real.exp (-((M - m) / β)) * Real.exp ((M - m) / β) = 1 := by
        rw [← Real.exp_add]
        simp
      nlinarith [hE1, h0, hprod, sq_nonneg (Real.exp ((M - m) / β) - 1)]
    rw [abs_le]
    constructor
    · have : ref i * (1 - Real.exp (-((M - m) / β))) ≤ ref i * (Real.exp ((M - m) / β) - 1) :=
        mul_le_mul_of_nonneg_left hge (href.pos i).le
      nlinarith [hlo, this]
    · nlinarith [hup]
  calc ∑ i, |gibbs β ref r i - ref i|
      ≤ ∑ i, ref i * (Real.exp ((M - m) / β) - 1) := Finset.sum_le_sum fun i _ => hterm i
    _ = Real.exp ((M - m) / β) - 1 := by rw [← Finset.sum_mul, href.sum_one, one_mul]

/-- **Strong-regularisation limit**: as the KL coefficient `β → ∞` the aligned
policy converges to the SFT reference policy in `L¹`. -/
theorem gibbs_tendsto_ref {m M : ℝ} {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) :
    Tendsto (fun β : ℝ => ∑ i, |gibbs β ref r i - ref i|) atTop (𝓝 0) := by
  have hquot : Tendsto (fun β : ℝ => (M - m) / β) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
  have hexp : Tendsto (fun β : ℝ => Real.exp ((M - m) / β) - 1) atTop (𝓝 0) := by
    have h1 : Tendsto (fun β : ℝ => Real.exp ((M - m) / β)) atTop (𝓝 1) := by
      have h2 := (Real.continuous_exp.tendsto 0).comp hquot
      simpa using h2
    have h3 := h1.sub (tendsto_const_nhds (α := ℝ) (x := (1:ℝ)) (f := atTop))
    simpa using h3
  refine squeeze_zero' ?_ ?_ hexp
  · filter_upwards with β
    exact Finset.sum_nonneg fun i _ => abs_nonneg _
  · filter_upwards [eventually_gt_atTop 0] with β hβ
    exact gibbs_l1_drift_le hβ href hm hM

end NeuroSymbolicRLHF