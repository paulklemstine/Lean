# Tropical Compactification of Moduli Spaces: Combinatorial Foundations

## Abstract

We formalize the combinatorial backbone of the tropical compactification of the moduli space of curves M_g. We define stable graphs (encoding the combinatorial types of stable curves), tropical curves (metric graphs with genus labels), and prove the fundamental structural theorems connecting these objects to the Deligne-Mumford compactification. Our main results include: (1) the edge bound |E| ≤ 3g − 3 for stable graphs of genus g, following from a summation of the stability condition; (2) the codimension-one classification of boundary divisors as either separating or non-separating; (3) the count of ⌊g/2⌋ + 1 boundary divisors; and (4) the handshaking lemma for our graph representation. All results are formalized in Lean 4 with proofs checked by the Lean kernel.

## 1. Introduction

The moduli space M_g of smooth algebraic curves of genus g ≥ 2 is a fundamental object in algebraic geometry. Its Deligne-Mumford compactification M̄_g [DM69] parametrizes *stable curves* — connected curves with at worst nodal singularities and finite automorphism group. The boundary ∂M̄_g = M̄_g \ M_g is a normal crossing divisor whose combinatorial structure is governed by *stable graphs*.

The tropicalization of this picture, developed by Mikhalkin [Mik06], Gathmann-Markwig [GM07], and systematized by Abramovich-Caporaso-Payne [ACP15], replaces algebraic curves with metric graphs. The resulting tropical moduli space M_g^{trop} is a generalized cone complex whose cones correspond bijectively to the boundary strata of M̄_g.

In this work, we formalize the combinatorial foundations of this correspondence and prove the key structural theorems. Our formalization uses Lean 4 with the Mathlib library.

## 2. Definitions

### 2.1 Stable Graphs

**Definition 2.1** (Stable Graph). A *stable graph* Γ consists of:
- A finite set V of vertices, identified with Fin(n) for some n ≥ 1
- A finite set E of edges, identified with Fin(m)
- Endpoint maps src, tgt : E → V
- A genus function g : V → ℕ

The *valence* of a vertex v is:
  val(v) = |{e ∈ E : src(e) = v}| + |{e ∈ E : tgt(e) = v}|

The *first Betti number* is:
  β₁(Γ) = |E| - |V| + 1

The *total genus* is:
  g(Γ) = Σ_{v ∈ V} g(v) + β₁(Γ)

A vertex v is *stable* if 2g(v) - 2 + val(v) > 0.
A stable graph is *stable* if every vertex is stable.

### 2.2 Tropical Curves

**Definition 2.2** (Tropical Curve). A *tropical curve* of genus g is a stable graph Γ of total genus g equipped with a function ℓ : E → ℝ₊ assigning positive real lengths to each edge.

The *total length* (volume) of a tropical curve is Σ_{e ∈ E} ℓ(e).

### 2.3 Special Graphs

**Definition 2.3** (Smooth Graph). The *smooth graph* of genus g is the stable graph with one vertex of genus g and no edges.

**Definition 2.4** (Non-separating Divisor). For g ≥ 2, the graph δ_irr has one vertex of genus g-1 and one loop edge.

**Definition 2.5** (Separating Divisor). For 1 ≤ h ≤ g/2, the graph δ_h has two vertices of genera h and g-h connected by one edge.

## 3. Main Results

### 3.1 Genus and Stability of Special Graphs

**Theorem 3.1** (smoothGraph_totalGenus). The smooth graph of genus g has total genus g.

*Proof*. The sum of vertex genera is g (single vertex), and β₁ = 0 - 1 + 1 = 0. □

**Theorem 3.2** (smoothGraph_isStable). For g ≥ 2, the smooth graph is stable.

*Proof*. The unique vertex has genus g ≥ 2 and valence 0, so 2g - 2 + 0 = 2g - 2 ≥ 2 > 0. □

**Theorem 3.3** (smoothGraph_stratumDim). The stratum dimension of the smooth graph equals the moduli dimension 3g - 3.

*Proof*. stratumDim = 3g - 3 - 0 = 3g - 3 = moduliDim(g). □

### 3.2 Non-separating Boundary Divisor

**Theorem 3.4** (nonsep_totalGenus). The non-separating boundary divisor δ_irr has total genus g.

*Proof*. Vertex genus sum = g - 1, β₁ = 1 - 1 + 1 = 1. Total = g - 1 + 1 = g. □

**Theorem 3.5** (nonsep_isStable). For g ≥ 2, δ_irr is stable.

*Proof*. The unique vertex has genus g - 1 and valence 2 (loop). So 2(g-1) - 2 + 2 = 2g - 2 > 0. □

**Theorem 3.6** (nonsep_codimension_one). δ_irr has stratum dimension 3g - 4 = moduliDim(g) - 1.

### 3.3 Separating Boundary Divisors

**Theorem 3.7** (sep_totalGenus). For 1 ≤ h ≤ g/2, δ_h has total genus g.

*Proof*. Vertex genus sum = h + (g - h) = g, β₁ = 1 - 2 + 1 = 0. Total = g. □

**Theorem 3.8** (sep_isStable). For 1 ≤ h ≤ g/2, δ_h is stable.

*Proof*. Vertex 0 has genus h ≥ 1, valence 1: 2h - 2 + 1 = 2h - 1 ≥ 1 > 0.
Vertex 1 has genus g - h ≥ 1, valence 1: 2(g-h) - 1 ≥ 1 > 0. □

**Theorem 3.9** (sep_codimension_one). δ_h has stratum dimension moduliDim(g) - 1.

### 3.4 Boundary Divisor Counting

**Theorem 3.10** (boundary_divisor_count). The number of boundary divisors is ⌊g/2⌋ + 1.

