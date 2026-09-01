# The Block-Count Cap: Universal Ceilings for Rank Correlation Under Ties, with Application to the 2-adic Zero-Fit Dial

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

A statistic that takes only finitely many values imposes a hard, purely combinatorial
ceiling on the rank correlation it can achieve with any response. We give a complete
analysis of that ceiling as a functional of the *tie profile* $L=(m_1,\dots,m_K)$, the
multiset of tie-class sizes of the statistic on a sample of size $n=\sum_j m_j$.

Three results form the core. First, a **continuum sandwich**: for every profile with
$n \ge 2$,
$$1 - \frac{C(L)}{n^3} \le \rho^2_{\max}(L) \le 1 - \frac{C(L)}{n^3} + \frac{1}{n^2},
\qquad C(L) := \sum_{j} m_j^3,$$
so the exact discrete tie-attenuation ceiling and its continuum idealisation differ by at
most $1/n^2$, uniformly over all profiles. Second, a **power-mean bound**
$n^3 \le K^2\,C(L)$, with equality exactly at the flat profile, proved by induction from the
cubic factorisation
$(1+s)^2(s^2u^3+v^3) - s^2(u+v)^3 = (v-su)^2\big[(1+2s)v + s(2+s)u\big]$.
Third, combining the two, the **block-count cap**
$$\rho^2_{\max}(L) \le 1 - \frac{1}{K^2} + \frac{1}{n^2},$$
which depends on the *number* of tie classes alone and is sharp to within $1/n^2$, attained
by the flat profile.

We apply this to the **2-adic zero-fit dial** $T(x)=\nu_2(x)$ on uniform $b$-bit draws, whose
tie profile is $(2^{b-1},2^{b-2},\dots,2,1,1)$ with cubic moment $(8^b+6)/7$ and unweighted
ceiling $\rho \le \sqrt{6/7}$. Reweighting an observation multiplies its block size, scaling
the cubic moment cubically against a linear mass budget, so reweighting genuinely moves the
ceiling. For *stratified* (head/tail) weightings we obtain the exact asymptotic ceiling
$\kappa(p,q) = 1 - (p^3+q^3/7)/(p+q)^3$, the sharp maximum
$\kappa^\star = 1 - 1/(1+\sqrt7)^2 = 0.9247639\ldots$ attained only at the irrational ratio
$q=\sqrt7\,p$, and the radix generalisation $\kappa_g = (g^3-1)/(g-1)^3$. For *arbitrary*
weightings the block-count cap applies verbatim: since a weighting never creates tie classes,
no weight vector whatsoever lifts the bit-length-$56$ dial above
$\rho^2 = 1 - 1/3249 + 2^{-112}$, and the class-equalising weight vector $w_k = 2^k$ attains
this optimum up to $1/n^2$.

The application is adjudicative. A fresh-seed replication at bit-length $56$ recorded pooled
$\rho(T,\text{rate}) = 0.669$ with CI $[0.650, 0.690]$ (inside the validation band, primary
hypothesis replicated) but a weighted advantage of $+0.045$ against a pre-stated bar of
$+0.05$ — a $0.005$ shortfall, and the weighted edge was declared not established. The
theory shows the entire reweighting budget on the $\rho$ scale is
$\sqrt{\kappa^\star}-\sqrt{6/7} \in (0.0358, 0.0359)$, over seven times the shortfall, and
that the recorded reading sits $\approx 0.29$ below even the conservative stratified optimum.
The shortfall is therefore a property of the response variable, not a geometric ceiling
imposed by the dial's tie structure.

**Keywords:** rank correlation, tie correction, power-mean inequality, 2-adic valuation,
trailing-zero statistic, tie profile, extremal combinatorics, sharp bounds.

---

## 1. Introduction

### 1.1 Coarse statistics and their ceilings

Many practical probes of a complex system are *coarse by design*: they map a rich state into
a small number of readings, trading resolution for interpretability and cost. A popcount, a
bucketised timing, a discretised difficulty score, a valuation of an integer — all take
finitely many values, and typically with very unequal frequencies.

Coarseness has a price that is often ignored until it bites. When a statistic takes the same
value on many observations, those observations are *tied*: no rank-based procedure can order
them. Standard rank-correlation coefficients handle this by assigning midranks, and the
resulting coefficient carries a *tie correction*. The correction is not a nuisance term. It
is an upper bound on measurable association: even against a perfectly monotone response, a
heavily tied statistic cannot report a correlation near $1$.

This paper studies that bound as a mathematical object in its own right. We take as given
the classical tie-attenuation law and ask three questions:

1. How much does the exact discrete ceiling differ from its clean continuum surrogate?
2. Over all profiles with a fixed number of classes, what is the best possible ceiling?
3. Can *reweighting* the sample — a common device in applied protocols — evade the bound?

The answers are, respectively: at most $1/n^2$; exactly $1 - 1/K^2$ up to $1/n^2$, attained
at the flat profile; and no — reweighting redistributes mass among classes but never creates
new ones, so the class-count bound is invariant under it.

### 1.2 The motivating experiment

