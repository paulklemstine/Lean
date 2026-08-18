# The Shape of a Near Miss

## When two different crowds cast the same shadow

Here are two small collections of numbers. On the left, $1, 1, 4$. On the right, $0, 3, 3$.

They are clearly different lists. And yet:

- they have the same number of entries: $3 = 3$;
- they have the same sum: $1 + 1 + 4 = 6$ and $0 + 3 + 3 = 6$;
- they have the same sum of squares: $1 + 1 + 16 = 18$ and $0 + 9 + 9 = 18$.

Only when you get to cubes do they finally part company: $1 + 1 + 64 = 66$, while $0 + 27 + 27 = 54$.

Two different objects that agree on every measurement you make, until one measurement finally
separates them, are what we will call a **near miss**. The measurements here are the *power
sums*: for a collection $s$ of numbers, its $k$-th power sum is
$$p_k(s) \;=\; \sum_{x \in s} x^k .$$
The zeroth power sum counts the entries (with the convention $0^0 = 1$), the first is the total,
the second the sum of squares, and so on. Power sums are the moments of a distribution: the
count, the mean, the variance, the skew. A near miss is a pair of distinct collections whose
first several moments are identical.

Near misses are not a curiosity. They are the reason that "match the first $k$ moments" is a
*weak* fingerprint, and the mathematics that governs them tells you exactly how much data you
must collect before two things must be the same. They are the heart of a two-century-old
question — the Prouhet–Tarry–Escott problem — and they secretly control everything from
numerical integration rules to the design of experiments.

The question this article answers is a structural one. Suppose the values you are allowed to
use are restricted to some fixed finite palette $A$ of $N+1$ numbers, and suppose two
collections drawn from that palette agree on the first $N$ power sums $p_0, p_1, \dots,
p_{N-1}$. What can they look like? The answer turns out to be startlingly rigid: up to a single
scaling constant and a shared "padding" that cancels, there is **exactly one** near miss, and
its shape is written down by a formula that depends only on the palette — never on the
collections.

## The classical example: Pascal's triangle, split in two

Start with the most natural palette of all: the whole numbers $0, 1, 2, \dots, N$.

Take the $N$-th row of Pascal's triangle and split it by parity. Put the even positions on one
side and the odd positions on the other, using each value as many times as its binomial
coefficient says. For $N = 4$ the row is $1, 4, 6, 4, 1$, so we get

$$s \;=\; \{\,0,\; \underbrace{2,2,2,2,2,2}_{6},\; 4\,\},
\qquad
t \;=\; \{\,\underbrace{1,1,1,1}_{4},\; \underbrace{3,3,3,3}_{4}\,\}.$$

Both sides have $8 = 2^{4-1}$ elements. Both have total $16$. Both have sum of squares $40$.
Both have sum of cubes $112$. Only the fourth powers disagree: $352$ against $328$. This is the
**binomial pair** at level $N$, and it is a near miss of the purest kind.

Why does it work? Because of a beautiful and elementary identity: the alternating sum
$$\sum_{j=0}^{N} (-1)^j \binom{N}{j}\, j^k$$
vanishes for every $k < N$, and equals $(-1)^N N!$ when $k = N$. In other words, the vector of
signed binomial coefficients is *blind* to every polynomial of degree less than $N$ and sees
degree $N$ with the definite, nonzero value $N!$. Splitting that vector by sign is precisely
splitting Pascal's row by parity.

The first surprise is that this example is not merely one near miss among many. **It is the only
one.** Every pair of distinct collections with values in $\{0, 1, \dots, N\}$ that agree on the
first $N$ power sums is obtained from the binomial pair by two harmless operations: multiply all
multiplicities by a positive whole number $\lambda$, and then add the *same* extra elements to
both sides. Conversely, every such pair is a near miss. That is a complete census of an infinite
family, and it means the binomial pair is not an example but a template.

## One number governs every possible measurement

If the shape of a near miss is fixed, then so is everything you can compute from it. This is
where the story becomes genuinely surprising.

