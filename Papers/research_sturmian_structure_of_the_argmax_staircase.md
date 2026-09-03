# The Sturmian Structure of the Binomial Argmax Staircase

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

Let $p,q>0$ and let $b_{n,k}=\binom{n}{k}p^{k}q^{\,n-k}$ be the (unnormalised) binomial weights of row $n$. Write $M_n$ for the largest maximiser of $k\mapsto b_{n,k}$ over $0\le k\le n$, the *upper bracketing degree* or *mode* of row $n$. We prove that $M_n=\lfloor (n+1)\alpha\rfloor$ with $\alpha=p/(p+q)\in(0,1)$, so that the sequence $(M_n)_{n\ge0}$ — the *argmax staircase* — is a Beatty sequence of slope $\alpha$ evaluated at the shifted index $n+1$, and we study the binary *increment word*
$$w_\alpha(n)=M_{n+1}-M_n\in\{0,1\}.$$
Our results are the following. (i) The mode advances by exactly one letter of $w_\alpha$ per row. (ii) Every window of $L$ consecutive letters has letter sum $\lfloor L\alpha\rfloor$ or $\lfloor L\alpha\rfloor+1$; consequently $w_\alpha$ is *balanced*, has discrepancy less than $2$ from the ideal line, and the letter $1$ has frequency exactly $\alpha$ in every window sequence. (iii) A Morse–Hedlund dichotomy: $w_\alpha$ is periodic if and only if $\alpha\in\mathbb{Q}$; for integer weights $P,Q$ the exact period is $P+Q$ and every window of that length carries exactly $P$ ones. (iv) The subword complexity satisfies $p_\alpha(L)\le L+1$ for all slopes, with equality for all $L$ when $\alpha$ is irrational, and $p_\alpha(L)=\min\{L+1,\,P+Q\}$ when $\alpha=P/(P+Q)$ with $\gcd(P,Q)=1$. Thus the combinatorics of binomial peaks is exactly the combinatorics of an irrational (or rational) circle rotation. (v) Finally, $w_\alpha$ is the *shift by one letter* of the lower mechanical word of slope $\alpha$, and is never equal to it — a precise statement of the extra arithmetic carried by the $+1$ in $\lfloor(n+1)\alpha\rfloor$. The proofs are elementary and self-contained, relying only on floor-function estimates, Dirichlet's approximation theorem, and the structure of the orbit of a rational rotation.

**Keywords:** binomial mode, Beatty sequence, Sturmian word, balanced word, subword complexity, circle rotation, Morse–Hedlund dichotomy, Christoffel word.

---

## 1. Introduction

The mode of a binomial distribution is an object of textbook simplicity: for $\mathrm{Bin}(n,\theta)$ it is $\lfloor(n+1)\theta\rfloor$, a formula that one derives in two lines from the ratio of consecutive terms. What is much less commonly observed is that this formula, read as $n$ varies, defines an integer sequence with an extremely rigid combinatorial structure — one that has been studied intensively, but under a different name and in a different field.

The sequence $n\mapsto\lfloor(n+1)\alpha\rfloor$ is a *Beatty sequence*. Its first-difference word, an infinite word over the alphabet $\{0,1\}$, is (up to a shift) the *mechanical word of slope $\alpha$*: the canonical symbolic coding of the rotation $x\mapsto x+\alpha$ on the circle $\mathbb{R}/\mathbb{Z}$, and the archetype of a **Sturmian word** when $\alpha$ is irrational. Sturmian words are, by the Morse–Hedlund theorem, exactly the aperiodic infinite words of minimal subword complexity, and they carry a hundred years of accumulated theory: balance and the three-distance theorem, Christoffel words and continued fractions, palindromic closure, Ostrowski numeration, and connections to quasicrystals, digital geometry, and optimal scheduling.

This paper makes the identification precise and extracts from it the complete combinatorial description of how the peak of a binomial distribution moves as the number of trials increases. The content is not that the mode of $\mathrm{Bin}(n,\theta)$ is $\lfloor(n+1)\theta\rfloor$ — that is classical — but that the *dynamics of the mode across rows* is a circle rotation, together with the exact complexity, balance, periodicity, and frequency statements that the identification yields, and a careful analysis of the one-letter shift that separates the peak word from the standard mechanical word.

### 1.1 Overview of results

Throughout, $p,q>0$ are fixed positive real weights and
$$\alpha \;=\; \operatorname{slope}(p,q) \;=\; \frac{p}{p+q}\;\in\;(0,1).$$

