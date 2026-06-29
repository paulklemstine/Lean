# Gauge-Covariant Tropical Graph Surgery: Charged Wormhole Metrics

## Abstract

We introduce *charged wormhole surgery* on weighted graphs, extending classical tropical shortest-path surgery with a gauge potential. The cost of inserting a wormhole edge (u, v) depends on a base cost λ, a coupling constant κ ≥ 0, and the potential mismatch |A(u) - A(v)| at the wormhole endpoints, through the charged penalty λ + κ|A(u) - A(v)|. We prove that: (1) the charged surgery distance satisfies a three-way min bound analogous to the classical surgery inequality; (2) the charged penalty and resulting distances are gauge-invariant under global potential shifts; (3) the charged surgery distance is sandwiched between the uncharged surgery distance and the original distance. All results are formally verified in Lean 4 with Mathlib. This framework connects tropical graph metrics to electrical networks, discrete gauge theory, and optimal transport with source terms.

## 1. Introduction

### 1.1 Background

Tropical geometry replaces the standard (ℝ, +, ×) semiring with the min-plus semiring (ℝ ∪ {∞}, min, +). In this setting, shortest-path distances become tropical polynomials, the Bellman-Ford algorithm becomes a fixed-point iteration in the tropical semiring, and graph surgery—inserting or removing edges—becomes a tropical algebraic operation.

The classical wormhole surgery theorem states that inserting an edge (u, v) of weight τ into a weighted graph yields a new graph whose tropical distance satisfies:

d_τ(x, y) ≤ min(d(x,y), d(x,u) + τ + d(v,y), d(x,v) + τ + d(u,y))

This bound is sharp and has applications in network optimization, computational geometry, and algorithm design.

### 1.2 Motivation

In many applications, graph vertices carry additional structure—a potential, charge, elevation, or cost field A : V → ℝ. When inserting a shortcut between vertices u and v, the effective cost should depend on the mismatch |A(u) - A(v)|:

- **Electrical networks**: A is voltage; connecting nodes at different voltages requires transformer infrastructure.
- **Logistics**: A is quality standard; connecting different-standard facilities requires quality control.
- **Molecular networks**: A is free energy; reactions between different energy states require activation energy.
- **Communication**: A is security level; connecting different-security nodes requires encryption overhead.

### 1.3 Contributions

We make the following contributions:

1. **Definition**: We define the charged penalty chargedPenalty(A, u, v, λ, κ) = λ + κ|A(u) - A(v)| and the charged wormhole surgery as standard wormhole surgery with the charged penalty as tunnel cost.

2. **Main theorem**: We prove the charged surgery distance bound (Theorem 3.1), extending the classical surgery inequality.

3. **Gauge invariance**: We prove that the charged penalty and surgery are invariant under global gauge shifts A ↦ A + c (Theorem 3.2, Corollary 3.3).

4. **Structural results**: We prove symmetry, monotonicity, and sandwich inequalities (Theorems 3.4-3.6).

5. **Formal verification**: All results are verified in Lean 4 using Mathlib.

## 2. Definitions and Notation

### 2.1 Tropical Distance

Let V = Fin n be a finite vertex set with n ≥ 1, and W : V × V → ℝ a nonneg weight matrix. A *walk* of k steps from s to t is a function f : Fin(k+1) → V with f(0) = s and f(last) = t. The *walk cost* is:

walkCost(W, k, f) = Σ_{i=0}^{k-1} W(f(i), f(i+1))

The *tropical distance* is:

d_W(s, t) = inf { walkCost(W, k, f) : k ∈ ℕ, f walk from s to t }

### 2.2 Wormhole Surgery

The *wormhole surgery* with tunnel cost τ between vertices u, v modifies the weight matrix:

wormholeSurgery(W, u, v, τ)(i, j) = min(W(i,j), τ)  if (i,j) ∈ {(u,v), (v,u)}
                                    = W(i,j)           otherwise

### 2.3 Charged Penalty

Given a gauge potential A : V → ℝ, the *charged penalty* is:

chargedPenalty(A, u, v, λ, κ) = λ + κ · |A(u) - A(v)|

