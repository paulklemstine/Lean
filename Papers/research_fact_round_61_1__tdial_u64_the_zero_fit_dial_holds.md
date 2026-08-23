# Exact Attenuation Ceilings for Spearman Rank Correlation under Tied Statistics, with Application to Zero-Count Dials at 64-Bit Word Length

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We develop an exact, closed-form theory of Spearman rank correlation between a
tied discrete statistic and a response, in the regime where one variable's tie
blocks refine the other's. The central result is the **tie-attenuation law**: if
a statistic is scored by midranks and its tied values form blocks of sizes
$m_1,\dots,m_g$ summing to $n$, then against *any* tie-refining response the
squared Spearman coefficient equals
$$\rho^2 = 1 - \frac{12\sum_j (m_j^3-m_j)}{n^3-n},$$
a quantity depending on the tie profile alone. We extend this to a **two-sided
law** for nested profiles, $\rho^2 = (V - T_{\mathrm{coarse}})/(V -
T_{\mathrm{fine}})$ with $V=(n^3-n)/12$, and prove the refinement monotonicity
$T_{\mathrm{fine}} \le T_{\mathrm{coarse}}$ that makes the coefficient
well-behaved.

Three exact ceilings follow. For the trailing-zero (2-adic valuation) statistic
of uniform $b$-bit draws, $\rho^2 = \frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right)$,
strictly decreasing in $b$ with limit $6/7$ and hence $\rho \to \sqrt{6/7} =
0.925820\ldots$. For the same statistic truncated at a cap $c$, $\rho^2 =
\frac{6}{7}\cdot\frac{8^b - 8^{b-c}}{8^b - 2^b}$, increasing in $c$ and never
below $3/4$. For a two-class response with $j$ positives and $k$ negatives
against a tie-free statistic, $\rho^2 = 3jk/((j+k)^2-1)$, asymptotically
$3q(1-q)$, with the universal binary ceiling $\rho \le \sqrt{3}/2 = 0.866025\ldots$.

We apply the theory to a recorded rank-correlation measurement at 64-bit word
length whose pooled value is $\rho = 0.648$ across three seeds. The dyadic
ceiling moves by less than $10^{-26}$ between word lengths $44$ and $64$, while
the observed reading falls by $0.188$ in $\rho^2$ over that range; the tie
granularity of the statistic is therefore excluded as an explanation by
twenty-four orders of magnitude. Truncation of the statistic is likewise
excluded, since every capped ceiling exceeds $3/4$ while the reading is
$\rho^2 = 0.419904$. What remains is response granularity, and the binary
ceiling calibrates it: a two-class response with base rate $16.83\%$ reproduces
the reading to $10^{-4}$, while any two-class response with minority mass at
least $25\%$ is excluded. This is a sharp, falsifiable prediction about the
response distribution, together with a hard cap of $\sqrt{3}/2$ on the
attainable correlation at any word length.

**Keywords:** Spearman rank correlation; midranks; Kendall tie correction; tie
attenuation; 2-adic valuation; binary response ceiling; measurement calibration.

---

## 1. Introduction

### 1.1 The empirical anomaly

Consider the following measurement protocol. Integers are drawn uniformly at
random from $\{0, 1, \dots, 2^b - 1\}$. For each draw, one records a *zero-count*
statistic $T$ — the number of trailing binary zeros, equivalently the 2-adic
valuation $v_2$ — and a downstream continuous *rate*. The Spearman rank
correlation between $T$ and the rate is then reported as a diagnostic "dial", to
be validated against a band $[0.55, 0.85]$.

Across a grid of word lengths this dial declines gently and monotonically: about
$0.78$ at $b = 44$, and at $b = 64$ the following readings across three
independent seeds:

| seed | Spearman$(T,\text{rate})$ |
|---|---|
| 20261140 | $0.658$ |
| 20261141 | $0.642$ |
| 20261142 | $0.643$ |
| pooled | $0.648$, CI $[0.629, 0.665]$ |

All four values lie strictly inside the validation band. Against a
pre-registered acceptance bar of baseline $+\,0.05$, with baseline $0.580$ (so
the bar is $0.630$), all three point estimates and the pooled point estimate
clear the bar, but the lower confidence limit $0.629$ improves on the baseline by
only $0.049$, missing the bar by $0.001$. The recorded verdict is therefore
*count parity*: the majority criterion passes, the strict interval criterion does
not.

Two questions arise. First, **why does the dial decline with word length?**
Second, **how should a "majority passes, pooled fails" verdict be interpreted?**
This paper answers the first exactly and bounds the second.

### 1.2 Contribution

The zero-count statistic is massively tied: half of all draws have $v_2 = 0$, a
quarter have $v_2 = 1$, and so on. The natural hypothesis is that the decline is
a *tie artefact*. We make this hypothesis quantitative by deriving the exact
maximum correlation attainable given a tie profile, and then refute it, along
with its two natural repairs.

The technical contributions are:

1. A closed-form **tie-attenuation law** (Theorem 3.4) for a midranked tied
   statistic against a tie-refining response, together with its equality case
   (Theorem 3.6).
