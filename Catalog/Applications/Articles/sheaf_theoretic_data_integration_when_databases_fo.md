# When a Spreadsheet Becomes a Sheaf: The Hidden Geometry of Missing Data

Every data scientist knows the quiet dread of an incomplete table. A
spreadsheet of customer records with empty cells. A sensor log with gaps where
the network dropped. A medical dataset where half the patients never took the
optional test. The missing values are not just an inconvenience — they are the
single most common obstacle between raw data and a usable model.

The usual response is to *guess*. Replace the blanks with the column average.
Borrow values from the most similar rows. Run a statistical model that invents
plausible numbers. These tricks work, sometimes well. But they all share a
blind spot: they treat each missing cell as an isolated puzzle, ignoring a
deeper structure that the data itself carries. That structure has a name, and
it comes from one of the most beautiful corners of twentieth-century
mathematics. It is called a **sheaf**.

This article is about a simple but far-reaching idea: *a database with missing
entries is a partial section of a sheaf, and filling it in consistently is the
problem of gluing those sections into a whole.* Once you see data this way, a
remarkable amount of machinery — built originally to study geometry, topology,
and complex analysis — snaps into place and starts answering practical
questions about data. We will build the idea from scratch, state the precise
theorems that make it rigorous, and explain a surprising prediction: that the
probability of being able to fill in a random table *consistently* collapses
exponentially as the table grows.

## The shepherd and the patchwork

The word "sheaf" is agricultural — a bundle of stalks tied together — and the
intuition is exactly that. Imagine you are mapping the temperature across a
country. You don't have one giant thermometer; you have thousands of local
weather stations, each reporting the temperature in its own little region.
These local reports are *local data*. The question a sheaf answers is: **when
can local data be stitched into a single global picture?**

The answer is almost embarrassingly intuitive. Two neighboring stations whose
regions overlap must *agree* on the overlap. If one says it is 20°C in the town
square and another says it is 25°C in the same square, something is wrong — the
patches cannot be glued. But if every pair of overlapping reports agrees
wherever they overlap, then (and this is the magic) the patches *can* be glued
into one coherent global map. This "agree-on-overlaps-implies-gluable" promise
is the **sheaf condition**, the central axiom of the whole theory.

Now swap the weather map for a database. The "regions" become *subsets of
cells* in a table — say, the columns one source knows about. Each data source
is a partial table, filled in where that source has information and blank
elsewhere. Two sources are *consistent* if, wherever they both report a value
for the same cell, they report the **same** value. The dream of data
integration — merging many partial, overlapping sources into one clean,
complete table — is *exactly* the gluing problem for a sheaf.

## Making it precise

Let us pin the idea down. Fix a grid of positions, one for each (row, column)
pair. A **partial database** is a function that assigns to each position either
a value or the special token "missing." In the formalization underlying this
article, missing-ness is captured by the `Option` type: each cell holds either
`some v` (a value `v`) or `none` (a gap).

Two partial databases `db1` and `db2` are **consistent** when, for every
position `p` and every pair of values `v1`, `v2`, if `db1` reports `v1` at `p`
and `db2` reports `v2` at `p`, then `v1 = v2`. This is the discrete overlap
condition. A whole *family* of databases `dbs` satisfies the **sheaf
condition** when every pair `dbs i`, `dbs j` in it is consistent.

Three small facts confirm that consistency behaves the way a notion of
"compatibility" should:

- **Reflexivity** (`consistent_pair_refl`): every database is consistent with
  itself.
- **Symmetry** (`consistent_pair_symm`): if `db1` is consistent with `db2`,
  then `db2` is consistent with `db1`.
- **The empty database is universal** (`consistent_with_empty`): a database
  with *every* cell missing is consistent with absolutely everything — it
  asserts nothing, so it contradicts nothing.

These look trivial, and they are. But they are exactly the axioms that let us
treat consistency as the overlap-compatibility relation of a genuine sheaf, and
they are the base cases on which the harder results rest.

## Gluing: turning patches into a whole

Given two partial databases, how do we actually combine them? We define the
**gluing map**: walk over every position; if the first database has a value
there, keep it; otherwise, fall back to whatever the second database says. This
is a deterministic, computable rule — and crucially, it does the right thing
when the inputs are consistent.

