/-
# Cycle three: the margin law, and what the depth drift of `N_eff` can be

This file closes the two conjectures that the second cycle left open in
`FUTURE_DIRECTIONS.md`:

* **C1 — the margin law.**  `AttentionTruncationOutput.retention_threshold` shows
  that a top-`k` truncation keeps the prediction as soon as the retained mass
  `ρ` exceeds `1 - m/(4·L·B)`, where `m` is the logit margin and `L·B` the
  read-out constant.  Combining that threshold with the scale-free tail of
  `AttentionCostLaw.zipfTail` pins the *deficit at the knee* two-sidedly:

  `m/(8·L·B) ≤ 1 - ρ(k*) ≤ m/(4·L·B)`,

  i.e. `1 - ρ(k*) = Θ(m/(L·B))` with explicit constants `1/8` and `1/4`
  (`margin_law_theta`).  The knee itself is antitone in the margin
  (`marginKnee_antitone`) and scales exactly like `1/m`
  (`marginKnee_inverse_scaling`).  At the measured long-context cell the
  certified mass ceiling `ρ ≤ 0.65` turns the margin channel into a falsifiable
  numeric prediction: if the retention threshold is what explains the measured
  `0.985` retained accuracy at `k = 64`, then the held-out logit margin must
  satisfy `m > 1.4·L·B` (`netB_margin_channel_lower_bound`).

* **C2 — is the depth drift of `N_eff` a drift of the Zipf amplitude?**  The
  answer, under the model that produced the law, is **no**.  Two independent
  facts are proved here.  First, a scale-free tail of amplitude `A` *caps* the
  effective support: `N_eff ≤ 8·A·ctx + 4` (`effSupport_le_eight_amplitude`),
  equivalently the concentration measurement bounds the amplitude from below,
  `A·ctx ≥ (N_eff - 4)/8` (`amplitude_ge_of_effSupport`).  Second, a
  depth-*linear* knee forces the amplitude to be exactly `δ/32` at every depth
  (`amplitude_forced_by_depth_linear_knee`), so `A` is depth-independent and the
  product `A(d)·d` is *not* constant but grows linearly in `d`
  (`amplitude_times_depth_not_constant`) — the form conjectured in C2 is
  refuted.  Consequently the model predicts a single depth-independent ceiling
  `N_eff ≤ δ·ctx/4 + 4` (`effSupport_ceiling_depth_independent`), under which
  the measured drift `46.6 → 50.2 → 52.7` sits; and the deepest measured cell
  turns that ceiling into a lower bound on the end-to-end error budget,
  `δ ≥ 1.52` (`netA_budget_lower_bound`).

Everything below is proved from the definitions of the earlier files; the only
imported numbers are the logged values `N_eff = 152.11` (cell B, `d = 4`,
`ctx = 512`) and `N_eff = 52.73` (cell A, `d = 16`, `ctx = 128`).
-/

import Mathlib
import Probability.AttentionConcentration
import Probability.AttentionCostLaw
import Probability.AttentionTruncationOutput

namespace AttentionMarginLaw

open Finset AttentionConcentration AttentionCostLaw

/-!
## 1.  The margin law (conjecture C1)
-/

/-- The budget selected by the margin channel: the least top-`k` budget whose
scale-free tail `A·ctx/k` fits inside the retention threshold `m/(4·L·B)` of
`AttentionTruncation.retention_threshold`. -/
noncomputable def marginKnee (A ctx L B m : ℝ) : ℕ := ⌈4 * L * B * A * ctx / m⌉₊

/-- `marginKnee` is exactly the least sufficient budget for the margin channel. -/
theorem marginKnee_isLeast {A ctx L B m : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m) :
    IsLeast {k : ℕ | 0 < k ∧ zipfTail A ctx k ≤ m / (4 * L * B)}
      (marginKnee A ctx L B m) := by
  have hδ : 0 < m / (4 * L * B) := by positivity
  have h := kStar_isLeast (A := A) (ctx := ctx) (δ := m / (4 * L * B)) (d := 1)
    hA hctx hδ (by norm_num)
  have hidx : A * ((1 : ℕ) : ℝ) * ctx / (m / (4 * L * B))
      = 4 * L * B * A * ctx / m := by
    push_cast
    field_simp
  rw [hidx] at h
  have hset : {k : ℕ | 0 < k ∧ ((1 : ℕ) : ℝ) * zipfTail A ctx k ≤ m / (4 * L * B)}
      = {k : ℕ | 0 < k ∧ zipfTail A ctx k ≤ m / (4 * L * B)} := by
    ext k; simp
  rw [hset] at h
  exact h

