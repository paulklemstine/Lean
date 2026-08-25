import Mathlib

/-!
# Midpoint-corrected acceleration of the Euler–Mascheroni sequence

Mathlib's sequence `Real.eulerMascheroniSeq n = harmonic n - log (n + 1)` converges to
`γ = Real.eulerMascheroniConstant` at rate `Θ(n⁻¹)`.  Adding the *midpoint correction*
`1 / (2 (n+1))` produces a sequence converging at rate `Θ(n⁻²)`:

`accelerated n = Real.eulerMascheroniSeq n + 1 / (2 * (n + 1))`.

The main results are the **two-sided explicit error bounds**, valid for *every* `n : ℕ`
(threshold `n ≥ 0`, i.e. no threshold at all):

* `accelerated_lt_eulerMascheroniConstant` : `accelerated n < γ`;
* `eulerMascheroniConstant_sub_accelerated_le` : `γ - accelerated n ≤ 1 / (12 (n+1)²)`;
* `abs_eulerMascheroniConstant_sub_accelerated_le` : `|γ - accelerated n| ≤ 1 / (12 (n+1)²)`;
* `le_eulerMascheroniConstant_sub_accelerated` :
  `1 / (12 (n+1)²) - 1 / (36 (n+1)³) ≤ γ - accelerated n`, which shows the constant `1/12`
  is asymptotically optimal;
* `tendsto_scaled_error` : `12 (n+1)² (γ - accelerated n) → 1`, the sharpness statement.

## Method

Writing `m = n + 1`, the tail of the telescoping series is
`γ - eulerMascheroniSeq n = ∑_{j ≥ m} (1/j - log (1 + 1/j))`.
The proof does not use infinite sums: instead we produce two *telescoping envelopes*
`tailUpper x = 1/(2x) + 1/(12x²)` and `tailLower x = tailUpper x - 1/(36x³)` satisfying,
for every real `m > 0`,

`tailLower m - tailLower (m+1) ≤ 1/m - log (1 + 1/m) ≤ tailUpper m - tailUpper (m+1)`.

These two inequalities are equivalent to two Padé-type bounds for the logarithm,

`(12x + 18x² + 4x³ - x⁴) / (12 (1+x)²) ≤ log (1+x) ≤ (36x + 90x² + 66x³ + 12x⁴ + x⁶)/(36 (1+x)³)`

valid for all `x ≥ 0`, which are proved by the derivative test: the corresponding difference
functions vanish at `0` and have derivatives `x⁴ / (6 (1+x)³)` and
`x³ (12 + 12x + 6x² + 3x³) / (36 (1+x)⁴)`, both nonnegative.
Summation of the envelope then reduces to a finite induction, and `γ` enters only through
`Real.tendsto_eulerMascheroniSeq`.
-/

open Filter Topology Real

namespace EulerMascheroniMidpoint

/-! ## Generic analytic tools -/

