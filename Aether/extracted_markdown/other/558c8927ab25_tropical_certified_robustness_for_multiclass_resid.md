# Tropical Certified Robustness for Multiclass Residual Piecewise-Linear Networks under ECOC Decoding

## Abstract

We present a formally verified framework for certified adversarial robustness of multiclass classifiers using Error-Correcting Output Code (ECOC) decoders. Our approach bridges three mathematical layers: (1) coordinatewise tropical/Lipschitz bounds on individual network score coordinates, (2) combinatorial Hamming geometry of binary codewords, and (3) global stability of the decoded class label. The key insight is that ECOC redundancy transforms the robustness problem from preserving a single fragile argmax into preserving pairwise code agreements—a task governed by coding-theoretic error-correction capacity. We prove that the decoded class is certified robust whenever, for each competing class, fewer than half of the separating code bits are "uncertified" (have margin-to-Lipschitz ratio below the perturbation radius). All theorems are formalized and machine-verified in Lean 4 with Mathlib, providing the highest level of mathematical certainty.

## 1. Introduction

Adversarial robustness—the stability of a classifier's output under small input perturbations—is a central concern in deploying neural networks for safety-critical applications. A robustness *certificate* provides a mathematical guarantee: "for all perturbations within radius $r$, the classifier's prediction is unchanged." Such guarantees are fundamentally more valuable than empirical robustness evaluations, which can always be defeated by stronger attacks.

For standard multiclass classifiers with softmax or argmax output layers, certified robustness reduces to ensuring that the gap between the top logit and all runner-up logits is maintained under perturbation. The tropical geometry approach to this problem exploits the piecewise-linear structure of ReLU networks: each logit coordinate is a tropical rational function (a difference of max-plus polynomials), and its Lipschitz constant can be computed or bounded from the network's weights.

**ECOC decoders change the game.** In an ECOC scheme, each class is assigned a binary codeword, and the network produces scores for each code bit rather than for each class directly. The decoded class is whichever codeword has the highest Hamming agreement with the predicted bit vector. This introduces error-correcting capability: even if some bits flip, the decoder may still recover the correct class, provided the codewords are sufficiently separated in Hamming distance.

This paper formalizes the precise robustness guarantee that ECOC decoding provides. Our main theorem states:

> **Theorem (Informal).** If the network's score at a point $x$ matches the codeword of class $c$, each score coordinate is $K_i$-Lipschitz, and for every competing class $d$, strictly fewer than half of the code bits separating $c$ from $d$ have certified radius $|f(x)_i|/K_i$ at most $r$, then the decoder output is $c$ for all inputs within distance $r$ of $x$.

## 2. Mathematical Framework

### 2.1 ECOC Decoding

Let $C$ be a finite set of classes, and let $m \in \mathbb{N}$ be the number of code bits. A codebook is a function $\text{code} : C \to \{0,1\}^m$ assigning each class a binary codeword.

**Definition (Agreement).** The agreement between a bit vector $b \in \{0,1\}^m$ and class $c$ is:
$$\text{agreement}(b, c) = |\{i \in [m] : b_i = \text{code}(c)_i\}|$$

**Definition (Unique Decoder).** Class $c$ is the unique decoder output for $b$ if:
$$\forall d \neq c,\; \text{agreement}(b, c) > \text{agreement}(b, d)$$

### 2.2 Bit Prediction and Margins

Given a network $f : \alpha \to \mathbb{R}^m$ producing real-valued scores, we define:

- **Bit prediction:** $\text{bitPred}(f, x, i) = [f(x)_i \geq 0]$ (1 if nonneg, 0 otherwise)
- **Margin:** $\text{margin}(f, x, i) = |f(x)_i|$
- **Certified radius:** $\text{certRadius}(f, K, x, i) = |f(x)_i| / K_i$

where $K_i$ is the Lipschitz constant of the $i$-th score coordinate.

### 2.3 Disagreement Sets

For classes $c$ and $d$, the **disagreement set** is:
$$D(c,d) = \{i \in [m] : \text{code}(c)_i \neq \text{code}(d)_i\}$$

