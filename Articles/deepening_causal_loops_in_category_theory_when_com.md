# When Composition Loops Back: The Hidden Geometry of Rebracketing

## A parenthesis with consequences

Ask a child to add three numbers — say $2$, $3$, and $4$ — and it will
never occur to them to wonder whether $(2+3)+4$ is the *same* problem as
$2+(3+4)$. Of course it is. Both equal $9$. The parentheses are
scaffolding we throw away the instant the answer appears. This throwing-away
has a name: **associativity**, the law that says the way we group a chain
of operations does not matter.

Associativity is so deeply woven into arithmetic that it feels less like a
theorem and more like a fact of nature. But step outside the world of plain
numbers and something surprising happens. In many of the richest structures
in modern mathematics — the ones that describe symmetry, quantum systems,
knots, and the gluing of geometric pieces — grouping *does* matter, at least
a little. The two ways of bracketing a triple product are no longer literally
equal. They are only **connected by a bridge**: a reversible transformation,
canonical and unique, that carries one grouping to the other. Composition, in
these worlds, does not vanish into a single unambiguous answer. It *loops
back*.

This article is about what happens when we take that loop seriously. What is
the structure of a world where associativity fails — but fails in the gentlest
possible way? The answer turns out to braid together three subjects that look,
at first, to have nothing to do with one another: the logic of coherence, the
algebra of free monoids, and a sequence of numbers that has haunted
combinatorics for two centuries.

## The associator: a bridge instead of an equation

Let us give the bridge a name. Suppose we have three objects $A$, $B$, $C$
that we can multiply — think of them as operations to be performed in sequence,
or as physical processes to be chained. Instead of demanding

$$(A \cdot B) \cdot C = A \cdot (B \cdot C),$$

we demand only that there exist a reversible comparison

$$\alpha_{A,B,C} \colon (A \cdot B) \cdot C \;\xrightarrow{\;\cong\;}\; A \cdot (B \cdot C).$$

This comparison is called the **associator**. It is the formal admission that
the two bracketings are different things, together with a promise that the
difference is harmless: you can always translate one into the other and back.

Once you allow bridges instead of equalities, a worry appears immediately.
With four factors there are *five* ways to insert parentheses, and you can
travel between them by applying the associator in different orders. Do all the
routes agree? Take the two ways of walking from $((A\cdot B)\cdot C)\cdot D$
to $A\cdot(B\cdot(C\cdot D))$. One path reassociates on the left first; the
other reassociates on the right first. If these two journeys landed you in
different places, the whole edifice would collapse into ambiguity. The demand
that they *always* agree is the celebrated **pentagon equation**, drawn as a
five-sided diagram whose every path commutes. There is a smaller cousin, the
**triangle equation**, governing how the associator interacts with the
multiplicative unit. A structure carrying an associator that obeys the pentagon
and triangle laws is called a **monoidal category**, and these two coherence
laws are the price of admission.

## First surprise: in a thin world, coherence is free

Here is the first of our three results, and it is a liberation. Sometimes the
bridge between two objects — if it exists at all — is *unique*. There is at
most one reversible comparison between any given pair. We call such a world
**thin**: between any two objects there is at most one arrow, period.

In a thin world, the pentagon and the triangle **cost nothing**. They are
automatic. The reason is almost embarrassingly simple: the two sides of the
pentagon equation are both arrows between the same pair of objects, and in a
thin world any two such arrows are *forced to be equal*. There is no room for
disagreement, because there is no room for two distinct arrows to begin with.

We can state this cleanly.

> **Theorem (Coherence is free in a thin category).** Let $\mathcal{C}$ be a
> category in which any two parallel arrows are equal. Then *any* choice of
> tensor product, unit, associator, and unitors on $\mathcal{C}$ automatically
> satisfies the pentagon and triangle identities and every naturality
> condition. In other words, any tensor data on a thin category assembles,
> with no further checking, into a genuine monoidal category.

This is why the loops in a well-behaved rebracketing world never tangle: they
*cannot*. Travel the long way around Mac Lane's pentagon and come back along
the short way, and you return exactly to where you started — the composite of
the whole excursion is the identity. When composition loops back in a thin
world, it always loops back home.

## Second surprise: a concrete world where grouping truly matters

Abstract liberation is satisfying, but one wants to *see* a world where
associativity genuinely fails while coherence quietly holds. Here is one, built
from nothing but parentheses themselves.

Fix an alphabet of symbols. A **parenthesization** is a fully-bracketed word:
a binary tree whose leaves are symbols. For instance $(a\cdot b)\cdot c$ and
$a\cdot(b\cdot c)$ are two different parenthesizations of the same three
letters. We make these bracketings the **objects** of a category. For the
arrows, we declare that there is a (unique) arrow from one bracketing to
another exactly when they spell the *same underlying word* once the
parentheses are erased. Composition is just the transitivity of "spelling the
same word."

This little category — call it the **parenthesization category** — has three
striking features.