The motivating instrument is the **zero-fit dial**: for an integer $x$, the statistic
$T(x) = \nu_2(x)$, the 2-adic valuation, i.e. the number of trailing zero bits. On uniform
draws from $\{0,\dots,2^b-1\}$ (with the convention that the zero draw sits in the deepest
class) the tie profile is the geometric cascade
$$L_b = \big(2^{b-1},\, 2^{b-2},\, \dots,\, 2,\, 1,\, 1\big),$$
with $K = b+1$ classes and mass $n = 2^b$.

A fresh-seed replication of a bit-length-$56$ cell across three independent seeds recorded a
pooled $\rho(T,\text{rate}) = 0.669$ with confidence interval $[0.650, 0.690]$, inside the
pre-registered validation band $[0.55, 0.85]$; the primary hypothesis replicated on all three
seeds. The secondary hypothesis — that the trailing-zero statistic outperforms a plain
popcount baseline by more than $+0.05$ — failed: the pooled advantage was $+0.045$, and only
one of three seeds cleared the bar. The record therefore reads *"the weighted edge is not
established at bit-length 56."*

Such a negative verdict admits two very different explanations. Either the dial genuinely
lacks the claimed edge on this response, or the dial's tie geometry is so coarse that the
measured advantage was capped below the bar by construction. Distinguishing them requires
knowing the dial's ceiling exactly, including under reweighting. That is what the theory
below supplies.

---

## 2. Setup and definitions

### 2.1 Tie profiles

**Definition 2.1 (Tie profile).** A *tie profile* is a finite list $L = (m_1,\dots,m_K)$ of
nonnegative integers. Its *length* $K = |L|$ is the number of tie classes, its *mass* is
$n = n(L) = \sum_{j=1}^K m_j$, and its *cubic moment* is
$$C(L) \;=\; \sum_{j=1}^{K} m_j^3 .$$

A statistic $T$ evaluated on a sample of size $n$ induces a tie profile: the sizes of its
level sets.

**Definition 2.2 (Tie correction and ceiling).** The Kendall tie correction of $L$ is
$$\mathrm{tie}(L) \;=\; \frac{1}{12}\sum_{j=1}^K \left(m_j^3 - m_j\right)
\;=\; \frac{C(L) - n}{12},$$
and the *ceiling* of $L$ — the maximum squared Spearman rank correlation achievable between
a statistic with profile $L$ and any response, attained when the response is a monotone
function of the statistic — is, for $n \ge 2$,
$$\rho^2_{\max}(L) \;=\; 1 - \frac{12\,\mathrm{tie}(L)}{n^3 - n}
\;=\; 1 - \frac{C(L) - n}{n^3 - n}. \tag{2.1}$$

Equation (2.1) is the *tie-attenuation law*. Note that it is invariant under permuting the
blocks and under deleting empty blocks, and that it depends on the profile only through
$(C(L), n)$.

Two immediate sanity checks. If all $m_j = 1$ (no ties) then $C(L) = n$ and
$\rho^2_{\max} = 1$. If $K=1$ then $C(L) = n^3$ and $\rho^2_{\max} = 0$: a constant statistic
carries no rank information.

**Definition 2.3 (Flat profile).** For $K, m \ge 1$, the *flat profile* $F_{K,m}$ is the
constant list of $K$ blocks each of size $m$; its mass is $Km$ and $C(F_{K,m}) = K m^3$.

