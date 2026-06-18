# Viral Information Topology: Sheaf Cohomology of Meme Propagation on Social Networks

## Abstract

We develop a mathematical framework for meme propagation over social networks using cellular sheaf cohomology on graphs. A meme is modeled as a section of a sheaf over the network graph, where vertices represent individuals or communities and edges represent communication channels. The zeroth cohomology group H⁰ measures the space of consistent meme interpretations (polysemy), while the first cohomology H¹ measures propagation obstructions. We prove five main results: (1) the **Walk Telescope Theorem**, establishing that consistent sections propagate faithfully along graph walks; (2) the **Monodromy Obstruction Theorem**, showing that twisted sheaves with non-trivial monodromy around cycles admit no nonzero global sections; (3) the **Spectral-Cohomological Bridge**, proving that H⁰ of the constant sheaf equals the kernel of the graph Laplacian; (4) the **Equilibrium Theorem**, showing that consistent sections are exactly the fixed points of diffusion dynamics; and (5) the **H⁰ Monotonicity Theorem**, establishing that adding edges can only decrease the space of consistent sections. We state a falsifiable conjecture connecting the Erdős-Rényi connectivity threshold to a phase transition in meme polysemy. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: sheaf cohomology, graph theory, meme propagation, social networks, spectral graph theory, monodromy, information topology

---

## 1. Introduction

The propagation of information through social networks is a central problem in computational social science, epidemiology, and marketing. Classical models—SIR, Bass diffusion, threshold models—treat information as a scalar quantity that either is or is not adopted by each individual. These models capture *extent* of propagation but miss a crucial phenomenon: **meaning transformation**. A meme that means "scientific breakthrough" in an academic community may mean "health tip" in a wellness community and "government conspiracy" in a conspiracy community. The meme spreads precisely *because* it accommodates multiple interpretations.

We propose that the correct mathematical framework for this phenomenon is **cellular sheaf cohomology on graphs**. A cellular sheaf on a graph G = (V, E) assigns a vector space (the *stalk*) to each vertex and each edge, with *restriction maps* connecting them. The zeroth cohomology H⁰(G, F) of a sheaf F measures the space of *global sections*—assignments of values to all vertices that are compatible across all edges. The first cohomology H¹(G, F) measures the *obstruction* to extending local sections to global ones.

In our framework:
- **H⁰ dimension** = number of independent meme interpretations (polysemy)
- **H¹ dimension** = number of independent propagation barriers
- **Virality** ≈ dim H⁰ / (1 + dim H¹)

The most viral memes have H¹ = 0 (no barriers) and large dim H⁰ (many interpretations). This is the polysemy-virality hypothesis.

### 1.1 Related Work

Sheaves on graphs were introduced by Shepard [1] and developed extensively by Curry [2] and Ghrist-Hansen [3]. Robinson [4] connected cellular sheaves to signal processing on networks. Our contribution is the application to information propagation with a focus on the monodromy obstruction and the spectral-cohomological bridge.

Graph-based information diffusion has been studied through spectral methods [5], gossip algorithms [6], and opinion dynamics [7]. Our work unifies these through the sheaf-theoretic lens.

## 2. Definitions

### 2.1 Consistent Sections

**Definition 2.1** (Consistent Section). Let G = (V, E) be a simple graph and R a type. A function f : V → R is a *consistent section* of the constant R-sheaf on G if for all adjacent vertices u, v ∈ V:

f(u) = f(v)

The set of consistent sections is denoted H⁰(G, R).

**Definition 2.2** (H⁰ Submodule). When R is a commutative semiring, H⁰(G, R) forms a submodule of the function space V → R. This is the *zeroth cohomology submodule*.

### 2.2 Coboundary Map

**Definition 2.3** (Coboundary Operator). For a graph G with decidable adjacency, the coboundary operator δ : (V → ℚ) → (V × V → ℚ) is:

δ(f)(u, v) = f(v) − f(u) if G.Adj(u, v), else 0

The consistent sections are exactly ker(δ): we proved H⁰(G, ℚ) = ker(δ).

### 2.3 Twisted Meme Sheaf

**Definition 2.4** (Twisted Meme Sheaf). A twisted meme sheaf S on a graph G with vertices Fin n consists of:
- A twist function τ : Fin n → Fin n → ℚ
- Non-degeneracy: τ(i, j) ≠ 0 for all edges (i, j)
- Reciprocity: τ(i, j) · τ(j, i) = 1 for all edges (i, j)

**Definition 2.5** (Twisted Consistency). A function f : Fin n → ℚ is twisted-consistent if for all adjacent i, j:

