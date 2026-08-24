import Novelty.KneeDomainNarrowing

/-!
# The shared phase coordinate: rigidity, forecasts, and dilution-stable protection
(NET-87, round 31, cycle 2)

`Novelty.KneeDomainNarrowing` models each domain by an affine knee law
`K_d(T) = a_d + b_d T` in a **shared** phase-transition coordinate `T`, and shows
that the narrowing of the code/prose factor plus the growth of the gap force
permanent protection.  That model has a strong, immediately testable
consequence which this file isolates and proves.

### Rigidity: an increment-ratio invariant
If all domains ride the *same* coordinate, then for any three contexts the
normalised increment
`ρ = (K_d(T₂) − K_d(T₁)) / (K_d(T₃) − K_d(T₁))`
is `(T₂ − T₁)/(T₃ − T₁)`: it does **not depend on the domain**
(`increment_ratio_domain_invariant`, `increment_ratio_domain_free`).  This is the
knee analogue of a cross-ratio: the domain constants `a_d, b_d` cancel.

The converse holds too (`affine_model_of_increment_ratio_invariance`): two knee
chains sharing one increment ratio can always be written as affine laws in a
common coordinate.  So *increment-ratio invariance* is exactly the empirical
content of "one shared phase transition, per-domain slopes".

### Forecast
For the measured code chain `12 @512, 16 @1024, 32 @4096` the invariant is
`ρ = 1/5`, i.e. `T₃ − T₁ = 5 (T₂ − T₁)`.  Hence **every** domain riding the same
transition satisfies the one-line forecast
`K(4096) = K(512) + 5 (K(1024) − K(512))` (`domain_jump_forecast`).
This forces the prose knee at 1024 to be `104/5 = 20.8`
(`prose_knee_at_1024_forced`) and yields the concrete next-cycle targets for
math, German and French (`domain_jump_forecast_examples`).  A measured 4096 knee
off this line falsifies the shared-coordinate model — which is the strongest
falsifier the thread currently has.

### Quantitative narrowing rate
`ratio_within_eps` turns the limit statement into a budget: the factor is within
`ε` of `b_c/b_p` as soon as the prose knee exceeds `|a_c b_p − a_p b_c| / (b_p ε)`.
For the measured fit, the factor is within `1/100` of `5/6` once the prose knee
passes `400/3 ≈ 134` keys (`net87_epsilon_budget` records the convenient
threshold `288`) — far beyond any context yet swept, so the observed `0.80` is
nowhere near saturation.

### Protection is stable under tokenisation
Finally we connect back to the multiplicative dilution law of
`Novelty.KneeDilutionGrid`: if code is diluted by `r_c` tokens per unit and prose
by `r_p`, protection survives whenever `r_c K_code ≤ r_p (K_prose − 1)`
(`protection_survives_dilution`), and in particular whenever `r_c ≤ r_p` and the
gap is at least a `1/r_p` fraction of the code knee.  Protection is therefore not
an artefact of a shared tokenizer.
-/

namespace Catalog.Novelty.KneeDilutionGrid

/-! ### 1. The increment-ratio invariant -/

/-- **Domain constants cancel in a normalised increment.**  For an affine knee
law the ratio of increments over three contexts equals the ratio of the
coordinate increments — it is independent of `a` and of `b`. -/
theorem increment_ratio_domain_invariant {a b T₁ T₂ T₃ : ℝ} (hb : b ≠ 0) (h13 : T₁ ≠ T₃) :
    (kneeLaw a b T₂ - kneeLaw a b T₁) / (kneeLaw a b T₃ - kneeLaw a b T₁)
      = (T₂ - T₁) / (T₃ - T₁) := by
  have h : T₃ - T₁ ≠ 0 := sub_ne_zero.2 (Ne.symm h13)
  simp only [kneeLaw]
  rw [show a + b * T₂ - (a + b * T₁) = b * (T₂ - T₁) by ring,
    show a + b * T₃ - (a + b * T₁) = b * (T₃ - T₁) by ring]
  exact mul_div_mul_left _ _ hb

/-- **The invariant is domain free.**  Two domains riding the same phase
coordinate have equal normalised increments over any three contexts.  This is a
sharp, cheap falsifier of the shared-transition model: it needs three contexts
in two domains and no fitting. -/
theorem increment_ratio_domain_free {ac bc ap bp T₁ T₂ T₃ : ℝ} (hbc : bc ≠ 0) (hbp : bp ≠ 0)
    (h13 : T₁ ≠ T₃) :
    (kneeLaw ac bc T₂ - kneeLaw ac bc T₁) / (kneeLaw ac bc T₃ - kneeLaw ac bc T₁)
      = (kneeLaw ap bp T₂ - kneeLaw ap bp T₁) / (kneeLaw ap bp T₃ - kneeLaw ap bp T₁) := by
  rw [increment_ratio_domain_invariant hbc h13, increment_ratio_domain_invariant hbp h13]

