import Mathlib

/-!
# The U80 rung: rapidity geometry of a confidence interval, and the resolution floor

## Research context (FACT round-66 #1, exp 534, `TDIAL-U80` / `U80-DIAL-HOLDS-COUNT-PARITY`)

The recorded measurement is the highest-bitlen *uniform* rung of the `T`-dial ladder: the
Spearman rank correlation between the trailing-zero statistic `T` of a uniformly drawn
integer of bitlen 80 and a downstream `rate`.

```
seed      20261180  20261181  20261182   pooled     CI
rho_T     0.562     0.551     0.582      0.565      [0.542, 0.587]
```

* all three seeds sit inside the pre-registered validation band `[0.55, 0.85]`, but seed
  `20261181` clears the floor `0.55` by only `+0.001`;
* every reported interval dips below `0.55` at its lower end;
* the H2 count-parity advantage of `T` over the plain popcount baseline persists:
  pooled `+0.053`, CI `[0.030, 0.083]` (so the baseline reads `0.512`);
* the next cell, bitlen 84, is the announced crossing test.

Reproduction: `ResearchOutput/scripts/2026-08-21-resume/exp534_t_dial_unif_80.py`,
`exp534_result.json`, seeds `20261180`–`20261182`.

## What the existing catalog cannot say

Companion files analyse the pooled number against *tie* geometry
(`Novelty.ZeroFitDialU64`: the attenuation law and the dyadic ceiling `6/7`), *Gram*
geometry (`Algebra.ZeroFitDialU72Parity`: the parity ceiling `1/√2`), *pooling* geometry
(`Algebra.ZeroFitDialU120Floor`), and rapidity *pooling* (`Physics.TDialU108BandLoss`:
Fisher-`z` addition is Einstein composition, and pooling inflates).  Every one of them
treats the reading as a point.  None of them models the **interval**.

But the entire round-66 record is a statement about intervals: a `+0.001` margin, a lower
end that dips below the floor, and a band decision.  The missing layer is the geometry of
a *rapidity-symmetric* interval — the shape a Fisher interval actually has after it is
mapped back to correlation coordinates — together with the sample-size cost of resolving
a given margin.  This file supplies that layer and uses it to score the record.

## Main results

### 1. Rapidity interval geometry (Section 2–3)

* `rapidityDiff`, `artanh_sub_artanh` — the relativistic difference
  `d(x,y) = (x-y)/(1-xy)` satisfies `artanh x - artanh y = artanh (d x y)`: rapidity
  differences of correlations are correlations again.
* `ciLo_eq_tanh`, `ciHi_eq_tanh` — the back-transformed Fisher interval of half-width `h`
  about `r` is exactly `[d(r,τ), d(r,-τ)]` with `τ = tanh h`.
* `ci_width_eq` — the **exact width law** `width = 2τ(1-r²)/(1-r²τ²)`.
* `arm_gap_eq`, `lower_arm_longer` — the **asymmetry law**: the lower arm exceeds the
  upper arm by exactly `2rτ²(1-r²)/(1-r²τ²)`, strictly positive for any positive reading.
  *A rapidity-symmetric interval at a positive correlation always dips further down than
  up*: the recorded "every CI dips below 0.55 at its lower end" is forced geometry, not
  evidence about the dial.
* `floor_certified_iff` — the **certification criterion** in closed form: the interval
  clears a floor `f` iff `τ ≤ d(r,f)`.

### 2. The resolution law (Section 4)

* `artanh_upper`, `artanh_lower` — two-sided elementary bounds
  `x(2+x)/(2(1+x)) ≤ artanh x ≤ x(2-x)/(2(1-x))` proved from `log t ≤ t - 1` only.
* `self_le_artanh` — the sharp comparison `x ≤ artanh x`, proved by a derivative argument
  (the crude log bounds are provably too weak here: the gap is cubic).
* `floor_certification_criterion` — the payload: with Fisher half-width `z/√(n-3)`,
  the floor `f` is certified **iff** `n ≥ 3 + (z/(artanh r - artanh f))²`.
  Resolution cost is a rapidity margin, squared and inverted.

### 3. Scoring the U80 record (Section 5)

* `u80_ci_is_rapidity_symmetric` — the reported interval `[0.542, 0.587]` is reproduced to
  better than `6·10⁻⁴` by a rapidity half-width `τ = 0.033`, and no symmetric interval in
  correlation coordinates can do this (`u80_ci_arms_unequal`).
* `u80_effective_sample_size` — hence the experiment carries `3400 ≤ n ≤ 3650` effective
  paired draws.
* `u80_pooled_undersampled` — certifying the pooled reading `0.565` over the floor needs
  `n ≥ 7900`: **the measurement is short by more than a factor of two.**
* `u80_seed_181_resolution_cost` — the `+0.001` margin of seed `20261181` needs
  `n ≥ 1.8·10⁶`, three orders of magnitude beyond the experiment.  The clearance is
  statistically empty.
* `u80_no_seed_certifies_floor` — with `n/3` draws per seed, *not one* of the three seeds
  certifies the floor, the best one (`0.582`) included.

### 4. Count parity in the natural coordinate (Section 6)

* `rapidity_advantage_ge` — `artanh a - artanh b ≥ a - b`: rapidity never deflates an
  advantage.
* `u80_parity_advantage_rapidity` — the recorded `+0.053` is a rapidity advantage of at
  least `+0.0745`, a `40%` inflation; `parity_advantage_still_fades` shows the bitlen-44
  advantage is more than `1.8×` larger *even in rapidity*, so the parity fade is real and
  not a coordinate artefact.

### 5. The bitlen-84 crossing prediction (Section 7)

Fitting a straight line in rapidity through the rungs `(72, 0.605)` and `(80, 0.565)`:

* `u80_crossing_before_84` — the floor `0.55` is crossed at bitlen `b* ∈ (82, 83)`;
* `u80_model_84_below_floor`, `u80_model_84_window` — the predicted bitlen-84 reading lies
  in `(0.543, 0.545)`, decisively below `0.55`.

Every one of these reduces, through `artanh x = ½ log((1+x)/(1-x))`, to an inequality
between *rational powers* — e.g. `b* < 83` is exactly `(2889/2449)^8 < (27927/24727)^11` —
which is the sense in which a rank-correlation extrapolation is an arithmetic statement.
-/

open Real

namespace Catalog.Applications.TDialU80FloorResolution

/-! ## 1. Rapidity: `artanh` as a logarithm, and elementary two-sided bounds -/

/-- `artanh` in explicit logarithmic form. -/
lemma artanh_eq_half_log {x : ℝ} (h1 : -1 < x) (h2 : x < 1) :
    artanh x = (Real.log (1 + x) - Real.log (1 - x)) / 2 := by
  have hp : (0:ℝ) < 1 + x := by linarith
  have hn : (0:ℝ) < 1 - x := by linarith
  rw [Real.artanh, Real.log_sqrt (by positivity), Real.log_div (by linarith) (by linarith)]

