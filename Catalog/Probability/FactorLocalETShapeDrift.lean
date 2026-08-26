import Mathlib
import Probability.FactorLocalETTruncation

/-!
# FACTOR-LOCAL-ET, cycle 7: the shape-drift identity

Cycle 6 closed two doors on the reported trial-division slope `0.84`:

* cost truncation `min(p, B·2^k)` can never manufacture a deficit past `1/8`
  (`truncation_cannot_explain_084`), and
* a *scale-invariant* population `p_k(i) = 2^k · u(i)` gives measured slope
  exactly `s` for the pointwise cost `a·p^s`, with no tolerance at all
  (`scale_invariant_slope_eq_pow`).

Direction C4 of the previous cycle therefore conjectured that whatever produces
the compression must be a `k`-dependence of the *normalised* factor
distribution `u_k = p_k / 2^k`, and that the relation between the deficit and
the drift of the normalised means is an **identity**, not a bound.  This file
proves that conjecture and works out its consequences.

## Main results

* `shape_cost_eq` — for a population written in normalised form
  `p_k(i) = 2^k · u_k(i)` the expected pointwise power cost factorises exactly:
  `E k = (a · M_s(k)) · 2^{sk}` where `M_s(k) = mean (u_k)^s` is the normalised
  `s`-th moment ("the shape").
* `shape_drift_identity` — **the identity**:
  `slope = s + log₂(M_s(k₂)/M_s(k₁))/Δk`, and equivalently
  `s − slope = log₂(M_s(k₁)/M_s(k₂))/Δk` (`shape_drift_deficit`).  No
  hypothesis on the window is needed; the implementation constant `a` cancels.
* `compression_iff_shape_decrease` — hence the measured exponent is compressed
  (`slope < s`) **iff** the normalised moment strictly decreases across the
  lever arm, and is inflated iff it increases.  Compression is *equivalent* to
  shape drift; it is not merely explained by it.
* `shape_ratio_of_slope` — inverting the identity: a measured deficit `d` over
  lever arm `Δk` pins the drift exactly, `M_s(k₁)/M_s(k₂) = 2^{d·Δk}`.
* `trial_084_forces_shape_ratio` / `trial_084_forces_shape_ratio_ge` — at the
  experimental configuration (`s = 1`, `k = 16 → 24`) the reported `0.84`
  forces `M_1(16)/M_1(24) = 2^{1.28} ≥ 2.36`, the numerical prediction of C4.
* `dyadic_shape_ratio_le_two`, `dyadic_slope_ge` — a *dyadic* sampler cannot
  drift that far: its normalised means live in `[1/2, 1]`, so the ratio is at
  most `2 < 2^{1.28}` and the slope is at least `0.875`.  The measurement
  therefore also refutes the dyadic window itself, independently of the cost
  truncation route.
* `drift_realizes_084` — the mechanism is nonetheless *sufficient*: an explicit
  drifting sampler `u_k ≡ 2^{-0.16k}` realises the slope `0.84` exactly, and
  its shape ratio is the predicted `2^{1.28}`.  So C4's mechanism is consistent,
  and the identity turns the reported number into a falsifiable, directly
  measurable statement about the round-41 draws.
-/

namespace FactorLocalET

open Real

/-! ## 1. Normalised populations and their shape moments -/

/-- The **shape moment** of a normalised population: `M_s(k) = mean (u_k)^s`,
where `u_k(i) = p_k(i)/2^k` is the level-`k` population rescaled to the unit
window.  For a scale-invariant sampler this is independent of `k`. -/
noncomputable def shapeMean {n : ℕ} (u : ℕ → Fin n → ℝ) (s : ℝ) (k : ℕ) : ℝ :=
  mean fun i => (u k i) ^ s

theorem shapeMean_pos {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) (s : ℝ) (k : ℕ) : 0 < shapeMean u s k :=
  mean_pos hn fun i => Real.rpow_pos_of_pos (hu k i) s

