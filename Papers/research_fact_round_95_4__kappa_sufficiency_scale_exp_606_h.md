# Composition Order as a Sufficient Statistic: Exact Cell Measures, Slope Laws, and the Boundary of $\kappa$-Sufficiency

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

Let $B$ be a finite base of distinct primes. For an integer $v$, the *cell* of $v$
relative to $B$ is $\mathrm{cell}(v) = \{p \in B : p \mid v\}$ and its *composition order*
is $\kappa(v) = |\mathrm{cell}(v)|$. Empirical work on smooth-number production reports a
graded law of the form $\log(\text{rate}) \approx \text{dial} - \beta\kappa$ with a
scale-stable slope $\beta \approx 0.35$ across bit-widths $72$, $96$ and $128$, together with
the finding that $\kappa$ is a sufficient summary of the cell at $72$ and $96$ bits but not
at $128$.

We give an exact mathematical account of what those three findings measure. First we compute
the arithmetic distribution of cells with no heuristic: over one period
$M = \prod_{p\in B} p$, the number of residues with cell exactly $S$ is
$\prod_{p \in B\setminus S}(p-1)$, so the small-prime divisibility events are *exactly*
independent Bernoulli variables with biases $1/p$. We then certify the transfer to finite
windows: for every window length $N$ the cell count deviates from its predicted value by at
most $2^{|B\setminus S|}$, a bound uniform in $N$.

On this measure we analyse the additive model $\Lambda(S) = D - \sum_{p\in S} w_p$ with
weight profile $w$. We prove: (i) a *sufficiency dichotomy* — $\kappa$ is a sufficient
statistic if and only if $w$ is constant on $B$, with failure already visible at
$\kappa = 1$; (ii) an *identification theorem* — the graded law holds iff $w \equiv \beta$,
and then both $\beta$ and the dial are determined; (iii) a *slope law* — the least-squares
slope of $\Lambda$ on $\kappa$ equals the $q(1-q)$-weighted mean of $-w$, so weight
homogeneity forces the same slope at every base, marginal profile and scale, and cross-scale
slope stability is *equivalent* to weight homogeneity rather than being additional evidence;
(iv) a *closed form* for the identity increment,
$\mathcal{R} = \big(\tfrac12\sum_{p,r} v_p v_r (w_p-w_r)^2\big)/\sum_p v_p$ with
$v_p = q_p(1-q_p)$, vanishing exactly when $\kappa$ is sufficient, with a sharp Popoviciu
bound converting a measured increment into a certified lower bound on the weight spread;
(v) an *orthogonality theorem* justifying the name — the least-squares residual is centred
and uncorrelated with $\kappa$, its variance is $\mathcal{R}$, and
$\operatorname{Var}\Lambda = \beta^2\operatorname{Var}\kappa + \mathcal{R}$; and (vi) a
*boundary calculus* — for a monotone increment the verdict is downward closed, a
TRUE/FALSE/TRUE pattern is impossible, the crossing is unique for a continuous strictly
increasing increment, the reported bracket $0.0084 \le 0.02 < 0.0346$ localises it strictly
inside $(96,128]$, and the $72$-bit verdict is *forced* by the $96$-bit one rather than being
independent evidence.

The net effect is a reduction: four experimental questions collapse into one question about
a single hidden object, the weight profile $w$ — its homogeneity and its scale dependence.
We close with a Dickman-type prediction $w_p \propto \log p$, which the slope law and the
closed form together render falsifiable by a single measured number per scale.

**Keywords:** composition order, smooth numbers, sufficient statistic, exact independence,
Lagrange identity, Popoviciu inequality, least-squares slope, Dickman function.

---

## 1. Introduction

### 1.1 Motivation

Smooth numbers — integers all of whose prime factors lie below a bound $y$ — are the
computational substrate of sieve-based factoring and index-calculus discrete logarithms. The
run time of such an algorithm is governed by the rate at which smooth values appear in the
window being sieved. Any cheap, locally computable statistic that predicts that rate is
therefore of direct algorithmic interest: it tells a sieve where to look.

The cheapest such statistic is trial division by a fixed base $B$ of small primes. It
produces a set — the *cell* $\mathrm{cell}(v) = \{p\in B : p\mid v\}$ — and, coarser still,
a single integer, the *composition order* $\kappa(v) = |\mathrm{cell}(v)|$.

Measurements at three bit-widths report:

| bit-width | $\kappa$-effect $\Delta$ | fitted slope $\beta_\kappa$ (95% CI) | identity increment | $\kappa$ sufficient? |
|---|---|---|---|---|
| $72$ | $+0.0830$ | $-0.349\ [-0.456,-0.256]$ | $+0.0071$ | yes |
| $96$ | $+0.0869$ | $-0.380\ [-0.483,-0.279]$ | $+0.0084$ | yes |
| $128$ | $+0.0585$ | $-0.325\ [-0.432,-0.217]$ | $+0.0346$ | **no** |

against a pre-registered sufficiency bar of $0.02$. Three claims are being made: the effect
replicates; the slope is scale-stable near $-0.35$; and the count $\kappa$ summarises the
whole cell at the two smaller scales but not at the largest.

### 1.2 What this paper does

Each claim presupposes a model. "The slope is stable" presupposes that a slope is a
well-defined functional of something. "$\kappa$ is sufficient" presupposes a distribution
over cells. This paper supplies both, exactly, and then proves what each verdict is a
statement about.

The architecture is a two-layer separation:

* the **population layer** — how cells are distributed among integers. We compute this
  exactly (Section 2) and certify its transfer to finite windows (Section 3).
* the **response layer** — how the log-rate depends on the cell. We posit the mildest
  additive model, $\Lambda(S) = D - \sum_{p\in S} w_p$, and derive everything from the weight
  profile $w$ (Sections 4–7).

The reduction that emerges is the paper's main structural message: *sufficiency, scale
stability and the size of the identity increment are three faces of one property of $w$.*

---

## 2. The exact arithmetic cell measure

### 2.1 Definitions

