# Tropical Certified Robustness for Top-k Predictions: A Machine-Verified Theorem

## Abstract

We present a formally verified theory of certified robustness for top-k predictions
of multiclass piecewise-linear neural networks. The classical margin-based robustness
certificate, which guarantees invariance of the top-1 (argmax) prediction under
bounded L∞ perturbation, is upgraded to a set-valued certificate guaranteeing
invariance of the entire top-k prediction set. The key mathematical object is the
**k-th order-statistic gap**: the difference between the k-th and (k+1)-th largest
class scores. We prove that this gap degrades by at most 2ε under coordinatewise
ε-perturbation, and that whenever the gap exceeds 2ε, the top-k prediction set is
exactly preserved. The theory is compositional: a 1-Lipschitz score aggregation layer
preserves the perturbation bound, enabling certification of architectures with
pooling, score fusion, or attention-style layers. All results are machine-verified
in Lean 4 with the Mathlib library—no sorry, no custom axioms, no gaps.

## 1. Introduction

### 1.1 The Robustness Certification Problem

Neural network classifiers are vulnerable to adversarial perturbation: small,
often imperceptible changes to the input can cause dramatic changes in the
output prediction. Certified robustness provides mathematical guarantees that
the prediction is stable within a specified region around each input.

The standard approach certifies the **argmax** (top-1) prediction: given a
classifier f(x) producing scores for C classes, the certificate guarantees
that the highest-scoring class is unchanged for all perturbations δ with
‖δ‖∞ ≤ r. The certified radius r is determined by the **margin**—the gap
between the highest and second-highest class scores, divided by a Lipschitz
constant.

### 1.2 Why Top-k?

In many practical settings, the operational output is not a single class but
a **shortlist** of top-k candidates:

- **Search and retrieval**: Return the k most relevant documents
- **Medical diagnosis**: Present the k most likely conditions
- **Recommendation systems**: Show the top-k items to the user
- **Beam search in sequence generation**: Maintain k candidate sequences
- **Ensemble methods**: Aggregate predictions from k diverse models

For these applications, the relevant question is not "does the top-1 change?"
but "does the top-k set change?" Our theorem provides an exact, computable
certificate for this question.

### 1.3 The Tropical Connection

The term "tropical" refers to the min-plus (or max-plus) algebraic framework
that naturally describes piecewise-linear functions, including ReLU neural
networks. In this framework, the network function is a tropical rational map,
and the Lipschitz constant has an interpretation as the **tropical degree**—the
number of linear pieces along a generic line. Our certificates extend the
tropical robustness program from scalar (top-1) to set-valued (top-k)
predictions.

## 2. Mathematical Framework

### 2.1 Core Definitions

**Definition 1** (k-th Largest Value). For a score function s : Fin C → ℝ and
index k ∈ ℕ with k < C, the k-th largest value (0-indexed) is:

$$\text{kthLargest}(s, k) = \max_{\substack{S \subseteq [C] \\ |S| = k+1}} \min_{i \in S} s(i)$$

This "sup-of-infima" characterization is equivalent to sorting the values in
descending order and taking the (k+1)-th element. Its advantage over sorting
is that it leads directly to clean perturbation bounds.

**Definition 2** (Top-k Gap). For k ≥ 1 with k < C:

$$\text{topkGap}(s, k) = \text{kthLargest}(s, k-1) - \text{kthLargest}(s, k)$$

This measures the separation between the k-th and (k+1)-th largest scores.

**Definition 3** (Top-k Set). The top-k set is:

$$\text{topKSet}(s, k) = \{i \in [C] \mid \text{kthLargest}(s, k) < s(i)\}$$

Under a positive gap condition, this set has exactly k elements.

### 2.2 Key Insight: Sup-of-Infima and Perturbation

The critical property of the sup-of-infima definition is that it interacts
cleanly with coordinatewise perturbation. If |t(i) - s(i)| ≤ ε for all i,
then for any subset S:

$$\inf_{i \in S} t(i) \leq \inf_{i \in S} s(i) + \varepsilon$$

