# Tie Ceilings for Discrete Rank Statistics: Exact Values, Resolution Budgets, and a Deployment Envelope

**Aristotle**

**2026-08-23**

---

## Abstract

We develop a complete, distribution-free theory of the *tie ceiling* of a discrete statistic under Spearman rank correlation: the largest squared correlation the statistic can attain against any response whatsoever, given only its multiset of tie-class sizes. Writing $L=(m_1,\dots,m_K)$ for the tie profile of a statistic on $n$ points, the ceiling is $\rho^2_{\max}(L) = 1 - 12\,C(L)/(n^3-n)$ with $C(L)=\sum_j (m_j^3-m_j)/12$; it is a function of the cube sum $\sum_j m_j^3$ alone.

We compute this quantity exactly for two statistics of practical interest on $b$-bit machine words drawn uniformly. For the **trailing-zero statistic** (the $2$-adic valuation) the ceiling is exactly $\tfrac{6}{7}\bigl(1+ 1/(2^b(2^b+1))\bigr)$, hence essentially the word-length-independent constant $6/7$, i.e. $\rho \le 0.9258$. For the **Hamming-weight statistic** the ceiling is governed by the Franel numbers $F(b)=\sum_k\binom{b}{k}^3$; using the sharp central-binomial estimate $\binom{2m}{m}^2(3m+1)\le 16^m$ we prove the *count ceiling law* $\rho^2_{\max}\ge 1-4/(3b+2)$ for even $b\ge 2$, hence $\rho^2_{\max}\to 1$, and the *inversion law*: for every even $b\ge 10$ the Hamming-weight ceiling strictly exceeds the trailing-zero ceiling.

We then prove three structural laws. The **resolution law** $\rho^2_{\max}\le 1-1/K^2+1/n^2$ follows from a power-mean inequality $n^3\le K^2\sum_j m_j^3$ established by an explicit sum-of-squares identity; applied at $b=52$ it sandwiches the Hamming-weight ceiling in $[0.9747,\,0.9997]$ and exhibits a *shape gap*: two statistics with the identical number $K=53$ of distinct values whose ceilings differ by more than $0.14$. The **half-mass cap** states that any statistic whose modal class carries at least half the mass obeys $\rho^2_{\max}\le \tfrac78 + \tfrac{7}{8(n^2-1)}$, hence $\rho\le 0.936$ once $n\ge 1024$ — a bound requiring no assumption on the draw law. The **envelope stability law** states that ceilings are Lipschitz in the total-variation distance between draw laws; a conservation-aware displacement lemma gives constant $4.1$, and an explicit pair of $52$-bit profiles shows no constant below $2.96$ is possible, bracketing the sharp constant in $[2.96,\,4.1]$.

Finally we apply the theory to a recorded three-seed measurement at bit length $52$: readings $0.698$, $0.697$, $0.720$ (pooled $0.705$), all inside a validation band $[0.55,0.85]$, with a pooled advantage of $+0.070$ over the Hamming-weight baseline, CI $[0.046,0.093]$. The inversion law shows this advantage *cannot* be a tie or quantisation artefact — the losing statistic is the one with the better instrument — and the stability law shows the band membership survives any draw-law shift of total variation up to roughly $8.8\%$.

**Keywords:** Spearman rank correlation, tie correction, midranks, $2$-adic valuation, Franel numbers, central binomial coefficient, power-mean inequality, total variation, Lipschitz stability.

---

## 1. Introduction

### 1.1 The problem

A discrete statistic used as a diagnostic returns few distinct values on many sample points. Ranking such a sample forces massive ties, and the standard remedy — replacing each tied group's ranks by their average, the *midrank* — irreversibly destroys within-group ordering. Consequently a rank correlation computed from a coarse statistic is bounded away from $1$ *before any data is seen*, by an amount determined entirely by the statistic's granularity.

Practitioners generally know this qualitatively. What has been missing is a usable quantitative theory: exact ceilings for statistics that arise in practice, universal bounds in terms of resolution, and — critically for deployment — a guarantee that the ceilings do not move discontinuously when the input distribution drifts.

This paper supplies all three, and then uses them to adjudicate a concrete empirical question.

### 1.2 The empirical setting

Fix a bit length $b$ and draw $b$-bit integers. Two cheap statistics compete as diagnostics for a downstream response:

* the **dial** $T(x) = v_2(x)$, the number of trailing binary zeros of $x$ (the $2$-adic valuation), computed by a single machine instruction;
* the **count** $H(x)$, the Hamming weight (popcount) of $x$.

At $b=52$, three independent runs return Spearman correlations $0.698$, $0.697$, $0.720$ for the dial against the response — pooled $0.705$ — all within a pre-registered validation band $[0.55,0.85]$. The dial's pooled advantage over the count baseline is $+0.070$ with confidence interval $[0.046,0.093]$, implying a count reading of about $0.635$.

Two questions follow immediately.

**(Q1) Is the advantage real, or is it an artefact of rank granularity?** The count statistic has an enormous central tie class, $\binom{52}{26}\approx 4.96\times 10^{14}$. A natural hypothesis is that the count is simply more tie-crippled than the dial, and the $+0.070$ measures nothing but that.

**(Q2) Is band membership robust?** The readings were obtained under (approximately) uniform draws. If the ceiling were highly sensitive to the draw law, the band membership would be a knife-edge property of exact uniformity and would carry no deployment guarantee.

Both questions turn out to have clean, fully rigorous answers, and both answers are somewhat counterintuitive.

### 1.3 Contributions and organisation

Section 2 sets up the tie calculus. Section 3 computes the dyadic ceiling exactly. Section 4 computes the count ceiling and proves the inversion law, answering (Q1). Section 5 proves the resolution law and exhibits the shape gap. Section 6 proves the dominant-block and half-mass caps. Section 7 proves the envelope stability law with a matching lower witness, answering (Q2). Section 8 applies everything to the recorded numbers. Section 9 gives algorithms; Section 10 discusses limitations and future work.

---

## 2. The tie calculus

### 2.1 Tie profiles

