# Future Directions: Stereographic Capacity Theory

## Conjecture 1: Second-Order Asymptotic Sharpness

**Conjecture:** For fixed dimension $n$, the stereographic distortion bound satisfies
$$\frac{N(n,r) \cdot \mathrm{capVol}(n,r)}{\mathrm{vol}(S^n)} = 1 + C_n r^2 + o(r^2) \quad \text{as } r \to 0$$
where $C_n = n(n+2)/12$ is the second-order coefficient arising from the Taylor expansion of the conformal factor over a cap of radius $r$.

**Test:** For $n = 2$, compute $Q_2(r_k)$ numerically using the closed-form bound $8/(\cos^2 r \cdot (1 - \cos r))$ for a sequence $r_k = \pi/(6k)$ with $k = 1, 2, \ldots, 100$. Fit the residual $(Q_2(r_k) - 1)/r_k^2$ and compare to the predicted $C_2 = 2/3$. Alternatively, compare against known spherical code databases (e.g., Neil Sloane's tables) for small $r$.

**Impact:** If true, this establishes that stereographic transport is asymptotically optimal up to second order, meaning no other conformal chart-based method can do better. This would make stereographic capacity theory the canonical approach for small-cap packing bounds on spheres.

---

## Conjecture 2: Dimension-2 Distortion Constant Improvement

**Conjecture:** The worst-case distortion factor $(2/\cos r)^2$ in the $S^2$ bound can be replaced by the average distortion over the cap image:
$$D_{\mathrm{avg}}(r) = \frac{1}{\mathrm{area}(\text{cap})} \int_{\text{cap}} \frac{1}{\lambda(x)^2} \, d\sigma < \left(\frac{2}{\cos r}\right)^2$$
yielding a strictly tighter bound for all $0 < r < \pi/2$.

**Test:** Compute $D_{\text{avg}}(r)$ numerically by integrating $(1 + \|x\|^2)^2/4$ over the stereographic image of a cap of radius $r$ centered at the south pole. Compare $D_{\text{avg}}(r)$ to $(2/\cos r)^2$ for $r \in \{0.1, 0.2, \ldots, 1.5\}$.

**Impact:** This would give the tightest known conformal-chart-based bound for $S^2$ packing. The improvement factor grows with $r$, potentially making the bound competitive with Rankin-type estimates for moderate angular separations.

---

## Conjecture 3: Weighted Planar Packing Equivalence

**Conjecture:** For every finite set $C \subset S^2$ with pairwise geodesic distance $\geq 2r$, the stereographic images $\{x_i\}$ satisfy the weighted disk packing condition: the disks $B(x_i, \rho(r, x_i))$ are pairwise disjoint, where $\rho(r, x) = \tan(r) / \lambda(x)$. Conversely, every such weighted disk packing in the plane lifts to a valid spherical cap packing.

**Test:** For the 12 vertices of the icosahedron projected stereographically, verify computationally that the weighted exclusion disks are disjoint with $r = \pi/6$. Then attempt to find 13 disks satisfying the weighted packing condition — failure confirms the bound.

**Impact:** This establishes a complete dictionary between spherical packing and weighted planar packing, opening the door to applying planar disk-packing algorithms (e.g., linear programming relaxations) to spherical code design.

---

## Conjecture 4: Coding-Theoretic Transfer Bound

**Conjecture:** For angular separations $\theta \in (\pi/3, 2\pi/3)$ on $S^2$, the stereographic bound $B_{\text{stereo}}(2, \theta/2)$ improves upon the naive volume (Gilbert-type) bound by a factor that is at most $(2/\cos(\theta/2))^2$ but at least $(4/3)$ for all $\theta$ in this range. In particular, for the "kissing number" problem ($\theta = \pi/3$ on $S^2$), the stereographic bound gives $N \leq 80$, which is within a factor of 7 of the true answer $N = 12$.

**Test:** Compare the stereographic bound against the Rankin bound $N \leq (n+1) \cdot 2^{n/2}$ and the Kabatiansky-Levenshtein bound for $n = 2, 3, 4$ across a range of angular separations. Identify the regime where stereographic transport outperforms or complements these classical estimates.

**Impact:** If the stereographic bound is competitive in certain angular regimes, it provides a computationally simpler alternative to LP-based bounds (Delsarte) that can be implemented with certified arithmetic — enabling verified spherical code capacity computations.

---

## Conjecture 5: Curvature-Generalization to Constant-Curvature Spaces

**Conjecture:** An analogous conformal packing bound exists for the hyperbolic disk $\mathbb{H}^n$ using the Poincaré disk model: the conformal factor $\lambda_{\mathbb{H}}(x) = 2/(1 - \|x\|^2)$ yields packing bounds of the form
$$N_{\mathbb{H}}(n, r) \leq D_{\mathbb{H}}(n, r) \cdot \frac{\mathrm{vol}(\text{domain})}{\mathrm{capVol}_{\mathbb{H}}(n, r)}$$
where $D_{\mathbb{H}}(n, r) = (2/\cosh r)^n$ for geodesic balls of radius $r$ in $\mathbb{H}^n$.

**Test:** Implement the hyperbolic version with the Poincaré disk conformal factor. Compute bounds for hyperbolic disk packings with $n = 2$ and compare against known hyperbolic circle packing densities. The bound should recover the classical fact that hyperbolic space admits packings of arbitrarily high density (as curvature increases).

**Impact:** Proving this conjecture would establish stereographic capacity as a general conformal-chart technique applicable to any constant-curvature space, unifying spherical, Euclidean, and hyperbolic packing theory under a single framework. This is the most ambitious direction and could lead to a new chapter in geometric analysis.
