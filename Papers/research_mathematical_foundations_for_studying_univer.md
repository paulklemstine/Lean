# Tropical Renormalization Flows: Depth Spectra, Universality Classes, and the Merging Principle

## Abstract

We develop a mathematical framework for studying universality in discrete dynamical systems through the lens of tropical (max-plus) geometry. We introduce **tropical depth flows** — iterated maps on finite sets equipped with a real-valued depth function that is non-increasing under iteration — and establish three main results: (1) under strict contraction, every orbit stabilizes within at most |α| steps, with an explicit pigeonhole-based bound; (2) the **Merging Principle**, showing that coarse-graining morphisms between flows can only merge universality classes, never split them; and (3) the tropical max-plus averaging step is non-expansive in the sup norm, providing stability guarantees for concrete tropical dynamics. We show that coarse-graining maps compose functorially, establishing a well-defined category of tropical depth flows. All results are formalized and machine-verified. We state a falsifiable conjecture on the logarithmic growth of universality class counts.

**Keywords**: tropical geometry, renormalization group, universality classes, discrete dynamical systems, max-plus algebra, coarse-graining, formal verification

---

## 1. Introduction

The renormalization group (RG) is one of the most powerful organizing principles in theoretical physics, explaining why systems with vastly different microscopic details can exhibit identical macroscopic behavior. Originally developed in the context of quantum field theory and statistical mechanics [Wilson & Kogut 1974], the RG has found applications across physics, from condensed matter to cosmology.

The mathematical essence of renormalization is a **flow**: an iterated transformation that coarsens a system by integrating out short-distance (high-energy) degrees of freedom. Under this flow, systems converge to **fixed points**, and systems that converge to the same fixed point are said to belong to the same **universality class**.

In this paper, we develop a rigorous combinatorial and tropical-geometric framework for studying such flows on finite discrete systems. Our framework captures the essential features of renormalization — depth-graded convergence, universality class structure, and the monotonicity of coarse-graining — while remaining amenable to formal verification and computational enumeration.

### 1.1 Contributions

1. **Definition of Tropical Depth Flows** (§2): We introduce a structure combining a self-map on a finite type with a non-increasing real-valued depth function, capturing the essential monotonicity of renormalization.

2. **Strict Contraction Bound** (§3): We prove that under strict contraction (depth strictly decreases at every non-fixed point), every orbit reaches a fixed point within at most |α| steps. The proof uses a pigeonhole argument on the distinct depth values along an orbit.

3. **The Merging Principle** (§4): We prove that surjective morphisms between tropical depth flows (coarse-graining maps) can only merge asymptotic congruence classes, never split them. This is the discrete analogue of Kadanoff's block-spin universality preservation.

4. **Categorical Structure** (§5): We show that coarse-graining maps compose, establishing a category of tropical depth flows. The Merging Principle is functorial.

5. **Tropical Non-expansion** (§6): We prove that the max-plus averaging step on weighted graphs is non-expansive in the sup norm, providing a concrete instance of the abstract framework.

6. **Logarithmic Class Conjecture** (§7): We state a falsifiable conjecture that the number of universality classes in a strictly contracting flow is at most logarithmic in the system size.

---

## 2. Tropical Depth Flows

### 2.1 Definition

**Definition 2.1** (Tropical Depth Flow). A *tropical depth flow* on a finite type α consists of:
- A self-map `step : α → α`
- A depth function `depth : α → ℝ`
satisfying:
- (Non-negativity) `∀ x, 0 ≤ depth x`
- (Monotonicity) `∀ x, depth (step x) ≤ depth x`

The iterate `F^n(x)` is defined recursively: `F^0(x) = x`, `F^{n+1}(x) = step(F^n(x))`.

### 2.2 Fixed Points and Asymptotic Congruence

**Definition 2.2**. An element x is a *fixed point* if `step(x) = x`.

**Definition 2.3**. Two elements x, y are *asymptotically congruent* (written `x ~_F y`) if there exists N such that `F^n(x) = F^n(y)` for all n ≥ N.

