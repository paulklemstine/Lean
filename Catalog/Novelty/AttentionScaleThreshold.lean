import Novelty.AttentionRetentionKnee

/-!
# Hinges, grid resolution, and the scale threshold (NET-67, cycle 2)

This is the second research cycle on the NET-67 measurement.  Cycle 1
(`Novelty.AttentionBudgetIncrement`, `Novelty.AttentionRetentionKnee`) fixed the
two measured budget laws, audited the verdict, and derived the additive law from
a decay rate degrading like `1/log(context)`.  Three questions were left open,
and each gets a theorem here.

**(1) How much does the measured triple actually determine?**  The 1.5B curve is
a *hinge* `max 16 (base + slope·j)`.  `hingeFits_iff` characterises all hinges
through the measured points `16, 16, 18`, and the answer is uncomfortable:
`hingeFits_slope_ge_two` shows the data only force `slope ≥ 2`, and
`hingeFits_alternative` exhibits a genuinely different fit (`base = 12`,
`slope = 3`).  So the advertised `+2` is a **lower bound**, not a measurement.
`hinge_prediction_discriminates` shows the two fits separate at the very next
octave (`20` versus `21` keys at `4096`), which is exactly the experiment to run.

**(2) Why did NET-66 read `20` where NET-67 reads `18`?**  Because a knee read
on a coarse grid is the least *grid point* above the true knee.  `kneeMul` is
the grid-restricted knee and `kneeMul_bounds` proves the two-sided estimate
`knee ≤ kneeMul < knee + d`.  `coarse_grid_reads_twenty` realises the NET-66/67
discrepancy exactly: a profile whose true knee is `18` is read as `20` on the
spacing-`4` grid, and the error is provably below the spacing.

**(3) Does the halving extrapolate to 7B?**  Cycle 1 calibrated the peakedness
of the two models to `λ₀ = 1` and `λ₀ = 2` at parameter counts `0.5B` and
`1.5B`, i.e. `λ₀(N) = (2N)^θ` with `θ = log 2 / log 3`.  The induced increment
law `incrAt N = 4·(2N)^(-θ)` reproduces both measurements
(`incrAt_half`, `incrAt_three_halves`), is strictly decreasing
(`incrAt_strictAntiOn`), and has an **exact closed-form threshold**:
`incrAt N < 1 ↔ 4.5 < N` (`incrAt_lt_one_iff`).  Hence
`scale_threshold_four_point_five`: *a model above 4.5B parameters needs less
than one extra key per context doubling* — its attention budget is essentially
context-free.  For the proposed 7B cell the prediction is bracketed exactly:
`1/2 < incrAt 7 < 1` (`prediction_7B`).
-/

namespace Catalog.Novelty.AttentionScaleThreshold

open Catalog.Novelty.AttentionBudgetIncrement Catalog.Novelty.AttentionRetentionKnee

/-! ### 1. Hinges: what the measured triple does and does not determine -/

/-- A *hinge* budget law: a floor (the minimum viable key count) below which the
affine demand `base + slope·j` is invisible. -/
def hinge (floor base slope j : ℕ) : ℕ := max floor (base + slope * j)

/-- The 1.5B law of cycle 1 is the hinge with floor `16`, base `14`, slope `2`. -/
theorem kneeLarge_eq_hinge : kneeLarge = hinge 16 14 2 := by
  funext j
  simp [kneeLarge, hinge, Nat.mul_comm]

/-- Every hinge is discretely convex: its increments never decrease. -/
theorem hinge_convex (floor base slope j : ℕ) :
    2 * hinge floor base slope (j + 1) ≤
      hinge floor base slope j + hinge floor base slope (j + 2) := by
  have e1 : slope * (j + 1) = slope * j + slope := by ring
  have e2 : slope * (j + 2) = slope * j + 2 * slope := by ring
  simp only [hinge, e1, e2]
  omega

/-- The measured 1.5B triple `16, 16, 18`, as a constraint on hinge parameters
with the measured floor `16`. -/
def HingeFits (base slope : ℕ) : Prop :=
  hinge 16 base slope 0 = 16 ∧ hinge 16 base slope 1 = 16 ∧ hinge 16 base slope 2 = 18

/-- Explicit description of all hinges through the measured points. -/
theorem hingeFits_iff (base slope : ℕ) :
    HingeFits base slope ↔ (base + 2 * slope = 18 ∧ base + slope ≤ 16) := by
  simp only [HingeFits, hinge]
  omega

