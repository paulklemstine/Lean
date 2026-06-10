# Closure Barron Duality: Atomic Decomposition for Monotone Functionals on Finite Distributive Lattices

## Abstract

We prove a finite duality theorem showing that monotone sup-preserving functionals on finite distributive lattices admit a unique atomic decomposition over join-irreducible elements. Specifically, for any monotone functional f : L → ℝ≥0∞ satisfying f(a ⊔ b) = max(f(a), f(b)) and f(⊥) = 0, we establish:

1. **Representation**: f(K) = sup{f(j) | j join-irreducible, j ≤ K} for all K ∈ L.
2. **Determination**: f is uniquely determined by its values on join-irreducible elements.
3. **Reconstruction**: The canonical weight assignment w(j) = f(j) for join-irreducible j, together with the sup-combination operator, exactly recovers f.
4. **Sparsity**: Any atomic decomposition has support bounded by the number of join-irreducibles.

All results are formally verified in Lean 4 with the Mathlib library, using zero axioms beyond the standard foundations (propext, Classical.choice, Quot.sound). The theorem establishes a bridge between lattice theory, idempotent mathematics, and interpretable machine learning.

## 1. Introduction

### 1.1 Motivation

The classical Barron approximation theorem (Barron, 1993) shows that functions with finite "variation" (first absolute moment of the Fourier transform) can be efficiently represented as linear combinations of sigmoidal atoms. This result is foundational for neural network approximation theory: it explains why single-hidden-layer networks can approximate complex functions, and provides explicit bounds on the number of hidden units needed.

We develop an analogous theory for monotone functionals on finite distributive lattices. The atoms are not sigmoidal functions but *join-irreducible elements*—the irreducible building blocks of the lattice. The linear combination is replaced by a *sup-combination* (max-aggregation), reflecting the idempotent nature of lattice operations. The variation norm becomes the *closure variation*, measuring the total weight of an atomic decomposition.

### 1.2 Related Work

**Birkhoff representation theorem.** Birkhoff (1937) proved that finite distributive lattices are isomorphic to lattices of lower sets of finite posets, with elements decomposing as joins of join-irreducibles. Our representation theorem extends this structural result to functionals.

**Tropical mathematics.** The sup-combination operation is the additive operation in tropical (max-plus) algebra. Our framework can be viewed as a "tropical representation theory" for monotone functionals, connecting to work on tropical linear algebra, tropical convexity, and idempotent analysis (Litvinov et al., 2001; Akian et al., 2012).

**Formal concept analysis.** Closure systems and their lattice-theoretic properties are central to formal concept analysis (Ganter & Wille, 1999). Our theorem implies that monotone measures on concept lattices are determined by their values on join-irreducible concepts.

**Barron spaces.** Recent work (E et al., 2019; Parhi & Nowak, 2021) has extended Barron's original results to deeper networks and more general function spaces. Our work is complementary: we trade the continuous, Euclidean setting for a discrete, lattice-theoretic one, gaining exact (non-approximate) representation and unique decomposition.

### 1.3 Contributions

1. A formally verified Birkhoff decomposition theorem for finite distributive lattices.
2. A representation theorem for monotone sup-preserving functionals as sup-combinations of join-irreducible atoms.
3. A uniqueness/determination theorem showing the canonical weights are the unique parameters.
4. A reconstruction theorem establishing round-trip correspondence between functionals and weight functions.
5. A bundled duality theorem packaging the above as a forward-inverse pair.
6. Sparsity bounds on atomic decompositions.

## 2. Preliminaries and Definitions

### 2.1 Finite Distributive Lattices

A **finite distributive lattice** is a finite partially ordered set (L, ≤) with binary joins ⊔, binary meets ⊓, and a bottom element ⊥, satisfying the distributive law: a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c) for all a, b, c ∈ L.

An element j ∈ L is **join-irreducible** (SupIrred in Mathlib) if j is not minimal (j ≠ ⊥) and whenever j = a ⊔ b, either j = a or j = b. We write JI(L) for the set of join-irreducible elements.

In a distributive lattice, join-irreducible elements are **join-prime** (SupPrime): if j ≤ a ⊔ b, then j ≤ a or j ≤ b. This is the key property that makes the representation theorem work.

### 2.2 Monotone Sup-Preserving Functionals

A functional f : L → ℝ≥0∞ is:
- **Monotone**: a ≤ b implies f(a) ≤ f(b).
- **Sup-preserving**: f(a ⊔ b) = f(a) ⊔ f(b) = max(f(a), f(b)).
- **Normalized**: f(⊥) = 0.

The sup-preserving condition is the lattice analogue of "max-plus linearity" in tropical mathematics. It says that combining two concepts yields the maximum importance, not the sum.

### 2.3 Formal Definitions

