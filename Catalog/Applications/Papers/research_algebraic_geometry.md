# Formal Tropical Divisor Theory on Trees: Triviality of the Tree Jacobian and Genus-Zero Riemann–Roch

## Abstract

We present a complete formalization of the foundational theory of divisors on finite trees, viewed as genus-zero tropical curves. Working in Lean 4 with Mathlib, we prove three main results: (1) the triviality of the tree Jacobian — every degree-zero divisor on a connected tree is principal; (2) the tree divisor singleton theorem — every divisor is linearly equivalent to one concentrated at a single vertex; and (3) the effective representative theorem — every divisor of nonneg degree admits an effective (pointwise nonneg) representative. These results constitute the genus-zero case of tropical Riemann–Roch theory and provide the formal foundation for extending divisor theory to graphs of higher genus.

**Keywords:** tropical geometry, divisors on graphs, chip-firing, graph Laplacian, Baker–Norine theorem, Riemann–Roch, Jacobian of a graph, critical group, formal verification

## 1. Introduction

### 1.1 Motivation

Tropical geometry, developed through the work of Mikhalkin, Gathmann, Sturmfels, and many others, provides a combinatorial shadow of classical algebraic geometry via piecewise-linear structures. A central object in this theory is the *tropical curve*, which in its simplest form is a finite metric graph. The divisor theory of tropical curves — pioneered by Baker and Norine [BN07] in their celebrated combinatorial Riemann–Roch theorem — connects graph-theoretic chip-firing to deep algebraic geometry.

The present work formalizes the base case of this theory: divisors on trees, which are tropical curves of genus zero. While mathematically well-understood, the formalization provides:

1. A machine-verified foundation for tropical Brill–Noether theory.
2. An explicit, constructive algorithm for divisor normalization with certified correctness.
3. A template for extending formal divisor theory to graphs of arbitrary genus.

### 1.2 Relationship to Prior Work

The mathematical content traces to Baker and Norine [BN07], with antecedents in Dhar's work on abelian sandpiles [Dha90] and the earlier development of chip-firing by Björner, Lovász, and Shor [BLS91]. The genus-zero case is folklore in the combinatorics community but, to our knowledge, has not previously been machine-verified.

Our formalization uses Lean 4 with the Mathlib library, leveraging its extensive API for finite graphs (`SimpleGraph`), finsets, and fintype.

## 2. Definitions and Notation

### 2.1 Graphs and Trees

We work with `SimpleGraph V` for a finite type `V` with `[Fintype V]` and `[DecidableEq V]`. A graph is a *tree* if it is connected (`G.Connected`) and acyclic (`G.IsAcyclic`).

### 2.2 Divisors

A **divisor** on a graph G with vertex set V is a function `D : V → ℤ`. The **degree** of D is:

$$\deg(D) = \sum_{v \in V} D(v)$$

### 2.3 Principal Divisors

Given a function `f : V → ℤ`, the **principal divisor** (graph Laplacian) is:

$$\operatorname{div}(f)(v) = \sum_{w \sim v} (f(w) - f(v))$$

where the sum ranges over neighbors of v in G.

### 2.4 Linear Equivalence

Two divisors D₁, D₂ are **linearly equivalent**, written D₁ ~ D₂, if there exists f : V → ℤ such that D₂(v) = D₁(v) + div(f)(v) for all v.

### 2.5 Effectiveness

A divisor D is **effective** if D(v) ≥ 0 for all v.

## 3. Main Results

### 3.1 Theorem: Principal Divisors Have Degree Zero

**Statement.** For any f : V → ℤ, deg(div(f)) = 0.

**Proof sketch.** Expand the double sum and use symmetry of adjacency:

$$\sum_v \sum_{w \sim v} (f(w) - f(v)) = \sum_v \sum_{w \sim v} f(w) - \sum_v \sum_{w \sim v} f(v)$$

By interchanging summation order and using G.adj_comm, both sums are equal. ∎

### 3.2 Theorem: Linear Equivalence Preserves Degree