* **Theorem A** (staircase identification). $M_n=\lfloor(n+1)\alpha\rfloor$ for all $n$; this is the Beatty sequence of slope $\alpha$ at index $n+1$.
* **Theorem B** (binarity and one-letter advance). $w_\alpha(n)\in\{0,1\}$ and $M_{n+1}=M_n+w_\alpha(n)$.
* **Theorem C** (window bound, balance, discrepancy, frequency). $\lfloor L\alpha\rfloor\le W_\alpha(m,L)\le\lfloor L\alpha\rfloor+1$; hence $|W_\alpha(m,L)-W_\alpha(m',L)|\le1$, $|W_\alpha(m,L)-L\alpha|<2$, and $W_\alpha(m,L)/L\to\alpha$.
* **Theorem D** (Morse–Hedlund dichotomy). $w_\alpha$ is periodic $\iff$ $\alpha\in\mathbb{Q}$.
* **Theorem E** (rational period). For integers $P,Q$ with $P+Q>0$ and $\alpha=P/(P+Q)$, the word has period $P+Q$ and every window of length $P+Q$ contains exactly $P$ ones.
* **Theorem F** (complexity upper bound). $p_\alpha(L)\le L+1$ for every real $\alpha$ and every $L$.
* **Theorem G** (exact complexity, irrational slope). $\alpha$ irrational $\Rightarrow$ $p_\alpha(L)=L+1$ for every $L$; the peak word is Sturmian.
* **Theorem H** (exact complexity, rational slope). $\gcd(P,Q)=1$, $P,Q\ge1$ $\Rightarrow$ $p_{P/(P+Q)}(L)=\min\{L+1,P+Q\}$.
* **Theorem I** (the shift). $w_\alpha(n)=s_\alpha(n+1)$ where $s_\alpha$ is the lower mechanical word, and $w_\alpha\ne s_\alpha$ for every $\alpha\in(0,1)$.

---

## 2. Definitions

**Definition 2.1 (Binomial weights and the mode).** For $n\in\mathbb{N}$ and $p,q>0$ let
$$b_{n,k}\;=\;\binom{n}{k}p^{k}q^{\,n-k},\qquad 0\le k\le n .$$
The *mode*, or upper bracketing degree, is
$$M_n\;=\;\max\big\{\,k\in\{0,\dots,n\} \;:\; b_{n,k}=\textstyle\max_{0\le j\le n}b_{n,j}\,\big\},$$
i.e. the largest maximiser. Taking the largest maximiser makes $M_n$ well defined even in the tie case, which occurs precisely when $(n+1)\alpha\in\mathbb{Z}$.

**Definition 2.2 (Slope, staircase, increment word).** Set $\alpha=p/(p+q)$. The *argmax staircase* of slope $\alpha$ is
$$S_\alpha(n)\;=\;\big\lfloor (n+1)\alpha\big\rfloor \in \mathbb{Z},\qquad n\ge0,$$
and its *increment word* is
$$w_\alpha(n)\;=\;S_\alpha(n+1)-S_\alpha(n).$$

**Definition 2.3 (Lower mechanical word).** The *lower mechanical word* of slope $\alpha$ is
$$s_\alpha(m)\;=\;\lfloor (m+1)\alpha\rfloor-\lfloor m\alpha\rfloor,\qquad m\ge0 .$$
For irrational $\alpha\in(0,1)$ this is the standard Sturmian word of slope $\alpha$ and intercept $0$.

**Definition 2.4 (Window sum).** For $m,L\ge0$,
$$W_\alpha(m,L)\;=\;\sum_{i=0}^{L-1}w_\alpha(m+i),$$
the number of $1$s in the length-$L$ window at position $m$, equivalently the total rise of the staircase across $[m,m+L)$.

**Definition 2.5 (Factors and complexity).** The *factor of length $L$ at position $m$* is the finite word
$$F_\alpha(m,L)\;=\;\big(w_\alpha(m),\,w_\alpha(m+1),\,\dots,\,w_\alpha(m+L-1)\big),$$
which we regard as the function $t\mapsto w_\alpha(m+t)$ for $t<L$ (and $0$ for $t\ge L$, a harmless padding convention). The *subword complexity* is
$$p_\alpha(L)\;=\;\#\{\,F_\alpha(m,L)\;:\;m\ge0\,\}.$$

**Definition 2.6 (Periodicity).** $w_\alpha$ is *periodic with period $T\ge1$* if $w_\alpha(n+T)=w_\alpha(n)$ for all $n\ge0$.

**Definition 2.7 (Balance).** An infinite binary word is *balanced* if any two of its factors of equal length have letter sums differing by at most $1$.

---

## 3. The staircase: identification of the mode

**Theorem 3.1 (Theorem A: the mode is a shifted Beatty sequence).**
For all $p,q>0$ and all $n\ge0$,
$$M_n\;=\;\big\lfloor (n+1)\alpha\big\rfloor\;=\;S_\alpha(n),\qquad \alpha=\frac{p}{p+q}.$$

*Proof sketch.* For $1\le k\le n$,
$$\frac{b_{n,k}}{b_{n,k-1}}=\frac{n-k+1}{k}\cdot\frac{p}{q},$$
and this ratio is $\ge1$ exactly when $kq\le(n-k+1)p$, i.e. when $k\le(n+1)p/(p+q)=(n+1)\alpha$. Hence the sequence $k\mapsto b_{n,k}$ is non-decreasing on $\{0,\dots,\lfloor(n+1)\alpha\rfloor\}$ and strictly decreasing afterwards, and the *largest* index attaining the maximum is $\lfloor(n+1)\alpha\rfloor$. (This index lies in $\{0,\dots,n\}$ because $0<\alpha<1$ forces $\lfloor(n+1)\alpha\rfloor\le n$.) $\square$

Two immediate remarks. First, $0<\alpha<1$ holds for all positive $p,q$: positivity gives $\alpha>0$ and $p<p+q$ gives $\alpha<1$. Second, only the ratio $p:q$ matters, so the result covers both the probabilistic normalisation $p+q=1$ and arbitrary positive weights.

**Proposition 3.2 (Quasi-periodicity of the staircase).** If $T\alpha=c\in\mathbb{Z}$ then $S_\alpha(n+T)=S_\alpha(n)+c$ for all $n$.

*Proof.* $S_\alpha(n+T)=\lfloor (n+1)\alpha+T\alpha\rfloor=\lfloor(n+1)\alpha+c\rfloor=S_\alpha(n)+c$. $\square$

---

## 4. The increment word is binary

**Lemma 4.1.** $w_\alpha(n)=\lfloor (n+1)\alpha+\alpha\rfloor-\lfloor (n+1)\alpha\rfloor$.

*Proof.* Immediate from $S_\alpha(n+1)=\lfloor(n+2)\alpha\rfloor=\lfloor(n+1)\alpha+\alpha\rfloor$. $\square$

**Theorem 4.2 (Theorem B).** If $0\le\alpha\le1$ then $w_\alpha(n)\in\{0,1\}$ for every $n$, and consequently
$$M_{n+1}\;=\;M_n+w_\alpha(n).$$
In words: *from one row of the binomial weights to the next, the mode either stays put or advances by exactly one, and the choice is recorded by the letter $w_\alpha(n)$.*

*Proof.* Monotonicity of $\lfloor\cdot\rfloor$ and $\alpha\ge0$ give $w_\alpha(n)\ge0$. For the upper bound, $\lfloor (n+1)\alpha+\alpha\rfloor\le\lfloor (n+1)\alpha+1\rfloor=\lfloor(n+1)\alpha\rfloor+1$. The displayed recursion is then Theorem 3.1 together with the definition of $w_\alpha$. $\square$

---

## 5. Window sums: balance, discrepancy, frequency

The following elementary sandwich is the engine of this section.

**Lemma 5.1 (Floor sandwich).** For all reals $x,y$,
$$\lfloor x\rfloor+\lfloor y\rfloor\;\le\;\lfloor x+y\rfloor\;\le\;\lfloor x\rfloor+\lfloor y\rfloor+1 .$$

*Proof.* Lower bound: $\lfloor x\rfloor+\lfloor y\rfloor$ is an integer $\le x+y$. Upper bound: $x+y<\lfloor x\rfloor+\lfloor y\rfloor+2$, so $\lfloor x+y\rfloor\le\lfloor x\rfloor+\lfloor y\rfloor+1$. $\square$

**Lemma 5.2 (Telescoping).** $W_\alpha(m,L)=S_\alpha(m+L)-S_\alpha(m)=\big\lfloor (m+1)\alpha+L\alpha\big\rfloor-\big\lfloor (m+1)\alpha\big\rfloor$.

*Proof.* Induction on $L$ using $S_\alpha(n+1)=S_\alpha(n)+w_\alpha(n)$; the second equality is $S_\alpha(m+L)=\lfloor(m+L+1)\alpha\rfloor$. $\square$

**Theorem 5.3 (Theorem C, window bound).** For all $m,L\ge0$ and every real $\alpha$,
$$\big\lfloor L\alpha\big\rfloor\;\le\;W_\alpha(m,L)\;\le\;\big\lfloor L\alpha\big\rfloor+1 .$$

*Proof.* Apply Lemma 5.1 with $x=(m+1)\alpha$, $y=L\alpha$ and subtract $\lfloor(m+1)\alpha\rfloor$, using Lemma 5.2. $\square$

Three corollaries follow at once, and they are the reason the window bound is the right statement to isolate: it is *position-free*.

**Corollary 5.4 (Balance).** For all $m,m',L$: $\big|W_\alpha(m,L)-W_\alpha(m',L)\big|\le1$. Hence the increment word of the argmax staircase is balanced: any two blocks of $L$ consecutive rows contain numbers of mode-advances differing by at most one.

