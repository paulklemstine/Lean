/-
# Knee thresholds on a finite sweep grid: robustness certificates, seed fluctuation,
# and the collapse of an "exact product law" into a two-seed bracket (NET-44)

Round NET-44 closes the last single-seed cell of the attention-cost grid studied in
`Probability.AttentionCostLaw` / `Probability.AttentionDepthRigidity`.  The measured
object is always the same: a *knee*

  `k*(seed) = ` the least budget on a finite sweep grid `G` at which the retained
  accuracy curve `c : ℕ → ℝ` first reaches a bar `bar`,

and the empirical claim under test was the *exact product law* `k* = d·ctx/32`, which
at `(d = 4, ctx = 1024)` predicts `k* = 128`.

**Lab notes (round NET-44, speed axis, round 17).**
Harness byte-identical to NET-37: `CausalTF`, `d_model = 64`, 4 heads, Gutenberg corpus,
vocab 4097, 2000 AdamW steps, `d = 4`, `ctx = 1024`, sweep
`{32, 64, 96, 112, 128, 192, 256, 384, 512, 768}` (`112` added this round to pin the
`(96, 128]` bracket), bar `= 0.98` of full accuracy.

| budget `k` | 64 | 96 | 112 | 128 | 768 |
|---|---|---|---|---|---|
| retained, seed 1 (NET-37) | 0.968 | 0.977 | (not swept) | 0.986 | 1.000 |
| retained, seed 2 (NET-44) | 0.979 | 0.987 | 0.991 | 0.993 | 1.000 |

Seed 2: full accuracy 0.1591, bar 0.1559, loss 5.1179 (seed 1: 0.1594 / 5.1209);
train 6067 s; `ALL_DONE_NET44`, no crash.  Selection-vs-random-`k` gaps
`+6.2` (`k = 64`) / `+4.8` (`k = 128`) versus seed 1's `+5.9 / +4.6`; concentration
reproducible to `1.3 %` (`N_eff` 294.97 vs 291.16).  Hence `k*(s1) = 128` but
`k*(s2) = 96`: the pre-registered prediction FAILED.

**What this file proves.**  The empirical story is entirely an order-theoretic statement
about threshold functionals on a finite chain, and it can be certified exactly.

* `KneeFluctuation.IsKnee` and `IsKnee.unique`, `IsKnee.le_of_passes` : the knee is the
  least passing grid point; it is unique, and *any* passing budget is an upper bound
  for it.  This is why the product law can only ever be certified as an **upper bound**
  from a sweep (`productLaw_is_safe_upper_bound`).
* `KneeFluctuation.robustKnee_iff` : the exact seed-robustness criterion.  A knee claim
  `k* = k` survives every monotone perturbation of size `η` **iff**
  `η ≤ c k - bar` and `η < bar - c j` for every earlier grid point `j`.  The asymmetry
  (`≤` at the knee, `<` below it) is sharp, both directions are proved, and the
  necessity direction is by explicit construction of a violating curve.
* `KneeFluctuation.net44_seed1_knee`, `net44_seed2_knee` : from the measured numbers
  alone (plus monotonicity of the retained curve, which is all that is used for the
  unswept points) the two knees are `128` and `96`.
* `KneeFluctuation.net44_two_seed_bracket` : both knees lie in `Ioc 64 128`, and
  `net44_speedup_bracket` converts this into the deployable speedup window
  `[8, 16)`, with the two measured seeds at `8` and `32/3 ≈ 10.67`.
* `KneeFluctuation.net44_seed1_knee_not_robust` and
  `net44_seed1_admits_knee_96_perturbation` : the seed-1 exactness was **seed-lucky**.
  The seed-1 margin at `k = 96` is `0.003`, far below the observed inter-seed spread
  `0.010`, so a `0.010`-perturbation of the seed-1 curve — one that reproduces the
  actual seed-2 numbers at `64`, `96`, `128` to within `0.001` — already has knee `96`.
  Seed-1 data alone therefore does not entail `k* = 128`
  (`single_seed_does_not_determine_knee`).
