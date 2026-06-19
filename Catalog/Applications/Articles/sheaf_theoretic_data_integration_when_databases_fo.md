# When a Spreadsheet Becomes a Sheaf: The Hidden Algebra of Filling in the Blanks

## A problem older than computers

Every dataset that has ever mattered has had holes in it. A census form left
half-blank. A medical record where the patient skipped the cholesterol panel. A
survey where respondents quietly ignored the awkward question. A sensor that
dropped offline for an hour. The spreadsheet is the universal language of modern
life, and the universal feature of every real spreadsheet is that some of the
cells are empty.

So we *fill them in*. The polite name for guessing the missing entries is
**imputation**, and it is one of the most consequential quiet operations in all
of data science. Every time a hospital builds a risk model, every time a bank
scores a loan, every time a climate model ingests patchy weather stations,
somebody — or some algorithm — has filled in the blanks first. The default
methods are blunt: replace a missing number with the column average, or copy the
value from the most similar complete row.

This article is about a different and more beautiful way to think about the
problem. It turns out that the act of merging incomplete records is not an ad hoc
hack at all. It is a genuine algebraic operation, with its own laws — laws as
rigid and as elegant as the laws of arithmetic. And the question "can these
records be consistently combined?" turns out to be a question with a clean,
checkable, *purely local* answer. The mathematical object lurking underneath is
called a **sheaf**, and the punchline is a slogan worth remembering:

> A database with missing entries is a partial section of a sheaf, and filling in
> the blanks consistently is possible exactly when the records agree wherever
> they overlap.

Let us unpack that, slowly and concretely.

## Rows with holes

Start with the humblest object imaginable. Fix a set of columns — call the column
labels `i`. A **row with holes** is a function that assigns to each column either
an actual value or the symbol "blank." In the formal development this is written

```
PartialSection ι α  :=  ι → Option α
```

which is jargon for: "for each column `i`, you either get a value (`some a`) or
nothing (`none`)." The columns where a row *does* have a value form its
**support** — the filled cells. A completely blank row, with `none` in every
column, will be our hero later; we call it the **empty section**.

Two natural ideas come for free. We say two rows are **compatible** if they never
contradict each other: wherever *both* rows have a value in the same column,
those two values are equal. (They are allowed to disagree about which cells are
blank — only the filled-in cells must match.) And we say one row **extends**
another if it agrees with it on every cell the smaller row had filled — a
completion that never overwrites known data.

## The merge, and its secret laws

Now the central operation. Given two rows `f` and `g`, define their **merge**,
written `glue f g`, by the simplest possible rule:

> For each column, take `f`'s value if `f` has one; otherwise fall back to `g`.

This is exactly what a spreadsheet user does when they paste one record on top of
another: the top record wins, and the bottom record only shows through the holes.
It is so simple it looks like it could not possibly have interesting structure.

It has a great deal of structure. Here are the laws this merge obeys — each one
is a proved theorem, not a heuristic.

**The empty row is invisible.** Merging anything with the all-blank row, on
either side, gives you back exactly what you started with: `glue empty f = f` and
`glue f empty = f`. In algebra, an element that does nothing when combined is
called a *unit* or *identity* — like `0` for addition or `1` for multiplication.
The empty record is the identity of merging.

**Merging is associative.** If you have three records to combine, it does not
matter how you parenthesize: `glue (glue f g) h` equals `glue f (glue g h)`. You
can merge a stack of records in any grouping and get the same answer. Together
with the identity law, this means rows-with-holes form a **monoid** — the same
abstract skeleton shared by addition of numbers, concatenation of strings, and
composition of functions.

**Merging is idempotent.** Merge a record with *itself* and nothing happens:
`glue f f = f`. Doing the operation twice is the same as doing it once. This is
the fingerprint of an operation that is about *combining information* rather than
*accumulating quantity* — you cannot learn anything new by overlaying a record on
a perfect copy of itself.

**The left-regular band laws.** This is where the structure becomes genuinely
special. The merge satisfies two further identities:

```
glue (glue f g) f = glue f g        and        glue f (glue g f) = glue f g.
```

Read the first one aloud: after you have overlaid `f` on top of `g`, overlaying
`f` *again* changes nothing. The result already "remembers" that `f` had the
first word everywhere it spoke. An idempotent monoid that obeys these laws is
called, in the algebra literature, a **left-regular band**. Bands are the natural
home of operations that *record priority* — they show up in the theory of
hyperplane arrangements, in random-walk mixing times, and in the combinatorics of
voting. The discovery here is that the most mundane data-cleaning step you can
imagine — "merge these two records, first one wins" — is secretly a left-regular
band. Merging is not arithmetic; it is a logic of precedence.

A small caution that the mathematics insists on: this merge is **not
commutative**. `glue f g` and `glue g f` can differ, because they disagree about
who wins in a contested cell. That is exactly right — when two sources conflict,
the order in which you trust them matters. The band laws are the precise
accounting of that fact.

## The real question: can the blanks be filled at all?

