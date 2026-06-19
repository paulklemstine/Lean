# When Databases Form a Sheaf: The Hidden Geometry of Filling in the Blanks

## A spreadsheet with holes

Imagine a spreadsheet. Rows are patients, columns are measurements: blood
pressure, cholesterol, age, weight. In the real world, this spreadsheet is
never complete. A test was skipped, a sensor failed, a form was left blank.
Wherever a value should be, there is a hole.

The everyday name for the problem of filling those holes is *imputation*.
Statisticians have a toolbox for it: replace each blank with the column
average (mean imputation), or copy values from the most similar rows
(k-nearest-neighbors), or run an iterative model (MICE). These methods work,
and they are everywhere — quietly running inside medical studies, credit
scoring, recommendation engines, and climate reconstructions.

But there is something philosophically unsatisfying about them. Each of these
methods looks at a hole and asks, "What number is *plausible* here?" None of
them asks the deeper question: "What number is *consistent* here?" Consistency
is a structural property. It is about whether the different partial views of
your data can be made to agree with one another. And consistency, it turns
out, has a precise mathematical home — one borrowed not from statistics but
from algebraic geometry. It is called a **sheaf**.

This article is about a simple but far-reaching idea: *a database is a sheaf,
and imputation is the search for a global section of that sheaf.* Once you see
data this way, several facts that looked like heuristics become theorems, and
several questions that looked vague become sharp.

## What is a sheaf, really?

The word "sheaf" sounds intimidating, but the idea is one you already use
every day when you assemble local information into a global picture.

Think of how a map of a country is made. No single surveyor sees the whole
country. Instead, each surveyor charts a small region — a *local view*. The
regions overlap. Where two surveyors' regions overlap, their maps had better
agree: the same river, in the same place, drawn the same way. If every pair of
overlapping local maps agrees on the overlap, you can stitch them together
into one global map. If even a single pair disagrees on a shared river, no
consistent global map exists; someone made a mistake.

That stitching rule has a name in mathematics: the **gluing axiom**, or the
**sheaf condition**. A sheaf is, informally, any system of "local views" that
obey this rule — local data that agree on overlaps can be glued into global
data, uniquely.

Now reread the spreadsheet example with this lens. Each filled-in fragment of
the database — say, the columns and rows recorded by one hospital — is a local
view. Two hospitals that recorded the same patient's blood pressure had better
report the same number. Where the views overlap, they must agree. If they all
agree, the fragments glue into one complete, consistent database. If they
clash, no consistent database contains them all. The spreadsheet *is* a sheaf,
and we just never noticed.

## The formal cast of characters

To make this precise we lay down a small vocabulary, exactly the one used in
the formal development behind this article.

A **position** in a database is a grid cell `(row, column)`. A **partial
database** assigns to each position either a value or a special blank marker
("none"). The **domain** of a partial database is the set of positions where
it actually holds a value — the cells that are *not* blank.

Two partial databases form a **consistent pair** when, at every position where
*both* of them hold a value, those two values are equal. This is the overlap
agreement rule, stated for two views. A whole family of partial databases
satisfies the **sheaf condition** when *every* pair in the family is
consistent — pairwise agreement everywhere.

When two partial databases are consistent, we can **glue** them: form a new
partial database that takes the value from whichever view has one (and either,
where both do — they agree, so it does not matter). A database with no blanks
at all is a **global section**: a complete, fully-imputed table.

That is the entire dictionary. From it, every result in this article follows.

## The first theorem: gluing works

The foundational fact is reassuringly simple to state and, once you believe
the dictionary, almost obvious — which is exactly what you want from a
foundation.

> **Gluing extends both (`gluing_extends_both`).** If two partial databases
> are a consistent pair, then their glued union agrees with the first wherever
> the first had a value, *and* agrees with the second wherever the second had
> a value.

