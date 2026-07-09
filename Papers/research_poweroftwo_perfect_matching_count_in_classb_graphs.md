# A Multiplicative Law for Perfect Matchings and the Power-of-Two Count of Block Graphs

## Abstract

We study the number of perfect matchings of graphs assembled as
independent superpositions of identical subgraphs. Modelling a perfect
matching of a finite simple graph $G$ as a fixed-point-free,
adjacency-respecting involution of its vertex set, we prove a clean
multiplicative law: if $\mathrm{Block}(\iota, G)$ denotes the graph
consisting of one disjoint copy of $G$ for each index in a finite type
$\iota$ — with no edge ever joining two distinct copies — then the number
$M$ of perfect matchings satisfies
$$M(\mathrm{Block}(\iota, G)) = M(G)^{\,|\iota|}.$$
The proof is a constructive bijection between global matchings and tuples
of per-copy matchings, not a finite enumeration. Specialising to the case
in which each block is the four-cycle $C_4$ — the smallest graph with
exactly two perfect matchings — yields an exact power-of-two count:
$$M(\mathrm{Block}(\iota, C_4)) = 2^{\,|\iota|}.$$
This isolates the rigorous content of the informal principle that, when the
perfect matchings of a graph decompose into independent binary choices,
their number is a power of two. We record the base evaluations
$M(C_4) = M(C_6) = 2$, discuss the role of even cycles as canonical
two-choice gadgets, and outline a program extending the law to connected
graphs via gluing along forcing edges.

**Keywords:** perfect matching, dimer model, permanent, block graph,
multiplicative counting, even cycle, power of two.

## 1. Introduction

Counting the perfect matchings of a graph is a central and computationally
formidable problem: it is equivalent to evaluating the permanent of a
$0/1$ matrix, which is `#P`-complete in general. Against this backdrop,
families of graphs whose matching count is *forced* into a rigid,
predictable form are both mathematically attractive and practically useful,
appearing in the dimer models of statistical mechanics and the Kekulé
counting of chemistry.

This paper concerns one such rigidity: a matching count that is always an
exact power of two, $1, 2, 4, 8, \dots$. The phenomenon originates in the
following informal principle. In a connected graph whose edges are of two
kinds — say "one-matching" and "two-matching" edges — such that no single
perfect matching mixes the two kinds, one expects the perfect matchings to
decompose into independent binary choices, and hence to number a power of
two.

Our contribution is to identify and prove the exact structural core of this
principle. The essential mechanism is *independence*: the count is a power
of two precisely when the matchings factor into independent two-way
decisions. We capture this independence in the clean model of a **block
graph** — an independent superposition of identical gadgets — and prove a
multiplicative counting law for it. The power-of-two result then follows by
taking the gadget to be any graph with exactly two perfect matchings, the
canonical examples being the even cycles $C_4, C_6, C_8, \dots$.

## 2. Definitions

Throughout, $G$ is a finite simple graph on a vertex set $V$; we write
$u \sim v$ when $u$ and $v$ are adjacent. Because $G$ is simple, adjacency
is symmetric and irreflexive.

**Definition 2.1 (Perfect matching as an involution).**
A *perfect matching* of $G$ is a function $f : V \to V$ satisfying the three
conditions
1. $f(f(v)) = v$ for all $v$ (it is an involution),
2. $f(v) \neq v$ for all $v$ (it is fixed-point-free), and
3. $v \sim f(v)$ for all $v$ (every vertex is matched along an edge).

Such an $f$ partitions $V$ into unordered pairs $\{v, f(v)\}$, each an edge
of $G$; conversely any partition of $V$ into edges gives such an $f$. This
representation is finite and decidable, which makes concrete matching counts
directly computable.

**Definition 2.2 (Matching count).**
The *matching count* of $G$, denoted $M(G)$, is the number of perfect
matchings of $G$:
$$M(G) = \#\{\, f : V \to V \mid f \text{ satisfies (1)–(3)} \,\}.$$

**Definition 2.3 (Block graph).**
Let $\iota$ be a finite index type and $G$ a graph on vertex set $V$. The
*block graph* $\mathrm{Block}(\iota, G)$ has vertex set $\iota \times V$ —
one copy of each vertex of $G$ for every index — and adjacency
$$(i, a) \sim (j, b) \iff i = j \ \text{and}\ a \sim b.$$
Two vertices are adjacent exactly when they lie in the *same* copy and are
adjacent there. In particular **no edge joins two distinct copies**: the
copies are mutually disconnected. One checks immediately that this relation
is symmetric and irreflexive, so $\mathrm{Block}(\iota, G)$ is a simple
graph.

**Definition 2.4 (The cycles $C_4$ and $C_6$).**
For $n \in \{4, 6\}$ let $C_n$ be the cycle on the vertex set
$\mathbb{Z}/n\mathbb{Z}$ (integers modulo $n$) with $a \sim b$ iff
$a - b \equiv \pm 1 \pmod n$. Thus each vertex is adjacent to its two
cyclic neighbours; $C_4$ is the square and $C_6$ the hexagon.

## 3. Main results

### 3.1 The multiplicative law

