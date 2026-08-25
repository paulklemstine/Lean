# Thin-Shell Counting under a Thickness Budget

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

The *equal-volume peeling* of the Euclidean ball $B(0,R) \subset \mathbb{R}^d$ into $N$ shells is the family of radii $r_k = R(1-k/N)^{1/d}$, $0 \le k \le N$, which divides the ball into $N$ regions of identical volume. Although the shells have equal volume, their geometric thicknesses $t_k = r_k - r_{k+1}$ are wildly unequal: they grow monotonically towards the centre, from thin skins near the boundary to a fat innermost core. Fixing a *thickness budget* $\delta > 0$, we determine completely the structure of the set of shells that violate the budget.

We prove: (i) a renormalisation identity showing that the tail of a peeling is again a peeling, so that every outer-shell estimate transfers to every shell; (ii) a two-sided per-shell sandwich $R/(dN) \le t_k \le R/(d(N-k-1))$; (iii) that the innermost shell is the thickest, with $t_{N-1} = R N^{-1/d}$ exactly, whence *all shells respect the budget if and only if $N \ge (R/\delta)^d$*, the least admissible number of shells being exactly $\max\{1,\lceil (R/\delta)^d \rceil\}$; (iv) that the shells violating the budget form a terminal block $[k_0, N)$; (v) the uniform counting bound $\#\{k : t_k > \delta\} \le 1 + R/(d\delta)$, together with a matching lower bound showing that the supremum over $N$ of this count is $\Theta(R/(d\delta))$; (vi) a two-sided decay law $(m-1)^{d-1} N \le (R/(d\delta))^d$ and its converse, which together pin the count to within one for every $N$; and (vii) that the base-two logarithm of the least admissible $N$ lies in $[\,d\log_2(R/\delta),\ d\log_2(R/\delta)+1\,]$.

Consequences: the conjecture that the number of budget-violating shells is $O(d\log(R/\delta))$ is **false** — the true order $\Theta(R/(d\delta))$ is polynomial in $1/\delta$ and *decreasing* in the dimension — and the conjecture that the thin-shell threshold grows like $(1-\delta/R)^{-d}$ is **false**, the correct base being $R/\delta$. The expression $d\log(R/\delta)$ nevertheless has an exact meaning in this problem: it is the bit cost of indexing a budget-respecting peeling. The qualitative slogan "exponentially many skins, boundedly many thick layers" survives with corrected constants, and quantifies the collapse of an equal-volume peeling onto the boundary sphere.

**Keywords:** equal-volume peeling, thin-shell phenomenon, concentration of measure, high-dimensional geometry, radial quantisation, Bernoulli's inequality, uniform sampling in a ball.

---

## 1. Introduction

### 1.1 Motivation

Turning a continuous region into a finite partition is a basic operation in randomised computation. When the region is a Euclidean ball and the objective is *unbiased sampling*, the natural partition is one into pieces of equal volume: a uniform random index then selects a piece with the correct marginal probability, and only the within-piece distribution has to be handled. For a ball, the rotationally symmetric partition of this kind is unique, and it is the *equal-volume peeling*.

Its defining property, however, controls only volume; it says nothing about *shape*. The metric quality of the partition — how well a point is localised once its shell index is known — is measured by the geometric thickness of the shells, and this quantity is very far from uniform. It is the interplay between the volumetric regularity of the peeling and the metric irregularity of its layers that this paper quantifies.

The concrete question is the following. Fix a *thickness budget* $\delta > 0$, thought of as a resolution requirement. How many shells does one need before every shell is thinner than $\delta$? And if one uses fewer, how many shells violate the budget, where are they, and how does their number vary with $N$?

### 1.2 Results and organisation

Section 2 fixes notation. Section 3 establishes the two structural pillars: the renormalisation identity (Theorem 3.1) and the two-sided per-shell sandwich (Theorem 3.5, Theorem 3.6). Section 4 identifies the extremal shell and derives the exact thin-shell threshold $N \ge (R/\delta)^d$ (Theorem 4.3). Section 5 proves the terminal-block structure theorem (Theorem 5.2) and the uniform counting bound $\le 1 + R/(d\delta)$ (Theorem 5.3), together with its sharpness (Theorem 5.5). Section 6 gives the decay law in $N$ and the pinning theorem (Theorems 6.2–6.4). Section 7 refutes the two conjectures (Theorems 7.1, 7.2) and locates the expression $d\log(R/\delta)$ as a bit cost (Theorem 7.3). Section 8 treats the degenerate dimension $d = 1$. Section 9 records algorithms, Section 10 numerical evidence, Section 11 applications, Section 12 discussion and open problems.

### 1.3 Summary of the main quantitative picture

With $T(R,d,N,\delta) = \#\{k < N : t_k > \delta\}$:

| quantity | exact answer |
|---|---|
| thickness of the $k$-th shell | $R\big[\big(\tfrac{N-k}{N}\big)^{1/d} - \big(\tfrac{N-k-1}{N}\big)^{1/d}\big]$ |
| thickest shell | innermost, $t_{N-1} = R\,N^{-1/d}$ |
| all shells thin | $\iff N \ge (R/\delta)^d$ |
| least admissible $N$ | $\max\{1,\lceil (R/\delta)^d\rceil\}$ |
| bits to index it | $d\log_2(R/\delta) + O(1)$, with $O(1) \in [0,1]$ |
| location of thick shells | a terminal block $[k_0,N)$ |
| $\sup_N T$ | $\Theta\big(R/(d\delta)\big)$ |
| $T$ for given $N$ ($d \ge 2$) | determined to within $1$ by $(R/(d\delta))^d / N$ |

