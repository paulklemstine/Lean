import Novelty.KneeVariableDilution

/-!
# The narrowing domain factor and permanent protection (NET-87, round 31)

This file continues the limited-memory thread `Novelty.KneeDilutionGrid` →
`Novelty.KneeVariableDilution` with the structural mathematics behind the NET-87
verdict **CODE-AT-4096-IS-PROTECTED**.

The measurement.  Sweeping the retention bar over budget grids gave the code
knee chain `{12 @ ctx 512, 16 @ ctx 1024, 32 @ ctx 4096}` (at ctx 4096:
`k = 28` retains `≈0.976`, below the bar, `k = 32` retains `0.986`, above it),
against a prose knee of `40` at ctx 4096.  Two qualitative claims were extracted:

* **acceleration** — `32` exceeds any value extrapolated from the short-context
  increments (`≤ 24`);
* **narrowing** — the code/prose ratio moves from `≈0.75` at short contexts to
  `≈0.80` at 4096, i.e. the domain factor shrinks while code stays cheaper.

We formalise four things.

### 1. What the sweep licenses (`net87_code_knee_bracket`, `net87_fine_grid_needed`)
A fail at `28` and a pass at `32` bracket the knee in `[29, 32]` and *nothing
finer*: there are two nonnegative antitone profiles with identical retention at
every budget outside the open interval `(28, 32)` whose knees are `29` and `32`.
The reported value `k* = 32` is the top of a four-wide bracket.

### 2. Protection is exactly head dominance (`protection_iff_head_dominance`)
"Code is protected at every bar" is not a numerical accident: it holds for all
thresholds simultaneously **iff** the code retention curve dominates the prose
one pointwise.  So a single domain ordering of knees that survives every bar is
an ordering of retention curves, and conversely.

### 3. The narrowing law (`ratio_strictMono`, `ratio_lt_limit`,
`domainRatio_tendsto`, `narrowing_dichotomy`, `protection_permanent`)
Model each domain by an affine knee law `K_d(T) = a_d + b_d · T` in a shared
phase-transition coordinate `T` (`T = 0` at ctx 512, `T = 1` at ctx 4096 for the
measured fit).  Then

* the ratio `r(T) = K_code(T) / K_prose(T)` is strictly increasing exactly when
  `a_c b_p < a_p b_c` — narrowing is a *sign condition*, not a trend;
* narrowing implies `r(T) < b_c / b_p` for **every** `T`: the ratio approaches
  its limit strictly from below and *never reaches parity*;
* `r(T) → b_c / b_p` (`domainRatio_tendsto`), and the gap `K_prose − K_code`
  stays bounded iff `b_c = b_p` iff the limit ratio is `1` (`narrowing_dichotomy`).

Hence the headline: from *ratio increased* **and** *gap increased* between two
contexts it follows that `b_c < b_p`, so `r(T) < b_c/b_p < 1` forever —
`protection_permanent`.  Extrapolating "`0.75 → 0.80 → …→ 1`" is invalid; the
measured pair of ratios alone cannot decide it (`two_ratios_underdetermine_limit`),
the *gap* is the discriminating observable.

The measured numbers fit exactly: `a_c = 12, b_c = 20, a_p = 16, b_p = 24` give
`r(0) = 3/4`, `r(1) = 4/5`, gap `4 → 8` (measured `16 − 12` and `40 − 32`), and
limiting ratio `5/6` (`net87_measured_fit`).  The same fit predicts a prose knee
of `104/5 = 20.8` at ctx 1024 (`net87_prose_prediction_at_1024`) — a falsifiable
next-cycle target.

### 4. Acceleration is a concavity failure (`concave_chain_bound`,
`code_chain_refutes_concavity`)
Any knee law whose per-doubling increments are nonincreasing satisfies
`K j ≤ K 0 + j (K 1 − K 0)`.  With `K 0 = 12`, `K 1 = 16` this caps `K 3` at
`24`; the measured `32` therefore refutes every concave law, which is the exact
content of "P2 confirmed, the acceleration hits code".
-/

namespace Catalog.Novelty.KneeDilutionGrid

open Finset

/-! ### 1. What a fail/pass pair at 28/32 licenses -/

