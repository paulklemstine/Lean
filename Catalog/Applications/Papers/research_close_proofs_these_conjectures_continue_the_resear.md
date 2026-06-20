# Transition Endomorphisms: A Chapman–Kolmogorov Law and the Stabilization of Transition Rank

**Author:** Aristotle
**Date:** 2026-06-20

## Abstract

We introduce the *transition endomorphism* of a stream of linear
self-maps on a vector space: given a sequence
$f : \mathbb{N} \to \operatorname{End}_K(V)$ and indices $i \le j$, the
transition endomorphism $\operatorname{trans}(f, i, j)$ is the ordered
composition $f(j-1) \circ \cdots \circ f(i)$ over the half-open window
$[i, j)$, with the convention that an empty or reversed window yields the
identity. Our central structural result is a *concatenation law* of
Chapman–Kolmogorov type: for $i \le j \le k$,
$\operatorname{trans}(f, i, k) = \operatorname{trans}(f, j, k) \circ
\operatorname{trans}(f, i, j)$. From this single identity, combined with
the classical submultiplicativity of rank under composition, we derive
that the transition rank is monotone non-increasing along nested
windows. We identify the constant-stream transition map with the monoid
power $g^{\,j-i}$, which yields as a corollary the rank decay of iterates
$\operatorname{rank}(g^{\,n+1}) \le \operatorname{rank}(g^{\,n})$.
Finally, over a finite-dimensional space we package the cardinal rank as
a bounded natural-number sequence and prove that the window-from-zero
transition-rank sequence is antitone and hence eventually constant, by
isolating a reusable well-foundedness lemma for antitone $\mathbb{N} \to
\mathbb{N}$ sequences. The development deliberately *reuses* standard
rank facts rather than re-deriving a Sylvester-type inequality, so that
the entire theory rests on one combinatorial concatenation law. All
results have been formally verified.

**Keywords:** transition endomorphism, Chapman–Kolmogorov, rank
submultiplicativity, antitone sequence, eventual constancy, transfer
operator, iterate rank, finite-dimensional linear algebra.

**MSC 2020:** 15A03 (vector spaces, linear dependence, rank), 47A05
(general operator theory), 06A06 (partial orders), 37A30 (transfer
operators).

---

## 1. Introduction

A recurring pattern across mathematics is the *transfer operator*: an
object that advances a system one step at a time, and whose iterated or
windowed composition advances it over an interval. In probability this
is the transition kernel of a Markov chain; in dynamics it is the
Perron–Frobenius/Koopman operator; in linear time-varying control it is
the state-transition matrix. In each case a fundamental bookkeeping law
holds — to advance from $i$ to $k$, advance from $i$ to $j$ and then from
$j$ to $k$ — and in each case a notion of "effective dimension" or
"surviving information" can only degrade as the window grows.

This paper isolates that pattern in its purest linear-algebraic form. We
work with a stream of endomorphisms of a vector space and define the
**transition endomorphism** over a window. We prove the windowed
composition law and show that essentially every rank-monotonicity
phenomenon associated with such streams is a one-line corollary of it,
given only the standard submultiplicativity of rank under composition.

### Contributions

1. A clean recursive definition of the transition endomorphism
   $\operatorname{trans}(f, i, j)$ and its boundary behaviour
   (Section 3).
2. The Chapman–Kolmogorov **concatenation law** `transEndo_comp`
   (Theorem 4.1).
3. Rank monotonicity along nested windows in both factor directions
   (`rank_transEndo_le_left`, `rank_transEndo_le_right`), the one-step
   decrease (`rank_transEndo_succ_le`), and the antitone statement
   (`rank_transEndo_antitone`) (Section 5).
4. Identification of constant streams with monoid powers
   (`transEndo_const`) and the consequent rank decay of iterates
   (`rank_pow_succ_le`) (Section 6).
5. Over a finite-dimensional space, the natural-number transition-rank
   sequence is bounded and antitone, hence eventually constant
   (`rankSeq_le_finrank`, `rankSeq_antitone`, `rankSeq_eventually_const`),
   via the reusable order lemma `antitone_nat_eventually_const`
   (Section 7).

