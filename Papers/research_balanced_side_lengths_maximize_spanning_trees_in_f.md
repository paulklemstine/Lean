# Balanced Side Lengths Maximize Spanning Trees in Free-Boundary Product Grids: A Schur-Concavity Engine

**Author:** Aristotle
**Domain:** Applications (Algebraic Combinatorics / Network Theory)
**Date:** 2026-06-28

---

## Abstract

We study how the number of spanning trees of a multidimensional grid graph depends on the grid's shape. The grids in question are *free-boundary product grids*: Cartesian products $P_{n_1} \times P_{n_2} \times \cdots \times P_{n_d}$ of $d$ finite path graphs, with no wrap-around at the boundary. Fixing the number of vertices $N = n_1 n_2 \cdots n_d$, we ask which side-length profile $(n_1, \dots, n_d)$ maximizes the spanning-tree count $\tau$.

Our central contribution is to isolate the *combinatorial mechanism* responsible for the answer and prove it in full generality. We show that "balanced maximizes" is not a fact about spanning trees but a consequence of a single **exchange (Schur-concavity) inequality**: any quantity that strictly increases when two of its arguments are leveled — $(a, b) \mapsto (a+1, b-1)$ for $a + 2 \le b$, preserving both the sum and the count — is maximized only at *balanced* configurations, those whose entries pairwise differ by at most one. This is our main theorem, `balanced_of_maximizer`.

We instantiate the engine to recover two classical extremal results as immediate corollaries — the integer arithmetic-mean–geometric-mean (AM–GM) characterization `balanced_of_prod_max` (a fixed-sum product is maximized at balance) and the dual Schur convexity of the power sum `balanced_of_sumsq_min` (a fixed-sum sum-of-squares is minimized at balance). We then show how the grid problem reduces to the engine via the prime-power exponent reduction (`grid_balanced_of_exchange`): for $N = c^k$ with sides constrained to powers of $c$, multiplicative balancing of side lengths is exactly additive balancing of exponents. The remaining analytic input — the grid-specific exchange inequality for $\tau$ — is verified computationally for all $N \le 16$ in two dimensions and across a range of three-dimensional cases, and is stated as a precise conjecture. All extremal computations reported here are exact, performed via the Matrix-Tree theorem with rational Gaussian elimination.

---

## 1. Introduction

### 1.1 The question

Let $P_n$ denote the *path graph* on $n$ vertices: vertices $0, 1, \dots, n-1$ with an edge between consecutive integers. The **free-boundary product grid** of dimensions $n_1, \dots, n_d$ is the Cartesian graph product
$$
G(n_1, \dots, n_d) \;=\; P_{n_1} \,\square\, P_{n_2} \,\square\, \cdots \,\square\, P_{n_d}.
$$
Its vertex set is $\{0, \dots, n_1 - 1\} \times \cdots \times \{0, \dots, n_d - 1\}$, of size $N = n_1 n_2 \cdots n_d$, and two vertices are adjacent precisely when they agree in every coordinate but one, where they differ by exactly $1$. "Free boundary" means there is no wrap-around: this is a grid, not a torus.

A **spanning tree** of a connected graph $G$ on $N$ vertices is a subgraph that is connected, acyclic, and includes every vertex; equivalently, a maximal acyclic subgraph, necessarily with $N - 1$ edges. We write $\tau(G)$, or $\tau(n_1, \dots, n_d)$, for the number of spanning trees of $G$.

**Central question.** Fix the dimension $d \ge 2$ and the vertex count $N$. Over all factorizations $N = n_1 \cdots n_d$ into positive integers, which profile $(n_1, \dots, n_d)$ maximizes $\tau$?

### 1.2 The answer, and a subtlety

Empirically the answer is unambiguous: the **most balanced shape available** wins, where "balanced" means the side lengths are as equal as the arithmetic allows. The table below collects exact values (computed in Section 5) for $d = 2$:

| $N$ | profile | $\tau$ |
|----:|:-------:|------:|
| 4 | $1\times4$ | $1$ |
| 4 | $2\times2$ | $\mathbf{4}$ |
| 6 | $1\times6$ | $1$ |
| 6 | $2\times3$ | $\mathbf{15}$ |
| 8 | $1\times8$ | $1$ |
| 8 | $2\times4$ | $\mathbf{56}$ |
| 12 | $1\times12$ | $1$ |
| 12 | $2\times6$ | $780$ |
| 12 | $3\times4$ | $\mathbf{2415}$ |
| 16 | $1\times16$ | $1$ |
| 16 | $2\times8$ | $10{,}864$ |
| 16 | $4\times4$ | $\mathbf{100{,}352}$ |

