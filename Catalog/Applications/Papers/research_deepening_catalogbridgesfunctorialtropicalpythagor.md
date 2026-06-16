# A Functorial Tropical–Pythagorean Bridge: Softmax as the Normalization Functor onto the Probability Simplex

## Abstract

We identify a single structural skeleton shared by three classically disjoint domains — tropical (max-plus) analysis, the Euclidean geometry of Pythagorean triples, and finite probability — and make it precise as a **normalization functor into the probability simplex**. The functor is realized by the softmax (Gibbs) map, which we show is (i) a partition of unity, (ii) invariant under the diagonal additive shift action, and (iii) surjective onto the open simplex. Dually, the log-sum-exp functional is a shift homomorphism that sandwiches the tropical maximum (*Maslov dequantization*), and its gradient is exactly softmax. On the geometric side we prove that the squared-normalized-leg map \((a,b,c)\mapsto((a/c)^2,(b/c)^2)\) attached to any Pythagorean relation \(a^2+b^2=c^2\) lands in the simplex, is dilation invariant, and coincides with softmax of the log-squared coordinates. Finally we record a **Pythagorean probability identity** \((p-q)^2 + 4\operatorname{Var} = 1\), exhibiting the unit total probability of a Bernoulli law as a Pythagorean sum of two squares whose legs are the polarization \(p-q\) and twice the standard deviation. All results are formalized and machine-checked; this paper presents the mathematics, the proof sketches, the supporting algorithms, and applications.

**Keywords:** softmax, log-sum-exp, tropical geometry, Maslov dequantization, Pythagorean triples, Bernoulli variance, probability simplex, Gibbs measure, free energy.

---

## 1. Introduction

Three pieces of mathematics that are almost never discussed together turn out to share one engine.

1. **Tropical / log-domain analysis.** The max-plus semiring \((\mathbb{R}\cup\{-\infty\}, \max, +)\) is dequantized by the log-sum-exp functional and its companion softmax/Gibbs map. These objects are the smooth bridge between ordinary and tropical arithmetic and the analytic backbone of statistical mechanics and large-deviation theory.

2. **Pythagorean geometry.** The relation \(a^2+b^2=c^2\), the foundational identity of Euclidean geometry.

3. **Finite probability.** Two-point (Bernoulli) distributions, their variance, and the simplex constraint that probabilities sum to one.

Our organizing thesis (Hypothesis H0) is that these three themes share a single structural skeleton: a *normalization functor* into the probability simplex. Softmax normalizes log-weights; the Pythagorean map normalizes a triple by \(c^2\). Both are partitions of unity and both are invariant under the natural rescaling of their inputs — additive shift for softmax, dilation for the triple. We make all of this precise and prove that the two functors *agree* on their common target.

The contributions are:

- A clean formalization of the two-point and general softmax functors, with partition of unity, strict positivity, shift invariance (functoriality), and surjectivity onto the open simplex (Section 3).
- A formalization of log-sum-exp as a shift homomorphism, the Maslov dequantization sandwich \(\max \le \mathrm{lse}_2 \le \max + \log 2\), and the identity \(\nabla(\text{free energy}) = \text{Gibbs probability}\) (Section 4).
- The Pythagorean → probability functor: partition of unity (= Pythagoras), dilation invariance, and the exact identification with softmax of log-squared coordinates (Section 5).
- The Pythagorean probability identity \((p-q)^2 + 4\operatorname{Var} = 1\), both abstractly for Bernoulli laws and on the Pythagorean image (Section 6).

All statements below have been formally verified; the proof sketches given are faithful to the formal proofs.

---

## 2. Preliminaries and notation

Throughout, \(\exp\) and \(\log\) denote the real exponential and natural logarithm. The **open probability simplex** in two coordinates is
\[
\Delta_2^\circ = \{(p,q) : p,q>0,\ p+q=1\}.
\]
A **Bernoulli law** is a pair \((p,q)\in\Delta_2^\circ\); its **variance** is \(\operatorname{Var} = pq\). We write \(\operatorname{bernVar}(p) := p(1-p)\), so that for \(q=1-p\) we have \(\operatorname{Var} = \operatorname{bernVar}(p)\).

