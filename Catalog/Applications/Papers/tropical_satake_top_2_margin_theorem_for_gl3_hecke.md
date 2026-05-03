# Sharp Top-2 Robustness Certificates for GL₃ Tropical Satake Score Classifiers

## Abstract

We formalize and prove a sharp robustness theorem for top-2 label sets determined by score triples, motivated by tropical Satake classifiers for GL₃. The main result establishes that the top-2 label set—the pair of classes with the two highest scores—is stable under coordinatewise ε-perturbation of scores if and only if the minimum gap from the excluded class to each member of the top-2 pair exceeds 2ε. We prove that this threshold is exact: when the margin condition fails, an explicit ε-perturbation exists that destroys the top-2 set. We further show that max-plus linear score functions (the natural model for tropical Satake reconstructions) satisfy a 1-Lipschitz property, yielding concrete robustness certificates from test-family perturbation bounds. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

### The classification robustness problem

In multiclass classification, a model assigns scores to each class and selects the highest-scoring class as the prediction. A fundamental question is: how robust is this prediction to perturbations of the input? The classical argmax margin theorem states that if the gap between the highest and second-highest scores exceeds 2ε, then any ε-perturbation of the scores preserves the argmax.

But many applications require not just the top prediction, but the top *k* predictions. Medical diagnosis may identify the two most likely conditions; search engines return ranked lists; recommendation systems present sets of options. The robustness question for top-k sets is strictly subtler than for the argmax.

### Why top-2 for GL₃ is special

For three classes (n = 3) and k = 2, the top-2 set has a particularly clean characterization: it is uniquely determined if and only if there is a unique "bottom" class—a class whose score is strictly below both others. The robustness threshold is then governed not by the gap between the top two scores (which is irrelevant for top-2 stability), but by the gap between the excluded class and the *closer* member of the top-2 pair.

This is the first genuinely nontrivial case where the top-k robustness threshold differs qualitatively from the argmax threshold. For GL₃ tropical Satake classifiers—where scores are computed as max-plus linear forms on a finite family of test valuations—this gives an exact certification criterion.

### Contributions

1. **Unique top-2 characterization** (Theorem 3.1): A unique top-2 set for score triples exists if and only if there is a unique bottom class with positive margin to all others.

2. **Sharp stability theorem** (Theorem 4.1): The top-2 set is stable under ε-perturbation iff the minimum margin exceeds 2ε.

3. **Sharp converse** (Theorem 4.2): When the margin condition fails, an explicit counterperturbation is constructed.

4. **Max-plus 1-Lipschitz property** (Theorem 5.1): Max-plus linear scores change by at most η when test valuations change by at most η.

5. **Transfer theorem** (Theorem 5.2): Combining the stability theorem with the Lipschitz bound gives a concrete robustness certificate for tropical Satake classifiers.

All results are formalized in Lean 4 with Mathlib and verified without axioms beyond the standard `propext`, `Classical.choice`, and `Quot.sound`.

## 2. Definitions

### Score vectors and top-2 sets

Let x : Fin 3 → ℝ be a score vector assigning real-valued scores to three classes.

**Definition 2.1** (Top-2 Set). A set A ⊆ Fin 3 is a *top-2 set* for x if |A| = 2 and every member of A scores strictly above every non-member:

$$\text{IsTop2Set}(x, A) \iff |A| = 2 \;\wedge\; \forall\, i \in A,\; \forall\, j \notin A,\; x_j < x_i$$

**Definition 2.2** (Top-2 Stability). The score vector x is *top-2 stable at radius ε* if there exists a top-2 set A for x that remains a top-2 set for every y with ‖y − x‖_∞ ≤ ε:

$$\text{Top2Stable}(x, \varepsilon) \iff \exists A,\; \text{IsTop2Set}(x, A) \;\wedge\; \forall y,\; (\forall i,\; |y_i - x_i| \leq \varepsilon) \Rightarrow \text{IsTop2Set}(y, A)$$

### Max-plus scores

**Definition 2.3** (Max-Plus Score). Given weight sets W_i ⊆ ℕ × ℝ for each class i, the max-plus score is:

$$\text{MaxPlus}(W, v)_i = \max_{(t, w) \in W_i} (v_t + w)$$

This is the natural score function for tropical Satake reconstructions, where v represents test valuations and the weights W encode the tropical Hecke structure.

## 3. Unique Top-2 Characterization

**Theorem 3.1** (Unique Bottom Characterization). *A unique top-2 set exists if and only if there is a unique bottom class:*

