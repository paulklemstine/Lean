# Exact Single-Bit Leakage of Fork Readouts: A Universal Rational Profile, Its Phase Diagram, and a Conservation Law

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

We study the *fork* model: $n+1$ independent Bernoulli($p$) bits
$x_0,\dots,x_n$ observed only through a single scalar readout $F$, and we measure
what the readout reveals about the designated bit $x_0$ by the squared Pearson
correlation, or **leakage**,
$\mathcal{L}_p(F) = \operatorname{Cov}(x_0,F)^2 / (\operatorname{Var}(x_0)\operatorname{Var}(F))$.
Four readouts recur throughout the literature on fanout channels: the AND, the OR,
the parity (XOR), and the split count (Hamming weight). We compute all four exactly
and prove that they are one and the same rational function

$$\Phi(t,n) = \frac{t^{n}}{1+t+\cdots+t^{n}}$$

evaluated at four channel parameters: $p$ for AND, $1-p$ for OR, $(1-2p)^2$ for XOR,
and $1$ for the split count. Since $\Phi(\cdot,n)$ is strictly increasing for
$n \ge 1$, every ordering question about these channels reduces to an ordering
question about four numbers, *independently of the fork size*. Three consequences
follow. (i) The split-count channel dominates all three Boolean channels at every
bias and every size, with the exact value $1/(n+1)$. (ii) No size-dependent crossover
between any two of the channels can exist; in particular the widely reported
"AND overtakes XOR at $n = 8$" is an artifact — the sign of $A - X$ depends only on
whether $p \gtrless 1/4$. (iii) The ratio $X/g$ never converges to $2$ for any bias;
its behaviour is a trichotomy pivoting on the single critical bias $p = 3/4$, where
XOR and OR coincide identically in $n$.

We then prove three structural theorems that place these computations in context.
*Product universality*: for any non-constant coordinate function $c$, the readout
$F(x) = \prod_i c(x_i)$ has leakage $\Phi(m^2/s, n)$ with $m = \mathbb{E}c$ and
$s = \mathbb{E}c^2$, and $m^2/s < 1$ always — so the split-count profile is
unreachable by any product readout, all product readouts decay geometrically, and no
two of them ever swap order. *Symmetric optimality*: every permutation-invariant
readout obeys $\mathcal{L}_p(F) \le 1/(n+1)$, with equality if and only if $F$ is a
non-degenerate affine function of the Hamming weight; the split count is therefore
the unique optimal symmetric readout up to affine changes. *Total-leakage sum rule*:
for any readout of an $N$-bit fork, $\sum_i \mathcal{L}_p^{(i)}(F) \le 1$, with slack
exactly the normalised mean square of the readout's nonlinear part, equality
precisely for affine readouts, and consequences including a pigeonhole bound
$\#\{i : \mathcal{L}^{(i)} \ge \tau\} \le 1/\tau$ and the fact that at most one bit
can be more than half-leaked. Exact rational tables at $25$ bits close the numerical
record.

**Keywords:** fork channel, single-bit leakage, squared Pearson correlation,
Boolean readouts, Hamming weight, Bessel inequality, phase diagram, rational profile.

---

## 1. Introduction

### 1.1 The fork problem

A great many measurement situations have the same shape. A source of randomness fans
out into many parallel components; a single scalar observation aggregates them; and
one wants to know how much of one designated component survives the aggregation.
Side-channel analysis asks it of power traces that combine many register bits.
Feature attribution asks it of pooled activations. Sensor design asks it of any
statistic that summarises an array. Identifiability analysis asks it of any
sufficient statistic that is not sufficient enough.

We call the abstraction a **fork**. Its ingredients are:

- a **source**: $n+1$ independent bits $x_0, x_1, \dots, x_n$, each equal to $1$
  with probability $p \in (0,1)$;
- a **readout** (or **channel**): an arbitrary function
  $F : \{0,1\}^{n+1} \to \mathbb{R}$;
- a **designated bit**, conventionally $x_0$.

The four readouts that dominate the literature are the conjunction, the disjunction,
the parity, and the count. Written on the bit pattern $x$:

| name | symbol | readout |
|---|---|---|
| AND channel | $A$ | $\prod_i x_i$ |
| OR channel | $g$ | $1 - \prod_i (1-x_i)$ |
| XOR channel | $X$ | $\big(1 - \prod_i(1-2x_i)\big)/2$ |
| split-count channel | $\mathrm{Is}$ | $w(x) = \sum_i x_i$ |

Historically these have been compared by tabulation: compute the four correlations at
each fork size and read the pattern off the table. Tabulation is fragile. Two
distinct pathologies contaminate it, and both were encountered before the present
work: an *unnormalised weighting*, where the assumed distribution over bit patterns
does not sum to one, and *non-summing distributions*, where the marginals used in the
covariance are inconsistent with the joint. Both produce plausible-looking numbers,
and both were only excluded once every expectation was written as an exact finite sum
against exact product weights with complement forms imposed. Two conclusions read off
the contaminated tables — a size-dependent crossover at $n=8$ and an asymptotic ratio
$X/g \to 2$ — are refuted below.

### 1.2 What we measure

**Definition 1.1 (Fork weights and expectation).** For $p \in (0,1)$ and
$x \in \{0,1\}^{N}$ put
$$
w_p(x) = \prod_{i=1}^{N} \big(p^{x_i}(1-p)^{1-x_i}\big),
\qquad
\mathbb{E}_p[F] = \sum_{x \in \{0,1\}^N} w_p(x) F(x).
$$

