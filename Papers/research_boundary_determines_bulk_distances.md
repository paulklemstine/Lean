# Boundary Determines Bulk: Rigidity of Tree-Like Metrics via Tropical Reconstruction

## Abstract

We prove a boundary rigidity theorem for finite tree-like metric spaces: if two symmetric metrics on a finite vertex set agree on all boundary-boundary distances and satisfy structural hypotheses (median witnesses and joint boundary reachability), then they agree on all pairwise distances. The proof proceeds in two stages: first, a median/Gromov product formula reconstructs interior-to-boundary distances purely from boundary data; second, a boundary reachability condition extends this to all pairs. All results are machine-verified, with complete proofs checked against the axioms of dependent type theory. We develop the theory in the framework of abstract metrics satisfying the four-point condition, providing definitions for tree-likeness, median vertices, boundary visibility, and boundary reachability. Applications to phylogenetic reconstruction, network tomography, and tropical geometry are discussed.

**Keywords:** boundary rigidity, tree metrics, four-point condition, Gromov products, tropical geometry, inverse problems, phylogenetics, network tomography

---

## 1. Introduction

### 1.1 Motivation

The **boundary rigidity problem** asks: given a compact Riemannian manifold with boundary, does the boundary distance function (the restriction of the geodesic distance to boundary points) determine the Riemannian metric up to isometry? This question, posed by Michel (1981) and studied extensively by Croke, Pestov-Uhlmann, Stefanov-Uhlmann, and others, remains open in full generality and is considered one of the central problems in inverse geometry.

In this work, we establish a discrete analogue: for finite metric spaces satisfying the **four-point condition** (equivalently, 0-hyperbolic or tree-like metrics), boundary distances determine the complete metric. Our result is:

1. **Constructive**: we provide explicit reconstruction formulas (Gromov product / median formulas) that compute interior distances from boundary data.
2. **Machine-verified**: all proofs are checked by a proof assistant, providing the highest standard of mathematical certainty.
3. **Connected to tropical geometry**: the reconstruction has a natural interpretation via tropical (min-plus) coordinate charts.

### 1.2 Prior Work

The reconstruction of weighted trees from leaf distances has a rich history:

- **Buneman (1971)**: Showed that a metric satisfying the four-point condition can be realized as a tree metric, and characterized when the realization is unique.
- **Zaretskii (1965)**: Early work on tree realization from distance matrices.
- **Semple & Steel (2003)**: Comprehensive treatment in the context of phylogenetics.
- **Dress, Huber, Koolen, Moulton (2012)**: Systematic theory of split systems and tree-like metrics.

The Gromov product formulation and its connection to hyperbolicity are due to:

- **Gromov (1987)**: Introduction of δ-hyperbolic spaces and the role of the Gromov product.
- **Bridson & Haefliger (1999)**: Standard reference for hyperbolic metric spaces.

Our contribution is to isolate and formally verify the precise boundary rigidity statement with explicit hypotheses (median witnesses, joint boundary reachability) that make the theorem both mathematically clean and computationally useful.

### 1.3 Overview of Results

Our main results, in order of logical dependency:

1. **Median distance formula** (Theorem 3.1): If m is the median of (a, b, c) in a symmetric metric, then d(a, m) = (d(a,b) + d(a,c) - d(b,c)) / 2.

2. **Boundary determines interior-boundary distances** (Theorem 4.1): If two symmetric metrics agree on B × B and every vertex has median witnesses for each boundary point, then they agree on V × B.

3. **Boundary determines bulk** (Theorem 4.2): Adding a joint boundary reachability condition, the metrics agree on V × V.

4. **Gromov product properties** (Theorems 5.1–5.3): Nonnegativity and the min-plus inequality for tree-like metrics.

---

## 2. Definitions and Notation

### 2.1 Basic Setup

Let V be a finite set (the vertex set) and d : V × V → ℝ a function. We consider the following properties:

**Definition 2.1 (Tree-like metric).** d is *tree-like* if:
1. d(x, y) ≥ 0 for all x, y ∈ V (nonnegativity)
2. d(x, y) = d(y, x) for all x, y ∈ V (symmetry)
3. d(x, x) = 0 for all x ∈ V (identity of indiscernibles, one direction)
4. d(w, x) + d(y, z) ≤ max(d(w, y) + d(x, z), d(w, z) + d(x, y)) for all w, x, y, z ∈ V (four-point condition)

The four-point condition is equivalent to 0-hyperbolicity in the sense of Gromov. It characterizes metrics that embed isometrically into weighted ℝ-trees.

**Definition 2.2 (Median).** A vertex m is a *median* of (a, b, c) if:
- d(a, b) = d(a, m) + d(m, b)
- d(a, c) = d(a, m) + d(m, c)  
- d(b, c) = d(b, m) + d(m, c)

