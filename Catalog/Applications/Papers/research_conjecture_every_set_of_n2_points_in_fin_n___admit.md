# Tropical Radon Theorem: Formal Foundations for Min-Plus Combinatorial Convexity

## Abstract

We establish the tropical analogue of Radon's partition theorem for min-plus convexity over rational coordinates. We define the tropical convex hull in ℚ^n, prove its basic properties, and demonstrate that any 4 points in ℚ^2 admit a tropical Radon partition — disjoint nonempty index subsets whose tropical convex hulls intersect. The proof uses a median-slope construction that selects three indices based on the ordering of coordinate differences and constructs explicit min-plus weights witnessing the intersection. We also prove that tropical convex hulls in ℚ^1 equal all of ℚ^1 (rendering the one-dimensional case trivial) and handle the zero-dimensional case by uniqueness. The general n-dimensional theorem is stated; the n ≥ 3 case requires tropical dependence theory beyond the scope of this work. All results for n ≤ 2 are machine-verified. Accompanying algorithms implement the median-slope construction with applications to shortest-path redundancy, scheduling overlap, and dynamic programming compression.

## 1. Introduction

### 1.1 Motivation

Classical combinatorial convexity is organized by the chain of implications:

**Carathéodory → Radon → Helly → Tverberg**

Each theorem constrains the combinatorial structure of convex sets in ℝ^n. Carathéodory says every point in the convex hull of S can be expressed using at most n+1 generators. Radon says any n+2 points admit a partition into two groups with intersecting convex hulls. Helly gives intersection conditions for convex families. Tverberg extends Radon to r-fold partitions.

Tropical (min-plus) convexity replaces affine combinations with min-plus combinations:

z(k) = min_i (w_i + p_i(k))

where the p_i are generators and w_i are scalar weights. This algebra arises naturally in:
- Shortest-path computation (Bellman-Ford, Floyd-Warshall)
- Scheduling and dynamic programming
- Tropical algebraic geometry
- Idempotent analysis and max-plus systems

A tropical analogue of the Carathéodory-Radon-Helly chain would provide structural foundations for all these fields. This work establishes the Radon step.

### 1.2 Prior Work

Develin and Sturmfels (2004) established tropical convexity theory and proved the tropical Radon theorem using connections to ordinary polytope theory (the Cayley trick). Their proof is existential and relies on classical Radon in a higher-dimensional lifted space.

Gaubert and Katz (2011) developed min-plus convexity from the perspective of idempotent semirings. Joswig (2005) studied tropical halfspaces and their Helly-type properties.

Our contribution is: (1) a self-contained, constructive proof for ℚ^2 using the median-slope method, (2) machine verification of all results for n ≤ 2, and (3) algorithmic implementations with applications.

## 2. Definitions and Notation

### 2.1 Tropical Convex Hull

**Definition.** Let S ⊆ (Fin n → ℚ). A point z is in the *tropical convex hull* of S, written z ∈ tropConvHull(S), if there exist finitely many generators s_1, ..., s_m ∈ S and weights w_1, ..., w_m ∈ ℚ such that:

∀ k ∈ Fin n : z(k) = min_{i=1}^{m} (w_i + s_i(k))

### 2.2 Tropical Radon Partition

**Definition.** A *tropical Radon partition* of a family p : Fin m → (Fin n → ℚ) consists of disjoint nonempty subsets A, B ⊆ Fin m such that tropConvHull(p '' A) ∩ tropConvHull(p '' B) ≠ ∅.

### 2.3 Slope and Tropical Equivalence

For points p, q ∈ ℚ^n, the *slope* between coordinates j and k is:
α^{j,k}(p) = p(j) - p(k)

Two points p, q are *tropically equivalent* if p - q is a constant function, i.e., p(k) - q(k) = c for all k.

## 3. Main Results

### 3.1 Basic Properties

**Lemma 3.1** (Self-membership). If s ∈ S, then s ∈ tropConvHull(S).

