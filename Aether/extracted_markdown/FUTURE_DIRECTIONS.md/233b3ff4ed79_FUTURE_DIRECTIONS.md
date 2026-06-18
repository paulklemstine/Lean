# Future Directions: Inverse Stereographic Renormalization Group

## Conjecture 1: Complex Extension Unlocks Hyperbolic Fixed Points

**Precise statement:** Extend the two-pole Möbius map $F_{a,b}$ to poles $a, b \in \mathbb{C}$ acting on the Riemann sphere $\hat{\mathbb{C}}$. Then for $a, b \in \mathbb{C}$ with $\text{Im}(a) \neq 0$ or $\text{Im}(b) \neq 0$, the map $F_{a,b}$ can be hyperbolic (two real fixed points) or loxodromic (spiraling dynamics), not just elliptic.

**Test:** Compute the trace $\text{tr}(F_{a,b}) = 2(ab+1)$ and the discriminant $\text{tr}^2 - 4\det$ for complex poles. The map is hyperbolic iff the discriminant is real and positive. Verify with specific examples: $a = i, b = 2i$ should give a loxodromic map.

**Impact:** If true, complex poles provide a geometric mechanism for hyperbolic (attractive/repulsive) RG fixed points, matching the phenomenology of physical RG flows. This would resolve the main limitation of the real-pole theory (elliptic-only dynamics).

---

## Conjecture 2: Two-Pole Geometric RG Is Universal for Rational One-Coupling RG Maps

**Precise statement:** Every one-dimensional rational RG map $T: \mathbb{R} \to \mathbb{R}$ of the form $T(g) = (pg + q)/(rg + s)$ with $ps - qr > 0$ (orientation-preserving Möbius map) is conjugate to some $F_{a,b}$ via an affine coordinate change $\psi(g) = \alpha g + \beta$.

**Test:** Given a Möbius RG map with coefficients $(p,q,r,s)$, solve the system:
- $(ab+1) = p\lambda$, $(b-a) = q\lambda$, $(a-b) = r\lambda$, $(ab+1) = s\lambda$ for $a, b, \lambda$.
- The constraint $(b-a) + (a-b) = 0 \Leftrightarrow q + r = 0$ (up to conjugacy) is necessary.
- Verify numerically for the transfer-matrix RG maps of the Potts model and hierarchical models.

**Impact:** If true, the geometric RG framework is the universal language for one-coupling Möbius RG, and all such physical RG flows are reparameterizations of pole-change geometry.

---

## Conjecture 3: Rotation Number Encodes the Central Charge

**Precise statement:** For the geometric RG map $F_{a,b}$ with poles $a, b \in \mathbb{R}$, $a \neq b$, the rotation number $\rho(a,b) \in [0,1)$ on the projective line satisfies
$$\rho(a,b) = \frac{1}{\pi} \arctan\left(\frac{|a - b|}{ab + 1}\right)$$
and this quantity is related to the central charge $c$ of a conformal field theory by $c = 12\rho(1 - \rho)$ in appropriate normalization.

**Test:**
1. Compute $\rho(a,b)$ numerically for many pole pairs and compare with the analytic formula.
2. For known CFT models with $c = 1/2$ (Ising), $c = 4/5$ (3-state Potts), check if there exist pole pairs reproducing these values.
3. The formula predicts $\rho(0, 1) = 1/4$, giving $c = 12 \cdot (1/4)(3/4) = 9/4$. Verify the rotation number numerically.

**Impact:** A direct connection between pole geometry and CFT data would be a major breakthrough, providing a geometric construction of conformal field theories from stereographic parameters.

---

## Conjecture 4: Multi-Pole Chains Generate Lattice RG Maps

**Precise statement:** For a sequence of $n$ poles $a_1, a_2, \ldots, a_n$ with $a_{n+1} = a_1$ (periodic), the iterated map $F_{a_n, a_1} \circ \cdots \circ F_{a_2, a_3} \circ F_{a_1, a_2} = F_{a_1, a_1} = \text{id}$ by the composition law. However, if we define a *block-averaged* RG map by grouping $k$ consecutive poles, the effective map $F_{a_1, a_{k+1}}$ can have nontrivial dynamics that depends on the block size $k$ (the "scale").

**Test:**
1. Generate random pole sequences and compute the effective RG map for various block sizes.
2. Check whether the effective map's properties (rotation number, derivative at representative points) exhibit scaling behavior as a function of block size.
3. Compare with real-space RG blocking transformations for the 1D Ising model on a finite lattice.

**Impact:** This would provide a discrete geometric analog of the Kadanoff block-spin transformation, where the "blocking" operation is purely geometric (grouping poles) rather than physical (summing spins).

---

## Conjecture 5: Hamiltonian Systems with Möbius-Invariant Energy Functions Exist and Are Integrable

**Precise statement:** There exists a nontrivial Hamiltonian system $H: \mathbb{R}^2 \to \mathbb{R}$ and a projection $\pi: \mathbb{R}^2 \to \mathbb{R}$ such that $H$ is a first integral, the projected dynamics $g(t) = \pi(\gamma(t))$ evolves on $\mathbb{R}$, and the energy function $E(g) = H(\pi^{-1}(g))$ satisfies $E(F_{a,b}(g)) = E(g)$ for specific poles $a, b$ determined by $H$.

**Test:**
1. Search for quadratic Hamiltonians $H(x,y) = \alpha x^2 + \beta xy + \gamma y^2$ where the projection $\pi(x,y) = x/y$ (projective coordinate) satisfies Möbius invariance.
2. The condition $E(F_{a,b}(g)) = E(g)$ with $E(g) = g^2 + 1$ (simplest candidate) requires $(F_{a,b}(g))^2 + 1 = g^2 + 1$, i.e., $F_{a,b}(g) = \pm g$. Check which pole pairs achieve this.
3. For the harmonic oscillator $H = (x^2 + y^2)/2$, verify whether the projected dynamics has any Möbius symmetry.

**Impact:** An explicit example would bridge Hamiltonian mechanics and geometric RG concretely, not just axiomatically. It would demonstrate that energy conservation *constrains* the allowable RG transformations, providing a physical selection principle for poles.
