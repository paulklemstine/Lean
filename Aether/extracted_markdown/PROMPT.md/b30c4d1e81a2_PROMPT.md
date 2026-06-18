
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: **Causal Integration Algebra** — a rigorous lattice-t
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Causal Integration Algebra

## Synthesis

This cycle established the **Causal Integration Algebra** — a rigorous lattice-theoretic formalization of Integrated Information Theory that identifies Φ with the minimum cut of a weighted causal graph. We proved 18 theorems covering nonnegativity, decomposition characterization, composition/exclusion, scaling, monotonicity, and a novel symmetrization invariance result. The framework connects IIT to classical graph theory and opens several deep avenues.

The most promising cross-domain connection is between **integration theory and spectral graph theory**. The Fiedler value (algebraic connectivity) provides a lower bound on the minimum cut, and our scaling and monotonicity theorems suggest that the entire spectral structure of the graph Laplacian encodes integration properties. This connects consciousness science to one of the richest areas of combinatorial mathematics.

The highest breakthrough potential lies in **Direction 1**: formalizing the relationship between Φ and algebraic connectivity. If this connection can be made precise, it would import the entire machinery of spectral graph theory into consciousness science — eigenvalue bounds, Cheeger inequalities, expander graphs, and random matrix theory would all become tools for understanding integration.

---

### Direction 1: Spectral Integration — Φ and the Fiedler Value

**Conjecture**: For any symmetric causal system C on n vertices, the Fiedler value λ₂(L) of the graph Laplacian satisfies: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4, where L is the Laplacian matrix of the symmetrized causal graph with edge weights w(i,j) + w(j,i).

**Test**: Compute both Φ (by brute-force minimum cut) and λ₂(L) (by eigenvalue computation) for all connected weighted graphs on 4-6 vertices with integer weights 1-3. Check whether the conjectured inequality holds.

**Impact**: If true, this establishes a computable lower bound on Φ via eigenvalue computation (O(n²) vs O(2ⁿ) for brute-force Φ), and imports Cheeger-type inequalities into consciousness theory. If false, the failure case would reveal systems where spectral methods fundamentally mischaracterize integration.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (CausalSystem, phi, symmetrize_phi), `Novelty/IntegratedInformation/Spectrum.lean` (phi_eq_min_cut, phi_mono_of_weight_le)

**Proof Strategy**: 
1. Define the graph Laplacian L of a CausalSystem in Lean
2. Prove the Courant-Fischer characterization of λ₂
3. Show that Φ = min_A cross(A) ≥ λ₂ via the Rayleigh quotient bound
4. Prove the upper bound using the Cheeger inequality

**Domain Bridges**: Spectral Graph Theory ↔ Integrated Information Theory ↔ Algebraic Connectivity

**Lineage**: Builds on phi_eq_min_cut, symmetrize_phi, crossInfo_le_totalWeight from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Dynamic Integration — Phase Transitions in Evolving Causal Systems

**Conjecture**: For a one-parameter family of causal systems C(t) where w(i,j;t) = (1-t)·w_disconnected + t·w_connected (linear interpolation between a disconnected and fully connected system), there exists a critical threshold t* ∈ (0,1) such that Φ(C(t)) = 0 for t < t* and Φ(C(t)) > 0 for t > t*. Moreover, t* = 1/n for the uniform complete graph target.

**Test**: Compute Φ(C(t)) for n = 4,5,6 with the disconnected system being two equal halves and the connected system being the complete graph with unit weights. Plot Φ vs t and verify the phase transition.

**Impact**: If true, this identifies a sharp phase transition in integration, analogous to percolation thresholds in random graphs. This would connect IIT to critical phenomena and phase transitions — one of the deepest frameworks in statistical physics. If false, integration may emerge gradually rather than sharply, which would itself be informative.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (phi, IsDisconnected, phi_zero_of_disconnected), `Novelty/IntegratedInformation/Spectrum.lean` (phi_mono_of_weight_le, phi_scale)

**Proof Strategy**:
1. Define CausalSystem.interpolate as a linear combination
2. Show Φ is continuous in the interpolation parameter (follows from min of continuous functions)
3. Show Φ = 0 at t = 0 (disconnected) and Φ > 0 at t = 1 (strongly positive)
4. Prove existence of t* by intermediate value theorem
5. For the specific uniform case, compute t* exactly

**Domain Bridges**: Statistical Physics (Phase Transitions) ↔ Integrated Information ↔ Percolation Theory

**Lineage**: Builds on phi_zero_of_disconnected, phi_pos_of_strongly_positive, phi_mono_of_weight_le from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Categorical Integration — Causal Systems as Enriched Categories