2. The **exact dyadic ceiling** for the 2-adic valuation profile (Theorem 4.2),
   its strict monotonicity and limit (Theorems 4.3–4.4), and the arithmetic
   bridge showing that the profile really is the 2-adic block structure of
   $\{0,\dots,2^b-1\}$ (Proposition 4.1).
3. The **two-sided law** for nested profiles (Theorem 5.3), with the refinement
   monotonicity that underlies it (Theorem 5.4).
4. The **exact binary-response ceiling** (Theorem 6.1), the balanced case
   (Corollary 6.2), and the universal cap $\rho \le \sqrt{3}/2$.
5. The **exact truncation ceiling** (Theorem 7.1) and the resulting refutation
   of truncation as an explanation (Corollary 7.3).
6. The **calibration and exclusion** results for the recorded measurement
   (Section 8), and a general **majority-versus-pooled bound** for near-miss
   verdicts (Proposition 8.4).

---

## 2. Setup and definitions

Throughout, $n \ge 2$ is the sample size and all quantities are exact rationals.

**Definition 2.1 (Tie profile).** A *tie profile* is a finite list of positive
integers $L = (m_1, \dots, m_g)$ with $\sum_j m_j = n$, listing the sizes of the
blocks of equal values of a statistic, in increasing order of the statistic's
value.

**Definition 2.2 (Midranks).** Observations are laid out in a fixed order
compatible with the blocks: block $j$ occupies rank positions
$c_j+1, \dots, c_j+m_j$ where $c_j = m_1 + \dots + m_{j-1}$. The *raw ranks* are
$S = (1, 2, \dots, n)$; the *midrank* assigned to every member of block $j$ is
$$R_j = c_j + \frac{m_j+1}{2},$$
the arithmetic mean of the positions the block occupies.

**Definition 2.3 (Refining response).** A response *refines* the statistic if its
ordering is a linear extension of the block order that separates all
observations within each block — informally, the response distinguishes items the
statistic ties, and never contradicts the statistic across blocks. Under this
assumption the response's rank vector is precisely $S$.

**Definition 2.4 (Sums of squares and cross-products).** With grand mean
$\mu = (n+1)/2$, define
$$\mathrm{SS}_R = \sum_{i=1}^n (R_i - \mu)^2, \qquad
\mathrm{SS}_S = \sum_{i=1}^n (S_i - \mu)^2, \qquad
\mathrm{SP} = \sum_{i=1}^n (R_i - \mu)(S_i - \mu),$$
where $R_i$ is the midrank of the block containing observation $i$. These are
$n\operatorname{Var}(R)$, $n\operatorname{Var}(S)$ and $n\operatorname{Cov}(R,S)$
respectively.

**Definition 2.5 (Kendall tie correction).** For a tie profile $L$,
$$T(L) = \sum_j \frac{m_j^3 - m_j}{12}.$$
We write $V = V(n) = \dfrac{n^3-n}{12}$ for the total rank variability.

**Definition 2.6 (Spearman coefficient of a profile).** The squared Spearman
coefficient of a tie profile against a refining response is
$$\rho^2(L) = \frac{\mathrm{SP}^2}{\mathrm{SS}_R \cdot \mathrm{SS}_S},
\qquad \rho(L) = \sqrt{\rho^2(L)}.$$

Two elementary identities are used repeatedly:
$\sum_{t=0}^{m-1}(t+1) = m(m+1)/2$ and $\sum_{t=0}^{m-1}(t+1)^2 =
m(m+1)(2m+1)/6$.

---

## 3. The one-sided tie-attenuation law

The engine of the theory is a collapse identity: the midrank vector is the
conditional mean of the raw-rank vector given the block, so their covariance is
the variance of the midrank vector.

**Lemma 3.1 (Block identities).** Within a block of size $m$ occupying positions
$c+1, \dots, c+m$, the ranks centred at the block midrank $c + (m+1)/2$ sum to
zero and have sum of squares $(m^3-m)/12$.

*Proof sketch.* The centred values are $t + 1 - (m+1)/2$ for $t = 0,\dots,m-1$.
The first claim is the Gauss sum; the second is the sum-of-squares formula, and
$$\sum_{t=0}^{m-1}\left(t+1-\tfrac{m+1}{2}\right)^2
= \frac{m(m+1)(2m+1)}{6} - (m+1)\cdot\frac{m(m+1)}{2} + m\cdot\frac{(m+1)^2}{4}
= \frac{m^3-m}{12}. \square$$

**Theorem 3.2 (Midrank collapse identity).** For any grand mean $\mu$, any tie
profile $L$ and any starting offset, $\mathrm{SP} = \mathrm{SS}_R$.

