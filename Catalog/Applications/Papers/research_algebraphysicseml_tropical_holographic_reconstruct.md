# Tropical Holographic Reconstruction: Boundary Rigidity and Bulk Recovery for Weighted Closure Systems

## Abstract

We develop a formal theory of **boundary-to-bulk reconstruction** for weighted closure systems over finite types, working in the min-plus (tropical) semiring. Given a finite state space partitioned into boundary and interior, we associate to each weighted closure system a *boundary data set* encoding the observable tropical response at the boundary. Our main results are:

1. **Boundary Rigidity Theorem**: Two weighted closure systems in normal form (injective boundary signature–weight map) with identical boundary data sets are gauge-equivalent — there exists a bijection of generators preserving boundary signatures and weights.

2. **Reconstruction Theorem**: Every admissible boundary data set admits a canonical bulk realization, and this realization is unique up to gauge equivalence.

3. **Gauge Invariance**: Gauge-equivalent systems have identical boundary kernels and entropy profiles, confirming that boundary observables are gauge-invariant.

All results are formalized and machine-verified in Lean 4 with the Mathlib library, with no unproven assumptions (`sorry`-free).

## 1. Introduction

### 1.1 Motivation

Inverse problems — recovering hidden structure from external observations — appear throughout mathematics, physics, and computer science. Classical examples include:

- **Calderón's inverse conductivity problem**: recovering internal conductivity from boundary voltage-current measurements.
- **Boundary rigidity in Riemannian geometry**: determining a metric from boundary distance data.
- **Dirichlet-to-Neumann reconstruction**: recovering a differential operator from its boundary response.

These problems share a common structure: a "bulk" system with hidden internal parameters produces observable "boundary" data, and the question is whether (and how) the boundary data determines the bulk.

We introduce a discrete, algebraic analogue of this framework using **weighted closure systems** — finite rule-based systems where generators add elements to sets at specified tropical costs. The boundary response of such a system records which observable (boundary) elements each generator produces and at what cost. Our central question is:

> *Does the boundary response of a weighted closure system determine its internal generator structure?*

We answer affirmatively under natural regularity conditions (normal form), establishing a discrete tropical analogue of holographic reconstruction.

### 1.2 Related Work

**Tropical algebra and min-plus systems.** The min-plus semiring (ℝ ∪ {∞}, min, +) is fundamental in optimization, scheduling, and discrete event systems. Tropical linear algebra studies matrices and linear maps over this semiring. Our propagation cost function is a tropical analogue of matrix-vector multiplication.

**Closure systems and lattice theory.** Closure operators on finite sets are well-studied in lattice theory and formal concept analysis. Our weighted closure systems add a tropical cost dimension to classical closure dynamics.

**Boundary rigidity.** In Riemannian geometry, boundary rigidity asks whether a compact manifold with boundary is determined (up to isometry) by the distances between boundary points. Pestov and Uhlmann (2005) proved boundary rigidity for simple surfaces. Our result is a discrete tropical analogue.

**Holographic duality.** The AdS/CFT correspondence in theoretical physics asserts that a gravitational theory in the "bulk" of anti-de Sitter space is equivalent to a conformal field theory on its boundary. While our setting is far simpler, the structural parallel is precise: bulk weighted closure dynamics ↔ bulk geometry, boundary data ↔ boundary correlators, gauge equivalence ↔ bulk diffeomorphisms.

### 1.3 Contributions

1. A clean formalization of weighted closure systems, boundary signatures, propagation costs, boundary kernels, and entropy profiles.
2. A boundary rigidity theorem for normal-form systems.
3. A constructive reconstruction algorithm with uniqueness guarantees.
4. Complete machine verification of all results in Lean 4.

## 2. Definitions and Setup

### 2.1 Weighted Closure Systems

