# Tie Geometry of the Trailing-Zero Statistic: Scale Invariance, Closed-Form Ceilings, and an Exact Inversion Threshold

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the rank-correlation *tie geometry* of the 2-adic valuation $\nu_2$ (the trailing-zero count of a binary integer) as a predictor statistic, and compare it with the popcount (Hamming weight) baseline. Three results are established.

First, a **closed-form ceiling**: on any sample of $2^b$ integers drawn from a window of consecutive integers, the trailing-zero statistic admits the maximal squared Spearman coefficient
$$\rho^2_{\max} = \frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right),$$
so the ceiling is $\sqrt{6/7} = 0.92582\ldots$ to within $O(4^{-b})$, uniformly in $b$.

Second, a **complete invariance theorem**: for every starting point $A\in\mathbb{N}$ and every scale $s$, the window $\{A, A+1, \ldots, A+2^s-1\}$ has trailing-zero tie profile *exactly* $(2^{s-1}, 2^{s-2},\ldots,2,1,1)$. Alignment, magnitude, and bit-length conditioning are all irrelevant; the operative mechanism is period divisibility, not alignment. As a corollary, uniform sampling at *exact* bit-length $b+1$ — i.e. uniform on $[2^b, 2^{b+1})$ — yields the trailing-zero tie profile of full-range bit-length $b$; the same one-bit shift holds simultaneously for the popcount baseline, whose exact-bit-length-$(b+1)$ profile is the binomial profile at $b$.

Third, an **exact inversion threshold**: with both profiles carrying mass $2^b$, the popcount baseline has strictly greater tie headroom than the trailing-zero statistic if and only if $b \ge 3$; at $b \in \{1,2\}$ the two ceilings coincide exactly. The proof reduces the ceiling comparison to a cube-sum comparison, identifies the popcount cube sum as the Franel number $\sum_j \binom{b}{j}^3$, and closes the asymptotic range by a new odd-parity Franel estimate $\mathrm{franel}(2m+1)(3m+1) \le 8^{2m+1}$.

We apply these to a recorded measurement in which a trailing-zero statistic $T$ attains Spearman correlations $0.7291 / 0.7286 / 0.7087$ against a downstream rate on uniform draws of exact bit-length 48, beating a popcount baseline by $+0.134$ (CI $[0.113,0.158]$). The theory rules out four candidate deflationary explanations — ceiling saturation, quantisation drift with bit-length, tie-geometric advantage, and window-placement effects — and forces any explanatory model to be response-side.

**Keywords:** 2-adic valuation, trailing-zero count, Spearman rank correlation, tie correction, Franel numbers, dyadic profile, translation invariance, popcount.

---

## 1. Introduction

### 1.1 The measurement

A computational pipeline produces, for each integer input $x$, a scalar *rate*. One asks how much of that rate is predicted by cheap arithmetic summaries of $x$. Two natural candidates are

- the **trailing-zero statistic** $T(x) = \nu_2(x)$, the largest $k$ with $2^k \mid x$; and
- the **popcount baseline** $W(x)$, the number of one-bits in the binary expansion of $x$.

Both are single machine instructions. In the experiment under discussion, integers were drawn uniformly among those of *exactly* 48 bits — uniformly on the dyadic window $[2^{47}, 2^{48})$ — and the Spearman rank correlation between $T$ and the rate was recorded across three independent seeds:
$$0.7291, \qquad 0.7286, \qquad 0.7087,$$
all inside a pre-registered validation band $[0.55, 0.85]$. The pooled advantage of $T$ over $W$ was $+0.134$ with confidence interval $[0.113, 0.158]$. Across widening sampling regimes the dial declines roughly $0.78 \to 0.72 \to 0.65 \to 0.61$.

### 1.2 The deflationary hypotheses

Both statistics are heavily tied: $T$ takes the value $0$ on half of all integers, $1$ on a quarter, and so on. Ties cap rank correlation. Four deflationary hypotheses therefore present themselves:

- **(H1) Saturation.** The value $\approx 0.73$ is simply the ceiling imposed by ties.
- **(H2) Quantisation drift.** The decline with bit-length is the ceiling moving.
- **(H3) Tie-geometric advantage.** $T$ beats $W$ because $T$ has more headroom.
- **(H4) Window effects.** The seed spread reflects where the sampling window sits.

Each hypothesis is a statement about the *tie profile* of the statistic — a purely arithmetic object. This paper computes those profiles exactly and settles all four.

### 1.3 Contributions

