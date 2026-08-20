/-
# RLHF as an isometry of the Hilbert projective metric

This file continues the neurosymbolic RLHF / PPO-ptx research thread of
`Speculative/AutoResearch/NeuroSymbolicRLHFObjective.lean`, whose definitions
(`tiltZ`, `gibbs`, `freeEnergy`, `rlhfObj`, `klDivFin`) are reused verbatim.

The InstructGPT objective

  `Objective(p) = 𝔼_p[RM] - β · KL(p ‖ p_SFT) + γ · 𝔼_{pre}[log p]`

has, for `γ = 0`, the exponentially tilted maximiser `gibbs β ref r`.  The
catalog already knows that tilting is a *transitive group action* of the reward
space on the open simplex (a torsor structure).  Here we upgrade that algebraic
statement to a **metric** one, bridging information theory with the projective
geometry of Birkhoff and Hilbert:

* **Level 0.** Elementary theory of the oscillation seminorm
  `oscil f = max f - min f` (translation invariance, positive homogeneity,
  comparison with the sup-norm).
* **Level 1 (main theorem, `hilbertDist_gibbs`).**  The tilt map is an *exact
  isometry*, with scale factor `1/β`:
  `d_H (π_β(r₁), π_β(r₂)) = oscil (r₁ - r₂) / β`.
  In particular the RLHF torsor action of `(ℝ^ι/ℝ·1, oscil)` on the open
  simplex equipped with the Hilbert projective metric is by isometries, and
  `d_H (π_β(r), ref) = oscil r / β`.
* **Level 2 (`tvDist_le_expm1_hilbertDist`).**  A Hilbert-metric bound controls
  total variation, giving the quantitative reward-model-misspecification bound
  `‖π_β(r₁) - π_β(r₂)‖_TV ≤ exp(oscil (r₁ - r₂)/β) - 1`:
  KL-regularisation with large `β` makes the aligned policy insensitive to
  reward-model error.
* **Level 3 (`rlhf_reward_hacking_regret`).**  Optimising a *proxy* reward `r̂`
  loses at most `2‖r - r̂‖_∞` of the true KL-regularised value — an explicit
  reward-hacking (Goodhart) bound.

No `sorry`, no `native_decide`.
-/
import Speculative.AutoResearch.NeuroSymbolicRLHFObjective

open Finset Real BigOperators

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Level 0: the oscillation seminorm -/

/-- The oscillation (range) seminorm `max f - min f` of a function on a finite
nonempty type.  It vanishes exactly on the constants, and is the natural norm
on the quotient `ℝ^ι / ℝ·1` of rewards modulo additive constants. -/
def oscil (f : ι → ℝ) : ℝ :=
  (univ.sup' univ_nonempty f) - (univ.inf' univ_nonempty f)

theorem le_sup'_univ (f : ι → ℝ) (i : ι) : f i ≤ univ.sup' univ_nonempty f :=
  Finset.le_sup' f (mem_univ i)

theorem inf'_univ_le (f : ι → ℝ) (i : ι) : univ.inf' univ_nonempty f ≤ f i :=
  Finset.inf'_le f (mem_univ i)

theorem oscil_nonneg (f : ι → ℝ) : 0 ≤ oscil f := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  have h1 := inf'_univ_le f i
  have h2 := le_sup'_univ f i
  simp only [oscil]
  linarith

/-- Any two values of `f` differ by at most `oscil f`. -/
theorem sub_le_oscil (f : ι → ℝ) (i j : ι) : f i - f j ≤ oscil f := by
  have h1 := le_sup'_univ f i
  have h2 := inf'_univ_le f j
  simp only [oscil]
  linarith

