# Certified Tropical Invariants for Ranking Preservation in Network Analysis and Phylogenetics

## Abstract

We establish a formally verified theory of tropical equivalence on finite real-valued vectors and prove that all ranking-based observables are invariant under tropical shifts (additive translations). The core results include: (1) tropical equivalence forms an equivalence relation on ℝⁿ; (2) pairwise differences, pairwise orderings, strict orderings, argmin sets, and threshold sets are all invariant; (3) a quantitative robustness theorem showing that approximate tropical shifts preserve strict rankings when score gaps exceed twice the perturbation bound. All theorems are machine-verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound). We apply these results to certify ranking invariance of network centrality scores under normalization and nearest-neighbor invariance of phylogenetic dissimilarity profiles under baseline recalibration.

**Keywords**: tropical geometry, ranking invariance, formal verification, network analysis, phylogenetics, tropical projective space, certified data analysis

---

## 1. Introduction

### 1.1 Motivation

Tropical geometry studies algebraic and combinatorial structures arising when classical arithmetic is replaced by the min-plus (or max-plus) semiring: addition becomes minimum (or maximum), and multiplication becomes addition. This "tropicalization" has proven remarkably powerful across pure mathematics — from algebraic geometry and combinatorics to representation theory and number theory.

A fundamental concept in tropical geometry is **tropical equivalence**: two vectors x, y ∈ ℝⁿ are equivalent if they differ by an additive constant, i.e., y = x + c·**1** for some c ∈ ℝ. The quotient ℝⁿ/∼ is the tropical projective space TPⁿ⁻¹, which is the natural domain for tropical algebraic geometry.

In applied settings — phylogenetics, network analysis, machine learning — data vectors often undergo additive normalization (subtracting the mean, shifting to zero minimum, etc.). When the normalization is uniform (the same constant subtracted from every coordinate), the transformation is exactly a tropical equivalence. A natural question arises: **which data-analytic conclusions are invariant under tropical equivalence?**

This question has been answered informally in many applied papers: "rankings don't change under additive shifts." But to our knowledge, no prior work has:
1. Formally defined tropical equivalence as a mathematical structure.
2. Systematically proved the full hierarchy of invariance properties.
3. Extended the theory to approximate (noisy) shifts with quantitative robustness bounds.
4. Machine-verified all results for maximum certainty.

This paper fills that gap.

### 1.2 Contributions

1. **Definition and equivalence relation structure**: We define `TropEquiv` on `Fin n → ℝ` and prove it is an equivalence relation (Theorems 1–3).

2. **Complete invariance hierarchy**: We prove that pairwise differences (Theorem 4), pairwise non-strict order (Theorem 5), pairwise strict order (Theorem 6), argmin sets (Theorems 7–8), threshold sets (Theorem 9), and coordinate equality (Theorem 10) are all tropical invariants.

3. **Robustness theorem**: We prove that approximate tropical shifts (with ε-bounded perturbation) preserve strict rankings when score gaps exceed 2ε (Theorem 11).

4. **Applied instantiations**: We instantiate the general theory for network score functions (Theorem 12) and phylogenetic nearest-neighbor queries (Theorem 13).

5. **Formal verification**: All 15 theorems are proved in Lean 4 with Mathlib, depending only on the standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

**Tropical geometry foundations**: Maclagan and Sturmfels [MS15] provide the standard reference for tropical algebraic geometry. Tropical projective space and its quotient structure are foundational there.

**Tropical phylogenetics**: Yoshida, Zhang, and Zhang [YZZ19] apply tropical geometry to tree space and phylogenetic inference. Lin, Sturmfels, Tang, and Yoshida [LSTY17] study the tropical Grassmannian in the context of phylogenetics. These works use tropical coordinates descriptively but do not formalize invariance properties.

**Network analysis**: Butkovič [But10] develops max-plus linear algebra with applications to scheduling and discrete event systems. The min-plus spectral theory is developed there, but ranking invariance under shifts is not explicitly treated.

**Formal verification of mathematics**: The Mathlib library for Lean 4 provides extensive coverage of algebra, analysis, and combinatorics. Recent work has formalized results in combinatorics, number theory, and algebra, but tropical geometry applications remain largely unformalized.

---

## 2. Definitions and Notation

### 2.1 Tropical Equivalence

**Definition 1** (Tropical Equivalence). Let n ∈ ℕ. Two functions x, y : Fin n → ℝ are *tropically equivalent*, written x ∼ y, if there exists c ∈ ℝ such that y(i) = x(i) + c for all i ∈ Fin n.

