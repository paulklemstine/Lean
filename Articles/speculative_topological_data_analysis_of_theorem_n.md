# How a Computer Should Think When the Data Lies: Belnap's Four-Valued Logic

## A logic for the real world

Classical logic is beautiful, and classical logic is brittle.

It is beautiful because it rests on a single, clean idea: every statement is
either **true** or **false**, and from that binary judgment the whole edifice of
mathematics follows. It is brittle because of one notorious rule, the *principle
of explosion*: from a contradiction, **anything** follows. In Latin it has a
name that sounds almost gleeful — *ex falso quodlibet*, "from a falsehood,
whatever you like." If a classical reasoner ever accepts both a statement and
its negation, it does not merely make a local mistake. It collapses. Every
sentence in its language, true or absurd, becomes provable. "The moon is made of
cheese" and "the moon is not made of cheese" together entail "you owe me a
million dollars."

For a mathematician working with consistent axioms, explosion is harmless — you
simply never feed the machine a contradiction. But step outside pure mathematics
and contradictions are everywhere. A database merges two medical records and one
says the patient is allergic to penicillin while the other says they are not. A
sensor network reports that a valve is simultaneously open and closed. A
search engine scrapes the web and finds one page asserting a fact and another
denying it. A team of experts disagrees. In every one of these cases a classical
reasoner, confronted with the contradiction, would be entitled to conclude
*everything* — which is to say, to conclude *nothing useful at all*.

In 1977 the philosopher and logician Nuel Belnap asked a deceptively simple
question: **How should a computer think when its information might be both
incomplete and inconsistent?** His answer was a tiny, elegant system now known
as Belnap's FOUR, or "the logic of the four values." It is, in a precise sense
we will make exact, the *smallest* logic that can survive a contradiction
without exploding. This article is about why four is the magic number, and about
a hidden symmetry that explains where those four values really come from.

## Counting your evidence both ways

The trick is to stop asking "Is this statement true?" and start asking two
separate questions:

1. **Have I been told it is true?** (Is there evidence *for* it?)
2. **Have I been told it is false?** (Is there evidence *against* it?)

In classical logic these two questions are locked together: a "yes" to one is
automatically a "no" to the other. Belnap's insight was to *unlock* them. Each
question gets its own independent yes/no answer, and the combinations give
exactly four possible epistemic states:

- **N** — *Neither.* No evidence for, no evidence against. The database is
  silent. This is genuine ignorance — the "I don't know" value.
- **T** — *True.* Evidence for, no evidence against. The classical "true."
- **F** — *False.* No evidence for, evidence against. The classical "false."
- **B** — *Both.* Evidence for *and* evidence against. The database has been told
  contradictory things. This is the "told both" value, the overload that
  classical logic cannot represent.

That fourth value, **B**, is the whole point. Classical logic has no room for it:
it cannot record that it has heard a statement is both true and false. Belnap's
logic can. And crucially, it can record that fact *and keep working*.

## Two orders, two questions

Once you have four values, you can sort them in two completely different ways,
and the interplay between these two orderings is the deep structure of the
system.

The first ordering measures **truth**. Picture a vertical axis running from
"definitely false" at the bottom to "definitely true" at the top:

> **F** is the least true, **T** is the most true, and **N** and **B** sit in
> between — they are "half true" in the sense that they each carry exactly as
> much truth-evidence as falsity-evidence (N has none of either, B has both).

The second ordering measures **information**, or knowledge. Picture a *different*
vertical axis, running from "I know nothing" at the bottom to "I have been told
everything" at the top:

> **N** is the least informative (you've heard nothing), **B** is the most
> informative (you've heard everything, including the contradiction), and **T**
> and **F** sit in between — each represents one definite piece of news.

Here is the picture that makes the whole thing click. Lay the four values out as
a diamond:

```
            B  (told both)
           / \
          /   \
   (false) F   T (true)
          \   /
           \ /
            N  (told nothing)
```

Read the diamond **bottom-to-top** and you are climbing the *information* order:
N at the bottom, B at the top, T and F as the two incomparable middle points.
Read it **left-to-right** and you are climbing the *truth* order: F on the left,
T on the right, N and B as the two incomparable middle points. One diamond,
two orders, rotated ninety degrees from each other. A structure with two
compatible lattice orders like this is called a **bilattice**, and FOUR is the
founding example of the entire theory.

Negation — the logical "not" — lives on the truth axis. Flipping a statement's
truth value means swapping evidence-for with evidence-against:

> not-**T** = **F**, not-**F** = **T**, and — here is the surprise —
> not-**N** = **N** and not-**B** = **B**.

If you have heard nothing about a statement, you have heard nothing about its
negation either, so N is its own negation. And if you have heard *both* that a
statement is true and that it is false, then you have *also* heard both about its
negation — so B is its own negation too. Negation flips the diamond left-to-right
(swapping T and F) while leaving the information axis untouched.

## Surviving the contradiction

Now we can say precisely what it means for this logic to "not explode."

We declare a statement **assertible** — Belnap's word is *designated* — when we
have evidence *for* it, regardless of whether we also have evidence against it.
So the designated values are exactly **T** and **B**. (We assert what we've been
told is true, even if we've also been told it's false.)

Watch what happens with a contradiction. Take the value **B**. It is designated
(we have evidence for it). Its negation is also **B**, which is *also* designated.
So in FOUR the premise of explosion — "this statement is designated **and** its
negation is designated" — is genuinely **satisfiable**. There really is a value,
B, that witnesses a live contradiction.

In classical logic this can never happen. There, the designated value is just
"true," and a value is true exactly when its negation is false, i.e. *not*
designated. The classical contradiction premise — "*b* is true and not-*b* is
true" — has **no witness at all**. It is unsatisfiable. This is the secret reason
classical logic gets away with explosion: the rule "from a contradiction, infer
anything" is **vacuously valid**, because the contradiction can never actually
arise inside the algebra of two values. Classical logic does not *resist*
contradictions; it merely *forbids* them, and inherits an explosive rule it never
has to use.

FOUR makes a different bargain. It *permits* the contradiction (via B) and then
*refuses* the explosion. Concretely: from the designated, self-contradictory
value B you cannot derive the value F, because F is not designated. The inference
"contradiction, therefore anything" simply fails. A reasoner using FOUR can be
handed "the valve is open" and "the valve is not open," register both, mark the
valve's status as **B** — and still correctly conclude that an *unrelated* valve
across the plant is closed, without that local contradiction contaminating the
global picture. This property — tolerating contradictions without trivializing —
is called **paraconsistency**, and FOUR is the paradigm example.

The contrast is the heart of the matter. Paraconsistency is exactly **the gap
between a contradiction being *satisfiable* and explosion being *valid*** — and
that gap opens at precisely one place: a value that is designated and whose
negation is also designated. In FOUR that value is B. In the two-valued world no
such value exists, the gap snaps shut, and explosion rushes in.

## Why four, and not three, or five?

You might wonder whether we could economize. Couldn't we get paraconsistency
with just three values — true, false, and "both" — and skip the awkward
"neither"?

The bilattice structure says no, and the reason is symmetry. The information
order needs a bottom (total ignorance) and a top (total information). The top is
B: you've been told everything, both for and against. By the perfect duality of
the two orders, the bottom must be the mirror image of B — a value that has been
told *nothing*, neither for nor against. That is N. You cannot have B, the
"overload," without N, the "void," any more than you can have a magnet with only
one pole. The fourth value is *forced* by the geometry of the diamond. Drop N and
the structure is no longer a bilattice; the two orders lose their bottom and the
elegant duality breaks.

And you cannot do it with fewer than four, because two of the values (T and F)
are needed to recover ordinary classical reasoning when the data happens to be
clean. So four is not an arbitrary choice. It is the **minimum**: FOUR is the
smallest non-trivial bilattice, the smallest arena in which contradiction and
ignorance can both be represented as first-class citizens.

## The hidden product: 2 × 2

There is one final piece of magic, and it ties everything together.

Remember how we built the four values: each is an answer to two independent
yes/no questions, "evidence for?" and "evidence against?" That phrasing is
literally a recipe for a **pair of bits**. Let us write each value as a pair
(*for*, *against*), where each coordinate is 0 (no) or 1 (yes):

- **N** = (0, 0) — no, no
- **F** = (0, 1) — no, yes
- **T** = (1, 0) — yes, no
- **B** = (1, 1) — yes, yes

This is a perfect dictionary. There are exactly $2 \times 2 = 4$ such pairs, which
is *why* there are exactly four values. And every operation of the logic becomes
a simple, coordinate-by-coordinate Boolean operation on the two bits:

- The **information meet and join** (combining or reconciling evidence) act on
  each coordinate by ordinary AND and OR. To pool the *least* common information,
  you AND the for-bits and AND the against-bits; to pool *all* available
  information, you OR them.
- The **truth meet and join** (logical AND and OR of the statements themselves)
  also act coordinatewise — but with a twist: the "against" coordinate runs
  *backwards*. Logical conjunction takes the AND of the for-bits but the OR of
  the against-bits, because a statement "A and B" has evidence against it as soon
  as there is evidence against *either* part.
- **Negation** is the cleanest of all: it just **swaps the two bits**. Evidence
  for becomes evidence against and vice versa. (Now it is obvious why N = (0,0)
  and B = (1,1) are their own negations — swapping the coordinates of a pair of
  equal bits changes nothing.)

In the language of lattice theory, this dictionary says that FOUR is exactly the
**product** of the two-element lattice $\mathbf{2} = \{0, 1\}$ with itself — written
$\mathbf{2} \odot \mathbf{2}$ in Matthew Ginsberg's notation for bilattices. The four
values are the founding bilattice precisely because they are the smallest
non-trivial lattice squared. The two coordinates are the two questions; the two
orders are the two ways of comparing pairs; and the whole rich structure of
Belnap's logic unfolds, with nothing left to chance, from the simple act of
asking about evidence twice.

## What it buys us

This is not merely a philosopher's curiosity. The descendants of Belnap's FOUR
run inside real systems. Relational databases with "null" and "inconsistent"
markers, logic programs that must keep running when their knowledge base
contradicts itself, multi-agent systems fusing disagreeing sensors, and
trust-and-reputation engines on the open web all need a way to represent "I don't
know" and "I've been told both" as honest, stable states rather than as crashes.
Bilattice logics give them exactly that, and FOUR is the seed from which the
whole forest grows.

The lesson is broader than logic. We tend to treat truth as a single dial running
from false to true, and contradiction as a catastrophe to be avoided at all
costs. Belnap's four values show a wiser stance. Truth and information are *two*
dials, not one. A contradiction is not a catastrophe but a *data point* — the
state of having heard both sides — and a system that can name that state calmly
is far more robust than one that detonates the moment the world fails to agree
with itself. Four values, arranged in a diamond, two questions asked
independently: that is all it takes to teach a machine to keep its head when the
data starts to lie.