/-- The "doubled rapidity" form: `2·artanh x = log ((1+x)/(1-x))`. -/
lemma two_artanh_eq_log {x : ℝ} (h1 : -1 < x) (h2 : x < 1) :
    2 * artanh x = Real.log ((1 + x) / (1 - x)) := by
  rw [artanh_eq_half_log h1 h2, Real.log_div (by linarith) (by linarith)]
  ring

/-- Upper bound `artanh x ≤ x(2-x)/(2(1-x))`, from `log t ≤ t - 1` alone. -/
lemma artanh_upper {x : ℝ} (h0 : 0 ≤ x) (h1 : x < 1) :
    artanh x ≤ x * (2 - x) / (2 * (1 - x)) := by
  have hn : (0:ℝ) < 1 - x := by linarith
  have hA : Real.log (1 + x) ≤ x := by
    have := Real.log_le_sub_one_of_pos (x := 1 + x) (by linarith)
    linarith
  have hB : -Real.log (1 - x) ≤ x / (1 - x) := by
    have h := Real.log_le_sub_one_of_pos (x := 1 / (1 - x)) (by positivity)
    rw [Real.log_div one_ne_zero (by linarith), Real.log_one] at h
    have h2 : 1 / (1 - x) - 1 = x / (1 - x) := by field_simp; ring
    linarith [h2 ▸ h]
  have key : x * (2 - x) / (2 * (1 - x)) = (x + x / (1 - x)) / 2 := by field_simp; ring
  rw [artanh_eq_half_log (by linarith) h1, key]
  linarith

/-- Lower bound `x(2+x)/(2(1+x)) ≤ artanh x`, from `log t ≤ t - 1` alone. -/
lemma artanh_lower {x : ℝ} (h0 : 0 ≤ x) (h1 : x < 1) :
    x * (2 + x) / (2 * (1 + x)) ≤ artanh x := by
  have hp : (0:ℝ) < 1 + x := by linarith
  have hn : (0:ℝ) < 1 - x := by linarith
  have hA : x / (1 + x) ≤ Real.log (1 + x) := by
    have h := Real.log_le_sub_one_of_pos (x := 1 / (1 + x)) (by positivity)
    rw [Real.log_div one_ne_zero (by linarith), Real.log_one] at h
    have h2 : 1 / (1 + x) - 1 = -(x / (1 + x)) := by field_simp; ring
    rw [h2] at h; linarith
  have hB : Real.log (1 - x) ≤ -x := by
    have := Real.log_le_sub_one_of_pos (x := 1 - x) (by linarith)
    linarith
  have key : x * (2 + x) / (2 * (1 + x)) = (x / (1 + x) + x) / 2 := by field_simp; ring
  rw [artanh_eq_half_log (by linarith) h1, key]
  linarith