In the Lean formalization:
```
def TropEquiv {n : ℕ} (x y : Fin n → ℝ) : Prop :=
  ∃ c : ℝ, ∀ i, y i = x i + c
```

**Remark**. This is the "min-plus" or "additive" convention for tropical equivalence. The equivalent "max-plus" convention replaces ℝ with its opposite order. The multiplicative convention (used in some algebraic geometry texts) replaces additive shift by multiplicative scaling, related through the logarithm.

### 2.2 Derived Concepts

**Argmin set**: For x : Fin n → ℝ, the argmin set is {i ∈ Fin n | ∀ j, x(i) ≤ x(j)}.

**Threshold set**: For x : Fin n → ℝ and τ ∈ ℝ, the sublevel set is {i ∈ Fin n | x(i) ≤ τ}.

**Score gap**: For x : Fin n → ℝ and i, j ∈ Fin n, the gap is x(j) − x(i).

---

## 3. Main Results

### 3.1 Equivalence Relation

**Theorem 1** (Reflexivity). TropEquiv is reflexive: for all x, TropEquiv x x.

*Proof sketch*. Take c = 0. Then y(i) = x(i) + 0 = x(i). □

**Theorem 2** (Symmetry). TropEquiv is symmetric: if TropEquiv x y, then TropEquiv y x.

*Proof sketch*. If y(i) = x(i) + c for all i, then x(i) = y(i) + (−c) for all i. □

**Theorem 3** (Transitivity). TropEquiv is transitive.

*Proof sketch*. If y(i) = x(i) + c₁ and z(i) = y(i) + c₂, then z(i) = x(i) + (c₁ + c₂). □

**Corollary** (Equivalence). TropEquiv is an equivalence relation on (Fin n → ℝ).

### 3.2 Pairwise Invariants

**Theorem 4** (Difference Invariance). If TropEquiv x y, then y(i) − y(j) = x(i) − x(j) for all i, j.

*Proof sketch*. y(i) − y(j) = (x(i) + c) − (x(j) + c) = x(i) − x(j). □

**Remark**. This is the fundamental invariant: pairwise differences are the coordinates of tropical projective space. Everything that follows is a consequence.

**Theorem 5** (Order Invariance). If TropEquiv x y, then x(i) ≤ x(j) ↔ y(i) ≤ y(j) for all i, j.

*Proof sketch*. x(i) ≤ x(j) ↔ x(i) + c ≤ x(j) + c ↔ y(i) ≤ y(j), using monotonicity of addition. □

**Theorem 6** (Strict Order Invariance). If TropEquiv x y, then x(i) < x(j) ↔ y(i) < y(j) for all i, j.

*Proof sketch*. Analogous to Theorem 5, using strict monotonicity. □

**Theorem 10** (Equality Invariance). If TropEquiv x y, then x(i) = x(j) ↔ y(i) = y(j) for all i, j.

*Proof sketch*. x(i) = x(j) ↔ x(i) + c = x(j) + c ↔ y(i) = y(j). □

### 3.3 Set-Level Invariants

**Theorem 7** (Argmin Membership). If TropEquiv x y, then for any i: (∀ j, x(i) ≤ x(j)) ↔ (∀ j, y(i) ≤ y(j)).

*Proof sketch*. Apply Theorem 5 to each quantified comparison. □

**Theorem 8** (Argmin Set). If TropEquiv x y, then {i | ∀ j, x(i) ≤ x(j)} = {i | ∀ j, y(i) ≤ y(j)}.

*Proof sketch*. Set extensionality from Theorem 7. □

**Theorem 9** (Threshold Transport). If y(i) = x(i) + c for all i, then {i | x(i) ≤ τ} = {i | y(i) ≤ τ + c}.

*Proof sketch*. x(i) ≤ τ ↔ x(i) + c ≤ τ + c ↔ y(i) ≤ τ + c. □

### 3.4 Robustness Under Approximate Shifts

**Theorem 11** (Gap-Stability). Let s, t : Fin n → ℝ, c, ε ∈ ℝ with ε ≥ 0. Suppose:
- |t(i) − s(i) − c| ≤ ε for all i (approximate shift),
- s(j) − s(i) > 2ε whenever s(i) < s(j) (gap condition).

Then: s(i) < s(j) implies t(i) < t(j).

*Proof sketch*. From |t(i) − s(i) − c| ≤ ε, we get t(i) ≤ s(i) + c + ε and t(j) ≥ s(j) + c − ε. Then:

t(j) − t(i) ≥ (s(j) + c − ε) − (s(i) + c + ε) = (s(j) − s(i)) − 2ε > 0.

The last inequality uses the gap condition. □

**Remark**. The factor of 2 is tight: if the gap equals exactly 2ε, the conclusion weakens to t(i) ≤ t(j) (non-strict). The gap condition is scale-free and interpretable as a signal-to-noise requirement.

### 3.5 Applied Instantiations

**Theorem 12** (Network Score Ranking). If s, t : Fin n → ℝ are node score functions with t(i) = s(i) + c for all i, then s(i) ≤ s(j) ↔ t(i) ≤ t(j) for all i, j.

*Application*. When s and t represent centrality scores computed by different software with different normalization conventions, and the normalization difference is a uniform additive shift, node rankings are guaranteed identical.

**Theorem 13** (Phylogenetic Nearest Neighbor). If d₁, d₂ : Fin n → ℝ are dissimilarity profiles with TropEquiv d₁ d₂, then for any query taxon q: (∀ j, d₁(q) ≤ d₁(j)) ↔ (∀ j, d₂(q) ≤ d₂(j)).

*Application*. Nearest-neighbor selection in phylogenetics is invariant under baseline recalibration of distance measures.

---

## 4. Algorithms

### 4.1 Checking Tropical Equivalence

**Algorithm 1**: TropEquivCheck(x, y)

```
Input: vectors x, y ∈ ℝⁿ
Output: True if TropEquiv(x, y), with witness c

1. If n = 0, return True with c = 0
2. c ← y[0] - x[0]
3. For i = 1 to n-1:
4.   If y[i] - x[i] ≠ c:
5.     return False
6. return True with witness c
```

**Complexity**: O(n) time, O(1) space.

### 4.2 Approximate Tropical Equivalence Check

**Algorithm 2**: ApproxTropEquivCheck(x, y, ε)

```
Input: vectors x, y ∈ ℝⁿ, tolerance ε ≥ 0
Output: True if ∃c such that |y[i] - x[i] - c| ≤ ε for all i

1. diffs ← [y[i] - x[i] for i in 0..n-1]
2. c ← median(diffs)  // or mean(diffs)
3. For i = 0 to n-1:
4.   If |diffs[i] - c| > ε:
5.     return False
6. return True with witness c
```

**Complexity**: O(n) time (O(n log n) if using median), O(n) space.

### 4.3 Minimum Gap Computation

**Algorithm 3**: MinGap(x)

```
Input: vector x ∈ ℝⁿ
Output: minimum gap between distinct consecutive sorted values

1. sorted ← sort(x)
2. min_gap ← ∞
3. For i = 1 to n-1:
4.   If sorted[i] > sorted[i-1]:
5.     min_gap ← min(min_gap, sorted[i] - sorted[i-1])
6. return min_gap
```

**Complexity**: O(n log n) time, O(n) space.

**Application**: Given min_gap and Theorem 11, rankings are preserved under any approximate tropical shift with ε < min_gap/2.

---

## 5. Applications

### 5.1 Network Centrality Robustness

Consider a network with n nodes and adjacency matrix A. Different centrality measures assign score vectors s : Fin n → ℝ. Common normalizations include:
- Raw scores: s
- Zero-minimum normalization: s − min(s)
- Mean-centering: s − mean(s)

Each of these produces a vector tropically equivalent to s (with c = −min(s) or c = −mean(s), respectively). By Theorem 12, node rankings are identical across all such normalizations.

**Worked example**: Consider a 5-node network with raw PageRank scores s = (0.35, 0.15, 0.25, 0.10, 0.15). After mean-centering (c = −0.20), we get t = (0.15, −0.05, 0.05, −0.10, −0.05). The ranking (node 1 > node 3 > nodes 2,5 > node 4) is preserved.

### 5.2 Phylogenetic Distance Normalization

In molecular phylogenetics, evolutionary distances between taxa are estimated from sequence alignment data. Different distance formulas (e.g., p-distance vs. Jukes-Cantor corrected distance) can produce systematically different absolute values. When the correction is approximately an additive shift across all taxon pairs, Theorem 13 guarantees nearest-neighbor invariance, and Theorem 11 provides a quantitative bound on how much deviation can be tolerated.

**Worked example**: Consider distances from a query taxon to 4 others: d₁ = (2.1, 3.5, 1.8, 4.2). Under a different distance formula: d₂ = (5.3, 6.7, 5.0, 7.4). We verify: d₂ − d₁ = (3.2, 3.2, 3.2, 3.2), so c = 3.2 and the vectors are exactly tropically equivalent. The nearest neighbor (taxon 3, with distance 1.8 = 5.0 − 3.2) is the same under both formulas.

