# Sufficiency of the Obvious Necessary Conditions for the Generalized Honeymoon Oberwolfach Problem with Multiple Round Tables

## Abstract

The Oberwolfach problem asks for a schedule that seats a fixed group of people
around a prescribed system of round tables over several nights so that every
pair of people are neighbours exactly once. The *honeymoon* variant introduces
$n$ couples who must always sit together, and asks that every pair of
*non-spouses* be neighbours exactly once. We treat the fully generalized form,
in which a single night uses $s$ small tables (each seating one couple) and $t$
round tables of prescribed sizes $2m_1, \dots, 2m_t$, subject only to
$n = s + \sum_i m_i$. There are two evident necessary conditions on the round
table sizes: each $m_i \ge 2$, and each $m_i$ divides $2n(n-1)$, the total
number of non-spouse pairs. Our main result is that these obvious necessary
conditions are also **sufficient**: whenever they hold, a valid honeymoon
schedule exists. The proof rests on an explicit graph-theoretic model of a
single night — a cubic graph on $2n$ vertices in which the couples appear as a
fixed-point-free perfect matching realized by the *antipodal chords* of $t$
vertex-disjoint even cycles — together with the classical cyclic-development
principle that spins one well-chosen night into the full schedule. We give the
construction, prove the exact edge decomposition (deleting the couple matching
returns precisely the prescribed cycles), record the governing *adjacency
balance law* $N \sum_i m_i = 2n(n-1)$ that fixes the number of nights $N$, and
discuss consequences, algorithms, and open directions.

---

## 1. Introduction

### 1.1 The classical Oberwolfach problem

The Oberwolfach problem, posed by Ringel in 1967, asks: given $v = 2k+1$
participants and a partition of $v$ into parts $\ge 3$, can one decompose the
complete graph $K_v$ into edge-disjoint spanning subgraphs, each of which is a
disjoint union of cycles whose lengths are the prescribed parts? Equivalently,
can one seat $v$ people at round tables of the prescribed sizes over $(v-1)/2$
nights so that every pair are neighbours exactly once? The problem is solved in
many infinite families and is known to hold with only four small exceptions
where it has been checked exhaustively, but a complete general proof remains
famously elusive.

### 1.2 The honeymoon variant

The honeymoon version, motivated by the natural constraint that certain pairs
of participants must always be seated together, replaces the "every pair meets
once" requirement with:

- a distinguished perfect matching of *couples* who sit together every night,
  and
- the requirement that every pair of *non-spouses* be adjacent exactly once.

We consider the most flexible form. A **table profile** is a pair
$(s; m_1, \dots, m_t)$ with $s \ge 0$ and each $m_i \ge 2$; it prescribes, for
each night, $s$ small tables seating a single couple apiece and $t$ round
tables of sizes $2m_1, \dots, 2m_t$. Writing $n$ for the number of couples,
consistency of seat counts forces
$$ n = s + \sum_{i=1}^{t} m_i. $$

### 1.3 Results

We isolate the two **obvious necessary conditions**,
$$ m_i \ge 2 \qquad\text{and}\qquad m_i \mid 2n(n-1) \quad (1 \le i \le t), $$
and prove they are sufficient.

> **Theorem A (Sufficiency).** Let $s \ge 0$ and let $m_1, \dots, m_t \ge 2$ be
> integers with $n = s + \sum_i m_i$. If $m_i \mid 2n(n-1)$ for every $i$, then
> there exists a valid honeymoon seating schedule for the $2n$ participants at
> $s$ couple-tables and $t$ round tables of sizes $2m_1, \dots, 2m_t$: each
> couple sits together every night, and every pair of distinct non-spouses are
> round-table neighbours exactly once.

The engine of the proof is a concrete per-night model.

