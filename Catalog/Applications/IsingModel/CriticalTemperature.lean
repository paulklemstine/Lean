import Mathlib

/-!
# 2D Ising Model: Onsager Critical Temperature and Kramers–Wannier Self-Duality

This file formalizes the *value* of the Onsager critical temperature of the 2D
square-lattice Ising model,
`T_c = 2 / ln(1 + √2)`,
together with the Kramers–Wannier self-duality identities that single out this
point.  Working in units `J = k_B = 1`, the inverse critical temperature is
`β_c = 1 / T_c = (1/2) ln(1 + √2)`.

The mathematically decisive fact is that `β_c` is the unique fixed point of the
Kramers–Wannier duality involution `β ↦ β*` characterised by
`sinh(2β) · sinh(2β*) = 1`.  Self-duality `β = β*` forces `sinh(2β) = 1`, and the
solution is exactly `β_c`.  Equivalently the bond variable satisfies
`tanh(β_c) = e^{-2β_c} = √2 - 1`.  Numerically `T_c ≈ 2.269`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The Onsager point `β_c = ½ ln(1+√2)` is the
  self-dual fixed point of Kramers–Wannier duality, equivalently `sinh(2β_c)=1`.
* **Experiment (Experimenter).** Reduce everything to `exp(2β_c) = 1 + √2`
  (via `Real.exp_log`, valid since `1+√2 > 0`) and to the algebraic identity
  `1/(1+√2) = √2 - 1`.  Then `sinh`, `tanh` collapse to clean closed forms.
* **Analysis (Analyst).** Survives. The transcendental statement is genuinely a
  consequence of `exp(2β_c)=1+√2`, but the duality framing
  (`sinh(2β)·sinh(2β*)=1` fixed point) is what makes `β_c` *canonical*, not just a
  number; the bond identity `tanh β_c = e^{-2β_c}` is the lattice form used in
  Kramers–Wannier.  The tight decimal bracket `(2.26,2.27)` needs exponential
  Taylor estimates (true but hard); the clean bracket `(2,3)` via `log 2 < L < 1`
  already excludes any trivial reading.
* **Critique (Critic).** None of the results are `True`/`rfl`/`native_decide`;
  each uses `Real.exp_log`, `sinh`/`tanh` expansions and `field_simp`/`nlinarith`
  reasoning about `√2`. The numeric bracketing of `T_c` guards against a vacuous
  "definition equals itself" reading.
* **Synthesis (PI).** `β_c` is pinned down three independent ways: transcendental
  (`sinh 2β_c = 1`), algebraic-bond (`tanh β_c = √2 - 1`), and numeric
  (`2 < T_c < 3`, with true value `≈ 2.269`).
-/

namespace Ising

open Real

/-- Inverse Onsager critical temperature (units `J = k_B = 1`): `β_c = ½ ln(1+√2)`. -/
noncomputable def betaC : ℝ := Real.log (1 + Real.sqrt 2) / 2

/-- Onsager critical temperature: `T_c = 2 / ln(1+√2)`. -/
noncomputable def TC : ℝ := 2 / Real.log (1 + Real.sqrt 2)

/-- `1 + √2 > 1`, hence its logarithm is positive. -/
lemma one_lt_one_add_sqrt_two : (1 : ℝ) < 1 + Real.sqrt 2 := by
  have : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  linarith

/-- The logarithm appearing in the critical temperature is positive. -/
lemma log_one_add_sqrt_two_pos : 0 < Real.log (1 + Real.sqrt 2) :=
  Real.log_pos one_lt_one_add_sqrt_two

/-- The exponential of `2β_c` is `1 + √2`. -/
lemma exp_two_betaC : Real.exp (2 * betaC) = 1 + Real.sqrt 2 := by
  have h : (0:ℝ) < 1 + Real.sqrt 2 := by positivity
  rw [show 2 * betaC = Real.log (1 + Real.sqrt 2) by unfold betaC; ring, Real.exp_log h]

/-- The exponential of `-2β_c` is `√2 - 1` (the reciprocal of `1 + √2`). -/
lemma exp_neg_two_betaC : Real.exp (-(2 * betaC)) = Real.sqrt 2 - 1 := by
  rw [Real.exp_neg, exp_two_betaC]
  have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have : (1:ℝ) + Real.sqrt 2 ≠ 0 := by positivity
  field_simp
  nlinarith [hs]

