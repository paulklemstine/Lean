# Equal-Volume Shell Peelings of Euclidean Balls: Monotonicity, the Optimal Concentration Constant, and the Exponential Profile

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

Let $B(0,R) \subseteq \mathbb{R}^d$ be the Euclidean ball of radius $R$ and let
$N \ge 2$. The *equal-volume peeling* of $B(0,R)$ into $N$ shells is the nested
family of spheres of radii $r_k = R(1 - k/N)^{1/d}$, $0 \le k \le N$, which
divides the ball into $N$ regions of identical volume. We develop a complete
quantitative theory of this decomposition.

We first prove the two-sided estimate
$\frac{R}{dN} \le R - r_1 \le \frac{R}{d(N-1)}$ for the thickness of the
outermost shell, showing that the elementary upper bound is tight up to the
factor $1 - 1/N$ and that the lower bound is attained exactly at $d = 1$. We
then prove the central structural result: for every $t \in (0,1]$, the sequence
$d \mapsto d\,(1 - t^{1/d})$ is monotone increasing. The proof is elementary and
combinatorial — it reduces, via the substitution $y = t^{1/(ab)}$, to the fact
that the Cesàro averages of the geometric sequence $(y^i)_{i \ge 0}$ are
decreasing. Geometrically, the rescaled thickness $d\,(R - r_1)$ increases with
the dimension.

Monotonicity, combined with the limit $d\,(R - r_1) \to R\Lambda$ where
$\Lambda = \log\frac{N}{N-1}$, upgrades the asymptotic statement into a bound
valid in every dimension: $R - r_1 \le R\Lambda/d$, with $\Lambda$ *optimal* —
the bound $R - r_1 \le Rc/d$ holds for all $d$ if and only if $c \ge \Lambda$.
Since $\log x < x-1$ for $x \ne 1$, this strictly improves the elementary
estimate $R/(d(N-1))$ in every dimension. We supplement the limit with the
explicit rate $0 \le R\Lambda - d(R - r_1) \le R\Lambda^2/(d+\Lambda)$.

Finally we identify the shape of the entire decomposition. Introducing the
rescaled depth $\tau_k = -\log(1 - k/N)/d$, we show the depth profile is
*exactly* exponential, $R - r_k = R(1 - e^{-\tau_k})$, that
$d\,(R - r_k) \to R\log\frac{N}{N-k}$, and that the limiting depth and volume
fraction are related by $1 - e^{-\tau} = k/N$; dually, removing a boundary layer
of thickness $Ru/d$ removes a volume fraction tending to $1 - e^{-u}$. We
conclude with a concentration dichotomy — the outermost shell collapses to the
boundary sphere while the innermost shell, of the same volume, swells to the
whole ball — and with a reverse payoff: the geometry re-derives the classical
logarithmic sandwich $\frac{1}{N} \le \log\frac{N}{N-1} \le \frac{1}{N-1}$.

**Keywords.** Concentration of measure, high-dimensional geometry, Euclidean
ball, equal-volume peeling, boundary layer, optimal constant, exponential
profile, Cesàro averages.

---

## 1. Introduction

### 1.1 The phenomenon

That "almost all the volume of a high-dimensional ball lies near its boundary"
is a staple of introductory accounts of the curse of dimensionality. In its
usual form the observation is: the ball of radius $(1-\varepsilon)R$ in
$\mathbb{R}^d$ occupies a fraction $(1-\varepsilon)^d$ of the volume of the ball
of radius $R$, and $(1-\varepsilon)^d \to 0$ exponentially fast for fixed
$\varepsilon > 0$. Stated this way the phenomenon is qualitative and depends on
an arbitrary $\varepsilon$.

A cleaner formulation asks for the *inverse* function: rather than fixing a
thickness and computing the volume, fix a volume fraction and compute the
thickness. This leads to the object of the present paper.

**Definition 1.1 (Equal-volume peeling).** *Let $d \ge 1$, $R \ge 0$, and
$N \ge 2$. The equal-volume peeling of the ball $B(0,R) \subseteq \mathbb{R}^d$
into $N$ shells is the family of concentric spheres of radii*
$$r_k \;=\; r_k(R,d,N) \;=\; R\left(1 - \frac{k}{N}\right)^{1/d},
\qquad k = 0,1,\dots,N,$$
*together with the $N$ regions*
$$S_k \;=\; \{x : r_k \le \|x\| < r_{k-1}\}, \qquad k = 1,\dots,N,$$
*(with $S_N = B(0,r_{N-1})$ the innermost solid ball). We write*
$$\delta_k \;=\; R - r_k$$
*for the depth of the $k$-th sphere below the surface; $\delta_1$ is the
thickness of the outermost shell $S_1$.*

The definition is justified by the homogeneity of Lebesgue measure: writing
$\omega_d$ for the volume of the unit ball, $\operatorname{vol} B(0,r) =
\omega_d r^d$, so
$$\operatorname{vol} S_k = \omega_d\left(r_{k-1}^d - r_k^d\right)
= \omega_d R^d\left(\left(1-\tfrac{k-1}{N}\right) - \left(1-\tfrac{k}{N}\right)\right)
= \frac{\omega_d R^d}{N} = \frac{\operatorname{vol} B(0,R)}{N},$$
for every $k$. Each of the $N$ regions carries exactly $1/N$ of the volume; the
radii $r_k$ are the unique radii with this property. Note that only the
homogeneity $\operatorname{vol}(tK) = t^d \operatorname{vol}(K)$ was used, a
point we return to in §8.

### 1.2 The questions