**Corollary 5.5 (Uniformly bounded discrepancy).** For all $m,L$: $\big|W_\alpha(m,L)-L\alpha\big|<2$.

*Proof.* $\lfloor L\alpha\rfloor\le L\alpha<\lfloor L\alpha\rfloor+1$ combined with Theorem 5.3. $\square$

**Corollary 5.6 (Frequency of the letter $1$).** For every fixed $m$,
$$\lim_{L\to\infty}\frac{W_\alpha(m,L)}{L}\;=\;\alpha\;=\;\frac{p}{p+q}.$$

*Proof.* $\left|\frac{W_\alpha(m,L)}{L}-\alpha\right|=\frac{|W_\alpha(m,L)-L\alpha|}{L}<\frac{2}{L}\to0$. $\square$

Corollary 5.6 is a law-of-large-numbers statement for the binomial mode obtained with no probabilistic input and with an explicit, *uniform*, constant error bound: the mode of row $n$ never deviates from the ideal line by more than an absolute constant, for any $n$ and any weights.

**Proposition 5.7 (Both letters occur).** If $0<\alpha<1$ then there exist $n$ with $w_\alpha(n)=0$ and $n'$ with $w_\alpha(n')=1$.

*Proof.* If $w_\alpha\equiv0$ then $W_\alpha(0,L)=0$ for all $L$, contradicting $W_\alpha(0,L)\ge\lfloor L\alpha\rfloor\ge1$ once $L>1/\alpha$. If $w_\alpha\equiv1$ then $W_\alpha(0,L)=L$, contradicting $W_\alpha(0,L)\le\lfloor L\alpha\rfloor+1\le L\alpha+1$ once $L(1-\alpha)>1$. $\square$

---

## 6. The Morse–Hedlund dichotomy: periodicity is rationality

**Theorem 6.1 (Easy direction).** If $T\alpha\in\mathbb{Z}$ for some $T\ge1$, then $w_\alpha(n+T)=w_\alpha(n)$ for all $n$. In particular, for $\alpha=r\in\mathbb{Q}$ written with denominator $d$, the word is periodic with period $d$.