*Proof sketch.* Work block by block. The contribution of block $j$ to
$\mathrm{SP}$ is $(R_j-\mu)\sum_{i \in j}(S_i - \mu)$. Writing
$S_i - \mu = (S_i - R_j) + (R_j - \mu)$ and applying the first part of Lemma 3.1,
the term $\sum_{i\in j}(S_i - R_j)$ vanishes, leaving $m_j (R_j - \mu)^2$, which
is exactly block $j$'s contribution to $\mathrm{SS}_R$. Summing over blocks gives
the identity. Probabilistically this is the tower property: $R = \mathbb{E}[S
\mid \text{block}]$, hence $\operatorname{Cov}(R,S) = \operatorname{Var}(R)$.
$\square$

**Theorem 3.3 (Tie decomposition).** $\mathrm{SS}_S = \mathrm{SS}_R + T(L)$.

*Proof sketch.* This is the parallel-axis (within/between) decomposition applied
block by block: for block $j$, $\sum_{i \in j}(S_i - \mu)^2 = m_j(R_j-\mu)^2 +
\sum_{i \in j}(S_i - R_j)^2$, and the second sum is $(m_j^3-m_j)/12$ by Lemma
3.1. Summing over blocks and using $\sum_j (m_j^3-m_j)/12 = T(L)$ completes the
proof. Taking $\mu = (n+1)/2$ and using $\mathrm{SS}_S = V$ gives
$\mathrm{SS}_R = V - T(L)$. $\square$

**Theorem 3.4 (Tie-attenuation law).** For any tie profile $L$ with
$n = \sum_j m_j \ge 2$,
$$\rho^2(L) = 1 - \frac{12\sum_j (m_j^3-m_j)}{n^3-n} = \frac{V - T(L)}{V}.$$

*Proof.* By Theorem 3.2, $\mathrm{SP} = \mathrm{SS}_R$, so
$\rho^2 = \mathrm{SS}_R^2/(\mathrm{SS}_R\,\mathrm{SS}_S) =
\mathrm{SS}_R/\mathrm{SS}_S$. By Theorem 3.3 and $\mathrm{SS}_S = V$, this is
$(V - T(L))/V$, and $V = (n^3-n)/12 \neq 0$ since $n \ge 2$. $\square$

**Corollary 3.5 (Range).** $0 \le \rho^2(L) \le 1$.

*Proof sketch.* Non-negativity is $\mathrm{SS}_R \ge 0$, a sum of squares.
Upper-boundedness is $T(L) \ge 0$, since each term $(m^3-m)/12$ is non-negative
for $m \ge 1$. $\square$

**Theorem 3.6 (Equality case).** For $n \ge 2$, $\rho(L) = 1$ if and only if
every block has size $1$, i.e. the statistic is tie-free.

*Proof sketch.* $\rho^2 = 1$ iff $T(L) = 0$. Each summand $(m^3-m)/12$ is $0$ for
$m \le 1$ and strictly positive for $m \ge 2$; a sum of non-negative terms
vanishes iff all vanish. $\square$

Theorem 3.4 has a striking feature: the right-hand side does not depend on the
response at all, only on the tie profile of the statistic. It is therefore a
*ceiling*: whatever the downstream variable is, provided it refines the blocks,
the correlation is pinned exactly. In the large-$n$ limit with class proportions
$p_j = m_j/n$, the law reads
$$\rho^2 \longrightarrow 1 - \sum_j p_j^3,$$
so a tie profile influences the ceiling only through its **third frequency
moment** (its cubic mass). This is the observation that organises everything that
follows.

---

## 4. The dyadic ceiling

**Proposition 4.1 (Arithmetic bridge).** For $k < b$, exactly $2^{\,b-1-k}$ of the
integers in $\{0,1,\dots,2^b-1\}$ have precisely $k$ trailing binary zeros; the
integer $0$ forms a block of its own. Hence the tie profile of the trailing-zero
statistic is
$$D_b = \left(2^{b-1},\, 2^{b-2},\, \dots,\, 2,\, 1,\, 1\right),$$
of total mass $\sum_{k=0}^{b-1} 2^{\,b-1-k} + 1 = 2^b$.

*Proof sketch.* An integer has exactly $k$ trailing zeros iff it is of the form
$2^k(2u+1)$; the odd multipliers $2u+1$ with $2^k(2u+1) < 2^b$ number exactly
$2^{\,b-1-k}$. Summing the geometric series and adding the singleton $\{0\}$
accounts for all $2^b$ integers. $\square$

**Theorem 4.2 (Exact dyadic ceiling).** For $b \ge 1$,
$$\rho^2(D_b) = \frac{6}{7}\left(1 + \frac{1}{2^b\left(2^b+1\right)}\right).$$

*Proof.* Write $x = 2^b = n$. The cubic mass is
$$\sum_j m_j^3 = \sum_{k=0}^{b-1} \left(2^{\,b-1-k}\right)^3 + 1
= \sum_{i=0}^{b-1} 8^{\,i} + 1 = \frac{x^3-1}{7} + 1,$$
using $8^{\,i} = (2^i)^3$ and the geometric sum $\sum_{i<b}8^i = (8^b-1)/7$ with
$8^b = x^3$. Hence by Theorem 3.4,
$$\rho^2 = 1 - \frac{\frac{x^3-1}{7} + 1 - x}{x^3-x}
= \frac{7(x^3-x) - x^3 + 1 - 7 + 7x}{7(x^3-x)}
= \frac{6(x^3-1)}{7(x^3-x)}
= \frac{6}{7}\cdot\frac{x^2+x+1}{x^2+x},$$
after cancelling $x-1$, and $\frac{x^2+x+1}{x^2+x} = 1 + \frac{1}{x(x+1)}$.
$\square$

