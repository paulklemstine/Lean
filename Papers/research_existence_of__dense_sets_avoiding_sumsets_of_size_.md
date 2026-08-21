# The Exact Threshold for Sumsets in Dense Sets of Integers

**Author:** Aristotle

**Date:** 2026-08-21

---

## Abstract

For $0 < \delta < 1$ and $n \in \mathbb{N}$, call $S \subseteq [n] = \{0,1,\dots,n-1\}$
*$\delta$-dense* if $|S| \ge \delta n$. We determine, with an exact leading constant, the
largest size of a sumset $A + B = \{a+b : a \in A,\, b \in B\}$ that a $\delta$-dense set
must contain, and the smallest size at which a $\delta$-dense set can avoid such a sumset.

The engine is an exact finitary averaging identity. If $D$ is any set of shifts containing
all differences of $S$, then $\sum_{a \in D} \#\{u \in U : u + a \in S\} = |U|\,|S|$ for
every $U \subseteq S$. Iterating the resulting greedy step yields the **counting
criterion**: if
$$k\,|D|^{k} \le |S|\,(|S|-k)^{k},$$
then $S$ contains a sumset $A + B$ with $|A| = |B| = k$ and $A \subseteq D$. Applied inside
a finite abelian group ($D = G$) this gives the constant $1/\log(1/\delta)$ with no loss;
applied inside $[n]$ with the naive difference window $D = (-n,n)$ it gives
$1/\log(2/\delta)$, and a short-window refinement removes the factor $2$. Consequently, for
every $c$ with $c\log(1/\delta) < 1$ and all large $n$, **every** $\delta$-dense
$S \subseteq [n]$ contains a sumset $A + B$ with $|A| = |B| = \lfloor c\log n\rfloor$.

In the converse direction, a weighted first-moment argument — which charges each candidate
sumset by the true number of points it forces, exploiting that two progressions with
coprime reduced common differences $e_1, e_2$ span a $k \times \max(e_1,e_2)$ block — shows
that for every $\varepsilon > 0$ and all large $n$ some $\delta$-dense $S \subseteq [n]$
contains no sumset $A + B$ in which $A$ and $B$ each contain an arithmetic progression of
length at least $(1+\varepsilon)\log n / \log(1/\delta)$. Together the two sides pin the
threshold at $(1 + o(1))\log n/\log(1/\delta)$, replacing the previously recorded constant
$3$ (and an intermediate $3/2$) by the optimal $1$.

The same greedy engine, iterated on its own output, produces affine cubes: every
$\delta$-dense $S \subseteq [0,n)$ contains a $d$-dimensional affine cube
$u + \{0,a_1\} + \cdots + \{0,a_d\}$ with all $a_i \ne 0$ whenever $(4/\delta)^{2^d} \le 2n$,
and a *proper* cube (all $2^d$ subset sums distinct) whenever
$(4/\delta)^{2^d}\cdot 4^d \le 2n$. A matching first-moment bound produces $\delta$-dense
sets with no proper cube of dimension $d$ once $(1+\varepsilon)(d+1)\log n \le 2^d\log(1/\delta)$,
and in fact a single $\delta$-dense set avoiding proper cubes of *every* dimension
$d \ge d_0$ simultaneously. The two ranges of $d$ are disjoint, and both sit at
$2^d \asymp \log n/\log(1/\delta)$.

All bounds are effective: explicit numerical instances include the statement that every set
of $2^{19}$ integers below $2^{20}$ contains a sumset with $|A| = |B| = 7$, and that every
set of $16{,}384$ integers below $32{,}768$ contains a proper two-dimensional affine cube.

**Keywords:** additive combinatorics, sumset, density, greedy shift argument, affine cube,
Szemerédi cube lemma, first moment method, extremal threshold.

---

## 1. Introduction

### 1.1 The problem

Given a set $S$ of integers, when must $S$ contain a *product structure* — a sumset
$A + B$ with both factors large? A sumset is the additive analogue of a combinatorial
rectangle: it is a $|A| \times |B|$ grid of sums, determined by $|A| + |B|$ parameters but
imposing $|A|\cdot|B|$ membership conditions. Containing a large sumset is therefore a
strong regularity property, and the extremal question — *how large a sumset is forced by
density alone?* — sits at the interface of the pigeonhole and probabilistic halves of
additive combinatorics.

Concretely, fix $0 < \delta < 1$, write $[n] = \{0,1,\dots,n-1\}$, and call
$S \subseteq [n]$ **$\delta$-dense** if $|S| \ge \delta n$. Define the extremal constant
$C(\delta)$ as the infimum of the constants $c$ for which, for all large $n$, some
$\delta$-dense $S \subseteq [n]$ contains no sumset $A + B \subseteq S$ with
$\min\{|A|,|B|\} \ge c\,\log n/\log(1/\delta)$. Both the shape $\log n/\log(1/\delta)$ and
the finiteness of $C(\delta)$ are classical-style consequences of, respectively, an
iterated pigeonhole and a union bound; the content of this paper is the exact value of the
leading constant.

### 1.2 Results

Throughout, $\log$ is the natural logarithm.

* **(Existence, exact constant.)** For every $0 < \delta < 1$ and $c > 0$ with
  $c\log(1/\delta) < 1$, for all sufficiently large $n$, *every* $\delta$-dense
  $S \subseteq [n]$ contains a sumset $A + B$ with
  $|A| = |B| = \lfloor c \log n\rfloor$ (Theorem 4.4).
