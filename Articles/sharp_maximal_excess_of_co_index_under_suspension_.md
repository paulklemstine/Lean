# When Doubling a Shape Adds a Dimension: The Hidden Arithmetic of Symmetry

## A question about symmetric shapes

Imagine a shape that is perfectly *balanced*: for every point on it, there is an
exact opposite — an antipode — and the shape looks identical when you swap every
point with its opposite. A sphere is the model example. Stand at the North Pole
and the South Pole answers; stand anywhere on the equator and the diametrically
opposite point answers back. Mathematicians call such a balanced object a
**free $\mathbb{Z}_2$-space**: "$\mathbb{Z}_2$" because there are two states
(a point and its antipode) that swap, and "free" because no point is ever its own
antipode — the swap never has a fixed point.

Now ask a deceptively simple question. Given such a symmetric shape, *how spherical
is it?* A single balanced pair of points is like a $0$-dimensional sphere,
$S^0$ — just two opposite dots. A balanced loop is like the circle $S^1$. A
balanced surface can be like the ordinary sphere $S^2$. The precise measure of
"how spherical" a symmetric shape is called its **co-index**: the co-index is the
largest dimension $n$ such that the $n$-dimensional sphere $S^n$ can be mapped into
the shape *while respecting antipodes* — sending opposite points to opposite
points. The co-index is a number that says, "there is at least this much sphere
hiding inside."

This one number turns out to be startlingly powerful. It sits at the heart of the
**Borsuk–Ulam theorem** — the celebrated fact that at any moment there are two
antipodal points on Earth with exactly the same temperature and pressure — and it
is the engine behind some of the most beautiful lower bounds in combinatorics,
including Lovász's legendary proof of the Kneser conjecture about graph colorings.

This article is about a single operation on symmetric shapes — **suspension** —
and the exact arithmetic it performs on the co-index.

## Suspension: doubling a shape by adding two poles

Take any shape $K$. Its **suspension**, written $S(K)$, is built by adding two new
"pole" points — call them North and South — and connecting *every* point of $K$ to
*both* poles. If $K$ were a circle, connecting every point to two poles above and
below sweeps out the surface of an ordinary sphere. Indeed, that is the classical
picture:

$$S(S^n) \;\cong\; S^{n+1}.$$

Suspending a sphere gives the next sphere up. Suspension is a machine that turns
$S^0$ (two dots) into $S^1$ (a circle) into $S^2$ (a sphere) into $S^3$, and so on,
climbing the dimensional ladder one rung at a time.

To keep the balance, the two poles must themselves be antipodes of one another:
North swaps with South. And there is one crucial rule. The two poles are *never*
joined to each other. In the language of shapes built from triangles, North and
South never share an edge. This is exactly what makes the pair of poles behave like
$S^0$ — two genuinely separate, opposite points — which is why suspension is
literally the operation "join the shape to $S^0$," written $S(K) = K * S^0$.

## The central question: does suspension always add a dimension?

Here is the tension that drives this work. Suspension raises the *dimension* of a
shape by exactly one — that is easy to see, since we sweep the old shape between two
new poles. The question is whether it raises the *co-index* — the amount of hidden
sphere — by the same amount.

There is a known ceiling. The co-index of a suspension can never exceed the
dimension of the original shape plus one:

$$\mathrm{coind}\big(S(K)\big) \;\le\; \dim(K) + 1.$$

The natural conjecture is that this ceiling is **sharp**: no matter what co-index
$c$ your $d$-dimensional shape starts with — even if it is co-index-poor, hiding
only a small sphere despite being high-dimensional — you should be able to arrange
that its suspension leaps all the way up to co-index $d+1$. That would be a jump of
size $d + 1 - c$, the **maximal possible excess**. Previous work established this in
the first nontrivial case, $c = 1$. The bold conjecture is that it holds for *every*
feasible starting co-index $1 \le c \le d$.

This article reports the constructive foundation on which that program rests: a
completely explicit, hands-on account of how suspension acts on the co-index, and
a genuine Borsuk–Ulam obstruction proved from scratch in this combinatorial world.

## Octahedral spheres: spheres you can hold in your hand

