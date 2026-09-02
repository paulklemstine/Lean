# Super-Additive Degradation in Compressed Attention: An Exact Theory of the Quantization–Sparsity Interaction

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

Two of the most widely deployed inference-time compression techniques for transformer language models — low-bit weight quantization and top-$k$ sparse attention — are routinely budgeted as if their accuracy costs were additive. We show that they are not. In a controlled evaluation, 4-bit group-128 weight quantization alone cost $9.19\%$ of retained accuracy and top-$16$ attention alone cost $2.32\%$, while the two combined cost $14.02\%$ rather than the additive prediction of $11.51\%$; the residual $2.51$ points is an *interaction cost* that decays monotonically with the attention budget ($2.51\%,\,1.77\%,\,1.60\%$ at $k = 16, 20, 24$).

We develop an exact theory of this interaction in an idealized averaging model of an attention head and establish the following. (i) With $\varepsilon$-bounded quantization error the interaction cost is always at most $\varepsilon$, and under the additional hypothesis that the error is centred over the full context it is at most $\varepsilon\min(1,(n-k)/k)$, a bound attained whenever $2k \le n$ and antitone in the budget $k$. (ii) In mean square, under centred, pairwise-uncorrelated quantization error of variance $\sigma^2$, the interaction cost is *exactly* $\sigma^2(1/k - 1/n)$ — an identity, strictly positive for every $k < n$, realized non-vacuously by the $2^n$-point Rademacher dither ensemble. (iii) Top-$k$ selection is stable under score perturbations of size $\varepsilon$ precisely when the selection margin exceeds $2\varepsilon$, and the constant $2$ is sharp. (iv) The effect survives arbitrary (softmax) attention patterns: a normalized pattern supported on $k$ keys transmits noise energy $\sigma^2\sum_i w_i^2 \ge \sigma^2/k$, so the uniform top-$k$ head is the *best*, not the worst, case. (v) Under group-correlated quantization error with intra-group correlation $\rho$, the transmitted variance of a $k$-sparse head is $(\sigma^2 k + \rho\sigma^2 P(S))/k^2$ where $P(S) = \sum_t m_t(m_t-1)$ counts ordered same-group pairs in the selection, $m_t$ being the group occupancy profile; $P(S) \le k(k-1)$ with equality exactly for group-aligned selections, and $P(S) = 0$ for group-spread selections, so aligned selections at $\rho = 1$ transmit the *entire* variance $\sigma^2$ and lose all $1/k$ suppression. (vi) Recentering the quantization error on the selected set annihilates the interaction, restoring the additive budget law.

We also delimit the claim: the interaction is a worst-case and mean-square phenomenon, not a pointwise identity — explicit error patterns make it negative. The engineering conclusion is that additive budget arithmetic is a *lower* bound on combined damage, never an upper bound, and that selecting keys across distinct quantization groups is a provably correct, zero-cost mitigation.

**Keywords:** attention sparsity, weight quantization, noise amplification, super-additivity, Schur convexity, group-correlated dither, Cauchy–Schwarz noise gain.

---

## 1. Introduction

### 1.1 The additive budget assumption

Deploying a large transformer under a memory constraint means composing compression techniques. Two dominate practice:

- **Weight quantization**, which stores each weight on a low-bit grid. Group-wise 4-bit schemes share one scale factor across a block (typically 128) of weights and round within the block.
- **Sparse attention**, which restricts each query to the $k$ highest-scoring keys, so the key–value cache stores $k$ entries instead of the full context length $n$.

Because the two techniques touch different parts of the computation — one the parameters, the other the attention pattern — engineering practice budgets their accuracy costs additively: measure the degradation of each in isolation, add, and plan around the sum. This paper shows the assumption is false in a specific, quantifiable, and mechanistically explicable way.

### 1.2 The measurement

A controlled integration test evaluated a transformer language model under eight arms, reporting retained accuracy relative to the full-precision baseline together with cross-entropy:

| arm | retained | CE |
|---|---|---|
| full fp32 | 1.0000 | 2.697 |
| top-$k$ attention, $k=16$ | 0.9768 | 2.774 |
| top-$k$ attention, $k=20$ | 0.9803 | 2.755 |
| top-$k$ attention, $k=24$ | 0.9851 | 2.742 |
| 4-bit group-128 quantization | 0.9081 | 3.015 |
| quantization $+$ $k=16$ | 0.8598 | 3.220 |
| quantization $+$ $k=20$ | 0.8707 | 3.180 |
| quantization $+$ $k=24$ | 0.8772 | 3.155 |

Writing $L = 1 - \text{retained}$ for the loss of an arm, the *measured interaction* at budget $k$ is
$$I_k \;=\; L_{\text{both}}(k) - L_{\text{attn}}(k) - L_{\text{quant}}.$$
At $k = 16$: $L_{\text{attn}} = 2.32\%$, $L_{\text{quant}} = 9.19\%$, $L_{\text{both}} = 14.02\%$, so $I_{16} = 2.51\%$. Likewise $I_{20} = 1.77\%$ and $I_{24} = 1.60\%$. Every interaction is positive, and they decay monotonically in $k$. The cross-entropy figures tell the same story: the combined excess $3.220 - 2.697 = 0.523$ exceeds the sum of the individual excesses $0.077 + 0.318 = 0.395$.

