# Counterfactual Number Theory: What If Primes Were Random?

## A coin for every number

Imagine you are handed an infinite ledger, one line for every whole number:
2, 3, 4, 5, 6, and on forever. Your job is to decide, line by line, which
numbers are "prime." But instead of testing for divisors the way Euclid
taught us, you flip a weighted coin. For the number *n*, the coin comes up
"prime" with probability exactly **1 / log n**, and "composite" otherwise.

That is the entire rule. No factoring, no sieving, no divisibility — just a
cascade of independent coin flips, each one a little less likely to land on
"prime" as the numbers grow, because the logarithm in the denominator
slowly creeps upward.

This game is not a parlor trick. It is one of the most influential ideas in
twentieth-century number theory, introduced by the Swedish mathematician
Harald Cramér in 1936. Cramér's insight was audacious: *pretend the primes
are random*, with each integer independently "prime" with probability
1 / log n, and then ask what such a random universe would look like. If the
random universe behaves like the real primes, then we have a powerful
heuristic engine — a way to guess the answers to questions that are
otherwise impossibly hard. And if the random universe disagrees with the
real primes, the disagreement itself is a fingerprint of the deep,
non-random structure hiding inside the integers.

This article is about a counterfactual: a parallel number theory in which
the primes really are produced by Cramér's coins. We will ask which of the
great theorems of number theory survive the switch to randomness, and which
ones collapse. Along the way we will pin down, with complete rigor, the
single most important quantity in the whole model — the *expected number of
primes up to N* — and prove that it grows at exactly the rate the real
prime-counting function does.

## Why log n? The fingerprint of the Prime Number Theorem

Before we play the game, we should ask where the magic number 1 / log n
comes from. It is not arbitrary. It is borrowed directly from the single
most celebrated fact about the real primes: the **Prime Number Theorem**.

The Prime Number Theorem, proved in 1896, says that the number of primes
less than or equal to *N* — written π(*N*) — is approximately *N* / log *N*.
Equivalently, if you pick a random integer near *N*, the "chance" that it
is prime is about 1 / log *N*. Cramér simply took this average density and
promoted it to a literal probability for each individual integer. The genius
is that a statement about *averages* becomes a generator of *individual*
random events, and from those events we can compute everything else.

So the model is calibrated, by construction, to reproduce the prime density.
The real question is whether it reproduces the finer texture: the gaps
between primes, the twin primes, the distribution across arithmetic
progressions, and the mysteries surrounding the Riemann Hypothesis.

## The central quantity: how many primes should there be?

Let us make the first calculation that anyone playing Cramér's game must
make. Suppose we have flipped the coins for every integer from 2 up to *N*.
How many "primes" should we expect to see?

Each integer *n* contributes a coin that lands "prime" with probability
1 / log *n*. The expected value of a single coin flip is just its
probability. And the expected value of a sum of coin flips — even dependent
ones, though here they are independent — is the sum of the individual
expectations. This is the *linearity of expectation*, one of the most
quietly powerful facts in all of mathematics. So the expected number of
model primes up to *N* is simply the running total of the probabilities:

> **The Cramér expectation sum.**
> The expected number of random primes in the window from 2 to *N* is
> $$ \mathrm{CramerSum}(N) \;=\; \sum_{n=2}^{N} \frac{1}{\log n}. $$

This finite sum is the deterministic skeleton of the entire random model.
It is the model's prediction for π(*N*), the prime-counting function. Every
other quantity in the theory — twin-prime counts, gap statistics, residue
distributions — is built from sums and products of the same probabilities,
and the behavior of this one sum controls them all. So we should understand
it completely, and we do. Here is what is provably true about it.

## What we can prove, exactly

The beauty of the Cramér model is that its backbone requires no probability
theory at all once the expectations are written down — it reduces to clean,
honest real analysis about the function 1 / log *x*. Here are the results,
each one fully proved and machine-verified.

**1. The terms are positive.** For every integer *n* ≥ 2, the logarithm
log *n* is strictly positive (because *n* > 1), so each probability
1 / log *n* is a genuine, strictly positive number. There are no degenerate
or negative "probabilities" lurking in the sum.

**2. The probabilities decrease.** The function *x* ↦ 1 / log *x* is
*antitone* — strictly decreasing — on the interval (1, ∞). Intuitively, as
numbers get bigger, the logarithm in the denominator grows, so the chance of
being prime steadily drops. Concretely, if 3 ≤ *m* ≤ *n*, then
1 / log *n* ≤ 1 / log *m*. Primes thin out, exactly as they do in reality.