**Theorem 4.3 (Strict monotonicity and limit).** For $1 \le b < c$,
$\rho^2(D_c) < \rho^2(D_b)$; moreover $\rho^2(D_b) > 6/7$ for all $b \ge 1$, with
$$\rho^2(D_b) - \frac{6}{7} < 4^{-b} \longrightarrow 0.$$
Consequently $\rho(D_b) \downarrow \sqrt{6/7} = 0.9258200\ldots$

*Proof sketch.* All three claims are immediate from Theorem 4.2: the correction
term $\frac{1}{2^b(2^b+1)}$ is positive and strictly decreasing in $b$, and
$\frac{6}{7}\cdot\frac{1}{2^b(2^b+1)} < \frac{1}{4^b}$ because
$4^b < 2^b(2^b+1)$. $\square$

**Theorem 4.4 (Tie-ceiling insufficiency).** Between $b = 44$ and $b = 64$ the
exact ceiling satisfies
$$0 < \rho^2(D_{44}) - \rho^2(D_{64}) < 10^{-26},$$
whereas the recorded dial falls from $0.78$ to $0.648$, i.e. by
$0.78^2 - 0.648^2 = 0.188496$ in squared units.

*Proof sketch.* Apply Theorem 4.3 with $4^{-44} < 10^{-26}$ and evaluate the
recorded numbers exactly. $\square$

Theorem 4.4 is the decisive negative result: the observed decline exceeds the
maximum possible movement of the tie ceiling by roughly twenty-four orders of
magnitude. **The decline of the dial is not a tie artefact of the zero-count
statistic.**

Numerically, $\rho(D_b)$ reads $0.948683$ at $b=2$, $0.932227$ at $b=3$,
$0.927520$ at $b=4$, $0.925827$ at $b=8$ and $0.9258200\ldots$ for every
$b \ge 16$ to ten decimal places.

---

## 5. Nested profiles: the two-sided law

Since the statistic is exonerated, suspicion moves to the response. We therefore
drop the assumption that the response is tie-free, retaining only *nesting*.

**Definition 5.1 (Nested profile).** A *nested profile* is a list of lists
$\mathcal{L} = (P_1, \dots, P_g)$ of positive integers. The *coarse* profile is
$\mathrm{co}(\mathcal{L}) = (\Sigma P_1, \dots, \Sigma P_g)$ (the statistic's
blocks) and the *fine* profile is the concatenation
$\mathrm{fi}(\mathcal{L}) = P_1 \frown \cdots \frown P_g$ (the response's
blocks). By construction the response's blocks refine the statistic's.

**Lemma 5.2 (Weighted midrank averaging).** Let a coarse block occupy positions
$c+1,\dots,c+M$ and be subdivided into fine blocks of sizes $p_1,\dots,p_r$ with
$\sum_i p_i = M$. Then the fine midranks, weighted by the fine block sizes,
average to the coarse midrank:
$$\sum_{i} p_i\left(c_i + \frac{p_i+1}{2}\right) = M\left(c + \frac{M+1}{2}\right),$$
where $c_i = c + p_1 + \cdots + p_{i-1}$.

*Proof sketch.* Induction on $r$; each step is the identity
$p(c + \frac{p+1}{2}) + \Sigma'(c + p + \frac{\Sigma'+1}{2}) =
(p+\Sigma')(c + \frac{p+\Sigma'+1}{2})$ with $\Sigma' = p_2+\cdots+p_r$, which
expands to a polynomial identity. $\square$

**Theorem 5.3 (Two-sided attenuation law).** For a nested profile
$\mathcal{L}$ with $n = \sum \mathrm{fi}(\mathcal{L}) \ge 2$ and
$V = (n^3-n)/12$,
$$\rho^2(\mathcal{L}) = \frac{V - T(\mathrm{co}(\mathcal{L}))}{V - T(\mathrm{fi}(\mathcal{L}))}.$$

*Proof.* By Lemma 5.2, the centred cross-product of the coarse midranks against
the fine midranks equals the *coarse* between-block sum of squares:
$\mathrm{SP} = \mathrm{SS}_R^{\mathrm{coarse}}$. (Within a coarse block, the
weighted average of the fine midranks is the coarse midrank, so all fine detail
cancels — this is again the tower property, now with a coarser conditioning
$\sigma$-algebra.) Consequently
$$\rho^2 = \frac{\left(\mathrm{SS}_R^{\mathrm{coarse}}\right)^2}
{\mathrm{SS}_R^{\mathrm{coarse}}\cdot \mathrm{SS}_R^{\mathrm{fine}}}
= \frac{\mathrm{SS}_R^{\mathrm{coarse}}}{\mathrm{SS}_R^{\mathrm{fine}}}.$$
Both profiles have the same total mass $n$ (concatenation and summation commute),
hence the same grand mean and the same total $\mathrm{SS}_S = V$. Applying
Theorem 3.3 to each profile gives $\mathrm{SS}_R^{\mathrm{coarse}} = V -
T(\mathrm{co})$ and $\mathrm{SS}_R^{\mathrm{fine}} = V - T(\mathrm{fi})$.
$\square$

