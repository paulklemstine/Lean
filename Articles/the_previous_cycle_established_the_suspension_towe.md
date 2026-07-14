# Counting the Ways a Sphere Can Wrap Itself

## A puzzle about hedgehogs and antipodes

Imagine standing anywhere on the surface of the Earth. At the very same instant there is a point on the exact opposite side of the planet — your *antipode*. A famous theorem of topology, the **Borsuk–Ulam theorem**, says something surprising about antipodes: at any given moment there are two antipodal points on Earth with exactly the same temperature *and* the same barometric pressure. You cannot smoothly assign two numbers to every point on a sphere without some pair of opposite points agreeing.

The reason this is true is that a sphere "knows" its own dimension, and it refuses to be squeezed into a smaller one without tearing. More precisely: you cannot continuously map the surface of a ball in one dimension onto a sphere of a smaller dimension while always sending opposite points to opposite points. Opposite-preserving maps — call them **antipodal maps** — can raise dimension freely, but they can never lower it.

This article is about turning that soft, topological "never" into something hard, countable, and exact. We work with a beautifully rigid combinatorial model of spheres, and inside it we do not merely ask *whether* an antipodal map exists — we count **exactly how many there are**. The answer is a clean formula, and buried inside that formula is the whole Borsuk–Ulam theorem, a classical symmetry group, and a surprising rigidity that makes these particular spheres the most disciplined objects in the whole theory.

## Spheres made of building blocks

To count things you first need something discrete to count. Instead of the smooth round sphere, we use its skeleton: the **cross-polytope**, also called the *octahedron* in three dimensions and the *hyperoctahedron* in general.

Picture the ordinary sphere in $3$-dimensional space. Now keep only its six "pole" points: north/south, east/west, front/back — the six points $\pm e_0, \pm e_1, \pm e_2$ where the coordinate axes pierce the sphere. Connecting them with straight edges and triangular faces gives an **octahedron**, which is topologically the same as the sphere. This is the combinatorial sphere we call $S^2$.

In general, the combinatorial $n$-sphere $S^n$ has exactly $2(n+1)$ vertices: for each of the $n+1$ coordinate axes there is a **positive** vertex $+e_i$ and a **negative** vertex $-e_i$. So a vertex is nothing more than a pair
$$
(\text{axis } i,\ \text{sign} \in \{+,-\}), \qquad i \in \{0,1,\dots,n\}.
$$
The antipodal map — "go to the opposite point" — simply flips the sign: it sends $+e_i$ to $-e_i$ and vice versa, leaving the axis untouched.

A face of this combinatorial sphere is any collection of vertices that uses each axis **at most once with one sign**: you may pick $+e_0$ or $-e_0$ but never both, because $+e_0$ and $-e_0$ are opposite poles and are never joined by an edge. This one rule — *no axis appears twice* — is the entire combinatorial content of the octahedron, and it is the hinge on which everything below turns.

## What is an antipodal map, combinatorially?

An **antipodal simplicial map** $F : S^m \to S^n$ is a rule sending vertices of the small sphere to vertices of the big one such that:

1. **(Antipodal / equivariant)** opposite points go to opposite points: $F(-v) = -F(v)$; and
2. **(Simplicial)** faces go to faces: whenever a set of vertices forms a face upstairs, their images form a face downstairs.

These maps are the exact combinatorial stand-ins for the continuous odd maps of the Borsuk–Ulam theorem. The central question of this field is captured by a single invariant, the **$\mathbb{Z}_2$-coindex** of a sphere: the *largest* dimension $m$ such that some antipodal map $S^m \to S^n$ exists. Intuitively, it measures "how much antipodal complexity $S^n$ can absorb." The dual notion, the **index**, is the *smallest* target dimension $n$ into which $S^m$ can be antipodally mapped — "how much room $S^m$ needs to breathe."

Borsuk–Ulam, in this language, is the statement that you can never map a *bigger* sphere antipodally into a *smaller* one. Everything that follows makes this precise and quantitative.

## The decisive observation: an antipodal map is two free choices

Here is the key structural insight, and it is genuinely simple once you see it.

Because an antipodal map must send opposite points to opposite points, it is **completely determined by what it does to the positive vertices**. Once you know where $+e_0, +e_1, \dots, +e_m$ go, the images of the negative vertices are forced: $-e_i$ must go to the antipode of the image of $+e_i$. So a map is just a function on the $m+1$ positive vertices.

Now, where can $+e_i$ go? It lands on some vertex of $S^n$, that is, on some axis $j$ with some sign. Split that data in two:

- the **axis part** — which of the $n+1$ target axes does $+e_i$ land on; and
- the **sign part** — does it land on the positive or negative pole of that axis.

The simpliciality rule ("no axis appears twice in a face") forces the axis part to be **injective**: two different source axes can never be sent to the same target axis, because then a legitimate face upstairs would collapse to something using one axis twice — an illegal face downstairs. The sign part, on the other hand, is **completely free**: flipping the sign of an image just reflects across a coordinate hyperplane, which is a perfectly good antipodal symmetry.

This gives the clean **structure theorem**:

> **An antipodal simplicial map $S^m \to S^n$ is precisely an injection of the $m+1$ source axes into the $n+1$ target axes, together with an arbitrary, independent choice of sign for each source axis.**

Two decoupled ingredients: *which axes* (rigid, must be injective) and *which signs* (totally free). Everything else follows by arithmetic.

## From existence to an exact count

