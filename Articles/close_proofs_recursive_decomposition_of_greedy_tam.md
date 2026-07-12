# Counting Trees Without Counting: The Hidden Arithmetic of Dyck Paths

## A game of matching staircases

Imagine you are standing at the bottom-left corner of a square grid, and you want
to walk to the top-right corner using only two kinds of steps: a step *up* and a
step *right*. There is one rule you must never break — at no point may your path
dip below the diagonal line connecting where you started to where you are heading.
Every "up" you take must eventually be balanced by a "right," but you can never get
ahead of yourself in the wrong direction.

Paths like these are called **Dyck paths**, and they are one of the most beloved
objects in all of combinatorics. If your grid has side length $n$ — that is, if you
take $n$ ups and $n$ rights — the number of legal staircases you can draw is a
famous quantity called the $n$-th **Catalan number**:

$$C_n = \frac{1}{n+1}\binom{2n}{n}.$$

The first few Catalan numbers are $1, 1, 2, 5, 14, 42, 132, 429, \dots$. They
appear so often, and in so many disguises, that mathematicians sometimes joke that
if you are counting something and get a Catalan number, you have probably
rediscovered a Dyck path in disguise. And indeed, Catalan numbers count not just
staircase paths but an astonishing zoo of other structures: ways to fully
parenthesize a product, triangulations of a polygon, and — the stars of this
article — **trees**.

This article is about a single, elegant thread that ties all of these together, and
about how that thread extends upward into a richer family of numbers, the
**Fuss–Catalan numbers**, which govern the deep combinatorics of certain modern
objects called *greedy Tamari intervals*.

## Two kinds of trees

There are two families of trees at the heart of our story.

The first are **binary trees**. A binary tree is built from *internal nodes*, each
of which has exactly two slots — a left child and a right child — where you can
either attach another internal node or leave an empty stub. A binary tree with $n$
internal nodes is a compact, rigid structure: every branching is exactly two-way.

The second are **plane trees**, also called *ordered rooted trees*. A plane tree is
much more relaxed: it has a root, and the root has an *ordered list* of children —
zero, one, two, or a hundred — and each child is itself a plane tree. The word
"plane" (or "planar") is crucial: the *order* of the children matters. A root with
children $A, B$ is different from a root with children $B, A$. You can think of a
plane tree as a family tree drawn on paper, where left-to-right birth order is part
of the data.

These two families look completely different. Binary trees are stiff and two-way;
plane trees are floppy and multi-way. And yet:

> **A plane tree with $n+1$ nodes, a binary tree with $n$ internal nodes, and a
> Dyck path of semilength $n$ are all counted by exactly the same number** — the
> Catalan number $C_n$.

How can such different objects march in perfect lockstep? The answer is one of the
prettiest bijections in combinatorics.

## The Knuth transform: turning a forest into a binary tree

The bridge between plane trees and binary trees is a classical trick, sometimes
called the **left-child / right-sibling** correspondence, popularized by Donald
Knuth. Here is the idea, and it is genuinely simple.

Take a **forest** — an ordered list of plane trees standing side by side. We will
encode it as a single binary tree using two instructions:

- The **left child** of a node holds *its own children* (recursively encoded).
- The **right child** of a node holds *its next sibling* (recursively encoded).

Concretely: given a forest, look at its first tree. That first tree has a root with
some ordered list of children — call that list the tree's *sub-forest*. Send the
sub-forest to the **left**, and send the *rest of the original forest* (everything
after the first tree) to the **right**. Recurse. An empty forest becomes the empty
binary tree.

To recover the forest from a binary tree you simply reverse the reading: the left
branch tells you a node's children, the right branch tells you its siblings.

The remarkable fact — and the crux of why the correspondence works — is that these
two operations are *exact inverses of one another*. Encoding a forest and then
decoding it returns the original forest unchanged, and encoding the decoding of any
binary tree returns that same binary tree. In the language of this article:

> **The Knuth Correspondence.** The map sending an ordered forest of plane trees to
> a binary tree by the left-child / right-sibling rule is a perfect one-to-one
> correspondence (a bijection) between ordered plane forests and binary trees.
> Moreover it preserves size: a forest whose trees have $n$ nodes in total maps to
> a binary tree with exactly $n$ internal nodes.

A single plane tree with $n+1$ nodes is nothing more than *its root plus a forest of
its children*, and that child-forest has $n$ nodes. So plane trees with $n+1$ nodes
correspond exactly to forests with $n$ nodes, which correspond exactly to binary
trees with $n$ internal nodes, which — by the classical staircase encoding of a
binary tree — correspond exactly to Dyck paths of semilength $n$. The whole chain
snaps together, and the common count is $C_n$.

## The arithmetic that makes it tick

Behind the pictures lies a small tower of arithmetic facts, each one leaning on the
one before it. It is worth seeing this tower, because it is the skeleton that gives
the combinatorics its strength.

**Integrality — the miracle of the fraction.** The formula $C_n =
\frac{1}{n+1}\binom{2n}{n}$ contains a division, and there is no *a priori* reason a
fraction should come out to a whole number. But it always does. The precise
statement is that $n+1$ divides the central binomial coefficient $\binom{2n}{n}$,
so that

$$(n+1)\,C_n = \binom{2n}{n}.$$

This exactness is not a curiosity; it is the engine. From it, everything else
follows.

