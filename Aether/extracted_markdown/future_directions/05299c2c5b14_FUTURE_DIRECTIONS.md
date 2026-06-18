# Future Directions: Optimal Curvature Distribution on Triangulated Surfaces

## Synthesis

The formalization of the discrete constant-curvature principle—connecting Gauss–Bonnet topology, variance minimization, and angle-bound realizability—opens five natural research directions. These span from constructive existence (Direction 1) through dynamical convergence (Direction 2), spectral connections (Direction 3), higher-order energies (Direction 4), to a grand challenge unifying discrete and continuous uniformization (Direction 5). Each direction builds on the proven quadratic decomposition identity (`Geometry/CurvatureVariance.lean: sq_dist_decomposition_to_constant`), the variance-zero rigidity theorem (`Geometry/CurvatureVariance.lean: curvatureVariance_eq_zero_iff`), the topological instantiation (`Geometry/CurvatureVarianceRealization.lean: equicurved_curvature_value`), and the realizability obstruction (`Geometry/CurvatureVarianceRealization.lean: necessary_condition_for_equicurved_realization`). Together, they form a program to develop discrete constant-curvature geometry into a complete computational and theoretical framework.

---

## Direction 1: Equicurvature Existence Threshold

**Conjecture.** For every genus $g \geq 0$, there exists a threshold $N(g) \in \mathbb{N}$ such that for all $n \geq N(g)$, there exists a closed orientable triangulated surface of genus $g$ with $n$ vertices and constant discrete curvature $K(v) = 2\pi(2-2g)/n$ at every vertex.

**Test.** For each genus $g \in \{0, 1, 2, 3\}$ and vertex counts $n$ from the minimum triangulation size up to 200:
1. Enumerate or sample triangulations (via edge flips from known triangulations).
2. For each, solve the linear feasibility problem: do there exist angle assignments with constant vertex defect?
3. Record the smallest $n$ achieving equicurvature.
A single genus $g$ with no finite threshold would disprove the conjecture.

**Impact.** Would establish that equicurvature is generically achievable, reducing the optimization problem to a finite computation for each genus.

**Catalog References.**
- `Geometry/CurvatureVariance.lean: curvatureVariance_eq_zero_iff` — characterizes when equicurvature holds
- `Geometry/CurvatureVarianceRealization.lean: equicurved_curvature_value` — identifies the target value
- `Geometry/DiscreteGaussBonnet.lean: discrete_gauss_bonnet` — the topological constraint

**Proof Strategy.** For genus 0, use icosahedral subdivision sequences. For genus 1, use flat torus lattice triangulations (equicurvature is trivially achievable with $K^* = 0$). For higher genus, attempt construction via branched covers of the torus with prescribed cone angles.

**Domain Bridges.** Computational topology → algebraic combinatorics → geometric group theory.

**Lineage.** Extends `discrete_gauss_bonnet` and `equicurved_curvature_value` from existence of the target value to constructive realizability.

**Ambition.** ★★★★ (High — would require novel construction techniques for high genus.)

---

## Direction 2: Discrete Curvature Flow with Convergence Guarantee

**Conjecture.** There exists a combinatorial curvature flow—a sequence of local angle/edge modifications—that monotonically decreases curvature variance while preserving the Gauss–Bonnet constraint, and converges to the equicurved state (or to a local minimum under geometric constraints) in polynomially many steps.

**Test.**
1. Implement a flow: at each step, identify the vertex of maximum $|K(v) - \bar{K}|$, perform a local edge flip or angle redistribution that decreases variance.
2. Run on random triangulations with $n = 50, 100, 200$ vertices for genus 0, 1, 2.
3. Record variance at each step. Check monotone decrease and convergence rate.
A counterexample would be a triangulation where all local moves increase variance.

**Impact.** Would provide a certified mesh optimization algorithm with convergence guarantees—directly applicable to finite element preprocessing.

**Catalog References.**
- `Geometry/CurvatureVariance.lean: curvatureVariance_nonneg` — variance is bounded below by 0
- `Geometry/CurvatureVariance.lean: sq_dist_decomposition_to_constant` — energy decomposition drives convergence analysis
- `Geometry/CurvatureVarianceRealization.lean: surface_curvatureVariance_nonneg` — surface instantiation

**Proof Strategy.** Define the flow via steepest descent on variance. Show each step decreases variance by at least $\Omega(1/n^2)$. Use the decomposition identity to bound the gap from optimum. Polynomial convergence follows if the step size is uniformly bounded below.

**Domain Bridges.** Discrete differential geometry → optimization theory → algorithm design → computational geometry.

**Lineage.** Extends the static optimization principle to a dynamic convergence result. Analogous to Chow–Luo combinatorial Ricci flow.

**Ambition.** ★★★★★ (Grand challenge — convergence proofs for combinatorial flows are notoriously difficult.)

---

## Direction 3: Spectral Gap and Curvature Variance Bound

**Conjecture.** For a closed orientable triangulated surface $T$ with combinatorial Laplacian $L$ and smallest nonzero eigenvalue $\lambda_1(L)$, the curvature variance satisfies:
$$\operatorname{Var}(K_T) \geq C \cdot \lambda_1(L) \cdot \|\delta\|_\infty^2$$
for an explicit constant $C$ depending only on the genus and vertex count, where $\delta$ is the curvature defect vector.

**Test.**
1. Compute the combinatorial Laplacian and its spectrum for triangulations with $n = 20, 50, 100$ vertices.
2. Compute curvature variance and $\lambda_1$.
3. Plot $\operatorname{Var}(K)$ vs $\lambda_1 \cdot \|\delta\|_\infty^2$ and check whether a universal constant $C$ exists.
A family of triangulations violating any such bound would disprove the conjecture.

