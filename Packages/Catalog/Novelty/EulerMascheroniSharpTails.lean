/-
# Sharp two-sided summand asymptotics and quantitative tails for `γ`

This file continues the research thread on the Euler–Mascheroni constant that was
started in `Novelty/EulerMascheroniInformationBridge.lean`, where `γ` was realised
as the accumulated Kullback–Leibler divergence

  `γ = ∑ k, D(Exp(k+1) ‖ Exp(k+2))`,   `gammaTerm k = 1/(k+1) - log((k+2)/(k+1))`.

We prove here the four "future directions" that were left open there.

## Main results

* `gammaTerm_lower_bound` / `gammaTerm_upper_bound` — the *purely rational squeeze*
  `1/(2(k+2)^2) ≤ gammaTerm k ≤ 1/(2(k+1)^2)`, together with the sharper
  `gammaTerm_ge_tele : 1/(2(k+1)(k+2)) ≤ gammaTerm k`.
* `remainder_pos` and `remainder_le_inv_two_mul` — for `1 ≤ n`,
  `0 < γ - eulerMascheroniSeq n ≤ 1/(2n)`.
* `accelerated`, `abs_accelerated_error_le` — the midpoint-corrected sequence
  `accelerated n = eulerMascheroniSeq n + 1/(2(n+1))` satisfies the *explicit*
  `O(n⁻²)` bound `|γ - accelerated n| ≤ 1/(12(n+1)^2)` for **every** `n : ℕ`
  (no threshold is needed), and in fact `accelerated n ≤ γ`.
* `symKL_eq_sq_div` — the symmetrized divergence identity `D(a‖b)+D(b‖a) = (a-b)²/(ab)`,
  `summable_symKL_iff_of_ratio_bounds` — an exact summability criterion for chains of
  positive rates with bounded ratios, and its two test cases
  `hasSum_symKL_linear_rates` (polynomial rates: convergent, with sum exactly `1`)
  and `not_summable_symKL_geometric_rates` (geometric rates: always divergent).

## Method

Everything rests on two calculus lemmas for the *logarithmic ratio*
`Λ z = log(1+z) - log(1-z)` on `[0,1)`:

  `2z + 2z³/3 ≤ Λ z ≤ 2z/(1-z²)`,

each proved by exhibiting the derivative of the difference as an explicitly
nonnegative rational function (`4z⁴/(1-z²)` resp. `4z²/(1-z²)²`).  Substituting
`z = 1/(2m+1)` turns these into the two-sided rational estimate

  `2/(2m+1) + 2/(3(2m+1)³) ≤ log((m+1)/m) ≤ (2m+1)/(2m(m+1))`,

which is exactly what is needed to sandwich `gammaTerm` between two *telescoping*
sequences.  The upper telescoping sequence is the midpoint-corrected
`F m = 1/(2m) + 1/(12m²)`; the constant `1/12` is the classical Euler–Maclaurin
coefficient and the resulting bound is asymptotically sharp.
-/
import Mathlib
import Novelty.EulerMascheroniInformationBridge

open Real Filter Finset Topology
open EulerMascheroniInformationBridge

namespace EulerMascheroniSharpTails

/-! ## 1. Two calculus estimates for the logarithmic ratio -/

/-- The derivative of `z ↦ log(1+z) - log(1-z)` is `2/(1-z²)`. -/
theorem hasDerivAt_logRatio (x : ℝ) (hx0 : -1 < x) (hx1 : x < 1) :
    HasDerivAt (fun y : ℝ => Real.log (1 + y) - Real.log (1 - y)) (2 / (1 - x ^ 2)) x := by
  have hne1 : (1 : ℝ) + x ≠ 0 := by linarith
  have hne2 : (1 : ℝ) - x ≠ 0 := by linarith
  have h1 : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
    have hd : HasDerivAt (fun y : ℝ => 1 + y) 1 x := by
      simpa using (hasDerivAt_id x).const_add (1 : ℝ)
    simpa [one_div] using hd.log hne1
  have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-(1 / (1 - x))) x := by
    have hd : HasDerivAt (fun y : ℝ => 1 - y) (-1) x := by
      simpa using (hasDerivAt_id x).const_sub (1 : ℝ)
    simpa [one_div, neg_div] using hd.log hne2
  have h := h1.sub h2
  convert h using 1
  have hne3 : (1 : ℝ) - x ^ 2 ≠ 0 := by
    have hfac : (1 : ℝ) - x ^ 2 = (1 + x) * (1 - x) := by ring
    rw [hfac]; exact mul_ne_zero hne1 hne2
  field_simp
  ring

/-- **Upper estimate.** `log((1+z)/(1-z)) ≤ 2z/(1-z²)` on `[0,1)`; the difference has
derivative `4z²/(1-z²)² ≥ 0`. -/
theorem logRatio_le (z : ℝ) (hz0 : 0 ≤ z) (hz1 : z < 1) :
    Real.log (1 + z) - Real.log (1 - z) ≤ 2 * z / (1 - z ^ 2) := by
  set f : ℝ → ℝ := fun x => 2 * x / (1 - x ^ 2) - (Real.log (1 + x) - Real.log (1 - x)) with hf
  have key : ∀ x ∈ Set.Icc (0 : ℝ) z, HasDerivAt f (4 * x ^ 2 / (1 - x ^ 2) ^ 2) x := by
    intro x hx
    obtain ⟨hxl, hxr⟩ := hx
    have hx0 : (-1 : ℝ) < x := by linarith
    have hx1 : x < 1 := lt_of_le_of_lt hxr hz1
    have hne3 : (1 : ℝ) - x ^ 2 ≠ 0 := by nlinarith
    have hnum : HasDerivAt (fun y : ℝ => 2 * y) 2 x := by
      simpa using (hasDerivAt_id x).const_mul (2 : ℝ)
    have hden : HasDerivAt (fun y : ℝ => 1 - y ^ 2) (-(2 * x)) x := by
      have hp : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by simpa using hasDerivAt_pow 2 x
      simpa using hp.const_sub (1 : ℝ)
    have h := (hnum.div hden hne3).sub (hasDerivAt_logRatio x hx0 hx1)
    convert h using 1
    field_simp
    ring
  have hmono : MonotoneOn f (Set.Icc 0 z) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · exact fun x hx => (key x hx).continuousAt.continuousWithinAt
    · exact fun x hx => ((key x (interior_subset hx)).differentiableAt).differentiableWithinAt
    · intro x hx
      rw [(key x (interior_subset hx)).deriv]
      positivity
  have h0 : f 0 = 0 := by simp [hf]
  have hle := hmono (Set.left_mem_Icc.mpr hz0) (Set.right_mem_Icc.mpr hz0) hz0
  rw [h0] at hle
  simp only [hf] at hle
  linarith

