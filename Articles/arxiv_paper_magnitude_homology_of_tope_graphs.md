# Counting the Rooms of a Hyperplane World

*How a size measurement for metric spaces, refined into an algebraic invariant, turns out to be counting monomials.*

---

## A knife through space

Take a sheet of paper and draw a line across it. You have cut the plane into two regions. Draw a second line, and — if you were not too careful about making it parallel — you now have four. A third line, generically placed, gives seven. Keep going, and the plane fills with a mosaic of polygonal rooms.

Mathematicians call this a **real hyperplane arrangement**: a finite collection of flat walls (lines in the plane, planes in space, hyperplanes in $\mathbb{R}^d$), and the rooms they carve out are called **chambers**, or, in the language of oriented matroids, **topes**.

The topes are not just a pile of rooms. They come with a natural notion of *adjacency*: two rooms are neighbours if you can step from one to the other through a single wall. Turning this into a graph — a vertex for every room, an edge for every shared wall — yields the **tope graph** of the arrangement. And this graph has a beautiful metric property, first isolated by Jacques Tits in the setting of Coxeter groups:

> **The distance between two rooms in the tope graph equals the number of walls that separate them.**

You cannot cheat. To get from room $A$ to room $B$ you must cross every wall that has $A$ on one side and $B$ on the other, and a shortest route crosses each such wall exactly once, and no other wall at all. Distance is *separation*. This single fact is the hinge on which everything below turns.

## The simplest world of all

Let us make this completely concrete with the humblest arrangement there is: in $\mathbb{R}^n$, take the $n$ **coordinate hyperplanes**
$$H_i = \{x \in \mathbb{R}^n : x_i = 0\}, \qquad i = 1, \dots, n.$$
These are the walls; there are $n$ of them; and the rooms they cut out are exactly the $2^n$ open orthants. A room is determined by a choice of sign for each coordinate, so we may label it by the subset $s \subseteq \{1,\dots,n\}$ of coordinates that are *positive*:
$$C_s = \{x \in \mathbb{R}^n : x_i > 0 \text{ for } i \in s, \ x_i < 0 \text{ for } i \notin s\}.$$
Each $C_s$ is nonempty (the sign vector itself lives there), convex (a positive combination of two positive numbers is positive), and no point of any $C_s$ lies on any wall. Distinct labels give disjoint rooms.

Now the key computation. When does the wall $H_i$ separate the rooms $C_s$ and $C_t$? Precisely when $x_i$ and $y_i$ have opposite signs for $x \in C_s$, $y \in C_t$ — that is, when $i$ belongs to $s$ but not $t$, or to $t$ but not $s$. In symbols:

> **Separation is symmetric difference.** For $x \in C_s$ and $y \in C_t$, the hyperplane $H_i$ separates $x$ from $y$ (i.e. $x_i y_i < 0$) if and only if $i \in s \,\triangle\, t$.

So the number of separating walls is $|s \triangle t|$, and by Tits' principle the tope graph distance is
$$d(C_s, C_t) = |s \,\triangle\, t|.$$
This is the **Hamming distance** between the two sign vectors. The tope graph of the coordinate arrangement is nothing other than the $n$-dimensional **hypercube graph** $Q_n$ — the graph on binary strings of length $n$ with an edge whenever two strings differ in one bit. Every intuition you have about flipping bits is now a statement about walking through the orthants of $\mathbb{R}^n$.

There is a third face to the same object. The reflections in the $n$ coordinate hyperplanes generate the group $(\mathbb{Z}/2)^n$ — the Coxeter group of type $A_1^n$ — and the hypercube is exactly its **Cayley graph** with respect to those $n$ generating reflections. One combinatorial object, three descriptions: rooms of an arrangement, bit strings, group elements. This coincidence is not an accident of the coordinate arrangement; for any finite Coxeter group, the tope graph of its reflection arrangement is the Cayley graph with respect to the simple reflections, with graph distance equal to word length.

## How big is a metric space?

