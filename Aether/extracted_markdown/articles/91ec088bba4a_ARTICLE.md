# Shuffling Tables Without Breaking the Rules: The Hidden Geometry of Statistical Tests

## A puzzle hidden in a spreadsheet

Imagine a public-health researcher with a simple grid of numbers. The rows are
age groups, the columns are responses to a treatment, and each cell holds a
count: how many 30-somethings recovered, how many 60-somethings did not, and so
on. This humble object — a **contingency table** — is one of the most common
data structures in all of empirical science. Every clinical trial, every survey
crosstab, every A/B test on a website eventually produces one.

The researcher wants to answer a deceptively simple question: *are the rows and
columns independent?* In plain language, does age have nothing to do with
recovery, so that the pattern in the table is just the kind of thing chance would
cough up? Statisticians have a beautiful, exact way to answer this — but it hides
a computational monster, and taming that monster turns out to require a piece of
pure algebra so elegant it feels like cheating.

This article is about that algebra. We will see how the problem of testing
independence becomes a problem about *walking* through an enormous invisible
landscape of tables, and how a single, almost childishly simple "move" — swapping
the corners of a little 2×2 box — is provably enough to reach every reachable
table. That last fact, the **Fundamental Theorem of Markov Bases** for two-way
tables, is the centerpiece. We will state it precisely, and we will sketch why it
is true, because the why is where the beauty lives.

## The exact test and its impossible sum

Suppose your table has *m* rows and *n* columns, and entry `u(i,j)` is the count
in row *i*, column *j*. Two numbers summarize each margin of the table:

- the **row sum** `rowSum(u, i) = Σⱼ u(i,j)` — the total count in row *i*;
- the **column sum** `colSum(u, j) = Σᵢ u(i,j)` — the total count in column *j*.

The deep insight of R. A. Fisher, sharpened over the twentieth century, is this:
when you test independence, the only thing you should treat as "given" about your
data are these margins. The margins are not informative about independence; they
just describe how big each group is. Everything genuinely informative lives in
*how the counts are arranged inside the fixed margins*.

So Fisher's **exact test** says: hold the margins fixed, look at *every other
table with those same margins*, score each one by how "extreme" it looks, and ask
where your observed table falls in that distribution. The set of all non-negative
integer tables sharing a fixed set of row and column sums is called a **fiber**.
The exact test is a calculation over an entire fiber.

Here is the catch. A fiber is astronomically large. For a modest 10×10 table with
moderate counts, the number of tables with the same margins can exceed the number
of atoms in the observable universe. You cannot list them. You cannot sum over
them. The exact test, as literally defined, is computationally hopeless.

## Escape route: don't count, wander

When you cannot enumerate a set but you can *sample* from it, statisticians reach
for a Markov chain Monte Carlo (MCMC) method. The idea is to take a random walk
that drifts around the fiber, visiting tables in proportion to how likely they
are, and to estimate the answer from the places the walk visits. Run the walk
long enough and the fraction of time it spends in "extreme" tables approximates
exactly the p-value Fisher wanted.

But a random walk needs *steps*. What is a legal step from one table to another
inside a fiber? Whatever move we make, it must:

1. **keep every margin fixed** (or we leave the fiber entirely), and
2. **keep every count non-negative** (you cannot have −3 patients).

This is where the algebra enters. We need a repertoire of margin-preserving
moves, and we need to be sure that by chaining them we can reach *every* table in
the fiber. If even one table were unreachable, the random walk would have a blind
spot, and the statistical conclusion drawn from it could be silently wrong.

## The one move to rule them all

It turns out a single family of moves suffices, and it is breathtakingly simple.
Pick two distinct rows *i ≠ i′* and two distinct columns *j ≠ j′*. They mark out
a little 2×2 box with four corners. The **basic move** adds the pattern

```
        col j     col j′
row i     −1        +1
row i′    +1        −1
```

to the table — that is, it subtracts one from two opposite corners and adds one to
the other two. Formally, writing `e(a,b)` for the table that is 1 in cell `(a,b)`
and 0 elsewhere, the basic move is

```
B(i,i′,j,j′) = e(i,j′) + e(i′,j) − e(i,j) − e(i′,j′).
```

Why does this preserve the margins? Look at row *i*: it gains +1 in column *j′*
and loses 1 in column *j*, a net change of zero. Row *i′* does the opposite,
again netting zero. Every other row is untouched. The columns balance for the
same reason. So **adding a basic move changes no row sum and no column sum**. This
is the first theorem we prove rigorously:

> **Margin preservation.** For distinct rows `i ≠ i′` and distinct columns
> `j ≠ j′`, the table `u + B(i,i′,j,j′)` has exactly the same row sums and column
> sums as `u`.

The basic move is the smallest possible margin-preserving perturbation with
integer entries. It is to contingency tables what a single transposition is to
permutations: a minimal, local, reversible twist.

## The real question: is local enough to be global?

Margin preservation is the easy half. The move is *legal*. But legality is not
the same as *sufficiency*. Here is the genuinely hard question, the one that
keeps the whole MCMC program honest:

> Starting from any table in a fiber, can we reach **any other** table in the
> same fiber using only basic moves — never letting a count go negative along the
> way?

If yes, the basic moves form what is called a **Markov basis**: a finite set of
moves that connects every fiber. If no, our random walk is broken. The answer,
proved in full and verified down to the last logical step, is **yes**:

> **Fundamental Theorem of Markov Bases (two-way independence model).**
> Let *u* and *v* be any two non-negative integer tables with identical row sums
> and identical column sums. Then there is a finite sequence of tables
> `u = t₀, t₁, t₂, …, t_N = v`, each non-negative, in which every consecutive
> pair differs by a single basic 2×2 move. In short: the basic moves connect
> every fiber.

This is a special case of a landmark 1998 result of Persi Diaconis and Bernd
Sturmfels, which launched the entire field now called *algebraic statistics*. The
version proved here is the foundational one — the two-way independence model — and
it is established from first principles.

## How the proof works: walk downhill

The strategy is one of the oldest and most satisfying in mathematics: define a
notion of *distance to the goal*, then show you can always take a step that
shrinks it. If distance can always shrink and it can never go below zero, you must
eventually arrive.

The distance here is the **ℓ¹ distance**, the total cell-by-cell disagreement
between two tables:

```
D(u,v) = Σ over all cells (i,j) of  |u(i,j) − v(i,j)|.
```

This is just the number of unit corrections needed to turn *u* into *v*. We prove
the obvious-but-essential fact that `D(u,v) = 0` exactly when `u = v`: if every
absolute difference is zero, the tables are identical.

Now suppose *u* and *v* are different tables in the same fiber. We need to find a
basic move that, applied to *u*, lands strictly closer to *v*. The cleverness is
in *choosing the right 2×2 box*, and it comes from a three-stage application of
the **pigeonhole principle** to the difference table `d = u − v`.

1. **Same margins force balance.** Because *u* and *v* have identical row and
   column sums, the difference table *d* has all row sums zero and all column sums
   zero. In particular the grand total of *d* is zero. Since *u ≠ v*, some cell of
   *d* is nonzero — and because the entries sum to zero, some cell must be
   strictly **positive**. Call it `(i,j)`: there `u` overshoots `v`.

2. **Walk along the row.** Row *i* of *d* sums to zero but has a positive entry at
   *j*, so somewhere else in that same row there must be a strictly **negative**
   entry. Call its column *j′*: there `u` undershoots `v`. Note `j ≠ j′` because
   one cell is positive and the other negative — they cannot be the same cell.

3. **Walk down the column.** Column *j′* of *d* sums to zero but has a negative
   entry at row *i*, so somewhere in that column there is a strictly **positive**
   entry. Call its row *i′*: again `u` overshoots `v`. And `i ≠ i′` for the same
   sign reason.

We have, purely by counting and the balance of the margins, located a 2×2 frame
`(i,i′,j,j′)` whose corners carry the sign pattern

```
v(i,j)  < u(i,j),      u(i,j′) < v(i,j′),      v(i′,j′) < u(i′,j′).
```

This is exactly the situation the basic move was designed for. Apply
`B(i,i′,j,j′)` to *u*. Three of the four touched corners move one step *toward*
*v* (each shaving 1 off the distance), while the fourth corner can drift at most
one step *away*. The net change in `D` is therefore at most −2: a strict decrease.
And because the three decremented corners were all strictly above their target
values in *v* — which are themselves non-negative — subtracting one keeps them
non-negative. The move is legal.

> **Distance decrease.** With the sign-aligned 2×2 frame above, the basic move
> satisfies `D(u + B(i,i′,j,j′), v) < D(u,v)`, and the resulting table is still
> non-negative.

