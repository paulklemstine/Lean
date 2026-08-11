import Mathlib

/-!
# Normalized spectral transforms of the `an + 1` maps

This file develops a *corrected* spectral theory for the one-step "Collatz phase"
exponential sums.  Fix an odd multiplier `a` and consider the accelerated map

`step a n = n / 2` if `n` is even, `step a n = a * n + 1` if `n` is odd,

and the *phase ratio* `ratio a n = step a n / n`.  The cutoff transform is

`F a ω N = ∑_{n = 1}^{N} e(ω · ratio a n)`,  `e(x) = exp(2πi x)`.

The previous cycle attempted a *pointwise* smallness statement for `F a ω N`
valid for all irrational `ω`.  That is impossible: `ratio` takes only the value
`1/2` on the even branch and values `a + 1/n → a` on the odd branch, so the
normalized transform converges to an explicit trigonometric amplitude which is
close to `1` for `ω` near an integer resonance.  Here we prove exactly that.

## Main results

* `ratio_even`, `ratio_odd` — the even/odd splitting of the phase: constant `1/2`
  on evens, `a + 1/n` on odds.
* `F_even_odd_split` — the exact finite decomposition of `F a ω N` into a purely
  constant even contribution and a modulated odd contribution.
* `tendsto_F_div` — **the normalization theorem**:
  `F a ω N / N → (e(ω/2) + e(aω))/2 =: limitAmp a ω` for every real `ω`.
* `norm_limitAmp` — `‖limitAmp a ω‖ = |cos(π (a - 1/2) ω)|`.
* `limitAmp_eq_zero_iff` — the resonance ("spectral gap") set is exactly
  `{ω : (2a - 1) ω is an odd integer}`.
* `tendsto_F_div_of_resonance` — genuine `o(N)` cancellation at resonances.
* `eventually_norm_F_ge` — no cancellation off resonance: `‖F a ω N‖ ≥ c N`.
* `peak_near_zero` — continuity near frequency `0` forces `‖F a ω N‖ ≳ N/4`,
  which refutes any global pointwise decay statement.
* `discriminator_one_fifth` — at `ω = 1/5` the `3n+1` map has a spectral gap
  while the `5n+1` and `7n+1` maps do not: a genuine arithmetic discriminator.
* `meanSquare_limitAmp` — the mean square of the amplitude over a full period
  equals `1/2` for **every** `a`: `L²`-averaging cannot discriminate, only the
  location of the resonance set can.
-/

namespace CollatzSpectral

open Filter Complex
open scoped Real Topology

/-! ## The character `e(x) = exp(2π i x)` -/

/-- The additive character `e(x) = exp(2π i x)`. -/
noncomputable def E (x : ℝ) : ℂ := Complex.exp (2 * Real.pi * Complex.I * x)

lemma E_add (x y : ℝ) : E (x + y) = E x * E y := by
  unfold E
  rw [← Complex.exp_add]
  push_cast
  ring_nf

@[simp] lemma E_zero : E 0 = 1 := by simp [E]

@[simp] lemma norm_E (x : ℝ) : ‖E x‖ = 1 := by
  have : (2 : ℂ) * Real.pi * Complex.I * x = ((2 * Real.pi * x : ℝ) : ℂ) * Complex.I := by
    push_cast; ring
  rw [E, this, Complex.norm_exp_ofReal_mul_I]

lemma continuous_E : Continuous E := by
  unfold E
  fun_prop

/-- `e(x) + e(-x) = 2 cos(2π x)`. -/
lemma E_add_E_neg (x : ℝ) : E x + E (-x) = 2 * (Real.cos (2 * Real.pi * x) : ℂ) := by
  rw [E, E, Complex.ofReal_cos, Complex.two_cos]
  push_cast
  ring_nf

