# The Algebra of Role-Asymmetric Attention-Cache Quantisation

**Author:** Aristotle
**Date:** 2026-08-27

---

## Abstract

An attention cache stores two tensors per position: a *key*, which enters the attention map
through the exponential of an inner product with the query, and a *value*, which enters
linearly inside a convex combination. We show that this structural difference — and nothing
about any particular network, dataset, or quantisation format — forces a severe asymmetry in
how the two tensors tolerate reduced numerical precision.

On the value side we prove an exact stability result: a perturbation of magnitude
$\varepsilon$ in the stored values moves the attention output by at most $\varepsilon$,
independently of dimension, sequence length, query, and value magnitude. The value response
exponent is therefore exactly $1$: distortion merely doubles per lost bit.

On the key side we prove three complementary results. First, an upper bound that is tight:
a logit perturbation of size $\varepsilon$ inflates each softmax weight by at most
$e^{2\varepsilon}$, and this factor is attained, because a logit shift translates the
softmax log-odds *exactly*. Second, a *lower* bound: if the key perturbation exceeds the
top-two logit gap, the softmax ranking inverts, and the attention output error is bounded
below by $\tfrac12 - 1/(1+e^{2h})$, an order-$1$ quantity depending only on the overshoot
$2h$ past the gap, not on the noise magnitude. Third, a sharpness result in bit width:
with noise halving per bit, at most one bit width can lie in the critical band $[g/2, g)$,
so a gap-threshold mechanism confines the free-to-broken transition to one or two bit
widths.

We confront these laws with a controlled measurement (perplexity on a held-out text slice,
context length $2048$): keys at $8$ bits with values at raw $4$ bits give $+0.142\%$
degradation, while both tensors at $5$ bits give $+867.694\%$. Two model classes are
refuted outright by these two numbers. Any law multiplicative in bit width, $D(b) = c/K^b$,
must have per-bit shrink base $K > 18$; in particular the uniform-quantiser step law
$c\cdot 2^{-b}$ is impossible. Any power-law response $c\,(R/2^b)^{\gamma}$ must have
$\gamma \ge 5$, and $\gamma = 5$ is attained. Since the value exponent is exactly $1$, the
two cache roles are separated by a **response-exponent gap of at least $4$**. We further
close the most natural escape route: composing $L$ layers of gain $\lambda$ multiplies the
prefactor by $\sum_{i<L}\lambda^i$ but leaves the response exponent unchanged, so depth
cannot manufacture a cliff. Finally we derive the design consequence: at identical memory,
a key-rich split strictly dominates a uniform split, which is the theorem behind the
serving configuration *keys at $8$ bits, values at $4$*.

**Keywords:** attention, softmax, quantisation, convexity, Lipschitz stability, response
exponent, argmax threshold, bit allocation.

---

## 1. Introduction

### 1.1 The problem

In autoregressive attention, each processed position contributes two cached tensors. On
long contexts the cache dominates memory consumption, so it is routinely stored at reduced
precision. Because keys and values are both simply arrays of reals, the default engineering
instinct is to compress them symmetrically.

That instinct is measurably wrong. In the controlled cell that motivates this paper —
perplexity of a fixed model on a held-out text slice, context length $2048$, all other
settings identical across arms — two configurations behave as follows relative to a
full-precision control:

| Configuration | Perplexity | Degradation vs. control |
|---|---|---|
| Keys $8$ bits, values raw $4$ bits (≈ $6$ average bits/element) | $7.1194$ | $+0.142\%$ |
| Keys $5$ bits, values $5$ bits | $68.7963$ | $+867.694\%$ |

At $4$-bit keys the degradation exceeds $+38{,}000\%$. Values, by contrast, remain free at
every width tested, down to raw $4$ bits. The key floor is therefore bracketed in the
interval $(5, 8]$; the format ladder used offers no width strictly between, so $3$ bit
widths is an upper estimate of the true transition window.

### 1.2 What this paper proves

We take these two measurements as data and ask which mathematical models of cache
degradation are *consistent* with them. The results fall into five groups.

1. **Mechanism (§3).** An exact statement of where the asymmetry comes from: the value path
   is a $1$-Lipschitz convex average; the key path is an exponential of an inner product,
   with a tightness certificate showing the exponential cannot be softened.
2. **Bit-width geometry (§4).** Value distortion doubles per lost bit; key distortion
   *squares* per lost bit. Consequences: no value configuration can produce the observed
   collapse, and a lower bound on the width of any smooth cliff.
3. **Model refutation and the response-exponent gap (§5).** Two model classes eliminated
   by the data, and the resulting exponent gap $\gamma_K \ge 5 > 1 = \gamma_V$, with
   sharpness.
4. **Depth (§6).** Layer composition preserves the response exponent, so depth cannot
   explain the cliff.