**Conjecture**: The category of causal systems (with morphisms being weight-reducing maps) admits a monoidal structure under direct sum, and Φ extends to a lax monoidal functor to (ℝ≥0, min, +). Specifically, Φ(C₁ ⊕ C₂) = min(Φ(C₁), Φ(C₂), cross(C₁,C₂)) where cross(C₁,C₂) is the minimum cross-flow between the two components.

**Test**: Verify the functor properties for all pairs of causal systems on 2-3 vertices. Check that the monoidal structure axioms (associativity, unit) hold.

**Impact**: If true, this provides a categorical foundation for IIT, enabling composition of conscious systems via universal constructions (limits, colimits). This would connect IIT to topos theory and provide a principled answer to the "combination problem" in philosophy of mind.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (directSum, phi_directSum_eq_zero), `Bridges/ArrowDepthComplexity.lean` (category-theoretic methods)

**Proof Strategy**:
1. Define the category CausalSys with objects = CausalSystem n and morphisms = weight-reducing maps
2. Verify well-definedness of composition
3. Define the direct sum monoidal product
4. Show Φ is functorial (monotonicity implies functoriality)
5. Verify the lax monoidal property

**Domain Bridges**: Category Theory (Enriched Categories) ↔ IIT ↔ Monoidal Functors

**Lineage**: Builds on directSum, phi_directSum_eq_zero, phi_mono_of_weight_le from this cycle.

**Ambition**: extension

---

### Direction 4: Integration Spectrum and Chromatic Number

**Conjecture**: For a causal system C, define the "zero graph" G₀ as the graph with edges where w(i,j) = 0. Then the integration dimension (largest k where Φ_k > 0) equals the chromatic number χ(G₀ᶜ) of the complement of G₀ minus 1. In particular, for a strongly positive system, dim(C) = n - 1.

**Test**: Enumerate all graphs on 4-5 vertices, assign random positive weights to edges and zero to non-edges. Compute integration dimension by brute-force k-partition enumeration. Compare with chromatic number of complement.

**Impact**: If true, this provides a graph-coloring characterization of integration depth, connecting IIT to one of the central problems in combinatorics. If false, the failure cases would reveal interesting structures where integration dimension diverges from chromatic expectations.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (KPartition, interPartFlow, interPartFlow_nonneg), `Novelty/IntegratedInformation/Spectrum.lean` (phi_pos_of_strongly_positive)

**Proof Strategy**:
1. Formalize integration dimension as a definition
2. Show that Φ_k > 0 iff every k-partition has positive inter-part flow
3. Relate this to the existence of edges between every pair of parts
4. Connect to graph coloring: a proper coloring of G₀ᶜ corresponds to a zero-flow partition

**Domain Bridges**: Graph Coloring ↔ Integration Spectrum ↔ Complexity Theory (chromatic number is NP-hard)

**Lineage**: Builds on KPartition, interPartFlow_nonneg from this cycle; connects to `critical_density_bounds` in Novelty/SegmentAlgebra.lean.

**Ambition**: extension

---

### Direction 5: Information-Geometric Integration — Φ on Statistical Manifolds

**Conjecture**: When causal weights represent Fisher information between stochastic processes at each node, Φ becomes a Riemannian distance on the statistical manifold of joint distributions. Specifically, Φ(C) ≥ d_FI(p_joint, p_product) where d_FI is the Fisher-Rao distance between the joint distribution and the product of marginals.

**Test**: For binary causal systems (each node has state 0 or 1) with n = 3-4, compute Φ (minimum cut) and d_FI (Fisher-Rao distance between joint and product distributions) numerically. Check whether the inequality holds.

**Impact**: If true, this embeds IIT in information geometry — one of the most elegant frameworks in mathematical statistics. Φ would acquire a geometric interpretation as a "distance from independence" on a curved statistical manifold. This would also provide natural connections to machine learning (natural gradient descent) and quantum information (quantum Fisher information).

**Catalog References**: `Novelty/IntegratedInformation/Spectrum.lean` (phi_le_totalWeight, phi_scale), `Bridges/PadicQuantumInformation.lean` (information-theoretic methods)

**Proof Strategy**:
1. Define Fisher information matrix for a causal system
2. Define the Fisher-Rao metric on the simplex of joint distributions
3. Show that the minimum cut provides an upper bound on the geodesic distance
4. Prove the lower bound using the data processing inequality

**Domain Bridges**: Information Geometry ↔ IIT ↔ Statistical Manifolds ↔ Quantum Information

**Lineage**: Builds on phi_le_totalWeight, crossInfo_le_totalWeight from this cycle; connects to `ultrametric_entropy_composition_bound` in Bridges/PadicQuantumInformation.lean.

