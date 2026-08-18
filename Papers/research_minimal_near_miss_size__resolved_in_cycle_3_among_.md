# Power-Sum Near Misses on Arbitrary Node Sets: Inverse Nodal Weights, Rigidity, and Support

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

Let $A$ be a set of $N+1$ distinct natural numbers and let $s, t$ be multisets with all values
in $A$. Call $(s,t)$ a *near miss at level $N$* if $s \neq t$ and the power sums
$p_k(s) = \sum_{x \in s} x^k$ and $p_k(t)$ agree for every $k < N$. We prove that the
multiplicity difference $e(a) = m_s(a) - m_t(a)$ of any near miss obeys the *inverse nodal
weight law*
$$e(a) \cdot \prod_{b \in A \setminus \{a\}} (a-b) \;=\; c \qquad (a \in A),$$
with a single constant $c$ independent of $a$; equivalently, the kernel of the truncated
$N \times (N+1)$ Vandermonde system on the nodes of $A$ is the line spanned by the inverse nodal
weights $a \mapsto 1/w(a)$, $w(a) = \prod_{b \neq a}(a - b)$. The result holds verbatim over an
arbitrary field, and its proof is a two-way count of one linear functional evaluated on a
Lagrange basis polynomial. Four consequences follow. **(i) Rigidity:** since $w(a) \neq 0$, a
near miss differing at no node exists only trivially — if $m_s(a_0) = m_t(a_0)$ for a single
$a_0 \in A$, then $s = t$. **(ii) Support:** the two supports cover $A$, so
$|\operatorname{supp} s| + |\operatorname{supp} t| \geq N+1$ and the larger side uses at least
$\lceil (N+1)/2 \rceil$ distinct values; both bounds are attained on the interval
$A = \{0,\dots,N\}$ by the binomial pair, so $\lceil (N+1)/2 \rceil$ is optimal in the wide class
of arbitrary node sets. **(iii) Classification on the interval:** every near miss on
$\{0,\dots,N\}$ is $\lambda$ times the binomial pair plus common padding, with $\lambda \geq 1$;
consequently one integer controls the discrepancy of *every* test function, that discrepancy is
$\lambda \cdot (-1)^N \Delta^N f(0)$, and the generating functions satisfy
$\sum_{x\in s} q^x - \sum_{x \in t} q^x = \lambda (1-q)^N$. **(iv) Extremal node sets:** the law
turns "how small can a near miss on $A$ be?" into the explicit arithmetic functional
$m(A) = \frac12 \sum_a |v(a)|$, $v$ the primitive integer multiple of $1/w$. We show by explicit
example that, contrary to a natural conjecture, the interval does *not* minimise $m$: the node
sets $\{0,1,3,4\}$ and $\{0,1,4,6,9,10\}$ give near misses of sizes $3$ and $6$ against the
interval values $4$ and $16$. The minimisation of $m$ is exactly the Prouhet–Tarry–Escott
problem, restated as an extremal inequality for a single rational functional of the node set.

**Keywords:** power sums, Prouhet–Tarry–Escott problem, Vandermonde kernel, Lagrange
interpolation, nodal weights, finite differences, moment matching, multiset combinatorics.

---

## 1. Introduction

### 1.1 The problem

Fix $N \in \mathbb{N}$. For a finite multiset $s$ of natural numbers write $m_s(a)$ for the
multiplicity of $a$ in $s$, $|s| = \sum_a m_s(a)$ for its cardinality, $\operatorname{supp} s$
for its set of distinct values, and
$$p_k(s) \;=\; \sum_{x \in s} x^k \;=\; \sum_{a} m_s(a)\, a^k \qquad (k \geq 0),$$
with the convention $0^0 = 1$, so that $p_0(s) = |s|$.

> **Definition 1 (Near miss).** Let $A$ be a finite set of natural numbers with $|A| = N + 1$.
> A pair $(s,t)$ of multisets with $\operatorname{supp} s \cup \operatorname{supp} t \subseteq A$
> is a **near miss at level $N$ on $A$** if $s \neq t$ and $p_k(s) = p_k(t)$ for every
> $k \in \{0, 1, \dots, N-1\}$.

Thus a near miss matches the first $N$ moments — count, total, sum of squares, …, sum of
$(N-1)$-st powers — but the two multisets are different. The number of free parameters is
suggestive: the multiplicity difference $e = m_s - m_t$ is an integer vector with $N+1$
coordinates, subject to $N$ homogeneous linear conditions, so one expects a one-dimensional
solution space. Making this precise, and extracting its combinatorial consequences, is the
content of this paper.

### 1.2 Classical background: the binomial pair

