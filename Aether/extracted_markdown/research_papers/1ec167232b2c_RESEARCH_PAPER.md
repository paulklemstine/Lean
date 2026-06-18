# Causal Structure of Conway's Game of Life: Speed of Light, Causal Diamonds, and Perturbation Theory

## Abstract

We present a comprehensive formal foundation for Conway's Game of Life on the infinite integer lattice ℤ × ℤ, establishing its causal structure as a partial order on discrete spacetime. Our main contributions are: (1) a formally verified **Speed of Light Theorem** proving that information propagates at most one cell per time step in the Chebyshev metric; (2) the introduction of the **GoL Spacetime Causal Order**, a novel partial order on ℤ × ℤ × ℕ that captures the light cone structure of cellular automaton dynamics; (3) a proof that **causal diamonds are finite**, the discrete analog of finite spacetime volume in Lorentzian geometry; (4) a **Causality Theorem** establishing that GoL dynamics respects the causal order; and (5) an **iterated perturbation spread bound** quantifying how configuration differences propagate. All results are machine-verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords:** Conway's Game of Life, cellular automata, causal structure, speed of light, formal verification, Chebyshev metric, perturbation theory

## 1. Introduction

Conway's Game of Life (GoL), introduced in 1970 [1], is a two-dimensional totalistic cellular automaton with the birth/survival rule B3/S23: a dead cell becomes alive with exactly 3 living neighbors, and a living cell survives with 2 or 3 living neighbors. Despite its simplicity, GoL is Turing-complete [2] and exhibits rich emergent behavior.

While the computational universality and pattern theory of GoL have been extensively studied, its **physical** structure — the causal constraints, propagation bounds, and geometric properties of its dynamics — has received less formal attention. In this work, we develop a rigorous mathematical framework for the "physics" of GoL, centered on the concept of **causal structure**.

Our key innovation is the **GoL Spacetime Causal Order**, a partial order on the discrete spacetime ℤ × ℤ × ℕ defined by:

**(x₁, y₁, t₁) ≤_c (x₂, y₂, t₂)** iff **t₁ ≤ t₂** and **max(|x₁ - x₂|, |y₁ - y₂|) ≤ t₂ - t₁**

This structure captures the fundamental constraint that information in GoL propagates at most one cell per time step in the Chebyshev (L∞) metric. We prove this is a partial order, that GoL dynamics respects it, and that causal diamonds (intersections of forward and backward light cones) are finite sets.

### 1.1 Contributions

1. **Core Definitions** (§2): GoL on ℤ × ℤ with Bool-valued configurations, Chebyshev distance, Moore neighborhood, step function.

2. **Locality Theorem** (§3): The step function at any cell depends only on cells within Chebyshev distance 1.

3. **Speed of Light Theorem** (§3): If support(c) ⊆ B_r(0), then support(step^t(c)) ⊆ B_{r+t}(0).

4. **Causal Partial Order** (§4): Causal precedence is reflexive, antisymmetric, and transitive on STPoint.

5. **Causal Diamond Finiteness** (§4): For any two spacetime points a, b, the diamond {c : a ≤_c c ≤_c b} is finite.

6. **Causality Theorem** (§5): If c₁ and c₂ agree on the backward light cone of (p, t), then step^t(c₁)(p) = step^t(c₂)(p).

7. **Perturbation Spread Bound** (§5): If c₁ and c₂ differ only within B_r(center), then step^t(c₁) and step^t(c₂) differ only within B_{r+t}(center).

8. **Oscillator Period Divisibility** (§6): If step^p(c) = c, then step^{kp}(c) = c.

## 2. Definitions

### 2.1 Configuration Space

A **configuration** is a function c : ℤ × ℤ → Bool. The **support** of c is {p ∈ ℤ × ℤ : c(p) = true}.

### 2.2 Chebyshev Distance

The **Chebyshev distance** (L∞ distance) on ℤ × ℤ is:

d_∞(p, q) = max(|p₁ - q₁|, |p₂ - q₂|)

We prove this satisfies:
- **Identity**: d_∞(p, p) = 0
- **Symmetry**: d_∞(p, q) = d_∞(q, p)
- **Triangle inequality**: d_∞(p, r) ≤ d_∞(p, q) + d_∞(q, r)
- **Separation**: d_∞(p, q) = 0 ⟺ p = q

### 2.3 Moore Neighborhood and Step Function

The **Moore neighborhood** of p consists of the 8 cells at Chebyshev distance exactly 1:

N(p) = {p + d : d ∈ {-1,0,1}² \ {(0,0)}}

The **alive count** a(c, p) = |{q ∈ N(p) : c(q) = true}| satisfies 0 ≤ a(c, p) ≤ 8.

The **step function** implements B3/S23:

step(c)(p) = (c(p) ∧ a(c,p) ∈ {2,3}) ∨ (¬c(p) ∧ a(c,p) = 3)

### 2.4 Spacetime Points

