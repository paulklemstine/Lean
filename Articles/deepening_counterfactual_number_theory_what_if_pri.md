# What If Primes Were Random? A Counterfactual Number Theory

## A thought experiment at the heart of arithmetic

The prime numbers — $2, 3, 5, 7, 11, 13, \dots$ — are the atoms of arithmetic.
Every whole number is built from them in exactly one way, a fact so fundamental
that it has a grand name: the *Fundamental Theorem of Arithmetic*. And yet, for
all their importance, the primes feel oddly *lawless*. They thin out as you climb
the number line, but never stop. They cluster and gap in ways no simple formula
predicts. Looking at a long list of primes, a mathematician sees something that
looks disconcertingly like the output of a coin-flipping machine.

That resemblance is not an accident, and it is not new. In the 1930s the Swedish
mathematician Harald Cramér proposed a daring idea: *pretend the primes are
random*. Not random in a vague, poetic sense, but random in a precise,
computable sense — build a fake set of "primes" by walking up the number line and
flipping a biased coin at each integer $n$, keeping $n$ with probability
$1/\log n$. This particular bias is chosen for a reason. The celebrated *Prime
Number Theorem* says that the true primes below $n$ number about $n/\log n$, so
near the integer $n$ the "chance" that any given number is prime is roughly
$1/\log n$. Cramér's model simply promotes this density from a description into a
mechanism.

The result is a parallel universe of numbers — a **counterfactual number
theory**. In this universe the "primes" are a random subset of the integers.
Some are near the true primes, some are not; every possible outcome is a
different universe with its own arithmetic. The natural question is irresistible:
*which theorems of ordinary number theory survive the transition to randomness,
and which ones collapse?*

This article tells the story of one clean, complete answer. It concerns the most
basic prime fact of all — that there are infinitely many of them — and shows
that its survival is governed by a single, beautifully simple criterion.

## The world's oldest theorem, retold

Around 300 BCE, Euclid proved that the primes never run out. It is arguably the
oldest theorem still taught today. In our counterfactual universe the primes are
random, so "there are infinitely many primes" is no longer a fact — it is an
*event*, something that either happens or doesn't in a given random universe, and
we can ask for its *probability*.

Here is the punchline, stated for the model itself. Suppose we build the random
prime set $S$ by including each integer $n$ independently with some probability
$p_n$. Then:

- **If the probabilities add up to infinity** — that is, if $\sum_n p_n = \infty$ —
  then *almost every* random universe has infinitely many primes. The event has
  probability $1$.
- **If the probabilities add up to a finite total** — $\sum_n p_n < \infty$ —
  then *almost every* random universe has only finitely many primes. The event has
  probability $0$.

There is no middle ground. The probability of "infinitely many primes" is either
$0$ or $1$, and which one it is depends entirely on whether a certain sum of
numbers converges or diverges. This kind of all-or-nothing statement is called a
*zero–one law*, and the engine behind it is a classical pair of results known as
the **Borel–Cantelli lemmas**.

## The two lemmas that decide everything

The Borel–Cantelli lemmas are among the most useful tools in probability. They
concern a sequence of events $A_1, A_2, A_3, \dots$ and the event
"infinitely many of the $A_n$ happen." Written compactly, that event is the
*limit superior* $\limsup_n A_n$: the set of outcomes lying in infinitely many
of the $A_n$.

- **First Borel–Cantelli lemma.** If $\sum_n \Pr(A_n) < \infty$, then
  $\Pr(\limsup_n A_n) = 0$. Rare events, added up to a finite total, almost
  surely stop happening eventually. *No assumption about the events is needed.*
- **Second Borel–Cantelli lemma.** If the events are *independent* and
  $\sum_n \Pr(A_n) = \infty$, then $\Pr(\limsup_n A_n) = 1$. Independent events
  whose probabilities add to infinity almost surely keep happening forever.

Apply this with $A_n$ = "the integer $n$ is a random prime." The event
$\limsup_n A_n$ is exactly "infinitely many integers are random primes." So the
survival of Euclid's theorem in the counterfactual universe is decided by a
single question: **does the density series $\sum_n p_n$ converge or diverge?**

## Cramér's density lands on the winning side

Now we return to Cramér's specific choice, $p_n = 1/\log n$, and ask which side
of the divide it falls on. The relevant quantity is the **prime-density series**
$$\sum_n \frac{1}{\log n}.$$
Does it converge or diverge? The answer is *diverge* — and the reason is a
one-line comparison that a curious high-schooler can appreciate.