*Proof.* Apply Proposition 3.2 at $n$ and at $n+1$ and subtract; the shift $c$ cancels. $\square$

The converse requires an argument. Suppose $w_\alpha$ has period $T\ge1$.

**Lemma 6.2 (Constant rise per period).** If $w_\alpha$ has period $T$ then $S_\alpha(n+T)-S_\alpha(n)=c$ for all $n$, where $c=S_\alpha(T)-S_\alpha(0)$.

*Proof.* $S_\alpha(n+T)-S_\alpha(n)=W_\alpha(n,T)=\sum_{i<T}w_\alpha(n+i)$, and periodicity makes this sum independent of $n$. $\square$

**Lemma 6.3 (Exact rate).** With $T,c$ as above, $T\alpha=c$.

*Proof sketch.* Iterating Lemma 6.2 gives $S_\alpha(kT)=S_\alpha(0)+kc$ for every $k\ge0$. On the other hand $S_\alpha(kT)=\lfloor(kT+1)\alpha\rfloor$ satisfies
$$(kT+1)\alpha-1\;<\;S_\alpha(kT)\;\le\;(kT+1)\alpha .$$
Substituting the exact value yields, for all $k$,
$$k(T\alpha-c)\;\in\;\big(\,S_\alpha(0)-\alpha-1+\alpha,\; S_\alpha(0)+1-\alpha\,\big)$$
up to a fixed additive constant — that is, $k(T\alpha-c)$ stays inside a *bounded* interval independent of $k$. If $T\alpha-c\ne0$, choosing $k$ larger than (the absolute value of) that constant divided by $|T\alpha-c|$ contradicts boundedness. Hence $T\alpha=c$. $\square$

**Theorem 6.4 (Theorem D: Morse–Hedlund dichotomy for the argmax staircase).**
$$\exists\,T\ge1\ \forall n:\ w_\alpha(n+T)=w_\alpha(n)\qquad\Longleftrightarrow\qquad \alpha\in\mathbb{Q}.$$
Equivalently: for irrational $\alpha$ the peak word is aperiodic — for every $T\ge1$ there is an $n$ with $w_\alpha(n+T)\ne w_\alpha(n)$.

*Proof.* ($\Leftarrow$) Theorem 6.1. ($\Rightarrow$) Lemma 6.3 gives $\alpha=c/T\in\mathbb{Q}$. $\square$

### 6.1 The rational case in detail

**Theorem 6.5 (Theorem E).** Let $P,Q\in\mathbb{N}$ with $P+Q>0$ and $\alpha=P/(P+Q)$. Then:
1. $w_\alpha(n+(P+Q))=w_\alpha(n)$ for all $n$; the word is periodic with period $P+Q$.
2. $W_\alpha(m,P+Q)=P$ for *every* $m$: each window of length $P+Q$ contains exactly $P$ ones.

*Proof.* $(P+Q)\alpha=P\in\mathbb{Z}$, so Theorem 6.1 gives (1) and Proposition 3.2 gives $S_\alpha(m+P+Q)=S_\alpha(m)+P$, which is (2) by Lemma 5.2. $\square$

Statement (2) is stronger than periodicity: it is an *exact* count valid at every position, not merely on average and not merely for windows aligned with the period. Over $P+Q$ consecutive rows the binomial mode advances by exactly $P$, with zero error.

---

## 7. Subword complexity

We now count factors. The key device is a monotone integer statistic that determines the factor.

### 7.1 The circle picture and the level statistic

**Definition 7.1 (Prefix profile).** For $m,j\ge0$ set $\pi_\alpha(m,j)=S_\alpha(m+j)-S_\alpha(m)$, the cumulative rise over the first $j$ steps of the window at $m$. Note $\pi_\alpha(m,0)=0$ and $w_\alpha(m+t)=\pi_\alpha(m,t+1)-\pi_\alpha(m,t)$, so the profile $\big(\pi_\alpha(m,j)\big)_{j\le L}$ and the factor $F_\alpha(m,L)$ determine each other.

**Lemma 7.2 (Transfer to the circle).** Let $x_m=\{(m+1)\alpha\}$ be the fractional part. Then
$$\pi_\alpha(m,j)\;=\;\big\lfloor\, x_m+j\alpha\,\big\rfloor .$$

*Proof.* Write $(m+1)\alpha=\lfloor(m+1)\alpha\rfloor+x_m$ and use $\lfloor N+y\rfloor=N+\lfloor y\rfloor$ for $N\in\mathbb{Z}$ in Lemma 5.2. $\square$

Lemma 7.2 is the whole content of the "binomial peaks $=$ circle rotation" slogan: the factor read at position $m$ depends on $m$ **only** through the point $x_m$ of the circle $\mathbb{R}/\mathbb{Z}$, and the map $m\mapsto x_m$ is the orbit of the rotation by $\alpha$ started at $x_0=\{\alpha\}$.

**Lemma 7.3 (Coordinatewise bounds and monotonicity).** For all $m,j$: $0\le\pi_\alpha(m,j)-\lfloor j\alpha\rfloor\le1$. Moreover if $x_m\le x_{m'}$ then $\pi_\alpha(m,j)\le\pi_\alpha(m',j)$ for every $j$.