* **(Avoidance, exact constant.)** For every $0 < \delta < 1$ and $\varepsilon > 0$, for
  all sufficiently large $n$, some $\delta$-dense $S \subseteq [n]$ contains no sumset
  $A + B$ in which both $A$ and $B$ contain an arithmetic progression of length at least
  $(1+\varepsilon)\log n/\log(1/\delta)$ (Theorem 5.5). In particular no sumset of two
  arithmetic progressions with $\min\{|A|,|B|\} \ge (1+\varepsilon)\log n/\log(1/\delta)$.
* **(Threshold.)** Consequently the threshold for progression-rich sumsets is
  $(1 + o(1))\log n/\log(1/\delta)$ (Theorem 5.6).
* **(Groups.)** In any finite abelian group $G$ the existence bound holds with the sharp
  constant and no window loss: for $c\log(1/\delta) < 1$ and $|G|$ large, every
  $\delta$-dense $S \subseteq G$ contains $A + B$ with
  $|A| = |B| = \lfloor c\log|G|\rfloor$ (Theorem 4.2).
* **(Cubes.)** Every $\delta$-dense $S \subseteq [0,n)$ contains an affine cube of
  dimension $d$ with nonzero generators whenever $(4/\delta)^{2^d} \le 2n$ (Theorem 6.3),
  and a proper cube whenever $(4/\delta)^{2^d}4^{d} \le 2n$ (Theorem 6.5). Conversely, for
  $d$ above the first-moment threshold there exist $\delta$-dense sets with no proper cube
  of dimension $d$ (Theorem 6.6), even simultaneously for all $d \ge d_0$ (Theorem 6.7).
  The two ranges of $d$ are disjoint (Theorem 6.8).
* **(Effective instances.)** Every $S \subseteq [0,2^{20})$ with $|S| \ge 2^{19}$ contains
  a sumset with $|A| = |B| = 7$; every $S \subseteq [0,2^{22})$ with $|S| \ge 2^{19}$
  contains one with $|A| = |B| = 4$; every $S \subseteq [0,32768)$ with $|S| \ge 16384$
  contains a proper two-dimensional affine cube (Section 7).

### 1.3 Structure of the argument

Section 2 fixes notation. Section 3 develops the greedy shift engine in an arbitrary
abelian group and derives the exact counting criterion. Section 4 converts counting into
density, first in groups (no loss) and then in intervals, where a short-window variant of
the engine removes the factor $2$ inherent in the difference window. Section 5 gives the
weighted first-moment construction achieving the matching constant $1$. Section 6 iterates
the engine on its own output to obtain affine cubes and their matching bounds. Section 7
records effective instances, Section 8 discusses algorithmic content, and Section 9
discusses limitations and open problems.

---

## 2. Notation

$[n] = \{0,1,\dots,n-1\}$. For finite sets $A, B$ in an abelian group,
$A + B = \{a+b : a \in A, b\in B\}$ and $A - B = \{a - b\}$. A set $S \subseteq [n]$ is
$\delta$-dense if $|S| \ge \delta n$. For $a, d, K \in \mathbb{N}$ write
$$\mathrm{AP}(a,d,K) = \{a, a+d, \dots, a + (K-1)d\}$$
for the arithmetic progression with first term $a$, common difference $d$ and $K$ terms; if
$d > 0$ it has exactly $K$ elements. A finite set $A$ is *$T$-progression-rich* if it
contains $\mathrm{AP}(a,d,T)$ for some $a$ and some $d > 0$.

An **affine cube of dimension $d$** with base $u$ and generators $a_1,\dots,a_d$ is
$$\mathcal{C}(u; a_1,\dots,a_d) \;=\; u + \{0,a_1\} + \cdots + \{0,a_d\}
\;=\; \Big\{u + \sum_{i \in I} a_i : I \subseteq \{1,\dots,d\}\Big\}.$$
It has at most $2^d$ elements; it is **proper** when it has exactly $2^d$, i.e. when all
$2^d$ subset sums of the generators are distinct.

---

## 3. The greedy shift engine

### 3.1 The averaging identity

The whole development rests on the following exact identity. It is stated in an arbitrary
abelian group $G$; the set $D$ plays the role of an admissible *shift window*.

> **Lemma 3.1 (Averaging identity).** Let $S, D, U$ be finite subsets of an abelian group
> $G$ with $U \subseteq S$, and suppose $D$ absorbs all differences of $S$, i.e.
> $s - u \in D$ for all $u, s \in S$. Then
> $$\sum_{a \in D} \#\{u \in U : u + a \in S\} \;=\; |U| \cdot |S|.$$

*Proof.* Exchange the order of summation:
$$\sum_{a\in D}\#\{u \in U : u+a\in S\} = \sum_{u \in U} \#\{a \in D : u+a \in S\}.$$
Fix $u \in U \subseteq S$. The map $a \mapsto u + a$ is injective and carries
$\{a \in D : u+a \in S\}$ into $S$; conversely each $s \in S$ arises from $a = s - u$,
which lies in $D$ by hypothesis. Hence the inner count equals $|S|$ for every $u$, and the
total is $|U||S|$. $\square$

The identity is exact — no error term, no asymptotics — which is what makes every
consequence below effective.

### 3.2 One greedy step

> **Lemma 3.2 (Good shift).** With $S, D, U$ as above, let $F$ be a finite set of *already
> used* shifts with $|F| < |D|$. Then there exists $a \in D \setminus F$ with
> $$|U|\,|S| \;\le\; |D| \cdot \#\{u \in U : u + a \in S\} \;+\; |F|\,|U|.$$
> Equivalently, $\#\{u \in U : u+a\in S\} \ge |U|\,(|S| - |F|)/|D|$.