---

## 2. Setting and definitions

Throughout, $R > 0$ is a radius, $d \ge 1$ an integer dimension, $N \ge 1$ an integer number of shells, and $\delta > 0$ a thickness budget.

**Definition 2.1 (Shell radii).** The *equal-volume peeling* of $B(0,R) \subset \mathbb{R}^d$ into $N$ shells is determined by the radii
$$r_k \;=\; r_k(R,d,N) \;=\; R\left(1 - \frac{k}{N}\right)^{1/d}, \qquad k = 0,1,\dots,N,$$
where the base is understood as $\max\{0, 1-k/N\}$. Thus $r_0 = R$ and $r_N = 0$.

The name is justified by the elementary computation $\mathrm{vol}\,B(0,r) = \omega_d r^d$, so
$$\mathrm{vol}\,B(0,r_k) \;=\; \omega_d R^d\left(1-\frac{k}{N}\right) \;=\; \left(1-\frac{k}{N}\right)\mathrm{vol}\,B(0,R),$$
and the $k$-th shell $S_k = \{x : r_{k+1} \le |x| \le r_k\}$ has volume exactly $\mathrm{vol}\,B(0,R)/N$, independently of $k$.

**Definition 2.2 (Shell thickness).** The thickness of the $k$-th shell is
$$t_k \;=\; t_k(R,d,N) \;=\; r_k - r_{k+1}.$$

**Definition 2.3 (Thick-shell count).** For a budget $\delta > 0$,
$$T(R,d,N,\delta) \;=\; \#\{\, k \in \{0,\dots,N-1\} : t_k > \delta \,\}.$$
A shell is *thick* if $t_k > \delta$ and *thin* otherwise.

**Lemma 2.4 (Closed form).** For $k < N$,
$$t_k \;=\; R\left[\left(\frac{N-k}{N}\right)^{1/d} - \left(\frac{N-k-1}{N}\right)^{1/d}\right].$$

*Proof.* Immediate from Definitions 2.1 and 2.2 after writing $1-k/N = (N-k)/N$, which is nonnegative for $k \le N$. $\square$

It is convenient to index shells by their *inner depth* $j = N-k \in \{1,\dots,N\}$, so that $j=1$ is the innermost shell and $j = N$ the outermost. In this variable
$$t_{N-j} \;=\; R\,N^{-1/d}\left[j^{1/d} - (j-1)^{1/d}\right], \tag{2.1}$$
a formula that already displays every feature proved below: the bracket is decreasing in $j$ (so thickness increases inwards), equals $1$ at $j=1$ (giving the innermost thickness $RN^{-1/d}$), and behaves like $\tfrac1d j^{1/d - 1}$ for large $j$ (giving the sandwich).

**Convention.** All results below assume $R > 0$ (or $R \ge 0$ where the statement is a bound), $d \ge 1$, $\delta > 0$, and $N \ge 1$; hypotheses are restated where they matter.

---

## 3. Two structural pillars

### 3.1 Renormalisation

**Theorem 3.1 (Self-similarity of the peeling).** For every $k < N$,
$$r_{k+1}(R,d,N) \;=\; r_1\big(r_k(R,d,N),\, d,\, N-k\big).$$
That is, the tail $r_k, r_{k+1},\dots,r_N$ of the equal-volume peeling of $B(0,R)$ into $N$ shells *is* the equal-volume peeling of $B(0,r_k)$ into $N-k$ shells.

*Proof.* Both sides are nonnegative, so it suffices to compare them directly:
$$r_{k+1} = R\left(\frac{N-k-1}{N}\right)^{1/d} = R\left(\frac{N-k}{N}\right)^{1/d}\left(\frac{N-k-1}{N-k}\right)^{1/d} = r_k\left(1 - \frac{1}{N-k}\right)^{1/d},$$
where the middle step uses multiplicativity of $x \mapsto x^{1/d}$ on nonnegative reals, and the right-hand side is by definition the first shell radius of the peeling of $B(0,r_k)$ into $N-k$ shells. $\square$

**Remark 3.2.** Theorem 3.1 is the reason a *single* theorem about the outermost shell suffices to control every shell. It expresses that an equal-volume peeling is a self-similar object: removing the outer $k$ layers leaves a smaller ball, peeled by the same rule. Conceptually, all subsequent estimates are the outermost-shell estimate composed with a rescaling.

### 3.2 The analytic input

All bounds below rest on finite-difference forms of the identity $\frac{d}{dx}x^{1/d} = \frac{x^{1/d}}{dx}$, valid because $x \mapsto x^{1/d}$ is concave for $d \ge 1$.

**Lemma 3.3 (Two-sided derivative bound).** Let $d \ge 1$ and $0 < b \le a$. Then
$$\frac{a-b}{d\,a}\;a^{1/d} \;\le\; a^{1/d} - b^{1/d} \;\le\; \frac{a-b}{d\,b}\;b^{1/d}.$$

*Proof.* Both inequalities are homogeneous of degree $1/d$, so we may divide through by $a^{1/d}$ and set $u = (b/a)^{1/d} \in (0,1]$, whereupon $b/a = u^{d}$ and the two claims become
$$\frac{1-u^{d}}{d} \;\le\; 1-u \qquad\text{and}\qquad 1-u \;\le\; \frac{1-u^{d}}{d\,u^{d}}\,u \;=\;\frac{1-u^{d}}{d\,u^{d-1}} .$$
Both are Bernoulli's inequality in the two-sided form
$$d\,u^{d-1}(1-u) \;\le\; 1 - u^{d} \;\le\; d\,(1-u), \qquad u \in [0,1], \tag{3.1}$$
which follows from the factorisation $1-u^{d} = (1-u)\big(1+u+\cdots+u^{d-1}\big)$ together with the elementary estimate $d\,u^{d-1} \le 1+u+\cdots+u^{d-1} \le d$, valid for $u \in [0,1]$. $\square$

