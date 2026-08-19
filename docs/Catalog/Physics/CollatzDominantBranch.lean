import Physics.CollatzSpectralAveraged

/-!
# The dominant-branch principle, and the `b`-adic `a n + 1` maps

The previous files show a sharp contrast.  For the one-step transform of the
`a n + 1` map the two parity branches carry *equal* densities `1/2`, and exact
destructive interference (a spectral gap) occurs on the resonance set.  For the
two-step transform the branch densities are `1/4` and `3/4`, and no cancellation
is possible at any frequency.

This file isolates the mechanism behind both phenomena as a single, general
criterion, and then uses it to settle an entire family of maps.

## Main results

* `dominant_branch_lower_bound` — **the dominant-branch principle.**  Let
  `r : ℕ → ℝ` be any phase-ratio sequence and let `D` be a set of indices of
  asymptotic density `d > 1/2` along which the phases converge to a single value
  `θ`.  Then for *every* frequency `ω`,
  `‖Fgen r ω N‖ ≥ c · N` for all large `N`, for every constant `c < 2d - 1`
  (`dominant_branch_half_bound` is the convenient special case `c = (2d-1)/2`).
  Density `> 1/2` is exactly what makes destructive interference impossible; at
  `d = 1/2` the conclusion genuinely fails (the one-step resonances).
* `card_multiples_range`, `tendsto_card_multiples_div` — the density of a
  residue class, in the form needed by the criterion.
* `b_adic_no_resonance`, `b_adic_no_resonance_sharp` — **application.**  For the `b`-adic map
  `n ↦ n / b` (if `b ∣ n`), `n ↦ a n + 1` (otherwise) with `b ≥ 3`, the one-step
  transform satisfies `‖FB b a ω N‖ ≥ (b-2)/(2b) · N` for every real frequency:
  these maps have *no* spectral gap at all.
* `halving_is_the_unique_resonant_base` — combined with the resonance of the
  classical case `b = 2`, this shows that the spectral gaps studied in the
  earlier files are an artefact of *halving* specifically: base `2` is the unique
  base for which the one-step branch densities are balanced.
-/

namespace CollatzSpectral

open Filter Complex
open scoped Real Topology

/-! ## The deviation sequence along a branch -/

/-- The deviation of the phase from its branch model, supported on `D`. -/
noncomputable def devSeq (r : ℕ → ℝ) (θ ω : ℝ) (D : ℕ → Prop) [DecidablePred D] (k : ℕ) : ℂ :=
  if D k then E (ω * r (k + 1)) - E (ω * θ) else 0

lemma norm_devSeq_le (r : ℕ → ℝ) (θ ω : ℝ) (D : ℕ → Prop) [DecidablePred D] (k : ℕ) :
    ‖devSeq r θ ω D k‖ ≤ 2 * Real.pi * |ω| * |if D k then r (k + 1) - θ else 0| := by
  unfold devSeq
  by_cases h : D k
  · rw [if_pos h, if_pos h]
    have hfac : E (ω * r (k + 1)) - E (ω * θ) = E (ω * θ) * (E (ω * (r (k + 1) - θ)) - 1) := by
      rw [mul_sub, mul_one, ← E_add]
      ring_nf
    rw [hfac, norm_mul, norm_E, one_mul]
    refine (norm_E_sub_one_le _).trans ?_
    rw [abs_mul]
    have hpi : (0 : ℝ) ≤ 2 * Real.pi := by positivity
    nlinarith [abs_nonneg ω, abs_nonneg (r (k + 1) - θ), Real.pi_pos]
  · rw [if_neg h, if_neg h, norm_zero]
    positivity

