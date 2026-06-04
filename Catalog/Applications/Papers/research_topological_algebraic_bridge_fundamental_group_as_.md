# The Invariant Spectrum: A Graded Classification Framework for Topological-Algebraic Invariants

## Abstract

We introduce the **Invariant Spectrum**, a novel mathematical structure that formalizes the graded tower of algebraic invariants used to classify topological spaces up to homotopy equivalence. An Invariant Spectrum is a sequence of sound invariants indexed by the natural numbers, modeling the tower of homotopy groups (π₀, π₁, π₂, ...). We define key notions — *cumulative completeness*, *essential dimension*, *asphericity*, and *confusion pairs* — and prove a suite of structural theorems establishing when invariants at a given level suffice for complete classification.

Our central result, the **Aspherical Completeness Transfer Theorem** (Theorem 5), formalizes the classical fact that the fundamental group π₁ is a complete invariant for K(G,1) spaces: if a spectrum is aspherical (all invariants above level 1 are trivial), then cumulative completeness at level 1 is equivalent to cumulative completeness at any higher level. We also prove a **Dichotomy Theorem** (Theorem 10) showing that any separating spectrum either has level 1 complete or admits a *higher-dimensional witness* — a pair of objects indistinguishable at level 1 but separated at a higher level.

All results are formalized in Lean 4 with complete machine-verified proofs.

## 1. Introduction

A central theme in algebraic topology is the question: *when does a given algebraic invariant completely determine the topological type of a space?* The fundamental group π₁ is the most classical such invariant, yet it famously fails to distinguish many spaces. The sphere S² and the sphere S³ both have trivial fundamental groups, yet are topologically distinct — a fact revealed only by higher homotopy groups (π₂(S²) ≅ ℤ while π₂(S³) = 0).

However, for a special class of spaces — the **Eilenberg-MacLane spaces** K(G,1), also called *aspherical spaces* — the fundamental group *is* a complete invariant. These spaces have all higher homotopy groups trivial (πₙ = 0 for n ≥ 2), and two K(G,1) spaces with isomorphic fundamental groups are homotopy equivalent.

This paper formalizes and generalizes this phenomenon through a new algebraic structure. Rather than working with specific topological constructions, we abstract the essential pattern: a graded sequence of invariants, where completeness at a given level depends on the vanishing of higher-level information.

## 2. Definitions

### 2.1 Sound and Complete Invariants

Let α be a type equipped with a setoid (equivalence relation ≈).

**Definition 2.1** (Sound Invariant). A *sound invariant* is a pair (β, f) where f : α → β satisfies: if x ≈ y then f(x) = f(y).

**Definition 2.2** (Complete Invariant). A *complete invariant* is a sound invariant that additionally satisfies: if f(x) = f(y) then x ≈ y.

**Definition 2.3** (Incomplete Invariant). A sound invariant is *incomplete* if there exist x, y with f(x) = f(y) but ¬(x ≈ y).

### 2.2 The Invariant Spectrum

**Definition 2.4** (Invariant Spectrum). An *invariant spectrum* over (α, ≈) consists of:
- A family of types (InvType(n))_{n ∈ ℕ}
- A family of functions inv(n) : α → InvType(n)
- Soundness: for each n, if x ≈ y then inv(n)(x) = inv(n)(y)

**Definition 2.5** (Level Completeness). Level n is *complete* if inv(n)(x) = inv(n)(y) implies x ≈ y.

**Definition 2.6** (Cumulative Completeness). The spectrum is *cumulatively n-complete* if: whenever inv(k)(x) = inv(k)(y) for all k ≤ n, then x ≈ y.

**Definition 2.7** (Essential Dimension). The *essential dimension* is the minimum n such that the spectrum is cumulatively n-complete.

**Definition 2.8** (Aspherical Spectrum). A spectrum is *aspherical* if for all n > 1 and all x, y: inv(n)(x) = inv(n)(y). (All invariants above level 1 are trivial.)

**Definition 2.9** (Confusion Pair). A *confusion pair* at level n is a pair (x, y) with inv(k)(x) = inv(k)(y) for all k ≤ n, but ¬(x ≈ y).

**Definition 2.10** (Higher-Dimensional Witness). A *higher-dimensional witness* consists of x, y with inv(1)(x) = inv(1)(y) and some level n > 1 with inv(n)(x) ≠ inv(n)(y).

## 3. Main Results

### 3.1 Structural Properties

**Theorem 3.1** (Complete Invariant Characterization). For a complete invariant f: f(x) = f(y) if and only if x ≈ y.