5. **A genuine lower bound and threshold sharpness (§7).** Argmax inversion, an order-$1$
   lower bound on the resulting error, and the one-bit-wide critical band.

Section 8 derives the bit-allocation theorems, §9 gives algorithms, §10 discusses
limitations, and §11 lists open directions.

---

## 2. Setup and definitions

Throughout, $n \ge 1$ is the number of cached positions and $d \ge 1$ the head dimension.

**Definition 2.1 (Softmax weights).** For logits $s \in \mathbb{R}^n$, the softmax weight at
position $i$ is
$$w_i(s) \;=\; \frac{e^{s_i}}{\sum_{j=1}^{n} e^{s_j}}.$$
Since $\sum_j e^{s_j} > 0$, each $w_i(s) > 0$, and $\sum_i w_i(s) = 1$: $w(s)$ is a strictly
positive probability vector.

**Definition 2.2 (Query–key logit).** For $q, k \in \mathbb{R}^d$, the logit is the inner
product $\langle q, k\rangle = \sum_{c=1}^{d} q_c k_c$.

**Definition 2.3 (Attention output).** Given logits $s$ and cached scalars (one readout
coordinate) $v \in \mathbb{R}^n$, the attention output is
$\mathrm{Att}(s,v) = \sum_{i} w_i(s)\, v_i$.
All statements below are per readout coordinate; vector-valued outputs follow coordinatewise.

**Definition 2.4 (Distortion laws).** For bit width $b \in \mathbb{N}$:
- the **value distortion** is $D_V(R, b) = R\,2^{-b}$, where $R$ is the quantiser range;
- the **key distortion** is $D_K(c, b) = e^{c\,2^{-b}} - 1$, the multiplicative softmax
  inflation induced by an effective logit error $c\,2^{-b}$;
- the **total distortion** of a configuration with $b_K$ key bits and $b_V$ value bits is
  $D(c,R,b_K,b_V) = D_K(c,b_K) + D_V(R,b_V)$.

**Definition 2.5 (Power-law response).** A distortion law has *response exponent* $\gamma$
and prefactor $c$ if $D(b) = c\,(R\,2^{-b})^{\gamma}$.

**Definition 2.6 (Two-position model).** For a gap $g \ge 0$ and noise level $\varepsilon$,
the two-position logits are $(0, g)$ and the adversarial perturbation is
$(\varepsilon, -\varepsilon)$: the distractor's logit is overestimated and the attended
token's underestimated. The readout is $(0,1)$.

**Data constants.** We write the two measured arms as: distortion $\le 0.00142$ at $8$ key
bits (the $+0.142\%$ arm) and distortion $\ge 8.67694$ at $5$ key bits (the $+867.694\%$
arm, expressed as a multiplicative excess).

---

## 3. The mechanism: convex average versus exponential

### 3.1 The value path is $1$-Lipschitz

**Theorem 3.1 (Value path stability).** Let $w \in \mathbb{R}^n$ satisfy $w_i \ge 0$ and
$\sum_i w_i = 1$, let $v \in \mathbb{R}^n$ be arbitrary, and let $e \in \mathbb{R}^n$ satisfy
$|e_i| \le \varepsilon$ for all $i$. Then
$$\Big|\sum_i w_i (v_i + e_i) \;-\; \sum_i w_i v_i\Big| \;\le\; \varepsilon .$$

*Proof.* The difference equals $\sum_i w_i e_i$. By the triangle inequality and
non-negativity of the weights,
$|\sum_i w_i e_i| \le \sum_i w_i |e_i| \le \varepsilon \sum_i w_i = \varepsilon$. $\square$

Three features deserve emphasis. The bound is **dimension free** (no factor of $n$ or $d$),
**query free** (it holds for every probability weight vector, in particular for any
perturbed one), and **magnitude free** (independent of $\|v\|$). It is also exactly
attained when all $e_i = \varepsilon$. Hence the value response exponent is exactly $1$:
halving the step exactly halves the damage.

### 3.2 The key path is exponential, tightly

**Theorem 3.2 (Exact translation of the log-odds).** For any logits $s$, perturbation $d$,
and positions $i, j$,
$$\frac{w_i(s+d)}{w_j(s+d)} \;=\; e^{\,d_i - d_j}\;\frac{w_i(s)}{w_j(s)} .$$

*Proof.* The normalisers cancel in the ratio, leaving
$e^{s_i + d_i}/e^{s_j + d_j} = e^{d_i - d_j} \cdot e^{s_i}/e^{s_j}$. $\square$

This is an identity, not an estimate: it certifies that the exponential response of the
softmax to logit noise is real and cannot be improved by a sharper analysis.