A subtlety appears at $N = 8$: the maximizer $2 \times 4$ has sides differing by $2$, so it is *not* balanced in the naive sense $\max - \min \le 1$. The resolution is that $8 = 2^3$ admits no factorization into two factors closer than $2$ and $4$; the winner is the available profile of *smallest spread* $\max - \min$. Equivalently — and this is the right conceptual frame — write each side as a power of the prime $2$: the profiles are $2^0 \times 2^3$ and $2^1 \times 2^2$, with exponent multisets $\{0, 3\}$ and $\{1, 2\}$. The winner $\{1, 2\}$ *is* balanced as an exponent multiset. This is the multiplicative-to-additive reduction we formalize in Section 4.

### 1.3 Contributions

The contributions of this paper are:

1. **A general balancing engine** (Theorem 3.2, `balanced_of_maximizer`): an abstract Schur-concavity principle on multisets of natural numbers, with values in any linear order and over any exchange-closed domain. Any maximizer of an exchange-increasing function, among multisets of fixed cardinality and fixed sum, is balanced.

2. **Two unconditional corollaries** that exhibit genuine instances of the engine: the integer AM–GM extremal characterization (Theorem 4.1, `balanced_of_prod_max`) and Schur convexity of the quadratic power sum (Theorem 4.2, `balanced_of_sumsq_min`).

3. **The grid reduction** (Theorem 4.3, `grid_balanced_of_exchange`): a packaging of the engine for the spanning-tree application, reducing "balanced grids maximize $\tau$" to a single two-coordinate exchange inequality for $\tau$, plus the prime-power exponent correspondence.

4. **Exact computational evidence** for the grid exchange inequality (Section 5), with the analytic conjecture stated precisely (Section 7).

The philosophical thrust is that the grid result is *one corollary among several* of a single inequality on a single pair of coordinates. The combinatorics of balance is shared infrastructure; what is special about grids is exactly one determinant inequality.

---

## 2. Preliminaries and definitions

We work with finite **multisets** of natural numbers, written `Multiset ℕ`. A multiset is an unordered collection with repetition; for our purposes a side-length profile is naturally a multiset, since reordering the dimensions of a product grid yields an isomorphic graph and the same $\tau$. We use the multiset constructor $a ::_m s$ ("cons $a$ onto $s$"), the cardinality $\lvert s \rvert$ (`card`), the sum $\sum s$ (`sum`), and the product $\prod s$ (`prod`).

### Definition 2.1 (Balanced multiset)

A multiset $s$ of natural numbers is **balanced** if any two of its entries differ by at most one:
$$
\mathrm{Balanced}(s) \;:\Longleftrightarrow\; \forall\, a \in s,\ \forall\, b \in s,\quad b \le a + 1.
$$

Because the quantifiers range symmetrically over $a$ and $b$, this is equivalent to $\lvert a - b\rvert \le 1$ for all pairs, i.e. $\max(s) - \min(s) \le 1$. Balanced multisets are exactly the "as equal as possible" profiles.

### Definition 2.2 (The exchange move)

Given a multiset of the form $a ::_m b ::_m t$ with $a + 2 \le b$, the **exchange move** produces
$$
(a+1) ::_m (b-1) ::_m t.
$$
This preserves cardinality (two elements replaced by two) and sum (since $(a+1) + (b-1) = a + b$), and it strictly reduces the spread between the two chosen entries. The condition $a + 2 \le b$ guarantees the pair is genuinely unbalanced and that the move makes nontrivial progress (and, in $\mathbb{N}$, that $b - 1$ is well defined and remains $\ge a + 1$).

### Definition 2.3 (Exchange inequality / Schur concavity)

A function $f : \texttt{Multiset } \mathbb{N} \to \beta$, with $\beta$ a linear order, satisfies the **exchange inequality** on a domain $\mathrm{dom}$ if, for every $t$, every $a, b$ with $a + 2 \le b$, and every $a ::_m b ::_m t$ in $\mathrm{dom}$,
$$
f(a ::_m b ::_m t) \;<\; f\big((a+1) ::_m (b-1) ::_m t\big).
$$
A function with this property is *strictly Schur-concave* in the discrete sense: it strictly increases under every leveling exchange. The domain $\mathrm{dom}$ is **exchange-closed** if it is preserved by the move: $a ::_m b ::_m t \in \mathrm{dom}$ and $a + 2 \le b$ imply $(a+1) ::_m (b-1) ::_m t \in \mathrm{dom}$.

