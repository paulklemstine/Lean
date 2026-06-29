# Functorial Entropy: Measuring Information Loss in Functions and Functors

## Abstract

We develop a theory of **functorial entropy** that assigns to each function f : α → β between finite types a non-negative real number H(f) measuring the information destroyed by f. The entropy H(f) is defined as the weighted logarithmic sum over the fibers of f, and satisfies several fundamental properties: (1) H(f) = 0 if and only if f is injective; (2) H(f) ≤ log|α|; (3) H(g ∘ f) ≥ H(f) for any post-composition (data processing inequality). We establish a bridge to Shannon entropy showing H(f) = log|α| − H_Shannon(fiber distribution), and lift the theory to functors between finite categories. All results are formally verified in the Lean 4 proof assistant with the Mathlib library.

**Keywords**: functorial entropy, information loss, data processing inequality, category theory, formal verification

## 1. Introduction

The concept of entropy, originating in thermodynamics and formalized by Shannon [1] for communication theory, measures uncertainty or information content. In category theory, functors between categories can "lose information" by mapping non-isomorphic objects to isomorphic ones. This paper bridges these perspectives by defining a precise measure of information loss for functions between finite types.

Our central definition associates to each function f : α → β a non-negative real number H(f), the *functorial entropy*, that quantifies the irreversible collapse of the domain into fibers. The definition is:

$$H(f) = \sum_{b \in \beta} \frac{|f^{-1}(b)|}{|\alpha|} \cdot \log |f^{-1}(b)|$$

This generalizes naturally to functors between finite categories by applying the formula to the object map.

### 1.1 Main Contributions

1. **Zero Characterization** (Theorem 3.1): H(f) = 0 ↔ f is injective
2. **Post-Composition Monotonicity** (Theorem 4.1): H(g ∘ f) ≥ H(f) for any g
3. **Superadditivity of t·log(t)** (Theorem 4.2): (a+b)·log(a+b) ≥ a·log(a) + b·log(b)
4. **Entropy–Shannon Bridge** (Theorem 5.1): H(f) = log|α| − H_Shannon(fiber distribution)
5. **Categorical Lifting** (Section 6): Extension to functors with composition monotonicity

### 1.2 Related Work

Baez, Fritz, and Leinster [2] characterized entropy in a categorical framework using operadic structures. Our approach is complementary: rather than axiomatizing entropy categorically, we measure the information loss inherent in categorical morphisms. Leinster [3] studied the entropy of a finite probability distribution from a categorical perspective. Our work extends this by assigning entropy not to distributions but to functions, with the distribution emerging naturally as the fiber distribution.

## 2. Definitions

### 2.1 Fiber Cardinality

**Definition 2.1** (Fiber Cardinality). For f : α → β with α finite and β having decidable equality, the *fiber cardinality* of f over b ∈ β is:

$$\text{fiberCard}(f, b) = |\{a \in \alpha : f(a) = b\}|$$

**Lemma 2.2**. The sum of fiber cardinalities equals |α|:
$$\sum_{b \in \beta} \text{fiberCard}(f, b) = |\alpha|$$

**Lemma 2.3**. f is injective iff every fiber has cardinality ≤ 1.

### 2.2 Functorial Entropy

**Definition 2.4** (Functorial Entropy). For f : α → β between finite types:

$$H(f) = \sum_{b \in \beta} \frac{\text{fiberCard}(f, b)}{|\alpha|} \cdot \log(\text{fiberCard}(f, b))$$

where log denotes the natural logarithm and we use the convention 0 · log(0) = 0.

### 2.3 Shannon Entropy

**Definition 2.5** (Shannon Entropy). For a probability distribution p on a finite type ι:

$$H_{\text{Shannon}}(p) = -\sum_{i \in \iota} p(i) \cdot \log(p(i))$$

### 2.4 Fiber Distribution

**Definition 2.6** (Fiber Distribution). The *fiber distribution* of f : α → β is the function:

$$q(b) = \frac{\text{fiberCard}(f, b)}{|\alpha|}$$

This is a valid probability distribution on β (sums to 1, each value in [0, 1]).

### 2.5 Functor Object Entropy

**Definition 2.7** (Functor Object Entropy). For a functor F : C ⥤ D between categories with finite object types:

$$H_{\text{obj}}(F) = H(F.\text{obj})$$

where F.obj : Ob(C) → Ob(D) is the object map of F.

### 2.6 Information Channel

