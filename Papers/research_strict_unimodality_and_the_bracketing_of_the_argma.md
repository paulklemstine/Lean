# The Two Bracketing Degrees of a Strictly Log-Concave Window, and the Exact Location of the Binomial Mode

**Author:** Aristotle
**Date:** 2026-08-21

## Abstract

For a positive finite sequence $a_0, a_1, \dots, a_n$ one may define two indices that bracket the location of the maximum: the *lower bracketing degree* $d^-$, the first index at which the sequence stops rising strictly, and the *upper bracketing degree* $d^+$, the first index at which it begins to fall strictly. That such a bracket exists, and that a strictly log-concave sequence is unimodal, are classical and easy. The content of the present work is the **explicit comparison of the two bracketing degrees**.

We prove that for a strictly log-concave positive window ($a_k a_{k+2} < a_{k+1}^2$ for $k+2 \le n$) one always has $d^- \le d^+ \le d^- + 1$, with $d^+ = d^- + 1$ if and only if $d^- < n$ and $a_{d^-} = a_{d^-+1}$; and that the set of maximisers is exactly the integer interval $[d^-, d^+]$, with strict increase below and strict decrease above. We then isolate the mechanism that makes both degrees *computable*: a **threshold window**, in which the rise criterion takes the form $a_k < a_{k+1} \iff k+1 < \theta$ (with the weak criterion $a_k \le a_{k+1} \iff k+1 \le \theta$) for a single real threshold $\theta \in (0, n+1)$. For such a window,
$$d^- = \lceil \theta\rceil - 1, \qquad d^+ = \lfloor \theta\rfloor, \qquad d^+ = d^- + 1 \iff \theta \in \mathbb{Z}.$$

Running this machine on the binomial weights $w_k = \binom{n}{k}p^kq^{n-k}$ ($p, q>0$) — the terms of the binomial theorem for $(p+q)^n$ — produces a fully explicit description of the mode in terms of the *mode parameter* $\theta = (n+1)p/(p+q)$: the maximisers are exactly the $k$ with $\lceil\theta\rceil - 1 \le k \le \lfloor\theta\rfloor$; a two-term plateau occurs iff $\theta \in \mathbb{Z}$; for integer weights $p = P$, $q = Q$ this reads $(P+Q) \mid (n+1)P$; and for $P = Q = 1$ the brackets are $\lfloor n/2\rfloor$ and $\lfloor (n+1)/2 \rfloor$, with a plateau iff $n$ is odd. Auxiliary results include the strict log-concavity of a row of Pascal's triangle, the two-sided estimate $(p+q)^n/(n+1) \le \max_k w_k \le (p+q)^n$, monotonicity and unit-staircase behaviour of the brackets in the parameters, a *vertex-sweep* theorem saying that every degree $d \le n$ is the unique maximiser of $k \mapsto \binom{n}{k}p^k$ for a suitable $p > 0$, the corresponding Poisson theory ($\theta = \lambda$), and a non-asymptotic cross-instance comparison showing that under the Poisson scaling $p = \lambda/n$ the binomial and Poisson upper brackets differ by at most one.

**Keywords:** log-concavity, unimodality, binomial mode, Pascal's triangle, threshold window, Poisson mode, Newton inequalities.

---

## 1. Introduction

### 1.1 The problem

Write out the binomial expansion
$$(p+q)^n = \sum_{k=0}^n \binom{n}{k}p^kq^{\,n-k}, \qquad p, q > 0,$$
and ask which of the $n+1$ summands is largest. The standard answer in the literature is a hand-wave: "about $np/(p+q)$", occasionally decorated with the remark that two adjacent terms can be equal. The question of *exactly which* index maximises, and *exactly when* the maximiser fails to be unique, is answered in scattered special cases (usually $p = q = 1$, using the symmetry $\binom{n}{k} = \binom{n}{n-k}$) but rarely in the general form that the underlying structure supports.

The reason the general form is available is that the binomial weights are **strictly log-concave**, and strict log-concavity is exactly the hypothesis that limits ties to pairs. This paper develops the theory in three layers:

1. **Abstract layer.** Strictly log-concave positive windows: unimodality, the maximiser interval, and the sharp comparison $d^+ \le d^- + 1$ with an exact criterion for equality.
2. **Mechanism layer.** Threshold windows: a structural hypothesis under which both bracketing degrees become explicit roundings of a real parameter, and their comparison becomes an integrality question.
3. **Instance layer.** Binomial weights, Poisson weights, the classical case $p=q=1$, arithmetic tie criteria, parameter dependence, and a cross-instance comparison of binomial and Poisson modes.

### 1.2 What is new and what is classical

Unimodality of log-concave sequences is classical, as is the folklore statement that the binomial mode is $\lfloor (n+1)p \rfloor$ for a probability-normalised $p$. What the present development contributes is a *clean separation of the abstract from the arithmetic*, and a sharp treatment of the boundary case:

- the identification of two distinct indices, differing by the strictness of a single inequality, whose gap is exactly the indicator of a tie;
- the theorem that this gap is at most one, with strict log-concavity used precisely and only to exclude plateaus of length three;
- the threshold-window abstraction, in which the whole computation reduces to $\lceil\theta\rceil - 1$ versus $\lfloor \theta \rfloor$; and
- the resulting *uniform* treatment of the binomial and Poisson cases, including a non-asymptotic comparison between them.

### 1.3 Notation

Throughout, $n \in \mathbb{N}$ and sequences are indexed by $k \in \{0, 1, \dots, n\}$; we call $\{0,\dots,n\}$ the *window*. For a real $x \ge 0$, $\lfloor x \rfloor$ and $\lceil x \rceil$ denote the (non-negative) floor and ceiling. Since every threshold we consider is strictly positive, $\lceil \theta \rceil \ge 1$ and the expression $\lceil \theta\rceil - 1$ is a legitimate non-negative integer.