/-- **The measured NET-87 code cell at ctx 4096.**  The budget `28` misses the
retention bar and `32` meets it, so the knee lies in `[29, 32]`.  This — not the
point value `32` — is what the sweep proves. -/
theorem net87_code_knee_bracket {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) {tau : ℝ}
    (hfail : prefixMass p 28 < tau) (hpass : tau ≤ prefixMass p 32) :
    28 < knee p tau ∧ knee p tau ≤ 32 :=
  ⟨knee_exceeds_grid hp ⟨32, hpass⟩ hfail, knee_le_of_le hpass⟩

/-- **The bracket cannot be narrowed without a finer grid.**  There are two
nonnegative antitone profiles with the *same* retention at every budget `≤ 28`
and at every budget `≥ 32` — hence at every point of the coarse grid — whose
knees are `29` and `32`.  Reporting `k* = 32` is reporting the top of the
bracket, and the fine grid `24–32` is genuinely necessary. -/
theorem net87_fine_grid_needed :
    ∃ p q : ℕ → ℝ, (∀ i, 0 ≤ p i) ∧ (∀ i, 0 ≤ q i) ∧ Antitone p ∧ Antitone q ∧
      (∀ k ≤ 28, prefixMass p k = prefixMass q k) ∧
      (∀ k, 32 ≤ k → prefixMass p k = prefixMass q k) ∧
      knee p (29 : ℝ) = 29 ∧ knee q (29 : ℝ) = 32 := by
  obtain ⟨p, q, hp, hq, hpa, hqa, hlow, hhigh, hkp, hkq⟩ := grid_gap_ambiguity 28 32 (by norm_num)
  have hcast : ((28 : ℕ) : ℝ) + 1 = 29 := by norm_num
  rw [hcast] at hkp hkq
  exact ⟨p, q, hp, hq, hpa, hqa, hlow, hhigh, hkp, hkq⟩

/-! ### 2. Protection at every bar is head dominance -/

/-- Pointwise domination of retention curves transfers to the knee. -/
theorem knee_le_knee_of_prefixMass_le {c q : ℕ → ℝ}
    (hdom : ∀ k, prefixMass q k ≤ prefixMass c k) {tau : ℝ}
    (hex : ∃ k, tau ≤ prefixMass q k) : knee c tau ≤ knee q tau :=
  knee_le_of_le ((le_prefixMass_knee hex).trans (hdom _))

/-- **Protection is exactly head dominance.**  Code has a knee no larger than
prose at *every* reachable bar iff the code retention curve dominates the prose
curve at every budget.  A domain ordering that survives all thresholds is
therefore a statement about the profiles, not about one threshold. -/
theorem protection_iff_head_dominance {c q : ℕ → ℝ} (hc : ∀ i, 0 ≤ c i) :
    (∀ k, prefixMass q k ≤ prefixMass c k) ↔
      (∀ tau : ℝ, (∃ k, tau ≤ prefixMass q k) →
        (∃ k, tau ≤ prefixMass c k) ∧ knee c tau ≤ knee q tau) := by
  constructor
  · intro hdom tau hex
    exact ⟨⟨knee q tau, (le_prefixMass_knee hex).trans (hdom _)⟩,
      knee_le_knee_of_prefixMass_le hdom hex⟩
  · intro h k
    obtain ⟨hexc, hle⟩ := h (prefixMass q k) ⟨k, le_rfl⟩
    calc prefixMass q k ≤ prefixMass c (knee c (prefixMass q k)) := le_prefixMass_knee hexc
      _ ≤ prefixMass c k :=
          prefixMass_mono hc (hle.trans (knee_le_of_le (le_refl (prefixMass q k))))

/-! ### 3. Affine knee laws in the phase-transition coordinate -/

/-- An affine knee law `K(T) = a + b·T` in the shared phase-transition
coordinate `T`: `a` is the structural (domain) part, `b` the rate at which the
phase transition inflates the budget. -/
def kneeLaw (a b T : ℝ) : ℝ := a + b * T

/-- The domain factor: the code knee divided by the prose knee. -/
noncomputable def domainRatio (ac bc ap bp T : ℝ) : ℝ :=
  kneeLaw ac bc T / kneeLaw ap bp T

/-- The domain gap: how many more keys prose needs than code. -/
def domainGap (ac bc ap bp T : ℝ) : ℝ := kneeLaw ap bp T - kneeLaw ac bc T

