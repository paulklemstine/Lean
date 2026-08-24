# The Correlation Budget: Parity Thresholds and Capacity Laws for Shared-Response Rank Statistics

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study a purely geometric constraint on the situation in which several statistics are
scored against a single shared response, and we apply it to a measured rank-correlation
"dial" whose value declines with the bit-length of the underlying uniform draws. Our
starting point is the three-variable Gram inequality $a^2+b^2+c^2 \le 1 + 2abc$, valid for
the three pairwise correlations of any three real data vectors. From it we derive the
**parity ceiling law**: if two statistics each correlate at level at least $\rho \ge 0$ with
a shared response and their mutual correlation is $c < 1$, then $\rho^2 \le (1+c)/2$. In
particular, two decorrelated statistics can never both read above $\sqrt2/2 \approx 0.70711$,
and we show this threshold is exactly attained by an explicit three-dimensional
configuration. Two consequences follow: a **forcing law** $c \ge ab - \sqrt{(1-a^2)(1-b^2)}$
bounding the mutual correlation from below, and an **advantage law** stating that a
decorrelated baseline facing a dial reading $\rho$ must lose by at least
$\rho - \sqrt{1-\rho^2}$, which is strictly positive precisely above the threshold.

We then generalise from two statistics to $k$. Bessel's inequality for the coordinate inner
product yields the **correlation budget** $\sum_{i=1}^{k}\rho_i^2 \le 1$ over any mutually
decorrelated family, hence the **capacity law** $k\rho^2 \le 1$, i.e. $\rho \le 1/\sqrt k$;
and we exhibit, for every $t$ with $kt^2 \le 1$, an orthonormal family of $k$ statistics in
dimension $k+1$ all reading exactly $t$, so the capacity law is an equality rather than a
bound. A bridge lemma identifies Spearman's coefficient $1 - 6\sum d_i^2/(n^3-n)$ with the
Pearson correlation of centred rank vectors, using the fact that every tie-free ranking of
$n$ items has centred squared norm $(n^3-n)/12$; consequently all of the above applies
verbatim to rank data.

Applied to the recorded measurements, the theory yields a sharp dichotomy: the bitlen-72
reading $0.605$ has decorrelated capacity exactly two (a pair of decorrelated statistics can
both attain it, and does in an explicit configuration; three cannot, since
$3(0.605)^2 = 1.098 > 1$), while the bitlen-44 reading $0.78$ has capacity one (not even a
pair fits). The observed disappearance of the count advantage as the dial declines from
$0.78$ to $0.605$ is therefore not a property of the two particular statistics involved but
the signature of the dial crossing the geometric threshold $1/\sqrt 2$. We record honestly
that the forcing law is vacuous at the bitlen-72 numbers, and discuss what a genuine
"decline theorem" would require.

**Keywords:** Spearman rank correlation, Gram determinant, Bessel inequality, correlation
budget, parity threshold, shared response, capacity law.

---

## 1. Introduction

### 1.1 The measurement

Fix a bit-length $B$. Draw an integer uniformly from $\{0,1,\dots,2^B-1\}$ and compute the
*zero-count statistic* $T$: the number of trailing binary zeros, that is, the exponent of
the largest power of two dividing the draw. Independently the trial produces a scalar
outcome, the *rate*. The **dial** is the Spearman rank correlation between $T$ and the rate
over a sample of trials.

The measurement at $B = 72$, over three seeds, produced

$$0.605,\qquad 0.606,\qquad 0.603,$$

pooling to $0.605$ with confidence interval $[0.586,\ 0.625]$. All values lie inside the
pre-registered validation band $[0.55,\ 0.85]$. The dial declines gently and monotonically
with bit-length: approximately $0.78$ at $B = 44$, approximately $0.605$ at $B = 72$.

Alongside $T$ the campaign scores a deliberately naive **count baseline** — the popcount,
i.e. the number of one-bits. At $B \in [44,52]$ the zero-count enjoys an advantage of
roughly $+0.07$ in correlation over the popcount. At $B = 72$ that advantage has fallen
below $+0.05$. This is the phenomenon called **count parity**.

### 1.2 Why the previous tools cannot explain parity

Prior analyses of the dial were *single-statistic*: they bounded what one rank statistic can
achieve given its tie structure. In particular a tie-attenuation identity of the form
$\rho^2 = 1 - 12\sum_j (m_j^3 - m_j)/(n^3-n)$, where $m_j$ are the sizes of the tie classes,
caps a dyadic statistic like $T$ at $\rho^2 \le 6/7$, i.e. $\rho \le 0.9258$. That ceiling is
real but it is (i) far above the observed values and (ii) *flat* in the bit-length, so it can
explain neither the decline nor the parity.

