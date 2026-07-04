# Seating the Newlyweds: A Perfect Schedule for Every Round Table

## A very old puzzle in a fresh dress

Imagine you are organizing a week-long mathematics workshop at a remote
retreat. Every evening the participants gather for dinner, and every evening
you must seat them around a fixed collection of round tables. You would like
the schedule to be *fair*: over the course of the workshop, every participant
should sit next to every other participant exactly once. No repeated
neighbours, nobody left out.

This is the celebrated **Oberwolfach problem**, named after the German
research institute where it was first posed in 1967. It is deceptively simple
to state and famously hard to solve in full generality. Ask a room of
combinatorialists whether it is solved, and you will get a careful "almost."

Now add a human complication that any real dinner organizer will recognize.
Some of the guests arrive as **couples** — and not just any couples, but
*newlyweds* who insist on sitting side by side at every single meal. The
challenge is now doubled. You must still arrange for every pair of
*non-spouses* to be neighbours exactly once, but you must do so while keeping
each couple glued together, night after night.

This is the **Honeymoon Oberwolfach problem**. It is charming, it is
surprisingly deep, and — in the generalized form we describe here — it turns
out to have a clean and complete answer.

## The setup, precisely

Let us fix the vocabulary. There are $n$ newlywed couples, so $2n$ people in
all. Each night these $2n$ people are distributed among a prescribed list of
tables:

- $s$ **small tables**, each seating a single couple (two people); and
- $t$ **round tables**, of sizes $2m_1, 2m_2, \dots, 2m_t$.

Because every person sits somewhere every night, the sizes must add up:
$$ n = s + m_1 + m_2 + \dots + m_t. $$

Two rules govern a valid schedule.

1. **Togetherness.** Every couple sits together at every meal. (At a small
   table this is automatic; at a round table it means the two spouses occupy
   adjacent seats.)
2. **Fairness.** Every pair of people who are *not* married to each other are
   seated as immediate neighbours around some round table **exactly once**
   over the entire schedule.

The question is the obvious one: for which lists of table sizes
$(s; m_1, \dots, m_t)$ does such a schedule exist?

## The obvious obstructions

Before hunting for a construction, a good mathematician asks what could
possibly go wrong. Two constraints leap out.

First, a round table must be big enough to *have* neighbours: a table of size
$2m_i$ only makes sense as a place to meet new people if $m_i \ge 2$. (A round
"table" of size $2$ is just a couple sitting alone, which is what the small
tables are for.)

Second — and this is the heart of the matter — there is a **counting
constraint**. Consider one round table of size $2m_i$ on a single night.
Around it, each of the $2m_i$ seats has two neighbours, so the table
contributes $2m_i$ adjacent pairs that night. Across the whole schedule these
pairs must tile, without repetition, the set of all non-spouse pairs. The
number of non-spouse pairs among $2n$ people is
$$ \binom{2n}{2} - n = 2n(n-1), $$
because there are $\binom{2n}{2}$ pairs in total and exactly $n$ of them are
married couples. Tracking how a single table of size $2m_i$ chips away at this
budget forces
$$ m_i \mid 2n(n-1). $$

So we arrive at two **obvious necessary conditions**:
$$ m_i \ge 2 \quad\text{and}\quad m_i \mid 2n(n-1) \quad \text{for every } i. $$

The natural conjecture — and the result at the centre of this article — is
that *these obvious conditions are also sufficient*. Nothing hidden is
lurking. If the arithmetic permits a schedule, a schedule exists.

**Main Theorem.** *Let $s \ge 0$ be an integer and let $m_1, \dots, m_t$ be
integers each at least $2$. Set $n = s + m_1 + \dots + m_t$. If $m_i \mid
2n(n-1)$ for every $i$, then there is a valid honeymoon seating schedule for
the $2n$ participants at $s$ couple-tables and $t$ round tables of sizes
$2m_1, \dots, 2m_t$.*

## From a whole week to a single night