Now we change the subject, and then discover we have not changed it at all.

In the 2000s Tom Leinster proposed a startling invariant: a single number, the **magnitude**, attached to a metric space, generalising the "effective number of points" of a finite set. For a finite metric space $X$ one forms the *similarity matrix* $Z$, with entries $Z_{xy} = q^{d(x,y)}$ for a formal parameter $q$, and sets the magnitude to be the sum of all entries of $Z^{-1}$. For a finite graph with its shortest-path metric this yields a rational function of $q$, the **magnitude power series**
$$\#G(q) = \sum_{\ell \ge 0} c_\ell \, q^{\ell},$$
whose coefficients are integers encoding metric information about $G$. Magnitude behaves like a cardinality — it is multiplicative under products, additive under suitable unions — and in the continuous world it secretly knows about volume, surface area, and dimension.

A number is good. A *space* whose Euler characteristic is that number is better. In 2014 Richard Hepworth and Simon Willerton **categorified** graph magnitude: they built, for each graph $G$, a bigraded family of abelian groups $MH_{k,\ell}(G)$, the **magnitude homology** of $G$, whose graded Euler characteristic recovers the magnitude power series:
$$\#G(q) = \sum_{k,\ell} (-1)^k \operatorname{rank} MH_{k,\ell}(G) \, q^{\ell}.$$

The construction is disarmingly simple. A **generator of bidegree $(k,\ell)$** is a tuple of vertices
$$(x_0, x_1, \dots, x_k), \qquad x_{i-1} \ne x_i \text{ for all } i, \qquad \sum_{i=1}^{k} d(x_{i-1}, x_i) = \ell.$$
Think of it as a $k$-legged journey through the graph of total length $\ell$. The chain group $MC_{k,\ell}(G)$ is the free abelian group on these tuples. The differential deletes interior stops:
$$\partial_i (x_0, \dots, x_k) = \begin{cases} (x_0, \dots, \widehat{x_i}, \dots, x_k) & \text{if deleting } x_i \text{ does not change the total length,} \\ 0 & \text{otherwise,} \end{cases}$$
and $\delta = \sum_{i=1}^{k-1} (-1)^i \partial_i$. A stop can be skipped for free exactly when it lies on a geodesic between its neighbours; a stop that forces a detour cannot be removed. Homology of this complex is $MH_{k,\ell}(G)$.

The bookkeeping guarantees $\ell \ge k$ always (each leg has length at least $1$). The **diagonal** $k = \ell$ is therefore the extreme case, and a graph is called **diagonal** when all its magnitude homology is concentrated there: $MH_{k,\ell} = 0$ whenever $k \ne \ell$. Diagonal graphs are the ones for which magnitude homology is as simple as it could possibly be, and for which the magnitude power series has alternating-sign coefficients that literally count homology classes.

## The theorem

Here is the punchline, and it is a genuinely surprising bridge between three subjects.

> **Tope graphs are diagonal, and their magnitude homology ranks are Hilbert functions of Stanley–Reisner rings.**

To each arrangement one associates, tope by tope, a simplicial complex built from the local geometry, and the rank of $MH_{\ell,\ell}$ is a sum over topes of the values of the Hilbert function of the corresponding **Stanley–Reisner ring** — the quotient of a polynomial ring by the squarefree monomial ideal of non-faces of the complex. Combinatorial commutative algebra, invented to count faces of polytopes, is what governs the homology of a metric-space invariant.

For our coordinate arrangement every tope has the same local structure — a full simplex on $n$ vertices — and the Stanley–Reisner ring is the honest polynomial ring $k[x_1,\dots,x_n]$, whose Hilbert function is $\dim_k k[x_1,\dots,x_n]_\ell = \binom{n+\ell-1}{\ell}$. So the prediction is
$$\operatorname{rank} MH_{\ell,\ell}(Q_n) = 2^n \binom{n+\ell-1}{\ell},$$
with everything off the diagonal vanishing.

Let us test this against explicit computation.

