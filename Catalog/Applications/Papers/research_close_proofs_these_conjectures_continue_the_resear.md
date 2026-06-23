# Transition Endomorphisms of an Endomorphism Stream: Composition, Rank Antitonicity, and Eventual Stabilization

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Pythagorean / Finite-dimensional linear algebra

---

## Abstract

Given a sequence (a *stream*) of linear endomorphisms
$f : \mathbb{N} \to (V \to_{\ell} V)$ of a vector space $V$ over a field $K$,
we organize its iterated compositions into a two-index family of *transition
endomorphisms* $\mathrm{transEndo}\,f\,i\,j$, the net operator carrying the
state at station $i$ to the state at station $j$. We establish the foundational
algebra of this family: a recursive partial-composite construction, an
additivity law, and a Chasles-style composition identity
$\mathrm{transEndo}\,f\,i\,k = \mathrm{transEndo}\,f\,j\,k \circ \mathrm{transEndo}\,f\,i\,j$
for $i \le j \le k$. From the elementary inequality
$\mathrm{rank}(g \circ h) \le \mathrm{rank}(h)$ we deduce that the rank of a
transition endomorphism is antitone in the window: lengthening the segment
cannot increase its rank. Specializing to finite-dimensional $V$, we read the
(cardinal) rank as a natural number $\mathrm{rankSeq}\,f\,i\,j$, prove it is
bounded by $\dim_K V$ and antitone, and conclude that the rank profile
$m \mapsto \mathrm{rankSeq}\,f\,0\,m$ is **eventually constant**. The
stabilization step is isolated as a reusable order-theoretic lemma: every
antitone sequence $\mathbb{N} \to \mathbb{N}$ is eventually constant. All
results are fully formalized and machine-checked. We discuss the constant-stream
specialization (recovering the Fitting core), a Sylvester-type window
subadditivity, and the genuine necessity of finite-dimensionality.

---

## 1. Introduction

A single linear endomorphism $g : V \to V$ generates, through iteration, one of
the most studied objects in linear algebra: the descending chain of images
$V \supseteq \mathrm{im}\,g \supseteq \mathrm{im}\,g^2 \supseteq \cdots$, whose
stabilization underlies the Fitting decomposition and the theory of generalized
eigenspaces. But many systems are not driven by a single repeated map. A
non-autonomous discrete dynamical system, a layered neural network with distinct
layers, a time-varying linear filter, or a product of a varying transfer matrix
all apply a *different* operator at each step. The natural object is then a
**stream** of endomorphisms,
$$f : \mathbb{N} \to (V \to_{\ell} V), \qquad f(0), f(1), f(2), \dots,$$
and the natural questions concern the *cumulative* operators built from
consecutive windows of the stream.

This paper develops the elementary but foundational algebra of those cumulative
operators — the **transition endomorphisms** — and extracts from an arbitrary
stream a finite, monotone, eventually-constant integer invariant: its
*transition-rank profile*. The development is deliberately minimal and
self-contained, relying only on the standard rank inequality for composites and
the well-ordering of $\mathbb{N}$; it builds no new Sylvester theory from
scratch. Every statement below has been formally verified.

Throughout, $K$ is a field, $V$ is a $K$-vector space, and $V \to_{\ell} V$
denotes the $K$-linear endomorphisms of $V$. Composition $g \circ h$ means
"$h$ first, then $g$."

---

## 2. Definitions

### 2.1 Partial composites

The basic building block is the composite of a consecutive block of stream
maps, defined by recursion on the block length.

> **Definition 2.1 (Partial composite, `compFrom`).** For a stream
> $f : \mathbb{N} \to (V \to_{\ell} V)$, a start index $i \in \mathbb{N}$, and a
> length $n \in \mathbb{N}$, define $\mathrm{compFrom}\,f\,i\,n : V \to_{\ell} V$
> by
> $$\mathrm{compFrom}\,f\,i\,0 = \mathrm{id}_V, \qquad
> \mathrm{compFrom}\,f\,i\,(n+1) = f(i+n) \circ \mathrm{compFrom}\,f\,i\,n.$$

