# When Multiplication Forgets Its Brackets: The Secret Life of Parentheses

## A puzzle hiding in plain sight

Every schoolchild learns that when you multiply three numbers together, the
brackets do not matter: $(2 \times 3) \times 5$ and $2 \times (3 \times 5)$ both
equal $30$. We write this as the associative law,
$$(a \cdot b) \cdot c = a \cdot (b \cdot c),$$
and then we promptly forget about it, dropping the parentheses entirely and
writing $a \cdot b \cdot c$ as if bracketing were never an issue at all.

But *why* are we allowed to forget? In ordinary arithmetic the two bracketings
give literally the same number, so erasing the parentheses is harmless. In more
exotic mathematical worlds, however, associativity is not a matter of "same
answer" but of "canonically comparable answers." The two bracketings are
genuinely *different objects*, and what connects them is not an equality but a
**process** — a reversible transformation that turns one grouping into the other.
The astonishing fact, and the subject of this article, is that even when
associativity fails on the nose, the bookkeeping of these transformations is so
rigidly constrained that we recover the freedom to drop parentheses anyway. This
is the phenomenon of **coherence**, and its deepest expression is a result known
as the **strictification theorem**.

The story we tell here is a self-contained case study: we build a small universe
of bracketings where associativity provably fails at the level of objects, watch
a "causal loop" of reassociations chase itself around and close up perfectly,
and then prove that this loopy, non-strict world is *indistinguishable* — in the
strongest possible structural sense — from a flat, bracket-free world where
associativity holds exactly.

## A world made of bracketings

Fix an alphabet $\alpha$ of symbols — think of them as beads of different
colors. We will build *bracketed products* of beads. The rules are simple:

- there is an empty product, which we call $\mathrm{nil}$;
- each bead $a$ is itself a product, written $\mathrm{leaf}(a)$;
- given two products $s$ and $t$, we may form their bracketed product
  $\mathrm{node}(s, t)$, which you should read as $(s \cdot t)$.

These are exactly the **binary trees** with leaves labelled by beads. For
example, with beads $a, b, c$ the two trees
$$\mathrm{node}(\mathrm{node}(a,b),\,c) = (a \cdot b)\cdot c
\qquad\text{and}\qquad
\mathrm{node}(a,\,\mathrm{node}(b,c)) = a \cdot (b \cdot c)$$
are **different trees**. Not equal-looking-but-secretly-equal; actually
different pieces of data, like two different sentences with the same words in a
different order of assembly. This is the crucial design choice: we refuse to
build associativity into the objects. We call this universe of trees $\mathsf{P}$.

Now, when should we regard two trees as "the same product"? Precisely when they
spell out the same beads in the same left-to-right order, ignoring how they were
bracketed. Reading the leaves of a tree from left to right and stringing them
together produces a **word** — an element of the free monoid $\mathsf{F}(\alpha)$
on the alphabet, where the monoid operation is just concatenation and the empty
word $1$ is the identity. We call this reading-off operation *flattening* and
write it $\mathrm{flat}$:
$$\mathrm{flat}(\mathrm{nil}) = 1,\qquad
\mathrm{flat}(\mathrm{leaf}(a)) = a,\qquad
\mathrm{flat}(\mathrm{node}(s,t)) = \mathrm{flat}(s)\cdot\mathrm{flat}(t).$$
Both trees above flatten to the same word $abc$. They are different bracketings
of one underlying product.

We now declare a **morphism** — an allowed transformation — from tree $s$ to
tree $t$ to be *a proof that $s$ and $t$ flatten to the same word*. There is a
transformation $s \to t$ exactly when $\mathrm{flat}(s) = \mathrm{flat}(t)$, and
otherwise there is none. Composing transformations is transitivity of equality;
the identity transformation is the reflexive equality $\mathrm{flat}(s) =
\mathrm{flat}(s)$. This makes $\mathsf{P}$ a **category**: objects are trees,
arrows are same-word certificates.

## The defining feature: at most one arrow

