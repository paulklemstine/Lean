# Height Cocycles and the Monodromy Classification of Impossible Figures

## Abstract

We develop a rigorous mathematical framework for the classification of impossible figures using height cocycles on cycle graphs. The central result is the **Monodromy Classification Theorem**: a height cocycle on the cycle graph Cₙ is a coboundary (realizable as a consistent 3D height assignment) if and only if its monodromy — the sum of edge weights around the cycle — vanishes. We prove this theorem constructively, providing an explicit height reconstruction algorithm for the realizable case. We extend the framework to orientation cocycles, proving that the orientation monodromy (product of ±1 local orientations) classifies figures as orientable or non-orientable, and establish the odd-parity criterion for non-orientability. We derive the Hodge decomposition for cycle graphs, the perturbation stability of impossibility, and rational rigidity of the monodromy invariant. All main results have been formally verified in Lean 4 with the Mathlib library.

**Keywords**: impossible figures, height cocycles, monodromy, discrete cohomology, cycle graphs, Penrose triangle, orientation cocycles, Hodge decomposition

---

## 1. Introduction

Impossible figures — drawings that appear locally consistent but are globally unrealizable in three-dimensional Euclidean space — have fascinated artists, psychologists, and mathematicians since the pioneering work of Penrose and Penrose (1958) and the art of M.C. Escher. Despite extensive study in visual perception and computer graphics, the mathematical foundations of impossibility have lacked a unified, formally verified treatment.

This paper develops such a treatment using the language of discrete cohomology. We model an impossible figure as a **height cocycle** on a cycle graph: a real-valued function on directed edges encoding local height differences between adjacent vertices. The key observation is that a figure is realizable if and only if the cocycle is a **coboundary** — that is, it arises as the discrete differential of a global height function.

The obstruction to realizability is the **monodromy**: the sum of edge weights around the cycle. This is the discrete analogue of the period integral in de Rham cohomology. The Monodromy Classification Theorem states that the monodromy provides a complete invariant: a cocycle is a coboundary if and only if the monodromy vanishes.

### 1.1 Related Work

The connection between impossible figures and cohomology was observed informally by several authors. Sugihara (1986) characterized impossible objects through linear algebraic conditions on vertex heights. Huffman (1971) and Clowes (1971) developed junction-labeling approaches for line drawings. Our contribution formalizes these ideas in the language of cochains and coboundaries on graphs, proves the classification theorem constructively, and extends it to orientation cocycles and the Hodge decomposition.

### 1.2 Contributions

1. **Monodromy Classification Theorem** (Theorem 3.1): Complete characterization of coboundaries on cycle graphs via vanishing monodromy.
2. **Constructive height reconstruction** (Theorem 3.2): Explicit algorithm for building height functions from zero-monodromy cocycles.
3. **Orientation cocycle theory** (Section 4): Classification of orientability via the orientation monodromy product and the odd-parity criterion.
4. **Hodge decomposition** (Section 5): Unique decomposition of cocycles into coboundary and harmonic parts.
5. **Perturbation stability** (Theorem 6.1): Impossibility is stable under perturbations smaller than the monodromy.
6. **Rational rigidity** (Theorem 6.2): Rational cocycles have rational monodromy.
7. **Formal verification**: All main results verified in Lean 4 with Mathlib.

---

## 2. Definitions

### 2.1 Cycle Graph Cocycles

**Definition 2.1** (Cycle Graph). The cycle graph Cₙ (n ≥ 1) has vertex set {0, 1, ..., n−1} and directed edges i → (i+1) mod n for each i.

**Definition 2.2** (Height Cocycle). A *height cocycle* on Cₙ is a function ω : {0, ..., n−1} → ℝ, where ω(i) represents the height difference along edge i → (i+1) mod n.

Formally, the space of height cocycles is C¹(Cₙ; ℝ) = ℝⁿ (one real value per edge).

**Definition 2.3** (Monodromy). The *monodromy* of a cocycle ω is:

    M(ω) = Σᵢ₌₀ⁿ⁻¹ ω(i)

