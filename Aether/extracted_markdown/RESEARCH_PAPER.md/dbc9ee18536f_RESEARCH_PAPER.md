# Proof-Theoretic Ordinal Analysis as a Rigorous Depth Metric for Mathematical Research

## Abstract

We formalize proof-theoretic ordinal analysis as a depth metric for mathematical proofs and research outputs. Working in Lean 4 with Mathlib, we define abstract proof trees with axiom, modus ponens, cut, and induction rules, and assign ordinal-valued ranks measuring proof-theoretic complexity. We prove a strict depth hierarchy theorem: for every natural number d, the class of proofs of depth at most d is properly contained in the class of proofs of depth at most d+1. We establish an exponential efficiency gap between wide (branching) and deep (sequential) proof strategies, prove a tight size-cutcount bound (disproving a stronger conjectured bound), and define a research depth metric satisfying monotonicity under composition. All main theorems are machine-verified with no sorries.

**Keywords:** proof-theoretic ordinals, proof complexity, depth hierarchy, cut elimination, ordinal notation, formal verification

---

## 1. Introduction

Proof-theoretic ordinal analysis, originating with Gentzen's 1936 consistency proof for Peano arithmetic [1], assigns ordinal numbers to formal theories, measuring the "proof-theoretic strength" required to establish their consistency. The proof-theoretic ordinal of a theory T is the supremum of order types of primitive recursive well-orderings provably well-founded in T.

This paper develops ordinal analysis in a new direction: as a *depth metric* for individual proofs and research outputs. Rather than measuring the strength of entire theories, we assign ordinal-valued depth to specific proof trees and establish structural theorems about the resulting hierarchy.

### 1.1 Contributions

1. **Strict Depth Hierarchy** (Theorem 3.1): For each d ∈ ℕ, BoundedDepthClass(d) ⊊ BoundedDepthClass(d+1). The hierarchy never collapses.

2. **Exponential Efficiency Gap** (Theorem 4.1): Complete binary trees of depth n have size 2^{n+1} - 1, while omega towers have size n+1. The ratio grows as 2^n/n.

3. **Induction Amplification** (Theorem 5.1): k applications of the induction rule add exactly k to proof depth. This is tight.

4. **Cut-Count Bound** (Theorem 7.1): For all proof trees, treeSize ≥ 2 · cutCount + 1. This is tight (achieved by nested cuts). A stronger bound of 3 · cutCount is disproved by explicit counterexample.

5. **Research Depth Metric** (Definition 6.1): A typeclass formalizing monotone depth metrics on research outputs, with ProofTree as a canonical instance.

6. **Leaf Count Theorem** (Theorem 2.1): For any proof tree, leafCount = binaryCount + 1.

### 1.2 Related Work

Our work connects to several established lines of research:

- **Ordinal analysis** (Gentzen [1], Schütte [2], Buchholz [3]): We use ordinal notations in Cantor Normal Form, though our hierarchy theorems work at the level of natural-number depth rather than requiring the full ordinal structure.
- **Proof complexity** (Cook-Reckhow [4], Krajíček [5]): Our depth hierarchy is a proof-theoretic analogue of circuit depth hierarchies in computational complexity.
- **Formula depth** in the Catalog: Our work bridges to `Computation/ApproximationMethod.lean` (monotone KW lower bounds) and `Computation/PadicValuationDepth.lean` (valuation depth measures).

---

## 2. Proof Trees: Definitions and Basic Properties

### Definition 2.1 (ProofTree)
A *proof tree* is an element of the inductive type:
```
inductive ProofTree where
  | axiom_                              -- depth 0, size 1
  | mp (p₁ p₂ : ProofTree)             -- modus ponens
  | cut (p₁ p₂ : ProofTree)            -- cut rule
  | induction_ (p : ProofTree)          -- induction step
```

### Definition 2.2 (Structural Measures)
For a proof tree p, we define:
- **treeSize(p)**: total number of nodes
- **depth(p)**: length of longest root-to-leaf path
- **cutCount(p)**: number of cut-rule applications
- **binaryCount(p)**: number of binary (mp + cut) nodes
- **leafCount(p)**: number of axiom leaves