Three hypotheses were under test.

- **P1 (sub-additivity).** $L_{\text{both}} \le L_{\text{attn}} + L_{\text{quant}}$ universally.
- **P2 (super-additivity).** $L_{\text{both}}$ can exceed the additive prediction.
- **P3 (independence).** $L_{\text{both}} = L_{\text{attn}} + L_{\text{quant}}$.

The data refute P1 and P3 and support P2. The theory below refutes P1 and P3 as *theorems*, confirms P2 in worst case and in mean square, computes the exact size of the effect, and identifies two mitigations.

### 1.3 The mechanism in one sentence

Quantization error is approximately symmetric, so a dense average over $n$ keys cancels most of it; a sparse average over $k \ll n$ keys cancels far less. Sparsification is therefore a *noise amplifier* for quantization error, by a factor $n/k$ in transmitted energy. On top of this statistical mechanism there is a discrete one: quantized keys project differently, so the top-$k$ threshold can select a different set of keys altogether.

---

## 2. The averaging model

### 2.1 Definitions

Fix a context of $n$ keys, indexed by $\{1,\dots,n\}$. An attention head reads real values $v : \{1,\dots,n\} \to \mathbb{R}$. (Values are vectors in practice; every statement below applies coordinatewise, and nothing depends on the dimension.)

**Definition 2.1 (Restricted average).** For a finite index set $S$ and $f : \{1,\dots,n\}\to\mathbb{R}$,
$$\mathrm{avg}_S f \;=\; \frac{1}{|S|}\sum_{i\in S} f(i),$$
with the convention $\mathrm{avg}_\emptyset f = 0$. We write $\bar f = \mathrm{avg}_{\{1,\dots,n\}} f$ for the dense average.

**Definition 2.2 (Degradations).** Let $S$ with $|S| = k$ be the selected key set and let $\eta : \{1,\dots,n\}\to\mathbb{R}$ be the quantization error added to the values. Define

- the **attention-only degradation** $\ \mathrm{deg}_A(v,S) = |\mathrm{avg}_S v - \bar v|$;
- the **quantization-only degradation** $\ \mathrm{deg}_Q(\eta) = |\bar\eta|$;
- the **combined degradation** $\ \mathrm{deg}_{AQ}(v,\eta,S) = |\mathrm{avg}_S(v+\eta) - \bar v|$.

**Definition 2.3 (Interaction cost).**
$$I(v,\eta,S) \;=\; \mathrm{deg}_{AQ}(v,\eta,S) - \mathrm{deg}_A(v,S) - \mathrm{deg}_Q(\eta).$$

$I = 0$ is exact additivity (P3), $I \le 0$ is sub-additivity (P1), $I > 0$ is super-additivity (P2).

The elementary but decisive structural fact is linearity of the restricted average:
$$\mathrm{avg}_S(f+g) = \mathrm{avg}_S f + \mathrm{avg}_S g,$$
so that
$$\mathrm{avg}_S(v+\eta) - \bar v = \underbrace{(\mathrm{avg}_S v - \bar v)}_{\text{sparsity bias}} \;+\; \underbrace{\mathrm{avg}_S \eta}_{\text{sparse noise read}} . \tag{2.1}$$
Everything in this paper is a statement about the second term. The dense arm sees $\bar\eta$; the combined arm sees $\mathrm{avg}_S\eta$; the difference between these two readings of the *same* error field is the interaction.

### 2.2 A basic bound

**Lemma 2.4 (Bounded averages).** If $|f(i)| \le \varepsilon$ for all $i$ and $S \ne \emptyset$, then $|\mathrm{avg}_S f| \le \varepsilon$.

*Proof.* Triangle inequality on the sum, then divide by $|S| > 0$. $\square$

**Theorem 2.5 (Bounded interaction penalty).** If $|\eta_i| \le \varepsilon$ for all $i$ and $S\ne\emptyset$, then for every $v$,
$$I(v,\eta,S) \;\le\; \varepsilon .$$

*Proof.* By (2.1) and the triangle inequality, $\mathrm{deg}_{AQ} \le \mathrm{deg}_A + |\mathrm{avg}_S\eta| \le \mathrm{deg}_A + \varepsilon$ using Lemma 2.4. Since $\mathrm{deg}_Q \ge 0$, subtracting gives $I \le \varepsilon$. $\square$

Theorem 2.5 already delivers the reassuring half of the engineering message: budget tables need a correction term, but a *bounded* one, on the scale of the quantization step. It holds for **every** selected set, hence also across selection flips — the discrete mechanism of §5 cannot make the penalty exceed $\varepsilon$ either.

---

## 3. The interaction is real: an exact identity and a counterexample to additivity

### 3.1 Quantization invisible to dense attention

**Lemma 3.1.** If $\sum_i \eta_i = 0$ then $\mathrm{deg}_Q(\eta) = 0$.

