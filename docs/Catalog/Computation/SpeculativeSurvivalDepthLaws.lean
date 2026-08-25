/-
# Depth laws for the speculative-decoding cost law

Second cycle of the NET-96 thread. `Computation.SpeculativeSurvivalCostLaw`
established the structure of the cost law
`gain c s d = (∑_{i<d} sᵢ)/(1 + c·d)`; here we push it to closed-form and
asymptotic statements for named survival families, and we extract the
*equilibrium law* that closes the micro→macro loop.

## Main results

* `marginal_neg_iff_survival_below_throughput`,
  `optimal_survival_below_throughput` : **the equilibrium law** — speculation
  should stop exactly at the first depth where the marginal survival drops below
  `c` times the throughput already achieved. This is the sharp micro↔macro link:
  a purely per-position quantity is compared against a purely aggregate one.
* `exists_optimal_of_marginal_neg` : a single sign change of the marginal
  produces a certified global optimum (via least-element / `Nat.find`).
* `geom_accept`, `geom_gain_improves_of_pow_ge`, `geom_depth_log_lower_bound` :
  for geometric survival `sᵢ = rⁱ` the optimal depth is at least
  `log((1−r)/c) / log(1/r)`, i.e. it grows logarithmically as the drafting
  overhead vanishes.
* `geom_exists_optimal_depth` : geometric survival always has a finite optimum.
* `harm_exists_optimal_depth` : even for the heavy-tailed harmonic (Zipf)
  survival profile, whose cumulative acceptance diverges, unbounded speculation
  is strictly suboptimal — a finite optimal depth exists. Uses divergence of the
  harmonic series.
* `no_universal_optimal_depth` : no single speculation depth is optimal for all
  registers; the block survival family realises every depth as its optimum. This
  is the abstract form of the measured prose/code split (4 vs 8).
-/

import Computation.SpeculativeSurvivalCostLaw

namespace Catalog.Computation.SpecDecode

open Finset Filter

/-! ## The equilibrium law -/

/-- **The equilibrium law (exact form).** Deepening speculation stops paying off
precisely when the marginal survival probability falls below `c` times the
throughput already achieved at that depth. -/
theorem marginal_neg_iff_survival_below_throughput {c : ℝ} (hc : 0 ≤ c) (s : ℕ → ℝ) (d : ℕ) :
    marginal c s d < 0 ↔ s d < c * gain c s d := by
  have hden : (0:ℝ) < 1 + c * d := denom_pos hc d
  rw [gain, marginal]
  rw [show c * (accept s d / (1 + c * d)) = c * accept s d / (1 + c * d) by ring]
  rw [lt_div_iff₀ hden]
  constructor <;> intro h <;> nlinarith

/-- **Micro meets macro.** At an optimal depth (one where the gain stops
improving) the per-position survival is strictly below `c ·` throughput; at every
earlier depth it is at least that. Together with `myopic_stopping_optimal` this
determines the optimum from the survival curve alone. -/
theorem optimal_survival_below_throughput {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} {d : ℕ}
    (hd : gain c s (d + 1) < gain c s d) : s d < c * gain c s d :=
  (marginal_neg_iff_survival_below_throughput hc s d).mp ((gain_succ_lt_iff hc s d).mp hd)

/-- A single sign change of the marginal certifies a global optimum: take the
least depth at which the marginal is negative. -/
theorem exists_optimal_of_marginal_neg {c : ℝ} (hc : 0 ≤ c) {s : ℕ → ℝ} (hs : Antitone s)
    (hex : ∃ d, marginal c s d < 0) :
    ∃ d0, marginal c s d0 < 0 ∧ ∀ d, gain c s d ≤ gain c s d0 := by
  classical
  refine ⟨Nat.find hex, Nat.find_spec hex, ?_⟩
  refine myopic_stopping_optimal hc hs ?_ (Nat.find_spec hex)
  intro e he
  have := Nat.find_min hex he
  linarith [not_lt.mp this]

/-! ## Geometric survival -/

/-- Geometric survival profile `sᵢ = rⁱ`: acceptance decays at a constant rate,
the standard model for draft-model agreement. -/
noncomputable def geomSurv (r : ℝ) : ℕ → ℝ := fun i => r ^ i

lemma geomSurv_antitone {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) : Antitone (geomSurv r) := by
  intro i j hij
  exact pow_le_pow_of_le_one h0 h1 hij

