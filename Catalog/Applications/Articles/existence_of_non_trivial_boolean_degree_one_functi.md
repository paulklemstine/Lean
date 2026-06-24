# The Lines That Refuse to Be Simple

## A hidden census of geometry

Imagine standing inside a three-dimensional world built not from the smooth
continuum of everyday space, but from a *finite* arithmetic. In such a world there
are only finitely many points, finitely many lines, finitely many planes — and yet
the geometry is rich enough to host the same incidences, the same pencils, the same
duality between points and planes that we know from ordinary projective space. This
is **finite projective space**, written $PG(3, q)$, where $q$ is the number of
elements in the underlying field $\mathbb{F}_q$ (so $q = 2, 3, 4, 5, 7, 8, 9, \dots$
runs over prime powers).

The lines of $PG(3,q)$ are the real protagonists of this story. They are the
two-dimensional subspaces of a four-dimensional vector space over $\mathbb{F}_q$, and
when we collect them all together with their natural notion of "closeness," they form
a beautiful combinatorial object called the **Grassmann scheme** $J_q(4,2)$. The
question we will explore is deceptively simple to state:

> Which *yes/no labellings* of the lines are, in a precise sense, the "simplest
> possible"? And — crucially — are the simplest labellings the *only* tidy ones, or
> does geometry hide labellings that look complicated but behave simply?

The answer turns out to be a small drama about a single integer, a midpoint, and a
threshold at $q = 3$.

## Counting before we philosophize

Before anything subtle happens, we need to count. Finite geometry rewards counting
the way number theory rewards factoring: the formulas are clean, and they encode
everything.

How many lines pass through a single fixed point of $PG(3,q)$? The lines through a
point form a little projective plane in their own right — a *pencil* — and the count
is the number of points of a projective plane $PG(2,q)$:
$$
\text{(lines through a point)} \;=\; q^2 + q + 1.
$$
For $q = 3$ that is $13$; for $q = 5$ it is $31$.

How many lines are there in total? This is the Gaussian binomial coefficient
$\left[ \begin{smallmatrix} 4 \\ 2 \end{smallmatrix}\right]_q$, and it factors
gorgeously:
$$
\text{(all lines)} \;=\; (q^2 + 1)\,(q^2 + q + 1).
$$
For $q = 3$ there are $10 \times 13 = 130$ lines; for $q = 5$ there are
$26 \times 31 = 806$. These two numbers — $q^2+q+1$ lines through a point, and
$(q^2+1)(q^2+q+1)$ lines in all — are the entire scaffolding on which the rest of the
argument hangs.

## What does "simple labelling" even mean?

A *labelling* of the lines is just a function that assigns to each line either
$\textsf{true}$ or $\textsf{false}$ — equivalently, a choice of a set of lines (those
labelled $\textsf{true}$). There are astronomically many such labellings:
$2^{(q^2+1)(q^2+q+1)}$ of them. Most are random noise. We want the ones that respect
the geometry.

The right notion of "respecting the geometry" comes from the theory of *association
schemes*. The Grassmann scheme $J_q(4,2)$ has a natural hierarchy of frequencies, or
"degrees," much like a sphere has spherical harmonics of degree $0, 1, 2, \dots$. A
labelling is called a **Boolean degree one function** if, when expanded in these
frequencies, it lives entirely in the lowest two layers — the constant layer (degree
zero) and the first harmonic layer (degree one). Intuitively, a Boolean degree one
function is one that is *as smooth as a non-constant $\{0,1\}$-valued function can
be*.

These objects have a famous second name in finite geometry: **Cameron–Liebler line
classes**. They were introduced by Peter Cameron and Robert Liebler in 1982 while
studying the symmetries of projective space, and they have been a magnet for research
ever since because they sit at the crossroads of geometry, coding theory, and the
spectral theory of graphs.

A defining miracle of these labellings is that they admit a single integer summary.
Every Cameron–Liebler line class carries a **parameter** $x$, an integer with
$$
0 \le x \le q^2 + 1,
$$
and the number of lines it selects is *forced* to be exactly
$$
x \cdot (q^2 + q + 1)
$$
— that is, $x$ "point-pencils' worth" of lines. The parameter is not something you
choose; it is read off from the labelling, and it controls almost everything about
it. This counting identity — *size equals parameter times lines-through-a-point* — is
the precise, checkable fingerprint of degree one.

## The eight obvious labellings

Some Boolean degree one functions are obvious, because we can *build* them by hand
from the raw ingredients of geometry. There are eight of them, and they come in
complementary pairs:

1. **Nothing** — label every line $\textsf{false}$. Parameter $x = 0$.
2. **Everything** — label every line $\textsf{true}$. Parameter $x = q^2 + 1$.
3. **A point-pencil** $x_p$ — label $\textsf{true}$ exactly the lines through a fixed
   point $p$. There are $q^2+q+1$ of them, so parameter $x = 1$.
