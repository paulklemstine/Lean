import Novelty.CollatzSpectralUniform

/-!
# The two-step spectrum of the `a n + 1` maps: resonances are destroyed by iteration

This file continues the spectral programme of
`Catalog/Novelty/CollatzSpectralNormalized.lean` and
`Catalog/Novelty/CollatzSpectralUniform.lean`.

For an odd multiplier `a` the one-step phase ratio `ratio a n = step a n / n` takes
the two values `1/2` (even branch, density `1/2`) and `a + 1/n` (odd branch,
density `1/2`).  Because the two densities are *equal*, the limiting amplitude
`limitAmp a ω = (e(ω/2) + e(aω))/2` can vanish, and it does so exactly on the
resonance set `{ω : (2a-1)ω ∈ 2ℤ+1}`.  That perfect balance is the source of
every "spectral gap" of the one-step transform.

Here we compute the **two-step** spectrum, i.e. the transform built from
`ratio2 a n = step a (step a n) / n`.  A Terras-style parity analysis modulo `4`
gives three branches

* `n ≡ 0 (mod 4)`: `ratio2 = 1/4`                (density `1/4`),
* `n ≡ 2 (mod 4)`: `ratio2 = a/2 + 1/n`          (density `1/4`),
* `n` odd        : `ratio2 = a/2 + 1/(2n)`       (density `1/2`),

so the *two* limiting phases carry the **unbalanced** weights `1/4` and `3/4`:

`limitAmp2 a ω = (e(ω/4) + 3 e(aω/2))/4`.

## Main results

* `ratio2_mod_four_zero`, `ratio2_mod_four_two`, `ratio2_odd` — the exact
  three-branch decomposition of the two-step phase ratio (needs `a` odd).
* `norm_F2_div_sub_limitAmp2_le` — the quantitative error bound
  `‖F2 a ω N / N - limitAmp2 a ω‖ ≤ (2 + 2π|ω|(1 + log N))/N`, uniform in `a`
  and locally uniform in `ω`.
* `tendsto_F2_div` — the two-step normalization theorem.
* `norm_limitAmp2_ge_half` — **the two-step transform has no resonances**:
  `‖limitAmp2 a ω‖ ≥ 1/2` for every real frequency `ω`, for every multiplier.
* `norm_limitAmp2_sq` — the exact modulus `‖limitAmp2 a ω‖² = (10 + 6 cos(π(2a-1)ω/2))/16`,
  which shows the bound `1/2` is attained (`norm_limitAmp2_eq_half`).
* `two_step_no_cancellation` — consequently `‖F2 a ω N‖ ≥ N/4` eventually, for
  *every* frequency: the one-step spectral gap is not stable under iteration.
* `resonance_destroyed_by_iteration` — the explicit contrast at `a = 3`,
  `ω = 1/5`: `F 3 (1/5) N = o(N)` but `‖F2 3 (1/5) N‖ ≥ N/4`.
* `meanSquare_limitAmp_period_four`, `meanSquare_limitAmp2_period_four`,
  `meanSquare_strict_mono_in_depth` — the mean-square power over a full period
  is `1/2` at depth one and `5/8` at depth two, for *every* multiplier: an
  averaged statistic that detects the iteration depth but never the multiplier.
-/

namespace CollatzSpectral

open Filter Complex
open scoped Real Topology

/-! ## Elementary character computations -/

lemma E_re (x : ℝ) : (E x).re = Real.cos (2 * Real.pi * x) := by
  have h : (2 : ℂ) * Real.pi * Complex.I * x = ((2 * Real.pi * x : ℝ) : ℂ) * Complex.I := by
    push_cast; ring
  rw [E, h, Complex.exp_ofReal_mul_I_re]

lemma E_im (x : ℝ) : (E x).im = Real.sin (2 * Real.pi * x) := by
  have h : (2 : ℂ) * Real.pi * Complex.I * x = ((2 * Real.pi * x : ℝ) : ℂ) * Complex.I := by
    push_cast; ring
  rw [E, h, Complex.exp_ofReal_mul_I_im]

/-- `‖3 + e(t)‖² = 10 + 6 cos(2π t)`. -/
lemma norm_three_add_E_sq (t : ℝ) : ‖(3 : ℂ) + E t‖ ^ 2 = 10 + 6 * Real.cos (2 * Real.pi * t) := by
  rw [Complex.sq_norm, Complex.normSq_apply]
  simp only [Complex.add_re, Complex.add_im, E_re, E_im]
  have h := Real.sin_sq_add_cos_sq (2 * Real.pi * t)
  simp
  nlinarith [h]

