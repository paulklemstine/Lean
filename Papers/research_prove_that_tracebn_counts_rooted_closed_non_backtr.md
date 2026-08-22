# The Non-Backtracking Trace Formula: Counting Rooted Closed Non-Backtracking Walks by Powers of the Hashimoto Matrix

**Author:** Aristotle

**Date:** 2026-08-22

---

## Abstract

Let $G = (V,E)$ be a finite simple graph and let $B$ denote its Hashimoto
(non-backtracking) matrix, the zero-one matrix indexed by the $2|E|$ darts of $G$ whose
$(d,e)$ entry is $1$ precisely when the dart $e$ continues the dart $d$ without an
immediate reversal. We establish the identity
$$\operatorname{trace}(B^n) \;=\; \#\{\text{rooted closed non-backtracking walks of length } n\}$$
for every $n \ge 0$, in three mutually equivalent encodings — as lists of $n+1$ darts with
coinciding endpoints, as cyclic words of $n$ darts, and as cyclic vertex sequences
$(u_1,\dots,u_n)$ with $u_i \sim u_{i+1}$ and $u_{i+2} \ne u_i$ read modulo $n$. Since the
non-backtracking succession relation is *not* symmetric, the classical adjacency-matrix
walk-counting theorem does not apply, and we develop walk counting for an arbitrary
decidable relation on a finite index set as a prerequisite.

From the counting theorem we deduce a complete dictionary between the sequence
$\big(\operatorname{trace}(B^n)\big)_{n \ge 1}$ and the cycle structure of $G$:
the universal vanishing $\operatorname{trace}(B) = \operatorname{trace}(B^2) = 0$; the
ordered-triangle evaluation $\operatorname{trace}(B^3) = 6\cdot\#\{\text{triangles}\}$; the
row-sum identity $\sum_{e} B_{d,e} = \deg(\operatorname{head} d) - 1$ and the resulting
growth bound $\operatorname{trace}(B^n) \le 2|E|\,q^n$ for $(q+1)$-regular graphs; the
evenness of every trace, together with its algebraic source $JBJ = B^{\mathsf T}$ where
$J$ is the dart-reversal involution; the acyclicity criterion
$$G \text{ is a forest} \iff \operatorname{trace}(B^n) = 0 \text{ for all } n \ge 1;$$
the girth criterion
$\operatorname{girth}(G) = \min\{n \ge 1 : \operatorname{trace}(B^n) \ne 0\}$ for a graph
containing a cycle, refined by the multiplicity bound
$2\,\operatorname{girth}(G) \le \operatorname{trace}(B^{\operatorname{girth}(G)})$; and
monotonicity of the entire sequence under subgraph inclusion. Worked evaluations for
$K_3$, $K_4$, $C_5$ and paths are given in closed form.

**Keywords.** Non-backtracking walk; Hashimoto matrix; trace formula; girth; acyclicity;
Ihara zeta function; dart; graph spectrum.

---

## 1. Introduction

### 1.1 Motivation

A walk in a graph is *non-backtracking* if it never immediately reverses the edge it has
just traversed. The condition is deceptively small, and it is decisive. Ordinary random
walks on sparse graphs waste a constant fraction of their steps undoing the previous one;
their spectral theory is dominated by degree fluctuations, and their closed-walk counts are
swamped by the trivial there-and-back contributions. Removing backtracking removes exactly
this noise. What remains is a combinatorial object whose closed orbits are, in a precise
sense, the *cycles* of the graph — and this is the source of the object's importance in
three separate areas:

1. **Zeta functions.** Ihara's zeta function of a graph is an Euler product over
   equivalence classes of primitive closed non-backtracking cycles, and its expression as a
   finite determinant rests on the interpretation of $\operatorname{trace}(B^n)$ as a
   count of such walks.
2. **Spectral inference.** In sparse random graph models the leading eigenvectors of the
   adjacency matrix localise on high-degree vertices; those of the non-backtracking matrix
   do not, and non-backtracking spectral methods achieve community detection down to the
   information-theoretic threshold for the stochastic block model.
3. **Expansion.** For $(q+1)$-regular graphs the Ramanujan property is equivalent to the
   nontrivial spectrum of $B$ lying on the circle of radius $\sqrt{q}$, the square root of
   the non-backtracking branching factor.

The identity underpinning all three is elementary to state and, we shall see, subtler to
prove than its adjacency-matrix analogue. This paper gives a complete, self-contained
development.

### 1.2 The obstacle: asymmetry

For a simple graph with adjacency matrix $A$, the identity $(A^n)_{uv} = \#\{\text{walks of
length } n \text{ from } u \text{ to } v\}$ is standard, and it is standardly proved using
the symmetric structure of the graph. The non-backtracking successor relation is a relation
on *darts*, and it is not symmetric — indeed it is **antisymmetric in the strongest sense**:
if $e$ may follow $d$ then $d$ may never follow $e$ (Lemma 3.4). Consequently no
undirected-graph machinery applies. The correct level of generality is a **decidable
binary relation on a finite index set**, i.e. an arbitrary digraph, and Section 2 develops
walk counting there before Section 3 specialises.

### 1.3 Organisation

Section 2 develops walk counting for a general finite digraph. Section 3 defines darts, the
non-backtracking relation, and the Hashimoto matrix, and proves the main counting theorem
in its three forms. Section 4 derives the small-power evaluations, row sums and the
regular growth bound. Section 5 proves evenness via the reversal involution and identifies
its algebraic source. Section 6 proves the acyclicity criterion. Section 7 proves the
girth criterion and the multiplicity bound. Section 8 proves monotonicity. Section 9 works
out complete examples. Section 10 presents algorithms and complexity. Section 11
discusses applications, and Section 12 states open problems.

---

## 2. Walk counting for an arbitrary finite relation

Throughout this section, $\iota$ is a finite type with decidable equality and
$r : \iota \times \iota \to \{\text{true},\text{false}\}$ is a decidable binary relation —
equivalently, a digraph on the vertex set $\iota$, possibly with loops and certainly not
assumed symmetric.

