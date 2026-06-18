# Future Directions: Tropical Divisor Theory in Lean

## Overview

This document outlines 5 concrete next theorems extending the formalized tropical divisor theory on trees to a full tropical algebraic geometry library. Each direction includes exact theorem statements, proof strategies, and cross-domain significance.

---

## Direction 1: Critical Groups and the Graph Jacobian

### Target Theorem
For a connected graph G on n vertices, define the **Jacobian** (critical group) as:
```
Jac(G) = Div⁰(G) / Prin(G)
```
where Div⁰ is the group of degree-zero divisors and Prin is the subgroup of principal divisors.

**Theorem (Kirchhoff's Matrix-Tree Theorem):**
```lean
theorem jacobian_order_eq_spanning_trees
    (G : SimpleGraph V) [Fintype V] [DecidableEq V]
    (hconn : G.Connected) :
    Fintype.card (Jac G) = G.spanningTreeCount
```

### Proof Strategy
1. Define `Jac G` as a quotient type `(V → ℤ) ⧸ image(Laplacian)` restricted to degree zero.
2. Use the Smith normal form of the Laplacian matrix to compute the order.
3. Connect to spanning tree enumeration via Kirchhoff's theorem.

### Cross-Domain Significance
- **Number theory:** Critical groups connect to class groups of number fields via arithmetic graphs.
- **Coding theory:** The critical group determines the code associated to G.
- **Statistical physics:** Order of Jac(G) = number of recurrent sandpile configurations.

### Hypotheses to Validate
- H1: The tree case (Jac = 0) follows as a corollary (already proved).
- H2: For cycle graphs C_n, Jac(C_n) ≅ ℤ/nℤ.
- H3: For complete graphs K_n, |Jac(K_n)| = n^{n-2} (Cayley's formula).

---

## Direction 2: Reduced Divisors and Dhar's Burning Algorithm

### Target Theorem
Fix a vertex q ∈ V. A divisor D is **q-reduced** if D(v) ≥ 0 for all v ≠ q, and no nonempty subset S ⊆ V \ {q} can be fired (i.e., for every nonempty S, some v ∈ S has D(v) < |{w ∈ S^c : w ~ v}|).

**Theorem (Uniqueness of Reduced Representative):**
```lean
theorem unique_reduced_representative
    (G : SimpleGraph V) (hconn : G.Connected)
    (q : V) (D : Divisor V) :
    ∃! D' : Divisor V, LinearEquivalent G D D' ∧ IsQReduced G q D'
```

### Proof Strategy
1. Define `IsQReduced G q D` as a predicate.
2. **Existence:** Use iterated firing to reach a reduced form (termination by energy argument).
3. **Uniqueness:** If D₁ ~ D₂ are both q-reduced, show D₁ = D₂ by analyzing the principal divisor div(f) = D₂ - D₁ and using the reduced property to force f = const.

### Algorithm: Dhar's Burning Test
```
function IsBurnable(G, q, S):
    // S ⊆ V \ {q}
    fire ← {q}
    while ∃ v ∈ V \ fire with |{w ∈ fire : w ~ v}| > D(v):
        fire ← fire ∪ {v}
    return fire = V
```

### Cross-Domain Significance
- **Algorithmic:** Dhar's algorithm is the key primitive for computing in Jac(G).
- **Combinatorics:** Reduced divisors biject with G-parking functions.
- **TCS:** Termination of chip-firing relates to lattice theory (Abelian sandpile lattice).

---

## Direction 3: Baker–Norine Riemann–Roch for Finite Graphs

### Target Theorem
Define the **rank** of a divisor D on a graph G:
```
r(D) = max{k ≥ -1 : ∀ E effective with deg(E) = k+1, D - E has an effective representative}
```

**Theorem (Baker–Norine [2007]):**
```lean
theorem baker_norine_riemann_roch
    (G : SimpleGraph V) (hconn : G.Connected)
    (D : Divisor V) :
    r(D) - r(K - D) = deg(D) - g + 1
```
where K is the canonical divisor K(v) = deg(v) - 2 and g = |E| - |V| + 1 is the genus.

### Proof Strategy
This is a major formalization effort. The proof in Baker–Norine proceeds via:
1. Establishing properties of the rank function (monotonicity, bounds).
2. Proving Riemann–Roch for the canonical divisor.
3. Using Serre duality (D ↦ K - D) and the reduced divisor theory.
4. The key step is showing that for each linear equivalence class, the set of effective divisors linearly equivalent to D is determined by the q-reduced representative.

### Building Blocks Required
- Reduced divisors (Direction 2)
- Canonical divisor definition
- Genus computation from edge/vertex counts
- Rank function properties

### Cross-Domain Significance
- **Algebraic geometry:** Tropical Riemann–Roch is a shadow of the classical theorem.
- **Combinatorics:** Connects chip-firing to matroid theory via tropical linear series.
- **Cryptography:** Jacobian-based cryptosystems rely on the hardness of the divisor class group.

---

## Direction 4: Certified Chip-Firing Normalization

### Target Theorem
Formalize the leaf-firing algorithm as a certified computation:

```lean
theorem certified_normalization
    (G : SimpleGraph V) (hconn : G.Connected) (htree : G.IsAcyclic)
    (D : Divisor V) (v₀ : V) :
    ∃ f : V → ℤ,
      (∀ v, v ≠ v₀ → (D v + PrincipalDivisor G f v = 0)) ∧
      (D v₀ + PrincipalDivisor G f v₀ = divisorDegree D)
```

with a computable `f` given by the subtree-sum construction.

### Proof Strategy
1. Define `f` via the subtree-sum formula: f(v₀) = 0, f(v) = f(parent(v)) + ∑_{u ∈ subtree(v)} D(u).
2. Verify the Laplacian equation vertex by vertex.
3. The computation is concrete and should be directly checkable.

### Cross-Domain Significance
- **TCS:** Certified algorithms with machine-checked correctness proofs.
- **Network optimization:** Provably correct load-balancing schedules.
- **Formal methods:** Template for certifying graph algorithms.

---

## Direction 5: Tropical Rational Functions and Semiring Connections

### Target Theorem
A **tropical rational function** on a graph G is a piecewise-linear function f : V → ℤ. Its **tropical divisor** is div(f). Connect this to the max-plus semiring structure:

```lean
theorem tropical_divisor_characterization
    (G : SimpleGraph V) (f : V → ℤ) :
    PrincipalDivisor G f v =
      (⨆ w ∈ G.neighborFinset v, (f w - f v)) +
      (⨅ w ∈ G.neighborFinset v, (f w - f v)) +
      (something involving valence)
```

More precisely, establish the connection between:
- The graph Laplacian (our PrincipalDivisor)
- The tropical semiring operations (max, +)
- Piecewise-linear functions on metric graphs

### Proof Strategy
1. Define tropical rational functions as PL functions on the metric realization of G.
2. Show that integer-valued PL functions on vertices correspond to our `V → ℤ`.
3. Establish that the "order of vanishing" at a vertex v equals the Laplacian value.
4. Connect to the max-plus algebra via the slope formula.

### Cross-Domain Significance
- **Tropical geometry:** Bridge between combinatorial and geometric definitions.
- **Optimization:** Max-plus algebra is the language of scheduling and shortest paths.
- **Mirror symmetry:** Tropical curves play a central role in enumerative mirror symmetry.

---

## Implementation Priority

| Direction | Difficulty | Dependencies | Impact |
|-----------|-----------|-------------|--------|
| 4 (Certified normalization) | Low | Current work | High |
| 1 (Jacobian/critical group) | Medium | Quotient types | Very High |
| 2 (Reduced divisors) | Medium | Direction 1 | High |
| 5 (Tropical semiring) | Medium | None | Medium |
| 3 (Baker–Norine) | Very High | Directions 1, 2 | Transformative |

**Recommended execution order:** 4 → 1 → 2 → 5 → 3.

Direction 4 is nearly complete (the subtree-sum construction is already implemented in Python; formalizing it requires only a direct computation). Direction 1 requires quotient type infrastructure. Direction 3 is the ultimate goal but requires all preceding directions as prerequisites.

---

## Team Directive

Each direction should be pursued by a team that:
1. **States exact theorems** in Lean before attempting proofs.
2. **Validates with computational experiments** (Python implementations).
3. **Decomposes into ≤ 10 helper lemmas** per theorem.
4. **Builds on existing infrastructure** (import the current DivisorTheory module).
5. **Documents cross-domain connections** in code comments and companion articles.

The goal is not to prove isolated theorems but to build a **coherent tropical geometry library** that can eventually support research-level formalization of Baker–Norine theory and beyond.