/-- Pointwise lower bound for a transform split along a branch. -/
lemma Fgen_lower_bound_aux (r : ℕ → ℝ) (θ ω : ℝ) (D : ℕ → Prop) [DecidablePred D] (N : ℕ) :
    2 * (((Finset.range N).filter D).card : ℝ) - N
      - ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ ≤ ‖Fgen r ω N‖ := by
  classical
  set c : ℕ := ((Finset.range N).filter D).card with hc
  set T : ℂ := ∑ k ∈ (Finset.range N).filter (fun k => ¬ D k), E (ω * r (k + 1)) with hT
  set S : ℂ := ∑ k ∈ Finset.range N, devSeq r θ ω D k with hS
  have hdevsupp : S = ∑ k ∈ (Finset.range N).filter D, devSeq r θ ω D k := by
    rw [hS]
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro k hk hknot
    have hnD : ¬ D k := fun hD => hknot (Finset.mem_filter.mpr ⟨hk, hD⟩)
    unfold devSeq
    rw [if_neg hnD]
  have hdecomp : Fgen r ω N = ((c : ℂ) * E (ω * θ) + S) + T := by
    unfold Fgen
    rw [← Finset.sum_filter_add_sum_filter_not (Finset.range N) D, hdevsupp, hT]
    have hbranch : ∑ k ∈ (Finset.range N).filter D, E (ω * r (k + 1))
        = (c : ℂ) * E (ω * θ) + ∑ k ∈ (Finset.range N).filter D, devSeq r θ ω D k := by
      have : ∀ k ∈ (Finset.range N).filter D,
          E (ω * r (k + 1)) = E (ω * θ) + devSeq r θ ω D k := by
        intro k hk
        have hD : D k := (Finset.mem_filter.mp hk).2
        unfold devSeq
        rw [if_pos hD]
        ring
      rw [Finset.sum_congr rfl this, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul, hc]
    rw [hbranch]
  have hTnorm : ‖T‖ ≤ (N : ℝ) - c := by
    rw [hT]
    refine (norm_sum_le _ _).trans ?_
    have hb : ∑ _k ∈ (Finset.range N).filter (fun k => ¬ D k), (1 : ℝ)
        = (((Finset.range N).filter (fun k => ¬ D k)).card : ℝ) := by
      rw [Finset.sum_const, nsmul_eq_mul, mul_one]
    have hcard : (((Finset.range N).filter (fun k => ¬ D k)).card : ℝ) = (N : ℝ) - c := by
      have hsum := Finset.card_filter_add_card_filter_not (s := Finset.range N) (p := D)
      rw [Finset.card_range] at hsum
      have hsumR : (c : ℝ) + ((((Finset.range N).filter (fun k => ¬ D k)).card : ℕ) : ℝ)
          = (N : ℝ) := by
        rw [hc]
        exact_mod_cast hsum
      linarith
    calc ∑ k ∈ (Finset.range N).filter (fun k => ¬ D k), ‖E (ω * r (k + 1))‖
        = ∑ _k ∈ (Finset.range N).filter (fun k => ¬ D k), (1 : ℝ) := by
          refine Finset.sum_congr rfl (fun k _ => ?_)
          rw [norm_E]
      _ = (N : ℝ) - c := by rw [hb, hcard]
      _ ≤ (N : ℝ) - c := le_rfl
  have hmain : (c : ℝ) ≤ ‖Fgen r ω N‖ + (‖S‖ + ‖T‖) := by
    have hcnorm : ‖(c : ℂ) * E (ω * θ)‖ = (c : ℝ) := by
      rw [norm_mul, norm_E, mul_one, Complex.norm_natCast]
    calc (c : ℝ) = ‖(c : ℂ) * E (ω * θ)‖ := hcnorm.symm
      _ = ‖Fgen r ω N - (S + T)‖ := by rw [hdecomp]; ring_nf
      _ ≤ ‖Fgen r ω N‖ + ‖S + T‖ := norm_sub_le _ _
      _ ≤ ‖Fgen r ω N‖ + (‖S‖ + ‖T‖) := by
          have := norm_add_le S T
          linarith
  linarith [hmain, hTnorm]

/-! ## The dominant-branch principle -/