For the interval $A = \{0,1,\dots,N\}$ there is a canonical example. Define the **binomial pair**
$$\mathrm{Ev}_N \;=\; \bigl\{\, j \text{ with multiplicity } \tbinom{N}{j} \;:\; 0 \le j \le N,\ j \text{ even} \,\bigr\},$$
$$\mathrm{Od}_N \;=\; \bigl\{\, j \text{ with multiplicity } \tbinom{N}{j} \;:\; 0 \le j \le N,\ j \text{ odd} \,\bigr\}.$$
The identity $\sum_{j=0}^N (-1)^j \binom{N}{j} j^k = 0$ for $k < N$ (and $= (-1)^N N!$ for
$k = N$) says exactly that $(\mathrm{Ev}_N, \mathrm{Od}_N)$ is a near miss at level $N$, failing
at $k = N$ with gap $N!$. Both sides have $2^{N-1}$ elements for $N \geq 1$; the supports are the
even and odd elements of $\{0,\dots,N\}$, of sizes $\lceil (N+1)/2\rceil = \lfloor N/2\rfloor + 1$
and $\lfloor (N+1)/2 \rfloor$.

For $N = 4$:
$$\mathrm{Ev}_4 = \{0, 2^{(6)}, 4\}, \qquad \mathrm{Od}_4 = \{1^{(4)}, 3^{(4)}\},$$
with $p_0 = 8$, $p_1 = 16$, $p_2 = 40$, $p_3 = 112$ on both sides, and $p_4 = 352 \neq 328$.

Restricting attention to *sets* rather than multisets, and asking for near misses with fewer
terms than $N+1$, is the Prouhet–Tarry–Escott problem, open in general since the nineteenth
century. Our results concern the multiset problem with a prescribed value set, where a complete
answer is available.

### 1.3 Results

* **Theorem A (Vandermonde kernel).** Over an arbitrary field, for $N+1$ distinct nodes, any
  weight vector annihilating all power sums of order $k < N$ satisfies
  $e(a) w(a) = \sum_{a} e(a) a^N$ for every node $a$, where $w(a) = \prod_{b \ne a}(a-b)$. The
  kernel of the truncated Vandermonde system is the line spanned by $1/w$.
* **Theorem B (Near misses on an arbitrary node set).** Two multisets valued in a set $A$ of
  $N+1$ naturals which agree on all power sums of order $k < N$ have multiplicity difference
  proportional to $1/w$, with one universal constant of proportionality.
* **Theorem C (Rigidity).** Agreement of the two multiplicities at a single node forces $s = t$.
* **Theorem D (Support).** For a genuine near miss on $A$, $\operatorname{supp} s \cup
  \operatorname{supp} t = A$; hence the support sizes sum to at least $N+1$ and the larger is at
  least $\lceil (N+1)/2 \rceil$. Both bounds are attained.
* **Theorem E (Classification and universality on the interval).** Every near miss on
  $\{0,\dots,N\}$ is $\lambda \cdot (\mathrm{Ev}_N, \mathrm{Od}_N)$ plus a common padding; and
  for every $f$, $\sum_{x\in s} f(x) - \sum_{x \in t} f(x) = \lambda (-1)^N \Delta^N f(0)$.
* **Proposition F (The interval is not extremal).** The minimal near-miss cardinality on the
  node set $\{0,1,3,4\}$ is $3 < 2^{3-1} = 4$, and on $\{0,1,4,6,9,10\}$ it is $6 < 2^{5-1} = 16$.

---

## 2. Nodal weights and the truncated Vandermonde kernel

### 2.1 Setup

Let $F$ be a field and let $v : S \to F$ be an injective map on a finite index set $S$ with
$|S| = N+1$; write $v_i$ for the nodes. The **nodal weight** at $i$ is
$$w_i \;=\; \prod_{j \in S,\, j \neq i} (v_i - v_j) \;\in\; F^{\times},$$
nonzero because the nodes are distinct. The **Lagrange basis polynomial** at $i$ is
$$L_i(X) \;=\; \prod_{j \neq i} \frac{X - v_j}{v_i - v_j},$$
the unique polynomial of degree $N$ with $L_i(v_i) = 1$ and $L_i(v_j) = 0$ for $j \neq i$. Its
leading coefficient is $1/w_i$.

### 2.2 The kernel theorem

> **Theorem A (Kernel of the truncated Vandermonde system).** Let $v : S \to F$ be injective with
> $|S| = N + 1$, and let $e : S \to F$ satisfy
> $$\sum_{i \in S} e_i\, v_i^{\,k} \;=\; 0 \qquad \text{for all } k < N.$$
> Then for every $i_0 \in S$,
> $$e_{i_0} \cdot \prod_{j \neq i_0} (v_{i_0} - v_j) \;=\; \sum_{i \in S} e_i\, v_i^{\,N}.$$
> In particular the quantity $e_i w_i$ is independent of $i$, so the solution space of the
> system is at most one-dimensional, spanned by $i \mapsto 1/w_i$.

*Proof sketch.* Regard $e$ as the linear functional $\Lambda(g) = \sum_{i} e_i\, g(v_i)$ on
polynomials. The hypothesis says $\Lambda(X^k) = 0$ for $k < N$, hence by linearity
$\Lambda(g) = 0$ for every $g$ of degree $< N$.

Evaluate $\Lambda$ on the Lagrange basis polynomial $p = L_{i_0}$ in two ways.

