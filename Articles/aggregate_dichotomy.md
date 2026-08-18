# The Arithmetic of Forgetting: What a Product Remembers About a Family of Right Triangles

## A very old multiplication

Around the year 628, the Indian mathematician Brahmagupta wrote down an identity that still
feels like a magic trick:

$$(a^2+b^2)(a'^2+b'^2) = (aa'-bb')^2 + (ab'+ba')^2.$$

Read it slowly. On the left is the product of two sums of two squares. On the right is again
a sum of two squares. So sums of two squares are *closed under multiplication*: multiply two
of them and you never leave the family.

Translated into geometry, this says something charming about right triangles. Take the
$3$–$4$–$5$ triangle and the $5$–$12$–$13$ triangle. Feed their legs into the identity:
$$a a' - b b' = 3\cdot 5 - 4\cdot 12 = -33,\qquad a b' + b a' = 3\cdot 12 + 4\cdot 5 = 56,$$
and indeed $33^2 + 56^2 = 1089 + 3136 = 4225 = 65^2$. Out of two right triangles with whole
number sides we have manufactured a third, with hypotenuse $5 \cdot 13 = 65$.

The cleanest way to see why this works is to leave the plane of triangles and enter the plane
of *Gaussian integers*, the complex numbers $z = a + bi$ with $a$ and $b$ whole. The size of
such a number is measured by its norm $N(a+bi) = a^2+b^2$, and the norm is multiplicative:
$N(zw) = N(z)N(w)$. A Pythagorean triple $(a,b,c)$ with $a^2+b^2=c^2$ is nothing but a
Gaussian integer whose norm is a perfect square, and Brahmagupta's identity is just the
statement that multiplying two such numbers multiplies their norms. The hypotenuse comes
along for free: it multiplies too.

This little algebra is the starting point of a question that turns out to have a surprisingly
sharp answer. It is a question about **memory**.

## The compression question

Suppose I hand you not one triangle but a whole *family* of them: an ordered list
$$f = \big(t_1, t_2, \dots, t_n\big)$$
of Pythagorean triples. You would like to compress this list into a single object — one
number, one triple, one anything — in a way that loses nothing. Compression schemes are
everywhere in mathematics: a polynomial's coefficients get compressed into its value at a
point; a group's elements get compressed into a product; a data set gets hashed.

The most natural compression available here is the one Brahmagupta handed us. Just multiply
the whole family together:
$$\Pi(f) \;=\; t_1 \cdot t_2 \cdots t_n,$$
using the Brahmagupta product at every step. The result is a single Pythagorean triple. Call
it the **unlabeled product**. It is beautifully canonical: it is defined purely in terms of
the structure of the objects, it lives in the same world as its inputs, and it is easy to
compute.

Does it remember the family?

## Symmetry is destiny

It does not, and the reason is not an accident of arithmetic. It is a reason of pure
symmetry, and it disqualifies not just this scheme but an entire class of schemes at once.

> **The Symmetric Aggregate Obstruction.** Let $n \geq 2$. Suppose $F$ is *any* rule that
> assigns to each ordered family $(t_1,\dots,t_n)$ of Pythagorean triples some output
> $F(t_1,\dots,t_n)$ — in any target set whatsoever — with the single property that
> permuting the family does not change the output. Then $F$ cannot be injective: two
> different families must receive the same value.

The proof is one line, and it is the kind of one line that makes a subject feel inevitable.
Take the family whose first entry is the $3$–$4$–$5$ triangle and whose other entries are the
trivial triple $(1,0,1)$ — the multiplicative identity. Now swap the first two slots. The
family has genuinely changed, because $3$–$4$–$5$ is not the trivial triple. But the value of
$F$ has not changed, because $F$ is permutation-invariant. Two different families, one value.
Done.

Since the Brahmagupta product is commutative, it is permutation-invariant, so the
obstruction applies: **the unlabeled product of a family of $n \ge 2$ Pythagorean triples
never determines the family.**

## But it is worse than order

A natural response: "Fine, the product forgets the *order*. Who cares? Ask instead whether it
remembers the family as an unordered collection — a multiset." That is a real question, and
the answer is still no. Order is not the only casualty.