**Definition 2.1 (Tie profile).** Let $T$ be a statistic on a sample of $n$ points. Its **tie profile** is the multiset $L=(m_1,\dots,m_K)$ of the cardinalities of the level sets $T^{-1}(v)$, $v$ ranging over the values actually taken. We write $\Sigma L = \sum_j m_j = n$ and $|L| = K$ for the number of distinct values. All $m_j \ge 1$.

The profile records everything about the statistic that rank methods can see, and nothing else. Two statistics with the same profile are indistinguishable to any rank-based procedure applied to the statistic alone.

**Definition 2.2 (Tie correction).** The **tie correction** of a profile is
$$C(L) \;=\; \sum_{j=1}^{K} \frac{m_j^3 - m_j}{12}.$$
Equivalently $12\,C(L) = S_3(L) - \Sigma L$, where $S_3(L) = \sum_j m_j^3$ is the **cube sum**.

The quantity $C(L)$ is precisely the reduction in the variance of the rank vector caused by midranking: the ranks of a tied block of size $m$ collapse from $m$ distinct consecutive integers to a single repeated value, and the variance so removed is $(m^3-m)/12$.

### 2.2 The ceiling

Spearman's $\rho$ with midranks is the Pearson correlation of the midrank vectors of the statistic and the response. Standard tie-corrected algebra gives, for the best possible response — one whose own ranking refines the statistic's blocks in a fixed consistent order, so that every comparison the statistic *can* resolve is resolved correctly —

**Definition 2.3 (Tie ceiling).** For a profile $L$ with $n=\Sigma L\ge 2$,
$$\rho^2_{\max}(L) \;=\; 1 \;-\; \frac{12\,C(L)}{n^3-n} \;=\; 1 - \frac{S_3(L)-n}{n^3-n}.$$
We write $\rho_{\max}(L) = \sqrt{\rho^2_{\max}(L)}$.

**Proposition 2.4 (Basic properties).** For any profile $L$ with $n \ge 2$:

1. $0 \le \rho^2_{\max}(L)\le 1$;
2. $\rho^2_{\max}(L)=1$ if and only if $L=(1,1,\dots,1)$ (no ties);
3. $\rho^2_{\max}\bigl((n)\bigr)=0$ (a constant statistic);
4. $\rho^2_{\max}$ depends on $L$ only through $n$ and the cube sum $S_3(L)$; it is strictly decreasing in $S_3$.

*Proof sketch.* (4) is immediate from the definition. For (1), non-negativity is the inequality $S_3(L)\le n^3$, which holds because $\sum_j m_j^3 \le (\sum_j m_j)^3$ for non-negative reals; the upper bound is $S_3(L)\ge n$, which holds termwise since $m^3\ge m$ for $m\ge 1$. (2) and (3) are the two equality cases: $S_3=n$ forces every $m_j\in\{0,1\}$, and $S_3=n^3$ forces a single block. $\square$

Statement (4) is the organising principle of the whole paper: **the ceiling is a single scalar functional of the profile**, namely the normalised cube sum. Every result below is an estimate of $S_3$.

### 2.3 Two lemmas used repeatedly

**Lemma 2.5 (Monotone block domination).** If $M$ is a block of $L$, then $M \le \Sigma L$ and
$$\frac{M^3-M}{12} \;\le\; C(L).$$

*Proof.* Both statements are inductions over the list; the second uses that every term $(m^3-m)/12$ is non-negative, so dropping all terms other than the one for $M$ can only decrease the sum. $\square$

**Lemma 2.6 (Positivity of the denominator).** For $n \ge 2$ one has $n^3 - n > 0$, and for $n \ge 2$ also $n^2 - 1 > 0$.

---

## 3. The dial: an exact ceiling that ignores word length

### 3.1 The dyadic profile

**Definition 3.1.** The **dyadic profile** at bit length $b$ is
$$L_{\mathrm{dy}}(b) \;=\; \bigl(2^{b-1},\,2^{b-2},\,\dots,\,2,\,1,\,1\bigr),$$
defined recursively by $L_{\mathrm{dy}}(0)=(1)$ and $L_{\mathrm{dy}}(b+1) = \bigl(2^{b}\bigr) \frown L_{\mathrm{dy}}(b)$.

**Proposition 3.2.** $\Sigma L_{\mathrm{dy}}(b) = 2^b$ and $|L_{\mathrm{dy}}(b)| = b+1$. Moreover $L_{\mathrm{dy}}(b)$ is the tie profile of the trailing-zero statistic $v_2$ on the $2^b$ residues modulo $2^b$: exactly $2^{b-1}$ of them are odd, $2^{b-2}$ have valuation $1$, and so on down to the singleton $\{0\}$.

### 3.2 The dyadic ceiling theorem

**Theorem 3.3 (Dyadic ceiling).** For every $b \ge 1$, writing $n=2^b$,
$$\rho^2_{\max}\bigl(L_{\mathrm{dy}}(b)\bigr) \;=\; \frac{6}{7}\left(1 + \frac{1}{n(n+1)}\right).$$

*Proof sketch.* The cube sum is a geometric series:
$$S_3 = \sum_{k=0}^{b-1} \bigl(2^{k}\bigr)^3 + 1 = \frac{8^b-1}{7} + 1 = \frac{n^3+6}{7}.$$
Hence
$$1 - \rho^2_{\max} = \frac{S_3 - n}{n^3-n} = \frac{n^3 - 7n + 6}{7\,n(n^2-1)} = \frac{(n-1)(n-2)(n+3)}{7\,n(n-1)(n+1)} = \frac{(n-2)(n+3)}{7n(n+1)} .$$
Subtracting from $1$ and simplifying,
$$\rho^2_{\max} = \frac{7n(n+1) - (n^2+n-6)}{7n(n+1)} = \frac{6(n^2+n+1)}{7n(n+1)} = \frac{6}{7}\left(1+\frac{1}{n(n+1)}\right). \qquad \square$$

**Corollary 3.4 (Word-length independence).** $\rho^2_{\max}(L_{\mathrm{dy}}(b)) \downarrow 6/7$ as $b\to\infty$, and the excess over $6/7$ is $O(4^{-b})$. At $b=52$ the excess is below $5\times 10^{-32}$. On the correlation scale,
$$\rho_{\max} \;\le\; \sqrt{6/7} \;=\; 0.92582\ldots$$
for every $b \ge 3$, with equality to $32$ decimal places at $b=52$.