/-- **Dominant-branch principle.**  If a set of indices of asymptotic density
`d > 1/2` carries phases converging to a single value, then the exponential sum
has linear size at *every* frequency, with the explicit constant `(2d-1)/2`.
This is the structural reason why the two-step Collatz spectrum has no
resonances, while the one-step spectrum (balanced densities `d = 1/2`) does. -/
theorem dominant_branch_lower_bound (r : ℕ → ℝ) (θ ω d c : ℝ) (D : ℕ → Prop) [DecidablePred D]
    (hc : c < 2 * d - 1)
    (hdens : Tendsto (fun N : ℕ => (((Finset.range N).filter D).card : ℝ) / N) atTop (𝓝 d))
    (hphase : Tendsto (fun k : ℕ => if D k then r (k + 1) - θ else 0) atTop (𝓝 0)) :
    ∀ᶠ N : ℕ in atTop, c * N ≤ ‖Fgen r ω N‖ := by
  classical
  -- the deviations tend to zero
  have habs : Tendsto (fun k : ℕ => |if D k then r (k + 1) - θ else 0|) atTop (𝓝 0) := by
    simpa using hphase.abs
  have hdev : Tendsto (fun k : ℕ => devSeq r θ ω D k) atTop (𝓝 0) := by
    refine squeeze_zero_norm (fun k => norm_devSeq_le r θ ω D k) ?_
    simpa using habs.const_mul (2 * Real.pi * |ω|)
  -- their Cesàro means tend to zero
  have hces : Tendsto (fun N : ℕ => ((N : ℝ))⁻¹ • ∑ k ∈ Finset.range N, devSeq r θ ω D k)
      atTop (𝓝 0) := by simpa using hdev.cesaro_smul
  have hcesnorm : Tendsto
      (fun N : ℕ => ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ / N) atTop (𝓝 0) := by
    have h := hces.norm
    simp only [norm_zero] at h
    refine h.congr (fun N => ?_)
    rw [norm_smul, Real.norm_eq_abs, abs_inv, Nat.abs_cast]
    rw [div_eq_inv_mul]
  -- the model quantity converges to `2d - 1`
  have hpsi : Tendsto (fun N : ℕ => 2 * ((((Finset.range N).filter D).card : ℝ) / N) - 1
      - ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ / N) atTop (𝓝 (2 * d - 1)) := by
    have h1 := (hdens.const_mul 2).sub_const 1
    have h2 := h1.sub hcesnorm
    simpa using h2
  have hev := hpsi.eventually_const_le hc
  filter_upwards [hev, eventually_ge_atTop 1] with N hN hN1
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
  have haux := Fgen_lower_bound_aux r θ ω D N
  have hmul : c * N
      ≤ (2 * ((((Finset.range N).filter D).card : ℝ) / N) - 1
        - ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ / N) * N :=
    mul_le_mul_of_nonneg_right hN hN0.le
  have hexpand : (2 * ((((Finset.range N).filter D).card : ℝ) / N) - 1
      - ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ / N) * N
      = 2 * (((Finset.range N).filter D).card : ℝ) - N
        - ‖∑ k ∈ Finset.range N, devSeq r θ ω D k‖ := by
    field_simp
  rw [hexpand] at hmul
  linarith

/-- The dominant-branch principle in its simplest quantitative form: a branch of
density `d > 1/2` forces linear size with the constant `(2d-1)/2`. -/
theorem dominant_branch_half_bound (r : ℕ → ℝ) (θ ω d : ℝ) (D : ℕ → Prop) [DecidablePred D]
    (hd : 1 / 2 < d)
    (hdens : Tendsto (fun N : ℕ => (((Finset.range N).filter D).card : ℝ) / N) atTop (𝓝 d))
    (hphase : Tendsto (fun k : ℕ => if D k then r (k + 1) - θ else 0) atTop (𝓝 0)) :
    ∀ᶠ N : ℕ in atTop, (2 * d - 1) / 2 * N ≤ ‖Fgen r ω N‖ :=
  dominant_branch_lower_bound r θ ω d _ D (by linarith) hdens hphase

/-! ## Densities of residue classes -/

lemma card_multiples_range (b N : ℕ) :
    ((Finset.range N).filter (fun k => (k + 1) % b = 0)).card = N / b := by
  induction N with
  | zero => simp
  | succ m ih =>
    rw [Finset.range_add_one, Finset.filter_insert, Nat.succ_div]
    by_cases h : (m + 1) % b = 0
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih,
        if_pos (Nat.dvd_iff_mod_eq_zero.mpr h)]
    · rw [if_neg h, ih, if_neg (fun hd => h (Nat.dvd_iff_mod_eq_zero.mp hd)), add_zero]

