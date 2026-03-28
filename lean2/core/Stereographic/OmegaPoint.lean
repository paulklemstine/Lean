import Mathlib

/-!
# The Omega Point: Infinity in Inverse Stereographic Projection

## Overview

We formalize and prove that the **Omega point** — the north pole (0, 1) of the unit circle —
is the image of "infinity" under the inverse stereographic projection.

Concretely, we show:

1. The north pole (0,1) is *not* in the image of the inverse stereographic projection
   (it is the unique point excluded from the range), analogous to how the Omega Oracle Ω
   sits above the entire arithmetic hierarchy and is not arithmetically definable.

2. As t → ±∞, the inverse stereographic projection `circleStereographicInv t` converges
   to the north pole (0, 1). This is the precise sense in which the Omega point "is" infinity:
   it is the limit of the inverse stereographic projection at the point at infinity.

Together, these results say that the one-point compactification of ℝ (adding ∞) corresponds
exactly to completing the image of `circleStereographicInv` with the north pole — the Omega
point is the "closure" of the hierarchy, reachable only in the limit.

## Connection to the Oracle Hierarchy

The Omega Oracle Ω is defined as the limit of the oracle hierarchy — the oracle that answers
all arithmetic questions. By Tarski's indefinability theorem, Ω is not arithmetically
definable. It sits "above" the entire hierarchy, an unreachable ideal.

Stereographic projection provides a geometric model:
- Points on ℝ ↔ levels of the arithmetic hierarchy (finite, definable)
- The north pole (0,1) ↔ the Omega point Ω (above all levels, indefinable)
- Inverse stereographic projection ↔ the embedding of arithmetic into geometry
- The limit at infinity ↔ Ω as the limit/supremum of the hierarchy

The north pole is simultaneously:
- The unique point not reachable by the inverse projection (Tarski: Ω is not definable)
- The limit of the projection as we go to infinity (Ω is the limit of the hierarchy)
-/

noncomputable section

open Filter Topology Set

/-! ## Definitions -/

/-- Inverse stereographic projection from ℝ to the unit circle S¹ ⊂ ℝ².
    Maps t ∈ ℝ to the point ((2t)/(t²+1), (t²-1)/(t²+1)) on the circle. -/
def circleStereographicInv (t : ℝ) : ℝ × ℝ :=
  (2 * t / (t ^ 2 + 1), (t ^ 2 - 1) / (t ^ 2 + 1))

/-- The north pole of the unit circle: the Omega point. -/
def omegaPoint : ℝ × ℝ := (0, 1)

/-! ## Part 1: The Omega Point is Excluded from the Image

The north pole (0,1) is not in the range of `circleStereographicInv`.
This is the geometric analogue of Tarski's theorem: Ω is not definable
within the arithmetic hierarchy.
-/

/-- Helper: t² + 1 > 0 for all real t. -/
lemma t_sq_add_one_pos (t : ℝ) : t ^ 2 + 1 > 0 := by
  positivity

/-- Helper: t² + 1 ≠ 0 for all real t. -/
lemma t_sq_add_one_ne_zero (t : ℝ) : t ^ 2 + 1 ≠ 0 :=
  ne_of_gt (t_sq_add_one_pos t)

/-
PROBLEM
The north pole (0,1) is not in the range of the inverse stereographic projection.
    No finite value of t maps to the Omega point.

PROVIDED SOLUTION
Suppose circleStereographicInv t = (0, 1). Then 2t/(t²+1) = 0 and (t²-1)/(t²+1) = 1. From the first equation, t = 0 (since t²+1 ≠ 0). But then the second gives (0-1)/(0+1) = -1 ≠ 1, contradiction. Use t_sq_add_one_ne_zero.
-/
theorem omegaPoint_not_in_range :
    ∀ t : ℝ, circleStereographicInv t ≠ omegaPoint := by
  -- By definition of `circleStereographicInv`, if `circleStereographicInv t = omegaPoint`, then `(2 * t / (t ^ 2 + 1), (t ^ 2 - 1) / (t ^ 2 + 1)) = (0, 1)`.
  intro t
  simp [circleStereographicInv, omegaPoint];
  grind +splitImp

