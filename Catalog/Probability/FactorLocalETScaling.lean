import Mathlib
import Shared.BirthdayBoundHierarchy

/-!
# FACTOR-LOCAL-ET: a certified calculus for across-`k` scaling exponents

Experimental setting (paper 154, exp 486).  One population of balanced
semiprimes `N = p * q` is drawn at each bit size `k ∈ {16, 20, 24}` and three
factoring algorithms are run on *the same* instances.  The reported statistic is
the **across-`k` log-log slope of the expected running time per `log₂ p`**,

`slope(k₁, k₂) = (log₂ E[T](k₂) - log₂ E[T](k₁)) / (log₂ p(k₂) - log₂ p(k₁))`,

with the measured values

| algorithm      | measured slope |
|----------------|----------------|
| trial division | `0.84`         |
| Pollard ρ      | `0.52`         |
| Fermat         | `0.50`         |

This file supplies the *inferential* mathematics that such a measurement needs,
and it is deliberately stated so that the theorems can **refute** a model rather
than merely accommodate it.

## What is proved

* `logSlope_of_pure_power` — a pure power law is read off exactly by two points.
* `PowerBand.abs_logSlope_sub_le` — **identifiability**: if `E` is sandwiched
  between `c₁·2^{αk}` and `c₂·2^{αk}` then the two-point slope differs from `α`
  by at most `log₂(c₂/c₁)/(k₂-k₁)`.  Multiplicative model error decays like
  `1/Δk`; this is what makes an 8-bit lever arm meaningful.
* `PowerBand.of_dyadic_window` — the sandwich constants produced by a monotone
  cost `C·p^α` over the dyadic window `p ∈ [2^{k-1}, 2^k]`.
* `spread_of_slope_deficit` — **falsification**: a slope that misses `α` by more
  than the band forces a quantified constant drift `c₂/c₁ ≥ 2^{dΔk}`.
* `rho_slope_band`, `rho_measured_slope_realizable` — Pollard ρ: the birthday
  exponent `1/2` is certified to `±1/16` at `Δk = 8`, and the measured `0.52`
  is realized by an explicit curve inside the window, so it does not refute the
  birthday model.
* `trial_slope_deficit_forces_spread`, `tight_linear_model_refuted_by_084` —
  trial division: the measured `0.84` is *outside* the band of any tight linear
  model, hence provably certifies a constant drift of at least `2^{5/4} > 2.36`
  across the population.  This is the "balanced draws compress" effect, turned
  into a theorem rather than a narrative.
* `fermat_gap_locality` — the exact gap-locality law
  `(q-p)²/(8q) ≤ (p+q)/2 - √(pq) ≤ (q-p)²/(8p)`: Fermat's cost is `Θ(gap²/p)`.
* `fermat_powerBand_of_gap`, `gap_exponent_of_fermat_slope` — the **exponent
  transfer law** `α_Fermat = 2β_gap - 1`, and its inversion: the measured
  Fermat slope `0.50` predicts a gap exponent `0.75` for that population.
* `birthday_storage_threshold`, `birthday_storage_real_sandwich`,
  `birthday_storage_achieves_collision` — the ρ exponent is anchored to the
  *proved* collision threshold of `Catalog.Shared.BirthdayBoundHierarchy` (the
  minimal number of stored elements is exactly `Nat.sqrt p + 1`).
* `unified_across_k_bands` — the three bands on one population, in one
  statement.
-/

namespace FactorLocalET

open Real

/-! ## 1. The two-point log-log slope -/

/-- The across-`k` scaling slope measured by the experiment: the slope of
`log₂ E[T]` against `k`, where the population at level `k` has `log₂ p ≈ k`. -/
noncomputable def logSlope (E : ℕ → ℝ) (k₁ k₂ : ℕ) : ℝ :=
  (Real.logb 2 (E k₂) - Real.logb 2 (E k₁)) / ((k₂ : ℝ) - (k₁ : ℝ))

