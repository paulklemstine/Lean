# Rigorous Mathematical Foundations for the Poincaré Threshold

## Abstract

We establish rigorous mathematical foundations for the Poincaré threshold—the critical scale parameter at which a metric-indexed filtration first exhibits a target topological property. Working in the framework of pseudo-metric spaces, we formalize the Vietoris-Rips graph construction and prove its monotonicity as a filtration. We introduce the notion of a *metric filtration* as an abstract monotone family of propositions indexed by ℝ, and define the Poincaré threshold as the infimum of the level set. Our main results are: (1) a *threshold antitone principle* showing that stronger properties yield larger thresholds; (2) an *interleaving theorem* proving that δ-approximate isometries shift Rips edges by at most δ in scale; (3) a *stability theorem* showing that δ-interleaved filtrations have thresholds within δ of each other; (4) a *composition principle* for approximate isometries showing that distortions add under composition; and (5) a *covering-number bound* relating the connectivity threshold to the diameter. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

Topological data analysis (TDA) studies the shape of data by constructing simplicial complexes at varying scales and tracking topological features (connected components, loops, voids) across the resulting filtration. The Vietoris-Rips complex is the most commonly used construction: given a finite metric space (X, d) and a scale parameter ε ≥ 0, the Rips complex Rips(X, ε) is the simplicial complex whose k-simplices are (k+1)-tuples of points with all pairwise distances at most ε.

The *Poincaré threshold* for a topological property P is the critical scale ε*(P) = inf{ε ≥ 0 : P holds for Rips(X, ε)}. When P is "the Betti numbers match those of a target space M," this threshold measures the scale at which the data's topology first resembles M. The stability of ε* under metric perturbations is fundamental for statistical applications.

While stability results for persistence diagrams are well-established (the algebraic stability theorem of Chazal et al. [2009], the bottleneck stability theorem of Cohen-Steiner et al. [2007]), the specific stability of *threshold-type* invariants has received less formal attention. Our contribution is to axiomatize the threshold construction at the level of *abstract metric filtrations* and prove stability results in this generality.

### 1.1 Contributions

1. **Rips graph formalization.** We define the Rips graph as a `SimpleGraph` in Mathlib's combinatorics library and prove its monotonicity.

2. **Abstract metric filtrations.** We introduce `MetricFiltration` as a structure pairing a predicate `ℝ → Prop` with a monotonicity proof. This abstracts Rips, Čech, alpha, and witness complexes.

3. **Threshold functional.** We define the threshold as `sInf` of the level set and prove its fundamental properties: antitony under domination, equivariance under shifts, and Lipschitz continuity under interleaving.

4. **Approximate isometry theory.** We formalize δ-approximate isometries as a structure, prove the interleaving theorem (Theorem 3), and prove the composition principle (Theorem 5).

5. **Machine verification.** All results are verified in Lean 4 with Mathlib, with clean axiom usage.

## 2. Definitions

### 2.1 Rips Graph

**Definition 1** (Rips Graph). Let (α, d) be a pseudo-metric space and ε ∈ ℝ. The *Rips graph* Rips(α, ε) is the simple graph on vertex set α where x ~ y iff x ≠ y and d(x, y) ≤ ε.

In our formalization:
```
def ripsGraph (α : Type*) [PseudoMetricSpace α] (ε : ℝ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ dist x y ≤ ε
```

### 2.2 Approximate Isometry

**Definition 2** (δ-Approximate Isometry). A function f : α → β between pseudo-metric spaces is a *δ-approximate isometry* (δ ≥ 0) if for all x, y ∈ α:

|d_β(f(x), f(y)) − d_α(x, y)| ≤ δ

This captures the notion of a map that distorts distances by at most δ uniformly.

### 2.3 Metric Filtration

**Definition 3** (Metric Filtration). A *metric filtration* is a pair (P, mono) where P : ℝ → Prop and mono : ∀ ε₁ ε₂, ε₁ ≤ ε₂ → P(ε₁) → P(ε₂).