### 2.1 Definitions

**Definition 2.1 (Relation matrix).** The *relation matrix* of $r$ is the matrix
$M = M(r) \in \mathbb{N}^{\iota \times \iota}$ with
$$M_{ij} = \begin{cases} 1 & \text{if } r(i,j), \\ 0 & \text{otherwise.}\end{cases}$$

**Definition 2.2 (Walks).** For $n \ge 0$ and $a,b \in \iota$, a *walk of length $n$ from
$a$ to $b$* is a list $\ell = (\ell_0, \ell_1, \dots, \ell_n)$ of $n+1$ elements of $\iota$
such that $\ell_0 = a$, $\ell_n = b$, and $r(\ell_i, \ell_{i+1})$ holds for
$0 \le i < n$. We write $W_n(a,b)$ for the (finite) set of such walks.

Equivalently, a walk is a list of length $n+1$ whose consecutive pairs are $r$-related — the
*chain condition* — with prescribed head and last entry.

**Definition 2.3 (Rooted closed walks).** A *rooted closed walk of length $n$* is a walk of
length $n$ from $a$ to $a$ for some $a$; we write
$$C_n = \bigsqcup_{a \in \iota} W_n(a,a) = \{\ell : |\ell| = n+1,\ \ell \text{ is a chain},\ \ell_0 = \ell_n\}.$$
The adjective *rooted* records that the starting point $\ell_0$ is part of the data: the
same cyclic pattern started at a different index is a different element of $C_n$.

Note the degenerate case $n = 0$: a walk of length $0$ is a one-element list, so
$|C_0| = |\iota|$.

### 2.2 The counting theorem

**Theorem 2.4 (Entries of powers count walks).** For all $n \ge 0$ and $a,b \in \iota$,
$$(M^n)_{ab} = |W_n(a,b)| .$$

*Proof sketch.* Induction on $n$. For $n = 0$, $M^0 = I$ and $W_0(a,b)$ is a singleton if
$a = b$ and empty otherwise. For the inductive step, expand
$(M^{n+1})_{ab} = \sum_{c} M_{ac}\,(M^{n})_{cb}$. Each summand is $|W_n(c,b)|$ when
$r(a,c)$ and $0$ otherwise, and the map $\ell \mapsto (a) \mathbin{+\!\!+} \ell$ is a
bijection from $\bigsqcup_{c : r(a,c)} W_n(c,b)$ to $W_{n+1}(a,b)$: prepending $a$ to a
chain from $c$ to $b$ yields a chain from $a$ to $b$ exactly when $r(a,c)$, and every walk
of length $n+1$ from $a$ arises uniquely this way by stripping its head. Summing cardinalities
over the disjoint union gives the claim. $\square$

**Theorem 2.5 (Trace counts rooted closed walks).** For all $n \ge 0$,
$$\operatorname{trace}(M^n) = |C_n| .$$

*Proof.* $\operatorname{trace}(M^n) = \sum_{a} (M^n)_{aa} = \sum_a |W_n(a,a)| = |C_n|$,
the last step because the union defining $C_n$ is disjoint (the sets $W_n(a,a)$ are
distinguished by their first entry). $\square$

### 2.3 Row sums and a growth bound

**Proposition 2.6.** If every row of $M$ sums to the same value $q \in \mathbb{N}$, i.e.
$\sum_{j} M_{ij} = q$ for all $i$, then every row of $M^n$ sums to $q^n$, and consequently
$$\operatorname{trace}(M^n) \;\le\; \sum_{i,j} (M^n)_{ij} \;=\; |\iota| \cdot q^{n}.$$

*Proof sketch.* The row-sum vector satisfies $M \mathbf{1} = q \mathbf{1}$, hence
$M^n \mathbf{1} = q^n \mathbf{1}$ by induction. All entries of $M^n$ are nonnegative, and
the trace is a partial sum of all entries, whence the bound. $\square$

---

## 3. Darts, non-backtracking succession, and the main theorem

Let $G = (V,E)$ be a finite simple graph: $V$ finite, and $E$ a set of two-element subsets
of $V$. Write $u \sim v$ for adjacency.

### 3.1 Darts

**Definition 3.1 (Dart).** A *dart* of $G$ is an ordered pair $d = (u,v)$ with $u \sim v$.
We write $\operatorname{tail}(d) = u$, $\operatorname{head}(d) = v$, and
$d^{-1} = (v,u)$ for the *reversal*. The set of darts is denoted $D(G)$; each edge
contributes two darts, so
$$|D(G)| = 2|E| = \sum_{v \in V} \deg(v).$$
The *underlying edge* of $d = (u,v)$ is $\{u,v\}$.

Since $G$ has no loops, $d \ne d^{-1}$ for every dart $d$: reversal is a fixed-point-free
involution of $D(G)$. This trivial-looking remark is the entire content of Theorem 5.3.

### 3.2 The non-backtracking relation

**Definition 3.2 (Non-backtracking succession).** For darts $d = (u,v)$ and $e = (x,y)$,
say that *$e$ may follow $d$*, written $d \to e$, if
$$v = x \quad\text{and}\quad y \ne u .$$

**Lemma 3.3 (Reformulation).** $d \to e$ if and only if
$\operatorname{head}(d) = \operatorname{tail}(e)$ and $e \ne d^{-1}$.

*Proof.* Given composability $\operatorname{head}(d) = \operatorname{tail}(e)$, the darts
$e$ and $d^{-1}$ share their tail, so $e = d^{-1}$ if and only if their heads agree, i.e.
$y = u$. $\square$

**Lemma 3.4 (Irreflexivity and strong asymmetry).** For all darts $d, e$:
(i) $d \not\to d$; (ii) if $d \to e$ then $e \not\to d$.

*Proof.* (i) $d \to d$ would give $v = u$, impossible in a loopless graph. (ii) Suppose
$d = (u,v) \to e = (x,y)$, so $v = x$ and $y \ne u$; if also $e \to d$ then $y = u$, a
contradiction. $\square$