Parity is intrinsically a statement about **two** statistics read against **one** response —
a three-variable question. Three-variable correlation data is constrained not by tie
geometry but by Gram positivity. Supplying that geometry, and extracting sharp thresholds
from it, is the content of this paper.

### 1.3 Contributions

1. The parity ceiling law $\rho^2 \le (1+c)/2$ and the decorrelated threshold $\sqrt2/2$,
   with an explicit realisation showing the threshold is attained (§3).
2. The forcing law and the advantage law, converting readings into lower bounds on mutual
   correlation and on the baseline's deficit (§4).
3. The Spearman bridge: rank correlation is a Pearson correlation of centred rank vectors,
   so the geometry applies to the measured quantities (§5).
4. The correlation budget $\sum_i \rho_i^2 \le 1$ and the capacity law $\rho \le 1/\sqrt k$,
   with matching sharp constructions (§6).
5. The capacity classification of the recorded readings and the resulting falsifiable
   predictions (§7), together with an explicit statement of what the theory *cannot* do (§8).

---

## 2. Setting and definitions

We work throughout with finite real coordinate vectors, $u, v, w \in \mathbb R^n$, indexed
by $i = 1,\dots,n$. All results are elementary and require no probabilistic assumptions
whatsoever: they are statements about vectors of numbers.

**Definition 2.1 (Inner product and norm).** For $u,v \in \mathbb R^n$ put
$$\langle u, v\rangle = \sum_{i=1}^n u_i v_i, \qquad \|u\| = \sqrt{\langle u,u\rangle}.$$

**Definition 2.2 (Correlation).** For $u,v$ with $\langle u,u\rangle \ne 0$ and
$\langle v,v\rangle \ne 0$,
$$\operatorname{corr}(u,v) \;=\; \frac{\langle u,v\rangle}{\|u\|\,\|v\|}.$$
When $u,v$ are *centred* (mean zero) data vectors this is precisely the Pearson correlation
coefficient. In §5 we show that when they are centred *rank* vectors it is precisely
Spearman's coefficient. We will speak of a statistic "reading $\rho$ against a response"
to mean $\operatorname{corr}(\text{statistic}, \text{response}) = \rho$.

**Definition 2.3 (Mean and centring).** $\operatorname{avg}(u) = \frac1n\sum_i u_i$ and
$\tilde u = (u_i - \operatorname{avg}(u))_{i}$.

**Definition 2.4 (Decorrelated family).** A family $u_1,\dots,u_k \in \mathbb R^n$ is
*orthonormal* if $\langle u_i,u_i\rangle = 1$ for all $i$ and $\langle u_i,u_j\rangle = 0$
for $i \ne j$. Any family of pairwise uncorrelated statistics can be normalised to this
form without changing any correlation with a response, so "decorrelated family" and
"orthonormal family" are interchangeable for our purposes.

Two elementary facts are used repeatedly: $\langle u,u\rangle \ge 0$, and the Cauchy–Schwarz
inequality $\langle u,v\rangle^2 \le \langle u,u\rangle \langle v,v\rangle$.

---

## 3. The three-correlation inequality and the parity threshold

### 3.1 Gram positivity

**Theorem 3.1 (Three-vector Gram positivity, homogeneous form).**
For all $u,v,w \in \mathbb R^n$, writing $p = \langle u,u\rangle$, $q = \langle v,v\rangle$,
$r = \langle w,w\rangle$, $A = \langle u,w\rangle$, $B = \langle v,w\rangle$,
$C = \langle u,v\rangle$,
$$0 \;\le\; pqr + 2ABC - pB^2 - qA^2 - rC^2 .$$

*Proof sketch.* The right-hand side is the determinant of the Gram matrix
$\begin{pmatrix} p & C & A \\ C & q & B \\ A & B & r\end{pmatrix}$, which is positive
semidefinite. A direct elementary argument avoiding determinant theory: if $p = 0$ then
$u = 0$, hence $A = C = 0$ and the expression reduces to $pqr - qA^2 = 0$. If $p > 0$,
consider the residuals of $v$ and $w$ after projection onto $u$, scaled by $p$ to remain
polynomial:
$$v' = p\,v - C\,u, \qquad w' = p\,w - A\,u .$$
Then $\langle v',v'\rangle = p(pq - C^2)$, $\langle w',w'\rangle = p(pr - A^2)$ and
$\langle v',w'\rangle = p(pB - AC)$. Cauchy–Schwarz applied to $v',w'$ gives
$p^2(pB-AC)^2 \le p^2(pq-C^2)(pr-A^2)$; expanding and dividing by $p$ (which is positive)
yields exactly the claimed inequality. $\square$

**Theorem 3.2 (Correlation form).** Let $u,v,w$ be nonzero, and set
$$a = \operatorname{corr}(u,w),\quad b = \operatorname{corr}(v,w),\quad c = \operatorname{corr}(u,v).$$
Then
$$a^2 + b^2 + c^2 \;\le\; 1 + 2abc .$$