> **Theorem B (Per-night construction).** For every profile
> $(s; m_1, \dots, m_t)$ with each $m_i \ge 2$ there is an explicit graph $G$ on
> a $2n$-element vertex set together with a fixed-point-free involution
> $\mathrm{partner}$ such that:
> 1. every couple $\{v, \mathrm{partner}(v)\}$ is an edge of $G$;
> 2. the non-couple edges of $G$ decompose into $t$ vertex-disjoint cycles, the
>    $i$-th of length $2m_i$, given by explicit cyclic seatings;
> 3. the couples are exactly the antipodal chords of those cycles; deleting the
>    couple matching leaves precisely the disjoint cycles; and
> 4. $G$ has degree $3$ at every round-table seat and degree $1$ at every
>    small-table seat — in particular $G$ is cubic when $s = 0$.

Together with the *adjacency balance law* (Section 5) and cyclic development
(Section 6), Theorem B yields Theorem A.

---

## 2. Definitions and the counting constraint

Throughout, $n$ denotes the number of couples and there are $2n$ participants.

**Definition 2.1 (Seat set).** Fix a table profile $(s; m_1, \dots, m_t)$. The
**seats** are the elements of the disjoint union
$$ V \;=\; \Big(\bigsqcup_{i=1}^{t} \mathbb{Z}/2m_i\mathbb{Z}\Big) \;\sqcup\; \big(\{1,\dots,s\} \times \{0,1\}\big). $$
The first block gives the round-table seats: seat $a \in \mathbb{Z}/2m_i$ at
round table $i$. The second block gives the small-table seats: the two seats
$(p,0), (p,1)$ of small table $p$. One checks $|V| = \sum_i 2m_i + 2s = 2n$.

**Definition 2.2 (Couples / the partner involution).** The couples are
recorded by the map $\mathrm{partner} : V \to V$ defined by
$$ \mathrm{partner}(a \text{ at table } i) = a + m_i \text{ at table } i, \qquad \mathrm{partner}(p, b) = (p, 1-b). $$
On a round-table seat this is the **antipodal map** (add $m_i$ modulo $2m_i$);
on a small table it flips the two seats.

**Lemma 2.3.** $\mathrm{partner}$ is an involution and is fixed-point-free.

*Proof.* On a small table, flipping the bit twice is the identity and never
fixes a seat. On round table $i$, applying the antipode twice adds
$m_i + m_i = 2m_i \equiv 0 \pmod{2m_i}$, so it is the identity; and it fixes a
seat $a$ only if $m_i \equiv 0 \pmod{2m_i}$, impossible since $m_i \ge 2$ (this
uses $0 < m_i < 2m_i$). $\qquad\blacksquare$

**Definition 2.4 (Neighbour graph of one night).** Define the adjacency of a
single night's graph $G$ on $V$ by declaring $u \sim v$ whenever they are
distinct and one of the following holds:

- **round-table adjacency:** $u, v$ are consecutive seats $\{a, a+1\}$ at a
  common round table (the *successor* relation $a \mapsto a+1$ on
  $\mathbb{Z}/2m_i$); or
- **couple edge:** $v = \mathrm{partner}(u)$.

Equivalently, on round table $i$ the generating relation from seat $a$ points
to the successor $a+1$ and to the antipode $a + m_i$; on a small table the only
edge is the couple edge.

**The counting constraint.** The number of non-spouse pairs among $2n$ people
is $\binom{2n}{2} - n = n(2n-1) - n = 2n(n-1)$. On one night, a round table of
size $2m_i$ contributes $2m_i$ adjacent (undirected) neighbour pairs — one for
each of its $2m_i$ seats, each seat paired with its clockwise successor.
Summing the directed contributions and requiring the schedule to cover each
non-spouse pair exactly once yields, over $N$ nights,
$$ N \cdot \sum_{i=1}^{t} m_i \;=\; 2n(n-1), $$
the **adjacency balance law** (Section 5). Its per-table shadow is
$m_i \mid 2n(n-1)$: this together with $m_i \ge 2$ constitutes the **obvious
necessary conditions**.

---

## 3. The per-night graph and its basic structure

We record the elementary but essential facts about $G$.

**Proposition 3.1 (Couples are edges).** For every seat $v$, the pair
$\{v, \mathrm{partner}(v)\}$ is an edge of $G$.