This immediately gives kthLargest(t, k) ≤ kthLargest(s, k) + ε, and
symmetrically kthLargest(t, k) ≥ kthLargest(s, k) - ε.

## 3. Main Results

### 3.1 Order-Statistic Perturbation Bound

**Theorem 1** (kthLargest Stability). If ∀ i, |t(i) - s(i)| ≤ ε with ε ≥ 0, then:

$$|\text{kthLargest}(t, k) - \text{kthLargest}(s, k)| \leq \varepsilon$$

*Proof sketch*: For the upper bound, take any (k+1)-subset S. Its infimum under
t is at most its infimum under s plus ε. Since kthLargest is the supremum of
these infima, the bound follows. The lower bound is symmetric, using the subset
that achieves the supremum for s. □

### 3.2 Gap Degradation

**Theorem 2** (Gap Stability). Under the same conditions:

$$\text{topkGap}(t, k) \geq \text{topkGap}(s, k) - 2\varepsilon$$

*Proof*: By linearity of the gap definition and the two-sided perturbation bound. □

### 3.3 Top-k Set Cardinality

**Theorem 3** (Cardinality). If topkGap(s, k) > 0 and 1 ≤ k < C, then
|topKSet(s, k)| = k.

*Proof sketch*: The upper bound (≤ k) uses contradiction: if k+1 elements all
exceeded the threshold, they would form a (k+1)-subset whose infimum exceeds
the supremum of all such infima. The lower bound (≥ k) uses the gap: the
k-subset achieving the supremum for kthLargest(s, k-1) lies entirely within
the top-k set. □

### 3.4 Main Stability Theorem

**Theorem 4** (Top-k Stability). Let f : ℝ^d → ℝ^C satisfy the coordinatewise
perturbation bound:

$$\forall i,\; |f(x + \delta)_i - f(x)_i| \leq K \cdot d \cdot \|\delta\|_\infty$$

If topkGap(f(x), k) > 2Kd‖δ‖∞, then:

$$\text{topKSet}(f(x + \delta), k) = \text{topKSet}(f(x), k)$$

*Proof*: Let S = topKSet(f(x), k). For any i ∈ S and j ∉ S, the separation
theorem gives f(x)ᵢ - f(x)ⱼ ≥ topkGap(f(x), k). After perturbation with
ε = Kd‖δ‖∞:

$$f(x+\delta)_i - f(x+\delta)_j \geq (f(x)_i - f(x)_j) - 2\varepsilon > 0$$

Since every original top-k element still dominates every non-top-k element,
the dominance theorem gives topKSet(f(x+δ), k) = S. □

### 3.5 Certified Radius

**Corollary** (Explicit Radius). Under the hypotheses of Theorem 4 with K > 0
and d > 0:

$$\|\delta\|_\infty < \frac{\text{topkGap}(f(x), k)}{2Kd} \implies \text{topKSet}(f(x+\delta), k) = \text{topKSet}(f(x), k)$$

### 3.6 Compositional Theorem

**Theorem 5** (1-Lipschitz Aggregation). Let h : ℝ^d → ℝ^m satisfy the
coordinatewise bound ∀ j, |h(x+δ)ⱼ - h(x)ⱼ| ≤ Kd‖δ‖∞, and let
A : ℝ^m → ℝ^C satisfy ∀ z, z', ∀ i, |A(z)ᵢ - A(z')ᵢ| ≤ ‖z - z'‖∞.

Then ∀ i, |A(h(x+δ))ᵢ - A(h(x))ᵢ| ≤ Kd‖δ‖∞, and the top-k certificate
of Theorem 4 applies to A ∘ h.

## 4. Formal Verification

All results are formalized in Lean 4 using the Mathlib library. The
formalization consists of two files totaling approximately 350 lines.

### 4.1 Definitions

The sup-of-infima definition of `kthLargest` was chosen over a sorting-based
definition because the perturbation bound follows directly from Finset.sup'_le
and Finset.le_inf', avoiding the need to formalize properties of sorted lists.

### 4.2 Theorem Inventory