Thus $\to$ is a genuinely directed relation, and Theorem 2.4 rather than the
adjacency-matrix theorem is the tool we need.

**Definition 3.5 (Hashimoto matrix).** The *Hashimoto matrix* (non-backtracking matrix) of
$G$ is the relation matrix $B = M(\to) \in \mathbb{N}^{D(G) \times D(G)}$:
$$B_{d,e} = \begin{cases} 1 & \text{if } d \to e, \\ 0 & \text{otherwise.}\end{cases}$$
It is a square matrix of size $2|E|$ with zero diagonal, and $B \circ B^{\mathsf T} = 0$
entrywise by Lemma 3.4(ii).

### 3.3 Rooted closed non-backtracking walks

**Definition 3.6.** A *rooted closed non-backtracking walk of length $n$* in $G$ is a list
of darts $\ell = (d_0, d_1, \dots, d_n)$ with $d_i \to d_{i+1}$ for $0 \le i < n$ and
$d_n = d_0$. Write $\mathcal{C}_n(G)$ for the set of these.

**Theorem 3.7 (Non-Backtracking Trace Formula).** For every finite simple graph $G$ and
every $n \ge 0$,
$$\boxed{\;\operatorname{trace}(B^n) = |\mathcal{C}_n(G)|\;}$$

*Proof.* Apply Theorem 2.5 to the finite index set $D(G)$ and the decidable relation
$\to$. $\square$

The economy of this proof is entirely due to having set up Section 2 at the right level of
generality; the combinatorial substance lives there.

### 3.4 The cyclic-word form

The list $(d_0,\dots,d_n)$ carries a redundancy: its last entry repeats its first. Deleting
it produces a cyclically constrained word.

**Definition 3.8 (Cyclic non-backtracking words).** For $n \ge 1$, let $\mathcal{Z}_n(G)$ be
the set of lists $c = (c_1,\dots,c_n)$ of darts satisfying
* $c_i \to c_{i+1}$ for $1 \le i < n$ (the *chain condition*), and
* $c_n \to c_1$ (the *seam condition*).

Equivalently, writing $\sigma$ for the cyclic shift, $c$ satisfies the single condition
$c_i \to (\sigma c)_i$ for all $i$; that is, $\to$ holds pointwise between $c$ and its
rotation by one.

**Theorem 3.9.** For $n \ge 1$, deleting the last entry is a bijection
$\mathcal{C}_n(G) \to \mathcal{Z}_n(G)$; hence
$$\operatorname{trace}(B^n) = |\mathcal{Z}_n(G)| .$$

*Proof sketch.* Deletion sends a closed walk to a word satisfying both conditions: the
chain condition is inherited, and the seam condition is the pair
$d_{n-1} \to d_n = d_0$ rewritten. It is injective because the deleted entry is recoverable
as the first entry, and surjective because appending $c_1$ to $c \in \mathcal{Z}_n(G)$
restores a closed walk, the seam condition supplying the last required link. Cardinalities
therefore agree, and Theorem 3.7 concludes. $\square$

The cyclic form is the convenient one for symmetry arguments, because the cyclic group
$\mathbb{Z}/n$ acts on $\mathcal{Z}_n(G)$ by rotation and the reversal involution acts as
well — facts we exploit in Sections 5 and 7.

**Proposition 3.10 (Stability of cyclic words).** For $n \ge 1$, $\mathcal{Z}_n(G)$ is
stable under (i) rotation $c \mapsto \sigma^i c$ for every $i$, and (ii) the reversal
$c \mapsto \overline{c} := (c_n^{-1}, c_{n-1}^{-1}, \dots, c_1^{-1})$.

*Proof sketch.* (i) The pointwise formulation "$\to$ holds between $c$ and $\sigma c$" is
preserved by applying $\sigma^i$ to both sides, and $\sigma^i \sigma = \sigma \sigma^i$.
(ii) One checks $d \to e \iff e^{-1} \to d^{-1}$ directly from Definition 3.2; reversing
the list therefore converts the chain condition into itself with the roles of the two
endpoints exchanged, and likewise for the seam. $\square$

### 3.5 The vertex form

The dart encoding can be eliminated entirely.

**Theorem 3.11 (Vertex form).** For $n \ge 1$,
$$\operatorname{trace}(B^n) \;=\; \#\left\{(u_1,\dots,u_n) \in V^n \;:\; u_i \sim u_{i+1} \text{ and } u_{i+2} \ne u_i \text{ for all } i \pmod n \right\}.$$

*Proof sketch.* Map $c = (c_1,\dots,c_n) \in \mathcal{Z}_n(G)$ to the sequence of tails
$u_i = \operatorname{tail}(c_i)$. Since $c_i \to c_{i+1}$ forces
$\operatorname{head}(c_i) = \operatorname{tail}(c_{i+1}) = u_{i+1}$, the dart $c_i$ is
$(u_i, u_{i+1})$, so the map is injective (a dart list is determined by its tail list
together with its head list, and the latter is the rotation of the former). Adjacency
$u_i \sim u_{i+1}$ holds because $c_i$ is a dart. The non-backtracking clause of
$c_i \to c_{i+1}$ says $\operatorname{head}(c_{i+1}) \ne \operatorname{tail}(c_i)$, i.e.
$u_{i+2} \ne u_i$. Conversely, any cyclic vertex sequence with these two properties lifts
to a dart word by setting $c_i = (u_i, u_{i+1})$, and the two conditions become exactly the
chain and seam conditions. Combining with Theorem 3.9 gives the count. $\square$

The vertex form makes the nature of the constraint transparent: a closed non-backtracking
walk is an ordinary closed walk avoiding a single *local forbidden pattern*, the pattern
$u_{i+2} = u_i$ at distance two. Everything downstream — including the recursions
conjectured in Section 12 — is inclusion–exclusion on that one pattern.

---

## 4. Small powers, row sums, and growth

### 4.1 The bottom of the sequence

**Proposition 4.1.** $\operatorname{trace}(B^0) = |D(G)| = 2|E| = \sum_{v \in V}\deg(v)$.