f(j) = τ(i, j) · f(i)

When all twists are 1 (the *constant sheaf*), twisted consistency reduces to ordinary consistency.

### 2.4 Monodromy

**Definition 2.6** (Walk Monodromy). The monodromy of a twisted sheaf S along a walk w is the product of twist factors along the walk's darts:

mon(S, w) = ∏_{d ∈ darts(w)} τ(d.src, d.tgt)

### 2.5 Graph Laplacian

**Definition 2.7** (Graph Laplacian). For a graph G on Fin n, the Laplacian L is the n × n integer matrix:

L(i, j) = deg(i) if i = j; −1 if adj(i, j); 0 otherwise

### 2.6 Virality Index

**Definition 2.8** (Virality Index). For a meme sheaf with total interpretation capacity n and H¹ dimension h₁:

V(n, h₁) = n / (1 + h₁)

## 3. Main Results

### 3.1 Walk Telescope Theorem

**Theorem 3.1** (Walk Telescope). If f is a consistent section and w is a walk from u to v in G, then f(u) = f(v).

*Proof sketch*. By induction on the walk structure. The base case (nil walk) is trivial. For a cons walk u → x ⟶ v, consistency gives f(u) = f(x), and the inductive hypothesis gives f(x) = f(v). □

**Corollary 3.2**. On a connected graph, every consistent section is constant.

### 3.2 Polysemy-Connectivity Duality

**Theorem 3.3** (Indicator Sections). For any set S ⊆ V that is upward-closed under adjacency (if u ∈ S and u ~ v then v ∈ S), the indicator function 1_S is a consistent ℤ-section.

**Theorem 3.4** (Separating Sections). If u and v are in different connected components, there exists a consistent section f with f(u) ≠ f(v).

These two results establish that **dim H⁰ equals the number of connected components** for the constant sheaf over ℤ. Each component contributes one independent consistent section.

### 3.3 Monodromy Obstruction Theorem

**Theorem 3.5** (Monodromy Transport). For a twisted-consistent section f and walk w from u to v:

f(v) = mon(S, w) · f(u)

*Proof sketch*. Induction on the walk. At each step, the twisted consistency condition f(x) = τ(u, x) · f(u) introduces one factor. The product telescopes. □

**Theorem 3.6** (Monodromy Obstruction). If a closed walk w from u to u has monodromy mon(S, w) ≠ 1, then every twisted-consistent section satisfies f(u) = 0.

*Proof*. By Theorem 3.5, f(u) = mon(S, w) · f(u). Thus (mon(S, w) − 1) · f(u) = 0. Since ℚ has no zero divisors and mon(S, w) ≠ 1, we conclude f(u) = 0. □

**Theorem 3.7** (Global Vanishing). On a connected graph with a cycle carrying non-trivial monodromy, the only twisted-consistent section is the zero function.