**Lemma 1.2 (Master factorisation).** For any family of coordinate functions
$g_i : \{0,1\} \to \mathbb{R}$,
$$
\mathbb{E}_p\Big[\prod_i g_i(x_i)\Big] = \prod_i \big(p\, g_i(1) + (1-p) g_i(0)\big).
$$

*Proof sketch.* Expand the product of the $N$ two-term sums
$\sum_{b \in \{0,1\}} (\text{weight of } b)\, g_i(b)$ using distributivity over the
product index set; the resulting terms are in bijection with bit patterns $x$, and
the coefficient of $\prod_i g_i(x_i)$ is exactly $w_p(x)$. $\square$

Taking all $g_i \equiv 1$ gives $\mathbb{E}_p[1] = 1$: the weights sum to one. This
is not a triviality to be waved through — it is the precise statement that no
unnormalised weighting can hide in the computation, and every expectation below is
derived from Lemma 1.2 rather than assumed.

**Definition 1.3 (Covariance, variance, leakage).** For readouts $F, G$,
$$
\operatorname{Cov}_p(F,G) = \mathbb{E}_p[FG] - \mathbb{E}_p[F]\,\mathbb{E}_p[G],
\qquad
\operatorname{Var}_p(F) = \operatorname{Cov}_p(F,F),
$$
$$
\rho^2_p(F,G) = \frac{\operatorname{Cov}_p(F,G)^2}{\operatorname{Var}_p(F)\operatorname{Var}_p(G)},
\qquad
\mathcal{L}_p(F) = \rho^2_p(x_0, F).
$$

We call $\mathcal{L}_p(F)$ the **leakage** of the readout about the designated bit.
It lies in $[0,1]$; it is $0$ when $F$'s fluctuations are uncorrelated with $x_0$;
and it is invariant under $F \mapsto \alpha F + \beta$ for $\alpha \neq 0$, which is
the statement that the units and offset of the dial carry no information.

**Definition 1.4 (Channels).** With $n+1$ bits,
$A(p,n) = \mathcal{L}_p(\mathrm{AND})$, $g(p,n) = \mathcal{L}_p(\mathrm{OR})$,
$X(p,n) = \mathcal{L}_p(\mathrm{XOR})$, $\mathrm{Is}(p,n) = \mathcal{L}_p(w)$. Here
$n$ counts the *non-designated* bits.

### 1.3 The universal profile

**Definition 1.5 (Fork profile).** For $t \ge 0$ and $n \in \mathbb{N}$,
$$
\Phi(t,n) = \frac{t^{n}}{\sum_{k=0}^{n} t^{k}}.
$$

Equivalently $\Phi(t,n) = t^n(1-t)/(1-t^{n+1})$ for $t \neq 1$, and
$\Phi(1,n) = 1/(n+1)$.

The organising theorem of this paper is that all four channels are values of $\Phi$.

---

## 2. The channel collapse

**Theorem 2.1 (Channel collapse).** *For every $p \in (0,1)$ and every $n \ge 0$,*
$$
A(p,n) = \Phi(p,n), \qquad
g(p,n) = \Phi(1-p,n), \qquad
X(p,n) = \Phi\big((1-2p)^2, n\big), \qquad
\mathrm{Is}(p,n) = \Phi(1,n) = \frac{1}{n+1}.
$$

*Proof sketch.* Each case is an application of Lemma 1.2 followed by the geometric
identity $1 - t^{n+1} = (1-t)\sum_{k=0}^n t^k$.

*AND.* Write $\mathrm{AND}(x) = \prod_i \mathbb{1}[x_i = 1]$. The readout is
idempotent, $\mathrm{AND}^2 = \mathrm{AND}$, and absorbs the designated indicator,
$x_0 \cdot \mathrm{AND} = \mathrm{AND}$. Lemma 1.2 gives
$\mathbb{E}_p[\mathrm{AND}] = p^{\,n+1}$, hence
$$
\operatorname{Cov}_p(x_0,\mathrm{AND}) = p^{\,n+1} - p\cdot p^{\,n+1} = p^{\,n+1}(1-p),
\qquad
\operatorname{Var}_p(\mathrm{AND}) = p^{\,n+1}\big(1 - p^{\,n+1}\big),
$$
and with $\operatorname{Var}_p(x_0) = p(1-p)$,
$$
A = \frac{p^{2n+2}(1-p)^2}{p(1-p)\cdot p^{\,n+1}(1-p^{\,n+1})}
  = \frac{p^{\,n}(1-p)}{1-p^{\,n+1}} = \Phi(p,n).
$$

*OR.* Let $\mathrm{NOR}(x) = \prod_i \mathbb{1}[x_i = 0]$, so
$\mathrm{OR} = 1 - \mathrm{NOR}$. Then $x_0 \cdot \mathrm{NOR} = 0$, hence
$x_0\cdot \mathrm{OR} = x_0$; $\mathrm{OR}$ is idempotent; and
$\mathbb{E}_p[\mathrm{NOR}] = (1-p)^{n+1}$. Therefore
$\operatorname{Cov}_p(x_0,\mathrm{OR}) = p(1-p)^{n+1}$ and
$\operatorname{Var}_p(\mathrm{OR}) = (1-p)^{n+1}(1-(1-p)^{n+1})$, giving
$g = \Phi(1-p,n)$ after the same cancellation with $1 - (1-p)^{n+1} = p\sum_k(1-p)^k$.