**Theorem 3.3 (Multiplicative stability).** If $|d_k| \le \varepsilon$ for all $k$, then for
every $i$,
$$w_i(s + d) \;\le\; e^{2\varepsilon}\, w_i(s).$$

*Proof sketch.* The numerator satisfies $e^{s_i + d_i} \le e^{\varepsilon} e^{s_i}$, while
the normaliser satisfies $\sum_k e^{s_k + d_k} \ge e^{-\varepsilon}\sum_k e^{s_k}$.
Dividing gives the factor $e^{\varepsilon}/e^{-\varepsilon} = e^{2\varepsilon}$. $\square$

**Theorem 3.4 ($\ell^1$ movement of the weight vector).** Under the hypotheses of
Theorem 3.3 with $\varepsilon \ge 0$,
$$\sum_i \big| w_i(s+d) - w_i(s) \big| \;\le\; 2\big(e^{2\varepsilon} - 1\big).$$

*Proof sketch.* Write $|x| = 2\max(x,0) - x$ for $x = w_i(s+d) - w_i(s)$. The sum of the raw
differences vanishes because both weight vectors sum to $1$, so the $\ell^1$ norm equals
$2\sum_i \max(x_i, 0)$. Theorem 3.3 gives $\max(x_i,0) \le (e^{2\varepsilon}-1)\,w_i(s)$
pointwise, and summing against $\sum_i w_i(s) = 1$ finishes. $\square$

**Theorem 3.5 (Logit amplification by dimension).** Let $|q_c| \le Q$ for all $c$ and let
the key perturbation satisfy $|g_c| \le \eta$. Then
$$\big|\langle q, k+g\rangle - \langle q, k\rangle\big| \;\le\; d\,Q\,\eta .$$

*Proof.* The difference is $\sum_c q_c g_c$, bounded termwise by $Q\eta$ over $d$
terms. $\square$

Note the contrast with Theorem 3.1: the key path is **dimension amplifying**; the head
dimension multiplies the quantisation step before the exponential ever acts.

**Theorem 3.6 (Key path error).** Let $|d_k| \le \varepsilon$ with $\varepsilon \ge 0$ and
$|v_i| \le V$. Then
$$\Big|\sum_i w_i(s+d)\,v_i - \sum_i w_i(s)\,v_i\Big| \;\le\; 2\big(e^{2\varepsilon}-1\big)V .$$

*Proof.* Bound the difference by $\sum_i |w_i(s+d) - w_i(s)|\cdot V$ and apply
Theorem 3.4. $\square$

**Theorem 3.7 (Role-split error budget).** With key-side logit error $\varepsilon_K \ge 0$
and value-side entrywise error $\varepsilon_V$,
$$\Big|\sum_i w_i(s+d)\,(v_i + e_i) - \sum_i w_i(s)\,v_i\Big| \;\le\; 2\big(e^{2\varepsilon_K}-1\big)V \;+\; \varepsilon_V .$$

*Proof.* Insert the intermediate quantity $\sum_i w_i(s+d) v_i$ and apply Theorem 3.1 to the
first difference (legitimate because $w(s+d)$ is itself a probability vector) and
Theorem 3.6 to the second. $\square$

**Theorem 3.8 (Role asymmetry).** For $d, Q, V, \eta \ge 0$, with a common per-coordinate
budget $\eta$, the key bound of Theorem 3.6 evaluated at $\varepsilon = dQ\eta$ dominates the
value bound of Theorem 3.1 by at least the factor $4dQV$:
$$\eta \cdot (4\,d\,Q\,V) \;\le\; 2\big(e^{2 d Q \eta} - 1\big) V .$$

*Proof.* From $e^{x} \ge 1 + x$ with $x = 2dQ\eta \ge 0$ we get
$2(e^{x}-1)V \ge 2xV = 4dQ\eta V$. $\square$

Since the left side is linear in $\eta$ and the right side exponential, the ratio is
unbounded as $\eta$ grows. This is the role split in its most basic form.

---

## 4. Bit-width geometry: doubling versus squaring

**Theorem 4.1 (Squaring law).** For all $c$ and $b$,
$$1 + D_K(c,b) \;=\; \big(1 + D_K(c, b+1)\big)^2 ,$$
and more generally $1 + D_K(c,b) = \big(1 + D_K(c, b+k)\big)^{2^{k}}$.

*Proof.* $e^{c/2^{b}} = \big(e^{c/2^{b+1}}\big)^{2}$; iterate. $\square$

**Theorem 4.2 (Doubling law).** For $b_0 \le b_1$,
$$D_V(R, b_0) \;=\; 2^{\,b_1 - b_0}\, D_V(R, b_1).$$

*Proof.* $R\,2^{-b_0} = 2^{b_1-b_0}\cdot R\,2^{-b_1}$. $\square$

