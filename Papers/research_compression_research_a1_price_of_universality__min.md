# The Price of Universality: Exact Minimax Redundancy of Universal Decompressors

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

A universal compression scheme must serve every input with one shared decompressor, whereas a scheme specialised to a known source can tune its code to that source. We quantify the gap — the *price of universality* — for finite message spaces and arbitrary parametric source classes, and we determine when specialising a decompressor can actually move bits out of a message.

Our starting point is an exact minimax identification: for a class $\{p_\theta\}_{\theta\in\Theta}$ of sources on a finite message space $X$, the minimax pointwise redundancy equals $\log_2 C_S$, where $C_S=\sum_{x\in X}\sup_\theta p_\theta(x)$ is the Shtarkov sum, achieved by the normalized maximum likelihood (NML) distribution and unavoidable for every Kraft-compliant code. We then bound $C_S$ for the classes of practical interest by an abstract sufficient-statistic principle: if the likelihood factors through a statistic with $N$ values then $C_S\le N$. This yields $C_S\le(n+1)^{|A|}$ for memoryless sources of block length $n$ over an alphabet $A$ (with the sharper $C_S\le n+1$ in the binary case) and $C_S\le|A|\,(n+1)^{|A|^2}$ for first-order Markov chains, i.e. redundancies of $|A|\log_2(n+1)+1$ and $\log_2|A|+|A|^2\log_2(n+1)+1$ bits, uniformly over sources and messages.

A matching lower bound is proved with explicit constants and no asymptotics for the one-parameter binary memoryless class: two-sided Stirling estimates show every interior type contributes at least $1/(2\sqrt n)$ to the Shtarkov sum, whence $C_S\ge\sqrt n/4$ and the price is at least $\tfrac12\log_2 n-2$ bits. This is the classical $(d/2)\log_2 n$ parametric rate at $d=1$, so the theory is tight up to constants: $\tfrac12\log_2 n-2\le\log_2 C_S\le\log_2(n+1)$.

Against this we place the opposite extreme: for the class of point masses — literally one decompressor per file — the Shtarkov sum is exactly $|X|$, so on $n$-bit files the price is exactly $n$ bits and specialisation transfers nothing. The separation is explained by three structural laws: the price is zero for a singleton class, monotone in the class, exactly additive over blocks with independently chosen parameters, and only subadditive over blocks sharing a parameter. Finally, we develop the average-case dual: a compensation identity decomposes Bayes redundancy into a capacity term and an excess term, giving the redundancy–capacity lower bound $I(w)\le\inf_q\sup_\theta D(p_\theta\|q)$ and the consistency estimate $I(w)\le\log_2 C_S\;(\le\log_2|\Theta|)$.

The conclusion for practice is quantitative: bits move from the message into a shared decompressor only in proportion to the *logarithm* of the class complexity, so specialised decompressors pay off exactly when the data class is genuinely low-complexity relative to the data, and not otherwise.

**Keywords:** minimax redundancy, Shtarkov sum, normalized maximum likelihood, Rissanen rate, method of types, Markov sources, redundancy–capacity theorem, universal coding.

---

## 1. Introduction

### 1.1 The problem

Compression algorithms in the wild are *universal*: a single decompressor is shipped once and must correctly invert the compressor on every input it may ever meet. This is a deliberate engineering choice with an information-theoretic cost. If the data were known to be drawn from a specific source $p$, the optimal code would spend $\log_2(1/p(x))$ bits on the message $x$, and nothing else could do better on average. A universal scheme does not know $p$; it knows only that $p$ belongs to some class $\{p_\theta\}_{\theta\in\Theta}$ — "some memoryless source", "some Markov chain of order one", "some source, we have no idea".

The question this paper answers is:

> **How many bits must a single universal code lose, in the worst case over messages and sources, relative to the code tailored to the true source?**

We call this the *price of universality* of the class. It is the correct formalisation of the practical question "is it worth shipping a decompressor specialised to my kind of data?", because the price is exactly the number of bits per message that a specialised scheme can save and a universal one cannot.

### 1.2 Contributions

1. **An exact answer (Section 3).** The minimax pointwise redundancy of a class is exactly $\log_2 C_S$ with $C_S=\sum_x\sup_\theta p_\theta(x)$, attained (to within one bit of integer rounding) by the NML code and unavoidable by every Kraft-compliant code. Both directions are proved without positivity assumptions in a division-free multiplicative form, then transferred to code lengths.
2. **Closed-form upper bounds for the standard classes (Section 4).** An abstract sufficient-statistic bound $C_S\le|\sigma|$, a product-form counting bound $C_S\le|C|\,(m+1)^{|B|}$, and their specialisations to memoryless and first-order Markov sources, with the corresponding bit-level guarantees and the vanishing of the per-symbol price.
3. **A matching lower bound with explicit constants (Section 5).** For the binary memoryless class, $C_S\ge\sqrt n/4$ for $n\ge2$, hence a price of at least $\tfrac12\log_2 n-2$ bits. This meets the falsifiability gate of the programme: the classical Rissanen rate is matched from below by a self-contained, non-asymptotic argument.
4. **A separation theorem (Section 6).** On the same message space of $n$-bit files, the memoryless class costs $\Theta(\log n)$ bits while the class of point masses costs exactly $n$ bits. Specialisation moves bits if and only if the class is low-complexity.
5. **Structural laws (Section 7).** Calibration, monotonicity, exact multiplicativity over independent product classes, and submultiplicativity under a shared parameter; as a corollary the memoryless Shtarkov sum is submultiplicative in block length, so the per-symbol price converges by Fekete's lemma.
6. **The average-case dual (Section 8).** Relative entropy in bits, the Bayes mixture, the compensation identity, Bayes optimality of the mixture code, the redundancy–capacity lower bound, and the consistency estimates $I(w)\le\log_2 C_S$ and $I(w)\le H(w)\le\log_2|\Theta|$.
7. **Exact computational evidence (Section 9).** Rational-arithmetic values of the binary Shtarkov sum at $n=2,4,8$, confirming both sides of the sandwich and strict growth.

