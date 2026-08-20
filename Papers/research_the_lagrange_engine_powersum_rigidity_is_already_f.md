# The Invisible Weight Vectors of a Truncated Power-Sum Window

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Fix integers $0 \le K \le N$ and consider weight vectors $e = (e_0, \dots, e_N)$ supported
on the nodes $\{0, 1, \dots, N\}$. The *truncated moment map* sends $e$ to the tuple of its
first $K$ moments $m_k(e) = \sum_{j=0}^{N} e_j\, j^k$, $0 \le k < K$. We call $e$ *invisible
to the window $K$* when this tuple vanishes. The classical Vandermonde rigidity principle
settles the untruncated case: the full moment map, with $K = N+1$, is injective. This paper
determines the kernel of the truncated map completely.

We prove that the invisible vectors form a free module of rank exactly $N + 1 - K$, with an
explicit basis given by the $N + 1 - K$ translates of the $K$-th forward-difference stencil,
the *shifted alternating binomial vectors* $b^{(K,i)}$ supported on $[i, i+K]$ with entries
$(-1)^{K-d}\binom{K}{d}$. Sufficiency holds over any commutative ring; necessity holds over
$\mathbb{Q}$ and — the sharp point — over $\mathbb{Z}$, with integer coefficients for
integral vectors, because the leading entry of each basis vector is $1$ and the descent
never divides. Equivalently, $e$ is invisible to the window $K$ if and only if the generating
polynomial $E(X) = \sum_j e_j X^j$ is divisible by $(X-1)^K$.

Translating positive and negative parts into multisets converts the theorem into a complete
classification of bounded *near misses* — pairs of multisets of nonnegative integers with
identical power sums throughout a window — as integer combinations of translates of one
binomial pair. We derive: the support bound $\#\operatorname{supp}(e) \ge K + 1$ with a
complete rigidity description of the extremal case as a divided difference; the $\ell^1$
lower bounds $\ell^1(e) \ge K+2$ for $K \ge 2$ and $\ell^1(e) \ge K + 3$ for odd $K \ge 3$,
together with the parity statement that $\ell^1(e)$ is always even; and a convolution
principle under which windows add while $\ell^1$ norms multiply. The convolution principle
refutes the natural conjecture $\ell^1(e) \ge 2^K$ for every $K \ge 3$, exhibiting invisible
vectors of $\ell^1$ norm at most $6^{n}$ at window $3n$, exponentially below $2^{3n}$.

**Keywords.** Truncated moment problem, forward differences, Prouhet–Tarry–Escott problem,
vanishing moments, integral lattices, divided differences, Vandermonde rigidity.

---

## 1. Introduction

### 1.1 The problem

Let $R$ be a commutative ring and let $e : \{0, 1, \dots, N\} \to R$ be a *weight vector*
on the integer nodes $0$ through $N$ (extended by $0$ outside the range when convenient).
Its $k$-th moment is
$$m_k(e) \;=\; \sum_{j=0}^{N} e_j \, j^k , \qquad k \ge 0,$$
with the convention $0^0 = 1$, so that $m_0(e) = \sum_j e_j$.

**Definition 1.1 (Invisibility).** For $K \ge 0$, the vector $e$ is *invisible to the window
$K$* if $m_k(e) = 0$ for every $k < K$.

The full moment map is injective — this is the *rigidity principle*, and it is classical:

**Proposition 1.2 (Vandermonde rigidity).** If $e : \{0,\dots,N\} \to \mathbb{Q}$ satisfies
$m_k(e) = 0$ for all $k \le N$, then $e = 0$. The same holds over $\mathbb{Z}$.

*Proof sketch.* The equations say that the vector $e$ lies in the kernel of the Vandermonde
matrix $V_{kj} = j^k$, $0 \le k, j \le N$, whose determinant is
$\prod_{0 \le a < b \le N} (b - a) \ne 0$. Equivalently, one may write the Lagrange
interpolation identity: for each node $i$, the polynomial
$L_i(x) = \prod_{j \ne i} \frac{x - j}{i - j}$ has degree $\le N$, so pairing $e$ against
$L_i$ (a linear combination of the monomials $x^k$, $k \le N$) gives
$e_i = \sum_j e_j L_i(j) = 0$. $\square$

Thus invisibility is a phenomenon of *truncation*: it can only occur when $K \le N$. The
question addressed here is the exact determination of
$$\mathcal{I}(N,K) \;=\; \{ e : \{0,\dots,N\} \to R \;:\; m_k(e) = 0 \text{ for all } k < K \}.$$

### 1.2 Why the question matters

Three independent motivations converge on $\mathcal{I}(N,K)$.

*Numerical analysis and signal processing.* A finite stencil with $K$ vanishing moments is
exactly a stencil that annihilates polynomial trends of degree $< K$: the defining
approximation-order condition for finite-difference schemes, quadrature rules, and the
vanishing-moment condition on a wavelet's high-pass filter. Classifying $\mathcal{I}(N,K)$
classifies all stencils of a given length with a given approximation order.

