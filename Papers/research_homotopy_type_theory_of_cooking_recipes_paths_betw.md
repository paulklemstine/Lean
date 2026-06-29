# The Algebraic Structure of Recipe Substitution Spaces: Hamming Graphs, Flavor Independence, and Culinary Homotopy

## Abstract

We develop a mathematical framework for the space of recipes as a Hamming graph H(n,m), where n ingredient slots each admit m possible choices. We prove ten structural theorems about this space: the triangle inequality for Hamming distance, commutativity of disjoint substitutions, translation invariance (vertex transitivity), triangle-freeness for binary choices (m=2), triangle existence for m≥3, a slot independence theorem for additive flavor maps, the Vandermonde-culinary spectrum identity, four-cycle existence, and recipe space cardinality. These results connect culinary science to coding theory, combinatorics, and metric geometry, providing a rigorous foundation for understanding ingredient substitution.

## 1. Introduction

The problem of ingredient substitution is central to culinary science, dietary adaptation, and computational recipe generation. When a recipe calls for an ingredient that is unavailable, the cook faces a fundamental question: which substitutions preserve the essential character of the dish?

We formalize this problem by modeling the space of recipes as a graph where vertices are recipes and edges connect recipes that differ by exactly one ingredient. This construction is precisely the Hamming graph H(n,m), a well-studied object in coding theory [1], algebraic combinatorics [2], and association scheme theory [3].

Our contribution is threefold:
1. We establish the formal connection between recipe substitution and the Hamming graph
2. We prove structural theorems about recipe space with complete machine-verified proofs
3. We develop the theory of additive flavor maps and prove a slot independence theorem

### 1.1 Related Work

The Hamming graph H(n,m) has been extensively studied in coding theory, where it provides the ambient space for error-correcting codes [1]. Its automorphism group Sm ≀ Sn (the wreath product of symmetric groups) was determined by [4]. The spectrum of the Hamming graph is well-known from association scheme theory [3]. Our work applies this classical structure in a novel culinary context, adding the dimension of flavor maps and proving independence results.

## 2. Definitions

### 2.1 Recipe Space

**Definition 2.1** (Recipe). A *recipe* with n ingredient slots and m choices per slot is a function r : Fin n → Fin m. The set of all such recipes is denoted Recipe(n,m).

**Definition 2.2** (Differing Set). For recipes r₁, r₂ : Recipe(n,m), the *differing set* is
diffSet(r₁, r₂) = {i ∈ Fin n | r₁(i) ≠ r₂(i)}.

**Definition 2.3** (Hamming Distance). The *Hamming distance* between r₁ and r₂ is
hdist(r₁, r₂) = |diffSet(r₁, r₂)|.

**Definition 2.4** (Substitution Graph). The *substitution graph* SubstGraph(n,m) is the simple graph on Recipe(n,m) with adjacency relation
r₁ ~ r₂ ⟺ hdist(r₁, r₂) = 1.

### 2.2 Flavor Maps

**Definition 2.5** (Additive Flavor Map). An *additive flavor map* A : AdditiveFlavorMap(n,m,d) consists of per-slot contribution functions contrib : Fin n → Fin m → Fin d → ℝ. The evaluation on a recipe r is
A.eval(r, k) = Σᵢ A.contrib(i, r(i), k).

**Definition 2.6** (Translation). For an offset o : Fin n → Fin m, the *translation* map is
translate(o, r)(i) = r(i) + o(i) (mod m).

### 2.3 Substitution Spectrum

**Definition 2.7** (Spectrum Count). The number of recipes at Hamming distance exactly k is
spectrumCount(n, m, k) = C(n,k) · (m-1)^k.

## 3. Main Results

### 3.1 Metric Properties

**Theorem 3.1** (Triangle Inequality). For all recipes r₁, r₂, r₃ : Recipe(n,m),
hdist(r₁, r₃) ≤ hdist(r₁, r₂) + hdist(r₂, r₃).