/-- Closed form for the cumulative acceptance of a geometric survival curve. -/
theorem geom_accept {r : ℝ} (hr : r ≠ 1) (d : ℕ) :
    accept (geomSurv r) d = (1 - r ^ d) / (1 - r) := by
  have h : accept (geomSurv r) d = ∑ i ∈ range d, r ^ i := rfl
  rw [h, geom_sum_eq hr, show r ^ d - 1 = -(1 - r ^ d) by ring,
    show r - 1 = -(1 - r) by ring, neg_div_neg_eq]

lemma geom_accept_le {r : ℝ} (h0 : 0 ≤ r) (h1 : r < 1) (d : ℕ) :
    accept (geomSurv r) d ≤ 1 / (1 - r) := by
  rw [geom_accept (ne_of_lt h1) d]
  have hpos : (0:ℝ) < 1 - r := by linarith
  rw [div_le_div_iff_of_pos_right hpos]
  have : (0:ℝ) ≤ r ^ d := pow_nonneg h0 d
  linarith

/-- **Deepening still pays while `rᵈ ≥ c/(1−r)`.** The optimal depth for
geometric survival is therefore at least the crossing point of `rᵈ` with the
overhead-to-tail-mass ratio. -/
theorem geom_gain_improves_of_pow_ge {c r : ℝ} (hc : 0 ≤ c) (h0 : 0 ≤ r) (h1 : r < 1)
    {d : ℕ} (hpow : c / (1 - r) ≤ r ^ d) :
    gain c (geomSurv r) d ≤ gain c (geomSurv r) (d + 1) := by
  rw [gain_le_succ_iff hc]
  have hpos : (0:ℝ) < 1 - r := by linarith
  have hpd : (0:ℝ) ≤ r ^ d := pow_nonneg h0 d
  have hA : accept (geomSurv r) d = (1 - r ^ d) / (1 - r) := geom_accept (ne_of_lt h1) d
  have hsd : geomSurv r d = r ^ d := rfl
  have hcd : (0:ℝ) ≤ c * d := mul_nonneg hc (Nat.cast_nonneg d)
  have hkey : c * accept (geomSurv r) d ≤ r ^ d := by
    rw [hA, mul_div_assoc']
    rw [div_le_iff₀ hpos]
    have h2 : c * (1 - r ^ d) ≤ c := by nlinarith
    nlinarith [(div_le_iff₀ hpos).mp hpow]
  rw [marginal, hsd]
  nlinarith

/-- **Logarithmic depth law.** For geometric survival with rate `r` and overhead
`c < 1 − r`, every depth below `log((1−r)/c)/log(1/r)` is still improving, so the
optimal speculation depth grows like `log(1/c)/log(1/r)` as the overhead
vanishes. -/
theorem geom_depth_log_lower_bound {c r : ℝ} (hc : 0 < c) (h0 : 0 < r) (h1 : r < 1)
    {d : ℕ} (hd : (d : ℝ) ≤ Real.log ((1 - r) / c) / Real.log (1 / r)) :
    gain c (geomSurv r) d ≤ gain c (geomSurv r) (d + 1) := by
  have hpos : (0:ℝ) < 1 - r := by linarith
  have hlogr : Real.log (1 / r) > 0 := by
    rw [one_div, Real.log_inv]
    have : Real.log r < 0 := Real.log_neg h0 h1
    linarith
  have hq : (0:ℝ) < c / (1 - r) := div_pos hc hpos
  have hrd : (0:ℝ) < r ^ d := pow_pos h0 d
  refine geom_gain_improves_of_pow_ge hc.le h0.le h1 ?_
  rw [← Real.log_le_log_iff hq hrd]
  have hlogpow : Real.log (r ^ d) = (d : ℝ) * Real.log r := Real.log_pow r d
  have hstep : (d : ℝ) * Real.log (1 / r) ≤ Real.log ((1 - r) / c) :=
    (le_div_iff₀ hlogr).mp hd
  have hinv : Real.log (c / (1 - r)) = - Real.log ((1 - r) / c) := by
    rw [← Real.log_inv]
    congr 1
    field_simp
  rw [hlogpow, hinv]
  have : Real.log (1 / r) = - Real.log r := by rw [one_div, Real.log_inv]
  nlinarith [hstep, this]

/-- **Matching upper bound.** Once `rᵈ(1+cd) < c` the marginal is negative, so no
depth beyond `d` can beat it: together with `geom_depth_log_lower_bound` the
optimal depth for geometric survival is `Θ(log(1/c))`. -/
theorem geom_depth_upper_bound {c r : ℝ} (hc : 0 ≤ c) (h0 : 0 ≤ r) (h1 : r < 1)
    {d : ℕ} (hd1 : 1 ≤ d) (hsmall : r ^ d * (1 + c * d) < c) :
    ∀ e, d ≤ e → gain c (geomSurv r) e ≤ gain c (geomSurv r) d := by
  have hpos : (0:ℝ) < 1 - r := by linarith
  have hA : accept (geomSurv r) d = (1 - r ^ d) / (1 - r) := geom_accept (ne_of_lt h1) d
  have hAone : (1:ℝ) ≤ accept (geomSurv r) d := by
    have hmono : accept (geomSurv r) 1 ≤ accept (geomSurv r) d := by
      have : ∀ n, accept (geomSurv r) n ≤ accept (geomSurv r) (n + 1) := by
        intro n
        rw [accept_succ]
        have : (0:ℝ) ≤ geomSurv r n := pow_nonneg h0 n
        linarith
      exact monotone_nat_of_le_succ this hd1
    have h1' : accept (geomSurv r) 1 = 1 := by
      simp [accept, geomSurv]
    linarith [h1' ▸ hmono]
  have hmarg : marginal c (geomSurv r) d < 0 := by
    have hsd : geomSurv r d = r ^ d := rfl
    rw [marginal, hsd]
    nlinarith [mul_le_mul_of_nonneg_left hAone hc]
  exact gain_le_of_marginal_neg hc (geomSurv_antitone h0 (le_of_lt h1)) hmarg

/-- A calibrated illustration: with the NET-96 overhead `c = 0.118` and a
geometric acceptance rate `r = 0.8`, the globally optimal speculation depth is
exactly 7 — between the two measured register optima (prose 4, code 8), as a
single-rate model must be. -/
theorem geom_example_optimal_depth_seven :
    ∀ d, gain (59/500) (geomSurv (4/5)) d ≤ gain (59/500) (geomSurv (4/5)) 7 := by
  have hc : (0:ℝ) ≤ 59/500 := by norm_num
  have hs : Antitone (geomSurv (4/5 : ℝ)) := geomSurv_antitone (by norm_num) (by norm_num)
  have h6 : (0:ℝ) ≤ marginal (59/500) (geomSurv (4/5)) 6 := by
    norm_num [marginal, accept, geomSurv, Finset.sum_range_succ]
  have h7 : marginal (59/500) (geomSurv (4/5)) 7 < 0 := by
    norm_num [marginal, accept, geomSurv, Finset.sum_range_succ]
  refine myopic_stopping_optimal hc hs ?_ h7
  intro e he
  exact le_trans h6 (marginal_antitone hc hs (by omega))

/-- Geometric survival always admits a finite globally optimal depth. -/
theorem geom_exists_optimal_depth {c r : ℝ} (hc : 0 < c) (h0 : 0 ≤ r) (h1 : r < 1) :
    ∃ d0, ∀ d, gain c (geomSurv r) d ≤ gain c (geomSurv r) d0 :=
  exists_global_max hc (geom_accept_le h0 h1)

/-! ## Harmonic (Zipf) survival: divergent acceptance, finite optimum -/

/-- Harmonic survival profile `sᵢ = 1/(i+1)`: the heaviest tail with vanishing
per-position acceptance, for which the cumulative acceptance still diverges. -/
noncomputable def harmSurv : ℕ → ℝ := fun i => 1 / ((i : ℝ) + 1)

lemma harmSurv_antitone : Antitone harmSurv := by
  intro i j hij
  have h1 : (0:ℝ) < (i : ℝ) + 1 := by positivity
  have h2 : ((i : ℝ) + 1) ≤ ((j : ℝ) + 1) := by
    have : (i : ℝ) ≤ (j : ℝ) := Nat.cast_le.mpr hij
    linarith
  exact one_div_le_one_div_of_le h1 h2

lemma harm_accept_tendsto :
    Tendsto (fun d => accept harmSurv d) atTop atTop := by
  simpa [accept, harmSurv] using Real.tendsto_sum_range_one_div_nat_succ_atTop

/-- **Even a Zipf acceptance profile has a finite optimal depth.** Although the
cumulative acceptance of `harmSurv` diverges, the verification cost `1 + c·d`
grows linearly, so the marginal eventually turns negative and the myopic
stopping rule yields a global optimum. -/
theorem harm_exists_optimal_depth {c : ℝ} (hc : 0 < c) :
    ∃ d0, marginal c harmSurv d0 < 0 ∧ ∀ d, gain c harmSurv d ≤ gain c harmSurv d0 := by
  refine exists_optimal_of_marginal_neg hc.le harmSurv_antitone ?_
  obtain ⟨D, hD⟩ := (harm_accept_tendsto.eventually_ge_atTop ((1 + c) / c + 1)).exists
  refine ⟨D, ?_⟩
  have hd1 : (0:ℝ) < (D : ℝ) + 1 := by positivity
  have hsmall : harmSurv D * (1 + c * D) ≤ 1 + c := by
    have hval : harmSurv D * (1 + c * D) = (1 + c * D) / ((D : ℝ) + 1) := by
      rw [harmSurv]; field_simp
    rw [hval, div_le_iff₀ hd1]
    nlinarith [Nat.cast_nonneg (α := ℝ) D]
  have hbig : (1 + c) < c * accept harmSurv D := by
    have hmul : c * ((1 + c) / c + 1) ≤ c * accept harmSurv D :=
      mul_le_mul_of_nonneg_left hD hc.le
    have hval : c * ((1 + c) / c + 1) = (1 + c) + c := by field_simp
    linarith [hval ▸ hmul]
  rw [marginal]
  linarith

/-! ## No register-independent optimal depth -/

/-- Block survival: perfect acceptance for the first `N` positions, none after.
A crude but legitimate survival curve (values in `[0,1]`, antitone). -/
noncomputable def blockSurv (N : ℕ) : ℕ → ℝ := fun i => if i < N then 1 else 0

lemma blockSurv_antitone (N : ℕ) : Antitone (blockSurv N) := by
  intro i j hij
  unfold blockSurv
  by_cases hj : j < N
  · simp [hj, lt_of_le_of_lt hij hj]
  · simp only [hj, if_false]
    split <;> norm_num

lemma blockSurv_mem_unit (N : ℕ) (i : ℕ) : 0 ≤ blockSurv N i ∧ blockSurv N i ≤ 1 := by
  unfold blockSurv; split <;> norm_num

lemma blockSurv_accept_of_le {N d : ℕ} (h : d ≤ N) : accept (blockSurv N) d = (d : ℝ) := by
  unfold accept blockSurv
  rw [Finset.sum_congr rfl (fun i hi => if_pos (lt_of_lt_of_le (mem_range.mp hi) h))]
  simp

/-- **No universal optimal depth.** For every candidate depth `d₀` there is a
legitimate survival curve for which depth `d₀+1` strictly beats `d₀`. Optimal
speculation depth is a property of the *register*, not of the decoder — the
abstract form of the measured prose (4) versus code (8) split. -/
theorem no_universal_optimal_depth {c : ℝ} (hc : 0 < c) (d0 : ℕ) :
    ∃ s : ℕ → ℝ, Antitone s ∧ (∀ i, 0 ≤ s i ∧ s i ≤ 1) ∧
      gain c s d0 < gain c s (d0 + 1) := by
  refine ⟨blockSurv (d0 + 1), blockSurv_antitone _, blockSurv_mem_unit _, ?_⟩
  have h1 : accept (blockSurv (d0 + 1)) d0 = (d0 : ℝ) :=
    blockSurv_accept_of_le (Nat.le_succ d0)
  have h2 : accept (blockSurv (d0 + 1)) (d0 + 1) = ((d0 : ℝ) + 1) := by
    have := blockSurv_accept_of_le (N := d0 + 1) (d := d0 + 1) le_rfl
    rw [this]; push_cast; ring
  have hden0 : (0:ℝ) < 1 + c * d0 := denom_pos hc.le d0
  have hden1 : (0:ℝ) < 1 + c * ((d0 : ℝ) + 1) := by nlinarith [Nat.cast_nonneg (α := ℝ) d0]
  rw [gain, gain, h1, h2]
  push_cast
  rw [div_lt_div_iff₀ hden0 hden1]
  nlinarith [Nat.cast_nonneg (α := ℝ) d0]

end Catalog.Computation.SpecDecode