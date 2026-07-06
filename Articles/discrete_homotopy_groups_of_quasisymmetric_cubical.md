# When a Square Fills In: The Hidden Algebra of Discrete Loops

## A hole you can hear

Take a piece of string, tie its ends together, and drop the loop onto a
tabletop. Nothing interesting happens — you can slide the loop around, shrink
it to a point, and it never gets stuck. Now put a coffee mug in the middle of
the table and loop the string around its handle. Suddenly the loop is trapped.
No amount of sliding will contract it to a point without cutting the string or
lifting it over the handle. The loop has *detected a hole*.

This is the oldest idea in topology: a space is interesting precisely when it
has loops that cannot be contracted. The collection of all such loops, with a
rule for combining them, forms a group — the **fundamental group** — and it is
one of the most powerful fingerprints a shape can have. A disk has a trivial
fundamental group (every loop shrinks). An annulus, a donut, a figure-eight
each have their own richer fundamental groups that count and combine holes in
different ways.

For a century this theory lived in the continuous world of rubber sheets and
smooth deformations. But the objects we actually compute with — networks,
meshes, images, the cells of a simulation — are *discrete*. They are made of
vertices, edges, and higher building blocks glued along their faces. A natural
and surprisingly subtle question arises: **can we define "a loop that cannot be
contracted" using nothing but combinatorics, and get an invariant that behaves
like the classical one?**

This article is about a clean, fully rigorous answer to that question for one
of the most useful families of discrete spaces: **cubical sets**, spaces built
not from triangles but from squares, cubes, and their higher-dimensional
analogues. We will define a **discrete fundamental group**, watch it detect a
hole in an empty square, and then watch that hole vanish the instant we fill
the square in. Along the way we will meet a single principle that governs the
entire phenomenon: *filling can only create contractions, never destroy them.*

## Building spaces out of squares

A **cubical set** is a recipe for gluing together cubes of every dimension. In
dimension zero we have **vertices** (points). In dimension one we have
**edges** (segments) connecting vertices. In dimension two we have **squares**
(the 2-cubes), each with four boundary edges. In higher dimensions we have
solid cubes, hypercubes, and so on. Cubical sets are the natural language of
grids, of digital images (whose pixels are literally little squares), and of
many models in geometry and computer science, because products of cubes are
again cubes — a convenience that triangulations do not enjoy.

For the story of loops we only need the low-dimensional part of the picture,
the so-called **1-truncated** cubical set: its vertices and edges (together
called the **1-skeleton**) and its squares. A **loop** is a walk along edges
that starts and ends at the same vertex. Two loops should count as "the same"
if one can be deformed into the other by sliding across the squares that are
present. The whole subtlety is packed into that last clause: *which squares are
present.* A loop that runs around the boundary of a square can be slid across
the square and contracted — but only if the square is actually filled in. If
the square is missing, the loop is stuck, exactly like the string around the
mug handle.

## Turning geometry into a group presentation

Here is the key move that makes everything computable. To describe loops
algebraically, we use a classical bookkeeping trick.

First, choose a **spanning tree** of the 1-skeleton: a collection of edges that
connects every vertex without forming any loop of its own. Traveling along tree
edges never takes you around a hole, so we declare every tree edge to be
"trivial" — the identity. Every remaining (non-tree) edge becomes a **generator**:
a basic loop you are allowed to use.

Second, each **square** that is filled in contributes a **relation**. Reading
its four boundary edges in order spells a word in the generators — the square's
**boundary word** — and filling the square declares that this word equals the
identity. Geometrically: "the loop around this square can be contracted, so it
counts as nothing."

The resulting object — generators (the edges), modulo relations (tree edges are
trivial; boundary words of filled squares are trivial) — is a **presented
group**. We call it the **discrete fundamental group** and write it $\pi_1^{A}$.
Two loops are **discretely homotopic** (deformable into one another) exactly
when they represent the same element of this group. This is the synthetic,
combinatorial definition of "a loop that cannot be contracted," and it needs no
rubber sheets at all.

## The empty square remembers; the filled square forgets

The smallest experiment that reveals the whole phenomenon uses a single square
with four boundary edges. Label them $e_0, e_1, e_2, e_3$. Choose a spanning
tree consisting of the three edges $e_0, e_1, e_2$, so those three are set to
the identity, leaving one honest generator: $e_3$, the edge that closes the
loop.

**Case 1: the hollow square.** Suppose the square is *not* filled — we have its
four edges but no 2-cell spanning them. Then the only relations are the three
tree relations $e_0 = e_1 = e_2 = 1$. The presented group is therefore free on
the single generator $e_3$: it is a copy of the integers $\mathbb{Z}$. This is
not a technicality; it is the heart of the matter. **The hollow square has a
nontrivial discrete fundamental group.** Concretely, there is a homomorphism
from the group onto $\mathbb{Z}$ that sends $e_3$ to $1$ — a "winding number"
that counts how many times a loop wraps around the missing square. Because that
homomorphism sends $e_3$ to something nonzero, $e_3$ cannot be trivial, and the
group cannot collapse. The hole is real, and the algebra sees it.

