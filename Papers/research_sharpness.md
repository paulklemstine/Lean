# Power-Sum Rigidity for Bounded Multisets and the Exact Sharpness of the Window $0 \le k \le N$

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

For a finite multiset $s$ of natural numbers write $p_k(s) = \sum_{x \in s} x^k$ for its $k$-th
power sum. We prove that if all elements of $s$ and $t$ are bounded by $N$ and
$p_k(s) = p_k(t)$ for every $k \in \{0, 1, \dots, N\}$, then $s = t$; and that this window of
$N + 1$ indices is optimal at every level $N$, witnessed by the *binomial parity pair* $E_N$,
$O_N$ carrying multiplicity $\binom{N}{j}$ at even, respectively odd, $j \le N$. We then prove
that the failure is exactly quantified. The multiplicity difference of *any* pair of bounded
multisets agreeing on all power sums below the top index is an integer multiple of the single
alternating binomial vector $j \mapsto (-1)^j \binom{N}{j}$; consequently the separation at the
top index is divisible by $N!$, is at least $N!$ in absolute value for distinct multisets, and
equals $(-1)^N N!$ for the binomial pair. The same classification yields a size floor: a near
miss at level $N \ge 1$ has at least $2^{N-1}$ elements, attained by the binomial pair. We
isolate the role of the counting index $k = 0$: it is needed *only* because the value $0$ is
invisible to positive power sums, and on positive support the punctured window
$1 \le k \le N$ is again rigid and again sharp. Finally we give the spectral reading: for monic
integer polynomials split with roots in $\{0, \dots, N\}$ — equivalently, spectra of
diagonalisable matrices with eigenvalues in that range — the traces
$\operatorname{tr}(A^0), \dots, \operatorname{tr}(A^N)$ determine the characteristic polynomial,
and $N$ traces do not. The unifying mechanism is a single linear-algebra fact: the Vandermonde
matrix on the nodes $0, \dots, N$ is invertible, and the kernel of its top-row truncation is the
line spanned by the alternating binomial vector.

**Keywords:** power sums, moment problem, multiset reconstruction, Vandermonde matrix, Lagrange
interpolation, finite differences, alternating binomial sums, Newton's identities, spectral
rigidity.

---

## 1. Introduction

### 1.1 The problem

Let $s$ be a finite multiset of natural numbers. Its power sums are
$$p_k(s) = \sum_{x \in s} x^k \in \mathbb{Z}, \qquad k = 0, 1, 2, \dots,$$
with the convention $0^0 = 1$, so that $p_0(s) = |s|$ is the cardinality. Power sums are the
most natural "measurements" one can perform on a multiset: they are symmetric, additive over
disjoint union, and computable from any presentation of the data.

The reconstruction question is: *how many power sums determine $s$?* Without a bound on the
elements the answer is "no finite number", since one may always place a difference at a very
high value. But if all elements lie in $\{0, 1, \dots, N\}$, the multiset is described by
$N + 1$ multiplicities, and one expects $N + 1$ measurements to suffice. That expectation is
correct, and the purpose of this paper is to prove it and then to determine precisely how it
fails when one measurement is removed.

### 1.2 The motivating example

The smallest interesting instance is
$$s = \{0, 2\}, \qquad t = \{1, 1\},$$
both bounded by $N = 2$. One computes
$$p_0(s) = p_0(t) = 2, \qquad p_1(s) = p_1(t) = 2, \qquad p_2(s) = 4 \ne 2 = p_2(t).$$
The two multisets are indistinguishable by the first two power sums and separate exactly at
$k = N = 2$. We will see that this is not an isolated coincidence but the level-$2$ instance of
a construction that exists at every $N$, and that it is *extremal* in two independent senses.

### 1.3 Results

Throughout, "bounded by $N$" means every element is $\le N$; multiplicities are unrestricted.

* **Theorem A (Rigidity).** If $s, t$ are bounded by $N$ and $p_k(s) = p_k(t)$ for all
  $k \le N$, then $s = t$.
* **Theorem B (Sharpness).** For every $N$ there exist distinct multisets bounded by $N$ whose
  power sums agree for all $k < N$; explicitly, the binomial parity pair $E_N$, $O_N$.
* **Theorem C (Exact top-index gap).** $p_N(E_N) - p_N(O_N) = (-1)^N N!$.
* **Theorem D (Classification of near misses).** If $s, t$ are bounded by $N$ and agree on all
  $p_k$ with $k < N$, then there is an integer $\lambda$ with
  $c_j(s) - c_j(t) = \lambda \, (-1)^j \binom{N}{j}$ for all $j \le N$, where $c_j$ denotes
  multiplicity; in fact $\lambda = c_0(s) - c_0(t)$.
* **Theorem E (Quantisation and extremality).** Under the hypotheses of Theorem D,
  $N! \mid p_N(s) - p_N(t)$; if moreover $s \ne t$ then $|p_N(s) - p_N(t)| \ge N!$, and the
  binomial pair attains the bound.
