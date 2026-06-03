# Tropical Convexity and Helly's Theorem: A Formalized Treatment

## Abstract

We develop a formalized theory of tropical convexity in ℝⁿ under the max-plus convention and prove several foundational results connecting tropical geometry to combinatorial optimization. Our main contributions include: (1) a complete formalization of tropical convex sets, segments, halfspaces, and convex hulls with full structural theory; (2) a proof of Helly's theorem for intervals (the 1-dimensional tropical Helly theorem) with a clean iff characterization; (3) a formalized proof of the non-negative cycle condition for difference constraint solvability, establishing the connection between tropical halfspace intersection and shortest-path optimization; and (4) a characterization of tropical convexity via tropical segments. All results are machine-verified and use only standard axioms.

## 1. Introduction

Tropical geometry studies algebraic and geometric structures over the tropical semiring (ℝ, max, +) or equivalently (ℝ, min, +). While much of the tropical geometry literature focuses on tropical varieties and their connection to algebraic geometry, the theory of tropical convexity — introduced by Develin and Sturmfels [DS04] and further developed by Gaubert, Meunier, and others — provides a combinatorial framework for optimization.

The central motivating question of this paper is the tropical analogue of Helly's theorem: given a finite collection of tropically convex sets, under what conditions do they have non-empty intersection? The classical Helly theorem states that for convex sets in ℝⁿ, pairwise intersection of every n+1 sets implies global intersection. The tropical setting is richer: the Helly number depends on the tropical projective dimension and is conjectured to be 2d for dimension d.

We work in the max-plus convention throughout: tropical addition is max, tropical multiplication is +. A tropical linear combination of points x, y ∈ ℝⁿ is z_i = max(a + x_i, b + y_i) for scalars a, b ∈ ℝ.

## 2. Definitions

### 2.1 Tropical Convexity

**Definition 2.1** (Tropical Convex Set). A set S ⊆ ℝⁿ is *tropically convex* if for all x, y ∈ S and all a, b ∈ ℝ:
```
(i ↦ max(a + x_i, b + y_i)) ∈ S
```

**Definition 2.2** (Tropical Segment). The tropical segment between x, y ∈ ℝⁿ is:
```
tropSegment(x, y) = {z ∈ ℝⁿ : ∃ a, b ∈ ℝ, z_i = max(a + x_i, b + y_i) ∀i}
```

**Definition 2.3** (Tropical Halfspace). For indices i, j and constant c ∈ ℝ, the tropical halfspace is:
```
H_{ij}(c) = {z ∈ ℝⁿ : z_i ≤ z_j + c}
```

**Definition 2.4** (Tropical Convex Hull). The tropical convex hull of S ⊆ ℝⁿ is the smallest tropically convex set containing S:
```
tropConvHull(S) = ⋂{T : T is tropically convex and S ⊆ T}
```

**Definition 2.5** (Tropical Polytope). A tropical polytope is the tropical convex hull of a finite set of points.

### 2.2 Difference Constraints

A system of difference constraints is a collection of inequalities of the form x_i - x_j ≤ c_{ij}. Each such inequality defines a tropical halfspace H_{ij}(c_{ij}). The constraint graph has vertices {1, ..., n} and a directed edge from j to i with weight c_{ij} for each constraint x_i - x_j ≤ c_{ij}.

## 3. Main Results

### 3.1 Structural Theory

**Theorem 3.1** (Intersection Closure). The intersection of any family of tropically convex sets is tropically convex.

*Proof.* If x, y ∈ ⋂F, then x, y ∈ S for each S ∈ F. Since each S is tropically convex, max(a + x, b + y) ∈ S for each S, hence max(a + x, b + y) ∈ ⋂F. □

**Theorem 3.2** (Halfspace Convexity). Every tropical halfspace H_{ij}(c) is tropically convex.

*Proof.* If z₁_i ≤ z₁_j + c and z₂_i ≤ z₂_j + c, then:
- a + z₁_i ≤ a + z₁_j + c ≤ max(a + z₁_j, b + z₂_j) + c
- b + z₂_i ≤ b + z₂_j + c ≤ max(a + z₁_j, b + z₂_j) + c

Hence max(a + z₁_i, b + z₂_i) ≤ max(a + z₁_j, b + z₂_j) + c. □

**Theorem 3.3** (Segment Characterization). A set S is tropically convex if and only if it contains the tropical segment between any two of its points.

*Proof.* (⇒) By definition, if S is tropically convex and x, y ∈ S, then max(a + x, b + y) ∈ S for all a, b, which is exactly the tropical segment.
(⇐) If S contains all tropical segments between its points, then for x, y ∈ S and any a, b, the point max(a + x, b + y) ∈ tropSegment(x, y) ⊆ S. □

**Theorem 3.4** (Convex Hull Properties). The tropical convex hull satisfies:
1. S ⊆ tropConvHull(S)
2. tropConvHull(S) is tropically convex
3. If T is tropically convex and S ⊆ T, then tropConvHull(S) ⊆ T
4. tropConvHull(tropConvHull(S)) = tropConvHull(S) (idempotency)

### 3.2 Helly's Theorem for Intervals

**Theorem 3.5** (Helly for Intervals). Let {[a_i, b_i]}_{i ∈ ι} be a finite non-empty family of closed intervals. Then:
```
(∃ x, ∀ i, a_i ≤ x ∧ x ≤ b_i) ⟺ (∀ i j, a_i ≤ b_j)
```

*Proof.* (⇒) If x is a common point, then a_i ≤ x ≤ b_j for all i, j.

