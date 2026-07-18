import Mathlib
import MachineLearning.ResNetLipschitz

/-!
# Finite-Horizon Shadowing for Numerical Orbits

A local one-step error bound propagates through an iterated map according to a
discrete Gronwall inequality.  This gives a rigorous finite-horizon guarantee for
any Lipschitz dynamical system and a concrete specialization to the logistic map
`x ↦ 4x(1-x)` on the unit interval.

The result deliberately distinguishes finite-horizon error propagation from the
classical hyperbolic shadowing lemma.  Lipschitz continuity alone produces a
geometric error budget; it does not imply a horizon-independent shadowing radius
for expanding dynamics.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer), ranked by expected impact:
(1) uniformly hyperbolic program semantics admit horizon-independent shadowing;
(2) floating-point executions carry local certificates that compose into a
shadowing witness; (3) residual network dynamics and numerical orbit stability
share one geometric error calculus; (4) contracting maps admit a uniform
`δ/(1-L)` shadowing radius; (5) finite pseudo-orbits of an `L`-Lipschitz map are
shadowed from their first point with budget `δ ∑_{k<n} L^k`; (6) invariant-region
proofs permit sharper constants; and (7) logistic precision requirements admit
explicit horizon-dependent inequalities.

EXPERIMENT (Experimenter): isolate the one-step recurrence using the triangle
inequality, then solve it by induction.  Specialize the abstract estimate to the
logistic map after proving forward invariance and its sharp interval Lipschitz
constant four.

ANALYSIS (Analyst): the proof separates numerical semantics (the local defect)
from dynamics (the Lipschitz amplification).  This is the same multiplicative
error-propagation structure that appears in depth-wise robustness bounds for
composed learning systems.

CRITIQUE (Critic): conjectures (1) and (2) require precise hyperbolic and
floating-point semantics not supplied here.  Conjecture (3) survives as a direct
bridge theorem, while (4)--(7) survive quantitatively.  The geometric factor
grows exponentially when `L > 1`; hence this theorem does not support a
uniform-in-time claim.  The logistic estimate is
conditional on every reported pseudo-orbit point lying in `[0,1]`, exactly where
the constant four is valid.  No floating-point model is silently identified with
real arithmetic.

SYNTHESIS (Principal Investigator): the surviving result is a quantitative,
finite-horizon shadowing certificate.  It supplies the exact local precision
required for a requested horizon and exposes why a classical hyperbolicity
argument, rather than continuity alone, is needed for an infinite-time theorem.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Function

namespace ChaosShadowing

/-- The logistic map at the fully developed parameter value four. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- A sequence has local defect at most `δ` through time `N`. -/
def IsPseudoOrbit {E : Type*} [NormedAddCommGroup E]
    (f : E → E) (x : ℕ → E) (δ : ℝ) (N : ℕ) : Prop :=
  ∀ n < N, ‖x (n + 1) - f (x n)‖ ≤ δ

/-- The exact orbit generated from an initial state. -/
def exactOrbit {E : Type*} (f : E → E) (y₀ : E) (n : ℕ) : E :=
  (f^[n]) y₀

@[simp] lemma exactOrbit_zero {E : Type*} (f : E → E) (y₀ : E) :
    exactOrbit f y₀ 0 = y₀ := by
  rfl

lemma exactOrbit_succ {E : Type*} (f : E → E) (y₀ : E) (n : ℕ) :
    exactOrbit f y₀ (n + 1) = f (exactOrbit f y₀ n) := by
  exact Function.iterate_succ_apply' f n y₀

/-
One local rounding defect plus the amplified previous discrepancy controls
    the next discrepancy.
-/
lemma shadow_error_step {E : Type*} [NormedAddCommGroup E]
    (f : E → E) (x : ℕ → E) (y₀ : E) (L δ : ℝ) (N n : ℕ)
    (hL : ∀ a b, ‖f a - f b‖ ≤ L * ‖a - b‖)
    (hp : IsPseudoOrbit f x δ N) (hn : n < N) :
    ‖x (n + 1) - exactOrbit f y₀ (n + 1)‖ ≤
      δ + L * ‖x n - exactOrbit f y₀ n‖ := by
  have := hp n hn; rw [ exactOrbit_succ ];
  simpa using norm_add_le ( x ( n + 1 ) - f ( x n ) ) ( f ( x n ) - f ( exactOrbit f y₀ n ) ) |> le_trans <| add_le_add this ( hL _ _ )