*Proof.* From Lemma 7.2 and $0\le x_m<1$: $\lfloor j\alpha\rfloor\le\lfloor x_m+j\alpha\rfloor\le\lfloor j\alpha+1\rfloor=\lfloor j\alpha\rfloor+1$. Monotonicity of $\lfloor\cdot\rfloor$ gives the second claim. $\square$

**Definition 7.4 (Level).** For $L,m\ge0$ let
$$\lambda_\alpha(L,m)\;=\;\sum_{j=0}^{L}\big(\pi_\alpha(m,j)-\lfloor j\alpha\rfloor\big).$$

By Lemma 7.3 each summand lies in $\{0,1\}$ and the $j=0$ term vanishes, so $0\le\lambda_\alpha(L,m)\le L$: the level takes at most $L+1$ values.

**Lemma 7.5 (Level as a counting function).** Using the indicator identity $\lfloor x+y\rfloor-\lfloor y\rfloor=\mathbf{1}\{1-\{y\}\le x\}$ valid for $0\le x<1$,
$$\lambda_\alpha(L,m)\;=\;\#\big\{\,j\in\{1,\dots,L\}\;:\;\{j\alpha\}\;>\;1-x_m\,\big\},$$
i.e. $\lambda_\alpha(L,m)$ counts how many of the $L$ rotation points $\{\alpha\},\{2\alpha\},\dots,\{L\alpha\}$ lie in the arc $(1-x_m,1)$. In particular $\lambda_\alpha(L,\cdot)$ is a non-decreasing function of $x_m$.