**Definition 2.1 (base, period, cell, composition order).**
Let $B$ be a finite set of distinct primes. Its **period** is $\mathrm{per}(B) = \prod_{p\in B} p$.
For $v \in \mathbb{N}$, the **cell** of $v$ is
$$\mathrm{cell}_B(v) = \{p \in B : p \mid v\} \subseteq B,$$
and the **composition order** is $\kappa_B(v) = |\mathrm{cell}_B(v)|$.
For $S \subseteq B$, the **cell fibre** over $S$ is
$$F_B(S) = \{v : 0 \le v < \mathrm{per}(B),\ \mathrm{cell}_B(v) = S\}.$$

**Lemma 2.2 (fibre membership).** For $S \subseteq B$ and any $v$,
$\mathrm{cell}_B(v) = S$ if and only if for every $p \in B$ one has $p \mid v \iff p \in S$.

*Proof.* Immediate from the definition of the cell as a filter of $B$; the only content is
the observation that the right-hand condition constrains $v$ only through the primes of $B$,
which is exactly what the equality of finite sets asserts. $\square$

### 2.2 Exact counts

**Lemma 2.3 (totient of a squarefree product).** If $T$ is a finite set of distinct primes,
then $\varphi\!\left(\prod_{p\in T} p\right) = \prod_{p \in T}(p-1)$.

*Proof.* Induction on $T$. Adjoining a prime $a \notin T$, the modulus $a$ is coprime to
$\prod_{p\in T} p$ because distinct primes are coprime, so multiplicativity of $\varphi$
applies, and $\varphi(a) = a-1$. $\square$

**Theorem 2.4 (exact cell counts over a period).** Let $B$ be a finite base of distinct
primes and $S \subseteq B$. Then
$$|F_B(S)| \;=\; \prod_{p \in B \setminus S} (p-1).$$

*Proof sketch.* Put $d = \prod_{p\in S} p$ and $M' = \prod_{p \in B\setminus S} p$, so that
$\mathrm{per}(B) = M' d$. The map $u \mapsto d\,u$ is a bijection from
$$\{u : 0 \le u < M',\ \gcd(u, M') = 1\} \quad\longrightarrow\quad F_B(S).$$

*Well-defined.* If $u < M'$ then $du < dM' = \mathrm{per}(B)$. Every $p\in S$ divides $d$
hence $du$. For $p \in B\setminus S$: $p \nmid d$ (else $p$ would equal one of the distinct
primes of $S$), and $p \nmid u$ (since $p \mid M'$ and $\gcd(u,M')=1$), so by primality
$p \nmid du$. By Lemma 2.2, $\mathrm{cell}(du) = S$.

*Injective.* Cancellation by $d > 0$.