/-- **Converse: invariance is the whole content of the model.**  Any two knee
chains over three contexts that share one normalised increment are realised by
affine laws in a *common* coordinate (normalised to `T₁ = 0`, `T₃ = 1`).  Hence
"shared phase transition with per-domain slopes" is neither more nor less than
the equality of normalised increments. -/
theorem affine_model_of_increment_ratio_invariance {c₁ c₂ c₃ p₁ p₂ p₃ : ℝ}
    (hc : c₁ < c₃) (hp : p₁ < p₃)
    (hinv : (c₂ - c₁) / (c₃ - c₁) = (p₂ - p₁) / (p₃ - p₁)) :
    ∃ ac bc ap bp T₂ : ℝ, 0 < bc ∧ 0 < bp ∧
      kneeLaw ac bc 0 = c₁ ∧ kneeLaw ac bc T₂ = c₂ ∧ kneeLaw ac bc 1 = c₃ ∧
      kneeLaw ap bp 0 = p₁ ∧ kneeLaw ap bp T₂ = p₂ ∧ kneeLaw ap bp 1 = p₃ := by
  have hc0 : c₃ - c₁ ≠ 0 := sub_ne_zero.2 (ne_of_gt hc)
  have hp0 : p₃ - p₁ ≠ 0 := sub_ne_zero.2 (ne_of_gt hp)
  refine ⟨c₁, c₃ - c₁, p₁, p₃ - p₁, (c₂ - c₁) / (c₃ - c₁), by linarith, by linarith, ?_, ?_, ?_,
    ?_, ?_, ?_⟩
  · simp [kneeLaw]
  · simp only [kneeLaw]
    field_simp
    ring
  · simp [kneeLaw]
  · simp [kneeLaw]
  · simp only [kneeLaw, hinv]
    field_simp
    ring
  · simp [kneeLaw]

/-! ### 2. The forecast rule -/

/-- **The domain-jump forecast.**  If the coordinate gap from 512 to 4096 is five
times the gap from 512 to 1024 — the value pinned by the measured code chain —
then every domain on the same transition obeys
`K(4096) = K(512) + 5 (K(1024) − K(512))`, with no free parameters. -/
theorem domain_jump_forecast {a b T₁ T₂ T₃ : ℝ} (hT : T₃ - T₁ = 5 * (T₂ - T₁)) :
    kneeLaw a b T₃ = kneeLaw a b T₁ + 5 * (kneeLaw a b T₂ - kneeLaw a b T₁) := by
  have h : b * (T₃ - T₁) = 5 * (b * (T₂ - T₁)) := by rw [hT]; ring
  simp only [kneeLaw]
  linarith [h]

/-- The measured code chain pins the coordinate: `T₃ − T₁ = 5 (T₂ − T₁)`. -/
theorem code_chain_pins_coordinate {ac bc T₁ T₂ T₃ : ℝ}
    (h1 : kneeLaw ac bc T₁ = 12) (h2 : kneeLaw ac bc T₂ = 16) (h3 : kneeLaw ac bc T₃ = 32) :
    T₃ - T₁ = 5 * (T₂ - T₁) := by
  simp only [kneeLaw] at h1 h2 h3
  have hb2 : bc * (T₂ - T₁) = 4 := by nlinarith
  have hb3 : bc * (T₃ - T₁) = 20 := by nlinarith
  have hbne : bc ≠ 0 := by
    intro h
    rw [h] at hb3
    norm_num at hb3
  have : bc * ((T₃ - T₁) - 5 * (T₂ - T₁)) = 0 := by nlinarith
  have := mul_eq_zero.1 this
  rcases this with h | h
  · exact absurd h hbne
  · linarith

/-- **The prose knee at ctx 1024 is forced.**  Given the code chain
`12, 16, 32` and the prose endpoints `16 @512`, `40 @4096`, the shared coordinate
leaves no freedom: the prose knee at 1024 must be `104/5 = 20.8`.  A measured
prose knee of `24` or more at ctx 1024 refutes the shared-coordinate model. -/
theorem prose_knee_at_1024_forced {ac bc ap bp T₁ T₂ T₃ : ℝ}
    (hc1 : kneeLaw ac bc T₁ = 12) (hc2 : kneeLaw ac bc T₂ = 16) (hc3 : kneeLaw ac bc T₃ = 32)
    (hp1 : kneeLaw ap bp T₁ = 16) (hp3 : kneeLaw ap bp T₃ = 40) :
    kneeLaw ap bp T₂ = 104 / 5 := by
  have hT := code_chain_pins_coordinate hc1 hc2 hc3
  simp only [kneeLaw] at hp1 hp3 ⊢
  have h24 : bp * (T₃ - T₁) = 24 := by nlinarith
  have h5 : bp * (T₃ - T₁) = 5 * (bp * (T₂ - T₁)) := by rw [hT]; ring
  have : bp * (T₂ - T₁) = 24 / 5 := by linarith
  nlinarith