/-- `e(1/2) = -1`. -/
lemma E_half : E (1 / 2 : ℝ) = -1 := by
  have h : (2 : ℂ) * Real.pi * Complex.I * ((1 / 2 : ℝ) : ℂ) = Real.pi * Complex.I := by
    push_cast; ring
  rw [E, h, Complex.exp_pi_mul_I]

/-! ## The two-step map and its phase ratio -/

/-- The two-step accelerated map `step a ∘ step a`. -/
def step2 (a n : ℕ) : ℕ := step a (step a n)

/-- The two-step phase ratio `step²(n)/n`. -/
noncomputable def ratio2 (a n : ℕ) : ℝ := (step2 a n : ℝ) / (n : ℝ)

lemma step_of_even {n : ℕ} (hn : n % 2 = 0) (a : ℕ) : step a n = n / 2 := by
  unfold step; rw [if_pos hn]

lemma step_of_odd {n : ℕ} (hn : n % 2 = 1) (a : ℕ) : step a n = a * n + 1 := by
  unfold step; rw [if_neg (by omega)]

/-- On `n ≡ 0 (mod 4)` the two-step ratio is the constant `1/4`. -/
lemma ratio2_mod_four_zero {n : ℕ} (hn : n % 4 = 0) (hpos : n ≠ 0) (a : ℕ) :
    ratio2 a n = 1 / 4 := by
  have h2 : n % 2 = 0 := by omega
  have h4 : (n / 2) % 2 = 0 := by omega
  have hstep : step2 a n = n / 4 := by
    unfold step2
    rw [step_of_even h2, step_of_even h4, Nat.div_div_eq_div_mul]
  have hmul : n / 4 * 4 = n := Nat.div_mul_cancel (Nat.dvd_of_mod_eq_zero hn)
  have hcast : ((n / 4 : ℕ) : ℝ) * 4 = (n : ℝ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hmul
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratio2
  rw [hstep]
  field_simp
  linarith [hcast]

/-- On `n ≡ 2 (mod 4)` the two-step ratio is `a/2 + 1/n`. -/
lemma ratio2_mod_four_two {n : ℕ} (hn : n % 4 = 2) (a : ℕ) :
    ratio2 a n = (a : ℝ) / 2 + 1 / n := by
  have hpos : n ≠ 0 := by omega
  have h2 : n % 2 = 0 := by omega
  have h4 : (n / 2) % 2 = 1 := by omega
  have hstep : step2 a n = a * (n / 2) + 1 := by
    unfold step2
    rw [step_of_even h2, step_of_odd h4]
  have hmul : n / 2 * 2 = n := Nat.div_mul_cancel (Nat.dvd_of_mod_eq_zero h2)
  have hcast : ((n / 2 : ℕ) : ℝ) * 2 = (n : ℝ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hmul
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratio2
  rw [hstep]
  push_cast
  field_simp
  nlinarith [hcast]

/-- On odd `n` (and odd multiplier `a`) the two-step ratio is `a/2 + 1/(2n)`. -/
lemma ratio2_odd {a n : ℕ} (ha : a % 2 = 1) (hn : n % 2 = 1) :
    ratio2 a n = (a : ℝ) / 2 + 1 / (2 * n) := by
  have hpos : n ≠ 0 := by intro h; simp [h] at hn
  have hev : (a * n + 1) % 2 = 0 := by
    have h := Nat.mul_mod a n 2
    rw [ha, hn] at h
    omega
  have hstep : step2 a n = (a * n + 1) / 2 := by
    unfold step2
    rw [step_of_odd hn, step_of_even hev]
  have hmul : (a * n + 1) / 2 * 2 = a * n + 1 :=
    Nat.div_mul_cancel (Nat.dvd_of_mod_eq_zero hev)
  have hcast : (((a * n + 1) / 2 : ℕ) : ℝ) * 2 = (a : ℝ) * n + 1 := by
    have := congrArg (Nat.cast : ℕ → ℝ) hmul
    push_cast at this
    linarith [this]
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratio2
  rw [hstep]
  field_simp
  nlinarith [hcast]

/-! ## The two-step transform and its model -/

/-- The two-step cutoff transform `F2 a ω N = ∑_{n=1}^{N} e(ω · ratio2 a n)`. -/
noncomputable def F2 (a : ℕ) (ω : ℝ) (N : ℕ) : ℂ :=
  ∑ k ∈ Finset.range N, E (ω * ratio2 a (k + 1))

/-- The limiting two-step amplitude `(e(ω/4) + 3 e(aω/2))/4`.  Note the
**unbalanced** weights `1/4` and `3/4`. -/
noncomputable def limitAmp2 (a : ℕ) (ω : ℝ) : ℂ := (E (ω / 4) + 3 * E ((a : ℝ) * ω / 2)) / 4

/-- The four-periodic model of the two-step summand. -/
noncomputable def model2 (a : ℕ) (ω : ℝ) (k : ℕ) : ℂ :=
  if k % 4 = 3 then E (ω / 4) else E ((a : ℝ) * ω / 2)

/-- The deviation of the summand from the model. -/
noncomputable def dseq2 (a : ℕ) (ω : ℝ) (k : ℕ) : ℂ :=
  E (ω * ratio2 a (k + 1)) - model2 a ω k

lemma norm_dseq2_le {a : ℕ} (ha : a % 2 = 1) (ω : ℝ) (k : ℕ) :
    ‖dseq2 a ω k‖ ≤ 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) := by
  have hk1 : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  have hcast : (((k + 1 : ℕ)) : ℝ) = (k : ℝ) + 1 := by push_cast; ring
  unfold dseq2 model2
  have hcases : k % 4 = 0 ∨ k % 4 = 1 ∨ k % 4 = 2 ∨ k % 4 = 3 := by omega
  rcases hcases with h | h | h | h
  · -- k ≡ 0 : n = k+1 odd
    have hn : (k + 1) % 2 = 1 := by omega
    rw [if_neg (by omega), ratio2_odd ha hn]
    have harg : ω * ((a : ℝ) / 2 + 1 / (2 * ((k + 1 : ℕ) : ℝ)))
        = (a : ℝ) * ω / 2 + ω / (2 * ((k : ℝ) + 1)) := by
      rw [hcast]; field_simp
    rw [harg, E_add]
    have h1 : E ((a : ℝ) * ω / 2) * E (ω / (2 * ((k : ℝ) + 1))) - E ((a : ℝ) * ω / 2)
        = E ((a : ℝ) * ω / 2) * (E (ω / (2 * ((k : ℝ) + 1))) - 1) := by ring
    rw [h1, norm_mul, norm_E, one_mul]
    refine (norm_E_sub_one_le _).trans ?_
    rw [abs_div, abs_of_pos (by positivity : (0:ℝ) < 2 * ((k : ℝ) + 1))]
    have key : 2 * Real.pi * (|ω| / (2 * ((k : ℝ) + 1)))
        = (2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1))) / 2 := by
      field_simp
    rw [key]
    have hnn : 0 ≤ 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) := by positivity
    linarith
  · -- k ≡ 1 : n = k+1 ≡ 2 mod 4
    have hn : (k + 1) % 4 = 2 := by omega
    rw [if_neg (by omega), ratio2_mod_four_two hn]
    have harg : ω * ((a : ℝ) / 2 + 1 / ((k + 1 : ℕ) : ℝ))
        = (a : ℝ) * ω / 2 + ω / ((k : ℝ) + 1) := by
      rw [hcast]; field_simp
    rw [harg, E_add]
    have h1 : E ((a : ℝ) * ω / 2) * E (ω / ((k : ℝ) + 1)) - E ((a : ℝ) * ω / 2)
        = E ((a : ℝ) * ω / 2) * (E (ω / ((k : ℝ) + 1)) - 1) := by ring
    rw [h1, norm_mul, norm_E, one_mul]
    refine (norm_E_sub_one_le _).trans ?_
    rw [abs_div, abs_of_pos hk1]
    have key : 2 * Real.pi * (|ω| / ((k : ℝ) + 1)) = 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) := by
      field_simp
    exact le_of_eq key
  · -- k ≡ 2 : n = k+1 odd
    have hn : (k + 1) % 2 = 1 := by omega
    rw [if_neg (by omega), ratio2_odd ha hn]
    have harg : ω * ((a : ℝ) / 2 + 1 / (2 * ((k + 1 : ℕ) : ℝ)))
        = (a : ℝ) * ω / 2 + ω / (2 * ((k : ℝ) + 1)) := by
      rw [hcast]; field_simp
    rw [harg, E_add]
    have h1 : E ((a : ℝ) * ω / 2) * E (ω / (2 * ((k : ℝ) + 1))) - E ((a : ℝ) * ω / 2)
        = E ((a : ℝ) * ω / 2) * (E (ω / (2 * ((k : ℝ) + 1))) - 1) := by ring
    rw [h1, norm_mul, norm_E, one_mul]
    refine (norm_E_sub_one_le _).trans ?_
    rw [abs_div, abs_of_pos (by positivity : (0:ℝ) < 2 * ((k : ℝ) + 1))]
    have key : 2 * Real.pi * (|ω| / (2 * ((k : ℝ) + 1)))
        = (2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1))) / 2 := by
      field_simp
    rw [key]
    have hnn : 0 ≤ 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) := by positivity
    linarith
  · -- k ≡ 3 : n = k+1 ≡ 0 mod 4, exact
    have hn : (k + 1) % 4 = 0 := by omega
    rw [if_pos h, ratio2_mod_four_zero hn (by omega)]
    have : ω * (1 / 4 : ℝ) = ω / 4 := by ring
    rw [this, sub_self, norm_zero]
    positivity

