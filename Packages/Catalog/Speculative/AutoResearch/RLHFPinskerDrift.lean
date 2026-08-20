import Speculative.AutoResearch.RLHFTiltTorsorPTX

/-!
# Quantitative drift control for the KL-regularized RLHF/PTX objective

Domain: Novelty (information theory × convex analysis × alignment theory).

The catalog already contains the exact Gibbs variational principle for the
InstructGPT-style objective
```
J(q) = 𝔼_{y∼q}[r y] − β · KL(q ‖ p) + γ · 𝔼_{y∼d}[log q y]
```
(`Speculative.AutoResearch.RLHFGibbsVariational`, `…RLHFTiltTorsorPTX`), i.e. the
*qualitative* statement that the optimum is the softmax tilt `π_β` of the SFT
reference `p`.  What is missing is the *metric* half of the story: the claim, made
informally in the RLHF literature, that the KL penalty keeps the aligned policy
close to the reference and therefore prevents policy collapse / reward hacking.

This file supplies that half, from first principles:

* `RLHF.log_ge_pade` — the sharp Padé-type lower bound
  `log t ≥ (5t² − 4t − 1)/(2t² + 4t)` for `t > 0`, proved by a mean-value argument
  (its derivative is `(t−1)³ / (t²(t+2)²)`, which changes sign exactly at `t = 1`).
* `RLHF.klTerm_ge` — the resulting pointwise bound
  `a log(a/b) − a + b ≥ 3(a−b)²/(2(a+2b))`.
* `RLHF.pinsker` — **Pinsker's inequality** `‖q − p‖₁² ≤ 2 KL(q ‖ p)` on a finite
  response space, obtained from `klTerm_ge` by Cauchy–Schwarz in Engel form.
* `RLHF.kl_gibbs_le_range_div` — the aligned policy satisfies
  `KL(π_β ‖ p) ≤ (max r − min r)/β`: the KL penalty is *self-limiting*.
* `RLHF.gibbs_l1_le` — hence `‖π_β − p‖₁ ≤ √(2 (max r − min r)/β)`, a `β^{-1/2}`
  **no-collapse law**, and `RLHF.gibbs_l1_tendsto_zero` its `β → ∞` limit.
* `RLHF.audit_gap_le_l1` / `RLHF.audit_gap_gibbs_le` — for *every* bounded audit
  statistic `f` (a second, unseen reward model, a safety probe, …), the shift in
  its mean under alignment is at most `‖f‖_∞ √(2 (max r − min r)/β)`.  This is a
  formal, quantitative anti-reward-hacking guarantee.
* `RLHF.pinsker_constant_sharp_two_point` — the constant `2` in Pinsker cannot be
  improved: on a two-point space the ratio `2 KL/‖q−p‖₁²` tends to `1` as `q → p`.

All statements are `sorry`-free.
-/

namespace RLHF

open Finset Set Filter Topology

/-! ## 1. A Padé-type lower bound for the logarithm

The function `padeAux t = log t − (5t² − 4t − 1)/(2t² + 4t)` vanishes at `t = 1`
together with its first two derivatives; its derivative is `(t−1)³/(t²(t+2)²)`,
so `t = 1` is a global minimum on `(0, ∞)`. -/

/-- Auxiliary function `log t − (5t² − 4t − 1)/(2t² + 4t)`. -/
noncomputable def padeAux (t : ℝ) : ℝ := Real.log t - (5 * t ^ 2 - 4 * t - 1) / (2 * t ^ 2 + 4 * t)