The single formula $\delta_1 = R\bigl(1 - (1-1/N)^{1/d}\bigr)$ contains the
whole phenomenon, but in an opaque form. We ask:

1. **How thin is the outer shell?** Sharp two-sided bounds, valid for all $d$.
2. **How does the rescaled thickness behave in $d$?** Is $d\,\delta_1$ monotone?
3. **What is the optimal constant** $c$ in a uniform bound
   $\delta_1 \le Rc/d$?
4. **At what rate** does $d\,\delta_1$ approach its limit?
5. **What is the limiting shape** of the whole family $(\delta_k)_{k<N}$?

Sections 3–7 answer each in turn. The answers are, respectively: $\delta_1 \in
[R/(dN),\,R/(d(N-1))]$; yes, $d\,\delta_1$ is monotone increasing;
$c = \log\frac{N}{N-1}$ and no smaller value works; the gap is at most
$R\Lambda^2/(d+\Lambda)$; and the shape is the exponential profile
$R(1-e^{-\tau})$, *exactly* and not merely in the limit.

### 1.3 Notation

Throughout, $d \ge 1$ is the dimension, $N \ge 2$ the number of shells, $R \ge 0$
the radius, and
$$\Lambda \;=\; \Lambda(N) \;=\; \log\frac{N}{N-1} \;=\; -\log\left(1 - \tfrac1N\right).$$
We repeatedly abbreviate $t = 1 - 1/N \in (0,1)$ and $s = t^{1/d}$, so that
$\delta_1 = R(1-s)$ and $s^d = t$. All logarithms are natural. We write
$\operatorname{vol}$ for Lebesgue measure on $\mathbb{R}^d$ and $\omega_d$ for
the volume of the unit ball. Every result below holds for all $d \ge 1$ and
$N \ge 2$ unless stated otherwise.

---

## 2. The analytic core: two elementary inequalities

Everything in the paper rests on the factorisation of $1 - s^d$ and on the
exponential inequality $1 + u \le e^u$. We isolate the two consequences we need.

**Lemma 2.1 (Upper geometric bound).** *For $d \ge 0$ and $0 \le s \le 1$,*
$$1 - s^d \;\le\; d\,(1-s).$$

*Proof.* From $1 - s^d = (1-s)\sum_{i<d} s^i$ and $s^i \le 1$ for each
$i < d$ we get $\sum_{i<d} s^i \le d$; multiply by $1 - s \ge 0$. $\square$

**Lemma 2.2 (Lower geometric bound).** *For $d \ge 1$ and $0 \le s \le 1$,*
$$1 - s^d \;\ge\; d\,s^{d-1}(1-s).$$

*Proof.* Same factorisation, now bounding each term $s^i \ge s^{d-1}$ for
$i < d$. $\square$

The two lemmas are exact mirrors: the geometric sum $1 + s + \cdots + s^{d-1}$
has $d$ terms lying between $s^{d-1}$ and $1$, and the two lemmas take the two
extreme estimates. Rewritten in terms of $d$-th roots they become the following
normalised forms, which is how they will be used.

**Lemma 2.3 (Normalised lower estimate).** *For $0 \le t \le 1$ and $d \ge 1$,*
$$\frac{1-t}{d} \;\le\; 1 - t^{1/d},$$
*with equality at $d = 1$.*

*Proof.* Apply Lemma 2.1 with $s = t^{1/d} \in [0,1]$, so that $s^d = t$:
$1 - t \le d(1 - t^{1/d})$. $\square$

**Lemma 2.4 (Normalised upper estimate).** *For $0 < t \le 1$ and $d \ge 1$,*
$$1 - t^{1/d} \;\le\; \frac{1-t}{d\,t}.$$

*Proof.* Apply Lemma 2.2 with $s = t^{1/d}$. Since $0 \le s \le 1$ we have
$s^{d-1} \ge s^d = t$, so $1 - t \ge d\,s^{d-1}(1-s) \ge d\,t\,(1-s)$, and divide
by $dt > 0$. $\square$

---

## 3. The two-sided thickness bound

We can now read off the basic estimate. Note first the explicit form of the
outermost sphere: $r_1 = R\,(1 - 1/N)^{1/d}$ (this is Definition 1.1 with
$k = 1$; since $N \ge 2$ we have $1 - 1/N \ge 0$, so no truncation is needed).

**Theorem 3.1 (Two-sided thickness bound).** *For $d \ge 1$, $N \ge 2$,
$R \ge 0$,*
$$\frac{R}{dN} \;\le\; \delta_1 \;=\; R - r_1 \;\le\; \frac{R}{d(N-1)}.$$

*Proof.* Put $t = 1 - 1/N$, so $1 - t = 1/N$ and
$\delta_1 = R\,(1 - t^{1/d})$.

*Lower bound.* Lemma 2.3 gives $1 - t^{1/d} \ge (1-t)/d = 1/(dN)$; multiply by
$R \ge 0$.

*Upper bound.* Lemma 2.4 gives
$$1 - t^{1/d} \;\le\; \frac{1-t}{d\,t} = \frac{1/N}{d\,(1 - 1/N)}
= \frac{1}{d(N-1)};$$
multiply by $R$. $\square$

The lower bound is often more useful in the equivalent form
$$\frac{R}{d(N-1)}\left(1 - \frac1N\right) \;\le\; \delta_1,$$
which exhibits it as the upper bound diminished by the factor $1 - 1/N$; the two
expressions agree since $\frac{1}{d(N-1)}\cdot\frac{N-1}{N} = \frac{1}{dN}$.

