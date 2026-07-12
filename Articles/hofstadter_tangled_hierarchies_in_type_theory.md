# Strange Loops, Tamed: When Can a Hierarchy Bite Its Own Tail?

Imagine climbing a staircase. Step one is below step two, which is below step
three, and so on, forever upward. Now imagine a staircase drawn by M. C. Escher:
you climb and climb, turn four corners, and arrive back exactly where you began —
higher than yourself. You are above and below the same step at once. Douglas
Hofstadter called such structures **strange loops**, or **tangled hierarchies**:
level structures in which something manages to sit both above and below itself.

Tangled hierarchies are everywhere once you start looking. A government agency
that is supposed to regulate the very legislature that funds it. A sentence that
talks about its own truth ("this sentence is false"). A drawing of a hand drawing
the hand that is drawing it. And, most dramatically for mathematics and computer
science, a *universe of types large enough to contain itself*. This article is
about the precise mathematical line that separates hierarchies that *can* tangle
from hierarchies that *cannot* — and about why the ultimate tangle, a universe
that mirrors its own totality, is outright impossible.

## The staircase and the Escher print

Let us make "tangled" exact. Suppose we have a collection of levels and a
relation $\prec$ meaning "sits below." We say the structure is **tangled** if
there exist two levels $x$ and $y$ with
$$x \prec y \quad\text{and}\quad y \prec x.$$
That is the smallest possible strange loop: a two-step cycle, each element beneath
the other. A degenerate case is a **self-loop**, a single level $x$ with
$x \prec x$ — something strictly below itself. Every self-loop is a tangle: just
take $x = y$.

The opposite of a tangle is an **asymmetric** hierarchy, one where no edge ever
has a reverse: whenever $x \prec y$, it is never the case that $y \prec x$. This
is the honest staircase. And here is the first clean fact: an asymmetric hierarchy
can never be tangled, and a tangled hierarchy can never be asymmetric. The two
notions are exact opposites. To keep a strange loop, you must surrender the very
"strictly below" character that makes a hierarchy a hierarchy.

## Why an ordinary staircase can't tangle

Ordinary mathematical hierarchies — the natural numbers under $<$, the levels of
a well-designed type system, the ranks of a nested collection of sets — share a
structural feature called **well-foundedness**: there is no infinite descending
chain, no bottomless downward spiral. Every nonempty collection of levels has a
minimal element you cannot descend below.

Well-foundedness is exactly the guarantee that rules out tangles. If levels $x$
and $y$ formed a two-cycle, each would be strictly below the other, so from either
one you could descend to the other and back again, forever — an infinite descent,
which well-foundedness forbids. So:

> **Well-founded hierarchies are never tangled.**

The prototype is the tower of levels
$$\text{level}_0 \prec \text{level}_1 \prec \text{level}_2 \prec \cdots,$$
modeled faithfully by the natural numbers under their usual order $<$. Because
$(\mathbb{N}, <)$ is well-founded, no level in this tower is ever both above and
below another. The infinite ladder of type universes — the tower in which each
universe of types lives inside a strictly larger one — has exactly this shape, and
so it too is guaranteed tangle-free.

## The real reason: levels *are* a ruler

There is an even more transparent way to see why staircases can't tangle, and it
turns out to be the heart of the whole story. Suppose we can assign to each level
a whole number — a **rank** — in such a way that every "below" edge strictly
increases the rank:
$$x \prec y \ \Longrightarrow\ \operatorname{rank}(x) < \operatorname{rank}(y).$$
Such an assignment is called a **grading**. It is the mathematical incarnation of
what we informally mean by "levels": a consistent numbering of the floors of the
building.

A graded hierarchy simply cannot tangle. For if $x \prec y$ and $y \prec x$ both
held, then $\operatorname{rank}(x) < \operatorname{rank}(y)$ and
$\operatorname{rank}(y) < \operatorname{rank}(x)$ — a number strictly less than
itself, which is absurd. Hence:

> **A grading forbids tangles.**

Read the other way around, this is a striking impossibility theorem. Turn it
into its contrapositive:

> **The consistency dichotomy.** A genuinely tangled hierarchy admits *no*
> grading. There is no way to number its levels so that "below" always means
> "lower number."

This is the crisp form of a folklore conjecture about strange loops: *you cannot
have all three of consistency, a genuine tangle, and a system of levels.* If your
structure really loops, then any attempt to assign it consistent levels is doomed
before it starts. To keep the loop, you must abandon the levels; to keep the
levels, you must abandon the loop. There is no third option.

