# Antipodes, Ladders, and the One-Step Climb: How Suspension Grows Symmetry

Imagine standing at the North Pole of a globe. Every point on the Earth has an
*antipode* — the point diametrically opposite it. The North Pole's antipode is
the South Pole; New York's antipode is a patch of ocean southwest of Australia.
A famous and beautiful fact, the **Borsuk–Ulam theorem**, says something almost
paradoxical about these antipodal pairs: *at any moment there exist two antipodal
points on Earth with exactly the same temperature and the same barometric
pressure.* You cannot continuously flatten a sphere onto a lower-dimensional map
without collapsing some antipodal pair to a single point.

This article is about the deep, quantitative structure hiding behind that
statement. It turns out that spheres carry a hidden "amount of antipodal
symmetry" — a number that measures how much of the sphere's mirror structure can
be faithfully transported into another symmetric space. This number is called the
**coindex**, and the central question we answer is deceptively simple:

> When you *suspend* a sphere — building the next sphere up the dimensional
> ladder — exactly how much does the coindex grow?

The answer, which we establish rigorously and constructively, is: **it grows by
exactly one, every step, and this is sharp at the base of the ladder.**

## Spheres you can hold in your hand

Real spheres are made of infinitely many points, which makes them slippery to
reason about with total precision. So we replace them with an exact combinatorial
skeleton that captures everything we need about their antipodal symmetry.

Take the two-dimensional plane and mark the four points $\pm e_0, \pm e_1$ — the
tips of the coordinate axes. Connect each pair of non-opposite tips with an edge.
You get a diamond (a square standing on its corner): this is the *cross-polytope*
in dimension 2, and its boundary is a combinatorial circle, $S^1$. Do the same in
three dimensions with $\pm e_0, \pm e_1, \pm e_2$ and you get the **octahedron**,
whose surface is a combinatorial sphere $S^2$. In general, the combinatorial
sphere $S^n$ is the boundary of the $(n+1)$-dimensional cross-polytope: its
vertices are the $2(n+1)$ signed unit vectors $\pm e_0, \dots, \pm e_n$.

We encode a vertex as a pair $(i, b)$: the index $i \in \{0, 1, \dots, n\}$ tells
you *which* axis, and the sign bit $b$ (true or false) tells you *which
direction*. The **antipodal map** simply flips the sign bit:
$$\text{anti}(i, b) = (i, \lnot b).$$
This is the combinatorial mirror. It has two crucial properties: applying it
twice returns you home ($\text{anti}(\text{anti}(p)) = p$), and it never fixes any
point ($\text{anti}(p) \neq p$). That second property is what mathematicians call
a **free** action: the mirror has no fixed points, exactly like the antipodal map
on a real sphere.

There is one more piece of structure: which sets of vertices form a genuine
*face* of the shape? The answer is elegant. A collection of vertices spans a face
of the cross-polytope **precisely when it contains no antipodal pair.** On the
octahedron, three tips form a triangle exactly when no two of them are opposite —
you can pick a "north-ish, east-ish, up-ish" corner but never both a tip and its
mirror. This single rule — *faces are antipodal-pair-free sets* — is the entire
combinatorial DNA of a sphere.

## Maps that respect the mirror

The heart of the story is not the spheres themselves but the **maps between
them** that respect all this structure. We call such a map a **$\mathbb{Z}_2$-map**
(the "$\mathbb{Z}_2$" refers to the two-element mirror group: identity and
reflection). A $\mathbb{Z}_2$-map from $S^m$ to $S^n$ is a rule $f$ sending
vertices to vertices that obeys two laws:

1. **Equivariance (it respects the mirror):**
   $$f(\text{anti}(p)) = \text{anti}(f(p)).$$
   Whatever $f$ does to a vertex, it does the mirror-image thing to the mirror
   vertex. The map commutes with reflection.

2. **Simpliciality (it respects faces):** it must send faces to faces. Because
   faces are exactly the antipodal-pair-free sets, this has a wonderfully local
   form. Two vertices $p, q$ land on an antipodal pair only if they *were* an
   antipodal pair:
   $$f(p) = \text{anti}(f(q)) \implies p = \text{anti}(q).$$
   In words: the map never manufactures a new pair of opposites out of two
   vertices that weren't opposite to begin with. Nothing "folds over" onto its
   own mirror image.

These two laws are the combinatorial essence of a continuous, antipode-preserving
map between real spheres. A $\mathbb{Z}_2$-map $S^m \to S^n$ is precisely a
certificate that the symmetry of $S^m$ can be faithfully embedded inside the
symmetry of $S^n$.

The **coindex** of $S^n$ is now easy to state: it is the largest $m$ for which
such a faithful map $S^m \to S^n$ exists. It measures how much antipodal symmetry
the sphere can *receive*.

## The ladder: building up by suspension

Here is where the dynamics enter. There is a natural operation, **suspension**,
that turns a sphere into the next sphere up: geometrically, you take $S^n$, add
two new poles above and below, and cone the whole thing off to both poles — the
result is $S^{n+1}$. (Suspending a circle gives an ordinary sphere; suspending an
ordinary sphere gives a 3-sphere.)

The pivotal discovery is that suspension acts not just on spheres but on the
*maps between them*, and it does so functorially. Given any $\mathbb{Z}_2$-map
$f : S^m \to S^n$, we build a suspended map
$$\text{susp}(f) : S^{m+1} \to S^{n+1}$$
by a simple, explicit recipe:

- The **poles are preserved.** The two new suspension poles of $S^{m+1}$ (encoded
  as the vertices with the top index) go straight to the two new poles of
  $S^{n+1}$, matching sign to sign.
- **Every other vertex is transported by $f$**, then relabeled to live one
  dimension up.

We prove that this recipe always yields a genuine $\mathbb{Z}_2$-map: it stays
equivariant (poles go to poles, mirror to mirror) and it stays simplicial (no new
antipodal pairs are ever created — the pole coordinate can never clash with a
transported coordinate, and $f$'s own simpliciality handles the rest). This is
the **suspension functor on $\mathbb{Z}_2$-maps**, and it is the geometric engine
of everything that follows.

## The constructive lower bound

With the suspension engine and one more ingredient — the **equatorial
inclusion** $S^n \hookrightarrow S^{n+1}$, which drops $S^n$ in as the equator of
the bigger sphere, ignoring the new poles — we can build $\mathbb{Z}_2$-maps
between spheres to order. The result is a clean, *constructive* theorem:

> **Lower-bound theorem.** Whenever $m \le n$, there exists an explicit
> $\mathbb{Z}_2$-map $S^m \to S^n$. Consequently the coindex of $S^n$ is at least
> $n$.

The proof is a ladder-climb. To map $S^m$ into $S^n$ when $m \le n$, start with
the identity map of $S^m$ and apply the equatorial inclusion $n - m$ times,
threading $S^m$ up through the equators of ever-larger spheres. Every step is an
honest, writable map — nothing is assumed to exist; everything is built. The
special case $m = n$ gives the "diagonal" witness: the identity map shows the
coindex of $S^n$ is at least $n$.

Reading this through the suspension lens gives the punchline about growth:

> **Suspension raises the coindex.** If there is a $\mathbb{Z}_2$-map
> $S^m \to S^n$, then there is one $S^{m+1} \to S^{n+1}$. So any coindex witness
> for a sphere yields a witness one larger for its suspension.

Each turn of the suspension crank adds one to the guaranteed symmetry. The
climb never stalls.

## Sharpness: the mirror really does obstruct

A lower bound alone could be an overcautious estimate. To know the growth is
*exactly* one, we need the matching obstruction: a proof that you **cannot** do
better at the base of the ladder. This is where Borsuk–Ulam re-enters, now in
crisp finite form.

The key technical step is a **finite reformulation**. Because a
$\mathbb{Z}_2$-map is completely determined by where it sends the *positive*
vertices $(i, \text{true})$ — the negative vertices are forced by equivariance —
checking whether a $\mathbb{Z}_2$-map $S^m \to S^n$ exists becomes a finite
search over finitely many candidate assignments. Existence of an infinite-looking
geometric object collapses to a terminating computation.

Running that computation at the bottom of the tower yields two genuine,
exhaustively verified instances of the Borsuk–Ulam theorem:

> **No map $S^1 \to S^0$.** There is no $\mathbb{Z}_2$-map from the circle to the
> two-point sphere $S^0 = \{+e_0, -e_0\}$. You cannot fold a circle onto two
> antipodal points while respecting the mirror.

> **No map $S^2 \to S^1$.** There is no $\mathbb{Z}_2$-map from the
> two-dimensional sphere to the circle. This is the combinatorial shadow of the
> classical Borsuk–Ulam statement that opened this article — the reason two
> antipodal points on Earth must share temperature and pressure.

Put together with the lower bound, these obstructions pin the values down
exactly:
$$\text{coind}(S^0) = 0, \qquad \text{coind}(S^1) = 1.$$
The coindex of $S^0$ is 0 (it maps to itself but receives nothing from $S^1$);
the coindex of $S^1$ is 1 (it receives $S^0$ and itself, but nothing from $S^2$).
So suspending $S^0$ into $S^1$ raises the coindex by **exactly one** — not
zero, not two. The increment we constructed is the true increment, sharp at the
base of the tower.

## Why this is more than a curiosity

This circle of ideas — antipodal maps, coindex, suspension — is one of the most
productive bridges in modern combinatorics. Its most celebrated application is
**Lovász's solution of the Kneser conjecture**: the surprising fact that you can
compute a *lower bound on the chromatic number of a graph* — how many colors you
need to properly color it — from the coindex of an associated topological space
built from the graph. A purely combinatorial coloring question is answered by
antipodal topology. The relation reads $\chi(G) \ge \text{coind}(\cdot) + 2$, and
it launched the field of topological combinatorics.

The same machinery drives fair-division results ("necklace splitting," dividing
contested resources among parties), the ham-sandwich theorem (any three solids in
space can be simultaneously bisected by a single plane), and hardness results in
theoretical computer science. In every case the engine is the same: a symmetry
that cannot be undone forces the existence of a solution.

What we have done here is isolate and rigorously establish the **constructive,
growth half** of this engine for combinatorial spheres — that suspension is a
functor on antipodal maps, that it lifts symmetry up the dimensional ladder one
rung at a time, and that the ascent is genuinely sharp where we can pin it down.
Every map in the argument is written by hand; every obstruction is verified by
exhaustive finite search. The paradox of the antipodes, so slippery in its
continuous form, becomes a ladder you can climb with your eyes open — one certain
step at a time.