**Statement.** If D ~ E then deg(D) = deg(E).

**Proof.** Immediate from Theorem 3.1 and the definition of linear equivalence. ∎

### 3.3 Theorem: Existence of Leaves

**Statement.** Every finite tree with |V| ≥ 2 has a vertex of degree 1.

**Proof sketch.** A tree on n vertices has n-1 edges. The sum of degrees is 2(n-1). Since the graph is connected with n ≥ 2, every vertex has degree ≥ 1. If all had degree ≥ 2, the sum would be ≥ 2n > 2(n-1), contradiction. ∎

### 3.4 Theorem: Triviality of the Tree Jacobian

**Statement.** Let G be a connected tree. If deg(E) = 0, then E is a principal divisor.

This is the algebraic heart of the formalization. It asserts Jac(G) = 0 for trees.

**Proof.** By strong induction on |V|.

*Base case* (|V| = 1): E(v) = deg(E) = 0, so E = div(0).

*Inductive step* (|V| ≥ 2): Find a leaf ℓ with unique neighbor n. Define g : V → ℤ by g(ℓ) = -E(ℓ), g(v) = 0 for v ≠ ℓ. Then:
- div(g)(ℓ) = E(ℓ) (since ℓ has unique neighbor n)
- div(g)(n) = -E(ℓ) (contribution from ℓ)
- div(g)(v) = 0 for v ∉ {ℓ, n}

Set E' = E - div(g). Then E'(ℓ) = 0 and deg(E') = 0.

Restrict to the induced subgraph G' = G[V \ {ℓ}]. Key lemmas:
- G' is acyclic (subgraph of acyclic graph).
- G' is connected (a path between non-leaf vertices in G avoids ℓ, since any path through ℓ would require ℓ to have degree ≥ 2).
- |V'| = |V| - 1.

By induction, find f' : V' → ℤ with E'|_{V'} = div_{G'}(f'). Normalize: replace f' by f' - f'(n) (Laplacian kills constants). Extend to f₀ : V → ℤ with f₀(ℓ) = 0, f₀(v) = f'(v) for v ≠ ℓ. Then f₀(n) = 0.

Verify: div_G(f₀) = E' at every vertex. Finally, E = E' + div(g) = div(f₀) + div(g) = div(f₀ + g). ∎

### 3.5 Theorem: Tree Divisor Singleton

**Statement.** For any divisor D on a connected tree G, there exists v₀ ∈ V such that D ~ deg(D) · δ_{v₀}.

**Proof.** Choose any v₀. The divisor E = D - deg(D) · δ_{v₀} has degree 0. By Theorem 3.4, E is principal: E = div(f). Then D = deg(D) · δ_{v₀} + div(f), so D ~ deg(D) · δ_{v₀}. ∎

### 3.6 Theorem: Effective Representative

**Statement.** If deg(D) ≥ 0, then D is linearly equivalent to an effective divisor.

**Proof.** By Theorem 3.5, D ~ deg(D) · δ_{v₀}. Since deg(D) ≥ 0, this divisor is effective. ∎

## 4. Algorithms

### 4.1 Subtree Sum Construction

**Input:** Tree T rooted at v₀, divisor D.
**Output:** Function f with D + div(f) = deg(D) · δ_{v₀}.

```
function SubtreeSum(T, D, v₀):
    parent ← BFS(T, v₀)
    order ← BFS-order from v₀
    
    // Bottom-up: compute subtree sums
    S[v] ← D[v] for all v
    for v in reverse(order):
        if parent[v] ≠ null:
            S[parent[v]] += S[v]
    
    // Top-down: compute f
    f[v₀] ← 0
    for v in order:
        if v ≠ v₀:
            f[v] ← f[parent[v]] + S[v]
    
    return f
```

**Complexity:** O(n) time, O(n) space.

**Correctness:** For v ≠ v₀: div(f)(v) = -D(v), so D(v) + div(f)(v) = 0. For v₀: div(f)(v₀) = deg(D) - D(v₀), so D(v₀) + div(f)(v₀) = deg(D).