/-- `‖1 + e(t)‖ = 2 |cos(π t)|`. -/
lemma norm_one_add_E (t : ℝ) : ‖1 + E t‖ = 2 * |Real.cos (Real.pi * t)| := by
  have ha : t / 2 + -(t / 2) = 0 := by ring
  have hb : t / 2 + t / 2 = t := by ring
  have h1 : 1 + E t = E (t / 2) * (E (-(t / 2)) + E (t / 2)) := by
    rw [mul_add, ← E_add, ← E_add, ha, hb, E_zero]
  have harg : 2 * Real.pi * (t / 2) = Real.pi * t := by ring
  have h2 : E (-(t / 2)) + E (t / 2) = 2 * ((Real.cos (Real.pi * t) : ℝ) : ℂ) := by
    rw [add_comm, E_add_E_neg (t / 2), harg]
  rw [h1, h2, norm_mul, norm_E, one_mul, norm_mul, Complex.norm_real, Real.norm_eq_abs]
  norm_num

/-! ## The maps and their phase ratios -/

/-- The one-step accelerated `a n + 1` map. -/
def step (a n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else a * n + 1

/-- The phase ratio `step a n / n`. -/
noncomputable def ratio (a n : ℕ) : ℝ := (step a n : ℝ) / (n : ℝ)

lemma ratio_even {n : ℕ} (hn : n % 2 = 0) (hpos : n ≠ 0) (a : ℕ) : ratio a n = 1 / 2 := by
  have h2 : n / 2 * 2 = n := Nat.div_mul_cancel (Nat.dvd_of_mod_eq_zero hn)
  have hcast : ((n / 2 : ℕ) : ℝ) * 2 = (n : ℝ) := by exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) h2
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratio step
  rw [if_pos hn]
  field_simp
  linarith [hcast]

lemma ratio_odd {n : ℕ} (hn : n % 2 = 1) (a : ℕ) : ratio a n = (a : ℝ) + 1 / n := by
  have hpos : n ≠ 0 := by intro h; simp [h] at hn
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratio step
  rw [if_neg (by omega)]
  push_cast
  field_simp

/-! ## The cutoff transform -/

/-- The cutoff exponential sum `F a ω N = ∑_{n=1}^{N} e(ω · ratio a n)`. -/
noncomputable def F (a : ℕ) (ω : ℝ) (N : ℕ) : ℂ :=
  ∑ k ∈ Finset.range N, E (ω * ratio a (k + 1))

/-- The limiting normalized amplitude `(e(ω/2) + e(aω))/2`. -/
noncomputable def limitAmp (a : ℕ) (ω : ℝ) : ℂ := (E (ω / 2) + E (a * ω)) / 2

/-- Half the difference of the two branch phases. -/
noncomputable def branchGap (a : ℕ) (ω : ℝ) : ℂ := (E (a * ω) - E (ω / 2)) / 2

lemma summand_eq (a k : ℕ) (ω : ℝ) :
    E (ω * ratio a (k + 1)) =
      if k % 2 = 0 then E ((a : ℝ) * ω) * E (ω / (k + 1)) else E (ω / 2) := by
  rcases Nat.even_or_odd k with hk | hk
  · have hk0 : k % 2 = 0 := Nat.even_iff.mp hk
    have hodd : (k + 1) % 2 = 1 := by omega
    rw [if_pos hk0, ratio_odd hodd a]
    have : ω * ((a : ℝ) + 1 / (k + 1 : ℕ)) = (a : ℝ) * ω + ω / ((k : ℝ) + 1) := by
      push_cast; ring
    rw [this, E_add]
  · have hk1 : k % 2 = 1 := Nat.odd_iff.mp hk
    have heven : (k + 1) % 2 = 0 := by omega
    rw [if_neg (by omega), ratio_even heven (by omega) a]
    ring_nf

lemma card_odd_range (n : ℕ) : ((Finset.range n).filter (fun k => k % 2 = 1)).card = n / 2 := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : m % 2 = 1
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]; omega
    · rw [if_neg h, ih]; omega