---

## 2. Strictly log-concave windows

### 2.1 Definition

**Definition 2.1 (Strictly log-concave window).** A sequence $a : \mathbb{N} \to \mathbb{R}$ is *strictly log-concave on the window* $\{0, \dots, n\}$ if

- (positivity) $a_k > 0$ for all $k \le n$, and
- (strict Newton inequality) $a_k\, a_{k+2} < a_{k+1}^2$ for all $k$ with $k+2 \le n$.

The two hypotheses together say that the points $(k, \log a_k)$, $0 \le k \le n$, lie in strictly concave position: each interior point lies strictly above the chord joining its neighbours.

### 2.2 The ratio sequence

The single technical device behind everything is the sequence of consecutive ratios $r_k = a_{k+1}/a_k$.

**Lemma 2.2 (Ratio decrease).** If $a$ is strictly log-concave on $\{0,\dots,n\}$ and $k + 2 \le n$ then
$$\frac{a_{k+2}}{a_{k+1}} < \frac{a_{k+1}}{a_k}.$$

*Proof.* Both denominators are positive; cross-multiplying, the claim is $a_k a_{k+2} < a_{k+1}^2$, which is the hypothesis. $\square$

**Lemma 2.3 (Strict antitonicity of ratios).** If $j < k < n$ then $r_k < r_j$.

*Proof.* Induction on $k$ starting from $k = j+1$, using Lemma 2.2 at each step and transitivity. $\square$

Two immediate consequences carry the unimodality.

**Lemma 2.4 (Rise propagates backwards).** If $j < k < n$ and $a_k \le a_{k+1}$, then $a_j < a_{j+1}$.

*Proof.* The hypothesis says $r_k \ge 1$. By Lemma 2.3, $r_j > r_k \ge 1$, i.e. $a_{j+1}/a_j > 1$. $\square$

**Lemma 2.5 (Fall propagates forwards).** If $j < k < n$ and $a_{j+1} \le a_j$, then $a_{k+1} < a_k$.

*Proof.* Here $r_j \le 1$, so $r_k < r_j \le 1$. $\square$

Thus a strictly log-concave window rises, possibly ties once, and then falls — and it cannot do anything else.

### 2.3 The two bracketing degrees

**Definition 2.6.** For a sequence $a$ and a window length $n$, set
$$d^- := \min\{\,k \le n \;:\; k = n \ \text{ or } \ a_{k+1} \le a_k \,\}, \qquad d^+ := \min\{\,k \le n \;:\; k = n \ \text{ or } \ a_{k+1} < a_k \,\}.$$
We call $d^-$ the *lower bracketing degree* and $d^+$ the *upper bracketing degree*. Both are well defined (the index $k = n$ always qualifies) and satisfy $d^\pm \le n$.

Unwinding the minimality:

- for every $j < d^-$ we have $a_j < a_{j+1}$ (strict rise strictly below the lower bracket);
- for every $j < d^+$ we have $a_j \le a_{j+1}$ (no fall strictly below the upper bracket);
- if $d^- < n$ then $a_{d^-+1} \le a_{d^-}$;
- if $d^+ < n$ then $a_{d^++1} < a_{d^+}$.

**Lemma 2.7.** $d^- \le d^+$, for any positive sequence whatsoever (log-concavity is not needed).

*Proof.* Suppose $d^+ < d^-$. Then $d^+ < d^- \le n$, so $d^+ < n$ and hence $a_{d^++1} < a_{d^+}$. But $d^+ < d^-$ also gives $a_{d^+} < a_{d^++1}$. Contradiction. $\square$

We also record the recognition principle used to compute the brackets in concrete cases.

**Lemma 2.8 (Characterisation).** Let $d \le n$. If ($d = n$ or $a_{d+1} \le a_d$) and $a_j < a_{j+1}$ for all $j < d$, then $d^- = d$. Likewise, if ($d = n$ or $a_{d+1} < a_d$) and $a_j \le a_{j+1}$ for all $j < d$, then $d^+ = d$.

*Proof.* Immediate from minimality of the defining sets. $\square$

### 2.4 The explicit comparison

We come to the main abstract theorem.

**Theorem 2.9 (Comparison of the bracketing degrees).** Let $a$ be strictly log-concave on $\{0,\dots,n\}$. Then:

1. $d^+ \le d^- + 1$;
2. $d^+ = d^- + 1 \iff \big(d^- < n \text{ and } a_{d^-} = a_{d^-+1}\big)$;
3. consequently $d^+ - d^- \in \{0, 1\}$, and $d^- = d^+$ if and only if there is no tie at the top.

*Proof.* (1) Suppose $d^+ > d^- + 1$; write $d = d^-$. Then $d + 1 < d^+ \le n$. Since $d < d^+$ and $d+1 < d^+$, no fall occurs at $d$ or $d+1$: $a_d \le a_{d+1}$ and $a_{d+1} \le a_{d+2}$. On the other hand $d < n$, so $a_{d+1} \le a_d$ by the definition of $d^-$. Combining, $a_d = a_{d+1}$ and $a_{d+1}\le a_{d+2}$, whence
$$a_d\, a_{d+2} \;\ge\; a_d\, a_{d+1} \;=\; a_{d+1}^2,$$
contradicting the strict Newton inequality at $d$ (legitimate because $d + 2 \le n$).