*Proof.* $B^0 = I_{D(G)}$, whose trace is the number of darts; the count of darts is the
degree sum by double counting. $\square$

**Proposition 4.2.** $\operatorname{trace}(B) = 0$ for every graph.

*Proof.* The diagonal entries are $B_{d,d} = 0$ by Lemma 3.4(i). $\square$

**Proposition 4.3.** $\operatorname{trace}(B^2) = 0$ for every graph.

*Proof.* $(B^2)_{d,d} = \sum_{f} B_{d,f} B_{f,d}$, and each product vanishes by Lemma
3.4(ii). $\square$

Equivalently, by Theorem 3.7, *no graph has a rooted closed non-backtracking walk of length
$1$ or $2$*. Contrast the adjacency matrix, where $\operatorname{trace}(A^2) = 2|E|$: the
entire length-two closed-walk count of a graph consists of backtracks.

### 4.2 Length three

**Definition 4.4.** An *ordered triangle* of $G$ is a triple $(a,b,c) \in V^3$ with
$a \sim b$, $b \sim c$, $c \sim a$.

The three adjacencies force $a,b,c$ pairwise distinct (a simple graph has no loops), so
ordered triangles are exactly the $3! = 6$ orderings of each triangle
$\{a,b,c\} \subseteq V$; hence
$\#\{\text{ordered triangles}\} = 6 \cdot \#\{\text{triangles}\}$.

**Theorem 4.5.** $\operatorname{trace}(B^3) = \#\{\text{ordered triangles of } G\} = 6\cdot\#\{\text{triangles of } G\}$.

*Proof sketch.* By Theorem 3.9 we count cyclic non-backtracking words of three darts. Given
an ordered triangle $(a,b,c)$, the word $\big((a,b),(b,c),(c,a)\big)$ satisfies the chain
and seam conditions: composability is clear, and the non-backtracking clauses read
$c \ne a$, $a \ne b$, $b \ne c$, all true. This assignment is injective (the triangle is
read off from the tails). It is surjective: a cyclic word of three darts has, by the vertex
form of Theorem 3.11, a vertex sequence $(u_1,u_2,u_3)$ with all three consecutive
adjacencies and $u_3 \ne u_1$, $u_1 \ne u_2$, $u_2 \ne u_3$ — an ordered triangle.
$\square$

### 4.3 Row sums

**Theorem 4.6 (Row-sum identity).** For every dart $d$,
$$\sum_{e \in D(G)} B_{d,e} \;=\; \deg(\operatorname{head}(d)) - 1 .$$

*Proof.* Write $d = (u,v)$. The darts $e$ with $d \to e$ are exactly the darts with tail
$v$ other than $(v,u)$. There are $\deg(v)$ darts with tail $v$, one per neighbour of $v$,
and exactly one of them, namely $(v,u)$, is excluded. $\square$

**Corollary 4.7.** If $G$ is $(q+1)$-regular, every row of $B$ sums to $q$.

**Theorem 4.8 (Growth bound).** If $G$ is $(q+1)$-regular then for all $n \ge 0$,
$$\operatorname{trace}(B^n) \;\le\; 2|E| \cdot q^{n} .$$

*Proof.* Corollary 4.7 and Proposition 2.6 with $|\iota| = |D(G)| = 2|E|$. $\square$

The exponential rate is $q$, not $q+1$: at each step the walker forfeits one of its
$q+1$ options. The associated spectral radius scale $\sqrt{q}$ is the Alon–Boppana /
Ramanujan threshold.

---

## 5. Parity: the reversal involution

**Definition 5.1.** For a list of darts $\ell = (d_0,\dots,d_n)$, define its *reversal*
$$\overline{\ell} := (d_n^{-1}, d_{n-1}^{-1}, \dots, d_0^{-1}).$$

**Lemma 5.2.** $\overline{\,\overline{\ell}\,} = \ell$, and if $\ell \in \mathcal{C}_n(G)$
then $\overline{\ell} \in \mathcal{C}_n(G)$ and $\overline{\ell} \ne \ell$.

*Proof sketch.* Involutivity is immediate since $(d^{-1})^{-1} = d$ and reversing a list
twice is the identity. Stability: from Definition 3.2, $d \to e$ if and only if
$e^{-1} \to d^{-1}$ (both say head-of-first = tail-of-second and no immediate reversal),
so the chain condition survives reversal; the length is unchanged; and the closing
condition $d_n = d_0$ becomes $d_0^{-1} = d_n^{-1}$, again a closing condition.
Fixed-point-freeness: if $\overline{\ell} = \ell$ then comparing first entries gives
$d_0 = d_n^{-1} = d_0^{-1}$, contradicting $d \ne d^{-1}$ for darts of a loopless graph.
$\square$

**Theorem 5.3 (Evenness).** For every finite simple graph $G$ and every $n \ge 0$, the
integer $\operatorname{trace}(B^n)$ is even.

*Proof.* By Theorem 3.7 it suffices to show $|\mathcal{C}_n(G)|$ is even. By Lemma 5.2,
$\ell \mapsto \overline{\ell}$ is a fixed-point-free involution of the finite set
$\mathcal{C}_n(G)$; its orbits all have size exactly $2$, so they partition the set into
pairs. $\square$

(An efficient way to formalise the last step: summing the constant $1$ over the set in
$\mathbb{Z}/2$, and pairing terms via the involution, shows the cardinality is $0$ modulo
$2$.)

**Theorem 5.4 (Algebraic source: reversal intertwines $B$ with its transpose).** Let
$J : D(G) \to D(G)$ be the permutation $d \mapsto d^{-1}$, regarded as a permutation matrix
(so $J = J^{-1}$). Then
$$J\,B\,J \;=\; B^{\mathsf T}, \qquad\text{equivalently}\qquad B_{d^{-1},e^{-1}} = B_{e,d} \ \text{ for all } d,e .$$

*Proof.* The entry identity is precisely the equivalence $e^{-1} \to d^{-1} \iff d \to e$
used in Lemma 5.2, and conjugation by the permutation matrix $J$ is the corresponding
simultaneous relabelling of rows and columns. $\square$

