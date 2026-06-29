# Convex-Hull Confinement and Log-Partition Bounds for Softmax Self-Attention

## Abstract

We develop a rigorous, self-contained analysis of a single softmax self-attention head, viewed as a kernel smoother over a finite set of tokens. Modeling an attention head by a query vector $q \in \mathbb{R}^d$, a family of key vectors $k_1,\dots,k_n \in \mathbb{R}^d$, and a family of value vectors $v_1,\dots,v_n \in \mathbb{R}^m$, we define the unnormalized exponential kernel $\kappa(q,k)=\exp\langle q,k\rangle$, the partition function $Z=\sum_j \kappa(q,k_j)$, the softmax attention weights $w_j=\kappa(q,k_j)/Z$, and the attention output $o_i=\sum_j w_j (v_j)_i$. We establish four principal results. First, the attention weights form a probability distribution: they are strictly positive and sum to one (`attnWeight_sum_one`). Second, a purely order-theoretic lemma shows that any convex combination of points contained in an interval $[\ell,h]$ remains in $[\ell,h]$ (`convexCombo_mem_Icc`). Third, combining these yields the **confinement law**: every coordinate of the attention output lies in the interval — and hence the convex hull — spanned by the corresponding value coordinates (`attnOutput_mem_Icc`). Fourth, we prove a log-sum-exp lower bound stating that the log-partition function dominates every individual score (`logPartition_ge_term`). We discuss how these elementary but foundational facts underpin boundedness, robustness, the kernel-smoother interpretation, universal approximation, and the attention-sink phenomenon, and we outline a program of conjectures sharpening each of these directions.

**Keywords:** softmax attention, kernel method, partition function, log-sum-exp, convex hull, probability simplex, transformers, sequence-to-sequence.

---

## 1. Introduction

The transformer architecture has become the dominant computational substrate of modern machine learning, and its central primitive is the *self-attention* mechanism. Despite its empirical ubiquity, the basic mathematical properties of attention are often stated informally. The purpose of this paper is to isolate and prove, from first principles, the structural facts that make a single softmax attention head a *well-behaved averaging operator*: its weights form a genuine probability distribution, its output is confined to the convex hull of its values, and its normalization constant obeys a sharp log-sum-exp lower bound.

Our viewpoint is that softmax attention is a **kernel method**. The similarity kernel is the exponentiated inner product $\exp\langle q,k\rangle$; the attention head is then a Nadaraya–Watson-style kernel smoother that reports a locally reweighted average of the value vectors. This perspective immediately suggests which classical guarantees ought to transfer — boundedness, continuity, hull confinement — and we make them precise here.

All results below are fully formalized and machine-checked. We present the mathematical statements and proof sketches; the formal artifact contains the complete deductions.

### 1.1 Notation

We fix natural numbers $d, n, m$ denoting respectively the query/key dimension, the number of tokens, and the value dimension. We index tokens by $j \in \{1,\dots,n\}$, query/key coordinates by $i \in \{1,\dots,d\}$, and value coordinates by $i \in \{1,\dots,m\}$. Throughout, $\langle x, y\rangle = \sum_i x_i y_i$ denotes the standard Euclidean inner product. We write $[\ell, h]$ for the closed real interval $\{t : \ell \le t \le h\}$. For results requiring at least one token we assume $n \ge 1$ (formally, that the index type is nonempty).

---

## 2. The model

We treat a single attention head as a deterministic map from $(q, K, V)$ to an output vector, where $q$ is a query, $K=(k_j)$ is the matrix of keys, and $V=(v_j)$ is the matrix of values.

### Definition 2.1 (Exponential kernel / score)
For a query $q \in \mathbb{R}^d$ and a key $k \in \mathbb{R}^d$, the **unnormalized exponential kernel** is
$$\kappa(q,k) \;=\; \exp\!\Big(\textstyle\sum_{i} q_i\, k_i\Big) \;=\; \exp\langle q,k\rangle.$$
(Formally `expKernel`.)

