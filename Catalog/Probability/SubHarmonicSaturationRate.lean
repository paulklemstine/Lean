/-
  # The saturation rate below the harmonic exponent

  `Probability.HarmonicBulkSteeperEdge` proves the *saturation dichotomy* for the head
  statistic of a discrete power-law kernel `k ↦ k ^ (-a)` on `{1, …, n}`: the head mass of
  a fixed window `{1, …, m}` tends to a positive limit iff `a > 1`, and collapses to `0`
  for `a ≤ 1`.  `Probability.HarmonicSaturationRate` pins the *rate* of that collapse at
  the harmonic exponent `a = 1`, where it is logarithmic: `headMass 1 n m · log n → H(m)`.

  This file closes the remaining half of the rate question — the *sub-harmonic* regime
  `0 ≤ a < 1`, where the collapse is polynomial rather than logarithmic:

  * `headSum_sandwich_lower` / `headSum_sandwich_upper` — the non-asymptotic two-sided
    bound `((n+1)^{1-a} - 1)/(1-a) ≤ headSum a n ≤ 1 + (n^{1-a} - 1)/(1-a)`, obtained by
    monotone sum/integral comparison for the antitone kernel `x ↦ x^{-a}`.
  * `headSum_div_rpow_tendsto` — consequently `headSum a n / n^{1-a} → 1/(1-a)`.
  * `headMass_mul_rpow_tendsto` — the rate itself:
    `headMass a n m · n^{1-a} → (1-a) · headSum a m`.
  * `headMass_doubling_ratio_tendsto` — the calibration corollary: *doubling* the
    truncation multiplies the dial asymptotically by `2^{a-1}`.  (Contrast the harmonic
    case, where doubling is asymptotically neutral and *squaring* halves the dial.)

  Together with `HarmonicSaturationRate` this fixes the truncation artefact for every
  exponent `a ≤ 1`, so recorded dials taken at different truncations become comparable:
  at `a < 1` the level scales like `n^{a-1}`, at `a = 1` like `1 / log n`, and only for
  `a > 1` does it saturate.
-/
import Mathlib
import Probability.HarmonicBulkSteeperEdge

open Filter Topology

namespace HarmonicBulkSteeperEdge

/-! ## The kernel is antitone on the positive reals -/

/-- For a nonnegative exponent the real kernel `x ↦ x ^ (-a)` is antitone on any interval
contained in the positive reals. -/
lemma antitoneOn_rpow_neg {a : ℝ} (ha : 0 ≤ a) {u v : ℝ} (hu : 0 < u) :
    AntitoneOn (fun x : ℝ => x ^ (-a)) (Set.Icc u v) := by
  intro x hx _ _ hxy
  exact Real.rpow_le_rpow_of_nonpos (lt_of_lt_of_le hu hx.1) hxy (by linarith)

/-! ## Non-asymptotic sandwich for the truncated sum -/