where λ ∈ ℝ is the base cost and κ ≥ 0 is the coupling constant.

### 2.4 Charged Wormhole Surgery

The *charged wormhole surgery* is:

chargedWormholeSurgery(W, A, u, v, λ, κ) = wormholeSurgery(W, u, v, chargedPenalty(A, u, v, λ, κ))

## 3. Main Results

### 3.1 Charged Surgery Bound

**Theorem 3.1** (Main Theorem). Let W be a nonneg weight matrix, A : V → ℝ a gauge potential, u, v, x, y ∈ V vertices, λ ≥ 0 a base cost, and κ ≥ 0 a coupling constant. Then:

d_charged(x, y) ≤ min(d_W(x,y), min(d_W(x,u) + P + d_W(v,y), d_W(x,v) + P + d_W(u,y)))

where P = chargedPenalty(A, u, v, λ, κ).

*Proof sketch*. This follows immediately from the wormhole surgery bound applied with τ = chargedPenalty(A, u, v, λ, κ). The three branches correspond to: (1) not using the wormhole; (2) routing x → u → v → y; (3) routing x → v → u → y. Each branch is established using the triangle inequality for tropical distances, the bridge edge bound (surgery edge weight ≤ τ), and the monotonicity of tropical distance in edge weights.

### 3.2 Gauge Invariance

**Theorem 3.2**. For any constant c ∈ ℝ:

chargedPenalty(A + c, u, v, λ, κ) = chargedPenalty(A, u, v, λ, κ)

*Proof*. |((A(u) + c) - (A(v) + c))| = |A(u) - A(v)| by cancellation.

**Corollary 3.3**. The charged wormhole surgery is gauge-invariant:

chargedWormholeSurgery(W, A + c, u, v, λ, κ) = chargedWormholeSurgery(W, A, u, v, λ, κ)

### 3.4 Symmetry

**Theorem 3.4**. chargedPenalty(A, u, v, λ, κ) = chargedPenalty(A, v, u, λ, κ)

*Proof*. |A(u) - A(v)| = |A(v) - A(u)| by symmetry of absolute value.

### 3.5 Monotonicity

**Theorem 3.5**. If κ ≥ 0, then:

d_uncharged(x, y) ≤ d_charged(x, y)

*Proof*. The uncharged surgery uses min(W, λ) ≤ min(W, λ + κ|A(u)-A(v)|) = charged weight. Pointwise smaller weights give smaller tropical distances.

### 3.6 Sandwich Inequality

**Theorem 3.6**. If κ ≥ 0, then:

d_uncharged(x, y) ≤ d_charged(x, y) ≤ d_W(x, y)

*Proof*. The left inequality is Theorem 3.5. The right inequality follows from the fact that charged surgery weights are ≤ original weights (wormhole surgery can only decrease edge weights).

## 4. Algorithms

### 4.1 Computing Charged Surgery Distance

The charged surgery distance can be computed in O(|V|³) time using the Floyd-Warshall algorithm on the modified weight matrix.

```
Algorithm: ChargedSurgeryDistance(W, A, u, v, λ, κ)
Input: Weight matrix W, potential A, wormhole (u,v), parameters λ, κ
Output: Distance matrix D_charged

1. Compute penalty = λ + κ * |A[u] - A[v]|
2. W_mod = copy(W)
3. W_mod[u][v] = min(W[u][v], penalty)
4. W_mod[v][u] = min(W[v][u], penalty)
5. D_charged = FloydWarshall(W_mod)
6. Return D_charged
```

Time complexity: O(|V|³) for Floyd-Warshall.
Space complexity: O(|V|²) for the distance matrix.

### 4.2 Optimal Wormhole Placement

Given a graph and potential field, find the wormhole placement (u, v) that minimizes the maximum charged distance:

```
Algorithm: OptimalChargedWormhole(W, A, λ, κ)
Input: Weight matrix W, potential A, parameters λ, κ
Output: Optimal wormhole placement (u*, v*)

1. best_cost = ∞
2. For each pair (u, v) with u ≠ v:
   a. penalty = λ + κ * |A[u] - A[v]|
   b. D = ChargedSurgeryDistance(W, A, u, v, λ, κ)
   c. cost = max(D[x][y] for all x, y)
   d. If cost < best_cost: best_cost = cost, (u*, v*) = (u, v)
3. Return (u*, v*)
```