**Lemma 3.4 (Subadditivity of the $d$-th root).** For $d \ge 1$ and $0 \le b \le a$,
$$a^{1/d} \;\le\; b^{1/d} + (a-b)^{1/d}.$$

*Proof.* The map $x \mapsto x^{1/d}$ is concave on $[0,\infty)$ with value $0$ at $0$, hence subadditive. $\square$

### 3.3 The per-shell sandwich

**Theorem 3.5 (Uniform lower bound).** For every $k < N$,
$$t_k \;\ge\; \frac{R}{dN}.$$
No shell of an equal-volume peeling is thinner than the average value $R/(dN)$ predicted by the $1/d$ scaling.

*Proof.* Write $a = (N-k)/N$ and $b = (N-k-1)/N$, so $0 \le b < a \le 1$ and $a - b = 1/N$. By Lemma 2.4, $t_k = R(a^{1/d}-b^{1/d})$. The left inequality of Lemma 3.3 (extended to $b = 0$ by continuity) gives
$$a^{1/d} - b^{1/d} \;\ge\; \frac{a-b}{d\,a}\,a^{1/d} \;=\; \frac{a^{1/d}}{a}\cdot\frac{1}{dN} \;\ge\; \frac{1}{dN},$$
using $a^{1/d} \ge a$ for $a \in (0,1]$ and $d \ge 1$. Multiplying by $R$ finishes the proof. $\square$

**Theorem 3.6 (Upper bound away from the centre).** For every $k$ with $k+1 < N$,
$$t_k \;\le\; \frac{R}{d\,(N-k-1)}.$$

*Proof.* By Theorem 3.1 the $k$-th shell is the outermost shell of the peeling of $B(0,r_k)$ into $M = N-k \ge 2$ shells, so
$$t_k \;=\; r_k\left[1 - \left(1-\frac1M\right)^{1/d}\right].$$
Apply the right inequality of Lemma 3.3 with $a = 1$, $b = 1-1/M$:
$$1 - \left(1-\frac1M\right)^{1/d} \;\le\; \frac{1/M}{d(1-1/M)}\left(1-\frac1M\right)^{1/d} \;\le\; \frac{1}{d(M-1)} .$$
Finally $r_k \le R$. $\square$

**Corollary 3.7 (The dichotomy).** A shell can be thick only if it is close to the centre: if $t_k > \delta$ and $k+1 < N$, then $N - k - 1 < R/(d\delta)$.

Corollary 3.7 is precisely the input the counting argument of Section 5 requires.

---

## 4. The extremal shell and the exact threshold

**Theorem 4.1 (The innermost shell is the thickest).** For every $k < N$,
$$t_k \;\le\; R\,N^{-1/d},$$
and equality holds for $k = N-1$; explicitly,
$$t_{N-1} \;=\; R\,N^{-1/d}.$$

*Proof.* With $a = (N-k)/N$, $b = (N-k-1)/N$ we have $a - b = 1/N$, and Lemma 3.4 gives $a^{1/d} \le b^{1/d} + N^{-1/d}$, i.e. $t_k = R(a^{1/d}-b^{1/d}) \le R\,N^{-1/d}$. For $k = N-1$ we have $r_N = 0$ and $r_{N-1} = R(1/N)^{1/d}$, so $t_{N-1} = R\,N^{-1/d}$ exactly. $\square$

**Theorem 4.2 (All-thin criterion).** For $N \ge 1$,
$$\big(\forall k < N:\ t_k \le \delta\big) \iff R\,N^{-1/d} \le \delta .$$

*Proof.* ($\Rightarrow$) Take $k = N-1$ and use Theorem 4.1. ($\Leftarrow$) Every $t_k$ is dominated by $RN^{-1/d}$ by Theorem 4.1. $\square$

**Theorem 4.3 (Exact thin-shell threshold).** Let $R,\delta > 0$, $d \ge 1$, $N \ge 1$. Then
$$\big(\forall k < N:\ t_k \le \delta\big) \iff N \;\ge\; \left(\frac{R}{\delta}\right)^{d}.$$

*Proof.* By Theorem 4.2 the condition is $R N^{-1/d} \le \delta$. Both sides are positive; raising to the $d$-th power (a strictly increasing operation on $[0,\infty)$) gives $R^d/N \le \delta^d$, i.e. $N \ge (R/\delta)^d$. $\square$

**Corollary 4.4 (Least admissible number of shells).** The set $\{N \ge 1 : \text{every shell of the } N\text{-shell peeling is} \le \delta \text{ thick}\}$ has least element
$$N_{\min}(R,d,\delta) \;=\; \max\big\{1,\ \lceil (R/\delta)^d \rceil\big\}.$$

*Proof.* Membership: $\max\{1,\lceil x\rceil\} \ge x$ for every real $x$, so Theorem 4.3 applies. Minimality: any admissible $N$ satisfies $N \ge 1$ and $N \ge (R/\delta)^d$, hence $N \ge \lceil (R/\delta)^d\rceil$. $\square$

**Remark 4.5.** Theorem 4.3 is an *exact* threshold, not an estimate: the criterion is a single inequality with no constants. The number of shells required is exponential in the dimension with base $R/\delta$ — the "exponentially many skins" of the informal picture — and the exponential is unavoidable, since it is the exact answer rather than an upper bound.

---

## 5. Structure and counting

### 5.1 Monotonicity and the terminal block