This is the sharpest possible setting for isolating the interaction: quantization measured *in isolation* is free, so any loss the combined arm suffers beyond $\mathrm{deg}_A$ is interaction by definition.

**Theorem 3.2 (Exact interaction identity).** Suppose $\sum_i\eta_i = 0$ and the sparsity bias and the sparse noise read have the same sign, i.e.
$$(\mathrm{avg}_S v - \bar v)\cdot \mathrm{avg}_S\eta \;\ge\; 0 .$$
Then
$$I(v,\eta,S) \;=\; |\mathrm{avg}_S\eta| .$$

*Proof.* By Lemma 3.1, $\mathrm{deg}_Q = 0$. By (2.1), $\mathrm{deg}_{AQ} = |a + b|$ with $a = \mathrm{avg}_S v - \bar v$ and $b = \mathrm{avg}_S\eta$. When $ab \ge 0$ one has $|a+b| = |a| + |b|$ (check the four sign cases; if the signs are opposite, $ab \ge 0$ forces one factor to vanish). Hence $\mathrm{deg}_{AQ} = \mathrm{deg}_A + |b|$ and $I = |b|$. $\square$

The theorem isolates mechanism (2) exactly: *dense attention averages the error away; sparse attention cannot.* The additive budget predicts a combined penalty of $\mathrm{deg}_A + 0$; the truth is $\mathrm{deg}_A + |\mathrm{avg}_S\eta|$.

### 3.2 Refuting additivity and independence

**Example 3.3 (Four keys).** Let $n = 4$, $v = (0,0,3,3)$, $\eta = (-1,-1,-1,+1)$, $S = \{1,2\}$. Then $\bar v = 3/2$, $\mathrm{avg}_S v = 0$, so $\mathrm{deg}_A = 3/2$; $\bar\eta = -1/2$, so $\mathrm{deg}_Q = 1/2$; $\mathrm{avg}_S\eta = -1$, so $\mathrm{deg}_{AQ} = |0 - 1 - 3/2| = 5/2$. Therefore
$$I = \tfrac52 - \tfrac32 - \tfrac12 = \tfrac12 > 0 .$$

**Corollary 3.4 (P1 refuted).** There is no universal sub-additive law: the inequality $\mathrm{deg}_{AQ} \le \mathrm{deg}_A + \mathrm{deg}_Q$ fails.

**Corollary 3.5 (P3 refuted).** The quantization axis and the attention-budget axis are not independent: $\mathrm{deg}_{AQ} \ne \mathrm{deg}_A + \mathrm{deg}_Q$ in general.

**Theorem 3.6 (Strict super-additivity, general form).** Whenever the sparsity bias and the sparse noise read are aligned in sign and the sparse noise read is nonzero while the dense read of the error vanishes, $I > 0$. In particular super-additivity is generic, not exceptional: it requires only that the sparse window not be a fair sample of the error field.

### 3.3 The corrected budget law

**Theorem 3.7 (Two-sided budget law).** For $\varepsilon$-bounded, globally centred quantization error and any nonempty $S$,
$$\mathrm{deg}_{AQ} \;\le\; \mathrm{deg}_A + \mathrm{deg}_Q + \varepsilon\min\!\Big(1,\frac{n-k}{k}\Big),$$
while Example 3.3 shows the naive additive expression can be strictly exceeded.

*Proof.* Combine (2.1), the triangle inequality, $\mathrm{deg}_Q \ge 0$, and Theorem 4.1 below. $\square$

The practical reading: **additivity is a lower bound on damage, not an upper bound**, and the correct upper bound carries an explicit, budget-dependent penalty term.

---

## 4. The exact worst case

Define the **worst-case interaction bound**
$$W(n,k,\varepsilon) \;=\; \varepsilon\cdot\min\!\Big(1,\ \frac{n-k}{k}\Big).$$

**Theorem 4.1 (Worst case, upper half).** If $\sum_i\eta_i = 0$, $|\eta_i| \le \varepsilon$ for all $i$, and $S \ne \emptyset$ with $|S| = k$, then
$$|\mathrm{avg}_S\eta| \;\le\; W(n,k,\varepsilon).$$

*Proof.* Two independent bounds. First, Lemma 2.4 gives $|\mathrm{avg}_S\eta| \le \varepsilon$. Second, global centring gives $\sum_{i\in S}\eta_i = -\sum_{i\notin S}\eta_i$, and the complement has $n - k$ terms each of modulus at most $\varepsilon$, so $|\sum_{i\in S}\eta_i| \le (n-k)\varepsilon$ and hence $|\mathrm{avg}_S\eta| \le \varepsilon(n-k)/k$. Take the minimum. $\square$

**Theorem 4.2 (Worst case, achievability).** If $2k \le n$, $\varepsilon\ge 0$ and $S\ne\emptyset$, there exists $\eta$ with $\sum_i\eta_i = 0$, $|\eta_i|\le\varepsilon$ for all $i$, and $\mathrm{avg}_S\eta = \varepsilon$; moreover $W(n,k,\varepsilon) = \varepsilon$ in this regime.