Let $s$ and $t$ be *any* near miss at level $N$ on $\{0,\dots,N\}$, and let
$$\lambda \;=\; (\text{how many }0\text{'s in }s) - (\text{how many }0\text{'s in }t),$$
a single integer read off from one value only. Then for **every** function $f$ whatsoever —
polynomial, exponential, factorial, an indicator of primality, anything at all —
$$\sum_{x \in s} f(x) \;-\; \sum_{x \in t} f(x) \;=\; \lambda \sum_{j=0}^{N} (-1)^j \binom{N}{j} f(j).$$

The entire discrepancy between the two collections, against every conceivable test, is one
integer times one universal functional. You cannot design a clever statistic to distinguish
$s$ from $t$ better than the alternating binomial sum already does.

And that alternating sum has a name. It is the $N$-th **finite difference** of $f$ at the
origin, $\Delta^N f(0)$, up to the sign $(-1)^N$ — the discrete analogue of the $N$-th
derivative. So:

> A near miss at level $N$ *is* the discrete $N$-th derivative. It is invisible to a test
> function exactly when that function's $N$-th difference at $0$ vanishes, and it separates the
> function exactly when it does not.

Since every polynomial of degree $< N$ has vanishing $N$-th difference, near misses are blind to
low-degree polynomials — which is precisely the property that we started from. What is new is
the converse: nothing else is blind to them.

There is an equally clean way to say all this in one line. Encode a collection by the polynomial
$\sum_{x \in s} q^x$. Then for every near miss,
$$\sum_{x \in s} q^x \;-\; \sum_{x \in t} q^x \;=\; \lambda\,(1-q)^N .$$
Agreeing on the first $N$ moments *means* the discrepancy has a zero of order $N$ at $q = 1$,
and the multiplier $\lambda$ is the leading coefficient there. Nothing else can happen.

## Changing the palette: the nodal weights take over

So far, so classical: the values were $0, 1, \dots, N$, and Pascal's triangle wrote the answer.
The natural question — and the one whose answer is the centrepiece here — is whether the
interval was doing any of the work.

Suppose you are given an arbitrary palette: a set $A$ of $N+1$ distinct whole numbers, as
irregular as you like. Squares $\{0,1,4,9\}$. Mersenne numbers $\{0,1,3,7,15,31\}$. Whatever you
please. Which pairs of collections drawn from $A$ agree on the first $N$ power sums?

The answer is written by a single formula, the **nodal weight** of a point of the palette:
$$w(a) \;=\; \prod_{\substack{b \in A \\ b \neq a}} (a - b).$$
This is the quantity that appears at the bottom of every Lagrange interpolation formula: the
product of the distances from $a$ to all the other nodes, with signs.

**The law of near misses on a palette.** *If two collections with values in $A$ agree on the
power sums $p_0, \dots, p_{N-1}$, and $e(a)$ denotes how many more times $a$ occurs on the left
than on the right, then*
$$e(a)\cdot w(a) \;=\; c \qquad \text{for every } a \in A,$$
*where $c$ is a single constant, the same at every node.* Equivalently: $e$ is proportional to
the inverse nodal weights, $e(a) \propto 1/w(a)$.

Read that again, because it is stronger than it looks. The discrepancy profile of a near miss
does not depend on the collections at all. It depends only on the palette. Choose your palette,
compute $N+1$ products, invert them, clear denominators — and you have written down every near
miss there is, before you have seen a single collection.

Take $A = \{0, 1, 4, 9\}$. The nodal weights are $w(0) = -36$, $w(1) = 24$, $w(4) = -60$,
$w(9) = 360$. Clearing denominators in $1/w$ gives the profile $(-10, 15, -6, 1)$, so the unique
minimal near miss is
$$\{\,\underbrace{1,\dots,1}_{15},\; 9\,\} \quad\text{versus}\quad \{\,\underbrace{0,\dots,0}_{10},\; \underbrace{4,\dots,4}_{6}\,\},$$
and sure enough both sides have $16$ elements, total $24$, sum of squares $96$ — and part
company at cubes, $744$ against $384$.

For the interval $\{0,1,\dots,N\}$ the nodal weight is $w(a) = (-1)^{N-a}\,a!\,(N-a)!$, so
$1/w(a)$ is exactly $(-1)^a\binom{N}{a}/N!$ — Pascal's row, recovered. The binomial pair was
never a fact about binomial coefficients; it was a fact about the *spacing* of the integers.

## Why it is true: interpolation answers a counting question