**Positivity.** Because $(n+1)\,C_n = \binom{2n}{n}$ and the right-hand side is a
strictly positive count of lattice paths, $C_n$ can never be zero. In fact $C_n \ge
1$ for every $n$ — there is always at least one object of each size (the empty one,
and the single-root one).

**The recursive decomposition.** This is the heart of the matter. Take a nonempty
Dyck path. Follow it until the *very first moment it returns to the diagonal*. That
first return splits the path cleanly into two smaller Dyck paths: the arch you just
completed (with its own interior) and everything that comes after it. If the
interior has semilength $i$, the remainder has semilength $n-i$. Summing over all
possible split points gives the celebrated **Catalan convolution**:

$$C_{n+1} = \sum_{i=0}^{n} C_i \, C_{n-i}.$$

The exact same recursion is what you get by decomposing a binary tree at its root
into a left subtree and a right subtree. One picture, two readings, one formula.
This self-similarity — a big object built out of two smaller objects of the same
kind — is the true meaning of "recursive decomposition via Dyck path structure."

**Monotonicity.** From the convolution, one term alone — the one that pairs an
object of size $n$ with the empty object of size $0$ — already contributes $C_n$ to
the sum for $C_{n+1}$. Since every other term is nonnegative, the counts never
shrink: $C_n \le C_{n+1}$. The families grow.

## Climbing higher: the Fuss–Catalan numbers

Everything so far lives in a two-way world: binary branching, up-and-right steps.
But nature — and algebra — often demands more branches. What if every internal node
has not two slots but $m+1$ of them? What if a Dyck-like path is allowed to take one
"down" step for every $m$ "up" steps before it must return to the ground?

These richer objects are counted by the **Fuss–Catalan numbers**:

$$\mathrm{FC}(m,n) = \frac{1}{mn+1}\binom{(m+1)n}{n}.$$

Setting $m=1$ recovers the ordinary Catalan numbers exactly — the base layer of the
whole edifice. But for general $m$, $\mathrm{FC}(m,n)$ counts $(m+1)$-ary plane
trees with $n$ internal nodes, and equivalently the higher "$m$-Dyck paths" of
length $(m+1)n$. Two facts hold for *every* $m$, no matter the arity:

- $\mathrm{FC}(m,0) = 1$: there is exactly one empty object.
- $\mathrm{FC}(m,1) = 1$: there is exactly one object of size one — the lone root.

These are the seeds. The base layer $m=1$ is where the full recursive machinery —
integrality, positivity, convolution, monotonicity, and the triple bijection
between plane trees, binary trees, and Dyck paths — has been fully established and
made airtight.

## Why anyone should care: greedy Tamari intervals

The reason these numbers are more than a pretty pattern is that they are the
*enumerative backbone* of a much deeper structure. On the set of Dyck paths there
is a natural notion of "one path lies above another," and this partial order,
suitably arranged, forms the celebrated **Tamari lattice** — a structure that shows
up in the study of associativity, in the geometry of polytopes called
*associahedra*, and in modern algebra.

An *interval* in this order is simply a pair of paths, one sitting below the other,
together with everything in between. A remarkable and difficult conjecture, due to
Bousquet-Mélou and Chapoton and generalized to every arity $m$, predicts that the
number of certain distinguished ("greedy") $m$-Tamari intervals living inside a
planar $(m+1)$-constellation is exactly the number of certain maximal planar trees.
The bridge between the two sides of that conjecture is built — you guessed it — *via
Dyck paths*, and the number doing the counting on both sides is a Fuss–Catalan
number.

The work described here lays the foundational base layer of that program. It
establishes, with full rigor, the $m=1$ heart of the correspondence: the exact
arithmetic of the Catalan numbers, their recursive self-similarity, and the explicit
chain of bijections

$$\{\text{plane trees with } n{+}1 \text{ nodes}\}
\;\longleftrightarrow\;
\{\text{binary trees with } n \text{ internal nodes}\}
\;\longleftrightarrow\;
\{\text{Dyck paths of semilength } n\},$$

each side counted by $C_n$. This is the ground on which the general-$m$ story — and
ultimately the full greedy Tamari conjecture — must be built.

## The beauty of counting by not counting

There is a philosophical punchline hiding in all of this. To learn that two very
different collections of objects have the same size, you have two options. You can
count each one separately — a laborious, error-prone business — and check that the
two numbers agree. Or you can build a **bijection**: a rule that pairs up each
object on one side with exactly one object on the other, so that *no counting is
required at all*. If every plane tree has a unique binary-tree partner and vice
versa, then the two collections must be the same size, whatever that size happens to
be.

Bijective proofs are the poetry of combinatorics precisely because they explain
*why* two counts agree, not merely *that* they do. The Knuth transform does not just
tell us that plane trees and binary trees are equinumerous; it hands us the exact
dictionary translating one into the other, forest into tree, sibling into right
branch, child into left. And when that dictionary is combined with the arithmetic
tower — integrality, positivity, convolution, monotonicity — we get something rare
and satisfying: a story in which the pictures and the algebra tell precisely the
same tale, and neither can be pried apart from the other.

From a staircase that must not cross a diagonal, to a forest folded into a binary
tree, to the towering Fuss–Catalan hierarchy that governs the Tamari lattice — it is
all, in the end, the same number, wearing different clothes.
