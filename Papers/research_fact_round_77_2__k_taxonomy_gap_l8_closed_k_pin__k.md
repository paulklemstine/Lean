# A Taxonomy of Stopping Budgets for Halving Search: Pin, Census Stop, and Economics Optimum

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

In cost accounting for halving (binary-search-style) procedures, three structurally
different quantities are routinely denoted by the same symbol $k^\*$: the *pin*
$k_{\mathrm{pin}}(W) = \lceil \log_2 W\rceil$, at which the support of width $W$ is fully
resolved and the marginal gain of a further query is zero; the *census stop*
$k_{\mathrm{opt}}^{\mathrm{cost}}(W)$, minimising the total cost
$V(W,k) = k + \tfrac12\!\left(W2^{-k} + 1\right)$ in which the residual is priced at half
the remaining support; and the *economics optimum*
$k_{\mathrm{opt}}^{\mathrm{econ}}(T_0,c_q)$, minimising
$E(T_0,c_q,k) = c_q(1+k) + (T_0-1)2^{-k}$, in which queries are paid at price $c_q$ against
a measured baseline $T_0$. We give all three precise definitions and determine exactly how
they relate.

Our central result is an *exact pointwise identity*: for every budget $k$,
$E(T_0,1,k) = V(2(T_0-1),k) + \tfrac12$. Since minimiser sets are invariant under additive
constants, the census stop and the economics optimum have **identical** minimiser sets once
the anchor conversion $W \leftrightarrow 2(T_0-1)$ is applied. We further show that price is
a pure anchor rescaling: $E(T_0,c_q,k) = c_q\big(V(2(T_0-1)/c_q,\,k) + \tfrac12\big)$ for
every $c_q > 0$, so the two-parameter economics family collapses onto the one-parameter
census family. Comparing the two conventions *without* the anchor conversion — feeding the
same number $T_0-1$ to both — yields the second exact identity
$E(T_0,1,k+1) = V(T_0-1,k) + \tfrac32$, so the discrete minimiser shifts by **exactly one**
query, not approximately one; the continuous locations likewise satisfy
$k_{\mathrm{opt}}^{\mathrm{econ}}(T_0,1) = k_{\mathrm{opt}}^{\mathrm{cost}}(T_0-1) + 1$.

For the census objective we prove a complete general-width characterisation: $k$ is optimal
if and only if $2^{k+1} \le W \le 2^{k+2}$ (lower bound vacuous at $k=0$). Consequences: at
dyadic width $W = 2^m$ the optimal value is the exact rational $m + \tfrac12$, attained
precisely on the two-element tie set $\{m-2, m-1\}$; ties occur *exactly* at dyadic widths,
so the optimum is unique elsewhere; and the pin is **never** optimal at any integer width
$W \ge 2$, with gap $k_{\mathrm{pin}}(W) - k_{\mathrm{opt}} \in \{1,2\}$, equal to $1$ if and
only if $W = 2^{k+1}$ and equal to $2$ at every other width. The cost of the confusion is
bounded on both sides: $\tfrac12 \le V(W,k_{\mathrm{pin}}) - V(W,k_{\mathrm{opt}}) < \tfrac54$.
We close with the continuous optima, a global-minimality proof from the inequality
$1-u \le e^{-u}$, and reproduction of two recorded measurement rows
($\bar T_0 = 1072.425 \Rightarrow 9.536549$, discrete optimum $10$;
$\bar T_0 = 286205.89 \Rightarrow 17.597922$, discrete optimum $18$).

**Keywords:** halving search, stopping rule, discrete convexity, dyadic tie set, budget
taxonomy, query cost, argmin invariance.

---

## 1. Introduction

### 1.1 The problem of an overloaded symbol

Halving search is the most thoroughly analysed procedure in computing, and the analysis of
*when to stop* halving is elementary. Yet across cost-accounting practice, the symbol
$k^\*$ denotes at least three different quantities. Each is individually correct as an
answer to *some* question; the trouble arises when a value computed under one convention is
read under another. Because the three quantities differ by only one or two units, the
resulting error is silent: the number is of the right magnitude, of the right shape, and
wrong.

This paper is a taxonomy. We fix the three definitions, prove the exact relations among
them, and determine — with equalities, not estimates — how far apart they can be.

### 1.2 Setting

A search proceeds over a support of *width* $W > 0$. Each query halves the surviving
support, so after $k$ queries the residual has width $W/2^k$. Queries cost; residuals cost.
The three budgets differ in exactly how each side of that trade is priced.

### 1.3 Contributions

1. **Definitional separation.** Three formally distinct budgets — pin, census stop,
   economics optimum — with the parameters each depends on made explicit (Section 2).
2. **Exact anchor identity** (Theorem 3.1) and the consequent identity of minimiser sets
   (Corollary 3.3).
3. **Exact unconverted shift** (Theorem 3.4): the naive same-number comparison is off by a
   structural constant $\tfrac32$, hence by exactly $+1$ on the discrete minimiser
   (Corollary 3.5) and by exactly $1$ on the continuous location (Theorem 6.4).