*Proof.* Take $\eta_i = \varepsilon$ for $i\in S$ and $\eta_i = -\frac{k}{n-k}\varepsilon$ for $i\notin S$. The sum is $k\varepsilon - (n-k)\frac{k}{n-k}\varepsilon = 0$; the bound $|\eta_i|\le\varepsilon$ off $S$ holds because $2k\le n$ gives $k \le n-k$; and $\mathrm{avg}_S\eta = \varepsilon$. Since $2k\le n$ gives $(n-k)/k \ge 1$, $W = \varepsilon$. $\square$

So in the practically relevant regime — attention budget at most half the context — the worst-case interaction is *exactly* $\varepsilon$: an entire quantization step can hide inside a sparse window.

**Theorem 4.3 (Monotonicity in the budget).** For $\varepsilon \ge 0$ and $k_1 \le k_2$, $W(n,k_2,\varepsilon)\le W(n,k_1,\varepsilon)$. If moreover $\varepsilon>0$ and $n/2 \le k_1 < k_2 < n$, the inequality is strict.

*Proof.* $k \mapsto (n-k)/k = n/k - 1$ is strictly decreasing on $k > 0$, and $\min(1,\cdot)$ preserves monotonicity; in the saturated regime $k \ge n/2$ the minimum is attained by the second argument, where the decrease is strict. $\square$

This is the qualitative shape the measurement exhibits: $I_{16} > I_{20} > I_{24}$.

---

## 5. Mechanism (1): the moving top-$k$ threshold

**Definition 5.1.** $S$ is a **top-$k$ set** for a score vector $s$ if $|S| = k$ and $s_j \le s_i$ for every $i \in S$ and every $j\notin S$.

**Theorem 5.2 (Selection stability).** Let $S$ be a top-$k$ set for $s$ and $S'$ a top-$k$ set for the perturbed scores $s + e$, with $|e_i| \le \varepsilon$ for all $i$. If the clean margin satisfies
$$s_j + 2\varepsilon < s_i \qquad \text{for all } i \in S,\ j \notin S,$$
then $S' = S$.

*Proof.* Suppose $S'\ne S$. Since $|S| = |S'| = k$, both $S'\setminus S$ and $S\setminus S'$ are nonempty; pick $j \in S'\setminus S$ and $i \in S\setminus S'$. Optimality of $S'$ for the perturbed scores gives $s_i + e_i \le s_j + e_j$. With $|e_i|,|e_j|\le\varepsilon$ this yields $s_i \le s_j + 2\varepsilon$, contradicting the margin hypothesis. $\square$

**Theorem 5.3 (Sharpness of the constant $2$).** There exist scores, perturbations and top-$1$ sets with $|e_i|\le\varepsilon$, margin exactly $2\varepsilon$, and $S'\ne S$.

*Proof.* Take $n = 2$, $s = (1,-1)$, $e = (-1,+1)$, $\varepsilon = 1$. Then $S = \{1\}$ is top-$1$ for $s$, the margin is $s_1 - s_2 = 2 = 2\varepsilon$, and the perturbed scores are $(0,0)$, for which $S' = \{2\}$ is also a top-$1$ set. $\square$

Together, Theorems 5.2 and 5.3 locate the phase boundary exactly at margin $2\varepsilon$: below it, quantization can re-route attention to a different set of tokens; strictly above it, it provably cannot. Real attention score distributions are heavy-tailed but flat in their bulk, so a nontrivial fraction of query positions sit below the threshold — which is why mechanism (1) contributes in practice even though it is invisible in any first-order expansion.

---

## 6. Mechanism (2), quantitatively: noise gain

**Definition 6.1.** The **noise gain** of a weight vector $w$ supported on $S$ is $\mathcal{G}(w) = \sum_{i\in S} w_i^2$. If the $\eta_i$ are uncorrelated with variance $\sigma^2$, the read $\sum_i w_i \eta_i$ has variance $\sigma^2 \mathcal{G}(w)$.

**Theorem 6.2 (Cauchy–Schwarz floor).** If $S \ne\emptyset$ and $\sum_{i\in S} w_i = 1$, then $\mathcal{G}(w) \ge 1/|S|$.

*Proof.* $1 = (\sum_{i\in S} w_i)^2 \le |S|\sum_{i\in S} w_i^2$. $\square$

**Theorem 6.3 (Uniform weights attain the floor).** For $w_i = 1/|S|$ on $S$, $\mathcal{G}(w) = 1/|S|$.

**Corollary 6.4 (Amplification by sparsification).** Restricting a normalized attention pattern from $n$ keys to $k$ keys multiplies the transmitted quantization energy by at least $n/k$: the floor moves from $1/n$ to $1/k$. Consequently the transmitted energy $\sigma^2/k$ of a uniform $k$-sparse head is strictly decreasing in $k$.

This is the quantitative core of the paper: **sparsity is noise gain**, and the gain is exactly the reciprocal of the budget.

---

## 7. The mean-square theory

Worst-case bounds require an adversary. The typical case is cleaner still — it is an identity.

