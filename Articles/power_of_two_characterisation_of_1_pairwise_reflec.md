# When Symmetry Counts Only Powers of Two

## A puzzle hidden in a grid

Imagine a square grid, $n$ rows and $n$ columns, and a box of $n$ different
colored tiles. You want to fill the grid so that every color appears exactly
once in each row and exactly once in each column. Puzzle enthusiasts will
recognize the shape of this challenge instantly: it is the rule behind Sudoku,
and mathematicians have studied it for centuries under the name **Latin
square**. A Latin square of order $n$ is nothing more than an $n \times n$ array
of $n$ symbols in which no symbol repeats within any row or any column.

Latin squares are everywhere. They schedule round-robin tournaments so that no
team plays twice in the same round. They design agricultural field trials so
that every treatment appears once per row and once per column of a plot,
neutralizing hidden soil gradients. They form the backbone of error-correcting
codes and of the mixing steps inside modern encryption. A humble grid of
non-repeating symbols turns out to be one of the most useful objects in applied
combinatorics.

But this article is about a subtler property, one that at first glance seems to
have nothing to do with the size of the grid — and yet, remarkably, pins that
size down to a single, sparse family of numbers: the **powers of two**,
$1, 2, 4, 8, 16, 32, \dots$

## Reading two columns at a time

Pick any two columns of a Latin square and read them side by side, row by row.
Each row then hands you an **ordered pair of symbols** $(p, q)$: the symbol $p$
you see in the first column and the symbol $q$ you see in the second. As you
sweep down all $n$ rows, you collect $n$ such ordered pairs.

Now ask a symmetry question. For a chosen pair of columns and a chosen pair of
symbols, count how many rows show the pair $(p, q)$. Then count how many rows
show the *reversed* pair $(q, p)$. If these two counts are **always equal** — for
every choice of two columns and every choice of two symbols — we say the Latin
square is **pairwise reflection symmetric**, or PRS for short. Reflecting every
symbol pair across the diagonal leaves the tally of pairs completely unchanged.

This is a strong demand. It says the square treats the order of symbols with
perfect impartiality: whatever pattern of pairs the columns produce is mirror
symmetric. A natural refinement makes the object even cleaner. We say the square
has **index one** (written $\lambda = 1$) when, on any two *distinct* columns, no
ordered pair of symbols ever repeats — each pair $(p,q)$ shows up on at most one
row. Index-one PRS squares are the tightly-packed, non-redundant version of the
symmetry.

The conjecture at the heart of this article is startlingly clean:

> **A pairwise reflection symmetric Latin square of order $n$ with index one
> exists if and only if $n$ is a power of two.**

No power-of-two square is forbidden, and no non-power-of-two square is allowed.
Order $2, 4, 8, 16$: yes. Order $3, 5, 6, 7$: no. Why on earth should a symmetry
condition on pairs of columns *care* whether $n$ is a power of two? The answer
is a beautiful bridge between three very different corners of mathematics.

## The bridge: from grids to groups to number theory

The secret is that some Latin squares are not just grids — they are the
**multiplication tables of groups**. A group is a set of objects equipped with a
way to combine any two of them (a "product"), with an identity element and
inverses, obeying the associative law. The clock arithmetic of the integers
modulo $n$ is a group; so are the symmetries of a triangle, and countless other
structures. Write out the product $x \cdot y$ for every pair of elements in an
$n$-element group, arranging $x$ along the rows and $y$ along the columns, and
you get an $n \times n$ table.

**First observation.** That table is *automatically* a Latin square. Because you
can always cancel in a group — if $a \cdot y = b \cdot y$ then $a = b$ — no symbol
can repeat in a column, and by the same token none repeats in a row. Every group
of order $n$ hands you a Latin square of order $n$ for free. Moreover its index
is one: knowing what two distinct columns read on a given row determines that
row uniquely.

**Second observation — the keystone.** When is the multiplication table of a
group pairwise reflection symmetric? The answer is astonishingly crisp. The
table is PRS *exactly when every element of the group is its own inverse* — that
is, when $x \cdot x = e$ for every element $x$, where $e$ is the identity. Groups
with this property are said to have **exponent two**: squaring anything returns
you to the starting point, like flipping a light switch twice.