**Definition 2.1** (Weighted Closure System). Let X be a finite type with decidable equality. A *weighted closure system* over X with generators G consists of:
- `out : G → Finset X` — the output function, assigning to each generator a finite set of produced states.
- `weight : G → ℝ≥0∞` — the weight function, assigning a non-negative extended real cost to each generator.

A generator g acts on a set s by mapping it to s ∪ out(g), at tropical cost weight(g).

### 2.2 Boundary Signature

**Definition 2.2** (Boundary Signature). Given a boundary B ⊆ X (as a Finset), the *boundary signature* of generator g is:

```
boundarySig(B, S, g) = (S.out g).filter (· ∈ B)
```

This is the restriction of g's output to the observable boundary.

**Lemma 2.3.** `boundarySig(B, S, g) ⊆ B` for all g.

### 2.3 Structural Predicates

**Definition 2.4** (Reduced). A system S is *reduced* w.r.t. B if every generator has nonempty boundary signature: ∀ g, boundarySig(B, S, g) ≠ ∅.

**Definition 2.5** (Separating). A system is *separating* w.r.t. B if the boundary signature map is injective: g₁ ≠ g₂ → boundarySig(B, S, g₁) ≠ boundarySig(B, S, g₂).

**Definition 2.6** (Normal Form). A system is in *normal form* w.r.t. B if the combined map g ↦ (boundarySig(B, S, g), S.weight(g)) is injective.

**Lemma 2.7.** Separating implies normal form.

*Proof.* If the signature map alone is injective, then the pair (signature, weight) is also injective. □

### 2.4 Propagation Cost

**Definition 2.8** (Propagation Cost). The propagation cost from seed s to target t is:

```
propagationCost(S, s, t) = ⨅ {gs : Finset G | t ⊆ s ∪ gs.biUnion S.out} gs.sum S.weight
```

This is the minimum total generator weight needed to cover t starting from s.

**Theorem 2.9** (Propagation Cost Properties).
1. *Self-coverage*: If t ⊆ s, then propagationCost(S, s, t) = 0.
2. *Seed monotonicity*: If s₁ ⊆ s₂, then propagationCost(S, s₂, t) ≤ propagationCost(S, s₁, t).
3. *Target monotonicity*: If t₁ ⊆ t₂, then propagationCost(S, s, t₁) ≤ propagationCost(S, s, t₂).

*Proof sketch.*
1. Take gs = ∅; then s ∪ ∅.biUnion = s ⊇ t, and ∅.sum = 0.
2. Any gs covering t from s₁ also covers t from s₂ ⊇ s₁.
3. Any gs covering t₂ also covers t₁ ⊆ t₂. □

### 2.5 Boundary Kernel

**Definition 2.10** (Boundary Kernel). The boundary kernel at element b is:

```
boundaryKernel(B, S, b) = ⨅ {g : G | b ∈ boundarySig(B, S, g)} S.weight(g)
```

**Theorem 2.11.** boundaryKernel(B, S, b) ≤ S.weight(g) for any g with b ∈ boundarySig(B, S, g).

### 2.6 Boundary Entropy Profile

**Definition 2.12** (Entropy Profile). The entropy profile at k is:

```
boundaryEntropyProfile(B, S, k) = ⨅ {g : G | k ≤ |boundarySig(B, S, g)|} S.weight(g)
```

**Theorem 2.13** (Entropy Profile Properties).
1. *Monotonicity*: k₁ ≤ k₂ → h(k₁) ≤ h(k₂).
2. *Zero level*: h(0) = ⨅_g weight(g).
3. *Upper bound*: If k ≤ |boundarySig(B, S, g)|, then h(k) ≤ weight(g).

### 2.7 Boundary Data

**Definition 2.14** (Boundary Data Set). The boundary data set is:

```
boundaryDataSet(B, S) = Finset.univ.image (fun g => (boundarySig(B, S, g), S.weight(g)))
```

**Theorem 2.15.** In normal form, |boundaryDataSet(B, S)| = |G|.

*Proof.* The image of an injective function on Finset.univ has cardinality equal to Fintype.card G. □