Let $\Omega$ be a finite nonempty ensemble of quantization outcomes, with the uniform average written $\mathbb{E}$. Let $\eta_\omega$ denote the error field of outcome $\omega$.

**Hypotheses (dither model).** (a) *Centred*: $\mathbb{E}[\eta_\omega(i)] = 0$ for each $i$; (b) *pairwise uncorrelated*: $\mathbb{E}[\eta_\omega(i)\eta_\omega(j)] = 0$ for $i \ne j$; (c) *homoscedastic*: $\mathbb{E}[\eta_\omega(i)^2] = \sigma^2$ for each $i$.

**Lemma 7.1 (Second moment of a sparse read).** Under (a)–(c), for nonempty $S$ with $|S| = k$,
$$\mathbb{E}\big[(\mathrm{avg}_S \eta_\omega)^2\big] = \frac{\sigma^2}{k},\qquad \mathbb{E}[\mathrm{avg}_S\eta_\omega] = 0 .$$

*Proof.* Expand the square as the double sum $k^{-2}\sum_{i,j\in S}\eta_i\eta_j$, take the average, kill the $k(k-1)$ off-diagonal terms by (b) and evaluate the $k$ diagonal terms by (c). $\square$

**Theorem 7.2 (Exact mean-square interaction).** Under (a)–(c), for any values $v$ and any nonempty $S$ with $|S| = k$,
$$\underbrace{\mathbb{E}\big[(\mathrm{avg}_S(v+\eta_\omega) - \bar v)^2\big]}_{\text{combined}} \;-\; \underbrace{(\mathrm{avg}_S v - \bar v)^2}_{\text{attention only}} \;-\; \underbrace{\mathbb{E}\big[\bar\eta_\omega^{\,2}\big]}_{\text{quantization only}} \;=\; \sigma^2\Big(\frac1k - \frac1n\Big).$$

*Proof.* Write $b = \mathrm{avg}_S v - \bar v$. By (2.1), the combined error is $b + \mathrm{avg}_S\eta_\omega$, so its mean square is $b^2 + 2b\,\mathbb{E}[\mathrm{avg}_S\eta_\omega] + \mathbb{E}[(\mathrm{avg}_S\eta_\omega)^2]$. The cross-term vanishes by Lemma 7.1. The attention-only term is $b^2$, and the quantization-only term is $\sigma^2/n$ by Lemma 7.1 applied to the full index set. Subtract. $\square$

**Corollary 7.3 (Strict positivity).** If $\sigma \ne 0$ and $k < n$, the mean-square interaction is strictly positive. Super-additivity is a structural property of the model, requiring no adversarial choice of $\eta$ and no sign condition on $v$.

### 7.1 Non-vacuity: the Rademacher dither ensemble

The dither hypotheses are not vacuous. Let $\Omega = \{\pm 1\}^{n}$ with the uniform measure and set $\eta_\omega(i) = \sigma\,\omega_i$.

**Proposition 7.4.** This ensemble is centred, pairwise uncorrelated, and has $\mathbb{E}[\eta_\omega(i)^2] = \sigma^2$; consequently Theorem 7.2 applies verbatim and the interaction is exactly $\sigma^2(1/k - 1/n)$.

*Proof.* Each statistic is odd under flipping a single coordinate sign, and flipping is an involution of $\Omega$, hence the average vanishes; the variance is $\sigma^2$ pointwise. $\square$

### 7.2 The claim is not a pointwise law

**Proposition 7.5 (Interaction can be negative).** On the same values $v = (0,0,3,3)$ and the same $S = \{1,2\}$ as Example 3.3, take $\eta' = (+1,+1,+1,-1)$. Then $\mathrm{deg}_Q = 1/2$, $\mathrm{avg}_S\eta' = 1$, $\mathrm{deg}_{AQ} = |0+1-3/2| = 1/2$, and
$$I = \tfrac12 - \tfrac32 - \tfrac12 = -\tfrac32 < 0 .$$

The rounding noise happened to push the sparse read *toward* the dense answer. Super-additivity is therefore a worst-case and mean-square statement, not a pointwise identity — a distinction that a purely empirical study, averaging over a corpus, would blur.

---

## 8. Arbitrary attention patterns: softmax heads are covered

Real heads do not average uniformly; they apply softmax weights. Nothing above needs uniformity.

**Definition 8.1.** The read of an attention pattern $w$ is $R_w(f) = \sum_i w_i f_i$.

**Theorem 8.2 (Transmitted variance of an arbitrary pattern).** Under (a)–(c),
$$\mathbb{E}\big[R_w(\eta_\omega)^2\big] = \sigma^2 \sum_i w_i^2 .$$

*Proof.* Expand the square, kill off-diagonal terms by (b), evaluate diagonal terms by (c). $\square$

**Theorem 8.3 (Softmax-ready interaction floor).** If $w$ is supported on $S$ with $|S| = k$ and $\sum_{i\in S} w_i = 1$, then
$$\sigma^2\sum_i w_i^2 - \frac{\sigma^2}{n} \;\ge\; \sigma^2\Big(\frac1k - \frac1n\Big).$$

