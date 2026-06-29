# The Three Lucky Factorials: A Probability Story Hidden Inside a Number-Theory Mystery

## A puzzle that fits on a napkin

Take a number, multiply together every whole number up to it, and add one. Then ask a deceptively simple question: is the result a perfect square?

That is the entire setup of **Brocard's problem**, one of the oldest unsolved riddles in number theory. In symbols, we are hunting for whole numbers $n$ and $m$ that satisfy

$$n! + 1 = m^2,$$

where $n!$ — read "$n$ factorial" — means $1 \times 2 \times 3 \times \cdots \times n$. The factorial grows at a terrifying pace: $4! = 24$, $7! = 5040$, and by the time you reach $20!$ you have passed two quintillion. Squares, by contrast, are spaced out more and more sparsely as numbers grow. The question is whether these two very different sequences ever collide after you add a single unit.

Remarkably, they do — but apparently only three times. Try $n = 4$:

$$4! + 1 = 24 + 1 = 25 = 5^2.$$

Try $n = 5$:

$$5! + 1 = 120 + 1 = 121 = 11^2.$$

And try $n = 7$:

$$7! + 1 = 5040 + 1 = 5041 = 71^2.$$

Three clean hits, at $n = 4, 5, 7$. The values of $n$ that work are called **Brown numbers**, after the pairs $(m, n)$ first tabulated in the literature. Henri Brocard posed the problem in 1876; Srinivasa Ramanujan asked the very same question independently in 1913. More than a century later, nobody has found a fourth solution, and nobody has proved that a fourth solution is impossible. It is widely conjectured that $4, 5, 7$ are the only Brown numbers, and computers have now checked, without finding a fourth, far past any range a human could survey by hand.

This article is about a beautiful way to *understand* why mathematicians expect the list to stop at three — not a proof that it does, but a rigorous probabilistic argument that explains the silence. The surprise is that a question about exact arithmetic, where there is nothing random at all, is best illuminated by the mathematics of coincidence and luck.

## Why "probability" for a problem with no dice?

The integers do not roll dice. Whether $7! + 1$ is a square is a yes-or-no fact, settled forever. So what could probability possibly have to say?

The answer lies in a powerful style of reasoning called a **heuristic**: a back-of-the-envelope estimate that treats deterministic objects *as if* they were random, in order to predict how often rare events should happen. Number theorists use this constantly. The most famous example is the prime numbers: although primality is completely determined, the "probability" that a number near $N$ is prime behaves like $1/\ln N$, and this fiction predicts the distribution of primes with uncanny accuracy.

Brocard's problem invites exactly the same move. Picture the number line near $n!$. The perfect squares thin out as you go: between consecutive squares $k^2$ and $(k+1)^2$ there is a gap of about $2k$. Near a number of size $n!$, the relevant square root $k$ is about $\sqrt{n!}$, so the squares are spaced roughly $2\sqrt{n!}$ apart. If you drop a pin on a number of that size with no special reason to land on a square, the chance of hitting one is about one part in that spacing:

$$\Pr[\text{a number of size } n! \text{ is a perfect square}] \approx \frac{1}{2\sqrt{n!}} \;\sim\; \frac{1}{\sqrt{n!}}.$$

Now treat the question "is $n! + 1$ a square?" as a sequence of independent lottery tickets, one for each $n$, where ticket number $n$ wins with probability about $1/\sqrt{n!}$. The grand question becomes: how many of these tickets do we expect to win, in total, across all $n$?

## The sum that closes the case

Here the magic happens. The *expected* number of winning tickets is the sum of all the individual winning chances:

$$\sum_{n=0}^{\infty} \frac{1}{\sqrt{n!}} = \frac{1}{\sqrt{0!}} + \frac{1}{\sqrt{1!}} + \frac{1}{\sqrt{2!}} + \frac{1}{\sqrt{3!}} + \cdots.$$

Because the factorial explodes, the terms collapse to zero with astonishing speed. A clean way to see it: every factorial satisfies $n! \ge 2^{\,n-1}$, so

$$\frac{1}{\sqrt{n!}} \;\le\; \frac{\sqrt{2}}{(\sqrt{2})^{\,n}},$$

and the right-hand side is an ordinary geometric series with ratio $1/\sqrt{2} < 1$. A geometric series with ratio below one has a finite sum, and our smaller series is squeezed beneath it. So the whole sum converges to a finite number — in fact a number close to $3.47$.

This single fact — *the sum of the winning probabilities is finite* — is the linchpin of the entire argument. It says that, in the probabilistic model, the total expected number of "square factorials plus one" across the entire infinite number line is a finite quantity. And whenever the expected number of successes in an infinite sequence of trials is finite, an iron law of probability kicks in.

## The law of rare coincidences

That iron law is the **Borel–Cantelli lemma**, one of the cornerstones of probability theory. In plain language it states:

> If you add up the probabilities of an infinite list of events, and the total is finite, then almost surely only finitely many of those events ever happen.

The phrase "almost surely" is the technical way of saying "with probability one" — the exceptions form a set so small it has zero measure, like the chance of a dart landing on one exact point. The intuition is irresistible: if the events were so rare that their probabilities already added up to something finite, there simply isn't enough "probability budget" left for infinitely many of them to occur. The rare coincidences must dry up after some point.

Apply this to Brocard. The events are $E_n$ = "$n! + 1$ is a perfect square." Their probabilities (in the heuristic model) sum to a finite number. Borel–Cantelli therefore predicts: **almost surely, only finitely many of the $E_n$ occur.** In the language of the model, the Brown numbers should run out — exactly the behavior we observe, with the list apparently stopping at $4, 5, 7$.