From here the conclusion writes itself by induction on the distance. If *u = v*,
we are already there. Otherwise, take one legal step strictly closer to *v* — the
new table still shares all margins with *v*, since basic moves preserve margins —
and repeat. The distance is a non-negative integer that strictly decreases, so it
must hit zero in finitely many steps. At that moment we have arrived at *v*. The
fiber is connected.

## A walk you can run backward

One more elegant fact rounds out the picture. The reverse of a basic move is
itself a basic move: simply swap the two rows. Concretely,
`B(i′,i,j,j′) = −B(i,i′,j,j′)`, so applying the swapped move exactly undoes the
original. This means every legal step has a legal inverse, and therefore the
relation "reachable by basic moves" is **symmetric** — and, being built as a
reflexive, transitive chain, it is also reflexive and transitive. In other words:

> **Fibers are equivalence classes.** Connectivity by basic moves is an
> equivalence relation. Its classes are precisely the fibers of the independence
> model.

This is exactly the structural guarantee a Markov chain sampler needs. Symmetry
means the walk can go either direction with equal ease (the basis is what
statisticians call a *symmetric* proposal); connectivity means the chain is
*irreducible* on each fiber — it can get from anywhere to anywhere. Irreducibility
is the precise mathematical condition that makes the Monte Carlo estimate of
Fisher's exact p-value provably correct in the long run.

## Why this matters beyond the spreadsheet

The story we have told is not a curiosity. It is the backbone of how exact
conditional inference is actually performed when tables are too big for brute
force. Every time a biostatistician runs an exact test of independence on a
contingency table that is too large to enumerate, they are — knowingly or not —
relying on the fact we proved: that swapping the corners of 2×2 boxes is enough to
roam an entire fiber.

The deeper lesson is about the marriage of two worlds. On one side sits *algebra*:
the basic moves are the generators of a lattice — the kernel of the linear map
that reads off a table's margins. On the other side sits *probability*: a random
walk wandering a fiber to estimate a tail probability. Diaconis and Sturmfels'
great insight was that the algebraic question "what generates the kernel lattice,
and does it connect the non-negative points?" is *the same question* as the
statistical one "is my MCMC sampler irreducible?" The bridge between them is the
distance-reduction argument, the humble idea of always being able to step
downhill.

There is something quietly profound in it. A test invented to detect whether two
qualities of the world are related turns out, when you look underneath, to rest on
a geometric fact about an invisible landscape of grids — a landscape so vast it
cannot be listed, yet so well-connected that the simplest imaginable move can
reach every corner of it. The corners of a 2×2 box, swapped just so, are the keys
to the whole kingdom.

## The results, in one place

For the reader who wants the precise statements, here is the complete logical
skeleton, each piece proved rigorously and machine-checked:

- **Definitions.** A table is a map `u : {1,…,m} × {1,…,n} → ℤ`. Its margins are
  `rowSum(u,i) = Σⱼ u(i,j)` and `colSum(u,j) = Σᵢ u(i,j)`. Two tables have the
  same margins when all row sums and all column sums agree. A table is
  non-negative when every entry is ≥ 0. The basic move is
  `B(i,i′,j,j′) = e(i,j′)+e(i′,j)−e(i,j)−e(i′,j′)`. A legal step adds a basic move
  (with `i ≠ i′`, `j ≠ j′`) between two non-negative tables. Connectivity is the
  reflexive–transitive closure of legal steps. The distance is
  `D(u,v) = Σ |u(i,j) − v(i,j)|`.
- **Margin preservation:** `u` and `u + B(i,i′,j,j′)` have identical margins.
- **Distance is faithful:** `D(u,v) = 0` if and only if `u = v`.
- **Sign-pattern pigeonhole:** distinct equal-margin tables always admit a 2×2
  frame aligned to the sign pattern of their difference.
- **Distance decrease:** the aligned basic move strictly reduces `D(·,v)`.
- **One good step exists:** from any non-negative `u ≠ v` in a fiber there is a
  legal step strictly closer to `v`.
- **Fundamental Theorem:** any two non-negative tables with equal margins are
  connected by a non-negative walk of basic moves.
- **Symmetry:** connectivity is an equivalence relation; fibers are its classes.

Every one of these is a theorem, not a hope. The exact test, once an impossible
sum, becomes a walk you can actually take — guaranteed to reach wherever it needs
to go.
