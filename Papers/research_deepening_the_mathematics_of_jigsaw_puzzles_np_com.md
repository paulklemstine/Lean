# Conservation, Boundary Topology, and Symmetry in Jigsaw Assembly

## Abstract

We study the combinatorial structure of jigsaw puzzles through the algebra of
their edges. Each piece is modelled by the four-tuple of shapes on its top,
right, bottom, and left edges, where every edge is *flat*, a *tab*, or a *blank*,
and two edges *interlock* precisely when they are exchanged by a single
complementation involution swapping tab and blank while fixing flat. Two threads
of results follow. First, at the level of computational complexity, the decision
problem of whether a given multiset of pieces admits a valid assembly is
NP-complete: Boolean satisfiability reduces to puzzle assembly by encoding a truth
value as an edge shape (true as a tab, false as a blank), so that the local
matching rule enforces logical consistency. Second, at the level of global
structure, we introduce a signed edge potential — $+1$ for a tab, $-1$ for a
blank, $0$ for a flat edge — and prove a **conservation law**: every validly
assembled row or rectangle has total potential zero, so the number of exposed
tabs equals the number of exposed blanks. The proof reduces to a one-dimensional
telescoping cancellation and behaves like a discrete divergence theorem, with all
interior interfaces cancelling and a flat boundary carrying no charge. We
accompany the conservation law with a boundary-topology reading (corner pieces are
doubly flat; a handshake identity relates pieces, interior seams, and border
edges) and a determination of the symmetry group of the interlocking relation: a
relabelling of edge shapes preserves matching if and only if it commutes with
complementation, and there are exactly two such relabellings, so the automorphism
group is $\mathbb{Z}/2$.

**Keywords:** jigsaw puzzle, NP-completeness, complementation involution,
conservation law, discrete divergence theorem, boundary topology, handshake
identity, automorphism group.

## 1. Introduction

A jigsaw puzzle is a system of local constraints whose global solution encodes a
surprising amount of mathematics. The purpose of this paper is to make that
statement precise along two axes.

On the *computational* axis, we recall that deciding whether a bag of pieces can
be assembled into a valid rectangle is NP-complete. This places jigsaw assembly
in the company of Boolean satisfiability, graph colouring, and Hamiltonian-cycle
detection: easy to verify, apparently hard to solve. The reduction is elementary
and instructive, and we sketch it below because it motivates the edge algebra we
subsequently exploit.

On the *structural* axis — the main contribution — we show that beneath the
hardness there is striking rigidity. Every valid assembly obeys an exact
conservation law. We isolate the algebraic fact responsible (complementation
negates a signed edge potential), prove a single telescoping lemma, and derive
from it the conservation law in one and two dimensions, a boundary-topology
description, and the automorphism group of the matching relation. The recurring
character throughout is one order-two involution, from which the combinatorics,
the topology, and the symmetry all descend.

## 2. The edge algebra

**Definition 2.1 (Edges).** The *edge alphabet* is the three-element set
$$ \mathcal{E} = \{\,\text{flat},\ \text{tab},\ \text{blank}\,\}. $$
A *flat* edge is a straight border edge; a *tab* protrudes outward; a *blank*
recedes inward.

**Definition 2.2 (Complementation).** The *complementation* map
$c : \mathcal{E} \to \mathcal{E}$ is defined by
$$ c(\text{flat}) = \text{flat}, \qquad c(\text{tab}) = \text{blank}, \qquad c(\text{blank}) = \text{tab}. $$

**Lemma 2.3 (Involution).** $c \circ c = \mathrm{id}_{\mathcal{E}}$; that is, $c$
is an involution. Its set of fixed points is exactly $\{\text{flat}\}$.

*Proof.* Immediate by checking the three cases. $\square$

**Definition 2.4 (Fitting).** Two edges $a, b \in \mathcal{E}$ *interlock* (or
*fit*), written $a \bowtie b$, when $b = c(a)$. Equivalently, a tab fits a blank,
a blank fits a tab, and a flat fits nothing (since $c(\text{flat}) = \text{flat}$
would require a flat to meet a flat, which we exclude from interior interfaces).