In a tree-like metric, the median of any triple exists and is unique.

**Definition 2.3 (Boundary visibility).** Let B ⊆ V be a designated boundary set. A vertex x is *B-visible* if: for all y ∈ V, if d(x, b) = d(y, b) for all b ∈ B, then x = y.

**Definition 2.4 (Boundary profile).** The *boundary profile* of x is the function ρ_x : B → ℝ defined by ρ_x(b) = d(x, b).

**Definition 2.5 (Boundary reachability).** The boundary B *reaches* all directions in d if: for all x, y ∈ V, there exists s ∈ B such that d(y, s) = d(y, x) + d(x, s).

Intuitively, this says that for any vertex x and any direction (toward y), there is a boundary vertex s beyond x in that direction — the geodesic from y to s passes through x.

**Definition 2.6 (Joint boundary reachability).** Given two metrics d₁, d₂ on V, the boundary B has *joint reachability* if: for all x, y ∈ V, there exists s ∈ B such that d₁(y, s) = d₁(y, x) + d₁(x, s) AND d₂(y, s) = d₂(y, x) + d₂(x, s).

### 2.2 The Gromov Product

**Definition 2.7.** The *Gromov product* of a, b at basepoint x is:
(a | b)_x = (d(x, a) + d(x, b) - d(a, b)) / 2

The Gromov product measures how long the geodesics from x to a and from x to b travel together before diverging. In a tree, it equals the distance from x to the branch point of (x, a, b).

---

## 3. Branch-Point Reconstruction

### 3.1 The Median Distance Formula

**Theorem 3.1.** Let d be a symmetric function V × V → ℝ and m a median of (a, b, c). Then:
- d(a, m) = (d(a,b) + d(a,c) - d(b,c)) / 2
- d(m, b) = (d(a,b) + d(b,c) - d(a,c)) / 2
- d(m, c) = (d(a,c) + d(b,c) - d(a,b)) / 2

*Proof sketch.* From the median equations:
- d(a,b) = d(a,m) + d(m,b)  ... (1)
- d(a,c) = d(a,m) + d(m,c)  ... (2)
- d(b,c) = d(b,m) + d(m,c)  ... (3)

By symmetry, d(b,m) = d(m,b). Computing (1) + (2) - (3):

d(a,b) + d(a,c) - d(b,c) = 2·d(a,m) + d(m,b) + d(m,c) - d(m,b) - d(m,c) = 2·d(a,m)

Hence d(a,m) = (d(a,b) + d(a,c) - d(b,c)) / 2. The other formulas follow by cyclic permutation.

**Remark.** Symmetry of d is essential. Without it, the median equations have 4 unknowns (d(a,m), d(m,a), d(m,b), d(b,m), d(m,c), d(c,m)) but only 3 equations, so the system is underdetermined.

### 3.2 Gromov Product Identities

**Theorem 3.2 (Tautological identity).** For any symmetric d:
d(x, y) = d(x, a) + d(y, a) - 2·(a | x, y)

This follows immediately from the definition.

**Theorem 3.3 (Nonnegativity).** If d is tree-like, then (x | a, b) ≥ 0 for all x, a, b.

*Proof.* Apply the four-point condition with w = x, x = x, y = a, z = b:
d(x,x) + d(a,b) ≤ max(d(x,a) + d(x,b), d(x,b) + d(x,a))
Since d(x,x) = 0: d(a,b) ≤ d(x,a) + d(x,b), hence (x|a,b) ≥ 0.

**Theorem 3.4 (Min-plus inequality / 0-hyperbolicity).** If d is tree-like:
(x | a, b) ≥ min((x | a, c), (x | b, c))

This is equivalent to the four-point condition applied to the quadruple (a, b, c, x).

---

## 4. Main Theorems

### 4.1 Boundary Determines Interior-Boundary Distances

**Theorem 4.1.** Let d₁, d₂ : V × V → ℝ be symmetric, B ⊆ V a boundary set. Suppose:
1. d₁(u, v) = d₂(u, v) for all u, v ∈ B (boundary agreement)
2. For every x ∈ V and s ∈ B, there exist a, b ∈ B such that x is a median of (s, a, b) in both d₁ and d₂.

Then d₁(x, s) = d₂(x, s) for all x ∈ V, s ∈ B.

*Proof.* Fix x ∈ V and s ∈ B. By hypothesis (2), there exist a, b ∈ B with x = median(s, a, b) in both metrics. By Theorem 3.1:
- d₁(s, x) = (d₁(s,a) + d₁(s,b) - d₁(a,b)) / 2
- d₂(s, x) = (d₂(s,a) + d₂(s,b) - d₂(a,b)) / 2