*Combinatorially.* Since $p(v_{i_0}) = 1$ and $p(v_j) = 0$ for $j \neq i_0$, the sum collapses:
$$\Lambda(p) \;=\; \sum_{i \in S} e_i\, p(v_i) \;=\; e_{i_0}.$$

*Algebraically.* Since $\deg p = N$, write $p = \sum_{k=0}^{N} p_k X^k$ and exchange the order of
summation:
$$\Lambda(p) \;=\; \sum_{i \in S} e_i \sum_{k=0}^{N} p_k v_i^k \;=\; \sum_{k=0}^{N} p_k \sum_{i \in S} e_i v_i^k \;=\; p_N \sum_{i \in S} e_i v_i^N,$$
because every term with $k < N$ vanishes by hypothesis. The top coefficient of the Lagrange
basis polynomial is $p_N = 1/w_{i_0}$.

Comparing the two evaluations gives $e_{i_0} = w_{i_0}^{-1} \sum_i e_i v_i^N$, i.e. the claimed
identity after multiplying through by the (nonzero) nodal weight $w_{i_0}$. $\blacksquare$

Two remarks. First, the proof uses nothing beyond the field axioms and the existence of the
Lagrange basis, so it applies to $\mathbb{Q}$, $\mathbb{R}$, $\mathbb{C}$, function fields, and
finite fields of sufficient size alike. Second, the constant on the right-hand side has an
independent meaning: it is the value of the functional on $X^N$, i.e. the *gap* at the first
index where the near miss fails.

> **Corollary A′ (Dimension).** The kernel of the $N \times (N+1)$ matrix $V = (v_i^k)_{k<N,\,i\in S}$
> is exactly one-dimensional, spanned by $(1/w_i)_{i \in S}$.

*Proof sketch.* Theorem A shows $\ker V \subseteq F\cdot(1/w_i)_i$. Conversely $(1/w_i)_i$ does
lie in the kernel: apply the same two-way evaluation to $g = X^k$ with $k < N$, or note that
$\sum_i g(v_i)/w_i$ is the leading coefficient of the interpolant of $g$, which is $0$ whenever
$\deg g < N$. $\blacksquare$

### 2.3 The interval case

For $A = \{0,1,\dots,N\}$,
$$w(a) \;=\; \prod_{b \neq a} (a - b) \;=\; \Bigl(\prod_{b<a}(a-b)\Bigr)\Bigl(\prod_{b>a}(a-b)\Bigr) \;=\; a!\,\cdot\,(-1)^{N-a}(N-a)!,$$
so
$$\frac{1}{w(a)} \;=\; \frac{(-1)^{N-a}}{a!\,(N-a)!} \;=\; \frac{(-1)^{N}}{N!}\,(-1)^{a}\binom{N}{a}.$$
Up to the global constant $(-1)^N/N!$, the inverse nodal weight profile of the interval **is**
the alternating binomial vector. This is the structural reason for the binomial pair, and it
explains why Pascal's triangle plays no role for a general node set.

---

## 3. Near misses on an arbitrary node set

### 3.1 Passing from multisets to weight vectors

If a multiset $s$ takes all values in a finite set $A$, then for every $k$
$$p_k(s) \;=\; \sum_{a \in A} m_s(a)\, a^k,$$
since all values outside $A$ have multiplicity zero. Applying this to $s$ and $t$ and
subtracting, the near-miss hypothesis becomes precisely the linear system of Theorem A for the
weight vector $e(a) = m_s(a) - m_t(a) \in \mathbb{Z} \subset \mathbb{Q}$.

### 3.2 The inverse nodal weight law

> **Theorem B (Near misses on an arbitrary node set).** Let $A \subseteq \mathbb{N}$ with
> $|A| = N+1$, and let $s, t$ be multisets with all values in $A$ satisfying
> $p_k(s) = p_k(t)$ for all $k < N$. Then there is a single rational constant $c$ with
> $$\bigl(m_s(a) - m_t(a)\bigr)\prod_{b \in A \setminus\{a\}} (a - b) \;=\; c \qquad \text{for every } a \in A.$$
> Explicitly $c = \sum_{a \in A} (m_s(a) - m_t(a))\, a^N = p_N(s) - p_N(t)$.

*Proof sketch.* Immediate from §3.1 and Theorem A applied over $F = \mathbb{Q}$ with $S = A$,
$v = $ the inclusion $A \hookrightarrow \mathbb{Q}$ (injective), and $e = m_s - m_t$.
$\blacksquare$

Theorem B is a strong *shape* statement: the profile of a near miss is determined by the node
set alone, before any multiset is chosen. Only the scalar $c$ — equivalently, the top-index gap
$p_N(s) - p_N(t)$ — is free, and integrality of the multiplicities restricts it to a rank-one
lattice.