/-- The counting function of the residue class `3 (mod 4)`. -/
lemma card_mod_four_three (n : ℕ) :
    ((Finset.range n).filter (fun k => k % 4 = 3)).card = n / 4 := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : m % 4 = 3
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]; omega
    · rw [if_neg h, ih]; omega

/-- Exact decomposition of the two-step partial sum. -/
lemma F2_eq (a : ℕ) (ω : ℝ) (N : ℕ) :
    F2 a ω N = ((N / 4 : ℕ) : ℂ) * E (ω / 4)
      + ((N - N / 4 : ℕ) : ℂ) * E ((a : ℝ) * ω / 2)
      + ∑ k ∈ Finset.range N, dseq2 a ω k := by
  classical
  have hsplit : F2 a ω N
      = ∑ k ∈ Finset.range N, model2 a ω k + ∑ k ∈ Finset.range N, dseq2 a ω k := by
    unfold F2 dseq2
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun k _ => by ring)
  have hmodel : ∑ k ∈ Finset.range N, model2 a ω k
      = ((N / 4 : ℕ) : ℂ) * E (ω / 4) + ((N - N / 4 : ℕ) : ℂ) * E ((a : ℝ) * ω / 2) := by
    unfold model2
    rw [← Finset.sum_filter_add_sum_filter_not (Finset.range N) (fun k => k % 4 = 3)]
    have h1 : ∑ k ∈ (Finset.range N).filter (fun k => k % 4 = 3),
        (if k % 4 = 3 then E (ω / 4) else E ((a : ℝ) * ω / 2))
        = ((Finset.range N).filter (fun k => k % 4 = 3)).card • E (ω / 4) := by
      rw [← Finset.sum_const]
      exact Finset.sum_congr rfl (fun k hk => by rw [if_pos (Finset.mem_filter.mp hk).2])
    have h2 : ∑ k ∈ (Finset.range N).filter (fun k => ¬ k % 4 = 3),
        (if k % 4 = 3 then E (ω / 4) else E ((a : ℝ) * ω / 2))
        = ((Finset.range N).filter (fun k => ¬ k % 4 = 3)).card • E ((a : ℝ) * ω / 2) := by
      rw [← Finset.sum_const]
      exact Finset.sum_congr rfl (fun k hk => by rw [if_neg (Finset.mem_filter.mp hk).2])
    have hc1 : ((Finset.range N).filter (fun k => k % 4 = 3)).card = N / 4 :=
      card_mod_four_three N
    have hc2 : ((Finset.range N).filter (fun k => ¬ k % 4 = 3)).card = N - N / 4 := by
      have := Finset.card_filter_add_card_filter_not
        (s := Finset.range N) (p := fun k => k % 4 = 3)
      rw [Finset.card_range, hc1] at this
      omega
    rw [h1, h2, hc1, hc2, nsmul_eq_mul, nsmul_eq_mul]
  rw [hsplit, hmodel]