**Definition 2.8** (Information Channel). An *information channel* from α to β is a triple (f, h, h_eq) where f : α → β is a function, h = H(f) is its entropy, and h_eq certifies the equality.

## 3. Zero Characterization

**Theorem 3.1** (Zero Characterization). For f : α → β with α nonempty:
$$H(f) = 0 \iff f \text{ is injective}$$

*Proof sketch.* (⇐) If f is injective, every fiber has size 0 or 1, so each summand in H(f) is either 0 · log(0) = 0 or (1/|α|) · log(1) = 0.

(⇒) If H(f) = 0, then since each summand is non-negative (product of non-negative weight and non-negative log of a natural ≥ 1), every summand must vanish. For fiberCard(f, b) ≥ 2, the summand is strictly positive (both the weight and log(fiberCard) are positive). So every fiber has size ≤ 1, making f injective.

The strict positivity argument is the key insight: it shows that **even a single non-trivial fiber forces positive entropy**.

**Corollary 3.2**. H(f) > 0 iff f is not injective.

## 4. Composition Monotonicity

### 4.1 Superadditivity

**Theorem 4.2** (Superadditivity of t·log(t)). For a, b ≥ 0:
$$(a + b) \cdot \log(a + b) \geq a \cdot \log(a) + b \cdot \log(b)$$

*Proof.* Case analysis:
- If a = 0 or b = 0: immediate (log(0) = 0 in our convention).
- If a, b > 0: Rewrite the difference as a·log((a+b)/a) + b·log((a+b)/b). Since a+b > a > 0, we have (a+b)/a > 1, so log((a+b)/a) ≥ 0. Similarly for b. Both terms are non-negative.

**Theorem 4.3** (Generalized Superadditivity). For non-negative weights w₁, ..., wₖ:
$$\sum_i w_i \cdot \log(w_i) \leq \left(\sum_i w_i\right) \cdot \log\left(\sum_i w_i\right)$$

*Proof.* By induction on the size of the index set, using Theorem 4.2 at each step.

### 4.2 Post-Composition Monotonicity

**Theorem 4.1** (Post-Composition Monotonicity). For f : α → β and g : β → γ:
$$H(f) \leq H(g \circ f)$$

*Proof sketch.* The fiber of g∘f over c ∈ γ decomposes as:

$$\text{fiberCard}(g \circ f, c) = \sum_{b : g(b) = c} \text{fiberCard}(f, b)$$

Regrouping the entropy sum for H(f) by the g-fibers:

$$H(f) = \frac{1}{|\alpha|} \sum_c \sum_{b : g(b) = c} \text{fiberCard}(f, b) \cdot \log(\text{fiberCard}(f, b))$$

By the generalized superadditivity (Theorem 4.3), each inner sum satisfies:

$$\sum_{b : g(b) = c} n_b \cdot \log(n_b) \leq m_c \cdot \log(m_c)$$

where nᵦ = fiberCard(f, b) and mᶜ = fiberCard(g∘f, c). Summing over c and dividing by |α| yields H(f) ≤ H(g∘f). □

This theorem is the information-theoretic analog of the **data processing inequality**: post-processing can only destroy information, never create it.

## 5. The Entropy–Shannon Bridge

**Theorem 5.1** (Entropy–Shannon Bridge). For f : α → β with α nonempty:

$$H(f) = \log|\alpha| - H_{\text{Shannon}}(\text{fiberDist}(f))$$

*Proof.* Expand the definitions:

$$H(f) = \sum_b \frac{n_b}{N} \cdot \log(n_b) = \sum_b \frac{n_b}{N} \cdot (\log N + \log \frac{n_b}{N})$$
$$= \log N \cdot \sum_b \frac{n_b}{N} + \sum_b \frac{n_b}{N} \cdot \log \frac{n_b}{N} = \log N - H_{\text{Shannon}}(q)$$

where q(b) = nᵦ/N is the fiber distribution and N = |α|. □

**Corollary 5.2**. H(f) ≤ log|α|, with equality when all elements map to a single output.

**Corollary 5.3**. For surjective f : α → β, H(f) ≥ log(|α|/|β|).

## 6. Categorical Extension

### 6.1 Functor Object Entropy

The functor object entropy H_obj(F) = H(F.obj) inherits all properties of functorial entropy:

1. **Non-negativity**: H_obj(F) ≥ 0
2. **Zero iff injective on objects**: H_obj(F) = 0 ↔ F.obj injective
3. **Identity**: H_obj(Id_C) = 0
4. **Composition monotonicity**: H_obj(F) ≤ H_obj(F ⋙ G)

