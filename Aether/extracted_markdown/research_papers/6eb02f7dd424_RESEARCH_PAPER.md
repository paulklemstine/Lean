# Equivariant Impossibility Spectra: Spectral Gap, Defect Theory, and Orbit-Type Obstructions

## Abstract

We develop a formal algebraic framework for the **impossibility spectrum** of pairs of G-sets — the collection of subgroups H ≤ G for which no H-equivariant map exists between two given G-sets. We establish the fundamental structural properties of this spectrum: upward closure in the subgroup lattice, conjugation invariance, and the fixed-point obstruction principle. We introduce three novel concepts: the **spectral gap** (the antichain of minimal obstructing subgroups), the **equivariant defect set** (a quantitative measure of non-equivariance), and the **orbit-type obstruction** (a stabilizer-based criterion blocking injective equivariant maps). All results are formally verified in the Lean 4 theorem prover with the Mathlib library, providing machine-checked guarantees of correctness.

**Keywords:** Equivariant maps, impossibility theorems, group actions, spectral gap, formal verification

## 1. Introduction

### 1.1 Motivation

Equivariant maps — functions that commute with group actions — arise throughout mathematics and its applications. In representation theory, equivariant maps between group representations are intertwiners. In algebraic topology, equivariant maps between G-spaces are the morphisms of the equivariant homotopy category. In machine learning, equivariant neural networks have emerged as a powerful architecture for problems with inherent symmetries.

A fundamental question is: when does an equivariant map between two G-sets exist? Individual impossibility results abound — from the Borsuk-Ulam theorem in topology to Arrow's theorem in social choice theory — but a unified structural theory of equivariant impossibility has been lacking.

### 1.2 Contributions

We develop such a theory through the concept of the **impossibility spectrum**. Our main contributions are:

1. **Structural theory of the impossibility spectrum** (Theorems 1–3): We prove that the impossibility spectrum is an upper set in the subgroup lattice, is invariant under conjugation, and satisfies a transfer principle under equivariant bijections.

2. **Spectral gap theory** (Theorems 4–5): We introduce the spectral gap — the antichain of minimal obstructing subgroups — and prove it determines the full spectrum through upward closure.

3. **Equivariant defect theory** (Theorems 6–7): We introduce the defect set as a quantitative measure of non-equivariance, prove it characterizes equivariance exactly, and establish its compositional properties.

4. **Orbit-type obstruction** (Theorem 8): We prove that mismatched stabilizer structures block injective equivariant maps, strictly generalizing the fixed-point obstruction.

5. **Formal verification**: All results are machine-checked in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound).

## 2. Preliminaries

### 2.1 Group Actions and Equivariant Maps

Let G be a group acting on sets X and Y. For a subgroup H ≤ G, a function f : X → Y is **H-equivariant** if for all h ∈ H and x ∈ X:

$$f(h \cdot x) = h \cdot f(x)$$

We write HasHEquivariantMap(H, X, Y) for the proposition that such a map exists.

### 2.2 The Impossibility Spectrum

**Definition 1** (Impossibility Spectrum). The **impossibility spectrum** of a pair (X, Y) of G-sets is:

$$\text{ImpSpec}(G, X, Y) = \{H \leq G \mid \nexists f : X \to Y,\; f \text{ is } H\text{-equivariant}\}$$

### 2.3 Fixed Points

For a subgroup H ≤ G, the **fixed-point set** of H acting on X is:

$$\text{FixedPts}(H, X) = \{x \in X \mid \forall h \in H,\; h \cdot x = x\}$$

## 3. Structural Theory

### 3.1 Upward Closure

**Theorem 1** (Upward Closure). *The impossibility spectrum is an upper set in the subgroup lattice: if H ∈ ImpSpec(G, X, Y) and H ≤ K, then K ∈ ImpSpec(G, X, Y).*

*Proof sketch.* Any K-equivariant map is automatically H-equivariant (by restricting the equivariance condition to the subgroup H ≤ K). If no H-equivariant map exists, then a fortiori no K-equivariant map exists. □

This captures the intuition that more symmetry constraints make equivariant solutions harder, not easier.

### 3.2 Conjugation Invariance

**Theorem 2** (Conjugation Invariance). *For any g ∈ G, if H ∈ ImpSpec(G, X, Y), then gHg⁻¹ ∈ ImpSpec(G, X, Y).*

*Proof sketch.* Given an (gHg⁻¹)-equivariant map f, we construct an H-equivariant map f'(x) = g⁻¹ · f(g · x). For h ∈ H:

$$f'(h \cdot x) = g^{-1} \cdot f(g \cdot h \cdot x) = g^{-1} \cdot f((ghg^{-1}) \cdot (g \cdot x))$$
$$= g^{-1} \cdot (ghg^{-1}) \cdot f(g \cdot x) = h \cdot g^{-1} \cdot f(g \cdot x) = h \cdot f'(x)$$