### 4.2 Leaf-Firing Normalization

An alternative algorithm processes leaves iteratively. While equivalent in output, it more closely mirrors the inductive proof structure and is simpler to implement.

**Complexity:** O(n) time, O(n) space.

## 5. Applications

### 5.1 Electrical Networks

On a tree network with unit resistors, the Laplacian equation Δf = I (current injection I) has a solution iff ∑I(v) = 0 (Kirchhoff's current law). The tree Jacobian triviality guarantees existence and uniqueness (up to a global constant) of the voltage distribution.

### 5.2 Abelian Sandpile Model

The sandpile model on a tree with a distinguished sink has critical group isomorphic to the Jacobian. Since the tree Jacobian is trivial, every recurrent configuration is equivalent to every other — the sandpile dynamics on trees have no nontrivial invariants.

### 5.3 Network Load Balancing

In tree-structured networks (e.g., hierarchical data centers), the normalization algorithm provides an optimal strategy for consolidating distributed resources at a central node. The certificate (firing function) serves as a verifiable schedule.

## 6. Computational Experiments

We implemented both the subtree-sum and leaf-firing algorithms in Python and verified them on trees of various topologies (paths, stars, caterpillars, complete binary trees) and sizes (up to n = 10⁶ vertices). All experiments confirm:

| Property | Observed | Expected |
|----------|----------|----------|
| deg(div(f)) = 0 | Always | Theorem 3.1 |
| Singleton concentration | Always | Theorem 3.5 |
| Effective representative (deg ≥ 0) | Always | Theorem 3.6 |
| Algorithm time | O(n) | Theory |

The subtree-sum construction produces identical results to the leaf-firing algorithm for the same target vertex, confirming their mathematical equivalence.

## 7. Discussion

### 7.1 Relationship to Classical Algebraic Geometry

Trees are tropical curves of genus zero. The Picard group Pic⁰(T) of a tree T is trivial, corresponding to the classical fact that Pic⁰(ℙ¹) = 0 (the Picard group of the projective line is trivial). The effective representative theorem corresponds to the genus-zero case of the Riemann–Roch theorem: r(D) = deg(D) for deg(D) ≥ 0.

### 7.2 Limitations and Extensions

The current formalization is restricted to:
- Simple graphs (no multi-edges or loops)
- Unweighted edges (unit lengths)
- Trees (genus zero)

Extending to general finite graphs requires developing the theory of reduced divisors, Dhar's burning algorithm, and the Baker–Norine rank formula.

### 7.3 Formalization Challenges

The main formalization challenge was the inductive proof of Jacobian triviality (Theorem 3.4), which requires:
1. Working with induced subgraphs on subtypes `{v : V // v ≠ ℓ}`
2. Proving connectivity is preserved when a leaf is deleted
3. Translating between the Laplacian on the subgraph and the full graph
4. The normalization step (adjusting the firing function to ensure compatibility)

Each of these steps involves significant type-theoretic bookkeeping absent from informal proofs.

## 8. Future Work

1. **Baker–Norine Riemann–Roch** for finite graphs.
2. **Dhar's burning algorithm** and reduced divisors.
3. **Tropical Jacobians** and critical groups as quotient types.
4. **Weighted graphs** and metric graph divisor theory.
5. **Tropical moduli spaces** M_{g,n}^{trop}.

## References

- [BN07] M. Baker, S. Norine. *Riemann–Roch and Abel–Jacobi theory on a finite graph.* Advances in Mathematics 215 (2007), 766–788.
- [BLS91] A. Björner, L. Lovász, P. Shor. *Chip-firing games on graphs.* European J. Combin. 12 (1991), 283–291.
- [Dha90] D. Dhar. *Self-organized critical state of sandpile automaton models.* Phys. Rev. Lett. 64 (1990), 1613–1616.
- [GK08] A. Gathmann, M. Kerber. *A Riemann–Roch theorem in tropical geometry.* Math. Z. 259 (2008), 217–230.
- [MS15] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry.* AMS, 2015.