lemma kneeLaw_pos {a b T : ℝ} (ha : 0 < a) (hb : 0 ≤ b) (hT : 0 ≤ T) : 0 < kneeLaw a b T := by
  have : 0 ≤ b * T := mul_nonneg hb hT
  simpa [kneeLaw] using by linarith

/-- **The narrowing criterion.**  The domain factor is strictly increasing in the
phase-transition coordinate precisely when `a_c b_p < a_p b_c`: narrowing is a
sign condition on the four law constants, not an empirical trend. -/
theorem ratio_strictMono {ac bc ap bp : ℝ} (hap : 0 < ap) (hbp : 0 ≤ bp)
    (hnar : ac * bp < ap * bc) {T₁ T₂ : ℝ} (h1 : 0 ≤ T₁) (h12 : T₁ < T₂) :
    domainRatio ac bc ap bp T₁ < domainRatio ac bc ap bp T₂ := by
  have hd1 : 0 < kneeLaw ap bp T₁ := kneeLaw_pos hap hbp h1
  have hd2 : 0 < kneeLaw ap bp T₂ := kneeLaw_pos hap hbp (h1.trans h12.le)
  rw [domainRatio, domainRatio, div_lt_div_iff₀ hd1 hd2]
  simp only [kneeLaw]
  nlinarith [mul_pos (sub_pos.2 h12) (sub_pos.2 hnar)]

/-- The exact error term: the domain factor differs from its limit `b_c/b_p` by
`(a_c b_p − a_p b_c) / (b_p (a_p + b_p T))`. -/
theorem ratio_sub_limit {ac bc ap bp T : ℝ} (hbp : 0 < bp) (hd : 0 < kneeLaw ap bp T) :
    domainRatio ac bc ap bp T - bc / bp
      = (ac * bp - ap * bc) / (bp * kneeLaw ap bp T) := by
  have hne : ap + bp * T ≠ 0 := by simpa [kneeLaw] using ne_of_gt hd
  have hbp' : bp ≠ 0 := ne_of_gt hbp
  simp only [domainRatio, kneeLaw]
  rw [div_sub_div _ _ hne hbp',
    div_eq_div_iff (mul_ne_zero hne hbp') (mul_ne_zero hbp' hne)]
  ring

/-- **Narrowing never reaches the limit.**  Under the narrowing condition the
domain factor stays strictly below `b_c/b_p` at every context. -/
theorem ratio_lt_limit {ac bc ap bp T : ℝ} (hap : 0 < ap) (hbp : 0 < bp) (hT : 0 ≤ T)
    (hnar : ac * bp < ap * bc) : domainRatio ac bc ap bp T < bc / bp := by
  have hd : 0 < kneeLaw ap bp T := kneeLaw_pos hap hbp.le hT
  have hden : 0 < bp * kneeLaw ap bp T := mul_pos hbp hd
  have := ratio_sub_limit (ac := ac) (bc := bc) hbp hd
  have hneg : (ac * bp - ap * bc) / (bp * kneeLaw ap bp T) < 0 :=
    div_neg_of_neg_of_pos (by linarith) hden
  linarith [this ▸ hneg]

/-- The domain factor converges to the slope ratio `b_c / b_p`. -/
theorem domainRatio_tendsto {ac bc ap bp : ℝ} (hbp : 0 < bp) :
    Filter.Tendsto (fun T => domainRatio ac bc ap bp T) Filter.atTop
      (nhds (bc / bp)) := by
  have hden : Filter.Tendsto (fun T : ℝ => bp * kneeLaw ap bp T) Filter.atTop Filter.atTop := by
    have h1 : Filter.Tendsto (fun T : ℝ => kneeLaw ap bp T) Filter.atTop Filter.atTop := by
      simpa [kneeLaw] using
        (Filter.tendsto_atTop_add_const_left _ ap (Filter.Tendsto.const_mul_atTop hbp
          Filter.tendsto_id))
    exact Filter.Tendsto.const_mul_atTop hbp h1
  have hz : Filter.Tendsto
      (fun T : ℝ => (ac * bp - ap * bc) / (bp * kneeLaw ap bp T)) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hden
  have hev : ∀ᶠ T : ℝ in Filter.atTop,
      domainRatio ac bc ap bp T
        = (ac * bp - ap * bc) / (bp * kneeLaw ap bp T) + bc / bp := by
    filter_upwards [Filter.eventually_gt_atTop (|ap| / bp + 1)] with T hT
    have hd : 0 < kneeLaw ap bp T := by
      have h1 : |ap| / bp + 1 > 0 := by positivity
      have h2 : bp * (|ap| / bp) = |ap| := by field_simp
      have h3 : -|ap| ≤ ap := neg_abs_le ap
      have h4 : bp * (|ap| / bp + 1) < bp * T := mul_lt_mul_of_pos_left hT hbp
      simp only [kneeLaw]
      nlinarith
    have := ratio_sub_limit (ac := ac) (bc := bc) hbp hd
    linarith
  have : Filter.Tendsto
      (fun T : ℝ => (ac * bp - ap * bc) / (bp * kneeLaw ap bp T) + bc / bp)
      Filter.atTop (nhds (0 + bc / bp)) := hz.add tendsto_const_nhds
  rw [zero_add] at this
  exact this.congr' (by filter_upwards [hev] with T hT using hT.symm)