/-- **Lower estimate.** `2z + 2z³/3 ≤ log((1+z)/(1-z))` on `[0,1)`; the difference has
derivative `2z⁴/(1-z²) ≥ 0`. -/
theorem le_logRatio (z : ℝ) (hz0 : 0 ≤ z) (hz1 : z < 1) :
    2 * z + 2 * z ^ 3 / 3 ≤ Real.log (1 + z) - Real.log (1 - z) := by
  set g : ℝ → ℝ := fun x => Real.log (1 + x) - Real.log (1 - x) - 2 * x - 2 * x ^ 3 / 3 with hg
  have key : ∀ x ∈ Set.Icc (0 : ℝ) z, HasDerivAt g (2 * x ^ 4 / (1 - x ^ 2)) x := by
    intro x hx
    obtain ⟨hxl, hxr⟩ := hx
    have hx0 : (-1 : ℝ) < x := by linarith
    have hx1 : x < 1 := lt_of_le_of_lt hxr hz1
    have hne3 : (1 : ℝ) - x ^ 2 ≠ 0 := by nlinarith
    have h1 := hasDerivAt_logRatio x hx0 hx1
    have h2 : HasDerivAt (fun y : ℝ => 2 * y) 2 x := by
      simpa using (hasDerivAt_id x).const_mul (2 : ℝ)
    have h3 : HasDerivAt (fun y : ℝ => 2 * y ^ 3 / 3) (2 * x ^ 2) x := by
      have hp : HasDerivAt (fun y : ℝ => y ^ 3) (3 * x ^ 2) x := by simpa using hasDerivAt_pow 3 x
      have := (hp.const_mul (2 : ℝ)).div_const 3
      convert this using 1
      ring
    have h := (h1.sub h2).sub h3
    convert h using 1
    field_simp
    ring
  have hmono : MonotoneOn g (Set.Icc 0 z) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · exact fun x hx => (key x hx).continuousAt.continuousWithinAt
    · exact fun x hx => ((key x (interior_subset hx)).differentiableAt).differentiableWithinAt
    · intro x hx
      rw [(key x (interior_subset hx)).deriv]
      obtain ⟨hxl, hxr⟩ := interior_subset hx
      have hx1 : x < 1 := lt_of_le_of_lt hxr hz1
      have hpos : (0 : ℝ) < 1 - x ^ 2 := by nlinarith
      positivity
  have h0 : g 0 = 0 := by simp [hg]
  have hle := hmono (Set.left_mem_Icc.mpr hz0) (Set.right_mem_Icc.mpr hz0) hz0
  rw [h0] at hle
  simp only [hg] at hle
  linarith

/-! ## 2. Rational two-sided bounds for `log((m+1)/m)` -/

/-- `log((m+1)/m) ≤ (2m+1)/(2m(m+1))` for `m ≥ 1` (the trapezoid bound). -/
theorem log_succ_div_le (m : ℝ) (hm : 1 ≤ m) :
    Real.log ((m + 1) / m) ≤ (2 * m + 1) / (2 * m * (m + 1)) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hd : (0 : ℝ) < 2 * m + 1 := by linarith
  set z : ℝ := 1 / (2 * m + 1) with hz
  have hz0 : 0 ≤ z := by positivity
  have hz1 : z < 1 := by
    rw [hz, div_lt_one hd]; linarith
  have h1 : (1 : ℝ) + z = (2 * m + 2) / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have h2 : (1 : ℝ) - z = 2 * m / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have hratio : Real.log (1 + z) - Real.log (1 - z) = Real.log ((m + 1) / m) := by
    rw [h1, h2, ← Real.log_div (by positivity) (by positivity)]
    congr 1
    field_simp
  have hrhs : 2 * z / (1 - z ^ 2) = (2 * m + 1) / (2 * m * (m + 1)) := by
    have hsq : (1 : ℝ) - z ^ 2 = 4 * m * (m + 1) / (2 * m + 1) ^ 2 := by
      rw [hz]; field_simp; ring
    rw [hsq, hz]
    field_simp
    ring
  have := logRatio_le z hz0 hz1
  rw [hratio, hrhs] at this
  exact this

/-- `2/(2m+1) + 2/(3(2m+1)³) ≤ log((m+1)/m)` for `m ≥ 1` (two terms of the
`artanh` expansion). -/
theorem le_log_succ_div (m : ℝ) (hm : 1 ≤ m) :
    2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3) ≤ Real.log ((m + 1) / m) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hd : (0 : ℝ) < 2 * m + 1 := by linarith
  set z : ℝ := 1 / (2 * m + 1) with hz
  have hz0 : 0 ≤ z := by positivity
  have hz1 : z < 1 := by
    rw [hz, div_lt_one hd]; linarith
  have h1 : (1 : ℝ) + z = (2 * m + 2) / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have h2 : (1 : ℝ) - z = 2 * m / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have hratio : Real.log (1 + z) - Real.log (1 - z) = Real.log ((m + 1) / m) := by
    rw [h1, h2, ← Real.log_div (by positivity) (by positivity)]
    congr 1
    field_simp
  have hlhs : 2 * z + 2 * z ^ 3 / 3 = 2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3) := by
    rw [hz]; field_simp
  have := le_logRatio z hz0 hz1
  rw [hratio, hlhs] at this
  exact this

