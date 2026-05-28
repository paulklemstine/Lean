# Non-Abelian Product Covering via Ruzsa Calculus

## Abstract

We develop a covering theory for product sets in finite groups, establishing non-abelian generalizations of the abelian product-cover transfer theorem. We prove that for a K-approximate subgroup H, the triple product H³ can be covered by K² left translates of H, and the right-multiplied set A·H by C·K translates when A is covered by C translates. For commutative groups, we prove A·A is covered by C²·K translates of H. We demonstrate by explicit counterexample in S₃ that the bound C²·K³ proposed for general non-abelian groups fails: the obstruction is non-normality of H under conjugation by elements of the covering set. This identifies precisely the boundary between abelian and non-abelian covering theory. All results except the cover number monotonicity lemma are machine-verified.

## 1. Introduction

Product set covering is a fundamental operation in additive combinatorics. Given a finite subset A of a group G covered by C left translates of an approximate subgroup H, one seeks bounds on how many translates of H are needed to cover the product set A·A. In commutative groups, the classical bound is C²·K where K is the doubling constant of H.

The extension to non-commutative groups is motivated by applications in geometric group theory, model theory, and the theory of approximate groups. The seminal work of Breuillard-Green-Tao on the structure of approximate groups relies on non-abelian covering arguments that are substantially more delicate than their abelian counterparts.

### 1.1 Contributions

1. **New definitions**: CoveredByLeftTranslates, IsFiniteKApproxSubgroup, LeftCosetCoverNumber
2. **Triple product cover** (Theorem 1): H³ covered by K² translates of H
3. **Right multiplication cover** (Theorem 2): A·H covered by C·K translates
4. **Commutative product cover** (Theorem 3): A·A covered by C²·K translates (CommGroup)
5. **Counterexample**: The bound C²·K³ fails in S₃ for non-normal subgroups
6. **Word metric control** (Theorem 4): Covering implies bounded word distance (CommGroup)
7. **Computational validation**: Exhaustive testing on S₃, S₄, GL(2,F₂), GL(2,F₃)

## 2. Definitions and Notation

**Definition 2.1** (Left-translate covering). A finite set A ⊆ G is *covered by C left translates of H* if there exists a finite set T ⊆ G with |T| ≤ C such that for every a ∈ A, there exist t ∈ T and h ∈ H with a = t·h.

**Definition 2.2** (K-approximate subgroup). A finite set H ⊆ G is a *K-approximate subgroup* if:
- 1 ∈ H (identity)
- h ∈ H implies h⁻¹ ∈ H (symmetry)
- H·H is covered by K left translates of H (bounded doubling)

**Definition 2.3** (Cover number). LeftCosetCoverNumber(H, A) = inf{n : A is covered by n left translates of H}.

## 3. Main Results

### Theorem 1: Triple Product Cover

**Statement**: If H is a K-approximate subgroup, then H·H·H is covered by K² left translates of H.

**Proof sketch**: Since H² ⊆ X·H with |X| ≤ K, we compute:
```
H³ = H²·H ⊆ (X·H)·H = X·(H²) ⊆ X·(X·H) = X²·H
```
The translate set X² = X×X mapped under multiplication has |X²| ≤ K².

### Theorem 2: Right Multiplication Cover

**Statement**: If A is covered by C translates of H and H is a K-approximate subgroup, then A·H is covered by C·K translates of H.

**Proof sketch**: A·H ⊆ (T·H)·H = T·(H²) ⊆ T·(X·H) = (T·X)·H, with |T·X| ≤ C·K.

### Theorem 3: Commutative Product Cover

**Statement**: For a commutative group G, if A is covered by C translates of H and H is a K-approximate subgroup, then A·A is covered by C²·K translates of H.

**Proof sketch**: Since G is commutative:
```
(t₁·h₁)·(t₂·h₂) = (t₁·t₂)·(h₁·h₂)
```
The translate set T×T×X (mapped under multiplication) has cardinality ≤ C²·K.

### Theorem 4: Word Metric Control (CommGroup)

**Statement**: In a commutative group with generating set S, if every element of H has word length ≤ R and A·A is covered by translates of H, then every x ∈ A·A satisfies d_S(t, x) ≤ R for some translate representative t.

### Counterexample to C²K³ in Non-Abelian Groups

In S₃: H = {e, (12)}, K = 1, A = (13)·H, C = 1.
A·A = {e, (12), (23), (123)} requires 2 cosets of H.
But C²·K³ = 1 < 2.

The failure mechanism: (t₁·h₁)·(t₂·h₂) = t₁·(h₁·t₂)·h₂, and h₁·t₂ ≠ t₂·h₁ when H is not normal.

## 4. Computational Experiments

### 4.1 Groups Tested
- S₃ (|G| = 6): All subgroups and approximate subgroups up to size 5
- S₄ (|G| = 24): Subgroups and approximate subgroups up to size 8
- GL(2, F₂) (|G| = 6): Complete analysis
- GL(2, F₃) (|G| = 48): Subgroups and selected approximate subgroups

### 4.2 Results Summary
- **Commutative bound C²·K**: Never violated in any test case
- **Non-abelian bound C²·K³**: Violated precisely for non-normal subgroups with non-identity cosets
- **Sharpness**: The bound C²·K is achieved for normal subgroups in abelian quotients

### 4.3 Conjecture Status
**Conjecture (Sharp non-abelian product cover)**: C(A·A) ≤ C² · K² for all groups.
**Status**: REFUTED. Counterexample: S₃, H = {e, (12)}, A = single coset, C = 1, K = 1, C(A·A) = 2 > 1 = C²·K².

## 5. Discussion

### 5.1 The Non-Abelian Obstruction
The obstruction to non-abelian product covering is precisely conjugation. When H is not normal in G, the conjugate g⁻¹·H·g may differ from H, and the product set expansion depends on the "conjugation index" [H : H ∩ g·H·g⁻¹].

### 5.2 Correct Non-Abelian Formulations
The correct bound for general groups should involve:
- C²·K for commutative groups (proved)
- C²·L·K for groups with conjugation index L (conjectured)
- C² for normal subgroups (K = 1 case)

### 5.3 Connections to Other Fields
- **Model theory**: The covering theorems show that definable bounded-cover information survives passage to product sets in abelian settings.
- **Geometric group theory**: Word metric control connects algebraic covering to coarse geometric containment.
- **Finite group computation**: The counterexample discovery was computational, validating the compute-first methodology.

## 6. Future Work

1. Prove the Ruzsa covering-based bound for non-abelian groups with explicit conjugation index
2. Extend to approximate subgroups in locally compact groups
3. Connect to expansion and mixing time bounds in Cayley graphs
4. Develop a model-theoretic transfer for non-abelian approximate subgroups

## References

1. Breuillard, E., Green, B., Tao, T. (2012). The structure of approximate groups. *Publications mathématiques de l'IHÉS*, 116(1), 115-221.
2. Hrushovski, E. (2012). Stable group theory and approximate subgroups. *Journal of the AMS*, 25(1), 189-243.
3. Ruzsa, I. Z. (1999). An analog of Freiman's theorem in groups. *Astérisque*, 258, 323-326.
4. Tao, T. (2008). Product set estimates for non-commutative groups. *Combinatorica*, 28(5), 547-594.
5. Petridis, G. (2012). New proofs of Plünnecke-type estimates for product sets in groups. *Combinatorica*, 32(6), 721-733.