### 1.3 Relation to classical theory

The identification of the minimax pointwise redundancy with $\log_2 C_S$ and the optimality of NML are due to Shtarkov; the $(d/2)\log_2 n$ redundancy rate for $d$-parameter smooth families is due to Rissanen; the redundancy–capacity correspondence is the Davisson–Gallager circle of ideas. Our contribution here is a fully self-contained, constant-explicit development of this material for finite message spaces, together with the separation theorem and the structural calculus, which together answer the design question about specialised decompressors.

---

## 2. Setting and definitions

Throughout, $X$ is a finite non-empty set of *messages* and $\Theta$ a non-empty index set of *sources*.

**Definition 2.1 (Source class).** A *source class* on $X$ indexed by $\Theta$ is a family $p:\Theta\times X\to\mathbb R$ with $p_\theta(x)\ge0$ for all $\theta,x$ and $\sum_{x\in X}p_\theta(x)=1$ for all $\theta$.

Immediately $p_\theta(x)\le1$.

**Definition 2.2 (Maximum-likelihood envelope, Shtarkov sum, NML).**
$$\widehat p(x)\;=\;\sup_{\theta\in\Theta}p_\theta(x),\qquad C_S\;=\;\sum_{x\in X}\widehat p(x),\qquad q^\star(x)\;=\;\frac{\widehat p(x)}{C_S}.$$
The supremum exists because the set $\{p_\theta(x):\theta\}$ is bounded above by $1$. We call $C_S$ the *Shtarkov sum* and $q^\star$ the *normalized maximum likelihood* (NML) distribution of the class.

**Definition 2.3 (Codes and Kraft compliance).** A *length function* is a map $\ell:X\to\mathbb N$. It is *Kraft compliant* if $\sum_{x\in X}2^{-\ell(x)}\le1$. Kraft's inequality is precisely the condition for a prefix-free binary code with those lengths to exist, so we identify codes with Kraft-compliant length functions.

**Definition 2.4 (Redundancy).** The *pointwise redundancy* of $\ell$ at $(\theta,x)$ (for $p_\theta(x)>0$) is
$$R(\ell,\theta,x)\;=\;\ell(x)-\log_2\frac{1}{p_\theta(x)} .$$
The *price of universality* of the class is $\inf_{\ell}\sup_{\theta,x}R(\ell,\theta,x)$, the infimum being over Kraft-compliant $\ell$.

Two elementary facts anchor the scale.

**Proposition 2.5.** $1\le C_S$, and if $\Theta$ is finite then $C_S\le|\Theta|$.

*Proof.* Fix any $\theta_0$. Then $1=\sum_x p_{\theta_0}(x)\le\sum_x\widehat p(x)=C_S$. For the upper bound, $\widehat p(x)\le\sum_{\theta}p_\theta(x)$ since all terms are non-negative; summing over $x$ and exchanging the order of summation gives $C_S\le\sum_\theta 1=|\Theta|$. $\square$

In words: universality never helps, and it never costs more than naming the source outright.

---

## 3. The exact minimax theorem

### 3.1 Achievability

**Theorem 3.1 (NML dominates the class).** For every $\theta\in\Theta$ and $x\in X$,
$$p_\theta(x)\;\le\;C_S\cdot q^\star(x).$$

*Proof.* $C_S q^\star(x)=\widehat p(x)\ge p_\theta(x)$ by definition of the supremum; $C_S>0$ by Proposition 2.5. $\square$

Because $q^\star$ is a genuine probability distribution ($\sum_x q^\star(x)=1$ by construction), the code
$$\ell^\star(x)\;=\;\Big\lceil\log_2\frac{1}{q^\star(x)}\Big\rceil$$
is Kraft compliant: $2^{-\ell^\star(x)}\le q^\star(x)$ termwise, and the $q^\star(x)$ sum to $1$. Its redundancy is uniformly controlled.

**Theorem 3.2 (Achievability in code lengths).** Assume $\widehat p(x)>0$ for all $x$. Then for every source $\theta$ and every message $x$ with $p_\theta(x)>0$,
$$\ell^\star(x)\;\le\;\log_2\frac{1}{p_\theta(x)}+\log_2 C_S+1 .$$

*Proof.* By Theorem 3.1, $1/q^\star(x)\le C_S/p_\theta(x)$, hence $\log_2(1/q^\star(x))\le\log_2(1/p_\theta(x))+\log_2 C_S$. Since $q^\star(x)\le1$ the quantity $\log_2(1/q^\star(x))$ is non-negative, so its ceiling is strictly less than itself plus one. $\square$

Note the strength of the statement: a *single* code, fixed in advance, is within $\log_2C_S+1$ bits of the ideal code for the true source, simultaneously for all sources and all messages. No averaging, no asymptotics.

### 3.2 Converse

**Theorem 3.3 (Every sub-probability is beaten somewhere).** Let $q:X\to\mathbb R$ satisfy $\sum_x q(x)\le1$. Then there exists $x\in X$ with
$$q(x)\cdot C_S\;\le\;\widehat p(x).$$

*Proof.* Suppose not: $\widehat p(x)<q(x)C_S$ for every $x$. Summing the strict inequality over the non-empty finite set $X$ gives $C_S<\big(\sum_x q(x)\big)C_S\le C_S$, a contradiction. $\square$