So if H is in the spectrum (no H-equivariant map exists), the conjugate must be too. □

### 3.3 Transfer Principle

**Theorem 3** (Transfer Principle). *If there exists an H-equivariant bijection φ : X → X' with equivariant inverse ψ, then H ∈ ImpSpec(G, X, Y) implies H ∈ ImpSpec(G, X', Y).*

*Proof.* Given an H-equivariant map f : X' → Y, the composition f ∘ φ : X → Y is H-equivariant, contradicting H ∈ ImpSpec(G, X, Y). □

## 4. Spectral Gap Theory

### 4.1 The Spectral Gap

**Definition 2** (Spectral Gap). The **spectral gap** of (X, Y) is the set of minimal elements in ImpSpec(G, X, Y):

$$\text{Gap}(G, X, Y) = \{H \in \text{ImpSpec} \mid \forall K \in \text{ImpSpec},\; K \leq H \implies K = H\}$$

**Theorem 4** (Antichain Property). *The spectral gap is an antichain in the subgroup lattice: no two distinct elements are comparable.*

*Proof.* If H, K ∈ Gap with H ≤ K and H ≠ K, then by minimality of K applied to H (which is in the spectrum and ≤ K), we get H = K, contradicting H ≠ K. □

**Theorem 5** (Spectral Gap Determines Spectrum). *The full spectrum is the upward closure of the spectral gap: any element K in the spectrum with K ≥ H for some H in the gap satisfies K ∈ ImpSpec.*

This follows immediately from upward closure and the definition of the gap.

### 4.2 The Spectral Core

**Definition 3** (Spectral Core). The **spectral core** is the infimum of all spectral gap subgroups:

$$\text{Core}(G, X, Y) = \bigcap_{H \in \text{Gap}(G, X, Y)} H$$

**Theorem** (Empty Spectrum Core). *If ImpSpec(G, X, Y) = ∅, then Core(G, X, Y) = G* (the full group).

This reflects the fact that when everything is achievable, the "essential symmetry to break" is vacuously the entire group.

## 5. Equivariant Defect Theory

### 5.1 The Defect Set

**Definition 4** (Equivariant Defect Set). For a function f : X → Y and subgroup H ≤ G, the **defect set** is:

$$\text{Defect}(H, f) = \{(h, x) \in H \times X \mid f(h \cdot x) \neq h \cdot f(x)\}$$

This is the set of all pairs where equivariance fails.

**Theorem 6** (Defect Characterization). *Defect(H, f) = ∅ if and only if f is H-equivariant.*

*Proof.* Direct from the definitions: the defect set is empty iff the equivariance condition holds for all pairs. □

### 5.2 Compositional Properties

**Theorem 7** (Defect Composition). *If g : Y → Z is H-equivariant, then every defect of g ∘ f comes from a defect of f:*

$$\text{Defect}(H, g \circ f) \subseteq \text{proj}(\text{Defect}(H, f))$$

*where proj is the natural projection.*

*Proof.* If f(h · x) = h · f(x), then (g ∘ f)(h · x) = g(f(h · x)) = g(h · f(x)) = h · g(f(x)) = h · (g ∘ f)(x), where the last step uses equivariance of g. Contrapositively, a defect in the composition implies a defect in f. □

This compositional structure enables modular analysis of complex equivariant architectures.

## 6. Obstruction Theory

### 6.1 Fixed-Point Obstruction

**Theorem** (Fixed-Point Obstruction). *If FixedPts(H, X) ≠ ∅ and FixedPts(H, Y) = ∅, then H ∈ ImpSpec(G, X, Y).*

*Proof.* An equivariant map sends fixed points to fixed points. If the target has no fixed points, the image of any source fixed point would need to be a non-existent fixed point. □

**Theorem** (Cardinality Obstruction). *If f : X → Y is injective and H-equivariant, and FixedPts(H, Y) is finite, then |FixedPts(H, X)| ≤ |FixedPts(H, Y)|.*

### 6.2 Orbit-Type Obstruction

**Definition 5** (Orbit-Type Obstruction). An **orbit-type obstruction** for (H, X, Y) exists if there is some x ∈ X whose H-stabilizer has no match among H-stabilizers of points in Y:

$$\exists x \in X,\; \forall y \in Y,\; \text{Stab}_H(x) \neq \text{Stab}_H(y)$$

**Theorem 8** (Orbit-Type Blocks Injective Maps). *If an orbit-type obstruction exists, then no injective H-equivariant map X → Y exists.*

*Proof.* An injective equivariant map preserves stabilizers: if f is injective and equivariant, then Stab_H(x) = Stab_H(f(x)). Forward: if h stabilizes x, then f(h·x) = f(x), and by equivariance h·f(x) = f(x). Reverse: if h stabilizes f(x), then h·f(x) = f(x), by equivariance f(h·x) = f(x), and by injectivity h·x = x.

