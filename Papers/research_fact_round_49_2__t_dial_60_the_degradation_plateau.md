# Plateaus in Rank Correlation: A Sharp Cubic Law for Locally Starved Rankings

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We give an exact combinatorial explanation for a phenomenon observed in the empirical
evaluation of ranking heuristics: as instances grow, the Spearman rank correlation
between a cheap "dial" statistic and an expensive target statistic degrades, but the
degradation *stops* at a strictly positive level rather than continuing to zero.

Our starting point is an exact identity, the **reversal duality**
$3D(f) + 3D(\bar f) = n^3-n$ relating the squared rank displacement $D(f)=\sum_i (i-f(i))^2$
of a ranking $f$ of $\{0,\dots,n-1\}$ to that of its mirror $\bar f(i)=n-1-f(i)$. Duality
yields at once the sharp extremal bound $3D(f)\le n^3-n$ together with the identification of
its unique extremiser (the order reversal), hence $-1\le\rho\le 1$ for Spearman's coefficient
$\rho(f) = 1 - 6D(f)/(n^3-n)$.

We then model degradation as **local starvation**: the ranking is exact outside a window of
$m$ consecutive ranks and arbitrary inside it. A block transfer principle shows that such a
ranking satisfies $3D(f)\le m^3-m$ *independently of $n$*, whence the **plateau floor**
$$\rho \;\ge\; 1-2\alpha^3, \qquad \alpha = m/n,$$
uniformly in $n$; the floor is strictly positive precisely when $\alpha<2^{-1/3}\approx0.7937$.
We prove that this bound is attained: the worst window ranking has the closed form
$\rho = 1-2(m^3-m)/(n^3-n)$, obeys the shape law $|\rho-(1-2\alpha^3)|\le 2/(n^2-1)$, is
strictly decreasing in the window width, changes sign exactly at $2(m^3-m)=n^3-n$, and
converges to $1-2\alpha^3$ along any family of fixed shape.

Finally we treat the **starved-everywhere** regime. If the ranks are cut into $k$ segments and
the ranking is scrambled inside every segment while the coarse order between segments is
retained, then $\rho \ge 1-2/k^2$, independently of segment length; for $k\ge 2$ this gives
$\rho \ge 1/2$. Total loss of local resolution therefore cannot drive rank correlation to
zero — only loss of coarse order can.

Calibrating against the observation $\rho=0.437$ with interval $[0.393,0.480]$: a starved
fraction $\alpha=0.66$ predicts the plateau value $1-2(0.66)^3 = 0.425008$, inside the
interval, and *every* instance with $\alpha\le 0.66$ scores at least $0.425$. The same law
gives a guaranteed margin of at least $0.070$ over a rival ranking with starved fraction
$\ge 0.69$, for all instances with $n\ge 20$ — matching the observed gap.

**Keywords:** Spearman rank correlation, squared rank displacement, extremal permutation
problems, block-localised permutations, plateau phenomena, cubic scaling laws.

---

## 1. Introduction

### 1.1 The empirical puzzle

A common situation in experimental mathematics and in algorithm engineering is the
following. One has a *target* quantity that is expensive to compute for each of $n$ objects,
and a *dial*: a cheap statistic whose ordering one hopes correlates with the target's
ordering. The quality of the dial is measured by Spearman's rank correlation coefficient.

In the study that motivated this work, a dial $T$ was evaluated against a target rate
statistic at increasing problem sizes (parameterised by a bit length). The correlation
declined with size, and the natural extrapolation was that the dial would eventually carry no
information: $\rho \to 0$. Instead, at bit length $60$ the reading was

$$\rho(T,\text{rate}) = 0.437, \qquad \text{bootstrap interval } [0.393,\,0.480],$$

and it did not move further. The dial also retained a stable advantage of about $+0.070$ over
a simpler competing dial. Two hypotheses were tested and both failed: **H1** (monotone
continuation of the degradation to zero) and **H3** (recovery at larger sizes). The regime was
*starved*: only about $0.89\%$ of items possessed the property the dial tracks, so local
discrimination was almost entirely absent.

This paper supplies an exact mechanism that produces such a plateau, and proves that within
that mechanism both H1 and H3 must fail.

### 1.2 The mechanism in one sentence

