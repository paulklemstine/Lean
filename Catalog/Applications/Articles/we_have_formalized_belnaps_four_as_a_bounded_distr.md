# The Logic of Contradiction: How Four Truth Values Tame the Impossible

## A computer that has read too much

Imagine you are building a system that gathers facts from many sources at once — a
database fed by thousands of sensors, a search engine crawling the open web, a
medical record assembled from a dozen hospitals. Sooner or later, two of those
sources will disagree. One sensor reports that the valve is open; another insists it
is closed. One article says a chemical is safe; another says it is lethal.

In ordinary logic, this is a catastrophe. Classical logic — the logic of
mathematics, of Aristotle, of almost every programming language — has a rule with a
terrifying name: *ex contradictione quodlibet*, "from a contradiction, anything
follows." If your system ever simultaneously believes a statement and its negation,
classical logic permits it to deduce *everything*: that the valve is open, that the
moon is made of cheese, that 1 = 2. A single contradiction does not just corrupt one
fact; it detonates the entire body of knowledge. Logicians call this **explosion**.

A database that explodes the moment two sensors disagree is useless. We need a logic
that can hold a contradiction in one hand without dropping everything else it knows.
That logic exists. It was designed in 1977 by the philosopher Nuel Belnap in a paper
with the wonderful title *"How a Computer Should Think,"* and it uses not two truth
values but **four**. This article is about those four values, the elegant algebraic
shape they form, and a single clean theorem that explains *exactly why* the fourth
value is the secret to surviving contradiction.

## Two questions, not one

Classical logic asks one question of every statement: *is it true?* The answer is
yes or no, `T` or `F`, 1 or 0. But a computer collecting evidence is really tracking
two independent things:

- **Is there evidence *for* the statement?**
- **Is there evidence *against* the statement?**

In the tidy classical world these always move in lockstep: evidence for means no
evidence against, and vice versa. But real evidence is messier. Sometimes you have
neither — nobody has said anything about the statement at all. Sometimes you have
both — one source affirms it and another denies it. Once you allow the two questions
to be answered independently, you do not get two possibilities. You get **four**:

| Value | Evidence for? | Evidence against? | Meaning |
|-------|---------------|-------------------|---------|
| **N** | no  | no  | *Neither* — a knowledge **gap**, nothing is known |
| **F** | no  | yes | plain old **False** |
| **T** | yes | no  | plain old **True** |
| **B** | yes | yes | *Both* — a knowledge **glut**, the database is told it is true *and* false |

The two strange newcomers are `N` ("none" or "neither") and `B` ("both"). `N` is
the silence of an empty database. `B` is the cacophony of two sources shouting
opposite answers. These are not exotic edge cases; they are the everyday texture of
information gathered from the wild. Belnap's insight was that a thinking machine
should *record* these states rather than panic at them.

## A diamond of truth

Four values are more interesting than two not just because there are more of them,
but because of how they fit together. We can order the four values by how *true*
they are. `F` is the least true. `T` is the most true. And `N` and `B` sit in the
middle, incomparable to each other — one true-ish for lack of denial, the other
true-ish for excess of affirmation. Drawing the order, with "more true" going up, we
get a diamond:

```
            T   (true)
           / \
          /   \
       N         B
   (neither)   (both)
          \   /
           \ /
            F   (false)
```

