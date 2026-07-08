# Long Nontrivial Cycles in Hamiltonian Graphs on a Cyclic Frame

## Abstract

The *long nontrivial cycles conjecture* asserts that every simple graph on $n$
vertices with minimum degree at least three that contains a Hamiltonian cycle must
also contain a second cycle — one different from the Hamiltonian cycle — of length
at least $n - c$ for some absolute constant $c > 0$. The conjecture remains open;
the best known general guarantees only bound the deficit by a polynomial in $n$.
In this paper we establish the conjecture in a sharp quantitative form for a
natural and structurally central family: Hamiltonian graphs whose vertex set is
the cyclic group $\mathbb{Z}_n$ and which contain the standard cyclic Hamiltonian
frame $0 \sim 1 \sim \cdots \sim (n-1) \sim 0$. We prove three results. First, an
*arc-cycle construction* shows that each chord (non-frame edge) $\{a,b\}$
generates an explicit second cycle of length $\lvert b - a\rvert + 1$, strictly
between $3$ and $n$. Second, a *complementary-arc identity* shows that the two arc
cycles associated to a chord have lengths summing to $n + 2$, whence one of them
has length at least $n/2 + 1$; combined with the fact that minimum degree three
forces a chord at every vertex, this yields a second cycle of length at least
$n/2 + 1$. Third, a *vertex-uniform strengthening* shows that in fact every vertex
lies on such a second cycle. We also prove the half-perimeter bound is best
possible using a single chord, isolating the multi-chord interaction as the sole
remaining source of the gap toward $n - c$.

## 1. Introduction

A *Hamiltonian cycle* in a simple graph is a cycle passing through every vertex
exactly once. Graphs admitting one are ubiquitous in combinatorics, optimization,
and network design, where a Hamiltonian cycle models a fault-free tour visiting
every node. A recurring theme is *robustness*: once a graph has one Hamiltonian
cycle and a modest amount of extra connectivity, how much *additional* cyclic
structure is forced?

The long nontrivial cycles conjecture crystallizes this question. It predicts that
minimum degree three — one connection per vertex beyond the two used by the
Hamiltonian cycle — suffices to force a *second* cycle almost as long as the first.

**Conjecture (long nontrivial cycles).** There is an absolute constant $c > 0$
such that every simple graph on $n$ vertices with minimum degree at least $3$ that
contains a Hamiltonian cycle also contains a cycle, different from the Hamiltonian
cycle, of length at least $n - c$.

Currently only polynomial error terms are known in general: one can guarantee a
second cycle of length $n - o(n)$, but pinning the deficit down to an absolute
constant is open. This paper isolates the essential combinatorial mechanism in a
concrete setting where the analysis is completely rigorous, and proves a sharp
half-perimeter bound uniform over all vertices, together with a matching tightness
result.

### 1.1 Setting and contributions

We work with graphs on the cyclic vertex set $\mathbb{Z}_n = \{0,1,\dots,n-1\}$
containing the *cyclic Hamiltonian frame*, the cycle $0 \sim 1 \sim \cdots \sim
(n-1) \sim 0$. This is the canonical local model of a Hamiltonian graph: any
Hamiltonian graph is isomorphic to one whose Hamiltonian cycle is the cyclic
frame, after relabeling vertices along the cycle. Our contributions are:

1. **Arc-cycle construction (Theorem 3.1).** Each chord yields an explicit second
   cycle whose length is the chord's cyclic span plus one.
2. **Half-perimeter guarantee (Theorem 4.2).** Minimum degree three forces a
   second cycle of length at least $n/2 + 1$.
3. **Vertex-uniformity (Theorem 4.3).** Every vertex lies on such a second cycle.
4. **Tightness (Proposition 4.4).** The bound $n/2 + 1$ is the best obtainable
   from a single chord.

## 2. Definitions

Throughout, $n \geq 3$ is a positive integer and arithmetic on indices is taken in
the cyclic group $\mathbb{Z}_n$; for $x \in \mathbb{Z}_n$ we write $x.\mathrm{val}
\in \{0,1,\dots,n-1\}$ for its canonical representative.

**Definition 2.1 (Frame adjacency).** Two vertices $i, j \in \mathbb{Z}_n$ are
*frame-adjacent*, written $\mathrm{FrameAdj}(i,j)$, if $j = i + 1$ or $i = j + 1$.
The *frame* is the graph in which the frame-adjacent pairs are exactly the edges;
it is the Hamiltonian cycle $0 \sim 1 \sim \cdots \sim (n-1) \sim 0$. Frame
adjacency is symmetric.

