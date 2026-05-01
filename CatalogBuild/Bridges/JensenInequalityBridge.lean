/-! # CatalogBuild.Bridges.JensenInequalityBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 1
-/

import Mathlib

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

