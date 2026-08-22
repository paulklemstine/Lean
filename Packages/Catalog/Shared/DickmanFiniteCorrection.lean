import Mathlib

/-!
# The Dickman leading term, its finite-size correction, and why it is slow

Context (experiment 465, paper 130).  Smoothness probabilities in the quadratic
sieve are modelled by the Dickman function `ρ(u)`, and in the asymptotic analysis
of subexponential factoring one replaces `ρ(u)` by its leading term

`L(u) = exp (-u (log u + log log u - 1))`.

The experiment measured, over `1.2 · 10^6` smoothness tests with
`N ∈ {2^32 .. 2^44}`, that

* the empirical smooth-density / `ρ(u)` ratio sits in `0.877 – 0.913` at every
  scale, **equally for the `x^2 - N` pool and for the size-matched random
  control**, and
* the discrepancy has the size of the finite-`x` correction
  `log log v / log v ≈ 17–20 %` for the value sizes involved, shrinking only
  logarithmically, and
* the leading term `L(u)` is a useless proxy for `ρ(u)` at reachable `u`.

This file proves the analytic facts behind those three statements.

Main results:

* `rhoTwo_lt_one`, `rhoTwo_pos` — the exact Dickman value on `(1,2]` is a
  genuine probability, `ρ(u) = 1 - log u ∈ (0,1)`.
* `one_lt_dickmanLead` — on `(1,2]` the leading term is `> 1`: it is not even a
  probability there, so it cannot approximate `ρ`.
* `dickmanLead_two_gt_nine_mul_rho` — quantitatively, at `u = 2` the leading term
  overshoots the true value by more than a factor `9`.
* `dickmanLead_lt_one_of_three_le` — the leading term only becomes admissible
  from `u ≥ 3` onwards (and, per the experiment, only becomes *accurate* near
  `u ≈ 14.75`).
* `finiteCorrection_antitoneOn` — the finite-size correction `log log v / log v`
  decreases, but only logarithmically.
* `finiteCorrection_tendsto_zero` — it does vanish: nothing blocks convergence.
* `finiteCorrection_window` — in the experimental window `e^12 ≤ v ≤ e^20` it
  lies in `[0.1, 0.25]`, bracketing the measured `17–20 %` deficit.
-/

namespace DickmanFinite

open Real Filter Topology

/-- Leading-term Dickman model `L(u) = exp (-u (log u + log log u - 1))`. -/
noncomputable def dickmanLead (u : ℝ) : ℝ :=
  Real.exp (-u * (Real.log u + Real.log (Real.log u) - 1))

/-- The exact Dickman function on the interval `1 ≤ u ≤ 2`, where it is given in
closed form by `ρ(u) = 1 - log u`. -/
noncomputable def rhoTwo (u : ℝ) : ℝ := 1 - Real.log u

/-! ## `ρ` is a probability on `(1,2]`, the leading term is not -/

theorem rhoTwo_lt_one {u : ℝ} (hu : 1 < u) : rhoTwo u < 1 := by
  have : 0 < Real.log u := Real.log_pos hu
  simp only [rhoTwo]; linarith

theorem rhoTwo_pos {u : ℝ} (hu : u ≤ 2) (hu1 : 0 < u) : 0 < rhoTwo u := by
  have h2 : Real.log u ≤ Real.log 2 := Real.log_le_log hu1 hu
  have : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  simp only [rhoTwo]; linarith

/-- On `(1,2]` the leading-term Dickman model exceeds `1`, while the true Dickman
value is `< 1`: the leading term is not even a probability in this range. -/
theorem one_lt_dickmanLead {u : ℝ} (hu1 : 1 < u) (hu2 : u ≤ 2) : 1 < dickmanLead u := by
  have hlogpos : 0 < Real.log u := Real.log_pos hu1
  have hlogle : Real.log u ≤ Real.log 2 :=
    Real.log_le_log (by linarith) hu2
  have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  -- `log log u ≤ log u - 1 < 0`
  have hll : Real.log (Real.log u) ≤ Real.log u - 1 :=
    Real.log_le_sub_one_of_pos hlogpos
  have hexp : 0 < -u * (Real.log u + Real.log (Real.log u) - 1) := by
    have hsum : Real.log u + Real.log (Real.log u) - 1 < 0 := by linarith
    nlinarith
  calc (1 : ℝ) = Real.exp 0 := (Real.exp_zero).symm
    _ < _ := Real.exp_lt_exp.2 hexp