**Theorem 3.2** (Product Completeness). If (β₁, f) is a complete invariant and (β₂, g) is sound, then the product invariant (f, g) is complete.

**Theorem 3.3** (Monotone Completeness). If a spectrum is cumulatively n-complete, it is cumulatively (n+1)-complete.

*Proof sketch.* Given cumulative completeness at level n, and a hypothesis that inv(k)(x) = inv(k)(y) for all k ≤ n+1, the restriction to k ≤ n gives x ≈ y by the assumption.

**Theorem 3.4** (Incompleteness Witness). If a spectrum is not cumulatively n-complete, there exists a confusion pair at level n.

*Proof sketch.* Direct negation of the universal statement in the definition of cumulative completeness.

**Theorem 3.5** (Essential Dimension Uniqueness). If the essential dimension exists, it is unique.

*Proof sketch.* By antisymmetry of ℕ. If m, n are both essential dimensions with m ≠ n, then m < n or n < m. In either case, the minimality condition of one contradicts the completeness of the other.

### 3.2 The K(G,1) Theorem

**Theorem 3.6** (Aspherical Completeness Transfer — The Abstract K(G,1) Theorem). For an aspherical spectrum S and n ≥ 1:

> S is cumulatively 1-complete ⟺ S is cumulatively n-complete.

*Proof.* The forward direction follows by induction using Theorem 3.3. For the backward direction: given cumulative n-completeness and inv(k)(x) = inv(k)(y) for k ≤ 1, we must show x ≈ y. For k > 1, asphericity gives inv(k)(x) = inv(k)(y) automatically. Thus inv(k)(x) = inv(k)(y) for all k ≤ n, and n-completeness gives x ≈ y.

**Corollary 3.7** (Level 1 Complete ⟹ Full Classification for Aspherical Spectra). If a spectrum is aspherical and level 1 is complete, then inv(1)(x) = inv(1)(y) ⟺ x ≈ y.

This is the abstract version of the classical result that for K(G,1) spaces, the fundamental group is a complete invariant.

### 3.3 Boundary Analysis

**Theorem 3.8** (Higher Witness ⟹ Level 1 Incomplete). If a higher-dimensional witness (x, y, n) exists, then level 1 is not complete.

*Proof.* Suppose level 1 is complete. Then inv(1)(x) = inv(1)(y) implies x ≈ y. By soundness, inv(n)(x) = inv(n)(y) for any n, contradicting the witness.

This captures the classical observation: S² and S³ have trivial π₁ (agree at level 1) but π₂(S²) ≅ ℤ ≠ 0 = π₂(S³) (disagree at level 2). The existence of this higher witness proves π₁ is not a complete invariant for all spaces.

**Theorem 3.9** (Aspherical Dichotomy). For a spectrum where every inequivalent pair that agrees at level 1 has a separating level above 1: either level 1 is complete, or a higher-dimensional witness exists.

### 3.4 Composition and Refinement

**Theorem 3.10** (Injective Composition). If f is a complete invariant and g : β → γ is injective, then g ∘ f is a complete invariant.

**Theorem 3.11** (Pullback Completeness). If f is complete for a finer equivalence relation r₁, it is complete for any coarser relation r₂.

### 3.5 Concrete Example

**Theorem 3.12** (Parity Incompleteness). The parity invariant ZMod 4 → ZMod 2 is incomplete: 0 and 2 have the same parity but are distinct modulo 4. This is a finite analogue of the S²/S³ phenomenon.

## 4. PEGB Analysis

### 4.1 Aspherical Completeness Transfer (Theorem 3.6)

- **P** (Proof): Complete Lean 4 proof using induction for the forward direction and asphericity for the backward direction.
- **E** (Example): The parity example (Theorem 3.12) demonstrates incompleteness; an aspherical spectrum on ZMod 2 with identity invariant at level 1 demonstrates completeness.
- **G** (Generalization): The theorem generalizes from ℕ-graded spectra to any well-ordered grading, and from setoids to categories (where "complete invariant" becomes "faithful functor").
- **B** (Boundary): The theorem fails for non-aspherical spectra. Example: ZMod 4 with parity at level 1 and identity at level 2 is NOT aspherical and level 1 alone is NOT complete.

### 4.2 Higher Witness Implies Incomplete (Theorem 3.8)

- **P** (Proof): Direct proof by contradiction in Lean 4.
- **E** (Example): S² and S³ with π₁ = 0 (agree at level 1) but π₂(S²) = ℤ ≠ 0 = π₂(S³) (disagree at level 2).
- **G** (Generalization): Any number of higher witnesses can exist; the "witness dimension" measures the minimum level at which they appear.
- **B** (Boundary): A higher witness at level n does NOT imply incompleteness at levels 2, ..., n-1. Each level's completeness is independent.