A design principle throughout is *reuse over re-derivation*: we treat
the submultiplicativity inequalities as black boxes and let the
combinatorial concatenation law carry the structural weight.

---

## 2. Preliminaries and notation

Throughout, $K$ is a field, $V$ a vector space over $K$, and
$\operatorname{End}_K(V)$ the (noncommutative, unital) ring of
$K$-linear self-maps $V \to V$ under composition, with identity
$\mathrm{id}$. We write $g \circ h$ for composition and $g^{\,n}$ for the
$n$-fold composite ($g^{\,0} = \mathrm{id}$).

The **rank** of $g \in \operatorname{End}_K(V)$ is the dimension of its
image,
$$\operatorname{rank}(g) = \dim_K \operatorname{im}(g),$$
understood as a cardinal in general (and identified with a natural number
when $V$ is finite-dimensional). When $V$ is finite-dimensional we write
$n = \dim_K V$ for its dimension.

We take as given the two classical **submultiplicativity** inequalities,
valid for all $g, h \in \operatorname{End}_K(V)$:
$$
\operatorname{rank}(g \circ h) \le \operatorname{rank}(g)
\tag{S-left}
$$
$$
\operatorname{rank}(g \circ h) \le \operatorname{rank}(h).
\tag{S-right}
$$
*(S-left)* holds because $\operatorname{im}(g\circ h) \subseteq
\operatorname{im}(g)$, and *(S-right)* because $g$ restricted to
$\operatorname{im}(h)$ has image $\operatorname{im}(g \circ h)$, whose
dimension cannot exceed $\dim_K \operatorname{im}(h)$. These are the only
nontrivial external facts we use; in particular we do *not* re-prove any
Sylvester rank inequality.

A sequence $a : \mathbb{N} \to \mathbb{N}$ is **antitone** if
$m \le m' \Rightarrow a(m') \le a(m)$. It is **eventually constant** if
there exist $N$ and $c$ with $a(m) = c$ for all $m \ge N$.

---

## 3. The transition endomorphism

### Definition 3.1 (Transition endomorphism)

Let $f : \mathbb{N} \to \operatorname{End}_K(V)$ and $i \in \mathbb{N}$.
The **transition endomorphism** $\operatorname{trans}(f, i, \cdot) :
\mathbb{N} \to \operatorname{End}_K(V)$ is defined by recursion on the
upper endpoint:
$$
\operatorname{trans}(f, i, 0) = \mathrm{id},
\qquad
\operatorname{trans}(f, i, j+1) =
\begin{cases}
f(j) \circ \operatorname{trans}(f, i, j) & \text{if } i \le j,\\[2pt]
\mathrm{id} & \text{if } i > j.
\end{cases}
$$

Unfolding the recursion, for $i \le j$ this is the ordered composition
over the half-open window $[i, j)$,
$$
\operatorname{trans}(f, i, j) = f(j-1) \circ f(j-2) \circ \cdots \circ f(i),
$$
read right-to-left: an input vector meets $f(i)$ first and $f(j-1)$ last.
The corresponding formal name is `transEndo f i j`.

### Basic identities

The following are immediate from the definition.

- **(`transEndo_zero`)** $\operatorname{trans}(f, i, 0) = \mathrm{id}$.
- **(`transEndo_succ_of_le`)** If $i \le j$ then
  $\operatorname{trans}(f, i, j+1) = f(j) \circ \operatorname{trans}(f, i, j)$.
- **(`transEndo_eq_id_of_le`)** If $j \le i$ then
  $\operatorname{trans}(f, i, j) = \mathrm{id}$ (empty/reversed window).
- **(`transEndo_self`)** $\operatorname{trans}(f, i, i) = \mathrm{id}$.

*Proof sketches.* The first is definitional. The second is the recursive
clause under the hypothesis $i \le j$. For the third, if $j = 0$ it is
the base case; if $j = j'+1$ then $j \le i$ forces $i > j'$, so the
recursion takes the identity branch. The fourth is the special case
$j = i$ of the third. $\qquad\blacksquare$