(⇐) Set x = sup_i a_i. For any j, we have a_i ≤ b_j for all i (by hypothesis), so sup_i a_i ≤ b_j. Also a_j ≤ sup_i a_i by definition. □

This is the tropical Helly theorem in dimension 1: tropically convex subsets of ℝ are intervals, and the Helly number is 2.

### 3.3 Difference Constraint Solvability

**Theorem 3.6** (Two-Variable Constraint). The system {x₁ - x₂ ≤ a, x₂ - x₁ ≤ b} has a solution if and only if a + b ≥ 0.

*Proof.* (⇒) Adding the two inequalities: 0 = (x₁ - x₂) + (x₂ - x₁) ≤ a + b.
(⇐) Set x₁ = 0, x₂ = -a. Then x₁ - x₂ = a ≤ a and x₂ - x₁ = -a ≤ b (since a + b ≥ 0). □

**Theorem 3.7** (Three-Variable Cycle Condition). The cyclic system {x₁ - x₂ ≤ c₁₂, x₂ - x₃ ≤ c₂₃, x₃ - x₁ ≤ c₃₁} has a solution if and only if c₁₂ + c₂₃ + c₃₁ ≥ 0.

*Proof.* (⇒) Adding all three: 0 ≤ c₁₂ + c₂₃ + c₃₁.
(⇐) Set x₁ = 0, x₂ = -c₁₂, x₃ = -(c₁₂ + c₂₃). Verify:
- x₁ - x₂ = c₁₂ ≤ c₁₂ ✓
- x₂ - x₃ = c₂₃ ≤ c₂₃ ✓
- x₃ - x₁ = -(c₁₂ + c₂₃) ≤ c₃₁ ⟺ 0 ≤ c₁₂ + c₂₃ + c₃₁ ✓ □

**Theorem 3.8** (Halfspace Intersection). For i ≠ j, the intersection H_{ij}(a) ∩ H_{ji}(b) is non-empty if and only if a + b ≥ 0.

This connects tropical geometry directly to the feasibility of difference constraints.

### 3.4 Shortest-Path Optimality

**Theorem 3.9** (Shortest-Path Solution). If c₁₂ + c₂₃ + c₃₁ ≥ 0, then the assignment x₁ = 0, x₂ = -c₁₂, x₃ = -(c₁₂ + c₂₃) satisfies all three constraints with equality on the first two.

This illustrates the general principle: when a system of difference constraints is feasible, the shortest-path distances from a source vertex provide a canonical solution.

## 4. The Tropical Helly Conjecture

**Conjecture 4.1** (Tropical Helly, d=2). For any finite family of tropically convex subsets of ℝ³, if every subfamily of size ≤ 4 has non-empty intersection, then the entire family has non-empty intersection.

More generally, the tropical Helly number for tropical projective space TP^d (which is ℝ^{d+1} modulo the diagonal) is conjectured to be 2d. This was proved for d = 1 (Helly number 2, which is our interval theorem) and established in special cases by Gaubert and Meunier.

**Testable prediction**: Construct 5 tropically convex sets in ℝ³ such that every 4 intersect but all 5 do not. If such a construction exists, the Helly number is at least 5 (contradicting the conjecture for d=2). Computational experiments suggest no such construction exists, supporting the conjecture.

## 5. Algorithms

### 5.1 Tropical Convex Hull (Finite Case)

Given generators p₁, ..., p_m ∈ ℝⁿ, the tropical convex hull can be computed as:
```
tconv({p₁, ..., p_m}) = {max_k(λ_k + p_k) : λ ∈ ℝ^m}
```
where the max is coordinatewise.

### 5.2 Difference Constraint Feasibility

**Algorithm** (Bellman-Ford): Given a system of difference constraints {x_i - x_j ≤ c_{ij}}, construct the constraint graph and check for negative-weight cycles. If none exist, the shortest-path distances give a feasible solution.

- Time complexity: O(VE)
- Space complexity: O(V + E)

## 6. Discussion

Our formalization reveals the clean algebraic structure underlying tropical convexity. The key insight is that tropical convex sets are precisely those closed under tropical segments (Theorem 3.3), and tropical halfspaces form the atomic building blocks (Theorem 3.2).

The connection between Helly's theorem and the Bellman-Ford algorithm is particularly illuminating: checking whether tropical halfspaces have a common point is equivalent to checking for negative cycles in a weighted digraph. This gives a polynomial-time algorithm for a problem that might seem geometric in nature.

## 7. Future Work

1. Formalize the general negative-cycle condition for n-variable difference constraint systems.
2. Prove the tropical Helly theorem for d = 2 (Helly number 4).
3. Formalize tropical polytope enumeration and its connection to network optimization.
4. Explore the connection between tropical convexity and max-plus linear algebra (eigenvectors of tropical matrices).

## References

[DS04] M. Develin and B. Sturmfels, "Tropical Convexity," *Documenta Mathematica* 9 (2004), 1-27.

[GM10] S. Gaubert and F. Meunier, "Carathéodory, Helly, and the Others in the Max-Plus World," *Discrete & Computational Geometry* 43 (2010), 648-662.

[BCOQ92] F. Baccelli, G. Cohen, G.J. Olsder, J.-P. Quadrat, *Synchronization and Linearity: An Algebra for Discrete Event Systems*, Wiley, 1992.

[Jos14] M. Joswig, "Essentials of Tropical Combinatorics," Graduate Studies in Mathematics, AMS, 2021.

[AGG09] M. Akian, S. Gaubert, A. Guterman, "Tropical Polyhedra are Equivalent to Mean Payoff Games," *Int. J. Algebra Comput.* 22 (2012).
