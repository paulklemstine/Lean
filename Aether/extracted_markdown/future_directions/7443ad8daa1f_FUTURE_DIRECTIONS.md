# Future Directions: Tropical Celestial Mechanics

## Synthesis

The tropical-celestial bridge established in this work opens five interconnected research directions, ranging from direct extensions of proven theorems to paradigm-shifting conjectures. The central theme is that **tropical geometry provides a combinatorial skeleton for continuous dynamical systems**, and this skeleton captures more structure than previously realized.

The proven results — tropical valuation homomorphism, parabolic degeneration via Newton polygon collapse, scaling invariance, tropical vis-viva — form a foundation on which each direction builds. Direction 1 extends the support collapse theorem to a vertex formula. Direction 2 generalizes scaling invariance to a full structural stability criterion. Direction 3 lifts the p-adic coefficient analysis to a period valuation theorem. Direction 4 makes the leap to the three-body problem, testing whether tropical genus equals the number of equilibria. Direction 5 proposes a tropical analog of the deepest result in Hamiltonian mechanics.

Together, these directions define a research program that could establish tropical celestial mechanics as a field bridging algebraic geometry, dynamical systems, and number theory.

---

## Direction 1: Tropical Kepler Vertex Formula

**Conjecture**: For the tropicalization of $K(e,p)$ with $0 < e < 1$, $p > 0$, and base $t \gg 1$, the tropical curve has exactly
$$N_{\text{vert}} = 3 + \delta\big(v_t(1-e^2) > \min(v_t(2ep), v_t(e^2p^2))\big)$$
vertices, where $\delta(\cdot)$ is the indicator function.

**Test**: For $10^4$ random $(e, p)$ pairs with $0 < e < 1$, $0.1 < p < 10$:
1. Compute the lower convex hull of the lifted points $\{(2,0,v_t(1-e^2)), (1,0,v_t(2ep)), (0,2,0), (0,0,v_t(e^2p^2))\}$ in $\mathbb{R}^3$
2. Count the 2-dimensional faces → vertex count of the tropical curve
3. Compare with the formula
4. Any counterexample falsifies the conjecture

**Impact**: Would give a complete closed-form classification of tropical Kepler orbit combinatorics, reducing all tropical orbit computation to a single inequality check.

**Catalog References**: `Catalog/Pythagorean/TropicalKeplerOrbits.lean` — `keplerSupportSize_elliptic`, `keplerSupportSize_parabolic`, `keplerSupportSize_drop_at_parabola`

**Proof Strategy**: Strategy A (Newton Polygon Duality). Compute the regular subdivision of the Newton polygon induced by the valuation vector $(v(1-e^2), v(2ep), 0, v(e^2p^2))$. The vertex count equals the number of 2-cells in the subdivision, which depends on whether the lifted point $(2,0,v(1-e^2))$ lies above or below the lower convex hull of the other three lifted points.

**Domain Bridges**: Tropical Geometry ↔ Celestial Mechanics, Combinatorics ↔ Dynamics

**Lineage**: Extends Theorem 3.3 (support collapse) from counting monomials to counting tropical curve vertices.

**Ambition**: ★★★ (Solid extension — directly builds on proven infrastructure)

---

## Direction 2: Tropical Structural Stability

**Conjecture**: A perturbation $(e,p) \mapsto (e+\delta e, p+\delta p)$ preserves the combinatorial type of the tropical Kepler orbit if and only if it preserves the regular subdivision of the Newton polygon induced by the valuation vector.

**Test**:
1. For $10^3$ base parameters $(e,p)$, compute the tropical orbit and its regular subdivision
2. Apply random perturbations $(\delta e, \delta p)$ with varying magnitudes
3. For each perturbation, check whether:
   a. The combinatorial type (vertex count + edge directions) is preserved
   b. The regular subdivision is preserved
4. Verify that (a) ↔ (b) in all cases
5. Compute the Hausdorff distance between original and perturbed tropical curves

**Impact**: Would provide a tropical formulation of orbital stability, reducing it to a finite combinatorial check (is the subdivision unchanged?). This replaces continuous Lyapunov analysis with discrete geometry.

**Catalog References**: `Catalog/Pythagorean/TropicalKeplerOrbits.lean` — `keplerCoeffX_scale`, `keplerCoeffConst_scale`, `keplerCoeffX2_pos_of_elliptic`

**Proof Strategy**: Use the fact that regular subdivisions are determined by the lower convex hull, which changes only when a lifted point crosses a face. Characterize the crossing locus as a hyperplane arrangement in parameter space.

**Domain Bridges**: Tropical Geometry ↔ Dynamical Systems, Structural Stability ↔ Combinatorial Topology

**Lineage**: Generalizes Theorem 4.1 (scaling invariance) from scale transformations to arbitrary perturbations.

**Ambition**: ★★★★ (Substantial extension — requires developing tropical perturbation theory)

---

## Direction 3: P-adic Orbital Period Valuation

**Conjecture**: For prime $p$ and rational orbital parameters $(a, \mu) \in \mathbb{Q}^+$, the p-adic valuation of the Kepler period $T = 2\pi a^{3/2}/\sqrt{\mu}$ satisfies
$$v_p(T/2\pi) = \frac{3}{2} v_p(a) - \frac{1}{2} v_p(\mu).$$

Moreover, this p-adic invariant can be read off from the vertex depths of the p-adic tropical orbit: the depth of each vertex equals the p-adic valuation of the corresponding coefficient.