This is the set of bit positions that distinguish $c$ from $d$. Its cardinality is the Hamming distance $d_H(c, d)$.

## 3. Main Results

### 3.1 Theorem 1: Combinatorial ECOC Robustness

The coding-theoretic core of our framework is purely combinatorial, independent of neural networks or metric spaces.

**Theorem (ecoc_stable_under_flip_budget).** Let $b_0$ match the codeword of class $c$ exactly ($b_0(i) = \text{code}(c)_i$ for all $i$). Let $b$ be any bit vector such that for every competitor $d \neq c$:
$$2 \cdot |\{i \in D(c,d) : b(i) \neq b_0(i)\}| < |D(c,d)|$$
Then $c$ is the unique decoder output for $b$.

*Proof sketch.* Fix $d \neq c$. Partition $D(c,d)$ into bits where $b$ agrees with $\text{code}(c)$ and bits where $b$ disagrees. Since $\text{code}(c)_i \neq \text{code}(d)_i$ on $D(c,d)$, disagreeing with $\text{code}(c)$ means agreeing with $\text{code}(d)$. The budget hypothesis says fewer than half disagree with $\text{code}(c)$, so more than half agree with $\text{code}(c)$. This gives a strict agreement advantage for $c$ on $D(c,d)$. Outside $D(c,d)$, both classes get equal credit. Therefore $\text{agreement}(b, c) > \text{agreement}(b, d)$.

### 3.2 Theorem 2: Analytic Sign Stability

**Lemma (same_sign_of_abs_sub_lt).** If $|a - b| < |b|$, then $(0 \leq a) \iff (0 \leq b)$.

**Theorem (sign_stable_of_abs_lt_margin).** Let $f : \alpha \to \mathbb{R}$ satisfy $|f(y) - f(x)| \leq K \cdot d(y,x)$ for all $y$, with $K \geq 0$ and $K \cdot r < |f(x)|$. Then for all $y$ with $d(y,x) \leq r$:
$$(0 \leq f(y)) \iff (0 \leq f(x))$$

*Proof.* From $|f(y) - f(x)| \leq K \cdot d(y,x) \leq K \cdot r < |f(x)|$, we get $|f(y) - f(x)| < |f(x)|$, and the lemma applies.

### 3.3 Theorem 3: ECOC Decoder Robustness (Main Result)

**Theorem (ecoc_decoder_robust_of_coordinate_certificates).** Let $(\alpha, d)$ be a pseudometric space, $f : \alpha \to \mathbb{R}^m$ with coordinatewise Lipschitz bounds $K_i \geq 0$, and $x \in \alpha$ such that $\text{bitPred}(f, x) = \text{code}(c)$. If for every $d \neq c$:
$$2 \cdot |\{i \in D(c,d) : |f(x)_i| \leq K_i \cdot r\}| < |D(c,d)|$$
then for all $y$ with $d(y,x) \leq r$, class $c$ is the unique decoder output for $\text{bitPred}(f, y)$.

*Proof.* For any $y$ in the ball:
1. If $|f(x)_i| > K_i \cdot r$, then by Theorem 2, $\text{bitPred}(f, y, i) = \text{bitPred}(f, x, i) = \text{code}(c)_i$.
2. Therefore any bit that flips must be in the uncertified set $\{i : |f(x)_i| \leq K_i \cdot r\}$.
3. On each $D(c,d)$, the flipped bits are a subset of the uncertified bits in $D(c,d)$.
4. By hypothesis, fewer than half of $D(c,d)$ is uncertified.
5. Apply Theorem 1 to conclude.

**Corollary (ecoc_decoder_robust_of_pairwise_radius_count).** With $K_i > 0$, robustness holds if for every $d \neq c$:
$$2 \cdot |\{i \in D(c,d) : \text{certRadius}(f, K, x, i) \leq r\}| < |D(c,d)|$$

This is the most interpretable form: robustness is certified whenever, for every competitor, fewer than half of the distinguishing bits have certified radius at most $r$.

## 4. Formal Verification