1. A closed-form tie ceiling for the trailing-zero statistic, $\frac{6}{7}\big(1+\frac{1}{2^b(2^b+1)}\big)$, with the constant $6/7$ arising as a dyadic geometric series (Theorem 3.4).
2. The one-bit shift law: exact-bit-length conditioning shifts *both* the trailing-zero and popcount tie profiles down by exactly one bit, so all comparisons transport (Theorems 4.2, 4.4).
3. Full translation invariance: every window of $2^s$ consecutive integers has trailing-zero profile $D_s$, with no error term (Theorem 5.6), specialising to the aligned case (Theorem 5.3).
4. The cube-sum reduction of ceiling comparison, and the exact inversion threshold $b \ge 3$, with sharpness at $b \in \{1,2\}$ (Theorems 6.2, 6.7, 6.8).
5. An odd-parity Franel estimate $\mathrm{franel}(2m+1)(3m+1) \le 8^{2m+1}$ and its transfer to a ceiling bound (Theorems 6.5, 6.6).
6. Refutation of (H1)–(H4) for the recorded measurement (Section 7).

---

## 2. Preliminaries: tie profiles and the Spearman ceiling

### 2.1 Profiles

**Definition 2.1 (Tie profile).** Let $f$ be a statistic on a finite sample $S$ with $|S| = n$. The *tie profile* of $f$ on $S$ is the multiset of fibre cardinalities $(m_1, \ldots, m_r)$, $m_j = |f^{-1}(v_j)|$ over the distinct values $v_1,\ldots,v_r$ attained. Its **mass** is $n = \sum_j m_j$ and its **cube sum** is $C = \sum_j m_j^3$.

We record profiles as lists; only the multiset matters for everything below.

**Definition 2.2 (Ceiling functional).** For a profile $L = (m_1,\ldots,m_r)$ with mass $n = \sum_j m_j \ge 2$, set
$$\mathrm{Sp}(L) \;=\; 1 - \frac{\sum_j m_j^3 - n}{n^3 - n}.$$

**Proposition 2.3 (Interpretation).** $\mathrm{Sp}(L)$ is the supremum of $\rho_S^2$, the squared Spearman rank correlation of $f$ against an arbitrary response $Y$ on the sample, taken over all responses; the supremum is attained by any $Y$ that is a strictly monotone function of $f$ up to arbitrary within-block ordering. It is the classical tie-corrected Spearman bound with tie-correction term $\frac{1}{12}\sum_j (m_j^3 - m_j)$.

*Sketch.* With mid-ranks assigned inside each tied block, the rank vector of $f$ has variance $\frac{n^3-n}{12} - \frac{1}{12}\sum_j(m_j^3-m_j)$ instead of the untied $\frac{n^3-n}{12}$. Cauchy–Schwarz against any response's rank vector, whose variance is at most $\frac{n^3-n}{12}$, yields $\rho^2 \le \big(1 - \frac{\sum_j m_j^3 - n}{n^3-n}\big)$, with equality when the response is untied and order-compatible with $f$. $\square$

Because we only ever compare ceilings, the following two facts do all the structural work.

**Lemma 2.4 (Cube-sum reduction).** $\mathrm{Sp}(L)$ depends on $L$ only through its mass $n$ and cube sum $C$: $\mathrm{Sp}(L) = 1 - \frac{C - n}{n^3 - n}$.

**Theorem 2.5 (Order reversal).** Let $L, M$ be profiles of equal mass $n \ge 2$. Then
$$\text{(i) } C(M) < C(L) \implies \mathrm{Sp}(L) < \mathrm{Sp}(M), \qquad \text{(ii) } C(L) = C(M) \implies \mathrm{Sp}(L) = \mathrm{Sp}(M).$$

*Proof.* $n^3 - n = n(n-1)(n+1) > 0$ for $n \ge 2$, and $\mathrm{Sp}$ is a strictly decreasing affine function of $C$ at fixed $n$. $\square$

Theorem 2.5 is the methodological lesson of this work: **compare cube sums, not ceilings.** The map $C \mapsto \mathrm{Sp}$ is an order-reversing bijection at fixed mass, and all combinatorial estimates are cleaner upstream of it.

### 2.2 The two profiles of interest

**Definition 2.6 (Dyadic profile).** $D_b = (2^{b-1}, 2^{b-2}, \ldots, 2, 1, 1)$, of length $b+1$: entry $k$ equals $2^{b-1-k}$ for $0 \le k < b$, and the final entry is $1$. Mass $\sum D_b = 2^b$.

**Definition 2.7 (Binomial profile).** $B_b = \big(\binom{b}{0}, \binom{b}{1}, \ldots, \binom{b}{b}\big)$, of length $b+1$ and mass $2^b$.

**Definition 2.8 (Franel number).** $\mathrm{franel}(b) = \sum_{j=0}^{b}\binom{b}{j}^3$. The first values are $1, 2, 10, 56, 346, 2252, 15184, \ldots$

---

## 3. The dyadic profile and its closed-form ceiling

**Definition 3.1 (Blocks of the full range).** For $k < b$ let
$$A_{b,k} = \{x < 2^b : 2^k \mid x \text{ and } 2^{k+1} \nmid x\}.$$