### 4.3 Essential Dimension Uniqueness (Theorem 3.5)

- **P** (Proof): Lean 4 proof using `grind` (automated reasoning over natural number arithmetic).
- **E** (Example): A spectrum with essential dimension 2: level 0 and 1 together are incomplete, but levels 0, 1, 2 together are complete. E.g., ZMod 8 classified by (mod 2, mod 4, mod 8).
- **G** (Generalization): Essential dimension generalizes to ordinal-valued essential dimension for transfinitely graded spectra.
- **B** (Boundary): Essential dimension may not exist if no finite level is cumulatively complete (e.g., the full homotopy spectrum of an infinite CW-complex with nontrivial homotopy groups at all levels).

## 5. Algorithms

### 5.1 Computing Essential Dimension (Finite Case)

For a finite type α with decidable equivalence:

```
Input: Spectrum S, type α (finite)
Output: Essential dimension d, or "infinite"

for n = 0, 1, 2, ..., |α|:
    if confusionCount(S, n) == 0:
        return n
return "infinite"
```

The confusion count is monotonically decreasing (Theorem implied by monotone completeness), so this terminates in at most |α| steps.

### 5.2 Finding Confusion Pairs

Given a non-complete level n:
```
for (x, y) in α × α:
    if inv(k, x) == inv(k, y) for all k ≤ n and x ≉ y:
        return (x, y)  # confusion pair
```

## 6. Discussion

### 6.1 Connection to Algebraic Topology

Our Invariant Spectrum directly models the Postnikov tower of homotopy groups. In this interpretation:
- Level 0 = π₀ (connected components)
- Level 1 = π₁ (fundamental group)
- Level n = πₙ (n-th homotopy group)
- Asphericity = K(G,1) condition (all πₙ = 0 for n ≥ 2)
- Essential dimension = homotopy dimension

The Aspherical Completeness Transfer Theorem is the abstract version of the classical result that K(G,1) spaces are classified by their fundamental group.

### 6.2 Connection to Model Theory

Complete invariants correspond to definable equivalence relations with quantifier elimination. The essential dimension corresponds to the quantifier depth needed for classification. This connects our framework to descriptive set theory and classification theory à la Hjorth and Kechris.

### 6.3 Cross-Connection to Catalog

Our framework connects to the existing catalog through the notion of "invariant completeness":
- **Tropical profiles** (OperadicTropicalization): tropical profiles are sound invariants for architecture congruence, and are proven complete for bounded architectures — this is level completeness in our framework.
- **Beta-equivalence** (BetaClassCanonicity): β-equivalence classes are proven to be a complete invariant for Nerode equivalence — this is a CompleteInvariant in our framework.
- **Transfer observables** (BerggrenTransferDuality): boundary partitions determined by transfer observables — a completeness result.

## 7. Falsifiable Conjecture

**Conjecture** (Spectrum Stabilization). For any Invariant Spectrum on a finite type α with |α| = n, if the confusion count at level k is equal to the confusion count at level k+1, then the confusion count stabilizes: it remains constant for all levels ≥ k.

**Test**: Compute confusion counts for specific finite spectra (e.g., ZMod n with various projection chains) and verify that stabilization occurs at the first repeated value.

**Status**: Not yet formalized. This is a natural conjecture from the monotone decrease property (confusion count is antitone) combined with discreteness of ℕ-valued counts.

## 8. Future Work

1. **Categorical generalization**: Replace setoids with categories and sound invariants with functors. Complete invariants become faithful functors, and the K(G,1) theorem becomes a statement about natural transformations.

2. **Ordinal-graded spectra**: Generalize from ℕ-indexed to ordinal-indexed spectra, capturing transfinite homotopy invariants.

3. **Computable essential dimension**: For decidable spectra on finite types, implement and verify an algorithm computing the essential dimension.

4. **Connection to cohomological dimension**: Relate essential dimension to sheaf-theoretic and cohomological dimension.

## References

1. Eilenberg, S. and MacLane, S. "Relations between homology and homotopy groups of spaces." Ann. of Math. 46 (1945): 480-509.
2. Whitehead, J.H.C. "Combinatorial homotopy. I." Bull. Amer. Math. Soc. 55 (1949): 213-245.
3. Postnikov, M.M. "Determination of the homology groups of a space by means of the homotopy invariants." Doklady Akad. Nauk SSSR 76 (1951): 359-362.