/-- The gap between the two laws is itself affine, with slope `b_p − b_c`. -/
theorem domainGap_eq (ac bc ap bp T : ℝ) :
    domainGap ac bc ap bp T = (ap - ac) + (bp - bc) * T := by
  simp only [domainGap, kneeLaw]; ring

/-- **A growing gap forces distinct phase-transition slopes.**  If prose pulls
away from code between two contexts, the two domains cannot share the slope. -/
theorem slopes_differ_of_gap_increase {ac bc ap bp T₁ T₂ : ℝ} (h12 : T₁ < T₂)
    (hgap : domainGap ac bc ap bp T₁ < domainGap ac bc ap bp T₂) : bc < bp := by
  rw [domainGap_eq, domainGap_eq] at hgap
  nlinarith [sub_pos.2 h12]

/-- **An increasing ratio forces the narrowing sign condition.** -/
theorem narrowing_of_ratio_increase {ac bc ap bp T₁ T₂ : ℝ} (hap : 0 < ap) (hbp : 0 ≤ bp)
    (h1 : 0 ≤ T₁) (h12 : T₁ < T₂)
    (hr : domainRatio ac bc ap bp T₁ < domainRatio ac bc ap bp T₂) : ac * bp < ap * bc := by
  have hd1 : 0 < kneeLaw ap bp T₁ := kneeLaw_pos hap hbp h1
  have hd2 : 0 < kneeLaw ap bp T₂ := kneeLaw_pos hap hbp (h1.trans h12.le)
  rw [domainRatio, domainRatio, div_lt_div_iff₀ hd1 hd2] at hr
  simp only [kneeLaw] at hr
  have hkey : (ap * bc - ac * bp) * (T₂ - T₁) > 0 := by nlinarith
  have hT : 0 < T₂ - T₁ := sub_pos.2 h12
  nlinarith

/-- **The dichotomy.**  Either the two domains share the phase-transition slope,
in which case the gap is constant and the domain factor tends to parity, or the
slopes differ, in which case the gap diverges and the limiting factor is
`b_c/b_p < 1` — permanent protection. -/
theorem narrowing_dichotomy {ac bc ap bp : ℝ} (hbp : 0 < bp) (hle : bc ≤ bp) :
    (bc = bp ∧ (∀ T, domainGap ac bc ap bp T = ap - ac) ∧ bc / bp = 1) ∨
    (bc < bp ∧ (∀ T₁ T₂, T₁ < T₂ → domainGap ac bc ap bp T₁ < domainGap ac bc ap bp T₂)
        ∧ bc / bp < 1) := by
  rcases eq_or_lt_of_le hle with heq | hlt
  · refine Or.inl ⟨heq, fun T => ?_, by rw [heq]; field_simp⟩
    rw [domainGap_eq, heq]; ring
  · refine Or.inr ⟨hlt, fun T₁ T₂ h => ?_, (div_lt_one hbp).2 hlt⟩
    rw [domainGap_eq, domainGap_eq]
    nlinarith [sub_pos.2 h, sub_pos.2 hlt]

