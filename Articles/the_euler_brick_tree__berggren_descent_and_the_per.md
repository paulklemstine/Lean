# The Brick Tree: Growing Euler's Impossible Box

## A box that shouldn't be hard

Take a shoebox. Measure its length, width and height. Then measure the diagonal
across each of its three faces, and finally the long diagonal that runs from one
bottom corner to the opposite top corner, through the air inside the box.

Seven numbers. The question Euler's contemporaries asked — and nobody has
answered in nearly three hundred years — is whether all seven can be whole
numbers at once.

A box that gets six of the seven right is called an **Euler brick**: integer
edges $x, y, z$ with all three face diagonals integral,
$$x^2 + y^2 = p^2, \qquad x^2 + z^2 = q^2, \qquad y^2 + z^2 = r^2 .$$
These exist, and the smallest is famous: the box with edges $44$, $117$ and
$240$, whose face diagonals are $125$, $244$ and $267$. Its space diagonal is
$\sqrt{44^2 + 117^2 + 240^2} = \sqrt{73{,}225} = 270.6\ldots$, agonizingly close
to $271$ but not an integer.

A box that gets all seven right — an Euler brick with
$x^2 + y^2 + z^2 = s^2$ — is a **perfect cuboid**. Nobody has ever found one.
Nobody has ever proved one cannot exist. Computer searches have swept every box
with smallest edge below $10^{10}$ and come back empty-handed.

This article is about a different way to attack the problem: not by searching a
grid of boxes, but by *growing* them on a tree.

## The tree that grows all right triangles

The story starts one dimension down, with Pythagorean triples — whole numbers
with $a^2 + b^2 = c^2$, like $(3,4,5)$ and $(5,12,13)$. There are infinitely
many, and at first glance they look scattered. They are not. There is a
beautiful piece of structure, discovered in the twentieth century, that
organizes *every* primitive triple (one where $a$ and $b$ share no common
factor) into a single infinite ternary tree.

Here is how. Write a triple as a column vector and multiply by one of three
fixed matrices:
$$A = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix},
\qquad
B = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix},
\qquad
C = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}.$$
Feed in $(3,4,5)$ and you get out $(5,12,13)$, $(21,20,29)$ and $(15,8,17)$.
Feed those in and you get nine more. And so on for ever.

The remarkable theorem is that this tree is *exactly* the set of primitive
triples with odd first leg — nothing is missed, and nothing appears twice. Going
downward is easy (multiply); the real content is going *upward*: every triple
other than $(3,4,5)$ has one and only one parent among the three inverse maps
that is again a legitimate triple with a strictly smaller hypotenuse. Since the
hypotenuse is a positive integer that strictly decreases at each step, you
cannot descend for ever: every triple in the universe slides down, in finitely
many steps, to the seed $(3,4,5)$.

This is descent in Fermat's sense, made completely explicit and completely
finite. It turns an infinite set into a tree with one root and exactly $3^n$
nodes at depth $n$.

## Lifting the tree to boxes

Now the leap. There is a two-centuries-old recipe, attributable to the
eighteenth-century mathematician Nicholas Saunderson, that converts a right
triangle into a box. Given any Pythagorean triple $u^2 + v^2 = w^2$, form
$$x = u(4v^2 - w^2), \qquad y = v(4u^2 - w^2), \qquad z = 4uvw .$$

This box always has integral face diagonals, and one can see exactly why,
because the diagonals come out in closed form:
$$x^2 + y^2 = (w^3)^2, \qquad
x^2 + z^2 = \bigl(u(w^2 + 4v^2)\bigr)^2, \qquad
y^2 + z^2 = \bigl(v(w^2 + 4u^2)\bigr)^2 .$$
Two of these three are pure algebra — they are true for *any* $u, v, w$
whatsoever. Only the first uses the Pythagorean relation, and it uses it once.
The first face diagonal is a perfect cube, $w^3$; that is the fingerprint of the
construction.

Apply it to the seed $(3,4,5)$ and you get $x = 3(64-25) = 117$,
$y = 4(36-25) = 44$, $z = 4\cdot3\cdot4\cdot5 = 240$: the classical smallest
Euler brick, recovered as the root of a tree.

So the Berggren tree of triangles *becomes* a tree of boxes. The three matrices
act on the triangle underneath, and a whole infinite family of Euler bricks
unfurls from a single seed. Two facts make this a genuine tree rather than a
tangle: the recipe is injective on tree nodes — distinct triangles give distinct
boxes, which one proves by reading the hypotenuse $w$ off the first face
diagonal $w^3$ and then recovering $u$ and $v$ — and each node has exactly one
parent. The result is an exact census:

> **Growth Theorem.** Level $n$ of the brick tree contains exactly $3^n$
> pairwise distinct, nondegenerate Euler bricks, and every brick in the family
> descends to the root brick $(117, 44, 240)$ in finitely many steps.

