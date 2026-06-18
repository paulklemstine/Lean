# Future Directions: Tropical Discrete Relativity

## Roadmap for Breakthrough Research in Tropical Spacetime Geometry

This document describes 5 concrete, actionable research directions opened by the formalization of tropical wormhole surgery. Each direction includes specific theorem targets, proof strategies, and cross-domain connections. These are not metaphors — they are theorem factories.

---

## Direction 1: Tropical Causal Cones and Lightlike Reachability

### Hypothesis
In a weighted spacetime graph with two classes of edges (timelike = finite cost, spacelike = infinite sentinel), the set of vertices reachable from a source within cost budget `T` forms a "tropical causal cone" that obeys discrete analogues of causal structure axioms.

### Key Definitions to Formalize
```
def causalCone (W : Matrix (Fin n) (Fin n) ℝ) (source : Fin n) (T : ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun v => tropicalDistance W source v ≤ T)

def lightCone (W : Matrix (Fin n) (Fin n) ℝ) (source : Fin n) (T : ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun v => tropicalDistance W source v = T)
```

### Theorem Targets
1. **Monotonicity**: `T₁ ≤ T₂ → causalCone W s T₁ ⊆ causalCone W s T₂`
2. **Transitivity**: If `v ∈ causalCone W s T₁` and `w ∈ causalCone W v T₂`, then `w ∈ causalCone W s (T₁ + T₂)` (triangle inequality).
3. **Surgery enlargement**: Wormhole surgery strictly enlarges the causal cone: `causalCone W s T ⊂ causalCone (wormholeSurgery W u v τ) s T` under appropriate conditions.
4. **Chronological ordering**: Define a partial order from tropical distances and show it satisfies antisymmetry for nonneg-weight graphs with no negative cycles.

### Proof Strategy
Use the triangle inequality for tropical distance (which follows from path concatenation) and the surgery distance-drop theorem already proved.

### Cross-Domain Connections
- Causal set theory in quantum gravity
- Reachability analysis in timed automata
- Network influence propagation bounds

---

## Direction 2: Tropical Black Hole Horizons as Min-Cut Barriers

### Hypothesis
A "tropical event horizon" is a min-cut in the weighted spacetime graph separating an interior region from an exterior region. The horizon's "area" (total cut weight) controls the maximum information throughput, yielding a discrete analogue of the Bekenstein–Hawking area-entropy bound.

### Key Definitions to Formalize
```
def tropicalHorizon (W : Matrix (Fin n) (Fin n) ℝ) (interior exterior : Finset (Fin n)) : ℝ :=
  -- Min-cut value between interior and exterior
  sInf { c | ∃ (cut : Finset (Fin n × Fin n)),
    (∀ p : path from interior to exterior, ∃ e ∈ cut, e on p) ∧
    c = ∑ e in cut, W e.1 e.2 }

def tropicalEntropy (W : Matrix (Fin n) (Fin n) ℝ) (region : Finset (Fin n)) : ℝ :=
  Real.log (region.card) * tropicalHorizon W region (Finset.univ \ region)
```

### Theorem Targets
1. **Max-flow min-cut duality**: The maximum number of edge-disjoint paths from interior to exterior equals the min-cut (discrete max-flow min-cut theorem).
2. **Horizon monotonicity under surgery**: Adding a wormhole bridge that crosses the horizon strictly increases the min-cut value.
3. **Area-entropy bound**: `tropicalEntropy ≤ C * horizonArea` for an explicit constant `C`.
4. **Horizon stability**: Small perturbations of edge weights produce small changes in the horizon location (Lipschitz stability).

### Proof Strategy
Leverage Mathlib's existing graph theory for max-flow min-cut. The tropical entropy bound should follow from counting arguments and the min-cut structure.

### Cross-Domain Connections
- Bekenstein–Hawking entropy in black hole thermodynamics
- Network reliability and fault tolerance
- Information-theoretic security (wiretap channels)
- Ryu–Takayanagi formula in holographic entanglement entropy

---

## Direction 3: Tropical Einstein–Maxwell Systems on Weighted Graphs

### Hypothesis
Extend the tropical Einstein equation to include a "gauge field" (a second weight matrix `A : Matrix (Fin n) (Fin n) ℝ` representing electromagnetic potential). The coupled system has a min-plus fixed-point characterization where charged geodesics minimize `W + q·A` for charge `q`.

### Key Definitions to Formalize
```
def chargedWeight (W A : Matrix (Fin n) (Fin n) ℝ) (q : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => W i j + q * A i j

def TropicalEinsteinMaxwell (W A : Matrix (Fin n) (Fin n) ℝ) (source : Fin n) (q : ℝ)
    (Φ : Fin n → ℝ) : Prop :=
  Φ source = 0 ∧
  ∀ x, x ≠ source → Φ x = Finset.inf' Finset.univ Finset.univ_nonempty
    (fun y => Φ y + (W y x + q * A y x))
```

### Theorem Targets
1. **Reduction to standard Bellman**: `TropicalEinsteinMaxwell W A s q Φ ↔ TropicalEinsteinEquation (chargedWeight W A q) s Φ`
2. **Charge-reversal symmetry**: The tropical distance in `chargedWeight W A q` relates to that in `chargedWeight W A (-q)` via the transpose.
3. **Lorentz force analogue**: The difference `tropicalDistance (chargedWeight W A q) s t - tropicalDistance W s t` is bounded by `|q| * maxA * pathLength`, giving a discrete analogue of the Lorentz force deflection.
4. **Gauge invariance**: Adding a "pure gauge" `A i j = φ j - φ i` does not change charged tropical distances.

### Proof Strategy
Most results reduce to properties of the standard tropical Einstein equation via the chargedWeight substitution. Gauge invariance follows from telescoping sums along paths.

