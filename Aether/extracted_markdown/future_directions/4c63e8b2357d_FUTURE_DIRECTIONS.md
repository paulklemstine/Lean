# Future Directions: EML Differential Equations

## Synthesis

This research cycle established the **EML Differential Complexity Algebra (EDCA)** — a novel mathematical structure that stratifies elementary functions by transcendental depth and provides a rigorous framework for analyzing when differential equations have elementary solutions. The key discovery is that differentiation is *depth-non-increasing*, while integration can increase depth by at most one level. This asymmetry is the engine that powers the entire theory of elementary non-integrability.

The most promising cross-domain connection is between the depth filtration and the Galois group of a differential equation. We proved that depth-preserving automorphisms form a filtered group, but the deeper question — whether this filtration corresponds to the derived series or lower central series of the differential Galois group — remains open. If true, this would give a purely computational criterion for solvability that bypasses the need for explicit Galois group computation.

The Airy obstruction results (polynomial degree arguments, Kovacic case elimination, growth rate bounds) provide a template that should generalize to broad families of equations. The number 3/2 — the rank of the Airy equation's irregular singularity at infinity — is the prototypical "fractional rank obstruction." Any equation with non-integer rank at infinity is immediately ruled out from having EML solutions, and classifying which rational functions r(x) produce integer vs. non-integer ranks is a tractable computational problem.

---

### Direction 1: Full Kovacic Algorithm as a Verified Decision Procedure

**Conjecture**: Kovacic's algorithm can be formalized as a total, decidable function `kovacic : RatCoeff → KovacicCase` in Lean 4, together with a soundness proof that if `kovacic r = noEMLSolution`, then the ODE y'' + r·y = 0 has no Liouvillian solutions.

**Test**: Implement the algorithm for the three Kovacic cases with rational coefficient input. Verify correctness on a test suite of 20 known equations (Airy, Bessel, Mathieu, Hermite, Laguerre, Whittaker, confluent hypergeometric, etc.) where the answer is known from classical references.

**Impact**: This would be the first machine-verified implementation of a complete differential equation solvability classifier. It would provide push-button proofs of non-elementary solvability for broad classes of equations.

**Catalog References**: `EML/DiffEML/AiryObstruction.lean` (Kovacic case obstructions), `EML/DiffEML/Wronskian.lean` (Riccati reduction)

**Proof Strategy**: 
1. Formalize the pole analysis of rational functions (partial fraction decomposition).
2. For each Kovacic case, implement the search for ω satisfying the case conditions.
3. The key difficulty is Case 3, which requires enumerating elements of finite subgroups of SL₂.
4. Prove termination by showing each case checks a finite set of candidates.
5. Prove soundness by showing that any EML solution must fall into one of the three cases.

**Domain Bridges**: Computation ↔ EML (decision procedure), Algebra ↔ EML (Galois groups)

**Lineage**: Builds on the Kovacic case analysis in this cycle's AiryObstruction.lean and the Riccati reduction in Wronskian.lean.

**Ambition**: grand_challenge

---

### Direction 2: Depth Filtration and the Derived Series of Differential Galois Groups

**Conjecture**: For a second-order linear ODE y'' + py' + qy = 0 with rational coefficients p, q, the depth filtration G₀ ⊇ G₁ ⊇ G₂ ⊇ ··· of the EML Galois group coincides with a truncation of the derived series G ⊇ [G,G] ⊇ [[G,G],[G,G]] ⊇ ··· of the differential Galois group. Specifically, G_d = G^(d) ∩ Aut_δ where G^(d) is the d-th derived subgroup.

**Test**: Compute both filtrations explicitly for:
- y'' + y = 0 (Galois group = SL₂, depth 1 solutions e^{ix})
- y'' = xy (Galois group = SL₂, no finite-depth solutions)
- y'' = y/x² (reducible, Galois group = Borel subgroup)
Verify whether the filtrations match in all three cases.

**Impact**: If true, this would provide a purely algebraic criterion for depth of solutions: the depth equals the length of the derived series (or ∞ if the group is perfect like SL₂). This connects differential Galois theory to group theory in a novel way.