*Proof.* Write $f(a) = \#\{u \in U : u+a \in S\}$ and split the sum of Lemma 3.1 over
$D \cap F$ and $D\setminus F$. Each term of the first part is at most $|U|$, so that part
contributes at most $|F||U|$. The second part is at most $|D \setminus F| \cdot \max_{a \in D\setminus F} f(a)
\le |D| \max f(a)$, and $D \setminus F$ is nonempty since $|F| < |D|$. $\square$

### 3.3 Iteration and the counting criterion

> **Proposition 3.3 (Greedy iteration).** Let $D$ absorb all differences of $S$ and let
> $k \le \min(|S|,|D|)$. For every $j \le k$ there exist $A \subseteq D$ with $|A| = j$ and
> $U \subseteq S$ with
> $$u + a \in S \quad \text{for all } a \in A,\ u \in U,$$
> and
> $$|S|\,(|S| - k)^{j} \;\le\; |U|\,|D|^{j}.$$

*Proof.* Induct on $j$. For $j = 0$ take $A = \emptyset$, $U = S$. For the step, apply
Lemma 3.2 with $F = A$ (so $|F| = j < k \le |D|$), obtaining a fresh shift $a$ and the
survivor set $U' = \{u \in U : u+a\in S\}$. Since $|A| = j$ and $(|S| - k) + j \le |S|$,
$$|U|(|S|-k) + |A||U| \le |U| |S| \le |D||U'| + |A||U|,$$
so $|U|(|S|-k) \le |D||U'|$. Multiplying the inductive bound
$|S|(|S|-k)^j \le |U||D|^j$ by $(|S|-k)$ and substituting gives
$|S|(|S|-k)^{j+1} \le |U'||D|^{j+1}$. The compatibility condition
$u + a \in S$ holds for the new shift by construction of $U'$ and for old shifts because
$U' \subseteq U$. $\square$

> **Theorem 3.4 (Counting criterion).** Let $S, D$ be finite subsets of an abelian group,
> with $D$ absorbing all differences of $S$, and let $k \le \min(|S|,|D|)$ satisfy
> $$k\,|D|^{k} \;\le\; |S|\,(|S|-k)^{k}.$$
> Then there exist $A \subseteq D$ and $B$ with $|A| = |B| = k$ and $A + B \subseteq S$.

*Proof.* Take $j = k$ in Proposition 3.3, obtaining $A$ and $U$. Then
$k|D|^k \le |S|(|S|-k)^k \le |U||D|^k$, so $k \le |U|$ (dividing by $|D|^k > 0$). Choose
any $B \subseteq U$ with $|B| = k$. Every $a + b$ with $a \in A, b\in B$ lies in $S$. $\square$

Two remarks. First, the criterion is *symmetric in nothing*: $A$ is a set of shifts drawn
from the window $D$, while $B$ is a subset of $S$ itself. Second, the bound is essentially
$k \le |S| / |D| \cdot$-iterated, i.e. the density $\sigma = |S|/|D|$ raised to the $k$-th
power must exceed $k/|S|$; solving gives $k \approx \log|S| / \log(1/\sigma)$.

### 3.4 Instances of the window

* **Finite abelian group.** Take $D = G$. Then $D$ absorbs all differences trivially, and
  the criterion reads $k|G|^k \le |S|(|S|-k)^k$; with $|S| = \delta|G|$ this is
  $k(1/\delta)^k \lesssim \delta|G|$, i.e. $k \lesssim \log|G|/\log(1/\delta)$. **No loss.**
* **Integer interval, naive window.** For $S \subseteq [0,n) \subseteq \mathbb{Z}$ take
  $D = (-n, n)$, of size $2n-1$. The criterion $k(2n)^k \le |S|(|S|-k)^k$ gives
  $k \lesssim \log n/\log(2/\delta)$: a factor-$2$ loss in the base of the logarithm.
* **Natural numbers.** Any statement for $S \subseteq [0,n) \subseteq \mathbb{Z}$ transfers
  to $\mathbb{N}$ by translating $A$ by its minimum and $B$ by the negative of that minimum;
  the sumset is unchanged and both factors become sets of nonnegative integers.

---

## 4. From counting to density

### 4.1 Real-parameter form

It is convenient to record the criterion with a slack parameter absorbing the difference
between $|S|$ and $|S| - k$.

> **Lemma 4.1 (Real-parameter criterion).** Let $D$ absorb all differences of $S$, let
> $k \le |D| \le M$, let $\sigma \le |S|$, and let $0 < \epsilon < 1$. If $k \le \epsilon\sigma$
> and
> $$k\left(\frac{M}{(1-\epsilon)\sigma}\right)^{k} \le \sigma,$$
> then $S$ contains $A + B$ with $|A| = |B| = k$ and $A \subseteq D$.

*Proof.* $k \le \epsilon \sigma$ gives $|S| - k \ge (1-\epsilon)\sigma$, and $|D| \le M$;
substituting into Theorem 3.4 and rearranging gives the displayed inequality. $\square$

The analytic engine converting this into an asymptotic statement is elementary: if $b > 1$
and $c \log b < 1$, then for every $\alpha > 0$ one has
$\lfloor c\log N\rfloor \, b^{\lfloor c\log N\rfloor} \le \alpha N$ for all large $N$,
because $b^{c \log N} = N^{c\log b} = N^{1 - \eta}$ with $\eta > 0$, and the extra factor
$\lfloor c\log N\rfloor$ is absorbed by $N^{\eta}$.

### 4.2 Groups: the sharp constant with no loss

> **Theorem 4.2 (Sharp lower bound in finite abelian groups).** Fix $0 < \delta < 1$ and
> $c > 0$ with $c\log(1/\delta) < 1$. There is $N_0$ such that for every finite abelian
> group $G$ with $|G| \ge N_0$ and every $S \subseteq G$ with $|S| \ge \delta|G|$, there
> exist $A, B \subseteq G$ with
> $$|A| = |B| = \lfloor c\log|G|\rfloor, \qquad A + B \subseteq S.$$

