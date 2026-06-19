# When Databases Become Geometry: The Hidden Sheaf Inside Your Missing Data

Every organization that has ever stored information eventually meets the same
quiet adversary: the blank cell. A customer record without a phone number. A
sensor reading dropped during a network hiccup. A medical chart with the weight
recorded but the height missing. Spreadsheets and databases are riddled with
holes, and the everyday craft of *filling them in* — statisticians call it
**imputation** — is one of the most consequential, least glamorous tasks in all
of data science. Get it wrong, and your forecasts wobble, your models hallucinate,
your dashboards lie.

The usual recipes are familiar and a little crude. Replace a missing value with
the column average. Copy it from the nearest neighbor. Train a model to predict
the gap. These methods are useful, but they share a curious blind spot: **they
never check whether the pieces of your data actually agree with one another.**
They fill holes one at a time, locally, without asking the global question that a
careful human would ask first — *are these partial views even consistent?*

It turns out that this question has a precise, beautiful answer, and the answer
comes from an unexpected corner of pure mathematics: the theory of **sheaves**,
a language invented in the 1940s to study how local information on a geometric
space can be stitched into global information. The same machinery that tells an
algebraic geometer when local solutions to an equation patch together into a
global one tells a data engineer exactly when a collection of partial databases
can be merged into one complete, contradiction-free table — and when it cannot.

This article tells the story of that bridge, and of a handful of theorems that
make it rigorous.

## The shape of a database

Start with the most innocent object imaginable: a table with rows and columns.
Picture a grid with `nRows` rows and `nCols` columns. Each cell sits at a
position — a pair `(row, column)` — and either holds a value or is empty.

We capture this formally with a single idea. A **partial database** is a function
that takes a grid position and returns *either* a value *or* the special symbol
`none` meaning "missing":

> **Definition (Partial database).** Over a value type `V`, a partial database on
> an `nRows × nCols` grid is a function `db` from positions to `Option V`. A
> position `p` is *observed* when `db p` is some value, and *missing* when
> `db p = none`. The **domain** of `db` is the set of observed positions.

This little `Option` — value or nothing — is the entire conceptual move. A
complete table with no holes is called a **global section**: a partial database
where *every* position is observed. Imputation, in this language, is the search
for a global section that is faithful to what we already know.

## The crucial question: do the pieces agree?

Real data rarely arrives as one tidy table. It arrives as fragments: one system
exports customer names and emails, another exports emails and purchase histories,
a third exports purchase histories and shipping addresses. Each fragment is a
partial database. They *overlap* — two of them might both record the same
customer's email — and on those overlaps they had better tell the same story.

This is the heart of the matter. We say two partial databases are **consistent**
when they never contradict each other where both have an opinion:

> **Definition (Consistent pair).** Two partial databases `db1` and `db2` are
> *consistent* if, for every position `p`, whenever `db1` reports value `v1` at
> `p` and `db2` reports value `v2` at `p`, we have `v1 = v2`.

Notice what this definition does *not* require: it says nothing about positions
where only one of the two has data. Disagreement is only possible — and only
forbidden — on the overlap. A family of many partial databases satisfies the
**sheaf condition** when *every* pair in the family is consistent.

Three small but reassuring facts fall out immediately, and each was verified
formally:

- **Consistency is symmetric** (`consistent_pair_symm`): if `db1` agrees with
  `db2`, then `db2` agrees with `db1`. Agreement is a two-way street.
- **Consistency is reflexive** (`consistent_pair_refl`): every database agrees
  with itself.
- **Everything is consistent with emptiness** (`consistent_with_empty`): a table
  full of holes contradicts nothing, because it never offers a competing value.

These feel obvious — and that is exactly the point. A good formal foundation
should make the obvious things provably obvious, so that the surprising things
can be trusted.

## Gluing: assembling the whole from the parts