First, it is **thin** by construction: a morphism is nothing but a proof that
two bracketings flatten to the same word, and any two such proofs are
interchangeable. So by our first theorem, whatever tensor structure we put on
it is coherent for free.

Second, it carries an *obvious* tensor product: to multiply two bracketings,
just join them under a new top bracket, $s \otimes t = (s\, t)$. And here is
the payoff — this product is **genuinely not associative on objects**. The
bracketing $((a\cdot b)\cdot c)$ and the bracketing $(a\cdot(b\cdot c))$ are
*different objects*: one is a tree whose left branch is itself a product, the
other is a tree whose right branch is. No sleight of hand disguises an equality
as an isomorphism here; a simple size count proves the two trees can never
coincide. Yet the two are joined by the associator, and — because the world is
thin — that associator is the **unique** isomorphism between them. This is a
non-strict monoidal category you can hold in your hand.

> **Theorem (Genuine non-strictness).** In the parenthesization category, for
> every triple of bracketings the objects $(A\otimes B)\otimes C$ and
> $A\otimes(B\otimes C)$ are distinct, yet canonically and *uniquely*
> isomorphic. Two bracketings are isomorphic precisely when they spell the same
> word.

Third, if you deliberately *forget* the distinctions the associator makes — if
you agree to identify any two bracketings that are isomorphic — the whole
tower of nested parentheses collapses onto something utterly familiar: the
**free monoid**, that is, ordinary words under concatenation, with the empty
word as unit. Every bracketing has a canonical "normal form," the fully
right-nested spelling of its word, and joining two normal forms corresponds
exactly to concatenating their words. This is the concrete face of Mac Lane's
famous **coherence theorem**: *every* diagram of associators commutes, so you
lose nothing by pretending the product was strictly associative all along. The
messy world of brackets and the clean world of words are two views of the same
thing.

## Third surprise: counting the loops gives the Catalan numbers

We have a world where each isomorphism class is a single word, and inside each
class sit all the different ways of bracketing that word. It is irresistible to
*count* them. How many bracketings does a word of $n+1$ letters admit — that
is, how big is one connected component of this rebracketing world?

The answer is one of the most beloved sequences in all of mathematics: the
**Catalan numbers**,

$$C_0 = 1,\quad C_1 = 1,\quad C_2 = 2,\quad C_3 = 5,\quad C_4 = 14,\quad C_5 = 42,\ \dots$$

> **Theorem (The census of loops).** The number of ways to bracket a product
> of $n+1$ factors is the Catalan number $C_n$. Equivalently, each connected
> component of the rebracketing world — the set of all bracketings sharing one
> underlying word of length $n+1$ — has exactly $C_n$ members, and they are all
> mutually and uniquely isomorphic.

There is nothing coincidental here. A bracketing of $n+1$ factors is, stripped
of its labels, exactly a binary tree with $n$ internal nodes — and Catalan
numbers count binary trees. The correspondence is a clean bijection: turn each
bracket into an internal node, each factor into a leaf. Counting bracketings
*is* counting trees.

And the Catalan numbers arrive complete with their signature recurrence, the
**Segner convolution**. Split a bracketing at its outermost bracket: everything
to the left is a smaller bracketing, everything to the right is another. Summing
over all the places the outermost split could fall gives

$$C_{n+1} \;=\; \sum_{i=0}^{n} C_i \, C_{n-i}.$$

This is exactly the arithmetic of the loops: the number of ways to bracket a
big product, expressed in terms of the ways to bracket its two outermost
halves. The categorical structure — associators looping bracketings into one
another — and the combinatorics — Catalan numbers counting bracketings —
turn out to be the same phenomenon wearing two costumes.

## Why any of this matters

The instinct to treat $(A\cdot B)\cdot C$ and $A\cdot(B\cdot C)$ as *the same*
is a convenience, and like many conveniences it hides structure. Physicists
building topological models of matter, computer scientists reasoning about the
order of data-combining operations, topologists gluing manifolds, and
algebraists studying quantum symmetries all live in worlds where the grouping
of operations carries real information — information stored precisely in the
associator and policed precisely by the pentagon.

What the three results above tell us, together, is a satisfying story with a
beginning, middle, and end. **When can a controlled failure of associativity be
trusted?** When the world is thin, coherence comes for free. **What does such a
world look like concretely?** Exactly like the category of bracketed words,
non-associative on the nose yet perfectly coherent. **And how much does the
associator actually do?** It glues together $C_n$ different bracketings into
each single word — a Catalan number's worth of bookkeeping, no more and no
less.

The child was right that $(2+3)+4$ and $2+(3+4)$ give the same answer. What the
child could not have guessed is that the act of *forgetting* the parentheses is
itself a piece of mathematics — with its own theorems, its own geometry, and a
census counted by one of the most famous sequences ever discovered. Composition,
it turns out, does loop back. And when it does, it loops back through the
Catalan numbers.
