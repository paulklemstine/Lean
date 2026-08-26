import Computation.RLHFThreshold.Core

/-!
# A sharp temperature threshold for reward hacking (conjecture N2)

Domain: Computation (alignment theory × perturbation theory × order theory).

`Computation.RLHFThreshold.Core` proves the *first-order* half of C4: the audit gap
`G(β) = 𝔼_{π_β} f − 𝔼_p f` of a statistic `f` satisfies
`|G(β) − Cov_p(r,f)/β| ≤ 24 (R/β)² σ_p(f)`.  The *sharp threshold* half — that reward
hacking of a fixed statistic at a fixed tolerance `ε` switches on at a critical
temperature `β_c(ε)`, with `β_c(ε) ~ |Cov_p(r,f)|/ε` — was left open.  This file
proves it.

* `RLHF.auditGap` — the audit gap `G(β)`;
* `RLHF.abs_auditGap_sub_cov_le` — `|G(β) − Cov/β| ≤ K/β²` with `K = 24 R² σ_p(f)`;
* `RLHF.auditGap_lower_bound`, `RLHF.auditGap_upper_bound` — the two-sided envelope
  `|Cov|/β − K/β² ≤ |G(β)| ≤ |Cov|/β + K/β²`;
* `RLHF.tendsto_beta_mul_auditGap` — `β · G(β) → Cov_p(r,f)` as `β → ∞`: the
  covariance is *exactly* the first-order hacking rate, not merely an upper bound;
* `RLHF.hacked_below_threshold` / `RLHF.safe_above_threshold` — the two sides of the
  transition: below `(1−δ)|Cov|/ε` the statistic is provably hacked, above
  `(1+δ)|Cov|/ε` it is provably safe;
* `RLHF.betaCrit` — the critical temperature, defined *intrinsically* as the supremum
  of the hacked temperatures, with `RLHF.betaCrit_window` sandwiching it inside
  `[(1−δ)|Cov|/ε, (1+δ)|Cov|/ε]` for all small `ε`;
* `RLHF.abs_eps_mul_betaCrit_sub_cov_le` and `RLHF.tendsto_eps_mul_betaCrit` —
  **the sharp threshold**: `ε · β_c(ε) → |Cov_p(r,f)|` as `ε ↓ 0`.

The transition is genuinely sharp: the constant in the threshold is the reference
covariance itself, with no loss.
-/

namespace RLHF

open Finset Filter Topology

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The audit gap and its two-sided envelope -/

/-- The audit gap `G(β) = 𝔼_{π_β} f − 𝔼_p f` of the statistic `f` at temperature `β`. -/
noncomputable def auditGap (β : ℝ) (r p f : Ω → ℝ) : ℝ :=
  mean (gibbsPolicy β r p) f - mean p f

/-- The second-order constant `K = 24 R² σ_p(f)` governing the remainder. -/
noncomputable def hackRemainder (R : ℝ) (p f : Ω → ℝ) : ℝ :=
  24 * R ^ 2 * Real.sqrt (variance p f)

omit [Nonempty Ω] in
theorem hackRemainder_nonneg (R : ℝ) (p f : Ω → ℝ) : 0 ≤ hackRemainder R p f := by
  unfold hackRemainder
  positivity