**Case 2: the filled square.** Now glue in the 2-cell. This adds exactly one new
relation: the boundary word $e_0 \, e_1 \, e_2 \, e_3 = 1$. But we already
declared $e_0 = e_1 = e_2 = 1$. Substituting, the boundary relation collapses to
$e_3 = 1$. The last surviving generator dies. Every generator is now trivial,
and so **the entire discrete fundamental group collapses to the trivial group**:
a single point's worth of loops, all contractible. The hole has been sealed.

The contrast is the punchline of discrete homotopy theory in miniature: *the
same loop* — the boundary of the square — is nontrivial when the square is
hollow and trivial when the square is filled. Two-dimensional cells are the
precise mechanism by which one-dimensional loops become contractible.

## One principle to rule them: filling only creates contractions

It would be a thin result if it only worked for one hand-built square. The real
content is a general law about how the discrete fundamental group *changes* when
you add cells.

Adding filled squares means adding relations. Suppose one cubical set's
relations form a set $R_1$ and we enlarge it to a bigger set $R_2$ by filling in
more squares, so $R_1 \subseteq R_2$. Then there is a canonical group
homomorphism
$$\varphi : \pi_1^{A}(R_1) \longrightarrow \pi_1^{A}(R_2)$$
that sends each edge generator to the corresponding edge generator, and this map
is always **surjective**. Nothing in the target is missed; every loop in the
larger complex is the image of a loop in the smaller one.

Read the surjectivity carefully, because it encodes a genuine asymmetry of
nature. A surjection can *merge* elements together (its kernel can be large) but
it can never invent elements out of nowhere. Translated back into geometry:
**filling in cells can only make more loops contractible; it can never make a
contractible loop become stuck.** Homotopy can be destroyed by filling, never
created. The hollow-versus-filled square is simply the extreme case of this law,
where the surjection from $\mathbb{Z}$ down to the trivial group crushes the
winding-number generator to nothing.

There is also a clean sufficient condition for total collapse, which we used
above: *if every edge generator becomes trivial in $\pi_1^{A}$, then the whole
group is trivial.* The reasoning is that the generators, by definition,
generate the entire group; if each of them is the identity, the subgroup they
generate is both everything and nothing at once, forcing the group to be a
single point. This is the algebraic face of the statement "every loop is
null-homotopic."

## Why this is more than a curiosity

The picture we have drawn — generators are edges, relations are squares,
filling collapses loops — is a faithful, fully rigorous shadow of the classical
theory, and it comes with three attractive features.

**It is genuinely combinatorial.** Everything is a finite manipulation of words
in generators. There are no limits, no continuity, no deformation retracts to
verify by hand. A computer can carry out the bookkeeping, and the winding-number
homomorphism can be evaluated by simply counting signed occurrences of an edge
in a word.

**It is functorial.** The subset law $R_1 \subseteq R_2 \Rightarrow$ surjection
is not an accident of one example; it is a structural principle that turns the
discrete fundamental group into a well-behaved invariant that *transforms
predictably* as you build a space up cell by cell. This is exactly the property
that makes an invariant useful rather than merely defined.

**It points upward.** The same template — generators, then relations, then
relations-among-relations — is the ladder that classical algebra climbs to reach
higher homotopy. In our setting the rungs are literal cubes: edges give
generators, squares give relations, and solid cubes should give the relations
among relations that compute the *second* discrete homotopy group. The boundary
of a hollow solid cube ought to behave like a two-dimensional sphere, detecting
a higher hole, while a fully filled cube should be contractible. The
one-dimensional theory pinned down here is the base of that ladder, and it fixes
the pattern for every step above it.

## The shape of things to come

Once you believe that filling a square kills a loop, a cascade of bold,
testable conjectures follows. Attaching an $n$-dimensional cube to a space that
is already connected in lower dimensions should induce a surjection on the
$(n-1)$-st discrete homotopy group whose kernel is generated by the boundary of
the new cube — while leaving all the lower homotopy untouched. Cubes, in other
words, are surgical: they only cut holes of their own dimension and never
disturb the floors below. Symmetries of the cubes — the coordinate swaps that
make these spaces "quasisymmetric" — should act on the fundamental group by
automorphisms, so that the homotopy of a symmetric quotient is exactly the part
fixed by the symmetry. And there should be a gluing law, a discrete van Kampen
theorem, that computes the fundamental group of a space assembled from two
overlapping pieces in terms of the pieces and their overlap.

Each of these is a precise, falsifiable statement, and each rests on the same
small foundation we have laid: a square, four edges, one generator, and the
single decisive act of filling it in. The empty square remembers its hole; the
filled square forgets. From that one bit of memory, an entire discrete world of
shape and connectivity unfolds.