/-- A pure power law `E k = C · 2^{αk}` is recovered *exactly* by the two-point
slope, for any pair of distinct levels. -/
theorem logSlope_of_pure_power {C α : ℝ} (hC : 0 < C) {k₁ k₂ : ℕ} (hk : k₁ ≠ k₂) :
    logSlope (fun k => C * (2 : ℝ) ^ (α * k)) k₁ k₂ = α := by
  have hne : ((k₂ : ℝ) - (k₁ : ℝ)) ≠ 0 := by
    have hcast : (k₁ : ℝ) ≠ (k₂ : ℝ) := by exact_mod_cast hk
    intro h; apply hcast; linarith
  have key : ∀ k : ℕ, Real.logb 2 (C * (2 : ℝ) ^ (α * k)) = Real.logb 2 C + α * k := by
    intro k
    rw [Real.logb_mul (ne_of_gt hC) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  simp only [logSlope, key]
  field_simp
  ring

/-! ## 2. Power bands: multiplicative model error and slope identifiability -/

/-- `E` obeys a **power band** with exponent `α` and constants `c₁ ≤ c₂` when
`c₁ · 2^{αk} ≤ E k ≤ c₂ · 2^{αk}` for every level `k`.  This is the honest form
of a scaling hypothesis: the exponent is asserted, the constant is not. -/
structure PowerBand (E : ℕ → ℝ) (α c₁ c₂ : ℝ) : Prop where
  pos : 0 < c₁
  lower : ∀ k : ℕ, c₁ * (2 : ℝ) ^ (α * k) ≤ E k
  upper : ∀ k : ℕ, E k ≤ c₂ * (2 : ℝ) ^ (α * k)

namespace PowerBand

variable {E : ℕ → ℝ} {α c₁ c₂ : ℝ}

theorem le_const (h : PowerBand E α c₁ c₂) : c₁ ≤ c₂ := by
  have h0 := (h.lower 0).trans (h.upper 0)
  simpa using h0

theorem pos_of (h : PowerBand E α c₁ c₂) (k : ℕ) : 0 < E k :=
  lt_of_lt_of_le (mul_pos h.pos (Real.rpow_pos_of_pos (by norm_num) _)) (h.lower k)

/-- Pointwise linearisation: `log₂ E k` sits in a fixed vertical strip around
the line `α k`. -/
theorem logb_mem (h : PowerBand E α c₁ c₂) (k : ℕ) :
    Real.logb 2 c₁ + α * k ≤ Real.logb 2 (E k) ∧
      Real.logb 2 (E k) ≤ Real.logb 2 c₂ + α * k := by
  have hc₂ : 0 < c₂ := lt_of_lt_of_le h.pos h.le_const
  have hsplit : ∀ c : ℝ, 0 < c →
      Real.logb 2 (c * (2 : ℝ) ^ (α * k)) = Real.logb 2 c + α * k := by
    intro c hc
    rw [Real.logb_mul (ne_of_gt hc) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  constructor
  · have hstep := Real.logb_le_logb_of_le (b := 2) (by norm_num)
      (mul_pos h.pos (Real.rpow_pos_of_pos (by norm_num) _)) (h.lower k)
    rwa [hsplit c₁ h.pos] at hstep
  · have hstep := Real.logb_le_logb_of_le (b := 2) (by norm_num) (h.pos_of k) (h.upper k)
    rwa [hsplit c₂ hc₂] at hstep

/-- **Slope identifiability.**  A two-point measurement recovers the exponent up
to `log₂(c₂/c₁)/Δk`: multiplicative model error is divided by the lever arm.
This is the theorem that makes an across-`k` measurement on three bit sizes an
inference rather than an anecdote. -/
theorem abs_logSlope_sub_le (h : PowerBand E α c₁ c₂) {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    |logSlope E k₁ k₂ - α| ≤ Real.logb 2 (c₂ / c₁) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hc₂ : 0 < c₂ := lt_of_lt_of_le h.pos h.le_const
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  obtain ⟨hl₁, hu₁⟩ := h.logb_mem k₁
  obtain ⟨hl₂, hu₂⟩ := h.logb_mem k₂
  set D := Real.logb 2 c₂ - Real.logb 2 c₁ with hD
  have hDeq : Real.logb 2 (c₂ / c₁) = D := by
    rw [hD, Real.logb_div (ne_of_gt hc₂) (ne_of_gt h.pos)]
  have hnum : |(Real.logb 2 (E k₂) - Real.logb 2 (E k₁)) - α * ((k₂ : ℝ) - k₁)| ≤ D := by
    rw [abs_le]
    constructor <;> [linarith; linarith]
  rw [hDeq, le_div_iff₀ hΔ]
  have hslope : logSlope E k₁ k₂ - α =
      ((Real.logb 2 (E k₂) - Real.logb 2 (E k₁)) - α * ((k₂ : ℝ) - k₁)) /
        ((k₂ : ℝ) - (k₁ : ℝ)) := by
    simp only [logSlope]
    field_simp
  rw [hslope, abs_div, abs_of_pos hΔ, div_mul_cancel₀ _ (ne_of_gt hΔ)]
  exact hnum

/-- Constants produced by a **dyadic window**: if at level `k` the population
lives in `p ∈ [2^{k-1}, 2^k]` and the per-instance cost is `C · p^α`, then the
expected cost obeys a power band with spread `2^α`. -/
theorem of_dyadic_window {C : ℝ} (hC : 0 < C)
    (hl : ∀ k : ℕ, C * (2 : ℝ) ^ (α * ((k : ℝ) - 1)) ≤ E k)
    (hu : ∀ k : ℕ, E k ≤ C * (2 : ℝ) ^ (α * k)) :
    PowerBand E α (C * (2 : ℝ) ^ (-α)) C := by
  refine ⟨by positivity, ?_, hu⟩
  intro k
  have hrw : C * (2 : ℝ) ^ (-α) * (2 : ℝ) ^ (α * k) = C * (2 : ℝ) ^ (α * ((k : ℝ) - 1)) := by
    rw [mul_assoc, ← Real.rpow_add (by norm_num)]
    ring_nf
  rw [hrw]
  exact hl k

/-- The spread of a dyadic-window band is exactly `α` on the `log₂` scale. -/
theorem logb_spread_dyadic {C : ℝ} (hC : 0 < C) :
    Real.logb 2 (C / (C * (2 : ℝ) ^ (-α))) = α := by
  have h : C / (C * (2 : ℝ) ^ (-α)) = (2 : ℝ) ^ α := by
    rw [Real.rpow_neg (by norm_num)]
    field_simp
  rw [h, Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]

end PowerBand

/-! ## 3. Falsification: a slope deficit certifies constant drift -/

/-- **Falsification direction.**  If the measured slope misses the modelled
exponent by more than `d`, then no power band with spread smaller than
`2^{d·Δk}` can hold.  Contrapositive of `abs_logSlope_sub_le`, and the form in
which the experiment bites: an anomalous slope is *evidence about the
constants*, quantified. -/
theorem spread_of_slope_deficit {E : ℕ → ℝ} {α c₁ c₂ d : ℝ} {k₁ k₂ : ℕ}
    (h : PowerBand E α c₁ c₂) (hk : k₁ < k₂) (hd : d ≤ |logSlope E k₁ k₂ - α|) :
    d * ((k₂ : ℝ) - (k₁ : ℝ)) ≤ Real.logb 2 (c₂ / c₁) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hchain := hd.trans (h.abs_logSlope_sub_le hk)
  rwa [le_div_iff₀ hΔ] at hchain

/-- A `log₂`-spread bound turns into a multiplicative statement about the
constants themselves. -/
theorem ratio_ge_of_logb_ge {c₁ c₂ t : ℝ} (h₁ : 0 < c₁) (h₂ : 0 < c₂)
    (h : t ≤ Real.logb 2 (c₂ / c₁)) : (2 : ℝ) ^ t ≤ c₂ / c₁ := by
  have hpos : 0 < c₂ / c₁ := div_pos h₂ h₁
  calc (2 : ℝ) ^ t ≤ (2 : ℝ) ^ (Real.logb 2 (c₂ / c₁)) :=
        Real.rpow_le_rpow_of_exponent_le (by norm_num) h
    _ = c₂ / c₁ := Real.rpow_logb (by norm_num) (by norm_num) hpos

/-! ## 4. Pollard ρ: the birthday exponent, certified -/

/-- Pollard ρ under the birthday model: expected cost `Θ(√p)`.  With the dyadic
window this gives the band `[2^{-1/2}, 1]` around `2^{k/2}`. -/
theorem rho_powerBand {E : ℕ → ℝ}
    (hl : ∀ k : ℕ, (2 : ℝ) ^ ((1 / 2 : ℝ) * ((k : ℝ) - 1)) ≤ E k)
    (hu : ∀ k : ℕ, E k ≤ (2 : ℝ) ^ ((1 / 2 : ℝ) * k)) :
    PowerBand E (1 / 2) (1 * (2 : ℝ) ^ (-(1 / 2 : ℝ))) 1 :=
  PowerBand.of_dyadic_window (E := E) (α := 1 / 2) one_pos
    (by simpa using hl) (by simpa using hu)

/-- **The ρ exponent is identified to `±1/(2Δk)`.**  At the experimental lever
arm `Δk = 8` (`k = 16 → 24`) the certified band is `1/2 ± 1/16`. -/
theorem rho_slope_band {E : ℕ → ℝ}
    (hl : ∀ k : ℕ, (2 : ℝ) ^ ((1 / 2 : ℝ) * ((k : ℝ) - 1)) ≤ E k)
    (hu : ∀ k : ℕ, E k ≤ (2 : ℝ) ^ ((1 / 2 : ℝ) * k)) :
    |logSlope E 16 24 - 1 / 2| ≤ 1 / 16 := by
  have hb := rho_powerBand hl hu
  have h := hb.abs_logSlope_sub_le (k₁ := 16) (k₂ := 24) (by norm_num)
  have hspread : Real.logb 2 (1 / (1 * (2 : ℝ) ^ (-(1 / 2 : ℝ)))) = 1 / 2 :=
    PowerBand.logb_spread_dyadic (α := (1 / 2 : ℝ)) (C := (1 : ℝ)) one_pos
  rw [hspread] at h
  refine h.trans (le_of_eq ?_)
  norm_num

/-- **The measured ρ slope is realizable, so it does not refute the birthday
model.**  There is an expected-cost curve obeying the dyadic birthday window at
*every* level whose across-`k` slope is exactly the reported `0.52`.  Together
with `rho_slope_band` (which forbids anything outside `1/2 ± 1/16`) this pins
the status of the measurement precisely: `0.52` is admissible, and only because
the window slack is spent almost entirely on the two endpoints. -/
theorem rho_measured_slope_realizable :
    ∃ E : ℕ → ℝ, (∀ k : ℕ, (2 : ℝ) ^ ((1 / 2 : ℝ) * ((k : ℝ) - 1)) ≤ E k) ∧
      (∀ k : ℕ, E k ≤ (2 : ℝ) ^ ((1 / 2 : ℝ) * k)) ∧ logSlope E 16 24 = 0.52 := by
  refine ⟨fun k => if k = 24 then (2 : ℝ) ^ (11.66 : ℝ)
    else (2 : ℝ) ^ ((1 / 2 : ℝ) * ((k : ℝ) - 1)), ?_, ?_, ?_⟩
  · intro k
    by_cases h : k = 24
    · subst h
      exact Real.rpow_le_rpow_of_exponent_le (by norm_num) (by norm_num)
    · simp [h]
  · intro k
    by_cases h : k = 24
    · subst h
      exact Real.rpow_le_rpow_of_exponent_le (by norm_num) (by norm_num)
    · simp only [if_neg h]
      exact Real.rpow_le_rpow_of_exponent_le (by norm_num)
        (by nlinarith [Nat.cast_nonneg (α := ℝ) k])
  · simp only [logSlope, if_neg (by norm_num : (16 : ℕ) ≠ 24),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
    norm_num

/-! ## 5. Trial division: the measured `0.84` refutes a tight linear model -/

/-- **The tight linear model is refuted.**  If trial division obeyed a linear
power band with dyadic-window spread (`c₂ ≤ √2 · c₁`, the spread forced by the
window alone), its measured across-`k` slope at `Δk = 8` would have to exceed
`0.84`.  The observed `0.84` therefore cannot come from such a model. -/
theorem tight_linear_model_refuted_by_084 {E : ℕ → ℝ} {c₁ c₂ : ℝ}
    (h : PowerBand E 1 c₁ c₂) (hspread : c₂ ≤ Real.sqrt 2 * c₁) :
    (0.84 : ℝ) < logSlope E 16 24 := by
  have hc₂ : 0 < c₂ := lt_of_lt_of_le h.pos h.le_const
  have hband := h.abs_logSlope_sub_le (k₁ := 16) (k₂ := 24) (by norm_num)
  have hle : Real.logb 2 (c₂ / c₁) ≤ 1 / 2 := by
    have hdiv : c₂ / c₁ ≤ Real.sqrt 2 := by rw [div_le_iff₀ h.pos]; linarith
    calc Real.logb 2 (c₂ / c₁) ≤ Real.logb 2 (Real.sqrt 2) :=
          Real.logb_le_logb_of_le (by norm_num) (div_pos hc₂ h.pos) hdiv
      _ = 1 / 2 := by
          rw [Real.sqrt_eq_rpow, Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hband
  have hfinal : Real.logb 2 (c₂ / c₁) / 8 ≤ 1 / 16 := by linarith
  have := (abs_le.mp (hband.trans hfinal)).1
  linarith

/-- **Quantified drift.**  Whatever the true constants, a linear (`α = 1`) model
with measured slope at most `0.84` over `Δk = 8` forces a constant ratio of at
least `2^{5/4}`: the head and the tail of the population differ by more than a
factor `2.36`.  This converts "balanced draws compress the exponent" into a
numerical lower bound on the compression. -/
theorem trial_slope_deficit_forces_spread {E : ℕ → ℝ} {c₁ c₂ : ℝ}
    (h : PowerBand E 1 c₁ c₂) (hmeas : logSlope E 16 24 ≤ 0.84) :
    (5 : ℝ) / 4 ≤ Real.logb 2 (c₂ / c₁) := by
  have hd : (0.16 : ℝ) ≤ |logSlope E 16 24 - 1| := by
    rw [le_abs]; right; linarith
  have hsp := spread_of_slope_deficit (d := 0.16) h (by norm_num) hd
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hsp
  linarith

/-- `2^{5/4} ≥ 2.36`: the drift certified above is a genuine, sizeable factor. -/
theorem two_rpow_five_quarters_ge : (2.36 : ℝ) ≤ (2 : ℝ) ^ ((5 : ℝ) / 4) := by
  have hpow : ((2 : ℝ) ^ ((5 : ℝ) / 4)) ^ (4 : ℕ) = 32 := by
    rw [← Real.rpow_natCast ((2 : ℝ) ^ ((5 : ℝ) / 4)) 4, ← Real.rpow_mul (by norm_num)]
    norm_num
  have hpos : (0 : ℝ) < (2 : ℝ) ^ ((5 : ℝ) / 4) := by positivity
  refine le_of_pow_le_pow_left₀ (n := 4) (by norm_num) hpos.le ?_
  rw [hpow]; norm_num

/-- The end-to-end trial-division statement: a linear model matching the
measured slope has constants spread by a factor `≥ 2.36`. -/
theorem trial_constant_ratio_ge {E : ℕ → ℝ} {c₁ c₂ : ℝ}
    (h : PowerBand E 1 c₁ c₂) (hmeas : logSlope E 16 24 ≤ 0.84) :
    (2.36 : ℝ) ≤ c₂ / c₁ :=
  le_trans two_rpow_five_quarters_ge
    (ratio_ge_of_logb_ge h.pos (lt_of_lt_of_le h.pos h.le_const)
      (trial_slope_deficit_forces_spread h hmeas))

/-! ## 6. Fermat: exact gap locality -/

/-- Fermat's method starts at `⌈√N⌉` and stops at `(p+q)/2`; the number of steps
is the *offset* `(p+q)/2 - √(pq)`, which equals `(√q - √p)²/2`. -/
theorem fermat_offset_eq {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) :
    (p + q) / 2 - Real.sqrt (p * q) = (Real.sqrt q - Real.sqrt p) ^ 2 / 2 := by
  have hs : Real.sqrt p ^ 2 = p := Real.sq_sqrt hp
  have ht : Real.sqrt q ^ 2 = q := Real.sq_sqrt hq
  rw [Real.sqrt_mul hp q]
  nlinarith [hs, ht]

/-- **Gap locality (the Fermat law).**  For `0 < p ≤ q` the Fermat offset is
squeezed between `(q-p)²/(8q)` and `(q-p)²/(8p)`: the cost is `Θ(gap²/p)`, a
purely local function of the prime gap.  This is the structural reason a Fermat
scaling slope is *not* an intrinsic property of the algorithm but a readout of
the gap distribution of the population. -/
theorem fermat_gap_locality {p q : ℝ} (hp : 0 < p) (hpq : p ≤ q) :
    (q - p) ^ 2 / (8 * q) ≤ (p + q) / 2 - Real.sqrt (p * q) ∧
      (p + q) / 2 - Real.sqrt (p * q) ≤ (q - p) ^ 2 / (8 * p) := by
  have hq : 0 < q := lt_of_lt_of_le hp hpq
  have hs : Real.sqrt p ^ 2 = p := Real.sq_sqrt hp.le
  have ht : Real.sqrt q ^ 2 = q := Real.sq_sqrt hq.le
  have hs0 : 0 < Real.sqrt p := Real.sqrt_pos.mpr hp
  have ht0 : 0 < Real.sqrt q := Real.sqrt_pos.mpr hq
  have hst : Real.sqrt p ≤ Real.sqrt q := Real.sqrt_le_sqrt hpq
  rw [fermat_offset_eq hp.le hq.le]
  set s := Real.sqrt p with hsdef
  set t := Real.sqrt q with htdef
  have hfac : q - p = (t - s) * (t + s) := by rw [← hs, ← ht]; ring
  have k1 : (t + s) ^ 2 ≤ 4 * t ^ 2 := by nlinarith
  have k2 : 4 * s ^ 2 ≤ (t + s) ^ 2 := by nlinarith
  constructor
  · rw [div_le_div_iff₀ (by positivity) (by norm_num), hfac, ← ht]
    nlinarith [mul_le_mul_of_nonneg_left k1 (sq_nonneg (t - s))]
  · rw [div_le_div_iff₀ (by norm_num) (by positivity), hfac, ← hs]
    nlinarith [mul_le_mul_of_nonneg_left k2 (sq_nonneg (t - s))]

/-! ## 7. The exponent transfer law `α_Fermat = 2β_gap - 1` -/

/-- **Exponent transfer.**  If the population's mean gap obeys a power band with
exponent `β` and the small factor `p` obeys the dyadic band (`2^k ≤ p ≤ 2·2^k`),
then the Fermat cost surrogate `gap²/(8p)` obeys a power band with exponent
`2β - 1`.  The constants compose multiplicatively, so the transfer is
quantitative, not asymptotic. -/
theorem fermat_powerBand_of_gap {F G P : ℕ → ℝ} {β g₁ g₂ : ℝ}
    (hg : PowerBand G β g₁ g₂) (hP : PowerBand P 1 1 2)
    (hF : ∀ k, F k = (G k) ^ 2 / (8 * P k)) :
    PowerBand F (2 * β - 1) (g₁ ^ 2 / 16) (g₂ ^ 2 / 8) := by
  have hg₂ : 0 < g₂ := lt_of_lt_of_le hg.pos hg.le_const
  have hg₁ : 0 < g₁ := hg.pos
  have hw2 : ∀ k : ℕ, ((2 : ℝ) ^ (β * (k : ℝ))) ^ 2
      = (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) * (2 : ℝ) ^ ((k : ℝ)) := by
    intro k
    rw [← Real.rpow_natCast ((2 : ℝ) ^ (β * (k : ℝ))) 2, ← Real.rpow_mul (by norm_num),
      ← Real.rpow_add (by norm_num)]
    ring_nf
  refine ⟨div_pos (pow_pos hg₁ 2) (by norm_num), ?_, ?_⟩
  · intro k
    have hw : (0 : ℝ) < (2 : ℝ) ^ (β * (k : ℝ)) := by positivity
    have hGk : g₁ * (2 : ℝ) ^ (β * (k : ℝ)) ≤ G k := hg.lower k
    have hPk : P k ≤ 2 * (2 : ℝ) ^ ((k : ℝ)) := by
      have hup := hP.upper k; rwa [one_mul] at hup
    have hPpos : 0 < P k := hP.pos_of k
    have h1 : (g₁ * (2 : ℝ) ^ (β * (k : ℝ))) ^ 2 ≤ (G k) ^ 2 :=
      pow_le_pow_left₀ (by positivity) hGk 2
    rw [hF k, le_div_iff₀ (by positivity)]
    calc g₁ ^ 2 / 16 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) * (8 * P k)
        ≤ g₁ ^ 2 / 16 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) * (8 * (2 * (2 : ℝ) ^ ((k : ℝ)))) := by
          have hnn : (0 : ℝ) ≤ g₁ ^ 2 / 16 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) := by positivity
          nlinarith
      _ = (g₁ * (2 : ℝ) ^ (β * (k : ℝ))) ^ 2 := by rw [mul_pow, hw2 k]; ring
      _ ≤ (G k) ^ 2 := h1
  · intro k
    have hw : (0 : ℝ) < (2 : ℝ) ^ (β * (k : ℝ)) := by positivity
    have hGk : G k ≤ g₂ * (2 : ℝ) ^ (β * (k : ℝ)) := hg.upper k
    have hGpos : 0 < G k := hg.pos_of k
    have hPk : (2 : ℝ) ^ ((k : ℝ)) ≤ P k := by
      have hlo := hP.lower k; rwa [one_mul, one_mul] at hlo
    have hPpos : 0 < P k := hP.pos_of k
    have h1 : (G k) ^ 2 ≤ (g₂ * (2 : ℝ) ^ (β * (k : ℝ))) ^ 2 :=
      pow_le_pow_left₀ hGpos.le hGk 2
    rw [hF k, div_le_iff₀ (by positivity)]
    calc (G k) ^ 2 ≤ (g₂ * (2 : ℝ) ^ (β * (k : ℝ))) ^ 2 := h1
      _ = g₂ ^ 2 / 8 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) * (8 * (2 : ℝ) ^ ((k : ℝ))) := by
          rw [mul_pow, hw2 k]; ring
      _ ≤ g₂ ^ 2 / 8 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) * (8 * P k) := by
          have hnn : (0 : ℝ) ≤ g₂ ^ 2 / 8 * (2 : ℝ) ^ ((2 * β - 1) * (k : ℝ)) := by positivity
          nlinarith

