# The Price of Universality: Minimax Redundancy of Universal Decompressors

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

A single decompressor must serve all inputs; a decompressor specialized to a class of data can do better on that class. We quantify the gap — the *price of universality* — as the minimax pointwise redundancy of a source class, and we identify it exactly with the logarithm of the class's Shtarkov sum $C_S = \sum_x \sup_\theta p_\theta(x)$. Building on that identification, we prove: (i) a type-counting upper bound $\log_2 C_S \le (m-1)\log_2(n+1)$ for the memoryless class over an $m$-letter alphabet, matching the Rissanen parameter dimension $d = m-1$ exactly; (ii) a general packing lower bound, giving $\log_2 C_S \ge \log_2 m$ for every message length, and, by tensorization of the binary bound $C_S \ge \sqrt n/4$, an alphabet-growing lower bound $k(\frac12 \log_2 n - 2)$ for alphabets of size $2^k$; (iii) exact multiplicativity of the Shtarkov sum under independent composition, $C_S(\mathcal{S}\otimes\mathcal{T}) = C_S(\mathcal{S})C_S(\mathcal{T})$, hence exact additivity of the price over independently parameterized blocks; (iv) a resulting dichotomy — the price is linear in the number of independent parameters but only logarithmic when the parameter is shared, with an explicit gap of at least $k/4$ bits for $k \ge 5000$ binary blocks of length $32$; (v) subadditivity over unions of classes, giving a model-selection overhead of exactly $\log_2 m$ bits for $m$ models, attained when the models are mutually singular; (vi) the bound $\log_2 C_S \le |S||A|\log_2(n+1)$ for finite-state sources with automaton state set $S$, whence a per-symbol price tending to zero for every finite-state class; and (vii) that symmetry, not parametricity, is the operative feature: *every* exchangeable class on length-$n$ messages, parametric or not, has price at most $(m-1)\log_2(n+1)$ bits.

The verdict for the motivating engineering question: specializing a decompressor to a data class is worth pursuing exactly to the extent that the class has many independent parameters relative to the message length. Bits migrate from message to shared decompressor at the rate of the parameter count, not the message length.

**Keywords:** universal coding, minimax redundancy, Shtarkov sum, normalized maximum likelihood, method of types, Rissanen redundancy, finite-state sources, exchangeability, model selection, tensorization.

---

## 1. Introduction

### 1.1 The engineering question

Compression schemes in practice separate into two artifacts: a *decompressor*, shared across all uses and amortized over many files, and a *compressed message*, paid for once per file. The pigeonhole principle forbids a scheme that shortens all inputs, but it says nothing about how bits are apportioned between these two artifacts. A decompressor that knows your data is a Markov chain of order $3$ with specific transition probabilities need not spend message bits describing that structure; a universal decompressor must.

The question we address is: **how many bits does universality cost?** Equivalently, what is the maximal saving a specialized decompressor could ever deliver? If the answer is a vanishing fraction of the message, building specialized decompressors is a micro-optimization. If it is a constant fraction, or an unbounded number of bits, it is a structural win.

### 1.2 Codes as distributions

Fix a finite message set $\mathcal{X}$. By Kraft's inequality, uniquely decodable binary codes on $\mathcal{X}$ correspond, up to one bit of rounding, to probability distributions $q$ on $\mathcal{X}$, the codeword length of $x$ being $-\log_2 q(x)$. We work throughout with the idealized (non-integer) lengths, so that a *compression scheme* is a distribution $q$ and a *source* is a distribution $p$.

**Definition 1.1 (Source class).** A *source class* on a finite message set $\mathcal{X}$, with parameter set $\Theta$, is a family $\mathcal{S} = \{p_\theta\}_{\theta\in\Theta}$ of functions $p_\theta : \mathcal{X}\to\mathbb{R}$ with $p_\theta(x) \ge 0$ for all $x$ and $\sum_{x\in\mathcal{X}} p_\theta(x) = 1$ for all $\theta$. We write
$$\widehat p(x) \;=\; \sup_{\theta \in \Theta} p_\theta(x)$$
for the *maximum likelihood* of a message, which we assume finite (automatic for finite $\mathcal{X}$ since $p_\theta(x) \le 1$).

$\Theta$ is allowed to be arbitrary — infinite, uncountable, non-compact. In particular we never assume the supremum in $\widehat p$ is attained; all arguments below are engineered to work with the supremum, characterized by the two properties $p_\theta(x) \le \widehat p(x)$ for all $\theta$, and: if $p_\theta(x) \le c$ for all $\theta$ then $\widehat p(x) \le c$.

**Definition 1.2 (Pointwise redundancy).** For a scheme $q$, source $p_\theta$ and message $x$ with $q(x) > 0$,
$$R(q,\theta,x) \;=\; -\log_2 q(x) - \bigl(-\log_2 p_\theta(x)\bigr) \;=\; \log_2\frac{p_\theta(x)}{q(x)}.$$

**Definition 1.3 (Price of universality).** The *price of universality* of a class $\mathcal{S}$ is its minimax pointwise redundancy
$$\mathcal{R}(\mathcal{S}) \;=\; \inf_{q}\;\sup_{x}\;\sup_{\theta}\; R(q,\theta,x),$$
the infimum being over probability distributions $q$ on $\mathcal{X}$.

**Definition 1.4 (Shtarkov sum).** The *Shtarkov sum* of $\mathcal{S}$ is
$$C_S(\mathcal{S}) \;=\; \sum_{x\in\mathcal{X}} \widehat p(x) \;=\; \sum_{x \in \mathcal{X}} \sup_{\theta\in\Theta} p_\theta(x).$$