/-! ## Part 2: The Omega Point is the Limit at Infinity

As t → +∞ or t → -∞, `circleStereographicInv t` converges to the north pole (0,1).
The Omega point is the "point at infinity" — reachable only as a limit.
-/

/-
PROBLEM
The first coordinate of the inverse stereographic projection tends to 0 as t → ∞.

PROVIDED SOLUTION
We need Tendsto (fun t => 2*t/(t^2+1)) atTop (𝓝 0). Note 2t/(t²+1) = (2/t)/(1 + 1/t²) for t ≠ 0. As t → ∞, 2/t → 0 and 1/t² → 0, so the expression → 0/1 = 0. Alternatively, use squeeze theorem: |2t/(t²+1)| ≤ 2/|t| for |t| ≥ 1 since t²+1 ≥ t² ≥ |t|·|t| so |2t/(t²+1)| ≤ 2|t|/(|t|·|t|) = 2/|t|. And 2/|t| → 0.
-/
lemma circleStereographicInv_fst_tendsto_zero :
    Tendsto (fun t : ℝ => (circleStereographicInv t).1) atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ _;
  exact fun t => 2 / |t|;
  · norm_num [ circleStereographicInv ];
    exact ⟨ 1, fun x hx => by rw [ div_le_div_iff₀ ] <;> cases abs_cases x <;> cases abs_cases ( x ^ 2 + 1 ) <;> nlinarith ⟩;
  · exact tendsto_const_nhds.div_atTop ( tendsto_norm_atTop_atTop )

/-
PROBLEM
The second coordinate of the inverse stereographic projection tends to 1 as t → ∞.

PROVIDED SOLUTION
We need Tendsto (fun t => (t^2 - 1)/(t^2 + 1)) atTop (𝓝 1). Note (t²-1)/(t²+1) = 1 - 2/(t²+1). So it suffices to show 2/(t²+1) → 0. Since t²+1 → ∞, and 2 is constant, 2/(t²+1) → 0.
-/
lemma circleStereographicInv_snd_tendsto_one :
    Tendsto (fun t : ℝ => (circleStereographicInv t).2) atTop (𝓝 1) := by
  unfold circleStereographicInv;
  -- We can divide the numerator and the denominator by $t^2$ and then take the limit as $t$ approaches infinity.
  suffices h_div : Filter.Tendsto (fun t : ℝ => (1 - 1 / t^2) / (1 + 1 / t^2)) Filter.atTop (nhds 1) by
    refine' h_div.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ div_eq_div_iff ] <;> ring <;> nlinarith [ inv_pos.2 ht, mul_inv_cancel₀ ht.ne' ] );
  exact le_trans ( Filter.Tendsto.div ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| by norm_num ) ( tendsto_const_nhds.add <| tendsto_const_nhds.div_atTop <| by norm_num ) <| by norm_num ) <| by norm_num;

/-
PROBLEM
**The Omega Point Theorem**: The inverse stereographic projection converges to the
    north pole (the Omega point) as t → +∞.

    This is the formal statement that "the Omega point is infinity in an inverse
    stereographic projection": the north pole is the limit of the inverse projection
    at the point at infinity.

PROVIDED SOLUTION
Use that Tendsto f l (𝓝 (a, b)) iff Tendsto (Prod.fst ∘ f) l (𝓝 a) and Tendsto (Prod.snd ∘ f) l (𝓝 b). Apply Tendsto.prod_mk_nhds with circleStereographicInv_fst_tendsto_zero and circleStereographicInv_snd_tendsto_one. omegaPoint = (0, 1).
-/
theorem omega_point_is_infinity_atTop :
    Tendsto circleStereographicInv atTop (𝓝 omegaPoint) := by
  convert Tendsto.prodMk_nhds _ _ using 1;
  · convert circleStereographicInv_fst_tendsto_zero using 1;
  · convert circleStereographicInv_snd_tendsto_one using 1