/-- The oscillation is invariant under adding a constant: it is a seminorm on
rewards modulo constants. -/
theorem oscil_add_const (f : ι → ℝ) (c : ℝ) : oscil (fun i => f i + c) = oscil f := by
  have hs : univ.sup' univ_nonempty (fun i => f i + c) = univ.sup' univ_nonempty f + c := by
    apply le_antisymm
    · refine Finset.sup'_le _ _ ?_
      intro i _
      have := le_sup'_univ f i
      linarith
    · have : univ.sup' univ_nonempty f ≤ univ.sup' univ_nonempty (fun i => f i + c) - c := by
        refine Finset.sup'_le _ _ ?_
        intro i _
        have := le_sup'_univ (fun i => f i + c) i
        simp only at this
        linarith
      linarith
  have hi : univ.inf' univ_nonempty (fun i => f i + c) = univ.inf' univ_nonempty f + c := by
    apply le_antisymm
    · have : univ.inf' univ_nonempty (fun i => f i + c) - c ≤ univ.inf' univ_nonempty f := by
        refine Finset.le_inf' _ _ ?_
        intro i _
        have := inf'_univ_le (fun i => f i + c) i
        simp only at this
        linarith
      linarith
    · refine Finset.le_inf' _ _ ?_
      intro i _
      have := inf'_univ_le f i
      linarith
  simp only [oscil, hs, hi]
  ring