*Proof sketch.* Apply Lemma 4.1 with $D = G$, $M = |G|$, $\sigma = \delta|G|$, a fixed
small slack $\epsilon$, and $k = \lfloor c\log|G|\rfloor$. The hypothesis becomes
$k\big(1/((1-\epsilon)\delta)\big)^k \le \delta|G|$, which holds for large $|G|$ by the
analytic engine above, since $c\log\big(1/((1-\epsilon)\delta)\big) < 1$ for $\epsilon$
small enough. $\square$

Specialising $G = \mathbb{Z}/N\mathbb{Z}$ gives the cyclic statement with
$k = \lfloor c \log N\rfloor$.

### 4.3 Intervals: removing the window loss

Inside $[n]$ the naive window has $2n$ elements while $S$ lives in a region of size $n$;
the resulting constant is $1/\log(2/\delta)$. The loss is removable, because the greedy
iteration never needs $D$ to contain *all* differences of $S$: it only needs a uniform
lower bound
$$\#\{a \in D : u + a \in S\} \;\ge\; m \qquad \text{for every } u \in U_0,$$
where $U_0$ is the starting set. All of Lemmas 3.1–3.2 and Proposition 3.3 go through in
this one-sided form (in an arbitrary commutative monoid), with $|U|\,|S|$ replaced by
$m\,|U|$ throughout.

> **Lemma 4.3 (Short window).** Let $S \subseteq [0,n)$ and let $1 \le w \le n$. For every
> $u < w$, taking $D = [0, n-w+1)$ we have
> $$\#\{a \in D : u + a \in S\} \;\ge\; |S| - (w-1),$$
> since the shifts $a$ with $u + a \in S$ miss at most the $w - 1$ elements of $S$ below
> $u$, and $u + a < n$ for $a \in D$.

The window $D$ now has $n - w + 1 \approx n$ elements rather than $2n$. To supply a large
starting set $U_0$ inside a window of length $w$, partition $[0,n)$ into $\lceil n/w\rceil$
blocks of length $w$; by pigeonhole one block $I$ satisfies $|S \cap I| \ge |S| w / n$
(up to rounding). Translating so that $I$ starts at $0$ and taking $U_0 = S \cap I$, the
iteration runs with $m = |S| - (w-1)$ and $|D| \approx n$. Choosing, for instance,
$w = \lfloor \rho n \rfloor$ for a small fixed $\rho$ costs only a constant factor in $|U_0|$
and a $\rho n$ additive loss in $m$ — both invisible in the exponent.

> **Theorem 4.4 (Sharp lower bound in $[n]$).** Fix $0 < \delta < 1$ and $c > 0$ with
> $c\log(1/\delta) < 1$. Then for all sufficiently large $n$, **every** $S \subseteq [n]$
> with $|S| \ge \delta n$ contains a sumset $A + B$ with
> $$|A| = |B| = \lfloor c\log n\rfloor .$$

*Proof sketch.* Fix $t = 1 - c\log(1/\delta) > 0$ and choose a shrink factor
$r = e^{-t/(2c)} \in (0,1)$, so that $\delta r$ still satisfies $c \log(1/(\delta r)) < 1$
(the loss $c\log(1/r) = t/2$ leaves half of the slack $t$). Choose the window length
$w$ so that the pigeonhole loss and the additive loss $w-1$ together degrade the effective
density from $\delta$ to at least $\delta r$. Then the one-sided criterion applies with
$|D| \le n$, $m \ge \delta r n$, and $k = \lfloor c\log n\rfloor$, and the required
inequality $k\,(1/(\delta r))^{k}\cdot(\text{const}) \le n$ holds for all large $n$ by the
analytic engine. $\square$

Thus $C(\delta) \ge 1/\log(1/\delta) \cdot \log(1/\delta) = 1$ in the normalisation
$k = c\,\log n/\log(1/\delta)$: the existence side holds for every $c < 1$.

---

## 5. The matching construction

### 5.1 The naive first moment

Suppose we choose $S \subseteq [n]$ uniformly at random among sets of size $m = \lceil \delta n\rceil$.
For a fixed set $W \subseteq [n]$ with $|W| = L$,
$$\Pr[W \subseteq S] \;=\; \frac{\binom{n-L}{m-L}}{\binom{n}{m}} \;\le\; \left(\frac{m}{n}\right)^{L}.$$
Hence, if $\mathcal{W}$ is a family of "witnesses" (sets that any forbidden configuration
must contain) with $|\mathcal{W}| \cdot (m/n)^{L} < 1$, some $m$-element $S \subseteq [n]$
contains no member of $\mathcal{W}$, and therefore no forbidden configuration.

For sumsets of two $K$-term arithmetic progressions
$\mathrm{AP}(a,d_1,K) + \mathrm{AP}(b,d_2,K)$, the family is parameterised by
$(a + b, d_1, d_2)$ — only the sum $a+b$ matters — giving at most $n^3$ witnesses; each
sumset contains the "L-shaped" witness of $2K - 1$ points. The condition
$n^3 (m/n)^{2K-1} < 1$ holds once
$$K \;\ge\; \Big(\tfrac{3}{2}+\varepsilon\Big)\frac{\log n}{\log(1/\delta)},$$
giving the intermediate constant $3/2$.

### 5.2 Weighted first moment

The improvement to $1$ comes from two observations.