The contrast — the key distortion *factor* is raised to a power $2^{k}$, whereas the value
distortion is multiplied by $2^{k}$ — is the engine of everything that follows.

**Theorem 4.3 (No value cliff).** There is no range $R \ge 0$ with
$D_V(R,8) \le 0.00142$ and $D_V(R,5) \ge 8.67694$.

*Proof.* By Theorem 4.2, $D_V(R,5) = 8\,D_V(R,8) \le 8 \cdot 0.00142 = 0.01136 < 8.67694$.
$\square$

So the observed collapse is provably a **key-side event**: no value configuration, at any
range, can produce it. The role split is forced by the algebra rather than assumed.

**Theorem 4.4 (Cliff-width lower bound).** Let $c > 0$, $P \ge 0$, $b_0 \le b_1$, and suppose
$e^{c/2^{b_1}} \le 1 + \rho$ and $1 + P \le e^{c/2^{b_0}}$. Then
$$\log(1+P) \;\le\; 2^{\,b_1 - b_0}\,\log(1+\rho).$$

*Proof.* Taking logarithms of the two hypotheses gives
$\log(1+P) \le c/2^{b_0}$ and $c/2^{b_1} \le \log(1+\rho)$. Since
$c/2^{b_0} = 2^{b_1-b_0}\cdot c/2^{b_1}$, the claim follows. $\square$

In words: under the smooth law, the *logarithm* of the distortion factor can at most double
per lost bit, so a transition from $\rho$ to $P$ must occupy at least
$\log_2\!\big(\log(1+P)/\log(1+\rho)\big)$ bit widths.

**Corollary 4.5 (The smooth softmax model is refuted).** There is no $c > 0$ with
$e^{c/2^{8}} \le 1.00142$ and $9.67694 \le e^{c/2^{5}}$.

*Proof.* Apply Theorem 4.4 with $b_0=5$, $b_1=8$, $\rho = 0.00142$, $P = 8.67694$:
it would force $\log(9.67694) \le 8\log(1.00142)$. But $\log(1+x) \le x$ gives
$\log(1.00142) \le 0.00142$, so the right side is at most $0.01136$, while
$\log(9.67694) \ge 2$ because $e^{2} < 9.67694$. Contradiction. $\square$

The data therefore demand a transition sharper, by a factor exceeding
$\log(9.67694)/\log(1.00142) > 1400$, than the smooth model can produce — over two orders
of magnitude.

**Theorem 4.6 (Effective per-bit shrink base, softmax version).** If $K > 0$ satisfies
$e^{c/K^{8}} \le 1.00142$ and $9.67694 \le e^{c/K^{5}}$, then $K > 11$.

*Proof sketch.* Taking logs, $c/K^{8} \le 0.00142$ and $c/K^{5} \ge 2$. Hence
$2K^{5} \le c \le 0.00142\,K^{8}$, so $K^{3} \ge 2/0.00142 > 1331 = 11^{3}$. $\square$

Thus even keeping the exponential softmax response, each key bit must divide the *effective*
logit error by more than eleven, not by two.

---

## 5. Model-free refutation and the response-exponent gap

Theorem 4.6 still assumes a softmax-shaped law. The following results dispense with that.

**Theorem 5.1 (Super-binary shrink is forced).** Let $K > 0$ and $c$ satisfy
$c/K^{8} \le 0.00142$ and $8.67694 \le c/K^{5}$. Then $K > 18$.

*Proof.* From the hypotheses, $8.67694\,K^{5} \le c \le 0.00142\,K^{8}$, whence
$K^{3} \ge 8.67694/0.00142 > 6110 > 5832 = 18^{3}$, and $t \mapsto t^{3}$ is increasing on
$t > 0$. $\square$

This covers every law multiplicative in bit width: uniform quantisers ($K = 2$), power-law
responses ($K = 2^{\gamma}$), and all geometric surrogates between.

**Corollary 5.2 (The uniform-quantiser step law is refuted).** There is no $c$ with
$c\,2^{-8} \le 0.00142$ and $8.67694 \le c\,2^{-5}$.

*Proof.* Theorem 5.1 with $K=2$ would give $2 > 18$. $\square$

This refutation uses no softmax, no logarithms, and no Lipschitz theory — only the geometry
of the bit ladder. Notably, $c\,2^{-b}$ is precisely the *value*-side law: what is exactly
right for values is impossible for keys.

**Theorem 5.3 (Multiplicativity of power-law responses).** For $b_0 \le b_1$,
$$c\,(R\,2^{-b_0})^{\gamma} \;=\; \big(2^{\gamma}\big)^{\,b_1-b_0}\, c\,(R\,2^{-b_1})^{\gamma},$$
i.e. a power-law response is multiplicative in bit width with shrink base $K = 2^{\gamma}$.