/-- **Exact factorisation of the expected cost.**  A pointwise power cost on a
population in normalised form separates into the pure power `2^{sk}` and the
shape moment; nothing is lost or approximated. -/
theorem shape_cost_eq {n : ℕ} {u : ℕ → Fin n → ℝ} (hu : ∀ k i, 0 < u k i) {a s : ℝ}
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
    (k : ℕ) : E k = (a * shapeMean u s k) * (2 : ℝ) ^ (s * (k : ℝ)) := by
  have hsplit : ∀ i, ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s
      = (2 : ℝ) ^ (s * (k : ℝ)) * (u k i) ^ s := by
    intro i
    rw [Real.mul_rpow (Real.rpow_pos_of_pos (by norm_num) _).le (hu k i).le,
      ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2), mul_comm (k : ℝ) s]
  have hmean : (mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
      = (2 : ℝ) ^ (s * (k : ℝ)) * shapeMean u s k := by
    simp only [mean, shapeMean, hsplit, ← Finset.mul_sum]
    ring
  rw [hE k, hmean]; ring

/-! ## 2. The identity -/

/-- **The shape-drift identity.**  For a pointwise power cost `a·p^s` on a
population written in normalised form, the measured two-point slope is the cost
exponent plus the log-drift of the shape moment, divided by the lever arm:

`slope(k₁,k₂) = s + log₂(M_s(k₂)/M_s(k₁)) / (k₂ − k₁)`.

This is an *equality*: the implementation constant `a` cancels and no window
hypothesis is used.  Every deviation of a measured exponent from its cost
exponent is exactly the sampler's shape drift. -/
theorem shape_drift_identity {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a s : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    logSlope E k₁ k₂
      = s + Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hlog : ∀ k : ℕ, Real.logb 2 (E k)
      = Real.logb 2 (a * shapeMean u s k) + s * (k : ℝ) := by
    intro k
    have hM : 0 < a * shapeMean u s k := mul_pos ha (shapeMean_pos hn hu s k)
    rw [shape_cost_eq hu hE k, Real.logb_mul (ne_of_gt hM) (by positivity),
      Real.logb_rpow (b := 2) (by norm_num) (by norm_num)]
  have hdiff : Real.logb 2 (a * shapeMean u s k₂) - Real.logb 2 (a * shapeMean u s k₁)
      = Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) := by
    have h₁ : 0 < a * shapeMean u s k₁ := mul_pos ha (shapeMean_pos hn hu s k₁)
    have h₂ : 0 < a * shapeMean u s k₂ := mul_pos ha (shapeMean_pos hn hu s k₂)
    rw [← Real.logb_div (ne_of_gt h₂) (ne_of_gt h₁)]
    congr 1
    field_simp
  simp only [logSlope, hlog]
  rw [← hdiff]
  field_simp
  ring

/-- The identity in deficit form: the *shortfall* of the measured exponent
below the cost exponent is the log-decay of the shape moment per bit. -/
theorem shape_drift_deficit {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a s : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    s - logSlope E k₁ k₂
      = Real.logb 2 (shapeMean u s k₁ / shapeMean u s k₂) / ((k₂ : ℝ) - (k₁ : ℝ)) := by
  have h₁ : 0 < shapeMean u s k₁ := shapeMean_pos hn hu s k₁
  have h₂ : 0 < shapeMean u s k₂ := shapeMean_pos hn hu s k₂
  have hswap : Real.logb 2 (shapeMean u s k₁ / shapeMean u s k₂)
      = -Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) := by
    rw [Real.logb_div (ne_of_gt h₁) (ne_of_gt h₂),
      Real.logb_div (ne_of_gt h₂) (ne_of_gt h₁)]
    ring
  rw [shape_drift_identity hn hu ha hE hk, hswap]
  ring

/-- **Compression is exactly shape decay.**  The measured exponent falls below
the cost exponent iff the normalised moment strictly decreases across the lever
arm.  (In particular a scale-invariant sampler, for which the moment is
constant, cannot compress — recovering `scale_invariant_slope_eq_pow`.) -/
theorem compression_iff_shape_decrease {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a s : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) :
    logSlope E k₁ k₂ < s ↔ shapeMean u s k₂ < shapeMean u s k₁ := by
  have h₁ : 0 < shapeMean u s k₁ := shapeMean_pos hn hu s k₁
  have h₂ : 0 < shapeMean u s k₂ := shapeMean_pos hn hu s k₂
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  rw [shape_drift_identity hn hu ha hE hk]
  constructor
  · intro h
    have hneg : Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) < 0 := by
      by_contra hcon
      push_neg at hcon
      have : (0 : ℝ) ≤ Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) /
          ((k₂ : ℝ) - (k₁ : ℝ)) := div_nonneg hcon hΔ.le
      linarith
    have hlt : shapeMean u s k₂ / shapeMean u s k₁ < 1 := by
      by_contra hcon
      push_neg at hcon
      have : (0 : ℝ) ≤ Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) :=
        Real.logb_nonneg (by norm_num) hcon
      linarith
    rw [div_lt_one h₁] at hlt
    exact hlt
  · intro h
    have hlt : shapeMean u s k₂ / shapeMean u s k₁ < 1 := (div_lt_one h₁).mpr h
    have hneg : Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) < 0 :=
      Real.logb_neg (by norm_num) (div_pos h₂ h₁) hlt
    have : Real.logb 2 (shapeMean u s k₂ / shapeMean u s k₁) /
        ((k₂ : ℝ) - (k₁ : ℝ)) < 0 := div_neg_of_neg_of_pos hneg hΔ
    linarith

