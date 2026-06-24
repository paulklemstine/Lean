# The Hidden Linear Heart of Every Right Triangle

## A family tree for the Pythagorean theorem

Almost everyone meets the equation $a^2 + b^2 = c^2$ as a child, usually
attached to the picture of a right triangle and the name of Pythagoras. Far
fewer people ever learn the strange and beautiful fact that *all* of its whole-number
solutions can be arranged into a single, infinite family tree — one root, and from
every node exactly three children, forever.

A **Pythagorean triple** is a trio of positive whole numbers $(a, b, c)$ with
$a^2 + b^2 = c^2$. The famous smallest example is $(3, 4, 5)$, since
$9 + 16 = 25$. Next come $(5, 12, 13)$, $(8, 15, 17)$, $(7, 24, 25)$, $(20, 21, 29)$,
and on and on. We call a triple **primitive** when $a$, $b$, and $c$ share no common
factor — so $(3, 4, 5)$ is primitive, but its scaled copy $(6, 8, 10)$ is not. Every
Pythagorean triple is just a whole-number multiple of a primitive one, so the
primitives are the "atoms" from which all right triangles with whole sides are built.

In 1934 the Swedish mathematician B. Berggren discovered something astonishing about
these atoms: if you start from $(3, 4, 5)$ and repeatedly apply three fixed
arithmetic recipes, you generate **every** primitive triple exactly once, and never
produce a repeat or a non-primitive. The primitives form a perfect *ternary tree* —
a tree in which every node branches into precisely three children. No triple is
orphaned, none appears twice, and the whole infinite zoo of right triangles is laid
out with the tidy regularity of a family genealogy.

Berggren's three recipes are usually written as three $3\times 3$ matrices that act on
the column $(a, b, c)$. They look forbidding. The first one, for instance, sends
$(a, b, c)$ to

$$(a - 2b + 2c,\; 2a - b + 2c,\; 2a - 2b + 3c).$$

The other two are similar tangles of plus and minus signs. They *work* — you can check
by hand that feeding $(3, 4, 5)$ into this first recipe yields $(5, 12, 13)$ — but
they offer no intuition. Why these particular coefficients? Why three branches and not
two or four? Where does the magic come from? This article is about a clean answer to
those questions, and about a small mathematical result that pins the answer down with
complete rigor.

## A change of coordinates that changes everything

The key is an old idea, going back to Euclid himself. Every primitive Pythagorean
triple can be written in terms of two "seed" numbers $m$ and $n$:

$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2.$$

You can verify in one line that this is always a Pythagorean triple:
$(m^2 - n^2)^2 + (2mn)^2 = (m^2 + n^2)^2$. Choosing $m = 2$ and $n = 1$ gives
$(4 - 1, \, 4, \, 4 + 1) = (3, 4, 5)$, our root. Choosing $m = 3, n = 2$ gives
$(5, 12, 13)$. To get *primitive* triples with positive legs, the seeds must satisfy
three modest conditions: $m > n > 0$; $m$ and $n$ share no common factor; and $m$ and
$n$ have **opposite parity** (one even, one odd). Call a pair $(m, n)$ meeting all three
a **valid generator pair**. Euclid's parametrization is a perfect dictionary: valid
pairs correspond exactly to primitive triples.

Here is the punchline. The whole reason Berggren's matrices look so ugly is that
we are looking at them in the wrong coordinates. The triple $(a, b, c)$ is a
*quadratic* shadow of the seed pair $(m, n)$ — the formulas involve $m^2$, $n^2$, and
$mn$. If instead we track what Berggren's recipes do to the seeds themselves, the
quadratic fog lifts and three breathtakingly simple rules appear:

$$A:(m, n) \mapsto (2m - n,\; m), \qquad
  B:(m, n) \mapsto (2m + n,\; m), \qquad
  C:(m, n) \mapsto (m + 2n,\; n).$$

