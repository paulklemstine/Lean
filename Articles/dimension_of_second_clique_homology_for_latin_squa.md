# The Hidden Squares Inside a Latin Square

## A puzzle that hides a graph

Fill an $n \times n$ grid with the numbers $1$ through $n$ so that every row and
every column contains each number exactly once. You have just drawn a *Latin
square*. Children meet these grids as Sudoku; statisticians use them to design
experiments; algebraists recognize them as the multiplication tables of
finite quasigroups. They are among the most democratic objects in mathematics:
simple enough to doodle on a napkin, deep enough to resist a century of study.

Here is a small one of order $5$, built by the rule "the entry in row $i$,
column $j$ is $i+j$ modulo $5$":

$$
\begin{array}{|c|c|c|c|c|}
\hline
0&1&2&3&4\\\hline
1&2&3&4&0\\\hline
2&3&4&0&1\\\hline
3&4&0&1&2\\\hline
4&0&1&2&3\\\hline
\end{array}
$$

Now play a different game with the same grid. Treat each of the $n^2$ *cells* as
a dot, and draw a line between two dots whenever the two cells **share a row**,
**share a column**, or **carry the same symbol**. The result is a network — a
*graph* — that mathematicians call the **Latin square graph**. It is remarkably
uniform: every single cell is connected to exactly $3(n-1)$ others (the $n-1$
other cells in its row, the $n-1$ in its column, and the $n-1$ elsewhere that
happen to hold the same number). This kind of extreme regularity makes Latin
square graphs a favorite laboratory for the theory of *strongly regular graphs*.

This article is about the shapes you can find inside that network — its
triangles, its tetrahedra — and about a cautionary tale: a beautiful-looking
formula that turned out to be wrong, and the correct formulas that replaced it.

## Triangles, tetrahedra, and higher shapes

A network is more than its edges. Whenever three dots are all mutually
connected, they form a **triangle**. Whenever four dots are all mutually
connected — every one of the six possible edges present — they form a
**tetrahedron**, the graph theorist's $K_4$. Cataloguing these little
"clumps of mutual friendship" (formally, *cliques*) is one of the oldest games
in combinatorics, and it is the first step toward measuring the *topology* of a
network: the way its triangles, tetrahedra, and higher clumps fit together to
enclose hollow spaces.

Latin square graphs are an ideal place to count clumps, because their edges come
in three clean flavors — **row edges**, **column edges**, and **symbol edges** —
and every clique is built from those three ingredients. So a natural project
suggests itself: *count the triangles, count the tetrahedra, and read off the
topology.*

## A tempting formula — and why it fails

The Latin square graphs of a given order $n$ all look alike from a distance:
they share the same number of vertices, the same degree, and the same
"strongly regular" statistics. It is tempting to believe that they therefore
have the same number of triangles and tetrahedra, given by clean closed-form
expressions. A specific set of such formulas was proposed:

- **Proposed triangle count:** $n^2(n-1)^2$.
- **Proposed tetrahedron count:** $(n-1)^3 n^2 - 6\,I(M)$, where $I(M)$ counts
  the *intercalates* of the square (more on these in a moment).
- **A topological consequence:** that the second homology — a precise count of
  the two-dimensional "hollow shells" in the complex of cliques — would have
  dimension $(n-1)^3 - I(M)$.

These are attractive guesses. They are also **false**, and the honest way to see
this is to actually count. Take the order-$5$ square above. A direct enumeration
of its Latin square graph finds:

- **$250$ triangles**, not the proposed $n^2(n-1)^2 = 5^2 \cdot 4^2 = 400$;
- **$75$ tetrahedra**, not the proposed $(n-1)^3 n^2 = 4^3 \cdot 25 = 1600$.

The gap is not a rounding error; it is a factor of nearly two in one case and
more than twenty in the other. The proposed formulas simply overcount by
imagining connections that a Latin square forbids.

There is an even sharper problem, an internal contradiction. The proposed
topological claim rested on the assertion that the *boundary* of the
tetrahedra — the map that records how each solid tetrahedron is glued to its
four triangular faces — vanishes entirely. But if there are $75$ genuine
tetrahedra in the order-$5$ graph, their boundaries cannot all vanish: a single
solid tetrahedron already contributes a nonzero boundary. The proposal thus
asks for many tetrahedra and no boundary in the same breath, and those two
demands cannot both hold. The order-$5$ square, having **no intercalates at all**,
exposes the contradiction cleanly.

## The correct count of triangles

So what *is* the right answer? The key is to sort the shapes by how their edges
are colored.

Consider a triangle — three mutually connected cells. Two edges of the *same*
flavor force collinearity: if cell $A$ shares a row with $B$ and $A$ also shares
a row with $C$, then $A$, $B$, $C$ all sit in one row. So every triangle is of
exactly one of two types:

1. **Line triangles.** All three cells lie on a single line — one row, one
   column, or one symbol class. Each of the $3n$ lines contains $n$ cells that
   are all mutually connected, contributing $\binom{n}{3}$ triangles. Total:
   $3n \binom{n}{3}$.

2. **Transversal triangles.** The three edges use *all three* flavors: one row
   edge, one column edge, one symbol edge. A short count shows there are exactly
   $n^2(n-1)$ of these.

Adding these gives a clean, square-independent theorem.

> **Theorem (Triangle count).** For every Latin square of order $n$, its Latin
> square graph has exactly
> $$ 3n\binom{n}{3} + n^2(n-1) \;=\; \frac{n^3(n-1)}{2} $$
> triangles.

For $n = 5$ this is $3\cdot 5\cdot 10 + 25\cdot 4 = 150 + 100 = 250$, exactly the
enumerated value — and $\tfrac{125\cdot 4}{2} = 250$ confirms the tidy closed
form. Notice what is *not* in the formula: the intercalate count $I(M)$. Every
Latin square of a given order has the same number of triangles.