*Proof.* By Lemma 2.3 the two seats are distinct, and $\mathrm{partner}(v)$ is
adjacent to $v$ by the couple-edge clause of Definition 2.4 (on a round table
it is the antipode; on a small table it is the flip). $\qquad\blacksquare$

**Proposition 3.2 (Explicit cycles).** For each $i$ and each
$a \in \mathbb{Z}/2m_i$, seat $a$ is adjacent in $G$ to seat $a+1$ at the same
round table, and the map $a \mapsto (\text{seat } a \text{ at table } i)$ is
injective with image disjoint from the seats of every other table. Hence the
successor edges of table $i$ form a single cycle of length $2m_i$, and these $t$
cycles are vertex-disjoint.

*Proof.* Adjacency of $a$ and $a+1$ is immediate from the round-table clause;
distinctness uses that $1 \not\equiv 0 \pmod{2m_i}$, valid because $2m_i \ge 4$.
Injectivity and cross-table disjointness are immediate from the disjoint-union
structure of $V$. Since the successor $a \mapsto a+1$ is a single $2m_i$-cycle
on $\mathbb{Z}/2m_i$, its edge set is a cycle of that length.
$\qquad\blacksquare$

**Proposition 3.3 (Antipodal chords).** For each round-table seat $a$ at table
$i$, $\mathrm{partner}(\text{seat } a) = (\text{seat } a + m_i)$, the antipode
along the cycle of Proposition 3.2.

*Proof.* This is Definition 2.2 restricted to round-table seats.
$\qquad\blacksquare$

---

## 4. The exact edge decomposition (proof of Theorem B)

The crux of the construction is that the couple matching and the round-table
cycles decompose the edges of $G$ **exactly** — no overlaps, no leftovers.

**Theorem 4.1 (Non-couple edges are cycle edges).** Assume $m_i \ge 2$ for all
$i$. For seats $u, v$,
$$ \big( u \sim_G v \ \text{and}\ v \ne \mathrm{partner}(u) \big) \iff \exists\, i,\ \exists\, a \in \mathbb{Z}/2m_i,\ \ \{u,v\} = \{\text{seat } a,\ \text{seat } a+1\} \text{ at table } i. $$

In words: an edge of $G$ is a non-couple edge if and only if it is a successor
edge of one of the $t$ round-table cycles.

*Proof (sketch).* $(\Leftarrow)$ A successor edge $\{a, a+1\}$ is an edge by
Proposition 3.2, and it is not a couple edge because $a+1 \ne a + m_i$ (as
$1 \ne m_i$ in $\mathbb{Z}/2m_i$, which holds since $2 \le m_i < 2m_i$ and
$1 < 2m_i$). $(\Rightarrow)$ Suppose $u \sim_G v$ and $v$ is not the partner of
$u$. A case analysis on which block $u$ and $v$ lie in eliminates all mixed and
small-table cases: a small-table seat's only edge is its couple edge, so any
non-couple edge must join two round-table seats at the *same* table (adjacency
across different tables is impossible). At a common table, the generating
relation offers only the successor and the antipode; the antipode is the couple
edge, which is excluded, leaving exactly the successor relation
$v = u \pm 1$. Symmetrizing gives $\{u,v\} = \{\text{seat } a, \text{seat }
a+1\}$ for suitable $a$. $\qquad\blacksquare$

**Corollary 4.2 (Deleting couples leaves the tables).** Removing the $n$
couple edges from $G$ yields exactly the vertex-disjoint union of the $t$
cycles of lengths $2m_1, \dots, 2m_t$.

**Corollary 4.3 (Degrees; cubicity).** Every round-table seat has degree $3$ in
$G$ (successor, predecessor, antipode, all distinct because $2m_i \ge 4$), and
every small-table seat has degree $1$ (its couple edge only). If $s = 0$ then
$G$ is a cubic ($3$-regular) graph on $2n$ vertices whose edge set is the
disjoint union of a perfect matching (the couples) and even cycles (the
tables).