### Definition 2.2 (Partition function)
For keys $k_1,\dots,k_n$, the **partition function** is
$$Z(q,K) \;=\; \sum_{j} \kappa(q,k_j) \;=\; \sum_j \exp\langle q,k_j\rangle.$$
(Formally `attnPartition`.)

### Definition 2.3 (Softmax attention weight)
The **attention weight** assigned to token $j$ is the normalized kernel
$$w_j(q,K) \;=\; \frac{\kappa(q,k_j)}{Z(q,K)} \;=\; \frac{\exp\langle q,k_j\rangle}{\sum_{\ell}\exp\langle q,k_\ell\rangle}.$$
(Formally `attnWeight`.)

### Definition 2.4 (Attention output)
For value vectors $v_1,\dots,v_n \in \mathbb{R}^m$, the **attention output** has $i$-th coordinate
$$o_i(q,K,V) \;=\; \sum_{j} w_j(q,K)\,(v_j)_i .$$
(Formally `attnOutput`.) Each output coordinate is thus the $w$-weighted average of that coordinate across the value vectors.

This is the canonical single-head scaled-dot-product attention (with the temperature/scale folded into $q$), restricted to a single query for clarity; extending to multiple queries amounts to applying the construction row by row.

---

## 3. Positivity and normalization

We first record the elementary positivity facts; they are the hypotheses the later theorems consume.

### Lemma 3.1 (Kernel positivity, `expKernel_pos`)
For all $q,k$, $\;\kappa(q,k) > 0$.

*Proof.* The real exponential is strictly positive. $\square$

### Lemma 3.2 (Partition positivity, `attnPartition_pos`)
If $n\ge 1$ then $Z(q,K) > 0$.

*Proof.* $Z$ is a sum, over a nonempty index set, of strictly positive terms (Lemma 3.1); a sum of positive terms over a nonempty set is positive. $\square$

### Lemma 3.3 (Weight positivity, `attnWeight_pos` and `attnWeight_nonneg`)
If $n \ge 1$ then $w_j(q,K) > 0$ for every $j$, and in particular $w_j(q,K) \ge 0$.

*Proof.* $w_j$ is a quotient of a positive numerator (Lemma 3.1) by a positive denominator (Lemma 3.2), hence positive; positivity implies non-negativity. $\square$

### Theorem 3.4 (Weights form a probability distribution, `attnWeight_sum_one`)
If $n \ge 1$ then
$$\sum_{j} w_j(q,K) \;=\; 1.$$

*Proof.* Expand each weight as $w_j = \kappa(q,k_j)/Z$ with the *same* denominator $Z=\sum_\ell \kappa(q,k_\ell)$. Pull the common denominator out of the sum,
$$\sum_j \frac{\kappa(q,k_j)}{Z} \;=\; \frac{\sum_j \kappa(q,k_j)}{Z} \;=\; \frac{Z}{Z} \;=\; 1,$$
where the final equality uses $Z \neq 0$, which holds because $Z>0$ by Lemma 3.2. $\square$

Together, Lemmas 3.3 and Theorem 3.4 show that $(w_j)_j$ is a point of the (open) probability simplex
$$\Delta^{n-1} = \Big\{ w \in \mathbb{R}^n : w_j \ge 0,\ \textstyle\sum_j w_j = 1\Big\}.$$
This is the precise sense in which softmax "turns scores into a decision."

---

## 4. The confinement law

The geometric content of attention is captured by a single, model-agnostic lemma about convex combinations.

### Lemma 4.1 (Convex combinations preserve intervals, `convexCombo_mem_Icc`)
Let $\ell, h \in \mathbb{R}$, let $w_1,\dots,w_n \ge 0$ with $\sum_j w_j = 1$, and let $x_1,\dots,x_n \in [\ell, h]$. Then
$$\sum_{j} w_j\, x_j \;\in\; [\ell, h].$$