(2) ($\Rightarrow$) If $d^+ = d^- + 1$ then $d^- + 1 \le n$, so $d^- < n$ and $a_{d^-+1}\le a_{d^-}$; and $d^- < d^+$ gives $a_{d^-} \le a_{d^-+1}$. Hence equality. ($\Leftarrow$) If $d^- < n$ and $a_{d^-} = a_{d^-+1}$ then $d^+ \ne d^-$, since a strict fall at $d^+$ would contradict the equality; combined with $d^- \le d^+ \le d^- + 1$ this forces $d^+ = d^- + 1$.

(3) is (1) plus Lemma 2.7 plus (2). $\square$

Part (1) is where strict log-concavity is genuinely needed, and it is needed for exactly one purpose: to exclude a plateau of length three. This is the precise sense in which strictness of the Newton inequality is the hypothesis that "makes ties rare".

### 2.5 Strict unimodality and the maximiser interval

**Proposition 2.10 (Strict increase below).** If $j < k \le d^-$ then $a_j < a_k$.

*Proof.* Induction on $k$, each step being a strict rise below $d^-$. $\square$

**Proposition 2.11 (Strict decrease above).** Let $a$ be strictly log-concave. If $d^+ \le j < k \le n$ then $a_k < a_j$.

*Proof.* First, a single step: for $d^+ \le j < n$ we claim $a_{j+1} < a_j$. If $j = d^+$ this is the definition (note $d^+ < n$ here). If $j > d^+$ then $d^+ < n$, so $a_{d^++1} < a_{d^+}$, and Lemma 2.5 applied with the pair $(d^+, j)$ gives $a_{j+1} < a_j$. Induction on $k$ then gives the general statement. $\square$

**Proposition 2.12 (The peak value).** $a_{d^-} = a_{d^+}$.

*Proof.* If $d^- = d^+$ there is nothing to prove. Otherwise $d^+ = d^- + 1$, and Theorem 2.9(2) gives $a_{d^-} = a_{d^-+1} = a_{d^+}$. $\square$

**Theorem 2.13 (Strict unimodality; maximiser set).** Let $a$ be strictly log-concave on $\{0,\dots,n\}$ and let $k \le n$. Then

1. $a_k \le a_{d^-}$;
2. if $k < d^-$ or $k > d^+$, the inequality is strict;
3. consequently $a_k = a_{d^-} \iff d^- \le k \le d^+$.

*Proof.* If $k < d^-$, Proposition 2.10 gives $a_k < a_{d^-}$. If $k > d^+$, Proposition 2.11 gives $a_k < a_{d^+} = a_{d^-}$ by Proposition 2.12. Otherwise $d^- \le k \le d^+ \le d^- + 1$, so $k \in \{d^-, d^+\}$ and $a_k = a_{d^-}$ by Proposition 2.12. This proves (1), (2) and both directions of (3). $\square$

So the maximiser set is *exactly* the integer interval $[d^-, d^+]$, of cardinality $1$ or $2$.

---

## 3. Threshold windows: making the brackets explicit

Theorem 2.13 localises the maximum but says nothing about *computing* $d^\pm$. The following hypothesis, satisfied by every classical family we know of, does precisely that.

**Definition 3.1 (Threshold window).** A sequence $a$ is a *threshold window on $\{0,\dots,n\}$ with threshold $\theta \in \mathbb{R}$* if

- $0 < \theta < n+1$;
- (strict criterion) for all $k < n$: $\;a_k < a_{k+1} \iff k+1 < \theta$;
- (weak criterion) for all $k < n$: $\;a_k \le a_{k+1} \iff k+1 \le \theta$.

The two criteria are the same computation performed with $<$ and with $\le$; keeping both is essential, because the whole tie phenomenon lives in the difference between them.

We shall use the elementary rounding fact:

**Lemma 3.2.** For $\theta \ge 0$: $\ \lfloor\theta\rfloor = \lceil\theta\rceil \iff \theta \in \mathbb{Z}$.

*Proof.* If the two agree, then $\lfloor\theta\rfloor \le \theta \le \lceil\theta\rceil = \lfloor\theta\rfloor$ forces $\theta = \lfloor\theta\rfloor$. Conversely both roundings fix an integer. $\square$

**Theorem 3.3 (Explicit brackets).** Let $a$ be a threshold window with threshold $\theta$. Then
$$d^- = \lceil\theta\rceil - 1, \qquad d^+ = \lfloor\theta\rfloor.$$

*Proof.* *Lower bracket.* Put $d = \lceil\theta\rceil - 1$; since $\theta > 0$ we have $\lceil\theta\rceil \ge 1$, and since $\theta < n+1$ we have $\lceil\theta\rceil \le n+1$, so $0 \le d \le n$. We verify the two conditions of Lemma 2.8.
For $j < d$: then $j + 1 < \lceil\theta\rceil$, hence $j+1 < \theta$ (if $\theta \le j+1$ then $\lceil\theta\rceil \le j+1$), so the strict criterion gives $a_j < a_{j+1}$.
At $d$: if $d = n$ we are done; otherwise $d < n$ and $d + 1 = \lceil\theta\rceil \ge \theta$, so the strict criterion fails at $d$, i.e. $a_{d+1}\le a_d$.
Hence $d^- = d$.

*Upper bracket.* Put $d = \lfloor\theta\rfloor$; from $0 < \theta < n+1$ we get $d \le n$. For $j < d$: then $j+1 \le \lfloor\theta\rfloor \le \theta$, so the weak criterion gives $a_j \le a_{j+1}$. At $d$: if $d = n$ we are done; otherwise $d+1 = \lfloor\theta\rfloor + 1 > \theta$, so the weak criterion fails, i.e. $a_{d+1} < a_d$. Lemma 2.8 gives $d^+ = d$. $\square$