```
def supIrredFinset (L) := Finset.univ.filter (fun a => SupIrred a)
def supIrredBelow (a : L) := Finset.univ.filter (fun j => SupIrred j ∧ j ≤ a)
def IsSupPreserving (f : L → ENNReal) := ∀ a b, f (a ⊔ b) = f a ⊔ f b
def canonicalWeights (f : L → ENNReal) := fun j => if SupIrred j then f j else 0
def reconstruct (w : L → ENNReal) := fun K => ⨆ j ∈ supIrredFinset L, if j ≤ K then w j else 0
```

## 3. Main Results

### 3.1 Birkhoff Decomposition (Theorem 1)

**Theorem** (birkhoff_sup_irred). *For every element a of a finite distributive lattice L:*
$$a = \bigsup\{j \in JI(L) \mid j \leq a\}$$

**Proof sketch.** By well-founded induction on the lattice order. The upper bound is immediate: every join-irreducible below a is ≤ a, so their sup is ≤ a. For the lower bound: if a = ⊥, the sup of the empty set is ⊥. If a is join-irreducible, then a belongs to supIrredBelow(a) and equals its own sup. If a is not join-irreducible and a ≠ ⊥, then a = b ⊔ c for some b, c < a, and by induction, both b and c are sups of join-irreducibles below themselves, which are also below a. □

### 3.2 Finite Sup Distribution (Theorem 2)

**Theorem** (sup_preserving_finset_sup). *If f is monotone, sup-preserving, and normalized, then for any finite set S:*
$$f\left(\bigsup_{s \in S} s\right) = \bigsup_{s \in S} f(s)$$

**Proof.** By induction on |S|. The base case uses f(⊥) = 0. The inductive step uses the binary sup-preserving property. □

### 3.3 Main Representation Theorem (Theorem 3)

**Theorem** (sup_hom_eq_iSup_atoms). *For f : L → ℝ≥0∞ monotone, sup-preserving, and normalized:*
$$f(K) = \bigsup\{f(j) \mid j \in JI(L),\; j \leq K\}$$

**Proof.** By Theorem 1, K = sup(supIrredBelow K). By Theorem 2, f(K) = sup{f(j) | j ∈ supIrredBelow K}. The result follows by converting the Finset.sup to an indexed supremum. □

### 3.4 Determination by Join-Irreducibles (Theorem 4)

**Theorem** (sup_hom_determined_by_sup_irred). *If f, g : L → ℝ≥0∞ are both monotone, sup-preserving, normalized, and f(j) = g(j) for all join-irreducible j, then f = g.*

**Proof.** By Theorem 3, both f(K) and g(K) equal a supremum over the same set {j ∈ JI(L) | j ≤ K}. Since f and g agree on join-irreducibles, the suprema are equal. □

### 3.5 Reconstruction Theorem (Theorem 5)

**Theorem** (reconstruct_canonical). *For f monotone, sup-preserving, and normalized:*
$$\text{reconstruct}(\text{canonicalWeights}(f)) = f$$

**Proof.** The canonical weights set w(j) = f(j) for join-irreducible j and 0 otherwise. The reconstruction computes ⨆ j ∈ JI(L), if j ≤ K then w(j) else 0 = ⨆ {f(j) | j ∈ JI(L), j ≤ K} = f(K) by Theorem 3. □

### 3.6 Properties of Reconstruction

**Theorem.** For any weight function w : L → ℝ≥0∞:
- reconstruct(w) is monotone.
- reconstruct(w) is sup-preserving (uses that SupIrred ⟹ SupPrime in distributive lattices).
- reconstruct(w)(⊥) = 0.

These three properties mean that reconstruct is a well-defined map from weight functions to SupHomFunctionals.

### 3.7 Bundled Duality (Theorem 6)

**Theorem** (closure_barron_duality_forward). *The composition fromWeights ∘ toWeights is the identity on SupHomFunctionals:*
$$\text{SupHomFunctional.fromWeights}(\text{SupHomFunctional.toWeights}(f)) = f$$

This establishes the forward direction of the duality: every SupHomFunctional is recovered from its canonical weights.

### 3.8 Sparsity

**Theorem** (sparse_support_bound). *Any sparse atomic representation has support size ≤ |JI(L)|.*

**Theorem** (sup_hom_sparse_rep). *Every monotone sup-preserving normalized functional admits a sparse atomic representation with support ⊆ JI(L).*

## 4. Algorithms

### 4.1 Weight Extraction

**Input:** A monotone sup-preserving functional f on a finite distributive lattice L.
**Output:** Canonical weights w : JI(L) → ℝ≥0∞.

```
function ExtractWeights(f, L):
    JI ← {j ∈ L | SupIrred(j)}
    for j in JI:
        w[j] ← f(j)
    return w
```