When $\Theta$ is finite the supremum $\widehat p(x)$ is attained, so a witnessing source can be exhibited: there are $x,\theta$ with $q(x)C_S\le p_\theta(x)$.

**Theorem 3.4 (Kraft converse, code-length form).** Let $\ell$ be Kraft compliant and $\Theta$ finite with all $p_\theta(x)>0$. Then there exist a message $x$ and a source $\theta$ with
$$\ell(x)\;\ge\;\log_2\frac{1}{p_\theta(x)}+\log_2 C_S .$$

*Proof.* Apply Theorem 3.3 to $q(x)=2^{-\ell(x)}$, which is a sub-probability by Kraft. This yields $x,\theta$ with $C_S\le2^{\ell(x)}p_\theta(x)$; take base-two logarithms. $\square$

### 3.3 The minimax identity

Combining, we obtain the multiplicative form of Shtarkov's theorem, valid with no positivity hypotheses at all.

**Theorem 3.5 (Exact minimax redundancy).** For a source class with Shtarkov sum $C_S$:

1. $p_\theta(x)\le C_S\,q^\star(x)$ for all $\theta,x$;
2. if $q$ is any non-negative sub-probability on $X$ and $c\in\mathbb R$ satisfies $p_\theta(x)\le c\,q(x)$ for all $\theta,x$, then $C_S\le c$.

Consequently $C_S$ is the least constant of uniform domination of the class by a coding sub-probability, and $\log_2 C_S$ is the minimax pointwise redundancy, achieved to within one bit by the NML code and unavoidable by Theorem 3.4.

*Proof of (2).* From $p_\theta(x)\le cq(x)$ for all $\theta$ we get $\widehat p(x)\le cq(x)$; summing, $C_S\le c\sum_x q(x)$. Since $C_S\ge1>0$ and $\sum_x q(x)\ge0$, necessarily $c>0$, and then $c\sum_xq(x)\le c$. $\square$

### 3.4 The maximally expensive case

**Theorem 3.6 (Mutually singular sources).** Suppose $\Theta$ is finite and there are pairwise disjoint sets $S_\theta\subseteq X$ with $\sum_{x\in S_\theta}p_\theta(x)=1$ for each $\theta$. Then $C_S=|\Theta|$ exactly.

*Proof.* "$\le$" is Proposition 2.5. For "$\ge$": $|\Theta|=\sum_\theta\sum_{x\in S_\theta}p_\theta(x)\le\sum_\theta\sum_{x\in S_\theta}\widehat p(x)$, and by disjointness the double sum is a sum of $\widehat p$ over a subset of $X$, hence at most $C_S$ by non-negativity. $\square$

If the sources of a class can be told apart with certainty from the data, the universal code must effectively *name* the source, paying the full $\log_2|\Theta|$ bits. This is the seed of the separation theorem of Section 6.

---

## 4. Upper bounds: parametric classes cost only $O(\log n)$

The bound $C_S\le|\Theta|$ is vacuous for continuously parametrised classes. The right tool is that likelihoods usually factor through a coarse statistic.

**Theorem 4.1 (Sufficient-statistic bound).** Let $T:X\to\sigma$ with $\sigma$ finite, and suppose $T(x)=T(y)$ implies $p_\theta(x)=p_\theta(y)$ for every $\theta$. Then
$$C_S\;\le\;|\sigma| .$$

*Proof.* Fix $s\in\sigma$ and let $F=T^{-1}(s)$, $k=|F|$. If $F=\emptyset$ its contribution to $C_S$ is $0$. Otherwise $\widehat p$ is constant on $F$, say equal to $M$, because $p_\theta$ is. For each $\theta$ and $x\in F$ we have $k\,p_\theta(x)=\sum_{y\in F}p_\theta(y)\le1$, so $p_\theta(x)\le1/k$; taking suprema, $M\le1/k$ and $\sum_{x\in F}\widehat p(x)=kM\le1$. Summing over the $|\sigma|$ fibres, which partition $X$, gives the claim. $\square$

The classes of interest have *product-form* likelihoods, and for those the relevant statistic is a vector of counts.

**Theorem 4.2 (Product-form counting bound).** Suppose the message $x$ determines features $b_1(x),\dots,b_m(x)\in B$ and an initial value $c(x)\in C$, with $B,C$ finite, and that the likelihood has the form
$$p_\theta(x)\;=\;h_\theta(c(x))\prod_{j=1}^{m}g_\theta\big(b_j(x)\big).$$
Then $C_S\le|C|\cdot(m+1)^{|B|}$.

*Proof.* The product $\prod_j g_\theta(b_j(x))$ equals $\prod_{b\in B}g_\theta(b)^{N_b(x)}$ where $N_b(x)=\#\{j:b_j(x)=b\}$. Hence the likelihood depends on $x$ only through the pair $\big(c(x),(N_b(x))_{b\in B}\big)$, a statistic with at most $|C|\cdot(m+1)^{|B|}$ values. Apply Theorem 4.1. $\square$

### 4.1 Memoryless sources

Let $A$ be a finite alphabet and let the parameter range over the simplex $\Delta(A)=\{\theta:A\to[0,\infty)\ :\ \sum_a\theta(a)=1\}$. The memoryless class on $X=A^n$ is
$$p_\theta(x)\;=\;\prod_{i=1}^{n}\theta(x_i).$$
(That these are probability distributions is the multinomial expansion of $\big(\sum_a\theta(a)\big)^n=1$.)

**Theorem 4.3.** $C_S\le(n+1)^{|A|}$ for the memoryless class of block length $n$ over $A$.

*Proof.* Theorem 4.2 with $B=A$, $m=n$, $|C|=1$, $g_\theta=\theta$, $h_\theta\equiv1$. $\square$