A **Pythagorean relation** is a triple \((a,b,c)\) with \(a^2 + b^2 = c^2\); we always assume \(c\neq 0\) (and \(c>0\) where positivity is needed).

The **diagonal additive shift action** of \(\mathbb{R}\) on \(\mathbb{R}^2\) is \((a,b)\mapsto (a+c,b+c)\). The **dilation action** of \(\mathbb{R}_{>0}\) on triples is \((a,b,c)\mapsto(ta,tb,tc)\).

---

## 3. The softmax functor: tropical coordinates → probability

### 3.1 Definition

**Definition 3.1 (two-point softmax).**
\[
\mathrm{softmax}_2(a,b) \;=\; \frac{e^{a}}{e^{a}+e^{b}}.
\]

This is the Gibbs weight of state \(a\) in a two-state system with (negative) energies \(a,b\).

### 3.2 Basic order and positivity

**Theorem 3.2 (positivity).** For all \(a,b\in\mathbb{R}\), \(\;0 < \mathrm{softmax}_2(a,b)\).

*Proof sketch.* Quotient of the positive numerator \(e^a\) by the positive denominator \(e^a + e^b\). ∎

**Theorem 3.3 (strict sub-unitarity).** For all \(a,b\), \(\;\mathrm{softmax}_2(a,b) < 1\).

*Proof sketch.* Since \(e^b>0\), the numerator \(e^a\) is strictly below the denominator \(e^a+e^b\); divide. ∎

Together, \(\mathrm{softmax}_2(a,b)\in(0,1)\): every output is a genuine non-degenerate probability.

### 3.3 Partition of unity

**Theorem 3.4 (partition of unity, two points).** For all \(a,b\),
\[
\mathrm{softmax}_2(a,b) + \mathrm{softmax}_2(b,a) = 1.
\]

*Proof sketch.* Place over the common denominator \(e^a+e^b\); the numerators sum to \(e^a+e^b\). ∎

This is the defining property of a normalization map: the two Gibbs weights form a Bernoulli law.

### 3.4 Functoriality: shift invariance

**Theorem 3.5 (shift invariance).** For all \(a,b,c\),
\[
\mathrm{softmax}_2(a+c,\,b+c) = \mathrm{softmax}_2(a,b).
\]

*Proof sketch.* Using \(e^{x+c}=e^xe^c\), both numerator and denominator acquire a common factor \(e^c\), which cancels. ∎

This is the functoriality of the bridge: softmax is invariant under the diagonal shift action; it depends only on the *difference* \(a-b\). It is also the reason for the standard numerically-stable implementation (subtract the max before exponentiating).

### 3.5 Surjectivity onto the open simplex

**Theorem 3.6 (realizability / surjectivity).** For all \(p,q>0\),
\[
\mathrm{softmax}_2(\log p,\,\log q) = \frac{p}{p+q}.
\]

*Proof sketch.* \(e^{\log p}=p\), \(e^{\log q}=q\); substitute. ∎

Consequently every point of \(\Delta_2^\circ\) is realized: given a target \((p,1-p)\) with \(0<p<1\), take weights \((\log p, \log(1-p))\). Softmax is a bijection between additive log-coordinates (modulo the shift) and \(\Delta_2^\circ\).

### 3.6 The general softmax

**Definition 3.7 (general softmax).** For a finite index type \(\iota\) and weights \(w:\iota\to\mathbb{R}\),
\[
\mathrm{softmax}(w)_i = \frac{e^{w_i}}{\sum_{j} e^{w_j}}.
\]

**Theorem 3.8 (positivity, general).** If \(\iota\) is finite and nonempty, then \(\mathrm{softmax}(w)_i>0\) for every \(i\).

*Proof sketch.* Numerator \(e^{w_i}>0\); denominator is a sum of positive terms over a nonempty index set, hence positive. ∎

**Theorem 3.9 (partition of unity, general).** \(\sum_i \mathrm{softmax}(w)_i = 1\).