A **spacetime point** is a triple (x, y, t) ∈ ℤ × ℤ × ℕ, with spatial projection σ(x,y,t) = (x,y).

## 3. Locality and Speed of Light

### 3.1 Locality Theorem

**Theorem 3.1** (Locality). *If c₁(q) = c₂(q) for all q with d_∞(p, q) ≤ 1, then step(c₁)(p) = step(c₂)(p).*

*Proof.* The alive count depends only on c restricted to the Moore neighborhood of p. Since every Moore neighbor q satisfies d_∞(p, q) = 1 ≤ 1, and the cell p itself satisfies d_∞(p, p) = 0 ≤ 1, the hypothesis ensures aliveCount(c₁, p) = aliveCount(c₂, p) and c₁(p) = c₂(p). □

### 3.2 Dead Neighborhood Lemma

**Lemma 3.2**. *If c(q) = false for all q with d_∞(p, q) ≤ 1, then step(c)(p) = false.*

*Proof.* The hypothesis implies c(p) = false (taking q = p) and aliveCount(c, p) = 0. The B3/S23 rule with 0 neighbors and a dead cell yields false. □

### 3.3 Speed of Light Theorem

**Theorem 3.3** (Speed of Light). *If c(p) = false for all p with d_∞(0, p) > r, then step^t(c)(p) = false for all p with d_∞(0, p) > r + t.*

*Proof.* By induction on t.

**Base case** (t = 0): Immediate from the hypothesis.

**Inductive step**: Suppose the result holds for t. Let p satisfy d_∞(0, p) > r + t + 1. For any q with d_∞(p, q) ≤ 1, the triangle inequality gives:

d_∞(0, q) ≥ d_∞(0, p) - d_∞(p, q) > r + t + 1 - 1 = r + t

By the inductive hypothesis, step^t(c)(q) = false. Since this holds for all q in the closed neighborhood of p, Lemma 3.2 applied to step^t(c) gives step^{t+1}(c)(p) = step(step^t(c))(p) = false. □

**Remark.** The bound is tight: the glider pattern demonstrates that information can propagate at the full speed of one cell per step.

## 4. Causal Structure

### 4.1 Causal Precedence

**Definition 4.1**. The **causal precedence** relation on STPoint is:

(x₁, y₁, t₁) ≤_c (x₂, y₂, t₂) ⟺ t₁ ≤ t₂ ∧ d_∞((x₁,y₁), (x₂,y₂)) ≤ t₂ - t₁

**Theorem 4.2** (Partial Order). *Causal precedence is a partial order on STPoint.*

*Proof.*
- **Reflexivity**: d_∞(a, a) = 0 ≤ 0 = a.t - a.t.
- **Antisymmetry**: If a ≤_c b and b ≤_c a, then a.t = b.t and d_∞(σ(a), σ(b)) ≤ 0, so σ(a) = σ(b) and a = b.
- **Transitivity**: Given a ≤_c b ≤_c c, we have a.t ≤ c.t and d_∞(σ(a), σ(c)) ≤ d_∞(σ(a), σ(b)) + d_∞(σ(b), σ(c)) ≤ (b.t - a.t) + (c.t - b.t) = c.t - a.t. □

### 4.2 Causal Diamonds

**Definition 4.3**. The **causal diamond** between a and b is Diamond(a, b) = {c : a ≤_c c ∧ c ≤_c b}.

**Theorem 4.4** (Diamond Finiteness). *For any spacetime points a, b, the causal diamond Diamond(a, b) is finite.*

*Proof.* Any c ∈ Diamond(a, b) satisfies:
- a.t ≤ c.t ≤ b.t (from both precedence constraints)
- |c.x - a.x| ≤ b.t - a.t and |c.y - a.y| ≤ b.t - a.t (from the spatial distance bounds)

The diamond is thus contained in the finite product [a.t, b.t] × [a.x - Δ, a.x + Δ] × [a.y - Δ, a.y + Δ] where Δ = b.t - a.t. □

**Corollary 4.5** (Volume Bound). *|Diamond((0,0,0), (0,0,T))| ≤ (T+1)(2T+1)².*

### 4.3 Forward and Backward Light Cones

The **forward light cone** of a is J⁺(a) = {b : a ≤_c b}, and the **backward light cone** is J⁻(b) = {a : a ≤_c b}. The causal diamond is Diamond(a,b) = J⁺(a) ∩ J⁻(b).

## 5. Dynamical Consequences

### 5.1 Causality Theorem

**Theorem 5.1** (Causality). *If c₁(q) = c₂(q) for all q with d_∞(p, q) ≤ t, then step^t(c₁)(p) = step^t(c₂)(p).*

*Proof.* By induction on t, generalizing over p. The base case is direct. For the inductive step, step^{t+1}(c)(p) = step(step^t(c))(p). By locality, this depends only on step^t(c) restricted to the 1-neighborhood of p. For each q with d_∞(p, q) ≤ 1, the inductive hypothesis (applied to q) requires agreement within d_∞(q, ·) ≤ t. The triangle inequality ensures this from agreement within d_∞(p, ·) ≤ t + 1. □