/-- Positive homogeneity of the oscillation seminorm. -/
theorem oscil_const_mul {c : ℝ} (hc : 0 < c) (f : ι → ℝ) :
    oscil (fun i => c * f i) = c * oscil f := by
  have hs : univ.sup' univ_nonempty (fun i => c * f i) = c * univ.sup' univ_nonempty f := by
    apply le_antisymm
    · refine Finset.sup'_le _ _ ?_
      intro i _
      exact mul_le_mul_of_nonneg_left (le_sup'_univ f i) hc.le
    · rw [← le_div_iff₀' hc]
      refine Finset.sup'_le _ _ ?_
      intro i _
      rw [le_div_iff₀ hc]
      have := le_sup'_univ (fun i => c * f i) i
      simpa [mul_comm] using this
  have hi : univ.inf' univ_nonempty (fun i => c * f i) = c * univ.inf' univ_nonempty f := by
    apply le_antisymm
    · rw [← div_le_iff₀' hc]
      refine Finset.le_inf' _ _ ?_
      intro i _
      rw [div_le_iff₀ hc]
      have := inf'_univ_le (fun i => c * f i) i
      simpa [mul_comm] using this
    · refine Finset.le_inf' _ _ ?_
      intro i _
      exact mul_le_mul_of_nonneg_left (inf'_univ_le f i) hc.le
  simp only [oscil, hs, hi]
  ring

/-- The oscillation is at most twice the sup-norm bound. -/
theorem oscil_le_two_mul {f : ι → ℝ} {M : ℝ} (hM : ∀ i, |f i| ≤ M) : oscil f ≤ 2 * M := by
  have hs : univ.sup' univ_nonempty f ≤ M :=
    Finset.sup'_le _ _ fun i _ => (abs_le.mp (hM i)).2
  have hi : -M ≤ univ.inf' univ_nonempty f :=
    Finset.le_inf' _ _ fun i _ => (abs_le.mp (hM i)).1
  simp only [oscil]
  linarith

/-! ## Level 1: the Hilbert projective metric and the tilt isometry -/

/-- The Hilbert projective (Birkhoff) distance between two positive vectors:
the oscillation of the log-likelihood ratio. -/
def hilbertDist (p q : ι → ℝ) : ℝ := oscil (fun i => Real.log (p i / q i))

theorem hilbertDist_nonneg (p q : ι → ℝ) : 0 ≤ hilbertDist p q :=
  oscil_nonneg _

theorem hilbertDist_self {p : ι → ℝ} (hp : IsPosProb p) : hilbertDist p p = 0 := by
  have : (fun i => Real.log (p i / p i)) = fun _ : ι => (0 : ℝ) := by
    funext i
    rw [div_self (hp.pos i).ne']
    simp
  simp only [hilbertDist, this, oscil]
  simp

/-- Pointwise log-ratio of two tilted policies: the reward difference divided by
`β`, plus a constant (the log ratio of partition functions). -/
theorem log_gibbs_ratio {β : ℝ} {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref) (i : ι) :
    Real.log (gibbs β ref r₁ i / gibbs β ref r₂ i)
      = (r₁ i - r₂ i) / β + Real.log (tiltZ β ref r₂ / tiltZ β ref r₁) := by
  have hZ1 : 0 < tiltZ β ref r₁ := tiltZ_pos href
  have hZ2 : 0 < tiltZ β ref r₂ := tiltZ_pos href
  have hri : 0 < ref i := href.pos i
  have hkey : gibbs β ref r₁ i / gibbs β ref r₂ i
      = Real.exp ((r₁ i - r₂ i) / β) * (tiltZ β ref r₂ / tiltZ β ref r₁) := by
    have he1 : Real.exp (r₁ i / β) ≠ 0 := (Real.exp_pos _).ne'
    have he2 : Real.exp (r₂ i / β) ≠ 0 := (Real.exp_pos _).ne'
    simp only [gibbs, sub_div, Real.exp_sub]
    field_simp
  rw [hkey, Real.log_mul (Real.exp_pos _).ne' (by positivity), Real.log_exp]

/-- **Main theorem (exact isometry).**  The RLHF tilt map
`r ↦ π_β(r) = gibbs β ref r` is an isometry from the reward space modulo
constants, equipped with `oscil / β`, onto the open simplex equipped with the
Hilbert projective metric.  In particular the "temperature" `β` is exactly the
metric scale factor of alignment. -/
theorem hilbertDist_gibbs {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref) :
    hilbertDist (gibbs β ref r₁) (gibbs β ref r₂) = oscil (fun i => r₁ i - r₂ i) / β := by
  have hfun : (fun i => Real.log (gibbs β ref r₁ i / gibbs β ref r₂ i))
      = fun i => (1 / β) * (r₁ i - r₂ i) + Real.log (tiltZ β ref r₂ / tiltZ β ref r₁) := by
    funext i
    rw [log_gibbs_ratio href i]
    ring_nf
  simp only [hilbertDist, hfun]
  rw [oscil_add_const, oscil_const_mul (by positivity)]
  ring

/-- Specialisation: the Hilbert distance the aligned policy has travelled from
the SFT reference is exactly `oscil r / β`. -/
theorem hilbertDist_gibbs_ref {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} (href : IsPosProb ref) :
    hilbertDist (gibbs β ref r) ref = oscil r / β := by
  have h0 : gibbs β ref (fun _ => (0 : ℝ)) = ref := gibbs_zero href
  have := hilbertDist_gibbs (r₁ := r) (r₂ := fun _ => (0 : ℝ)) hβ href
  rw [h0] at this
  simpa using this

/-- Tilting by two rewards gives the same policy iff the rewards differ by a
constant — read off metrically: the Hilbert distance vanishes iff the
oscillation of the difference vanishes. -/
theorem hilbertDist_gibbs_eq_zero_iff {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ}
    (href : IsPosProb ref) :
    hilbertDist (gibbs β ref r₁) (gibbs β ref r₂) = 0 ↔ oscil (fun i => r₁ i - r₂ i) = 0 := by
  rw [hilbertDist_gibbs hβ href, div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · exact h
    · exact absurd h hβ.ne'
  · intro h; exact Or.inl h

/-! ## Level 2: from the Hilbert metric to total variation -/

/-- Total variation distance between two finite probability vectors. -/
def tvDist (p q : ι → ℝ) : ℝ := (∑ i, |p i - q i|) / 2

omit [Nonempty ι] in
theorem tvDist_nonneg (p q : ι → ℝ) : 0 ≤ tvDist p q := by
  have h : 0 ≤ ∑ i, |p i - q i| := Finset.sum_nonneg fun i _ => abs_nonneg _
  simp only [tvDist]
  linarith

/-- A density-ratio bound: two positive probability vectors at Hilbert distance
`d` satisfy `p ≤ e^d q` pointwise. -/
theorem le_exp_hilbertDist_mul {p q : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q) (i : ι) :
    p i ≤ Real.exp (hilbertDist p q) * q i := by
  set L : ι → ℝ := fun i => Real.log (p i / q i) with hL
  -- there is an index where `p ≤ q`, hence `inf L ≤ 0`
  obtain ⟨j, -, hj⟩ : ∃ j ∈ univ, p j ≤ q j := by
    by_contra hcon
    push_neg at hcon
    have : ∑ i, q i < ∑ i, p i :=
      Finset.sum_lt_sum_of_nonempty univ_nonempty fun i _ => hcon i (mem_univ i)
    rw [hp.sum_one, hq.sum_one] at this
    exact lt_irrefl _ this
  have hLj : L j ≤ 0 := by
    have : p j / q j ≤ 1 := (div_le_one (hq.pos j)).mpr hj
    have := Real.log_nonpos (div_pos (hp.pos j) (hq.pos j)).le this
    simpa [hL] using this
  have hinf : univ.inf' univ_nonempty L ≤ 0 := le_trans (inf'_univ_le L j) hLj
  have hsup : univ.sup' univ_nonempty L ≤ hilbertDist p q := by
    simp only [hilbertDist, oscil, ← hL]
    linarith
  have hLi : L i ≤ hilbertDist p q := le_trans (le_sup'_univ L i) hsup
  have hratio : p i / q i ≤ Real.exp (hilbertDist p q) := by
    have hpos : 0 < p i / q i := div_pos (hp.pos i) (hq.pos i)
    have := Real.exp_le_exp.mpr hLi
    rwa [Real.exp_log hpos] at this
  calc p i = (p i / q i) * q i := by rw [div_mul_cancel₀ _ (hq.pos i).ne']
    _ ≤ Real.exp (hilbertDist p q) * q i := mul_le_mul_of_nonneg_right hratio (hq.pos i).le

/-- **Total-variation stability.**  The Hilbert projective metric dominates
total variation: `‖p - q‖_TV ≤ e^{d_H(p,q)} - 1`. -/
theorem tvDist_le_expm1_hilbertDist {p q : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q) :
    tvDist p q ≤ Real.exp (hilbertDist p q) - 1 := by
  set d := hilbertDist p q with hd
  have hd0 : 0 ≤ d := hilbertDist_nonneg p q
  have hexp1 : 1 ≤ Real.exp d := Real.one_le_exp hd0
  have hpt : ∀ i, |p i - q i| ≤ 2 * ((Real.exp d - 1) * q i) - (p i - q i) := by
    intro i
    have hle : p i ≤ Real.exp d * q i := le_exp_hilbertDist_mul hp hq i
    rcases le_or_gt (p i) (q i) with h | h
    · rw [abs_of_nonpos (by linarith)]
      have : 0 ≤ (Real.exp d - 1) * q i := by
        have := (hq.pos i).le
        nlinarith
      linarith
    · rw [abs_of_nonneg (by linarith)]
      nlinarith
  have hsum : ∑ i, |p i - q i| ≤ ∑ i, (2 * ((Real.exp d - 1) * q i) - (p i - q i)) :=
    Finset.sum_le_sum fun i _ => hpt i
  have hrhs : ∑ i, (2 * ((Real.exp d - 1) * q i) - (p i - q i))
      = 2 * (Real.exp d - 1) := by
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
      hp.sum_one, hq.sum_one]
    ring
  rw [hrhs] at hsum
  simp only [tvDist]
  linarith

/-- **Reward-model misspecification bound.**  Two reward models differing by an
oscillation `ε` produce aligned policies within total variation
`exp(ε/β) - 1`; the KL coefficient `β` linearly damps reward-model error. -/
theorem tvDist_gibbs_le {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref) :
    tvDist (gibbs β ref r₁) (gibbs β ref r₂)
      ≤ Real.exp (oscil (fun i => r₁ i - r₂ i) / β) - 1 := by
  have h := tvDist_le_expm1_hilbertDist (gibbs_isPosProb (β := β) (r := r₁) href)
    (gibbs_isPosProb (β := β) (r := r₂) href)
  rwa [hilbertDist_gibbs hβ href] at h

/-! ## Level 3: Goodhart / reward-hacking regret -/

/-- Shifting a reward by a constant shifts the free energy by that constant. -/
theorem freeEnergy_add_const {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} (href : IsPosProb ref) (c : ℝ) :
    freeEnergy β ref (fun i => r i + c) = freeEnergy β ref r + c := by
  have hZ : tiltZ β ref (fun i => r i + c) = Real.exp (c / β) * tiltZ β ref r := by
    simp only [tiltZ, Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [add_div, Real.exp_add]
    ring
  have hZpos : 0 < tiltZ β ref r := tiltZ_pos href
  simp only [freeEnergy, hZ]
  rw [Real.log_mul (Real.exp_pos _).ne' hZpos.ne', Real.log_exp]
  field_simp
  ring

/-- The free energy is monotone in the reward. -/
theorem freeEnergy_mono {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} (href : IsPosProb ref)
    (h : ∀ i, r₁ i ≤ r₂ i) : freeEnergy β ref r₁ ≤ freeEnergy β ref r₂ := by
  have hZ : tiltZ β ref r₁ ≤ tiltZ β ref r₂ := by
    refine Finset.sum_le_sum fun i _ => ?_
    have : Real.exp (r₁ i / β) ≤ Real.exp (r₂ i / β) :=
      Real.exp_le_exp.mpr (by gcongr; exact h i)
    exact mul_le_mul_of_nonneg_left this (href.pos i).le
  have h1 : 0 < tiltZ β ref r₁ := tiltZ_pos href
  simp only [freeEnergy]
  exact mul_le_mul_of_nonneg_left (Real.log_le_log h1 hZ) hβ.le

/-- **Free energy is 1-Lipschitz in the reward (sup-norm).** -/
theorem freeEnergy_sub_le {β : ℝ} (hβ : 0 < β) {ref r₁ r₂ : ι → ℝ} {M : ℝ}
    (href : IsPosProb ref) (hM : ∀ i, |r₁ i - r₂ i| ≤ M) :
    freeEnergy β ref r₁ - freeEnergy β ref r₂ ≤ M := by
  have h1 : ∀ i, r₁ i ≤ r₂ i + M := by
    intro i
    have := (abs_le.mp (hM i)).2
    linarith
  have := freeEnergy_mono hβ href h1
  rw [freeEnergy_add_const hβ href] at this
  linarith

/-- **Reward hacking / Goodhart bound.**  If the proxy reward `r̂` used for
RLHF is uniformly within `M` of the true reward `r`, then the policy obtained by
optimising the proxy loses at most `2M` of the true KL-regularised objective,
whose optimum is the true free energy.  Note the bound is *independent of `β`*:
KL-regularised alignment degrades gracefully in reward-model error. -/
theorem rlhf_reward_hacking_regret {β : ℝ} (hβ : 0 < β) {ref r rhat : ι → ℝ} {M : ℝ}
    (href : IsPosProb ref) (hM : ∀ i, |r i - rhat i| ≤ M) :
    freeEnergy β ref r - rlhfObj β ref r (gibbs β ref rhat) ≤ 2 * M := by
  set q := gibbs β ref rhat with hq
  have hqprob : IsPosProb q := gibbs_isPosProb href
  -- value of the proxy-optimal policy under the proxy reward
  have hopt : rlhfObj β ref rhat q = freeEnergy β ref rhat := rlhfObj_gibbs hβ href
  -- swapping the reward inside the objective costs at most `M`
  have hswap : rlhfObj β ref rhat q - rlhfObj β ref r q ≤ M := by
    simp only [rlhfObj]
    have : ∑ i, q i * rhat i - ∑ i, q i * r i ≤ M := by
      rw [← Finset.sum_sub_distrib]
      have hle : ∀ i ∈ univ, q i * rhat i - q i * r i ≤ q i * M := by
        intro i _
        have := (abs_le.mp (hM i)).1
        nlinarith [(hqprob.pos i).le]
      calc ∑ i, (q i * rhat i - q i * r i) ≤ ∑ i, q i * M := Finset.sum_le_sum hle
        _ = M := by rw [← Finset.sum_mul, hqprob.sum_one, one_mul]
    linarith
  -- the two free energies are within `M`
  have hfe : freeEnergy β ref r - freeEnergy β ref rhat ≤ M :=
    freeEnergy_sub_le hβ href hM
  linarith [hopt, hswap, hfe]

end NeuroSymbolicRLHF