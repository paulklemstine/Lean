/-! # CatalogBuild.Geometry.Stereographic.OmegaPoint

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 19
-/

import Mathlib

noncomputable section

/-- The x-coordinate of the inverse stereographic projection ℝ → S¹ -/
def invStereoX (t : ℝ) : ℝ := 2 * t / (t ^ 2 + 1)

/-- The y-coordinate of the inverse stereographic projection ℝ → S¹ -/

def invStereoY (t : ℝ) : ℝ := (t ^ 2 - 1) / (t ^ 2 + 1)

/-- The Omega Point: the north pole of S¹, the "point at infinity" -/

def omegaPoint : ℝ × ℝ := (0, 1)

/-- The inverse stereographic map as a pair -/

theorem denom_pos (t : ℝ) : 0 < t ^ 2 + 1 := by positivity

/-- The denominator t² + 1 is never zero -/

theorem denom_ne_zero (t : ℝ) : t ^ 2 + 1 ≠ 0 := ne_of_gt (denom_pos t)

/-- Every point on the inverse stereographic image lies on the unit circle -/

theorem omega_point_on_circle : omegaPoint.1 ^ 2 + omegaPoint.2 ^ 2 = 1 := by
  simp [omegaPoint]

/-! ### Convergence: The Omega Point Theorem -/

/-
PROBLEM
As t → +∞, the x-coordinate 2t/(t²+1) → 0

PROVIDED SOLUTION
Show invStereoX t = 2*t/(t^2+1) → 0 as t → +∞. Rewrite as 2/(t + 1/t) which → 0. Or use Tendsto.div: numerator 2*t grows linearly while denominator t^2+1 grows quadratically. Key approach: show invStereoX t = (2/t) / (1 + 1/t^2) for t ≠ 0, or use squeeze theorem with |invStereoX t| ≤ 2/|t| for large t (since t^2+1 ≥ t^2, so |2t/(t^2+1)| ≤ 2/|t|). Then 2/|t| → 0.
-/

theorem omega_x_tendsto_atTop :
    Tendsto invStereoX atTop (nhds 0) := by
  -- To prove the limit, we can use the fact that the denominator grows faster than the numerator.
  have h_lim : Filter.Tendsto (fun t : ℝ => 2 / (t + 1 / t)) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop ( Filter.tendsto_id.atTop_add <| tendsto_const_nhds.div_atTop Filter.tendsto_id );
  refine h_lim.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ show invStereoX t = 2 / ( t + 1 / t ) by rw [ invStereoX, div_eq_div_iff ] <;> ring <;> nlinarith [ inv_mul_cancel₀ ht.ne' ] ] )

/-
PROBLEM
As t → -∞, the x-coordinate 2t/(t²+1) → 0

PROVIDED SOLUTION
Same as atTop case but for t → -∞. invStereoX t = 2*t/(t^2+1) → 0. Use squeeze: |2t/(t^2+1)| ≤ 2/|t| → 0 as |t| → ∞. Or compose with neg: invStereoX(-t) = -invStereoX(t) since 2*(-t)/((-t)^2+1) = -2t/(t^2+1).
-/

theorem omega_x_tendsto_atBot :
    Tendsto invStereoX atBot (nhds 0) := by
  -- To prove the limit as $t \to -\infty$, we can use the fact that the limit of a function as $t \to -\infty$ is the same as the limit of the function as $t \to \infty$ with the sign reversed.
  have h_neg : Filter.Tendsto (fun t : ℝ => invStereoX (-t)) Filter.atTop (nhds 0) := by
    convert omega_x_tendsto_atTop.neg using 2 ; norm_num [ invStereoX ] ; ring;
    norm_num;
  convert h_neg.comp Filter.tendsto_neg_atBot_atTop using 2 ; aesop

/-
PROBLEM
As t → +∞, the y-coordinate (t²-1)/(t²+1) → 1

PROVIDED SOLUTION
Show invStereoY t = (t^2-1)/(t^2+1) → 1 as t → +∞. Note (t^2-1)/(t^2+1) = 1 - 2/(t^2+1). Since 2/(t^2+1) → 0 as t → ∞, we get the result. Use this decomposition: show invStereoY t = 1 - 2/(t^2+1), then use tendsto_const_nhds.sub with 2/(t^2+1) → 0.
-/

theorem omega_y_tendsto_atTop :
    Tendsto invStereoY atTop (nhds 1) := by
  -- We can decompose the function as $1 - \frac{2}{t^2 + 1}$.
  suffices h_decomp : Tendsto (fun t : ℝ => 1 - 2 / (t ^ 2 + 1)) atTop (nhds 1) by
    convert h_decomp using 2 ; rw [ invStereoY ] ; rw [ one_sub_div ( by positivity ) ] ; ring;
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ <| by norm_num ) <| by norm_num;

/-
PROBLEM
As t → -∞, the y-coordinate (t²-1)/(t²+1) → 1

