# Future Directions: Dynamical Spectrum Theory

## Synthesis

This research cycle established **Dynamical Spectrum Theory** — a spectral framework for finite dynamical systems built on a novel invariant, the *spectral radius* σ(f), defined as the LCM of all minimal periods. The centerpiece is the **Spectral Idempotent Theorem** (f^[N+σ] = f^[N]), which characterizes the stabilization of iteration semigroups. Supporting results include conjugacy invariance, a factorial divisibility bound (σ | N!), iteration monotonicity (σ(f^n) | σ(f)), and a fixed-point characterization (σ=1 iff all periodic orbits are fixed points). All 15 theorems are formally verified in Lean 4 with zero sorries.

The most promising cross-domain connection is with the **algebraic structure of periodic orbits** in the existing Catalog. The `finite_state_orbit_periodic` result in `Bridges/ModularCFDynamics.lean` and `finite_dynamics_eventually_periodic` in `Bridges/ClosureKoopmanReconstruction.lean` prove qualitative periodicity results. Our spectral framework provides a *quantitative* upgrade: not just "eventually periodic" but "periodic with period dividing σ, stabilizing in at most N steps." This upgrades every existing periodicity result in the Catalog into a precise spectral statement. The `exists_periodic_point_finite` result in `Bridges/ProofStoneCechDynamics.lean` ensures existence of periodic points; our theory provides the full periodic structure.