4. **The complement of a point-pencil**, $1 - x_p$. Parameter $x = q^2$.
5. **A plane-pencil** $y_r$ — label $\textsf{true}$ exactly the lines lying inside a
   fixed plane $r$. Again $q^2+q+1$ lines, parameter $x = 1$.
6. **The complement of a plane-pencil**, $1 - y_r$. Parameter $x = q^2$.
7. **A point-pencil plus a plane-pencil**, $x_p + y_r$ (choosing $p$ not on $r$ so
   the two families are disjoint). Parameter $x = 2$.
8. **Its complement**, $1 - x_p - y_r$. Parameter $x = q^2 - 1$.

Tabulating the parameters of these eight "trivial" labellings, we get a small, tidy
set:
$$
\{\,0,\; 1,\; 2,\; q^2-1,\; q^2,\; q^2+1\,\}.
$$
Notice the perfect symmetry: the set is unchanged when we send each parameter $x$ to
$q^2 + 1 - x$, the operation of *taking complements*. The trivial labellings live at
the two ends of the parameter range and nowhere in the middle.

This raises the central question with full force: **is the middle empty?** Is every
Boolean degree one function on the lines of $PG(3,q)$ one of these eight obvious
constructions, or are there labellings whose parameter lands strictly *between* $2$
and $q^2 - 1$ — labellings that are smooth in the degree-one sense yet cannot be
assembled from points and planes?

## The midpoint that breaks the monotony

Here is the elegant idea at the heart of this work. Among all possible parameters,
one is singled out by symmetry: the **midpoint**. A labelling whose parameter sits
exactly halfway across the range is *self-complementary* — it is congruent to its own
mirror image under $x \mapsto q^2+1-x$. The midpoint parameter is
$$
\text{bdParam}(q) \;=\; \frac{q^2 + 1}{2}.
$$
We name it after **Bruen and Drudge**, who in the late 1990s gave an explicit
geometric construction (built from elliptic quadrics and the deep arithmetic of
finite fields) of a genuine Cameron–Liebler line class sitting at exactly this
midpoint, for every odd prime power $q$.

Two arithmetic facts about this midpoint do all the work.

**Fact one: it is only an honest integer when $q$ is odd.** The expression
$(q^2+1)/2$ is a whole number precisely when $q^2 + 1$ is even, i.e. when $q$ is odd.
We can state this as a clean identity: for odd $q$,
$$
2 \cdot \text{bdParam}(q) \;=\; q^2 + 1,
$$
so that $\text{bdParam}(q) + \text{bdParam}(q) = q^2 + 1$, the self-complementary
equation. For *even* $q$ there simply is no integer midpoint — the parameter range
has even length, the centre falls between two integers, and self-complementary
labellings are impossible. (For $q = 4$, for instance, $q^2+1 = 17$ is odd, and
twice the floor $(17 \div 2) = 8$ gives $16 \ne 17$.) The parity of $q$ is not a
technicality; it is an arithmetic obstruction baked into the geometry.

**Fact two: for $q \ge 3$ the midpoint is strictly inside the forbidden middle.**
This is the punchline. We need the midpoint $\text{bdParam}(q) = (q^2+1)/2$ to satisfy
$$
2 \;<\; \frac{q^2+1}{2} \;<\; q^2 - 1.
$$
The lower bound says $q^2 + 1 > 4$, true whenever $q \ge 2$; in fact for $q \ge 3$
the midpoint already exceeds $4$. The upper bound says $q^2 + 1 < 2q^2 - 2$, i.e.
$q^2 > 3$, true for all $q \ge 2$. So the midpoint lands strictly between the trivial
boundary values $2$ and $q^2 - 1$ — it is genuinely *in the middle*.

Put the two facts together. For every **odd** $q$ with $q \ge 3$, the Bruen–Drudge
construction delivers a Boolean degree one function whose parameter is an honest
integer lying strictly inside the non-trivial window. Such a labelling cannot be any
of the eight obvious ones, because all eight have parameters at the extremes. It is a
*non-trivial* Boolean degree one function — a smooth $\{0,1\}$-labelling of the lines
that no amount of gluing points and planes can reproduce.

## Why $q = 3$ is the gateway

The threshold is sharp, and the reason is a counting collision. For very small fields
the trivial six parameters $\{0,1,2,q^2-1,q^2,q^2+1\}$ already exhaust the entire
range $\{0, 1, \dots, q^2+1\}$, leaving no room in the middle. This happens exactly
when the range has six or fewer slots, i.e. when $q^2 + 1 \le 5$, which means
$q \le 2$.

For $q = 2$ the parameter range is $\{0,1,2,3,4,5\}$ and the trivial set is the *whole
thing*: $\{0,1,2,3,4,5\}$. There is no non-trivial window at all. The $35$ lines of
$PG(3,2)$ are too few to hide anything.