*XOR.* Use the $\pm 1$ parity $\pi(x) = \prod_i (1-2x_i)$, so
$\mathrm{XOR} = (1-\pi)/2$. Lemma 1.2 gives
$\mathbb{E}_p[\pi] = (1-2p)^{n+1}$ and, splitting on $x_0$,
$\mathbb{E}_p[x_0\pi] = -p(1-2p)^{n}$. Hence
$\operatorname{Cov}_p(x_0,\mathrm{XOR}) = p(1-p)(1-2p)^n$. Since
$\pi^2 \equiv 1$, $\mathrm{XOR}$ is idempotent and
$\operatorname{Var}_p(\mathrm{XOR}) = \big(1-(1-2p)^{2n+2}\big)/4$. Writing
$d = (1-2p)^2$ and using $1 - d = 4p(1-p)$,
$$
X = \frac{p^2(1-p)^2 d^{\,n}}{p(1-p)\cdot \tfrac14(1 - d^{\,n+1})}
  = \frac{d^{\,n}(1-d)}{1-d^{\,n+1}} = \Phi(d,n).
$$

*Split count.* $\operatorname{Cov}_p(x_0, w) = \sum_i \operatorname{Cov}_p(x_0,x_i) =
\operatorname{Var}_p(x_0) = p(1-p)$ by independence, and
$\operatorname{Var}_p(w) = (n+1)p(1-p)$. Thus
$\mathrm{Is} = \frac{p^2(1-p)^2}{p(1-p)(n+1)p(1-p)} = \frac{1}{n+1} = \Phi(1,n)$.
$\square$

The four parameters have transparent meaning. AND is sensitive to the event that all
bits are "on", whose probability is $p$ per bit — hence $t = p$. OR is the complement
statement, hence $t = 1-p$. Parity is sensitive to the *bias gap* $1-2p$, and the
correlation squares it, hence $t = (1-2p)^2$. The counter forgets nothing about how
many bits are on, hence $t = 1$, the maximal value the profile is ever asked for.

---

## 3. Monotonicity, and why orderings are size-free

**Theorem 3.1 (Strict monotonicity of the profile).** *Let $0 \le s \le t$. Then
$\Phi(s,n) \le \Phi(t,n)$ for all $n$, and if $s < t$ and $n \ge 1$ the inequality is
strict. Consequently, for $n \ge 1$ and $s,t \ge 0$:*
$$
\Phi(s,n) \le \Phi(t,n) \iff s \le t, \qquad
\Phi(s,n) = \Phi(t,n) \iff s = t.
$$

*Proof sketch.* The denominators $\sum_k s^k$ and $\sum_k t^k$ are strictly positive.
Cross-multiplying, the claim is $s^n \sum_{k=0}^n t^k \le t^n \sum_{k=0}^n s^k$,
which follows term by term from
$$
s^{n} t^{k} \le t^{n} s^{k} \quad (0 \le k \le n),
$$
since $s^n t^k = s^k t^k s^{n-k} \le s^k t^k t^{n-k} = t^n s^k$. For strictness with
$n \ge 1$, the $k = 0$ term already gives $s^n < t^n$ unless $s = t$. $\square$

**Corollary 3.2 (Order rigidity).** *Fix $p \in (0,1)$ and $n \ge 1$. The ordering of
the four channels is exactly the ordering of the four parameters $p$, $1-p$,
$(1-2p)^2$, $1$, and therefore does not depend on $n$.*

This single corollary settles the three hypotheses that motivated the tabulation
programme.

**Theorem 3.3 (H1: split-count dominance).** *For every $p \in (0,1)$ and every $n$,*
$$
\max\big(A(p,n),\, g(p,n),\, X(p,n)\big) \le \mathrm{Is}(p,n) = \frac{1}{n+1},
$$
*and the inequality is strict for $n \ge 1$.*

*Proof.* $p < 1$, $1-p<1$ and $(1-2p)^2 < 1$ for $p \in (0,1)$; apply Theorem 3.1
with $t = 1$. $\square$

**Theorem 3.4 (Bias thresholds replace size thresholds).** *For $n \ge 1$,*
$$
A(p,n) \ge g(p,n) \iff p \ge \tfrac12,
\qquad
A(p,n) \ge X(p,n) \iff p \ge \tfrac14 .
$$

*Proof.* By Theorem 3.1, $A \ge g \iff p \ge 1-p$, and $A \ge X \iff p \ge (1-2p)^2$,
i.e. $4p^2 - 5p + 1 \le 0$, i.e. $(4p-1)(p-1) \le 0$, i.e. $p \ge 1/4$ (using
$p < 1$). $\square$

**Theorem 3.5 (Crossover freedom; refutation of the $n=8$ crossover).** *Fix
$p \in (0,1)$ and let $m, n \ge 1$. If $A(p,m) \le X(p,m)$ then $A(p,n) \le X(p,n)$;
likewise for the pair $(A,g)$. In particular no fork size at which the AND channel
"overtakes" the XOR channel can exist.*

*Proof.* Both sides of each comparison are $\Phi$ at parameters that do not depend on
the size, and Theorem 3.1 converts the comparison into a size-free comparison of
parameters. $\square$

The reported crossover at $n = 8$ is therefore an artifact of the numerics rather
than a property of the model — precisely the sort of conclusion that unnormalised
weights or inconsistent marginals produce, since both corrupt the covariance in a
size-dependent way.

**Theorem 3.6 (H2: universal decay).** *For every $p \in (0,1)$, each of
$A(p,n), g(p,n), X(p,n), \mathrm{Is}(p,n) \to 0$ as $n \to \infty$. Moreover
$\Phi(t,n) \le 1/(n+1)$ for $0 \le t \le 1$, and $\Phi(t,n) \le t^n$ for all $t \ge 0$,
so the three Boolean channels decay geometrically while the split-count channel decays
like $1/(n+1)$.*