If an orbit-type obstruction exists at x, then Stab_H(x) ≠ Stab_H(y) for all y, but f(x) is a point of Y with Stab_H(f(x)) = Stab_H(x), contradiction. □

The orbit-type obstruction strictly generalizes the fixed-point obstruction: a fixed point has stabilizer equal to the full subgroup H, so if the target has no fixed points, the stabilizer pattern {H} has no match.

## 7. Product Principles

**Theorem** (Product Principle). *If HasHEquivariantMap(H, X, Y₁) and HasHEquivariantMap(H, X, Y₂), then HasHEquivariantMap(H, X, Y₁ × Y₂) (with the diagonal action).*

*Proof.* Given equivariant maps f₁ and f₂, the map x ↦ (f₁(x), f₂(x)) is equivariant for the diagonal action on the product. □

**Corollary.** *ImpSpec(G, X, Y₁ × Y₂) ⊆ ImpSpec(G, X, Y₁) ∪ ImpSpec(G, X, Y₂).*

## 8. Algorithms

### 8.1 Computing the Impossibility Spectrum

For finite groups, the impossibility spectrum can be computed algorithmically:

**Algorithm: Spectrum Computation**
```
Input: Finite group G, finite G-sets X, Y
Output: ImpSpec(G, X, Y)

1. Enumerate all subgroups H of G (up to conjugacy)
2. For each H:
   a. Compute FixedPts(H, X) and FixedPts(H, Y)
   b. If |FixedPts(H, X)| > 0 and |FixedPts(H, Y)| = 0:
      mark H as obstructed (fixed-point obstruction)
   c. Otherwise, attempt to construct an equivariant map
      by solving the system of constraints f(h·x) = h·f(x)
3. Return {H | no equivariant map found}
```

### 8.2 Computing the Spectral Gap

```
Input: ImpSpec(G, X, Y)
Output: SpectralGap(G, X, Y)

1. Sort subgroups in ImpSpec by order |H|
2. For each H in ascending order:
   If no previously accepted K satisfies K ≤ H:
      add H to the gap
3. Return collected gap subgroups
```

## 9. Applications

### 9.1 Equivariant Neural Networks

In equivariant deep learning, one seeks neural network architectures that commute with a group action. The impossibility spectrum classifies which symmetry constraints are compatible with which function spaces. The spectral gap identifies the minimal symmetry reduction needed to escape impossibility.

### 9.2 Social Choice Theory

Arrow's impossibility theorem states that no voting rule satisfies certain fairness axioms for ≥ 3 alternatives. This can be reformulated as: the symmetric group S₃ is in the impossibility spectrum for aggregation maps on preference profiles. The spectral framework generalizes this to identify which subgroups of S_n create impossibility.

### 9.3 Crystallographic Constraints

Crystal structures are classified by space groups. The impossibility spectrum for maps between crystal structures (viewed as G-sets for the relevant space group) captures which structural transformations are forbidden by symmetry.

## 10. Discussion

### 10.1 Relation to Equivariant Homotopy Theory

The impossibility spectrum is the set-theoretic shadow of a richer homotopy-theoretic invariant. In equivariant homotopy theory, the space of equivariant maps [X, Y]^G has a filtration by subgroups, and the impossibility spectrum captures the set of subgroups where this space is empty.

### 10.2 The Obstruction Filter

The structural properties we establish — upward closure, conjugation invariance, and exclusion of the trivial subgroup (when the target is nonempty) — are precisely the axioms of what we call an *obstruction filter*. A natural question is whether every obstruction filter is realizable as the impossibility spectrum of some pair of G-sets. This **spectral completeness** question is the most important open problem in this theory.

### 10.3 Approximate Equivariance

The equivariant defect set opens the door to a quantitative theory of approximate equivariance. When equipped with a metric on Y, the defect set can be refined to a defect *measure*, enabling continuous interpolation between full equivariance and no symmetry constraint.

## 11. Future Work

1. **Spectral Completeness**: Prove that every obstruction filter is realizable as an impossibility spectrum. The marks homomorphism of the Burnside ring provides a concrete approach.

2. **Quantitative Defect Bounds**: Develop metric-space versions of the defect theory, with explicit bounds on the achievable defect for approximately equivariant maps.

3. **Higher-Categorical Extensions**: Extend the impossibility spectrum to higher-categorical actions (G-categories, G-∞-groupoids), connecting to equivariant homotopy type theory.

4. **Computational Complexity**: Determine the complexity of computing the impossibility spectrum and spectral gap for finite groups.

## References

1. T. tom Dieck, *Transformation Groups*, de Gruyter, 1987.
2. P. May, *Equivariant Homotopy and Cohomology Theory*, CBMS Regional Conference Series, 1996.
3. M. Weiler et al., "General E(2)-Equivariant Steerable CNNs," NeurIPS 2019.
4. K. Arrow, *Social Choice and Individual Values*, Wiley, 1951.
5. The Mathlib Community, *Mathlib: A Unified Library of Mathematics Formalized in Lean 4*, 2024.
