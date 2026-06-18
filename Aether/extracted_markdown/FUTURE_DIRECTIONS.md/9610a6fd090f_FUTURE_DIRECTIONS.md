# Future Research Directions

## Synthesis

This research cycle established the foundational structural theorems for categorical physics: the (2,∞)-necessity theorem showing any unified theory must have at least two nontrivial categorical levels, the computability threshold proving that dimension 4 is the exact boundary between computable and non-computable physics, and the defect CPT theorem generalizing particle-antiparticle duality to arbitrary codimension. The key cross-domain connection is between **computability theory** and **higher category theory**: the oracle hierarchy indexed by dimension creates a bridge between Turing degree theory and the classification of topological field theories.

The most promising direction for breakthrough lies in the intersection of defect towers and anomaly data. The anomaly cascade theorem shows that consistency of anomalies propagates downward through dimensions, but the *converse* — whether anomaly freedom at all lower dimensions forces anomaly freedom at a given dimension — remains open. A proof or disproof would directly constrain which physical theories can exist and would connect to the Green-Schwarz anomaly cancellation mechanism in string theory.

The dimensional ladder theorems reveal a rigid structure: any sequence of compactifications starting from dimension ≥ 4 necessarily passes through the computability barrier. This connects the Catalog's existing oracle hierarchy work (`Algebra/OptimalComputer.lean`) with the physics of dimensional reduction, creating a genuine bridge between computability and physics.

---

### Direction 1: Classification of Shadow Sets by Stable Level

**Conjecture**: For a dualizable tower with stable level k and maximal nontriviality (every level below k is nontrivial), the shadow set equals {TQFT} for k=1, {TQFT, CFT, String} for k=2, and {TQFT, CFT, String, Gravity} for k≥3. Moreover, these are the *only* possible maximal shadow sets.

**Test**: Enumerate all subsets of {TQFT, CFT, String, Gravity} and determine which can arise as shadow sets of towers with given stable level. The conjecture predicts that shadow sets are totally ordered by inclusion, with no "incomparable" pairs.

**Impact**: If true, this establishes a complete classification of physical theory types by categorical depth — a periodic table of physics. If false, there exist exotic theories that mix gravitational and topological features in unexpected ways.

**Catalog References**: `Physics/CategoricalPhysics/Theorems.lean` (shadow_completeness, dimension_gap, spectrum_gravity_implies_all)

**Proof Strategy**: Extend the PhysicalTheoryCandidate structure with nontriviality axioms for CFT and Gravity shadow types (analogous to existing axioms for TQFT and String). Then prove the classification by case analysis on stable level. The key lemma: "if Gravity ∈ shadows then ¬Subsingleton(Obj 2)" must be added as an axiom and its consequences traced.

**Domain Bridges**: Computability ↔ Physics (oracle level determines which shadow sets are computable)

**Lineage**: Builds on two_infinity_necessity, shadow_completeness, dimension_gap from this cycle.

**Ambition**: extension

---

### Direction 2: Anomaly Completeness and the Green-Schwarz Mechanism

**Conjecture**: In a consistent anomaly tower, if the anomaly vanishes at all dimensions k ≤ d, then it vanishes at dimension d+1 if and only if a specific cohomological obstruction (the "anomaly polynomial") is exact.

**Test**: Construct a concrete anomaly tower modeling the Type I string theory anomaly cancellation. The anomaly groups should be Z at each dimension, with the interplay map given by the index of the Dirac operator. Verify that the 10-dimensional anomaly vanishes iff the gauge group is SO(32) or E₈ × E₈.

**Impact**: A formalization of the Green-Schwarz mechanism would be a landmark in mathematical physics, providing the first machine-verified proof that anomaly cancellation forces the gauge group. This would directly connect to the Catalog's algebra infrastructure.

**Catalog References**: `Physics/CategoricalPhysics/Defs.lean` (ConsistentAnomalyData), `Algebra/Advanced.lean`

**Proof Strategy**: 
1. Define an "anomaly polynomial" as an element of a polynomial ring over the anomaly groups.
2. Prove that the interplay map factors through the anomaly polynomial.
3. Show that exactness of the polynomial is equivalent to vanishing of the anomaly.
4. For the Type I string case, reduce to a computation in the representation ring of SO(32).

**Domain Bridges**: Algebra (representation theory) ↔ Physics (anomaly cancellation) ↔ Computation (decidability of anomaly constraints)

**Lineage**: Builds on ConsistentAnomalyData and anomaly_cascade from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Oracle Hierarchy Embedding in TQFT Amplitudes