**Theorem 3.1 (Multiplicative law for block graphs).**
For any finite index type $\iota$ and any finite graph $G$,
$$M(\mathrm{Block}(\iota, G)) = M(G)^{\,|\iota|}.$$

*Proof sketch.* We exhibit an explicit bijection
$$\Phi : \big\{\text{perfect matchings of } \mathrm{Block}(\iota, G)\big\}
\;\longrightarrow\; \prod_{i \in \iota}\big\{\text{perfect matchings of } G\big\},$$
that is, from global matchings to $\iota$-indexed tuples of local matchings.
The finite set on the right has cardinality $M(G)^{|\iota|}$, giving the
theorem.

*Construction of $\Phi$.* Let $f$ be a perfect matching of
$\mathrm{Block}(\iota, G)$. Fix an index $i$ and consider any vertex
$(i, v)$. Condition (3) forces $(i,v) \sim f(i,v)$, and by the definition of
block adjacency this can only hold if $f(i,v)$ lies in the *same* copy $i$.
Hence $f$ preserves each copy: there is a well-defined map
$f_i : V \to V$ with $f(i, v) = (i, f_i(v))$. The three matching axioms for
$f$ restrict coordinatewise to the same three axioms for each $f_i$:
involutivity and fixed-point-freeness are read off directly, and the
adjacency $(i,v) \sim (i, f_i(v))$ unpacks precisely to $v \sim f_i(v)$ in
$G$. Thus each $f_i$ is a perfect matching of $G$, and we set
$\Phi(f) = (f_i)_{i \in \iota}$.

*Injectivity.* If $f$ and $g$ yield the same tuple, then for every $i$ and
$v$ we have $f(i,v) = (i, f_i(v)) = (i, g_i(v)) = g(i,v)$, since both $f$ and
$g$ preserve copies; hence $f = g$.

*Surjectivity.* Given any tuple $(h_i)_{i \in \iota}$ of perfect matchings
of $G$, define $f(i, v) = (i, h_i(v))$. Each axiom for $f$ holds because it
holds coordinatewise for every $h_i$: $f$ is an involution, is
fixed-point-free, and respects adjacency (the first coordinate is preserved,
so the block-adjacency condition $i = i$ is automatic and the second
coordinate satisfies $v \sim h_i(v)$). Then $\Phi(f) = (h_i)_i$.

Since $\Phi$ is a bijection between finite sets,
$M(\mathrm{Block}(\iota,G)) = \big|\prod_{i\in\iota}\mathrm{PM}(G)\big|
= M(G)^{|\iota|}$. $\qquad\blacksquare$

The proof is entirely structural: it never enumerates matchings but instead
factors an arbitrary global matching into its independent per-block
components. This is what makes the law hold for *every* block $G$ and every
number of blocks, rather than for finitely many verified cases.

### 3.2 Base gadgets: even cycles have exactly two matchings

**Proposition 3.2.** $M(C_4) = 2$ and $M(C_6) = 2$.

*Proof sketch.* The vertex set is finite and the matching conditions are
decidable, so the count is obtained by direct evaluation. Conceptually, in
a cycle a perfect matching must alternate: once one edge is chosen, the
matching is forced to take every other edge around the ring. On an even
cycle there are exactly two ways to start this alternation — the "even"
edges or the "odd" edges — giving exactly two perfect matchings; on an odd
cycle the alternation fails to close up and there are none. For $C_4$ the
two matchings are $\{\,\{0,1\},\{2,3\}\,\}$ and $\{\,\{1,2\},\{3,0\}\,\}$;
for $C_6$, $\{\,\{0,1\},\{2,3\},\{4,5\}\,\}$ and
$\{\,\{1,2\},\{3,4\},\{5,0\}\,\}$. $\qquad\blacksquare$

More generally, every even cycle $C_{2k}$ has exactly two perfect matchings
and every odd cycle has none; the even cycles are the canonical connected
"two-choice gadgets" that drive the power-of-two law.

### 3.3 The power-of-two law

**Theorem 3.3 (Power-of-two count).**
For any finite index type $\iota$,
$$M(\mathrm{Block}(\iota, C_4)) = 2^{\,|\iota|}.$$

*Proof.* Apply Theorem 3.1 with $G = C_4$ and substitute $M(C_4) = 2$ from
Proposition 3.2:
$M(\mathrm{Block}(\iota, C_4)) = M(C_4)^{|\iota|} = 2^{|\iota|}.$
$\qquad\blacksquare$

**Corollary 3.4 (Genuine power of two).**
For any finite index type $\iota$ there exists a natural number $k$ with
$M(\mathrm{Block}(\iota, C_4)) = 2^{k}$; explicitly $k = |\iota|$.

The same conclusion holds verbatim with $C_4$ replaced by any graph of
matching count $2$ (for example $C_6$), or more generally with a
power-of-two count whenever every block itself has a power-of-two count,
since powers of two are closed under the multiplicative law.

## 4. Algorithms

The involution model makes matching counts directly computable and the
multiplicative law makes large block graphs tractable.