For every reasonable $n$, the logarithm grows slower than the number itself:
$$\log n \le n.$$
Taking reciprocals flips the inequality:
$$\frac{1}{n} \le \frac{1}{\log n}.$$
So each term of the prime-density series is *at least as big* as the
corresponding term of the famous *harmonic series* $\sum_n 1/n$. And the harmonic
series is the textbook example of a sum that diverges — it crawls to infinity,
ever more slowly, but without bound. Since the prime-density series dominates it
term by term, the prime-density series diverges too:
$$\sum_n \frac{1}{\log n} = \infty.$$

To make everything well-defined at the very bottom of the number line (where
$\log 1 = 0$ would cause division by zero), we shift the index slightly and work
with $1/\log(n+2)$; nothing about the argument changes. The conclusion stands:
Cramér's density adds up to infinity.

Combine this with the second Borel–Cantelli lemma and we obtain the headline
result.

> **Survival of Infinitude (Cramér model).** In the random model where each
> integer $n$ is independently a "prime" with probability at least $1/\log(n+2)$,
> *almost surely there are infinitely many primes.* The probability of the event
> "infinitely many random primes" is exactly $1$.

Euclid's theorem survives the leap into randomness — and it survives *robustly*,
for essentially the same reason the harmonic series diverges. The infinitude of
primes is not a delicate arithmetic miracle; it is a soft consequence of how
slowly the logarithm grows.

## The phase transition: where infinitude dies

The most illuminating part of the story is not that infinitude survives, but
*why*, and *what it would take to destroy it*. The zero–one law tells us there is
a sharp boundary — a **phase transition** — between universes teeming with
infinitely many primes and universes where the primes peter out. That boundary
sits exactly at the convergence line of the density series.

To see the other side of the transition, imagine a stingier universe where
numbers are much less likely to be prime — say, integer $n$ is prime with
probability at most $1/(n+2)^2$. This density decays fast enough that its total is
*finite*:
$$\sum_n \frac{1}{(n+2)^2} < \infty,$$
because it is dominated by the convergent series $\sum_n 1/n^2$ (whose sum,
famously, is $\pi^2/6$). By the *first* Borel–Cantelli lemma — which needs no
independence at all — the primes in such a universe almost surely run dry:

> **Collapse of Infinitude (subcritical model).** If each integer $n$ is a
> "prime" with probability at most $1/(n+2)^2$, then *almost surely only finitely
> many integers are prime.* The probability of "infinitely many primes" is $0$.

So the entire qualitative fate of the primes — infinitely many or finitely many —
turns on a single arithmetic dial: whether the density series adds up to infinity
or not. Cramér's choice, $1/\log n$, sits comfortably on the divergent side, and
so its universe looks like ours: bursting with primes forever. Squeeze the
density down past the convergence threshold — anything decaying like $1/n^2$ or
faster — and the primes vanish. The threshold itself lives in the delicate zone
between $1/n$ (diverges) and $1/n^{1+\varepsilon}$ (converges), precisely where
$1/\log n$ makes its home.

## Why translate arithmetic into probability?

There is a deeper lesson in this dictionary between two worlds. On one side sits
**analytic number theory**, the study of how primes are distributed, with its
logarithms and its density series. On the other sits **probability theory**, with
its independent events and its zero–one laws. The counterfactual model is a
*bridge*: it translates a statement about primes into a statement about summing a
sequence, and then hands that sequence to Borel–Cantelli, which returns a verdict
of probability $0$ or $1$.

This is exactly how working mathematicians use the Cramér model in earnest. It is
a *heuristic engine*: to guess whether some property of primes should be true,
one computes the corresponding probability in the random model. The model
correctly predicts the Prime Number Theorem, suggests the right shape for the
gaps between consecutive primes, and even underlies modern conjectures about
twin primes and prime constellations. It is wrong in important ways too — the
real primes are *not* independent (once you know $n$ is odd, its neighbor's
primality is constrained), and this is exactly why some deterministic structures,
like *unique factorization*, have no counterpart in the random world. In a random
"prime" universe there is no reason a number should factor in only one way; the
multiplicative skeleton of arithmetic simply dissolves. What survives are the
*counting* facts — how many primes, how spread out — because those are governed
by densities, and densities are what randomness reproduces faithfully.

That is the moral of counterfactual number theory. Strip the primes of their
rigid multiplicative structure and keep only their density, and you lose unique
factorization but you *keep* Euclid. The infinitude of primes was never really
about factorization at all. It was about a sum that refuses to converge.

## The takeaway

By replacing the primes with a coin-flipping caricature, we learn something true
about the originals. The fact that there are infinitely many primes — proved by
Euclid twenty-three centuries ago — turns out to be *stable under randomness*:
it holds with probability one in Cramér's model, and it does so for a reason as
simple as $\log n \le n$. Push the density below the critical line and the
theorem collapses to probability zero. Between those two regimes lies a razor-thin
phase transition, and the true primes, in their density $1/\log n$, live right at
its resilient edge.

Sometimes the best way to understand a thing is to imagine it otherwise.