**Definition 4** (Threshold). The *threshold* of a metric filtration (P, mono) is τ(P) = inf{ε ∈ ℝ : P(ε)}.

**Definition 5** (Shift). The *δ-shift* of a filtration (P, mono) is the filtration P^δ(ε) = P(ε − δ).

**Definition 6** (Domination). Filtration F *dominates* G if F.property(ε) → G.property(ε) for all ε.

### 2.4 ε-Covering

**Definition 7** (ε-Covering). A finite set S ⊂ α is an *ε-covering* if for every x ∈ α, there exists s ∈ S with d(x, s) ≤ ε.

## 3. Main Results

### 3.1 Rips Monotonicity

**Theorem 1** (Rips Monotonicity). If ε₁ ≤ ε₂, then Rips(α, ε₁) ≤ Rips(α, ε₂) as simple graphs.

*Proof sketch.* If x ~ y in Rips(α, ε₁), then x ≠ y and d(x, y) ≤ ε₁ ≤ ε₂, so x ~ y in Rips(α, ε₂). □

### 3.2 Interleaving Theorem

**Theorem 2** (Interleaving). Let f : α → β be an injective δ-approximate isometry. If x ~ y in Rips(α, ε), then f(x) ~ f(y) in Rips(β, ε + δ).

*Proof sketch.* From the adjacency condition, x ≠ y and d(x,y) ≤ ε. Injectivity gives f(x) ≠ f(y). The distortion bound gives d(f(x), f(y)) ≤ d(x,y) + δ ≤ ε + δ. □

This theorem is the foundation of all stability results: it shows that approximate isometries shift the Rips filtration by at most δ in scale.

### 3.3 Threshold Antitone Principle

**Theorem 3** (Threshold Antitone). If F dominates G and {ε : F.property(ε)} is nonempty and {ε : G.property(ε)} is bounded below, then τ(G) ≤ τ(F).

*Proof sketch.* Since F dominates G, {ε : F.property(ε)} ⊆ {ε : G.property(ε)}. The infimum of a superset is at most the infimum of a subset (csInf_le_csInf). □

### 3.4 Threshold Shift

**Theorem 4** (Threshold Shift). τ(P^δ) = τ(P) + δ when the level set of P is nonempty and bounded below.

*Proof sketch.* The level set {ε : P^δ(ε)} = {ε : P(ε − δ)} = {ε + δ : P(ε)} is the translation of {ε : P(ε)} by δ. The infimum of a translated set equals the original infimum plus the translation. □

### 3.5 Stability Theorem

**Theorem 5** (Stability). Let F, G be metric filtrations with δ-interleaving: F^δ dominates G and G^δ dominates F. Then |τ(F) − τ(G)| ≤ δ.

*Proof sketch.* From F^δ dominating G and Theorem 3: τ(G) ≤ τ(F^δ) = τ(F) + δ (by Theorem 4). Symmetrically, τ(F) ≤ τ(G) + δ. Together: |τ(F) − τ(G)| ≤ δ. □

### 3.6 Composition Principle

**Theorem 6** (Composition). If f is a δ₁-approximate isometry and g is a δ₂-approximate isometry, then g ∘ f is a (δ₁ + δ₂)-approximate isometry.

*Proof sketch.* For any x, y:
|d(g(f(x)), g(f(y))) − d(x,y)| ≤ |d(g(f(x)), g(f(y))) − d(f(x), f(y))| + |d(f(x), f(y)) − d(x,y)| ≤ δ₂ + δ₁. □

### 3.7 Covering-Diameter Connectivity

**Theorem 7** (Covering-Diameter Connectivity). If diam(X) ≤ 2ε for a finite metric space X, then Rips(X, 2ε) is connected.