/-! ## The quantitative two-step normalization theorem -/

/-- **Explicit two-step error bound.** -/
theorem norm_F2_div_sub_limitAmp2_le {a : ℕ} (ha : a % 2 = 1) (ω : ℝ) {N : ℕ} (hN : 1 ≤ N) :
    ‖F2 a ω N / (N : ℂ) - limitAmp2 a ω‖
      ≤ (2 + 2 * Real.pi * |ω| * (1 + Real.log N)) / N := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
  have hNc : (N : ℂ) ≠ 0 := by simp only [ne_eq, Nat.cast_eq_zero]; omega
  set q : ℕ := N / 4 with hq
  have hqbounds : 4 * q ≤ N ∧ N ≤ 4 * q + 3 := by omega
  have hqR : (4 : ℝ) * (q : ℝ) ≤ (N : ℝ) ∧ (N : ℝ) ≤ 4 * (q : ℝ) + 3 := by
    constructor
    · exact_mod_cast hqbounds.1
    · exact_mod_cast hqbounds.2
  have hsubcast : (((N - q : ℕ)) : ℝ) = (N : ℝ) - (q : ℝ) := by
    have : q ≤ N := by omega
    push_cast [Nat.cast_sub this]
    ring
  -- decomposition
  have hdec : F2 a ω N / (N : ℂ) - limitAmp2 a ω
      = (((q : ℂ) / (N : ℂ) - 1 / 4) * E (ω / 4)
        + (((N - q : ℕ) : ℂ) / (N : ℂ) - 3 / 4) * E ((a : ℝ) * ω / 2))
        + (∑ k ∈ Finset.range N, dseq2 a ω k) / (N : ℂ) := by
    rw [F2_eq, limitAmp2]
    field_simp
    ring
  -- the two counting errors
  have he1 : ‖((q : ℂ) / (N : ℂ) - 1 / 4) * E (ω / 4)‖ ≤ 3 / (4 * N) := by
    rw [norm_mul, norm_E, mul_one]
    have : ((q : ℂ) / (N : ℂ) - 1 / 4) = (((4 * (q : ℝ) - N) / (4 * N) : ℝ) : ℂ) := by
      push_cast
      field_simp
    rw [this, Complex.norm_real, Real.norm_eq_abs, abs_div,
      abs_of_pos (by positivity : (0:ℝ) < 4 * (N:ℝ))]
    rw [div_le_div_iff_of_pos_right (by positivity : (0:ℝ) < 4 * (N:ℝ))]
    rw [abs_le]; constructor <;> linarith [hqR.1, hqR.2]
  have he2 : ‖(((N - q : ℕ) : ℂ) / (N : ℂ) - 3 / 4) * E ((a : ℝ) * ω / 2)‖ ≤ 3 / (4 * N) := by
    rw [norm_mul, norm_E, mul_one]
    have hcc : (((N - q : ℕ)) : ℂ) = ((N : ℝ) - (q : ℝ) : ℝ) := by
      rw [← hsubcast]; push_cast; ring
    have : (((N - q : ℕ) : ℂ) / (N : ℂ) - 3 / 4)
        = (((N - 4 * (q : ℝ)) / (4 * N) : ℝ) : ℂ) := by
      rw [hcc]
      push_cast
      field_simp
      ring
    rw [this, Complex.norm_real, Real.norm_eq_abs, abs_div,
      abs_of_pos (by positivity : (0:ℝ) < 4 * (N:ℝ))]
    rw [div_le_div_iff_of_pos_right (by positivity : (0:ℝ) < 4 * (N:ℝ))]
    rw [abs_le]; constructor <;> linarith [hqR.1, hqR.2]
  -- the deviation sum
  have hsum : ‖∑ k ∈ Finset.range N, dseq2 a ω k‖ ≤ 2 * Real.pi * |ω| * (1 + Real.log N) := by
    refine (norm_sum_le _ _).trans ?_
    have hterm : ∑ k ∈ Finset.range N, ‖dseq2 a ω k‖
        ≤ ∑ k ∈ Finset.range N, 2 * Real.pi * |ω| * (1 / ((k : ℝ) + 1)) :=
      Finset.sum_le_sum (fun k _ => norm_dseq2_le ha ω k)
    refine hterm.trans ?_
    rw [← Finset.mul_sum]
    exact mul_le_mul_of_nonneg_left (sum_one_div_le_one_add_log N) (by positivity)
  have he3 : ‖(∑ k ∈ Finset.range N, dseq2 a ω k) / (N : ℂ)‖
      ≤ (2 * Real.pi * |ω| * (1 + Real.log N)) / N := by
    rw [norm_div, Complex.norm_natCast, div_le_div_iff_of_pos_right hN0]
    exact hsum
  rw [hdec]
  have htri := norm_add_le
    (((q : ℂ) / (N : ℂ) - 1 / 4) * E (ω / 4)
      + (((N - q : ℕ) : ℂ) / (N : ℂ) - 3 / 4) * E ((a : ℝ) * ω / 2))
    ((∑ k ∈ Finset.range N, dseq2 a ω k) / (N : ℂ))
  have htri2 := norm_add_le
    (((q : ℂ) / (N : ℂ) - 1 / 4) * E (ω / 4))
    ((((N - q : ℕ) : ℂ) / (N : ℂ) - 3 / 4) * E ((a : ℝ) * ω / 2))
  have hfin : (3 : ℝ) / (4 * N) + 3 / (4 * N) + (2 * Real.pi * |ω| * (1 + Real.log N)) / N
      ≤ (2 + 2 * Real.pi * |ω| * (1 + Real.log N)) / N := by
    have hrw : (3 : ℝ) / (4 * N) + 3 / (4 * N) + (2 * Real.pi * |ω| * (1 + Real.log N)) / N
        = (3 / 2 + 2 * Real.pi * |ω| * (1 + Real.log N)) / N := by
      field_simp
      ring
    rw [hrw, div_le_div_iff_of_pos_right hN0]
    linarith
  linarith [htri, htri2, he1, he2, he3]