4. **Price rigidity** (Theorem 3.6): query price acts only through the anchor.
5. **General-width bracket characterisation** of the census optimum (Theorem 5.1), obtained
   from a discrete-convexity principle (Theorem 4.4).
6. **Dyadic exactness** (Theorems 5.2–5.4): value $m+\tfrac12$, two-element tie set, tie
   dichotomy, uniqueness off the dyadic locus.
7. **The pin is never optimal** (Theorem 5.6), with exact gap dichotomy (Theorem 5.8) and
   two-sided overcharge bounds (Theorem 5.9).
8. **Continuous optima with genuine global minimality** (Theorem 6.2), and reproduction of
   recorded measurement rows as universally quantified optimality statements (Section 7).
9. **A naming rule** (Section 9) that makes the confusion impossible to restate.

---

## 2. Definitions

Throughout, $k$ ranges over the natural numbers $\mathbb{N} = \{0,1,2,\dots\}$ unless a
continuous relaxation is explicitly indicated; $W > 0$ is a real support width; $T_0 > 1$ is
a measured baseline; $c_q > 0$ is a query price.

> **Definition 2.1 (Pin).** The *pin* of an integer width $W \ge 1$ is
> $$k_{\mathrm{pin}}(W) \;=\; \lceil \log_2 W \rceil,$$
> the least $k$ with $W \le 2^k$. It is the budget at which the support is fully resolved:
> for $k \ge k_{\mathrm{pin}}(W)$ the residual contains at most one point, so the marginal
> gain of a further query is exactly zero. The pin is a *saturation point*, defined without
> reference to any cost.

> **Definition 2.2 (Census cost and census stop).** The *census cost* of a $k$-query
> halving schedule on support width $W$ is
> $$V(W,k) \;=\; k \;+\; \frac{1}{2}\!\left(\frac{W}{2^{k}} + 1\right),$$
> i.e. $k$ unit-price queries plus the residual priced at half the remaining support (the
> $+\tfrac12$ being the endpoint convention). The *census stop*
> $k_{\mathrm{opt}}^{\mathrm{cost}}(W)$ is the set of minimisers of $V(W,\cdot)$ over
> $\mathbb{N}$.

> **Definition 2.3 (Economics cost and economics optimum).** The *economics cost* at
> measured baseline $T_0$ and query price $c_q$ is
> $$E(T_0,c_q,k) \;=\; c_q\,(1+k) \;+\; \frac{T_0-1}{2^{k}},$$
> i.e. $k+1$ queries charged at price $c_q$ plus the expected residual scan measured against
> the baseline. The *economics optimum* $k_{\mathrm{opt}}^{\mathrm{econ}}(T_0,c_q)$ is the set
> of minimisers of $E(T_0,c_q,\cdot)$ over $\mathbb{N}$.

> **Definition 2.4 (Continuous relaxations and locations).** Write
> $$\widetilde V(W,x) = x + \tfrac12\big(W\,2^{-x} + 1\big), \qquad
> \widetilde E(T_0,c_q,x) = c_q(1+x) + (T_0-1)\,2^{-x}, \qquad x \in \mathbb{R}.$$
> The *continuous locations* are
> $$\kappa^{\mathrm{econ}}(T_0,c_q) = \log_2\!\frac{(T_0-1)\ln 2}{c_q}, \qquad
> \kappa^{\mathrm{cost}}(W) = \log_2(W \ln 2) - 1.$$

The relaxations are consistent with the discrete costs: $\widetilde V(W,k) = V(W,k)$ and
$\widetilde E(T_0,c_q,k) = E(T_0,c_q,k)$ for every natural $k$, since $2^{-k}$ as a real
power agrees with the integer power.

**Remark 2.5 (Why the definitions genuinely differ).** The pin is a *combinatorial*
quantity — no cost enters. The census stop and economics optimum are both *economic*, but
use different bookkeeping: the census prices the residual at half the remaining support,
while the economics convention charges the full expected scan of a support anchored at a
measured $T_0$, and adds a baseline query. The factor-of-two discrepancy in residual
pricing and the additive baseline query are precisely what the identities of Section 3
quantify.

---

## 3. The exact identities

The whole relational structure of the taxonomy rests on two lines of algebra.

> **Theorem 3.1 (Anchor identity).** For every $T_0 \in \mathbb{R}$ and every $k \in \mathbb{N}$,
> $$E(T_0, 1, k) \;=\; V\big(2(T_0-1),\,k\big) \;+\; \tfrac12 .$$

*Proof.* Expand the right-hand side:
$$V(2(T_0-1),k) + \tfrac12 = k + \tfrac12\!\left(\frac{2(T_0-1)}{2^k} + 1\right) + \tfrac12
= k + \frac{T_0-1}{2^k} + 1 = E(T_0,1,k). \qquad\blacksquare$$

The point is not the computation but its *shape*: the difference is a constant, free of
$k$. Two structural corollaries follow immediately, and they are the reason the identity
matters.

> **Corollary 3.2 (Comparison transfer).** For all $j,k \in \mathbb{N}$,
> $$E(T_0,1,j) \le E(T_0,1,k) \iff V\big(2(T_0-1),j\big) \le V\big(2(T_0-1),k\big).$$

