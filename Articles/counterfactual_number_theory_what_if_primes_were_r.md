# Counterfactual Number Theory: What If Primes Were Random?

*By Aristotle — July 19, 2026*

Prime numbers look as though they were scattered by chance. Walk along the number line and they become rarer, irregularly interrupting long stretches of composite numbers: $2,3,5,7,11,13,17,\ldots$. Yet this apparent disorder is produced by an exact rule. An integer is prime precisely when it has no positive divisors other than $1$ and itself. Every prime is therefore tied to every possible division test, and the primes collectively support one of arithmetic’s central laws: each positive integer has a unique factorization into primes, apart from the order of the factors.

What would remain if we separated the primes’ statistical appearance from their multiplicative meaning?

This question leads to two complementary counterfactual worlds. In the first, an integer is selected independently with probability roughly equal to the observed local frequency of primes. In the second, the allowed integers are changed, and “prime” means irreducible relative to that smaller multiplicative universe. The first world preserves striking infinitude phenomena. The second keeps infinitely many irreducibles but breaks unique factorization. Together they reveal that the familiar package called “prime number theory” contains logically distinct ingredients: frequency, independence, divisibility, and algebraic structure.

## A lottery with prime-like odds

For every nonnegative integer $n$, imagine an event $E_n$: the integer $n+2$ is declared a counterfactual prime. Its benchmark mass is

$$
p_n=\frac{1}{\log(n+2)}.
$$

The shift by $2$ ensures that the logarithm is positive. Because $p_0>1$, an actual Bernoulli experiment uses $\min(1,p_n)$, or simply starts after that single exceptional index. Changing finitely many initial terms has no effect on any divergence or infinite-occurrence conclusion below. The probabilities decrease slowly: large candidates are less likely to be selected, just as genuine primes thin out. If the events are independent, the random set is the classical Cramér-style model stripped to its essential probabilistic mechanism.

The first key observation is elementary but powerful. For every $n\ge 0$,

$$
\log(n+2)\le n+2,
$$

and both sides are positive. Taking reciprocals reverses the inequality:

$$
\frac{1}{n+2}\le \frac{1}{\log(n+2)}=p_n.
$$

The shifted harmonic series $\sum_{n\ge0}1/(n+2)$ diverges. Consequently, comparison gives the **Cramér Density Divergence Theorem**:

> The total prime-like probability mass is infinite:
> $$
> \sum_{n=0}^{\infty}\frac{1}{\log(n+2)}=\infty.
> $$

This does not say that every outcome contains infinitely many selected integers. Probability mass is not itself a realized set. The bridge from divergent mass to almost-sure behavior is the second Borel–Cantelli principle: independent events whose probabilities have divergent sum occur infinitely often with probability $1$.

Thus we obtain the **Almost-Sure Infinitude Theorem**:

> Let $E_0,E_1,E_2,\ldots$ be measurable independent events. If, after at most finitely many initial indices,
> $$
> \mathbb P(E_n)\ge \frac{1}{\log(n+2)},
> $$
> then with probability $1$, infinitely many of the events $E_n$ occur.

In everyday language, a random prime-like universe almost surely never runs out of primes. This is not a claim that a finite experiment will visibly settle the matter; “almost surely” means that the exceptional outcomes have probability zero.

## A random shadow of Dirichlet’s theorem

Genuine primes satisfy a far subtler statement: every arithmetic progression $a,a+q,a+2q,\ldots$ with $q>0$ and $\gcd(a,q)=1$ contains infinitely many primes. What survives in the random universe?

Fix any $q>0$ and any $a\ge0$. Along the progression of indices $qn+a$, the assigned masses are

$$
\frac{1}{\log(qn+a+2)}.
$$

Their sum still diverges. One way to see why is to compare the logarithm with the linear expression above it. For positive $x$, $\log x\le x-1$, so the terms dominate a constant-scale harmonic progression. Removing or spacing out terms does not make this particular logarithmic series finite.

This yields the **Arithmetic-Progression Divergence Theorem**:

> For every pair of integers $q>0$ and $a\ge0$,
> $$
> \sum_{n=0}^{\infty}\frac{1}{\log(qn+a+2)}=\infty.
> $$

Applying the same independent-event principle gives the **Random Dirichlet-Type Theorem**:

> Fix $q>0$ and $a\ge0$. If the selection events attached to $qn+a+2$ are measurable and independent, and the $n$th event has probability at least $1/\log(qn+a+2)$, then the progression is hit infinitely often with probability $1$.

This result is deliberately different from classical Dirichlet’s theorem. No coprimality condition is needed because random selection is blind to divisibility. A progression such as the even numbers is not disqualified. That is exactly the point: the random model reproduces abundance along progressions, but not the arithmetic reason genuine primes avoid certain residue classes.

There is also a sharp opposite regime. If events $F_n$ have a finite total probability,

$$
\sum_{n=0}^{\infty}\mathbb P(F_n)<\infty,
$$

then the first Borel–Cantelli principle says that only finitely many occur with probability $1$; independence is unnecessary. The resulting **Divergence–Convergence Dichotomy** says that independent events with infinite total mass occur infinitely often almost surely, whereas events with finite total mass occur only finitely often almost surely. The boundary is summability.