$$(\exists!\, A,\; \text{IsTop2Set}(x, A)) \;\iff\; (\exists!\, c,\; \forall\, i \neq c,\; x_c < x_i)$$

*Proof sketch.* For the forward direction: if A is the unique top-2 set with |A| = 2 in Fin 3, its complement contains a unique element c, and the definition of IsTop2Set gives x_c < x_i for all i ∈ A. Uniqueness of c follows from uniqueness of A.

For the backward direction: given a unique bottom class c, the set A = Fin 3 \ {c} has cardinality 2 and satisfies IsTop2Set. Any other top-2 set B would exclude some element c' ≠ c satisfying the bottom property, contradicting uniqueness. □

**Theorem 3.2** (Positive Margin Characterization). *Equivalently:*

$$(\exists!\, A,\; \text{IsTop2Set}(x, A)) \;\iff\; (\exists\, c,\; \forall\, i \neq c,\; 0 < x_i - x_c)$$

Note the right-hand side uses ∃ (not ∃!), since a unique bottom class is equivalent to a class with positive margin to all others (uniqueness becomes automatic from the strict inequality).

## 4. Sharp Stability Theorem

### The key inequality

The following elementary lemma is the engine of the stability proof:

**Lemma 4.0** (Perturbed Order Preservation). *If 2ε < x_a − x_c, |y_a − x_a| ≤ ε, and |y_c − x_c| ≤ ε, then y_c < y_a.*

*Proof.* From the absolute value bounds: y_a ≥ x_a − ε and y_c ≤ x_c + ε. The margin condition gives x_a − ε > x_c + ε, hence y_a > y_c. □

### Sufficient condition

**Theorem 4.1** (Top-2 Stability). *If there exists a class c such that 2ε < x_i − x_c for all i ≠ c, then x is top-2 stable at radius ε.*

*Proof.* Let A = Fin 3 \ {c}. Then IsTop2Set(x, A) follows from the margin condition (which implies x_c < x_i). For any y with ‖y − x‖_∞ ≤ ε and any i ∈ A, Lemma 4.0 gives y_c < y_i, establishing IsTop2Set(y, A). □

### Sharp converse

**Theorem 4.2** (Counterperturbation). *If IsTop2Set(x, A) and there exist a ∈ A, c ∉ A with x_a − x_c ≤ 2ε, then there exists y with ‖y − x‖_∞ ≤ ε such that ¬IsTop2Set(y, A).*

*Proof.* Define the extremal perturbation:

$$y_i = \begin{cases} x_a - \varepsilon & \text{if } i = a \\ x_c + \varepsilon & \text{if } i = c \\ x_i & \text{otherwise} \end{cases}$$

Then ‖y − x‖_∞ ≤ ε and y_a − y_c = (x_a − x_c) − 2ε ≤ 0, so y_a ≤ y_c, contradicting the requirement y_c < y_a for IsTop2Set(y, A). □

**Remark.** The threshold 2ε is sharp in both directions: Theorem 4.1 guarantees stability when all margins exceed 2ε, and Theorem 4.2 constructs a counterexample when any single margin is at most 2ε. The factor of 2 arises because both the included and excluded scores can be perturbed adversarially by ε in opposite directions.

## 5. Max-Plus Transfer and Tropical Satake Application

### Lipschitz property

**Theorem 5.1** (Max-Plus 1-Lipschitz). *If ∀t ∈ T, |v_t − w_t| ≤ η, then for all i:*

$$|\text{MaxPlus}(W, v)_i - \text{MaxPlus}(W, w)_i| \leq \eta$$

*Proof.* Let p* = (t*, w*) be the maximizer for v, so MaxPlus(W, v)_i = v_{t*} + w*. Then:
- w_{t*} + w* ≤ MaxPlus(W, w)_i (since p* ∈ W_i)
- v_{t*} − w_{t*} ≤ |v_{t*} − w_{t*}| ≤ η (since t* ∈ T)

Hence MaxPlus(W, v)_i ≤ MaxPlus(W, w)_i + η. By symmetry, the reverse inequality holds. □

**Remark.** The Lipschitz constant is exactly 1, independent of the number of terms or weights. This is the tropical analogue of the fact that support functions of convex bodies are 1-Lipschitz.

### Robustness certificate

**Theorem 5.2** (Max-Plus Top-2 Robustness). *Under the hypotheses of Theorem 5.1, if there exists c with 2η < MaxPlus(W, v)_i − MaxPlus(W, v)_c for all i ≠ c, then the top-2 set is preserved under the perturbation v → w.*