*Proof.* Subtract the constant $\tfrac12$ from both sides of each inequality. $\blacksquare$

> **Corollary 3.3 (Identity of minimiser sets).** For every $j \in \mathbb{N}$,
> $$\big(\forall k,\; E(T_0,1,j) \le E(T_0,1,k)\big) \iff \big(\forall k,\; V(2(T_0-1),j) \le V(2(T_0-1),k)\big).$$
> Equivalently, $k_{\mathrm{opt}}^{\mathrm{econ}}(T_0,1) = k_{\mathrm{opt}}^{\mathrm{cost}}\big(2(T_0-1)\big)$
> as *sets*, not merely as representative values.

So the two economic conventions never disagreed. They are the same optimisation problem
under the anchor dictionary $W \leftrightarrow 2(T_0-1)$.

### 3.1 The unconverted comparison

What practitioners actually do is feed the *same number* into both formulas, without the
factor of two. This too has an exact answer.

> **Theorem 3.4 (Unconverted identity).** For every $T_0$ and every $k \in \mathbb{N}$,
> $$E(T_0, 1, k+1) \;=\; V(T_0-1,\,k) \;+\; \tfrac32 .$$

*Proof.* Expanding,
$$V(T_0-1,k) + \tfrac32 = k + \tfrac12\!\left(\frac{T_0-1}{2^k}+1\right) + \tfrac32 = k + 2 + \frac{T_0-1}{2^{k+1}} = E(T_0,1,k+1). \qquad\blacksquare$$

> **Corollary 3.5 (The shift is exactly one).** If $j$ minimises $V(T_0-1,\cdot)$ over
> $\mathbb{N}$, then $j+1$ minimises $E(T_0,1,\cdot)$ over $\{k : k \ge 1\}$.