/-- **The measured `+2` is only a lower bound.**  Every hinge through the
measured triple has slope at least `2` … -/
theorem hingeFits_slope_ge_two {base slope : ℕ} (h : HingeFits base slope) : 2 ≤ slope := by
  rw [hingeFits_iff] at h; omega

/-- … and at most `9`, so the measurement pins the slope only to `[2, 9]`. -/
theorem hingeFits_slope_le_nine {base slope : ℕ} (h : HingeFits base slope) : slope ≤ 9 := by
  rw [hingeFits_iff] at h; omega

/-- The parsimonious fit: slope `2`, the reading of NET-67. -/
theorem hingeFits_canonical : HingeFits 14 2 := by rw [hingeFits_iff]; omega

/-- A genuinely different fit through the *same* three measured points. -/
theorem hingeFits_alternative : HingeFits 12 3 := by rw [hingeFits_iff]; omega

/-- Given the slope, the base is determined. -/
theorem hingeFits_base_unique {base base' slope : ℕ}
    (h : HingeFits base slope) (h' : HingeFits base' slope) : base = base' := by
  rw [hingeFits_iff] at h h'; omega

/-- **The discriminating experiment.**  The two admissible fits agree on all
three measured points but disagree at the next octave (`ctx = 4096`, `j = 3`):
`20` keys versus `21`.  One measurement at `4096` decides the slope. -/
theorem hinge_prediction_discriminates :
    hinge 16 14 2 3 = 20 ∧ hinge 16 12 3 3 = 21 ∧
      hinge 16 14 2 3 ≠ hinge 16 12 3 3 := by
  refine ⟨by decide, by decide, by decide⟩

/-! ### 2. Grid resolution: why a coarse sweep over-reads the knee -/

/-- The knee as measured on the grid of multiples of `d`. -/
noncomputable def kneeMul (p : ℕ → ℝ) (tau : ℝ) (d : ℕ) : ℕ :=
  sInf {k | d ∣ k ∧ tau ≤ retained p k}

/-- Between `n` and `n + d` there is always a multiple of `d`. -/
theorem exists_multiple_between (d n : ℕ) (hd : 0 < d) :
    ∃ k, d ∣ k ∧ n ≤ k ∧ k < n + d := by
  have hne : {m : ℕ | n ≤ d * m}.Nonempty := ⟨n, Nat.le_mul_of_pos_left n hd⟩
  have hmem : n ≤ d * sInf {m : ℕ | n ≤ d * m} := Nat.sInf_mem hne
  refine ⟨d * sInf {m : ℕ | n ≤ d * m}, ⟨_, rfl⟩, hmem, ?_⟩
  rcases Nat.eq_zero_or_pos (sInf {m : ℕ | n ≤ d * m}) with h | h
  · rw [h] at hmem ⊢
    simp only [Nat.mul_zero] at hmem ⊢
    omega
  · obtain ⟨m', hm'⟩ := Nat.exists_eq_succ_of_ne_zero h.ne'
    have hlt : d * m' < n := by
      by_contra hle
      have hmem' : m' ∈ {m : ℕ | n ≤ d * m} := not_lt.mp hle
      have := Nat.sInf_le hmem'
      omega
    calc d * sInf {m : ℕ | n ≤ d * m} = d * m' + d := by
          rw [hm', Nat.succ_eq_add_one]; ring
      _ < n + d := by omega

/-- **Grid resolution bound.**  A knee measured on the spacing-`d` grid is never
below the true knee, and never more than `d - 1` above it. -/
theorem kneeMul_bounds {p : ℕ → ℝ} (hp : ∀ i, 0 ≤ p i) (tau : ℝ) {d : ℕ} (hd : 0 < d)
    (hex : ∃ k, tau ≤ retained p k) :
    knee p tau ≤ kneeMul p tau d ∧ kneeMul p tau d < knee p tau + d := by
  obtain ⟨k, hdvd, hk1, hk2⟩ := exists_multiple_between d (knee p tau) hd
  have hmemk : tau ≤ retained p k := (knee_spec hex).trans (retained_mono hp hk1)
  have hne : {k | d ∣ k ∧ tau ≤ retained p k}.Nonempty := ⟨k, hdvd, hmemk⟩
  constructor
  · exact knee_le (Nat.sInf_mem hne).2
  · exact lt_of_le_of_lt (Nat.sInf_le ⟨hdvd, hmemk⟩) hk2

/-- The flat profile: every key carries weight `1`, so `retained k = k`.
It is the cleanest test object for a knee measurement. -/
theorem retained_one (k : ℕ) : retained (fun _ => (1 : ℝ)) k = k := by
  simp [retained]

/-- **The NET-66 / NET-67 discrepancy, exactly.**  For a profile whose true knee
is `18`, a sweep restricted to the spacing-`4` grid `{16, 20, 24, …}` reports
`20` — one grid point high, precisely the coarse read that NET-67's two-point
addendum corrected.  The over-read is `2 < 4`, inside the resolution bound. -/
theorem coarse_grid_reads_twenty :
    knee (fun _ => (1 : ℝ)) 18 = 18 ∧ kneeMul (fun _ => (1 : ℝ)) 18 4 = 20 := by
  have hset : {k : ℕ | (18 : ℝ) ≤ retained (fun _ => (1 : ℝ)) k} = {k : ℕ | 18 ≤ k} := by
    ext k
    simp [retained_one, Nat.ofNat_le_cast]
  have hset' : {k : ℕ | 4 ∣ k ∧ (18 : ℝ) ≤ retained (fun _ => (1 : ℝ)) k}
      = {k : ℕ | 4 ∣ k ∧ 18 ≤ k} := by
    ext k
    simp [retained_one, Nat.ofNat_le_cast]
  constructor
  · rw [knee, hset]
    apply le_antisymm
    · exact Nat.sInf_le (by simp)
    · exact le_csInf ⟨18, by simp⟩ fun b hb => hb
  · rw [kneeMul, hset']
    apply le_antisymm
    · exact Nat.sInf_le ⟨by norm_num, by norm_num⟩
    · refine le_csInf ⟨20, ⟨by norm_num, by norm_num⟩⟩ ?_
      rintro b ⟨hdvd, hb⟩
      obtain ⟨c, rfl⟩ := hdvd
      omega

/-! ### 3. The scale exponent and the context-free threshold -/

/-- The scale exponent calibrated by the two measured cells: peakedness `λ₀`
grows like `N^θ` in the parameter count, and `λ₀` doubles from `0.5B` to `1.5B`,
so `3^θ = 2`. -/
noncomputable def theta : ℝ := Real.log 2 / Real.log 3

theorem theta_pos : 0 < theta :=
  div_pos (Real.log_pos (by norm_num)) (Real.log_pos (by norm_num))

/-- The defining property of the exponent: `3^θ = 2`. -/
theorem three_rpow_theta : (3 : ℝ) ^ theta = 2 := by
  have hlog3 : Real.log 3 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  rw [Real.rpow_def_of_pos (by norm_num : (0:ℝ) < 3), theta, mul_div_assoc']
  rw [mul_comm, mul_div_assoc, div_self hlog3, mul_one]
  exact Real.exp_log (by norm_num)

/-- Powers of `3` are sent to powers of `2`. -/
theorem three_pow_rpow_theta (n : ℕ) : ((3 : ℝ) ^ n) ^ theta = 2 ^ n := by
  induction n with
  | zero => simp [Real.one_rpow]
  | succ m ih =>
      have h3 : (0 : ℝ) ≤ (3 : ℝ) ^ m := by positivity
      rw [pow_succ, Real.mul_rpow h3 (by norm_num), ih, three_rpow_theta, pow_succ]

/-- Peakedness of a model with `N` billion parameters, calibrated so that
`λ₀(0.5) = 1` and `λ₀(1.5) = 2`. -/
noncomputable def lam0Of (N : ℝ) : ℝ := (2 * N) ^ theta

/-- Predicted keys-per-doubling increment at parameter count `N` (in billions):
the cycle-1 increment `log(1/δ)/λ₀` at tail budget `δ = e⁻⁴`. -/
noncomputable def incrAt (N : ℝ) : ℝ := 4 * (2 * N) ^ (-theta)

/-- The prediction is exactly the cycle-1 increment law at the calibrated
peakedness — the two cycles are one model. -/
theorem incrAt_eq_kneeCts {N : ℝ} (hN : 0 < N) :
    incrAt N = kneeCts (lam0Of N) (Real.exp (-4)) := by
  have h2N : (0 : ℝ) < 2 * N := by linarith
  have hpow : (0 : ℝ) < (2 * N) ^ theta := Real.rpow_pos_of_pos h2N theta
  rw [incrAt, kneeCts, lam0Of, Real.rpow_neg h2N.le, one_div, ← Real.exp_neg, Real.log_exp]
  field_simp

/-- Calibration at `0.5B`: the measured `+4` keys per doubling. -/
theorem incrAt_half : incrAt 0.5 = 4 := by
  rw [incrAt]
  norm_num [Real.one_rpow]

/-- Calibration at `1.5B`: the measured `+2` keys per doubling. -/
theorem incrAt_three_halves : incrAt 1.5 = 2 := by
  have h3 : (2 : ℝ) * 1.5 = 3 := by norm_num
  rw [incrAt, h3, Real.rpow_neg (by norm_num), three_rpow_theta]
  norm_num

/-- The increment law is strictly decreasing in model size. -/
theorem incrAt_strictAntiOn : StrictAntiOn incrAt (Set.Ioi (0 : ℝ)) := by
  intro a ha b hb hab
  have ha' : (0 : ℝ) < 2 * a := by simp only [Set.mem_Ioi] at ha; linarith
  have hlt : (2 : ℝ) * a < 2 * b := by linarith
  have h := Real.rpow_lt_rpow_of_neg ha' hlt (neg_neg_iff_pos.2 theta_pos)
  simp only [incrAt]
  linarith

/-- The exact threshold value: at `4.5B` parameters the predicted increment is
exactly one key per doubling. -/
theorem incrAt_threshold : incrAt 4.5 = 1 := by
  have h9 : (2 : ℝ) * 4.5 = 3 ^ 2 := by norm_num
  have hpow : ((3 : ℝ) ^ (2 : ℕ)) ^ theta = 2 ^ (2 : ℕ) := three_pow_rpow_theta 2
  rw [incrAt, h9, Real.rpow_neg (by positivity), hpow]
  norm_num

/-- The half-key threshold: at `13.5B` parameters the predicted increment is
exactly half a key per doubling. -/
theorem incrAt_half_threshold : incrAt 13.5 = 1 / 2 := by
  have h27 : (2 : ℝ) * 13.5 = 3 ^ 3 := by norm_num
  have hpow : ((3 : ℝ) ^ (3 : ℕ)) ^ theta = 2 ^ (3 : ℕ) := three_pow_rpow_theta 3
  rw [incrAt, h27, Real.rpow_neg (by positivity), hpow]
  norm_num

/-- **The context-free threshold, in closed form.**  A model needs less than one
extra key per context doubling exactly when it has more than `4.5B` parameters. -/
theorem incrAt_lt_one_iff {N : ℝ} (hN : 0 < N) : incrAt N < 1 ↔ 4.5 < N := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rcases eq_or_lt_of_le hcon with heq | hlt
    · rw [heq, incrAt_threshold] at h; linarith
    · have := incrAt_strictAntiOn (Set.mem_Ioi.2 hN) (Set.mem_Ioi.2 (by norm_num)) hlt
      rw [incrAt_threshold] at this
      linarith
  · intro h
    have := incrAt_strictAntiOn (Set.mem_Ioi.2 (by norm_num : (0:ℝ) < 4.5))
      (Set.mem_Ioi.2 hN) h
    rw [incrAt_threshold] at this
    linarith

/-- Deployment reading of the threshold. -/
theorem scale_threshold_four_point_five {N : ℝ} (hN : 4.5 < N) : incrAt N < 1 :=
  (incrAt_lt_one_iff (by linarith)).2 hN

/-- **The falsifiable 7B prediction.**  The next cell proposed by NET-67 is
bracketed exactly: between half a key and one key per context doubling.  On an
integer grid that means the 7B knee should move by `0` or `1` key from `2048` to
`4096` — the halving law, extrapolated, predicts a flat cell. -/
theorem prediction_7B : 1 / 2 < incrAt 7 ∧ incrAt 7 < 1 := by
  constructor
  · have := incrAt_strictAntiOn (Set.mem_Ioi.2 (by norm_num : (0:ℝ) < 7))
      (Set.mem_Ioi.2 (by norm_num : (0:ℝ) < 13.5)) (by norm_num)
    rw [incrAt_half_threshold] at this
    linarith
  · exact scale_threshold_four_point_five (by norm_num)

/-- The 7B prediction is strictly below the measured 1.5B increment: the
halving law does not stall. -/
theorem prediction_7B_below_measured : incrAt 7 < incrAt 1.5 := by
  exact incrAt_strictAntiOn (Set.mem_Ioi.2 (by norm_num)) (Set.mem_Ioi.2 (by norm_num))
    (by norm_num)

end Catalog.Novelty.AttentionScaleThreshold