/-- Derivative of a general degree-`≤ 6` real polynomial, used to differentiate the
numerators and denominators of our Padé approximants. -/
private lemma hasDerivAt_poly6 (a₀ a₁ a₂ a₃ a₄ a₅ a₆ x : ℝ) :
    HasDerivAt (fun y : ℝ => a₀ + a₁ * y + a₂ * y ^ 2 + a₃ * y ^ 3 + a₄ * y ^ 4 + a₅ * y ^ 5
        + a₆ * y ^ 6)
      (a₁ + 2 * a₂ * x + 3 * a₃ * x ^ 2 + 4 * a₄ * x ^ 3 + 5 * a₅ * x ^ 4 + 6 * a₆ * x ^ 5) x := by
  have h := ((((((hasDerivAt_const x a₀).add
      ((hasDerivAt_id' (𝕜 := ℝ) (x := x)).const_mul a₁)).add
      ((hasDerivAt_pow 2 x).const_mul a₂)).add
      ((hasDerivAt_pow 3 x).const_mul a₃)).add
      ((hasDerivAt_pow 4 x).const_mul a₄)).add
      ((hasDerivAt_pow 5 x).const_mul a₅)).add
      ((hasDerivAt_pow 6 x).const_mul a₆)
  refine (h.congr_deriv (by push_cast; ring)).congr_of_eventuallyEq
    (Filter.Eventually.of_forall (fun z => ?_))
  simp only [Pi.add_apply]
  try ring

/-- Derivative test: a function vanishing at `0` with nonnegative derivative on `(0, ∞)`
is nonnegative on `[0, ∞)`.  The derivative hypothesis is required on `(-1, ∞)` so that
continuity at the endpoint `0` comes for free (our functions involve `log (1 + x)`). -/
lemma nonneg_of_hasDerivAt_nonneg {f f' : ℝ → ℝ} (hf0 : f 0 = 0)
    (hd : ∀ x : ℝ, -1 < x → HasDerivAt f (f' x) x)
    (hnn : ∀ x : ℝ, 0 < x → 0 ≤ f' x) :
    ∀ x : ℝ, 0 ≤ x → 0 ≤ f x := by
  intro x hx
  have hmono : MonotoneOn f (Set.Ici (0 : ℝ)) := by
    refine monotoneOn_of_deriv_nonneg (convex_Ici 0) (fun y hy => ?_) (fun y hy => ?_)
      (fun y hy => ?_)
    · exact ((hd y (by simp only [Set.mem_Ici] at hy; linarith)).continuousAt).continuousWithinAt
    · rw [interior_Ici] at hy
      simp only [Set.mem_Ioi] at hy
      exact (hd y (by linarith)).differentiableAt.differentiableWithinAt
    · rw [interior_Ici] at hy
      simp only [Set.mem_Ioi] at hy
      rw [(hd y (by linarith)).deriv]
      exact hnn y hy
  have := hmono Set.self_mem_Ici (Set.mem_Ici.mpr hx) hx
  rw [hf0] at this
  exact this

/-! ## Padé-type bounds for the logarithm -/

/-- Lower Padé bound: `(12x + 18x² + 4x³ - x⁴) / (12 (1+x)²) ≤ log (1+x)` for `x ≥ 0`.
This is the `(2,2)` Padé approximant of `log (1+x)` corrected so as to be a genuine
lower bound; the error is `x⁵/30 + O(x⁶)`. -/
theorem pade_lower_le_log_one_add (x : ℝ) (hx : 0 ≤ x) :
    (12 * x + 18 * x ^ 2 + 4 * x ^ 3 - x ^ 4) / (12 * (1 + x) ^ 2) ≤ log (1 + x) := by
  set f : ℝ → ℝ := fun y : ℝ =>
    log (1 + y) - (12 * y + 18 * y ^ 2 + 4 * y ^ 3 - y ^ 4) / (12 * (1 + y) ^ 2) with hf
  have key : ∀ y : ℝ, 0 ≤ y → 0 ≤ f y := by
    refine nonneg_of_hasDerivAt_nonneg (f' := fun y => y ^ 4 / (6 * (1 + y) ^ 3)) ?_ ?_ ?_
    · simp [hf]
    · intro y hy
      have hy1 : (0 : ℝ) < 1 + y := by linarith
      have hlog : HasDerivAt (fun z : ℝ => log (1 + z)) (1 / (1 + y)) y := by
        have h := (Real.hasDerivAt_log (x := 1 + y) (by positivity)).comp y
          ((hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_add 1)
        simpa [one_div] using h
      have hN : HasDerivAt (fun z : ℝ => 12 * z + 18 * z ^ 2 + 4 * z ^ 3 - z ^ 4)
          (12 + 36 * y + 12 * y ^ 2 - 4 * y ^ 3) y := by
        have h := hasDerivAt_poly6 0 12 18 4 (-1) 0 0 y
        have e : (fun z : ℝ => (0 : ℝ) + 12 * z + 18 * z ^ 2 + 4 * z ^ 3 + (-1) * z ^ 4
            + 0 * z ^ 5 + 0 * z ^ 6) = fun z : ℝ => 12 * z + 18 * z ^ 2 + 4 * z ^ 3 - z ^ 4 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hD : HasDerivAt (fun z : ℝ => 12 * (1 + z) ^ 2) (24 + 24 * y) y := by
        have h := hasDerivAt_poly6 12 24 12 0 0 0 0 y
        have e : (fun z : ℝ => (12 : ℝ) + 24 * z + 12 * z ^ 2 + 0 * z ^ 3 + 0 * z ^ 4
            + 0 * z ^ 5 + 0 * z ^ 6) = fun z : ℝ => 12 * (1 + z) ^ 2 := by
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

/-- Upper Padé bound: `log (1+x) ≤ (36x + 90x² + 66x³ + 12x⁴ + x⁶) / (36 (1+x)³)` for `x ≥ 0`.
The error is `-x⁵/30 + O(x⁶)`, so together with `pade_lower_le_log_one_add` the logarithm is
pinned to order `x⁵`. -/
theorem log_one_add_le_pade_upper (x : ℝ) (hx : 0 ≤ x) :
    log (1 + x) ≤ (36 * x + 90 * x ^ 2 + 66 * x ^ 3 + 12 * x ^ 4 + x ^ 6) / (36 * (1 + x) ^ 3) := by
  set f : ℝ → ℝ := fun y : ℝ =>
    (36 * y + 90 * y ^ 2 + 66 * y ^ 3 + 12 * y ^ 4 + y ^ 6) / (36 * (1 + y) ^ 3) - log (1 + y)
    with hf
  have key : ∀ y : ℝ, 0 ≤ y → 0 ≤ f y := by
    refine nonneg_of_hasDerivAt_nonneg
      (f' := fun y => y ^ 3 * (12 + 12 * y + 6 * y ^ 2 + 3 * y ^ 3) / (36 * (1 + y) ^ 4)) ?_ ?_ ?_
    · simp [hf]
    · intro y hy
      have hy1 : (0 : ℝ) < 1 + y := by linarith
      have hlog : HasDerivAt (fun z : ℝ => log (1 + z)) (1 / (1 + y)) y := by
        have h := (Real.hasDerivAt_log (x := 1 + y) (by positivity)).comp y
          ((hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_add 1)
        simpa [one_div] using h
      have hN : HasDerivAt (fun z : ℝ => 36 * z + 90 * z ^ 2 + 66 * z ^ 3 + 12 * z ^ 4 + z ^ 6)
          (36 + 180 * y + 198 * y ^ 2 + 48 * y ^ 3 + 6 * y ^ 5) y := by
        have h := hasDerivAt_poly6 0 36 90 66 12 0 1 y
        have e : (fun z : ℝ => (0 : ℝ) + 36 * z + 90 * z ^ 2 + 66 * z ^ 3 + 12 * z ^ 4
            + 0 * z ^ 5 + 1 * z ^ 6)
            = fun z : ℝ => 36 * z + 90 * z ^ 2 + 66 * z ^ 3 + 12 * z ^ 4 + z ^ 6 := by
          funext z; ring
        rw [e] at h
        convert h using 1
        ring
      have hD : HasDerivAt (fun z : ℝ => 36 * (1 + z) ^ 3)
          (108 + 216 * y + 108 * y ^ 2) y := by
        have h := hasDerivAt_poly6 36 108 108 36 0 0 0 y
        have e : (fun z : ℝ => (36 : ℝ) + 108 * z + 108 * z ^ 2 + 36 * z ^ 3 + 0 * z ^ 4
            + 0 * z ^ 5 + 0 * z ^ 6) = fun z : ℝ => 36 * (1 + z) ^ 3 := by
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

/-! ## The accelerated sequence and its telescoping envelopes -/

/-- The midpoint-corrected Euler–Mascheroni sequence. -/
noncomputable def accelerated (n : ℕ) : ℝ :=
  Real.eulerMascheroniSeq n + 1 / (2 * (n + 1 : ℝ))

/-- Upper telescoping envelope `1/(2x) + 1/(12x²)` for the tail of the series. -/
noncomputable def tailUpper (x : ℝ) : ℝ := 1 / (2 * x) + 1 / (12 * x ^ 2)

/-- Lower telescoping envelope `1/(2x) + 1/(12x²) - 1/(36x³)`. -/
noncomputable def tailLower (x : ℝ) : ℝ := 1 / (2 * x) + 1 / (12 * x ^ 2) - 1 / (36 * x ^ 3)

/-- One step of the Euler–Mascheroni sequence. -/
lemma eulerMascheroniSeq_succ_sub (k : ℕ) :
    Real.eulerMascheroniSeq (k + 1) - Real.eulerMascheroniSeq k
      = 1 / (k + 1 : ℝ) - log (1 + 1 / (k + 1 : ℝ)) := by
  have hk : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  have hlog : log ((k : ℝ) + 1 + 1) - log ((k : ℝ) + 1) = log (1 + 1 / ((k : ℝ) + 1)) := by
    rw [← Real.log_div (by positivity) (by positivity)]
    congr 1
    field_simp
  simp only [Real.eulerMascheroniSeq, harmonic_succ]
  push_cast
  rw [← hlog]
  ring

/-- Upper step bound: one increment of the sequence is at most the decrement of the upper
envelope.  Equivalently, `tailUpper` dominates the tail of the series. -/
lemma step_le_tailUpper (m : ℝ) (hm : 0 < m) :
    1 / m - log (1 + 1 / m) ≤ tailUpper m - tailUpper (m + 1) := by
  have hx : (0 : ℝ) ≤ 1 / m := by positivity
  have h := pade_lower_le_log_one_add (1 / m) hx
  have hm1 : (0 : ℝ) < m + 1 := by linarith
  have hid : (12 * (1 / m) + 18 * (1 / m) ^ 2 + 4 * (1 / m) ^ 3 - (1 / m) ^ 4)
      / (12 * (1 + 1 / m) ^ 2) = 1 / m - (tailUpper m - tailUpper (m + 1)) := by
    simp only [tailUpper]
    field_simp
    ring
  rw [hid] at h
  linarith

/-- Lower step bound: one increment of the sequence is at least the decrement of the lower
envelope. -/
lemma tailLower_le_step (m : ℝ) (hm : 0 < m) :
    tailLower m - tailLower (m + 1) ≤ 1 / m - log (1 + 1 / m) := by
  have hx : (0 : ℝ) ≤ 1 / m := by positivity
  have h := log_one_add_le_pade_upper (1 / m) hx
  have hm1 : (0 : ℝ) < m + 1 := by linarith
  have hid : (36 * (1 / m) + 90 * (1 / m) ^ 2 + 66 * (1 / m) ^ 3 + 12 * (1 / m) ^ 4 + (1 / m) ^ 6)
      / (36 * (1 + 1 / m) ^ 3) = 1 / m - (tailLower m - tailLower (m + 1)) := by
    simp only [tailLower]
    field_simp
    ring
  rw [hid] at h
  linarith

/-! ## Telescoping -/

/-- Telescoped upper bound: after `d` further steps the sequence has increased by at most the
total decrement of the upper envelope. -/
lemma seq_le_telescope (n d : ℕ) :
    Real.eulerMascheroniSeq (n + d)
      ≤ Real.eulerMascheroniSeq n + tailUpper ((n : ℝ) + 1) - tailUpper ((n : ℝ) + d + 1) := by
  induction d with
  | zero => norm_num
  | succ e ih =>
    have hm : (0 : ℝ) < (n : ℝ) + e + 1 := by positivity
    have hstep := step_le_tailUpper ((n : ℝ) + e + 1) hm
    have hsucc := eulerMascheroniSeq_succ_sub (n + e)
    push_cast at hsucc
    have hgoal : n + (e + 1) = (n + e) + 1 := by omega
    rw [hgoal]
    have hc : ((n : ℝ) + (e + 1 : ℕ) + 1) = ((n : ℝ) + e + 1) + 1 := by push_cast; ring
    rw [hc]
    linarith

/-- Telescoped lower bound. -/
lemma seq_ge_telescope (n d : ℕ) :
    Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1) - tailLower ((n : ℝ) + d + 1)
      ≤ Real.eulerMascheroniSeq (n + d) := by
  induction d with
  | zero => norm_num
  | succ e ih =>
    have hm : (0 : ℝ) < (n : ℝ) + e + 1 := by positivity
    have hstep := tailLower_le_step ((n : ℝ) + e + 1) hm
    have hsucc := eulerMascheroniSeq_succ_sub (n + e)
    push_cast at hsucc
    have hgoal : n + (e + 1) = (n + e) + 1 := by omega
    rw [hgoal]
    have hc : ((n : ℝ) + (e + 1 : ℕ) + 1) = ((n : ℝ) + e + 1) + 1 := by push_cast; ring
    rw [hc]
    linarith

/-! ## Main results -/

lemma tailUpper_nonneg {x : ℝ} (hx : 0 < x) : 0 ≤ tailUpper x := by
  simp only [tailUpper]
  positivity

/-- **Upper error bound.**  For every `n`, the midpoint-corrected value undershoots `γ` by at
most `1 / (12 (n+1)²)`. -/
theorem eulerMascheroniConstant_sub_accelerated_le (n : ℕ) :
    Real.eulerMascheroniConstant - accelerated n ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  have hbound : ∀ N : ℕ, n ≤ N →
      Real.eulerMascheroniSeq N ≤ Real.eulerMascheroniSeq n + tailUpper ((n : ℝ) + 1) := by
    intro N hN
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le hN
    have h := seq_le_telescope n d
    have hpos : (0 : ℝ) < (n : ℝ) + d + 1 := by positivity
    linarith [tailUpper_nonneg hpos]
  have hlim : Real.eulerMascheroniConstant
      ≤ Real.eulerMascheroniSeq n + tailUpper ((n : ℝ) + 1) := by
    refine le_of_tendsto Real.tendsto_eulerMascheroniSeq ?_
    filter_upwards [eventually_ge_atTop n] with N hN using hbound N hN
  have hexp : tailUpper ((n : ℝ) + 1)
      = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2) := rfl
  simp only [accelerated]
  rw [hexp] at hlim
  linarith

/-- **Lower error bound.**  The error is at least `1/(12 (n+1)²) - 1/(36 (n+1)³)`, so the
constant `1/12` in the upper bound cannot be improved. -/
theorem le_eulerMascheroniConstant_sub_accelerated (n : ℕ) :
    1 / (12 * ((n : ℝ) + 1) ^ 2) - 1 / (36 * ((n : ℝ) + 1) ^ 3)
      ≤ Real.eulerMascheroniConstant - accelerated n := by
  have key : ∀ d : ℕ,
      Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1) - 1 / ((d : ℝ) + 1)
        ≤ Real.eulerMascheroniSeq (n + d) := by
    intro d
    have h := seq_ge_telescope n d
    have hsmall : tailLower ((n : ℝ) + d + 1) ≤ 1 / ((d : ℝ) + 1) := by
      have hd : (0 : ℝ) < (d : ℝ) + 1 := by positivity
      have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have hx : (0 : ℝ) < (n : ℝ) + d + 1 := by positivity
      simp only [tailLower]
      have h1 : 1 / (2 * ((n : ℝ) + d + 1)) ≤ 1 / (2 * ((d : ℝ) + 1)) := by
        apply one_div_le_one_div_of_le (by positivity)
        linarith
      have h2 : 1 / (12 * ((n : ℝ) + d + 1) ^ 2) ≤ 1 / (12 * ((d : ℝ) + 1)) := by
        apply one_div_le_one_div_of_le (by positivity)
        nlinarith
      have h3 : (0 : ℝ) ≤ 1 / (36 * ((n : ℝ) + d + 1) ^ 3) := by positivity
      have h4 : 1 / (2 * ((d : ℝ) + 1)) + 1 / (12 * ((d : ℝ) + 1))
          = (7 / 12) * (1 / ((d : ℝ) + 1)) := by
        field_simp
        ring
      have h5 : (0 : ℝ) < 1 / ((d : ℝ) + 1) := by positivity
      linarith
    linarith
  have hlim : Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1)
      ≤ Real.eulerMascheroniConstant := by
    refine le_of_tendsto_of_tendsto' (b := atTop) (f := fun d : ℕ =>
        Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1) - 1 / ((d : ℝ) + 1))
      (g := fun d : ℕ => Real.eulerMascheroniSeq (n + d)) ?_ ?_ key
    · have h0 : Tendsto (fun d : ℕ => 1 / ((d : ℝ) + 1)) atTop (𝓝 0) :=
        tendsto_one_div_add_atTop_nhds_zero_nat
      have hc : Tendsto (fun _ : ℕ => Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1)) atTop
          (𝓝 (Real.eulerMascheroniSeq n + tailLower ((n : ℝ) + 1))) := tendsto_const_nhds
      simpa using hc.sub h0
    · have hshift : Tendsto (fun d : ℕ => n + d) atTop atTop := by
        simpa [Nat.add_comm] using tendsto_add_atTop_nat n
      exact Real.tendsto_eulerMascheroniSeq.comp hshift
  have hexp : tailLower ((n : ℝ) + 1)
      = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2)
        - 1 / (36 * ((n : ℝ) + 1) ^ 3) := rfl
  simp only [accelerated]
  rw [hexp] at hlim
  linarith

/-- The accelerated sequence is a strict lower approximant of `γ`. -/
theorem accelerated_lt_eulerMascheroniConstant (n : ℕ) :
    accelerated n < Real.eulerMascheroniConstant := by
  have h := le_eulerMascheroniConstant_sub_accelerated n
  have hx : (1 : ℝ) ≤ (n : ℝ) + 1 := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  have hx0 : (0 : ℝ) < (n : ℝ) + 1 := by linarith
  have hid : 1 / (12 * ((n : ℝ) + 1) ^ 2) - 1 / (36 * ((n : ℝ) + 1) ^ 3)
      = (3 * ((n : ℝ) + 1) - 1) / (36 * ((n : ℝ) + 1) ^ 3) := by
    field_simp
    ring
  have hpos : 0 < 1 / (12 * ((n : ℝ) + 1) ^ 2) - 1 / (36 * ((n : ℝ) + 1) ^ 3) := by
    rw [hid]
    apply div_pos (by linarith) (by positivity)
  linarith

/-- **Main theorem.**  The midpoint-corrected sequence approximates `γ` to `O(n⁻²)` with the
explicit constant `1/12`, for every `n : ℕ` (the threshold is `n ≥ 0`). -/
theorem abs_eulerMascheroniConstant_sub_accelerated_le (n : ℕ) :
    |Real.eulerMascheroniConstant - accelerated n| ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  rw [abs_le]
  refine ⟨?_, eulerMascheroniConstant_sub_accelerated_le n⟩
  have h := (accelerated_lt_eulerMascheroniConstant n).le
  have : (0 : ℝ) ≤ 1 / (12 * ((n : ℝ) + 1) ^ 2) := by positivity
  linarith

/-- The uncorrected sequence is only `Θ(n⁻¹)` away from `γ`: the correction term is exactly
the leading error, hence the acceleration gains one full power of `n`. -/
theorem eulerMascheroniConstant_sub_eulerMascheroniSeq_bounds (n : ℕ) :
    1 / (2 * ((n : ℝ) + 1)) < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n ∧
      Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n
        ≤ 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2) := by
  constructor
  · have := accelerated_lt_eulerMascheroniConstant n
    simp only [accelerated] at this
    linarith
  · have := eulerMascheroniConstant_sub_accelerated_le n
    simp only [accelerated] at this
    linarith

/-- The accelerated sequence converges to `γ`. -/
theorem tendsto_accelerated :
    Tendsto accelerated atTop (𝓝 Real.eulerMascheroniConstant) := by
  have h0 : Tendsto (fun n : ℕ => 1 / (2 * ((n : ℝ) + 1))) atTop (𝓝 0) := by
    have h := tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)
    have he : (fun n : ℕ => 1 / (2 * ((n : ℝ) + 1)))
        = fun n : ℕ => (1 / 2 : ℝ) * (1 / ((n : ℝ) + 1)) := by
      funext n
      rw [one_div, one_div, mul_inv]
      ring
    rw [he]
    simpa using h.const_mul (1 / 2 : ℝ)
  have h := Real.tendsto_eulerMascheroniSeq.add h0
  rw [add_zero] at h
  exact Tendsto.congr (fun n => rfl) h

/-- **Sharpness.**  The rescaled error tends to `1`: the constant `1/12` is exactly the
asymptotic error constant, so no smaller constant works for large `n`. -/
theorem tendsto_scaled_error :
    Tendsto (fun n : ℕ => 12 * ((n : ℝ) + 1) ^ 2
      * (Real.eulerMascheroniConstant - accelerated n)) atTop (𝓝 1) := by
  have hsq : Tendsto (fun n : ℕ => 1 - 1 / (3 * ((n : ℝ) + 1))) atTop (𝓝 1) := by
    have h : Tendsto (fun n : ℕ => 1 / (3 * ((n : ℝ) + 1))) atTop (𝓝 0) := by
      have h1 := tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)
      have he : (fun n : ℕ => 1 / (3 * ((n : ℝ) + 1)))
          = fun n : ℕ => (1 / 3 : ℝ) * (1 / ((n : ℝ) + 1)) := by
        funext n
        rw [one_div, one_div, mul_inv]
        ring
      rw [he]
      simpa using h1.const_mul (1 / 3 : ℝ)
    have hc : Tendsto (fun _ : ℕ => (1 : ℝ)) atTop (𝓝 (1 : ℝ)) := tendsto_const_nhds
    simpa using hc.sub h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le hsq tendsto_const_nhds ?_ ?_
  · intro n
    have h := le_eulerMascheroniConstant_sub_accelerated n
    have hx : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have h12 : (0 : ℝ) < 12 * ((n : ℝ) + 1) ^ 2 := by positivity
    have hmul := mul_le_mul_of_nonneg_left h (le_of_lt h12)
    have hid : 12 * ((n : ℝ) + 1) ^ 2
        * (1 / (12 * ((n : ℝ) + 1) ^ 2) - 1 / (36 * ((n : ℝ) + 1) ^ 3))
        = 1 - 1 / (3 * ((n : ℝ) + 1)) := by
      field_simp
      ring
    rw [hid] at hmul
    exact hmul
  · intro n
    have h := eulerMascheroniConstant_sub_accelerated_le n
    have hx : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have h12 : (0 : ℝ) < 12 * ((n : ℝ) + 1) ^ 2 := by positivity
    have hmul := mul_le_mul_of_nonneg_left h (le_of_lt h12)
    have hid : 12 * ((n : ℝ) + 1) ^ 2 * (1 / (12 * ((n : ℝ) + 1) ^ 2)) = 1 := by
      field_simp
    rw [hid] at hmul
    exact hmul