The headline result here is **`gluing_extends_both`**: *if `db1` and `db2` are
consistent, then their gluing extends both of them.* In plain terms, the merged
table never overwrites or contradicts any value that either source provided.
Every fact known to either source survives into the union. The proof has two
halves. Extending the first source is immediate from the gluing rule. Extending
the second is the interesting case: where the first source already has a value,
consistency forces it to match the second source's value, so no information is
lost; where the first source is blank, the gluing simply copies the second
source.

Two companion facts (`gluing_increases_domain` and
`gluing_preserves_right_domain`) record that gluing only ever *adds*
information: the set of filled cells of the result contains the filled cells of
each input. Merging never creates new holes.

And gluing plays well with others. **`gluing_preserves_consistency`** shows
that if three databases are pairwise consistent, then gluing the first two
yields a database still consistent with the third. This is what makes
*iterated* integration safe: you can fold many sources together one at a time,
and at no point do you paint yourself into a corner. The order does not trap
you; consistency is preserved at every step.

## The "easy direction": global truth always glues

There is a satisfying sanity check buried in the theory. Suppose there really
is a single, complete, correct database — a *global section* — and each of our
sources is simply a *restriction* of it to the cells that source happens to
observe. Then the sources are *automatically* consistent. They are all shadows
of the same object, so they cannot contradict one another.

This is **`sheaf_condition_of_global_restriction`**: restricting one global
database to any family of position-subsets always yields a family satisfying the
sheaf condition. It is the discrete echo of a foundational fact in geometry —
that the restrictions of a single global function to overlapping open sets
always agree. In data terms: if your sources are honest windows onto one
underlying reality, they will be consistent. Inconsistency is therefore *itself
information* — it is evidence that no single reality explains all the sources at
once.

## Measuring inconsistency: a coboundary for data

What if the sources *don't* agree? Real data is messy, and we want to quantify
*how* messy. Borrowing again from the homological-algebra toolbox, we define a
**coboundary norm**: for a family of databases, count up every position where
two of them both report a value and those values *disagree*, summed over all
pairs and all positions. The pointwise ingredient is the **disagreement
indicator** — it contributes `1` exactly when two sources clash at a cell, and
`0` otherwise.

The central bridge theorem is **`coboundary_zero_iff_sheaf`**: *the coboundary
norm is zero if and only if the sheaf condition holds.* Total disagreement
vanishes precisely when every pair of sources is consistent everywhere. This is
the discrete shadow of one of the deepest dictionaries in mathematics — that
the *kernel* of a coboundary operator (the things with zero coboundary) is
exactly the space of globally consistent sections, the degree-zero cohomology
`H⁰`. The grand statement "data integration is a problem in sheaf cohomology"
is, at its computational heart, this single equivalence: *inconsistency is a
coboundary, and consistency is its vanishing.*

## Imputation as optimization

Now we can say precisely what it *means* to fill in a table well. Given an
observed partial database, an **imputation** is a complete assignment — a value
in every cell. We score a candidate by the **imputation objective**: count the
observed cells where the candidate *disagrees* with what was actually seen. A
perfect imputation respects every value you started with and only invents the
genuinely missing ones.

The clean characterization is **`imputation_zero_iff_extends`**: *the
imputation objective is zero if and only if the candidate extends the observed
data* — that is, it agrees with every value the source actually provided.
"Closest complete database" is therefore not a vague aspiration; it is an
honest optimization problem whose global minimum (cost zero) is exactly the set
of faithful completions. **Sheaf imputation** is the program of finding such a
completion that also respects the overlap constraints across feature subsets —
constraints that mean-filling and nearest-neighbor methods simply throw away.

## The exponential cliff

Here is where the geometry makes a startling, falsifiable prediction. Suppose
each overlap constraint independently has some probability `r` of being
*violated* by noise — a per-constraint "disagreement rate." If the constraints
behave independently, the probability that *all* of them hold at once is

> **P(consistent) = (1 − r)^C,**

where `C` is the number of constraints. This is the **consistency probability
model** (`consistencyProbability`), and the file proves it behaves exactly as a
probability should and as intuition demands:

- It **decreases as constraints pile up** (`consistency_prob_mono_constraints`):
  more overlap conditions make consistency strictly harder.
- It **decreases as noise rises** (`consistency_prob_mono_rate`): a noisier
  channel is less likely to be globally consistent.