**Theorem 2.4**. Asymptotic congruence is an equivalence relation.

*Proof sketch*. Reflexivity is immediate (N = 0). Symmetry follows from the symmetry of equality. Transitivity uses N = max(N₁, N₂) where N₁, N₂ are the respective convergence witnesses. □

**Definition 2.5**. The *universality class* of x is the equivalence class `[x] = {y ∈ α : x ~_F y}`.

### 2.3 Depth Monotonicity

**Theorem 2.6** (Orbit Depth Monotonicity). For all x ∈ α and m ≤ n:
```
depth(F^n(x)) ≤ depth(F^m(x)) ≤ depth(x)
```

*Proof sketch*. The first inequality follows by induction on n - m using the monotonicity axiom. The second is the special case m = 0. □

### 2.4 Strict Contraction

**Definition 2.7**. A tropical depth flow is *strictly contracting* if `depth(step(x)) < depth(x)` for every non-fixed point x.

---

## 3. The Strict Contraction Bound

**Theorem 3.1** (Contraction Bound). If F is strictly contracting, then for every x ∈ α, there exists N ≤ |α| such that F^N(x) is a fixed point.

*Proof*. Suppose for contradiction that F^i(x) is not a fixed point for any i ≤ |α|. Then by strict contraction:

```
depth(x) > depth(F(x)) > depth(F²(x)) > ... > depth(F^|α|(x))
```

This gives |α| + 1 distinct real values, all of the form depth(F^i(x)). But F^0(x), F^1(x), ..., F^|α|(x) are |α| + 1 elements of α, which has only |α| elements. By the pigeonhole principle, some F^i(x) = F^j(x) with i < j. But then depth(F^i(x)) = depth(F^j(x)), contradicting the strict decrease. □

**Corollary 3.2** (Orbit Stabilization). Under strict contraction, every orbit eventually stabilizes: there exists N such that F^n(x) = F^N(x) for all n ≥ N.

*Proof*. Let N be given by Theorem 3.1, so F^N(x) is a fixed point. Then F^{N+1}(x) = step(F^N(x)) = F^N(x), and by induction, F^n(x) = F^N(x) for all n ≥ N. □

**Corollary 3.3** (Fixed Point Convergence). Under strict contraction, every element x has a unique fixed point y in its universality class, and F^n(x) → y.

---

## 4. The Merging Principle

### 4.1 Coarse-Graining Maps

**Definition 4.1** (Coarse-Graining). A *coarse-graining* from a tropical depth flow (α, F) to (β, G) is a surjective map φ : α → β such that:
- (Equivariance) `φ(step_F(x)) = step_G(φ(x))` for all x
- (Depth Reduction) `depth_G(φ(x)) ≤ depth_F(x)` for all x

### 4.2 The Merging Principle

**Lemma 4.2** (Iterate Commutation). For any coarse-graining φ and all n:
```
G^n(φ(x)) = φ(F^n(x))
```

*Proof*. Induction on n, using equivariance at each step. □

**Theorem 4.3** (Merging Principle). If x ~_F y, then φ(x) ~_G φ(y).

*Proof*. Let N be such that F^n(x) = F^n(y) for all n ≥ N. Then for n ≥ N:
```
G^n(φ(x)) = φ(F^n(x)) = φ(F^n(y)) = G^n(φ(y))
```
using Lemma 4.2 and the hypothesis. □

**Corollary 4.4** (Class Count Monotonicity). The number of universality classes in (β, G) is at most the number in (α, F).

*Proof*. Each universality class in α maps into a single universality class in β (by Theorem 4.3), and φ is surjective, so every class in β is hit. But multiple α-classes may map to the same β-class. □

---

## 5. Categorical Structure

### 5.1 Composition of Coarse-Grainings

**Theorem 5.1** (Functoriality). If φ : F → G and ψ : G → H are coarse-grainings, then ψ ∘ φ : F → H is a coarse-graining.