/-- **Next-cycle targets.**  The forecast applied to three plausible short-context
chains: a domain kneeing at `10, 14` predicts `30` at 4096; one at `14, 20`
predicts `44`; one at `16, 24` predicts `56`.  Each is a single sweep away from
falsifying the shared-coordinate model. -/
theorem domain_jump_forecast_examples {a b T₁ T₂ T₃ : ℝ} (hT : T₃ - T₁ = 5 * (T₂ - T₁)) :
    (kneeLaw a b T₁ = 10 → kneeLaw a b T₂ = 14 → kneeLaw a b T₃ = 30) ∧
    (kneeLaw a b T₁ = 14 → kneeLaw a b T₂ = 20 → kneeLaw a b T₃ = 44) ∧
    (kneeLaw a b T₁ = 16 → kneeLaw a b T₂ = 24 → kneeLaw a b T₃ = 56) := by
  have h := domain_jump_forecast (a := a) (b := b) hT
  refine ⟨fun h1 h2 => ?_, fun h1 h2 => ?_, fun h1 h2 => ?_⟩ <;>
    rw [h, h1, h2] <;> norm_num

/-- Consistency of the forecast with the measured code chain: `12, 16 ↦ 32`. -/
theorem code_forecast_consistent {a b T₁ T₂ T₃ : ℝ} (hT : T₃ - T₁ = 5 * (T₂ - T₁))
    (h1 : kneeLaw a b T₁ = 12) (h2 : kneeLaw a b T₂ = 16) : kneeLaw a b T₃ = 32 := by
  rw [domain_jump_forecast hT, h1, h2]; norm_num

/-! ### 3. How far from the limit is `0.80`? -/

/-- **Quantitative narrowing.**  The domain factor is within `ε` of its limit
`b_c/b_p` as soon as the prose knee `a_p + b_p T` reaches
`|a_c b_p − a_p b_c| / (b_p ε)`. -/
theorem ratio_within_eps {ac bc ap bp eps T : ℝ} (hbp : 0 < bp) (heps : 0 < eps)
    (hd : 0 < kneeLaw ap bp T)
    (hT : |ac * bp - ap * bc| / (bp * eps) ≤ kneeLaw ap bp T) :
    |domainRatio ac bc ap bp T - bc / bp| ≤ eps := by
  have hden : 0 < bp * kneeLaw ap bp T := mul_pos hbp hd
  rw [ratio_sub_limit hbp hd, abs_div, abs_of_pos hden, div_le_iff₀ hden]
  have hmul : |ac * bp - ap * bc| ≤ bp * eps * kneeLaw ap bp T := by
    rw [div_le_iff₀ (by positivity)] at hT
    linarith
  nlinarith