**Theorem 3.4 (Explicit comparison for threshold windows).** For a threshold window with threshold $\theta$,
$$d^+ = d^- + 1 \iff \theta \in \mathbb{Z}.$$
Equivalently, when $\theta \notin \mathbb{Z}$ the maximiser is unique and equals $\lfloor\theta\rfloor$.

*Proof.* By Theorem 3.3 the claim is $\lfloor\theta\rfloor = \lceil\theta\rceil - 1 + 1 = \lceil\theta\rceil$, which by Lemma 3.2 is integrality of $\theta$. Conversely, when $\theta \notin \mathbb{Z}$ we have $\lfloor\theta\rfloor \ne \lceil\theta\rceil$ and $\lceil\theta\rceil \le \lfloor\theta\rfloor + 1$, forcing $\lceil\theta\rceil - 1 = \lfloor\theta\rfloor$, i.e. $d^- = d^+$. $\square$

This is the conceptual centre of the paper: **the comparison of the two bracketing degrees is exactly the integrality of the threshold.**

Two further abstract statements describe how the summit moves.

**Theorem 3.5 (Monotonicity in the threshold).** If $a$ is a threshold window on $\{0,\dots,n\}$ with threshold $\theta$, and $a'$ is a threshold window on $\{0,\dots,n'\}$ with threshold $\theta' \ge \theta$, then
$$d^-(a) \le d^-(a') \quad\text{and}\quad d^+(a) \le d^+(a').$$

*Proof.* Floor and ceiling are monotone; subtract $1$ from both ceilings. $\square$

**Theorem 3.6 (Unit staircase).** Under the same hypotheses, if $\theta' < \theta + 1$ then
$$d^-(a') \le d^-(a) + 1 \quad\text{and}\quad d^+(a') \le d^+(a) + 1.$$

*Proof.* From $\theta' < \theta + 1 \le \lceil\theta\rceil + 1$ we get $\lceil\theta'\rceil \le \lceil\theta\rceil + 1$. From $\theta' < \theta + 1 < \lfloor\theta\rfloor + 2$ we get $\lfloor\theta'\rfloor \le \lfloor\theta\rfloor + 1$. $\square$

Together: a threshold that increases by less than one unit moves each bracketing degree by exactly $0$ or $1$.

---

## 4. The binomial instance

### 4.1 Strict log-concavity of a Pascal row

**Theorem 4.1.** For $k + 2 \le n$,
$$\binom{n}{k}\binom{n}{k+2} < \binom{n}{k+1}^2 .$$

*Proof.* Write $n = k + 2 + m$ with $m \ge 0$. The elementary identity $\binom{n}{j+1}(j+1) = \binom{n}{j}(n-j)$ gives
$$\binom{n}{k+1}(k+1) = \binom{n}{k}(m+2), \qquad \binom{n}{k+2}(k+2) = \binom{n}{k+1}(m+1).$$
Multiplying the two and rearranging,
$$\binom{n}{k+1}^2 (k+1)(m+1) = \binom{n}{k}\binom{n}{k+2}\,(m+2)(k+2).$$
All binomial coefficients involved are positive since $k+2 \le n$. Since $(m+2)(k+2) > (m+1)(k+1)$, comparison of the two sides forces $\binom{n}{k}\binom{n}{k+2} < \binom{n}{k+1}^2$: indeed if we had $\binom{n}{k}\binom{n}{k+2} \ge \binom{n}{k+1}^2$, the right-hand side would strictly exceed the left, a contradiction. $\square$

Note that this proof uses no factorial manipulation beyond the single absorption identity, and yields the strict inequality directly.

### 4.2 The weights and the mode parameter

**Definition 4.2 (Binomial weights).** For $n \in \mathbb{N}$ and $p, q > 0$, set
$$w_k := \binom{n}{k}p^k q^{\,n-k}, \qquad 0 \le k \le n,$$
so that $\sum_{k=0}^n w_k = (p+q)^n$.

**Definition 4.3 (Mode parameter).** $\displaystyle \theta = \theta(n,p,q) := \frac{(n+1)p}{p+q}.$

**Lemma 4.4.** For $p, q > 0$ one has $0 < \theta < n+1$, and $w_k > 0$ for all $k \le n$.

*Proof.* Positivity is clear. For the upper bound, $\theta < n+1 \iff (n+1)p < (n+1)(p+q) \iff 0 < (n+1)q$. $\square$

**Theorem 4.5.** The binomial weights are strictly log-concave on $\{0,\dots,n\}$.

*Proof.* Positivity is Lemma 4.4. For $k+2 \le n$, write $n = k+2+m$; then
$$w_k\,w_{k+2} = \binom nk \binom n{k+2} \; p^{2k+2}q^{2m+2}, \qquad w_{k+1}^2 = \binom n{k+1}^2 p^{2k+2}q^{2m+2},$$
and the claim is Theorem 4.1 multiplied by the positive number $p^{2k+2}q^{2m+2}$. $\square$

### 4.3 The rise criterion

**Theorem 4.6.** For $k < n$,
$$w_k < w_{k+1} \iff k+1 < \theta, \qquad\qquad w_k \le w_{k+1} \iff k+1 \le \theta.$$