**Ambition**: grand_challenge

**Concept description**: # Future Directions: Causal Integration Algebra

## Synthesis

This cycle established the **Causal Integration Algebra** — a rigorous lattice-theoretic formalization of Integrated Information Theory that identifies Φ with the minimum cut of a weighted causal graph. We proved 18 theorems covering nonnegativity, decomposition characterization, composition/exclusion, scaling, monotonicity, and a novel symmetrization invariance result. The framework connects IIT to classical graph theory and opens several deep avenues.

The most promising cross-domain connection is between **integration theory and spectral graph theory**. The Fiedler value (algebraic connectivity) provides a lower bound on the minimum cut, and our scaling and monotonicity theorems suggest that the entire spectral structure of the graph Laplacian encodes integration properties. This connects consciousness science to one of the richest areas of combinatorial mathematics.

The highest breakthrough potential lies in **Direction 1**: formalizing the relationship between Φ and algebraic connectivity. If this connection can be made precise, it would import the entire machinery of spectral graph theory into consciousness science — eigenvalue bounds, Cheeger inequalities, expander graphs, and random matrix theory would all become tools for understanding integration.

---

### Direction 1: Spectral Integration — Φ and the Fiedler Value

**Conjecture**: For any symmetric causal system C on n vertices, the Fiedler value λ₂(L) of the graph Laplacian satisfies: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4, where L is the Laplacian matrix of the symmetrized causal graph with edge weights w(i,j) + w(j,i).

**Test**: Compute both Φ (by brute-force minimum cut) and λ₂(L) (by eigenvalue computation) for all connected weighted graphs on 4-6 vertices with integer weights 1-3. Check whether the conjectured inequality holds.

**Impact**: If true, this establishes a computable lower bound on Φ via eigenvalue computation (O(n²) vs O(2ⁿ) for brute-force Φ), and imports Cheeger-type inequalities into consciousness theory. If false, the failure case would reveal systems where spectral methods fundamentally mischaracterize integration.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (CausalSystem, phi, symmetrize_phi), `Novelty/IntegratedInformation/Spectrum.lean` (phi_eq_min_cut, phi_mono_of_weight_le)

**Proof Strategy**: 
1. Define the graph Laplacian L of a CausalSystem in Lean
2. Prove the Courant-Fischer characterization of λ₂
3. Show that Φ = min_A cross(A) ≥ λ₂ via the Rayleigh quotient bound
4. Prove the upper bound using the Cheeger inequality

**Domain Bridges**: Spectral Graph Theory ↔ Integrated Information Theory ↔ Algebraic Connectivity

**Lineage**: Builds on phi_eq_min_cut, symmetrize_phi, crossInfo_le_totalWeight from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Dynamic Integration — Phase Transitions in Evolving Causal Systems

**Conjecture**: For a one-parameter family of causal systems C(t) where w(i,j;t) = (1-t)·w_disconnected + t·w_connected (linear interpolation between a disconnected and fully connected system), there exists a critical threshold t* ∈ (0,1) such that Φ(C(t)) = 0 for t < t* and Φ(C(t)) > 0 for t > t*. Moreover, t* = 1/n for the uniform complete graph target.

**Test**: Compute Φ(C(t)) for n = 4,5,6 with the disconnected system being two equal halves and the connected system being the complete graph with unit weights. Plot Φ vs t and verify the phase transition.

**Impact**: If true, this identifies a sharp phase transition in integration, analogous to percolation thresholds in random graphs. This would connect IIT to critical phenomena and phase transitions — one of the deepest frameworks in statistical physics. If false, integration may emerge gradually rather than sharply, which would itself be informative.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (phi, IsDisconnected, phi_zero_of_disconnected), `Novelty/IntegratedInformation/Spectrum.lean` (phi_mono_of_weight_le, phi_scale)

**Proof Strategy**:
1. Define CausalSystem.interpolate as a linear combination
2. Show Φ is continuous in the interpolation parameter (follows from min of continuous functions)
3. Show Φ = 0 at t = 0 (disconnected) and Φ > 0 at t = 1 (strongly positive)
4. Prove existence of t* by intermediate value theorem
5. For the specific uniform case, compute t* exactly

**Domain Bridges**: Statistical Physics (Phase Transitions) ↔ Integrated Information ↔ Percolation Theory

**Lineage**: Builds on phi_zero_of_disconnected, phi_pos_of_strongly_positive, phi_mono_of_weight_le from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Categorical Integration — Causal Systems as Enriched Categories

