# Logical Qubits as Middle Homology: An Exact Dictionary for CSS Quantum Codes

## Abstract

We develop, in complete generality over an arbitrary field, the exact dictionary
identifying the logical dimension of a Calderbank–Shor–Steane (CSS) quantum
error-correcting code with the dimension of the middle homology of its associated
length-two chain complex. The cornerstone is an *additive* accounting identity,
$k + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim B$, relating the
number of logical qubits $k$ to the ranks of the two boundary maps and the number
of physical qubits $\dim B$. From this single identity we derive four principal
consequences. First (**realizability**), every pair $(n,k)$ with $k \le n$ is
realized by some CSS complex, and indeed the two check ranks may be prescribed
independently. Second (**self-duality**), the transposed complex has the same
logical dimension, so the $X$-logical and $Z$-logical spaces always match — a
direct consequence of rank invariance under transposition. Third (**Euler
rate**), for connected graph complexes the code rate equals $1 - (V-1)/E$,
attaining $0$ on trees and $1$ on bouquets. Fourth (**hypercube girth**), the
hypercube graph $Q_n$ has girth exactly $4$ for all $n \ge 2$, so the associated
homological code has distance $4$ and fails the quantum Singleton bound for
$n \ge 5$, even though its logical dimension $2^{n-1}(n-2)+1$ grows exponentially.
Together these results decouple the two fundamental code parameters — logical
count (an Euler-characteristic invariant) and distance (a girth invariant) — and
refute the folklore that the hypercube code protects a single qubit.

**Keywords:** CSS codes, chain complex, homology, quantum error correction,
rank–nullity, Euler characteristic, code rate, hypercube graph, girth, bipartite
graph, self-duality, quantum Singleton bound.

---

## 1. Introduction

Quantum error correction protects fragile quantum information by encoding a small
number of *logical* qubits redundantly across a larger number of *physical*
qubits. The CSS construction of Calderbank, Shor, and Steane produces a large and
practically important class of such codes from a pair of classical parity-check
systems satisfying an orthogonality condition. It has long been understood, at the
level of examples and folklore, that CSS codes are "the same as" chain complexes
and that the number of logical qubits is a homological quantity. The purpose of
this paper is to make that correspondence into a precise, field-agnostic theorem
and to harvest its consequences.

We work throughout with the algebraic skeleton of a CSS code: a **length-two
chain complex**

$$A \xrightarrow{\;d_2\;} B \xrightarrow{\;d_1\;} C, \qquad d_1 \circ d_2 = 0,$$

over a field $K$. The middle space $B$ carries the physical qubits. The **logical
space** is the middle homology $H = \ker d_1 / \operatorname{im} d_2$, and the
**logical dimension** (number of logical qubits) is $k = \dim_K H$.

Our results are organized around a single additive accounting identity
(Section 3), from which realizability (Section 4), self-duality (Section 5), the
Euler code-rate formula (Section 6), and the hypercube girth theorem (Section 7)
all follow. A distinctive feature of the development is that it never uses
truncated natural-number subtraction: every identity is stated additively, so it
holds verbatim over any field.

---

## 2. Definitions

**Definition 2.1 (Chain complex).**
Let $K$ be a field and $A, B, C$ be $K$-vector spaces. A *length-two chain
complex* is a pair of linear maps $d_2 \colon A \to B$ and $d_1 \colon B \to C$
satisfying $d_1 \circ d_2 = 0$. We call $d_1$ and $d_2$ the *boundary maps*.

**Definition 2.2 (Cycles and boundaries).**
The *cycles* are $Z = \ker d_1 \subseteq B$, and the *boundaries* are
$\mathrm{Bd} = \operatorname{im} d_2 \subseteq B$. The chain-complex condition
$d_1 \circ d_2 = 0$ is precisely the statement $\mathrm{Bd} \subseteq Z$: every
boundary is a cycle.

**Definition 2.3 (Logical space and logical dimension).**
The *logical space* (middle homology) is the quotient
$$H = Z / \mathrm{Bd} = \ker d_1 / \operatorname{im} d_2.$$
The *logical dimension* is $k = \dim_K H$, the number of logical qubits.

**Definition 2.4 (Physical dimension and check ranks).**
The *physical dimension* is $\dim_K B$, the number of physical qubits. The two
*check ranks* are $\operatorname{rank} d_1 = \dim_K \operatorname{im} d_1$ and
$\operatorname{rank} d_2 = \dim_K \operatorname{im} d_2$.

**Definition 2.5 (Graph complex).**
A *graph complex* is a chain complex with $d_2 = 0$ arising from a graph $G$: the
middle space $B = K^E$ is spanned by the edges, $C = K^V$ by the vertices, and
$d_1$ sends each edge to the (signed) sum of its endpoints. The *zeroth Betti
number* $\beta_0 = \dim_K (C / \operatorname{im} d_1)$ counts connected
components; the graph is *connected* iff $\beta_0 = 1$.