**Theorem 5.4 (Refinement monotonicity).** For every nested profile,
$$T(\mathrm{fi}(\mathcal{L})) \le T(\mathrm{co}(\mathcal{L})).$$

*Proof.* The map $m \mapsto m^3 - m$ is superadditive on non-negative reals:
$(a^3-a)+(b^3-b) \le (a+b)^3-(a+b)$, since the difference is exactly
$3a^2b + 3ab^2 = 3ab(a+b) \ge 0$. Iterating over the parts of a
single coarse block gives $T(P) \le \frac{(\Sigma P)^3 - \Sigma P}{12}$; summing
over coarse blocks and using additivity of $T$ over concatenation yields the
claim. $\square$

**Corollary 5.5 (Range and the direction of attenuation).** For $n \ge 2$,
$0 \le \rho^2(\mathcal{L}) \le 1$, with equality on the right precisely when the
two profiles coincide (every coarse block being a single fine block). What
attenuates the coefficient is therefore the *mismatch* in granularity between
the two variables: with the statistic held fixed, refining the response lowers
the coefficient monotonically towards the one-sided floor
$(V - T_{\mathrm{coarse}})/V$, and the penalty is exactly the ordering detail
that the coarser variable cannot track.

**Corollary 5.6 (Consistency).** If the fine profile is tie-free (all $p_i = 1$),
then $T(\mathrm{fi}) = 0$ and Theorem 5.3 reduces to Theorem 3.4.

---

## 6. The binary-response ceiling

The extreme case of a coarse response is a two-class variable.

**Theorem 6.1 (Exact binary ceiling).** A two-class response with $j \ge 1$
positives and $k \ge 1$ negatives, measured against a tie-free statistic,
attains exactly
$$\rho^2 = \frac{3jk}{(j+k)^2 - 1}.$$

*Proof.* Apply Theorem 3.4 to the two-block profile $(j,k)$ with $n = j+k \ge 2$:
$$\rho^2 = 1 - \frac{(j^3-j)+(k^3-k)}{(j+k)^3-(j+k)}
= \frac{(j+k)^3 - (j+k) - j^3 + j - k^3 + k}{(j+k)^3-(j+k)}
= \frac{3jk(j+k)}{(j+k)\left((j+k)^2-1\right)},$$
using $(j+k)^3 - j^3 - k^3 = 3jk(j+k)$; cancel the factor $j+k > 0$. $\square$

Writing $q = j/(j+k)$ for the base rate and $n = j+k$, Theorem 6.1 gives
$$\rho^2 = \frac{3q(1-q)}{1 - n^{-2}} \longrightarrow 3q(1-q),
\qquad \rho \longrightarrow \sqrt{3q(1-q)}.$$

**Corollary 6.2 (Balanced ceiling).** For $j = k \ge 1$,
$$\rho^2 = \frac{3j^2}{4j^2-1} > \frac{3}{4},$$
and $\rho^2 \downarrow 3/4$ as $j \to \infty$, so $\rho \to \sqrt{3}/2 =
0.8660254\ldots$

**Corollary 6.3 (Universal binary cap).** No binary response can achieve a
Spearman correlation above $\sqrt{3}/2$ against any statistic, at any sample
size, other than in the degenerate case $j = k = 1$. Indeed for $j+k \ge 3$ the
coefficient is strictly below $1$, and $3q(1-q) \le 3/4$ for all $q \in [0,1]$
with equality only at $q = 1/2$.

This is a striking practical fact: a dichotomous outcome caps a rank correlation
at $0.866$ *before any data are collected*, and much lower if the classes are
unbalanced. At $q = 0.1$, the cap is already $\sqrt{0.27} = 0.5196$.

---

## 7. Truncated statistics

The last "blame the statistic" escape route is truncation: real instrumentation
may cap the zero-count at $c$, merging all draws with $v_2 \ge c$ (and the draw
$0$) into a single terminal block. Merged blocks destroy rank variance
cubically, so one might hope a small cap explains a low reading.

**Definition.** The capped profile at bit length $b$ and cap $1 \le c \le b$ is
$$C_{b,c} = \left(2^{b-1},\, 2^{b-2},\, \dots,\, 2^{\,b-c},\, 2^{\,b-c}\right),$$
of total mass $2^b$: the first $c$ blocks are the exact zero-count classes
$0,1,\dots,c-1$, and the terminal block of size $2^{\,b-c}$ collects the rest.

**Theorem 7.1 (Exact truncation ceiling).** For $1 \le c \le b$,
$$\rho^2(C_{b,c}) = \frac{6}{7}\cdot\frac{8^{\,b} - 8^{\,b-c}}{8^{\,b} - 2^{\,b}}.$$