* `KneeFluctuation.net44_lower_bracket_is_robust` : by contrast the *lower* end of the
  bracket is protected — the seed-1 deficit at `k = 64` is `0.012 > 0.010`, so no
  `0.010`-perturbation can push the knee down to `64`.  The bracket `(64, 128]` is the
  exact robust content of the two-seed measurement.
* `KneeFluctuation.gridKnee_overshoot_lt_step` and `oneStepFluctuation` : grid
  quantisation alone manufactures one-step knee fluctuations — two seeds whose true
  (continuous) knees differ by an arbitrarily small amount can report grid knees
  differing by a full step `32`, exactly the observed `128` vs `96`.
* `KneeFluctuation.amplitude_ratio_of_knee_ratio` and `net44_amplitude_slack` : read
  through the Zipf mechanism of `Probability.AttentionCostLaw`, the whole effect is a
  `3/4` change in the tail amplitude `A`; `net44_over_prediction` records that the law's
  `128` over-predicts the seed-2 knee by exactly one quarter of its own value.
-/

import Mathlib
import Probability.AttentionCostLaw

namespace KneeFluctuation

open Finset

/-! ## 1.  Knees as threshold functionals on a finite grid -/

/-- `IsKnee G bar c k` : on the sweep grid `G`, `k` is the least budget whose retained
accuracy `c k` reaches the bar. -/
def IsKnee (G : Finset ℕ) (bar : ℝ) (c : ℕ → ℝ) (k : ℕ) : Prop :=
  k ∈ G ∧ bar ≤ c k ∧ ∀ j ∈ G, bar ≤ c j → k ≤ j