*Proof sketch.* The bound $\Phi(t,n) \le 1/(n+1)$ is Theorem 3.1 at $t \le 1$
combined with $\Phi(1,n) = 1/(n+1)$; squeeze with $1/(n+1) \to 0$. The bound
$\Phi(t,n) \le t^n$ holds because the denominator is at least $1$ (its $k=0$ term).
$\square$

**Theorem 3.7 (Boolean channels are $o(1/n)$).** *For every $p \in (0,1)$,
$(n+1)\,A(p,n) \to 0$, and likewise for $g$ and $X$; equivalently
$A/\mathrm{Is} \to 0$. The split count is not merely the largest channel, it is on a
strictly slower decay scale.*

*Proof sketch.* For $0 \le t < 1$, $(n+1)\Phi(t,n) \le (n+1)t^n \to 0$. Each Boolean
parameter is $<1$. $\square$

---

## 4. The $X/g$ trichotomy: refutation of the asymptotic ratio $2$

The remaining tabulated hypothesis asserted $X/g \to 2$. It is false at every bias,
and the reason is a single critical point.

**Theorem 4.1 (Ratio decay).** *Let $0 \le s < t \le 1$. Then
$\Phi(s,n)/\Phi(t,n) \to 0$ as $n \to \infty$, and in fact
$\Phi(s,n)/\Phi(t,n) \le (n+1)(s/t)^n$.*

*Proof sketch.* Numerator: $\Phi(s,n) \le s^n$. Denominator:
$\Phi(t,n) \ge t^n/(n+1)$ because for $t \le 1$ each of the $n+1$ terms of the
denominator sum is at most $1$. Divide, and note $(n+1)r^n \to 0$ for $r<1$. $\square$

**Theorem 4.2 (Exact XOR/OR degeneracy).** *For $n \ge 1$ and $p \in (0,1)$,*
$$
X(p,n) = g(p,n) \iff p = \tfrac34 ,
$$
*and at $p = 3/4$ the equality holds identically in $n$.*

*Proof.* By Theorem 3.1, equality holds iff $(1-2p)^2 = 1-p$, i.e.
$4p^2 - 3p = 0$, i.e. $p \in \{0, 3/4\}$; only $3/4$ lies in $(0,1)$. $\square$

**Theorem 4.3 (H3 refuted).** *For no $p \in (0,1)$ does $X(p,n)/g(p,n)$ converge to
$2$. Precisely:*

- *if $0 < p < 3/4$, then $X/g \to 0$ geometrically;*
- *if $p = 3/4$, then $X/g \equiv 1$;*
- *if $3/4 < p < 1$, then $g/X \to 0$, so $X/g \to \infty$.*

*Proof sketch.* $(1-2p)^2 < 1-p \iff 4p^2-3p < 0 \iff p < 3/4$; apply Theorem 4.1 in
the appropriate direction, and Theorem 4.2 at the critical point. Uniqueness of
limits then excludes the value $2$ in each of the three cases. $\square$

The empirical evidence that motivated the conjecture — a ratio observed to rise from
about $5.93$ at $n=5$ to about $6.43$ at $n=25$ — is consistent with a *divergent*
ratio at a bias above $3/4$, misread as a slowly converging one. The exact algebra
shows the sequence has no finite limit there at all.

---

## 5. Phase diagram of the three Boolean channels

Because the ordering is decided by the four parameters, the bias interval $(0,1)$ is
partitioned by the three critical values $1/4$, $1/2$, $3/4$, at each of which
exactly one pair of channels merges.

**Theorem 5.1 (Four regimes).** *For every $n \ge 1$:*

| regime | ordering |
|---|---|
| $0 < p < 1/4$ | $A < X < g < \mathrm{Is}$ |
| $1/4 < p < 1/2$ | $X < A < g < \mathrm{Is}$ |
| $1/2 < p < 3/4$ | $X < g < A < \mathrm{Is}$ |
| $3/4 < p < 1$ | $g < X < A < \mathrm{Is}$ |

*Proof sketch.* Each row is the corresponding ordering of $\{(1-2p)^2, p, 1-p, 1\}$
transported through Theorem 3.1. The two elementary inequalities that generate the
table are $(1-2p)^2 < p \iff p > 1/4$ and $(1-2p)^2 < 1-p \iff p < 3/4$, together
with $p < 1-p \iff p < 1/2$. $\square$

**Theorem 5.2 (Critical merges).** *For every $n$:*
$A(1/4,n) = X(1/4,n)$; $\;A(1/2,n) = g(1/2,n)$; $\;X(3/4,n) = g(3/4,n)$.
*Each merge holds identically in the fork size.*

**Theorem 5.3 (Parity blindness).** *For $n \ge 1$ and $p \in (0,1)$,
$X(p,n) = 0 \iff p = 1/2$.*

*Proof.* $\Phi(t,n) = 0 \iff t = 0$ for $n\ge1$, and $(1-2p)^2 = 0 \iff p = 1/2$.
$\square$

This is the classical fact that the parity of unbiased independent bits is
independent of any single one of them, recovered as the vanishing of a channel
parameter. It is also the reason parity is the canonical masking primitive: at the
unbiased point it leaks nothing at first order, and the leakage grows only
quadratically in the bias gap.

**Theorem 5.4 (No triple point).** *For $n \ge 1$ and $p \in (0,1)$ it is impossible
that $A = g$ and $g = X$ simultaneously.*

*Proof.* $A = g$ forces $p = 1/2$ by Theorem 3.1; then $X$ has parameter $0$ and
$g$ has parameter $1/2 \neq 0$. $\square$

So the three merges are pairwise and isolated: the phase diagram of the Boolean
channels has three walls and no corner.