* **Theorem F (Size floor).** Under the hypotheses of Theorem D with $s \ne t$ and $N \ge 1$,
  $2^N \le 2|s|$, i.e. $|s| \ge 2^{N-1}$; and $|E_N| = 2^{N-1}$ exactly.
* **Theorem G (The role of $k = 0$).** The window $1 \le k \le N$ fails in general ($\{0\}$
  versus $\emptyset$), but on positive support — all elements in $\{1, \dots, N\}$ — the
  punctured window $1 \le k \le N$ is rigid, and it too is sharp.
* **Theorem H (Spectral form).** For $s, t$ bounded by $N$, the monic split polynomials
  $\chi_s = \prod_{x \in s} (X - x)$ and $\chi_t$ are equal if and only if $p_k(s) = p_k(t)$
  for all $k \le N$; and there exist $s, t$ with $\chi_s \ne \chi_t$ agreeing for all $k < N$.
* **Proposition I (Abundance).** For each $N$ the set of pairs of distinct multisets bounded by
  $N$ agreeing on all $p_k$ with $k < N$ is infinite.

### 1.4 Context

Two classical circles of ideas meet here. The first is the theory of symmetric functions:
Newton's identities convert the first $n$ power sums of $n$ quantities into their elementary
symmetric functions, hence into the coefficients of the polynomial they are roots of. That
gives a reconstruction theorem in which the number of required power sums is governed by the
*cardinality* of the multiset. The present statement is governed instead by the *range* of the
values, and does not degrade as the multiplicities grow: a multiset of a billion elements
bounded by $5$ still needs only six power sums. The second circle is the truncated moment
problem, where one asks which finite sequences $(m_0, \dots, m_K)$ arise as moments of a
measure and when the measure is determined. Restricting to atoms in $\{0, \dots, N\}$ makes
that problem finite-dimensional and linear, and the answer is entirely governed by the
Vandermonde matrix on those nodes.

The novelty here is not that the Vandermonde matrix is invertible but that the *failure mode*
one index short is completely described: a single kernel line, an integrality constraint from
its normalisation at $j = 0$, and hence an exact factorial quantisation of the smallest
possible discrepancy.

---

## 2. Setup and notation

$\mathbb{N} = \{0, 1, 2, \dots\}$. Multisets of naturals are written $s, t$; $c_j(s)$ denotes
the multiplicity of $j$ in $s$; $|s| = \sum_j c_j(s)$ is the cardinality; $\emptyset$ is the
empty multiset. Power sums $p_k(s) = \sum_{x \in s} x^k$ are computed in $\mathbb{Z}$ (so
subtraction is available), with $0^0 = 1$.

Two immediate properties, used constantly:

* **Additivity.** $p_k(s \uplus t) = p_k(s) + p_k(t)$, where $\uplus$ is multiset union with
  multiplicities added.
* **Replication.** $p_k(n \cdot \{j\}) = n\,j^k$ for the multiset consisting of $n$ copies of
  $j$.

**Definition 2.1 (Multiplicity presentation).** For $N \in \mathbb{N}$ and
$c : \{0, \dots, N\} \to \mathbb{N}$ let
$$\mathrm{Ms}_N(c) \;=\; \biguplus_{j=0}^{N} \, c(j)\cdot\{j\}$$
be the multiset with multiplicity $c(j)$ at $j$. Every multiset bounded by $N$ is of this form,
namely $s = \mathrm{Ms}_N(j \mapsto c_j(s))$, and conversely every $\mathrm{Ms}_N(c)$ is bounded
by $N$.

**Lemma 2.2 (Linear form of the power sums).** If $s$ is bounded by $N$ then for every $k$,
$$p_k(s) \;=\; \sum_{j=0}^{N} c_j(s)\, j^k .$$

*Proof.* Write $s$ in the form of Definition 2.1 and apply additivity and replication. $\square$

Lemma 2.2 is the whole translation: the map
$$s \longmapsto \bigl(p_0(s), \dots, p_K(s)\bigr)$$
is the restriction to nonnegative integer vectors of the linear map with matrix
$V^{(K)}_{k,j} = j^k$, $0 \le k \le K$, $0 \le j \le N$. For $K = N$ this is the square
Vandermonde matrix on the nodes $0, 1, \dots, N$ (transposed); for $K = N-1$ it is that matrix
with its last row deleted.

---

## 3. Rigidity

The key linear statement is the injectivity of the transposed Vandermonde map, phrased so that
it applies directly to the *difference* of two multiplicity vectors (which may be negative, and
is naturally considered over $\mathbb{Q}$).

**Lemma 3.1 (Dual Vandermonde injectivity).** Let $e_0, \dots, e_N \in \mathbb{Q}$ satisfy
$$\sum_{j=0}^{N} e_j\, j^k = 0 \qquad \text{for every } k \le N .$$
Then $e_m = 0$ for all $m \le N$.

