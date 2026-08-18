# The Last Question You Must Ask

## How many power sums does it take to recognise a bag of numbers?

Imagine someone has a bag of whole numbers. You are not allowed to look inside. You may only
ask questions of a very restricted kind:

> "Take every number in your bag, raise it to the $k$-th power, and add the results. What do
> you get?"

The answer to that question — for a bag (formally, a *multiset*) $s$ — is called the $k$-th
**power sum**,
$$p_k(s) \;=\; \sum_{x \in s} x^k .$$

The question with $k = 0$ is just "how many numbers are in your bag?", since $x^0 = 1$ for
every $x$ (and by the standard convention $0^0 = 1$). The question with $k = 1$ is "what is
their total?", $k = 2$ asks for the sum of squares, and so on.

Two bags can survive a surprising number of these interrogations while remaining different.
The bag $\{0, 2\}$ and the bag $\{1, 1\}$ both contain two numbers ($p_0 = 2$) and both total
$2$ ($p_1 = 2$). They are indistinguishable to the first two questions. Only at $k = 2$ do
they separate: $0^2 + 2^2 = 4$, while $1^2 + 1^2 = 2$.

So how long must the interrogation go on before you are guaranteed the truth? If the bag is
allowed to contain arbitrarily large numbers, the answer is: forever — no fixed number of
questions ever suffices, because you can always hide the difference higher up. But suppose you
know a ceiling: every number in the bag is at most $N$. Multiplicities are unrestricted — the
bag may contain a million copies of $7$ — but no element exceeds $N$.

Then there is a clean and complete answer, and it comes with a matching counterexample that
shows nothing shorter will do.

---

## The theorem

**Rigidity Theorem.** *Let $s$ and $t$ be finite multisets of natural numbers, all of whose
elements are at most $N$. If*
$$p_k(s) = p_k(t) \quad \text{for every } k = 0, 1, 2, \dots, N,$$
*then $s = t$.*

That is $N + 1$ questions — one for each possible value $0, 1, \dots, N$ that an element could
take. It feels like the right count, and it is: the theorem says the bag is completely
reconstructible from those $N+1$ numbers.

**Sharpness Theorem.** *For every $N$ there exist two different multisets, both bounded by
$N$, whose power sums agree for all $k = 0, 1, \dots, N - 1$.*

So the window $0 \le k \le N$ cannot be shortened, at any level $N$. The $(0,2)$ versus
$(1,1)$ example is exactly the case $N = 2$ of a general construction, and it is not a
coincidental accident but the visible tip of a single algebraic phenomenon.

---

## Why $N+1$ is enough: a bag is a vector, and the matrix is invertible

The proof of rigidity is a change of viewpoint. A bag bounded by $N$ is nothing more than a
list of multiplicities: how many $0$s, how many $1$s, …, how many $N$s. Write $c_j$ for the
number of copies of $j$. Then
$$p_k(s) \;=\; \sum_{j=0}^{N} c_j \, j^k .$$

Read that as a matrix acting on a vector. The unknown is the multiplicity vector
$(c_0, c_1, \dots, c_N)$; the data are the numbers $p_0, \dots, p_N$; and the matrix that
connects them has entries $j^k$ — the classical **Vandermonde matrix** built from the $N+1$
distinct nodes $0, 1, \dots, N$. Vandermonde matrices with distinct nodes are invertible, so
the data determine the unknown. Two bags with the same power sums have the same multiplicity
vector, hence they are the same bag.

There is a way to see the invertibility that requires no determinant formula and shows what is
really happening. Suppose a weight vector $e_0, \dots, e_N$ (rational numbers, possibly
negative — think of it as the difference of two multiplicity vectors) satisfies
$$\sum_{j=0}^{N} e_j \, j^k = 0 \quad \text{for all } k \le N .$$
The left side is a linear functional applied to the monomial $x^k$. Since the monomials
$1, x, \dots, x^N$ span all polynomials of degree at most $N$, the functional
$f \mapsto \sum_j e_j f(j)$ annihilates *every* such polynomial. Now feed it the **Lagrange
basis polynomial** $L_m$ for the nodes $0, \dots, N$ — the unique polynomial of degree $\le N$
with $L_m(m) = 1$ and $L_m(j) = 0$ for all other nodes $j$. The sum collapses to a single
term, and we learn $e_m = 0$. Do this for every $m$: the weight vector is zero.