*Proof*. By Theorem 3.6, f(u) = 0 at the base vertex. For any other vertex v, connectivity provides a walk from u to v. By Theorem 3.5, f(v) = mon(S, w') · 0 = 0. □

**Remark**. This result has a beautiful interpretation: a meme whose meaning "rotates" as it travels around a social cycle cannot sustain any coherent interpretation. It is the sheaf-theoretic analog of the Bohr-Sommerfeld quantization condition in physics.

### 3.4 Spectral-Cohomological Bridge

**Theorem 3.8** (Forward Bridge). If f is a consistent section, then Lf = 0 (f is in the kernel of the Laplacian).

*Proof sketch*. Row i of Lf computes deg(i)·f(i) − Σ_{j~i} f(j). Since f is consistent, each f(j) = f(i), so the sum equals deg(i)·f(i), and the row value is 0. □

**Theorem 3.9** (Reverse Bridge). If Lf = 0, then f is a consistent section.

*Proof sketch*. Consider the quadratic form f^T L f = Σ_{i~j} (f(i) − f(j))². If Lf = 0, then f^T L f = 0. Since each term is a non-negative integer squared, all terms vanish: f(i) = f(j) for all edges. □

**Corollary 3.10**. H⁰(G, ℤ) = ker(L). The sheaf-cohomological and spectral characterizations agree exactly.

### 3.5 H⁰ Monotonicity

**Theorem 3.11** (Edge Monotonicity). If G ≤ H (G is a subgraph of H), then H⁰(H, R) ⊆ H⁰(G, R).

**Corollary 3.12** (Extremal Duality). The complete graph has the smallest H⁰ (dimension 1 on a connected graph), and the empty graph has the largest (dimension |V|).

### 3.6 Equilibrium Theorem

**Theorem 3.13** (Propagation Equilibrium). A consistent section is a fixed point of the propagation dynamics (each vertex averages its neighbors' values).

*Proof sketch*. At vertex i with neighbors N(i), all f(j) = f(i) for j ∈ N(i). The average is f(i). □

### 3.7 Virality Optimization

**Theorem 3.14** (Virality Maximization). V(n, h₁) ≤ V(n, 0) for all h₁ ≥ 0. Virality is maximized when H¹ = 0.

**Theorem 3.15** (Strict Decrease). For positive interpretation capacity, virality strictly decreases with increasing H¹ dimension.

## 4. The Phase Transition Conjecture

**Conjecture 4.1** (Viral Phase Transition). For the Erdős-Rényi random graph G(n, p) with the constant ℤ-sheaf:
- If p < ln(n)/n, then dim H⁰ > 1 with high probability
- If p > ln(n)/n, then dim H⁰ = 1 with high probability

This conjecture follows from the classical Erdős-Rényi connectivity threshold: below ln(n)/n, the graph is almost surely disconnected (multiple components = multiple interpretations), and above it, almost surely connected (single component = single interpretation).

**Verified extremes**: We formally proved that:
- The complete graph (p = 1) has dim H⁰ = 1
- The empty graph (p = 0) has dim H⁰ = n

**Computational test**: For n = 1000, the threshold is p ≈ 0.0069. Monte Carlo simulation with 10⁴ samples should show >90% disconnection at p = 0.005 and >90% connection at p = 0.010.

## 5. Algorithms

### 5.1 Computing H⁰ Dimension

For the constant sheaf, dim H⁰ equals the number of connected components, computable via BFS/DFS in O(|V| + |E|) time.

### 5.2 Computing Monodromy

For a twisted sheaf, monodromy along a walk is computed by multiplying twist factors: O(|walk length|) arithmetic operations.

### 5.3 Detecting Obstruction

To determine if H¹ = 0 for a twisted sheaf on a connected graph:
1. Build a spanning tree T of G
2. For each non-tree edge e, compute the monodromy around the fundamental cycle of e
3. H¹ = 0 iff all fundamental cycle monodromies equal 1

This runs in O(|V| + |E|) time (dominated by DFS/BFS for the spanning tree).

## 6. Discussion

### 6.1 Biological Interpretation

The monodromy obstruction has a direct biological analog. In epidemiology, a pathogen that mutates as it passes between populations may become "self-incompatible"—unable to reinfect its population of origin because the mutated version is unrecognizable. This is monodromy ≠ 1 around the social cycle.

### 6.2 Financial Contagion

In financial networks, the "twist factors" can model exchange rates or risk transformations. The monodromy condition τ(A→B)·τ(B→C)·τ(C→A) = 1 is the no-arbitrage condition. Non-trivial monodromy = arbitrage opportunity = instability. The Global Vanishing Theorem then says: arbitrage opportunities cannot coexist with stable equilibria.

### 6.3 Limitations

Our model assumes:
1. Linear interpretation spaces (real-world interpretations may be nonlinear)
2. Deterministic restriction maps (real propagation involves noise)
3. Static networks (social networks evolve over time)

Extensions to sheaves of nonlinear spaces, stochastic restriction maps, and time-varying graphs are natural directions for future work.

## 7. Conclusion

We have established that meme virality is fundamentally a topological phenomenon. The sheaf cohomology of the network-meme pair determines propagation potential: H⁰ counts interpretations, H¹ counts barriers, and monodromy detects self-inconsistency. The spectral-cohomological bridge connects this framework to the powerful tools of spectral graph theory. The phase transition conjecture provides a falsifiable prediction linking network structure to meme behavior.

The key takeaway: **the shape of the network matters more than the content of the message**. Topology has the final word on virality.

## References

[1] Shepard, A. (1985). A cellular description of the derived category of a stratified space. Brown University PhD thesis.

[2] Curry, J. (2014). Sheaves, cosheaves, and applications. University of Pennsylvania PhD thesis.

[3] Ghrist, R. & Hansen, J. (2022). "Opinions, Conflicts, and Consensus: Modeling Social Dynamics via Sheaves." *Topological Data Analysis*, Springer.

[4] Robinson, M. (2014). *Topological Signal Processing*. Springer.

[5] Chung, F. (1997). *Spectral Graph Theory*. AMS.

[6] Shah, D. (2009). "Gossip Algorithms." *Foundations and Trends in Networking* 3(1).

[7] DeGroot, M.H. (1974). "Reaching a Consensus." *Journal of the American Statistical Association* 69(345).