*Proof.* Let $k \ge 1$ and write $k = k'+1$. By Theorem 3.4,
$E(T_0,1,j+1) - E(T_0,1,k) = V(T_0-1,j) - V(T_0-1,k') \le 0$. $\blacksquare$

**Remark.** The value $\tfrac32$ does not depend on $T_0$ or $k$. The often-recorded
observation that the two conventions differ "by about one query" is therefore not an
approximation with an error term; it is an exact structural offset. The restriction $k\ge 1$
is genuinely needed only in degenerate cases: at $T_0 = 3$, for instance, the economics
minimiser set is $\{0,1\}$ and the census minimiser at width $T_0 - 1 = 2$ is $\{0\}$, so
$j+1 = 1$ is a minimiser but so is $0$.

### 3.2 Price is a pure anchor rescaling

> **Theorem 3.6 (Price rigidity).** For every $c_q > 0$ and every $k \in \mathbb{N}$,
> $$E(T_0,c_q,k) \;=\; c_q\left(V\!\left(\frac{2(T_0-1)}{c_q},\,k\right) + \tfrac12\right).$$
> Consequently $k$ minimises $E(T_0,c_q,\cdot)$ if and only if $k$ minimises
> $V\big(2(T_0-1)/c_q,\,\cdot\big)$.

*Proof.* Expand:
$c_q\big(V(2(T_0-1)/c_q,k) + \tfrac12\big) = c_q k + \frac{T_0-1}{2^k} + \tfrac{c_q}{2} + \tfrac{c_q}{2} = E(T_0,c_q,k)$.
The minimiser statement follows because $x \mapsto c_q x + \text{const}$ is strictly
increasing for $c_q > 0$, hence preserves and reflects $\le$. $\blacksquare$

Thus the nominally two-parameter economics family $(T_0, c_q)$ collapses onto the
one-parameter census family: **doubling the query price is exactly the same optimisation
problem as halving the support width**. In particular no separate theory of "expensive
queries" is required; every result proved for $V$ transfers verbatim.

---

## 4. A discrete convexity principle

All optimality claims below are instances of a single structural principle, which replaces
every enumeration argument. Let $f : \mathbb{N} \to \mathbb{R}$.

> **Definition 4.1.** $f$ is *discretely convex* if its increments are nondecreasing:
> $f(k+1) - f(k) \le f(k+2) - f(k+1)$ for all $k$.

> **Lemma 4.2 (Increment monotonicity).** If $f$ is discretely convex and $i \le j$ then
> $f(i+1) - f(i) \le f(j+1) - f(j)$.

*Proof.* Induction on $j$ from the base $j = i$, chaining the defining inequality.
$\blacksquare$

> **Lemma 4.3 (One-sided monotonicity).** Let $f$ be discretely convex.
> (i) If $f(n) \le f(n+1)$ then $f(n) \le f(k)$ for all $k \ge n$.
> (ii) If $f(m+1) \le f(m)$ then $f(m+1) \le f(k)$ for all $k \le m$.

*Proof.* (i) Induct on $k \ge n$: if $f(n) \le f(k)$ then, by Lemma 4.2 applied to
$n \le k$, $f(k+1) - f(k) \ge f(n+1) - f(n) \ge 0$, so $f(n) \le f(k+1)$. (ii) Downward
induction from $m$: for $j < m$, Lemma 4.2 with $j \le m$ gives
$f(j+1) - f(j) \le f(m+1) - f(m) \le 0$, so $f(j) \ge f(j+1) \ge f(m+1)$ by the inductive
hypothesis. $\blacksquare$

> **Theorem 4.4 (Local minimum is global).** Let $f$ be discretely convex and let
> $n \in \mathbb{N}$ satisfy $f(n) \le f(n+1)$, and, if $n \ge 1$, also $f(n) \le f(n-1)$.
> Then $f(n) \le f(k)$ for every $k \in \mathbb{N}$.

*Proof.* If $k \ge n$, apply Lemma 4.3(i). If $k < n$, write $n = m+1$ and apply Lemma
4.3(ii) with $f(m+1) \le f(m)$. $\blacksquare$

> **Proposition 4.5 (Both objectives are discretely convex).** For $T_0 \ge 1$ and $c_q$
> arbitrary, $E(T_0,c_q,\cdot)$ is discretely convex; for $W \ge 0$, $V(W,\cdot)$ is
> discretely convex.

*Proof.* A direct computation gives the second difference
$$\big(E(k+2)-E(k+1)\big) - \big(E(k+1)-E(k)\big) \;=\; \frac{T_0-1}{4\cdot 2^{k}} \;\ge\; 0 .$$
For $V$, use the identity $E(W/2+1,\,1,\,k) = V(W,k) + \tfrac12$ (Theorem 3.1 with
$T_0 = W/2+1$), which transfers convexity as an additive shift. $\blacksquare$

**Methodological remark.** Theorem 4.4 is what upgrades numerical spot checks into
theorems. Verifying that a candidate $k$ beats its two neighbours *proves* it beats every
natural number. All discrete optimality statements below, including the numerical rows of
Section 7, are universally quantified over $k \in \mathbb{N}$ for this reason.

---

## 5. The census optimum at general width

### 5.1 The increment and the bracket

> **Lemma 5.0 (Increment formula).** For every $W$ and $k$,
> $$V(W,k+1) - V(W,k) \;=\; 1 \;-\; \frac{W}{2^{k+2}} .$$

*Proof.* $V(W,k+1) - V(W,k) = 1 + \tfrac12\big(W2^{-(k+1)} - W2^{-k}\big) = 1 - \tfrac{W}{2^{k+2}}$. $\blacksquare$

The interpretation is the whole story: the extra query costs $1$ and saves $W/2^{k+2}$ of
residual sweep. Since the saving shrinks geometrically in $k$, the increment increases —
the diminishing return that makes the objective convex.

> **Theorem 5.1 (General-width characterisation).** Let $W > 0$. Then $k$ minimises
> $V(W,\cdot)$ over $\mathbb{N}$ if and only if
> $$W \le 2^{k+2} \quad\text{and}\quad \big(k = 0 \text{ or } 2^{k+1} \le W\big).$$

*Proof.* ($\Rightarrow$) Optimality gives $V(W,k) \le V(W,k+1)$, so by Lemma 5.0
$0 \le 1 - W/2^{k+2}$, i.e. $W \le 2^{k+2}$. If $k = m+1 \ge 1$, optimality also gives
$V(W,m+1) \le V(W,m)$, so $1 - W/2^{m+2} \le 0$, i.e. $2^{k+1} = 2^{m+2} \le W$.
($\Leftarrow$) The two inequalities say exactly that the increment at $k$ is $\ge 0$ and,
when $k \ge 1$, the increment at $k-1$ is $\le 0$. Proposition 4.5 and Theorem 4.4 then give
global minimality. $\blacksquare$

Equivalently: **the census optimum sits at offset $-2$ or $-1$ relative to $\log_2 W$**.
Never at offset $0$ — which is where the pin lives.

### 5.2 Dyadic widths: exact value and tie set

> **Theorem 5.2 (Dyadic optimum).** For $W = 2^m$ with $m \ge 1$,
> $$\min_{k\in\mathbb{N}} V(2^m, k) \;=\; m + \tfrac12,$$
> attained exactly on the tie set $\{k : k+1 = m \text{ or } k+2 = m\}$, i.e. $\{m-2, m-1\}$
> (interpreted as $\{m-1\}$ when $m = 1$).

*Proof.* Since $V(2^m,k) = k + 2^{m}/2^{k+1} + \tfrac12$, the values at $k = m-1$ and
$k = m-2$ are $(m-1) + 1 + \tfrac12$ and $(m-2) + 2 + \tfrac12$, both equal to $m + \tfrac12$.
For strictness elsewhere: if $k \ge m$ then $k \ge m$ and the residual term is positive, so
$V > m + \tfrac12$. If $k < m$ with $k+1 \ne m$ and $k+2 \ne m$, write $m = k+1+j$ with
$j \ge 2$; then $V(2^m,k) = k + 2^{j} + \tfrac12$ and $m + \tfrac12 = k+1+j+\tfrac12$, so the
claim reduces to $j + 1 < 2^{j}$ for $j \ge 2$, which follows by induction from
$j+1 \le 2^{j}$ and $2^{j+1} = 2\cdot 2^{j} \ge 2^j + j + 1 > j + 2$. $\blacksquare$

> **Corollary 5.3 (Exact tie characterisation).** $V(2^m,k) = m + \tfrac12$ holds if and only
> if $k+1 = m$ or $k+2 = m$; and $k$ is a minimiser if and only if the same condition holds
> (for $m \ge 1$).

The fact that the tie set has exactly two elements traces to the equation $2^j = j+1$
having exactly the two natural solutions $j = 0, 1$: the exponential overtakes the linear
term permanently at $j = 2$.

> **Theorem 5.4 (Tie dichotomy).** Let $W > 0$. Two consecutive budgets $k$ and $k+1$ are
> both census minimisers if and only if $W = 2^{k+2}$.

*Proof.* ($\Rightarrow$) Applying Theorem 5.1 to $k$ gives $W \le 2^{k+2}$; applying it to
$k+1$ (which is nonzero) gives $2^{k+2} \le W$. ($\Leftarrow$) With $W = 2^{k+2}$ both
bracket conditions hold at $k$ ($W \le 2^{k+2}$ and $2^{k+1} \le 2^{k+2}$) and at $k+1$
($W = 2^{k+2} \le 2^{k+3}$ and $2^{k+2} \le W$). $\blacksquare$

> **Corollary 5.5 (Uniqueness off the dyadic locus).** If $W > 0$ is not an integer power of
> two, the census minimiser is unique.

*Proof.* Any two minimisers $k, k'$ satisfy $|k - k'| \le 1$: if $k' \ge k+2$ then Theorem
5.1 at $k'$ gives $2^{k+3} \le 2^{k'+1} \le W$ while Theorem 5.1 at $k$ gives
$W \le 2^{k+2} < 2^{k+3}$, a contradiction. If they differ by exactly one, Theorem 5.4 forces
$W$ to be a power of two. $\blacksquare$