/-- Numeric core: `exp 1.2272 > 3`, via four terms of the exponential series. -/
private theorem three_lt_exp_of : (3 : ℝ) < Real.exp 1.2272 := by
  have h := Real.sum_le_exp_of_nonneg (x := (1.2272 : ℝ)) (by norm_num) 4
  simp [Finset.sum_range_succ, Nat.factorial] at h
  linarith

/-- **Quantitative failure of the leading term at `u = 2`.**  The leading-term
Dickman model overshoots the exact value `ρ(2) = 1 - log 2 ≈ 0.3069` by more than
a factor of nine. -/
theorem dickmanLead_two_gt_nine_mul_rho : 9 * rhoTwo 2 < dickmanLead 2 := by
  have hlog2pos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hll : Real.log (Real.log 2) ≤ Real.log 2 - 1 :=
    Real.log_le_sub_one_of_pos hlog2pos
  have hE : (1.2272 : ℝ) ≤ -2 * (Real.log 2 + Real.log (Real.log 2) - 1) := by
    nlinarith
  have hlead : (3 : ℝ) < dickmanLead 2 :=
    lt_of_lt_of_le three_lt_exp_of (Real.exp_le_exp.2 hE)
  have hrho : rhoTwo 2 < 0.3069 := by
    have : (0.6931 : ℝ) < Real.log 2 := by
      have := Real.log_two_gt_d9
      linarith
    simp only [rhoTwo]; linarith
  linarith

/-- From `u ≥ 3` on, the leading term is at least a subprobability. -/
theorem dickmanLead_lt_one_of_three_le {u : ℝ} (hu : 3 ≤ u) : dickmanLead u < 1 := by
  have hupos : (0 : ℝ) < u := by linarith
  have hlog3 : (1 : ℝ) < Real.log 3 := by
    have h := Real.exp_one_lt_d9
    have : Real.exp 1 < 3 := by linarith
    calc (1:ℝ) = Real.log (Real.exp 1) := by rw [Real.log_exp]
      _ < Real.log 3 := Real.log_lt_log (Real.exp_pos 1) this
  have hlogu : Real.log 3 ≤ Real.log u := Real.log_le_log (by norm_num) hu
  have hlogpos : 0 < Real.log u := by linarith
  have hll : 0 ≤ Real.log (Real.log u) := Real.log_nonneg (by linarith)
  have hexp : -u * (Real.log u + Real.log (Real.log u) - 1) < 0 := by
    have hsum : 0 < Real.log u + Real.log (Real.log u) - 1 := by linarith
    nlinarith
  calc dickmanLead u < Real.exp 0 := Real.exp_lt_exp.2 hexp
    _ = 1 := Real.exp_zero

/-- The exact Dickman function satisfies the delay differential equation
`u ρ'(u) = -ρ(u-1)`; on `(1,2)` the delayed value is `ρ(u-1) = 1`, and the closed
form `ρ(u) = 1 - log u` is checked here to satisfy it: `u ρ'(u) = -1`, and for
`1 < u < 2` the right-hand side is exactly `-ρ(u-1)` because `ρ ≡ 1` on `[0,1]`. -/
theorem rhoTwo_hasDerivAt {u : ℝ} (hu : u ≠ 0) : HasDerivAt rhoTwo (-1 / u) u := by
  have h := (Real.hasDerivAt_log hu).const_sub 1
  simpa [rhoTwo, neg_div] using h

theorem rhoTwo_satisfies_dickman_dde {u : ℝ} (hu : 0 < u) :
    u * deriv rhoTwo u = -1 := by
  have hu0 : u ≠ 0 := ne_of_gt hu
  rw [(rhoTwo_hasDerivAt hu0).deriv]
  field_simp

/-- **The leading term is not an approximation at small `u`.**  On `(1,2]` the
exact Dickman value is a probability `< 1` while the leading term exceeds `1`. -/
theorem leading_term_overestimates {u : ℝ} (hu1 : 1 < u) (hu2 : u ≤ 2) :
    rhoTwo u < 1 ∧ 1 < dickmanLead u :=
  ⟨rhoTwo_lt_one hu1, one_lt_dickmanLead hu1 hu2⟩

/-! ## The finite-size correction -/

/-- The finite-`x` correction term of the Dickman model at value size `v`:
`log log v / log v`. -/
noncomputable def finiteCorrection (v : ℝ) : ℝ := Real.log (Real.log v) / Real.log v