/-- `β_c` is positive. -/
lemma betaC_pos : 0 < betaC := by
  unfold betaC; exact div_pos log_one_add_sqrt_two_pos (by norm_num)

/-- `T_c` is positive. -/
lemma TC_pos : 0 < TC := by
  unfold TC; exact div_pos (by norm_num) log_one_add_sqrt_two_pos

/-- `β_c` and `T_c` are reciprocal: `T_c = 1 / β_c`, i.e. `β_c · T_c = 1`. -/
lemma betaC_mul_TC : betaC * TC = 1 := by
  unfold betaC TC
  have h := log_one_add_sqrt_two_pos.ne'
  field_simp

/-- **Kramers–Wannier self-duality.** The critical point satisfies `sinh(2β_c) = 1`.
This is the fixed-point equation of the duality involution `sinh(2β)·sinh(2β*)=1`. -/
theorem sinh_two_betaC : Real.sinh (2 * betaC) = 1 := by
  rw [Real.sinh_eq, exp_two_betaC, exp_neg_two_betaC]; ring

/-- The critical point is its own Kramers–Wannier dual: `sinh(2β_c)² = 1`, i.e.
`sinh(2β_c)·sinh(2β_c) = 1`. -/
theorem self_dual : Real.sinh (2 * betaC) * Real.sinh (2 * betaC) = 1 := by
  rw [sinh_two_betaC]; ring

/-- **Bond form of self-duality.** `tanh(β_c) = √2 - 1 = e^{-2β_c}`. -/
theorem tanh_betaC : Real.tanh betaC = Real.sqrt 2 - 1 := by
  rw [Real.tanh_eq_sinh_div_cosh, Real.sinh_eq, Real.cosh_eq, Real.exp_neg]
  have ha : (0:ℝ) < Real.exp betaC := Real.exp_pos _
  have ha2 : Real.exp betaC ^ 2 = 1 + Real.sqrt 2 := by
    rw [← Real.exp_nat_mul]; norm_num; exact exp_two_betaC
  have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hd : (0:ℝ) < Real.exp betaC + (Real.exp betaC)⁻¹ := by positivity
  field_simp
  nlinarith [ha2, hs, ha, Real.sqrt_nonneg 2]

/-- The duality fixed-point equation in bond variables: `tanh(β_c) = e^{-2β_c}`. -/
theorem tanh_betaC_eq_exp : Real.tanh betaC = Real.exp (-(2 * betaC)) := by
  rw [tanh_betaC, exp_neg_two_betaC]

/-- Two-decimal bracketing of `√2`. -/
lemma sqrt2_bracket : 1.41 < Real.sqrt 2 ∧ Real.sqrt 2 < 1.42 := by
  constructor
  · rw [show (1.41:ℝ) = Real.sqrt (1.41^2) by rw [Real.sqrt_sq]; norm_num]
    apply Real.sqrt_lt_sqrt <;> norm_num
  · rw [show (1.42:ℝ) = Real.sqrt (1.42^2) by rw [Real.sqrt_sq]; norm_num]
    apply Real.sqrt_lt_sqrt <;> norm_num

/-- Numeric bracketing of the Onsager critical temperature: `2 < T_c < 3`
(the exact value is `≈ 2.269`). -/
theorem TC_bounds : 2 < TC ∧ TC < 3 := by
  have h2 : (2:ℝ) < 1 + Real.sqrt 2 := by have := sqrt2_bracket.1; linarith
  have h2' : 1 + Real.sqrt 2 < Real.exp 1 := by
    have := sqrt2_bracket.2
    have he : (2.7182818283:ℝ) < Real.exp 1 := Real.exp_one_gt_d9
    linarith
  have hLpos : 0 < Real.log (1 + Real.sqrt 2) := Real.log_pos (by linarith)
  have hLlt1 : Real.log (1 + Real.sqrt 2) < 1 := by
    have := Real.log_lt_log (by linarith : (0:ℝ) < 1 + Real.sqrt 2) h2'
    rwa [Real.log_exp] at this
  have hL23 : 2/3 < Real.log (1 + Real.sqrt 2) := by
    have hlog2 : (0.6931471803:ℝ) < Real.log 2 := Real.log_two_gt_d9
    have : Real.log 2 < Real.log (1 + Real.sqrt 2) := Real.log_lt_log (by norm_num) h2
    linarith
  refine ⟨?_, ?_⟩
  · rw [TC, lt_div_iff₀ hLpos]; linarith
  · rw [TC, div_lt_iff₀ hLpos]; linarith

end Ising