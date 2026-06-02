# Equivariant Impossibility Spectra: A Lattice-Theoretic Framework for Impossibility Theorems

## Abstract

We introduce the **impossibility spectrum** of a pair of G-sets (X, Y) — the set of subgroups H ≤ G for which no H-equivariant map X → Y exists — and establish its fundamental structural properties. We prove that the impossibility spectrum is upward closed in the subgroup lattice, invariant under conjugation, and preserved by equivariant bijections (the transfer principle). We identify fixed-point counting and orbit structure as concrete obstruction mechanisms, and introduce the **obstruction filter** as a novel algebraic structure axiomatizing the properties of impossibility spectra. We state the Spectral Completeness Conjecture, asserting that every obstruction filter arises as the impossibility spectrum of some pair of finite G-sets, and discuss computational approaches to testing it. All main results have been verified in Lean 4 with the Mathlib library.

**Keywords**: equivariant maps, impossibility theorems, subgroup lattice, obstruction theory, group actions, fixed points, orbit theory

---

## 1. Introduction

Impossibility theorems pervade mathematics and its applications: Arrow's impossibility theorem in social choice theory, the Borsuk–Ulam theorem in topology, undecidability results in computability theory, and no-go theorems in quantum mechanics. While these results arise in diverse contexts, they share a common feature: the impossibility stems from a **symmetry constraint**. A function or construction that exists without symmetry requirements becomes impossible when equivariance under a group action is demanded.

Despite this commonality, impossibility theorems have traditionally been studied in isolation, each with its own proof technique. We propose a unifying framework that captures the symmetry-based core of these results through a single lattice-theoretic invariant: the **impossibility spectrum**.

### 1.1 Overview of Results

Our main contributions are:

1. **Definition** of the impossibility spectrum `ImpSpec(G, X, Y)` and the obstruction filter structure (Section 2).

2. **Upward Closure Theorem** (Theorem 3.1): The impossibility spectrum is an upper set in the subgroup lattice of G.

3. **Fixed-Point Obstruction** (Theorem 4.1): If the H-fixed points of X are nonempty but those of Y are empty, then H ∈ ImpSpec(G, X, Y).

4. **Orbit Image Theorem** (Theorem 4.2): G-equivariant maps send orbits exactly onto orbits, providing an orbit-theoretic obstruction mechanism.

5. **Transfer Principle** (Theorem 5.1): Equivariant bijections preserve the impossibility spectrum.

6. **Conjugation Invariance** (Theorem 6.1): The impossibility spectrum is invariant under conjugation of subgroups.

7. **Filter Construction** (Theorem 7.1): The impossibility spectrum of any pair (X, Y) with Y nonempty is an obstruction filter.

8. **Spectral Completeness Conjecture** (Conjecture 8.1): Every obstruction filter on a finite group is realizable.

---

## 2. Definitions

### 2.1 Equivariant Maps

Let G be a group acting on sets X and Y. For a subgroup H ≤ G, a function f : X → Y is **H-equivariant** if

$$f(h \cdot x) = h \cdot f(x) \quad \text{for all } h \in H, \, x \in X.$$

We write `IsSubgroupEquivariant(H, f)` for this property.

**Key observation**: K-equivariance is a strictly stronger condition than H-equivariance when H ≤ K, since the equivariance condition must hold for more group elements.

### 2.2 The Impossibility Spectrum

**Definition 2.1.** The **impossibility spectrum** of a pair of G-sets (X, Y) is

$$\text{ImpSpec}(G, X, Y) = \{ H \leq G \mid \nexists f : X \to Y \text{ with } f \text{ H-equivariant} \}.$$

This is a subset of the subgroup lattice Sub(G).

### 2.3 The Obstruction Filter

**Definition 2.2.** An **obstruction filter** on a group G is a pair (S, ↑, ⊥) where:
- S ⊆ Sub(G) is a collection of subgroups;
- **Upward closure**: if H ∈ S and H ≤ K, then K ∈ S;
- **Non-triviality**: ⊥ ∉ S (the trivial subgroup is not in S).

The motivation for excluding ⊥ is that a constant map to any element of a nonempty target set is always ⊥-equivariant (since the only element of the trivial subgroup is the identity, which acts trivially).

---

## 3. The Upward Closure Theorem

**Theorem 3.1** (Upward Closure). *If H ∈ ImpSpec(G, X, Y) and H ≤ K, then K ∈ ImpSpec(G, X, Y).*

*Proof sketch.* If f : X → Y is K-equivariant, then since H ≤ K, every h ∈ H is also in K, so f(h · x) = h · f(x) for all h ∈ H. Thus f is H-equivariant. The contrapositive gives the result: if no H-equivariant map exists, then no K-equivariant map exists. ∎

**Corollary 3.2.** ImpSpec(G, X, Y) is an upper set (upset) in the lattice Sub(G).