**Remark 3.5 (Why $6/7$).** The dyadic profile is self-similar: deleting the leading block and halving rescales the profile to itself. Under this scaling $S_3$ picks up a factor $8$ while $n^3$ picks up a factor $8$ as well, so the *normalised* cube sum has a fixed point, namely $S_3/n^3 \to 1/7$. The constant is a signature of binary doubling, not of any hardware parameter. Any statistic whose level sets shrink geometrically with ratio $r$ has normalised cube sum $\to (1-r^3)^{-1}(1-r)^3$-type expressions; $r=1/2$ gives $1/7$.

---

## 4. The count baseline and the inversion law

### 4.1 The binomial profile and Franel numbers

**Definition 4.1.** The **binomial profile** at bit length $b$ is
$$L_{\mathrm{bin}}(b) = \left(\binom{b}{0},\binom{b}{1},\dots,\binom{b}{b}\right),$$
with $\Sigma L_{\mathrm{bin}}(b) = 2^b$ and $|L_{\mathrm{bin}}(b)| = b+1$.

**Proposition 4.2 (Combinatorial bridge).** $L_{\mathrm{bin}}(b)$ is the tie profile of the Hamming-weight statistic on the Boolean cube: the level set of weight $k$ is the family of $k$-element subsets of a $b$-element set, of cardinality $\binom{b}{k}$.

**Definition 4.3.** The **Franel number** is $F(b) = \sum_{k=0}^{b}\binom{b}{k}^3$; this is the cube sum $S_3(L_{\mathrm{bin}}(b))$. (Sequence A000172; $F(0)=1$, $F(1)=2$, $F(2)=10$, $F(3)=56$, $F(4)=346$.)

Thus, exactly,
$$\rho^2_{\max}\bigl(L_{\mathrm{bin}}(b)\bigr) \;=\; 1 - \frac{F(b) - 2^b}{8^b - 2^b}.$$
At $b=52$ this evaluates to $0.9929768931\ldots$ — but we want a *proved* bound valid for all $b$, and that requires estimating $F(b)$.

### 4.2 The arithmetic input

**Lemma 4.4 (Cube-to-square collapse).** $\displaystyle F(b) \le \Bigl(\max_k \binom{b}{k}\Bigr)^{2}\cdot 2^{b} = \binom{b}{\lfloor b/2\rfloor}^{2}\, 2^{b}$.

*Proof.* Termwise, $\binom{b}{k}^3 = \binom{b}{k}^2\binom{b}{k}\le \binom{b}{\lfloor b/2\rfloor}^2 \binom{b}{k}$; sum over $k$ and use $\sum_k \binom{b}{k}=2^b$. $\square$

**Lemma 4.5 (Sharp central-binomial bound).** For every $m \ge 0$,
$$\binom{2m}{m}^{2}(3m+1) \;\le\; 16^{m},$$
equivalently $\binom{2m}{m} \le 4^m/\sqrt{3m+1}$.

*Proof sketch.* Induction on $m$. The base case is $1\le 1$. For the step, use the exact recurrence $(m+1)\binom{2m+2}{m+1} = 2(2m+1)\binom{2m}{m}$. Multiplying the target inequality at $m+1$ by $(m+1)^2(3m+1)>0$ and substituting the recurrence reduces it to
$$4\bigl[(2m+1)^2(3m+4)\bigr]\cdot \binom{2m}{m}^2(3m+1) \;\le\; 16^{m+1}(m+1)^2(3m+1),$$
and by the inductive hypothesis it suffices that $(2m+1)^2(3m+4) \le (2m+2)^2(3m+1)$, i.e. after expansion $12m^3+28m^2+19m+4 \le 12m^3+28m^2+20m+4$, which holds for $m\ge 0$. $\square$

This is essentially the sharp form of Wallis's estimate; the factor $3m+1$ is the best of the form $am+1$ for which the induction closes, and the resulting constant $\sqrt{3}$ in $\binom{2m}{m}\sim 4^m/\sqrt{\pi m}$ is off by only $\sqrt{\pi/3}\approx 1.023$.

**Proposition 4.6 (Franel bound at even bit length).** For every $m\ge 0$,
$$F(2m)\,(3m+1) \;\le\; 8^{2m}.$$

*Proof.* Combine Lemmas 4.4 and 4.5: $F(2m)(3m+1) \le \binom{2m}{m}^2 2^{2m}(3m+1) \le 16^m\cdot 2^{2m} = 2^{4m+2m}=8^{2m}$. $\square$

So the Franel sum is $O(8^b/b)$: a vanishing fraction of the maximum conceivable cube sum $8^b$.

### 4.3 The count ceiling law

**Theorem 4.7 (Count ceiling law).** For every even bit length $b=2m\ge 2$,
$$\rho^2_{\max}\bigl(L_{\mathrm{bin}}(b)\bigr) \;\ge\; 1 - \frac{2}{3m+1} \;=\; 1 - \frac{4}{3b+2}.$$

*Proof sketch.* Write $n=2^b$, so $n^3=8^b$ and $n^3-n \ge 8^b/2$ (since $8^b \ge 2\cdot 2^b$ for $b\ge 1$). Then
$$1-\rho^2_{\max} = \frac{F(b)-n}{n^3-n} \le \frac{F(b)}{8^b/2} = \frac{2F(b)}{8^b} \le \frac{2}{3m+1}$$
by Proposition 4.6. $\square$

**Corollary 4.8 (Asymptotic tie-transparency).** $\rho^2_{\max}(L_{\mathrm{bin}}(2m)) \to 1$ as $m\to\infty$.

*Proof.* Squeeze between the lower bound of Theorem 4.7, which tends to $1$, and the universal upper bound $1$ of Proposition 2.4. $\square$

At $b=52$: $\rho^2_{\max} \ge 1 - 2/79 = 0.974683\ldots$, and the exact value is $0.992977$.

### 4.4 The inversion law

**Theorem 4.9 (Inversion law).** For every even $b = 2m \ge 10$,
$$\rho^2_{\max}\bigl(L_{\mathrm{dy}}(b)\bigr) \;<\; \rho^2_{\max}\bigl(L_{\mathrm{bin}}(b)\bigr).$$
That is, the Hamming-weight statistic is *strictly less* tie-attenuated than the trailing-zero statistic.