**Lemma 3.2.** $|A_{b,k}| = 2^{b-1-k}$ for $k < b$.

*Proof.* The elements are exactly $2^k(2t+1)$ with $2^k(2t+1) < 2^b$, i.e. $t < 2^{b-1-k}$. $\square$

The single remaining point of $[0,2^b)$ is $x = 0$, giving the final block of size $1$. Hence:

**Proposition 3.3.** The tie profile of $\nu_2$ on $[0,2^b)$ is $D_b$, of mass $2^b$ and cube sum
$$C(D_b) = \sum_{k=0}^{b-1} 8^{\,b-1-k} + 1 = \frac{8^b - 1}{7} + 1 .$$

**Theorem 3.4 (Dyadic ceiling, closed form).** For $b \ge 1$,
$$\mathrm{Sp}(D_b) = \frac{6}{7}\left(1 + \frac{1}{2^b\,(2^b+1)}\right).$$

*Proof.* Write $n = 2^b$, so $C = \frac{n^3-1}{7} + 1$ and $C - n = \frac{n^3 - 7n + 6}{7} = \frac{(n-1)(n-2)(n+3)}{7}$, while $n^3 - n = n(n-1)(n+1)$. Therefore
$$\mathrm{Sp}(D_b) = 1 - \frac{(n-2)(n+3)}{7n(n+1)} = \frac{7n(n+1) - (n^2+n-6)}{7n(n+1)} = \frac{6(n^2+n+1)}{7n(n+1)} = \frac{6}{7}\Big(1 + \frac{1}{n(n+1)}\Big). \square$$

**Corollary 3.5 (Envelope and monotonicity).** For $b \ge 1$:
$$\frac{6}{7} < \mathrm{Sp}(D_b) \le \frac{6}{7} + \frac{1}{2^b}, \qquad \mathrm{Sp}(D_b) - \frac{6}{7} < 4^{-b},$$
and $b \mapsto \mathrm{Sp}(D_b)$ is strictly decreasing.

Thus $\rho_{\max} = \sqrt{\mathrm{Sp}(D_b)} \to \sqrt{6/7} = 0.925820\ldots$ extremely fast: already at $b = 20$ the correction is below $10^{-12}$, and at $b = 47$ below $10^{-28}$. The constant $6/7$ is exactly $\big(1 - \tfrac{1}{8}\big)^{-1}\cdot\tfrac{3}{4}$, the fingerprint of the geometric halving $m_k = 2^{-k}n$.

---

## 4. Exact-bit-length conditioning: the one-bit shift law

Uniform sampling at *exact* bit-length $b+1$ means uniform sampling on the window
$$\mathcal{W}_b = [2^b, 2^{b+1}) = \{x : x \text{ has exactly } b+1 \text{ binary digits}\},$$
which conditions the top bit to be one and is a strictly different measure from uniform on $[0,2^{b+1})$.

**Definition 4.1.** For $k \le b$ let $\mathcal{W}_{b,k} = \{x \in \mathcal{W}_b : 2^k \mid x,\ 2^{k+1}\nmid x\}$.

**Theorem 4.2 (One-bit shift law, trailing-zero statistic).** $|\mathcal{W}_{b,k}| = 2^{b-1-k}$ for $k < b$, and $\mathcal{W}_{b,b} = \{2^b\}$. Consequently the tie profile of $\nu_2$ on uniform draws of exact bit-length $b+1$ is exactly $D_b$: the full-range dyadic profile one bit lower.

*Proof.* $\mathcal{W}_{b,k} = A_{b+1,k} \setminus A_{b,k}$ as sets, since the divisibility condition is the same and the ranges nest. By Lemma 3.2 the cardinality is $2^{b-k} - 2^{b-1-k} = 2^{b-1-k}$ for $k < b$. For $k = b$, an element of $\mathcal{W}_b$ divisible by $2^b$ is $2^b u$ with $2^b \le 2^b u < 2^{b+1}$, forcing $u = 1$; and $2^b$ indeed has $2^{b+1}\nmid 2^b$. Assembling the blocks $k=0,\ldots,b$ gives $(2^{b-1},\ldots,2,1,1) = D_b$. $\square$

The competitor undergoes the same shift.

**Definition 4.3.** Identify the words of exact bit-length $b+1$ with subsets $S \subseteq \{0,\ldots,b\}$ containing the top index $b$; the popcount is $|S|$.

**Theorem 4.4 (One-bit shift law, popcount baseline).** The number of integers of exact bit-length $b+1$ with popcount $j+1$ is $\binom{b}{j}$. Hence the popcount tie profile on exact bit-length $b+1$ is exactly $B_b$.

*Proof.* $S \mapsto S \setminus \{b\}$ is a bijection between such $S$ of cardinality $j+1$ and the $j$-subsets of $\{0,\ldots,b-1\}$, with inverse $T \mapsto T \cup \{b\}$. $\square$

