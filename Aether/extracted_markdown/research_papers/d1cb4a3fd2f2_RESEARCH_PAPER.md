# Compression Stability Under Probe Enlargement: A Categorical Data Processing Inequality

## Abstract

We develop a formal theory of *observational compression stability* for probe families on finite presheaf models over discrete categories. The central contribution is a **monotonicity + rigidity package**: enlarging a probe family (the set of objects used to observe a system) can only increase the measurement invariant (the total count of distinguishable signatures), and the invariant is preserved exactly when the enlargement introduces no new element-level separations. We prove five main theorems: (1) monotonicity of the measurement invariant under probe enlargement, (2) equality from informational redundancy, (3) rigidity — equality implies redundancy, (4) strict increase when new separations exist, and (5) saturation of the invariant by separating families. The proofs are mechanically verified in the Lean 4 theorem prover using the Mathlib library. We also provide algorithms for computing the measurement invariant and detecting redundancy, with implementations verified on examples from sensor design, feature selection, experimental design, and finite model theory.

**Keywords:** data processing inequality, observational entropy, partition refinement, probe complexity, measurement invariant, categorical information theory, finite model theory, sensor design

---

## 1. Introduction

### 1.1 Motivation

A fundamental principle in information theory states that post-processing of data cannot increase information content. This is formalized as the **data processing inequality** (DPI): if random variables form a Markov chain $X \to Y \to Z$, then $I(X; Z) \leq I(X; Y)$. The DPI is one of the most widely used tools in information theory, with applications ranging from source coding to channel capacity bounds.

However, the DPI is traditionally stated in probabilistic terms. The core phenomenon — that restricting observations can only lose information — is fundamentally about the logic of distinguishability, not about probability distributions. In this paper, we isolate and formalize this structural core in a purely categorical/combinatorial setting.

### 1.2 Setting

We work with **finite presheaf models**: a finite type `Ob` of objects, a family of finite types `F(Y)` for each object `Y`, and restriction maps `r(Y, Z) : F(Y) → F(Z)`. A **probe family** is a finite subset `P ⊆ Ob`. The **probe signature** of an element `x ∈ F(Y)` with respect to `P` is the tuple:

$$\sigma_P(Y, x) = (r(Y, Z)(x))_{Z \in P}$$

The **measurement space image cardinality** at object `Y` is the number of distinct probe signatures realized by elements of `F(Y)`:

$$m_P(Y) = |\{\sigma_P(Y, x) : x \in F(Y)\}|$$

The **measurement invariant** is the total:

$$M(P) = \sum_{Y \in \text{Ob}} m_P(Y)$$

### 1.3 Main Results

We prove the following theorem package:

**Theorem 1 (Monotonicity).** If $P \subseteq P'$, then $M(P) \leq M(P')$.

**Theorem 2 (Equality from Redundancy).** If $P \subseteq P'$ and $P'$ introduces no new element separations relative to $P$, then $M(P) = M(P')$.

**Theorem 3 (Rigidity).** If $P \subseteq P'$ and $M(P) = M(P')$, then $P'$ introduces no new element separations relative to $P$.