PROVIDED SOLUTION
Same as atTop since invStereoY(-t) = invStereoY(t): the function is even. So compose with neg, or directly argue (t^2-1)/(t^2+1) = 1 - 2/(t^2+1) → 1 as t → -∞, since t^2 → ∞ either way.
-/

theorem omega_y_tendsto_atBot :
    Tendsto invStereoY atBot (nhds 1) := by
  rw [ Metric.tendsto_nhds ] at *;
  unfold invStereoY;
  exact fun ε hε => Filter.eventually_atBot.2 ⟨ -ε⁻¹ - 1, fun x hx => abs_lt.2 ⟨ by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne.symm, mul_div_cancel₀ ( x ^ 2 - 1 ) ( show x ^ 2 + 1 ≠ 0 by nlinarith ) ], by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne.symm, mul_div_cancel₀ ( x ^ 2 - 1 ) ( show x ^ 2 + 1 ≠ 0 by nlinarith ) ] ⟩ ⟩

/-- **The Omega Point Theorem (at +∞)**: The inverse stereographic projection
    converges to the north pole (0, 1) as t → +∞.
    The north pole is the Omega Point — the image of infinity. -/

theorem omega_point_is_north_pole_atTop :
    Tendsto invStereo atTop (nhds omegaPoint) := by
  rw [show omegaPoint = (0, 1) from rfl]
  exact Filter.Tendsto.prodMk_nhds omega_x_tendsto_atTop omega_y_tendsto_atTop

/-- **The Omega Point Theorem (at -∞)**: The inverse stereographic projection
    converges to the north pole (0, 1) as t → -∞. -/

theorem omega_point_is_north_pole_atBot :
    Tendsto invStereo atBot (nhds omegaPoint) := by
  rw [show omegaPoint = (0, 1) from rfl]
  exact Filter.Tendsto.prodMk_nhds omega_x_tendsto_atBot omega_y_tendsto_atBot

/-! ## Part 2: Abstract Omega Point via Mathlib's stereoInvFunAux

The Mathlib definition:
  `stereoInvFunAux v w = (‖w‖² + 4)⁻¹ • (4 • w + (‖w‖² - 4) • v)`

As ‖w‖ → ∞:
  - The `4 • w` term is damped by `(‖w‖² + 4)⁻¹`, contributing `O(1/‖w‖)` → 0
  - The `(‖w‖² - 4) • v` term with factor `(‖w‖² + 4)⁻¹` contributes `→ 1 • v`

Therefore `stereoInvFunAux v w → v`, establishing `v` as the Omega Point.
-/

/-
PROBLEM
**Abstract Omega Point Theorem**: In any inner product space, the inverse
    stereographic projection map converges to the north pole `v` as ‖w‖ → ∞.

    This is the abstract formulation: the north pole is the unique "point at infinity"
    in the one-point compactification, reachable only as a limit of divergent sequences.

PROVIDED SOLUTION
stereoInvFunAux v w = (‖w‖^2 + 4)⁻¹ • (4 • w + (‖w‖^2 - 4) • v). Rewrite as: ((‖w‖^2 - 4)/(‖w‖^2 + 4)) • v + (4/(‖w‖^2 + 4)) • w. We need to show this → v. Write it as v + ((‖w‖^2 - 4)/(‖w‖^2 + 4) - 1) • v + (4/(‖w‖^2 + 4)) • w = v + (-8/(‖w‖^2 + 4)) • v + (4/(‖w‖^2 + 4)) • w. Both error terms → 0: the first because 8/(‖w‖^2+4) → 0, the second because ‖(4/(‖w‖^2+4)) • w‖ = 4‖w‖/(‖w‖^2+4) ≤ 4/‖w‖ → 0 (using AM-GM: ‖w‖^2+4 ≥ 2·2·‖w‖). Key: use squeeze_zero or Tendsto for both terms, then combine. On cobounded, ‖w‖ → ∞.
-/

