import Mathlib

/-! # Jensen Inequality Bridge

Proves Jensen's inequality and convexity of exp:
1. Jensen's inequality for convex functions (MASTER inequality of analysis)
2. exp is convex (Jensen gives LSE ≥ max from tropical geometry)
3. exp is strictly convex

Jensen's inequality is the MASTER inequality: AM-GM, Cauchy-Schwarz,
and the power mean inequality are ALL consequences of Jensen.
-/

namespace JensenInequalityBridge

/-! ## Section 1: Jensen's Inequality -/

/-- **Jensen's Inequality** (convex version): For a convex function f on s,
    f(Σ wᵢxᵢ) ≤ Σ wᵢf(xᵢ) for any convex combination.
    This is the MASTER inequality of analysis. Every other classical
    inequality (AM-GM, Cauchy-Schwarz, Hölder, Minkowski) follows from it. -/
theorem jensen_convex {𝕜 E β ι : Type*} [Field 𝕜] [LinearOrder 𝕜] [IsStrictOrderedRing 𝕜]
    [AddCommGroup E] [AddCommGroup β] [PartialOrder β] [IsOrderedAddMonoid β]
    [Module 𝕜 E] [Module 𝕜 β] [IsStrictOrderedModule 𝕜 β]
    {s : Set E} {f : E → β} {t : Finset ι} {w : ι → 𝕜} {p : ι → E}
    (hf : ConvexOn 𝕜 s f) (hw : ∀ i ∈ t, 0 ≤ w i) (hsum : ∑ i ∈ t, w i = 1)
    (hp : ∀ i ∈ t, p i ∈ s) :
    f (∑ i ∈ t, w i • p i) ≤ ∑ i ∈ t, w i • f (p i) :=
  ConvexOn.map_sum_le hf hw hsum hp

/-! ## Section 2: Convexity of exp -/

/-- exp is convex on ℝ. This is the DIRECT reason that LSE ≥ max
    from tropical geometry: Jensen gives exp(convex combination) ≤
    convex combination of exps, which after taking log gives LSE ≥ max. -/
theorem exp_convex : ConvexOn ℝ Set.univ Real.exp :=
  convexOn_exp

/-- exp is strictly convex on ℝ.
    Strict convexity means Jensen's inequality is strict for
    distinct points with positive weights. -/
theorem exp_strict_convex : StrictConvexOn ℝ Set.univ Real.exp :=
  strictConvexOn_exp

end JensenInequalityBridge