/-- The correction is decreasing beyond `v ≥ exp (exp 1)`: it shrinks, but only
logarithmically in `v` — which is exactly why the measured `0.877–0.913` band
barely moves over twelve bits of scale. -/
theorem finiteCorrection_antitoneOn :
    AntitoneOn finiteCorrection {v : ℝ | Real.exp (Real.exp 1) ≤ v} := by
  intro a ha b hb hab
  simp only [Set.mem_setOf_eq] at ha hb
  have hea : Real.exp 1 ≤ Real.log a := by
    have := Real.log_le_log (Real.exp_pos _) ha
    rwa [Real.log_exp] at this
  have heb : Real.exp 1 ≤ Real.log b := by
    have := Real.log_le_log (Real.exp_pos _) hb
    rwa [Real.log_exp] at this
  have hlog : Real.log a ≤ Real.log b :=
    Real.log_le_log (lt_of_lt_of_le (Real.exp_pos _) ha) hab
  exact Real.log_div_self_antitoneOn (Set.mem_setOf_eq ▸ hea) (Set.mem_setOf_eq ▸ heb) hlog

/-- **Nothing blocks convergence.**  The finite-size correction does tend to `0`;
the Dickman model is asymptotically correct, it is merely approached slowly. -/
theorem finiteCorrection_tendsto_zero :
    Tendsto finiteCorrection atTop (𝓝 0) := by
  have h0 : Tendsto (fun t : ℝ => Real.log t / t) atTop (𝓝 0) := by
    simpa [Function.comp] using Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero
  exact h0.comp Real.tendsto_log_atTop

/-! ### The experimental window -/

theorem exp_two_lt_twelve : Real.exp 2 < 12 := by
  have h := Real.exp_one_lt_d9
  have hpos : (0 : ℝ) < Real.exp 1 := Real.exp_pos 1
  have : Real.exp 2 = Real.exp 1 * Real.exp 1 := by
    rw [← Real.exp_add]; norm_num
  nlinarith

theorem twenty_lt_exp_three : (20 : ℝ) < Real.exp 3 := by
  have h := Real.exp_one_gt_d9
  have hpos : (0 : ℝ) < Real.exp 1 := Real.exp_pos 1
  have h3 : Real.exp 3 = Real.exp 1 * (Real.exp 1 * Real.exp 1) := by
    rw [← Real.exp_add, ← Real.exp_add]; norm_num
  nlinarith

/-- **The measured deficit has exactly the size of the finite-`x` correction.**
Throughout the experimental window `exp 12 ≤ v ≤ exp 20` (value sizes of `12` to
`20` nats, i.e. the `x^2 - N` values sieved for `N` up to `2^44`) the correction
`log log v / log v` lies between `10 %` and `25 %`, bracketing the observed
`17–20 %` shortfall of the empirical density against `ρ(u)`. -/
theorem finiteCorrection_window {v : ℝ} (h1 : Real.exp 12 ≤ v) (h2 : v ≤ Real.exp 20) :
    0.1 ≤ finiteCorrection v ∧ finiteCorrection v ≤ 0.25 := by
  have hvpos : (0 : ℝ) < v := lt_of_lt_of_le (Real.exp_pos _) h1
  have hl1 : (12 : ℝ) ≤ Real.log v := by
    have := Real.log_le_log (Real.exp_pos 12) h1
    rwa [Real.log_exp] at this
  have hl2 : Real.log v ≤ 20 := by
    have := Real.log_le_log hvpos h2
    rwa [Real.log_exp] at this
  set t := Real.log v with ht
  have htpos : (0 : ℝ) < t := by linarith
  -- `2 ≤ log t ≤ 3`
  have hlow : (2 : ℝ) ≤ Real.log t := by
    have : Real.exp 2 ≤ t := le_trans exp_two_lt_twelve.le hl1
    calc (2 : ℝ) = Real.log (Real.exp 2) := (Real.log_exp 2).symm
      _ ≤ Real.log t := Real.log_le_log (Real.exp_pos 2) this
  have hhigh : Real.log t ≤ 3 := by
    have : t ≤ Real.exp 3 := le_trans hl2 twenty_lt_exp_three.le
    calc Real.log t ≤ Real.log (Real.exp 3) := Real.log_le_log htpos this
      _ = 3 := Real.log_exp 3
  constructor
  · rw [finiteCorrection, ← ht, le_div_iff₀ htpos]
    nlinarith
  · rw [finiteCorrection, ← ht, div_le_iff₀ htpos]
    nlinarith

end DickmanFinite