Once we know two partial databases agree on their overlap, we want to *merge*
them. The merge operation — sheaf theorists call it **gluing** — is defined by
preferring the first database wherever it has a value and falling back to the
second otherwise:

> **Definition (Gluing).** The gluing of `db1` and `db2` is the partial database
> that, at each position, returns `db1`'s value if it has one, and otherwise
> returns `db2`'s value.

The definition looks asymmetric — it favors `db1` — and you might worry that the
merged table secretly depends on which database we listed first. Here is where
consistency earns its keep. The central structural theorem says that when the
two databases are consistent, the gluing faithfully **extends both of them**:

> **Theorem (Gluing extends both, `gluing_extends_both`).** If `db1` and `db2`
> are consistent, then every value recorded by `db1` survives in the gluing, and
> every value recorded by `db2` survives in the gluing.

The first half is easy — the gluing was *built* to prefer `db1`. The second half
is the miracle: even though the gluing prefers `db1`, none of `db2`'s information
is lost, *because wherever both spoke they said the same thing.* Consistency is
precisely the hypothesis that makes the asymmetric construction behave
symmetrically. This is the discrete shadow of the sheaf-theoretic gluing axiom:
**compatible local data can always be assembled into a larger, faithful whole.**

Gluing also behaves well in chains. If three databases are pairwise consistent,
then gluing the first two yields something still consistent with the third
(`gluing_preserves_consistency`). This is what lets you integrate a hundred data
sources by absorbing them one at a time, never having to redo earlier work — the
algorithmic backbone of incremental data integration.

## Measuring inconsistency: the coboundary

So far, consistency has been a yes-or-no property. But in the real world we want
a *dial*, not a switch — a number that says *how badly* a collection of databases
disagrees, so we can track it, minimize it, and report it.

That number is the **coboundary norm**. At each position, for each pair of
databases, we record a single bit: `1` if both are defined and disagree, `0`
otherwise. Summing these bits over all pairs and all positions gives a total
disagreement count:

> **Definition (Coboundary norm).** For a family of `n` partial databases, the
> coboundary norm is the total number of (pair, position) combinations at which
> the two databases are both observed and contradict each other.

The name is borrowed deliberately. In algebraic topology, the *coboundary
operator* measures the failure of local data to be globally consistent, and its
kernel — the things it sends to zero — is exactly the space of genuinely global
objects. The same drama plays out here, and it is captured by what is arguably
the keystone theorem of the whole development:

> **Theorem (Coboundary vanishes iff sheaf condition, `coboundary_zero_iff_sheaf`).**
> The coboundary norm of a family of partial databases equals zero if and only
> if the family satisfies the sheaf condition.

Read it slowly, because it unifies two worlds. On the left is an *algebraic*
statement — a single number is zero. On the right is a *geometric* statement —
the local pieces glue. The theorem says they are the same fact wearing two
costumes. This is the discrete, finite, fully verified analogue of the classical
slogan that the kernel of the coboundary is the space of global sections.
Inconsistency is not a vague unease about messy data; it is a measurable
quantity, and it vanishes exactly when geometry permits a clean merge.

## Imputation as optimization

Now we can finally say what good imputation *means*. Given an observed partial
database, a candidate complete table should agree with everything we actually
saw. Score a candidate by counting the observed cells it gets wrong:

> **Definition (Imputation objective).** For an observed partial database and a
> candidate complete table, the objective is the number of observed positions
> where the candidate's value differs from the observed value.

The optimum is unambiguous, and again it was proved formally:

> **Theorem (Zero cost iff faithful extension, `imputation_zero_iff_extends`).**
> The imputation objective is zero if and only if the candidate agrees with the
> observed value at every observed position.

A perfect imputation, then, is exactly a global section that *extends* the
observed data — it invents values for the holes while never overwriting a single
thing you knew. This reframes a fuzzy engineering task as a crisp optimization
problem with a characterized optimum, and it explains in one line why average-
and neighbor-based methods can score badly: they make no promise to preserve the
overlaps that the objective actually measures.