*Proof*. Surjectivity: composition of surjections is surjective. Equivariance: (ψ ∘ φ)(step_F(x)) = ψ(φ(step_F(x))) = ψ(step_G(φ(x))) = step_H(ψ(φ(x))). Depth: depth_H(ψ(φ(x))) ≤ depth_G(φ(x)) ≤ depth_F(x). □

**Corollary 5.2**. The Merging Principle composes: if φ and ψ are coarse-grainings and x ~_F y, then (ψ ∘ φ)(x) ~_H (ψ ∘ φ)(y).

### 5.2 The Category TDF

We define the category **TDF** (Tropical Depth Flows) as follows:
- **Objects**: Tropical depth flows (α, step, depth) on finite types
- **Morphisms**: Coarse-graining maps
- **Composition**: Standard function composition (Theorem 5.1)
- **Identity**: The identity map on each flow

The universality class partition defines a functor from **TDF** to the category of finite sets with surjective maps, sending each flow to its set of universality classes.

---

## 6. Tropical Non-Expansion

### 6.1 The Max-Plus Averaging Step

For a weighted directed graph with adjacency matrix W ∈ ℝ^{n×n}, define the tropical step:

```
(Tv)_i = (v_i + max_j(v_j + W_{ij})) / 2
```

This averages each node's value with the best value it can "see" through its connections.

### 6.2 Non-Expansion Theorem

**Theorem 6.1** (Tropical Non-Expansion). For all v, w : ℝ^n and all i:
```
|(Tv)_i - (Tw)_i| ≤ max_j |v_j - w_j|
```

*Proof*. We bound:
```
|(Tv)_i - (Tw)_i| = |(v_i - w_i + (max_j(v_j + W_{ij}) - max_j(w_j + W_{ij})))| / 2
```

The key inequality is:
```
|max_j(v_j + W_{ij}) - max_j(w_j + W_{ij})| ≤ max_j |v_j - w_j|
```

This follows because for any j₀ achieving the max of (v_j + W_{ij}):
```
v_{j₀} + W_{ij₀} ≤ w_{j₀} + W_{ij₀} + |v_{j₀} - w_{j₀}| ≤ max_j(w_j + W_{ij}) + max_j |v_j - w_j|
```

Combined with |v_i - w_i| ≤ max_j |v_j - w_j|, we get:
```
|(Tv)_i - (Tw)_i| ≤ (max_j |v_j - w_j| + max_j |v_j - w_j|) / 2 = max_j |v_j - w_j|  □
```

---

## 7. The Logarithmic Class Conjecture

**Conjecture 7.1** (Logarithmic Universality Class Bound). For any strictly contracting depth-monotone function step : Fin(n) → Fin(n) with integer depth values in {0, ..., n-1}, the number of universality classes is at most ⌊log₂(n)⌋ + 2.

### 7.1 Motivation

Under strict contraction with integer depths bounded by n, the orbit tree (the forest of orbits converging to fixed points) has depth at most n. The conjecture asserts that the number of roots (fixed points) — which equals the number of universality classes — is bounded logarithmically.

### 7.2 Testable Prediction

**Test**: Enumerate all strictly contracting maps on Fin(n) for n = 2, 3, ..., 10 (with depth functions satisfying the constraints) and compute the maximum number of universality classes. The conjecture predicts:

| n | max classes (conjectured) |
|---|--------------------------|
| 2 | 3 |
| 3 | 3 |
| 4 | 4 |
| 8 | 5 |
| 16 | 6 |
| 32 | 7 |

### 7.3 Potential Counterexample Strategy

A counterexample would require constructing a map with many fixed points while maintaining strict contraction. The constraint is that every non-fixed point must have strictly lower depth after one step. If we assign depth 0 to all fixed points, every other element must flow to a lower depth, which is impossible — so fixed points must be the depth-0 elements. The maximum number of depth-0 elements is bounded by the number of elements that can have depth 0, which in turn is constrained by the injectivity implicit in strict contraction.

---

## 8. Algorithms