/-
Discrete Gronwall shadowing bound for a finite pseudo-orbit.
-/
theorem finite_horizon_shadow_bound {E : Type*} [NormedAddCommGroup E]
    (f : E → E) (x : ℕ → E) (L δ : ℝ) (N : ℕ)
    (hL0 : 0 ≤ L) (hδ0 : 0 ≤ δ)
    (hL : ∀ a b, ‖f a - f b‖ ≤ L * ‖a - b‖)
    (hp : IsPseudoOrbit f x δ N) :
    ∀ n ≤ N, ‖x n - exactOrbit f (x 0) n‖ ≤ δ * ∑ k ∈ Finset.range n, L ^ k := by
  intro n hn
  induction' n with n ih <;> simp_all +decide [ Finset.sum_range_succ ];
  refine' le_trans ( shadow_error_step f x _ _ _ _ _ hL hp hn ) _;
  nlinarith [ ih hn.le, pow_nonneg hL0 n, geom_sum_mul_neg L n ]

/-
For a contracting map, the finite geometric budget is bounded uniformly in
    the horizon by `δ / (1-L)`.
-/
theorem contraction_uniform_shadow_bound {E : Type*} [NormedAddCommGroup E]
    (f : E → E) (x : ℕ → E) (L δ : ℝ) (N : ℕ)
    (hL0 : 0 ≤ L) (hL1 : L < 1) (hδ0 : 0 ≤ δ)
    (hL : ∀ a b, ‖f a - f b‖ ≤ L * ‖a - b‖)
    (hp : IsPseudoOrbit f x δ N) :
    ∀ n ≤ N, ‖x n - exactOrbit f (x 0) n‖ ≤ δ / (1 - L) := by
  intro n hn; rw [ le_div_iff₀ ];
  · refine' le_trans ( mul_le_mul_of_nonneg_right ( finite_horizon_shadow_bound f x L δ N hL0 hδ0 hL hp n hn ) ( sub_nonneg.2 hL1.le ) ) _;
    nlinarith [ mul_le_mul_of_nonneg_left ( show ∑ k ∈ Finset.range n, L ^ k ≤ 1 / ( 1 - L ) by rw [ le_div_iff₀ ] <;> nlinarith [ pow_nonneg hL0 n, geom_sum_mul L n ] ) hδ0, mul_div_cancel₀ 1 ( by linarith : ( 1 - L ) ≠ 0 ) ];
  · linarith

/-
A residual dynamical system inherits a finite-horizon shadowing certificate
from the additive Lipschitz estimate for residual blocks.  This bridges depth-wise
robustness estimates with numerical orbit stability.
-/
theorem residual_finite_horizon_shadow {E : Type*} [NormedAddCommGroup E]
    (g : E → E) (x : ℕ → E) (L δ : ℝ) (N : ℕ)
    (hL0 : 0 ≤ L) (hδ0 : 0 ≤ δ)
    (hg : ∀ a b, ‖g a - g b‖ ≤ L * ‖a - b‖)
    (hp : IsPseudoOrbit (fun z => z + g z) x δ N) :
    ∀ n ≤ N,
      ‖x n - exactOrbit (fun z => z + g z) (x 0) n‖ ≤
        δ * ∑ k ∈ Finset.range n, (1 + L) ^ k := by
  convert finite_horizon_shadow_bound ( fun z => z + g z ) x ( 1 + L ) δ N _ _ _ _ using 1;
  · linarith;
  · exact hδ0;
  · convert ResNetLipschitz.resnet_block_lipschitz g L hL0 hg using 1;
  · exact hp

/-
The logistic map preserves the unit interval.
-/
lemma logistic_mem_unit {x : ℝ} (hx : x ∈ Set.Icc (0 : ℝ) 1) :
    logistic x ∈ Set.Icc (0 : ℝ) 1 := by
  constructor <;> nlinarith [ hx.1, hx.2, sq_nonneg ( x - 1 / 2 ), show logistic x = 4 * x * ( 1 - x ) by rfl ]