An injection of $m+1$ things into $n+1$ things exists **if and only if** $m+1 \le n+1$, i.e. $m \le n$. That single observation is the **Borsuk–Ulam theorem** for these spheres: an antipodal map $S^m \to S^n$ exists exactly when $m \le n$, and in particular there is **no** antipodal map from a sphere into any strictly smaller one.

But we can do far better than yes/no. The number of injections of an $(m+1)$-element set into an $(n+1)$-element set is the **falling factorial**
$$
(n+1)^{\underline{\,m+1\,}} \;=\; (n+1)\,n\,(n-1)\cdots(n-m+1),
$$
the product of $m+1$ consecutive descending integers. And there are $2^{m+1}$ independent sign choices. Multiplying the two free ingredients gives the **exact enumeration**:
$$
\boxed{\;\#\{\text{antipodal maps } S^m \to S^n\} \;=\; (n+1)^{\underline{\,m+1\,}}\cdot 2^{\,m+1}.\;}
$$

Let us read some values off this formula. Writing the count in a table with source dimension $m$ down the rows and target dimension $n$ across:

| $m \backslash n$ | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| **0** | 2 | 4 | 6 | 8 | 10 |
| **1** | 0 | 8 | 24 | 48 | 80 |
| **2** | 0 | 0 | 48 | 192 | 480 |

The zeros below the diagonal are Borsuk–Ulam made visible: there simply are no maps when $m > n$. The count crosses from zero to positive at exactly the moment $m = n$.

## The diagonal is a famous group

Look at the diagonal entries $2, 8, 48, 384, \dots$ — the number of antipodal self-maps of $S^n$. Setting $m = n$ in the formula, the falling factorial becomes an ordinary factorial and we get
$$
\#\{\text{antipodal self-maps of } S^n\} \;=\; (n+1)!\cdot 2^{\,n+1}.
$$
This is not a random number: it is exactly the order of the **hyperoctahedral group** $B_{n+1}$, the full symmetry group of the cross-polytope — all the ways to permute the $n+1$ coordinate axes ($(n+1)!$ of them) and independently flip their signs ($2^{n+1}$ of them). The enumeration recovers, on the nose, the classical symmetry group of the very shape we started with. The self-maps of the combinatorial sphere are *precisely* its rigid symmetries — there is no extra floppiness. This is the sense in which the octahedral model is maximally rigid.

## Index equals coindex: a gap that vanishes

Recall the two dual invariants: the **coindex** of $S^n$ (largest source that maps in) and the **index** of $S^n$ (smallest target it maps out into). In general topology these two numbers can *differ* — there are spaces whose index strictly exceeds their coindex, and that gap encodes subtle information. For our combinatorial spheres, however, the count settles the matter instantly. A map $S^m \to S^n$ exists iff $m \le n$, so:

- the largest $m$ with a map into $S^n$ is $m = n$ — hence **coindex $= n$**;
- the smallest $n$ with a map out of $S^m$ is $n = m$ — hence **index $= m$**.

Both invariants equal the dimension, so
$$
\operatorname{index}(S^n) = \operatorname{coindex}(S^n) = n,
$$
and the index–coindex gap is **zero**. These spheres are perfectly balanced: they need exactly as much room to map out as they can absorb mapping in. This is special to the octahedral model — the rigidity that forces axes to be permuted is exactly what closes the gap. For more general combinatorial spaces the gap reopens, and studying it is a live research direction.

## Suspension: climbing the tower one rung at a time

There is a natural way to build $S^{n+1}$ from $S^n$: **suspension**. Geometrically, you add one new coordinate axis with two new poles and "cone off" — every old face joins to each new pole. It is the combinatorial version of spinning a circle into a sphere.

Suspension turns the sequence of spheres into a **tower**
$$
S^0 \hookrightarrow S^1 \hookrightarrow S^2 \hookrightarrow \cdots,
$$
and it interacts perfectly with our invariants. Suspending both source and target of an antipodal map produces a new antipodal map one dimension higher, and this operation preserves the "excess" $n - m$: there is an antipodal map $S^{m+k} \to S^{n+k}$ if and only if there is one $S^m \to S^n$. Each rung of the tower is Borsuk–Ulam sharp — the coindex goes up by exactly one at each step, with no slack. The invariant $m \le n$, the coindex, the index, and the raw map-count all shift in lockstep as you climb.

## Why the tidiness matters

It is tempting to dismiss all of this as too clean — surely a model where everything reduces to "count injections and signs" throws away the hard topology? The opposite is true. The value of a rigid, fully solved model is that it becomes a **calibrated baseline**. Because we know the octahedral spheres have zero index–coindex gap and a map-count that factors perfectly into "a falling factorial times a power of two," any *other* combinatorial space can be measured against them. A space whose map-count fails to factor this way is provably *not* octahedral; a space with a positive index–coindex gap is provably carrying structure the sphere does not. The rigid case turns folklore into a computable diagnostic.

And the philosophical payoff is genuinely satisfying. Borsuk–Ulam is usually presented as a deep, almost mysterious fact about continuity and dimension — the hedgehog you cannot comb, the antipodes you cannot separate. Here it is revealed, in one important model, to be nothing more exotic than the pigeonhole principle in disguise: **you cannot injectively fit $m+1$ axes into $n+1$ axes when $m > n$.** The mystery dissolves into counting, and the counting hands back, as a bonus, the exact number of ways every sphere can wrap itself.