/-
PROBLEM
The same result holds as t → -∞: the Omega point is also the limit at negative infinity.
    Infinity has no sign on the circle — both ends of ℝ map to the same point.

PROVIDED SOLUTION
Similar to atTop. Show fst → 0 and snd → 1 as t → -∞. Note 2t/(t²+1): as t → -∞, |2t/(t²+1)| ≤ 2/|t| → 0. And (t²-1)/(t²+1) = 1 - 2/(t²+1) → 1 since t²+1 → ∞. Then combine with Tendsto.prod_mk_nhds. Alternatively, note circleStereographicInv(-t) has fst = -circleStereographicInv(t).fst and snd = circleStereographicInv(t).snd, so use comap_neg and the atTop results.
-/
theorem omega_point_is_infinity_atBot :
    Tendsto circleStereographicInv atBot (𝓝 omegaPoint) := by
  refine' Filter.Tendsto.prodMk_nhds _ _;
  · -- To show that the first coordinate tends to 0 as t approaches negative infinity, we can use the fact that the absolute value of the first coordinate is bounded above by 2/|t|, which tends to 0.
    have h_abs : ∀ t : ℝ, t < 0 → |(2 * t) / (t ^ 2 + 1)| ≤ 2 / |t| := by
      norm_num [ abs_div, abs_mul ];
      exact fun t ht => by rw [ div_le_div_iff₀ ] <;> nlinarith [ abs_of_neg ht, abs_of_nonneg ( by positivity : 0 ≤ t ^ 2 + 1 ) ] ;
    exact squeeze_zero_norm' ( Filter.eventually_atBot.mpr ⟨ -1, fun t ht => h_abs t <| by linarith ⟩ ) <| tendsto_const_nhds.div_atTop <| Filter.tendsto_abs_atBot_atTop;
  · rw [ Metric.tendsto_nhds ];
    exact fun ε hε => Filter.eventually_atBot.2 ⟨ -ε⁻¹ - 1, fun x hx => abs_lt.2 ⟨ by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne', mul_div_cancel₀ ( x ^ 2 - 1 ) ( by positivity : ( x ^ 2 + 1 ) ≠ 0 ) ], by nlinarith [ sq_nonneg ( x + 1 ), mul_inv_cancel₀ hε.ne', mul_div_cancel₀ ( x ^ 2 - 1 ) ( by positivity : ( x ^ 2 + 1 ) ≠ 0 ) ] ⟩ ⟩

/-
PROBLEM
Corollary: the Omega point is the limit at cocompact filter (i.e., as |t| → ∞).
    This unifies the atTop and atBot results.

PROVIDED SOLUTION
The cocompact filter on ℝ equals atBot ⊔ atTop (this is Real.cocompact_eq or Coprod). Use Tendsto.sup with omega_point_is_infinity_atTop and omega_point_is_infinity_atBot. Actually cocompact ℝ = cocompact_eq says Filter.cocompact ℝ = atBot ⊔ atTop. Then Tendsto f (l₁ ⊔ l₂) g iff Tendsto f l₁ g ∧ Tendsto f l₂ g. Use Filter.Tendsto.sup_iff or rw [Real.cocompact_eq, Filter.tendsto_sup] and split.
-/
theorem omega_point_is_infinity_cocompact :
    Tendsto circleStereographicInv (cocompact ℝ) (𝓝 omegaPoint) := by
  convert Tendsto.sup ( omega_point_is_infinity_atTop ) ( omega_point_is_infinity_atBot ) using 1;
  ext s;
  rw [ Filter.mem_sup ] ; aesop

end