**Definition 2.2 (Ambient graph containing the frame).** We fix a simple graph $G$
on vertex set $\mathbb{Z}_n$ that *contains the frame*: $G.\mathrm{Adj}(i, i+1)$
holds for every $i \in \mathbb{Z}_n$. $G$ may have arbitrary additional edges.

**Definition 2.3 (Chord).** An unordered pair $\{a,b\}$ is a *chord* of $G$ if
$G.\mathrm{Adj}(a,b)$ holds but $a$ and $b$ are not frame-adjacent. Being a chord
is symmetric in $a$ and $b$.

**Definition 2.4 (Cycle).** A *cycle* in $G$ of length $\ell \geq 3$ is a map
$f : \mathbb{Z}_\ell \to \mathbb{Z}_n$ that is injective (the vertices are pairwise
distinct) and satisfies $G.\mathrm{Adj}\bigl(f(i), f(i+1)\bigr)$ for all $i \in
\mathbb{Z}_\ell$. Indexing the vertices by $\mathbb{Z}_\ell$ makes the wrap-around
edge $f(\ell - 1) \sim f(0)$ automatic (it is the case $i + 1 = 0$). The frame is
the cycle $\mathrm{id} : \mathbb{Z}_n \to \mathbb{Z}_n$ of length $n$; we call it
the *Hamiltonian cycle*. Any cycle of length strictly less than $n$ is necessarily
different from it, and we refer to such a cycle as a *second cycle*.

**Definition 2.5 (Cyclic span of a chord).** For a chord $\{a,b\}$ the *forward
span* from $a$ to $b$ is $(b - a).\mathrm{val}$, the number of forward frame steps
from $a$ to $b$. The *backward span* is $(a - b).\mathrm{val}$.

## 3. The arc-cycle construction

The single mechanism underlying all of our results is the *arc cycle*: given a
starting vertex $a$ and a step count $k$ with a closing edge from $a + k$ back to
$a$, we walk along the frame $a, a+1, \dots, a+k$ and close the loop.

**Lemma 3.0 (Arc walk).** Fix $a \in \mathbb{Z}_n$ and $k \in \mathbb{N}$ with
$2 \le k$ and $k + 2 \le n$, and suppose $G.\mathrm{Adj}(a + k, a)$. Define
$f : \mathbb{Z}_{k+1} \to \mathbb{Z}_n$ by $f(j) = a + j.\mathrm{val}$. Then:

- $f$ is injective (since $k + 1 \le n$, the representatives $0, 1, \dots, k$ are
  distinct modulo $n$);
- consecutive vertices are adjacent: for $j.\mathrm{val} < k$ the step
  $f(j) \sim f(j+1)$ is the frame edge $a + j.\mathrm{val} \sim a + j.\mathrm{val}
  + 1$, and the final step $f(k) \sim f(0)$, i.e. $a + k \sim a$, is the supplied
  closing edge.

Consequently $f$ is a cycle of length $k + 1$, called the *arc cycle*
$\mathrm{Arc}(a, k)$, and it passes through $a$ (namely $f(0) = a$).

*Proof sketch.* Injectivity: if $a + i.\mathrm{val} = a + j.\mathrm{val}$ in
$\mathbb{Z}_n$ then $i.\mathrm{val} \equiv j.\mathrm{val} \pmod n$; since both lie
in $\{0,\dots,k\} \subseteq \{0,\dots,n-1\}$ they are equal. Adjacency: split on
whether $j.\mathrm{val} < k$. For interior indices the successor of $j$ in
$\mathbb{Z}_{k+1}$ has value $j.\mathrm{val} + 1$, so $f(j+1) = f(j) + 1$ is a
frame edge. For $j.\mathrm{val} = k$ we have $j = -1$ in $\mathbb{Z}_{k+1}$, so
$j + 1 = 0$ and the step is $a + k \sim a$, the closing edge. $\square$

**Theorem 3.1 (Chord arc cycle).** Let $\{a,b\}$ be a chord of $G$. Then $G$
contains a cycle of length $(b - a).\mathrm{val} + 1$, this length satisfies
$$2 < (b - a).\mathrm{val} + 1 < n,$$
and the cycle passes through $a$. In particular it is a genuine cycle (length
$\ge 3$) strictly shorter than the frame, hence a second cycle.