*Number theory.* An integral weight vector splits as a difference of two multisets, and the
invisibility equations become the statement that the two multisets have identical power sums
$p_0, \dots, p_{K-1}$. That is the *Prouhet–Tarry–Escott* (PTE) condition, studied since the
mid-nineteenth century. A classification of $\mathcal{I}(N,K)$ over $\mathbb{Z}$ is a
classification of bounded PTE solutions.

*Design and testing.* If a test procedure can only evaluate $K$ polynomial statistics of a
signed configuration, $\mathcal{I}(N,K)$ is precisely the set of configurations the test
cannot distinguish from nothing.

### 1.3 Results

Section 2 introduces the shifted binomial vectors and proves that they are invisible with a
first visible moment equal to $K!$ independent of the shift. Section 3 proves the structure
theorem over $\mathbb{Q}$ and over $\mathbb{Z}$, together with uniqueness, and Section 4
records the polynomial reformulation and the dimension count. Section 5 gives the near-miss
dictionary. Section 6 proves the support bound and its rigidity. Section 7 develops the
$\ell^1$ theory: lower bounds, parity, the convolution principle, and the refutation of the
$2^K$ conjecture. Section 8 discusses the remaining gap and states the conjecture that the
minimum is $2K$.

---

## 2. The shifted alternating binomial vectors

**Definition 2.1.** For $K, i \ge 0$, the *shifted alternating binomial vector*
$b^{(K,i)}$ is the weight vector
$$b^{(K,i)}_j \;=\;
\begin{cases}
(-1)^{K - (j-i)} \dbinom{K}{\,j - i\,}, & i \le j \le i + K, \\[4pt]
0, & \text{otherwise.}
\end{cases}$$

Its two extreme entries are $b^{(K,i)}_i = (-1)^K$ and, crucially,
$$b^{(K,i)}_{i+K} = 1 . \tag{2.1}$$
For $K = 2$ the pattern is $(1, -2, 1)$; for $K = 3$, $(-1, 3, -3, 1)$.

**Lemma 2.2 (Difference interpretation).** If $i + K \le N$ then for every $k \ge 0$,
$$m_k\big(b^{(K,i)}\big) \;=\; \sum_{d=0}^{K} (-1)^{K-d} \binom{K}{d} (i+d)^k
\;=\; \big(\Delta^K x^k\big)(i),$$
where $\Delta f(x) = f(x+1) - f(x)$ is the forward difference with unit step.

*Proof sketch.* The support of $b^{(K,i)}$ is contained in $\{i, \dots, i+K\} \subseteq
\{0,\dots,N\}$, so the sum over $\{0,\dots,N\}$ restricts to the image of
$d \mapsto i + d$, which is injective; re-indexing gives the alternating binomial sum, and
that sum is the standard expansion of the $K$-fold iterate of $\Delta$. $\square$

**Theorem 2.3 (The basis vectors are invisible).** For $i + K \le N$, the vector
$b^{(K,i)}$ is invisible to the window $K$: $m_k(b^{(K,i)}) = 0$ for all $k < K$. This holds
over any commutative ring.

*Proof sketch.* By Lemma 2.2 the $k$-th moment is $(\Delta^K x^k)(i)$. Each application of
$\Delta$ lowers the degree of a polynomial by one; applying it $K$ times to $x^k$ with
$k < K$ therefore yields the zero polynomial. $\square$

**Theorem 2.4 (Uniform first visible moment).** For $i + K \le N$,
$$m_K\big(b^{(K,i)}\big) \;=\; K! ,$$
independently of the shift $i$.

*Proof sketch.* $\Delta^K x^K$ is the constant $K!$ (the leading coefficient of $x^K$ times
$K!$); evaluate at $i$. $\square$

**Corollary 2.5.** Over a nontrivial ring, $b^{(K,i)} \ne 0$; indeed its top entry is $1$.

So each basis vector hides perfectly inside the window and re-emerges immediately after it,
with a signal strength that does not depend on where it is placed.

---

## 3. The structure theorem

Between $0$ and $N$ there are exactly $N + 1 - K$ admissible shifts $i \in \{0, \dots, N-K\}$
(with the convention that this count is $0$ when $K > N$). The main theorem says they
generate everything.

**Theorem 3.1 (Sufficiency; any commutative ring).** Let $K \le N + 1$ and let
$c : \mathbb{N} \to R$ be arbitrary. Then
$$e_j \;=\; \sum_{i=0}^{N-K} c_i \, b^{(K,i)}_j$$
defines a vector invisible to the window $K$.

*Proof sketch.* Moments are linear in the weight vector: $m_k(e + f) = m_k(e) + m_k(f)$ and
$m_k(c\,e) = c\, m_k(e)$, hence $m_k$ of a finite sum is the sum of the $m_k$'s. Apply
Theorem 2.3 termwise. $\square$

