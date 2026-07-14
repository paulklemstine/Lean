# Counting Without Counting: The Hidden Order Behind a Sum of Products

## A puzzle in disguise

Suppose you are handed a strange-looking arithmetic task. Pick three
non-negative whole numbers that add up to, say, $4$. There are many ways to do
this: $(4,0,0)$, $(0,4,0)$, $(1,2,1)$, $(2,1,1)$, and so on. For each such
triple $(i_1, i_2, i_3)$, form a product of three binomial coefficients,
$$\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a},$$
where $a$ is some fixed number you chose in advance. Now add up all of these
products, one for every triple summing to $4$. What do you get?

At first glance this looks like a bookkeeping nightmare. The number of triples
grows quickly, each term is a product of three separate quantities, and the
whole thing seems to depend intricately on both $a$ and the target sum. And yet
the answer is astonishingly clean. No matter what $a$ and the target $d$ are,
the entire sum collapses to a *single* binomial coefficient:
$$\sum_{i_1+i_2+i_3=d}\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a}
= \binom{3a+d+2}{d}.$$

One number, on the right, secretly equal to a whole galaxy of products on the
left. This article is about why that happens, why it keeps happening no matter
how many factors you use, and why a piece of pure combinatorial magic like this
turns out to be exactly the tool needed to count one of the oldest objects in
mathematics: the Latin rectangle.

## From three to many

The three-factor identity above is not a coincidence of the number three. It is
the shadow of a far more general law. Replace three factors with $m$ of them,
and the same phenomenon persists. For **any** natural numbers $m$, $a$, and $d$,
$$\boxed{\;\sum_{i_1+\cdots+i_m=d}\ \prod_{j=1}^{m}\binom{a+i_j}{a}
= \binom{ma+d+m-1}{d}.\;}$$

The sum on the left runs over *all* ordered $m$-tuples of non-negative integers
that add up to $d$. The right-hand side is one binomial coefficient whose top
number, $ma+d+m-1$, records only three simple ingredients: the number of factors
$m$, the shared parameter $a$, and the target $d$. Everything else — the
combinatorial explosion of tuples, the tangle of products — washes out.

Why should such an identity be true? The cleanest explanation comes from a
picture that mathematicians have loved for over a century: **stars and bars**.

## Stars, bars, and multisets

Imagine you want to count the ways to place $d$ identical stars into $r$
labelled boxes. A standard trick lays the stars in a row and separates the boxes
with $r-1$ vertical bars. For example, with $d=4$ stars and $r=3$ boxes, the
arrangement
$$\star\,\star \mid \star \mid \star$$
means "two stars in box 1, one in box 2, one in box 3." Every distribution
corresponds to one arrangement of $d$ stars and $r-1$ bars in a row of
$d + r - 1$ symbols, and the number of such arrangements is
$$\binom{d+r-1}{d}.$$
This quantity — the number of ways to choose a *multiset* of size $d$ from $r$
types — is important enough to deserve its own name. We call it the
**multichoose** number,
$$\left(\!\!\binom{r}{d}\!\!\right) := \binom{r+d-1}{d},$$
read "$r$ multichoose $d$." It counts multisets: collections in which repetition
is allowed and order does not matter.

The single most useful fact about multichoose numbers is that a single binomial
coefficient can be re-read as a multichoose number and vice versa. In
particular,
$$\binom{a+i}{a} = \left(\!\!\binom{a+1}{i}\!\!\right),$$
because both sides count the number of multisets of size $i$ drawn from $a+1$
types. This tiny observation is the master key. It transforms the intimidating
product of binomials into a product of multichoose numbers, and multichoose
numbers convolve beautifully.

## The convolution law

Here is the heart of the matter, stated for two boxes first. If you split a
multiset of size $d$ into two halves — one of size $k$ chosen from $r$ types and
the rest of size $d-k$ chosen from $t$ types — and sum over every possible way
to split, you recover a single multiset chosen from all $r+t$ types combined:
$$\sum_{k=0}^{d}\left(\!\!\binom{r}{k}\!\!\right)\left(\!\!\binom{t}{d-k}\!\!\right)
= \left(\!\!\binom{r+t}{d}\!\!\right).$$
This is the multichoose version of the classical Vandermonde–Chu convolution.
It says something intuitively obvious once you see it: to build a size-$d$
multiset from $r+t$ types, first decide how many elements come from the first
$r$ types and how many from the last $t$, then choose each part independently.
Summing over the split reassembles the whole.

