# Six Friends, a Pentagon, and the Unavoidable Pattern

## A party trick that became a theorem

Invite six people to a party. Any two of them either already know each other or
they don't — there is no in-between. Now make the following claim, which sounds
far too strong to be true:

> Among any six people, there are always three who all know each other, **or**
> three who are all mutual strangers.

You cannot escape this. You can arrange the acquaintances however you like —
make it lopsided, make it sparse, make it weird — and somewhere inside the group
of six a perfectly uniform trio will always appear. With five people you *can*
slip free; with six you never can. That single jump, from "sometimes avoidable"
to "always unavoidable", is the smallest nontrivial fact in a field called
**Ramsey theory**, and it captures the whole spirit of the subject:

> **Complete disorder is impossible.** Make any structure big enough and
> pockets of order are forced to appear, whether you want them or not.

This article is about turning that slogan into exact, fully proved mathematics.
We will pin down the precise tipping point for the party problem — it is exactly
six — meet a beautifully stubborn five-person configuration shaped like a
pentagon that shows five is not enough, and then climb to a general counting
bound that controls *every* such problem at once.

## Drawing the problem

The clean way to think about the party is with dots and lines. Draw one dot for
each person. For every pair of people draw a line between their dots, and colour
that line **red** if the two know each other and **blue** if they are strangers.
A party of $n$ people becomes a complete network on $n$ dots in which every line
wears one of two colours.

Now the claim translates perfectly. "Three mutual acquaintances" is a red
triangle: three dots with all three connecting lines red. "Three mutual
strangers" is a blue triangle. The party theorem says: **colour the ten lines
among six dots any way you like, and you will always create a red triangle or a
blue triangle.**

Mathematicians write this kind of guarantee with an arrow. The statement
$$ n \to (s, t) $$
means: *however you two-colour the network on $n$ dots, you are forced to create
either a red clique of size $s$ — a group of $s$ dots all joined in red — or a
blue clique of size $t$.* (A "clique" is just a fully connected group; a triangle
is a clique of size $3$.) The party theorem is exactly
$$ 6 \to (3, 3). $$

The smallest $n$ that works is called the **Ramsey number** $R(s, t)$. So the
party problem is the assertion that $R(3,3) = 6$: six is enough, and — as we will
see — five is not.

## Why six is enough

Here is the argument, and it is short enough to do at the party.

Pick any one person; call her Alice. Alice has five relationships with the other
five guests, each red or blue. Five things in two colour-boxes means one box
holds at least three of them. Say at least three of Alice's lines are red, going
to guests $X$, $Y$, $Z$ (the blue case is identical with the colours swapped).

Now look only at the trio $X, Y, Z$.

- If *any* line among them is red — say $X$–$Y$ — then Alice, $X$ and $Y$ form a
  red triangle, because Alice–$X$ and Alice–$Y$ are red and now $X$–$Y$ is too.
- If *no* line among them is red, then all three lines $X$–$Y$, $Y$–$Z$, $X$–$Z$
  are blue, and $X, Y, Z$ form a blue triangle.

Either way a monochromatic triangle appears. Six is enough. In our formal
development this is the theorem `arrows_three_three`, stating exactly
$6 \to (3,3)$.

## Why five is not enough: the pentagon

To prove that six is the *true* threshold, we must exhibit a five-person party
with **no** monochromatic triangle. The witness is one of the most elegant small
objects in combinatorics: the **pentagon**.

Seat five people at a round table. Make each person know only their two
immediate neighbours (those edges are red); every other pair are strangers
(blue). The red edges form a five-pointed cycle — a pentagon. Now check:

- **No red triangle.** A red triangle would need three people who are pairwise
  neighbours around the table, but a five-cycle has no such trio; its edges only
  ever connect adjacent seats.
- **No blue triangle.** The blue edges connect each person to the two people who
  are *not* their neighbours. Remarkably, those blue edges also form a single
  five-cycle (the "pentagram" you get by connecting every other vertex), so by
  the same reasoning there is no blue triangle either.

The pentagon is *self-complementary*: swap red and blue and you get back a
pentagon. This perfect symmetry is exactly why it dodges both colours at once. In
the formal development the two checks are `pentagon_no_triangle` and
`pentagon_compl_no_triangle`, and together they give `not_arrows_five_three_three`:
the statement that $5 \not\to (3,3)$.

Combining the two halves yields the headline result, named `ramsey_three_three`:
$$ R(3,3) = 6, \qquad\text{i.e.}\qquad 6 \to (3,3) \ \text{ but }\ 5 \not\to (3,3). $$

A clean, two-sided, exactly determined fact: six always works, five sometimes
fails.

## The simplest infinite family: $R(2, t) = t$

Triangles are the size-$3$ case. What if a "red clique" only needs size $2$ — a
single red edge? Then the question becomes: how many dots force *either one red
edge somewhere, or a fully blue clique of size $t$*?

The answer is exactly $t$, an entire infinite family of exact Ramsey numbers we
can prove in one stroke:
$$ R(2, t) = t. $$

The reasoning is almost a tautology once you see it.

- **$t$ dots are enough** (`arrows_two_t`, the statement $t \to (2,t)$). Take any
  colouring of $t$ dots. Either there is at least one red line somewhere — and a
  single red line *is* a red clique of size $2$, so we are done — or there is no
  red line at all, meaning **every** line is blue. In that case the whole set of
  $t$ dots is one giant blue clique of size $t$. Either way we win.