/-- The density of the multiples of `b`. -/
lemma tendsto_card_multiples_div {b : ℕ} (hb : 0 < b) :
    Tendsto (fun N : ℕ => (((Finset.range N).filter (fun k => (k + 1) % b = 0)).card : ℝ) / N)
      atTop (𝓝 (1 / b)) := by
  have hbR : (0 : ℝ) < b := by exact_mod_cast hb
  rw [← tendsto_sub_nhds_zero_iff]
  refine squeeze_zero_norm' ?_ (tendsto_const_div_atTop_nhds_zero_nat 1)
  filter_upwards [eventually_ge_atTop 1] with N hN1
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
  rw [card_multiples_range]
  set q : ℕ := N / b with hq
  have hdm : b * q + N % b = N := Nat.div_add_mod N b
  have hmod : N % b < b := Nat.mod_lt _ hb
  have hdmR : (b : ℝ) * q + ((N % b : ℕ) : ℝ) = N := by exact_mod_cast hdm
  have hmodR : ((N % b : ℕ) : ℝ) < b := by exact_mod_cast hmod
  have hmodnn : (0 : ℝ) ≤ ((N % b : ℕ) : ℝ) := Nat.cast_nonneg _
  have hb1 : (b : ℝ) * q ≤ N := by linarith
  have hb2 : (N : ℝ) < (b : ℝ) * q + b := by linarith
  have hrw : ((q : ℝ) / N - 1 / b) = ((b : ℝ) * q - N) / (b * N) := by
    field_simp
  rw [Real.norm_eq_abs, hrw, abs_div, abs_of_pos (by positivity : (0 : ℝ) < b * N)]
  have hkey : |(b : ℝ) * q - N| ≤ b := by
    rw [abs_le]
    constructor <;> linarith
  calc |(b : ℝ) * q - (N : ℝ)| / ((b : ℝ) * N) ≤ (b : ℝ) / ((b : ℝ) * N) := by
        gcongr
    _ = 1 / N := by field_simp

/-! ## The `b`-adic `a n + 1` maps -/

/-- The `b`-adic accelerated map: divide by `b` when possible, else `a n + 1`. -/
def stepB (b a n : ℕ) : ℕ := if n % b = 0 then n / b else a * n + 1

/-- Its one-step phase ratio. -/
noncomputable def ratioB (b a n : ℕ) : ℝ := (stepB b a n : ℝ) / (n : ℝ)

/-- The associated cutoff transform. -/
noncomputable def FB (b a : ℕ) (ω : ℝ) (N : ℕ) : ℂ := Fgen (ratioB b a) ω N

lemma ratioB_of_dvd {b n : ℕ} (hb : 0 < b) (hn : n % b = 0) (hpos : n ≠ 0) (a : ℕ) :
    ratioB b a n = 1 / b := by
  have hmul : n / b * b = n := Nat.div_mul_cancel (Nat.dvd_of_mod_eq_zero hn)
  have hcast : ((n / b : ℕ) : ℝ) * b = (n : ℝ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) hmul
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  have hb0 : (b : ℝ) ≠ 0 := by positivity
  unfold ratioB stepB
  rw [if_pos hn]
  field_simp
  linarith [hcast]

lemma ratioB_of_not_dvd {b n : ℕ} (hn : ¬ n % b = 0) (a : ℕ) :
    ratioB b a n = (a : ℝ) + 1 / n := by
  have hpos : n ≠ 0 := by
    intro h
    rw [h] at hn
    simp at hn
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos
  unfold ratioB stepB
  rw [if_neg hn]
  push_cast
  field_simp

