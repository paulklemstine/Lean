# Capped Valuation Dials, Corruption Budgets, and the Erosion of a Rank Diagnostic

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study a rank-correlation diagnostic — the *zero-fit dial* — that measures the Spearman
correlation $\rho$ between the $2$-adic valuation $T(x) = v_2(x)$ of uniformly drawn
$b$-bit integers and a downstream numerical response. Across five experiments the dial
reads $0.780,\ 0.705,\ 0.648,\ 0.608$ at bit-widths $b = 44, 52, 64, 76$, and
$0.563 / 0.556$ on two seeds at $b = 92$, the last essentially at the validation floor
$0.55$. We ask what mechanism can produce this monotone erosion, and we answer with exact
combinatorics rather than with statistics.

First, we compute the exact Spearman tie ceiling of the *$K$-capped* valuation
$\min(v_2(x),K)$: for $b = r + K \geq 1$,
$$\rho^2_{\max} = \frac{6}{7}\cdot\frac{8^b - 8^r}{8^b - 2^b} = \frac{6}{7}\cdot\frac{1-8^{-K}}{1-4^{-b}}.$$
This *capped resolution law* interpolates between $0$ (no resolution) and the dyadic
ceiling $\frac67\bigl(1+\frac{1}{2^b(2^b+1)}\bigr)$ (full resolution), is strictly
increasing in the cap depth at fixed bit-width, and — decisively — never drops below $3/4$
for any $K \geq 1$ and any $b$. Since the recorded readings satisfy $\rho^2 \leq 0.317$,
**coarse resolution is excluded as a mechanism**. A quantitative companion statement shows
that the entire exact tie-geometry budget between $b = 52$ and $b = 92$ is below $10^{-15}$,
against a measured drop exceeding $0.14$.

Second, we convert readings into *corruption budgets*. Using a Lipschitz estimate for
Spearman correlation under partial re-ranking, we show that a reading $\rho$ forces any
rank-level mechanism to displace at least a fraction $(1-\rho)/6$ of the sample: more than
$7.28\%$ at $b = 92$, against under $4.92\%$ at $b = 52$. The converse holds as well: a
mechanism touching at most $3/40$ of the sample cannot push the reading below $0.55$.
Hence **the validation floor $0.55$ is exactly the $7.5\%$ corruption budget**.

Third, we fit a hyperbolic erosion law $\rho(b) = \frac{5}{14} + \frac{93}{5b}$, which
reproduces all five recorded readings to within $1/100$, decreases strictly to the
sub-floor asymptote $5/14$, and crosses the floor sharply between $b = 96$ and $b = 97$.
Along this law the forced displacement equals $\frac{3}{28} - \frac{31}{10b}$, saturating
strictly below $3/28$, and band exit occurs exactly when the displacement passes $3/40$.

Fourth, we generalise the entire capped theory to arbitrary base $p \geq 2$, obtaining
$\rho^2_{\max} = L(p)\,(p^{3b}-p^{3r})/(p^{3b}-p^b)$ with $L(p) = 3p/(p^2+p+1)$, and a
base-independent universal capped floor $L(p)(1-p^{-3})$. Defining the *effective base* of
a reading as the unique $p$ with $L(p+1) < \rho^2 \le L(p)$, we show that erosion is base
drift: the effective base is below $7$ at $b = 76$, exactly $8$ at $b = 92$, and — under the
hyperbolic law — bounded forever strictly between $22$ and $23$.

**Keywords.** Spearman rank correlation, tie correction, $p$-adic valuation, rank
perturbation bounds, diagnostic erosion, hyperbolic fit.

---

## 1. Introduction

### 1.1 The diagnostic

Fix a bit-width $b$ and draw integers uniformly from $\{0, 1, \dots, 2^b - 1\}$. For each
draw $x$ a computational pipeline produces a real-valued outcome, the *rate*. The
diagnostic under study, the **zero-fit dial**, is the Spearman rank correlation

$$\rho \;=\; \operatorname{Spearman}\bigl(T, \text{rate}\bigr), \qquad T(x) = v_2(x),$$

where $v_2(x)$ is the $2$-adic valuation, i.e. the number of trailing zeros in the binary
expansion of $x$ (with the convention $v_2(0) = b$ for $b$-bit draws, a boundary case that
affects a single element and none of the estimates below). The dial's *validation band* is
$[0.55, 0.85]$; readings below $0.55$ are declared uninformative.

The motivating rationale is that a pipeline manipulating machine integers inherits the
$2$-adic structure of its inputs, so a strong monotone relationship between trailing zeros
and downstream behaviour indicates that the pipeline is genuinely tracking arithmetic
structure.

### 1.2 The data

| bit-width $b$ | 44 | 52 | 64 | 76 | 92 |
|---|---|---|---|---|---|
| $\rho$ | $0.780$ | $0.705$ | $0.648$ | $0.608$ | $0.563$, $0.556$ |

At $b = 92$ two seeds completed; a third was not measured. Write
$\rho_{10} = 0.563$, $\rho_{11} = 0.556$ and $\bar\rho_{92} = (\rho_{10}+\rho_{11})/2 = 0.5595$.