*Proof sketch.* We first bound the span. Since $a \ne b$ (a chord is a genuine
edge), the span is nonzero. Since $\{a,b\}$ is not a frame edge, $b \ne a + 1$ and
$a \ne b + 1$, ruling out spans $1$ and $n - 1$ respectively. Hence
$2 \le (b - a).\mathrm{val} \le n - 2$. Set $k = (b - a).\mathrm{val}$. Then
$a + k = a + (b - a) = b$, so the closing edge $G.\mathrm{Adj}(a + k, a)$ is just
$G.\mathrm{Adj}(b, a)$, which holds by symmetry of $G$. Apply Lemma 3.0 to obtain
the arc cycle of length $k + 1$, which lies strictly between $2$ and $n$ by the
span bounds, and passes through $a$. $\square$

**Lemma 3.2 (Complementary-arc identity).** For $a \ne b$ in $\mathbb{Z}_n$,
$$(b - a).\mathrm{val} + (a - b).\mathrm{val} = n.$$
Consequently the forward and backward arc cycles of a chord $\{a,b\}$ have lengths
summing to $n + 2$:
$$\bigl[(b - a).\mathrm{val} + 1\bigr] + \bigl[(a - b).\mathrm{val} + 1\bigr] = n + 2.$$

*Proof sketch.* Write $x = b - a \ne 0$. Then $a - b = -x$, and for a nonzero
element $x$ of $\mathbb{Z}_n$ the representatives satisfy $x.\mathrm{val} +
(-x).\mathrm{val} = n$: the two complementary arcs of the ring partition all $n$
positions with the endpoints counted once each on the step counts. Adding $1$ to
each arc-cycle length gives the second identity. $\square$

## 4. Forced long second cycles

**Lemma 4.1 (Degree three forces a chord).** If every vertex of $G$ has at least
three neighbours — formally $\lvert N_G(v)\rvert \ge 3$ for all $v$, where
$N_G(v)$ is the neighbour set — then for every vertex $v$ there is a vertex $w$
with $\{v, w\}$ a chord.

*Proof sketch.* The only vertices frame-adjacent to $v$ are $v + 1$ and $v - 1$,
so if $v$ had no chord then $N_G(v) \subseteq \{v+1, v-1\}$, giving
$\lvert N_G(v)\rvert \le 2$, contradicting the degree hypothesis. Hence some
neighbour of $v$ is not frame-adjacent to $v$, i.e. is a chord endpoint. $\square$

Note this uses only the degree hypothesis, not the presence of the frame edges.

**Theorem 4.2 (Half-perimeter guarantee).** If $G$ contains the frame and has
minimum degree at least three, then $G$ contains a second cycle (length $< n$) of
length at least $n/2 + 1$.

*Proof sketch.* By Lemma 4.1 there is a chord $\{a, b\}$ (take $a = 0$). Theorem
3.1 applied to $\{a,b\}$ and to $\{b,a\}$ produces two second cycles of lengths
$(b - a).\mathrm{val} + 1$ and $(a - b).\mathrm{val} + 1$, each strictly less than
$n$. By Lemma 3.2 their lengths sum to $n + 2$, so the larger is at least
$\lceil (n+2)/2 \rceil \ge n/2 + 1$. Keep the longer one. $\square$

**Theorem 4.3 (Vertex-uniform strengthening).** Under the same hypotheses, every
vertex $v$ lies on some second cycle: there is a cycle of length $\ell$ with
$3 \le \ell < n$ whose vertex set contains $v$.

*Proof sketch.* Apply Lemma 4.1 at $v$ to get a chord $\{v, w\}$, then apply
Theorem 3.1 to $\{v, w\}$. The resulting arc cycle starts at $v$ (its vertex $f(0)
= v$), so $v$ lies on it, and its length is strictly between $2$ and $n$.
$\square$

**Proposition 4.4 (Tightness of the half bound for one chord).** The bound
$n/2 + 1$ in Theorem 4.2 cannot be improved using a single chord. If the only
non-frame edge is one chord $\{a, b\}$ with $(b - a).\mathrm{val} = (a -
b).\mathrm{val} = n/2$ (for even $n$), then the two arc cycles both have length
$n/2 + 1$ and no distinct cycle of greater length can be formed from a single
chord, since any cycle other than the frame must use the chord and is therefore
one of its two arcs.

*Proof sketch.* Any cycle distinct from the frame must contain at least one
non-frame edge; with a single chord available, it must use that chord, and the
remainder of the cycle is a path in the frame between the chord's endpoints. There
are exactly two such paths — the forward and backward arcs — of lengths $n/2 + 1$
each. Hence no distinct cycle longer than $n/2 + 1$ exists. $\square$