All results are formalized in Lean 4 with the Mathlib library. The formalization consists of approximately 300 lines of Lean code with complete proofs—no axioms beyond the standard Lean kernel axioms (`propext`, `Classical.choice`, `Quot.sound`).

The key formal statements are:

```lean
theorem ecoc_stable_under_flip_budget
    (code : C → Fin m → Bool) (b₀ b : Fin m → Bool) (c : C)
    (hbase : ∀ i, b₀ i = code c i)
    (hbudget : ∀ d, d ≠ c →
      2 * ((univ.filter fun i => b i ≠ b₀ i ∧ code c i ≠ code d i).card)
        < ((univ.filter fun i => code c i ≠ code d i).card))
    : IsUniqueDecoder code b c

theorem ecoc_decoder_robust_of_coordinate_certificates
    (code : C → Fin m → Bool) (f : α → Fin m → ℝ)
    (K : Fin m → ℝ) (x : α) (r : ℝ) (c : C)
    (hbase : ∀ i, bitPred f x i = code c i)
    (hLip : ∀ i y, |f y i - f x i| ≤ K i * dist y x)
    (hK : ∀ i, 0 ≤ K i) (hr : 0 ≤ r)
    (hsep : ∀ d, d ≠ c →
      2 * ((univ.filter fun i =>
        code c i ≠ code d i ∧ |f x i| ≤ K i * r).card)
        < ((univ.filter fun i => code c i ≠ code d i).card))
    : ∀ y, dist y x ≤ r → IsUniqueDecoder code (bitPred f y) c
```

The formal proof structure mirrors the mathematical argument:
- Helper lemmas establish the combinatorial partition of disagreement sets
- The sign stability lemma handles the real analysis
- The main theorem composes these ingredients

## 5. Significance and Connections

### 5.1 Why ECOC Robustness Is Different

Standard multiclass robustness (argmax of logits) is fragile: flipping a single coordinate can change the predicted class. ECOC introduces redundancy that provides genuine error-correction. The minimum Hamming distance $d_{\min}$ of the code determines the number of bit errors that can be corrected: up to $\lfloor (d_{\min} - 1)/2 \rfloor$ bit flips are tolerated.

Our theorem makes this precise at the level of individual perturbation radii, going beyond worst-case Hamming distance bounds. For each competitor class $d$, the relevant quantity is not the global code distance but the per-coordinate margin-to-Lipschitz ratios on the disagreement set $D(c,d)$.

### 5.2 Connection to Tropical Geometry

The tropical approach to certified robustness views ReLU networks as tropical rational maps. Each neuron computes $\max(0, x)$, which in the tropical semiring $(\mathbb{R}, \max, +)$ is the identity operation. The compositional structure of deep networks yields piecewise-linear functions whose Lipschitz constants can be computed from the tropical decomposition.

Our framework takes the Lipschitz constants as given and focuses on how they combine through the ECOC decoder. This makes the theory applicable not just to tropical analyses but to any method that provides coordinatewise Lipschitz bounds.

### 5.3 Relation to Randomized Smoothing

Randomized smoothing provides probabilistic robustness certificates by averaging over Gaussian perturbations. Our certificates are *deterministic*: they guarantee robustness for *all* perturbations in the ball, not just in expectation. The two approaches are complementary: randomized smoothing is scalable but approximate, while tropical ECOC certificates are exact but require Lipschitz constant computation.

## 6. Applications

### 6.1 Designing Robust Codebooks

Our theorem provides a concrete optimization target for codebook design. Given a pre-trained network with known margins and Lipschitz constants, the codebook that maximizes the certified radius is the one that:
- Maximizes minimum Hamming distance (for worst-case guarantees)
- Concentrates high-margin bits on the disagreement sets of close competitors

### 6.2 Adaptive Perturbation Budgets

Unlike uniform-radius certificates, our theorem allows *non-uniform* certification. Different code bits may have vastly different margins and Lipschitz constants. The certified radius is determined by the "weakest majority" across all pairwise comparisons, not by the single weakest bit.

### 6.3 Abstention and Rejection