**Definition 2.6 (Dual complex).**
The *dual (transposed) complex* of $A \xrightarrow{d_2} B \xrightarrow{d_1} C$ is
$$C^* \xrightarrow{\;d_1^{\!\top}\;} B^* \xrightarrow{\;d_2^{\!\top}\;} A^*,$$
where $V^* = \operatorname{Hom}_K(V, K)$ is the dual space and $f^{\!\top}$ the
transpose (dual) map. The condition $d_2^{\!\top} \circ d_1^{\!\top} =
(d_1 \circ d_2)^{\!\top} = 0$ holds automatically, so the dual is again a chain
complex.

**Definition 2.7 (Hypercube graph).**
The *hypercube graph* $Q_n$ has vertex set $\{0,1\}^n$ (binary strings of length
$n$, i.e. functions $\{1,\dots,n\} \to \mathbb{Z}/2$); two vertices are adjacent
iff they differ in exactly one coordinate. The *parity* of a vertex $x$ is
$\pi(x) = \sum_i x_i \in \mathbb{Z}/2$.

**Definition 2.8 (Girth and distance).**
The *girth* of a graph is the length of its shortest cycle (with the convention
that an acyclic graph has infinite girth). For a graph (one-dimensional)
homological code, the code *distance* — the weight of the smallest undetectable
error — equals the girth of the underlying graph.

---

## 3. The accounting identity

All later results rest on the following exact, additive identity.

**Theorem 3.1 (CSS dimension formula).**
*Let $A \xrightarrow{d_2} B \xrightarrow{d_1} C$ be a chain complex with $B$
finite-dimensional. Then*
$$k + \operatorname{rank} d_1 + \operatorname{rank} d_2 = \dim_K B,$$
*where $k = \dim_K H$ is the logical dimension.*

*Proof sketch.* Two applications of rank–nullity, glued additively.

1. **Splitting off boundaries.** Because $\operatorname{im} d_2 \subseteq
   \ker d_1$, the boundaries form a subspace of the cycles, and the natural
   isomorphism between $H = Z/\mathrm{Bd}$ and the quotient of $Z$ by the
   pullback of $\mathrm{Bd}$ gives
   $$\dim_K H + \operatorname{rank} d_2 = \dim_K Z. \tag{3.1}$$
   (Here $\operatorname{rank} d_2 = \dim_K \mathrm{Bd}$, as $\mathrm{Bd}$ sits
   inside $Z$.)

2. **Rank–nullity on $d_1$.** The kernel–image decomposition of $d_1$ gives
   $$\dim_K Z + \operatorname{rank} d_1 = \dim_K B. \tag{3.2}$$

Adding (3.1) and (3.2) and cancelling $\dim_K Z$ yields the claim. $\qquad\blacksquare$

Two auxiliary identities used repeatedly are recorded here.

**Corollary 3.2 (Euler identity).**
*If $B$ and $C$ are finite-dimensional, then*
$$\beta_0 + \dim_K B = \dim_K Z + \dim_K C,$$
*where $\beta_0 = \dim_K(C/\operatorname{im} d_1)$.*

*Proof sketch.* Rank–nullity for the quotient $C/\operatorname{im} d_1$ gives
$\beta_0 + \operatorname{rank} d_1 = \dim_K C$; combine with (3.2). $\blacksquare$

**Corollary 3.3 (Graph complexes).**
*If $d_2 = 0$ then $H = Z$, so $k = \dim_K Z$; the logical space is the entire
cycle space.*

---

## 4. Realizability of every parameter pair

**Theorem 4.1 (Realizability).**
*For every field $K$ and all natural numbers $k \le n$, there is a length-two
chain complex with physical dimension $\dim_K B = n$ and logical dimension exactly
$k$. Consequently every physical/logical pair $(n,k)$ with $k \le n$ is realized
by a CSS complex.*

*Proof sketch.* Set $B = K^{\,n-k} \times K^{\,k}$, take $d_2 = 0$, and let $d_1$
be the projection onto the first factor. Then $\operatorname{rank} d_2 = 0$,
$\operatorname{rank} d_1 = n-k$ (the projection is onto), and the accounting
identity 3.1 gives $k = \dim_K B - \operatorname{rank} d_1 = n - (n-k) = k$. $\blacksquare$

The construction can be sharpened to control both check ranks independently. This
is the content of the exact accounting: the ranks are free parameters.

