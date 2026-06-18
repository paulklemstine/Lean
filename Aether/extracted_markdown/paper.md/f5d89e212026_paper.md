# Tropical Certified Robustness for Multiclass Piecewise-Linear Networks under Top-K Decision via Order-Statistic Gaps

## Abstract

We present a formally verified theory of certified robustness for top-*k* prediction in multiclass neural networks, formalized in Lean 4 with Mathlib. The central contribution is a set-based formulation of top-*k* stability that avoids sorting machinery entirely, reducing order-statistic certification to finite pairwise comparisons over `Finset (Fin n)`. We prove four main theorems: (1) coordinate-Lipschitz top-*k* stability with certified radius `margin/(2K)`, (2) a sharper pairwise-difference Lipschitz variant that eliminates the factor-of-2 penalty when score differences have smaller Lipschitz constants due to cancellation, (3) a subset preservation theorem for hierarchical readouts, and (4) an order-statistic cardinality corollary. We also prove Lipschitz closure lemmas for `max`, ReLU, and finite max-pooling, connecting the abstract stability theory to tropical/piecewise-linear network architectures. All proofs are machine-verified and depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## 1. Introduction

Certified robustness—providing mathematical guarantees that a classifier's prediction is stable under bounded input perturbations—is a cornerstone of trustworthy machine learning. While extensive work has addressed the binary and single-class argmax settings, the top-*k* prediction problem has received less formal attention despite its practical importance in retrieval, shortlist prediction, and hierarchical classification.

The top-*k* prediction asks: which *k* classes receive the highest scores? This is fundamentally an order-statistic question. Previous approaches typically require formalizing the *k*-th and (*k*+1)-st sorted coordinates, introducing sorting permutations and their associated proof obligations. This is technically burdensome in a formal proof assistant.

**Our key insight** is that top-*k* set stability can be phrased entirely as a finite conjunction of pairwise comparisons: class *i* ∈ *S* dominates class *j* ∉ *S* if and only if *f(x,i) > f(x,j)*. This reduces the problem to finitely many scalar inequalities, each of which can be controlled by Lipschitz bounds. No sorting is needed.

This formulation is especially natural for tropical (piecewise-linear) network architectures, where each output coordinate is a max-affine function and the Lipschitz constant admits clean compositional bounds through `max`, ReLU, and max-pooling operations.

### Contributions

1. **Sort-free top-*k* stability theory.** We define `StrictTopKSet f x S` as a predicate asserting that all classes in *S* strictly dominate all classes outside *S*, and prove stability theorems using only `Finset` quantification.

2. **Pairwise-Lipschitz sharpening.** Our `topk_stable_of_pairwise_lipschitz` theorem uses individual Lipschitz constants *L*(*i*,*j*) for each score difference *f_i - f_j*, yielding strictly tighter certificates than the generic `margin/(2K)` bound when cancellation occurs.

3. **Subset preservation.** The `subset_of_topk_preserved` theorem guarantees that a designated subset *T* ⊆ *S* of classes cannot drop below outside classes, even if the internal ranking within *S* may permute.

4. **Tropical closure.** Lipschitz closure for `max`, ReLU, and `Finset.sup'` enables compositional certification of piecewise-linear architectures.

5. **Complete machine verification.** All results are proved in Lean 4 using only standard axioms.

## 2. Mathematical Framework

### 2.1 Score Maps and Top-K Sets

Let (α, d) be a pseudometric space and *f* : α → Fin *n* → ℝ a multiclass score map assigning *n* real-valued scores to each input.

**Definition (Score Gap).** For classes *i*, *j* ∈ Fin *n*:
```
scoreGap(f, x, i, j) = f(x, i) - f(x, j)
```

**Definition (Strict Top-K Set).** A finset *S* ⊆ Fin *n* is a strict top-*k* set at *x* if:
```
StrictTopKSet(f, x, S) ⟺ ∀ i ∈ S, ∀ j ∉ S, f(x, j) < f(x, i)
```

