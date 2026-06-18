# Future Directions: Stereographic Persistence Theory

## Conjecture 1: Hemisphere Acceleration Hypothesis

**Precise statement:** For a finite point cloud $X$ sampled uniformly from a spherical cap of angular radius $\rho < \pi/3$ on $S^n$, the bottleneck distance between the persistence diagram of the intrinsic spherical Rips filtration and the persistence diagram of the ordinary Euclidean Rips filtration on the stereographic projection $\sigma(X)$ (with standard Euclidean metric, after rescaling by $2/(R^2+4)$ where $R = \tan(\rho/2)$) is bounded by $O(\rho^3)$ as $\rho \to 0$.

**Test:** Sample $N = 200$ points uniformly from spherical caps of angular radii $\rho \in \{0.1, 0.2, 0.3, 0.5, 0.8, 1.0\}$ on $S^2$. Compute both persistence diagrams (spherical geodesic Rips vs rescaled Euclidean Rips on stereographic coordinates). Measure bottleneck distance. Plot $d_B / \rho^3$ as a function of $\rho$. If the hypothesis holds, this ratio should remain bounded as $\rho \to 0$.

**Disproof protocol:** If the ratio $d_B / \rho^3$ diverges for small $\rho$, the hypothesis is false. Check whether $d_B / \rho^2$ remains bounded instead (suggesting a quadratic rather than cubic bound).

**Impact:** If true, this provides a practical error guarantee for using standard Euclidean persistence software on spherical data confined to small caps, with explicit error bounds. This would immediately benefit directional statistics and astrophysical applications.

---

## Conjecture 2: North-Pole Instability Threshold

**Precise statement:** Let $X_t$ be a family of point clouds on $S^n \setminus \{N\}$ where one point approaches the north pole at angular distance $\delta_t \to 0$. The condition number of the weighted distance matrix $D_{ij} = d_{\mathrm{st}}(\sigma(x_i), \sigma(x_j))$ grows as $\Theta(1/\delta_t^2)$, and the Lipschitz constant of the persistence diagram (as a function of point positions) grows as $\Theta(1/\delta_t)$.

**Test:** Fix $N = 50$ points on $S^2$ in a generic position. Move one point along a geodesic toward the north pole, with angular distances $\delta \in \{0.5, 0.2, 0.1, 0.05, 0.02, 0.01\}$. Compute the condition number of the weighted distance matrix and the local Lipschitz constant of the persistence diagram (by numerical differentiation). Plot both quantities against $1/\delta$ on log-log axes. If the hypothesis holds, the slopes should be approximately 2 and 1 respectively.

**Disproof protocol:** If growth rates differ from the predicted powers, measure the actual exponents by regression. The hypothesis is false if either exponent differs significantly from the prediction.

**Impact:** This would quantify exactly how close to the stereographic singularity one can work before numerical instability corrupts the persistence computation. It would guide practitioners in choosing chart centers for data near poles.

---

## Conjecture 3: Chartwise Manifold Persistence via Atlas Patching

**Precise statement:** For a compact Riemannian manifold $M$ admitting a finite conformal atlas $\{(U_\alpha, \phi_\alpha)\}_{\alpha=1}^k$ with overlap distortion bounded by $\kappa$, the persistence diagram obtained by patching chartwise weighted filtrations (using the exact transported metric in each chart) is interleaved with the intrinsic geodesic persistence diagram with multiplicative constant at most $1 + C\kappa$ for an explicit universal constant $C$.

**Test:** Use $S^2$ with two stereographic charts (from north and south poles). Sample $N = 100$ points distributed across the sphere. Assign each point to the chart whose pole is farther away. Compute: (a) intrinsic geodesic persistence, (b) single-chart weighted persistence (choosing the better pole), (c) patched two-chart persistence using a partition of unity. Compare interleaving distances.

**Disproof protocol:** If the patched persistence has interleaving constant growing faster than linearly in the overlap distortion $\kappa$, the hypothesis is false with the stated bound. Check whether a polynomial bound $1 + C\kappa^p$ holds for some $p > 1$.

**Impact:** If true, this generalizes stereographic persistence to arbitrary manifolds, opening the door to persistence computations on hyperbolic manifolds, projective spaces, Grassmannians, and Lie groups — all via chartwise Euclidean computations with metric corrections.

---

## Conjecture 4: Conformal TDA Invariance for Möbius Transformations

**Precise statement:** Let $T : S^n \to S^n$ be a Möbius transformation (conformal diffeomorphism). Then the stereographic persistence diagrams of $X$ and $T(X)$ are identical, i.e., $\mathrm{PH}_*(\check{C}^{d_{\mathrm{st}}}_\bullet(\sigma(X))) \cong \mathrm{PH}_*(\check{C}^{d_{\mathrm{st}}}_\bullet(\sigma(T(X))))$.

**Test:** Generate random point clouds on $S^2$. Apply random Möbius transformations (generated as compositions of inversions). Compare persistence diagrams before and after. Since Möbius transformations preserve geodesic circles (though not geodesic distances), the persistence diagrams should be invariant when using the exact transported metric.

**Disproof protocol:** Compute persistence diagrams for $X$ and $T(X)$ for multiple Möbius transformations. If any bottleneck distance is nonzero (beyond numerical tolerance), the conjecture is false. Note: this should follow from the fact that $d_{\mathrm{st}}$ recovers the intrinsic spherical metric exactly, so it reduces to the question of whether Möbius transformations preserve geodesic distances — which they do NOT in general (they preserve angles, not distances). Therefore this conjecture is likely **false** except for isometries.

**Impact:** Clarifying the boundary between Möbius invariance and isometric invariance in persistence would sharpen the theoretical foundations of conformal TDA.

---

## Conjecture 5: Protein Orientation Separation via Weighted Stereographic Persistence

**Precise statement:** For molecular orientation data on $S^2$ (e.g., bond angles, dihedral angle distributions), weighted stereographic persistence separates conformational classes (e.g., alpha-helix vs beta-sheet orientational signatures) with higher classification accuracy than either (a) naive Euclidean persistence on stereographic coordinates, or (b) persistence computed using chordal distance in the ambient $\mathbb{R}^3$.

**Test:** Generate synthetic orientation distributions on $S^2$ mimicking two conformational classes: (A) points clustered near a great circle (modeling alpha-helix backbone angles), (B) points clustered near two antipodal caps (modeling beta-sheet angles). For each distribution, compute: (i) spherical geodesic Rips persistence, (ii) weighted stereographic persistence, (iii) naive Euclidean persistence on projections, (iv) chordal distance persistence. Use persistent entropy or total persistence as features. Measure classification accuracy (leave-one-out cross-validation) for each method across 100 trials of $N = 50$ points.

**Disproof protocol:** If naive Euclidean persistence achieves equal or higher accuracy, or if the geodesic persistence does not match the weighted stereographic persistence (as predicted by our theorem), something is wrong with either the implementation or the theorem application. Detailed error analysis should reveal which.

**Impact:** Validates that the exact metric transport theorem has practical consequences in structural biology. Could lead to certified topological tools for protein structure classification.