/-- The two-step error bound tends to `0`. -/
lemma tendsto_errorBound2 (M : ℝ) :
    Tendsto (fun N : ℕ => (2 + 2 * Real.pi * M * (1 + Real.log N)) / N) atTop (𝓝 0) := by
  have h1 := tendsto_errorBound M
  have h2 := tendsto_const_div_atTop_nhds_zero_nat (1 : ℝ)
  have h3 := h1.add h2
  rw [add_zero] at h3
  refine h3.congr (fun N => ?_)
  by_cases hN : (N : ℝ) = 0
  · simp [hN]
  · field_simp
    ring

/-- **Two-step normalization theorem.** -/
theorem tendsto_F2_div {a : ℕ} (ha : a % 2 = 1) (ω : ℝ) :
    Tendsto (fun N : ℕ => F2 a ω N / (N : ℂ)) atTop (𝓝 (limitAmp2 a ω)) := by
  rw [← tendsto_sub_nhds_zero_iff]
  refine squeeze_zero_norm' ?_ (tendsto_errorBound2 |ω|)
  filter_upwards [eventually_ge_atTop 1] with N hN
  exact norm_F2_div_sub_limitAmp2_le ha ω hN

/-! ## The two-step amplitude never vanishes -/

/-- **No two-step resonances.**  For every multiplier and every real frequency the
two-step amplitude has modulus at least `1/2`.  The unbalanced branch weights
`1/4, 3/4` make destructive interference impossible. -/
theorem norm_limitAmp2_ge_half (a : ℕ) (ω : ℝ) : (1 : ℝ) / 2 ≤ ‖limitAmp2 a ω‖ := by
  have hsplit : limitAmp2 a ω = E (ω / 4) * (1 + 3 * E ((a : ℝ) * ω / 2 - ω / 4)) / 4 := by
    unfold limitAmp2
    have : E ((a : ℝ) * ω / 2) = E (ω / 4) * E ((a : ℝ) * ω / 2 - ω / 4) := by
      rw [← E_add]; ring_nf
    rw [this]; ring
  rw [hsplit, norm_div, norm_mul, norm_E, one_mul]
  have h1 : (3 : ℝ) - 1 ≤ ‖(1 : ℂ) + 3 * E ((a : ℝ) * ω / 2 - ω / 4)‖ := by
    have h3 : ‖(3 : ℂ) * E ((a : ℝ) * ω / 2 - ω / 4)‖ = 3 := by
      rw [norm_mul, norm_E, mul_one]; norm_num
    have := norm_sub_norm_le ((3 : ℂ) * E ((a : ℝ) * ω / 2 - ω / 4)) (-1 : ℂ)
    have hrw : (3 : ℂ) * E ((a : ℝ) * ω / 2 - ω / 4) - (-1) =
        1 + 3 * E ((a : ℝ) * ω / 2 - ω / 4) := by ring
    rw [hrw, h3] at this
    simpa using this
  have h4 : ‖(4 : ℂ)‖ = 4 := by norm_num
  rw [h4]
  linarith