Time complexity: O(|V|⁵) (|V|² pairs × |V|³ Floyd-Warshall).

## 5. Applications

### 5.1 Electrical Network Design

Consider a power grid with n substations, where W(i,j) is the transmission loss between substations i and j, and A(i) is the operating voltage at substation i.

Adding a new transmission line between substations u and v costs λ (base construction) plus κ|A(u) - A(v)| (transformer equipment for voltage conversion). The charged surgery bound gives the optimal improvement in transmission loss:

d_charged(x, y) ≤ min(d_W(x,y), d_W(x,u) + λ + κ|A(u)-A(v)| + d_W(v,y))

### 5.2 Supply Chain Optimization

In a supply chain network, vertices represent facilities, W(i,j) is the shipping cost, and A(i) is the quality standard at facility i. A new direct link between facilities u and v incurs quality control overhead proportional to the standard mismatch.

### 5.3 Worked Example

Consider a 4-vertex graph with vertices {0, 1, 2, 3}:
- W(0,1) = 2, W(1,2) = 100, W(2,3) = 2, W(0,3) = 100 (all other edges = 1000)
- Potential A: A(0) = 0, A(1) = 0, A(2) = 5, A(3) = 5
- Wormhole: u = 1, v = 2, λ = 1, κ = 1

Charged penalty = 1 + 1 · |0 - 5| = 6
Uncharged penalty = 1

Original d(0, 3) via 0→1→2→3 = 2 + 100 + 2 = 104, or 0→3 = 100. So d_W(0,3) = 100.
Uncharged d(0, 3) via 0→1→2→3 = 2 + 1 + 2 = 5. So d_uncharged(0,3) = 5.
Charged d(0, 3) via 0→1→2→3 = 2 + 6 + 2 = 10. So d_charged(0,3) = 10.

Verification: 5 ≤ 10 ≤ 100 ✓ (sandwich inequality)
Charge defect contribution: 10 - 5 = 5 = κ · |A(1) - A(2)| ✓

## 6. Discussion

### 6.1 Relation to Prior Work

The classical wormhole surgery theorem is due to various authors in the shortest-path and tropical geometry literature. Our contribution is the gauge-covariant extension, which has no direct precedent.

The gauge invariance property connects to the extensive literature on discrete gauge theory and lattice gauge theory in mathematical physics. However, our setting (min-plus algebra rather than multiplicative groups) is novel.

### 6.2 Limitations

The current framework handles single-wormhole surgery. Extension to multiple wormholes with interacting charge defects is an important open problem. Additionally, the perturbative comparison bound (charged ≤ uncharged + defect) requires a walk surgery argument that is not yet fully formalized.

### 6.3 Open Problems

1. **Walk surgery lemma**: Prove that in nonneg-weight graphs, optimal walks use each wormhole at most once. This would complete the perturbative comparison proof.

2. **Multi-wormhole surgery**: Extend to simultaneous insertion of multiple wormholes with subadditive interaction bounds.

3. **Tropical Laplacian connection**: Relate the gauge potential to tropical harmonic functions and the tropical Laplacian.

4. **Categorical framework**: Define a category of weighted graphs with charged surgeries as morphisms.

5. **Spectral perturbation**: Bound the tropical spectral radius change under charged surgery.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed conjectural theorem statements and research roadmap.

## 8. References

1. Maclagan, D., Sturmfels, B. (2015). Introduction to Tropical Geometry. Graduate Studies in Mathematics, AMS.

2. Butkovič, P. (2010). Max-linear Systems: Theory and Algorithms. Springer.

3. Akian, M., Bapat, R., Gaubert, S. (2006). Min-plus methods in eigenvalue perturbation theory and generalised Lidskii-Vishik-Ljusternik theorem.

4. Mikhalkin, G. (2006). Tropical geometry and its applications. Proceedings of the ICM.

5. Joswig, M. (2021). Essentials of Tropical Combinatorics. Graduate Studies in Mathematics, AMS.