Theorem 5.4 says $B$ is similar to $B^{\mathsf T}$ *by an explicit involution*, not merely
by the abstract similarity that holds for every square matrix. It is the structural reason
behind the evenness of the traces and behind the symmetry of the non-backtracking spectrum.

---

## 6. Acyclicity

**Theorem 6.1 (Cycles force positive trace).** If $p$ is a cycle in $G$ of length $m$ —
that is, a closed walk of length $m \ge 3$ whose vertices $u_1,\dots,u_m$ are pairwise
distinct and consecutively adjacent cyclically — then
$$\operatorname{trace}(B^m) \ge 1 .$$

*Proof sketch.* By the vertex form (Theorem 3.11) it suffices to exhibit one admissible
cyclic vertex sequence of length $m$. Take $(u_1,\dots,u_m)$ itself. Adjacency holds by
hypothesis. The non-backtracking condition $u_{i+2} \ne u_i$ holds because the $u_j$ are
pairwise distinct and $m \ge 3$ ensures $i+2 \not\equiv i \pmod m$. $\square$

**Theorem 6.2 (Forests have vanishing traces).** If $G$ contains no cycle then
$\operatorname{trace}(B^n) = 0$ for every $n \ge 1$; equivalently
$\mathcal{C}_n(G) = \emptyset$ for $n \ge 1$.

*Proof sketch.* Suppose $c = (c_1,\dots,c_n) \in \mathcal{Z}_n(G)$ with $n \ge 1$. Two
steps.

*Step 1: darts reassemble into a walk.* A list of darts in which consecutive darts are
composable ($\operatorname{head}(c_i) = \operatorname{tail}(c_{i+1})$) is the dart list of a
genuine walk in $G$ from $\operatorname{tail}(c_1)$ to $\operatorname{head}(c_n)$; this is
proved by induction on the list, prepending one edge at a time. Because $c$ satisfies the
seam condition, $\operatorname{head}(c_n) = \operatorname{tail}(c_1)$, so the resulting walk
$p$ is *closed*, of length $n \ge 1$.

*Step 2: consecutive edges differ.* If $d \to e$ then the underlying edges of $d$ and $e$
are distinct. Indeed, equality of the unordered pairs $\{u,v\}$ and $\{v,y\}$ forces either
$u = v$ (excluded: no loops) or $y = u$ (excluded: the non-backtracking clause). Hence the
edge list of $p$ has distinct consecutive entries.

Now invoke the characterisation of acyclic graphs: in a forest, a walk whose consecutive
edges are distinct is a *path* (no repeated vertices). A closed path has length $0$,
contradicting $n \ge 1$. Therefore $\mathcal{Z}_n(G) = \emptyset$, and by Theorem 3.9,
$\operatorname{trace}(B^n) = 0$. $\square$

**Theorem 6.3 (Acyclicity criterion).** For a finite simple graph $G$,
$$G \text{ is acyclic (a forest)} \iff \operatorname{trace}(B^n) = 0 \text{ for all } n \ge 1 .$$

*Proof.* ($\Rightarrow$) is Theorem 6.2. ($\Leftarrow$): contrapositively, if $G$ has a
cycle of length $m$ then $\operatorname{trace}(B^m) \ge 1$ by Theorem 6.1, and $m \ge 3
\ge 1$. $\square$

**Corollary 6.4.** A forest has no rooted closed non-backtracking walk of any positive
length. (For $n = 0$ the count is $2|E|$, by Proposition 4.1.)

---

## 7. Girth

Recall the *girth* $g(G)$ of a graph containing a cycle is the least length of a cycle in
it; forests have girth $\infty$.

**Theorem 7.1 (No trace below the girth).** If $n \ge 1$ and
$\operatorname{trace}(B^n) \ne 0$, then $g(G) \le n$.

*Proof sketch.* By Theorem 3.9 there is $c \in \mathcal{Z}_n(G)$, which by Step 1 and Step 2
of the proof of Theorem 6.2 yields a closed walk $p$ of length $n \ge 1$ whose consecutive
edges are distinct. Let $H \subseteq G$ be the subgraph spanned by the edges of $p$. Then
$H$ cannot be acyclic: were it, the walk $p$ — which lives in $H$ and has distinct
consecutive edges — would be a path, hence of length $0$. So $H$ contains a cycle, of
length at most $|E(H)| \le n$; since $H \subseteq G$, this cycle is a cycle of $G$, whence
$g(G) \le n$. $\square$

**Corollary 7.2.** If $1 \le n < g(G)$ then $\operatorname{trace}(B^n) = 0$.

**Theorem 7.3 (Girth criterion).** If $G$ contains a cycle then
$$g(G) = \min\{\, n \ge 1 \;:\; \operatorname{trace}(B^n) \ne 0 \,\}.$$

*Proof.* The set is nonempty: taking a shortest cycle, of length $g(G) \ge 3$, Theorem 6.1
gives $\operatorname{trace}(B^{g(G)}) \ge 1$, so $g(G)$ belongs to the set. And every
element $n$ of the set satisfies $n \ge g(G)$ by Theorem 7.1. Hence $g(G)$ is the least
element. $\square$

The girth criterion turns a combinatorial search over cycles into the evaluation of a
sequence of matrix traces (Section 10).

**Theorem 7.4 (Multiplicity at the girth).** If $p$ is a cycle of length $m$ in $G$, then
$$2m \le \operatorname{trace}(B^m).$$
In particular, if $G$ contains a cycle,
$$2\,g(G) \;\le\; \operatorname{trace}\!\left(B^{\,g(G)}\right).$$

*Proof sketch.* Let $c \in \mathcal{Z}_m(G)$ be the dart word of the cycle $p$ (the darts
$(u_i,u_{i+1})$ read around the cycle). By Proposition 3.10 the $2m$ words
$$\sigma^i c \quad (0 \le i < m), \qquad \sigma^i \overline{c} \quad (0 \le i < m)$$
all lie in $\mathcal{Z}_m(G)$. They are pairwise distinct. Indeed:
* the $m$ rotations $\sigma^i c$ are distinct because $c$ has no repeated entry — its darts
  have pairwise distinct tails, the vertices of the cycle — and a list with distinct entries
  has $m$ distinct rotations (comparing first entries separates them);