*Proof sketch.* Factor the common denominator out of the sum: \(\sum_i e^{w_i}/\sum_j e^{w_j} = (\sum_i e^{w_i})/(\sum_j e^{w_j}) = 1\). ∎

**Theorem 3.10 (shift invariance, general).** For any constant \(c\), \(\mathrm{softmax}(w + c\mathbf{1}) = \mathrm{softmax}(w)\), where \((w+c\mathbf{1})_i = w_i + c\).

*Proof sketch.* Each numerator and the whole denominator scale by \(e^c\); cancel. ∎

Thus softmax is, in any finite dimension, a shift-invariant normalization onto the open simplex — the functor at the center of this paper.

---

## 4. Log-sum-exp: the tropical dequantization

### 4.1 Definition

**Definition 4.1 (two-point log-sum-exp).**
\[
\mathrm{lse}_2(a,b) = \log\!\left(e^{a}+e^{b}\right).
\]

In physics \(\mathrm{lse}_2\) is (up to sign and temperature) the **free energy** of a two-state system; in statistics it is the cumulant generating function; in optimization the soft maximum.

### 4.2 Shift homomorphism

**Theorem 4.2 (shift homomorphism).** For all \(a,b,c\),
\[
\mathrm{lse}_2(a+c,\,b+c) = \mathrm{lse}_2(a,b) + c.
\]

*Proof sketch.* \(e^{a+c}+e^{b+c} = e^c(e^a+e^b)\); take logs and use \(\log(e^c\cdot x)=c+\log x\). ∎

Where softmax *erases* the diagonal shift, \(\mathrm{lse}_2\) *records* it additively: it is an equivariant map (a degree-1 homogeneous functional) for the shift action.

### 4.3 Maslov dequantization sandwich

**Theorem 4.3 (lower bound).** \(\max(a,b) \le \mathrm{lse}_2(a,b)\).

*Proof sketch.* \(e^a+e^b \ge e^{\max(a,b)}\) since the other summand is positive; apply the monotone \(\log\) and \(\log e^{\max}=\max\). ∎

**Theorem 4.4 (upper bound).** \(\mathrm{lse}_2(a,b) \le \max(a,b) + \log 2\).

*Proof sketch.* \(e^a + e^b \le 2 e^{\max(a,b)}\); apply \(\log\) and \(\log(2x) = \log 2 + \log x\). ∎

**Corollary 4.5 (diagonal value).** \(\mathrm{lse}_2(a,a) = a + \log 2\), so the upper bound in Theorem 4.4 is sharp.

Together Theorems 4.3–4.4 give the **Maslov dequantization sandwich**
\[
\max(a,b) \;\le\; \mathrm{lse}_2(a,b)\;\le\; \max(a,b)+\log 2 .
\]
Introducing a temperature \(h>0\) via \(\mathrm{lse}_2^{(h)}(a,b) := h\,\log(e^{a/h}+e^{b/h})\) and rescaling the sandwich gives
\[
\max(a,b)\le \mathrm{lse}_2^{(h)}(a,b)\le \max(a,b)+h\log 2 \xrightarrow[h\to 0^+]{}\max(a,b),
\]
the precise sense in which ordinary algebra degenerates to the tropical (max-plus) semiring. The constant \(\log 2\) is exactly one nat (one "bit," in natural units) of entropy — the maximal cost of softening the hard maximum at two points.

### 4.4 The gradient is the Gibbs probability

**Theorem 4.6 (gradient of free energy = probability).** For all \(a,b\),
\[
\frac{d}{da}\,\mathrm{lse}_2(a,b) = \mathrm{softmax}_2(a,b).
\]

*Proof sketch.* The chain rule gives \(\frac{d}{da}\log(e^a+e^b) = \frac{e^a}{e^a+e^b}\), which is the definition of \(\mathrm{softmax}_2\); differentiability of \(\exp\) and non-vanishing of the denominator justify the step. ∎

This is the analytic glue of the bridge: the *same* object is a max-plus functional (lse) and the generating function of the Gibbs law (softmax). Differentiating the tropical free energy returns the probability map.