To reason about all of this concretely, we replace smooth spheres with a
crystalline, combinatorial model: the **octahedral spheres**. The ordinary
octahedron — two pyramids glued base to base — has six vertices arranged as three
antipodal pairs along three axes, and its surface is a triangulated $2$-sphere. The
octahedral $n$-sphere, written $\mathrm{Oct}\,n$, generalizes this:

- Its vertices are the $2(n+1)$ points labeled by an axis $i \in \{0, 1, \dots, n\}$
  and a sign (plus or minus).
- The antipodal map flips the sign, sending the plus end of an axis to its minus
  end.
- A collection of vertices forms a **face** — a legal simplex — precisely when it
  contains **no antipodal pair**: you may pick at most one end of each axis.

This last rule is the whole game in miniature. It says the largest faces are the
"orthants" — one choice of sign per axis — which have $n+1$ vertices and hence
dimension $n$. So $\mathrm{Oct}\,n$ has dimension exactly $n$, and it triangulates
the genuine sphere $S^n$. Two facts pin this down precisely:

- **(Top face exists.)** Choosing the plus end of every axis gives a face with
  $n+1$ vertices, an $n$-dimensional simplex.
- **(No bigger face.)** Every face has at most $n+1$ vertices, because the
  no-antipodal-pair rule forces each face to pick a *distinct* axis for each of its
  vertices, and there are only $n+1$ axes.

These crystalline spheres form a tower, and suspension moves you up the tower
exactly as expected.

## The heart of the matter: an explicit map that climbs the ladder

The technical core is a single, concrete, antipode-respecting map that realizes the
classical homeomorphism $S^{n+1} \cong S(S^n)$ combinatorially. It sends the
octahedral $(n+1)$-sphere onto the suspension of the octahedral $n$-sphere:

$$\mathrm{Oct}\,(n+1) \;\longrightarrow\; S(\mathrm{Oct}\,n).$$

The recipe could hardly be more transparent. The $(n+1)$-sphere has one extra axis
compared to the $n$-sphere. The map keeps the first $n+1$ axes inside the base copy
of $\mathrm{Oct}\,n$, and sends the two ends of the *last, extra* axis to the two
poles North and South. The plus end becomes North; the minus end becomes South. One
checks two things, and both fall out immediately from the definitions:

- **It respects antipodes.** Flipping a sign in $\mathrm{Oct}\,(n+1)$ either flips a
  sign in the base (matching the base antipodal map) or swaps the extra axis's ends
  (matching the North–South swap).
- **It sends faces to faces.** A face of $\mathrm{Oct}\,(n+1)$ picks at most one end
  of each axis, in particular at most one end of the extra axis — so its image never
  contains both poles, and its base part still avoids antipodal pairs. That is
  exactly the definition of a face of the suspension.

From this one map, everything cascades.

**Theorem (Suspension raises the co-index).** *If a symmetric shape $K$ hides an
$m$-sphere — that is, there is an antipode-respecting map $S^m \to K$ — then its
suspension $S(K)$ hides an $(m+1)$-sphere. In symbols, if the co-index of $K$ is at
least $m$, then the co-index of $S(K)$ is at least $m+1$.*

The proof is a two-step composition. Suppose we already have an antipode-respecting
map $\mathrm{Oct}\,m \to K$ (this is what "co-index at least $m$" means). Suspension
is *functorial*: any antipode-respecting map $K \to L$ can be suspended to a map
$S(K) \to S(L)$ by acting on the base and leaving the poles alone. Suspending our
given map yields $S(\mathrm{Oct}\,m) \to S(K)$. Now precede it by the explicit
ladder-climbing map $\mathrm{Oct}\,(m+1) \to S(\mathrm{Oct}\,m)$ above. Composing,
we get exactly the antipode-respecting map
$\mathrm{Oct}\,(m+1) \to S(K)$ that certifies co-index at least $m+1$. $\blacksquare$

Applied to the spheres themselves, this says the octahedral tower realizes the
diagonal $\mathrm{coind}(\mathrm{Oct}\,n) = n$: the identity map witnesses that the
$n$-sphere hides an $n$-sphere (itself), and suspension carries this up the ladder
in lockstep. Suspension never loses co-index, and it always adds at least one. This
is the unconditional **lower-bound half** of the sharp-excess program.

