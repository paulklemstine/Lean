# Future Directions: Hyperbolic Conformal Packing Theory

## Conjecture 1: Boundary-Shell Asymptotic Sharpness

**Conjecture:** For fixed n and r > 0, consider thin annular shells Ω_ρ = {x ∈ ℝⁿ : ρ₀ ≤ ‖x‖ < ρ} with ρ₀ fixed and ρ → 1⁻. Then the ratio

$$\frac{N_{\mathbb{H}}(\Omega_\rho, r) \cdot \text{capVol}_{\mathbb{H}}(n,r)}{\text{hvol}_n(\Omega_\rho)}$$

converges to a constant c(n,r) > 0 as ρ → 1⁻, where N_H is the optimal packing number and capVol_H is the exact hyperbolic ball volume.

**Test:** Implement optimal (or near-optimal) hyperbolic circle packings in thin shells Ω_ρ for n=2, r=0.5, with ρ = 0.9, 0.95, 0.98, 0.99, 0.995, 0.999. Compute the ratio and test for convergence. Use simulated annealing or other global optimization to improve beyond greedy packings. If the ratio converges, estimate c(2, 0.5). If it does not converge, determine whether the limit is 0 or ∞.

**Impact:** If true, this establishes that the conformal volume is the correct "natural scale" for hyperbolic packing, validating the weighted volume framework. If false, it would suggest that additional geometric structure (e.g., boundary curvature effects) must be incorporated.

---

## Conjecture 2: Curvature Interpolation Law

**Conjecture:** There exists a unified distortion factor D_K(n, ρ, r) for constant sectional curvature K ∈ [-1, 0, +1] such that:
- D₋₁(n, ρ, r) = (1-ρ²)⁻ⁿ · f(n, ρ, r) gives the hyperbolic packing bound
- D₀(n, ρ, r) = 1 gives the Euclidean packing bound
- D₊₁(n, ρ, r) gives the spherical packing bound via stereographic projection
- D_K varies continuously as K → 0

Specifically, the conformal factor for curvature K on the ball of radius R = 1/√|K| should be λ_K(x) = 2/(1 - K‖x‖²), yielding distortion D_K(n,ρ) = (1/(1 - Kρ²))ⁿ.

**Test:** For n=2 and r=0.3:
1. Compute D_K for K = -1, -0.5, -0.1, -0.01, 0, +0.01, +0.1, +0.5, +1
2. For each K, generate optimal packings on the corresponding model space
3. Verify that D_K(n,ρ,r) gives valid upper bounds in each case
4. Check continuity at K = 0

**Impact:** Would unify Euclidean, spherical, and hyperbolic packing theory into a single parametric framework, creating a "periodic table" of constant-curvature packing bounds.

---

## Conjecture 3: Möbius Sharpening

**Conjecture:** Using the Möbius automorphism φ_a(x) = (a - x + ...)/(1 - ⟨a,x⟩ + ...) of the Poincaré ball that sends center c to origin 0, the Euclidean radius of a hyperbolic r-ball B_H(c,r) can be bounded below by

$$R_{\text{sharp}}(c, r) = \frac{(1 - \|c\|^2) \tanh(r/2)}{1 - \|c\| \cdot \tanh(r/2)}$$

which is strictly larger than our current bound R̲(ρ,r) when ‖c‖ < ρ. This would improve the packing bound by a factor that grows with the ratio ρ/‖c‖.

**Test:** For n=2, compute both R̲(ρ,r) and R_sharp(c,r) for c at various positions within B̄(0,ρ), and compare. Then compute the improved packing bound using center-specific subball radii and compare against the uniform bound.

**Impact:** Would tighten the packing inequality by eliminating the worst-case over all centers, potentially reducing the gap factor from O(D) to O(1) for well-distributed packings.

---

## Conjecture 4: Exponential Capacity Growth Rate

**Conjecture:** For the Poincaré disk (n=2), the maximal packing number N_H(B̄(0,ρ), r) satisfies

$$\lim_{\rho \to 1^-} \frac{\log N_{\mathbb{H}}(\overline{B}(0,\rho), r)}{-\log(1-\rho^2)} = 1$$

for every fixed r > 0. That is, the packing number grows like (1-ρ²)⁻¹ as ρ → 1.

**Test:** Compute N_H(B̄(0,ρ), r) for ρ = 0.9, 0.95, 0.99, 0.995, 0.999 and r = 0.3, 0.5, 1.0 using the best available packings (greedy + local search). Plot log(N) vs -log(1-ρ²) and check for slope convergence to 1.

**Impact:** Would establish the precise growth rate of hyperbolic packing numbers near the boundary, connecting to the volume growth rate of hyperbolic space and the growth functions of Fuchsian groups.

---

## Conjecture 5: Computational Hardness of Hyperbolic Packing

**Conjecture:** Computing the exact maximum packing number N_H(Ω, r) for a polygonal domain Ω in the Poincaré disk is NP-hard, even for convex Ω.

**Test:** Reduce from a known NP-hard problem (e.g., independent set in unit disk graphs, or the Euclidean packing problem which is known to be NP-hard) to the hyperbolic packing problem. The key step is showing that the conformal distortion does not make the problem easier — if anything, the position-dependent ball sizes make it harder.

**Impact:** Would establish that certified upper bounds (like our theorem) are not just convenient but *necessary* — exact computation is intractable, so provably correct bounds are the best one can achieve in polynomial time.