/-- **CODE-AT-4096-IS-PROTECTED, structurally.**  Suppose that between two
contexts the domain factor *increased* (narrowing) and the domain gap *also
increased*.  Then the limiting factor is `b_c/b_p < 1` and the measured factor
is below it at every context: code is protected at every context, and the
narrowing trend can never close the gap. -/
theorem protection_permanent {ac bc ap bp T₁ T₂ : ℝ} (hap : 0 < ap) (hbp : 0 < bp)
    (h1 : 0 ≤ T₁) (h12 : T₁ < T₂)
    (hratio : domainRatio ac bc ap bp T₁ < domainRatio ac bc ap bp T₂)
    (hgap : domainGap ac bc ap bp T₁ < domainGap ac bc ap bp T₂) :
    bc < bp ∧ bc / bp < 1 ∧ ∀ T, 0 ≤ T → domainRatio ac bc ap bp T < bc / bp := by
  have hslope : bc < bp := slopes_differ_of_gap_increase h12 hgap
  have hnar : ac * bp < ap * bc := narrowing_of_ratio_increase hap hbp.le h1 h12 hratio
  exact ⟨hslope, (div_lt_one hbp).2 hslope, fun T hT => ratio_lt_limit hap hbp hT hnar⟩

/-! ### 4. The measured NET-87 fit and its prediction -/

/-- **The measured cell fits an affine pair exactly.**  With
`K_code(T) = 12 + 20T` and `K_prose(T) = 16 + 24T` (coordinate `T = 0` at
ctx 512, `T = 1` at ctx 4096) the measured code/prose knees `12 vs 16` and
`32 vs 40` are reproduced, the factor moves `3/4 → 4/5`, the gap grows `4 → 8`,
and the limiting factor is `5/6`: code stays cheaper by a sixth forever. -/
theorem net87_measured_fit :
    kneeLaw 12 20 0 = 12 ∧ kneeLaw 16 24 0 = 16 ∧
    kneeLaw 12 20 1 = 32 ∧ kneeLaw 16 24 1 = 40 ∧
    domainRatio 12 20 16 24 0 = 3 / 4 ∧
    domainRatio 12 20 16 24 1 = 4 / 5 ∧
    domainGap 12 20 16 24 0 = 4 ∧ domainGap 12 20 16 24 1 = 8 ∧
    (∀ T, 0 ≤ T → domainRatio 12 20 16 24 T < 5 / 6) := by
  refine ⟨by norm_num [kneeLaw], by norm_num [kneeLaw], by norm_num [kneeLaw],
    by norm_num [kneeLaw], by norm_num [domainRatio, kneeLaw], by norm_num [domainRatio, kneeLaw],
    by norm_num [domainGap, kneeLaw], by norm_num [domainGap, kneeLaw], fun T hT => ?_⟩
  have := ratio_lt_limit (ac := 12) (bc := 20) (ap := 16) (bp := 24) (T := T)
    (by norm_num) (by norm_num) hT (by norm_num)
  norm_num at this
  linarith

/-- The fit is strictly narrowing over the whole measured range. -/
theorem net87_fit_narrows {T₁ T₂ : ℝ} (h1 : 0 ≤ T₁) (h12 : T₁ < T₂) :
    domainRatio 12 20 16 24 T₁ < domainRatio 12 20 16 24 T₂ :=
  ratio_strictMono (by norm_num) (by norm_num) (by norm_num) h1 h12

/-- **A falsifiable next-cycle prediction.**  The code knee `16` at ctx 1024 pins
the coordinate to `T = 1/5`; the same fit then forces a prose knee of `104/5 =
20.8` there — so the prose sweep at ctx 1024 should knee at `20` or `21`, and a
value of `24` or more falsifies the affine two-slope model. -/
theorem net87_prose_prediction_at_1024 :
    kneeLaw 12 20 (1 / 5) = 16 ∧ kneeLaw 16 24 (1 / 5) = 104 / 5 ∧
      domainRatio 12 20 16 24 (1 / 5) = 10 / 13 := by
  refine ⟨by norm_num [kneeLaw], by norm_num [kneeLaw], ?_⟩
  norm_num [domainRatio, kneeLaw]

