# Future Directions: Boundary Rigidity and Tropical Reconstruction

## Direction 1: Approximate Boundary Rigidity for δ-Hyperbolic Spaces

### Precise Theorem Statement
For δ-hyperbolic metrics (generalizing the four-point condition with error δ), if two metrics agree on boundary distances, then they agree on all distances up to error O(δ).

```
theorem approximate_boundary_rigidity
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d₁ d₂ : V → V → ℝ) (δ : ℝ)
    (hδ : 0 ≤ δ)
    (h₁hyp : IsδHyperbolic d₁ δ)
    (h₂hyp : IsδHyperbolic d₂ δ)
    (hbdry : ∀ a ∈ B, ∀ b ∈ B, d₁ a b = d₂ a b)
    (hwitness : ...) :
    ∀ x y : V, |d₁ x y - d₂ x y| ≤ C * δ
```

### Proof Strategy
- Define δ-hyperbolicity: the Gromov product inequality holds up to additive error δ.
- The median formula gives d(a,m) = (d(a,b) + d(a,c) - d(b,c))/2 ± O(δ) for approximate medians.
- Propagate errors through the reconstruction pipeline.
- The constant C should depend on the diameter/boundary-to-vertex distance ratio.

### Cross-Domain Significance
- **Geometric group theory**: δ-hyperbolic groups are fundamental; this would give metric rigidity for their Cayley graphs.
- **Network science**: Real networks are approximately tree-like (low hyperbolicity). Approximate rigidity would justify tomography algorithms for such networks.
- **Phylogenetic networks**: When evolution doesn't follow a strict tree, hyperbolicity measures the deviation. Approximate rigidity quantifies reconstruction error.

---

## Direction 2: Boundary Rigidity for Median Graphs and CAT(0) Cube Complexes

### Precise Theorem Statement
Extend boundary rigidity to **median graphs** — graphs where every triple of vertices has a unique median. These include trees, hypercubes, and products of trees.

```
theorem median_graph_boundary_rigidity
    {V : Type} [Fintype V] [DecidableEq V]
    (B : Finset V) (d₁ d₂ : V → V → ℝ)
    (hmedian₁ : IsMedianGraph d₁)
    (hmedian₂ : IsMedianGraph d₂)
    (hbdry : ∀ a ∈ B, ∀ b ∈ B, d₁ a b = d₂ a b)
    (hcoverage : AdequateBoundaryCoverage B d₁ d₂) :
    ∀ x y : V, d₁ x y = d₂ x y
```

### Proof Strategy
- Median graphs have a canonical embedding into products of trees (the Djokovic-Winkler decomposition).
- Apply tree boundary rigidity componentwise.
- The boundary coverage condition becomes: the projection of B to each tree factor must be sufficiently spread.

### Cross-Domain Significance
- **CAT(0) geometry**: Median graphs are 1-skeleta of CAT(0) cube complexes, connecting to geometric group theory.
- **Distributed computing**: Median graphs model consensus protocols where the median is the natural agreement point.
- **Tropical convexity**: Products of trees are basic objects in tropical geometry.

---

## Direction 3: Algorithmic Improvements via Persistent Homology

### Precise Theorem Statement
Develop an O(n² log n) algorithm for boundary-to-bulk reconstruction using persistent homology to identify branch points.

### Proof Strategy
- The Vietoris-Rips complex of the boundary distance matrix has persistent homology that reveals the tree structure.
- H₀ persistence gives the dendrogram (tree hierarchy).
- Branch points correspond to deaths in the H₀ barcode.
- This avoids the O(n⁴) four-point check and provides a topological certificate of tree-likeness.

### Cross-Domain Significance
- **Topological data analysis**: Connects metric reconstruction to persistent homology, a major tool in data science.
- **Computational biology**: Faster phylogenetic reconstruction with topological guarantees.
- **Machine learning**: Tree-like structure detection in high-dimensional data.