## The other side of the coin: a Borsuk–Ulam obstruction

A lower bound alone would be too good — if co-index only ever went up, the theory
would collapse. The magic of Borsuk–Ulam is that co-index *cannot* be faked
downward: you cannot squeeze a big sphere into a small one antipodally. The smallest
nontrivial case of this is proved here directly, in the crystalline model.

**Theorem (Combinatorial Borsuk–Ulam, base case).** *There is no antipode-respecting
simplicial map from $\mathrm{Oct}\,n$ to $\mathrm{Oct}\,0$ when $n \ge 1$.
Equivalently, the co-index of the two-point sphere $S^0 = \mathrm{Oct}\,0$ is exactly
$0$ — no positive-dimensional sphere fits antipodally inside two dots.*

The argument is a small gem, and it lays bare *why* the freeness rules matter. The
target $\mathrm{Oct}\,0$ has just two vertices, a single antipodal pair; a face may
contain at most one of them. Suppose $n \ge 1$, so the source has at least two
distinct axes; pick the plus ends $a$ and $b$ of two different axes. Since $a$ and
$b$ lie on different axes, $\{a, b\}$ is a legal face, so a face-preserving map must
send it to a face of $\mathrm{Oct}\,0$ — but a face there has at most one vertex, so
the map is forced to **collapse** $a$ and $b$ to the same point. Now play the
antipode $a$ against $b$: the set $\{a, \bar b\}$ (where $\bar b$ is $b$'s antipode)
is also a legal face, so its image is a face too. But respecting antipodes means
$\bar b$ maps to the antipode of $b$'s image, which equals the antipode of $a$'s
image — so the image of $\{a, \bar b\}$ is an antipodal pair, and *that is not a
face*. Contradiction. No such map can exist.

Notice what the proof used: that the involution is genuinely *free* (no vertex is
its own antipode) and that faces are *antipodal-pair-free*. Drop either rule and the
theorem is false — a constant map would suddenly be legal. Freeness is not
decoration; it is the entire source of the obstruction, the discrete fingerprint of
Borsuk–Ulam.

## Why the big jump is genuinely harder

The results above deliver the "$+1$" arithmetic of suspension exactly, and they show
the framework already *feels* the Borsuk–Ulam obstruction. But they also clarify why
the full sharp-excess conjecture — a jump of size $d + 1 - c$, potentially much
larger than one — is a deeper beast.

A single suspension adds *one* pole axis, and our explicit map spends that one axis
climbing one rung. To force a co-index-poor, $d$-dimensional shape all the way up to
co-index $d+1$ in one suspension, the jump cannot come from the lone new pole
direction; it must come from the **global equivariant connectivity** of the shape.
The intuition is striking: a shape can be "co-index poor" yet "suspension rich"
because suspension repairs exactly the equivariant homotopical defect that was
suppressing the co-index in the first place — and that defect can be engineered to be
as large as the ambient dimension allows. Building such shapes for every $c$ is the
central open problem this foundation is designed to attack.

## The bigger picture

Why should anyone outside topology care about the co-index of a suspension? Because
this exact quantity is a coloring detector. Through a classical dictionary, every
graph gives rise to a symmetric shape — its **box complex** — and the co-index of
that shape is a rigorous lower bound on the graph's chromatic number: you need at
least $\mathrm{coind} + 2$ colors to properly color it. This is Lovász's route to the
Kneser conjecture, and it remains one of the most surprising bridges in mathematics:
a purely topological invariant controlling a purely combinatorial one. A companion
identity says that suspending the box complex corresponds to a concrete graph
operation, so understanding suspension excess translates directly into sharpened
coloring bounds — potentially detecting colorings that the classical Lovász bound
misses.

So the humble act of adding two poles to a symmetric shape, and asking whether the
hidden sphere grows accordingly, turns out to touch the temperature of the Earth, the
coloring of graphs, and the fine structure of high-dimensional symmetry. The
arithmetic of suspension — always $+1$ on the way up, never a free ride on the way
down — is a small, sharp instance of a very large and very beautiful story.