*Proof.* Consider the linear functional $\Lambda(f) = \sum_{j=0}^{N} e_j f(j)$ on the space
$\mathbb{Q}[x]_{\le N}$ of polynomials of degree at most $N$. The hypothesis says $\Lambda$
annihilates every monomial $x^k$ with $k \le N$; by linearity $\Lambda$ annihilates all of
$\mathbb{Q}[x]_{\le N}$. Fix $m \le N$ and let $L_m \in \mathbb{Q}[x]_{\le N}$ be the Lagrange
basis polynomial for the nodes $0, 1, \dots, N$:
$$L_m(x) \;=\; \prod_{\substack{j = 0 \\ j \ne m}}^{N} \frac{x - j}{m - j},
\qquad L_m(m) = 1, \quad L_m(j) = 0 \ (j \ne m).$$
Its degree is $N < N + 1$, so expanding $L_m$ in the monomial basis and applying $\Lambda$
term by term gives $\Lambda(L_m) = 0$. On the other hand, evaluating the defining sum,
$\Lambda(L_m) = \sum_j e_j L_m(j) = e_m$. Hence $e_m = 0$. $\square$

The proof deserves a remark. It uses only that the nodes $0, \dots, N$ are pairwise distinct
(so that the Lagrange basis exists) and that there are exactly as many of them as the dimension
of the polynomial space being tested. No determinant is computed: the argument is the statement
that point evaluations at $N+1$ distinct nodes form a basis of the dual of
$\mathbb{Q}[x]_{\le N}$, and the Lagrange polynomials are the dual basis of the monomials'
image. This is the "algebra $\leftrightarrow$ combinatorics" bridge on which everything below
rests.

**Theorem A (Rigidity).** Let $s, t$ be finite multisets of naturals bounded by $N$ with
$$p_k(s) = p_k(t) \qquad \text{for all } k \le N .$$
Then $s = t$.

*Proof.* Set $e_j = c_j(s) - c_j(t) \in \mathbb{Q}$ for $j \le N$. By Lemma 2.2 and the
hypothesis, for every $k \le N$,
$$\sum_{j=0}^{N} e_j\, j^k = p_k(s) - p_k(t) = 0 .$$
Lemma 3.1 gives $e_m = 0$, i.e. $c_m(s) = c_m(t)$, for all $m \le N$. For $m > N$ both
multiplicities vanish because both multisets are bounded by $N$. Multisets with identical
multiplicity functions are equal. $\square$

Two comments. First, the bound on the elements is essential — the theorem is not about the
number of measurements versus the number of elements but versus the number of *available
values*. Second, the hypothesis is used only for $k \le N$, and the conclusion is exact
equality of multisets, not merely of some coarser invariant.

---

## 4. Alternating binomial sums and finite differences

We now build the object that will realise sharpness. Let $\Delta$ denote the forward difference
operator with unit step, $(\Delta f)(x) = f(x+1) - f(x)$.

**Lemma 4.1 (Difference expansion).** For all $N, k \in \mathbb{N}$,
$$(\Delta^N f)(0) \;=\; (-1)^N \sum_{j=0}^{N} (-1)^j \binom{N}{j} f(j) .$$

*Proof.* Induction on $N$, or the operator identity $\Delta = S - I$ with $S$ the unit shift:
expanding $(S - I)^N$ by the binomial theorem gives
$\Delta^N = \sum_{i} \binom{N}{i} (-1)^{N-i} S^{i}$, and evaluating at $0$ gives
$\sum_i (-1)^{N-i}\binom{N}{i} f(i)$, which is the stated expression after replacing
$(-1)^{N-i}$ by $(-1)^N(-1)^i$. $\square$

**Lemma 4.2 (Vanishing below the top degree).** If $k < N$ then
$$A(N,k) \;:=\; \sum_{j=0}^{N} (-1)^j \binom{N}{j} j^k \;=\; 0 .$$

*Proof.* By Lemma 4.1, $A(N,k) = (-1)^N (\Delta^N f)(0)$ with $f(x) = x^k$. The difference
operator lowers the degree of a polynomial by exactly one; applying it $N > k$ times to a
polynomial of degree $k$ yields the zero function. $\square$

**Lemma 4.3 (Value at the top degree).**
$$A(N,N) \;=\; \sum_{j=0}^{N} (-1)^j \binom{N}{j} j^N \;=\; (-1)^N \, N! \, .$$

*Proof.* Again by Lemma 4.1 with $f(x) = x^N$: each application of $\Delta$ to a monic
polynomial of degree $d$ yields a polynomial of degree $d-1$ with leading coefficient $d$, so
$\Delta^N x^N$ is the constant $N!$. Multiplying by $(-1)^N$ and using
$(-1)^N(-1)^N = 1$ gives the claim. $\square$

Together, Lemmas 4.2 and 4.3 say that the *alternating table*
$A(N,k)$, $0 \le k \le N$, is strictly lower triangular with diagonal $(-1)^N N!$. Its diagonal
entries are
$$1, \; -1, \; 2, \; -6, \; 24, \; -120, \; 720, \; -5040, \; 40320, \dots$$
the factorials with alternating signs.