/-- **No resonances for base `b ≥ 3`.**  The `b`-adic `a n + 1` map has a
one-step transform of full linear size at *every* real frequency: the "divide"
branch has density `1/b < 1/2`, so the multiplicative branch dominates and
destructive interference is impossible. -/
theorem b_adic_no_resonance {b : ℕ} (hb : 3 ≤ b) (a : ℕ) (ω : ℝ) :
    ∀ᶠ N : ℕ in atTop, ((b : ℝ) - 2) / (2 * b) * N ≤ ‖FB b a ω N‖ := by
  classical
  have hb0 : 0 < b := by omega
  have hbR : (3 : ℝ) ≤ b := by exact_mod_cast hb
  have hdens : Tendsto (fun N : ℕ =>
      (((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℝ) / N)
      atTop (𝓝 (1 - 1 / b)) := by
    have hcard : ∀ N : ℕ, (((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℝ)
        = (N : ℝ) - (((Finset.range N).filter (fun k => (k + 1) % b = 0)).card : ℝ) := by
      intro N
      have hsum := Finset.card_filter_add_card_filter_not
        (s := Finset.range N) (p := fun k => (k + 1) % b = 0)
      rw [Finset.card_range] at hsum
      have hsumR : ((((Finset.range N).filter (fun k => (k + 1) % b = 0)).card : ℕ) : ℝ)
          + ((((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℕ) : ℝ)
          = (N : ℝ) := by exact_mod_cast hsum
      linarith
    have hlim := (tendsto_card_multiples_div hb0)
    have hone : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
    have hcombo := hone.sub hlim
    refine hcombo.congr' ?_
    filter_upwards [eventually_ge_atTop 1] with N hN1
    have hN0 : (N : ℝ) ≠ 0 := by
      have : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
      exact ne_of_gt this
    rw [hcard N]
    field_simp
  have hphase : Tendsto (fun k : ℕ =>
      if ¬ ((k + 1) % b = 0) then ratioB b a (k + 1) - (a : ℝ) else 0) atTop (𝓝 0) := by
    have hbnd : ∀ k : ℕ, ‖(if ¬ ((k + 1) % b = 0) then ratioB b a (k + 1) - (a : ℝ) else 0)‖
        ≤ 1 / ((k : ℝ) + 1) := by
      intro k
      by_cases h : ¬ ((k + 1) % b = 0)
      · rw [if_pos h, ratioB_of_not_dvd h a]
        have : (a : ℝ) + 1 / ((k + 1 : ℕ) : ℝ) - (a : ℝ) = 1 / ((k : ℝ) + 1) := by
          push_cast
          ring
        rw [this, Real.norm_eq_abs, abs_of_pos (by positivity)]
      · rw [if_neg h, norm_zero]
        positivity
    refine squeeze_zero_norm hbnd ?_
    have h1 : Tendsto (fun k : ℕ => (k : ℝ) + 1) atTop atTop :=
      tendsto_atTop_add_const_right _ 1 (tendsto_natCast_atTop_atTop (R := ℝ))
    simpa using h1.inv_tendsto_atTop
  have hd : 1 / 2 < 1 - 1 / (b : ℝ) := by
    rw [lt_sub_iff_add_lt, div_add_div _ _ (by norm_num) (by positivity),
      div_lt_one (by positivity)]
    nlinarith [hbR]
  have := dominant_branch_half_bound (ratioB b a) (a : ℝ) ω (1 - 1 / b)
    (fun k => ¬ ((k + 1) % b = 0)) hd hdens hphase
  filter_upwards [this] with N hN
  refine le_trans (le_of_eq ?_) hN
  have hbne : (b : ℝ) ≠ 0 := by positivity
  field_simp
  ring

/-- **The sharp `b`-adic constant, up to `ε`.**  For `b ≥ 3` and any `ε > 0` the
transform eventually satisfies `‖FB b a ω N‖ ≥ (1 - 2/b - ε) N` at every
frequency.  The constant `1 - 2/b` is the difference of the two branch weights
`1 - 1/b` and `1/b`, and matches the numerically observed minimum. -/
theorem b_adic_no_resonance_sharp {b : ℕ} (hb : 3 ≤ b) (a : ℕ) (ω : ℝ) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ N : ℕ in atTop, (1 - 2 / (b : ℝ) - ε) * N ≤ ‖FB b a ω N‖ := by
  classical
  have hb0 : 0 < b := by omega
  have hbne : (b : ℝ) ≠ 0 := by positivity
  have hdens : Tendsto (fun N : ℕ =>
      (((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℝ) / N)
      atTop (𝓝 (1 - 1 / b)) := by
    have hcard : ∀ N : ℕ, (((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℝ)
        = (N : ℝ) - (((Finset.range N).filter (fun k => (k + 1) % b = 0)).card : ℝ) := by
      intro N
      have hsum := Finset.card_filter_add_card_filter_not
        (s := Finset.range N) (p := fun k => (k + 1) % b = 0)
      rw [Finset.card_range] at hsum
      have hsumR : ((((Finset.range N).filter (fun k => (k + 1) % b = 0)).card : ℕ) : ℝ)
          + ((((Finset.range N).filter (fun k => ¬ ((k + 1) % b = 0))).card : ℕ) : ℝ)
          = (N : ℝ) := by exact_mod_cast hsum
      linarith
    have hlim := tendsto_card_multiples_div hb0
    have hone : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
    have hcombo := hone.sub hlim
    refine hcombo.congr' ?_
    filter_upwards [eventually_ge_atTop 1] with N hN1
    have hN0 : (N : ℝ) ≠ 0 := by
      have : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
      exact ne_of_gt this
    rw [hcard N]
    field_simp
  have hphase : Tendsto (fun k : ℕ =>
      if ¬ ((k + 1) % b = 0) then ratioB b a (k + 1) - (a : ℝ) else 0) atTop (𝓝 0) := by
    have hbnd : ∀ k : ℕ, ‖(if ¬ ((k + 1) % b = 0) then ratioB b a (k + 1) - (a : ℝ) else 0)‖
        ≤ 1 / ((k : ℝ) + 1) := by
      intro k
      by_cases h : ¬ ((k + 1) % b = 0)
      · rw [if_pos h, ratioB_of_not_dvd h a]
        have hrw : (a : ℝ) + 1 / ((k + 1 : ℕ) : ℝ) - (a : ℝ) = 1 / ((k : ℝ) + 1) := by
          push_cast
          ring
        rw [hrw, Real.norm_eq_abs, abs_of_pos (by positivity)]
      · rw [if_neg h, norm_zero]
        positivity
    refine squeeze_zero_norm hbnd ?_
    have h1 : Tendsto (fun k : ℕ => (k : ℝ) + 1) atTop atTop :=
      tendsto_atTop_add_const_right _ 1 (tendsto_natCast_atTop_atTop (R := ℝ))
    simpa using h1.inv_tendsto_atTop
  have hlt : 1 - 2 / (b : ℝ) - ε < 2 * (1 - 1 / (b : ℝ)) - 1 := by
    have : 2 * (1 - 1 / (b : ℝ)) - 1 = 1 - 2 / (b : ℝ) := by field_simp; ring
    rw [this]
    linarith
  exact dominant_branch_lower_bound (ratioB b a) (a : ℝ) ω (1 - 1 / b) (1 - 2 / (b : ℝ) - ε)
    (fun k => ¬ ((k + 1) % b = 0)) hlt hdens hphase

/-- At base `2` the transform is the classical one. -/
lemma FB_two (a : ℕ) (ω : ℝ) (N : ℕ) : FB 2 a ω N = F a ω N := rfl

/-- **Halving is the unique resonant base.**  For the classical base `b = 2` the
one-step transform of the `3n+1` map has a genuine spectral gap at `ω = 1/5`
(full cancellation), whereas for every base `b ≥ 3` and every multiplier the
transform keeps linear size at every frequency.  The spectral gaps of the
`a n + 1` maps are therefore a phenomenon of the balanced base `2`, not of the
arithmetic of the multiplier. -/
theorem halving_is_the_unique_resonant_base :
    Tendsto (fun N : ℕ => FB 2 3 (1 / 5) N / (N : ℂ)) atTop (𝓝 0) ∧
    ∀ b : ℕ, 3 ≤ b → ∀ (a : ℕ) (ω : ℝ),
      ∀ᶠ N : ℕ in atTop, ((b : ℝ) - 2) / (2 * b) * N ≤ ‖FB b a ω N‖ := by
  refine ⟨?_, fun b hb a ω => b_adic_no_resonance hb a ω⟩
  have h := tendsto_F_div 3 (1 / 5 : ℝ)
  rw [resonance_three_one_fifth] at h
  simpa [FB_two] using h

/-! ## Sharpness of the density threshold `1/2` -/

/-- **The threshold `d > 1/2` in the dominant-branch principle is sharp.**  For the
classical `3n+1` map at the resonant frequency `ω = 1/5` all hypotheses of
`dominant_branch_lower_bound` hold with the branch `D = {k : k even}` of density
exactly `1/2` (the phases converge to `3` along `D`), yet the conclusion fails for
*every* positive constant: the transform is `o(N)`.  Density strictly above `1/2`
is therefore not a technical artefact of the proof. -/
theorem dominant_branch_threshold_sharp :
    Tendsto (fun N : ℕ => (((Finset.range N).filter (fun k => ¬ ((k + 1) % 2 = 0))).card : ℝ) / N)
        atTop (𝓝 (1 / 2)) ∧
    Tendsto (fun k : ℕ => if ¬ ((k + 1) % 2 = 0) then ratio 3 (k + 1) - 3 else 0)
        atTop (𝓝 0) ∧
    ∀ c : ℝ, 0 < c → ¬ (∀ᶠ N : ℕ in atTop, c * N ≤ ‖Fgen (ratio 3) (1 / 5) N‖) := by
  classical
  refine ⟨?_, ?_, ?_⟩
  · -- the even indices have density exactly `1/2`
    have hcard : ∀ N : ℕ, (((Finset.range N).filter (fun k => ¬ ((k + 1) % 2 = 0))).card : ℝ)
        = (N : ℝ) - (((Finset.range N).filter (fun k => (k + 1) % 2 = 0)).card : ℝ) := by
      intro N
      have hsum := Finset.card_filter_add_card_filter_not
        (s := Finset.range N) (p := fun k => (k + 1) % 2 = 0)
      rw [Finset.card_range] at hsum
      have hsumR : ((((Finset.range N).filter (fun k => (k + 1) % 2 = 0)).card : ℕ) : ℝ)
          + ((((Finset.range N).filter (fun k => ¬ ((k + 1) % 2 = 0))).card : ℕ) : ℝ)
          = (N : ℝ) := by exact_mod_cast hsum
      linarith
    have hlim := tendsto_card_multiples_div (b := 2) (by norm_num)
    have hone : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 1) := tendsto_const_nhds
    have hcombo := hone.sub hlim
    have hval : (1 : ℝ) - 1 / (2 : ℕ) = 1 / 2 := by norm_num
    rw [hval] at hcombo
    refine hcombo.congr' ?_
    filter_upwards [eventually_ge_atTop 1] with N hN1
    have hN0 : (N : ℝ) ≠ 0 := by
      have : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
      exact ne_of_gt this
    rw [hcard N]
    field_simp
  · -- along the even indices the phase tends to the multiplier `3`
    have hbnd : ∀ k : ℕ, ‖(if ¬ ((k + 1) % 2 = 0) then ratio 3 (k + 1) - 3 else 0)‖
        ≤ 1 / ((k : ℝ) + 1) := by
      intro k
      by_cases h : ¬ ((k + 1) % 2 = 0)
      · have hodd : (k + 1) % 2 = 1 := by omega
        rw [if_pos h, ratio_odd hodd 3]
        have hrw : ((3 : ℕ) : ℝ) + 1 / ((k + 1 : ℕ) : ℝ) - 3 = 1 / ((k : ℝ) + 1) := by
          push_cast
          ring
        rw [hrw, Real.norm_eq_abs, abs_of_pos (by positivity)]
      · rw [if_neg h, norm_zero]
        positivity
    refine squeeze_zero_norm hbnd ?_
    have h1 : Tendsto (fun k : ℕ => (k : ℝ) + 1) atTop atTop :=
      tendsto_atTop_add_const_right _ 1 (tendsto_natCast_atTop_atTop (R := ℝ))
    simpa using h1.inv_tendsto_atTop
  · -- yet the transform is `o(N)` at the resonant frequency
    intro c hc hcon
    have hlim : Tendsto (fun N : ℕ => ‖F 3 (1 / 5) N / (N : ℂ)‖) atTop (𝓝 0) := by
      have := tendsto_F_div 3 (1 / 5 : ℝ)
      rw [resonance_three_one_fifth] at this
      simpa using this.norm
    have hsmall : ∀ᶠ N : ℕ in atTop, ‖F 3 (1 / 5) N / (N : ℂ)‖ < c :=
      hlim.eventually (eventually_lt_nhds hc)
    obtain ⟨N, hN1, hNc, hNs⟩ := ((eventually_ge_atTop 1).and (hcon.and hsmall)).exists
    have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN1
    rw [norm_div, Complex.norm_natCast, div_lt_iff₀ hN0] at hNs
    rw [← F_eq_Fgen] at hNc
    linarith [hNs, hNc]

end CollatzSpectral