# The Smallest Plane in Mathematics, and the Magic Number Six

## A puzzle with seven points

Imagine a tiny universe that contains exactly seven places and seven roads. Every
road passes through exactly three of the places, every place sits on exactly three
of the roads, and — most strikingly — any two places are joined by one and only one
road, while any two roads cross at one and only one place. There is no parallelism,
no waste, no redundancy. This object is real, it is famous, and it is the smallest
nontrivial geometry that exists. Mathematicians call it the **Fano plane**, written
$PG(2,2)$: the projective plane over the two-element field.

The Fano plane is the boundary of what geometry can be. Shrink any further and the
axioms collapse; the seven-point world is the irreducible seed from which all
projective planes grow. Because it is so small, it can be drawn on a napkin (a
triangle with its three midpoints, its center, and an inscribed circle through the
midpoints) and, more importantly, it can be *completely understood*. Every question
you can ask about it has a definite answer. This article is about one such question
with a surprisingly clean answer: **how few of its seven points can you keep and
still "see" every road clearly?** The answer is **six**, and proving that the answer
is exactly six — not five, not seven — turns out to connect pure geometry to the
hidden architecture of error-correcting codes.

## What it means to block a line

Picture yourself standing in this seven-point world holding a highlighter. You want
to mark a subset $S$ of the seven points so that, no matter which of the seven roads
you look at, the marked points lying on that road are enough to *pin the road down*.

What does "pin down" mean? Over the two-element field, a road (a projective line) has
exactly three points, and any **two** distinct points on it already determine the
whole road — two points span a line. So a road is "pinned down by $S$" precisely when
$S$ contains at least two of that road's three points. A single marked point is not
enough: one point lies on three different roads at once and cannot tell them apart.

A set $S$ that pins down *every* road in this way is called a **strong blocking set**.
The name comes from a family of objects studied across combinatorics and coding
theory: a blocking set merely *touches* every line; a strong blocking set does more —
its intersection with every line *generates* that line. Strong blocking sets are the
geometric shadow of some of the most useful objects in digital communication, as we
will see.

So here is the crisp question. Among all $2^7 = 128$ possible subsets of the seven
Fano points, which ones are strong blocking, and what is the *smallest* one?

## The answer, and why it is six

The main result is a clean dichotomy. Call a subset of the seven points strong
blocking if it meets every line in at least two points. Then:

> **Threshold theorem.** A subset $S$ of the seven Fano points is strong blocking
> **if and only if** it contains at least six of the seven points. Equivalently, $S$
> is strong blocking exactly when it omits at most one point. Consequently, the
> smallest possible strong blocking set has size exactly **six**.

Let us see why, because the argument is short and beautiful and uses the special
geometry of the Fano plane in an essential way.

**Six points always work.** Suppose you mark six points and leave out a single point
$p$. How many points does each road keep? There are exactly three roads through $p$;
each of them loses $p$ and keeps its other two points — still at least two, so still
pinned down. The other four roads do not pass through $p$ at all, so they keep all
three of their points. Every road survives with at least two marked points. The
six-point set $\text{(all points)} \setminus \{p\}$ is strong blocking. Concretely,
if we label the points $0,1,2,3,4,5,6$ and omit point $0$, the marked set
$\{1,2,3,4,5,6\}$ blocks all seven lines.

**Five points never work.** Now suppose you leave out *two* distinct points $p$ and
$q$. Here the defining miracle of the Fano plane intervenes: any two distinct points
lie on a **unique** common road. Call it $\ell_{pq}$. That road contains $p$, $q$,
and exactly one more point. Once you have discarded both $p$ and $q$, the road
$\ell_{pq}$ retains a single marked point — not enough to pin it down. So the road
$\ell_{pq}$ is no longer blocked, and $S$ fails. Since any set of five (or fewer)
points omits at least two points, no such set can be strong blocking.

Putting the two halves together: strong blocking is *exactly* the property of omitting
at most one point, which is *exactly* the property of having size at least six. The
minimum size is six, achieved by every "all-but-one-point" set and by nothing smaller.

Notice how lean the logic is. The forward direction rests entirely on the counting
fact that a point lies on three lines and each loses only itself; the backward
direction rests entirely on the uniqueness of the line through two points. Both are
defining features of $PG(2,2)$. Change the field — go from two elements to three —
and both halves of the argument break, which is exactly why the larger planes behave
differently (more on that below).

## A concrete walk-through

Let's make it tangible with the standard labelling of the Fano plane. Take the seven
points to be $\{0,1,2,3,4,5,6\}$ and the seven lines to be
$$\{0,1,2\},\ \{0,3,4\},\ \{0,5,6\},\ \{1,3,5\},\ \{1,4,6\},\ \{2,3,6\},\ \{2,4,5\}.$$
You can check by eye that each label appears in exactly three lines, and that any two
labels appear together in exactly one line.

