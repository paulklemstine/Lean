# When Composition Loops Back: The Hidden Simplicity Inside Parentheses

## A puzzle hiding in plain sight

Ask a child to add three numbers — say $2$, $3$, and $4$ — and they will not
hesitate. Whether they compute $(2 + 3) + 4$ or $2 + (3 + 4)$, the answer is
$9$. This is the *associative law*, and it is so deeply woven into arithmetic
that we usually drop the parentheses altogether and just write $2 + 3 + 4$.

But look more closely. The two expressions $(2 + 3) + 4$ and $2 + (3 + 4)$ are
*not the same expression*. They describe two different procedures: in the first,
you add $2$ and $3$, then add $4$; in the second, you add $3$ and $4$, then add
$2$. They happen to land on the same number, but the *shape* of the computation
is genuinely different. Associativity is not a triviality. It is a **coincidence
that always happens** — and mathematicians have learned that coincidences which
always happen are worth taking seriously.

This article is about what you find when you take the shapes of computation
seriously and refuse to collapse them too soon. We will build a small universe in
which parenthesizations are first-class citizens — where $(a \cdot b) \cdot c$ and
$a \cdot (b \cdot c)$ are *different objects* connected by an invisible bridge —
and then we will prove that this seemingly elaborate universe secretly has the
simplest possible skeleton: it is nothing more than a list of ingredients, in
order. Composition loops back on itself, and when the dust settles, all that
survives is the word you started with.

## Trees, not just answers

Let us give the shapes of computation a name and a home. Fix an alphabet of
symbols — think of them as ingredients, letters, or numbers to be combined. A
**parenthesization** is a way of fully bracketing a sequence of those symbols so
that every combination is binary: you only ever combine two things at a time.

The natural picture is a **binary tree**. A single ingredient $a$ is a *leaf*.
Combining two already-built expressions $s$ and $t$ produces a new expression we
write as $s \cdot t$, drawn as a *node* with $s$ on the left and $t$ on the
right. (We also allow an empty expression, the trivial "combine nothing"
placeholder.) So the two ways of bracketing three letters $a, b, c$ become two
different trees:

$$
(a \cdot b) \cdot c \qquad\text{versus}\qquad a \cdot (b \cdot c).
$$

Each tree carries two kinds of information: the **word** — the ingredients read
left to right, here always $a, b, c$ — and the **bracketing** — the internal
plan of which pair gets combined first. Flattening a tree, that is, reading off
its leaves in order and forgetting the branching, throws away the bracketing and
keeps only the word.

Here is the first honest observation, and it deserves to be stated as a theorem
because it is easy to wave away and secretly false-feeling.

> **Associativity genuinely fails.** The trees $(a \cdot b) \cdot c$ and
> $a \cdot (b \cdot c)$ are distinct objects. They are not equal.

They are not equal *as trees*, and no amount of squinting makes them equal. What
*is* true is subtler and more interesting: they are *connected*.

## A bridge between every two bracketings

Even though the two trees differ, they flatten to the same word $abc$. That
shared word is a bridge. We declare, as the founding rule of our universe, that
**whenever two trees flatten to the same word, there is a passage between them** —
a morphism, in the language of category theory, recording the fact "these two
bracketings compute over the same ingredients in the same order." Composition of
passages is just chaining these facts together, and it works because equality of
words is transitive: if $s$ and $t$ share a word and $t$ and $u$ share a word,
then $s$ and $u$ do too.

This turns the collection of all parenthesizations into a **category**: objects
are trees, arrows are these bridges. And the category has two remarkable
features that together are the whole story.

First, it is **thin**: between any two trees there is *at most one* bridge. Two
bracketings either share a word (and then there is exactly one canonical passage
between them) or they do not (and then there is none). There is never any choice
to make, never two different ways to reassociate. This is the categorical
fingerprint of what topologists and algebraists call **coherence**: all the ways
of getting from one bracketing to another agree.

