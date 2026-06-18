# Future Directions: Metric Filtrations and the Poincaré Threshold

## 1. Connectivity Threshold Scaling Law

The **connectivity threshold** ε*(X) of a finite point cloud X ⊂ ℝᵈ is the infimum of ε such that the Rips graph at scale ε is connected (i.e., has exactly one connected component). For n points sampled uniformly on the unit d-sphere Sᵈ, we conjecture:

> **Conjecture**: ε*(X) ~ C · d^{1/2} · n^{-1/d} as n → ∞, where C depends only on d.

The key insight is that the connectivity threshold is controlled by the maximum nearest-neighbor distance, which for uniform samples on Sᵈ scales as n^{-1/d} by volumetric arguments — the surface area of a geodesic cap of radius ε on Sᵈ scales as εᵈ.

**Why now?** Our `MetricFiltration` structure and `ripsGraph_mono` theorem provide the algebraic foundation. The `coveringNumber_antitone` result shows the covering number's monotonicity, which is the dual of the connectivity threshold. The next step is to formalize the probabilistic bound using measure-theoretic arguments about uniform distributions on Sᵈ, which Mathlib's measure theory library now supports.

**Computational test**: Sample n = 100, 1000, 10000 points on S¹, S², S³ and compute ε* by binary search on the Rips graph connectivity. Plot log(ε*) vs log(n) — the slope should be -1/d.

## 2. Persistent Betti Numbers via Chain Complexes

Our current formalization captures the π₀ (connected components) level of the Vietoris-Rips filtration via SimpleGraph. The full persistent homology requires chain complexes over the Rips simplicial complex.

> **Conjecture**: For X uniformly sampled from Sᵈ with n sufficiently large, the Rips complex VR_ε(X) has β₀ = 1, β₁ = β₂ = ... = β_{d-1} = 0, β_d = 1 for ε in an interval [ε_low, ε_high] whose width grows as n^{1/(d+1)}.

The key insight is that the "persistence" (length of the interval where the homology matches Sᵈ) is a quantitative measure of how well the point cloud approximates the sphere, and its scaling law encodes the dimension.

**Why now?** Mathlib has basic homological algebra (chain complexes, homology functors). Our `AbstractSimplicialComplex` in `SimplicialComplex.lean` provides the combinatorial input. The gap is formalizing the boundary operator and proving that the Rips complex of a dense enough sample has the same homology as the underlying manifold (the Nerve Lemma / Niyogi-Smale-Weinberger theorem).

**Computational test**: Compute the full persistent homology barcode of 1000 points on S² using standard TDA software. The longest bar in H₂ should appear at scale ≈ C · n^{-1/2}.

## 3. Packing-Covering Duality and Metric Entropy

Our `maximal_packing_is_cover` theorem establishes the fundamental duality between packings and coverings. This should extend to a full metric entropy theory.

> **Conjecture**: For a compact Riemannian manifold M of dimension d and volume V, the covering number satisfies N(M, ε) = V · ωd⁻¹ · ε⁻ᵈ · (1 + O(ε · κ)) where ωd is the volume of the d-ball and κ is related to the Ricci curvature.

The key insight is that the O(ε · κ) correction term encodes curvature information — the covering number is not just a volumetric invariant but a geometric one. Formally, the packing number P(M, ε) satisfies P(M, 2ε) ≤ N(M, ε) ≤ P(M, ε), and both are asymptotic to V/ωd · ε⁻ᵈ.

**Why now?** Our `IsEpsilonPacking`, `IsEpsilonCover`, and `coveringNumber` definitions provide the discrete framework. The next step is connecting to Mathlib's `MeasureTheory.Measure.lebesgue` for volumetric arguments and proving the packing-covering sandwich inequality (which our duality theorem is the first step toward).

**Computational test**: Compute N(S², ε) for ε = 0.1, 0.01, 0.001 by greedy covering. Compare to the predicted 4π/πε² = 4/ε². The ratio should converge to 1.

## 4. Stability of the Poincaré Threshold Under Noise

Our `sphere_perturbation_stability` theorem shows that LiesOnSphere is robust to perturbation. This should extend to stability of the Poincaré threshold itself.

> **Conjecture**: If X lies on Sᵈ and Y is a δ-perturbation of X (each Y_i within δ of X_i), then |ε*(Y) - ε*(X)| ≤ 2δ, where ε* is the connectivity threshold.

The key insight is that a δ-perturbation can change any pairwise distance by at most 2δ (by triangle inequality), so edges in the Rips graph at scale ε for X correspond to edges at scale ε + 2δ for Y and vice versa. This gives a Lipschitz bound on the connectivity threshold.

**Why now?** Our `ripsGraph_mono` and `sphere_perturbation_stability` provide the ingredients. The proof would use: if VR_ε(X) is connected, then VR_{ε+2δ}(Y) is connected (since every edge at scale ε in X gives an edge at scale ε + 2δ in Y), yielding ε*(Y) ≤ ε*(X) + 2δ and symmetrically.

**Computational test**: Take 1000 points on S², add Gaussian noise with σ = 0.01, 0.1, 0.5. Measure ε*(noisy) - ε*(clean). The difference should be ≤ 2 · max perturbation.

## 5. The Filtration as a Functor

Our `MetricFiltration` and `GeneralizedFiltration` structures beg for a categorical treatment.

> **Conjecture**: The assignment X ↦ MetricFiltration.rips(X) extends to a functor from the category of finite pseudometric spaces (with short maps) to the category of filtrations (with filtration-preserving graph morphisms), and this functor preserves finite limits.

The key insight is that a short map f : X → Y (with dist(f(x), f(y)) ≤ dist(x,y)) sends edges of VR_ε(X) to edges of VR_ε(Y), giving a natural transformation between the filtrations. Functoriality would make the Poincaré threshold a metric invariant in a precise categorical sense.

**Why now?** Mathlib's category theory library is mature enough to formalize this. Our `GeneralizedFiltration` provides the target category's objects. The key missing piece is defining morphisms of filtrations (natural transformations between the monotone families) and showing the Rips construction respects composition of short maps.

**Computational test**: Not directly computational, but one could verify that isometric embeddings of S¹ → S² induce filtration morphisms that preserve the connectivity threshold, by computing ε* for both the embedded and ambient point clouds.