/-! ## 3. Sharp two-sided bounds for the summands -/

/-- `gammaTerm` written in terms of the real parameter `m = k+1`. -/
theorem gammaTerm_eq_shift (k : ℕ) :
    gammaTerm k = 1 / ((k : ℝ) + 1) - Real.log ((((k : ℝ) + 1) + 1) / ((k : ℝ) + 1)) := by
  unfold gammaTerm
  rw [show ((k : ℝ) + 1 + 1) = (k : ℝ) + 2 by ring]

/-- The strong lower bound `1/(2(k+1)(k+2)) ≤ gammaTerm k`, obtained from the
trapezoid estimate for the logarithm. -/
theorem gammaTerm_ge_tele (k : ℕ) :
    1 / (2 * ((k : ℝ) + 1) * ((k : ℝ) + 2)) ≤ gammaTerm k := by
  set m : ℝ := (k : ℝ) + 1 with hm
  have hm1 : (1 : ℝ) ≤ m := by
    rw [hm]; have : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k; linarith
  have hm0 : (0 : ℝ) < m := by linarith
  have hlog := log_succ_div_le m hm1
  have hkey : 1 / m - (2 * m + 1) / (2 * m * (m + 1)) = 1 / (2 * m * (m + 1)) := by
    field_simp
    ring
  rw [gammaTerm_eq_shift k, ← hm]
  have h2 : ((k : ℝ) + 2) = m + 1 := by rw [hm]; ring
  rw [h2]
  linarith

/-- **Sharp rational lower bound (Future direction 1).**
`1/(2(k+2)^2) ≤ gammaTerm k` for every `k`. -/
theorem gammaTerm_lower_bound (k : ℕ) : 1 / (2 * ((k : ℝ) + 2) ^ 2) ≤ gammaTerm k := by
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  refine le_trans ?_ (gammaTerm_ge_tele k)
  refine one_div_le_one_div_of_le (by positivity) ?_
  nlinarith

/-- **Rational upper bound.** `gammaTerm k ≤ 1/(2(k+1)^2)`, the classical companion of
`gammaTerm_lower_bound`; together they give a purely rational squeeze of every summand. -/
theorem gammaTerm_upper_bound (k : ℕ) : gammaTerm k ≤ 1 / (2 * ((k : ℝ) + 1) ^ 2) := by
  set m : ℝ := (k : ℝ) + 1 with hm
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hm1 : (1 : ℝ) ≤ m := by rw [hm]; linarith
  have hm0 : (0 : ℝ) < m := by linarith
  have hlog := le_log_succ_div m hm1
  have hstep : 1 / m - (2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)) ≤ 1 / (2 * m ^ 2) := by
    rw [← sub_nonneg]
    have hkey : 1 / (2 * m ^ 2) - (1 / m - (2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)))
        = (16 * m ^ 2 + 12 * m + 3) / (6 * m ^ 2 * (2 * m + 1) ^ 3) := by
      field_simp
      ring
    rw [hkey]
    positivity
  rw [gammaTerm_eq_shift k, ← hm]
  linarith

/-! ## 4. Telescoping comparison series -/

/-- A nonincreasing sequence tending to `0` gives a telescoping `HasSum`. -/
theorem hasSum_telescoping (u : ℕ → ℝ) (hanti : ∀ k, u (k + 1) ≤ u k)
    (h0 : Tendsto u atTop (𝓝 0)) : HasSum (fun i => u i - u (i + 1)) (u 0) := by
  refine (hasSum_iff_tendsto_nat_of_nonneg (fun i => by linarith [hanti i]) _).mpr ?_
  have hsum : ∀ M, ∑ i ∈ Finset.range M, (u i - u (i + 1)) = u 0 - u M :=
    fun M => Finset.sum_range_sub' u M
  simp_rw [hsum]
  simpa using (tendsto_const_nhds (x := u 0) (f := atTop (α := ℕ))).sub h0

theorem tendsto_inv_linear (c : ℝ) (hc : 0 < c) (n : ℕ) :
    Tendsto (fun i : ℕ => 1 / (c * ((i : ℝ) + n + 1))) atTop (𝓝 0) := by
  have h : Tendsto (fun i : ℕ => ((i : ℝ) + n + 1)) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_right
    apply Filter.tendsto_atTop_add_const_right
    exact tendsto_natCast_atTop_atTop
  exact ((h.const_mul_atTop hc).inv_tendsto_atTop).congr fun i => (one_div _).symm

theorem tendsto_inv_sq (c : ℝ) (hc : 0 < c) (n : ℕ) :
    Tendsto (fun i : ℕ => 1 / (c * ((i : ℝ) + n + 1) ^ 2)) atTop (𝓝 0) := by
  have h : Tendsto (fun i : ℕ => ((i : ℝ) + n + 1)) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_right
    apply Filter.tendsto_atTop_add_const_right
    exact tendsto_natCast_atTop_atTop
  have hsq : Tendsto (fun i : ℕ => ((i : ℝ) + n + 1) ^ 2) atTop atTop := by
    simpa [pow_two] using h.atTop_mul_atTop₀ h
  exact ((hsq.const_mul_atTop hc).inv_tendsto_atTop).congr fun i => (one_div _).symm

/-- The per-term lower estimate: `gammaTerm k` dominates the telescoping increment
`1/(2(k+1)) - 1/(2(k+2))`. -/
theorem lowerTele_le_gammaTerm (k : ℕ) :
    1 / (2 * ((k : ℝ) + 1)) - 1 / (2 * ((k : ℝ) + 2)) ≤ gammaTerm k := by
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  refine le_trans (le_of_eq ?_) (gammaTerm_ge_tele k)
  field_simp
  ring

