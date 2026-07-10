# Graph Coloring with Emotions: Counting the Feelings a Friendship Can Hold

Imagine a group of people, some of whom are friends. You want to hand each
person a single emotion — say joy, anger, fear, sadness, disgust, or surprise —
in such a way that no two friends are ever feeling the *same* thing at the same
time. Friends, after all, tend to react to each other: if I am calm and you are
calm, one of us will eventually break the symmetry. Two friends holding
identical moods feels like an unstable arrangement, so we forbid it.

How many ways are there to do this? The answer turns out to be a beautiful,
exact formula — not an estimate, not a bound, but a clean product that you can
evaluate on the back of an envelope. This article tells the story of that
formula for one especially charming social network: the **friendship graph**.

## The mathematics of who-knows-whom

Mathematicians model "who is friends with whom" using a *graph*: a collection
of dots (called **vertices**), representing people, joined by lines (called
**edges**), representing friendships. Assigning a color — an emotion — to each
person so that no two connected people share a color is called a **proper
coloring**. If we have a palette of $q$ colors to work with, the number of
distinct proper colorings is a quantity that depends only on the shape of the
graph and on $q$. Remarkably, for every fixed graph this count is a
*polynomial* in $q$. It is called the **chromatic polynomial**, written
$P(G, q)$.

The chromatic polynomial is one of the jewels of combinatorics. Evaluated at a
particular number of colors, it tells you exactly how many valid colorings
exist. Its lowest color count at which it becomes positive tells you the
**chromatic number** — the minimum number of colors that make a proper coloring
possible at all. And its algebraic structure secretly encodes deep information
about the connectivity of the graph. Computing it exactly for an arbitrary
graph is famously hard. But for graphs with enough symmetry, it collapses into
something we can write down in closed form.

## The friendship graph: triangles around a hub

The **friendship graph** $F_n$ — also known as the **windmill graph** or the
**Dutch windmill** — is one of those symmetric gems. It is built from a single
central person who is friends with *everyone*, together with $n$ pairs of people.
Within each pair, the two people are friends with each other, and both are
friends with the center. Nobody else is connected.

Geometrically, $F_n$ is exactly what its nickname suggests: $n$ triangles, all
sharing one common corner, spread out like the sails of a windmill. Each
triangle is a little clique of three mutual friends — the center and one outer
pair. The friendship graph earns its name from a classical theorem of
combinatorics: it is precisely the shape a social network must take if every two
people have *exactly one* common friend.

Let us count its proper colorings. Suppose we have $q$ emotions available.

- First, the **center** picks a mood. There are $q$ choices — no constraint yet,
  because we have not colored anyone else.