## Why consistency gets harder as data grows

There is a sobering corollary hiding in all of this. The number of overlap
constraints a dataset must satisfy grows with its size. With `n` feature-subsets
there is one agreement constraint per *pair* — that is `n(n-1)/2` of them — and
each pair imposes constraints across the whole grid. The constraint count grows
**quadratically** in the number of sources (`overlap_quadratic_growth`).

Now suppose each individual constraint has some small independent chance `r` of
being violated by noise. Then the probability that *all* constraints hold at once
behaves like `(1 - r)` raised to the power of the constraint count:

> **Definition (Consistency probability).** With per-constraint disagreement rate
> `r` and `C` constraints, the probability that everything is consistent is
> `(1 - r)^C`.

This quantity has exactly the properties intuition demands, each one proved: it
*falls* as you add constraints (`consistency_prob_mono_constraints`), it *falls*
as the noise rate rises (`consistency_prob_mono_rate`), it equals `1` when there
is no noise (`consistency_prob_zero_rate`), and it collapses to `0` under total
noise (`consistency_prob_one_rate`). It even *composes multiplicatively*: bolting
together two independent constraint sets multiplies their probabilities
(`consistency_prob_mul`), which is the precise reason the decay is exponential
rather than gentle.

The numbers are bracing. For a modest table of 10 columns and 100 rows with a
30% disagreement rate, the constraint count runs into the thousands, and the
probability of perfect, accidental consistency is something like `10` to the
*negative seven-hundredth* power — indistinguishable from zero. The lesson is not
despair but design: large-scale data integration cannot rely on luck. It must
*actively enforce* consistency, source by source, exactly the way the gluing
theorems prescribe.

## Imputation as a growing crystal: the sheaf filtration

The final idea is the most novel. Real imputation is rarely a single leap from
"full of holes" to "complete." It is a *process*: we fill in the easy, certain
values first, then use them to justify filling in more, and so on. To model this,
we borrow another tool from homological algebra — the **filtration**, a sequence
of structures that grow into one another.

> **Definition (Sheaf filtration).** A sheaf filtration of depth `d` is a sequence
> of `d` partial databases such that (i) each level *extends* the previous one —
> a value, once filled, is never erased or changed — and (ii) all levels are
> pairwise consistent.

The growth condition turns out to do remarkable structural work. We proved that
**monotonicity implies consistency for free**:

> **Theorem (Monotone filtrations are automatically consistent,
> `sheaf_filtration_auto_consistent`).** If every level of a sequence extends the
> previous one, then the whole family automatically satisfies the sheaf
> condition.

In other words, if your imputation pipeline only ever *adds* information and never
overwrites, you can never introduce a contradiction. Consistency is not an extra
checkpoint to police; it is a *guarantee baked into a disciplined process.* And
because information only accumulates, the final level of any filtration contains
the domains of all earlier levels (`filtration_final_contains_all`) — nothing is
ever lost on the way to completion. Even a single fragment forms a (trivial)
filtration of depth one (`sheaf_filtration_exists_singleton`), giving an
inductive base from which richer filtrations can be built.

## The bridge, in one sentence

Strip away the vocabulary and here is what we have learned. **A database with
missing values is a partial section of a sheaf; consistent imputation is gluing;
inconsistency is a coboundary; and a disciplined, monotone imputation process is a
filtration that cannot contradict itself.** The abstractions that Jean Leray
invented in a prisoner-of-war camp to understand the topology of continuous
spaces turn out to describe, with uncanny precision, the very concrete problem of
merging your spreadsheets without lying.

That is the recurring delight of mathematics: a structure built for one purpose,
pursued for its own elegance, waiting decades to reveal that it was secretly about
something you needed all along. The blank cell in your database is not just an
absence. It is an invitation to geometry.