/-! ## 3. Inverting the identity: a measured deficit pins the drift -/

/-- **The drift is determined by the measurement.**  If the measured deficit is
`d` over lever arm `Δk`, the shape moment must have dropped by exactly the
factor `2^{d·Δk}`. -/
theorem shape_ratio_of_slope {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a s d : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ s)
    {k₁ k₂ : ℕ} (hk : k₁ < k₂) (hd : logSlope E k₁ k₂ = s - d) :
    shapeMean u s k₁ / shapeMean u s k₂ = (2 : ℝ) ^ (d * ((k₂ : ℝ) - (k₁ : ℝ))) := by
  have h₁ : 0 < shapeMean u s k₁ := shapeMean_pos hn hu s k₁
  have h₂ : 0 < shapeMean u s k₂ := shapeMean_pos hn hu s k₂
  have hΔ : (0 : ℝ) < (k₂ : ℝ) - (k₁ : ℝ) := by
    have hcast : (k₁ : ℝ) < (k₂ : ℝ) := by exact_mod_cast hk
    linarith
  have hid := shape_drift_deficit hn hu ha hE hk
  rw [hd] at hid
  have hlogb : Real.logb 2 (shapeMean u s k₁ / shapeMean u s k₂)
      = d * ((k₂ : ℝ) - (k₁ : ℝ)) := by
    field_simp at hid
    linarith [hid]
  have := Real.rpow_logb (b := 2) (x := shapeMean u s k₁ / shapeMean u s k₂)
    (by norm_num) (by norm_num) (div_pos h₁ h₂)
  rw [hlogb] at this
  exact this.symm

/-- `2^{1.28} ≥ 2.36`: the numerical form of the drift predicted by the
reported trial-division slope. -/
theorem two_rpow_128_ge : (2.36 : ℝ) ≤ (2 : ℝ) ^ (1.28 : ℝ) := by
  have key : (2.36 : ℝ) ^ (25 : ℝ) ≤ (2 : ℝ) ^ (32 : ℝ) := by
    rw [show (25 : ℝ) = ((25 : ℕ) : ℝ) by norm_num,
      show (32 : ℝ) = ((32 : ℕ) : ℝ) by norm_num,
      Real.rpow_natCast, Real.rpow_natCast]
    norm_num
  have h := Real.rpow_le_rpow (by positivity) key (by norm_num : (0 : ℝ) ≤ 1 / 25)
  rw [← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2.36),
    ← Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2)] at h
  norm_num at h ⊢
  exact h