**Definition 4.4 (Binomial parity pair).** For $N \in \mathbb{N}$ set
$$E_N \;=\; \mathrm{Ms}_N\bigl(j \mapsto [\,j \text{ even}\,]\tbinom{N}{j}\bigr), \qquad
O_N \;=\; \mathrm{Ms}_N\bigl(j \mapsto [\,j \text{ odd}\,]\tbinom{N}{j}\bigr),$$
where $[\,\cdot\,]$ is the indicator. Thus $E_N$ contains $\binom{N}{j}$ copies of each even
$j \le N$, and $O_N$ contains $\binom{N}{j}$ copies of each odd $j \le N$. Both are bounded by
$N$.

**Lemma 4.5.** For every $k$, $\;p_k(E_N) - p_k(O_N) = A(N, k)$.

*Proof.* By Lemma 2.2 the difference is $\sum_{j \le N} \bigl(c_j(E_N) - c_j(O_N)\bigr) j^k$,
and by construction $c_j(E_N) - c_j(O_N) = (-1)^j \binom{N}{j}$: at even $j$ the difference is
$+\binom{N}{j}$ and at odd $j$ it is $-\binom{N}{j}$. $\square$

**Theorem C (Exact top-index gap).** For every $N$,
$$p_k(E_N) = p_k(O_N) \quad \text{for all } k < N, \qquad
p_N(E_N) - p_N(O_N) = (-1)^N\, N! \, .$$

*Proof.* Combine Lemma 4.5 with Lemmas 4.2 and 4.3. $\square$

**Corollary 4.6.** $E_N \ne O_N$, since $(-1)^N N! \ne 0$.

**Theorem B (Sharpness).** For every $N$ there exist multisets $s \ne t$ bounded by $N$ with
$p_k(s) = p_k(t)$ for all $k < N$. Consequently the window $0 \le k \le N$ of Theorem A cannot
be shortened at any level.

*Proof.* Take $s = E_N$, $t = O_N$ and apply Theorem C and Corollary 4.6. $\square$

**Optimality, packaged.** For every $N$, the implication
"$p_k(s) = p_k(t)$ for all $k \le N$ $\Rightarrow$ $s = t$" holds for all multisets bounded by
$N$, while the implication with $k \le N$ replaced by $k < N$ fails. This is precisely the
statement that the threshold $K = N$ is optimal.

**Low levels.** At $N = 2$: $\binom{2}{0} = \binom{2}{2} = 1$ and $\binom{2}{1} = 2$, so
$E_2 = \{0, 2\}$ and $O_2 = \{1, 1\}$, with gap $4 - 2 = 2 = 2!$. At $N = 3$:
$E_3 = \{0, 2, 2, 2\}$ and $O_3 = \{1, 1, 1, 3\}$, agreeing at $k = 0$ ($4 = 4$), $k = 1$
($6 = 6$) and $k = 2$ ($12 = 12$), separating at $k = 3$: $24 - 30 = -6 = -3!$. The motivating
example of §1.2 is thus the level-$2$ instance of Definition 4.4, derived rather than found.

---

## 5. Classification of near misses and quantisation of the gap

Call a pair $(s,t)$ of multisets bounded by $N$ a **near miss at level $N$** if
$p_k(s) = p_k(t)$ for all $k < N$. Theorem B produces near misses; the results of this section
show that there are essentially no others, and that they carry an exact numerical cost.

**Theorem D (Classification).** Let $(s,t)$ be a near miss at level $N$. Then, with
$\lambda = c_0(s) - c_0(t) \in \mathbb{Z}$,
$$c_j(s) - c_j(t) \;=\; \lambda \,(-1)^j \binom{N}{j} \qquad \text{for all } j \le N .$$

*Proof sketch.* Let $e_j = c_j(s) - c_j(t)$ and $v_j = (-1)^j \binom{N}{j}$, and consider the
corrected vector $w_j = e_j - \lambda v_j$. Two facts are combined.

1. For every $k < N$, $\sum_{j \le N} w_j j^k = \bigl(p_k(s) - p_k(t)\bigr) - \lambda A(N,k) = 0$,
   using the near-miss hypothesis and Lemma 4.2.
2. $w_0 = e_0 - \lambda v_0 = e_0 - \lambda = 0$, because $v_0 = (-1)^0\binom{N}{0} = 1$.

So $w$ is supported on $\{1, \dots, N\}$ — that is $N$ nodes — and annihilates the $N$ monomials
$x^k$, $k < N$. Repeating the Lagrange argument of Lemma 3.1 on the punctured node set
$\{1, \dots, N\}$ (which again has as many nodes as the dimension of the polynomial space being
tested) forces $w_j = 0$ for all $j \le N$. Hence $e = \lambda v$. $\square$