This is the total height discrepancy accumulated in one traversal of the cycle.

**Definition 2.4** (Coboundary). A cocycle ω is a *coboundary* if there exists a height function h : {0, ..., n−1} → ℝ such that:

    ω(i) = h((i+1) mod n) − h(i)   for all i

Coboundaries correspond to the image of the discrete differential δ : C⁰(Cₙ; ℝ) → C¹(Cₙ; ℝ).

**Definition 2.5** (Impossibility Index). The *impossibility index* of ω is |M(ω)|. It measures "how impossible" the figure is: zero for realizable, positive for impossible.

### 2.2 Impossible Figures

**Definition 2.6** (Impossible Figure). An *impossible figure* is a pair (Cₙ, ω) where ω is a height cocycle with M(ω) ≠ 0.

**Example 2.7** (Penrose Triangle). The Penrose triangle corresponds to n = 3 with ω(0) = ω(1) = ω(2) = 1. The monodromy is M(ω) = 3 ≠ 0.

**Example 2.8** (Escher Staircase). An Escher staircase with 4 flights corresponds to n = 4 with ω(i) = 2 for all i. The monodromy is M(ω) = 8.

### 2.3 Orientation Cocycles

**Definition 2.9** (Orientation Cocycle). An *orientation cocycle* on Cₙ is a function σ : {0, ..., n−1} → {+1, −1}, where σ(i) indicates whether orientation is preserved (+1) or reversed (−1) at edge i.

**Definition 2.10** (Orientation Monodromy). The *orientation monodromy* is:

    M_or(σ) = Πᵢ₌₀ⁿ⁻¹ σ(i)

**Definition 2.11** (Non-orientability). A figure is *non-orientable* if M_or(σ) = −1.

### 2.4 Cohomology

**Definition 2.12** (Cohomologous). Two cocycles ω₁, ω₂ are *cohomologous* if ω₁ − ω₂ is a coboundary. This is an equivalence relation.

The first cohomology group H¹(Cₙ; ℝ) = C¹(Cₙ; ℝ) / B¹(Cₙ; ℝ) classifies cocycles up to coboundary equivalence.

---

## 3. The Monodromy Classification Theorem

### 3.1 The Telescoping Lemma

**Lemma 3.1** (Telescoping Sum). For any function h : Fin n → ℝ and n ≥ 1:

    Σᵢ₌₀ⁿ⁻¹ (h((i+1) mod n) − h(i)) = 0

*Proof sketch.* The map i ↦ (i+1) mod n is a permutation of {0, ..., n−1}. By the permutation invariance of finite sums:

    Σᵢ h((i+1) mod n) = Σᵢ h(i)

Therefore their difference is zero. □

### 3.2 Forward Direction

**Theorem 3.1** (Coboundary ⟹ Zero Monodromy). If ω is a coboundary, then M(ω) = 0.

*Proof.* Let h be the height function with ω(i) = h((i+1) mod n) − h(i). Then:

    M(ω) = Σᵢ ω(i) = Σᵢ (h((i+1) mod n) − h(i)) = 0

by the Telescoping Lemma. □

### 3.3 Backward Direction

**Theorem 3.2** (Zero Monodromy ⟹ Coboundary). If M(ω) = 0, then ω is a coboundary.

*Proof.* Define the partial sum height function:

    h(k) = Σᵢ₌₀ᵏ⁻¹ ω(i)   (with h(0) = 0)

For 0 ≤ k < n−1:
    h((k+1) mod n) − h(k) = h(k+1) − h(k) = ω(k) ✓

For k = n−1:
    h(0) − h(n−1) = 0 − Σᵢ₌₀ⁿ⁻² ω(i) = ω(n−1)

where the last step uses M(ω) = 0, i.e., ω(n−1) = −Σᵢ₌₀ⁿ⁻² ω(i). □

### 3.4 The Classification Theorem

**Theorem 3.3** (Monodromy Classification). A cocycle ω on Cₙ is a coboundary if and only if M(ω) = 0.

*Proof.* Combine Theorems 3.1 and 3.2. □