*Proof.* Immediate from Theorems 8.2 and 6.2. $\square$

The interpretation matters. The uniform top-$k$ head analysed in §7 is the **best** case among all attention patterns with a given $k$-element support; a peaked softmax — the empirically common case, since top-$k$ selection keeps exactly the high-scoring keys — has larger $\sum w_i^2$ and therefore a *larger* interaction. The measured $2.51\%$ is, if anything, a conservative reflection of the underlying effect.

---

## 9. Group-correlated quantization: why 4-bit grouping amplifies the effect

Group-wise 4-bit quantization shares one scale factor across a block of weights; the rounding errors of a block are then correlated, and hypothesis (b) fails by design.

**Hypotheses (grouped dither).** Let $\mathrm{grp} : \{1,\dots,n\}\to G$ assign each key to a quantization group. Assume $\mathbb{E}[\eta_\omega(i)^2] = \sigma^2$ and, for $i \ne j$,
$$\mathbb{E}[\eta_\omega(i)\eta_\omega(j)] = \begin{cases}\rho\sigma^2 & \mathrm{grp}(i)=\mathrm{grp}(j),\\ 0 & \text{otherwise.}\end{cases}$$

**Definition 9.1.** For $i \in S$, the **same-group partner count** is $p_S(i) = \#\{j\in S : j\ne i,\ \mathrm{grp}(j)=\mathrm{grp}(i)\}$, and the **pair statistic** of the selection is $P(S) = \sum_{i\in S} p_S(i)$, the number of *ordered* same-group pairs in $S$.

**Theorem 9.2 (Exact grouped mean-square read).** For nonempty $S$ with $|S| = k$,
$$\mathbb{E}\big[(\mathrm{avg}_S\eta_\omega)^2\big] \;=\; \frac{\sigma^2 k + \rho\sigma^2 P(S)}{k^2}.$$

*Proof.* Expand $\mathrm{avg}_S\eta$ as $k^{-1}\sum_{i\in S}\eta_i$ and take the double sum. Row $i$ contributes $\sigma^2$ on the diagonal and $\rho\sigma^2$ for each of its $p_S(i)$ same-group partners in $S$, other off-diagonal terms vanishing. Summing over $i\in S$ gives $\sigma^2 k + \rho\sigma^2 P(S)$; divide by $k^2$. $\square$

**Corollary 9.3 (Group-spread selections are clean).** If no two selected keys share a group, $P(S)=0$ and the head transmits $\sigma^2/k$, exactly as in the uncorrelated model.

**Corollary 9.4 (Group-aligned selections are penalised).** If all selected keys lie in one group, $P(S) = k(k-1)$ and the head transmits
$$\frac{\sigma^2\big(1+\rho(k-1)\big)}{k},$$
which for $\rho>0$, $\sigma\ne0$, $k\ge2$ is strictly larger than $\sigma^2/k$.

### 9.1 The extreme case $\rho = 1$: all suppression is lost

Group-wise quantization shares *one* scale per group, so the extreme $\rho = 1$ — the errors of a whole group moving in lockstep — is the physically relevant model. It is realized exactly by the **shared-scale dither ensemble**: draw one sign $\omega_g \in \{\pm1\}$ per group $g$ uniformly and set $\eta_\omega(i) = \sigma\,\omega_{\mathrm{grp}(i)}$. This ensemble has $\mathbb{E}[\eta(i)^2] = \sigma^2$ and $\mathbb{E}[\eta(i)\eta(j)] = \sigma^2$ for same-group $i \ne j$, $0$ across groups.

**Theorem 9.5 (Total loss of averaging).** Under shared-scale dither, if all selected keys lie in a single quantization group then
$$\mathbb{E}\big[(\mathrm{avg}_S\eta_\omega)^2\big] = \sigma^2 .$$

The $1/k$ suppression that makes low-bit weights survivable disappears entirely: the sparse weighted sum averages nothing at all. Spreading the same $k$ keys across distinct groups restores $\sigma^2/k$ — a factor of $k$ in transmitted noise energy, obtainable purely by *which* keys the selector prefers among near-ties.

### 9.2 The pair statistic is a group occupancy profile

The penalty of Theorem 9.2 depends on the selection only through $P(S)$. That statistic can be computed exactly.

**Definition 9.6.** The **group occupancy profile** of $S$ is the vector $(m_t)_{t\in G}$ with $m_t = \#\{i\in S : \mathrm{grp}(i)=t\}$, so $\sum_t m_t = k$.

**Theorem 9.7 (Profile identity).**
$$P(S) \;=\; \sum_{t} m_t\,(m_t - 1).$$

*Proof.* Partition $S$ into the fibres of $\mathrm{grp}$. Every $i$ in the fibre over $t$ has $p_S(i) = m_t - 1$ same-group partners, and there are $m_t$ such $i$. Summing over $t$ gives the claim. $\square$

**Corollary 9.8 (Aligned is worst; spread is best).** $0 \le P(S) \le k(k-1)$ for every selection and every group structure. The upper bound is attained exactly when all of $S$ lies in one group, and $P(S) = 0$ exactly when no two selected keys share a group.