**Theorem 4.4 (Binary refinement).** For $A=\{0,1\}$, $C_S\le n+1$.

*Proof.* The likelihood $\theta(1)^{k}\theta(0)^{n-k}$ depends on $x$ only through $k$, the number of ones, a statistic with $n+1$ values; apply Theorem 4.1 directly. $\square$

**Theorem 4.5 (Bit-level guarantee for memoryless sources).** The NML code of the memoryless class satisfies, for every $\theta\in\Delta(A)$ and every $x\in A^n$ with $p_\theta(x)>0$,
$$\ell^\star(x)\;\le\;\log_2\frac{1}{p_\theta(x)}+|A|\log_2(n+1)+1 .$$

*Proof.* Theorem 3.2 plus $\log_2 C_S\le|A|\log_2(n+1)$ from Theorem 4.3; the hypothesis $\widehat p>0$ holds because the uniform parameter gives every message positive probability. $\square$

**Corollary 4.6 (Vanishing per-symbol price).** For any constant $c$, $\big(c\log_2(n+1)+1\big)/n\to0$ as $n\to\infty$. Hence the price of universality of the memoryless class is $o(1)$ bits per symbol: a decompressor specialised to a memoryless class can absorb only a vanishing fraction of the message.

### 4.2 First-order Markov sources

Let the parameter be a pair $(\nu,T)$ consisting of an initial law $\nu$ on $A$ and a stochastic kernel $T:A\times A\to[0,1]$, and set, on $X=A^{n+1}$,
$$p_{(\nu,T)}(x)\;=\;\nu(x_0)\prod_{j=0}^{n-1}T(x_j,x_{j+1}).$$

**Proposition 4.7 (Normalisation).** For every stochastic kernel $T$ and probability vector $\nu$, $\sum_{x\in A^{n+1}}p_{(\nu,T)}(x)=1$.

*Proof.* Induction on $n$. For $n=0$ the sum is $\sum_{a}\nu(a)=1$. For the step, split the sum over the first symbol $a$ and the remaining word $y\in A^{n+1}$:
$$\sum_{x\in A^{n+2}}\nu(x_0)\prod_{j<n+1}T(x_j,x_{j+1})=\sum_{y\in A^{n+1}}\Big(\sum_{a}\nu(a)T(a,y_0)\Big)\prod_{i<n}T(y_i,y_{i+1}),$$
and $\nu'(b)=\sum_a\nu(a)T(a,b)$ is again a probability vector because $\sum_b\nu'(b)=\sum_a\nu(a)\sum_bT(a,b)=\sum_a\nu(a)=1$. Apply the induction hypothesis to $\nu'$. $\square$

**Theorem 4.8 (Markov redundancy).** For the first-order Markov class on $A^{n+1}$,
$$C_S\;\le\;|A|\,(n+1)^{|A|^2},$$
and consequently the NML code satisfies, for every chain $\theta$ and message $x$ of positive probability,
$$\ell^\star(x)\;\le\;\log_2\frac{1}{p_\theta(x)}+\log_2|A|+|A|^2\log_2(n+1)+1 .$$

*Proof.* Apply Theorem 4.2 with feature alphabet $B=A\times A$ (the transition pairs $(x_j,x_{j+1})$, of which there are $m=n$), initial alphabet $C=A$ (the first symbol), $g_\theta(a,b)=T(a,b)$ and $h_\theta(a)=\nu(a)$; then $|B|=|A|^2$. The bit form follows from Theorem 3.2 and monotonicity of $\log_2$, the positivity hypothesis being witnessed by the uniform chain. $\square$

The pattern is uniform: **the price is logarithmic in the message length, with the number of free parameters entering as the multiplier of $\log_2 n$.** For memoryless sources the effective dimension is $|A|$; for first-order Markov chains, $|A|^2$. Up to the constant in front of the dimension, this is Rissanen's $(d/2)\log_2 n$ law.

---

## 5. The matching lower bound: the Rissanen floor

Upper bounds alone leave open the possibility that the true price is far smaller. We now show that it is not, in the one-parameter case, with explicit constants.

Throughout this section the class is binary memoryless on $X=\{0,1\}^n$, and we write $k$ for the number of ones in a string, $j=n-k$.

### 5.1 Types and their maximum likelihood

**Lemma 5.1 (Type fibres).** The set of binary strings of length $n$ with exactly $k$ ones has $\binom{n}{k}$ elements.

**Lemma 5.2 (Maximum likelihood of a string).** For a string $x$ with $k$ ones, the Bernoulli parameter $\theta$ maximising $p_\theta(x)$ is the empirical frequency $\theta(1)=k/n$, and
$$\widehat p(x)\;\ge\;\Big(\frac{k}{n}\Big)^{k}\Big(\frac{n-k}{n}\Big)^{n-k}$$
(with equality, though only the inequality is needed below, and with the convention $0^0=1$).

*Proof.* The likelihood of $x$ under $\theta$ is $\theta(1)^k\theta(0)^{n-k}$; substituting the empirical parameter exhibits a member of the class attaining the displayed value, so the supremum is at least that. $\square$

Consequently
$$C_S\;=\;\sum_{k=0}^{n}\binom{n}{k}\Big(\frac{k}{n}\Big)^{k}\Big(\frac{n-k}{n}\Big)^{n-k}. \tag{5.1}$$

### 5.2 Two-sided Stirling estimates

**Lemma 5.3 (Stirling, upper).** For $m\ge1$, $\ m!\ \le\ e\sqrt{m}\,(m/e)^m$.

*Proof.* The Stirling sequence $s_m=m!\,/\big(\sqrt{2m}\,(m/e)^m\big)$ is antitone in $m\ge1$, so $s_m\le s_1=e/\sqrt2$. Rearranging, $m!\le(e/\sqrt2)\sqrt{2m}\,(m/e)^m=e\sqrt m\,(m/e)^m$. $\square$