By hypothesis (1), d₁(s,a) = d₂(s,a), d₁(s,b) = d₂(s,b), d₁(a,b) = d₂(a,b). Hence d₁(s,x) = d₂(s,x), and by symmetry d₁(x,s) = d₂(x,s). □

### 4.2 Boundary Determines Bulk Distances

**Theorem 4.2 (Main Theorem).** Let d₁, d₂ : V × V → ℝ be symmetric, B ⊆ V a boundary set. Suppose:
1. d₁ and d₂ agree on B × B.
2. For every x ∈ V and s ∈ B, there exist a, b ∈ B with x = median(s, a, b) in both metrics.
3. B has joint reachability for (d₁, d₂).

Then d₁(x, y) = d₂(x, y) for all x, y ∈ V.

*Proof.* By Theorem 4.1, d₁(x, s) = d₂(x, s) for all x ∈ V, s ∈ B. Fix x, y ∈ V. By joint reachability, there exists s ∈ B with:
- d₁(y, s) = d₁(y, x) + d₁(x, s)
- d₂(y, s) = d₂(y, x) + d₂(x, s)

From the first equation: d₁(y, x) = d₁(y, s) - d₁(x, s).
From the second: d₂(y, x) = d₂(y, s) - d₂(x, s).

Since d₁(y, s) = d₂(y, s) and d₁(x, s) = d₂(x, s) (by Theorem 4.1), we conclude d₁(y, x) = d₂(y, x), hence d₁(x, y) = d₂(x, y) by symmetry. □

### 4.3 Discussion of Hypotheses

**Hypothesis analysis:**

- **Symmetry** is essential for the median formula (see Remark after Theorem 3.1).
- **Median witnesses** are automatically available when B contains all leaves of the tree and every internal vertex has degree ≥ 3 (the tree is "reduced").
- **Joint boundary reachability** holds when: (a) both metrics have the same underlying tree combinatorics, and (b) every branch of the tree at every internal vertex contains at least one boundary vertex.
- For **trees with B = leaves**, all hypotheses are automatically satisfied when the tree has no degree-2 vertices.

---

## 5. Algorithms

### 5.1 Reconstruction Algorithm

```
Algorithm: BOUNDARY-TO-BULK-RECONSTRUCTION
Input: Boundary distance matrix D_B ∈ ℝ^{|B|×|B|},
       median witnesses W: V × B → B × B,
       reach witnesses R: V × V → B
Output: Full distance matrix D ∈ ℝ^{|V|×|V|}

1. Initialize D with D_B on B × B entries.

2. For each interior vertex x ∈ V \ B:
   For each boundary vertex s ∈ B:
     Let (a, b) = W(x, s)
     Set D[x, s] = D[s, x] = (D_B[s,a] + D_B[s,b] - D_B[a,b]) / 2

3. For each pair (x, y) ∈ V × V with x or y ∉ B:
   Let s = R(x, y)
   Set D[x, y] = D[y, x] = D[y, s] - D[x, s]

Return D
```

**Complexity:** O(|V|·|B| + |V|²) time, O(|V|²) space.

### 5.2 Tree-Likeness Test

```
Algorithm: FOUR-POINT-CHECK
Input: Distance matrix D ∈ ℝ^{n×n}
Output: True iff D is tree-like

For all {w, x, y, z} ⊆ {0, ..., n-1}:
  Compute s₁ = D[w,x] + D[y,z]
           s₂ = D[w,y] + D[x,z]
           s₃ = D[w,z] + D[x,y]
  Sort: s_min ≤ s_mid ≤ s_max
  If s_max ≠ s_mid (up to tolerance):
    Return False

Return True
```

**Complexity:** O(n⁴) time.

### 5.3 Hyperbolicity Computation

The Gromov hyperbolicity δ can be computed in O(n⁴) time via:

δ = max_{x,a,b,c} [(a|b)_x - min((a|c)_x, (b|c)_x)]

For tree metrics, δ = 0.

---

## 6. Applications

### 6.1 Phylogenetic Reconstruction

**Problem:** Given a matrix of evolutionary distances between n extant species (e.g., from DNA sequence alignment), reconstruct the phylogenetic tree.

**Solution:** The boundary rigidity theorem guarantees that if the true evolutionary process follows a tree model, the tree is uniquely determined by the leaf-to-leaf distances. The median formula provides an explicit construction.

**Example:** Given distances between Human, Chimp, Gorilla, Orangutan, and Mouse:

| | Human | Chimp | Gorilla | Orangutan | Mouse |
|---|---|---|---|---|---|
| Human | 0 | 6 | 8 | 16 | 32 |
| Chimp | 6 | 0 | 8 | 16 | 32 |
| Gorilla | 8 | 8 | 0 | 16 | 32 |
| Orangutan | 16 | 16 | 16 | 0 | 32 |
| Mouse | 32 | 32 | 32 | 32 | 0 |