**Theorem 5.1 (Thicknesses increase inwards).** For $k+1 < N$, $t_k \le t_{k+1}$. Consequently $t_j \le t_k$ whenever $j \le k < N$.

*Proof.* By (2.1), $t_{N-j} = RN^{-1/d}\big[j^{1/d}-(j-1)^{1/d}\big]$, and the bracket is a first difference of the concave function $x \mapsto x^{1/d}$, hence nonincreasing in $j$. Since $k \mapsto N-k$ reverses order, $t_k$ is nondecreasing in $k$. $\square$

**Theorem 5.2 (Terminal-block structure).** For every $R \ge 0$, $d \ge 1$, $N \ge 1$, $\delta$ there exists $k_0 \le N$ such that for all $k < N$,
$$t_k > \delta \iff k \ge k_0,$$
and consequently
$$T(R,d,N,\delta) \;=\; N - k_0.$$
The shells violating the budget are exactly the innermost $N-k_0$ of them; they are never scattered.

*Proof.* If no shell is thick take $k_0 = N$. Otherwise let $k_0$ be the least thick index. If $k \ge k_0$ then $t_k \ge t_{k_0} > \delta$ by Theorem 5.1, so $k$ is thick; conversely if $k$ is thick then $k \ge k_0$ by minimality. The counted set is therefore the interval $\{k_0,\dots,N-1\}$, of cardinality $N-k_0$. $\square$

### 5.2 The uniform counting bound

**Theorem 5.3 (Counting theorem).** Let $R \ge 0$, $\delta > 0$, $d \ge 1$. Then for every $N$,
$$T(R,d,N,\delta) \;\le\; 1 + \frac{R}{d\,\delta}.$$
The bound is uniform in $N$.

*Proof.* Let $c = \lfloor R/(d\delta)\rfloor + 1$, so that $R/(d\delta) < c$ and hence $R/(dc) < \delta$. We claim every thick index $k$ satisfies $k \ge N-c$. Suppose not: then $k + c + 1 \le N$, so in particular $k+1 < N$ and $N-k-1 \ge c$, whence by Theorem 3.6
$$t_k \;\le\; \frac{R}{d(N-k-1)} \;\le\; \frac{R}{dc} \;<\; \delta,$$
contradicting thickness. Therefore the thick indices lie in $[N-c, N)$, a set of at most $c$ elements, and
$$T \;\le\; c \;=\; \lfloor R/(d\delta)\rfloor + 1 \;\le\; \frac{R}{d\delta} + 1. \qquad\square$$

**Remark 5.4.** The shape of the bound deserves emphasis. It is $\Theta(1/\delta)$ in the budget — polynomial, not logarithmic — and it *decreases* in the dimension $d$. Both features contradict the naive expectation and both are correct, as the next theorem shows.

### 5.3 Sharpness

**Theorem 5.5 (All shells thick for a small budget).** If $\delta < R/(dN)$ then every one of the $N$ shells is thick, i.e. $T(R,d,N,\delta) = N$.

*Proof.* Immediate from the uniform lower bound $t_k \ge R/(dN)$ of Theorem 3.5. $\square$

**Theorem 5.6 (Matching lower bound).** For all $R,\delta > 0$ and $d \ge 1$ there exists $N \ge 1$ with
$$T(R,d,N,\delta) \;\ge\; \frac{R}{2d\delta} - 1 .$$

*Proof.* Put $B = R/(2d\delta)$. If $\lfloor B\rfloor = 0$ then $B < 1$ and the claim is trivial since $T \ge 0 > B - 1$. Otherwise take $N = \lfloor B\rfloor \ge 1$. Then $N \le B$, so $dN\delta \le dB\delta = R/2 < R$, i.e. $\delta < R/(dN)$, and Theorem 5.5 gives $T = N \ge B - 1$. $\square$

**Corollary 5.7 (Exact order of the worst case).** For fixed $R,\delta,d$,
$$\frac{R}{2d\delta} - 1 \;\le\; \sup_{N \ge 1} T(R,d,N,\delta) \;\le\; 1 + \frac{R}{d\delta},$$
so $\sup_N T = \Theta\big(R/(d\delta)\big)$, with the implied constants absolute.

### 5.4 The structure theorem

Assembling Theorems 4.3, 5.2 and 5.3:

**Theorem 5.8 (Structure of a peeling under a budget).** Let $R,\delta > 0$, $d \ge 1$, $N \ge 1$. There is a threshold index $k_0 \le N$ such that:

1. a shell is thick if and only if its index is $\ge k_0$ (an outer block of thin skins, an inner block of thick layers);
2. the inner block has at most $1 + R/(d\delta)$ members: $N - k_0 \le 1 + R/(d\delta)$;
3. the inner block is empty as soon as $N \ge (R/\delta)^d$.

In particular, the fraction of the ball's volume occupied by budget-violating shells is $(N-k_0)/N \le (1 + R/(d\delta))/N$, which tends to $0$ as $N$ grows and vanishes identically at $N = \lceil (R/\delta)^d\rceil$.

---

## 6. The profile in $N$: decay and pinning

Theorem 5.3 is uniform in $N$ and Corollary 5.7 says it is attained — but only near one particular value of $N$. The following results describe the entire profile.

**Lemma 6.1 (Depth form of the sandwich).** For the shell of inner depth $j = N-k \in \{1,\dots,N\}$,
$$\frac{R}{d\,j}\left(\frac{j}{N}\right)^{1/d} \;\le\; t_{N-j} \;\le\; \frac{R}{d\,(j-1)}\left(\frac{j-1}{N}\right)^{1/d} \quad (j \ge 2).$$