**Length 1.** A $(1,1)$-generator is a pair $(x,y)$ of vertices at distance $1$: an ordered edge. There is nothing to differentiate into, and nothing differentiates onto it (there are no $(2,1)$-generators, since a two-legged journey has length at least $2$). So $MH_{1,1}(G)$ is the free abelian group on the ordered edges of *any* connected graph $G$. For the hypercube each of the $2^n$ topes has $n$ neighbours, giving $2^n n$ ordered edges. And indeed $2^n\binom{n}{1} = 2^n n$. ✓

**Off-diagonal vanishing in degree $1$.** Take $\ell \ge 2$ and a pair $(x,y)$ at distance $\ell$. Walk one step from $x$ along a geodesic to a vertex $z$; then $d(x,z) + d(z,y) = d(x,y)$ and $z \ne y$, so $(x,z,y)$ is a legitimate $(2,\ell)$-generator whose differential is exactly $(x,y)$. The differential is therefore *surjective* in every length $\ell \ge 2$, so
$$MH_{1,\ell}(G) = 0 \qquad \text{for all } \ell \ge 2,$$
for every connected graph. This is the degree-$1$ shadow of diagonality — and here it is free of charge, no hyperplanes required.

**The diagonal in length 2.** This is where it gets interesting. A $(2,2)$-generator is a triple $(x,y,z)$ with $x \ne y \ne z$ and $d(x,y) = d(y,z) = 1$: a middle vertex $y$ together with an ordered pair of neighbours. In the hypercube, $y$ is any of the $2^n$ topes and each neighbour is a choice of one of the $n$ walls to cross, so there are $2^n n^2$ such generators. Meanwhile there are $2^n\binom{n}{2}$ generators of bidegree $(1,2)$ (a tope, plus a $2$-element set of walls to cross). Since the differential is surjective and lands in a free group, the sequence splits, so the group of $(2,2)$-cycles is free of rank
$$2^n n^2 - 2^n\binom{n}{2} = 2^n\left(n^2 - \frac{n(n-1)}{2}\right) = 2^n \frac{n(n+1)}{2} = 2^n \binom{n+1}{2}.$$
Nothing maps into bidegree $(2,2)$ — the incoming differential comes from $(3,2)$, and a three-legged journey has length at least $3$ — so the homology *is* the cycle group:
$$MH_{2,2}(Q_n) \cong \mathbb{Z}^{\,2^n\binom{n+1}{2}}.$$
And $\binom{n+1}{2}$ is exactly the number of degree-$2$ monomials in $n$ variables: the Hilbert function of $k[x_1,\dots,x_n]$ at $2$. The prediction is confirmed on the nose.

For $n=2$ (two crossing lines in the plane, four quadrants), this says $MH_{2,2}$ has rank $4 \cdot 3 = 12$; for $n = 3$ (the three coordinate planes, eight octants, the ordinary cube), rank $8 \cdot 6 = 48$.

## Where does that Hilbert function come from?

There is a satisfying reason for the polynomial ring to appear, and it can be read off the chain groups directly.

Fix a length $\ell \ge 2$. A $(2,\ell)$-generator of the tope graph is a triple $(x,y,z)$; using the separation dictionary, write $a = x \triangle y$ and $b = y \triangle z$ for the sets of walls crossed on the two legs. The conditions $x \ne y$, $y \ne z$ say exactly that $a$ and $b$ are nonempty, and the length condition says $|a| + |b| = \ell$. So:

> A degree-$2$ chain of length $\ell$ is the same thing as a tope $y$ together with an **ordered pair of nonempty sets of walls** $(a, b)$ with $|a| + |b| = \ell$.

