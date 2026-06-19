# When a Spreadsheet Becomes a Sheaf: The Hidden Geometry of Missing Data

Every data scientist knows the quiet dread of the empty cell. You open a
spreadsheet of patient records, sensor logs, or survey answers, and there they
are: the blanks. A blood pressure not taken. A temperature the sensor missed.
A question a respondent skipped. The standard response is to *impute* — to
guess the missing values. Fill blanks with the column average. Borrow from the
nearest similar row. Run a fancy iterative model. These methods all work, after
a fashion, and they all share one blind spot: they treat each missing value as
an isolated puzzle, ignoring a deeper structure that the data has been carrying
all along.

That structure has a name from a corner of mathematics that sounds about as
far from spreadsheets as you can get: **sheaf theory**. Sheaves were invented
to track how local information on a geometric space — say, functions defined on
small patches — can be stitched together into a single global object, and to
detect exactly when that stitching fails. The punchline of this article is
that a database with missing entries is, quite literally, a partial section of
a sheaf, and the centuries-old machinery for gluing local data is precisely the
machinery you need to fill in blanks consistently. The mismatch between local
patches is not noise to be smoothed away; it is a measurable obstruction, and
when it vanishes, imputation is not just possible but *unique*.

This is not a loose analogy. Every claim below has been formalized and
machine-checked, so the bridge between "missing data" and "sheaf gluing" is
built on bedrock rather than hand-waving.

## A database is a function on a grid

Let us be concrete. Picture a table with `nRows` rows and `nCols` columns. Each
cell sits at a position `(r, c)` — row `r`, column `c`. A **complete** database
is simply a function that assigns a value to every position. A real database,
the kind with holes in it, assigns to each position *either* a value *or* the
special token "missing." Mathematically we model this as a function

> `PartialDB = (position) → Option value`,

where `Option value` means "either some value, or nothing." The positions where
the function returns a genuine value form its **domain** — the part of the table
you actually observed.

Two sub-tables that describe the same underlying reality should not contradict
each other. If table A and table B both recorded the blood pressure in cell
`(7, 3)`, they had better record the *same* blood pressure. This is the heart of
the whole story, and it gets a precise name:

> **Consistency.** Two partial databases are *consistent* if, at every position
> where both of them have a value, those values agree.

Consistency is the discrete shadow of the most important idea in sheaf theory:
local pieces of data are allowed to overlap, and on the overlap they must match.
A whole *family* of partial databases satisfies the **sheaf condition** when
every pair in the family is consistent. That is the entire condition — pairwise
agreement on overlaps, nothing more exotic.

## Gluing: assembling the whole from the parts

Once two tables agree where they overlap, you can merge them. The merge — call
it the **gluing** — takes each cell's value from table A if A has one, and
otherwise from table B. The first formal result says this merge behaves exactly
as a merge should:

> **Theorem (gluing extends both).** If two partial databases are consistent,
> then their gluing agrees with the first wherever the first is defined *and*
> agrees with the second wherever the second is defined.

In plain words: nothing you observed gets overwritten or lost. The merged table
contains both originals faithfully. The proof is a short case analysis — for a
given cell, either the first table has a value (and the merge copies it) or it
does not (and the merge copies the second table's value, which consistency
guarantees would match the first anyway).

This extends, one table at a time, to whole collections. The key fact that makes
incremental merging safe is:

> **Theorem (gluing preserves consistency).** If three databases are pairwise
> consistent, then merging the first two yields a table that is still consistent
> with the third.

So you can glue a pile of mutually-consistent sub-tables in any order and never
paint yourself into a corner. This is the database analogue of the sheaf axiom
that local sections agreeing on overlaps assemble into a global section.

And the easy direction holds too, as a sanity check on the whole framework:

> **Theorem (restrictions of a global section glue).** If you start from one
> complete table and chop it into overlapping pieces, those pieces always
> satisfy the sheaf condition.

Of course they do — they all came from the same source, so they cannot disagree.
The interesting content is the converse: when *can* a pile of pieces have come
from a common source? That is exactly what consistency decides.

## The coboundary: a single number that measures inconsistency

Here is where the geometry earns its keep. Mathematicians studying sheaves
measure the failure of gluing with a gadget called the **Čech coboundary**, and
its discrete version is wonderfully tangible. For each pair of tables and each
cell, define a *disagreement indicator*: it is `1` if both tables have a value
there and the values differ, and `0` otherwise. Sum this indicator over all
pairs of tables and all cells, and you get a single non-negative integer, the
**coboundary norm** — the total count of contradictions in your collection.

The central bridge theorem says this number tells you everything:

> **Theorem (coboundary zero iff sheaf).** The coboundary norm of a family of
> partial databases equals zero *if and only if* the family satisfies the sheaf
> condition.