### 8.1 Computing Universality Classes

Given a tropical depth flow on n elements:

```
function ComputeClasses(step, n):
    // Phase 1: Iterate to fixed points
    for each x in {0, ..., n-1}:
        fixed[x] = step^n(x)    // guaranteed to be a fixed point under strict contraction
    
    // Phase 2: Group by fixed point
    classes = {}
    for each x:
        classes[fixed[x]].add(x)
    
    return classes
```

Time complexity: O(n²) in the worst case (n elements, each iterated at most n times).

### 8.2 Tropical Step Computation

```
function TropicalStep(W, v, n):
    result = new array[n]
    for i in 0..n-1:
        max_val = -infinity
        for j in 0..n-1:
            max_val = max(max_val, v[j] + W[i][j])
        result[i] = (v[i] + max_val) / 2
    return result
```

Time complexity: O(n²) per step.

---

## 9. Discussion

### 9.1 Connections to Physics

The tropical depth flow framework formalizes key features of the physical renormalization group:

- **Depth ↔ Energy scale**: The depth function plays the role of the energy scale in quantum field theory. Higher depth = higher energy = more microscopic detail.
- **Step ↔ RG transformation**: The flow step integrates out the highest-energy degrees of freedom, reducing the effective energy scale.
- **Fixed points ↔ Scale-invariant theories**: Fixed points of the flow correspond to conformal field theories in physics — theories that look the same at every scale.
- **Universality classes ↔ Phases of matter**: Asymptotic congruence classes correspond to phases: systems in the same phase flow to the same fixed point.
- **Merging Principle ↔ Coarse-graining irreversibility**: The RG flow is irreversible in the sense that information about microscopic details is lost. The Merging Principle formalizes this precisely.

### 9.2 Connections to Tropical Geometry

The max-plus averaging step (§6) operates in the tropical semiring (ℝ ∪ {-∞}, max, +). This connects our framework to:

- **Tropical eigenvalues**: The maximum cycle mean of a weighted graph (the tropical Perron–Frobenius eigenvalue) governs the asymptotic growth rate of walk weights. Our non-expansion result complements the spectral theory developed for tropical matrices.
- **Tropical convexity**: The non-expansion theorem implies that the tropical step preserves tropical convex sets, connecting to the geometry of tropical polytopes.

### 9.3 Limitations

Our framework currently applies to **finite** systems. Extending to infinite types (e.g., function spaces, measures on Polish spaces) would require topological depth functions and continuity assumptions on the flow. The strict contraction condition is also strong; weaker conditions (e.g., eventual contraction) would apply to a broader class of systems.

---

## 10. Future Work

1. **Spectral characterization**: Relate the depth spectrum to the eigenvalues of the tropical adjacency matrix, establishing a spectral theory for tropical depth flows.

2. **Infinite extensions**: Develop the framework for Polish spaces with continuous depth functions, connecting to measure-theoretic renormalization.

3. **Categorical universality**: Establish adjunctions between the category TDF and categories of lattices, proving that universality class formation is a left adjoint to a forgetful functor.

4. **Computational complexity**: Determine the complexity of deciding whether two elements are asymptotically congruent, and of computing the number of universality classes.

---

## References

1. Wilson, K.G. and Kogut, J. (1974). The renormalization group and the ε expansion. *Physics Reports*, 12(2), 75-199.

2. Cuninghame-Green, R.A. (1979). *Minimax Algebra*. Lecture Notes in Economics and Mathematical Systems, Vol. 166. Springer.

3. Karp, R.M. (1978). A characterization of the minimum cycle mean in a digraph. *Discrete Mathematics*, 23(3), 309-311.

4. Kadanoff, L.P. (1966). Scaling laws for Ising models near T_c. *Physics Physique Fizika*, 2(6), 263.

5. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, Vol. 161. AMS.

6. Gaubert, S. and Gunawardena, J. (2004). The Perron-Frobenius theorem for homogeneous, monotone functions. *Transactions of the AMS*, 356(12), 4931-4950.