No squares. No subtraction-of-three-terms. Just small integer combinations of $m$ and
$n$ — *linear* maps, the simplest kind of transformation there is. The root seed is
$(2, 1)$, the seeds of $(3, 4, 5)$. Apply $A$ and you get $(3, 2)$, the seeds of
$(5, 12, 13)$. Apply $B$ and you get $(5, 2)$, the seeds of $(21, 20, 29)$. Apply $C$
and you get $(4, 1)$, the seeds of $(15, 8, 17)$. The monstrous $3\times 3$ matrices
were always just these three baby maps wearing a disguise.

The central result that makes this precise is a single commuting square. Write
$q(m, n)$ for Euclid's recipe $(m^2 - n^2, \, 2mn, \, m^2 + n^2)$. Then for each of the
three branches, **applying Berggren's matrix after $q$ equals applying $q$ after the
simple linear map**:

$$\text{Berggren}_{\text{branch}}\bigl(q(m, n)\bigr) = q\bigl(\text{paramMap}_{\text{branch}}(m, n)\bigr).$$

In words: it does not matter whether you climb the tree in the world of triples or in
the world of seeds — you land on the same triple either way. The two trees are the same
tree, drawn in two coordinate systems. This is the heart of the whole story, and it can
be checked by pure algebra: expand both sides and every term cancels.

## Why the disguise existed

There is a deeper reason the squares should melt away, and it is worth a moment.
Pair the seeds into a single complex number $z = m + ni$, a so-called Gaussian integer.
Then Euclid's recipe is almost exactly the operation of **squaring**:
$z^2 = (m^2 - n^2) + (2mn)\,i$, whose real and imaginary parts are the two legs of the
triple, and whose squared length is the hypotenuse. The triple world is the *squared*
world; the seed world is the world before squaring. Squaring is what turns a linear
action into a quadratic one. So when we undo the squaring — when we step back from
triples to seeds — a quadratic transformation must collapse into a linear one. The
three Berggren branches are, underneath, just multiplication of the column $(m, n)$ by
three small integer matrices, each with determinant $\pm 1$:

$$A = \begin{pmatrix} 2 & -1 \\ 1 & 0 \end{pmatrix}, \quad
  B = \begin{pmatrix} 2 & 1 \\ 1 & 0 \end{pmatrix}, \quad
  C = \begin{pmatrix} 1 & 2 \\ 0 & 1 \end{pmatrix}.$$

This is the same kind of structure — matrices of determinant $\pm 1$ acting on integer
columns — that governs the geometry of the modular group, one of the most studied
objects in all of mathematics. The Pythagorean tree, it turns out, is a humble cousin
of that grand family.

## The tree really is a tree: three guarantees

A picture is only convincing if it is complete and non-redundant. Three facts, each
provable by elementary but careful reasoning, lock the structure in place.

**First, the recipes never break a valid seed pair.** If $(m, n)$ is a valid generator
pair, then so is each of $A(m, n)$, $B(m, n)$, and $C(m, n)$. Coprimality survives,
opposite parity survives, and the ordering $m > n > 0$ survives. So every child of a
right triangle is again a genuine, primitive right triangle. The tree never leaks out
of the family it is supposed to describe.

**Second, the recipes always grow the triangle.** Each branch strictly increases the
hypotenuse $m^2 + n^2$. Concretely, branch $A$ sends a pair with hypotenuse-seed
$m^2 + n^2$ to one with the larger value $(2m - n)^2 + m^2$, and similarly for $B$ and
$C$. Children are always bigger than their parents. This is what guarantees the tree has
no cycles: you can never wander forward and return to where you started, because the
hypotenuse keeps climbing.

**Third, and most beautifully, every seed pair has a unique parent.** Take any valid
pair other than the root $(2, 1)$. Compare $m$ to $n$:

- If $n < m < 2n$, it is the $A$-child of a smaller pair.
- If $2n < m < 3n$, it is the $B$-child of a smaller pair.
- If $m > 3n$, it is the $C$-child of a smaller pair.