### Theorem 2.1 (Leaf Count)
*For any proof tree p, leafCount(p) = binaryCount(p) + 1.*

**Proof sketch.** By structural induction. Axioms: 1 = 0 + 1. Binary rules: leafCount = leafCount(p₁) + leafCount(p₂) = (binaryCount(p₁) + 1) + (binaryCount(p₂) + 1) = binaryCount + 1 + 1, and binaryCount = 1 + binaryCount(p₁) + binaryCount(p₂), so leafCount = binaryCount + 1. Induction: leafCount = leafCount(p) = binaryCount(p) + 1 = binaryCount + 1 since binaryCount(induction_ p) = binaryCount(p). ∎

### Theorem 2.2 (Depth-Size Bound)
*For any proof tree p, depth(p) < treeSize(p).*

Equivalently, treeSize(p) ≥ depth(p) + 1. Proved by structural induction.

### Theorem 2.3 (Cut-Free Characterization)
*A proof tree p is cut-free if and only if cutCount(p) = 0.*

---

## 3. The Strict Depth Hierarchy

### Definition 3.1
- **DepthStratum(d)** = { p : ProofTree | depth(p) = d }
- **BoundedDepthClass(d)** = { p : ProofTree | depth(p) ≤ d }

### Lemma 3.1 (Monotonicity)
*If d₁ ≤ d₂ then BoundedDepthClass(d₁) ⊆ BoundedDepthClass(d₂).*

### Theorem 3.1 (Strict Hierarchy)
*For every d ∈ ℕ, BoundedDepthClass(d) ⊊ BoundedDepthClass(d+1).*

**Proof.** Inclusion follows from Lemma 3.1. For strict containment, we construct witnesses by induction on d:
- Base case (d = 0): The proof tree mp(axiom_, axiom_) has depth 1, hence is in DepthStratum(1) but not DepthStratum(0).
- Inductive step: Given p ∈ DepthStratum(d+1) \ DepthStratum(d), the tree induction_(p) has depth d+2, hence is in DepthStratum(d+2) \ DepthStratum(d+1). ∎

### Corollary 3.1
*The sequence BoundedDepthClass(0) ⊊ BoundedDepthClass(1) ⊊ BoundedDepthClass(2) ⊊ ⋯ is strictly increasing.*

---

## 4. Canonical Proof Families

### Definition 4.1 (Omega Tower)
```
omegaTower(0) = axiom_
omegaTower(n+1) = induction_(omegaTower(n))
```

### Theorem 4.1 (Omega Tower Properties)
1. depth(omegaTower(n)) = n
2. treeSize(omegaTower(n)) = n + 1
3. omegaTower(n) is cut-free for all n

### Definition 4.2 (Complete Binary Tree)
```
completeBinaryTree(0) = axiom_
completeBinaryTree(n+1) = mp(completeBinaryTree(n), completeBinaryTree(n))
```

### Theorem 4.2 (Complete Binary Tree Properties)
1. depth(completeBinaryTree(n)) = n
2. treeSize(completeBinaryTree(n)) = 2^{n+1} - 1

### Theorem 4.3 (Exponential vs Linear Gap)
*For n ≥ 1, treeSize(completeBinaryTree(n)) > treeSize(omegaTower(n)).*

The ratio grows as (2^{n+1} - 1) / (n + 1), which is Θ(2^n / n).

### Theorem 4.4 (Size Optimality of Omega Tower)
*For any proof tree p with depth(p) = n, treeSize(p) ≥ treeSize(omegaTower(n)) = n + 1.*

This shows the omega tower achieves the minimum possible size for its depth.

---

## 5. Induction Amplification

### Definition 5.1 (Iterated Induction)
```
iterInduction(0, p) = p
iterInduction(k+1, p) = induction_(iterInduction(k, p))
```

### Theorem 5.1 (Induction Amplification)
*For any proof tree p and natural number k, depth(iterInduction(k, p)) = k + depth(p).*