**Conjecture**: The category of causal systems (with morphisms being weight-reducing maps) admits a monoidal structure under direct sum, and Φ extends to a lax monoidal functor to (ℝ≥0, min, +). Specifically, Φ(C₁ ⊕ C₂) = min(Φ(C₁), Φ(C₂), cross(C₁,C₂)) where cross(C₁,C₂) is the minimum cross-flow between the two components.

**Test**: Verify the functor properties for all pairs of causal systems on 2-3 vertices. Check that the monoidal structure axioms (associativity, unit) hold.

**Impact**: If true, this provides a categorical foundation for IIT, enabling composition of conscious systems via universal constructions (limits, colimits). This would connect IIT to topos theory and provide a principled answer to the "combination problem" in philosophy of mind.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (directSum, phi_directSum_eq_zero), `Bridges/ArrowDepthComplexity.lean` (category-theoretic methods)

**Proof Strategy**:
1. Define the category CausalSys with objects = CausalSystem n and morphisms = weight-reducing maps
2. Verify well-definedness of composition
3. Define the direct sum monoidal product
4. Show Φ is functorial (monotonicity implies functoriality)
5. Verify the lax monoidal property

**Domain Bridges**: Category Theory (Enriched Categories) ↔ IIT ↔ Monoidal Functors

**Lineage**: Builds on directSum, phi_directSum_eq_zero, phi_mono_of_weight_le from this cycle.

**Ambition**: extension

---

### Direction 4: Integration Spectrum and Chromatic Number

**Conjecture**: For a causal system C, define the "zero graph" G₀ as the graph with edges where w(i,j) = 0. Then the integration dimension (largest k where Φ_k > 0) equals the chromatic number χ(G₀ᶜ) of the complement of G₀ minus 1. In particular, for a strongly positive system, dim(C) = n - 1.

**Test**: Enumerate all graphs on 4-5 vertices, assign random positive weights to edges and zero to non-edges. Compute integration dimension by brute-force k-partition enumeration. Compare with chromatic number of complement.

**Impact**: If true, this provides a graph-coloring characterization of integration depth, connecting IIT to one of the central problems in combinatorics. If false, the failure cases would reveal interesting structures where integration dimension diverges from chromatic expectations.

**Catalog References**: `Novelty/IntegratedInformation/Core.lean` (KPartition, interPartFlow, interPartFlow_nonneg), `Novelty/IntegratedInformation/Spectrum.lean` (phi_pos_of_strongly_positive)

**Proof Strategy**:
1. Formalize integration dimension as a definition
2. Show that Φ_k > 0 iff every k-partition has positive inter-part flow
3. Relate this to the existence of edges between every pair of parts
4. Connect to graph coloring: a proper coloring of G₀ᶜ corresponds to a zero-flow partition

**Domain Bridges**: Graph Coloring ↔ Integration Spectrum ↔ Complexity Theory (chromatic number is NP-hard)

**Lineage**: Builds on KPartition, interPartFlow_nonneg from this cycle; connects to `critical_density_bounds` in Novelty/SegmentAlgebra.lean.

**Ambition**: extension

---

### Direction 5: Information-Geometric Integration — Φ on Statistical Manifolds

**Conjecture**: When causal weights represent Fisher information between stochastic processes at each node, Φ becomes a Riemannian distance on the statistical manifold of joint distributions. Specifically, Φ(C) ≥ d_FI(p_joint, p_product) where d_FI is the Fisher-Rao distance between the joint distribution and the product of marginals.

**Test**: For binary causal systems (each node has state 0 or 1) with n = 3-4, compute Φ (minimum cut) and d_FI (Fisher-Rao distance between joint and product distributions) numerically. Check whether the inequality holds.

**Impact**: If true, this embeds IIT in information geometry — one of the most elegant frameworks in mathematical statistics. Φ would acquire a geometric interpretation as a "distance from independence" on a curved statistical manifold. This would also provide natural connections to machine learning (natural gradient descent) and quantum information (quantum Fisher information).

**Catalog References**: `Novelty/IntegratedInformation/Spectrum.lean` (phi_le_totalWeight, phi_scale), `Bridges/PadicQuantumInformation.lean` (information-theoretic methods)

**Proof Strategy**:
1. Define Fisher information matrix for a causal system
2. Define the Fisher-Rao metric on the simplex of joint distributions
3. Show that the minimum cut provides an upper bound on the geodesic distance
4. Prove the lower bound using the data processing inequality

**Domain Bridges**: Information Geometry ↔ IIT ↔ Statistical Manifolds ↔ Quantum Information

**Lineage**: Builds on phi_le_totalWeight, crossInfo_le_totalWeight from this cycle; connects to `ultrametric_entropy_composition_bound` in Bridges/PadicQuantumInformation.lean.

**Ambition**: grand_challenge

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