The three ranges tile the possibilities perfectly. The only boundary case $m = 2n$
occurs solely at the root, and the case $m = 3n$ can *never* happen for a valid pair —
it would force $m$ and $n$ to share the same parity, which validity forbids. So the
trichotomy is clean: every non-root pair falls into exactly one band, and therefore has
exactly one parent obtained by running the matching recipe backward. Because each step
backward strictly *shrinks* the hypotenuse, repeatedly taking parents must terminate —
and the only place it can terminate is the root $(2, 1)$.

Put those three facts together and you have **completeness**: starting from $(2, 1)$ and
applying the three forward maps, you reach every valid seed pair, hence (through
Euclid's dictionary) every primitive Pythagorean triple, exactly once. The tree is
genuinely a tree, exhaustive and non-repeating, and the backward descent gives an
explicit address — a finite word in the three letters $A$, $B$, $C$ — for every right
triangle in existence.

## Reading a triangle's family history

This descent procedure is more than a proof device; it is an algorithm you can run.
Suppose someone hands you the triple $(20, 21, 29)$ and asks where it sits in the tree.
First recover its seeds: solving $m^2 + n^2 = 29$ and $m^2 - n^2 = 21$ gives
$m = 5, n = 2$. Now compare: $2n = 4$ and $3n = 6$, and $m = 5$ falls in the band
$2n < m < 3n$, so the last step was a $B$. Run $B$ backward — subtract to recover the
parent seeds $(2, 1)$ — and you are home at the root in a single step. The full address
of $(20, 21, 29)$ is therefore "$B$ from the root", i.e., it is a direct child of
$(3, 4, 5)$. Every triple gets such a fingerprint, and no two triples share one.

Try a longer one. The triple $(5, 12, 13)$ has seeds $(3, 2)$; since $n < m < 2n$
(because $2 < 3 < 4$), its last step was an $A$, with parent seeds $(2, 1)$ — the root
again. So $(5, 12, 13)$ is the $A$-child of $(3, 4, 5)$, and $(15, 8, 17)$, with seeds
$(4, 1)$ and $m = 4 > 3 = 3n$, is the $C$-child. The three smallest descendants of the
$(3,4,5)$ root are exactly the three triples Berggren's matrices produce — now each
labeled by which simple linear recipe built it.

## Why simplicity is the whole point

It would be easy to dismiss all this as bookkeeping: we already knew the primitive
triples formed a tree, and we have merely re-described it. But re-description is one of
the quiet engines of mathematics. The ugly $3 \times 3$ matrices hid the structure; the
$2 \times 2$ linear maps reveal it. Once you see the tree as living on seed pairs rather
than triples, a cascade of further questions becomes natural and answerable. The
single-branch "spines" of the tree — apply $B$ over and over, say — turn into classical
second-order recurrences of Pell type, the same numbers that arise in approximating
$\sqrt{2}$. The depth of a triple in the tree is governed by the continued-fraction
expansion of the ratio $m/n$ of its seeds. And the appearance of determinant-$\pm 1$
matrices points straight at the modular group and the rich theory that surrounds it.
None of these connections is visible from the original tangled coefficients; all of them
leap out once the coordinates are right.

There is a moral here that reaches well beyond right triangles. A hard-looking problem
is often a simple problem viewed through a warped lens. The art is to find the lens —
the change of coordinates, the right notion of "seed" — that flattens the warp. For the
Pythagorean tree, that lens is Euclid's two-thousand-year-old parametrization, read not
as a formula but as a *bridge* between two worlds: the quadratic world of triangles and
the linear world of their seeds. Cross that bridge and the oldest equation in
mathematics reveals an infinite, perfectly ordered family — every right triangle a node,
every node with three children, every child one short, simple step from its parent, all
the way down to a single common ancestor: the triangle $(3, 4, 5)$.