This has a strong structural consequence: the complement of ImpSpec(G, X, Y) — the set of subgroups for which equivariant maps *do* exist — is a **lower set** (downset, order ideal). The downset structure means that the "possibility region" is closed under taking subgroups, a principle we call the **monotonicity of possibility**.

---

## 4. Obstruction Mechanisms

### 4.1 Fixed-Point Obstruction

**Lemma 4.0** (Fixed-Point Preservation). *If f : X → Y is H-equivariant, then f maps X^H into Y^H, where X^H = {x ∈ X : h · x = x for all h ∈ H} denotes the H-fixed point set.*

*Proof.* If x ∈ X^H, then for any h ∈ H, h · f(x) = f(h · x) = f(x), so f(x) ∈ Y^H. ∎

**Theorem 4.1** (Fixed-Point Obstruction). *If X^H ≠ ∅ and Y^H = ∅, then H ∈ ImpSpec(G, X, Y).*

*Proof.* If f : X → Y were H-equivariant, Lemma 4.0 would give f(X^H) ⊆ Y^H = ∅, but X^H ≠ ∅ implies f(X^H) ≠ ∅, a contradiction. ∎

**Theorem 4.1'** (Cardinality Obstruction). *If Y is finite, |Y^H| = 0, and X^H ≠ ∅, then H ∈ ImpSpec(G, X, Y).*

This is a special case of Theorem 4.1, but stated in a form amenable to computational verification when Y is a finite type.

### 4.2 Orbit-Theoretic Obstruction

**Theorem 4.2** (Orbit Image Theorem). *If f : X → Y is G-equivariant, then for any x ∈ X,*
$$f(\text{Orb}_G(x)) = \text{Orb}_G(f(x)).$$

*Proof.* For the forward inclusion: if y ∈ f(Orb_G(x)), then y = f(g · x) = g · f(x) by equivariance, so y ∈ Orb_G(f(x)). For the reverse: if y = g · f(x) ∈ Orb_G(f(x)), then y = f(g · x) and g · x ∈ Orb_G(x), so y ∈ f(Orb_G(x)). ∎

**Corollary 4.3** (Orbit Type Obstruction). *If X has an orbit of type G/H (i.e., with stabilizer conjugate to H) and Y has no orbit of this type, then no injective G-equivariant map X → Y exists.*

---

## 5. The Transfer Principle

**Theorem 5.1** (Transfer Principle). *Let eX : X → X' and eY : Y → Y' be G-equivariant bijections. Then*
$$\text{ImpSpec}(G, X, Y) = \text{ImpSpec}(G, X', Y').$$

*Proof sketch.* For the forward direction: suppose H ∈ ImpSpec(G, X, Y) and there exists an H-equivariant f' : X' → Y'. Define f = eY^{-1} ∘ f' ∘ eX. Since eX, f', and eY^{-1} are all H-equivariant (using that G-equivariance implies H-equivariance for H ≤ G, and bijective equivariant maps have equivariant inverses), f is H-equivariant, contradicting H ∈ ImpSpec(G, X, Y). The reverse direction is symmetric. ∎

**Interpretation.** The transfer principle means that the impossibility spectrum is an invariant of the equivariant isomorphism class, not of the specific representation. This is crucial for applications: it allows us to replace a complicated problem with a simpler one having the same impossibility structure.

---

## 6. Conjugation Invariance

**Theorem 6.1** (Conjugation Invariance). *For any g ∈ G, H ∈ ImpSpec(G, X, Y) implies gHg^{-1} ∈ ImpSpec(G, X, Y).*

*Proof sketch.* Suppose f : X → Y is gHg^{-1}-equivariant. Define f'(x) = g^{-1} · f(g · x). Then f' is H-equivariant: for h ∈ H and x ∈ X,
$$f'(h · x) = g^{-1} · f(g · (h · x)) = g^{-1} · f((ghg^{-1}) · (g · x)) = g^{-1} · (ghg^{-1}) · f(g · x) = h · (g^{-1} · f(g · x)) = h · f'(x).$$
This contradicts H ∈ ImpSpec(G, X, Y). ∎

**Corollary 6.2.** The impossibility spectrum is a union of conjugacy classes of subgroups. In particular, if G is abelian, the impossibility spectrum is simply an upper set in the subgroup lattice (with no additional conjugation structure).

---

## 7. The Filter Construction

**Theorem 7.1.** *For any G-sets X, Y with Y nonempty, the impossibility spectrum ImpSpec(G, X, Y) is an obstruction filter.*

*Proof.* Upward closure is Theorem 3.1. For non-triviality: choose y₀ ∈ Y (using nonemptiness) and define f(x) = y₀ for all x. Then f is ⊥-equivariant since the only element of the trivial subgroup is the identity, and f(1 · x) = f(x) = 1 · f(x) = 1 · y₀ = y₀ = f(x). ∎