**Definition 2.4 (Dyadic profile).** For $b \ge 0$ define $D_0 = (1)$ and
$D_{b+1} = (2^{b}) \frown D_b$. Explicitly
$D_b = (2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$ for $b\ge1$. This is the profile of the zero-fit
dial on uniform $b$-bit draws.

**Definition 2.5 (Weighting).** A *weight vector* is a list $W = (w_1,\dots,w_M)$ of
nonnegative integers. Its action on a profile $L$ with $|L| \le M$ is coordinatewise:
$$W \odot L \;=\; (w_1 m_1,\ w_2 m_2,\ \dots,\ w_K m_K).$$
Operationally, giving every observation in class $j$ multiplicity $w_j$ produces a sample
whose profile is $W \odot L$.

The crucial structural facts, both immediate, are:
$$n(W\odot L) = \sum_j w_j m_j, \qquad C(W \odot L) = \sum_j w_j^3 m_j^3, \qquad
|W \odot L| = |L|. \tag{2.2}$$
Mass scales linearly in the weights, the cubic moment cubically, and **the number of classes
does not change at all**. The first two facts make reweighting a genuine lever on the
ceiling; the third is the reason the main theorem of this paper applies to every weighting
scheme at once.

### 2.2 Two elementary moment bounds

**Lemma 2.6.** For every profile $L$, $\; n(L) \le C(L) \le n(L)^3$.

*Proof.* For the left inequality it suffices that $m \le m^3$ for every nonnegative integer
$m$, then sum. For the right, induct on the length: with $m$ the head and $S$ the sum of the
tail, $(m+S)^3 = m^3 + S^3 + 3mS(m+S) \ge m^3 + S^3 \ge m^3 + C(\text{tail})$ by the inductive
hypothesis and nonnegativity. $\square$

Both bounds are attained: the left at the tie-free profile, the right at $K=1$.

---

## 3. The continuum sandwich

Formula (2.1) is exact but slightly awkward: the $-m_j$ terms inside $\sum (m_j^3 - m_j)$ and
the $-n$ in the denominator are discrete corrections that obstruct clean optimisation. The
natural surrogate is the **continuum ceiling**
$$\widetilde\rho^{\,2}(L) \;=\; 1 - \frac{C(L)}{n^3},$$
which is scale-invariant: it depends only on the relative block frequencies $m_j/n$.

Crucially, the discrete ceiling is always *at least* the continuum one, since the discrete
corrections work in the profile's favour. A cap proved for $\widetilde\rho^{\,2}$ is therefore
not automatically a cap for $\rho^2_{\max}$ — a limit statement is not a finite-length
statement. The following theorem closes that gap once and for all.

**Theorem 3.1 (Continuum sandwich).** For every tie profile $L$ with mass $n \ge 2$,
$$1 - \frac{C(L)}{n^3} \;\;\le\;\; \rho^2_{\max}(L) \;\;\le\;\; 1 - \frac{C(L)}{n^3} + \frac{1}{n^2}.$$

*Proof sketch.* Write $C = C(L)$. Both halves compare the fractions
$A = \frac{C-n}{n^3-n}$ and $B = \frac{C}{n^3}$, since $\rho^2_{\max} = 1 - A$ and the
surrogate is $1-B$.

*Lower half* ($A \le B$): cross-multiplying against the positive denominators $n^3-n$ and
$n^3$, the claim $A \le B$ is equivalent to
$n^3(C-n) \le C(n^3-n)$, i.e. $-n^4 \le -nC$, i.e. $C \le n^3$ — which is the right-hand
bound of Lemma 2.6.

*Upper half* ($B - 1/n^2 \le A$): first note the exact algebraic identity
$$\frac{C}{n^3} - \frac{1}{n^2} \;=\; \frac{C-n}{n^3}.$$
Since $C \ge n$ by Lemma 2.6 the numerator is nonnegative, and $n^3 - n < n^3$, so shrinking
the denominator only increases the fraction:
$\frac{C-n}{n^3} \le \frac{C-n}{n^3-n} = A$. $\square$

The width of the sandwich is $1/n^2$, uniform over all profiles and independent of $K$ and of
the block sizes. For the dial at bit-length $b$ we have $n = 2^b$ and the width is $4^{-b}$:
at $b=56$ this is $2^{-112} \approx 1.93\times 10^{-34}$. Any continuum-level cap is therefore
a finite-length cap at negligible cost.

---

## 4. The power-mean bound and the block-count cap

### 4.1 A cubic factorisation

The engine of this paper is a single polynomial identity.

**Lemma 4.1 (Cubic weight identity).** For all real $s, u, v$,
$$(1+s)^2\left(s^2u^3 + v^3\right) - s^2(u+v)^3
\;=\; (v - su)^2\Big[(1+2s)\,v + s(2+s)\,u\Big].$$

*Proof.* Expand both sides; they agree coefficientwise. $\square$

The right-hand side is a perfect square times a linear form which is nonnegative whenever
$s, u, v \ge 0$. Hence for $s,u,v \ge 0$,
$$s^2(u+v)^3 \;\le\; (1+s)^2\left(s^2u^3 + v^3\right), \tag{4.1}$$
with equality precisely when $v = su$ (given $s>0$ and $(u,v)\neq(0,0)$).

This one identity does double duty. With $s$ real and interpreted as a weight ratio it
produces the sharp $\sqrt{7}$ constant of Section 5. With $s = K$ an integer block count it
produces the power-mean bound below.

### 4.2 The power-mean bound

**Theorem 4.2 (Power-mean bound).** For every tie profile $L$ with $K = |L|$ blocks and mass
$n = n(L)$,
$$n^3 \;\le\; K^2\,C(L),$$
with equality if and only if $L$ is flat.

*Proof sketch.* This is the Chebyshev/Hölder power-mean inequality
$\left(\frac1K\sum m_j\right)^3 \le \frac1K \sum m_j^3$, but we give the inductive proof
because it is the one that generalises and because it exposes the same factorisation as
Lemma 4.1.

Induct on the length of $L$. The empty list is trivial ($0 \le 0$). For $L = (m) \frown L'$
with $K' = |L'|$, $S = n(L')$, $C' = C(L')$, the inductive hypothesis is $S^3 \le K'^2 C'$ and
the goal is
$$(m+S)^3 \;\le\; (K'+1)^2\left(m^3 + C'\right).$$
If $K' = 0$ then $S = 0$ (an empty list has zero mass) and the goal is $m^3 \le m^3$. If
$K' \ge 1$, apply (4.1) with $s = K'$, $u = m$, $v = S$ to get
$$K'^2 (m+S)^3 \;\le\; (1+K')^2\left(K'^2 m^3 + S^3\right)
\;\le\; (1+K')^2\left(K'^2 m^3 + K'^2 C'\right),$$
using the inductive hypothesis in the second step; dividing by $K'^2 > 0$ gives the goal.

Equality analysis: the slack in (4.1) is $(S - K'm)^2$ times a positive form, so equality
forces $S = K'm$, i.e. the head equals the mean of the tail; propagating down the induction
forces all blocks equal. Conversely the flat profile $F_{K,m}$ gives
$n^3 = K^3m^3 = K^2\cdot Km^3 = K^2 C$. $\square$

Equivalently, for $K \ge 1$ and $n \ge 1$,
$$\frac{1}{K^2} \;\le\; \frac{C(L)}{n^3}. \tag{4.2}$$
The cubic moment of a $K$-block profile can never fall below the $1/K^2$ fraction of $n^3$
that the flat profile achieves. This is the precise sense in which "spreading mass evenly" is
the best a fixed number of classes can do.

### 4.3 The main theorem

**Theorem 4.3 (Block-count cap).** For every tie profile $L$ with $K$ blocks and mass
$n \ge 2$,
$$\rho^2_{\max}(L) \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2}.$$

*Proof.* Combine the upper half of Theorem 3.1 with (4.2):
$\rho^2_{\max} \le 1 - C/n^3 + 1/n^2 \le 1 - 1/K^2 + 1/n^2$. (Positivity of $K$ and $n$
follows from $n \ge 2$, which forces the list to be nonempty.) $\square$

The striking feature is what has disappeared: the bound mentions the block *sizes* nowhere.
Whatever the shape of the profile — one dominant class, a geometric cascade, a pathological
spike — the ceiling is governed by the class count alone, up to $1/n^2$.

**Theorem 4.4 (Sharpness).** For $K \ge 2$ and $m \ge 1$, the flat profile $F_{K,m}$ (mass
$n = Km \ge 2$) satisfies
$$1 - \frac{1}{K^2} \;\le\; \rho^2_{\max}(F_{K,m}) \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2}.$$
Hence the constant $1-1/K^2$ in Theorem 4.3 cannot be lowered.

*Proof sketch.* The upper bound is Theorem 4.3 with $|F_{K,m}| = K$. For the lower bound,
apply the *lower* half of Theorem 3.1 together with the exact evaluation
$C(F_{K,m})/n^3 = Km^3/(Km)^3 = 1/K^2$, giving
$\rho^2_{\max}(F_{K,m}) \ge 1 - 1/K^2$. $\square$

Thus $\sup\{\rho^2_{\max}(L) : |L| = K,\ n(L) = n\} = 1 - 1/K^2 + O(n^{-2})$, and the
supremum is attained (up to that correction) exactly at the flat profile. As $K$ grows the cap
tends to $1$: adding classes, and only adding classes, buys resolution.

---

## 5. The 2-adic dial and the $\sqrt{7}$ optimum

We now specialise to the dial and to the stratified weightings that motivated the analysis,
before returning to the general cap in Section 6.

### 5.1 The unweighted ceiling

**Proposition 5.1.** The dyadic profile $D_b$ has $|D_b| = b+1$, mass $n = 2^b$, and cubic
moment
$$C(D_b) \;=\; \frac{8^b + 6}{7}.$$

*Proof.* Length and mass are immediate inductions from $D_{b+1} = (2^b)\frown D_b$. For the
moment, $C(D_{b+1}) = 8^b + C(D_b)$, and $(8^{b+1}+6)/7 = 8^b + (8^b+6)/7$ since
$8^{b+1} + 6 = 7\cdot 8^b + (8^b + 6)$. The base case $C(D_0) = 1 = (1+6)/7$ checks. $\square$

Consequently the continuum ceiling of the dial is $1 - \frac{8^b+6}{7\cdot 8^b} \to 6/7$, and
by Theorem 3.1 the exact ceiling satisfies
$$\rho_{\max}(D_b) \;=\; \sqrt{6/7} + O(4^{-b}) \;=\; 0.9258201\ldots + O(4^{-b}).$$
The dominant odd class, holding half the mass, permanently costs the dial one seventh of its
squared resolving power, uniformly in $b$.

### 5.2 Stratified weightings

**Definition 5.2.** For $p,q \ge 1$ the *stratified weighting* of the bit-length-$b$ dial
weights the dominant class (mass $2^b$) by $p$ and every deeper class by $q$; explicitly it
is the profile
$$W_b(p,q) \;=\; \big(p\,2^b\big) \frown q\!\cdot\! D_b .$$
Note $W_b(1,1) = D_{b+1}$: uniform weighting merely advances the bit-length, as it must.

From (2.2), $n(W_b(p,q)) = (p+q)2^b$ and $C(W_b(p,q)) = p^3 8^b + q^3 \frac{8^b+6}{7}$, so the
exact ceiling is available in closed form in $p,q,2^b$. Passing to the bit-length limit:

**Theorem 5.3 (Stratified ceiling).** For fixed $p,q \ge 1$,
$$\lim_{b\to\infty} \rho^2_{\max}\big(W_b(p,q)\big)
\;=\; \kappa(p,q) \;:=\; 1 - \frac{p^3 + q^3/7}{(p+q)^3}.$$

*Proof sketch.* Substitute the closed forms into (2.1), divide numerator and denominator by
$8^b$, and let $b\to\infty$; the $+6/7$ and the discrete $-n$ terms are $O(8^{-b})$ and
$O(2^{-2b})$ respectively. $\square$

**Theorem 5.4 (Weighting strictly helps).** For every $b \ge 2$,
$$\rho^2_{\max}\big(W_b(1,3)\big) \;>\; \rho^2_{\max}\big(D_{b+1}\big) = \rho^2_{\max}\big(W_b(1,1)\big).$$

*Proof sketch.* Both sides are explicit rational functions of $2^b$ from the closed forms;
the difference is a ratio of polynomials in $2^b$ whose numerator is positive for
$2^b \ge 4$. Conceptually: tripling the deep classes dilutes the dominant block, and since
mass scales linearly while the cubic moment scales cubically only *within* the reweighted
classes, the ratio $C/n^3$ strictly decreases. $\square$

So reweighting is not cosmetic. How far can it go?

**Theorem 5.5 ($\sqrt7$ cap, with equality case).** For all $p > 0$ and $q \ge 0$,
$$\kappa(p,q) \;\le\; \kappa^\star \;:=\; 1 - \frac{1}{\big(1+\sqrt7\big)^2},$$
with equality if and only if $q = \sqrt7\,p$. Numerically
$\kappa^\star = 0.9247639\ldots$ and $\sqrt{\kappa^\star} = 0.9616465\ldots$

*Proof sketch.* Write $\kappa(p,q) = 1 - \frac{7p^3+q^3}{7(p+q)^3}$, so maximising $\kappa$ is
minimising $\frac{7p^3+q^3}{7(p+q)^3}$. Apply Lemma 4.1 with $s = \sqrt7$, $u = p$, $v = q$:
$$(1+\sqrt7)^2\left(7p^3 + q^3\right) - 7(p+q)^3
= \left(q - \sqrt7 p\right)^2\Big[(1+2\sqrt7)q + \sqrt7(2+\sqrt7)p\Big] \;\ge\; 0,$$
the bracket being positive for $p>0,q\ge0$. Rearranged, this is exactly
$\frac{7p^3+q^3}{7(p+q)^3} \ge \frac{1}{(1+\sqrt7)^2}$, i.e. $\kappa \le \kappa^\star$, and the
slack vanishes iff $q = \sqrt7 p$. $\square$

**Corollary 5.6 (No rational weighting is optimal).** Since $\sqrt7 \notin \mathbb{Q}$, every
rational weight ratio $q/p$ satisfies $\kappa(p,q) < \kappa^\star$ strictly. The
continued-fraction convergent $q/p = 37/14$ nevertheless realises $\kappa^\star$ to within
$10^{-7}$.

**Theorem 5.7 (Finite-length sharpness).** At every finite bit-length $b$ and for all
$p,q\ge1$,
$$\rho^2_{\max}\big(W_b(p,q)\big) \;\le\; \kappa(p,q) + \frac{1}{4\cdot 4^{b}}
\;\le\; \kappa^\star + 4^{-(b+1)} .$$

*Proof sketch.* Theorem 3.1 bounds the discrete ceiling by the continuum one plus
$1/n^2 = 1/((p+q)^2 4^b) \le 1/(4\cdot 4^b)$; the continuum ceiling of the finite profile is
$\kappa(p,q)$ up to a term of the same order, and Theorem 5.5 caps $\kappa$. $\square$

At $b=56$ this reads: no stratified weighting whatsoever reaches
$\kappa^\star + 10^{-33}$, i.e. no stratified weighted binary dial can report
$\rho > 0.9616465$ at bit-length $56$.

### 5.3 The radix law

The constant $7$ is not special to binary; it is the cubic sum of a geometric cascade of
ratio $1/g$.

**Definition/Theorem 5.8 (Radix constant).** For a radix $g > 1$ define the $g$-adic profile
$D_b^{(g)}$ analogously (block sizes $(g-1)g^{b-1}, (g-1)g^{b-2},\dots,(g-1),1$) and set
$$\kappa_g \;=\; \frac{g^3-1}{(g-1)^3} .$$
Then $\kappa_2 = 7$ and $\kappa_{10} = 111/81$, the limiting cubic-moment fraction of the
$g$-adic dial is $1/\kappa_g$, the stratified ceiling is
$$\kappa^{(g)}(p,q) = 1 - \frac{p^3 + q^3/\kappa_g}{(p+q)^3},$$
and its sharp maximum is $1 - 1/(1+\sqrt{\kappa_g})^2$, attained at $q = \sqrt{\kappa_g}\,p$.

**Theorem 5.9 (Monotonicity of the weighting gain).** Define the *weighting gain*
$$G(\kappa) \;=\; \frac{1}{\kappa} - \frac{1}{\big(1+\sqrt{\kappa}\big)^2},$$
the improvement in squared ceiling that optimal stratified weighting buys over none. Then
$G(\kappa) > 0$ for all $\kappa > 0$, and $G$ is strictly decreasing.

*Proof sketch.* Substituting $\kappa = s^2$ with $s>0$ gives
$G(s^2) = \frac{1}{s^2} - \frac{1}{(1+s)^2} = \frac{(1+s)^2 - s^2}{s^2(1+s)^2}
= \frac{1+2s}{s^2(1+s)^2}$, manifestly positive; and the numerator grows linearly while the
denominator grows quartically, so $G$ is strictly decreasing in $s$, hence in $\kappa$.
$\square$

Coarser cascades (smaller $\kappa$, i.e. larger radix... more precisely: profiles whose
dominant block carries a larger share) leave more gain on the table. For binary,
$G(7) = 1/7 - 1/(1+\sqrt7)^2 = 0.14286 - 0.07524 = 0.06762$ in squared units, which is the
$0.0358$ figure once converted to the $\rho$ scale.

---

## 6. Arbitrary weightings: the class count is the whole story

Theorem 5.5 is sharp but *conditional*: it assumes a two-level, head/tail weighting. An
adversarial protocol designer would not accept that restriction; they would tune all $b+1$
weights independently. The block-count cap removes the restriction with no loss.

**Lemma 6.1.** $|D_b| = b+1$; and for any weight vector $W$ with $|W| \ge b+1$,
$|W \odot D_b| = b+1$.

*Proof.* Induction for the first claim; the second is (2.2), since coordinatewise
multiplication truncated to the shorter list preserves length when the weight vector is at
least as long. $\square$

**Theorem 6.2 (Universal weighted cap for the dial).** Let $b \ge 0$ and let $W$ be any
weight vector with $|W| \ge b+1$ such that the reweighted sample has mass $n \ge 2$. Then
$$\rho^2_{\max}\big(W \odot D_b\big) \;\le\; 1 - \frac{1}{(b+1)^2} + \frac{1}{n^2}.$$

*Proof.* By Lemma 6.1 the reweighted profile has exactly $b+1$ blocks; apply Theorem 4.3.
$\square$

**Corollary 6.3 (Bit-length 56).** For any weight vector $W$ with $|W| \ge 57$ and reweighted
mass $n \ge 2$,
$$\rho^2_{\max}\big(W \odot D_{56}\big) \;\le\; 1 - \frac{1}{3249} + \frac{1}{n^2},$$
so with $n = 2^{56}$ (the all-ones weighting) the cap is $1 - 1/3249 + 2^{-112}$, i.e.
$\rho \le 0.9998461\ldots$

**Remark 6.4 (Non-vacuity).** The hypotheses of Corollary 6.3 are satisfiable: the all-ones
vector of length $57$ has $|W| = 57$ and $W \odot D_{56} = D_{56}$, whose mass $2^{56} \ge 2$.
The cap is therefore a statement with content, not a vacuous implication.

**Theorem 6.5 (Optimality of the equalising weighting).** For $b \ge 1$ let $E_b$ be the
weight vector giving the class of numbers with exactly $k$ trailing zeros the weight $2^k$
(so $E_b \odot D_b$ is the flat profile of $b+1$ blocks of size $2^{b-1}$). Then for every
weight vector $W$ with $|W| \ge b+1$ and reweighted mass $n \ge 2$,
$$\rho^2_{\max}\big(W \odot D_b\big) \;\le\; \rho^2_{\max}\big(E_b \odot D_b\big) + \frac{1}{n^2}.$$

*Proof sketch.* The equalising weighting flattens the geometric cascade, so by Theorem 4.4
its ceiling is at least $1 - 1/(b+1)^2$; Theorem 6.2 caps every competitor at
$1 - 1/(b+1)^2 + 1/n^2$. $\square$

So the extremal design is explicit: weight each class inversely to its frequency. Every other
weighting is worse, by an amount that is only bounded below by $0$ but is never negative
beyond $1/n^2$.

**Interpretation.** The two caps answer complementary questions.

| Regime | Cap on $\rho^2$ | Cap on $\rho$ at $b=56$ | Sharp? |
|---|---|---|---|
| No weighting | $6/7 + O(4^{-b})$ | $0.9258201$ | exact |
| Stratified (head/tail) | $\kappa^\star = 1-\tfrac1{(1+\sqrt7)^2}$ | $0.9616465$ | yes, at $q=\sqrt7 p$ |
| Arbitrary weight vector | $1 - \tfrac1{(b+1)^2} + \tfrac1{n^2}$ | $0.9998461$ | yes, at the flat profile |

The jump from $0.9616$ to $0.9998$ is exactly the value of the extra design freedom — and it
comes with a warning attached: an experimental protocol that permits arbitrary per-class
reweighting is no longer measuring the dial as such, since it can flatten the dial's
characteristic geometric signature into a profile carrying nearly full rank information.

---

## 7. Application: adjudicating the bit-length-56 record

The recorded quantities are: pooled $\rho(T,\text{rate}) = 0.669$; confidence interval
$[0.650, 0.690]$; validation band $[0.55, 0.85]$; pre-stated advantage bar $+0.05$; observed
pooled advantage $+0.045$; shortfall $0.005$; baseline (popcount) pooled reading
$0.669 - 0.045 = 0.624$.

Four verifiable consequences follow.

**(a) The primary hypothesis is comfortably inside the band.** $0.55 \le 0.650$ and
$0.690 \le 0.85$: the whole interval lies inside the validation band.

**(b) Both statistics read far below their own ceilings.** $0.669^2 = 0.4476 <
\rho^2_{\max}(D_{56}) \approx 6/7 = 0.8571$, and likewise for the baseline's own profile. The
$0.005$ shortfall is not a granularity artefact of either instrument.

**(c) The reweighting budget exceeds the shortfall sevenfold.** On the $\rho$ scale the
maximal gain achievable by any stratified reweighting of the binary dial is
$$\sqrt{\kappa^\star} - \sqrt{6/7} \;=\; 0.9616465\ldots - 0.9258201\ldots \;\in\; (0.0358,\ 0.0359),$$
which is more than $7 \times 0.005$. Had the tie geometry been the binding constraint, this
budget would have had to be smaller than the shortfall. It is not.

**(d) Headroom under the optimal weighting is enormous.** Even against the conservative
stratified optimum $\sqrt{\kappa^\star} = 0.96165$, the recorded $0.669$ leaves
$0.2926$ of unused correlation range — nearly sixty times the missing margin. Against the
universal cap of Corollary 6.3 the headroom is $0.3308$.

**Conclusion.** The failure of the advantage hypothesis at bit-length $56$ is a fact about
the *response variable*, not a geometric ceiling imposed by the dial's ties. Count parity in
this batch — the popcount baseline catching up — is not evidence that the trailing-zero
statistic is saturated; the statistic's own ceiling is nowhere near being touched, under any
weighting scheme whatsoever.

This is the useful form of a negative result: not "we failed to detect an effect," but "the
instrument had, provably, seven times the dynamic range required to detect the effect, and it
did not appear."

---

## 8. Algorithms

Three computations underpin the numerical claims; all are elementary and cheap.

**Algorithm A (Exact ceiling of a profile).** Given $L$, compute $n = \sum m_j$ and
$C = \sum m_j^3$ in exact rational (or big-integer) arithmetic, then return
$1 - (C-n)/(n^3-n)$. Cost $O(K)$ big-integer operations. Exact arithmetic matters: at
$b = 56$ the quantities involved span $10^{50}$, and double precision silently destroys the
$1/n^2$ corrections that the sandwich is about.

**Algorithm B (Cap comparison).** Given $L$, return the triple
$\big(1 - C/n^3,\ \rho^2_{\max}(L),\ 1 - C/n^3 + 1/n^2\big)$ and assert the sandwich; then
return $1 - 1/K^2 + 1/n^2$ and assert the block-count cap. This is a direct executable
witness for Theorems 3.1 and 4.3 on any concrete profile. Cost $O(K)$.

**Algorithm C (Optimal stratified ratio search).** Maximise
$\kappa(1,s) = 1 - (1 + s^3/7)/(1+s)^3$ over $s > 0$. Ternary search on the unimodal
objective converges to $s^\star = \sqrt7$; alternatively enumerate the continued-fraction
convergents of $\sqrt7 = [2;\overline{1,1,1,4}]$, namely $2, 3, 5/2, 8/3, 37/14, \dots$, and
report the first whose $\kappa$ is within a target tolerance of $\kappa^\star$. Cost
$O(\log(1/\varepsilon))$.

---

## 9. Discussion

### 9.1 What the block-count cap does and does not say

The cap $\rho^2_{\max} \le 1 - 1/K^2 + 1/n^2$ is a statement about *achievable* correlation
under the most favourable possible response. It says nothing about the *actual* correlation of
any particular dataset, which will generally be far lower. Its value is diagnostic: when a
measured correlation falls short of a target, the cap tells you whether the instrument could
possibly have reached the target. If the cap is below the target, the experiment was
ill-posed; if the cap is far above, as here, the shortfall is substantive.

The cap is also *tight only at the flat profile*. For strongly unequal profiles — the dyadic
cascade being the canonical example — the true ceiling is much lower than $1 - 1/K^2$. The
cap's role is as a universal, weighting-invariant envelope, not as an accurate predictor for
a given shape. When one wants accuracy for a specific family, the exact cubic-moment formula
(2.1) with a closed-form $C$ is available, as in Proposition 5.1.

### 9.2 Why the class count, and not the entropy?

One might expect the ceiling to be governed by an entropy-like functional of the frequency
vector. It is, in a sense: $C(L)/n^3 = \sum_j f_j^3$ where $f_j = m_j/n$ is precisely the
*collision-triple* probability, a Rényi-type quantity of order $3$ (the probability that three
independent draws all land in the same class). The continuum ceiling is exactly
$1 - \|f\|_3^3$. The block-count cap is then the statement
$\|f\|_3^3 \ge K^{-2}$ — the standard power-mean lower bound for an $\ell^3$ norm on the
simplex. Read this way, the paper's message is: rank-correlation ceilings are governed by the
order-3 Rényi collision quantity of the tie distribution, and the class count is the crudest
invariant that controls it from above.

### 9.3 The two roles of the cubic identity

It is worth emphasising the structural coincidence of Section 4.1. The identity
$(1+s)^2(s^2u^3+v^3) - s^2(u+v)^3 = (v-su)^2[(1+2s)v + s(2+s)u]$ produces:

- with $s = \sqrt{\kappa_g}$ a real parameter: the *sharp constant* $1-1/(1+\sqrt{\kappa_g})^2$
  for stratified weightings, with the equality case pinning down an irrational optimum;
- with $s = K$ an integer block count and induction over the list: the *universal* power-mean
  bound $n^3 \le K^2 C(L)$.

The same square $(v - su)^2$ encodes "the tail is $s$ times the head" in both cases; in the
first it is the optimal weight ratio, in the second it is the flatness condition. That the
irrational optimum and the flat extremiser come from one algebraic source is the tidiest
structural fact in this development.

### 9.4 Practical design guidance

For anyone building a coarse probe:

1. **Count your classes first.** The number $K$ of distinct readings bounds your ceiling at
   $1 - 1/K^2$ before you collect any data. If your target correlation exceeds
   $\sqrt{1-1/K^2}$, refine the statistic.
2. **Weighting buys a bounded, computable amount.** For a geometric cascade of ratio $1/g$
   the gain is $G(\kappa_g)$ in squared units — for binary, about $0.036$ on the $\rho$ scale.
   Budget accordingly; do not expect reweighting to rescue a fundamentally coarse probe.
3. **The best weighting is inverse-frequency.** Flattening the profile is optimal to within
   $1/n^2$. But flattening a $57$-class dyadic cascade means upweighting a singleton class by
   $2^{55}$, which destroys the variance properties of the estimator; the sharp stratified cap
   is the realistic target, and the block-count cap the theoretical envelope.
4. **Report ceilings alongside readings.** A correlation of $0.669$ against a ceiling of
   $0.9258$ means something quite different from the same reading against a ceiling of
   $0.70$.

---

## 10. Future directions

**1. Continuum-sandwich rigidity for multiplicative tie profiles.** The sandwich width
$1/n^2$ is an upper bound on the discrete correction, but one expects it to be its exact
leading order whenever the largest block is a constant fraction of $n$. Making this a
two-sided asymptotic — an expansion
$\rho^2_{\max} = 1 - \|f\|_3^3 + c(f)/n^2 + O(n^{-3})$ with $c(f)$ identified — would upgrade
every cap here to an equality up to $O(n^{-3})$, and would in particular decide whether the
flat profile is the exact maximiser at finite $n$, not merely up to $1/n^2$.

**2. Multi-statistic Gram geometry.** The caps here concern one statistic against one
response. When $k$ statistics with profiles $L_1,\dots,L_k$ are combined, the relevant object
is the Gram matrix of their midrank vectors, and the achievable multiple correlation depends
on the *joint* tie structure. A block-count cap for the joint case — presumably in terms of
the number of cells of the common refinement — would bound what any ensemble of coarse probes
can achieve.

**3. Sharp constants for constrained weightings.** Between the two-level stratified family
and the fully arbitrary one lies a natural hierarchy: $r$-level weightings for
$r = 2, 3, \dots, K$. Theorem 5.5 handles $r=2$ and Theorem 4.3 handles $r=K$. Determining the
sharp constant $\kappa^\star_r$ for each $r$ would interpolate between $0.9247$ and
$1 - 1/K^2$, and the equality cases should again be algebraic numbers arising from an
$r$-variable analogue of Lemma 4.1.

**4. Variance-aware optimality.** Inverse-frequency weighting maximises the ceiling but can
inflate estimator variance catastrophically. A constrained optimisation — maximise the
ceiling subject to a bound on $\max_j w_j / \min_j w_j$, or on the effective sample size
$(\sum w_j m_j)^2 / \sum w_j^2 m_j$ — would produce the weighting a practitioner should
actually use, and its optimum should again be governed by a cubic extremal problem.

**5. Radix and valuation generalisations.** The radix law $\kappa_g = (g^3-1)/(g-1)^3$ invites
a general theory for valuations on arbitrary discrete valuation rings, and for profiles with
non-geometric decay. Which decay rates $m_j \sim n\,\alpha^j$ admit closed-form ceilings, and
what replaces $\sqrt{\kappa_g}$ for sub-geometric cascades?

---

## 11. Conclusion

We have shown that the ceiling on rank correlation imposed by ties is governed, uniformly over
all tie profiles and to within an additive $1/n^2$, by the number of tie classes alone:
$$\rho^2_{\max} \;\le\; 1 - \frac{1}{K^2} + \frac{1}{n^2},$$
sharp at the flat profile. Since reweighting a sample redistributes mass among classes without
creating new ones, this caps *every* weighting scheme simultaneously. Specialising to the
2-adic zero-fit dial, the unweighted ceiling is $\sqrt{6/7} = 0.92582$, the sharp ceiling under
two-level weightings is $\sqrt{1 - 1/(1+\sqrt7)^2} = 0.96165$ attained only at the irrational
ratio $q = \sqrt7\,p$, and the universal ceiling under arbitrary weightings at bit-length $56$
is $0.99985$. All three are finite-length statements, not asymptotic ones, thanks to the
continuum sandwich.

Applied to the recorded bit-length-$56$ replication, these bounds show that the $0.005$
shortfall in the weighted-advantage hypothesis cannot be attributed to the dial's tie geometry:
the reweighting budget is seven times the shortfall, and the recorded reading leaves roughly
$0.29$ of correlation headroom under even the conservative optimum. The negative verdict is a
statement about the response variable, and the instrument is exonerated.