**Proof.** By induction on k. The base case is trivial. For the inductive step:
depth(iterInduction(k+1, p)) = depth(induction_(iterInduction(k, p))) = 1 + depth(iterInduction(k, p)) = 1 + k + depth(p) = (k+1) + depth(p). ∎

### Theorem 5.2 (Iterated Induction Preserves Cut-Freeness)
*If p is cut-free, then iterInduction(k, p) is cut-free for all k.*

---

## 6. Research Depth Metric

### Definition 6.1 (ResearchDepthMetric)
A *research depth metric* on a type α consists of:
- rdepth : α → ℕ (depth function)
- compose : α → α → α (composition operation)
- compose_depth_mono : ∀ a b, rdepth(compose(a, b)) ≥ max(rdepth(a), rdepth(b))

### Theorem 6.1 (ProofTree Instance)
*ProofTree with depth and modus ponens forms a ResearchDepthMetric.*

**Proof.** depth(mp(a, b)) = 1 + max(depth(a), depth(b)) ≥ max(depth(a), depth(b)). ∎

### Theorem 6.2 (Composition Bounds)
*For any research depth metric and elements a, b:*
1. rdepth(compose(a, b)) ≥ rdepth(a)
2. rdepth(compose(a, b)) ≥ rdepth(b)

These follow immediately from the monotonicity axiom.

---

## 7. Cut-Count Analysis

### Definition 7.1 (Nested Cuts)
```
nestedCuts(0) = axiom_
nestedCuts(n+1) = cut(nestedCuts(n), axiom_)
```

### Theorem 7.1 (Cut-Count Bound)
*For any proof tree p, treeSize(p) ≥ 2 · cutCount(p) + 1.*

**Proof.** By structural induction on p:
- axiom_: 1 ≥ 2 · 0 + 1 = 1. ✓
- mp(p₁, p₂): treeSize = 1 + treeSize(p₁) + treeSize(p₂) ≥ 1 + (2·cutCount(p₁) + 1) + (2·cutCount(p₂) + 1) = 3 + 2·cutCount ≥ 2·cutCount + 1. ✓
- cut(p₁, p₂): treeSize = 1 + treeSize(p₁) + treeSize(p₂) ≥ 1 + (2·cutCount(p₁) + 1) + (2·cutCount(p₂) + 1) = 3 + 2·(cutCount(p₁) + cutCount(p₂)) = 2·(1 + cutCount(p₁) + cutCount(p₂)) + 1 = 2·cutCount + 1. ✓
- induction_(p): treeSize = 1 + treeSize(p) ≥ 1 + 2·cutCount(p) + 1 = 2 + 2·cutCount ≥ 2·cutCount + 1. ✓ ∎

### Theorem 7.2 (Tightness)
*nestedCuts(n) achieves equality: treeSize(nestedCuts(n)) = 2n + 1 = 2 · cutCount(nestedCuts(n)) + 1.*

### Theorem 7.3 (Disproof of Stronger Bound)
*The statement "treeSize(p) ≥ 3 · cutCount(p) for all p with cutCount(p) ≥ 1" is FALSE.*

**Counterexample.** p = cut(cut(axiom_, axiom_), axiom_) has treeSize = 5 and cutCount = 2, but 5 < 6 = 3 · 2. ∎

---

## 8. Algorithms

### 8.1 Depth Computation
Computing depth(p) takes O(|p|) time via a single tree traversal. The algorithm is:
```python
def depth(p):
    if p is axiom_: return 0
    if p is induction_(q): return 1 + depth(q)
    return 1 + max(depth(p.left), depth(p.right))
```

### 8.2 Ordinal Rank Computation
Computing the ordinal rank uses the same traversal but produces CNF ordinal notations:
- axiom_ → 0
- mp(p₁, p₂) → ω^0 · (max(depth(p₁), depth(p₂)) + 1)
- cut(p₁, p₂) → ω^(ω^0 · (max(depth(p₁), depth(p₂)) + 1))
- induction_(p) → ω^(rank(p))