Interpolation, in other words, is the reason a bounded bag of numbers is rigid. Knowing
$N+1$ power sums is knowing the value of a linear functional on a space of dimension $N+1$,
and the point evaluations at $0, 1, \dots, N$ form a basis of the dual of that space.

---

## Why $N$ is not enough: Pascal's triangle, with signs

If you delete the last question, the Vandermonde matrix loses a row and acquires a kernel — a
one-dimensional space of "invisible differences". Remarkably, the kernel vector can be written
down explicitly, and it is one of the most famous vectors in combinatorics:
$$v_j \;=\; (-1)^j \binom{N}{j}, \qquad j = 0, 1, \dots, N.$$
The alternating row of Pascal's triangle.

Split it into its positive and negative halves. Let $E_N$ be the bag containing
$\binom{N}{j}$ copies of $j$ for every **even** $j \le N$, and let $O_N$ be the bag containing
$\binom{N}{j}$ copies of $j$ for every **odd** $j \le N$. Then for each $k$,
$$p_k(E_N) - p_k(O_N) \;=\; \sum_{j=0}^{N} (-1)^j \binom{N}{j} j^k .$$

That alternating binomial sum is a celebrated quantity: it is the $N$-th **finite difference**
of the function $x \mapsto x^k$, evaluated at $0$. Differencing lowers degree by one, so
applying it $N$ times to a polynomial of degree $k < N$ annihilates it, while applying it to
$x^N$ leaves the constant $N!$. Up to the sign $(-1)^N$ that comes from writing the difference
operator with alternating binomial coefficients, we get exactly
$$\sum_{j=0}^{N} (-1)^j \binom{N}{j} j^k =
\begin{cases} 0, & k < N, \\ (-1)^N \, N!, & k = N. \end{cases}$$

So the two bags $E_N$ and $O_N$ agree on **every** power sum below the top, and separate at
$k = N$ by precisely $(-1)^N N!$ — never by zero, so they really are different bags.

At $N = 2$ this construction gives $E_2 = \{0, 2\}$ (one $0$, one $2$, since
$\binom{2}{0} = \binom{2}{2} = 1$) and $O_2 = \{1, 1\}$ (two $1$s, since $\binom{2}{1} = 2$).
The gap at $k = 2$ is $4 - 2 = 2 = 2!$. At $N = 3$ it gives $\{0, 2, 2, 2\}$ against
$\{1, 1, 1, 3\}$: both have four elements, both sum to $6$, both have sum of squares $12$, and
at the cubes they part company, $24$ versus $30$, a gap of $-6 = -3!$.

The little example we started with was never a curiosity. It was $N = 2$ of Pascal's triangle.

---

## The gap is quantised

The story could have stopped there — a theorem and a matching counterexample. But the kernel
picture says something much stronger, and it is where the subject becomes genuinely rigid
rather than merely tight.

Suppose *any* two bags $s \ne t$, bounded by $N$, agree on all power sums with $k < N$. Their
multiplicity difference lies in the kernel of the truncated Vandermonde matrix, which is the
single line spanned by $v_j = (-1)^j \binom{N}{j}$. So there is a scalar $\lambda$ with
$$c_j(s) - c_j(t) \;=\; \lambda \, (-1)^j \binom{N}{j} \quad \text{for all } j \le N .$$
Now look at $j = 0$: since $v_0 = 1$, the scalar $\lambda$ is exactly the difference in the
number of $0$s — an **integer**. That single observation forces everything else.

**Classification of Near Misses.** *Every pair of bags bounded by $N$ agreeing on all power
sums below the top differs by an integer multiple of the alternating binomial vector.*

**Quantisation of the Gap.** *For such a pair, $N!$ divides $p_N(s) - p_N(t)$. Hence if the
bags are distinct, $|p_N(s) - p_N(t)| \ge N!$, and the pair $E_N, O_N$ attains this bound
exactly.*

You cannot make a near miss cheap. Two bounded bags that fool you for $N$ questions must differ
at the last question by at least $N!$ — a gap of $3628800$ already at $N = 10$. The binomial
pair is not merely one witness among many; it is the minimal one, the primitive generator of
the whole family.

The same argument bounds the *size* of a near miss. Since the multiplicity difference is
$\lambda v$ with $|\lambda| \ge 1$, and the alternating vector has total absolute weight
$\sum_j \binom{N}{j} = 2^N$, any near miss at level $N \ge 1$ must contain at least $2^{N-1}$
elements. And $E_N$ has exactly $2^{N-1}$ elements, since the even binomial coefficients sum to
half of $2^N$. Minimal in separation *and* minimal in size.