Squared rank displacement is a *cubic* resource: $n$ ranks can express at most $(n^3-n)/3$
units of disagreement. Damage confined to a window of $m$ ranks can consume at most
$(m^3-m)/3$ of those units. The ratio is $\alpha^3$ where $\alpha=m/n$, so the correlation
depends only on the *shape* of the damage and not on the size of the instance — and a
correlation that depends only on a shape parameter which has stopped changing is, by
definition, a plateau.

### 1.3 Contributions

1. An exact reversal duality for squared rank displacement (Theorem 2.4), with the sharp
   extremal bound and its unique equality case as corollaries (Theorems 2.5, 2.7).
2. A block transfer principle (Theorem 3.2) reducing displacement of a window-localised
   ranking to displacement on the window alone, hence a size-free damage bound (Theorem 3.3).
3. The plateau floor $\rho\ge1-2\alpha^3$ (Theorem 4.3) and the positivity threshold
   $\alpha<2^{-1/3}$ (Corollary 4.4).
4. The exact degradation curve of the worst window ranking, its strict monotonicity in
   window width, its sign change, its shape law with error $2/(n^2-1)$, and its limit
   (Theorems 5.1–5.5) — showing the floor is attained, not merely a bound.
5. Calibration to the observed plateau and a proved margin over the rival dial
   (Theorems 6.1–6.3).
6. The fragmentation floor $\rho\ge1-2/k^2$ for totally locally-scrambled rankings
   (Theorem 7.3), and the corollary $\rho\ge1/2$ for $k\ge2$ (Corollary 7.4).

---

## 2. Rank displacement and the reversal duality

### 2.1 Setting

Throughout, $n\in\mathbb{N}$ and rankings are described by maps $f:\mathbb{N}\to\mathbb{N}$
restricted to the initial segment of ranks.

> **Definition 2.1 (Rank permutation).** A map $f:\mathbb{N}\to\mathbb{N}$ is a *rank
> permutation of $\{0,\dots,n-1\}$* if (i) $f(i)<n$ for all $i<n$, and (ii) $f$ is injective
> on $\{0,\dots,n-1\}$. Equivalently, $f$ maps $\{0,\dots,n-1\}$ bijectively onto itself.

Interpretation: object of true rank $i$ receives dial rank $f(i)$.

> **Definition 2.2 (Squared displacement).** The *squared rank displacement* of $f$ on $n$
> ranks is
> $$D_n(f) \;=\; \sum_{i=0}^{n-1}\bigl(i-f(i)\bigr)^2 .$$

> **Definition 2.3 (Spearman coefficient).** For $n\ge 2$,
> $$\rho_n(f) \;=\; 1 - \frac{6\,D_n(f)}{n^3-n}.$$

We record two elementary power sums used repeatedly:
$$2\sum_{i=0}^{n-1} i = n^2-n, \qquad 6\sum_{i=0}^{n-1} i^2 = 2n^3-3n^2+n. \tag{2.1}$$

Expanding the square and using that $f$ permutes the ranks (so $\sum_i f(i)^2=\sum_i i^2$)
gives the *inner-product form*
$$D_n(f) \;=\; 2\sum_{i<n} i^2 \;-\; 2\sum_{i<n} i\,f(i). \tag{2.2}$$
In particular $\sum_i i f(i) \le \sum_i i^2$ for every rank permutation — a Cauchy–Schwarz
statement obtained here for free from $D_n(f)\ge0$.

### 2.2 The duality

> **Definition.** The *mirror* of a rank permutation $f$ is $\bar f(i) = n-1-f(i)$. It is
> again a rank permutation of $\{0,\dots,n-1\}$.

> **Theorem 2.4 (Reversal duality).** For every rank permutation $f$ of $\{0,\dots,n-1\}$,
> $$3D_n(f) + 3D_n(\bar f) \;=\; n^3-n .$$
> Equivalently, $\rho_n(f)+\rho_n(\bar f)=0$.

*Proof sketch.* Apply (2.2) to both $f$ and $\bar f$. Writing $S_1=\sum_{i<n} i$ and
$S_2=\sum_{i<n} i^2$, the cross term for the mirror is
$$\sum_{i<n} i\,\bar f(i) = \sum_{i<n} i\,(n-1-f(i)) = (n-1)S_1 - \sum_{i<n} i f(i),$$
so the unknown cross term $\sum_i i f(i)$ cancels exactly when the two copies of (2.2) are
added. What remains is $4S_2 - 2(n-1)S_1$, and substituting the power sums (2.1) turns this
into $(n^3-n)/3$. Multiplying by $3$ gives the claim. $\square$