---

## 6. Exact tables at 25 bits

The profile has an exact rational evaluation.

**Lemma 6.1 (Rational form).** *For $0 \le a < b$,*
$$
\Phi\!\left(\frac{a}{b}, n\right) = \frac{a^{n}(b-a)}{b^{\,n+1} - a^{\,n+1}} .
$$

*Proof sketch.* Substitute into $\Phi(t,n) = t^n(1-t)/(1-t^{n+1})$ and clear
denominators by $b^{n+1}$. $\square$

**Theorem 6.2 (Closed 25-bit table).** *At $p = 1/3$ and $25$ bits (i.e. $n = 24$),*
$$
\mathrm{Is} = \frac{1}{25},
\qquad
g = \frac{16777216}{847255055011},
\qquad
A = \frac{1}{423644304721},
\qquad
X = \frac{1}{89737248461481573596281},
$$
*and consequently $X < A < g < \mathrm{Is}$.*

*Proof sketch.* $\mathrm{Is} = 1/(n+1)$. For $A$, Lemma 6.1 with $a/b = 1/3$ and
$n=24$ gives $2/(3^{25}-1) = 2/847288609442 = 1/423644304721$. For $g$, $a/b = 2/3$
gives $2^{24}\cdot 1/(3^{25}-2^{25}) = 16777216/847255055011$. For $X$,
$(1-2/3)^2 = 1/9$ gives $8/(9^{25}-1) = 1/89737248461481573596281$. Numerically these
are $4.0 \times 10^{-2}$, $1.98 \times 10^{-5}$, $2.36\times10^{-12}$,
$1.11\times10^{-23}$. $\square$

The spread of twenty-one orders of magnitude between $X$ and $\mathrm{Is}$ at this
modest size explains why floating-point tabulation is not merely inaccurate but
qualitatively misleading: the smallest entries are far below the resolution at which
double-precision covariance estimates retain any significant digits, and the resulting
noise is exactly what a spurious crossover looks like. Since Theorem 5.1 makes the
ordering size-free, the row above is the ordering at *every* size for $p = 1/3$, and
the table is closed in the strongest sense: not extended to $n = 25$, but replaced by
a formula valid for all $n$.

---

## 7. Product universality: why one profile suffices

The collapse of Theorem 2.1 is not a coincidence of three gates. It is a theorem
about all *multiplicative* readouts.

**Definition 7.1.** For a coordinate function $c : \{0,1\} \to \mathbb{R}$ define the
product readout $P_c(x) = \prod_{i} c(x_i)$, and the two moments
$$
m = m_p(c) = p\,c(1) + (1-p)\,c(0),
\qquad
s = s_p(c) = p\,c(1)^2 + (1-p)\,c(0)^2 .
$$
The **product parameter** is $\theta_p(c) = m^2/s$.

**Lemma 7.2 (Moment gap).** $s - m^2 = p(1-p)\,\big(c(1)-c(0)\big)^2$.
*In particular, if $c$ is non-constant and $p \in (0,1)$, then $0 \le m^2 < s$, so
$0 \le \theta_p(c) < 1$.*

*Proof.* Direct expansion; the identity is the variance of a two-point random
variable. $\square$

**Theorem 7.3 (Product universality).** *Let $p \in (0,1)$ and let $c$ be
non-constant. Then for an $(n+1)$-bit fork*
$$
\mathcal{L}_p(P_c) = \Phi\big(\theta_p(c),\, n\big).
$$

*Proof sketch.* By Lemma 1.2, $\mathbb{E}_p[P_c] = m^{\,n+1}$ and
$\mathbb{E}_p[P_c^2] = s^{\,n+1}$ (the latter because $P_c^2 = P_{c^2}$
coordinatewise). Conditioning the designated coordinate,
$\mathbb{E}_p[x_0 P_c] = p\,c(1)\,m^{\,n}$. Hence
$$
\operatorname{Cov}_p(x_0,P_c) = p\,m^{\,n}\big(c(1) - m\big) = p(1-p)\,m^{\,n}\big(c(1)-c(0)\big),
$$
using $c(1) - m = (1-p)(c(1)-c(0))$, and
$\operatorname{Var}_p(P_c) = s^{\,n+1} - m^{\,2n+2}$. Therefore
$$
\mathcal{L}_p(P_c) = \frac{p^2(1-p)^2 m^{2n}(c(1)-c(0))^2}{p(1-p)\big(s^{\,n+1} - (m^2)^{\,n+1}\big)}
= \frac{(m^2)^{\,n}\,\big(s - m^2\big)}{s^{\,n+1} - (m^2)^{\,n+1}},
$$
after substituting Lemma 7.2, and this is exactly $\Phi(m^2/s, n)$ by Lemma 6.1 with
$a = m^2$, $b = s$. $\square$

**Corollary 7.4 (Re-derivation of the three Boolean channels).** *Leakage is invariant
under $F \mapsto \alpha F + \beta$ with $\alpha \neq 0$. Applying Theorem 7.3:*

- $c(1)=1,\, c(0)=0$: $m = s = p$, $\theta = p$, giving $A = \Phi(p,n)$;
- $c(1)=0,\, c(0)=1$: $m = s = 1-p$, $\theta = 1-p$, giving the NOR readout profile,
  and hence, by affine invariance applied to $\mathrm{OR} = 1 - \mathrm{NOR}$,
  $g = \Phi(1-p,n)$;
- $c(1)=-1,\, c(0)=1$: $m = 1-2p$, $s = 1$, $\theta = (1-2p)^2$, and hence, by affine
  invariance applied to $\mathrm{XOR} = (1-\pi)/2$, $X = \Phi((1-2p)^2,n)$.