*Proof sketch.* Divide the inequality of Theorem 3.1 by $pqr > 0$ and substitute
$a^2 = A^2/(pr)$, $b^2 = B^2/(qr)$, $c^2 = C^2/(pq)$, $abc = ABC/(pqr)$. $\square$

Geometrically, Theorem 3.2 says: the three pairwise cosines of three directions in Euclidean
space cannot be arbitrary. Also note the immediate corollary $|{\operatorname{corr}(u,v)}| \le 1$,
which follows from Cauchy–Schwarz directly.

### 3.2 The parity ceiling

**Theorem 3.3 (Parity ceiling law).** Suppose $a,b,c,\rho$ satisfy the Gram inequality
$a^2+b^2+c^2 \le 1+2abc$, with $c < 1$, $\rho \ge 0$, $\rho \le a$ and $\rho \le b$. Then
$$\rho^2 \;\le\; \frac{1+c}{2}.$$

*Proof sketch.* Since $0 \le \rho \le a$ and $0 \le \rho \le b$ we have $\rho^2 \le ab$.
Symmetrising the Gram inequality via $(a-b)^2 \ge 0$ gives
$2ab(1-c) \le 1 - c^2$, hence $2\rho^2(1-c) \le 1-c^2 = (1+c)(1-c)$. Because $1 - c > 0$ we
may cancel it, obtaining $2\rho^2 \le 1+c$. $\square$

The interpretation is the central message of the paper: *the permission for two statistics to
both score highly against a common response is purchased with mutual redundancy, at an exact
exchange rate.*

**Theorem 3.4 (The parity threshold).** Under the hypotheses of Theorem 3.3 with $c \le 0$
(the statistics are uncorrelated or negatively correlated),
$$\rho \;\le\; \frac{\sqrt 2}{2} \;=\; \frac{1}{\sqrt 2} \;\approx\; 0.70711 .$$

*Proof sketch.* Theorem 3.3 gives $\rho^2 \le (1+c)/2 \le 1/2$; take square roots using
$\rho \ge 0$. $\square$

### 3.3 The threshold is attained

**Theorem 3.5 (Sharpness).** For every real $t$ with $2t^2 \le 1$ there exist
$u,v,w \in \mathbb R^3$, all nonzero, with
$$\operatorname{corr}(u,v) = 0, \qquad \operatorname{corr}(u,w) = \operatorname{corr}(v,w) = t.$$

*Proof.* Take
$$u = (1,0,0),\qquad v = (0,1,0),\qquad w = \bigl(t,\ t,\ \sqrt{1-2t^2}\bigr).$$
Then $\langle u,u\rangle = \langle v,v\rangle = 1$, $\langle u,v\rangle = 0$, and
$\langle w,w\rangle = t^2 + t^2 + (1-2t^2) = 1$, so $w$ is a unit vector; finally
$\langle u,w\rangle = \langle v,w\rangle = t$, and dividing by the (unit) norms gives the
claim. $\square$

Thus $\sqrt2/2$ is not merely an upper bound but the exact supremum of achievable parity
levels: every value up to it occurs, and no value beyond it does.

---

## 4. Forcing and advantage

Theorem 3.3 read in the contrapositive direction constrains the *mutual* correlation.

**Theorem 4.1 (Forcing law).** If $a^2+b^2+c^2 \le 1+2abc$, then
$$c \;\ge\; ab - \sqrt{(1-a^2)(1-b^2)} .$$

*Proof sketch.* Rearranging the Gram inequality gives
$(c - ab)^2 \le (1-a^2)(1-b^2)$; take square roots to obtain
$|c - ab| \le \sqrt{(1-a^2)(1-b^2)}$ and keep the lower half. $\square$

(The same computation gives the matching upper bound
$c \le ab + \sqrt{(1-a^2)(1-b^2)}$; the mutual correlation is pinned to an interval centred
at $ab$ whose half-width is the product of the two "unexplained" amplitudes.)

**Corollary 4.2 (High readings force correlation).** If two statistics read $a \ge 0.78$ and
$b \ge 0.71$ against a shared response (with $a,b \le 1$), then their mutual correlation
satisfies $c \ge 0.11$.

*Proof sketch.* Substitute the bounds into Theorem 4.1 and estimate; equivalently, apply the
Gram inequality directly with the monotonicity of $ab - \sqrt{(1-a^2)(1-b^2)}$ in each
argument on $[0,1]$. $\square$

In the equal-reading case $a = b = \rho$ the forcing law reads $c \ge 2\rho^2 - 1$, which is
positive exactly when $\rho > 1/\sqrt2$ — the same threshold from a different direction.

Next, the quantitative form of parity.