/-- The first-order law, in the scaled form `|G(β) − Cov/β| ≤ K/β²`. -/
theorem abs_auditGap_sub_cov_le {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |auditGap β r p f - cov p r f / β| ≤ hackRemainder R p f / β ^ 2 := by
  have h := audit_gap_first_order (f := f) hβ hp hR hRβ
  have hrw : 24 * (R / β) ^ 2 * Real.sqrt (variance p f) = hackRemainder R p f / β ^ 2 := by
    unfold hackRemainder
    field_simp
  rw [hrw] at h
  exact h

/-- Upper envelope: `|G(β)| ≤ |Cov_p(r,f)|/β + K/β²`. -/
theorem auditGap_upper_bound {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |auditGap β r p f| ≤ |cov p r f| / β + hackRemainder R p f / β ^ 2 := by
  have h := abs_auditGap_sub_cov_le (f := f) hβ hp hR hRβ
  have hcov : |cov p r f / β| = |cov p r f| / β := by
    rw [abs_div, abs_of_pos hβ]
  have htri : |auditGap β r p f| - |cov p r f / β| ≤ |auditGap β r p f - cov p r f / β| :=
    abs_sub_abs_le_abs_sub _ _
  rw [hcov] at htri
  linarith

/-- Lower envelope: `|Cov_p(r,f)|/β − K/β² ≤ |G(β)|`. -/
theorem auditGap_lower_bound {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |cov p r f| / β - hackRemainder R p f / β ^ 2 ≤ |auditGap β r p f| := by
  have h := abs_auditGap_sub_cov_le (f := f) hβ hp hR hRβ
  have hcov : |cov p r f / β| = |cov p r f| / β := by
    rw [abs_div, abs_of_pos hβ]
  have htri : |cov p r f / β| - |auditGap β r p f| ≤ |cov p r f / β - auditGap β r p f| :=
    abs_sub_abs_le_abs_sub _ _
  rw [hcov, abs_sub_comm] at htri
  linarith

/-! ## 2. The covariance is exactly the first-order hacking rate -/

/-- **`β · G(β) → Cov_p(r, f)`.**  The reference covariance is not just an upper bound
on the first-order drift of an audit statistic: it is the exact limit of the rescaled
audit gap.  Consequently the first-order law of `Core` cannot be improved in its
leading term. -/
theorem tendsto_beta_mul_auditGap {R : ℝ} {r p f : Ω → ℝ} (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) :
    Tendsto (fun β => β * auditGap β r p f) atTop (𝓝 (cov p r f)) := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
  rw [tendsto_iff_dist_tendsto_zero]
  have hzero : Tendsto (fun β : ℝ => hackRemainder R p f / β) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds tendsto_id
  refine squeeze_zero' (Eventually.of_forall fun β => dist_nonneg) ?_ hzero
  filter_upwards [eventually_ge_atTop (max R 1)] with β hβ
  have hβ1 : (1 : ℝ) ≤ β := le_trans (le_max_right R 1) hβ
  have hβ0 : 0 < β := lt_of_lt_of_le zero_lt_one hβ1
  have hRβ : R ≤ β := le_trans (le_max_left R 1) hβ
  have h := abs_auditGap_sub_cov_le (f := f) hβ0 hp hR hRβ
  have hdist : dist (β * auditGap β r p f) (cov p r f)
      = β * |auditGap β r p f - cov p r f / β| := by
    rw [Real.dist_eq, ← abs_of_pos hβ0, ← abs_mul, abs_of_pos hβ0]
    congr 1
    field_simp
  rw [hdist]
  have := mul_le_mul_of_nonneg_left h hβ0.le
  refine this.trans_eq ?_
  field_simp

/-! ## 3. The two sides of the transition -/

/-- **Below the threshold the statistic is hacked.**  If the remainder is dominated
(`2K ≤ δ |Cov| β`) and the temperature is below `(1−δ)|Cov|/ε` (written without
division as `ε β ≤ (1−δ)|Cov|`), then the audit gap strictly exceeds the tolerance. -/
theorem hacked_below_threshold {β R ε δ : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β)
    (hδ0 : 0 < δ) (hC : 0 < |cov p r f|)
    (hK : 2 * hackRemainder R p f ≤ δ * |cov p r f| * β)
    (hβε : ε * β ≤ (1 - δ) * |cov p r f|) :
    ε < |auditGap β r p f| := by
  have hlow := auditGap_lower_bound (f := f) hβ hp hR hRβ
  have hkey : ε < |cov p r f| / β - hackRemainder R p f / β ^ 2 := by
    have hrw : |cov p r f| / β - hackRemainder R p f / β ^ 2
        = (|cov p r f| * β - hackRemainder R p f) / β ^ 2 := by
      field_simp
    rw [hrw, lt_div_iff₀ (by positivity)]
    have h1 : ε * β * β ≤ ((1 - δ) * |cov p r f|) * β :=
      mul_le_mul_of_nonneg_right hβε hβ.le
    have h2 : 0 < δ * |cov p r f| * β := by positivity
    nlinarith [h1, h2, hK]
  linarith

/-- **Above the threshold the statistic is safe.**  If the remainder is dominated and
the temperature exceeds `(1+δ)|Cov|/ε`, the audit gap stays within tolerance. -/
theorem safe_above_threshold {β R ε δ : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β)
    (hK : 2 * hackRemainder R p f ≤ δ * |cov p r f| * β)
    (hβε : (1 + δ) * |cov p r f| ≤ ε * β) :
    |auditGap β r p f| ≤ ε := by
  have hup := auditGap_upper_bound (f := f) hβ hp hR hRβ
  have hK0 := hackRemainder_nonneg R p f
  have hkey : |cov p r f| / β + hackRemainder R p f / β ^ 2 ≤ ε := by
    rw [div_add_div _ _ (by positivity) (by positivity), div_le_iff₀ (by positivity)]
    nlinarith [mul_pos hβ hβ]
  linarith

/-- Strict form of `safe_above_threshold`, used to bound the hacked set. -/
theorem safe_above_threshold_strict {β R ε δ : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β)
    (hK : 2 * hackRemainder R p f ≤ δ * |cov p r f| * β)
    (hβε : (1 + δ) * |cov p r f| < ε * β) :
    |auditGap β r p f| < ε := by
  have hup := auditGap_upper_bound (f := f) hβ hp hR hRβ
  have hK0 := hackRemainder_nonneg R p f
  have hkey : |cov p r f| / β + hackRemainder R p f / β ^ 2 < ε := by
    rw [div_add_div _ _ (by positivity) (by positivity), div_lt_iff₀ (by positivity)]
    nlinarith [mul_pos hβ hβ]
  linarith

/-! ## 4. The critical temperature and its sharp asymptotics -/

/-- The set of temperatures at which the statistic `f` is `ε`-hacked (restricted to the
regime `β ≥ R` in which the perturbative bounds apply). -/
def hackedSet (R ε : ℝ) (r p f : Ω → ℝ) : Set ℝ :=
  {β : ℝ | R ≤ β ∧ ε ≤ |auditGap β r p f|}

/-- The **critical temperature** `β_c(ε)`: the largest temperature at which the audit
statistic can still be moved by `ε`. -/
noncomputable def betaCrit (R ε : ℝ) (r p f : Ω → ℝ) : ℝ := sSup (hackedSet R ε r p f)

section Sharp

variable {R ε δ : ℝ} {r p f : Ω → ℝ}

/-- Every hacked temperature lies below `(1+δ)|Cov|/ε`. -/
theorem hackedSet_subset (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hR0 : 0 < R)
    (hε : 0 < ε) (hδ0 : 0 < δ) (hC : 0 < |cov p r f|)
    (h2 : 2 * hackRemainder R p f * ε ≤ δ * (1 - δ) * |cov p r f| ^ 2) :
    hackedSet R ε r p f ⊆ Set.Iic ((1 + δ) * |cov p r f| / ε) := by
  intro β hβmem
  obtain ⟨hRβ, hgap⟩ := hβmem
  rw [Set.mem_Iic]
  by_contra hlt
  have hlt' : (1 + δ) * |cov p r f| / ε < β := lt_of_not_ge hlt
  have hβ0 : 0 < β := lt_of_lt_of_le hR0 hRβ
  have hβε : (1 + δ) * |cov p r f| < ε * β := by
    rw [div_lt_iff₀ hε] at hlt'
    linarith [hlt']
  have hK : 2 * hackRemainder R p f ≤ δ * |cov p r f| * β := by
    have hstep : 2 * hackRemainder R p f * ε ≤ δ * |cov p r f| * ((1 - δ) * |cov p r f|) := by
      nlinarith
    have hchain : δ * |cov p r f| * ((1 - δ) * |cov p r f|)
        ≤ δ * |cov p r f| * (ε * β) := by
      refine mul_le_mul_of_nonneg_left ?_ (by positivity)
      nlinarith
    have : 2 * hackRemainder R p f * ε ≤ (δ * |cov p r f| * β) * ε := by
      nlinarith
    exact le_of_mul_le_mul_right (by linarith) hε
  have := safe_above_threshold_strict (f := f) hβ0 hp hR hRβ hK hβε
  linarith

/-- `(1−δ)|Cov|/ε` is itself a hacked temperature. -/
theorem mem_hackedSet_of_small (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hR0 : 0 < R)
    (hε : 0 < ε) (hδ0 : 0 < δ) (hC : 0 < |cov p r f|)
    (h1 : ε * R ≤ (1 - δ) * |cov p r f|)
    (h2 : 2 * hackRemainder R p f * ε ≤ δ * (1 - δ) * |cov p r f| ^ 2) :
    (1 - δ) * |cov p r f| / ε ∈ hackedSet R ε r p f := by
  set β : ℝ := (1 - δ) * |cov p r f| / ε with hβdef
  have hβ0 : 0 < β := by
    rw [hβdef]
    have : 0 < (1 - δ) * |cov p r f| := by nlinarith
    positivity
  have hRβ : R ≤ β := by
    rw [hβdef, le_div_iff₀ hε]
    linarith
  have hβε : ε * β = (1 - δ) * |cov p r f| := by
    rw [hβdef]
    field_simp
  have hK : 2 * hackRemainder R p f ≤ δ * |cov p r f| * β := by
    have hprod : (2 * hackRemainder R p f) * ε ≤ (δ * |cov p r f| * β) * ε := by
      have : (δ * |cov p r f| * β) * ε = δ * |cov p r f| * ((1 - δ) * |cov p r f|) := by
        rw [← hβε]; ring
      rw [this]
      nlinarith
    exact le_of_mul_le_mul_right hprod hε
  refine ⟨hRβ, le_of_lt ?_⟩
  exact hacked_below_threshold (f := f) hβ0 hp hR hRβ hδ0 hC hK (le_of_eq hβε)

/-- **The critical temperature sits in the window `[(1−δ)|Cov|/ε, (1+δ)|Cov|/ε]`.** -/
theorem betaCrit_window (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hR0 : 0 < R)
    (hε : 0 < ε) (hδ0 : 0 < δ) (hC : 0 < |cov p r f|)
    (h1 : ε * R ≤ (1 - δ) * |cov p r f|)
    (h2 : 2 * hackRemainder R p f * ε ≤ δ * (1 - δ) * |cov p r f| ^ 2) :
    (1 - δ) * |cov p r f| / ε ≤ betaCrit R ε r p f ∧
      betaCrit R ε r p f ≤ (1 + δ) * |cov p r f| / ε := by
  have hsub := hackedSet_subset (f := f) hp hR hR0 hε hδ0 hC h2
  have hbdd : BddAbove (hackedSet R ε r p f) :=
    ⟨(1 + δ) * |cov p r f| / ε, fun x hx => hsub hx⟩
  have hmem := mem_hackedSet_of_small (f := f) hp hR hR0 hε hδ0 hC h1 h2
  refine ⟨le_csSup hbdd hmem, ?_⟩
  exact csSup_le ⟨_, hmem⟩ fun x hx => hsub hx

/-- **Sharp threshold, quantitative form.**  `|ε · β_c(ε) − |Cov_p(r,f)|| ≤ δ |Cov|`
for every tolerance `ε` small enough that the two explicit conditions hold. -/
theorem abs_eps_mul_betaCrit_sub_cov_le (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R)
    (hR0 : 0 < R) (hε : 0 < ε) (hδ0 : 0 < δ) (hC : 0 < |cov p r f|)
    (h1 : ε * R ≤ (1 - δ) * |cov p r f|)
    (h2 : 2 * hackRemainder R p f * ε ≤ δ * (1 - δ) * |cov p r f| ^ 2) :
    abs (ε * betaCrit R ε r p f - |cov p r f|) ≤ δ * |cov p r f| := by
  obtain ⟨hlow, hhigh⟩ := betaCrit_window (f := f) hp hR hR0 hε hδ0 hC h1 h2
  have hlow' : (1 - δ) * |cov p r f| ≤ ε * betaCrit R ε r p f := by
    rw [div_le_iff₀ hε] at hlow
    linarith
  have hhigh' : ε * betaCrit R ε r p f ≤ (1 + δ) * |cov p r f| := by
    rw [le_div_iff₀ hε] at hhigh
    linarith
  rw [abs_le]
  constructor <;> nlinarith

/-- **The sharp threshold (conjecture N2).**  As the audit tolerance `ε` decreases to
zero, the critical temperature `β_c(ε)` obeys `ε · β_c(ε) → |Cov_p(r, f)|`; that is,
`β_c(ε) = (1 + o(1)) |Cov_p(r,f)| / ε`.  Reward hacking of a statistic at tolerance `ε`
switches on exactly at the temperature dictated by its covariance with the reward. -/
theorem tendsto_eps_mul_betaCrit (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R)
    (hR0 : 0 < R) (hC : 0 < |cov p r f|) :
    Tendsto (fun ε => ε * betaCrit R ε r p f) (𝓝[>] 0) (𝓝 |cov p r f|) := by
  rw [Metric.tendsto_nhdsWithin_nhds]
  intro η hη
  set C : ℝ := |cov p r f| with hCdef
  set K : ℝ := hackRemainder R p f with hKdef
  have hK0 : 0 ≤ K := hackRemainder_nonneg R p f
  set d : ℝ := min (1 / 2) (η / (2 * C)) with hd
  have hd0 : 0 < d := by
    refine lt_min (by norm_num) ?_
    positivity
  have hd1 : d < 1 := lt_of_le_of_lt (min_le_left _ _) (by norm_num)
  have hdC : d * C ≤ η / 2 := by
    have : d ≤ η / (2 * C) := min_le_right _ _
    calc d * C ≤ (η / (2 * C)) * C := by nlinarith
      _ = η / 2 := by field_simp
  refine ⟨min ((1 - d) * C / R) (d * (1 - d) * C ^ 2 / (2 * K + 1)), ?_, ?_⟩
  · have h1d : 0 < 1 - d := by linarith
    refine lt_min (by positivity) ?_
    positivity
  · intro ε hεmem hεdist
    have hε : 0 < ε := hεmem
    have hεlt : ε < min ((1 - d) * C / R) (d * (1 - d) * C ^ 2 / (2 * K + 1)) := by
      rw [Real.dist_eq, sub_zero, abs_of_pos hε] at hεdist
      exact hεdist
    have h1d : 0 < 1 - d := by linarith
    have h1 : ε * R ≤ (1 - d) * C := by
      have := lt_of_lt_of_le hεlt (min_le_left _ _)
      rw [lt_div_iff₀ hR0] at this
      linarith
    have h2 : 2 * K * ε ≤ d * (1 - d) * C ^ 2 := by
      have hlt := lt_of_lt_of_le hεlt (min_le_right _ _)
      rw [lt_div_iff₀ (by positivity)] at hlt
      nlinarith
    have hbound := abs_eps_mul_betaCrit_sub_cov_le (f := f) hp hR hR0 hε hd0 hC h1 h2
    rw [Real.dist_eq]
    calc abs (ε * betaCrit R ε r p f - C) ≤ d * C := hbound
      _ ≤ η / 2 := hdC
      _ < η := by linarith

end Sharp

end RLHF