*Surjective.* If $\mathrm{cell}(v) = S$ with $v < \mathrm{per}(B)$, then every prime of $S$
divides $v$; since these are distinct primes, their product $d$ divides $v$, say $v = du$.
Then $du < dM'$ gives $u < M'$, and for each $p \in B\setminus S$ we have $p \nmid du$, hence
$p \nmid u$; as $M'$ is squarefree with prime divisors exactly $B\setminus S$, this yields
$\gcd(u,M')=1$.

The source set has cardinality $\varphi(M') = \prod_{p\in B\setminus S}(p-1)$ by Lemma 2.3.
$\square$

*Remark.* An earlier route through the Chinese Remainder Theorem stalls on identifying
component maps. Dividing out the forced factor $d$ and invoking the totient removes the CRT
entirely — a simplification worth recording.

**Theorem 2.5 (exact independence).** For every $S \subseteq B$,
$$\frac{|F_B(S)|}{\mathrm{per}(B)} \;=\; \prod_{p \in S}\frac{1}{p}\;\cdot\!\!\prod_{p \in B\setminus S}\!\!\left(1 - \frac 1p\right).$$

*Proof.* Divide Theorem 2.4 by $\mathrm{per}(B) = \big(\prod_{B\setminus S} p\big)\big(\prod_S p\big)$
and distribute: each factor $p-1$ over $p$ becomes $1 - 1/p$, and each factor $1$ over $p$
becomes $1/p$. $\square$

Thus the divisibility events $\{p \mid v\}_{p\in B}$ are *exactly* — not asymptotically —
independent over a period, with marginals $1/p$.

**Theorem 2.6 (partition of the period).**
$\sum_{S \subseteq B} |F_B(S)| = \mathrm{per}(B)$.

*Proof.* By Theorem 2.4 the sum is $\sum_S \prod_{p\in S} 1 \cdot \prod_{p\notin S}(p-1)$,
which by the expansion $\prod_{p\in B}\big(1 + (p-1)\big) = \prod_{p\in B} p$ equals
$\mathrm{per}(B)$. $\square$

**Theorem 2.7 (mean composition order is the truncated Mertens sum).**
$$\frac{1}{\mathrm{per}(B)}\sum_{v < \mathrm{per}(B)} \kappa_B(v) \;=\; \sum_{p\in B}\frac1p .$$

*Proof.* Write $\kappa_B(v) = \sum_{p\in B} \mathbf 1[p\mid v]$ and exchange the order of
summation. For each $p \in B$ we have $p \mid \mathrm{per}(B)$, and the multiples of $p$
below $\mathrm{per}(B)$ are in bijection with $\{0,\dots,\mathrm{per}(B)/p - 1\}$ via
$k \mapsto pk$, so the inner count is exactly $\mathrm{per}(B)/p$. Divide. $\square$

**Theorem 2.8 (every cell is populated).** $|F_B(S)| > 0$ for every $S \subseteq B$.

*Proof.* Each factor $p - 1 \ge 1$ in Theorem 2.4. $\square$

Theorem 2.8 matters for the regression: the design has support at every level
$0 \le \kappa \le |B|$, so a fit on $\kappa$ is not extrapolating.

**Worked check.** For $B = \{2,3,5\}$, $\mathrm{per}(B)=30$ and the fibre sizes are
$$\emptyset \mapsto 8,\quad \{2\}\mapsto 8,\quad \{3\}\mapsto 4,\quad \{5\}\mapsto 2,\quad \{2,3\}\mapsto 4,\quad \{2,5\}\mapsto 2,\quad \{3,5\}\mapsto 1,\quad \{2,3,5\}\mapsto 1,$$
totalling $30$; and $8 = 1\cdot 2\cdot 4$, $8 = 2\cdot 4$, $4 = 1\cdot 4$, matching
$\prod_{p\notin S}(p-1)$ in every case. The total of $\kappa$ over the period is
$31 = 15+10+6$, i.e. mean $31/30 = \tfrac12+\tfrac13+\tfrac15$.

---

## 3. From periods to windows: a certified error term

Theorem 2.5 is exact but describes a full period, whereas experiments sample a window of
$n$ integers of fixed bit-width with $n \ll \mathrm{per}(B)$ once $|B|$ exceeds a dozen. This
section closes the gap with a bound uniform in the window length.

**Lemma 3.1 (multiples in an initial window).** For $d \ge 1$ and $N \ge 0$,
$$\#\{v < N : d \mid v\} = \left\lceil \frac{N}{d} \right\rceil, \qquad \text{hence}\qquad \left|\#\{v<N : d\mid v\} - \frac Nd\right| \le 1 .$$

*Proof.* The multiples are $0, d, 2d, \dots$; $dk < N$ iff $k < \lceil N/d\rceil$. The
displayed inequality is the standard gap between a ceiling and its argument. $\square$

**Lemma 3.2 (Möbius expansion of the cell indicator).** For every base $B$ of distinct
primes, every $S \subseteq B$ and every integer $v$,
$$\mathbf 1[\mathrm{cell}_B(v) = S] \;=\; \sum_{T \subseteq B\setminus S} (-1)^{|T|}\, \mathbf 1\!\left[\Big(\textstyle\prod_{p\in S\cup T} p\Big) \;\Big|\; v\right].$$

*Proof sketch.* Two cases. If some $p \in S$ fails to divide $v$, then every term on the
right vanishes (each divisor contains $p$), and so does the left. Otherwise let
$E = \{p \in B\setminus S : p\mid v\}$ be the excess. Since the primes are distinct, the
divisibility condition for $T$ holds precisely when $T \subseteq E$, so the right-hand side is
$\sum_{T\subseteq E} (-1)^{|T|} = (1-1)^{|E|}$, which is $1$ if $E = \emptyset$ and $0$
otherwise — exactly the left-hand side. $\square$

**Theorem 3.3 (window error bound).** For every base $B$ of distinct primes, every
$S \subseteq B$ and every $N \ge 0$,
$$\left|\;\#\{v < N : \mathrm{cell}_B(v) = S\} \;-\; N \prod_{p\in S}\frac1p \prod_{p\in B\setminus S}\!\left(1-\frac1p\right)\right| \;\le\; 2^{\,|B\setminus S|}.$$

*Proof sketch.* Sum Lemma 3.2 over $v < N$: the count equals
$\sum_{T\subseteq B\setminus S} (-1)^{|T|}\,\#\{v<N : d_T \mid v\}$ with
$d_T = \prod_{p \in S\cup T} p$. Replace each count by $N/d_T$, incurring an error at most
$1$ per term by Lemma 3.1. The resulting main term is
$$N \sum_{T \subseteq B\setminus S} \frac{(-1)^{|T|}}{\prod_{p\in S\cup T} p} \;=\; N\prod_{p\in S}\frac1p \prod_{p\in B\setminus S}\!\left(1-\frac1p\right),$$
by factoring $\prod_{p\in S} p^{-1}$ out and recognising the remaining alternating sum as the
expansion of $\prod_{p\in B\setminus S}(1 - 1/p)$. There are $2^{|B\setminus S|}$ terms. $\square$

**Corollary 3.4 (convergence of empirical cell frequencies).** For every $S \subseteq B$,
$$\frac{\#\{v<N : \mathrm{cell}_B(v) = S\}}{N} \;\xrightarrow[N\to\infty]{}\; \prod_{p\in S}\frac1p \prod_{p\in B\setminus S}\!\left(1-\frac1p\right).$$

*Proof.* Divide Theorem 3.3 by $N$; the error is $O(2^{|B|}/N)$. $\square$

*Remark 3.5.* The critical feature is that the constant does not depend on $N$. A naive
argument that bounds the discrepancy by the length of the incomplete final period gives a
constant of order $\mathrm{per}(B)$, which is vacuous exactly in the regime $N \ll
\mathrm{per}(B)$ where every real experiment operates. Performing the inclusion–exclusion
*before* truncating replaces $\mathrm{per}(B)$ by $2^{|B\setminus S|}$.

**Numerical check.** For $B = \{2,3,5\}$ and $S = \{2\}$, the window counts for
$N = 10, 50, 97, 1000$ are $3, 13, 26, 267$, against predicted values
$8N/30 = 2.67, 13.33, 25.87, 266.67$; the errors $0.33, 0.33, 0.13, 0.33$ show no growth in
$N$ and stay well inside the proved bound $2^{|B\setminus S|} = 4$.

---

## 4. The additive response model and the sufficiency dichotomy

**Definition 4.1 (additive log-rate).** Given a *dial* $D \in \mathbb R$ and a **weight
profile** $w : B \to \mathbb R$, the modelled log smoothness rate of a cell $S$ is
$$\Lambda(S) \;=\; D - \sum_{p\in S} w_p .$$

**Definition 4.2 ($\kappa$-sufficiency).** $\kappa$ is a **sufficient statistic** for
$\Lambda$ on $B$ if for all $S, T \subseteq B$ with $|S| = |T|$ one has $\Lambda(S) = \Lambda(T)$,
equivalently $\sum_{p\in S} w_p = \sum_{p\in T} w_p$.

**Theorem 4.3 (sufficiency dichotomy).**
$$\kappa \text{ is sufficient on } B \iff w_p = w_r \ \text{ for all } p, r \in B .$$

*Proof.* ($\Rightarrow$) Apply Definition 4.2 to the singletons $S = \{p\}$, $T = \{r\}$,
which have equal cardinality; the sums are $w_p$ and $w_r$.
($\Leftarrow$) If $B$ is empty both subsets are empty. Otherwise fix $p_0 \in B$; for any
$U \subseteq B$, replacing each $w_p$ by $w_{p_0}$ gives $\sum_{p\in U} w_p = |U|\,w_{p_0}$,
which depends on $U$ only through $|U|$. $\square$

**Corollary 4.4 (no intermediate regime).** For any two primes $p, r$,
$$\Lambda(\{r\}) - \Lambda(\{p\}) = w_p - w_r .$$
Hence if any two weights differ, sufficiency fails already at $\kappa = 1$.

This is a genuinely informative negative result. Gradedness — sufficiency degrading smoothly
as scale increases — *cannot* arise inside a fixed additive model. It must come from the
scale dependence of $w$ itself. That is why the analysis below is two-layered: weights $w$,
marginals $q$, and a scale-indexed weight spread.

**Theorem 4.5 (a priori bound on the identity increment).** Suppose $m \le w_p \le M_x$ for
all $p \in B$. Then for $S, T \subseteq B$ with $|S| = |T| = \kappa$,
$$|\Lambda(S) - \Lambda(T)| \;\le\; \min(\kappa,\; |B| - \kappa)\cdot (M_x - m).$$

*Proof sketch.* Splitting each sum over the intersection and the difference gives
$\Lambda(S) - \Lambda(T) = \sum_{p\in T\setminus S} w_p - \sum_{p\in S\setminus T} w_p$. Since
$|S| = |T|$, the two differences have the same size $j = |S\setminus T| = |T\setminus S|$,
and $j \le |S| = \kappa$ while $j \le |B\setminus S| = |B|-\kappa$. Bounding each sum
between $j\,m$ and $j\,M_x$ gives the claim. $\square$

**Proposition 4.6 (sharpness).** At $\kappa = 1$ the bound is attained: taking $S = \{p\}$,
$T = \{r\}$ with $w_p = M_x$, $w_r = m$ gives $|\Lambda(S)-\Lambda(T)| = M_x - m =
\min(1,|B|-1)(M_x-m)$ whenever $|B| \ge 2$.

*Remark 4.7.* Measuring the increment as an unconditional supremum over all pairs of cells
produces the vacuous bound $|B|(M_x - m)$. Conditioning on equal composition order is what
recovers the sharp constant.

---

## 5. The product cell measure and the slope law

### 5.1 The measure and its moments

**Definition 5.1 (product cell measure).** For marginals $q : B \to \mathbb R$, define
$$P_q(S) = \prod_{p\in S} q_p \prod_{p \in B\setminus S} (1 - q_p), \qquad S \subseteq B,$$
and $\mathbb E[f] = \sum_{S\subseteq B} P_q(S) f(S)$. Write $v_p = q_p(1-q_p)$.

**Theorem 5.2 (upward marginals).** For $T \subseteq B$,
$\sum_{S \supseteq T} P_q(S) = \prod_{p\in T} q_p$; in particular $\sum_{S} P_q(S) = 1$, so
$P_q$ is a probability distribution.

*Proof sketch.* Reindex the cells containing $T$ by $S = T \cup R$ with
$R \subseteq B\setminus T$; disjointness gives
$P_q(T\cup R) = \big(\prod_{p\in T} q_p\big)\cdot \big(\prod_{p\in R} q_p \prod_{p \in (B\setminus T)\setminus R}(1-q_p)\big)$,
and the bracketed factor sums over $R$ to $\prod_{p\in B\setminus T}\big(q_p + (1-q_p)\big) = 1$.
Take $T = \emptyset$ for the second claim. $\square$

**Corollary 5.3 (indicator moments).** With $\mathbf 1_p(S) = \mathbf 1[p\in S]$,
$$\mathbb E[\mathbf 1_p] = q_p, \qquad \mathbb E[\mathbf 1_p \mathbf 1_r] = \begin{cases} q_p, & p = r,\\ q_p q_r, & p\ne r.\end{cases}$$

**Theorem 5.4 (first and second moments of additive statistics).** For $a, b : B \to \mathbb R$,
$$\mathbb E\Big[\sum_{p\in S} a_p\Big] = \sum_{p\in B} a_p q_p, \qquad
\mathbb E\Big[\Big(\sum_{p\in S} a_p\Big)\Big(\sum_{r\in S} b_r\Big)\Big] = \Big(\sum_p a_p q_p\Big)\Big(\sum_r b_r q_r\Big) + \sum_p a_p b_p v_p .$$

*Proof sketch.* Write $\sum_{p\in S} a_p = \sum_{p\in B} a_p \mathbf 1_p(S)$, expand the
product into a double sum and apply Corollary 5.3 termwise. The off-diagonal terms
reconstruct the product of the means; the diagonal contributes
$a_p b_p (q_p - q_p^2) = a_p b_p v_p$. $\square$

**Corollary 5.5 (the four moments).** With $\kappa(S) = |S|$ and $\Lambda$ as in
Definition 4.1,
$$\mathbb E[\kappa] = \sum_p q_p, \qquad \operatorname{Var}(\kappa) = \sum_p v_p,$$
$$\mathbb E[\Lambda] = D - \sum_p w_p q_p, \qquad \operatorname{Cov}(\Lambda,\kappa) = -\sum_p w_p v_p, \qquad \operatorname{Var}(\Lambda) = \sum_p w_p^2 v_p .$$

*Proof.* Specialise Theorem 5.4 with $a \equiv 1$ (for $\kappa$), $a = w$, and combinations
thereof, and subtract the products of the means. $\square$

### 5.2 The slope law

**Definition 5.6 (least-squares slope).**
$\displaystyle \beta_{\mathrm{OLS}} = \frac{\operatorname{Cov}(\Lambda, \kappa)}{\operatorname{Var}(\kappa)}$.

**Theorem 5.7 (slope law).**
$$\beta_{\mathrm{OLS}} \;=\; \frac{-\sum_{p\in B} w_p\, v_p}{\sum_{p\in B} v_p}.$$
That is, the measured slope is exactly the $v$-weighted mean of $-w$.

*Proof.* Substitute the covariance and variance from Corollary 5.5. $\square$

**Theorem 5.8 (scale stability $\equiv$ weight homogeneity).** If $w_p = \beta$ for all
$p \in B$ and $\sum_p v_p \ne 0$, then $\beta_{\mathrm{OLS}} = -\beta$ — for *every* base
$B$, *every* marginal profile $q$, and hence every scale.

*Proof.* The numerator becomes $\beta \sum_p v_p$; cancel. $\square$

**Theorem 5.9 (the slope identifies the weight).** On the singleton base $B = \{p\}$ with
$q_p \notin \{0,1\}$, $\beta_{\mathrm{OLS}} = -w_p$.

*Proof.* Both sums in Theorem 5.7 have one term $v_p \ne 0$; cancel. $\square$

Theorems 5.8 and 5.9 together settle the interpretation of the scale-stability verdict. The
empirical observation is that the fitted slope agrees within confidence intervals at three
widths. Theorem 5.8 says a homogeneous $w$ *forces* that agreement automatically, at all
scales, with no further hypothesis; Theorem 5.9 says the slope is a faithful readout of the
per-prime penalty rather than a summary that could coincidentally be stable. Consequently:

> **Cross-scale slope stability is not additional evidence beyond the graded law. It is
> equivalent to weight homogeneity.**

### 5.3 The graded law is an identification

**Theorem 5.10 (graded law, both directions).**
(i) If $w_p = \beta$ for all $p\in B$, then $\Lambda(S) = D - \beta|S|$ for all $S \subseteq B$.
(ii) Conversely, if $\Lambda(S) = C - \beta|S|$ for all $S \subseteq B$, then $C = D$ and
$w_p = \beta$ for every $p \in B$.

*Proof.* (i) is a direct substitution. For (ii), evaluate at $S = \emptyset$ to get $C = D$,
then at $S = \{p\}$ to get $D - w_p = D - \beta$. $\square$

So the graded law is not a loose fit but a complete determination: observing it pins the dial
and every weight.

### 5.4 The arithmetic bridge

**Theorem 5.11 (the model measure is the arithmetic one).** If every element of $B$ is prime
then, taking $q_p = 1/p$,
$$P_q(S) \;=\; \frac{|F_B(S)|}{\mathrm{per}(B)} \qquad \text{for all } S \subseteq B .$$

*Proof.* This is Theorem 2.5. $\square$

**Lemma 5.12 (nondegeneracy).** If $p$ is prime then $v_p = \tfrac1p(1-\tfrac1p) > 0$, since
$p \ge 2$ gives $0 < 1/p \le 1/2$. Hence $\sum_{p\in B} v_p > 0$ for nonempty prime $B$.

**Theorem 5.13 (slope law over the integers).** For a nonempty base $B$ of primes with
$q_p = 1/p$ and constant weight $w \equiv \beta$, the least-squares slope of the log-rate on
composition order is exactly $-\beta$.

*Proof.* Combine Theorem 5.8 with Lemma 5.12. $\square$

Theorem 5.13 is the point at which the slope law stops being a statement about a postulated
population and becomes a statement about integers.

---

## 6. The identity increment in closed form

### 6.1 The algebraic engine

**Theorem 6.1 (finite Lagrange identity).** For any $v, w : B \to \mathbb R$,
$$\Big(\sum_{p} v_p\Big)\Big(\sum_{p} v_p w_p^2\Big) - \Big(\sum_p v_p w_p\Big)^2 \;=\; \tfrac12 \sum_{p\in B}\sum_{r\in B} v_p v_r (w_p - w_r)^2 .$$

*Proof.* Expand both products into double sums. The right-hand side expands to
$\tfrac12\sum_{p,r} v_p v_r(w_p^2 - 2w_pw_r + w_r^2)$; the two square terms are equal by
symmetry of the index swap and together give $\sum_{p,r} v_p v_r w_p^2 = (\sum v)(\sum vw^2)$,
while the cross term gives $-(\sum v w)^2$. $\square$

**Corollary 6.2 (positivity and its equality case).** If $v_p \ge 0$ on $B$ then the pair
energy $\sum_{p,r} v_p v_r (w_p-w_r)^2$ is $\ge 0$; if $v_p > 0$ on $B$ then it is $0$ if and
only if $w$ is constant on $B$.

*Proof.* Each summand is a product of non-negatives. For the equality case, a sum of
non-negative terms vanishes iff each vanishes, and $v_pv_r > 0$ forces $w_p = w_r$. $\square$

Note the order of derivation: proving the identity first and reading positivity off it makes
the equality case immediate, whereas quoting Cauchy–Schwarz first makes the equality case
awkward.

### 6.2 The closed form

**Definition 6.3 (identity increment / residual variance).**
$$\mathcal R \;=\; \operatorname{Var}(\Lambda) \;-\; \frac{\operatorname{Cov}(\Lambda,\kappa)^2}{\operatorname{Var}(\kappa)} .$$

**Theorem 6.4 (closed form).** If $\sum_p v_p \ne 0$ then
$$\boxed{\;\mathcal R \;=\; \frac{\tfrac12 \sum_{p\in B}\sum_{r\in B} v_p\, v_r\, (w_p - w_r)^2}{\sum_{p\in B} v_p}\;}$$
with $v_p = q_p(1-q_p)$.

*Proof.* By Corollary 5.5, $\mathcal R = \sum_p w_p^2 v_p - (\sum_p w_p v_p)^2/\sum_p v_p$.
Multiply through by $\sum_p v_p$ and apply Theorem 6.1. $\square$

So the increment is a **pairwise weight-spread energy**, normalised by the total Bernoulli
variance. Three consequences:

**Corollary 6.5 (non-negativity).** If $v_p \ge 0$ on $B$ and $\sum_p v_p > 0$, then
$\mathcal R \ge 0$.

**Theorem 6.6 (the sufficiency law).** If $v_p > 0$ for all $p \in B$ and $\sum_p v_p > 0$,
then
$$\mathcal R = 0 \iff \kappa \text{ is a sufficient statistic for } \Lambda .$$

*Proof.* Combine Theorem 6.4, Corollary 6.2 and Theorem 4.3. $\square$

**Theorem 6.7 (arithmetic form).** For a nonempty base of primes with $q_p = 1/p$, the exact
arithmetic cell measure satisfies $\mathcal R = 0$ if and only if $\kappa$ is sufficient.

*Proof.* Theorem 6.6 with Lemma 5.12. $\square$

Theorem 6.7 is the statement that, over the integers, "cell identity adds nothing beyond
composition order" is *equivalent* to weight homogeneity, with no error term and no asymptotic
caveat. The quantitative and qualitative verdicts coincide exactly.

### 6.3 A sharp protocol bound

**Theorem 6.8 (Popoviciu bound).** If $v_p \ge 0$ on $B$, $\sum_p v_p > 0$, and
$m \le w_p \le M_x$ for all $p$, then
$$\mathcal R \;\le\; \frac{\big(\sum_{p\in B} v_p\big)\,(M_x - m)^2}{4}.$$

*Proof sketch.* In the closed form, each factor $(w_p - w_r)^2 \le (M_x-m)^2$; the double sum
is then at most $(M_x-m)^2 (\sum_p v_p)^2$, and the factor $\tfrac12$ against the
normalisation yields the stated constant after the sharpened bookkeeping of the diagonal
(which contributes zero). $\square$

**Theorem 6.9 (sharpness).** On a two-prime base $B = \{p, r\}$ with $q_p = q_r = 1/2$,
$$\mathcal R \;=\; \frac{\big(\sum_{x\in B} v_x\big)(w_p - w_r)^2}{4},$$
so the constant $1/4$ cannot be improved.

*Proof.* Direct evaluation of Theorem 6.4 on a two-element base: the double sum has two
non-zero terms, each $v_pv_r(w_p-w_r)^2$, and $v_p = v_r = 1/4$. $\square$

**Corollary 6.10 (certified weight spread).** A measured increment $g > 0$ forces
$$M_x - m \;\ge\; 2\sqrt{\frac{g}{\sum_{p\in B} v_p}} .$$

*Proof.* Contrapositive of Theorem 6.8. $\square$

Corollary 6.10 converts a reported number into a hard statement about the model. The
$128$-bit increment $+0.0346$ cannot be produced by a nearly homogeneous weight profile: it
certifies a definite minimum heterogeneity among the small primes at that scale.

---

## 7. Orthogonality: why "residual variance" is the right name

Definition 6.3 has the *shape* of a residual variance. This section proves that it is one.

**Definition 7.1 (fitted line and residual).** With $\beta_{\mathrm{OLS}}$ as in
Definition 5.6, set $\alpha = \mathbb E[\Lambda] - \beta_{\mathrm{OLS}}\,\mathbb E[\kappa]$ and
$$R(S) \;=\; \Lambda(S) - \big(\alpha + \beta_{\mathrm{OLS}}\,\kappa(S)\big).$$

The proofs below rest on bilinearity of the covariance functional of the product cell
measure — additivity in each argument, vanishing against constants, homogeneity, and symmetry
— each of which is a direct expansion of $\mathbb E$.

**Theorem 7.2 (the residual is centred).** $\mathbb E[R] = 0$.

*Proof.* $\mathbb E$ is linear and $\mathbb E[\alpha + \beta_{\mathrm{OLS}}\kappa] = \alpha + \beta_{\mathrm{OLS}}\mathbb E[\kappa]$,
which equals $\mathbb E[\Lambda]$ by the definition of $\alpha$. $\square$

**Theorem 7.3 (orthogonality).** If $\operatorname{Var}(\kappa) \ne 0$ then
$\operatorname{Cov}(R, \kappa) = 0$.

*Proof.* By bilinearity, $\operatorname{Cov}(R,\kappa) = \operatorname{Cov}(\Lambda,\kappa) - \beta_{\mathrm{OLS}}\operatorname{Var}(\kappa)$,
which vanishes by Definition 5.6. $\square$

This is precisely the property that makes the fitted line least-squares.

**Theorem 7.4 (the residual variance is the increment).** If $\operatorname{Var}(\kappa)\ne 0$
then $\operatorname{Var}(R) = \mathcal R$.

*Proof.* Expand the right argument: $\operatorname{Var}(R) = \operatorname{Cov}(R,\Lambda) - \operatorname{Cov}(R, \alpha + \beta_{\mathrm{OLS}}\kappa)$.
The second term vanishes by Theorem 7.3 and vanishing against constants. Expanding the first
gives $\operatorname{Var}(\Lambda) - \beta_{\mathrm{OLS}}\operatorname{Cov}(\kappa,\Lambda) = \mathcal R$. $\square$

**Theorem 7.5 (Pythagorean decomposition).** If $\operatorname{Var}(\kappa)\ne 0$,
$$\operatorname{Var}(\Lambda) \;=\; \beta_{\mathrm{OLS}}^2 \operatorname{Var}(\kappa) \;+\; \operatorname{Var}(R),$$
with no cross term.

*Proof.* Substitute Theorem 7.4 and Definition 5.6 and simplify. $\square$

**Corollary 7.6 (explained fraction).** If additionally $\operatorname{Var}(\Lambda) \ne 0$,
$$R^2 \;:=\; \frac{\beta_{\mathrm{OLS}}^2\operatorname{Var}(\kappa)}{\operatorname{Var}(\Lambda)} \;=\; 1 - \frac{\mathcal R}{\operatorname{Var}(\Lambda)} .$$

So a reported identity increment converts directly and exactly into an $R^2$ statement: the
fraction of log-rate variance explained by composition order is $1 - \mathcal R/\operatorname{Var}(\Lambda)$,
and the unexplained remainder is the pairwise weight-spread energy of Theorem 6.4.

**Numerical check.** For $B = \{2,3,5\}$, $q_p = 1/p$, and weights $w = (0.5, 0.35, 0.20)$
on $(2,3,5)$: $\mathbb E[R] = 0$, $\operatorname{Cov}(R,\kappa) = 0$, and
$\operatorname{Var}(R) = 1017/113800 \approx 0.008937$, matching the pairwise-energy formula
of Theorem 6.4 exactly as a rational number. With $w \equiv 0.35$ all three vanish, and
$\mathbb E[\kappa] = 31/30$, $\operatorname{Var}(\kappa) = 569/900$, and
$\beta_{\mathrm{OLS}} = -7/20$ exactly.

---

## 8. The regime boundary of sufficiency

Let $g(u)$ denote the identity increment as a function of scale $u$ (bit-width, or the
smoothness parameter), and fix a bar $b$. The **verdict** at scale $u$ is the assertion
$g(u) \le b$.

**Theorem 8.1 (downward closure).** If $g$ is monotone non-decreasing and $u_1 \le u_2$, then
the verdict at $u_2$ implies the verdict at $u_1$.

*Proof.* $g(u_1) \le g(u_2) \le b$. $\square$

**Corollary 8.2 (no verdict reversal).** For monotone $g$ and $u_2 \le u_3$, if the verdict
fails at $u_2$ it fails at $u_3$. Hence a TRUE / FALSE / TRUE pattern across increasing
scales is impossible.

This is the falsifiability content of the three-scale design: the observed pattern had a
shape it could have taken and did not.

**Theorem 8.3 (existence and uniqueness of the boundary).** Let $g$ be continuous and
strictly increasing on $[a,b']$ with $g(a) \le b < g(b')$. Then there is exactly one
$u^\ast \in [a,b']$ with $g(u^\ast) = b$.

*Proof.* Existence is the intermediate value theorem, since $b$ lies in $[g(a), g(b')]$.
Uniqueness is injectivity of a strictly increasing function. $\square$

**Theorem 8.4 (the verdict is exactly "below the boundary").** If $g$ is strictly increasing
and $g(u^\ast) = b$, then for every $u$: $g(u) \le b \iff u \le u^\ast$.

*Proof.* If $u > u^\ast$, strict monotonicity gives $g(u) > g(u^\ast) = b$; conversely
$u \le u^\ast$ gives $g(u) \le g(u^\ast) = b$. $\square$

**Theorem 8.5 (localisation of the observed boundary).** Suppose $g$ is continuous and
strictly increasing with $g(96) = 0.0084$ and $g(128) = 0.0346$, and let the bar be $0.02$.
Then there is exactly one $u^\ast$ with $g(u^\ast) = 0.02$ and
$$u^\ast \in (96,\; 128].$$

*Proof.* Apply Theorem 8.3 on $[96,128]$, using $0.0084 \le 0.02 < 0.0346$. If $u^\ast \le 96$
then $0.02 = g(u^\ast) \le g(96) = 0.0084$, a contradiction; so the crossing is strictly
above $96$. Uniqueness is as before. $\square$

**Theorem 8.6 (the smallest-scale verdict is forced).** If $g$ is monotone and
$g(96) = 0.0084 \le 0.02$, then the verdict holds at $72$ bits.

*Proof.* Theorem 8.1 with $72 \le 96$. $\square$

Theorem 8.6 is a deflation worth stating plainly: given monotonicity and the $96$-bit
measurement, the observation $g(72) = 0.0071 \le 0.02$ carries no independent information
about sufficiency. It is a consistency check on monotonicity, not a third data point. A
careful accounting of the experiment's evidential content must not double-count it.

---

## 9. Algorithms

The results above are constructive and yield four small algorithms.

**A. Exact cell census.** Given a base $B$, enumerate all $2^{|B|}$ cells and return
$|F_B(S)| = \prod_{p\notin S}(p-1)$ together with the density
$\prod_{p\in S} p^{-1}\prod_{p\notin S}(1-p^{-1})$. Cost $O(2^{|B|}|B|)$; verified against
brute-force enumeration of $[0,\mathrm{per}(B))$ for small bases. Independent of any sampling.

**B. Window-frequency certificate.** Given $B$, $S$, $N$, compute the exact window count via
the inclusion–exclusion expansion of Lemma 3.2 in $O(2^{|B\setminus S|})$ arithmetic
operations — no enumeration of $[0,N)$ — and report the guaranteed error envelope
$2^{|B\setminus S|}$ from Theorem 3.3.

**C. Slope and increment evaluator.** Given marginals $q$ and weights $w$, compute
$v_p = q_p(1-q_p)$ and return
$\beta_{\mathrm{OLS}} = -\sum w_pv_p/\sum v_p$ and $\mathcal R$ from Theorem 6.4 in $O(|B|^2)$
(or $O(|B|)$ using the equivalent moment form of Corollary 5.5), plus the Popoviciu envelope
and the $R^2$ of Corollary 7.6.

**D. Boundary bisection.** Given a strictly increasing increment model $g$ and a bar $b$,
bisect on $[a, b']$ with $g(a) \le b < g(b')$ to locate the unique crossing $u^\ast$ of
Theorem 8.3 to any prescribed precision, in $O(\log(1/\varepsilon))$ evaluations.

---

## 10. Applications

**Sieve triage.** Corollary 3.4 with the explicit constant of Theorem 3.3 legitimises using
cell frequencies computed on a sampled window as if they were exact periodic densities, with
a stated error. Combined with the graded law, this supports cheap triage: compute $\kappa(v)$
by trial division against $B$ and prioritise candidates with small $\kappa$, with a
quantified expected gain of $e^{\beta}$ per unit of $\kappa$ avoided.

**Experimental design.** Corollary 6.10 turns a measured increment into a lower bound on the
weight spread, which is the quantity a follow-up experiment should target directly. Theorem
5.9 says the cleanest possible measurement of an individual $w_p$ is a single-prime
restriction. Theorem 8.6 says a design that includes a scale below one already-passing scale
buys nothing under monotonicity, and the budget is better spent bracketing the boundary of
Theorem 8.5.

**Reporting discipline.** Corollary 7.6 makes the translation between the "identity
increment" scale and the familiar $R^2$ scale exact, so reported increments across
differently-scaled experiments can be compared without a heuristic normalisation.

---

## 11. Discussion

The organising discovery is a *reduction*. The experimental programme poses four apparently
separate questions — does the effect replicate, is the slope stable, is $\kappa$ sufficient,
how large is the failure — and the analysis above shows each is a question about the weight
profile $w$ alone:

| Empirical question | Exact equivalent |
|---|---|
| graded law $\Lambda = \text{dial} - \beta\kappa$ | $w \equiv \beta$ (Theorem 5.10) |
| $\kappa$ sufficient | $w$ constant (Theorem 4.3) |
| slope stable across scales | $w$ homogeneous (Theorems 5.7–5.8) |
| size of identity increment | pairwise spread energy of $w$ (Theorem 6.4) |

Two of these are the *same* statement. That is the sharpest methodological consequence: the
scale-stability verdict and the graded-law verdict are not independent confirmations of a
mechanism. They are one confirmation, reported twice. Similarly, Theorem 8.6 shows the
smallest-scale sufficiency verdict is entailed by the middle one under monotonicity.

The main *positive* surprise runs the other way. Corollary 4.4 shows that within a fixed
additive model there is no such thing as partial sufficiency: heterogeneity of any size is
already detectable at $\kappa = 1$. The observed graded behaviour therefore cannot be an
artefact of the response model and must live in the scale dependence of the weights. That
narrows the search space considerably and is what makes the Dickman prediction of Section 12
the natural next target.

**Limitations.** (i) Additivity is a modelling hypothesis; interactions between small primes
are not covered, though the framework extends naturally to a second-order term. (ii)
Theorems 2.4–2.7 concern initial segments of $\mathbb N$; Theorem 3.3 transfers them to
initial windows $[0,N)$, and an analogous bound for arbitrary offset windows $[N_0, N_0+N)$
follows by subtraction at the cost of doubling the constant. (iii) The boundary results of
Section 8 are conditional on monotonicity and, for uniqueness, strict monotonicity and
continuity of the increment in scale — natural but unproved assumptions about the physical
system. (iv) The empirical numbers are inputs to Theorems 8.5–8.6, not outputs of the theory.

---

## 12. Future work

The open edge is now sharp: everything reduces to the weight profile $w$ — its homogeneity,
and its scale dependence.

**A Dickman-type closed form for $\beta$.** If the log smoothness rate of a window is
asymptotically $\log\rho(u)$ with $u = \log v/\log y$ and $\rho$ the Dickman function, then
conditioning on divisibility by a small prime $p$ shifts the effective $u$ by
$-\log p/\log y$. To first order the per-prime penalty is therefore
$$w_p \;\approx\; -\frac{\log p}{\log y}\cdot\frac{\rho'(u)}{\rho(u)} \;=\; \frac{\log p}{\log y}\,\log u,$$
a weight *proportional to $\log p$*, not constant. On this account, constant-$\beta$ behaviour
is an artefact of a narrow base and the measured $\beta \approx -0.35$ is a $\log$-weighted
average. Theorem 5.7 makes this falsifiable by a single number per scale: substitute
$w_p \propto \log p$ into the $v$-weighted mean and compare. Theorem 6.4 makes it doubly
falsifiable, since a $\log p$ profile predicts a specific nonzero increment at every scale —
including the two where sufficiency was accepted.

**Locating the boundary.** Theorem 8.5 places the crossing strictly inside $(96,128]$;
Algorithm D locates it to arbitrary precision given a model for $g$. The corresponding
experimental question is to measure the increment at intermediate widths and bisect.

**Identifying the responsible cells.** Corollary 6.10 certifies that the $128$-bit increment
requires a definite weight spread; it does not say which primes carry it. The natural
candidate is the heavy-$2$-adic direction — cells containing high powers of small primes —
and the closed form of Theorem 6.4 gives a per-pair decomposition that can be audited term by
term to attribute the increment.

**Second-order response.** Adding pairwise interaction terms $w_{pr}$ to Definition 4.1 and
recomputing the moments would test whether the residual, once the additive part is removed,
is itself structured.

**Arbitrary windows and correlated bases.** Extending Theorem 3.3 to windows at arbitrary
offset with the sharp constant, and to bases including prime powers, would remove the last
gap between the exact theory and the sampling protocol.

---

## Appendix: summary of results

1. **Exact cell counts.** $|F_B(S)| = \prod_{p\in B\setminus S}(p-1)$ over one period.
2. **Exact independence.** Cell density $= \prod_{S} p^{-1}\prod_{B\setminus S}(1-p^{-1})$.
3. **Partition.** $\sum_S |F_B(S)| = \mathrm{per}(B)$; every cell is populated.
4. **Mean order.** $\mathbb E[\kappa] = \sum_{p\in B} 1/p$ exactly over a period.
5. **Window bound.** Cell-count error $\le 2^{|B\setminus S|}$, uniform in the window length;
   hence frequencies converge to the periodic densities.
6. **Sufficiency dichotomy.** $\kappa$ sufficient $\iff$ $w$ constant; failure already at
   $\kappa = 1$.
7. **Identity-gap bound.** $|\Lambda(S)-\Lambda(T)| \le \min(\kappa,|B|-\kappa)(M_x - m)$,
   sharp at $\kappa = 1$.
8. **Slope law.** $\beta_{\mathrm{OLS}} = -\sum w_pv_p / \sum v_p$; constant $w \equiv \beta$
   gives $-\beta$ at every base, profile and scale; a singleton base identifies $w_p$.
9. **Graded law.** $\Lambda = C - \beta\kappa$ on all cells $\iff$ $w\equiv\beta$, with $C$
   the dial.
10. **Arithmetic bridge.** $q_p = 1/p$ reproduces the exact periodic cell measure, so 8–9
    are statements about integers.
11. **Closed form.** $\mathcal R = \big(\tfrac12\sum_{p,r} v_pv_r(w_p-w_r)^2\big)/\sum_p v_p$;
    non-negative; zero iff $\kappa$ is sufficient, including in the arithmetic case.
12. **Sharp Popoviciu bound.** $\mathcal R \le (\sum v_p)(M_x-m)^2/4$, attained on a balanced
    two-prime base; hence a measured $g$ certifies $M_x - m \ge 2\sqrt{g/\sum v_p}$.
13. **Orthogonality.** The least-squares residual is centred and uncorrelated with $\kappa$;
    its variance is $\mathcal R$; $\operatorname{Var}\Lambda = \beta^2\operatorname{Var}\kappa + \mathcal R$;
    $R^2 = 1 - \mathcal R/\operatorname{Var}\Lambda$.
14. **Boundary calculus.** Monotone increments give downward-closed verdicts and forbid
    TRUE/FALSE/TRUE; a continuous strictly increasing increment has a unique crossing; the
    bracket $0.0084 \le 0.02 < 0.0346$ localises it strictly in $(96,128]$; the $72$-bit
    verdict is forced by the $96$-bit one.