**Lemma 5.4 (Stirling, lower).** For all $m$, $\ \sqrt{2\pi m}\,(m/e)^m\ \le\ m!$.

These are the two sides of the classical Stirling sandwich; the constants $e$ and $\sqrt{2\pi}$ are all we use.

### 5.3 Every interior type is heavy

**Theorem 5.5 (Type-term lower bound).** Let $k,j\ge1$ and $n=k+j$. Then
$$\binom{n}{k}\Big(\frac{k}{n}\Big)^{k}\Big(\frac{j}{n}\Big)^{j}\;\ge\;\frac{1}{2\sqrt n}.$$

*Proof.* Write $\binom{n}{k}=n!/(k!\,j!)$ and expand the maximum-likelihood factor:
$$\Big(\frac{k}{n}\Big)^{k}\Big(\frac{j}{n}\Big)^{j}=\frac{(k/e)^k (j/e)^j}{(n/e)^n},$$
an identity because the powers of $e$ contribute $e^{-k-j+n}=1$ and the powers of $n$ contribute $n^{-k-j+n}=1$ in the appropriate rearrangement. Therefore the left-hand side equals
$$\frac{n!}{(n/e)^n}\cdot\frac{(k/e)^k}{k!}\cdot\frac{(j/e)^j}{j!}.$$
By Lemma 5.4 the first factor is at least $\sqrt{2\pi n}$; by Lemma 5.3 the second and third are at least $1/(e\sqrt k)$ and $1/(e\sqrt j)$. Hence the product is at least
$$\frac{\sqrt{2\pi n}}{e^{2}\sqrt{k}\sqrt{j}} .$$
Now $\sqrt k\sqrt j=\sqrt{kj}\le n/2$ by AM–GM, and numerically $\sqrt{2\pi}>2.5$ and $e^2<7.4$, so the bound is at least
$$\frac{2.5\sqrt n}{7.4\cdot n/2}=\frac{5}{7.4}\cdot\frac{1}{\sqrt n}\;\ge\;\frac{1}{2\sqrt n},$$
since $5/7.4>1/2$. $\square$

### 5.4 The lower bound on the Shtarkov sum

**Theorem 5.6.** For $n\ge2$, the binary memoryless class satisfies $\ C_S\ \ge\ \sqrt n/4$.

*Proof.* Group the messages by type. The fibres $F_k=\{x:\#\text{ones}(x)=k\}$ are pairwise disjoint, and by Lemmas 5.1, 5.2 and Theorem 5.5, for each interior type $1\le k\le n-1$,
$$\sum_{x\in F_k}\widehat p(x)\;\ge\;\binom{n}{k}\Big(\frac kn\Big)^k\Big(\frac{n-k}{n}\Big)^{n-k}\;\ge\;\frac{1}{2\sqrt n}.$$
Summing over the $n-1$ interior types and discarding the two extreme types (whose contributions are non-negative),
$$C_S\;\ge\;\frac{n-1}{2\sqrt n}\;\ge\;\frac{\sqrt n}{4},$$
the last step being equivalent to $4(n-1)\ge2n$, i.e. $n\ge2$. $\square$

**Theorem 5.7 (The price of the binary memoryless class, sandwiched).** For $n\ge2$,
$$\tfrac12\log_2 n-2\;\le\;\log_2 C_S\;\le\;\log_2(n+1).$$
Equivalently: **every** Kraft-compliant code has some message and some Bernoulli source on which it exceeds the ideal code length by at least $\tfrac12\log_2 n-2$ bits, while the NML code never exceeds it by more than $\log_2(n+1)+1$ bits.

*Proof.* The lower bound is Theorem 5.6 with $\log_2(\sqrt n/4)=\tfrac12\log_2 n-2$, combined with Theorem 3.4; the upper bound is Theorem 4.4 combined with Theorem 3.2. $\square$

This meets the falsifiability gate of the research programme: the lower bound is exactly the Rissanen rate $(d/2)\log_2 n$ at $d=1$, so the theory is not merely an upper-bound artefact, and the two sides agree to within a factor $2$ and an additive constant.

---

## 6. Separation: when specialisation buys nothing

Consider on the same message space the opposite extreme of class complexity.

**Definition 6.1 (Deterministic class).** For a finite $X$, the *deterministic class* is $\{\delta_y\}_{y\in X}$ with $\delta_y(x)=1$ if $x=y$ and $0$ otherwise. Interpreted operationally, this is "one decompressor per file": the source $\delta_y$ needs zero bits to describe $y$.

**Theorem 6.2.** For the deterministic class, $\widehat p\equiv1$ and hence $C_S=|X|$ exactly.

*Proof.* $\widehat p(x)\ge\delta_x(x)=1$ and $\widehat p(x)\le1$ since all probabilities are at most $1$. Summing the constant $1$ over $X$ gives $|X|$. (Alternatively, apply Theorem 3.6 with $S_y=\{y\}$.) $\square$

**Corollary 6.3.** On $n$-bit files, $\log_2 C_S=n$: the price of universality of the deterministic class is exactly $n$ bits.

**Theorem 6.4 (Separation).** On the message space of $n$-bit files with $n\ge2$:
$$\tfrac12\log_2 n-2\;\le\;\log_2 C_S^{\mathrm{memoryless}}\;\le\;\log_2(n+1),\qquad \log_2 C_S^{\mathrm{deterministic}}\;=\;n .$$
Moreover $\log_2(n+1)/n\to0$: the fraction of an $n$-bit message that a memoryless-specialised decompressor can absorb vanishes.

**Interpretation.** The deterministic class is the mathematical model of "ship a decompressor tailored to each individual file". Each specialist saves all $n$ bits on its own file; the theorem says the universal scheme facing that class pays exactly $n$ bits. The savings and the price cancel identically: **no bits are moved from the message into the shared decompressor.** This is the pigeonhole bound in redundancy form. At the other extreme, a one-parameter class transfers $\Theta(\log n)$ bits — real, but a vanishing fraction of the file.

The design conclusion is therefore sharp and quantitative: *specialisation pays exactly in proportion to the logarithm of the complexity of the data class, and only when that class is genuinely low-complexity relative to the data.*

---

## 7. Structural laws of the price

The numbers above are not coincidences; they follow from a small calculus obeyed by $C_S$.

**Theorem 7.1 (Calibration).** If all sources of the class have the same law, then $C_S=1$ and the price is exactly $0$ bits.

*Proof.* $\widehat p=p_{\theta_0}$ for any fixed $\theta_0$, whose total mass is $1$. $\square$

**Theorem 7.2 (Monotonicity).** If $\iota:\Theta'\to\Theta$ is any reindexing (in particular, if $\{p_{\theta}\}_{\theta\in\iota(\Theta')}$ is a subclass), then the Shtarkov sum of the reindexed class is at most that of the original.