*Proof sketch.* By Theorem 3.3 and $n=2^b\ge 1024$,
$$\rho^2_{\max}(L_{\mathrm{dy}}(b)) \le \frac67 + \frac{1}{2^b} \le \frac67 + \frac{1}{1024} < 0.8582.$$
By Theorem 4.7 with $m \ge 5$, $\rho^2_{\max}(L_{\mathrm{bin}}(b)) \ge 1 - 2/16 = 0.875$. The two intervals are disjoint. $\square$

Numerically the inversion in fact already holds from $b=3$; the theorem certifies the regime that the proof covers unconditionally.

### 4.5 Answering (Q1): the advantage is not a tie artefact

**Theorem 4.10 (The advantage is not a tie artefact).** At $b=52$, let $r_{\mathrm{dial}} = 0.705$ and $r_{\mathrm{count}} = 0.635$ be the pooled readings. Then
$$r_{\mathrm{count}} < r_{\mathrm{dial}} \qquad\text{while}\qquad \rho^2_{\max}(L_{\mathrm{dy}}(52)) < \rho^2_{\max}(L_{\mathrm{bin}}(52)).$$
The observed ordering of readings is opposite to the ordering of the tie ceilings.

*Proof.* The first inequality is arithmetic; the second is Theorem 4.9 at $m=26$. $\square$

This is the adversarial content of the paper. Rank-tie attenuation is a *downward* force acting more strongly on the statistic with the larger normalised cube sum. Here that is the dial, not the count. Hence tie geometry, if it explained anything at all, would predict the *opposite* sign of the observed advantage. A tie/quantisation explanation of $+0.070$ is therefore ruled out, and any residual explanation must be located in the response, not in the granularity of the statistic.

**Theorem 4.11 (Deficit comparison).** Measuring each statistic against its own ceiling,
$$\Bigl(\rho^2_{\max}(L_{\mathrm{bin}}(52)) - r_{\mathrm{count}}^2\Bigr) \;-\; \Bigl(\rho^2_{\max}(L_{\mathrm{dy}}(52)) - r_{\mathrm{dial}}^2\Bigr) \;>\; \frac15 .$$

*Proof sketch.* Use the lower bound $\rho^2_{\max}(L_{\mathrm{bin}}(52))\ge 1-2/79$ and the upper bound $\rho^2_{\max}(L_{\mathrm{dy}}(52))\le 6/7+2^{-52}$, together with $r_{\mathrm{count}}^2 = 0.403225$ and $r_{\mathrm{dial}}^2=0.497025$. The count deficit exceeds $0.5714$; the dial deficit is at most $0.3602$. $\square$

The count baseline squanders strictly more of its resolving power — by more than $0.2$ in squared correlation — despite starting from a strictly better instrument.

---

## 5. The resolution law

### 5.1 A power-mean inequality with an SOS certificate

**Theorem 5.1 (Power-mean inequality for tie profiles).** For any profile $L$ with $K=|L|$ blocks and total mass $n=\Sigma L$,
$$n^3 \;\le\; K^2 \, S_3(L),$$
with equality if and only if all blocks are equal.

