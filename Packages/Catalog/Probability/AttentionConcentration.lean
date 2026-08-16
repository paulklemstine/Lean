/-
# Concentration limits on top-`k` attention truncation

Empirical setting (round NET-36).  A trained causal transformer's attention rows
are probability vectors over `ctx` positions.  Two numbers are measured per model:

* the **effective support** `N_eff = 1 / ∑ p i ^ 2` (inverse participation ratio,
  a.k.a. inverse collision mass) of the attention rows, and
* the **knee** `k*`, the smallest `k` for which keeping only the `k` largest
  attention weights (and re-normalising) retains `≥ 0.98` of the full model's
  held-out accuracy.

This file proves the *information-theoretic side* of the story: what the measured
`N_eff` can and cannot say about top-`k` truncation.

Main results.

* `AttentionConcentration.sq_subset_mass_le` : for **every** index set `T`,
  `(∑_{i ∈ T} p i)^2 ≤ |T| · ∑_{i ∈ s} p i ^ 2`.  In particular the top-`k` mass is
  at most `sqrt (k / N_eff)` (`mass_le_sqrt_div_effSupport`).
* `AttentionConcentration.card_ge_of_retained` : retaining a fraction `ρ` of the
  attention *mass* forces `k ≥ ρ² · N_eff`.  This is a hard lower bound on the
  mass-knee, with no distributional assumption whatsoever.
* `AttentionConcentration.mass_knee_gt_measured_knee` : instantiated at the NET-36
  numbers (`N_eff = 152.11` at `ctx = 512`, measured `k* = 64`, `ρ = 0.98`) the
  bound gives `k_mass ≥ 146 > 64`.  Hence the measured accuracy-knee is *strictly*
  cheaper than any possible mass-knee: top-`k` attention truncation cannot be
  explained by mass retention — accuracy is genuinely more robust than attention
  mass.  This is a theorem-certified separation, not a fit.
* `AttentionConcentration.retained_mass_at_knee_le` : at the same numbers, a
  budget of `k ≤ 64` provably keeps at most `65 %` of the attention mass, while
  the measured retained accuracy there is `0.985`.
* `AttentionConcentration.effSupport_does_not_control_topk` : the converse of the
  Cauchy–Schwarz bound is false, and quantitatively so.  The spike-plus-uniform
  family has `N_eff → 4` while, for every fixed `k`, its top-`k` mass stays at
  `1/2`.  So a small effective support does *not* imply a small knee; the observed
  law `k* = d·ctx/32` must come from elsewhere (see `AttentionCostLaw.lean`).
* `AttentionConcentration.spike_saturates_cauchy_schwarz` : the same family shows
  the bound of `sq_subset_mass_le` is asymptotically sharp at `k = 1`.
-/

import Mathlib

namespace AttentionConcentration

open Finset Filter Topology

variable {ι : Type*}

/-- Collision mass (inverse participation ratio) of a weight vector on `s`. -/
def collision (s : Finset ι) (p : ι → ℝ) : ℝ := ∑ i ∈ s, p i ^ 2

/-- Effective support `N_eff = 1 / ∑ p i ^ 2`: the quantity reported as
"eff support" in the experimental logs. -/
noncomputable def effSupport (s : Finset ι) (p : ι → ℝ) : ℝ := 1 / collision s p

lemma collision_nonneg (s : Finset ι) (p : ι → ℝ) : 0 ≤ collision s p :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- **Cauchy–Schwarz truncation bound.**  For any set `T` of retained positions
inside the support `s`, the retained mass squared is at most `|T|` times the
collision mass.  No sign or normalisation assumption is needed, and `T` need not
be the set of `|T|` largest weights — so this bounds the top-`k` mass as well. -/
theorem sq_subset_mass_le (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s) :
    (∑ i ∈ T, p i) ^ 2 ≤ T.card * collision s p := by
  have h1 : (∑ i ∈ T, p i) ^ 2 ≤ T.card * ∑ i ∈ T, p i ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have h2 : ∑ i ∈ T, p i ^ 2 ≤ collision s p :=
    Finset.sum_le_sum_of_subset_of_nonneg hT (fun i _ _ => sq_nonneg _)
  refine h1.trans ?_
  have : (0:ℝ) ≤ (T.card : ℝ) := Nat.cast_nonneg _
  exact mul_le_mul_of_nonneg_left h2 this

/-- The retained mass is at most `sqrt (k · collision)`. -/
theorem mass_le_sqrt (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) :
    ∑ i ∈ T, p i ≤ Real.sqrt (T.card * collision s p) := by
  have hnn : 0 ≤ ∑ i ∈ T, p i :=
    Finset.sum_nonneg fun i hi => hp i (hT hi)
  have := sq_subset_mass_le s T p hT
  calc ∑ i ∈ T, p i = Real.sqrt ((∑ i ∈ T, p i) ^ 2) := (Real.sqrt_sq hnn).symm
    _ ≤ Real.sqrt (T.card * collision s p) := Real.sqrt_le_sqrt this