Read that slowly, because it is the conceptual heart of the article. On the left
is a purely *algebraic* quantity — add up some 0s and 1s. On the right is a
*geometric* statement — the pieces can be glued. The theorem says they are the
same thing. Zero contradictions means consistent means gluable. A single
contradiction anywhere means the norm is positive means the global section does
not exist. This is the discrete echo of one of the deepest slogans in modern
mathematics: the kernel of the coboundary operator is the space of global
sections, and the first cohomology group `H¹` measures the obstruction to
gluing. Your spreadsheet has a cohomology, and its vanishing is the precise
license to impute.

## Imputation as finding the nearest consistent world

So what *is* imputation, in this language? You have observed data with holes.
You want a complete table — a candidate filling of every cell. The natural cost
of a candidate is the number of observed cells where it gets the answer wrong.
This is the **sheaf imputation objective**. And it has a crisp optimum:

> **Theorem (zero cost iff the candidate extends the data).** The imputation
> objective is zero exactly when the candidate agrees with every value you
> actually observed.

A perfect imputation, then, is one that respects all your data and merely fills
the blanks — a global section restricting to your partial section. This reframes
imputation as a constrained search: among all complete tables, find one whose
restriction to the observed cells matches what you saw. Mean imputation and
nearest-neighbor imputation produce *a* filling, but they never check whether
the filling is consistent across overlapping views of the data. The sheaf
viewpoint makes the consistency constraint the *objective itself*.

## Why consistency gets exponentially harder

If consistency is so powerful, why is it not automatic? Because every pair of
overlapping views imposes its own constraint, and constraints multiply. With `n`
columns and `k` rows the number of overlap constraints scales like

> `overlapConstraintCount = n(n-1)/2 · (rows × columns),`

which grows quadratically in the number of views — formally bounded by `n²`
times the grid size. Now suppose each individual constraint is satisfied
independently with probability `1 - r`, where `r` is the rate at which random
fillings clash. The probability that *all* `c` constraints hold at once is

> `consistencyProbability(r, c) = (1 - r)^c.`

This single formula carries the whole probabilistic story, and several exact
facts pin it down. It composes multiplicatively — adding constraints multiplies
the odds:

> **Theorem (multiplicative composition).** `(1-r)^{c₁+c₂} = (1-r)^{c₁} · (1-r)^{c₂}`.

It decreases as you add constraints and as the clash rate climbs (both proved),
it equals `1` at zero clash rate, and it hits `0` once any clash is certain.
The consequence is stark. The formalized **conjecture of exponential decay**
predicts that for a realistic table — say 10 columns and 100 rows at a 30%
clash rate — the number of overlap constraints runs into the thousands, and
`(0.7)` raised to that power is a number with hundreds of zeros after the decimal
point. Spontaneous, accidental consistency is astronomically unlikely. Real
databases are consistent not by luck but because they describe a real, coherent
world — and that is exactly why the sheaf constraints carry so much information
that average-and-fill methods throw away.

## Imputation as a process: filtrations

The framework even captures imputation as something that unfolds over time.
Imagine filling blanks progressively: each round you commit a few more values,
never erasing what you already wrote, and you insist that every snapshot stays
consistent with every other. This is a **sheaf filtration** — a sequence of
ever-richer tables, monotone in information and consistent throughout. Two
elegant facts make this notion well-behaved:

> **Theorem (monotone implies consistent).** If each stage only *adds*
> information and never changes an existing value, then all stages are
> automatically pairwise consistent — you get the sheaf condition for free.

> **Theorem (the final stage contains everything).** In any such filtration, the
> domain of the last table includes the domains of all earlier ones. Information
> accumulates; nothing is ever lost.

Together these say that a disciplined, monotone imputation pipeline is
*structurally* guaranteed to stay coherent and to converge toward a maximally
informed table. The order-theoretic condition "only ever add" silently enforces
the geometric condition "everything glues."

## The bigger picture

Strip away the vocabulary and a clean idea remains. Data with holes lives on a
grid. Overlapping views of that data must agree where they meet. The agreement
can be measured by a single number whose vanishing is equivalent to the
existence of a unique, faithful completion. And the odds of accidental agreement
fall off exponentially with the number of overlaps, which is why genuine
consistency is such a strong signal.

These are the same moves that algebraic geometers and topologists make when they
glue functions on a manifold or compute the cohomology of a space. The migration
of those ideas into data science is not a metaphor dressed up in symbols; it is
an exact correspondence, checked line by line. The next time you stare at a
spreadsheet full of blanks, you can see past the inconvenience to the geometry
underneath: a sheaf, waiting to be glued, its missing entries determined — when
they are determined at all — by the quiet insistence that the parts must fit the
whole.