*Proof.* Pointwise, $\sup_{\theta'}p_{\iota(\theta')}(x)\le\sup_\theta p_\theta(x)$; sum. $\square$

**Definition 7.3 (Product classes).** Given classes $S_1$ on $X_1$ indexed by $\Theta_1$ and $S_2$ on $X_2$ indexed by $\Theta_2$, the *independent product* on $X_1\times X_2$ indexed by $\Theta_1\times\Theta_2$ is $p_{(\theta_1,\theta_2)}(x_1,x_2)=p_{\theta_1}(x_1)p_{\theta_2}(x_2)$. If instead both blocks are driven by one shared parameter $\theta\in\Theta$, the *tied product* is $p_\theta(x_1,x_2)=p^{(1)}_\theta(x_1)p^{(2)}_\theta(x_2)$.

**Theorem 7.4 (Exact multiplicativity).** For the independent product, $C_S=C_S^{(1)}\cdot C_S^{(2)}$; equivalently, the price in bits is exactly additive:
$$\log_2 C_S=\log_2 C_S^{(1)}+\log_2 C_S^{(2)}.$$

*Proof.* The supremum of a product of non-negative functions over a product index set factorises: $\sup_{(\theta_1,\theta_2)}p_{\theta_1}(x_1)p_{\theta_2}(x_2)=\widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2)$. Summing over $X_1\times X_2$ and factoring the double sum gives the claim. $\square$

**Theorem 7.5 (Submultiplicativity under sharing).** For the tied product, $C_S\le C_S^{(1)}\cdot C_S^{(2)}$.

*Proof.* Pointwise, $\sup_\theta p^{(1)}_\theta(x_1)p^{(2)}_\theta(x_2)\le\widehat p^{(1)}(x_1)\widehat p^{(2)}(x_2)$, because a single $\theta$ must serve both factors; sum as before. $\square$

Theorems 7.4 and 7.5 are the structural explanation of the whole paper. A class that re-chooses its parameter on every block pays additively: $n$ blocks cost $n$ times the per-block price, which is how the deterministic class reaches $n$ bits. A class that shares one parameter across all blocks pays only subadditively, and the slack is exactly the saving that turns a linear price into a logarithmic one.

**Corollary 7.6 (Subadditivity in block length).** For the memoryless class over a fixed alphabet, $C_S(n_1+n_2)\le C_S(n_1)\,C_S(n_2)$, hence $n\mapsto\log_2C_S(n)$ is subadditive and $\log_2 C_S(n)/n$ converges by Fekete's lemma.

*Proof.* Splitting a message of length $n_1+n_2$ into its two blocks identifies the memoryless class of length $n_1+n_2$ with the tied product of the memoryless classes of lengths $n_1$ and $n_2$ (the same parameter drives both blocks). The claim is Theorem 7.5 transported along this relabelling, using that the Shtarkov sum is invariant under bijective relabellings of the message space. $\square$

By Corollary 4.6 the limit is $0$, so the Fekete limit is not merely existent but zero — universality is free at first order in the rate, and the whole content of the theory lives in the second-order $\Theta(\log n)$ term.

---

## 8. The average-case dual: redundancy as capacity

Worst-case redundancy is one of two classical formulations; the other averages over a prior on the class and produces lower bounds that do not rely on a single unlucky message. The two views agree, and we prove the comparison.

Throughout this section $\Theta$ is finite, all $p_\theta(x)>0$, and $w$ is a strictly positive prior with $\sum_\theta w_\theta=1$.

**Definition 8.1.** For probability vectors $p,q$ on $X$ with positive entries,
$$D(p\|q)=\sum_x p(x)\log_2\frac{p(x)}{q(x)},\qquad H(w)=-\sum_\theta w_\theta\log_2 w_\theta .$$
The *mixture* is $m_w(x)=\sum_\theta w_\theta p_\theta(x)$; the *capacity functional* (mutual information between parameter and data) is
$$I(w)=\sum_\theta w_\theta\,D(p_\theta\|m_w);$$
the *Bayes redundancy* of a coding distribution $q$ is $\bar R(w,q)=\sum_\theta w_\theta D(p_\theta\|q)$.