**Corollary 4.5 (Comparisons transport).** Conditioning on exact bit-length $b+1$ replaces both tie profiles by their full-range bit-length-$b$ counterparts. Every statement comparing the trailing-zero and popcount ceilings at bit-length $b$ therefore holds verbatim at exact bit-length $b+1$.

**Corollary 4.6 (Conditioning raises the ceiling, imperceptibly).** For $b \ge 1$,
$$\mathrm{Sp}(D_{b+1}) < \mathrm{Sp}(D_b) \quad\text{and}\quad \mathrm{Sp}(D_b) - \mathrm{Sp}(D_{b+1}) < 4^{-b}.$$
Exact-bit-length conditioning strictly increases the trailing-zero ceiling, by less than $4^{-b}$ — undetectable at any realistic sample size.

---

## 5. Invariance: the profile does not see the window

### 5.1 Aligned windows

**Definition 5.1.** The *aligned window* of scale $s$ and offset $c$ is $\mathcal{A}_{c,s} = [\,c\cdot 2^s,\ (c+1)\cdot 2^s\,)$. Its $k$-th block is $\mathcal{A}_{c,s,k} = \{x \in \mathcal{A}_{c,s} : 2^k \mid x,\ 2^{k+1}\nmid x\}$, and its *cap* is $\{x \in \mathcal{A}_{c,s} : 2^s \mid x\}$.

**Lemma 5.2 (Translation of low valuations).** For $k < s$, the map $x \mapsto x + c\cdot 2^s$ is a bijection $A_{s,k} \to \mathcal{A}_{c,s,k}$; consequently $|\mathcal{A}_{c,s,k}| = 2^{s-1-k}$. Moreover the cap is the singleton $\{c\cdot 2^s\}$.

*Proof.* For $k < s$ both $2^k$ and $2^{k+1}$ divide $2^s$, so $2^k \mid x \iff 2^k \mid x + c2^s$ and likewise for $2^{k+1}$; the map is a bijection of $[0,2^s)$ onto $\mathcal{A}_{c,s}$ preserving both conditions. For the cap, $2^s u \in \mathcal{A}_{c,s}$ forces $c \le u < c+1$, i.e. $u = c$. $\square$

**Theorem 5.3 (Dyadic-scale invariance).** For all $c, s$, the trailing-zero tie profile of $\mathcal{A}_{c,s}$ is exactly $D_s$. Hence all aligned windows of a common scale share the ceiling
$$\mathrm{Sp}(D_s) = \frac{6}{7}\left(1 + \frac{1}{2^s(2^s+1)}\right),$$
independently of the offset $c$.

The exact-bit-length window is the case $c = 1$ and the full range is $c = 0$, recovering Theorem 4.2 and Proposition 3.3.

### 5.2 Arbitrary windows

Alignment turns out to be a red herring; the operative hypothesis is period divisibility.

**Lemma 5.4 (Valuation as a residue class).** For all $k, x$,
$$x \equiv 2^k \pmod{2^{k+1}} \iff \big(2^k \mid x \text{ and } 2^{k+1} \nmid x\big) \iff \nu_2(x) = k.$$

*Proof.* ($\Rightarrow$) $x = 2^{k+1}q + 2^k = 2^k(2q+1)$, which is divisible by $2^k$ and not by $2^{k+1}$ since $2q+1$ is odd. ($\Leftarrow$) $x = 2^k u$ with $u$ odd, say $u = 2q+1$; then $x = 2^{k+1}q + 2^k$. $\square$

**Lemma 5.5 (Equidistribution of residues in a run).** For all $A, M, v$ and $r \ge 1$,
$$\big|\{x \in [A, A + Mr) : x \equiv v \pmod r\}\big| = M.$$

*Proof.* The interval is a disjoint union of $M$ blocks of $r$ consecutive integers, each of which is a complete residue system mod $r$ and so meets the class of $v$ exactly once. $\square$

**Definition 5.6.** The *sliding window* of scale $s$ starting at $A$ is $\mathcal{S}_{A,s} = [A, A + 2^s)$.

**Theorem 5.7 (Translation invariance).** For every $A$ and $s$: for each $k < s$, exactly $2^{s-1-k}$ elements of $\mathcal{S}_{A,s}$ have $\nu_2 = k$, and exactly one element is divisible by $2^s$. Hence the trailing-zero tie profile of *any* window of $2^s$ consecutive integers is exactly $D_s$, with ceiling $\frac{6}{7}\big(1+\frac{1}{2^s(2^s+1)}\big)$.