*Proof.* Non-negativity and the vanishing criterion are immediate. For the upper bound, $p_S(i) \le k-1$ for each of the $k$ elements. Attainment: aligned $S$ has $p_S(i) = k-1$ for all $i$. $\square$

**Theorem 9.9 (Variance form of the extremal statement).** For any $\rho \ge 0$ and any nonempty selection $S$ with $|S| = k$,
$$\mathbb{E}\big[(\mathrm{avg}_S\eta_\omega)^2\big] \;\le\; \frac{\sigma^2\big(1 + \rho(k-1)\big)}{k}.$$

*Proof.* Insert $P(S) \le k(k-1)$ (Corollary 9.8) into Theorem 9.2 and simplify. $\square$

So the group-aligned selection is the unique worst case, and no selection can do worse than the aligned bound — a complete extremal characterization of the grouped penalty.

### 9.3 Balanced profiles are the good ones

The profile identity turns the design problem into an optimization over occupancy vectors. The relevant structural property is that $x \mapsto x(x-1)$ is convex, so $P$ is a Schur-convex function of the profile: spreading mass out decreases it.

**Theorem 9.10 (Smoothing step).** For integers (indeed reals) $a, b$ with $b + 2 \le a$,
$$(a-1)(a-2) + (b+1)b \;<\; a(a-1) + b(b-1).$$

*Proof.* The difference of right and left sides equals $2(a - b - 1) > 0$ by hypothesis. $\square$

Concretely: moving one selected key from a group holding $a$ of them to a group holding $b \le a - 2$ strictly decreases $P(S)$. Iterating the smoothing step drives any profile toward balance, and the design rule follows.

> **Design rule.** Under group-wise quantization, among selections of equal attention quality, prefer the one whose group occupancy profile is most balanced. The transmitted quantization energy is a strictly increasing function of the profile's imbalance, ranging from $\sigma^2/k$ (perfectly spread) up to $\sigma^2(1+\rho(k-1))/k$ (fully aligned).

---

## 10. Removing the interaction: selection-aware recentering

Both mechanisms trace back to a single asymmetry: the quantizer centres its error over the *whole* weight block, while the sparse head reads it over a *subset*. Removing the asymmetry removes the effect.

**Theorem 10.1 (Recentering kills the interaction).** If the quantization error is centred on the selected set, $\sum_{i\in S}\eta_i = 0$, then
$$\mathrm{deg}_{AQ}(v,\eta,S) = \mathrm{deg}_A(v,S) \qquad\text{and}\qquad I(v,\eta,S) \le 0 .$$

*Proof.* The hypothesis gives $\mathrm{avg}_S\eta = 0$, so by (2.1) the combined error equals the sparsity bias exactly; then $I = -\mathrm{deg}_Q \le 0$. $\square$

The sharper form is that after recentering, $I = -\mathrm{deg}_Q$ exactly: the combined arm is *better* than the additive prediction by precisely the quantization-only degradation, because the quantization error is invisible to the sparse read by construction. Additivity becomes a valid (indeed conservative) budget law.

Practically this argues for **selection-aware calibration**: choose quantization offsets (or a per-head bias correction) so that the residual error has zero mean over the keys the head actually attends to, rather than over the full context. Combined with the group-diversification rule of §9.3, this yields two complementary and cheap mitigations, each targeting one of the two identified mechanisms.

---

## 11. Reconciling theory with the measurement

The theory makes four predictions that the measured table can be checked against.

1. **Sign.** The interaction is positive. Measured: $+2.51\%, +1.77\%, +1.60\%$ at $k=16,20,24$. ✔
2. **Monotonicity.** The interaction is antitone in $k$ (Theorem 4.3, Corollary 6.4). Measured: monotone decreasing. ✔
3. **Rate.** In mean square the interaction scales like $1/k - 1/n \approx 1/k$ for $k \ll n$. Anchoring at $k=16$, a pure $1/k$ law predicts $2.51\cdot 16/20 = 2.01\%$ at $k=20$ and $2.51\cdot 16/24 = 1.67\%$ at $k=24$, against measured $1.77\%$ and $1.60\%$. The observed decay is slightly faster than $1/k$ but of the right order and shape. ✔ (approximately)
4. **Amplification by grouping.** 4-bit group-128 quantization has $\rho$ substantially above $0$; §9 then predicts an interaction larger than the uncorrelated $\sigma^2(1/k-1/n)$, with the excess governed by how the selected keys distribute across groups. The measured interaction being of the same order as the attention-only loss itself is consistent with a correlated regime. ✔ (qualitatively)

Cross-entropy corroborates: combined excess $0.523$ nats versus additive prediction $0.395$ nats at $k=16$, a $32\%$ relative shortfall in the naive budget.

The theory also explains what would otherwise look like noise: because the interaction is *not* pointwise positive (Proposition 7.5), individual sequences in an evaluation corpus can show the combined arm beating the additive prediction. Only the corpus mean-square behaviour is guaranteed.