/-- The per-term upper estimate: `gammaTerm k` is dominated by the increment of the
midpoint-corrected sequence `F m = 1/(2m) + 1/(12m²)`.  This is the sharp step behind
the `1/(12(n+1)²)` acceleration bound. -/
theorem gammaTerm_le_upperTele (k : ℕ) :
    gammaTerm k ≤ (1 / (2 * ((k : ℝ) + 1)) + 1 / (12 * ((k : ℝ) + 1) ^ 2))
      - (1 / (2 * ((k : ℝ) + 2)) + 1 / (12 * ((k : ℝ) + 2) ^ 2)) := by
  set m : ℝ := (k : ℝ) + 1 with hm
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hm1 : (1 : ℝ) ≤ m := by rw [hm]; linarith
  have hm0 : (0 : ℝ) < m := by linarith
  have hlog := le_log_succ_div m hm1
  have hm2 : ((k : ℝ) + 2) = m + 1 := by rw [hm]; ring
  have hkey : 2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)
      - (1 / m - ((1 / (2 * m) + 1 / (12 * m ^ 2))
          - (1 / (2 * (m + 1)) + 1 / (12 * (m + 1) ^ 2))))
      = (2 * m ^ 2 + 2 * m + 1) / (12 * m ^ 2 * (m + 1) ^ 2 * (2 * m + 1) ^ 3) := by
    field_simp
    ring
  have hpos : (0 : ℝ) ≤ (2 * m ^ 2 + 2 * m + 1) / (12 * m ^ 2 * (m + 1) ^ 2 * (2 * m + 1) ^ 3) := by
    positivity
  rw [gammaTerm_eq_shift k, ← hm, hm2]
  linarith

/-! ## 5. The tail `γ - eulerMascheroniSeq n` -/

theorem summable_gammaTerm : Summable gammaTerm := hasSum_gammaTerm.summable

theorem summable_gammaTerm_shift (n : ℕ) : Summable (fun i : ℕ => gammaTerm (i + n)) :=
  (summable_nat_add_iff n).2 summable_gammaTerm

/-- The remainder of the approximation `eulerMascheroniSeq n ≈ γ` is exactly the tail
of the series of `gammaTerm`s. -/
theorem tail_eq (n : ℕ) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n = ∑' i : ℕ, gammaTerm (i + n) := by
  have h := Summable.sum_add_tsum_nat_add n summable_gammaTerm
  rw [hasSum_gammaTerm.tsum_eq, gammaTerm_partial_sum n] at h
  linarith

/-- The lower telescoping comparison series sums to `1/(2(n+1))`. -/
theorem hasSum_lowerTele (n : ℕ) :
    HasSum (fun i : ℕ => 1 / (2 * ((i : ℝ) + n + 1)) - 1 / (2 * ((i : ℝ) + n + 2)))
      (1 / (2 * ((n : ℝ) + 1))) := by
  have hanti : ∀ k : ℕ, 1 / (2 * (((k + 1 : ℕ) : ℝ) + n + 1)) ≤ 1 / (2 * ((k : ℝ) + n + 1)) := by
    intro k
    have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    refine one_div_le_one_div_of_le (by positivity) ?_
    push_cast
    linarith
  have h := hasSum_telescoping (fun i : ℕ => 1 / (2 * ((i : ℝ) + n + 1))) hanti
    (tendsto_inv_linear 2 (by norm_num) n)
  have hfun : (fun i : ℕ => 1 / (2 * ((i : ℝ) + n + 1)) - 1 / (2 * (((i + 1 : ℕ) : ℝ) + n + 1)))
      = fun i : ℕ => 1 / (2 * ((i : ℝ) + n + 1)) - 1 / (2 * ((i : ℝ) + n + 2)) := by
    funext i
    push_cast
    ring_nf
  rw [hfun] at h
  simpa using h

/-- The telescoping comparison series for `m ↦ 1/(2m) + 1/(c m²)` sums to
`1/(2(n+1)) + 1/(c(n+1)²)`. -/
theorem hasSum_invSqTele (c : ℝ) (hc : 0 < c) (n : ℕ) :
    HasSum (fun i : ℕ => (1 / (2 * ((i : ℝ) + n + 1)) + 1 / (c * ((i : ℝ) + n + 1) ^ 2))
        - (1 / (2 * ((i : ℝ) + n + 2)) + 1 / (c * ((i : ℝ) + n + 2) ^ 2)))
      (1 / (2 * ((n : ℝ) + 1)) + 1 / (c * ((n : ℝ) + 1) ^ 2)) := by
  set u : ℕ → ℝ := fun i => 1 / (2 * ((i : ℝ) + n + 1)) + 1 / (c * ((i : ℝ) + n + 1) ^ 2) with hu
  have hanti : ∀ k : ℕ, u (k + 1) ≤ u k := by
    intro k
    have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    have h1 : 1 / (2 * (((k + 1 : ℕ) : ℝ) + n + 1)) ≤ 1 / (2 * ((k : ℝ) + n + 1)) := by
      refine one_div_le_one_div_of_le (by positivity) ?_
      push_cast; linarith
    have h2 : 1 / (c * (((k + 1 : ℕ) : ℝ) + n + 1) ^ 2) ≤ 1 / (c * ((k : ℝ) + n + 1) ^ 2) := by
      refine one_div_le_one_div_of_le (by positivity) ?_
      push_cast; nlinarith
    simp only [hu]
    linarith
  have htend : Tendsto u atTop (𝓝 0) := by
    have := (tendsto_inv_linear 2 (by norm_num) n).add (tendsto_inv_sq c hc n)
    simpa [hu] using this
  have h := hasSum_telescoping u hanti htend
  have hfun : (fun i : ℕ => u i - u (i + 1))
      = fun i : ℕ => (1 / (2 * ((i : ℝ) + n + 1)) + 1 / (c * ((i : ℝ) + n + 1) ^ 2))
        - (1 / (2 * ((i : ℝ) + n + 2)) + 1 / (c * ((i : ℝ) + n + 2) ^ 2)) := by
    funext i
    simp only [hu]
    push_cast
    ring_nf
  rw [hfun] at h
  simpa [hu] using h