**Corollary 3.4.** The first cohomology H¹(Cₙ; ℝ) ≅ ℝ, with the isomorphism given by the monodromy map M : C¹(Cₙ; ℝ) → ℝ.

**Corollary 3.5.** Two cocycles ω₁, ω₂ are cohomologous if and only if M(ω₁) = M(ω₂).

---

## 4. Orientation Cocycle Theory

### 4.1 The ±1 Monodromy Theorem

**Theorem 4.1.** For any orientation cocycle σ on Cₙ, the orientation monodromy M_or(σ) ∈ {+1, −1}.

*Proof.* Each factor σ(i) ∈ {+1, −1} has |σ(i)| = 1. Therefore |M_or(σ)| = Πᵢ |σ(i)| = 1, so M_or(σ) ∈ {+1, −1}. □

### 4.2 The Odd-Parity Criterion

**Theorem 4.2** (Odd-Parity Criterion). An orientation cocycle σ is non-orientable if and only if the number of edges with σ(i) = −1 is odd.

*Proof.* Let k = |{i : σ(i) = −1}|. Each σ(i) equals (−1)^[σ(i)=−1], so:

    M_or(σ) = Πᵢ σ(i) = (−1)^k

This is −1 if and only if k is odd. □

**Remark.** This theorem provides the connection between impossible figures and non-orientable surfaces. The Möbius strip corresponds to a cycle with an odd number of orientation reversals — precisely the condition for non-orientability.

---

## 5. The Hodge Decomposition

### 5.1 Decomposition Theorem

**Theorem 5.1** (Hodge Decomposition for Cycle Graphs). Every cocycle ω on Cₙ has a unique decomposition:

    ω = δf + ω_h

where δf is a coboundary and ω_h is harmonic (constant on all edges):

    ω_h(i) = M(ω) / n   for all i

*Proof.* Define ω_h(i) = M(ω)/n. Then M(ω_h) = n · M(ω)/n = M(ω), so M(ω − ω_h) = 0. By the classification theorem, ω − ω_h = δf for some f. Uniqueness follows from the fact that a coboundary that is also harmonic (constant) must have zero monodromy, hence must equal the zero function (since the constant must be M/n = 0/n = 0). □

### 5.2 Interpretation

The harmonic part ω_h represents the "pure impossibility" — the irreducible component that cannot be gauged away. The coboundary part δf represents height variations that are consistent and could be built. The impossibility index equals n · |ω_h(i)| for any i.

---

## 6. Stability and Rigidity

### 6.1 Perturbation Stability

**Theorem 6.1.** If M(ω) ≠ 0 and |M(ε)| < |M(ω)|, then M(ω + ε) ≠ 0.

*Proof.* By linearity, M(ω + ε) = M(ω) + M(ε). If this were zero, then M(ε) = −M(ω), so |M(ε)| = |M(ω)|, contradicting the hypothesis. □

**Interpretation.** Impossibility is an open condition in the space of cocycles. The stability radius equals |M(ω)| — the impossibility index itself.

### 6.2 Rational Rigidity

**Theorem 6.2.** If all edge weights ω(i) are rational, then M(ω) is rational.

*Proof.* The monodromy is a finite sum of rational numbers, hence rational. □

**Corollary.** The impossibility index of a rational figure is rational.

---

## 7. Algorithms

### 7.1 Impossibility Detection

**Input:** Edge weights ω(0), ..., ω(n−1)  
**Output:** Whether the figure is impossible

1. Compute M = Σᵢ ω(i)
2. Return M ≠ 0

**Complexity:** O(n) time, O(1) space.

### 7.2 Height Reconstruction

**Input:** Edge weights ω(0), ..., ω(n−1) with M(ω) = 0  
**Output:** Height function h(0), ..., h(n−1)

1. Set h(0) = 0
2. For k = 1, ..., n−1: set h(k) = h(k−1) + ω(k−1)

**Complexity:** O(n) time, O(n) space.

### 7.3 Hodge Decomposition

**Input:** Edge weights ω(0), ..., ω(n−1)  
**Output:** Coboundary part δf and harmonic part ω_h