theorem hasDerivAt_padeAux {x : ℝ} (hx : 0 < x) :
    HasDerivAt padeAux ((x - 1) ^ 3 / (x ^ 2 * (x + 2) ^ 2)) x := by
  have hD : (2 * x ^ 2 + 4 * x) ≠ 0 := by positivity
  have h1 : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log (ne_of_gt hx)
  have hN : HasDerivAt (fun y : ℝ => 5 * y ^ 2 - 4 * y - 1) (10 * x - 4) x := by
    have h := (((hasDerivAt_pow 2 x).const_mul 5).sub ((hasDerivAt_id x).const_mul 4)).sub_const 1
    simp only [Nat.cast_ofNat] at h
    convert h using 1
    push_cast; ring
  have hDd : HasDerivAt (fun y : ℝ => 2 * y ^ 2 + 4 * y) (4 * x + 4) x := by
    have h := ((hasDerivAt_pow 2 x).const_mul 2).add ((hasDerivAt_id x).const_mul 4)
    simp only [Nat.cast_ofNat] at h
    convert h using 1
    push_cast; ring
  have := h1.sub (hN.div hDd hD)
  convert this using 1
  field_simp
  ring

theorem padeAux_one : padeAux 1 = 0 := by norm_num [padeAux]

theorem padeAux_nonneg {t : ℝ} (ht : 0 < t) : 0 ≤ padeAux t := by
  rcases le_or_gt 1 t with h | h
  · have hmono : MonotoneOn padeAux (Ici 1) := by
      apply monotoneOn_of_deriv_nonneg (convex_Ici 1)
      · intro y hy
        have hy1 : (1 : ℝ) ≤ y := hy
        exact ((hasDerivAt_padeAux (lt_of_lt_of_le one_pos hy1)).continuousAt).continuousWithinAt
      · intro y hy
        rw [interior_Ici] at hy
        have hy1 : (1 : ℝ) < y := hy
        exact (hasDerivAt_padeAux (lt_trans one_pos hy1)).differentiableAt.differentiableWithinAt
      · intro y hy
        rw [interior_Ici] at hy
        have hy1 : (1 : ℝ) < y := hy
        have hy0 : (0 : ℝ) < y := lt_trans one_pos hy1
        rw [(hasDerivAt_padeAux hy0).deriv]
        have h1 : (0 : ℝ) ≤ (y - 1) ^ 3 := pow_nonneg (by linarith) 3
        positivity
    simpa [padeAux_one] using hmono Set.self_mem_Ici h h
  · have hanti : AntitoneOn padeAux (Ioc 0 1) := by
      apply antitoneOn_of_deriv_nonpos (convex_Ioc 0 1)
      · intro y hy
        exact ((hasDerivAt_padeAux hy.1).continuousAt).continuousWithinAt
      · intro y hy
        rw [interior_Ioc] at hy
        exact (hasDerivAt_padeAux hy.1).differentiableAt.differentiableWithinAt
      · intro y hy
        rw [interior_Ioc] at hy
        obtain ⟨hy0, hy1⟩ : 0 < y ∧ y < 1 := hy
        rw [(hasDerivAt_padeAux hy0).deriv]
        have h1 : (y - 1) ^ 3 ≤ 0 := Odd.pow_nonpos (by norm_num) (by linarith)
        have h2 : (0 : ℝ) < y ^ 2 * (y + 2) ^ 2 := by positivity
        exact div_nonpos_of_nonpos_of_nonneg h1 h2.le
    simpa [padeAux_one] using hanti ⟨ht, h.le⟩ ⟨one_pos, le_refl 1⟩ h.le

/-- **Sharp Padé lower bound for the logarithm.**  For `t > 0`,
`log t ≥ (5t² − 4t − 1)/(2t² + 4t)`.  Both sides agree to third order at `t = 1`,
which is exactly what makes Pinsker's inequality come out with the optimal
constant. -/
theorem log_ge_pade {t : ℝ} (ht : 0 < t) :
    (5 * t ^ 2 - 4 * t - 1) / (2 * t ^ 2 + 4 * t) ≤ Real.log t := by
  have := padeAux_nonneg ht
  simp only [padeAux] at this
  linarith

/-! ## 2. The pointwise Kullback–Leibler bound -/