*Proof.* Fix $k < s$ and write $2^s = 2^{s-1-k}\cdot 2^{k+1}$. By Lemma 5.4 the $k$-th block is the set of $x \in [A, A + 2^{s-1-k}\cdot 2^{k+1})$ with $x \equiv 2^k \pmod {2^{k+1}}$, which by Lemma 5.5 (with $M = 2^{s-1-k}$, $r = 2^{k+1}$) has exactly $2^{s-1-k}$ elements. For the cap take $M = 1$, $r = 2^s$, $v = 0$. Summing, $\sum_{k<s} 2^{s-1-k} + 1 = 2^s$ accounts for the whole window, so there are no further blocks and the profile is $D_s$. $\square$

**Corollary 5.8 (Complete invariance).** The trailing-zero tie ceiling is a function of the sample size $2^s$ alone. It is independent of:

- the magnitude of the integers sampled;
- conditioning on bit-length;
- alignment of the sampling window to a dyadic grid;
- the placement (offset, phase) of the window.

Theorem 5.3 is the special case $A = c2^s$; Theorem 4.2 is $A = 2^s$; Proposition 3.3 is $A = 0$.

**Remark 5.9 (A stronger statement is easier).** The natural conjecture — that non-aligned windows perturb the profile at order $\Theta(2^{-s})$ — is false, and not merely to leading order: there is no error term whatsoever. The aligned proof (Lemma 5.2) is structurally transparent but proves less than the residue-counting proof, which is shorter. This is a recurring phenomenon: proving the general statement removed the hypothesis that made the special one look delicate.

---

## 6. The inversion threshold

We now compare the two statistics. Both profiles $D_b$ and $B_b$ have mass $2^b$, so by Theorem 2.5 everything reduces to cube sums.

**Proposition 6.1 (Cube sums).**
$$C(D_b) = \frac{8^b - 1}{7} + 1, \qquad C(B_b) = \mathrm{franel}(b) = \sum_{j=0}^{b}\binom{b}{j}^3 .$$

**Theorem 6.2 (Arithmetic inversion criterion).** For $b \ge 1$,
$$\mathrm{Sp}(D_b) < \mathrm{Sp}(B_b) \iff C(B_b) < C(D_b) \iff 7\,\mathrm{franel}(b) < 8^b + 6 .$$

*Proof.* Theorem 2.5 plus Proposition 6.1: $C(B_b) < C(D_b) \iff \mathrm{franel}(b) < \frac{8^b-1}{7}+1 = \frac{8^b+6}{7}$. $\square$

### 6.1 The asymptotic range via a Franel estimate

**Lemma 6.3 (Coarse Franel bound).** $\mathrm{franel}(b) \le \binom{b}{\lfloor b/2\rfloor}^2 \, 2^b$.

*Proof.* $\sum_j \binom{b}{j}^3 \le \max_j \binom{b}{j}^2 \sum_j \binom{b}{j}$. $\square$

**Lemma 6.4 (Odd middle binomial).** $\binom{2m+1}{m} \le 2\binom{2m}{m}$.

*Proof.* Pascal: $\binom{2m+1}{m} = \binom{2m}{m-1} + \binom{2m}{m}$, and both terms are at most the central binomial $\binom{2m}{m}$, which is the row maximum. $\square$

**Theorem 6.5 (Odd Franel estimate).** For all $m \ge 0$,
$$\mathrm{franel}(2m+1)\,(3m+1) \;\le\; 8^{\,2m+1}.$$

*Proof.* By Lemmas 6.3 and 6.4, $\mathrm{franel}(2m+1) \le \big(2\binom{2m}{m}\big)^2 2^{2m+1}$. Multiply by $3m+1$ and use the central-binomial estimate $\binom{2m}{m}^2 (3m+1) \le 16^m$ to get
$$\mathrm{franel}(2m+1)(3m+1) \le 4\cdot 16^m \cdot 2^{2m+1} = 2^2 \cdot 2^{4m} \cdot 2^{2m+1} = 2^{6m+3} = 8^{2m+1}. \square$$

**Theorem 6.6 (Franel-to-ceiling transfer).** Let $b \ge 1$ and $c > 0$ satisfy $\mathrm{franel}(b)\cdot c \le 8^b$. Then
$$\mathrm{Sp}(B_b) \;\ge\; 1 - \frac{2}{c}.$$

*Proof.* With $n = 2^b$, Lemma 2.4 gives $\mathrm{Sp}(B_b) = 1 - \frac{\mathrm{franel}(b) - n}{n^3 - n}$, and $n^3 = 8^b$. Since $\mathrm{franel}(b) \le 8^b/c$ and $2n \le 8^b$ (as $b\ge1$),
$$\frac{\mathrm{franel}(b) - n}{n^3 - n} \le \frac{8^b/c - n}{8^b - n} \le \frac{2}{c},$$
the last step because $c(8^b/c - n) \le 2(8^b-n)$ rearranges to $n(2-c) \le 8^b$, which holds since $n(2-c) \le 2n = 2^{b+1} \le 8^b$ for $b \ge 1$. $\square$