*Proof.* Apply Lemma 3.3 with $a = j/N$, $b = (j-1)/N$, $a-b = 1/N$, and multiply by $R$; use Lemma 2.4. $\square$

**Theorem 6.2 (Decay of the thick block).** Let $R,\delta > 0$, $d \ge 1$, and suppose $m = T(R,d,N,\delta) \ge 2$. Then
$$(m-1)^{\,d-1}\,N \;\le\; \left(\frac{R}{d\,\delta}\right)^{d}.$$

*Proof.* By Theorem 5.2 the thick shells are those of inner depth $1,\dots,m$; in particular the shell of depth $j = m$ is thick, so by the upper bound of Lemma 6.1 (legitimate since $m \ge 2$),
$$\delta \;<\; t_{N-m} \;\le\; \frac{R}{d(m-1)}\left(\frac{m-1}{N}\right)^{1/d} \;=\; \frac{R}{d}\,(m-1)^{\frac1d - 1}\,N^{-\frac1d}.$$
Raising to the $d$-th power gives $\delta^d < (R/d)^d (m-1)^{1-d} N^{-1}$, i.e. $(m-1)^{d-1}N \le (R/(d\delta))^d$. $\square$

**Theorem 6.3 (Converse: forcing thick shells).** Let $R,\delta > 0$, $d \ge 1$, and let $1 \le j \le N$ satisfy
$$j^{\,d-1}\,N \;<\; \left(\frac{R}{d\,\delta}\right)^{d}.$$
Then $T(R,d,N,\delta) \ge j$.

*Proof.* By the lower bound of Lemma 6.1, the shell of inner depth $j$ has
$$t_{N-j} \;\ge\; \frac{R}{d}\,j^{\frac1d-1}N^{-\frac1d},$$
and the hypothesis, after taking $d$-th roots, says exactly that this quantity exceeds $\delta$. So that shell is thick; by Theorem 5.2 so is every shell of smaller depth, giving at least $j$ thick shells. $\square$

**Theorem 6.4 (Pinning to within one).** Let $R,\delta > 0$, $d \ge 1$, and let $1 \le j$ with $j+1 \le N$ satisfy
$$j^{\,d-1}N \;<\; \left(\frac{R}{d\delta}\right)^{d} \;<\; (j+1)^{\,d-1}N .$$
Then
$$j \;\le\; T(R,d,N,\delta) \;\le\; j+1 .$$

*Proof.* The lower bound is Theorem 6.3. For the upper bound suppose $m = T \ge j+2$. Then $m \ge 2$, so Theorem 6.2 gives $(m-1)^{d-1}N \le (R/(d\delta))^d$; but $m - 1 \ge j+1$ and $x \mapsto x^{d-1}$ is nondecreasing on $[0,\infty)$, so $(j+1)^{d-1}N \le (R/(d\delta))^d$, contradicting the right-hand hypothesis. $\square$

**Remark 6.5 (Interpretation).** For $d \ge 2$, Theorem 6.4 determines the thick-shell count to within a single shell from the single scalar
$$\rho \;=\; \frac{(R/(d\delta))^d}{N}, \qquad\text{via}\qquad T \approx \rho^{1/(d-1)} .$$
Thus the thick block decays like $N^{-1/(d-1)}$, and reaches $0$ at $N = (R/\delta)^d$, in agreement with Theorem 4.3. For $d = 1$ the exponent degenerates: Theorem 6.2 reads $N \le R/\delta$, which is the correct statement (see Section 8).

---

## 7. Two refutations, and where $d\log(R/\delta)$ really lives

Two natural conjectures accompany the informal picture "exponentially many skins plus boundedly many thick layers". Both are false, and both fail by getting the dependence on the dimension backwards.

**Theorem 7.1 (The count is not $O(d\log(R/\delta))$).** For every constant $C > 0$ and every dimension $d \ge 1$ there exist $N \ge 1$ and $\delta \in (0,1)$ with
$$C\,d\,\log\frac{1}{\delta} \;<\; T(1,d,N,\delta).$$
Hence no bound of the form $T = O(d\log(R/\delta))$ holds uniformly in $N$.

*Proof.* Set $A = Cd$. Choose $N$ so large that
$$2A\big(\log(2d) + \log(2A)\big) \;<\; N,$$
and put $\delta = 1/(2dN) \in (0,1)$. Since $\delta < 1/(dN) = R/(dN)$ with $R=1$, Theorem 5.5 gives $T = N$. It therefore suffices to show $A\log(2dN) < N$. Split $\log(2dN) = \log(2d) + \log N$ and use $\log x \le x - 1$ in the form
$$\log N \;=\; \log(2A) + \log\frac{N}{2A} \;\le\; \log(2A) + \frac{N}{2A} - 1 .$$
Multiplying by $A$ gives $A\log N \le A\log(2A) + N/2 - A$, so
$$A\log(2dN) \;\le\; A\log(2d) + A\log(2A) + \frac{N}{2} - A \;<\; \frac{N}{2} + \frac{N}{2} \;=\; N,$$
the last step by the choice of $N$. $\square$

**Remark.** The failure is not a matter of constants. The true order $\Theta(R/(d\delta))$ is *polynomial* in $1/\delta$ where the conjecture is logarithmic, and it is *decreasing* in $d$ where the conjecture is increasing. In the regime $d^2\log(R/\delta) > R/\delta$ the conjectured expression is an overestimate; in the complementary low-dimension, small-budget regime it is a gross underestimate.