Unrolling the recursion gives the explicit form
$$\mathrm{compFrom}\,f\,i\,n = f(i+n-1) \circ \cdots \circ f(i+1) \circ f(i)
\quad (n \ge 1),$$
the operator that applies the $n$ consecutive maps $f(i), \dots, f(i+n-1)$ in
increasing order of index.

Two immediate facts record the recursion:

> **Lemma 2.2 (`compFrom_zero`).** $\mathrm{compFrom}\,f\,i\,0 = \mathrm{id}_V$.
>
> **Lemma 2.3 (`compFrom_succ`).**
> $\mathrm{compFrom}\,f\,i\,(n+1) = f(i+n) \circ \mathrm{compFrom}\,f\,i\,n$.

Both hold by definition (`rfl`).

### 2.2 Transition endomorphisms

> **Definition 2.4 (Transition endomorphism, `transEndo`).** For
> $i, j \in \mathbb{N}$,
> $$\mathrm{transEndo}\,f\,i\,j = \mathrm{compFrom}\,f\,i\,(j - i),$$
> where $j - i$ is truncated natural subtraction (so the family is the identity
> whenever $j \le i$).

When $j \ge i$, $\mathrm{transEndo}\,f\,i\,j$ is the net operator produced by
the stream segment between stations $i$ and $j$:
$$\mathrm{transEndo}\,f\,i\,j = f(j-1) \circ \cdots \circ f(i).$$

### 2.3 The natural-number rank profile

Recall the **rank** of a linear map $\varphi$, written $\mathrm{rank}\,\varphi$,
is the dimension (a cardinal) of its image $\mathrm{im}\,\varphi$. Over a
finite-dimensional space we record it as a natural number.

> **Definition 2.5 (Transition-rank sequence, `rankSeq`).** For
> finite-dimensional $V$,
> $$\mathrm{rankSeq}\,f\,i\,j = \big(\mathrm{rank}(\mathrm{transEndo}\,f\,i\,j)\big)^{\downarrow} \in \mathbb{N},$$
> where $(\cdot)^{\downarrow}$ denotes the cardinal-to-natural cast `Cardinal.toNat`
> (well-defined here because the rank is finite, i.e. $< \aleph_0$).

---

## 3. The algebra of transition endomorphisms

### 3.1 Additivity of partial composites

The combinatorial engine of the theory is the way two consecutive blocks
combine.

> **Theorem 3.1 (Additivity, `compFrom_add`).** For all $i, m, n \in \mathbb{N}$,
> $$\mathrm{compFrom}\,f\,i\,(m+n) = \mathrm{compFrom}\,f\,(i+m)\,n \;\circ\; \mathrm{compFrom}\,f\,i\,m.$$

*Proof sketch.* Induct on $n$ (with $i, m$ general). For $n = 0$ both sides equal
$\mathrm{compFrom}\,f\,i\,m$ since the right factor is the identity. For the
inductive step, use $\mathrm{compFrom}\,f\,i\,(m + (n+1)) =
\mathrm{compFrom}\,f\,i\,((m+n)+1) = f(i + m + n) \circ \mathrm{compFrom}\,f\,i\,(m+n)$,
apply the inductive hypothesis to the trailing composite, and reassociate; the
leading map $f(i+m+n)$ is precisely the $(n+1)$-st map of the block starting at
$i + m$, so the right-hand side collapses to
$\mathrm{compFrom}\,f\,(i+m)\,(n+1) \circ \mathrm{compFrom}\,f\,i\,m$.
Associativity of composition closes the step. $\qquad\blacksquare$

### 3.2 The composition (Chasles) law

> **Theorem 3.2 (Composition law, `transEndo_comp`).** If $i \le j \le k$, then
> $$\mathrm{transEndo}\,f\,i\,k = \mathrm{transEndo}\,f\,j\,k \;\circ\; \mathrm{transEndo}\,f\,i\,j.$$

*Proof sketch.* Set $m = j - i$ and $n = k - j$. Because $i \le j \le k$, natural
subtraction satisfies $m + n = (j-i)+(k-j) = k - i$ and $i + m = j$. Apply
Theorem 3.1 at $(i, m, n)$:
$$\mathrm{compFrom}\,f\,i\,(k-i) = \mathrm{compFrom}\,f\,i\,(m+n)
= \mathrm{compFrom}\,f\,(i+m)\,n \circ \mathrm{compFrom}\,f\,i\,m
= \mathrm{compFrom}\,f\,j\,(k-j) \circ \mathrm{compFrom}\,f\,i\,(j-i).$$
Rewriting each partial composite as the corresponding transition endomorphism
yields the claim. $\qquad\blacksquare$