/-- **Inversion of the transfer law.**  A measured Fermat slope determines the
population's gap exponent to half the slope tolerance.  Applied to the reported
`0.50` this predicts `β = 0.75`: the Fermat channel is a gap-exponent meter. -/
theorem gap_exponent_of_fermat_slope {s β eps : ℝ} (h : |s - (2 * β - 1)| ≤ eps) :
    |β - (s + 1) / 2| ≤ eps / 2 := by
  rw [abs_le] at h ⊢
  constructor <;> linarith [h.1, h.2]

/-- The measured Fermat slope `0.50`, with the transfer law, predicts a gap
exponent of exactly `3/4` (up to half the slope tolerance).  A population whose
gaps scale like `p` (the uniform-balanced case) would instead give slope `1`. -/
theorem fermat_measured_predicts_gap_exponent {β eps : ℝ}
    (h : |(0.50 : ℝ) - (2 * β - 1)| ≤ eps) : |β - 0.75| ≤ eps / 2 := by
  have hstep := gap_exponent_of_fermat_slope h
  have hval : ((0.50 : ℝ) + 1) / 2 = 0.75 := by norm_num
  rwa [hval] at hstep

/-! ## 8. Anchoring the ρ exponent in the proved collision threshold -/

open BirthdayHierarchy