**Theorem 5.4 (At least quintic key response).** If the key distortion obeys
$D(b) = c\,(R\,2^{-b})^{\gamma}$ with $D(8) \le 0.00142$ and $D(5) \ge 8.67694$, then
$\gamma \ge 5$.

*Proof.* By Theorem 5.3 the law is multiplicative with base $K = 2^{\gamma}$ and prefactor
$cR^{\gamma}$; Theorem 5.1 gives $2^{\gamma} > 18$. If $\gamma \le 4$ then
$2^{\gamma} \le 16 < 18$, a contradiction. $\square$

**Theorem 5.5 (Sharpness).** With unit range and exponent exactly $5$, the prefactor
$c = 8.67694\cdot 2^{25}$ satisfies both constraints: $c\,2^{-40} \le 0.00142$ and
$c\,2^{-25} = 8.67694$. Hence $\gamma = 5$ is attained and Theorem 5.4 cannot be strengthened
to $\gamma \ge 6$.

*Proof.* $c\,2^{-25} = 8.67694$ exactly, and $c\,2^{-40} = 8.67694\cdot 2^{-15} < 0.000265
\le 0.00142$. $\square$

**Theorem 5.6 (Response-exponent gap).** Under the hypotheses of Theorem 5.4:
1. the key exponent satisfies $\gamma_K \ge 5$;
2. the value exponent is exactly $1$ — indeed $D_V(R,5) = 8\,D_V(R,8)$ for every $R$;
3. consequently $\gamma_K - \gamma_V \ge 4$.

*Proof.* (1) is Theorem 5.4; (2) is Theorem 4.2 with $b_0 = 5$, $b_1 = 8$; (3) is
arithmetic. $\square$

This is the sharpest quantitative statement of the role split: perplexity is at least
quintic in the key quantisation step and exactly linear in the value step. It is also the
reason a key-rich split is quality-free at the same memory as a uniform $6$-bit cache.

---

## 6. Depth cannot manufacture a cliff

A natural rescue for the refuted smooth models is *depth*: perhaps a mild per-layer response
compounds across a stack into a cliff. It does not.

**Definition 6.1 (Error propagation recursion).** For gain $\lambda$ and per-layer injected
error $e$, define $\delta_0 = 0$ and $\delta_{L+1} = \lambda\,\delta_L + e$.

**Theorem 6.2 (The recursion is a genuine bound).** Let $\lambda \ge 0$ and let $x, y$ be
two trajectories with $x_0 = y_0$ and
$|x_{L+1} - y_{L+1}| \le \lambda |x_L - y_L| + e$ for all $L$. Then
$|x_L - y_L| \le \delta_L$ for all $L$.

*Proof.* Induction on $L$; the base case is $x_0 = y_0$, and the step composes the
hypothesis with monotonicity of $t \mapsto \lambda t + e$. $\square$

**Theorem 6.3 (Closed form).** $\displaystyle \delta_L = e\sum_{i<L}\lambda^{i}$.

*Proof.* Induction, using $\sum_{i<L+1}\lambda^i = \lambda\sum_{i<L}\lambda^i + 1$. $\square$

**Theorem 6.4 (Depth preserves the response exponent).** For all $\lambda, c, R$ and all
$\gamma, b, L$, composing the power-law response $c\,(R2^{-b})^{\gamma}$ over $L$ layers of
gain $\lambda$ gives
$$\delta_L\big(c\,(R2^{-b})^{\gamma}\big) \;=\; \Big(c\textstyle\sum_{i<L}\lambda^{i}\Big)\,(R2^{-b})^{\gamma},$$
a power-law response of the *same* exponent $\gamma$ with prefactor multiplied by the
geometric depth factor.

*Proof.* Immediate from Theorem 6.3, since the depth factor is independent of $b$. $\square$

**Corollary 6.5 (Depth cannot rescue a low exponent).** Whatever $L$ and $\lambda$, if the
depth-composed key response fits both measured arms then $\gamma \ge 5$.

*Proof.* Rewrite via Theorem 6.4 as a power-law response with a modified prefactor and apply
Theorem 5.4, which does not constrain the prefactor. $\square$

**Theorem 6.6 (Value side is depth linear).** With $\lambda = 1$, $\delta_L = L\,e$.

So a stack of $1$-Lipschitz value paths accumulates at most $L$ copies of the per-layer
budget: linear in depth, linear in the step, and never a cliff. **Depth moves the constant,
never the slope.**

---

## 7. A genuine lower bound: argmax inversion

All the key-side results so far are *upper* bounds. Upper bounds can fail to prove
robustness but can never prove fragility. This section supplies the missing half.

**Theorem 7.1 (Softmax is order preserving).** For all $s$ and all $i,j$:
$w_i(s) < w_j(s)$ if and only if $s_i < s_j$.