/-- **Upper half of the margin law.**  At the margin knee the attention deficit
is at most the threshold `m/(4·L·B)`. -/
theorem margin_law_upper {A ctx L B m : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m) :
    zipfTail A ctx (marginKnee A ctx L B m) ≤ m / (4 * L * B) :=
  (marginKnee_isLeast hA hctx hL hB hm).1.2

/-- **Lower half of the margin law.**  Whenever the margin channel actually
bites (`4·L·B·A·ctx/m ≥ 1`, i.e. the knee is not the trivial budget `k = 1`),
the deficit at the knee is at least half the threshold.  Together with
`margin_law_upper` this is the two-sided statement `1 - ρ(k*) = Θ(m/(L·B))`. -/
theorem margin_law_lower {A ctx L B m : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m)
    (hbite : 1 ≤ 4 * L * B * A * ctx / m) :
    m / (8 * L * B) ≤ zipfTail A ctx (marginKnee A ctx L B m) := by
  set x : ℝ := 4 * L * B * A * ctx / m with hx
  have hx0 : 0 < x := lt_of_lt_of_le zero_lt_one hbite
  have hceil : ((marginKnee A ctx L B m : ℕ) : ℝ) ≤ 2 * x := by
    have h1 : ((⌈x⌉₊ : ℕ) : ℝ) < x + 1 := Nat.ceil_lt_add_one hx0.le
    have : x + 1 ≤ 2 * x := by linarith
    exact le_trans h1.le this
  have hkpos : (0 : ℝ) < ((marginKnee A ctx L B m : ℕ) : ℝ) := by
    have : 0 < ⌈x⌉₊ := Nat.ceil_pos.mpr hx0
    exact_mod_cast this
  have hstep : A * ctx / (2 * x) ≤ zipfTail A ctx (marginKnee A ctx L B m) := by
    unfold zipfTail
    exact div_le_div_of_nonneg_left (by positivity) hkpos hceil
  have hval : A * ctx / (2 * x) = m / (8 * L * B) := by
    rw [hx]
    field_simp
    ring
  linarith [hstep, hval.le, hval.ge]

/-- **C1, closed: the margin law.**  At the budget chosen by the margin channel,
the attention deficit `1 - ρ(k*)` is squeezed between `m/(8·L·B)` and
`m/(4·L·B)`: it is `Θ(m/(L·B))`, governed by the held-out logit margin and the
read-out constant alone — not by any fixed mass level such as `0.98`. -/
theorem margin_law_theta {A ctx L B m : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m)
    (hbite : 1 ≤ 4 * L * B * A * ctx / m) :
    m / (8 * L * B) ≤ zipfTail A ctx (marginKnee A ctx L B m) ∧
      zipfTail A ctx (marginKnee A ctx L B m) ≤ m / (4 * L * B) :=
  ⟨margin_law_lower hA hctx hL hB hm hbite, margin_law_upper hA hctx hL hB hm⟩

/-- The margin knee is antitone in the margin: a model with a healthier margin
needs a strictly smaller (never a larger) top-`k` budget. -/
theorem marginKnee_antitone {A ctx L B m m' : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m) (hmm : m ≤ m') :
    marginKnee A ctx L B m' ≤ marginKnee A ctx L B m := by
  refine Nat.ceil_mono ?_
  have hnum : 0 ≤ 4 * L * B * A * ctx := by positivity
  exact div_le_div_of_nonneg_left hnum hm hmm

/-- The margin knee scales exactly like `1/m`: scaling the margin by `c > 0`
scales the real budget `4·L·B·A·ctx/m` by `1/c`.  (The integer knee is its
ceiling, so this is the exact statement before rounding.) -/
theorem marginKnee_inverse_scaling {A ctx L B m c : ℝ} (hm : 0 < m) (hc : 0 < c) :
    4 * L * B * A * ctx / (c * m) = (1 / c) * (4 * L * B * A * ctx / m) := by
  field_simp

/-!
### Lab note: the margin channel at the measured long-context cell

Cell B (`d = 4`, `ctx = 512`, seed 2): `N_eff = 152.11`, `k* = 64`, retained
accuracy `0.985`.  `AttentionConcentration.retained_mass_at_knee_le` certifies
that at most `0.65` of the attention *mass* survives there.
-/