/-- The exact squared modulus of the two-step amplitude. -/
theorem norm_limitAmp2_sq (a : ℕ) (ω : ℝ) :
    ‖limitAmp2 a ω‖ ^ 2 = (10 + 6 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω / 2)) / 16 := by
  have hsplit : limitAmp2 a ω = E ((a : ℝ) * ω / 2) * (3 + E (ω / 4 - (a : ℝ) * ω / 2)) / 4 := by
    unfold limitAmp2
    have : E (ω / 4) = E ((a : ℝ) * ω / 2) * E (ω / 4 - (a : ℝ) * ω / 2) := by
      rw [← E_add]; ring_nf
    rw [this]; ring
  have h4 : ‖(4 : ℂ)‖ = 4 := by norm_num
  rw [hsplit, norm_div, norm_mul, norm_E, one_mul, h4, div_pow, norm_three_add_E_sq]
  have harg : 2 * Real.pi * (ω / 4 - (a : ℝ) * ω / 2)
      = -(Real.pi * (2 * (a : ℝ) - 1) * ω / 2) := by ring
  rw [harg, Real.cos_neg]
  norm_num

/-- For a natural number `a` the quantity `2a - 1` never vanishes. -/
lemma odd_multiplier_ne_zero (a : ℕ) : (2 * (a : ℝ) - 1) ≠ 0 := by
  intro h
  have h1 : (2 * a : ℝ) = 1 := by linarith
  have h2 : (2 * a : ℕ) = 1 := by exact_mod_cast h1
  omega