1. Compute M = Σᵢ ω(i)
2. Set ω_h(i) = M/n for all i
3. Set (δf)(i) = ω(i) − M/n for all i

**Complexity:** O(n) time, O(n) space.

---

## 8. Applications

### 8.1 Computer Vision

In scene understanding, a vision system may extract local depth cues from shading, texture, or stereo that assign relative heights to adjacent regions. The monodromy detects inconsistencies: a nonzero monodromy indicates that the depth cues are globally contradictory (perhaps due to a reflection, occlusion, or actual impossible object in the scene). The impossibility index quantifies the severity of the inconsistency.

### 8.2 Computer Graphics

When rendering 3D scenes from 2D specifications, the height reconstruction algorithm provides an optimal consistent depth assignment when one exists. The Hodge decomposition can be used to "fix" inconsistent specifications by removing the harmonic (impossible) component, yielding the closest realizable figure.

### 8.3 Cognitive Science

The monodromy provides a quantitative measure of the "strength" of an impossible figure as a visual stimulus. Figures with higher impossibility index are predicted to produce stronger cognitive conflict. This prediction is testable through response-time experiments.

---

## 9. Discussion

### 9.1 Connection to de Rham Theory

The Monodromy Classification Theorem is the discrete analogue of the following result from de Rham theory: a closed 1-form on the circle S¹ is exact if and only if its integral over S¹ vanishes. The cycle graph Cₙ serves as a combinatorial model of S¹, edge weights correspond to 1-forms, height functions to 0-forms, the discrete differential to the exterior derivative, and the monodromy to the period integral.

### 9.2 Limitations and Extensions

The current framework is limited to cycle graphs. For general graphs, the first cohomology has dimension β₁ (the first Betti number), and realizability requires all monodromies around independent cycles to vanish. For simplicial complexes, higher-dimensional cocycles capture higher-order impossibilities.

### 9.3 The Cohomological Viewpoint

The monodromy classification can be stated in the language of sheaf cohomology: a height cocycle defines a ℝ-valued presheaf on the cycle graph, and the obstruction to its being a sheaf (having global sections) is classified by H¹. This perspective opens the door to generalizations involving non-abelian coefficient groups, twisted coefficients, and higher-categorical structures.

---

## 10. Future Work

1. **Higher cocycles on simplicial complexes**: Extend the theory to 2-cocycles on triangulated surfaces, classifying "surface impossibilities."
2. **Non-abelian monodromy**: Replace ℝ with non-abelian groups (e.g., SO(3)) to model impossible figures with rotational, not just translational, inconsistencies.
3. **Spectral theory**: Develop a spectral decomposition of the coboundary operator on general graphs, relating the eigenvalues to the graph's topological properties.
4. **Quantum impossibility**: Investigate connections between cocycle obstructions and contextuality in quantum mechanics (both are cohomological phenomena).

---

## References

1. Penrose, L.S. and Penrose, R. (1958). "Impossible objects: a special type of visual illusion." *British Journal of Psychology*, 49(1), 31–33.
2. Sugihara, K. (1986). *Machine Interpretation of Line Drawings*. MIT Press.
3. Huffman, D.A. (1971). "Impossible Objects as Nonsense Sentences." *Machine Intelligence*, 6, 295–323.
4. Clowes, M.B. (1971). "On seeing things." *Artificial Intelligence*, 2(1), 79–116.
5. Bott, R. and Tu, L.W. (1982). *Differential Forms in Algebraic Topology*. Springer.

---

## Appendix: Formal Verification

All definitions and theorems in Sections 2–6 have been formally verified in Lean 4 using the Mathlib library (v4.28.0). The formalization includes:

- 7 novel definitions (CycleCocycle, monodromy, IsCoboundary, ImpossibleFigure, OrientationCocycle, etc.)
- 14 formally verified theorems with complete proofs and no axioms beyond the standard Lean foundations
- Constructive height reconstruction via partial sums
- The Penrose triangle as a concrete impossible figure instance

The complete Lean source is available in `Algebra/ImpossibleFigures/`.