/-- **The margin channel is quantitatively expensive at cell B.**  Suppose the
measured survival of the prediction at the knee `k ≤ 64` of the `N_eff = 152.11`
cell is explained by the retention threshold of
`AttentionTruncation.retention_threshold` (its hypothesis `1 - m/(4LB) < ρ`).
Then the held-out logit margin must exceed `1.4·L·B`.  This is a falsifiable
prediction about a quantity the harness does not currently log: a measured
margin below `1.4·L·B` would refute the margin-channel explanation of the knee
at this cell. -/
theorem netB_margin_channel_lower_bound {ι : Type*} (s T : Finset ι) (p : ι → ℝ)
    (hT : T ⊆ s) (hp : ∀ i ∈ s, 0 ≤ p i) (hNeff : effSupport s p = 152.11)
    (hcard : T.card ≤ 64) {L B m : ℝ} (hL : 0 < L) (hB : 0 < B)
    (hthr : 1 - m / (4 * L * B) < ∑ i ∈ T, p i) :
    1.4 * L * B < m := by
  have hmass : ∑ i ∈ T, p i ≤ 0.65 :=
    retained_mass_at_knee_le s T p hT hp hNeff hcard
  have h4LB : (0 : ℝ) < 4 * L * B := by positivity
  have h1 : (0.35 : ℝ) < m / (4 * L * B) := by linarith
  have h2 := (mul_lt_mul_of_pos_left h1 h4LB)
  rw [mul_div_cancel₀ _ h4LB.ne'] at h2
  nlinarith [h2]

/-!
## 2.  What the concentration measurement says about the tail amplitude (C2)
-/

variable {ι : Type*}

/-- A head set carrying mass `≥ r` on at most `K` positions caps the effective
support at `K / r²`.  (Cauchy–Schwarz, in the direction opposite to
`AttentionConcentration.mass_le_sqrt`: concentration of a *known* head forces a
*small* `N_eff`.) -/
theorem effSupport_le_of_head_mass (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {r : ℝ} (hr : 0 < r) (hmass : r ≤ ∑ i ∈ T, p i) :
    effSupport s p ≤ T.card / r ^ 2 := by
  have h := card_ge_of_retained s T p hT hc hr.le hmass
  rw [le_div_iff₀ (by positivity : (0 : ℝ) < r ^ 2)]
  linarith [h, mul_comm (r ^ 2) (effSupport s p)]

/-- If the scale-free tail with amplitude `A` has already dropped to at most one
half by the budget `K` — i.e. `2·A·ctx ≤ K` — then the effective support is at
most `4·K`. -/
theorem effSupport_le_four_card (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {A ctx : ℝ} {K : ℕ} (hK : 0 < K)
    (hKge : 2 * (A * ctx) ≤ (K : ℝ))
    (hcard : T.card ≤ K) (hmass : 1 - A * ctx / K ≤ ∑ i ∈ T, p i) :
    effSupport s p ≤ 4 * K := by
  have hKR : (0 : ℝ) < (K : ℝ) := by exact_mod_cast hK
  have htail : A * ctx / K ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hKR (by norm_num : (0:ℝ) < 2)]
    linarith
  have hr : (0 : ℝ) < 1 - A * ctx / K := by linarith
  have h := effSupport_le_of_head_mass s T p hT hc hr hmass
  have hcardR : ((T.card : ℕ) : ℝ) ≤ (K : ℝ) := by exact_mod_cast hcard
  have hsq : (1 / 2 : ℝ) ≤ 1 - A * ctx / K := by linarith
  have hden : (1 / 4 : ℝ) ≤ (1 - A * ctx / K) ^ 2 := by nlinarith
  have h2 : ((T.card : ℕ) : ℝ) / (1 - A * ctx / K) ^ 2 ≤ 4 * K := by
    rw [div_le_iff₀ (by positivity : (0:ℝ) < (1 - A * ctx / K) ^ 2)]
    nlinarith [hcardR, Nat.cast_nonneg (α := ℝ) T.card, hden, hKR]
  linarith [h, h2]

/-- **The scale-free tail caps the effective support.**  If some head of at most
`⌈2·A·ctx⌉₊` positions carries all but the Zipf tail of the attention mass, then
`N_eff ≤ 8·A·ctx + 4`.  The concentration statistic reported by the harness is
therefore not free: it is bounded by the tail amplitude that the cost law fits. -/
theorem effSupport_le_eight_amplitude (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {A ctx : ℝ} (hAc : 0 < A * ctx)
    (hcard : T.card ≤ ⌈2 * (A * ctx)⌉₊)
    (hmass : 1 - A * ctx / (⌈2 * (A * ctx)⌉₊ : ℝ) ≤ ∑ i ∈ T, p i) :
    effSupport s p ≤ 8 * (A * ctx) + 4 := by
  have hpos : (0 : ℝ) < 2 * (A * ctx) := by linarith
  have hK : 0 < ⌈2 * (A * ctx)⌉₊ := Nat.ceil_pos.mpr hpos
  have hKge : 2 * (A * ctx) ≤ ((⌈2 * (A * ctx)⌉₊ : ℕ) : ℝ) := Nat.le_ceil _
  have h := effSupport_le_four_card s T p hT hc hK hKge hcard hmass
  have hlt : ((⌈2 * (A * ctx)⌉₊ : ℕ) : ℝ) < 2 * (A * ctx) + 1 :=
    Nat.ceil_lt_add_one hpos.le
  linarith

/-- **Contrapositive: the measured concentration bounds the amplitude from
below.**  `A·ctx ≥ (N_eff - 4)/8`.  A large effective support cannot coexist
with a light scale-free tail. -/
theorem amplitude_ge_of_effSupport (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {A ctx N : ℝ} (hAc : 0 < A * ctx)
    (hN : N ≤ effSupport s p)
    (hcard : T.card ≤ ⌈2 * (A * ctx)⌉₊)
    (hmass : 1 - A * ctx / (⌈2 * (A * ctx)⌉₊ : ℝ) ≤ ∑ i ∈ T, p i) :
    (N - 4) / 8 ≤ A * ctx := by
  have h := effSupport_le_eight_amplitude s T p hT hc hAc hcard hmass
  rw [div_le_iff₀ (by norm_num : (0:ℝ) < 8)]
  linarith

/-!
## 3.  Depth drift of `N_eff` is not amplitude drift (C2, resolved)
-/

/-- **A depth-linear knee forces a depth-independent amplitude.**  If the least
sufficient budget `A·d·ctx/δ` of `AttentionCostLaw.kStar_isLeast` equals the
measured `d·ctx/32` at some depth `d`, then the tail amplitude at that depth is
exactly `δ/32` — no freedom is left. -/
theorem amplitude_forced_by_depth_linear_knee {A δ ctx : ℝ} {d : ℕ} (hd : 0 < d)
    (hctx : 0 < ctx) (hδ : 0 < δ)
    (hlaw : A * d * ctx / δ = d * ctx / 32) :
    A = δ / 32 := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  field_simp at hlaw
  linarith

/-- **C2 refuted in its conjectured form.**  Under the measured depth-linear
knee the amplitude is the same at every depth, so the product `A(d)·d` is *not*
constant: it grows exactly linearly in `d`, by the factor `4` between `d = 4`
and `d = 16`.  The `13 %` depth drift of `N_eff` therefore cannot be a drift of
the scale-free tail amplitude. -/
theorem amplitude_times_depth_not_constant {A₄ A₁₆ δ ctx : ℝ} (hctx : 0 < ctx)
    (hδ : 0 < δ)
    (h4 : A₄ * 4 * ctx / δ = 4 * ctx / 32)
    (h16 : A₁₆ * 16 * ctx / δ = 16 * ctx / 32) :
    A₄ = A₁₆ ∧ A₁₆ * 16 = 4 * (A₄ * 4) ∧ A₄ * 4 < A₁₆ * 16 := by
  have e4 : A₄ = δ / 32 :=
    amplitude_forced_by_depth_linear_knee (d := 4) (by norm_num) hctx hδ
      (by push_cast; linarith [h4])
  have e16 : A₁₆ = δ / 32 :=
    amplitude_forced_by_depth_linear_knee (d := 16) (by norm_num) hctx hδ
      (by push_cast; linarith [h16])
  refine ⟨by rw [e4, e16], by rw [e4, e16]; ring, ?_⟩
  rw [e4, e16]
  linarith

/-- **A depth-independent ceiling on the effective support.**  With the
amplitude pinned at `δ/32` by the depth-linear knee, the cap of
`effSupport_le_eight_amplitude` reads `N_eff ≤ δ·ctx/4 + 4` at *every* depth.
The measured drift `46.6 → 50.2 → 52.7` at `ctx = 128` must therefore sit under
one and the same ceiling; unbounded growth of `N_eff` with depth would refute
the scale-free tail. -/
theorem effSupport_ceiling_depth_independent (s T : Finset ι) (p : ι → ℝ)
    (hT : T ⊆ s) (hc : 0 < collision s p) {δ ctx : ℝ} (hδ : 0 < δ) (hctx : 0 < ctx)
    (hcard : T.card ≤ ⌈2 * (δ / 32 * ctx)⌉₊)
    (hmass : 1 - δ / 32 * ctx / (⌈2 * (δ / 32 * ctx)⌉₊ : ℝ) ≤ ∑ i ∈ T, p i) :
    effSupport s p ≤ δ * ctx / 4 + 4 := by
  have hAc : 0 < δ / 32 * ctx := by positivity
  have h := effSupport_le_eight_amplitude s T p hT hc hAc hcard hmass
  have : 8 * (δ / 32 * ctx) = δ * ctx / 4 := by ring
  linarith

/-- **The deepest measured cell bounds the error budget from below.**  Cell A
(`d = 16`, `ctx = 128`) reports `N_eff = 52.73`.  Feeding it into the
depth-independent ceiling `N_eff ≤ 32·δ + 4` gives `δ ≥ 1.52`: the end-to-end
truncation budget implicit in the fitted constant `A/δ = 1/32` cannot be small.
This is the sharpest constraint the concentration stage places on the model. -/
theorem netA_budget_lower_bound (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hc : 0 < collision s p) {δ : ℝ} (hδ : 0 < δ)
    (hNeff : (52.73 : ℝ) ≤ effSupport s p)
    (hcard : T.card ≤ ⌈2 * (δ / 32 * 128)⌉₊)
    (hmass : 1 - δ / 32 * 128 / (⌈2 * (δ / 32 * 128)⌉₊ : ℝ) ≤ ∑ i ∈ T, p i) :
    (1.52 : ℝ) ≤ δ := by
  have h := effSupport_ceiling_depth_independent s T p hT hc hδ
    (by norm_num : (0:ℝ) < 128) hcard hmass
  have : (52.73 : ℝ) ≤ δ * 128 / 4 + 4 := le_trans hNeff h
  linarith

/-- **Non-vacuity of the amplitude cap.**  The hypotheses of
`effSupport_le_eight_amplitude` are realised: take the row on `Fin 8` putting
mass `1/2` on each of two positions.  Its collision mass is `1/2`, so
`N_eff = 2`; with `A·ctx = 1` the head `{0, 1}` has `⌈2⌉₊ = 2` positions and
carries mass `1 ≥ 1 - 1/2`, and indeed `2 ≤ 8·1 + 4`. -/
theorem two_spike_realises_amplitude_cap :
    ∃ (s T : Finset (Fin 8)) (p : Fin 8 → ℝ),
      T ⊆ s ∧ 0 < collision s p ∧ effSupport s p = 2 ∧
        T.card ≤ ⌈2 * (1 : ℝ)⌉₊ ∧
        1 - (1 : ℝ) / (⌈2 * (1 : ℝ)⌉₊ : ℝ) ≤ ∑ i ∈ T, p i := by
  classical
  refine ⟨({0, 1} : Finset (Fin 8)), ({0, 1} : Finset (Fin 8)),
    fun i => if i = 0 ∨ i = 1 then 1 / 2 else 0, Finset.Subset.refl _, ?_, ?_, ?_, ?_⟩
  · have : collision ({0, 1} : Finset (Fin 8))
        (fun i => if i = 0 ∨ i = 1 then 1 / 2 else 0) = 1 / 2 := by
      unfold collision
      norm_num [Finset.sum_pair (show (0 : Fin 8) ≠ 1 by decide)]
    rw [this]; norm_num
  · have : collision ({0, 1} : Finset (Fin 8))
        (fun i => if i = 0 ∨ i = 1 then 1 / 2 else 0) = 1 / 2 := by
      unfold collision
      norm_num [Finset.sum_pair (show (0 : Fin 8) ≠ 1 by decide)]
    unfold effSupport
    rw [this]; norm_num
  · norm_num [Finset.card_pair (show (0 : Fin 8) ≠ 1 by decide)]
  · norm_num [Finset.sum_pair (show (0 : Fin 8) ≠ 1 by decide)]

/-!
## 4.  The margin is pinned too: the knee window, and depth-independence

The two-sided margin law has a dimensionless reading.  Write
`x = 4·L·B·A·ctx/m` for the real budget the margin channel asks for.  Then the
integer knee always sits in the closed window `[x, 2x]`, so the dimensionless
number `k*·m/(4·L·B·A·ctx)` is confined to `[1, 2]` — a window fixed before any
measurement, with no free constant to fit.  And if the measured depth-linear
knee is what the margin channel selects, the margin itself is forced:
`m = 128·L·B·A` at *every* depth.
-/

/-- **The knee window.**  `k*·m/(4·L·B·A·ctx) ∈ [1, 2]`: the margin channel
determines the knee up to a factor two, with both ends of the window fixed in
advance. -/
theorem knee_margin_window {A ctx L B m : ℝ} (hA : 0 < A) (hctx : 0 < ctx)
    (hL : 0 < L) (hB : 0 < B) (hm : 0 < m)
    (hbite : 1 ≤ 4 * L * B * A * ctx / m) :
    1 ≤ (marginKnee A ctx L B m : ℝ) * m / (4 * L * B * A * ctx) ∧
      (marginKnee A ctx L B m : ℝ) * m / (4 * L * B * A * ctx) ≤ 2 := by
  set x : ℝ := 4 * L * B * A * ctx / m with hx
  have hden : (0 : ℝ) < 4 * L * B * A * ctx := by positivity
  have hx0 : 0 < x := lt_of_lt_of_le zero_lt_one hbite
  have hxm : x * m = 4 * L * B * A * ctx := by
    rw [hx]; field_simp
  have hlow : x ≤ ((marginKnee A ctx L B m : ℕ) : ℝ) := Nat.le_ceil _
  have hhigh : ((marginKnee A ctx L B m : ℕ) : ℝ) ≤ 2 * x := by
    have h1 : ((⌈x⌉₊ : ℕ) : ℝ) < x + 1 := Nat.ceil_lt_add_one hx0.le
    have : x + 1 ≤ 2 * x := by linarith
    exact le_trans h1.le this
  constructor
  · rw [le_div_iff₀ hden]
    nlinarith [mul_le_mul_of_nonneg_right hlow hm.le]
  · rw [div_le_iff₀ hden]
    nlinarith [mul_le_mul_of_nonneg_right hhigh hm.le]

/-- **The margin is forced by the depth-linear knee.**  If the budget the margin
channel asks for equals the measured `d·ctx/32` at some depth `d`, then
`m = 128·L·B·A` — a value with no `d` in it. -/
theorem margin_forced_by_depth_linear_knee {A ctx L B m : ℝ} {d : ℕ} (hd : 0 < d)
    (hctx : 0 < ctx) (hm : 0 < m)
    (hlaw : 4 * L * B * A * d * ctx / m = d * ctx / 32) :
    m = 128 * L * B * A := by
  have hdR : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
  have h1 : 4 * L * B * A * d * ctx = ((d : ℝ) * ctx / 32) * m :=
    (div_eq_iff hm.ne').mp hlaw
  have hne : ((d : ℝ) * ctx) ≠ 0 := by positivity
  have hcancel : (128 * L * B * A) * ((d : ℝ) * ctx) = m * ((d : ℝ) * ctx) := by
    linear_combination 32 * h1
  exact (mul_right_cancel₀ hne hcancel).symm

/-- **Depth-independence of the margin (replacing the naive `m(d)·d = const`).**
Under the mechanism, the margins of the `d = 4` and `d = 16` stacks at the same
context must be *equal*, not inversely proportional to depth: the linear growth
of `k*` is produced by the error accumulation over layers, not by a shrinking
margin.  A measured ratio `m(16)/m(4) ≈ 1/4` would therefore refute the
mechanism rather than confirm it. -/
theorem margin_depth_independent {A ctx L B m₄ m₁₆ : ℝ} (hctx : 0 < ctx)
    (hm₄ : 0 < m₄) (hm₁₆ : 0 < m₁₆)
    (h4 : 4 * L * B * A * 4 * ctx / m₄ = 4 * ctx / 32)
    (h16 : 4 * L * B * A * 16 * ctx / m₁₆ = 16 * ctx / 32) :
    m₄ = m₁₆ ∧ m₁₆ ≠ m₄ / 4 := by
  have e4 : m₄ = 128 * L * B * A :=
    margin_forced_by_depth_linear_knee (d := 4) (by norm_num) hctx hm₄
      (by push_cast; linarith [h4])
  have e16 : m₁₆ = 128 * L * B * A :=
    margin_forced_by_depth_linear_knee (d := 16) (by norm_num) hctx hm₁₆
      (by push_cast; linarith [h16])
  refine ⟨by rw [e4, e16], ?_⟩
  intro hcon
  rw [e4, e16] at hcon
  have : (0 : ℝ) < 128 * L * B * A := by rw [← e4]; exact hm₄
  linarith

end AttentionMarginLaw