## 3. Main Results

### 3.1 Gauge Equivalence

**Definition 3.1** (Gauge Equivalence). A *gauge equivalence* between systems S₁ (with generators G₁) and S₂ (with generators G₂) w.r.t. boundary B consists of:
- A bijection e : G₁ ≃ G₂
- Signature preservation: ∀ g, boundarySig(B, S₁, g) = boundarySig(B, S₂, e(g))
- Weight preservation: ∀ g, S₁.weight(g) = S₂.weight(e(g))

### 3.2 Boundary Rigidity Theorem

**Theorem 3.2** (Boundary Rigidity). Let S₁, S₂ be weighted closure systems in normal form w.r.t. B. If boundaryDataSet(B, S₁) = boundaryDataSet(B, S₂), then S₁ and S₂ are gauge-equivalent.

*Proof.* The proof proceeds in three steps:

**Step 1: Establishing a domain correspondence.** Define f₁ : G₁ → Finset X × ℝ≥0∞ by f₁(g) = (boundarySig(B, S₁, g), S₁.weight(g)), and similarly f₂ for S₂. By normal form, both f₁ and f₂ are injective. By hypothesis, image(f₁) = image(f₂) as Finsets.

**Step 2: Constructing the bijection.** For each g₁ ∈ G₁, f₁(g₁) ∈ image(f₁) = image(f₂), so there exists g₂ ∈ G₂ with f₂(g₂) = f₁(g₁). By injectivity of f₂, this g₂ is unique. Define e(g₁) = g₂. This map is injective (since f₁ is injective and f₂(e(g₁)) = f₁(g₁)), and surjective by a cardinality argument (|G₁| = |image(f₁)| = |image(f₂)| = |G₂|).

**Step 3: Verifying the equivalence conditions.** By construction, f₂(e(g)) = f₁(g), i.e., (boundarySig(B, S₂, e(g)), S₂.weight(e(g))) = (boundarySig(B, S₁, g), S₁.weight(g)). Extracting components gives the signature and weight preservation conditions. □

**Corollary 3.3.** Gauge-equivalent systems have equal boundary kernels and entropy profiles.

*Proof.* The boundary kernel at b is ⨅_{g : b ∈ bSig(g)} weight(g). Reindexing by the equivalence bijection and using the preservation conditions yields equality. Similarly for the entropy profile. □

### 3.3 Reconstruction

**Definition 3.4** (Reconstruction). Given admissible boundary data d (all signatures are subsets of B), the *canonical reconstruction* is:

```
reconstructBulk(d) : WeightedClosureSystem X {p // p ∈ d}
  out := fun ⟨p, _⟩ => p.1
  weight := fun ⟨p, _⟩ => p.2
```

**Theorem 3.5** (Reconstruction Properties).
1. *Normal form*: reconstructBulk(d) is in normal form w.r.t. B.
2. *Data realization*: boundaryDataSet(B, reconstructBulk(d)) = d.
3. *Uniqueness*: Any normal-form system S with boundaryDataSet(B, S) = d is gauge-equivalent to reconstructBulk(d).

