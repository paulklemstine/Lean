# The Price of Universality: Exact Minimax Redundancy of Universal Decompressors

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

A universal decompressor must serve an entire class of sources with a single, shared program; a specialized decompressor is tuned to one source. The number of extra bits the universal scheme pays is the *price of universality*. We give a complete, finitary and fully explicit treatment of this quantity for finite classes of sources on finite alphabets, in both its average-case and its worst-case forms.

In the average-case setting we prove a compensation identity — a Pythagorean decomposition of relative entropy — which yields the redundancy–capacity lower bound: for every prior $\pi$ on the class, some source pays at least the mutual information $I(\pi)$ bits of redundancy under any code. A matching construction (the Shannon code of the uniform mixture) pays at most $\log_2 m + 1$ bits on every member of a class of $m$ sources, giving the sandwich $\log_2 m \le \text{minimax redundancy} \le \log_2 m + 1$ for classes of $m$ perfectly distinguishable sources.

In the worst-case (pointwise regret) setting we remove the one-bit slack entirely: the minimax regret of a finite class $\mathcal{P} = \{p_\theta\}$ equals exactly $\log_2 S(\mathcal{P})$, where $S(\mathcal{P}) = \sum_a \max_\theta p_\theta(a)$ is the Shtarkov sum, with the optimum attained by the normalized maximum likelihood distribution. We establish the structural theory of $S$: $1 \le S \le m$; $S = m$ exactly for perfectly distinguishable classes and $S < m$ strictly otherwise; $S(\{p_0,p_1\}) = 1 + \mathrm{TV}(p_0,p_1)$ in closed form; and $S$ is multiplicative over independent components, so $\log_2 S$ is additive.

We then instantiate the theory on the class of memoryless binary sources of block length $n$. Using only the first two moments of the binomial law and Chebyshev's inequality we prove $S_n \ge \sqrt{n}/4$, and a term-by-term bound gives $S_n \le n+1$, whence

$$\tfrac12 \log_2 n - 2 \;\le\; \text{minimax regret} \;\le\; \log_2 (n+1).$$