/-- **Lower tail bound**: `1/(2(n+1)) ≤ γ - eulerMascheroniSeq n`. -/
theorem tail_lower (n : ℕ) :
    1 / (2 * ((n : ℝ) + 1)) ≤ Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
  rw [tail_eq n]
  refine hasSum_le (fun i => ?_) (hasSum_lowerTele n) (summable_gammaTerm_shift n).hasSum
  have h := lowerTele_le_gammaTerm (i + n)
  push_cast at h
  convert h using 3

/-- **Upper tail bound**: `γ - eulerMascheroniSeq n ≤ 1/(2(n+1)) + 1/(12(n+1)²)`. -/
theorem tail_upper (n : ℕ) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n
      ≤ 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  rw [tail_eq n]
  refine hasSum_le (fun i => ?_) (summable_gammaTerm_shift n).hasSum (hasSum_invSqTele 12 (by norm_num) n)
  have h := gammaTerm_le_upperTele (i + n)
  push_cast at h
  convert h using 3

/-! ## 6. Quantitative remainder and midpoint acceleration -/

/-- **Future direction 2, positivity.** The lower approximants are strictly below `γ`. -/
theorem remainder_pos (n : ℕ) :
    0 < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
  have h := Real.eulerMascheroniSeq_lt_eulerMascheroniConstant n
  linarith

/-- **Future direction 2, upper bound.** For every positive `n`,
`γ - eulerMascheroniSeq n ≤ 1/(2n)`. -/
theorem remainder_le_inv_two_mul (n : ℕ) (hn : 1 ≤ n) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n ≤ 1 / (2 * (n : ℝ)) := by
  have hx : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hx0 : (0 : ℝ) < (n : ℝ) := by linarith
  have hstep : 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2) ≤ 1 / (2 * (n : ℝ)) := by
    rw [← sub_nonneg]
    have hkey : 1 / (2 * (n : ℝ)) - (1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2))
        = (5 * (n : ℝ) + 6) / (12 * (n : ℝ) * ((n : ℝ) + 1) ^ 2) := by
      field_simp
      ring
    rw [hkey]
    positivity
  exact le_trans (tail_upper n) hstep

/-- The midpoint-corrected approximant `accelerated n = eulerMascheroniSeq n + 1/(2(n+1))`. -/
noncomputable def accelerated (n : ℕ) : ℝ :=
  Real.eulerMascheroniSeq n + 1 / (2 * ((n : ℝ) + 1))

/-- The midpoint correction never overshoots: `accelerated n ≤ γ`. -/
theorem accelerated_le_gamma (n : ℕ) : accelerated n ≤ Real.eulerMascheroniConstant := by
  have h := tail_lower n
  unfold accelerated
  linarith

/-- **Future direction 3.** The midpoint-corrected sequence approximates `γ` with the
explicit inverse-square error bound `1/(12(n+1)²)`, valid for *every* `n : ℕ`
(no threshold is required). -/
theorem abs_accelerated_error_le (n : ℕ) :
    |Real.eulerMascheroniConstant - accelerated n| ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hlow := tail_lower n
  have hup := tail_upper n
  have hpos : (0 : ℝ) < 1 / (12 * ((n : ℝ) + 1) ^ 2) := by positivity
  rw [abs_le]
  unfold accelerated
  constructor <;> linarith

/-! ## 7. Symmetrized information tail (Future direction 4) -/

/-- The symmetrized (Jeffreys) divergence between two exponential laws. -/
noncomputable def symKL (a b : ℝ) : ℝ := exponentialKL a b + exponentialKL b a