The reason is a short, satisfying calculation. On columns $j_1$ and $j_2$ the
pair $(p, q)$ appears on the unique row $x$ with $x \cdot j_1 = p$ and
$x \cdot j_2 = q$; eliminating $x$, this happens precisely when
$p \cdot w = q$, where $w = j_1^{-1} \cdot j_2$ is a fixed element built from the
two columns. The reversed pair $(q, p)$ appears when $q \cdot w = p$. So
reflection symmetry demands
$$p \cdot w = q \iff q \cdot w = p.$$
If $w \cdot w = e$, multiplying $p \cdot w = q$ on the right by $w$ gives exactly
$q \cdot w = p$, and vice versa — the equivalence holds, and the table is
symmetric. Conversely, feeding the columns "identity" and "$x$" into the
symmetry condition forces $x \cdot x = e$ for every $x$. A purely *combinatorial*
symmetry of a grid turns out to be identical to a purely *algebraic* property of
a group. That is the keystone of the bridge.

**Third observation — the payoff.** A finite group in which every element
squares to the identity has size a power of two. This is a classical gem of
group theory. Such a group is automatically commutative (a two-line argument:
since $ab$, $a$, and $b$ are all their own inverses,
$ab = (ab)^{-1} = b^{-1}a^{-1} = ba$), and one can show every element has order
$1$ or $2$, which forces the group to be a **$2$-group**: its order is
$2^k$ for some $k$. There is simply no exponent-two group of order $3$, or $5$,
or $6$ — the arithmetic forbids it.

Chain the three observations together and the "only if" direction snaps into
place for group tables: if the multiplication table of a group is pairwise
reflection symmetric, the group has exponent two, so its order — the order of the
Latin square — is a power of two.

## Building the examples

A bridge is only convincing if traffic flows both ways, so we also need the "if"
direction: whenever $n$ is a power of two, a PRS index-one square really exists.
Here the construction is explicit and elegant. Take $k$ independent switches,
each either off or on, and let the group be all $2^k$ configurations, combined by
flipping switches independently — formally, the elementary abelian group
$(\mathbb{Z}/2)^k$, which is just vectors of $0$s and $1$s added coordinatewise
modulo two. Adding any vector to itself gives the zero vector, so every element
squares to the identity. By the keystone, its multiplication table is a pairwise
reflection symmetric Latin square, and by the cancellation property it has index
one. Its order is exactly $2^k$.

So for **every** power of two there is a witness, and the smallest cases are easy
to picture. At order $2$ the table is the XOR of a single bit. At order $4$ it is
the XOR table of two-bit strings — the familiar "Klein four-group" square. At
order $8$, three bits, and so on up the ladder of powers of two.

This settles the conjecture completely for the vast and important class of
group-based squares, and it settles the constructive half for *all* orders that
are powers of two.

## What is genuinely known — and what remains

It is worth being precise about the frontier. Everything above gives an
airtight, two-directional theorem **for Latin squares that arise as group
multiplication tables**: such a square is pairwise reflection symmetric with
index one if and only if its order is a power of two, and every power of two is
realized.

The fully general conjecture — for *arbitrary* PRS index-one squares, not
necessarily coming from a group — is still open, and for an interesting reason.
Not every Latin square is secretly a group table. The very first "exotic"
example, one that no relabeling can turn into a group, appears already at order
five. So closing the general conjecture means controlling squares that have no
group structure to lean on. Promising routes include attaching to each square a
family of "difference" permutations and hunting for a hidden binary-linear
invariant; recasting the symmetry as an identity in the looser language of
quasigroups (where a Steiner-like law should replace "every element squares to
the identity"); and a Fourier-analytic attack in which reflection symmetry
becomes a statement about $\pm 1$ characters, potentially forcing the
power-of-two conclusion directly.

## Why it resonates

There is a particular kind of pleasure in a theorem that ties a knot between
distant fields. Here a question a puzzle-lover could ask — *are the pairs in
these two columns as common as their mirror images?* — turns out to be the same
question a group theorist asks — *does everything square to the identity?* — which
in turn is the same question a number theorist answers — *is $n$ a power of two?*
Three vocabularies, one truth.

That is also why the result is more than a curiosity. Reflection-symmetric,
non-repeating designs are exactly the kinds of structures engineers reach for
when they need balance without bias: in the layout of experiments, in the
scheduling of fair competitions, in the mixing layers of ciphers where the
$(\mathbb{Z}/2)^k$ XOR tables above are already the workhorses. Knowing that this
brand of perfect symmetry is available *precisely* at the powers of two tells a
designer, before a single grid is drawn, which sizes can possibly work — and
hands them a ready-made recipe for the sizes that can.

The powers of two are the numbers of doublings, of binary digits, of switches
that are simply on or off. It is fitting that the most impartial way to fill a
grid should belong to them alone.
