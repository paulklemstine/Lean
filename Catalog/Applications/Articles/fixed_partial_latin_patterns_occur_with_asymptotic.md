# Every Symbol Gets a Fair Turn: The Hidden Democracy of Latin Squares

## A puzzle older than Sudoku

Long before Sudoku booklets appeared at supermarket checkouts, mathematicians
were fascinated by a humble grid. Take an $n \times n$ board. Fill each cell with
one of $n$ symbols — say the numbers $1, 2, \dots, n$ — so that **every row uses
each symbol exactly once** and **every column uses each symbol exactly once**.
That's it. The result is called a *Latin square* of order $n$, a name we owe to
Leonhard Euler, who liked to use Latin letters for the entries.

Here is one of order $4$:

$$
\begin{array}{|c|c|c|c|}
\hline
1 & 2 & 3 & 4\\\hline
2 & 1 & 4 & 3\\\hline
3 & 4 & 1 & 2\\\hline
4 & 3 & 2 & 1\\\hline
\end{array}
$$

Check it: scan any row, you'll see $1,2,3,4$ in some order; scan any column, the
same. Sudoku is just a Latin square of order $9$ with extra box constraints, so
you have already met these objects without knowing their pedigree.

Latin squares look like toys, but they are workhorses. They are the mathematical
skeleton of *experimental design* — the way agronomists lay out crop trials so
that no fertilizer is accidentally favored by sunnier rows, the way statisticians
balance treatments in clinical studies, the way engineers schedule tournaments so
every team plays every other. They underpin error-correcting codes and certain
cryptographic gadgets. And they are gloriously, ferociously numerous: there is
exactly $1$ Latin square of order $1$, $2$ of order $2$, $12$ of order $3$,
$576$ of order $4$, $161{,}280$ of order $5$, and then the counts explode beyond
all hope of listing — the number of order-$11$ Latin squares already has $52$
digits.

This article is about a deceptively simple question hiding inside that explosion,
and a clean, exact answer to it.

## The question: what does a *random* Latin square look like?

Imagine you could write down all $161{,}280$ Latin squares of order $5$ on slips
of paper, drop them in an enormous hat, and pull one out blindly. Now stare at the
top-left cell. What is the probability that it contains the symbol $3$?

Intuition whispers "one in five," and intuition is exactly right. But *why*?
There is no obvious reason a corner cell should treat all symbols even-handedly.
The constraints of a Latin square are global and tangled: changing one entry can
force a cascade of changes elsewhere to keep every row and column legal. It is not
at all clear, a priori, that the symbol $3$ is no more and no less likely to land
in the corner than the symbol $1$.

The main result we will explain says that the even-handedness is real, and it is
*exact* — not approximately one-in-$n$, not one-in-$n$ "in the limit of large
boards," but precisely $1/n$ for every order $n$ and every cell.

> **Main theorem (exact one-cell uniformity).**
> Fix any cell $(r,c)$ and any symbol $s$ in a board of order $n$. Among all
> Latin squares of order $n$, the fraction whose entry in cell $(r,c)$ equals $s$
> is *exactly* $1/n$.

Equivalently, and this is the form that makes the proof sing: if $N$ is the total
number of Latin squares of order $n$, then the number of them with symbol $s$ in
cell $(r,c)$ is exactly $N/n$. Or, avoiding division entirely,

$$
N \;=\; n \cdot \bigl(\text{number of Latin squares with } s \text{ in cell } (r,c)\bigr).
$$

Every symbol gets a perfectly fair turn in every seat. The corner is a democracy.

## Why this is not obvious — and the trick that cracks it

When you want to show two collections are the same size, the cleanest possible
argument is a *perfect pairing*: a rule that matches each member of the first
collection with exactly one member of the second, and vice versa, leaving nobody
out and nobody double-counted. If such a pairing exists, the two collections must
have the same number of elements — you never even have to count.

So consider two piles of Latin squares:

- **Pile $S$:** all order-$n$ Latin squares with symbol $s$ sitting in cell $(r,c)$.
- **Pile $T$:** all order-$n$ Latin squares with a *different* symbol $t$ sitting in cell $(r,c)$.

We want to show these two piles are equal in size. The pairing is a beautifully
simple operation we'll call the **swap trick**.

Take any square in pile $S$. Walk through the entire grid and, everywhere you see
the symbol $s$, write $t$ instead; everywhere you see $t$, write $s$. Leave all
other symbols untouched. This is just *renaming two of the symbols throughout the
square* — like deciding that what you used to call "red" you'll now call "blue"
and vice versa, across the whole picture at once.

Three things make this trick work:

1. **The result is still a Latin square.** Renaming symbols can never create a
   repeat in a row or column, because it just shuffles names; if every row was a
   rainbow of distinct colors before, it still is after you rename two of the
   colors. (In the formal development this is exactly the statement that a
   relabelling preserves row and column injectivity.)

2. **It lands you in the right pile.** The square you started with had $s$ in cell
   $(r,c)$. After swapping the names $s$ and $t$ everywhere, that very cell now
   reads $t$. So you've moved from pile $S$ to pile $T$.

3. **It undoes itself.** Apply the same name-swap a second time and the two
   renames cancel — $s$ becomes $t$ becomes $s$ again — returning you to exactly
   the square you began with. An operation that is its own inverse is automatically
   a perfect pairing.

That third point is the secret. Because swapping the names $s$ and $t$ twice is
the same as doing nothing, the swap trick pairs up pile $S$ and pile $T$ flawlessly.
Therefore the two piles have **the same size**.