---

## 8. The Spectral Completeness Conjecture

**Conjecture 8.1** (Spectral Completeness). *For any finite group G, every obstruction filter on G is realizable as ImpSpec(G, X, Y) for some finite G-sets X, Y with Y nonempty.*

### 8.1 Computational Test

For G = ℤ/6ℤ, the subgroup lattice has subgroups of orders 1, 2, 3, 6 (one of each). The upper sets not containing ⊥ = {e} are:
- ∅ (the empty spectrum — always realizable by taking X = Y)
- {G} (only the full group is obstructed)
- {H₃, G} where H₃ has order 3
- {H₂, G} where H₂ has order 2
- {H₂, H₃, G}

For each, one can attempt to construct explicit finite G-sets realizing the spectrum.

### 8.2 Proof Strategy

A potential approach uses the Burnside ring of G. The impossibility spectrum can be expressed in terms of the marks (fixed-point counts) of the G-sets, and the realizability question becomes: given constraints on mark differences, can we find G-sets satisfying them? The Burnside ring's structure theory may provide the necessary existence results.

---

## 9. Algorithms

### 9.1 Computing the Impossibility Spectrum

For finite groups and finite G-sets, the impossibility spectrum can be computed as follows:

1. Enumerate all subgroups H ≤ G (up to conjugacy, by Theorem 6.1).
2. For each H, compute X^H and Y^H.
3. If X^H ≠ ∅ and Y^H = ∅, add H (and its conjugates) to the spectrum.
4. For remaining subgroups, check orbit type compatibility.
5. For subgroups surviving both checks, attempt to construct an H-equivariant map via constraint satisfaction.

**Complexity**: Steps 1-3 run in O(|Sub(G)| · (|X| + |Y|)) time. Step 5 is NP-hard in general (it reduces to graph homomorphism), but the fixed-point and orbit checks eliminate most cases.

### 9.2 Upward Closure Optimization

Since the spectrum is upward closed, we can optimize by working bottom-up: if H is *not* in the spectrum (an equivariant map exists), then no subgroup of H can be in the spectrum either. This allows pruning of the search tree.

---

## 10. Applications

### 10.1 Social Choice Theory

Arrow's impossibility theorem can be viewed through this lens: the "G-sets" are spaces of preference profiles and social welfare functions, with the symmetric group S_n acting by permuting alternatives. Arrow's theorem asserts that the full symmetric group is in the impossibility spectrum (with additional rationality constraints on the maps).

### 10.2 Distributed Computing

The impossibility of consensus in asynchronous systems with one faulty process (FLP impossibility) has a symmetry interpretation: the set of initial configurations and the set of decision values carry natural symmetry actions, and the impossibility arises from equivariance constraints imposed by the asynchronous model.

### 10.3 Topology

The Borsuk–Ulam theorem states that any continuous map from S^n to ℝ^n has an antipodal coincidence, which is equivalent to the nonexistence of a ℤ/2ℤ-equivariant map S^n → S^{n-1}. In our framework, ℤ/2ℤ belongs to the impossibility spectrum of (S^n, S^{n-1}) for the antipodal action.

---

## 11. Discussion and Future Work

The impossibility spectrum provides a unified language for impossibility theorems across mathematics. Several directions for future work are particularly promising:

1. **Spectral Completeness**: Proving or disproving Conjecture 8.1, possibly using Burnside ring techniques.

2. **Approximate Equivariance**: Extending the framework to maps that are "almost equivariant" — satisfying d(f(h·x), h·f(x)) ≤ ε in a metric setting. Understanding the stability of the impossibility spectrum under perturbation.

3. **Categorical Generalization**: Replacing G-sets with G-objects in a category, and studying the impossibility spectrum for equivariant morphisms in categories beyond Set.

4. **Connections to Equivariant Cohomology**: The obstruction filter structure is reminiscent of support theory in modular representation theory and tensor triangular geometry. Exploring this connection could yield deep structural results.

5. **Computational Complexity**: Understanding the complexity of deciding whether a given subgroup belongs to the impossibility spectrum of two explicitly given finite G-sets.

---

## References

1. Arrow, K. J. (1951). *Social Choice and Individual Values*. Wiley.
2. Bredon, G. E. (1972). *Introduction to Compact Transformation Groups*. Academic Press.
3. tom Dieck, T. (1987). *Transformation Groups*. de Gruyter.
4. Fischer, M. J., Lynch, N. A., & Paterson, M. S. (1985). Impossibility of distributed consensus with one faulty process. *JACM*, 32(2), 374–382.
5. Matoušek, J. (2003). *Using the Borsuk–Ulam Theorem*. Springer.
6. Dress, A. W. M. (1969). A characterisation of solvable groups. *Math. Z.*, 110, 213–217.