**Theorem 7.2 (The threshold base is $R/\delta$, not $(1-\delta/R)^{-1}$).** For every constant $C$ there is a dimension $d \ge 1$ with
$$C\left(1 - \frac{\delta}{R}\right)^{-d} \;<\; \left(\frac{R}{\delta}\right)^{d} \qquad\text{at } \delta = R/4 .$$

*Proof.* At $\delta = R/4$ the two bases are $(1-1/4)^{-1} = 4/3$ and $R/\delta = 4$. Choose $m$ with $C < 3^m$ (possible since $3^m \to \infty$); then for $d = m+1$,
$$C\left(\frac43\right)^{d} \;<\; 3^{d}\left(\frac43\right)^{d} \;=\; 4^{d}. \qquad\square$$

Thus the least admissible number of shells is $\Theta^*\big((R/\delta)^d\big)$, not $\Theta^*\big((1-\delta/R)^{-d}\big)$; the two guesses coincide only in the degenerate case $\delta = R/2$, where $R/\delta = 2 = (1-\delta/R)^{-1}$.

The expression $d\log(R/\delta)$ is nevertheless exactly right — for a different question.

**Theorem 7.3 (Bit cost of a budget-respecting peeling).** Let $0 < \delta \le R$ and $d \ge 1$, and let $N_{\min} = \max\{1,\lceil (R/\delta)^d\rceil\}$ be the least admissible number of shells (Corollary 4.4). Then
$$d\,\log_2\frac{R}{\delta} \;\le\; \log_2 N_{\min} \;\le\; d\,\log_2\frac{R}{\delta} + 1 .$$

*Proof.* Write $x = (R/\delta)^d \ge 1$, so $N_{\min} = \lceil x\rceil$ and $\log_2 x = d\log_2(R/\delta)$. The lower bound is $x \le \lceil x\rceil$ and monotonicity of $\log_2$. For the upper bound, $\lceil x \rceil < x + 1 \le 2x$ because $x \ge 1$, so $\log_2\lceil x\rceil \le \log_2 2 + \log_2 x = 1 + d\log_2(R/\delta)$. $\square$

**Corollary 7.4.** Indexing the shells of a budget-respecting equal-volume peeling costs $d\log_2(R/\delta) + O(1)$ bits, with the $O(1)$ lying in $[0,1]$. This — a *storage* cost, one $\log_2(R/\delta)$-bit word per dimension — is the correct home of the expression appearing in the false counting conjecture.

---

## 8. The degenerate dimension

**Theorem 8.1 (Uniform peeling in dimension one).** For $d = 1$ and every $k < N$, $t_k = R/N$.

*Proof.* By Lemma 2.4 with $1/d = 1$, $t_k = R\big[(N-k)/N - (N-k-1)/N\big] = R/N$. $\square$

**Theorem 8.2 (All-or-nothing).** For $d = 1$,
$$T(R,1,N,\delta) \;=\; \begin{cases} N, & \delta < R/N,\\ 0, & \delta \ge R/N.\end{cases}$$

*Proof.* Immediate from Theorem 8.1. $\square$

Dimension one therefore realises both extremes of the terminal-block dichotomy of Theorem 5.2 ($k_0 = 0$ and $k_0 = N$), showing that no intermediate structure can be forced in general. It is also consistent with the other results: Theorem 4.3 reads $N \ge R/\delta$, Theorem 5.3 reads $T \le 1 + R/\delta$, and Theorem 6.2 reads $N \le R/\delta$ — all sharp.

---

## 9. Algorithms

The theory yields three algorithms of practical interest; all operate in $O(1)$ or $O(\log N)$ arithmetic operations, never $O(N)$.

### 9.1 Least admissible shell count

**Input:** $R > 0$, $d \ge 1$, $\delta > 0$. **Output:** $N_{\min} = \max\{1,\lceil (R/\delta)^d\rceil\}$.
Complexity: $O(1)$ arithmetic operations (one power). By Corollary 4.4 the output is *exact*, not an estimate. Its bit length is $d\log_2(R/\delta) + O(1)$ by Theorem 7.3, which is the correct measure of the cost in practice.

### 9.2 Thick-shell count in $O(\log N)$

Naively, computing $T$ costs $O(N)$ thickness evaluations. Theorem 5.2 replaces this by a binary search: thickness is monotone in the index, so the predicate "$t_k > \delta$" is monotone, and its threshold $k_0$ can be located in $O(\log N)$ evaluations. Equivalently, by (2.1) one may solve
$$R N^{-1/d}\big[j^{1/d} - (j-1)^{1/d}\big] > \delta$$
for the largest admissible depth $j$. The result is exactly $T$. Theorem 6.4 provides an $O(1)$ *approximation* accurate to within one shell, namely the unique $j$ with $j^{d-1}N < (R/(d\delta))^d < (j+1)^{d-1}N$, which serves as an excellent starting point for the search.

### 9.3 Budget-aware radial quantiser

Given a target resolution $\delta$ and a shell budget $N$ that may be smaller than $N_{\min}$, the following procedure produces a partition of $B(0,R)$ that is equal-volume on the outside and refined on the inside:

1. compute the threshold $k_0$ by the search of §9.2;
2. keep the shells $0,\dots,k_0-1$ as they are (all are $\le \delta$ thick);
3. recursively re-peel the inner ball $B(0,r_{k_0})$ — legitimate by Theorem 3.1, since the tail of a peeling is a peeling — with enough shells to meet the budget, namely $\lceil (r_{k_0}/\delta)^d\rceil$ of them.

By Theorem 5.8 the recursion is applied to at most $1 + R/(d\delta)$ shells' worth of volume, i.e. a fraction $\le (1 + R/(d\delta))/N$ of the ball, so the refinement is cheap whenever $N$ is large.

---

## 10. Numerical evidence