**Theorem 8.2 (Gibbs' inequality).** $D(p\|q)\ge0$.

*Proof.* Using $\ln t\le t-1$ with $t=q(x)/p(x)$: $\sum_x p(x)\ln(q(x)/p(x))\le\sum_x(q(x)-p(x))=0$; divide by $-\ln 2$. $\square$

**Theorem 8.3 (Compensation identity).** For every coding distribution $q$ with positive entries,
$$\bar R(w,q)\;=\;I(w)\;+\;D(m_w\|q).$$

*Proof.* For each $\theta$ and $x$, $\log_2\frac{p_\theta(x)}{q(x)}=\log_2\frac{p_\theta(x)}{m_w(x)}+\log_2\frac{m_w(x)}{q(x)}$. Multiply by $w_\theta p_\theta(x)$ and sum over $\theta$ and $x$. The first group of terms is $I(w)$ by definition. In the second, the factor $\log_2(m_w(x)/q(x))$ does not depend on $\theta$, so summing $w_\theta p_\theta(x)$ over $\theta$ yields $m_w(x)$, and the remaining sum over $x$ is $D(m_w\|q)$. $\square$

**Corollary 8.4 (Bayes optimality of the mixture code).** $I(w)\le\bar R(w,q)$ for every coding distribution $q$, with equality iff $q=m_w$. No code beats the mixture on average.

*Proof.* Theorem 8.3 and $D(m_w\|q)\ge0$. $\square$

**Theorem 8.5 (Redundancy–capacity lower bound).** For every coding distribution $q$ there exists $\theta\in\Theta$ with $D(p_\theta\|q)\ge I(w)$. Hence
$$\sup_w I(w)\;\le\;\inf_q\ \sup_\theta\ D(p_\theta\|q).$$

*Proof.* If $D(p_\theta\|q)<I(w)$ for all $\theta$, averaging with the strictly positive weights $w_\theta$ gives $\bar R(w,q)<I(w)$, contradicting Corollary 8.4. $\square$

**Theorem 8.6 (Consistency with the worst-case theory).** Assume additionally $\widehat p(x)>0$ for all $x$. Then for every source $\theta$, $D(p_\theta\|q^\star)\le\log_2 C_S$, and consequently for every prior,
$$I(w)\;\le\;\log_2 C_S .$$

*Proof.* By Theorem 3.1, $p_\theta(x)/q^\star(x)\le C_S$ pointwise, so $D(p_\theta\|q^\star)\le\sum_x p_\theta(x)\log_2 C_S=\log_2 C_S$. Now apply Corollary 8.4 with $q=q^\star$ and average. $\square$

**Theorem 8.7 (Capacity is at most the cost of naming the source).** $I(w)\le H(w)\le\log_2|\Theta|$.

*Proof.* For each $\theta$, $m_w(x)\ge w_\theta p_\theta(x)$, so $p_\theta(x)/m_w(x)\le1/w_\theta$ and $D(p_\theta\|m_w)\le-\log_2 w_\theta$. Averaging gives $I(w)\le H(w)$. The second inequality is the maximum-entropy property of the uniform prior (equivalently Jensen's inequality applied to $\log_2$). $\square$

Theorems 8.5–8.7 place the average-case theory below the worst-case theory: the pointwise requirement of Section 3 is strictly the stronger demand, and it is bounded above by the same quantity, $\log_2|\Theta|$ or $\log_2 C_S$, that bounds the capacity. Universal compression is, formally, the problem of learning the channel while using it: the price of universality is the information the data carries about the unknown parameter.

---

## 9. Exact computational evidence

Formula (5.1) can be evaluated in exact rational arithmetic. Doing so for small $n$:

| $n$ | $C_S$ (exact) | $C_S$ (decimal) | $\sqrt n/4$ | $n+1$ | $\log_2 C_S$ | $\tfrac12\log_2 n-2$ |
|---|---|---|---|---|---|---|
| 2 | $5/2$ | 2.5000 | 0.3536 | 3 | 1.3219 | $-1.5000$ |
| 4 | $103/32$ | 3.2188 | 0.5000 | 5 | 1.6865 | $-1.0000$ |
| 8 | $556403/131072$ | 4.2450 | 0.7071 | 9 | 2.0857 | $-0.5000$ |

Both sides of the sandwich of Theorem 5.7 hold with room to spare at these sizes (the additive constant $-2$ makes the lower bound weak for small $n$; its content is asymptotic in the exponent of $n$, not in the constant), and $C_S$ is strictly increasing over the computed range — inconsistent with any conjecture of a bounded price, and consistent with growth of order $\sqrt n$.

---

## 10. Discussion

### 10.1 The answer to the design question

Suppose you are considering shipping a decompressor specialised to a class $\mathcal C$ of data. The results above give a complete accounting.

- The maximum number of bits per message that the specialisation can move out of the message and into the shared decompressor is exactly $\log_2 C_S(\mathcal C)$, no more and no less (Theorem 3.5).
- If $\mathcal C$ is parametric with $d$ effective parameters, that number is $\Theta(\log n)$ — provably at least $\tfrac12\log_2 n-2$ and at most $\log_2(n+1)$ for the binary memoryless class (Theorem 5.7), at most $|A|\log_2(n+1)$ and $\log_2|A|+|A|^2\log_2(n+1)$ for the general memoryless and Markov classes (Theorems 4.5 and 4.8).
- If $\mathcal C$ is rich enough to name individual files, that number is $n$ on $n$-bit files (Corollary 6.3), and the specialists' savings are exactly cancelled by the cost of identifying which specialist to use.
- The transition between these regimes is governed by parameter sharing: additive price without sharing (Theorem 7.4), subadditive with (Theorem 7.5).

Hence the verdict: **specialised decompressors are worth pursuing precisely when the data class is genuinely low-complexity relative to the data volume**, and the benefit is at most logarithmic in the data volume for any fixed parametric model. In particular, no amount of modelling ingenuity can move a constant *fraction* of a message into the decompressor unless the model class is asymptotically negligible in complexity compared to the data — which is exactly the regime in which the model is doing the compressing.

### 10.2 Sharpness

The bounds meet the gate set for this line of work: the lower bound $\tfrac12\log_2 n-2$ reproduces the classical parametric redundancy rate at dimension one, with fully explicit constants and no asymptotic notation, and the upper bound $\log_2(n+1)$ for the same class is within a factor of two of it in the coefficient of $\log_2 n$. For higher-dimensional classes we have the upper bound $|A|\log_2(n+1)$, which exceeds the expected $\frac{|A|-1}{2}\log_2 n$ by a factor of roughly $2$; closing that factor requires the multi-dimensional analogue of the type-term estimate of Theorem 5.5.

### 10.3 Practical readings

Several familiar facts are corollaries.

*Adaptive coders are near-optimal.* The NML code of a parametric class is a single, fixed code whose loss against the best-tuned code is at most $\log_2 C_S+1$ bits on *every* message. Adaptive arithmetic coders with Krichevsky–Trofimov-style estimators implement close relatives of the mixture code, which is optimal on average by Corollary 8.4.

*Model selection is compression.* $\log_2 C_S$ is the parametric complexity term of the minimum description length principle; the theorems above are its coding-theoretic justification, and Theorem 4.1 is the precise statement that only the number of distinguishable statistics matters.

*Dictionaries and pretraining.* Shipping a large "shared dictionary" or a pretrained model with a codec is the deterministic-class trade in disguise if the dictionary is as expressive as the data; it pays only if the effective description length of the shared object is small relative to the data it will serve — the same $\log_2 C_S$ accounting.

### 10.4 Limitations

All results are for finite message spaces and worst-case pointwise or Bayes-average redundancy relative to *classes of probability distributions*; algorithmic (Kolmogorov) universality is not treated. The lower bound of Section 5 is proved for the binary case; the general alphabet lower bound is conjectural (Section 11). The capacity theory is developed for strictly positive laws and priors, the regime where relative entropy is finite.

---

## 11. Future work

**Full Rissanen rate for general alphabets.** For the memoryless class over an alphabet of size $a$ we conjecture $\log_2 C_S=\frac{a-1}{2}\log_2 n+O(1)$, with the constant given by Shtarkov's formula $\log_2\big(\Gamma(1/2)^a/\Gamma(a/2)\big)+\frac{a-1}{2}\log_2(n/2\pi)$. The one-dimensional proof factorises: each interior type contributes $\prod_i\sqrt{n/(2\pi n_i)}$ by the same two-sided Stirling estimate, and the sum over the $(a-1)$-dimensional type lattice is a Riemann sum for the Dirichlet$(\tfrac12,\dots,\tfrac12)$ normaliser. The remaining work is the multi-index version of Theorem 5.5.

**Minimax equals maximin, exactly.** We conjecture that for every finite class $\sup_w I(w)=\inf_q\sup_\theta D(p_\theta\|q)$, and that both equal $\log_2C_S$ up to $o(1)$ for smooth parametric families. The compensation identity already gives one inequality; the reverse is a minimax exchange on the compact simplex of priors, a finite-dimensional argument.

**Higher-order Markov and finite-state sources.** The product-form bound applies verbatim to order-$r$ chains with $|A|^{r+1}$ features, giving $C_S\le|A|^r(n+1)^{|A|^{r+1}}$; the matching lower bound and the correct dependence on the state count remain open.

**Sharpening the binary constants.** The gap between $\tfrac12\log_2 n-2$ and $\log_2(n+1)$ can be narrowed by replacing the crude discard of the two extreme types and the AM–GM step in Theorem 5.5 by an exact Riemann-sum evaluation of (5.1), which should yield $\log_2 C_S=\tfrac12\log_2 n+\tfrac12\log_2(\pi/2)+o(1)$.

**Beyond worst case: redundancy under structural constraints.** The structural calculus of Section 7 suggests studying the price as a functional on the lattice of classes: which operations on classes are exactly multiplicative, and what is the price of a class defined by a constraint (e.g. bounded entropy rate, bounded total variation from a reference source)?

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Exact minimax redundancy | Price $=\log_2 C_S$, $C_S=\sum_x\sup_\theta p_\theta(x)$; achieved by NML within one bit, unavoidable by Kraft |
| Basic bounds | $1\le C_S\le|\Theta|$; $C_S=1$ for a singleton class; $C_S=|\Theta|$ for mutually singular sources |
| Sufficient statistic | Likelihood factors through an $N$-valued statistic $\Rightarrow C_S\le N$ |
| Memoryless | $C_S\le(n+1)^{|A|}$; binary $C_S\le n+1$; redundancy $\le|A|\log_2(n+1)+1$ bits |
| Markov (order 1) | $C_S\le|A|(n+1)^{|A|^2}$; redundancy $\le\log_2|A|+|A|^2\log_2(n+1)+1$ bits |
| Rissanen floor | Binary memoryless: $C_S\ge\sqrt n/4$, price $\ge\tfrac12\log_2 n-2$ bits, $n\ge2$ |
| Sandwich | $\tfrac12\log_2 n-2\le\log_2 C_S\le\log_2(n+1)$ |
| Separation | Deterministic class: $C_S=|X|$, price exactly $n$ bits on $n$-bit files |
| Structure | Additive over independent blocks; subadditive under a shared parameter; monotone; calibrated |
| Rates | Per-symbol price $\to0$; $\log_2C_S(n)$ subadditive, Fekete limit $0$ |
| Capacity | Compensation identity; mixture Bayes optimal; $I(w)\le\log_2C_S$ and $I(w)\le H(w)\le\log_2|\Theta|$ |
