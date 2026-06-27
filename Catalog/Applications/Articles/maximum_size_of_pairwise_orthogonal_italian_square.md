# The Tricolore Puzzle: How Many Latin Squares Can Be Friends?

Imagine you are setting the table for a grand Italian dinner. You have a
square arrangement of place settings — say, four rows and four columns —
and four colors of napkins: red, white, green, and blue. House rules
forbid repetition: in every row, all four colors must appear, and in
every column, all four colors must appear. Each color shows up once and
only once along every line you can draw.

This is an **Italian square** — the same object mathematicians have long
called a *Latin square*. It is a deceptively simple constraint, and it
hides one of the most beautiful and stubborn puzzles in all of
combinatorics.

Now raise the stakes. Suppose you have a second set of colored objects —
wine glasses, perhaps, in the same number of colors — and you arrange
them in their own valid Italian square on the same table. You ask for
something almost magical: when you look at every place setting and read
off *the pair* (napkin color, glass color), you want **every possible
pair to occur exactly once**. Red napkin with green glass appears once.
Green napkin with red glass appears once. All sixteen pairs, each in
exactly one of the sixteen settings, with nothing repeated and nothing
missing.

Two squares that fit together this perfectly are called **orthogonal**.
And here is the question that has fascinated mathematicians since Leonhard
Euler posed a version of it in 1782: *how many squares can you stack up
so that every pair among them is orthogonal?*

This article tells the story of that question and the sharp answer we can
prove — that the answer is **at most $n-1$**, and that this maximum is
genuinely achieved exactly when the order $n$ is a power of a prime.

## Euler's Officers

Euler framed the puzzle in military dress. Suppose you have officers of
six ranks drawn from six regiments — thirty-six officers in all. Can you
parade them in a $6 \times 6$ square so that each row and each column
contains one officer of each rank and one officer of each regiment? In
the language above: can you find two orthogonal Italian squares of order
six, one recording rank and one recording regiment?

Euler conjectured the answer was no — and, remarkably, for order six he
was right, though a rigorous proof had to wait until Gaston Tarry
verified it by exhaustive checking in 1901. Euler went further and
guessed that no such pair existed whenever the order left a remainder of
two when divided by four — orders $6, 10, 14, 18, \dots$. That broader
conjecture turned out to be *spectacularly* false: in 1959 Bose, Shrikhande,
and Parker constructed orthogonal pairs for every such order except six.
The puzzle, in other words, is a master class in mathematical humility.
Patterns that look ironclad can shatter at the next case.

## Stacking Squares: The Tower of Orthogonality

Two orthogonal squares are good; a whole *family* of mutually orthogonal
squares is better. We call a collection **mutually orthogonal** — the
classical abbreviation is MOLS, for Mutually Orthogonal Latin Squares — if
*every* pair drawn from the collection is orthogonal. These families are
the workhorses behind error-correcting codes, the scheduling of balanced
experiments in agriculture and clinical trials, the construction of
finite geometries, and even the design of certain tournaments and
Sudoku-like puzzles.

So we want them tall. We want as many mutually orthogonal squares of a
given order $n$ as we can possibly stack. Is there a ceiling?

There is, and it is clean.

> **The Ceiling Theorem.** For any order $n \ge 2$, a family of mutually
> orthogonal Italian squares of order $n$ can contain **at most $n - 1$**
> squares.

Four-by-four squares? At most three mutually orthogonal companions.
Five-by-five? At most four. The bound is simple, universal, and — as we
will see — tight in the most important cases.

## Why $n-1$? A Proof You Can Hold in Your Hand

The reason the ceiling sits exactly at $n-1$ is genuinely elegant, and it
needs no machinery beyond careful bookkeeping. Here is the idea, stripped
to its bones.

Pick two distinct rows of your table; call them row $x_0$ and row $x_1$.
Now focus your attention on one particular cell: the cell in row $x_1$,
column $x_0$. Each square $L_t$ in your family puts *some* symbol in that
cell — call the symbol $L_t(x_1, x_0)$.