Now the punchline is just bookkeeping. The symbol $t$ was arbitrary: by the same
argument, the pile for symbol $1$, the pile for symbol $2$, …, the pile for symbol
$n$ all have the *same* size. And every Latin square belongs to exactly one of
these $n$ piles — the pile named by whatever symbol happens to sit in cell $(r,c)$.
So the total $N$ splits into $n$ equal heaps:

$$
N \;=\; \underbrace{(\text{size of one pile}) + \cdots + (\text{size of one pile})}_{n \text{ equal terms}} \;=\; n \cdot (\text{size of one pile}).
$$

Rearranged, each pile has size $N/n$, and the probability of seeing any chosen
symbol in any chosen cell is exactly $1/n$. The democracy is proved.

## The quiet hero: symmetry by relabelling

It's worth pausing on what really did the work here, because the same idea echoes
all across mathematics. The swap was a special case of a much broader move:
**relabelling the symbols** of a Latin square by any rule that doesn't collide —
any *permutation* of the symbol set. If $\sigma$ is such a relabelling, you get a
new Latin square by replacing every entry $x$ with $\sigma(x)$. These relabellings
compose like the steps of a dance (do one, then another, and the combined effect
is itself a relabelling), and doing nothing is itself a relabelling. In the
language of algebra, the relabellings *act* on the set of all Latin squares.

What the swap trick exploited is that this action is rich enough to send any
symbol to any other symbol while keeping everything legal. Whenever a symmetry can
carry "configuration A" to "configuration B," the two configurations must occur
equally often in a uniformly random object. The fairness of the corner cell is not
a numerical coincidence; it is the shadow of a symmetry. This single principle —
*equal symmetry implies equal probability* — is one of the most reliable tools in
all of combinatorics and probability, and Latin squares display it in pure form.

## A small example you can check by hand

Return to order $3$, where there are exactly $12$ Latin squares. Our theorem
predicts that the number with, say, symbol $1$ in the top-left corner should be
$12 / 3 = 4$. Let's verify by listing them. Write each square by its rows. The
four order-$3$ Latin squares with a $1$ in the top-left are:

$$
\begin{array}{ccc}
\begin{array}{|c|c|c|}\hline 1&2&3\\\hline 2&3&1\\\hline 3&1&2\\\hline\end{array}
&\quad&
\begin{array}{|c|c|c|}\hline 1&2&3\\\hline 3&1&2\\\hline 2&3&1\\\hline\end{array}
\end{array}
$$
$$
\begin{array}{ccc}
\begin{array}{|c|c|c|}\hline 1&3&2\\\hline 2&1&3\\\hline 3&2&1\\\hline\end{array}
&\quad&
\begin{array}{|c|c|c|}\hline 1&3&2\\\hline 3&2&1\\\hline 2&1&3\\\hline\end{array}
\end{array}
$$

Exactly four — just as predicted. By symmetry, there are four with a $2$ in the
corner and four with a $3$, and $4+4+4 = 12$. The arithmetic closes perfectly, and
the swap trick explains *why* it had to.

## Where the story is heading

The corner-cell result is the first rung of a taller ladder. The motivating
conjecture behind this line of work concerns not one cell but a whole *partial
pattern*: a handful of pre-filled entries — say, "a $5$ in row $2$, column $7$,
and a $3$ in row $4$, column $1$" — that you might hope to find embedded in a
random Latin square. The expectation, long believed and supported by simulation,
is that a fixed legal pattern of $k$ entries appears in a uniformly random
order-$n$ Latin square with probability that shrinks like $n^{-k}$ as the board
grows: each entry you pin down costs you, roughly, a factor of $n$ in rarity, and
the entries behave nearly independently when $n$ is large.

The theorem proved here nails the case $k = 1$ — and nails it not just
asymptotically but *on the nose*, for every single $n$. A single pinned entry
occurs with probability exactly $n^{-1}$. The natural next steps, already mapped
out, are to extend the same swap-and-pair machinery: first to several prescribed
symbols within one row (where relabelling still suffices and the count becomes the
falling product $n(n-1)\cdots(n-k+1)$ in the denominator), then to general small
patterns classified by the full symmetry group of Latin squares — rows,
columns, *and* symbols all permutable at once. Each rung uses the same quiet hero:
a symmetry that carries one configuration to another and so forces them to be
equally common.

There is a final, satisfying twist. The corner-cell argument turns out to be a
special case of a completely general statement about *any* finite symmetry acting
on *any* finite collection: if a group of symmetries can shuttle a labelling
function around transitively — reaching every possible label — then all the
labels occur equally often, and the total count factors as
(number of labels) $\times$ (size of one fiber). Latin squares gave us a concrete,
visual, hand-checkable instance of a principle that, once isolated, pays for
itself everywhere from card shuffling to statistical mechanics.

## Takeaways

- A **Latin square** of order $n$ is an $n \times n$ grid filled with $n$ symbols
  so that no symbol repeats in any row or any column. Sudoku is a decorated
  example.
- These objects are finite in number but astronomically many, which makes their
  *statistical* behavior — what a random one looks like — a genuine question.
- The **exact one-cell uniformity theorem** says each symbol occupies each cell in
  precisely a $1/n$ fraction of all Latin squares: $N = n \cdot (\text{count with } s \text{ in cell } (r,c))$.
- The proof is a single elegant idea: **swapping the names of two symbols** is its
  own inverse, so it perfectly pairs the squares favoring one symbol with those
  favoring another — proving the piles equal without ever counting them.
- This is the verified base case of a grander conjecture that *any* fixed legal
  pattern of $k$ entries appears with probability $\sim n^{-k}$, and a first
  glimpse of a unifying theme: **symmetry dictates probability.**

The next time you idly fill in a Sudoku grid, remember that you are wandering
through one of the largest, most symmetric, and most fair-minded landscapes in all
of mathematics — one where, in the long run, everybody gets a turn.