**Impact.** Would connect curvature geometry to spectral graph theory, enabling spectral methods for mesh quality assessment.

**Catalog References.**
- `Geometry/CurvatureVariance.lean: curvatureVariance_eq_norm_sq_of_mean_zero_part` — variance as squared norm
- `Geometry/CurvatureVarianceRealization.lean: defect_sum_vanishes` — defect is mean-zero
- `Geometry/DiscreteGaussBonnet.lean: discrete_gauss_bonnet` — topological constraint

**Proof Strategy.** The defect vector $\delta$ is mean-zero, hence in the span of non-constant eigenvectors of $L$. By Rayleigh quotient, $\langle L\delta, \delta \rangle \geq \lambda_1 \|\delta\|^2$. If the Laplacian energy of $\delta$ can be related to geometric curvature energy, the bound follows.

**Domain Bridges.** Spectral graph theory → discrete Hodge theory → statistical mechanics → quantum gravity.

**Lineage.** Extends the Hodge decomposition interpretation in `curvatureVariance_eq_norm_sq_of_mean_zero_part`.

**Ambition.** ★★★★ (High — spectral-geometric inequalities are deep.)

---

## Direction 4: Lp Curvature Energy and Phase Transitions

**Conjecture.** For the generalized curvature energy $E_p(K) = \sum_v |K(v) - \bar{K}|^p$, the minimizer under the Gauss–Bonnet constraint is still the constant profile for all $p \geq 1$, but for $0 < p < 1$, there exist triangulations where the minimizer is non-constant (curvature concentrates at fewer vertices).

**Test.**
1. For $p \in \{0.5, 1, 1.5, 2, 3\}$ and triangulated spheres with $n = 12, 42, 80$ vertices:
2. Numerically minimize $E_p$ over admissible curvature profiles (those satisfying Gauss–Bonnet and angle bounds).
3. Check whether the minimizer is constant ($p \geq 1$) or concentrated ($p < 1$).
A constant minimizer for some $p < 1$ would partially disprove the conjecture.

**Impact.** Would reveal a phase transition in optimal curvature distribution, connecting to compressed sensing and sparsity-promoting regularization.

**Catalog References.**
- `Geometry/CurvatureVariance.lean: curvatureVariance_eq_zero_iff` — $p = 2$ case
- `Geometry/CurvatureVariance.lean: curvatureEnergy_strict_min` — strict minimality for $p = 2$
- `Geometry/CurvatureVarianceRealization.lean: necessary_condition_for_equicurved_realization` — geometric constraints

**Proof Strategy.** For $p \geq 1$, use strict convexity of $x \mapsto |x|^p$ and Jensen's inequality. For $p < 1$, construct explicit counterexamples via perturbation of the constant profile, showing the $L^p$ energy decreases under concentration.

**Domain Bridges.** Convex analysis → compressed sensing → information theory → statistical physics.

**Lineage.** Generalizes the $L^2$ theory in `CurvatureVariance.lean` to arbitrary $L^p$.

**Ambition.** ★★★ (Moderate — the $p \geq 1$ case should follow from known convexity results; the $p < 1$ case requires construction.)

---

## Direction 5: Discrete Uniformization via Curvature Flow (Grand Challenge)

**Conjecture.** For every closed orientable triangulated surface $T$ and every target curvature profile $K^* : V \to \mathbb{R}$ satisfying $\sum_v K^*(v) = 2\pi\chi$ and local realizability constraints, there exists a sequence of edge flips and angle redistributions transforming $T$ into a triangulation $T'$ with $K_{T'} = K^*$. Moreover, this transformation can be computed in polynomial time.

**Test.**
1. Start with random triangulations of genus 0, 1, 2 with $n = 50$ vertices.
2. Set $K^*$ to be equicurved.
3. Implement a greedy algorithm: flip the edge that most decreases $\|K - K^*\|^2$.
4. Record convergence or failure after $O(n^3)$ steps.
A triangulation from which no sequence of edge flips reaches equicurvature would partially disprove the conjecture.

**Impact.** Would be a discrete analogue of the uniformization theorem—one of the most celebrated results in mathematics. A polynomial-time algorithm would revolutionize mesh processing, 3D modeling, and computational conformal geometry.

**Catalog References.**
- `Geometry/DiscreteGaussBonnet.lean: total_curvature_eq_genus` — the conservation law driving the flow
- `Geometry/CurvatureVariance.lean: sq_dist_decomposition_to_constant` — energy monotonicity framework
- `Geometry/CurvatureVarianceRealization.lean: equicurved_curvature_value` — the target state
- `Geometry/CurvatureVarianceRealization.lean: necessary_condition_for_equicurved_realization` — realizability constraints

**Proof Strategy.** 
Phase 1: Prove reachability for genus 0 using the Pachner move connectivity theorem (any two triangulations of $S^2$ with the same vertex count are connected by edge flips).
Phase 2: Prove variance monotonicity of the greedy flip algorithm.
Phase 3: Extend to higher genus using the handle decomposition.

**Domain Bridges.** Discrete differential geometry → computational topology → algorithmic graph theory → complex analysis → mathematical physics (Regge calculus, quantum gravity).

**Lineage.** Ultimate synthesis of all catalog results: Gauss–Bonnet constraint + variance optimization + realizability obstruction + flow convergence = discrete uniformization.

**Ambition.** ★★★★★ (Grand challenge — would be a major breakthrough in discrete geometry.)