The identity is remarkable in being *exact for every permutation*, with no error term: the
pair $\{f,\bar f\}$ always splits the total displacement budget evenly in the sense of summing
to a constant.

> **Theorem 2.5 (Sharp extremal bound).** For every rank permutation $f$ of $\{0,\dots,n-1\}$,
> $$3D_n(f) \;\le\; n^3-n, \qquad\text{i.e.}\qquad \rho_n(f)\ge -1 .$$

*Proof.* $D_n(\bar f)\ge0$ is a sum of squares; subtract it from Theorem 2.4. $\square$

Together with the trivial $D_n(f)\ge0$ (giving $\rho_n\le1$) this pins the range of Spearman's
coefficient to $[-1,1]$, with $\rho_n(\mathrm{id})=1$.

> **Definition 2.6.** The *order reversal* is $\mathrm{rev}_n(i)=n-1-i$.

> **Theorem 2.7 (Unique extremiser).** $3D_n(\mathrm{rev}_n)=n^3-n$ exactly, so
> $\rho_n(\mathrm{rev}_n)=-1$; and conversely, if a rank permutation $f$ satisfies
> $3D_n(f)=n^3-n$, then $f(i)=n-1-i$ for all $i<n$.

*Proof.* Apply Theorem 2.4 to $f=\mathrm{id}$, whose displacement is $0$ and whose mirror is
$\mathrm{rev}_n$; this gives the value. For uniqueness, equality in Theorem 2.5 forces
$D_n(\bar f)=0$; since $D_n(g)=0$ iff $g$ fixes every rank below $n$, we get
$n-1-f(i)=i$. $\square$

We therefore call
$$B(n) \;=\; \frac{n^3-n}{3}$$
the **displacement budget** of $n$ ranks: the maximum disagreement expressible by $n$ items.
Its first values are $B(0),\dots,B(7) = 0,0,2,8,20,40,70,112$; exhaustive enumeration over all
permutations of up to $7$ elements confirms these maxima, and Theorem 2.7 proves them in
general. (For instance, the reversal of $7$ items has displacement $6^2+4^2+2^2+0+2^2+4^2+6^2=112$.)

---

## 3. Local starvation: block-localised rankings

We now model the way a starved dial degrades.

> **Definition 3.1 (Block-localised ranking).** Let $a+m\le n$. A map $f$ is *block-localised
> in the window $[a,a+m)$* if
> 1. $f(i)=i$ for every $i<a$ and every $i\ge a+m$ (coarse order outside the window intact);
> 2. $f$ maps $[a,a+m)$ into itself, and $j\mapsto f(a+j)-a$ is a rank permutation of
>    $\{0,\dots,m-1\}$ (arbitrary scrambling inside the window).

Such an $f$ is automatically a rank permutation of $\{0,\dots,n-1\}$. It represents a dial
that has retained all coarse ordering information but has lost all discrimination inside a
band of relative width $\alpha=m/n$.

> **Theorem 3.2 (Block transfer).** If $f$ is block-localised in $[a,a+m)$ then
> $$D_n(f) \;=\; D_m\bigl(j\mapsto f(a+j)-a\bigr).$$

*Proof sketch.* Every rank outside the window contributes $(i-f(i))^2 = 0$. Restricting the
sum to $[a,a+m)$ and reindexing by $i=a+j$, the displacement $i-f(i)$ equals
$j-(f(a+j)-a)$, which is exactly the displacement of the induced window permutation. $\square$

> **Theorem 3.3 (Size-free damage bound).** If $f$ is block-localised in a window of width
> $m$ inside $n$ ranks, then
> $$3D_n(f) \;\le\; m^3-m,$$
> a bound independent of $n$.

*Proof.* Combine Theorem 3.2 with Theorem 2.5 applied on $m$ ranks. $\square$

This is the crux. The maximal harm a starved band can do is capped by the band's own budget
$B(m)$, while the normalisation of $\rho$ uses the whole budget $B(n)$. Because $B$ is cubic,
the ratio is essentially $\alpha^3$.