This reproduces Rissanen's $\tfrac{k}{2}\log n$ redundancy rate at $k = 1$ with explicit non-asymptotic constants; additivity upgrades it to $k\big(\tfrac12\log_2 n - 2\big) \le \text{regret} \le k\log_2(n+1)$ for $k$ independent blocks, and shows the price is unbounded in the number of parameters. Finally we quantify the value of specialization: restricting to a subclass $\mathcal{P}' \subseteq \mathcal{P}$ saves at most $\log_2\big(S(\mathcal{P})/S(\mathcal{P}')\big)$ bits pointwise, with equality where the maximum likelihood is attained inside the subclass. The engineering verdict follows: specialization does move bits from the message into the shared decompressor, but only $\log_2(\text{class complexity})$ of them — an $O(\log n)$ saving against a $\Theta(n)$-bit message in every parametric regime.

**Keywords:** minimax redundancy, universal source coding, Shtarkov sum, normalized maximum likelihood, redundancy–capacity theorem, Rissanen rate, Bernoulli class, total variation distance.

---

## 1. Introduction

### 1.1 The question

Data compression is asymmetric. The compressor sees the data; the decompressor is fixed in advance and must be shared by all users of the format. This asymmetry is the origin of a basic engineering question: *how much would we gain by shipping a decompressor specialized to a class of data, instead of a universal one?*

The question is not rhetorical. A universal scheme is a single length function $L$ that must be good simultaneously for every source in a class $\mathcal{P}$. A specialized scheme may be tailored to a single $p \in \mathcal{P}$, and — by Shannon's theorem — can then operate within one bit of the entropy $H(p)$. The excess of the universal scheme over this ideal is the price we wish to compute, and the question is whether the price is large enough that moving bits from the message into the decompressor is worth the loss of generality.

### 1.2 What is proved here

We work throughout with a finite message alphabet $\mathcal{A}$ and a finite index set $\Theta$; everything is exact and finitary, with no asymptotics hidden in the statements. The contributions are:

1. **The average-case price** (Section 3). A compensation identity for relative entropy, the resulting redundancy–capacity lower bound, a matching mixture-code upper bound, and their combination into an exact-up-to-one-bit answer $\log_2 m$ for classes of $m$ perfectly distinguishable sources.
2. **The worst-case price, exactly** (Section 4). The minimax pointwise regret of a finite class equals $\log_2 S$ with $S$ the Shtarkov sum, with both achievability (via normalized maximum likelihood) and a converse valid for arbitrary sub-probability coding weights, and hence for genuine integer code lengths obeying Kraft's inequality.
3. **Structure of the Shtarkov sum** (Section 5). Bounds $1 \le S \le m$; a rigidity theorem characterizing the extreme case $S = m$; the closed form $S = 1 + \mathrm{TV}$ for two-source classes; and multiplicativity over independent components.
4. **A Rissanen-style rate from first principles** (Section 6). An elementary development of the binomial moments and Chebyshev's inequality, and the resulting two-sided bound $\tfrac12\log_2 n - 2 \le \log_2 S_n \le \log_2(n+1)$ for the memoryless binary class.
5. **Multi-parameter rates and unboundedness** (Section 7).
6. **The value of specialization, and the verdict** (Sections 8–9).

### 1.3 Relation to the classical picture

The three pillars of the classical theory of universal coding are: the redundancy–capacity theorem (minimax average redundancy equals the capacity of the channel from source label to message), Shtarkov's normalized maximum likelihood construction (minimax pointwise regret equals $\log$ of the Shtarkov sum), and Rissanen's $\tfrac{k}{2}\log n$ rate for smooth $k$-parameter families. This paper gives self-contained, quantitatively explicit versions of all three in the finite setting, together with structural results (rigidity, the total-variation formula, exact pricing of specialization) that sharpen the picture into an answer to the engineering question.

---

## 2. Setting and basic quantities

Let $\mathcal{A}$ be a finite nonempty set of *messages*.

**Definition 2.1 (Code).** A *length function* is a map $L : \mathcal{A} \to \mathbb{N}$. Its *Kraft sum* is $\kappa(L) = \sum_{a \in \mathcal{A}} 2^{-L(a)}$, and $L$ is a *code* if $\kappa(L) \le 1$. By the Kraft–McMillan theorem this is exactly the constraint satisfied by uniquely decodable codes, so nothing is lost by working with length functions rather than explicit encoders.

**Definition 2.2 (Distributions and information quantities).** A function $p : \mathcal{A} \to \mathbb{R}$ is a *probability mass function* if $p \ge 0$ pointwise and $\sum_a p(a) = 1$. For such $p$, and for arbitrary positive weights $q$, define (all logarithms base $2$, so all quantities are in bits):

$$H(p) = -\sum_a p(a)\log_2 p(a), \qquad D(p\|q) = \sum_a p(a)\log_2\frac{p(a)}{q(a)},$$
$$\mathbb{E}_p[L] = \sum_a p(a) L(a), \qquad R(p, L) = \mathbb{E}_p[L] - H(p).$$

We adopt the standard conventions $0\log 0 = 0$ and $\log 0 = 0$ in the summands where the coefficient vanishes; every statement below is insensitive to these conventions because the offending terms are always multiplied by a zero probability.

**Lemma 2.3 (Gibbs' inequality).** If $p$ is a probability mass function and $q > 0$ satisfies $\sum_a q(a) \le 1$, then $D(p\|q) \ge 0$.

*Proof sketch.* From $\log x \le x - 1$ one gets the pointwise bound $p(a)\ln\frac{q(a)}{p(a)} \le q(a) - p(a)$, valid also at $p(a)=0$. Summing over $a$ gives $\sum_a p(a)\ln\frac{q(a)}{p(a)} \le \sum_a q(a) - 1 \le 0$. Dividing by $\ln 2$ and flipping the sign of the log-ratio yields $D(p\|q)\ge 0$. $\square$

**Proposition 2.4 (Redundancy is a divergence).** For every probability mass function $p$ and length function $L$,
$$R(p, L) = D\big(p \,\big\|\, 2^{-L}\big).$$

*Proof sketch.* On each message with $p(a) > 0$, $\log_2\frac{p(a)}{2^{-L(a)}} = \log_2 p(a) + L(a)$; multiply by $p(a)$ and sum, recognizing $\mathbb{E}_p[L] - H(p)$. Messages with $p(a)=0$ contribute nothing on either side. $\square$

**Corollary 2.5 (Source coding bound).** If $L$ is a code and $p$ a probability mass function then $H(p) \le \mathbb{E}_p[L]$, i.e. $R(p,L) \ge 0$.

**Definition 2.6 (Shannon code).** For a strictly positive $p$, put $L_p(a) = \lceil -\log_2 p(a)\rceil$.

**Proposition 2.7 (The specialist pays at most one bit).** For strictly positive $p$, $L_p$ is a code and $R(p, L_p) \le 1$.

*Proof sketch.* Kraft: $2^{-L_p(a)} \le 2^{\log_2 p(a)} = p(a)$, so $\kappa(L_p) \le \sum_a p(a) = 1$. Redundancy: $L_p(a) \le -\log_2 p(a) + 1$, so $\mathbb{E}_p[L_p] \le H(p) + 1$. $\square$

Propositions 2.4–2.7 fix the baseline. A decompressor that knows the source is essentially free of overhead; everything we compute below is therefore genuinely the cost of *not knowing*.

---

## 3. The average-case price: mutual information

Fix a finite family $\mathcal{P} = \{p_\theta\}_{\theta\in\Theta}$ of probability mass functions on $\mathcal{A}$, and a *prior* $\pi$ on $\Theta$.

**Definition 3.1.** The *Bayes mixture* is $\bar p_\pi(a) = \sum_\theta \pi(\theta) p_\theta(a)$, and the *mutual information* of the prior is
$$I(\pi) = \sum_\theta \pi(\theta)\, D(p_\theta \,\|\, \bar p_\pi),$$
i.e. the mutual information between the source label $\theta \sim \pi$ and the message $a \sim p_\theta$.

**Theorem 3.2 (Compensation identity).** Let $\pi$ be a strictly positive prior and $q$ a strictly positive weight function on $\mathcal{A}$. Then
$$\sum_\theta \pi(\theta)\, D(p_\theta\|q) \;=\; I(\pi) \;+\; D(\bar p_\pi \| q).$$

*Proof sketch.* For every $\theta$ and every $a$ with $p_\theta(a) > 0$ we have $\bar p_\pi(a) > 0$ (because $\pi(\theta) > 0$), so the log-ratio splits:
$$\log_2 \frac{p_\theta(a)}{q(a)} = \log_2\frac{p_\theta(a)}{\bar p_\pi(a)} + \log_2\frac{\bar p_\pi(a)}{q(a)}.$$
Multiplying by $\pi(\theta)p_\theta(a)$ and summing over $\theta$ and $a$: the first group of terms assembles to $I(\pi)$ by definition, while in the second group the sum over $\theta$ of $\pi(\theta)p_\theta(a)$ is exactly $\bar p_\pi(a)$, producing $D(\bar p_\pi\|q)$. $\square$

This identity is the algebraic heart of the redundancy–capacity theorem: it says that the average distance from the class to a coding distribution $q$ decomposes orthogonally into an irreducible part (the spread of the class about its own centre of mass) and a part measuring how badly $q$ misses that centre of mass.

**Theorem 3.3 (Redundancy–capacity lower bound, average form).** For every strictly positive prior $\pi$ and every code $L$,
$$I(\pi) \;\le\; \sum_\theta \pi(\theta)\, R(p_\theta, L).$$

*Proof sketch.* Apply Proposition 2.4 with $q = 2^{-L}$, then Theorem 3.2, and discard the nonnegative term $D(\bar p_\pi \| 2^{-L}) \ge 0$, which is nonnegative by Gibbs' inequality since $\kappa(L)\le 1$. $\square$

**Corollary 3.4 (Minimax form).** For every strictly positive prior $\pi$ and every code $L$ there exists $\theta$ with $R(p_\theta, L) \ge I(\pi)$.

*Proof sketch.* A weighted average is at most its maximum term. $\square$

Thus every prior on the class certifies a lower bound on the price of universality; the best such certificate is the channel capacity $\sup_\pi I(\pi)$, whence the classical name.

For the matching upper bound we use the uniform mixture. Write $m = |\Theta|$ and $\bar p = \bar p_{\mathrm{unif}}$.

**Lemma 3.5.** For every $\theta$, $D(p_\theta \| \bar p) \le \log_2 m$.

*Proof sketch.* Pointwise, $\bar p(a) \ge \frac{1}{m} p_\theta(a)$, since the mixture contains the term $\frac1m p_\theta(a)$ and all terms are nonnegative. Hence $p_\theta(a)/\bar p(a) \le m$ wherever $p_\theta(a)>0$, and averaging $\log_2$ of this ratio against $p_\theta$ gives at most $\log_2 m$. $\square$

**Theorem 3.6 (Upper bound on the price).** Suppose every message has positive probability under the uniform mixture. Then the Shannon code $L_{\bar p}$ of the mixture is a code, and
$$R(p_\theta, L_{\bar p}) \;\le\; \log_2 m + 1 \qquad \text{for every } \theta .$$

*Proof sketch.* $L_{\bar p}$ is a code by Proposition 2.7 applied to $\bar p$. For redundancy: $L_{\bar p}(a) \le -\log_2\bar p(a) + 1$, so $\mathbb{E}_{p_\theta}[L_{\bar p}] \le \sum_a p_\theta(a)\big(-\log_2 \bar p(a)\big) + 1 = H(p_\theta) + D(p_\theta\|\bar p) + 1$. Apply Lemma 3.5. $\square$

**Definition 3.7 (Perfect distinguishability).** The class has *disjoint supports* if for all $\theta \ne \theta'$ and all $a$, $p_\theta(a) > 0$ implies $p_{\theta'}(a) = 0$: one observation identifies the source.

**Lemma 3.8.** If the class has disjoint supports then $I(\mathrm{unif}) = \log_2 m$ exactly.

*Proof sketch.* On the support of $p_\theta$, all other terms of the mixture vanish, so $\bar p(a) = \frac1m p_\theta(a)$ and the log-ratio is identically $\log_2 m$ there. Averaging gives $D(p_\theta\|\bar p) = \log_2 m$ for each $\theta$, hence the same for the average. $\square$

**Theorem 3.9 (The price of universality, average-case).** Let $\{p_\theta\}$ be a class of $m$ sources with pairwise disjoint supports, every message covered by the uniform mixture. Then:

1. for every code $L$ there is a source $\theta$ with $R(p_\theta, L) \ge \log_2 m$;
2. there is a single code $L$ with $R(p_\theta, L) \le \log_2 m + 1$ for every $\theta$.

*Proof sketch.* (1) Corollary 3.4 with the uniform prior, then Lemma 3.8. (2) Theorem 3.6. $\square$

The price of universality over a class of $m$ mutually distinguishable sources is therefore $\log_2 m$ bits, up to one bit: exactly the cost of naming the source.

---

## 4. The worst-case price, exactly: the Shtarkov sum

Averages hide the one-bit slack of the Shannon code. Scoring *pointwise regret* against the best member of the class removes it.

**Definition 4.1.** The *maximum likelihood envelope* of the class is $\widehat p(a) = \max_\theta p_\theta(a)$; the *Shtarkov sum* is
$$S(\mathcal{P}) = \sum_{a\in\mathcal{A}} \widehat p(a),$$
and the *normalized maximum likelihood* (NML) distribution is $p^{\mathrm{NML}}(a) = \widehat p(a)/S(\mathcal{P})$.

**Lemma 4.2.** $S(\mathcal{P}) \ge 1$, with $S(\mathcal{P}) = 1$ if the class is a singleton; consequently $S > 0$ and $p^{\mathrm{NML}}$ is a probability mass function.

*Proof sketch.* $\widehat p \ge p_\theta$ pointwise for any fixed $\theta$, and $p_\theta$ sums to one. Normalization is immediate. $\square$

**Theorem 4.3 (Achievability).** For every $\theta$ and every $a$,
$$p_\theta(a) \le S(\mathcal{P}) \cdot p^{\mathrm{NML}}(a), \qquad\text{hence}\qquad \log_2\frac{p_\theta(a)}{p^{\mathrm{NML}}(a)} \le \log_2 S(\mathcal{P}).$$
That is, the codelength $-\log_2 p^{\mathrm{NML}}(a)$ exceeds the ideal codelength $-\log_2 p_\theta(a)$ of *every* member of the class by at most $\log_2 S(\mathcal{P})$ bits, uniformly in the message.

*Proof sketch.* Immediate from $p_\theta(a)\le \widehat p(a) = S\,p^{\mathrm{NML}}(a)$. $\square$

**Theorem 4.4 (Converse).** Let $q : \mathcal{A}\to\mathbb{R}$ satisfy $\sum_a q(a)\le 1$. Then there exist $\theta$ and $a$ with $p_\theta(a) \ge S(\mathcal{P})\, q(a)$. If moreover $q > 0$, then $\log_2\frac{p_\theta(a)}{q(a)} \ge \log_2 S(\mathcal{P})$ for that pair.

*Proof sketch.* Suppose not: $p_\theta(a) < S q(a)$ for all $\theta, a$. Taking the maximum over $\theta$ gives $\widehat p(a) < S q(a)$ for all $a$; summing over the (nonempty, finite) alphabet gives the strict inequality $S = \sum_a \widehat p(a) < S\sum_a q(a) \le S$, a contradiction. $\square$

**Theorem 4.5 (Exact minimax regret).** For a finite class of sources whose envelope is strictly positive, the minimax pointwise regret is exactly $\log_2 S(\mathcal{P})$: the NML distribution attains regret at most $\log_2 S$ uniformly (Theorem 4.3), and no sub-probability coding distribution attains regret below $\log_2 S$ in the worst case (Theorem 4.4).

**Corollary 4.6 (Integer code lengths).** For every code $L$ there exist $\theta$ and $a$ with
$$L(a) + \log_2 p_\theta(a) \;\ge\; \log_2 S(\mathcal{P}),$$
i.e. $L$ spends at least $\log_2 S$ bits more on the message $a$ than the ideal codelength of the best-fitting source.

*Proof sketch.* Apply Theorem 4.4 to $q(a) = 2^{-L(a)}$, which is strictly positive and has $\sum_a q(a) = \kappa(L) \le 1$; then $\log_2\frac{p_\theta(a)}{2^{-L(a)}} = \log_2 p_\theta(a) + L(a)$. $\square$

**Proposition 4.7 (Average vs. worst case).** For every strictly positive prior $\pi$, $I(\pi) \le \log_2 S(\mathcal{P})$; and for every $\theta$, $D(p_\theta \| p^{\mathrm{NML}}) \le \log_2 S(\mathcal{P})$.

*Proof sketch.* The second claim follows by averaging the pointwise bound of Theorem 4.3 against $p_\theta$. The first then follows from the compensation identity (Theorem 3.2) applied with $q = p^{\mathrm{NML}}$: the average of the $D(p_\theta\|p^{\mathrm{NML}})$ equals $I(\pi) + D(\bar p_\pi\|p^{\mathrm{NML}}) \ge I(\pi)$. $\square$

So the two prices are consistent: the average-case price never exceeds the worst-case price, as it must.

---

## 5. Structure of the Shtarkov sum

The Shtarkov sum is not just an optimization value; it is a measure of the *statistical distinguishability* of the class.

**Proposition 5.1 (Cardinality bound).** $\widehat p(a) \le \sum_\theta p_\theta(a)$ pointwise, hence $S(\mathcal{P}) \le m = |\Theta|$.

**Theorem 5.2 (Rigidity).** $S(\mathcal{P}) = m$ if and only if the class has pairwise disjoint supports. Consequently, if two members of the class can produce a common message then $S(\mathcal{P}) < m$ strictly, and $\log_2 S(\mathcal{P}) < \log_2 m$: the naive "transmit the source label, then use the specialist" scheme is strictly suboptimal.

*Proof sketch.* ($\Leftarrow$) If supports are disjoint, then for each $a$ at most one $p_\theta(a)$ is nonzero, so $\widehat p(a) = \sum_\theta p_\theta(a)$; summing over $a$ and exchanging the order of summation gives $S = \sum_\theta 1 = m$. ($\Rightarrow$) Since $\widehat p(a)\le \sum_\theta p_\theta(a)$ pointwise and both sides sum to $S$ and $m$ respectively, equality of the totals forces equality at every $a$; and equality at $a$ forces at most one $\theta$ with $p_\theta(a) > 0$. $\square$

**Theorem 5.3 (Two sources: closed form).** For a class $\{p_0, p_1\}$,
$$S = 1 + \mathrm{TV}(p_0,p_1), \qquad \mathrm{TV}(p_0,p_1) = \tfrac12\sum_a |p_0(a)-p_1(a)| .$$
Hence the exact minimax regret of a two-source class is $\log_2\big(1 + \mathrm{TV}(p_0,p_1)\big)$ bits, which lies in $[0,1]$, is monotone in the total variation distance, and equals exactly one bit if and only if $\mathrm{TV} = 1$, i.e. if and only if the two sources have disjoint supports.

*Proof sketch.* Pointwise $\max(x,y) = \frac{x+y+|x-y|}{2}$. Summing, $S = \frac{1 + 1 + 2\,\mathrm{TV}}{2} = 1 + \mathrm{TV}$. The range statement follows from $0\le \mathrm{TV}\le 1$ (the upper bound is Proposition 5.1 with $m=2$), and the equality case from Theorem 5.2. $\square$

This is the cleanest possible statement of the phenomenon: *ambiguity is a discount*. Two sources that are statistically hard to tell apart are cheap to serve with one decompressor; the price rises continuously with total variation distance to a maximum of one bit.

**Theorem 5.4 (Multiplicativity over independent components).** Let $\mathcal{P} = \{p_\theta\}$ act on $\mathcal{A}$ and $\mathcal{Q} = \{q_\psi\}$ on $\mathcal{B}$, and let $\mathcal{P}\otimes\mathcal{Q}$ be the class on $\mathcal{A}\times\mathcal{B}$ with members $(a,b)\mapsto p_\theta(a) q_\psi(b)$ indexed by $(\theta,\psi)$. Then
$$S(\mathcal{P}\otimes\mathcal{Q}) = S(\mathcal{P})\,S(\mathcal{Q}), \qquad \log_2 S(\mathcal{P}\otimes\mathcal{Q}) = \log_2 S(\mathcal{P}) + \log_2 S(\mathcal{Q}).$$
More generally, for a finite family $(\mathcal{P}_i)_{i\in I}$ of classes acting on independent components,
$$S\Big(\bigotimes_{i} \mathcal{P}_i\Big) = \prod_i S(\mathcal{P}_i), \qquad \log_2 S\Big(\bigotimes_i \mathcal{P}_i\Big) = \sum_i \log_2 S(\mathcal{P}_i).$$

*Proof sketch.* The envelope factorizes: $\max_{(\theta,\psi)} p_\theta(a)q_\psi(b) = \big(\max_\theta p_\theta(a)\big)\big(\max_\psi q_\psi(b)\big)$, because the parameters range independently and all quantities are nonnegative (one inequality is termwise, the other is attained at the pair of individual maximizers). Summing the product over the product alphabet factorizes the sum. The general case follows by the distributive law for sums of products over a finite index set. $\square$

**Corollary 5.5.** *The price of universality is additive over independent components.* This is exactly where the factor $k$ in the $\tfrac{k}{2}\log n$ rate originates: each independent free parameter contributes its own copy of the bill.

---

## 6. The memoryless binary class and the $\tfrac12 \log_2 n$ rate

We now compute the price for the canonical parametric class.

**Definition 6.1.** Messages are binary strings of length $n$, identified with subsets $s$ of positions carrying a one; write $|s|$ for the number of ones. The memoryless (i.i.d. Bernoulli) source with bias $t \in [0,1]$ assigns
$$p_t(s) = t^{|s|}(1-t)^{n-|s|}.$$
The *memoryless binary class of block length $n$* is $\mathcal{B}_n = \{p_{j/n} : j = 0,1,\dots,n\}$, indexed by the maximum-likelihood grid: $j/n$ is exactly the maximum-likelihood bias for a string with $j$ ones, so restricting to the grid loses nothing in the envelope.

### 6.1 Binomial ingredients

Write $b_{n,t}(k) = \binom{n}{k} t^k (1-t)^{n-k}$ for the binomial weights.

**Lemma 6.2 (Normalization).** $\sum_{k=0}^{n} b_{n,t}(k) = 1$. *(Binomial theorem applied to $\big(t + (1-t)\big)^n$.)*

**Lemma 6.3 (Reindexing).** For all $m, j$ and $t$,
$$(j+1)\, b_{m+1,t}(j+1) = (m+1)\, t\, b_{m,t}(j),$$
because $(j+1)\binom{m+1}{j+1} = (m+1)\binom{m}{j}$ and the powers of $t$ and $1-t$ match after the shift.

**Proposition 6.4 (First two moments).** For all $n$ and $t$,
$$\sum_{k=0}^{n} k\, b_{n,t}(k) = nt, \qquad \sum_{k=0}^{n} k^2\, b_{n,t}(k) = nt\big((n-1)t + 1\big),$$
and hence
$$\sum_{k=0}^{n} (k - nt)^2\, b_{n,t}(k) = nt(1-t).$$

*Proof sketch.* Both moments follow from Lemma 6.3, which converts a sum weighted by $k$ over block length $n = m+1$ into $(m+1)t$ times an unweighted sum over block length $m$: taking the inner function constant gives the mean, and taking it linear gives the second moment (using the mean and normalization at level $m$). The variance identity is the expansion $(k-nt)^2 = k^2 - 2nt\,k + (nt)^2$ combined with the two moments and Lemma 6.2. $\square$

**Theorem 6.5 (Chebyshev for the binomial law).** Let $0 \le t \le 1$, $d > 0$, and let $K \subseteq \{0,\dots,n\}$ satisfy $(k - nt)^2 \ge d^2$ for all $k \in K$. Then
$$\sum_{k\in K} b_{n,t}(k) \;\le\; \frac{nt(1-t)}{d^2}.$$
Consequently, if $K$ is any set containing all indices with $(k-nt)^2 < d^2$, then $\sum_{k\in K} b_{n,t}(k) \ge 1 - \frac{nt(1-t)}{d^2}$.

*Proof sketch.* On $K$ we have $d^2 b_{n,t}(k) \le (k-nt)^2 b_{n,t}(k)$; summing over $K$, then enlarging to the full range (all terms nonnegative), gives $d^2\sum_{K} b_{n,t} \le nt(1-t)$ by Proposition 6.4. The concentration form follows by complementation with Lemma 6.2. $\square$

### 6.2 The upper bound

**Theorem 6.6.** $S(\mathcal{B}_n) \le n+1$, hence the minimax regret of $\mathcal{B}_n$ is at most $\log_2(n+1)$.

*Proof sketch.* The envelope depends on a string only through its number of ones $k$, so grouping strings by $k$,
$$S(\mathcal{B}_n) = \sum_{k=0}^{n}\binom{n}{k}\, \widehat\ell(k), \qquad \widehat\ell(k) = \max_{j}\ (j/n)^k(1-j/n)^{n-k}.$$
For each $k$ the maximum is attained at some grid point $j^*$, and then $\binom{n}{k}\widehat\ell(k) = b_{n, j^*/n}(k)$ is a single term of a probability distribution over $k$, hence at most $1$. Summing $n+1$ terms gives the bound. $\square$

Equivalently, in achievability form: the NML code for $\mathcal{B}_n$ never loses more than a factor $n+1$ (i.e. $\log_2(n+1)$ bits) against the best-fitting bias, on any string.

### 6.3 The lower bound: counting distinguishable coins

**Theorem 6.7.** For every $n \ge 1$, $S(\mathcal{B}_n) \ge \sqrt{n}/4$.

*Proof sketch.* The argument realizes, quantitatively, the slogan "the class contains about $\sqrt n$ mutually distinguishable sources".

*Step 1 (windows dominate).* If $(K_i)_{i\in I}$ is a family of pairwise disjoint subsets of $\{0,\dots,n\}$ and for each $i$ we choose a grid bias $t_i$, then
$$\sum_{i\in I}\sum_{k\in K_i} b_{n,t_i}(k) \;\le\; S(\mathcal{B}_n).$$
Indeed $b_{n,t_i}(k) \le \binom{n}{k}\widehat\ell(k)$ termwise, and disjointness allows the double sum to be rewritten as a sum over the union, which is a subsum of $\sum_k \binom{n}{k}\widehat\ell(k) = S(\mathcal{B}_n)$ with nonnegative terms.

*Step 2 (each window catches three quarters of its own source).* Put $d = \lfloor\sqrt n\rfloor + 1$, so $d^2 > n$. Place centres $c_i = 2di$ for $0 \le i \le \lfloor n/(2d)\rfloor$ (so $c_i \le n$), let $K_i = \{k \le n : |k - c_i| < d\}$, and let $t_i = c_i/n$, a grid point. Then $\mathbb{E}[K] = n t_i = c_i$ and $\mathrm{Var}(K) = n t_i(1-t_i) \le n/4 < d^2/4$. Every $k \notin K_i$ satisfies $(k-c_i)^2 \ge d^2$, so Theorem 6.5 gives
$$\sum_{k\in K_i} b_{n,t_i}(k) \;\ge\; 1 - \frac{n t_i(1-t_i)}{d^2} \;\ge\; 1 - \tfrac14 \;=\; \tfrac34 .$$

*Step 3 (count the windows).* The windows are pairwise disjoint because consecutive centres are $2d$ apart while each window has width $< 2d$. There are $\lfloor n/(2d)\rfloor + 1$ of them, so Steps 1–2 give
$$S(\mathcal{B}_n) \;\ge\; \tfrac34\left(\left\lfloor\frac{n}{2d}\right\rfloor + 1\right).$$

*Step 4 (arithmetic).* Since $d \le \sqrt n + 1$, one has $\lfloor n/(2d)\rfloor + 1 > n/(2d) \ge \frac{n}{2(\sqrt n + 1)} \ge \frac{\sqrt n}{3}$ whenever $\sqrt n \ge 2$; hence $S \ge \tfrac34\cdot\tfrac{\sqrt n}{3} = \sqrt n /4$. For $\sqrt n \le 3$ the bound $S \ge 3/4 \ge \sqrt n/4$ holds trivially because there is always at least one window. $\square$

**Theorem 6.8 (Two-sided rate for memoryless binary sources).** For every $n \ge 1$,
$$\tfrac12\log_2 n - 2 \;\le\; \log_2 S(\mathcal{B}_n) \;\le\; \log_2 (n+1).$$
Equivalently: every code $L$ for binary strings of length $n$ admits a string $s$ and a bias $j/n$ with
$$L(s) + \log_2 p_{j/n}(s) \;\ge\; \tfrac12\log_2 n - 2,$$
while the NML code achieves regret at most $\log_2(n+1)$ uniformly.

*Proof sketch.* Take $\log_2$ in Theorems 6.6 and 6.7, using $\log_2(\sqrt n/4) = \frac12\log_2 n - 2$; then apply Corollary 4.6 for the statement about codes and Theorem 4.3 for the achievability statement. $\square$

This is Rissanen's $\frac{k}{2}\log n$ redundancy rate at $k=1$, with explicit constants and no asymptotics. The truth is pinned between $\frac12\log_2 n$ and $\log_2 n$; the classical asymptotic answer, $\frac12\log_2 n + O(1)$, sits at the lower end. The factor-of-two gap is the price of the Chebyshev argument: using only two moments, each "distinguishable coin" is resolved at scale $\sqrt n$ rather than at the sharp Fisher-information scale.

---

## 7. Multi-parameter rates

**Definition 7.1.** For $k, n \ge 0$ let $\mathcal{B}_n^{\otimes k}$ be the class of $k$ independent memoryless binary blocks of length $n$, each with its own grid bias: messages are $k$-tuples of binary strings of length $n$, parameters are $k$-tuples of grid biases, and probabilities multiply.

**Theorem 7.2 ($k$-parameter Rissanen rate).** For every $n\ge 1$ and every $k$,
$$k\left(\tfrac12\log_2 n - 2\right) \;\le\; \log_2 S\big(\mathcal{B}_n^{\otimes k}\big) \;\le\; k\,\log_2(n+1).$$
Hence every code for $k$ independent blocks suffers, on some message and against some member of the class, a regret of at least $k\big(\frac12\log_2 n - 2\big)$ bits; and the NML code for the product class attains regret at most $k\log_2(n+1)$ bits uniformly.

*Proof sketch.* Additivity (Theorem 5.4 / Corollary 5.5) reduces the product class to $k$ copies of the one-block bound of Theorem 6.8. The code statements follow from Corollary 4.6 and Theorem 4.3. $\square$

**Theorem 7.3 (Unboundedness in the number of parameters).** For every target $C$ and every block length $n \ge 32$ there is a number of components $k$ such that every code for $\mathcal{B}_n^{\otimes k}$ pays more than $C$ bits of regret on some message against some member of the class.

*Proof sketch.* For $n\ge 32$ we have $\frac12\log_2 n - 2 \ge \frac52 - 2 > 0$, so the lower bound of Theorem 7.2 is a positive multiple of $k$; choose $k > C/\big(\frac12\log_2 n - 2\big)$. $\square$

The contrast between Theorems 6.8 and 7.3 is the essential structural message: the price grows only *logarithmically* in the resolution $n$ of a single parameter, but *linearly* in the number of parameters.

---

## 8. What specialization is worth

We can now price specialization exactly. Let $\mathcal{P}' \subseteq \mathcal{P}$ be a subclass (formally, $\mathcal{P}' = \{p_{e(\tau)}\}_{\tau}$ for a map $e$ into the index set of $\mathcal{P}$).

**Proposition 8.1 (Monotonicity).** The envelope of a subclass is pointwise below that of the full class, so $S(\mathcal{P}') \le S(\mathcal{P})$: a narrower class is always cheaper to serve.

**Theorem 8.2 (Invariance with an explicit price).** For every message $a$ at which the subclass envelope is positive,
$$\log_2 p^{\mathrm{NML}}_{\mathcal{P}'}(a) - \log_2 p^{\mathrm{NML}}_{\mathcal{P}}(a) \;\le\; \log_2\frac{S(\mathcal{P})}{S(\mathcal{P}')},$$
i.e. the specialized code is shorter than the general one by at most $\log_2\big(S(\mathcal{P})/S(\mathcal{P}')\big)$ bits. Equality holds at every message whose maximum likelihood over $\mathcal{P}$ is already attained inside $\mathcal{P}'$.

*Proof sketch.* Expand both NML logarithms as (log envelope) $-$ (log Shtarkov sum); the envelope terms compare by Proposition 8.1, and coincide precisely under the stated equality hypothesis. $\square$

**Example 8.3 (The deterministic class).** Let $\mathcal{I}_m$ consist of the $m$ deterministic sources on an alphabet of $m$ letters, source $\theta$ emitting letter $\theta$ with certainty. These have disjoint supports, so $S(\mathcal{I}_m) = m$ (Theorem 5.2); a one-source subclass has $S = 1$. Theorem 8.2 then gives, on the message emitted by that source, a saving of exactly $\log_2 m$ bits.

The same class makes the general theory concrete at the level of code lengths:

**Corollary 8.4 (Sharp pigeonhole bound).** Every code on $m$ messages assigns some message a length of at least $\log_2 m$ bits.

*Proof sketch.* For the deterministic class, entropy is zero and $R(p_\theta, L) = L(\theta)$. Theorem 3.9(1) yields a $\theta$ with $L(\theta) \ge \log_2 m$. $\square$

**Theorem 8.5 (The value of specialization).** For the class $\mathcal{I}_m$:

1. for each $\theta$ there is a code with $R(p_\theta, L)\le 1$ — e.g. give letter $\theta$ length $1$ and all others length $m+1$, which satisfies Kraft because $(m-1)2^{-(m+1)} \le \tfrac12$;
2. every code $L$ has some $\theta$ with $R(p_\theta, L) \ge \log_2 m$.

Specialization is therefore worth exactly $\log_2 m - 1$ bits here, and that is the entirety of the gain.

Moreover Theorem 5.2 shows this is the *best case*: if the class members overlap at all, the achievable saving is strictly less than $\log_2 m$, and Theorem 5.3 quantifies the shortfall exactly for two sources, where the saving is $\log_2(1 + \mathrm{TV})$ rather than $1$ bit.

---

## 9. Algorithms

Three computational primitives follow directly from the theory. Throughout, $|\mathcal{A}|$ is the alphabet size and $m$ the number of sources.

**(A) Shtarkov sum and NML distribution.** Given the likelihood table $p_\theta(a)$, compute $\widehat p(a) = \max_\theta p_\theta(a)$ for each $a$, then $S = \sum_a \widehat p(a)$ and $p^{\mathrm{NML}} = \widehat p / S$. Cost: $\Theta(m|\mathcal{A}|)$ time and $\Theta(|\mathcal{A}|)$ space. The output certifies both directions of Theorem 4.5: $\log_2 S$ is simultaneously the guarantee of the NML code and the unavoidable worst-case loss of every competitor.

**(B) Shtarkov sum of the memoryless binary class in $O(n)$.** Naively $|\mathcal{A}| = 2^n$, but the envelope depends only on the number of ones. Using the maximum-likelihood bias $\hat t = k/n$ for a string with $k$ ones,
$$S_n = \sum_{k=0}^{n} \binom{n}{k}\left(\frac{k}{n}\right)^{k}\left(1 - \frac{k}{n}\right)^{n-k},$$
which is $n+1$ terms, each computable in $O(1)$ from the previous binomial coefficient. Cost: $\Theta(n)$ arithmetic operations. Numerically one works in log-space to avoid underflow. This is the exact minimax regret certificate $\log_2 S_n$, sitting between the theoretical bounds $\frac12\log_2 n - 2$ and $\log_2(n+1)$.

**(C) Certified minimax regret via disjoint windows.** The lower bound proof is itself an algorithm: choose $d = \lfloor\sqrt n\rfloor + 1$, place centres $c_i = 2di \le n$, and evaluate $\sum_{k : |k - c_i| < d} b_{n, c_i/n}(k)$ for each window. The sum of these masses is a rigorous certificate $S_n \ge \sum_i (\text{window mass})$ computable in $\Theta(n)$ total time, since the windows are disjoint. Each window mass is $\ge 3/4$ by Chebyshev, but the computed values are typically near $0.95$, giving numerically stronger certificates than the analytic bound.

---

## 10. Discussion: is specialization worth pursuing?

The research question that motivated this work was whether shipping decompressors specialized to a class of data can move a meaningful number of bits out of the message and into the shared program. The theory answers it precisely.

**Specialization does move bits, and the exchange rate is the log of class complexity.** By Theorem 8.2 the saving is exactly $\log_2\big(S(\mathcal{P})/S(\mathcal{P}')\big)$; by Theorems 3.9 and 5.2 it is at most $\log_2 m$ for a class of $m$ sources, with equality if and only if the sources are perfectly distinguishable.

**But for parametric classes this is $O(\log n)$ against a $\Theta(n)$-bit message.** For the memoryless binary class the entire price of universality is between $\frac12\log_2 n - 2$ and $\log_2 n$ bits on messages of $n$ bits. For $n = 10^6$, that is at most twenty bits out of a million — a saving of $0.002\%$. Even a $k$-parameter family only reaches $\frac{k}{2}\log_2 n$, which remains negligible unless $k$ is itself comparable to $n$.

**The regime where specialization can matter is exponential class complexity.** Since the price is $\log_2 S$ and $S \le m$, a saving that is a constant fraction of the message length requires $\log_2 S = \Theta(n)$, i.e. a class whose effective number of distinguishable members is exponential in the message length. Theorem 7.3 shows this is attainable by stacking parameters — the price is unbounded in $k$ — so the mathematics does not forbid it. What it forbids is getting there with a fixed smooth low-dimensional model. Dictionary-based, context-mixing, and learned-model schemes are exactly the constructions whose effective class complexity scales with the data, and the theory says that is the only place where the bits are.

**Rigidity sharpens the design advice.** Theorem 5.2 says the price measures distinguishability, not cardinality. Enlarging a class by adding models statistically similar to existing ones costs almost nothing ($S$ grows sublinearly, and by Theorem 5.3 the marginal price of a second model is $\log_2(1+\mathrm{TV})$). So a well-designed universal scheme should be greedy about adding *redundant* models — they are nearly free — and parsimonious about adding *distinguishable* ones. This inverts the naive "label plus specialist" intuition, under which every added model costs a full $\log_2$ of the count.

**Consistency with the classical literature.** The results reproduce the known minimax rates: redundancy–capacity for the average case, Shtarkov's normalized maximum likelihood for the worst case, and Rissanen's $\frac{k}{2}\log n$ for smooth $k$-parameter families. The lower bound established here matches the classical rate in order and differs from the sharp constant only by the factor two inherent in a second-moment argument, and the upper bound $\log_2(n+1)$ matches it in order as well; the truth is bracketed on both sides.

---

## 11. Future work

Five directions stand out.

1. **The sharp constant.** The conjecture $S_n \le \sqrt{\pi n/2} + 1$ for all $n\ge 1$ would make the exact minimax regret of the memoryless binary class $\frac12\log_2 n + O(1)$ with an explicit constant, closing the factor-of-two gap left by the two-sided bound of Theorem 6.8. The route is to replace the crude term bound $\binom{n}{k}\widehat\ell(k)\le 1$ with a Stirling estimate: the $k$-th term behaves like $\sqrt{n/(2\pi k(n-k))}$, and summing the resulting Riemann sum produces the arcsine-density integral $\int_0^1 \frac{dx}{\pi\sqrt{x(1-x)}}$ times $\sqrt{\pi n/2}$.
2. **Beyond memoryless: Markov and finite-state classes.** The additivity theorem should give the $\frac{k}{2}\log n$ rate for order-$r$ Markov chains on a binary alphabet with $k = 2^r$ free parameters, by decomposing a string into the $2^r$ subsequences following each context; the technical obstruction is that context counts are random rather than fixed, so the decomposition is only asymptotically a product.
3. **Exponential class complexity.** Construct explicit classes with $\log_2 S = \Theta(n)$ and analyze their achievable specialization savings — the regime identified in Section 10 as the only one where per-class decompressors can move a constant fraction of the message.
4. **Continuous parameter spaces.** Our classes are finite by construction. Extending the exact minimax identity to compact parameter spaces with a continuous envelope requires replacing the finite maximum with a supremum and controlling measurability; the Shtarkov sum becomes an integral and the rigidity theorem should become a statement about mutual singularity of the family.
5. **Algorithmic NML.** The NML distribution is optimal but requires the envelope, which is exponentially large in general. Identifying classes for which the envelope admits a polynomial-size sufficient statistic — as the number of ones does for the memoryless binary class, reducing $2^n$ messages to $n+1$ equivalence classes — would turn the exact minimax theory into practical codes.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Compensation identity | $\sum_\theta \pi(\theta)D(p_\theta \Vert q) = I(\pi) + D(\bar p_\pi \Vert q)$ |
| Average-case lower bound | Some source pays $\ge I(\pi)$ bits under any code |
| Average-case sandwich | $\log_2 m \le$ minimax redundancy $\le \log_2 m + 1$ for $m$ distinguishable sources |
| Exact worst-case price | Minimax pointwise regret $= \log_2 S$, $S = \sum_a\max_\theta p_\theta(a)$, attained by NML |
| Range | $1 \le S \le m$ |
| Rigidity | $S = m$ iff pairwise disjoint supports; $S < m$ strictly otherwise |
| Two sources | $S = 1 + \mathrm{TV}(p_0,p_1)$; price $=\log_2(1+\mathrm{TV}) \in [0,1]$, $=1$ iff $\mathrm{TV}=1$ |
| Additivity | $S$ multiplies over independent components; $\log_2 S$ adds |
| Bernoulli rate | $\frac12\log_2 n - 2 \le \log_2 S_n \le \log_2(n+1)$ |
| $k$-parameter rate | $k(\frac12\log_2 n - 2) \le \log_2 S \le k\log_2(n+1)$; unbounded in $k$ |
| Price of specialization | $\le \log_2\big(S(\mathcal{P})/S(\mathcal{P}')\big)$ bits, with equality where the MLE lies in the subclass |
| Pigeonhole corollary | Every code on $m$ messages has some length $\ge \log_2 m$ |