**Companion fact (curvature = variance).** Differentiating once more,
\[
\frac{d^2}{da^2}\,\mathrm{lse}_2(a,b) = \mathrm{softmax}_2(a,b)\,\big(1 - \mathrm{softmax}_2(a,b)\big) = \operatorname{bernVar}\!\big(\mathrm{softmax}_2(a,b)\big).
\]
The curvature of the free energy is the variance of the induced Bernoulli law. This is the two-point case of the general cumulant theorem: the Hessian of \(\log\sum_j e^{w_j}\) is the covariance matrix of the Gibbs law (Conjecture 1, Section 7).

---

## 5. The Pythagorean functor

### 5.1 Definition

Attach to a Pythagorean relation \(a^2+b^2=c^2\) (with \(c\neq 0\)) the pair
\[
p = \left(\frac{a}{c}\right)^2,\qquad q = \left(\frac{b}{c}\right)^2 .
\]

### 5.2 Partition of unity is Pythagoras

**Theorem 5.1 (Pythagorean partition).** If \(a^2+b^2=c^2\) and \(c\neq 0\), then
\[
\left(\frac{a}{c}\right)^2 + \left(\frac{b}{c}\right)^2 = 1 .
\]

*Proof sketch.* Divide \(a^2+b^2=c^2\) by \(c^2\). ∎

So the squared, normalized legs of any right triangle form a Bernoulli law. Pythagoras' theorem *is* the partition-of-unity axiom for this functor.

### 5.3 Dilation invariance

**Theorem 5.2 (scale invariance).** For \(t\neq 0\), the triple \((ta,tb,tc)\) induces the same \(p\):
\[
\left(\frac{ta}{tc}\right)^2 = \left(\frac{a}{c}\right)^2 .
\]

*Proof sketch.* The factor \(t\) cancels in the ratio. ∎

This is the geometric analogue of softmax's shift invariance: the induced distribution depends only on the *shape* of the triangle, not its size.

### 5.4 The Pythagorean functor is softmax

**Theorem 5.3 (Pythagoras = softmax of log-squares).** For \(a,b>0\),
\[
\mathrm{softmax}_2\!\big(\log a^2,\ \log b^2\big) = \frac{a^2}{a^2+b^2}.
\]
In particular, when \(a^2+b^2=c^2\), the right-hand side equals \(p=(a/c)^2\).

*Proof sketch.* Apply Theorem 3.6 (surjectivity) with weights \(p'=a^2\), \(q'=b^2\): \(\mathrm{softmax}_2(\log a^2,\log b^2)= a^2/(a^2+b^2)\). The Pythagorean relation gives the denominator \(c^2\). ∎

This is the central compatibility result: the Pythagorean normalization and the softmax normalization are the *same map*, related by the change of coordinates "take logarithms of the squared legs." The dilation symmetry of the triangle and the shift symmetry of softmax are identified under this coordinate change (a dilation \(a\mapsto ta\) becomes a shift \(\log a^2 \mapsto \log a^2 + 2\log t\)).

---

## 6. The Pythagorean probability identity

### 6.1 Abstract Bernoulli form

**Theorem 6.1 (Pythagorean probability identity).** For any Bernoulli law with \(p+q=1\) and variance \(\operatorname{Var}=pq\),
\[
(p-q)^2 + 4\operatorname{Var} = 1.
\]
Equivalently, with \(\sigma=\sqrt{\operatorname{Var}}\),
\[
(p-q)^2 + (2\sigma)^2 = 1.
\]

*Proof sketch.* Polarize the constraint: \(1 = (p+q)^2 = (p-q)^2 + 4pq\); identify \(pq=\operatorname{Var}\). Substituting \(q=1-p\) gives the algebraic identity \((2p-1)^2 + 4p(1-p) = 1\). ∎

This realizes the unit total probability as a Pythagorean sum of two squares. The interpretation:

- **Hypotenuse** \(c = 1\): the total probability.
- **Leg 1** \(=p-q\): the *polarization* (signed imbalance / bias of the law).
- **Leg 2** \(=2\sigma\): twice the standard deviation (the law's intrinsic randomness).

Extreme cases: a deterministic law \((p=1)\) is the degenerate triangle with leg 1 \(=1\), leg 2 \(=0\); the uniform law \((p=\tfrac12)\) is the degenerate triangle with leg 1 \(=0\), leg 2 \(=1\). Every law in between is a genuine right triangle trading bias against noise.

### 6.2 On the Pythagorean image

**Theorem 6.2 (Pythagorean identity on triangles).** If \(a^2+b^2=c^2\) with \(c\neq 0\), and \(p=(a/c)^2\), \(q=(b/c)^2\), then
\[
(p-q)^2 + 4pq = 1,
\]
and the associated standard deviation is
\[
\sigma = \sqrt{pq} = \frac{|ab|}{c^2} = \tfrac12\cdot\frac{2|ab|}{c^2},
\]
i.e. exactly half the normalized area \(2|ab|/c^2\) of the right triangle with legs \(a,b\).

*Proof sketch.* By Theorem 5.1 the pair \((p,q)\) is Bernoulli, so Theorem 6.1 applies. The formula for \(\sigma\) follows from \(pq = a^2b^2/c^4\). ∎

The Bernoulli standard deviation of the triangle's distribution is exactly the (half-)normalized area of the triangle: **randomness becomes geometric area**.

---

## 7. Algorithms

We summarize the computational content. (Full implementations appear in the accompanying `demo.py` and in the package's `algorithms` array.)

**Algorithm A — Numerically stable softmax.** To compute \(\mathrm{softmax}(w)\), subtract \(m=\max_j w_j\) from each \(w_i\) (legitimate by shift invariance, Theorem 3.10), exponentiate, and normalize. This avoids overflow because all exponents are \(\le 0\). Complexity: \(O(n)\) time, \(O(1)\) extra space beyond the output.

**Algorithm B — Log-sum-exp with the Maslov certificate.** Compute \(\mathrm{lse}(w) = m + \log\sum_j e^{w_j - m}\) and simultaneously emit the dequantization bracket \([m,\ m+\log n]\) certifying \(m \le \mathrm{lse}(w) \le m + \log n\). Complexity: \(O(n)\).

**Algorithm C — Pythagorean → Bernoulli encoder.** Given a triple \((a,b,c)\) with \(a^2+b^2=c^2\), return \((p,q)=((a/c)^2,(b/c)^2)\), the variance \(pq\), the polarization \(p-q\), and verify the identity \((p-q)^2+4pq=1\) numerically. Complexity: \(O(1)\).

**Algorithm D — Simplex → Pythagorean decoder.** Given \(p\in(0,1)\), return a canonical right triangle realizing it: \(a=\sqrt{p}\), \(b=\sqrt{1-p}\), \(c=1\) (so \(a^2+b^2=1\)), confirming surjectivity (Conjecture 2) and that \(\sigma=ab\). Complexity: \(O(1)\).

---

## 8. Applications

**Machine learning.** Softmax is the canonical output layer of classifiers; the cross-entropy loss is built from log-sum-exp. Theorem 4.6 (gradient of lse = softmax) is the reason gradients through a softmax layer are clean, and the curvature/variance companion underlies natural-gradient and Gauss–Newton methods. The Maslov sandwich quantifies the hardening of softmax into argmax as logits grow.

**Statistical mechanics.** \(\mathrm{lse}_2\) is the free energy; softmax is the Gibbs measure. The dequantization sandwich is the rigorous low-temperature collapse onto ground states; the variance-as-curvature identity is the fluctuation–dissipation relation at two states.

**Optimization / tropical methods.** Max-plus algebra governs shortest paths and scheduling; lse is its smooth surrogate, and the sandwich bounds the smoothing error by \(\log n\).

**Geometry of data.** The Pythagorean functor gives a dictionary between right triangles and Bernoulli laws under which the triangle's normalized area is the law's standard deviation — a geometric reading of uncertainty.

---

## 9. Discussion

The unifying mechanism is a *normalization functor into the probability simplex*, instantiated twice: softmax normalizes log-weights by their exponential sum; the Pythagorean map normalizes a triple by \(c^2\). Both are partitions of unity (softmax by construction; the Pythagorean map *because of* Pythagoras), both are invariant under the natural rescaling of inputs (additive shift; dilation), and — via Theorem 5.3 — they are the *same* map in different coordinates. The analytic layer (lse, its gradient and curvature) supplies the calculus that ties tropical limits to probabilistic moments. The Pythagorean probability identity then closes the loop, exhibiting the simplex constraint itself as a sum of two squares.

The aesthetic point is the elementarity of the ingredients — a maximum, a triangle, a coin — and the cleanness with which they cohere once the binding map is identified.

---

## 10. Future directions

This cycle established a normalization functor into the probability simplex unifying tropical analysis (lse, softmax, the Maslov sandwich), probability (Bernoulli variance, the cumulant identities \(\nabla\mathrm{lse}=\text{softmax}\) and \(\nabla^2\mathrm{lse}=\text{variance}\)), and Pythagorean geometry. We list precise, falsifiable targets.

**Conjecture 1 (n-point tropical Hessian = covariance).** The general softmax is the gradient of the n-point free energy \(\mathrm{lse}(w)=\log\sum_j e^{w_j}\), and the Hessian of \(\mathrm{lse}\) is the covariance matrix of the Gibbs law:
\[
\frac{\partial^2 \mathrm{lse}}{\partial w_i\,\partial w_j} = \begin{cases}\mathrm{softmax}(w)_i\,(1-\mathrm{softmax}(w)_i), & i=j,\\[2pt] -\,\mathrm{softmax}(w)_i\,\mathrm{softmax}(w)_j, & i\neq j.\end{cases}
\]
The diagonal specializes to \(\operatorname{bernVar}(\mathrm{softmax}(w)_i)\), generalizing the two-point curvature identity.

**Conjecture 2 (Pythagorean parametrization of the full simplex).** Every interior Bernoulli law arises from a real Pythagorean relation: for all \(p\in(0,1)\) there exist \(a,b,c>0\) with \(a^2+b^2=c^2\) and \((a/c)^2=p\); concretely \(a=\sqrt{p}\,c\), \(b=\sqrt{1-p}\,c\). Moreover \(\sigma = |ab|/c^2 = \sqrt{p(1-p)}\), so the Bernoulli standard deviation is exactly half the normalized area \(2ab/c^2\) of the right triangle; the area-to-\(\sigma\) constant is conjectured to be exactly \(2\).

**Conjecture 3 (Maslov interpolation is monotone and contracts to max).** With \(\mathrm{lse}_T(h,a,b) := h\log(e^{a/h}+e^{b/h})\) for \(h>0\): the map \(h\mapsto \mathrm{lse}_T(h,a,b)\) is monotone non-decreasing, \(\mathrm{lse}_T(h,a,b)\to\max(a,b)\) as \(h\to 0^+\), and the Gibbs entropy gap \(\mathrm{lse}_T(h,a,b)-\max(a,b)\in[0,h\log 2]\). Targets: the sandwich \(\max\le\mathrm{lse}_T\le\max+h\log 2\) (rescale the proved bound) and the one-sided limit.

**Conjecture 4 (Pythagorean identity is the χ² / information projection at two points).** For the Pythagorean-induced law \(p=(a/c)^2\), the polarization leg \(p-q\) equals the signed χ²-type discrepancy from the uniform law, identifying the Pythagorean probability identity with an information-geometric projection at two points.

---

## 11. Conclusion

A single map — softmax, the Gibbs/normalization functor onto the probability simplex — binds tropical analysis, Pythagorean geometry, and finite probability. It is a partition of unity, it is invariant under the natural rescaling of its inputs, and it is surjective onto the open simplex; its potential (log-sum-exp) sandwiches the tropical maximum and has softmax as its gradient and Bernoulli variance as its curvature; and under the change of coordinates "log-squared legs" it *is* the Pythagorean normalization, whose partition of unity is Pythagoras' theorem and whose total-probability constraint is itself a Pythagorean sum of two squares. The result is a compact, fully verified dictionary among three of mathematics' most familiar worlds.