The mechanism is worth stating plainly. The kernel of the truncated matrix
$V^{(N-1)} = (j^k)_{k<N,\; j \le N}$, of size $N \times (N+1)$, is at least one-dimensional by
dimension count and at most one-dimensional because deleting any single column leaves an
invertible $N \times N$ Vandermonde matrix. Lemma 4.2 exhibits $v$ in that kernel, so the
kernel is exactly $\mathbb{Q}v$. Theorem D adds the arithmetic refinement: because $v_0 = 1$,
the coefficient $\lambda$ of an *integer* kernel vector is itself an integer, namely the
$0$-coordinate. The normalisation $v_0 = 1$ — a triviality about Pascal's triangle — is what
turns a statement about a line into a statement about a lattice.

**Theorem E (Quantisation and extremality).** Let $(s,t)$ be a near miss at level $N$. Then
$$N! \; \big| \; p_N(s) - p_N(t).$$
If moreover $s \ne t$, then $|p_N(s) - p_N(t)| \ge N!$. The bound is attained: for
$s = E_N$, $t = O_N$ one has $|p_N(s) - p_N(t)| = N!$.

*Proof.* By Lemma 2.2 and Theorem D,
$$p_N(s) - p_N(t) = \sum_{j \le N} \bigl(c_j(s) - c_j(t)\bigr) j^N
= \lambda \sum_{j \le N} (-1)^j \binom{N}{j} j^N = \lambda \, (-1)^N N! ,$$
using Lemma 4.3. Divisibility by $N!$ is immediate. If $s \ne t$ then some multiplicity differs;
by Theorem D that forces $\lambda \ne 0$ (if $\lambda = 0$ then $e_j = 0$ for all $j \le N$, and
multiplicities above $N$ vanish by boundedness, so $s = t$). Hence $|\lambda| \ge 1$ and
$|p_N(s) - p_N(t)| = |\lambda| \, N! \ge N!$. Attainment is Theorem C, where $\lambda = 1$.
$\square$

Theorem E converts the qualitative sharpness of Theorem B into an extremal statement: not only
does the shortened window fail, but every failure is expensive. The cheapest one costs exactly
$N!$, and the binomial pair realises that minimum. There is no near miss with a small
discrepancy at the top index; the discrepancy is quantised in units of $N!$.

**Theorem F (Size floor).** Let $(s,t)$ be a near miss at level $N \ge 1$ with $s \ne t$. Then
$$2^N \le 2\,|s| , \qquad \text{i.e.} \qquad |s| \ge 2^{N-1}.$$
Moreover $2\,|E_N| = 2^N$, so the binomial pair attains the floor.

*Proof sketch.* By Theorem D with $|\lambda| \ge 1$, the multiplicity difference dominates the
alternating binomial vector coordinatewise in absolute value:
$|c_j(s) - c_j(t)| \ge \binom{N}{j}$ for every $j \le N$. Summing over $j$ and using
$\sum_j \binom{N}{j} = 2^N$ gives
$$2^N \le \sum_{j \le N} \bigl(c_j(s) + c_j(t)\bigr) = |s| + |t| ,$$
since $|a - b| \le a + b$ for nonnegative integers. But $|s| = p_0(s) = p_0(t) = |t|$ when
$N \ge 1$, because the near-miss hypothesis includes the index $k = 0$. Hence $2^N \le 2|s|$.
For the attainment, $|E_N| = \sum_{j \text{ even}} \binom{N}{j} = 2^{N-1}$, the standard parity
identity, which follows from evaluating $(1+1)^N$ and $(1-1)^N$ and averaging. $\square$

Theorem F is a second extremality statement, independent of Theorem E: the binomial pair is not
just the cheapest near miss in top-index separation, it is also the smallest one in cardinality.
Both minima are consequences of the same fact — that the kernel is a line whose primitive
integer generator is $v$.

**Proposition I (Abundance).** For each $N$, the set of near misses at level $N$ consisting of
distinct multisets is infinite.

*Proof.* For each $m \in \mathbb{N}$ let $s_m = E_N \uplus (m \cdot \{0\})$ and
$t_m = O_N \uplus (m \cdot \{0\})$. Adding copies of $0$ changes $p_k$ only for $k = 0$, and
changes it equally on both sides, so each pair is again a near miss; $s_m \ne t_m$ because
$E_N \ne O_N$ and padding is cancellative; and the pairs are pairwise distinct since their
cardinalities differ. $\square$

Note the consistency with Theorem D: padding by $m$ zeros leaves $\lambda = 1$, so all these
pairs sit at the minimum of Theorem E. Increasing $|\lambda|$ instead — for example taking
multiplicity $2\binom{N}{j}$ — multiplies both the top-index gap and the size floor by
$|\lambda|$.

---

## 6. The role of the index $k = 0$

The window $0 \le k \le N$ contains one index of a different flavour: $p_0$ measures
cardinality, not any arithmetic of the elements. It is natural to ask whether it can be dropped
in favour of a purely "positive-degree" window.