## Every brick has a minimal ancestor

The tree covers one infinite family of bricks. What about all the others? Here a
second, cruder kind of descent applies to *every* Euler brick whatsoever.

If $(x,y,z)$ is an Euler brick and $g$ is a common factor of all three edges,
then $(x/g, y/g, z/g)$ is again an Euler brick. The reason is a small piece of
integer arithmetic: from $(ga)^2 + (gb)^2 = p^2$ we get $g^2 \mid p^2$, hence
$g \mid p$, and dividing through gives the smaller diagonal. Peel off the
greatest common divisor and you land on a brick with no common factor — a
**primitive** brick. So the primitive bricks are the minimal elements of the
whole brick world, and everything else is an integer dilation of one of them.

Primitive bricks are surprisingly rigid. Two odd edges are impossible: if $x$
and $y$ are both odd then $x^2 + y^2 \equiv 2 \pmod 4$, which no square is. All
three edges even is impossible by primitivity. So exactly one edge is odd — and
the other two are divisible by $4$, because pairing the odd edge with each even
edge in a Pythagorean relation forces the even leg to be a multiple of $4$.
Sieving through the primes $3$ and $5$ in the same style yields a classical
divisibility law with a clean proof:

> **The 720 Law.** For every primitive Euler brick, $720$ divides the product of
> the edges $xyz$.

For the root brick: $117 \cdot 44 \cdot 240 = 1{,}235{,}520 = 720 \times 1716$.
Note $720 = 16 \cdot 9 \cdot 5$: the $16$ is the two-adic rigidity just
described, the $9$ says at least two edges are divisible by $3$, the $5$ says
some edge is divisible by $5$. Any perfect cuboid, if one exists, must obey this
law too.

## Four conditions collapse into one

Here is where the tree earns its keep. Along the tree, three of the four square
conditions are *free* — the Saunderson recipe guarantees them. Only the space
diagonal is in doubt, and it turns out to be controlled by a single quantity.

Compute the square of the space diagonal of a generated brick. After using
$u^2 + v^2 = w^2$ once, it factors:
$$x^2 + y^2 + z^2 = w^2\,(w^4 + 16u^2v^2) .$$

The factor $w^2$ is already a square. So the box is perfect precisely when the
other factor is:

> **Reduction Theorem.** For a Pythagorean triple $(u,v,w)$ with $w \neq 0$, the
> generated brick is a perfect cuboid if and only if $w^4 + 16u^2v^2$ is a
> perfect square — equivalently, if and only if $(w^2, 4uv)$ are the legs of a
> Pythagorean triple.

(The "only if" direction needs one extra step: if $w^2 \cdot Q = s^2$ then
$w^2 \mid s^2$, so $w \mid s$, and cancelling $w^2$ shows $Q$ itself is a
square.)

Substituting $w^2 = u^2 + v^2$ turns the quartic into the symmetric shape
$$u^4 + 18u^2v^2 + v^4 ,$$
so the entire perfect-cuboid question on this infinite tree of boxes is:
*can $u^4 + 18u^2v^2 + v^4$ be a perfect square for coprime $u, v$ with
$uv \neq 0$?* Four simultaneous square conditions, three of them absorbed by the
construction, one left standing. That is the payoff of building the tree: it
compresses the problem into a single curve.

Notice what has happened: the missing condition is *itself* a Pythagorean
condition. The fourth square wants $(w^2, 4uv)$ to be legs of a right triangle —
so a perfect cuboid on the tree would be a node of the triangle tree whose
"diagonal triple" is again a node. The problem has become self-referential, and
that is a very suggestive place to be.

## Killing branches with clock arithmetic

Once the problem is one quartic, you can attack it with congruences: show that
$w^4 + 16u^2v^2$ is not a square *modulo* some small number, and no amount of
searching will ever produce a square.

The cleanest case is modulo $7$. Suppose a node has $u \equiv v \pmod 7$ with
$7 \nmid u$. Then $w^2 \equiv 2u^2$, so
$$w^4 + 16u^2v^2 \equiv 4u^4 + 2u^4 = 6u^4 \pmod 7 .$$
Fourth powers of nonzero residues mod $7$ are $1, 2$ or $4$, so $6u^4$ is $6, 5$
or $3$ — and the squares mod $7$ are exactly $0, 1, 2, 4$. Every possibility is
a nonresidue. The box over such a node is provably not perfect.

Is that a rare accident? No: the nodes $(m^2-1,\,2m,\,m^2+1)$ with
$m = 14j + 4$ satisfy the congruence for every $j \ge 0$, and they are genuine
tree nodes (primitive, odd first leg). Their boxes grow without bound. So:

> **Infinite Obstruction Theorem.** There are infinitely many nodes of the brick
> tree, with boxes of unbounded size, whose space-diagonal condition provably
> fails.

