# The Mass of Invisibility: Sharp $\ell^1$ Bounds for Weight Vectors Annihilated by a Truncated Power-Sum Window

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

Let $e : \{0,1,\dots,N\} \to \mathbb{Z}$ be an integer weight vector and let

$$m_k(e) \;=\; \sum_{j=0}^{N} e_j \, j^k \qquad (0^0 := 1)$$

denote its $k$-th moment. Call $e$ *invisible to the window $K$* if
$m_k(e) = 0$ for all $k < K$, and define its *mass* to be the $\ell^1$ norm
$\|e\|_1 = \sum_j |e_j|$. We study the extremal invariant

$$\operatorname{minMass}(K) \;=\; \min\{\|e\|_1 : e \neq 0 \text{ and } e \text{ invisible to the window } K\}.$$

We prove four groups of results. First, a sharp lower bound
$\operatorname{minMass}(K) \ge 2K$, obtained by converting the vanishing
moments into equal power sums of two multisets and applying Newton's
identities to force equality of the associated monic root polynomials. Second,
an exact evaluation $\operatorname{minMass}(K) = 2K$ for $1 \le K \le 10$ and
$K = 12$, via explicit ideal Prouhet–Tarry–Escott configurations, together
with the exact characterisation
$\operatorname{minMass}(K) = 2K \iff$ an ideal Prouhet–Tarry–Escott
configuration of size $K$ exists; in particular
$\operatorname{minMass}(11) \in \{22,24\}$, equal to $22$ precisely when an
ideal configuration of size $11$ exists. Third, a composition calculus:
$\operatorname{minMass}$ is submultiplicative,
$\operatorname{minMass}(K_1+K_2) \le \operatorname{minMass}(K_1)\operatorname{minMass}(K_2)$,
strictly so at $(2,2)$; and a *seeded engine* which converts any single
invisible vector of window $K_0$, mass $L$ and nonzero $K_0$-th moment into
nonzero invisible vectors of window $K_0 n$ and mass at most $L^n$ for all
$n$. Instantiating the engine at the ideal configuration of size $12$ yields
the bracket

$$2K \;\le\; \operatorname{minMass}(K) \;\le\; 24^{\lceil K/12\rceil},$$

equivalently $\operatorname{minMass}(K)^{12} \le 24^{K+11}$, so the growth base
of invisibility is at most $24^{1/12} \approx 1.3032$, improving the previous
$6^{1/3} \approx 1.8171$ by a factor $54^{n}$ at each window $12n$. Fourth, a
dictionary identifying $\operatorname{minMass}(K)$ with the least
coefficient-$\ell^1$ norm of a nonzero integer polynomial divisible by
$(X-1)^K$. The results together show that the polynomial-mass conjecture
$\operatorname{minMass}(K) = 2K$ is equivalent, for the composition method, to
the existence of ideal Prouhet–Tarry–Escott configurations of unbounded size.

**Keywords:** power sums, moment problems, Prouhet–Tarry–Escott problem,
Newton's identities, $\ell^1$ extremal problems, finite differences,
integer polynomials, convolution.

---

## 1. Introduction

### 1.1 Ghosts of a truncated moment map

A measurement that reports only the first $K$ moments of a discrete
distribution defines a linear map

$$\mathcal{M}_K : \mathbb{Z}^{\{0,\dots,N\}} \longrightarrow \mathbb{Z}^{K},
\qquad \mathcal{M}_K(e) = \big(m_0(e), m_1(e), \dots, m_{K-1}(e)\big).$$

Its kernel — the set of configurations that the measurement cannot see —
is nontrivial as soon as $N \ge K$, because the map is a $K \times (N+1)$
Vandermonde-type system. The existence of kernel elements is therefore
uninteresting. What is interesting is their *size*, in a norm which reflects
the physical or computational cost of producing them. For integer weights the
natural choice is the $\ell^1$ norm, which counts the total number of unit
charges deployed, and the extremal question is:

> How cheaply can a nonzero configuration hide from the first $K$ moments?

Classically the answer is quantified by the $K$-th finite-difference stencil.
The vector $e_j = (-1)^{K-j}\binom{K}{j}$, supported on $\{0,\dots,K\}$,
annihilates all polynomials of degree $< K$ and hence lies in
$\ker \mathcal{M}_K$; its mass is $2^K$. Thus
$\operatorname{minMass}(K) \le 2^K$, and the question is how far below this
exponential the truth lies.

### 1.2 Summary of results

Throughout, $K \ge 1$ is the window, and all vectors have integer entries and
finite support.

* **(Newton mass law, Theorem 3.4)** Every nonzero $e$ invisible to the window
  $K$ has $\|e\|_1 \ge 2K$.
* **(Sharpness, Theorem 4.3)** $\operatorname{minMass}(K) = 2K$ for
  $1 \le K \le 10$ and for $K = 12$, witnessed by explicit ideal
  Prouhet–Tarry–Escott configurations.
* **(Characterisation, Theorem 5.2)** For every $K$,
  $\operatorname{minMass}(K) = 2K$ if and only if an ideal
  Prouhet–Tarry–Escott configuration of size $K$ exists.
* **(Boundary case, Corollary 5.4)** $\operatorname{minMass}(11) \in \{22,24\}$,
  and $\operatorname{minMass}(11) = 22$ if and only if an ideal configuration
  of size $11$ exists.