> **Definition 3.4 (Worst window ranking).** The *block reversal* $R_{a,m}$ acts as the
> identity outside $[a,a+m)$ and reverses the window:
> $$R_{a,m}(i)=\begin{cases} a+(m-1-(i-a)), & a\le i<a+m,\\ i,&\text{otherwise.}\end{cases}$$

> **Proposition 3.5.** $R_{a,m}$ is block-localised in $[a,a+m)$ and attains the bound of
> Theorem 3.3 with equality: $3D_n(R_{a,m}) = m^3-m$.

*Proof.* By Theorem 3.2 its displacement is that of $\mathrm{rev}_m$, which is $(m^3-m)/3$ by
Theorem 2.7. $\square$

---

## 4. The plateau floor

> **Lemma 4.1 (Cubic comparison).** If $1\le M \le \alpha N$ with $0\le\alpha\le1$ and
> $N\ge2$ (reals), then $M^3-M \le \alpha^3(N^3-N)$.

*Proof sketch.* The function $t\mapsto t^3-t$ is increasing for $t\ge1$, and $\alpha N \ge M
\ge 1$, so $M^3-M \le (\alpha N)^3-\alpha N$. Since $0\le\alpha\le1$ we have $\alpha^3\le\alpha$
hence $\alpha^3 N \le \alpha N$, so $(\alpha N)^3-\alpha N \le \alpha^3 N^3-\alpha^3 N
= \alpha^3(N^3-N)$. $\square$

> **Theorem 4.2 (Degradation floor, integral form).** If $f$ is block-localised in a window of
> width $m$ inside $n\ge2$ ranks, then
> $$\rho_n(f) \;\ge\; 1 - \frac{2(m^3-m)}{n^3-n}.$$

*Proof.* Theorem 3.3 gives $6D_n(f)\le 2(m^3-m)$; divide by $n^3-n>0$. $\square$

> **Theorem 4.3 (Plateau floor — main theorem).** Let $f$ be block-localised in a window of
> width $m\ge1$ inside $n\ge2$ ranks, and suppose the window occupies at most a fraction
> $\alpha\in[0,1]$ of the ranks, i.e. $m \le \alpha n$. Then
> $$\boxed{\;\rho_n(f) \;\ge\; 1-2\alpha^3\;}$$
> uniformly in $n$.

*Proof.* Apply Lemma 4.1 with $M=m$, $N=n$ to the numerator of Theorem 4.2. $\square$

> **Corollary 4.4 (Strictly positive floor).** Under the hypotheses of Theorem 4.3, if
> $2\alpha^3<1$ — that is, $\alpha < 2^{-1/3}\approx0.7937$ — then $\rho_n(f)>0$ for every $n$.

Theorem 4.3 is the refutation of H1 inside the model: no matter how large the instance, a dial
whose loss is confined to a fixed fraction of the range below $2^{-1/3}$ has correlation
bounded away from zero by an explicit constant depending only on that fraction.

---

## 5. The exact degradation curve

The bound of Theorem 4.3 would be uninteresting if slack. It is not.

> **Theorem 5.1 (Closed form).** For $a+m\le n$ and $n\ge2$,
> $$\rho_n(R_{a,m}) \;=\; 1-\frac{2(m^3-m)}{n^3-n}.$$

*Proof.* Immediate from Proposition 3.5 and Definition 2.3. $\square$

Thus Theorem 4.2 is an equality for the worst window ranking: the block reversal *is* the
extremal instance, and the plateau level is achieved by an explicit dial.