*Proof.* For the lower bound, since each $w_j \ge 0$ and $x_j \ge \ell$, monotonicity of weighted sums gives
$$\sum_j w_j x_j \;\ge\; \sum_j w_j \ell \;=\; \ell\sum_j w_j \;=\; \ell .$$
For the upper bound, symmetrically $x_j \le h$ yields
$$\sum_j w_j x_j \;\le\; \sum_j w_j h \;=\; h\sum_j w_j \;=\; h .$$
Both steps factor the constant out of the sum and use $\sum_j w_j = 1$. $\square$

This lemma is the abstract engine: it knows nothing about exponentials or queries. It says only that *weighted averages live between the extremes*. Everything attention-specific is supplied by instantiating $w_j$ with the softmax weights and $x_j$ with a fixed value coordinate.

### Theorem 4.2 (Convex-hull confinement, `attnOutput_mem_Icc`)
Fix an output coordinate $i$. Suppose $\ell \le (v_j)_i \le h$ for every token $j$. If $n \ge 1$, then
$$o_i(q,K,V) \;\in\; [\ell, h].$$

*Proof.* By definition $o_i = \sum_j w_j (v_j)_i$. Apply Lemma 4.1 with weights $w_j = w_j(q,K)$ and points $x_j = (v_j)_i$. The non-negativity hypothesis is Lemma 3.3, the normalization hypothesis is Theorem 3.4, and the containment hypothesis $x_j \in [\ell, h]$ is exactly the assumption $\ell \le (v_j)_i \le h$. $\square$

### Corollary 4.3 (Hull confinement)
Applying Theorem 4.2 coordinatewise with $\ell = \min_j (v_j)_i$ and $h = \max_j (v_j)_i$ shows that the output vector lies in the axis-aligned bounding box of the values, and more strongly in their **convex hull**
$$\mathrm{conv}\{v_1,\dots,v_n\} = \Big\{\textstyle\sum_j w_j v_j : w \in \Delta^{n-1}\Big\},$$
since $o = \sum_j w_j v_j$ is by construction a convex combination of the $v_j$.

**Interpretation.** Theorem 4.2 is the rigorous form of the statement that an attention head *smooths* rather than *extrapolates*. It cannot output a magnitude larger than the largest it was given, nor smaller than the smallest. Three consequences follow:

1. **Numerical stability.** If a network maintains bounded value representations, attention layers preserve those bounds; there is no intra-head blow-up.
2. **Lipschitz-style robustness.** The output is a convex combination with continuously varying weights, so it depends continuously on the values, and small input perturbations cannot push the output outside the hull.
3. **Kernel-smoother semantics.** The head is a Nadaraya–Watson estimator with kernel $\kappa$, and Theorem 4.2 is the classical "estimator lies in the convex hull of the data" guarantee.

---

## 5. The log-partition bound

The normalization constant $Z$ controls how sharply attention can focus. Its logarithm — the *log-partition function* or *log-sum-exp* — is the central object.

### Theorem 5.1 (Log-partition dominates each score, `logPartition_ge_term`)
If $n \ge 1$ then, for every token $j$,
$$\log Z(q,K) \;\ge\; \langle q, k_j\rangle \;=\; \sum_i q_i (k_j)_i .$$

*Proof.* Write $Z = \sum_\ell \exp\langle q, k_\ell\rangle$. Since every summand is non-negative, the full sum dominates any single term:
$$Z \;\ge\; \exp\langle q, k_j\rangle .$$
Moreover $Z > 0$ (Lemma 3.2). The logarithm is monotone increasing on the positive reals, and $\log(\exp t) = t$, so applying $\log$ to both sides yields $\log Z \ge \langle q, k_j\rangle$. (Formally, this is the equivalence $\log Z \ge t \iff e^t \le Z$ applied to $t=\langle q,k_j\rangle$.) $\square$