Ordered pairs of subsets of an $n$-set with total size $\ell$ are in bijection with $\ell$-subsets of a $2n$-set — the Vandermonde identity $\sum_j \binom{n}{j}\binom{n}{\ell-j} = \binom{2n}{\ell}$ made into a bijection — and there are $2\binom{n}{\ell}$ pairs with an empty member. Hence
$$\operatorname{rank} MC_{2,\ell}(Q_n) = 2^n\left(\binom{2n}{\ell} - 2\binom{n}{\ell}\right),$$
while $\operatorname{rank} MC_{1,\ell}(Q_n) = 2^n\binom{n}{\ell}$. Surjectivity of the differential gives the rank of the $(2,\ell)$-cycles as the difference:
$$2^n\left(\binom{2n}{\ell} - 3\binom{n}{\ell}\right).$$
Setting $\ell = 2$ recovers $2^n\binom{n+1}{2}$, and every one of these numbers is a *count of decorated monomials*: choosing a multiset of walls with multiplicity is choosing a monomial, and the Hilbert function of the polynomial ring is the number of ways of doing so. The magnitude homology of the arrangement is, in a precise sense, the space of monomials on its walls, distributed over its rooms.

## Why one should care

Three threads meet here, and each is enriched by the others.

**Metric geometry gets an algebraic model.** Magnitude was designed to measure "size", and its categorification was expected to be hard to compute. Tope graphs are a large, natural family — every finite Coxeter group, every oriented matroid, every real arrangement — where the answer is not only computable but is a *standard* algebraic invariant.

**Commutative algebra gets a new home.** Hilbert functions of Stanley–Reisner rings are among the most-studied objects in combinatorial commutative algebra, tied to $f$-vectors of complexes and to the $g$-theorem. Finding them as ranks of homology groups of a metric invariant gives them an unexpected topological meaning.

**Group theory gets an invariant.** Because the tope graph of a reflection arrangement is the Cayley graph of the corresponding Coxeter group with word-length metric, the theorem computes the magnitude homology of Coxeter groups. For the elementary abelian group $(\mathbb{Z}/2)^n$ we get precisely the numbers above: $MH_{1,1}$ free of rank $2^n n$, $MH_{1,\ell} = 0$ for $\ell \ge 2$, and $MH_{2,2}$ free of rank $2^n\binom{n+1}{2}$. Everything transfers because a graph isomorphism is automatically an isometry for the shortest-path metric — a small lemma with a large payoff, since it makes the entire magnitude-homological package a genuine invariant of the abstract graph.

There is a further symmetry in the picture, a **homological reciprocity** for *central* arrangements — those in which all walls pass through a common point, as the coordinate hyperplanes do through the origin. The chamber structure of a central arrangement is invariant under $x \mapsto -x$, which pairs each tope with its antipode, and this involution induces a duality relation among the magnitude homology ranks in complementary degrees, closely analogous to Alexander duality for a sphere and to Poincaré-type reciprocity for Ehrhart and Hilbert series. In the hypercube it is visible as the symmetry $s \mapsto \{1,\dots,n\} \setminus s$, the map exchanging each orthant with the opposite one.

## The shape of the argument

Behind the general theorem is a chain of ideas each worth knowing in its own right. One filters the magnitude chain complex by geodesic structure and identifies the associated graded pieces with order complexes of intervals in the poset of *covectors* of the arrangement — the combinatorial record of which side of each wall a face lies on. The **Edelman–Walker theorem** on the homotopy type of such intervals identifies these order complexes with wedges of spheres. **Alexander duality** then converts the sphere counts into face counts of a complementary simplicial complex, and face counts of a simplicial complex are precisely the Hilbert function of its Stanley–Reisner ring. Diagonality drops out because the spheres sit in exactly one degree.

For the coordinate arrangement, none of that machinery is needed: the poset is Boolean, the complex is the full simplex, and the counting can be done by hand — which is what we did above, with each step visible.

## Coda

Start with a knife and a sheet of paper. Cut. Count the rooms, and how many walls separate each pair. Feed those numbers into a machine designed to measure the "size" of a metric space, refine the machine until it produces groups instead of numbers, and out come the dimensions of the spaces of polynomials in as many variables as you had walls.

That is the pleasure of the subject: not that the answer is complicated, but that three fields which had no reason to speak to one another turn out to have been saying the same thing all along.