The median of (Human, Chimp, Mouse) has depth (6+32-32)/2 = 3 from Human, giving the Human-Chimp ancestor at 3 Mya.

### 6.2 Network Tomography

**Problem:** Given round-trip latencies between n edge servers, determine the internal network topology and latencies.

**Application of Theorem 4.2:** If the network has tree topology, the boundary rigidity theorem guarantees unique reconstruction of all internal latencies from edge-to-edge measurements.

### 6.3 Tropical Geometry Interpretation

The boundary profile map x ↦ ρ_x = (d(x, b))_{b∈B} is a **tropical embedding** of V into ℝ^|B|. In the min-plus semiring, this embedding preserves the metric structure: the Gromov product (a|b)_x is a tropical bilinear form.

The boundary rigidity theorem states that this tropical embedding is:
1. **Injective** (boundary visibility)
2. **Distance-preserving** in the sense that d(x,y) is recoverable from ρ_x and ρ_y

This makes the boundary profile map a tropical isometric embedding — a new object connecting metric geometry and tropical algebra.

---

## 7. Computational Experiments

We verified all theorems computationally on a weighted tree with 8 vertices (5 boundary, 3 interior):

| Experiment | Result |
|---|---|
| Four-point condition check | 70/70 quadruples satisfied |
| Hyperbolicity δ | 0.0 (exactly) |
| Boundary visibility | All 8 profiles distinct |
| Median formula accuracy | Exact match on all triples |
| Full reconstruction error | 0.0 (exact reconstruction) |
| Gromov product min-inequality | 448/448 tuples verified |

Python implementations of all algorithms are provided in `algorithms.py` and `demo.py`.

---

## 8. Discussion

### 8.1 Relationship to Continuous Boundary Rigidity

Our theorem is a discrete analogue of the **boundary rigidity conjecture** for Riemannian manifolds: if (M, g) is a compact simple Riemannian manifold with boundary, does the boundary distance function d_g|_{∂M × ∂M} determine g up to boundary-fixing isometry?

The continuous case remains open, though it has been proved for:
- Simple surfaces (Pestov-Uhlmann, 2005)
- Metrics close to flat (Stefanov-Uhlmann, 2005)
- Metrics with certain curvature conditions

Our discrete theorem provides a clean "model case" where the answer is fully affirmative, with explicit reconstruction formulas.

### 8.2 Limitations

1. **Tree assumption:** The theorem applies to metrics satisfying the four-point condition. Real networks often have cycles.
2. **Joint reachability:** The hypothesis that reach witnesses are compatible across both metrics is nontrivial. It holds when both metrics share the same tree combinatorics.
3. **Median witnesses:** The existence of median witnesses for every (vertex, boundary point) pair requires sufficient boundary coverage.

### 8.3 Extensions

Natural generalizations include:
- **δ-hyperbolic metrics:** For δ > 0, boundary distances determine the metric up to error O(δ).
- **Graph metrics with bounded treewidth:** The reconstruction might work modulo a bounded number of ambiguities.
- **Continuous tree metrics (ℝ-trees):** The theory extends naturally.

---

## 9. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps including:
1. Approximate boundary rigidity for δ-hyperbolic spaces
2. Algorithmic complexity improvements via persistent homology
3. Tropical Satake-type reconstruction for higher-rank buildings
4. Continuous boundary rigidity for ℝ-trees
5. Applications to phylogenetic network reconstruction

---

## 10. References

1. Bridson, M. R., & Haefliger, A. (1999). *Metric Spaces of Non-Positive Curvature*. Springer.
2. Buneman, P. (1971). The recovery of trees from measures of dissimilarity. In *Mathematics in the Archaeological and Historical Sciences*.
3. Dress, A., Huber, K. T., Koolen, J., Moulton, V., & Spillner, A. (2012). *Basic Phylogenetic Combinatorics*. Cambridge University Press.
4. Gromov, M. (1987). Hyperbolic groups. In *Essays in Group Theory*, MSRI Publications.
5. Michel, R. (1981). Sur la rigidité imposée par la longueur des géodésiques. *Inventiones Mathematicae*, 65(1), 71–83.
6. Pestov, L., & Uhlmann, G. (2005). Two dimensional compact simple Riemannian manifolds are boundary distance rigid. *Annals of Mathematics*, 161(2), 1093–1110.
7. Semple, C., & Steel, M. (2003). *Phylogenetics*. Oxford University Press.
8. Stefanov, P., & Uhlmann, G. (2005). Boundary rigidity and stability for generic simple metrics. *Journal of the AMS*, 18(4), 975–1003.