**Proposition 1.1 (At the floor).** *We have*
$$0.55 \le \rho_{11} \le \rho_{10} \le 0.85, \qquad \rho_{10} - 0.55 \le 0.013, \qquad \bar\rho_{92} - 0.55 \le 0.01 .$$

*Proof.* Direct arithmetic on the recorded rationals. $\square$

Both seeds lie inside the band, but within $0.013$ of its floor: the dial has reached the
bottom of its scale after a monotone slide across four experiments.

### 1.3 What has to be explained

Two questions are forced by the measurement.

1. **Is the erosion an artefact of the instrument?** Perhaps the statistic resolves only
   the first $K$ levels of the valuation, merging all deeper draws into one tie class. Ties
   depress rank correlation, and depress it in an exactly computable way. Section 3
   computes the corresponding ceiling and excludes the mechanism.
2. **What does the reading cost in rank displacement?** Section 5 converts readings into
   two-sided statements about the fraction of the sample a rank-level mechanism must touch,
   and identifies the validation floor with a $7.5\%$ displacement budget.

Sections 6 and 7 fit the erosion trend and reinterpret it as a drift of the dial's
effective arithmetic base.

---

## 2. Preliminaries: tie profiles and the Spearman ceiling

### 2.1 Tie profiles

**Definition 2.1 (Tie profile).** Let a statistic $S$ take values on a finite sample of size
$n$, partitioning it into classes of equal value of sizes $m_1, \dots, m_J$ with
$\sum_j m_j = n$. The multiset $\{m_1,\dots,m_J\}$ (recorded here as a list) is the
**tie profile** of $S$.

**Definition 2.2 (Tie correction).** For a profile $L = (m_1,\dots,m_J)$ put
$$\operatorname{tie}(L) \;=\; \frac{1}{12}\sum_{j=1}^{J}\bigl(m_j^3 - m_j\bigr).$$
This is the classical Spearman tie-correction term. Note $\operatorname{tie}$ is additive
over concatenation of profiles and vanishes on the empty profile and on profiles of
singletons.

### 2.2 The ceiling

**Definition 2.3 (Spearman ceiling).** For a profile $L$ of total mass $n = \sum_j m_j \ge 2$
set
$$\sigma^2(L) \;=\; 1 - \frac{12\,\operatorname{tie}(L)}{n^3 - n} \;=\; 1 - \frac{\sum_j (m_j^3 - m_j)}{n^3-n}.$$

The quantity $\sigma^2(L)$ is the classical **maximum attainable squared Spearman
correlation** between a statistic with tie profile $L$ and a perfectly co-monotone
untied response. It is a purely combinatorial ceiling: no property of the response can push
the reading above it. Two profiles with the same total mass and the same tie correction have
the same ceiling; we use this congruence repeatedly to replace an "arithmetic" profile by a
convenient "geometric" one.

Two elementary facts will be used without further comment: $n^3 - n > 0$ for $n \ge 2$, and
for $b \ge 1$ one has $8^b - 2^b > 0$, which is the statement that the Spearman denominator
at $n = 2^b$ is positive.

### 2.3 The uncapped dyadic profile