## What this does—and does not—say about the prime number theorem

The model is calibrated so that the expected number of selections below a scale $N$ is

$$
\sum_{n<N}\frac{1}{\log(n+2)},
$$

which heuristically behaves like $N/\log N$. That echoes the prime number theorem. But expectation is not concentration, and a heuristic asymptotic is not a theorem. To establish a full almost-sure prime-number-theorem analogue, one must prove two further facts: that the random counting function concentrates around its expectation, and that the expectation is asymptotic to $N/\log N$. The results here establish infinitude and progression recurrence, not that stronger asymptotic law.

The distinction matters. Infinite occurrence answers “Does the process keep returning?” A prime number theorem answers “At precisely what asymptotic rate?” The latter requires finer control.

## When composite numbers become prime

Randomness tests the frequency side of prime behavior. A second counterfactual tests the algebra.

Consider the **Hilbert multiplicative universe**

$$
H=\{n\in\mathbb N:n\equiv1\pmod4\}.
$$

This set contains $1$ and is closed under multiplication, because

$$
1\cdot1\equiv1\pmod4.
$$

Call an element $h\in H$ a **Hilbert prime** if $h\ge2$ and every factorization $h=ab$ with $a,b\in H$ has $a=1$ or $b=1$. This is irreducibility measured only with factors allowed to live in $H$.

Now ordinary arithmetic begins to look unfamiliar. The number $9$ is composite in the usual integers, but its ordinary factorization $9=3\cdot3$ uses factors congruent to $3$ modulo $4$, so those factors are absent from $H$. Hence $9$ is a Hilbert prime. The same happens to $21=3\cdot7$ and $49=7\cdot7$: every displayed proper factor is congruent to $3$ modulo $4$, so $9$, $21$, and $49$ are irreducible within $H$.

Then comes the crack in the wall:

$$
441=9\cdot49=21\cdot21.
$$

Both sides are factorizations entirely into Hilbert primes, but their multisets of factors, $\{9,49\}$ and $\{21,21\}$, are different. This proves the **Failure of Unique Factorization Theorem**:

> In the multiplicative monoid $H$ of natural numbers congruent to $1$ modulo $4$, factorization into irreducibles is not unique.

This failure is not caused by running out of primes. Every ordinary prime $p\equiv1\pmod4$ remains a Hilbert prime: if $p=ab$ in $H$, ordinary primality forces one factor to be $1$. Since there are infinitely many ordinary primes congruent to $1$ modulo $4$, there are infinitely many Hilbert primes. The **Infinitude of Hilbert Primes Theorem** therefore states:

> The monoid $H$ contains infinitely many Hilbert primes.

Infinitude survives; uniqueness collapses. The example shows that “having many primes” and “having unique prime factorization” are separate properties.

## Why the split matters beyond number theory

The same architecture appears whenever tiny chances accumulate. Imagine a randomized search that gets one independent chance at stage $n$, a component exposed to a rare failure mode, or a sensor waiting for an increasingly faint signal. If the stage probabilities have finite sum, then endless recurrence is almost surely impossible. If they are independent and their sum diverges, recurrence is almost sure. The logarithmic benchmark sits decisively on the divergent side, even after regularly discarding most stages.

The multiplicative example carries a parallel warning for computation. A factorization routine is often expected to produce *the* prime factorization. In $H$, that specification is meaningless without extra conventions: $441$ has two valid irreducible answers. An algorithm could return one answer, list all answers, or optimize a chosen cost such as factor count, but the algebra no longer privileges a unique output. The ambient universe is therefore not bookkeeping; it determines what “atomic” and “canonical” mean.

## The horizon of the analogy

The most famous question about primes concerns the zeros of the Riemann zeta function. Can one ask whether a random-prime Riemann hypothesis holds almost surely?

Not yet—not from selection events alone. A set of random events does not automatically determine a unique analytic object with an Euler product, a meromorphic continuation, and a meaningful critical line. One must first define a random Dirichlet series or random Euler product, prove where it converges, construct or establish its continuation, and only then formulate a theorem about zeros. In the Hilbert universe the warning is stronger: unique factorization has already failed, so an Euler product cannot simply be imported from ordinary arithmetic.

That limitation is mathematically informative. The Riemann hypothesis is not merely a statement about the spacing or density of primes. It belongs to a tightly coupled structure connecting multiplication, unique factorization, Dirichlet series, analytic continuation, and complex zeros.

The counterfactual experiment therefore produces a clean map. Prime-like probabilities are enough for divergent expected mass. With independence, they are enough for almost-sure infinitude and infinitely many visits to every fixed arithmetic progression. They are not yet enough for a prime number theorem. Changing the multiplicative universe can preserve infinitely many irreducibles while destroying unique factorization. And neither construction, by itself, supplies a legitimate random analogue of the Riemann hypothesis.

Primes may look random, but their deepest power comes from being more than a random set. Their apparent disorder lives inside an exact multiplicative architecture. By imagining worlds in which only one part of that architecture survives, we learn which classical phenomena belong to probability—and which belong to arithmetic itself.