How does one build such a schedule? The elegant idea, common to this entire
family of problems, is to **build one perfect night and then spin it**.

Picture the $2n$ guests standing on the rim of a giant wheel, labelled by the
residues $0, 1, 2, \dots$ modulo a suitable number. A single night's seating
plan can be described as a pattern of who-sits-next-to-whom. If we choose that
first night cleverly and then, on each successive night, **rotate every guest
one notch around the wheel**, the neighbour-pairs sweep around like the hands
of a clock. The divisibility condition $m_i \mid 2n(n-1)$ is precisely what
guarantees that, as the pattern rotates, every non-spouse pair is visited once
and only once — the rotations partition the full pair-budget into equal,
non-overlapping slices. This is the classical technique of **cyclic
development**, and the divisibility condition is exactly its admission ticket.

Everything, then, reduces to describing the **first night** as a mathematical
object and proving it has the right structure. That object is a **graph**.

## The graph of a single night

Represent each of the $2n$ seats by a vertex. Draw an edge between two vertices
whenever the corresponding people are *relevant neighbours* on that night —
that is, either they are a married couple sharing a seat-pair, or they are
non-spouses sitting immediately side by side at a round table. The couples and
the round-table adjacencies together form a graph $G$ on $2n$ vertices, and the
whole problem becomes a statement about the structure of $G$.

Here is the beautiful part. We can write $G$ down explicitly.

**The couples.** Introduce a map $\mathrm{partner}$ that sends each person to
their spouse. It is an **involution** — applying it twice returns you to where
you started — and it is **fixed-point-free**, because nobody is married to
themselves. The $n$ couples are exactly the $n$ two-element edges of this
matching, the $n$ disjoint "$K_2$"s.

**The round tables.** Seat round table $i$ by placing its $2m_i$ people at the
residues $0, 1, \dots, 2m_i - 1$ around a cycle. The *successor* map sends seat
$a$ to seat $a+1$ (its clockwise neighbour). This produces, for each table, a
cycle of length $2m_i$ — the round-table adjacencies.

**The clever twist: antipodal spouses.** Where do the couples live inside the
round tables? At the **antipodes**. Two people at a round table of size $2m_i$
are married exactly when their seats are diametrically opposite, i.e. seat $a$
is married to seat $a + m_i$. Because $m_i + m_i = 2m_i \equiv 0$, applying the
antipodal map twice is the identity — the involution property holds — and no
seat is its own antipode, so no one is married to a neighbour of themselves.

Now assemble $G$: its edges are the successor edges of the cycles (round-table
adjacencies) *together with* the antipodal chords (the couples). This single
graph encodes one perfect night.

## What the construction guarantees

Three structural facts make this construction exactly right, and each can be
verified directly.

**Fact 1 — couples are genuine edges, and never trivial.** Every person is
joined to their spouse in $G$, and no person is their own spouse. The couple
matching is a fixed-point-free perfect matching sitting inside $G$.

**Fact 2 — deleting the couples leaves the tables.** This is the crucial
decomposition. If you erase the $n$ antipodal chords (the couples) from $G$,
what remains is precisely the $t$ round-table cycles — vertex-disjoint cycles
of lengths $2m_1, \dots, 2m_t$, and nothing else. Formally, an edge $\{u,v\}$
of $G$ is a *non-couple* edge if and only if $u$ and $v$ are cyclic neighbours
$\{a, a+1\}$ at some common round table. The round-table adjacencies and the
couple chords partition the edges of $G$ cleanly, with no accidental overlaps
and no leftover edges. This is the "cycle decomposition of the non-couple
edges," and it is proved constructively — we exhibit the cycles, we do not
merely assert they exist.