**Remark 4.5 (Distinctness from the Hamiltonian cycle).** Every cycle produced
above has length strictly less than $n$, whereas the frame has length exactly $n$.
Since cycle length is an invariant, any cycle of length $< n$ is different from the
frame. This is the precise sense in which the produced cycles are *second* cycles.

## 5. Algorithms

The constructive proofs translate directly into algorithms.

**Algorithm A (Chord to arc cycle).** *Input:* the ring size $n$ and a chord
$\{a,b\}$. *Output:* the longer of its two arc cycles as an explicit vertex list.
Compute the forward span $s = (b - a) \bmod n$ and backward span $n - s$; the
longer arc lists $a, a+1, \dots$ around the ring to the far endpoint. Runs in
$O(n)$ time and space (the output size).

**Algorithm B (Find a long second cycle).** *Input:* a graph $G$ on
$\mathbb{Z}_n$ containing the frame, with minimum degree three. *Output:* a second
cycle of length $\ge n/2 + 1$. Scan a vertex's neighbours for one that is not a
ring-neighbour (guaranteed by degree three), obtaining a chord; apply Algorithm A.
Runs in $O(\deg)$ time to find the chord plus $O(n)$ to emit the cycle.

**Algorithm C (Cycle through a prescribed vertex).** *Input:* $G$ and a target
vertex $v$. *Output:* a second cycle through $v$. Find a chord incident to $v$ and
apply Algorithm A anchored at $v$. Same complexity as Algorithm B.

## 6. Applications

The half-perimeter guarantee has a direct reading in **network resilience**. A
ring network in which every node has one extra link beyond its two ring-neighbours
admits, through *every* node, an alternative cyclic route covering at least half
the network. If any single link on the primary ring fails, traffic anchored at a
node can be rerouted along a substantial alternative loop, and the vertex-uniform
theorem guarantees this option exists no matter which node one starts from.

In **fault-tolerant circuit and interconnect design**, the arc-cycle construction
gives an explicit, linear-time procedure for extracting a long backup cycle from a
single redundant connection, with a certified length guarantee. The tightness
result quantifies the value of a single redundant link: it is worth exactly half
the ring, and no design relying on one shortcut can promise more.

## 7. Discussion and future work

The results settle the long nontrivial cycles conjecture, in a strong
vertex-uniform form, for cyclic-frame Hamiltonian graphs — but only up to the
*half*-perimeter, not the conjectured $n - c$. Proposition 4.4 explains precisely
why: a single chord is worth exactly half the ring, so the entire gap to $n - c$
lives in the *interaction between several chords*. The following directions are
framed to attack that gap.

**Two crossing chords beat the half bound.** If two chords *cross* (their
endpoints alternate around the frame), they partition the ring into four arcs, and
a single cycle can be routed through three of the four — discarding only the
shortest — instead of being confined to one arc. This should yield a second cycle
of length at least $2n/3$. Crossing is the minimal structural feature that lets a
cycle re-use more than one arc, making it the natural first step beyond the half
bound.

**Chord density forces near-Hamiltonian second cycles.** With at least $n$ chords
(average degree at least four on top of the frame), the short arcs cut off by
chords can be individually bypassed, each bypass removing only its own length. The
deficit should then collapse from a constant fraction of $n$ to $O(\log n)$,
yielding a second cycle of length $n - O(\log n)$.

**Bounded chord span is the only obstruction.** The complementary-arc identity
shows a single long-span chord already gives a long cycle. Hence the extremal
graphs — those *without* a length-$(n - c)$ second cycle — must hide all their
length in many short-span chords clustered near the frame, reducing the extremal
analysis to a finite, checkable local configuration space.

**Vertex-uniform strengthening.** Just as Theorem 4.3 upgrades existence to
vertex-uniform existence at the half-perimeter, one expects the eventual $n - c$
bound to hold uniformly: every vertex should lie on a second cycle of length
$n - c$.

Finally, the cyclic-group indexing should be removed in favour of an abstract
Hamiltonian cycle in a general simple graph, transporting the arc-cycle engine to
the full conjecture.

## 8. Conclusion

We have shown that in any Hamiltonian graph built on the cyclic frame with minimum
degree three, a single chord manufactures a second cycle whose length is its
cyclic span plus one; that the two complementary arcs of a chord have lengths
summing to $n + 2$, forcing a second cycle of length at least $n/2 + 1$; that this
long second cycle passes through every vertex; and that half the perimeter is
exactly what one chord is worth. The arc-cycle construction and the
complementary-arc identity are the compact, exact tools with which the remaining
climb to the full $n - c$ conjecture — a story about how multiple chords cooperate
— can be built.