---

## 4. The concatenation law

### Theorem 4.1 (Chapman–Kolmogorov concatenation, `transEndo_comp`)

For all $i, j, k \in \mathbb{N}$ with $i \le j \le k$,
$$
\operatorname{trans}(f, i, k)
\;=\;
\operatorname{trans}(f, j, k) \circ \operatorname{trans}(f, i, j).
$$

**Proof sketch.** Induct on $k$, generalizing $i$ and $j$.

*Base $k = 0$.* Then $i \le j \le 0$ forces $i = j = 0$, and both sides
equal $\mathrm{id}$ (each factor is an empty window).

*Inductive step $k \mapsto k+1$.* Assume the law for $k$ and suppose
$i \le j \le k+1$. Split on whether the middle index reaches the top:

- **Case $j \le k$.** Then $i \le k$ as well. Expand both transitions
  whose upper endpoint is $k+1$ using `transEndo_succ_of_le`:
  $$
  \operatorname{trans}(f, i, k+1) = f(k) \circ \operatorname{trans}(f, i, k),
  \qquad
  \operatorname{trans}(f, j, k+1) = f(k) \circ \operatorname{trans}(f, j, k).
  $$
  Apply the induction hypothesis to rewrite
  $\operatorname{trans}(f, i, k) = \operatorname{trans}(f, j, k) \circ
  \operatorname{trans}(f, i, j)$, then reassociate composition:
  $$
  f(k) \circ \big(\operatorname{trans}(f, j, k) \circ \operatorname{trans}(f, i, j)\big)
  = \big(f(k) \circ \operatorname{trans}(f, j, k)\big) \circ \operatorname{trans}(f, i, j),
  $$
  and the left factor is exactly $\operatorname{trans}(f, j, k+1)$.

- **Case $j = k+1$.** Then the outer leg $\operatorname{trans}(f, j, k+1)
  = \operatorname{trans}(f, k+1, k+1) = \mathrm{id}$ by `transEndo_self`,
  so the right-hand side collapses to $\operatorname{trans}(f, i, k+1)$,
  which is the left-hand side.

This case split is genuine — it is precisely where the boundary
convention for empty windows is used — so the theorem is not vacuous.
$\qquad\blacksquare$

The concatenation law is associative in the expected sense: applied
twice it shows $\operatorname{trans}(f, i, \ell)$ factors through any
chain $i \le j \le k \le \ell$, consistent with associativity of
composition.

---

## 5. Rank monotonicity

Combining Theorem 4.1 with the submultiplicativity inequalities yields
the rank-monotonicity package. All four statements assume a nested
window $i \le j \le k$.

### Theorem 5.1 (Outer-factor bound, `rank_transEndo_le_left`)

$$
\operatorname{rank}\big(\operatorname{trans}(f, i, k)\big)
\le
\operatorname{rank}\big(\operatorname{trans}(f, j, k)\big).
$$

**Proof.** By Theorem 4.1, $\operatorname{trans}(f, i, k) =
\operatorname{trans}(f, j, k) \circ \operatorname{trans}(f, i, j)$.
Apply *(S-left)* with $g = \operatorname{trans}(f, j, k)$ and
$h = \operatorname{trans}(f, i, j)$. $\qquad\blacksquare$

### Theorem 5.2 (Inner-factor bound, `rank_transEndo_le_right`)

$$
\operatorname{rank}\big(\operatorname{trans}(f, i, k)\big)
\le
\operatorname{rank}\big(\operatorname{trans}(f, i, j)\big).
$$

**Proof.** Same factorization, now apply *(S-right)*. $\qquad\blacksquare$

### Corollary 5.3 (One-step decrease, `rank_transEndo_succ_le`)

For $i \le j$,
$$
\operatorname{rank}\big(\operatorname{trans}(f, i, j+1)\big)
\le
\operatorname{rank}\big(\operatorname{trans}(f, i, j)\big).
$$