Here is the witness, and it is pretty. Square the two triangles we started with:
$$(3+4i)^2 = -7 + 24i \;\leftrightarrow\; (-7,24,25), \qquad (5+12i)^2 = -119+120i
\;\leftrightarrow\; (-119,120,169),$$
and separately multiply them:
$$(3+4i)(5+12i) = -33+56i \;\leftrightarrow\; (-33,56,65).$$
Then the unordered pair $\{(-7,24,25),\,(-119,120,169)\}$ and the unordered pair
$\{(-33,56,65),\,(-33,56,65)\}$ are different collections of triples — but their products
agree:
$$(-7+24i)(-119+120i) \;=\; -2047-3696i \;=\; (-33+56i)^2 .$$
Both give the triple $(-2047,-3696,4225)$, with hypotenuse $4225 = 65^2$. The identity behind
it is nothing more mysterious than $z^2 w^2 = (zw)^2$; but as a statement about *collections
of right triangles* it says that the product genuinely conflates distinct collections. The
loss of information is arithmetic, not merely combinatorial.

Could we patch this by carrying more data along? A natural attempt: record the product **and**
the multiset of hypotenuses, since the hypotenuses feel like a fingerprint. That repair also
fails, and again the counterexample is concrete and non-degenerate. The number $65 = 5\cdot13$
factors in the Gaussian integers in two essentially different ways, and multiplying the pieces
in two different pairings gives
$$(63-16i)(63+16i) = 4225 = (-33+56i)(-33-56i).$$
All four Gaussian integers here have norm $65^2$, i.e. all four correspond to Pythagorean
triples with hypotenuse exactly $65$, and none of them has a vanishing leg. So the two
collections $\{(63,-16,65),(63,16,65)\}$ and $\{(-33,56,65),(-33,-56,65)\}$ are different, yet
they share both their product $(4225, 0, 4225)$ and their multiset of hypotenuses
$\{65,65\}$. **No amount of hypotenuse bookkeeping restores memory.**

## Exactly how much is forgotten

Failure is one thing; *measured* failure is another. It turns out one can say precisely how
much the product forgets, and the answer is governed by a group of order four.

Which triples are invertible under the Brahmagupta product? A triple $(a,b,c)$ has an inverse
exactly when its hypotenuse is $c = 1$, and then $a^2+b^2=1$ forces
$$(a,b) \in \{(1,0),\,(-1,0),\,(0,1),\,(0,-1)\},$$
the four *rotations* $1, -1, i, -i$ of the Gaussian plane. So the invertible triples form the
cyclic group of order four generated by the quarter turn $i = (0,1,1)$: powers of the quarter
turn cycle $1 \to i \to -1 \to -i \to 1$, and nothing else is invertible.

This unit group is exactly the engine of the collapse. Given any family, pick two slots, and
multiply one slot by a rotation and the other by that rotation's inverse. The family changes;
the product does not. This gives, from every family with a non-degenerate entry, four
distinct families sharing its product. Consequently:

> **Nowhere injectivity.** For families of length two, *every* family shares its product with
> some other family. There is no "rigid" configuration hiding somewhere; the collapse is
> uniform across the entire space.

And the count is exact. Consider families of length $n+1$ whose product is the trivial
triple $(1,0,1)$. Every entry of such a family must be invertible (its hypotenuse divides $1$),
hence a power of the quarter turn. So a family in this fibre is precisely a vector of
exponents $(v_0,\dots,v_n)$ with each $v_j$ taken modulo $4$, subject to the single condition
$$v_0 + v_1 + \cdots + v_n \equiv 0 \pmod 4 .$$
That is a hyperplane in $(\mathbb{Z}/4)^{n+1}$: choose the first $n$ exponents freely and the
last is forced. Hence:

> **The fibre over the identity has exactly $4^{\,n}$ elements** for families of length $n+1$.

For $n+1 = 2$ this says the fibre has four elements: the pairs $(1,1)$, $(-1,-1)$, $(i,-i)$,
$(-i,i)$ — the four rotation pairs and nothing else. The redundancy of the product is *exactly*
the order of the rotation group raised to the number of free slots.

One more pathology deserves mention. The degenerate triple $(0,0,0)$ is an absorbing element:
multiply anything by it and you get it back. So the collection of length-two families whose
product is $(0,0,0)$ is *infinite* — a black hole in which all information disappears.

## The other side of the dichotomy

Now the constructive half of the story. Is there a compression that *does* remember
everything? Yes, and once you see the obstruction you know exactly what such a scheme must
look like: it must not be symmetric. It has to reference *position*.

