# Two Ways to Multiply, One Hidden Law

## Why a famous trick of topology is really a statement about ordinary arithmetic

Imagine you discover a strange new world with two different kinds of
multiplication. There is a "vertical" product, which we write `a · b`,
and a "horizontal" product, which we write `a ∗ b`. Both behave like
honest multiplications in one respect: each has a neutral element — call
it `1` — that does nothing when you multiply by it. So `1 · x = x` and
`x · 1 = x`, and likewise `1 ∗ x = x` and `x ∗ 1 = x`.

That much is unremarkable. The twist is a single rule that ties the two
products together, a rule called the **interchange law**:

> `(a ∗ b) · (c ∗ d) = (a · c) ∗ (b · d).`

In words: if you build a little two-by-two grid of elements and combine
them, it does not matter whether you first combine the rows (using `∗`)
and then the columns (using `·`), or first the columns and then the rows.
The two products *commute past each other*.

This looks like a mild compatibility condition — the kind of fine print
you would expect to constrain things only a little. The astonishing fact,
discovered by Beno Eckmann and Peter Hilton in 1962, is that it constrains
things almost completely. From this one law and nothing else, four
conclusions tumble out, each more surprising than the last:

1. **The two products are actually equal.** There was never any
   difference between vertical and horizontal multiplication: `a · b = a ∗ b`
   for all `a` and `b`.
2. **The product is commutative.** `a · b = b · a`.
3. **The product is associative.** `(a · b) · c = a · (b · c)`.
4. And so, packaged together, the whole structure is nothing more exotic
   than a **commutative monoid** — the gentlest, most familiar algebraic
   object there is, the abstract shape shared by addition of whole numbers,
   multiplication of positive reals, and the union of finite sets.

This is the **Eckmann–Hilton argument**, and it is one of the most
delightful "collapses" in all of mathematics: you set up what looks like
genuinely two-dimensional, higher-order structure, and it instantly
flattens into something one-dimensional and ordinary.

The work described here takes that classical collapse one decisive step
further. It is not enough to know that the structure *collapses*. The
sharper question is: **what exactly does it collapse to?** The answer,
made completely precise and machine-checked, is that the equational theory
of these doubly-multiplicative worlds is *identical* — not merely similar,
not merely related, but the very same theory — to that of commutative
monoids. Nothing weaker survives; nothing stronger is forced. And, as a
bonus, the supposedly "two-dimensional" bookkeeping turns out to be rigidly
determined by its one-dimensional shadow.

---

## A magic trick you can do with your hands

Before the algebra, here is the picture that makes Eckmann–Hilton feel
inevitable.

Suppose you want to prove that the two products coincide. Start from the
interchange law and feed it a special diet of units. Put `b = 1` and
`c = 1`:

```
(a ∗ 1) · (1 ∗ d) = (a · 1) ∗ (1 · d).
```

Now apply the unit laws to every parenthesis. On the left, `a ∗ 1 = a`
and `1 ∗ d = d`, so the left side is just `a · d`. On the right,
`a · 1 = a` and `1 · d = d`, so the right side is just `a ∗ d`. The
interchange law has handed us, for free:

```
a · d = a ∗ d.
```

The two products are the same. That is the entire proof of conclusion (1),
and it is nothing but a clever choice of where to plug in the unit.

Commutativity is the same trick with a different seating chart. Put
`a = 1` and `d = 1` in the interchange law:

```
(1 ∗ b) · (c ∗ 1) = (1 · c) ∗ (b · 1).
```

Unit laws collapse this to `b · c = c ∗ b`. But we already know `∗` and `·`
are the same product, so `c ∗ b = c · b`, and therefore `b · c = c · b`.
Commutativity, again from a single substitution.

Associativity takes a touch more juggling — it comes from the *medial
law*, the statement `(a · b) · (c · d) = (a · c) · (b · d)` that the
interchange law becomes once you know the two products coincide — but the
flavor is identical: choose your units wisely, and the structure tells on
itself.

The moral is almost philosophical. There is no "second dimension" of
information hiding in the horizontal product. The moment you demand
that horizontal and vertical multiplication be compatible *and* share a
unit, you have demanded that they be the same commutative thing.

---

## Where two multiplications actually come from

You might wonder whether anyone ever genuinely runs into two products with
a shared unit and an interchange law, or whether this is just a logician's
fantasy. The honest answer is that they arise constantly — in the part of
mathematics that studies *shape*.

Consider a loop: a path that starts and ends at the same point. Loops can
be **composed** — walk around the first loop, then the second — and this
composition is the multiplication of the **fundamental group**, the
algebraic fingerprint of a space's holes. In one dimension, this product
is generally *not* commutative: walking loop A then loop B can differ from
B then A, which is exactly why a figure-eight is more complicated than a
circle.

Now climb one dimension higher. Instead of loops, consider **loops of
loops** — continuous families of loops, the objects measured by the
*second* homotopy group, `π₂`. Here something new happens. There are two
natural ways to combine two such 2-dimensional gadgets: you can stack them
**vertically** or place them **side by side horizontally**. Both have the
same do-nothing element (the constant family), and a moment's thought about
sliding little squares around in the plane shows they satisfy precisely the
interchange law.