**Theorem 3.2 (Necessity, integral form).** Let $e : \{0,\dots,N\} \to \mathbb{Z}$ be
invisible to the window $K$. Then there exist **integers** $c_0, \dots, c_{N-K}$ with
$$e_j \;=\; \sum_{i=0}^{N-K} c_i \, b^{(K,i)}_j \qquad \text{for all } j \le N .$$
The same statement holds verbatim over $\mathbb{Q}$ with rational coefficients.

*Proof sketch.* Induct downward on $N$, with the window length $K$ fixed.

*Base case $N < K$.* Then the invisibility hypothesis supplies $m_k(e) = 0$ for all
$k \le N$, and Proposition 1.2 forces $e = 0$; the empty combination works, since
$N + 1 - K = 0$.

*Inductive step $N \ge K$.* Consider the last admissible shift $i = N - K$. By construction
$b^{(K,i)}_j = 0$ for $j > i + K = N$, and no other admissible shift $i' < N-K$ reaches the
node $N$, because $i' + K < N$. Hence the coefficient of $b^{(K,N-K)}$ is pinned by the top
entry, and by (2.1) that entry equals $1$. Set $c_{N-K} := e_N$ and put
$$e' \;=\; e - e_N \cdot b^{(K, N-K)} .$$
Then $e'_N = e_N - e_N \cdot 1 = 0$, so $e'$ is supported on $\{0,\dots,N-1\}$, and $e'$ is
still invisible to the window $K$ by Theorem 3.1 and linearity. The inductive hypothesis at
$N - 1$ expresses $e'$ in the shifts $i \le N - 1 - K$; adding back $e_N b^{(K,N-K)}$ gives
the claim.

The essential point is that **the recursion never divides**: the pivot entry is $1$, not
$\pm K!$ and not a binomial coefficient, so the coefficients extracted from an integral $e$
are integers. Rationality enters only through the base case, where the Vandermonde argument
is applied to a vector of length shorter than the window. $\square$

**Theorem 3.3 (Uniqueness).** If $\sum_{i=0}^{M-1} c_i\, b^{(K,i)}_j = 0$ for all $j \le N$
and $M \le N + 1 - K$, then $c_0 = \dots = c_{M-1} = 0$. Consequently the coefficients in
Theorem 3.2 are unique, and the family $\{b^{(K,i)}\}_{i=0}^{N-K}$ is linearly independent.

*Proof sketch.* Downward induction again: evaluate at $j = M - 1 + K$, the largest node
reached by any of the listed vectors; only $b^{(K,M-1)}$ is nonzero there, with value $1$,
so $c_{M-1} = 0$; remove it and repeat. $\square$

Combining:

**Theorem 3.4 (Classification).** For $K \le N+1$ and $e : \{0,\dots,N\} \to \mathbb{Q}$,
$$e \text{ is invisible to the window } K
\iff
\exists!\, c \in \mathbb{Q}^{\,N+1-K} : \; e = \sum_{i=0}^{N-K} c_i\, b^{(K,i)} .$$
Over $\mathbb{Z}$, the invisible integral vectors form a free $\mathbb{Z}$-module of rank
$N+1-K$ with basis $\{b^{(K,i)}\}$; in particular the inclusion of the integral lattice into
the rational kernel is unimodular.

---

## 4. Polynomial reformulation and dimension

Encode a weight vector as a polynomial.

**Definition 4.1.** $E(X) = \sum_{j=0}^{N} e_j X^j$, the *generating polynomial* of $e$; it
has degree at most $N$ and its $j$-th coefficient recovers $e_j$ for $j \le N$.

**Lemma 4.2.** $\big(X^i (X-1)^K\big)$ has $j$-th coefficient exactly $b^{(K,i)}_j$; hence
for $i + K \le N$ the generating polynomial of $b^{(K,i)}$ is $X^i (X-1)^K$.

*Proof sketch.* Expand $(X-1)^K = \sum_{d} \binom{K}{d} (-1)^{K-d} X^{d}$ and shift by
$X^i$. $\square$

**Theorem 4.3 (Divisibility criterion).** Let $K \le N + 1$. Over $\mathbb{Q}$, and also
over $\mathbb{Z}$,
$$e \text{ is invisible to the window } K \iff (X-1)^K \mid E(X).$$
More precisely, over any commutative ring: if $(X-1)^K \mid E$ then $e$ is invisible, and if
$e$ is a combination of the $b^{(K,i)}$ then $(X-1)^K \mid E$.

*Proof sketch.* If $E = (X-1)^K Q$ with $\deg Q \le N - K$, write $Q = \sum_i c_i X^i$;
comparing coefficients with Lemma 4.2 exhibits $e$ as $\sum_i c_i b^{(K,i)}$, which is
invisible by Theorem 3.1. Conversely, Theorem 3.2 writes $e$ in that form, and then
$E = (X-1)^K \sum_i c_i X^i$. $\square$