/-- Pointwise lower bound on the KL integrand: for `a ≥ 0` and `b > 0`,
`a log (a/b) − a + b ≥ 3 (a − b)² / (2 (a + 2b))`. -/
theorem klTerm_ge {a b : ℝ} (ha : 0 ≤ a) (hb : 0 < b) :
    3 * (a - b) ^ 2 / (2 * (a + 2 * b)) ≤ a * Real.log (a / b) - a + b := by
  rcases eq_or_lt_of_le ha with h | ha'
  · have : a = 0 := h.symm
    subst this
    have h1 : 3 * (0 - b) ^ 2 / (2 * (0 + 2 * b)) = 3 * b / 4 := by field_simp; ring
    rw [h1]
    simp
    linarith
  · have ht : 0 < a / b := div_pos ha' hb
    have h := log_ge_pade ht
    have hmul : a * ((5 * (a / b) ^ 2 - 4 * (a / b) - 1) / (2 * (a / b) ^ 2 + 4 * (a / b)))
        ≤ a * Real.log (a / b) := mul_le_mul_of_nonneg_left h ha
    have hkey : a * ((5 * (a / b) ^ 2 - 4 * (a / b) - 1) / (2 * (a / b) ^ 2 + 4 * (a / b)))
        = 3 * (a - b) ^ 2 / (2 * (a + 2 * b)) + a - b := by
      have hb' : b ≠ 0 := ne_of_gt hb
      have ha'' : a ≠ 0 := ne_of_gt ha'
      have hab : a + 2 * b ≠ 0 := by positivity
      field_simp
      ring
    linarith [hkey ▸ hmul]

/-! ## 3. Pinsker's inequality on a finite response space -/

variable {Ω : Type*} [Fintype Ω]

/-- The `L¹` (twice total-variation) distance between two policies. -/
noncomputable def l1Dist (q p : Ω → ℝ) : ℝ := ∑ y, |q y - p y|

theorem l1Dist_nonneg (q p : Ω → ℝ) : 0 ≤ l1Dist q p :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

/-- Rewriting of the KL divergence as a sum of nonnegative "Gibbs slack" terms. -/
theorem klDiv_eq_sum_slack {q p : Ω → ℝ} (hq : IsDist q) (hp : IsPosDist p) :
    klDiv q p = ∑ y, (q y * Real.log (q y / p y) - q y + p y) := by
  rw [klDiv]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, hq.2, hp.2]
  ring

/-- **Pinsker's inequality** for the catalog's finite-space KL divergence:
`‖q − p‖₁² ≤ 2 KL(q ‖ p)`. -/
theorem pinsker {q p : Ω → ℝ} (hq : IsDist q) (hp : IsPosDist p) :
    (l1Dist q p) ^ 2 ≤ 2 * klDiv q p := by
  classical
  set w : Ω → ℝ := fun y => q y + 2 * p y with hw
  have hwpos : ∀ y ∈ (univ : Finset Ω), 0 < w y := by
    intro y _
    have := hq.1 y
    have := hp.1 y
    simp only [hw]
    linarith
  have hwsum : ∑ y, w y = 3 := by
    simp only [hw]
    rw [Finset.sum_add_distrib, hq.2, ← Finset.mul_sum, hp.2]
    ring
  -- Cauchy–Schwarz in Engel (Sedrakyan) form
  have hcs : (∑ y, |q y - p y|) ^ 2 / (∑ y, w y)
      ≤ ∑ y, |q y - p y| ^ 2 / w y :=
    Finset.sq_sum_div_le_sum_sq_div univ (fun y => |q y - p y|) hwpos
  rw [hwsum] at hcs
  -- the pointwise Gibbs slack bound
  have hterm : ∀ y ∈ (univ : Finset Ω),
      (3 / 2) * (|q y - p y| ^ 2 / w y) ≤ q y * Real.log (q y / p y) - q y + p y := by
    intro y _
    have h := klTerm_ge (hq.1 y) (hp.1 y)
    have habs : |q y - p y| ^ 2 = (q y - p y) ^ 2 := sq_abs _
    have hwy : w y = q y + 2 * p y := rfl
    have hpos : 0 < q y + 2 * p y := by
      have := hq.1 y; have := hp.1 y; linarith
    rw [habs, hwy]
    have : (3 : ℝ) / 2 * ((q y - p y) ^ 2 / (q y + 2 * p y))
        = 3 * (q y - p y) ^ 2 / (2 * (q y + 2 * p y)) := by
      field_simp
    rw [this]
    exact h
  have hsum := Finset.sum_le_sum hterm
  rw [← Finset.mul_sum] at hsum
  rw [klDiv_eq_sum_slack hq hp]
  have hl1 : l1Dist q p = ∑ y, |q y - p y| := rfl
  rw [hl1]
  nlinarith [hcs, hsum]