*Proof sketch.* The cubic mass is $\sum_{i=1}^{c} 8^{\,b-i} + 8^{\,b-c} =
\frac{8^b - 8^{\,b-c}}{7} + 8^{\,b-c}$ by the finite geometric sum, and the
linear mass is $2^b$. Substituting into Theorem 3.4 with $n = 2^b$, $n^3 = 8^b$
and simplifying gives the stated rational function. $\square$

**Theorem 7.2 (Monotone in the cap, bounded below).** $\rho^2(C_{b,c})$ is
increasing in $c$ and satisfies
$$\rho^2(C_{b,c}) \ge \rho^2(C_{b,1}) = \frac{3}{4}\cdot\frac{4^b}{4^b - 1} > \frac{3}{4}$$
for every $b \ge 1$ and $1 \le c \le b$.

*Proof sketch.* Monotonicity is clear since $8^{\,b-c}$ decreases in $c$ and the
denominator is constant. Setting $c=1$ gives
$\frac{6}{7}\cdot\frac{8^b-8^{b-1}}{8^b-2^b} = \frac{6}{7}\cdot\frac{7\cdot
8^{b-1}}{8^b - 2^b} = \frac{6 \cdot 8^{b-1}}{8^b-2^b}$, which equals
$\frac{3}{4}\cdot\frac{4^b}{4^b-1}$ after dividing numerator and denominator by
$2^b$. $\square$

**Corollary 7.3 (No truncation explains the reading).** Since the recorded pooled
value is $\rho^2 = 0.648^2 = 0.419904 < 3/4$, no truncated zero-count statistic,
at any cap and any bit length, can produce it.

**Consistency.** At $c = b$, Theorem 7.1 returns $\frac{6}{7}\cdot\frac{8^b -
1}{8^b - 2^b}$, exactly the dyadic ceiling of Theorem 4.2. At $c = 1$, the capped
profile is the even/odd split $(2^{b-1}, 2^{b-1})$ and Theorem 7.1 returns the
balanced binary value $3j^2/(4j^2-1)$ of Corollary 6.2 with $j = 2^{b-1}$. The
three developments — dyadic, binary, capped — are mutually consistent, which is
a meaningful internal check on the algebra.

---

## 8. Application: calibrating the 64-bit reading

We now apply the theory to the measurement of Section 1.1. Write
$\hat\rho = 0.648$, so $\hat\rho^2 = 0.419904$.

**Proposition 8.1 (Band and ceiling placement).** All four recorded readings lie
strictly inside $[0.55, 0.85]$; the mean of the three seeds is
$0.6476\overline{6}$, within $5\times10^{-4}$ of the pooled value; and every
reading lies strictly below the exact dyadic ceiling at $b = 64$, whose value is
$\rho = 0.9258200\ldots$

**Proposition 8.2 (Binary calibration).** The two-class profile with $1683$
positives per $10\,000$ observations — base rate $16.83\%$ — satisfies
$$\left|\,\rho^2(1683,\,8317) - \hat\rho^2\,\right| < 10^{-4}.$$

*Proof.* By Theorem 6.1, $\rho^2 = \frac{3\cdot1683\cdot8317}{10000^2-1} =
0.4199254\ldots$, and $\hat\rho^2 = 0.419904$. $\square$

Equivalently, solving $3q(1-q) = 0.419904$ yields $q = 0.16828\ldots$ (or its
reflection $0.83172$).

**Proposition 8.3 (Exclusion).** Let a two-class response have $j \le k$ with
$j + k \le 4j$, i.e. minority mass at least $25\%$. Then
$$\rho^2 \ge \frac{9}{16} = 0.5625 > 0.419904 = \hat\rho^2.$$

*Proof sketch.* By Theorem 6.1 it suffices to show $3jk \ge \frac{9}{16}
((j+k)^2-1)$ under $j \le k \le 3j$. Writing $k = \lambda j$ with $1 \le \lambda
\le 3$, the inequality $3\lambda \ge \frac{9}{16}(1+\lambda)^2$ holds throughout
$[1,3]$, with equality at the endpoints $\lambda = 1/3, 3$; the $-1$ in the
denominator only helps. $\square$

Together, Propositions 8.2 and 8.3 make the response-granularity hypothesis
**falsifiable**: if the decline of the dial is caused by coarseness of the rate
variable, then at 64 bits the rate is effectively a two-class variable with
minority mass near $17\%$, and any measured minority mass of $25\%$ or more
refutes the hypothesis outright.

Finally, we bound the near-miss verdict.

**Proposition 8.4 (Majority-versus-pooled bound).** Let three readings
$a, b, c$ satisfy $b, c \ge \tau$ and $a \ge \ell$. Then the pooled (mean)
reading satisfies
$$\frac{a+b+c}{3} \ge \tau - \frac{\tau-\ell}{3}.$$

*Proof.* $\frac{a+b+c}{3} \ge \frac{\ell + 2\tau}{3} = \tau -
\frac{\tau-\ell}{3}$. $\square$