In plain terms: gluing never throws away or corrupts observed data. Every
number you actually measured survives the merge, no matter which of the two
sources it came from. The proof rests on a tiny lemma: where the first
database is undefined, the glue simply copies the second; where the first is
defined, consistency forces the second (if also defined) to match, so copying
the first is harmless. Information is preserved; conflict is impossible by
hypothesis.

Consistency is not an exotic condition; it behaves like the equality it
generalizes. It is **symmetric** (`consistent_pair_symm`): if view A agrees
with view B on overlaps, then B agrees with A. (It is also reflexive — a view
always agrees with itself.) These small facts are the connective tissue that
lets us reason about many views at once.

## Merging many views, one at a time

Real data integration rarely involves just two sources. You have dozens of
spreadsheets, sensors, or hospitals, and you want to merge them all. The naive
worry is that merging two of them might break consistency with the rest. It
does not.

> **Gluing preserves consistency (`gluing_preserves_consistency`).** If three
> partial databases are pairwise consistent, then the glue of the first two is
> still consistent with the third.

This is the permission slip for *incremental* integration. You can fold your
sources together one at a time — glue source 1 and source 2, then glue the
result with source 3, and so on — and as long as everything was pairwise
consistent to begin with, you never create a contradiction along the way. The
order does not matter, and the merge keeps growing.

And it really does grow. Gluing only ever *adds* information:

> **Domains only grow (`gluing_increases_domain`).** The set of filled cells of
> the first database is contained in the set of filled cells of the glue.

You never lose a cell by merging. The completed picture is always at least as
filled-in as any of its parts.

## Measuring inconsistency: the coboundary

So far we have assumed consistency. But the entire point of integrating messy
real data is that it is often *in*consistent — two sources disagree on the same
patient, the same day, the same measurement. We need a number that says *how
inconsistent* a collection of views is.

Borrowing again from algebraic topology, we define the **coboundary norm**.
For each pair of views and each position, the **disagreement indicator** is `1`
if both views are defined there and report different values, and `0` otherwise.
The coboundary norm is the grand total of these indicators, summed over all
pairs and all positions. It is, quite literally, the count of conflicts.

The central bridge theorem ties this conflict count back to the sheaf
condition with no slack whatsoever:

> **Coboundary zero iff sheaf (`coboundary_zero_iff_sheaf`).** The coboundary
> norm of a family of partial databases is exactly zero if and only if the
> family satisfies the sheaf condition.

This is the discrete shadow of one of the deepest dictionary entries in modern
mathematics: the kernel of the coboundary operator is the space of global
sections; "first cohomology vanishes" means "local data glue." Here it becomes
something a programmer can compute: *count the conflicts; if and only if the
count is zero can your data be consistently completed.* Mean imputation and
KNN never compute this number. They cannot tell you whether your data are even
consistent — because they never look at the overlaps.

## What imputation is actually optimizing

With conflicts quantified, "good imputation" gets a precise objective. Given an
observed partial database and a candidate complete database, the **sheaf
imputation objective** counts the observed cells where the candidate disagrees
with what was actually recorded. A perfect imputation is one that respects
every observation.

> **Zero cost iff faithful (`imputation_zero_iff_extends`).** The imputation
> objective is zero if and only if the candidate database reproduces every
> observed value exactly.

This sounds like a tautology, and that is its virtue: it pins down, with no
wiggle room, what it means to fill in blanks *without lying about the data you
have*. The sheaf method's job is to find a zero-cost completion — a global
section that extends the observations. Mean and KNN can and routinely do
violate this: they "smooth over" observed values or let neighboring rows
overwrite genuine measurements. The sheaf objective makes that failure
visible and forbidden.

## The probability of being fillable

Here is where the story turns quantitative and a little dramatic. Suppose the
data are random and noisy. Each potential overlap constraint — each place where
two views could disagree — is independently violated with some probability `r`,
the "conflict rate." How likely is it that the *whole* database is consistent,
that *every* constraint happens to hold at once?

If the constraints were independent, the probability that all `C` of them hold
is `(1 - r)` multiplied by itself `C` times. That is the **consistency
probability**:

> `P(consistent) = (1 - r)^C`.

This single formula carries the moral of the whole subject, and several of its
properties are theorems. It composes the way independent constraints should:

> **Multiplicative composition (`consistency_prob_mul`).** The probability for
> `c1 + c2` constraints equals the product of the probabilities for `c1` and
> for `c2` constraints.

It is **monotone**: more constraints can only lower your chances
(`consistency_prob_mono_constraints`), and a higher conflict rate can only
lower them too (`consistency_prob_mono_rate`). At zero conflict rate it is `1`
(everything is fillable); at conflict rate `1` it collapses to `0` whenever
there is at least one constraint.

Now count the constraints. A database with `n` columns, `k` rows, comparing
every pair of views over the grid, has on the order of `n(n-1)/2` pairwise
comparisons over the cells — the **overlap constraint count**. The crucial
qualitative fact is that this count grows *quadratically*:

> **Quadratic growth (`overlap_quadratic_growth`).** The overlap constraint
> count is bounded by `n · n · (rows · cols)`.

Combine quadratic growth with exponential decay and you get a stark
prediction. Plug in a modest example — `10` columns, `100` rows, a `30%`
conflict rate — and the number of constraints runs into the thousands, so the
consistency probability is `(0.7)` raised to a four-digit power: a number like
`10^{-697}`, indistinguishable from zero. A large, noisy database is
*essentially never* spontaneously consistent. This is not pessimism; it is the
reason imputation is hard, and the reason a method that actively *enforces*
consistency, rather than hoping for it, is so valuable.

This is exactly the content of the **testable exponential-decay conjecture**
(`conjecture_exponential_decay_testable`): the consistency probability built
from the quadratic overlap count is strictly smaller than the probability built
from a merely linear count. The decay is genuinely faster than linear, and you
can falsify it with a simulation — generate a million random noisy tables and
count how many come out consistent. (Spoiler from the arithmetic: none will.)

## Imputation as a growing story

The final piece reframes imputation not as a single leap from "blank" to
"filled" but as a *process* — a sequence of ever-more-complete snapshots. We
call such a sequence a **sheaf filtration**: a chain of partial databases where
each level fills in at least as much as the previous one (monotone in
information) and all levels remain mutually consistent.

The structural payoff is a small surprise:

> **Monotone implies consistent (`sheaf_filtration_auto_consistent`).** If each
> stage of an imputation process only ever *adds* values and never overwrites
> an earlier one, then all stages are automatically pairwise consistent — for
> free.

In other words, the disciplined way of imputing — only fill blanks, never edit
what you have already committed — cannot create contradictions. Consistency,
which we worked hard to define, comes bundled with monotonicity at no extra
charge. And the process accumulates everything:

> **Nothing is lost (`filtration_final_contains_all`).** In any such chain, the
> final, most-complete database contains every cell filled at every earlier
> stage.

The story only ever moves toward completeness.

## Why this matters beyond the spreadsheet

Step back and look at what the dictionary bought us. By renaming "spreadsheet
with holes" as "partial section of a sheaf," a grab-bag of data-cleaning
heuristics turned into a small, rigorous theory with provable guarantees:
merging never corrupts data; consistency is exactly conflict-count-zero; faithful
imputation is exactly zero-cost imputation; the chance of accidental
consistency decays exponentially in a quadratically growing number of
constraints; and disciplined, monotone imputation is contradiction-free by
construction.

The deeper lesson is the one mathematicians keep relearning: the right language
makes the hard parts visible and the obvious parts free. Sheaves were invented
to understand how solutions to equations on small patches of space fit together
into solutions on the whole space. Eighty years later, the same gluing rule
tells a hospital whether its patient records can be merged without lying, and a
data scientist exactly why their billion-cell table will never be consistent by
luck. The geometry of filling in the blanks was hiding in plain sight, in every
spreadsheet we ever left half-empty.
