# The Shape of a Proof: How Geometry Counts the Islands in a Network

## A number hiding in plain sight

Imagine you are handed an enormous tangle of dependencies — thousands of
mathematical statements, each leaning on a handful of others. Some clusters of
statements are tightly woven together; others float off on their own, connected
to nothing. If someone asked you a single, deceptively simple question — *how
many separate islands are there in this archipelago of ideas?* — you would
probably start tracing connections by hand, coloring in one island at a time.

There is a more surprising way to get the answer. Instead of walking the
network, you can *listen to its vibrations*. Encode the whole structure as a
matrix, study the way functions can sit on top of it, and a single integer falls
out — the number of islands — without ever explicitly chasing a single path.
That integer is what we will call the **spectral modular signature** of the
network, and the precise theorem that pins it down is the subject of this
article.

The motivation comes from an ambitious dream: predicting how *hard* a
mathematical theorem is to prove from the *geometry* of its dependencies. Modern
formal mathematics libraries are gigantic dependency networks. If difficulty
leaves a geometric fingerprint, we ought to be able to read it off the network's
shape rather than by brute-force search. The result below is the rigorous,
fully verified cornerstone of that program: the exact statement that the
simplest geometric invariant of a network — a dimension computed from linear
algebra — counts its connected pieces on the nose.

## Functions that refuse to change

Let us set the stage with the cleanest possible object: a **finite simple
graph**. Picture a finite set $V$ of vertices and a symmetric, loop-free
relation telling us which pairs of vertices are joined by an edge. Write
$u \sim v$ when $u$ and $v$ are adjacent.

Now consider all the ways of assigning a real number to each vertex — every
function $f : V \to \mathbb{R}$. These functions form a vector space: you can add
two of them, or scale one by a constant, and you still have a function on the
vertices. Among all such functions, single out the ones that are *flat across
every edge*. Formally, $f$ belongs to the **harmonic kernel** $\mathcal{H}(G)$
exactly when

$$ u \sim v \implies f(u) = f(v) \quad \text{for all vertices } u, v. $$

In words: whenever two vertices are directly connected, the function must take
the same value on both. This is a kind of "no tension across an edge"
condition. It is the discrete shadow of a *harmonic* function in analysis —
a function with no internal stress, no place where it is being pulled in two
directions at once.

These flat functions form a subspace of all functions, because the flatness
condition is preserved by addition and scaling: if $f$ and $g$ are both flat
across every edge, so is $f + g$, and so is $cf$ for any constant $c$. The
zero function is trivially flat. So $\mathcal{H}(G)$ is a genuine vector
space, and it has a dimension — a single number measuring how much freedom you
have when building a function that never changes across an edge.

## Flatness spreads

Here is the first key insight, and it is the engine of everything that follows.
The flatness condition is stated only for *adjacent* vertices, but it
propagates. Suppose $f$ is flat across every edge, and suppose you can walk from
vertex $u$ to vertex $v$ along a path $u = x_0 \sim x_1 \sim \cdots \sim x_k = v$.
Step by step, $f(x_0) = f(x_1) = \cdots = f(x_k)$, so $f(u) = f(v)$. A flat
function is therefore constant along *any* walk, not just across single edges.

In the formal development this is the lemma that a harmonic-kernel element is
constant along every walk, strengthened to the statement that membership in the
harmonic kernel is *equivalent* to being constant on every **reachable** pair of
vertices — two vertices that can be joined by some walk. The local condition
(flat across each edge) and the global condition (constant on each connected
piece) are one and the same.

This means a flat function cannot tell apart any two vertices that live on the
same island. The only freedom it has is to pick *one* value per island. Choose a
real number for each connected component, and you have completely determined a
flat function; conversely, every flat function arises this way.

## The dictionary between flat functions and islands

That observation can be upgraded from an analogy to an exact, structure-
preserving correspondence — a **linear isomorphism**. Let $\pi_0(G)$ denote the
set of connected components (the "islands") of $G$. There is a perfect dictionary

$$ \mathcal{H}(G) \;\cong\; \big(\pi_0(G) \to \mathbb{R}\big), $$

between flat functions on the vertices and arbitrary functions on the set of
islands. In one direction, a flat function $f$ descends to a function on islands
by reading off its single value on each island. In the other, any assignment of
a number to each island pulls back to a flat function on the vertices, by giving
every vertex the number attached to its island; this pullback is automatically
flat because adjacent vertices share an island. The two operations undo each
other exactly, and both respect addition and scaling — so they constitute an
isomorphism of vector spaces, not merely a matching of sizes.

The payoff is immediate. Two isomorphic vector spaces have the same dimension.
The space of functions on a finite set with $n$ elements has dimension $n$ — you
freely choose one number per element. Therefore the dimension of the harmonic
kernel equals the number of islands:

$$ \dim_{\mathbb{R}} \mathcal{H}(G) \;=\; \#\,\pi_0(G). $$

We christen the left-hand side the **spectral modular signature** of $G$, written
$\mathrm{specModSig}(G)$. The central theorem — the *component-kernel theorem* —
is the clean equation