**Conjecture**: The oracle hierarchy σ_d = max(0, d-3) can be *realized* by explicit TQFTs: for each d ≥ 4, there exists a TQFT in dimension d whose amplitude computation is Σ^(d-3)-complete but not Σ^(d-2)-complete.

**Test**: Construct TQFTs in dimensions 4 and 5 whose amplitudes encode, respectively, the halting problem (Σ¹) and the halting-of-halting problem (Σ²). The dimension-4 construction should use Markov's theorem: the TQFT assigns to each 3-manifold M the truth value of "M bounds a topological 4-manifold with a given fundamental group presentation." The dimension-5 case should use iterated oracle machines.

**Impact**: This would establish a *tight* connection between the oracle hierarchy in computability theory and the computational complexity of TQFTs, showing our oracle level formula is not merely a bound but an exact characterization.

**Catalog References**: `Computation/GravityOracle.lean` (IsGravOracle, GravTruthSet), `Algebra/OptimalComputer.lean` (OracleHierarchy, god_oracle_contains_all)

**Proof Strategy**:
1. Formalize Markov's theorem: every finitely presented group is the fundamental group of a closed 4-manifold.
2. Build a TQFT whose state space on S³ encodes halting information.
3. Prove completeness using a reduction from the word problem.
4. For the upper bound, show the amplitude can be computed with a Σ¹ oracle.

**Domain Bridges**: Computation (oracle hierarchy) ↔ Physics (TQFT amplitudes) ↔ Algebra (group presentations)

**Lineage**: Builds on tqftOracleLevel, computability_threshold, oracle_unbounded, and the Catalog's OracleHierarchy.

**Ambition**: grand_challenge

---

### Direction 4: Topological Defect Fusion Categories

**Conjecture**: Every topological defect tower in dimension d naturally gives rise to d+1 fusion categories (one at each codimension), and these fusion categories are related by a "Drinfeld center" operation: the fusion category at codimension k is the Drinfeld center of the fusion category at codimension k+1.

**Test**: In dimension 2, construct a topological defect tower whose codimension-0 fusion category is Vec (vector spaces), codimension-1 is a modular tensor category C, and codimension-2 is Z(C) (the Drinfeld center). Verify that Z(Vec) = Vec and Z(C) recovers the expected doubled theory.

**Impact**: This would formalize the "bulk-boundary correspondence" — the deep physical principle that the boundary theory of a (d+1)-dimensional topological theory is a d-dimensional theory with one higher level of categorical structure.

**Catalog References**: `Physics/CategoricalPhysics/Defs.lean` (TopologicalDefectTower), `Physics/CategoricalPhysics/Theorems.lean` (topological_bar_is_homomorphism, bar_trivial)

**Proof Strategy**:
1. Define fusion categories as TopologicalDefectTowers with additional rigidity data (associator, braiding).
2. Construct the Drinfeld center Z(C) as a specific defect tower.
3. Prove the center construction gives a topological defect tower.
4. Show condensation maps correspond to the forgetful functor from Z(C) to C.

**Domain Bridges**: Algebra (fusion categories) ↔ Physics (topological phases) ↔ Computation (quantum computing with anyons)

**Lineage**: Builds on TopologicalDefectTower, topological_bar_is_homomorphism, and defect fusion algebra results.

**Ambition**: extension

---

### Direction 5: Compactification Composition and the M-Theory Landscape

**Conjecture**: The composition of compactification functors is associative up to natural isomorphism: compactifying on a torus T² (= S¹ × S¹) gives the same result (up to equivalence) as compactifying twice on S¹.

**Test**: Formalize a CompactificationData for the simplest nontrivial case: the 3d → 2d compactification of Chern-Simons theory on S¹. Verify that the resulting 2d theory is a 2d TQFT (Dijkgraaf-Witten model). Then compose with the 2d → 1d compactification and compare with direct 3d → 1d compactification.

**Impact**: Formalizing the composition law for compactifications would give a rigorous foundation for the "landscape" of string theory vacua — the vast collection of lower-dimensional theories obtained by different compactification choices.

**Catalog References**: `Physics/CategoricalPhysics/Defs.lean` (CompactificationData), `Physics/CategoricalPhysics/Theorems.lean` (compactification_functorial, compactification_preserves_involution)

**Proof Strategy**:
1. Define composition of CompactificationData as sequential application of reduce maps.
2. Prove the composed reduction preserves all categorical structure.
3. For the torus case, construct the product compactification and show equivalence.
4. Verify on the Chern-Simons → Dijkgraaf-Witten example.

**Domain Bridges**: Physics (string landscape) ↔ Geometry (fiber bundles, torus fibrations) ↔ Algebra (modular representations)

**Lineage**: Builds on CompactificationData, compactification_functorial, and the dimensional ladder theorems.

**Ambition**: extension