Here is the clever move. Look at the **top row** of square $L_t$, the row
indexed by $x_0$. Because every row of an Italian square contains every
symbol exactly once, the symbol $L_t(x_1, x_0)$ appears somewhere in that
top row — in exactly one column. Call that column $a(t)$. In symbols, $a(t)$
is the unique column with
$$L_t(x_0, a(t)) = L_t(x_1, x_0).$$
So to each square $L_t$ in your family we have attached a single column
$a(t)$.

Two facts now finish the argument.

**First, $a(t)$ is never the column $x_0$ itself.** If it were, we would
have $L_t(x_0, x_0) = L_t(x_1, x_0)$ — the *same* symbol appearing twice
in column $x_0$, at the two different rows $x_0$ and $x_1$. But columns of
an Italian square never repeat a symbol. Contradiction. So $a(t)$ always
lands in one of the $n-1$ columns *other* than $x_0$.

**Second, different squares get different columns.** Suppose two distinct
squares $L_s$ and $L_t$ were assigned the same column, $a(s) = a(t) = a$.
Then by definition
$$L_s(x_0, a) = L_s(x_1, x_0) \quad\text{and}\quad L_t(x_0, a) = L_t(x_1, x_0).$$
Read these as statements about the *superposition* of the two squares —
the map sending a cell to the pair of symbols the two squares place
there. The equations say that the cell $(x_0, a)$ and the cell $(x_1, x_0)$
produce the *same pair*. But orthogonality demands every pair occur
exactly once, so these two cells must be the very same cell:
$(x_0, a) = (x_1, x_0)$. That forces $x_0 = x_1$, contradicting our choice
of two *distinct* rows.

So the assignment $t \mapsto a(t)$ is an injection from your family of
squares into the set of $n - 1$ columns different from $x_0$. A set cannot
inject into a smaller set, so the family has at most $n - 1$ members.
That's the whole proof. The ceiling is real, and it is exactly $n-1$.

## Touching the Ceiling: The Magic of Fields

A ceiling is only interesting if you can reach it. Can we actually build
$n - 1$ mutually orthogonal squares? Not always — but when $n$ is a
**prime power** (a prime, or a prime raised to a power: $2, 3, 4, 5, 7,
8, 9, 11, 13, 16, \dots$), the answer is a resounding yes, and the
construction is breathtakingly simple.

The secret ingredient is a **finite field**: a number system with finitely
many elements in which you can add, subtract, multiply, and — crucially —
divide by anything nonzero. Finite fields exist for exactly the
prime-power sizes. Inside such a field $F$ with $n$ elements, build one
square for each nonzero "slope" $a$ by the formula
$$S_a(i, j) = a \cdot i + j.$$
Here $i$ is the row, $j$ is the column, and the arithmetic is done in the
field.

Each $S_a$ is a genuine Italian square. Fix a row $i$ and vary the column
$j$: the map $j \mapsto a \cdot i + j$ just shifts every symbol by a
constant, so it hits every symbol once — every row is valid. Fix a column
$j$ and vary the row $i$: the map $i \mapsto a \cdot i + j$ multiplies by
the nonzero constant $a$, then shifts; multiplying by a nonzero field
element is reversible (you can divide by $a$), so it too hits every symbol
once — every column is valid.

Now take two different slopes $a \ne b$ and superimpose $S_a$ and $S_b$.
Suppose two cells produce the same pair of symbols:
$$a\cdot i + j = a\cdot i' + j', \qquad b\cdot i + j = b\cdot i' + j'.$$
Subtract the second equation from the first: the $j$ terms cancel and you
are left with $(a - b)\cdot i = (a - b)\cdot i'$. Because $a \ne b$, the
quantity $a - b$ is nonzero, and in a field you may divide by it — forcing
$i = i'$, and then immediately $j = j'$. So distinct cells always give
distinct pairs; with $n^2$ cells and $n^2$ possible pairs, every pair
occurs exactly once. The squares are orthogonal.

The slopes $a$ range over all the nonzero elements of the field, and there
are exactly $n - 1$ of them. So we have built a family of $n - 1$
pairwise orthogonal Italian squares — *exactly* hitting the ceiling.