## Where do the loops come from, then?

If well-founded, graded hierarchies are so safe, why do strange loops feel so
pervasive? The answer is that the loops usually live not in the *order* of the
levels but in the *references between* them.

Consider the natural rule of a layered language: a thing at level $n$ is allowed
to *mention* the level just above it and the level just below it — its immediate
neighbours. This gives an **adjacency** relation on levels: $n$ and $m$ are
adjacent when $m = n+1$ or $n = m+1$. Adjacency is **symmetric** — if $n$ can
mention $n+1$, then $n+1$ can mention $n$.

And symmetry is the enemy of gradedness. The moment a relation is symmetric and
has even a single edge, it is tangled: that one edge $r(x,y)$ automatically comes
with its mirror $r(y,x)$, closing a two-cycle. Levels $0$ and $1$ refer to each
other, so:

> **The reference graph is tangled** — even though the order on levels
> underneath it is a perfectly well-behaved, well-founded ladder.

This is the resolution of the apparent paradox. The tower of levels is untangled;
the graph of *who may talk about whom* is tangled. The loop was never in the
staircase — it was in the cross-talk between the steps. And by the consistency
dichotomy, this reference graph admits no grading at all: you cannot consistently
rank people by "who cites whom" in a network where citation goes both ways.

## The ultimate tangle

Everything so far has been about finite, local loops. But there is a maximal
strange loop, the one that has haunted logic since Bertrand Russell: a universe
so complete that it contains a name for *every possible property of itself*.

Picture a universe $U$ of objects, together with a dictionary that reads each
object $c$ as a *predicate* over $U$ — a criterion that each object of $U$ either
satisfies or not. Equivalently, each code $c$ names a subset $\operatorname{decode}(c)$
of $U$: the objects satisfying it. Now demand that this dictionary be **complete**:
*every* subset of $U$, every conceivable property, is named by some object inside
$U$. Call such a thing a **reflective universe** — a universe that perfectly
mirrors its own totality of properties. This is the ultimate tangle, the exact
shape of the notorious assumption "$\text{Type} : \text{Type}$," where the
universe of all types is itself one of the types it contains.

It cannot exist. The proof is Cantor's diagonal argument, the same jewel that
shows there are more real numbers than whole numbers, wielded here as a weapon.
Suppose the dictionary were complete. Form the **Russell property**: the set of
all objects that do *not* satisfy their own criterion,
$$R = \{\, x \in U : x \notin \operatorname{decode}(x) \,\}.$$
By completeness, $R$ must be named by some object $a$, so
$\operatorname{decode}(a) = R$. Now ask the fatal question: does $a$ satisfy its
own criterion? By definition of $R$,
$$a \in R \iff a \notin \operatorname{decode}(a) = R.$$
So $a$ belongs to $R$ exactly when it does not — a flat contradiction. There is no
escape, and no such $a$, and hence no complete dictionary. We conclude:

> **The ultimate tangle is inconsistent.** No reflective universe exists. No type
> can contain a name for every predicate over itself. A universe cannot mirror its
> own power set.

This is precisely why serious foundations of mathematics do *not* allow
"$\text{Type} : \text{Type}$." A single all-encompassing universe that is a member
of itself would let us build the Russell property and derive a contradiction from
which every statement, true or false, becomes provable. To stay consistent, the
foundations use the infinite well-founded ladder of universes instead — each
universe strictly below the next, tangle-free by design. The staircase, not the
Escher print.

## The moral of the loop

The findings assemble into a single, satisfying picture:

- **Ordinary hierarchies don't tangle** — well-foundedness, and more sharply the
  existence of a rank function, guarantees it.
- **A structure is graded exactly when it is loop-free.** Levels and loops are
  mutually exclusive. This is the whole content of "you can't have consistency,
  a tangle, and a hierarchy at once."
- **The loops we notice are loops of reference, not of order.** Symmetric
  cross-talk between neighbouring levels tangles the reference graph while leaving
  the level order pristine.
- **The maximal loop is impossible.** A universe reflecting its own totality
  collapses under the diagonal argument — Cantor's and Russell's and Girard's
  insight in one blow.

Hofstadter's strange loops are seductive precisely because they seem to promise
something for nothing: self-reference, self-containment, a system that captures
itself whole. Mathematics answers with a firm and elegant accounting. You may have
your levels or you may have your loop, but the ledger must balance — and the grand
tangle, the universe that swallows itself, is a debt that can never be paid.