*Proof.* Use m = 1, s_1 = s, w_1 = 0. Then z(k) = 0 + s(k) = s(k). □

**Lemma 3.2** (Monotonicity). If S ⊆ T, then tropConvHull(S) ⊆ tropConvHull(T).

**Theorem 3.3** (Dimension-one triviality). For any nonempty S ⊆ (Fin 1 → ℚ), tropConvHull(S) = Fin 1 → ℚ (the whole space).

*Proof.* Given any target z(0) ∈ ℚ and any s ∈ S, set w = z(0) - s(0). Then min(w + s(0)) = z(0). □

### 3.2 Tropical Radon for ℚ^2

**Theorem 3.4** (Tropical Radon, n = 2). For any p : Fin 4 → (Fin 2 → ℚ), there exist disjoint nonempty A, B ⊆ Fin 4 with tropConvHull(p '' A) ∩ tropConvHull(p '' B) ≠ ∅.

*Proof (Median-Slope Construction).* Define α_i = p(i)(1) - p(i)(0) for each i ∈ Fin 4. Among the four values {α_0, α_1, α_2, α_3}, find three distinct indices i_lo, i_med, i_hi such that:

α_{i_lo} ≤ α_{i_med} ≤ α_{i_hi}

This is possible because among any 4 rational numbers, sorting and taking positions 0, 1, 2 gives three with this property.

Set A = {i_med} and B = {i_hi, i_lo}. These are disjoint and nonempty since all three indices are distinct.

**Witness construction.** Let z = p(i_med). Then z ∈ tropConvHull(p '' A) by Lemma 3.1.

For z ∈ tropConvHull(p '' B), set:
- w_hi = p(i_med)(0) - p(i_hi)(0)  (calibrated to coordinate 0)
- w_lo = p(i_med)(1) - p(i_lo)(1)  (calibrated to coordinate 1)

**Verification at coordinate 0:**

min(w_hi + p(i_hi)(0), w_lo + p(i_lo)(0))
= min(p(i_med)(0), p(i_med)(1) - α_{i_lo})

Since α_{i_lo} ≤ α_{i_med} = p(i_med)(1) - p(i_med)(0):
p(i_med)(1) - α_{i_lo} ≥ p(i_med)(1) - α_{i_med} = p(i_med)(0)

Therefore the minimum is p(i_med)(0) = z(0). ✓

**Verification at coordinate 1:**

min(w_hi + p(i_hi)(1), w_lo + p(i_lo)(1))
= min(p(i_med)(0) + α_{i_hi}, p(i_med)(1))

Since α_{i_hi} ≥ α_{i_med}:
p(i_med)(0) + α_{i_hi} ≥ p(i_med)(0) + α_{i_med} = p(i_med)(1)

Therefore the minimum is p(i_med)(1) = z(1). ✓ □

### 3.3 General Theorem Statement

**Theorem 3.5** (Tropical Radon, general). For every n ≥ 0 and every p : Fin (n+2) → (Fin n → ℚ), there exist disjoint nonempty A, B ⊆ Fin (n+2) with tropConvHull(p '' A) ∩ tropConvHull(p '' B) ≠ ∅.

The cases n = 0 (trivial, by uniqueness of the empty function) and n = 1 (by Theorem 3.3) are elementary. The case n = 2 is Theorem 3.4. The general case for n ≥ 3 requires extending the median-slope argument to handle all n coordinates simultaneously, which involves tropical dependence theory.

## 4. Algorithms

### 4.1 Median-Slope Algorithm (n = 2)

```
Input: 4 points p[0], ..., p[3] in ℚ^2
Output: Partition (A, B) and witness z

1. Compute α[i] = p[i][1] - p[i][0] for i = 0,...,3
2. Sort indices by α: π[0], ..., π[3]
3. Set i_med = π[1], i_lo = π[0], i_hi = π[2]
4. Set A = {i_med}, B = {i_hi, i_lo}
5. Set z = p[i_med]
6. Set w_hi = z[0] - p[i_hi][0], w_lo = z[1] - p[i_lo][1]
7. Return (A, B, z, [w_hi, w_lo])
```