/-- The lower bound `1/2` is attained: at `ω = 2/(2a-1)` the two-step amplitude has
modulus exactly `1/2`.  So `norm_limitAmp2_ge_half` is sharp. -/
theorem norm_limitAmp2_eq_half (a : ℕ) :
    ‖limitAmp2 a (2 / (2 * (a : ℝ) - 1))‖ = 1 / 2 := by
  have hc : (2 * (a : ℝ) - 1) ≠ 0 := odd_multiplier_ne_zero a
  have hsq := norm_limitAmp2_sq a (2 / (2 * (a : ℝ) - 1))
  have harg : Real.pi * (2 * (a : ℝ) - 1) * (2 / (2 * (a : ℝ) - 1)) / 2 = Real.pi := by
    field_simp
  rw [harg, Real.cos_pi] at hsq
  norm_num at hsq
  have hnn : 0 ≤ ‖limitAmp2 a (2 / (2 * (a : ℝ) - 1))‖ := norm_nonneg _
  nlinarith [hsq]

/-! ## Consequences: no cancellation at any frequency -/

/-- **The two-step transform has linear size at every frequency.**  There is no
frequency, rational or irrational, at which the two-step exponential sum
exhibits cancellation. -/
theorem two_step_no_cancellation {a : ℕ} (ha : a % 2 = 1) (ω : ℝ) :
    ∀ᶠ N : ℕ in atTop, (1 / 4 : ℝ) * N ≤ ‖F2 a ω N‖ := by
  have herr : ∀ᶠ N : ℕ in atTop,
      (2 + 2 * Real.pi * |ω| * (1 + Real.log N)) / N ≤ 1 / 4 :=
    (tendsto_errorBound2 |ω|).eventually (eventually_le_nhds (by norm_num))
  filter_upwards [herr, eventually_ge_atTop 1] with N hN hN1
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
  have hb := norm_F2_div_sub_limitAmp2_le ha ω hN1
  have hlow := norm_limitAmp2_ge_half a ω
  have : ‖limitAmp2 a ω‖ - ‖F2 a ω N / (N : ℂ)‖ ≤ ‖F2 a ω N / (N : ℂ) - limitAmp2 a ω‖ := by
    rw [← norm_neg (F2 a ω N / (N : ℂ) - limitAmp2 a ω)]
    have := norm_sub_norm_le (limitAmp2 a ω) (F2 a ω N / (N : ℂ))
    simpa [neg_sub] using this
  have hge : (1 : ℝ) / 4 ≤ ‖F2 a ω N / (N : ℂ)‖ := by linarith [hb.trans hN]
  rw [norm_div, Complex.norm_natCast, le_div_iff₀ hN0] at hge
  linarith

/-- **Resonances are destroyed by iteration.**  At `a = 3`, `ω = 1/5` the one-step
transform exhibits full cancellation, `F 3 (1/5) N = o(N)`, while the two-step
transform built from the *same* map at the *same* frequency keeps linear size.
Hence the one-step "spectral gap" is an artefact of the exact `1/2`–`1/2` balance
of the parity branches and carries no information stable under the dynamics. -/
theorem resonance_destroyed_by_iteration :
    Tendsto (fun N : ℕ => F 3 (1 / 5) N / (N : ℂ)) atTop (𝓝 0) ∧
    (∀ᶠ N : ℕ in atTop, (1 / 4 : ℝ) * N ≤ ‖F2 3 (1 / 5) N‖) := by
  refine ⟨?_, two_step_no_cancellation (by norm_num) (1 / 5)⟩
  have := tendsto_F_div 3 (1 / 5 : ℝ)
  rwa [resonance_three_one_fifth] at this

/-! ## Mean-square power: an averaged statistic that detects depth, not multiplier -/

private lemma integral_cos_period_four {c : ℝ} (hc : c ≠ 0) (m : ℤ)
    (hm : c = Real.pi * (m : ℝ) / 2) :
    (∫ ω in (0 : ℝ)..4, Real.cos (c * ω)) = 0 := by
  rw [intervalIntegral.integral_comp_mul_left (fun y => Real.cos y) hc, integral_cos]
  have hs : Real.sin (c * 4) = 0 := by
    rw [hm]
    have h4 : Real.pi * (m : ℝ) / 2 * 4 = ((2 * m : ℤ) : ℝ) * Real.pi := by push_cast; ring
    rw [h4, Real.sin_int_mul_pi]
  simp [hs]