All computations use $R = 1$ and double-precision arithmetic.

**Two-sided sandwich ($d=4$, $N=12$).** The measured thicknesses $t_0,\dots,t_{11}$ are
$$0.0215,\ 0.0230,\ 0.0248,\ 0.0270,\ 0.0297,\ 0.0330,\ 0.0375,\ 0.0436,\ 0.0527,\ 0.0682,\ 0.1017,\ 0.5373,$$
monotone increasing, all $\ge R/(dN) = 0.02083$ and all $\le R/(d(N-k-1))$. The innermost equals $12^{-1/4} = 0.53728\ldots$, confirming Theorem 4.1.

**Exact threshold (Corollary 4.4).** Brute-force search for the least $N$ with all shells thin returns: $d=3,\delta=1/4 \mapsto 64 = 4^3$; $d=4,\delta=1/2 \mapsto 16 = 2^4$; $d=2,\delta=1/5 \mapsto 25 = 5^2$; $d=5,\delta=1/2 \mapsto 32 = 2^5$. Every value matches $\lceil (R/\delta)^d\rceil$ exactly.

**Counting bound and its sharpness.** For $\delta = 0.01$, the maximum of $T$ over $N \le 3000$ is $50$ for $d=2$, $20$ for $d=5$, $10$ for $d=10$. The prediction $R/(d\delta) = 100/d$ gives $50, 20, 10$: the bound of Theorem 5.3 is attained exactly, and the *decrease* in $d$ is unambiguous. For comparison, the conjectured $d\log(R/\delta)$ at $d = 10, \delta = 0.01$ is $\approx 46$, against a true maximum of $10$ — wrong by a factor of nearly five, and with the wrong sign in $d$.

**Profile in $N$ ($d=2$, $\delta=0.01$, so $(R/(d\delta))^d = 2500$).**

| $N$ | 10 | 25 | 50 | 100 | 200 | 400 | 1000 |
|---|---|---|---|---|---|---|---|
| $T$ | 10 | 25 | 50 | 25 | 13 | 6 | 3 |
| $(T-1)N$ | 90 | 600 | 2450 | 2400 | 2400 | 2000 | 2000 |

Every shell is thick until $N \approx R/(2d\delta) = 50$, after which the count decays; the quantity $(T-1)^{d-1}N$ never exceeds $2500$, and near the peak it is within $2\%$ of it. Theorem 6.2 is thus essentially an equality in the interesting range.

**Pinning ($d=3$, $\delta=0.02$).** For $N = 50, 100, 200, 500, 1000, 5000$ the measured counts are $10, 7, 5, 3, 2, 1$, and the windows $\{j,j+1\}$ predicted by Theorem 6.4 are $\{9,10\},\{6,7\},\{4,5\},\{3,4\},\{2,3\},\{1,2\}$. Every measured value lies in its window.

**Bit cost (Theorem 7.3).** For $(d,\delta) = (2,0.1), (5,0.05), (8,0.01), (16,0.001)$ the quantity $\log_2 N_{\min} - d\log_2(R/\delta)$ is $0.0000$ in each case (each $(R/\delta)^d$ happens to be an integer), well inside the guaranteed window $[0,1]$.

**Refutation (Theorem 7.1).** With $\delta = R/(2dN)$: at $d = 2, N = 2000$ the count is $2000$ against $d\ln(R/\delta) \approx 18$, a ratio of $111$; at $d = 10, N = 2000$ the count is $2000$ against $\approx 106$, a ratio of $19$. Increasing $N$ increases the ratio without bound.

---

## 11. Applications

### 11.1 Uniform sampling in a ball with a resolution guarantee

To sample uniformly from $B(0,R)$ using an equal-volume peeling one draws a shell index uniformly from $\{0,\dots,N-1\}$ — correct precisely because the shells have equal volume — and then samples within the chosen shell. The *radial resolution* of the resulting sampler is the thickness of the fattest shell, so Theorem 4.3 states the exact price of a resolution guarantee: $N \ge (R/\delta)^d$ shells, equivalently $d\log_2(R/\delta) + O(1)$ bits of shell index (Corollary 7.4). Because the threshold of Theorem 4.3 is an equivalence, this cost cannot be improved by a cleverer choice of equal-volume partition into concentric shells.

### 11.2 Graceful degradation under a shell budget

When the exponential cost of §11.1 is unaffordable one uses fewer shells, and Theorem 5.8 says the damage is localised: the offending shells form a single terminal block of at most $1 + R/(d\delta)$ members, concentrated at the origin, occupying a fraction $\le (1+R/(d\delta))/N$ of the volume. An implementation therefore knows exactly where its resolution guarantee fails — inside the ball $B(0, r_{k_0})$ — and can handle that region by a separate rule, recursively if desired (§9.3). The recursion is exact rather than approximate because of the renormalisation identity, Theorem 3.1.

### 11.3 Radial leakage and the boundary collapse

If an adversary observes only the shell index of a sample, it learns the radial coordinate to within $t_{k}$, and nothing else. Theorem 5.8 bounds the number of indices for which this localisation is worse than $\delta$, and Theorem 5.3 shows that this number *shrinks* as the dimension grows: high dimension is helpful here, not harmful. The underlying reason is the thin-shell phenomenon — almost all of the volume of a high-dimensional ball lies within $O(R/d)$ of the boundary — and the results above quantify it in the discrete, budgeted setting: the peeling collapses onto the boundary sphere, with $(R/\delta)^d$ skins doing the work and at most $\Theta(R/(d\delta))$ layers left over.

### 11.4 Discretisation of radially symmetric measures