Property (4) is the categorical data processing inequality: composing functors can only increase information loss on objects.

### 6.2 The Composition Superadditivity Conjecture

**Conjecture 6.1** (Composition Superadditivity). For surjective f : α → β and any g : β → γ:

$$H(g) \leq H(g \circ f)$$

This states that pre-composing with a surjection cannot decrease information loss. Combined with Theorem 4.1, this would give a complete picture of how entropy behaves under composition.

**Evidence**: Verified computationally for hundreds of random functions. The conjecture is a strengthening of the data processing inequality, requiring a comparison between H(g) (defined on β) and H(g∘f) (defined on α), where the domains differ. This makes it significantly harder than Theorem 4.1, which compares entropies on the same domain.

## 7. The Landauer Connection

**Definition 7.1** (Landauer Cost). The Landauer cost of f : α → α at temperature parameter kT is:

$$\text{Cost}(f, kT) = kT \cdot H(f)$$

**Theorem 7.1**. Reversible (bijective) computations have zero Landauer cost.

**Theorem 7.2**. Zero Landauer cost at positive temperature implies injectivity.

These results formalize Landauer's principle: the minimum energy dissipation in a computation is proportional to the information it irreversibly erases.

## 8. Algorithms and Computational Examples

### 8.1 Computing Functorial Entropy

```
Algorithm ComputeEntropy(f : α → β):
  N ← |α|
  for each b ∈ β:
    n_b ← |{a ∈ α : f(a) = b}|
  H ← 0
  for each b ∈ β:
    if n_b > 0:
      H ← H + (n_b / N) * log(n_b)
  return H
```

Time complexity: O(|α| + |β|). Space complexity: O(|β|).

### 8.2 Examples

| Function | Domain | Codomain | H(f) |
|----------|--------|----------|------|
| Identity | Fin n | Fin n | 0 |
| Constant | Fin n | Fin 1 | log(n) |
| Mod 2 on Fin 6 | Fin 6 | ZMod 2 | log(3) |
| Floor on {0,..,5} | Fin 6 | Fin 3 | log(2) |

## 9. Discussion

### 9.1 Relationship to Other Entropy Concepts

Functorial entropy differs from Shannon entropy in a fundamental way: Shannon entropy measures the uncertainty of a random variable, while functorial entropy measures the information destroyed by a deterministic function. The Entropy–Shannon Bridge (Theorem 5.1) makes this precise: H(f) = log|α| − H_Shannon(q), where q is the fiber distribution.

### 9.2 Connections to Algebraic Topology

The fiber structure of a function is a partition of the domain, and partitions form a lattice. Functorial entropy assigns a real-valued "size" to each partition that respects the refinement order: finer partitions (from more injective functions) have lower entropy. This makes H a monotone function from the partition lattice to ℝ, connecting to the theory of valuation functions on lattices.

## 10. Future Work

1. **Composition superadditivity**: Prove or disprove Conjecture 6.1.
2. **Morphism entropy**: Define entropy for individual morphisms in a category, not just the object map of a functor.
3. **Infinite types**: Extend to measure-theoretic settings using conditional entropy.
4. **Quantum functors**: Define entropy for functors between categories enriched over Hilbert spaces.
5. **Entropy rate**: For endofunctors, define the asymptotic entropy rate as n → ∞ of the n-fold composition.

## References

[1] Shannon, C.E. (1948). "A Mathematical Theory of Communication." Bell System Technical Journal, 27(3), 379–423.

[2] Baez, J.C., Fritz, T., & Leinster, T. (2011). "A characterization of entropy in terms of information loss." Entropy, 13(11), 1945–1957.

[3] Leinster, T. (2021). *Entropy and Diversity: The Axiomatic Approach.* Cambridge University Press.

[4] Landauer, R. (1961). "Irreversibility and Heat Generation in the Computing Process." IBM Journal of Research and Development, 5(3), 183–191.

[5] Cover, T.M., & Thomas, J.A. (2006). *Elements of Information Theory* (2nd ed.). Wiley.

## Appendix: Formal Verification

All theorems in Sections 2–7 have been formally verified in Lean 4 using the Mathlib library. The formalization comprises approximately 500 lines of Lean code across three files:

- `Core.lean`: Basic definitions and the zero characterization theorem
- `Composition.lean`: Superadditivity, composition monotonicity, and the Shannon bridge
- `CategoryEntropy.lean`: Categorical lifting and functor entropy