This shape is not arbitrary. It is one of the most fundamental small structures in
all of mathematics: a **lattice**. In a lattice, any two elements have a greatest
common lower bound (their "meet", written `⊓`, the logical *and*) and a least common
upper bound (their "join", written `⊔`, the logical *or*). The diamond above is the
lattice you get by taking the two-element set `{no, yes}` and pairing it with itself
— the famous structure mathematicians write as `2 × 2`. Each value is just a pair of
yes/no answers to our two questions, and *and*/*or* operate on the two coordinates
independently.

Because it comes from such a clean product, the diamond inherits the best property a
lattice can have: it is **distributive**. The familiar schoolbook law
`a and (b or c) = (a and b) or (a and c)` holds perfectly, exactly as it does for
ordinary true/false logic. Nothing about handling contradictions forces us to give
up the algebra we know and love. We have simply added two new vertices to the
square.

There is one more operation: **negation**. To negate a statement, swap the two
questions — what was evidence *for* becomes evidence *against*, and vice versa. This
swap leaves `T` and `F` doing what you expect (`not true = false`,
`not false = true`), but watch what it does to the newcomers. The gap `N` has no
evidence either way; swapping nothing for nothing leaves it unchanged: **not N = N**.
The glut `B` has evidence both ways; swapping them also leaves it unchanged:
**not B = B**. The two middle values are *fixed points* of negation. This negation is
a genuine **De Morgan involution**: applying it twice returns you home
(`not not a = a`), it reverses the truth order, and it satisfies De Morgan's laws
`not(a and b) = (not a) or (not b)` and `not(a or b) = (not a) and (not b)`. The
diamond, with this negation, is the smallest De Morgan algebra that is more than a
single chain.

## Which statements may we assert?

A logic is not just an algebra; it needs a notion of what counts as an *acceptable*
conclusion. In Belnap's system, we are willing to assert a statement when there is
evidence for it — that is, when its value is `T` *or* `B`. We call these two values
**designated**. (Notice `B` is designated even though it is also contradicted: if a
source vouches for a claim, you may act on it, while remembering the dissent.)

Now we can name precisely the two pathological-looking values:

- A **glut** is a value that is designated *and whose negation is also designated*.
  It is "assertibly true and assertibly false at once." Among the four values, there
  is exactly one glut: `B`. (`T` fails because its negation `F` is not designated;
  `N` and `F` fail because they are not designated to begin with.)

- A **gap** is a value that is not designated *and whose negation is also not
  designated* — "neither assertibly true nor assertibly false." There is exactly one
  gap: `N`.

These two facts — *the unique glut is `B`* and *the unique gap is `N`* — are not
hand-waving. They are theorems, checked exhaustively over all four values. In the
formal development they read, almost word for word, "a value is a glut if and only if
it equals `B`," and "a value is a gap if and only if it equals `N`."

## The heart of the matter

We can now state the central result with complete precision. Recall the doomsday
rule, explosion: *a designated value with a designated negation entails every
conclusion.* A logic is **paraconsistent** — explosion-proof — when this rule
**fails**: when you can have a statement that is assertibly true and assertibly false
without thereby being forced to assert *everything*.

Here is the theorem that ties the whole story together:

> **Paraconsistency holds if and only if a glut exists.**

In words: a logic of this kind survives contradiction *exactly when* it contains a
value that is simultaneously designated and has designated negation. The capacity to
absorb contradiction is not a vague philosophical attitude; it is the presence or
absence of a single algebraic object. And Belnap's FOUR has that object — the value
`B`. Therefore FOUR is paraconsistent. Feed it a contradiction, and it records `B`
on that one statement while everything else carries on undisturbed. No explosion.

The contrast with classical logic is illuminated by the same theorem read in
reverse. Why is ordinary true/false logic explosive? Not because it bravely chooses
to deduce everything from a contradiction, but because in the two-valued world the
premise of explosion can *never be satisfied*: no Boolean value is true at the same
time as its negation. Classical logic validates explosion **vacuously** — it promises
that anything follows from a contradiction precisely because, in its impoverished
world, a contradiction can never actually arise. Belnap's logic enlarges the world
just enough — by exactly one value, `B` — to make contradiction *expressible*, and in
the same stroke makes explosion *fail*. The glut is both the disease and the cure: it
lets contradictions be stated, and it stops them from spreading.

## Why exactly four?

One might ask whether we could get away with three values — true, false, and one
middle value doing double duty. We cannot, and the diamond shows why. Paraconsistency
demands a designated value whose negation is also designated: that is `B`. But the
algebra of negation, being an order-reversing involution, then *forces* a partner for
`B` at the opposite pole — a value with no evidence either way, fixed by negation
from below. That is `N`. You cannot have the glut without its dual the gap; the
symmetry of negation insists on both. Together with the indispensable `T` and `F`,
that makes **four** — and a count of the values confirms it: FOUR has exactly four
elements, no more and no fewer. It is the smallest non-trivial structure of its kind,
the minimal arena in which contradiction can be both spoken and survived.

## From logic to dreams: where contradictions hide

The story does not end with a tidy four-element algebra. The same idea — *local
consistency that fails to add up globally* — reappears in a surprising geometric
guise.

In ordinary topology, the building blocks are "open sets," and they obey two closure
rules: the intersection of finitely many opens is open, and the union of *any*
collection of opens, however vast, is also open. That second rule is strong. It is
what makes topology "global": local openness automatically scales up to arbitrary
unions.

But reasoning under contradiction is not like that. A dreamer can hold each scene
coherent while the dream as a whole makes no consistent sense; a database can be
locally tidy on every finite query yet globally incoherent. To model this, we relax
the rules. A **dream space** is a family of "open" sets closed under *finite*
intersection but **not** required to be closed under arbitrary union. Finite, local
coherence is guaranteed; global coherence is not.

There is a concrete and beautiful example on the natural numbers `0, 1, 2, 3, …`.
Declare a set "dream-open" if it is **finite, or it is the whole of `ℕ`**. Finite
intersections stay finite (or land on the whole space), so the dream-space rule
holds. But now take the set of **even numbers**. It is an infinite union of
single-point sets — each singleton `{0}, {2}, {4}, …` is finite and hence dream-open —
yet the evens themselves are neither finite nor everything. *The union of dream-open
sets has escaped the family.* This dream space is provably **not a topology**: the
evens are the explicit witness that arbitrary unions break it.

And here the two halves of the story fuse. Take any assignment of Belnap values to
the natural numbers — a *valuation* `v`, perhaps recording for each fact `n` whether
our sources are silent (`N`), agreed-false (`F`), agreed-true (`T`), or in conflict
(`B`). The set of facts on which the sources *conflict* — the **glut locus**
`{n : v(n) = B}` — is exactly the set of contradictions our system is carrying. We
proved earlier that being a glut is the same as being `B`, so this locus is precisely
the trouble spots.

Now choose a valuation whose glut locus is the even numbers: contradictions on every
even fact, harmony on every odd one. This valuation is perfectly paraconsistent — each
contradiction sits quietly as a `B`, no explosion anywhere. Yet its glut locus, the
evens, is **not dream-open**. The metalogical defect — "where does this system carry
contradictions?" — turns out to be *literally the same set* as the topological defect
— "which union escapes the dream space?" The place where logic refuses to explode and
the place where geometry refuses to close are one and the same.

## Why it matters

This is a small theory, but it earns its keep. Paraconsistent logics are not a
curiosity: they underpin systems that must reason with inconsistent inputs without
collapsing — fault-tolerant databases, belief-revision engines, multi-source sensor
fusion, and AI systems that ingest contradictory text. Belnap's FOUR is the canonical
starting point, the "hydrogen atom" of inconsistency-tolerant reasoning, and reducing
its central virtue to a single crisp condition — *there is a glut* — turns a
philosophical stance into an engineering checklist. Want a logic that won't explode?
Make sure it has a value that is designated together with its negation. That is the
whole secret.

And the bridge to dream spaces hints at something larger: that the way reasoning
tolerates contradiction and the way geometry tolerates incomplete closure are two
views of the same phenomenon. Local coherence is cheap; global coherence is
expensive; and the gap between them — whether you call it a glut, a dream, or an
escaped union — is exactly where the interesting mathematics lives.