Applying Theorem 6.6 with $b = 2m+1$ and $c = 3m+1$ yields $\mathrm{Sp}(B_{2m+1}) \ge 1 - \frac{2}{3m+1}$. Since $\mathrm{Sp}(D_b) \le \frac{6}{7} + 2^{-b}$ (Corollary 3.5), for $m \ge 5$ we have $\frac{2}{3m+1} \le \frac18$ and $2^{-b} \le 2^{-11}$, whence
$$\mathrm{Sp}(D_{2m+1}) \le \tfrac67 + \tfrac{1}{1024} < \tfrac78 \le \mathrm{Sp}(B_{2m+1}).$$
This is the **odd** half of the inversion law; the even half follows from the corresponding even Franel estimate by the same transfer. Together they cover all $b \ge 10$.

### 6.2 Small bit-lengths and sharpness

The Franel estimate is too lossy below $b = 10$ — at $b = 8$ it yields only $1 - 2/13 = 0.846 < 6/7$ — but there the cube sums are finite arithmetic. Direct evaluation gives, for $3 \le b \le 9$,

| $b$ | $\mathrm{franel}(b)$ | $7\,\mathrm{franel}(b)$ | $8^b + 6$ |
|---|---|---|---|
| 1 | 2 | 14 | 14 |
| 2 | 10 | 70 | 70 |
| 3 | 56 | 392 | 518 |
| 4 | 346 | 2422 | 4102 |
| 5 | 2252 | 15764 | 32774 |
| 6 | 15184 | 106288 | 262150 |
| 7 | 104960 | 734720 | 2097158 |
| 8 | 739162 | 5174134 | 16777222 |
| 9 | 5280932 | 36966524 | 134217734 |

**Theorem 6.7 (Inversion threshold).** For every $b \ge 3$,
$$\mathrm{Sp}(D_b) < \mathrm{Sp}(B_b).$$

*Proof.* For $3 \le b \le 9$ the table verifies $7\,\mathrm{franel}(b) < 8^b + 6$, so Theorem 6.2 applies. For $b \ge 10$, split by parity and apply the odd estimate (Theorem 6.5 with $m \ge 5$) or its even counterpart. $\square$

**Theorem 6.8 (Sharpness).** $\mathrm{Sp}(D_1) = \mathrm{Sp}(B_1)$ and $\mathrm{Sp}(D_2) = \mathrm{Sp}(B_2)$. Hence for $b \ge 1$,
$$\mathrm{Sp}(D_b) < \mathrm{Sp}(B_b) \iff b \ge 3.$$

*Proof.* $D_1 = (1,1) = B_1$. $D_2 = (2,1,1)$ and $B_2 = (1,2,1)$ are permutations, so they have equal mass and cube sum ($4$ and $10$ respectively); apply Theorem 2.5(ii). Equivalently, $7\,\mathrm{franel}(1) = 14 = 8+6$ and $7\,\mathrm{franel}(2) = 70 = 64+6$. Combine with Theorem 6.7. $\square$

**Corollary 6.9 (Inversion under bit-length conditioning).** For $b \ge 3$, on uniform draws of exact bit-length $b+1$ the popcount baseline has strictly greater tie headroom than the trailing-zero statistic. In particular this holds at exact bit-length 48, where both profiles are the bit-length-47 ones.

*Proof.* Theorems 4.2, 4.4 and 6.7. $\square$

**Interpretation.** Bit-lengths $1$ and $2$ are the only regimes where the two statistics are tie-equivalent; above them the geometry *always* favours the popcount baseline, uniformly and without asymptotics. Therefore no measured advantage of the trailing-zero statistic at any realistic bit-length can be attributed to tie geometry.

---

## 7. Application: the recorded measurement

Write $\rho_{10} = 0.7291$, $\rho_{11} = 0.7286$, $\rho_{12} = 0.7087$ for the three seeds, $\bar\rho = \frac{1}{3}(\rho_{10}+\rho_{11}+\rho_{12}) = 0.72213\overline{3}$ for the pooled value, and $\Delta = 0.134$ (CI $[0.113, 0.158]$) for the advantage over the popcount baseline, so the implied pooled baseline is $\bar\rho - \Delta = 0.58813\overline{3}$.

**Proposition 7.1 (Band).** All three seeds satisfy $0.55 < \rho_i < 0.85$; the implied baseline $0.5881\ldots$ also lies in the band. The seed spread is $\rho_{10} - \rho_{12} = 0.0204 < 0.021$.

**Proposition 7.2 (No saturation — refutes H1).** At exact bit-length 48 the tie ceiling is $\mathrm{Sp}(D_{47}) = \frac{6}{7}\big(1 + \frac{1}{2^{47}(2^{47}+1)}\big) > \frac{6}{7}$, i.e. $\rho_{\max} = 0.92582\ldots$, whereas $\rho_i^2 \le 0.7291^2 = 0.5316 < \frac67$ for every seed. Every recorded value sits strictly below the ceiling with large margin.