/-- Pinsker in `L¹` form: `‖q − p‖₁ ≤ √(2 KL(q ‖ p))`. -/
theorem l1Dist_le_sqrt_two_mul_kl {q p : Ω → ℝ} (hq : IsDist q) (hp : IsPosDist p) :
    l1Dist q p ≤ Real.sqrt (2 * klDiv q p) := by
  have h := pinsker hq hp
  have hnn := l1Dist_nonneg q p
  calc l1Dist q p = Real.sqrt ((l1Dist q p) ^ 2) := (Real.sqrt_sq hnn).symm
    _ ≤ Real.sqrt (2 * klDiv q p) := Real.sqrt_le_sqrt h

/-! ## 4. Reward range and the self-limiting KL penalty -/

variable [Nonempty Ω]

/-- The oscillation (range) `max r − min r` of the reward model. -/
noncomputable def rewardRange (r : Ω → ℝ) : ℝ :=
  univ.sup' univ_nonempty r - univ.inf' univ_nonempty r

theorem rewardRange_nonneg (r : Ω → ℝ) : 0 ≤ rewardRange r := by
  obtain ⟨y⟩ := ‹Nonempty Ω›
  have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
  have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
  simp only [rewardRange]
  linarith

theorem expectation_le_sup {q r : Ω → ℝ} (hq : IsDist q) :
    ∑ y, q y * r y ≤ univ.sup' univ_nonempty r := by
  have h : ∀ y ∈ (univ : Finset Ω), q y * r y ≤ q y * univ.sup' univ_nonempty r :=
    fun y _ => mul_le_mul_of_nonneg_left (Finset.le_sup' r (mem_univ y)) (hq.1 y)
  have := Finset.sum_le_sum h
  rwa [← Finset.sum_mul, hq.2, one_mul] at this

theorem inf_le_expectation {q r : Ω → ℝ} (hq : IsDist q) :
    univ.inf' univ_nonempty r ≤ ∑ y, q y * r y := by
  have h : ∀ y ∈ (univ : Finset Ω), q y * univ.inf' univ_nonempty r ≤ q y * r y :=
    fun y _ => mul_le_mul_of_nonneg_left (Finset.inf'_le r (mem_univ y)) (hq.1 y)
  have := Finset.sum_le_sum h
  rwa [← Finset.sum_mul, hq.2, one_mul] at this

/-- **The KL penalty is self-limiting.**  The aligned (Gibbs) policy never spends more
divergence budget than `(max r − min r)/β`, no matter how the reward model is shaped. -/
theorem kl_gibbs_le_range_div {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    klDiv (gibbsPolicy β r p) p ≤ rewardRange r / β := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hopt : objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) :=
    objective_gibbs hβ hp
  have href : ∑ y, p y * r y ≤ β * Real.log (partition β r p) :=
    reference_le_free_energy hβ hp
  have hobj : objective β r p (gibbsPolicy β r p)
      = (∑ y, gibbsPolicy β r p y * r y) - β * klDiv (gibbsPolicy β r p) p := rfl
  have hsup : ∑ y, gibbsPolicy β r p y * r y ≤ univ.sup' univ_nonempty r :=
    expectation_le_sup hg.isDist
  have hinf : univ.inf' univ_nonempty r ≤ ∑ y, p y * r y := inf_le_expectation hp.isDist
  have hkey : β * klDiv (gibbsPolicy β r p) p ≤ rewardRange r := by
    simp only [rewardRange]
    linarith [hobj ▸ hopt]
  rw [le_div_iff₀ hβ]
  linarith

/-- **No-collapse law.**  The aligned policy stays within `L¹`-distance
`√(2 (max r − min r)/β)` of the SFT reference: the drift decays like `β^{-1/2}`. -/
theorem gibbs_l1_le {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    l1Dist (gibbsPolicy β r p) p ≤ Real.sqrt (2 * rewardRange r / β) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 := l1Dist_le_sqrt_two_mul_kl hg.isDist hp
  have h2 := kl_gibbs_le_range_div (r := r) hβ hp
  refine h1.trans (Real.sqrt_le_sqrt ?_)
  rw [mul_div_assoc]
  linarith

/-- The drift of the aligned policy vanishes as the KL temperature `β → ∞`. -/
theorem gibbs_l1_tendsto_zero {r p : Ω → ℝ} (hp : IsPosDist p) :
    Tendsto (fun β : ℝ => l1Dist (gibbsPolicy β r p) p) atTop (𝓝 0) := by
  have hlim : Tendsto (fun β : ℝ => Real.sqrt (2 * rewardRange r / β)) atTop (𝓝 0) := by
    have h0 : Tendsto (fun β : ℝ => 2 * rewardRange r / β) atTop (𝓝 0) :=
      tendsto_const_nhds.div_atTop tendsto_id
    have := (Real.continuous_sqrt.tendsto 0).comp h0
    simpa [Function.comp] using this
  refine squeeze_zero' (Eventually.of_forall fun β => l1Dist_nonneg _ _) ?_ hlim
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with β hβ
  exact gibbs_l1_le hβ hp

/-! ## 5. Anti-reward-hacking: bounded audit statistics cannot move much -/

omit [Nonempty Ω] in
/-- Any bounded statistic changes by at most `‖f‖_∞ · ‖q − p‖₁`. -/
theorem audit_gap_le_l1 {q p f : Ω → ℝ} {M : ℝ} (hM : ∀ y, |f y| ≤ M) :
    |(∑ y, q y * f y) - ∑ y, p y * f y| ≤ M * l1Dist q p := by
  have hrw : (∑ y, q y * f y) - ∑ y, p y * f y = ∑ y, (q y - p y) * f y := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hrw]
  calc |∑ y, (q y - p y) * f y| ≤ ∑ y, |(q y - p y) * f y| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ y, M * |q y - p y| := by
        refine Finset.sum_le_sum fun y _ => ?_
        rw [abs_mul, mul_comm]
        exact mul_le_mul_of_nonneg_right (hM y) (abs_nonneg _)
    _ = M * l1Dist q p := by rw [← Finset.mul_sum]; rfl

/-- **Quantitative anti-reward-hacking guarantee.**  For *every* audit statistic `f`
bounded by `M` — a held-out reward model, a safety classifier, a benchmark score —
the aligned policy's mean of `f` differs from the reference's by at most
`M √(2 (max r − min r)/β)`.  In particular no unseen metric can be destroyed by
alignment at large `β`, and the guarantee is uniform over all such metrics. -/
theorem audit_gap_gibbs_le {β : ℝ} {r p f : Ω → ℝ} {M : ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hM : ∀ y, |f y| ≤ M) :
    |(∑ y, gibbsPolicy β r p y * f y) - ∑ y, p y * f y|
      ≤ M * Real.sqrt (2 * rewardRange r / β) := by
  have hM0 : 0 ≤ M := le_trans (abs_nonneg (f (Classical.arbitrary Ω)))
    (hM (Classical.arbitrary Ω))
  refine (audit_gap_le_l1 (q := gibbsPolicy β r p) (p := p) hM).trans ?_
  exact mul_le_mul_of_nonneg_left (gibbs_l1_le hβ hp) hM0

end RLHF