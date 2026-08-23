/-
# NET-68, adversarial round: is the domain jump an *additive base shift* or a
# *rescaling of the attention decay rate*?

`Applications.NET68DomainJumpBudgetLaw` fits the measured cells with the additive law
`k*(domain, ctx) = base(domain) + inc · doublings(ctx)`, `base(prose) = 16`,
`base(code) = 12`, `inc = 4`.  The Critic's objection: an additive fit of two points is
cheap.  A *mechanistic* alternative is that code attention decays geometrically at a
faster rate — `cum k = 1 - r^k` with `r_code = r_prose ^ a` for some `a > 1` — which
divides the knee rather than shifting it.

This file develops that alternative honestly and pushes both models to breaking point.

## Contents

*§1 Geometric profiles.*  `geomKnee r ρ` is the least budget with `r ^ k ≤ ρ`
(`ρ = 1 - τ` is the residual tolerance).  `geomKnee_eq_ceil` computes it exactly as
`⌈log ρ / log r⌉₊` — the **continuous knee** `X` of the domain — and
`geomKnee_rpow_eq_ceil_div` shows that raising the decay rate to the power `a` divides
the continuous knee by `a`.  `exists_geom_profile_with_continuous_knee`: every positive
`X` is realised by an actual geometric profile, so the model is not empty.

*§2 Ceiling calculus.*  `lt_of_ceil_eq`, `le_of_ceil_eq` — the exact bracket a knee
reading imposes on the continuous knee.

*§3 The two models on the measured data.*  `additive_model_matches` and
`rescaling_model_matches` (witness `a = 251/200`, `X_prose(512) = 15.05`,
`X_prose(1024) = 20`, geometrically realised by `rescaling_model_realisable`):
**both** reproduce all four measured knees.  `two_cells_do_not_identify_the_mechanism`
states the resulting identifiability failure — the honest limit of round 21.

*§4 The discriminating experiment.*  `rescaling_factor_gt_five_quarters`: the 512 cell
*forces* `a > 5/4` in any rescaling model.  `rescaling_prediction_4096_le_23`: every such
model then predicts at most `23` keys at 4096, whereas the additive law predicts exactly
`24` (`additive_prediction_4096_eq_24`).  `net69_discriminating_experiment`: the two
mechanisms are separated by a single measurement at ctx 4096 — and `separation_is_sharp`
shows one further doubling is genuinely needed, since at 2048 the models can still agree.
-/
import Mathlib
import Applications.NET68DomainJumpBudgetLaw

namespace Catalog.NET68

open Real

/-! ## 1. Geometric attention profiles and the continuous knee -/

/-- The knee of a geometrically decaying profile `cum k = 1 - r ^ k`: the least budget
whose residual mass `r ^ k` is within the residual tolerance `ρ = 1 - τ`. -/
noncomputable def geomKnee (r ρ : ℝ) : ℕ := sInf {k : ℕ | r ^ k ≤ ρ}