Here is the linchpin. Between any two trees $s$ and $t$ there is **at most one**
transformation: either they flatten to the same word (and then there is exactly
one arrow, since "they're equal" admits no meaningful variations) or they do not
(and then there is none). A category with this property — at most one morphism
between any two objects — is called **thin**.

Thinness has a magical consequence: *in a thin category, every diagram
commutes*. Whenever two chains of transformations start at the same object and
end at the same object, they must be equal, simply because there is nowhere for
them to differ. This one observation will hand us all the hard coherence
theorems for free.

Every transformation in $\mathsf{P}$ is moreover reversible: if $s$ and $t$
flatten to the same word, then so do $t$ and $s$. So $\mathsf{P}$ is not just
thin but a **thin groupoid** — a world of reversible, essentially-unique
comparisons.

## The tensor that forgets its brackets

We make $\mathsf{P}$ into a **monoidal category**: a category equipped with a
product operation $\otimes$ on objects, a unit object, and comparison
isomorphisms witnessing associativity and unit laws. Our choices are the obvious
ones:

- the tensor product of two trees is $s \otimes t := \mathrm{node}(s,t)$;
- the unit object is $\mathrm{nil}$.

Crucially, $\otimes$ is **not associative on objects**: $(a\otimes b)\otimes c$
and $a\otimes(b\otimes c)$ are the two distinct trees above. What repairs this is
the **associator**, a chosen isomorphism
$$\alpha_{a,b,c}\colon (a\otimes b)\otimes c \;\xrightarrow{\ \sim\ }\; a\otimes(b\otimes c),$$
which exists because both sides flatten to the same word,
$(\mathrm{flat}\,a)(\mathrm{flat}\,b)(\mathrm{flat}\,c)$. Likewise the left and
right unit laws $\mathrm{nil}\otimes x \cong x$ and $x\otimes\mathrm{nil}\cong x$
are witnessed by isomorphisms, again because $1\cdot w = w = w\cdot 1$ in the
free monoid. The associativity of the *objects* has failed, but it has been
restored one level up, by invertible transformations.

## The causal loop that closes itself

Whenever associativity is repaired by a transformation rather than an equality, a
new question appears: are the repairs *consistent* with each other? Consider
rebracketing a product of four factors. Starting from
$((a\otimes b)\otimes c)\otimes d$ you can reach $a\otimes(b\otimes(c\otimes d))$
by two different routes through the associator, and the celebrated **pentagon
condition** demands that these two routes agree. Similarly the **triangle
condition** demands that the associator and the unit laws mesh correctly. Mac
Lane's coherence theorem says that once the pentagon and triangle hold, *all*
conceivable diagrams of reassociations commute — every way of moving brackets
around gives the same answer.

In our world this entire tower of conditions is discharged in a single stroke.
Because $\mathsf{P}$ is thin, the two sides of the pentagon are parallel arrows,
so they are automatically equal; the triangle likewise; and so is every
naturality square one could ever write down. This is the "causal loop" of the
title: send the associator on its journey around the pentagon and it returns
exactly to where it began, not because we cleverly arranged the algebra, but
because there was never room for it to come back anywhere else. We record this as
a general principle.

> **Coherence from thinness.** Any assignment of tensor, unit, associator, and
> unit-law isomorphisms on a thin category automatically satisfies the pentagon
> condition, the triangle condition, and all naturality laws, and therefore
> constitutes a genuine monoidal category.

Applied to $\mathsf{P}$, this yields at once:

> **The bracketing category is monoidal.** With $\otimes = \mathrm{node}$,
> unit $\mathrm{nil}$, and the associator and unitors read off from the free
> monoid, $\mathsf{P}$ is a monoidal category — one that is genuinely
> **non-strict**, since $(a\otimes b)\otimes c \ne a\otimes(b\otimes c)$ as
> objects.

There is even a satisfying uniqueness: because the category is thin, the
associator is the *only* isomorphism between its endpoints. There is one
canonical way to move the brackets, and no other.

## Flattening the world