**Corollary 8.5.** With bar $\tau = 0.63$ and band floor $\ell = 0.55$, a
"majority passes" configuration forces the pooled value to be at least
$0.6033\overline{3}$; the observed pooled value was $0.648$. Hence a *count
parity* verdict — majority passes, strict interval criterion fails — is confined
to a window of width $(\tau-\ell)/3 \approx 0.027$ and can never signal gross
discordance between the seeds. Here the shortfall is one part in a thousand: the
lower confidence limit $0.629$ improves on the baseline $0.580$ by $0.049$
against a required $0.050$.

---

## 9. Algorithms

All quantities in this paper are computable exactly in rational arithmetic; the
algorithms are short, and we record them for completeness.

**Algorithm A (Attenuation coefficient of a tie profile).** Input a profile
$(m_1,\dots,m_g)$; output $\rho^2$.

1. $n \leftarrow \sum_j m_j$; if $n < 2$, reject.
2. $T \leftarrow \sum_j (m_j^3 - m_j)/12$ (exact rationals or big integers).
3. Return $1 - 12T/(n^3-n)$.

Cost: $O(g)$ arithmetic operations, $O(\log n)$ bits per operation for
fixed-width inputs. Compare with the naive $O(n)$ construction of the full rank
vectors and their covariance — a decisive saving when $n = 2^{64}$.

**Algorithm B (Nested coefficient).** Input a nested profile $(P_1,\dots,P_g)$.
Compute $\mathrm{fi} = P_1 \frown \cdots \frown P_g$, $\mathrm{co} = (\Sigma
P_1,\dots,\Sigma P_g)$, $n = \Sigma\,\mathrm{fi}$, $V = (n^3-n)/12$, and return
$(V - T(\mathrm{co}))/(V - T(\mathrm{fi}))$. Cost $O(|\mathrm{fi}|)$.

**Algorithm C (Base-rate inversion / calibration).** Given a target $\rho^2 = r$
with $0 < r \le 3/4$, solve $3q(1-q) = r$:
$$q = \frac{1 \pm \sqrt{1 - 4r/3}}{2}.$$
The two roots are reflections $q \leftrightarrow 1-q$ and give the same ceiling.
If $r > 3/4$, report *infeasible*: no binary response can produce the reading.
Cost $O(1)$. Applied to $r = 0.419904$ this returns $q = 0.16828\ldots$

**Algorithm D (Exact ceiling table for dyadic and capped profiles).** For a bit
length $b$ and cap $c$, return $\frac{6}{7}(8^b - 8^{\,b-c})/(8^b - 2^b)$ in
exact rational arithmetic, reducing to $\frac{6}{7}(1 + 1/(2^b(2^b+1)))$ at
$c = b$. Cost: $O(b)$ bit operations for the powers, $O(M(b))$ for the exact
division.

---

## 10. Discussion

### 10.1 What the theory says about measurement design