The proof is short enough to sketch in a paragraph, and it is a small marvel of translation
between two subjects.

Regard the discrepancy $e$ as a linear functional: it eats a function $g$ and returns
$\sum_{a \in A} e(a)\, g(a)$. The near-miss hypothesis says exactly that this functional
annihilates $1, x, x^2, \dots, x^{N-1}$; by linearity, it annihilates every polynomial of degree
less than $N$.

Now feed it a very particular polynomial: the Lagrange basis polynomial $L_{a_0}$ attached to a
node $a_0$ — the unique polynomial of degree $N$ that equals $1$ at $a_0$ and $0$ at every other
node. Evaluating the functional on $L_{a_0}$ directly gives $e(a_0)$, since all other terms are
killed. But expanding $L_{a_0}$ in powers of $x$ and using linearity, everything below degree
$N$ is annihilated, and only the leading coefficient survives — and the leading coefficient of
$L_{a_0}$ is famously $1/w(a_0)$. So
$$e(a_0) \;=\; \frac{1}{w(a_0)} \sum_{a \in A} e(a)\, a^{N},$$
which is the law, with $c = \sum_a e(a) a^N$ the (single) constant. Counting a discrepancy in
two ways — once combinatorially, once through interpolation — forces the whole structure.

In linear algebra terms: the matrix of the conditions is the truncated $N \times (N+1)$
Vandermonde matrix built from the nodes, and the theorem says its kernel is exactly the line
spanned by the inverse nodal weights. Nothing about $\mathbb{N}$ or $\mathbb{Q}$ is used; the
statement and the proof hold over any field, for any $N+1$ distinct nodes.

## Rigidity: a near miss can hide nowhere

Because $w(a)$ is a product of differences of *distinct* nodes, it is never zero. So the law
$e(a) w(a) = c$ has an immediate and drastic consequence:

> **Rigidity.** If the two collections have the same multiplicity at even a *single* node of the
> palette, then $c = 0$, hence $e$ vanishes identically, hence the two collections are equal.

A genuine near miss must therefore differ at every single node. It cannot skip a value, cannot
be locally invisible, cannot be repaired by looking away from one point. One nonzero
multiplicity difference determines all the others.

That immediately settles a question about *support size* — the number of distinct values a
collection actually uses. Since the two sides must differ everywhere on the palette, their
supports together cover all $N+1$ nodes, so
$$|\operatorname{supp} s| + |\operatorname{supp} t| \;\geq\; N + 1,$$
and consequently the larger side uses at least $\lceil (N+1)/2 \rceil$ distinct values while the
smaller uses at least $\lfloor (N+1)/2 \rfloor$. Both bounds are attained, by the binomial pair:
splitting $\{0,\dots,N\}$ by parity gives exactly $\lceil (N+1)/2\rceil$ even values and
$\lfloor (N+1)/2 \rfloor$ odd ones, and the two supports are disjoint. Moreover, equality
$|\operatorname{supp} s| + |\operatorname{supp} t| = N+1$ happens *only* for a scaled binomial
pair — the padding must be empty.

So "how few distinct values can a near miss get away with?" has the sharp answer
$\lceil (N+1)/2 \rceil$ on the larger side — and, because the general-palette theorem holds for
arbitrary nodes, that answer does not improve if you are allowed to choose your palette
cleverly. This is the sort of statement that is easy to guess and, without the nodal-weight law,
awkward to prove.

There is a companion phenomenon about *multiplicities* rather than distinct values. A near miss
at level $N$ on the interval must contain at least $2^{N-1}$ elements on each side, spread over
at most $N+1$ distinct values; by pigeonhole, some single value must be repeated at least
$2^N/(2(N+1))$ times. Near misses are inherently *lumpy*: the price of moment-blindness is
extreme concentration.

## A conjecture, and its refutation

Once you know that the size of the smallest near miss on a palette $A$ is a formula — half the
sum of the absolute values of the primitive integer version of the inverse nodal weights — it
becomes irresistible to ask which palette is cheapest. The natural guess is the interval: it is
the tightest packing of $N+1$ nodes, its inverse nodal weights are the binomial coefficients,
and its minimal near miss has $2^{N-1}$ elements per side.

