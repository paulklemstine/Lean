# Counting the Tame Numbers: A Sieve, a Hypothesis, and the Shadow of the Primes

## A number's prime fingerprint

Every whole number bigger than $1$ carries a kind of genetic code: its prime
factorization. The number $12$ is $2 \times 2 \times 3$; the number $1000$ is
$2^3 \times 5^3$; and a number like $9991$ turns out to be $97 \times 103$. The
primes that appear in this code are the irreducible atoms from which the number
is built.

Among all these factorizations, mathematicians have long been fascinated by a
simple distinction. Some numbers are built entirely from *small* atoms. Take
$5040 = 2^4 \times 3^2 \times 5 \times 7$: its largest prime factor is a tiny
$7$, even though the number itself is in the thousands. Other numbers are
secretly dominated by a *large* atom: $9991$ looks unremarkable until you see
that it hides the prime $103$ inside.

We call a number **$y$-smooth** if *all* of its prime factors are at most $y$.
So $5040$ is $7$-smooth, while $9991$ is not even $100$-smooth. Smooth numbers
are the tame, well-behaved citizens of the integers. They show up everywhere
that matters: in the fastest known algorithms for factoring large numbers and
breaking cryptographic codes, in the analysis of how long computations take, and
in the deepest questions about how the primes are distributed.

The central question is deceptively easy to state:

> **How many $y$-smooth numbers are there up to a given bound $x$?**

Write $L(x, y)$ for this count — the number of integers $n$ with $1 \le n \le x$
whose prime factors are all $\le y$. If you can understand $L(x,y)$, you can
predict how often a random number will be "easy" in the sense that smooth
numbers are easy. This article tells the story of an elementary but surprisingly
sharp way to pin $L(x,y)$ down — a method built from one of the oldest ideas in
mathematics.

## The sieve of Eratosthenes, turned upside down

More than two thousand years ago, Eratosthenes of Cyrene described a procedure
for finding primes: write out the numbers, then cross out the multiples of $2$,
the multiples of $3$, the multiples of $5$, and so on. Whatever survives is
prime.

We are going to run this sieve, but with a twist. We don't want the primes — we
want the *smooth* numbers. So instead of crossing out multiples of every prime,
we only cross out multiples of the **large** primes, the ones strictly bigger
than our threshold $y$.

Here is the key observation. A number $n \le x$ fails to be $y$-smooth precisely
when it has at least one prime factor $p > y$. So if we strike out, for each
prime $p$ in the window $(y, x]$, all the multiples of $p$ that lie in
$(0, x]$, then everything we strike out is non-smooth, and everything that
survives is smooth.

How many multiples of a prime $p$ are there up to $x$? Exactly
$\lfloor x / p \rfloor$. So the total number of "strike-outs," counted with
repetition, is

$$\text{primeContribution}(x, y) \;=\; \sum_{\substack{y < p \le x \\ p \text{ prime}}} \left\lfloor \frac{x}{p} \right\rfloor.$$

Because a single number might be struck out more than once (if it has two large
prime factors), this sum *overcounts* the non-smooth numbers. The number we
actually remove is therefore no more than this sum. Subtracting from the total
$x$ gives a guaranteed lower bound on the survivors:

$$\boxed{\;x - \sum_{y < p \le x} \left\lfloor \frac{x}{p} \right\rfloor \;\le\; L(x, y).\;}$$

This is the **sieve lower bound**, and it holds with no assumptions whatsoever.
It is the entry point to everything that follows.

## When the bound is not a bound at all — it's an equality

Here is where the story takes an unexpected turn. When you actually compute both
sides for small examples, something striking happens. Consider:

- $x = 20$, $y = 5$: the smooth count is $L = 14$, and $x$ minus the sieve sum is
  also $14$.
- $x = 30$, $y = 4$: both sides equal $12$.
- $x = 100$, $y = 10$: both sides equal $46$.

The "lower bound" is not merely a bound — it lands *exactly* on the answer. Why?

The only way the sieve overcounts is when some number $n \le x$ gets struck out
twice, which requires $n$ to be divisible by two *different* large primes $p$ and
$q$, both bigger than $y$. But two distinct primes bigger than $y$ multiply to
something bigger than $y^2$. If $x$ is not too much larger than $y^2$, there's
simply no room: the product $pq$ already exceeds $x$, so no number up to $x$ can
carry two large primes. With nothing double-counted, the overcounting vanishes
and the inequality collapses to an equality:

$$L(x, y) \;=\; x - \sum_{y < p \le x} \left\lfloor \frac{x}{p} \right\rfloor
\qquad\text{whenever no } n \le x \text{ has two distinct prime factors} > y.$$

Concretely, this happens exactly when every pair of distinct primes $p, q$ in
the window $(y, x]$ satisfies $p \cdot q > x$. In the $x = 100$, $y = 10$
example, the relevant primes are $11, 13, 17, \dots, 97$, and the two smallest,
$11$ and $13$, already multiply to $143 > 100$. So the equality is forced.

When $x$ grows large compared to $y^2$, this clean equality breaks. Take
$x = 100$, $y = 5$: now $7 \times 11 = 77 \le 100$, so the number $77$ is struck
out twice — once for $7$, once for $11$. The sieve sum overcounts by exactly one,
and indeed $L(100, 5) = 34$ while the raw sieve bound gives only $32$.

This is not a defect; it's a signpost. It tells us precisely *when* the simple
formula is exact and *when* we need to work harder.

## Putting back what we took twice: the bracketing principle