### 5.2 Perturbation Spread Bound

**Theorem 5.2** (Perturbation Spread). *If c₁(p) = c₂(p) for all p with d_∞(center, p) > r, then step^t(c₁)(p) = step^t(c₂)(p) for all p with d_∞(center, p) > r + t.*

*Proof.* Similar to the speed of light theorem, by induction on t using locality and the triangle inequality. □

This theorem quantifies the spread of perturbations: a localized difference between two configurations grows at most linearly, at the speed of light.

## 6. Oscillator Theory

### 6.1 Basic Definitions

A **still life** is a configuration c with step(c) = c. An **oscillator of period p** is a configuration with p > 0 and step^p(c) = c.

**Theorem 6.1**. *Every still life is an oscillator of period 1.*

**Theorem 6.2** (Period Divisibility). *If c is an oscillator of period p, then c is an oscillator of period kp for all k ≥ 1.*

*Proof.* By induction on k. step^{(k+1)p}(c) = step^p(step^{kp}(c)) = step^p(c) = c. □

### 6.2 Support Boundedness

**Theorem 6.3**. *If support(c) ⊆ B_r(0), then support(step^t(c)) ⊆ B_{r+t}(0).*

This follows from the speed of light theorem by contraposition.

## 7. Connections to Existing Work

### 7.1 Tropical Geometry

The Chebyshev distance d_∞(p, q) = max(|p₁ - q₁|, |p₂ - q₂|) is the tropical sum (max-plus addition) of coordinate-wise L¹ distances. This connects the causal structure of GoL to tropical geometry, where max and plus replace plus and times.

The existing catalog contains tropical formulations of the GoL step function using the `tropicalThreshold` function, which implements the birth/survival predicates using min-plus operations. Our causal order provides the geometric framework that organizes these tropical computations.

### 7.2 Causal Set Theory

In the causal set approach to quantum gravity [3], spacetime is modeled as a locally finite partial order, with the volume of a spacetime region equal to the number of elements. Our GoL causal order is precisely such a causal set, with the causal diamond volume bound providing the analog of the Hauptvermutung (volume = cardinality).

### 7.3 Finite Propagation in PDE Theory

The speed of light theorem is the discrete analog of finite speed of propagation for hyperbolic PDEs. Just as the wave equation ∂²u/∂t² = c²∇²u has propagation speed c, the GoL step function has propagation speed 1 in the Chebyshev metric.

## 8. Algorithms

### 8.1 Light Cone Optimization

The causality theorem enables an important optimization for GoL simulation: when computing step^t(c)(p), only cells within d_∞(p, ·) ≤ t need be consulted. For sparse patterns with support of size S, this gives O(S · (2t+1)²) work for t steps, compared to O(grid_size) for naive simulation.

### 8.2 Perturbation Analysis

The perturbation spread bound enables efficient differential simulation: to compare the evolution of c and c', only the expanding zone of disagreement needs to be tracked, saving computation on the (potentially large) region where the configurations agree.

## 9. Discussion

The causal structure of Conway's Game of Life is richer than its computational universality might suggest. While Turing completeness is an asymptotic property — it requires unbounded time and space — the causal structure is a local, finite, geometric property that constrains every finite computation.

The formal verification of these results in Lean 4 provides a high degree of confidence in their correctness and enables future extension. The most promising directions include:

1. **Constructive Turing completeness**: encoding a universal Turing machine as a GoL pattern and proving correctness through the causal framework.

2. **Garden of Eden theory**: characterizing configurations with no predecessor, using the causal structure to constrain the search space.

3. **Entropy bounds**: defining and bounding the topological entropy of GoL using the causal diamond volume as a normalizing factor.

## 10. Conclusion

We have established a comprehensive formal foundation for the causal structure of Conway's Game of Life, proving that its dynamics respects a natural partial order on discrete spacetime. The speed of light theorem, causal diamond finiteness, and perturbation spread bound provide the infrastructure for rigorous analysis of GoL's physical properties.

The GoL Spacetime Causal Order is, to our knowledge, the first formally verified causal structure for a standard cellular automaton. It connects cellular automata theory to causal set theory, tropical geometry, and the theory of hyperbolic PDEs, opening new directions for research at the intersection of discrete dynamics and mathematical physics.

## References

[1] Gardner, M. (1970). "Mathematical Games – The fantastic combinations of John Conway's new solitaire game 'life'." Scientific American, 223(4), 120-123.

[2] Rendell, P. (2002). "Turing Universality of the Game of Life." In Collision-Based Computing, Springer.

[3] Bombelli, L., Lee, J., Meyer, D., & Sorkin, R. D. (1987). "Space-time as a causal set." Physical Review Letters, 59(5), 521.

[4] Maclagan, D., & Sturmfels, B. (2015). Introduction to Tropical Geometry. American Mathematical Society.