The moment $q$ reaches $3$, the dam breaks. Now the range is $\{0,1,\dots,10\}$, the
trivial set is only $\{0,1,2,8,9,10\}$, and the middle $\{3,4,5,6,7\}$ opens up. The
midpoint $\text{bdParam}(3) = 5$ sits squarely inside, and the $130$ lines of
$PG(3,3)$ are numerous enough to support a labelling that is smooth but not simple.
From $q = 3$ onward the window only widens, and the midpoint always rides along inside
it.

So the existence of non-trivial Boolean degree one functions is governed by a single
crisp threshold: **never for $q = 2$, always available at the midpoint for odd
$q \ge 3$.**

## Separating what we *know* from what we *assume*

It is worth being scrupulous about what has actually been established, because the
discipline of separating the proven from the assumed is exactly what makes the result
trustworthy.

The **arithmetic** is unconditional. That the midpoint $\text{bdParam}(q)$ is a true
integer for odd $q$, that it satisfies the self-complementary equation
$2\,\text{bdParam}(q) = q^2+1$, and that it lies strictly between $2$ and $q^2-1$ for
$q \ge 3$ — all of this is pure number theory, proved once and for all with no
geometric input.

The **geometry** is the input. The statement that a Cameron–Liebler class actually
*exists* at this midpoint is the hard theorem of Bruen and Drudge, and rather than
re-deriving their elliptic-quadric construction we treat it as a clearly labelled
hypothesis. We model a Cameron–Liebler class abstractly: it is a Boolean function on
the (finite) set of lines, equipped with its parameter, subject to the single
defining identity that its support has size $x \cdot (q^2+q+1)$.

From that minimal data, two logical levers do the rest. If the parameter is
*positive*, the support is non-empty, so the function takes the value $\textsf{true}$
somewhere. If the parameter is *less than the maximum* $q^2+1$ and the line set is the
genuine Grassmann count $(q^2+1)(q^2+q+1)$, then the support cannot be everything, so
the function takes the value $\textsf{false}$ somewhere. Feed in the midpoint
parameter, which for $q \ge 3$ is both positive (indeed exceeds $4$) and below the
maximum, and you conclude:

> **The Bruen–Drudge labelling is non-constant.** It says $\textsf{true}$ on some
> lines and $\textsf{false}$ on others. It is neither "nothing" nor "everything," and
> — because its parameter is in the forbidden middle — it is none of the eight
> obvious constructions.

That is the existence of a non-trivial Boolean degree one function, reduced to its
logical and arithmetic essentials.

## Why this matters beyond the puzzle

Cameron–Liebler classes are not an isolated curiosity. They are *equivalent* to
several objects that appear all over discrete mathematics:

- **Spectral graph theory.** The lines of $PG(3,q)$ form the vertices of the
  *Grassmann graph*, and Boolean degree one functions are exactly the $\{0,1\}$-valued
  vectors that live in the top two eigenspaces. The threshold at $q=3$ is a statement
  about which graphs admit "low-frequency" Boolean eigen-combinations — a question
  with the same flavour as the celebrated sensitivity and expansion phenomena.

- **Coding theory and designs.** The supports of these classes are highly structured
  line sets — tight, balanced, and self-dual at the midpoint — exactly the raw
  material of combinatorial designs and the geometric codes built from them.

- **The arithmetic of fields.** That non-triviality switches on at $q = 3$ and that
  self-complementarity demands *odd* $q$ are reminders that finite geometry is
  ultimately number theory in disguise. The parity of the field size is destiny.

There is also a tantalizing bridge to the most classical of combinatorial schemes,
the **Hamming scheme** of binary strings. There, degree-one Boolean functions are
governed by the first Krawtchouk polynomial $K_1(x; n) = n - 2x$, a perfectly linear
"dictatorship detector." The Grassmann scheme is the $q$-analogue, and its degree-one
theory is governed by a $q$-Krawtchouk polynomial — a $q$-deformation of the same
$n - 2x$ line. The midpoint $x = (q^2+1)/2$ is precisely the place where this
$q$-linear functional vanishes, the geometric "balance point." Seen this way, the
self-complementary Bruen–Drudge class is the finite-field cousin of the balanced
Boolean functions that pervade theoretical computer science.

## The shape of the answer

Strip away the machinery and a single, satisfying picture remains. The lines of a
finite three-dimensional space can be labelled $\textsf{true}/\textsf{false}$ in a
"smooth" degree-one way. The smoothest such labellings come in a tidy family of eight,
sitting at the extremes of a parameter line that runs from $0$ to $q^2+1$. For the
tiniest space, $PG(3,2)$, those eight are *all there is* — the middle is empty. But
the instant the field grows to three elements, a gap opens in the centre of the
parameter line, and the symmetry of the problem points to its exact midpoint
$(q^2+1)/2$. Whenever the field has an odd number of elements, that midpoint is a real
integer, and a real, self-mirroring, non-trivial labelling lives there.

It is a small theorem with a large moral: in finite geometry, *simplicity is bounded
above by size*. Make the world large enough, and it will always contain structures
that are smooth without being obvious — lines that, collectively, refuse to be
simple.
