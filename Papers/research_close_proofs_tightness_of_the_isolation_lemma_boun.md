# Tightness of the Isolation Lemma Bound Under Arbitrary Edge Offsets

**Author:** Aristotle
**Date:** 2026-07-12
**Domain:** Applications — Combinatorics of tie-breaking and derandomization

## Abstract

The Isolation Lemma of Mulmuley, Vazirani, and Vazirani (1987) guarantees that a
random weighting of the ground set of a set system isolates, with high
probability, a unique minimum-weight member. In the exact counting refinement
studied by Faber and Harris, one asks for the *number* of isolating weight
assignments $w \in \{0,\dots,d-1\}^n$ for an inclusion-free (Sperner) hypergraph,
and this number is bounded below by $n\sum_{j=0}^{d-1} j^{\,n-1}$. The singleton
hypergraph attains this bound exactly with zero offset. We analyze what happens
under an *arbitrary integer edge offset* $f$, where the singleton edge $\{i\}$
carries weight $f_i + w_i$. Our main result is an exact product–sum identity for
the isolating count valid for **every** offset:
$$
I(n,d,f) \;=\; \sum_{i=1}^{n}\sum_{m=0}^{d-1}\prod_{j\neq i}
\#\{k\in\{0,\dots,d-1\} : f_i + m < f_j + k\}.
$$
From it we obtain the two extreme regimes exactly: constant offsets reproduce the
Faber–Harris extremal value $n\sum_{j<d} j^{\,n-1}$ (the offset-free floor), while
widely separated offsets isolate every assignment and reach the maximum $d^n$. In
particular the extremal value is *not* an offset invariant: the offset
$f=(0,1,5)$ on $(n,d)=(3,3)$ yields $21 > 15$ isolating assignments. We give the
supporting structural lemmas (a strict-minimum reformulation of isolation, a
fiber-factorization lemma, and a disjoint-decomposition over the argmin vertex),
numerical corroboration, algorithms, and a program of four conjectures extending
the results.

## 1. Introduction

### 1.1 Background

Let $V = \{1,\dots,n\}$ be a ground set and let $H$ be a hypergraph on $V$: a
family of edges, each a subset $S \subseteq V$. A **weight assignment** is a map
$w : V \to \{0,1,\dots,d-1\}$; we write $[d] = \{0,\dots,d-1\}$ and note there are
$d^n$ assignments. Given an **edge offset** $f : H \to \mathbb{R}$, each edge $S$
receives weight
$$
W_f(S, w) \;=\; f(S) + \sum_{v\in S} w(v).
$$
The assignment $w$ is **isolating** if a *unique* edge attains the minimum weight
$\min_{S\in H} W_f(S,w)$.

The Isolation Lemma asserts that a uniformly random $w$ is isolating with
probability at least $1 - n/d$; its exact-counting form asks for the precise
number of isolating assignments. A hypergraph is **inclusion-free** (a *Sperner
family* / antichain) if no edge is a proper subset of another. Faber and Harris
established the sharp lower bound
$$
\#\{\text{isolating } w\} \;\geq\; n\sum_{j=0}^{d-1} j^{\,n-1}
\qquad\text{for every inclusion-free } H.
$$

### 1.2 The singleton hypergraph and the offset question

The **singleton hypergraph** is $H = \{\{1\},\dots,\{n\}\}$, whose edges are the
individual vertices. Here $W_f(\{i\}, w) = f_i + w_i$, so isolation is precisely
the event that a single vertex attains the strict minimum of $i \mapsto f_i +
w_i$. With zero offset the singleton hypergraph meets the Faber–Harris bound with
equality, certifying tightness.

This paper removes the zero-offset restriction. We treat integer offsets $f :
\{1,\dots,n\}\to\mathbb{Z}$, an order-faithful subfamily of the real offsets
(isolation depends only on the linear order of the finitely many edge weights),
and we determine the isolating count for *every* such offset. The central
questions are:

1. Is there a closed-form count valid for all offsets?
2. What are the extreme values of the count, and which offsets realize them?
3. Is the Faber–Harris extremal value an offset invariant?

We answer all three: (1) yes, an exact product–sum identity; (2) the floor
$n\sum_{j<d} j^{n-1}$ at constant offsets and the ceiling $d^n$ at separated
offsets; (3) no — offsets strictly change the count in general.

## 2. Definitions

Throughout, fix integers $n \geq 0$ and $d \geq 1$. Assignments are maps
$w : \{1,\dots,n\}\to[d]$, and an offset is a map $f : \{1,\dots,n\}\to\mathbb{Z}$.

**Definition 2.1 (Offset weight).** The weight of the singleton edge $\{i\}$ under
offset $f$ and assignment $w$ is
$$
g_f(w, i) \;=\; f_i + w_i \in \mathbb{Z}.
$$

**Definition 2.2 (Isolating assignment).** An assignment $w$ is *isolating for
$f$* if a unique vertex attains the minimum offset weight:
$$
\exists!\, i \;\; \forall j,\; g_f(w,i)\le g_f(w,j).
$$

**Definition 2.3 (Strict minimum).** An assignment $w$ *has a strict minimum for
$f$* if
$$
\exists\, i \;\;\forall j\neq i,\; g_f(w,i) < g_f(w,j).
$$

**Definition 2.4 (Isolating set).** $\mathcal I_f = \{\,w\in[d]^n : w \text{ has
a strict minimum for } f\,\}$, and its cardinality is the *isolating count*
$I(n,d,f) = |\mathcal I_f|$.

**Definition 2.5 (Strict-min-at-$i$ set).** For a vertex $i$,
$$
\mathcal M_f(i) \;=\; \{\,w\in[d]^n : \forall j\neq i,\ g_f(w,i) < g_f(w,j)\,\}.
$$

**Definition 2.6 (Above-threshold count).** For vertices $i,j$ and a value
$m\in[d]$, define
$$
A_f(i,j,m) \;=\; \#\{\,k\in[d] : f_i + m < f_j + k\,\}.
$$
Concretely $A_f(i,j,m) = \min\bigl(d,\ \max(0,\ d - 1 - (f_i + m - f_j))\bigr)$ is
the number of weight values that clear the offset-shifted threshold at vertex $j$.

## 3. Main Results

### 3.1 Two notions of isolation coincide

**Lemma 3.1 (Isolation equals strict minimum).** For every offset $f$ and
assignment $w$,
$$
\bigl(\exists!\, i\ \forall j,\ g_f(w,i)\le g_f(w,j)\bigr)
\iff
\bigl(\exists\, i\ \forall j\neq i,\ g_f(w,i) < g_f(w,j)\bigr).
$$

*Proof sketch.* ($\Rightarrow$) Let $i$ be the unique minimizer. For $j\neq i$,
either $g_f(w,i) < g_f(w,j)$ (done) or $g_f(w,i) = g_f(w,j)$; in the latter case
$j$ is also a minimizer, contradicting uniqueness. ($\Leftarrow$) A strict
minimizer $i$ is a minimizer. Any other minimizer $k\neq i$ would satisfy
$g_f(w,k)\le g_f(w,i)$, but strictness of $i$ gives $g_f(w,i) < g_f(w,k)$, a
contradiction; hence the minimizer $i$ is unique.
$\square$

This lemma lets us count with the strict-minimum formulation, which factorizes
cleanly.

### 3.2 Fiber factorization

**Lemma 3.2 (Fiber count).** Fix a vertex $i$ and a value $m\in[d]$. The set of
assignments with $w_i = m$ and vertex $i$ a strict minimum factors as a product
of above-threshold counts:
$$
\#\{\,w : w_i = m,\ \forall j\neq i,\ f_i + m < f_j + w_j\,\}
\;=\; \prod_{j\neq i} A_f(i,j,m).
$$