/-- Strict decrease of the second-order envelope correction, the key inequality behind the
monotonicity of the accelerated sequence. -/
lemma envelope_correction_strictAnti {m : ℝ} (hm : 1 ≤ m) :
    1 / (12 * (m + 1) ^ 2) - 1 / (36 * (m + 1) ^ 3)
      < 1 / (12 * m ^ 2) - 1 / (36 * m ^ 3) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hid : (1 / (12 * m ^ 2) - 1 / (36 * m ^ 3))
      - (1 / (12 * (m + 1) ^ 2) - 1 / (36 * (m + 1) ^ 3))
      = (6 * m ^ 3 + 6 * m ^ 2 - 1) / (36 * m ^ 3 * (m + 1) ^ 3) := by
    field_simp
    ring
  have hnum : 0 < 6 * m ^ 3 + 6 * m ^ 2 - 1 := by nlinarith
  have : 0 < (1 / (12 * m ^ 2) - 1 / (36 * m ^ 3))
      - (1 / (12 * (m + 1) ^ 2) - 1 / (36 * (m + 1) ^ 3)) := by
    rw [hid]
    apply div_pos hnum (by positivity)
  linarith

/-- The accelerated sequence is strictly increasing, so it is a monotone family of certified
lower bounds for `γ`. -/
theorem strictMono_accelerated : StrictMono accelerated := by
  refine strictMono_nat_of_lt_succ (fun n => ?_)
  have hm : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hm1 : (1 : ℝ) ≤ (n : ℝ) + 1 := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  have hstep := tailLower_le_step ((n : ℝ) + 1) hm
  have hsucc := eulerMascheroniSeq_succ_sub n
  have hcorr := envelope_correction_strictAnti hm1
  have hexp1 : tailLower ((n : ℝ) + 1)
      = 1 / (2 * ((n : ℝ) + 1)) + (1 / (12 * ((n : ℝ) + 1) ^ 2)
        - 1 / (36 * ((n : ℝ) + 1) ^ 3)) := by
    simp only [tailLower]
    ring
  have hexp2 : tailLower ((n : ℝ) + 1 + 1)
      = 1 / (2 * ((n : ℝ) + 1 + 1)) + (1 / (12 * ((n : ℝ) + 1 + 1) ^ 2)
        - 1 / (36 * ((n : ℝ) + 1 + 1) ^ 3)) := by
    simp only [tailLower]
    ring
  rw [hexp1, hexp2] at hstep
  simp only [accelerated]
  push_cast
  linarith

end EulerMascheroniMidpoint