**Corollary 3.2 (Relative error of the upper bound).** *Under the hypotheses of
Theorem 3.1,*
$$\frac{R}{d(N-1)} - \delta_1 \;\le\; \frac{R}{d(N-1)}\cdot\frac{1}{N}.$$
*Thus the elementary upper bound overshoots by at most a $1/N$ fraction of
itself, uniformly in $d$ and $R$; in particular it is asymptotically exact as
$N \to \infty$.*

*Proof.* Immediate from the lower bound of Theorem 3.1. $\square$

**Proposition 3.3 (Exactness in dimension one).** *For $N \ge 2$ and any $R$,*
$$R - r_1(R,1,N) \;=\; \frac{R}{N}.$$
*Hence the lower bound of Theorem 3.1 is attained at $d = 1$ and no constant
factor can be removed from it.*

*Proof.* At $d = 1$, $r_1 = R(1 - 1/N)$, so $R - r_1 = R/N$. $\square$

The picture emerging is that the true thickness sits inside a window
$[R/(dN),\,R/(d(N-1))]$ of multiplicative width $N/(N-1)$, with the lower
endpoint attained at $d = 1$. Where in the window does it sit for larger $d$?
The next section answers this completely.

---

## 4. Monotonicity in the dimension

The key structural fact is that the rescaled thickness moves monotonically
across the window of Theorem 3.1 as the dimension grows. We prove it by a
combinatorial argument that avoids differentiation entirely.

### 4.1 Cesàro averages of a geometric sequence

**Lemma 4.1 (Averaging lemma).** *Let $0 \le y \le 1$ and let $a \le b$ be
natural numbers. Then*
$$a \sum_{i<b} y^i \;\le\; b \sum_{i<a} y^i.$$
*Equivalently, the Cesàro averages $\frac1n\sum_{i<n} y^i$ of the antitone
sequence $(y^i)_{i\ge0}$ are non-increasing in $n$.*

*Proof.* Split the longer sum at $a$:
$$\sum_{i<b} y^i \;=\; \sum_{i<a} y^i \;+\; \sum_{a \le i < b} y^i.$$
Since $0 \le y \le 1$ the sequence $(y^i)$ is non-increasing, so:

* *the tail is small:* each of the $b - a$ terms with $i \ge a$ satisfies
  $y^i \le y^a$, whence $\sum_{a\le i<b} y^i \le (b-a)\,y^a$;
* *the head is large:* each of the $a$ terms with $i < a$ satisfies
  $y^i \ge y^a$, whence $\sum_{i<a} y^i \ge a\,y^a$.

Write $H = \sum_{i<a} y^i$. Then
$$a\sum_{i<b} y^i \;\le\; a H + a(b-a)y^a
\;\le\; aH + (b-a)H \;=\; bH,$$
where the second inequality uses $a\,y^a \le H$ and $b - a \ge 0$. $\square$

**Lemma 4.2 (Power form).** *Let $0 \le y \le 1$ and $a \le b$ natural numbers.
Then*
$$a\left(1 - y^b\right) \;\le\; b\left(1 - y^a\right).$$

*Proof.* Multiply Lemma 4.1 by $1 - y \ge 0$ and use the geometric
factorisation $(1-y)\sum_{i<n} y^i = 1 - y^n$ on both sides. $\square$

Lemma 4.2 already contains the monotonicity, in disguise: it says that
$n \mapsto \frac{1-y^n}{n}$ is non-increasing. Passing from integer exponents to
integer *roots* is now a matter of one substitution.

### 4.2 The monotonicity theorem

**Theorem 4.3 (Monotonicity of the rescaled deficit).** *Let $0 < t \le 1$. The
sequence*
$$d \;\longmapsto\; \Phi_t(d) := d\left(1 - t^{1/d}\right), \qquad d \in \mathbb{N},$$
*is monotone increasing.*

*Proof.* Let $a \le b$. If $a = 0$ the claim is $0 \le \Phi_t(b)$, which holds
because $t^{1/b} \le 1$ for $t \le 1$. So assume $1 \le a \le b$ and set
$$y \;=\; t^{1/(ab)} \;\in\; (0,1].$$
Then
$$y^b = t^{b/(ab)} = t^{1/a}, \qquad y^a = t^{a/(ab)} = t^{1/b}.$$
Substituting these two identities into Lemma 4.2 gives exactly
$$a\left(1 - t^{1/a}\right) \;\le\; b\left(1 - t^{1/b}\right),$$
i.e. $\Phi_t(a) \le \Phi_t(b)$. $\square$

The substitution $y = t^{1/(ab)}$ is the whole idea: it converts a statement
about fractional powers with two different denominators into a statement about
integer powers of a single base, where the combinatorial argument of Lemma 4.1
applies. The common refinement $1/(ab)$ plays the role of a common denominator.

**Theorem 4.4 (Geometric monotonicity).** *For $N \ge 2$ and $R \ge 0$ the
rescaled outer-shell thickness*
$$d \;\longmapsto\; d\left(R - r_1(R,d,N)\right)$$
*is monotone increasing in the dimension $d$.*

*Proof.* With $t = 1 - 1/N \in (0,1)$ we have
$d\,(R - r_1) = R\,\Phi_t(d)$ by Definition 1.1, and $R \ge 0$; apply
Theorem 4.3. $\square$

Combining Theorem 4.4 with Proposition 3.3, the family
$d \mapsto d\,\delta_1/R$ starts at the value $1/N$ — the lower endpoint of the
window of Theorem 3.1 — and increases from there. Its supremum is computed next.

---

## 5. The limit, the optimal constant, and the rate