From this two-box law, the full identity follows by a clean induction. Adding
one more box at a time, each step is exactly one application of the convolution
above. After $m$ steps you have merged $m$ groups of $a+1$ types each into a
single pool of $m(a+1)$ types, and the size-$d$ multichoose count of that pool is
$$\left(\!\!\binom{m(a+1)}{d}\!\!\right) = \binom{m(a+1)+d-1}{d}=\binom{ma+d+m-1}{d},$$
which is precisely the right-hand side of the boxed identity.

There is a subtle payoff hidden in this translation. If you try to prove the
original binomial identity directly by induction, you run headlong into the
awkward "$-1$" in the exponent $ma+d+m-1$. Truncated subtraction over the natural
numbers behaves badly and derails the recursion. Passing to multichoose numbers
makes the subtraction vanish from the inner workings: the recursion becomes
$m(a+1)$, clean and subtraction-free, and only reappears as a "$-1$" at the very
end when you translate back. The multichoose form is, in a real sense, the
*right* generality — the version of the statement in which the proof wants to
live.

## Letting the factors differ

Once the pattern is clear, a natural question arises: must all the factors share
the same parameter $a$? They need not. Suppose the $j$-th factor uses its own
parameter $a_j$. Then the identity still holds, and — this is the striking part
— the right-hand side notices the individual parameters only through their sum:
$$\sum_{i_1+\cdots+i_m=d}\ \prod_{j=1}^{m}\binom{a_j+i_j}{a_j}
= \binom{(a_1+\cdots+a_m)+d+m-1}{d}.$$
The uniform identity is simply the special case $a_1 = \cdots = a_m = a$.

The generating-function heuristic makes this inevitable. Each factor
$\binom{a_j+i}{a_j}$ is the coefficient of $x^i$ in the power series
$(1-x)^{-(a_j+1)}$. The sum over tuples summing to $d$ is exactly the coefficient
of $x^d$ in the product of these series, and
$$\prod_{j=1}^{m}(1-x)^{-(a_j+1)} = (1-x)^{-\left(\sum_j a_j + m\right)}.$$
The product of the series depends on the exponents only through their total. The
combinatorial proof by insertion — adding one factor at a time — turns this
formal calculation into an honest, finite argument valid for every choice of
parameters.

## Why Latin rectangles care

None of this would be more than an elegant curiosity if it did not *do* something.
It does. The identity is the engine behind a classical simplification in the
enumeration of **Latin rectangles**.

A Latin square of order $n$ is an $n \times n$ grid filled with the symbols
$1, \dots, n$ so that every symbol appears exactly once in each row and exactly
once in each column — the abstract skeleton of a completed Sudoku puzzle. A
Latin *rectangle* is the same idea with fewer rows: a $k \times n$ array,
$k \le n$, whose rows are permutations of $1, \dots, n$ and whose columns never
repeat a symbol. Counting Latin rectangles is a notoriously hard problem, and
the classical attack, going back to work of Bogart, Longyear, and others,
proceeds row by row: given a valid $k$-row rectangle, in how many ways can you
legally add a $(k+1)$-st row?

That extension count is governed by an inclusion–exclusion over how the new row
interacts with the columns already filled, and the combinatorics organizes
itself into exactly the kind of sum-of-products that our identity resolves. In
the three-row case, the relevant convolution is precisely
$$\sum_{i_1+i_2+i_3=d}\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a}
= \binom{3a+d+2}{d},$$
and collapsing it to a single binomial coefficient turns an unwieldy nested sum
into a closed form. The general $m$-factor identity does the same for the analogous
step in taller rectangles: wherever the counting produces a convolution of these
binomial factors, the sum evaporates into one clean term.

## The shape of a good theorem

What makes this result satisfying is not just that it is true, but the *manner*
in which it is true. A messy, parameter-laden sum turns out to be a single
number. A subtraction that blocks the obvious proof disappears the moment you
choose the right language. An apparent dependence on many parameters collapses to
dependence on their sum. And a formula that looks like a technical lemma for one
specific counting problem reveals itself as a universal law — stars and bars, all
the way down.

The edges of the picture invite further exploration. What if the parts carry
signs, so that negative parameters produce the alternating patterns of
inclusion–exclusion? What if each part is weighted by its position, breaking the
symmetry and revealing a second hidden grading? What if the whole identity is
refined by a variable $q$ that records the "area" swept out by an underlying
lattice path, in the manner of Gaussian binomial coefficients? Each of these is a
door left ajar by the same insertion argument that proved the theorem: add one
factor at a time, and watch what you are allowed to carry along for the ride.

For now, the core statement stands complete and self-contained. A sum over an
ocean of tuples equals one binomial coefficient — and the reason is nothing more
mysterious, or more beautiful, than the humble act of counting multisets.
