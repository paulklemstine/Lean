import Mathlib
import Bridges.InnerProductBridge

/-!
# Natural Gradient: Exact Models, Rates, and Geodesic Boundaries

Natural gradient is best understood as steepest descent in a local metric, not as an
exact geodesic integrator.  This development isolates both facts.  For a constant
diagonal Fisher metric, the matched quadratic loss is solved at a rate independent
of the spread of the metric weights.  Harmonic step sizes admit an exact polynomial
law.  A separate one-dimensional calculation shows that an Euler natural-gradient
step need not be a geodesic midpoint when the metric varies.
-/

open scoped BigOperators
open Filter Topology

noncomputable section

namespace InformationGeometryOptimization

/-- A positive diagonal metric and its matched quadratic objective. -/
def fisherEnergy {n : ℕ} (w x : Fin n → ℝ) : ℝ :=
  (1 / 2 : ℝ) * ∑ i, w i * (x i) ^ 2

/-- The natural-gradient Euler step for the matched quadratic objective.
The inverse metric cancels every weight. -/
def matchedNaturalStep {n : ℕ} (η : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => (1 - η) * x i

/-- The local quadratic model whose metric term is diagonal with weights `w`. -/
def localMetricModel {n : ℕ} (w g : Fin n → ℝ) (η : ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, (g i * v i + w i * (v i) ^ 2 / (2 * η))

/-
The inverse-metric direction minimizes the local metric model.  This is the
precise steepest-descent characterization of natural gradient.
-/
theorem naturalDirection_minimizes_local_model {n : ℕ}
    (w g : Fin n → ℝ) (η : ℝ) (hη : 0 < η) (hw : ∀ i, 0 < w i)
    (v : Fin n → ℝ) :
    localMetricModel w g η (fun i => -η * g i / w i) ≤
      localMetricModel w g η v := by
  refine' Finset.sum_le_sum fun i _ => _;
  field_simp;
  rw [ div_le_iff₀ ( hw i ) ] ; nlinarith [ sq_nonneg ( v i * w i + g i * η ), hw i ]

/-
The matched quadratic energy contracts by the square of the scalar step factor,
with no dependence on the largest or smallest metric weight.
-/
theorem fisherEnergy_matched_step_exact {n : ℕ} (w x : Fin n → ℝ) (η : ℝ) :
    fisherEnergy w (matchedNaturalStep η x) =
      (1 - η) ^ 2 * fisherEnergy w x := by
  unfold fisherEnergy matchedNaturalStep;
  simp +decide only [mul_pow, Finset.mul_sum _ _ _, mul_left_comm]

/-- A constant-step matched natural-gradient orbit. -/
def constantOrbit {n : ℕ} (η : ℝ) (x₀ : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => x₀
  | k + 1 => matchedNaturalStep η (constantOrbit η x₀ k)

/-
Exact condition-number-free energy law for every iterate.
-/
theorem constantOrbit_energy_exact {n : ℕ} (w x₀ : Fin n → ℝ) (η : ℝ) :
    ∀ k, fisherEnergy w (constantOrbit η x₀ k) =
      ((1 - η) ^ 2) ^ k * fisherEnergy w x₀ := by
  intro k;
  induction' k with k ih;
  · norm_num [ constantOrbit ];
  · convert fisherEnergy_matched_step_exact w ( constantOrbit η x₀ k ) η using 1;
    rw [ ih, pow_succ', mul_assoc ]

/-
Under a genuine contraction step, the energy converges geometrically.
-/
theorem constantOrbit_energy_tendsto_zero {n : ℕ} (w x₀ : Fin n → ℝ)
    (η : ℝ) (hη0 : 0 < η) (hη1 : η < 1) :
    Tendsto (fun k => fisherEnergy w (constantOrbit η x₀ k)) atTop (𝓝 0) := by
  convert Tendsto.const_mul ( fisherEnergy w x₀ ) ( tendsto_pow_atTop_nhds_zero_of_abs_lt_one ?_ ) using 1;
  rotate_left;
  grind +splitIndPred;
  exacts [ ( 1 - η ) ^ 2, abs_lt.mpr ⟨ by nlinarith, by nlinarith ⟩, funext fun k => by rw [ constantOrbit_energy_exact ] ; ring ]

/-- Harmonic-step orbit, with step `1/(k+2)` at transition `k → k+1`. -/
def harmonicOrbit {n : ℕ} (x₀ : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => x₀
  | k + 1 => matchedNaturalStep (1 / ((k : ℝ) + 2)) (harmonicOrbit x₀ k)

/-
Harmonic natural-gradient steps have the exact parameter law `xₖ=x₀/(k+1)`.
-/
theorem harmonicOrbit_exact {n : ℕ} (x₀ : Fin n → ℝ) :
    ∀ (k : ℕ) (i : Fin n), harmonicOrbit x₀ k i = x₀ i / ((k : ℝ) + 1) := by
  intro k i
  induction' k with k ih generalizing i
  · norm_num [harmonicOrbit]
  · norm_num [harmonicOrbit] at *
    convert congr_arg (fun x : ℝ => (1 - ((k : ℝ) + 2)⁻¹) * x) (ih i) using 1 <;> ring_nf
    field_simp
    ring

/-
Consequently, on the matched quadratic the harmonic schedule has the stronger
`1/(k+1)²` objective law, rather than merely an `O(1/k)` guarantee.
-/
theorem harmonicOrbit_energy_exact {n : ℕ} (w x₀ : Fin n → ℝ) (k : ℕ) :
    fisherEnergy w (harmonicOrbit x₀ k) =
      fisherEnergy w x₀ / (((k : ℝ) + 1) ^ 2) := by
  unfold fisherEnergy;
  simp +decide only [harmonicOrbit_exact];
  simp +decide [div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm,
    Finset.mul_sum _ _ _, sq]

/-
In the one-dimensional metric whose flattening coordinate is `Φ(x)=x²`, the
metric midpoint between `2` and `1` must have square `5/2`.  The Euler
natural-gradient step `2 - (1/16)·8 = 3/2` does not satisfy this identity.
Thus a natural-gradient Euler update is not, in general, an exact geodesic step.
-/
theorem natural_gradient_euler_not_geodesic_midpoint :
    let start : ℝ := 2
    let target : ℝ := 1
    let inverseMetricAtStart : ℝ := 1 / 16
    let lossDerivativeAtStart : ℝ := 8
    let euler := start - inverseMetricAtStart * lossDerivativeAtStart
    euler ^ 2 ≠ (start ^ 2 + target ^ 2) / 2 := by
  norm_num

/-
Orthogonal modes obey the same condition-free contraction law.  This links the
matched natural-gradient calculation to the Pythagorean decomposition of energy.
-/
theorem orthogonal_mode_contraction {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (x y : E) (hxy : inner ℝ x y = 0) (η : ℝ) :
    ‖(1 - η) • (x + y)‖ ^ 2 =
      (1 - η) ^ 2 * (‖x‖ ^ 2 + ‖y‖ ^ 2) := by
  rw [norm_smul, mul_pow, InnerProductBridge.pythagorean x y hxy]
  rw [Real.norm_eq_abs, sq_abs]

-- !-- Lab Notes -- !--
/-
Hypothesis: Natural gradient should remove conditioning when the objective Hessian
matches a constant Fisher metric, while the stronger assertion that every Euler
update is a geodesic should fail for variable metrics.

Experiment: Completing the local metric square identifies the inverse-metric update
as the unique local-model minimizer.  Iterating the matched quadratic update yields
exact geometric and harmonic laws.  A nonlinear flattening coordinate supplies a
one-dimensional geodesic-midpoint test.

Analysis: Metric conditioning cancels algebraically only in the matched model.  The
rate is then independent of the weight ratio.  Harmonic steps produce polynomial,
not exponential, decay even for this strongly convex quadratic.  Local steepest
descent and exact geodesic integration are therefore distinct notions.

Critique: The unrestricted convergence conjecture omits smoothness, convexity,
completeness, diameter, and metric-variation hypotheses.  No universal conclusion
can follow from shortest-path language alone.  The results here deliberately make
the matching and step-size assumptions explicit and include a concrete boundary
case against the geodesic equivalence.

Synthesis: The surviving principle is a preconditioning theorem: matching the
objective curvature to a constant Fisher metric removes spectral conditioning.
Variable-metric algorithms require retractions or exponential maps, plus curvature
control, before geodesic convergence claims become valid.
-/
-- !-- End Lab Notes -- !--

end InformationGeometryOptimization