### 5.1 The limit

**Theorem 5.1 (Fundamental limit).** *For $0 < x \le 1$,*
$$\lim_{d\to\infty} d\left(1 - x^{1/d}\right) \;=\; -\log x.$$

*Proof.* Write $L = \log x \le 0$ and $x^{1/d} = e^{L/d}$. We squeeze.

*Upper.* By $1 + u \le e^u$ at $u = L/d$ we get
$1 - e^{L/d} \le -L/d$, hence $d(1 - e^{L/d}) \le -L$ for every $d \ge 1$.

*Lower.* By $1 + u \le e^u$ at $u = -L/d$ we get
$1 - L/d \le e^{-L/d}$; since $L \le 0$ the left side is positive, so
$e^{L/d} \le \frac{1}{1 - L/d}$ and therefore
$$d\left(1 - e^{L/d}\right) \;\ge\; d\left(1 - \frac{1}{1 - L/d}\right)
\;=\; -L\cdot\frac{d}{d - L}.$$

As $d \to \infty$, $-L\cdot\frac{d}{d-L} \to -L$, and the upper bound is the
constant $-L$; the squeeze theorem finishes the proof. $\square$

**Theorem 5.2 (Asymptotics of the outer shell).** *For $N \ge 2$ and any $R$,*
$$\lim_{d\to\infty} d\left(R - r_1\right) \;=\; R\,\Lambda,
\qquad \Lambda = \log\frac{N}{N-1}.$$

*Proof.* Apply Theorem 5.1 with $x = t = 1 - 1/N = \frac{N-1}{N}$, noting
$-\log t = \log\frac{N}{N-1} = \Lambda$, and multiply by the constant $R$. $\square$

### 5.2 The optimal constant

Monotone plus convergent means the limit is the supremum; this converts the
asymptotic Theorem 5.2 into a bound valid in *every* dimension.

**Theorem 5.3 (Optimal concentration bound).** *For all $d \ge 1$, $N \ge 2$,
$R \ge 0$,*
$$R - r_1 \;\le\; \frac{R\,\Lambda}{d}, \qquad \Lambda = \log\frac{N}{N-1}.$$

*Proof.* By Theorem 4.4 the sequence $d \mapsto d\,(R - r_1)$ is monotone
increasing, and by Theorem 5.2 it converges to $R\Lambda$. A monotone increasing
convergent sequence is bounded above by its limit, so
$d\,(R - r_1) \le R\Lambda$ for every $d$; divide by $d > 0$. (For $d = 0$ the
statement is vacuous in the sense that $r_1 = R$ and both sides are handled
directly.) $\square$

**Theorem 5.4 (Optimality).** *Let $N \ge 2$, $R > 0$, and $c \in \mathbb{R}$.
Then*
$$\Bigl(\forall d \ge 1:\; R - r_1(R,d,N) \le \frac{Rc}{d}\Bigr)
\iff c \;\ge\; \Lambda = \log\frac{N}{N-1}.$$

*Proof.* ($\Leftarrow$) Immediate from Theorem 5.3 and $R > 0$.

($\Rightarrow$) The hypothesis says $d\,(R - r_1) \le Rc$ for every $d \ge 1$.
Letting $d \to \infty$ and using Theorem 5.2, $R\Lambda \le Rc$; divide by
$R > 0$. $\square$

Thus $\Lambda$ is not merely *a* constant but *the* constant: the bound of
Theorem 5.3 is unimprovable within the class of uniform-in-dimension estimates
of order $1/d$, and it is attained only in the limit $d \to \infty$.

**Theorem 5.5 (Strict improvement over the elementary bound).** *For $d \ge 1$,
$N \ge 2$, $R > 0$,*
$$\frac{R\,\Lambda}{d} \;<\; \frac{R}{d(N-1)}.$$

*Proof.* The strict inequality $\log x < x - 1$ holds for every $x > 0$ with
$x \ne 1$. Apply it at $x = \frac{N}{N-1} \ne 1$ (as $N \ge 2$ makes
$\frac{N}{N-1} > 1$): then
$$\Lambda = \log\frac{N}{N-1} \;<\; \frac{N}{N-1} - 1 \;=\; \frac{1}{N-1}.$$
Multiply by $R/d > 0$. $\square$

So the new bound beats the elementary one of Theorem 3.1 not asymptotically but
strictly, for every triple $(d,N,R)$ with $R > 0$. Table 1 quantifies this.

| $N$ | elementary constant $\frac1{N-1}$ | optimal constant $\Lambda = \log\frac{N}{N-1}$ | $d=1$ value $\frac1N$ | improvement |
|---|---|---|---|---|
| $2$ | $1.000000$ | $0.693147$ | $0.500000$ | $30.7\%$ |
| $3$ | $0.500000$ | $0.405465$ | $0.333333$ | $18.9\%$ |
| $5$ | $0.250000$ | $0.223144$ | $0.200000$ | $10.7\%$ |
| $10$ | $0.111111$ | $0.105361$ | $0.100000$ | $5.2\%$ |
| $100$ | $0.010101$ | $0.010050$ | $0.010000$ | $0.5\%$ |

**Table 1.** The three constants. The optimal constant $\Lambda$ always lies
strictly between the $d=1$ value $1/N$ and the elementary bound $1/(N-1)$,
consistent with Corollary 7.4 below.

### 5.3 The rate of convergence

**Theorem 5.6 (Two-sided rate).** *For $0 < x \le 1$ and $d \ge 1$,*
$$-\log x \;-\; \frac{(\log x)^2}{d - \log x} \;\le\; d\left(1 - x^{1/d}\right)
\;\le\; -\log x.$$