---

## What the index $k = 0$ is for

The window $0 \le k \le N$ has an oddity: the very first question, "how many numbers do you
have?", looks different in kind from the others. Can it be dropped, leaving the $N$ questions
$k = 1, \dots, N$?

No — and the reason is embarrassingly simple. The bag $\{0\}$ and the empty bag have identical
power sums for every $k \ge 1$, because zero raised to a positive power contributes nothing.
The value $0$ is invisible to every question except the counting one.

That is the *only* obstruction, and the corrected statement is exact:

**Rigidity on Positive Support.** *If all elements of $s$ and $t$ lie in $\{1, \dots, N\}$ and
$p_k(s) = p_k(t)$ for $k = 1, \dots, N$, then $s = t$. This punctured window — again of length
$N$ — is itself sharp: dropping $k = N$ makes it fail.*

The sharpness witness is the same binomial pair with the zeros simply deleted; deleting them
changes no power sum with $k \ge 1$.

---

## Traces, spectra, and why anyone should care

Rename the objects and the theorem changes discipline. A bag of numbers $s$ is the root
multiset of the monic polynomial
$$\chi_s(X) = \prod_{x \in s} (X - x),$$
and $p_k(s)$ is the $k$-th power sum of its roots. If $A$ is a diagonalisable matrix whose
eigenvalues are exactly the elements of $s$, then $p_k(s) = \operatorname{tr}(A^k)$.

**Spectral Rigidity.** *For monic integer polynomials that split with all roots in
$\{0, 1, \dots, N\}$, equality of the polynomials is equivalent to equality of the first
$N + 1$ power sums of their roots. Two different such polynomials can nevertheless share their
first $N$.*

In matrix language: the traces $\operatorname{tr}(A^0), \dots, \operatorname{tr}(A^N)$ pin down
the entire spectrum of a diagonalisable matrix with integer eigenvalues in $[0, N]$ — and $N$
traces do not. This is the moment-recovery problem that shows up wherever one probes a system
by measuring averages: the eigenvalue histogram of a graph, the degree distribution recovered
from walk counts, a discrete distribution recovered from its moments. The theorem tells you the
exact number of measurements to budget, and the classification tells you exactly what an
adversary who is one measurement short can hide from you: an integer multiple of Pascal's
alternating row, no less, costing at least $N!$ at the moment you were not allowed to take.

---

## Counting the near misses

One might hope near misses are rare enough to ignore. They are not. Padding both bags of the
binomial pair with any number of extra zeros preserves the agreement below the top and
preserves distinctness, so at every level $N$ there are infinitely many pairs of distinct
bounded bags agreeing on all power sums with $k < N$.

An exhaustive machine search over all multiplicity vectors on $\{0, \dots, N\}$ with
multiplicities capped at $M$ agrees. At $N = 2$, $M = 2$ there are four pairs agreeing for
$k \le 1$ and none agreeing for $k \le 2$; at $M = 3$ there are eighteen and none. At $N = 3$,
$M = 3$ there are nine near misses, the first being $\{0,2,2,2\}$ against $\{1,1,1,3\}$ —
level $3$ of the construction, as predicted — and again none survive the full window. At
$N = 3$, $M = 2$ there are none at all: the multiplicity cap $2$ is below the largest binomial
coefficient $\binom{3}{1} = 3$, so the primitive kernel vector does not fit. The near misses
appear precisely when there is room for Pascal's triangle.

Along the way the search reproduces the alternating table
$A(N,k) = \sum_j (-1)^j \binom{N}{j} j^k$: strictly lower triangular, with diagonal
$1, -1, 2, -6, 24, -120, 720, -5040, 40320$ — the factorials, alternating in sign.

---

## The moral

Two facts that look like opposites — a reconstruction theorem and a counterexample — are the
two faces of one linear-algebra statement. The $(N+1) \times (N+1)$ Vandermonde matrix on the
nodes $0, 1, \dots, N$ is invertible: that is rigidity. Delete its last row and the resulting
$N \times (N+1)$ matrix has a one-dimensional kernel spanned by the alternating binomial
vector: that is sharpness. Pair that kernel vector with the one monomial it fails to
annihilate, $x^N$, and you get $(-1)^N N!$: that is the exact size of the extremal gap.

Invertibility, kernel, and pairing. Everything else — the parity split of Pascal's triangle,
the factorial quantisation, the $2^{N-1}$ size floor, the special role of the value zero — is
bookkeeping around those three words.