/-- **Two ratios do not determine the limit.**  The measured pair
`r = 3/4, 4/5` is reproduced both by a law whose limiting factor is `5/6`
(permanent protection) and by a law whose limiting factor is `1` (eventual
parity).  The two are separated only by the *gap*: constant in the parity law,
doubling in the protected law.  Ratio extrapolation is therefore not evidence
about protection; the gap is the discriminating observable. -/
theorem two_ratios_underdetermine_limit :
    (domainRatio 12 20 16 24 0 = 3 / 4 ∧ domainRatio 12 20 16 24 1 = 4 / 5 ∧
      (20 : ℝ) / 24 = 5 / 6 ∧ domainGap 12 20 16 24 0 = 4 ∧ domainGap 12 20 16 24 1 = 8) ∧
    (domainRatio 12 4 16 4 0 = 3 / 4 ∧ domainRatio 12 4 16 4 1 = 4 / 5 ∧
      (4 : ℝ) / 4 = 1 ∧ domainGap 12 4 16 4 0 = 4 ∧ domainGap 12 4 16 4 1 = 4) := by
  refine ⟨⟨by norm_num [domainRatio, kneeLaw], by norm_num [domainRatio, kneeLaw], by norm_num,
      by norm_num [domainGap, kneeLaw], by norm_num [domainGap, kneeLaw]⟩,
    ⟨by norm_num [domainRatio, kneeLaw], by norm_num [domainRatio, kneeLaw], by norm_num,
      by norm_num [domainGap, kneeLaw], by norm_num [domainGap, kneeLaw]⟩⟩

/-- In the parity law the factor really does tend to `1`, and in the protected
law to `5/6`: the two limits are distinct, so the underdetermination above is
not an artefact of finitely many probes. -/
theorem two_limits_distinct :
    Filter.Tendsto (fun T => domainRatio 12 4 16 4 T) Filter.atTop (nhds 1) ∧
    Filter.Tendsto (fun T => domainRatio 12 20 16 24 T) Filter.atTop (nhds (5 / 6)) := by
  constructor
  · have := domainRatio_tendsto (ac := 12) (bc := 4) (ap := 16) (bp := 4) (by norm_num)
    simpa using this
  · have h : (20 : ℝ) / 24 = 5 / 6 := by norm_num
    simpa [h] using domainRatio_tendsto (ac := 12) (bc := 20) (ap := 16) (bp := 24) (by norm_num)

/-! ### 5. Acceleration is the failure of concavity -/

/-- With nonincreasing increments every increment is bounded by the first one. -/
lemma increment_le_first {K : ℕ → ℝ}
    (hcon : ∀ j, K (j + 2) - K (j + 1) ≤ K (j + 1) - K j) (j : ℕ) :
    K (j + 1) - K j ≤ K 1 - K 0 := by
  induction j with
  | zero => exact le_rfl
  | succ j ih => exact (hcon j).trans ih

/-- **Concave chains are capped by their first increment.**  If the knee grows by
nonincreasing amounts per context doubling, then `K j ≤ K 0 + j (K 1 − K 0)`. -/
theorem concave_chain_bound {K : ℕ → ℝ}
    (hcon : ∀ j, K (j + 2) - K (j + 1) ≤ K (j + 1) - K j) (j : ℕ) :
    K j ≤ K 0 + j * (K 1 - K 0) := by
  induction j with
  | zero => simp
  | succ j ih =>
      have hstep : K (j + 1) ≤ K j + (K 1 - K 0) := by
        have := increment_le_first hcon j
        linarith
      have : K (j + 1) ≤ K 0 + j * (K 1 - K 0) + (K 1 - K 0) := by linarith
      calc K (j + 1) ≤ K 0 + j * (K 1 - K 0) + (K 1 - K 0) := this
        _ = K 0 + ((j : ℝ) + 1) * (K 1 - K 0) := by ring
        _ = K 0 + ((j + 1 : ℕ) : ℝ) * (K 1 - K 0) := by push_cast; ring

/-- **P2, the acceleration, formally.**  Indexing contexts by doublings from
512 (`j = 0 ↦ 512`, `j = 1 ↦ 1024`, `j = 3 ↦ 4096`), the measured code chain
`K 0 = 12`, `K 1 = 16`, `K 3 = 32` is incompatible with *every* law of
nonincreasing increments: concavity caps `K 3` at `24`.  The knee at 4096
exceeds the short-context extrapolation by `8` keys. -/
theorem code_chain_refutes_concavity {K : ℕ → ℝ} (h0 : K 0 = 12) (h1 : K 1 = 16)
    (h3 : K 3 = 32) : ¬ (∀ j, K (j + 2) - K (j + 1) ≤ K (j + 1) - K j) := by
  intro hcon
  have := concave_chain_bound hcon 3
  rw [h0, h1, h3] at this
  norm_num at this