/-- **Rapidity dominates correlation**: `x ≤ artanh x` on `[0,1)`.  The gap is cubic, so
the elementary `log t ≤ t - 1` bounds above cannot give this; the proof is a derivative
argument on `g x = log(1+x) - log(1-x) - 2x`. -/
lemma self_le_artanh {x : ℝ} (h0 : 0 ≤ x) (h1 : x < 1) : x ≤ artanh x := by
  set g : ℝ → ℝ := fun t => Real.log (1 + t) - Real.log (1 - t) - 2 * t with hg
  have hderiv : ∀ t ∈ Set.Ioo (-1:ℝ) 1, HasDerivAt g (2 * t ^ 2 / (1 - t ^ 2)) t := by
    intro t ht
    have hp : (0:ℝ) < 1 + t := by linarith [ht.1]
    have hn : (0:ℝ) < 1 - t := by linarith [ht.2]
    have d1 : HasDerivAt (fun s : ℝ => Real.log (1 + s)) (1 / (1 + t)) t := by
      have h := (Real.hasDerivAt_log hp.ne').comp t ((hasDerivAt_id t).const_add 1)
      simpa [one_div] using h
    have d2 : HasDerivAt (fun s : ℝ => Real.log (1 - s)) (-(1 / (1 - t))) t := by
      have h := (Real.hasDerivAt_log hn.ne').comp t ((hasDerivAt_id t).const_sub 1)
      simpa [one_div, mul_comm] using h
    have d3 : HasDerivAt (fun s : ℝ => 2 * s) 2 t := by
      simpa using (hasDerivAt_id t).const_mul (2:ℝ)
    have := (d1.sub d2).sub d3
    have hne : (1:ℝ) - t ^ 2 ≠ 0 := by nlinarith
    have heq : 1 / (1 + t) - -(1 / (1 - t)) - 2 = 2 * t ^ 2 / (1 - t ^ 2) := by
      rw [eq_div_iff hne]; field_simp; ring
    rwa [heq] at this
  have hcont : ContinuousOn g (Set.Icc 0 x) := by
    intro t ht
    have ht1 : (-1:ℝ) < t := by linarith [ht.1]
    have ht2 : t < 1 := by linarith [ht.2, h1]
    exact ((hderiv t ⟨ht1, ht2⟩).continuousAt).continuousWithinAt
  have hmono : ∀ t ∈ Set.Ioo (0:ℝ) x, 0 ≤ deriv g t := by
    intro t ht
    have ht1 : (-1:ℝ) < t := by linarith [ht.1]
    have ht2 : t < 1 := by linarith [ht.2, h1]
    rw [(hderiv t ⟨ht1, ht2⟩).deriv]
    have : (0:ℝ) < 1 - t ^ 2 := by nlinarith
    positivity
  have hmonoOn : MonotoneOn g (Set.Icc 0 x) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc 0 x) hcont
    · intro t ht
      rw [interior_Icc] at ht
      have ht1 : (-1:ℝ) < t := by linarith [ht.1]
      have ht2 : t < 1 := by linarith [ht.2, h1]
      exact (hderiv t ⟨ht1, ht2⟩).differentiableAt.differentiableWithinAt
    · intro t ht
      rw [interior_Icc] at ht
      exact hmono t ht
  have h := hmonoOn (Set.left_mem_Icc.mpr h0) (Set.right_mem_Icc.mpr h0) h0
  simp only [hg] at h
  rw [artanh_eq_half_log (by linarith) h1]
  simp only [add_zero, sub_zero, Real.log_one, mul_zero, sub_self] at h
  linarith

/-! ## 2. The relativistic difference of two correlations -/

/-- The relativistic ("velocity") difference of two correlations. -/
noncomputable def rapidityDiff (x y : ℝ) : ℝ := (x - y) / (1 - x * y)

lemma one_sub_mul_pos {x y : ℝ} (hx1 : -1 < x) (hx2 : x < 1) (hy1 : -1 < y) (hy2 : y < 1) :
    0 < 1 - x * y := by nlinarith

lemma rapidityDiff_mem {x y : ℝ} (hx1 : -1 < x) (hx2 : x < 1) (hy1 : -1 < y) (hy2 : y < 1) :
    -1 < rapidityDiff x y ∧ rapidityDiff x y < 1 := by
  have hd : 0 < 1 - x * y := one_sub_mul_pos hx1 hx2 hy1 hy2
  refine ⟨?_, ?_⟩
  · rw [rapidityDiff, lt_div_iff₀ hd]; nlinarith
  · rw [rapidityDiff, div_lt_one hd]; nlinarith

lemma rapidityDiff_pos {x y : ℝ} (hx1 : -1 < x) (hx2 : x < 1) (hy1 : -1 < y) (hy2 : y < 1)
    (hlt : y < x) : 0 < rapidityDiff x y :=
  div_pos (by linarith) (one_sub_mul_pos hx1 hx2 hy1 hy2)

/-- **Rapidity differences are correlations.**  `artanh x - artanh y = artanh (d x y)`:
the Fisher scale turns the relativistic difference into ordinary subtraction. -/
theorem artanh_sub_artanh {x y : ℝ} (hx1 : -1 < x) (hx2 : x < 1) (hy1 : -1 < y) (hy2 : y < 1) :
    artanh x - artanh y = artanh (rapidityDiff x y) := by
  have hd : 0 < 1 - x * y := one_sub_mul_pos hx1 hx2 hy1 hy2
  obtain ⟨hm1, hm2⟩ := rapidityDiff_mem hx1 hx2 hy1 hy2
  have p1 : (0:ℝ) < (1 + x) * (1 - y) := mul_pos (by linarith) (by linarith)
  have p2 : (0:ℝ) < (1 - x) * (1 + y) := mul_pos (by linarith) (by linarith)
  have e1 : 1 + rapidityDiff x y = (1 + x) * (1 - y) / (1 - x * y) := by
    rw [rapidityDiff]; field_simp; ring
  have e2 : 1 - rapidityDiff x y = (1 - x) * (1 + y) / (1 - x * y) := by
    rw [rapidityDiff]; field_simp; ring
  rw [artanh_eq_half_log hx1 hx2, artanh_eq_half_log hy1 hy2, artanh_eq_half_log hm1 hm2,
    e1, e2, Real.log_div p1.ne' hd.ne', Real.log_div p2.ne' hd.ne',
    Real.log_mul (by linarith) (by linarith), Real.log_mul (by linarith) (by linarith)]
  ring

/-- **Rapidity never deflates an advantage.**  For `0 ≤ b ≤ a < 1`, the rapidity gap is at
least the raw gap. -/
theorem rapidity_advantage_ge {a b : ℝ} (hb : 0 ≤ b) (hab : b ≤ a) (ha : a < 1) :
    a - b ≤ artanh a - artanh b := by
  have ha1 : (-1:ℝ) < a := by linarith
  have hb1 : (-1:ℝ) < b := by linarith
  have hb2 : b < 1 := lt_of_le_of_lt hab ha
  have hd : 0 < 1 - a * b := one_sub_mul_pos ha1 ha hb1 hb2
  obtain ⟨hm1, hm2⟩ := rapidityDiff_mem ha1 ha hb1 hb2
  have h0 : 0 ≤ rapidityDiff a b := div_nonneg (by linarith) hd.le
  have hle : a - b ≤ rapidityDiff a b := by
    rw [rapidityDiff, le_div_iff₀ hd]
    nlinarith [mul_nonneg (sub_nonneg.mpr hab) (mul_nonneg (hb.trans hab) hb)]
  rw [artanh_sub_artanh ha1 ha hb1 hb2]
  exact hle.trans (self_le_artanh h0 hm2)

/-! ## 3. The geometry of a rapidity-symmetric interval -/

/-- Lower endpoint of the interval of rapidity half-width `artanh t` about the reading `r`. -/
noncomputable def ciLo (r t : ℝ) : ℝ := rapidityDiff r t

/-- Upper endpoint of the interval of rapidity half-width `artanh t` about the reading `r`. -/
noncomputable def ciHi (r t : ℝ) : ℝ := rapidityDiff r (-t)

lemma ciLo_eq (r t : ℝ) : ciLo r t = (r - t) / (1 - r * t) := rfl

lemma ciHi_eq (r t : ℝ) : ciHi r t = (r + t) / (1 + r * t) := by
  rw [ciHi, rapidityDiff]
  ring_nf

/-- The interval endpoints really are the back-transform of a symmetric rapidity interval. -/
theorem ciLo_eq_tanh {r t : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht1 : -1 < t) (ht2 : t < 1) :
    ciLo r t = Real.tanh (artanh r - artanh t) := by
  obtain ⟨hm1, hm2⟩ := rapidityDiff_mem hr1 hr2 ht1 ht2
  rw [artanh_sub_artanh hr1 hr2 ht1 ht2, Real.tanh_artanh ⟨hm1, hm2⟩, ciLo]

/-- `artanh` is odd. -/
lemma artanh_neg' {t : ℝ} (ht1 : -1 < t) (ht2 : t < 1) : artanh (-t) = -artanh t := by
  rw [artanh_eq_half_log (by linarith) (by linarith), artanh_eq_half_log ht1 ht2]
  have e1 : (1:ℝ) + -t = 1 - t := by ring
  have e2 : (1:ℝ) - -t = 1 + t := by ring
  rw [e1, e2]
  ring

theorem ciHi_eq_tanh {r t : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht1 : -1 < t) (ht2 : t < 1) :
    ciHi r t = Real.tanh (artanh r + artanh t) := by
  have hnt1 : (-1:ℝ) < -t := by linarith
  have hnt2 : (-t:ℝ) < 1 := by linarith
  obtain ⟨hm1, hm2⟩ := rapidityDiff_mem hr1 hr2 hnt1 hnt2
  have hneg : artanh (-t) = -artanh t := artanh_neg' ht1 ht2
  have : artanh r + artanh t = artanh r - artanh (-t) := by rw [hneg]; ring
  rw [ciHi, this, artanh_sub_artanh hr1 hr2 hnt1 hnt2, Real.tanh_artanh ⟨hm1, hm2⟩]

/-- **The width law.**  A rapidity-symmetric interval of half-width `artanh t` about `r`
has correlation-space width exactly `2t(1-r²)/(1-r²t²)`. -/
theorem ci_width_eq {r t : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht1 : -1 < t) (ht2 : t < 1) :
    ciHi r t - ciLo r t = 2 * t * (1 - r ^ 2) / (1 - r ^ 2 * t ^ 2) := by
  have h1 : 0 < 1 - r * t := one_sub_mul_pos hr1 hr2 ht1 ht2
  have h2 : 0 < 1 + r * t := by nlinarith
  have h3 : (1:ℝ) - r ^ 2 * t ^ 2 ≠ 0 := by nlinarith
  rw [ciHi_eq, ciLo_eq, div_sub_div _ _ h2.ne' h1.ne', eq_div_iff h3]
  field_simp
  ring

/-- **The asymmetry law.**  The lower arm exceeds the upper arm by exactly
`2rt²(1-r²)/(1-r²t²)`. -/
theorem arm_gap_eq {r t : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht1 : -1 < t) (ht2 : t < 1) :
    (r - ciLo r t) - (ciHi r t - r) = 2 * r * t ^ 2 * (1 - r ^ 2) / (1 - r ^ 2 * t ^ 2) := by
  have h1 : 0 < 1 - r * t := one_sub_mul_pos hr1 hr2 ht1 ht2
  have h2 : 0 < 1 + r * t := by nlinarith
  have h3 : (1:ℝ) - r ^ 2 * t ^ 2 ≠ 0 := by nlinarith
  rw [ciHi_eq, ciLo_eq, eq_div_iff h3]
  field_simp
  ring

/-- **A positive reading always dips further down than up.**  Hence "the CI dips below the
floor at its lower end" is a structural feature of Fisher intervals, carrying no
information about the dial beyond its point estimate. -/
theorem lower_arm_longer {r t : ℝ} (hr0 : 0 < r) (hr2 : r < 1) (ht0 : 0 < t) (ht2 : t < 1) :
    ciHi r t - r < r - ciLo r t := by
  have hr1 : (-1:ℝ) < r := by linarith
  have ht1 : (-1:ℝ) < t := by linarith
  have hgap := arm_gap_eq hr1 hr2 ht1 ht2
  have hrs : r ^ 2 < 1 := by nlinarith
  have hts : t ^ 2 < 1 := by nlinarith
  have hden : 0 < 1 - r ^ 2 * t ^ 2 := by nlinarith [sq_nonneg r, sq_nonneg t]
  have hnum : 0 < 2 * r * t ^ 2 * (1 - r ^ 2) :=
    mul_pos (mul_pos (by linarith) (pow_pos ht0 2)) (by nlinarith)
  have : 0 < 2 * r * t ^ 2 * (1 - r ^ 2) / (1 - r ^ 2 * t ^ 2) := div_pos hnum hden
  linarith [hgap ▸ this]

/-- **The certification criterion, closed form.**  The interval clears the floor `f`
exactly when the rapidity half-width parameter `t` is at most the relativistic gap
`d(r,f)`. -/
theorem floor_certified_iff {r t f : ℝ} (hr1 : -1 < r) (hr2 : r < 1) (ht1 : -1 < t)
    (ht2 : t < 1) (hf0 : 0 ≤ f) (hf2 : f < 1) :
    f ≤ ciLo r t ↔ t ≤ rapidityDiff r f := by
  have h1 : 0 < 1 - r * t := one_sub_mul_pos hr1 hr2 ht1 ht2
  have h2 : 0 < 1 - r * f := one_sub_mul_pos hr1 hr2 (by linarith) hf2
  rw [ciLo_eq, le_div_iff₀ h1, rapidityDiff, le_div_iff₀ h2]
  constructor <;> intro h <;> nlinarith

/-! ## 4. The resolution law: sample size as an inverse squared rapidity margin -/

/-- Fisher half-width at confidence multiplier `z` and effective sample size `n`. -/
noncomputable def fisherHalfWidth (z n : ℝ) : ℝ := z / Real.sqrt (n - 3)

/-- Sample size required to resolve a rapidity margin `M` at multiplier `z`. -/
noncomputable def reqSamples (z M : ℝ) : ℝ := 3 + (z / M) ^ 2

lemma reqSamples_ge_of_le {z M B : ℝ} (hz : 0 < z) (hM : 0 < M) (hMB : M ≤ B) :
    3 + (z / B) ^ 2 ≤ reqSamples z M := by
  have hB : 0 < B := lt_of_lt_of_le hM hMB
  have hmono : z / B ≤ z / M := by gcongr
  have h2 : (z / B) ^ 2 ≤ (z / M) ^ 2 := by
    nlinarith [hmono, div_nonneg hz.le hB.le, div_nonneg hz.le hM.le]
  simpa [reqSamples] using h2

lemma reqSamples_le_of_ge {z M L : ℝ} (hz : 0 < z) (hL : 0 < L) (hLM : L ≤ M) :
    reqSamples z M ≤ 3 + (z / L) ^ 2 := by
  have hM : 0 < M := lt_of_lt_of_le hL hLM
  have hmono : z / M ≤ z / L := by gcongr
  have h2 : (z / M) ^ 2 ≤ (z / L) ^ 2 := by
    nlinarith [hmono, div_nonneg hz.le hL.le, div_nonneg hz.le hM.le]
  simpa [reqSamples] using h2

lemma halfWidth_le_iff {z n M : ℝ} (hz : 0 < z) (hn : 3 < n) (hM : 0 < M) :
    fisherHalfWidth z n ≤ M ↔ reqSamples z M ≤ n := by
  have hpos : 0 < n - 3 := by linarith
  have hs : 0 < Real.sqrt (n - 3) := Real.sqrt_pos.mpr hpos
  rw [fisherHalfWidth, div_le_iff₀ hs, reqSamples]
  constructor
  · intro h
    have h1 : z / M ≤ Real.sqrt (n - 3) := by rw [div_le_iff₀ hM]; linarith
    have h2 : (z / M) ^ 2 ≤ n - 3 := by
      have := Real.sq_sqrt hpos.le
      nlinarith [Real.sqrt_nonneg (n - 3), div_nonneg hz.le hM.le]
    linarith
  · intro h
    have h2 : (z / M) ^ 2 ≤ n - 3 := by linarith
    have h1 : z / M ≤ Real.sqrt (n - 3) := by
      rw [show z / M = |z / M| from (abs_of_nonneg (by positivity)).symm]
      exact Real.abs_le_sqrt (by linarith [sq_abs (z/M)])
    rw [div_le_iff₀ hM] at h1
    linarith

/-- **The resolution law.**  With a Fisher interval at multiplier `z` and effective sample
size `n`, the floor `f` is certified by a reading `r > f` **iff**
`n ≥ 3 + (z / (artanh r - artanh f))²`. -/
theorem floor_certification_criterion {z n r f : ℝ} (hz : 0 < z) (hn : 3 < n)
    (hf0 : 0 ≤ f) (hfr : f < r) (hr2 : r < 1) :
    f ≤ ciLo r (Real.tanh (fisherHalfWidth z n)) ↔
      reqSamples z (artanh r - artanh f) ≤ n := by
  have hr1 : (-1:ℝ) < r := by linarith
  have hf1 : (-1:ℝ) < f := by linarith
  have hf2 : f < 1 := lt_trans hfr hr2
  set h := fisherHalfWidth z n with hh
  set t := Real.tanh h with htdef
  have ht1 : -1 < t := Real.neg_one_lt_tanh h
  have ht2 : t < 1 := Real.tanh_lt_one h
  have hM : 0 < artanh r - artanh f := by
    have := Real.artanh_lt_artanh hf1 hr2 hfr
    linarith
  obtain ⟨hd1, hd2⟩ := rapidityDiff_mem hr1 hr2 hf1 hf2
  rw [floor_certified_iff hr1 hr2 ht1 ht2 hf0 hf2, ← halfWidth_le_iff hz hn hM,
    artanh_sub_artanh hr1 hr2 hf1 hf2, ← hh]
  constructor
  · intro hle
    have := Real.artanh_le_artanh ht1 hd2 hle
    rwa [htdef, Real.artanh_tanh] at this
  · intro hle
    by_contra hcon
    push_neg at hcon
    have := Real.artanh_lt_artanh hd1 ht2 hcon
    rw [htdef, Real.artanh_tanh] at this
    linarith

/-! ## 5. Scoring the U80 record -/

/-- Pooled U80 reading. -/
noncomputable def rhoPooled : ℝ := 565 / 1000
/-- Seed `20261180`. -/
noncomputable def rhoSeed0 : ℝ := 562 / 1000
/-- Seed `20261181` — the seed that clears the floor by `+0.001`. -/
noncomputable def rhoSeed1 : ℝ := 551 / 1000
/-- Seed `20261182`. -/
noncomputable def rhoSeed2 : ℝ := 582 / 1000
/-- Pre-registered band floor. -/
noncomputable def bandFloor : ℝ := 55 / 100
/-- Pre-registered band ceiling. -/
noncomputable def bandCeil : ℝ := 85 / 100
/-- The `95%` normal multiplier used by the reproduction script. -/
noncomputable def zMult : ℝ := 196 / 100
/-- The rapidity half-width parameter that reproduces the reported interval. -/
noncomputable def tauU80 : ℝ := 33 / 1000

/-- All three seeds and the pooled value lie inside the validation band. -/
theorem u80_inside_band :
    bandFloor < rhoSeed0 ∧ rhoSeed0 < bandCeil ∧
    bandFloor < rhoSeed1 ∧ rhoSeed1 < bandCeil ∧
    bandFloor < rhoSeed2 ∧ rhoSeed2 < bandCeil ∧
    bandFloor < rhoPooled ∧ rhoPooled < bandCeil := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [bandFloor, bandCeil, rhoSeed0, rhoSeed1, rhoSeed2, rhoPooled] <;> norm_num

/-- The pooled reading is the arithmetic mean of the three seeds, to `10⁻⁴`. -/
theorem u80_pooled_is_seed_mean :
    |rhoPooled - (rhoSeed0 + rhoSeed1 + rhoSeed2) / 3| < 1 / 10000 := by
  simp only [rhoPooled, rhoSeed0, rhoSeed1, rhoSeed2]
  rw [abs_lt]
  constructor <;> norm_num

/-- **The reported interval is rapidity-symmetric.**  A single rapidity half-width
`τ = 0.033` reproduces both reported endpoints `[0.542, 0.587]` to better than `6·10⁻⁴`
(i.e. exactly, after rounding to three decimals). -/
theorem u80_ci_is_rapidity_symmetric :
    |ciLo rhoPooled tauU80 - 542 / 1000| < 6 / 10000 ∧
    |ciHi rhoPooled tauU80 - 587 / 1000| < 6 / 10000 := by
  constructor
  · rw [ciLo_eq]
    simp only [rhoPooled, tauU80]
    rw [abs_lt]
    constructor <;> norm_num
  · rw [ciHi_eq]
    simp only [rhoPooled, tauU80]
    rw [abs_lt]
    constructor <;> norm_num

/-- The two arms of the reported interval are provably unequal: the lower arm is longer.
No interval symmetric in correlation coordinates can match the record. -/
theorem u80_ci_arms_unequal :
    ciHi rhoPooled tauU80 - rhoPooled < rhoPooled - ciLo rhoPooled tauU80 := by
  apply lower_arm_longer <;> simp only [rhoPooled, tauU80] <;> norm_num

/-- The interval dips below the band floor at its lower end. -/
theorem u80_ci_dips_below_floor : ciLo rhoPooled tauU80 < bandFloor := by
  rw [ciLo_eq]
  simp only [rhoPooled, tauU80, bandFloor]
  norm_num

/-- The effective (paired-draw) sample size carried by the reported interval. -/
noncomputable def effSamples : ℝ := reqSamples zMult (artanh tauU80)

/-- **The experiment carries between 3400 and 3650 effective draws.**  Both bounds come
from the elementary two-sided `artanh` estimates. -/
theorem u80_effective_sample_size : 3400 ≤ effSamples ∧ effSamples ≤ 3650 := by
  have h0 : (0:ℝ) ≤ tauU80 := by simp only [tauU80]; norm_num
  have h1 : tauU80 < 1 := by simp only [tauU80]; norm_num
  have hz : (0:ℝ) < zMult := by simp only [zMult]; norm_num
  have hup := artanh_upper h0 h1
  have hlo := artanh_lower h0 h1
  have hLpos : (0:ℝ) < tauU80 * (2 + tauU80) / (2 * (1 + tauU80)) := by
    simp only [tauU80]; norm_num
  constructor
  · have := reqSamples_ge_of_le (z := zMult) (M := artanh tauU80)
      (B := tauU80 * (2 - tauU80) / (2 * (1 - tauU80))) hz (lt_of_lt_of_le hLpos hlo) hup
    refine le_trans ?_ this
    simp only [zMult, tauU80]
    norm_num
  · have := reqSamples_le_of_ge (z := zMult) (M := artanh tauU80)
      (L := tauU80 * (2 + tauU80) / (2 * (1 + tauU80))) hz hLpos hlo
    refine le_trans this ?_
    simp only [zMult, tauU80]
    norm_num

/-- A convenience wrapper: an upper bound for the rapidity margin of a reading over the
floor, in terms of the relativistic gap. -/
lemma margin_upper {r f : ℝ} (hf0 : 0 ≤ f) (hfr : f < r) (hr2 : r < 1) :
    artanh r - artanh f ≤
      rapidityDiff r f * (2 - rapidityDiff r f) / (2 * (1 - rapidityDiff r f)) := by
  have hr1 : (-1:ℝ) < r := by linarith
  have hf1 : (-1:ℝ) < f := by linarith
  have hf2 : f < 1 := lt_trans hfr hr2
  obtain ⟨hd1, hd2⟩ := rapidityDiff_mem hr1 hr2 hf1 hf2
  have hdpos : 0 < rapidityDiff r f := rapidityDiff_pos hr1 hr2 hf1 hf2 hfr
  rw [artanh_sub_artanh hr1 hr2 hf1 hf2]
  exact artanh_upper hdpos.le hd2

lemma margin_pos {r f : ℝ} (hf0 : 0 ≤ f) (hfr : f < r) (hr2 : r < 1) :
    0 < artanh r - artanh f := by
  have := Real.artanh_lt_artanh (by linarith : (-1:ℝ) < f) hr2 hfr
  linarith

/-- **The pooled reading needs at least 7900 draws to certify the floor.** -/
theorem u80_pooled_requires_7900 :
    7900 ≤ reqSamples zMult (artanh rhoPooled - artanh bandFloor) := by
  have hf0 : (0:ℝ) ≤ bandFloor := by simp only [bandFloor]; norm_num
  have hfr : bandFloor < rhoPooled := by simp only [bandFloor, rhoPooled]; norm_num
  have hr2 : rhoPooled < 1 := by simp only [rhoPooled]; norm_num
  have hz : (0:ℝ) < zMult := by simp only [zMult]; norm_num
  have hup := margin_upper hf0 hfr hr2
  have hpos := margin_pos hf0 hfr hr2
  have := reqSamples_ge_of_le hz hpos hup
  refine le_trans ?_ this
  simp only [zMult, rapidityDiff, rhoPooled, bandFloor]
  norm_num

/-- **The U80 measurement is undersampled by more than a factor of two**: certification of
the pooled reading over the floor needs more than twice the draws the interval reveals. -/
theorem u80_pooled_undersampled :
    2 * effSamples < reqSamples zMult (artanh rhoPooled - artanh bandFloor) := by
  have h1 := u80_effective_sample_size.2
  have h2 := u80_pooled_requires_7900
  linarith

/-- **The `+0.001` clearance of seed `20261181` is statistically empty**: resolving it
would take at least `1.8·10⁶` paired draws, three orders of magnitude beyond the
experiment. -/
theorem u80_seed_181_resolution_cost :
    1800000 ≤ reqSamples zMult (artanh rhoSeed1 - artanh bandFloor) := by
  have hf0 : (0:ℝ) ≤ bandFloor := by simp only [bandFloor]; norm_num
  have hfr : bandFloor < rhoSeed1 := by simp only [bandFloor, rhoSeed1]; norm_num
  have hr2 : rhoSeed1 < 1 := by simp only [rhoSeed1]; norm_num
  have hz : (0:ℝ) < zMult := by simp only [zMult]; norm_num
  have := reqSamples_ge_of_le hz (margin_pos hf0 hfr hr2) (margin_upper hf0 hfr hr2)
  refine le_trans ?_ this
  simp only [zMult, rapidityDiff, rhoSeed1, bandFloor]
  norm_num

/-- **No single seed certifies the floor.**  Each seed carries at most `effSamples / 3`
draws, and every one of the three required sample sizes exceeds that budget — including
the best seed, `0.582`. -/
theorem u80_no_seed_certifies_floor :
    effSamples / 3 < reqSamples zMult (artanh rhoSeed0 - artanh bandFloor) ∧
    effSamples / 3 < reqSamples zMult (artanh rhoSeed1 - artanh bandFloor) ∧
    effSamples / 3 < reqSamples zMult (artanh rhoSeed2 - artanh bandFloor) := by
  have hbudget : effSamples / 3 ≤ 1217 := by
    have := u80_effective_sample_size.2
    linarith
  have hf0 : (0:ℝ) ≤ bandFloor := by simp only [bandFloor]; norm_num
  have hz : (0:ℝ) < zMult := by simp only [zMult]; norm_num
  refine ⟨?_, ?_, ?_⟩
  · have hfr : bandFloor < rhoSeed0 := by simp only [bandFloor, rhoSeed0]; norm_num
    have hr2 : rhoSeed0 < 1 := by simp only [rhoSeed0]; norm_num
    have h := reqSamples_ge_of_le hz (margin_pos hf0 hfr hr2) (margin_upper hf0 hfr hr2)
    have hnum : (12500:ℝ) ≤ 3 + (zMult / (rapidityDiff rhoSeed0 bandFloor *
        (2 - rapidityDiff rhoSeed0 bandFloor) /
        (2 * (1 - rapidityDiff rhoSeed0 bandFloor)))) ^ 2 := by
      simp only [zMult, rapidityDiff, rhoSeed0, bandFloor]; norm_num
    linarith
  · have h := u80_seed_181_resolution_cost
    linarith
  · have hfr : bandFloor < rhoSeed2 := by simp only [bandFloor, rhoSeed2]; norm_num
    have hr2 : rhoSeed2 < 1 := by simp only [rhoSeed2]; norm_num
    have h := reqSamples_ge_of_le hz (margin_pos hf0 hfr hr2) (margin_upper hf0 hfr hr2)
    have hnum : (1650:ℝ) ≤ 3 + (zMult / (rapidityDiff rhoSeed2 bandFloor *
        (2 - rapidityDiff rhoSeed2 bandFloor) /
        (2 * (1 - rapidityDiff rhoSeed2 bandFloor)))) ^ 2 := by
      simp only [zMult, rapidityDiff, rhoSeed2, bandFloor]; norm_num
    linarith

/-! ## 6. Count parity in the natural coordinate -/

/-- The popcount baseline implied by the recorded `+0.053` pooled advantage. -/
noncomputable def rhoCount : ℝ := 512 / 1000

/-- **The recorded parity advantage is at least `+0.0745` in rapidity** — a `40%`
inflation over the raw `+0.053`. -/
theorem u80_parity_advantage_rapidity :
    0745 / 10000 ≤ artanh rhoPooled - artanh rhoCount := by
  have hb : (0:ℝ) ≤ rhoCount := by simp only [rhoCount]; norm_num
  have hab : rhoCount ≤ rhoPooled := by simp only [rhoCount, rhoPooled]; norm_num
  have ha : rhoPooled < 1 := by simp only [rhoPooled]; norm_num
  have hr1 : (-1:ℝ) < rhoPooled := by simp only [rhoPooled]; norm_num
  have hb1 : (-1:ℝ) < rhoCount := by simp only [rhoCount]; norm_num
  have hb2 : rhoCount < 1 := by simp only [rhoCount]; norm_num
  obtain ⟨hd1, hd2⟩ := rapidityDiff_mem hr1 ha hb1 hb2
  have hdpos : 0 ≤ rapidityDiff rhoPooled rhoCount :=
    (rapidityDiff_pos hr1 ha hb1 hb2 (by simp only [rhoCount, rhoPooled]; norm_num)).le
  rw [artanh_sub_artanh hr1 ha hb1 hb2]
  refine le_trans ?_ (self_le_artanh hdpos hd2)
  simp only [rapidityDiff, rhoPooled, rhoCount]
  norm_num

/-- The bitlen-44 rung (`0.78` against a `0.71` baseline) had a rapidity advantage more
than `1.8×` larger than U80's.  So the parity fade survives the change of coordinate: it
is a real effect, not an artefact of reading correlations on the wrong scale. -/
theorem parity_advantage_still_fades :
    18 / 10 * (artanh rhoPooled - artanh rhoCount) <
      artanh (78 / 100 : ℝ) - artanh (71 / 100 : ℝ) := by
  -- upper bound for the U80 rapidity advantage
  have hUp : artanh rhoPooled - artanh rhoCount ≤ 776 / 10000 := by
    have hb : (0:ℝ) ≤ rhoCount := by simp only [rhoCount]; norm_num
    have hab : rhoCount < rhoPooled := by simp only [rhoCount, rhoPooled]; norm_num
    have ha : rhoPooled < 1 := by simp only [rhoPooled]; norm_num
    have h := margin_upper hb hab ha
    refine le_trans h ?_
    simp only [rapidityDiff, rhoPooled, rhoCount]
    norm_num
  -- lower bound for the bitlen-44 rapidity advantage
  have hLo : (1462 / 10000 : ℝ) ≤ artanh (78 / 100 : ℝ) - artanh (71 / 100 : ℝ) := by
    have hr1 : (-1:ℝ) < (78 / 100 : ℝ) := by norm_num
    have hr2 : (78 / 100 : ℝ) < 1 := by norm_num
    have hf1 : (-1:ℝ) < (71 / 100 : ℝ) := by norm_num
    have hf2 : (71 / 100 : ℝ) < 1 := by norm_num
    obtain ⟨hd1, hd2⟩ := rapidityDiff_mem hr1 hr2 hf1 hf2
    have hdpos : (0:ℝ) ≤ rapidityDiff (78 / 100) (71 / 100) :=
      (rapidityDiff_pos hr1 hr2 hf1 hf2 (by norm_num)).le
    rw [artanh_sub_artanh hr1 hr2 hf1 hf2]
    refine le_trans ?_ (artanh_lower hdpos hd2)
    simp only [rapidityDiff]
    norm_num
  linarith

/-! ## 7. The bitlen-84 crossing prediction -/

/-- Comparison of rational powers transfers to rapidity combinations. -/
lemma log_pow_lt {P Q : ℝ} {m k : ℕ} (hP : 0 < P) (h : P ^ m < Q ^ k) :
    (m : ℝ) * Real.log P < (k : ℝ) * Real.log Q := by
  have h1 : Real.log (P ^ m) < Real.log (Q ^ k) :=
    Real.log_lt_log (by positivity) h
  rwa [Real.log_pow, Real.log_pow] at h1

/-- `tanh` is strictly monotone (derived from strict monotonicity of `artanh`). -/
lemma tanh_lt_tanh {a b : ℝ} (h : a < b) : Real.tanh a < Real.tanh b := by
  by_contra hcon
  push_neg at hcon
  have := Real.artanh_le_artanh (Real.neg_one_lt_tanh b) (Real.tanh_lt_one a) hcon
  rw [Real.artanh_tanh, Real.artanh_tanh] at this
  linarith

/-- The reading `0.605` at bitlen 72 (previous uniform rung). -/
noncomputable def rho72 : ℝ := 605 / 1000

/-- The rapidity-linear model through two rungs, evaluated at a third bitlen. -/
noncomputable def modelRho (r1 r2 b1 b2 b : ℝ) : ℝ :=
  Real.tanh (artanh r1 + (b - b1) / (b2 - b1) * (artanh r2 - artanh r1))

/-- The bitlen at which the rapidity-linear model crosses a floor `f`. -/
noncomputable def crossingBitlen (r1 r2 b1 b2 f : ℝ) : ℝ :=
  b1 + (artanh r1 - artanh f) * (b2 - b1) / (artanh r1 - artanh r2)

/-- Key arithmetic input: `2(artanh 0.605 - artanh 0.565) = log (27927/24727)`. -/
lemma two_gap_72_80 :
    2 * (artanh rho72 - artanh rhoPooled) = Real.log (27927 / 24727) := by
  have h1 : (2:ℝ) * artanh rho72 = Real.log ((1 + rho72) / (1 - rho72)) :=
    two_artanh_eq_log (by simp only [rho72]; norm_num) (by simp only [rho72]; norm_num)
  have h2 : (2:ℝ) * artanh rhoPooled = Real.log ((1 + rhoPooled) / (1 - rhoPooled)) :=
    two_artanh_eq_log (by simp only [rhoPooled]; norm_num) (by simp only [rhoPooled]; norm_num)
  have e1 : (1 + rho72) / (1 - rho72) = 321 / 79 := by simp only [rho72]; norm_num
  have e2 : (1 + rhoPooled) / (1 - rhoPooled) = 313 / 87 := by simp only [rhoPooled]; norm_num
  have e3 : (27927:ℝ) / 24727 = (321 / 79) / (313 / 87) := by norm_num
  rw [mul_sub, h1, h2, e1, e2, e3]
  exact (Real.log_div (by norm_num) (by norm_num)).symm

/-- Key arithmetic input: `2(artanh 0.565 - artanh 0.55) = log (939/899)`. -/
lemma two_gap_80_floor :
    2 * (artanh rhoPooled - artanh bandFloor) = Real.log (939 / 899) := by
  have h1 : (2:ℝ) * artanh rhoPooled = Real.log ((1 + rhoPooled) / (1 - rhoPooled)) :=
    two_artanh_eq_log (by simp only [rhoPooled]; norm_num) (by simp only [rhoPooled]; norm_num)
  have h2 : (2:ℝ) * artanh bandFloor = Real.log ((1 + bandFloor) / (1 - bandFloor)) :=
    two_artanh_eq_log (by simp only [bandFloor]; norm_num) (by simp only [bandFloor]; norm_num)
  have e1 : (1 + rhoPooled) / (1 - rhoPooled) = 313 / 87 := by simp only [rhoPooled]; norm_num
  have e2 : (1 + bandFloor) / (1 - bandFloor) = 31 / 9 := by simp only [bandFloor]; norm_num
  have e3 : (939:ℝ) / 899 = (313 / 87) / (31 / 9) := by norm_num
  rw [mul_sub, h1, h2, e1, e2, e3]
  exact (Real.log_div (by norm_num) (by norm_num)).symm

/-- Key arithmetic input: `2(artanh 0.605 - artanh 0.55) = log (2889/2449)`. -/
lemma two_gap_72_floor :
    2 * (artanh rho72 - artanh bandFloor) = Real.log (2889 / 2449) := by
  have h1 : (2:ℝ) * artanh rho72 = Real.log ((1 + rho72) / (1 - rho72)) :=
    two_artanh_eq_log (by simp only [rho72]; norm_num) (by simp only [rho72]; norm_num)
  have h2 : (2:ℝ) * artanh bandFloor = Real.log ((1 + bandFloor) / (1 - bandFloor)) :=
    two_artanh_eq_log (by simp only [bandFloor]; norm_num) (by simp only [bandFloor]; norm_num)
  have e1 : (1 + rho72) / (1 - rho72) = 321 / 79 := by simp only [rho72]; norm_num
  have e2 : (1 + bandFloor) / (1 - bandFloor) = 31 / 9 := by simp only [bandFloor]; norm_num
  have e3 : (2889:ℝ) / 2449 = (321 / 79) / (31 / 9) := by norm_num
  rw [mul_sub, h1, h2, e1, e2, e3]
  exact (Real.log_div (by norm_num) (by norm_num)).symm

/-- The rapidity ladder is strictly decreasing from bitlen 72 to bitlen 80. -/
lemma rapidity_decreasing_72_80 : 0 < artanh rho72 - artanh rhoPooled := by
  have := Real.artanh_lt_artanh (x := rhoPooled) (y := rho72)
    (by simp only [rhoPooled]; norm_num) (by simp only [rho72]; norm_num)
    (by simp only [rho72, rhoPooled]; norm_num)
  linarith

/-- **The floor is crossed strictly between bitlen 82 and bitlen 83.**  The two halves of
the statement are exactly the rational inequalities `(2889/2449)^4 > (27927/24727)^5` and
`(2889/2449)^8 < (27927/24727)^11`. -/
theorem u80_crossing_before_84 :
    82 < crossingBitlen rho72 rhoPooled 72 80 bandFloor ∧
    crossingBitlen rho72 rhoPooled 72 80 bandFloor < 83 := by
  have hden := rapidity_decreasing_72_80
  have hR : (0:ℝ) < 2889 / 2449 := by norm_num
  have hQ : (0:ℝ) < 27927 / 24727 := by norm_num
  -- lower: 8·(z72 - zf) > 10·(z72 - z80)
  have hlow : 10 * (artanh rho72 - artanh rhoPooled) < 8 * (artanh rho72 - artanh bandFloor) := by
    have h := log_pow_lt (Q := (2889 / 2449 : ℝ)) (m := 5) (k := 4) hQ (by norm_num)
    have e1 := two_gap_72_80
    have e2 := two_gap_72_floor
    push_cast at h
    nlinarith [h, e1, e2]
  have hhigh : 8 * (artanh rho72 - artanh bandFloor) <
      11 * (artanh rho72 - artanh rhoPooled) := by
    have h := log_pow_lt (Q := (27927 / 24727 : ℝ)) (m := 8) (k := 11) hR (by norm_num)
    have e1 := two_gap_72_80
    have e2 := two_gap_72_floor
    push_cast at h
    nlinarith [h, e1, e2]
  refine ⟨?_, ?_⟩
  · rw [crossingBitlen]
    have h : (10:ℝ) <
        (artanh rho72 - artanh bandFloor) * (80 - 72) / (artanh rho72 - artanh rhoPooled) := by
      rw [lt_div_iff₀ hden]; linarith
    linarith
  · rw [crossingBitlen]
    have h : (artanh rho72 - artanh bandFloor) * (80 - 72) /
        (artanh rho72 - artanh rhoPooled) < 11 := by
      rw [div_lt_iff₀ hden]; linarith
    linarith

/-- Comparison of products of rational powers transfers to rapidity combinations. -/
lemma log_prod_lt {A B C D : ℝ} (hA : 0 < A) (hB : 0 < B) (hC : 0 < C) (hD : 0 < D)
    {m k p q : ℕ} (h : A ^ m * B ^ k < C ^ p * D ^ q) :
    (m : ℝ) * Real.log A + (k : ℝ) * Real.log B <
      (p : ℝ) * Real.log C + (q : ℝ) * Real.log D := by
  have h1 : Real.log (A ^ m * B ^ k) < Real.log (C ^ p * D ^ q) :=
    Real.log_lt_log (by positivity) h
  rwa [Real.log_mul (by positivity) (by positivity),
    Real.log_mul (by positivity) (by positivity),
    Real.log_pow, Real.log_pow, Real.log_pow, Real.log_pow] at h1

/-- **The rapidity-linear model puts bitlen 84 in the window `(0.543, 0.545)`.** -/
theorem u80_model_84_window :
    543 / 1000 < modelRho rho72 rhoPooled 72 80 84 ∧
    modelRho rho72 rhoPooled 72 80 84 < 545 / 1000 := by
  have hA : (2:ℝ) * artanh rhoPooled = Real.log (313 / 87) := by
    have h := two_artanh_eq_log (x := rhoPooled)
      (by simp only [rhoPooled]; norm_num) (by simp only [rhoPooled]; norm_num)
    have e : (1 + rhoPooled) / (1 - rhoPooled) = 313 / 87 := by simp only [rhoPooled]; norm_num
    rwa [e] at h
  have hB : (2:ℝ) * artanh rho72 = Real.log (321 / 79) := by
    have h := two_artanh_eq_log (x := rho72)
      (by simp only [rho72]; norm_num) (by simp only [rho72]; norm_num)
    have e : (1 + rho72) / (1 - rho72) = 321 / 79 := by simp only [rho72]; norm_num
    rwa [e] at h
  have hC1 : (2:ℝ) * artanh (543 / 1000 : ℝ) = Real.log (1543 / 457) := by
    have h := two_artanh_eq_log (x := (543 / 1000 : ℝ)) (by norm_num) (by norm_num)
    have e : (1 + (543 / 1000 : ℝ)) / (1 - 543 / 1000) = 1543 / 457 := by norm_num
    rwa [e] at h
  have hC2 : (2:ℝ) * artanh (545 / 1000 : ℝ) = Real.log (309 / 91) := by
    have h := two_artanh_eq_log (x := (545 / 1000 : ℝ)) (by norm_num) (by norm_num)
    have e : (1 + (545 / 1000 : ℝ)) / (1 - 545 / 1000) = 309 / 91 := by norm_num
    rwa [e] at h
  have key1 : artanh (543 / 1000 : ℝ) <
      artanh rho72 + (84 - 72) / (80 - 72) * (artanh rhoPooled - artanh rho72) := by
    have h := log_prod_lt (A := (1543 / 457 : ℝ)) (B := (321 / 79 : ℝ)) (C := (313 / 87 : ℝ))
      (D := (1 : ℝ)) (m := 2) (k := 1) (p := 3) (q := 0) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
    push_cast at h
    rw [Real.log_one] at h
    linarith
  have key2 : artanh rho72 + (84 - 72) / (80 - 72) * (artanh rhoPooled - artanh rho72) <
      artanh (545 / 1000 : ℝ) := by
    have h := log_prod_lt (A := (313 / 87 : ℝ)) (B := (1 : ℝ)) (C := (309 / 91 : ℝ))
      (D := (321 / 79 : ℝ)) (m := 3) (k := 0) (p := 2) (q := 1) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num)
    push_cast at h
    rw [Real.log_one] at h
    linarith
  have e1 : Real.tanh (artanh (543 / 1000 : ℝ)) = 543 / 1000 :=
    Real.tanh_artanh ⟨by norm_num, by norm_num⟩
  have e2 : Real.tanh (artanh (545 / 1000 : ℝ)) = 545 / 1000 :=
    Real.tanh_artanh ⟨by norm_num, by norm_num⟩
  constructor
  · rw [modelRho, ← e1]
    exact tanh_lt_tanh key1
  · rw [modelRho, ← e2]
    exact tanh_lt_tanh key2

/-- **The model puts bitlen 84 strictly below the pre-registered floor.**  This is the
falsifiable prediction the round-66 record calls the crossing test. -/
theorem u80_model_84_below_floor : modelRho rho72 rhoPooled 72 80 84 < bandFloor := by
  have h := u80_model_84_window.2
  simp only [bandFloor]
  linarith

end Catalog.Applications.TDialU80FloorResolution