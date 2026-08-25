import Mathlib
import Computation.EulerMascheroniMidpointAcceleration

/-!
# Second-order (quartic) acceleration of the Euler–Mascheroni sequence

This file continues `Computation.EulerMascheroniMidpointAcceleration`.  There the *midpoint*
correction `1 / (2 (n+1))` was shown to turn `Real.eulerMascheroniSeq` into an `O(n⁻²)`
approximation of `γ`, with the sharp constant `1/12`.  Since the residual error is
*exactly* `1/(12 (n+1)²) + o(n⁻²)`, subtracting it must gain two more powers of `n`
(the `n⁻³` coefficient of the tail vanishes).  We prove this:

`accelerated2 n = Real.eulerMascheroniSeq n + 1 / (2 (n+1)) + 1 / (12 (n+1)²)`

satisfies

* `eulerMascheroniConstant_lt_accelerated2` : `γ < accelerated2 n` (an upper approximant);
* `abs_accelerated2_sub_le` : `|γ - accelerated2 n| ≤ 1 / (120 (n+1)⁴)`;
* `le_accelerated2_sub` : `1/(120 (n+1)⁴) - 1/(300 (n+1)⁵) ≤ accelerated2 n - γ`;
* `tendsto_scaled_error2` : `120 (n+1)⁴ (accelerated2 n - γ) → 1`, so `1/120` is sharp;
* `accelerated_lt_accelerated2_sandwich` : the two accelerated sequences trap `γ` in an
  explicit interval of width `1/(12 (n+1)²)`.

## Structural tool

The main reusable device is the pair of *envelope transfer* theorems
`tail_le_envelope` / `envelope_le_tail`: any function `H` whose one-step decrement dominates
(resp. is dominated by) the increment `1/m - log (1 + 1/m)` of the Euler–Mascheroni sequence
automatically bounds the whole tail `γ - eulerMascheroniSeq n` from above (resp. below).
This reduces every order of acceleration to a *single-variable* inequality between
`log (1 + x)` and an explicit rational function, which the derivative test settles.
Here the relevant inequalities are the two Padé-type bounds

`M(x) / (600 (1+x)⁵) ≤ log (1 + x) ≤ N(x) / (120 (1+x)⁴)`   (`x ≥ 0`),

whose difference functions have derivatives
`(6x⁵ + 5x⁶ + 3x⁸ + 4x⁹ + x¹⁰) / (60 (1+x)⁶)` and `(5x⁶ + 5x⁷ + x⁸) / (30 (1+x)⁵)`.
-/

open Filter Topology Real

namespace EulerMascheroniMidpoint

/-! ## Envelope transfer theorems -/

/-- If the one-step decrement of `H` dominates the increment of the Euler–Mascheroni
sequence and `H` is nonnegative, then `H` bounds the tail `γ - eulerMascheroniSeq n`
from above. -/
theorem tail_le_envelope (H : ℝ → ℝ) (hnn : ∀ m : ℝ, 1 ≤ m → 0 ≤ H m)
    (hstep : ∀ m : ℝ, 1 ≤ m → 1 / m - log (1 + 1 / m) ≤ H m - H (m + 1)) (n : ℕ) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n ≤ H ((n : ℝ) + 1) := by
  have tele : ∀ d : ℕ, Real.eulerMascheroniSeq (n + d)
      ≤ Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) - H ((n : ℝ) + d + 1) := by
    intro d
    induction d with
    | zero => norm_num
    | succ e ih =>
      have hm : (1 : ℝ) ≤ (n : ℝ) + e + 1 := by
        have : (0 : ℝ) ≤ (n : ℝ) + e := by positivity
        linarith
      have hst := hstep ((n : ℝ) + e + 1) hm
      have hsucc := eulerMascheroniSeq_succ_sub (n + e)
      push_cast at hsucc
      have hgoal : n + (e + 1) = (n + e) + 1 := by omega
      rw [hgoal]
      have hc : ((n : ℝ) + (e + 1 : ℕ) + 1) = ((n : ℝ) + e + 1) + 1 := by push_cast; ring
      rw [hc]
      linarith
  have hbound : ∀ N : ℕ, n ≤ N →
      Real.eulerMascheroniSeq N ≤ Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) := by
    intro N hN
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hN
    have h := tele d
    have hm : (1 : ℝ) ≤ (n : ℝ) + d + 1 := by
      have : (0 : ℝ) ≤ (n : ℝ) + d := by positivity
      linarith
    linarith [hnn _ hm]
  have hlim : Real.eulerMascheroniConstant
      ≤ Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) := by
    refine le_of_tendsto Real.tendsto_eulerMascheroniSeq ?_
    filter_upwards [eventually_ge_atTop n] with N hN using hbound N hN
  linarith