The guess is wrong, and the counterexample is the pair we opened with. Take the palette
$A = \{0, 1, 3, 4\}$ — four nodes, so $N = 3$. Its nodal weights are $-12, 6, -6, 12$, whose
inverses clear to the profile $(-1, 2, -2, 1)$. The resulting minimal near miss is
$$\{1, 1, 4\} \quad \text{versus} \quad \{0, 3, 3\},$$
with three elements a side, beating the interval's four. A larger and more emphatic example
lives on the symmetric palette $A = \{0, 1, 4, 6, 9, 10\}$, where $N = 5$: the profile is
$(-1, 2, -3, 3, -2, 1)$ and the minimal near miss is
$$\{1, 1, 6, 6, 6, 10\} \quad \text{versus} \quad \{0, 4, 4, 4, 9, 9\}.$$
These two collections of six numbers each agree in count, sum ($30$), sum of squares ($210$),
sum of cubes ($1650$) and sum of fourth powers ($13890$), and separate only at fifth powers
($123330$ against $121170$). Six elements per side, against the interval's sixteen: the interval
loses by a factor of nearly three.

What is going on? Both winning palettes are *symmetric* — invariant under reflection about their
midpoint, $a \mapsto 4 - a$ and $a \mapsto 10 - a$ respectively — and both are unevenly spaced.
The nodal-weight law explains why that helps. Symmetry makes the profile palindromic, so no node
is wasted; uneven spacing makes the products $w(a)$ at the interior nodes *large*, and since the
multiplicities are proportional to $1/w(a)$, large weights mean small multiplicities. Packing the
values tightly into an interval does exactly the opposite: it minimises every product of
distances and therefore maximises the multiplicities you are forced to use.

The right question is therefore not "does the interval win?" — it does not — but "what does the
functional
$$m(A) \;=\; \tfrac{1}{2}\sum_{a \in A} \bigl| v(a) \bigr|, \qquad v \;=\; \text{primitive integer multiple of } 1/w,$$
actually minimise over palettes of a given size?" That is a clean, purely arithmetic extremal
problem about products of differences, and the answer — an old, hard, still-open question in
disguise — is exactly the Prouhet–Tarry–Escott problem itself.

## Where this lives in the wider world

Moment matching is everywhere, and so are near misses.

*Quadrature.* A numerical integration rule assigns weights to nodes so that polynomials up to
some degree are integrated exactly. The kernel of the truncated Vandermonde system is precisely
the space of weight adjustments that no low-degree test can detect; the nodal-weight law says
this space is one-dimensional and names its generator. That is the exact obstruction to
uniqueness of an interpolatory rule.

*Statistics and experimental design.* Two experimental designs that match on the first $N$
moments are indistinguishable by any linear statistic of degree below $N$. The universality
statement says something sharper: the *entire* difference between them, against every possible
statistic, is one number times the $N$-th finite difference — so all you can ever hope to
estimate about the difference is a single scalar.

*Signal processing.* The generating-function form, $\sum_{x\in s} q^x - \sum_{x\in t} q^x =
\lambda (1-q)^N$, says a near miss is a signal whose $z$-transform is a pure $N$-fold zero at
$q = 1$: the difference of the two sequences is annihilated by $N$ passes of the first-difference
filter, and nothing weaker.

*Number theory.* Restricted to distinct values, the search for near misses with more terms than
$N$ is the Prouhet–Tarry–Escott problem, open since the nineteenth century. The nodal-weight law
does not solve it, but it does something useful: it converts an existence question about pairs of
sets into an extremal question about a single explicit rational functional of the node set.

## The moral

There is a temptation to think of coincidences as accidents — that two lists agreeing on their
first few moments must be a fluke of arithmetic. The mathematics says the opposite. On a fixed
palette of $N+1$ values, agreement on the first $N$ moments is not a coincidence at all: it is a
one-dimensional linear condition, and its solution is written by a product of distances that you
can compute before you look at any data.

The coincidence you were hoping was rare turns out to be unique, forced, and fully described.
Pascal's triangle appears not as magic but as the special case where the palette is evenly
spaced. And the moment you let the palette breathe — spread the values out, make them symmetric
— the coincidences get cheaper, and you are staring straight at a two-hundred-year-old open
problem, now phrased as a single inequality about products of differences.