Any radially symmetric probability measure on $B(0,R)$ can be discretised by transporting it to a peeling adapted to its radial CDF; the equal-volume peeling is the special case of the uniform measure. The analysis above is then a template: the extremal-shell principle (Theorem 4.1) reduces a global resolution requirement to a single scalar inequality, monotonicity (Theorem 5.1) turns the count into a threshold search, and the derivative sandwich (Lemma 3.3) converts the threshold into a closed-form estimate. Which of these steps survives for a general radial density is a natural question (§12).

---

## 12. Discussion and open problems

### 12.1 What is settled

For the equal-volume peeling of a ball under a thickness budget, the following are now exact or sharp up to explicit constants: the per-shell two-sided bounds; the extremal shell; the all-thin threshold (exact); the least admissible shell count (exact); the location of the violators (exact: a terminal block); the worst-case count over $N$ (sharp within a factor $2$); the count for each individual $N$ (sharp within $1$ additive shell for $d \ge 2$); and the bit cost (sharp within one bit).

Two conjectures are refuted, both by sign errors in the dimension: the number of violating shells is $\Theta(R/(d\delta))$, decreasing in $d$, not $O(d\log(R/\delta))$; and the thin-shell threshold has base $R/\delta$, not $(1-\delta/R)^{-1}$.

### 12.2 Open problems

**Problem 1 (Exact count formula).** Theorem 6.4 pins $T$ to within one. Is the exact value always
$$T \;=\; \max\Big\{\,m \in \{0,\dots,N\} \;:\; R\,N^{-1/d}\big(m^{1/d} - (m-1)^{1/d}\big) > \delta \,\Big\}\ ?$$
Formula (2.1) makes this a tautology once one knows the block is terminal, so the real content is a closed-form inversion of $m \mapsto m^{1/d}-(m-1)^{1/d}$ — equivalently, an exact description of when the pinning window $\{j,j+1\}$ resolves to $j$ and when to $j+1$.

**Problem 2 (Second-order asymptotics).** For $d \ge 2$ and $N \to \infty$ with $R,\delta,d$ fixed, is
$$T \;=\; \rho^{1/(d-1)} + c_d + o(1), \qquad \rho = \frac{(R/(d\delta))^d}{N},$$
for an explicit constant $c_d$? The numerics of Section 10 suggest a limit exists.

**Problem 3 (General radial measures).** Replace the uniform measure by a radial density $f$. The equal-mass peeling then has radii determined by the CDF, and thickness is $F^{-1}$-differences. For which $f$ do the terminal-block structure and the $\Theta(1/(d\delta))$ counting bound survive? Log-concavity of $f$ is the natural hypothesis, since it preserves the concavity of the relevant inverse.

**Problem 4 (Anisotropic bodies).** For a convex body $K$ in place of the ball, the equal-volume peeling by dilates $\lambda K$ has "thickness" that depends on direction. Is the Hausdorff distance between consecutive dilates still monotone inwards, and is the count of budget-violating layers still $O(\mathrm{diam}(K)/(d\delta))$? The renormalisation identity survives verbatim (dilates of dilates are dilates), so the obstruction is the derivative sandwich, not the structure.

**Problem 5 (Optimal non-equal-volume peelings).** Fix $N$ and minimise the maximal shell thickness over *all* increasing sequences $R = \rho_0 > \cdots > \rho_N = 0$, without the equal-volume constraint. The optimum is obviously the uniform peeling $\rho_k = R(1-k/N)$, with maximal thickness $R/N$; the interesting question is the trade-off curve between maximal thickness and maximal volume imbalance $\max_k \mathrm{vol}(S_k)/\min_k \mathrm{vol}(S_k)$. The results here give the two endpoints; the interior of the curve is open.

**Problem 6 (Sampling cost lower bound).** Corollary 7.4 gives the storage cost of a shell index. Is $d\log_2(R/\delta)$ also a lower bound on the *randomness* cost of any sampler on $B(0,R)$ achieving radial resolution $\delta$, over all partitions into measurable pieces of equal measure — not merely concentric shells?

### 12.3 Future directions

The single most useful next step is Problem 1: an exact formula for the thick-shell count would upgrade every result of Sections 5 and 6 from sharp-to-within-one to exact, and would make the $O(\log N)$ search of §9.2 an $O(1)$ evaluation. Problems 3 and 4 test how much of the theory is really about the ball, and how much is about concavity of the $d$-th root; the evidence of Section 3 is that concavity is the whole story, in which case both generalisations should go through with $x^{1/d}$ replaced by the appropriate inverse CDF or radial gauge.

---

## 13. Conclusion

An equal-volume peeling of a $d$-dimensional ball is a self-similar object whose layers grow monotonically thicker towards the centre. Under a thickness budget $\delta$ it splits cleanly into an outer stack of thin skins and an inner block of thick layers. The skins number $(R/\delta)^d$ when the budget is met exactly — an exponential in the dimension with base $R/\delta$, and the threshold is exact. The thick layers number at most $1 + R/(d\delta)$, always, and this order is attained; for each fixed $N$ their number is determined to within one by the ratio $(R/(d\delta))^d/N$, and they vanish abruptly at $N = (R/\delta)^d$.

Both features that make the picture memorable — the exponential and the boundedness — are genuine. Both natural quantitative guesses about them were wrong, and wrong in the same way: they reversed the role of the dimension. The correct statements say that high dimension *helps*: it multiplies the number of skins you need, and it divides the number of thick layers you are stuck with. The expression $d\log(R/\delta)$, which motivated the false conjecture, turns out to be the exact bit cost of writing down a shell index — a reminder that in high-dimensional geometry the right formula often answers a question adjacent to the one that was asked.