On uniform $b$-bit draws the exact $2$-adic valuation classes are
$$\bigl|\{x < 2^b : v_2(x) = k\}\bigr| = 2^{\,b-1-k} \quad (0 \le k < b),$$
together with the single element $x = 0$. The tie profile is therefore
$(2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$, and summing the geometric series of cubes gives the
**dyadic ceiling**
$$\sigma^2 \;=\; \frac{6}{7}\Bigl(1 + \frac{1}{2^b(2^b+1)}\Bigr),$$
which converges to $6/7 \approx 0.857$ with astronomical speed. This is the ceiling a
perfect binary-valuation dial could read.

---

## 3. The capped resolution law

### 3.1 The capped profile

**Definition 3.1 (Capped statistic and capped profile).** For a cap depth $K \ge 0$ the
**$K$-capped valuation** is $T_K(x) = \min(v_2(x), K)$. On draws from
$\{0,\dots,2^{r+K}-1\}$, writing $b = r + K$, its tie profile is
$$\mathrm{CB}(K,r) \;=\; \bigl(2^{r},\; 2^{r},\, 2^{r+1},\, \dots,\, 2^{r+K-1}\bigr),$$
i.e. one merged top class of size $2^r$ (all $x$ with $v_2(x) \ge K$, equivalently all
multiples of $2^K$ below $2^b$) together with the $K$ resolved classes of sizes
$2^{r}, 2^{r+1}, \dots, 2^{b-1}$.

**Lemma 3.2 (Mass).** $\sum \mathrm{CB}(K,r) = 2^{\,r+K}$.

*Proof.* Induction on $K$, using $2^{r+K} + 2^{r+K} = 2^{r+K+1}$ at the inductive step. $\square$

**Lemma 3.3 (Exact tie correction).**
$$12\,\operatorname{tie}\bigl(\mathrm{CB}(K,r)\bigr) \;=\; \frac{8^{r}\bigl(8^{K}+6\bigr)}{7} \;-\; 2^{\,r+K}.$$

*Proof.* Induction on $K$. The base case $K = 0$ is the single block $2^r$, for which
$12\operatorname{tie} = 8^r - 2^r$, matching the right-hand side. For the step, append the
block $2^{r+K}$, whose contribution is $8^{r+K} - 2^{r+K}$, and use additivity of
$\operatorname{tie}$ together with $8^{r+K} = 8^r 8^K$ and $2^{r+K+1} = 2\cdot 2^{r+K}$;
the identity then reduces to $\frac{8^r(8^K+6)}{7} + 8^r 8^K = \frac{8^r(8^{K+1}+6)}{7}$,
which is the geometric-series step. $\square$

### 3.2 The law

**Theorem 3.4 (Capped Resolution Law).** *Let $K, r \ge 0$ with $b := r + K \ge 1$. Then*
$$\sigma^2\bigl(\mathrm{CB}(K,r)\bigr) \;=\; \frac{6\,(8^{b} - 8^{r})}{7\,(8^{b} - 2^{b})} \;=\; \frac{6}{7}\cdot\frac{1 - 8^{-K}}{1 - 4^{-b}} .$$

*Proof.* By Definition 2.3 with $n = 2^b$ (Lemma 3.2) and $n^3 = 8^b$,
$$\sigma^2 = 1 - \frac{12\operatorname{tie}(\mathrm{CB}(K,r))}{8^b - 2^b}
= 1 - \frac{\tfrac{8^r(8^K+6)}{7} - 2^b}{8^b - 2^b}$$
by Lemma 3.3. Clearing the denominator, the numerator becomes
$7(8^b - 2^b) - 8^r 8^K - 6\cdot 8^r + 7\cdot 2^b = 6\cdot 8^b - 6\cdot 8^r$, since
$8^r 8^K = 8^b$. Dividing by $7(8^b - 2^b) > 0$ gives the claim; the second form follows on
dividing numerator and denominator by $8^b$ and using $2^b/8^b = 4^{-b}$. $\square$

The law is the exact interpolation one wants:

**Corollary 3.5 (Endpoints).**
- $K = 0$ (no resolution): $\sigma^2 = 0$.
- $r = 0$ (full resolution): $\sigma^2 = \frac{6(8^b-1)}{7(8^b-2^b)} = \frac{6}{7}\bigl(1+\frac{1}{2^b(2^b+1)}\bigr)$, the dyadic ceiling of §2.3.

*Proof.* The first is immediate. For the second, put $n = 2^b$; then
$\frac{6(n^3-1)}{7(n^3-n)} = \frac{6(n-1)(n^2+n+1)}{7n(n-1)(n+1)} = \frac{6(n^2+n+1)}{7n(n+1)}
= \frac{6}{7}\bigl(1+\frac{1}{n(n+1)}\bigr)$. $\square$

**Theorem 3.6 (Strict monotonicity in cap depth).** *If $r+K = r'+K' \ge 1$ and $K < K'$
then $\sigma^2(\mathrm{CB}(K,r)) < \sigma^2(\mathrm{CB}(K',r'))$.*

*Proof.* At fixed $b$ the denominator of Theorem 3.4 is fixed and positive, while
$K < K'$ forces $r > r'$, hence $8^{r'} < 8^{r}$ and the numerator $6(8^b - 8^r)$ strictly
increases. $\square$

**Theorem 3.7 (Lifting the cap).** *For fixed $r$, $\sigma^2(\mathrm{CB}(K,r)) \to \frac{6}{7}$
as $K \to \infty$.*

*Proof.* With $b = r+K$, $\sigma^2 = \frac67\cdot\frac{1-8^{-K}}{1-4^{-b}}$, and both
$8^{-K}$ and $4^{-b}$ tend to $0$. Explicit two-sided geometric bounds sandwich the ratio,
giving the limit. $\square$

### 3.3 The universal $3/4$ floor

The following is the decisive inequality of the paper.

**Theorem 3.8 (Universal capped floor).** *For every cap depth $K \ge 1$ and every $r \ge 0$,*
$$\sigma^2\bigl(\mathrm{CB}(K,r)\bigr) \;\ge\; \frac34,$$
*equivalently $\rho_{\max} \ge \sqrt{3}/2 \approx 0.866$.*

*Proof.* By Theorem 3.4 it suffices to show $6(8^b - 8^r) \ge \tfrac{21}{4}(8^b - 2^b)$ with
$b = r+K$. Since $K \ge 1$ we have $8^b = 8^r 8^K \ge 8\cdot 8^r$, so
$8^r \le 8^b/8$ and $8^b - 8^r \ge \tfrac78\, 8^b$. Hence
$6(8^b - 8^r) \ge \tfrac{21}{4}\,8^b > \tfrac{21}{4}(8^b - 2^b)$. $\square$

Interpretation: the resolved classes carry the geometric mass $\tfrac12 + \tfrac14 + \dots$
of the sample, so even the crudest instrument — one that distinguishes only odd from even —
retains three quarters of the squared correlation. Deep valuations are exponentially rare
and cannot, by themselves, destroy a rank signal.

### 3.4 Arithmetic bridge

The profile $\mathrm{CB}(K,r)$ was written down as a geometric list. It is genuinely the
profile of the capped valuation.

**Lemma 3.9 (Top-class cardinality).** *For $K \le b$,*
$$\bigl|\{x < 2^b : 2^K \mid x\}\bigr| \;=\; 2^{\,b-K}.$$

*Proof.* The map $m \mapsto 2^K m$ is a bijection from $\{0,\dots,2^{b-K}-1\}$ onto the set
of multiples of $2^K$ below $2^b$: it is injective by cancellation, and $2^K m < 2^b$ iff
$m < 2^{b-K}$. $\square$

**Theorem 3.10 (Bridge).** *For $1 \le b$ and $K \le b$, the tie profile of $T_K$ on
$\{0,\dots,2^b-1\}$ — namely the exact-valuation class sizes $|\{x<2^b : v_2(x) = k\}|$ for
$k < K$ together with the merged top class of Lemma 3.9 — has the same total mass and the
same tie correction as $\mathrm{CB}(K, b-K)$, and therefore the same Spearman ceiling:*
$$\sigma^2\bigl(\text{profile of } T_K\bigr) = \sigma^2\bigl(\mathrm{CB}(K, b-K)\bigr) = \frac{6\,(8^{b}-8^{\,b-K})}{7\,(8^{b}-2^{b})}.$$

*Proof.* The exact-valuation class $\{x<2^b : v_2(x)=k\}$ has $2^{b-1-k}$ elements for
$k < K \le b$; reindexing $i = K-1-k$ turns the list $(2^{b-1}, \dots, 2^{b-K})$ into
$(2^{(b-K)+i})_{i<K}$, which is exactly the resolved part of $\mathrm{CB}(K,b-K)$, while
Lemma 3.9 supplies the top class $2^{b-K}$. Equal profiles have equal mass and equal tie
correction, and the ceiling depends only on those two data. $\square$

**Corollary 3.11 (Exclusion, arithmetic form).** *For all $1 \le K \le b$,*
$$\rho_{10}^2 \;=\; 0.563^2 \;=\; 0.316969 \;<\; \tfrac34 \;\le\; \sigma^2\bigl(\text{profile of } T_K\bigr).$$

**Theorem 3.12 (Coarse resolution is excluded).** *No capped-resolution mechanism, at any
cap depth $K \ge 1$ and any bit-width, is compatible with the bitlen-92 readings: the
mechanism's ceiling exceeds $0.866$ while the readings are at most $0.563$.*

---

## 4. Tie geometry cannot account for the trend

Exclusion at a single bit-width might be dismissed as a boundary effect; the erosion *trend*
is likewise immune.

**Theorem 4.1 (Tie budget between $b=52$ and $b=92$).**
$$\sigma^2(\text{dyadic}, b{=}52) - \sigma^2(\text{dyadic}, b{=}92) \;<\; 10^{-15},
\qquad \text{whereas} \qquad \rho_{52} - \bar\rho_{92} \;>\; 0.14 .$$

*Proof.* By Corollary 3.5 the dyadic ceiling at bit-width $b$ is
$\frac67\bigl(1+\frac1{2^b(2^b+1)}\bigr)$, so the difference of ceilings is
$\frac{6}{7}\bigl(\frac{1}{2^{52}(2^{52}+1)} - \frac{1}{2^{92}(2^{92}+1)}\bigr) < 2^{-103}
< 10^{-15}$. The second claim is arithmetic: $0.705 - 0.5595 = 0.1455 > 0.14$. $\square$

The available tie-geometry budget is thus more than thirteen orders of magnitude too small
to account for the observed drop. Whatever drives the erosion, it acts on the *response*,
not on the arithmetic of the predictor.

---

## 5. The corruption ledger

### 5.1 Rank-perturbation stability

We work with rank vectors: $R, S : \{1,\dots,n\} \to \mathbb{Q}$ are rank vectors when they
assign the standard (possibly mid-)ranks of some ordering, and
$$\rho(R,S) \;=\; 1 - \frac{6\sum_i (R_i - S_i)^2}{n^3 - n}.$$
Note $\rho(R,R) = 1$.

**Lemma 5.1 (Lipschitz estimate).** *Let $n \ge 2$ and let $R$, $S$, $S'$ be rank vectors
with $S_i = S'_i$ for all $i \notin A$. Then*
$$\bigl|\rho(R,S) - \rho(R,S')\bigr| \;\le\; \frac{6\,|A|}{n}.$$

*Proof sketch.* Both correlations are affine in $\sum_i (R_i - \cdot_i)^2$ with the same
normalisation $n^3-n$. Coordinates outside $A$ contribute identically and cancel. Each
coordinate inside $A$ contributes a squared rank difference of magnitude at most $(n-1)^2$,
so the total discrepancy is at most $6|A|(n-1)^2/(n^3-n) = 6|A|/(n(n+1)) \cdot (n-1)
\le 6|A|/n$. $\square$

### 5.2 Readings as budgets

**Definition 5.2 (Required corruption fraction).** For a reading $\rho$ put
$$\varphi(\rho) \;=\; \frac{1-\rho}{6}.$$

**Theorem 5.3 (Reading-to-corruption budget).** *Let $n \ge 2$, let $R$ be a rank vector, and
let $S'$ be a rank vector agreeing with $R$ outside a set $A$. If $\rho(R,S') \le \rho$, then*
$$|A| \;\ge\; n\,\varphi(\rho) \;=\; n\,\frac{1-\rho}{6}.$$

*Proof.* Apply Lemma 5.1 with $S = R$: since $\rho(R,R)=1$,
$1 - \rho \le 1 - \rho(R,S') \le |\rho(R,R)-\rho(R,S')| \le 6|A|/n$. Rearrange. $\square$

**Corollary 5.4 (The bitlen-92 budget).** *A reading of $\rho_{10} = 0.563$ forces
$|A| \ge 0.0728\, n$: any rank-level mechanism must displace more than $7.28\%$ of the
sample.*

*Proof.* $\varphi(0.563) = 0.437/6 = 0.0728\overline{3} > 0.0728$. $\square$

**Theorem 5.5 (The budget grew).**
$$\varphi(\rho_{52}) < \varphi(\bar\rho_{92}), \qquad \varphi(\rho_{52}) < 0.05, \qquad \varphi(\bar\rho_{92}) > 0.0728 .$$

*Proof.* $\varphi(0.705) = 0.295/6 = 0.0491\overline{6}$ and
$\varphi(0.5595) = 0.4405/6 = 0.0734\overline{16}$. $\square$

So over forty bits of draw width the mechanism's minimum footprint grew by about half
again, from under $4.92\%$ to over $7.34\%$ of the sample.

### 5.3 The floor *is* the budget

**Theorem 5.6 (Converse: a $7.5\%$ mechanism cannot break the floor).** *Let $n \ge 2$, let
$R$ and $S'$ be rank vectors agreeing outside $A$, and suppose $|A| \le \frac{3}{40}n$.
Then*
$$\rho(R,S') \;\ge\; 0.55 .$$

*Proof.* Lemma 5.1 with $S = R$ gives $1 - \rho(R,S') \le |1-\rho(R,S')| \le 6|A|/n
\le 6\cdot\frac{3}{40} = \frac{9}{20}$, whence $\rho(R,S') \ge 1 - \frac{9}{20} = \frac{11}{20} = 0.55$. $\square$

Combining Theorems 5.3 and 5.6 gives the following identification, which is the conceptual
core of the corruption analysis.

> **The floor is the $7.5\%$ corruption budget.** For rank-level mechanisms, the statements
> "$\rho \ge 0.55$" and "the mechanism displaces at most $3/40 = 7.5\%$ of the sample" are
> equivalent (up to the sharpness of the Lipschitz constant $6$). The validation floor is
> not a statistical convention but a displacement tolerance.

This resolves the qualitative puzzle of *why the dial bottoms out at $0.55$ instead of
decaying to zero*: a mechanism with a bounded footprint has a correspondingly bounded effect
on the reading, and $0.55$ is precisely the reading a $7.5\%$-footprint mechanism produces
in the worst case.

---

## 6. The hyperbolic erosion law

### 6.1 Fit

**Definition 6.1.** $\displaystyle \rho_{\mathrm{mod}}(b) = \frac{5}{14} + \frac{93}{5b}
\approx 0.357142 + \frac{18.6}{b}.$

**Theorem 6.2 (Fit across all recorded bit-widths).** *For all five recorded readings,*
$$\bigl|\rho_{\mathrm{mod}}(b) - \rho_{\mathrm{obs}}(b)\bigr| \;\le\; \frac{1}{100},
\qquad b \in \{44, 52, 64, 76, 92\}.$$

*Proof.* Direct evaluation: $\rho_{\mathrm{mod}}(44) = 0.77987$ vs $0.780$;
$\rho_{\mathrm{mod}}(52) = 0.71484$ vs $0.705$ (residual $0.0098$, the maximum);
$\rho_{\mathrm{mod}}(64) = 0.64777$ vs $0.648$;
$\rho_{\mathrm{mod}}(76) = 0.60188$ vs $0.608$;
$\rho_{\mathrm{mod}}(92) = 0.55932$ vs $0.5595$. $\square$

Two constants reproduce four independent experiments spanning a factor of two in bit-width,
with all residuals under one part in a hundred.

**Theorem 6.3 (Strict erosion and asymptote).** *$\rho_{\mathrm{mod}}$ is strictly decreasing
on $b \ge 1$, and $\rho_{\mathrm{mod}}(b) \to \frac{5}{14} \approx 0.3571$ as $b \to \infty$.*

*Proof.* $93/(5b)$ is strictly decreasing and tends to $0$. $\square$

Since $5/14 < 0.55$, the law predicts the dial does not merely approach the floor: it passes
through it.

### 6.2 The crossing

**Theorem 6.4 (Crossing prediction).** *For $b \ge 1$,*
$$\rho_{\mathrm{mod}}(b) \ge 0.55 \iff b \le 96,$$
*and $\rho_{\mathrm{mod}}(b) < 0.55$ for all $b \ge 97$.*

*Proof.* $\rho_{\mathrm{mod}}(b) \ge \frac{11}{20}$ iff $\frac{93}{5b} \ge \frac{11}{20}-\frac{5}{14} = \frac{27}{140}$
iff $93 \cdot 140 \ge 27 \cdot 5b$ iff $b \le \frac{13020}{135} = 96.4\overline{4}$, i.e. iff
$b \le 96$ for integer $b$. $\square$

This is a sharp, falsifiable prediction: a uniform measurement at any bit-width exceeding
$96$ should read below the validation floor, and one at $b \le 96$ should not.

### 6.3 Saturation of the ledger

**Lemma 6.5 (Closed form of the budget along the law).** *For $b \ge 1$,*
$$\varphi\bigl(\rho_{\mathrm{mod}}(b)\bigr) \;=\; \frac{3}{28} - \frac{31}{10b}.$$

*Proof.* $\varphi(\rho) = (1-\rho)/6$, so
$\varphi(\rho_{\mathrm{mod}}(b)) = \frac{1}{6}\bigl(\frac{9}{14} - \frac{93}{5b}\bigr)
= \frac{3}{28} - \frac{31}{10 b}$. $\square$

**Theorem 6.6 (Saturation).** *For all $b \ge 1$, $\varphi(\rho_{\mathrm{mod}}(b)) < \frac{3}{28} \approx 10.71\%$,
and $\varphi(\rho_{\mathrm{mod}}(b)) \to \frac{3}{28}$ as $b\to\infty$.*

*Proof.* Immediate from Lemma 6.5, since $31/(10b) > 0$ and tends to $0$. $\square$

Hence no rank-level mechanism consistent with the fitted trend is ever forced to displace
more than $3/28$ of the sample, at any bit-width: the corruption ledger saturates.

**Theorem 6.7 (Band exit is budget exhaustion).** *For $b \ge 1$,*
$$\varphi\bigl(\rho_{\mathrm{mod}}(b)\bigr) \le \frac{3}{40} \iff b \le 96 .$$

*Proof.* By Lemma 6.5 the condition reads $\frac{31}{10b} \ge \frac{3}{28}-\frac{3}{40} = \frac{9}{280}$,
i.e. $b \le \frac{31\cdot 280}{90} = 96.4\overline{4}$. $\square$

Theorems 6.4 and 6.7 have the same threshold, as they must: by §5.3 the floor and the
$3/40$ budget are the same condition. The geometric statement (the dial leaves the band) and
the arithmetic statement (the forced displacement overruns $7.5\%$) are two readings of one
crossing.

---

## 7. Every base: capped $p$-adic dials and effective-base drift

### 7.1 The base-$p$ law

Nothing above used primality or the specific value $2$. Fix an integer base $p \ge 2$ and
consider uniform draws from $\{0,\dots,p^b-1\}$ with the statistic $v_p(x)$, the exponent of
$p$ in $x$.

**Definition 7.1 (Capped $p$-adic profile).** For $b = r+K$,
$$\mathrm{CB}_p(K,r) \;=\; \bigl(p^{r},\; (p-1)p^{r},\, (p-1)p^{r+1},\, \dots,\, (p-1)p^{r+K-1}\bigr),$$
the merged top class of size $p^r$ together with the resolved classes of exact valuation
$0,\dots,K-1$.

**Definition 7.2 (Asymptotic base-$p$ ceiling).** $\displaystyle L(p) = \frac{3p}{p^2+p+1}.$

Note $L(2) = 6/7$, $L(7) = 7/19$, $L(8) = 24/73$, $L(9) = 27/91$, and $L$ is strictly
decreasing on $p \ge 2$ with $L(p) \sim 3/p$.

**Lemma 7.3 (Mass and tie correction).** *$\sum \mathrm{CB}_p(K,r) = p^{\,r+K}$, and*
$$12\,(p^3-1)\operatorname{tie}\bigl(\mathrm{CB}_p(K,r)\bigr)
= (p^3-1)p^{3r} + (p-1)^3\bigl(p^{3(r+K)} - p^{3r}\bigr) - (p^3-1)p^{\,r+K}.$$

*Proof.* Both by induction on $K$: the mass step uses $(p-1)p^{r+K}+p^{r+K}=p^{r+K+1}$, and
the tie step appends the block $(p-1)p^{r+K}$, whose contribution is
$((p-1)p^{r+K})^3 - (p-1)p^{r+K}$, then collects the geometric sum. $\square$

**Theorem 7.4 (Base-$p$ Capped Resolution Law).** *For $p \ge 2$ and $b = r+K \ge 1$,*
$$\sigma^2\bigl(\mathrm{CB}_p(K,r)\bigr) \;=\; L(p)\cdot\frac{p^{3b}-p^{3r}}{p^{3b}-p^{b}} .$$

*Proof.* Substitute Lemma 7.3 into $\sigma^2 = 1 - 12\operatorname{tie}/(n^3-n)$ with
$n = p^b$, and simplify. Writing $Y = p^b$, $t = p^r$, the numerator becomes
$(p^3-1)(Y^3 - Y) - \bigl[(p^3-1)t^3 + (p-1)^3(Y^3-t^3) - (p^3-1)Y\bigr]
= \bigl((p^3-1)-(p-1)^3\bigr)(Y^3-t^3)$, and
$\bigl((p^3-1)-(p-1)^3\bigr)/(p^3-1) = 3p/(p^2+p+1) = L(p)$ after factoring
$p^3-1 = (p-1)(p^2+p+1)$. $\square$

**Corollary 7.5 (Consistency).** *Base two reproduces Theorem 3.4, since
$\mathrm{CB}_2(K,r) = \mathrm{CB}(K,r)$ and $L(2) = 6/7$. Lifting the cap ($r=0$) reproduces
the uncapped $p$-adic ceiling
$\sigma^2 = L(p)\,\frac{Y^3-1}{Y^3-Y}$ with $Y = p^b$, which tends to $L(p)$.*

**Theorem 7.6 (Base-$p$ universal capped floor).** *For $p\ge2$, $K \ge 1$, $r \ge 0$,*
$$\sigma^2\bigl(\mathrm{CB}_p(K,r)\bigr) \;\ge\; L(p)\Bigl(1 - \frac{1}{p^3}\Bigr).$$
*At $p = 2$ this is exactly $\frac67\cdot\frac78 = \frac34$, recovering Theorem 3.8.*

*Proof.* With $Y = p^b$, $t = p^r$ and $K \ge 1$ we have $tp \le Y$, hence
$t^3 p^3 \le Y^3$, i.e. $t^3 \le Y^3/p^3$. Therefore
$$\frac{Y^3-t^3}{Y^3-Y} \;\ge\; \frac{Y^3 - Y^3/p^3}{Y^3} \;=\; 1-\frac{1}{p^3},$$
using $Y^3 - Y \le Y^3$ in the denominator. Multiply by $L(p) > 0$. $\square$

So the existence of a universal capped floor is base-independent; only its numerical value
depends on $p$. The elimination of the coarse-resolution mechanism in §3 is therefore
structural, not an accident of binary arithmetic.

### 7.2 Effective base

**Definition 7.7 (Effective base).** A reading $\rho$ has **effective base** $p$ when
$$L(p+1) \;<\; \rho^2 \;\le\; L(p).$$
Since $L$ is strictly decreasing with $L(p) \to 0$, every $\rho$ with $0 < \rho^2 \le L(2)$
has a unique effective base. Equivalently, $p$ is the base of the idealised uncapped
valuation dial whose asymptotic ceiling brackets the observed reading; since
$L(p) \sim 3/p$, one has the rule of thumb $p \approx 3/\rho^2$.

**Theorem 7.8 (Erosion is base drift).** *If $\rho$ has effective base $p$, $\rho'$ has
effective base $p' \ge 1$, and $\rho'^2 < \rho^2$, then $p \le p'$.*

*Proof.* Suppose $p' < p$, so $p' + 1 \le p$ and hence $L(p) \le L(p'+1)$ by antitonicity of
$L$. Then $\rho^2 \le L(p) \le L(p'+1) < \rho'^2$, contradicting $\rho'^2 < \rho^2$. $\square$

**Theorem 7.9 (The bitlen-92 effective base is $8$).** *Each of $\rho_{10} = 0.563$,
$\rho_{11} = 0.556$ and $\bar\rho_{92} = 0.5595$ has effective base exactly $8$:*
$$L(9) = \tfrac{27}{91} \approx 0.29670 \;<\; \rho^2 \;\le\; \tfrac{24}{73} = L(8) \approx 0.32877 .$$

*Proof.* $\rho_{10}^2 = 0.316969$, $\rho_{11}^2 = 0.309136$, $\bar\rho_{92}^2 = 0.31304$;
all three lie in $(0.29670,\, 0.32877]$. $\square$

**Theorem 7.10 (Drift from bit-width 76 to 92).**
$$L(7) < \rho_{76}^2, \qquad \bar\rho_{92}^2 < L(8), \qquad L(9) < \bar\rho_{92}^2 .$$

*Proof.* $\rho_{76}^2 = 0.608^2 = 0.369664 > 7/19 \approx 0.368421$, and the remaining two
are Theorem 7.9. $\square$

Thus at $b = 76$ the reading still sat strictly above the base-seven ceiling, so its
effective base was below $7$, whereas at $b = 92$ it is exactly $8$: at least one unit of
base drift in sixteen bits of draw width.

**Theorem 7.11 (Bounded drift).** *For every $b \ge 1$, $\rho_{\mathrm{mod}}(b)^2 > L(23)$;
moreover the asymptote satisfies*
$$L(23) = \tfrac{69}{553} \approx 0.124774 \;<\; \Bigl(\tfrac{5}{14}\Bigr)^2 \approx 0.127551 \;<\; \tfrac{66}{507} = L(22) \approx 0.130178 .$$

*Proof.* The displayed inequalities are arithmetic. For any $b\ge1$,
$\rho_{\mathrm{mod}}(b) > 5/14 > 0$, so $\rho_{\mathrm{mod}}(b)^2 > (5/14)^2 > L(23)$. $\square$

**Interpretation.** Under the hyperbolic law the dial's effective base increases with $b$ but
never passes $23$: the instrument degrades from a faithful binary valuation dial into
something behaving like a base-$22.5$ valuation dial, and stops there. The signal does not
vanish asymptotically — it converges to the ceiling of a coarser arithmetic.

---

## 8. Algorithms

Three computations underlie the results and are worth isolating.

**A. Ceiling of a tie profile.** Given a profile $(m_1,\dots,m_J)$, return
$1 - \sum_j (m_j^3-m_j)/(n^3-n)$ with $n = \sum_j m_j$. Cost $O(J)$ in exact rational
arithmetic; for the capped profile $J = K+1$ so cost is $O(K)$, but Theorem 3.4 collapses it
to $O(1)$ closed-form evaluation (with $O(\log b)$ big-integer exponentiations).

**B. Corruption budget from a reading.** Given $\rho$ and sample size $n$, return the forced
displacement $\lceil n(1-\rho)/6 \rceil$ and the maximal safe footprint $\lfloor 3n/40 \rfloor$
that preserves band membership. Cost $O(1)$.

**C. Effective base of a reading.** Given $\rho$, find the least $p \ge 2$ with
$\rho^2 > L(p+1)$ and $\rho^2 \le L(p)$. Since $L(p) \sim 3/p$, a starting guess
$p_0 = \lceil 3/\rho^2 \rceil$ followed by a short monotone scan terminates in $O(1)$
expected steps; a plain scan from $p = 2$ costs $O(3/\rho^2)$.

---

## 9. Discussion

**What is established.** The erosion of the dial from $0.780$ at $b=44$ to $0.556$ at
$b = 92$ is not an instrument artefact. The exact tie ceiling of any capped valuation
statistic is at least $3/4$ in squared correlation, while the observed square is at most
$0.317$; and the drift of the exact uncapped ceiling across the entire measured range is
below $10^{-15}$ against a measured drop above $0.14$. The mechanism must therefore act on
the *response*, displacing at least $7.28\%$ of the sample at $b=92$ — and, symmetrically,
any mechanism confined to $7.5\%$ of the sample cannot break the floor. The floor and the
budget are one statement.

**What is inferred, not established.** The hyperbolic law $\rho(b) = 5/14 + 93/(5b)$ is a
two-constant fit to five points, not a derivation. Its predictive content — the sharp
crossing at $b = 97$, the saturation of the ledger at $3/28$, the bounded effective-base
drift below $23$ — is offered precisely because it is falsifiable by a single further
measurement.

**Caveats.** The bitlen-92 measurement is partial: two of three planned seeds completed. The
two seeds agree to $0.007$, and every statement above that uses the reading is stated for
the larger seed (making the exclusions conservative) or for the mean (making the fit
statement conservative in the other direction). A third seed materially outside
$[0.55, 0.57]$ would require revisiting §6 but not §3–§5, whose exclusions have margins of a
factor of two.

**Sharpness of the Lipschitz constant.** The constant $6$ in Lemma 5.1 is the natural one
from the $6\sum d^2/(n^3-n)$ normalisation, and the budget statements inherit whatever
slack it carries. Both directions of §5.3 use the same constant, so the identification of
the floor with the $7.5\%$ budget is exact as an equivalence of the two derived bounds,
even where each bound is individually conservative.

---

## 10. Future work

1. **Effective-base linearity.** Conjecture: the effective base $p(b)$ satisfies
   $p(b) = \alpha b + \beta + o(1)$, and the hyperbolic law forces $\alpha = 0$, i.e. the
   drift decelerates and saturates at $p_\infty \in (22,23)$. Since $L(p)\sim 3/p$, a reading
   $\rho$ has effective base $\approx 3/\rho^2$, so feeding a hyperbolic decay through this
   inverse yields a *bounded* base drift — a far stronger and more falsifiable statement than
   the decay itself. Two anchors exist (base below $7$ at $b=76$, base $8$ at $b=92$); a third
   at $b = 108$ decides it.
2. **Attainability of the saturated budget.** Theorem 6.6 bounds the forced displacement by
   $3/28$; whether that bound is attained by an actual mechanism, and what such a mechanism
   would look like at the level of the rank vector, is open.
3. **Non-uniform draws.** All ceilings here assume uniform draws. Skewed input laws change
   the tie profile and hence the ceiling; the capped resolution law should be re-derived for
   geometric and log-uniform input distributions.
4. **Sharper perturbation constants.** Replacing the constant $6$ in Lemma 5.1 by the exact
   extremal value would turn the floor/budget identification from an equivalence of bounds
   into an exact statement about attainable readings.
5. **Composite bases.** Definition 7.1 makes sense for composite $p$, and Theorem 7.4 was
   proved for all integers $p \ge 2$; the arithmetic bridge (Theorem 3.10), however, uses
   $p$-power divisibility and deserves a careful restatement when $p$ is composite, since
   $v_p$ is then not a valuation.

---

## Appendix: numerical summary

| quantity | value |
|---|---|
| $L(2) = 6/7$ | $0.857143$ |
| dyadic ceiling at $b=92$ | $0.857143$ (to $10^{-27}$) |
| universal capped floor ($p=2$, any $K\ge1$) | $0.75$ in $\rho^2$; $0.866025$ in $\rho$ |
| $\rho_{10}^2$ | $0.316969$ |
| forced displacement at $\rho = 0.563$ | $7.283\%$ |
| forced displacement at $\rho = 0.705$ | $4.917\%$ |
| floor budget $3/40$ | $7.5\%$ |
| saturation budget $3/28$ | $10.714\%$ |
| $\rho_{\mathrm{mod}}(96)$, $\rho_{\mathrm{mod}}(97)$ | $0.550893$, $0.548896$ |
| $L(8) = 24/73$, $L(9) = 27/91$ | $0.328767$, $0.296703$ |
| $L(22)$, $(5/14)^2$, $L(23)$ | $0.130178$, $0.127551$, $0.124774$ |