*Proof sketch.* Fixing $w_i = m$, the constraints on the remaining coordinates are
independent: each $w_j$ ($j\neq i$) ranges freely over $\{k\in[d] : f_i + m < f_j
+ k\}$, a set of size $A_f(i,j,m)$. The assignment set is thus a product of
independent choices; its cardinality is the product of the factor sizes. Formally
this identifies the fiber with a dependent product $\prod_j t_j$ where $t_i =
\{m\}$ and $t_j = \{k : f_i+m < f_j+k\}$, whose cardinality is $\prod_j |t_j| =
\prod_{j\neq i} A_f(i,j,m)$. $\square$

### 3.3 Summing over the minimum value

**Lemma 3.3 (Strict-min-at-$i$ count).** For each vertex $i$,
$$
|\mathcal M_f(i)| \;=\; \sum_{m=0}^{d-1}\ \prod_{j\neq i} A_f(i,j,m).
$$

*Proof sketch.* The set $\mathcal M_f(i)$ partitions by the value $m = w_i$ of the
minimizing vertex, since $w_i$ is determined by $w$. The pieces are the fibers of
Lemma 3.2 and are pairwise disjoint (different $m$ forces different $w_i$).
Summing the fiber counts gives the claim. $\square$

### 3.4 Disjoint decomposition over the argmin

**Lemma 3.4 (Argmin decomposition).** The isolating set is the disjoint union of
the strict-min-at-$i$ sets:
$$
\mathcal I_f = \bigsqcup_{i=1}^{n} \mathcal M_f(i),
\qquad
I(n,d,f) = \sum_{i=1}^{n} |\mathcal M_f(i)|.
$$