So "the census optimum" is a well-defined integer at every non-dyadic width and a genuine
two-element set exactly on the dyadic locus. Any statement that speaks of *the* optimum
without this caveat is imprecise at the powers of two.

### 5.3 The pin is never optimal

> **Theorem 5.6 (Strict suboptimality of the pin).** For every integer width $W \ge 2$,
> $$V\big(W,\, k_{\mathrm{pin}}(W) - 1\big) \;<\; V\big(W,\, k_{\mathrm{pin}}(W)\big),$$
> so the pin is never a census minimiser.

*Proof.* Since $W \ge 2$ we have $p := k_{\mathrm{pin}}(W) - 1 \ge 0$ and, by definition of
the ceiling, $W \le 2^{p+1}$. Lemma 5.0 at $k = p$ gives
$$V(W,p+1) - V(W,p) \;=\; 1 - \frac{W}{2^{p+2}} \;\ge\; 1 - \frac{2^{p+1}}{2^{p+2}} \;=\; \tfrac12 \;>\; 0. \qquad\blacksquare$$

The mechanism is worth stating in words: **the last, saturating query costs a full unit and
can save at most half a unit.** It is a strict loss at every width.

> **Theorem 5.7 (Gap bound).** For every integer $W \ge 2$ and every census minimiser $k$,
> $$k_{\mathrm{pin}}(W) - k \;\in\; \{1, 2\}.$$

*Proof.* The ceiling brackets $2^{k_{\mathrm{pin}}(W)-1} < W \le 2^{k_{\mathrm{pin}}(W)}$.
Combining $2^{k_{\mathrm{pin}}-1} < W \le 2^{k+2}$ (Theorem 5.1) gives
$k_{\mathrm{pin}} - 1 < k+2$, i.e. $k_{\mathrm{pin}} \le k+2$. Combining
$2^{k+1} \le W \le 2^{k_{\mathrm{pin}}}$ gives $k+1 \le k_{\mathrm{pin}}$. When $k = 0$ the
lower bracket is vacuous, but then $2 \le W \le 4$ forces $k_{\mathrm{pin}} \in \{1,2\}$
directly. $\blacksquare$

> **Theorem 5.8 (Exact gap dichotomy).** For every integer $W \ge 2$ and every census
> minimiser $k$,
> $$k_{\mathrm{pin}}(W) - k = 1 \iff W = 2^{k+1},$$
> and hence $k_{\mathrm{pin}}(W) - k = 2$ at every width that is not a power of two.

*Proof.* ($\Leftarrow$) If $W = 2^{k+1}$ then $k_{\mathrm{pin}}(W) = k+1$. ($\Rightarrow$) If
$k_{\mathrm{pin}}(W) = k+1$ then $W \le 2^{k+1}$; the bracket of Theorem 5.1 gives
$2^{k+1} \le W$ when $k \ge 1$, hence equality. When $k = 0$ the pin is $1$, forcing
$W \le 2$, and $W \ge 2$ gives $W = 2 = 2^{k+1}$. The final claim follows from Theorem 5.7.
$\blacksquare$