## Enter the intercalate

Tetrahedra tell a richer story, and to hear it we need the star of the show: the
**intercalate**. An intercalate is a $2\times 2$ Latin subsquare hiding inside
the big grid — two rows $i, i'$ and two columns $j, j'$ whose four cells form a
tiny Latin square:

$$
\begin{array}{|c|c|}
\hline a & b \\\hline b & a \\\hline
\end{array}
$$

that is, $M_{ij} = M_{i'j'} = a$ and $M_{ij'} = M_{i'j} = b$ with $a \neq b$.
Intercalates are the most fundamental "moves" you can make in a Latin square: you
can swap the two symbols of an intercalate and still have a valid Latin square.
Counting them, denoted $I(M)$, is a delicate business — some squares have very
many, and rare "$N_\infty$" squares have **none**.

Here is why intercalates matter for our tetrahedra. Take the four cells of an
intercalate: $(i,j), (i,j'), (i',j), (i',j')$. Are all six edges present?

- $(i,j)$–$(i,j')$: same row. ✓
- $(i',j)$–$(i',j')$: same row. ✓
- $(i,j)$–$(i',j)$: same column. ✓
- $(i,j')$–$(i',j')$: same column. ✓
- $(i,j)$–$(i',j')$: **same symbol** $a$. ✓
- $(i,j')$–$(i',j)$: **same symbol** $b$. ✓

All six! Every intercalate is a genuine tetrahedron — and a *sneaky* one,
because its two diagonal edges are held together only by the symbol relation, not
by any shared row or column. These are the tetrahedra that the naive formula both
miscounted and misunderstood.

## The correct count of tetrahedra

Sorting tetrahedra the same way we sorted triangles yields exactly two families.

1. **Line tetrahedra.** Four cells on a single line. Each of the $3n$ lines
   gives $\binom{n}{4}$ of them, for a total of $3n\binom{n}{4}$.

2. **Intercalate tetrahedra.** The four cells of an intercalate, as above. There
   are exactly $I(M)$ of these — no more, no fewer, because any tetrahedron using
   more than one edge flavor is forced by the Latin condition into precisely the
   intercalate pattern.

> **Theorem (Tetrahedron count).** For every Latin square $M$ of order $n$, its
> Latin square graph has exactly
> $$ 3n\binom{n}{4} + I(M) $$
> tetrahedra ($K_4$ subgraphs).

Look closely at how this differs from the discredited proposal. The proposal
*subtracted* $6\,I(M)$; the truth *adds* $I(M)$. Intercalates do not destroy
tetrahedra — they *create* them. For the order-$5$ square, $I = 0$, so the count
is purely the line term $3\cdot 5\cdot \binom{5}{4} = 3\cdot 5\cdot 5 = 75$,
matching the enumeration exactly.

To see the intercalate term come alive, drop to order $4$. The cyclic square of
order $4$ has $I = 4$ intercalates, so the theorem predicts
$3\cdot 4\cdot \binom{4}{4} + 4 = 12 + 4 = 16$ tetrahedra — and a direct
enumeration confirms $16$. The intercalate count is not decoration; it is a
genuine, measurable contribution to the geometry.

## What this means for topology

The original dream was topological: to compute the *second homology* of the
complex you get by filling in every triangle as a solid face and every
tetrahedron as a solid cell. Homology measures hollow shells — two-dimensional
voids that the faces enclose but the cells fail to fill. The proposal hoped these
voids would number exactly $(n-1)^3 - I(M)$, with each intercalate plugging one
otherwise-open shell.

The correct clique counts do not, by themselves, hand us that number; and the
particular shortcut the proposal used — the claim that the tetrahedra contribute
nothing to the boundary — is provably false. The boundary map is nonzero the
moment a single tetrahedron exists. So the elegant formula $(n-1)^3 - I(M)$ must
be regarded as an **open conjecture**, not a theorem, and any proof of it will
have to grapple honestly with the tetrahedral boundaries rather than wishing them
away.

What survives, and what is genuinely established, is a clean and useful picture:

- The **triangle count is a universal constant** for each order, $\tfrac{n^3(n-1)}{2}$,
  blind to the fine structure of the square.
- The **tetrahedron count sees exactly one invariant beyond the order**: the
  intercalate number $I(M)$, entering with a plus sign as $3n\binom{n}{4} + I(M)$.

That single dependence is the real headline. Among all the intricate ways two
Latin squares of the same order can differ, only their intercalate counts change
the number of tetrahedra — which is precisely why intercalates are the natural
suspects for controlling the deeper topology as well.

## Why the correction matters

It would be easy to treat a refuted formula as an embarrassment to be buried. It
is better to treat it as a lesson. The proposed formulas were seductive because
Latin square graphs *look* interchangeable from the vantage point of strongly
regular parameters. But "same parameters" is not "same everything": the parameters
fix the triangle count, yet the tetrahedron count — and, we suspect, the
topology — depends on a finer invariant that the parameters cannot see. The
intercalate count is that finer invariant.

This is a recurring theme in modern combinatorics. Coarse invariants (degrees,
eigenvalues, parameters) capture the bulk behavior of a structured object; but the
interesting variation — the part that distinguishes one object from another of the
same "type" — lives in subtler counts. For Latin squares, intercalates are that
subtler count, controlling everything from how many ways you can locally rewrite
the square to how many hidden tetrahedra its graph contains.

So the next time you fill in a grid so that no number repeats in any row or
column, remember that you are not just solving a puzzle. You are drawing a
network with a fixed, universal number of triangles — and a number of hidden
four-cornered shapes that quietly counts the $2\times 2$ squares you left behind.