**Definition 2.5 (Pieces).** A *piece* is a tuple
$p = (\text{top}, \text{right}, \text{bottom}, \text{left}) \in \mathcal{E}^4$.
We write $p.\text{top}$, $p.\text{right}$, etc. for its components.

**Definition 2.6 (Truth encoding).** The *encoding* $\mathrm{enc} : \{\bot,
\top\} \to \mathcal{E}$ sends $\top \mapsto \text{tab}$ and $\bot \mapsto
\text{blank}$. Thus a truth value is stored as the *sign* of an interlocking
edge.

## 3. Computational hardness

**Theorem 3.1 (NP-completeness of assembly).** The decision problem *"Given a
finite multiset of pieces and target dimensions $r \times c$, is there a valid
assembly?"* is NP-complete.

*Proof sketch.* Membership in NP is clear: a claimed placement of pieces is a
polynomial-size certificate whose validity (all interior interfaces
complementary, all border edges flat) is checkable in polynomial time.

For hardness we reduce from Boolean satisfiability. Given a formula $\varphi$ over
variables $x_1, \dots, x_m$, we build a family of pieces arranged into
*channels*. Each variable $x_k$ is represented by a channel of pieces whose
interlocking edges must all carry a consistent value: since neighbouring edges
must be complementary and a truth value is encoded as $\mathrm{enc}(b)$ with
$\mathrm{enc}(\top) = \text{tab}$, $\mathrm{enc}(\bot) = \text{blank}$, a channel
can be assembled in exactly two ways, corresponding to $x_k = \top$ or
$x_k = \bot$. Clause gadgets connect the channels so that a clause's gadget admits
a valid local assembly if and only if at least one of its literals is satisfied.
The full board assembles if and only if there is a truth assignment satisfying
every clause, i.e. if and only if $\varphi$ is satisfiable. The construction is
polynomial in the size of $\varphi$. $\square$

The reduction turns the mechanical act of interlocking into logical evaluation:
the "tab meets blank" rule is exactly the propagation of a consistent Boolean
value along a channel. This computational reading is what motivates viewing an
edge as carrying a *signed* quantity, which we now formalise.

## 4. The signed potential and its two defining properties

**Definition 4.1 (Edge potential).** The *potential* $w : \mathcal{E} \to
\mathbb{Z}$ is
$$ w(\text{flat}) = 0, \qquad w(\text{tab}) = +1, \qquad w(\text{blank}) = -1. $$

**Lemma 4.2 (Complementation negates potential).** For every edge $e$,
$$ w(c(e)) = -\,w(e). $$

*Proof.* Check the three cases: $w(c(\text{flat})) = w(\text{flat}) = 0 = -0$;
$w(c(\text{tab})) = w(\text{blank}) = -1 = -w(\text{tab})$; and symmetrically for
blank. $\square$

**Lemma 4.3 (Potential detects the boundary).** $w(e) = 0$ if and only if
$e = \text{flat}$.

*Proof.* Immediate from the definition. $\square$

**Lemma 4.4 (Encoding sign).** $w(\mathrm{enc}(b)) = +1$ if $b = \top$ and $-1$
if $b = \bot$; i.e. the assignment channel carries the truth value as the sign of
its potential.

These three lemmas are the entire arithmetic input to the conservation law. Lemma
4.2 is the crucial one: it says that whenever two edges are mated, their
potentials are equal and opposite.

**Lemma 4.5 (Potential as tab/blank indicator).** For every edge $e$,
$$ w(e) = \mathbf{1}[e = \text{tab}] - \mathbf{1}[e = \text{blank}], $$
where $\mathbf{1}[\cdot]$ is the $0/1$ indicator. Consequently, summed over any
collection of edges, total potential equals *(number of tabs)* minus *(number of
blanks)*.

## 5. The telescoping conservation lemma

The heart of the theory is a one-dimensional cancellation along a strip of
interfaces.

**Lemma 5.1 (Telescoping cancellation).** Let $r, \ell : \mathbb{N} \to
\mathcal{E}$ be sequences of "right" and "left" edges along a strip of $n$
consecutive interfaces. Suppose:

1. *(flat start)* if $n > 0$ then $\ell(0) = \text{flat}$;
2. *(flat end)* if $n > 0$ then $r(n-1) = \text{flat}$;
3. *(interface rule)* for all $i$ with $i + 1 < n$, $\ell(i+1) = c(r(i))$.

Then
$$ \sum_{i=0}^{n-1} w(r(i)) + \sum_{i=0}^{n-1} w(\ell(i)) = 0. $$

*Proof.* The case $n = 0$ is the empty sum. For $n = m + 1$, split off the last
right term and the first left term:
$$ \sum_{i=0}^{m} w(r(i)) = \Big(\sum_{i=0}^{m-1} w(r(i))\Big) + w(r(m)), \qquad
\sum_{i=0}^{m} w(\ell(i)) = w(\ell(0)) + \sum_{i=0}^{m-1} w(\ell(i+1)). $$
By the flat-start and flat-end conditions, $w(\ell(0)) = 0$ and $w(r(m)) = 0$. By
the interface rule and Lemma 4.2,
$$ \sum_{i=0}^{m-1} w(\ell(i+1)) = \sum_{i=0}^{m-1} w(c(r(i))) = -\sum_{i=0}^{m-1} w(r(i)). $$
Adding the two displayed sums, the surviving terms are
$\sum_{i=0}^{m-1} w(r(i))$ and $-\sum_{i=0}^{m-1} w(r(i))$, which cancel. $\square$

This lemma is the discrete analogue of integrating a derivative across an
interval: interior contributions telescope, and only the (flat, hence neutral)
endpoints could survive.

## 6. Rows: one-dimensional conservation

**Definition 6.1 (Row).** A *row* (or chain) of length $n$ is a family of pieces
$p_0, \dots, p_{n-1}$ laid left to right.

**Definition 6.2 (Valid row).** A row is *valid* when:
every $p_i$ has flat top and flat bottom (a single row is both the top and bottom
border); the far-left edge $p_0.\text{left}$ and far-right edge
$p_{n-1}.\text{right}$ are flat; and each interior left edge complements the
previous right edge, $p_{i+1}.\text{left} = c(p_i.\text{right})$.

**Definition 6.3 (Counts).** The row's *potential* is the sum over all pieces of
the potentials of their four edges. Its *tab count* and *blank count* are the
number of edges (over all four sides of all pieces) equal to tab and to blank,
respectively.

**Theorem 6.4 (Row conservation).** Every valid row has total potential zero.

*Proof.* The flat top and bottom of each piece contribute $0$, so the potential
equals $\sum_i \big(w(p_i.\text{right}) + w(p_i.\text{left})\big)$. Apply Lemma
5.1 with $r(i) = p_i.\text{right}$, $\ell(i) = p_i.\text{left}$; the three
hypotheses are exactly the flat-left, flat-right, and interface conditions of
validity. $\square$

**Theorem 6.5 (Tab–blank balance, 1D).** In every valid row, the number of
exposed tabs equals the number of exposed blanks.

*Proof.* By Lemma 4.5, potential $=$ tabs $-$ blanks. Theorem 6.4 makes this
zero. $\square$

## 7. Rectangles: two-dimensional conservation

**Definition 7.1 (Grid).** A *grid* of dimensions $R \times C$ is a family of
pieces $p_{i,j}$ for $0 \le i < R$, $0 \le j < C$.

**Definition 7.2 (Valid grid).** A grid is *valid* when its four borders are flat
(top edges of row $0$, bottom edges of row $R-1$, left edges of column $0$, right
edges of column $C-1$ are all flat) and interior neighbours interlock:
horizontally $p_{i,j+1}.\text{left} = c(p_{i,j}.\text{right})$ and vertically
$p_{i+1,j}.\text{top} = c(p_{i,j}.\text{bottom})$.

**Theorem 7.3 (Row/column slice conservation).** In a valid grid, each row has
zero horizontal potential $\sum_j \big(w(p_{i,j}.\text{right}) +
w(p_{i,j}.\text{left})\big) = 0$, and each column has zero vertical potential
$\sum_i \big(w(p_{i,j}.\text{bottom}) + w(p_{i,j}.\text{top})\big) = 0$.

*Proof.* Each is a direct application of Lemma 5.1 — along the row using the flat
left/right borders and the horizontal interface rule, along the column using the
flat top/bottom borders and the vertical interface rule. $\square$