*Proof.* Both halves were established inside the proof of Theorem 5.1. Writing
$L = \log x \le 0$, the upper bound is $d(1 - e^{L/d}) \le -L$, and the lower
one is $d(1 - e^{L/d}) \ge -L\frac{d}{d-L}$. It remains to note
$$-L \;-\; \left(-L\cdot\frac{d}{d-L}\right) \;=\; -L\cdot\frac{(d-L)-d}{d-L}
\;=\; \frac{L^2}{d-L}. \qquad\square$$

**Theorem 5.7 (Quantitative boundary concentration).** *For $d \ge 1$,
$N \ge 2$, $R \ge 0$, with $\Lambda = \log\frac{N}{N-1}$,*
$$0 \;\le\; R\Lambda - d\,\left(R - r_1\right) \;\le\; \frac{R\,\Lambda^2}{d + \Lambda}.$$
*Equivalently,*
$$R - r_1 \;=\; \frac{R\Lambda}{d}\left(1 + O(1/d)\right),$$
*with the implicit constant equal to $\Lambda$.*

*Proof.* Apply Theorem 5.6 with $x = t = 1 - 1/N$, so $\log t = -\Lambda$ and
$(\log t)^2 = \Lambda^2$, $d - \log t = d + \Lambda$; multiply through by
$R \ge 0$ and use $d(R - r_1) = R\,d(1 - t^{1/d})$. $\square$

Numerically at $R = 1$, $N = 2$ ($\Lambda = \log 2 = 0.693147$): the bound
$\Lambda^2/(d+\Lambda)$ equals $0.044960$ at $d = 10$ where the true gap is
$0.023477$, and $0.004774$ at $d = 100$ where the true gap is $0.002397$. The
bound is within a factor $2$ of the truth — the true leading term is
$\Lambda^2/(2d)$ — and has the exact $\Theta(1/d)$ order.

---

## 6. The exponential profile of the whole decomposition

We now move beyond the outermost shell.

### 6.1 A sandwich for every sphere

**Theorem 6.1 (Depth sandwich).** *For $d \ge 1$, $k < N$, $R \ge 0$,*
$$\frac{R}{d}\cdot\frac{k}{N} \;\le\; R - r_k \;\le\;
\frac{R\,(k/N)}{d\left(1 - k/N\right)}.$$

*Proof.* Set $t = 1 - k/N \in (0,1]$, so $r_k = R\,t^{1/d}$ and $1 - t = k/N$.
The left inequality is Lemma 2.3 multiplied by $R$; the right one is Lemma 2.4
multiplied by $R$. $\square$

For $k = 1$ this is Theorem 3.1. The content is that every sphere of the
decomposition — not only the outermost — lies at depth $\Theta(R/d)$: the whole
family is compressed into a boundary layer of width $O(R/d)$.

### 6.2 The profile is exactly exponential

**Definition 6.2 (Rescaled depth parameter).** *For $d \ge 1$ and $k < N$ put*
$$\tau_k \;=\; \tau_k(d,N) \;=\; \frac{-\log\left(1 - \frac{k}{N}\right)}{d}.$$

**Theorem 6.3 (Exact exponential profile).** *For every $d \ge 1$, every
$k < N$, and every $R$,*
$$R - r_k \;=\; R\left(1 - e^{-\tau_k}\right).$$

*Proof.* Since $0 < 1 - k/N \le 1$,
$$r_k = R\left(1-\tfrac kN\right)^{1/d}
= R\exp\left(\frac{\log(1 - k/N)}{d}\right) = R\,e^{-\tau_k}.$$
Subtract from $R$. $\square$

This deserves emphasis: no limit is taken. The equal-volume decomposition, read
in the rescaled depth variable $\tau$, *is* the exponential profile
$R(1 - e^{-\tau})$ in every dimension. The dimension enters only through the
factor $1/d$ inside $\tau_k$, which compresses the profile towards the boundary
— and that compression is precisely the concentration phenomenon.

### 6.3 The limit profile and its inverse

**Theorem 6.4 (Limit profile).** *For every $k < N$ and every $R$,*
$$\lim_{d\to\infty} d\left(R - r_k\right) \;=\; R\,\log\frac{N}{N-k}.$$

*Proof.* Theorem 5.1 with $x = 1 - k/N = \frac{N-k}{N} \in (0,1]$, whose negative
logarithm is $\log\frac{N}{N-k}$; multiply by $R$. $\square$

**Theorem 6.5 (Inverse relation).** *For every $k < N$,*
$$1 - \exp\left(-\log\frac{N}{N-k}\right) \;=\; \frac{k}{N}.$$
*That is, the limiting rescaled depth $\tau = \log\frac{N}{N-k}$ of the $k$-th
sphere and its enclosed-volume-fraction complement $k/N$ are exchanged by the
map $\tau \mapsto 1 - e^{-\tau}$.*

*Proof.* $\exp(-\log\frac{N}{N-k}) = \frac{N-k}{N}$, so
$1 - \frac{N-k}{N} = \frac kN$. $\square$

Theorems 6.4 and 6.5 together say that the limiting depth profile
$k \mapsto R\log\frac{N}{N-k}$ is exactly the inverse function of the
exponential volume profile $\tau \mapsto 1 - e^{-\tau}$, restricted to the grid
of heights $k/N$.

### 6.4 The volume side