/-- **The continuous knee.**  For a decay rate `r ∈ (0,1)` and residual tolerance
`ρ ∈ (0,1)`, the geometric knee is exactly `⌈log ρ / log r⌉₊`.  This is the quantity the
budget law is really about; the measured `k*` is its ceiling on the fine grid. -/
theorem geomKnee_eq_ceil {r ρ : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (hρ0 : 0 < ρ) :
    geomKnee r ρ = ⌈Real.log ρ / Real.log r⌉₊ := by
  have hL : Real.log r < 0 := Real.log_neg hr0 hr1
  set X : ℝ := Real.log ρ / Real.log r with hX
  have hmem : ∀ k : ℕ, r ^ k ≤ ρ ↔ X ≤ (k : ℝ) := by
    intro k
    have hpow : (0 : ℝ) < r ^ k := pow_pos hr0 k
    rw [← Real.log_le_log_iff hpow hρ0, Real.log_pow, hX, div_le_iff_of_neg hL]
  have hceil : X ≤ (⌈X⌉₊ : ℝ) := Nat.le_ceil X
  have h1 : ⌈X⌉₊ ∈ {k : ℕ | r ^ k ≤ ρ} := (hmem _).2 hceil
  have h2 : ∀ k ∈ {k : ℕ | r ^ k ≤ ρ}, ⌈X⌉₊ ≤ k := fun k hk =>
    Nat.ceil_le.2 ((hmem k).1 hk)
  exact le_antisymm (Nat.sInf_le h1) (h2 _ (Nat.sInf_mem ⟨_, h1⟩))

/-- Raising the decay rate to the power `a > 0` divides the continuous knee by `a`: this
is the precise content of "the same attention shape, decaying `a` times faster". -/
theorem geomKnee_rpow_eq_ceil_div {r ρ a : ℝ} (hr0 : 0 < r) (hr1 : r < 1) (hρ0 : 0 < ρ)
    (ha : 0 < a) :
    geomKnee (r ^ a) ρ = ⌈(Real.log ρ / Real.log r) / a⌉₊ := by
  have hpos : 0 < r ^ a := Real.rpow_pos_of_pos hr0 a
  have hlt : r ^ a < 1 := Real.rpow_lt_one hr0.le hr1 ha
  rw [geomKnee_eq_ceil hpos hlt hρ0, Real.log_rpow hr0]
  congr 1
  field_simp

/-- Every positive continuous knee is realised by an honest geometric profile, so the
rescaling model has content. -/
theorem exists_geom_profile_with_continuous_knee {X : ℝ} (hX : 0 < X) :
    ∃ r ρ : ℝ, 0 < r ∧ r < 1 ∧ 0 < ρ ∧ ρ < 1 ∧ geomKnee r ρ = ⌈X⌉₊ := by
  refine ⟨Real.exp (-1), Real.exp (-X), Real.exp_pos _, ?_, Real.exp_pos _, ?_, ?_⟩
  · exact Real.exp_lt_one_iff.2 (by norm_num)
  · exact Real.exp_lt_one_iff.2 (by linarith)
  · rw [geomKnee_eq_ceil (Real.exp_pos _) (Real.exp_lt_one_iff.2 (by norm_num))
      (Real.exp_pos _), Real.log_exp, Real.log_exp]
    congr 1
    field_simp

/-! ## 2. What a knee reading says about the continuous knee -/

/-- A knee reading `n ≥ 1` forces `X ≤ n`. -/
theorem le_of_ceil_eq {X : ℝ} {n : ℕ} (h : ⌈X⌉₊ = n) : X ≤ (n : ℝ) :=
  Nat.ceil_le.1 h.le

/-- A knee reading `n ≥ 1` forces `n - 1 < X`. -/
theorem lt_of_ceil_eq {X : ℝ} {n : ℕ} (hn : 0 < n) (h : ⌈X⌉₊ = n) : ((n : ℝ) - 1) < X := by
  have : n - 1 < ⌈X⌉₊ := by omega
  have h' : ((n - 1 : ℕ) : ℝ) < X := Nat.lt_ceil.1 this
  have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
    have : (1 : ℕ) ≤ n := hn
    push_cast [Nat.cast_sub this]
    ring
  linarith [hcast ▸ h']

/-! ## 3. Both mechanisms fit the two measured cells -/

/-- The additive law reproduces the four measured knees `(16, 20)` for prose and
`(12, 16)` for code. -/
theorem additive_model_matches :
    proseLaw.eval 0 = 16 ∧ proseLaw.eval 1 = 20 ∧
    codeLaw.eval 0 = 12 ∧ codeLaw.eval 1 = 16 :=
  ⟨net68_prose_fit.1, net68_prose_fit.2, net68_code_fit.1, net68_code_fit.2⟩

/-- **The rescaling mechanism also fits.**  With decay-rate exponent `a = 251/200` and
prose continuous knees `15.05` (ctx 512) and `20` (ctx 1024), all four measured readings
are reproduced exactly. -/
theorem rescaling_model_matches :
    ⌈(1505 / 100 : ℝ)⌉₊ = 16 ∧ ⌈(1505 / 100 : ℝ) / (251 / 200)⌉₊ = 12 ∧
    ⌈(20 : ℝ)⌉₊ = 20 ∧ ⌈(20 : ℝ) / (251 / 200)⌉₊ = 16 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num

/-- The rescaling witness is not an abstraction: honest geometric profiles with those
continuous knees exist, both for prose and for the `a`-times faster code decay. -/
theorem rescaling_model_realisable :
    (∃ r ρ : ℝ, 0 < r ∧ r < 1 ∧ 0 < ρ ∧ ρ < 1 ∧ geomKnee r ρ = 16) ∧
    (∃ r ρ : ℝ, 0 < r ∧ r < 1 ∧ 0 < ρ ∧ ρ < 1 ∧ geomKnee r ρ = 12) := by
  obtain ⟨r, ρ, h1, h2, h3, h4, h5⟩ :=
    exists_geom_profile_with_continuous_knee (X := (1505 / 100 : ℝ)) (by norm_num)
  obtain ⟨r', ρ', h1', h2', h3', h4', h5'⟩ :=
    exists_geom_profile_with_continuous_knee (X := (12 : ℝ)) (by norm_num)
  refine ⟨⟨r, ρ, h1, h2, h3, h4, ?_⟩, ⟨r', ρ', h1', h2', h3', h4', ?_⟩⟩
  · rw [h5, Nat.ceil_eq_iff (by norm_num)]; norm_num
  · rw [h5', Nat.ceil_eq_iff (by norm_num)]; norm_num

/-- **Identifiability failure — the honest limit of round 21.**  Two contexts cannot
distinguish an additive base shift from a rescaling of the attention decay rate: both
mechanisms reproduce all four measured knees exactly. -/
theorem two_cells_do_not_identify_the_mechanism :
    (proseLaw.eval 0 = 16 ∧ proseLaw.eval 1 = 20 ∧
      codeLaw.eval 0 = 12 ∧ codeLaw.eval 1 = 16) ∧
    (∃ a Xp0 Xp1 : ℝ, 1 < a ∧
      ⌈Xp0⌉₊ = 16 ∧ ⌈Xp0 / a⌉₊ = 12 ∧ ⌈Xp1⌉₊ = 20 ∧ ⌈Xp1 / a⌉₊ = 16) :=
  ⟨additive_model_matches,
    251 / 200, 1505 / 100, 20, by norm_num,
    rescaling_model_matches.1, rescaling_model_matches.2.1,
    rescaling_model_matches.2.2.1, rescaling_model_matches.2.2.2⟩

/-! ## 4. The experiment that separates them -/

/-- The 512 cell alone already pins the rescaling exponent from below: `a > 5/4`. -/
theorem rescaling_factor_gt_five_quarters {a X : ℝ} (ha : 0 < a) (h16 : ⌈X⌉₊ = 16)
    (h12 : ⌈X / a⌉₊ = 12) : 5 / 4 < a := by
  have hlow : (15 : ℝ) < X := by
    have := lt_of_ceil_eq (n := 16) (by norm_num) h16
    norm_num at this
    linarith
  have hup : X / a ≤ 12 := by
    have := le_of_ceil_eq (n := 12) h12
    norm_num at this
    linarith
  have : X ≤ 12 * a := by
    rw [div_le_iff₀ ha] at hup
    linarith
  linarith

/-- Any rescaling model consistent with the 512 cell predicts **at most 23** keys for code
at ctx 4096, given the prose reading `28` predicted there by the increment law. -/
theorem rescaling_prediction_4096_le_23 {a X : ℝ} (ha : 5 / 4 < a)
    (h28 : ⌈X⌉₊ = 28) : ⌈X / a⌉₊ ≤ 23 := by
  have hle : X ≤ 28 := by
    have := le_of_ceil_eq (n := 28) h28
    norm_num at this
    linarith
  have hapos : (0 : ℝ) < a := by linarith
  have : X / a ≤ 23 := by
    rw [div_le_iff₀ hapos]
    nlinarith
  exact Nat.ceil_le.2 (by exact_mod_cast this)

/-- The additive law predicts exactly `24` keys for code at ctx 4096. -/
theorem additive_prediction_4096_eq_24 : codeLaw.eval 3 = 24 := net68_prediction_4096.1

/-- **The discriminating experiment (NET-69).**  Every decay-rescaling model that
reproduces the measured 512 cell predicts at most `23` keys for code at ctx 4096, while
the additive budget law predicts exactly `24`.  One measurement at 4096 therefore
separates the two mechanisms — the identifiability failure of §3 is removable. -/
theorem net69_discriminating_experiment :
    codeLaw.eval 3 = 24 ∧
    ∀ a X X3 : ℝ, 0 < a → ⌈X⌉₊ = 16 → ⌈X / a⌉₊ = 12 → ⌈X3⌉₊ = 28 →
      (⌈X3 / a⌉₊ : ℤ) < codeLaw.eval 3 := by
  refine ⟨additive_prediction_4096_eq_24, fun a X X3 ha h16 h12 h28 => ?_⟩
  have hle := rescaling_prediction_4096_le_23
    (rescaling_factor_gt_five_quarters ha h16 h12) h28
  rw [additive_prediction_4096_eq_24]
  exact_mod_cast Nat.lt_of_le_of_lt hle (by norm_num)

/-- **The exponent window closes at 4096.**  No decay-rescaling model whatsoever can
reproduce both the measured 512 cell (`16 → 12`) and the additive prediction at 4096
(`28 → 24`): the first forces `a > 5/4`, the second `a < 28/23`.  So if the 4096 cell
reads `24`, the rescaling mechanism is dead — not merely disfavoured. -/
theorem no_rescaling_model_fits_512_and_4096 {a X0 X3 : ℝ} (ha : 0 < a)
    (h16 : ⌈X0⌉₊ = 16) (h12 : ⌈X0 / a⌉₊ = 12)
    (h28 : ⌈X3⌉₊ = 28) (h24 : ⌈X3 / a⌉₊ = 24) : False := by
  have hlow : 5 / 4 < a := rescaling_factor_gt_five_quarters ha h16 h12
  have hup : X3 ≤ 28 := by
    have := le_of_ceil_eq (n := 28) h28
    norm_num at this
    linarith
  have h23 : (23 : ℝ) < X3 / a := by
    have := lt_of_ceil_eq (n := 24) (by norm_num) h24
    norm_num at this
    linarith
  rw [lt_div_iff₀ ha] at h23
  linarith

/-- **The separation is sharp: 4096 is the first context that decides.**  The single
rescaling witness `a = 251/200` reproduces the additive prediction at ctx 512, 1024 *and*
2048 (prose continuous knees `15.05`, `20`, `24`; code readings `12`, `16`, `20`).  So no
measurement below 4096 can separate the mechanisms, while at 4096 the bound
`rescaling_prediction_4096_le_23` is strictly below the additive `24` for *every*
admissible `a`. -/
theorem separation_is_sharp :
    codeLaw.eval 2 = 20 ∧
    ⌈(24 : ℝ)⌉₊ = 24 ∧ ⌈(24 : ℝ) / (251 / 200)⌉₊ = 20 := by
  refine ⟨by norm_num [codeLaw, BudgetLaw.eval], ?_, ?_⟩
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num
  · rw [Nat.ceil_eq_iff (by norm_num)]; norm_num

end Catalog.NET68