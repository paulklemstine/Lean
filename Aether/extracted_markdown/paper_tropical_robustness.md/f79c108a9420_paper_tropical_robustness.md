# Tropical Certified Robustness for Multiclass Piecewise-Linear Networks with Hierarchical Max-Aggregation Trees

## Abstract

We present formally verified robustness certificates for multiclass classifiers built from hierarchical max-aggregation trees. The key contribution is a **subtree logit-gap certificate**: a recursive quantity computed bottom-up through the tree that provably lower-bounds the pairwise class margins at the root. Combined with Lipschitz propagation through max operations, this yields a certified robustness radius—any input perturbation within this radius is guaranteed to preserve the predicted class. All results are machine-verified in Lean 4 with the Mathlib library, producing proofs that depend only on the standard axioms of classical mathematics (propext, Classical.choice, Quot.sound).

## 1. Introduction

Adversarial robustness is a central concern in deploying neural networks for safety-critical applications. Given a classifier $T$ and an input $x$, we want to certify that all inputs $x'$ within a radius $r$ of $x$ receive the same classification. Existing certification approaches focus primarily on flat architectures: single-layer networks, individual max-pooling operations, or shallow compositions.

Modern architectures, however, feature **deep hierarchical max-aggregation**: attention mechanisms with softmax approximations, multi-resolution pooling, ensemble methods with max-voting, and dynamic programming layers. These create trees of `max` operations whose compositional structure has not been systematically exploited for certification.

We address this gap by formalizing a **tropical** approach to robustness certification. The term "tropical" refers to the max-plus algebra, where the fundamental operations are maximum and addition—exactly the operations that appear in piecewise-linear networks. Our main insight is that pairwise class margins (logit gaps) satisfy a **monotonicity property** through max-aggregation trees: the minimum gap over subtrees lower-bounds the gap at the root.

### Contributions

1. **Formal proof that max-aggregation preserves Lipschitz constants** by taking the maximum (not sum) of child constants—a key structural advantage of max over summation.

2. **A recursive subtree certificate** that provably lower-bounds pairwise logit gaps at the root, computed in a single bottom-up pass.

3. **A certified robustness radius** derived from these certificates, with a formally verified guarantee that any perturbation within this radius preserves the predicted class.

4. **Complete machine verification** of all results in Lean 4, providing the highest level of mathematical certainty.

## 2. Setup and Definitions

### 2.1 Aggregation Trees

We define a binary aggregation tree inductively:

$$
\text{AggTree} ::= \text{leaf}(f, L) \mid \text{bin}(T_\ell, T_r)
$$

where $f : \kappa \to \alpha \to \mathbb{R}$ is a family of class-score functions indexed by a type $\kappa$ of class labels, and $L \geq 0$ is a Lipschitz constant. The input space $\alpha$ is an arbitrary pseudo-metric space.

Any finite-arity tree can be encoded as a binary tree (since max is associative and commutative), so this captures all tree-structured max-aggregation architectures.

### 2.2 Recursive Evaluation

The **aggregated score** is defined recursively:

$$
\text{eval}(\text{leaf}(f, L), x, i) = f(i, x)
$$
$$
\text{eval}(\text{bin}(T_\ell, T_r), x, i) = \max(\text{eval}(T_\ell, x, i),\; \text{eval}(T_r, x, i))
$$

### 2.3 Lipschitz Bound

The **recursive Lipschitz bound** is:

$$
\text{lip}(\text{leaf}(\_, L)) = L, \qquad \text{lip}(\text{bin}(T_\ell, T_r)) = \max(\text{lip}(T_\ell), \text{lip}(T_r))
$$

### 2.4 Validity

A tree is **valid** if each leaf's score functions are actually Lipschitz with their stored constant:

$$
|f(i, x) - f(i, y)| \leq L \cdot d(x, y) \quad \forall i, x, y
$$

### 2.5 Logit Gaps and Certified Gaps

The **logit gap** between classes $i$ and $j$:

$$
\text{gap}(T, x, i, j) = \text{eval}(T, x, i) - \text{eval}(T, x, j)
$$

The **certified gap** (recursive minimum):