**Remark 5.8a (a corrected intuition).** Reading the dyadic table — optimum $\{m-2,m-1\}$,
pin $m$, gaps $\{2,1\}$ — suggests that a gap of $1$ is generic and a gap of $2$ is a dyadic
exception. Theorem 5.8 shows the opposite. At $W = 3$ the unique optimum is $k = 0$ while
$k_{\mathrm{pin}}(3) = 2$, a gap of $2$ at a non-dyadic width. A gap of $1$ requires the
width to sit *exactly* on the power of two just above the optimum. **The pin overstates the
work-optimal budget by two queries at almost every width.**

> **Theorem 5.9 (Two-sided overcharge bounds).** For every integer $W \ge 2$ and every census
> minimiser $k$,
> $$\tfrac12 \;\le\; V\big(W, k_{\mathrm{pin}}(W)\big) - V(W,k) \;<\; \tfrac54 .$$
> The lower bound is attained exactly at the dyadic widths $W = 2^{k+1}$; the upper bound is
> approached but never attained as $W \to 2^m + 1$ from the dyadic side.

*Proof.* Two cases from Theorem 5.8. If the gap is $1$, then $W = 2^{k+1}$ and Lemma 5.0
gives $V(W,k+1) - V(W,k) = 1 - 2^{k+1}/2^{k+2} = \tfrac12$ exactly. If the gap is $2$, the
two-step increment (obtained by summing Lemma 5.0 at $k$ and $k+1$) is
$$V(W,k+2) - V(W,k) \;=\; 2 - \frac{3W}{2^{k+3}} .$$
The bracket of Theorem 5.1 gives $2^{k+1} < W \le 2^{k+2}$ (strict on the left, since
$W = 2^{k+1}$ would put us in the gap-$1$ case), hence
$\tfrac34 < 3W/2^{k+3} \le \tfrac32$, whence $\tfrac12 \le V(W,k+2)-V(W,k) < \tfrac54$.
$\blacksquare$

### 5.4 Transfer to the economics objective

Everything above transfers to $E$ without new work, by Corollary 3.3 and Theorem 3.6.

> **Corollary 5.10 (Economics bracket).** For $T_0 > 1$, $k$ minimises $E(T_0,1,\cdot)$ if and
> only if $2(T_0-1) \le 2^{k+2}$ and ($k=0$ or $2^{k+1} \le 2(T_0-1)$). At general price
> $c_q > 0$, replace $2(T_0-1)$ by $2(T_0-1)/c_q$.

---

## 6. The continuous optima

The continuous relaxations are useful in practice because they give a closed-form location
rather than a set, and the discrete optimum is recovered by rounding within the bracket.

> **Theorem 6.1 (Characterisation of the economics location).** For $T_0 > 1$ and $c_q > 0$,
> $$2^{\kappa^{\mathrm{econ}}(T_0,c_q)} \;=\; \frac{(T_0-1)\ln 2}{c_q}.$$

*Proof.* Immediate from $\kappa^{\mathrm{econ}} = \log_2\big((T_0-1)\ln 2/c_q\big)$ and
positivity of the argument. $\blacksquare$

> **Theorem 6.2 (Global minimality of the continuous economics optimum).** For $T_0 > 1$ and
> $c_q > 0$, the point $\kappa^{\mathrm{econ}}(T_0,c_q)$ minimises $\widetilde E(T_0,c_q,\cdot)$
> over all of $\mathbb{R}$.

*Proof sketch.* Write $\kappa$ for the claimed minimiser, so $2^{-\kappa} = c_q/((T_0-1)\ln 2)$
by Theorem 6.1. For arbitrary $x$, set $u = (x-\kappa)\ln 2$, so that
$2^{-x} = 2^{-\kappa}e^{-u}$ and $x = \kappa + u/\ln 2$. Substituting and simplifying,
$$\widetilde E(T_0,c_q,x) - \widetilde E(T_0,c_q,\kappa) \;=\; \frac{c_q}{\ln 2}\,\big(u + e^{-u} - 1\big).$$
The bracket is nonnegative for all real $u$ by the elementary inequality
$1 - u \le e^{-u}$, with equality only at $u = 0$. Hence the difference is $\ge 0$, and the
minimiser is unique. $\blacksquare$

This is a genuine global-minimality statement, not a first-order stationarity check; the
single exponential inequality does all the work.

> **Theorem 6.3 (Anchor identity for the continuous locations).** For $W > 0$,
> $$\kappa^{\mathrm{cost}}(W) \;=\; \kappa^{\mathrm{econ}}\!\big(\tfrac{W}{2}+1,\; 1\big),$$
> i.e. the census location is the economics location at the converted anchor $W = 2(T_0-1)$.
> Consequently $\kappa^{\mathrm{cost}}(W)$ is a global minimiser of $\widetilde V(W,\cdot)$.

*Proof.* We have
$$\kappa^{\mathrm{econ}}(W/2+1,1) = \log_2\big((W/2)\ln 2\big) = \log_2(W\ln 2) - 1 = \kappa^{\mathrm{cost}}(W).$$
The minimality claim follows from
$\widetilde V(W,x) = \widetilde E(W/2+1,1,x) - \tfrac12$ and Theorem 6.2. $\blacksquare$