*Proof.* The weights share a positive normaliser, so the inequality reduces to
$e^{s_i} < e^{s_j}$, i.e. $s_i < s_j$. $\square$

Hence the attended position is exactly the argmax of the logits: what attention decides is a
fact about *ranking*.

**Theorem 7.2 (Rank inversion).** Suppose $s_i < s_j$ (position $j$ dominates by the gap
$g = s_j - s_i > 0$) and the perturbation satisfies $d_i - d_j > g$. Then
$$w_i(s) < w_j(s) \quad\text{but}\quad w_j(s+d) < w_i(s+d).$$

*Proof.* The first inequality is Theorem 7.1. For the second, $d_i - d_j > s_j - s_i$
rearranges to $s_j + d_j < s_i + d_i$, and Theorem 7.1 applies to the perturbed logits.
$\square$

No Lipschitz constant undoes this: the model attends to the wrong token, a discrete error.

**Lemma 7.3.** In the two-position model with gap $g \ge 0$ and no perturbation, the
attended token holds at least half the mass: $w_2\big((0,g)\big) = e^{g}/(1+e^{g}) \ge 1/2$.

**Lemma 7.4.** If the perturbation overshoots the gap by $2h$, i.e. $g + 2h \le 2\varepsilon$,
then in the perturbed two-position model
$$w_2\big((\varepsilon,\, g - \varepsilon)\big) \;=\; \frac{e^{g-\varepsilon}}{e^{\varepsilon} + e^{g-\varepsilon}} \;\le\; \frac{1}{1 + e^{2h}} .$$

*Proof.* The claim is equivalent to $e^{2h}\,e^{g-\varepsilon} \le e^{\varepsilon}$, i.e.
$2h + g - \varepsilon \le \varepsilon$, which is the hypothesis. $\square$

**Theorem 7.5 (Inversion lower bound on the attention error).** Let $g \ge 0$, $h \ge 0$, and
$g + 2h \le 2\varepsilon$. With readout $(0,1)$ in the two-position model,
$$\frac{1}{2} - \frac{1}{1 + e^{2h}} \;\le\; \Big|\mathrm{Att}_{\text{perturbed}} - \mathrm{Att}_{\text{clean}}\Big| .$$

*Proof.* Both outputs equal the weight on position $2$. By Lemma 7.3 the clean output is at
least $1/2$; by Lemma 7.4 the perturbed output is at most $1/(1+e^{2h}) \le 1/2$. The
absolute difference is therefore at least the stated gap. $\square$

The right-hand side tends to $1/2$ as the overshoot $h$ grows: this is an **order-$1$ lower
bound**, and it is the exact converse of Theorem 3.1. The value path can never move the
output by more than its own budget; the key path moves it by an amount governed only by
*whether* the noise beat the gap, not by how small the noise is.

### 7.1 Why a threshold law is sharp in bit width