*Proof sketch.* The differing set satisfies diffSet(r₁, r₃) ⊆ diffSet(r₁, r₂) ∪ diffSet(r₂, r₃), since if r₁(i) ≠ r₃(i) then either r₁(i) ≠ r₂(i) or r₂(i) ≠ r₃(i). The result follows from |A| ≤ |A ∪ B| ≤ |A| + |B|. □

Combined with hdist(r, r) = 0, hdist(r₁, r₂) = hdist(r₂, r₁), and hdist(r₁, r₂) = 0 ⟺ r₁ = r₂, this establishes that hdist is a metric on Recipe(n,m).

### 3.2 Commutativity of Disjoint Substitutions

**Theorem 3.2** (Disjoint Update Commutativity). For distinct slots i ≠ j and any values vᵢ, vⱼ,
update(update(r, i, vᵢ), j, vⱼ) = update(update(r, j, vⱼ), i, vᵢ).

*Proof sketch.* By function extensionality, both sides agree at every index k:
- k = i: both sides evaluate to vᵢ (since i ≠ j)
- k = j: both sides evaluate to vⱼ (since j ≠ i)
- k ≠ i, k ≠ j: both sides evaluate to r(k). □

This theorem is fundamental for geodesic factorization: any shortest path between two recipes can be decomposed into independent per-slot substitutions, and these commute when they act on different slots. The k! shortest paths between recipes at distance k correspond to the k! orderings of k commuting substitutions.

### 3.3 Vertex Transitivity

**Theorem 3.3** (Translation Invariance). For any offset o : Fin n → Fin m,
hdist(translate(o, r₁), translate(o, r₂)) = hdist(r₁, r₂).

*Proof.* The key observation is that r₁(i) + o(i) ≠ r₂(i) + o(i) iff r₁(i) ≠ r₂(i), by the cancellation law in Fin m. Therefore the differing sets are identical. □

**Theorem 3.4** (Vertex Transitivity). For any r₁, r₂ : Recipe(n,m), there exists a graph isomorphism f : Recipe(n,m) ≃ Recipe(n,m) with f(r₁) = r₂ that preserves adjacency.

*Proof.* Take f = translate(r₂ - r₁). This is a bijection (with inverse translate(r₁ - r₂)) that preserves adjacency by Theorem 3.3. □

### 3.4 Triangle Structure

**Theorem 3.5** (Triangle-Free Hypercube). For m = 2, SubstGraph(n, 2) contains no triangles.

*Proof.* Suppose a, b, c are pairwise adjacent. Let i be the unique slot where a and b differ, and j the unique slot where a and c differ. If i ≠ j: b and c differ at both i and j, giving hdist(b,c) ≥ 2, contradiction. If i = j: since Fin 2 has only two elements, a(i) ≠ b(i) and a(i) ≠ c(i) forces b(i) = c(i). Combined with agreement on all other slots, b = c, contradicting hdist(b,c) = 1. □

**Theorem 3.6** (Triangle Existence). For m ≥ 3 and n ≥ 1, SubstGraph(n,m) contains triangles.

*Proof.* Take a = constant 0, b = (1 at slot 0, else 0), c = (2 at slot 0, else 0). Each pair differs only at slot 0, so they are pairwise adjacent and pairwise distinct. □

**Corollary.** The clique number of SubstGraph(n,m) for m ≥ 3 is at least 3, while for m = 2 it is exactly 2. In fact, for general m, the clique number is m (a complete subgraph on m recipes that all agree except at one slot).

### 3.5 Slot Independence

**Theorem 3.7** (Slot Independence). For an additive flavor map A and any recipe r, slot i, value v, and flavor dimension k:
A.eval(update(r, i, v), k) - A.eval(r, k) = A.contrib(i, v, k) - A.contrib(i, r(i), k).