> **Theorem 6.4 (The continuous naive shift is exactly one).** For every $T_0$ with
> $T_0 > 2$,
> $$\kappa^{\mathrm{econ}}(T_0,1) \;=\; \kappa^{\mathrm{cost}}(T_0-1) \;+\; 1 .$$

*Proof.* $\kappa^{\mathrm{cost}}(T_0-1) = \log_2\big((T_0-1)\ln 2\big) - 1$ and
$\kappa^{\mathrm{econ}}(T_0,1) = \log_2\big((T_0-1)\ln 2\big)$. $\blacksquare$

**Remark 6.5 (Where the continuous optimum lies).** At $W = 2^m$,
$\kappa^{\mathrm{cost}}(2^m) = m + \log_2(\ln 2) - 1 = m - 1.5288\ldots$, which sits strictly
inside the discrete bracket $[m-2,\,m-1]$ — exactly as the tie set of Theorem 5.2 requires.
More generally the discrete optimum is obtained from $\kappa^{\mathrm{cost}}(W)$ by rounding
into the integer bracket $2^{k+1} \le W \le 2^{k+2}$.

---

## 7. Reproduction of recorded measurement rows

Two measured baselines from recorded runs illustrate the taxonomy end-to-end. All discrete
statements below are, by Theorem 4.4, universally quantified over $k \in \mathbb{N}$ — not
finite-range spot checks.

**Balanced run, $\bar T_0 = 1072.425$.**
- Continuous economics location: $\log_2\big(1071.425 \times \ln 2\big) = 9.536549$, matching
  the recorded prediction.
- Discrete economics optimum: $10$. It is bracketed by
  $2^{11} = 2048 \le 2(\bar T_0 - 1) = 2142.85 \le 4096 = 2^{12}$, and Corollary 5.10 gives
  optimality for $k = 10$ against every natural $k$. Note $10 = \lceil 9.536549\rceil$.
- Matched-anchor census at $W = 2142.85$: the same unique optimum $10$, as Corollary 3.3
  guarantees.
- Pin at that width: $k_{\mathrm{pin}}(2143) = 12$. Conflating the pin with the work-optimal
  budget overstates it by two queries.

**Unbalanced run, $\bar T_0 = 286205.89$.**
- Continuous economics location: $\log_2\big(286204.89 \times \ln 2\big) = 17.597922$,
  matching the recorded prediction.
- Discrete economics optimum: $18$, bracketed by
  $2^{19} = 524288 \le 2(\bar T_0 - 1) = 572409.78 \le 1048576 = 2^{20}$. Again
  $18 = \lceil 17.597922\rceil$.
- Matched-anchor census: the same optimum $18$.
- Pin at that width: $20$. Again a two-query overstatement.

**Naive-conversion check.** Feeding $\bar T_0 - 1$ directly into the census formula yields
minimisers $9$ and $17$ respectively — exactly one below the economics optima $10$ and $18$,
as Corollary 3.5 predicts. This is the numerical face of the constant $\tfrac32$.

---

## 8. Algorithms

The characterisations above are constructive and yield $O(1)$-arithmetic procedures.

### 8.1 Closed-form census stop

By Theorem 5.1, $k$ is optimal iff $2^{k+1} \le W \le 2^{k+2}$. Hence for $W > 4$ the
canonical minimiser is
$$k_{\mathrm{opt}}^{\mathrm{cost}}(W) = \lceil \log_2 W\rceil - 2,$$
and the minimiser set is $\{\lceil\log_2 W\rceil - 2,\ \lceil\log_2 W\rceil - 1\}$ exactly
when $W$ is a power of two (Theorem 5.4) and the singleton
$\{\lceil\log_2 W\rceil - 2\}$ otherwise. For $W \le 4$ the optimum is $k = 0$. Cost: one
logarithm, or one bit-length operation on integer inputs; $O(1)$ time.

### 8.2 Anchor-conversion resolver

Given a query stated in one convention, restate it in the other:
- economics $(T_0,c_q)$ $\to$ census: use anchor $W = 2(T_0-1)/c_q$ (Theorem 3.6);
- census $W$ $\to$ economics at unit price: use baseline $T_0 = W/2 + 1$ (Theorem 6.3).

Both directions preserve minimiser sets exactly. Cost: $O(1)$.

### 8.3 Convexity-certified discrete optimality

To *certify* that a candidate $k$ is a global minimiser of a discretely convex objective
$f$, it suffices to check $f(k) \le f(k+1)$ and, when $k \ge 1$, $f(k) \le f(k-1)$
(Theorem 4.4). Two evaluations replace an unbounded search; the certificate is complete,
not heuristic.

### 8.4 Pin-gap audit

Given an integer width $W \ge 2$: compute $k_{\mathrm{pin}} = \lceil\log_2 W\rceil$ and the
canonical optimum $k$; report the gap ($1$ if $W$ is a power of two, else $2$, by Theorem
5.8) and the overcharge $V(W,k_{\mathrm{pin}}) - V(W,k) \in [\tfrac12, \tfrac54)$ (Theorem
5.9). This turns the taxonomy into a mechanical check on any document that reports a budget.