**Observation 6.1 (The counting index cannot be dropped).** For every $N$ the multisets
$s = \{0\}$ and $t = \emptyset$ are bounded by $N$, are distinct, and satisfy $p_k(s) = p_k(t)$
for all $k$ with $1 \le k \le N$ — indeed for all $k \ge 1$, since $0^k = 0$.

So the naive punctured statement is false, and it fails for a single, completely identifiable
reason: the value $0$ contributes nothing to any positive power sum. Removing that value from
consideration removes the obstruction entirely.

**Theorem G (Positive support).** Let $s, t$ be multisets with all elements in
$\{1, 2, \dots, N\}$.

1. *(Rigidity)* If $p_k(s) = p_k(t)$ for all $k$ with $1 \le k \le N$, then $s = t$.
2. *(Sharpness)* For $N \ge 1$ there exist distinct such $s, t$ with $p_k(s) = p_k(t)$ for all
   $k$ with $1 \le k < N$.

*Proof sketch.* (1) Let $e_j = c_j(s) - c_j(t)$; then $e_0 = 0$ because neither multiset
contains $0$, and $\sum_{j \le N} e_j j^k = 0$ for $1 \le k \le N$. The functional
$\Lambda(f) = \sum_{j=1}^{N} e_j f(j)$ therefore annihilates $x, x^2, \dots, x^N$, hence every
polynomial of degree $\le N$ with zero constant term. For $m \in \{1, \dots, N\}$, the Lagrange
basis polynomial $L_m$ for the nodes $\{1,\dots,N\}$ has degree $N - 1$; multiplying it by
$x/m$ produces a polynomial of degree $\le N$ with zero constant term taking value $1$ at $m$
and $0$ at the other positive nodes. Applying $\Lambda$ to it yields $e_m = 0$. Multiplicities
outside $\{1, \dots, N\}$ vanish by hypothesis, so $s = t$.

(2) Take $E_N^{+}$, the binomial even part with the value $0$ deleted, and $O_N$. Deleting
zeros changes no power sum with $k \ge 1$, so by Theorem C the two agree for $1 \le k < N$; and
they are distinct because their power sums at $k = N$ differ by $(-1)^N N!$, again unaffected
by the deletion. $\square$

Both windows in Theorem G have length $N$: the general statement needs $N + 1$ indices only
because it must also detect a value that positive power sums cannot see. The picture is
therefore complete and symmetric — one index per available value, no more and no less.

---

## 7. Spectral form: traces of powers determine the spectrum

Multisets of naturals are root multisets. For a multiset $s$ define the monic integer
polynomial
$$\chi_s(X) \;=\; \prod_{x \in s} \, (X - x) \;\in\; \mathbb{Z}[X].$$
Its degree is $|s|$, it splits over $\mathbb{Z}$, and its root multiset (with multiplicity) is
exactly $s$; in particular $s \mapsto \chi_s$ is injective. If $A$ is a diagonalisable matrix
whose eigenvalues, with multiplicity, are the elements of $s$, then $\chi_s$ is the
characteristic polynomial of $A$ and
$$p_k(s) \;=\; \operatorname{tr}(A^k).$$

**Theorem H (Spectral rigidity and its sharpness).** Let $s, t$ be multisets bounded by $N$.
Then
$$\chi_s = \chi_t \iff p_k(s) = p_k(t) \ \text{ for all } k \le N .$$
Moreover there exist $s, t$ bounded by $N$ with $\chi_s \ne \chi_t$ and $p_k(s) = p_k(t)$ for
all $k < N$.

*Proof.* ($\Rightarrow$) Equal polynomials have equal root multisets, hence equal power sums at
every index. ($\Leftarrow$) By Theorem A, the hypothesis forces $s = t$, hence
$\chi_s = \chi_t$. For the second statement take $s = E_N$, $t = O_N$: they agree below the top
index by Theorem C, and $\chi_{E_N} \ne \chi_{O_N}$ because $E_N \ne O_N$ and $s \mapsto \chi_s$
is injective. $\square$

In matrix terms: for diagonalisable matrices with integer eigenvalues in $\{0, \dots, N\}$, the
$N + 1$ traces $\operatorname{tr}(A^0), \dots, \operatorname{tr}(A^N)$ determine the
characteristic polynomial — regardless of the size of the matrix — and $N$ traces do not.
Theorem E quantifies the failure: two such matrices agreeing on the first $N$ traces but with
different spectra must differ in $\operatorname{tr}(A^N)$ by at least $N!$, and must have size
at least $2^{N-1}$.

The comparison with Newton's identities is instructive. Newton's identities recover the
elementary symmetric functions $e_1, \dots, e_n$ from $p_1, \dots, p_n$ for $n$ quantities, so
they need as many power sums as there are elements, and in characteristic zero only. The
present theorem needs as many power sums as there are available *values*. For a matrix of size
$10^6$ with eigenvalues in $\{0,1,2\}$, Newton would ask for a million traces; Theorem H asks
for three.