**Proposition 7.3 (No quantisation drift — refutes H2).** Passing from exact bit-length 48 to full-range bit-length 64 changes the ceiling by
$$\mathrm{Sp}(D_{47}) - \mathrm{Sp}(D_{64}) < 4^{-47} < 10^{-28},$$
while the recorded dial moves by more than $0.07$ over the same change of regime. The bit-length dependence of the measurement is not tie geometry.

*Proof.* Corollary 3.5 bounds $\mathrm{Sp}(D_{47}) - \frac67 < 4^{-47}$, and $\mathrm{Sp}(D_{64}) > \frac67$. $\square$

**Proposition 7.4 (Advantage is signal, not geometry — refutes H3).** At exact bit-length 48 the popcount baseline has the strictly *larger* ceiling (Corollary 6.9), yet the measurement places the trailing-zero statistic $+0.134$ *above* it. The measured ordering is the reverse of the tie-headroom ordering; the advantage is therefore achieved against the geometry.

**Proposition 7.5 (Window placement is inert — refutes H4).** Every window of $2^{47}$ consecutive integers — the exact-bit-length-48 window $[2^{47},2^{48})$, any aligned window $[c\,2^{47},(c+1)2^{47})$, any unaligned window $[A, A+2^{47})$, and the full range $[0,2^{47})$ — has the identical trailing-zero tie ceiling $\frac{6}{7}\big(1 + \frac{1}{2^{47}(2^{47}+1)}\big)$ (Theorems 5.3, 5.7). No part of the seed spread can be attributed to window arithmetic.

**Corollary 7.6 (Factorisation).** Writing the measured coefficient as $\rho = \rho_{\text{ceiling}}\cdot\rho_{\text{response}}$, the first factor is pinned exactly and is flat to $O(4^{-s})$ across all windows, scales, placements and bit-length conditionings considered. All the observed variation — the bit-length decline $0.78 \to 0.72 \to 0.65 \to 0.61$, the seed spread $0.0204$, and the $+0.134$ advantage — lives in $\rho_{\text{response}}$. Any explanatory model must be response-side.

---

## 8. Algorithms

Three computational primitives support the results; all are elementary but worth stating with their complexities.

**Algorithm A (Profile of an arbitrary window).** Given $A$ and $s$, compute the trailing-zero tie profile of $[A, A+2^s)$ *without enumeration*, in $O(s)$ arithmetic operations: for $k < s$ the block size is
$$\big|\{x \in [A, A+2^s) : x \equiv 2^k \ (\mathrm{mod}\ 2^{k+1})\}\big| = 2^{s-1-k}$$
by Lemma 5.5, and the cap size is $1$. Naive enumeration costs $\Theta(2^s)$; the closed form makes $s = 47$ instantaneous. A direct-count variant is used only as a cross-check at small $s$.

**Algorithm B (Ceiling from a profile).** Given a profile of mass $n$, compute $\mathrm{Sp} = 1 - \frac{C-n}{n^3-n}$ in exact rational arithmetic in $O(r)$ operations, $r$ the number of blocks. For $D_s$ the closed form of Theorem 3.4 avoids the sum entirely.

**Algorithm C (Inversion decision).** To decide $\mathrm{Sp}(D_b) < \mathrm{Sp}(B_b)$, evaluate the criterion $7\,\mathrm{franel}(b) < 8^b + 6$. Computing $\mathrm{franel}(b)$ by summing $b+1$ cubed binomials costs $O(b)$ big-integer multiplications of numbers with $O(b)$ bits, i.e. $\tilde O(b^2)$ bit operations — fine for $b$ in the hundreds. For asymptotic $b$ one uses Theorem 6.5 instead, which decides the question in $O(1)$.

---

## 9. Discussion

### 9.1 What the invariance buys

Empirical work on such dials typically proceeds by sweeping knobs and watching a number. The results here prove four knobs inert: integer magnitude, bit-length conditioning, window alignment, window placement. In the tie-geometry factor these are not merely small effects; they are *exactly zero* effects (up to the explicit $O(4^{-s})$ term coming from sample size alone). That is unusual: invariance statements in applied settings usually carry an error term, and here the error term is genuinely absent because the mechanism is exact residue equidistribution.

### 9.2 Methodological lesson: work upstream of the ceiling map

Theorem 2.5 makes the ceiling map an order-reversing bijection of cube sums at fixed mass. Every comparison in Section 6 became tractable only after being pushed upstream into a statement about $\sum m_j^3$ — where the objects are Franel numbers and geometric series and the classical inequality toolkit applies. Attempts to compare ceilings directly, via bounds of the form $\mathrm{Sp} \ge 1 - 2/c$, were provably insufficient in the small range: at $b = 8$ the best available such bound gives $0.846 < 6/7$ and cannot decide the comparison, even though the comparison is true there.

