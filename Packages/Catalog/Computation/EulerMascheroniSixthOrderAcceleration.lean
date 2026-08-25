import Mathlib
import Computation.EulerMascheroniMidpointAcceleration
import Computation.EulerMascheroniQuarticAcceleration

/-!
# Sixth-order acceleration of the Euler–Mascheroni sequence

Third cycle of the acceleration programme.  `Computation.EulerMascheroniMidpointAcceleration`
proved the midpoint correction is `O(n⁻²)` with sharp constant `1/12`, and
`Computation.EulerMascheroniQuarticAcceleration` proved that adding the curvature term
`1/(12 (n+1)²)` gives `O(n⁻⁴)` with sharp constant `1/120`.  Both constants are the
Bernoulli numbers `|B₂|/2 = 1/12` and `|B₄|/4 = 1/120`.  The pattern predicts that the next
truncation

`accelerated3 n = eulerMascheroniSeq n + 1/(2(n+1)) + 1/(12(n+1)²) - 1/(120(n+1)⁴)`

is accurate to `|B₆|/6 = 1/252` times `(n+1)⁻⁶`.  We prove exactly that:

* `accelerated3_le_eulerMascheroniConstant` : `accelerated3 n ≤ γ`;
* `abs_accelerated3_sub_le` : `|γ - accelerated3 n| ≤ 1 / (252 (n+1)⁶)`.

The proof needs only *one* new ingredient beyond the previous files, namely the sixth-order
Padé bound `pade6_le_log_one_add`; everything else is the envelope transfer machinery
`tail_le_envelope` / `envelope_le_tail`.  This is the structural payoff of the envelope
formulation: each further order of acceleration costs exactly one single-variable inequality
between `log (1 + x)` and a rational function.
-/

open Filter Topology Real

namespace EulerMascheroniMidpoint

/-! ## The sixth-order Padé bound -/