---

## 8. Computational evidence

An exhaustive search over all multiplicity vectors $c : \{0,\dots,N\} \to \{0,\dots,M\}$
enumerates every multiset bounded by $N$ with multiplicities at most $M$ and compares power-sum
prefixes. Writing $\#\{k \le N\}$ for the number of unordered pairs of distinct multisets
agreeing on all $p_k$ with $k \le N$, and $\#\{k \le N-1\}$ likewise:

| $N$ | $M$ | $\#\{k \le N\}$ | $\#\{k \le N-1\}$ | first witness |
|-----|-----|------------------|--------------------|----------------|
| 1 | 2 | 0 | 5 | $\{0\}$ vs $\{1\}$ |
| 2 | 1 | 0 | 0 | (needs multiplicity $2$) |
| 2 | 2 | 0 | 4 | $\{0,2\}$ vs $\{1,1\}$ |
| 2 | 3 | 0 | 18 | $\{0,2\}$ vs $\{1,1\}$ |
| 3 | 2 | 0 | 0 | (needs multiplicity $3$) |
| 3 | 3 | 0 | 9 | $\{0,2,2,2\}$ vs $\{1,1,1,3\}$ |

Every entry is explained by the theory. The column $\#\{k \le N\}$ is identically zero: that is
Theorem A. The first witnesses are exactly the binomial parity pairs of Definition 4.4, as
Theorem D predicts, since any near miss has multiplicity difference $\lambda v$ and the smallest
choice $|\lambda| = 1$ within a multiplicity cap gives precisely $E_N$ versus $O_N$. The two
rows with zero near misses are the cases where the cap $M$ is smaller than
$\max_j \binom{N}{j}$ — $\binom{2}{1} = 2 > 1$ and $\binom{3}{1} = 3 > 2$ — so the primitive
kernel vector does not fit inside the search box: by Theorem D no near miss can exist at all.
The growth from $4$ to $18$ near misses as the cap rises from $2$ to $3$ at $N = 2$ is the
count of translates $\bigl(\mathrm{Ms}(c + v_+),\, \mathrm{Ms}(c + v_-)\bigr)$ that fit in the
box, where $v_{\pm}$ are the positive and negative parts of $\lambda v$.

The search also reproduces the alternating table $A(N,k)$: strictly lower triangular with
diagonal $1, -1, 2, -6, 24, -120, 720, -5040, 40320$, matching Lemmas 4.2 and 4.3 exactly.

---

## 9. Algorithms

Three procedures follow directly from the theory.

**(A) Reconstruction from power sums.** Given $N$ and the values $p_0, \dots, p_N$ of a multiset
bounded by $N$, recover the multiplicities by solving the $(N+1) \times (N+1)$ Vandermonde
system $\sum_j c_j j^k = p_k$. Solving it as a general linear system costs $O(N^3)$; exploiting
the Vandermonde structure, the standard Björck–Pereyra style algorithm — equivalently, Newton
interpolation followed by conversion — costs $O(N^2)$ exact rational operations. Theorem A
guarantees existence and uniqueness of the solution when the data really come from a multiset,
and the solution is automatically a vector of nonnegative integers in that case; a
non-integral or negative output certifies that the input was not the power-sum vector of any
multiset bounded by $N$.

**(B) Near-miss detection and certification.** Given two multisets bounded by $N$, compute
$p_0, \dots, p_{N-1}$ for both. If they agree, Theorem D asserts
$c_j(s) - c_j(t) = \lambda (-1)^j \binom{N}{j}$ with $\lambda = c_0(s) - c_0(t)$; verifying this
identity for all $j \le N$ costs $O(N)$ after an $O(N)$ pass computing binomial coefficients by
the recurrence $\binom{N}{j+1} = \binom{N}{j}(N-j)/(j+1)$. The top-index gap can then be read
off without summing anything: it equals $\lambda(-1)^N N!$.

**(C) Extremal witness generation.** To produce the minimal near miss at level $N$, emit the
multiset with multiplicity $\binom{N}{j}$ at even $j \le N$ and the one with multiplicity
$\binom{N}{j}$ at odd $j \le N$. Both have $2^{N-1}$ elements, so writing them out costs
$\Theta(2^N)$; representing them by their multiplicity vectors costs $O(N)$.

---

## 10. Discussion

### 10.1 One fact wearing three hats

Rigidity, sharpness and quantisation are the invertibility, the kernel and a pairing of the
same matrix.

* The $(N+1) \times (N+1)$ matrix $V_{k,j} = j^k$ on the nodes $0, \dots, N$ is invertible.
  *That is Theorem A.*
* Deleting the top row $k = N$ leaves an $N \times (N+1)$ matrix whose kernel is the line
  spanned by $v_j = (-1)^j \binom{N}{j}$. *That is Theorems B and D.*