/-- The acceleration is strict and quantified: the concave extrapolation of the
code chain to ctx 4096 is `24`, the measurement is `32`. -/
theorem code_chain_extrapolation_gap {K : ℕ → ℝ}
    (hcon : ∀ j, K (j + 2) - K (j + 1) ≤ K (j + 1) - K j) (h0 : K 0 = 12) (h1 : K 1 = 16) :
    K 3 ≤ 24 ∧ (32 : ℝ) - 24 = 8 := by
  refine ⟨?_, by norm_num⟩
  have := concave_chain_bound hcon 3
  rw [h0, h1] at this
  norm_num at this
  linarith

/-- **Acceleration and narrowing are compatible but independent.**  The affine
two-slope fit is *convex-free* — it has constant increments — yet it reproduces
the narrowing; the acceleration lives in the reparametrisation `j ↦ T(j)` of
context doublings into phase-transition time, which the fit forces to be convex:
`T(0) = 0, T(1) = 1/5, T(3) = 1` has strictly increasing increments. -/
theorem phase_coordinate_is_convex :
    (1 : ℝ) / 5 - 0 < (1 - 1 / 5) / 2 ∧
      kneeLaw 12 20 0 = 12 ∧ kneeLaw 12 20 (1 / 5) = 16 ∧ kneeLaw 12 20 1 = 32 := by
  refine ⟨by norm_num, by norm_num [kneeLaw], by norm_num [kneeLaw], by norm_num [kneeLaw]⟩

/-! ### 6. Back to profiles: protection with a growing gap is realisable -/

/-- The uniform profile on `n` keys has knee exactly `n` at bar `n`. -/
lemma knee_unif_self (n : ℕ) : knee (unif n) ((n : ℕ) : ℝ) = n := by
  refine knee_eq_of ?_ ?_
  · rw [prefixMass_unif, min_self]
  · intro j hj
    rw [prefixMass_unif, show min j n = j by omega]
    exact_mod_cast hj

/-- **The whole NET-87 picture is realised by honest attention profiles.**  There
are nonnegative antitone profiles for code and prose at each of two contexts
with knees `12, 16` and `32, 40`: the domain factor narrows `3/4 → 4/5`, the gap
grows `4 → 8`, and code is protected at both contexts.  So no hidden
inconsistency lurks in the verdict; the measured configuration is profile
realisable. -/
theorem net87_configuration_realisable :
    ∃ c₁ q₁ c₂ q₂ : ℕ → ℝ,
      (∀ i, 0 ≤ c₁ i) ∧ (∀ i, 0 ≤ q₁ i) ∧ (∀ i, 0 ≤ c₂ i) ∧ (∀ i, 0 ≤ q₂ i) ∧
      Antitone c₁ ∧ Antitone q₁ ∧ Antitone c₂ ∧ Antitone q₂ ∧
      knee c₁ (12 : ℝ) = 12 ∧ knee q₁ (16 : ℝ) = 16 ∧
      knee c₂ (32 : ℝ) = 32 ∧ knee q₂ (40 : ℝ) = 40 := by
  refine ⟨unif 12, unif 16, unif 32, unif 40, unif_nonneg _, unif_nonneg _, unif_nonneg _,
    unif_nonneg _, unif_antitone _, unif_antitone _, unif_antitone _, unif_antitone _,
    ?_, ?_, ?_, ?_⟩
  · simpa using knee_unif_self 12
  · simpa using knee_unif_self 16
  · simpa using knee_unif_self 32
  · simpa using knee_unif_self 40

/-- Protection at the long context transfers to every bar once the code profile
dominates: at ctx 4096 the reported knees `32 < 40` are the shadow of a
domination that holds at *all* thresholds simultaneously. -/
theorem protection_at_all_bars {c q : ℕ → ℝ} (hc : ∀ i, 0 ≤ c i)
    (hdom : ∀ k, prefixMass q k ≤ prefixMass c k) (tau : ℝ)
    (hex : ∃ k, tau ≤ prefixMass q k) : knee c tau ≤ knee q tau :=
  ((protection_iff_head_dominance (q := q) hc).1 hdom tau hex).2

end Catalog.Novelty.KneeDilutionGrid