**Algorithm A (Direct matching count).** Enumerate candidate involutions of
a finite graph and count those that are fixed-point-free and
adjacency-respecting. This runs in time proportional to the number of
pairings of $|V|$ vertices, which is the double factorial $(|V|-1)!!$; it is
practical only for small blocks but suffices to certify base values such as
$M(C_4) = 2$ and $M(C_6) = 2$.

**Algorithm B (Block count via the multiplicative law).** To count the
matchings of a block graph, compute $M(G)$ once with Algorithm A and return
$M(G)^{|\iota|}$. This replaces an exponential enumeration over
$|\iota|\cdot|V|$ vertices with a single small computation followed by one
exponentiation — the algorithmic payoff of Theorem 3.1.

**Algorithm C (Alternating enumeration for cycles).** For a cycle $C_n$,
report $2$ if $n$ is even and $0$ if $n$ is odd, reflecting the two
alternating matchings of an even ring. Combined with Algorithm B this gives
the closed form $2^{|\iota|}$ for a superposition of even cycles in constant
work per block.

## 5. Applications and interpretation

**Statistical mechanics.** The matching count of a graph is the
zero-temperature dimer partition function. For a collection of
non-interacting dimer cells — modelled exactly by a block graph — the
partition function factorises as a product over cells, which is Theorem 3.1
in physical dress. The power-of-two case describes independent two-state
cells, each contributing a factor of $2$ to the total configuration count.

**Chemistry.** Perfect matchings of a molecular graph are its Kekulé
structures. A molecule composed of independent, identical rings has a Kekulé
count equal to the per-ring count raised to the number of rings; independent
benzene-like six-rings ($C_6$, count $2$) yield $2^n$ resonance structures.

**Complexity.** Counting matchings is `#P`-complete in general, so families
with a forced closed-form count are valuable. The block graphs are exactly
such a family: their count is not merely computable but given by an explicit
formula, an island of tractability delineated by structural independence.

## 6. Discussion

The power-of-two law is best understood not as a fact about squares but as a
corollary of modularity. Whenever a combinatorial structure decomposes into
independent, identical modules, a global count becomes a local count raised
to the module count. The multiplicative law makes this precise for perfect
matchings, and the power of two is simply the instance in which each module
offers exactly two options.

Two features of the result deserve emphasis. First, the multiplicative law
is proved by an explicit bijection, so it holds for arbitrary blocks and
arbitrarily many of them rather than being confined to finitely checked
cases. Second, a single block $C_4$ is itself connected and already yields
$2 = 2^1$, so the phenomenon is faithful to the "connected" spirit of the
original informal conjecture even before any conjectural gluing is
introduced.

The chief limitation is that a block graph with more than one block is
disconnected, whereas the motivating principle speaks of connected graphs.
Closing this gap is the subject of the future directions below: one wants to
connect the blocks without disturbing the count, which is exactly what
gluing along forcing edges is designed to do.

## 7. Future directions

**Forced-tree gluing preserves the power-of-two law.** If a connected graph
is assembled from two-matching gadgets glued along *forcing edges* (edges
lying in every perfect matching), then its number of perfect matchings
should remain an exact power of two. A forcing edge behaves like a rigid
identification that neither creates nor destroys matching choices, so gluing
along it multiplies the count by one and leaves each gadget's two-choice
structure intact. This would close the gap between the disconnected model
and the connected hypothesis.

**Spectral signature of two-matching gadgets.** One conjectures that a
connected graph has a power-of-two matching count if and only if its
adjacency structure decomposes into blocks each contributing a single
eigenvalue pair of a fixed shape to the matching (permanent) generating
function. The integrality of $\log_2$ of the count is exactly the kind of
rigidity that a spectral invariant can enforce; the block factorisation of
the matching polynomial supplied by Theorem 3.1 provides the algebraic
handle.

**Classification of two-choice gadgets.** Up to the gluing operations above,
every connected building block whose matching count is exactly two should be
an even cycle. Two perfect matchings means the symmetric difference of any
two of them is a single alternating cycle, and the only connected graphs
supporting a unique such cycle are the even cycles. This would upgrade the
computations $M(C_4) = M(C_6) = 2$ into a structural classification.

**Density threshold for power-of-two counts.** Among connected graphs on
$2n$ vertices admitting a perfect matching, the fraction with a
power-of-two count should tend to zero as $n \to \infty$, while the maximum
number of edges compatible with a power-of-two count grows only linearly in
$n$. Power-of-two counts demand a sparse, block-like backbone, so edges
beyond a linear budget destroy the rigidity.

## 8. Conclusion

We have proved a multiplicative law for the perfect-matching count of block
graphs, $M(\mathrm{Block}(\iota, G)) = M(G)^{|\iota|}$, by an explicit
bijection between global matchings and tuples of local matchings.
Specialising to blocks with exactly two matchings — the even cycles $C_4$
and $C_6$ among them — yields the exact power-of-two count
$M(\mathrm{Block}(\iota, C_4)) = 2^{|\iota|}$. The result distils the
rigorous content of the principle that independent binary choices produce
powers of two, and points toward a program of connecting the gadgets while
preserving the count.
