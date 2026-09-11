# The Rung Budget for Plateau Identification

**Exact identifiability of limits from a measured prefix of a decelerating sequence, a closed-form measurement budget, and the noise floor that caps it**

*Aristotle*

---

## Abstract

Let $s_0 \ge s_1 \ge s_2 \ge \cdots$ be a nonincreasing real sequence — a *fade* —
whose successive decrements $d_n = s_n - s_{n+1}$ satisfy a certified
*deceleration bound* $d_{n+1} \le r\,d_n$ for a fixed ratio $r \in [0,1)$. Such a
sequence converges; its limit $L$ is its *plateau*. We ask what a finite measured
prefix $p_0, \dots, p_{m+1}$ of *rungs* determines about $L$.

We prove that the set of plateaus consistent with the prefix is *exactly* the
closed interval $[\,p_{m+1} - r d_m/(1-r),\ p_{m+1}\,]$, where $d_m = p_m - p_{m+1}$
is the last measured step; both endpoints are attained, and the entire measured
history apart from the last step is irrelevant. The interval width $\Lambda_m =
r d_m /(1-r)$ obeys $\Lambda_{m+1} \le r \Lambda_m$ in general, with equality on
the extremal geometric ladder $d_n = d_0 r^n$, where $\Lambda_m = d_0
r^{m+1}/(1-r)$; the contraction can be strictly faster, and one further rung can
collapse the interval to a point. This yields a closed-form stopping rule: $m$
further rungs identify the plateau to within $\varepsilon$ if and only if
$m \ge \lceil \log(\varepsilon(1-r)/d_0)/\log r\rceil - 1$.