**Theorem 7.5 (Structural consequences for the whole product class).** *Let $p \in (0,1)$
and let $c, d$ be non-constant coordinate functions. Then for $n \ge 1$:*

1. *(Strict $H1$.)* $\mathcal{L}_p(P_c) < 1/(n+1) = \mathrm{Is}(p,n)$. *No product
   readout can match the split count, at any size.*
2. *(Universal $H2$.)* $\mathcal{L}_p(P_c) \to 0$ as $n \to \infty$, geometrically at
   rate $\theta_p(c) < 1$.
3. *(Universal crossover freedom.)* $\mathcal{L}_p(P_c) \le \mathcal{L}_p(P_d)$ if and
   only if $\theta_p(c) \le \theta_p(d)$; in particular if the inequality holds at one
   fork size it holds at every fork size.

*Proof.* Combine Theorem 7.3, Lemma 7.2 and Theorem 3.1. $\square$

Item 3 is the general form of the crossover refutation: *no* pair of product readouts
can ever swap order as the fork grows, for the trivial reason that their relative
order is encoded in two size-independent numbers. The AND/XOR pair is a special case.

The parameter $\theta_p(c) = m^2/s$ has a clean interpretation: it is the squared
cosine of the angle, in the one-bit inner-product space, between the coordinate
function $c$ and the constant function. A coordinate function nearly parallel to a
constant has $\theta$ close to $1$ and its product readout leaks nearly as much as the
counter; a coordinate function nearly orthogonal to constants — parity at $p=1/2$ is
exactly orthogonal — has $\theta$ near $0$ and its product readout leaks essentially
nothing.

---

## 8. Symmetric optimality: the counter is the unique optimum

The dominance of the split count is not an accident of the algebra; it follows from
exchangeability alone.

**Definition 8.1.** A readout $F$ on $\{0,1\}^{N}$ is **symmetric** if
$F(x \circ \sigma) = F(x)$ for every permutation $\sigma$ of the coordinates.

**Lemma 8.2 (Permutation invariance of the fork functional).** $w_p(x\circ\sigma) = w_p(x)$
and hence $\mathbb{E}_p[F \circ \sigma] = \mathbb{E}_p[F]$ for all $F$ and $\sigma$.

**Lemma 8.3 (Equal covariances).** *If $F$ is symmetric then
$\operatorname{Cov}_p(x_i, F)$ is the same for all $i$, and therefore*
$$
\operatorname{Cov}_p(w, F) = (n+1)\operatorname{Cov}_p(x_0, F).
$$

*Proof sketch.* Transport by the transposition exchanging $0$ and $i$, using
Lemma 8.2 and $F \circ \sigma = F$; then sum over $i$. $\square$

**Lemma 8.4 (Cauchy–Schwarz for the fork functional).**
$\operatorname{Cov}_p(F,G)^2 \le \operatorname{Var}_p(F)\operatorname{Var}_p(G)$.

*Proof sketch.* $\lambda \mapsto \operatorname{Var}_p(F + \lambda G)$ is a
non-negative quadratic in $\lambda$ (non-negativity because the weights are
non-negative and the variance is a mean square); its discriminant is
$4(\operatorname{Cov}^2 - \operatorname{Var}\operatorname{Var})$, which must
therefore be $\le 0$. $\square$

**Theorem 8.5 (Symmetric optimality).** *For $p \in (0,1)$, every symmetric readout of
an $(n+1)$-bit fork satisfies*
$$
\mathcal{L}_p(F) \le \frac{1}{n+1},
$$
*and the Hamming weight attains the bound.*

*Proof sketch.* If $\operatorname{Var}_p(F) = 0$ the leakage is $0$. Otherwise apply
Lemma 8.4 to the pair $(w,F)$, substitute Lemma 8.3 and
$\operatorname{Var}_p(w) = (n+1)p(1-p)$:
$$
(n+1)^2\operatorname{Cov}_p(x_0,F)^2 \le (n+1)p(1-p)\operatorname{Var}_p(F),
$$
so $\operatorname{Cov}_p(x_0,F)^2 \le \frac{p(1-p)}{n+1}\operatorname{Var}_p(F)$;
dividing by $\operatorname{Var}_p(x_0)\operatorname{Var}_p(F) = p(1-p)\operatorname{Var}_p(F)$
gives the claim. $\square$

**Theorem 8.6 (Equality case).** *Let $p\in(0,1)$ and let $F$ be symmetric. Then*
$$
\mathcal{L}_p(F) = \frac{1}{n+1}
\iff
\exists\, \alpha \neq 0,\ \beta \in \mathbb{R} : \ F(x) = \alpha\, w(x) + \beta \ \ \text{for all } x .
$$

*Proof sketch.* ($\Leftarrow$) Affine invariance of leakage plus
$\mathrm{Is} = 1/(n+1)$. ($\Rightarrow$) Equality in Lemma 8.4 forces the
discriminant to vanish, i.e. $\operatorname{Var}_p\!\big(F - \lambda w\big) = 0$ for
$\lambda = \operatorname{Cov}_p(w,F)/\operatorname{Var}_p(w)$. Since all weights
$w_p(x)$ are strictly positive for $p \in (0,1)$, a readout of zero variance is
constant, so $F = \lambda w + \beta$; and $\lambda \neq 0$ because otherwise $F$ is
constant and $\mathcal{L}_p(F) = 0 \neq 1/(n+1)$. $\square$