### 1.3 The exact minimax identity

**Theorem 1.5 (Shtarkov).** For every nonempty source class $\mathcal{S}$ on a finite message set,
$$\mathcal{R}(\mathcal{S}) \;=\; \log_2 C_S(\mathcal{S}),$$
and the infimum is attained by the *normalized maximum likelihood* (NML) distribution $q^{*}(x) = \widehat p(x)/C_S(\mathcal{S})$.

*Proof sketch.* $q^*$ is a probability distribution by construction, and for every $\theta$ and $x$ with $\widehat p(x) > 0$ we have $\log_2 (p_\theta(x)/q^*(x)) = \log_2(p_\theta(x) C_S/\widehat p(x)) \le \log_2 C_S$, with equality whenever $\theta$ approaches the maximizer; so the upper bound holds and is tight for $q^*$. Conversely, if some $q$ achieved $\sup_{x,\theta} R(q,\theta,x) < \log_2 C_S$, then $q(x) > \widehat p(x)/C_S$ for every $x$, and summing over $\mathcal{X}$ yields $1 = \sum_x q(x) > 1$, a contradiction. $\square$

Everything downstream is therefore an estimate of a single scalar, $C_S$.

**Proposition 1.6 (Universality never helps).** $C_S(\mathcal{S}) \ge 1$, hence $\mathcal{R}(\mathcal{S}) \ge 0$.

*Proof.* Pick any $\theta_0 \in \Theta$; then $C_S \ge \sum_x p_{\theta_0}(x) = 1$. $\square$

### 1.4 Contributions and organization

Section 2 develops the two general tools — statistic-counting upper bounds and packing lower bounds — and applies them to the memoryless class, obtaining the dimension sandwich. Section 3 proves exact multiplicativity of $C_S$ and derives the sharing dichotomy, including the multi-alphabet lower bound by tensorization. Section 4 treats unions of classes and model selection. Section 5 treats finite-state sources and proves the vanishing-rate theorem. Section 6 proves that exchangeability alone suffices for a logarithmic price. Section 7 gives algorithms, Section 8 numerical illustrations, Section 9 discussion and the verdict, Section 10 open problems.

---

## 2. Two general tools, and the memoryless class

### 2.1 Sufficient statistics give upper bounds

**Lemma 2.1 (Statistic-counting bound).** Let $\mathcal{S}$ be a source class on a finite set $\mathcal{X}$ and let $T:\mathcal{X}\to\Sigma$ be a map into a finite set such that
$$T(x) = T(y) \;\Longrightarrow\; p_\theta(x) = p_\theta(y) \quad\text{for all } \theta.$$
Then $C_S(\mathcal{S}) \le |\Sigma|$.

*Proof sketch.* Partition $\mathcal{X}$ into the fibers of $T$. On a fiber $F$, the maximum likelihood $\widehat p$ is constant, say equal to $v_F$; and for any $\theta$ nearly attaining the supremum, $|F| \cdot p_\theta(x_F) = \sum_{x\in F} p_\theta(x) \le 1$, so $v_F \le 1/|F|$. Hence each fiber contributes $\sum_{x\in F}\widehat p(x) = |F| v_F \le 1$ to $C_S$, and there are at most $|\Sigma|$ nonempty fibers. $\square$

The whole *method of types* is this lemma with $T$ the vector of letter counts.

**Definition 2.2 (Type).** For a word $x \in A^n$ over a finite alphabet $A$ and a letter $a \in A$, let $N_a(x) = \#\{j : x_j = a\}$. The *type* of $x$ is $N(x) = (N_a(x))_{a\in A} \in \{0,\dots,n\}^{A}$.

**Lemma 2.3 (Counts sum to the length).** $\sum_{a \in A} N_a(x) = n$ for every $x \in A^n$. Consequently, if two words agree in all counts except possibly one letter $a_0$, they agree in that count too, and hence have the same type.

*Proof.* Fiberwise counting of positions; the consequence follows by subtracting the common part from the common total $n$. $\square$

**Definition 2.4 (Memoryless class).** Let $\Delta(A) = \{\theta \in \mathbb{R}^{A} : \theta_a \ge 0, \sum_a \theta_a = 1\}$. The *memoryless* (i.i.d.) class on $A^n$ is $\mathcal{I}(A,n) = \{p_\theta\}_{\theta\in\Delta(A)}$ with $p_\theta(x) = \prod_{j=1}^n \theta_{x_j}$.

**Lemma 2.5 (Likelihood factors through the type).** $p_\theta(x) = \prod_{a\in A}\theta_a^{N_a(x)}$; in particular $N(x) = N(y)$ implies $p_\theta(x)=p_\theta(y)$ for every $\theta$.

**Theorem 2.6 (Type bound at the Rissanen dimension).** Let $|A| = m \ge 1$. Then
$$C_S(\mathcal{I}(A,n)) \;\le\; (n+1)^{\,m-1}, \qquad\text{hence}\qquad \mathcal{R}(\mathcal{I}(A,n)) \;\le\; (m-1)\log_2(n+1) \text{ bits.}$$

*Proof sketch.* Fix a distinguished letter $a_0$ and apply Lemma 2.1 with the *reduced* statistic $T(x) = (N_a(x))_{a \ne a_0} \in \{0,\dots,n\}^{A\setminus\{a_0\}}$. By Lemma 2.3 the reduced statistic determines the full type, and by Lemma 2.5 the likelihood then depends only on it. The target set has cardinality $(n+1)^{m-1}$. $\square$