/-- **Exact even/odd decomposition** of the cutoff transform: the even branch
contributes the constant phase `e(ω/2)` with multiplicity `⌊N/2⌋`, while the odd
branch contributes `e(aω)` times a sum of slowly varying phases `e(ω/n)`. -/
theorem F_even_odd_split (a : ℕ) (ω : ℝ) (N : ℕ) :
    F a ω N = (N / 2 : ℕ) * E (ω / 2)
      + E ((a : ℝ) * ω) * ∑ k ∈ (Finset.range N).filter (fun k => k % 2 = 0),
          E (ω / (k + 1)) := by
  classical
  unfold F
  rw [← Finset.sum_filter_add_sum_filter_not (Finset.range N) (fun k => k % 2 = 0)]
  have h1 : ∑ k ∈ (Finset.range N).filter (fun k => k % 2 = 0), E (ω * ratio a (k + 1))
      = E ((a : ℝ) * ω) * ∑ k ∈ (Finset.range N).filter (fun k => k % 2 = 0), E (ω / (k + 1)) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl ?_
    intro k hk
    have hk0 : k % 2 = 0 := (Finset.mem_filter.mp hk).2
    rw [summand_eq, if_pos hk0]
  have h2 : ∑ k ∈ (Finset.range N).filter (fun k => ¬ k % 2 = 0), E (ω * ratio a (k + 1))
      = ((Finset.range N).filter (fun k => ¬ k % 2 = 0)).card • E (ω / 2) := by
    rw [← Finset.sum_const]
    refine Finset.sum_congr rfl ?_
    intro k hk
    have hk0 : ¬ k % 2 = 0 := (Finset.mem_filter.mp hk).2
    rw [summand_eq, if_neg hk0]
  have hfil : (Finset.range N).filter (fun k => ¬ k % 2 = 0)
      = (Finset.range N).filter (fun k => k % 2 = 1) := by
    apply Finset.filter_congr
    intro k _
    constructor
    · intro h; omega
    · intro h; omega
  have hcard : ((Finset.range N).filter (fun k => ¬ k % 2 = 0)).card = N / 2 := by
    rw [hfil, card_odd_range]
  rw [h1, h2, hcard, nsmul_eq_mul]
  ring

/-! ## Convergence of the normalized transform -/

/-- The deviation of the `k`-th summand from its two-periodic model. -/
noncomputable def dseq (a : ℕ) (ω : ℝ) (k : ℕ) : ℂ :=
  E (ω * ratio a (k + 1)) - (limitAmp a ω + (-1) ^ k * branchGap a ω)

lemma dseq_eq (a : ℕ) (ω : ℝ) (k : ℕ) :
    dseq a ω k = if k % 2 = 0 then E ((a : ℝ) * ω) * (E (ω / (k + 1)) - 1) else 0 := by
  unfold dseq limitAmp branchGap
  rcases Nat.even_or_odd k with hk | hk
  · have hk0 : k % 2 = 0 := Nat.even_iff.mp hk
    rw [summand_eq, if_pos hk0, if_pos hk0, hk.neg_one_pow]
    ring
  · have hk1 : k % 2 = 1 := Nat.odd_iff.mp hk
    rw [summand_eq, if_neg (by omega), if_neg (by omega), hk.neg_one_pow]
    ring

lemma norm_dseq_le (a : ℕ) (ω : ℝ) (k : ℕ) :
    ‖dseq a ω k‖ ≤ ‖E (ω / (k + 1)) - 1‖ := by
  rw [dseq_eq]
  by_cases hk : k % 2 = 0
  · rw [if_pos hk, norm_mul, norm_E, one_mul]
  · rw [if_neg hk, norm_zero]
    positivity