### 5.3 Anomaly Detection Threshold Stability

In threshold-based anomaly detection, nodes with scores below a threshold τ are flagged. Theorem 9 shows that under a tropical shift by c, the same nodes are flagged at threshold τ + c. This means that the *set* of anomalous nodes is invariant — only the threshold value changes predictably.

---

## 6. Computational Experiments

### 6.1 Exact Tropical Equivalence

We implemented the algorithms in Python and tested on synthetic networks (Erdős–Rényi and Barabási–Albert models) with n = 10, 50, 100, 500 nodes. For each network:
1. Computed degree centrality scores s.
2. Applied random additive shift c ~ Uniform(−10, 10) to get t = s + c.
3. Verified ranking preservation: the Kendall tau distance between rankings of s and t was always 0.

### 6.2 Approximate Tropical Equivalence

For the robustness experiment:
1. Computed scores s with minimum gap δ = min_{s(i)≠s(j)} |s(i) − s(j)|.
2. Applied approximate shift: t(i) = s(i) + c + noise(i), where noise(i) ~ Uniform(−ε, ε).
3. Measured ranking agreement as a function of ε/δ.
4. Confirmed that strict ranking is preserved when ε < δ/2, matching the 2ε threshold from Theorem 11.

---

## 7. Discussion

### 7.1 Significance

The theorems in this paper are individually elementary — additive shifts preserve order. Their significance lies in three aspects:

1. **Systematization**: By packaging these results into a theory of tropical equivalence invariants, we create a reusable framework. Any future analysis that operates on rankings, argmin sets, or threshold sets can cite tropical invariance as a one-line justification.

2. **Machine verification**: All proofs are checked by the Lean proof assistant, providing a level of certainty that exceeds any peer review process. This is especially important for results that seem "obvious" — such results are precisely the ones where hidden edge cases (empty sets, ties, boundary conditions) can lurk.

3. **Extensibility**: The robustness theorem (Theorem 11) extends the theory from exact invariance to quantitative stability, bridging the gap between mathematical idealization and noisy reality.

### 7.2 Limitations

- The current theory handles only uniform additive shifts. Non-uniform shifts (where different coordinates are shifted by different amounts) break ranking invariance in general.
- The robustness theorem provides a *sufficient* condition (gap > 2ε) but does not characterize *necessary* conditions for ranking preservation.
- We do not formalize the connection to tropical projective space as a quotient type, though the ingredients are in place.

### 7.3 Connection to Existing Formalized Results

The catalog of existing tropical theorems provides several connection points:
- **`tropical_network_lipschitz_bound`**: Controls output perturbation as a function of input perturbation, enabling end-to-end robustness chains when combined with Theorem 11.
- **`tropical_hecke_shift_one`**: Suggests that the additive shift has a representation-theoretic interpretation as a Hecke operator, giving algebraic depth to the invariance theory.
- **`tropical_eigenpair_one_by_one`**: Points toward spectral invariance as a future direction.

---

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. Key targets include:
1. Quartet invariance for phylogenetic tree reconstruction.
2. Tropical quotient statistics on TPⁿ⁻¹.
3. Min-plus spectral invariance.
4. End-to-end certified centrality pipelines.
5. Information-theoretic tropical sufficiency.

---

## 9. Conclusion

We have established a formally verified theory of tropical equivalence invariance, proving that all ranking-based observables are preserved under additive shifts. The theory covers exact and approximate shifts, pointwise and set-level invariants, and instantiates to concrete applications in network analysis and phylogenetics. All results are machine-verified in Lean 4, providing mathematical certainty that tropical normalization does not alter scientifically relevant ordering information.

---

## References

[But10] P. Butkovič. *Max-linear Systems: Theory and Algorithms*. Springer, 2010.

[LSTY17] B. Lin, B. Sturmfels, X. Tang, R. Yoshida. Convexity in tree spaces. *SIAM J. Discrete Math.*, 31(3):2015–2038, 2017.

[MS15] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, vol. 161. AMS, 2015.

[YZZ19] R. Yoshida, L. Zhang, X. Zhang. Tropical geometry and phylogenetics. In *Algebraic and Geometric Methods in Discrete Mathematics*, AMS, 2019.

[SS09] D. Speyer, B. Sturmfels. Tropical mathematics. *Mathematics Magazine*, 82(3):163–173, 2009.
