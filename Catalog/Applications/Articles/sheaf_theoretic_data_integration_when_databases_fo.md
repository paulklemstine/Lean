# When Databases Form a Sheaf: The Hidden Geometry of Missing Data

## A spreadsheet with holes in it

Picture a spreadsheet. Rows are patients, customers, sensors, or stars; columns
are the things you measured about them — age, income, temperature, brightness.
Now picture the spreadsheet as it really arrives in the wild: peppered with
blanks. A sensor dropped offline for an hour. A survey respondent skipped a
question. A telescope was clouded out. Real data is not a filled rectangle; it
is a rectangle with holes punched through it.

Filling those holes is one of the oldest and most consequential chores in data
science. It has a name — *imputation* — and a folklore of recipes. Replace each
blank with the column's average. Borrow the value from the most similar row.
Build a little model that predicts each missing entry from the others. These
methods work, sometimes well. But they share a quiet assumption that is almost
never examined: that the blanks are independent little problems, each to be
patched on its own.

This article is about what happens when you stop believing that. It turns out
that a database with missing entries is not a bag of independent holes at all.
It is a single geometric object — a *partial section of a sheaf* — and the
question "can these holes be filled consistently?" is, exactly and provably, the
central question of a branch of mathematics invented to study how local
information assembles into global information. The mathematics is called sheaf
theory, and it was born in the 1940s to understand surfaces, solutions of
differential equations, and the topology of space. That it should govern your
quarterly sales spreadsheet is, at first, astonishing. By the end of this
article it should feel inevitable.

## Local agreement, global truth

Here is the idea in one sentence. **Pieces of data that agree wherever they
overlap can be glued into a single larger piece — and they can be glued in
exactly one best way.**

That sentence is the *sheaf condition*, and it is worth slowing down on.

Imagine two analysts each hold a partial copy of the same database. Analyst A
knows the ages and incomes for the morning shift; Analyst B knows the incomes
and ZIP codes for a partly overlapping set of people. Wherever both of them
recorded an income for the *same* person, do their numbers match? If yes — if
they agree on the overlap — then there is no obstacle to merging their
notebooks into one fuller notebook. If even one income disagrees, no consistent
merge exists; the two notebooks describe incompatible worlds.

That is the whole story in miniature, and it generalizes. Replace "two analysts"
with "any number of partial views," and replace "agree on income" with "agree on
every cell where two views both have a value." The resulting principle is what
mathematicians call *gluing*, and the collection of all consistently-gluable
partial views is what they call a *sheaf*.

To make this precise we need three honest definitions.

A **partial database** on a grid of `nRows × nCols` cells is simply a function
that assigns to each cell either a value or the special symbol "missing." Write
`db p = some v` when cell `p` holds the value `v`, and `db p = none` when it is
blank. That is all a partial database is: a grid where each cell is either filled
or empty.

Two partial databases are a **consistent pair** when they never contradict each
other: for every cell `p`, if the first database says `v₁` and the second says
`v₂`, then `v₁ = v₂`. Blanks are free — a blank conflicts with nothing. Only two
*filled* cells holding *different* values count as a clash.

A whole family of partial databases satisfies the **sheaf condition** when every
pair within it is consistent. This is the precise, checkable meaning of "all the
local views agree on their overlaps."

## The information order: more data is "bigger"

To talk about gluing as *building something*, we need a notion of one database
containing more information than another. Say that a database `big` **extends** a
database `small` when every value recorded by `small` is recorded identically by
`big`:

> `Extends big small` means: for every cell `p` and value `v`, if `small p =
> some v` then `big p = some v`.

`big` may fill in extra cells that `small` left blank, but it may never erase or
alter what `small` already knew. This "has at least as much data" relation is the
*information order*, and it behaves exactly as an order should:

- **Reflexive:** every database extends itself.
- **Transitive:** if `a` extends `b` and `b` extends `c`, then `a` extends `c`.
- **Antisymmetric:** if `a` extends `b` *and* `b` extends `a`, the two databases
  are literally equal, cell for cell.

These three facts — proven precisely as `extends_refl`, `extends_trans`, and
`extends_antisymm` — say that partial databases form a *partial order*. This is
the stage on which everything else plays out. Imputation, in this language, is the
act of moving *upward* in the information order: from a blank-riddled database to
a fuller one that extends it.