lemma tendsto_dseq (a : ℕ) (ω : ℝ) : Tendsto (dseq a ω) atTop (𝓝 0) := by
  have h0 : Tendsto (fun k : ℕ => ω / ((k : ℝ) + 1)) atTop (𝓝 0) := by
    have := tendsto_natCast_atTop_atTop (R := ℝ)
    have h1 : Tendsto (fun k : ℕ => (k : ℝ) + 1) atTop atTop :=
      tendsto_atTop_add_const_right _ 1 this
    simpa using h1.inv_tendsto_atTop.const_mul ω
  have h1 : Tendsto (fun k : ℕ => E (ω / ((k : ℝ) + 1)) - 1) atTop (𝓝 0) := by
    have : Tendsto (fun k : ℕ => E (ω / ((k : ℝ) + 1))) atTop (𝓝 (E 0)) :=
      (continuous_E.tendsto 0).comp h0
    simpa using this.sub_const 1
  refine squeeze_zero_norm (fun k => ?_) (by simpa using h1.norm)
  simpa using norm_dseq_le a ω k

/-- Exact decomposition of the partial sum into the mean term, the alternating
term, and the deviation sum. -/
lemma F_eq (a : ℕ) (ω : ℝ) (N : ℕ) :
    F a ω N = (N : ℂ) * limitAmp a ω
      + branchGap a ω * (∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)
      + ∑ k ∈ Finset.range N, dseq a ω k := by
  unfold F dseq
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul, Finset.sum_const,
    Finset.card_range, nsmul_eq_mul]
  ring