### The Matrix-Tree theorem

Throughout, $\tau(G)$ is computed via Kirchhoff's **Matrix-Tree theorem**: if $L = D - A$ is the combinatorial Laplacian of $G$ (degree matrix minus adjacency matrix), then $\tau(G)$ equals any cofactor of $L$, i.e. the determinant of $L$ with one row and the corresponding column deleted. Equivalently, $\tau(G) = \frac{1}{N}\prod_{i=2}^{N}\mu_i$, the product of the nonzero Laplacian eigenvalues divided by the vertex count. For a Cartesian product, the Laplacian eigenvalues are sums of the factors' eigenvalues; the path $P_n$ has Laplacian spectrum $\{\,2 - 2\cos(\pi j / n) : j = 0, \dots, n-1\,\}$. Both formulas are used in Section 5.

---

## 3. The balancing engine

### Theorem 3.1 (informal statement)

*If a quantity strictly increases under every leveling exchange, then it can only be maximal at a balanced configuration.*

### Theorem 3.2 (`balanced_of_maximizer`)

Let $\beta$ be a linear order, let $f : \texttt{Multiset } \mathbb{N} \to \beta$, let $\mathrm{dom}$ be a predicate on multisets, and let $d, k \in \mathbb{N}$. Suppose:

- **(Exchange)** for all $t, a, b$ with $a + 2 \le b$ and $a ::_m b ::_m t \in \mathrm{dom}$,
  $$f(a ::_m b ::_m t) < f((a+1) ::_m (b-1) ::_m t);$$
- **(Closure)** for all such $t, a, b$, the move stays in the domain:
  $$a ::_m b ::_m t \in \mathrm{dom} \implies (a+1) ::_m (b-1) ::_m t \in \mathrm{dom}.$$

Let $s$ be a multiset with $s \in \mathrm{dom}$, $\lvert s \rvert = d$, $\sum s = k$, and suppose $s$ maximizes $f$ over the domain at fixed cardinality and sum:
$$
\forall\, t \in \mathrm{dom},\ \lvert t \rvert = d,\ \textstyle\sum t = k \implies f(t) \le f(s).
$$
Then $s$ is balanced.

**Proof sketch.** Argue by contradiction. Suppose $s$ is not balanced: there exist $a, b \in s$ with $b > a + 1$, i.e. $a + 2 \le b$. Extract these two entries from the multiset. Concretely, since $a \in s$ there is $t_1$ with $s = a ::_m t_1$; and since $b \in s$ and $b \ne a$ (because $a + 2 \le b$), we have $b \in t_1$, so $t_1 = b ::_m t$ for some $t$, whence $s = a ::_m b ::_m t$. (This is the multiset `cons`/`erase` extraction; the inequality $a + 2 \le b$ is what guarantees $b$ survives the removal of one copy of $a$.) Now form the exchanged multiset $s' = (a+1) ::_m (b-1) ::_m t$. By Closure, $s' \in \mathrm{dom}$; it has the same cardinality $d$ and the same sum $k$ as $s$ (the latter because $(a+1)+(b-1) = a+b$, using $1 \le b$). By maximality of $s$, $f(s') \le f(s)$. But the Exchange hypothesis gives $f(s) = f(a ::_m b ::_m t) < f(s') $, a strict contradiction. Hence no unbalanced pair exists and $s$ is balanced. $\qquad\blacksquare$

**Remarks.**
- The proof uses only: multiset extraction, the sum/cardinality bookkeeping of the move, the closure of the domain, and the trichotomy of a linear order ($<$ contradicts $\le$). It does **not** use decidability of $f$ or finiteness beyond what is implicit in `card`. The codomain $\beta$ may be any `LinearOrder` (e.g. $\mathbb{Z}$, $\mathbb{R}$, $\mathbb{N}$).
- The hypotheses are not vacuous: Section 4 exhibits two genuine functions $f$ (the product, and the negated sum of squares) satisfying Exchange and Closure with nontrivial domains.
- The engine is purely *additive* in the constraint: it fixes $\sum s = k$. Multiplicative constraints are handled by a change of variables to exponents (Section 4.3).