The highest breakthrough potential lies in **Direction 1** (Sharkovsky's Theorem Formalization). This deep theorem about continuous dynamics on intervals has never been fully formalized in any proof assistant and would be a landmark achievement. Direction 2 (Probabilistic Spectral Theory) connects to number theory through Landau's function and offers concrete computational tests. Direction 3 (Spectral Zeta Function) introduces analytic tools that could bridge discrete dynamics and number theory.

---

### Direction 1: Sharkovsky's Theorem via Spectral Covering Relations

**Conjecture**: For any continuous function f : [a,b] → [a,b] and any positive integer n, if f has a periodic point of minimal period n, then for every positive integer m with n ◁ m in the Sharkovsky ordering (3 ◁ 5 ◁ 7 ◁ ... ◁ 2·3 ◁ 2·5 ◁ ... ◁ 4 ◁ 2 ◁ 1), f has a periodic point of minimal period m.

**Test**: Formalize the Sharkovsky ordering as a total order on ℕ⁺ and prove the "period 3 implies all periods" case (the strongest single implication). This would extend the existing `period3_implies_fixed_point_ivt` in `MachineLearning/DejaVu/CognitiveDynamics.lean`.

**Impact**: Full formalization of Sharkovsky's theorem would be a first for any proof assistant and a significant contribution to the formalized mathematics community. It would also provide the bridge between continuous dynamics (Sharkovsky) and discrete spectral theory (our framework): the Sharkovsky ordering constrains which spectral profiles are realizable by continuous maps.

**Catalog References**: `MachineLearning/DejaVu/CognitiveDynamics.lean` (`period3_implies_fixed_point_ivt`), `Bridges/DynamicalSpectrum/Defs.lean` (spectral radius definition)

**Proof Strategy**: The standard proof of Sharkovsky's theorem uses "interval covering relations": if f maps interval I over interval J, write I → J. A period-3 orbit creates a specific covering graph, and periodic orbits of all other periods are found via closed paths in this graph. The key technical challenge is formalizing the "f maps I over J" relation and using the Intermediate Value Theorem to extract periodic points from closed paths. Start with "period 3 implies period n for all n" as the main target, then generalize to the full Sharkovsky ordering.

**Domain Bridges**: Dynamical Systems ↔ Topology (IVT), Combinatorics (graph cycles) ↔ Number Theory (Sharkovsky ordering structure)

**Lineage**: Builds on `period3_implies_fixed_point_ivt` and the spectral framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Probabilistic Spectral Theory and Landau's Function

**Conjecture**: For a uniformly random function f : [n] → [n], the expected logarithm of the spectral radius satisfies E[log σ(f)] ~ c · √(n log n) for a constant c ∈ (0, 1), analogous to the Erdős-Turán theorem for random permutations.

**Test**: Compute E[log σ(f)] for n = 10, 50, 100, 500, 1000 with 10,000 samples each. Fit the function c · √(n log n) and estimate c. Compare with the permutation case (where c = 1 by the Erdős-Turán theorem). If the conjecture holds with c < 1, this quantifies how much periodic structure is "lost" by non-injectivity.

**Impact**: If true, this establishes a precise probabilistic law for the spectral complexity of random finite dynamical systems. The constant c would be a new mathematical constant characterizing the "spectral efficiency" of random maps versus random permutations. If false (e.g., if a different scaling holds), it would reveal that the periodic structure of non-bijective maps behaves fundamentally differently from permutations.

**Catalog References**: `Bridges/DynamicalSpectrum/Theorems.lean` (spectralRadius_dvd_factorial)

**Proof Strategy**: For the upper bound, use the factorial bound and Stirling's approximation. For the lower bound, analyze the distribution of cycle lengths in random functional graphs using the Flajolet-Odlyzko framework. The expected number of cycles of length k in a random map on [n] is approximately 1/k for k ≤ √n, similar to random permutations. The LCM of independent "random cycle lengths" can be analyzed using prime number theory. This is primarily an analytic number theory problem.

**Domain Bridges**: Dynamical Systems ↔ Probability Theory, Analytic Number Theory (prime distribution) ↔ Combinatorics (random structures)

**Lineage**: Builds on the spectral radius definition and factorial bound from this cycle. Connects to Erdős-Turán (1965) and Flajolet-Odlyzko (1990).

**Ambition**: grand_challenge

---

### Direction 3: The Dynamical Zeta Function

**Conjecture**: For a finite dynamical system (α, f) with |α| = n, define the dynamical zeta function ζ_f(t) = exp(Σ_{k≥1} |Fix(f^k)| · t^k / k) where Fix(f^k) is the set of fixed points of f^k. Then ζ_f(t) is a rational function of t, and its poles are located at t = 1/λ where λ ranges over the eigenvalues of the transition matrix of f.

**Test**: Compute ζ_f(t) for several small examples and verify rationality. For f = (0→1→2→0) on 3 elements, |Fix(f^k)| = 3 if 3|k and 0 otherwise, giving ζ_f(t) = 1/(1-t³). Check that the poles are at cube roots of unity, matching the eigenvalues of the 3×3 permutation matrix.

**Impact**: This would connect Dynamical Spectrum Theory to the Artin-Mazur zeta function and ultimately to the Weil conjectures (in the finite field setting). The spectral radius would appear as the inverse of the pole of ζ_f closest to the origin, providing a new interpretation of the spectral radius through analytic tools.

**Catalog References**: `Bridges/DynamicalSpectrum/Defs.lean`, `Bridges/AlgebraicEMLThermodynamicFormalism.lean` (thermodynamic formalism connection)

**Proof Strategy**: For finite systems, ζ_f(t) can be expressed as det(I - tA)^{-1} where A is the adjacency matrix of the functional graph. This is a standard result but has not been formalized. The key step is showing that |Fix(f^k)| = tr(A^k), which follows from the definition of matrix power. Then the exponential formula and the identity exp(Σ tr(A^k) t^k/k) = 1/det(I-tA) completes the proof.

**Domain Bridges**: Dynamical Systems ↔ Linear Algebra (spectral theory of matrices), Number Theory (zeta functions) ↔ Algebraic Geometry (Weil conjectures)

**Lineage**: Builds on the spectral radius and iteration divisibility results from this cycle.

**Ambition**: extension

---

### Direction 4: Optimal Stabilization Index

**Conjecture**: The optimal stabilization index N*(f) — the smallest N such that f^[N+σ] = f^[N] — equals the maximum tail length over all points. Moreover, for random f : [n] → [n], E[N*(f)] ~ c' · √n for a constant c' ≈ √(π/2).

**Test**: Compute N*(f) for random maps on [n] for n = 10, 100, 1000 and compare with √(πn/2). This constant comes from the expected height of a random functional graph (Flajolet-Odlyzko, 1990).

**Impact**: Our Spectral Idempotent Theorem uses N = card α as the stabilization bound, which is a worst case. The optimal N* could be much smaller. Proving N* = max tail length would tighten the theorem significantly, and the probabilistic result would show that for typical systems, stabilization occurs much faster than the worst case.

**Catalog References**: `Bridges/DynamicalSpectrum/Theorems.lean` (spectral_idempotent), `Bridges/DynamicalSpectrum/Defs.lean` (iterate_card_mem_periodicPts)

**Proof Strategy**: The key lemma is: if the maximum tail length is T, then f^T(x) is periodic for all x. This follows from the definition of tail length. Then f^[T+σ](x) = f^σ(f^T(x)) = f^T(x). The tightness direction requires constructing an x with tail length exactly T and showing f^[T-1+σ](x) ≠ f^[T-1](x). For the probabilistic part, use known results on the tail length distribution of random functional graphs.

**Domain Bridges**: Dynamical Systems ↔ Combinatorics (functional graph statistics), Probability ↔ Analytic Combinatorics

**Lineage**: Direct extension of the Spectral Idempotent Theorem from this cycle.

**Ambition**: extension

---

### Direction 5: Spectral Theory for Infinite-State Systems via Approximation

**Conjecture**: For a continuous map f : X → X on a compact metric space, define the n-th spectral approximation σ_n(f) as the spectral radius of f restricted to any ε_n-net of X (with ε_n → 0). Then lim sup σ_n(f) / n → 0 for maps with finitely many periodic orbits, and lim inf σ_n(f) / n > 0 for maps with positive topological entropy.

**Test**: For the logistic map f(x) = rx(1-x) on [0,1], compute σ_n for n-point discretizations at various values of r. For r < 3 (stable fixed point), verify σ_n = O(1). For r = 4 (full chaos), verify σ_n grows exponentially.

**Impact**: This would extend Dynamical Spectrum Theory from finite to infinite systems, providing a new numerical invariant for continuous dynamics. The connection to topological entropy would give spectral methods a foothold in the infinite-dimensional world.

**Catalog References**: `Bridges/DynamicalSpectrum/Theorems.lean` (spectralRadius_iterate_dvd for monotonicity under refinement), `Computation/Bifurcation.lean` (logistic map iteration)

**Proof Strategy**: The upper bound (finitely many periodic orbits case) follows from the fact that eventually, the discretization resolves all periodic orbits, and additional points only add transient tails. The lower bound (positive entropy case) requires showing that maps with positive topological entropy have periodic orbits with unboundedly large minimal periods (a consequence of the variational principle). The spectral radius of the discretization must capture at least some of these large periods.

**Domain Bridges**: Dynamical Systems (continuous) ↔ Dynamical Systems (discrete), Topology (compactness, continuity) ↔ Information Theory (entropy)

**Lineage**: Extends the finite spectral theory to the continuous setting. Connects to the existing `Computation/Bifurcation.lean` results.

**Ambition**: grand_challenge