> **The Attainment Theorem.** Over a finite field with $n$ elements, the
> affine squares $S_a(i,j) = a\cdot i + j$ for the $n - 1$ nonzero slopes
> $a$ form a family of mutually orthogonal Italian squares of size $n-1$.
> Combined with the Ceiling Theorem, the maximum size of such a family is
> *exactly* $n - 1$, and it is achieved.

Because finite fields exist for every prime power $n = p^k$, we conclude:

> **The Prime-Power Realization.** For every prime $p$ and every exponent
> $k \ge 1$, there exist exactly $p^k - 1$ mutually orthogonal Italian
> squares of order $p^k$.

The single algebraic fact doing all the heavy lifting is that you can
**divide by $a - b$**. In a mere ring — where division may fail — the
construction can collapse. The field is not a convenience; it is the
whole game.

## The Hidden Geometry

Why should the maximum sit at $n - 1$, and why should fields be the key
that unlocks it? The deepest answer is geometric, and it reveals that this
table-setting puzzle is secretly a question about *planes*.

There is a perfect dictionary between families of squares and a tidy
combinatorial gadget called an **orthogonal array**. Picture a giant
ledger with $n^2$ rows, one for each cell of the table, and several
columns of symbols. Two of the columns simply record the cell's own row
and column coordinates; each remaining column records the symbol that one
of your squares places in that cell. The orthogonality conditions
translate into a single, uniform rule: *pick any two columns of the
ledger, and every ordered pair of symbols appears in exactly one row.*

In this language, a family of $k$ mutually orthogonal squares of order $n$
is exactly the same data as an orthogonal array with $n^2$ rows and
$k + 2$ columns where every pair of columns is "balanced." The two extra
columns are the bookkeeping coordinates of the cell.

Push the family all the way to the maximum, $k = n - 1$, and the ledger
acquires $n + 1$ columns. An orthogonal array of this extremal shape is
precisely the blueprint of a **finite affine plane of order $n$** — a
geometry with $n^2$ points in which every two points lie on a unique
line, lines come in parallel families, and any two non-parallel lines
meet in exactly one point. The $n + 1$ columns are nothing but the $n + 1$
families of parallel lines. The dictionary, made precise, reads:

> A complete set of $n - 1$ mutually orthogonal squares of order $n$ exists
> **if and only if** a finite plane of order $n$ exists.

This is why the prime powers are exactly the orders we can confidently
fill to the ceiling: a finite field hands you a plane on a silver platter,
its lines being the graphs of the affine maps $y = a\cdot x + b$. And it is
why the *converse* — whether the ceiling can ever be reached at an order
that is **not** a prime power — remains one of the great open problems of
mathematics. It is equivalent to asking whether finite planes exist beyond
the prime powers, and after centuries of effort no one knows. The cases of
order $6$ and order $10$ are ruled out (the latter only by an enormous
computer search completed in 1989), but the general pattern is a mystery.

## Why It Matters

This is not idle puzzling. Mutually orthogonal squares are the scaffolding
of **statistical experiment design**: when an agronomist must test seed
varieties against fertilizers across a field with two directions of
fertility variation, orthogonal squares let every variety meet every
treatment exactly once, balancing out the nuisance variation. They power
**error-correcting codes** that protect data on scratched discs and noisy
channels, because the "every pair exactly once" property is exactly the
redundancy that lets you detect and repair corruption. They underlie
schemes for **distributing cryptographic secrets** and for scheduling
round-robin tournaments. And in pure mathematics they are the combinatorial
shadow of finite geometry itself.

The story of Italian squares is the story of mathematics in miniature: a
rule a child could follow at the dinner table, a ceiling proved by an
argument you can hold in your hand, a construction whose magic is the
single act of dividing by a nonzero number, and — lurking just past the
edge of what we can prove — a geometric mystery that has resisted every
assault for two and a half centuries. The next time you set a table, spare
a thought for the napkins and the wine glasses. They know more geometry
than they let on.