$$
\text{certGap}(\text{leaf}(f, \_), x, i, j) = f(i, x) - f(j, x)
$$
$$
\text{certGap}(\text{bin}(T_\ell, T_r), x, i, j) = \min(\text{certGap}(T_\ell, x, i, j),\; \text{certGap}(T_r, x, i, j))
$$

## 3. Main Results

### 3.1 Binary Max Lipschitz Lemma

**Theorem (abs_max_sub_max_le).** For all $a, b, c, d \in \mathbb{R}$:

$$
|\max(a, b) - \max(c, d)| \leq \max(|a - c|, |b - d|)
$$

*Proof.* By case analysis on which arguments achieve the maxima. If $\max(a,b) = a$, then $a - \max(c,d) \leq a - c \leq |a - c| \leq \max(|a-c|, |b-d|)$. The symmetric bound follows by swapping roles. ∎

This is the fundamental building block: taking a binary max is a *non-expansive* operation (1-Lipschitz in each argument).

### 3.2 Max-Preserves-Lipschitz Theorem

**Theorem (eval_lip).** If $T$ is a valid aggregation tree, then for all classes $i$ and inputs $x, y$:

$$
|\text{eval}(T, x, i) - \text{eval}(T, y, i)| \leq \text{lip}(T) \cdot d(x, y)
$$

*Proof.* By structural induction on $T$.

- **Leaf:** Directly from the validity assumption.
- **Bin:** By the induction hypothesis,
  $|T_\ell.\text{eval}(x, i) - T_\ell.\text{eval}(y, i)| \leq \text{lip}(T_\ell) \cdot d(x,y)$ and similarly for $T_r$. Applying `abs_max_sub_max_le`:

$$
|\max(a, b) - \max(c, d)| \leq \max(|a-c|, |b-d|) \leq \max(\text{lip}(T_\ell), \text{lip}(T_r)) \cdot d(x,y)
$$

where the last step uses $\max(L_1 \delta, L_2 \delta) = \max(L_1, L_2) \cdot \delta$ for $\delta \geq 0$. ∎

**Remark.** The crucial point is that the global Lipschitz constant is the *maximum* across leaves, not the *sum*. This is a fundamental advantage of max-aggregation over additive aggregation: adding $N$ Lipschitz functions multiplies the constant by $N$, while taking the max of $N$ Lipschitz functions preserves the maximum constant.

### 3.3 Tropical Monotonicity of Gaps

**Theorem (min_sub_le_max_sub_max).** For all $a, b, c, d \in \mathbb{R}$:

$$
\min(a - c, b - d) \leq \max(a, b) - \max(c, d)
$$

*Proof.* If $\max(c, d) = c$, then $\max(a,b) - c \geq a - c \geq \min(a-c, b-d)$. If $\max(c,d) = d$, then $\max(a,b) - d \geq b - d \geq \min(a-c, b-d)$. ∎

**Interpretation.** When a parent node takes the max of children's scores, the parent's gap between classes $i$ and $j$ is at least the minimum of the children's gaps. The key insight: whichever child achieves the maximum for class $j$ (the "losing" class), the parent's score for the "winning" class $i$ is at least that child's score for $i$, so the parent gap is at least that child's gap.

### 3.4 Subtree Certificate Monotonicity

**Theorem (certGap_le_gap).** For all trees $T$, inputs $x$, and class pairs $(i, j)$:

$$
\text{certGap}(T, x, i, j) \leq \text{gap}(T, x, i, j)
$$

*Proof.* By structural induction on $T$.

- **Leaf:** $\text{certGap} = \text{gap}$, so equality holds.
- **Bin:** By induction, $\text{certGap}(T_\ell) \leq \text{gap}(T_\ell)$ and $\text{certGap}(T_r) \leq \text{gap}(T_r)$. Therefore:

$$
\text{certGap}(\text{bin}) = \min(\text{certGap}(T_\ell), \text{certGap}(T_r)) \leq \min(\text{gap}(T_\ell), \text{gap}(T_r)) \leq \text{gap}(\text{bin})
$$

where the last inequality is the tropical monotonicity theorem. ∎

### 3.5 Gap Degradation Bound

**Theorem (gap_perturb_lower_bound).** For a valid tree $T$ and inputs $x, y$:

$$
\text{gap}(T, y, i, j) \geq \text{gap}(T, x, i, j) - 2 \cdot \text{lip}(T) \cdot d(x, y)
$$

*Proof.* Write:

$$
\text{gap}(T, y, i, j) = \text{eval}(T, y, i) - \text{eval}(T, y, j)
$$

From the Lipschitz bound (eval_lip):
$|\text{eval}(T, x, i) - \text{eval}(T, y, i)| \leq L \cdot d(x,y)$, giving $\text{eval}(T, y, i) \geq \text{eval}(T, x, i) - L \cdot d(x,y)$, and $\text{eval}(T, y, j) \leq \text{eval}(T, x, j) + L \cdot d(x,y)$. Subtracting:

$$
\text{gap}(T, y, i, j) \geq (\text{eval}(T, x, i) - L\delta) - (\text{eval}(T, x, j) + L\delta) = \text{gap}(T, x, i, j) - 2L\delta \quad\qquad ∎
$$

### 3.6 Classification Stability

**Theorem (argmax_stable).** Let $T$ be a valid tree and $c$ the predicted class at $x$. If for every competitor $j \neq c$:

$$
2 \cdot \text{lip}(T) \cdot d(x, y) < \text{certGap}(T, x, c, j)
$$

then $c$ is the strict winner at $y$: $\text{eval}(T, y, c) > \text{eval}(T, y, j)$ for all $j \neq c$.

*Proof.* For each $j \neq c$:

$$
\text{gap}(T, y, c, j) \geq \text{gap}(T, x, c, j) - 2L\delta \geq \text{certGap}(T, x, c, j) - 2L\delta > 0 \quad\qquad ∎
$$

### 3.7 Certified Robustness Radius

**Definition.** The certified radius is:

$$
R(T, x, c) = \min_{j \neq c} \frac{\text{certGap}(T, x, c, j)}{2 \cdot \text{lip}(T)}
$$

**Theorem (certRadius_spec).** If $T$ is valid, $\text{lip}(T) > 0$, all certified gaps are positive, and $d(x, y) < R(T, x, c)$, then $c$ is the strict winner at $y$.

*Proof.* From $d(x,y) < R$, we get $d(x,y) < \text{certGap}(T, x, c, j) / (2L)$ for all $j \neq c$. Multiplying by $2L > 0$: $2L \cdot d(x,y) < \text{certGap}(T, x, c, j)$. Apply argmax_stable. ∎

## 4. Formal Verification

All results are formalized in approximately 220 lines of Lean 4 code using the Mathlib library. The formalization choices include:

- **Binary trees** instead of n-ary trees, eliminating nonemptiness complications while losing no generality (any finite tree can be binarized).
- **PseudoMetricSpace** as the abstract input type, making all results applicable to arbitrary metric spaces including $\ell^\infty$.
- **Explicit absolute-value Lipschitz estimates** instead of Mathlib's `LipschitzWith` (which uses `ENNReal` for the constant), avoiding extended real arithmetic.

The formal proof of `certGap_le_gap` is particularly elegant:
```
induction T <;> simp [certGap, gap, eval]
· rfl  -- leaf case: certGap = gap
· exact (min_le_min IH_l IH_r).trans (min_sub_le_max_sub_max ..)
```

The entire development compiles cleanly with no warnings and uses only standard axioms.

## 5. Discussion: Why Trees of Max Matter

*A Scientific American perspective*

Imagine you're a building inspector who needs to certify that a skyscraper can withstand an earthquake. You could test the entire building at once—expensive and uninformative if it fails. Or you could inspect each floor, each wall, each joint, building confidence from the ground up. If every component passes inspection, the whole building is safe.

Our theorem does the same thing for AI classifiers. Modern AI systems don't make decisions in one step—they process information through layers of operations, each comparing and selecting the best among alternatives. These "max" operations are everywhere: attention mechanisms pick the most relevant context, pooling layers select the strongest feature, ensemble methods choose the best model's prediction.

The classical approach to certifying such systems treats the entire network as a black box and bounds its sensitivity to input changes (its "Lipschitz constant"). But this is like testing the whole skyscraper at once—it works but gives conservative bounds.