/-- If the one-step decrement of `H` is dominated by the increment of the Euler–Mascheroni
sequence and `H m ≤ 1/m`, then `H` bounds the tail `γ - eulerMascheroniSeq n` from below. -/
theorem envelope_le_tail (H : ℝ → ℝ) (hsmall : ∀ m : ℝ, 1 ≤ m → H m ≤ 1 / m)
    (hstep : ∀ m : ℝ, 1 ≤ m → H m - H (m + 1) ≤ 1 / m - log (1 + 1 / m)) (n : ℕ) :
    H ((n : ℝ) + 1) ≤ Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
  have tele : ∀ d : ℕ, Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) - H ((n : ℝ) + d + 1)
      ≤ Real.eulerMascheroniSeq (n + d) := by
    intro d
    induction d with
    | zero => norm_num
    | succ e ih =>
      have hm : (1 : ℝ) ≤ (n : ℝ) + e + 1 := by
        have : (0 : ℝ) ≤ (n : ℝ) + e := by positivity
        linarith
      have hst := hstep ((n : ℝ) + e + 1) hm
      have hsucc := eulerMascheroniSeq_succ_sub (n + e)
      push_cast at hsucc
      have hgoal : n + (e + 1) = (n + e) + 1 := by omega
      rw [hgoal]
      have hc : ((n : ℝ) + (e + 1 : ℕ) + 1) = ((n : ℝ) + e + 1) + 1 := by push_cast; ring
      rw [hc]
      linarith
  have key : ∀ d : ℕ, Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) - 1 / ((d : ℝ) + 1)
      ≤ Real.eulerMascheroniSeq (n + d) := by
    intro d
    have h := tele d
    have hm : (1 : ℝ) ≤ (n : ℝ) + d + 1 := by
      have : (0 : ℝ) ≤ (n : ℝ) + d := by positivity
      linarith
    have h1 : H ((n : ℝ) + d + 1) ≤ 1 / ((n : ℝ) + d + 1) := hsmall _ hm
    have h2 : 1 / ((n : ℝ) + d + 1) ≤ 1 / ((d : ℝ) + 1) := by
      apply one_div_le_one_div_of_le (by positivity)
      have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      linarith
    linarith
  have hlim : Real.eulerMascheroniSeq n + H ((n : ℝ) + 1)
      ≤ Real.eulerMascheroniConstant := by
    refine le_of_tendsto_of_tendsto' (b := atTop) (f := fun d : ℕ =>
        Real.eulerMascheroniSeq n + H ((n : ℝ) + 1) - 1 / ((d : ℝ) + 1))
      (g := fun d : ℕ => Real.eulerMascheroniSeq (n + d)) ?_ ?_ key
    · have h0 : Tendsto (fun d : ℕ => 1 / ((d : ℝ) + 1)) atTop (𝓝 0) :=
        tendsto_one_div_add_atTop_nhds_zero_nat
      have hc : Tendsto (fun _ : ℕ => Real.eulerMascheroniSeq n + H ((n : ℝ) + 1)) atTop
          (𝓝 (Real.eulerMascheroniSeq n + H ((n : ℝ) + 1))) := tendsto_const_nhds
      simpa using hc.sub h0
    · have hshift : Tendsto (fun d : ℕ => n + d) atTop atTop := by
        simpa [Nat.add_comm] using tendsto_add_atTop_nat n
      exact Real.tendsto_eulerMascheroniSeq.comp hshift
  linarith

/-! ## Fourth- and fifth-order Padé bounds for the logarithm -/