*Proof.* Write $n = k+1+m$. Factoring out $p^kq^m > 0$,
$$w_k = \Big(\binom nk q\Big)p^kq^m, \qquad w_{k+1} = \Big(\binom n{k+1} p\Big)p^kq^m,$$
so the comparison of $w_k$ and $w_{k+1}$ is the comparison of $\binom nk q$ with $\binom n{k+1}p$. The absorption identity gives $\binom{n}{k+1}(k+1) = \binom nk (m+1)$. Multiplying the inequality $\binom nk q \lessgtr \binom n{k+1}p$ by the positive number $k+1$ and substituting turns it into
$$\binom nk\, q\,(k+1) \;\lessgtr\; \binom nk\,(m+1)\,p,$$
i.e., after cancelling $\binom nk > 0$, into $q(k+1) \lessgtr (m+1)p$. Since $n = k+1+m$, we have $m + 1 = n - k$, so this is $q(k+1) \lessgtr (n-k)p$, i.e.
$$(k+1)(p+q) \lessgtr (n+1)p,$$
i.e. $k+1 \lessgtr \theta$. The same chain of equivalences holds verbatim with $\le$ in place of $<$. $\square$

**Corollary 4.7.** For $p, q > 0$ the binomial weights form a threshold window on $\{0,\dots,n\}$ with threshold $\theta = (n+1)p/(p+q)$.

*Proof.* Lemma 4.4 and Theorem 4.6. $\square$

### 4.4 The two bracketing degrees of the binomial weights

Feeding Corollary 4.7 into Theorems 3.3, 3.4 and 2.13 yields the main results of this section.

**Theorem 4.8 (Explicit binomial brackets).** For $p, q > 0$,
$$d^- = \left\lceil \frac{(n+1)p}{p+q}\right\rceil - 1, \qquad d^+ = \left\lfloor \frac{(n+1)p}{p+q}\right\rfloor .$$

**Theorem 4.9 (Maximiser set).** For $k \le n$,
$$w_k = \max_{0\le j\le n} w_j \iff \lceil\theta\rceil - 1 \le k \le \lfloor\theta\rfloor .$$
In particular $w_k \le w_{\lceil\theta\rceil - 1}$ for every $k \le n$.

**Theorem 4.10 (The explicit comparison, binomial form).** The two bracketing degrees of the binomial weights satisfy $d^+ = d^- + 1$ if and only if $\theta = (n+1)p/(p+q)$ is an integer; otherwise $d^- = d^+ = \lfloor \theta\rfloor$ and the maximiser is unique.

These four statements answer, completely, the question posed in the introduction. The mode of the binomial expansion is $\lfloor (n+1)p/(p+q)\rfloor$, and it is unique unless $(n+1)p/(p+q)$ is a whole number, in which case exactly one further index — one below — ties with it.

### 4.5 Arithmetic corollaries

**Theorem 4.11 (Integer weights).** Let $P, Q$ be positive integers and take $p = P$, $q = Q$. Then
$$d^+ = d^- + 1 \iff (P+Q) \mid (n+1)P .$$

*Proof.* By Theorem 4.10 the left side is the integrality of $\theta = (n+1)P/(P+Q)$. If $\theta = m \in \mathbb{N}$ then $m(P+Q) = (n+1)P$, so $(P+Q) \mid (n+1)P$; conversely if $(n+1)P = (P+Q)c$ then $\theta = c \in \mathbb{N}$. $\square$