/-- **Mean-square power at depth one.**  Over the period `[0,4]` the mean of
`‖limitAmp a ω‖²` equals `1/2` for every multiplier. -/
theorem meanSquare_limitAmp_period_four (a : ℕ) :
    (∫ ω in (0 : ℝ)..4, ‖limitAmp a ω‖ ^ 2) = 2 := by
  have hkey : ∀ ω : ℝ, ‖limitAmp a ω‖ ^ 2
      = 1 / 2 + Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2 := by
    intro ω
    rw [norm_limitAmp, sq_abs, Real.cos_sq (Real.pi * ((a : ℝ) - 1 / 2) * ω),
      show 2 * (Real.pi * ((a : ℝ) - 1 / 2) * ω) = Real.pi * (2 * (a : ℝ) - 1) * ω by ring]
  rw [intervalIntegral.integral_congr
    (g := fun ω => 1 / 2 + Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2) (fun ω _ => hkey ω)]
  have hint : (∫ ω in (0 : ℝ)..4, Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω)) = 0 := by
    refine integral_cos_period_four ?_ (2 * (2 * (a : ℤ) - 1)) ?_
    · exact mul_ne_zero (ne_of_gt Real.pi_pos) (odd_multiplier_ne_zero a)
    · push_cast
      ring
  have hcosint : (∫ ω in (0 : ℝ)..4, Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2) = 0 := by
    rw [intervalIntegral.integral_div, hint]; simp
  have hcont : Continuous fun x : ℝ => Real.cos (Real.pi * (2 * (a : ℝ) - 1) * x) / 2 := by
    fun_prop
  rw [intervalIntegral.integral_add (continuous_const.intervalIntegrable _ _)
    (hcont.intervalIntegrable _ _), hcosint]
  simp
  norm_num

/-- **Mean-square power at depth two.**  Over the same period the mean of
`‖limitAmp2 a ω‖²` equals `5/8` for every multiplier: iterating the map raises
the spectral power. -/
theorem meanSquare_limitAmp2_period_four (a : ℕ) :
    (∫ ω in (0 : ℝ)..4, ‖limitAmp2 a ω‖ ^ 2) = 5 / 2 := by
  have hkey : ∀ ω : ℝ, ‖limitAmp2 a ω‖ ^ 2
      = 5 / 8 + 3 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω) / 8 := by
    intro ω
    rw [norm_limitAmp2_sq,
      show Real.pi * (2 * (a : ℝ) - 1) * ω / 2 = Real.pi * (2 * (a : ℝ) - 1) / 2 * ω by ring]
    ring
  rw [intervalIntegral.integral_congr
    (g := fun ω => 5 / 8 + 3 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω) / 8)
    (fun ω _ => hkey ω)]
  have hint : (∫ ω in (0 : ℝ)..4, Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω)) = 0 := by
    refine integral_cos_period_four ?_ (2 * (a : ℤ) - 1) ?_
    · exact div_ne_zero (mul_ne_zero (ne_of_gt Real.pi_pos) (odd_multiplier_ne_zero a))
        (by norm_num)
    · push_cast
      ring
  have hcosint : (∫ ω in (0 : ℝ)..4,
      3 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω) / 8) = 0 := by
    rw [show (fun ω : ℝ => 3 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω) / 8)
        = fun ω : ℝ => (3 / 8) * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * ω) by
      funext ω; ring]
    rw [intervalIntegral.integral_const_mul, hint]
    simp
  have hcont : Continuous fun x : ℝ => 3 * Real.cos (Real.pi * (2 * (a : ℝ) - 1) / 2 * x) / 8 := by
    fun_prop
  rw [intervalIntegral.integral_add (continuous_const.intervalIntegrable _ _)
    (hcont.intervalIntegrable _ _), hcosint]
  simp
  norm_num

/-- **An averaged discriminator that sees the iteration depth, never the
multiplier.**  The mean-square power over a full period strictly increases from
depth one to depth two, by the same amount for all multipliers.  Combined with
`meanSquare_limitAmp_period_four` this shows that `L²` averaging can separate
*dynamical depth* but is blind to the arithmetic of `a`; only the location of the
depth-one resonance set distinguishes the maps. -/
theorem meanSquare_strict_mono_in_depth (a b : ℕ) :
    (∫ ω in (0 : ℝ)..4, ‖limitAmp a ω‖ ^ 2) < (∫ ω in (0 : ℝ)..4, ‖limitAmp2 b ω‖ ^ 2) ∧
    (∫ ω in (0 : ℝ)..4, ‖limitAmp a ω‖ ^ 2) = (∫ ω in (0 : ℝ)..4, ‖limitAmp b ω‖ ^ 2) := by
  rw [meanSquare_limitAmp_period_four, meanSquare_limitAmp2_period_four,
    meanSquare_limitAmp_period_four]
  norm_num

end CollatzSpectral