**Test**:
1. For primes $p < 1000$ and rational parameters $a = m/n$, $\mu = r/s$ with $1 \le m,n,r,s \le 100$
2. Compute $v_p(T/2\pi)$ directly from $T = 2\pi a^{3/2}/\mu^{1/2}$
3. Compare with $3v_p(a)/2 - v_p(\mu)/2$
4. When $v_p(a)$ is even and $v_p(\mu)$ is even (so the formula gives an integer), verify exact equality

**Impact**: Would establish a number-theoretic invariant of Kepler orbits computable from the tropical curve. The p-adic period valuation would be the first arithmetic orbital invariant derived from tropical geometry.

**Catalog References**: `Catalog/Pythagorean/TropicalKeplerOrbits.lean` — `tropicalVal_mul`, `tropicalVal_pow`, `tropicalVal_inv`

**Proof Strategy**: Express $T$ as a product $2\pi \cdot a^{3/2} \cdot \mu^{-1/2}$, apply the p-adic valuation homomorphism, and use the power rule for p-adic valuations. The key subtlety is handling $a^{3/2}$ and $\mu^{1/2}$ when they are not rational — restrict to cases where $a$ and $\mu$ are perfect squares modulo the prime.

**Domain Bridges**: Number Theory ↔ Celestial Mechanics, P-adic Analysis ↔ Tropical Geometry

**Lineage**: Extends the tropical valuation homomorphism (Theorems 2.1–2.5) to p-adic valuations of orbital quantities.

**Ambition**: ★★★ (Solid extension — uses well-understood p-adic machinery)

---

## Direction 4: Tropical Three-Body Genus Conjecture (Grand Challenge)

**Conjecture**: The tropicalization of the restricted three-body problem's Jacobi integral
$$C_J = -2E = (x^2 + y^2) + 2\left(\frac{1-\mu}{r_1} + \frac{\mu}{r_2}\right) - (\dot{x}^2 + \dot{y}^2)$$
yields a tropical curve whose genus equals the number of Lagrange points (5).

**Test**:
1. Tropicalize the Jacobi integral (after clearing denominators) to obtain a tropical polynomial in $(X, Y, \dot{X}, \dot{Y})$
2. Compute the tropical variety using `polymake` or `gfan`
3. Compute the genus (first Betti number) of the tropical curve
4. Verify whether genus = 5 for mass ratio $\mu \in (0, 1/2)$

**Impact**: Would provide a deep structural explanation for why there are exactly 5 Lagrange points — relating a dynamical fact to a topological invariant of a tropical curve. This would be the first application of tropical genus to a problem in dynamical systems.

**Catalog References**: `Catalog/Pythagorean/TropicalKeplerOrbits.lean` (two-body foundation), `Catalog/Pythagorean/OrbitClassification.lean` (orbit classification)

**Proof Strategy**: The Jacobi integral, after clearing denominators, becomes a polynomial in 4 variables. Its tropicalization has a Newton polytope in $\mathbb{Z}^4$. The tropical variety is a polyhedral complex whose Betti numbers can be computed from the combinatorics of the regular subdivision. The conjecture predicts that the relevant Betti number equals 5 regardless of the mass ratio.

**Domain Bridges**: Tropical Geometry ↔ Dynamical Systems ↔ Topology

**Lineage**: Extends the two-body tropical framework (this work) to the three-body problem.

**Ambition**: ★★★★★ (Grand challenge — would open tropical dynamics as a field)

---

## Direction 5: Tropical KAM Stability (Grand Challenge)

**Conjecture**: Tropical quasi-periodic orbits on tropical tori are structurally stable under tropical perturbations that preserve the Newton polytope subdivision. Specifically, the tropical analog of the KAM theorem holds: for "most" frequency vectors (a tropical Diophantine condition), the tropical invariant torus persists under perturbation.

**Test**:
1. Define a tropical integrable system as a collection of piecewise-linear functions $H_1, \ldots, H_n$ with the tropical Poisson bracket $\{H_i, H_j\}_{\text{trop}} = 0$
2. Construct tropical tori as level sets of these functions
3. Apply random tropical perturbations (piecewise-linear deformations) with varying amplitudes
4. Track whether the level-set topology is preserved
5. Measure the "tropical rotation number" and test whether preservation correlates with Diophantine conditions on the frequency vector

**Impact**: A tropical KAM theorem would revolutionize our understanding of stability in Hamiltonian systems. It would replace the analytical KAM machinery (convergence of infinite series, small divisor estimates) with finite combinatorial verification. The Diophantine condition on frequencies would become a condition on the Newton polytope subdivision, making it algorithmically checkable.

**Catalog References**: `Catalog/Pythagorean/TropicalKeplerOrbits.lean` — tropical valuation theory, scaling invariance, vis-viva identity

**Proof Strategy**: Begin with the tropical analog of the Hamilton-Jacobi equation. In the min-plus semiring, the generating function becomes piecewise-linear, and the small-divisor problem becomes a question about lattice geometry. The key insight: the Diophantine condition $|\langle k, \omega \rangle| \ge C/|k|^\tau$ tropicalizes to a condition on the depth of lattice points relative to the Newton polytope boundary.

**Domain Bridges**: Tropical Geometry ↔ Hamiltonian Mechanics ↔ Number Theory ↔ Ergodic Theory

**Lineage**: Extends the tropical vis-viva identity (Theorem 5.1) to full Hamiltonian mechanics.

**Ambition**: ★★★★★ (Paradigm-shifting — would create tropical Hamiltonian mechanics)