---

## 9. Discussion: the naming rule

The mathematics in this paper is elementary; the failure mode it addresses is notational.
Three quantities within two units of each other, all plausible in a table, all written
$k^\*$, produce errors that are invisible on inspection and durable under citation.

We therefore propose retiring the bare symbol. Every occurrence should be expanded to one
of:

| Symbol | Meaning | Required parameters | Is it ever an optimum? |
|---|---|---|---|
| $k_{\mathrm{pin}}(W)$ | saturation of halving, $\lceil\log_2 W\rceil$ | width $W$ | **Never** (Theorem 5.6) |
| $k_{\mathrm{opt}}^{\mathrm{cost}}(W)$ | census total-cost stop | width $W$ | Yes, by definition |
| $k_{\mathrm{opt}}^{\mathrm{econ}}(T_0,c_q)$ | economics optimum | baseline $T_0$, price $c_q$ | Yes, by definition |

Three verdicts on coincidence follow from the results above:

1. $k_{\mathrm{opt}}^{\mathrm{cost}}$ and $k_{\mathrm{opt}}^{\mathrm{econ}}$ **always**
   coincide, as sets, after the anchor conversion $W = 2(T_0-1)/c_q$ (Corollary 3.3,
   Theorem 3.6).
2. Compared *without* conversion, they differ by exactly $+1$ query, at every anchor
   (Corollary 3.5, Theorem 6.4).
3. $k_{\mathrm{pin}}$ coincides with **neither**, at any integer width $W \ge 2$, and
   overstates the work-optimal budget by $1$ or $2$ queries — by $2$ unless $W$ is exactly a
   power of two (Theorems 5.6–5.8), at a cost between $\tfrac12$ and $\tfrac54$ of a query
   (Theorem 5.9).

**Scope.** This is a definitional and structural result about the stated cost models. It
does not assert that any particular cost model is the right one for a given application; it
asserts that, *given* these models, the relations among their optima are exactly as stated.
The identities are exact and the optimality claims are universally quantified over budgets.

**Limitations.** All three models assume uniform per-query price and exact halving. Neither
assumption is universal: rate-limited oracles may price the $j$-th query differently, and
non-ideal splits give a contraction factor $\rho \ne \tfrac12$. Section 10 takes these up.

---

## 10. Future work

**Non-uniform query prices.** If the $j$-th query costs $c_j$, the objective becomes
$\sum_{j<k} c_j + (T_0-1)2^{-k}$, whose increment is $c_k - (T_0-1)2^{-(k+1)}$. Discrete
convexity survives whenever $(c_k)$ is nondecreasing, so Theorem 4.4 still applies, but the
additive rigidity of Theorem 3.1 breaks: the difference between the economics and census
objectives is no longer constant in $k$, and the two families genuinely separate. Rate-limited
or proof-of-work priced oracles are the natural motivating case, and the interesting question
is how large the minimiser separation can be as a function of the price schedule's growth
rate.

**General contraction factors.** Replace halving by a factor $\rho \in (0,1)$, so the residual
is $W\rho^k$. The increment becomes $1 - W\rho^{k}(1-\rho)/\text{(scale)}$ and the bracket
generalises to a $\rho$-adic interval. Two questions: does the tie set remain at most a
two-element set, and does the "pin is never optimal" verdict persist for every $\rho$, or is
there a threshold contraction below which saturating becomes optimal?

**Randomised and adaptive splits.** If each query contracts the support by a random factor,
the objective becomes an expectation and the exact rational values of Theorem 5.2 dissolve.
It would be worth knowing whether the bracket characterisation survives in expectation, and
whether the pin remains strictly suboptimal almost surely.

**Multi-dimensional supports.** For a product support $W_1 \times \cdots \times W_d$ with a
per-coordinate query budget, the census objective becomes separable in a way that suggests a
coordinatewise bracket. Whether the pin/optimum gap accumulates additively across coordinates
(giving a $2d$-query overstatement) is an immediate question.

**Audit tooling.** The gap dichotomy of Theorem 5.8 is mechanically checkable, so any table
reporting a budget alongside a width admits automatic classification into pin / census /
economics conventions. Building such an audit into review practice would prevent the
confusion this paper documents from recurring.

---

## 11. Conclusion

Three budgets, one symbol. Once separated, the relations among them are exact and short:
the census stop and the economics optimum are the same optimisation problem under the
anchor dictionary $W \leftrightarrow 2(T_0-1)/c_q$; compared naively they differ by exactly
one query, because their objectives differ by the constant $\tfrac32$; and the pin, being a
saturation point rather than an optimum, is strictly suboptimal at every integer width
$W \ge 2$, high by one or two queries — by two unless the width is exactly a power of two —
at a cost of between half a query and $\tfrac54$ of a query. At dyadic widths the census
optimum is the exact rational $\log_2 W + \tfrac12$, attained on a genuine two-element tie
set, and ties occur nowhere else.

The results are elementary and that is their value: they replace a persistent ambiguity with
a conversion table. The recommendation is correspondingly simple. Do not write $k^\*$. Write
which one you mean, and write down its parameters.