**Definition (Top-K Margin).** The top-*k* margin is the minimum score gap between any in-set and any out-set class:
```
topkMargin'(f, x, S) = min { f(x,i) - f(x,j) | i ∈ S, j ∉ S }
```

This is formalized using `Finset.min'` over the image of the cross product *S* × *Sᶜ*, requiring only that both *S* and *Sᶜ* are nonempty.

### 2.2 The Pairwise Gap Perturbation Lemma

The foundation of all stability results is a single inequality:

**Lemma (Pairwise Gap Perturbation).** If each coordinate *f_i* is *K*-Lipschitz, then for all *x*, *y* ∈ α and *i*, *j* ∈ Fin *n*:

```
f(y,i) - f(y,j) ≥ (f(x,i) - f(x,j)) - 2K · d(x,y)
```

*Proof.* From the Lipschitz bounds |*f(y,i)* − *f(x,i)*| ≤ *K* · *d*(*x*,*y*) and |*f(y,j)* − *f(x,j)*| ≤ *K* · *d*(*x*,*y*), we get:

*f(y,i)* − *f(y,j)* = (*f(x,i)* − *f(x,j)*) + (*f(y,i)* − *f(x,i)*) − (*f(y,j)* − *f(x,j)*)
≥ (*f(x,i)* − *f(x,j)*) − *K* · *d*(*x*,*y*) − *K* · *d*(*x*,*y*)
= (*f(x,i)* − *f(x,j)*) − 2*K* · *d*(*x*,*y*). □

### 2.3 Main Stability Theorems

**Theorem 1 (Coordinate-Lipschitz Stability).** If each *f_i* is *K*-Lipschitz and for every *i* ∈ *S*, *j* ∉ *S*:
```
2K · d(x,y) < f(x,i) - f(x,j)
```
then `StrictTopKSet(f, y, S)`.

**Theorem 2 (Margin Certificate).** If 2*K* · *r* < topkMargin'(*f*, *x*, *S*), then `StrictTopKSet(f, y, S)` for all *y* with *d*(*x*,*y*) ≤ *r*.

**Theorem 3 (Pairwise-Lipschitz Stability).** If each score difference *f_i* − *f_j* has Lipschitz constant *L*(*i*,*j*), and for every *i* ∈ *S*, *j* ∉ *S*:
```
L(i,j) · d(x,y) < f(x,i) - f(x,j)
```
then `StrictTopKSet(f, y, S)`.

This is strictly stronger than Theorem 1: it replaces 2*K* with *L*(*i*,*j*), which can be much smaller when *f_i* and *f_j* share structure (e.g., common subnetwork weights in a tropical architecture).

**Theorem 4 (Subset Preservation).** For *T* ⊆ *S*, if for every *i* ∈ *T*, *j* ∉ *S*:
```
2K · r < f(x,i) - f(x,j)
```
then for all *y* with *d*(*x*,*y*) ≤ *r* and every *i* ∈ *T*, *j* ∉ *S*: *f(y,j)* < *f(y,i)*.

**Theorem 5 (Cardinal Stability).** If *S*.card = *k* and the conditions of Theorem 2 hold, then `StrictTopKSet(f, y, S) ∧ S.card = k` for all *y* with *d*(*x*,*y*) ≤ *r*.

### 2.4 Tropical Closure Lemmas

**Theorem (Lipschitz Max).** If *g*, *h* : α → ℝ are both *K*-Lipschitz, then *x* ↦ max(*g*(*x*), *h*(*x*)) is *K*-Lipschitz.

**Theorem (ReLU is 1-Lipschitz).** The function *z* ↦ max(*z*, 0) is 1-Lipschitz.