The tie-attenuation law converts a vague methodological worry ("ties depress
correlations") into an exact budget. Since the ceiling depends on the profile
only through $\sum_j p_j^3$ in the large-sample limit, every family of tie
structures collapses to a one-parameter curve indexed by its **third frequency
moment**. Some values worth internalising:

| response / statistic structure | limiting $\rho^2$ | limiting $\rho$ |
|---|---|---|
| tie-free | $1$ | $1$ |
| dyadic (geometric, ratio $1/2$) | $6/7 = 0.857143$ | $0.925820$ |
| capped zero-count, cap $c$ | $\frac{6}{7}(1 - 8^{-c})$ | $\ge 0.866$ |
| balanced binary | $3/4$ | $0.866025$ |
| binary, base rate $q$ | $3q(1-q)$ | $\sqrt{3q(1-q)}$ |
| binary, $q = 0.1683$ | $0.419925$ | $0.648$ |

The last two rows are the operational content of this paper: a reading of
$0.648$ is *not* a weak association if the response is a $17\%$-prevalence
dichotomy — it is, in that case, essentially the maximum attainable. Reporting a
rank correlation without its structural ceiling is like reporting a signal
without a noise floor.

### 10.2 The status of the anomaly

Three explanations of the observed decline were considered and their fates are
now exact:

1. **Tie granularity of the zero-count.** Refuted (Theorem 4.4): the ceiling is
   flat to within $10^{-26}$ across the range where the reading falls by
   $0.188$.
2. **Truncation of the zero-count.** Refuted (Corollary 7.3): every capped
   ceiling exceeds $3/4$, while the reading is $0.419904$.
3. **Response granularity.** Not refuted, and now *quantified*: it predicts a
   minority mass near $17\%$ and excludes minority masses at or above $25\%$
   (Propositions 8.2–8.3).

The elimination of (1) and (2) is not a null result — it is the substance. Both
were the natural hypotheses; both are now closed by exact computation rather than
by simulation.

### 10.3 Limitations

The theory assumes *nesting*: the response's blocks refine the statistic's (or,
one-sidedly, that the response is tie-refining). Real measurements can violate
this, with the two partitions crossing. In the crossing case the collapse
identity fails — the covariance no longer reduces to a variance — and the
coefficient depends on the joint arrangement, not only on the two marginal
profiles. Second, the ceilings are attained only when the response is *perfectly*
informative given the blocks; a real reading below its ceiling mixes structural
attenuation with genuine noise, and these two contributions are not separated
here. Third, the calibration in Section 8 is an identification statement under an
explicitly binary reading of the response; a three-class or continuous-but-coarse
response would give a different, though computable, base-rate solution.

---

## 11. Future directions

Two research cycles were run on the anomalous 64-bit reading, and a third closed
the last "blame the statistic" route.

**Cycle 1** produced the tie-attenuation law: for a tied statistic scored by
midranks against any tie-refining response, $\rho^2 = 1 - 12\sum_j(m_j^3 -
m_j)/(n^3-n)$ — a quantity depending only on the tie profile. Specialised to the
2-adic profile of uniform $b$-bit draws it gives the exact ceiling
$\rho^2 = \frac{6}{7}(1 + 1/(2^b(2^b+1)))$, strictly decreasing in $b$ with limit
$6/7$ ($\rho \to \sqrt{6/7} \approx 0.92582$). The decisive negative consequence
is that from bit length $44$ to $64$ the ceiling can drop by less than
$10^{-26}$, while the recorded dial drops by $0.188$ in $\rho^2$: the decline is
not a tie artefact of the zero-count statistic.

**Cycle 2** moved the suspicion to the response and proved the two-sided law for
nested profiles, $\rho^2 = (V - T_{\mathrm{coarse}})/(V - T_{\mathrm{fine}})$
with $V = (n^3-n)/12$, plus the exact binary-response ceiling
$\rho^2 = 3jk/((j+k)^2-1)$ (asymptotically $\sqrt{3q(1-q)}$, maximum
$\sqrt{3}/2 \approx 0.866$). Under the binary reading, $0.648$ pins the
response's base rate to $\approx 16.8\%$, and any response with minority mass
$\ge 25\%$ is excluded.

**Cycle 3** tested truncation of the zero-count at a cap $c$ and closed it: the
capped ceiling is exactly $\rho^2 = \frac{6}{7}(8^b - 8^{\,b-c})/(8^b - 2^b)$,
increasing in $c$ and never below $3/4$, so no cap reproduces $\rho^2 =
0.419904$. The cap-$1$ case reproduces the balanced two-class value of cycle 2
and the cap-$b$ case the dyadic ceiling of cycle 1, so the three cycles are
mutually consistent.

The next targets are the following.

**D1. Geometric-response attenuation spectrum.** *Conjecture.* For a response
whose class masses follow a geometric law with ratio $r$ ($p_i \propto r^i$),
the attenuation ceiling converges, as $n \to \infty$, to a rational function of
$r$ alone — of the shape
$\rho^2(r) = 1 - \frac{(1-r)^3}{1-r^3}\cdot\frac{1+r+r^2}{(1+r)^2}$ — and
$\rho^2$ is strictly decreasing in the response's Simpson index $\sum_i p_i^2$.
The key insight is that the tie-attenuation law depends on the profile only
through the cubic mass $\sum_i p_i^3$, so every response family collapses to a
one-parameter curve indexed by its third frequency moment — a genuine "dial
calibration curve". This is within reach now because the two-sided law already
reduces the whole question to comparing two cubic masses; only an asymptotic
evaluation of $\sum_i p_i^3$ for the geometric family remains, and that is a
closed-form geometric series.

**D2. Crossing (non-nested) statistic–response pairs.** *Conjecture.* Drop the
nesting assumption and let the statistic's blocks and the response's blocks
cross. Then the coefficient is no longer a function of the two marginal profiles
alone, but should satisfy sharp bounds in terms of them: the nested value should
be extremal, with the crossing configurations filling an interval whose endpoints
are computable from the two profiles and the coupling. Establishing the extremal
property of nesting, and identifying the minimiser, would complete the theory.

**D5. Separating structural attenuation from noise.** A reading below its
structural ceiling reflects both coarseness and genuine imperfection of the
association. A decomposition $\rho_{\mathrm{obs}} = \rho_{\mathrm{ceiling}}
\cdot \kappa$ with an interpretable, estimable $\kappa \in [0,1]$ — a "purity"
coefficient — would make ceilings directly usable as a reporting standard for
rank correlations against coarse responses.

---

## 12. Conclusion

The exact tie-attenuation law and its two-sided extension convert questions
about rank correlations under ties from simulation problems into closed-form
arithmetic. Applied to the 64-bit zero-count measurement, they eliminate the two
leading explanations of the observed decline with margins of twenty-four orders
of magnitude and of a factor near two respectively, and replace them with a
sharp, testable prediction about the coarseness of the response, together with a
hard universal cap of $\sqrt{3}/2$ on any rank correlation against a
dichotomous outcome. The general lesson is methodological: before asking why a
correlation is small, compute how large it was allowed to be.