**Theorem 7.6 (The critical band contains at most one bit width).** Let $A, g \in \mathbb{R}$
and $b, b' \in \mathbb{N}$ satisfy
$$\tfrac{g}{2} \le \frac{A}{2^{b}} < g \qquad\text{and}\qquad \tfrac{g}{2} \le \frac{A}{2^{b'}} < g .$$
Then $b = b'$.

*Proof.* It suffices to show that if $p < q$ and $g/2 \le A/2^{p} < g$ then $A/2^{q} < g/2$.
The band hypotheses force $A/2^{p} > 0$ and hence $A > 0$, so $b \mapsto A/2^{b}$ is strictly
decreasing; since $q \ge p+1$ we get $A/2^{q} \le A/2^{p+1} = \tfrac12\,(A/2^{p}) < g/2$.
Applying this in both directions to $b, b'$ contradicts the band membership of the larger
index unless $b = b'$. $\square$

Note that positivity of the gap is not assumed: the band hypotheses already force $g > 0$.

Interpretation: with noise $A\,2^{-b}$ halving per bit, one bit *below* the band the noise
exceeds the gap and the argmax inverts (Theorem 7.2); one bit *above*, the noise is already
below half the gap. A gap-threshold mechanism therefore has a transition window of **one to
two bit widths**.

**Theorem 7.7 (Threshold beats smooth).** Simultaneously: (i) the critical band contains at
most one bit width; (ii) no smooth law $e^{c/2^{b}}-1$ with $c > 0$ matches both measured
arms.

*Proof.* (i) is Theorem 7.6; (ii) is Corollary 4.5. $\square$

Quantitatively, the smooth law would need at least
$\log_2\!\big(\log 9.67694/\log 1.00142\big) > 10$ bit widths to travel from $+0.142\%$ to
$+867.694\%$, whereas the threshold mechanism needs one or two. The measurement brackets the
key floor within $(5, 8]$ — three widths, and only because the format ladder offers nothing
in between. Three is near one and far from ten: **the bracketing is evidence for the
gap-threshold mechanism and against the smooth one.**

---

## 8. Optimal allocation of a fixed bit budget

**Theorem 8.1 (One-bit transfer).** Let $b_V \ge 1$ and suppose
$D_V(R, b_V) < D_K(c, b_K) - D_K(c, b_K+1)$. Then
$$D\big(c,R,b_K+1,\,b_V-1\big) \;<\; D\big(c,R,b_K,\,b_V\big).$$

*Proof.* By Theorem 4.2, $D_V(R, b_V-1) = 2\,D_V(R,b_V)$, so the value side loses
$D_V(R,b_V)$ while the key side saves $D_K(c,b_K) - D_K(c,b_K+1)$; the hypothesis says the
saving wins. $\square$

**Theorem 8.2 (Budget-neutral reallocation).** Let $k \le b$ and write
$t = 1 + D_K(c, b+k)$ for the key distortion factor at the enriched width. If
$$\big(2^{k}-1\big)\,D_V(R,b) \;<\; t^{\,2^{k}} - t ,$$
then memory is unchanged, $(b+k) + (b-k) = b + b$, and
$$D\big(c,R,b+k,\,b-k\big) \;<\; D\big(c,R,b,\,b\big).$$

*Proof.* By the squaring law (Theorem 4.1), $D_K(c,b) = t^{2^{k}} - 1$ while
$D_K(c,b+k) = t - 1$, so the key side saves exactly $t^{2^{k}} - t$. By the doubling law,
$D_V(R, b-k) = 2^{k} D_V(R,b)$, so the value side loses $(2^{k}-1)D_V(R,b)$. $\square$

The asymmetry is visible in the shapes: the key saving is a degree-$2^{k}$ polynomial in
$t$, the value loss is a mere factor $2^{k}$. This is why the inequality is easy to satisfy.

**Theorem 8.3 (Equal memory, unequal quality).** Suppose $R \le 256$ and the key distortion
factor at $8$ bits satisfies $1 + D_K(c, 8) \ge 2$. Then
$$D(c,R,8,4) \;<\; D(c,R,6,6),$$
although both configurations cost exactly $6$ average bits per element, since $8+4 = 6+6$.

*Proof.* Apply Theorem 8.2 with $b = 6$, $k = 2$. Writing $t = 1 + D_K(c,8) \ge 2$, the
required inequality is $3\,(R/64) < t^{4} - t$. The left side is at most $3\cdot 4 = 12$,
while $t \ge 2$ gives $t^4 - t \ge 16 - 2 = 14 > 12$. $\square$

The hypothesis $1 + D_K(c,8) \ge 2$ is exactly the regime the measurement puts us in: keys
are already so sensitive that $5$-bit storage breaks the model, so the $8$-bit distortion
factor is not small. Theorem 8.3 is the formal statement behind the serving default: **keys
at $8$ bits, values at $4$ bits.**

---

## 9. Algorithms

### 9.1 Optimal bit allocation under a memory budget

Given a total budget $B$ of average bits per cache element and the two distortion laws,
choose $(b_K, b_V)$ with $b_K + b_V = 2B$ minimising $D_K(c,b_K) + D_V(R,b_V)$. Because
$D_K$ is convex and rapidly decreasing in $b_K$ while $D_V$ decreases geometrically, the
objective over the finite admissible ladder can be minimised by direct enumeration in
$O(B)$ time. The theory above predicts the minimiser is key rich: in the regime
$1 + D_K(c,8) \ge 2$, the pair $(8,4)$ beats $(6,6)$ at $B = 6$.

### 9.2 Response-exponent estimation from two arms

Given two measurements $(b_0, D_0)$ and $(b_1, D_1)$ with $b_0 < b_1$ and $D_1 < D_0$, the
implied per-bit shrink base of any multiplicative law is
$$K \;=\; \Big(\frac{D_0}{D_1}\Big)^{1/(b_1 - b_0)},$$
and the implied power-law exponent is $\gamma = \log_2 K$. Feeding in $D_0 = 8.67694$ at
$b_0 = 5$ and $D_1 = 0.00142$ at $b_1 = 8$ gives $K = (6110.5)^{1/3} \approx 18.28 > 18$ and
$\gamma \approx 4.19$ as the *real-valued* exponent, hence $\gamma \ge 5$ once integrality is
imposed — matching Theorem 5.4. Complexity: $O(1)$.

### 9.3 Critical-band locator

Given a gap $g$ and noise amplitude $A$, the unique bit width (if any) with
$A/2^{b} \in [g/2, g)$ is $b^{*} = \lceil \log_2(A/g)\rceil$, subject to the membership check.
Theorem 7.6 guarantees uniqueness; the computation is $O(1)$ and locates the predicted
one-bit-wide transition.

---

## 10. Discussion

### 10.1 What survives and what fails

**Survives.** The mechanism (convex average versus exponential); the two degradation laws
(doubling versus squaring); the equal-memory optimality of the key-rich split; the
response-exponent gap; the order-$1$ inversion lower bound; the one-bit-wide critical band.

**Fails, and instructively.** Both *smooth* key models — the linear step law and the
Lipschitz-softmax law — are not merely hard to justify, they are **false against the data**,
by $2.9$ and $2.6$ orders of magnitude respectively. This is a "needs-a-different-definition"
failure rather than a proof gap: the effective key error is not $R\,2^{-b}$ with a fixed
range $R$.

The most plausible replacement is block-scaled quantisation. A block quantiser's step is
$\max|k|/2^{b}$, so the *relative* error of a typical key coordinate carries the outlier
ratio $\max/\mathrm{typ}$ as a prefactor. If that ratio itself grows as the block scale is
re-fitted at lower widths, the effective error can fall by far more than a factor of $2$ per
bit — the only known mechanism able to deliver the per-bit shrink base $K > 18$ that
Theorem 5.1 demands.

### 10.2 Reconciling the two key-side pictures

The smooth picture (§3–§6) and the threshold picture (§7) are not competitors so much as
different resolutions of the same object. The smooth bounds are correct as *upper* bounds;
they simply cannot generate a cliff. The threshold mechanism explains the cliff, and its
predicted transition window (one to two bit widths) is compatible with the measured bracket
$(5,8]$ while the smooth prediction ($> 10$ widths) is not. Both are needed: the smooth
analysis proves that values are safe, and the threshold analysis proves that keys are not.

### 10.3 Limitations

The measurements are a single controlled cell: one model, one held-out text slice, context
length $2048$. The distortion laws relate an *analytic* output perturbation to a *measured*
perplexity excess through a monotone identification that we assume rather than derive; the
refutation results are robust to any strictly increasing reparametrisation of that
identification, but the numerical value of $\gamma$ is not. The two-position model of §7 is
an idealisation, chosen to isolate the inversion mechanism; it shows the damage *can* be
order $1$, not that it *always* is. Finally, the format ladder available offers no width
strictly between $5$ and $8$ bits, so the bracket $(5,8]$ is a limit of the experimental
resolution, not of the mathematics.

---

## 11. Future directions

**Outlier-scaled block quantisation should have response exponent at least $5$.** The
missing piece is a derivation, rather than a fit, of the prefactor. If the block scale is
set by outlier channels and re-fits adversarially as the width drops, the effective error
should shrink super-binarily per bit — the only known route to $K > 18$. Proving a lower
bound on the shrink base for an explicit outlier model would turn Theorem 5.1 from a
constraint into a prediction.

**Depth is settled, negatively.** The conjecture that end-to-end exponents are additive in
depth is false in the standard error-propagation model: composition multiplies the
prefactor by $\sum_{i<L}\lambda^{i}$ and preserves the exponent exactly.

**Distributional gap statistics.** Theorem 7.5 concerns a single attended pair. The natural
next step is to average over the empirical distribution of top-two logit gaps: given a gap
density, what fraction of positions invert at a given noise level, and how does the
resulting expected error depend on bit width? A heavy concentration of small gaps would
predict an even sharper cliff.

**Sharper brackets.** The predicted transition window is one to two bit widths, but the
available formats bracket the key floor only within $(5,8]$. A finer ladder (a $6$- or
$7$-bit cache format) would provide a direct test: the threshold theory predicts the free-to-
broken jump occurs between two adjacent widths, the smooth theory predicts a gradual slope
over many.

**Beyond the two-position model.** Extending the inversion lower bound to $n$ positions with
a general logit profile, and to vector-valued readouts, would close the last idealisation in
the fragility argument.

---

## 12. Conclusion

The two halves of an attention cache are not interchangeable, and the reason is algebraic
rather than empirical. Values enter through a convex combination: their path is
$1$-Lipschitz, dimension free, and has response exponent exactly $1$, so they survive raw
$4$-bit storage. Keys enter through an exponential of an inner product: their path is
dimension amplifying, exponentially responsive with a tightness certificate, has response
exponent at least $5$, and — once the noise exceeds the top-two logit gap — suffers an
order-$1$ error from argmax inversion that no smoothness assumption can bound away. Depth
changes none of this. The measured data eliminate every smooth key model by more than two
orders of magnitude and are consistent, in both size and sharpness, with a threshold
mechanism.

The practical corollary is a theorem: at equal memory, spend the bits where the argmax
lives. Keys at $8$ bits, values at $4$ — about $6$ bits per element, half the cache, and
$+0.142\%$ degradation.