theorem stereoInvFunAux_tendsto_north_pole
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (v : E) (hv : ‖v‖ = 1) :
    Tendsto (stereoInvFunAux v) (Bornology.cobounded E) (nhds v) := by
  -- Let's simplify the expression for the difference.
  suffices h_simp : Filter.Tendsto (fun w : E => ((‖w‖^2 - 4) / (‖w‖^2 + 4)) • v + (4 / (‖w‖^2 + 4)) • w) (Bornology.cobounded E) (nhds v) by
    convert h_simp using 2 ; unfold stereoInvFunAux ; norm_num ; ring;
    norm_num [ add_comm, add_left_comm, add_assoc, mul_comm, smul_smul ] ; ring;
  -- We can split the limit into two parts and show each part tends to its respective limit.
  have h_split : Filter.Tendsto (fun w : E => ((‖w‖^2 - 4) / (‖w‖^2 + 4))) (Bornology.cobounded E) (nhds 1) ∧ Filter.Tendsto (fun w : E => (4 / (‖w‖^2 + 4)) • w) (Bornology.cobounded E) (nhds 0) := by
    constructor;
    · -- We can divide the numerator and the denominator by ‖w‖^2.
      have h_div : Filter.Tendsto (fun w : E => (1 - 4 / (‖w‖^2 : ℝ)) / (1 + 4 / (‖w‖^2 : ℝ))) (Bornology.cobounded E) (nhds 1) := by
        -- As ‖w‖ → ∞, the term $4 / (‖w‖^2)$ tends to $0$.
        have h_zero : Filter.Tendsto (fun w : E => 4 / (‖w‖^2 : ℝ)) (Bornology.cobounded E) (nhds 0) := by
          refine' tendsto_const_nhds.div_atTop _;
          exact Filter.tendsto_pow_atTop ( by norm_num ) |> Filter.Tendsto.comp <| tendsto_norm_cobounded_atTop;
        convert Filter.Tendsto.div ( tendsto_const_nhds.sub h_zero ) ( tendsto_const_nhds.add h_zero ) _ using 2 <;> norm_num;
      refine h_div.congr' ?_;
      filter_upwards [ Bornology.eventually_ne_cobounded 0 ] with w hw using by rw [ one_sub_div ( by positivity ), one_add_div ( by positivity ) ] ; rw [ div_div_div_cancel_right₀ ( by positivity ) ] ;
    · have h_second_term : Filter.Tendsto (fun w : E => (4 / (‖w‖^2 + 4)) * ‖w‖) (Bornology.cobounded E) (nhds 0) := by
        -- We can simplify the expression inside the limit further by dividing the numerator and the denominator by ‖w‖.
        suffices h_simplify' : Filter.Tendsto (fun w : E => 4 / (‖w‖ + 4 / ‖w‖)) (Bornology.cobounded E) (nhds 0) by
          grind;
        refine' tendsto_const_nhds.div_atTop _;
        exact Filter.tendsto_atTop_mono ( fun w => le_add_of_nonneg_right <| div_nonneg zero_le_four <| norm_nonneg _ ) ( tendsto_norm_cobounded_atTop );
      exact tendsto_zero_iff_norm_tendsto_zero.mpr ( by simpa [ norm_smul, abs_of_nonneg ( by positivity : 0 ≤ ( ‖_‖^2 + 4 : ℝ ) ⁻¹ * 4 ) ] using h_second_term.norm );
  simpa using Filter.Tendsto.add ( h_split.1.smul_const v ) h_split.2

/-! ## Part 3: Topological Characterization

The one-point compactification provides the proper framework:
- `OnePoint ℝ` is `ℝ ∪ {∞}`, homeomorphic to S¹
- The point `∞ : OnePoint ℝ` corresponds to the north pole
- The embedding `ℝ ↪ OnePoint ℝ` corresponds to the stereographic chart

This formalizes the oracle hierarchy analogy:
- Each `n : ℝ` represents a "finite oracle" (an oracle at level n)
- The point `∞` represents the Omega Oracle — unreachable from within but
  a well-defined topological limit
-/

/-- The Omega Point in the one-point compactification is the point at infinity -/

def omegaPointOnePoint : OnePoint ℝ := OnePoint.infty

/-- Every finite point embeds into the one-point compactification -/

def finiteOracle (n : ℝ) : OnePoint ℝ := .some n

/-- The Omega Point is NOT a finite oracle -/

theorem omega_not_finite : ∀ n : ℝ, omegaPointOnePoint ≠ finiteOracle n := by
  intro n; exact nofun

/-! ## Part 4: Oracle Hierarchy Interpretation

The arithmetic hierarchy of oracles (∅, ∅', ∅'', ...) maps naturally to
integers 0, 1, 2, ... on the real line. The inverse stereographic projection
maps this "flat" hierarchy onto the sphere, where:

- Oracle level n ↦ a point on S¹ approaching the north pole
- The Omega Oracle ↦ the north pole itself (by the Omega Point Theorem)

This gives a geometric interpretation of Tarski's indefinability theorem:
the Omega Oracle is "visible" (as the north pole) but not "reachable"
from within the arithmetic hierarchy (the stereographic chart never hits the pole).
-/

/-- Oracle level n maps to a point on S¹ via inverse stereographic projection.
    As n → ∞, these points converge to the Omega Point (north pole). -/

def oracleOnSphere (n : ℕ) : ℝ × ℝ := invStereo (n : ℝ)

/-- Each oracle level maps to the unit circle -/

theorem oracle_on_circle (n : ℕ) :
    (oracleOnSphere n).1 ^ 2 + (oracleOnSphere n).2 ^ 2 = 1 := by
  exact inv_stereo_on_circle (n : ℝ)

/-- The oracle hierarchy converges to the Omega Point on the sphere -/

theorem oracle_hierarchy_converges_to_omega :
    Tendsto (fun n : ℕ => invStereo (n : ℝ)) atTop (nhds omegaPoint) :=
  omega_point_is_north_pole_atTop.comp tendsto_natCast_atTop_atTop


end