/-- **Normalization theorem.**  For every multiplier `a` and every real frequency
`ω`, the normalized cutoff transform converges to the explicit amplitude
`(e(ω/2) + e(aω))/2`. -/
theorem tendsto_F_div (a : ℕ) (ω : ℝ) :
    Tendsto (fun N : ℕ => F a ω N / (N : ℂ)) atTop (𝓝 (limitAmp a ω)) := by
  have hces : Tendsto (fun N : ℕ => ((N : ℝ))⁻¹ • ∑ k ∈ Finset.range N, dseq a ω k)
      atTop (𝓝 0) := by
    simpa using (tendsto_dseq a ω).cesaro_smul
  have hces' : Tendsto (fun N : ℕ => (N : ℂ)⁻¹ * ∑ k ∈ Finset.range N, dseq a ω k)
      atTop (𝓝 0) := by
    refine hces.congr (fun N => ?_)
    rw [Complex.real_smul]
    push_cast
    ring
  have hbnd : ∀ N : ℕ, ‖(N : ℂ)⁻¹ * (branchGap a ω * ∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)‖
      ≤ ‖branchGap a ω‖ / N := by
    intro N
    rw [norm_mul, norm_mul, norm_inv, Complex.norm_natCast]
    have hb : ‖∑ k ∈ Finset.range N, (-1 : ℂ) ^ k‖ ≤ 1 := by
      rw [neg_one_geom_sum]
      by_cases h : Even N <;> simp [h]
    have h1 : ‖branchGap a ω‖ * ‖∑ k ∈ Finset.range N, (-1 : ℂ) ^ k‖
        ≤ ‖branchGap a ω‖ * 1 := mul_le_mul_of_nonneg_left hb (norm_nonneg _)
    calc (N : ℝ)⁻¹ * (‖branchGap a ω‖ * ‖∑ k ∈ Finset.range N, (-1 : ℂ) ^ k‖)
        ≤ (N : ℝ)⁻¹ * (‖branchGap a ω‖ * 1) := mul_le_mul_of_nonneg_left h1 (by positivity)
      _ = ‖branchGap a ω‖ / N := by rw [mul_one]; ring
  have halt : Tendsto (fun N : ℕ => (N : ℂ)⁻¹ *
      (branchGap a ω * ∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)) atTop (𝓝 0) :=
    squeeze_zero_norm hbnd (tendsto_const_div_atTop_nhds_zero_nat ‖branchGap a ω‖)
  have hmain : Tendsto (fun N : ℕ => (N : ℂ)⁻¹ *
      (branchGap a ω * ∑ k ∈ Finset.range N, (-1 : ℂ) ^ k)
      + (N : ℂ)⁻¹ * ∑ k ∈ Finset.range N, dseq a ω k + limitAmp a ω)
      atTop (𝓝 (limitAmp a ω)) := by
    simpa using ((halt.add hces').add_const (limitAmp a ω))
  refine hmain.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with N hN
  have hN0 : (N : ℂ) ≠ 0 := by
    simp only [ne_eq, Nat.cast_eq_zero]
    omega
  rw [F_eq]
  field_simp
  ring

/-! ## The amplitude: modulus, resonances, and the discriminator -/

/-- The modulus of the limiting amplitude is `|cos(π (a - 1/2) ω)|`. -/
theorem norm_limitAmp (a : ℕ) (ω : ℝ) :
    ‖limitAmp a ω‖ = |Real.cos (Real.pi * ((a : ℝ) - 1 / 2) * ω)| := by
  have harg : ω / 2 + ((a : ℝ) - 1 / 2) * ω = (a : ℝ) * ω := by ring
  have hsplit : E (ω / 2) + E ((a : ℝ) * ω)
      = E (ω / 2) * (1 + E (((a : ℝ) - 1 / 2) * ω)) := by
    rw [mul_add, mul_one, ← E_add, harg]
  have h2 : ‖(2 : ℂ)‖ = 2 := by norm_num
  unfold limitAmp
  rw [hsplit, norm_div, norm_mul, norm_E, one_mul, norm_one_add_E, h2,
    show Real.pi * (((a : ℝ) - 1 / 2) * ω) = Real.pi * ((a : ℝ) - 1 / 2) * ω by ring]
  ring

/-- The resonance set: the amplitude vanishes exactly when `(2a - 1) ω` is an odd
integer. -/
theorem limitAmp_eq_zero_iff (a : ℕ) (ω : ℝ) :
    limitAmp a ω = 0 ↔ ∃ m : ℤ, (2 * (a : ℝ) - 1) * ω = 2 * m + 1 := by
  rw [← norm_eq_zero, norm_limitAmp, abs_eq_zero, Real.cos_eq_zero_iff]
  constructor
  · rintro ⟨m, hm⟩
    exact ⟨m, by field_simp at hm ⊢; nlinarith [Real.pi_pos, hm]⟩
  · rintro ⟨m, hm⟩
    refine ⟨m, ?_⟩
    have : ((a : ℝ) - 1 / 2) * ω = m + 1 / 2 := by linarith
    rw [show Real.pi * ((a : ℝ) - 1 / 2) * ω = Real.pi * (((a : ℝ) - 1 / 2) * ω) by ring, this]
    ring

/-- **Spectral gap at resonance**: if `(2a-1)ω` is an odd integer the normalized
transform tends to `0`, i.e. `F a ω N = o(N)` — genuine cancellation. -/
theorem tendsto_F_div_of_resonance (a : ℕ) (ω : ℝ) (h : ∃ m : ℤ, (2 * (a : ℝ) - 1) * ω = 2 * m + 1) :
    Tendsto (fun N : ℕ => F a ω N / (N : ℂ)) atTop (𝓝 0) := by
  have := tendsto_F_div a ω
  rwa [(limitAmp_eq_zero_iff a ω).mpr h] at this

/-- **No cancellation off resonance**: away from the resonance set the transform
has full linear size along the whole sequence. -/
theorem eventually_norm_F_ge (a : ℕ) (ω : ℝ) (h : limitAmp a ω ≠ 0) :
    ∀ᶠ N : ℕ in atTop, (‖limitAmp a ω‖ / 2) * N ≤ ‖F a ω N‖ := by
  have hlim := (tendsto_F_div a ω).norm
  have hpos : 0 < ‖limitAmp a ω‖ := norm_pos_iff.mpr h
  have hlt : ‖limitAmp a ω‖ / 2 < ‖limitAmp a ω‖ := by linarith
  have hev : ∀ᶠ N : ℕ in atTop, ‖limitAmp a ω‖ / 2 ≤ ‖F a ω N / (N : ℂ)‖ :=
    hlim.eventually_const_le hlt
  filter_upwards [hev, eventually_ge_atTop 1] with N hN hN1
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
  rw [norm_div, Complex.norm_natCast, le_div_iff₀ hN0] at hN
  linarith [hN]

/-- **The zero-frequency peak.**  Continuity at `ω = 0` forces the transform to
stay close to the trivial bound `N` for all small frequencies; in particular no
pointwise bound `‖F a ω N‖ = o(N)` can hold for all irrational `ω`. -/
theorem peak_near_zero (a : ℕ) (ω : ℝ) (hω : |(2 * (a : ℝ) - 1) * ω| ≤ 2 / 3) :
    ∀ᶠ N : ℕ in atTop, (1 / 4 : ℝ) * N ≤ ‖F a ω N‖ := by
  set t : ℝ := ((a : ℝ) - 1 / 2) * ω with ht
  have hpi : |Real.pi * t| ≤ Real.pi / 3 := by
    have h1 : |t| ≤ 1 / 3 := by
      have : |(2 * (a : ℝ) - 1) * ω| = 2 * |t| := by
        rw [ht, abs_mul, abs_mul]
        rw [show (2 * (a : ℝ) - 1) = 2 * ((a : ℝ) - 1 / 2) by ring, abs_mul]
        simp
        ring
      linarith [this ▸ hω]
    calc |Real.pi * t| = Real.pi * |t| := by rw [abs_mul, abs_of_pos Real.pi_pos]
      _ ≤ Real.pi * (1 / 3) := by nlinarith [Real.pi_pos]
      _ = Real.pi / 3 := by ring
  have hcos : (1 : ℝ) / 2 ≤ Real.cos (Real.pi * t) := by
    have h2 : Real.cos (Real.pi / 3) ≤ Real.cos (Real.pi * t) := by
      rw [← Real.cos_abs (Real.pi * t)]
      apply Real.cos_le_cos_of_nonneg_of_le_pi (abs_nonneg _)
      · linarith [Real.pi_pos]
      · exact hpi
    rwa [Real.cos_pi_div_three] at h2
  have hnorm : (1 : ℝ) / 2 ≤ ‖limitAmp a ω‖ := by
    rw [norm_limitAmp, show Real.pi * ((a : ℝ) - 1 / 2) * ω = Real.pi * t by rw [ht]; ring]
    calc (1 : ℝ) / 2 ≤ Real.cos (Real.pi * t) := hcos
      _ ≤ |Real.cos (Real.pi * t)| := le_abs_self _
  have hne : limitAmp a ω ≠ 0 := by
    intro h
    rw [h, norm_zero] at hnorm
    linarith
  filter_upwards [eventually_norm_F_ge a ω hne] with N hN
  have : (1 / 4 : ℝ) * N ≤ (‖limitAmp a ω‖ / 2) * N := by
    have hNn : (0 : ℝ) ≤ N := Nat.cast_nonneg N
    nlinarith
  linarith

/-! ## An arithmetic discriminator between the `3n+1`, `5n+1` and `7n+1` maps -/

lemma resonance_three_one_fifth : limitAmp 3 (1 / 5 : ℝ) = 0 := by
  rw [limitAmp_eq_zero_iff]
  exact ⟨0, by norm_num⟩

lemma no_resonance_five_one_fifth : limitAmp 5 (1 / 5 : ℝ) ≠ 0 := by
  rw [Ne, limitAmp_eq_zero_iff]
  rintro ⟨m, hm⟩
  norm_num at hm
  have : (9 : ℝ) = 10 * m + 5 := by linarith
  have hz : (9 : ℤ) = 10 * m + 5 := by exact_mod_cast this
  omega

lemma no_resonance_seven_one_fifth : limitAmp 7 (1 / 5 : ℝ) ≠ 0 := by
  rw [Ne, limitAmp_eq_zero_iff]
  rintro ⟨m, hm⟩
  norm_num at hm
  have : (13 : ℝ) = 10 * m + 5 := by linarith
  have hz : (13 : ℤ) = 10 * m + 5 := by exact_mod_cast this
  omega

/-- **A genuine spectral discriminator.**  At the frequency `ω = 1/5` the `3n+1`
map exhibits full cancellation (`F = o(N)`), while the `5n+1` and `7n+1` maps
retain linear size.  Unlike the behaviour near frequency zero, this distinction
is arithmetic: it detects the multiplier through the resonance set
`{ω : (2a-1)ω ∈ 2ℤ + 1}`. -/
theorem discriminator_one_fifth :
    Tendsto (fun N : ℕ => F 3 (1 / 5) N / (N : ℂ)) atTop (𝓝 0) ∧
    (∀ᶠ N : ℕ in atTop, (‖limitAmp 5 (1 / 5)‖ / 2) * N ≤ ‖F 5 (1 / 5) N‖) ∧
    (∀ᶠ N : ℕ in atTop, (‖limitAmp 7 (1 / 5)‖ / 2) * N ≤ ‖F 7 (1 / 5) N‖) ∧
    0 < ‖limitAmp 5 (1 / 5)‖ ∧ 0 < ‖limitAmp 7 (1 / 5)‖ := by
  refine ⟨?_, eventually_norm_F_ge 5 (1 / 5) no_resonance_five_one_fifth,
    eventually_norm_F_ge 7 (1 / 5) no_resonance_seven_one_fifth,
    norm_pos_iff.mpr no_resonance_five_one_fifth,
    norm_pos_iff.mpr no_resonance_seven_one_fifth⟩
  have := tendsto_F_div 3 (1 / 5 : ℝ)
  rwa [resonance_three_one_fifth] at this

/-! ## The averaged (L²) statistic does not discriminate -/

/-- **Mean square of the amplitude over a period.**  For every multiplier `a ≥ 1`
the mean of `‖limitAmp a ω‖²` over the interval `[0, 2]` equals `1/2`,
independently of `a`.  Hence a plain `L²` average cannot distinguish the maps;
only the *location* of the resonance set can. -/
theorem meanSquare_limitAmp (a : ℕ) (ha : 1 ≤ a) :
    (∫ ω in (0 : ℝ)..2, ‖limitAmp a ω‖ ^ 2) = 1 := by
  have hkey : ∀ ω : ℝ, ‖limitAmp a ω‖ ^ 2
      = 1 / 2 + Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2 := by
    intro ω
    rw [norm_limitAmp, sq_abs]
    rw [Real.cos_sq (Real.pi * ((a : ℝ) - 1 / 2) * ω),
      show 2 * (Real.pi * ((a : ℝ) - 1 / 2) * ω) = Real.pi * (2 * (a : ℝ) - 1) * ω by ring]
  have hc : (2 * (a : ℝ) - 1) ≠ 0 := by
    have : (1 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha
    linarith
  rw [intervalIntegral.integral_congr (g := fun ω => 1 / 2 + Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2)
      (fun ω _ => hkey ω)]
  have hint : (∫ ω in (0 : ℝ)..2, Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω)) = 0 := by
    have hcc : (Real.pi * (2 * (a : ℝ) - 1)) ≠ 0 := mul_ne_zero (ne_of_gt Real.pi_pos) hc
    have hs : Real.sin (Real.pi * (2 * (a : ℝ) - 1) * 2) = 0 := by
      have hrw : Real.pi * (2 * (a : ℝ) - 1) * 2 = ((2 * (a : ℤ) - 1) * 2 : ℤ) * Real.pi := by
        push_cast; ring
      rw [hrw, Real.sin_int_mul_pi]
    rw [intervalIntegral.integral_comp_mul_left (fun y => Real.cos y) hcc, integral_cos]
    simp [hs]
  have hcosint : (∫ ω in (0 : ℝ)..2, Real.cos (Real.pi * (2 * (a : ℝ) - 1) * ω) / 2) = 0 := by
    rw [intervalIntegral.integral_div, hint]
    simp
  have hcont : Continuous fun x : ℝ => Real.cos (Real.pi * (2 * (a : ℝ) - 1) * x) / 2 := by
    fun_prop
  rw [intervalIntegral.integral_add (continuous_const.intervalIntegrable _ _)
    (hcont.intervalIntegrable _ _), hcosint]
  simp

end CollatzSpectral