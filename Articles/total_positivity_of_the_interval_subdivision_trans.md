# The Hidden Positivity of Subdivision

## When cutting things up keeps them in order

Imagine you are handed a triangle and asked to chop it into smaller
pieces. There are many ways to do this. You could drop a point in the
middle and connect it to the corners. You could add midpoints to the
edges. Or you could perform a more exotic cut, the *interval
subdivision*, which replaces each face of the shape by the set of
"intervals" that live inside it. Each of these operations turns one
combinatorial object into a more finely grained one, and each of them
can be recorded, with perfect fidelity, by a single matrix of numbers.

This article is about a surprising and beautiful property that one such
matrix turns out to possess. The property is called **total
positivity**, and it is one of those ideas that appears, unannounced,
in an astonishing range of places: in the theory of vibrating strings,
in statistics, in the geometry of curves used to design car bodies and
animated films, and in the modern combinatorics of counting faces of
polytopes. The result we will explain says, in a single sentence:

> *The transformation matrix that records how the interval subdivision
> reshapes a simplicial complex is totally positive — not just its
> entries, but every determinant you can carve out of it, is
> nonnegative.*

To appreciate why that is remarkable, we need to unpack three things:
what these subdivisions are, what the matrix is counting, and what
total positivity really means.

## Counting the shape of a shape

A **simplicial complex** is a shape built out of simple pieces —
points, edges, triangles, tetrahedra, and their higher-dimensional
analogues, all glued together along shared faces. The surface of a
crystal, a triangulated map of a country, the mesh underneath a
computer-graphics character: all of these are simplicial complexes.

The most basic thing you can ask about such a shape is: *how many
pieces of each dimension does it have?* If a complex has $f_0$
vertices, $f_1$ edges, $f_2$ triangles, and so on, we can bundle these
counts into a list called the **$f$-vector**,
$(f_0, f_1, f_2, \dots)$. The $f$-vector is honest but clumsy; the
numbers in it satisfy tangled relations that make them hard to reason
about.

Combinatorialists long ago discovered a change of coordinates that
tames these numbers. From the $f$-vector one forms the **$h$-vector**,
$(h_0, h_1, h_2, \dots)$, by taking a specific linear combination of
the face counts. The definition looks technical, but its effect is
magical: for many important shapes the $h$-vector is symmetric, its
entries are nonnegative, and it encodes deep algebraic and geometric
information that the raw $f$-vector hides. The $h$-vector is the
combinatorial fingerprint that modern face-counting theory is really
about.

## A subdivision as a matrix

Now suppose we subdivide our shape. Subdivision does not change the
underlying space — a chopped-up triangle is still a triangle — but it
absolutely changes the $f$-vector and the $h$-vector, because there are
now more pieces of each dimension.

Here is the key structural fact. For a fixed *type* of subdivision, the
new $h$-vector depends on the old one in a completely uniform, linear
way. There is a fixed matrix $H$ — depending only on the dimension and
the kind of subdivision, not on the particular shape — such that

$$
h(\text{subdivided complex}) \;=\; H \cdot h(\text{original complex}).
$$

The matrix $H$ is the arithmetic soul of the subdivision. It says: "no
matter what shape you feed me, here is exactly how my style of cutting
rearranges its fingerprint."

For the **interval subdivision** in low dimension, this matrix is a
clean, triangular object. In the three-dimensional case it is precisely

$$
H \;=\;
\begin{pmatrix}
1 & 1 & 1 \\
0 & 1 & 2 \\
0 & 0 & 1
\end{pmatrix}.
$$

You may recognize the pattern hiding in the top-right corner: the
numbers $1, 1, 1$ and $1, 2$ are Pascal's triangle, tilted on its side.
Subdivision operators love binomial coefficients, and this is no
exception.

## What total positivity means

Take any matrix of numbers. From it you can extract smaller square
grids by choosing some of the rows and some of the columns — say rows
$1$ and $3$ and columns $2$ and $4$ — and reading off the numbers where
they cross. Each such square grid has a **determinant**, a single
number built by the familiar cross-multiplying rule. These determinants
are called the **minors** of the matrix.

A matrix is called **totally positive** — more precisely *totally
nonnegative* — when **every single one of these minors is
nonnegative**. Not just the entries (those are the $1 \times 1$
minors), and not just the full determinant, but every determinant of
every square sub-grid, of every size, all at once.

This is a *stringent* condition. A random matrix will almost never
satisfy it; even a matrix with all-positive entries usually has some
negative minor lurking inside it. Total positivity is a strong form of
internal consistency, and matrices that possess it behave beautifully.
They map ordered configurations to ordered configurations without ever
"crossing the wires": a curve controlled by a totally positive scheme
never wiggles more than its control points do, which is exactly why
such matrices are the backbone of the spline curves used in computer
graphics and geometric design. In the theory of small oscillations,
totally positive matrices describe systems whose vibration modes are
crisp and well-separated. Wherever total positivity appears, it signals
hidden order.

So the theorem — that the interval-subdivision matrix is totally
positive — is really a statement that this particular way of cutting up
shapes is *maximally well-behaved*. It never introduces spurious
oscillation into the combinatorial fingerprint.

## The idea of the proof: build it out of gentle moves