Now mark the six points $S = \{1,2,3,4,5,6\}$ (we dropped $0$). Walk the lines:
$\{0,1,2\}$ keeps $1,2$; $\{0,3,4\}$ keeps $3,4$; $\{0,5,6\}$ keeps $5,6$; the other
four lines keep all three of their points. Every line has at least two survivors —
$S$ is strong blocking, as promised.

Try to do better with five points, say $S' = \{2,3,4,5,6\}$ (we dropped $0$ and $1$).
The unique line through $0$ and $1$ is $\{0,1,2\}$. After deletion it retains only the
single point $2$. That line is unblocked: $S'$ fails. No matter which two points you
drop, the unique line joining them will betray you. Six is genuinely the floor.

## From geometry to the wires in your phone

Why should anyone outside of finite geometry care that a seven-point toy world has a
magic number six? Because strong blocking sets are the geometric face of **minimal
linear codes**, and minimal codes are workhorses of modern information theory.

A binary linear code packages messages as vectors over the two-element field so that
errors introduced by a noisy channel can be detected and corrected. There is a
dictionary — the **projective system correspondence** — translating a code with
$k$ "dimensions" (independent message coordinates) into a collection of points in the
projective space $PG(k-1,2)$. The *length* of the code (how many bits it transmits per
codeword) becomes the *number of points* in the geometric picture.

Among codes, the **minimal** ones are prized: a code is minimal when no codeword's
pattern of nonzero positions is contained inside another's. Minimal codes are exactly
what you want for **secret-sharing schemes** (where the "minimal" codewords encode
precisely the authorized coalitions that can reconstruct a secret) and for certain
**secure two-party computation** protocols. And here is the punchline of the
dictionary: **a code is minimal precisely when its associated point set is strong
blocking.** Minimality, an algebraic condition about codewords, is the very same thing
as strong blocking, a geometric condition about lines.

So our threshold theorem, translated through the dictionary, says something concrete
about communication:

> The shortest nondegenerate minimal binary linear code of dimension $3$ has length
> exactly $6$.

In words: if you insist on three independent message coordinates and on the strong
security guarantee of minimality, you cannot compress below six transmitted bits — and
six is achievable. The geometric "omit one point" construction becomes the optimal
short minimal code. A fact about a napkin-sized geometry is a sharp optimality
statement about real codes.

## Why the small case is the interesting case

It is tempting to dismiss the seven-point world as too small to matter. The opposite
is true: $q = 2$ (the two-element field) is the *exceptional* regime. The proof we gave
exploited two facts that are special to it — that a line has only three points (so
removing one still leaves two) and that two points determine a unique line (so two
deletions kill exactly one line). Push to $PG(2,3)$, the next projective plane, with
$13$ points and lines of size $4$, and both facts weaken.

The naive guess "omit one point" gives $12$, but it is not optimal there, and a single
omitted point no longer automatically keeps every line spanned, because a line now has
four points and the bookkeeping must be done *per line*, not globally. The known
minimal strong blocking set in $PG(2,3)$ has size $8$, realized by more exotic
configurations such as two disjoint full lines or a dual hyperoval — genuinely
different from the "all but one point" recipe. This contrast is part of what makes the
clean $q = 2$ answer worth isolating: it is the base case that exposes the exact
obstruction (two omitted points sharing a line) which the larger cases must
generalize.

There is even a uniqueness twist. In the seven-point world, *every* minimum strong
blocking set is of the form "all points except one" — the minimizers are completely
classified. For $q \geq 3$ the minimizers are no longer all of this shape; unions of
lines and other configurations sneak in. Non-uniqueness of the extremal configuration
appears to be a phenomenon that switches on exactly when you leave the two-element
field.

## The bigger picture

The story has a natural ladder of generalizations. One can study **additive** strong
blocking sets indexed by a parameter $h$, where the seven-point Fano constraint is
imposed across an $h$-dimensional fiber; the case $h = 1$ is exactly the ordinary
strong blocking set discussed here. A plausible conjecture is that the threshold scales
linearly — that the $h$-fold version costs $6h$, recovering the magic six at $h = 1$ —
because the fibers ought to decouple into $h$ independent copies of the Fano
constraint. And one can climb the projective ladder to $PG(2,3)$, $PG(2,4)$, and beyond,
asking for the threshold and the classification of minimizers at each rung. These are
live questions; the seven-point case is the solved cornerstone they all rest on.

What makes the Fano result satisfying is the way three perspectives lock together. To
the geometer it is a statement about lines and points: keep all but one and every line
stays visible. To the combinatorialist it is an extremal counting problem with a sharp
threshold at six and a complete description of the extremizers. To the coding theorist
it is an optimality bound: minimal codes of dimension three need length six. Three
languages, one fact. The smallest plane in mathematics, it turns out, has something
sharp and useful to say — and the number it says is six.