> **Corollary B′ (The minimal near miss on $A$).** Let $v$ be the primitive integer vector
> proportional to $(1/w(a))_{a \in A}$, obtained by clearing denominators with
> $L = \operatorname{lcm}_a |w(a)|$ and dividing by the content. Then every near miss on $A$ has
> multiplicity difference an integer multiple of $v$, the minimal one has
> $$s^\ast = \{ a \text{ with multiplicity } v(a) : v(a) > 0 \}, \qquad
> t^\ast = \{ a \text{ with multiplicity } -v(a) : v(a) < 0 \},$$
> and the minimal cardinality is
> $$m(A) \;=\; |s^\ast| \;=\; |t^\ast| \;=\; \tfrac12 \sum_{a \in A} |v(a)|.$$

*Proof sketch.* By Theorem B the difference vector lies in the rank-one lattice
$\mathbb{Z}\cdot v$; the case $c = 0$ is $s = t$. The equality $|s^\ast| = |t^\ast|$ is the $k=0$
condition $\sum_a v(a) = 0$, so the positive and negative parts of $v$ have equal mass, each
$\frac12 \sum_a |v(a)|$. Adding a common padding multiset preserves the difference vector and
strictly increases cardinality, so the minimum is attained with empty padding. $\blacksquare$

**Worked example.** $A = \{0,1,4,9\}$, $N = 3$. The nodal weights are
$$w(0) = (0-1)(0-4)(0-9) = -36,\quad w(1) = (1)(-3)(-8) = 24,$$
$$w(4) = (4)(3)(-5) = -60,\quad w(9) = (9)(8)(5) = 360.$$
With $L = \operatorname{lcm}(36,24,60,360) = 360$ we get $L/w = (-10, 15, -6, 1)$, already
primitive. Hence
$$s^\ast = \{1^{(15)}, 9\}, \qquad t^\ast = \{0^{(10)}, 4^{(6)}\},$$
and indeed $p_0 = 16$, $p_1 = 24$, $p_2 = 96$ agree while $p_3 = 744 \neq 384$; the constant is
$c = p_3(s^\ast) - p_3(t^\ast) = 360$, matching $e(9)w(9) = 1 \cdot 360$.

### 3.3 Rigidity

> **Theorem C (Rigidity).** Under the hypotheses of Theorem B, if $m_s(a_0) = m_t(a_0)$ for some
> single node $a_0 \in A$, then $s = t$.

*Proof sketch.* The hypothesis makes the left-hand side of the law vanish at $a_0$, so $c = 0$.
For every $a \in A$ the nodal weight $w(a)$ is a product of differences of distinct integers,
hence nonzero, so $m_s(a) = m_t(a)$ on $A$; outside $A$ both multiplicities are $0$ by
assumption. Two multisets with identical multiplicity functions are equal. $\blacksquare$

Rigidity is what makes the combinatorial consequences of the next section possible: a genuine
near miss must be "active" at every single node.

---

## 4. Support: how many distinct values a near miss needs

> **Theorem D (Support covers the node set).** Let $(s,t)$ be a near miss at level $N$ on a node
> set $A$ with $|A| = N+1$. Then
> $$\operatorname{supp} s \cup \operatorname{supp} t \;=\; A .$$
> Consequently
> $$|\operatorname{supp} s| + |\operatorname{supp} t| \;\geq\; N+1
> \qquad\text{and}\qquad
> \max\bigl(|\operatorname{supp} s|, |\operatorname{supp} t|\bigr) \;\geq\; \Bigl\lceil \tfrac{N+1}{2} \Bigr\rceil .$$

*Proof sketch.* The inclusion $\subseteq$ is the hypothesis that all values lie in $A$. For
$\supseteq$, suppose some $a \in A$ lay in neither support; then $m_s(a) = m_t(a) = 0$, and
Theorem C forces $s = t$, contradicting $s \neq t$. The cardinality statement follows from
$|X \cup Y| \le |X| + |Y|$, and the max bound because $\max(x,y) \geq \lceil (x+y)/2 \rceil$.
$\blacksquare$

> **Theorem D′ (Optimality on the interval).** On $A = \{0,\dots,N\}$ the binomial pair attains
> both bounds:
> $$|\operatorname{supp} \mathrm{Ev}_N| = \Bigl\lfloor \tfrac N2 \Bigr\rfloor + 1 = \Bigl\lceil \tfrac{N+1}{2}\Bigr\rceil,
> \qquad |\operatorname{supp} \mathrm{Od}_N| = \Bigl\lfloor \tfrac{N+1}{2} \Bigr\rfloor,$$
> and their sum is exactly $N+1$. Hence $\lceil (N+1)/2 \rceil$ is the exact minimum of the
> larger support size, and it is not improved by choosing a cleverer node set.

*Proof sketch.* The support of $\mathrm{Ev}_N$ is the set of even elements of $\{0,\dots,N\}$
and that of $\mathrm{Od}_N$ the odd ones, because $\binom{N}{j} > 0$ for $0 \le j \le N$; these
have the stated sizes and are disjoint with union $\{0,\dots,N\}$. Optimality across all node
sets is Theorem D. $\blacksquare$