**Complexity:** O(|L|) time to identify join-irreducibles + O(|JI(L)|) evaluations of f.

### 4.2 Reconstruction

**Input:** Weights w : JI(L) → ℝ≥0∞ and a query element K ∈ L.
**Output:** f(K).

```
function Reconstruct(w, K, L):
    result ← 0
    for j in JI(L):
        if j ≤ K:
            result ← max(result, w[j])
    return result
```

**Complexity:** O(|JI(L)|) comparisons per query.

### 4.3 Certified Recovery

**Input:** Oracle access to f on a subset S ⊆ L with JI(L) ⊆ S.
**Output:** Complete functional f, with certificate of correctness.

```
function CertifiedRecovery(oracle, L):
    JI ← {j ∈ L | SupIrred(j)}
    w ← ExtractWeights(oracle|_JI, L)
    f_hat ← Reconstruct(w, ·, L)
    // Certificate: f_hat = f by sup_hom_determined_by_sup_irred
    return f_hat, Certificate(JI, w)
```

**Complexity:** |JI(L)| oracle queries + O(|JI(L)| · |L|) for full reconstruction.

## 5. Applications

### 5.1 Interpretable Concept Networks

Consider a concept lattice arising from a database of objects and attributes. The join-irreducible concepts are the "atomic" concepts that cannot be decomposed into simpler ones. Any monotone sup-preserving measure of concept importance is determined by its values on these atoms.

**Example.** In a medical diagnosis system with 8 attributes (symptoms), the power-set lattice has 256 elements but typically far fewer join-irreducibles (at most 8). A monotone importance measure on diagnoses is determined by at most 8 weights.

### 5.2 Feature Selection in Boolean Functions

For Boolean functions on {0,1}^n, the lattice of closed sets under the standard closure operator has join-irreducibles corresponding to "essential variables." The Barron duality implies that any monotone aggregate measure over variable subsets is determined by the essential-variable weights.

### 5.3 Dependency Structures in Knowledge Graphs

Knowledge graphs can be modeled as closure systems where the closed sets are deductively closed knowledge states. Join-irreducible states correspond to "minimal non-trivial knowledge units." The duality theorem implies that any monotone utility function over knowledge states is determined by the utilities of these atomic knowledge units.

## 6. Computational Experiments

We implemented the algorithms in Python and tested them on several lattice families:

1. **Power-set lattices** P({1,...,n}) for n = 3,4,5: join-irreducibles are singletons, |JI| = n.
2. **Divisor lattices** D(n) for n = 12, 30, 60: join-irreducibles are prime-power divisors.
3. **Partition lattices** Π(n) for n = 3,4: join-irreducibles are "atomic" partitions.

In all cases, the reconstruction was exact (error = 0 in exact arithmetic) and the number of required evaluations equaled |JI(L)|.

## 7. Discussion

### 7.1 Limitations

The current theory requires:
- **Finiteness**: The lattice must be finite. Extension to complete lattices requires topological continuity conditions.
- **Distributivity**: The lattice must satisfy the distributive law. The key step (SupIrred ⟹ SupPrime) fails in non-distributive lattices.
- **Sup-preservation**: The functional must satisfy f(a ⊔ b) = max(f(a), f(b)). General monotone functionals do not admit exact atomic decompositions.

### 7.2 Strengths

- **Exact, not approximate**: Unlike classical Barron theory, the decomposition is exact.
- **Unique canonical weights**: The representation is canonical, not one of many.
- **Formally verified**: All proofs are machine-checked.
- **Constructive**: The algorithms are efficient and implementable.

### 7.3 Relation to Tropical Geometry

The sup-combination operation is the additive structure of the tropical semiring (ℝ ∪ {-∞}, max, +). Our representation theorem can be viewed as a tropical spectral theorem for monotone functionals on finite distributive lattices, with join-irreducibles playing the role of eigenvalues.

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions including:
1. Extension to semidistributive lattices via canonical join representations.
2. Möbius inversion and Choquet capacity connections.
3. Sample complexity bounds for concept learning.
4. Categorical duality between weighted closure systems and sparse networks.
5. Thermodynamic invariants of closure geometries.

## References

- Barron, A. R. (1993). Universal approximation bounds for superpositions of a sigmoidal function. IEEE Trans. Information Theory, 39(3), 930-945.
- Birkhoff, G. (1937). Rings of sets. Duke Mathematical Journal, 3(3), 443-454.
- Ganter, B., & Wille, R. (1999). Formal Concept Analysis: Mathematical Foundations. Springer.
- Litvinov, G. L., Maslov, V. P., & Shpiz, G. B. (2001). Idempotent functional analysis: An algebraic approach. Mathematical Notes, 69(5), 696-729.
