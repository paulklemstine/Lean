# The Three Lonely Numbers: A Detective Story About Factorials and Squares

## A puzzle hiding in plain sight

Mathematics is full of patterns that begin so innocently you almost don't notice them. Here is one. Take the number $4$, and multiply together every whole number from $1$ up to it:

$$4! = 1 \times 2 \times 3 \times 4 = 24.$$

Now add one: $24 + 1 = 25$. And $25$, of course, is $5 \times 5$ — a perfect square. So

$$4! + 1 = 5^2.$$

Curious. Let's try $5$:

$$5! + 1 = 120 + 1 = 121 = 11^2.$$

Another perfect square! Encouraged, we try $6$: $6! + 1 = 721$, which sits awkwardly between $26^2 = 676$ and $27^2 = 729$ — not a square. We try $7$:

$$7! + 1 = 5040 + 1 = 5041 = 71^2.$$

A square again. By now you might expect these to keep coming forever. They do not. Search every value from $n = 8$ onward — to a hundred, to a thousand, with every supercomputer ever built — and you will never find another. Three numbers, $4$, $5$, and $7$, appear to be the *entire* answer to a question that looks like it should have infinitely many.

This is **Brocard's problem**, posed by Henri Brocard in 1876 and independently by the legendary Srinivasa Ramanujan in 1913. The equation is deceptively short:

$$n! + 1 = m^2.$$

Find all whole numbers $n$ and $m$ that make it true. The three known solutions, $n = 4, 5, 7$, are called the **Brown numbers**. Whether there are any others is, after nearly 150 years, still **unsolved**. It is one of those rare problems a curious child can understand but no mathematician on Earth can settle.

This article is the story of what we *can* prove — and the surprising number of different mathematical lenses through which the same three lonely numbers come into focus.

## Why factorials and squares almost never meet

To feel the texture of the problem, it helps to understand a closely related fact that we *can* prove completely: a factorial is almost never a perfect square *on its own*.

Look at the factorials: $2! = 2$, $3! = 6$, $4! = 24$, $5! = 120$. None is a perfect square, and none ever will be (for $n \ge 2$). The reason is a beautiful piece of classical number theory called **Bertrand's postulate**, which guarantees that between any number $k$ and its double $2k$ there always lurks at least one prime.

Here is how that wins the day. Suppose $n \ge 2$. Bertrand's postulate hands us a prime $p$ sitting in the window

$$\tfrac{n}{2} < p \le n.$$

Because $p \le n$, this prime appears as one of the factors in the product $n! = 1 \times 2 \times \cdots \times n$. But because $p > n/2$, its *double* $2p$ is bigger than $n$ — so $2p$ does **not** appear in the product. The upshot: the prime $p$ divides $n!$ *exactly once*. It shows up, but never twice.

A perfect square, however, is fussy: every prime in its factorization must appear an *even* number of times (that is what "square" means at the level of primes). A factorial that contains some prime exactly once can therefore never be a square. Formally, this is the theorem we call `factorial_square_iff_le_one`:

> **Theorem.** For a whole number $n$, the factorial $n!$ is a perfect square if and only if $n \le 1$.

(The only exceptions are the trivial $0! = 1 = 1^2$ and $1! = 1 = 1^2$.)

Brocard's problem adds a single, maddening $+1$ to this picture. That $+1$ shifts $n!$ just enough to *occasionally* land on a square — at $n = 4, 5, 7$ — and the clean prime-counting argument no longer applies. The whole difficulty of Brocard's problem lives in that one extra dot.

## Cornering the suspect: structural clues

When you cannot catch a culprit directly, you describe it so precisely that almost nothing can fit the description. That is exactly the strategy here. Even without solving Brocard's problem, we can prove that *any* hypothetical new solution must obey a long list of strict rules. The more rules, the smaller the haystack.

**Clue 1: The square root must be odd.** Suppose $n \ge 2$ and $n! + 1 = m^2$. For $n \ge 2$, the factorial $n!$ is even (it contains the factor $2$), so $n! + 1$ is odd, which forces $m$ to be odd. We prove this as `brocard_m_odd`. A small thing, but it already halves the candidates.

**Clue 2: The equation factors.** Rewrite $n! + 1 = m^2$ as $n! = m^2 - 1$, and remember the schoolbook identity $m^2 - 1 = (m-1)(m+1)$. So every solution secretly says

$$(m-1)(m+1) = n!.$$

This is `brocard_factor`. It reframes Brocard's problem as a *factorization* question: the factorial $n!$ must split into two factors that differ by exactly $2$. As $n$ grows, $n!$ has more and more prime factors, and the demand that two of its "halves" be just $2$ apart becomes wildly restrictive.

**Clue 3: Wilson's theorem strikes.** This is the most elegant constraint of all, and it comes from a 1770 gem called **Wilson's theorem**: a number $p$ is prime if and only if $(p-1)! + 1$ is divisible by $p$. In symbols, $(p-1)! \equiv -1 \pmod{p}$.

Now watch what happens if $n = p - 1$ for a prime $p$, and $n! + 1 = m^2$. Wilson tells us $p$ divides $(p-1)! + 1 = m^2$. But $p$ is prime, so if it divides $m^2$ it must already divide $m$ itself. We capture this as `brocard_wilson_dvd`:

> **Theorem.** If $p$ is prime and $(p-1)! + 1 = m^2$, then $p \mid m$.

And there is an immediate, striking consequence, `brocard_wilson_ge`: since $m$ is a positive multiple of $p$, we get $m \ge p$. The square root can't be small. Let's sanity-check it on the known solutions: $n = 4 = 5 - 1$ with $5$ prime gives $m = 5$, and indeed $5 \mid 5$. For $n = 7 = ?$ — here $8$ is not prime, so Wilson does not apply, and sure enough $m = 71$ is not a multiple of $8$. The clue fires exactly when its hypothesis holds.