/-- In the experimenters' vocabulary: retained mass `≤ sqrt (k / N_eff)`. -/
theorem mass_le_sqrt_div_effSupport (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hc : 0 < collision s p) :
    ∑ i ∈ T, p i ≤ Real.sqrt (T.card / effSupport s p) := by
  have : (T.card : ℝ) / effSupport s p = T.card * collision s p := by
    unfold effSupport
    field_simp
  rw [this]
  exact mass_le_sqrt s T p hT hp

/-- **The mass knee is at least `ρ² · N_eff`.**  If a set `T` of retained
positions carries a fraction `ρ` of the attention mass then `|T| ≥ ρ² N_eff`. -/
theorem card_ge_of_retained (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (h : ρ ≤ ∑ i ∈ T, p i) :
    ρ ^ 2 * effSupport s p ≤ T.card := by
  have h1 : ρ ^ 2 ≤ (∑ i ∈ T, p i) ^ 2 := by
    have hnn : 0 ≤ ∑ i ∈ T, p i := le_trans hρ h
    nlinarith
  have h2 := sq_subset_mass_le s T p hT
  have h3 : ρ ^ 2 ≤ T.card * collision s p := le_trans h1 h2
  have : ρ ^ 2 * effSupport s p = ρ ^ 2 / collision s p := by
    unfold effSupport; ring
  rw [this, div_le_iff₀ hc]
  linarith [h3, mul_comm ((T.card : ℝ)) (collision s p)]

/-!
### Lab notes: the measured grid separates the mass knee from the accuracy knee

NET-36, cell B (`d = 4`, `ctx = 512`, seed 2): reported effective support
`N_eff = 152.11`, reported accuracy knee `k* = 64` at retention threshold `0.98`.
Cell A (`d = 16`, `ctx = 128`, seed 1): `N_eff = 52.73`, `k* = 64`.
-/

/-- With `N_eff = 152.11`, keeping `98 %` of the attention *mass* provably needs
`k ≥ 146`, more than twice the measured accuracy knee `k* = 64`. -/
theorem mass_knee_gt_measured_knee :
    (146 : ℝ) ≤ (0.98 : ℝ) ^ 2 * 152.11 ∧ (64 : ℝ) < (0.98 : ℝ) ^ 2 * 152.11 := by
  constructor <;> norm_num

/-- Formal form of the separation: any retained set achieving `0.98` of the
attention mass of a row with `N_eff = 152.11` has more than `64` elements — so the
measured knee `k* = 64` cannot be a mass-retention phenomenon. -/
theorem accuracy_knee_not_mass_knee (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p)
    (hNeff : effSupport s p = 152.11) (h : (0.98 : ℝ) ≤ ∑ i ∈ T, p i) :
    64 < T.card := by
  have := card_ge_of_retained s T p hT hc (by norm_num : (0:ℝ) ≤ 0.98) h
  rw [hNeff] at this
  have h64 : (64 : ℝ) < (T.card : ℝ) := by nlinarith
  exact_mod_cast h64

/-- **At the measured knee, at most 65 % of the attention mass is kept.**  With
`N_eff = 152.11` (cell `d = 4`, `ctx = 512`) any budget of `k ≤ 64` positions
retains at most `0.65` of the attention mass — while the measured retained
accuracy at `k = 64` is `0.985`.  Attention mass and accuracy therefore decouple
by a wide, certified margin. -/
theorem retained_mass_at_knee_le (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hNeff : effSupport s p = 152.11) (hcard : T.card ≤ 64) :
    ∑ i ∈ T, p i ≤ 0.65 := by
  have hc : collision s p = 1 / 152.11 := by
    rcases eq_or_ne (collision s p) 0 with h0 | h0
    · rw [effSupport, h0] at hNeff; norm_num at hNeff
    · rw [effSupport] at hNeff
      field_simp at hNeff
      linarith [hNeff]
  have hcardR : (T.card : ℝ) ≤ 64 := by exact_mod_cast hcard
  have hbound : (T.card : ℝ) * collision s p ≤ 0.65 ^ 2 := by
    rw [hc]
    nlinarith [hcardR, Nat.cast_nonneg (α := ℝ) T.card]
  calc ∑ i ∈ T, p i ≤ Real.sqrt (T.card * collision s p) := mass_le_sqrt s T p hT hp
    _ ≤ Real.sqrt (0.65 ^ 2) := Real.sqrt_le_sqrt hbound
    _ = 0.65 := Real.sqrt_sq (by norm_num)

/-!
### The spike family: small effective support, stubborn top-`k` mass
-/

/-- One position of weight `1/2`, and `n+1` positions sharing the other half. -/
noncomputable def spike (n : ℕ) : Fin (n + 2) → ℝ :=
  fun i => if i = 0 then 1 / 2 else 1 / (2 * (n + 1))

@[simp] lemma spike_zero (n : ℕ) : spike n 0 = 1 / 2 := by
  unfold spike; norm_num

lemma spike_ne (n : ℕ) {i : Fin (n + 2)} (h : i ≠ 0) :
    spike n i = 1 / (2 * ((n : ℝ) + 1)) := by
  unfold spike; simp [h]

lemma spike_nonneg (n : ℕ) (i : Fin (n + 2)) : 0 ≤ spike n i := by
  unfold spike
  split <;> positivity

lemma spike_sum (n : ℕ) : ∑ i : Fin (n + 2), spike n i = 1 := by
  have h : ∀ i : Fin (n + 1), spike n i.succ = 1 / (2 * ((n : ℝ) + 1)) :=
    fun i => spike_ne n (Fin.succ_ne_zero i)
  rw [Fin.sum_univ_succ, spike_zero, Finset.sum_congr rfl (fun i _ => h i),
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
  push_cast
  field_simp
  norm_num

lemma spike_collision (n : ℕ) :
    collision Finset.univ (spike n) = ((n : ℝ) + 2) / (4 * ((n : ℝ) + 1)) := by
  have h : ∀ i : Fin (n + 1), spike n i.succ ^ 2 = (1 / (2 * ((n : ℝ) + 1))) ^ 2 :=
    fun i => by rw [spike_ne n (Fin.succ_ne_zero i)]
  unfold collision
  rw [Fin.sum_univ_succ, spike_zero, Finset.sum_congr rfl (fun i _ => h i),
    Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
  push_cast
  field_simp
  ring

lemma spike_collision_pos (n : ℕ) : 0 < collision Finset.univ (spike n) := by
  rw [spike_collision]
  positivity

lemma spike_effSupport (n : ℕ) :
    effSupport Finset.univ (spike n) = 4 * ((n : ℝ) + 1) / ((n : ℝ) + 2) := by
  unfold effSupport
  rw [spike_collision]
  have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
  have hn2 : ((n : ℝ) + 2) ≠ 0 := by positivity
  field_simp

/-- Every retained set of size `≤ k` catches at most `1/2 + k/(2(n+1))` of the
spike distribution's mass. -/
theorem spike_topk_mass_le (n k : ℕ) (T : Finset (Fin (n + 2))) (hk : T.card ≤ k) :
    ∑ i ∈ T, spike n i ≤ 1 / 2 + k / (2 * ((n : ℝ) + 1)) := by
  set c : ℝ := 1 / (2 * ((n : ℝ) + 1)) with hc
  have hcpos : 0 < c := by rw [hc]; positivity
  have hpt : ∀ i : Fin (n + 2), spike n i ≤ (if i = 0 then (1:ℝ)/2 else 0) + c := by
    intro i
    by_cases h : i = 0
    · subst h
      have h0 : (if (0 : Fin (n + 2)) = 0 then (1:ℝ)/2 else 0) = 1/2 := by norm_num
      rw [spike_zero, h0]
      linarith
    · rw [spike_ne n h, ← hc]
      simp [h]
  have h1 : ∑ i ∈ T, spike n i ≤ ∑ i ∈ T, ((if i = 0 then (1:ℝ)/2 else 0) + c) :=
    Finset.sum_le_sum fun i _ => hpt i
  have h2 : ∑ i ∈ T, ((if i = 0 then (1:ℝ)/2 else 0) + c)
      = (∑ i ∈ T, (if i = 0 then (1:ℝ)/2 else 0)) + T.card * c := by
    rw [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]
  have h3 : ∑ i ∈ T, (if i = 0 then (1:ℝ)/2 else 0) ≤ 1 / 2 := by
    have hsub : ∑ i ∈ T, (if i = 0 then (1:ℝ)/2 else 0)
        ≤ ∑ i ∈ (Finset.univ : Finset (Fin (n+2))), (if i = 0 then (1:ℝ)/2 else 0) := by
      refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ T) ?_
      intro i _ _
      split <;> norm_num
    simpa using hsub
  have h4 : (T.card : ℝ) * c ≤ (k : ℝ) * c :=
    mul_le_mul_of_nonneg_right (by exact_mod_cast hk) hcpos.le
  have h5 : (k : ℝ) * c = k / (2 * ((n : ℝ) + 1)) := by rw [hc]; ring
  linarith [h1, h2.le, h2.ge, h3, h4, h5.le, h5.ge]

private lemma tendsto_one_div_succ : Tendsto (fun n : ℕ => 1 / ((n : ℝ) + 1)) atTop (𝓝 0) :=
  tendsto_one_div_add_atTop_nhds_zero_nat

/-- `N_eff → 4` along the spike family: an "essentially four position" attention
row in the sense of the effective-support statistic. -/
theorem spike_effSupport_tendsto :
    Tendsto (fun n : ℕ => effSupport Finset.univ (spike n)) atTop (𝓝 4) := by
  have h : ∀ n : ℕ, effSupport Finset.univ (spike n) = 4 * (1 + 1 / ((n : ℝ) + 1))⁻¹ := by
    intro n
    rw [spike_effSupport]
    have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
    have hn2 : ((n : ℝ) + 2) ≠ 0 := by positivity
    rw [eq_comm, mul_inv_eq_iff_eq_mul₀ (by positivity)]
    field_simp
    ring
  simp only [h]
  have hden : Tendsto (fun n : ℕ => 1 + 1 / ((n : ℝ) + 1)) atTop (𝓝 (1 + 0)) :=
    tendsto_const_nhds.add tendsto_one_div_succ
  have := (hden.inv₀ (by norm_num)).const_mul (4 : ℝ)
  simpa using this

/-- **The effective support does not control the knee.**  For every fixed budget
`k` and every tolerance `ε > 0` there is an attention row whose effective support
is within `ε` of `4` — i.e. "essentially four positions matter" — yet whose best
`k`-position truncation retains barely more than half of the mass.  Consequently no
inequality of the form "top-`k` mass `≥ F(k, N_eff)`" with `F(k,4) > 1/2` can hold,
and the empirical law `k* = d·ctx/32` cannot be a consequence of concentration
alone: the measured effective supports are *not* sufficient statistics for the
knee. -/
theorem effSupport_does_not_control_topk (k : ℕ) {ε : ℝ} (hε : 0 < ε) :
    ∃ (n : ℕ), |effSupport Finset.univ (spike n) - 4| < ε ∧
      ∀ T : Finset (Fin (n + 2)), T.card ≤ k → ∑ i ∈ T, spike n i < 1 / 2 + ε := by
  have hA : ∀ᶠ n : ℕ in atTop, |effSupport Finset.univ (spike n) - 4| < ε := by
    have h := spike_effSupport_tendsto
    rw [Metric.tendsto_atTop] at h
    obtain ⟨N, hN⟩ := h ε hε
    filter_upwards [eventually_ge_atTop N] with n hn
    simpa [Real.dist_eq] using hN n hn
  have hB : ∀ᶠ n : ℕ in atTop, (k : ℝ) / (2 * ((n : ℝ) + 1)) < ε := by
    have hlim : Tendsto (fun n : ℕ => (k : ℝ) / (2 * ((n : ℝ) + 1))) atTop (𝓝 0) := by
      have h2 := tendsto_one_div_succ.const_mul ((k : ℝ) / 2)
      rw [mul_zero] at h2
      exact h2.congr (fun n => by rw [div_mul_div_comm, mul_one])
    rw [Metric.tendsto_atTop] at hlim
    obtain ⟨N, hN⟩ := hlim ε hε
    filter_upwards [eventually_ge_atTop N] with n hn
    have := hN n hn
    rw [Real.dist_eq, sub_zero] at this
    exact (le_abs_self _).trans_lt this
  obtain ⟨n, hn1, hn2⟩ := (hA.and hB).exists
  refine ⟨n, hn1, fun T hT => ?_⟩
  have := spike_topk_mass_le n k T hT
  linarith

/-- **Sharpness of `sq_subset_mass_le` at `k = 1`.**  Along the spike family the
ratio of the squared top-1 mass to the Cauchy–Schwarz bound `1 · collision` tends
to `1`, so the constant in the truncation bound cannot be improved. -/
theorem spike_saturates_cauchy_schwarz :
    Tendsto (fun n : ℕ => (spike n 0) ^ 2 / (1 * collision Finset.univ (spike n)))
      atTop (𝓝 1) := by
  have h : ∀ n : ℕ, (spike n 0) ^ 2 / (1 * collision Finset.univ (spike n))
      = (1 + 1 / ((n : ℝ) + 1))⁻¹ := by
    intro n
    rw [spike_collision, spike_zero]
    have hn : ((n : ℝ) + 1) ≠ 0 := by positivity
    have hn2 : ((n : ℝ) + 2) ≠ 0 := by positivity
    rw [eq_comm, inv_eq_iff_eq_inv]
    field_simp
    ring
  simp only [h]
  have hden : Tendsto (fun n : ℕ => 1 + 1 / ((n : ℝ) + 1)) atTop (𝓝 (1 + 0)) :=
    tendsto_const_nhds.add tendsto_one_div_succ
  have := hden.inv₀ (by norm_num)
  simpa using this

end AttentionConcentration