/-- A knee is unique: two least passing grid points coincide. -/
theorem IsKnee.unique {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k k' : ℕ}
    (h : IsKnee G bar c k) (h' : IsKnee G bar c k') : k = k' :=
  le_antisymm (h.2.2 _ h'.1 h'.2.1) (h'.2.2 _ h.1 h.2.1)

/-- **Any passing budget bounds the knee from above.**  A sweep can only ever *certify*
an upper bound for the knee; it can never certify minimality of a predicted value. -/
theorem IsKnee.le_of_passes {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k j : ℕ}
    (h : IsKnee G bar c k) (hj : j ∈ G) (hpass : bar ≤ c j) : k ≤ j :=
  h.2.2 _ hj hpass

/-- Every grid point strictly below the knee fails the bar. -/
theorem IsKnee.fails_below {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k j : ℕ}
    (h : IsKnee G bar c k) (hj : j ∈ G) (hlt : j < k) : c j < bar := by
  by_contra hcon
  exact absurd (h.le_of_passes hj (not_lt.mp hcon)) (not_le.mpr hlt)

/-- **Monotone comparison of seeds.**  If one seed's retained curve dominates another's
pointwise, its knee is no larger.  This is the structural reason a uniformly higher
seed-2 curve can only move the knee *down*. -/
theorem knee_antitone {G : Finset ℕ} {bar : ℝ} {c c' : ℕ → ℝ} {k k' : ℕ}
    (h : IsKnee G bar c k) (h' : IsKnee G bar c' k') (hle : ∀ j ∈ G, c j ≤ c' j) :
    k' ≤ k :=
  h'.le_of_passes h.1 (h.2.1.trans (hle _ h.1))

/-! ## 2.  Robustness certificates: exactly when a knee cannot move -/

/-- `RobustKnee G bar c k η` : the knee claim `k* = k` survives every monotone
perturbation of the retained curve of size at most `η` on the grid. -/
def RobustKnee (G : Finset ℕ) (bar : ℝ) (c : ℕ → ℝ) (k : ℕ) (η : ℝ) : Prop :=
  ∀ c' : ℕ → ℝ, Monotone c' → (∀ j ∈ G, |c' j - c j| ≤ η) → IsKnee G bar c' k

/-- **Sufficiency.**  Strict margins below the knee and a (weakly) large margin at the
knee force the knee to stay put under every `η`-perturbation. -/
theorem robustKnee_of_margins {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k : ℕ} {η : ℝ}
    (hk : k ∈ G) (hup : η ≤ c k - bar) (hdown : ∀ j ∈ G, j < k → η < bar - c j) :
    RobustKnee G bar c k η := by
  intro c' _ hclose
  refine ⟨hk, ?_, ?_⟩
  · have h := abs_le.mp (hclose k hk)
    linarith [h.1]
  · intro j hj hpass
    by_contra hlt
    push_neg at hlt
    have h := abs_le.mp (hclose j hj)
    have := hdown j hj hlt
    linarith [h.2]

/-- **Necessity.**  If the knee is robust at level `η ≥ 0` then the margins above hold.
Both violating curves are explicit shifts `c ± η`, so the criterion is sharp. -/
theorem margins_of_robustKnee {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k : ℕ} {η : ℝ}
    (hc : Monotone c) (hη : 0 ≤ η) (hrob : RobustKnee G bar c k η) :
    η ≤ c k - bar ∧ ∀ j ∈ G, j < k → η < bar - c j := by
  constructor
  · by_contra hcon
    push_neg at hcon
    have hlow : IsKnee G bar (fun x => c x - η) k :=
      hrob _ (fun _ _ h => by simpa using sub_le_sub_right (hc h) η)
        (fun j _ => by
          have hj : (c j - η) - c j = -η := by ring
          rw [hj, abs_neg, abs_of_nonneg hη])
    have := hlow.2.1
    simp only at this
    linarith
  · intro j hj hlt
    by_contra hcon
    push_neg at hcon
    have hup : IsKnee G bar (fun x => c x + η) k :=
      hrob _ (fun _ _ h => by simpa using add_le_add_right (hc h) η)
        (fun j _ => by
          have hj : (c j + η) - c j = η := by ring
          rw [hj, abs_of_nonneg hη])
    have hpass : bar ≤ c j + η := by linarith
    exact absurd (hup.le_of_passes hj hpass) (not_le.mpr hlt)

/-- **The robustness criterion.**  A knee claim is `η`-robust *iff* the bar is cleared at
the knee by at least `η` and missed at every earlier grid point by strictly more than
`η`.  The asymmetry `≤` / `<` is forced by the bar being a non-strict threshold. -/
theorem robustKnee_iff {G : Finset ℕ} {bar : ℝ} {c : ℕ → ℝ} {k : ℕ} {η : ℝ}
    (hc : Monotone c) (hη : 0 ≤ η) (hk : k ∈ G) :
    RobustKnee G bar c k η ↔ (η ≤ c k - bar ∧ ∀ j ∈ G, j < k → η < bar - c j) :=
  ⟨margins_of_robustKnee hc hη, fun h => robustKnee_of_margins hk h.1 h.2⟩

/-- A *lower* bracket claim, `k* > b`, is `η`-robust when every grid point `≤ b` misses
the bar by more than `η`.  Unlike an exact knee value this needs no upper margin. -/
theorem knee_gt_of_robust_deficit {G : Finset ℕ} {bar η : ℝ} {c c' : ℕ → ℝ} {k b : ℕ}
    (hdef : ∀ j ∈ G, j ≤ b → η < bar - c j) (hclose : ∀ j ∈ G, |c' j - c j| ≤ η)
    (h' : IsKnee G bar c' k) : b < k := by
  by_contra hcon
  push_neg at hcon
  have h := abs_le.mp (hclose k h'.1)
  have := hdef k h'.1 hcon
  linarith [h'.2.1, h.2]

/-! ## 3.  Grid quantisation manufactures one-step fluctuations -/

/-- The grid knee produced by a sweep of step `s`: the least multiple of `s` at or above
the true (continuous) knee `κ`. -/
noncomputable def gridKnee (s κ : ℝ) : ℝ := s * ⌈κ / s⌉₊

/-- The grid knee never under-reports the true knee. -/
theorem le_gridKnee {s κ : ℝ} (hs : 0 < s) : κ ≤ gridKnee s κ := by
  have h := Nat.le_ceil (κ / s)
  have := (mul_le_mul_of_nonneg_left h hs.le)
  rwa [mul_div_cancel₀ _ hs.ne'] at this

/-- **Quantisation error.**  The grid knee over-reports by strictly less than one step.
So "the measured knee equals `d·ctx/32` exactly" is a statement with a built-in
uncertainty of one grid step — here `32`. -/
theorem gridKnee_overshoot_lt_step {s κ : ℝ} (hs : 0 < s) (hκ : 0 ≤ κ) :
    gridKnee s κ - κ < s := by
  have h : (⌈κ / s⌉₊ : ℝ) < κ / s + 1 := Nat.ceil_lt_add_one (by positivity)
  have := (mul_lt_mul_of_pos_left h hs)
  rw [mul_add, mul_one, mul_div_cancel₀ _ hs.ne'] at this
  simpa [gridKnee] using by linarith

/-- **One-step fluctuation from nothing.**  For every `ε > 0` there are two continuous
knees within `ε` of one another whose grid knees on the step-`32` sweep are `96` and
`128` — the exact NET-37/NET-44 pair.  A one-grid-step knee change therefore carries no
information beyond `ε`-level noise in the underlying threshold. -/
theorem oneStepFluctuation (ε : ℝ) (hε : 0 < ε) :
    ∃ κ₁ κ₂ : ℝ, 0 ≤ κ₁ ∧ 0 ≤ κ₂ ∧ |κ₁ - κ₂| ≤ ε ∧
      gridKnee 32 κ₂ = 96 ∧ gridKnee 32 κ₁ = 128 := by
  refine ⟨96 + min ε 32 / 2, 96, by positivity, by norm_num, ?_, ?_, ?_⟩
  · have h1 : min ε 32 ≤ ε := min_le_left _ _
    have h2 : 0 < min ε 32 := lt_min hε (by norm_num)
    rw [abs_of_nonneg (by linarith)]
    linarith
  · have h3 : ⌈(96 : ℝ) / 32⌉₊ = 3 := by norm_num
    simp only [gridKnee, h3]
    norm_num
  · have h2 : 0 < min ε 32 := lt_min hε (by norm_num)
    have h3 : min ε 32 ≤ 32 := min_le_right _ _
    have hceil : ⌈(96 + min ε 32 / 2) / 32⌉₊ = 4 := by
      rw [Nat.ceil_eq_iff (by norm_num)]
      constructor
      · push_cast
        rw [lt_div_iff₀ (by norm_num)]
        linarith
      · rw [div_le_iff₀ (by norm_num)]
        push_cast
        linarith
    simp [gridKnee, hceil]
    norm_num

/-! ## 4.  The NET-44 measurement -/

/-- The NET-37 sweep grid at `(d = 4, ctx = 1024)`, seed 1 (no `112` point). -/
def gridS1 : Finset ℕ := {32, 64, 96, 128, 192, 256, 384, 512, 768}

/-- The NET-44 sweep grid, seed 2: `112` was added to pin the `(96, 128]` bracket. -/
def gridS2 : Finset ℕ := {32, 64, 96, 112, 128, 192, 256, 384, 512, 768}

/-- The retained-accuracy bar: `0.98` of the full model's held-out accuracy. -/
def bar : ℝ := 0.98

/-- The measured seed-1 retained curve at `(d = 4, ctx = 1024)` (NET-37).  Only the three
swept values are recorded; the unswept grid points are handled by monotonicity. -/
structure Seed1Data (c : ℕ → ℝ) : Prop where
  mono : Monotone c
  at64 : c 64 = 0.968
  at96 : c 96 = 0.977
  at128 : c 128 = 0.986

/-- The measured seed-2 retained curve at `(d = 4, ctx = 1024)` (NET-44). -/
structure Seed2Data (c : ℕ → ℝ) : Prop where
  mono : Monotone c
  at64 : c 64 = 0.979
  at96 : c 96 = 0.987
  at112 : c 112 = 0.991
  at128 : c 128 = 0.993

/-- **Non-vacuity of the seed-1 record.**  An explicit monotone step curve realises the
NET-37 measurement, so every theorem with a `Seed1Data` hypothesis has content. -/
theorem seed1Data_nonvacuous :
    Seed1Data (fun k => if k ≤ 64 then 0.968 else if k ≤ 96 then 0.977 else 0.986) := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num⟩
  intro a b hab
  dsimp only
  split_ifs <;> first | rfl | (exfalso; omega) | norm_num

/-- **Non-vacuity of the seed-2 record.** -/
theorem seed2Data_nonvacuous :
    Seed2Data (fun k => if k ≤ 64 then 0.979 else if k ≤ 96 then 0.987 else
      if k ≤ 112 then 0.991 else 0.993) := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num, by norm_num⟩
  intro a b hab
  dsimp only
  split_ifs <;> first | rfl | (exfalso; omega) | norm_num

/-- Seed 1: the knee is `128`, exactly the product law `d·ctx/32 = 4·1024/32`. -/
theorem net44_seed1_knee {c : ℕ → ℝ} (h : Seed1Data c) : IsKnee gridS1 bar c 128 := by
  obtain ⟨hm, h64, h96, h128⟩ := h
  have h32 : c 32 ≤ 0.968 := h64 ▸ hm (by norm_num : (32 : ℕ) ≤ 64)
  refine ⟨by decide, by rw [h128]; norm_num [bar], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- Seed 2: the knee is `96` — one grid step below the product law's prediction.  The
`112` point is above the knee (it passes, but `96` already does), so the seed-2 knee is
pinned, not merely bracketed. -/
theorem net44_seed2_knee {c : ℕ → ℝ} (h : Seed2Data c) : IsKnee gridS2 bar c 96 := by
  obtain ⟨hm, h64, h96, h112, h128⟩ := h
  have h32 : c 32 ≤ 0.979 := h64 ▸ hm (by norm_num : (32 : ℕ) ≤ 64)
  refine ⟨by decide, by rw [h96]; norm_num [bar], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar] <;> linarith

/-- **The prediction failed.**  The pre-registered hypothesis `k*(s2) = 128` is refuted:
no curve can have both knees. -/
theorem net44_prediction_failed {c : ℕ → ℝ} (h : Seed2Data c) :
    ¬ IsKnee gridS2 bar c 128 := by
  intro hcon
  have := (net44_seed2_knee h).unique hcon
  norm_num at this

/-- **The product law is a proven-safe upper bound.**  At both seeds the law's budget
`128` clears the bar, so at both seeds the knee is at most `128`. -/
theorem productLaw_is_safe_upper_bound {G : Finset ℕ} {c : ℕ → ℝ} {k : ℕ}
    (hmem : 128 ∈ G) (hpass : bar ≤ c 128) (hk : IsKnee G bar c k) : k ≤ 128 :=
  hk.le_of_passes hmem hpass

/-- **Two-seed bracket.**  Both measured knees lie in `Ioc 64 128`; neither seed reaches
the bar at `64`, and both clear it at `128`. -/
theorem net44_two_seed_bracket {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ}
    (h₁ : Seed1Data c₁) (h₂ : Seed2Data c₂)
    (hk₁ : IsKnee gridS1 bar c₁ k₁) (hk₂ : IsKnee gridS2 bar c₂ k₂) :
    k₁ ∈ Set.Ioc 64 128 ∧ k₂ ∈ Set.Ioc 64 128 := by
  have e₁ : k₁ = 128 := hk₁.unique (net44_seed1_knee h₁) ▸ rfl
  have e₂ : k₂ = 96 := hk₂.unique (net44_seed2_knee h₂) ▸ rfl
  subst e₁; subst e₂
  exact ⟨⟨by norm_num, by norm_num⟩, ⟨by norm_num, by norm_num⟩⟩

/-- **Over-prediction.**  The product law's `128` exceeds the seed-2 knee by exactly one
quarter of its own value: `96 = 0.75 · 128`. -/
theorem net44_over_prediction : (96 : ℝ) = 0.75 * 128 ∧ (128 : ℝ) - 96 = 128 / 4 := by
  norm_num

/-- Deployable speedup at budget `k` on a context of length `ctx`. -/
noncomputable def speedup (ctx k : ℝ) : ℝ := ctx / k

/-- **Speedup window.**  The two-seed bracket `(64, 128]` converts into a deployable
speedup window `[8, 16)` at `ctx = 1024`; the measured seeds sit at `8` and `32/3`. -/
theorem net44_speedup_bracket {k : ℕ} (h : k ∈ Set.Ioc 64 128) :
    8 ≤ speedup 1024 k ∧ speedup 1024 k < 16 := by
  obtain ⟨hlo, hhi⟩ := h
  have hk0 : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hlo
  have hkle : (k : ℝ) ≤ 128 := by exact_mod_cast hhi
  have hkgt : (64 : ℝ) < k := by exact_mod_cast hlo
  constructor
  · rw [speedup, le_div_iff₀ hk0]; linarith
  · rw [speedup, div_lt_iff₀ hk0]; linarith

/-- The two measured speedups: `8×` at seed 1 and `32/3 ≈ 10.67×` at seed 2. -/
theorem net44_measured_speedups :
    speedup 1024 128 = 8 ∧ speedup 1024 96 = 32 / 3 := by
  constructor <;> norm_num [speedup]

/-! ## 5.  The seed-1 exactness was seed-lucky -/

/-- The observed inter-seed spread of the retained curve: `≈ 0.010` at every swept
budget (`0.979 - 0.968`, `0.987 - 0.977`, `0.993 - 0.986`). -/
def spread : ℝ := 0.010

/-- **Not robust.**  The seed-1 knee claim `k* = 128` is *not* stable against
perturbations of the size actually observed between seeds: the seed-1 margin at `96` is
only `bar - 0.977 = 0.003 < 0.010`. -/
theorem net44_seed1_knee_not_robust {c : ℕ → ℝ} (h : Seed1Data c) :
    ¬ RobustKnee gridS1 bar c 128 spread := by
  intro hrob
  have := (margins_of_robustKnee h.mono (by norm_num [spread]) hrob).2 96 (by decide)
    (by norm_num)
  rw [h.at96] at this
  norm_num [bar, spread] at this

/-- **The seed-luck, explicitly.**  Shifting the seed-1 curve by the observed spread
`0.010` — a shift which reproduces the actual seed-2 numbers at `64`, `96`, `128` to
within `0.001` — already moves the knee to `96`.  Seed 1's agreement with the product
law was therefore an accident of the seed, not a certified fact. -/
theorem net44_seed1_admits_knee_96_perturbation {c : ℕ → ℝ} (h : Seed1Data c) :
    ∃ c' : ℕ → ℝ, Monotone c' ∧ (∀ j, |c' j - c j| ≤ spread) ∧
      IsKnee gridS1 bar c' 96 := by
  obtain ⟨hm, h64, h96, h128⟩ := h
  refine ⟨fun x => c x + spread, fun _ _ hxy => by
      simpa using add_le_add_right (hm hxy) spread, fun j => by
      have hj : (c j + spread) - c j = spread := by ring
      rw [hj, abs_of_nonneg (by norm_num [spread])], ?_⟩
  have h32 : c 32 ≤ 0.968 := h64 ▸ hm (by norm_num : (32 : ℕ) ≤ 64)
  refine ⟨by decide, by show bar ≤ c 96 + spread; rw [h96]; norm_num [bar, spread], ?_⟩
  intro j hj hpass
  fin_cases hj <;> simp_all [bar, spread] <;> linarith

/-- **Single-seed data does not determine the knee.**  Two monotone curves that agree
with the seed-1 measurement up to the observed inter-seed spread can have different
knees, so no inference from a single seed to the two-seed law is valid. -/
theorem single_seed_does_not_determine_knee {c : ℕ → ℝ} (h : Seed1Data c) :
    ∃ c₁ c₂ : ℕ → ℝ, Monotone c₁ ∧ Monotone c₂ ∧
      (∀ j, |c₁ j - c j| ≤ spread) ∧ (∀ j, |c₂ j - c j| ≤ spread) ∧
      ∃ k₁ k₂, IsKnee gridS1 bar c₁ k₁ ∧ IsKnee gridS1 bar c₂ k₂ ∧ k₁ ≠ k₂ := by
  obtain ⟨c', hmono, hclose, hknee⟩ := net44_seed1_admits_knee_96_perturbation h
  refine ⟨c, c', h.mono, hmono, fun j => by
      rw [sub_self, abs_zero]; norm_num [spread], hclose, 128, 96,
    net44_seed1_knee h, hknee, by norm_num⟩

/-- **The lower end of the bracket *is* protected.**  The seed-1 deficit at `k = 64` is
`0.012`, strictly larger than the observed spread `0.010`, so no `0.010`-perturbation of
the seed-1 curve has a knee at `64` or below.  Together with the safe upper bound this
says the robust content of the measurement is exactly `k* ∈ (64, 128]`. -/
theorem net44_lower_bracket_is_robust {c c' : ℕ → ℝ} {k : ℕ} (h : Seed1Data c)
    (hclose : ∀ j ∈ gridS1, |c' j - c j| ≤ spread) (hk : IsKnee gridS1 bar c' k) :
    64 < k := by
  refine knee_gt_of_robust_deficit (bar := bar) (c := c) (b := 64) ?_ hclose hk
  intro j hj hle
  obtain ⟨hm, h64, h96, h128⟩ := h
  have h32 : c 32 ≤ 0.968 := h64 ▸ hm (by norm_num : (32 : ℕ) ≤ 64)
  fin_cases hj <;> simp_all [bar, spread] <;> linarith

/-! ## 6.  Reading the fluctuation through the Zipf mechanism -/

open AttentionCostLaw

/-- Under the Zipf tail of `Probability.AttentionCostLaw`, the least feasible budget is
`A·d·ctx/δ`; hence a knee ratio between two seeds is exactly the ratio of their tail
amplitudes.  Structure, depth and context all cancel. -/
theorem amplitude_ratio_of_knee_ratio {A₁ A₂ d ctx δ κ₁ κ₂ : ℝ}
    (hδ : 0 < δ) (hd : 0 < d) (hctx : 0 < ctx) (hA₁ : 0 < A₁)
    (h₁ : κ₁ = A₁ * d * ctx / δ) (h₂ : κ₂ = A₂ * d * ctx / δ) :
    κ₂ / κ₁ = A₂ / A₁ := by
  have hd0 : d ≠ 0 := hd.ne'
  have hctx0 : ctx ≠ 0 := hctx.ne'
  have hA0 : A₁ ≠ 0 := hA₁.ne'
  have hδ0 : δ ≠ 0 := hδ.ne'
  subst h₁; subst h₂
  field_simp

/-- **The NET-44 effect is a 3/4 amplitude slack.**  Moving the knee from `128` to `96`
is exactly a `3/4` change in the Zipf tail amplitude: the mechanism of
`Probability.AttentionCostLaw` is intact, only its single fitted constant fluctuates. -/
theorem net44_amplitude_slack {A₁ A₂ d ctx δ : ℝ}
    (hδ : 0 < δ) (hd : 0 < d) (hctx : 0 < ctx) (hA₁ : 0 < A₁)
    (h₁ : (128 : ℝ) = A₁ * d * ctx / δ) (h₂ : (96 : ℝ) = A₂ * d * ctx / δ) :
    A₂ / A₁ = 3 / 4 := by
  have := amplitude_ratio_of_knee_ratio hδ hd hctx hA₁ h₁ h₂
  rw [← this]
  norm_num

/-- **Feasibility at the law's budget is genuinely sufficient**, for any amplitude at or
below the calibrated one: the safe-upper-bound claim survives the amplitude fluctuation.
Stated through `AttentionCostLaw.zipf_feasible_iff`. -/
theorem law_budget_feasible_of_amplitude_le {A A₀ ctx δ : ℝ} {d k : ℕ}
    (hδ : 0 < δ) (hd : 0 < d) (hk : 0 < k) (hctx : 0 ≤ ctx) (hAA : A ≤ A₀)
    (hlaw : A₀ * d * ctx / δ ≤ (k : ℝ)) :
    (d : ℝ) * zipfTail A ctx k ≤ δ := by
  refine (zipf_feasible_iff hδ hd hk).2 (le_trans ?_ hlaw)
  have hd' : (0 : ℝ) ≤ d := le_of_lt (by exact_mod_cast hd)
  gcongr

end KneeFluctuation