Thus the split count is, up to affine reparametrisation, the **unique** optimal
symmetric readout. Every symmetric alternative — thresholds, majority votes, medians,
truncated counts, and of course AND/OR/XOR — sits strictly below the bound, and the
amount by which it does so is exactly the amount of the count it destroys.

---

## 9. A conservation law: the total-leakage sum rule

Everything so far concerns a single designated bit. The final structural theorem
concerns all of them at once, and holds for arbitrary readouts.

**Definition 9.1.** For an $N$-bit fork let $z_i(x) = x_i - p$ be the centred bit
indicators, and for a readout $F$ define the projection coefficients and residual
$$
\pi_i(F) = \frac{\operatorname{Cov}_p(x_i,F)}{p(1-p)},
\qquad
R_F(x) = F(x) - \mathbb{E}_p[F] - \sum_{i=1}^{N}\pi_i(F)\,z_i(x).
$$

**Lemma 9.2 (Orthogonality).** $\mathbb{E}_p[z_i z_j] = p(1-p)\delta_{ij}$, and
$\mathbb{E}_p[F z_i] = \operatorname{Cov}_p(x_i, F)$.

**Lemma 9.3 (Residual identity).**
$$
\mathbb{E}_p\big[R_F^2\big]
= \operatorname{Var}_p(F) - \frac{1}{p(1-p)}\sum_{i=1}^{N}\operatorname{Cov}_p(x_i,F)^2 .
$$

*Proof sketch.* Expand the square and apply Lemma 9.2; the cross terms collapse to
twice the sum of squared projections, leaving the stated difference. This is the
Pythagoras identity for the orthogonal decomposition of $F$ into its constant, its
linear part in the centred indicators, and its nonlinear residual. $\square$