Laws about a single merge are pretty. But the operational question is the one a
data engineer actually asks: *given a whole pile of partial records, is there a
single consistent record that completes all of them at once?* In the language
above: does there exist a row that **extends** every record in the family? When
such a row exists, we say the family **has a global section** — a consistent
fill-in.

You might fear that answering this requires checking the entire combinatorial
explosion of ways the records could interact. The central theorem says
otherwise, and it is the heart of the whole story:

> **A family of records can be consistently completed if and only if it is
> *pairwise* compatible** — that is, if and only if every *two* records agree
> wherever they both have values.

Read that again, because it is genuinely surprising. To know that *all* of your
records can be reconciled into one global truth, you do **not** need to examine
the family as a whole. You only need to check the records two at a time. Local
agreement, checked pair by pair, automatically forces global consistency. There
are no hidden three-way or seventeen-way conflicts that pairwise checking can
miss. This is precisely the **gluing axiom** of sheaf theory, stripped of all its
topological clothing and stated for databases.

And the construction is explicit, not just an existence promise. When the records
are pairwise compatible, you build the global completion by the obvious greedy
rule — for each column, take a value from any record that happens to have one.
The theorems guarantee this merged record genuinely extends every member of the
family.

## And the answer is unique — with one honest caveat

Existence is half the prize. The other half is **uniqueness**: is the filled-in
record *the* answer, or merely *an* answer? Here the mathematics is scrupulously
honest. The completion is unique — provided you demand the natural minimality
condition that **the completion invents no cells beyond those that some record
actually mentioned**. Formally: among all consistent completions whose support
lies inside the union of the records' supports, there is exactly one, and it is
the greedy merge.

The caveat is not a technicality to be embarrassed about; it is the moral of the
story. If you allow yourself to scribble extra values into columns that *no*
record ever filled, of course you can produce infinitely many "completions" —
you are just making things up. Honest imputation fills only the cells the data
collectively speaks to, and on that domain the answer is forced, unique, and
canonical. There is a companion principle, called **locality**, that pins this
down from the other side: if two completions each extend the other, they are
literally equal. A consistent record is completely determined by what it says on
each cell — nothing is hidden.

## A worked miniature

Picture three lab technicians measuring the same three samples for three assays,
but each technician was lazy in a different way.

- Tech A recorded: sample-1 = 7, sample-2 = blank, sample-3 = 2.
- Tech B recorded: sample-1 = blank, sample-2 = 5, sample-3 = 2.
- Tech C recorded: sample-1 = 7, sample-2 = 5, sample-3 = blank.

Check them pairwise. A and B overlap only on sample-3, where both say 2 — fine. A
and C overlap on sample-1 (both 7) — fine. B and C overlap on sample-2 (both 5) —
fine. Every pair agrees on its overlap, so the family is pairwise compatible. The
theorem now *guarantees*, without any further checking, that a single consistent
record exists, and the greedy merge produces it: sample-1 = 7, sample-2 = 5,
sample-3 = 2. No technician alone knew all three values; together, and only
because they never contradicted one another, they reconstruct the full truth.

Now corrupt one entry: let Tech C report sample-1 = 9 instead of 7. Suddenly A
and C disagree on sample-1 (7 versus 9). The family is no longer pairwise
compatible — and the theorem tells us, instantly, that *no* global completion can
exist. The single broken pair is a complete certificate of global failure. You do
not need to hunt; the conflict announces itself locally.

## Why this matters, and the probabilistic twist

The reframing pays off in two currencies. First, *diagnosis*: when imputation is
impossible, the obstruction is a concrete, locatable disagreement between two
records — a pair of cells you can point at, fix, or flag. Methods that quietly
average the blanks away never tell you this; they paper over contradictions
instead of reporting them.

Second, *prediction*. If you model a large database as throwing down many
overlapping local constraints, and each overlapping constraint is independently
satisfied with probability `1 - r` (where `r` is the missingness/corruption
rate), then the probability that the *whole* database glues into a single
consistent global record is

```
P(consistent) = (1 - r) ^ N,
```

where `N` is the number of overlapping constraints. For a table with `n` columns
and `k` rows the number of overlaps grows combinatorially, so feasibility decays
*exponentially* in the size of the table. This is presented here as a model and a
conjecture rather than a finished theorem — but it makes a sharp, falsifiable
prediction: consistent imputation has a cliff. Below some critical corruption
rate it almost always succeeds; above it, almost never. The richer the table (the
more overlapping constraints), the sharper the cliff. Exactly *because* a sheaf
imposes exponentially many consistency constraints, it extracts more signal than
mean- or neighbor-based imputation when data is plentiful and clean — and it
fails loudly, rather than silently, when data is too corrupt to trust.

## The takeaway

Strip away the vocabulary and the message is simple and a little wonderful. The
dull operation of merging incomplete records obeys exact algebraic laws — it is a
left-regular band with the empty record as its unit. The question of whether
records can be consistently combined has a clean local answer — pairwise
agreement is necessary *and sufficient*. And when a completion exists, it is
unique on the cells the data actually mentions. Filling in the blanks, done
honestly, is not guesswork. It is sheaf theory, hiding in plain sight inside
every spreadsheet you have ever opened.