**Theorem (Finset Sup' Lipschitz).** If every *g_b* is *K*-Lipschitz for *b* in a nonempty finset *s*, then *x* ↦ sup'_s *g_b*(*x*) is *K*-Lipschitz.

**Corollary (Certified Radius).** For a coordinate-*K*-Lipschitz network with positive top-*k* margin *m*, the certified radius is:
```
r* = m / (2K)
```
Within this radius, the top-*k* set is guaranteed to be preserved.

## 3. Formalization Details

### 3.1 File Structure

The Lean formalization consists of three files:

- **`Defs.lean`** (≈100 lines): Core definitions (`scoreGap`, `crossGaps`, `topkMargin'`, `IsTopKSet`, `StrictTopKSet`) and basic lemmas about `Finset` membership and margin bounds.

- **`Stability.lean`** (≈170 lines): The main stability theorems, including the pairwise gap perturbation lemma, coordinate-Lipschitz and pairwise-Lipschitz stability, subset preservation, and cardinal stability.

- **`Tropical.lean`** (≈85 lines): Lipschitz closure lemmas for `max`, ReLU, and `Finset.sup'`, plus the certified radius corollary.

### 3.2 Design Decisions

**Sort-free formulation.** By defining top-*k* membership through pairwise dominance rather than sorted coordinates, we avoid needing a formalization of sorting, order statistics, or the connection between sorted positions and set membership. This makes every theorem statement a straightforward finite conjunction.

**`Finset.min'` for margins.** We use `Finset.min'` rather than `sInf` over a real-valued set, avoiding the need for `ConditionallyCompleteLinearOrder` lemmas and the subtleties of `sInf ∅`.

**NNReal for Lipschitz constants.** Following Mathlib convention, `LipschitzWith` takes an `NNReal` argument. We bridge to the user's `ℝ`-valued constants via `⟨K, hK⟩ : ℝ≥0` constructions.

### 3.3 Axiom Audit

All theorems depend only on:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry`, `axiom`, or `@[implemented_by]` is used anywhere.

## 4. Applications

### 4.1 Retrieval and Shortlist Prediction

In information retrieval, the system returns the top-*k* documents/items. A certified radius guarantees that small perturbations to the query embedding (e.g., from quantization, adversarial noise, or measurement error) do not change the returned set. This is critical for:

- **Search engines**: Ensuring ranking stability under query perturbation.
- **Recommendation systems**: Guaranteeing shortlist consistency.
- **Medical diagnosis**: When the top-*k* differential diagnoses must be preserved.

### 4.2 Hierarchical Classification

The subset preservation theorem (Theorem 4) is designed for hierarchical readouts: given a coarse top-*k* set *S* (e.g., "this image is an animal") and a fine target *T* ⊂ *S* (e.g., "specifically a dog"), the theorem guarantees that the "dog" class cannot drop below any non-animal class within the certified radius, even if the internal animal ranking changes.

### 4.3 Tropical Network Certification

Max-affine (tropical) networks—ReLU networks viewed as tropical rational maps—admit especially clean Lipschitz analysis. Each output coordinate is a pointwise maximum of affine functions, so the Lipschitz constant is simply the maximum operator norm across pieces. The pairwise-Lipschitz variant is particularly valuable here: when two output classes share intermediate computations, their difference may have a much smaller Lipschitz constant than the sum of individual constants.

### 4.4 Multi-Label Safety

In safety-critical applications (autonomous driving, medical imaging), the decision rule is often "act if any of the top-*k* classes exceeds a threshold." Certified top-*k* stability ensures that the set of classes exceeding the threshold is invariant under bounded perturbation.

## 5. Discussion: A Scientific American Perspective

### What does "certified robustness" really mean?

Imagine you're using a medical AI that analyzes an X-ray and returns the three most likely diagnoses. You'd want to know: if the image is slightly blurry, or the lighting changes a bit, will those same three diagnoses still appear? Certified robustness gives you a mathematical guarantee—a "safety radius" around each input within which the prediction is provably unchanged.

### The sorting problem

Previous approaches to this problem faced a fundamental difficulty: defining "top-*k*" requires sorting all class scores, and sorting is surprisingly hard to reason about formally. It involves permutations, order statistics, and the delicate relationship between a score's value and its rank.

### Our insight: don't sort, just compare

We realized that you don't need to know the *ranking* of scores—you only need to know that every class in your top set beats every class outside it. This is just a collection of pairwise comparisons, each of which is easy to bound. It's like the difference between knowing that Alice, Bob, and Charlie are the three tallest people in a room (which requires measuring everyone and sorting) versus simply checking that Alice is taller than Dave, Alice is taller than Eve, Bob is taller than Dave, and so on.

### Why formal verification matters

These certificates are used in safety-critical systems. An error in the mathematical reasoning—a missed case, a wrong inequality direction—could lead to a false guarantee of safety. By formalizing the proofs in Lean 4 and having them machine-checked, we achieve the highest level of mathematical certainty available. Every step from the Lipschitz bound to the final stability guarantee is verified by the Lean kernel.

### The tropical connection

The name "tropical" comes from a beautiful area of mathematics where the usual operations of addition and multiplication are replaced by maximum and addition. It turns out that ReLU neural networks—the most common type in practice—naturally compute tropical polynomials. This means their Lipschitz constants can be analyzed combinatorially, piece by piece, leading to tighter robustness certificates than generic bounds.

### Looking forward

This work opens several directions:
- **Compositional certification**: Build certified robustness for complex architectures by chaining Lipschitz closure lemmas.
- **Approximate top-*k***: Extend to settings where we allow a small number of class swaps.
- **Randomized smoothing integration**: Combine deterministic certificates with randomized smoothing for probabilistic guarantees.
- **Tropical geometry of decision boundaries**: Use the tropical structure to characterize where certified radii are largest and smallest.

## 6. Related Work

The margin-based approach to certified robustness traces back to the classical generalization bounds of Bartlett and Shawe-Taylor. In the deep learning context, Hein and Andriushchenko (2017) established Lipschitz-based certification for binary classifiers, extended to multiclass argmax by Weng et al. (2018) and Tsuzuku et al. (2018).

Tropical approaches to neural network analysis were pioneered by Zhang et al. (2018), who showed that ReLU networks compute tropical rational maps. This viewpoint was developed further by Alfarra et al. (2020) for robustness certification and by Montúfar et al. for understanding the geometry of decision boundaries.

The formalization of Lipschitz conditions and metric space properties in Lean 4 / Mathlib provides the foundation for our work. The `LipschitzWith` predicate and its associated API in Mathlib are well-developed, enabling clean statements of our theorems.

Our contribution is to bring these threads together with a sort-free formulation of top-*k* stability that is both mathematically natural and formally tractable, plus a pairwise-Lipschitz sharpening that exploits the structure of tropical architectures.

## 7. Conclusion

We have presented a formally verified theory of top-*k* certified robustness for multiclass piecewise-linear networks, implemented in Lean 4. The key innovation is a sort-free formulation that reduces order-statistic stability to finite pairwise comparisons, making formal verification tractable. The pairwise-Lipschitz variant provides strictly tighter certificates for tropical architectures where score differences have smaller Lipschitz constants than individual coordinates. All 11 theorems and lemmas are machine-verified with no sorry axioms, and the theory connects cleanly to tropical network analysis through Lipschitz closure lemmas for max, ReLU, and finite max-pooling.

## References

1. Alfarra, M., Bibi, A., Torr, P.H.S., Ghanem, B. (2020). "On the Decision Boundaries of Neural Networks: A Tropical Geometry Perspective." *arXiv:2002.08838*.

2. Hein, M., Andriushchenko, M. (2017). "Formal Guarantees on the Robustness of a Classifier against Adversarial Manipulation." *NeurIPS 2017*.

3. Tsuzuku, Y., Sato, I., Sugiyama, M. (2018). "Lipschitz-Margin Training: Scalable Certification of Perturbation Invariance for Deep Neural Networks." *NeurIPS 2018*.

4. Weng, L., Zhang, H., Chen, H., Song, Z., Hsieh, C.-J., Daniel, L., Boning, D., Dhillon, I. (2018). "Towards Fast Computation of Certified Robustness for ReLU Networks." *ICML 2018*.

5. Zhang, L., Naitzat, G., Lim, L.-H. (2018). "Tropical Geometry of Deep Neural Networks." *ICML 2018*.

6. The Mathlib Community. (2024). "Mathlib: The Lean 4 Mathematical Library." *https://github.com/leanprover-community/mathlib4*.