**Fact 3 — the graph is cubic (when there are no small tables).** Count the
neighbours of a round-table seat $a$: its clockwise neighbour $a+1$, its
counter-clockwise neighbour $a-1$, and its antipodal spouse $a+m_i$. That is
three neighbours — **degree three**. A round table of size $2m_i \ge 4$ never
makes any of these coincide, so every round-table vertex has degree exactly
three. When $s = 0$ (no small tables), *every* vertex is a round-table seat,
and $G$ is a genuine **cubic graph**: a $3$-regular graph on $2n$ vertices
whose edges split into a perfect matching (the couples) plus a disjoint union
of even cycles (the tables). A seat at a small table, by contrast, has just one
neighbour — its spouse — so it has degree one.

This cubic-graph picture is the geometric skeleton of the whole problem: a
$3$-regular graph on $2n$ vertices in which the edges of $n$ disjoint $K_2$'s
represent couples, and the remaining edges form disjoint cycles of the exact
prescribed even lengths. Building it is the substantive combinatorial core.

## The balance law

There is a slogan that captures why the divisibility condition is *the* right
condition. Count, over the whole schedule, the total number of "adjacency
slots" that get used. On any one night, the round tables together supply
$$ 2m_1 + 2m_2 + \dots + 2m_t $$
adjacent pairs — each seat contributes exactly two neighbours, and summing over
all $2\sum m_i$ round-table seats and dividing by two (each pair counted twice)
gives $\sum m_i$ pairs... but counting *directed* neighbour-slots gives the
cleaner statement. Over $N$ nights, these must exactly account for the
$2n(n-1)$ non-spouse pairs, twice over in the directed count, yielding the
**adjacency balance law**
$$ N \cdot \sum_{i=1}^{t} m_i = 2n(n-1). $$

This single equation does two jobs at once. It *pins down the number of nights*
$N = \dfrac{2n(n-1)}{\sum_i m_i}$, and it exposes $\sum_i m_i$ as the sole
controlling parameter of the schedule. The condition $m_i \mid 2n(n-1)$ is the
per-table shadow of this global law, and once it holds the cyclic development
described above snaps everything into place.

(The closely related *same-table* variant, in which "sitting together" means
merely sharing a table rather than being adjacent, obeys the analogous law
$N \cdot \sum_i m_i(m_i - 1) = n(n-1)$, with the quadratic gap $m_i(m_i-1)$
replacing the linear $m_i$. The linear adjacency version is the one solved
here.)

## Why this is satisfying

Problems about scheduling and fairness have a way of hiding nasty surprises:
constructions that work for small cases but fail sporadically, obstructions
that appear only for special sizes, exceptions that resist every pattern. The
Honeymoon Oberwolfach problem with multiple round tables could easily have been
one of these. The delight of the result is that it is *not*. The two conditions
that any schoolchild could spot — tables must be large enough, and the
arithmetic must divide — are the *only* conditions. There is no hidden
obstruction, no exceptional list of table sizes that spoils the pattern.

The proof reflects this honesty. It does not appeal to some vast external
machine; it hands you the seating chart. The couples are the antipodal chords
of explicit cycles. Delete them and the tables fall out. Rotate the wheel and
the weeks unfold. It is the kind of argument you could, with patience, act out
with a deck of place-cards.

## Beyond the honeymoon

The circle of ideas here reaches well past wedding receptions. Cyclic
constructions of this flavour are the engine behind **round-robin tournament
scheduling** (who plays whom, and when), **experimental design** (which
treatments to compare in which trials), and **network design** (laying out
fault-tolerant communication rings). The requirement that certain pairs stay
together while all others meet exactly once is a template that recurs whenever
you must balance *constraints* against *coverage*.

And the story is not over. If one demands only that couples *share a table*
rather than sit adjacent, the controlling quantity becomes the quadratic
$\sum_i m_i(m_i - 1)$, and a tantalizing conjecture asserts that divisibility is
again the *only* obstruction. Counting the admissible table-profiles for a
fixed $n$ turns into a purely number-theoretic question about writing divisors
of $n(n-1)$ as sums of "triangular gaps" $m(m-1)$. The humble dinner seating,
it turns out, is a doorway into arithmetic.

For now, the newlyweds can relax. Whatever the arithmetic allows, a perfect
week of dinners is waiting to be arranged — and we can hand them the plan.