| Theorem | Statement |
|---------|-----------|
| `kthLargest_perturb_le` | k-th largest ≤ original + ε |
| `kthLargest_perturb_ge` | k-th largest ≥ original - ε |
| `topkGap_perturb_ge` | Gap degrades by at most 2ε |
| `topKSet_card_le` | Top-k set has ≤ k elements |
| `topKSet_card_ge_of_gap_pos` | Positive gap ⟹ ≥ k elements |
| `topKSet_card_of_gap_pos` | Positive gap ⟹ exactly k elements |
| `topKSet_nmem_le` | Non-members score ≤ threshold |
| `topKSet_mem_ge` | Members score ≥ (k-1)-th largest |
| `topKSet_separation` | In-out separation ≥ gap |
| `topKSet_eq_of_dominates` | Domination ⟹ set equality |
| `topk_stable_of_gap_pos` | **Main stability theorem** |
| `topk_stable_on_closedBall` | Ball-form certificate |
| `topk_certified_radius` | Explicit radius form |
| `coord_lipschitz_comp_preserves_bound` | Composition preserves bound |
| `topk_stable_comp_agg` | **Compositional theorem** |
| `proj/relu/min_one_lipschitz` | Concrete aggregator bounds |

### 4.3 Axiom Audit

All theorems depend only on the standard axioms: `propext`,
`Classical.choice`, and `Quot.sound`. No `sorry`, no custom axioms,
no `@[implemented_by]`.

## 5. Applications

### 5.1 Certified Top-k Retrieval

In information retrieval, a neural ranker produces relevance scores for C
documents. The certified radius guarantees the retrieved set is invariant
within an explicit L∞ ball around each query embedding.

### 5.2 Robust Medical Diagnosis

A diagnostic model's "differential diagnosis" (top-k conditions) is certified
stable when the gap exceeds 2ε. This provides quantitative safety guarantees
for clinical decision support.

### 5.3 Certified Beam Search

In sequence models, beam search maintains top-k candidates. The compositional
theorem certifies beam stability through multi-layer architectures.

### 5.4 Robust Score Fusion

The compositional theorem covers architectures with max-pooling, averaging,
or attention-based score fusion, since these are 1-Lipschitz operations.

## 6. Discussion: Making Robustness Tangible

### The Scoreboard Analogy

Imagine a tournament scoreboard with C teams. The "top-k gap" is the margin
between k-th and (k+1)-th place. Our theorem says: **if the gap exceeds
twice the measurement error, the playoff bracket is trustworthy**. No noise
within the error budget can change which teams qualify.

### Why 2ε?

The factor of 2 is tight: perturbation can simultaneously raise a non-top-k
score (+ε) and lower a top-k score (-ε), requiring the gap to exceed 2ε.

### The Compositional Insight

Real networks process scores through pooling and normalization. The
compositional theorem shows that 1-Lipschitz post-processing preserves
the certificate, covering practical architectures without modification.

### Formal Verification: Trust But Verify

Machine verification eliminates proof bugs. For safety-critical robustness
certificates, this level of rigor is not just desirable but necessary.

## 7. Future Directions

1. **Robust ranking**: Full Kendall tau distance guarantees
2. **Certified beam search**: Multi-step compositional certification
3. **Adaptive k**: Certifying confidence-based k selection
4. **Tropical degree integration**: Architecture-aware Lipschitz constants
5. **Robust attention**: Certification through bounded softmax layers

## 8. Conclusion

We have formalized and machine-verified a complete theory of certified
top-k robustness. The central result—top-k invariance when the gap exceeds
2ε—generalizes the classical margin certificate. The theory is compositional,
covers practical architectures, and all proofs are verified in Lean 4 with
no gaps or custom axioms.

---

*File structure:*
```
MachineLearning/TopKRobustness/
├── Defs.lean    # Core definitions
└── Main.lean    # All 16 theorems, fully proved

demos/
├── topk_robustness_demo.py     # Interactive Python demos
├── topk_certified_regions.png  # Certified region visualization
└── topk_gap_analysis.png       # Gap degradation plots
```