**Proof.** Theorem 5.2 with $k = j+1$ and the inner window $[i, j)$,
using $j \le j+1$. $\qquad\blacksquare$

### Corollary 5.4 (Antitonicity, `rank_transEndo_antitone`)

The map $k \mapsto \operatorname{rank}\big(\operatorname{trans}(f, i, k)\big)$
is non-increasing for $k \ge i$: if $i \le j \le k$ then
$\operatorname{rank}(\operatorname{trans}(f, i, k)) \le
\operatorname{rank}(\operatorname{trans}(f, i, j))$.

**Proof.** Restatement of Theorem 5.2. $\qquad\blacksquare$

Interpretation: from a fixed start $i$, *widening the window never
increases the surviving rank*. Each additional station can only collapse
directions, never create them.

---

## 6. Constant streams and iterate rank

### Theorem 6.1 (Constant stream, `transEndo_const`)

Let $g \in \operatorname{End}_K(V)$ and let $f(n) = g$ for all $n$. Then
for $i \le j$,
$$
\operatorname{trans}(f, i, j) = g^{\,j-i}.
$$

**Proof sketch.** Induct on the witness of $i \le j$. The base case
$j = i$ gives $\operatorname{trans}(f, i, i) = \mathrm{id} = g^{0}$ by
`transEndo_self`. For the step from $j$ to $j+1$ with $i \le j$, write
$(j+1) - i = (j - i) + 1$ and use $g^{(j-i)+1} = g \circ g^{\,j-i}$
together with `transEndo_succ_of_le`:
$$
\operatorname{trans}(f, i, j+1) = g \circ \operatorname{trans}(f, i, j)
= g \circ g^{\,j-i} = g^{(j+1)-i}.
$$
$\qquad\blacksquare$

This identity is the bridge between the windowed transfer operator and
the classical monoid of iterates of a single endomorphism.

### Theorem 6.2 (Iterate rank decay, `rank_pow_succ_le`)

For every $g \in \operatorname{End}_K(V)$ and every $n \in \mathbb{N}$,
$$
\operatorname{rank}(g^{\,n+1}) \le \operatorname{rank}(g^{\,n}).
$$

**Proof.** Write $g^{\,n+1} = g \circ g^{\,n}$ and apply *(S-right)* with
$h = g^{\,n}$. Equivalently, this is Corollary 5.4 specialized to the
constant stream via Theorem 6.1. $\qquad\blacksquare$

Theorem 6.2 expresses, at the level of rank, the descending chain of
iterate images
$$
V \supseteq \operatorname{im}(g) \supseteq \operatorname{im}(g^2)
\supseteq \cdots,
$$
whose eventual stabilization (over a finite-dimensional space) is the
content of the Fitting decomposition. We make the stabilization precise
in the next section.

---

## 7. Stabilization of the transition-rank sequence

We now assume $V$ is finite-dimensional, $n = \dim_K V < \infty$, so that
$\operatorname{rank}(g)$ is a finite cardinal identifiable with a natural
number $\operatorname{rank}(g) \le n$.

### Definition 7.1 (Transition-rank sequence)

For a stream $f$ and indices $i \le j$, the **transition-rank** is the
natural number
$$
\operatorname{rankSeq}(f, i, j) =
\big(\operatorname{rank}\,\operatorname{trans}(f, i, j)\big)_{\mathbb{N}},
$$
the natural-number value of the (finite) cardinal rank. The formal name
is `rankSeq f i j`.

### Lemma 7.2 (Uniform bound, `rankSeq_le_finrank`)

For all $i \le j$,
$$
\operatorname{rankSeq}(f, i, j) \le \dim_K V = n.
$$

**Proof sketch.** The image of any endomorphism is a subspace of $V$, so
its dimension is at most $\dim_K V$; transferring this cardinal
inequality to $\mathbb{N}$ is legitimate because the rank is below
$\aleph_0$ in finite dimension. $\qquad\blacksquare$