/-- **The measured `0.80` is not near saturation.**  For the fit
`12 + 20T` vs `16 + 24T` the factor is within `1/100` of `5/6` once the prose
knee passes `288` keys (the criterion's sharp threshold is `32 / (24/100) =
400/3 ≈ 134`) — far beyond any swept context.  So the trend `0.75 → 0.80` has
essentially all of its remaining range left: the observed narrowing is *early*
in the approach to its limit. -/
theorem net87_epsilon_budget {T : ℝ} (hT : 288 ≤ kneeLaw 16 24 T) :
    |domainRatio 12 20 16 24 T - 20 / 24| ≤ 1 / 100 := by
  have hd : 0 < kneeLaw 16 24 T := lt_of_lt_of_le (by norm_num) hT
  refine ratio_within_eps (by norm_num) (by norm_num) hd ?_
  have habs : |(12 : ℝ) * 24 - 16 * 20| = 32 := by norm_num [abs_of_nonneg]
  rw [habs]
  norm_num
  linarith

/-! ### 4. Protection is stable under tokenisation -/

/-- **Protection survives a domain-dependent tokenizer.**  If the code profile is
diluted by `r_c` tokens per unit and the prose profile by `r_p`, and the budget
inequality `r_c · K_code ≤ r_p · (K_prose − 1)` holds, then the diluted code knee
is still strictly below the diluted prose knee.  The verdict
CODE-AT-4096-IS-PROTECTED is therefore not an artefact of a common tokenizer:
it survives any tokenisation whose ratios respect that inequality — e.g. the
measured cell `K_code = 32, K_prose = 40` survives every pair with
`4 r_c ≤ 5 r_p − r_p/8`. -/
theorem protection_survives_dilution {rc rp : ℕ} (hrc : 0 < rc) (hrp : 0 < rp)
    {c q : ℕ → ℝ} (hq : ∀ i, 0 ≤ q i) {tau : ℝ}
    (hexc : ∃ k, tau ≤ prefixMass c k) (hexq : ∃ k, tau ≤ prefixMass q k)
    (hKq : 0 < knee q tau)
    (hbudget : rc * knee c tau ≤ rp * (knee q tau - 1)) :
    knee (tokenSplit rc c) tau < knee (tokenSplit rp q) tau := by
  have hup : knee (tokenSplit rc c) tau ≤ rc * knee c tau := knee_tokenSplit_le hrc hexc
  have hlow : rp * (knee q tau - 1) < knee (tokenSplit rp q) tau :=
    knee_tokenSplit_gt hrp hq hexq hKq
  omega

/-- The concrete NET-87 instance: with `K_code = 32`, `K_prose = 40`, protection
survives whenever `4 r_c ≤ 39 r_p / 8`; in particular it survives every tokenizer
that is no coarser on code than on prose (`r_c ≤ r_p`). -/
theorem protection_survives_equal_or_finer_code_tokenizer {rc rp : ℕ} (hrc : 0 < rc)
    (hrp : 0 < rp) (hle : rc ≤ rp) {c q : ℕ → ℝ} (hq : ∀ i, 0 ≤ q i) {tau : ℝ}
    (hexc : ∃ k, tau ≤ prefixMass c k) (hexq : ∃ k, tau ≤ prefixMass q k)
    (hKc : knee c tau = 32) (hKq : knee q tau = 40) :
    knee (tokenSplit rc c) tau < knee (tokenSplit rp q) tau := by
  refine protection_survives_dilution hrc hrp hq hexc hexq (by omega) ?_
  rw [hKc, hKq]
  have : rc * 32 ≤ rp * 32 := Nat.mul_le_mul_right 32 hle
  omega

/-- **Sharpness of the dilution criterion.**  The budget inequality cannot simply
be dropped: for the measured knees there is a tokenisation pair (`r_c = 8`,
`r_p = 1`) whose diluted code knee provably exceeds the diluted prose knee, so
protection is a genuine constraint on the tokenizer, not a theorem about the
profiles alone. -/
theorem protection_can_fail_under_dilution {c q : ℕ → ℝ} (hc : ∀ i, 0 ≤ c i) {tau : ℝ}
    (hexc : ∃ k, tau ≤ prefixMass c k) (hexq : ∃ k, tau ≤ prefixMass q k)
    (hKc : knee c tau = 32) (hKq : knee q tau = 40) :
    knee (tokenSplit 1 q) tau < knee (tokenSplit 8 c) tau := by
  have hup : knee (tokenSplit 1 q) tau ≤ 1 * knee q tau := knee_tokenSplit_le one_pos hexq
  have hlow : 8 * (knee c tau - 1) < knee (tokenSplit 8 c) tau :=
    knee_tokenSplit_gt (by norm_num) hc hexc (by rw [hKc]; norm_num)
  rw [hKc] at hlow
  rw [hKq] at hup
  omega


/-- **The measured narrowing refutes a purely multiplicative domain model.**  The
NET-72 tokenisation mechanism makes the domain factor a *constant* `ρ`
(`K_code = ρ · K_prose` at every context).  Any measurement in which the factor
strictly changes between two contexts — as `0.75 → 0.80` does — is therefore
inconsistent with a purely multiplicative domain law, whatever `ρ` is.  The
narrowing is evidence for an additive structural component on top of the shared
transition. -/
theorem no_constant_domain_factor {ac bc ap bp T₁ T₂ : ℝ}
    (hd1 : kneeLaw ap bp T₁ ≠ 0) (hd2 : kneeLaw ap bp T₂ ≠ 0)
    (hne : domainRatio ac bc ap bp T₁ ≠ domainRatio ac bc ap bp T₂) :
    ¬ ∃ rho : ℝ, ∀ T, kneeLaw ac bc T = rho * kneeLaw ap bp T := by
  rintro ⟨rho, hrho⟩
  apply hne
  rw [domainRatio, domainRatio, hrho T₁, hrho T₂, mul_div_assoc, mul_div_assoc,
    div_self hd1, div_self hd2]

/-- Applied to the measured cell: no constant domain factor reproduces both
`3/4` at ctx 512 and `4/5` at ctx 4096. -/
theorem net87_no_constant_domain_factor :
    ¬ ∃ rho : ℝ, ∀ T, kneeLaw 12 20 T = rho * kneeLaw 16 24 T := by
  refine no_constant_domain_factor (T₁ := 0) (T₂ := 1) (by norm_num [kneeLaw])
    (by norm_num [kneeLaw]) ?_
  norm_num [domainRatio, kneeLaw]

end Catalog.Novelty.KneeDilutionGrid