The simplest device is to interleave. First note that the hypotenuse of a triple with $c \ge 0$
is redundant — it is determined by the legs, since $c = \sqrt{a^2+b^2}$ and the sign is fixed.
So each triple is faithfully captured by its pair of legs, hence by a single natural number
via any standard pairing of integers. Now fold a family into one natural number by pairing the
code of its first member with the (recursively formed) code of the rest. This **interleaved
aggregate** is injective for families of *every* length: unwinding the pairing recovers each
member together with the slot it occupied.

Putting the two halves together gives the result the whole story has been building toward.

> **Aggregate Dichotomy.** For every $n \ge 2$: the unlabeled Brahmagupta product on families
> of $n$ Pythagorean triples is not injective, while the interleaved aggregate is injective.

And the relationship between the two is one of strict refinement. From the interleaved
aggregate you can always recover the product — decode the family, then multiply. From the
product you can *never* recover the interleaved aggregate when $n \ge 2$, since a recovery map
would make the product injective. So the product is a genuine quotient of the interleaved
aggregate, not merely a different summary.

## Keeping it inside the arithmetic

The interleaved aggregate works, but it feels like cheating: it leaves the arithmetic world
and lands in the world of encodings. Can we have a faithful aggregate that lives in the very
same algebraic universe as the product — the Gaussian integers themselves?

We can, and the answer is the oldest idea in numeration: **place value**. Fix a base $B$ and
send the family $(t_0,\dots,t_{n-1})$, with Gaussian integers $z_0,\dots,z_{n-1}$, to
$$G_B(f) \;=\; z_0 + z_1 B + z_2 B^2 + \cdots + z_{n-1}B^{\,n-1} \in \mathbb{Z}[i].$$
The multiplicative aggregate $\prod z_j$ and the additive positional aggregate $\sum z_j B^j$
are built from *exactly the same data*. One forgets the labels; the other keeps them.

Keeping them requires a hypothesis, and it is precisely the classical condition for balanced
digit expansions: every coordinate must satisfy $2|a_j| < B$ and $2|b_j| < B$. Under that
bound the positional aggregate is injective, because balanced base-$B$ digit strings are
unique. The proof is a clean induction: reduce modulo $B$ to pin down the lowest digit — the
difference of two lowest digits has absolute value less than $B$ yet is divisible by $B$,
hence vanishes — then divide by $B$ and repeat.

The bound is sharp; it cannot be relaxed from $<$ to $\le$. In base $B = 2$ the families
$\big((1,0,1),(0,0,0)\big)$ and $\big((-1,0,1),(1,0,1)\big)$ have coordinates satisfying
$2|\cdot| \le 2$ but not $2|\cdot| < 2$, and both aggregate to the Gaussian integer $1$:
indeed $1 + 0\cdot 2 = 1 = -1 + 1\cdot 2$. Injectivity sits exactly at the balanced-digit
threshold.

And the separation is visible in a single example. The two orderings of the family
$\{(3,4,5),(5,12,13)\}$ have the same product, namely $(-33,56,65)$. In base $100$ their
positional aggregates are
$$503 + 1204\,i \qquad\text{and}\qquad 305 + 412\,i,$$
manifestly different. The digits still read off the original triangles: $\dots 05\,03$ and
$\dots 12\,04$ in the first case. Nothing has been forgotten.

## Why the dichotomy matters

Strip away the triangles and a general principle remains, one that recurs across mathematics
and computing. **A summary that treats its inputs symmetrically cannot be faithful.** Sorted
hashes, unordered checksums, symmetric polynomial fingerprints, commutative accumulators —
all of them collapse, and the collapse is forced by the symmetry alone, before any arithmetic
enters. To be faithful, a summary must break the symmetry, and the standard way to break it is
to give each input a position: interleave the streams, or weight them by powers of a base.

The Pythagorean setting makes the trade-off unusually vivid because both aggregates are
natural, both live in the Gaussian integers, and the exact size of the collapse can be
computed: the fibre over the identity in length $n+1$ has precisely $4^n$ points, the four
Gaussian rotations acting freely in each of the $n$ free slots. Two summaries built from the
same numbers, one a quotient of the other by a group of symmetries — that is the aggregate
dichotomy, and it is as sharp as one could ask for.
