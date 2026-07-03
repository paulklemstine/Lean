# The Perfect Ruler: How Many Marks Can You Fit Without a Repeat?

Imagine you are designing a ruler — but a strange one. Instead of caring
about the positions of the marks, you care about the *distances between
them*. You want every pair of marks to be separated by a different amount.
No two gaps the same. If the mark at $3$ and the mark at $7$ are four units
apart, then no other pair anywhere on the ruler is allowed to be four units
apart. How many marks can you crowd onto a ruler of a given length before
you are forced to repeat a distance?

This innocent-sounding puzzle is one of the oldest and most stubborn
questions in a field called *additive combinatorics*, and it turns out to
touch everything from radio antenna design to error-correcting codes to the
architecture of modern signal processing. The special sets that solve it —
sets of integers with all distinct pairwise differences — are called
**Sidon sets**, after the Hungarian analyst Simon Sidon, who first ran into
them in the 1930s while studying the harmonics of musical tones.

## The rule of the game

Let us be precise about the "no repeated distance" rule, because the precise
version has a pleasant twist. A set of integers is called a **Sidon set** if
all of its pairwise *sums* are distinct: whenever $a + b = c + d$ with all
four drawn from the set, the pair $\{a, b\}$ must be the same as the pair
$\{c, d\}$. It is a small but delightful exercise to check that this is
*exactly the same* as demanding that all pairwise *differences* be distinct.
If two different pairs shared a difference, they would also share a sum, and
vice versa. So "no repeated distance" and "no repeated sum" are two faces of
the same coin.

The central object of study is a counting function. Fix a window of the
whole numbers, say $\{1, 2, \dots, N\}$, and ask: what is the largest Sidon
set that fits inside it? Call that maximum size $F(N)$. Everything in this
story is about understanding how $F(N)$ grows as the window widens.

Two questions immediately present themselves. First, an **upper bound**: no
matter how cleverly you place your marks, you *cannot* exceed a certain
number. Second, a **lower bound**: you can always *achieve* at least a
certain number. The truth lives in the sandwich between them.

## The counting trick that caps the ruler

Here is the elegant argument that bounds $F(N)$ from above, and it fits in a
paragraph. Take any Sidon set $S$ sitting inside $\{1, \dots, N\}$. Look at
all *ordered pairs* of distinct elements $(a, b)$ and form the difference
$a - b$. Because $S$ is Sidon, these differences are all distinct — that is
the whole point. So the map $(a, b) \mapsto a - b$ is one-to-one on the set
of ordered pairs.

Now count both sides. On the one hand, if $S$ has $m$ elements, there are
exactly $m(m-1)$ ordered pairs of distinct elements. On the other hand,
every difference $a - b$ is a nonzero integer whose absolute value is at
most $N - 1$ (since all elements lie between $1$ and $N$). That leaves only
$2(N-1)$ possible values for the difference: the numbers from $-(N-1)$ up to
$N-1$, excluding zero. A one-to-one map cannot squeeze more inputs than
there are outputs, so

$$ m(m-1) \le 2(N-1). $$

That single inequality is the engine of the entire subject. Rearranging it —
solving the quadratic and keeping the positive root — gives the clean,
memorable ceiling

$$ F(N) \le \sqrt{2N} + 1. $$

In words: a Sidon set inside a window of length $N$ can have at most about
$\sqrt{2N}$ elements. The number of marks grows only like the *square root*
of the ruler's length. Double the length and you gain only about a factor of
$\sqrt{2} \approx 1.41$ more marks. The distinct-difference rule is
punishingly expensive.

## Do such rich rulers even exist?

An upper bound alone is a hollow victory. It would be a cruel joke if the
"maximum Sidon set" were always tiny — if, say, you could never fit more
than five marks no matter how long the ruler. Then the ceiling
$\sqrt{2N} + 1$ would be technically true but utterly pointless. To make the
problem *genuine*, we need to show that large Sidon sets actually exist —
that $F(N)$ really does climb without limit as $N$ grows.

There is a beautifully cheap way to see this, and it uses the most familiar
sequence in all of computing: the **powers of two**. Consider the set

$$ \{2^0, 2^1, 2^2, \dots, 2^{k-1}\} = \{1, 2, 4, 8, \dots\}. $$

Claim: this is always a Sidon set, for every $k$. Why? Because a sum of two
powers of two is nothing more than a binary number with (at most) two bits
turned on, and *binary representations are unique*. If $2^a + 2^b = 2^c +
2^d$, then the two sides are the same integer, so they have the same binary
expansion, so the same bits are switched on — which forces the exponents to
match up. There is exactly one subtle case to rule out, the "carry" case
where two equal powers combine, as in $2^a + 2^a = 2^{a+1}$. But this never
collides with a genuinely distinct pair, because a true two-bit number like
$2^c + 2^d$ (with $c \ne d$) is a sum of an *odd* factor and a power of two
in a way that a single power $2^{a+1}$ can never mimic. The clean way to see
all of this at once is through the **$2$-adic valuation** — the number of
times $2$ divides an integer. Writing $2^a + 2^b = 2^{\min(a,b)}\bigl(1 +
2^{|a-b|}\bigr)$ exposes the power of two dividing the sum, and matching
these across the equation pins the exponents down completely.