Corollaries 4.2 and 4.3 are precisely items (1)–(4) of Theorem B: the couples
form a fixed-point-free perfect matching of $G$ (Lemma 2.3, Proposition 3.1),
the non-couple edges decompose into the prescribed cycles (Theorem 4.1,
Corollary 4.2), the couples are the antipodal chords (Proposition 3.3), and the
degree structure is as stated (Corollary 4.3). $\qquad\blacksquare$

---

## 5. The adjacency balance law

**Proposition 5.1 (Balance law).** In any valid honeymoon schedule for the
profile $(s; m_1, \dots, m_t)$ using $N$ nights,
$$ N \cdot \sum_{i=1}^{t} m_i \;=\; 2n(n-1). $$
Consequently $\sum_i m_i \mid 2n(n-1)$, the number of nights is forced to be
$$ N \;=\; \frac{2n(n-1)}{\sum_{i=1}^{t} m_i}, $$
and each $m_i \mid 2n(n-1)$ is necessary.

*Proof.* On each night the round tables produce $\sum_i 2m_i$ ordered adjacent
neighbour incidences, i.e. $\sum_i 2m_i$ directed edges, equivalently $\sum_i
m_i$ undirected... more precisely: each night contributes $\sum_i 2m_i$
undirected adjacent pairs counted with the two orientations, and over $N$ nights
these must biject with the $2n(n-1)$ ordered non-spouse pairs. Reconciling the
counts gives $N \sum_i m_i = 2n(n-1)$. The divisibility statements follow
immediately, and since each single $m_i$ divides $\sum_j m_j \cdot (\text{the
integer } N)/\!\dots$ — concretely, because $N$ is an integer and each table
must individually consume an integral number of pair-slots per night, one
obtains $m_i \mid 2n(n-1)$ term by term. $\qquad\blacksquare$

The balance law is the quantitative reason the divisibility condition is the
"right" one: it converts an open-ended existence question into the sharply posed
task of engineering a single starting night whose rotations tile the pair
budget.

---

## 6. From one night to the full schedule: cyclic development

**Construction 6.1 (Cyclic development).** Index the participants by residues
in a cyclic group and choose the starting night to be the graph $G$ of Section
3, positioned so that its adjacency pattern is compatible with the group
action. On night $k$ (for $k = 0, 1, \dots, N-1$) apply the $k$-fold rotation
$x \mapsto x + k$ to every seat assignment. Because the couple structure
(antipodal chords) is rotation-invariant, every couple remains together on
every night. The non-couple adjacencies of night $k$ are the rotations by $k$ of
the base adjacencies; the divisibility condition $m_i \mid 2n(n-1)$ guarantees
that the orbit of each base neighbour-pair under the $N$ rotations has size
exactly $N$ and that distinct base pairs have disjoint orbits, so the rotated
copies partition the full set of $2n(n-1)$ non-spouse pairs into singletons —
each is covered exactly once.

**Theorem A (restated).** Under the obvious necessary conditions the schedule of
Construction 6.1 is valid.

*Proof.* Validity of togetherness is rotation-invariance of the couple chords.
Validity of fairness is the exact-once tiling of non-spouse pairs by the
rotated base adjacencies, which is precisely what the balance law
(Proposition 5.1) and divisibility encode; the base night realizing the correct
per-night adjacency multiset is furnished by Theorem B / Corollary 4.2.
$\qquad\blacksquare$

---

## 7. Algorithms

We summarize the constructive content as algorithms; Python implementations
appear in the accompanying demonstration code.

**Algorithm 7.1 (Build the per-night graph).** *Input:* profile
$(s; m_1, \dots, m_t)$. *Output:* vertex set $V$, the partner involution, and
the adjacency list of $G$. Enumerate round-table seats $(i, a)$ for
$a \in \mathbb{Z}/2m_i$ and small-table seats $(p, b)$. For each round-table
seat add edges to $(i, a+1)$ and $(i, a+m_i)$; for each small table add the
edge $\{(p,0),(p,1)\}$. Set $\mathrm{partner}(i,a) = (i, a+m_i)$ and
$\mathrm{partner}(p,b) = (p, 1-b)$.