/-- Sixth-order lower Padé bound for the logarithm.  The three summands are the second-order
Padé approximant, the fourth-order Bernoulli correction `x⁴((1+x)⁴-1)/(120(1+x)⁴)` and the
sixth-order Bernoulli correction `x⁶((1+x)⁶-1)/(252(1+x)⁶)`.  The difference function has
derivative `(63x⁸ + 126x⁹ + 98x¹⁰ + 35x¹¹ + 5x¹²) / (210 (1+x)⁷) ≥ 0`. -/
theorem pade6_le_log_one_add (x : ℝ) (hx : 0 ≤ x) :
    (12 * x + 18 * x ^ 2 + 4 * x ^ 3 - x ^ 4) / (12 * (1 + x) ^ 2)
      + x ^ 4 * ((1 + x) ^ 4 - 1) / (120 * (1 + x) ^ 4)
      - x ^ 6 * ((1 + x) ^ 6 - 1) / (252 * (1 + x) ^ 6) ≤ log (1 + x) := by
  set f : ℝ → ℝ := fun y : ℝ => log (1 + y) -
    ((12 * y + 18 * y ^ 2 + 4 * y ^ 3 - y ^ 4) / (12 * (1 + y) ^ 2)
      + y ^ 4 * ((1 + y) ^ 4 - 1) / (120 * (1 + y) ^ 4)
      - y ^ 6 * ((1 + y) ^ 6 - 1) / (252 * (1 + y) ^ 6)) with hf
  have key : ∀ y : ℝ, 0 ≤ y → 0 ≤ f y := by
    refine nonneg_of_hasDerivAt_nonneg
      (f' := fun y => (63 * y ^ 8 + 126 * y ^ 9 + 98 * y ^ 10 + 35 * y ^ 11 + 5 * y ^ 12)
        / (210 * (1 + y) ^ 7)) ?_ ?_ ?_
    · simp [hf]
    · intro y hy
      have hy1 : (0 : ℝ) < 1 + y := by linarith
      have hbase : HasDerivAt (fun z : ℝ => 1 + z) 1 y :=
        (hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_add 1
      have hlog : HasDerivAt (fun z : ℝ => log (1 + z)) (1 / (1 + y)) y := by
        have h := (Real.hasDerivAt_log (x := 1 + y) (by positivity)).comp y hbase
        simpa [one_div] using h
      -- second-order Padé term
      have hN1 : HasDerivAt (fun z : ℝ => 12 * z + 18 * z ^ 2 + 4 * z ^ 3 - z ^ 4)
          (12 + 36 * y + 12 * y ^ 2 - 4 * y ^ 3) y := by
        have h := ((((hasDerivAt_id' (𝕜 := ℝ) (x := y)).const_mul (12 : ℝ)).add
          ((hasDerivAt_pow 2 y).const_mul (18 : ℝ))).add
          ((hasDerivAt_pow 3 y).const_mul (4 : ℝ))).sub (hasDerivAt_pow 4 y)
        refine (h.congr_deriv (by push_cast; ring)).congr_of_eventuallyEq
          (Filter.Eventually.of_forall (fun z => ?_))
        simp only [Pi.add_apply, Pi.sub_apply]
        try ring
      have hD1 : HasDerivAt (fun z : ℝ => 12 * (1 + z) ^ 2) (12 * (2 * (1 + y))) y := by
        have h := (hbase.pow 2).const_mul (12 : ℝ)
        convert h using 1
        push_cast
        ring
      have hT1 := hN1.div hD1 (by positivity)
      -- fourth-order correction
      have hN2 : HasDerivAt (fun z : ℝ => z ^ 4 * ((1 + z) ^ 4 - 1))
          (4 * y ^ 3 * ((1 + y) ^ 4 - 1) + y ^ 4 * (4 * (1 + y) ^ 3)) y := by
        have h := (hasDerivAt_pow 4 y).mul ((hbase.pow 4).sub_const 1)
        convert h using 1
        simp only [Pi.pow_apply]
        push_cast
        ring
      have hD2 : HasDerivAt (fun z : ℝ => 120 * (1 + z) ^ 4) (120 * (4 * (1 + y) ^ 3)) y := by
        have h := (hbase.pow 4).const_mul (120 : ℝ)
        convert h using 1
        push_cast
        ring
      have hT2 := hN2.div hD2 (by positivity)
      -- sixth-order correction
      have hN3 : HasDerivAt (fun z : ℝ => z ^ 6 * ((1 + z) ^ 6 - 1))
          (6 * y ^ 5 * ((1 + y) ^ 6 - 1) + y ^ 6 * (6 * (1 + y) ^ 5)) y := by
        have h := (hasDerivAt_pow 6 y).mul ((hbase.pow 6).sub_const 1)
        convert h using 1
        simp only [Pi.pow_apply]
        push_cast
        ring
      have hD3 : HasDerivAt (fun z : ℝ => 252 * (1 + z) ^ 6) (252 * (6 * (1 + y) ^ 5)) y := by
        have h := (hbase.pow 6).const_mul (252 : ℝ)
        convert h using 1
        push_cast
        ring
      have hT3 := hN3.div hD3 (by positivity)
      have hsum := hlog.sub ((hT1.add hT2).sub hT3)
      convert hsum using 1
      field_simp
      ring
    · intro y hy
      have : (0 : ℝ) < 1 + y := by linarith
      positivity
  have := key x hx
  simp only [hf] at this
  linarith

/-! ## The sixth-order accelerated sequence -/

/-- The third truncation of the Bernoulli expansion of `γ - eulerMascheroniSeq n`. -/
noncomputable def accelerated3 (n : ℕ) : ℝ :=
  Real.eulerMascheroniSeq n + 1 / (2 * (n + 1 : ℝ)) + 1 / (12 * (n + 1 : ℝ) ^ 2)
    - 1 / (120 * (n + 1 : ℝ) ^ 4)

/-- Sixth-order envelope. -/
noncomputable def tail6 (x : ℝ) : ℝ :=
  1 / (2 * x) + 1 / (12 * x ^ 2) - 1 / (120 * x ^ 4) + 1 / (252 * x ^ 6)

lemma tail6_step (m : ℝ) (hm : 1 ≤ m) :
    1 / m - log (1 + 1 / m) ≤ tail6 m - tail6 (m + 1) := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hm1 : (0 : ℝ) < m + 1 := by linarith
  have hx : (0 : ℝ) ≤ 1 / m := by positivity
  have h := pade6_le_log_one_add (1 / m) hx
  have hid : (12 * (1 / m) + 18 * (1 / m) ^ 2 + 4 * (1 / m) ^ 3 - (1 / m) ^ 4)
        / (12 * (1 + 1 / m) ^ 2)
      + (1 / m) ^ 4 * ((1 + 1 / m) ^ 4 - 1) / (120 * (1 + 1 / m) ^ 4)
      - (1 / m) ^ 6 * ((1 + 1 / m) ^ 6 - 1) / (252 * (1 + 1 / m) ^ 6)
      = 1 / m - (tail6 m - tail6 (m + 1)) := by
    simp only [tail6]
    field_simp
    ring
  rw [hid] at h
  linarith

lemma tail6_nonneg {m : ℝ} (hm : 1 ≤ m) : 0 ≤ tail6 m := by
  have hm0 : (0 : ℝ) < m := by linarith
  have hid : tail6 m
      = (1260 * m ^ 5 + 210 * m ^ 4 - 21 * m ^ 2 + 10) / (2520 * m ^ 6) := by
    simp only [tail6]
    field_simp
    ring
  rw [hid]
  apply div_nonneg _ (by positivity)
  have h1 : m ^ 2 ≤ m ^ 5 := by nlinarith [sq_nonneg m, sq_nonneg (m - 1), sq_nonneg (m ^ 2 - 1)]
  have h2 : (0 : ℝ) ≤ m ^ 4 := by positivity
  nlinarith

/-- The sixth-order truncation is still a lower approximant of `γ`: this is exactly the
fourth-order envelope bound from the previous file. -/
theorem accelerated3_le_eulerMascheroniConstant (n : ℕ) :
    accelerated3 n ≤ Real.eulerMascheroniConstant := by
  have h := envelope_le_tail tail4 (fun m hm => tail4_le_one_div hm) tail4_step n
  have hexp : tail4 ((n : ℝ) + 1) = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2)
      - 1 / (120 * ((n : ℝ) + 1) ^ 4) := rfl
  rw [hexp] at h
  simp only [accelerated3]
  linarith

/-- **Main theorem.**  The sixth-order truncation approximates `γ` with error at most
`1 / (252 (n+1)⁶)`, the Bernoulli constant `|B₆|/6`. -/
theorem eulerMascheroniConstant_sub_accelerated3_le (n : ℕ) :
    Real.eulerMascheroniConstant - accelerated3 n ≤ 1 / (252 * ((n : ℝ) + 1) ^ 6) := by
  have h := tail_le_envelope tail6 (fun m hm => tail6_nonneg hm) tail6_step n
  have hexp : tail6 ((n : ℝ) + 1) = 1 / (2 * ((n : ℝ) + 1)) + 1 / (12 * ((n : ℝ) + 1) ^ 2)
      - 1 / (120 * ((n : ℝ) + 1) ^ 4) + 1 / (252 * ((n : ℝ) + 1) ^ 6) := rfl
  rw [hexp] at h
  simp only [accelerated3]
  linarith

/-- Two-sided sixth-order error bound. -/
theorem abs_accelerated3_sub_le (n : ℕ) :
    |Real.eulerMascheroniConstant - accelerated3 n| ≤ 1 / (252 * ((n : ℝ) + 1) ^ 6) := by
  rw [abs_le]
  refine ⟨?_, eulerMascheroniConstant_sub_accelerated3_le n⟩
  have h := accelerated3_le_eulerMascheroniConstant n
  have : (0 : ℝ) ≤ 1 / (252 * ((n : ℝ) + 1) ^ 6) := by positivity
  linarith

/-- The three accelerations are nested lower/upper approximants: the sixth-order truncation
sits between the midpoint-corrected value and `γ`, while `accelerated2` stays above `γ`. -/
theorem acceleration_hierarchy (n : ℕ) :
    accelerated n < accelerated3 n ∧ accelerated3 n ≤ Real.eulerMascheroniConstant ∧
      Real.eulerMascheroniConstant < accelerated2 n := by
  refine ⟨?_, accelerated3_le_eulerMascheroniConstant n,
    eulerMascheroniConstant_lt_accelerated2 n⟩
  have hm : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hid : accelerated3 n - accelerated n
      = (10 * ((n : ℝ) + 1) ^ 2 - 1) / (120 * ((n : ℝ) + 1) ^ 4) := by
    simp only [accelerated3, accelerated]
    field_simp
    ring
  have hm1 : (1 : ℝ) ≤ (n : ℝ) + 1 := by
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  have hpos : 0 < accelerated3 n - accelerated n := by
    rw [hid]
    apply div_pos _ (by positivity)
    nlinarith
  linarith

end EulerMascheroniMidpoint