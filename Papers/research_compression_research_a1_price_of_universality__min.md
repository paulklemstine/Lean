# An Algebra of Source Classes: The Price of Universality under Products and Libraries

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

We study the *price of universality* of a class of information sources: the number of extra bits that a single shared decompressor must spend, relative to a decompressor tailored to the source that actually generated the data. On a finite message space the worst-case price of a class $\mathcal{S} = \{p_\theta\}_{\theta\in\Theta}$ is $\log_2 C_{\mathcal{S}}$, where $C_{\mathcal{S}} = \sum_x \sup_\theta p_\theta(x)$ is the Shtarkov sum; the optimal code is the normalised maximum likelihood distribution.

Our main contribution is a complete *algebra* for this functional under the two natural operations on classes. For **independent products** we prove that the maximum likelihood envelope factorises — for arbitrary, possibly infinite parameter sets, where suprema need not be attained — hence the Shtarkov sum is multiplicative and the price in bits is exactly additive: $k$ independent blocks cost exactly $k$ times the per-block price. For **libraries** (finite unions of specialised classes) we prove the two-sided bound $\max_i C_{\mathcal{S}_i} \le C_{\mathcal{L}} \le \sum_i C_{\mathcal{S}_i}$, whence the price of a library of $K$ specialised decompressors exceeds the price of its most expensive member by at most $\log_2 K$ bits.