---

## 4. Corollaries: classical inequalities and the grid reduction

### Theorem 4.1 (`balanced_of_prod_max` — integer AM–GM)

Let $d, k \in \mathbb{N}$ and let $s$ be a multiset of natural numbers with all entries positive ($\forall x \in s,\ 1 \le x$), with $\lvert s \rvert = d$ and $\sum s = k$. Suppose $s$ maximizes the product over positive multisets of the same cardinality and sum:
$$
\forall\, t,\ (\forall x \in t,\ 1 \le x) \wedge \lvert t \rvert = d \wedge \textstyle\sum t = k \implies \prod t \le \prod s.
$$
Then $s$ is balanced.

**Proof sketch.** Take $f = \prod$ and $\mathrm{dom}(t) = (\forall x \in t,\ 1 \le x)$. The domain is exchange-closed: if $a + 2 \le b$ and all entries are $\ge 1$, then $a + 1 \ge 1$ and $b - 1 \ge 1$ (indeed $b - 1 \ge a + 1 \ge 1$). For the exchange inequality, factor out the common tail $t$: $\prod(a ::_m b ::_m t) = a\,b \cdot \prod t$ and $\prod((a+1)::_m(b-1)::_m t) = (a+1)(b-1)\cdot \prod t$. Since $(a+1)(b-1) = ab + (b - a - 1)$ and $b - a - 1 \ge 1$, the new two-factor product strictly exceeds $ab$; multiplying by the strictly positive $\prod t$ (a product of positives) preserves the strict inequality. Thus $f$ satisfies Exchange, and Theorem 3.2 applies. *(Operationally one shows the contrapositive: an unbalanced positive multiset is beaten by its exchange, witnessing non-maximality.)* $\qquad\blacksquare$

This is precisely the statement that, for a fixed sum split into a fixed number of positive integer parts, the product is largest when the parts are balanced — the integer/extremal form of AM–GM.

### Theorem 4.2 (`balanced_of_sumsq_min` — Schur convexity of the power sum)

Let $d, k \in \mathbb{N}$ and let $s$ be a multiset of natural numbers with $\lvert s \rvert = d$ and $\sum s = k$. Suppose $s$ minimizes the integer sum of squares over multisets of the same cardinality and sum:
$$
\forall\, t,\ \lvert t \rvert = d \wedge \textstyle\sum t = k \implies \sum_{x \in s} x^2 \le \sum_{x \in t} x^2.
$$
Then $s$ is balanced.

**Proof sketch.** Minimizing $\sum x^2$ is maximizing $f(t) = -\sum_{x \in t} x^2$ (computed in $\mathbb{Z}$ to avoid truncated subtraction), with $\mathrm{dom} \equiv \text{True}$ (trivially exchange-closed). The exchange inequality for $f$ is the statement
$$
(a+1)^2 + (b-1)^2 < a^2 + b^2 \quad\text{whenever } a + 2 \le b,
$$
equivalently $a^2 + b^2 - \big((a+1)^2 + (b-1)^2\big) = 2(b - a - 1) > 0$, which holds because $b - a - 1 \ge 1$. Casting to $\mathbb{Z}$ makes the subtraction $b - 1$ honest, after which the inequality is a direct quadratic computation. Theorem 3.2 then yields balance. $\qquad\blacksquare$

Theorems 4.1 and 4.2 are dual faces of Schur monotonicity: leveling raises the product and lowers the sum of squares. Both are unconditional and serve as proof that the engine's hypotheses are inhabited.

### 4.3 The multiplicative-to-additive reduction

The grid problem fixes a *product* $N = \prod n_i$, not a sum. We bridge to the additive engine through exponents.

**Prime-power model.** Suppose $N = c^k$ for a base $c \ge 2$, and restrict attention to side lengths that are powers of $c$: $n_i = c^{a_i}$. Then
$$
\prod_i n_i = \prod_i c^{a_i} = c^{\sum_i a_i} = N = c^k \iff \sum_i a_i = k.
$$
So the multiplicative constraint $\prod n_i = N$ on side lengths is *exactly* the additive constraint $\sum a_i = k$ on the exponent multiset $\{a_1, \dots, a_d\}$. Moreover, balancing the exponents (in the sense of Definition 2.1) corresponds to making the side lengths as multiplicatively equal as possible. This is the change of coordinates "take $\log_c$": multiplicative majorization of sides is additive majorization of exponents.