This is the cleanest form of the result: *vanishing of the first $K$ moments is a $K$-fold
root at $X = 1$ of the generating polynomial*. The heuristic is Taylor's: differentiating
$E(e^{t})=\sum_j e_j e^{jt} = \sum_k m_k(e)\, t^k/k!$ shows that the moments are the Taylor
coefficients of the exponential generating transform at $t = 0$, i.e. at $X = 1$.

**Theorem 4.4 (Dimension).** Over $\mathbb{Q}$, let $\mathcal{I}(N,K)$ denote the space of
vectors supported on $\{0,\dots,N\}$ and invisible to the window $K$. Then
$$\dim_{\mathbb{Q}} \mathcal{I}(N,K) \;=\; N + 1 - K$$
(with the truncated subtraction convention, so the value is $0$ once $K > N$). In particular
$\dim \mathcal{I}(N,N+1) = 0$ — the rigidity principle — and $\dim \mathcal{I}(N,N) = 1$,
the line spanned by the single alternating binomial vector
$\big((-1)^{N-j}\binom{N}{j}\big)_{j=0}^{N}$.

*Proof sketch.* Theorems 3.1–3.3 exhibit $\{b^{(K,i)}\}_{i \le N-K}$ as a spanning,
linearly independent family. $\square$

**Proposition 4.5 (One equation per step; surjectivity of the truncated moment map).** For
$K \le N$,
$$\dim \mathcal{I}(N,K) = \dim \mathcal{I}(N,K+1) + 1 ,$$
and for every prescribed target $(\mu_0, \dots, \mu_{K-1}) \in \mathbb{Q}^{K}$ with
$K \le N+1$ there is a weight vector on $\{0,\dots,N\}$ with $m_k(e) = \mu_k$ for all
$k < K$.

*Proof sketch.* The first assertion follows from Theorem 4.4. The second says the truncated
moment map $\mathbb{Q}^{N+1} \to \mathbb{Q}^{K}$ is surjective, which follows from the
rank–nullity computation: its kernel has dimension $N+1-K$, so its image has dimension $K$.
Concretely, one can also solve directly by Lagrange interpolation on any $K$ of the nodes.
$\square$

Each additional measurement therefore removes exactly one degree of freedom, no more and no
less, until the window catches up with the ruler.

---

## 5. The near-miss dictionary

We now specialise to $R = \mathbb{Z}$ and translate into multisets. For
$e : \{0,\dots,N\} \to \mathbb{Z}$ write $e_j^{+} = \max(e_j, 0)$ and
$e_j^{-} = \max(-e_j, 0)$, and let
$$S(e) = \bigsqcup_{j \le N} \{\, \underbrace{j, \dots, j}_{e_j^{+}} \,\},
\qquad
T(e) = \bigsqcup_{j \le N} \{\, \underbrace{j, \dots, j}_{e_j^{-}} \,\}$$
be the associated multisets of nodes. Write $p_k(S) = \sum_{x \in S} x^k$.

**Definition 5.1.** A pair of multisets $(S,T)$ with all elements in $\{0,\dots,N\}$ is a
*near miss of order $K$* if $S \ne T$ and $p_k(S) = p_k(T)$ for all $k < K$.

**Lemma 5.2.** $p_k(S(e)) - p_k(T(e)) = m_k(e)$ for every $k$, and conversely, for multisets
$S,T$ bounded by $N$, the vector $e_j = \#_j(S) - \#_j(T)$ (difference of multiplicities)
has $m_k(e) = p_k(S) - p_k(T)$.

**Theorem 5.3 (Dictionary).** Let $S, T$ be multisets in $\{0,\dots,N\}$.
1. If $e$ is invisible to the window $K$ and $e \ne 0$, then $(S(e), T(e))$ is a near miss
   of order $K$.
2. If $(S,T)$ has $p_k(S) = p_k(T)$ for $k < K$, then the multiplicity difference vector is
   invisible to the window $K$.
3. Consequently (Theorem 3.2) **every** near miss of order $K$ bounded by $N$ arises as an
   integer combination $\sum_{i=0}^{N-K} c_i\, b^{(K,i)}$ of the translated binomial
   stencils, and conversely every such combination that is not identically zero is a near
   miss of order $K$.

*Proof sketch.* Parts 1 and 2 are Lemma 5.2 plus the observation that $e \ne 0$ is
equivalent to $S(e) \ne T(e)$, since the multiplicity functions of $S(e)$ and $T(e)$ have
disjoint supports. Part 3 is the structure theorem transported along the dictionary.
$\square$

**Corollary 5.4 (Explicit family).** For every $K$ and every shift $i$ with $i + K \le N$
there are multisets $S \ne T$ bounded by $N$ with
$$p_k(S) = p_k(T) \ \ (k < K), \qquad p_K(S) - p_K(T) = K! .$$
These are the positive and negative parts of $b^{(K,i)}$: $S$ collects the nodes $i+d$ with
$K - d$ even, each with multiplicity $\binom{K}{d}$, and $T$ the others. There are
$N + 1 - K$ independent such families.

