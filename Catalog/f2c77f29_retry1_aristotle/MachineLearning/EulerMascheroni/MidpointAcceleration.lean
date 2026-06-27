import Mathlib

/-!
# A quadratically-faster midpoint acceleration of the Euler–Mascheroni constant

Mathlib brackets `γ = eulerMascheroniConstant` between the two sequences
`eulerMascheroniSeq n = H_n − log(n+1)` (increasing, from below) and
`eulerMascheroniSeq' n = H_n − log n` (decreasing, from above).  Both have a
*linear* `Θ(1/n)` error.

This file introduces the **midpoint sequence**
```
midpointSeq n = H_n − log(n + 1/2),
```
and proves it is a strictly decreasing sequence converging to `γ` **from above**,
hence `γ < midpointSeq n` for every `n`.  Numerically `midpointSeq n − γ ~ 1/(24 n²)`,
i.e. a *quadratic* acceleration: replacing the shift `log n` (resp. `log(n+1)`) by
the midpoint shift `log(n+1/2)` turns the `Θ(1/n)` error into `Θ(1/n²)`.

The new sandwich `eulerMascheroniSeq n < γ < midpointSeq n` and the strict
improvement `midpointSeq n < eulerMascheroniSeq' n` upgrade the classical
upper approximant.  This continues the catalog's Euler–Mascheroni development
(`MachineLearning.EulerMascheroni.SeriesRepresentation`,
`MachineLearning.EulerMascheroni.Stieltjes`), whose lower approximant is exactly
`eulerMascheroniSeq`; the `midpointSeq_eq_eulerMascheroniSeq_add` identity below
records the precise correction linking the two.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Shifting the logarithm to the *midpoint* `n+1/2`
should beat both classical one-sided approximants.  The Hermite–Hadamard
intuition: `log(n+3/2) − log(n+1/2) = ∫_{n+1/2}^{n+3/2} dx/x ≥ 1/(n+1)` because
`1/x` is convex and `n+1` is the midpoint of the interval, with strict inequality
by strict convexity.  Hence the per-step increment of `midpointSeq` is negative,
so the sequence decreases to `γ` from above.

EXPERIMENT (Experimenter).  Computed `midpointSeq n − γ` for
`n ∈ {1,2,5,10,20,50,100}`: values `0.0173, 0.0065, 0.00137, 0.00038, …` with
`n²·(error) → 0.04167 ≈ 1/24`.  Confirms decreasing-from-above and the quadratic
`1/(24 n²)` rate, vs. `eulerMascheroniSeq' n − γ ~ 1/(2n)` for the classical
upper approximant.