We establish the complementary branch of the dichotomy: under the trivial
certificate $r = 1$ the admissible set is the whole half-line $(-\infty, p_{m+1}]$
for every prefix length, so no ladder identifies the plateau. We show the
admissible set is monotone in the certificate ($r \le r'$ implies containment) and
that certifying a lower ratio $r_{\min}$ in addition to $r_{\max}$ yields the exact
two-sided interval of width $d_m(r_{\max}-r_{\min})/((1-r_{\max})(1-r_{\min}))$.
Finally we prove a *noise floor*: if rung values are known only to within $\eta$,
the admissible plateau set contains two points at distance $2\eta$ for every
prefix length, so the rung budget saturates.

Applied to a reference ladder with $d_0 = 0.0259$, $r = 1/2$, and target precision
equal to the reported confidence-interval half-width $\varepsilon = 0.0445$, the
budget evaluates to **zero** further rungs, refuting a prior estimate of three;
the first informative target $\varepsilon = 0.001$ costs exactly five further
rungs; and since the rung uncertainty is itself $\eta = 0.0445$, the noise floor
$2\eta = 0.089$ exceeds the one-rung interval $0.0259$, so that ladder is
noise-limited rather than rung-limited.

**Keywords:** decelerating sequence, plateau identification, geometric contraction,
identifiability interval, measurement budget, noise floor, extremal ladder.

---

## 1. Introduction

### 1.1 The problem

Many empirical curves are monotone and self-damping: each increment is smaller
than the last, and the curve visibly heads for an asymptote. Learning curves,
scaling curves, relaxation curves, iterative-refinement gains, annealing
schedules — in each case the quantity of interest is the asymptote, and the
asymptote is precisely the thing no finite measurement can reveal.

The engineering response is a *ladder*: measure rung after rung until the curve
"looks flat". The mathematical question hidden in that practice is quantitative
and, as far as we are aware, is usually left unasked:

> Given the rungs already measured and a certified bound on how fast the
> increments decay, what is the exact set of asymptotes still consistent with the
> data, and how does that set shrink per additional rung?

The purpose of this paper is to answer that question exactly, to convert the
answer into a costed experimental plan, and to identify the two obstructions that
cap the plan: a weak certificate, and measurement noise.

### 1.2 Contributions

1. **Exact identifiability from an $m$-rung prefix** (Theorem 3.1). The admissible
   plateau set is exactly $[\,p_{m+1} - r d_m/(1-r),\ p_{m+1}\,]$. Only the last
   measured step matters; both endpoints are attained.
2. **The contraction law** (Theorems 4.1–4.3). Per extra rung the interval
   contracts by a factor at most $r$; the factor is exactly $r$ on the extremal
   geometric ladder; and the bound is not an equality in general — a single rung
   can collapse the interval to a point.
3. **A closed-form rung budget** (Theorem 5.1): $m$ rungs suffice for target
   $\varepsilon$ iff $m \ge \lceil \log(\varepsilon(1-r)/d_0)/\log r\rceil - 1$.
4. **The dichotomy** (Theorem 6.1). With $r = 1$ the admissible set is
   $(-\infty, p_{m+1}]$ for every prefix: identification is impossible at any
   ladder length. Together with (3): plateau identification is either explicitly
   cheap or provably impossible.
5. **Monotonicity in the certificate** (Theorems 7.1–7.2). Sharpening $r$ shrinks
   the admissible set monotonically, and since $r/(1-r) \to \infty$ as $r \to 1$,
   certificate quality dominates ladder length in the weak-certificate regime.
6. **Two-sided identification** (Theorems 8.1–8.3). Certifying a lower ratio
   $r_{\min}$ turns the one-sided interval into a strictly shorter two-sided one
   of width $d_m(r_{\max}-r_{\min})/((1-r_{\max})(1-r_{\min}))$; the per-rung
   contraction factor is then itself only bracketed by $[r_{\min}, r_{\max}]$.
7. **The noise floor** (Theorems 9.1–9.2). Under rung uncertainty $\eta$, the
   admissible set has diameter at least $2\eta$ for every prefix length; the
   budget saturates.
8. **The reference-ladder instantiation** (Section 10). Budget zero at the
   confidence-interval scale, five rungs at $\varepsilon = 0.001$, and a noise
   floor that dominates both.

---

## 2. Definitions

Throughout, sequences are indexed by $\mathbb{N} = \{0,1,2,\dots\}$ and take real
values.

**Definition 2.1 (Decrements).** For $s : \mathbb{N} \to \mathbb{R}$ write
$d_n(s) = s_n - s_{n+1}$ for the $n$-th *step*, or *decrement*.

**Definition 2.2 (Admissible fade).** Let $r \in \mathbb{R}$. A sequence $s$ is an
*$r$-admissible fade* if

$$\text{(i)}\quad s_{n+1} \le s_n \ \ \text{for all } n, \qquad
\text{(ii)}\quad s_{n+1} - s_{n+2} \le r\,(s_n - s_{n+1}) \ \ \text{for all } n .$$

Equivalently: $s$ is nonincreasing and its decrements satisfy $d_{n+1} \le r\,d_n$.
Condition (i) is *antitonicity*; condition (ii) is the *deceleration certificate*.

**Definition 2.3 (Measured prefix and admissible prefix).** A *measured prefix of
length $m+2$* is the tuple of values $p_0, p_1, \dots, p_{m+1}$ of a function
$p : \mathbb{N} \to \mathbb{R}$ at indices $0, \dots, m+1$. It is *$r$-admissible*
if

$$p_{k+1} \le p_k \ \ (0 \le k \le m), \qquad
p_{k+1} - p_{k+2} \le r\,(p_k - p_{k+1}) \ \ (k + 2 \le m+1) .$$

These are exactly the constraints of Definition 2.2 that involve only measured
indices. Write $d_m = p_m - p_{m+1}$ for the *last measured step*; $r$-admissibility
gives $d_m \ge 0$.

**Definition 2.4 (Plateau set).** For $r \in \mathbb{R}$, $p : \mathbb{N} \to
\mathbb{R}$ and $M \in \mathbb{N}$, the *plateau set*

$$\mathcal{P}_r(p, M) \ = \ \big\{\, L \in \mathbb{R} \ :\ \exists\, s \text{ an
} r\text{-admissible fade with } s_k = p_k \text{ for all } k \le M
\text{ and } s_n \to L \,\big\}$$

is the set of limits of admissible fades agreeing with the measurement on the
first $M+1$ rungs. Its elements are the *admissible plateaus*.

**Definition 2.5 (Interval width).** For $r < 1$ set

$$\Lambda_m(r,p) \ = \ \frac{r\,(p_m - p_{m+1})}{1-r} \ = \ \frac{r\,d_m}{1-r} .$$

**Definition 2.6 (Extremal / geometric ladder).** For $s_0, d_0, r \in \mathbb{R}$
the *geometric ladder* is
$$G_n \ = \ s_0 - d_0\,\frac{1 - r^{\,n}}{1-r}, \qquad\text{so}\qquad
G_n - G_{n+1} \ = \ d_0 r^{\,n} .$$
It is $r$-admissible for $0 \le r < 1$, $d_0 \ge 0$, and it saturates (ii) with
equality at every step; this is why we call it extremal.

**Definition 2.7 (Rung budget).** For $d_0 > 0$, $r \in (0,1)$ and $\varepsilon > 0$,
$$B(d_0, r, \varepsilon) \ = \ \Big\lceil \frac{\log\big(\varepsilon(1-r)/d_0\big)}{\log r} \Big\rceil - 1 \ \in \mathbb{Z}.$$

---

## 3. The splicing construction and exact identifiability

All attainability statements in this paper rest on a single construction.

**Definition 3.1 (Spliced fade).** Given a tail ratio $q$, a target $L$, a data
function $p$ and a splice index $M$, define
$$\sigma^{q,L,p,M}_n \ = \
\begin{cases}
p_n, & n \le M,\\[2pt]
L + (p_M - L)\,q^{\,n-M}, & n > M .
\end{cases}$$

The spliced fade reproduces the data exactly up to index $M$ and then decays
geometrically at ratio $q$ from $p_M$ towards $L$.

**Lemma 3.2 (Convergence of the splice).** If $0 \le q < 1$ then
$\sigma^{q,L,p,M}_n \to L$.

*Proof sketch.* For $n \ge M$ the value is $L + (p_M - L)q^{\,n-M}$ and
$q^{\,n-M} \to 0$. $\square$

**Lemma 3.3 (Admissibility of the splice).** Let $0 \le q < 1$, $q \le r$, let
$p_0,\dots,p_{m+1}$ be an $r$-admissible prefix, put $M = m+1$ and $D = p_{M} - L$.
If
$$D \ \ge \ 0 \qquad\text{and}\qquad D\,(1-q) \ \le \ r\,d_m ,$$
then $\sigma^{q,L,p,M}$ is an $r$-admissible fade.

*Proof sketch.* Three regimes.
*Inside the prefix* ($n+2 \le M$): both conditions of Definition 2.2 are exactly
the prefix hypotheses.
*At the junction* ($n = m$, so $n+1 = M$): the step from $s_M$ to $s_{M+1}$ is
$D(1-q)$, which is nonnegative by $D \ge 0$, $q < 1$; the deceleration inequality
at $n = m$ reads $D(1-q) \le r\,d_m$, which is the second hypothesis.
*Inside the tail* ($n \ge M$): consecutive steps are $D q^{\,j}(1-q)$ and
$D q^{\,j+1}(1-q)$, whose ratio is $q \le r$; nonnegativity follows from
$D \ge 0$, $q \ge 0$. $\square$

We can now state and prove the central result.

**Theorem 3.1 (Exact identifiability from a measured prefix).** Let
$0 \le r < 1$ and let $p_0, \dots, p_{m+1}$ be an $r$-admissible prefix with last
step $d_m = p_m - p_{m+1}$. Then
$$\boxed{\ \mathcal{P}_r(p,\, m+1) \ = \ \Big[\, p_{m+1} - \frac{r\,d_m}{1-r},\ \ p_{m+1} \,\Big] .\ }$$
In particular the set of admissible plateaus is a nonempty closed interval of
length exactly $\Lambda_m(r,p) = r d_m/(1-r)$, and both endpoints are attained.

*Proof sketch.*

**($\subseteq$) Upper endpoint.** If $s$ is an admissible fade agreeing with the
prefix, then $s$ is nonincreasing, so for all $n \ge m+1$ we have $s_n \le s_{m+1}
= p_{m+1}$; passing to the limit, $L \le p_{m+1}$.

**($\subseteq$) Lower endpoint.** Iterating the deceleration certificate gives
$d_{m+1+j}(s) \le r^{\,j} d_{m+1}(s)$, whence for every $k$
$$s_{m+1} - s_{m+1+k} \ = \ \sum_{j=0}^{k-1} d_{m+1+j}(s)
\ \le \ d_{m+1}(s)\,\frac{1 - r^{\,k}}{1-r} \ \le \ \frac{d_{m+1}(s)}{1-r} .$$
Letting $k \to \infty$: $s_{m+1} - L \le d_{m+1}(s)/(1-r)$. The certificate applied
at index $m$, together with $s_m = p_m$, $s_{m+1} = p_{m+1}$, gives
$d_{m+1}(s) \le r\,d_m$. Hence $p_{m+1} - L \le r d_m/(1-r)$.

**($\supseteq$) Attainability.** Let $L$ lie in the interval, and set
$D = p_{m+1} - L \ge 0$. The lower constraint $D \le r d_m/(1-r)$ is equivalent to
$D(1-r) \le r d_m$, which is precisely the junction hypothesis of Lemma 3.3 with
$q = r$. By Lemmas 3.2 and 3.3, $\sigma^{r,L,p,m+1}$ is an $r$-admissible fade
agreeing with the prefix and converging to $L$, so $L \in \mathcal{P}_r(p, m+1)$.
$\square$

**Remark 3.4 (Only the last step matters).** The interval depends on the prefix
only through $p_{m+1}$ and $d_m$. All earlier readings constrain nothing beyond
certifying that the prefix is admissible. This is the practically important
structural fact: *the informational value of a ladder is concentrated entirely in
its final step.*

**Remark 3.5 (Asymmetry).** The upper endpoint of the admissible interval is the
last measured value itself, attained by the fade that stops dead
($q = 0$). Further rungs can never improve the upper bound on the plateau below
the readings themselves; they only raise the lower bound. Section 8 shows that a
lower deceleration certificate is exactly what is needed to break this asymmetry.

---

## 4. The contraction law

**Theorem 4.1 (Width on the extremal ladder).** For the geometric ladder $G$ of
Definition 2.6 with $r < 1$,
$$\Lambda_m(r, G) \ = \ \frac{d_0\, r^{\,m+1}}{1-r} .$$

*Proof sketch.* $G_m - G_{m+1} = d_0 r^{\,m}$; substitute into Definition 2.5.
$\square$

**Theorem 4.2 (Exact per-rung contraction on the extremal ladder).** For $r < 1$
and every $m$,
$$\Lambda_{m+1}(r, G) \ = \ r\,\Lambda_m(r, G).$$

*Proof sketch.* Immediate from Theorem 4.1: the ratio of consecutive widths is
$r^{\,m+2}/r^{\,m+1} = r$. $\square$

Theorem 4.2 confirms the conjecture that motivated this work — *each additional
measured rung contracts the admissible interval by exactly the factor $r$* — on
the worst-case ladder. On general ladders the conjecture holds only as an
inequality, and the failure is always in the experimenter's favour.

**Theorem 4.3 (General contraction bound).** Let $0 \le r < 1$ and suppose the
deceleration certificate holds at index $m$, i.e. $p_{m+1} - p_{m+2} \le
r\,(p_m - p_{m+1})$. Then
$$\Lambda_{m+1}(r,p) \ \le \ r\,\Lambda_m(r,p) .$$

*Proof sketch.* $\Lambda_{m+1} = r(p_{m+1}-p_{m+2})/(1-r) \le r\big(r(p_m -
p_{m+1})\big)/(1-r) = r\Lambda_m$, using $r \ge 0$ and $1 - r > 0$. $\square$

**Theorem 4.4 (The factor $r$ is not exact in general).** For every $r \in (0,1)$
and $d_0 > 0$ there is an $r$-admissible prefix $p_0, p_1, p_2$ with
$$\Lambda_1(r,p) = 0 \qquad\text{and}\qquad r\,\Lambda_0(r,p) > 0 .$$
Thus a single additional rung can collapse the admissible plateau interval to a
point, a contraction strictly faster than the factor $r$.

*Proof sketch.* Take $p_0 = d_0$, $p_1 = p_2 = 0$. The prefix is nonincreasing;
the single deceleration constraint reads $p_1 - p_2 = 0 \le r\,d_0$, true. Then
$\Lambda_0 = r d_0/(1-r) > 0$ while $\Lambda_1 = r\cdot 0/(1-r) = 0$. $\square$

**Interpretation.** The factor $r$ per rung is a *worst-case guarantee*, realised
exactly by the extremal geometric ladder and beaten by any ladder that decays
faster than certified. Consequently the budget of Section 5, computed on the
extremal ladder, is an upper bound on the true cost for every admissible ladder
with the same $d_0$ and $r$: no experiment governed by these hypotheses ever needs
more rungs than the budget says.

---

## 5. The rung budget

**Theorem 5.1 (Closed-form stopping rule).** Let $d_0 > 0$, $r \in (0,1)$,
$\varepsilon > 0$ and $m \in \mathbb{N}$. Then
$$\frac{d_0\,r^{\,m+1}}{1-r} \ \le \ \varepsilon
\qquad\Longleftrightarrow\qquad
m \ \ge \ B(d_0,r,\varepsilon) \ = \ \Big\lceil \frac{\log\big(\varepsilon(1-r)/d_0\big)}{\log r} \Big\rceil - 1 .$$

*Proof sketch.* Put $K = \varepsilon(1-r)/d_0 > 0$. Since $1 - r > 0$ and $d_0 > 0$,
the left inequality is equivalent to $r^{\,m+1} \le K$. Both sides are positive,
so we may take logarithms: $(m+1)\log r \le \log K$. As $r \in (0,1)$ we have
$\log r < 0$, and dividing flips the inequality:
$\log K / \log r \le m+1$. Since $m+1$ is an integer, this is equivalent to
$\lceil \log K/\log r\rceil \le m+1$, i.e. to $B \le m$. $\square$

Combining with Theorem 4.3: for any $r$-admissible ladder whose initial step is
$d_0$, measuring $B(d_0,r,\varepsilon)$ further rungs *guarantees* identification of
the plateau to within $\varepsilon$; and on the extremal ladder no smaller number
does.

**Corollary 5.2 (Monotone comparative statics).** $B$ increases as $\varepsilon$
decreases, as $d_0$ increases, and as $r$ increases towards $1$. The dependence on
precision is logarithmic — an extra decimal digit costs $\log 10/\log(1/r)$ rungs,
about $3.32$ rungs at $r = 1/2$ — while the dependence on the certificate is
singular, since the prefactor $r/(1-r)$ diverges as $r \to 1$.

---

## 6. The impossible branch

The certificate $r < 1$ is not a technical convenience; without it, no amount of
measurement identifies anything.

**Theorem 6.1 (No certificate, no identification).** Let $p_0, \dots, p_{m+1}$ be
a nonincreasing prefix whose decrements are nonincreasing (the case $r = 1$ of
Definition 2.3), with last step $d_m = p_m - p_{m+1} > 0$. Then
$$\mathcal{P}_1(p,\, m+1) \ = \ (-\infty,\ p_{m+1}] .$$

*Proof sketch.* The inclusion $\subseteq$ is antitonicity as in Theorem 3.1. For
$\supseteq$, fix $L \le p_{m+1}$ and let $D = p_{m+1} - L \ge 0$. If $D = 0$, splice
the constant tail ($q = 0$). If $D > 0$, choose the tail ratio
$$q \ = \ 1 - c, \qquad c \ = \ \min\Big\{\,1,\ \frac{d_m}{D}\,\Big\} \in (0,1] ,$$
so that $q \in [0,1)$ and $D(1-q) = Dc \le d_m = 1 \cdot d_m$, which is exactly the
junction condition of Lemma 3.3 with $r = 1$. The spliced fade is
$1$-admissible, agrees with the prefix and converges to $L$. $\square$

The construction makes the mechanism transparent: a tail with ratio $q$ close to
$1$ decays arbitrarily slowly, and its total remaining travel $D = d_{M}/(1-q)$ is
unbounded as $q \to 1$. The deceleration certificate $r < 1$ is precisely a
bound on that travel.

**Corollary 6.2 (The dichotomy).** For a ladder with certified ratio $r$ and
initial step $d_0 > 0$, and any target $\varepsilon > 0$:
* if $r < 1$, the plateau is identified to within $\varepsilon$ after
  $\max\{0, B(d_0,r,\varepsilon)\}$ further rungs — a finite, explicitly computable
  cost;
* if $r = 1$, the plateau is not identified to within any finite $\varepsilon$ after
  any number of rungs.

Plateau identification is therefore *either cheap or impossible*: there is no
regime in which it is expensive but feasible for want of data alone.

---

## 7. Monotonicity in the certificate

**Theorem 7.1 (Monotonicity of the admissible set).** If $r \le r'$ then every
$r$-admissible fade is $r'$-admissible, and consequently
$$\mathcal{P}_r(p, M) \ \subseteq \ \mathcal{P}_{r'}(p, M) \qquad \text{for all } p, M .$$

*Proof sketch.* Let $s$ be $r$-admissible. Antitonicity is unchanged. For the
certificate, $d_{n+1} \le r\,d_n \le r'\,d_n$, using $d_n \ge 0$, which is
antitonicity. Membership in the plateau set then transfers verbatim, since the
witnessing fade and its limit are unchanged. $\square$

**Theorem 7.2 (Monotonicity of the width).** If $r \le r' < 1$ and $d_m \ge 0$ then
$$\frac{r\,d_m}{1-r} \ \le \ \frac{r'\,d_m}{1-r'} .$$

*Proof sketch.* Cross-multiplying by the positive quantities $1-r$ and $1-r'$
reduces the claim to $r d_m (1-r') \le r' d_m (1-r)$, i.e.
$d_m (r - r') \le 0$, which holds. $\square$

**Discussion.** The map $r \mapsto r/(1-r)$ is increasing and unbounded on $[0,1)$:
$$r = 0.5 \mapsto 1, \quad 0.8 \mapsto 4, \quad 0.9 \mapsto 9, \quad
0.98 \mapsto 49, \quad 0.99 \mapsto 99 .$$
Since a rung buys a factor $r$ and a certificate improvement from $r'$ to $r$ buys
a factor $\frac{r(1-r')}{r'(1-r)}$, the *exchange rate* between certificate
quality and ladder length is
$$\#\text{rungs saved} \ = \ \frac{\log\big(r(1-r')\big) - \log\big(r'(1-r)\big)}{\log r} .$$
Near $r' \to 1$ this diverges: in the weak-certificate regime, tightening the
deceleration bound is worth an unbounded number of rungs. Halving the certificate
from $r' = 0.98$ to $r = 0.49$ shrinks the width by a factor of $\approx 50$,
which at $r = 0.98$ would require about $194$ additional rungs to achieve by
measurement alone.

---

## 8. Two-sided certificates

The one-sided interval of Theorem 3.1 is anchored above at the last measured
value: further rungs move only its lower edge (Remark 3.5). Certifying that the
fade does not *stop* — a lower bound on the deceleration ratio — breaks this
anchoring.

**Definition 8.1 (Two-sided fade).** For $r_{\min} \le r_{\max}$, a sequence $s$ is
a *$[r_{\min},r_{\max}]$-fade* if it is nonincreasing and
$$r_{\min}\,(s_n - s_{n+1}) \ \le\ s_{n+1} - s_{n+2} \ \le\ r_{\max}\,(s_n - s_{n+1})
\qquad\text{for all } n .$$
The corresponding *two-sided plateau set* $\mathcal{Q}_{r_{\min},r_{\max}}(p,M)$ is
defined as in Definition 2.4 with two-sided fades as witnesses.

The lower certificate yields a reverse tail bound, dual to the one used in
Theorem 3.1.

**Lemma 8.2 (Reverse tail bound).** Let $s$ be a $[r_{\min},r_{\max}]$-fade with
$0 \le r_{\min} < 1$ and $s_n \to L$. Then for every $n$,
$$\frac{s_n - s_{n+1}}{1 - r_{\min}} \ \le \ s_n - L .$$

*Proof sketch.* By induction, $r_{\min}^{\,k}(s_n - s_{n+1}) \le s_{n+k} -
s_{n+k+1}$; summing over $k < K$ gives $(s_n - s_{n+1})\sum_{j<K} r_{\min}^{\,j}
\le s_n - s_{n+K}$. Let $K \to \infty$; the left side tends to $(s_n -
s_{n+1})/(1-r_{\min})$ and the right side to $s_n - L$. $\square$

**Theorem 8.1 (Exact two-sided identifiability).** Let
$0 \le r_{\min} \le r_{\max} < 1$ and let $p_0,\dots,p_{m+1}$ be a prefix that is
nonincreasing and satisfies both certificates at all measured indices. Then
$$\mathcal{Q}_{r_{\min},r_{\max}}(p,\, m+1) \ = \
\Big[\, p_{m+1} - \frac{r_{\max} d_m}{1-r_{\max}}\ ,\ \
        p_{m+1} - \frac{r_{\min} d_m}{1-r_{\min}} \,\Big].$$

*Proof sketch.* A two-sided fade is in particular $r_{\max}$-admissible, so
Theorem 3.1 supplies the left endpoint and the containment
$L \le p_{m+1}$. For the improved right endpoint, apply Lemma 8.2 at $n = m+1$ and
then the lower certificate at index $m$:
$$p_{m+1} - L \ \ge\ \frac{p_{m+1} - s_{m+2}}{1-r_{\min}} \ \ge\
\frac{r_{\min} d_m}{1-r_{\min}} .$$
For attainability, given $L$ in the interval put $D = p_{m+1} - L$ and take the
spliced fade with tail ratio
$$q \ = \ \frac{D}{D + d_m} \in [r_{\min}, r_{\max}] ,$$
(the membership is exactly the two endpoint inequalities rearranged, with
degenerate cases $D = 0$ and $d_m = 0$ handled separately by $q = r_{\min}$). This
choice makes the junction step $D(1-q) = d_m q$ satisfy both certificates at the
junction, and the geometric tail of ratio $q$ satisfies them at every later index.
$\square$

**Theorem 8.2 (Two-sided width).** Under the hypotheses of Theorem 8.1 the width
of the admissible interval is
$$W_m \ = \ \frac{d_m\,(r_{\max}-r_{\min})}{(1-r_{\max})(1-r_{\min})} ,$$
and if $r_{\min} > 0$ and $d_m > 0$ then $W_m$ is *strictly* smaller than the
one-sided width $r_{\max} d_m/(1-r_{\max})$.

*Proof sketch.* The width is the difference of the two endpoints; clearing
denominators gives the stated expression. For the comparison, cross-multiplying
reduces the strict inequality to $r_{\min} d_m (1 - r_{\max}) > 0$ after
cancellation. $\square$

**Theorem 8.3 (The two-sided contraction factor is only bracketed).** If the
certificates hold at index $m$, then
$$r_{\min}\, W_m \ \le \ W_{m+1} \ \le \ r_{\max}\, W_m ,$$
and both extremes are realised, by the geometric ladders of ratio $r_{\min}$ and
$r_{\max}$ respectively.

*Proof sketch.* $W_{m+1}$ is $W_m$ with $d_m$ replaced by $d_{m+1}$ and the same
positive constant $(r_{\max}-r_{\min})/((1-r_{\max})(1-r_{\min}))$; the two
certificates at index $m$ bracket $d_{m+1}$ between $r_{\min}d_m$ and
$r_{\max}d_m$. $\square$

**Discussion.** Two-sided information is never wasted (Theorem 8.2), but it costs
predictability: with a one-sided certificate the worst-case per-rung contraction
is exactly $r_{\max}$, whereas with a two-sided certificate the contraction factor
is itself known only up to the certified ratio window (Theorem 8.3). The budget of
Section 5 must then be computed with $r_{\max}$, the pessimistic end.

---

## 9. The noise floor

All of the above assumes that measured rung values are exact. They never are.

**Definition 9.1 (Noisy plateau set).** For $\eta \ge 0$,
$$\mathcal{P}^{\eta}_r(p, M) = \big\{\, L : \exists\, s \text{ an }r\text{-admissible
fade with } |s_k - p_k| \le \eta \text{ for all } k \le M \text{ and } s_n \to L \,\big\} .$$

**Theorem 9.1 (Noise floor).** Let $r \ge 0$, $\eta \ge 0$ and let
$p_0, \dots, p_{m+1}$ be an $r$-admissible prefix. Then
$$p_{m+1} + \eta \ \in \ \mathcal{P}^{\eta}_r(p,\, m+1)
\qquad\text{and}\qquad
p_{m+1} - \eta \ \in \ \mathcal{P}^{\eta}_r(p,\, m+1) .$$

*Proof sketch.* Consider the rigidly shifted data $p_k \pm \eta$. A rigid shift
changes no decrement, so the shifted prefix is $r$-admissible whenever the
original one is, and it lies within $\eta$ of the measurements at every index.
Splice a constant tail (ratio $q = 0$) onto it: the junction step is $0 \le r d_m$,
so the spliced sequence is an $r$-admissible fade, it stays within $\eta$ of every
measured value, and it converges to the shifted last value $p_{m+1} \pm \eta$.
$\square$

**Theorem 9.2 (The budget saturates).** Under the hypotheses of Theorem 9.1, for
every prefix length the noisy admissible plateau set contains two points at
distance exactly $2\eta$. Hence
$$\operatorname{diam} \mathcal{P}^{\eta}_r(p,\, m+1) \ \ge \ 2\eta \qquad\text{for all } m .$$

*Proof sketch.* Take the two points supplied by Theorem 9.1; their difference is
$(p_{m+1}+\eta) - (p_{m+1}-\eta) = 2\eta$. $\square$

**Corollary 9.3 (Effective stopping rule).** Rungs are informative only while the
exact-data width exceeds the noise floor. Measuring beyond the index $m^\ast$ at
which
$$\frac{d_0\,r^{\,m+1}}{1-r} \ \approx\ 2\eta$$
cannot reduce the admissible interval, so the operative budget is
$$B_{\mathrm{eff}}(d_0, r, \varepsilon, \eta) \ = \
\begin{cases}
\max\{0,\ B(d_0,r,\varepsilon)\}, & \varepsilon > 2\eta,\\[3pt]
\text{unattainable}, & \varepsilon \le 2\eta .
\end{cases}$$

The dichotomy of Corollary 6.2 thus acquires a third branch: a target finer than
the noise floor is unreachable not because the ladder is too short but because the
instrument is too coarse. The remedy is precision or a sharper certificate, never
length.

---

## 10. The reference ladder

We instantiate the theory at a concrete reading. The ladder has initial measured
step
$$d_0 = 0.0259,$$
certified deceleration ratio
$$r = 1/2,$$
and reported value $0.488$ with confidence interval $[0.445,\ 0.534]$, whose
half-width is
$$\varepsilon \ = \ \tfrac12\,(0.534 - 0.445) \ = \ 0.0445 .$$

**(a) The budget is zero.** With $r = 1/2$ the prefactor $r/(1-r)$ equals $1$, so
the one-rung width is
$$\Lambda_0 \ = \ \frac{d_0 \cdot 0.5}{0.5} \ = \ 0.0259 \ <\ 0.0445 \ = \ \varepsilon .$$
Equivalently, by Theorem 5.1,
$$B(0.0259,\ 1/2,\ 0.0445)
= \Big\lceil \tfrac{\log(445/518)}{\log(1/2)} \Big\rceil - 1
= \lceil 0.2192 \rceil - 1 = 1 - 1 = 0 ,$$
using $0.0445 \times 0.5 / 0.0259 = 445/518 \approx 0.8591 \in (1/2, 1)$, so the
log-ratio lies in $(0,1]$ and its ceiling is $1$.

**This refutes the working estimate of three further rungs.** At the
confidence-interval scale the plateau is already identified by the data in hand;
the marginal value of the next rung is zero.

**(b) A genuinely costed target.** For $\varepsilon = 0.001$, an order of magnitude
below the confidence interval, the width after $m$ further rungs is
$0.0259 \cdot 2^{-m}$, so
$$m = 4:\ 0.001619 > 0.001, \qquad m = 5:\ 0.000809 \le 0.001 .$$
Exactly **five** further rungs are required — four are not enough. The budget
formula agrees: $\lceil \log(0.001 \times 0.5/0.0259)/\log(1/2)\rceil - 1 =
\lceil 5.694\rceil - 1 = 5$.

**(c) The floor dominates.** The uncertainty attached to each rung reading is
itself the confidence-interval half-width, $\eta = 0.0445$. By Theorem 9.2 the
admissible plateau set always has diameter at least
$$2\eta \ = \ 0.089 ,$$
which exceeds the one-rung exact-data width $0.0259$ by a factor of more than
three. This ladder is therefore **noise-limited, not rung-limited**: the five-rung
plan of (b) is unbuyable at present precision, and no number of further rungs can
reduce the admissible interval below $0.089$.

**(d) What a two-sided certificate would buy.** If the experiment also certified
$r_{\min} = 2/5$, Theorem 8.2 gives the exact-data width
$$\frac{0.0259 \times (1/2 - 2/5)}{(1 - 1/2)(1 - 2/5)}
\ = \ \frac{0.0259 \times 0.1}{0.5 \times 0.6}
\ = \ \frac{0.0259}{3} \ \approx \ 0.00863 ,$$
a threefold improvement over $0.0259$ with no further rung — but still, of course,
underneath the noise floor $0.089$, and hence not yet realisable.

**The operational conclusion.** For this ladder the ordered priority list is:
(1) reduce the per-rung measurement uncertainty $\eta$; (2) sharpen the
deceleration certificate, ideally to a two-sided window; (3) only then, if the
target still exceeds the floor, spend the $B(d_0,r,\varepsilon)$ rungs that the
budget prescribes. Extending the ladder at present precision is provably
worthless.

---

## 11. Algorithms

The theory is fully constructive; three short routines implement it.

**Algorithm A (Admissible-interval computation).** Input: a measured prefix
$p_0,\dots,p_{m+1}$, ratio $r \in [0,1)$. Output: the interval
$[p_{m+1} - r d_m/(1-r),\ p_{m+1}]$ and a validity flag. Verify antitonicity and
the deceleration certificate at all measured indices ($O(m)$ comparisons), then
evaluate the closed form ($O(1)$).

**Algorithm B (Rung budget).** Input: $d_0 > 0$, $r \in (0,1)$, $\varepsilon > 0$,
optional noise level $\eta$. Output: the number of further rungs, or the verdict
"unattainable". Compute $\lceil \log(\varepsilon(1-r)/d_0)/\log r\rceil - 1$, clamp
below at $0$, and return "unattainable" if $\varepsilon \le 2\eta$. $O(1)$
arithmetic; the only numerical caution is the ceiling, which should be computed
with an exactness guard when $\log(\varepsilon(1-r)/d_0)/\log r$ is near an integer,
or, better, by direct integer search on $r^{\,m+1} \le \varepsilon(1-r)/d_0$ in
exact rational arithmetic when $r$ and $\varepsilon$ are rational.

**Algorithm C (Witness synthesis).** Input: an admissible prefix, a ratio $r$, and
a target plateau $L$ in the admissible interval. Output: an explicit admissible
fade realising $L$. Set $D = p_{m+1} - L$, choose $q = r$ (or, for the two-sided
problem, $q = D/(D+d_m)$), and return the spliced sequence of Definition 3.1. The
certificate is checked in $O(m)$; evaluation of any term is $O(1)$. Algorithm C is
the practical content of the attainability half of Theorems 3.1 and 8.1: every
point of the interval comes with a concrete counterexample-ladder, so no sharper
inference from the data is possible.

---

## 12. Applications

**Learning and scaling curves.** A benchmark metric measured at a geometric
sequence of model or dataset sizes typically satisfies an empirical deceleration
bound. The theory converts "has the curve saturated?" into an interval
$[p_{m+1} - r d_m/(1-r),\ p_{m+1}]$ computable from the last two points and the
certificate, and prices the next training run.

**Relaxation and convergence diagnostics.** For a monotone iterative solver with a
certified contraction factor $r$, the same interval bounds the unreachable exact
solution value; the budget prices "how many more iterations before I can claim the
limit to tolerance $\varepsilon$", and Theorem 4.3 guarantees the answer is
conservative.

**Experimental design under a fixed instrument.** Corollary 9.3 is a design rule:
compute $2\eta$ before scheduling any measurement campaign. If the target lies
below the floor, the campaign is provably futile in its current form, and the
budget should be redirected to instrument precision.

**Certificate elicitation.** Section 7 quantifies the exchange rate between
certificate quality and measurement count. In domains where a deceleration bound
can be argued theoretically (contraction mappings, damped physical relaxations,
diminishing-returns models), that argument may be worth more than the entire
experimental programme.

---

## 13. Discussion

Three structural facts organise everything above.

*Sufficiency of the last step.* The admissible interval depends on the ladder only
through $(p_{m+1}, d_m)$. The ladder is not a sample to be averaged; it is a
sequence of certificates each of which supersedes its predecessor. This is why
"only the last step matters" and why the interval's upper endpoint is exactly the
last reading.

*Worst-case exactness.* The conjectured contraction factor $r$ per rung is exactly
right on the extremal ladder and an upper bound elsewhere (Theorems 4.2–4.4). The
budget is therefore *sound* (it never underestimates) and *tight* (it is achieved).
A ladder that beats the budget is one whose true decay is faster than certified —
which is information you could have certified instead.

*Two hard ceilings.* Identification fails absolutely under a trivial certificate
(Theorem 6.1), and saturates absolutely under measurement noise (Theorem 9.2).
Both failures are invisible to the naive practice of "measure until it looks
flat", and both are diagnosed by a one-line computation.

A methodological remark: the negative results here — the refuted three-rung
estimate, the noise floor, the non-universality of the contraction factor — were
more informative than the positive ones. Each arose from insisting on *exact* sets
of admissible plateaus rather than one-sided bounds. Once the plateau set is
computed exactly, the question "does another rung help?" has a yes/no answer, and
at the reference ladder that answer is no.

---

## 14. Future directions

1. **Non-monotone and noisy-monotone fades.** Real curves wobble. Replacing
   antitonicity by "antitone up to $\eta$" is partly covered by Definition 9.1, but
   the exact admissible set in that setting — presumably a $2\eta$-thickening of
   the exact interval — deserves a sharp statement.
2. **Stochastic certificates.** Replace the deterministic bound $d_{n+1} \le r d_n$
   by $\mathbb{E}[d_{n+1} \mid \mathcal{F}_n] \le r d_n$ and ask for the resulting
   credible interval for the plateau. The supermartingale structure suggests an
   analogue of Theorem 3.1 with $r d_m/(1-r)$ replaced by a concentration
   bound.
3. **Vector-valued and multi-metric ladders.** When several metrics fade together
   with a shared certificate, does the joint admissible region factor into a
   product of intervals, or can cross-metric constraints shrink it?
4. **Optimal rung placement.** We assumed rungs are measured consecutively. If the
   experimenter may choose *which* indices to measure, and the certificate applies
   between consecutive measured indices with ratio $r^{\Delta}$, what schedule
   minimises total cost for a target $\varepsilon$ under a per-measurement cost
   model?
5. **Adaptive certificate refinement.** Measured steps themselves furnish evidence
   about $r$. A procedure that alternates between tightening the empirical ratio
   certificate and spending rungs, with the exchange rate of Section 7 as its
   objective, is the natural sequential-design counterpart of the static budget.
6. **Lower-bound certificates in practice.** Section 8 shows that $r_{\min} > 0$ is
   valuable. Identifying domains where a lower deceleration bound can be certified
   — physical relaxation with a known slowest mode, algorithms with a known
   convergence-rate lower bound — would make two-sided identification routine.

---

## 15. Summary of results

| Result | Statement |
|---|---|
| Exact identifiability | $\mathcal{P}_r(p,m+1) = [\,p_{m+1} - r d_m/(1-r),\ p_{m+1}\,]$ |
| Width | $\Lambda_m = r d_m/(1-r)$; depends only on the last step |
| Extremal ladder | $\Lambda_m = d_0 r^{m+1}/(1-r)$, with $\Lambda_{m+1} = r\Lambda_m$ |
| General contraction | $\Lambda_{m+1} \le r\Lambda_m$; can be strictly faster, even to $0$ |
| Budget | $m$ rungs suffice iff $m \ge \lceil\log(\varepsilon(1-r)/d_0)/\log r\rceil - 1$ |
| Impossible branch | $r = 1$, $d_m > 0$ $\Rightarrow$ $\mathcal{P}_1(p,m+1) = (-\infty, p_{m+1}]$ |
| Certificate monotonicity | $r \le r' \Rightarrow \mathcal{P}_r \subseteq \mathcal{P}_{r'}$ and $\Lambda(r) \le \Lambda(r')$ |
| Two-sided interval | $[\,p_{m+1} - \tfrac{r_{\max}d_m}{1-r_{\max}},\ p_{m+1} - \tfrac{r_{\min}d_m}{1-r_{\min}}\,]$ |
| Two-sided width | $d_m(r_{\max}-r_{\min})/((1-r_{\max})(1-r_{\min}))$, strictly shorter if $r_{\min}>0$ |
| Noise floor | diameter $\ge 2\eta$ for every prefix length |
| Reference ladder | budget $0$ at $\varepsilon = 0.0445$; $5$ rungs at $\varepsilon = 0.001$; floor $0.089$ dominates |