> **Theorem D″ (Equality is rigid).** On the interval, a near miss satisfies
> $|\operatorname{supp} s| + |\operatorname{supp} t| = N+1$ if and only if the two supports are
> disjoint, if and only if $(s,t) = \lambda\cdot(\mathrm{Ev}_N, \mathrm{Od}_N)$ for some integer
> $\lambda \geq 1$ (up to swapping the two sides). Likewise, a near miss of minimal cardinality
> $|s| = 2^{N-1}$ *is* the binomial pair.

*Proof sketch.* Both statements follow from the classification of §5: writing
$s = \lambda\,\mathrm{Ev}_N + u$, $t = \lambda\,\mathrm{Od}_N + u$, the padding $u$ contributes to
both supports, so the supports intersect exactly in $\operatorname{supp} u$, and
$|\operatorname{supp} s| + |\operatorname{supp} t| = (N+1) + |\operatorname{supp} u|$. Similarly
$|s| = \lambda\, 2^{N-1} + |u|$, which equals $2^{N-1}$ only for $\lambda = 1$, $u = \varnothing$.
$\blacksquare$

---

## 5. The interval: complete classification and universality

On the interval the nodal-weight law can be upgraded from an identity between multiplicity
*vectors* to an identity between *multisets*.

> **Theorem E1 (Structure).** Let $s \neq t$ be multisets with values in $\{0,\dots,N\}$ and
> $p_k(s) = p_k(t)$ for all $k < N$. Then there exist an integer $\lambda \ge 1$ and a multiset
> $u$ with values in $\{0,\dots,N\}$ such that, after possibly swapping $s$ and $t$,
> $$s \;=\; \lambda\cdot \mathrm{Ev}_N + u, \qquad t \;=\; \lambda\cdot \mathrm{Od}_N + u .$$
> Conversely every such pair is a near miss. Thus the near misses at level $N$ are exactly
> parameterised by $(\lambda, u)$ with $\lambda \geq 1$, doubled by the swap.

*Proof sketch.* By Theorem B specialised to the interval (§2.3), the multiplicity difference is
$m_s(j) - m_t(j) = \lambda\,(-1)^j \binom{N}{j}$ with $\lambda = m_s(0) - m_t(0)$; up to the swap
we may take $\lambda \geq 1$, and $\lambda \neq 0$ because $s \neq t$. So $m_s(j) \geq
\lambda\binom{N}{j}$ at even $j$ and $m_t(j) \geq \lambda \binom{N}{j}$ at odd $j$; define
$u(j) = \min(m_s(j), m_t(j))$, which is $m_s - \lambda\binom{N}{\cdot}$ at even $j$ and $m_t$
there, etc. Both sides then differ from $u$ by exactly $\lambda$ copies of the corresponding half
of Pascal's row. The converse is the vanishing of the alternating binomial sum, which makes
$p_k(\lambda\,\mathrm{Ev}_N + u) = p_k(\lambda\,\mathrm{Od}_N + u)$ for $k < N$; the two sides are
distinct because they differ at $j = 0$. $\blacksquare$

> **Theorem E2 (Universality).** For any near miss on $\{0,\dots,N\}$, with
> $\lambda = m_s(0) - m_t(0)$, and for *every* function $f : \mathbb{N} \to \mathbb{Z}$,
> $$\sum_{x \in s} f(x) \;-\; \sum_{x \in t} f(x) \;=\; \lambda \sum_{j=0}^{N} (-1)^j \binom{N}{j} f(j).$$

*Proof sketch.* Expand both weighted sums over multiplicities and substitute the multiplicity
difference from Theorem E1. $\blacksquare$

> **Theorem E3 (Finite-difference form).** With $\Delta g(x) = g(x+1) - g(x)$,
> $$\sum_{x \in s} g(x) \;-\; \sum_{x \in t} g(x) \;=\; \lambda \cdot (-1)^N\,\Delta^N g(0).$$
> Hence a near miss at level $N$ cannot separate any $g$ with $\Delta^N g(0) = 0$ — in
> particular any polynomial of degree $< N$ — and it *does* separate every $g$ with
> $\Delta^N g(0) \neq 0$.

*Proof sketch.* The classical expansion $\Delta^N g(0) = \sum_{j=0}^N (-1)^{N-j}\binom{N}{j} g(j)$
converts Theorem E2 into the stated form; the "does separate" half uses $\lambda \neq 0$, which
holds because $s \neq t$. $\blacksquare$

> **Theorem E4 (Generating function).** In $\mathbb{Z}[q]$,
> $$\sum_{x \in s} q^{x} \;-\; \sum_{x \in t} q^{x} \;=\; \lambda\,(1-q)^N .$$
> Thus "the first $N$ power sums agree" is literally "the discrepancy has a zero of order $N$ at
> $q = 1$", and $\lambda$ is the leading coefficient there.

*Proof sketch.* Take $f(j) = q^j$ in Theorem E2 (coefficientwise, i.e. work in the polynomial
ring) and apply the binomial theorem to $\sum_j (-1)^j \binom Nj q^j = (1-q)^N$. $\blacksquare$