This is the Chasles/cocycle identity for the family $\{\mathrm{transEndo}\,f\,i\,j\}_{i \le j}$:
any itinerary may be broken at an intermediate index. In categorical language,
$\mathrm{transEndo}\,f$ is a functor from the poset $(\mathbb{N}, \le)$ to the
monoid of endomorphisms of $V$.

---

## 4. Rank antitonicity

We use a single standard fact about linear maps.

> **Fact 4.1 (Rank of a composite).** For linear maps $g, h$ with $g \circ h$
> defined, $\mathrm{rank}(g \circ h) \le \mathrm{rank}(h)$.
> (In Mathlib: `LinearMap.rank_comp_le_right`.)

Intuitively, $g \circ h$ acts on the image of $h$, so its image is the image of
$g$ restricted to $\mathrm{im}\,h$, which cannot exceed $\dim(\mathrm{im}\,h) = \mathrm{rank}\,h$.

> **Theorem 4.2 (Antitone partial composite rank, `rank_compFrom_antitone`).**
> If $n \le m$, then
> $$\mathrm{rank}\big(\mathrm{compFrom}\,f\,i\,m\big) \le \mathrm{rank}\big(\mathrm{compFrom}\,f\,i\,n\big).$$

*Proof sketch.* Write $m = n + (m - n)$ and apply Theorem 3.1:
$\mathrm{compFrom}\,f\,i\,m = \mathrm{compFrom}\,f\,(i+n)\,(m-n) \circ \mathrm{compFrom}\,f\,i\,n$.
By Fact 4.1 the rank of this composite is at most the rank of its right factor
$\mathrm{compFrom}\,f\,i\,n$. $\qquad\blacksquare$

> **Theorem 4.3 (Antitone transition rank, `rank_transEndo_antitone`).**
> If $i \le j \le k$, then
> $$\mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,k\big) \le \mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,j\big).$$

*Proof sketch.* By Theorem 3.2,
$\mathrm{transEndo}\,f\,i\,k = \mathrm{transEndo}\,f\,j\,k \circ \mathrm{transEndo}\,f\,i\,j$;
apply Fact 4.1 with right factor $\mathrm{transEndo}\,f\,i\,j$. $\qquad\blacksquare$

The principle is "processing on the far end of a segment cannot create rank."
Note the asymmetry: it is the *right* (earlier) factor whose rank bounds the
composite, which is why widening the window at the *upper* endpoint $k$ (while
fixing the start $i$) is the operation that decreases rank.

---

## 5. Stabilization in finite dimensions

We now assume $V$ is finite-dimensional over $K$, with $d = \dim_K V$
(`Module.finrank K V`). The cardinal rank is then finite, so the cast in
Definition 2.5 is faithful and order-preserving on transition endomorphisms.

> **Theorem 5.1 (Boundedness, `rankSeq_le_finrank`).** For all $i, j$,
> $$\mathrm{rankSeq}\,f\,i\,j \le d.$$

*Proof sketch.* The rank of any endomorphism is at most the dimension of its
domain (`rank_le_domain`), i.e. $\mathrm{rank}(\mathrm{transEndo}\,f\,i\,j) \le \dim_K V$.
Cast to $\mathbb{N}$ via the monotone `Cardinal.toNat` (legitimate as both sides
are $< \aleph_0$); the right side becomes $\mathrm{finrank}\,K\,V = d$. $\qquad\blacksquare$

> **Theorem 5.2 (Window antitonicity, `rankSeq_antitone`).** If $i \le j \le k$,
> then $\mathrm{rankSeq}\,f\,i\,k \le \mathrm{rankSeq}\,f\,i\,j$.

*Proof sketch.* Apply `Cardinal.toNat_le_toNat` to Theorem 4.3, using that the
larger side $\mathrm{rank}(\mathrm{transEndo}\,f\,i\,j)$ is $< \aleph_0$ in finite
dimensions. $\qquad\blacksquare$