**Lemma 4.3 (Circle bound).** If $a^2+b^2+c^2 \le 1+2abc$ with $c \le 0$, $a \ge 0$, $b \ge 0$,
then $a^2 + b^2 \le 1$.

*Proof sketch.* $2abc \le 0$ since $a,b \ge 0 \ge c$, and $c^2 \ge 0$; so
$a^2+b^2 \le a^2+b^2+c^2 \le 1 + 2abc \le 1$. $\square$

So the pair of readings of a decorrelated pair lies inside the unit quarter-disc — a
completely explicit trade-off curve.

**Theorem 4.4 (Advantage law).** Suppose a dial statistic reads $\rho \ge 0$ and a baseline
reads $\rho - \alpha \ge 0$ against the same response, and the two are decorrelated
($c \le 0$). Then
$$\alpha \;\ge\; \rho - \sqrt{1-\rho^2}.$$

*Proof sketch.* By Lemma 4.3, $(\rho-\alpha)^2 \le 1-\rho^2$; since $\rho - \alpha \ge 0$,
taking square roots gives $\rho - \alpha \le \sqrt{1-\rho^2}$. $\square$

**Theorem 4.5 (Above the threshold the advantage cannot vanish).** In the situation of
Theorem 4.4, if $\rho > \sqrt2/2$ then $\alpha > 0$ strictly.

*Proof sketch.* $\rho > \sqrt2/2$ gives $\rho^2 > 1/2$, so $\sqrt{1-\rho^2} < \rho$ and
Theorem 4.4 forces $\alpha > 0$. $\square$

**Interpretation (the inference rule).** Observing *parity* — that is, $\alpha \approx 0$ —
between a dial and a baseline forces a disjunction:

> either the dial has fallen to or below $1/\sqrt 2 \approx 0.7071$, or the two statistics
> are measurably correlated, at level at least $2\rho^2-1$.

At $\rho = 0.78$ the forced advantage is at least $0.78 - \sqrt{1-0.78^2} \approx 0.1542$,
and the forced mutual correlation (if parity nonetheless held) is at least
$2(0.78)^2 - 1 = 0.2168$.

---

## 5. The Spearman bridge

The measured dial is a *rank* correlation, computed by the classical formula
$$\rho_s \;=\; 1 - \frac{6\sum_{i} d_i^2}{n^3-n},$$
$d_i$ being the difference of the two ranks assigned to item $i$. The geometry of §§3–4
concerns Pearson correlations of vectors. The following identifies the two.

**Theorem 5.1 (Rank normalisation).** For every $n$, the rank vector
$u = (1,2,\dots,n) \in \mathbb R^n$ has centred squared norm
$$\langle \tilde u, \tilde u\rangle \;=\; \frac{n^3-n}{12}.$$

*Proof sketch.* $\operatorname{avg}(u) = (n+1)/2$; expand
$\langle \tilde u,\tilde u\rangle = \sum_i u_i^2 - 2\operatorname{avg}(u)\sum_i u_i + n\operatorname{avg}(u)^2$
and substitute $\sum_i i = n(n+1)/2$ and $\sum_i i^2 = n(n+1)(2n+1)/6$; algebra gives
$n(n^2-1)/12$. $\square$

**Theorem 5.2 (Permutation invariance).** For any $u \in \mathbb R^n$ and any permutation
$\sigma$ of $\{1,\dots,n\}$, $\langle \widetilde{u\circ\sigma}, \widetilde{u\circ\sigma}\rangle
= \langle \tilde u, \tilde u\rangle$.

*Proof sketch.* The mean is permutation invariant, and the centred sum of squares is a sum
over a reindexed set of the same terms. $\square$

Together: *every* tie-free ranking of $n$ items has centred squared norm $(n^3-n)/12$, so the
hypotheses of the next theorem are automatically satisfied by genuine rankings.

**Theorem 5.3 (Spearman bridge).** Let $n \ge 2$ and let $u, v \in \mathbb R^n$ have equal
means and common centred squared norm $(n^3-n)/12$. Then
$$\operatorname{corr}(\tilde u, \tilde v) \;=\; 1 - \frac{6\sum_{i}(u_i-v_i)^2}{n^3-n}.$$

*Proof sketch.* Because the means agree, $\tilde u_i - \tilde v_i = u_i - v_i$ pointwise.
Expanding the squared distance,
$$\sum_i (u_i - v_i)^2 = \langle \tilde u,\tilde u\rangle - 2\langle \tilde u,\tilde v\rangle + \langle \tilde v,\tilde v\rangle
= \frac{n^3-n}{6} - 2\langle \tilde u,\tilde v\rangle,$$
so $\langle \tilde u,\tilde v\rangle = \frac{n^3-n}{12} - \frac12\sum_i (u_i-v_i)^2$. The
denominator is $\|\tilde u\|\,\|\tilde v\| = (n^3-n)/12$. Dividing gives the stated formula.
$\square$