/-- **Lower half of the sandwich.**  Comparing the sum with the integral of the antitone
kernel over `[1, n+1]`. -/
theorem headSum_sandwich_lower {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (n : ℕ) :
    (((n : ℝ) + 1) ^ (1 - a) - 1) / (1 - a) ≤ headSum a n := by
  have hanti : AntitoneOn (fun x : ℝ => x ^ (-a)) (Set.Icc ((1 : ℕ) : ℝ) ((n + 1 : ℕ) : ℝ)) := by
    push_cast
    exact antitoneOn_rpow_neg ha one_pos
  have hkey := AntitoneOn.integral_le_sum_Ico (f := fun x : ℝ => x ^ (-a)) (a := 1) (b := n + 1)
    (by omega) hanti
  rw [integral_rpow (Or.inl (by linarith))] at hkey
  have hsum : ∑ x ∈ Finset.Ico 1 (n + 1), ((x : ℝ)) ^ (-a) = headSum a n := by
    rw [Finset.Ico_add_one_right_eq_Icc]
    rfl
  rw [hsum] at hkey
  push_cast at hkey
  have he : (-a + 1) = 1 - a := by ring
  rw [he] at hkey
  simpa using hkey

/-- **Upper half of the sandwich.**  Comparing the sum, minus its first term, with the
integral of the antitone kernel over `[1, n]`. -/
theorem headSum_sandwich_upper {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) {n : ℕ} (hn : 1 ≤ n) :
    headSum a n ≤ 1 + ((n : ℝ) ^ (1 - a) - 1) / (1 - a) := by
  have hanti : AntitoneOn (fun x : ℝ => x ^ (-a)) (Set.Icc ((1 : ℕ) : ℝ) ((n : ℕ) : ℝ)) := by
    push_cast
    exact antitoneOn_rpow_neg ha one_pos
  have hkey := AntitoneOn.sum_le_integral_Ico (f := fun x : ℝ => x ^ (-a)) (a := 1) (b := n)
    hn hanti
  rw [integral_rpow (Or.inl (by linarith))] at hkey
  have hre : ∑ i ∈ Finset.Ico 1 n, ((((i + 1 : ℕ)) : ℝ)) ^ (-a) = headSum a n - 1 := by
    have h1 : ∑ i ∈ Finset.Ico 1 n, ((((i + 1 : ℕ)) : ℝ)) ^ (-a)
        = ∑ i ∈ Finset.Ico 2 (n + 1), ((i : ℝ)) ^ (-a) := by
      rw [← Finset.sum_Ico_add' (fun i : ℕ => ((i : ℝ)) ^ (-a)) 1 n 1]
    rw [h1, Finset.Ico_add_one_right_eq_Icc]
    have h2 : Finset.Icc 1 n = insert 1 (Finset.Icc 2 n) := by
      ext k
      simp only [Finset.mem_Icc, Finset.mem_insert]
      omega
    rw [headSum, h2, Finset.sum_insert (by simp)]
    simp [pw]
  rw [hre] at hkey
  push_cast at hkey
  have he : (-a + 1) = 1 - a := by ring
  rw [he] at hkey
  simp only [Real.one_rpow] at hkey
  linarith

/-! ## The polynomial rate -/

/-- **The truncated sub-harmonic sum is asymptotically `n^{1-a}/(1-a)`.** -/
theorem headSum_div_rpow_tendsto {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) :
    Tendsto (fun n : ℕ => headSum a n / (n : ℝ) ^ (1 - a)) atTop (𝓝 (1 / (1 - a))) := by
  set t : ℝ := 1 - a with hti
  have ht : 0 < t := by rw [hti]; linarith
  have hinv : Tendsto (fun n : ℕ => ((n : ℝ) ^ t)⁻¹) atTop (𝓝 0) := by
    have h1 : Tendsto (fun n : ℕ => (n : ℝ) ^ t) atTop atTop :=
      (tendsto_rpow_atTop ht).comp tendsto_natCast_atTop_atTop
    exact tendsto_inv_atTop_zero.comp h1
  have hone : Tendsto (fun n : ℕ => (1 + ((n : ℝ))⁻¹) ^ t) atTop (𝓝 1) := by
    have h0 : Tendsto (fun n : ℕ => 1 + ((n : ℝ))⁻¹) atTop (𝓝 1) := by
      have := tendsto_inv_atTop_zero.comp (tendsto_natCast_atTop_atTop (R := ℝ))
      simpa using this.const_add 1
    have hc : ContinuousAt (fun x : ℝ => x ^ t) 1 :=
      Real.continuousAt_rpow_const 1 t (Or.inl one_ne_zero)
    simpa using hc.tendsto.comp h0
  have hlow :
      Tendsto (fun n : ℕ => ((1 + ((n : ℝ))⁻¹) ^ t - ((n : ℝ) ^ t)⁻¹) / t) atTop (𝓝 (1 / t)) := by
    have := (hone.sub hinv).div_const t
    simpa using this
  have hup :
      Tendsto (fun n : ℕ => ((n : ℝ) ^ t)⁻¹ + (1 - ((n : ℝ) ^ t)⁻¹) / t) atTop (𝓝 (1 / t)) := by
    have := hinv.add
      (((tendsto_const_nhds (x := (1 : ℝ)) (f := atTop (α := ℕ))).sub hinv).div_const t)
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hup ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    have hnt : (0 : ℝ) < (n : ℝ) ^ t := Real.rpow_pos_of_pos hn0 t
    have hrat : ((n : ℝ) + 1) ^ t / (n : ℝ) ^ t = (1 + ((n : ℝ))⁻¹) ^ t := by
      rw [← Real.div_rpow (by linarith) hn0.le]
      congr 1
      field_simp
    have hL := headSum_sandwich_lower ha ha1 n
    rw [← hti] at hL
    have key : ((1 + ((n : ℝ))⁻¹) ^ t - ((n : ℝ) ^ t)⁻¹) / t
        = ((((n : ℝ) + 1) ^ t - 1) / t) / (n : ℝ) ^ t := by
      rw [← hrat]; field_simp
    rw [key]
    gcongr
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    have hnt : (0 : ℝ) < (n : ℝ) ^ t := Real.rpow_pos_of_pos hn0 t
    have hU := headSum_sandwich_upper ha ha1 hn
    rw [← hti] at hU
    have key : ((n : ℝ) ^ t)⁻¹ + (1 - ((n : ℝ) ^ t)⁻¹) / t
        = (1 + (((n : ℝ) ^ t - 1) / t)) / (n : ℝ) ^ t := by
      field_simp
    rw [key]
    gcongr

/-- **Sub-harmonic saturation rate.**  For `0 ≤ a < 1` the head dial of a fixed window
`{1, …, m}` collapses at the polynomial rate `n^{a-1}`, with the explicit constant
`(1 - a) · headSum a m`. -/
theorem headMass_mul_rpow_tendsto {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) (m : ℕ) :
    Tendsto (fun n : ℕ => headMass a n m * (n : ℝ) ^ (1 - a)) atTop
      (𝓝 ((1 - a) * headSum a m)) := by
  have ht : (0 : ℝ) < 1 - a := by linarith
  have hne : (1 : ℝ) / (1 - a) ≠ 0 := by positivity
  have hdiv :
      Tendsto (fun n : ℕ => headSum a m / (headSum a n / (n : ℝ) ^ (1 - a))) atTop
        (𝓝 (headSum a m / (1 / (1 - a)))) :=
    tendsto_const_nhds.div (headSum_div_rpow_tendsto ha ha1) hne
  have hlim : headSum a m / (1 / (1 - a)) = (1 - a) * headSum a m := by
    field_simp
  rw [hlim] at hdiv
  refine hdiv.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hnt : (0 : ℝ) ≠ (n : ℝ) ^ (1 - a) := ne_of_lt (Real.rpow_pos_of_pos hn0 _)
  have hsn : headSum a n ≠ 0 := ne_of_gt (headSum_pos hn)
  rw [headMass]
  field_simp

/-- **Calibration corollary: doubling the truncation.**  In the sub-harmonic regime the
dial is *not* saturating and doubling the truncation multiplies it asymptotically by
`2^{a-1} < 1`.  (At the harmonic exponent doubling is asymptotically neutral; a positive
limit under doubling would force `a > 1`.) -/
theorem headMass_doubling_ratio_tendsto {a : ℝ} (ha : 0 ≤ a) (ha1 : a < 1) {m : ℕ}
    (hm : 1 ≤ m) :
    Tendsto (fun n : ℕ => headMass a (2 * n) m / headMass a n m) atTop
      (𝓝 ((2 : ℝ) ^ (a - 1))) := by
  have ht : (0 : ℝ) < 1 - a := by linarith
  have hc : (0 : ℝ) < (1 - a) * headSum a m := by
    have := headSum_pos (a := a) hm
    positivity
  -- the numerator, rescaled at truncation `2n`
  have hnum : Tendsto (fun n : ℕ => headMass a (2 * n) m * ((2 * n : ℕ) : ℝ) ^ (1 - a)) atTop
      (𝓝 ((1 - a) * headSum a m)) := by
    have hmono : Tendsto (fun n : ℕ => 2 * n) atTop atTop :=
      Filter.tendsto_atTop_atTop.2 (fun b => ⟨b, fun n hn => by omega⟩)
    exact (headMass_mul_rpow_tendsto ha ha1 m).comp hmono
  have hden := headMass_mul_rpow_tendsto ha ha1 m
  have hquot :
      Tendsto (fun n : ℕ => (headMass a (2 * n) m * ((2 * n : ℕ) : ℝ) ^ (1 - a))
        / (headMass a n m * (n : ℝ) ^ (1 - a))) atTop (𝓝 1) := by
    have h := hnum.div hden (ne_of_gt hc)
    rw [div_self (ne_of_gt hc)] at h
    exact h
  have hscaled :
      Tendsto (fun n : ℕ => ((headMass a (2 * n) m * ((2 * n : ℕ) : ℝ) ^ (1 - a))
        / (headMass a n m * (n : ℝ) ^ (1 - a))) * (2 : ℝ) ^ (a - 1)) atTop
        (𝓝 ((2 : ℝ) ^ (a - 1))) := by
    have := hquot.mul_const ((2 : ℝ) ^ (a - 1))
    simpa using this
  refine hscaled.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with n hn
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hnt : (0 : ℝ) < (n : ℝ) ^ (1 - a) := Real.rpow_pos_of_pos hn0 _
  have h2n : ((2 * n : ℕ) : ℝ) ^ (1 - a) = (2 : ℝ) ^ (1 - a) * (n : ℝ) ^ (1 - a) := by
    push_cast
    rw [Real.mul_rpow (by norm_num) hn0.le]
  have hpow : (2 : ℝ) ^ (1 - a) * (2 : ℝ) ^ (a - 1) = 1 := by
    rw [← Real.rpow_add (by norm_num)]
    norm_num
  have hmpos : 0 < headMass a n m := by
    rw [headMass]
    exact div_pos (headSum_pos hm) (headSum_pos hn)
  rw [h2n]
  field_simp
  rw [mul_assoc, hpow, mul_one]

end HarmonicBulkSteeperEdge