**3. The expected count only grows.** The sum CramerSum(*N*) is monotone in
*N*: enlarging the window from *N* to *M* ≥ *N* can only add more
nonnegative terms, so CramerSum(*N*) ≤ CramerSum(*M*). The expected number
of primes never decreases as we look farther out — an obvious-sounding fact
that is nonetheless the foundation for comparing the model against the true
π(*N*), which is also nondecreasing.

**4. The sum is trapped between two integrals.** This is the heart of the
matter. A sum of values of a decreasing function can be compared to the area
under that function's curve — the classic "Riemann sum" sandwich. We prove
both halves of the sandwich:

> **Lower bound (right-Riemann comparison).** For *N* ≥ 3,
> $$ \int_{2}^{N+1} \frac{dx}{\log x} \;\le\; \mathrm{CramerSum}(N). $$

> **Upper bound (left-Riemann comparison).** For *N* ≥ 3,
> $$ \mathrm{CramerSum}(N) \;\le\; \frac{1}{\log 2} + \int_{2}^{N} \frac{dx}{\log x}. $$

The integral that appears here, ∫ dx / log x, is famous in its own right: it
is (essentially) the **logarithmic integral** Li(*N*), the single best
elementary approximation to π(*N*) known to mathematics. The fact that our
random model's expectation is sandwiched between two copies of the
logarithmic integral, differing only by a bounded constant, is a
quantitative statement that **the Cramér model predicts π(N) ≈ Li(N)** — the
refined form of the Prime Number Theorem, recovered from coin flips.

A subtle technical point makes this honest. One might want to compare the
sum to the integral starting at *x* = 1, but 1 / log *x* blows up to
infinity as *x* approaches 1 (since log 1 = 0). So the naive integral over
[1, N] does not even exist. We sidestep the singularity by isolating the
very first term, 1 / log 2, and integrating only over the safe range
[2, N] where the integrand is perfectly tame. This is exactly the kind of
careful bookkeeping that separates a heuristic from a theorem.

**5. The growth rate is N / log N — the Prime Number Theorem order.** Even
without invoking the integral, we can prove the model grows at the right
speed by a wonderfully crude argument. Every one of the roughly *N* terms in
the sum is at least as big as the smallest one, 1 / log *N* (since the terms
decrease). So:

> **Crude count bound.** For *N* ≥ 2,
> $$ \frac{N-1}{\log N} \;\le\; \mathrm{CramerSum}(N). $$

> **Explicit scale lower bound.** For *N* ≥ 2,
> $$ \frac{N}{2\log N} \;\le\; \mathrm{CramerSum}(N). $$

The number *N* / (2 log *N*) is, up to the harmless factor of 2, exactly the
Prime Number Theorem estimate *N* / log *N*. So with nothing more than the
observation that a decreasing sequence is bounded below by its last term, we
have recovered the *order of growth* of the primes inside the random
universe. No analytic machinery, no contour integrals, no zeta function —
just counting.

## Which theorems survive, and which collapse

Now we come to the philosophical payoff. With the backbone in place, we can
classify the great theorems of number theory by whether they survive the
jump into Cramér's random world.

**The Prime Number Theorem: survives.** As we just saw, the expected count
grows like *N* / log *N* and is pinned to the logarithmic integral. The PNT
is fundamentally a *density* statement, and density is exactly what the
model is calibrated to. It survives — in fact, it survives almost by
definition, which is the whole point of choosing 1 / log *n* as the
probability.

**Dirichlet's theorem on primes in arithmetic progressions: survives.**
Dirichlet proved that any arithmetic progression *a*, *a* + *q*,
*a* + 2*q*, … with *a* and *q* sharing no common factor contains infinitely
many primes. In the Cramér model, the coins are blind to arithmetic
structure — the probability 1 / log *n* does not care whether *n* is even,
or one more than a multiple of seven. So *every* residue class receives its
proportional share of random primes, and each unbounded class collects
infinitely many of them almost surely. Dirichlet survives, and in fact the
model predicts *perfect* equidistribution with no bias between classes.

**Unique factorization: collapses — completely.** This is the dramatic
casualty. The Fundamental Theorem of Arithmetic says every integer factors
into primes in exactly one way. But the Cramér primes are just a random
subset of the integers; they have no multiplicative meaning whatsoever. The
number 12 is not "2 × 2 × 3" in this universe, because "2" and "3" are
random labels, not building blocks. There is no operation under which the
random primes generate the integers. Multiplicative structure — the very
soul of classical number theory — is gone. The model knows about *how many*
primes there are and *where* they sit on the number line, but nothing about
*why* they are prime. This is the model's great blind spot, and recognizing
it is essential to using the model wisely.