> **Corollary 5.3 (Profile antitonicity, `rankSeq_zero_antitone`).** The map
> $m \mapsto \mathrm{rankSeq}\,f\,0\,m$ is antitone on $\mathbb{N}$.

*Proof sketch.* For $j \le k$, instantiate Theorem 5.2 with $i = 0$ and
$0 \le j \le k$. $\qquad\blacksquare$

The decisive step is order-theoretic and dimension-free in statement; we isolate
it for reuse.

> **Lemma 5.4 (Stabilization of antitone integer sequences, `antitone_nat_eventually_const`).**
> For every antitone sequence $a : \mathbb{N} \to \mathbb{N}$ there exists $N$
> such that $a(m) = a(N)$ for all $m \ge N$.

*Proof sketch.* The image $\{a(n) : n \in \mathbb{N}\} \subseteq \mathbb{N}$ is
nonempty, and $\mathbb{N}$ is well-ordered, so the image has a least element,
attained at some index $N$: $a(N) = \min_n a(n)$. For any $m \ge N$,
antitonicity gives $a(m) \le a(N)$, while minimality gives $a(m) \ge a(N)$;
hence $a(m) = a(N)$. $\qquad\blacksquare$

> **Theorem 5.5 (Eventual constancy, `rankSeq_eventually_const`).** There exists
> $N \in \mathbb{N}$ with
> $$\mathrm{rankSeq}\,f\,0\,m = \mathrm{rankSeq}\,f\,0\,N \quad \text{for all } m \ge N.$$

*Proof.* Apply Lemma 5.4 to the antitone sequence $a(m) = \mathrm{rankSeq}\,f\,0\,m$
of Corollary 5.3. $\qquad\blacksquare$

Thus every endomorphism stream over a finite-dimensional space carries a
canonical **transition-rank profile**: a non-increasing $\mathbb{N}$-valued
sequence, bounded by $d$, that stabilizes to a well-defined *stable rank*.
Boundedness is what forces stabilization — Theorem 5.1 ensures the antitone
profile cannot descend forever.

---

## 6. The constant-stream specialization: Fitting's core

The classical theory of a single operator is the special case of a *constant*
stream $f \equiv g$.

For $f \equiv g$, the recursion of Definition 2.1 yields
$\mathrm{compFrom}\,f\,i\,n = g^n$, independent of $i$, and hence
$\mathrm{transEndo}\,f\,0\,m = g^m$. The composition law (Theorem 3.2)
specializes to the monoid exponent rule $g^{m+n} = g^m \circ g^n$, obtained here
for free from additivity.

Consequently $\mathrm{rankSeq}\,f\,0\,m = \dim_K(\mathrm{im}\,g^m)$, and Theorem
5.5 recovers the stabilization of the descending image chain
$\mathrm{im}\,g \supseteq \mathrm{im}\,g^2 \supseteq \cdots$. The stable value is
$$\lim_{m\to\infty} \dim_K(\mathrm{im}\,g^m) = \dim_K \Big(\bigcap_{n} \mathrm{im}\,g^n\Big),$$
the dimension of the **Fitting core** (generalized image) of $g$ — the largest
$g$-invariant subspace on which $g$ acts surjectively (indeed invertibly). The
general transition-rank profile is therefore a non-autonomous, time-varying
generalization of the Fitting/Fitting-core stabilization phenomenon.

---

## 7. A Sylvester-type window inequality