*Proof.* In the sum Σⱼ A.contrib(j, r'(j), k), where r' = update(r, i, v), the terms for j ≠ i are identical (since r'(j) = r(j)). Only the i-th term changes, giving the stated difference. □

This theorem formalizes the principle that in an additive flavor model, each ingredient contributes independently. The flavor change from any single substitution depends only on the old and new values at that slot, not on the rest of the recipe.

### 3.6 Spectrum Identity

**Theorem 3.8** (Spectrum Sum). For m ≥ 1,
Σ_{k=0}^{n} C(n,k) · (m-1)^k = m^n.

*Proof.* This is the binomial theorem with a = m-1, b = 1:
m^n = ((m-1) + 1)^n = Σ_{k=0}^{n} C(n,k) · (m-1)^k · 1^{n-k} = Σ_{k=0}^{n} C(n,k) · (m-1)^k. □

### 3.7 Cycle Structure

**Theorem 3.9** (Four-Cycle Existence). For n ≥ 2 and m ≥ 2, SubstGraph(n,m) contains non-degenerate 4-cycles.

*Proof.* The cycle (0,...,0) → (1,0,...) → (1,1,0,...) → (0,1,0,...) → (0,...,0) is a 4-cycle where opposite vertices are distinct. □

### 3.8 Cardinality

**Theorem 3.10** (Recipe Space Cardinality). |Recipe(n,m)| = m^n.

## 4. Algorithms

### 4.1 Nearest Recipe Search
Given a target flavor profile p and an additive flavor map A, find the recipe r minimizing ‖A.eval(r) - p‖. The additive structure allows this to be decomposed into n independent per-slot optimizations, reducing the search from m^n to n·m evaluations.

### 4.2 Substitution Path Planning
Given recipes r₁, r₂ with hdist(r₁, r₂) = k, enumerate all k! shortest substitution paths. Each path corresponds to a permutation of the k differing slots.

## 5. Discussion

### 5.1 Connections to Coding Theory
The recipe substitution graph is isomorphic to the Hamming graph H(n,m), the fundamental ambient graph for error-correcting codes. A "code" in this context would be a subset of recipes — a cookbook — optimized so that any two recipes are far apart in Hamming distance. This maximizes "distinguishability": no single ingredient error could transform one recipe into another.

### 5.2 Limitations of the Additive Model
Real flavor perception involves substantial nonlinearities: Maillard reactions couple sugars and amino acids, emulsification depends on the ratio of fat to water, and texture (which contributes to perceived flavor) depends on complex physical interactions. The additive flavor map captures only the linear contribution of each ingredient, serving as a first-order approximation.

### 5.3 Continuous Extensions
The discrete recipe model can be extended by replacing Fin m with [0,1] (continuous quantities), yielding the unit hypercube [0,1]^n as the recipe space. The Hamming distance is replaced by the L⁰ or L¹ metric, and the graph structure gives way to a continuous metric space. The additive flavor map becomes a linear map ℝ^n → ℝ^d, and the slot independence theorem becomes a statement about the kernel of this linear map.

## 6. Conjectures

**Conjecture 6.1** (Fiber Connectivity). For a "generic" additive flavor map A : AdditiveFlavorMap(n,m,d) with d < n, every flavor fiber is connected in SubstGraph(n,m). Here "generic" means the contribution vectors are in general position.

**Test**: For n = 5, m = 3, d = 2, randomly sample 1000 additive flavor maps and check connectivity of each fiber. If any fiber is disconnected, the conjecture is falsified.

## 7. Future Work

1. **Higher homotopy invariants**: Compute π₁ of the clique complex of SubstGraph(n,m) restricted to a flavor fiber
2. **Weighted substitution graphs**: Assign weights to edges based on flavor distance, connecting to shortest-path problems
3. **Interaction models**: Extend beyond additive flavor maps to include pairwise and higher-order ingredient interactions
4. **Computational recipe optimization**: Use the decomposition from Theorem 3.7 for efficient recipe search

## References

[1] R. W. Hamming, "Error detecting and error correcting codes," Bell System Technical Journal, vol. 29, no. 2, pp. 147–160, 1950.

[2] R. A. Bailey, "Association Schemes: Designed Experiments, Algebra and Combinatorics," Cambridge University Press, 2004.

[3] E. Bannai and T. Ito, "Algebraic Combinatorics I: Association Schemes," Benjamin/Cummings, 1984.

[4] P. Delsarte, "An algebraic approach to the association schemes of coding theory," Philips Research Reports Supplements, no. 10, 1973.