**The Riemann Hypothesis: holds almost surely.** Here is the most tantalizing
result of the whole program, and one of Cramér's original motivations. The
Riemann Hypothesis, in its number-theoretic form, is equivalent to a sharp
bound on the *error* between π(*N*) and Li(*N*): the error should be no
larger than about √*N* · log *N*. In the random model, the error is a sum of
independent mean-zero fluctuations, and the law of large numbers (more
precisely, results on sums of independent random variables) forces that
error to be of size roughly √*N*, with logarithmic corrections — comfortably
within the Riemann bound. The upshot, established by Cramér himself, is that
**the Riemann Hypothesis holds almost surely in the random model.** The
counterfactual universe satisfies RH with probability one. This does not
prove RH for the real primes — the real primes are not random — but it tells
us that RH is exactly the kind of statement we should *expect* to be true,
and that any disproof would have to exploit some special, non-random
conspiracy among the genuine primes.

## The fingerprints of non-randomness

The places where the model and reality *disagree* are just as illuminating as
where they agree. The most famous disagreement concerns **twin primes** and
other prime constellations. The Cramér model predicts that the number of
twin primes (pairs *p*, *p* + 2 both prime) up to *N* should be about the
integral of 1 / (log *t*)², because two independent coins both landing
"prime" has probability 1 / (log *n* · log(*n*+2)) ≈ 1 / (log *n*)². But the
true count, conjectured by Hardy and Littlewood, carries an extra constant —
the famous *twin prime constant* of about 1.32 — that the naive model misses.

That discrepancy is not a failure; it is a measurement. The gap between the
Cramér prediction and the truth is precisely the *singular series*, a
correction factor that encodes all the multiplicative biases the random
model throws away. In other words, by subtracting the random baseline from
reality, number theorists isolate exactly the part of prime behavior that is
genuinely arithmetic rather than statistical. The model is most valuable not
when it is right, but when its errors are well understood.

## Why a cryptographer should care

This is filed under cryptography for a concrete reason. Modern public-key
cryptography — RSA, Diffie–Hellman, and their descendants — runs on our
ability to *find large primes quickly* and to estimate *how many primes* live
in a given range. Both tasks lean on the heuristic that primes behave like a
random set of density 1 / log *n*.

When a cryptographic library generates a 2048-bit RSA key, it picks random
odd numbers and tests them for primality, and it relies on the Cramér-style
estimate that roughly one in every log(2²⁰⁴⁸) ≈ 1420 candidates will be
prime, so a successful key is found after a manageable number of tries. The
expected-count sum we analyzed above — CramerSum(*N*) — is, quite literally,
the back-of-the-envelope calculation behind every key-generation routine.
Proving rigorous upper and lower bounds on it, sandwiching it between
logarithmic integrals and pinning its *N* / log *N* growth, turns a
heuristic into a guarantee about how long key generation should take.

The same model underpins the security analysis of schemes that depend on the
*gaps* between primes, on the difficulty of factoring (which the
unique-factorization collapse reminds us is a genuinely multiplicative, and
therefore non-random, phenomenon), and on the distribution of primes in
residue classes that show up in elliptic-curve and lattice constructions.
Understanding precisely *where* the random model is trustworthy and *where*
it lies is, for a cryptographer, the difference between a sound security
proof and a dangerous illusion.

## The view from the counterfactual

Cramér's model is a philosophical instrument disguised as a calculation. By
imagining a world where the primes really are random, we get a null
hypothesis for all of number theory: a precise prediction of what "no special
structure" would look like. Theorems that depend only on density — the Prime
Number Theorem, Dirichlet's theorem, the Riemann Hypothesis — survive the
transition, telling us they are, in a deep sense, *robust* statistical facts.
Theorems that depend on multiplication — unique factorization above all —
shatter, telling us they encode something the coins can never see.

And the residue, the part that survives neither cleanly nor catastrophically
— the twin-prime constant, the singular series, the subtle gap statistics —
is where the real mathematics lives. The Cramér model draws the map of the
ordinary so that the extraordinary stands out in relief.

We have made the backbone of this map completely rigorous. The expected
prime count is a positive, increasing, decreasing-termed sum, trapped
between two logarithmic integrals and growing at the Prime Number Theorem
rate of *N* / log *N*. From this modest, fully proven foundation, the entire
edifice of probabilistic number theory — and the heuristics that secure our
digital communications — takes its first solid step.
