# Future Directions: Stereographic Capacity Theory

## 1. Higher-dimensional packing bounds via n-dimensional conformal distortion

The conformal distortion theorem `conformal_distortion_ge_one` establishes that (1/cos r)^n ≥ 1 for all dimensions n. The natural next step is proving the full n-dimensional packing bound: for the n-sphere S^n, the number of non-overlapping caps of geodesic radius r satisfies N(n,r) ≤ C(n) / (cos^n(r) · V_n(r)/V_n), where V_n(r) is the n-dimensional cap volume and C(n) is an explicit constant depending only on dimension.

The key insight is that the stereographic conformal factor in n dimensions is λ(x) = 2/(1+‖x‖²), which is dimension-independent, but the volume distortion scales as λ^n, making the dimension appear only in the exponent. This means the 1-dimensional analysis of `stereoConformalFactor` carries all the analytic content; the generalization is purely about integrating λ^n over higher-dimensional caps.

Why now? The `stereoConformalFactor_ge_on_cap` theorem already proves the pointwise bound λ(x) ≥ 2cos²(r) on stereographic images of caps. Extending to n dimensions requires formalizing the n-dimensional volume element dV_n = λ^n · dV_Eucl and integrating, which is accessible given Mathlib's measure theory infrastructure.

## 2. Tightness analysis: AM-GM optimization of the packing bound

Our `sphere_packing_bound_ge_four` proves that 2/(cos²(r)·(1-cos r)) ≥ 4 for r ∈ (0, π/2). A deeper question is: for which r is this bound tight? The function f(c) = c²(1-c) for c = cos r achieves its maximum 4/27 at c = 2/3 (i.e., r = arccos(2/3)), giving a minimum packing bound of 27/2 = 13.5. For the icosahedral packing (r = π/6, N = 12), our bound gives ≈ 12.31, which is remarkably tight.

The key insight is that the function c²(1-c) is a cubic with a unique maximum on (0,1), and its value at the maximum determines the loosest the bound can be. Proving that the bound is within a factor of (1 + O(r²)) of optimal for small r would connect to asymptotic sphere packing theory.

Why now? The AM-GM bound c²(1-c) ≤ 4/27 is a clean algebraic inequality that should be provable with `polyrith` or `nlinarith`, and the tightness analysis for specific packings (icosahedral, cuboctahedral, tetrahedral) provides concrete test cases.

## 3. Connection to spherical codes and kissing numbers

The packing bound N(2,r) ≤ 2/(cos²(r)·(1-cos r)) at r = π/6 gives N ≤ 12.31, which is consistent with the known kissing number in 3 dimensions (k₃ = 12). This is not a coincidence: spherical caps of geodesic radius π/6 on S² correspond exactly to the contact regions of unit spheres in a kissing configuration in R³.

The key insight is that the stereographic packing framework unifies two classically separate problems — sphere packing on spheres and kissing numbers in Euclidean space — through the conformal factor. A cap of radius r on S^(n-1) corresponds to a contact region for spheres at angular distance 2r, so our bounds directly give kissing number bounds.

Why now? The formalized conformal factor analysis and volume ratio computations provide the missing link. Formalizing the correspondence between S^(n-1) cap packing and R^n kissing numbers would yield the first machine-verified kissing number bounds.

## 4. Weighted packing and non-uniform cap distributions

The `packing_card_le` theorem assumes all caps have the same minimum measure v. In practice, stereographic projection maps caps at different positions to regions with different conformal distortion. Caps near the north pole (stereographic projection singularity) have high distortion, while caps near the south pole have low distortion.

The key insight is that a weighted packing bound, where each cap i contributes weight w_i = λ(x_i)^n to the packing inequality, gives a tighter bound than the uniform one. The optimal packing on S^n should concentrate caps where the conformal factor is closest to its average value, which for stereographic projection means near the equator.

Why now? The `stereoConformalFactor_strictAntiOn` theorem already establishes that the conformal factor varies monotonically with distance from the origin. Extending `packing_card_le` to a weighted version (∑ w_i ≤ W) is a natural generalization that would capture position-dependent distortion effects.

## 5. Möbius-invariant packing bounds

Stereographic projection is a special case of a Möbius transformation. The full Möbius group acts conformally on S^n, and packing bounds should be invariant under this group. Our current bound uses a specific stereographic projection (from the north pole), which breaks Möbius invariance by choosing a preferred point.

The key insight is that optimizing over all Möbius transformations (equivalently, over all choices of projection center) should yield the tightest possible conformal packing bound. The optimal center minimizes the maximum conformal distortion over all caps in the packing, which is a minimax problem on the Möbius group.

Why now? The conformal factor analysis in `stereoConformalFactor_ge_on_cap` already bounds distortion for one projection center. Formalizing the Möbius group action on S^n and proving that the optimal projection center exists (by compactness of the Möbius group modulo isometries) would complete the invariant theory.