> **Theorem E5 (Polynomial form).** Writing $\chi_s(X) = \prod_{x \in s}(X - x)$ for the monic
> split polynomial of a multiset, every near miss satisfies
> $$\chi_s \cdot \chi_{\mathrm{Od}_N}^{\lambda} \;=\; \chi_t \cdot \chi_{\mathrm{Ev}_N}^{\lambda}$$
> (up to the swap). The *ratio* $\chi_s/\chi_t$ is therefore the fixed rational function
> $\bigl(\prod_{j \text{ even}} (X-j)^{\binom Nj} \big/ \prod_{j \text{ odd}} (X-j)^{\binom Nj}\bigr)^{\lambda}$,
> independent of the padding.

*Proof sketch.* $\chi$ turns multiset addition into multiplication and scaling into powers;
substitute Theorem E1. $\blacksquare$

> **Theorem E6 (Concentration).** For $N \geq 1$, every near miss at level $N$ on the interval
> has $|s| \geq 2^{N-1}$, and some value occurs in $s$ at least $\dfrac{2^{N}}{2(N+1)}$ times.

*Proof sketch.* Cardinality: $|s| = \lambda 2^{N-1} + |u| \ge 2^{N-1}$ by Theorem E1. Pigeonhole:
$s$ has at least $2^{N-1}$ elements distributed over at most $N+1$ distinct values, so the
maximal multiplicity is at least $2^{N-1}/(N+1)$. $\blacksquare$

The moral of §5 is that on the interval the near-miss family, though infinite, is
one-dimensional in every sense that matters: a single integer $\lambda$ and a single universal
functional $\Delta^N(\cdot)(0)$ describe every observable difference between the two sides.

---

## 6. Extremal node sets: the interval is not optimal

Corollary B′ makes the minimal near-miss size on a node set completely explicit:
$$m(A) \;=\; \tfrac12 \sum_{a \in A} |v(a)|, \qquad v \;=\; \frac{L}{w},\quad L = \operatorname{lcm}_{a}|w(a)|,\ \text{divided by its content}.$$
For the interval, $|v(a)| = \binom{N}{a}$ and $m(\{0,\dots,N\}) = \frac12 \sum_a \binom Na =
2^{N-1}$. It is natural to conjecture that the interval, being the tightest possible packing of
$N+1$ nodes, minimises $m$ among all node sets of that size. It does not.

> **Proposition F (Counterexamples).**
> 1. For $A = \{0,1,3,4\}$ ($N = 3$) the nodal weights are $-12, 6, -6, 12$ and the primitive
>    kernel vector is $(-1, 2, -2, 1)$, giving the minimal near miss
>    $$\{1,1,4\} \quad\text{versus}\quad \{0,3,3\},$$
>    of size $3 < 4 = 2^{N-1}$.
> 2. For $A = \{0,1,4,6,9,10\}$ ($N = 5$) the primitive kernel vector is $(-1, 2, -3, 3, -2, 1)$,
>    giving the minimal near miss
>    $$\{1,1,6,6,6,10\} \quad\text{versus}\quad \{0,4,4,4,9,9\},$$
>    of size $6 < 16 = 2^{N-1}$.

*Verification (elementary arithmetic).* For (1):
$$3 = 3,\quad 1+1+4 = 6 = 0+3+3,\quad 1+1+16 = 18 = 0+9+9,$$
while $1+1+64 = 66 \neq 54 = 0+27+27$. For (2):
$$6 = 6,\quad 1+1+6+6+6+10 = 30 = 0+4+4+4+9+9,$$
$$1+1+3\cdot 36+100 = 210 = 3\cdot 16 + 2\cdot 81,$$
$$1+1+3\cdot 216 + 1000 = 1650 = 3\cdot 64 + 2\cdot 729,$$
$$1+1+3\cdot 1296 + 10000 = 13890 = 3\cdot 256 + 2\cdot 6561,$$
while $1+1+3\cdot 7776 + 100000 = 123330 \neq 121170 = 3\cdot 1024 + 2\cdot 59049$. $\blacksquare$

Both winning node sets are **symmetric**: $\{0,1,3,4\}$ and $\{0,1,4,6,9,10\}$ are invariant under
$a \mapsto \max A - a$, and the first is the sumset $\{0,1\} + \{0,3\}$. Symmetry pairs the nodal
weights in equal magnitudes, so the primitive kernel vector is (anti)palindromic — indeed
$(-1,2,-2,1)$ and $(-1,2,-3,3,-2,1)$ — while the *unevenness* of the spacing inflates the weights
of interior nodes and thereby deflates the corresponding multiplicities. Packing the nodes into
an interval does the opposite: it makes every weight as small as possible and every multiplicity
as large as possible.

An exhaustive computation over node sets normalised by $\min A = 0$ inside $\{0,\dots,3N\}$
finds minima $1, 2, 3, 8, 6$ for $N = 1,\dots,5$, versus the interval values $1,2,4,8,16$; the
minimisers at $N=3$ and $N=5$ are the (translates and dilates of the) two sets above. The correct
open question is therefore:

> **Question.** Determine $\min\{\,m(A) : A \subseteq \mathbb{N},\ |A| = N+1\,\}$ and the node sets
> attaining it. Is the minimum polynomially bounded in $N$, or must it grow exponentially for
> infinitely many $N$?

The question is a close relative of the Prouhet–Tarry–Escott problem but not identical to it: here
the number of *conditions* is tied to the number of *nodes* by $|A| = N+1$, and repeated values
are allowed, whereas the classical problem fixes the number of terms per side and asks for as
many conditions as possible with distinct entries. The two meet in the corank-$r$ regime
discussed in §10, where $|A| = N + r$ and the kernel becomes $r$-dimensional.

---

## 7. Algorithms

### 7.1 Constructing the minimal near miss on a node set

Given $A = \{a_0 < a_1 < \dots < a_N\}$:

1. Compute the nodal weights $w(a_i) = \prod_{j\ne i}(a_i - a_j)$ — $O(N^2)$ integer
   multiplications, each on numbers of size $O(N \log \max A)$ bits.
2. Set $L = \operatorname{lcm}_i |w(a_i)|$ and $v(a_i) = \operatorname{sgn}(w(a_i))\, L/|w(a_i)|$.
3. Divide $v$ by the gcd of its entries to obtain the primitive kernel vector.
4. Output $s^\ast = \{a : v(a) > 0\}$ with multiplicities $v(a)$, and $t^\ast = \{a : v(a) < 0\}$
   with multiplicities $-v(a)$.

Correctness is Corollary B′. The total cost is $O(N^2)$ big-integer operations. Step 3 is what
makes the output minimal; skipping it produces a valid but non-primitive near miss.

### 7.2 Verifying a near miss and locating its failure index

Given multisets $s, t$ and a level $N$, compute $p_k(s), p_k(t)$ for $k = 0, \dots, N$ by Horner
evaluation, $O(N \cdot |{\operatorname{supp} s}| )$ multiplications. The pair is a near miss iff
all $k < N$ agree; the constant of Theorem B is then read off as $c = p_N(s) - p_N(t)$, and can
be cross-checked against $e(a)w(a)$ at any single node — an $O(N)$ consistency test that detects
input errors immediately.

### 7.3 Certifying universality

To confirm Theorem E3 numerically for a given test function $f$, compute
$\sum_{x\in s} f(x) - \sum_{x \in t} f(x)$ directly and compare with
$\lambda\,(-1)^N \sum_{j} (-1)^{N-j}\binom{N}{j} f(j)$. Both sides cost $O(N)$ evaluations of
$f$. Doing this for an exponential, a factorial, and an indicator function is a strong test,
because those functions lie far outside the polynomial world in which the near-miss condition was
posed.

---

## 8. Applications

**Numerical quadrature.** An interpolatory quadrature rule on nodes $A$ assigns weights $\omega_a$
so that $\sum_a \omega_a g(a) = \int g$ for all $g$ of degree $< N$. Two rules on the same nodes
differ by a vector in the kernel of the truncated Vandermonde matrix; Theorem A says this kernel
is one-dimensional and equals $\mathbb{R}\cdot(1/w(a))$. Hence: an interpolatory rule on $N+1$
nodes exact to degree $N-1$ is unique up to adding a multiple of the inverse nodal weights, and
becomes unique once exactness at degree $N$ is imposed — with the failure at degree $N$ measured
by exactly the constant $c$ of Theorem B.

**Design of experiments and moment matching.** Two designs (or two quadrature-like sampling
schemes) that match $N$ moments are indistinguishable by any linear statistic of degree $< N$.
Theorem E2 sharpens this to a complete description of what *is* distinguishable: the whole
difference, against any statistic $f$ at all, is $\lambda \Delta^N f(0)$ up to sign — a single
unknown scalar times a known functional.

**Signal processing.** Theorem E4 identifies a near miss with a finite signal whose $z$-transform
is $\lambda(1-q)^N$: a pure $N$-fold zero at DC. Equivalently, the difference of the two
multiplicity sequences is annihilated by $N$ applications of the first-difference filter and by
no fewer. Near misses are therefore precisely the "$N$-th order high-pass" discrepancies.

**Number theory.** The Prouhet–Tarry–Escott problem asks for two distinct multisets of integers
with equal power sums up to a high order and as few terms as possible. Theorem B pins down the
shape of such a solution once its value set is fixed, converting the search over pairs of
multisets into a search over node sets, scored by the single functional $m(A)$ of §6.

**Coding and combinatorics.** Rigidity (Theorem C) is a uniqueness/erasure statement: knowing one
multiplicity of the difference vector determines the rest. In coding language, the inverse nodal
weight vector is the unique (up to scale) minimum-weight codeword of the dual of a truncated
generalised Reed–Solomon code, and $m(A)$ measures its weight.

---

## 9. Discussion