- It is **1 at zero noise** (`consistency_prob_zero_rate`) and **0 at total
  noise** when there is at least one constraint (`consistency_prob_one_rate`).
- It **composes multiplicatively** (`consistency_prob_mul`): independent batches
  of constraints multiply, so `P` for `c1 + c2` constraints equals the product
  of the two pieces — and doubling the constraints squares the probability
  (`consistency_prob_double`).
- It always stays a legitimate probability, between `0` and `1`
  (`consistency_prob_nonneg`, `consistency_prob_le_one`).

The number of overlap constraints `C` grows fast. With `n` columns and `k`
rows, comparing every pair of sources over every cell gives on the order of
`n(n−1)/2 · (k·n)` constraints (`overlapConstraintCount`), which grows roughly
*quadratically* in the number of sources (`overlap_quadratic_growth`) and is
zero only in the degenerate case of fewer than two sources
(`overlap_zero_of_lt_two`).

Put the pieces together and you get a genuinely dramatic forecast. For a modest
table — say 10 columns, 100 rows, and a 30% disagreement rate — the constraint
count runs into the thousands, and `(0.7)` raised to that power is a number with
hundreds of zeros after the decimal point: effectively zero. The conjecture
`conjecture_exponential_decay_testable` packages this as a concrete,
*falsifiable* claim: generate a million random tables, check how many are
spontaneously consistent, and watch the count sit stubbornly at zero. The
lesson is not despair — it is that *random* data is essentially never globally
consistent, so the consistency you *do* find in real data is a fingerprint of
genuine structure. That is precisely the structure sheaf imputation exploits
and other methods ignore.

## Building up the picture, one layer at a time

Real imputation is rarely a single leap from blanks to a finished table; it is
a *process*. To model this, the theory introduces a genuinely new gadget: the
**sheaf filtration**. A sheaf filtration is a sequence of partial databases,
each level filling in more cells than the last, subject to two rules:
*monotonicity* (information only grows — a value, once asserted at some level,
persists at every later level) and *consistency* (all the levels are pairwise
consistent). It is the data-science cousin of a *filtered complex* in
homological algebra, where one studies an object by watching it assemble through
a rising chain of approximations.

The structural payoff is **`sheaf_filtration_auto_consistent`**: *monotonicity
implies consistency for free.* If each layer only ever extends the previous one,
the layers cannot possibly contradict each other — a value at an earlier level
reappears unchanged later, so two levels comparing the same cell must agree.
This reduces the somewhat global "sheaf condition" to a simpler, local,
order-theoretic property, and it tells the practitioner something concrete: *if
your imputation pipeline never overwrites a previously committed value, it is
automatically consistent.*

Two more results round out the picture. **`sheaf_filtration_exists_singleton`**
shows that any single database is, trivially, a one-level filtration — the
construction is never vacuous. And **`filtration_final_contains_all`** proves
that the last level's set of filled cells contains those of *every* earlier
level: across the whole process, information accumulates and nothing is ever
lost. When the final level fills every cell, the filtration is **complete**
(`SheafFiltration.isComplete`) — the progressive process has terminated in a
genuine global section, a fully imputed table.

## Why this matters

It is tempting to dismiss all this as a high-flown re-description of common
sense — of course you shouldn't overwrite known values, of course inconsistent
sources can't be merged. But re-description is exactly what good mathematics
does, and the payoff is leverage. By recognizing missing-data integration as a
sheaf-gluing problem, we inherit a precise vocabulary (sections, restriction,
gluing, coboundary, cohomology), a precise notion of optimality (zero
imputation cost equals faithful extension), a precise measure of failure (the
coboundary norm), and a precise quantitative prediction (exponential
consistency decay). Each of these has been stated and *proved*, not merely
asserted.

The deepest message is a shift in perspective. Inconsistency is not noise to be
smoothed away — it is an *obstruction*, in the technical sense, and obstructions
are measurable. When a family of sources refuses to glue, the coboundary norm
tells you how badly, and a more refined theory (the first cohomology of the data
sheaf) promises to tell you *where* and *why*. The blank cells in your
spreadsheet, it turns out, are not gaps in a list. They are missing patches of a
landscape, and the question of whether they can be filled is a question about
the shape of that landscape. Geometry was hiding in the spreadsheet all along.