We complement the algebra with a general lower bound in terms of statistical diversity, $C_{\mathcal{S}} \ge 1 + \|p_\theta - p_{\theta'}\|_{\mathrm{TV}}$, from which we deduce that the price vanishes if and only if the class is a single source, that it is monotone under passage to a subclass, and — combining with additivity — that it tensorises to $k\log_2(1+\delta)$ over $k$ blocks. We develop the parallel average-case (Bayes) theory: the compensation identity, the redundancy $\ge$ capacity lower bound, the two-part-code upper bound $\log_2|\Theta|$, and a bridge showing that the average-case price never exceeds the worst-case price, which transfers all product and library bounds to the average-case setting. Two exactly solvable families delimit the answer: mutually singular classes cost exactly $\log_2|\Theta|$ (robustly so, under approximate singularity), and the constant-composition class on $n$ bits costs exactly $\log_2(n+1)$, attaining the logarithmic Rissanen rate on the nose. Finally, a conservation law for file-type classes shows that partitioning an unstructured message space merely relocates bits from the payload to the type label, while the memoryless and Markov classes exhibit an unbounded, growing saving over the unstructured class.

The engineering conclusion is sharp: specialisation is worth pursuing precisely when it lowers the *complexity* of the class rather than its *size*, and libraries of specialised decompressors are essentially free, costing only a logarithm in the number of models.

**Keywords:** universal compression, minimax redundancy, Shtarkov sum, normalised maximum likelihood, model libraries, product sources, total variation, method of types, Rissanen rate.

---

## 1. Introduction

### 1.1 The separation of decompressor from data

The pigeonhole principle imposes a hard ceiling on lossless compression: no injective map can shorten every input. But this bound is silent about *where* the irreducible description length lives. In practice a compressed artefact has two components — the *message* (the compressed bits) and the *decompressor* (a program, shared across all messages, that reconstitutes the data). A decompressor tuned to a narrow class of data will encode that class efficiently while being useless elsewhere; a universal decompressor serves everything at some cost per message.

This paper quantifies that cost. We call it the **price of universality**: the excess description length paid by a single shared decompressor over the decompressor that already knows which source generated the data. The question we address is structural. Not "what is the price of one particular class?" — that is classical — but *how does the price behave under the operations by which real model families are built?* Data arrives in blocks; models arrive in families. The two corresponding operations on classes are the independent product and the finite union, and we determine the exact behaviour of the price under each.

### 1.2 Contributions

1. **Multiplicativity and additivity (§4).** The maximum likelihood envelope of an independent product factorises, so Shtarkov sums multiply and prices add. Crucially, the proof is valid for arbitrary parameter sets, with no attainment or compactness hypothesis.
2. **Library bounds (§5).** For a library of $K$ classes, $\max_i C_i \le C_{\mathcal{L}} \le \sum_i C_i$, hence $\text{price}(\mathcal{L}) \le \log_2 K + \max_i \text{price}(\mathcal{S}_i)$, with a matching lower bound $\max_i \text{price}(\mathcal{S}_i)$.
3. **Diversity floor and tensorisation (§6).** $C_{\mathcal{S}} \ge 1 + \|p_\theta - p_{\theta'}\|_{\mathrm{TV}}$; $C_{\mathcal{S}} = 1$ iff the class is a single source; monotonicity under subclasses; and, via additivity, a $k\log_2(1+\delta)$ floor over $k$ blocks.
4. **Average-case theory and the bridge (§7).** The compensation identity, redundancy $\ge$ capacity, the two-part-code bound, and the fact that the normalised maximum likelihood code pays at most $\log_2 C_{\mathcal{S}}$ on average against every member — so all worst-case bounds transfer.
5. **Exact values and conservation (§8–§9).** Mutually singular classes cost exactly $\log_2|\Theta|$, robustly under approximate singularity; file-type classes obey an exact conservation law; the constant-composition class costs exactly $\log_2(n+1)$.
6. **Separation (§10).** The memoryless class costs $O(\log n)$ and the unstructured class exactly $n$ bits on $n$-bit messages, with a gap diverging to infinity.

---

## 2. Setting and definitions

Throughout, $\mathcal{X}$ is a **finite** message space and $\Theta$ an arbitrary nonempty parameter set (finite where explicitly required).

**Definition 2.1 (Source class).** A *source class* on $\mathcal{X}$ with parameter set $\Theta$ is a family $\mathcal{S} = (p_\theta)_{\theta\in\Theta}$ of functions $p_\theta : \mathcal{X} \to \mathbb{R}$ with $p_\theta(x) \ge 0$ for all $x$ and $\sum_{x\in\mathcal{X}} p_\theta(x) = 1$ for all $\theta$.

**Definition 2.2 (Maximum likelihood envelope).** The *envelope* of $\mathcal{S}$ is $\hat p_{\mathcal{S}}(x) = \sup_{\theta\in\Theta} p_\theta(x)$. It is characterised by the two properties: $p_\theta(x) \le \hat p_{\mathcal{S}}(x)$ for every $\theta$, and if $p_\theta(x) \le u$ for every $\theta$ then $\hat p_{\mathcal{S}}(x) \le u$. In particular $\hat p_{\mathcal{S}} \ge 0$.

**Definition 2.3 (Shtarkov sum, price, NML code).** The *Shtarkov sum* is
$$C_{\mathcal{S}} \;=\; \sum_{x\in\mathcal{X}} \hat p_{\mathcal{S}}(x),$$
the *price of universality* of $\mathcal{S}$ is $\log_2 C_{\mathcal{S}}$ bits, and the *normalised maximum likelihood* (NML, or Shtarkov) distribution is $q^*_{\mathcal{S}}(x) = \hat p_{\mathcal{S}}(x)/C_{\mathcal{S}}$.

**Proposition 2.4 (Basic properties).** $1 \le C_{\mathcal{S}} < \infty$ and $0 < C_{\mathcal{S}}$; $q^*_{\mathcal{S}}$ is a probability distribution; and for every $\theta$ and $x$,
$$p_\theta(x) \;\le\; C_{\mathcal{S}}\; q^*_{\mathcal{S}}(x).$$

*Proof sketch.* $\hat p_{\mathcal{S}} \ge p_{\theta_0}$ pointwise for any fixed $\theta_0$, and summing gives $C_{\mathcal{S}} \ge 1$; finiteness is by finiteness of $\mathcal{X}$ and $\hat p_{\mathcal{S}} \le 1$. The displayed inequality is the definition of the envelope after multiplying through by $C_{\mathcal{S}}$. $\square$

**Interpretation (worst-case regret).** For a coding distribution $q$ the *regret* on $(θ,x)$ is $\log_2\bigl(p_\theta(x)/q(x)\bigr)$. Proposition 2.4 says the NML code has regret at most $\log_2 C_{\mathcal{S}}$ uniformly in $\theta$ and $x$; conversely, any $q$ with uniform regret $\le r$ satisfies $\hat p_{\mathcal{S}}(x) \le 2^r q(x)$, and summing over $x$ gives $C_{\mathcal{S}} \le 2^r$, i.e. $r \ge \log_2 C_{\mathcal{S}}$. Hence
$$\min_q \max_{\theta, x} \log_2 \frac{p_\theta(x)}{q(x)} \;=\; \log_2 C_{\mathcal{S}},$$
which is why we call $\log_2 C_{\mathcal{S}}$ *the* price of universality.

**Definition 2.5 (Divergence, entropy, average length, Kraft).** For $p, q : \mathcal{X}\to\mathbb{R}$ with $q > 0$,
$$D(p\|q) = \sum_x p(x)\log_2\frac{p(x)}{q(x)}, \qquad H(p) = -\sum_x p(x)\log_2 p(x), \qquad \mathbb{E}_p[\ell] = \sum_x p(x)\,\ell(x),$$
with the convention $0\log 0 = 0$. A length function $\ell : \mathcal{X}\to\mathbb{N}$ is *Kraft-compliant* if $\sum_x 2^{-\ell(x)} \le 1$.

---

## 3. Preliminaries: Gibbs, the coding identity, and the log-sum inequality

**Lemma 3.1 (Pointwise Gibbs estimate).** For $p \ge 0$ and $q > 0$ real, $p - q \le p\ln(p/q)$.

*Proof sketch.* For $p=0$ this is $-q \le 0$. For $p>0$, apply $\ln t \le t-1$ with $t = q/p$, multiply by $p \ge 0$, and use $\ln(p/q) = -\ln(q/p)$. $\square$

**Theorem 3.2 (Gibbs' inequality, sub-probability form).** Let $s \subseteq \mathcal{X}$ be finite, $p \ge 0$ on $s$, $r > 0$ on $s$, and suppose $\sum_{x\in s} r(x) \le \sum_{x\in s} p(x)$. Then $\sum_{x\in s} p(x)\log_2\frac{p(x)}{r(x)} \ge 0$.

*Proof sketch.* Sum Lemma 3.1 over $s$: $\sum_s (p - r) \le \sum_s p\ln(p/r)$. The left side is $\ge 0$ by hypothesis reversed, giving $\sum_s p\ln(p/r) \ge 0$; divide by $\ln 2 > 0$. $\square$

In particular $D(p\|q) \ge 0$ whenever $p$ is a probability distribution and $q$ is a strictly positive sub-probability distribution.

**Proposition 3.3 (Coding identity).** For a probability distribution $p$ and a length function $\ell$,
$$D\bigl(p \,\big\|\, 2^{-\ell}\bigr) \;=\; \mathbb{E}_p[\ell] - H(p).$$

*Proof sketch.* Termwise: $p(x)\log_2\bigl(p(x)/2^{-\ell(x)}\bigr) = p(x)\log_2 p(x) + p(x)\ell(x)$; sum. $\square$

**Corollary 3.4 (Shannon's source-coding bound).** For any Kraft-compliant $\ell$, $\mathbb{E}_p[\ell] \ge H(p)$.

*Proof sketch.* $2^{-\ell}$ is a strictly positive sub-probability by Kraft; apply Theorem 3.2 and Proposition 3.3. $\square$

**Theorem 3.5 (Log-sum inequality).** For $s \subseteq \mathcal{X}$, $p \ge 0$ on $s$ with $P := \sum_s p > 0$, and $q > 0$ on $s$ with $Q := \sum_s q$,
$$P \log_2 \frac{P}{Q} \;\le\; \sum_{x\in s} p(x)\log_2\frac{p(x)}{q(x)}.$$

*Proof sketch.* Apply Theorem 3.2 on $s$ with reference measure $r(x) = q(x)\cdot(P/Q)$, whose total mass on $s$ is exactly $P$; expand the logarithm of the product. $\square$

Operationally: lumping a block of messages into one symbol can only decrease divergence.

---

## 4. Independent products: the price is additive

**Definition 4.1 (Product class).** Given classes $\mathcal{S}_1$ on $\mathcal{X}_1$ with parameters $\Theta_1$ and $\mathcal{S}_2$ on $\mathcal{X}_2$ with parameters $\Theta_2$, the *independent product* $\mathcal{S}_1\otimes\mathcal{S}_2$ is the class on $\mathcal{X}_1\times\mathcal{X}_2$ with parameter set $\Theta_1\times\Theta_2$ and
$$p_{(\theta_1,\theta_2)}(x_1,x_2) \;=\; p_{\theta_1}(x_1)\, p_{\theta_2}(x_2).$$
That this is a class is Fubini for finite sums: $\sum_{x_1}\sum_{x_2} p_{\theta_1}(x_1)p_{\theta_2}(x_2) = \sum_{x_1} p_{\theta_1}(x_1) = 1$.

**Theorem 4.2 (Factorisation of the envelope).** For all $(x_1,x_2)$,
$$\hat p_{\mathcal{S}_1\otimes\mathcal{S}_2}(x_1,x_2) \;=\; \hat p_{\mathcal{S}_1}(x_1)\cdot \hat p_{\mathcal{S}_2}(x_2).$$
No finiteness, compactness, or attainment hypothesis on $\Theta_1,\Theta_2$ is required.

*Proof.* Write $M = \hat p_{\mathcal{S}_1\otimes\mathcal{S}_2}(x_1,x_2)$, $M_i = \hat p_{\mathcal{S}_i}(x_i)$.

($\le$) For each $(\theta_1,\theta_2)$ we have $p_{\theta_1}(x_1)p_{\theta_2}(x_2) \le M_1 M_2$, by multiplying the two defining inequalities (all quantities nonnegative). Taking the supremum gives $M \le M_1M_2$.

($\ge$) This is the delicate direction, because neither supremum need be attained. Two squeezes.

*Step 1: for every $\theta_2 \in \Theta_2$, $M_1\, p_{\theta_2}(x_2) \le M$.* If $p_{\theta_2}(x_2) = 0$ the claim is $0 \le M$, true. Otherwise $p_{\theta_2}(x_2) > 0$ and for every $\theta_1$,
$$p_{\theta_1}(x_1) \;\le\; \frac{M}{p_{\theta_2}(x_2)},$$
because $p_{\theta_1}(x_1)p_{\theta_2}(x_2) \le M$ by definition of $M$. Since this holds for all $\theta_1$, the supremum obeys $M_1 \le M/p_{\theta_2}(x_2)$, i.e. $M_1 p_{\theta_2}(x_2) \le M$.

*Step 2.* If $M_1 = 0$ the claim $M_1M_2 \le M$ is trivial. Otherwise $M_1 > 0$, and Step 1 rearranges to $p_{\theta_2}(x_2) \le M/M_1$ for every $\theta_2$; taking the supremum over $\theta_2$ gives $M_2 \le M/M_1$, i.e. $M_1M_2 \le M$. $\square$

**Theorem 4.3 (Multiplicativity of the Shtarkov sum).**
$$C_{\mathcal{S}_1\otimes\mathcal{S}_2} \;=\; C_{\mathcal{S}_1}\cdot C_{\mathcal{S}_2}.$$

*Proof.* Sum the identity of Theorem 4.2 over $\mathcal{X}_1\times\mathcal{X}_2$ and factor the double sum:
$\sum_{x_1}\sum_{x_2} \hat p_1(x_1)\hat p_2(x_2) = \bigl(\sum_{x_1}\hat p_1(x_1)\bigr)\bigl(\sum_{x_2}\hat p_2(x_2)\bigr)$. $\square$

**Corollary 4.4 (Additivity of the price).**
$$\log_2 C_{\mathcal{S}_1\otimes\mathcal{S}_2} \;=\; \log_2 C_{\mathcal{S}_1} + \log_2 C_{\mathcal{S}_2}.$$
In particular, $k$ independent blocks drawn from the same class cost exactly $k \cdot \log_2 C_{\mathcal{S}}$ bits.

*Proof.* Theorem 4.3 and $\log_2(ab) = \log_2 a + \log_2 b$ for $a,b > 0$ (positivity from Proposition 2.4). $\square$

**Discussion.** Corollary 4.4 is a *negative* result for compression practice: the price of universality is an extensive quantity, a tax per block rather than a one-off overhead. It cannot be amortised by processing longer streams as products of independent blocks. (It *can* be amortised by classes whose blocks are not independent — the memoryless class on $n$ symbols is not the $n$-fold product of the memoryless class on one symbol, precisely because the parameter is shared across the blocks; and indeed its price is $O(\log n)$, not $\Theta(n)$. The contrast between *shared* and *independent* parameters is exactly the difference between logarithmic and linear price.)

---

## 5. Libraries of specialised decompressors

**Definition 5.1 (Library).** Let $\iota$ be a finite nonempty index set and, for each $i \in \iota$, let $\mathcal{S}_i$ be a class on the *same* message space $\mathcal{X}$ with parameter set $\Theta_i$. The *library* $\mathcal{L} = \bigsqcup_i \mathcal{S}_i$ is the class on $\mathcal{X}$ with parameter set $\Sigma = \{(i,\theta) : i\in\iota,\ \theta\in\Theta_i\}$ and $p_{(i,\theta)} = p^{(i)}_\theta$.

**Lemma 5.2 (Domination).** For each $i$ and each $x$, $\hat p_{\mathcal{S}_i}(x) \le \hat p_{\mathcal{L}}(x)$.

*Proof.* Each $p^{(i)}_\theta(x)$ equals $p_{(i,\theta)}(x) \le \hat p_{\mathcal{L}}(x)$; take the supremum over $\theta \in \Theta_i$. $\square$

**Lemma 5.3 (Pointwise subadditivity).** For each $x$, $\hat p_{\mathcal{L}}(x) \le \sum_{i\in\iota} \hat p_{\mathcal{S}_i}(x)$.

*Proof.* For any library parameter $(i,\theta)$ we have $p_{(i,\theta)}(x) = p^{(i)}_\theta(x) \le \hat p_{\mathcal{S}_i}(x) \le \sum_{j} \hat p_{\mathcal{S}_j}(x)$, the last step because the summands are nonnegative. Take the supremum over $(i,\theta)$. $\square$

**Theorem 5.4 (Two-sided library bound).**
$$\max_{i\in\iota} C_{\mathcal{S}_i} \;\le\; C_{\mathcal{L}} \;\le\; \sum_{i\in\iota} C_{\mathcal{S}_i}.$$

*Proof.* Sum Lemma 5.2 over $x$ for each fixed $i$ to get the left inequality; sum Lemma 5.3 over $x$ and exchange the order of the (finite) double sum to get the right one. $\square$

**Theorem 5.5 (Price of a library).** Let $K = |\iota|$ and suppose $C_{\mathcal{S}_i} \le B$ for every $i$. Then
$$\max_i \log_2 C_{\mathcal{S}_i} \;\le\; \log_2 C_{\mathcal{L}} \;\le\; \log_2 K + \log_2 B.$$

*Proof.* From Theorem 5.4, $C_{\mathcal{L}} \le \sum_i C_{\mathcal{S}_i} \le K\!\cdot\! B$, and $B > 0$ since $B \ge C_{\mathcal{S}_i} \ge 1$; monotonicity of $\log_2$ on positives and $\log_2(KB) = \log_2 K + \log_2 B$ give the upper bound. The lower bound is the left half of Theorem 5.4 under $\log_2$. $\square$

**Interpretation.** Assembling $K$ specialised decompressors into one universal decompressor costs at most $\log_2 K$ bits more than the most expensive specialist alone — the cost of *naming* which specialist applies, and nothing else. Combined with §4, this yields the design principle that model diversity is logarithmically cheap while data volume is linearly expensive.

---

## 6. Diversity: a general lower bound and its tensorisation

**Definition 6.1.** For $p,q : \mathcal{X}\to\mathbb{R}$, the *total variation distance* is $\|p-q\|_{\mathrm{TV}} = \tfrac12\sum_x |p(x)-q(x)| \ge 0$, and $\|p-q\|_{\mathrm{TV}} = 0$ iff $p = q$ pointwise.

**Lemma 6.2 (Max-sum identity).** If $\sum_x p(x) = \sum_x q(x) = 1$ then
$$\sum_x \max\bigl(p(x),q(x)\bigr) \;=\; 1 + \|p-q\|_{\mathrm{TV}}.$$

*Proof.* Pointwise, $\max(a,b) = \tfrac{a+b+|a-b|}{2}$ (check the two cases $a\le b$, $b\le a$). Sum and use the two mass conditions. $\square$

**Theorem 6.3 (Diversity lower bound).** For any two members of a class,
$$1 + \|p_\theta - p_{\theta'}\|_{\mathrm{TV}} \;\le\; C_{\mathcal{S}}, \qquad\text{hence}\qquad \log_2\bigl(1+\|p_\theta-p_{\theta'}\|_{\mathrm{TV}}\bigr) \;\le\; \log_2 C_{\mathcal{S}}.$$

*Proof.* $\max(p_\theta(x),p_{\theta'}(x)) \le \hat p_{\mathcal{S}}(x)$ for each $x$; sum and apply Lemma 6.2. $\square$

**Theorem 6.4 (Degeneracy criterion).** $C_{\mathcal{S}} = 1$ if and only if all members of $\mathcal{S}$ coincide as functions on $\mathcal{X}$.

*Proof.* ($\Rightarrow$) By Theorem 6.3, $1 + \|p_\theta-p_{\theta'}\|_{\mathrm{TV}} \le 1$ forces $\|p_\theta-p_{\theta'}\|_{\mathrm{TV}} = 0$, hence $p_\theta = p_{\theta'}$, for all $\theta,\theta'$. ($\Leftarrow$) If all members equal a common $p$, the envelope equals $p$ (it is $\le p$ by the defining property and $\ge p$ trivially), so $C_{\mathcal{S}} = \sum_x p(x) = 1$. $\square$

**Corollary 6.5 (No free universality).** If $p_\theta(x_0) \ne p_{\theta'}(x_0)$ for some $\theta,\theta',x_0$, then $\log_2 C_{\mathcal{S}} > 0$.

*Proof.* $C_{\mathcal{S}} \ge 1$ always, and $C_{\mathcal{S}} = 1$ is excluded by Theorem 6.4, so $C_{\mathcal{S}} > 1$. $\square$

**Definition 6.6 (Subclass).** For $f : \Theta' \to \Theta$, the *reindexed* class $\mathcal{S}\circ f$ has members $p_{f(\theta')}$.

**Theorem 6.7 (Monotonicity: specialisation never hurts).** $C_{\mathcal{S}\circ f} \le C_{\mathcal{S}}$ and hence $\log_2 C_{\mathcal{S}\circ f} \le \log_2 C_{\mathcal{S}}$.

*Proof.* Pointwise $\hat p_{\mathcal{S}\circ f}(x) \le \hat p_{\mathcal{S}}(x)$, since every $p_{f(\theta')}(x)$ is bounded by $\hat p_{\mathcal{S}}(x)$; sum. $\square$

**Theorem 6.8 (Tensorised diversity bound).** Let $\delta = \|p_\theta - p_{\theta'}\|_{\mathrm{TV}}$ for two members of $\mathcal{S}$. Then for every $k \in \mathbb{N}$, $k$ independent blocks from $\mathcal{S}$ cost at least $k\log_2(1+\delta)$ bits:
$$k\,\log_2(1+\delta) \;\le\; \log_2\bigl(C_{\mathcal{S}}^{\,k}\bigr) \;=\; \log_2 C_{\mathcal{S}^{\otimes k}}.$$

*Proof.* $\log_2(C^k) = k\log_2 C$ (Corollary 4.4 iterated / the power rule) and Theorem 6.3 multiplied by $k \ge 0$. $\square$

Theorem 6.8 is the quantitative form of the extensivity discussed after Corollary 4.4: the price grows *at least* linearly in the volume of data, with a slope determined by the statistical spread of the class.

---

## 7. Average-case (Bayes) theory and the bridge

Sections 4–6 concern worst-case regret. The classical Rissanen-style question is about averages: if the true source is $p_\theta$, the code $q$ spends $\mathbb{E}_{p_\theta}\log_2(1/q)$ bits versus the oracle's $H(p_\theta)$, and the excess is exactly $D(p_\theta\|q)$ by Proposition 3.3. Fix a finite $\Theta$ for this section.

**Definition 7.1 (Bayes mixture, mutual information).** For a prior $w : \Theta\to[0,1]$ with $\sum_\theta w(\theta) = 1$, the *Bayes mixture* is $m_w(x) = \sum_\theta w(\theta) p_\theta(x)$, and the *mutual information* is $I(w) = \sum_\theta w(\theta)\, D(p_\theta \| m_w)$. Note $m_w$ is a probability distribution and $w(\theta)p_\theta(x) \le m_w(x)$ pointwise.

**Theorem 7.2 (Compensation identity).** For every prior $w$ and every strictly positive $q$ with $m_w > 0$,
$$\sum_\theta w(\theta)\, D(p_\theta\|q) \;=\; I(w) \;+\; D(m_w\|q).$$

*Proof.* Pointwise chain rule: for $p \ge 0$, $m > 0$, $q > 0$,
$p\log_2(p/q) = p\log_2(p/m) + p\log_2(m/q)$ (trivial for $p = 0$; otherwise split the logarithms). Apply with $m = m_w(x)$, sum over $x$, then average over $\theta$ with weights $w$. The first group of terms is $I(w)$. The cross term is
$$\sum_\theta w(\theta)\sum_x p_\theta(x)\log_2\frac{m_w(x)}{q(x)} = \sum_x \Bigl(\sum_\theta w(\theta)p_\theta(x)\Bigr)\log_2\frac{m_w(x)}{q(x)} = D(m_w\|q),$$
by exchanging the two finite sums and recognising $m_w$. $\square$

Theorem 7.2 is the exact bookkeeping of the average-case price: the *unavoidable* component $I(w)$ is paid by every code, and the *avoidable* component $D(m_w\|q) \ge 0$ vanishes precisely for $q = m_w$. Hence the Bayes mixture is the Bayes-optimal universal code, of cost $I(w)$.

**Theorem 7.3 (Redundancy $\ge$ capacity).** For every prior $w$ and every strictly positive sub-probability $q$ (i.e. $\sum_x q(x)\le 1$) with $m_w > 0$, there exists $\theta$ with
$$I(w) \;\le\; D(p_\theta\|q).$$

*Proof.* Choose $\theta_{\max}$ maximising $D(p_\cdot\|q)$ over the finite $\Theta$. Then $\sum_\theta w(\theta)D(p_\theta\|q) \le D(p_{\theta_{\max}}\|q)$. By Theorem 7.2 the left side equals $I(w) + D(m_w\|q) \ge I(w)$, since $D(m_w\|q)\ge 0$ by Gibbs (Theorem 3.2, using $\sum_x q \le 1 = \sum_x m_w$). $\square$

Maximising over $w$ gives the channel-capacity lower bound $\sup_w I(w)$ on the minimax average redundancy.

**Theorem 7.4 (Two-part-code upper bound).** For a prior $w$ and $\theta$ with $w(\theta) > 0$,
$$D(p_\theta \| m_w) \;\le\; \log_2\frac{1}{w(\theta)}.$$
Under the uniform prior, $D(p_\theta\|m_{\mathrm{unif}}) \le \log_2|\Theta|$ for every $\theta$, and $I(m_{\mathrm{unif}}) \le \log_2|\Theta|$.

*Proof.* Pointwise $w(\theta)p_\theta(x) \le m_w(x)$ gives $p_\theta(x)/m_w(x) \le 1/w(\theta)$ wherever $p_\theta(x) > 0$; take $\log_2$, multiply by $p_\theta(x) \ge 0$, and sum, using $\sum_x p_\theta(x)=1$. $\square$

**Theorem 7.5 (Bridge: average $\le$ worst case).** If $\hat p_{\mathcal{S}} > 0$ everywhere, then for every $\theta$,
$$D\bigl(p_\theta \,\big\|\, q^*_{\mathcal{S}}\bigr) \;\le\; \log_2 C_{\mathcal{S}}.$$

*Proof.* By Proposition 2.4, $p_\theta(x)/q^*_{\mathcal{S}}(x) \le C_{\mathcal{S}}$ for all $x$; take $\log_2$, multiply by $p_\theta(x)$, sum, and use $\sum_x p_\theta(x) = 1$. $\square$

**Corollary 7.6 (Average-case library bound).** With $\mathcal{L}$, $K$, $B$ as in Theorem 5.5 and $\hat p_{\mathcal{L}} > 0$, the single NML code of the library satisfies, for every member $p$ of every constituent class,
$$D\bigl(p \,\big\|\, q^*_{\mathcal{L}}\bigr) \;\le\; \log_2 K + \log_2 B.$$

*Proof.* Compose Theorem 7.5 for $\mathcal{L}$ with Theorem 5.5. $\square$

Thus every structural bound of §4–§6 has an average-case shadow: one universal code is within $\log_2 K + \log_2 B$ bits, on average, of the code tailored to the true source, whichever specialist family it came from.

---

## 8. Exactly solvable classes

### 8.1 Mutually singular classes

**Theorem 8.1 (Lower bound for singular classes).** Let $\Theta$ be finite and nonempty, and suppose there are pairwise disjoint sets $A_\theta \subseteq \mathcal{X}$ with $\sum_{x\in A_\theta} p_\theta(x) = 1$ for every $\theta$. Then for every strictly positive sub-probability $q$ there exists $\theta$ with
$$D(p_\theta\|q) \;\ge\; \log_2|\Theta|.$$

*Proof sketch.* Put $c_\theta = \sum_{x\in A_\theta} q(x) > 0$. Disjointness gives $\sum_\theta c_\theta \le \sum_x q(x) \le 1$, so some $\theta$ has $c_\theta \le 1/|\Theta|$. For that $\theta$: since $p_\theta$ vanishes off $A_\theta$, the divergence restricts to $A_\theta$. Apply Gibbs on $A_\theta$ against the normalised reference $q/c_\theta$ (whose mass on $A_\theta$ is exactly $1 = \sum_{A_\theta} p_\theta$), obtaining
$$0 \le \sum_{x\in A_\theta} p_\theta(x)\log_2\frac{p_\theta(x)}{q(x)/c_\theta} = D(p_\theta\|q) + \log_2 c_\theta,$$
so $D(p_\theta\|q) \ge -\log_2 c_\theta \ge \log_2|\Theta|$. $\square$

**Theorem 8.2 (Exact minimax value).** Under the hypotheses of Theorem 8.1, the average-case price of universality is exactly $\log_2|\Theta|$: the uniform mixture pays at most $\log_2|\Theta|$ against every member (Theorem 7.4), and every strictly positive sub-probability pays at least $\log_2|\Theta|$ against some member (Theorem 8.1). The same value $\log_2|\Theta|$ is the worst-case price, since disjoint supports give $\hat p_{\mathcal{S}} = \sum_\theta p_\theta \mathbf{1}_{A_\theta}$ and hence $C_{\mathcal{S}} = |\Theta|$.

**Theorem 8.3 (Robustness under approximate singularity).** Let $\Theta$ be finite and nonempty, let $A_\theta$ be pairwise disjoint, and suppose merely that $\sum_{x\in A_\theta} p_\theta(x) \ge 1-\delta$ for each $\theta$. Then for every strictly positive sub-probability $q$ there is a $\theta$ with
$$D(p_\theta\|q) \;\ge\; (1-\delta)\log_2|\Theta| - 4.$$

*Proof sketch.* As before select $\theta$ with $c_\theta \le 1/|\Theta|$ and split the divergence into the block $A_\theta$ and its complement. On $A_\theta$, the log-sum inequality (Theorem 3.5) gives $P\log_2(P/c_\theta) \le \sum_{A_\theta} p_\theta\log_2(p_\theta/q)$ with $P = \sum_{A_\theta}p_\theta \ge 1-\delta$; expanding $P\log_2(P/c_\theta) = P\log_2 P + P\log_2(1/c_\theta)$ and using the elementary bound $t\log_2 t \ge -2$ for $t \ge 0$ together with $\log_2(1/c_\theta) \ge \log_2|\Theta| \ge 0$ yields at least $(1-\delta)\log_2|\Theta| - 2$. On the complement, the same log-sum step with $R = \sum p_\theta$, $R_q = \sum q \le 1$ gives $R\log_2 R - R\log_2 R_q \ge -2$. Adding the two blocks gives the claim. $\square$

So the exact value of Theorem 8.2 is not a knife-edge phenomenon: sources that merely *concentrate* on disjoint sets still pay almost the full naming cost.

### 8.2 File-type classes and conservation of bits

**Definition 8.4 (File-type class).** Let $f : \mathcal{X}\to\kappa$ be a classifier onto a finite nonempty set of *types*, with every fibre $f^{-1}(c)$ nonempty. The *file-type class* has parameter set $\kappa$ and $P_c = $ the uniform distribution on $f^{-1}(c)$.

Distinct fibres are disjoint and $P_c$ is supported on $f^{-1}(c)$, so Theorems 8.1–8.2 apply verbatim: the price is exactly $\log_2|\kappa|$, worst case and on average. Moreover $H(P_c) = \log_2 |f^{-1}(c)|$.

**Theorem 8.5 (Conservation of bits).** For every Kraft-compliant length function $\ell$ on $\mathcal{X}$ there is a type $c$ with
$$\mathbb{E}_{P_c}[\ell] \;\ge\; \underbrace{\log_2 \bigl|f^{-1}(c)\bigr|}_{\text{what the specialist needs}} \;+\; \underbrace{\log_2 |\kappa|}_{\text{price of serving all types}}.$$

*Proof.* Apply Theorem 8.1 with $q = 2^{-\ell}$ (strictly positive, sub-probability by Kraft) to obtain $c$ with $D(P_c\|2^{-\ell}) \ge \log_2|\kappa|$; rewrite the left side as $\mathbb{E}_{P_c}[\ell] - H(P_c)$ by Proposition 3.3 and substitute $H(P_c) = \log_2|f^{-1}(c)|$. $\square$

**Corollary 8.6 (Two-block form).** If $\mathcal{X} = A\times B$ with $f = $ the projection to $A$, then for every Kraft-compliant $\ell$ there is a type $c\in A$ with $\mathbb{E}[\ell] \ge \log_2|B| + \log_2|A|$ — exactly the length of the whole message. A decompressor specialised to one type spends only $\log_2|B|$ bits; the missing $\log_2|A|$ bits are precisely those absorbed into the choice of decompressor.

**Interpretation.** Specialisation *moves* exactly $\log_2|\kappa|$ bits from the message into the identity of the decompressor — never more, never less. Partitioning an unstructured space is therefore bookkeeping, not compression. To gain, the specialised classes must be genuinely low-complexity in the sense of §10.

### 8.3 Constant-composition sources: an exactly solvable natural class

**Definition 8.7.** On $\mathcal{X} = \{0,1\}^n$, let $\mathrm{type}(x)$ be the number of ones of $x$, and for $j \in \{0,\dots,n\}$ let $P_j$ be the uniform distribution on $\{x : \mathrm{type}(x) = j\}$. The family $(P_j)_{j=0}^n$ is the *constant-composition* class.

This is the file-type class of the classifier $\mathrm{type}$, whose $n+1$ fibres are nonempty of size $\binom{n}{j}$. Hence:

**Theorem 8.8.** $C = n+1$ exactly, and the price of universality of the constant-composition class on $n$ bits is exactly $\log_2(n+1)$ bits — worst case *and* on average.

**Theorem 8.9 (Two-part accounting for types).** For every Kraft-compliant $\ell$ on $\{0,1\}^n$ there is a composition $j$ with
$$\mathbb{E}_{P_j}[\ell] \;\ge\; \log_2\binom{n}{j} \;+\; \log_2(n+1).$$

**Theorem 8.10 (The rate is genuinely logarithmic).** For $n \ge 1$,
$$\log_2 n \;\le\; \log_2(n+1) \;\le\; \log_2 n + 1.$$

These sources are precisely the conditional laws of memoryless sources given their empirical type, and they are what method-of-types codes actually model. The point of §8.3 is therefore methodological: the $\Theta(\log n)$ Rissanen rate is not an artefact of a lossy upper-bounding technique — a natural class attains it exactly.

---

## 9. Algorithms

We record the elementary algorithms implicit in the theory. Let $N = |\mathcal{X}|$ and $M = |\Theta|$ (for a finitely-parametrised class, or a grid discretisation of a continuous one).

**Algorithm A (Envelope, Shtarkov sum, price, NML code).**
For each $x\in\mathcal{X}$ compute $\hat p(x) = \max_\theta p_\theta(x)$; accumulate $C = \sum_x \hat p(x)$; output $\log_2 C$ and $q^*(x) = \hat p(x)/C$. Cost $\Theta(NM)$ time, $\Theta(N)$ space.

**Algorithm B (Product price).** Rather than enumerating $|\mathcal{X}_1|\cdot|\mathcal{X}_2|$ messages and $|\Theta_1|\cdot|\Theta_2|$ parameters — cost $\Theta(N_1N_2M_1M_2)$ — invoke Theorem 4.3: compute $C_1$ and $C_2$ separately and multiply. Cost $\Theta(N_1M_1 + N_2M_2)$. For $k$ identical blocks, $\log_2 C^{\otimes k} = k\log_2 C$ in $\Theta(NM)$ time independent of $k$: an exponential saving.

**Algorithm C (Library certificate).** Given specialist Shtarkov sums $C_1,\dots,C_K$, output the interval $\bigl[\max_i \log_2 C_i,\ \log_2 K + \max_i \log_2 C_i\bigr]$ containing the library price, in $\Theta(K)$ time and without touching the message space at all. This is the practical model-selection tool: it certifies the cost of carrying a model zoo from summary statistics alone.

**Algorithm D (Diversity certificate).** Given two members, compute $\delta = \tfrac12\sum_x|p_\theta(x)-p_{\theta'}(x)|$ in $\Theta(N)$ time and report the lower bound $\log_2(1+\delta)$ on the price, and $k\log_2(1+\delta)$ for $k$ blocks. This certifies that a proposed universal scheme *cannot* beat a stated target, without any optimisation.

---

## 10. The separation: what specialisation actually buys

Fix an alphabet $A$ and message length $n$.

**Theorem 10.1 (Unstructured class).** The class of all point masses on $\mathcal{X}$ (equivalently, "any file is possible, nothing is known") has $C = |\mathcal{X}|$ and price exactly $\log_2|\mathcal{X}|$, worst case and on average; for $\mathcal{X} = \{0,1\}^n$ this is exactly $n$ bits.

*Proof.* Point masses have disjoint supports, so Theorem 8.2 applies with $|\Theta| = |\mathcal{X}|$. $\square$

**Corollary 10.2 (Pigeonhole bound recovered).** For every Kraft-compliant $\ell$ on $\{0,1\}^n$ there is a file $x$ with $\ell(x) \ge n$.

*Proof.* Apply Theorem 10.1's lower-bound half to $q = 2^{-\ell}$: some point mass $\delta_x$ has $D(\delta_x\|q) \ge n$. But $D(\delta_x\|q) = \log_2(1/q(x)) = \ell(x)$. $\square$

**Theorem 10.3 (Memoryless and Markov classes).** On $n$-symbol messages over $A$:
- the memoryless class (i.i.d. symbols with unknown distribution) satisfies $C \le (n+1)^{|A|}$, hence its price, worst case and on average against every parameter, is at most $|A|\log_2(n+1)$ bits;
- the first-order Markov class satisfies $C \le |A|\,(n+1)^{|A|^2}$, hence price at most $\log_2|A| + |A|^2\log_2(n+1)$ bits.

*Proof sketch.* Both are method-of-types bounds: the maximum likelihood of a string depends only on its empirical (transition) counts, and the number of distinct count vectors is at most $(n+1)^{|A|}$ (resp. $(n+1)^{|A|^2}$), while for each count vector the corresponding maximum-likelihood mass over its type class is at most $1$. The average-case statements follow from Theorem 7.5. $\square$

**Theorem 10.4 (Separation and divergence of the gap).** On $\{0,1\}^n$ the memoryless class costs at most $2\log_2(n+1)$ bits while the unstructured class costs exactly $n$ bits; and
$$n - 2\log_2(n+1) \;\longrightarrow\; \infty \quad (n\to\infty).$$

*Proof sketch.* The first claim is Theorem 10.3 with $|A|=2$ and Theorem 10.1. For the divergence, write $n - 2\log_2(n+1) = n\bigl(1 - 2\log_2(n+1)/n\bigr)$; the bracket tends to $1$ because $\log_2(n+1)/n \to 0$, and $n\to\infty$. $\square$

**Theorem 10.5 (Sharpness).** The logarithmic rate of Theorem 10.3 is attained exactly by a natural class: the constant-composition class on $n$ bits has price exactly $\log_2(n+1)$ (Theorem 8.8), which is $\Theta(\log n)$ by Theorem 8.10.

**Summary of the separation.** The price of universality is governed by the *complexity of the class*, not by the *length of the data*. For a class of parametric complexity $\Theta(n)$ (constant-composition: $n+1$ sources) the price is $\Theta(\log n)$; for a class of complexity $2^n$ with no structure (all files) the price is exactly $n$. Moving bits from the message into a shared decompressor is therefore worthwhile exactly when the data class is genuinely low-complexity, and then the saving is unbounded.

---

## 11. Numerical illustration

Brute-force enumeration on small message spaces confirms every identity above. Representative values (all computed by exhaustive summation over $\{0,1\}^n$):

| Statement | Instance | Predicted | Computed |
|---|---|---|---|
| Multiplicativity | $\mathcal{S}_1$: 3 memoryless sources on 2 bits, $\mathcal{S}_2$: 4 on 3 bits | $C_1C_2 = 1.9500\times 2.45938$ | $C_{\otimes} = 4.795781$ |
| Additivity, $k$ blocks | class $\{0.25,0.75\}$ on 2 bits, $k = 1..4$ | $k\times 0.584963$ | $0.5850, 1.1699, 1.7549, 2.3399$ |
| Library bounds | 4 specialist families on 4 bits | $\max C_i = 5 \le C_{\mathcal{L}} \le \sum C_i = 8.742$ | $C_{\mathcal{L}} = 5.000$ |
| Diversity floor | $\theta \in \{0.2,0.8\}$ on 4 bits | $1+\delta = 1.792$ | $C = 1.792$ (equality for two sources) |
| Constant composition | $n = 1,\dots,8$ | $C = n+1$ | $2,3,4,5,6,7,8,9$ |
| Unstructured class | $n = 1,\dots,4$ | $C = 2^n$ | $2,4,8,16$ |
| Bridge | memoryless, $n = 6$ | $D(p_\theta\|q^*) \le 1.916359$ | $\max_\theta D = 1.284956$ |
| Rissanen constant | binary memoryless, $n = 12$ | $C_n \approx \sqrt{\pi n/2}$ | ratio $1.1600$ (slowly $\to 1$) |

The last row is a numerical probe of the conjecture discussed in §12: the binary memoryless Shtarkov sum satisfies $C_n = \sum_{j=0}^n\binom{n}{j}(j/n)^j(1-j/n)^{n-j}$, and the ratio $C_n/\sqrt{\pi n/2}$ decreases slowly towards $1$ (it is $\approx 1.017$ at $n = 1000$).

Two entries deserve comment. First, the diversity floor is *tight* whenever the class consists of exactly two sources: then $\hat p = \max(p,p')$ and Lemma 6.2 is an equality, so $C = 1+\delta$ on the nose. Second, in the library example the bound $\log_2 K + \max_i \text{price}_i = 4.32$ bits considerably overshoots the truth ($2.32$ bits), because the specialists there overlap heavily; the bound is tight when the specialists are close to mutually singular, which is precisely the regime in which a library is most useful.

---

## 12. Discussion and open problems

### 12.1 What the algebra says about compressor design

The two laws pull in opposite directions and together determine the design space.

*Products penalise data.* Additivity (Corollary 4.4) and its quantitative floor (Theorem 6.8) say that universality is a per-block tax. There is no batching strategy that dilutes it. Crucially, this is a statement about *independent parameters*: the memoryless class on $n$ symbols escapes linear price precisely because its blocks share one parameter. The design lesson is that a model family should tie its parameters across the stream as tightly as the data allows; every genuinely independent degree of freedom costs its own full price.

*Unions barely penalise models.* Theorem 5.5 says that carrying $K$ specialised decompressors costs at most $\log_2 K$ bits more than carrying the single worst of them. Doubling the model zoo costs one bit. This is the single most actionable consequence of the paper: **the correct architecture is a library**, and the practical bottleneck is fitting good specialists, not paying for the privilege of holding many.

*The falsifiability gate.* The research programme this work belongs to set an explicit test: does specialisation actually move bits from the message into the shared decompressor? The answer is a conditional yes, and the condition is sharp. Theorem 8.5 (conservation) shows that partitioning an unstructured space moves exactly $\log_2|\kappa|$ bits and nothing more — a pure relabelling. Theorem 10.4 shows that restricting to a genuinely low-complexity class moves $n - O(\log n)$ bits, an unbounded saving. Complexity, not partition size, is the operative variable.

### 12.2 Open problems

**Problem 1 (Redundancy–capacity theorem: minimax equals maximin).** For every finite class,
$$\inf_q \max_\theta D(p_\theta\|q) \;=\; \max_w I(w),$$
with the infimum attained at the Bayes mixture of a maximising prior. Theorem 7.3 gives $\ge$ and Theorem 7.4 gives the upper bound $\log_2|\Theta|$; the missing half is a genuine minimax exchange. The map $w\mapsto I(w)$ is concave and $q\mapsto \sum_\theta w(\theta)D(p_\theta\|q)$ is convex, so a Sion-type minimax theorem on the compact convex simplices of priors and coding distributions should close it, once the extended-real-valued divergence is handled at the boundary. All the convexity ingredients (Gibbs, the compensation identity) are in place; the result would upgrade every lower bound here from "for each prior" to "exactly".

**Problem 2 (Sharp Rissanen constant).** For the binary memoryless class on $n$ bits, is
$$\log_2 C_n \;=\; \tfrac12\log_2 n + \tfrac12\log_2\frac{\pi}{2} + o(1),$$
and more generally $\tfrac{k-1}{2}\log_2 n + O(1)$ for alphabet size $k$? Our two-sided bounds are $\tfrac12\log_2 n - 2 \le \log_2 C_n \le k\log_2(n+1)$, a factor-two gap at the top. The Shtarkov sum is a sum of binomial *mode* probabilities, $C_n = \sum_j \Pr[\mathrm{Bin}(n, j/n) = j]$, so Stirling bounds on the central term together with a Laplace-type comparison of neighbouring terms should pin the constant. Numerically $C_n/\sqrt{\pi n/2} = 1.017$ at $n=1000$, consistent with the conjecture.

**Problem 3 (When is the library bound tight?).** Theorem 5.4 gives $\max_i C_i \le C_{\mathcal{L}} \le \sum_i C_i$. The upper bound is attained when the specialists are mutually singular; the lower bound when one specialist dominates. A quantitative interpolation — $C_{\mathcal{L}}$ as an explicit function of the pairwise overlaps between the specialists' envelopes — would turn Algorithm C from a certificate into an exact model-selection criterion.

**Problem 4 (Non-product dependence).** Additivity assumes independent blocks with independent parameters. What is the price for classes with shared or slowly-varying parameters across blocks — the regime of real data? A general "price of a hidden-Markov-tied parameter" theorem interpolating between $\Theta(\log n)$ (fully tied) and $\Theta(n)$ (fully free) would complete the picture.

**Problem 5 (Beyond finite message spaces).** All our results are stated on finite $\mathcal{X}$, with arbitrary parameter sets. The envelope factorisation (Theorem 4.2) already works for infinite $\Theta$; extending Shtarkov sums to countable or continuous $\mathcal{X}$ requires care (the envelope may be non-integrable), and the interesting question is which classes remain finitely-priced.

---

## 13. Conclusion

The worst-case price of universality of a source class is a single scalar, the logarithm of the Shtarkov sum, and this scalar has an algebra. It is exactly multiplicative under independent products, so the price in bits is exactly additive and cannot be amortised over data. It is subadditive and dominating under unions, so the price of a library of $K$ specialised decompressors sits between the most expensive specialist and that specialist plus $\log_2 K$ bits. Below, the price is floored by the statistical diversity of the class, $\log_2(1 + \|p_\theta-p_{\theta'}\|_{\mathrm{TV}})$, and this floor tensorises; it vanishes exactly for degenerate classes and is monotone under specialisation. Above, the average-case price never exceeds the worst-case price, so every one of these bounds holds in the Bayes setting as well, where the compensation identity resolves the redundancy into an unavoidable mutual information plus an avoidable divergence from the Bayes mixture.

Instantiated, the theory delivers exact values (mutually singular classes: $\log_2|\Theta|$; constant-composition classes: $\log_2(n+1)$), a conservation law showing that partitioning an unstructured space merely relabels bits, and an unbounded separation showing that structural restriction moves a growing number of bits out of the message. For the engineer, the conclusion is that specialised decompressors are worth pursuing, that they should be assembled into libraries rather than chosen, and that the entire cost of hedging across a library is the logarithm of its size.