* likewise the $m$ rotations of $\overline{c}$ are distinct;
* no rotation of $c$ equals a rotation of $\overline{c}$: the entries of $c$ are darts
  traversing the cycle in one orientation, while those of $\overline{c}$ traverse it in the
  other, so the two lists have disjoint entry sets (a dart and its reverse are distinct, and
  a cycle of length $\ge 3$ uses each edge once).

Hence $|\mathcal{Z}_m(G)| \ge 2m$, and Theorem 3.9 concludes. The second statement applies
this to a shortest cycle. $\square$

The bound is sharp: for the cycle graph $C_m$ the unique cycle contributes and nothing else
does, giving $\operatorname{trace}(B^m) = 2m$ exactly. When there are several shortest
cycles the bound is strict, and the data suggest the exact formula
$\operatorname{trace}(B^{g}) = 2g \cdot \#\{\text{cycles of length } g\}$ (Section 12,
Problem 3): for the Petersen graph, $g = 5$ with $12$ pentagons, and indeed
$\operatorname{trace}(B^5) = 120 = 2\cdot 5\cdot 12$; for $K_{3,3}$, $g = 4$ with nine
quadrilaterals, and $\operatorname{trace}(B^4) = 72 = 2\cdot 4\cdot 9$; for $K_4$, $g=3$
with four triangles, $\operatorname{trace}(B^3) = 24 = 2 \cdot 3 \cdot 4$.

---

## 8. Monotonicity under subgraph inclusion

**Theorem 8.1.** Let $H \subseteq G$ be graphs on the same vertex set (that is,
$u \sim_H v \Rightarrow u \sim_G v$), with Hashimoto matrices $B_H$ and $B_G$. Then for
every $n \ge 0$,
$$\operatorname{trace}(B_H^{\,n}) \;\le\; \operatorname{trace}(B_G^{\,n}).$$

*Proof sketch.* For $n = 0$ both sides are the respective dart counts and
$|D(H)| \le |D(G)|$ since every dart of $H$ is a dart of $G$. For $n \ge 1$, the inclusion
$D(H) \hookrightarrow D(G)$ is injective and preserves and reflects the non-backtracking
relation, because the relation is defined purely in terms of the endpoints of the darts and
does not refer to the ambient edge set. Applying it entrywise therefore maps
$\mathcal{Z}_n(H)$ injectively into $\mathcal{Z}_n(G)$ (injectivity of a map on lists
follows from injectivity of the map on entries). Theorem 3.9 turns the resulting inequality
of cardinalities into the stated inequality of traces. $\square$

We stress that this proof is *combinatorial by necessity*: $B_H$ and $B_G$ are matrices of
different sizes, and entrywise domination of a submatrix does not in general imply
domination of the traces of powers for non-symmetric matrices. The walk interpretation is
what makes the statement accessible.

---

## 9. Worked examples

### 9.1 The triangle $K_3$

$K_3$ has $3$ edges and hence $6$ darts. By Theorem 4.6, every row of $B$ sums to
$\deg - 1 = 1$: each dart has a *unique* legal continuation. Thus $B$ is a permutation
matrix, and since following the unique continuations traverses the triangle in a fixed
orientation, that permutation is a product of two $3$-cycles (one per orientation). Hence
$$B^3 = I_6, \qquad \operatorname{trace}(B^n) = \begin{cases} 6, & 3 \mid n,\\ 0, & \text{otherwise.}\end{cases}$$
Indeed $\operatorname{trace}(B^{3k}) = \operatorname{trace}(I) = 6$; for $n = 3k+1$ and
$n = 3k+2$ the trace reduces to $\operatorname{trace}(B)$ and $\operatorname{trace}(B^2)$
respectively, both zero by Propositions 4.2 and 4.3. The value $6 = 2\cdot 3$ realises
Theorem 7.4 with equality.

### 9.2 The complete graph $K_4$

$K_4$ has $6$ edges, $12$ darts, four triangles and three quadrilaterals. Theorem 4.5
gives $\operatorname{trace}(B^3) = 6 \cdot 4 = 24$, and direct evaluation gives
$\operatorname{trace}(B^4) = 24 = 8 \cdot 3$, each quadrilateral contributing $2\cdot 4 = 8$
words. $K_4$ is $3$-regular, so $q = 2$ and Theorem 4.8 predicts
$\operatorname{trace}(B^n) \le 12 \cdot 2^n$; at $n = 3$ this reads $24 \le 96$.

### 9.3 The pentagon $C_5$

$C_5$ has $5$ edges, $10$ darts, and again each dart has a unique continuation, so $B$ is a
permutation matrix, of order $5$ (two $5$-cycles):
$$B^5 = I_{10}, \qquad \operatorname{trace}(B^n) = \begin{cases} 10, & 5 \mid n,\\ 0, & \text{otherwise } (n \ge 1).\end{cases}$$
The first nonvanishing index is $5 = g(C_5)$, confirming Theorem 7.3, and the value
$10 = 2 \cdot 5$ meets the bound of Theorem 7.4 with equality. More generally
$C_m$ has $\operatorname{trace}(B^n) = 2m$ when $m \mid n$ and $0$ otherwise.

### 9.4 A tree

For the path $P_3 : 0 - 1 - 2$ (four darts), one computes $B^2 = 0$: the non-backtracking
matrix of this tree is nilpotent, so all traces of positive powers vanish, illustrating
Theorem 6.2. In general the Hashimoto matrix of a forest with $\ell$ edges on a longest path
is nilpotent, since a non-backtracking walk in a forest is a path and hence has bounded
length.

### 9.5 The Petersen graph