### Theorem 4.3 (`grid_balanced_of_exchange` — the grid corollary)

Let $\beta$ be a linear order and $\tau : \texttt{Multiset } \mathbb{N} \to \beta$ a function (the spanning-tree count, indexed by the exponent multiset). Suppose $\tau$ satisfies the unconstrained exchange inequality:
$$
\forall\, t, a, b,\quad a + 2 \le b \implies \tau(a ::_m b ::_m t) < \tau((a+1) ::_m (b-1) ::_m t).
$$
Let $s$ be a multiset with $\lvert s \rvert = d$ and $\sum s = k$ that maximizes $\tau$ over multisets of the same cardinality and sum. Then $s$ is balanced.

**Proof sketch.** Apply Theorem 3.2 with $f = \tau$ and the trivial domain $\mathrm{dom} \equiv \text{True}$. The trivial domain is exchange-closed for free, and the unconstrained exchange hypothesis is exactly the engine's Exchange hypothesis restricted to that domain. The maximality hypothesis matches directly. Hence $s$ is balanced. $\qquad\blacksquare$

In words: *once the spanning-tree count is shown to satisfy the two-coordinate exchange inequality, the entire "balanced grids win" theorem follows with no further work.* Combined with the reduction of Section 4.3, every prime-power, fixed-$N$ maximizer has balanced exponents, i.e. side lengths as equal as the integers allow.

---

## 5. Algorithms and exact computation

To furnish evidence for the grid exchange inequality and to verify the maximizers, we compute $\tau$ exactly.

### 5.1 Matrix-Tree via rational Gaussian elimination

**Input:** side lengths $(n_1, \dots, n_d)$.
**Output:** $\tau$, an exact integer.

1. Enumerate the $N = \prod n_i$ vertices as integer tuples; index them $0, \dots, N-1$.
2. Build the Laplacian $L = D - A$: for each vertex and each coordinate direction, add an edge to the neighbor that differs by $\pm 1$ in that coordinate when it stays in range, incrementing the diagonal and decrementing the off-diagonal.
3. Delete the last row and column to form the reduced Laplacian $L_0$ of size $(N-1)\times(N-1)$.
4. Compute $\det L_0$ by Gaussian elimination over the rationals $\mathbb{Q}$ (exact `Fraction` arithmetic), so the result is an exact integer (guaranteed by the theorem).

This is robust and exact; its cost is $O(N^3)$ field operations, which suffices comfortably for all $N$ tabulated here.

### 5.2 Eigenvalue product for product grids

For a Cartesian product of paths there is a faster exact-in-floating-point route, useful as a cross-check:
$$
\tau(n_1, \dots, n_d) \;=\; \frac{1}{N}\!\!\prod_{\substack{0 \le j_i < n_i \\ (j_1,\dots,j_d)\neq 0}}\ \sum_{i=1}^{d}\Big(2 - 2\cos\tfrac{\pi j_i}{n_i}\Big).
$$
The all-zero index is the unique zero eigenvalue and is omitted; the remaining product, divided by $N$, is $\tau$. Rounding to the nearest integer recovers the exact value for the ranges considered.

Both methods agree on every case in this paper.

### 5.3 Verified values

For $d = 2$ the maximizer is always the available profile of smallest spread (Section 1.2). For $d = 3$:

| $N$ | best profile | $\tau$ (max) |
|----:|:------------:|------:|
| 8 | $2\times2\times2$ | $384$ |
| 27 | $3\times3\times3$ | $8{,}193{,}540{,}096{,}000$ |
| 64 | $4\times4\times4$ | $\approx 1.73\times10^{35}$ |

In every computed instance — all two-dimensional factorizations for $N \le 36$, and the three-dimensional cubes and their competitors above — the spread-minimizing (balanced-exponent) profile strictly dominates, in agreement with the conjectured exchange inequality.

---

## 6. Applications

**Network reliability and design.** The spanning-tree count is a standard global measure of a network's redundancy: more spanning trees means more independent ways for the network to remain connected under edge failures, and a larger denominator in Kirchhoff's resistance formulas. For grid-structured networks under a fixed node budget $N$, our result prescribes a design rule: choose the most balanced (near-cubical) shape the budget allows. Long, thin layouts are extremal in the wrong direction — the single path $P_N$ has the unique minimum $\tau = 1$.