/-- Derivative of a general degree-`≤ 10` real polynomial. -/
private lemma hasDerivAt_poly10 (a₀ a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ a₉ a₁₀ x : ℝ) :
    HasDerivAt (fun y : ℝ => a₀ + a₁ * y + a₂ * y ^ 2 + a₃ * y ^ 3 + a₄ * y ^ 4 + a₅ * y ^ 5
        + a₆ * y ^ 6 + a₇ * y ^ 7 + a₈ * y ^ 8 + a₉ * y ^ 9 + a₁₀ * y ^ 10)
      (a₁ + 2 * a₂ * x + 3 * a₃ * x ^ 2 + 4 * a₄ * x ^ 3 + 5 * a₅ * x ^ 4 + 6 * a₆ * x ^ 5
        + 7 * a₇ * x ^ 6 + 8 * a₈ * x ^ 7 + 9 * a₉ * x ^ 8 + 10 * a₁₀ * x ^ 9) x := by
  have h := ((((((((((hasDerivAt_const x a₀).add
      ((hasDerivAt_id' (𝕜 := ℝ) (x := x)).const_mul a₁)).add
      ((hasDerivAt_pow 2 x).const_mul a₂)).add
      ((hasDerivAt_pow 3 x).const_mul a₃)).add
      ((hasDerivAt_pow 4 x).const_mul a₄)).add
      ((hasDerivAt_pow 5 x).const_mul a₅)).add
      ((hasDerivAt_pow 6 x).const_mul a₆)).add
      ((hasDerivAt_pow 7 x).const_mul a₇)).add
      ((hasDerivAt_pow 8 x).const_mul a₈)).add
      ((hasDerivAt_pow 9 x).const_mul a₉)).add
      ((hasDerivAt_pow 10 x).const_mul a₁₀)
  refine (h.congr_deriv (by push_cast; ring)).congr_of_eventuallyEq
    (Filter.Eventually.of_forall (fun z => ?_))
  simp only [Pi.add_apply]
  try ring

/-- Fourth-order upper Padé bound.  Here
`N(x) = 120x + 420x² + 520x³ + 250x⁴ + 24x⁵ - 4x⁶ + 4x⁷ + x⁸`. -/
theorem log_one_add_le_pade4 (x : ℝ) (hx : 0 ≤ x) :
    log (1 + x) ≤ (120 * x + 420 * x ^ 2 + 520 * x ^ 3 + 250 * x ^ 4 + 24 * x ^ 5
      - 4 * x ^ 6 + 4 * x ^ 7 + x ^ 8) / (120 * (1 + x) ^ 4) := by
  set f : ℝ → ℝ := fun y : ℝ =>
    (120 * y + 420 * y ^ 2 + 520 * y ^ 3 + 250 * y ^ 4 + 24 * y ^ 5 - 4 * y ^ 6 + 4 * y ^ 7
      + y ^ 8) / (120 * (1 + y) ^ 4) - log (1 + y) with hf
  have key : ∀ y : ℝ, 0 ≤ y → 0 ≤ f y := by
    refine nonneg_of_hasDerivAt_nonneg
      (f' := fun y => (5 * y ^ 6 + 5 * y ^ 7 + y ^ 8) / (30 * (1 + y) ^ 5)) ?_ ?_ ?_
    · simp [hf]
    · intro y hy
      have hy1 : (0 : ℝ) < 1 + y := by linarith
      have hlog : HasDerivAt (fun z : ℝ => log (1 + z)) (1 / (1 + y)) y := by
        have h := (Real.hasDerivAt_log (x := 1 + y) (by positivity)).comp y
          ((hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_add 1)
        simpa [one_div] using h
      have hN : HasDerivAt (fun z : ℝ => 120 * z + 420 * z ^ 2 + 520 * z ^ 3 + 250 * z ^ 4
          + 24 * z ^ 5 - 4 * z ^ 6 + 4 * z ^ 7 + z ^ 8)
          (120 + 840 * y + 1560 * y ^ 2 + 1000 * y ^ 3 + 120 * y ^ 4 - 24 * y ^ 5 + 28 * y ^ 6
            + 8 * y ^ 7) y := by
        have h := hasDerivAt_poly10 0 120 420 520 250 24 (-4) 4 1 0 0 y
        have e : (fun z : ℝ => (0 : ℝ) + 120 * z + 420 * z ^ 2 + 520 * z ^ 3 + 250 * z ^ 4
            + 24 * z ^ 5 + (-4) * z ^ 6 + 4 * z ^ 7 + 1 * z ^ 8 + 0 * z ^ 9 + 0 * z ^ 10)
            = fun z : ℝ => 120 * z + 420 * z ^ 2 + 520 * z ^ 3 + 250 * z ^ 4 + 24 * z ^ 5
              - 4 * z ^ 6 + 4 * z ^ 7 + z ^ 8 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hD : HasDerivAt (fun z : ℝ => 120 * (1 + z) ^ 4)
          (480 + 1440 * y + 1440 * y ^ 2 + 480 * y ^ 3) y := by
        have h := hasDerivAt_poly10 120 480 720 480 120 0 0 0 0 0 0 y
        have e : (fun z : ℝ => (120 : ℝ) + 480 * z + 720 * z ^ 2 + 480 * z ^ 3 + 120 * z ^ 4
            + 0 * z ^ 5 + 0 * z ^ 6 + 0 * z ^ 7 + 0 * z ^ 8 + 0 * z ^ 9 + 0 * z ^ 10)
            = fun z : ℝ => 120 * (1 + z) ^ 4 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hq := hN.div hD (by positivity)
      have := hq.sub hlog
      convert this using 1
      field_simp
      ring
    · intro y hy
      have : (0 : ℝ) < 1 + y := by linarith
      positivity
  have := key x hx
  simp only [hf] at this
  linarith

/-- Fifth-order lower Padé bound.  Here
`M(x) = 600x + 2700x² + 4700x³ + 3850x⁴ + 1370x⁵ + 90x⁶ - 20x⁷ + 5x⁸ - 5x⁹ - 2x¹⁰`. -/
theorem pade5_le_log_one_add (x : ℝ) (hx : 0 ≤ x) :
    (600 * x + 2700 * x ^ 2 + 4700 * x ^ 3 + 3850 * x ^ 4 + 1370 * x ^ 5 + 90 * x ^ 6
      - 20 * x ^ 7 + 5 * x ^ 8 - 5 * x ^ 9 - 2 * x ^ 10) / (600 * (1 + x) ^ 5)
      ≤ log (1 + x) := by
  set f : ℝ → ℝ := fun y : ℝ =>
    log (1 + y) - (600 * y + 2700 * y ^ 2 + 4700 * y ^ 3 + 3850 * y ^ 4 + 1370 * y ^ 5
      + 90 * y ^ 6 - 20 * y ^ 7 + 5 * y ^ 8 - 5 * y ^ 9 - 2 * y ^ 10) / (600 * (1 + y) ^ 5)
    with hf
  have key : ∀ y : ℝ, 0 ≤ y → 0 ≤ f y := by
    refine nonneg_of_hasDerivAt_nonneg
      (f' := fun y => (6 * y ^ 5 + 5 * y ^ 6 + 3 * y ^ 8 + 4 * y ^ 9 + y ^ 10)
        / (60 * (1 + y) ^ 6)) ?_ ?_ ?_
    · simp [hf]
    · intro y hy
      have hy1 : (0 : ℝ) < 1 + y := by linarith
      have hlog : HasDerivAt (fun z : ℝ => log (1 + z)) (1 / (1 + y)) y := by
        have h := (Real.hasDerivAt_log (x := 1 + y) (by positivity)).comp y
          ((hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_add 1)
        simpa [one_div] using h
      have hN : HasDerivAt (fun z : ℝ => 600 * z + 2700 * z ^ 2 + 4700 * z ^ 3 + 3850 * z ^ 4
          + 1370 * z ^ 5 + 90 * z ^ 6 - 20 * z ^ 7 + 5 * z ^ 8 - 5 * z ^ 9 - 2 * z ^ 10)
          (600 + 5400 * y + 14100 * y ^ 2 + 15400 * y ^ 3 + 6850 * y ^ 4 + 540 * y ^ 5
            - 140 * y ^ 6 + 40 * y ^ 7 - 45 * y ^ 8 - 20 * y ^ 9) y := by
        have h := hasDerivAt_poly10 0 600 2700 4700 3850 1370 90 (-20) 5 (-5) (-2) y
        have e : (fun z : ℝ => (0 : ℝ) + 600 * z + 2700 * z ^ 2 + 4700 * z ^ 3 + 3850 * z ^ 4
            + 1370 * z ^ 5 + 90 * z ^ 6 + (-20) * z ^ 7 + 5 * z ^ 8 + (-5) * z ^ 9
            + (-2) * z ^ 10)
            = fun z : ℝ => 600 * z + 2700 * z ^ 2 + 4700 * z ^ 3 + 3850 * z ^ 4 + 1370 * z ^ 5
              + 90 * z ^ 6 - 20 * z ^ 7 + 5 * z ^ 8 - 5 * z ^ 9 - 2 * z ^ 10 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hD : HasDerivAt (fun z : ℝ => 600 * (1 + z) ^ 5)
          (3000 + 12000 * y + 18000 * y ^ 2 + 12000 * y ^ 3 + 3000 * y ^ 4) y := by
        have h := hasDerivAt_poly10 600 3000 6000 6000 3000 600 0 0 0 0 0 y
        have e : (fun z : ℝ => (600 : ℝ) + 3000 * z + 6000 * z ^ 2 + 6000 * z ^ 3 + 3000 * z ^ 4
            + 600 * z ^ 5 + 0 * z ^ 6 + 0 * z ^ 7 + 0 * z ^ 8 + 0 * z ^ 9 + 0 * z ^ 10)
            = fun z : ℝ => 600 * (1 + z) ^ 5 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hq := hN.div hD (by positivity)
      have := hlog.sub hq
      convert this using 1
      field_simp
      ring
    · intro y hy
      have : (0 : ℝ) < 1 + y := by linarith
      positivity
  have := key x hx
  simp only [hf] at this
  linarith

/-! ## The quartically accelerated sequence -/

/-- The second-order (midpoint + curvature) correction of the Euler–Mascheroni sequence. -/
noncomputable def accelerated2 (n : ℕ) : ℝ :=
  Real.eulerMascheroniSeq n + 1 / (2 * (n + 1 : ℝ)) + 1 / (12 * (n + 1 : ℝ) ^ 2)

/-- Envelope for the upper bound on `accelerated2 - γ`. -/
noncomputable def tail4 (x : ℝ) : ℝ := 1 / (2 * x) + 1 / (12 * x ^ 2) - 1 / (120 * x ^ 4)

/-- Envelope for the lower bound on `accelerated2 - γ`. -/
noncomputable def tail5 (x : ℝ) : ℝ :=
  1 / (2 * x) + 1 / (12 * x ^ 2) - 1 / (120 * x ^ 4) + 1 / (300 * x ^ 5)

lemma tail4_step (m : ℝ) (hm : 1 ≤ m) :
    tail4 m - tail4 (m + 1) ≤ 1 / m - log (1 + 1 / m) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hx : (0 : ℝ) ≤ 1 / m := by positivity
  have h := log_one_add_le_pade4 (1 / m) hx
  have hm1 : (0 : ℝ) < m + 1 := by linarith
  have hid : (120 * (1 / m) + 420 * (1 / m) ^ 2 + 520 * (1 / m) ^ 3 + 250 * (1 / m) ^ 4
      + 24 * (1 / m) ^ 5 - 4 * (1 / m) ^ 6 + 4 * (1 / m) ^ 7 + (1 / m) ^ 8)
      / (120 * (1 + 1 / m) ^ 4) = 1 / m - (tail4 m - tail4 (m + 1)) := by
    simp only [tail4]
    field_simp
    ring
  rw [hid] at h
  linarith

lemma tail5_step (m : ℝ) (hm : 1 ≤ m) :
    1 / m - log (1 + 1 / m) ≤ tail5 m - tail5 (m + 1) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hx : (0 : ℝ) ≤ 1 / m := by positivity
  have h := pade5_le_log_one_add (1 / m) hx
  have hm1 : (0 : ℝ) < m + 1 := by linarith
  have hid : (600 * (1 / m) + 2700 * (1 / m) ^ 2 + 4700 * (1 / m) ^ 3 + 3850 * (1 / m) ^ 4
      + 1370 * (1 / m) ^ 5 + 90 * (1 / m) ^ 6 - 20 * (1 / m) ^ 7 + 5 * (1 / m) ^ 8
      - 5 * (1 / m) ^ 9 - 2 * (1 / m) ^ 10) / (600 * (1 + 1 / m) ^ 5)
      = 1 / m - (tail5 m - tail5 (m + 1)) := by
    simp only [tail5]
    field_simp
    ring
  rw [hid] at h
  linarith

lemma tail4_le_one_div {m : ℝ} (hm : 1 ≤ m) : tail4 m ≤ 1 / m := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hid : 1 / m - tail4 m
      = (60 * m ^ 3 - 10 * m ^ 2 + 1) / (120 * m ^ 4) := by
    simp only [tail4]
    field_simp
    ring
  have : 0 ≤ 1 / m - tail4 m := by
    rw [hid]
    apply div_nonneg _ (by positivity)
    nlinarith
  linarith

lemma tail5_nonneg {m : ℝ} (hm : 1 ≤ m) : 0 ≤ tail5 m := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hid : tail5 m = (300 * m ^ 4 + 50 * m ^ 3 - 5 * m + 2) / (600 * m ^ 5) := by
    simp only [tail5]
    field_simp
    ring
  rw [hid]
  apply div_nonneg _ (by positivity)
  have h1 : m ≤ m ^ 4 := by nlinarith [sq_nonneg m, sq_nonneg (m - 1), sq_nonneg (m ^ 2 - 1)]
  have h2 : (0 : ℝ) ≤ m ^ 3 := by positivity
  linarith

/-- **Upper bound.**  The second-order correction overshoots `γ` by at most `1/(120 (n+1)⁴)`. -/
theorem accelerated2_sub_le (n : ℕ) :
    accelerated2 n - Real.eulerMascheroniConstant ≤ 1 / (120 * ((n : ℝ) + 1) ^ 4) := by
  have h := envelope_le_tail tail4 (fun m hm => tail4_le_one_div hm) tail4_step n
  have hexp : tail4 ((n : ℝ) + 1) = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2)
      - 1 / (120 * ((n : ℝ) + 1) ^ 4) := rfl
  rw [hexp] at h
  simp only [accelerated2]
  linarith

/-- **Lower bound.**  The overshoot is at least `1/(120 (n+1)⁴) - 1/(300 (n+1)⁵)`; in
particular `accelerated2` is a strict upper approximant of `γ`. -/
theorem le_accelerated2_sub (n : ℕ) :
    1 / (120 * ((n : ℝ) + 1) ^ 4) - 1 / (300 * ((n : ℝ) + 1) ^ 5)
      ≤ accelerated2 n - Real.eulerMascheroniConstant := by
  have h := tail_le_envelope tail5 (fun m hm => tail5_nonneg hm) tail5_step n
  have hexp : tail5 ((n : ℝ) + 1) = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2)
      - 1 / (120 * ((n : ℝ) + 1) ^ 4) + 1 / (300 * ((n : ℝ) + 1) ^ 5) := rfl
  rw [hexp] at h
  simp only [accelerated2]
  linarith

/-- `accelerated2` is a strict upper approximant of `γ`. -/
theorem eulerMascheroniConstant_lt_accelerated2 (n : ℕ) :
    Real.eulerMascheroniConstant < accelerated2 n := by
  have h := le_accelerated2_sub n
  have hm : (1 : ℝ) ≤ (n : ℝ) + 1 := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  have hm0 : (0 : ℝ) < (n : ℝ) + 1 := by linarith
  have hid : 1 / (120 * ((n : ℝ) + 1) ^ 4) - 1 / (300 * ((n : ℝ) + 1) ^ 5)
      = (5 * ((n : ℝ) + 1) - 2) / (600 * ((n : ℝ) + 1) ^ 5) := by
    field_simp
    ring
  have hpos : 0 < 1 / (120 * ((n : ℝ) + 1) ^ 4) - 1 / (300 * ((n : ℝ) + 1) ^ 5) := by
    rw [hid]
    apply div_pos (by linarith) (by positivity)
  linarith

/-- **Main theorem of this file.**  Adding the curvature term gains two further powers of `n`:
the error is `O(n⁻⁴)` with the explicit constant `1/120`, for every `n : ℕ`. -/
theorem abs_accelerated2_sub_le (n : ℕ) :
    |Real.eulerMascheroniConstant - accelerated2 n| ≤ 1 / (120 * ((n : ℝ) + 1) ^ 4) := by
  rw [abs_le]
  constructor
  · have h := accelerated2_sub_le n
    linarith
  · have h := (eulerMascheroniConstant_lt_accelerated2 n).le
    have : (0 : ℝ) ≤ 1 / (120 * ((n : ℝ) + 1) ^ 4) := by positivity
    linarith

/-- **Sharpness at fourth order.**  `120 (n+1)⁴ (accelerated2 n - γ) → 1`. -/
theorem tendsto_scaled_error2 :
    Tendsto (fun n : ℕ => 120 * ((n : ℝ) + 1) ^ 4
      * (accelerated2 n - Real.eulerMascheroniConstant)) atTop (𝓝 1) := by
  have hsq : Tendsto (fun n : ℕ => 1 - 1 / ((5 / 2) * ((n : ℝ) + 1))) atTop (𝓝 1) := by
    have h : Tendsto (fun n : ℕ => 1 / ((5 / 2) * ((n : ℝ) + 1))) atTop (𝓝 0) := by
      have h1 := tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)
      have he : (fun n : ℕ => 1 / ((5 / 2 : ℝ) * ((n : ℝ) + 1)))
          = fun n : ℕ => (2 / 5 : ℝ) * (1 / ((n : ℝ) + 1)) := by
        funext n
        rw [one_div, one_div, mul_inv]
        ring
      rw [he]
      simpa using h1.const_mul (2 / 5 : ℝ)
    have hc : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 (1 : ℝ)) := tendsto_const_nhds
    simpa using hc.sub h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hsq tendsto_const_nhds ?_ ?_
  · intro n
    have h := le_accelerated2_sub n
    have hx : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have h120 : (0 : ℝ) < 120 * ((n : ℝ) + 1) ^ 4 := by positivity
    have hmul := mul_le_mul_of_nonneg_left h (le_of_lt h120)
    have hid : 120 * ((n : ℝ) + 1) ^ 4
        * (1 / (120 * ((n : ℝ) + 1) ^ 4) - 1 / (300 * ((n : ℝ) + 1) ^ 5))
        = 1 - 1 / ((5 / 2) * ((n : ℝ) + 1)) := by
      field_simp
      ring
    rw [hid] at hmul
    exact hmul
  · intro n
    have h := accelerated2_sub_le n
    have hx : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have h120 : (0 : ℝ) < 120 * ((n : ℝ) + 1) ^ 4 := by positivity
    have hmul := mul_le_mul_of_nonneg_left h (le_of_lt h120)
    have hid : 120 * ((n : ℝ) + 1) ^ 4 * (1 / (120 * ((n : ℝ) + 1) ^ 4)) = 1 := by
      field_simp
    rw [hid] at hmul
    exact hmul

/-- **Certified enclosure.**  `γ` lies strictly between the two accelerated sequences, in an
interval of width exactly `1 / (12 (n+1)²)`. -/
theorem accelerated_lt_accelerated2_sandwich (n : ℕ) :
    accelerated n < Real.eulerMascheroniConstant ∧
      Real.eulerMascheroniConstant < accelerated2 n ∧
      accelerated2 n - accelerated n = 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  refine ⟨accelerated_lt_eulerMascheroniConstant n, eulerMascheroniConstant_lt_accelerated2 n, ?_⟩
  simp only [accelerated, accelerated2]
  ring

/-- `accelerated2` decreases: it is a monotone family of certified upper bounds for `γ`. -/
theorem antitone_accelerated2 : Antitone accelerated2 := by
  refine antitone_nat_of_succ_le (fun n => ?_)
  have hm : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hstep := step_le_tailUpper ((n : ℝ) + 1) hm
  have hsucc := eulerMascheroniSeq_succ_sub n
  have hexp1 : tailUpper ((n : ℝ) + 1)
      = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2) := rfl
  have hexp2 : tailUpper ((n : ℝ) + 1 + 1)
      = 1 / (2 * ((n : ℝ) + 1 + 1)) + 1 / (12 * ((n : ℝ) + 1 + 1) ^ 2) := rfl
  rw [hexp1, hexp2] at hstep
  simp only [accelerated2]
  push_cast
  linarith

/-! ## A certified numerical consequence at `n = 0` -/

/-- Taking `n = 0` in the enclosure costs nothing (`eulerMascheroniSeq 0 = 0`) and already
improves on the textbook upper bound `γ < 2/3`. -/
theorem eulerMascheroniConstant_lt_seven_twelfths :
    Real.eulerMascheroniConstant < 7 / 12 := by
  have h := eulerMascheroniConstant_lt_accelerated2 0
  have h0 : accelerated2 0 = 7 / 12 := by
    simp only [accelerated2, Real.eulerMascheroniSeq_zero]
    norm_num
  linarith [h0 ▸ h]

/-- The corresponding lower bound at `n = 0`, recovering `1/2 < γ` from the midpoint
correction alone. -/
theorem one_half_lt_eulerMascheroniConstant' :
    (1 : ℝ) / 2 < Real.eulerMascheroniConstant := by
  have h := accelerated_lt_eulerMascheroniConstant 0
  have h0 : accelerated 0 = 1 / 2 := by
    simp only [accelerated, Real.eulerMascheroniSeq_zero]
    norm_num
  linarith [h0 ▸ h]

/-- **Speed-up.**  The relative gain of the midpoint correction over the raw sequence tends
to `0` like `1/(6n)`: the accelerated error is an ever smaller fraction of the raw error. -/
theorem tendsto_error_ratio_zero :
    Tendsto (fun n : ℕ => (Real.eulerMascheroniConstant - accelerated n)
      / (Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n)) atTop (𝓝 0) := by
  have hupper : Tendsto (fun n : ℕ => 1 / (6 * ((n : ℝ) + 1))) atTop (𝓝 0) := by
    have h1 := tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)
    have he : (fun n : ℕ => 1 / (6 * ((n : ℝ) + 1)))
        = fun n : ℕ => (1 / 6 : ℝ) * (1 / ((n : ℝ) + 1)) := by
      funext n
      rw [one_div, one_div, mul_inv]
      ring
    rw [he]
    simpa using h1.const_mul (1 / 6 : ℝ)
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hupper ?_ ?_
  · intro n
    have hnum : 0 ≤ Real.eulerMascheroniConstant - accelerated n := by
      linarith [(accelerated_lt_eulerMascheroniConstant n).le]
    have hden : 0 < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
      have := (eulerMascheroniConstant_sub_eulerMascheroniSeq_bounds n).1
      have hx : (0 : ℝ) < 1 / (2 * ((n : ℝ) + 1)) := by positivity
      linarith
    exact div_nonneg hnum hden.le
  · intro n
    have hden : 1 / (2 * ((n : ℝ) + 1))
        < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n :=
      (eulerMascheroniConstant_sub_eulerMascheroniSeq_bounds n).1
    have hx : (0 : ℝ) < 1 / (2 * ((n : ℝ) + 1)) := by positivity
    have hden0 : 0 < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by linarith
    have hnum : Real.eulerMascheroniConstant - accelerated n ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) :=
      eulerMascheroniConstant_sub_accelerated_le n
    rw [div_le_iff₀ hden0]
    have hxp : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have hprod : 1 / (12 * ((n : ℝ) + 1) ^ 2)
        ≤ 1 / (6 * ((n : ℝ) + 1)) * (1 / (2 * ((n : ℝ) + 1))) := by
      rw [div_mul_div_comm]
      apply le_of_eq
      field_simp
      ring
    have hmul : 1 / (6 * ((n : ℝ) + 1)) * (1 / (2 * ((n : ℝ) + 1)))
        ≤ 1 / (6 * ((n : ℝ) + 1)) * (Real.eulerMascheroniConstant
          - Real.eulerMascheroniSeq n) := by
      apply mul_le_mul_of_nonneg_left hden.le (by positivity)
    linarith

end EulerMascheroniMidpoint