---

## Direction 4: Tropical Satake Isomorphism and Boundary Rigidity for Buildings

### Precise Theorem Statement
Extend boundary rigidity to **Bruhat-Tits buildings** of reductive groups, where the boundary is the associated flag variety and the bulk is the building itself.

```
theorem building_boundary_rigidity
    {G : Type} [ReductiveGroup G]
    (B : Building G) (∂B : FlagVariety G)
    (d₁ d₂ : B → B → ℝ)
    (hbdry : ∀ a b : ∂B, d₁ a b = d₂ a b) :
    ∀ x y : B, d₁ x y = d₂ x y
```

### Proof Strategy
- Buildings are higher-dimensional analogues of trees (they retract to trees in each apartment).
- The tropical Satake isomorphism provides a tropical coordinate chart from the building to ℝⁿ.
- Boundary data on the flag variety determines the building metric via the Cartan decomposition.
- This connects to existing catalog theorems on GL₃ tropical Satake reconstruction.

### Cross-Domain Significance
- **Representation theory**: Building geometry encodes p-adic representation theory.
- **Number theory**: Bruhat-Tits buildings appear in the Langlands program.
- **Tropical geometry**: Tropical Satake isomorphisms are bridges between representation theory and tropical geometry.

---

## Direction 5: Continuous Boundary Rigidity for ℝ-Trees

### Precise Theorem Statement
Extend the discrete theorem to continuous ℝ-trees (metric spaces where every two points are joined by a unique arc isometric to an interval).

```
theorem R_tree_boundary_rigidity
    (X : Type) [MetricSpace X] [RTreeSpace X]
    (B : Set X) (hB : IsClosed B)
    (d₁ d₂ : MetricOnX)
    (hbdry : ∀ a b ∈ B, d₁ a b = d₂ a b)
    (hreach : BoundaryReaches B d₁ ∧ BoundaryReaches B d₂) :
    d₁ = d₂
```

### Proof Strategy
- Use the characterization of ℝ-trees as 0-hyperbolic geodesic metric spaces.
- The median of three points exists and is unique; the Gromov product formula extends.
- Density arguments: if B is dense enough, boundary data determines the metric by continuity.
- Connect to Mayer-Oversteegen theory of ℝ-trees.

### Cross-Domain Significance
- **Geometric group theory**: ℝ-trees appear as asymptotic cones and limits of group actions.
- **Probability**: Continuum random trees (Aldous's CRT) are ℝ-trees; boundary rigidity could have probabilistic applications.
- **Analysis on metric spaces**: Extends the theory to infinite-dimensional settings.

---

## Team Directive

Each direction should be pursued by a team that:

1. **States precise conjectures** as formal Lean theorem statements with `sorry`.
2. **Tests computationally** with Python implementations on concrete examples.
3. **Identifies required Mathlib infrastructure** (δ-hyperbolicity, median graphs, buildings, ℝ-trees).
4. **Decomposes into lemmas** following the median → boundary-interior → bulk pipeline established in this work.
5. **Iterates** between formalization and informal proof discovery.

The established proof architecture — median formula → boundary-interior reconstruction → reach-based extension — should serve as a template for all extensions.

---

## Cross-Domain Connection Map

```
Phylogenetics ←→ BOUNDARY RIGIDITY ←→ Network Tomography
       ↑                  ↑                     ↑
       |          Tropical Geometry              |
       |                  ↑                     |
       |          Gromov Hyperbolicity           |
       ↓                  ↓                     ↓
  Evolutionary     Geometric Group      Distributed
    Biology           Theory            Computing
       ↑                  ↑                     ↑
       |          Buildings/CAT(0)               |
       ↓                  ↓                     ↓
  Persistent      Representation         Sensor
  Homology           Theory            Networks
```

Each node in this map represents a research community that would benefit from formal boundary rigidity results, and each edge represents a known mathematical connection that can carry insights between domains.