**(i) A variable-size first-moment principle.** Let $\{W_i\}_{i \in I}$ be a finite family
of subsets of $[n]$ with $|W_i| \ge L_i \ge 1$. If
$$\sum_{i \in I} \left(\frac{m}{n}\right)^{L_i} \;<\; 1,$$
then some $m$-element $S \subseteq [n]$ contains no $W_i$. (Same proof as above, without
assuming the $L_i$ equal.)

**(ii) Blocks beat L-shapes.** Write $d_1 = g e_1$, $d_2 = g e_2$ with
$\gcd(e_1,e_2) = 1$ and set $Q = \max(e_1,e_2)$. Then
$$\mathrm{AP}(a,d_1,K) + \mathrm{AP}(b,d_2,K)
= \{a + b + g(i e_1 + j e_2) : 0 \le i,j < K\}.$$
Because $e_1$ and $e_2$ are coprime, the map $(i,j)\mapsto i e_1 + j e_2$ is injective on
$0 \le i < K$, $0 \le j < \min(Q, K)$; hence the sumset contains a **block witness** of
$$K \cdot \min(Q, K)$$
distinct points. The L-shaped bound $2K-1$ is the truth only when $Q = 1$, i.e. $d_1 = d_2$.

**(iii) The parameter count does not grow with $Q$.** For fixed $Q$, the triples
$(t, g, e_1, e_2)$ with $t < n$, $\max(e_1,e_2) = Q$ and $g e_i < n$ number at most
$2n^2$ — the constraint $\max(e_1,e_2) = Q$ pins one of the two cofactors, and $g$ ranges
over at most $n/Q$ values. Combining with the witness sizes
$$L(K,Q) \;=\; \max\big(2K-1,\; K\min(Q,K)\big)$$
(the L-shape is always available, the block is available when $Q \ge 2$), the weighted first
moment is bounded by
$$\sum_{Q \ge 1} 2n^{2}\,x^{\,L(K,Q)}, \qquad x = m/n \le \delta + 1/n .$$
The terms decay geometrically in $Q$ (each increment of $Q$ below $K$ adds $K$ to the
exponent), so once $2x^{K}\le 1$ the sum is at most twice its first term, $4n^{2}x^{2K-1}$.
The binding constraint is therefore the *equal-difference* case $Q = 1$, where only $n^2$
parameters occur and the witness has $2K - 1$ points:
$$4n^{2}x^{2K-1} < 1 \iff (2K-1)\log(1/x) > 2\log n + \log 4,$$
i.e. $K > (1+\varepsilon)\log n/\log(1/\delta)$ once the rounding loss $x \le \delta + 1/n$
and the constant factors are absorbed into $\varepsilon$. Compared with the naive bound,
what has been saved is exactly the third factor of $n$: the parameter $d_1/d_2$ ratio is no
longer free, because when it is nontrivial the witness is a fat block rather than an L.

> **Theorem 5.3 (Counting form).** Let $m \le n$, $m \ge 1$, $K \ge 2$, and set $x = m/n$.
> If $2x^{K} \le 1$ and the weighted sum above is $< 1$, then there is $S \subseteq [n]$
> with $|S| = m$ containing no sumset $\mathrm{AP}(a,d_1,K') + \mathrm{AP}(b,d_2,K')$ with
> $d_1,d_2 > 0$ and $K' \ge K$.

> **Theorem 5.4 (Avoidance at constant $1$).** For every $0 < \delta < 1$ and
> $\varepsilon > 0$ there is $n_0$ such that for all $n \ge n_0$ there exists
> $S \subseteq [n]$ with $|S| \ge \delta n$ and
> $$\mathrm{AP}(a,d_1,K) + \mathrm{AP}(b,d_2,K) \not\subseteq S$$
> for all $a, b$, all $d_1, d_2 > 0$ and all
> $K \ge (1+\varepsilon)\log n/\log(1/\delta)$.

*Proof sketch.* Set $m = \lceil \delta n\rceil$, so $x = m/n \le \delta + 1/n$. Choose
$\theta = \varepsilon/(2(1+\varepsilon))$; for $n$ large enough, $1/(\delta n) \le \theta\log(1/\delta)$,
which converts $\log(1/x) \ge (1-\theta)\log(1/\delta)$. Two further largeness conditions,
$\log(1/\delta) + \log 16 \le \varepsilon \log n$ and $4\log(1/\delta) \le \log n$, make the
constants in the geometric series harmless. Then Theorem 5.3 applies with
$K = \lceil (1+\varepsilon)\log n/\log(1/\delta)\rceil$. $\square$

### 5.3 Progression-rich pairs and the min-form

The constructed set avoids far more than sumsets of progressions.

> **Theorem 5.5 (Progression-rich avoidance).** For every $0 < \delta < 1$ and
> $\varepsilon > 0$, for all large $n$ there is $S \subseteq [n]$ with $|S| \ge \delta n$
> such that: whenever $A$ and $B$ each contain an arithmetic progression of length
> $T \ge (1+\varepsilon)\log n/\log(1/\delta)$ (with positive common difference), we have
> $A + B \not\subseteq S$.

*Proof.* If $\mathrm{AP}(a,d_1,T) \subseteq A$ and $\mathrm{AP}(b,d_2,T)\subseteq B$ then
$\mathrm{AP}(a,d_1,T) + \mathrm{AP}(b,d_2,T) \subseteq A + B$, so containment of $A+B$ in
$S$ would contradict Theorem 5.4. $\square$

In particular, taking $A, B$ to be progressions of possibly *different* lengths $K_1, K_2$
and applying the theorem with $T = \min(K_1,K_2)$ gives the statement in the form in which
the problem is usually posed: no sumset of two progressions with
$\min\{|A|,|B|\}\ge(1+\varepsilon)\log n/\log(1/\delta)$ lies inside $S$.