**Theorem 7.4 (Grid conservation).** Every valid grid has total potential zero:
$$ \sum_{i=0}^{R-1}\sum_{j=0}^{C-1} \big( w(p_{i,j}.\text{top}) + w(p_{i,j}.\text{right}) + w(p_{i,j}.\text{bottom}) + w(p_{i,j}.\text{left}) \big) = 0. $$

*Proof.* Regroup the total as (all right/left potentials) $+$ (all top/bottom
potentials). The first group is $\sum_i$ of the horizontal row potentials, each
zero by Theorem 7.3; the second is $\sum_j$ of the vertical column potentials
(after exchanging the order of summation), each zero by Theorem 7.3. Hence the
total is $0$. $\square$

Consequently, by Lemma 4.5 again, **every valid rectangular assembly has as many
exposed tabs as exposed blanks.** The two-dimensional statement is proved by
slicing into one-dimensional strips and invoking the same telescoping lemma once
per slice — the combinatorial shadow of a divergence theorem.

## 8. Boundary topology

**Theorem 8.1 (Corner pieces are doubly flat).** In a non-empty valid grid, the
top-left corner piece $p_{0,0}$ satisfies $p_{0,0}.\text{top} = \text{flat}$ and
$p_{0,0}.\text{left} = \text{flat}$; symmetrically for the other three corners.

*Proof.* The top edge of $p_{0,0}$ lies on the flat top border and the left edge
on the flat left border, directly from validity. $\square$

By Lemma 4.3, the boundary of the figure is exactly the fixed-point set of
complementation: the outline is where the potential vanishes.

**Theorem 8.2 (Handshake identity).** In an $(r+1) \times (c+1)$ grid,
$$ 2\big((r+1)c + r(c+1)\big) + 2\big((r+1) + (c+1)\big) = 4\,(r+1)(c+1). $$
Equivalently, twice the number of interior interfaces plus the number of border
edges equals four times the number of pieces.

*Proof.* Each of the $(r+1)(c+1)$ pieces has four edges, giving $4(r+1)(c+1)$
edge-slots. Every interior interface is shared by two pieces (counted twice);
there are $(r+1)c$ vertical seams and $r(c+1)$ horizontal seams. Every border edge
belongs to one piece; there are $2((r+1)+(c+1))$ of them. Summing the two ways of
counting edge-slots gives the identity, which is a polynomial identity verifiable
directly. $\square$

## 9. The symmetry group of interlocking

We now ask which relabellings of edge shapes preserve the matching relation. A
relabelling is a permutation $\sigma$ of $\mathcal{E}$.

**Definition 9.1 (Commuting with complementation).** A permutation $\sigma$ of
$\mathcal{E}$ *commutes with complementation* when $\sigma(c(e)) = c(\sigma(e))$
for every edge $e$.

**Theorem 9.2 (Symmetry characterization).** A permutation $\sigma$ preserves the
interlocking relation — meaning $a \bowtie b \iff \sigma(a) \bowtie \sigma(b)$ for
all $a, b$ — if and only if $\sigma$ commutes with complementation.

*Proof.* ($\Rightarrow$) Since $e \bowtie c(e)$ always holds, preservation gives
$\sigma(e) \bowtie \sigma(c(e))$, i.e. $\sigma(c(e)) = c(\sigma(e))$.
($\Leftarrow$) Assume $\sigma \circ c = c \circ \sigma$. Then $a \bowtie b$ means
$b = c(a)$, whence $\sigma(b) = \sigma(c(a)) = c(\sigma(a))$, i.e. $\sigma(a)
\bowtie \sigma(b)$; conversely, if $\sigma(a) \bowtie \sigma(b)$ then $\sigma(b) =
c(\sigma(a)) = \sigma(c(a))$, and injectivity of $\sigma$ yields $b = c(a)$.
$\square$

**Theorem 9.3 (Order of the symmetry group).** Exactly two permutations of
$\mathcal{E}$ commute with complementation: the identity and the tab$\leftrightarrow$blank
swap. Hence the automorphism group of the interlocking relation is $\mathbb{Z}/2$.