Each clue alone is modest. Together they sketch a portrait of any new Brown number so demanding that most candidates are eliminated on sight.

## The geometric mirror: triangles made of dots

Here is where the story takes an unexpectedly visual turn. **Triangular numbers** count dots arranged in a triangle: $1, 3, 6, 10, 15, \dots$, where the $y$-th triangular number is

$$T_y = \frac{y(y+1)}{2}.$$

These figurate numbers have been doodled in the margins of mathematics since antiquity. What could they possibly have to do with factorials and squares?

The bridge is a single classical identity:

$$8 \cdot T_y + 1 = (2y+1)^2.$$

Multiply a triangular number by $8$, add one, and you *always* get an odd perfect square. Reading this backward gives a perfect dictionary between Brocard's problem and the geometry of triangles. We prove (`factorial_eq_eight_triangular_iff_brown`):

> **Theorem.** For $n \ge 2$, the number $n!/8$ is a triangular number **if and only if** $n! + 1$ is a perfect square.

So a Brown number is nothing more than a factorial whose eighth part can be laid out as a perfect triangle of dots. The three solutions translate into three explicit triangles, with side lengths $y = 2, 5, 35$ (`triangular_indices`):

- $n = 4$: $4!/8 = 3 = T_2$, and $m = 2\cdot 2 + 1 = 5$.
- $n = 5$: $5!/8 = 15 = T_5$, and $m = 2 \cdot 5 + 1 = 11$.
- $n = 7$: $7!/8 = 630 = T_{35}$, and $m = 2 \cdot 35 + 1 = 71$.

The square root $m$ is just $2y + 1$, the odd number attached to the triangle's side. The same three lonely numbers, now wearing a completely different costume. And a finite search confirms there are no triangular witnesses for $8 \le n \le 50$ (`no_triangular_witness_8_to_50`).

## Why we *expect* the list to stop: a coin-flipping heuristic

Mathematicians believe there are no Brown numbers beyond $7$ — but belief is not proof. Where does the belief come from? From a back-of-the-envelope probability argument, and one of the satisfying things we *can* make completely rigorous is the engine behind that argument.

Picture the number $n! + 1$. It is astronomically large. The perfect squares near it are spaced roughly $2\sqrt{n!}$ apart, so if you imagine $n! + 1$ as a "random" number of its size, the chance it happens to land exactly on a square is about

$$\frac{1}{\sqrt{n!}}.$$

Now here is the key question. If we add up these tiny chances over *all* $n$, do they pile up into infinity, or do they settle to a finite total? Because factorials explode so violently — faster than any exponential — the terms $1/\sqrt{n!}$ shrink with breathtaking speed. We prove (`summable_inv_sqrt_factorial`):

> **Theorem.** The infinite series $\displaystyle\sum_{n} \frac{1}{\sqrt{n!}}$ converges to a finite value.

A finite total of probabilities is exactly the input to a classical principle of probability theory called the **Borel–Cantelli lemma**, which says, roughly: *if the chances of a sequence of events add up to something finite, then only finitely many of those events actually happen.* It is the mathematical formalization of "if something is rare enough, rare enough times, it eventually stops happening for good."

We make this completely precise in an abstract measure-theoretic setting (`brocard_heuristic_finite`): model "$n! + 1$ is a square" as an event whose probability obeys the density bound $C/\sqrt{n!}$, and the theorem concludes that, with certainty, only finitely many such events occur. In plain terms: *under the standard randomness model, factorial-plus-one is a square only finitely often.* This does not prove Brocard's conjecture — nature is not obligated to be random — but it explains, with full rigor, why every expert bets the list ends at $7$.

## What computation can and cannot do

Faced with a conjecture, the modern instinct is to check it on a computer. And we have: an exhaustive, machine-verified search establishes (`brocard_no_others_below_1000`)

> **Theorem.** Among all $n$ below $1000$, the only Brown numbers are $4$, $5$, and $7$.

That is a genuine theorem, not a vague reassurance — a complete verification across a thousand cases, including values of $n!$ with thousands of digits. (In fact, much larger searches by other researchers extend this past $n = 10^9$ with no new solutions.)

But here lies the philosophical heart of the matter. No finite search, however vast, can ever *settle* Brocard's problem, because there are infinitely many $n$ still untested beyond any cutoff. Checking a billion cases is a billion confirmations and exactly zero proofs. The conjecture asks a question about *all* numbers at once, and only a structural argument — a reason rooted in the very nature of factorials and squares — could close it. That argument has eluded everyone for a century and a half.

## The shape of an open problem

What makes Brocard's problem so beguiling is the gap between how much we can say and how little we can conclude. We can prove a factorial is almost never a square. We can prove any new solution must have an odd square root, must factor as two numbers differing by $2$, must be divisible by a Wilson prime when one is in range. We can recast the whole question as a statement about triangular arrays of dots. We can prove that the probabilistic heuristic predicting finiteness is mathematically sound. We can verify the absence of solutions across enormous ranges.

And yet the central question — *are $4$, $5$, and $7$ truly alone?* — remains beyond reach. Every tool in the arsenal narrows the search without ever finishing it.

This is, in miniature, the condition of mathematics at its frontier: a simple question, a wealth of partial illumination, and a stubborn final darkness. The three Brown numbers sit at the center, quietly daring us to prove they have no companions. Perhaps the decisive idea will come from number theory, or from the geometry of triangles, or from some probabilistic insight not yet imagined. Until then, $4$, $5$, and $7$ keep their secret — three lonely numbers, and the long, beautiful chase to understand why.