* **(Rigidity, Theorem 5.5)** A pair of multisets of the minimal size $K$ with
  equal power sums through the window is necessarily disjoint.
* **(Composition, Theorem 6.2 and Corollary 6.3)**
  $\operatorname{minMass}(K_1+K_2) \le \operatorname{minMass}(K_1)\operatorname{minMass}(K_2)$
  and $\operatorname{minMass}(nK) \le \operatorname{minMass}(K)^n$; the
  inequality is strict at $(K_1,K_2) = (2,2)$.
* **(Seeded engine, Theorem 6.5)** Any invisible seed of window $K_0$, mass
  $L$ and nonzero $K_0$-th moment yields, for every $n$, a nonzero vector
  invisible to the window $K_0n$ of mass at most $L^n$.
* **(Growth base, Theorem 7.1 and Corollary 7.3)** With the ideal size-$12$
  seed: nonzero invisible vectors of mass $\le 24^n$ at window $12n$; hence
  $\operatorname{minMass}(K) \le 24^{\lceil K/12\rceil}$ for every $K$ and
  $\operatorname{minMass}(K)^{12} \le 24^{K+11}$, i.e. growth base at most
  $24^{1/12} < 1.31$.
* **(Polynomial dictionary, Theorem 8.2)** $\operatorname{minMass}(K)$ is the
  least coefficient-$\ell^1$ norm of a nonzero $P \in \mathbb{Z}[X]$ with
  $(X-1)^K \mid P$; consequently every such $P$ has coefficient norm $\ge 2K$,
  attained for $K \le 10$ and $K = 12$.

### 1.3 Relation to the Prouhet–Tarry–Escott problem

The Prouhet–Tarry–Escott problem asks for two distinct multisets of integers
of the same size $n$ with equal power sums $p_1, \dots, p_{K-1}$; the solution
is *ideal* when $n = K$, the smallest size possible. Ideal solutions are known
for $K \le 10$ and $K = 12$, and their existence for general $K$ (in
particular $K = 11$) is open. Theorem 5.2 shows that the extremal problem
studied here is not merely analogous to but *equivalent* to that classical
problem, window by window. The composition calculus of §6 then converts the
classical open problem into a statement about growth rates: the conjecture
$\operatorname{minMass}(K) = 2K$ for all $K$ is precisely the assertion that
ideal configurations exist in all sizes.

---

## 2. Setting and definitions

**Definition 2.1 (moments and invisibility).** For $N, k \in \mathbb{N}$ and
$e : \mathbb{N} \to \mathbb{Z}$ define the $k$-th moment on $\{0,\dots,N\}$ by

$$m_k^{(N)}(e) \;=\; \sum_{j=0}^{N} e_j \, j^k, \qquad 0^0 := 1 .$$

We say $e$ is *invisible to the window $K$ on $\{0,\dots,N\}$*, written
$\mathrm{Inv}(N,K,e)$, if $m_k^{(N)}(e) = 0$ for all $k < K$. We suppress $N$
when it is clear from the context.

**Definition 2.2 (mass).** The *mass* of $e$ on $\{0,\dots,N\}$ is
$\|e\|_1 = \sum_{j=0}^{N} |e_j|$.

**Definition 2.3 (the extremal invariant).** Say the value $L \in \mathbb{N}$
is *achievable at window $K$* if there exist $N$ and $e$ with
$\mathrm{Inv}(N,K,e)$, $e \not\equiv 0$ on $\{0,\dots,N\}$, and $\|e\|_1 = L$.
Set

$$\operatorname{minMass}(K) \;=\; \min\{L : L \text{ achievable at window } K\}.$$

The set of achievable values is nonempty — the binomial stencil achieves
$2^K$ — so the minimum exists, and $\operatorname{minMass}(K) \le 2^K$.

**Definition 2.4 (positive/negative multisets).** Given $e$ supported on
$\{0,\dots,N\}$, let $s(e)$ be the multiset containing $j$ with multiplicity
$\max(e_j,0)$ and $t(e)$ the multiset containing $j$ with multiplicity
$\max(-e_j,0)$. Then $\|e\|_1 = |s(e)| + |t(e)|$, where $|\cdot|$ denotes
multiset cardinality.

**Definition 2.5 (power sums of a multiset).** For a multiset $s$ of naturals
and $k \in \mathbb{N}$, $p_k(s) = \sum_{a \in s} a^k$, again with $0^0=1$, so
$p_0(s) = |s|$.

**Definition 2.6 (near miss).** A *near miss at window $K$* is a pair of
distinct multisets $s \ne t$ of naturals with $p_k(s) = p_k(t)$ for all
$k < K$.

**Lemma 2.7 (dictionary between vectors and multisets).** $e$ is invisible to
the window $K$ if and only if $p_k(s(e)) = p_k(t(e))$ for all $k < K$; and
$e \ne 0$ if and only if $s(e) \ne t(e)$. Moreover $\|e\|_1 = |s(e)|+|t(e)|$.

*Proof sketch.* Split the sum defining $m_k$ into terms with $e_j>0$ and
$e_j<0$; the two partial sums are exactly $p_k(s(e))$ and $p_k(t(e))$. The
multisets determine $e$ since $s(e)$ and $t(e)$ have disjoint supports. $\square$