### 8.3 Hierarchy Verification
The strict hierarchy can be verified computationally by constructing omega tower witnesses at each level and checking their depth and non-membership in lower strata.

---

## 9. Discussion

### 9.1 Connection to Circuit Complexity
The strict depth hierarchy for proof trees mirrors the depth hierarchy in Boolean circuit complexity. Just as NC^k ⊊ NC^{k+1} (under standard assumptions), our BoundedDepthClass(k) ⊊ BoundedDepthClass(k+1) is unconditional. The proof-theoretic setting avoids the conditional nature of circuit complexity separations because proof tree depth is a purely structural measure.

### 9.2 Connection to Valuation Depth
The ValuationDepthMeasure typeclass in `Computation/PadicValuationDepth.lean` provides a complementary view: it measures the number of valuation queries needed to compute a function, using the ultrametric inequality. Our ResearchDepthMetric generalizes this to arbitrary composition operations with a monotonicity guarantee.

### 9.3 Limitations
Our depth metric captures structural complexity but not semantic complexity. Two proof trees of the same depth may prove statements of vastly different mathematical significance. A more refined metric would incorporate both structural depth and semantic content, potentially using ordinal notations to capture transfinite levels of mathematical insight.

---

## 10. Future Work

1. **Ordinal-valued depth beyond ω**: Extend the hierarchy to transfinite ordinals using well-founded CNF notations, establishing that the hierarchy continues past any finite level.

2. **Cut elimination complexity**: Formalize the exponential blowup of cut elimination and connect it to the ordinal decrease in proof-theoretic rank.

3. **Semantic depth metrics**: Combine structural depth with semantic measures (e.g., the complexity of the statement being proved) for a more nuanced research depth metric.

4. **Automated depth analysis**: Build tools that automatically compute the proof-theoretic depth of formalized proofs in Lean/Mathlib, enabling empirical studies of mathematical depth.

---

## References

[1] G. Gentzen, "Die Widerspruchsfreiheit der reinen Zahlentheorie," *Mathematische Annalen*, vol. 112, pp. 493–565, 1936.

[2] K. Schütte, *Proof Theory*, Springer-Verlag, 1977.

[3] W. Buchholz, "A new system of fundamental sequences," *Annals of Pure and Applied Logic*, vol. 32, pp. 195–207, 1986.

[4] S. A. Cook and R. A. Reckhow, "The relative efficiency of propositional proof systems," *Journal of Symbolic Logic*, vol. 44, no. 1, pp. 36–50, 1979.

[5] J. Krajíček, *Proof Complexity*, Cambridge University Press, 2019.

[6] Catalog: `Computation/PadicValuationDepth.lean` — ValuationDepthMeasure typeclass.

[7] Catalog: `Computation/ApproximationMethod.lean` — monotone KW lower bounds and formula depth.

---

## Appendix: Formal Verification Summary

All theorems are machine-verified in Lean 4 (v4.28.0) with Mathlib. The formalization contains:

| Result | Status | Proof Method |
|--------|--------|-------------|
| Leaf Count Theorem | ✓ Proved | Structural induction |
| Cut-Free Characterization | ✓ Proved | Structural induction |
| Depth-Size Bound | ✓ Proved | Structural induction |
| Strict Hierarchy | ✓ Proved | Induction + witnesses |
| Bounded Class Strict Containment | ✓ Proved | Hierarchy + subset |
| Omega Tower Properties (4 thms) | ✓ Proved | Induction |
| Binary Tree Properties (2 thms) | ✓ Proved | Induction + arithmetic |
| Exponential Gap | ✓ Proved | Arithmetic bound |
| Induction Amplification | ✓ Proved | Induction |
| Cut-Count Bound | ✓ Proved | Structural induction |
| Stronger Bound Disproof | ✓ Disproved | Explicit counterexample |
| Research Depth Monotonicity | ✓ Proved | Arithmetic |
| Omega Tower Size-Optimality | ✓ Proved | Depth-size bound |

Total: 0 sorries in the final formalization.