When the certificate fails—i.e., some competitor has too many uncertified bits on its disagreement set—the system can abstain rather than make an unreliable prediction. The per-competitor analysis identifies exactly which classes are at risk.

### 6.4 Product-Code and Hierarchical Extensions

The proof structure generalizes naturally to:
- **Product codes**: where the code is a Cartesian product of smaller codes
- **Hierarchical codes**: where classes are organized in a tree and codes reflect the hierarchy
- **Weighted ECOC**: where different bits carry different importance weights

## 7. Discussion: Error Correction Meets Machine Learning

*A discussion for general readers.*

Imagine you're trying to communicate a message through a noisy telephone line. You could say "yes" or "no," but static on the line might flip a single sound and change the meaning entirely. Engineers solved this problem decades ago with **error-correcting codes**: instead of saying "yes," you say "yes-yes-yes," so even if one repetition gets garbled, the receiver can recover the original message by majority vote.

Our research applies this same idea to make AI systems more reliable. Modern neural networks for image classification are notoriously vulnerable to **adversarial perturbations**—tiny, imperceptible changes to an image that cause the network to misclassify it. A stop sign with a few strategically placed stickers might be classified as a speed limit sign, with potentially catastrophic consequences for self-driving cars.

The standard approach to classification uses a separate network output for each class (one score for "cat," one for "dog," etc.), and the class with the highest score wins. This is fragile: changing just one score slightly can flip the decision.

**ECOC decoding works differently.** Instead of one output per class, the network produces outputs for binary "code bits." Each class has a unique binary codeword—like a barcode. The system predicts each bit independently, then matches the predicted bit string to the nearest codeword. Crucially, the codewords are chosen to be far apart in "Hamming distance" (the number of positions where they differ), just like in telecommunications.

The mathematical insight we formalize is this: if each code bit has a certain **margin** (how confidently the network predicts it) and a certain **sensitivity** (how much it changes under input perturbations), then we can count how many bits might flip for a given perturbation size. As long as fewer than half the bits distinguishing any two classes flip, the decoder still recovers the correct class.

This is exactly the error-correction property of the code, adapted to continuous perturbations. The beauty is that even if some bits are very fragile (small margin, high sensitivity), robust bits elsewhere in the code can compensate—just as in telecommunications, where some symbols might be corrupted but the message gets through.

We prove this theorem with complete mathematical rigor using **Lean 4**, a computer proof assistant. The computer mechanically verifies every logical step, leaving no room for errors in the argument. This is important because adversarial robustness claims have significant real-world implications, and informal proofs can contain subtle gaps.

The practical upshot: when designing AI systems for safety-critical applications, using ECOC decoders with carefully chosen codes can provide *provably* stronger robustness guarantees than standard classifiers, with the improvement governed by the error-correcting capacity of the code.

## 8. Future Directions

1. **Weighted ECOC certificates**: Extending to weighted Hamming agreement, where different bits carry different importance.
2. **Tight certified radii**: Computing the exact largest $r$ for which the certificate holds, which requires solving a combinatorial optimization problem over disagreement sets.
3. **Code design optimization**: Joint optimization of the codebook and network architecture to maximize certified robustness.
4. **Integration with tropical network analysis**: Automatic computation of per-bit Lipschitz constants from network weights via tropical geometry.
5. **Empirical validation**: Comparing ECOC robustness certificates with state-of-the-art certified defense methods on standard benchmarks.

## References

1. Zhang, H., et al. "Towards Stable and Efficient Training of Verifiably Robust Neural Networks." ICLR 2020.
2. Dietterich, T.G. and Bakiri, G. "Solving Multiclass Learning Problems via Error-Correcting Output Codes." JAIR, 1995.
3. Zhang, L., et al. "Tropical Geometry of Deep Neural Networks." ICML 2018.
4. Cohen, J., Rosenfeld, E., and Kolter, J.Z. "Certified Adversarial Robustness via Randomized Smoothing." ICML 2019.
5. The Lean community. Mathlib4. https://github.com/leanprover-community/mathlib4