---

## 12. Algorithms

Three algorithmic recipes fall directly out of the theory.

**A. Interaction-corrected budget table.** Given per-axis measurements, do not report $L_{\text{attn}} + L_{\text{quant}}$. Report the interval
$$\big[\,L_{\text{attn}} + L_{\text{quant}},\ \ L_{\text{attn}} + L_{\text{quant}} + \varepsilon\min(1,(n-k)/k)\,\big]$$
in the worst case, or the point estimate $L_{\text{attn}} + L_{\text{quant}} + \sigma^2(1/k-1/n)$ in mean square (calibrating $\sigma$ from the quantizer's step size, $\sigma \approx \Delta/\sqrt{12}$ for uniform rounding of step $\Delta$).

**B. Margin-gated selection audit.** For each query position, compute the gap between the $k$-th and $(k{+}1)$-st clean scores. Positions with gap $\le 2\varepsilon$ are *at risk* of a selection flip under quantization (Theorems 5.2, 5.3); the fraction of at-risk positions is a directly measurable, model-specific predictor of the discrete component of the interaction. Complexity: one partial sort per position, $O(n \log k)$.

**C. Group-diversified top-$k$.** Among candidate keys whose scores lie within a tolerance $\tau$ of the top-$k$ cut, prefer those that reduce the group occupancy imbalance. Greedily: sort candidates by score; when admitting a key, break near-ties in favour of the least-occupied quantization group. By Theorem 9.10 each such swap strictly reduces $P(S)$ and hence the transmitted noise energy, at attention-quality cost bounded by $\tau$. Complexity: $O(n\log n)$ per position, no extra memory beyond a per-group counter.

---

## 13. Discussion and limitations

The model is deliberately minimal: a scalar-valued averaging head. This is a feature for the identities of §§7–9, which are exact in the model and dimension-free, but it means several realistic effects are outside its scope.

- **Depth.** A transformer stacks many heads and layers; the per-layer interaction terms compose in a way not modelled here. The empirical $2.51\%$ is a whole-network figure, whereas the theory prices a single head.
- **Data-dependent selection.** Theorem 7.2 treats $S$ as fixed. In reality $S$ depends on the (quantized) scores, so mechanisms (1) and (2) are coupled; §5 bounds when the coupling is inactive but does not integrate the two.
- **Value/key asymmetry.** We perturb values; quantization also perturbs the query–key products, which is what §5 models. A unified treatment would perturb both simultaneously.
- **Correlation structure.** The block-correlation model of §9 is a two-parameter idealization of what a real 4-bit group quantizer does; $\rho$ is not directly measurable without instrumenting the quantizer.

None of these weaken the central negative result: additivity is refuted as a matter of mathematics, not of measurement, by a four-key example, and the mean-square excess is an exact identity in a standard dither model.

---

## 14. Future work

Four directions are immediate.

1. **Global Schur-convexity.** Theorem 9.7 identifies the penalty with $\sum_t m_t(m_t-1)$, Theorem 9.10 supplies the smoothing step, and Corollary 9.8 the maximum. The remaining statement is the global minimum: among profiles with $\sum_t m_t = k$ and $m_t \le g$ (group capacity), the balanced profiles minimise $\sum_t m_t(m_t-1)$. The smoothing step makes this a routine majorization argument, but it should be recorded.
2. **Softmax temperature monotonicity.** Theorem 8.3 shows peaked patterns pay more. Making the dependence quantitative — the transmitted energy $\sum_i w_i^2$ as a monotone function of inverse temperature for a fixed score vector — would let one trade attention sharpness against quantization robustness explicitly.
3. **Coupling the two mechanisms.** Bound the total interaction when $S$ itself is chosen from perturbed scores, combining the $2\varepsilon$ margin analysis with the mean-square identity, ideally as an expectation over a score-gap distribution.
4. **Multi-layer composition.** Determine whether the per-layer interaction accumulates additively, multiplicatively, or sub-linearly in depth; this is what converts a per-head identity into a network-level budget law.

---

## 15. Conclusion

Combining low-bit weight quantization with top-$k$ sparse attention is super-additive: the degradation of the pair exceeds the sum of the degradations of the parts. The excess is not an artifact. In the worst case it is exactly $\varepsilon\min(1,(n-k)/k)$ and equals a full quantization step whenever the attention budget is at most half the context. In mean square it is exactly $\sigma^2(1/k - 1/n)$, strictly positive for every sparse budget, and it grows as the budget shrinks. Peaked (softmax) attention pays more, not less. Group-wise quantization can multiply the penalty by up to $k$, and does so exactly when the selected keys concentrate in a single quantization group — a condition characterized completely by the group occupancy profile, whose penalty $\sum_t m_t(m_t-1)$ is maximal for aligned selections and zero for spread ones.

The corrective is equally precise: diversify the selection across quantization groups, and centre the quantization error on the keys the head actually reads. Do both, and the additive budget law becomes valid again. Do neither, and a 4-bit model with a 24-key attention window is decidedly not a 4-bit model plus a 24-key cache.