This is why working mathematicians are confident there is no fourth Brown number, even without a proof. The probabilistic accounting is overwhelming: the expected number of solutions beyond the ones we already know is essentially zero, and it stays essentially zero no matter how far out you look.

## Turning a hunch into a theorem

A heuristic is a story, and stories can mislead. The honest question is: *which part of this reasoning is genuine mathematics, and which part is the fiction we introduced?*

The fiction is exactly one step: the modelling assumption that the chance of a hit is bounded by something of size $1/\sqrt{n!}$. Squares are not actually random, so this is a belief about the world, not a theorem. But *everything else* — the convergence of the sum, and the leap from "finite sum" to "finitely many events" — is pure, rigorous mathematics that holds with no fiction at all.

We can therefore state the heuristic as an honest conditional theorem. Work in any probability space (or, more generally, with any "outer measure" $\mu$ that assigns sizes to events). Suppose you are handed a sequence of events $E_0, E_1, E_2, \dots$ — *any* events whatsoever — and suppose they satisfy the Brocard density bound

$$\mu(E_n) \le \frac{C}{\sqrt{n!}} \quad \text{for every } n,$$

for some fixed constant $C \ge 0$. Then the set of outcomes that land in infinitely many of the $E_n$ has measure zero:

$$\mu\bigl(\{x : x \in E_n \text{ for infinitely many } n\}\bigr) = 0.$$

Equivalently, almost every outcome lies in only finitely many of the events. This is the **Brocard–Borel–Cantelli theorem**, and it is true unconditionally. It exposes the heuristic for exactly what it is: a perfectly rigorous deduction, sitting on top of a single, clearly labelled modelling assumption. The probabilistic finiteness of Brown numbers is not hand-waving; it is a theorem about any sequence of events meeting the density bound, applied to the events that model Brocard's equation.

## What the integers themselves are willing to tell us

The probabilistic picture explains the *expected* behavior. But the actual equation $n! + 1 = m^2$ also leaves hard, exact fingerprints — constraints that any genuine solution is forced to obey. Three of them are especially elegant.

**First, the square root is always odd.** For any $n \ge 2$, the factorial $n!$ is even (it contains the factor $2$), so $n! + 1$ is odd, and an odd square must come from an odd root. So in any solution with $n \ge 2$, the number $m$ is odd. The known cases confirm it: $5, 11, 71$ are all odd.

**Second, the equation factors.** Rewrite $n! + 1 = m^2$ as $n! = m^2 - 1$ and use the classic difference-of-squares identity $m^2 - 1 = (m-1)(m+1)$. This gives the striking relation

$$(m-1)(m+1) = n!.$$

The factorial — a product of all small numbers — must split as a product of two integers that differ by exactly $2$. For $n = 7$ this reads $70 \times 72 = 5040 = 7!$, a tidy little miracle. This factorization is the doorway through which most attempted attacks on Brocard's problem try to pass, because it converts a question about squares into a question about how factorials can be torn into near-equal halves.

**Third, primes leave a calling card.** Suppose $n + 1$ happens to be a prime number $p$, so that $n = p - 1$. There is a famous result from the 1770s called **Wilson's theorem**, which says that for any prime $p$,

$$(p-1)! + 1 \text{ is divisible by } p.$$

But $(p-1)! + 1$ is exactly our quantity $n! + 1 = m^2$. So $p$ divides $m^2$, and because $p$ is prime, $p$ must already divide $m$ itself. The consequence is a clean lower bound: the root $m$ is at least as big as $p = n + 1$. The factorial's square root cannot be small; it is pinned from below by the next prime. This is the **Wilson obstruction**, and it is a genuine, exact constraint — a glimpse of the rigid arithmetic skeleton beneath the probabilistic flesh.

## Trust, but verify: the exhaustive search

Heuristics predict; constraints restrict; but mathematicians also like to *look*. Is it really true that no fourth Brown number hides among modest values of $n$?

A direct computational sweep settles the modest range completely. Test every $n$ from $0$ up to $999$: form $n! + 1$, take its integer square root, square that back, and check whether you recover the original number. Out of a thousand candidates — including factorials with thousands of digits — exactly three pass the test, and they are precisely $4, 5, 7$. No fourth solution lurks below $1000$.

This sounds heavy, but it is fast, because testing whether a giant number is a square does not require examining the number digit by digit; an efficient integer-square-root procedure homes in on the answer with a handful of high-precision multiplications. The verification is exhaustive and exact: not a sampling, not an estimate, but a complete census of the first thousand cases, each one checked by honest arithmetic.

## The bigger lesson

Brocard's problem remains open, and it may stay open for a long time. The connection to deep modern machinery — including the celebrated **ABC conjecture**, which would imply that $n! + 1 = m^2$ has only finitely many solutions — shows just how far the ripples spread. But the probabilistic story is satisfying in its own right, for a reason that goes beyond this one equation.

It illustrates a recurring theme in mathematics: that **randomness is often the best model for things that are not random at all.** The digits of $\pi$, the gaps between primes, the factorizations of large integers — all are perfectly determined, yet all behave, statistically, like the output of a fair coin or a uniform spinner. When we treat $n! + 1$ as a lottery ticket and discover that the expected number of jackpots across all of eternity is a small finite number, we have not proved that the jackpots stop. But we have explained, in the clearest possible terms, why the silence after $n = 7$ is exactly what we should expect to hear.

Three lucky factorials — $24, 120, 5040$ — each landing one short of a perfect square. The probability that there is a fourth is, in every honest accounting, vanishingly small. And the mathematics that tells us so is the same mathematics that governs gamblers, insurers, and anyone who has ever wondered how long a streak of good luck can really last.