**Lemma 7.6 (The level determines the factor).** If $\lambda_\alpha(L,m)=\lambda_\alpha(L,m')$ then $\pi_\alpha(m,j)=\pi_\alpha(m',j)$ for all $j\le L$, hence $F_\alpha(m,L)=F_\alpha(m',L)$. Conversely equal factors give equal levels.

*Proof sketch.* By symmetry assume $x_m\le x_{m'}$. Lemma 7.3 gives $\pi_\alpha(m,j)\le\pi_\alpha(m',j)$ termwise; if the two sums of these termwise-comparable quantities are equal, every term must be equal. The converse is immediate since the level is a function of the prefix profile, which is a function of the factor. $\square$

### 7.2 The upper bound

**Theorem 7.7 (Theorem F: complexity $\le L+1$).** For every real $\alpha$ and every $L\ge0$,
$$p_\alpha(L)\;\le\;L+1 .$$
Equivalently (pigeonhole form): among any $L+2$ positions, two read the same factor of length $L$.

*Proof.* The map $F_\alpha(m,L)\mapsto\lambda_\alpha(L,m)$ is well defined (Lemma 7.6, converse direction) and injective on the factor set (Lemma 7.6, forward direction), with values in $\{0,1,\dots,L\}$, a set of size $L+1$. $\square$

Geometrically: the $L$ thresholds $1-\{j\alpha\}$, $j=1,\dots,L$, cut the circle into at most $L+1$ arcs, and positions whose rotation points lie in the same arc read the same factor.

### 7.3 The lower bound for irrational slope

The upper bound is achieved exactly when every level $v\in\{0,\dots,L\}$ is attained by some position.

**Lemma 7.8 (Density of the orbit).** If $\alpha$ is irrational then for every $0\le a<b\le1$ there is $k\ge1$ with $\{k\alpha\}\in(a,b)$.

*Proof sketch.* Dirichlet's approximation theorem yields infinitely many $k$ with $\{k\alpha\}$ arbitrarily close to $0$ (from above or below); iterating such a $k$ produces an orbit whose consecutive points are spaced by less than $b-a$, hence one of them lands in $(a,b)$. Irrationality also gives injectivity of $k\mapsto\{k\alpha\}$. $\square$

**Lemma 7.9 (All levels attained).** If $\alpha$ is irrational then for every $L$ and every $v\in\{0,\dots,L\}$ there is $m$ with $\lambda_\alpha(L,m)=v$.

*Proof sketch.* By Lemma 7.5, $\lambda_\alpha(L,m)$ is the number of points of $X_L=\{\{\alpha\},\dots,\{L\alpha\}\}$ exceeding $1-x_m$. Since $\alpha$ is irrational, $X_L$ consists of $L$ distinct points in $(0,1)$; sorting them, the "count above a threshold" function takes every value in $\{0,\dots,L\}$ as the threshold sweeps $(0,1)$, and each such threshold value is realised by some $x_m$ because the orbit $\{x_m\}=\{\{(m+1)\alpha\}\}$ is dense (Lemma 7.8). Choosing $x_m$ strictly between two consecutive sorted points realises the desired level. $\square$

**Theorem 7.10 (Theorem G: the peak word is Sturmian).** If $\alpha$ is irrational then
$$p_\alpha(L)\;=\;L+1\qquad\text{for every }L\ge0 .$$
Consequently, for weights $p,q>0$ whose slope $\alpha=p/(p+q)$ is irrational, the argmax staircase of the binomial weights is $M_n=\lfloor(n+1)\alpha\rfloor$, its increment word is balanced, and it has exactly $L+1$ factors of each length $L$ — the defining combinatorics of a Sturmian word.

*Proof.* Theorem 7.7 gives $\le$; Lemmas 7.6 and 7.9 give a bijection between attained levels and factors, so $\ge$. $\square$

**Example 7.11 (An explicit Sturmian binomial peak word).** Take $p=\sqrt2$, $q=1$. Then
$$\alpha=\frac{\sqrt2}{\sqrt2+1}=2-\sqrt2=0.585786\ldots,$$
which is irrational. Hence the largest maximiser of $\binom{n}{k}(\sqrt2)^{k}$ over $k\le n$ equals $\lfloor(n+1)(2-\sqrt2)\rfloor$, and the increment word
$$1\,0\,1\,0\,1\,1\,0\,1\,0\,1\,1\,0\,1\,0\,1\,0\,1\,1\,0\,1\cdots$$
has exactly $L+1$ factors of every length $L$: it is aperiodic, balanced, and of minimal complexity.

### 7.4 The rational case: the complete complexity function

For rational slope the orbit is finite and the complexity saturates. Two ingredients replace Lemma 7.8.

**Lemma 7.12 (Surjectivity of the rational orbit).** If $\gcd(a,b)=1$ and $b\ge1$ then for every residue $i<b$ there is $k\ge1$ with $ka\equiv i\pmod b$; moreover $\{k\cdot a/b\}=\big((ka)\bmod b\big)/b$.

*Proof.* $a$ is invertible modulo $b$; take $k\equiv i a^{-1}$, adjusting by a multiple of $b$ to make $k$ positive. The fractional-part identity is the division algorithm. $\square$

**Lemma 7.13 (All levels attained, rational slope).** If $\gcd(a,b)=1$, $b\ge1$, and $L<b$, then for slope $a/b$ every level $v\le L$ is attained.

*Proof sketch.* By Lemma 7.12 the set $X_L=\{\{j\,a/b\}: 1\le j\le L\}$ consists of $L$ distinct multiples of $1/b$, and the attainable thresholds $1-x_m$ likewise range over all multiples of $1/b$ because the orbit $m\mapsto\{(m+1)a/b\}$ is onto $\{0,1/b,\dots,(b-1)/b\}$. Since $L<b$, there are enough distinct grid points strictly between consecutive elements of $X_L$ to realise every count $v\in\{0,\dots,L\}$. $\square$

**Theorem 7.14 (Exact complexity below the period).** If $\gcd(a,b)=1$ and $L<b$, the increment word of slope $a/b$ satisfies $p_{a/b}(L)=L+1$.

**Lemma 7.15 (Complexity is capped by the period and non-decreasing).** If $w_\alpha$ has period $T\ge1$ then (i) $p_\alpha(L)\le T$ for every $L$, since every factor equals the factor read at $m\bmod T$; and (ii) $L\mapsto p_\alpha(L)$ is non-decreasing, since truncating factors of length $L+1$ to length $L$ surjects onto the factors of length $L$.

**Theorem 7.16 (Theorem H: the complexity function of the binomial peak word).** Let $P,Q\ge1$ be coprime integers and $\alpha=P/(P+Q)$. Then, for every $L\ge0$,
$$p_\alpha(L)\;=\;\min\{\,L+1,\;P+Q\,\}.$$

*Proof.* Note $\gcd(P,P+Q)=\gcd(P,Q)=1$ and $\alpha=P/(P+Q)$. If $L<P+Q$ apply Theorem 7.14 with $a=P$, $b=P+Q$. If $L\ge P+Q$, then $p_\alpha(L)\le P+Q$ by Lemma 7.15(i) with $T=P+Q$ (Theorem 6.5), while monotonicity (Lemma 7.15(ii)) and the case $L=P+Q-1$ give $p_\alpha(L)\ge p_\alpha(P+Q-1)=P+Q$. $\square$

So the complexity function grows with Sturmian slope $1$ until it reaches the period and is constant thereafter — the complexity function of a *Christoffel word*, the periodic balanced word of rational slope.

---

## 8. The one-letter shift: the peak word is Sturmian but not the mechanical word

**Theorem 8.1 (Theorem I, part 1: the shift identity).** For every real $\alpha$ and $n\ge0$,
$$w_\alpha(n)\;=\;s_\alpha(n+1).$$

*Proof.* $w_\alpha(n)=\lfloor(n+2)\alpha\rfloor-\lfloor(n+1)\alpha\rfloor$, which is $s_\alpha$ evaluated at $m=n+1$. $\square$

Thus the peak word is the mechanical word of slope $\alpha$ with its first letter deleted. This is enough to inherit every *shift-invariant* property of Sturmian words — balance, complexity, factor set, letter frequency, aperiodicity — which is why all the results above hold. But the shift is not invisible.

**Theorem 8.2 (Theorem I, part 2: the shift is never trivial).** For every $\alpha\in(0,1)$ there exists $n$ with $w_\alpha(n)\ne s_\alpha(n)$.

*Proof.* Suppose $w_\alpha(n)=s_\alpha(n)$ for all $n$. Combined with Theorem 8.1 this reads $s_\alpha(n+1)=s_\alpha(n)$ for all $n$, so $s_\alpha$ is constant. Its value at $0$ is $\lfloor\alpha\rfloor-\lfloor0\rfloor=0$ since $0<\alpha<1$, so $s_\alpha\equiv0$, hence $w_\alpha\equiv0$ by Theorem 8.1. This contradicts Proposition 5.7, which supplies $n$ with $w_\alpha(n)=1$. $\square$

**Proposition 8.3 (Explicit disagreement at the origin).** If $1/2\le\alpha<1$ then $w_\alpha(0)=1$ while $s_\alpha(0)=0$.

*Proof.* $\lfloor\alpha\rfloor=0$ and $\lfloor2\alpha\rfloor=1$, so $w_\alpha(0)=\lfloor2\alpha\rfloor-\lfloor\alpha\rfloor=1$ and $s_\alpha(0)=\lfloor\alpha\rfloor-0=0$. $\square$

The interpretation is worth stating carefully, because it is the one place where the naive slogan "the binomial peak word is the Sturmian word of slope $\alpha$" is *false as stated*. The correct statement is: the binomial peak word is the Sturmian word of slope $\alpha$ **and intercept $\alpha$** — the coding of the rotation orbit started at $x_0=\{\alpha\}$ rather than at $0$. All the combinatorial invariants coincide; the words themselves never do.

---

## 9. Algorithms

All quantities above are computable exactly, and for rational slopes with *integer arithmetic only* — no floating point, hence no rounding hazard near ties.

### 9.1 Exact staircase and increment word (Bresenham form)

For $\alpha=P/(P+Q)$ with integers $P,Q$, the staircase is $S(n)=\lfloor (n+1)P/(P+Q)\rfloor$, computable by integer division; and the word by differencing. An incremental form maintains an accumulator $r_n=(n+1)P\bmod(P+Q)$: from state $(S,r)$, add $P$ to $r$; if $r\ge P+Q$ subtract $P+Q$ and emit the letter $1$ (advance the mode), else emit $0$. This is precisely Bresenham's line-drawing loop and costs $O(1)$ integer operations per row, $O(N)$ for $N$ rows. For irrational $\alpha$ one uses high-precision rationals or an interval-arithmetic guard around ties.

### 9.2 Direct mode computation and cross-check

Independently, one can compute $\arg\max_k \binom{n}{k}p^kq^{n-k}$ by scanning the ratio test $r_k=\frac{n-k+1}{k}\cdot\frac pq$ and taking the largest $k$ with $r_k\ge1$: $O(n)$ per row, and exact in rational arithmetic. Agreement with $\lfloor(n+1)\alpha\rfloor$ is a direct numerical certificate of Theorem 3.1.

### 9.3 Complexity by level enumeration

By Lemma 7.6, $p_\alpha(L)$ equals the number of distinct values of the level statistic. Since the level is a monotone function of $x_m=\{(m+1)\alpha\}$, one can compute $p_\alpha(L)$ *without enumerating factors*: sort the thresholds $1-\{j\alpha\}$, $j\le L$, and count how many of the resulting arcs contain at least one orbit point. For rational slope with denominator $b$ the orbit is the grid $\{i/b\}$ and the count is exact in $O((L+b)\log(L+b))$ time. A naive alternative — collect all factors $F_\alpha(m,L)$ for $m<T$ (period) or $m<$ some horizon, and count distinct ones — costs $O(TL)$ and serves as a cross-check.

### 9.4 Balance and discrepancy audit

For a horizon $N$ and length $L$, compute all window sums $W(m,L)$, $m\le N-L$, via prefix sums in $O(N)$ and report $\max_m W-\min_m W$ (which Corollary 5.4 asserts is $\le1$) and $\max_m|W(m,L)-L\alpha|$ (which Corollary 5.5 asserts is $<2$).

### 9.5 Gap spectrum (return times)

The positions of the letter $1$ are the rows at which the mode advances. Their consecutive differences — the *return times* — are conjecturally governed by the three-distance theorem, taking at most three distinct values whose sizes are determined by the continued-fraction convergents of $\alpha$. Computing the gap multiset for a horizon $N$ costs $O(N)$ and provides sharp numerical evidence.

---

## 10. Applications and interpretation

**Exact mode tracking.** Any decision rule of the form "output the most likely count" applied to a binomial family — a maximum-a-posteriori class index, a quantised bin, a discretised argmax over a binomially-weighted grid — has its output given exactly by $\lfloor(n+1)\alpha\rfloor$ and its *change points* given exactly by the positions of $1$s in a Sturmian word. Rather than an asymptotic $n\alpha+O(\sqrt n)$ statement, one obtains an $O(1)$-cost update rule with a zero-error guarantee.

**Fairness and scheduling.** Balanced binary words are exactly the solutions of the optimal fair-scheduling problem "interleave $P$ tasks of type A with $Q$ of type B as evenly as possible". Theorem 6.5 says the binomial mode's advance pattern is such an optimal schedule with $P$ advances per $P+Q$ rows, and Corollary 5.4 says no block of rows is ever busier than another by more than one advance.

**Digital geometry.** The word $w_\alpha$ is the digitisation of a straight line of slope $\alpha$: the standard Bresenham rasterisation. The statement $p_\alpha(L)=L+1$ is the digital-geometry fact that a digital straight line of irrational slope contains exactly $L+1$ distinct patterns of length $L$; the rational case $\min\{L+1,P+Q\}$ is the corresponding statement for a periodic digital line.

**A transfer principle.** Because the identification is exact rather than approximate, every theorem about Sturmian words becomes a theorem about binomial peaks. Three examples: (i) the three-distance theorem controls the waiting times between mode advances; (ii) the continued-fraction expansion of $\alpha$ controls the hierarchical block structure of the advance pattern (standard words, $S$-adic decomposition); (iii) palindromicity of Sturmian factors implies that every finite pattern of mode advances occurs in reversed order somewhere else in the sequence.

**Why the $+1$ matters.** In applications where the *initial* rows matter — small-$n$ behaviour, warm-up phases, off-by-one indexing in a scheduler — using the standard mechanical word instead of the correct shifted word introduces a systematic one-row misalignment. Theorem 8.2 guarantees the two words really do differ, always; Proposition 8.3 identifies the very first row as the point of disagreement whenever $\alpha\ge1/2$.

---

## 11. Discussion

The three results that carry the most information are, we believe, the following.

1. **The window bound (Theorem 5.3)** is the single most efficient statement in the theory: balance, discrepancy, frequency, and the both-letters-occur lemma are all one-line corollaries, and it is proved from nothing but the floor sandwich. Isolating a *position-free* two-sided bound, rather than proving the corollaries separately, is what makes the development short.

2. **The level statistic (Definition 7.4)** converts a question about words into a question about a single monotone integer, and thereby makes both bounds on complexity accessible: the upper bound is a pigeonhole on the range $\{0,\dots,L\}$, and the lower bound is the statement that this range is exhausted, which reduces to density (irrational case) or surjectivity of a modular orbit (rational case). This is the standard three-distance-style argument packaged so that no interval combinatorics is needed for the upper bound at all.

3. **The shift theorem (Theorems 8.1–8.2)** is the sharpest formulation of the conjecture that motivated this work. The initial guess — "the increment word of the argmax staircase *is* the Sturmian word of slope $\alpha$" — is very nearly right and is literally false. The correct statement is that it is the Sturmian word of slope $\alpha$ and intercept $\alpha$, that all shift-invariant Sturmian properties transfer verbatim, and that no choice of $\alpha\in(0,1)$ makes the two words coincide. This is the precise sense in which the staircase "carries extra arithmetic from the $+1$ shift".

**Limitations.** The results describe the *largest* maximiser. The smallest maximiser is $\lceil (n+1)\alpha\rceil-1$ in all cases (it agrees with $\lfloor(n+1)\alpha\rfloor$ except at the tie rows, where $(n+1)\alpha\in\mathbb{Z}$ and it is smaller by one); its increment word is the *upper* mechanical word of the same slope, again shifted, and the two words differ only at the (density-zero, and for irrational $\alpha$ empty) set of tie rows. Everything here is about a one-parameter family with fixed $p,q$; the behaviour of the mode as $p,q$ vary with $n$ is not addressed.

---

## 12. Future directions

*The following programme is the natural continuation of the results proved above.*

**1. A three-distance theorem for peak-return times.** The gaps between successive rows $n$ at which the mode advances (i.e. $w_\alpha(n)=1$) are the return times of the rotation $x\mapsto x+\alpha$ to an arc, so the three-distance (Steinhaus) theorem predicts that at most three distinct gap lengths occur at any scale, with values given by the continued-fraction convergents of $\alpha$. The transfer map to the circle needed for this is exactly the identity $\pi_\alpha(m,j)=\lfloor\{(m+1)\alpha\}+j\alpha\rfloor$ established here, so the remaining work is combinatorial rather than analytic.

**2. An Ostrowski (continued-fraction) formula for the peak location.** The quantity $\lfloor(n+1)\alpha\rfloor$ admits an exact expansion in the Ostrowski numeration system attached to the continued fraction of $\alpha$. This would upgrade the *asymptotic* statement "the mode is $n\alpha+O(1)$" to an exact digit-by-digit description of the peak of $(p+q)^n$. The discrepancy bound $|W_\alpha(m,L)-L\alpha|<2$ proved here is the zeroth-order case; Ostrowski gives all orders, and would yield explicit error terms for the mode of a binomial distribution with no probabilistic input.

**3. Palindromic and Christoffel structure of the peak word.** Every factor of a Sturmian word of slope $\alpha$ is a factor of a Christoffel word attached to a convergent $P_k/Q_k$ of $\alpha$. Hence the finite binomial rows $\binom{n}{k}P^kQ^{n-k}$ with $P/Q$ a convergent should reproduce, exactly, the local peak patterns of the irrational-weight family. The rational complexity formula $p(L)=\min\{L+1,P+Q\}$ proved here is the first step: it shows the rational words are exactly the Christoffel words, so the approximation scheme is the right one.

**4. Multinomial and higher-dimensional analogues.** For multinomial weights the argmax is a lattice point rather than an integer, and the natural conjecture is that its increment sequence codes a rotation on a higher-dimensional torus — that is, that the peak word becomes an Arnoux–Rauzy or billiard word. Complexity $L+1$ would be replaced by a polynomial in $L$.

**5. Effective algorithms from the structure.** Because the peak word is $S$-adically generated by the continued fraction of $\alpha$, the position of the $N$-th mode advance should be computable in $O(\log N)$ arithmetic operations rather than $O(N)$, by descending the continued-fraction expansion. This turns a structural theorem into a genuinely faster algorithm for mode tracking.

---

## 13. Conclusion

The mode of the binomial weights $\binom{n}{k}p^kq^{n-k}$ is exactly $\lfloor(n+1)\alpha\rfloor$ with $\alpha=p/(p+q)$, and the pattern of its advances is a Sturmian word: balanced, of subword complexity exactly $L+1$ for irrational $\alpha$ and exactly $\min\{L+1,P+Q\}$ for the rational slope $P/(P+Q)$ in lowest terms, periodic precisely when $\alpha$ is rational, with the letter $1$ of frequency exactly $\alpha$ and discrepancy uniformly less than $2$. It is the shift by one letter of the lower mechanical word of the same slope, and never equal to it. Binomial peaks and circle rotations are, combinatorially, the same object.