$$ \mathrm{specModSig}(G) \;=\; \#\,\pi_0(G): $$

the signature of a graph is exactly its number of connected components.

## Why "spectral"?

The word *spectral* signals where this fits in a larger story. There is a famous
matrix attached to any graph, the **combinatorial Laplacian** $L = D - A$, where
$A$ is the adjacency matrix (a $1$ wherever two vertices are joined) and $D$ is
the diagonal matrix of vertex degrees. The Laplacian measures local
disagreement: the quantity $f^\top L f$ equals $\sum_{u \sim v} (f(u) - f(v))^2$,
a sum of squared differences across edges. This number is zero precisely when
$f$ is flat across every edge — that is, precisely when $f$ lies in the harmonic
kernel.

So the harmonic kernel is exactly the *null space* of the Laplacian, and its
dimension is the Laplacian's **nullity**. A celebrated fact in spectral graph
theory states that the multiplicity of the eigenvalue $0$ of the Laplacian equals
the number of connected components. The component-kernel theorem is the rigorous,
coordinate-free heart of that fact: it isolates the part of the statement that is
pure linear algebra and combinatorics, with no matrices required. The bridge to
the matrix picture is a re-encoding rather than a new theorem — once you know the
kernel *is* the harmonic kernel, the spectral statement becomes literally true.

## What the signature tells you

From the single equation $\mathrm{specModSig}(G) = \#\,\pi_0(G)$, a family of
sharp facts follows, each of which has been formally verified.

**The signature is never zero when there is anything to talk about.** If the
graph has at least one vertex, it has at least one island, so
$\mathrm{specModSig}(G) > 0$. There is always at least one nontrivial flat
function: the constant functions.

**The signature never exceeds the number of vertices.** Every vertex belongs to
exactly one island, so there cannot be more islands than vertices:
$\mathrm{specModSig}(G) \le \#V$. Mapping each vertex to its island is a
surjection from vertices onto islands.

**The signature equals $1$ exactly when the graph is connected.** A connected
graph is one big island, so its signature is $1$; and conversely a signature of
$1$ forces a single island, which is connectivity. This gives a purely
dimensional certificate of connectivity:

$$ G \text{ is connected} \iff \mathrm{specModSig}(G) = 1. $$

**The signature is maximal exactly when the graph has no edges.** The signature
hits its ceiling $\#V$ precisely when every vertex is its own island — that is,
when the graph is *edgeless*. Adding any edge fuses two islands and drops the
signature.

**The signature is an invariant of the graph's shape.** Two graphs that are
isomorphic — the same network drawn with relabeled vertices — have equal
signatures. The number does not depend on how you name the vertices, only on the
underlying connectivity. This is what makes it a genuine *signature* rather than
an artifact of presentation.

## From graphs to the architecture of mathematics

Why build this machinery so carefully? Because it is the load-bearing first
floor of a much taller building. The grand conjecture motivating this work is
that the *difficulty* of proving a theorem — the length of its shortest proof in
a formal library — can be predicted from the *geometry* of its dependency
structure: the type constraints, the web of lemmas it relies on, and the local
data of how those lemmas fit together. The proposed predictor is spectral: it
reads off the low-lying eigenvalues of a generalized Laplacian built from this
structure.

Real dependency structures are richer than simple graphs. A lemma usually leans
on several others at once, which is a *hypergraph* rather than a graph; and the
data attached to each statement suggests a **sheaf** — a way of gluing local
information into global sections — rather than a bare network. In that grander
language, the harmonic kernel becomes the *zeroth cohomology* of a constant
sheaf, and the component count is its dimension. The component-kernel theorem is
the $H^0$ shadow of a sheaf-theoretic statement that also exposes higher
invariants. It is the anchor: a place where the abstract spectral theory and the
concrete count of islands provably agree.

And crucially, the signature is *computable*. Because
$\mathrm{specModSig}(G)$ equals the number of connected components, an abstract
dimension becomes a directly printable integer. Take the dependency graph that a
formal library already exposes, symmetrize it into a simple graph on the finite
set of declarations, and the signature is just a connected-component count — a
number you can compute, track, and compare across libraries. The geometry stops
being a metaphor and becomes a measurement.

## The view from here

What makes this story satisfying is the collision of three very different
viewpoints on a single integer. Combinatorially, it is the number of islands in
a network. Algebraically, it is the dimension of a space of functions that refuse
to change across any edge. Spectrally, it is the multiplicity of the lowest
eigenvalue of a Laplacian — the number of "silent modes" of the network, the
ways it can hold a value without any internal tension. The theorem says these
three numbers are one and the same.

There is something quietly profound in that. The connected components of a graph
are about *cutting*: which pieces fall apart when you stop tracing edges. The
harmonic kernel is about *flow*: which functions can rest on the network without
strain. That cutting and flowing should give the same count is the discrete
echo of a principle that runs through all of geometry — that the holes and
pieces of a space are detectable by the functions and fields that live on it.

Here that principle is not a slogan but a theorem, verified down to the last
step, ready to bear the weight of a theory that hopes to measure the difficulty
of mathematics itself by the shape of its ideas.