**Example 5.5.** $K = 2$, $i = 1$: $b^{(2,1)} = (0, 1, -2, 1)$ on $\{0,1,2,3\}$, i.e.
$$\{1, 3\} \ \text{vs.} \ \{2,2\}: \quad 1 + 3 = 2 + 2 = 4, \quad
p_2 = 10 \ \text{vs.} \ 8, \ \text{difference } 2 = 2!$$

**Example 5.6.** $K = 3$: the vector $(-1, 2, 0, -2, 1)$ on $\{0,\dots,4\}$ is invisible to
the window $3$; as a near miss it reads
$$\{1,1,4\} \ \text{vs.} \ \{0,3,3\}: \quad 6 = 6, \quad 18 = 18, \quad
p_3 = 66 \ \text{vs.} \ 54, \ \text{difference } 12 .$$

Two structural corollaries come free from the dictionary.

**Proposition 5.7 (Equal cardinality).** If $K \ge 1$ and $p_k(S) = p_k(T)$ for all $k < K$,
then $|S| = |T|$; this is the case $k = 0$.

**Proposition 5.8 (Alternating-sum congruence).** If $S, T$ are bounded by $N$ and
$p_k(S) = p_k(T)$ for all $k < K$ with $K \le N+1$, then
$$2^K \ \Big|\ \sum_{x \in S} (-1)^x \;-\; \sum_{x \in T} (-1)^x .$$