The exponent is exactly the dimension $d = m-1$ of the parameter space $\Delta(A)$ — one less than the alphabet size, because of the linear constraint $\sum_a \theta_a = 1$. This matches the dimension in Rissanen's asymptotic $\frac{d}{2}\log_2 n + O(1)$; only the constant factor $2$ is lost (see §10, C1).

### 2.2 Packing gives lower bounds

**Theorem 2.7 (Packing bound).** Let $\mathcal{S}$ be a source class on $\mathcal{X}$, let $f : I \to \mathcal{X}$ be an injective map from a finite index set, and let $\theta : I \to \Theta$ be any assignment of sources. Then
$$\sum_{i\in I} p_{\theta(i)}\bigl(f(i)\bigr) \;\le\; C_S(\mathcal{S}).$$

*Proof.* Each summand is at most $\widehat p(f(i))$; injectivity makes $\{f(i)\}$ a set of distinct messages, so the sum of $\widehat p$ over that set is a sub-sum of the (nonnegative) full sum defining $C_S$. $\square$

Any family of sources that can be "told apart" by distinct signature messages is thus a lower-bound certificate.

**Theorem 2.8 (Monotonicity).** If every source of $\mathcal{S}'$ is pointwise dominated by some source of $\mathcal{S}$ — i.e. for all $\theta'$ and $x$ there is $\theta$ with $p'_{\theta'}(x) \le p_\theta(x)$ — then $C_S(\mathcal{S}') \le C_S(\mathcal{S})$. In particular a subclass is never more expensive than the class.

*Proof.* Pointwise, $\widehat{p'} \le \widehat p$; sum. $\square$

**Theorem 2.9 (Alphabet lower bound).** For $n \ge 1$, $C_S(\mathcal{I}(A,n)) \ge m$, i.e. $\mathcal{R} \ge \log_2 m$ bits.

*Proof.* Apply Theorem 2.7 with $I = A$, $f(a) = a^n$ the constant word (injective for $n\ge 1$), and $\theta(a) = \delta_a$ the point mass on $a$. Then $p_{\delta_a}(a^n) = 1$ for each of the $m$ indices. $\square$

**Theorem 2.10 (Dimension sandwich).** For $|A| = m$ and $n\ge 1$,
$$\log_2 m \;\le\; \mathcal{R}(\mathcal{I}(A,n)) \;\le\; (m-1)\log_2(n+1).$$

The lower bound is *independent of $n$*: however long the message, the universal decompressor must still pay for naming the letter a deterministic source repeats.

### 2.3 The binary benchmark

For $A = \{0,1\}$ the Shtarkov sum is computable in closed form,
$$C_S(\mathcal{I}(\{0,1\},n)) \;=\; \sum_{j=0}^{n}\binom{n}{j}\left(\frac{j}{n}\right)^{j}\left(\frac{n-j}{n}\right)^{n-j},$$
because the maximum-likelihood parameter for a word with $j$ ones is $\theta = j/n$. Two standard estimates bracket it:
$$\frac{\sqrt n}{4} \;\le\; C_S(\mathcal{I}(\{0,1\},n)) \;\le\; n+1 \qquad (n\ge 2),$$
the upper bound being Theorem 2.6 with $m=2$, and the lower bound arising from a central-window estimate: the $\Omega(\sqrt n)$ indices $j$ within $O(\sqrt n)$ of $n/2$ each contribute a term of size $\Omega(1)$, since $\binom{n}{j}(j/n)^j((n-j)/n)^{n-j}$ is bounded below by a constant throughout that window. In bits, $\frac12\log_2 n - 2 \le \mathcal{R} \le \log_2(n+1)$: the Rissanen half-logarithm for one free parameter.

---

## 3. Tensorization: the price is additive over independent blocks

### 3.1 Products of classes

**Definition 3.1 (Tensor product).** For classes $\mathcal{S}$ on $\mathcal{X}$ (parameters $\Theta$) and $\mathcal{T}$ on $\mathcal{Y}$ (parameters $\Psi$), the *tensor product* $\mathcal{S}\otimes\mathcal{T}$ is the class on $\mathcal{X}\times\mathcal{Y}$ with parameter set $\Theta\times\Psi$ and
$$p_{(\theta,\psi)}(x,y) = p_\theta(x)\,p_\psi(y).$$
The *$k$-th power* $\mathcal{S}^{\otimes k}$ is the class on $\mathcal{X}^{k}$ with parameter set $\Theta^{k}$ and $p_{\vec\theta}(\vec x) = \prod_{i=1}^{k} p_{\theta_i}(x_i)$: $k$ blocks, each with its own independently chosen parameter.

The technical obstacle to factorizing the maximum likelihood is that suprema over infinite parameter sets need not be attained. The following device replaces compactness.

**Lemma 3.2 (Division trick).** Let $c \ge 0$, $P \ge 0$, and suppose $c\, p_\theta(x) \le P$ for every $\theta$. Then $c\,\widehat p(x) \le P$.

*Proof.* If $c = 0$ this is $0 \le P$. If $c > 0$, then $p_\theta(x) \le P/c$ for all $\theta$, so $\widehat p(x) \le P/c$ by the defining property of the supremum, and multiply back. $\square$

**Theorem 3.3 (Maximum likelihood factorizes).** $\widehat{p}_{\mathcal{S}\otimes\mathcal{T}}(x,y) = \widehat p_{\mathcal{S}}(x)\,\widehat p_{\mathcal{T}}(y)$.

*Proof sketch.* ($\le$) For every $(\theta,\psi)$, $p_\theta(x)p_\psi(y) \le \widehat p(x)\widehat p(y)$ by monotonicity of multiplication on nonnegatives; take the supremum. ($\ge$) Write $P = \widehat p_{\mathcal{S}\otimes\mathcal{T}}(x,y)$. For fixed $\theta$, the family $\psi \mapsto p_\theta(x)p_\psi(y) \le P$ and Lemma 3.2 (with $c = p_\theta(x)$) give $p_\theta(x)\widehat p_{\mathcal{T}}(y) \le P$. Now apply Lemma 3.2 again, with $c = \widehat p_{\mathcal{T}}(y)$, over $\theta$: $\widehat p_{\mathcal{T}}(y)\widehat p_{\mathcal{S}}(x) \le P$. $\square$

**Theorem 3.4 (Multiplicativity of the Shtarkov sum).**
$$C_S(\mathcal{S}\otimes\mathcal{T}) = C_S(\mathcal{S})\cdot C_S(\mathcal{T}), \qquad C_S(\mathcal{S}^{\otimes k}) = C_S(\mathcal{S})^{k}.$$
Equivalently, in bits, $\mathcal{R}(\mathcal{S}^{\otimes k}) = k\,\mathcal{R}(\mathcal{S})$: **the price of universality is additive over independently parameterized blocks.**

*Proof sketch.* Sum the factorization of Theorem 3.3 over $\mathcal{X}\times\mathcal{Y}$ and use the product-of-sums identity. For powers, the corresponding statement $\widehat p_{\mathcal{S}^{\otimes k}}(\vec x) = \prod_i \widehat p(x_i)$ is proved by induction over coordinates: for a set $s$ of coordinates already maximized, one shows
$$\Bigl(\prod_{i\in s}\widehat p(x_i)\Bigr)\Bigl(\prod_{i\notin s} p_{\theta_i}(x_i)\Bigr) \;\le\; \widehat p_{\mathcal{S}^{\otimes k}}(\vec x)$$
for every assignment $\vec\theta$, upgrading one coordinate at a time with Lemma 3.2; taking $s$ to be all coordinates gives the claim. $\square$

### 3.2 A multi-alphabet Rissanen lower bound by tensorization

**Theorem 3.5 (Embedding the binary power).** Let $A = \{0,1\}^k$, so $|A| = 2^k$. Then
$$C_S\bigl(\mathcal{I}(\{0,1\},n)^{\otimes k}\bigr) \;\le\; C_S\bigl(\mathcal{I}(A,n)\bigr).$$

*Proof sketch.* A word $x \in A^n$ is the same data as a $k$-tuple of binary words of length $n$ (transpose). Given a $k$-tuple $\vec\theta$ of Bernoulli parameters, the *product parameter* $\theta^{\otimes}(a) = \prod_{i=1}^k \theta_i(a_i)$ is an element of $\Delta(A)$, and the $\mathcal{I}(A,n)$-likelihood of $x$ under $\theta^\otimes$ equals the $\mathcal{I}(\{0,1\},n)^{\otimes k}$-likelihood of the transpose of $x$ under $\vec\theta$ (both are $\prod_j\prod_i \theta_i(x_{j,i})$, by commuting the products). Hence each maximum likelihood of the power class is dominated by a maximum likelihood of the memoryless class over $A$, and the two Shtarkov sums are related by summing along the transpose bijection. $\square$

**Corollary 3.6 (Multi-alphabet lower bound).** For $n \ge 2$ and $|A| = 2^k$,
$$C_S(\mathcal{I}(A,n)) \;\ge\; \left(\frac{\sqrt n}{4}\right)^{k}, \qquad \mathcal{R}(\mathcal{I}(A,n)) \;\ge\; k\left(\tfrac12\log_2 n - 2\right).$$

*Proof.* Combine the binary bound $C_S \ge \sqrt n/4$, Theorem 3.4 ($C_S$ of the power is the $k$-th power), and Theorem 3.5; take logarithms. $\square$

**Theorem 3.7 (Multi-alphabet sandwich).** For $|A| = 2^k$ and $n \ge 2$,
$$k\left(\tfrac12\log_2 n - 2\right) \;\le\; \mathcal{R}(\mathcal{I}(A,n)) \;\le\; (2^{k}-1)\log_2(n+1).$$

Both sides are logarithmic in $n$; the alphabet-dependent constant is unbounded, at least linear in $k = \log_2|A|$ and at most the parameter dimension $|A|-1$.

### 3.3 The sharing dichotomy

**Theorem 3.8 (Independent versus shared parameters).** Fix $n \ge 2$ and $k \ge 1$, and consider binary data of total length $kn$.

1. *(Independent.)* For $k$ blocks of length $n$, each an independent Bernoulli source with its own bias:
$$\mathcal{R}\bigl(\mathcal{I}(\{0,1\},n)^{\otimes k}\bigr) \;=\; k\,\mathcal{R}\bigl(\mathcal{I}(\{0,1\},n)\bigr) \;\ge\; k\left(\tfrac12\log_2 n - 2\right).$$
2. *(Shared.)* For one Bernoulli source with a single bias governing all $kn$ symbols:
$$\mathcal{R}\bigl(\mathcal{I}(\{0,1\},kn)\bigr) \;\le\; \log_2(kn+1).$$

*Proof.* (1) is Theorem 3.4 plus the binary lower bound; (2) is Theorem 2.6 with $m=2$. $\square$

**Theorem 3.9 (Explicit linear gap).** With blocks of length $32$, for every $k \ge 5000$,
$$\mathcal{R}\bigl(\mathcal{I}(\{0,1\},32)^{\otimes k}\bigr) - \mathcal{R}\bigl(\mathcal{I}(\{0,1\},32k)\bigr) \;\ge\; \frac{k}{4} \text{ bits.}$$

*Proof sketch.* By Theorem 3.8(1) with $n = 32$ and $\log_2 32 = 5$, the independent price is at least $k(\frac52 - 2) = k/2$. For the shared price, $\log_2(32k+1) \le 2.9\sqrt{32k+1} \le 2.9\sqrt{33k}$, using the elementary inequality $\log_2 t \le 2.9\sqrt t$ for $t \ge 1$ (which follows from $\log \sqrt t \le \sqrt t - 1$ and $\log 2 > 0.693$). For $k \ge 5000$ one has $\sqrt{33k}\ge 406$ and hence $2.9\sqrt{33k} \le k/4$. Subtract. $\square$

**Interpretation.** Memorylessness is not what makes universality cheap; *parameter sharing* is. Two classes with the same alphabet, the same total message length, and the same i.i.d. structure within blocks differ by an unbounded number of bits according to whether the parameter is shared across the message or replicated per block. Those $\Theta(k)$ bits are exactly the bits a specialized decompressor — one that already knows the $k$ parameters — gets for free.

---

## 4. Model selection: serving many specialized classes at once

Real systems do not choose between one model and everything; they keep a library.

**Definition 4.1 (Union of classes).** For classes $\mathcal{S}_i$, $i \in I$ finite, on the same message set, the *union* $\bigsqcup_i \mathcal{S}_i$ is the class with parameter set $\coprod_i \Theta_i$ and $p_{(i,\theta)} = p^{(i)}_{\theta}$.

**Theorem 4.2 (Subadditivity).** $C_S\bigl(\bigsqcup_i \mathcal{S}_i\bigr) \le \sum_i C_S(\mathcal{S}_i)$.

*Proof.* Pointwise, $\widehat{p}_{\sqcup}(x) \le \sum_i \widehat p_i(x)$, since every $p^{(i)}_\theta(x) \le \widehat p_i(x) \le \sum_j \widehat p_j(x)$ and the right side is a uniform bound; sum over $x$ and exchange the order. $\square$

**Theorem 4.3 (Union is never cheaper).** $C_S(\mathcal{S}_i) \le C_S(\bigsqcup_j \mathcal{S}_j)$ for every $i$.

*Proof.* Theorem 2.8 with the inclusion. $\square$

**Theorem 4.4 (Model-selection overhead).** If $C_S(\mathcal{S}_i)\le B$ for every $i$ and $|I| = M$, then
$$\mathcal{R}\Bigl(\bigsqcup_i\mathcal{S}_i\Bigr) \;\le\; \log_2 M + \log_2 B.$$
In particular for two classes, $\mathcal{R}(\mathcal{S}\sqcup\mathcal{T}) \le 1 + \max\{\mathcal{R}(\mathcal{S}),\mathcal{R}(\mathcal{T})\}$.

*Proof.* Theorem 4.2 gives $C_S \le MB$; take logarithms and split. (Note $B \ge 1$ by Proposition 1.6.) $\square$

**Theorem 4.5 (The overhead is attained).** Suppose the models are mutually singular: there are pairwise disjoint sets $U_i \subseteq \mathcal{X}$ with $p^{(i)}_\theta(x) = 0$ whenever $x \notin U_i$. Then
$$C_S\Bigl(\bigsqcup_i \mathcal{S}_i\Bigr) = \sum_i C_S(\mathcal{S}_i),$$
and if moreover all $C_S(\mathcal{S}_i)$ equal a common value $C$, then $\mathcal{R}(\bigsqcup_i\mathcal{S}_i) = \log_2 M + \log_2 C$ exactly.

*Proof sketch.* Off $\bigcup_i U_i$ every maximum likelihood vanishes. On $U_i$, every source from a different model contributes $0$, so the union's maximum likelihood coincides with $\widehat p_i$. Split the sum over the disjoint union of the $U_i$. $\square$

Thus $\log_2 M$ bits — the cost of *naming the model* — is exactly the price of keeping $M$ specialized models under one shared decompressor. Doubling the library costs one bit. This is the information-theoretic content of two-part codes and minimum-description-length model selection.

**Theorem 4.6 (Twice-universal coding: memoryless and Markov).** Let $|A| = m$. The first-order Markov class on messages of length $n+1$ (an initial distribution and a transition matrix, $m + m(m-1)$ free parameters) satisfies $C_S \le m\,(n+1)^{m^2}$ by the method of types applied to transition counts. Consequently a single decompressor serving *both* the memoryless class and the first-order Markov class on messages of length $n+1$ pays at most
$$1 + \log_2 m + m^{2}\log_2(n+2) \text{ bits},$$
one bit more than the Markov class alone.

*Proof sketch.* Both classes have Shtarkov sum at most $B = m(n+2)^{m^2}$ (for the memoryless class use Theorem 2.6 and $m - 1\le m^2$, monotonicity in the base); apply Theorem 4.4 with $M = 2$ and expand $\log_2(2B)$. $\square$

---

## 5. Finite-state sources and the vanishing per-symbol price

**Definition 5.1 (Finite-state source).** Fix a finite alphabet $A$, a finite state set $S$, a deterministic transition function $\delta : S\times A \to S$ and an initial state $s_0$. A *parameter* is an emission law $g : S \to \Delta(A)$, i.e. $g_s(a) \ge 0$ and $\sum_a g_s(a) = 1$ for each $s$. The likelihood on messages of length $n$ is defined recursively by
$$p_g^{(0)}(\varepsilon \mid s) = 1, \qquad p_g^{(n+1)}(x \mid s) = g_s(x_1)\cdot p_g^{(n)}(x_2\cdots x_{n+1} \mid \delta(s,x_1)),$$
and the class is $\mathcal{F}(\delta,s_0,n) = \{x \mapsto p^{(n)}_g(x\mid s_0)\}_g$. Order-$r$ Markov sources are the case $S = A^{r}$ with the shift transition.

**Lemma 5.2 (Normalization).** $\sum_{x\in A^n} p^{(n)}_g(x\mid s) = 1$ for every $n$ and $s$.

*Proof sketch.* Induction on $n$: split the sum over the first letter $a$; the inner sum is $g_s(a)$ times the total mass at the successor state $\delta(s,a)$, which is $1$ by hypothesis; then $\sum_a g_s(a) = 1$. $\square$

**Lemma 5.3 (Trajectory product form).** Let $s_1 = s_0$ and $s_{j+1} = \delta(s_j, x_j)$ be the state trajectory. Then
$$p^{(n)}_g(x\mid s_0) = \prod_{j=1}^{n} g_{s_j}(x_j).$$

*Proof.* Unfold the recursion; the first factor is $g_{s_1}(x_1)$ and the rest is the trajectory of the suffix from $\delta(s_0,x_1)$. $\square$

**Theorem 5.4 (Finite-state type bound).**
$$C_S(\mathcal{F}(\delta,s_0,n)) \;\le\; (n+1)^{\,|S|\cdot|A|}, \qquad \mathcal{R} \;\le\; |S|\,|A|\log_2(n+1) \text{ bits.}$$

*Proof sketch.* By Lemma 5.3 the likelihood is $\prod_{(s,a)} g_s(a)^{N_{s,a}(x)}$ where $N_{s,a}(x)$ counts positions $j$ with $s_j = s$ and $x_j = a$. Because $\delta$ and $s_0$ are fixed and deterministic, the trajectory is a function of $x$, so $N(x)$ is a well-defined statistic of the message, and the likelihood depends on $x$ only through $N(x)$, for every parameter. Each of the $|S||A|$ counts takes at most $n+1$ values, so Lemma 2.1 applies. $\square$

**Consistency check.** If $|S| = 1$, the trajectory is constant and the likelihood reduces to $\prod_j g_{s_0}(x_j)$: the class *is* the memoryless class, and the bound degenerates to $(n+1)^{|A|}$, in agreement with §2.

**Theorem 5.5 (The per-symbol price of universality vanishes).** For every finite alphabet $A$, every finite automaton $(S,\delta,s_0)$,
$$\frac{\mathcal{R}(\mathcal{F}(\delta,s_0,n))}{n} \;\xrightarrow[n\to\infty]{}\; 0 ,$$
and $\mathcal{R} \ge 0$ always.

*Proof.* Non-negativity is Proposition 1.6. For the limit, squeeze: $0 \le \mathcal{R}(n)/n \le c\log_2(n+1)/n$ with $c = |S||A|$ a constant, by Theorem 5.4, and $\log_2(n+1)/n \to 0$. $\square$

**Reading.** The automaton may be arbitrarily large; only the constant changes. Specializing the decompressor to a *parametric* class of sources therefore cannot move more than $o(n)$ bits out of a length-$n$ message. Since finite-state sources are precisely the model class against which Lempel–Ziv-type schemes are analyzed, this is the theoretical statement that generic universal compressors are asymptotically optimal per symbol against that whole modelling world.

---

## 6. Symmetry, not parametricity

Every bound so far concerns a parametric family. Is parametricity the reason the price is logarithmic? No — a symmetry suffices.

**Definition 6.1 (Exchangeable class).** A class $\mathcal{S}$ on $A^n$ is *exchangeable* (permutation-invariant) if for every parameter $\theta$, every message $x$ and every permutation $\sigma$ of $\{1,\dots,n\}$,
$$p_\theta(x_{\sigma(1)},\dots,x_{\sigma(n)}) = p_\theta(x_1,\dots,x_n).$$

**Theorem 6.2 (Equal types means permutation).** If $x,y \in A^n$ satisfy $N(x) = N(y)$, then there is a permutation $\sigma$ of positions with $y_{\sigma(j)} = x_j$ for all $j$.

*Proof sketch.* For each letter $b$, the fibers $\{j : x_j = b\}$ and $\{j : y_j = b\}$ have the same cardinality $N_b(x) = N_b(y)$, so there is a bijection $e_b$ between them. The position set $\{1,\dots,n\}$ is the disjoint union of the $x$-fibers and also of the $y$-fibers; assembling the $e_b$ over the fiber decomposition yields a bijection of positions — formally, compose the equivalence $\{1,\dots,n\}\simeq \coprod_b \{j : x_j = b\}$, the fiberwise bijections $\coprod_b e_b$, and the equivalence $\coprod_b \{j: y_j = b\}\simeq\{1,\dots,n\}$. By construction the image of a position $j$ carries the letter $x_j$ in $y$. $\square$

**Theorem 6.3 (Type-invariant classes are cheap).** If $\mathcal{S}$ is a class on $A^n$ such that $N(x) = N(y) \Rightarrow p_\theta(x) = p_\theta(y)$ for all $\theta$, then $C_S(\mathcal{S}) \le (n+1)^{|A|-1}$.

*Proof.* Lemma 2.1 with the reduced count statistic, exactly as in Theorem 2.6, using Lemma 2.3 to recover the omitted count. $\square$

**Theorem 6.4 (Exchangeable classes are cheap).** Every exchangeable class $\mathcal{S}$ on $A^n$ — of arbitrary cardinality, parametric or not — satisfies
$$C_S(\mathcal{S}) \le (n+1)^{|A|-1}, \qquad \mathcal{R}(\mathcal{S}) \le (|A|-1)\log_2(n+1) \text{ bits}.$$
Over a binary alphabet, $\mathcal{R}(\mathcal{S}) \le \log_2(n+1)$ bits.

*Proof.* Combine Theorems 6.2 and 6.3: if $N(x) = N(y)$, write $x$ as a permutation of $y$ and use invariance to conclude $p_\theta(x) = p_\theta(y)$. $\square$

**Discussion.** The class of *all* exchangeable sources on $\{0,1\}^n$ is uncountable and non-parametric; by de Finetti's theorem its infinite-sequence members are exactly the mixtures of i.i.d. Bernoulli laws, but the theorem needs no such representation and applies to finite-$n$ exchangeable laws (Pólya urns, sampling without replacement, arbitrary symmetric measures) that are not i.i.d. mixtures. All of them are served by one code at $\log_2(n+1)$ bits of redundancy: no more than the one-parameter coin. The class of explanations may be enormous; what matters is that its symmetry group collapses the message space to $(n+1)^{|A|-1}$ orbits.

This also delimits the search for expensive classes. Any class whose price is superlogarithmic must break permutation symmetry — as, indeed, the independent-block classes of §3 do (permuting positions mixes blocks).

---

## 7. Algorithms

### 7.1 Exact Shtarkov sum for the memoryless class

For $\mathcal{I}(A,n)$ the maximum-likelihood parameter of a word of type $N$ is $\widehat\theta_a = N_a/n$, so the maximum likelihood is $\prod_a (N_a/n)^{N_a}$, and each type $N$ contains $\binom{n}{N} = n!/\prod_a N_a!$ words. Therefore

$$C_S(\mathcal{I}(A,n)) \;=\; \sum_{\substack{N \in \mathbb{Z}_{\ge0}^{A} \\ \sum_a N_a = n}} \binom{n}{N}\prod_{a\in A}\left(\frac{N_a}{n}\right)^{N_a},$$

with the convention $0^0 = 1$. This is a sum over $\binom{n+m-1}{m-1}$ compositions; for $m = 2$ it is $O(n)$ terms and directly computable for $n$ in the millions in log-space arithmetic. Its asymptotics are the Shtarkov–Rissanen formula
$$\log C_S \;=\; \frac{m-1}{2}\log\frac{n}{2\pi} \;+\; \log\frac{\pi^{m/2}}{\Gamma(m/2)} \;+\; o(1),$$
which for $m = 2$ reads $C_S \sim \sqrt{\pi n/2}$.

### 7.2 Normalized maximum likelihood encoding

Given $C_S$, the optimal universal code assigns $x$ the length $-\log_2 \widehat p(x) + \log_2 C_S$. Since $\widehat p$ is a function of the type alone for the classes considered here, the code can be implemented as: (i) encode the type using an enumerative code over the $\binom{n+m-1}{m-1}$ types; (ii) encode the index of $x$ within its type class using $\log_2\binom{n}{N}$ bits. The total is within a constant of the NML length, which is the standard *enumerative* implementation of NML.

### 7.3 Certifying a lower bound by packing

Given a finite subfamily $\{\theta_i\}$ and candidate signature messages $\{x_i\}$ (distinct), the quantity $\sum_i p_{\theta_i}(x_i)$ is a certificate that $\mathcal{R} \ge \log_2 \sum_i p_{\theta_i}(x_i)$. Choosing $x_i$ to be a typical message of $\theta_i$ and the $\theta_i$ to be a $\Theta(1/\sqrt n)$-separated grid in the parameter simplex is the route to the conjectured $\frac{d}{2}\log_2 n$ (see §10).

---

## 8. Numerical illustrations

The following values illustrate the theory for the binary memoryless class (exact Shtarkov sums, computed from the type sum of §7.1):

| $n$ | $C_S$ | $\mathcal{R} = \log_2 C_S$ | lower bd. $\frac12\log_2 n - 2$ | upper bd. $\log_2(n+1)$ | asymptotic $\log_2\sqrt{\pi n/2}$ |
|---:|---:|---:|---:|---:|---:|
| 8    | 4.245  | 2.086 | −0.500 | 3.170  | 1.826 |
| 32   | 7.774  | 2.959 | 0.500  | 5.044  | 2.826 |
| 128  | 14.855 | 3.893 | 1.500  | 7.011  | 3.826 |
| 1024 | 40.776 | 5.350 | 3.000  | 10.001 | 5.326 |

The exact price tracks $\frac12\log_2 n + \frac12\log_2(\pi/2) = \frac12\log_2 n + 0.326$ closely (the discrepancy falls from $0.26$ at $n = 8$ to $0.024$ at $n = 1024$), sitting strictly between the proved bounds and confirming that the type bound overshoots by the expected factor of about $2$ in the leading coefficient.

For the sharing dichotomy with block length $32$: the independent-block price is exactly $k \cdot 2.959$ bits, while the shared-parameter price on $32k$ symbols is $\log_2 C_S(\mathcal{I}(\{0,1\},32k)) \approx \frac12\log_2(32k) + 0.326$. At $k = 5000$ the two are $14\,793$ bits versus $8.97$ bits: the specialized decompressor absorbs more than $14\,780$ bits that the universal one must charge to the message.

For model selection, two mutually singular models each of Shtarkov sum $C$ yield exactly $\log_2 2 + \log_2 C$: the one-bit overhead is realized to the last bit.

---

## 9. Discussion: the verdict on specialization

The research question was whether specializing a decompressor to a class of data can move a significant number of bits out of the message. The results give a sharp, two-sided answer.

**Against specialization.** For any parametric class with a shared parameter — memoryless, Markov of any order, finite-state with any automaton — the price of universality is $O(\log n)$ bits on a message of $n$ symbols, and the constant is at most the parameter count. Per symbol, the price tends to zero (Theorem 5.5). A universal decompressor asymptotically matches a specialized one on a *rate* basis; there is nothing to be gained beyond $o(n)$ bits. Even non-parametric classes escape only if they break permutation symmetry (Theorem 6.4).

**For specialization.** The price is exactly additive over independently parameterized blocks (Theorem 3.4). Whenever the data is a concatenation of many short, heterogeneously parameterized records — per-file models, per-user profiles, per-sensor calibrations — the universal price grows linearly in the number of records (Theorem 3.9: at least $k/4$ bits for $k\ge 5000$ blocks of length $32$), and a decompressor that already carries those parameters absorbs all of it.

**A cheap hedge.** Maintaining $M$ specialized models in one decompressor costs $\log_2 M$ bits, once (Theorem 4.4), and no less than that when models are mutually singular (Theorem 4.5). The engineering implication: build a library of specialized models and pay a model index; do not attempt to build a single monolithic model of everything.

**Relation to the classical literature.** Our upper bounds have the exact Rissanen parameter dimension $d$ in the exponent, $\log_2 C_S \le d\log_2(n+1)$, and our binary lower bound has the correct $\frac{d}{2}\log_2 n$ leading behavior for $d = 1$; the multi-alphabet lower bound has leading coefficient $\frac{k}{2} = \frac{\log_2 m}{2}$, growing with the alphabet. The conjectured truth, $\frac{d}{2}\log_2 n + O(1)$, is therefore bracketed everywhere, with the remaining gap a factor $2$ in the leading coefficient for large alphabets. In this sense the bounds meet the falsifiability gate: they match known minimax rates in dimension, and in constant for the one-dimensional case.

---

## 10. Open problems and future directions

**C1. The factor-2 conjecture: the type bound is exactly twice the truth.** For a fixed alphabet with $m$ letters there are constants $0 < c_1 \le c_2$ with
$$c_1 n^{(m-1)/2} \;\le\; C_S(\mathcal{I}(A,n)) \;\le\; c_2 n^{(m-1)/2}\quad (n\ge 1),$$
i.e. $\log_2 C_S = \frac{m-1}{2}\log_2 n + O(1)$, whereas the proved bounds are $\frac{\log_2 m}{2}\log_2 n - 2\log_2 m$ from below and $(m-1)\log_2(n+1)$ from above. The key insight is that the Shtarkov sum is a sum over types, and Stirling turns each type's contribution into a Gaussian weight: $C_S$ is a Riemann sum for $\int\sqrt{\det I(\theta)}\,d\theta$ over the simplex, so the exponent is *half* the dimension, the missing factor $\frac12$ being exactly the Jacobian of the maximum-likelihood map. The one-dimensional case is settled; the general case needs a multivariate local central limit theorem for the multinomial, or a purely combinatorial packing over a $\sqrt n$-grid of types.

**C2. Exact tensor-power rate: the price is a dimension-additive invariant.** Define
$$\dim(\mathcal{S}) = \limsup_{n\to\infty}\frac{\log_2 C_S(\mathcal{S}_n)}{\log_2 n}$$
for a family of classes indexed by message length. Then $\dim$ is additive over tensor products and satisfies $\dim(\text{i.i.d. over }A) = \frac{|A|-1}{2}$, $\dim(\text{order-1 Markov over }A) = \frac{|A|(|A|-1)}{2}$, $\dim(\text{finite-state with automaton }S) = \frac{|S|(|A|-1)}{2}$. The key insight is that $C_S$ is *exactly* multiplicative, so the price of universality is a dimension-like invariant of a source class — a logarithmic "entropy of the model space" that adds under independent composition, exactly like Hausdorff dimension under products. Multiplicativity is established for arbitrary (even infinite) parameter spaces via the division trick, so the invariant is well defined; what remains is to compute it for the three families.

**C3. Sharing is the only cheap regime (a dichotomy theorem).** The exchangeable half is proved: every permutation-invariant class on $A^n$ has price at most $(|A|-1)\log_2(n+1)$, parametric or not. The remaining conjecture: for every $\alpha \in (0,1]$ there is a class of sources on $A^n$ whose price is $\Theta(n^{\alpha})$, and every class whose price is $\omega(\log n)$ fails to be exchangeable in a quantitative sense — the price should be controlled by the number of orbits of the symmetry group of the class acting on the message space, interpolating between the exchangeable case ($(n+1)^{|A|-1}$ orbits, logarithmic price) and the fully independent case ($|A|^n$ orbits, linear price).

**Further directions.** (a) Extend the model-selection theorem to countably infinite libraries with a prior, recovering the classical MDL two-part code with a Kraft-summable model weight. (b) Quantify the price for context-tree sources with unbounded depth, where the parameter count itself grows with $n$. (c) Study the *sequential* (online) version, where the code must be a predictor: the minimax regret is the same $\log_2 C_S$, but the achieving strategy differs and the horizon-free version is strictly more expensive. (d) Determine whether the packing certificate of §7.3 can be made algorithmic — computing near-optimal $\sqrt n$-grids and thereby numerically certifying lower bounds within $O(1)$ of the truth for moderate $m$ and $n$.