*Proof.* Any such $\sigma$ must fix the set of fixed points of $c$, namely
$\{\text{flat}\}$, so $\sigma(\text{flat}) = \text{flat}$ and $\sigma$ permutes
$\{\text{tab}, \text{blank}\}$. Both of the two permutations of this pair commute
with $c$ (the identity trivially; the swap because $c$ is itself that swap on the
pair). No other permutation of $\mathcal{E}$ fixes flat, so there are exactly
two. $\square$

Thus one involution governs three phenomena at once: it negates the potential
(Section 4, powering conservation), it fixes exactly the flat edges (Section 8,
describing the boundary), and it generates the order-two symmetry group of
matching (this section).

## 10. Worked example

Consider the two-piece row with
$$ p_0 = (\text{flat}, \text{tab}, \text{flat}, \text{flat}), \qquad
   p_1 = (\text{flat}, \text{flat}, \text{flat}, \text{blank}). $$
The interior interface pairs $p_0.\text{right} = \text{tab}$ with
$p_1.\text{left} = \text{blank} = c(\text{tab})$; the far-left, far-right, and all
top/bottom edges are flat. This row is valid. It exposes exactly one tab and one
blank, and total potential $(+1) + (-1) = 0$: tab–blank balance in the smallest
non-trivial case.

## 11. Applications and discussion

**Verification and error detection.** The conservation law is a global invariant
computable in linear time. Any candidate assembly whose tab count differs from its
blank count is provably invalid, giving a cheap necessary condition — a checksum
for puzzles — useful in automated solvers and in generating well-formed puzzle
instances.

**A dictionary with physics and topology.** The proof structure — interior
cancellation, boundary charge — is precisely the pattern of a discrete divergence
theorem. The signed potential plays the role of a flux, complementation the role
of orientation reversal across a shared face, and the flat border the role of a
no-flux boundary condition. This dictionary suggests transporting the invariant to
other lattices and surfaces.

**Complexity versus structure.** It is notable that a problem which is NP-complete
to *solve* nonetheless obeys an exact, efficiently checkable law satisfied by
*every* solution. Hardness lives in *finding* an assembly; the conservation law
constrains the *space* of assemblies. The two coexist without tension: the
invariant prunes but does not collapse the search.

## 12. Future directions

**A conservation law for arbitrary simply connected regions.** We conjecture the
tab–blank balance holds for every assembly whose footprint is a simply connected
region of the square lattice with an all-flat outer boundary, not merely
rectangles. The signed potential behaves like a discrete divergence:
complementation negates it, each shared interior edge cancels against itself, and
only the boundary can carry net charge; a flat boundary carries none. Extending
the slicing argument from rectangles to staircase and L-shaped footprints is the
natural next step and would connect puzzle assembly to discrete exterior calculus.

**Genus obstructions on surfaces.** If pieces are assembled on a closed surface of
genus $g$ rather than a flat rectangle, we conjecture the balance is corrected by a
term determined solely by $g$: exact on the torus, with a fixed unremovable defect
on higher-genus surfaces. The boundary term is a topological invariant of the
assembly surface; changing genus changes how interior edges pair, and the unpaired
remainder should match an Euler-characteristic count.

**Richer edge alphabets and larger symmetry groups.** If the edge alphabet is
enlarged from three shapes to $2k+1$ shapes (one self-complementary border shape
and $k$ complementary tab/blank pairs), we conjecture the automorphism group of
the interlocking relation is the hyperoctahedral group of order $2^k \cdot k!$,
with centre the single order-two "flip every interlock" symmetry. Preserving the
matching relation is equivalent to commuting with the complementation involution,
and for $k$ independent complementary pairs this centraliser is exactly the group
of signed permutations of the pairs.

## 13. Conclusion

From the single algebraic fact that complementation is an involution negating a
signed edge potential, we obtained: a conservation law forcing exposed tabs and
blanks to balance in every valid row and rectangle; a boundary-topology reading
with doubly-flat corners and a handshake identity; and the determination of the
matching relation's automorphism group as $\mathbb{Z}/2$. Alongside the classical
NP-completeness of assembly, these results show the jigsaw puzzle to be a compact
laboratory in which computational hardness, conservation, topology, and symmetry
meet.