* Pairing $v$ with the one monomial the truncation omits, $x^N$, gives
  $\langle v, x^N\rangle = (-1)^N N!$. *That is Theorems C and E.*

The finite-difference identity $\Delta^N(x \mapsto x^N) = N!$ is the computation of that
pairing, and the normalisation $v_0 = 1$ is what makes the kernel a *lattice* line rather than
merely a vector-space line, which in turn is what quantises the gap.

### 10.2 Why the window length is the range, not the size

The theorem says: to reconstruct a multiset you need one measurement per possible *value*, not
one per element. This is what makes the statement useful in situations where the multiplicities
are astronomically large but the alphabet is small — degree sequences of graphs with bounded
degree, eigenvalue multiplicities of highly symmetric operators, histograms of quantised
signals. In such settings the moment budget is set by the alphabet, and Theorem E says how
badly an adversary (or a truncation error) can exploit a budget that is one short.

### 10.3 The special status of zero

Observation 6.1 and Theorem G together give a clean account of the boundary. Positive power
sums are blind to the value $0$; the index $k = 0$ is precisely the compensating measurement.
Delete the value from the alphabet and one may delete the index, with rigidity and sharpness
both preserved at window length $N$. This is the correct formulation of a statement that is
false as naively guessed, and it is a good illustration of how a failed conjecture localises
into a theorem once the single obstruction is identified.

### 10.4 Robustness

All statements here are exact-arithmetic statements. In the presence of measurement noise the
quantisation result becomes a stability statement of practical interest: since two distinct
bounded multisets sharing $p_0, \dots, p_{N-1}$ differ at $p_N$ by at least $N!$, an
approximate reconstruction using $N+1$ noisy power sums is safe as long as the accumulated
error is well below $N!$ at the top index — though one must weigh this against the enormous
dynamic range of the data, since $p_N$ itself can be as large as $|s| \cdot N^N$. Making this
tradeoff precise, in the form of a condition number for the Vandermonde system restricted to
integer solutions, is a natural next step.

---

## 11. Future work

1. **Punctured quantisation.** On positive support the kernel of the truncated system on nodes
   $\{1, \dots, N\}$ is again a line; determining its primitive integer generator and the
   corresponding minimal gap — plausibly $N!/N$ times a unit — would complete the picture begun
   in Theorem G.
2. **General node sets.** Replace $\{0, \dots, N\}$ by an arbitrary finite set
   $S \subset \mathbb{Z}$ of size $n$. Rigidity holds verbatim with $n$ measurements
   (Vandermonde on distinct nodes). The kernel of the truncation is spanned by the cofactor
   vector $j \mapsto \prod_{i \ne j} (j - i)^{-1}$ up to normalisation; clearing denominators
   gives an integer generator whose pairing with $x^{n-1}$ is a determinant of Vandermonde type.
   The resulting quantum replaces $N!$ by that determinant.
3. **Several variables.** For multisets of lattice points in $\{0,\dots,N\}^d$ probed by
   monomial moments, the analogous window is the set of exponents in a box, and the analogous
   kernel is generated by tensor products of alternating binomial vectors. Both the
   classification and the quantisation should survive, with $N!$ replaced by $(N!)^d$.
4. **Approximate rigidity.** Quantify the stability of reconstruction: given power sums known
   to additive error $\varepsilon$, for which $\varepsilon$ is the multiset still uniquely
   determined? Theorem E suggests the threshold scales with $N!$ at the top index but with much
   smaller quantities lower down, so the answer should be governed by a weighted condition
   number.
5. **Beyond power sums.** Which other families of $N+1$ symmetric functionals are rigid on
   multisets bounded by $N$, and which admit kernel lines with small primitive generators? The
   question is whether the factorial quantum is special to monomial moments or a general
   feature of interpolation-based rigidity.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Rigidity | $s, t$ bounded by $N$, $p_k(s) = p_k(t)$ for $k \le N$ $\Rightarrow s = t$ |
| Sharpness | For every $N$, $E_N \ne O_N$ agree on $p_k$ for all $k < N$ |
| Exact gap | $p_N(E_N) - p_N(O_N) = (-1)^N N!$ |
| Classification | Any near miss has $c_j(s) - c_j(t) = \lambda(-1)^j\binom{N}{j}$, $\lambda \in \mathbb{Z}$ |
| Quantisation | $N! \mid p_N(s) - p_N(t)$; $\ge N!$ if $s \ne t$; attained by $E_N, O_N$ |
| Size floor | Near miss with $s \ne t$, $N \ge 1$ $\Rightarrow$ $\lvert s\rvert \ge 2^{N-1}$; $\lvert E_N\rvert = 2^{N-1}$ |
| Zero index | $\{0\}$ vs $\emptyset$ shows $k=0$ is needed; on positive support $1 \le k \le N$ is rigid and sharp |
| Spectral form | $\chi_s = \chi_t \iff p_k(s) = p_k(t)$ for $k \le N$; fails for $k < N$ |
| Abundance | Infinitely many near misses at each level |