**Theorem 6.6 (Exponential volume profile).** *Let $R > 0$ and $u \in
\mathbb{R}$. Then, for $d$ large enough that $u/d \le 1$,*
$$\frac{\operatorname{vol} B\bigl(0, R(1 - u/d)\bigr)}{\operatorname{vol} B(0,R)}
\;=\; \left(1 - \frac{u}{d}\right)^{d}
\;\xrightarrow[d\to\infty]{}\; e^{-u},$$
*and consequently the removed fraction satisfies*
$$\frac{\operatorname{vol} B(0,R) - \operatorname{vol} B\bigl(0,R(1-u/d)\bigr)}
{\operatorname{vol} B(0,R)} \;\xrightarrow[d\to\infty]{}\; 1 - e^{-u}.$$

*Proof.* The identity is the homogeneity
$\operatorname{vol} B(0,r) = \omega_d r^d$: the ratio is
$\bigl(R(1-u/d)\bigr)^d / R^d = (1-u/d)^d$. The limit is the classical
$(1 + z/d)^d \to e^z$ at $z = -u$. The second display follows by subtracting
from $1$. $\square$

This is the dual, measure-theoretic form of Theorem 6.3: peeling a boundary
layer whose thickness is $R u/d$ — i.e. of rescaled depth $u$ — removes a volume
fraction tending to $1 - e^{-u}$. Probabilistically: if $X_d$ is uniform on the
unit ball of $\mathbb{R}^d$, then
$$\mathbb{P}\left[d\left(1 - \|X_d\|\right) > u\right] = \left(1 - \frac ud\right)^d
\longrightarrow e^{-u},$$
so the rescaled distance to the boundary has, tail-by-tail, the law of a
standard exponential random variable.

---

## 7. The dichotomy, and a return payoff

### 7.1 Skins and a core

**Theorem 7.1 (Outer shells collapse).** *For $N \ge 2$ and any $R$,*
$$\lim_{d\to\infty}\left(R - r_1\right) \;=\; 0.$$

*Proof.* $r_1 = R\,t^{1/d}$ with $t = 1 - 1/N > 0$ fixed, and
$t^{1/d} = e^{(\log t)/d} \to e^0 = 1$. $\square$

**Theorem 7.2 (The innermost shell swells).** *For $N \ge 2$ and any $R$,*
$$\lim_{d\to\infty} r_{N-1} \;=\; R, \qquad r_{N-1} = R\,N^{-1/d}.$$

*Proof.* With $k = N-1$, $1 - k/N = 1/N$, so $r_{N-1} = R(1/N)^{1/d}$, and
$(1/N)^{1/d} = e^{-(\log N)/d} \to 1$. $\square$

**Theorem 7.3 (Concentration dichotomy).** *For $N \ge 2$ and any $R$, as
$d \to \infty$,*
$$R - r_1 \to 0 \qquad\text{and}\qquad r_{N-1} \to R.$$
*Every one of the $N$ regions carries exactly the volume fraction $1/N$; yet in
the limit the outermost $N-1$ of them are infinitesimally thin skins pressed
against the boundary sphere, while the innermost one is a ball of full radius
$R$.*

*Proof.* Theorems 7.1 and 7.2; the statement for a general fixed shell
$S_k$ with $k < N$ follows from Theorem 6.1, whose upper bound is $O(R/d)$. $\square$

At $N = 2$, $d = 100$: the outer half of the volume occupies a shell of
thickness $1 - 2^{-1/100} = 0.006908\,R$, while the inner half is the ball of
radius $0.993092\,R$. Two sets of identical volume, one of which is
geometrically indistinguishable from a sphere and the other from the whole ball.

### 7.2 The geometry proves an analytic inequality

The final result runs in the opposite direction to everything above: the
geometric sandwich, valid in every dimension, forces a classical analytic
inequality about the logarithm.

**Corollary 7.4 (Logarithmic sandwich).** *For every integer $N \ge 2$,*
$$\frac{1}{N} \;\le\; \log\frac{N}{N-1} \;\le\; \frac{1}{N-1}.$$

*Proof.* Take $R = 1$. By Theorem 3.1, for every $d \ge 1$,
$$\frac1N \;\le\; d\,(1 - r_1) \;\le\; \frac1{N-1}.$$
By Theorem 5.2, $d(1 - r_1) \to \Lambda = \log\frac{N}{N-1}$. A limit of a
sequence confined to a closed interval lies in that interval. $\square$

This is the familiar $\frac{x}{1+x} \le \log(1+x) \le x$ evaluated at
$x = \frac{1}{N-1}$ — the estimate underlying the logarithmic growth of the
harmonic numbers. It is recovered here as a consequence of the geometry of
equal-volume peelings. Note also the internal consistency: Corollary 7.4 places
$\Lambda$ inside the window $[1/N, 1/(N-1)]$ of Theorem 3.1, and Proposition 3.3
and Theorem 5.2 identify the two endpoints of the monotone family
$d \mapsto d\,\delta_1$ as its infimum ($d = 1$: exactly $1/N$) and its supremum
($d \to \infty$: exactly $\Lambda$), the latter strictly below $1/(N-1)$ by
Theorem 5.5.

---

## 8. Algorithms and computation

All quantities in this paper are elementary functions of $(d, N, R)$ and can be
evaluated in $O(1)$ arithmetic operations, but naive evaluation is numerically
delicate for large $d$, and it is worth recording the stable formulations.