*Proof sketch.* For any x, y ∈ X: if x = y, the trivial walk connects them; if x ≠ y, then d(x,y) ≤ 2ε gives an edge in Rips(X, 2ε). □

### 3.8 Edge Count Monotonicity

**Theorem 8** (Edge Count Monotonicity). For finite metric spaces, the edge count |E(Rips(X, ε))| is monotonically non-decreasing in ε.

*Proof sketch.* The filter set at ε₁ is a subset of the filter set at ε₂ when ε₁ ≤ ε₂, so the cardinality is non-decreasing. □

### 3.9 One-Sided Stability

**Theorem 9** (Threshold Shift Bound). If F.property(ε) → G.property(ε + δ) for all ε, then τ(G) ≤ τ(F) + δ.

*Proof sketch.* The hypothesis implies F^δ dominates G (since F.property(ε − δ) → G.property(ε)). By Theorems 3 and 4: τ(G) ≤ τ(F^δ) = τ(F) + δ. □

## 4. Algorithms

### 4.1 Connectivity Threshold

The connectivity threshold can be computed exactly using a minimum spanning tree:

1. Compute all pairwise distances.
2. Build the MST using Kruskal's algorithm.
3. The connectivity threshold equals the maximum edge weight in the MST.

Time complexity: O(n² log n) for n points.

### 4.2 Covering-Based Approximation

For large datasets, the greedy covering algorithm provides an O(n log n) approximation:

1. Compute a greedy ε-cover of the data.
2. Compute the connectivity threshold of the cover.
3. By the stability theorem, the true threshold is within ε of the cover's threshold.

## 5. Discussion

### 5.1 Relation to Persistence Stability

The classical stability theorem for persistence diagrams states that the bottleneck distance between persistence diagrams is bounded by the Gromov-Hausdorff distance between the underlying spaces. Our threshold stability theorem (Theorem 5) can be seen as a *scalar projection* of this result: instead of tracking the full persistence diagram, we track a single scalar (the threshold) and obtain a simpler, sharper bound.

### 5.2 Abstract Filtration Framework

The key insight of this work is that many results in persistent homology stability can be proved at the level of abstract metric filtrations, without reference to specific constructions (Rips, Čech, alpha). The `MetricFiltration` structure captures the essential property—monotonicity—and the threshold functional captures the essential invariant—the first appearance of a feature.

### 5.3 Limitations

The current framework addresses only *threshold-type* invariants (infima of level sets). It does not capture the full richness of persistence diagrams, which track birth-death pairs. Extending the abstract filtration framework to handle paired thresholds is a natural next step.

## 6. Future Work

1. **Quantitative stability bounds.** Determine tight constants in the stability inequality, depending on the geometry of the underlying space (e.g., curvature, dimension).

2. **Higher-dimensional thresholds.** Extend from connectivity (β₀) to loop formation (β₁) and higher Betti numbers.

3. **Statistical theory.** Derive the asymptotic distribution of the Poincaré threshold for random point clouds, enabling hypothesis testing.

4. **Efficient computation.** Develop subquadratic algorithms for threshold approximation using spatial data structures and random sampling.

## 7. References

- Chazal, F., Cohen-Steiner, D., Glisse, M., Guibas, L. J., & Oudot, S. Y. (2009). Proximity of persistence modules and their diagrams. *Proceedings of SCG*.
- Cohen-Steiner, D., Edelsbrunner, H., & Harer, J. (2007). Stability of persistence diagrams. *Discrete & Computational Geometry*, 37(1), 103-120.
- Edelsbrunner, H., & Harer, J. (2010). *Computational Topology: An Introduction*. AMS.
- Carlsson, G. (2009). Topology and data. *Bulletin of the AMS*, 46(2), 255-308.
- Vietoris, L. (1927). Über den höheren Zusammenhang kompakter Räume und eine Klasse von zusammenhangstreuen Abbildungen. *Math. Annalen*, 97, 454-472.