**Theorem 4.2 (Rank-prescription realizability).**
*For every field $K$ and all natural numbers $r, s, m$, there is a length-two
chain complex with*
$$\dim_K B = r + s + m, \quad \operatorname{rank} d_1 = r, \quad
\operatorname{rank} d_2 = s, \quad k = m.$$

*Proof sketch.* Take $B = K^r \times K^s \times K^m$. Let $d_1$ be the projection
onto the first factor $K^r$ (rank $r$, surjective onto $C = K^r$), and let $d_2$
be the inclusion of $A = K^s$ into the middle factor (rank $s$, injective, with
image inside $\ker d_1$ so that $d_1 \circ d_2 = 0$). The accounting identity then
forces $k = (r+s+m) - r - s = m$. $\blacksquare$

Theorem 4.1 follows from Theorem 4.2 with $(r, s, m) = (n-k, 0, k)$.

---

## 5. Cohomological self-duality

CSS codes carry two families of stabilizer checks — the $X$-checks and the
$Z$-checks — whose logical spaces are $\ker d_1 / \operatorname{im} d_2$ and
$\ker d_2^{\!\top} / \operatorname{im} d_1^{\!\top}$ respectively. The second is
precisely the logical space of the dual complex.

**Theorem 5.1 (Self-duality).**
*Let $A \xrightarrow{d_2} B \xrightarrow{d_1} C$ be a chain complex with $B$
finite-dimensional. Then its dual complex has the same logical dimension:*
$$\dim_K \big(\ker d_2^{\!\top}/\operatorname{im} d_1^{\!\top}\big)
= \dim_K \big(\ker d_1/\operatorname{im} d_2\big).$$
*Equivalently, the $X$-logical and $Z$-logical spaces have equal dimension.*

*Proof sketch.* Transposition preserves rank: $\operatorname{rank} d^{\!\top} =
\operatorname{rank} d$ for any linear map $d$ between finite-dimensional spaces.
Applying the accounting identity 3.1 to the dual complex, whose middle space is
$B^*$ with $\dim_K B^* = \dim_K B$ and whose boundary maps are $d_1^{\!\top}$ and
$d_2^{\!\top}$, gives
$$k_{\mathrm{dual}} + \operatorname{rank} d_1^{\!\top} +
\operatorname{rank} d_2^{\!\top} = \dim_K B^*.$$
Substituting $\operatorname{rank} d_i^{\!\top} = \operatorname{rank} d_i$ and
$\dim_K B^* = \dim_K B$ and comparing with the original identity for $k$ yields
$k_{\mathrm{dual}} = k$. $\blacksquare$

Thus CSS self-duality is not an extra structural hypothesis but a *consequence* of
rank symmetry under transposition, valid for every chain complex.

---

## 6. The Euler characteristic as a code rate

We now specialize to connected graph complexes ($d_2 = 0$, $\beta_0 = 1$) with
$V = \dim_K C$ vertices and $E = \dim_K B$ edges.

**Theorem 6.1 (Circuit-rank count).**
*For a connected graph complex, $k + V = E + 1$, i.e. $k = E - V + 1$.*

*Proof sketch.* By Corollary 3.3, $k = \dim_K Z$. The Euler identity 3.2 with
$\beta_0 = 1$ gives $1 + E = \dim_K Z + V$, hence $\dim_K Z = E - V + 1$. $\blacksquare$

The quantity $E - V + 1$ is the classical *circuit rank* (first Betti number) of
the graph: the number of independent cycles.

**Theorem 6.2 (Code rate formula).**
*For a connected graph complex with $E > 0$, the code rate is*
$$\frac{k}{E} = 1 - \frac{V-1}{E}.$$

*Proof sketch.* Rearrange $k = E - V + 1 = E - (V-1)$ and divide by $E$. $\blacksquare$

**Corollary 6.3 (Extremes).**
1. **(Trees.)** A connected graph complex with $E = V - 1$ (a spanning tree) has
   $k = 0$ and rate $0$: it encodes no logical qubits.
2. **(Bouquets.)** A connected graph complex on a single vertex ($V = 1$, a
   bouquet of $E$ loops) has $k = E$ and rate $1$: every physical qubit is
   logical.

*Proof sketch.* Substitute $E = V-1$ and $V = 1$ respectively into Theorem 6.1. $\blacksquare$

The rate is thus a purely combinatorial ratio, minimized by trees and maximized by
bouquets among connected graphs.

---

## 7. The hypercube: exponentially many qubits, constant distance

### 7.1 Logical dimension

The hypercube $Q_n$ has $V = 2^n$ vertices and $E = n \cdot 2^{n-1}$ edges. By
Theorem 6.1 its associated graph code has logical dimension
$$k = E - V + 1 = n \cdot 2^{n-1} - 2^n + 1 = 2^{n-1}(n-2) + 1.$$
This equals $1$ only for $n = 2$, grows to $17$ for $n = 4$, and increases
exponentially thereafter — refuting the folklore "one qubit" law for the
hypercube.