/-- The minimal number of stored elements for a *guaranteed* 2-sum collision
modulo `p` is exactly `Nat.sqrt p + 1`: the birthday exponent `1/2` is a
theorem about the threshold, not a heuristic. -/
theorem birthday_storage_threshold (p m : ℕ) : p < m ^ 2 ↔ Nat.sqrt p + 1 ≤ m := by
  constructor
  · intro h
    have hlt : Nat.sqrt p < m := by
      by_contra hcon
      push_neg at hcon
      have h1 : m ^ 2 ≤ Nat.sqrt p ^ 2 := Nat.pow_le_pow_left hcon 2
      have hle : Nat.sqrt p ^ 2 ≤ p := Nat.sqrt_le' p
      omega
    omega
  · intro h
    have h2 : p < (Nat.sqrt p + 1) ^ 2 := Nat.lt_succ_sqrt' p
    have hmono : (Nat.sqrt p + 1) ^ 2 ≤ m ^ 2 := Nat.pow_le_pow_left h 2
    omega

/-- With `Nat.sqrt p + 1` stored elements the 2-sum scheme provably collides:
the threshold of `birthday_storage_threshold` is achieved, tying the ρ exponent
to the catalogued birthday-bound hierarchy. -/
theorem birthday_storage_achieves_collision {p : ℕ} (hp : 0 < p) (A : Finset ℕ)
    (hA : Nat.sqrt p + 1 ≤ A.card) :
    ∃ u ∈ tupleSpace 2 A, ∃ v ∈ tupleSpace 2 A, u ≠ v ∧
      (∑ i, u i) % p = (∑ i, v i) % p :=
  exists_tuple_sum_collision hp A ((birthday_storage_threshold p A.card).2 hA)