/-
On the invariant unit interval, the logistic map has Lipschitz constant four.
-/
lemma logistic_lipschitz_unit {x y : ℝ}
    (hx : x ∈ Set.Icc (0 : ℝ) 1) (hy : y ∈ Set.Icc (0 : ℝ) 1) :
    |logistic x - logistic y| ≤ 4 * |x - y| := by
  unfold logistic; rw [ abs_sub_le_iff ] ; constructor <;> cases abs_cases ( x - y ) <;> nlinarith [ hx.1, hx.2, hy.1, hy.2, mul_nonneg hx.1 hy.1, mul_le_mul_of_nonneg_left hy.2 hx.1, mul_le_mul_of_nonneg_right hx.2 hy.1 ] ;

/-
Every point of a logistic orbit starting in the unit interval remains there.
-/
lemma logistic_exactOrbit_mem_unit {x : ℝ} (hx : x ∈ Set.Icc (0 : ℝ) 1) (n : ℕ) :
    exactOrbit logistic x n ∈ Set.Icc (0 : ℝ) 1 := by
  induction n <;> simp_all +decide [ exactOrbit, logistic ];
  rename_i k hk;
  convert logistic_mem_unit hk using 1;
  erw [ Function.iterate_succ_apply' ] ; norm_num [ logistic ]

/-
Concrete finite-horizon certificate for the parameter-four logistic map.
-/
theorem logistic_finite_shadow
    (x : ℕ → ℝ) (δ : ℝ) (N : ℕ) (hδ0 : 0 ≤ δ)
    (hx : ∀ n ≤ N, x n ∈ Set.Icc (0 : ℝ) 1)
    (hp : IsPseudoOrbit logistic x δ N) :
    ∀ n ≤ N, |x n - exactOrbit logistic (x 0) n| ≤
      δ * ∑ k ∈ Finset.range n, (4 : ℝ) ^ k := by
  intro n hn
  induction' n with n ih;
  · norm_num [ exactOrbit ];
  · have h_step : |x (n + 1) - exactOrbit logistic (x 0) (n + 1)| ≤ δ + 4 * |x n - exactOrbit logistic (x 0) n| := by
      have h_step : |x (n + 1) - exactOrbit logistic (x 0) (n + 1)| ≤ |x (n + 1) - logistic (x n)| + |logistic (x n) - logistic (exactOrbit logistic (x 0) n)| := by
        rw [ exactOrbit_succ ];
        exact abs_sub_le _ _ _;
      refine le_trans h_step <| add_le_add ?_ ?_;
      · exact hp n ( Nat.lt_of_succ_le hn );
      · apply logistic_lipschitz_unit;
        · exact hx n ( Nat.le_of_succ_le hn );
        · exact logistic_exactOrbit_mem_unit ( hx 0 bot_le ) n;
    rw [ Finset.sum_range_succ ] ; nlinarith [ ih ( Nat.le_of_lt hn ), geom_sum_mul_neg ( 4 : ℝ ) n ] ;

/-
Closed-form version of the logistic error budget.
-/
theorem logistic_finite_shadow_closed
    (x : ℕ → ℝ) (δ : ℝ) (N : ℕ) (hδ0 : 0 ≤ δ)
    (hx : ∀ n ≤ N, x n ∈ Set.Icc (0 : ℝ) 1)
    (hp : IsPseudoOrbit logistic x δ N) :
    ∀ n ≤ N, |x n - exactOrbit logistic (x 0) n| ≤
      δ * ((4 : ℝ) ^ n - 1) / 3 := by
  intro n hn
  convert logistic_finite_shadow x δ N hδ0 hx hp n hn using 1
  rw [geom_sum_eq]
  · ring_nf
  · norm_num

/-
A local precision budget sufficient to guarantee a requested logistic-map
shadowing tolerance at every time up to the certified horizon.
-/
theorem logistic_precision_certificate
    (x : ℕ → ℝ) (δ ε : ℝ) (N : ℕ) (hδ0 : 0 ≤ δ)
    (hx : ∀ n ≤ N, x n ∈ Set.Icc (0 : ℝ) 1)
    (hp : IsPseudoOrbit logistic x δ N)
    (hbudget : δ * ((4 : ℝ) ^ N - 1) ≤ 3 * ε) :
    ∀ n ≤ N, |x n - exactOrbit logistic (x 0) n| ≤ ε := by
  intro n hn; nlinarith [ show ( 4 : ℝ ) ^ n ≤ 4 ^ N by exact pow_le_pow_right₀ ( by norm_num ) hn, logistic_finite_shadow_closed x δ N hδ0 hx hp n hn ] ;

end ChaosShadowing