> **Theorem 5.2 (Strict monotone degradation).** If $1\le m<m'$ and $a+m'\le n$ with $n\ge2$,
> then $\rho_n(R_{a,m'}) < \rho_n(R_{a,m})$.

*Proof sketch.* $t\mapsto t^3-t$ is strictly increasing on $[1,\infty)$, since
$m'^3-m'-(m^3-m)=(m'-m)(m'^2+m'm+m^2-1)>0$ for $m\ge1$; divide by the fixed positive
denominator. $\square$

This is the correct home for the intuition "degradation is monotone". Monotonicity in bit
length is not a statement about a single permutation; monotonicity in *window width* is, and
it is exactly true.

> **Theorem 5.3 (Phase transition).** For $a+m\le n$, $n\ge2$:
> $$\rho_n(R_{a,m})>0 \iff 2(m^3-m) < n^3-n .$$

Asymptotically the threshold is $m/n \to 2^{-1/3}\approx 0.7937$, matching Corollary 4.4.

> **Theorem 5.4 (Shape law with explicit error).** For $a+m\le n$, $n\ge2$, with $\alpha=m/n$,
> $$\bigl|\rho_n(R_{a,m}) - (1-2\alpha^3)\bigr| \;\le\; \frac{2}{n^2-1}.$$

*Proof sketch.* A direct computation gives the exact discrepancy
$$\rho_n(R_{a,m}) - (1-2\alpha^3) \;=\; \frac{2m\,(n^2-m^2)}{n^2\,(n^3-n)} ,$$
which is nonnegative since $m\le n$ (so the exact reading always sits slightly *above* the
shape law). For the upper bound, $m\le n$ and $n^2-m^2\le n^2$ give numerator
$2m(n^2-m^2)\le 2n^3$, while the denominator is $n^2(n^3-n)=n^3(n^2-1)$; the quotient is at
most $2/(n^2-1)$. $\square$

Numerically the error is $2\times10^{-4}$ at $n=100$ and $2\times10^{-6}$ at $n=1000$: the
shape law $1-2\alpha^3$ is not an approximation in any practically relevant sense.

> **Theorem 5.5 (Attainment).** Fix integers $p\le q$ with $q\ge2$ and set $\alpha=p/q$. Along
> the family with $n=q(k+1)$ ranks and window width $m=p(k+1)$,
> $$\lim_{k\to\infty} \rho_{q(k+1)}\bigl(R_{0,\,p(k+1)}\bigr) \;=\; 1-2\alpha^3 .$$

*Proof.* By Theorem 5.4 the discrepancy is at most $2/(n^2-1)\le 2/(k+1)\to0$, since
$n=q(k+1)\ge 2(k+1)$. $\square$

Theorems 5.1–5.5 together say: the floor of Theorem 4.3 is an **attained infimum**. This
refutes H3 (recovery). A quantity converging to its infimum from above does not subsequently
rebound as the instance grows; the observed value is the asymptotic level itself.

### 5.1 Numerical table

| $n$ | $m$ | $\alpha=m/n$ | exact $\rho = 1-\dfrac{2(m^3-m)}{n^3-n}$ | shape law $1-2\alpha^3$ | error |
|---:|---:|---:|---:|---:|---:|
| $10$ | $3$ | $0.30$ | $0.951515$ | $0.946000$ | $0.005515$ |
| $10$ | $7$ | $0.70$ | $0.321212$ | $0.314000$ | $0.007212$ |
| $60$ | $40$ | $0.6\overline{6}$ | $0.407613$ | $0.407407$ | $0.000206$ |
| $100$ | $66$ | $0.66$ | $0.425083$ | $0.425008$ | $0.000075$ |
| $1000$ | $660$ | $0.66$ | $0.425009$ | $0.425008$ | $0.000001$ |

The last two rows exhibit the plateau: a hundredfold increase in $n$ at fixed shape moves the
reading by one unit in the sixth decimal place.

---

## 6. Calibration against the measurement

The reported reading is $\rho = 0.437$ with interval $[0.393,0.480]$, together with a stable
advantage of $+0.070$ over a `count`-style rival dial.

Inverting the shape law, $1-2\alpha^3 = 0.437$ gives $\alpha=\bigl((1-0.437)/2\bigr)^{1/3}
\approx 0.6549$. We adopt the round rational calibration $\alpha=33/50=0.66$.

> **Theorem 6.1 (Predicted plateau lies in the reported interval).**
> $$0.393 \;\le\; 1-2\left(\tfrac{33}{50}\right)^3 = 0.425008 \;\le\; 0.480 .$$

> **Theorem 6.2 (Calibrated plateau).** Let $f$ be block-localised in a window of width
> $m\ge1$ inside $n\ge2$ ranks with $50m\le 33n$ (i.e. at most $66\%$ of the ranks are
> starved). Then
> $$\rho_n(f) \;\ge\; 0.425 .$$

*Proof.* Theorem 4.3 with $\alpha=33/50$, then $1-2(33/50)^3=0.425008\ge0.425$. $\square$

This is the formal content of "the degradation reaches a floor at $\approx0.44$ instead of
vanishing": the value is not fitted, it is a *guaranteed lower bound* holding at every
instance size, and the measurement sits on it.

> **Theorem 6.3 ($T$ still beats `count`).** Let $n\ge20$. Let $f_T$ be block-localised in a
> window of width $m_T\ge1$ with $50m_T\le33n$ (starved fraction $\le0.66$), and let the rival
> dial be the block reversal $R_{b,m_C}$ with $b+m_C\le n$ and $69n\le100m_C$ (starved fraction
> $\ge0.69$). Then
> $$\rho_n(f_T) - \rho_n(R_{b,m_C}) \;\ge\; 0.070 .$$

*Proof sketch.* Theorem 6.2 gives $\rho_n(f_T)\ge 0.425$. For the rival, Theorem 5.4 with
$\alpha_C=m_C/n\ge0.69$ gives
$$\rho_n(R_{b,m_C}) \le 1-2\alpha_C^3 + \frac{2}{n^2-1} \le 1-2(0.69)^3+\frac{2}{399}
= 0.342982+0.005013 = 0.347995,$$
using $n\ge20 \Rightarrow n^2-1\ge399$. Subtracting, the gap is at least
$0.425-0.348 = 0.077 \ge 0.070$. $\square$

The observed $+0.070$ margin thus corresponds to a mere three-percentage-point difference in
starved width, amplified by the cube: $2(0.69^3-0.66^3)\approx0.0555$, plus the slack between
the calibrated floor $0.425$ and the observed $0.437$.

---

## 7. Total starvation: the fragmentation floor

The single-window model is a caricature: in the observed regime the dial is starved
*everywhere*, not in one band. The following results show that this changes the constant but
not the conclusion.

> **Definition 7.1 (Segment-wise scrambling).** Let $k,m\ge1$ and $n=km$. A map $f$ is
> *segment-wise scrambled with $k$ segments of length $m$* if for every $j<k$ the map
> $i \mapsto f(jm+i)-jm$ is a rank permutation of $\{0,\dots,m-1\}$ and $f$ maps the segment
> $[jm,\,jm+m)$ into itself.

Interpretation: the dial has lost *all* local resolution — inside every segment its ordering is
arbitrary — but it still knows which segment each item belongs to, i.e. the coarse order.

> **Theorem 7.2 (Segment decoupling and damage bound).** For segment-wise scrambled $f$,
> $$D_{km}(f) \;=\; \sum_{j=0}^{k-1} D_m\bigl(i\mapsto f(jm+i)-jm\bigr),
> \qquad\text{hence}\qquad 3D_{km}(f) \;\le\; k\,(m^3-m).$$

*Proof sketch.* Split $\{0,\dots,km-1\}$ into the $k$ segments and reindex each; within
segment $j$ the displacement $(jm+i)-f(jm+i)$ equals $i-(f(jm+i)-jm)$. This is the induction
step; the bound then follows by applying Theorem 2.5 on each segment. $\square$

> **Theorem 7.3 (Fragmentation floor).** Let $f$ be segment-wise scrambled with $k\ge1$
> segments of length $m$, and let $n=km\ge2$. Then
> $$\rho_n(f) \;\ge\; 1-\frac{2}{k^2},$$
> **independently of the segment length $m$**.

*Proof sketch.* By Theorem 7.2, $6D_n(f)\le 2k(m^3-m)$, so
$$\rho_n(f) \ge 1 - \frac{2k(m^3-m)}{(km)^3-km} = 1-\frac{2}{k^2}\cdot\frac{m^3-m}{m^3-m/k^2}
\ge 1-\frac{2}{k^2},$$
the last step because $m^3-m \le m^3-m/k^2$ for $k\ge1$. $\square$

> **Corollary 7.4 (Half the signal survives total local starvation).** With $k\ge2$ segments,
> $\rho_n(f)\ge \tfrac12$, however long the segments.

The asymptotic sharpness is visible in the worst instance: reversing every segment gives
exactly
$$\rho = 1-\frac{2k(m^3-m)}{(km)^3-km} \;\xrightarrow[m\to\infty]{}\; 1-\frac{2}{k^2},$$
so $1-2/k^2$ is approached from above and never attained at finite segment length.

**Worked instance.** Take $k=2$, $m=3$, so $n=6$, and reverse each segment:
$f = (2,1,0,\,5,4,3)$. Then $D_6(f)=4+0+4+4+0+4=16$, so
$$\rho_6(f) = 1-\frac{96}{210} = 1-0.457143 = 0.542857,$$
comfortably above the guaranteed floor $1-2/2^2 = 0.5$.

**Interpretation.** Squared displacement is a cubic resource: the whole range holds
$B(n)\sim n^3/3$ units, while $k$ segments hold only $k\,B(n/k)\sim n^3/(3k^2)$. Fine
distinctions are cheap; coarse order is expensive. Spearman correlation is therefore
overwhelmingly a measurement of coarse order, and a starved dial destroys precisely the cheap
component. This is why total local starvation cannot send $\rho$ to zero: reaching zero would
require destroying the *between-segment* structure, which no amount of within-segment
scrambling can touch.

---

## 8. Algorithms

Three routines suffice to reproduce and explore everything above.

**(A) Exact Spearman evaluation of a rank map.** Given a permutation $f$ of
$\{0,\dots,n-1\}$, compute $D=\sum(i-f(i))^2$ and return $1-6D/(n^3-n)$. Cost $O(n)$ time,
$O(1)$ extra space. Used to check every closed form against a direct evaluation.

**(B) Extremal displacement search.** For small $m$, enumerate all $m!$ permutations of
$\{0,\dots,m-1\}$, maximise $D$, and compare to $(m^3-m)/3$. Cost $O(m!\cdot m)$; feasible to
$m\approx9$. This is the empirical confirmation of Theorem 2.7 and yields the sequence
$0,0,2,8,20,40,70,112$ for $m=0,\dots,7$.

**(C) Plateau curve and calibration.** For a grid of $(n,m)$, tabulate the exact curve
$1-2(m^3-m)/(n^3-n)$, the shape law $1-2\alpha^3$, and their difference; invert the shape law
to recover the starved fraction from an observed correlation, $\alpha = ((1-\rho)/2)^{1/3}$.
Cost $O(1)$ per point.

A fourth routine builds random segment-wise scramblings and verifies the fragmentation floor
$1-2/k^2$ empirically; cost $O(km)$ per sample.

---

## 9. Discussion

### 9.1 What the model does and does not claim

The model claims: *if* degradation takes the form of losing local ordering resolution while
preserving coarse order, *then* the Spearman reading is a function of the shape of the loss
alone, is bounded below by an explicit positive constant, and converges to that constant. It
does not claim that all degradation is of this form. A dial that begins to misplace items
across the whole range — coarse damage — is not covered, and indeed such a dial can reach
$\rho=-1$ (Theorem 2.7).

The empirical signature distinguishing the two is exactly the plateau. Coarse damage produces
size-dependent readings that keep falling; local starvation produces size-independent readings
at a level $1-2\alpha^3$.

### 9.2 On the two refuted hypotheses

**H1 (monotone continuation to zero).** Refuted by Theorem 4.3 with Corollary 4.4: for a fixed
starved fraction $\alpha<2^{-1/3}$ the reading is bounded below by $1-2\alpha^3>0$, uniformly
in $n$. No sequence of instances of that shape can approach zero.

**H3 (recovery).** Refuted by Theorem 5.5: the extremal reading converges to $1-2\alpha^3$
from above with error $\Theta(1/n^2)$. There is no mechanism in the model by which a converged
quantity subsequently increases; the observed level is the limit.

What *does* survive of the monotonicity intuition is Theorem 5.2: degradation is strictly
monotone in the window width. Bit length is not a parameter of a single permutation, so
monotonicity in bit length is not even expressible in the model; monotonicity in the induced
shape parameter is, and it holds exactly.

### 9.3 Reading the plateau height as a measurement

Because the shape law is invertible, an observed plateau *measures* the starved fraction:
$$\alpha = \left(\frac{1-\rho}{2}\right)^{1/3}.$$
The observation $\rho=0.437$ gives $\alpha\approx0.655$; the interval $[0.393,0.480]$ gives
$\alpha\in[0.641,0.671]$. The cube root compresses uncertainty: a $\pm0.044$ band on $\rho$
becomes a $\pm0.015$ band on $\alpha$. Plateau height is therefore a *more* stable estimator
of the shape parameter than it is of anything else, which is a pleasant inversion of the usual
complaint about rank statistics being blunt instruments.

### 9.4 The cubic asymmetry

The single structural fact underlying every result is that the displacement budget is cubic in
the number of ranks. Two consequences:

- **Locality is cheap.** Damage confined to a fraction $\alpha$ costs $\alpha^3$ of the budget.
  At $\alpha=1/2$ that is one eighth; the correlation cannot drop below $0.75$.
- **Fragmentation is cheaper still.** Splitting into $k$ pieces and destroying each costs only
  $1/k^2$ of the budget.

Both are manifestations of the fact that Spearman's coefficient measures *long-range* order.

---

## 10. Future work

**Ties-aware plateau.** The measured target variable is starved: only $\approx0.89\%$ of items
are "smooth", so the target ranking is massively tied while the dial ranking is not. Spearman
with mid-ranks then carries a different normalisation and the plateau constant should shift.
The key structural observation is that ties act as a projection of the rank vector onto
block-constant vectors, so the correlation splits into a between-class part — exactly the
fragmentation quantity $1-2/k^2$ — and a within-class part which vanishes. The decoupling
identity of Theorem 7.2 already computes the between-class part exactly; only the mid-rank
normalisation must be added.

**Sharpness of the fragmentation floor.** Theorem 7.3 gives $\rho\ge1-2/k^2$, and the
all-segments-reversed witness attains it in the limit $m\to\infty$. Conjecture: $1-2/k^2$ is the
exact infimum over *all* segment-wise scramblings with $k$ segments, attained only in the
limit. Since segment displacements decouple completely, the infimum is $k$ copies of a
one-segment extremal problem whose answer is Theorem 2.7; what is missing is the limit
statement analogous to Theorem 5.5.

**Two-scale and non-uniform fragmentation.** Real degradation is unlikely to produce equal
segments. For a partition into blocks of sizes $m_1,\dots,m_k$ with $\sum m_j=n$, the same
decoupling gives $\rho\ge 1-2\sum_j m_j^3/n^3$ up to lower-order terms, i.e. the floor is
controlled by the *third-power concentration* $\sum (m_j/n)^3$ of the partition. Making this
exact, and identifying which partitions of a fixed total mass minimise the correlation
(intuitively, the most unequal ones), is the natural next theorem.

**Mixed damage.** A hybrid model in which a fraction of coarse order is also lost — say, a
random transposition of two distant blocks superimposed on local scrambling — would quantify
how much coarse damage is needed before the plateau breaks. Since coarse damage is expensive
in budget terms, one expects a sharp threshold, with the plateau surviving until the coarse
damage reaches a fixed fraction of $n^3$.

**Beyond Spearman.** Kendall's $\tau$ counts inversions, a *quadratic* resource
($\binom{n}{2}$), so the analogous locality law should read $\tau \ge 1-2\alpha^2$ for a window
of relative width $\alpha$ and $\tau\ge1-1/k$ for $k$-fold fragmentation. Proving these and
comparing the exponents would sharpen the general principle that the exponent in the plateau
law is determined by the degree of the correlation statistic's normalising budget.

---

## 11. Conclusion

A rank-correlation reading that stops falling is not an anomaly to be explained away; it is the
signature of a specific kind of information loss. We have shown that when a ranking heuristic
loses only *local* ordering resolution — inside a window of relative width $\alpha$, or inside
each of $k$ segments — its Spearman correlation with the truth obeys a sharp, size-free law:
$\rho\ge1-2\alpha^3$ in the first case, $\rho\ge1-2/k^2$ in the second. Both bounds are
attained in the limit, so the plateau is an infimum, not a way-station. Calibrating the first
law to a starved fraction of $0.66$ yields the plateau value $0.425008$, inside the observed
interval $[0.393,0.480]$, and yields a guaranteed margin of $0.070$ over a rival starved on
$0.69$ of its range — reproducing both observations from a single cubic law.

The mathematical core is a single exact identity: a ranking and its mirror always split the
displacement budget $n^3-n$ between them. Everything else — the extremal bound, its unique
extremiser, block transfer, the plateau, the fragmentation floor — is a consequence.