**Algorithm 8.1 (Stable shell radius and depth).** For $k < N$ the radius
$r_k = R(1-k/N)^{1/d}$ should be computed as
$R\exp\bigl(\log(1-k/N)/d\bigr)$, and the depth as
$$R - r_k \;=\; -R\,\operatorname{expm1}\!\left(\frac{\log(1-k/N)}{d}\right),$$
using the standard $\operatorname{expm1}(z) = e^z - 1$ primitive. For large $d$
the exponent $\log(1-k/N)/d$ is tiny and the direct subtraction $R - r_k$ loses
all significant digits to cancellation, while the $\operatorname{expm1}$ form is
accurate to full precision. Similarly $\log(1-k/N)$ for small $k/N$ is best
computed as $\operatorname{log1p}(-k/N)$. Cost: $O(1)$; relative error $O(\epsilon_{\text{mach}})$.

**Algorithm 8.2 (Certified bracketing of the thickness).** Given $(d,N,R)$,
return the interval
$$\left[\max\left\{\frac{R}{dN},\; \text{(lower rate bound)}\right\},\;
\min\left\{\frac{R}{d(N-1)},\; \frac{R\Lambda}{d}\right\}\right]$$
where the lower rate bound is $\frac{R}{d}\bigl(\Lambda - \frac{\Lambda^2}{d+\Lambda}\bigr)$
from Theorem 5.7. Since $\Lambda < 1/(N-1)$ strictly (Theorem 5.5) the upper
endpoint is always $R\Lambda/d$; the lower endpoint is $R/(dN)$ for small $d$
and switches to the rate bound once $d$ is large enough that
$\Lambda - \frac{\Lambda^2}{d+\Lambda} > \frac{1}{N}$, i.e. once
$d > \frac{\Lambda^2}{\Lambda - 1/N} - \Lambda$. The width of the bracket is
$O(R\Lambda^2/d^2)$ in the second regime. Cost: $O(1)$.

**Algorithm 8.3 (Monotone table of the rescaled thickness).** To exhibit
Theorem 4.4, compute $T(d) = d\,(R - r_1)$ for $d = 1,\dots,D$ using Algorithm
8.1 and verify $T(1) \le T(2) \le \cdots \le T(D) \le R\Lambda$, with
$T(1) = R/N$ exactly (Proposition 3.3). Cost: $O(D)$.

**Algorithm 8.4 (Sampling the rescaled radial law).** To sample the rescaled
depth $U = d(1 - \|X\|)$ for $X$ uniform on the unit ball of $\mathbb{R}^d$
*without sampling in $\mathbb{R}^d$*: the radial CDF is
$\mathbb{P}[\|X\| \le \rho] = \rho^d$, so with $V \sim \mathrm{Unif}(0,1)$ one
sets $\|X\| = V^{1/d}$ and $U = d(1 - V^{1/d})$. By Theorem 6.6, $U$ converges
in distribution to $\mathrm{Exp}(1)$. Cost: $O(1)$ per sample, independent of
$d$ — a useful contrast with rejection sampling in the ambient space.

---

## 9. Applications and interpretation

**Boundary layers and the curse of dimensionality.** The correct statement of
"all the volume is near the boundary" is: the natural depth coordinate in
dimension $d$ is $d \times \text{depth}$, and in that coordinate the volume
distribution is exponential. Theorem 5.3 gives the sharp version for equal-volume
strata: the outermost of $N$ equal parts has thickness at most
$\frac{R}{d}\log\frac{N}{N-1}$, and no smaller constant works.

**Stratified sampling and quadrature.** Stratifying a ball into $N$ equal-volume
shells and allocating nodes per shell is a standard variance-reduction device.
Theorem 6.1 says all the strata boundaries are within $O(R/d)$ of the surface
except the innermost, and Theorem 7.3 says the innermost stratum is essentially
the whole ball. Any scheme that treats the $N$ strata as geometrically
comparable is therefore mis-specified in high dimension; the exponential profile
of Theorem 6.3 tells one what the correct — geometrically uniform —
stratification in the rescaled variable is.

**Nearest-neighbour search and distance concentration.** For $X$ uniform on
$B(0,R) \subseteq \mathbb{R}^d$, Theorem 6.6 gives
$\mathbb{P}[\,\|X\| \le R(1-u/d)\,] = (1-u/d)^d \to e^{-u}$: the norm
concentrates in a window of width $O(R/d)$ around $R$. This is the mechanism
behind the failure of spatial indexing structures in high dimension, and the
rate of Theorem 5.7 makes explicit how quickly the exponential regime sets in.

**Isotropic null models.** In statistics and physics, uniform distributions on
high-dimensional balls serve as null models for isotropic randomness. The
dichotomy of Theorem 7.3 explains their standard replacement by "uniform on the
sphere $\times$ exponential radial coordinate": the two differ by $O(1/d)$ in
the radial variable.