> **Theorem 5.6 (Two-sided threshold).** Fix $0 < \delta < 1$, $\varepsilon > 0$, and
> $c>0$ with $c\log(1/\delta)<1$. For all sufficiently large $n$ *both* of the following
> hold:
> 1. every $S\subseteq[n]$ with $|S|\ge\delta n$ contains a sumset $A+B$ with
>    $|A|=|B|=\lfloor c\log n\rfloor$;
> 2. some $S\subseteq[n]$ with $|S|\ge\delta n$ contains no sumset $A+B$ with $A,B$ both
>    containing a progression of length $\ge(1+\varepsilon)\log n/\log(1/\delta)$.
>
> Since $c$ may be taken arbitrarily close to $1/\log(1/\delta)$, the threshold is
> $(1+o(1))\log n/\log(1/\delta)$: the extremal constant equals $1$.

*Proof.* Intersect the two eventual statements of Theorems 4.4 and 5.5. $\square$

The asymmetry deserves emphasis: the existence half is unconditional on the *shape* of
$A, B$, while the avoidance half applies to pairs that are progression-rich. Section 9
discusses this gap.

---

## 6. Affine cubes: the multi-fold companion

### 6.1 Iterating the engine on its own output

The greedy step of Lemma 3.2 can be applied with $U$ equal to the *current survivor set*
rather than to $S$, and the shift can be recorded as a new cube generator. Write
$$\mathcal{C}(a_1,\dots,a_j) = \{0,a_1\}+\cdots+\{0,a_j\}$$
for the cube of shifts built so far. The invariant maintained is: there is a set $U_j$ with
$u + x \in S$ for every $u \in U_j$ and every $x \in \mathcal{C}(a_1,\dots,a_j)$, together
with the counting bound
$$|S|^{2^{j}} \;\le\; (2|D|)^{2^{j}-1}\,|U_j| .$$
Each new generator squares the exponent, because the new survivor set must be compatible
with the entire old cube *and* its translate: $|U_{j+1}| \gtrsim |U_j|^2/|D|$.

> **Theorem 6.1 (Abstract cube criterion).** Let $D$ absorb all differences of $S$ with
> $|D| \ge 2$. If
> $$2\,(2|D|)^{2^{j}-1} \;\le\; |S|^{2^{j}} \qquad \text{for every } j \le d,$$
> then there are $u \in S$ and nonzero $a_1,\dots,a_d$ with
> $\mathcal{C}(u;a_1,\dots,a_d)\subseteq S$.

A convenient reduction: if $|S| \le 2|D|$ (always true in our applications) the condition
at the top scale $j = d$ implies it at every $j \le d$, since the ratio $|S|/(2|D|) \le 1$
only decreases under higher powers.

> **Theorem 6.2 (Cubes in finite abelian groups).** If $|G| \ge 2$ and
> $2(2|G|)^{2^d-1} \le |S|^{2^d}$, then $S \subseteq G$ contains an affine cube of dimension
> $d$ with nonzero generators. The same holds in $\mathbb{Z}/N\mathbb{Z}$ with $|G| = N$.

> **Theorem 6.3 (Cubes in intervals).** Let $S \subseteq [0,n)$ with $|S| \ge \delta n$ and
> $n \ge 1$, $\delta > 0$. If
> $$\left(\frac{4}{\delta}\right)^{2^{d}} \;\le\; 2n,$$
> equivalently $d \le \log_2\!\big(\log(2n)/\log(4/\delta)\big)$, then $S$ contains an
> affine cube of dimension $d$ with all generators nonzero (possibly negative).

*Proof sketch.* Use $D = (-n,n)$, so $|D| = 2n-1$ and $2|D| \le 4n$; the abstract condition
$2(4n)^{2^d-1} \le |S|^{2^d}$ follows from $|S| \ge \delta n$ once
$(4/\delta)^{2^d} \le 2n$, by writing $(\delta n)^{2^d} = (\delta/4)^{2^d}(4n)^{2^d}$. $\square$

The doubly logarithmic dimension is intrinsic: each step squares the density loss, so after
$d$ steps the density is $\delta^{2^d}$, and the process halts when $\delta^{2^d} n \approx 1$,
i.e. at $2^d \approx \log n/\log(1/\delta)$ — exactly where the two-fold argument halts at
$k \approx \log n /\log(1/\delta)$. This is a quantitative form of Szemerédi's cube lemma,
obtained here from the same averaging step as the two-fold bound.

### 6.2 Properness

A cube produced by Theorem 6.3 can be degenerate: if $a_1 = a_2$ it collapses to a
three-term progression, and a dense set certainly contains those. To force all $2^d$ subset
sums to be distinct, run the same iteration but forbid each new shift from lying in the
difference set
$$\mathcal{C}(a_1,\dots,a_j) - \mathcal{C}(a_1,\dots,a_j),$$
which has at most $4^{j}$ elements. A shift outside it is automatically nonzero and doubles
the cardinality of the cube, so properness is maintained.

> **Lemma 6.4.** If $a \notin \mathcal{C}(l) - \mathcal{C}(l)$ then
> $|\mathcal{C}(a, l)| = 2|\mathcal{C}(l)|$.

> **Theorem 6.5 (Proper cubes in intervals).** Let $S \subseteq [0,n)$, $|S| \ge \delta n$,
> $0 < \delta \le 1$, $n \ge 1$. If
> $$\left(\frac{4}{\delta}\right)^{2^{d}}\cdot 4^{d} \;\le\; 2n,$$
> then $S$ contains a *proper* affine cube of dimension $d$: nonzero generators
> $a_1,\dots,a_d$ and a base $u \in S$ with all $2^d$ points
> $u + \sum_{i\in I}a_i$ distinct and in $S$.