We now make precise the sense in which the loopy world $\mathsf{P}$ is "the same
as" a flat world. The flat world is the category $\mathsf{D}$ whose objects are
plain words in $\mathsf{F}(\alpha)$ and whose only arrows are identities: two
words are related exactly when they are literally equal. This is a **discrete**
category, and it carries an obviously **strict** monoidal structure — the tensor
of two words is their concatenation, and concatenation of words *is* associative
on the nose, with the empty word as a strict unit. No associator is needed here;
the brackets have been abolished.

Flattening, which we already used to define the morphisms of $\mathsf{P}$,
extends to a **functor** $\mathrm{Flat}\colon \mathsf{P} \to \mathsf{D}$ sending
each tree to its word and each same-word certificate to the corresponding
identity. And it does more than preserve the categorical structure: it respects
the *monoidal* structure too. Flattening a tensor product gives a concatenation,
$\mathrm{flat}(s\otimes t) = \mathrm{flat}(s)\cdot\mathrm{flat}(t)$, and
flattening the unit gives the empty word, both *exactly* — not merely up to
isomorphism. In the technical vocabulary, $\mathrm{Flat}$ is a **strong monoidal
functor**, and its comparison isomorphisms are identities.

Finally we come to the payoff. The functor $\mathrm{Flat}$ has an inverse up to
natural isomorphism: send each word back to its **right-nested bracketing** (the
canonical "lean everything to the right" tree). Reading a word into a tree and
flattening it back returns the same word exactly; flattening a tree and reading
it back returns a *possibly different* tree, but one that is canonically
isomorphic to the original — same word, so there is a unique comparison arrow.
This establishes an **equivalence of categories** $\mathsf{P} \simeq \mathsf{D}$,
and because every functor and transformation in sight respects the tensor
product, it upgrades to a **monoidal equivalence**.

> **Strictification (this family).** The non-strict bracketing category
> $\mathsf{P}$ is monoidally equivalent to the strict, bracket-free category
> $\mathsf{D}$ of words under concatenation. Every structure-respecting fact
> about products in $\mathsf{P}$ transports faithfully to $\mathsf{D}$ and back.

This is a concrete, hands-on instance of **Mac Lane's strictification theorem**:
*every monoidal category is monoidally equivalent to a strict one*. The abstract
theorem promises that the parentheses can always be dispensed with; here we watch
it happen for the universe built entirely out of parentheses.

## The loop, contracted

There is a poetic epilogue. What becomes of the associator — the invertible
$2$-cell that heroically repaired associativity — after we pass to the flat
world? It is *contracted to nothing*. Under flattening, the associator
$\alpha_{a,b,c}$ maps to an identity-type arrow in $\mathsf{D}$, because both of
its endpoints flatten to the very same word $abc$. The transformation that once
carried real content — the act of shifting a bracket — becomes trivial once the
brackets are gone. The causal loop that chased itself around the pentagon has
been pulled taut and collapsed to a point.

## Why any of this matters

This little world of trees is a toy, but the phenomenon it illustrates is
everywhere in modern mathematics and its neighbors. Whenever we compose
processes rather than combine static values — gluing regions of space, tensoring
quantum systems, stacking layers of a computation, wiring together a circuit —
associativity tends to hold only *up to canonical isomorphism*, not on the nose.
The two ways of grouping three quantum systems, or of concatenating three
data-processing stages, are different objects joined by a reversible comparison.

Coherence theory is the guarantee that we may nonetheless reason as if the
brackets did not matter, secure in the knowledge that every path of
reassociations lands in the same place. Strictification is the license to replace
a bracket-riddled model with a clean bracket-free one without losing information.
In practice this is what lets physicists draw string diagrams for quantum
processes, lets programmers treat certain data pipelines as flat sequences, and
lets topologists manipulate glued spaces without drowning in parentheses.

Our case study distills the whole mechanism to its essence. Thinness — the
"at most one arrow" condition — is exactly the feature that makes coherence
*automatic*: with no room for two comparisons to disagree, the pentagon and
triangle enforce themselves, and the passage to the strict world is forced. The
bracketing category shows, in miniature and with complete rigor, how a world
where associativity genuinely fails can be tamed so thoroughly that its failure
becomes invisible. The parentheses were doing real work all along; strictification
is the theorem that lets us finally, and safely, forget them.