**A convex-geometric remark.** The only property of the Euclidean ball used
throughout is the homogeneity $\operatorname{vol}(tK) = t^d\operatorname{vol}(K)$
of Lebesgue measure under dilation. Consequently every result above holds
verbatim for the equal-volume peeling of any convex body $K$ with $0$ in its
interior by dilates $tK$, with "thickness" measured in the gauge (Minkowski
functional) of $K$. The Euclidean specificity would only enter for *parallel*
peelings $K + \varepsilon B$, where the volume is a polynomial in $\varepsilon$
(Steiner's formula) rather than a monomial.

---

## 10. Discussion

Three features of the development deserve comment.

**Elementarity.** Every proof above uses only two ingredients: the factorisation
$1 - s^d = (1-s)\sum_{i<d}s^i$ and the inequality $1 + u \le e^u$. In
particular the monotonicity Theorem 4.3, which is the structurally deepest
statement, is proved by a counting argument about the Cesàro averages of a
geometric sequence, with no derivative in sight. The substitution
$y = t^{1/(ab)}$ that transports Lemma 4.2 to Theorem 4.3 is the only piece of
ingenuity required.

**The role of monotonicity.** Theorem 4.3 is what converts an asymptotic
statement into a universal one. Without it, Theorem 5.2 would only say that the
constant $\Lambda$ is correct *in the limit*; with it, $\Lambda$ becomes an
honest upper bound in every dimension, and Theorem 5.4 shows it is the least
such. Monotone convergence from below is precisely the structure needed for
"asymptotically optimal" to upgrade to "optimal".

**Exact versus asymptotic exponentiality.** It is tempting to describe the
$1-e^{-u}$ law as a limit theorem. Theorem 6.3 shows it is not: in the rescaled
depth variable the profile is exponential identically, in every dimension. What
converges as $d \to \infty$ is not the shape but the *grid* of depths at which
the equal-volume spheres sit — from $\{\,-\log(1-k/N)/d\,\}$ (which shrinks to
$0$) to the fixed grid $\{\log\frac{N}{N-k}\}$ after multiplication by $d$. This
is a cleaner way to phrase the concentration statement than any $\varepsilon$-based
formulation.

---

## 11. Future directions

**1. Exponential limit of the rescaled radial law.** If $X_d$ is uniform on
$B(0,1) \subseteq \mathbb{R}^d$, we conjecture that the rescaled distance to the
boundary $d(1 - \|X_d\|)$ converges *in distribution* to $\mathrm{Exp}(1)$ with
convergence at rate $O(1/d)$ in Kolmogorov distance. Theorem 6.6 already
computes every tail probability, $\mathbb{P}[d(1-\|X_d\|) > u] = (1-u/d)^d \to
e^{-u}$; what remains is the packaging as a statement about measures and a bound
uniform in $u$ of the shape established in Theorem 5.7. The analytic core is
finished; the remaining work is measure-theoretic bookkeeping.

**2. Anisotropic peelings: convex bodies and the log-constant.** For any convex
body $K \subseteq \mathbb{R}^d$ with $0$ in its interior, the equal-volume
peeling by dilates $tK$ has outer-shell thickness (measured in the gauge of $K$)
exactly $1 - (1-1/N)^{1/d}$, so the constant $\Lambda/d$ of Theorem 5.3 is a
*dimension-and-$N$* invariant independent of the body; this is immediate from
homogeneity. We conjecture that for non-dilate peelings — for instance by
parallel bodies $K + \varepsilon B$ — the corresponding constant is strictly
larger unless $K$ is a ball, the rigidity being a Brunn–Minkowski statement.

**3. Second-order asymptotics.** Theorem 5.7 gives $R\Lambda/d\,(1+O(1/d))$ with
an explicit constant. The true expansion is
$d(1 - t^{1/d}) = \Lambda - \frac{\Lambda^2}{2d} + O(1/d^2)$; establishing the
full asymptotic series, and an alternating-bound structure that brackets the
truth from both sides at each order, would sharpen Algorithm 8.2 to width
$O(d^{-m})$ for any $m$.

**4. Non-uniform stratifications.** Given a target profile of volume fractions
$0 = p_0 < p_1 < \cdots < p_N = 1$ instead of $p_k = k/N$, the radii are
$R(1-p_k)^{1/d}$, and the analogue of Theorem 5.3 reads
$R - r_k \le \frac{R}{d}\log\frac{1}{1-p_k}$ with the same optimality proof. It
would be interesting to characterise the profiles $(p_k)$ for which the strata
have comparable rescaled thicknesses — the answer should be the geometric
progression $1 - p_k = \theta^k$, which makes the rescaled depths an arithmetic
progression.

**5. Shells of general star bodies and Steiner-type expansions.** For a smooth
convex body, the parallel-body volume $\operatorname{vol}(K + \varepsilon B)$ is
a degree-$d$ polynomial in $\varepsilon$ whose coefficients are the intrinsic
volumes. The analogue of the equal-volume peeling then requires inverting that
polynomial, and the leading behaviour of the outer-shell thickness should be
$\frac{\operatorname{vol}(K)}{N\,\operatorname{surface}(K)}$ rather than
$R\Lambda/d$ — quantifying the discrepancy, and recovering the ball case as the
extremal one, is the natural isoperimetric question.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Two-sided bound | $\frac{R}{dN} \le R - r_1 \le \frac{R}{d(N-1)}$ |
| Exactness at $d=1$ | $R - r_1 = R/N$ when $d=1$ |
| Monotonicity | $d \mapsto d\,(1 - t^{1/d})$ increasing for $0 < t \le 1$ |
| Optimal bound | $R - r_1 \le \frac{R}{d}\log\frac{N}{N-1}$, constant optimal |
| Strict improvement | $\log\frac{N}{N-1} < \frac{1}{N-1}$ |
| Rate | $0 \le R\Lambda - d(R-r_1) \le \frac{R\Lambda^2}{d+\Lambda}$ |
| Exact profile | $R - r_k = R(1 - e^{-\tau_k})$, $\tau_k = -\log(1-k/N)/d$ |
| Limit profile | $d(R - r_k) \to R\log\frac{N}{N-k}$; $1 - e^{-\tau} = k/N$ |
| Volume profile | $(1-u/d)^d \to e^{-u}$ |
| Dichotomy | $R - r_1 \to 0$ and $r_{N-1} \to R$ |
| Analytic payoff | $\frac1N \le \log\frac{N}{N-1} \le \frac1{N-1}$ |