A small but pivotal observation lives here. Suppose some big database `g` extends
two smaller ones, `a` and `b`. Then `a` and `b` *must* be a consistent pair —
because wherever both have a value, both values are forced to equal `g`'s value,
so they equal each other. This is the result `consistentPair_of_common_extension`,
and it is the "easy half" of the whole theory: **if a common merge exists, the
pieces automatically agree on overlaps.** No cleverness, no choices, no
assumptions are needed. Consistency is a *necessary* condition for gluing, and it
comes for free.

## Gluing as the least upper bound

The reverse direction — building a merge *from* agreement — is where the content
lives. Given two consistent databases, how do we merge them? The natural recipe:
for each cell, take the first database's value if it has one, otherwise the
second's. Call this the **gluing map**. It has three properties that, together,
crown it as the canonical merge:

1. The gluing always extends the *first* database (`extends_gluing_left`) — even
   without consistency, because it always prefers the first's values.
2. For a consistent pair, the gluing also extends the *second* database
   (`extends_gluing_right`) — the agreement guarantees that preferring the first
   never contradicts the second.
3. **The gluing is the *least* upper bound** (`gluing_is_lub`): any database `g`
   that extends both pieces already extends their gluing. The gluing adds nothing
   superfluous; it is the *minimal* common extension, the tightest possible merge.

In the language of order theory, the gluing is the **join** — the least upper
bound — of a consistent pair. And the existence of joins is precisely what makes
an order into a *lattice*. So the slogan "databases form a sheaf" sharpens into
something an algebraist recognizes instantly: *consistent databases have joins.*

## From two to many: the colimit

Two databases are a warm-up. Real data integration merges dozens or hundreds of
partial views. So we need an *arbitrary-arity* merge, one that takes any indexed
family of partial databases and produces a single result.

The construction, called `glueFamily`, does the obvious thing made rigorous: at
each cell, if *some* member of the family has a value there, use it; if *every*
member leaves the cell blank, leave it blank. (When the family is consistent, it
does not matter *which* member you borrow from — they all agree.) A clean
companion fact, `glueFamily_eq_none_iff`, states the boundary of the construction
exactly: a cell of the merge is blank *if and only if* every member leaves it
blank. Nothing is invented; nothing is lost.

This merged object has the two properties that, in category theory, define a
**colimit** — the universal way to assemble a diagram of objects into one:

- **It extends every member** (`glueFamily_extends`). Under the sheaf condition,
  the merge contains all the information of all the pieces. This is the "gluing
  axiom," and it is the direction that genuinely *uses* consistency (and a small
  dose of the axiom of choice, to pick which member to borrow each value from).

- **It is the least such extension** (`glueFamily_is_lub`). Any database that
  extends every member already extends the merge. Remarkably, this universal
  property needs *no* consistency hypothesis and *no* choice — it is true for free,
  by pure bookkeeping. The merge is the tightest possible common extension, the
  initial point of the "cocone" of all common extensions.

Because the information order is antisymmetric, this least common extension is
*unique*: there is exactly one best merge. The colimit is not an arbitrary
witness that "some merge exists"; it is *the* canonical answer, pinned down by its
universal property.

## The theorem: databases really do form a sheaf

We can now state the headline result cleanly. It is a two-way street, an
*if-and-only-if* that captures the entire phenomenon:

> **Main Theorem (databases form a sheaf).** A family of partial databases admits
> a single common extension — a consistent merge into one larger database — *if
> and only if* it satisfies the sheaf condition (every pair agrees on its
> overlap).

Read it in both directions, because each direction tells a different story.

The **forward direction** (sheaf condition ⟹ merge exists) is the gluing axiom,
the hard-won content. It says: *agreement is enough*. You never have to check any
higher-order condition, never have to worry about three-way or four-way subtleties.
If the pieces agree pairwise, they assemble. The colimit `glueFamily` is the
explicit witness, and `glueFamily_extends` is the proof.

The **reverse direction** (merge exists ⟹ sheaf condition) is *separatedness* —
the free half from `consistentPair_of_common_extension`. It says: *agreement is
necessary*. If any consistent merge exists at all, the pieces had to have agreed
in the first place. There is no way to fill the holes consistently while papering
over a genuine contradiction.