- Now look at any one triangle. Its two outer members must each differ from the
  center, and they must differ from each other. So the first outer person has
  $q - 1$ admissible emotions (anything but the center's), and once that choice
  is made, the second outer person must avoid both the center and their partner,
  leaving $q - 2$ choices. That is $(q-1)(q-2)$ valid emotion-pairs for the
  triangle.
- Crucially, the triangles do not interfere with one another. Once the center's
  mood is fixed, each triangle is colored *independently* of all the others —
  the only vertex any two triangles share is the center, whose color is already
  locked in.

Multiplying the independent choices together gives the exact count.

## The main result

> **The Friendship Chromatic Formula.** For every number of triangles $n \ge 0$
> and every palette of $q$ emotions,
> $$P(F_n, q) = q \cdot \big((q-1)(q-2)\big)^n.$$

This is not an approximation. It is the precise number of ways to assign $q$
emotions to the $2n + 1$ people of $F_n$ so that no two friends coincide. The
structure of the formula mirrors the structure of the graph perfectly: one
factor of $q$ for the hub, and one identical factor of $(q-1)(q-2)$ for each of
the $n$ independent sails.

What makes the result airtight is that behind it lies a genuine
**bijection** — a perfect one-to-one correspondence. A valid coloring of the
whole windmill is *exactly the same data* as: (a) one color for the center,
plus (b) for each triangle, one ordered pair of outer colors avoiding the
center and each other. Every coloring produces exactly one such packet of data,
and every such packet reconstructs exactly one coloring. Counting the packets is
elementary, and the bijection transports that count back to the colorings with
no loss and no double-counting.

## Six emotions, and the original riddle

The story began with a specific question. Psychologists often speak of six
*basic emotions* — joy, anger, fear, sadness, disgust, and surprise. If those
are our only colors, how many consistent emotional assignments does a friendship
network admit? Plugging $q = 6$ into the formula, we compute
$(6-1)(6-2) = 5 \cdot 4 = 20$, and therefore:

> **The Six-Emotion Count.** With the six basic emotions,
> $$P(F_n, 6) = 6 \cdot 20^n.$$

For a single triangle of three friends ($n = 1$), that is $6 \cdot 20 = 120$
consistent moods-assignments. For ten triangles, it is already
$6 \cdot 20^{10} = 6 \cdot 10{,}240{,}000{,}000{,}000$ — over sixty trillion.
Emotional variety, it turns out, is combinatorially abundant.

## How few emotions can you get away with?

The flip side of *how many* colorings is *how few colors*. The **chromatic
number** of a graph is the smallest palette that admits any proper coloring at
all. Our formula answers this instantly, because $P(F_n, q)$ is positive exactly
when each of its factors is positive:

- With **two** emotions, $(q-1)(q-2) = 1 \cdot 0 = 0$, so $P(F_n, 2) = 0$: no
  valid assignment exists when $n \ge 1$. This is unavoidable — each triangle is
  a clique of three mutual friends, and three mutual friends can never be
  two-colored, since the third always collides with one of the first two.
- With **three** emotions, $(q-1)(q-2) = 2 \cdot 1 = 2 > 0$, so $P(F_n, 3) =
  3 \cdot 2^n > 0$: three emotions always suffice.

Hence, for any friendship network with at least one triangle, the chromatic
number is **exactly three**. Three is both necessary (because of the triangles)
and sufficient (because the triangles are independent once the hub is fixed).

## The emotional window

There is a psychologically natural refinement. If we insist that a healthy
emotional palette should offer at least three options — enough to break any
tie — but no more than the six basic emotions, we get an **emotional chromatic
number**: the least number of emotions, drawn from a menu of at least three,
that colors the network. For the friendship graph this lands squarely on the
floor:

> **The Emotional Number of Friendship.** For every $n$, the emotional
> chromatic number of $F_n$ is $3$, and it always lies inside the six-emotion
> window: $3 \le \text{emotional chromatic number} \le 6$.

Evaluating the count at this emotional floor gives the number of "minimal"
emotional configurations available to the network:
$$P(F_n, 3) = 3 \cdot 2^n.$$
Every friendship network, no matter how many sails its windmill has, can be
consistently colored with just three emotions — and it can never be done with
fewer.

## Why this is more than a curiosity

The friendship graph is a toy, but the technique it illustrates is not. The art
of computing a chromatic polynomial by *decomposing a graph into independent
pieces glued at a shared vertex* extends far beyond windmills. Replace each
triangle by a larger clique of $m$ friends and you get a **generalized
windmill**, whose chromatic polynomial is
$q \cdot \big((q-1)(q-2)\cdots(q-m+1)\big)^n$ — a falling factorial per sail.
Books, fans, and gear graphs succumb to the same idea. In each case, a shared
hub decouples the surrounding structure, and multiplication does the rest.

Beyond combinatorics, chromatic polynomials appear in statistical physics (as
the zero-temperature partition function of the antiferromagnetic Potts model),
in scheduling and register allocation (where "colors" are time slots or CPU
registers and "edges" are conflicts), and in frequency assignment for wireless
networks. The emotions are a playful dressing, but the underlying question —
*how many ways can you assign a resource so that neighbors never clash, and what
is the minimum number of resources you need?* — is one of the most practical in
all of applied mathematics.

So the next time you sit in a circle of friends and notice that no two of you
are feeling quite the same way, you can smile at a small combinatorial truth:
there are exactly $q \cdot \big((q-1)(q-2)\big)^n$ ways for that to happen — and
at least three feelings are always required to keep the peace.