**Catalog References**: `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety)

**Proof Strategy**:
1. Start with the classical Picard-Vessiot theory to compute the differential Galois group.
2. Define the depth filtration on the automorphism group of a concrete Picard-Vessiot extension.
3. For solvable equations, show inductively that each Liouville extension (adding one exp or log) corresponds to one step in the derived series.
4. For non-solvable equations (perfect Galois group), show that no finite truncation of the filtration reaches the identity.

**Domain Bridges**: Algebra ↔ EML (Galois theory meets depth filtration)

**Lineage**: Builds on the EMLDiffAut structure and depth_filtration_mono from Core.lean.

**Ambition**: grand_challenge

---

### Direction 3: Classification of Depth-1 Solvable Second-Order ODEs

**Conjecture**: A second-order linear ODE y'' + r(x)y = 0 with r ∈ ℚ(x) has a depth-1 EML solution (i.e., a solution of the form exp(∫ω) where ω is rational) if and only if the Riccati equation ω' + ω² = -r has a rational solution ω, which occurs if and only if the pole structure of r satisfies explicit arithmetic conditions at each pole (residues must be non-negative integers or specific half-integers).

**Test**: Generate all rational functions r = P/Q with deg(P) ≤ 3, deg(Q) ≤ 3, integer coefficients in [-5, 5]. For each, run the Kovacic Case 1 algorithm and record success/failure. Verify that the classification matches the conjectured pole conditions.

**Impact**: This would provide a complete characterization of when a second-order ODE has depth-1 solutions, extending Kovacic's Case 1 to an explicit, efficiently checkable criterion. This is the simplest non-trivial case of the full Kovacic algorithm.

**Catalog References**: `EML/DiffEML/Wronskian.lean` (riccati_reduction_identity, riccati_depth_bound)

**Proof Strategy**:
1. Formalize partial fraction decomposition for rational functions over ℚ.
2. Show that a rational solution ω of the Riccati equation must have poles only at the poles of r.
3. At each pole, the residue of ω is determined by a quadratic equation.
4. The consistency of all residue equations is the necessary and sufficient condition.
5. This is essentially a formalization of Kovacic's Case 1 with explicit classification.

**Domain Bridges**: Algebra ↔ EML (polynomial arithmetic), Computation ↔ EML (algorithmic classification)

**Lineage**: Builds on the Riccati reduction and depth bound results from this cycle.

**Ambition**: extension

---

### Direction 4: Irregular Singular Points and the Stokes Phenomenon

**Conjecture**: The **Stokes multiplier** of an irregular singular point of a linear ODE can be expressed in terms of a topological invariant (the monodromy defect) of the depth filtration. Specifically, for a rank-k/2 irregular singularity, the Stokes multiplier introduces exactly ⌈k/2⌉ additional "virtual depth levels" that prevent EML solvability.

**Test**: Compute Stokes multipliers numerically for:
- Airy equation (rank 3/2, expected 2 virtual levels)
- Bessel equation of order 0 (rank 1, expected 1 virtual level)
- Confluent hypergeometric (rank 1, expected 1 virtual level)
- Weber equation (rank 2, expected 1 virtual level since rank is integer)
Check whether the number of virtual levels correlates with the fractional part of the rank.

**Impact**: This would connect the analytic theory of Stokes phenomena to the algebraic theory of EML depth, creating a bridge between complex analysis and differential algebra. The Stokes phenomenon is one of the deepest aspects of ODE theory, and connecting it to depth filtration would be a significant advance.

**Catalog References**: `EML/DiffEML/AiryObstruction.lean` (kovacic_case1_rank_obstruction, airy_growth_exponent_irrational)

**Proof Strategy**:
1. Define the formal monodromy and Stokes matrices at an irregular singularity.
2. Show that the Stokes matrices lie in the unipotent radical of the differential Galois group.
3. Prove that the depth filtration of the Stokes matrices reflects the rank decomposition.
4. The key step is showing that non-integer rank forces the Stokes matrices to be non-trivial at every depth level — preventing finite-depth solutions.

**Domain Bridges**: Physics ↔ EML (Stokes phenomenon in quantum mechanics), Geometry ↔ EML (monodromy representations)

**Lineage**: Builds on the Airy obstruction analysis, particularly the rank 3/2 obstruction.

**Ambition**: grand_challenge

---

### Direction 5: EML Depth and Integration Complexity

**Conjecture**: Define the **integration complexity** of an EML function f as the minimum increase in depth when computing ∫f dx (within the class of EML functions, when the integral exists as EML). Then for "generic" depth-d EML functions, the integration complexity is exactly 1. Moreover, the set of depth-d functions with integration complexity 0 forms a proper differential ideal in the ring of depth-d EML functions.

**Test**: Enumerate all EML expression trees with ≤ 10 nodes and depth exactly 1. For each expression f, attempt to compute ∫f dx symbolically (using a CAS). Record whether the result has depth 1 (complexity 0) or depth 2 (complexity 1). Compute the ratio. The conjecture predicts the ratio of complexity-0 expressions approaches 0 as the tree size increases.

**Impact**: This would quantify the fundamental asymmetry between differentiation (depth-non-increasing) and integration (generically depth-increasing) in a precise, measurable way. It would provide theoretical backing for the empirical observation that "most integrals can't be done."

**Catalog References**: `EML/DiffEML/Core.lean` (depth_formalDeriv_le, depth_iterDeriv_le), `EML/DiffEML/Wronskian.lean` (log_deriv_depth_jump)

**Proof Strategy**:
1. Define a probability measure on EML expressions of bounded tree size using random recursive construction.
2. Show that depth-1 expressions generically have non-trivial logarithmic parts that force depth increase under integration.
3. The differential ideal structure should follow from the Risch algorithm's structure: the logarithmic part of the integral corresponds to the "obstacle" in Risch's algorithm.
4. This connects to effective differential algebra and Risch integration theory.

**Domain Bridges**: Computation ↔ EML (integration algorithms), MachineLearning ↔ EML (random expression generation)

**Lineage**: Builds on the depth monotonicity theorem and the observation that log(x) = ∫(1/x)dx increases depth.

**Ambition**: extension