### Lemma 7.3 (Antitonicity in $\mathbb{N}$, `rankSeq_antitone`)

For fixed $i$, the sequence $m \mapsto \operatorname{rankSeq}(f, i, m)$ is
antitone for $m \ge i$: if $i \le j \le k$ then
$\operatorname{rankSeq}(f, i, k) \le \operatorname{rankSeq}(f, i, j)$.

**Proof sketch.** Apply $\operatorname{toNat}$ to Corollary 5.4. The
order-preservation of $\operatorname{toNat}$ on cardinals below
$\aleph_0$ (here both ranks are finite) turns the cardinal inequality
into the desired natural-number inequality. $\qquad\blacksquare$

### Lemma 7.4 (Well-foundedness, `antitone_nat_eventually_const`)

Every antitone sequence $a : \mathbb{N} \to \mathbb{N}$ is eventually
constant: there exist $N, c \in \mathbb{N}$ with $a(m) = c$ for all
$m \ge N$.

**Proof sketch.** The set of values $\{a(m) : m \in \mathbb{N}\}
\subseteq \mathbb{N}$ is nonempty, so by well-ordering it has a least
element $c$, attained at some index $N$, i.e. $a(N) = c$. For any
$m \ge N$, antitonicity gives $a(m) \le a(N) = c$, while minimality of
$c$ gives $a(m) \ge c$; hence $a(m) = c$. (Equivalently: an infinite
strictly descending chain in $\mathbb{N}$ is impossible, so the antitone
sequence can strictly decrease only finitely often.) $\qquad\blacksquare$

### Theorem 7.5 (Eventual constancy, `rankSeq_eventually_const`)

For every stream $f$ over a finite-dimensional $V$, the window-from-zero
transition-rank sequence $m \mapsto \operatorname{rankSeq}(f, 0, m)$ is
eventually constant: there exist $N$ and $c$ with
$$
\operatorname{rankSeq}(f, 0, m) = c \qquad \text{for all } m \ge N.
$$

**Proof.** By Lemma 7.3 the sequence is antitone (taking $i = 0$); by
Lemma 7.4 every antitone $\mathbb{N} \to \mathbb{N}$ sequence is
eventually constant. (Lemma 7.2 confirms the sequence is bounded by $n$,
making the descending chain finite in an even stronger sense.)
$\qquad\blacksquare$

The eventual value $c$ is the **stable transition rank** of the stream:
the dimension of the information that survives arbitrarily long windows.
For the constant stream $f(n) = g$, Theorem 6.1 identifies the sequence
with $m \mapsto \operatorname{rank}(g^{\,m})$, whose stable value is the
dimension of the generalized (Fitting) image $\bigcap_m
\operatorname{im}(g^{\,m})$.

---

## 8. Algorithms

The theory is constructive and yields immediate algorithms over a finite
field or exact field (e.g. $\mathbb{Q}$).

### Algorithm A — Windowed transition rank by accumulation

Given matrices $M_0, \dots, M_{T-1} \in K^{n\times n}$ representing the
stream and a window $[i, j)$, compute $\operatorname{trans}(f, i, j)$ by
the recursion of Definition 3.1 (left-multiplying by $M_j$ as $j$
advances) and report its rank by Gaussian elimination. Complexity:
$O\big((j-i)\,n^{\omega}\big)$ for the products plus $O(n^{\omega})$ for
the final rank, where $n^\omega$ is the cost of one matrix multiply/rank.

### Algorithm B — Detecting stabilization

Compute the antitone sequence $r_m = \operatorname{rankSeq}(f, 0, m)$ for
$m = 0, 1, 2, \dots$ via Algorithm A's incremental product. By
Theorem 7.5 the sequence is non-increasing and bounded below by $0$ and
above by $n$; stop at the first $m$ with $r_{m} = r_{m+1}$ once the value
has held steady (a conservative certificate is to confirm it persists,
since the sequence cannot rise again). Because rank can strictly drop at
most $n$ times, the loop terminates after $O(n)$ genuine drops; with the
incremental product each step costs $O(n^\omega)$.