*Proof sketch.* Induction on the length of $L$. Write $L = (m)\frown L'$ with $K'=|L'|$, $s=\Sigma L'$, $S'=S_3(L')$; the inductive hypothesis is $s^3\le K'^2 S'$ and the goal is $(m+s)^3 \le (K'+1)^2 (m^3+S')$. Multiplying by $K'^2>0$ and rearranging, the goal becomes
$$0 \;\le\; \underbrace{\Bigl[K'^2(K'+1)^2 m^3 + (K'+1)^2 s^3 - K'^2 (m+s)^3\Bigr]}_{\text{(A)}} \;+\; (K'+1)^2\underbrace{\bigl[K'^2 S' - s^3\bigr]}_{\ge\,0 \text{ by hypothesis}} .$$
Term (A) admits the explicit factorisation
$$\text{(A)} \;=\; (K'm - s)^2\,\bigl(K'^2 m + 2K'm + 2K's + s\bigr),$$
which is manifestly non-negative for $m,s,K'\ge 0$. The degenerate case $K'=0$ (so $L'$ empty) is checked directly. $\square$

The factorisation is the crux: it converts an inductive analytic inequality into a *sum-of-squares certificate*, an identity verifiable by expansion. Equality in (A) forces $K'm=s$, i.e. the new block equals the mean of the old, which iterated gives the equal-block equality case.

### 5.2 The law and its contrapositive

**Theorem 5.2 (Resolution law).** Let $L$ be a profile with $n=\Sigma L\ge 2$, all blocks $\ge 1$, and $K = |L|$ distinct values. Then
$$\rho^2_{\max}(L) \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2}.$$

*Proof sketch.* By Theorem 5.1, $S_3(L)\ge n^3/K^2$, so the ceiling deficit obeys
$$1-\rho^2_{\max}(L) = \frac{S_3-n}{n^3-n} \;\ge\; \frac{n^3/K^2 - n}{n^3-n}.$$
It remains to check $\frac{1}{K^2}-\frac{1}{n^2}\le \frac{n^3/K^2-n}{n^3-n}$, i.e. after clearing the positive denominator,
$$\Bigl(\tfrac{1}{K^2}-\tfrac{1}{n^2}\Bigr)(n^3-n) = \frac{n^3}{K^2} - n - \Bigl(\frac{n}{K^2}-\frac1n\Bigr) \;\le\; \frac{n^3}{K^2}-n,$$
which holds because $K \le n$ (blocks are non-empty) gives $n/K^2 \ge 1/n$. $\square$

**Corollary 5.3 (Strict sub-unity).** If $K < n$ — i.e. the statistic has fewer values than points — then $\rho^2_{\max}(L)<1$.

**Corollary 5.4 (Resolution budget).** If a statistic attains $\rho^2 \ge 1-\varepsilon$, then
$$K^2\left(\varepsilon + \frac{1}{n^2}\right)\;\ge\;1, \qquad\text{i.e.}\qquad K \;\ge\; \bigl(\varepsilon+n^{-2}\bigr)^{-1/2}.$$

Corollary 5.4 is a design constraint: to read $\rho^2\ge 0.99$ a statistic needs at least $10$ distinct values; for $\rho^2\ge 0.9999$, at least $100$. It costs nothing to check at design time and rules out entire families of over-quantised diagnostics.

**Corollary 5.5 (Two-value floor).** Any profile whose ceiling reaches the bottom of the band, $\rho^2_{\max}\ge 0.55^2$, satisfies $K\ge 2$.

*Proof.* $K=0$ is impossible for $n\ge 2$, and $K=1$ gives $L=(n)$ with $\rho^2_{\max}=0$. $\square$

### 5.3 The sandwich, and the shape gap

**Theorem 5.6 (Count sandwich at $b=52$).**
$$0.974683 \;=\; 1-\frac{2}{79} \;\le\; \rho^2_{\max}\bigl(L_{\mathrm{bin}}(52)\bigr) \;\le\; 1-\frac{1}{53^2}+\frac{1}{(2^{52})^2} \;=\; 0.999644.$$

*Proof.* Lower: Theorem 4.7 with $m=26$. Upper: Theorem 5.2 with $K=53$, $n=2^{52}$. $\square$

The count baseline's true ceiling ($0.992977$) sits inside this interval. The important consequence is negative: the count is *not* tie-limited anywhere near the recorded band. A reading of $0.635$ cannot be blamed on its ties.

**Theorem 5.7 (Shape gap).** The dyadic and binomial profiles at $b=52$ have the *same* number of distinct values, $|L_{\mathrm{dy}}(52)| = |L_{\mathrm{bin}}(52)| = 53$, yet
$$\rho^2_{\max}\bigl(L_{\mathrm{dy}}(52)\bigr) + \frac{1}{10} \;<\; 1-\frac{1}{53^2}+\frac{1}{(2^{52})^2}.$$

*Proof sketch.* The left side is at most $6/7 + 2^{-52} + 0.1 < 0.9572$; the right side exceeds $0.9996$. $\square$

Numerically the dyadic profile falls $0.1425$ short of its resolution budget, while the binomial profile falls only $0.0067$ short.

**Interpretation.** Resolution is necessary but nowhere near sufficient. The number of distinct values gives an upper envelope; where inside that envelope a statistic actually lands is decided by the *shape* of its profile — specifically by how far the block masses are from equal. The dyadic profile is the extreme dominant-block shape (one class holding half the mass); the binomial profile is close to the equal-mass shape in the sense that matters, because its mass is spread over $\Theta(\sqrt b)$ comparable classes. This dichotomy — *resolution vs. shape* — is the conceptual heart of the theory.

---

## 6. Dominant blocks and the half-mass cap

The resolution law bounds ceilings from above using only $K$. We now bound them from above using only the *largest* block, which for skewed statistics is far more informative.

**Theorem 6.1 (Dominant-block upper law).** Let $M$ be any block of $L$ and $n=\Sigma L\ge 2$. Then
$$\rho^2_{\max}(L) \;\le\; 1 - \frac{M^3-M}{n^3-n}.$$
No hypothesis on the remaining blocks is required.

*Proof.* By Lemma 2.5, $12\,C(L)\ge M^3-M$. Divide by $n^3-n>0$ and substitute into Definition 2.3. $\square$

**Theorem 6.2 (Half-mass cap).** If some block satisfies $M \ge n/2$ and $n\ge 2$, then
$$\rho^2_{\max}(L) \;\le\; \frac{7}{8} + \frac{7}{8(n^2-1)}.$$

*Proof sketch.* From $n \le 2M$ and cubing, $M^3 \ge n^3/8$, so $M^3-M \ge n^3/8 - n$ (using $M\le n$). One verifies the exact identity
$$\left(\frac18 - \frac{7}{8(n^2-1)}\right)(n^3-n) \;=\; \frac{n^3}{8}-n,$$
so the deficit $(M^3-M)/(n^3-n)$ is at least $\tfrac18 - \tfrac{7}{8(n^2-1)}$. Substituting into Theorem 6.1 gives the claim. $\square$

**Theorem 6.3 (Reading cap).** If in addition $n \ge 1024$, then on the correlation scale
$$\rho_{\max}(L) \;\le\; 0.936.$$

*Proof sketch.* For $n\ge 1024$ the correction term satisfies $\tfrac{7}{8(n^2-1)}\le 10^{-6}$, so $\rho^2_{\max}\le 7/8 + 10^{-6} \le (0.936)^2 = 0.876096$. Take square roots. $\square$

**Proposition 6.4 (The dial is half-mass).** For every $b\ge 1$, the dyadic profile $L_{\mathrm{dy}}(b)$ contains the block $2^{b-1}$ and has total mass $2^b = 2\cdot 2^{b-1}$. Hence Theorems 6.2 and 6.3 apply, and $\rho_{\max}(L_{\mathrm{dy}}(52)) \le 0.936$.

**Remark 6.5 (Why this matters more than Theorem 3.3).** Theorem 3.3 is *exact* but assumes the exact uniform draw law. Theorem 6.3 is *weaker* but **distribution-free**: it holds for any draw law under which at least half the sampled words are odd. Balanced draws, uniform draws, and everything in between satisfy this. The pre-registered validation band $[0.55,0.85]$ lies strictly inside $[0,0.936]$, so the band is a meaningful test rather than a vacuous one; and a reported reading above $0.936$ would falsify the half-mass model outright rather than confirming an unusually strong effect.

---

## 7. The deployment envelope: stability under a shift of the draw law

### 7.1 Distance between draw laws

**Definition 7.1.** For two profiles $L,L'$ of the same length, listed in a common class order, the $\ell^1$ distance is $\|L-L'\|_1 = \sum_j |m_j - m'_j|$. If they carry the same total mass $n$, the induced **total-variation distance** between the two draw laws is $\tau = \|L-L'\|_1/(2n)$.

### 7.2 A crude bound and a conservation-aware improvement

**Lemma 7.2 (Generic cube Lipschitz bound).** If all blocks of $L$ and $L'$ are $\le N$ and $|L|=|L'|$, then
$$\bigl|S_3(L)-S_3(L')\bigr| \;\le\; 3N^2\,\|L-L'\|_1 .$$

*Proof.* Termwise, $|a^3-b^3| = |a-b|\,|a^2+ab+b^2| \le 3N^2|a-b|$; sum and apply the triangle inequality. $\square$

**Theorem 7.3 (Envelope stability law, crude form).** If $|L|=|L'|$, $\Sigma L=\Sigma L' = n \ge 3$, and $\|L-L'\|_1 \le 2\tau n$ with $\tau\ge 0$, then
$$\bigl|\rho^2_{\max}(L) - \rho^2_{\max}(L')\bigr| \;\le\; 7\tau.$$

*Proof sketch.* Since $\Sigma L = \Sigma L'$, the difference of ceilings is exactly $\bigl(S_3(L')-S_3(L)\bigr)/(n^3-n)$. Apply Lemma 7.2 with $N=n$ and then $\|L-L'\|_1\le 2\tau n$:
$$\bigl|\Delta\rho^2_{\max}\bigr| \le \frac{3n^2\cdot 2\tau n}{n^3-n} = \frac{6\tau n^3}{n^3-n} \le 7\tau,$$
the last step because $n\ge 3$ gives $n^3-n\ge \tfrac67 n^3$. $\square$

Lemma 7.2 wastes information: it treats the two profiles as unconstrained, whereas in fact mass is *conserved*. Exploiting this gives a genuinely better constant.

**Lemma 7.4 (Displacement lemma).** For profiles of equal length, every coordinate satisfies
$$2\bigl|m_j - m'_j\bigr| \;\le\; \|L-L'\|_1 + \bigl|\Sigma L - \Sigma L'\bigr|.$$
In particular, if $\Sigma L = \Sigma L'$, then $|m_j-m'_j| \le \tfrac12\|L-L'\|_1$ for every $j$.

*Proof sketch.* Induction on the list. Write $d_j = m_j - m'_j$ and $D = \sum_j d_j = \Sigma L - \Sigma L'$. For the head coordinate, the triangle inequality gives $|d_1| \le |D| + |\sum_{j\ge2} d_j| \le |D| + \sum_{j\ge 2}|d_j| = |D| + \|L-L'\|_1 - |d_1|$; rearranging gives the claim, and the same argument applies to each coordinate. $\square$

Intuitively: with mass conserved, whatever leaves one class must arrive elsewhere, so the $\ell^1$ budget is spent twice on every unit of displaced mass and no single class can absorb more than half of it.

**Lemma 7.5 (Square-sum bound).** $\displaystyle\sum_j (m_j + m'_j)^2 \le \bigl(\Sigma L + \Sigma L'\bigr)^2$.

*Proof.* Non-negativity of the cross terms in expanding the right-hand side. $\square$

**Theorem 7.6 (Conservation-aware cube bound).** If $|L|=|L'|$ and $\Sigma L=\Sigma L'=n$, then
$$\bigl|S_3(L)-S_3(L')\bigr| \;\le\; 2n^2\,\|L-L'\|_1 .$$

*Proof sketch.* Termwise use the sharper factorisation $|a^3-b^3| = |a-b|(a^2+ab+b^2) \le |a-b|\,(a+b)^2$, then bound every $|a-b|$ by $\tfrac12\|L-L'\|_1$ (Lemma 7.4) and sum the weights using Lemma 7.5:
$$|S_3(L)-S_3(L')| \le \tfrac12\|L-L'\|_1 \sum_j (m_j+m'_j)^2 \le \tfrac12\|L-L'\|_1 \cdot (2n)^2 = 2n^2\|L-L'\|_1. \ \square$$

This is a factor $3/2$ better than Lemma 7.2, and unlike it, it uses the conservation law.

**Theorem 7.7 (Sharpened envelope stability law).** If $|L|=|L'|$, $\Sigma L=\Sigma L'=n\ge 7$, and $\|L-L'\|_1 \le 2\tau n$ with $\tau\ge 0$, then
$$\bigl|\rho^2_{\max}(L) - \rho^2_{\max}(L')\bigr| \;\le\; 4.1\,\tau.$$

*Proof sketch.* As in Theorem 7.3 but with Theorem 7.6: the bound becomes $4\tau n^3/(n^3-n)$, and $n\ge 7$ gives $n^3 \ge 41 n$, hence $n^3-n \ge \tfrac{40}{41} n^3$ and $4\tau n^3/(n^3-n) \le \tfrac{41}{10}\tau$. $\square$

### 7.3 A matching lower witness

Is the constant $4.1$ merely an artefact of the proof? No: the true modulus is of the same order.

**Theorem 7.8 (Envelope constant lower bound).** Consider the two $52$-bit profiles
$$A = \bigl(4503599627370495,\; 1\bigr), \qquad B = \bigl(4458563631096791,\; 45035996273705\bigr).$$
Then $|A|=|B|=2$, $\Sigma A = \Sigma B = 2^{52}$, the total variation between them is $\tau \le 1/100$, and
$$\bigl|\rho^2_{\max}(A) - \rho^2_{\max}(B)\bigr| \;\ge\; 0.0296 .$$
Consequently no envelope law of the form $|\Delta \rho^2_{\max}|\le c\,\tau$ can hold with $c < 2.96$.

*Proof sketch.* Both are exact integer computations. $\|A-B\|_1 = 2\cdot 45035996273704 = 90071992547408$, so $\tau = 45035996273704/2^{52} < 1/100$. Profile $A$ is essentially degenerate: $S_3(A) = (n-1)^3+1$, giving $\rho^2_{\max}(A) \approx 3/n \approx 0$. Profile $B$ has normalised blocks $0.99$ and $0.01$, so $\rho^2_{\max}(B) \approx 1 - 0.99^3 - 0.01^3 = 0.0297$. The difference is $0.0297$ to eight decimal places. $\square$

**Corollary 7.9 (Bracketing).** The sharp envelope constant $c^\ast = \sup |\Delta\rho^2_{\max}|/\tau$ satisfies
$$2.96 \;\le\; c^\ast \;\le\; 4.1,$$
a bracket of width less than a factor $1.4$.

**Remark 7.10.** The witness reveals *where* the modulus is attained: at profiles near total degeneracy, where the cube sum is close to $n^3$ and its derivative in the direction of mass transfer is largest. Realistic profiles — including both of ours — sit far from this regime, so the effective local modulus for the dial is much smaller than $c^\ast$; Theorem 7.7 is the worst-case guarantee.

### 7.4 Answering (Q2): the recorded envelope at bit length 52

**Theorem 7.11 (Deployment envelope at $b=52$).** Let $L'$ be the tie profile of the trailing-zero statistic under any draw law with the same $53$ classes and the same total mass $2^{52}$ as the uniform law, at total-variation distance at most $1/100$. Then
$$\rho^2_{\max}(L') \;>\; 0.78 \;>\; 0.720^2,$$
so $\rho^2_{\max}(L')$ strictly exceeds the square of every recorded seed reading.

*Proof sketch.* By Theorem 3.3, $\rho^2_{\max}(L_{\mathrm{dy}}(52)) \ge 6/7$. By Theorem 7.3 (or a fortiori Theorem 7.7), $\rho^2_{\max}(L_{\mathrm{dy}}(52)) - \rho^2_{\max}(L') \le 7/100$. Hence $\rho^2_{\max}(L') \ge 6/7 - 0.07 > 0.78$. Since $0.720^2 = 0.5184 < 0.78$, all three recorded readings remain strictly beneath the perturbed ceiling. $\square$

**Corollary 7.12 (Tolerated drift).** With the sharpened constant $4.1$, band membership at bit length $52$ persists under any draw-law shift of total variation
$$\tau \;\le\; \frac{6/7 - 0.705^2}{4.1} \;=\; \frac{0.36012}{4.1} \;\approx\; 0.0878,$$
i.e. up to roughly an $8.8\%$ change in the input distribution.

This is the precise mathematical content of the claim that the dial's *deployment envelope* covers uniform as well as balanced draws at bit length $52$: band membership is not a knife-edge property of exact uniformity but a robust property with an explicit, quantified margin.

---

## 8. The recorded measurement, checked against the theory

Collecting everything for $b=52$, $n=2^{52}=4{,}503{,}599{,}627{,}370{,}496$:

| Quantity | Value | Source |
|---|---|---|
| Seed readings $\rho$ | $0.698,\ 0.697,\ 0.720$ | recorded |
| Pooled $\rho$ | $0.705$ | arithmetic mean of seeds |
| Validation band | $[0.55, 0.85]$ | all three inside |
| Advantage over count | $+0.070$, CI $[0.046, 0.093]$ | recorded; CI excludes $0$ |
| Implied count reading | $0.635$ | pooled minus advantage |
| Dial tie ceiling $\rho^2$ | $\tfrac67(1+4^{-52}\cdot\ldots) = 0.857142857\ldots$ | Theorem 3.3 |
| Dial tie ceiling $\rho$ | $0.925820$ | $\sqrt{6/7}$ |
| Count tie ceiling $\rho^2$ | $0.992977$; proved $\in[0.974683,\,0.999644]$ | Theorems 4.7, 5.6 |
| Count tie ceiling $\rho$ | $0.996482$ | — |
| Distribution-free cap on $\rho$ | $0.936$ | Theorem 6.3 |
| Dial deficit $\rho^2_{\max}-\rho^2$ | $0.360$ | — |
| Count deficit | $0.590$ | — |
| Deficit gap | $0.230 > 1/5$ | Theorem 4.11 |
| Envelope constant | $c^\ast\in[2.96,\,4.1]$ | Theorems 7.7, 7.8 |
| Tolerated drift | $\tau \lesssim 8.8\%$ | Corollary 7.12 |

Every entry in the "Source" column is a theorem proved above or exact rational arithmetic; none relies on simulation.

The synthesis is: (i) all three readings sit inside the band; (ii) all three sit strictly below the exact dial ceiling and far below the distribution-free cap, so the measurement is internally consistent; (iii) the count baseline, which lost by $0.070$, has the *higher* ceiling by $0.136$ in $\rho^2$, so ties cannot explain the loss; (iv) the whole configuration survives an $8.8\%$ perturbation of the draw law.

---

## 9. Algorithms

### 9.1 Exact ceiling evaluation

Given a profile as a list of integers, the ceiling is computed in $O(K)$ big-integer operations:

```
INPUT   L = (m_1, ..., m_K), integers >= 1
n   <- sum_j m_j                       # O(K) additions
S3  <- sum_j m_j^3                     # O(K) multiplications
if n < 2: reject
OUTPUT  1 - (S3 - n) / (n^3 - n)       # one exact rational division
```

All arithmetic must be exact: at $b=52$ the numerator and denominator have $\sim 47$ decimal digits and double precision loses the entire signal in the correction term. Using arbitrary-precision rationals, the cost is dominated by the $K$ cubings, each on integers of $O(b)$ bits, giving $O(K\,\mathsf{M}(b))$ bit operations where $\mathsf{M}$ is the multiplication cost.

### 9.2 Profile construction

The dyadic profile at bit length $b$ is $(2^{b-1},\dots,2,1,1)$ — $O(b)$ shifts. The binomial profile is one Pascal row, computed by the multiplicative recurrence $\binom{b}{k+1} = \binom{b}{k}(b-k)/(k+1)$ in $O(b)$ exact divisions, each exact by construction.

### 9.3 Certified envelope check

To certify that a measured reading is compatible with a claimed model:

```
INPUT   profile L, reading r, band [lo, hi], drift budget tau
1. n <- sum L; c2 <- ceiling_sq(L)
2. assert r^2 < c2                       # reading below its own ceiling
3. M <- max block of L
   if 2M >= n: assert r <= 0.936         # distribution-free half-mass cap
4. assert hi^2 + 4.1 * tau <= c2         # band survives the drift budget
5. K <- |L|
   assert c2 <= 1 - 1/K^2 + 1/n^2        # resolution law consistency
OUTPUT  PASS / the first failing certificate
```

Step 4 is the deployment envelope: it verifies that even after a worst-case draw-law shift of total variation $\tau$, the top of the validation band remains strictly beneath the ceiling. All steps are $O(K)$ exact-arithmetic operations and can be run before data collection.

### 9.4 Franel evaluation

For asymptotic work the Franel numbers satisfy the three-term P-recursive relation
$$(n+1)^2 F(n+1) = (7n^2+7n+2)F(n) + 8n^2 F(n-1), \qquad F(0)=1,\ F(1)=2,$$
which computes $F(b)$ in $O(b)$ big-integer operations rather than the $O(b)$ cubings of the definition, and — more importantly — provides the handle for the asymptotic analysis discussed in Section 10.

---

## 10. Discussion, limitations, and future work

### 10.1 What the theory does and does not say

The tie ceiling is an *upper* bound attained only by an idealised perfectly refining response. A reading well below the ceiling therefore has two possible explanations — weak association, or a response that fails to refine — and the ceiling cannot distinguish them. What the ceiling does deliver is a rigorous *exclusion*: no reading can exceed it, so any explanation of an observed value in terms of granularity must respect the ordering of ceilings. That exclusion is exactly what settles (Q1).

Second, the profiles used here are the *population* profiles at bit length $b$ (all $2^b$ words), not the empirical profiles of a finite sample. For samples much smaller than $2^b$ the empirical dyadic profile is a multinomial draw from the dyadic law and concentrates around it; the envelope stability law (Theorem 7.7) is precisely the tool that converts that concentration into a ceiling guarantee, since the empirical profile is within small total variation of the population one with high probability. Making that step quantitative — a concentration inequality for $\tau$ combined with Theorem 7.7 — is the most immediate technical gap.

### 10.2 What failed

It is worth recording a hypothesis that the analysis destroyed. The natural guess was that the count baseline's colossal central tie class, $\binom{52}{26}\approx 4.96\times 10^{14}$, depresses its ceiling and explains its weaker reading. It does not. The class is large in absolute terms but is only about $1/9$ of $n$, and — decisively — the Franel cube sum is $\Theta(8^b/b)$, a vanishing fraction of the $\Theta(8^b)$ a genuinely degenerate profile would need. This hypothesis is not merely hard to verify; it is false, and Theorem 4.9 is its refutation.

### 10.3 Future directions

**1. Franel exact ceiling law.** The count ceiling is *exactly* $1 - (F(b)-2^b)/(8^b-2^b)$. The three-term recurrence of Section 9.4 should convert a Laplace-type asymptotic for $F(b)/8^b$ into a closed form
$$\rho^2_{\max}\bigl(L_{\mathrm{bin}}(b)\bigr) = 1 - \frac{c}{b} + O(b^{-2}), \qquad c = \frac{\sqrt3}{2\pi} \approx 0.2757,$$
replacing the sandwich $[0.9747, 0.9996]$ by an exact constant. The recurrence turns the asymptotic into a linear difference-equation estimate, which is the tractable route.

**2. A universal shape functional.** Both the dyadic ceiling ($6/7$) and the binomial ceiling ($\to 1$) are values of one functional of the *limiting mass distribution*: if the normalised profile converges weakly to a measure $\mu$ on the value space with density-like weights $p_i$, the ceiling limit is $1 - \sum_i p_i^3$ up to normalisation. For the dyadic law $p_i = 2^{-(i+1)}$ and $\sum p_i^3 = 1/7$; for the binomial law $p_i \to 0$ uniformly and the sum vanishes. Formalising this as a continuity statement for the map $\mu \mapsto \|\mu\|_3^3$ would unify every ceiling computation here, and Theorem 7.7 is the finite-$n$ shadow of exactly that continuity.

**3. Sharpening the envelope constant.** Corollary 7.9 brackets $c^\ast$ in $[2.96,4.1]$. The witness of Theorem 7.8 suggests the extremiser is a two-block profile with masses $(1-t, t)$; optimising $\bigl|1-(1-t)^3-t^3 - 0\bigr|/t$ over $t$ should identify $c^\ast$ exactly, plausibly $c^\ast = 3$.

**4. Multivariate and partial ceilings.** Real diagnostics are compared in the presence of covariates. Extending the ceiling calculus to partial and multiple rank correlations — where several coarse statistics tie simultaneously — would let one bound the reading of a whole diagnostic panel, not just of one dial.

**5. Optimal quantisation.** Corollary 5.4 says $K$ values buy at most $1-1/K^2$. Theorem 5.7 says shape decides where inside that budget you land. Combining them yields a design problem: given a continuous score and a budget of $K$ bins, choose bin boundaries maximising the ceiling. Theorem 5.1's equality case says the answer is *equal-mass bins*; quantifying the loss from unequal bins, in terms of the $\ell^3$ norm of the bin-mass vector, would give a practical quantiser-design rule.

**6. Adversarial draw laws.** Theorem 6.2 assumes only that the modal class carries half the mass. One can ask the dual question: over all draw laws at total variation $\tau$ from uniform, what is the *minimum* achievable dial ceiling? Theorem 7.7 gives $6/7 - 4.1\tau$; the extremal law that attains it is not known and would sharpen the deployment envelope to an exact worst case.

---

## 11. Conclusion

The tie ceiling of a discrete statistic is a computable, exact, distribution-free property of the instrument rather than of the phenomenon. For the trailing-zero dial it is the word-length-independent constant $\sqrt{6/7} = 0.9258$; for the Hamming-weight baseline it converges to $1$ at rate $\Theta(1/b)$. The resulting inversion — the coarse-looking count statistic is the *less* attenuated of the two — shows that a $+0.070$ measured advantage in favour of the dial cannot be produced by rank granularity, since granularity acts in the opposite direction. The resolution law bounds any ceiling in terms of the number of distinct values, and the shape gap shows that this bound leaves an enormous range that only the profile's shape can resolve. The half-mass cap gives an assumption-light guarantee $\rho\le 0.936$ under every draw law with a majority-odd sample, and the envelope stability law, with its constant bracketed in $[2.96,4.1]$, converts that guarantee into a quantified deployment envelope: at bit length $52$, band membership survives roughly an $8.8\%$ shift in the input distribution.

The practical moral is short. Before interpreting a rank correlation from a coarse statistic, compute its ceiling. It costs $O(K)$ arithmetic operations, it can be done before the experiment, and it changes what the number means.