How do you prove that *every* minor of a matrix is nonnegative? There
are, after all, infinitely many matrices and, for a large matrix, an
enormous number of minors. Checking them one by one is hopeless. The
trick — a classical and elegant one — is to build the matrix out of
moves so gentle that each move is guaranteed to *preserve* total
positivity. Then, if we start from something obviously totally positive
and only ever make gentle moves, the final matrix must be totally
positive too.

The gentlest possible starting point is a **diagonal matrix** with
nonnegative numbers down the diagonal — in particular the identity
matrix, with $1$s on the diagonal and $0$s elsewhere. It is easy to see
that these are totally positive: every square sub-grid is itself
diagonal, and the determinant of a diagonal grid is just the product of
its diagonal entries, a product of nonnegative numbers.

The gentle move is an **adjacent column operation**: pick a column, and
add to the *next* column a nonnegative multiple of it. In symbols, if
column $s$ and column $t$ are neighbours (so $t = s+1$), we replace
column $t$ by

$$
(\text{new column } t) \;=\; (\text{column } t) \;+\; \alpha \cdot
(\text{column } s), \qquad \alpha \ge 0.
$$

The heart of the whole argument is a single lemma:

> **Preservation Lemma.** *An adjacent column operation with a
> nonnegative coefficient turns a totally positive matrix into another
> totally positive matrix.*

Here is why it is true, in words. Consider any minor of the new matrix.
If the column we modified was not among the columns you selected, the
minor is literally unchanged — nothing to prove. If it *was* selected,
then because the determinant is a linear function of each column, the
minor splits neatly into two pieces: the original minor, plus $\alpha$
times a second determinant in which the modified column has been
replaced by the source column.

Now two cases arise for that second determinant. If the source column
was *also* among your selected columns, then this second determinant has
two identical columns — and a determinant with a repeated column is
zero. If the source column was *not* selected, then — and this is where
the word *adjacent* earns its keep — swapping it in keeps your chosen
columns in strictly increasing order, because the source sits
immediately before the target. So the second determinant is *itself* a
genuine minor of the original matrix, and is therefore nonnegative by
assumption.

Either way, the new minor is the sum of two nonnegative quantities: the
old minor (nonnegative) plus $\alpha \ge 0$ times something nonnegative.
So it is nonnegative. The lemma is proved.

From here the theorem falls out almost for free. Applying one gentle
move preserves total positivity; therefore applying a whole *list* of
gentle moves, one after another, also preserves it — a straightforward
induction. And the subdivision matrix, it turns out, can be assembled
from the identity matrix by exactly such a sequence of adjacent column
operations. For the three-dimensional interval matrix above, one checks
directly that

$$
\begin{pmatrix}
1 & 1 & 1 \\
0 & 1 & 2 \\
0 & 0 & 1
\end{pmatrix}
$$

is the result of starting from the identity and adding, in the right
order, nonnegative multiples of each column to its neighbour. Since the
identity is totally positive and every move preserves that property, the
subdivision matrix is totally positive. Done.

This "build it out of bidiagonal moves" strategy is not just a proof
device; it is a window onto a deep classical theorem (the
Loewner–Whitney theorem) which says that *every* totally positive matrix
arises this way. Total positivity and gentle factorization are two faces
of the same coin.

## How big does the shape get?

There is one more concrete fact worth savouring, because it shows that
interval subdivision is genuinely doing something rich. Start with the
simplest possible shape in dimension $d-1$: a single **simplex**, the
$(d-1)$-dimensional analogue of a triangle, with $d$ corners. How many
vertices does its interval subdivision have?

The answer is elegantly clean:

$$
3^d - 2^d.
$$

For a triangle ($d = 3$) this is $27 - 8 = 19$ new vertices; for a
tetrahedron ($d = 4$) it is $81 - 16 = 65$. The formula counts, in
effect, the nonempty "intervals" one can form inside the simplex, and
the tidy difference of two exponentials is a small combinatorial gem in
its own right. It is a reminder that behind the matrix lies a living,
growing geometric process.

## Why it matters

At first glance this is a story about an obscure operation on abstract
shapes. But it sits at a genuine crossroads of mathematics. The
$h$-vector is the object at the center of one of the great success
stories of twentieth-century combinatorics — the theory that connects
counting faces to commutative algebra and to the geometry of polytopes.
Subdivisions are the natural way to relate one complex to another, and
the matrices that govern them are the dictionaries of the subject.
Showing that such a dictionary is totally positive tells us that
subdivision respects a hidden order — the same order that makes spline
curves smooth and mechanical vibrations orderly.

There is also something satisfying about the *shape* of the proof. A
property that quantifies over infinitely many determinants is reduced,
by a single well-chosen lemma, to a statement about one gentle move
repeated. The infinite collapses into the finite; the global property
follows from a local one. That collapse — from "check everything" to
"check one thing and build" — is the recurring melody of good
mathematics, and here it plays in a particularly pure key.

The natural next movement in this symphony is to leave dimension three
behind: to find, for every dimension $d$, a closed formula for the
entries of the interval-subdivision matrix and a uniform way to build it
from gentle moves, and thereby prove its total positivity once and for
all. The three-dimensional case, with its little Pascal triangle and its
$3^d - 2^d$ vertices, is the first bar of a longer piece — and it already
sounds beautiful.