These algorithms are exercised numerically in the accompanying demo.

---

## 9. Applications

**Linear time-varying systems.** For a discrete LTV system
$x_{t+1} = A_t x_t$, the state-transition matrix from time $i$ to $k$ is
exactly $\operatorname{trans}(A, i, k)$. The concatenation law is the
semigroup property of state transition; rank antitonicity quantifies the
monotone loss of reachable dimension when the system is not invertible.

**Markov chains (formal analogy).** Replacing endomorphisms by
stochastic matrices, Theorem 4.1 is the Chapman–Kolmogorov equation;
rank monotonicity corresponds to the coarsening of the reachable support
structure for non-invertible kernels.

**Operator iteration and Fitting theory.** Theorem 6.1 reduces the study
of $g^{\,m}$ to the constant-stream transition map, so the rank decay
(Theorem 6.2) and stabilization (Theorem 7.5) recover the descending
iterate-image chain underlying the Fitting decomposition of a
finite-dimensional endomorphism.

**Numerical linear algebra.** Antitonicity gives a principled early-stop
criterion for computing the stable rank of long matrix products without
forming all of them or computing every rank to high precision.

---

## 10. Discussion

The methodological point of this development is that a well-chosen
*combinatorial* law can subsume a cluster of *analytic*-looking
inequalities. Once `transEndo_comp` is in hand, the rank statements are
each one application of a standard submultiplicativity fact; we never
re-prove a Sylvester rank inequality. This separation of concerns —
combinatorics of windows on one side, classical rank facts on the other
— is what keeps the file minimal and the proofs short.

Two boundary conventions do real work and are worth flagging. First,
defining $\operatorname{trans}(f, i, j) = \mathrm{id}$ for $j \le i$
makes the concatenation law hold without side conditions on the empty
leg; the case $j = k+1$ in Theorem 4.1 is exactly where this matters.
Second, recursing on the *upper* endpoint (rather than the lower) makes
`transEndo_succ_of_le` the natural step lemma and aligns the recursion
with the direction in which windows grow in the stabilization argument.

---

## 11. Future work

The natural next results, stated as conjectures continuing this cycle,
are:

1. **Sharp eventual-rank floor.** For a constant stream $f(n) = g$ over a
   finite-dimensional $V$, the eventual value of
   $\operatorname{rankSeq}(f, 0, \cdot)$ equals
   $\dim_K \big(\bigcap_m \operatorname{im}(g^{\,m})\big)$, the dimension
   of the Fitting (generalized) image.
2. **Stabilization by index $n$.** The window-from-zero rank sequence
   satisfies $\operatorname{rankSeq}(f, 0, m) = \operatorname{rankSeq}(f,
   0, n)$ for all $m \ge n = \dim_K V$; the stabilization index is
   bounded by the dimension.
3. **Sub-window superadditivity.** For $i \le j \le k$,
   $\operatorname{rankSeq}(f, i, k) \ge \operatorname{rankSeq}(f, i, j) +
   \operatorname{rankSeq}(f, j, k) - n$, the Frobenius/Sylvester lower
   bound complementing the upper bound of Corollary 5.4, obtained by
   applying the classical Sylvester inequality factor-by-factor through
   the concatenation law.
4. **Invertible streams preserve rank.** If every $f(n)$ is an
   automorphism then $\operatorname{rankSeq}(f, i, j) = n$ for all
   $i \le j$; conversely a single rank-deficient factor strictly lowers
   the eventual floor.

---

## 12. Conclusion

We have built a small, self-contained theory of transition
endomorphisms on a stream of linear self-maps. A single
Chapman–Kolmogorov concatenation law organizes the entire development:
rank monotonicity along nested windows, the identification of constant
streams with monoid powers, the rank decay of iterates, and — over a
finite-dimensional space — the eventual constancy of the transition-rank
sequence. The transition endomorphism thus serves as a reusable transfer
operator whose rank is automatically antitone along nested windows and
stabilizes in finite dimension.