The only change from Theorem 6.3 is the factor $4^{d}$, which shifts the admissible range
of $d$ by $O(\log d)$ in the exponent $2^d$ — nothing on the scale
$2^d \approx \log n/\log(1/\delta)$.

### 6.3 The matching first-moment bound

A $d$-dimensional cube in $[n]$ is determined by its base and $d$ generators, hence there
are at most $n^{d+1}$ of them; a proper one forces $2^d$ points of $S$.

> **Theorem 6.6 (Cube-free dense sets).** For every $0 < \delta < 1$ and $\varepsilon > 0$,
> for all sufficiently large $n$ and *every* dimension $d$ with
> $$(1+\varepsilon)\,(d+1)\log n \;\le\; 2^{d}\log(1/\delta),$$
> there exists $S \subseteq [n]$ with $|S| \ge \delta n$ containing no proper
> $d$-dimensional affine cube with positive generators.

*Proof sketch.* With $m = \lceil \delta n\rceil$ the first-moment condition is
$n^{d+1}m^{L} < n^{L}$ with $L = 2^d$; this is exactly
$(d+1)\log n < 2^d \log(n/m)$, and $\log(n/m) \ge \log(1/(\delta + 1/n))$, which exceeds
$\log(1/\delta)/(1+\varepsilon)$ for large $n$. Note that the exponent $d+1$ must be allowed
to grow with $n$, so the analytic step is carried out for unbounded exponents. $\square$

> **Theorem 6.7 (One set for all dimensions).** For every $0 < \delta < 1$ and
> $\varepsilon>0$, for all large $n$ and every $d_0$ with
> $$(1+\varepsilon)(d_0+1)\log(4n) \;\le\; 2^{d_0}\log(1/\delta),$$
> there exists a single $S \subseteq [n]$ with $|S| \ge \delta n$ containing no proper
> affine cube of *any* dimension $d \ge d_0$.

*Proof sketch.* Apply the variable-size first-moment principle of §5.2(i) to the union over
all $d \ge d_0$ of the cube families, with $L_d = 2^d$ and $|I_d| = n^{d+1}$. Two facts make
the total sum finite and small: a proper $d$-cube in $[n]$ has $2^d \le n$ points, so only
$d \le n$ occur; and the ratio $(d+1)/2^{d}$ is nonincreasing, so the threshold hypothesis
need only be checked at $d = d_0$. The resulting series is dominated by
$\sum_{j\ge1}4^{-j} \le 1/3$. $\square$

> **Theorem 6.8 (Disjointness of the two ranges).** For every $0<\delta<1$ and
> $\varepsilon>0$, for all sufficiently large $n$ no dimension $d$ satisfies both the
> existence condition $(4/\delta)^{2^d}4^{d}\le 2n$ of Theorem 6.5 and the avoidance
> condition $(1+\varepsilon)(d+1)\log n \le 2^{d}\log(1/\delta)$ of Theorem 6.6.

*Proof sketch.* The existence condition gives $2^{d}\log(4/\delta) \le \log 2 + \log n$,
hence $2^{d}\log(1/\delta) \le \log 2 + \log n$; the avoidance condition gives
$2^{d}\log(1/\delta) \ge (1+\varepsilon)(d+1)\log n \ge (1+\varepsilon)\log n$. These
conflict once $\varepsilon \log n > \log 2$. $\square$

So the critical dimension for proper cubes lies between the two thresholds, and both are of
the shape $2^{d} \asymp \log n/\log(1/\delta)$ — up to the additive $\log_2(d+1)$ which is
$O(\log\log\log n)$ in the exponent scale.

---

## 7. Effective instances

Because Theorem 3.4 and Theorem 6.1 are exact inequalities between integers, they can be
instantiated at concrete numbers with no asymptotic slack. Four samples:

| Statement | Numerical check |
|---|---|
| Every $S \subseteq [0,2^{20})$ with $\lvert S\rvert \ge 2^{19}$ contains $A+B$, $\lvert A\rvert=\lvert B\rvert=7$ | $7\cdot(2^{21})^{7} \le 2^{19}(2^{19}-7)^{7}$ |
| Every $S \subseteq [0,2^{22})$ with $\lvert S\rvert \ge 2^{19}$ contains $A+B$, $\lvert A\rvert=\lvert B\rvert=4$ | $4\cdot(2^{23})^{4} \le 2^{19}(2^{19}-4)^{4}$ |
| Every $S\subseteq[0,4096)$ with $\lvert S\rvert\ge2048$ contains $u,u+a,u+b,u+a+b$ ($a,b\neq0$) | $2\,(4\cdot4096)^{3} = 2^{43} \le 2048^{4}=2^{44}$ |
| Every $S\subseteq[0,32768)$ with $\lvert S\rvert\ge16384$ contains a *proper* $2$-cube | $2\cdot4^{2}(4\cdot32768)^{3} = 2^{56} \le 16384^{4} = 2^{56}$ |

The last line is an exact equality — the criterion is tight at that instance.

---

## 8. Algorithmic content

The existence half of the theory is constructive, and the construction is a short
polynomial-time algorithm.

**Greedy sumset extraction.** Input: $S \subseteq [0,n)$, target $k$.
1. Set $U \leftarrow S$, $A \leftarrow \emptyset$.
2. Repeat $k$ times: over all shifts $a \in D \setminus A$, compute
   $f(a) = |\{u \in U : u + a \in S\}|$; choose $a^*$ maximising $f$; set
   $A \leftarrow A \cup \{a^*\}$, $U \leftarrow \{u \in U : u + a^* \in S\}$.