- **$t-1$ dots are not enough** (`not_arrows_pred_two_t`, the statement
  $t-1 \not\to (2,t)$). Colour every line among $t-1$ dots blue. There is no red
  edge (so no red $2$-clique), and there are only $t-1$ dots, too few to host a
  blue clique of size $t$. The all-blue colouring escapes.

Packaged together these give `ramsey_two_t`: $R(2,t) = t$ for every $t \ge 1$.
It is the base of the whole tower of Ramsey numbers.

## One bound to rule them all: Erdős and Szekeres

Computing individual Ramsey numbers by hand gets brutal fast. (To this day no
one knows the exact value of $R(5,5)$; even $R(4,4)$ took serious work.) What
saves the subject from despair is a single general inequality, discovered by Paul
Erdős and George Szekeres in 1935, that bounds *every* Ramsey number at once
using nothing more than binomial coefficients — the same $\binom{n}{k}$ that
count card hands and Pascal's triangle entries.

The bound says:
$$ R(s+1,\, t+1) \ \le\ \binom{s+t}{s}. $$
In arrow form this is our theorem `arrows_recursion` (restated as
`arrows_binomial_bound`):
$$ \binom{s+t}{s} \to (s+1,\, t+1). $$

The engine behind it is a recursion of striking simplicity, captured by the
theorem `arrows_step`:
$$ \text{if } m \to (s,\, t+1) \ \text{ and } \ n \to (s+1,\, t), \quad\text{then}\quad m + n \to (s+1,\, t+1). $$

Why does *adding* the two thresholds work? Repeat the Alice trick. In a party of
$m + n$ people, pick a vertex $v$ and split everyone else into the red neighbours
$R$ (joined to $v$ in red) and the blue neighbours $B$. Since
$|R| + |B| = m + n - 1$, we must have $|R| \ge m$ or $|B| \ge n$.

- If $|R| \ge m$, then because $m \to (s, t+1)$ the red group already contains a
  blue $(t+1)$-clique (done immediately) or a red $s$-clique — and that red
  $s$-clique, every member of which is joined to $v$ in red, grows by adding $v$
  into a red $(s+1)$-clique.
- If $|B| \ge n$, the mirror-image argument with $n \to (s+1, t)$ produces either
  a red $(s+1)$-clique or a blue $t$-clique extended by $v$ to a blue
  $(t+1)$-clique.

That is the entire idea. Feed this recursion the trivial base facts that a single
dot is by itself both a red and a blue clique of size $1$ (`arrows_one_red`,
`arrows_one_blue`, i.e. $1 \to (1, b)$ and $1 \to (a, 1)$), and the thresholds
add up exactly along Pascal's triangle:
$$ \binom{s+t}{s} = \binom{s-1+t}{s-1} + \binom{s+t-1}{s}. $$
The binomial coefficient is literally Pascal's rule bookkeeping the recursion.

As an immediate corollary, plug in $s = t = 2$: since $\binom{4}{2} = 6$, the
general bound instantly re-derives $6 \to (3,3)$ — the party theorem falls out as
one special case of the master inequality.

## A hidden symmetry

There is one more elegant fact worth stating, because it cuts the work in half.
Red and blue play perfectly interchangeable roles. If $n$ dots force a red
$s$-clique or a blue $t$-clique, then the very same $n$ dots force a red
$t$-clique or a blue $s$-clique — just relabel the colours. Formally this is
`Arrows.symm`:
$$ n \to (s, t) \quad\Longrightarrow\quad n \to (t, s), \qquad\text{hence}\qquad R(s,t) = R(t,s). $$
The proof is a one-liner: apply the hypothesis to the colour-swapped network
(the complement graph) and swap the colours back. This is why people only ever
tabulate Ramsey numbers with $s \le t$; the rest of the table is a mirror.

## Where the trail leads next

The results above — $R(3,3) = 6$, the infinite family $R(2,t) = t$, the
Erdős–Szekeres binomial bound, the recursion, and the colour symmetry — are the
solid, fully verified foundation. They also point straight at the frontier.

- **Nailing $R(4,4) = 18$ exactly.** The binomial bound already gives the upper
  half. The missing piece is a clever $17$-dot colouring with no monochromatic
  clique of size $4$ — the famous **Paley graph** on the $17$ numbers modulo
  $17$, where two numbers are joined exactly when their difference is a perfect
  square mod $17$. Like the pentagon, it is self-complementary, and its rigid
  algebraic regularity (every pair of adjacent points shares exactly the right
  number of common neighbours) replaces hopeless brute-force search.
- **The probabilistic method.** Erdős's revolutionary idea: colour the network at
  random and show that the *expected* number of monochromatic cliques can be made
  less than one, proving a good colouring must exist without ever constructing
  it. This gives the best known *lower* bounds on Ramsey numbers.
- **Hales–Jewett.** A vast generalization that trades graphs for high-dimensional
  grids, guaranteeing unavoidable "combinatorial lines" and underwriting much of
  modern Ramsey theory.

But the heart of the story is already complete and exact. Disorder, past a
certain size, is simply not an available option. Six friends cannot all be
strangers and acquaintances in a perfectly patternless way — and now we know,
down to the last edge of a stubborn little pentagon, precisely why.