### Cross-Domain Connections
- Electromagnetic geodesics in general relativity
- Pricing with transaction costs in financial networks
- Weighted routing with toll roads
- Magnetic Laplacians on graphs

---

## Direction 4: Categorical Functor from Graph Surgeries to Tropical Linear Operators

### Hypothesis
Graph surgeries (edge insertions, deletions, weight modifications) form a category where objects are weighted graphs and morphisms are surgery operations. There exists a functor from this category to the category of min-plus linear operators (tropical matrices under min-plus multiplication), mapping each surgery to a rank-1 tropical update.

### Key Definitions to Formalize
```
structure WeightedGraphMorphism (n : ℕ) where
  source target : Matrix (Fin n) (Fin n) ℝ
  surgery : Fin n × Fin n  -- the modified edge
  newWeight : ℝ

def tropicalMatrixPower (W : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  -- min-plus matrix power: (W^k)_ij = min over all k-step paths from i to j

def surgeryToUpdate (m : WeightedGraphMorphism n) : Matrix (Fin n) (Fin n) ℝ :=
  -- The rank-1 tropical perturbation matrix
```

### Theorem Targets
1. **Functoriality**: Composition of surgeries maps to min-plus multiplication of update matrices.
2. **Rank-1 structure**: A single wormhole surgery corresponds to a rank-1 tropical matrix update, enabling efficient recomputation of all-pairs shortest paths.
3. **Kleene star update**: The tropical closure (all-pairs shortest paths) of the surgered graph equals a specific algebraic expression involving the original closure and the surgery parameters.
4. **Idempotent convergence**: The sequence of tropical matrix powers `W, W², W³, ...` stabilizes at `W^(n-1)` for n-vertex graphs (Kleene star finiteness).

### Proof Strategy
Use the connection between tropical matrix multiplication and min-plus path composition. The rank-1 update formula is the tropical analogue of the Sherman–Morrison formula.

### Cross-Domain Connections
- Tropical linear algebra and the Kleene star
- Dynamic graph algorithms (incremental shortest paths)
- Operadic composition in higher algebra
- Transfer matrix methods in statistical physics

---

## Direction 5: Tropical Holography via Boundary Distance Reconstruction

### Hypothesis
A weighted graph's internal structure can be reconstructed (up to isomorphism) from the boundary-to-boundary tropical distance matrix. This is a discrete analogue of boundary rigidity / the Gel'fand inverse problem, and in the context of tropical discrete relativity, it realizes holographic reconstruction: the bulk geometry is determined by boundary data.

### Key Definitions to Formalize
```
def boundaryDistanceMatrix (W : Matrix (Fin n) (Fin n) ℝ) (boundary : Finset (Fin n)) :
    boundary → boundary → ℝ :=
  fun i j => tropicalDistance W i j

def tropicalBulkReconstruction (bdryDist : Fin k → Fin k → ℝ) : 
    -- Reconstruct a weighted graph whose boundary distances match bdryDist
    Matrix (Fin m) (Fin m) ℝ := ...
```

### Theorem Targets
1. **Boundary determines bulk distances**: If two graphs with the same vertex set and boundary have identical boundary distance matrices, their interior tropical distances agree (under tree-like or uniqueness conditions).
2. **Reconstruction algorithm**: Given a boundary distance matrix satisfying metric properties, construct a graph (tree or series-parallel graph) realizing those distances, with explicit complexity bounds.
3. **Surgery detection from boundary**: A wormhole surgery in the bulk creates a detectable signature in the boundary distance matrix (at least one boundary-to-boundary distance strictly decreases).
4. **Entanglement wedge**: The "entanglement wedge" of a boundary region B is the set of bulk vertices whose tropical distance to B is minimized compared to the complement, and surgery inside the wedge is detectable from B.

### Proof Strategy
For tree-like graphs, use the four-point condition for tree metrics and the Buneman reconstruction. For general graphs, the problem is related to metric embedding theory. The surgery detection theorem follows from the triangle inequality and the surgery distance-drop result.

### Cross-Domain Connections
- AdS/CFT correspondence and holographic entanglement
- Boundary rigidity (Gel'fand, Michel, Pestov–Uhlmann)
- Phylogenetic tree reconstruction in computational biology
- Network tomography and internet distance estimation
- Seismic inverse problems (travel time tomography)

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Causal Cones | Low | High | Current work (direct extension) |
| 2. Black Hole Horizons | Medium | Very High | Max-flow min-cut in Mathlib |
| 3. Einstein–Maxwell | Low | Medium | Current work (substitution) |
| 4. Categorical Functor | High | High | Tropical matrix algebra |
| 5. Holography | Very High | Very High | Metric reconstruction theory |

**Recommended sequence**: 1 → 3 → 2 → 4 → 5

Directions 1 and 3 can be started immediately with minimal additional infrastructure. Direction 2 requires developing min-cut machinery but has the highest conceptual payoff. Direction 4 requires building tropical matrix algebra but enables computational applications. Direction 5 is the most ambitious and represents a long-term research program.

---

## Cross-Cutting Themes

All five directions share common mathematical infrastructure:
- **Tropical distance as a functor**: tropicalDistance is a natural transformation from weighted graphs to metric spaces.
- **Surgery as perturbation**: All surgery operations are rank-1 or rank-2 perturbations of the weight matrix.
- **Bellman optimality as a universal principle**: Every "field equation" reduces to a min-plus fixed-point condition.
- **Polynomial-time computability**: Every physically meaningful quantity is computable by Bellman–Ford-style algorithms.

These themes suggest that tropical discrete relativity is not a collection of isolated results but a coherent mathematical framework with deep structural unity.