*Proof.* By Theorem 5.1, |MaxPlus(W, v)_i − MaxPlus(W, w)_i| ≤ η for each i. This means the score vector MaxPlus(W, w) is an η-perturbation of MaxPlus(W, v). The margin condition 2η < margin then gives top-2 stability by Theorem 4.1. □

### Abstract Lipschitz transfer

We also provide an abstract version (Theorem 5.3 in the formalization) for any finite test-family score model with Lipschitz constant K: if the margin exceeds 2Kη, then the top-2 set is preserved. The max-plus case is K = 1.

## 6. Discussion: Making Robustness Certificates Tangible

### An everyday analogy

Imagine you're a judge ranking three figure skaters. You've decided skaters A and B are clearly better than skater C, and you want to report the "top two" to advance to finals. But your scoring has some uncertainty—each score might be off by up to ε points.

Our theorem says: if both A and B beat C by more than 2ε points, then no matter how the scoring errors shake out, A and B will still be the top two. The factor of 2 is because the worst case is when C's score is bumped up by ε while A's or B's is bumped down by ε.

Crucially, it doesn't matter how close A and B are to each other—their relative ranking is irrelevant for top-2 stability. What matters is how far each of them is from the third-place skater. This is fundamentally different from asking "who wins gold?"

### Why this matters for AI safety

Modern AI classifiers often need to report not just their top prediction, but a set of plausible hypotheses. A medical AI might say "the two most likely diagnoses are X and Y"—and it's critical that this set is robust to small perturbations of the input (noise, adversarial attacks, distribution shift).

Our theorem provides *exact* conditions for when a top-2 prediction is certifiably robust. The certificate is:
1. **Computable**: Given the score vector, check if the margin exceeds 2ε.
2. **Sharp**: The threshold cannot be improved—if the margin is insufficient, we construct an explicit attack.
3. **Composable**: For max-plus models, the score perturbation is bounded by the input perturbation, giving end-to-end certificates.

### The tropical geometry connection

The max-plus algebra (where addition is max and multiplication is +) is the foundation of tropical geometry. Tropical Satake reconstructions—used in the Langlands program and number theory—compute group-theoretic invariants as max-plus linear forms on test families.

Our theorem shows that the robustness analysis of these classifiers is itself tropical: the 1-Lipschitz property of max-plus scores is a tropical analogue of the Lipschitz property of support functions in convex geometry. The factor-of-2 threshold arises from the same "adversarial two-sided perturbation" geometry in both the classical and tropical settings.

### Connections to existing work

The argmax margin theorem (top-1 robustness) is classical in machine learning and has been formalized in various proof assistants. Our contribution extends this to top-k with a sharp converse, in the first nontrivial case (n = 3, k = 2).

The max-plus Lipschitz property is well-known in tropical convexity and optimal transport theory. Our contribution is connecting it to classification robustness and providing a complete formal verification.

### Future directions

1. **General n and k**: The framework should extend to arbitrary n-class top-k sets. The margin condition becomes: the (k+1)-th ordered score must be separated from the k-th by more than 2ε. The Fin 3 case serves as a blueprint.

2. **Structured tropical models**: For specific tropical Satake reconstructions (e.g., GL_n spherical functions), the Lipschitz constant may be smaller than 1 due to the group-theoretic structure. Tighter bounds would give stronger certificates.

3. **Probabilistic certificates**: When perturbations are random rather than adversarial, the certification threshold can be relaxed. Connecting to concentration inequalities for max-plus sums would give probabilistic robustness guarantees.

4. **Certified training**: Using the margin as a training objective could produce classifiers that are provably robust by construction, rather than being certified post hoc.

## 7. Formalization Details

The complete formalization is in `TropicalSatakeTop2Margin.lean`, consisting of approximately 280 lines of Lean 4 code. Key design decisions:

- **Explicit finite enumeration**: Rather than using abstract order-statistics machinery, we exploit the finiteness of Fin 3 through `fin_cases` and `decide` tactics. This makes proofs short and robust.

- **Separation of concerns**: The order-theoretic layer (Sections 3–4) is independent of the max-plus layer (Section 5). The transfer theorem composes them cleanly.

- **Sharp converse via explicit construction**: The counterperturbation in Theorem 4.2 is defined by a concrete function, avoiding any use of compactness or existence axioms beyond the standard Lean foundation.

All proofs compile against Lean 4.28.0 with Mathlib v4.28.0 and depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## References

The mathematical content draws on standard material in:

- Tropical geometry and max-plus algebra
- Multiclass classification robustness theory
- The Satake isomorphism and spherical functions for reductive groups

The formalization uses the Lean 4 theorem prover and the Mathlib mathematical library.