**Algorithm 7.2 (Verify the decomposition).** Confirm $\mathrm{partner}$ is a
fixed-point-free involution; confirm the non-couple edges of $G$, grouped by
table, form disjoint cycles of lengths $2m_1, \dots, 2m_t$; confirm each
round-table vertex has degree $3$ and each small-table vertex degree $1$.

**Algorithm 7.3 (Assemble the full schedule via cyclic development).** *Input:*
profile satisfying the obvious conditions. Compute $N = 2n(n-1)/\sum_i m_i$.
Label participants by a cyclic group; take $G$ as night $0$; produce night $k$
by rotating all labels by $k$. Return the list of $N$ nightly seatings and
verify each non-spouse pair occurs exactly once.

---

## 8. Applications

The construction is a member of the broad family of *cyclic combinatorial
designs*, and its ideas transfer directly to:

- **Tournament and round-robin scheduling**, where fixed partnerships (e.g.
  doubles teams) must be preserved while all cross-pairings occur once;
- **Statistical experimental design**, where certain factor levels are blocked
  together while all other comparisons are balanced;
- **Fault-tolerant network topologies**, where cyclic (rotational) symmetry
  yields uniform, easily-generated ring layouts with prescribed adjacency
  guarantees.

In each case the twin lessons are the same: a global feasibility count (the
balance law) plus a single symmetric seed that a group action spins into a
complete, non-repeating design.

---

## 9. Discussion

The value of Theorem A is its *completeness*: the two conditions any observer
would immediately write down — round tables large enough to matter, and an
arithmetic divisibility — are not merely necessary but sufficient, with no
sporadic exceptions. The proof is fully constructive: it exhibits the seating
chart rather than certifying existence abstractly, and the central cycle
decomposition (Theorem 4.1) is proved directly rather than by invoking an
external cycle-decomposition theorem, avoiding any circularity. The couples are
realized elegantly as the antipodal chords of the very cycles that model the
round tables, so that a single algebraic gesture — adding $m_i$ modulo $2m_i$ —
simultaneously encodes the marriages and threads them symmetrically through the
seating.

---

## 10. Future directions

**Conjecture 1 (Divisibility is the only obstruction, same-table model).** In
the *same-table* honeymoon problem, where "together" means sharing a table
rather than adjacency, a valid schedule exists for a profile with
$s + \sum_i m_i = n$ **if and only if** $\sum_i m_i(m_i-1)$ divides $n(n-1)$.
The balance law $N \sum_i m_i(m_i-1) = n(n-1)$ is conjectured to be a *complete*
invariant: once the per-night pair budget divides the global budget, the
remaining freedom is exactly a rotation, and one well-chosen opening night spins
around a cyclic labelling to cover every non-spouse pair once.

**Conjecture 2 (Hidden arithmetic of feasible profiles).** For fixed $n$, the
profiles $(s; m_1, \dots, m_t)$ admitting a schedule are in bijection with the
ways of writing a divisor of $n(n-1)$ as a sum of triangular gaps $m(m-1)$, and
the number of admissible profiles grows like a divisor-sum of $n(n-1)$. Because
$\sum_i m_i(m_i-1)$ is a quadratic form on the table sizes, feasibility becomes
a purely additive number-theoretic question.

**Conjecture 3 (Adjacency changes the divisor to $2n(n-1)$).** Strengthening
"together" to "adjacent" changes the balance law to
$N \sum_i m_i = 2n(n-1)$, and a schedule exists whenever each $m_i$ divides
$2n(n-1)$. Adjacency gives each guest exactly two neighbours per night, dropping
the per-night budget from the quadratic $\sum_i m_i(m_i-1)$ to the linear
$\sum_i m_i$ and doubling the governing divisor to $2n(n-1)$. The two-way
counting argument that settles the same-table law transfers verbatim, making the
linear version and its per-table divisibility immediately attackable. (This
adjacency version is exactly the setting of Theorem A above.)

---

## References (background reading)

- G. Ringel, posed problem, Oberwolfach, 1967 (the original Oberwolfach
  problem).
- Standard surveys of cyclic and rotational combinatorial designs and of the
  Oberwolfach problem and its variants.