/-- **Symmetrization identity.** `D(a‖b) + D(b‖a) = (a-b)²/(ab)`: the logarithms cancel
and only a rational function of the rates survives. -/
theorem symKL_eq_sq_div (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    symKL a b = (a - b) ^ 2 / (a * b) := by
  unfold symKL exponentialKL
  rw [Real.log_div ha.ne' hb.ne', Real.log_div hb.ne' ha.ne']
  field_simp
  ring

/-- The symmetrized divergence depends only on the ratio of the two rates. -/
theorem symKL_eq_ratio (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    symKL a b = (b / a - 1) ^ 2 / (b / a) := by
  rw [symKL_eq_sq_div a b ha hb]
  field_simp
  ring

/-- Elementary comparison: `(p-1)² ≤ C·(p-1)²/p` when `0 < p ≤ C`. -/
theorem sq_sub_one_le_const_mul (p C : ℝ) (hp : 0 < p) (hpC : p ≤ C) :
    (p - 1) ^ 2 ≤ C * ((p - 1) ^ 2 / p) := by
  have hkey : C * ((p - 1) ^ 2 / p) - (p - 1) ^ 2 = (C - p) * (p - 1) ^ 2 / p := by
    field_simp
  have hnn : 0 ≤ (C - p) * (p - 1) ^ 2 / p :=
    div_nonneg (mul_nonneg (by linarith) (sq_nonneg _)) hp.le
  linarith

/-- Elementary comparison: `(p-1)²/p ≤ (1/c)·(p-1)²` when `0 < c ≤ p`. -/
theorem div_sq_sub_one_le (p c : ℝ) (hc : 0 < c) (hp : 0 < p) (hcp : c ≤ p) :
    (p - 1) ^ 2 / p ≤ 1 / c * (p - 1) ^ 2 := by
  have hkey : 1 / c * (p - 1) ^ 2 - (p - 1) ^ 2 / p = (p - c) * (p - 1) ^ 2 / (c * p) := by
    field_simp
  have hnn : 0 ≤ (p - c) * (p - 1) ^ 2 / (c * p) :=
    div_nonneg (mul_nonneg (by linarith) (sq_nonneg _)) (by positivity)
  linarith

/-- **Exact summability criterion for a chain of positive rates.** If the successive
ratios of a chain of positive rates stay in a fixed interval `[c, C]` with `c > 0`, then
the symmetrized adjacent divergences are summable *iff* the squared ratio deviations
`(ρₙ - 1)²` are summable.  In particular summability is a statement purely about how fast
the ratios approach `1`. -/
theorem summable_symKL_iff_of_ratio_bounds (rate : ℕ → ℝ) (hpos : ∀ n, 0 < rate n)
    (c C : ℝ) (hc : 0 < c) (hlb : ∀ n, c ≤ rate (n + 1) / rate n)
    (hub : ∀ n, rate (n + 1) / rate n ≤ C) :
    Summable (fun n => symKL (rate n) (rate (n + 1))) ↔
      Summable (fun n => (rate (n + 1) / rate n - 1) ^ 2) := by
  have hrpos : ∀ n, 0 < rate (n + 1) / rate n := fun n => div_pos (hpos (n + 1)) (hpos n)
  have hterm : ∀ n, symKL (rate n) (rate (n + 1))
      = (rate (n + 1) / rate n - 1) ^ 2 / (rate (n + 1) / rate n) :=
    fun n => symKL_eq_ratio _ _ (hpos n) (hpos (n + 1))
  rw [summable_congr hterm]
  constructor
  · intro h
    exact Summable.of_nonneg_of_le (fun n => sq_nonneg _)
      (fun n => sq_sub_one_le_const_mul _ C (hrpos n) (hub n)) (h.mul_left C)
  · intro h
    exact Summable.of_nonneg_of_le (fun n => div_nonneg (sq_nonneg _) (hrpos n).le)
      (fun n => div_sq_sub_one_le _ c hc (hrpos n) (hlb n)) (h.mul_left (1 / c))

/-- **Test case 1 (polynomial rates).** For the arithmetic chain of rates `1, 2, 3, …`
the symmetrized adjacent divergences form a telescoping series with sum exactly `1`. -/
theorem hasSum_symKL_linear_rates :
    HasSum (fun n : ℕ => symKL ((n : ℝ) + 1) ((n : ℝ) + 2)) 1 := by
  have hanti : ∀ k : ℕ, 1 / (((k + 1 : ℕ) : ℝ) + 1) ≤ 1 / ((k : ℝ) + 1) := by
    intro k
    have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    refine one_div_le_one_div_of_le (by positivity) ?_
    push_cast
    linarith
  have h := hasSum_telescoping (fun i : ℕ => 1 / ((i : ℝ) + 1)) hanti
    tendsto_one_div_add_atTop_nhds_zero_nat
  have hfun : (fun i : ℕ => 1 / ((i : ℝ) + 1) - 1 / (((i + 1 : ℕ) : ℝ) + 1))
      = fun i : ℕ => symKL ((i : ℝ) + 1) ((i : ℝ) + 2) := by
    funext i
    have hk : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg i
    rw [symKL_eq_sq_div _ _ (by positivity) (by positivity)]
    push_cast
    field_simp
    ring
  rw [hfun] at h
  simpa using h

/-- **Test case 2 (geometric rates).** For a geometric chain of rates `1, r, r², …` with
`r ≠ 1` the symmetrized adjacent divergences are *constant* `(1-r)²/r`, hence never
summable: geometric chains carry an infinite symmetrized information tail. -/
theorem not_summable_symKL_geometric_rates (r : ℝ) (hr : 0 < r) (hne : r ≠ 1) :
    ¬ Summable (fun n : ℕ => symKL (r ^ n) (r ^ (n + 1))) := by
  have hterm : ∀ n : ℕ, symKL (r ^ n) (r ^ (n + 1)) = (1 - r) ^ 2 / r := by
    intro n
    have hpow : (0 : ℝ) < r ^ n := pow_pos hr n
    have hpow' : (0 : ℝ) < r ^ (n + 1) := pow_pos hr (n + 1)
    rw [symKL_eq_sq_div _ _ hpow hpow', pow_succ]
    field_simp
    ring
  intro h
  have hconst : Summable (fun _ : ℕ => (1 - r) ^ 2 / r) := (summable_congr hterm).1 h
  have hzero := hconst.tendsto_atTop_zero
  have hval : (0 : ℝ) = (1 - r) ^ 2 / r := tendsto_nhds_unique hzero tendsto_const_nhds
  have hsq : (1 - r) ^ 2 = 0 := by
    rcases div_eq_zero_iff.mp hval.symm with h1 | h2
    · exact h1
    · exact absurd h2 (ne_of_gt hr)
  have : r = 1 := by nlinarith
  exact hne this

/-! ## 8. Matching lower bound: the acceleration error is exactly of order `n⁻²` -/

/-- **Padé-type upper estimate.** `log((1+z)/(1-z)) ≤ 2z + 2z³/3 + 2z⁵/(5(1-z²))` on
`[0,1)`; the difference has derivative `4z⁶/(5(1-z²)²) ≥ 0`. -/
theorem logRatio_le_pade (z : ℝ) (hz0 : 0 ≤ z) (hz1 : z < 1) :
    Real.log (1 + z) - Real.log (1 - z) ≤ 2 * z + 2 * z ^ 3 / 3 + 2 * z ^ 5 / (5 * (1 - z ^ 2)) := by
  set f : ℝ → ℝ := fun x => 2 * x + 2 * x ^ 3 / 3 + 2 * x ^ 5 / (5 * (1 - x ^ 2))
      - (Real.log (1 + x) - Real.log (1 - x)) with hf
  have key : ∀ x ∈ Set.Icc (0 : ℝ) z, HasDerivAt f (4 * x ^ 6 / (5 * (1 - x ^ 2) ^ 2)) x := by
    intro x hx
    obtain ⟨hxl, hxr⟩ := hx
    have hx0 : (-1 : ℝ) < x := by linarith
    have hx1 : x < 1 := lt_of_le_of_lt hxr hz1
    have hne3 : (1 : ℝ) - x ^ 2 ≠ 0 := by nlinarith
    have hne4 : (5 : ℝ) * (1 - x ^ 2) ≠ 0 :=
      mul_ne_zero (by norm_num : (5 : ℝ) ≠ 0) hne3
    have h1 : HasDerivAt (fun y : ℝ => 2 * y) 2 x := by
      simpa using (hasDerivAt_id x).const_mul (2 : ℝ)
    have h2 : HasDerivAt (fun y : ℝ => 2 * y ^ 3 / 3) (2 * x ^ 2) x := by
      have hp : HasDerivAt (fun y : ℝ => y ^ 3) (3 * x ^ 2) x := by simpa using hasDerivAt_pow 3 x
      have hq := (hp.const_mul (2 : ℝ)).div_const 3
      convert hq using 1
      ring
    have hnum : HasDerivAt (fun y : ℝ => 2 * y ^ 5) (10 * x ^ 4) x := by
      have hp : HasDerivAt (fun y : ℝ => y ^ 5) (5 * x ^ 4) x := by simpa using hasDerivAt_pow 5 x
      have hq := hp.const_mul (2 : ℝ)
      convert hq using 1
      ring
    have hden : HasDerivAt (fun y : ℝ => 5 * (1 - y ^ 2)) (-(10 * x)) x := by
      have hp : HasDerivAt (fun y : ℝ => y ^ 2) (2 * x) x := by simpa using hasDerivAt_pow 2 x
      have hq := (hp.const_sub (1 : ℝ)).const_mul (5 : ℝ)
      convert hq using 1
      ring
    have h := ((h1.add h2).add (hnum.div hden hne4)).sub (hasDerivAt_logRatio x hx0 hx1)
    convert h using 1
    field_simp
    ring
  have hmono : MonotoneOn f (Set.Icc 0 z) := by
    apply monotoneOn_of_deriv_nonneg (convex_Icc _ _)
    · exact fun x hx => (key x hx).continuousAt.continuousWithinAt
    · exact fun x hx => ((key x (interior_subset hx)).differentiableAt).differentiableWithinAt
    · intro x hx
      rw [(key x (interior_subset hx)).deriv]
      obtain ⟨hxl, hxr⟩ := interior_subset hx
      have hx1 : x < 1 := lt_of_le_of_lt hxr hz1
      have hpos : (0 : ℝ) < 1 - x ^ 2 := by nlinarith
      positivity
  have h0 : f 0 = 0 := by simp [hf]
  have hle := hmono (Set.left_mem_Icc.mpr hz0) (Set.right_mem_Icc.mpr hz0) hz0
  rw [h0] at hle
  simp only [hf] at hle
  linarith

/-- Third-order rational upper bound for `log((m+1)/m)`. -/
theorem log_succ_div_le_pade (m : ℝ) (hm : 1 ≤ m) :
    Real.log ((m + 1) / m)
      ≤ 2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)
        + 1 / (10 * m * (m + 1) * (2 * m + 1) ^ 3) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hd : (0 : ℝ) < 2 * m + 1 := by linarith
  set z : ℝ := 1 / (2 * m + 1) with hz
  have hz0 : 0 ≤ z := by positivity
  have hz1 : z < 1 := by
    rw [hz, div_lt_one hd]; linarith
  have h1 : (1 : ℝ) + z = (2 * m + 2) / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have h2 : (1 : ℝ) - z = 2 * m / (2 * m + 1) := by
    rw [hz]; field_simp; ring
  have hratio : Real.log (1 + z) - Real.log (1 - z) = Real.log ((m + 1) / m) := by
    rw [h1, h2, ← Real.log_div (by positivity) (by positivity)]
    congr 1
    field_simp
  have hsq : (1 : ℝ) - z ^ 2 = 4 * m * (m + 1) / (2 * m + 1) ^ 2 := by
    rw [hz]; field_simp; ring
  have hrhs : 2 * z + 2 * z ^ 3 / 3 + 2 * z ^ 5 / (5 * (1 - z ^ 2))
      = 2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)
        + 1 / (10 * m * (m + 1) * (2 * m + 1) ^ 3) := by
    rw [hsq, hz]
    field_simp
    ring
  have h := logRatio_le_pade z hz0 hz1
  rw [hratio, hrhs] at h
  exact h

/-- The per-term *lower* estimate matching `gammaTerm_le_upperTele`: `gammaTerm k` dominates
the increment of `m ↦ 1/(2m) + 1/(14m²)`. -/
theorem lowerTeleSharp_le_gammaTerm (k : ℕ) :
    (1 / (2 * ((k : ℝ) + 1)) + 1 / (14 * ((k : ℝ) + 1) ^ 2))
      - (1 / (2 * ((k : ℝ) + 2)) + 1 / (14 * ((k : ℝ) + 2) ^ 2)) ≤ gammaTerm k := by
  set m : ℝ := (k : ℝ) + 1 with hm
  have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hm1 : (1 : ℝ) ≤ m := by rw [hm]; linarith
  have hm0 : (0 : ℝ) < m := by linarith
  have hlog := log_succ_div_le_pade m hm1
  have hm2 : ((k : ℝ) + 2) = m + 1 := by rw [hm]; ring
  have hkey : (1 / m - (2 / (2 * m + 1) + 2 / (3 * (2 * m + 1) ^ 3)
        + 1 / (10 * m * (m + 1) * (2 * m + 1) ^ 3)))
      - ((1 / (2 * m) + 1 / (14 * m ^ 2)) - (1 / (2 * (m + 1)) + 1 / (14 * (m + 1) ^ 2)))
      = (40 * m ^ 4 + 80 * m ^ 3 + 4 * m ^ 2 - 36 * m - 15)
          / (210 * m ^ 2 * (m + 1) ^ 2 * (2 * m + 1) ^ 3) := by
    field_simp
    ring
  have hnum : (0 : ℝ) ≤ 40 * m ^ 4 + 80 * m ^ 3 + 4 * m ^ 2 - 36 * m - 15 := by
    nlinarith [sq_nonneg (m - 1), sq_nonneg (m + 1), sq_nonneg m, hm1]
  have hpos : (0 : ℝ) ≤ (40 * m ^ 4 + 80 * m ^ 3 + 4 * m ^ 2 - 36 * m - 15)
      / (210 * m ^ 2 * (m + 1) ^ 2 * (2 * m + 1) ^ 3) :=
    div_nonneg hnum (by positivity)
  rw [gammaTerm_eq_shift k, ← hm, hm2]
  linarith

/-- **Sharp lower tail bound**: `1/(2(n+1)) + 1/(14(n+1)²) ≤ γ - eulerMascheroniSeq n`. -/
theorem tail_lower_sharp (n : ℕ) :
    1 / (2 * ((n : ℝ) + 1)) + 1 / (14 * ((n : ℝ) + 1) ^ 2)
      ≤ Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
  rw [tail_eq n]
  refine hasSum_le (fun i => ?_) (hasSum_invSqTele 14 (by norm_num) n)
    (summable_gammaTerm_shift n).hasSum
  have h := lowerTeleSharp_le_gammaTerm (i + n)
  push_cast at h
  convert h using 3

/-- **Two-sided `Θ(n⁻²)` acceleration error.** The midpoint-corrected approximants
satisfy `1/(14(n+1)²) ≤ γ - accelerated n ≤ 1/(12(n+1)²)` for every `n : ℕ`; in particular
the error is *never* smaller than an explicit inverse square, so no midpoint-type
correction of this shape can converge faster than quadratically. -/
theorem accelerated_error_two_sided (n : ℕ) :
    1 / (14 * ((n : ℝ) + 1) ^ 2) ≤ Real.eulerMascheroniConstant - accelerated n ∧
      Real.eulerMascheroniConstant - accelerated n ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  have hlow := tail_lower_sharp n
  have hup := tail_upper n
  unfold accelerated
  constructor <;> linarith

/-! ## 9. Apéry-style linear forms: criterion and a concrete obstruction -/

/-- **Linear-forms irrationality criterion.** If there are integer sequences `A, B` such
that the linear forms `A n + B n · x` are never zero but tend to `0`, then `x` is
irrational.  This is the exact target an Apéry-style construction has to hit. -/
theorem irrational_of_linear_forms (x : ℝ) (A B : ℕ → ℤ)
    (hne : ∀ n, (A n : ℝ) + (B n : ℝ) * x ≠ 0)
    (h0 : Tendsto (fun n => |(A n : ℝ) + (B n : ℝ) * x|) atTop (𝓝 0)) : Irrational x := by
  intro hmem
  obtain ⟨q, hq⟩ := hmem
  have hden : (0 : ℝ) < (q.den : ℝ) := by exact_mod_cast q.pos
  have hform : ∀ n, (A n : ℝ) + (B n : ℝ) * x
      = ((A n * (q.den : ℤ) + B n * q.num : ℤ) : ℝ) / (q.den : ℝ) := by
    intro n
    rw [← hq, Rat.cast_def]
    push_cast
    field_simp
  have hlb : ∀ n, 1 / (q.den : ℝ) ≤ |(A n : ℝ) + (B n : ℝ) * x| := by
    intro n
    have hz : (A n * (q.den : ℤ) + B n * q.num) ≠ 0 := by
      intro hzero
      apply hne n
      rw [hform n, hzero]
      simp
    have hZ := Int.one_le_abs (z := A n * (q.den : ℤ) + B n * q.num) hz
    have h1 : (1 : ℝ) ≤ |((A n * (q.den : ℤ) + B n * q.num : ℤ) : ℝ)| := by
      rw [← Int.cast_abs]
      exact_mod_cast hZ
    rw [hform n, abs_div, abs_of_pos hden]
    gcongr
  obtain ⟨n, hn⟩ :=
    (h0.eventually (gt_mem_nhds (show (0 : ℝ) < 1 / (q.den : ℝ) by positivity))).exists
  exact absurd hn (not_lt.mpr (hlb n))

/-- **Exponential decay would settle the irrationality of `γ`.** If integer linear forms
in `1` and `γ` are nonzero and decay geometrically, then `γ` is irrational. -/
theorem irrational_gamma_of_exponential_forms (A B : ℕ → ℤ) (C r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hne : ∀ n, (A n : ℝ) + (B n : ℝ) * Real.eulerMascheroniConstant ≠ 0)
    (hbound : ∀ n, |(A n : ℝ) + (B n : ℝ) * Real.eulerMascheroniConstant| ≤ C * r ^ n) :
    Irrational Real.eulerMascheroniConstant := by
  refine irrational_of_linear_forms _ A B hne ?_
  have hgeo : Tendsto (fun n : ℕ => C * r ^ n) atTop (𝓝 0) := by
    have := tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1
    simpa using this.const_mul C
  exact squeeze_zero (fun n => abs_nonneg _) hbound hgeo

/-- **Concrete obstruction.** The midpoint-accelerated approximants cannot feed the
criterion: rescaled by `(n+1)²` their error stays in `[1/14, 1/12]`, so it does not tend
to `0`.  Any Apéry-style construction must therefore use a genuinely different
(super-polynomially accurate) family of approximants. -/
theorem accelerated_forms_do_not_decay :
    ¬ Tendsto (fun n : ℕ => ((n : ℝ) + 1) ^ 2
        * (Real.eulerMascheroniConstant - accelerated n)) atTop (𝓝 0) := by
  intro h
  obtain ⟨n, hn⟩ := (h.eventually (gt_mem_nhds (show (0 : ℝ) < 1 / 14 by norm_num))).exists
  have hlow := (accelerated_error_two_sided n).1
  have hn0 : (0 : ℝ) < ((n : ℝ) + 1) ^ 2 := by positivity
  have : (1 : ℝ) / 14 ≤ ((n : ℝ) + 1) ^ 2 * (Real.eulerMascheroniConstant - accelerated n) := by
    have hmul := mul_le_mul_of_nonneg_left hlow (le_of_lt hn0)
    calc (1 : ℝ) / 14 = ((n : ℝ) + 1) ^ 2 * (1 / (14 * ((n : ℝ) + 1) ^ 2)) := by
          field_simp
      _ ≤ ((n : ℝ) + 1) ^ 2 * (Real.eulerMascheroniConstant - accelerated n) := hmul
  linarith