/-- **The experimental prediction of direction C4.**  For a linear trial-division
cost (`s = 1`) at the experimental lever arm `k = 16 → 24`, the reported slope
`0.84` forces the normalised mean to drop by exactly `2^{1.28}`. -/
theorem trial_084_forces_shape_ratio {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ (1 : ℝ))
    (hslope : logSlope E 16 24 = 0.84) :
    shapeMean u 1 16 / shapeMean u 1 24 = (2 : ℝ) ^ (1.28 : ℝ) := by
  have hd : logSlope E 16 24 = 1 - 0.16 := by rw [hslope]; norm_num
  have h := shape_ratio_of_slope hn hu ha hE (k₁ := 16) (k₂ := 24) (by norm_num) hd
  rw [h]
  norm_num

/-- The same statement in the form C4 states it: the drift factor is at least
`2.36`. -/
theorem trial_084_forces_shape_ratio_ge {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hu : ∀ k i, 0 < u k i) {a : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ (1 : ℝ))
    (hslope : logSlope E 16 24 = 0.84) :
    (2.36 : ℝ) ≤ shapeMean u 1 16 / shapeMean u 1 24 := by
  rw [trial_084_forces_shape_ratio hn hu ha hE hslope]
  exact two_rpow_128_ge

/-! ## 4. A dyadic sampler cannot drift that far -/

/-- On a dyadic population the normalised means are confined to `[1/2, 1]`, so
the shape ratio across any two levels is at most `2`. -/
theorem dyadic_shape_ratio_le_two {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hlo : ∀ k i, (1 : ℝ) / 2 ≤ u k i) (hhi : ∀ k i, u k i ≤ 1) (k₁ k₂ : ℕ) :
    shapeMean u 1 k₁ / shapeMean u 1 k₂ ≤ 2 := by
  have hrw : ∀ k : ℕ, shapeMean u 1 k = mean fun i => u k i := by
    intro k
    simp [shapeMean, Real.rpow_one]
  have hup : shapeMean u 1 k₁ ≤ 1 := by
    rw [hrw]; exact mean_le hn fun i => hhi k₁ i
  have hlow : (1 : ℝ) / 2 ≤ shapeMean u 1 k₂ := by
    rw [hrw]; exact le_mean hn fun i => hlo k₂ i
  rw [div_le_iff₀ (by linarith)]
  linarith

/-- **The dyadic window is refuted too.**  A linear cost on a dyadic population
(`p_k ∈ [2^{k-1}, 2^k]`, i.e. normalised draws in `[1/2, 1]`) has across-`k`
slope at least `0.875` at the experimental lever arm — the shape drift it can
support, a factor `2`, is short of the `2^{1.28}` the measurement demands. -/
theorem dyadic_slope_ge {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hlo : ∀ k i, (1 : ℝ) / 2 ≤ u k i) (hhi : ∀ k i, u k i ≤ 1) {a : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ (1 : ℝ)) :
    (0.875 : ℝ) ≤ logSlope E 16 24 := by
  have hu : ∀ k i, 0 < u k i := fun k i => lt_of_lt_of_le (by norm_num) (hlo k i)
  have hid := shape_drift_deficit hn hu ha hE (k₁ := 16) (k₂ := 24) (by norm_num)
  have hratio : Real.logb 2 (shapeMean u 1 16 / shapeMean u 1 24) ≤ 1 := by
    have hpos : 0 < shapeMean u 1 16 / shapeMean u 1 24 :=
      div_pos (shapeMean_pos hn hu 1 16) (shapeMean_pos hn hu 1 24)
    have := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos
      (dyadic_shape_ratio_le_two hn hlo hhi 16 24)
    simpa using this
  have h8 : ((24 : ℕ) : ℝ) - ((16 : ℕ) : ℝ) = 8 := by norm_num
  rw [h8] at hid
  have : 1 - logSlope E 16 24 ≤ 1 / 8 := by
    rw [hid]; linarith
  linarith