$3$-regular, $15$ edges, $30$ darts, girth $5$, with exactly $12$ pentagons. The trace
sequence begins
$$30,\ 0,\ 0,\ 0,\ 0,\ 120,\ 120, \dots$$
for $n = 0,1,\dots,6$. The first nonzero index is $5$, as Theorem 7.3 requires, and
$120 = 2 \cdot 5 \cdot 12$ — the twelve shortest cycles, each counted with multiplicity
$2 \cdot 5$. The growth bound with $q = 2$ gives $\operatorname{trace}(B^5) \le 30 \cdot 32
= 960$.

---

## 10. Algorithms

### 10.1 Building the matrix

Enumerating darts and testing Definition 3.2 pairwise builds $B$ in
$O\big((2|E|)^2\big)$ time and space. In sparse form the row of $(u,v)$ has
$\deg(v) - 1$ nonzeros, so $B$ has $\sum_{(u,v)} (\deg(v) - 1) = \sum_v \deg(v)^2 - 2|E|$
nonzeros in total; for a $(q+1)$-regular graph this is $2|E|q$.

### 10.2 Trace of a power

Two regimes:

* **Dense, single $n$:** repeated squaring computes $B^n$ in $O\big(\log n \cdot (2|E|)^{\omega}\big)$
  arithmetic operations, $\omega$ the matrix-multiplication exponent. Entries grow like
  $q^n$, so with exact integers the bit complexity carries an extra factor $O(n \log q)$.
* **Sparse, all $n \le N$:** maintain the sparse product $B^k$ iteratively, or — better for
  traces alone — compute $\operatorname{trace}(B^n)$ as $\sum_d (B^n)_{dd}$ by running
  $2|E|$ sparse matrix–vector products of length $n$, giving
  $O\big(N \cdot \operatorname{nnz}(B) \cdot 2|E|\big)$ overall for the whole prefix. For a
  bounded-degree graph this is $O(N |E|^2)$.

### 10.3 Girth by trace search

Theorem 7.3 yields an algorithm: compute $\operatorname{trace}(B), \operatorname{trace}(B^2),
\dots$ and return the first index with a nonzero value; report "forest" if the search passes
$|V|$ without a hit (a graph with a cycle has girth at most $|V|$). Correctness is exactly
Theorem 7.3 plus Theorem 6.3. The cost is dominated by the sparse regime above and is
$O(g \cdot \operatorname{nnz}(B) \cdot 2|E|)$; this is inferior to breadth-first search
($O(|V||E|)$) as a practical girth algorithm, but it is instructive as a *certificate*: a
single nonzero trace at index $n$ certifies $g \le n$, and vanishing traces up to $n$
certify $g > n$.

### 10.4 Verifying the counting theorem

Independent verification is straightforward and is a useful sanity check on any
implementation: enumerate all rooted closed non-backtracking walks of length $n$ by
depth-first search from each dart, following only legal successors and accepting the path
when it has $n+1$ darts and returns to its root. The enumeration costs
$O\big(2|E| \cdot q^n\big)$ in the regular case — precisely the bound of Theorem 4.8, which
is therefore also the complexity statement for the brute-force side.

---

## 11. Discussion and applications

### 11.1 The Ihara zeta function

For a finite graph, the Ihara zeta function is
$$\zeta_G(u) = \prod_{[\gamma]} \left(1 - u^{\ell(\gamma)}\right)^{-1},$$
the product over equivalence classes (under rotation) of primitive closed non-backtracking
cycles. Taking the logarithmic derivative converts the product over classes into a sum over
all closed non-backtracking walks, which Theorem 3.7 identifies with
$\sum_{n \ge 1} \operatorname{trace}(B^n) u^n$. The consequent identity
$$\sum_{n \ge 1} \frac{\operatorname{trace}(B^n)}{n} u^n = -\log\det(I - uB), \qquad \zeta_G(u) = \det(I - uB)^{-1},$$
reduces an infinite Euler product to a finite determinant, and Ihara's theorem further
collapses that determinant for $(q+1)$-regular graphs to
$$\det(I - uB) = (1 - u^2)^{|E| - |V|}\,\det\!\left(I - uA + qu^2 I\right),$$
an identity between a $2|E| \times 2|E|$ determinant and a $|V| \times |V|$ one. Every step
of this chain uses the counting theorem as its combinatorial input.

### 11.2 Non-backtracking spectra in inference

The eigenvalues of $B$ govern the mixing of the non-backtracking random walk. In sparse
random graphs with heavy-tailed degrees, the adjacency matrix's leading eigenvectors
localise on hubs; the Hashimoto matrix suppresses this because the walk cannot dwell on a
hub by oscillating across a single edge. Consequently non-backtracking spectral methods
detect planted community structure in the sparse stochastic block model down to the
Kesten–Stigum threshold, where adjacency-based methods fail. Theorem 4.8 is the
deterministic shadow of the relevant growth estimate: the branching factor $q$, not the
degree $q+1$, governs the exponential rate.

### 11.3 Structural invariants from a single sequence

Sections 6–8 show that the integer sequence $\big(\operatorname{trace}(B^n)\big)_{n \ge 1}$
is a genuine graph invariant with a legible dictionary:

| Feature of the sequence | Meaning for the graph |
|---|---|
| $\operatorname{trace}(B^0) = 2\lvert E \rvert$ | number of darts |
| $\operatorname{trace}(B^1) = \operatorname{trace}(B^2) = 0$ | holds universally |
| $\operatorname{trace}(B^3)$ | $6 \times$ number of triangles |
| all terms even | dart reversal pairs walks; $JBJ = B^{\mathsf T}$ |
| identically zero | $G$ is a forest |
| index of first nonzero term | $g(G)$ |
| value at that index, $\ge 2g$ | shortest cycles counted $2g$ times each |
| nondecreasing under $H \subseteq G$ | monotone in the edge set |

It is worth noting what the sequence does *not* see directly: it is insensitive to isolated
vertices and, more substantially, to the tree parts of the graph — any pendant subtree
contributes nothing to any positive power. The non-backtracking trace sequence is an
invariant of the *2-core*, and two graphs with the same 2-core have identical sequences
except at $n = 0$.