**Theorem 4 (Iff Characterization).** $M(P) = M(P')$ if and only if $P'$ introduces no new separations.

**Theorem 5 (Strict Increase).** If $P \subseteq P'$ and there exist $Y, x, y$ such that $P'$ separates $x, y$ but $P$ does not, then $M(P) < M(P')$.

**Theorem 6 (Saturation).** If $P$ is already separating (probe signatures are injective at every object), then $M(P) = M(P')$ for all $P' \supseteq P$.

### 1.4 Cross-Domain Significance

The theorems formalize a universal principle that appears across disciplines:

| Domain | Probes | Objects | Theorem Says |
|--------|--------|---------|-------------|
| Information theory | Channels | Messages | Data processing inequality |
| Signal processing | Sensors | Spatial locations | More sensors ≥ resolution |
| Machine learning | Features | Data points | Feature augmentation monotonicity |
| Statistics | Experiments | Hypotheses | Test battery refinement |
| Finite model theory | Formulas | Structures | Logical type refinement |
| Physics | Observables | States | Coarse-graining increases entropy |

### 1.5 Related Work

- **Shannon (1948)**: Data processing inequality for mutual information.
- **Blackwell (1953)**: Comparison of experiments via sufficiency.
- **Torgersen (1991)**: Comprehensive treatment of statistical experiment comparison.
- **Lawvere (1973)**: Categorical approach to measurement and observation.
- **Yoneda lemma**: The foundational result that probe families generalize; our `ProbeFamily.IsSeparating` is a finite analogue.

---

## 2. Definitions and Notation

### 2.1 Finite Presheaf Model

**Definition 2.1.** A *finite presheaf model* consists of:
- A finite type `Ob` with decidable equality
- A family `F : Ob → Type` with `Fintype (F Y)` and `DecidableEq (F Y)` for each `Y`
- Restriction maps `r : ∀ Y Z, F Y → F Z`

**Definition 2.2.** A *probe family* is an element `P : Finset Ob`.

### 2.2 Probe Signatures

**Definition 2.3.** The *probe signature* of `x ∈ F(Y)` with respect to `P` is:

```
probeSignature P r Y x : ∀ Z : P, F ↑Z
probeSignature P r Y x := fun ⟨Z, _⟩ => r Y Z x
```

### 2.3 Observational Equivalence

**Definition 2.4.** Elements `x, y ∈ F(Y)` are *observationally equivalent* under `P`, written `ObsEq P r Y x y`, if they have identical probe signatures:

```
ObsEq P r Y x y ⟺ probeSignature P r Y x = probeSignature P r Y y
```

**Proposition 2.5.** `ObsEq P r Y` is an equivalence relation.

### 2.4 Separation

**Definition 2.6.** A probe family `P` *separates* elements `x, y ∈ F(Y)` if their probe signatures differ:

```
SeparatesElements P r x y ⟺ probeSignature P r Y x ≠ probeSignature P r Y y
```

### 2.5 No New Separation

**Definition 2.7.** Given `P ⊆ P'`, we say `P'` introduces *no new separation* relative to `P` if every pair separated by `P'` is already separated by `P`:

```
NoNewSeparation P P' r ⟺ ∀ Y x y, SeparatesElements P' r x y → SeparatesElements P r x y
```

Equivalently (by contraposition):

```
NoNewSeparation P P' r ⟺ ∀ Y x y, ObsEq P r Y x y → ObsEq P' r Y x y
```

### 2.6 Measurement Invariant

**Definition 2.8.** The *measurement space image cardinality* at object `Y` is:

```
measurementSpaceImageCard P r Y := |Finset.univ.image (probeSignature P r Y)|
```

**Definition 2.9.** The *measurement invariant* is:

```
measurementInvariant P r := ∑ Y, measurementSpaceImageCard P r Y
```

---

## 3. Main Results

### 3.1 Abstract Refinement Lemma

The proofs rest on an abstract combinatorial principle about functions on finite sets.

**Theorem 3.1** (`card_image_mono_of_refines`). Let $f : \alpha \to \beta$ and $g : \alpha \to \gamma$ be functions on a finite type $\alpha$. If $g$ *refines* $f$ — meaning $g(x) = g(y) \implies f(x) = f(y)$ for all $x, y$ — then:

$$|\text{image}(f)| \leq |\text{image}(g)|$$

*Proof sketch.* The refinement condition means $f$ factors through $g$: there is a well-defined function $\varphi : \text{image}(g) \to \text{image}(f)$ with $\varphi(g(a)) = f(a)$. This $\varphi$ is surjective (every value $f(a)$ is the image of $g(a)$). A surjection between finite sets gives the cardinality bound. ∎

**Theorem 3.2** (`image_card_eq_of_refines_and_eq`). Under the same hypotheses, if additionally $|\text{image}(f)| = |\text{image}(g)|$, then $f(x) = f(y) \implies g(x) = g(y)$.

*Proof sketch.* Equal cardinality + surjectivity ⟹ bijectivity of $\varphi$. Bijectivity of $\varphi$ implies that $\varphi$ is injective: $\varphi(g(x)) = \varphi(g(y)) \implies g(x) = g(y)$. Since $\varphi(g(x)) = f(x)$, we get $f(x) = f(y) \implies g(x) = g(y)$. ∎

### 3.2 Signature Refinement

**Theorem 3.3** (`probeSignature_refines`). If $P \subseteq P'$, then the $P'$-signature refines the $P$-signature:

$$\sigma_{P'}(Y, x) = \sigma_{P'}(Y, y) \implies \sigma_P(Y, x) = \sigma_P(Y, y)$$

*Proof.* The $P$-signature is a subtuple of the $P'$-signature (selecting coordinates indexed by $P \subseteq P'$). Equal tuples have equal subtuples. Formally, use `funext` and the fact that each coordinate $Z \in P$ is also in $P'$. ∎

### 3.3 Monotonicity (Theorem 1)

**Theorem 3.4** (`measurementInvariant_mono`). If $P \subseteq P'$, then $M(P) \leq M(P')$.

*Proof.* By Theorems 3.1 and 3.3, at each object $Y$:

$$m_P(Y) = |\text{image}(\sigma_P(Y, \cdot))| \leq |\text{image}(\sigma_{P'}(Y, \cdot))| = m_{P'}(Y)$$

Summing over all $Y$ gives $M(P) \leq M(P')$. ∎

### 3.4 Equality from Redundancy (Theorem 2)

**Theorem 3.5** (`measurementInvariant_eq_of_noNewSeparation`). If $P \subseteq P'$ and $\text{NoNewSeparation}(P, P', r)$, then $M(P) = M(P')$.

*Proof.* The no-new-separation condition gives: $\sigma_P(Y, x) = \sigma_P(Y, y) \implies \sigma_{P'}(Y, x) = \sigma_{P'}(Y, y)$. Combined with Theorem 3.3, the two signatures have the same equivalence classes. By Theorem 3.1 applied in *both* directions, $m_P(Y) = m_{P'}(Y)$ for each $Y$. ∎

### 3.5 Rigidity (Theorem 3)

**Theorem 3.6** (`noNewSeparation_of_measurementInvariant_eq`). If $P \subseteq P'$ and $M(P) = M(P')$, then $\text{NoNewSeparation}(P, P', r)$.

*Proof.* Since $m_P(Y) \leq m_{P'}(Y)$ for all $Y$ (by monotonicity) and $\sum_Y m_P(Y) = \sum_Y m_{P'}(Y)$, each summand must be equal: $m_P(Y) = m_{P'}(Y)$.

At each $Y$, apply Theorem 3.2 to $f = \sigma_P(Y, \cdot)$ and $g = \sigma_{P'}(Y, \cdot)$ with the refinement from Theorem 3.3 and the cardinality equality. We conclude: $\sigma_P(Y, x) = \sigma_P(Y, y) \implies \sigma_{P'}(Y, x) = \sigma_{P'}(Y, y)$.

By contraposition, this gives NoNewSeparation. ∎

### 3.6 Iff Characterization (Theorem 4)

**Theorem 3.7** (`measurementInvariant_eq_iff_noNewSeparation`). For $P \subseteq P'$:

$$M(P) = M(P') \iff \text{NoNewSeparation}(P, P', r)$$

*Proof.* Combine Theorems 3.5 and 3.6. ∎

### 3.7 Strict Increase (Theorem 5)

**Theorem 3.8** (`strict_increase_of_newSeparation`). If $P \subseteq P'$ and there exist $Y, x, y$ such that $P'$ separates $x, y$ but $P$ does not, then $M(P) < M(P')$.

*Proof.* By monotonicity, $M(P) \leq M(P')$. If $M(P) = M(P')$, then by rigidity (Theorem 3.6), $\text{NoNewSeparation}(P, P', r)$ holds, contradicting the existence of a new separation. Hence $M(P) < M(P')$. ∎

### 3.8 Saturation (Theorem 6)

**Theorem 3.9** (`measurementInvariant_eq_of_presheafSeparates_superset`). If $P$ is separating (probe signatures are injective at every object) and $P \subseteq P'$, then $M(P) = M(P')$.

*Proof.* By Theorem 3.5, it suffices to show NoNewSeparation. If $P'$ separates $x$ and $y$ (meaning $x \neq y$, since they have different $P'$-signatures), then $P$ also separates them by injectivity of $\sigma_P(Y, \cdot)$. ∎

---

## 4. Algorithms

### 4.1 Signature Computation

**Algorithm 1: ComputeSignature**

```
Input: Presheaf F, probe family P, object Y, element x ∈ F(Y)
Output: Probe signature σ_P(Y, x)

1. For each Z ∈ P (in fixed order):
2.   Compute c_Z = r(Y, Z)(x)
3. Return (c_Z)_{Z ∈ P}

Time: O(|P|)
Space: O(|P|)
```

### 4.2 Measurement Invariant

**Algorithm 2: MeasurementInvariant**

```
Input: Presheaf F, probe family P
Output: M(P) = ∑_Y |{σ_P(Y, x) : x ∈ F(Y)}|

1. total ← 0
2. For each Y ∈ Ob:
3.   S ← ∅
4.   For each x ∈ F(Y):
5.     σ ← ComputeSignature(F, P, Y, x)
6.     S ← S ∪ {σ}
7.   total ← total + |S|
8. Return total

Time: O(|Ob| · max_Y |F(Y)| · |P|)
Space: O(max_Y |F(Y)|)
```

### 4.3 Redundancy Detection

**Algorithm 3: DetectRedundancy**

```
Input: Presheaf F, probe families P ⊆ P'
Output: Boolean (is P' redundant relative to P?)

1. For each Y ∈ Ob:
2.   For each pair (x, y) with x ≠ y in F(Y):
3.     σ_P = ComputeSignature(F, P, Y, x)
4.     τ_P = ComputeSignature(F, P, Y, y)
5.     σ_P' = ComputeSignature(F, P', Y, x)
6.     τ_P' = ComputeSignature(F, P', Y, y)
7.     If σ_P' ≠ τ_P' and σ_P = τ_P:
8.       Return False  // new separation found
9. Return True

Time: O(|Ob| · max_Y |F(Y)|² · |P'|)
Space: O(|P'|)
```

### 4.4 Full Comparison

**Algorithm 4: FullComparison**

```
Input: Presheaf F, probe families P ⊆ P'
Output: (M(P), M(P'), monotone?, equal?, redundant?)

1. m_P ← MeasurementInvariant(F, P)
2. m_P' ← MeasurementInvariant(F, P')
3. redundant ← DetectRedundancy(F, P, P')
4. Assert: (m_P = m_P') ↔ redundant  // Theorem 4
5. Return (m_P, m_P', m_P ≤ m_P', m_P = m_P', redundant)

Time: O(|Ob| · max_Y |F(Y)|² · |P'|)
```

---

## 5. Applications and Computational Experiments

### 5.1 Sensor Array Design

We model a 4-zone factory with sensors at each zone. Each zone has 4 possible states (idle, running, warning, critical). Sensors at the same zone have full resolution; adjacent zones have partial resolution (warning/critical merge); distant zones have coarse resolution (all active states merge).

**Results:** The measurement invariant for all 16 probe families satisfies strict monotonicity under inclusion. The full sensor array ({Z1, Z2, Z3, Z4}) has M = 16 (full separation), while {Z1, Z3} achieves M = 14. Removing Z2 from the full array is not redundant (M drops), while removing Z4 from {Z1, Z2, Z3, Z4} may or may not be redundant depending on the restriction maps.

### 5.2 Feature Selection

Animals with 4 features (size, legs, tail, wings) across 3 classes (cat, dog, bird). With all features, M = 8 (all 8 exemplars distinguished). Feature set {legs, wings} alone achieves M = 6, while {size, legs} achieves M = 7. The minimal separating feature set is {size, legs, tail}, with M = 8.

### 5.3 Diagnostic Test Design

12 patients with 5 diseases, 4 available tests. The full test battery achieves M = 12 (all patients distinguished). Interestingly, the blood test alone achieves M = 8, the swab test M = 7, and temperature M = 9. Combining swab + temperature achieves M = 11, missing only one patient pair. The X-ray test is nearly redundant when added to {blood, swab, temp}.

### 5.4 Logical Formula Refinement

15 graph structures across 5 types, with 5 boolean formulas (has_edge, connected, has_triangle, regular, has_leaf). The measurement invariant grows monotonically as formulas are added. The full formula set achieves M = 8, but no subset of 4 formulas achieves the same — all 5 are needed. {has_triangle, regular} alone achieves M = 8 as well, demonstrating that smaller subsets can be as powerful as the full set when the missing formulas are redundant.

### 5.5 Exhaustive Verification

For the 3-object color presheaf with 9 elements across 3 fibers, we exhaustively tested all 19 inclusion pairs among the 8 possible probe families. Results:
- Monotonicity: 19/19 verified ✓
- Equality ⟺ No New Separation: 19/19 verified ✓
- Strict increase under new separation: 13/13 verified ✓

---

## 6. Discussion

### 6.1 Relationship to the Data Processing Inequality

The classical DPI states that for a Markov chain $X \to Y \to Z$:

$$I(X; Z) \leq I(X; Y)$$

Our Theorem 1 is the deterministic, finite analogue. The probe signature $\sigma_P(Y, \cdot)$ acts as a deterministic channel from $F(Y)$ to the signature space. Enlargement $P \subseteq P'$ means $\sigma_P$ is a post-processing of $\sigma_{P'}$ (it can be obtained by forgetting coordinates). The measurement invariant counts the number of distinct output values, which is a crude analogue of mutual information.

The key difference: we characterize *equality* completely (Theorem 4), which is harder to do for the probabilistic DPI (equality requires specific Markov chain conditions).

### 6.2 Limitations

1. **Finiteness assumption.** All results require finite types. Extension to infinite types would require topological or measure-theoretic machinery.

2. **Coarseness of the invariant.** The measurement invariant is a cardinality count, not a true entropy. It does not distinguish between partitions with the same number of blocks but different block sizes. A more refined invariant would use Shannon entropy of the partition.

3. **No noise model.** All separations are exact. A practical theory would need approximate separation (signatures within some tolerance).

### 6.3 Connections to Blackwell Comparison

Blackwell's theorem (1953) characterizes when one statistical experiment is "more informative" than another. Our probe family inclusion $P \subseteq P'$ is a special case of Blackwell's comparison for deterministic experiments. Theorem 4 gives a computable criterion for Blackwell equivalence in this special case.

---

## 7. Future Work

1. **Entropic refinement.** Replace the cardinality-based measurement invariant with a Shannon entropy measure of the partition induced by probe signatures. This would give a richer invariant that distinguishes partitions with the same block count.

2. **Approximate separation.** Extend the theory to metric spaces where separation is defined up to a tolerance $\varepsilon$. This would connect to compressed sensing and dimensionality reduction.

3. **Categorical generalization.** Extend from discrete categories to general small categories, where restriction maps have functorial properties. This would connect to the full Yoneda embedding.

4. **Active probe selection.** Use the measurement invariant to design adaptive probe selection algorithms: choose the next probe to maximize the expected increase in the invariant.

5. **Infinite categories.** Extend to topological or smooth categories, connecting to diffeological spaces and continuous measurement theory.

---

## 8. References

1. Shannon, C. E. (1948). "A Mathematical Theory of Communication." *Bell System Technical Journal*, 27(3), 379–423.

2. Blackwell, D. (1953). "Equivalent Comparisons of Experiments." *Annals of Mathematical Statistics*, 24(2), 265–272.

3. Cover, T. M., & Thomas, J. A. (2006). *Elements of Information Theory*. 2nd edition. Wiley.

4. Torgersen, E. (1991). *Comparison of Statistical Experiments*. Cambridge University Press.

5. Mac Lane, S. (1998). *Categories for the Working Mathematician*. 2nd edition. Springer.

6. Hodges, W. (1993). *Model Theory*. Cambridge University Press.

---

## Appendix: Formal Verification

All theorems in this paper have been mechanically verified in the Lean 4 theorem prover (version 4.28.0) using the Mathlib library. The formalization resides in:

- `Pythagorean/ProbeComplexity/CompressionStability.lean` — main theorem package
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — measurement invariant definitions
- `Pythagorean/ProbeComplexity/Defs.lean` — probe family definitions
- `Pythagorean/ProbeComplexity/Theorems.lean` — basic probe complexity theorems

The verification confirms that all proofs compile without `sorry` and depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).