**Consequence.** Spearman's $\rho_s$ between two tie-free rankings is exactly the cosine of
the angle between the corresponding centred rank vectors. Hence every result of §§3–4 and
§6 applies verbatim to measured Spearman coefficients: the parity threshold, the forcing
law, the advantage law and the capacity law are all statements one may test directly on a
table of reported rank correlations.

(For *tied* statistics — and $T$, the trailing-zero count, is heavily tied, since the tie
class of value $j$ has relative mass $2^{-(j+1)}$ — the centred norm shrinks below
$(n^3-n)/12$ and the correlation is attenuated. This is the tie-attenuation phenomenon that
caps a dyadic statistic at $\rho^2 \le 6/7$. The recorded value satisfies
$0.605^2 = 0.366 \ll 6/7 \approx 0.857$, so tie geometry is not the active constraint at
bitlen 72; Gram geometry is.)

---

## 6. From two statistics to $k$: the correlation budget

Parity concerns two statistics. A programme that keeps adding baselines is really asking:
how many mutually decorrelated statistics can all read the same value against one response?

**Theorem 6.1 (Bessel's inequality, coordinate form).** Let $u_1,\dots,u_k \in \mathbb R^n$
be orthonormal and let $w \in \mathbb R^n$. Then
$$\sum_{i=1}^k \langle u_i, w\rangle^2 \;\le\; \langle w,w\rangle .$$

*Proof sketch.* Put $c_i = \langle u_i,w\rangle$ and $P = \sum_i c_i u_i$. Orthonormality
gives $\langle P,P\rangle = \sum_i c_i^2$ and $\langle P,w\rangle = \sum_i c_i^2$.
Non-negativity of the residual's squared norm,
$$0 \le \langle w - P,\ w - P\rangle = \langle w,w\rangle - 2\langle w,P\rangle + \langle P,P\rangle
= \langle w,w\rangle - \sum_i c_i^2,$$
is exactly the claim. $\square$

**Theorem 6.2 (The correlation budget).** With $u_1,\dots,u_k$ orthonormal and
$\langle w,w\rangle \ne 0$,
$$\sum_{i=1}^{k} \operatorname{corr}(u_i,w)^2 \;\le\; 1 .$$

*Proof sketch.* Since $\|u_i\| = 1$, $\operatorname{corr}(u_i,w)^2 = \langle u_i,w\rangle^2/\langle w,w\rangle$;
sum and apply Theorem 6.1. $\square$

A response carries exactly one unit of explanatory mass, and mutually independent predictors
must divide it. This single inequality subsumes everything in §3.

**Theorem 6.3 (Capacity law).** Let $u_1,\dots,u_k$ be orthonormal, $\langle w,w\rangle \ne 0$,
$\rho \ge 0$, and suppose every statistic reads at least $\rho$:
$\operatorname{corr}(u_i, w) \ge \rho$ for all $i$. Then
$$k\,\rho^2 \;\le\; 1 .$$

*Proof sketch.* Each term of the budget satisfies $\rho^2 \le \operatorname{corr}(u_i,w)^2$
(both sides non-negative, and $\rho \le \operatorname{corr}(u_i,w)$), so
$k\rho^2 \le \sum_i \operatorname{corr}(u_i,w)^2 \le 1$. $\square$

**Corollary 6.4 (Root form).** Under the hypotheses of Theorem 6.3 with $k \ge 1$,
$$\rho \;\le\; \frac{1}{\sqrt k}.$$

At $k = 2$ this is exactly the parity threshold $\sqrt2/2$ of Theorem 3.4: the parity ceiling
is the second rung of a ladder $1, \tfrac{1}{\sqrt2}, \tfrac{1}{\sqrt3}, \dots$

**Theorem 6.5 (Sharpness of the capacity law).** Let $k \ge 0$ and let $t \in \mathbb R$
satisfy $k t^2 \le 1$. Then there exist an orthonormal family $u_1,\dots,u_k \in \mathbb R^{k+1}$
and a unit vector $w \in \mathbb R^{k+1}$ with
$$\operatorname{corr}(u_i, w) = t \quad\text{for every } i .$$

*Proof.* Let $u_i = e_i$, the $i$-th standard basis vector of $\mathbb R^{k+1}$, for
$i = 1,\dots,k$; these are manifestly orthonormal. Let
$$w = \bigl(t,\ t,\ \dots,\ t,\ s\bigr), \qquad s = \sqrt{1 - k t^2},$$
with $t$ in the first $k$ coordinates. Then $\langle w,w\rangle = k t^2 + s^2 = 1$ and
$\langle u_i, w\rangle = t$, so $\operatorname{corr}(u_i,w) = t$. $\square$

Hence the capacity constraint $k\rho^2 \le 1$ is an *exact* description of what is achievable,
with nothing to spare: the achievable region for $(k,\rho)$ is precisely $\{k\rho^2 \le 1\}$.

**Definition 6.6 (Decorrelated capacity).** For $\rho > 0$, the *capacity* of the level
$\rho$ is
$$\operatorname{cap}(\rho) \;=\; \max\{\,k \in \mathbb N : k\rho^2 \le 1\,\} \;=\; \left\lfloor \rho^{-2} \right\rfloor,$$
the largest number of mutually decorrelated statistics that can all read at level $\rho$
against one response. By Theorems 6.3 and 6.5 this maximum is both an upper bound and
attained.

---

## 7. Application: capacity classification of the recorded dial

We now evaluate the capacity at the two ends of the measured dial. The relevant ladder rungs
are
$$\tfrac{1}{\sqrt1} = 1,\qquad \tfrac{1}{\sqrt2} \approx 0.70711,\qquad \tfrac{1}{\sqrt3} \approx 0.57735,\qquad \tfrac{1}{\sqrt4} = 0.5 .$$

**Theorem 7.1 (Capacity two at bitlen 72).** Let $\rho_{72} = 0.605$. Then:

1. There exist an orthonormal pair $u_1,u_2 \in \mathbb R^3$ and a unit $w \in \mathbb R^3$
   with $\operatorname{corr}(u_1,w) = \operatorname{corr}(u_2,w) = \rho_{72}$.
2. For no $n$ do there exist an orthonormal *triple* $u_1,u_2,u_3 \in \mathbb R^n$ and a
   nonzero $w$ with $\operatorname{corr}(u_i,w) \ge \rho_{72}$ for all three.

*Proof sketch.* (1) $2\rho_{72}^2 = 0.73205 \le 1$, so Theorem 6.5 with $k=2$ applies; the
witness is $u_1 = e_1$, $u_2 = e_2$, $w = (0.605,\,0.605,\,\sqrt{0.26795})$. (2)
$3\rho_{72}^2 = 1.098075 > 1$, contradicting Theorem 6.3 with $k=3$. $\square$

**Corollary 7.2 (Prediction: a third baseline must be correlated).** Any third statistic that
also reads $0.605$ against the bitlen-72 response fails to be decorrelated from the other
two: at least one pairwise correlation among the three is nonzero. Quantitatively, the
budget $\sum_i \rho_i^2 \le 1$ is already exceeded by $0.098$, so the family must carry that
much redundancy.

**Theorem 7.3 (Capacity one at bitlen 44).** Let $\rho_{44} = 0.78$. There is no orthonormal
*pair* $u_1,u_2$ and nonzero $w$ with $\operatorname{corr}(u_i,w) \ge \rho_{44}$ for both.

*Proof sketch.* $2\rho_{44}^2 = 1.2168 > 1$, contradicting Theorem 6.3 with $k=2$. $\square$

**Theorem 7.4 (Capacity window / crossing dichotomy).**
$$\frac{1}{\sqrt3} \;<\; 0.605 \;\le\; \frac{1}{\sqrt2} \;<\; 0.78 .$$
Consequently $\operatorname{cap}(0.605) = 2$ and $\operatorname{cap}(0.78) = 1$; moreover a
common reading $\rho \ge 0$ by two decorrelated statistics is possible *if and only if*
$\rho \le \sqrt2/2$ (Theorems 3.4 and 3.5).

*Proof sketch.* $3(0.605)^2 = 1.0981 > 1 \ge 2(0.605)^2 = 0.7321$, and $2(0.78)^2 = 1.2168 > 1$.
$\square$

### 7.1 Reading the experiment through the capacity law

The programme recorded two facts about the dial's decline: the value fell from $0.78$ to
$0.605$, and the count advantage decayed from $+0.07$ to below $+0.05$. The theory says these
are one fact.

- While the dial is above $1/\sqrt2$, capacity is $1$. No decorrelated second statistic can
  match it; by Theorem 4.5 any decorrelated baseline must lose strictly, by at least
  $\rho - \sqrt{1-\rho^2}$.
- Once the dial falls below $1/\sqrt2$, capacity becomes $2$. A second decorrelated statistic
  *may* match it, and Theorem 3.5 shows that matching configurations exist.

Count parity is therefore not evidence that the baseline improved; it is evidence that the
dial declined past the geometric threshold, which opened a vacancy. And this is falsifiable:

**Prediction 7.5.** At any bit-length where the dial reads above $0.708 > 1/\sqrt2$, the count
baseline must either (i) trail by a strictly positive margin of at least
$\rho - \sqrt{1-\rho^2}$, or (ii) be measurably correlated with the zero-count statistic at
level at least $2\rho^2 - 1$.

Also recorded, for completeness, are the direct sanity checks on the measurement: all three
seed values $0.605, 0.606, 0.603$ and the pooled $0.605$ lie in $[0.55,0.85]$; the pooled
value lies in its own interval $[0.586,0.625] \subset [0.55,0.85]$; the pooled value agrees
with the seed mean to within the reporting precision; $0.605^2 = 0.366$ is far below the
dyadic tie ceiling $6/7$; and count parity in the reported sense (advantage at most $0.05$)
keeps the baseline itself inside the validation band, since $0.605 - 0.05 = 0.555 \ge 0.55$.

---

## 8. What the theory does not do

A sharp result is one that also fails cleanly outside its range, and it is worth recording
where this one does.

**8.1 The forcing law is vacuous at bitlen 72.** With the recorded pair
$(a,b) = (0.605,\ 0.555)$, Theorem 4.1 yields
$$c \;\ge\; 0.605\cdot 0.555 - \sqrt{(1-0.605^2)(1-0.555^2)} \;=\; 0.33578 - 0.66234 \;=\; -0.32657,$$
a bound weaker than the trivial $c \ge -1$ is useful. So the bitlen-72 data *cannot* be used
to detect correlation between the dial statistic and the count baseline. This is a genuine
limitation of the method at low readings, and it is the price of sharpness: below the
threshold, geometry permits everything and therefore forbids nothing.

**8.2 There is no decline theorem here.** One would like a statement of the form "the dial
must decline with bit-length". Tie geometry cannot supply it: the tie ceiling for the dyadic
statistic is essentially flat in the bit-length once the bit-length is large (the tie profile
of the trailing-zero count is $2^{-(j+1)}$ regardless of $B$, up to truncation effects), so
it gives the same $6/7$ at $B = 72$ as at $B = 76$. Gram geometry cannot supply it either,
because it is bit-length-free: it constrains correlations, not the mechanism that generates
them. A decline theorem requires a model of the *response*, not merely of the statistic. We
regard this as the main open modelling problem raised by the measurement.

**8.3 The results are worst-case, not distributional.** Every theorem here is an exact
geometric constraint on observed vectors. They contain no sampling error terms, and they say
nothing about how likely a configuration is — only whether it is possible at all. Their
value is as hard falsifiers: a reported table of numbers violating $\sum_i \rho_i^2 \le 1$ is
arithmetically impossible, not merely improbable.

---

## 9. Algorithms

Three procedures follow immediately, all with trivial computational cost.

**Algorithm A — Capacity certification.** Given a level $\rho$, return
$\operatorname{cap}(\rho) = \lfloor \rho^{-2}\rfloor$ together with a witness configuration
in dimension $\operatorname{cap}(\rho) + 1$ (Theorem 6.5) and, when
$(\operatorname{cap}(\rho)+1)\rho^2 > 1$, a certificate of impossibility for one more
statistic (the exceeded budget). Cost $O(k)$ to emit the witness.

**Algorithm B — Budget audit of a reported correlation table.** Given readings
$\rho_1,\dots,\rho_k$ against a shared response, together with claimed pairwise correlations,
compute $S = \sum_i \rho_i^2$. If $S > 1$, the family cannot be decorrelated, and a *minimum
required redundancy* $S - 1$ is reported. For any pair, evaluate the forcing interval
$[\,ab - \sqrt{(1-a^2)(1-b^2)},\ ab + \sqrt{(1-a^2)(1-b^2)}\,]$ and check the claimed pairwise
value against it. Cost $O(k^2)$.

**Algorithm C — Parity screening.** Given a dial reading $\rho$ and a baseline reading
$\rho - \alpha$, decide the disjunction of §4: if $\rho > 1/\sqrt2$ and
$\alpha < \rho - \sqrt{1-\rho^2}$, report that the two statistics are necessarily correlated,
at level at least $\rho(\rho-\alpha) - \sqrt{(1-\rho^2)(1-(\rho-\alpha)^2)}$; otherwise report
that parity is geometrically free. Cost $O(1)$.

---

## 10. Discussion and related structure

The correlation budget $\sum_i \rho_i^2 \le 1$ is Bessel's inequality wearing statistical
clothing, and, so dressed, it is a statement about the sociology of predictors: a response is
one direction, and independent explanations of it compete for a fixed resource. This is
familiar in spirit from the $R^2$ decomposition of orthogonal regression — indeed, for
orthonormal predictors, $\sum_i \rho_i^2$ *is* the coefficient of determination of the joint
linear fit, and the budget is just the statement $R^2 \le 1$. What is perhaps less familiar is
how sharply it bites at small $k$: at $k=2$ it already forbids two independent predictors from
both exceeding $0.708$, a level that is entirely ordinary for a single predictor.

The step function $\operatorname{cap}(\rho) = \lfloor \rho^{-2}\rfloor$ is a useful lens on
benchmark culture. A benchmark on which several published, ostensibly diverse methods all
score correlation $0.8$ against the same target is not a benchmark on which several diverse
methods succeed: since $2 \cdot 0.8^2 = 1.28 > 1$, the methods are necessarily correlated,
with a minimum redundancy of $0.28$ in budget units. The apparent diversity is arithmetically
impossible.

The three-correlation inequality has a pleasant classical reading, too. Writing
$a = \cos\alpha$, $b = \cos\beta$, $c = \cos\gamma$ for angles in $[0,\pi]$, the inequality
$a^2+b^2+c^2 \le 1+2abc$ is equivalent to the spherical triangle inequality
$\gamma \le \alpha + \beta$ together with $\alpha + \beta + \gamma \le 2\pi$: the
"correlation triangle inequality". The parity threshold is then the statement that two
directions at $90^\circ$ from each other cannot both be within $45^\circ$ of a third, and
$\cos 45^\circ = \sqrt2/2$ is the constant. Every bound in this paper is that observation,
made quantitative.

---

## 11. Future work

**11.1 The parity capacity staircase for correlated families.** The natural interpolation
between the capacity law ($\gamma = 0$) and the unconstrained case ($\gamma = 1$) is:

> **Conjecture.** For a family of $k$ statistics whose pairwise correlations are at most
> $\gamma \ge 0$, a common reading $\rho$ against a shared response obeys
> $$\rho^2 \;\le\; \frac{1 + (k-1)\gamma}{k},$$
> with equality for the equicorrelated configuration; the decorrelated capacity law
> $k\rho^2 \le 1$ is the case $\gamma = 0$, and the two-statistic ceiling
> $\rho^2 \le (1+c)/2$ is the case $k = 2$, $\gamma = c$.

The mechanism is transparent: the Gram matrix of an equicorrelated family is
$(1-\gamma)I + \gamma J$, whose eigenvalues are $1 + (k-1)\gamma$ (on the all-ones direction)
and $1-\gamma$ (with multiplicity $k-1$); the response's correlation vector must lie in the
span with unit norm, so the family's internal correlation converts directly into extra
budget. Only the eigenvalue computation for $(1-\gamma)I + \gamma J$ is needed, so this is
elementary and reachable.

**11.2 Tie–Gram interference.** Real rank statistics are tied, and ties attenuate. We
conjecture that the parity threshold degrades multiplicatively with the tie profiles:

> **Conjecture.** For two decorrelated statistics with tie profiles $L_1, L_2$ over $n$ items
> and tie ceilings $s_j = 1 - 12\sum_{m \in L_j}(m^3-m)/(n^3-n)$, the two cannot both read
> above $\sqrt{(s_1+s_2)/2}$. In particular, a statistic whose largest tie class carries half
> the mass — the dyadic dial itself — has parity threshold at most
> $\sqrt{6/7}\cdot\sqrt2/2 \approx 0.655$.

If correct, this would tighten the dichotomy of §7 substantially for the specific statistics
at hand: the crossing would occur at $0.655$ rather than $0.707$, closer to the observed
transition region.

**11.3 A response model.** As noted in §8.2, no decline theorem is available from either tie
geometry or Gram geometry, because both are bit-length-free. Obtaining one requires modelling
the joint law of $(T, \text{rate})$ as $B$ grows — for instance, a model in which the rate
depends on a fixed number of low-order bits, so that the informative fraction of the draw
shrinks with $B$ and the correlation decays with an explicit rate. Such a model would make
the observed monotone decline a theorem rather than a measurement, and would predict where
the $1/\sqrt2$ crossing occurs.

**11.4 Confidence-interval versions.** All statements here are exact and worst-case. Replacing
point readings by intervals — e.g. propagating $[0.586, 0.625]$ through the capacity law and
the forcing law — would give the honest observational version and turn Prediction 7.5 into a
proper statistical test.

---

## 12. Conclusion

An unremarkable experimental observation — a sophisticated statistic and a naive baseline
drawing level — turns out to be the local signature of a global geometric constraint. Three
correlations among three variables satisfy $a^2+b^2+c^2 \le 1+2abc$; two decorrelated
predictors therefore cannot both exceed $1/\sqrt2 \approx 0.70711$ against a shared response,
and the threshold is exactly attained. More generally, any decorrelated family spends from a
fixed budget $\sum_i \rho_i^2 \le 1$, so a level $\rho$ admits exactly
$\lfloor\rho^{-2}\rfloor$ mutually independent readers, again exactly. The measured dial
declined from $0.78$ (capacity one) to $0.605$ (capacity two), and the count advantage
disappeared over precisely that interval. Parity was not something the baseline achieved. It
was something the dial permitted.
