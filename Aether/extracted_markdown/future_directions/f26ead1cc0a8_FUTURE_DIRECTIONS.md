# Future Directions: Tropical Radon Transform Duality

## Overview

This file establishes the first formally verified tropical tomography duality for star trees. The following directions extend this foundation toward a complete theory of tropical integral geometry on finite metric graphs.

---

## Direction 1: Extension from Star Trees to General Finite Trees

**Status**: Ready for immediate formalization

**Goal**: Extend the duality from star trees (depth-1 trees) to arbitrary finite weighted trees.

**Key Theorem Target**:
```
theorem generalTree_reconstruction_certified (n : ℕ)
    (d : Fin n → Fin n → ℕ)
    (hmetric : FiniteMetric d)
    (hfourPt : FourPointCondition d) :
    ∃ T : RootedWeightedTree, tropicalRadonData T = d
```

**Proof Strategy**:
1. Define a general rooted weighted tree with parent pointers and well-founded depth recursion.
2. Define the LCA (lowest common ancestor) function using ancestor sets.
3. Express distance as `d(u,v) = depth(u) + depth(v) - 2 · depth(lca(u,v))`.
4. Prove that the four-point condition is equivalent to tree realizability (Buneman's theorem, 1974).
5. Construct the tree from distance data using the neighbor-joining or Prüfer-like algorithm.

**Mathematical Insight**: The four-point condition `d(x,y)+d(z,w) ≤ max(d(x,z)+d(y,w), d(x,w)+d(y,z))` is both necessary and sufficient for tree realizability. The tree can be recovered by identifying "splits" — bipartitions of the vertex set where the four-point condition is tight.

**Estimated Effort**: Medium. The reconstruction algorithm is well-understood (Buneman, Dress, etc.) but the Lean formalization requires careful handling of induction on tree structure.

---

## Direction 2: Cactus Graph Extension and Tropical Sheaf Exactness

**Status**: Requires new infrastructure

**Goal**: Extend from trees to cactus graphs (graphs where every edge belongs to at most one simple cycle).

**Key Definition**:
```
structure CactusGraph (n : ℕ) where
  vertices : Fin n
  edges : Finset (Fin n × Fin n)
  edgeWeights : (Fin n × Fin n) → ℕ
  cactus_property : ∀ e, e ∈ edges → (number of simple cycles containing e) ≤ 1
```

**Key Theorem Target**:
```
theorem cactus_radon_duality :
    ∃ (admissibility : DistanceMatrix → Prop),
      (∀ G : CactusGraph, admissibility (radonData G)) ∧
      (∀ d, admissibility d → ∃ G, radonData G = d) ∧
      (∀ d G₁ G₂, admissibility d → radonData G₁ = d → radonData G₂ = d → G₁ ≃ G₂)
```

**Proof Strategy**: The characterization involves a "relaxed four-point condition" — the four-point condition may fail, but only in a way consistent with the presence of exactly one cycle through the relevant vertices. The admissibility predicate requires:
- The metric axioms (as for trees)
- A modified four-point condition allowing failures of a specific cycle-consistent pattern
- A "girth condition" bounding the minimal cycle length

**Cross-Domain Impact**: Cactus graphs appear naturally in phylogenetic network reconstruction when hybridization events create reticulate evolutionary patterns.

---

## Direction 3: Stability of Reconstruction Under Perturbation

**Status**: Requires analysis infrastructure

**Goal**: Prove that small perturbations of the distance matrix lead to small changes in the reconstructed tree.

**Key Theorem Target**:
```
theorem reconstruction_stability (d₁ d₂ : Option (Fin n) → Option (Fin n) → ℕ)
    (hd₁ : AdmissibleRadon d₁) (hd₂ : AdmissibleRadon d₂)
    (hclose : ∀ u v, |d₁ u v - d₂ u v| ≤ ε) :
    ∀ i, |reconstructWeights d₁ i - reconstructWeights d₂ i| ≤ ε
```

**Mathematical Insight**: For star trees, this is immediate since reconstruction reads off root-to-leaf distances directly. For general trees, stability requires controlling the propagation of errors through the LCA computation, which involves the "robust four-point condition" — a quantitative version where the margin of the inequality determines the reconstruction accuracy.

**Applications**:
- **Network tomography**: Real network measurements are noisy; stability guarantees that the reconstructed topology is close to the true topology.
- **Phylogenetic inference**: Gene sequence distances have statistical error; stability bounds give confidence intervals on reconstructed evolutionary trees.
- **Sensor network localization**: Distance measurements between sensors have measurement error; stability bounds give accuracy guarantees for network reconstruction.

---

## Direction 4: Higher-Dimensional Tropical Cell Complex Tomography

**Status**: Long-term research direction

**Goal**: Extend from 1-dimensional metric graphs to higher-dimensional tropical polyhedral complexes.

**Key Concept**: A tropical polyhedral complex is a finite CW complex where each cell is a tropical polytope (defined by min-plus linear inequalities). The "tropical Radon data" becomes the collection of tropical distances between faces of different dimensions.

**Key Theorem Target**:
```
theorem tropical_complex_reconstruction (K : TropicalComplex)
    (hdata : TropicalRadonData K) :
    ∃! K', TropicalRadonData K' = hdata ∧ K' is minimal
```

**Mathematical Insight**: The reconstruction of a tropical complex from its face-distance data generalizes tree metric reconstruction. The key new ingredient is the "tropical Poincaré duality" — a relationship between the tropical homology of the complex and the structure of the Radon data semimodule.

**Connections**:
- **Tropical persistent homology**: The distance data induces a filtration whose persistent homology captures topological features of the complex.
- **Optimal transport**: Tropical complexes arise as limit objects in the tropicalization of optimal transport problems.

---

## Direction 5: Tropical Spectrum and Idempotent Functional Analysis

**Status**: Conceptual, requires significant new theory

**Goal**: Develop a "tropical spectral theory" where the graph is recovered as the spectrum of its tropical Radon semimodule.

**Key Definition**:
```
def tropicalSpectrum (M : TropicalSemimodule) : Type :=
  { φ : M →ₜ ℕ∞ // φ is extremal (join-irreducible) }
```

**Key Theorem Target**:
```
theorem spectrum_recovers_graph (T : StarTreeData n) :
    tropicalSpectrum (radonSemimodule T) ≃ Option (Fin n)
```

**Mathematical Insight**: In classical functional analysis, the Gelfand spectrum of a commutative C*-algebra recovers the underlying topological space. The tropical analogue should recover the metric graph from the "tropical spectrum" of its Radon semimodule — the set of extremal (join-irreducible) tropical linear functionals. Each vertex of the graph corresponds to an extremal evaluation functional.

**Impact**: This would establish a tropical analogue of the Gelfand–Naimark theorem, creating a new bridge between:
- Tropical geometry and functional analysis
- Idempotent mathematics and operator algebras
- Combinatorial optimization and spectral theory

---

## Cross-Domain Connections

### Network Tomography
The tropical Radon transform formalizes the inverse problem of reconstructing a network from end-to-end path measurements. The certified reconstruction theorem provides provable guarantees for network inference.

### Phylogenetic Reconstruction
Tree metrics are the mathematical foundation of phylogenetics. The four-point condition characterizes exactly when distance data arises from an evolutionary tree, and the reconstruction theorem provides a canonical minimal tree.

### Idempotent Signal Recovery
The tropical semimodule structure on distance matrices provides a framework for signal recovery in min-plus algebra, with applications to scheduling, discrete optimization, and max-plus control theory.

### Tropical Persistent Geometry
The filtration induced by distance data connects to persistent homology and topological data analysis, suggesting a "tropical persistence" theory where barcodes arise from min-plus algebraic structure.