*Proof sketch.* By Theorem 4.3 the polynomial $E(X) = \sum_j (\#_j S - \#_j T) X^j$ is
divisible by $(X-1)^K$ in $\mathbb{Z}[X]$. Evaluate at $X = -1$: the left-hand side is the
difference of alternating counts, and the right-hand side carries the factor
$(-1-1)^K = (-2)^K$. $\square$

---

## 6. Support: lower bound and rigidity

Write $\operatorname{supp}(e) = \{ j \le N : e_j \ne 0\}$.

**Theorem 6.1 (Support bound).** If $e$ is invisible to the window $K$ and $e \ne 0$, then
$$\#\operatorname{supp}(e) \;\ge\; K + 1 .$$

*Proof sketch.* Suppose $\#\operatorname{supp}(e) = s \le K$. The moment conditions
$\sum_{j \in \operatorname{supp}(e)} e_j j^k = 0$ for $k = 0, \dots, s-1$ form a square
Vandermonde system in the $s$ distinct nodes of the support, so all $e_j$ vanish there — a
contradiction. $\square$

**Theorem 6.2 (Sharpness).** The bound is attained: for $i + K \le N$,
$\#\operatorname{supp}(b^{(K,i)}) = K + 1$, since all binomial coefficients
$\binom{K}{d}$, $0 \le d \le K$, are nonzero.

The extremal case is completely rigid. Let $S$ be a finite set of nodes with $|S| = K + 1$
and suppose $\sum_{j \in S} e_j j^k = 0$ for all $k < K$.

**Theorem 6.3 (Minimal support is a divided difference).** For every $i \in S$,
$$e_i \prod_{j \in S \setminus \{i\}} (i - j) \;=\; \sum_{j \in S} e_j\, j^{K} \;=\; m_K(e).$$

*Proof sketch.* Expand the monic polynomial $P_i(x) = \prod_{j \in S \setminus\{i\}} (x - j)$
of degree $K$ as $x^K + (\text{lower order})$. Pairing $e$ against $P_i$ kills the
lower-order terms by hypothesis, leaving $\sum_j e_j P_i(j) = m_K(e)$. On the other hand
$P_i(j) = 0$ for every $j \in S$ with $j \ne i$, so the left-hand side reduces to
$e_i P_i(i) = e_i \prod_{j \ne i}(i-j)$. $\square$

**Corollary 6.4.** In the minimal-support situation:
1. *(Immediate visibility)* If some $e_i \ne 0$ with $i \in S$, then $m_K(e) \ne 0$: a
   minimal invisible vector becomes visible at the very first moment past the window.
2. *(No holes)* Conversely if $m_K(e) \ne 0$ then $e_i \ne 0$ for **every** $i \in S$.
3. *(Sign alternation)* The quantities $(-1)^{\#\{j \in S : j > i\}} e_i$ all have the same
   sign, so the weights alternate in sign as one walks along the nodes of $S$ in increasing
   order. This is because
   $(-1)^{\#\{j > i\}} \prod_{j \ne i} (i - j) > 0$ for every $i$.
4. *(Proportionality)* Any two vectors supported on the same $K+1$ nodes and invisible to
   the window $K$ are proportional:
   $e_i\, m_K(f) = f_i\, m_K(e)$ for all $i \in S$.

Thus a minimal invisible configuration is unique up to scale, has full support on its node
set, alternates in sign, and its magnitudes are the reciprocals of the products
$\prod_{j \ne i} |i - j|$. Specialising to $b^{(K,i_0)}$ recovers the binomial coefficients:
on consecutive nodes $i_0, \dots, i_0 + K$ the products $\prod_{j \ne i}(i - j)$ are
$\pm d!\,(K-d)!$, whose reciprocals scaled by $K!$ are $\binom{K}{d}$ — exactly Theorem 2.4
in disguise.

---

## 7. The cost of invisibility: $\ell^1$ theory

For an integral weight vector put $\ell^1(e) = \sum_{j=0}^{N} |e_j|$. Under the near-miss
dictionary, $\ell^1(e) = |S(e)| + |T(e)| = 2|S(e)|$: it is the total number of integers used
by the near miss.

### 7.1 Lower bounds

**Theorem 7.1 (Linear bound).** If $e$ is a nonzero integral vector invisible to the window
$K$, then $\ell^1(e) \ge K + 1$.

*Proof sketch.* Each nonzero integer entry contributes at least $1$, so
$\ell^1(e) \ge \#\operatorname{supp}(e) \ge K+1$ by Theorem 6.1. $\square$

**Theorem 7.2 (Parity).** If $K \ge 1$ and $e$ is integral and invisible to the window $K$,
then $\ell^1(e)$ is even.

*Proof sketch.* The equation $m_0(e) = \sum_j e_j = 0$ says the total positive mass equals
the total negative mass; hence $\ell^1(e) = 2\sum_j e_j^{+}$. Equivalently
$\ell^1(e) \equiv \sum_j e_j = 0 \pmod 2$. $\square$

**Corollary 7.3.** For even $K \ge 1$, a nonzero integral invisible vector has
$\ell^1(e) \ge K + 2$.

**Theorem 7.4 (Improved bounds).** Let $e \ne 0$ be integral and invisible to the window
$K$. Then
$$\ell^1(e) \ge K + 2 \quad (K \ge 2), \qquad
\ell^1(e) \ge K + 3 \quad (K \ge 3 \text{ odd}).$$
Both are sharp at the small windows: $\ell^1 = 2, 4, 6$ are attained at $K = 1, 2, 3$.

*Proof sketch.* Suppose $\ell^1(e) = K+1$ exactly. Then $e$ has exactly $K+1$ nonzero
entries, all of absolute value $1$: it is a minimal-support configuration. Theorem 6.3 then
forces, for every node $i$ of the support $S$,
$$\Big|\prod_{j \in S \setminus \{i\}} (i - j)\Big| = |m_K(e)| ,$$
i.e. *all* the products of distances from a support node to the other support nodes are
equal. For $|S| = K + 1 \ge 3$ this is impossible: among any three or more distinct integer
nodes, the extreme node has a strictly larger distance product than some interior node
(the interior node's distances are dominated termwise, with at least one strict inequality).
Hence $\ell^1(e) \ge K+2$ for $K \ge 2$. For odd $K$, the parity theorem forbids the odd
value $K + 2$, giving $\ell^1(e) \ge K + 3$. $\square$

The value $K + 3$ is attained at $K = 3$ by the configuration $(-1, 2, 0, -2, 1)$ of Example
5.6, with $\ell^1 = 6$.

### 7.2 Upper bounds: shift differences

**Definition 7.5.** For a weight vector $e$ define its *shift difference*
$(\delta e)_j = e_{j-1} - e_j$ (with $e_{-1} = 0$). If $e$ is supported in
$\{0,\dots,N\}$ then $\delta e$ is supported in $\{0,\dots,N+1\}$.

**Theorem 7.6 (Window increment).** If $e$ is supported in $\{0,\dots,N\}$ and invisible to
the window $K$, then $\delta e$ is invisible to the window $K+1$, its first visible moment
is
$$m_{K+1}(\delta e) = (K+1)\, m_K(e),$$
and $\ell^1(\delta e) \le 2\, \ell^1(e)$.

*Proof sketch.* Directly, $m_k(\delta e) = \sum_{t < k} \binom{k}{t} m_t(e)$, by expanding
$(j+1)^k$; every term with $t < k \le K$ vanishes, and for $k = K+1$ only the term
$t = K$ survives with coefficient $\binom{K+1}{K} = K+1$. The norm bound is the triangle
inequality. In generating-polynomial terms, $\delta$ multiplies $E(X)$ by $(X - 1)$, which
increases the multiplicity of the root at $1$ by one — the cleanest proof. $\square$

**Corollary 7.7.** For every $m \ge 0$ there is a nonzero integral vector invisible to the
window $3 + m$ with a nonzero moment of order $3+m$ and
$$\ell^1 \le 6 \cdot 2^{m} = \tfrac{3}{4}\, 2^{\,3+m} .$$
Apply $\delta$ repeatedly to the witness $(-1,2,0,-2,1)$.

### 7.3 The convolution principle

The doubling of Corollary 7.7 is wasteful; convolution does better.

**Definition 7.8.** For weight vectors $w$ (supported in $\{0,\dots,M\}$) and $e$ (supported
in $\{0,\dots,N\}$), the convolution is
$$(w * e)_j \;=\; \sum_{a=0}^{M} w_a\, e_{j - a},$$
supported in $\{0,\dots,N+M\}$; equivalently, its generating polynomial is $W(X)E(X)$.

**Theorem 7.9 (Moments of a convolution).** For all $k$,
$$m_k(w * e) \;=\; \sum_{t=0}^{k} \binom{k}{t}\, m_t(e)\, m_{k-t}(w) .$$

*Proof sketch.* Expand $(i + a)^k$ by the binomial theorem inside the double sum
$\sum_{a}\sum_{i} w_a e_i (i+a)^k$ and separate the two indices. This is the statement that
moments are exponential-generating-function coefficients and convolution multiplies those
generating functions. $\square$

**Theorem 7.10 (Windows add, norms multiply).** If $e$ is invisible to the window $K_e$ and
$w$ is invisible to the window $K_w$, then $w * e$ is invisible to the window $K_e + K_w$,
$$m_{K_e + K_w}(w * e) \;=\; \binom{K_e + K_w}{K_e}\, m_{K_e}(e)\, m_{K_w}(w),$$
and
$$\ell^1(w * e) \;\le\; \ell^1(w)\, \ell^1(e) .$$

*Proof sketch.* In Theorem 7.9 with $k < K_e + K_w$, every term has $t < K_e$ or
$k - t < K_w$, hence vanishes; at $k = K_e + K_w$ exactly one term survives. The norm bound
is the triangle inequality applied to the double sum (submultiplicativity of $\ell^1$ under
convolution). Equivalently: multiplying generating polynomials adds the multiplicities of
the root at $X = 1$, which is Theorem 4.3 again. $\square$

**Theorem 7.11 (Exponentially cheap invisibility).** For every $n \ge 0$ there is a weight
vector $e$, supported on a finite range, invisible to the window $3n$, with
$m_{3n}(e) \ne 0$ and
$$\ell^1(e) \;\le\; 6^{\,n} .$$

*Proof sketch.* Convolve $n$ copies of the window-$3$ witness $(-1,2,0,-2,1)$, whose norm is
$6$. Theorem 7.10 gives window $3n$ and norm at most $6^n$; the top moment is the product of
the individual top moments $12$ times a positive multinomial coefficient, hence nonzero.
$\square$

### 7.4 Refutation of the exponential conjecture

The binomial stencil itself has $\ell^1(b^{(K,i)}) = \sum_d \binom{K}{d} = 2^K$. It is
natural to conjecture that this is optimal.

**Theorem 7.12 (The bound $\ell^1 \ge 2^K$ holds only for $K \le 2$).**
1. If $1 \le K \le 2$ and $e \ne 0$ is integral and invisible to the window $K$, then
   $\ell^1(e) \ge 2^K$.
2. For every $K \ge 3$ there exists a nonzero integral vector invisible to the window $K$
   with $\ell^1(e) < 2^K$. Hence the statement "$\ell^1(e) \ge 2^K$ for all invisible
   nonzero integral $e$" is **false**.
3. The failure is exponential: with $K = 3n$, Theorem 7.11 gives invisible vectors with
   $$\frac{\ell^1(e)}{2^{K}} \;\le\; \left(\frac{6}{8}\right)^{n} = \left(\frac{3}{4}\right)^{n}
   \longrightarrow 0 .$$
   Equivalently, $4^n \ell^1(e) \le 3^n\, 2^{3n}$.

*Proof sketch.* (1) For $K = 1$, $2^K = 2 = K+1$ rounded up by parity; for $K = 2$,
$2^K = 4 = K + 2$, which is Theorem 7.4. (2) Corollary 7.7 supplies norm
$6 \cdot 2^{K-3} = \tfrac34 2^K < 2^K$. (3) Theorem 7.11. $\square$

The exponential base implicit in Theorem 7.11 is $6^{1/3} \approx 1.817 < 2$. So the true
growth rate of the minimal $\ell^1$, if it is exponential at all, has base at most $1.817$;
and the linear lower bounds leave open the possibility that it is not exponential at all.

---

## 8. Discussion and open problems

### 8.1 Summary of the picture

For every window $K \le N$:

* The invisible vectors form a free module of rank exactly $N + 1 - K$, over any base, with
  the $N+1-K$ translates of the $K$-th difference stencil as an explicit basis; the integral
  lattice sits unimodularly inside the rational space.
* Invisibility is equivalent to a $K$-fold root at $X = 1$ of the generating polynomial.
* Every bounded near miss of order $K$ is an integer combination of translates of one
  binomial pair; the alternating counts of the two multisets agree modulo $2^K$.
* Minimal-support invisible vectors ($K+1$ nodes) are divided differences: unique up to
  scale, with alternating signs and no zero entries, and immediately visible at moment $K$.
* The cost obeys $K + 2 \le \ell^1 \le \tfrac34 \cdot 2^{K}$ (with $K+3$ for odd $K \ge 3$
  and $\ell^1$ always even), and the upper bound improves to $\approx 1.817^{K}$ along the
  windows $K = 3n$.

### 8.2 The central gap

The distance between the linear lower bound and the exponential upper bound is the main
remaining question. The evidence assembled here points to a clean answer.

**Conjecture 8.1 (Minimal cost is $2K$).** For every $K \ge 1$, every nonzero integral
vector invisible to the window $K$ satisfies $\ell^1(e) \ge 2K$; and for infinitely many $K$
the value $2K$ is attained.

The lower half strengthens the proved $K+2$ / $K+3$ bounds by roughly a factor of two. The
attainment half is equivalent to the existence of *ideal* Prouhet–Tarry–Escott solutions of
arbitrary degree — a solution using exactly $K$ integers on each side — which has been sought
since 1851 and is known only in low degrees. The proved bounds already coincide with $2K$ at
$K = 1, 2, 3$, so the first genuine test is $K = 4$, where the expected truth is $8$ against
a proved floor of $6$.

The mechanism suggested by Section 6 is a *support-versus-spread trade-off*: the support
bound counts nodes, while $\ell^1$ counts nodes with multiplicity and sign. A vector that
achieves the support bound is a divided difference, and its entries
$m_K(e) / \prod_{j \ne i}(i - j)$ are large unless the nodes are extremely tightly packed —
but tightly packed consecutive nodes force the binomial pattern with its $2^K$ cost. A
genuinely economical vector must therefore spread over strictly more than $K + 1$ nodes and
pay for the spread. Quantifying that trade-off is a finite-dimensional optimisation over
node configurations, not a new theory, which is why the conjecture looks attackable.

### 8.3 Further directions

* **Exact exponential rate.** Define $\lambda = \lim_K (\min \ell^1)^{1/K}$ if it exists. The
  convolution principle shows $\lambda \le 6^{1/3} \approx 1.817$, and any cheap witness at a
  single window $K_0$ improves this to $(\min \ell^1 \text{ at } K_0)^{1/K_0}$. If Conjecture
  8.1 holds, $\lambda = 1$. Systematically searching small windows for cheap witnesses
  therefore directly bounds a global constant.
* **Weighted and continuous nodes.** The structure theorem uses only that the nodes are
  $0, 1, \dots, N$ and equally spaced. For arbitrary distinct real nodes the analogue of the
  basis is the family of divided-difference functionals of order $K$ on $K+1$ consecutive
  nodes; Section 6 already proves the rigidity half in that generality. The integrality
  statement, however, is special to the equally-spaced lattice.
* **Higher dimensions.** For nodes in $\mathbb{Z}^d$ and moments indexed by monomials of
  total degree $< K$, the kernel is again a lattice, but the analogue of the translated
  stencil basis is no longer obvious: mixed differences of total order $K$ span the kernel
  but are not independent. Determining a canonical basis is open.
* **Algorithmic decomposition.** The proof of Theorem 3.2 is an algorithm: read off $c_{N-K}$
  from the top entry, subtract, recurse. It runs in $O((N+1-K)\,K)$ integer operations and
  performs no divisions, so it is a practical exact decomposition procedure for near misses.

---

## Appendix A. Worked numerical data

$K = 2$, $N = 3$. Basis: $b^{(2,0)} = (1,-2,1,0)$ and $b^{(2,1)} = (0,1,-2,1)$; the invisible
space has dimension $4 - 2 = 2$. Moments of $b^{(2,1)}$: $m_0 = 1 - 2 + 1 = 0$,
$m_1 = 1\cdot 1 - 2 \cdot 2 + 1 \cdot 3 = 0$, and
$m_2 = 1 \cdot 1 - 2 \cdot 4 + 1 \cdot 9 = 2 = 2!$.

$K = 3$, $N = 3$. Basis: $b^{(3,0)} = (-1, 3, -3, 1)$ only; dimension $1$; $m_3 = 6 = 3!$;
$\ell^1 = 8 = 2^3$. The cheaper witness $(-1,2,0,-2,1)$ needs one more node ($N = 4$) and
achieves $\ell^1 = 6$: on $\{0,\dots,4\}$ its decomposition in the basis
$b^{(3,0)}, b^{(3,1)}$ is $(1, 1)$, i.e.
$$(-1,2,0,-2,1) = 1 \cdot (-1,3,-3,1,0) + 1 \cdot (0,-1,3,-3,1),$$
with integer coefficients, as Theorem 3.2 predicts.

$K = 2$, $N = 2$. Dimension $1$, basis $(1,-2,1)$, $\ell^1 = 4 = 2^2 = K+2$: sharp for both
the exponential bound at $K = 2$ and the linear bound.