Better still, the obstruction *propagates*. Apply the second generator $B$ to a
node with $u \equiv v \pmod 7$, $7 \nmid u$, and the child satisfies exactly the
same two conditions — the first is a one-line algebraic identity, the second a
finite check modulo $7$. Starting from $(15,8,17)$ (the third child of the seed)
and iterating $B$ forever produces an infinite path

$$(15,8,17) \to (65,72,97) \to (403,396,565) \to (2325,2332,3293) \to \cdots$$

on which every single box is a genuine Euler brick and no box is a perfect
cuboid. An infinite obstructed branch, with a uniform certificate.

## Why one congruence can never finish the job — exactly

The tempting next move is to find a congruence covering a *thick* part of the
tree. If some modulus certified an entire binary subtree, the obstructed set
would grow exponentially and one could dream of covering everything.

It cannot be done with modulo $7$, and this can be made precise. Reduce a node
to its residue triple in $(\mathbb{Z}/7)^3$; the generators $A$ and $B$ act on
these $343$ states. A finite check over all of them proves:

> **Escape Theorem.** From *every* residue state, at least one of the four short
> words $\varepsilon$, $A$, $AA$, $AB$ reaches a state where
> $w^4 + 16u^2v^2$ *is* a square mod $7$ — so the certificate no longer applies.

The consequence is immediate and sharp:

> **No Certified Subtree.** There is no node of the tree from which the entire
> binary subtree generated by $A$ and $B$ is certified by the mod-$7$
> obstruction.

So the infinite branch found above is the *most* this congruence can see: a
one-dimensional path inside a two-dimensional (indeed three-dimensional) tree,
a set of density zero. The local picture at $(15,8,17)$ says it in miniature:
its $B$-child $(65,72,97)$ is certified, and stays certified for ever; its
$A$-child $(33,56,65)$ and its $C$-child $(35,12,37)$ both escape within a
single step. The obstruction really is a branch, and only a branch.

This is a genuinely useful negative result. It tells you that no finite
collection of congruences will settle the perfect-cuboid question along the
tree, because local conditions at a fixed modulus obstruct only a zero-density
set. The difficulty is global, and the next move must be a global one: a descent
on the quartic curve itself.

## What the search says

Complementing the structural work, the first four levels of the tree — all $40$
nodes with depth at most three — have been checked exhaustively, each with an
explicit witness. For every one of them the quartic sits strictly between two
consecutive squares, so it cannot be a square. For the root, $2929$ lies between
$54^2 = 2916$ and $55^2 = 3025$; for $(5,12,13)$, $86161$ lies between $293^2$
and $294^2$; and so on through all forty. This is not a floating-point check
but a trapping inequality, valid exactly.

Extending the same sweep far past that (into the thousands of nodes, where boxes
have dozens of digits) still turns up nothing, and roughly half of all nodes are
killed outright by the mod-$7$ test alone. The empirical picture matches the
structural one: no perfect cuboid, but no congruence covering everything either.

## Where the problem now lives

Here is the landscape after all this. The space of Euler bricks has a genuine
Berggren-style architecture. There is a generator turning triangles into boxes;
a tree with one seed and exactly $3^n$ nodes at depth $n$, in which every node
has a unique parent and every brick descends to $(117,44,240)$; a separate,
elementary descent taking any brick at all down to a primitive one; and rigid
arithmetic laws — one odd edge, $720 \mid xyz$ — constraining every candidate.

Over that architecture, the perfect-cuboid question for this whole infinite
family is *exactly one Diophantine question*: is $u^4 + 18u^2v^2 + v^4$ ever a
square for coprime $u,v$ with $uv \ne 0$? This is a genus-one curve in disguise.
Its Jacobian is the elliptic curve $y^2 = x(x-16)(x-20)$, which carries full
rational $2$-torsion — and that is a gift, because a complete $2$-descent on
such a curve is elementary, reducing to a handful of coprime factorizations
$x = d e^2$ with $d$ dividing $320$, each branch a small system settled by parity
and quadratic residues. If that descent closes, the conclusion is a theorem:
*no member of the Saunderson family over any primitive triple is a perfect
cuboid* — the first structural non-existence result for a full parametric family
of Euler bricks.

That would not resolve the perfect cuboid problem; boxes not of Saunderson shape
would remain. But it would do something that three centuries of search has not:
convert a question about hunting for a needle into a question about the shape of
a curve, and then answer it. And it would tell us exactly where the difficulty
of the perfect cuboid lives — not in any single congruence, not in any bounded
search, but in the rational points of one quartic curve that the tree hands us
on a plate.

Euler's box is still out there, or still isn't. But it is no longer a box in a
haystack. It is a point on a curve, at the end of a branch we now know how to
grow.