So the powers of two give us, for free and with no heavy machinery, a Sidon
set of *any* size we like. For every $k$, there is a Sidon set with exactly
$k$ elements. The extremal function $F(N)$ is therefore genuinely unbounded:
it is a real, nontrivial object, not a mirage.

## The gap between what we can build and what we cannot exceed

Now the plot thickens. The powers of two are a *cheap* certificate, but a
*wasteful* one. To fit the $k$ powers $\{1, 2, 4, \dots, 2^{k-1}\}$, you need
a window stretching all the way out to $N = 2^{k-1}$. That means this family
only proves $F(N) \gtrsim \log_2 N$ — a logarithmic lower bound. Our ceiling,
meanwhile, was $\sqrt{2N}$. Between $\log_2 N$ and $\sqrt{2N}$ lies an
enormous chasm.

Which end is closer to the truth? Remarkably, it is the *upper* end. Deeper
constructions — using the arithmetic of prime fields and perfect difference
sets, ideas going back to James Singer and to Paul Erdős and Pál Turán in
the 1940s — build Sidon sets whose size genuinely reaches the order of
$\sqrt{N}$. A representative recipe: for a prime $p$, the numbers of the form
$2p\,i + (i^2 \bmod p)$ for $i = 0, 1, \dots, p-1$ form a Sidon set living
inside a window of length about $2p^2$, delivering roughly $\sqrt{N/2}$
marks. The trick is that squaring *linearizes* the distinctness condition:
two pairs of marks can only collide if a certain symmetric quadratic
congruence has a solution, and modular arithmetic forbids exactly those
solutions. The rigid combinatorial demand melts into a solvable equation.

So the true growth rate of $F(N)$ is $\sqrt{N}$, and the fight narrows to the
*constant* out front and the *finer corrections*. This is where the story
becomes modern.

## Chasing the second digit

Erdős and Turán proved that the leading behavior is exactly $F(N) =
N^{1/2}(1 + o(1))$, and refined the ceiling to the shape

$$ F(N) \le N^{1/2} + \gamma \cdot N^{1/4} + O(1). $$

The leading term $N^{1/2}$ is settled. The battleground is $\gamma$, the
coefficient of the *second* term $N^{1/4}$ — the correction that says how the
count deviates from a perfect square root. Shaving down $\gamma$ has occupied
combinatorialists for decades, each improvement squeezing out another sliver.

The most powerful modern approach reframes the whole problem in the language
of *signal processing*. Instead of counting differences one at a time — which,
as it happens, structurally traps the elementary method at the constant
$\sqrt{2}$ and can never do better — one slides a smoothing **convolution
kernel** across the difference distribution and averages. The genius is to use
not a single kernel but a whole *family of vector-valued kernels* and to take
a weighted average of the inequalities they each satisfy. Optimizing the
weights turns an infinite analytic search into a finite, concrete
optimization problem: a linear program whose solution certifies the best
possible constant. The conjectured optimum reachable by this method is a
specific, almost eerily precise number,

$$ \gamma_0 \approx 0.94601, $$

and part of what makes it beautiful is that it is not a limit you sneak up on
but the exact saddle point of a checkable, finite optimization — a duality
between the inequalities the kernels must obey and the weighting that
certifies the bound.

## Why anyone should care

It would be easy to file this under "recreational number theory," but Sidon
sets are quietly load-bearing across the sciences. Because their differences
are all distinct, they make ideal **frequency plans** for radar and radio: if
you place transmitters or receiving antennas at Sidon-set positions, no two
baselines coincide, which maximizes the resolution of the combined array.
The same "no coincidental spacing" property makes Sidon sets natural
building blocks for **error-correcting codes** and for the pseudo-random
sequences used to spread signals in communication systems. In machine
learning and high-dimensional signal processing, the convolution-kernel
optimization at the heart of the modern bound is a cousin of the very
techniques used to design filters and pooling operations — averaging a family
of local operators to extract a sharp global estimate is precisely the move
that makes these bounds, and much of modern signal processing, work.

At its core, the Sidon problem is a parable about *information*. Each
distinct difference is a distinct fact, and a Sidon set is a configuration
that packs the maximum number of non-redundant facts into a fixed space.
The square-root law is the price of non-redundancy; the constant $\gamma$ is
the fine print. That such a homely question — how many marks fit on a ruler
with no repeated gap — should lead through binary arithmetic, prime fields,
$2$-adic valuations, and convolution kernels tells you something about how
mathematics is stitched together: pull on one loose thread and the whole
fabric moves.

## The state of play

Let us collect what we can say with certainty. The distinct-difference rule
forces a square-root ceiling: any Sidon set in $\{1, \dots, N\}$ has at most
$\sqrt{2N} + 1$ elements, a fact that follows from nothing more than counting
ordered pairs against the window of possible differences. And the ceiling is
not vacuous: the powers of two supply an explicit Sidon set of every size,
proving the extremal function climbs without bound, while deeper quadratic
constructions push the lower bound all the way up to the order of $\sqrt{N}$,
matching the ceiling's shape. What remains — the chase after the exact
constant $\gamma_0 \approx 0.94601$ through the optimization of vector-valued
convolution kernels — is the frontier where the elementary counting argument
hands the baton to modern analysis.

The perfect ruler, it turns out, has room for about $\sqrt{N}$ marks. Getting
the *next* digit of that estimate is a story still being written.