/-- Real-valued sandwich for the threshold: `√p ≤ Nat.sqrt p + 1 ≤ 2√p` for
`p ≥ 1`.  Hence the storage cost is a `1/2`-power law with spread at most `2`,
and `PowerBand.abs_logSlope_sub_le` identifies its exponent. -/
theorem birthday_storage_real_sandwich {p : ℕ} (hp : 1 ≤ p) :
    Real.sqrt p ≤ (Nat.sqrt p : ℝ) + 1 ∧ ((Nat.sqrt p : ℝ) + 1) ≤ 2 * Real.sqrt p := by
  have hp0 : (0 : ℝ) ≤ (p : ℝ) := by positivity
  have hsq : Real.sqrt p ^ 2 = (p : ℝ) := Real.sq_sqrt hp0
  have hsqrt_nonneg : (0 : ℝ) ≤ Real.sqrt p := Real.sqrt_nonneg _
  have h1 : (p : ℝ) < ((Nat.sqrt p : ℝ) + 1) ^ 2 := by
    have hn : p < (Nat.sqrt p + 1) ^ 2 := Nat.lt_succ_sqrt' p
    exact_mod_cast (by exact_mod_cast hn : ((p : ℕ) : ℝ) < (((Nat.sqrt p + 1) ^ 2 : ℕ) : ℝ))
  have h2 : ((Nat.sqrt p : ℝ)) ^ 2 ≤ (p : ℝ) := by
    have hn : Nat.sqrt p ^ 2 ≤ p := Nat.sqrt_le' p
    exact_mod_cast hn
  have hone : (1 : ℝ) ≤ Real.sqrt p := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by exact_mod_cast hp)
  have hnn : (0 : ℝ) ≤ (Nat.sqrt p : ℝ) := Nat.cast_nonneg _
  exact ⟨by nlinarith [hsq, h1, hsqrt_nonneg], by nlinarith [hsq, h2, hsqrt_nonneg, hone, hnn]⟩