The single unifying idea of this work is that "agreeing on the first $N$ moments" is a linear
condition whose solution space is one-dimensional, and that the *generator* of that line is a
classical interpolation object — the vector of inverse nodal weights. Once that identification is
made, three separate strands of the theory become corollaries rather than theorems:

* the *combinatorial* strand (which multisets can be near misses, how big they must be, how many
  distinct values they need) becomes arithmetic of the vector $1/w$;
* the *analytic* strand (which functionals detect near misses) becomes the statement that the
  interpolation functional $g \mapsto \sum_a g(a)/w(a)$ is the $N$-th divided difference, which
  on equally spaced nodes is the $N$-th finite difference;
* the *algebraic* strand (factorisations of the split polynomials, generating functions) becomes
  the observation that a zero of order $N$ at $q=1$ is the generating-function avatar of the same
  line.

A pleasant surprise is that the shape of a near miss is *independent of the multisets*. One
might have expected a large moduli space of near misses on a given node set; instead there is a
single ray, and all apparent variety comes from the two trivial operations of scaling and common
padding.

The main limitation is the hypothesis $|A| = N + 1$: exactly one more node than conditions. With
$|A| = N + r$ nodes the kernel is $r$-dimensional and the shape is no longer unique; the
Prouhet–Tarry–Escott problem in its hardest form lives in that regime, and the extremal question
of §6 is our bridge to it. The counterexamples of Proposition F show that intuition calibrated on
the interval is a poor guide there: packing nodes tightly makes near misses *expensive*, not
cheap.

---

## 10. Future directions

**Extremal node sets.** Determine the minimum of $m(A) = \frac12\sum_a |v(a)|$ over node sets of
size $N+1$, and characterise the minimisers. The data for $N \le 5$ suggests symmetric sumset
node sets $\{0,1\} + B$; proving even that minimisers must be symmetric would be a first
structural result about the functional $m$.

**Support spectrum.** For which pairs $(p,q)$ with $p + q \geq N+1$, $p, q \le N+1$ and
$p, q \geq \lfloor (N+1)/2 \rfloor$ does there exist a near miss with support sizes exactly $p$
and $q$? The classification of §5 turns this into a finite construction: padding a scaled
binomial pair by a multiset $u$ raises the two support sizes by
$|\operatorname{supp} u \setminus \operatorname{supp}\mathrm{Ev}_N|$ and
$|\operatorname{supp} u \setminus \operatorname{supp}\mathrm{Od}_N|$, so the achievable pairs are
the integer points of an explicit polytope.

**Higher corank.** Develop the analogue of Theorem B for $|A| = N + r$: the kernel is spanned by
$r$ generators obtained by dividing the inverse nodal weights by $r-1$ further Lagrange factors,
and one asks which integer points of that lattice have minimal $\ell^1$ norm. This is the exact
setting of the Prouhet–Tarry–Escott problem.

**Spectral form.** Reformulate near misses as trace identities for nonnegative integer matrices:
$\operatorname{tr} M^k = \operatorname{tr} M'^k$ for $k < N$ with spectra confined to $A$. Rigidity
then becomes a statement that isospectrality below the top order forces equality of spectra —
a discrete analogue of "can one hear the shape of a drum" with a hard bound on the number of
audible frequencies.

**Fields of positive characteristic.** Theorem A holds over any field. Over $\mathbb{F}_p$ with
$p \le N$ the binomial profile degenerates, and the corresponding near misses on $\mathbb{F}_p$
nodes should exhibit Lucas-type periodicity — a concrete question with an immediately computable
answer.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Vandermonde kernel | For $N+1$ distinct nodes over a field, $\sum_i e_i v_i^k = 0$ for $k<N$ implies $e_i \prod_{j\ne i}(v_i-v_j) = \sum_i e_i v_i^N$, independent of $i$ |
| Kernel dimension | The kernel of the truncated $N\times(N+1)$ Vandermonde matrix is the line spanned by $1/w$ |
| Near misses on a node set | $(m_s(a)-m_t(a))\,w(a) = c$ for all $a \in A$, one universal $c = p_N(s)-p_N(t)$ |
| Rigidity | Equality of the two multiplicities at one node forces $s = t$ |
| Support covering | $\operatorname{supp}s \cup \operatorname{supp}t = A$, hence support sizes sum to $\ge N+1$ |
| Support bound | Larger support $\geq \lceil (N+1)/2\rceil$; attained by the binomial pair |
| Structure on the interval | Every near miss is $\lambda\cdot(\mathrm{Ev}_N,\mathrm{Od}_N)$ plus common padding, $\lambda \geq 1$ |
| Universality | $\sum_s f - \sum_t f = \lambda(-1)^N \Delta^N f(0)$ for every $f$ |
| Generating function | $\sum_s q^x - \sum_t q^x = \lambda (1-q)^N$ |
| Minimal size | Minimal cardinality on $A$ equals $\frac12\sum_a |v(a)|$; on the interval, $2^{N-1}$ |
| Interval not extremal | $m(\{0,1,3,4\}) = 3 < 4$ and $m(\{0,1,4,6,9,10\}) = 6 < 16$ |