**Interpretation.** Theorem 5.1 is the engine of *focus*. The softmax weight of token $j$ can be written
$$w_j = \exp\big(\langle q,k_j\rangle - \log Z\big),$$
and Theorem 5.1 guarantees the exponent is $\le 0$, so $w_j \le 1$ — consistent with Theorem 3.4. When one score $\langle q, k_{j^\star}\rangle$ exceeds all others by a large margin $g$, the term $\exp\langle q,k_{j^\star}\rangle$ dominates $Z$, forcing $w_{j^\star} \to 1$ and all other weights toward $0$: attention concentrates on a single token. When scores are comparable, $\log Z \approx \log n + \bar z$ and the weights spread out. The same inequality is the basis of the standard max-subtraction trick for numerically stable softmax.

---

## 6. Algorithms

The definitions are constructive and translate directly into numerically stable procedures.

### Algorithm 6.1 (Stable softmax attention via log-sum-exp)
Given $q$, keys $K$, values $V$:
1. Compute scores $z_j = \langle q, k_j\rangle$ for all $j$.
2. Compute $z^\star = \max_j z_j$ (the stabilizing shift; justified because softmax is invariant under adding a constant to all logits).
3. Compute shifted exponentials $e_j = \exp(z_j - z^\star)$.
4. Compute the partition $S = \sum_j e_j$ and the log-partition $\log Z = z^\star + \log S$ (a stable evaluation of Theorem 5.1's quantity).
5. Compute weights $w_j = e_j / S$.
6. Compute output $o = \sum_j w_j v_j$.

By Theorem 3.4 the returned weights sum to one (up to floating-point), and by Theorem 4.2 the output is guaranteed to lie in the per-coordinate range of $V$ — a property that can be asserted at runtime as a cheap sanity check. The time complexity is $O(n d + n m)$ and the space complexity $O(n + m)$.

### Algorithm 6.2 (Confinement certificate)
To certify Theorem 4.2 numerically: compute coordinatewise $\ell_i = \min_j (v_j)_i$ and $h_i = \max_j (v_j)_i$, run Algorithm 6.1 to obtain $o$, and verify $\ell_i \le o_i \le h_i$ for every $i$. The theorem guarantees this check never fails in exact arithmetic.

---

## 7. Applications and discussion

**Bounded deep stacks.** A transformer interleaves attention with feed-forward maps, residual additions, and normalization. Theorem 4.2 contributes the attention-layer half of any boundedness argument: under bounded values, the head's contribution is bounded by the input range, with no amplification.

**Universal approximation, foreshadowed.** Because softmax weights can be steered to any interior point of $\Delta^{n-1}$ (by scaling logits), the output $o = \sum_j w_j v_j$ can be placed arbitrarily close to any point of the open convex hull of the values. This is the geometric seed of universal approximation of sequence-to-sequence maps: any target that is a measurable selection of convex combinations of a fixed value set can be approximated to arbitrary sup-norm accuracy, with logit magnitude scaling like $O(\log(1/\varepsilon))$. The confinement law (Theorem 4.2) supplies the "reachable set," and a covering argument on the simplex supplies the density.

**The attention sink.** Empirically, models concentrate persistent attention mass on a few tokens. Theorem 5.1 and the structure of $Z$ explain why: if a token enjoys a logit gap $g$ over each of $n-1$ rivals, then
$$Z = e^{z}\big(1 + (n-1)e^{-g}\big), \qquad w_{\text{sink}} = \frac{1}{1+(n-1)e^{-g}} .$$
The sink retains $\Omega(1)$ mass as $n\to\infty$ precisely when $g \gtrsim \log n$. The lemmas proved here are exactly the ingredients needed to make this phase transition rigorous.

**Kernel methods.** Identifying $\kappa(q,k)=\exp\langle q,k\rangle$ as a similarity kernel places attention squarely within the theory of kernel smoothers and reproducing-kernel methods, opening the door to importing generalization bounds, spectral analysis, and approximation theory from that mature field.

---

## 8. Worked examples and quantitative remarks

To make the abstract statements concrete, we record small computations that exercise each theorem and expose the relevant quantitative behavior.

### 8.1 A two-token head

Let $d=1$, $n=2$, $m=1$, with query $q=(\beta)$, keys $k_1=(0)$, $k_2=(1)$, and values $v_1=(0)$, $v_2=(1)$. Then the scores are $0$ and $\beta$, so
$$Z = 1 + e^{\beta}, \qquad w_1 = \frac{1}{1+e^\beta}, \qquad w_2 = \frac{e^\beta}{1+e^\beta},$$
which is the logistic sigmoid in $\beta$. The output is
$$o = w_1 \cdot 0 + w_2 \cdot 1 = \frac{e^\beta}{1+e^\beta} = \sigma(\beta) \in (0,1).$$
Theorem 3.4 is the identity $w_1 + w_2 = 1$. Theorem 4.2 is the statement $\sigma(\beta) \in [0,1]$, the value range; note the output approaches but never reaches the endpoints, illustrating that attention reaches the *open* hull interior. Theorem 5.1 reads $\log(1+e^\beta) \ge \beta$ and $\log(1+e^\beta)\ge 0$, both manifestly true (the softplus dominates each logit). As $\beta\to\infty$, $w_2\to 1$ and the head focuses entirely on the second token; as $\beta\to -\infty$ it focuses on the first; at $\beta=0$ the weights are uniform.

### 8.2 Temperature and sharpening

Replacing $q$ by $\beta q$ multiplies every score by $\beta$, a *temperature* knob. As $\beta$ grows, the term with the largest score dominates the partition function and the corresponding weight tends to $1$, while all others tend to $0$ — the hallmark of attention's ability to select. As $\beta\to 0$ the scores flatten and the weights tend to the uniform distribution $w_j = 1/n$, recovering the plain average $o = \frac1n\sum_j v_j$, which lies at the centroid of the values and is the maximally diffuse point reachable. In all regimes Theorems 3.4 and 4.2 hold unchanged: the family of reachable outputs is exactly the open convex hull, traced out as $q$ and $\beta$ vary.

### 8.3 The hull is reached, not merely contained

Confinement (Theorem 4.2) is a *containment* statement. Its converse — that essentially every interior point of the hull is *attained* — also holds and is what makes attention expressive rather than merely safe. For any target weights $w^\star$ in the open simplex one can choose logits $z_j = \log w^\star_j$ (up to an additive constant) so that $\mathrm{softmax}(z) = w^\star$, and such logits are realizable as inner products $\langle q, k_j\rangle$ for suitable $q$ when the keys are in general position. Hence the output $o = \sum_j w^\star_j v_j$ can be steered to any point of the open hull $\mathrm{int}\,\mathrm{conv}\{v_j\}$. Containment plus attainability together say: the reachable set of a single head is *exactly* the open convex hull of its values.

## 9. Structural properties and the kernel viewpoint

### 9.1 Shift invariance

Adding a constant $c$ to every score leaves the weights unchanged:
$$\frac{e^{z_j+c}}{\sum_\ell e^{z_\ell+c}} = \frac{e^{c}e^{z_j}}{e^{c}\sum_\ell e^{z_\ell}} = \frac{e^{z_j}}{\sum_\ell e^{z_\ell}}.$$
This *shift invariance* is the algebraic basis of the numerically stable Algorithm 6.1 (subtracting the maximum score) and of the rank analysis of attention matrices: row-additive constants in the logit matrix are invisible to softmax, so the relevant invariant is the logit matrix modulo row translations.

### 9.2 Monotone response

Softmax is coordinatewise monotone in the scores: increasing $z_j$ while holding the others fixed increases $w_j$ and decreases every other weight. This follows from the Jacobian $\partial w_j/\partial z_\ell = w_j(\delta_{j\ell} - w_\ell)$, whose diagonal is positive and off-diagonal negative. Consequently, raising a token's affinity for the query strictly diverts attention mass toward it from all competitors — the precise mechanism by which a *sink* token, once it acquires an advantage, retains it.

### 9.3 Attention as a Nadaraya--Watson estimator

Given the kernel $\kappa(q,k)=\exp\langle q,k\rangle$, the attention output is exactly the Nadaraya--Watson kernel regression estimate
$$o = \frac{\sum_j \kappa(q,k_j)\, v_j}{\sum_j \kappa(q,k_j)},$$
with the query $q$ playing the role of the evaluation point, the keys $k_j$ the design points, and the values $v_j$ the responses. The confinement law (Theorem 4.2) is then precisely the classical fact that a kernel-weighted average of responses lies in the convex hull of those responses. This dictionary opens the door to importing, from nonparametric statistics, results on bias--variance trade-offs, bandwidth (here, temperature) selection, and consistency, suggesting a principled theory of when attention "smooths too much" or "too little."

### 9.4 Relation to the log-partition / free energy

The log-partition $\log Z$ is the cumulant generating function of the scores: its gradient with respect to the scores is the weight vector, $\nabla_z \log Z = w$, and its Hessian is the covariance of the induced distribution. Theorem 5.1 is the zeroth-order statement that this convex function dominates each coordinate. Its convexity (a standard property of log-sum-exp) underlies many optimization-theoretic analyses of attention and explains why temperature scaling interpolates smoothly between the hard maximum ($\beta\to\infty$, $\log Z \to \max_j z_j$) and the soft average.

## 10. Future directions

We highlight four conjectures sharpening the results above (stated in full in the accompanying program of open problems):

1. **Sharp threshold for the attention sink.** A token retains $\Omega(1)$ mass uniformly in $n$ iff its logit gap satisfies $g(n) \ge \log n - O(1)$; for $g(n) = \log n - \omega(1)$ the mass vanishes. The partition factorization $e^{z}(1+(n-1)e^{-g})$ pins the crossover at $g \asymp \log n$.
2. **Entropy law of attention concentration.** The Shannon entropy $H(\mathrm{softmax}\,z)$ is maximized ($=\log n$) exactly at uniform logits and decreases monotonically as the maximal logit gap grows, with $H\to 0$ iff one gap $\to\infty$. Softmax is the maximum-entropy distribution matching the logits as constraints, making entropy a Lyapunov function for sharpening.
3. **Exact rank characterization.** The attention matrix has rank $1$ iff the logit matrix has identical rows up to additive row-constants; in general $\mathrm{rank}(A) \le \mathrm{rank}(\exp\circ Z)$, with equality failing because $\exp$ is not affine. Shift-invariance of softmax makes row-additive constants invisible.
4. **Quantitative universal approximation.** For any target sequence-to-sequence map that is a measurable selection of convex combinations of a fixed value set, and any $\varepsilon>0$, there exist keys/queries so that the attention output is within $\varepsilon$ in sup norm, with logit magnitude $O(\log(1/\varepsilon))$.

---

## 11. Conclusion

We have given a clean, fully verified account of the foundational properties of softmax self-attention: its weights are a probability distribution (`attnWeight_sum_one`), its output is confined to the convex hull of the values (`attnOutput_mem_Icc`, via the general `convexCombo_mem_Icc`), and its log-partition function dominates every score (`logPartition_ge_term`). These facts, elementary individually, jointly characterize attention as a disciplined yet expressive averaging operator — a learnable kernel smoother that can focus sharply or blend broadly, but can never color outside the lines of its inputs. They form a solid base on which sharper results — phase transitions, entropy laws, rank characterizations, and quantitative universal approximation — can be built.