ANALYSIS (Analyst).  The decisive analytic fact is the artanh inequality
`2t < log((1+t)/(1−t))` for `t ∈ (0,1)`, applied at `t = 1/(2n+2)`.  This is
equivalent to strict convexity of `1/x` / positivity of the derivative of
`t ↦ log(1+t) − log(1−t) − 2t`.  Everything else is monotone-limit bookkeeping
matching Mathlib's own treatment of `eulerMascheroniSeq'`.

CRITIQUE (Critic).  `γ < midpointSeq n` is *not* a corollary of Mathlib's
`γ < eulerMascheroniSeq' n` (that only gives `midpointSeq n < eulerMascheroniSeq' n`);
the from-above bound genuinely needs the monotonicity argument.  The sandwich is
non-vacuous: `eulerMascheroniSeq n < midpointSeq n` strictly.

SYNTHESIS (PI).  Midpoint acceleration: a strictly tighter, decreasing,
upper approximant to `γ`.
-/

open Filter Topology Real

namespace EulerMascheroniMidpoint

/-- The midpoint approximant `H_n − log(n + 1/2)`. -/
noncomputable def midpointSeq (n : ℕ) : ℝ := (harmonic n : ℝ) - Real.log ((n : ℝ) + 1 / 2)

/-
**Core artanh inequality.**  For `t ∈ (0,1)`, `2t < log((1+t)/(1−t))`.
Equivalently `t ↦ log(1+t) − log(1−t) − 2t` is strictly increasing from `0`,
its derivative being `2t²/(1−t²) > 0`.
-/
lemma two_mul_lt_log_div (t : ℝ) (ht0 : 0 < t) (ht1 : t < 1) :
    2 * t < Real.log ((1 + t) / (1 - t)) := by
  -- Consider the function $f(x) = \log(1 + x) - \log(1 - x) - 2x$ and show that it is strictly increasing for $x \in (0, 1)$.
  set f : ℝ → ℝ := fun x => Real.log (1 + x) - Real.log (1 - x) - 2 * x
  have h_deriv_pos : ∀ x ∈ Set.Ioo 0 t, 0 < deriv f x := by
    intro x hx
    have h_deriv : deriv f x = 1 / (1 + x) + 1 / (1 - x) - 2 := by
      convert HasDerivAt.deriv ( HasDerivAt.sub ( HasDerivAt.sub ( HasDerivAt.log ( hasDerivAt_id' x |> HasDerivAt.const_add 1 ) ( by linarith [ hx.1 ] : ( 1 + x ) ≠ 0 ) ) ( HasDerivAt.log ( hasDerivAt_id' x |> HasDerivAt.const_sub 1 ) ( by linarith [ hx.2 ] : ( 1 - x ) ≠ 0 ) ) ) ( HasDerivAt.const_mul 2 ( hasDerivAt_id' x ) ) ) using 1 ; ring!;
    rw [ h_deriv, div_add_div, div_sub', lt_div_iff₀ ] <;> nlinarith [ hx.1, hx.2 ];
  -- Since $f$ is differentiable and its derivative is positive on $(0, t)$, we can apply the Mean Value Theorem to $f$ on this interval.
  have h_mvt : ∃ c ∈ Set.Ioo 0 t, deriv f c = (f t - f 0) / (t - 0) := by
    apply_rules [ exists_deriv_eq_slope ];
    · exact continuousOn_of_forall_continuousAt fun x hx => by exact ContinuousAt.sub ( ContinuousAt.sub ( ContinuousAt.log ( continuousAt_const.add continuousAt_id ) ( by linarith [ hx.1 ] ) ) ( ContinuousAt.log ( continuousAt_const.sub continuousAt_id ) ( by linarith [ hx.2 ] ) ) ) ( continuousAt_const.mul continuousAt_id ) ;
    · exact fun x hx => DifferentiableAt.differentiableWithinAt ( by exact DifferentiableAt.sub ( DifferentiableAt.sub ( DifferentiableAt.log ( differentiableAt_id.const_add _ ) ( by linarith [ hx.1 ] ) ) ( DifferentiableAt.log ( differentiableAt_id.const_sub _ ) ( by linarith [ hx.2 ] ) ) ) ( differentiableAt_id.const_mul _ ) );
  simp +zetaDelta at *;
  rw [ Real.log_div ] <;> nlinarith [ h_mvt.choose_spec, h_deriv_pos _ h_mvt.choose_spec.1.1 h_mvt.choose_spec.1.2, mul_div_cancel₀ ( log ( 1 + t ) - log ( 1 - t ) - 2 * t ) ht0.ne' ]

/-
**Per-step decrease.**  `1/(n+1) < log(n+3/2) − log(n+1/2)`; apply
`two_mul_lt_log_div` at `t = 1/(2n+2)`.
-/
lemma midpoint_step (n : ℕ) :
    (1 : ℝ) / (n + 1) < Real.log ((n : ℝ) + 3 / 2) - Real.log ((n : ℝ) + 1 / 2) := by
  convert two_mul_lt_log_div ( 1 / ( 2 * ( n : ℝ ) + 2 ) ) _ _ using 1 <;> ring_nf <;> norm_num at *;
  · rw [ inv_eq_iff_eq_inv ] ; norm_num ; ring;
  · field_simp;
    rw [ ← Real.log_div ( by positivity ) ( by positivity ) ] ; ring;
    rw [ show ( 1 / 2 + n : ℝ ) = ( 1 + n * 2 ) / 2 by ring ] ; norm_num ; ring;
  · positivity;
  · exact inv_lt_one_of_one_lt₀ ( by linarith )

/-
The midpoint sequence is strictly decreasing.
-/
lemma strictAnti_midpointSeq : StrictAnti midpointSeq := by
  refine' strictAnti_nat_of_succ_lt _;
  intro n; unfold midpointSeq; norm_num [ harmonic ];
  norm_num [ Finset.sum_range_succ ];
  have := midpoint_step n; ring_nf at *; linarith;

/-
The midpoint sequence converges to `γ` (squeezed between Mathlib's two
approximants).
-/
lemma tendsto_midpointSeq :
    Tendsto midpointSeq atTop (𝓝 Real.eulerMascheroniConstant) := by
  -- Apply the squeeze theorem with the two sequences that bound the midpoint sequence.
  have h_squeeze : Tendsto (fun n => (harmonic n : ℝ) - Real.log (n + 1)) Filter.atTop (nhds eulerMascheroniConstant) ∧ Tendsto (fun n => (harmonic n : ℝ) - Real.log n) Filter.atTop (nhds eulerMascheroniConstant) := by
    exact ⟨ Real.tendsto_eulerMascheroniSeq, by simpa using Real.tendsto_harmonic_sub_log ⟩;
  refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_squeeze.1 h_squeeze.2 _ _; all_goals filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using sub_le_sub_left ( Real.log_le_log ( by positivity ) ( by linarith ) ) _

/-
**Main: `γ` is approached from above.**  For every `n`, `γ < midpointSeq n`.
-/
theorem eulerMascheroniConstant_lt_midpointSeq (n : ℕ) :
    Real.eulerMascheroniConstant < midpointSeq n := by
  refine' lt_of_le_of_lt _ ( strictAnti_midpointSeq ( Nat.lt_succ_self n ) );
  -- Apply the fact that the limit of a strictly decreasing sequence is less than or equal to any term in the sequence.
  apply le_of_tendsto_of_tendsto tendsto_midpointSeq tendsto_const_nhds (Filter.eventually_atTop.mpr ⟨n + 1, fun m hm => strictAnti_midpointSeq.antitone hm⟩)

/-
The midpoint approximant strictly beats Mathlib's lower approximant.
-/
theorem eulerMascheroniSeq_lt_midpointSeq (n : ℕ) :
    Real.eulerMascheroniSeq n < midpointSeq n := by
  unfold eulerMascheroniSeq midpointSeq;
  gcongr ; norm_num

/-- **New two-sided sandwich** `eulerMascheroniSeq n < γ < midpointSeq n`. -/
theorem midpointSeq_sandwich (n : ℕ) :
    Real.eulerMascheroniSeq n < Real.eulerMascheroniConstant ∧
      Real.eulerMascheroniConstant < midpointSeq n :=
  ⟨Real.eulerMascheroniSeq_lt_eulerMascheroniConstant n,
    eulerMascheroniConstant_lt_midpointSeq n⟩

/-
**Strict improvement of the classical upper approximant.**  For `n ≥ 1`,
`midpointSeq n < eulerMascheroniSeq' n = H_n − log n`.
-/
theorem midpointSeq_lt_eulerMascheroniSeq' (n : ℕ) (hn : 1 ≤ n) :
    midpointSeq n < Real.eulerMascheroniSeq' n := by
  unfold midpointSeq eulerMascheroniSeq';
  rw [ if_neg ( by linarith ) ] ; gcongr ; norm_num

/-
**Link to the catalog lower approximant.**  The midpoint approximant equals
Mathlib's lower approximant `eulerMascheroniSeq n` (the partial sum of the catalog
positive series) plus the explicit midpoint correction `log(n+1) − log(n+1/2)`.
-/
theorem midpointSeq_eq_eulerMascheroniSeq_add (n : ℕ) :
    midpointSeq n =
      Real.eulerMascheroniSeq n + (Real.log ((n : ℝ) + 1) - Real.log ((n : ℝ) + 1 / 2)) := by
  unfold eulerMascheroniSeq midpointSeq; ring;

end EulerMascheroniMidpoint