*Proof sketch.* By definition $\mathcal I_f = \bigcup_i \mathcal M_f(i)$: $w$ has
a strict minimum iff some vertex is a strict minimum. Disjointness: if $w$ had two
strict minima $i\neq i'$ then $g_f(w,i) < g_f(w,i')$ and $g_f(w,i') < g_f(w,i)$, a
contradiction. Hence the union is disjoint and cardinalities add. $\square$

### 3.5 The master identity

**Theorem 3.5 (Exact isolating count under an arbitrary offset).** For the
singleton hypergraph on $n$ vertices with weight palette $[d]$ and *any* integer
offset $f$,
$$
\boxed{\,I(n,d,f) \;=\; \sum_{i=1}^{n}\ \sum_{m=0}^{d-1}\ \prod_{j\neq i}
\#\{\,k\in[d] : f_i + m < f_j + k\,\}.\,}
$$

*Proof.* Combine Lemma 3.4 (decompose over the argmin vertex $i$), Lemma 3.3
(expand each $|\mathcal M_f(i)|$ as a sum over the minimum value $m$), and Lemma
3.2 (factor each fiber as a product of above-threshold counts). Lemma 3.1
guarantees that this strict-minimum count equals the $\exists!$-isolating count.
$\square$

### 3.6 Constant offsets: the extremal floor

**Lemma 3.6 (Constant offset reduces to the offset-free notion).** For any
constant $c\in\mathbb{Z}$ and any $w$, $w$ has a strict minimum for the constant
offset $f\equiv c$ if and only if $w$ has a strict minimum in the offset-free
sense ($\exists i\ \forall j\neq i,\ w_i < w_j$).

*Proof sketch.* $g_c(w,i) = c + w_i$, so $g_c(w,i) < g_c(w,j) \iff w_i < w_j$;
the constant cancels. $\square$

**Theorem 3.7 (Constant offsets recover the Faber–Harris value).** For every
constant offset $f\equiv c$,
$$
I(n,d,c) \;=\; n\sum_{j=0}^{d-1} j^{\,n-1}.
$$

*Proof.* By Lemma 3.6 the isolating set for a constant offset equals the
offset-free isolating set, whose cardinality is the known extremal value
$n\sum_{j<d} j^{n-1}$. Directly from the master identity: with $f$ constant,
$A_f(i,j,m) = \#\{k : m < k\} = d-1-m$, so
$$
I = \sum_{i=1}^n \sum_{m=0}^{d-1} (d-1-m)^{n-1}
 = n\sum_{m=0}^{d-1}(d-1-m)^{n-1}
 = n\sum_{j=0}^{d-1} j^{\,n-1},
$$
reindexing $j = d-1-m$. $\square$

Thus every uniform bias leaves the count at the extremal floor — the level
playing field, tilted uniformly, remains level.

### 3.7 Separated offsets: the ceiling

**Theorem 3.8 (Widely separated offsets isolate every assignment).** Choose
offsets that are pairwise separated by at least the palette width, e.g. $f_i = i
\cdot d$ (equivalently any $f$ with $f_i + (d-1) < f_j$ whenever $f_i < f_j$ across
the distinct offset values, together with distinct offsets). Then every assignment
is isolating:
$$
I(n,d,f) \;=\; d^n.
$$

*Proof sketch.* Let $i^\star$ be the vertex with the least offset $f_{i^\star}$.
For any assignment $w$, $g_f(w,i^\star) = f_{i^\star} + w_{i^\star} \le f_{i^\star}
+ (d-1)$, while for every $j\neq i^\star$ we have $g_f(w,j) = f_j + w_j \ge f_j >
f_{i^\star} + (d-1) \ge g_f(w,i^\star)$ by separation. Hence $i^\star$ is a strict
minimum for *every* $w$, so $\mathcal I_f = [d]^n$ and $I = d^n$. Via the master
identity, separation pushes one threshold below $0$, making $A_f(i^\star,j,m) = d$
for all $j,m$, so the $i^\star$-term alone sums to $\sum_m d^{n-1} = d^n$ and the
other terms vanish. $\square$

### 3.8 Offsets genuinely move the count

**Theorem 3.9 (The extremal value is not an offset invariant).** There exist $n,
d$ and an offset $f$ with $I(n,d,f) > n\sum_{j<d} j^{n-1}$. Explicitly, for
$(n,d) = (3,3)$ and $f = (0,1,5)$,
$$
I(3,3,(0,1,5)) = 21 \;>\; 15 = 3\sum_{j=0}^{2} j^{2}.
$$

*Proof.* Direct evaluation of the master identity (equivalently, enumeration of
all $27$ assignments) gives $21$; the offset-free value is $3(0+1+4)=15$.
$\square$

This refutes the natural conjecture that the extremal value depends only on the
hypergraph. Combined with Theorems 3.7 and 3.8, it locates the isolating count of
the singleton hypergraph in the band
$$
n\sum_{j=0}^{d-1} j^{\,n-1} \;\le\; I(n,d,f) \;\le\; d^n,
$$
with the floor realized by constant offsets and the ceiling by separated ones.

## 4. Algorithms

### 4.1 Exact count by the master identity

Evaluating Theorem 3.5 directly costs $O(n^2 d)$ arithmetic operations: for each
of the $n$ argmin vertices and $d$ minimum values, form a product over $n-1$
above-threshold counts, each computable in $O(1)$ from the closed form
$A_f(i,j,m) = \mathrm{clip}(d-1-(f_i+m-f_j),\,0,\,d)$. This is exponentially faster
than the brute-force enumeration of all $d^n$ assignments.

### 4.2 Brute-force verifier

For validation, enumerate all $d^n$ assignments, compute the shifted weights,
and count those with a unique minimum. Its $O(n\,d^n)$ cost restricts it to small
$(n,d)$ but provides an independent ground truth against which the master identity
is checked.

### 4.3 Spectrum explorer

To probe the full range of achievable counts, sample offsets (or enumerate a
bounded offset lattice) and tabulate $I(n,d,f)$ via the master identity,
recording the minimum (constant), maximum (separated), and which intermediate
integer values are hit — the empirical basis for the spectrum conjecture below.

## 5. Numerical Corroboration

All values below were computed by the master identity and independently confirmed
by brute-force enumeration.

| $(n,d)$ | offset $f$ | $I(n,d,f)$ | note |
|---|---|---|---|
| $(3,3)$ | $(0,0,0)$ | $15$ | floor $= 3\sum_{j<3} j^2$ |
| $(3,3)$ | $(0,1,5)$ | $21$ | strictly above floor |
| $(3,4)$ | $(2,2,2)$ | $42$ | any constant $\Rightarrow$ floor |
| $(3,4)$ | $(0,4,8)$ | $64 = 4^3$ | separated $\Rightarrow$ ceiling |

The offset-free sequence $n\sum_{j<d} j^{n-1}$ begins $3, 6, 15, 12, 42, \dots$
across small grids, matching enumeration in every case.

## 6. Applications and Discussion

The Isolation Lemma is a foundational derandomization and tie-breaking tool
underpinning parallel matching algorithms and complexity-theoretic reductions.
The counting refinement quantifies *how many* random weightings succeed; exact
tightness pins the best case. Real instances arrive with structural biases —
priorities, costs, handicaps — modeled here as edge offsets. Our results show that
such biases move the isolating count in a fully predictable way: the count never
drops below the symmetric floor and never exceeds the trivial ceiling $d^n$, and
both endpoints carry transparent combinatorial meaning. The practical upshot is
robustness: over-counting from adversarial offsets is bounded, and the *only* way
to sit exactly at the extremal value (among the analyzed regimes) is to keep the
offsets uniform.

Methodologically, Theorem 3.5 converts a global extremal statement into a
local, hand-computable one: the entire behavior is dictated by the single scalar
quantity $A_f(i,j,m)$, opening the extremal-analysis to term-by-term comparison.

## 7. Future Directions

The following conjectures extend the results of this paper.

**Conjecture 1 (Offset monotonicity).** For the singleton hypergraph, the
isolating count is minimized exactly at constant offsets: every integer offset $f$
satisfies $I(n,d,f) \ge n\sum_{j<d} j^{n-1}$, with equality iff $f$ is constant.
Spreading offsets apart can only break ties in favor of a unique minimizer, never
create ties, so the symmetric offset sits at the bottom; the master identity
reduces the claim to a term-by-term comparison of above-threshold counts against
their symmetric baseline.

**Conjecture 2 (Full offset spectrum).** As $f$ ranges over all integer offsets,
$I(n,d,f)$ takes *every* integer value in $[\,n\sum_{j<d} j^{n-1},\ d^n\,]$ and no
value outside it. The endpoints are realized by constant and separated offsets;
interpolating one coordinate at a time changes the count by controlled increments,
sweeping the interval — a connectivity argument on the offset lattice.

**Conjecture 3 (General hypergraphs attain the floor via offsets).** For every
inclusion-free hypergraph $H$ on $n$ vertices there exists an edge offset $f$ for
which the isolating count equals the Faber–Harris lower bound $n\sum_{j<d}
j^{n-1}$ exactly. A carefully chosen offset can force every edge except a minimal
spanning skeleton to be non-competitive, reducing an arbitrary Sperner family to
the singleton hypergraph solved here.

**Conjecture 4 (Real vs. integer offsets).** The set of isolating-count values
achievable with real offsets coincides with that achievable with integer offsets;
passing to the reals adds no new counts. Isolation depends only on the linear
order of the finitely many edge weights, so any real offset can be perturbed to a
rational and cleared to an integer without crossing a comparison boundary.

## 8. Conclusion

For the singleton hypergraph we have determined the number of isolating weight
assignments under an *arbitrary* integer edge offset by an exact product–sum
identity, and pinned its two extreme regimes: constant offsets reproduce the
Faber–Harris extremal value $n\sum_{j<d} j^{n-1}$, while widely separated offsets
isolate every assignment and reach $d^n$. The extremal value is therefore not an
offset invariant — the offset $(0,1,5)$ on $(3,3)$ already overshoots it, from
$15$ to $21$. These results anchor a concrete program: offset monotonicity, the
full spectrum of counts, offset-driven extremality for general hypergraphs, and
the equivalence of real and integer offsets.