Second, every bridge is **reversible**. If you can pass from $s$ to $t$ because
they share a word, you can pass back. In the language of categories, every arrow
is an *isomorphism*, and a category with this property is a **groupoid**. Our
universe of parenthesizations is a groupoid: a world of pure, invertible,
canonical translations.

Putting the two features together gives a clean slogan:

> **Coherence is connectedness.** Two bracketings are isomorphic — linked by a
> reversible bridge — *if and only if* they flatten to the same word.

The bracketing is entirely negotiable; the word is the invariant. Every possible
plan for combining $a, b, c$ is uniquely and reversibly interchangeable with
every other. The classical *coherence theorem* of Mac Lane — the statement that
"all reasonable diagrams of reassociations commute" — appears here in its most
transparent form: there is only ever one arrow to draw, so of course every
diagram commutes.

## The census of shapes: enter Catalan

Before we collapse this universe, let us marvel at how big it is. How many
bracketings are there of a fixed number of ingredients?

- One ingredient: just $a$. One tree.
- Two ingredients: just $a \cdot b$. One tree.
- Three ingredients: $(a \cdot b) \cdot c$ and $a \cdot (b \cdot c)$. Two trees.
- Four ingredients: five trees.
- Five ingredients: fourteen.

These numbers — $1, 1, 2, 5, 14, 42, 132, \dots$ — are the celebrated **Catalan
numbers**, among the most ubiquitous sequences in mathematics. They count
triangulations of polygons, paths that stay above a diagonal, ways to match
parentheses, and — as we see here — ways to bracket a product. Writing $C_n$ for
the $n$-th Catalan number, we have proved:

> **The census of bracketings.** The number of distinct bracketings of $n + 1$
> ingredients is exactly $C_n$.

And these counts are not independent numbers; they interlock through a beautiful
self-referential recurrence discovered by Segner in the eighteenth century. A
bracketing of many factors is, at its outermost node, a split into a left group
and a right group, each itself bracketed. Summing over every possible place to
split gives the **convolution recurrence**

$$
C_{n+1} \;=\; \sum_{i=0}^{n} C_i \, C_{n-i},
$$

which we have also established for our census. The multitude of shapes is vast,
structured, and classical.

## The collapse: strictification

Now for the punchline. We have a rich groupoid — a whole ecosystem of
bracketings, growing at the Catalan rate, laced together by canonical reversible
bridges. It *looks* complicated. What is its true content?

Consider the opposite extreme of simplicity: the **discrete category on words**.
Its objects are words (ordered lists of ingredients), and it has *no* nontrivial
arrows at all — the only passage from a word to itself is standing still, and
there are no passages between different words. This is as inert as a category can
be. It is, quite literally, just the set of words, with the free-monoid
operation of concatenation lurking in the background: put two lists end to end.

The central theorem of this work says these two worlds — the elaborate groupoid
of bracketings and the inert set of words — are **the same category in disguise**.

> **Strictification Theorem.** The groupoid of parenthesizations is equivalent,
> as a category, to the discrete category of words. The equivalence sends each
> tree to its flattened word, and sends each word back to its canonical
> right-nested bracketing $a \cdot (b \cdot (c \cdot \cdots))$.

An *equivalence of categories* is the correct notion of "the same for all
structural purposes." It means: the flattening map that forgets bracketing loses
**nothing essential**. Every word is realized by some tree (essential
surjectivity). Between any two trees there is exactly one bridge, matching the
zero-or-one arrows of the discrete world (fullness and faithfulness). Going from
tree to word and back returns you to where you started, up to the canonical
bridge (the round trip is naturally isomorphic to the identity).