*Proof*. There is 1 non-separating divisor and ⌊g/2⌋ separating divisors δ_h for h = 1, ..., ⌊g/2⌋. □

### 3.5 The Edge Bound

**Theorem 3.11** (edge_genus_inequality). For any stable graph Γ of total genus g, |E| ≤ 3g - 3.

*Proof sketch*. By stability, 2g(v) + val(v) ≥ 3 for each vertex v. Summing over all vertices:
  Σ_v (2g(v) + val(v)) ≥ 3|V|

By the handshaking lemma, Σ_v val(v) = 2|E|, so:
  2Σ_v g(v) + 2|E| ≥ 3|V|

Since g = Σ_v g(v) + |E| - |V| + 1, we have Σ_v g(v) = g - |E| + |V| - 1. Substituting:
  2(g - |E| + |V| - 1) + 2|E| ≥ 3|V|
  2g + 2|V| - 2 ≥ 3|V|
  |V| ≤ 2g - 2

Combined with |E| = g - Σ_v g(v) + |V| - 1 ≤ g + |V| - 1 ≤ g + 2g - 3 = 3g - 3. □

This inequality is sharp: equality holds precisely for trivalent graphs (all vertices have genus 0 and valence 3), which correspond to the maximal cones of M_g^{trop}.

### 3.6 The Handshaking Lemma

**Theorem 3.12** (handshaking_lemma). For any stable graph Γ, Σ_v val(v) = 2|E|.

*Proof*. Each edge e contributes 1 to the filter count of src(e) and 1 to the filter count of tgt(e). The sum telescopes by fiber counting. □

### 3.7 Tropical Curve Properties

**Theorem 3.13** (tropical_curve_positive_volume). Any tropical curve with at least one edge has positive total length.

**Theorem 3.14** (totalLength_nonneg). Every tropical curve has non-negative total length.

## 4. The Tropical-Algebraic Correspondence

### 4.1 Dimension Matching

The results above establish the key numerical coincidences:

1. The smooth graph has stratum dimension 3g - 3 = dim M_g (Theorem 3.3)
2. Each boundary divisor has stratum dimension 3g - 4 = dim M_g - 1 (Theorems 3.6, 3.9)
3. The edge bound |E| ≤ 3g - 3 ensures stratum dimension ≥ 0 (Theorem 3.11)

These correspond to the fan structure of M_g^{trop}:
- The smooth graph → the open cone (interior of M_g^{trop})
- One-edge graphs → codimension-1 faces (boundary divisors)
- Maximal edge graphs → vertices of the dual complex

### 4.2 Boundary Stratification

The boundary of M̄_g admits a stratification indexed by stable graphs:

  ∂M̄_g = ⋃_{Γ stable, |E(Γ)| ≥ 1} D_Γ

where D_Γ is a locally closed stratum of codimension |E(Γ)|. The boundary divisors (codimension-1 strata) are indexed by one-edge stable graphs, of which there are exactly ⌊g/2⌋ + 1 (Theorem 3.10).

### 4.3 The Tropicalization Map

The tropicalization map trop: M̄_g → M_g^{trop} sends each stable curve C to the tropical curve obtained by:
1. Taking the dual graph Γ_C
2. Assigning edge lengths from the deformation parameters at nodes

This map is compatible with the stratification: the preimage of a cone σ_Γ is the stratum D_Γ.

## 5. Connections to Existing Work

This formalization extends the tropical semiring results in the project catalog:
- `tropical_and_bound` (OracleApplicationsFrontier.lean): Our edge bound is the moduli-theoretic analog
- `tropical_and_distributes` (TropicalNNFrontier.lean): Distributivity in the tropical semiring underlies the piecewise-linear structure of tropical curves
- `tropical_BSD_abelian_variety` (TropicalBSDAbelianVariety.lean): The abelian variety perspective connects to the Torelli map from M_g to the moduli of abelian varieties

## 6. Algorithms

### 6.1 Stable Graph Enumeration

To enumerate all stable graphs of genus g with k edges:
1. Enumerate all multigraphs on at most 2g - 2 vertices with k edges
2. Assign genus labels g(v) ≥ 0 with Σg(v) = g - k + |V| - 1
3. Check stability: 2g(v) - 2 + val(v) > 0 for all v

### 6.2 Tropical Moduli Dimension

Given a stable graph Γ:
- Compute stratum dimension as 3 · totalGenus(Γ) - 3 - |E|
- This equals the number of moduli parameters for the corresponding tropical curve

## 7. Future Work

1. **Higher genus**: Extend to marked curves M_{g,n} with n marked points
2. **Tropical Torelli**: Formalize the tropical Torelli map and its relationship to the classical Torelli theorem
3. **Intersection theory**: Formalize Psi-classes and their tropical counterparts
4. **Berkovich spaces**: Connect tropical curves to Berkovich analytifications

## References

[ACP15] D. Abramovich, L. Caporaso, S. Payne. The tropicalization of the moduli space of curves. *Ann. Sci. Éc. Norm. Supér.* 48 (2015), 765-809.

[DM69] P. Deligne, D. Mumford. The irreducibility of the space of curves of given genus. *Publ. Math. IHÉS* 36 (1969), 75-109.

[GM07] A. Gathmann, H. Markwig. Kontsevich's formula and the WDVV equations in tropical geometry. *Adv. Math.* 217 (2008), 537-560.

[Mik06] G. Mikhalkin. Tropical geometry and its applications. *Proceedings ICM 2006*, Vol. II, 827-852.

[Chan12] M. Chan. Combinatorics of the tropical Torelli map. *Algebra Number Theory* 6 (2012), 1133-1169.