**Theorem 9.4 (Bessel's inequality for forks).** *For any readout $F$,*
$$
\sum_{i=1}^{N}\operatorname{Cov}_p(x_i,F)^2 \le p(1-p)\operatorname{Var}_p(F).
$$

*Proof.* $\mathbb{E}_p[R_F^2] \ge 0$ in Lemma 9.3. $\square$

**Theorem 9.5 (Total-leakage sum rule).** *For any readout $F$ of an $N$-bit fork,*
$$
\sum_{i=1}^{N} \rho^2_p(x_i, F) \le 1 .
$$
*If $\operatorname{Var}_p(F) > 0$, the exact identity is*
$$
\sum_{i=1}^{N} \rho^2_p(x_i, F) = 1 - \frac{\mathbb{E}_p[R_F^2]}{\operatorname{Var}_p(F)} ,
$$
*so the slack is precisely the normalised mean square of the readout's nonlinear part.*

*Proof.* Divide Theorem 9.4 by $p(1-p)\operatorname{Var}_p(F)$, noting
$\operatorname{Var}_p(x_i) = p(1-p)$ for every $i$; the identity is Lemma 9.3 in the
same normalisation. $\square$

**Theorem 9.6 (Saturation family).** *Let $\operatorname{Var}_p(F) > 0$. Then
$\sum_i \rho^2_p(x_i,F) = 1$ if and only if $F$ is affine in the bit indicators, i.e.
$F(x) = \beta + \sum_i b_i x_i$ for some coefficients $b_i$ and constant $\beta$.*

*Proof sketch.* Equality forces $\mathbb{E}_p[R_F^2] = 0$; since all fork weights are
strictly positive, this forces $R_F \equiv 0$ pointwise, which is exactly the stated
affine form with $b_i = \pi_i(F)$. Conversely, for affine $F$ the residual vanishes
identically. $\square$

**Theorem 9.7 (Tightness).** *The split count saturates the sum rule:
$\sum_i \rho^2_p(x_i, w) = (n+1)\cdot\frac{1}{n+1} = 1$. Hence the constant $1$ cannot
be lowered.*

Two corollaries of the sum rule are worth isolating, because they are the operational
form of the statement "leakage is a conserved budget".

**Theorem 9.8 (Leakage pigeonhole).** *For any readout $F$ and any threshold
$\tau > 0$,*
$$
\#\big\{\, i : \rho^2_p(x_i,F) \ge \tau \,\big\} \le \frac{1}{\tau}.
$$

*Proof.* The sum over the qualifying index set is at least $\tau$ times its
cardinality, and at most $1$ by Theorem 9.5 and non-negativity of each term.
$\square$

**Theorem 9.9 (At most one bit is half-leaked).** *If
$\rho^2_p(x_i,F) > 1/2$ and $\rho^2_p(x_j,F) > 1/2$, then $i = j$.*

*Proof.* Otherwise the two terms alone sum to more than $1$. $\square$

**Theorem 9.10 (Independent proof of symmetric optimality).** *If $F$ is symmetric,
all $N = n+1$ terms of the sum rule are equal to $\mathcal{L}_p(F)$, whence
$(n+1)\mathcal{L}_p(F) \le 1$.*

This is a second, structurally different proof of Theorem 8.5 that never mentions the
Hamming weight: symmetric readouts must divide the conserved budget equally, and the
budget is one.

---

## 10. Algorithms

Three computations recur, and all three should be done in exact rational arithmetic.

**Algorithm A (Exact channel table).** Given a rational bias $p = a/b$ and a maximum
size $n_{\max}$, produce the exact values of $A$, $g$, $X$, $\mathrm{Is}$ for
$n = 1,\dots,n_{\max}$ by evaluating $\Phi$ at $p$, $1-p$, $(1-2p)^2$, $1$ using the
closed form $\Phi(a/b,n) = a^n(b-a)/(b^{n+1}-a^{n+1})$. Cost: $O(n_{\max})$ big-integer
operations per channel. This replaces the $2^{n+1}$-term brute-force sum entirely.

**Algorithm B (Brute-force certification).** For small $n$, enumerate all $2^{n+1}$ bit
patterns, accumulate the exact rational weights, and form the covariance and variances
directly. Cost $O(2^{n+1})$ but exact. Agreement of A and B at every $n \le 12$ is the
certificate that the closed form is not an algebraic slip; disagreement of either with
a floating-point pipeline is the signature of the unnormalised-weight pathology.

**Algorithm C (Ordering oracle).** To rank any collection of product readouts, do not
compute leakages at all: compute the parameters $\theta = m^2/s$ and sort them. By
Theorem 7.5 this ordering is correct at every fork size. Cost $O(k \log k)$ for $k$
readouts, independent of $n$.

---

## 11. Applications and discussion

**Side-channel design.** The model is a stylised description of a device whose
observable leaks a scalar function of many internal bits. Theorem 8.5 says that among
all permutation-invariant observables, the Hamming weight is the worst possible one
from a designer's point of view — and Theorem 8.6 says there is no clever
reparametrisation that escapes this, because *only* affine functions of the weight are
that bad. Theorem 9.9 gives a hard architectural guarantee in the other direction: a
single scalar observable can strongly compromise at most one bit.

**Masking and parity.** Theorem 5.3 recovers the reason parity is the canonical mask:
at $p=1/2$ it is exactly blind to each individual bit. Theorem 2.1 quantifies the
degradation under bias: leakage is $\Phi((1-2p)^2,n)$, quadratic in the bias gap and
geometrically small in the fork size, which is a sharp statement of the intuition that
"biased masks leak, but not much, and less as the mask widens".

**Pooling in learned models.** A pooling unit is a readout. Sum-pooling is affine in
the indicators, hence saturates the sum rule and preserves the maximum total
first-order information — it is the maximally *transparent* pooling. Product-like
units (multiplicative gates, and by Corollary 7.4 the Boolean gates as limits) destroy
first-order information geometrically in fan-in. The sum-rule deficiency
$\mathbb{E}[R_F^2]/\operatorname{Var}(F)$ is a natural definition of the *nonlinearity*
of a unit: exactly the fraction of its variance not explainable by any linear function
of its inputs.

**Methodological.** The most transferable lesson is about the failure mode that this
work removed. The two mirages — the $n=8$ crossover and the ratio $2$ — were not
careless arithmetic; they were the output of a pipeline whose weights did not sum to
one and whose marginals were inconsistent with its joint. Such a pipeline produces
numbers with the right order of magnitude and the wrong structure, which is worse than
producing obvious nonsense. The remedy applied here is structural rather than
numerical: express every expectation as an exact finite sum against explicit product
weights, prove the normalisation ($\mathbb{E}[1] = 1$) rather than assume it, and
impose complement forms ($\mathrm{OR} = 1 - \mathrm{NOR}$,
$\mathrm{XOR} = (1-\pi)/2$) as identities rather than approximations. Once that is
done, the tables do not need to be measured at all: they follow from one increasing
rational function of one variable.

---

## 12. Future directions

The collapse to $\Phi$ raises immediate questions.

*Beyond products and symmetry.* Product readouts and symmetric readouts are both
completely understood. The general readout is governed by the sum rule, but the sum
rule constrains only the *first-order* profile. A classification of the readouts
achieving a prescribed leakage vector $(\rho^2_p(x_i,F))_i$, subject to the
conservation law, is open.

*Higher-order leakage.* Squared correlation is the first term of a hierarchy. The same
exact functional supports the full Fourier–Walsh expansion with respect to the biased
measure; the natural next object is the leakage of a readout about a *set* of bits,
and whether the product class again collapses to a one-parameter profile.

*Dependent sources.* Independence is used twice: in the master factorisation and in
the orthogonality of the centred indicators. Exchangeable but dependent sources retain
Lemma 8.3 and hence a version of symmetric optimality, but the profile itself will
deform. Identifying the deformation is the natural generalisation.

*Non-Bernoulli alphabets.* Nothing about $\Phi$ is intrinsically binary: the product
parameter $\theta = m^2/s$ is defined for any coordinate distribution. The conjecture
is that Theorem 7.3 holds verbatim for products over an arbitrary i.i.d. source with
finite second moments.

*Optimal readouts under a complexity budget.* The counter is optimal but expensive.
Among readouts computable by a bounded-depth circuit, or with bounded range, which
maximises single-bit leakage? Theorem 8.5 caps the answer at $1/(n+1)$; how close can
a cheap readout get?

---

## 13. Conclusion

The four fork channels are one rational profile
$\Phi(t,n) = t^n/(1+t+\cdots+t^n)$ read at four parameters: $p$ for the conjunction,
$1-p$ for the disjunction, $(1-2p)^2$ for the parity, and $1$ for the count. Because
$\Phi$ is strictly increasing in $t$, every comparison between channels is a
comparison between parameters and is therefore independent of the fork size. This
confirms the dominance of the split count in the strongest form, confirms universal
decay, refutes the reported size-dependent crossover, and refutes the conjectured
asymptotic ratio $2$ by exhibiting the exact trichotomy about $p = 3/4$.

Behind the computation lie three structural theorems that make the collapse
inevitable: every multiplicative readout has leakage $\Phi(m^2/s, n)$ with parameter
strictly below $1$; every symmetric readout leaks at most $1/(n+1)$, with equality
exactly for non-degenerate affine functions of the Hamming weight; and every readout
whatsoever distributes at most one unit of total squared correlation among the source
bits, with the slack equal to its nonlinear content. The tables are closed not because
they were extended to $25$ bits, but because they were replaced by a formula.