This is *strictification* in action. The word "strict" refers to associativity
holding *on the nose*, with no bridges needed. Concatenation of lists is
perfectly, boringly associative: $(x \mathbin{+\!\!+} y) \mathbin{+\!\!+} z$ and
$x \mathbin{+\!\!+} (y \mathbin{+\!\!+} z)$ are literally the same list. Our
theorem says that the *non-strict* world of bracketings, where associativity
famously fails and must be repaired by bridges, is equivalent to this *strict*
world where the problem never arises. All the invertible bridges recording "how
associativity loops back" are collapsed, and what remains is exactly the
underlying word.

And the collapse respects structure. The combining operation on trees — join two
trees under a new node — is carried by the equivalence precisely to
concatenation of words:

$$
\operatorname{flatten}(s \cdot t) \;=\; \operatorname{flatten}(s)\;\mathbin{+\!\!+}\;\operatorname{flatten}(t).
$$

So the *skeleton* — the essential, redundancy-free core — of the loop-tolerant
tensor product is the **free monoid**: lists under concatenation, with the empty
list as unit. This is the precise, provable meaning of the slogan that opened our
investigation. When composition loops back on itself through a maze of canonical
reassociations, its skeleton is the simplest algebraic structure that could
possibly carry an associative product on a given alphabet.

## Why this matters beyond the parentheses

It is tempting to dismiss all this as bookkeeping about brackets. It is not.
The tension between "equal on the nose" and "equal up to canonical isomorphism"
is one of the central themes of modern mathematics and theoretical computer
science.

In **programming language theory**, the difference between two data structures
that are *literally* equal and two that are *provably interconvertible* is the
difference between a type-checker accepting your code instantly and it demanding a
proof. Compilers that reason about reassociating operations — turning a
left-leaning chain of additions into a balanced tree for parallel evaluation —
are silently invoking exactly the coherence we made explicit: the answer does not
depend on the shape, so the shape may be chosen for efficiency.

In **higher category theory and homotopy theory**, strictification theorems are
load-bearing. They tell us when a structure that is only associative "up to
coherent isomorphism" can be replaced by an equivalent one that is associative on
the nose — dramatically simplifying computations while changing nothing that
matters. Mac Lane's coherence theorem for monoidal categories is the ancestor of
our result; here it appears in a stripped-down, completely transparent form,
where thinness makes every coherence condition automatic.

In **physics and the study of processes**, categories are the language of
composing systems — wiring outputs to inputs, running things in parallel. The
idea that a process built one way is *canonically the same* as the process built
another way, even when the two are not literally identical, is exactly what lets
us reason about complex systems by rearranging them into convenient forms.

The deepest lesson is a philosophical one about the phrase in our title. A
**causal loop** — composition looping back on itself — sounds paradoxical, the
stuff of time-travel puzzles. Here it becomes concrete and benign: a structure
whose operation is not quite associative, but whose failures of associativity all
cancel out through a coherent web of canonical translations. Far from being
paradoxical, such loops have a serene resolution. Peel away the loops, and you
find, sitting quietly underneath, the free monoid — a list of things, in order,
combined by juxtaposition. The most elaborate coherent chaos of reassociation
hides the most elementary order.

## The shape of the argument

The whole story rests on one modest technical decision made at the very
beginning: define a passage between two trees to be *nothing more than a proof
that they flatten to the same word*. From this single choice, everything cascades.

Because a passage is just such a proof, and any two proofs of the same equality
are interchangeable, the category is automatically **thin** — at most one passage
between any two trees. Because equality is symmetric, every passage is
automatically **reversible**, so the category is a **groupoid**. Because
flattening a joined tree concatenates the words, the operation is automatically
carried to the free-monoid product. And because every word is the flattening of
its own right-nested bracketing, the flattening functor is automatically
**essentially surjective**. Each of the three ingredients of an equivalence —
full, faithful, essentially surjective — falls out for free.

That is the quiet beauty of the result: a rich-looking phenomenon, the Catalan
explosion of bracketings woven together by coherent reassociation, reduced to its
essence by a single well-chosen definition. The loops were never a problem. They
were a disguise. And underneath the disguise is the free monoid — the humble list
of ingredients we started combining in the first place.