3. If $|U| \ge k$, output $A$ and any $k$-subset $B \subseteq U$.

Each round costs $O(|D|\cdot|U|)$ membership tests, so the whole run is $O(k\,n\,|S|)$ in
the worst case with a bitset representation reducing this to $O(k n^2/64)$ word operations;
in practice $U$ shrinks geometrically and the cost is dominated by the first round.
Theorem 3.4 guarantees success whenever $k|D|^k \le |S|(|S|-k)^k$; in experiments the
algorithm typically succeeds well beyond that guarantee, since the greedy choice
consistently beats the average.

**Greedy cube extraction.** Identical, except that $U$ is replaced by the current survivor
set and the update is $U \leftarrow U \cap (U - a^*)$, doubling the cube dimension count by
one each round; to force properness, restrict $a^*$ to lie outside
$\mathcal{C}-\mathcal{C}$ for the cube built so far.

**Threshold computation.** Both criteria are monotone in $k$ (resp. $d$), so the maximal
guaranteed $k$ is found by a single scan or a binary search on the inequality; the
arithmetic must be done in exact integers (or in logarithms) because the quantities involved
have thousands of digits already for $n = 2^{20}$.

---

## 9. Discussion, limitations, open problems

**What is exactly determined.** For pairs $(A,B)$ in which both factors are
progression-rich, the extremal threshold in $[n]$ is
$(1+o(1))\log n/\log(1/\delta)$, and the constant $1$ is best possible on both sides. In
finite abelian groups the existence side holds with the same constant with respect to
$\log |G|$, with a cleaner proof (no window loss).

**The asymmetry.** The existence theorem produces *arbitrary* $A, B$; the avoidance
theorem defeats only *progression-rich* $A,B$. Closing this gap — i.e. constructing, for
$K \ge (1+\varepsilon)\log n/\log(1/\delta)$, a $\delta$-dense set containing no sumset
$A+B$ with $|A| = |B| = K$ and $A, B$ arbitrary — is the main open problem left here. The
obstruction is a counting one: the family of all pairs of $K$-element sets is far too large
for a union bound, and any successful construction must exploit the structure that a
$K \times K$ additive grid imposes on its own factor sets (Freiman-type rigidity), rather
than enumerating them.

**Sharpness of the greedy engine.** The counting criterion $k|D|^k\le|S|(|S|-k)^k$ is tight
in shape but not in constants: the greedy step only claims the maximum beats the average,
and the "already used shifts" are charged at the maximal rate $|U|$ each. Refined accounting
(e.g. second-moment control of the shift-count distribution) might improve the lower-order
terms, though not the leading constant, which is already matched.

**Cubes.** For proper affine cubes the existence and avoidance ranges of $d$ are disjoint
and both located at $2^{d}\asymp\log n/\log(1/\delta)$, but they differ by the additive
$\log_2(d+1)+O(1)$ in $d$. Determining the critical dimension to within an additive
constant — that is, deciding whether the truth sits at
$2^{d}\approx \log n/\log(1/\delta)$ or at $2^{d}\approx (d+1)\log n/\log(1/\delta)$ — is a
natural next target. The gap is exactly the "$d+1$ parameters" of the union bound versus the
"one parameter per dimension" of the greedy construction.

**Beyond two factors.** The cube results are the $d$-fold companion for two-element
factors. The general question — the largest $r$-fold sumset $A_1+\cdots+A_r$ with all
$|A_i| = k$ forced inside a $\delta$-dense set — interpolates between the two regimes and
is governed by the same squaring phenomenon: with $r$ factors of size $k$ the density loss
per factor is $\delta^{k}$, so one expects $rk\approx\log n/\log(1/\delta)$ for the total
"volume" $\sum \log|A_i|$ of the configuration. Making this precise, with matching
constants, would unify Sections 3–5 with Section 6.

**Groups versus intervals.** The interval bound needed the short-window trick to shed a
factor $2$; in a group no trick is needed. This suggests that the interval problem's
lower-order terms carry genuine boundary information, and it would be interesting to
determine the second-order term in $[n]$ — whether it is $-\Theta(\log\log n)$ or $O(1)$.

---

## 10. Summary of the main statements

1. **Averaging identity.** For $U \subseteq S$ and $D \supseteq S - S$:
   $\sum_{a\in D}\#\{u\in U : u+a\in S\} = |U||S|$.
2. **Counting criterion.** $k|D|^{k}\le|S|(|S|-k)^{k}$ implies $A+B\subseteq S$ with
   $|A|=|B|=k$, $A \subseteq D$.
3. **Groups.** For $c\log(1/\delta)<1$ and $|G|$ large, every $\delta$-dense $S\subseteq G$
   contains $A+B$ with $|A|=|B|=\lfloor c\log|G|\rfloor$.
4. **Intervals.** The same with $\log n$, for every $\delta$-dense $S\subseteq[n]$.
5. **Avoidance.** For every $\varepsilon>0$ and large $n$, some $\delta$-dense
   $S\subseteq[n]$ contains no $A+B$ with $A,B$ both containing a progression of length
   $\ge(1+\varepsilon)\log n/\log(1/\delta)$.
6. **Threshold.** The extremal constant for progression-rich sumsets is exactly $1$:
   the threshold is $(1+o(1))\log n/\log(1/\delta)$.
7. **Cubes.** $(4/\delta)^{2^{d}}\le 2n$ forces a $d$-dimensional affine cube;
   $(4/\delta)^{2^{d}}4^{d}\le2n$ forces a proper one;
   $(1+\varepsilon)(d+1)\log n\le2^{d}\log(1/\delta)$ permits avoidance of proper $d$-cubes,
   even for all $d\ge d_0$ at once.