The fix for the overcounting is itself ancient: **inclusion–exclusion**. If we
subtracted too much by removing $\lfloor x/p \rfloor$ for every large prime, we
can add back the numbers we removed twice — the multiples of products $pq$ of two
distinct large primes — to get a correction term

$$\sum_{\substack{y < p < q \le x}} \left\lfloor \frac{x}{pq} \right\rfloor.$$

A beautiful classical fact, the family of **Bonferroni inequalities**, says that
truncating inclusion–exclusion always errs in a predictable direction. Stopping
after the single-prime terms gives a lower bound for $L$; stopping after the
two-prime correction gives an *upper* bound. Together they trap the true count:

$$x - \sum_{p} \left\lfloor \frac{x}{p} \right\rfloor
\;\le\; L(x, y) \;\le\;
x - \sum_{p} \left\lfloor \frac{x}{p} \right\rfloor + \sum_{p < q} \left\lfloor \frac{x}{pq} \right\rfloor,$$

where all sums run over primes in $(y, x]$. For $x = 100$, $y = 5$, the lower
bracket is $32$ and the upper bracket is $34$, neatly straddling the true value
$L = 34$. The smooth count is pinned between two explicit, computable numbers.

## A hypothesis with a sharp payoff

So far everything has been unconditional — true with no leaps of faith. But the
real power of the sieve emerges when we feed it a single clean assumption about
how much the large primes can contribute.

Call it **Hypothesis U**. Fix a target $c$, the number of smooth survivors we
hope to guarantee. Hypothesis U for the triple $(x, y, c)$ is simply the
statement that the large-prime contribution leaves at least $c$ room:

$$\sum_{y < p \le x} \left\lfloor \frac{x}{p} \right\rfloor \;+\; c \;\le\; x.$$

In words: the primes above $y$ don't eat up more than $x - c$ of the integers.
The moment you grant this, the sieve lower bound hands you the conclusion with no
further work:

$$\text{Hypothesis U} \implies L(x, y) \;\ge\; c.$$

This is the crux of the conditional theory. The deep analytic content of
estimating smooth numbers gets quarantined into a single inequality about a sum
over primes — exactly the kind of statement that Mertens-type theorems and the
distribution of primes are designed to control. Verify Hypothesis U with the
target $c$ you want, and the lower bound on smooth numbers follows automatically.

## The mirror image: when smoothness is total

There is one more piece of the puzzle that ties the whole subject back to the
primes. Ask: when is *every* number up to $x$ smooth? That is, when does
$L(x, y) = x$, with no exceptions at all?

The answer is exact and elegant:

$$L(x, y) = x \quad\Longleftrightarrow\quad \text{there is no prime in the interval } (y, x].$$

If there's no large prime to spoil things, every integer up to $x$ is built only
from primes $\le y$, so all of them are smooth. Conversely, the very first prime
$p$ in $(y, x]$ is itself a non-smooth number $\le x$, breaking the saturation.

This little equivalence quietly connects our humble counting function to one of
the celebrated landmarks of number theory: **Bertrand's postulate**, which
guarantees a prime between $m$ and $2m$ for every $m \ge 1$. Apply it with
$m = y$: there is always a prime in $(y, 2y]$. That prime is a non-smooth number
no larger than $2y$, so the count must fall short of saturation:

$$L(2y, \, y) \;<\; 2y.$$

The smooth-number count has become a *detector* of primes. Whenever a prime
hides in an interval, $L$ feels its presence and dips below the maximum. Sharper
results about prime gaps — Nagura's theorem that a prime always lies in
$(y, \tfrac{6}{5}y]$ for $y \ge 25$, or the conjecturally tiny gaps of size
$y^{0.525}$ — would each translate directly into a sharper deficiency for $L$.

## Why any of this matters

Smooth numbers are not an idle curiosity. They are the secret engine behind the
algorithms that test the security of the internet. The fastest general-purpose
factoring methods — the quadratic sieve and the number field sieve — succeed
precisely because they manufacture and collect smooth numbers, and their running
time is governed by *how common* smooth numbers are. A reliable lower bound on
$L(x, y)$ is, quite literally, a guarantee that these algorithms will find the
raw material they need.

The same counting function controls the analysis of random number generators,
the theory of integer factorization records, and parts of cryptography that rely
on the *rarity* of smooth numbers for security. In each case, what you want is
not a vague asymptotic but a concrete, checkable bound: a promise that at least
so many smooth numbers exist below $x$. The sieve lower bound and its conditional
sharpening under Hypothesis U provide exactly that kind of promise.

## The shape of the argument

Step back and admire the architecture. We started with a two-thousand-year-old
idea — strike out multiples — and aimed it at the large primes instead of all
primes. That single move produced an unconditional lower bound for the count of
smooth numbers. Numerical experiments revealed that this bound is often an exact
equality, and a moment's thought explained *why*: there is simply no room for a
number to carry two large prime factors when $x$ is close to $y^2$. The error,
when it appears, is governed by the next layer of inclusion–exclusion, giving a
two-sided Bonferroni bracket. A single clean assumption, Hypothesis U, converts
the lower bound into any target density you can justify. And the saturation case
loops the whole story back to the primes themselves, turning $L$ into a
sensitive instrument for detecting prime gaps.

It is a small theory, but a complete one: elementary enough to compute by hand on
a slip of paper, sharp enough to be exact on the nose in a wide regime, and
flexible enough to absorb the hardest analytic input through a single hypothesis.
Two thousand years after Eratosthenes, his sieve is still teaching us how to
count.