**Definition 2.8 (ideal configuration).** An *ideal Prouhet–Tarry–Escott
configuration of size $K$* is a pair of multisets $s,t$ of naturals with
$|s| = |t| = K$, $s \cap t = \emptyset$ (no element of $s$ lies in $t$),
$s \ne t$ and $p_k(s) = p_k(t)$ for all $k < K$. We write
$\mathrm{Ideal}(K)$ for the assertion that such a pair exists.

---

## 3. The Newton mass law

The lower bound rests on a determinacy statement for multisets: a multiset of
size $n$ over a field of characteristic $0$ is determined by its power sums
$p_0,\dots,p_n$. We record the chain of steps.

**Lemma 3.1 (Newton's identity for multisets).** Let $s$ be a multiset of
rationals of cardinality $n$, and let $e_i(s)$ denote its elementary symmetric
functions. For every $k \ge 1$,

$$k\,e_k(s) \;=\; \sum_{i=1}^{k} (-1)^{i-1} e_{k-i}(s)\, p_i(s),$$

with $e_i(s) = 0$ for $i > n$.

*Proof sketch.* This is the classical Newton identity, obtained by
specialising the universal identity between elementary symmetric and power-sum
symmetric polynomials in $n$ variables along the evaluation that sends the
variables to the elements of $s$. $\square$

**Lemma 3.2 (equal power sums force equal symmetric functions).** Let $s,t$ be
multisets of rationals with $p_k(s) = p_k(t)$ for all $k < K$. Then
$e_k(s) = e_k(t)$ for all $k < K$.

*Proof sketch.* Induct on $k$. For $k=0$ both sides are $1$. For $1 \le k < K$
the Newton identity expresses $k\,e_k$ in terms of $e_0,\dots,e_{k-1}$ and
$p_1,\dots,p_k$, all of which agree by the induction hypothesis and the
assumption (note $p_i$ for $i \le k \le K-1$ is inside the window). Since we
work in characteristic $0$, dividing by $k$ is legitimate. $\square$

**Proposition 3.3 (determinacy).** Let $s,t$ be multisets of rationals with
$|s| = |t| = n$ and $p_k(s) = p_k(t)$ for all $k \le n$. Then $s = t$.

*Proof sketch.* By Lemma 3.2 the elementary symmetric functions agree in
degrees $\le n$, hence the monic polynomials
$F(X) = \prod_{a\in s}(X-a)$ and $G(X) = \prod_{b\in t}(X-b)$, whose
coefficients are (signed) elementary symmetric functions of degree $\le n$,
are equal. A monic polynomial over a field determines its multiset of roots
with multiplicity, so $s = t$. $\square$

**Theorem 3.4 (size law and mass law).** Let $K \ge 1$.

1. If $(s,t)$ is a near miss at window $K$ (Definition 2.6) then
   $|s| \ge K$ and $|t| \ge K$; consequently $|s| + |t| \ge 2K$.
2. If $e \ne 0$ is invisible to the window $K$, then $\|e\|_1 \ge 2K$.
   Hence $\operatorname{minMass}(K) \ge 2K$.

*Proof sketch.* (1) The case $k=0$ of the hypothesis gives $|s| = |t| =: n$.
Suppose $n < K$. Then $p_k(s) = p_k(t)$ holds for all $k \le n$ (since
$n \le K-1$), so Proposition 3.3, applied after the inclusion
$\mathbb{N} \hookrightarrow \mathbb{Q}$, yields $s = t$, contradicting
distinctness. Hence $n \ge K$ and the total is $\ge 2K$.
(2) Apply Lemma 2.7 to obtain a near miss $(s(e),t(e))$ at window $K$, and use
$\|e\|_1 = |s(e)| + |t(e)| \ge 2K$. $\square$

**Remark 3.5.** The essential point is the passage from *sets of positions* to
*multisets of units*. Bounds derived from the support of $e$ (for instance via
Lagrange interpolation against the window, which yields
$\|e\|_1 \ge K+1$, or geometric refinements giving $K+2$) cannot exceed the
number of distinct nodes and are therefore intrinsically weaker; the Newton
argument counts multiplicity and is exact. For $K \ge 3$ the bound $2K$
strictly improves $K+2$, and the improvement is unbounded.

---

## 4. Attainment: explicit ideal configurations

**Lemma 4.1 (from node lists to vectors).** Let $A, B$ be lists of naturals
bounded by $N$, with $A$ nonempty and $A \cap B = \emptyset$, and suppose
$p_k(A) = p_k(B)$ for all $k < K$. Define
$e_j = \#\{i : A_i = j\} - \#\{i : B_i = j\}$. Then

* $e$ is invisible to the window $K$ on $\{0,\dots,N\}$;
* $m_k(e) = p_k(A) - p_k(B)$ for every $k$, so $e$ becomes visible exactly at
  the first index where the power sums differ;
* $e \ne 0$;
* $\|e\|_1 = |A| + |B|$.

*Proof sketch.* The moment identity is a rearrangement of the defining sums
(each element $a \in A$ contributes $a^k$). Disjointness makes
$|e_j| = \#\{i: A_i = j\} + \#\{i : B_i = j\}$ pointwise, and summing over
$j \le N$ gives $|A|+|B|$ because every element of either list is $\le N$.
Nonvanishing follows because $A$ is nonempty and its elements are absent from
$B$. $\square$

**Proposition 4.2 (certified witnesses).** For each $K$ in the table below the
listed pair $(A,B)$ consists of two disjoint sets of $K$ naturals with
$p_k(A) = p_k(B)$ for all $k < K$ and $p_K(A) \ne p_K(B)$; hence by Lemma 4.1
the value $2K$ is achievable at window $K$.

| $K$ | $A$ | $B$ |
|---|---|---|
| 1 | $\{0\}$ | $\{1\}$ |
| 2 | $\{0,3\}$ | $\{1,2\}$ |
| 3 | $\{1,5,6\}$ | $\{2,3,7\}$ |
| 4 | $\{0,4,7,11\}$ | $\{1,2,9,10\}$ |
| 5 | $\{1,2,10,14,18\}$ | $\{0,4,8,16,17\}$ |
| 6 | $\{0,5,6,16,17,22\}$ | $\{1,2,10,12,20,21\}$ |
| 7 | $\{0,18,27,58,64,89,101\}$ | $\{1,13,38,44,75,84,102\}$ |
| 8 | $\{0,4,9,23,27,41,46,50\}$ | $\{1,2,11,20,30,39,48,49\}$ |
| 9 | $\{0,24,30,83,86,133,157,181,197\}$ | $\{1,17,41,65,112,115,168,174,198\}$ |
| 10 | $\{12,2865,3519,11869,23738,23762,35631,43981,44635,47488\}$ | $\{0,3083,3301,11893,23314,24186,35607,44199,44417,47500\}$ |
| 12 | $\{0,11,24,65,90,129,173,212,237,278,291,302\}$ | $\{3,5,30,57,104,116,186,198,245,272,297,299\}$ |

*Proof sketch.* Each row is a finite list of integer identities
$p_k(A) = p_k(B)$, $k < K$, verified by direct evaluation (the largest such
identity involves ninth powers of numbers up to $47\,500$). Disjointness and
cardinality are immediate. $\square$

**Theorem 4.3 (exact values).** For $1 \le K \le 10$ and for $K = 12$,

$$\operatorname{minMass}(K) = 2K .$$

*Proof.* Theorem 3.4(2) gives $\ge 2K$; Proposition 4.2 with Lemma 4.1 gives
$\le 2K$. $\square$

**Corollary 4.4 (the binomial stencil is far from optimal).** For
$4 \le K \le 10$ and $K = 12$ one has $\operatorname{minMass}(K) < 2^K$, with
the gap growing exponentially; e.g. $51 \cdot \operatorname{minMass}(10) < 2^{10}$
and $\operatorname{minMass}(12) = 24$ against $2^{12} = 4096$.

**Lemma 4.5 (parity).** For $K \ge 1$, $\operatorname{minMass}(K)$ is even.

*Proof sketch.* An invisible vector has $m_0(e) = \sum_j e_j = 0$, so the
positive and negative parts have equal total, whence
$\|e\|_1 = 2\sum_{j : e_j>0} e_j$ is even. $\square$

---

## 5. Exact characterisation of equality, and rigidity

**Lemma 5.1 (mass of a disjoint near miss).** If $s,t$ are multisets of
naturals bounded by $N$ with no common element, then the vector
$e_j = \mathrm{mult}_s(j) - \mathrm{mult}_t(j)$ satisfies
$\|e\|_1 = |s| + |t|$.

*Proof sketch.* Disjointness means that for each $j$ at most one of the two
multiplicities is nonzero, so $|a-b| = a+b$ pointwise. $\square$

**Theorem 5.2 (equality characterisation).** For every $K$,

$$\operatorname{minMass}(K) = 2K \iff \mathrm{Ideal}(K).$$

*Proof sketch.* ($\Leftarrow$) Given an ideal configuration $(s,t)$, Lemma 5.1
produces a nonzero invisible vector of mass exactly $2K$; combined with
Theorem 3.4 this pins the minimum.
($\Rightarrow$) Let $e$ realise the minimum $2K$ and pass to $s = s(e)$,
$t = t(e)$. By Lemma 2.7 these form a near miss at window $K$, and by Theorem
3.4(1) each has cardinality $\ge K$; since $|s|+|t| = 2K$, both equal $K$
exactly. Disjointness — the remaining requirement — is Theorem 5.5 below. $\square$

**Corollary 5.3.** $\mathrm{Ideal}(K)$ holds for $1 \le K \le 10$ and $K = 12$.
Moreover, if $\mathrm{Ideal}(K)$ fails for some $K \ge 1$ then
$\operatorname{minMass}(K) \ge 2K+2$.

**Corollary 5.4 (the boundary case $K=11$).**
$\operatorname{minMass}(11) \in \{22,24\}$, and

$$\operatorname{minMass}(11) = 22 \iff \mathrm{Ideal}(11), \qquad
\operatorname{minMass}(11) = 24 \implies \neg\,\mathrm{Ideal}(11).$$

*Proof sketch.* Theorem 3.4 gives $\ge 22$. Restricting the size-$12$ witness
to the smaller window gives $\le 24$ (monotonicity: invisibility to a window
$K$ implies invisibility to every smaller window). Lemma 4.5 excludes the odd
value $23$. The equivalence is Theorem 5.2 at $K = 11$. $\square$

Thus the century-old question of the existence of an ideal size-$11$
configuration is exactly the question of which of two explicit integers the
invariant $\operatorname{minMass}(11)$ equals.

**Theorem 5.5 (rigidity of size-minimal near misses).** Let $(s,t)$ be a near
miss at window $K$ with $|s| = |t| = K$. Then $s$ and $t$ are disjoint: no
natural number lies in both.

*Proof sketch.* Put $F(X) = \prod_{a \in s}(X-a)$ and
$G(X) = \prod_{b\in t}(X-b)$ in $\mathbb{Q}[X]$; both are monic of degree $K$.
By Lemma 3.2 the elementary symmetric functions of $s$ and $t$ agree in
degrees $\le K-1$, so $F$ and $G$ agree in all coefficients of degree $\ge 1$;
that is, $F - G$ is a constant $c$. If $c = 0$ then $F=G$ and hence $s=t$,
contradicting distinctness; so $c \ne 0$. A common element $a \in s \cap t$
would be a root of both, giving $c = F(a)-G(a) = 0$, a contradiction. $\square$

Rigidity has a structural reading: while general near misses admit "padding"
(adding a common element to both sides preserves equal power sums), the
padding freedom disappears exactly at the minimal size. Minimal-mass invisible
vectors are therefore genuinely $\pm1$-valued on $2K$ distinct nodes.

---

## 6. The composition calculus

### 6.1 Convolution

For vectors $w$ supported on $\{0,\dots,M\}$ and $e$ supported on
$\{0,\dots,N\}$ define the convolution

$$(w * e)_j \;=\; \sum_{a=0}^{M} w_a\, e_{j-a},$$

supported on $\{0,\dots,M+N\}$; in generating-function terms
$P_{w*e} = P_w P_e$ where $P_e(X) = \sum_j e_j X^j$.

**Lemma 6.1 (windows add, masses multiply, top moments multiply).** Let $w$ be
invisible to the window $K_1$ on $\{0,\dots,M\}$ and $e$ invisible to the
window $K_2$ on $\{0,\dots,N\}$. Then

1. $w*e$ is invisible to the window $K_1+K_2$ on $\{0,\dots,M+N\}$;
2. $\|w*e\|_1 \le \|w\|_1 \, \|e\|_1$;
3. $m_{K_1+K_2}(w*e) = \binom{K_1+K_2}{K_2}\, m_{K_2}(e)\, m_{K_1}(w)$.

*Proof sketch.* Expand $m_k(w*e) = \sum_{a,i} w_a e_i (a+i)^k$ by the binomial
theorem into $\sum_{r} \binom{k}{r} m_r(w)\, m_{k-r}(e)$. Every term of a sum
with $k < K_1+K_2$ has either $r < K_1$ or $k - r < K_2$, hence vanishes,
proving (1); at $k = K_1+K_2$ exactly the single term $r = K_1$ survives,
proving (3). Part (2) is the triangle inequality applied coefficientwise. $\square$

Note that (3) is what guarantees the convolution is nonzero: if $m_{K_1}(w)$
and $m_{K_2}(e)$ are nonzero then so is $m_{K_1+K_2}(w*e)$, and a vector with
a nonvanishing moment cannot vanish identically.

### 6.2 Submultiplicativity

The only subtlety in deducing submultiplicativity of
$\operatorname{minMass}$ is that a mass-optimal witness carries no a priori
information about its first *visible* moment. This is supplied by:

**Lemma 6.2a (first visible moment).** Every nonzero vector $e$ supported on
$\{0,\dots,N\}$ has a well-defined *sharp window*: an integer $K^\star \ge$
(its invisibility window) with $m_k(e) = 0$ for all $k < K^\star$ and
$m_{K^\star}(e) \ne 0$.

*Proof sketch.* If every moment vanished, then testing $e$ against Lagrange
interpolation polynomials for the nodes $\{0,\dots,N\}$ — each a
$\mathbb{Q}$-combination of the monomials $X^k$, $k \le N$ — would give
$e_j = 0$ for each $j$, contradicting $e \ne 0$. So the set of indices $k$
with $m_k(e) \ne 0$ is nonempty; take its least element that is at least the
invisibility window. $\square$

**Theorem 6.2 (submultiplicativity).** For all $K_1, K_2$,

$$\operatorname{minMass}(K_1+K_2) \;\le\; \operatorname{minMass}(K_1)\cdot\operatorname{minMass}(K_2).$$

*Proof sketch.* Take mass-optimal witnesses $w$ (window $K_1$) and $e$ (window
$K_2$). By Lemma 6.2a, replace their windows by their sharp windows
$K_1^\star \ge K_1$, $K_2^\star \ge K_2$. Then $w*e$ is invisible to
$K_1^\star + K_2^\star \ge K_1+K_2$, is nonzero by Lemma 6.1(3), and has mass
at most the product. Invisibility is monotone in the window, so $w*e$ certifies
the bound at $K_1+K_2$. $\square$

**Corollary 6.3 (iteration).**
$\operatorname{minMass}(nK) \le \operatorname{minMass}(K)^n$ for all $n,K$.

**Proposition 6.4 (strictness).** The inequality of Theorem 6.2 is strict at
$(K_1,K_2) = (2,2)$: $\operatorname{minMass}(4) = 8 < 16 = \operatorname{minMass}(2)^2$.

Consequently, composition is *never* optimal at windows where an ideal
configuration exists; its value is that it extends beyond them. Sample
consequences of composing certified witnesses:
$\operatorname{minMass}(13) \le 48$ (sizes $12$ and $1$) and
$\operatorname{minMass}(22) \le 480$ (sizes $12$ and $10$; the actual mass of
that convolution is $464$, so even the certified bound is not tight).

### 6.3 The seeded engine

**Theorem 6.5 (seeded engine).** Let $w$ be invisible to the window $K_0$ on
$\{0,\dots,M\}$, with $m_{K_0}(w) \ne 0$ and $\|w\|_1 = L$. Then for every
$n \in \mathbb{N}$ there exist $N$ and a vector $\varepsilon$ supported on
$\{0,\dots,N\}$ such that

* $\varepsilon$ is invisible to the window $K_0 n$;
* $m_{K_0n}(\varepsilon) \ne 0$ (in particular $\varepsilon \ne 0$);
* $\|\varepsilon\|_1 \le L^n$.

*Proof sketch.* Induct on $n$. For $n = 0$ take $\varepsilon = \delta_0$, the
unit mass at the origin: it is (vacuously) invisible to the empty window, has
$m_0 = 1 \ne 0$ and mass $1 = L^0$. For the step, convolve the vector
$\varepsilon_n$ produced at stage $n$ with the seed $w$: by Lemma 6.1(1) the
window becomes $K_0n + K_0 = K_0(n+1)$; by Lemma 6.1(3) the new top moment is
$\binom{K_0(n+1)}{K_0 n} m_{K_0 n}(\varepsilon_n) m_{K_0}(w) \ne 0$; and by
Lemma 6.1(2) the mass is at most $L \cdot L^n = L^{n+1}$ (using $L \ge 0$).
$\square$

The seeded formulation isolates exactly what a construction must provide: a
window, a mass, and a certificate of first visibility. Nothing else in the
argument depends on the seed.

---

## 7. The growth base

**Theorem 7.1 (ideal size-$12$ seed).** For every $n$ there is a nonzero
integer vector, supported on $\{0,\dots,302n\}$, invisible to the window $12n$
and of mass at most $24^n$.

*Proof sketch.* Apply Theorem 6.5 with $w$ the weight vector of the size-$12$
configuration of Proposition 4.2: $\|w\|_1 = 24$, window $12$, and
$m_{12}(w) = p_{12}(A) - p_{12}(B) \ne 0$ by Lemma 4.1 and direct evaluation
of the two twelfth power sums. $\square$

**Theorem 7.2 (quantitative comparison).** At the common window $12n$, the
bound of Theorem 7.1 is $24^n$, while iterating the size-$3$ configuration
(window $3$, mass $6$) gives only $6^{4n}$. These satisfy the exact identity

$$24^n \cdot 54^n \;=\; 6^{4n},$$

so the new bound is smaller by the factor $54^n$, strictly for every $n\ge1$.

**Corollary 7.3 (the bracket).** For every $K \ge 0$,

$$2K \;\le\; \operatorname{minMass}(K) \;\le\; 24^{\lceil K/12\rceil}
\;=\; 24^{\lfloor (K+11)/12\rfloor},$$

and, in integer form free of real exponentials,

$$\operatorname{minMass}(K)^{12} \;\le\; 24^{\,K+11}.$$

*Proof sketch.* The lower bound is Theorem 3.4. For the upper bound take
$n = \lceil K/12\rceil$ in Theorem 7.1 and note $K \le 12n$, so the constructed
vector is also invisible to the window $K$; it is nonzero, so it certifies
$\operatorname{minMass}(K) \le 24^{n}$. Raising this to the twelfth power and
using $12\lceil K/12\rceil \le K+11$ gives the integer form. $\square$

**Remark 7.4 (numerics and honest scope).** The growth base of the upper bound
is $24^{1/12} = 1.30322\ldots$, against $6^{1/3} = 1.81712\ldots$ for the
size-$3$ seed and $2$ for the binomial stencil. The bound
$24^{\lceil K/12\rceil}$ is only better than the trivial $2^K$ from $K = 13$
onwards; for $K \le 12$ the explicit witnesses of Theorem 4.3 are far
stronger. The engine's value is uniformity and extensibility, not superiority
in the small range. Numerically, the actual masses of the iterated seed are
smaller still than the certificate: $24$, $512$, $7\,308$ at windows $12$,
$24$, $36$, against certificates $24$, $576$, $13\,824$.

**Remark 7.5 (future seeds).** An ideal configuration of size $n_0$ is a seed
of mass $2n_0$ at window $n_0$, giving base $(2n_0)^{1/n_0} \to 1$. Hence, for
this method, "$\operatorname{minMass}$ grows subexponentially in every base"
is equivalent to "ideal configurations of unbounded size exist".

---

## 8. The polynomial dictionary

**Definition 8.1.** For $P \in \mathbb{Z}[X]$ set
$\operatorname{polyMass}(P) = \sum_{j} |[X^j]P|$, the $\ell^1$ norm of the
coefficient vector.

**Theorem 8.2 (dictionary).** For all $K, L$, the value $L$ is achievable at
window $K$ (Definition 2.3) if and only if there exists $P \in \mathbb{Z}[X]$
with $P \ne 0$, $(X-1)^K \mid P$ and $\operatorname{polyMass}(P) = L$.
Consequently

$$\operatorname{minMass}(K) \;=\; \min\{\operatorname{polyMass}(P) :
P \in \mathbb{Z}[X],\ P \ne 0,\ (X-1)^K \mid P\}.$$

*Proof sketch.* Associate to $e$ the polynomial $P_e = \sum_j e_j X^j$. The
substitution $X \mapsto 1 + Y$ turns the coefficient of $Y^k$ in
$P_e(1+Y)$ into $\sum_j \binom{j}{k} e_j$, and the family
$\{\binom{j}{k}\}_{k<K}$ spans the same space of test functions on $j$ as
$\{j^k\}_{k<K}$ (unitriangular change of basis). Hence
$m_k(e) = 0$ for $k<K$ if and only if $Y^K$ divides $P_e(1+Y)$, i.e.
$(X-1)^K \mid P_e$. Masses correspond by definition. The identification of
values (not merely minima) requires care only in the degenerate range
$K > \deg$, where invisibility already forces the vector to vanish. $\square$

**Corollary 8.3 (polynomial mass bound).** If $P \in \mathbb{Z}[X]$ is nonzero
and divisible by $(X-1)^K$, then $\operatorname{polyMass}(P) \ge 2K$; and
$2K$ is attained for every $K \le 10$ and for $K = 12$.

**Corollary 8.4 (certificate reading).** A nonzero $P \in \mathbb{Z}[X]$ with
$(X-1)^K \mid P$ and $\operatorname{polyMass}(P) = 2K$ yields an ideal
Prouhet–Tarry–Escott configuration of size $K$ (its positive and negative
coefficient supports, all coefficients being $\pm 1$ by rigidity).

The dictionary explains the shape of the constructions. The polynomial
$(X-1)^K$ has coefficient norm $2^K$; convolution corresponds to multiplying
sparse factors, and products of the form $\prod_{i}(X^{a_i}-1)$ are always
divisible by $(X-1)^K$ when there are $K$ factors. Minimising the coefficient
norm inside the ideal $((X-1)^K)$ is therefore a question about cancellation
in products of binomials. Even the crudest choice $a_i = i$ gives masses
$2,4,6,8,12,16,20,28,36,44,54,72$ for $K = 1,\dots,12$: far below $2^K$,
though above the ideal $2K$.

---

## 9. Algorithms

Three procedures organise the computational side of the theory.

**(A) Witness certification.** Given lists $A$, $B$ of naturals and a target
window $K$: check $|A| = |B| = K$, check disjointness, and evaluate the $K$
power-sum identities $p_k(A) = p_k(B)$, $k<K$, in exact integer arithmetic,
plus the inequality $p_K(A) \ne p_K(B)$ certifying that visibility begins at
$K$. Cost: $O(K^2)$ big-integer multiplications; the entries can be large
(the size-$10$ configuration has nodes up to $47\,500$ and involves ninth
powers).

**(B) The convolution engine.** Given a certified seed of window $K_0$, mass
$L$ and node bound $M$, and a target $n$: form the $n$-fold convolution power
of the seed's coefficient vector. Cost: $O(n^2 M^2)$ integer operations by
naive convolution (or $O(nM\log(nM))$ per step by transform methods). Output:
a vector of window $\ge K_0n$ and mass $\le L^n$.

**(C) Bracket evaluation.** Given $K$: return the pair
$\big(2K,\ \min(2^K, 24^{\lceil K/12\rceil})\big)$, and the exact value $2K$
when $K \le 10$ or $K = 12$, and the two-element set $\{22,24\}$ when $K=11$.

---

## 10. Applications and interpretation

**Robustness of moment measurements.** Any measurement scheme that reports the
first $K$ power moments of an integer-weighted configuration is
unconditionally robust against perturbations of total size below $2K$: no such
perturbation can be invisible. This is a clean design rule — a budget of $K$
moments buys a guarantee proportional to $K$, with the constant exactly $2$.

**Finite-difference and filter design.** In signal-processing language, a
vector invisible to the window $K$ is a finite impulse response with a
$K$-fold zero at DC. Theorem 8.2 says the minimal coefficient $\ell^1$ norm of
such a filter with integer taps is exactly $\operatorname{minMass}(K)$, and
Theorem 4.3 exhibits integer filters with a $12$-fold zero and coefficient
norm $24$, against the $4096$ of the naive cascade $(1 - z^{-1})^{12}$. Low
coefficient norm bounds the amplification of coefficient-level noise, so these
are quantitatively better realisations.

**Quadrature and cubature.** Rules exact for polynomials of degree $<K$ differ
by elements of $\ker\mathcal{M}_K$; the mass law measures the minimal weight
budget separating two such rules with integer weights, and the ideal
configurations exhibit maximally economical differences.

**Sharp thresholds for identifiability.** Two integer configurations of total
mass $<K$ each are distinguished by their first $K$ moments, since their
difference has mass $<2K$ and would otherwise be an invisible vector. This is
an exact recovery threshold for moment-based identification, with no
constants left unspecified.

---

## 11. Discussion

Three features of the results deserve emphasis.

*The lower bound is structural, the upper bound is arithmetic.* The bound
$2K$ follows from symmetric-function theory alone and holds with no exception.
Everything above $2K$ depends on the arithmetic accident of whether ideal
configurations exist, which is where a century of effort has stalled.

*The invariant is a faithful reformulation, not an analogy.* Theorem 5.2 is an
equivalence, window by window. Theorem 8.2 upgrades it to an equality of
achievable value sets between two extremal problems posed in different
languages (moments versus polynomial divisibility). Consequently, progress in
any one of the three formulations transfers immediately to the other two.

*The engine is a reduction.* Theorem 6.5 depends only on the numerical data
$(K_0, L)$ of a seed. Any new ideal configuration — or indeed any economical
non-ideal invisible vector — immediately improves the growth base to
$L^{1/K_0}$ without altering a single step of the argument. This is why the
step from base $6^{1/3}$ to base $24^{1/12}$ costs nothing beyond
substituting a better witness.

The main limitation is equally clear. The bracket
$2K \le \operatorname{minMass}(K) \le 24^{\lceil K/12\rceil}$ leaves an
exponentially wide gap. Closing it from above by this method requires ideal configurations
of size $> 12$, none of which is known; closing it from below requires an
obstruction argument that no current technique provides, since the Newton
bound is provably tight at eleven of the first twelve windows.

---

## 12. Future directions

Derived from the results above on the mass ($\ell^1$) theory of weight vectors
invisible to a truncated power-sum window. Settled here: the exact mass law
$\text{mass} \ge 2K$ via Newton's identities; the exact minimum
$\operatorname{minMass}(K) = 2K$ for $K \le 10$ and $K = 12$ by certified ideal
Prouhet–Tarry–Escott witnesses; the equivalence
$\operatorname{minMass}(K) = 2K \iff \mathrm{Ideal}(K)$, hence the sharp
dichotomy at $K = 11$; submultiplicativity
$\operatorname{minMass}(K_1+K_2) \le \operatorname{minMass}(K_1)\operatorname{minMass}(K_2)$,
strict at $(2,2)$; the improved growth base $24^{1/12} \approx 1.3032$
(previously $6^{1/3} \approx 1.8171$); and the polynomial dictionary
identifying $\operatorname{minMass}(K)$ with the least coefficient-$\ell^1$
norm of a nonzero integer polynomial divisible by $(X-1)^K$.

### 12.1 Polynomial mass growth for truncated power-sum windows

**Conjecture.** $\operatorname{minMass}(K) = 2K$ for every $K \ge 1$;
equivalently, ideal Prouhet–Tarry–Escott configurations of every size exist,
and every nonzero integer polynomial divisible by $(X-1)^K$ has
coefficient-$\ell^1$ norm $\ge 2K$ with equality attained.

The key insight is that $\operatorname{minMass}$ is now known to be *pinned*
between $2K$ and an exponential bound produced by a single seed, so the whole
question collapses to whether better seeds exist — an existence problem about
integer polynomials with a $K$-fold root at $1$, not about power sums. The
equivalence $\operatorname{minMass}(K) = 2K \iff \mathrm{Ideal}(K)$ means that
any new construction, or any nonexistence proof, plugs directly into the
framework, and the case $K = 11$ is already reduced to two numerical
alternatives.

### 12.2 Ideal size-eleven configuration

**Conjecture.** $\operatorname{minMass}(11) = 24$; that is, **no** ideal
Prouhet–Tarry–Escott pair of size $11$ exists — the first genuine gap in the
sequence.

The key insight is that the dichotomy reduces a century-old open problem to a
two-valued invariant. A proof of *either* alternative is a complete answer.
The parity lemma already excludes $23$, the Newton bound excludes everything
below $22$, and the size-$12$ witness supplies $24$; the remaining task is a
finite-flavoured obstruction argument — congruences modulo small primes on the
coefficient vector, or a $2$-adic valuation obstruction for $(X-1)^{11}$.

### 12.3 Subexponential seeds via sparse cyclotomic products

**Conjecture.** For every $K$ there is a nonzero $P \in \mathbb{Z}[X]$ with
$(X-1)^K \mid P$ and $\operatorname{polyMass}(P) \le \exp(C\sqrt{K \log K})$,
obtained as a product $\prod_{i \le K}(X^{a_i}-1)$ with a carefully chosen
exponent sequence.

The key insight is that convolution of invisible vectors *is* multiplication
of such sparse factors, so the growth base is governed by the amount of
coefficient cancellation available in products of binomials — the
Erdős–Szekeres circle of problems, transplanted into the invisible-vector
setting.

### 12.4 Beyond ideal seeds

The engine accepts any seed, not just ideal ones. A non-ideal invisible vector
of window $K_0$ and mass $L$ with $L^{1/K_0} < 24^{1/12}$ would
improve the record without solving the Prouhet–Tarry–Escott problem. Searching
the space of sparse integer polynomials divisible by $(X-1)^{K_0}$ for
$13 \le K_0 \le 30$, with coefficient norm below $24^{K_0/12}$, is a concrete
finite computation whose success would be immediately certifiable.

### 12.5 Real and rational weights

Everything above concerns integer weights, where mass is quantised. For real
weights the normalised problem (mass minimised subject to a normalisation such
as $\max_j |e_j| = 1$, or a fixed leading moment) is a linear program, and its
value as a function of $K$ interpolates the integral invariant from below.
Determining that value, and the gap between the real and integral problems,
would clarify how much of the difficulty is arithmetic and how much is
geometric.

---

## 13. Conclusion

The cost of hiding from the first $K$ power moments is at least $2K$ units of
integer mass, and this is exactly right for every window size up to $12$
except possibly $11$, where the answer is one of two explicit numbers.
Uniformly in $K$, hiding is possible at cost $24^{\lceil K/12\rceil}$, so the
per-unit-window cost of invisibility is at most $24^{1/12} \approx 1.3032$,
well below the classical finite-difference rate $2$. Between the linear floor
and the exponential ceiling lies a single, sharply posed arithmetic question —
the existence of ideal Prouhet–Tarry–Escott configurations of large size — and
the composition machinery ensures that every future answer to it upgrades the
whole theory automatically.