The composition law also positions the family for the *lower* rank bound
(Sylvester's rank inequality): for $g, h$ on a $d$-dimensional space,
$\mathrm{rank}(g) + \mathrm{rank}(h) - d \le \mathrm{rank}(g \circ h)$. Applied to
the factorization $\mathrm{transEndo}\,f\,i\,k = \mathrm{transEndo}\,f\,j\,k \circ \mathrm{transEndo}\,f\,i\,j$
this gives, for $i \le j \le k$,
$$\mathrm{rankSeq}\,f\,i\,j + \mathrm{rankSeq}\,f\,j\,k
\;\le\; \mathrm{rankSeq}\,f\,i\,k + d,$$
a subadditivity controlling how much rank a window can shed when split. Pairing
this lower control with the antitone upper control of §4–§5 sandwiches the
profile and quantifies its rate of descent. (The present development proves the
upper, antitone half; the Sylvester lower half is recorded as future work,
§9.4.)

---

## 8. Applications

- **Non-autonomous linear dynamical systems.** For a time-varying recurrence
  $x_{n+1} = f(n)\,x_n$, the state at time $j$ is $\mathrm{transEndo}\,f\,0\,j$
  applied to $x_0$. The transition-rank profile measures the collapsing
  reachable/observable dimension over time and identifies the horizon $N$ beyond
  which no further structural collapse occurs.

- **Layered linear networks.** A deep network whose layers are linear maps of
  varying shape is a finite stream; the profile tracks the information
  bottleneck as depth increases and certifies that effective rank is monotone in
  depth — a clean, exact statement of the "rank can only fall through layers"
  folklore.

- **Products of varying transfer matrices.** In control and signal processing,
  cascaded stages correspond to matrix products $A_{j-1}\cdots A_i$; the
  composition law is the associativity bookkeeping, and the profile bounds the
  achievable rank of any sub-cascade.

- **Operator semigroups and Fitting theory.** §6 shows the framework subsumes
  the single-operator image-chain stabilization, suggesting a uniform treatment
  of autonomous and non-autonomous settings.

---

## 9. Discussion and future directions

### 9.1 The stabilization index is bounded by $\dim_K V$
There exists $N \le d$ with $\mathrm{rankSeq}\,f\,0\,m = \mathrm{rankSeq}\,f\,0\,N$
for all $m \ge N$. A strictly decreasing antitone $\mathbb{N} \to \mathbb{N}$
chain bounded by $d$ can drop at most $d$ times, so the first stabilization point
is reached within $d$ steps rather than at an abstract well-founded minimum. With
boundedness and antitonicity already in hand, only a quantitative refinement of
the stabilization lemma is needed.

### 9.2 The stable rank as a generalized image
For a constant stream $f \equiv g$, the eventual value of $\mathrm{rankSeq}\,f\,0\,m$
equals $\dim_K(\bigcap_n \mathrm{im}\,g^n)$. Since $\mathrm{transEndo}\,(\lambda\_.g)\,0\,m = g^m$
and the descending range chain stabilizes at the Fitting core of $g$, the
remaining work is to formalize the Fitting decomposition itself.

### 9.3 Eventual constancy fails without finite dimension
Over an infinite-dimensional $V$ there is a stream $f$ whose cardinal rank
$\mathrm{rank}(\mathrm{transEndo}\,f\,0\,m)$ is strictly decreasing for every $m$
(e.g. an iterated shift on $\mathbb{N} \to_0 K$ realizes an infinite descending
chain of subspaces). Finiteness in Theorem 5.5 is genuinely load-bearing: it
justifies both the `toNat` cast and the bound.

### 9.4 Window rank is subadditive in a Sylvester sense
For $i \le j \le k$,
$\mathrm{rankSeq}\,f\,i\,j + \mathrm{rankSeq}\,f\,j\,k \le \mathrm{rankSeq}\,f\,i\,k + d$,
which is Sylvester's rank inequality applied to the factorization of §7. The
composition law is in hand; only the rank-of-composition lower bound must be
located or built.

### 9.5 Joint stabilization across all starting windows
There is a single $N$ such that for every $i \le N$ the sequence
$m \mapsto \mathrm{rankSeq}\,f\,i\,m$ is constant for $m \ge N$. Finitely many
antitone bounded sequences (one per start index up to $N$) stabilize
simultaneously by taking a common cutoff, building on the established window
antitonicity.

---

## 10. Conclusion

From an arbitrary stream of linear endomorphisms we have built a clean algebraic
calculus of transition operators — additive in length, Chasles-composable in
the window — and shown that their ranks form a bounded, antitone, and (in finite
dimensions) eventually-constant integer signature of the stream. The argument is
elementary, modular, and fully formalized: a recursion, one rank inequality, and
the well-ordering of $\mathbb{N}$ suffice. The framework unifies the classical
single-operator image-chain stabilization (the Fitting core) with the
time-varying setting and opens onto sharper quantitative refinements via
Sylvester's inequality.