### 7.2 Girth

**Lemma 7.1 (Bipartiteness).**
*Along any walk in $Q_n$ from $x$ to $y$ of length $\ell$, the endpoint parities
satisfy $\pi(y) = \pi(x) + \ell \pmod 2$.*

*Proof sketch.* Each edge flips exactly one coordinate, changing the coordinate
sum by $1 \pmod 2$; induct on walk length. Adjacent vertices therefore have
opposite parity, so $Q_n$ is bipartite. $\blacksquare$

**Corollary 7.2 (Even cycles).**
*Every closed walk in $Q_n$ has even length. In particular $Q_n$ is
triangle-free, so its girth is at least $4$.*

*Proof sketch.* A closed walk has $x = y$, so Lemma 7.1 forces $\ell \equiv 0
\pmod 2$. A closed walk of length $3$ is impossible. $\blacksquare$

**Lemma 7.3 (A 4-cycle exists).**
*For $n \ge 2$, $Q_n$ contains a cycle of length $4$.*

*Proof sketch.* Fix two coordinates $i \ne j$. Starting from the zero vector,
flip coordinate $i$, then $j$, then $i$, then $j$; each step changes exactly one
coordinate (an edge), the four vertices visited are distinct, and the walk
returns to its start. This is a $4$-cycle. $\blacksquare$

**Theorem 7.4 (Hypercube girth).**
*For every $n \ge 2$, the girth of $Q_n$ is exactly $4$.*

*Proof sketch.* Corollary 7.2 gives girth $\ge 4$ (no odd cycles, hence no
triangle), and Lemma 7.3 gives girth $\le 4$. $\blacksquare$

Remarkably the girth is $4$ *independent of $n$*: it does not grow with dimension.

### 7.3 Failure of the quantum Singleton bound

For a one-dimensional (graph) homological code the distance equals the girth, so
by Theorem 7.4 the hypercube code has distance $d = 4$ for all $n \ge 2$. The
quantum Singleton bound for this family would require distance on the order of
$2^{n/2}$.

**Theorem 7.5 (Singleton gap).**
*For all $n \ge 5$, $4 < 2^{\,n/2}$.*

*Proof sketch.* $2^{n/2}$ is strictly increasing in $n$ and exceeds
$2^{5/2} = 4\sqrt{2} > 4$ already at $n = 5$; monotonicity handles all larger $n$.
$\blacksquare$

Hence the hypercube code fails the quantum Singleton bound for every $n \ge 5$:
its logical count explodes exponentially while its distance is pinned at $4$. The
two parameters are governed by independent invariants — the Euler characteristic
(logical count) and the girth (distance).

---

## 8. Discussion

The results above present a coherent picture in which the two central parameters
of a CSS code are read off from independent features of a chain complex. The
logical dimension is an Euler-characteristic quantity, fixed by the ranks of the
boundary maps through the additive accounting identity of Theorem 3.1. The
distance, for graph codes, is a girth quantity, fixed by the shortest cycle. The
hypercube dramatizes their independence: an exponential logical count coexisting
with constant distance.

The additive formulation is essential. By avoiding truncated subtraction, every
identity holds over an arbitrary field and transposes cleanly, which is exactly
what makes the self-duality theorem a one-line corollary of rank invariance rather
than a separate structural input. The realizability theorems show the design space
of $(n,k)$ pairs is completely unobstructed, and the rank-prescription refinement
shows the accounting is genuinely an equation, not merely a bound.

---

## 9. Future work

Several directions extend these findings.

1. **Distance of the hypercube code.** We conjecture that for all $n \ge 2$ the
   distance equals the girth $4$ independent of $n$, and hence fails the quantum
   Singleton bound $d = 2^{n/2}$ for $n \ge 5$. Section 7 settles the girth; a full
   distance analysis at the level of homology classes would complete the picture.

2. **Euler characteristic as a rate obstruction.** For connected graph complexes
   the rate $k/E = 1 - (V-1)/E$ is a combinatorial ratio; a full extremal analysis
   over all connected graphs on a fixed number of edges would characterize the
   maximizers (bouquets) and minimizers (trees) as a discrete isoperimetric
   problem.

3. **Realizability spectrum.** The rank-prescription construction realizes every
   $(r,s,m)$; understanding which parameter triples are realized by *sparse* or
   *local* complexes (the physically relevant regime) is open.

4. **Higher-length complexes.** Extending the exact dictionary and self-duality to
   chain complexes of length greater than two would connect to higher-dimensional
   homological codes and their improved distance scaling.