*Proof.*
1. Under admissibility, boundarySig of ⟨(T, w), h⟩ equals T (since T ⊆ B). So the combined map sends ⟨p, h⟩ to p, which is injective on the subtype.
2. The image of the combined map over the subtype {p // p ∈ d} is exactly d.
3. Follows from boundary rigidity applied to S and reconstructBulk(d), using data realization. □

## 4. Computational Experiments

### 4.1 Example Systems

We implemented the theory in Python and tested it on concrete examples.

**System 1** has states {i₁, i₂, b₁, b₂, b₃} with boundary {b₁, b₂, b₃} and generators:
| Generator | Output | Weight |
|-----------|--------|--------|
| α | {b₁, b₂, i₁} | 2.0 |
| β | {b₂, b₃} | 3.0 |
| γ | {b₁, b₃, i₂} | 1.5 |

**System 2** is a relabeling of System 1 with different internal state names but identical boundary data.

**System 3** has different boundary data and is NOT gauge-equivalent to System 1.

### 4.2 Results

| Property | System 1 | System 2 | System 3 |
|----------|----------|----------|----------|
| Reduced | ✓ | ✓ | ✓ |
| Separating | ✓ | ✓ | ✓ |
| Normal form | ✓ | ✓ | ✓ |
| K(b₁) | 1.5 | 1.5 | 1.0 |
| K(b₂) | 2.0 | 2.0 | 1.0 |
| K(b₃) | 1.5 | 1.5 | 4.0 |
| Gauge-equiv to S1 | — | ✓ | ✗ |

The gauge equivalence between Systems 1 and 2 maps: α ↔ B, β ↔ C, γ ↔ A, confirming the rigidity theorem.

### 4.3 Entropy Profiles

The entropy profiles are:
- Systems 1 & 2: h(0) = 1.5, h(1) = 1.5, h(2) = 1.5, h(3) = ∞
- System 3: h(0) = 1.0, h(1) = 1.0, h(2) = 1.0, h(3) = 5.0

The profile correctly distinguishes the non-equivalent system and matches for gauge-equivalent systems.

### 4.4 Reconstruction

Starting from System 1's boundary data {({b₁,b₂}, 2.0), ({b₁,b₃}, 1.5), ({b₂,b₃}, 3.0)}, the canonical reconstruction produces a system with three generators matching the boundary data exactly. This reconstructed system is verified to be gauge-equivalent to the original.

## 5. Discussion

### 5.1 Strength and Limitations

The rigidity theorem is sharp in the following sense: removing the normal-form hypothesis allows systems with redundant generators (multiple generators with identical boundary effects) that are genuinely non-isomorphic but boundary-indistinguishable. Normal form is the minimal condition ensuring the boundary data is a complete invariant.

The current framework uses single-step generators without antecedent conditions. Extending to multi-step propagation (where the order and preconditions of generators matter) would yield a richer theory with applications to sequential decision processes and dynamic programming.

### 5.2 Connections to Other Fields

**Tropical linear algebra**: The boundary kernel is a tropical analogue of a matrix, and reconstruction is a tropical matrix factorization problem. The extremal signatures in normal form correspond to the "tropical rank" of the kernel.

**Formal concept analysis**: Closure systems are the semantic engine of formal concept analysis. Our weighted extension adds a tropical cost dimension, and the rigidity theorem says that the observable tropical response determines the concept lattice generator.

**Information theory**: The entropy profile h(k) behaves like a rate-distortion function in information theory — the minimum cost to achieve a certain level of boundary coverage. Its monotonicity is a discrete analogue of the convexity of rate-distortion curves.

## 6. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions. Key priorities include:

1. Multi-step propagation rigidity using iterated closure costs.
2. Categorical equivalence between reduced systems and admissible kernels.
3. Finite-temperature deformation connecting to statistical physics.
4. Extension to weighted hypergraph rewriting systems.
5. Tropical sheafification of boundary observables.

## 7. References

1. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.P. *Synchronization and Linearity: An Algebra for Discrete Event Systems*. Wiley, 1992.
2. Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry*. AMS, 2015.
3. Pestov, L., Uhlmann, G. "Two-dimensional compact simple Riemannian manifolds are boundary distance rigid." *Annals of Mathematics*, 161(2):1093-1110, 2005.
4. Davey, B.A., Priestley, H.A. *Introduction to Lattices and Order*. Cambridge University Press, 2002.
5. Maldacena, J. "The Large N Limit of Superconformal Field Theories and Supergravity." *Advances in Theoretical and Mathematical Physics*, 2:231-252, 1998.
6. Litvinov, G.L. "Maslov dequantization, idempotent and tropical mathematics." *Journal of Mathematical Sciences*, 140(3):209-325, 2007.