Our approach is compositional: we inspect each subtree of the computation independently, computing a local "margin certificate" at each node. The key mathematical insight—which we prove formally—is that these local certificates compose monotonically: if every subtree has a positive margin, the root must too. Moreover, the only thing that degrades as we go deeper is the Lipschitz constant, and crucially, **max operations don't amplify Lipschitz constants** (unlike addition, which does).

This is related to the **tropical semiring** from algebraic geometry, where max replaces addition and addition replaces multiplication. In this tropical world, the "sum" of Lipschitz constants is their maximum, not their arithmetic sum. This algebraic structure is what makes deep max-aggregation trees fundamentally more certifiable than deep additive networks.

The practical implication: for architectures built from max operations—which includes a surprising fraction of modern neural network components—our theorem provides a fast, guaranteed-correct way to compute how far you can perturb an input before the AI's decision changes. No sampling, no approximation, no hope—just a formally verified mathematical guarantee.

## 6. Applications

### 6.1 Ensemble Robustness

When combining $N$ classifiers via max-voting (each model votes with its confidence score, take the max across models for each class), our certificate applies directly. The Lipschitz constant is the maximum across models (not the sum), making the certificate tight.

### 6.2 Multi-Resolution Feature Aggregation

CNNs with max-pooling at multiple scales create exactly the tree structure we formalize. Our certificate propagates through the pooling hierarchy, giving per-resolution robustness information.

### 6.3 Attention-Adjacent Architectures

While softmax attention is not a pure max operation, hard attention and top-k attention are. Our framework certifies the robustness of architectures using these operations, providing a foundation for analyzing softer variants.

### 6.4 Dynamic Programming Networks

Networks that implement Viterbi-style decoding or shortest-path computations use max-plus operations. Our tropical certificate applies directly to these architectures.

## 7. Related Work

**Lipschitz-based certification** (Hein & Andriushchenko, 2017; Weng et al., 2018) bounds network sensitivity using global Lipschitz constants. Our work refines this by exploiting the compositional structure of max operations.

**Tropical geometry and neural networks** (Zhang et al., 2018; Alfarra et al., 2022) studies the tropical algebraic structure of ReLU networks. Our work extends this to hierarchical max-aggregation, formalizing the compositional certificate structure.

**Formal verification of neural networks** (Katz et al., 2017; Huang et al., 2017) uses SMT solvers or abstract interpretation. Our approach is complementary: we provide mathematical proofs of certificate validity, which can then be used to validate the output of automated verifiers.

## 8. Conclusion

We have presented and formally verified a compositional robustness certificate for hierarchical max-aggregation trees. The certificate exploits the tropical structure of max operations—specifically, that max preserves Lipschitz constants and that pairwise margins propagate monotonically through max-aggregation. The formal verification in Lean 4 provides the highest level of mathematical certainty for these guarantees.

The broader significance is methodological: tropical algebra provides a natural framework for reasoning about the robustness of piecewise-linear computations, and formal verification ensures that these guarantees are not merely plausible but provably correct. We expect this pattern—tropical certificates verified by theorem provers—to extend to more complex architectures including attention trees, dynamic programming layers, and mixed tropical-linear networks.

## References

- Alfarra, M., Bibi, A., Hammoud, H., Sabber, M., & Ghanem, B. (2022). On the decision boundaries of neural networks: A tropical geometry perspective.
- Hein, M., & Andriushchenko, M. (2017). Formal guarantees on the robustness of a classifier against adversarial manipulation.
- Huang, X., Kwiatkowska, M., Wang, S., & Wu, M. (2017). Safety verification of deep neural networks.
- Katz, G., Barrett, C., Dill, D. L., Julian, K., & Kochenderfer, M. J. (2017). Reluplex: An efficient SMT solver for verifying deep neural networks.
- Weng, T. W., Zhang, H., Chen, P. Y., Yi, J., Su, D., Gao, Y., Hsieh, C. J., & Daniel, L. (2018). Evaluating the robustness of neural networks: An extreme value theory approach.
- Zhang, L., Naitzat, G., & Lim, L. H. (2018). Tropical geometry of deep neural networks.