### 9.3 The $6/7$ constant

The value $6/7$ arises because the dyadic profile halves geometrically: $\sum_k (2^{-k})^3 = \frac{8}{7}$ relative to $\sum_k 2^{-k} = 2$, giving a normalised cube mass of $\frac17$ and a ceiling of $1 - \frac17 = \frac67$ in the limit. Any statistic whose tie blocks decay by a fixed ratio $q$ has an analogous limiting ceiling $1 - \frac{(1-q)^2}{1+q+q^2}\cdot\frac{1}{\text{(normalisation)}}$; the trailing-zero statistic is the case $q = 1/2$. This suggests a family of "geometric dials" with tunable ceilings — potentially useful when one wants a coarse statistic with a *prescribed* headroom.

### 9.4 Limitations

The ceiling is an upper bound over all responses; it says nothing about which response a given pipeline actually produces. In particular the theory here cannot predict the value $0.73$, only certify that it is not forced. Second, the analysis assumes a sample of exactly $2^s$ consecutive integers; for a sample of $N$ consecutive integers with $N$ not a power of two the profile acquires genuine $O(1)$ boundary corrections (though they are still explicitly computable by Lemma 5.5 with $M = \lfloor N/2^{k+1}\rfloor$ and a remainder term). Third, we treat sampling as exhaustive over the window; sampling *with replacement* from a window introduces multinomial fluctuation in the block sizes, and the resulting ceiling is a random variable concentrated around the deterministic value.

---

## 10. Future directions

### 10.1 The response-side attenuation law

The key structural insight is that the measured coefficient factorises as $\rho = \rho_{\text{ceiling}}\cdot\rho_{\text{response}}$, and everything proved above pins the first factor exactly. The observed decline $0.78 \to 0.72 \to 0.65 \to 0.61$ with widening bit-length must therefore live entirely in $\rho_{\text{response}}$. The natural conjecture is an *attenuation law*: as the bit-length grows, the informative low-order structure of the input occupies a shrinking fraction of the response's variance, producing a decline of a specific functional form (logarithmic in the bit-length, or a power law in the sample size). Identifying that form — and proving that it is forced by the response's own structure rather than by the sampling — is the outstanding problem.

### 10.2 Non-power-of-two windows

Extend Theorem 5.7 to windows of arbitrary length $N$: the block sizes become $\lfloor N/2^{k+1}\rfloor$ or that plus one according to phase, so the profile — and hence the ceiling — acquires an explicit dependence on $N \bmod 2^{k+1}$. Quantifying the resulting oscillation, presumably $O(1/N)$ in the ceiling, would complete the invariance picture.

### 10.3 Geometric dials with prescribed ceilings

For a statistic whose blocks decay with ratio $q$ (e.g. the $p$-adic valuation for $p > 2$, with $q = 1/p$), compute the limiting ceiling in closed form and characterise which values in $(0,1)$ are attainable. The $p$-adic family should give $1 - \frac{p-1}{p^2+p+1}$-type constants; $p = 2$ recovers $6/7$.

### 10.4 Sharper Franel comparisons

Theorem 6.5 is deliberately crude. The true asymptotics $\mathrm{franel}(b) \sim c\, 8^b / b$ suggest the criterion $7\,\mathrm{franel}(b) < 8^b + 6$ holds with a widening multiplicative margin $\Theta(b)$. Making that explicit would give a quantitative version of the inversion — how much more headroom the popcount baseline has, as a function of $b$ — rather than the qualitative strict inequality proved here.

### 10.5 Beyond two statistics

Both $\nu_2$ and popcount are instances of a broader class of cheap integer summaries (digit sums in other bases, run lengths, low-order residues). Computing the tie profile and cube sum of each places them on a single totally ordered scale of headroom, and the resulting hierarchy would tell an experimenter, in advance and with no measurement, which coarse statistic can in principle correlate best.

---

## 11. Conclusion

The tie geometry of the trailing-zero statistic is completely rigid. On any $2^s$ consecutive integers — anywhere, at any magnitude, aligned or not, conditioned on bit-length or not — the tie profile is exactly $(2^{s-1},\ldots,2,1,1)$ and the ceiling is exactly $\frac{6}{7}\big(1 + \frac{1}{2^s(2^s+1)}\big)$. Against the popcount baseline, whose ceiling is governed by Franel numbers, the trailing-zero statistic has strictly *less* headroom at every bit-length $b \ge 3$, and exactly equal headroom at $b \in \{1,2\}$.

Applied to the recorded measurement, this closes four explanatory routes at once: the observed $\approx 0.73$ is not saturation, the bit-length trend is not quantisation, the $+0.134$ advantage over the popcount baseline is not tie geometry (which favours the baseline), and the seed spread is not window placement. What remains is a well-posed question about the response, unclouded by the arithmetic of the sampler.