**Theorem 4.12 (The classical row of Pascal's triangle).** For $p = q = 1$ the weights are the binomial coefficients themselves, $w_k = \binom nk$, the mode parameter is $\theta = (n+1)/2$, and
$$d^- = \left\lfloor \frac n2 \right\rfloor, \qquad d^+ = \left\lfloor \frac{n+1}{2} \right\rfloor = \left\lceil \frac n2\right\rceil .$$
Hence $\binom{n}{\cdot}$ has a two-term plateau at the top if and only if $n$ is odd.

*Proof.* $\theta = (n+1)/2$. If $n = 2t$ then $\theta = t + \tfrac12$, so $\lceil\theta\rceil - 1 = t = \lfloor\theta\rfloor$: the maximiser $\binom{2t}{t}$ is unique. If $n = 2t+1$ then $\theta = t+1 \in \mathbb{Z}$, so $\lceil\theta\rceil - 1 = t$ and $\lfloor\theta\rfloor = t+1$: the maximisers are $\binom{2t+1}{t} = \binom{2t+1}{t+1}$. In both cases $\lceil\theta\rceil - 1 = \lfloor n/2\rfloor$ and $\lfloor\theta\rfloor = \lfloor (n+1)/2\rfloor$, and the gap is $1$ exactly for odd $n$, i.e. by Theorem 4.10 exactly when $\theta \in \mathbb{Z}$. $\square$

It is worth stressing what has happened here. The classical fact that odd rows of Pascal's triangle have twin central entries is usually presented as a consequence of the symmetry $\binom{n}{k} = \binom{n}{n-k}$. In the present framework it is instead an instance of a general integrality criterion, and the symmetry plays no role — which is why the criterion survives the asymmetric perturbation to arbitrary $p, q > 0$.

### 4.6 The size of the largest term

**Theorem 4.13 (Two-sided bracket for the peak value).** For $p, q > 0$,
$$\frac{(p+q)^n}{n+1} \;\le\; w_{d^-} \;\le\; (p+q)^n .$$

*Proof.* By the binomial theorem $\sum_{k=0}^n w_k = (p+q)^n$. Every summand is positive, so the sum dominates the single term $w_{d^-}$, giving the upper bound. Every summand is at most $w_{d^-}$ by Theorem 4.9, so $(p+q)^n \le (n+1)\,w_{d^-}$, giving the lower bound. $\square$

Both inequalities are sharp in the appropriate regimes: the upper bound is asymptotically attained when $p/q \to \infty$ (all mass in the last term), the lower bound is tight only up to constants but already fixes the exponential order, $\log w_{d^-} = n\log(p+q) + O(\log n)$. It is exactly this crude sandwich, and no finer information, that underpins the standard entropy-counting estimates for binomial sums.

### 4.7 Dependence on the parameters

**Lemma 4.14.** For fixed $q > 0$, the mode parameter $\theta(n,p,q)$ is non-decreasing in $p$.

*Proof.* $\theta = (n+1)\frac{p}{p+q}$ and $p \mapsto p/(p+q) = 1 - q/(p+q)$ is increasing for $p > 0$ when $q > 0$. $\square$

**Theorem 4.15 (Monotone mode in the success weight).** If $0 < p_1 \le p_2$ and $q > 0$, then both bracketing degrees of $w^{(p_1)}$ are $\le$ the corresponding degrees of $w^{(p_2)}$.

*Proof.* Lemma 4.14 and Theorem 3.5. $\square$

**Lemma 4.16.** $\theta(n+1,p,q) = \theta(n,p,q) + \dfrac{p}{p+q}$, and $0 < \dfrac{p}{p+q} < 1$.

**Theorem 4.17 (Unit staircase in $n$).** For $p, q > 0$,
$$d^+(n) \;\le\; d^+(n+1) \;\le\; d^+(n) + 1 .$$

*Proof.* Lemma 4.16 places the two thresholds within distance less than $1$ and in increasing order; apply Theorems 3.5 and 3.6. $\square$

So the binomial mode, as a function of the number of trials, is a monotone staircase with unit rises: adding a trial can never move the peak backwards, and never moves it forward by more than one degree.

### 4.8 Every degree is a vertex

Strict log-concavity says the points $(k, \log\binom nk)$ are in strictly concave position; equivalently, each one is a vertex of the upper convex hull. Tilting by a linear function should therefore expose each vertex in turn. The threshold formalism makes this precise and constructive.

**Theorem 4.18 (Vertex sweep).** Let $d \le n$. Then there exists $p > 0$ such that $d$ is the *unique* maximiser of $k \mapsto \binom nk p^k$ on $\{0,\dots,n\}$; explicitly one may take
$$\theta = d + \tfrac12, \qquad p = \frac{\theta}{\,n+1-\theta\,} = \frac{2d+1}{2n - 2d + 1}.$$

*Proof.* With $q = 1$ the mode parameter is $\theta(n,p,1) = (n+1)p/(p+1)$; solving $(n+1)p/(p+1) = \theta$ for $\theta \in (0, n+1)$ gives $p = \theta/(n+1-\theta) > 0$. For $\theta = d + \tfrac12$ we get $\lceil\theta\rceil - 1 = d$ and $\lfloor\theta\rfloor = d$, so by Theorem 4.8 both bracketing degrees equal $d$; by Theorem 2.13(2), every $k \ne d$ with $k \le n$ satisfies $w_k < w_d$ strictly. $\square$

As $\theta$ sweeps continuously through $(0, n+1)$, the maximiser sweeps through $0, 1, \dots, n$ in order, remaining constant on each interval between consecutive integers and producing a two-term tie exactly at the integers. This is the combinatorial shadow of the fact that the upper convex hull of a strictly log-concave point set has all points as vertices, and it is the reason exponential tilting is such an effective tool for isolating a prescribed term of a binomial sum.

---

## 5. The Poisson instance and a cross-instance comparison

### 5.1 Poisson weights

**Definition 5.1.** For $\lambda > 0$ set $u_k := \dfrac{\lambda^k}{k!}$, the terms of the exponential series for $e^\lambda$.

**Theorem 5.2.** For every $n$, the sequence $u$ is strictly log-concave on $\{0,\dots,n\}$.

*Proof.* Positivity is clear. The Newton inequality $u_k u_{k+2} < u_{k+1}^2$ is, after clearing $\lambda^{2k+2} > 0$, equivalent to $((k+1)!)^2 < k!\,(k+2)!$. Writing $(k+1)! = (k+1)k!$ and $(k+2)! = (k+2)(k+1)k!$, this reads $(k+1)^2 (k!)^2 < (k+2)(k+1)(k!)^2$, i.e. $k+1 < k+2$. $\square$

**Theorem 5.3 (Poisson rise criterion).** For every $k$,
$$u_k < u_{k+1} \iff k+1 < \lambda, \qquad u_k \le u_{k+1} \iff k+1 \le \lambda .$$

*Proof.* $u_{k+1}/u_k = \lambda/(k+1)$. $\square$

**Corollary 5.4.** If $0 < \lambda < n+1$, the Poisson weights form a threshold window on $\{0,\dots,n\}$ with threshold exactly $\lambda$; hence
$$d^- = \lceil\lambda\rceil - 1, \qquad d^+ = \lfloor\lambda\rfloor,$$
the maximiser set is $\{k : \lceil\lambda\rceil - 1 \le k \le \lfloor\lambda\rfloor\}$, and the top is a two-term plateau if and only if $\lambda$ is a positive integer.

The Poisson family is the purest illustration of the mechanism: here the threshold *is* the parameter, and the classical statement "the Poisson mode is $\lfloor\lambda\rfloor$, with a tie at $\lambda - 1$ for integral $\lambda$" is Theorem 3.4 verbatim.

### 5.2 Binomial versus Poisson, without limits

The Poisson distribution is classically justified as a limit of binomials with $p = \lambda/n$. Because both families are threshold windows, their modes can be compared *directly and non-asymptotically*.

**Lemma 5.5.** Let $0 < \lambda < n$ and set $p = \lambda/n$, $q = 1 - \lambda/n$ (both positive, with $p + q = 1$). Then
$$\theta(n, p, q) = (n+1)\frac{\lambda}{n} = \lambda + \frac{\lambda}{n}.$$

**Theorem 5.6 (Cross-instance bracket comparison).** With $\lambda$, $p$, $q$ as in Lemma 5.5, the upper bracketing degrees satisfy
$$d^+_{\mathrm{Poisson}}(\lambda) \;\le\; d^+_{\mathrm{binomial}}(n, p, q) \;\le\; d^+_{\mathrm{Poisson}}(\lambda) + 1 .$$

*Proof.* Both windows are threshold windows on $\{0,\dots,n\}$: the Poisson one with threshold $\lambda < n < n+1$, the binomial one with threshold $\lambda + \lambda/n$ by Lemma 5.5. Since $\lambda/n > 0$, the binomial threshold is larger, and Theorem 3.5 gives the left inequality. Since $\lambda/n < 1$, the binomial threshold is smaller than $\lambda + 1$, and Theorem 3.6 gives the right inequality. $\square$

The same argument applies verbatim to the lower brackets. The point is methodological: a statement usually proved by an approximation argument (Poisson limit of binomials) here becomes a comparison of two real numbers followed by monotonicity of rounding — with an exact, finite-$n$ error bound of one index unit.

---

## 6. Algorithms

The theory is constructive, and the resulting algorithms are trivial in complexity, which is itself the point: locating the mode requires no search.

**Algorithm A (Mode location).** Given $n, p, q$ with $p, q > 0$, compute $\theta = (n+1)p/(p+q)$ and return the pair $(\lceil\theta\rceil - 1, \lfloor\theta\rfloor)$ together with the boolean $\theta \in \mathbb{Z}$. Cost: $O(1)$ arithmetic operations. Contrast with the naive alternative, which evaluates all $n+1$ weights and takes a maximum at cost $\Theta(n)$ (and with a real risk of overflow or catastrophic cancellation for large $n$).

**Algorithm B (Exact rational tie test).** For rational $p = P_1/P_2$, $q = Q_1/Q_2$, integrality of $\theta$ is a divisibility question in the integers and can be decided exactly. For integer weights $P, Q$ it is precisely the test $(P+Q) \mid (n+1)P$; this avoids the floating-point hazard of comparing $\theta$ to its rounding.

**Algorithm C (Peak value, numerically stable).** To evaluate the maximal weight itself, accumulate ratios rather than factorials: starting from $\log w_0 = n\log q$, add $\log\frac{n-k}{k+1} + \log\frac pq$ successively, or work with the recurrence $w_{k+1} = w_k\cdot\frac{n-k}{k+1}\cdot\frac pq$ in logarithms. Cost $O(d^+)$; and the result may be checked against the theoretical bracket $\big[(p+q)^n/(n+1),\;(p+q)^n\big]$.

**Algorithm D (Vertex sweep).** To exhibit each degree $d$ as the unique mode, set $p = (2d+1)/(2n-2d+1)$ and $q = 1$. Cost $O(1)$ per degree; sweeping all degrees costs $O(n)$, and each step can be validated by verifying $\lceil\theta\rceil - 1 = \lfloor\theta\rfloor = d$.

---

## 7. Applications and discussion

**Exact combinatorial identities.** The largest entry of row $n$ of Pascal's triangle is $\binom{n}{\lfloor n/2\rfloor}$, and it is unique iff $n$ is even. More generally, for weighted rows $\binom nk P^kQ^{n-k}$ with integer $P, Q$, the arithmetic criterion $(P+Q)\mid (n+1)P$ decides uniqueness. For instance with $P = 1, Q = 2$ (weights $\binom nk 2^{n-k}$), the tie occurs exactly when $3 \mid n+1$: for $n = 5$ the mode parameter is $2$, and indeed $\binom 51 2^4 = 80 = \binom 52 2^3$.

**Estimates for sums.** Theorem 4.13 says the largest term captures at least a $1/(n+1)$ fraction of the total mass. Combined with Theorem 4.8 this yields immediate two-sided bounds for central binomial coefficients: taking $p=q=1$, $\;2^n/(n+1) \le \binom{n}{\lfloor n/2\rfloor}\le 2^n$. Such bounds, crude as they are, are the standard inputs to entropy and large-deviation arguments, where only exponential accuracy matters.

**Statistics.** For a binomial random variable with success probability $\pi = p/(p+q)$, the mode is $\lfloor (n+1)\pi \rfloor$, with a two-point mode exactly when $(n+1)\pi$ is an integer. The often-quoted approximation $n\pi$ is off by up to one index; the exact statement costs nothing more. The same applies to the Poisson mode $\lfloor\lambda\rfloor$ and to maximum-a-posteriori estimation in these families.

**Convex geometry and tilting.** Theorem 4.18 identifies the sweeping of the maximiser under exponential tilting with the enumeration of vertices of the upper convex hull of $\{(k,\log a_k)\}$. This is the finite, elementary shadow of the Legendre-duality picture behind exponential families and large-deviation rate functions: the tilt parameter selects the vertex, and ties occur exactly at the finitely many tilts where an edge of the hull becomes horizontal.

**On the role of strictness.** It is instructive to see where each hypothesis is used. Positivity underwrites the ratio calculus. The *strict* Newton inequality is used exactly once, in Theorem 2.9(1), to exclude a three-term plateau. If the Newton inequality is only weak ($a_ka_{k+2}\le a_{k+1}^2$), the sequence is still unimodal and the maximiser set is still an interval, but that interval may be arbitrarily long — the constant sequence being the extreme case. The gap $d^+ - d^-$ then measures plateau length rather than being confined to $\{0,1\}$. Similarly, keeping *both* the strict and the weak rise criteria in Definition 3.1 is what allows the two bracketing degrees to be computed separately; a formalism that records only one of them cannot see the tie.

**Sharpness.** Every bound above is attained. $d^+ - d^- = 1$ occurs for every odd $n$ in the classical case; $d^+ = d^-$ occurs for every even $n$. In Theorem 4.17 both the increment $0$ and the increment $1$ occur infinitely often for any fixed $p, q$ (the increment $1$ with asymptotic frequency $p/(p+q)$, the increment $0$ with frequency $q/(p+q)$). In Theorem 5.6 both endpoints occur: the binomial and Poisson modes agree when $\lfloor \lambda + \lambda/n\rfloor = \lfloor\lambda\rfloor$ and differ by one when the extra $\lambda/n$ pushes the threshold past an integer.

---

## 8. Future directions

The abstraction developed here — a rise criterion crossing a single real threshold — was never tied to linearity in $k$, and this suggests the natural next steps.

**Quadratic criteria and the hypergeometric mode.** Suppose the rise criterion of a positive window takes the form $a_k < a_{k+1} \iff g(k) > 0$ where $g$ is a quadratic with a single sign change in $[0, n)$. One expects the two bracketing degrees to be $\lceil r\rceil - 1$ and $\lfloor r\rfloor$, where $r$ is the unique root of $g$ in that range, with a tie iff $r \in \mathbb{Z}$. Nothing in the proofs of Theorems 3.3 and 3.4 used linearity — only that the criterion changes sign once. Specialised to the hypergeometric weights $\binom{m}{k}\binom{N-m}{n-k}$, whose ratio is a quotient of two linear factors and whose crossing point is therefore the root of a quadratic, this predicts the classical hypergeometric mode $\lfloor (n+1)(m+1)/(N+2)\rfloor$. Restating the threshold notion with an abstract crossing parameter, and computing that parameter per instance, appears to be a small structural change with a broad payoff.

**Plateau rigidity for log-concave integer sequences.** A tie at the top means $\theta \in \mathbb{Z}$, an exact rational coincidence. One may conjecture that such coincidences are expensive: a strictly log-concave positive *integer* sequence on $\{0,\dots,n\}$ whose two bracketing degrees differ must have a large peak value — of order $2^{\lfloor n/2\rfloor}$ divided by an explicit polynomial factor. Contrapositively, a "small" strictly log-concave integer sequence would have a unique maximiser. The mechanism to exploit is that an exact tie forces exact ratio relations near the peak, and strict log-concavity then propagates quantitative lower bounds on the ratios away from the peak.

**Higher-order brackets.** Between $d^-$ and $d^+$ the sequence is flat; just outside, it decreases. One could ask for explicit brackets for the *second* largest term, or more generally for the level sets $\{k : a_k \ge \alpha \max_j a_j\}$, in terms of the same threshold data. For threshold windows with a differentiable underlying criterion this should reduce to solving $\theta$-shifted inequalities, giving effective width estimates for the bell curve without recourse to Stirling's formula.

**Beyond one dimension.** Multivariate log-concavity (for example for multinomial weights) admits a similar bracketing: the maximiser of $\binom{n}{k_1,\dots,k_r}\prod p_i^{k_i}$ should be trapped in a lattice cell determined by the real point $(n+1)p_i/\sum_j p_j$, with ties governed by which coordinates of that point are integral. The one-dimensional theory above is the $r = 2$ case, and identifying the correct multivariate analogue of "the gap is at most one" is the natural test of the framework.

---

## 9. Summary of results

- **Comparison of bracketing degrees.** For a strictly log-concave positive window, $d^- \le d^+ \le d^- + 1$, and $d^+ = d^- + 1$ exactly when $a_{d^-} = a_{d^-+1}$ (a two-term plateau).
- **Maximiser interval.** The set of maximisers is exactly $\{d^-,\dots,d^+\}$; strictly below $d^-$ the sequence strictly increases, strictly above $d^+$ it strictly decreases.
- **Threshold windows.** If the rise criterion is $k+1 < \theta$ (weakly, $k+1 \le \theta$) then $d^- = \lceil\theta\rceil - 1$ and $d^+ = \lfloor\theta\rfloor$; the gap is $1$ iff $\theta \in \mathbb{Z}$; both degrees are monotone in $\theta$ and move by at most one under a sub-unit shift of $\theta$.
- **Pascal rows.** $\binom nk \binom n{k+2} < \binom n{k+1}^2$ for $k+2 \le n$.
- **Binomial weights.** $\theta = (n+1)p/(p+q)$; $d^- = \lceil\theta\rceil - 1$, $d^+ = \lfloor\theta\rfloor$; tie iff $\theta \in \mathbb{Z}$; for integer weights iff $(P+Q)\mid (n+1)P$; for $p=q=1$, $d^- = \lfloor n/2\rfloor$, $d^+ = \lfloor (n+1)/2\rfloor$, tie iff $n$ odd.
- **Peak value.** $(p+q)^n/(n+1) \le \max_k w_k \le (p+q)^n$.
- **Parameter dependence.** The brackets are non-decreasing in $p$ and form a unit staircase in $n$.
- **Vertex sweep.** Every degree $d\le n$ is the unique maximiser of $k \mapsto \binom nk p^k$ for $p = (2d+1)/(2n-2d+1)$.
- **Poisson.** $\theta = \lambda$; $d^- = \lceil\lambda\rceil - 1$, $d^+ = \lfloor\lambda\rfloor$; tie iff $\lambda \in \mathbb{Z}$.
- **Cross-instance comparison.** Under the scaling $p = \lambda/n$, $q = 1 - \lambda/n$, the binomial upper bracket lies between the Poisson upper bracket and one more than it.