**Complexity:** O(m log m) for sorting, O(n) for weight computation. Total: O(m log m + n).

### 4.2 General Partition Algorithm

For n ≥ 3, we use a brute-force approach: for each singleton A = {i₀}, compute the covering weights μ_j = max_k(p(i₀)(k) - p(j)(k)) and check if every coordinate is "covered" (has a tight index). If so, output the partition. Otherwise, try the next i₀.

**Complexity:** O(m · n · m) = O(m²n) per candidate, O(m³n) total.

## 5. Applications

### 5.1 Shortest-Path Redundancy

In a network with m sources and n destinations, source i has a distance vector d_i ∈ ℚ^n. A tropical Radon partition identifies two source groups with overlapping shortest-path profiles — natural backup groups for fault tolerance.

### 5.2 Schedule Compression

In min-plus scheduling with m jobs across n stages, job profiles form points in ℚ^n. A Radon partition reveals two job subsets whose feasibility regions overlap, enabling schedule compression.

### 5.3 DP State Pruning

Dynamic programming maintains value-function vectors in ℚ^n. When n+2 states accumulate, the Radon theorem guarantees compressible structure. One of the two partition groups can be pruned without losing optimality.

## 6. Computational Experiments

We verified the median-slope algorithm on several families of 4 points in ℚ^2:

| Configuration | Points | Partition A | Partition B | Verified |
|---|---|---|---|---|
| Standard basis | (0,0),(1,0),(0,1),(1,1) | {0} | {3,1} | ✓ |
| Collinear | (0,0),(0,1),(0,2),(0,3) | {1} | {2,0} | ✓ |
| Large spread | (0,0),(100,0),(0,100),(50,50) | {0} | {3,1} | ✓ |
| Negative coords | (-3,2),(1,-4),(5,3),(-2,-1) | {2} | {3,1} | ✓ |
| Random | (1,5),(3,2),(7,4),(2,8) | {1} | {0,2} | ✓ |

All partitions were verified by explicit weight construction and coordinatewise minimum computation.

## 7. Discussion

### 7.1 Limitations

The median-slope construction covers exactly 2 coordinates. For n ≥ 3, covering all n coordinates simultaneously requires either:
- A multi-step argument using multiple coordinate pairs
- Tropical dependence theory (Develin-Sturmfels)
- An inductive argument with careful lifting

### 7.2 Comparison with Classical Radon

| Aspect | Classical Radon | Tropical Radon |
|---|---|---|
| Algebra | Affine combinations | Min-plus combinations |
| Key technique | Linear dependence | Slope ordering (n=2) |
| Radon number | n+2 (sharp) | n+2 (conjectured sharp) |
| Proof method | Gaussian elimination | Median construction |
| Constructive? | Yes (via null space) | Yes for n≤2 |

## 8. Future Work

1. Complete the proof for all n by formalizing tropical dependence theory
2. Establish the sharp Radon number (lower bound via general position)
3. Derive tropical Helly from tropical Radon
4. Investigate tropical Tverberg partitions
5. Connect to valuated matroid theory and tropical linear algebra

## References

1. Develin, M., Sturmfels, B. (2004). Tropical convexity. *Documenta Mathematica* 9, 1–27.
2. Gaubert, S., Katz, R. (2011). Minimal half-spaces and external representation of tropical polyhedra. *Journal of Algebraic Combinatorics* 33(3), 325–348.
3. Joswig, M. (2005). Tropical halfspaces. *Combinatorial and Computational Geometry*, 409–431.
4. Radon, J. (1921). Mengen konvexer Körper, die einen gemeinsamen Punkt enthalten. *Mathematische Annalen* 83, 113–115.