### 11.4 On the necessity of working with darts

The vertex form (Theorem 3.11) might suggest that darts are dispensable. They are not, for
the counting theorem itself: the constraint $u_{i+2} \ne u_i$ is not a condition on
consecutive terms of the vertex sequence and therefore is not encoded by any matrix indexed
by vertices. Passing to darts makes the constraint *local*, i.e. a condition on consecutive
terms — and locality is exactly what a matrix can express. The price is a state space of
size $2|E|$ rather than $|V|$; the reward is that every combinatorial question becomes a
question about $\operatorname{trace}(B^n)$.

---

## 12. Open problems and future directions

The following three problems are the natural next steps; each is stated precisely and each
is testable against the machinery developed above.

### Problem 1: A Chebyshev-like recursion for non-backtracking walk matrices

For a $(q+1)$-regular graph $G$ with adjacency matrix $A$, let $A_m \in \mathbb{N}^{V \times V}$
be the matrix whose $(u,v)$ entry counts *non-backtracking walks of length $m$ from $u$ to
$v$*.

> **Conjecture.** $A_1 = A$, $A_2 = A^2 - (q+1)I$, and
> $$A_{m+1} = A\,A_m - q\,A_{m-1} \quad (m \ge 2).$$
> Consequently $A_m = P_m(A)$ for an explicit Chebyshev-like polynomial $P_m$, and
> $\operatorname{trace}(B^m)$ is a fixed linear combination of the numbers
> $\operatorname{trace}(A^k)$, $k \le m$.

*Why it should be true.* Theorem 3.11 exhibits closed non-backtracking walks as ordinary
walks subject to a single forbidden local pattern, $u_{i+2} = u_i$. Inclusion–exclusion on
that one pattern should close after two correction terms rather than generating an infinite
hierarchy, and the correction coefficient $q$ is exactly the row sum from Theorem 4.6.
*Why now.* The vertex form and the row-sum identity are precisely the two ingredients such
a recursion consumes, and both are established here.

### Problem 2: The Ihara determinant identity from the trace generating function

> **Conjecture.** For every finite graph,
> $$\sum_{n \ge 1} \frac{\operatorname{trace}(B^n)}{n}\,u^n \;=\; -\log\det(I - uB),$$
> and for $(q+1)$-regular graphs the right-hand side equals
> $$-\log\left[(1-u^2)^{|E|-|V|}\,\det\!\left(I - uA + qu^2 I\right)\right].$$

*Why it should be true.* The counting theorem converts the analytic identity into a purely
combinatorial statement about cyclic words, and the hard direction becomes a bijection
between cyclic non-backtracking words of length $n$ and multisets of primitive cycles whose
total length is $n$.
*Why now.* Proposition 3.10 establishes that the set of cyclic non-backtracking words is
stable under both rotation and reversal, which is exactly the group action needed for the
primitive-cycle decomposition; what remains is orbit–stabiliser bookkeeping over the
rotation action, with the primitive words being those of trivial stabiliser.

### Problem 3: Exact multiplicity at the girth

> **Conjecture.** For a graph containing a cycle, with $g = g(G)$,
> $$\operatorname{trace}(B^{\,g}) \;=\; 2g \cdot \#\{\text{cycles of length } g\},$$
> i.e. the first nonzero term of the trace sequence counts shortest cycles with
> multiplicity exactly $2g$.

*Why it should be true.* Theorem 7.4 supplies the inequality $\ge 2g$ from a single cycle,
and the orbit argument there extends to a family of shortest cycles once one knows their
dart words have pairwise disjoint rotation–reversal orbits. The remaining content is the
converse: every cyclic non-backtracking word of length exactly $g$ must be the dart word of
a cycle, since a shorter closed structure is excluded by minimality of $g$ and a
non-injective vertex sequence of length $g$ would exhibit a strictly shorter cycle.
*Evidence.* The identity is confirmed on the pentagon ($2\cdot 5 \cdot 1 = 10$), on $K_4$
($2\cdot 3\cdot 4 = 24$), on $K_{3,3}$ ($2 \cdot 4 \cdot 9 = 72$), and on the Petersen
graph ($2\cdot 5\cdot 12 = 120$).

### Further directions

Beyond these, three lines seem promising.

* **Weighted and directed generalisations.** Replacing the zero-one matrix by a weighted
  one turns the trace formula into a generating identity for weighted cycles; the
  acyclicity and girth criteria should survive for positive weights.
* **Spectral consequences of $JBJ = B^{\mathsf T}$.** Theorem 5.4 constrains the Jordan
  structure of $B$; making this explicit would give a self-contained account of the
  symmetry of the non-backtracking spectrum without invoking the Ihara factorisation.
* **Quantitative girth certificates.** Corollary 7.2 gives a certificate for $g > n$ from
  vanishing traces. Bounding the numerical precision needed to certify vanishing would turn
  this into a practical randomised girth-lower-bound algorithm via trace estimators.

---

## 13. Conclusion

The non-backtracking trace formula
$$\operatorname{trace}(B^n) = \#\{\text{rooted closed non-backtracking walks of length } n\}$$
is elementary, but it is a hinge. On one side of it lies linear algebra: powers, traces,
eigenvalues, determinants. On the other lies the cycle structure of a graph: triangles,
girth, acyclicity, multiplicity. The proof requires walk counting for a general directed
relation, because the non-backtracking succession relation is asymmetric by nature, and
once that groundwork is laid the theorem itself is a two-line consequence. What follows
from it is not: the acyclicity criterion, the girth criterion, the multiplicity bound at
the girth, the parity of every trace with its algebraic source in dart reversal, and the
monotonicity of the whole sequence under adding edges are each substantive statements about
graphs, and each is most naturally proved by passing through the walk interpretation.

The general lesson is worth stating plainly: a global constraint that is not a function of
the current state can often be made local by enlarging the state. Darts are the enlargement
that makes non-backtracking local; a matrix is what locality buys; and everything above is
what the matrix pays out.