/-- Consequently no dyadic sampler with a linear cost reproduces `0.84`. -/
theorem dyadic_cannot_explain_084 {n : ℕ} (hn : 0 < n) {u : ℕ → Fin n → ℝ}
    (hlo : ∀ k i, (1 : ℝ) / 2 ≤ u k i) (hhi : ∀ k i, u k i ≤ 1) {a : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ} (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * u k i) ^ (1 : ℝ)) :
    logSlope E 16 24 ≠ 0.84 := by
  intro h
  have := dyadic_slope_ge hn hlo hhi ha hE
  rw [h] at this
  norm_num at this

/-! ## 5. Drift is sufficient: an explicit sampler realising `0.84` -/

/-- The drifting sampler of direction C4: at level `k` every normalised draw is
`2^{-0.16k}`, i.e. the factor `p` is `2^{0.84k}` rather than filling the dyadic
window. -/
noncomputable def driftShape (n : ℕ) : ℕ → Fin n → ℝ :=
  fun k _ => (2 : ℝ) ^ (-(0.16 : ℝ) * (k : ℝ))

theorem driftShape_pos {n : ℕ} (k : ℕ) (i : Fin n) : 0 < driftShape n k i :=
  Real.rpow_pos_of_pos (by norm_num) _

theorem driftShape_shapeMean {n : ℕ} (hn : 0 < n) (k : ℕ) :
    shapeMean (driftShape n) 1 k = (2 : ℝ) ^ (-(0.16 : ℝ) * (k : ℝ)) := by
  simp only [shapeMean, driftShape, Real.rpow_one]
  exact mean_const hn _

/-- **Shape drift is a sufficient mechanism.**  The sampler `driftShape`
realises the reported trial-division slope `0.84` exactly, under the plain
linear cost `a·p` — so the reported number is consistent with a drifting
normalised distribution, while (cycle 6) it is inconsistent with cost
truncation and with any scale-invariant draw. -/
theorem drift_realizes_084 {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a)
    {E : ℕ → ℝ}
    (hE : ∀ k, E k = a * mean fun i => ((2 : ℝ) ^ (k : ℝ) * driftShape n k i) ^ (1 : ℝ)) :
    logSlope E 16 24 = 0.84 := by
  have hpure : E = fun k => a * (2 : ℝ) ^ ((0.84 : ℝ) * (k : ℕ)) := by
    funext k
    have hval : ∀ i : Fin n, ((2 : ℝ) ^ (k : ℝ) * driftShape n k i) ^ (1 : ℝ)
        = (2 : ℝ) ^ ((0.84 : ℝ) * (k : ℝ)) := by
      intro i
      simp only [driftShape, Real.rpow_one]
      rw [← Real.rpow_add (by norm_num)]
      ring_nf
    rw [hE k]
    simp only [hval]
    rw [mean_const hn]
  rw [hpure]
  exact logSlope_of_pure_power (C := a) (α := 0.84) ha (by norm_num)

/-- And its shape ratio is exactly the predicted `2^{1.28}`, in agreement with
`trial_084_forces_shape_ratio`: the identity is consistent and the witness
saturates it. -/
theorem drift_shape_ratio {n : ℕ} (hn : 0 < n) :
    shapeMean (driftShape n) 1 16 / shapeMean (driftShape n) 1 24
      = (2 : ℝ) ^ (1.28 : ℝ) := by
  rw [driftShape_shapeMean hn, driftShape_shapeMean hn,
    ← Real.rpow_sub (by norm_num)]
  norm_num

end FactorLocalET