Put together, the two halves say that pairwise agreement is not just sufficient or
just necessary for consistent imputation — it is the *exact* condition. There is
no hidden obstruction, no gap between "looks consistent" and "is consistent." The
sheaf condition is the whole truth about gluability.

This is sharper than merely asserting that a merge exists somewhere. The earlier,
weaker statement in the catalog was one-directional. The upgrade here is the
biconditional *plus* the universal property: not only does a merge exist exactly
when the pieces agree, but that merge is the unique least common extension, a
genuine colimit rather than an arbitrary patch.

## Progressive imputation is taking a colimit

There is a beautiful payoff for anyone who has ever filled in missing data in
stages — first the easy cells, then the harder ones, refining as you go. This
"progressive imputation" can be formalized as a **sheaf filtration**: a sequence
of databases, each extending the previous one (information only grows), all
mutually consistent.

A striking structural fact, `sheaf_filtration_auto_consistent`, says that the
consistency is *automatic*: if each stage merely extends the previous one, then
all stages are pairwise consistent for free. Monotonicity — never erasing what you
knew — is the only discipline you need; the sheaf condition follows.

And the colimit of such a filtration is exactly its top level
(`filtration_colimit_eq_top`): the limit of progressive imputation is simply its
final, most-complete stage. Refinement converges to its own destination. The
abstract machinery of colimits, when specialized to the everyday act of filling in
a table step by step, says nothing more exotic than "you end up where you were
heading." That the two viewpoints agree is precisely the kind of consistency check
that tells you the abstraction is the right one.

## Why this changes how we think about imputation

So what does the working data scientist take from all this?

First, a **diagnostic**. Before you impute, you can *test for an obstruction*. If
your partial views fail the sheaf condition — if two of them genuinely disagree
on a shared cell — then **no** imputation method can consistently fill the holes,
because there is no consistent world to fill them into. Mean imputation, k-nearest
neighbors, and the rest will happily produce numbers anyway, but those numbers
paper over a contradiction in your data. The sheaf condition is a tripwire that
fires before you waste effort modeling an impossibility.

Second, a **principle**. The right merge is not "some" filling but *the* least
common extension — the colimit. It adds exactly the information forced by the
data and nothing more. Methods that hallucinate structure to fill blanks are
moving *too far up* the information order; the colimit tells you precisely how far
you are entitled to go.

Third, a **constraint count that explains difficulty**. Each overlapping pair of
views, at each shared cell, is one consistency constraint. A database with many
columns and many rows generates a combinatorial explosion of these constraints —
on the order of `n·(n−1)/2` pairs times the grid size. If each constraint is
satisfied independently with probability `1−r` (where `r` measures the rate of
local disagreement or noise), the probability that *all* of them hold is
`(1−r)^C`, where `C` is the constraint count. This is an *exponential* decay in
the number of overlaps. It is why, as databases grow wide, exact global
consistency becomes vanishingly rare — and why a method that respects the
exponentially many overlap constraints can see structure that blank-by-blank
methods are blind to. The functions modeling this decay are honest: the
consistency probability is monotone decreasing in both the constraint count and
the noise rate, equals one when there is no noise, and drops to zero at full noise
— each fact proved exactly.

## The larger lesson

There is a recurring delight in mathematics: a tool forged for one purpose turns
out to be the natural language for something utterly different. Sheaf theory was
built to track how solutions of equations on small patches of a surface fit
together into solutions on the whole. The "patches" were open sets; the "fitting
together" was the gluing axiom; the obstruction to global assembly was measured by
a subtle invariant called cohomology.

Swap the surface for a spreadsheet and the open sets for partial views, and every
piece of the apparatus transfers intact. Overlaps become shared cells. Sections
become partial databases. Gluing becomes data integration. The gluing axiom
becomes the precise condition for consistent imputation. And the first whisper of
cohomology — the obstruction `H¹` — becomes the question of whether locally
agreeing data can fail to glue globally, a question this framework answers crisply:
for the database sheaf, pairwise agreement *always* suffices, so the obstruction
vanishes and the holes can be filled.

Missing data, it turns out, is a problem in geometry. The blanks in your
spreadsheet are not isolated nuisances but the shadow of a single shape, and
filling them in consistently is the act of recovering that shape's one true
global form. The next time a spreadsheet arrives full of holes, you might see it a
little differently: not as a broken table, but as a partial section waiting to be
glued.
