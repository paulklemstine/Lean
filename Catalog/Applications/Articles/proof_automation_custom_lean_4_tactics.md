# The Coefficient That Counts Primes

## A number from Pascal's triangle that knows where the primes live

Pick a row deep inside Pascal's triangle — say row number $2n$ — and look at the
single number sitting right in the middle. Mathematicians call it the *central
binomial coefficient*, written $\binom{2n}{n}$. The first few values are

$$\binom{0}{0}=1,\quad \binom{2}{1}=2,\quad \binom{4}{2}=6,\quad \binom{6}{3}=20,\quad \binom{8}{4}=70,\quad \binom{10}{5}=252.$$

At first glance these are just the counts of how many ways you can choose $n$
objects from $2n$. But hidden inside this innocent counting number is a secret
census of the prime numbers. Every prime that lies strictly between $n$ and $2n$
divides $\binom{2n}{n}$ — and divides it *exactly once*, never twice. Because of
this, the middle of Pascal's triangle becomes a kind of prime-detector: it is big
enough to swallow all those primes as factors, yet small enough that it cannot
hide too many of them. Squeeze that idea hard enough and out falls one of the
oldest quantitative facts about prime numbers: **the primes thin out, and they do
so at a controllable rate.**

This article tells the story of that bridge — from a number you can compute by
hand in Pascal's triangle to a genuine theorem about the distribution of primes.
It is a journey across two countries of mathematics that rarely share a border:
*combinatorics*, the art of counting arrangements, and *analytic number theory*,
the study of how primes are spread along the number line. The traveler that
carries us across is a 200-year-old gem called Legendre's formula.

## How many times does a prime divide a factorial?

The factorial $n! = 1\cdot 2\cdot 3\cdots n$ grows monstrously fast, and its prime
factorization is a tangle. Yet there is a beautifully clean way to count how many
times a single prime $p$ appears in it. Adrien-Marie Legendre found it around
1808.

Write $n$ in base $p$ and add up its digits; call that digit sum $s_p(n)$. For
example, in base $3$ the number $n=8$ is written $22$, so $s_3(8)=2+2=4$.
Legendre's formula says that the exponent of $p$ in $n!$ — the number of times
$p$ divides it, which we write $v_p(n!)$ — satisfies the strikingly simple
identity

$$(p-1)\cdot v_p(n!) = n - s_p(n).$$

In words: take the number, subtract its base-$p$ digit sum, and divide by $p-1$.
That is exactly how many factors of $p$ are buried inside $n!$. There is no
guesswork, no estimation — it is an exact equality. This is the first theorem in
our formal development, and everything else is built on it.

## The central coefficient, decoded

Now we apply Legendre's formula three times. The central binomial coefficient is

$$\binom{2n}{n} = \frac{(2n)!}{n!\,\cdot\,n!}.$$

A prime $p$ divides the top a certain number of times and the bottom a certain
number of times; the difference is how many times $p$ divides $\binom{2n}{n}$.
Feeding Legendre's formula into each factorial and simplifying, we obtain a clean
"digit-sum" description of the valuation of the central coefficient:

$$(p-1)\cdot v_p\!\left(\binom{2n}{n}\right) = s_p(n) + s_p(n) - s_p(2n),$$

or equivalently, dividing through,

$$v_p\!\left(\binom{2n}{n}\right) = \frac{2\,s_p(n) - s_p(2n)}{p-1}.$$

This little formula is the engine of the whole story. It converts a question
about divisibility — *how many times does this prime go into this giant number?* —
into a question about adding up the digits of $n$ and $2n$ in base $p$. Digit
sums are concrete, finite, and easy to reason about. The mystery has become
arithmetic.

## The "exactly once" miracle

Here is where the magic happens. Suppose $p$ is a prime sitting in the upper half
of the interval, so that

$$n < p \le 2n.$$

In base $p$, the number $n$ is then a *single digit* — because $n$ is smaller
than $p$, it is just written as "$n$" with no carrying. So $s_p(n) = n$. And
$2n$, being between $p$ and $2p$, is written with exactly two digits: a leading
$1$ and a remainder, giving $s_p(2n) = 1 + (2n - p)$.

Plug these into the digit-sum formula:

$$(p-1)\cdot v_p\!\left(\binom{2n}{n}\right) = n + n - \bigl(1 + 2n - p\bigr) = p - 1.$$

Divide both sides by $p-1$ and you get the punchline:

$$v_p\!\left(\binom{2n}{n}\right) = 1.$$

**Every prime strictly between $n$ and $2n$ divides the central binomial
coefficient exactly once — no more, no less.** This is the result our formal
development calls the "valuation equals one" theorem, and it is the keystone of
the bridge. An immediate consequence is that the *product* of all those primes
divides $\binom{2n}{n}$:

$$\left(\prod_{n < p \le 2n} p\right)\ \Big|\ \binom{2n}{n}.$$

Because each prime appears to the first power and the primes are distinct, their
product divides the coefficient cleanly. We have turned the central coefficient
into a container holding every prime in the upper half-interval.

## How big is the container?

A container's contents cannot be larger than the container itself. So if we know
how big $\binom{2n}{n}$ is, we know how large the product of primes can be. The
size of the central coefficient is pinned down by two complementary bounds that we
prove formally.

The **lower bound** comes from the fact that $\binom{2n}{n}$ is the largest of the
$2n+1$ entries in row $2n$ of Pascal's triangle, and those entries add up to
$4^n$. Sharing $4^n$ among $2n+1$ entries, the biggest one is at least the
average:

$$4^n \le (2n+1)\binom{2n}{n}.$$

The **upper bound** is subtler and is where we had to correct the historical
record. A widely-quoted estimate claims $\binom{2n}{n} \le 4^n/(2\sqrt{n})$. This
is simply false: at $n=2$ it would say $6 \le 16/(2\sqrt 2) = 5.65\ldots$, which is
not true. The correct, provable statement is

$$\binom{2n}{n} \le \frac{4^n}{\sqrt{2n}},$$

and indeed $4^n/(2\sqrt n)$ turns out to be a *lower* bound, not an upper one. We
prove the correct inequality, anchored by the clean integer identity

$$(3n+1)\binom{2n}{n}^2 \le 16^n.$$

Getting this detail right matters: a single mis-stated constant can quietly
poison every estimate downstream. Formal verification is unforgiving about such
things, and that is precisely its value — it refuses to let a plausible-looking
falsehood slip through.

## Crossing the bridge: primes thin out

Now we assemble the pieces into the destination theorem. Define the *primorial*
of $n$, written $n\#$, as the product of all primes up to $n$:

$$n\# = \prod_{p \le n} p.$$

For example $5\# = 2\cdot 3\cdot 5 = 30$ and $10\# = 2\cdot3\cdot5\cdot7 = 210$.
The claim — a Chebyshev-type bound first proved by this elegant route by Paul
Erdős as a teenager — is

$$\prod_{p \le n} p < 4^n \qquad \text{for all } n \ge 1.$$

The proof is a graceful induction. Even numbers above $2$ are not prime, so
$n\#$ does not change when $n$ steps from an odd number to the next even one;
that case is free. The interesting case is an odd number $2m+1$. Split the primes
up to $2m+1$ into two groups: those at most $m+1$, and those in the upper
interval $(m+1,\,2m+1]$.

For the small group, induction already gives $(m+1)\# < 4^{m+1}$.

For the large group, every one of those primes divides $\binom{2m+1}{m}$ exactly
once — the same "exactly once" miracle as before — so their product is at most
$\binom{2m+1}{m}$, which is at most $4^m$ (it is one of two equal middle entries
in row $2m+1$, whose total is $4^{m+\frac12}\cdot\ldots$; the clean bound is
$\binom{2m+1}{m}\le 4^m$).

Multiplying the two groups:

$$(2m+1)\# \;<\; 4^{m+1}\cdot 4^{m} \;=\; 4^{2m+1}.$$

The induction closes, and the theorem stands. From a number in Pascal's triangle,
we have deduced that the primes up to $n$ multiply together to less than $4^n$ —
a hard quantitative limit on how dense the primes can be.

## Why this matters

This single inequality, $\prod_{p\le n} p < 4^n$, is the beating heart of
Chebyshev's theorem, which states that the number of primes below $x$ is
sandwiched between two constant multiples of $x/\ln x$. It was the first real
evidence, decades before the Prime Number Theorem was proved, that the primes
obey a precise statistical law rather than scattering randomly. And it descends
directly from elementary facts about binomial coefficients — no complex analysis,
no Riemann zeta function, just digit sums and counting.

That is the deeper lesson of the bridge. The boundaries we draw between
"combinatorics" and "number theory," between "elementary" and "analytic," are
conveniences, not laws of nature. A theorem about how to choose $n$ things from
$2n$ is, when read correctly, a theorem about the architecture of the primes.
Legendre's formula is the dictionary that translates between the two languages,
and the central binomial coefficient is the sentence that says the same thing in
both.

## A note on certainty

Every statement in this article — Legendre's formula, the digit-sum valuation,
the "exactly once" theorem, the corrected size bounds, and the final primorial
inequality — has been checked down to its logical atoms. The corrected upper
bound is a small but real example of why that checking is worth doing: an
appealing formula that "everyone knows" turned out to be wrong by a constant, and
only a rigorous accounting caught it. Mathematics has always prized certainty;
here we have certainty that a machine has audited and found complete.

The middle of Pascal's triangle has been staring at us for centuries. It turns
out it was counting primes the whole time.