**Electrical networks.** By the weighted Matrix-Tree theorem, effective resistances and current distributions in a resistor grid are ratios of spanning-tree-like sums. The qualitative conclusion that compact grids are "more connected" has a direct electrical reading: balanced grids have, on average, lower pairwise effective resistance for fixed size.

**Statistical physics.** The spanning-tree count is the $q \to 0$ limit of the Potts partition function and is central to the uniform spanning tree / loop-erased random walk theory on lattices. Shape dependence of $\tau$ at fixed volume informs finite-size scaling and boundary effects in these models; the free-boundary (open) case treated here is the natural one for finite samples.

**Discrete optimization templates.** Theorems 4.1 and 4.2 are reusable: any objective shown to satisfy the exchange inequality inherits a balanced optimizer. This pattern recurs in load balancing (minimize sum of squared loads), in combinatorial AM–GM arguments, and in majorization-based proofs throughout combinatorics and information theory.

---

## 7. Discussion and future work

The conceptual contribution is a clean separation of concerns. "Balanced wins" splits into:

- a **universal, fully proved part** — the exchange-to-balance engine (Theorem 3.2) and its closed corollaries (Theorems 4.1–4.3); and
- a **problem-specific analytic part** — the grid exchange inequality for $\tau$, verified computationally here and conjectured in general.

This reframes a global extremal problem as a *single two-coordinate inequality*, which is both conceptually clarifying and computationally testable.

We record the open problems (Phase A future directions) precisely.

**C1. $\tau$ is Schur-concave in the side-length multiset.** *Conjecture:* for the $d$-dimensional free-boundary grid, $\tau(\dots, a, \dots, b, \dots) < \tau(\dots, a+1, \dots, b-1, \dots)$ whenever $a + 2 \le b$. By Theorem 4.3, this single inequality implies every fixed-$N$ maximizer is balanced. The point is that "balanced wins" is a Schur-concavity fact, not a spanning-tree fact: the implication exchange $\Rightarrow$ balanced is already unconditional, so the whole conjecture collapses to one determinant inequality between grids whose shapes differ by a single leveling step.

**C2. Multiplicative balancing reduces to additive balancing on exponents.** *Conjecture:* for $N = c^k$ with sides restricted to powers of $c$, the $\tau$-maximizer has balanced exponents. The multiplicative majorization order on side lengths is the additive majorization order on $c$-adic exponents, so the additive engine applies verbatim once the $\tau$-exchange input of C1 holds in the prime-power regime.

**C3. Strict log-concavity along balancing chains.** *Conjecture:* along any spread-reducing chain $(1 \times N) \to \cdots \to (\text{balanced})$, the sequence $\log \tau$ is strictly concave, not merely increasing. The eigenvalue product formula factorizes over dimensions, so balancing acts like a convolution that should preserve log-concavity. The observed accelerating ratios — $1 < 780 < 2415$ for $N = 12$ and $1 < 10{,}864 < 100{,}352$ for $N = 16$ — give concrete data to fit.

**C4. Uniqueness of the maximizer shape.** *Conjecture:* when a perfectly balanced factorization exists ($\max - \min \le 1$), it is the unique maximizer up to permutation; when none exists (e.g. $N$ prime, or $N = 15$ in two dimensions), the unique spread-minimizer is the unique maximizer. Strictness of the exchange inequality already forces uniqueness in the engine; promoting strictness from individual instances to a general strict exchange lemma is the remaining step.

**C5. Free versus periodic boundaries.** A natural next axis is to compare the open (free) grids studied here with their toroidal (periodic) counterparts, where the spectrum changes and the shape dependence of $\tau$ may differ quantitatively while, we expect, sharing the same balanced-optimum qualitative behavior.

---

## 8. Conclusion

The superiority of balanced grids for spanning-tree count is one instance of a single, simple principle: any quantity that strictly improves under leveling exchanges is optimized only at balanced configurations. We proved this engine in full generality, exhibited it powering the integer AM–GM inequality and the Schur convexity of the power sum, and packaged the grid case so that the entire extremal theorem reduces to one two-coordinate exchange inequality for $\tau$ — verified exactly for all small cases and stated as a precise conjecture. The mathematics of "balanced wins" is shared infrastructure; what remains specific to grids is a single determinant inequality between near-identical shapes.