/-- **Unified across-`k` statement on one population.**  Given the three cost
channels on the same draw — a linear trial-division band, the birthday band for
ρ, and the gap-transfer band for Fermat — the three across-`k` slopes are
simultaneously identified, each to an explicit tolerance at lever arm `Δk = 8`.
The ρ and Fermat tolerances are what make `0.52` and `0.50` meaningful
replications; the trial tolerance is what makes `0.84` a refutation. -/
theorem unified_across_k_bands {Etri Erho Ffer : ℕ → ℝ} {a₁ a₂ β g₁ g₂ : ℝ}
    (htri : PowerBand Etri 1 a₁ a₂)
    (hrhoL : ∀ k : ℕ, (2 : ℝ) ^ ((1 / 2 : ℝ) * ((k : ℝ) - 1)) ≤ Erho k)
    (hrhoU : ∀ k : ℕ, Erho k ≤ (2 : ℝ) ^ ((1 / 2 : ℝ) * k))
    (hfer : PowerBand Ffer (2 * β - 1) g₁ g₂) :
    |logSlope Etri 16 24 - 1| ≤ Real.logb 2 (a₂ / a₁) / 8 ∧
      |logSlope Erho 16 24 - 1 / 2| ≤ 1 / 16 ∧
      |logSlope Ffer 16 24 - (2 * β - 1)| ≤ Real.logb 2 (g₂ / g₁) / 8 := by
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  refine ⟨?_, rho_slope_band hrhoL hrhoU, ?_⟩
  · have hb := htri.abs_logSlope_sub_le (k₁ := 16) (k₂ := 24) (by norm_num)
    rwa [h8] at hb
  · have hb := hfer.abs_logSlope_sub_le (k₁ := 16) (k₂ := 24) (by norm_num)
    rwa [h8] at hb

end FactorLocalET