The Eckmann–Hilton argument now fires, and out comes a celebrated theorem
of topology:

> **The second homotopy group `π₂` is always abelian.**

The non-commutativity that makes one-dimensional loops interesting simply
*cannot exist* one dimension up. This is the deep reason that higher
homotopy is, in a sense, tamer than the fundamental group — and it is a
direct consequence of being able to multiply in two compatible ways. In
the precise formal statement proved here, this appears as the clean
identity

```
a · b = b ∗ a,
```

a single line that captures "the second homotopy group is abelian" in pure
algebra, with no topology required.

---

## From "they collapse" to "they ARE commutative monoids"

The classical Eckmann–Hilton argument tells you the structure collapses.
The contribution at the center of this package is to nail down *exactly*
what it collapses to, in both directions, and to certify the answer with
total rigor.

Here is the two-way bridge, stated plainly.

**Direction one — every doubly-multiplicative world is a commutative
monoid.** Given any system with two unital products and an interchange law,
you can forget the horizontal product entirely (it equals the vertical
one anyway), keep the vertical product and the shared unit, and what you
hold in your hand is a genuine commutative monoid. In the formalization
this is the construction `toCommMonoid`: it takes the data and assembles
the commutative-monoid laws — the unit laws come straight from the
hypotheses, associativity and commutativity from the Eckmann–Hilton
argument above.

**Direction two — every commutative monoid is a doubly-multiplicative
world.** Conversely, take any ordinary commutative monoid — the natural
numbers under addition, say. Define *both* the vertical and the horizontal
product to be its single multiplication, and take the unit to be its
identity. Do the unit laws hold? Of course. Does the interchange law hold?
It becomes

```
(a + b) + (c + d) = (a + c) + (b + d),
```

which is true for any commutative monoid — it is just rearranging a sum,
the **medial law**. So every commutative monoid *is* Eckmann–Hilton data,
viewed twice. In the formalization this is `ofCommMonoid`.

Put the two directions together and you get the headline result,
`eh_iff_commMonoid`:

> A binary operation with a unit is the vertical product of some
> Eckmann–Hilton structure **if and only if** it is the multiplication of
> a commutative monoid.

The equational theories are not cousins. They are the same theory wearing
two costumes. This is the exact sense in which **there is no genuinely
higher algebra in dimension two**: the apparatus of two compatible
products produces nothing the humble commutative monoid did not already
contain.

---

## The structure has no secrets: rigidity

There is one more twist, and it is the most striking of all.

When you write down Eckmann–Hilton data, you appear to be specifying three
separate things: a vertical product, a horizontal product, and a unit.
That feels like three independent choices. It is not. The result called
`structure_rigidity` proves that the vertical product **alone** determines
everything else:

> If two Eckmann–Hilton structures have the same vertical product, then
> they automatically have the same unit *and* the same horizontal product.

Why? The unit is pinned down because in any monoid the identity element is
unique — there can be only one element that does nothing — so the moment
you fix the product, the unit has no freedom left. And the horizontal
product is pinned down because it always equals the vertical product. The
"two-dimensional" data — the second product, the chosen unit — carries
*zero* extra information beyond the one-dimensional product you started
with. It is bookkeeping, not content.

This rigidity is what elevates the iff-statement from a curiosity to a
structural law. The correspondence between these doubly-multiplicative
worlds and commutative monoids is not just a loose equivalence; it is as
tight as it could possibly be, because each side has no hidden degrees of
freedom for the other to match.

---

## A one-line theorem with a big consequence

The package closes with a corollary that turns the whole story into a
practical tool, `monoid_comm_of_second_interchange`:

> Take any monoid — not assumed commutative. Suppose its multiplication
> admits a *second* unital operation, sharing the same identity, that
> interchanges with it. Then the monoid is forced to be commutative.

Read it as a slogan: **a second compatible multiplication is no extra
structure — it is a commutativity certificate.** If you can find even one
other unital product that plays nicely with yours, your product had no
choice but to be abelian all along. This is the algebraic incarnation of
the topological fact that a "connected double loop space is
homotopy-commutative," compressed into a statement an undergraduate can
check.

---

## Why this is beautiful

Mathematics prizes results where a tiny hypothesis forces an enormous
conclusion, and the Eckmann–Hilton argument is a jewel of that kind. But
the deeper pleasure here is the *exactness*. It is one thing to watch a
structure collapse; it is another to prove, with no wiggle room, that it
collapses onto a specific, named, well-understood object — and that the
collapse loses nothing and adds nothing.

The picture that emerges is a small parable about dimension. We tend to
assume that "higher" means "richer" — more dimensions, more room, more
structure. Eckmann and Hilton showed that the opposite can be true: demand
the right compatibility between two layers, and the second layer evaporates,
leaving behind the most ordinary arithmetic. The natural numbers, the
abelian groups, the commutative monoids you met in school are not a
starting point you eventually leave behind. In dimension two, they are the
destination.

Two ways to multiply, one hidden law — and at the end of it, just
commutative arithmetic, all the way up.
