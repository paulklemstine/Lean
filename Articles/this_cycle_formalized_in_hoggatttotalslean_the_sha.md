# One Number That Decides the Shape of Counting

## A hidden dial behind the most famous sequences in combinatorics

Count the number of ways to do almost anything — arrange parentheses, triangulate a polygon, choose a committee, shuffle a deck — and you get a sequence of whole numbers. Some of these sequences grow gently, some explode, and some do something in between. For more than a century, mathematicians have noticed that the *character* of that growth tends to fall into a small number of clean patterns. What has been missing is a single, simple reason *why*.

This article tells the story of one such reason: a single number, which we will call the **Möbius discriminant**, whose *sign* — positive, zero, or negative — completely decides the growth character of an enormous family of counting sequences all at once.

### Convex, straight, or concave — but in the world of ratios

Before we meet the number, we need the right way to look at a sequence.

Suppose $a_0, a_1, a_2, \dots$ is a sequence of positive numbers. Instead of comparing differences (as you would for a straight line versus a curve), the natural thing for *multiplicative* growth is to compare the numbers three at a time and ask how the middle one sits relative to its neighbors. There are exactly three possibilities:

- **Log-convex:** the sequence "curves upward" on a logarithmic scale, meaning
  $$a_{n+1}^2 < a_n \, a_{n+2}.$$
  Equivalently, the ratios $a_{n+1}/a_n$ keep increasing — each step multiplies by more than the last. Growth accelerates.

- **Log-linear:** the sequence is a perfect geometric progression,
  $$a_{n+1}^2 = a_n \, a_{n+2}.$$
  Every ratio is the same. This is the knife's edge — the boundary case.

- **Log-concave:** the sequence "curves downward" on a log scale,
  $$a_n \, a_{n+2} < a_{n+1}^2.$$
  The ratios keep shrinking; growth decelerates (or decay accelerates).

Log-concavity in particular is a celebrated property: it forces the sequence to be *unimodal* (it rises then falls, with a single peak), and it shows up everywhere from statistics to the geometry of polynomials. Log-convexity is its mirror image and is equally natural for the fast-growing sequences of enumerative combinatorics.

The question is: given a counting sequence, which of the three is it — and can you tell *without* computing a single term?

### The recurrence that ties them together

Here is the observation that makes everything work. A striking number of classical sequences satisfy a **first-order multiplicative recurrence** of a very particular shape:
$$(\alpha n + \beta)\, a_{n+1} = (\gamma n + \delta)\, a_n,$$
where $\alpha, \beta, \gamma, \delta$ are fixed constants and the coefficient $\alpha n + \beta$ stays positive. In words: to get the next term, you multiply the current term by a ratio that is itself a simple fraction — one straight line divided by another — in the index $n$.

This is not an exotic condition. Look:

- **Powers of two,** $a_n = 2^n$: here $a_{n+1} = 2\,a_n$, so $(\alpha,\beta,\gamma,\delta) = (0,1,0,2)$.
- **Catalan numbers,** $C_n$ (the count of ways to correctly match $n$ pairs of parentheses, among a hundred other things): they obey $(n+2)\,C_{n+1} = (4n+2)\,C_n$, so $(\alpha,\beta,\gamma,\delta) = (1,2,4,2)$.
- **Central binomial coefficients,** $\binom{2n}{n}$: $(n+1)\binom{2n+2}{n+1} = (4n+2)\binom{2n}{n}$, so $(\alpha,\beta,\gamma,\delta) = (1,1,4,2)$.
- **Factorials,** $n!$: $a_{n+1} = (n+1)\,a_n$, so $(\alpha,\beta,\gamma,\delta) = (0,1,1,1)$.
- **Reciprocal factorials,** $1/n!$: $(n+1)\,a_{n+1} = a_n$, so $(\alpha,\beta,\gamma,\delta) = (1,1,0,1)$.

Each of these is just a choice of four numbers. And that is the whole point: the recurrence *is* those four numbers.

### The dial: one number, three regimes

Now for the punchline. Form the single quantity
$$\Delta = \gamma\beta - \alpha\delta.$$
We call it the **Möbius discriminant** of the recurrence. The main theorem says:

> **The sign of $\Delta$ decides everything.**
> If $\Delta > 0$, the sequence is strictly **log-convex**.
> If $\Delta = 0$, the sequence is **log-linear**.
> If $\Delta < 0$, the sequence is strictly **log-concave**.

That is the entire criterion. No term-by-term checking, no asymptotics, no case analysis. You read off four coefficients, compute one product minus another, and look at the sign.

Let us turn the dial through our examples:

| Sequence | $(\alpha,\beta,\gamma,\delta)$ | $\Delta = \gamma\beta - \alpha\delta$ | Verdict |
|---|---|---|---|
| $2^n$ | $(0,1,0,2)$ | $0$ | log-linear |
| Catalan $C_n$ | $(1,2,4,2)$ | $6$ | log-convex |
| Central binomial $\binom{2n}{n}$ | $(1,1,4,2)$ | $2$ | log-convex |
| Factorial $n!$ | $(0,1,1,1)$ | $1$ | log-convex |
| Reciprocal factorial $1/n!$ | $(1,1,0,1)$ | $-1$ | log-concave |

All three regimes appear. The famous fast growers ($C_n$, $\binom{2n}{n}$, $n!$) land firmly in the log-convex camp. The pure geometric sequence $2^n$ sits exactly on the boundary. And the decaying reciprocal factorials tip over into log-concavity. One formula, three genuinely different behaviors, all correctly predicted.

### Why the sign of $\Delta$ is the right thing to look at

The magic is not a coincidence; it comes from a clean piece of algebra involving *ratios of consecutive terms*.

Divide the recurrence through and you learn the exact value of each step's multiplier:
$$\frac{a_{n+1}}{a_n} = \frac{\gamma n + \delta}{\alpha n + \beta}.$$
This is a **Möbius function** of $n$ — a fraction whose top and bottom are both linear. That is where the name comes from.

Whether the sequence is log-convex, log-linear, or log-concave is exactly the question of whether these ratios are *increasing*, *constant*, or *decreasing*. So we just need to know which way the Möbius function moves as $n$ grows.

Here is the elegant part. Compare two consecutive ratios by cross-multiplying:
$$\frac{\gamma(n+1) + \delta}{\alpha(n+1) + \beta} \;-\; \frac{\gamma n + \delta}{\alpha n + \beta} \;=\; \frac{\gamma\beta - \alpha\delta}{(\alpha(n+1)+\beta)(\alpha n + \beta)}.$$
Look at the numerator on the right: it is $\gamma\beta - \alpha\delta = \Delta$, **and nothing else**. The index $n$ has completely vanished from the top. The denominator is a product of two positive quantities, so it is always positive.

The consequence is beautiful and rigid. The *direction* in which the ratios move is the same at every single step, and it is dictated entirely by the sign of $\Delta$:

- $\Delta > 0$: ratios strictly increase forever $\Rightarrow$ log-convex.
- $\Delta = 0$: ratios never change $\Rightarrow$ log-linear (geometric).
- $\Delta < 0$: ratios strictly decrease forever $\Rightarrow$ log-concave.

There is no "eventually," no threshold to cross, no exceptional early terms. The moment you know $\Delta \neq 0$, you know the sequence's log-behavior is *strict* and *permanent*.

### The vanishing act that explains an old mystery

This framework also solves a small mystery. If you study the Catalan numbers directly, you can grind out an exact identity relating three consecutive terms:
$$(2n+1)(n+3)\,C_n\,C_{n+2} = (n+2)(2n+3)\,C_{n+1}^2.$$
The two sides look almost symmetric, and the log-convexity of the Catalan numbers ends up hinging on the fact that a certain pair of coefficients differ by exactly the constant $3$ — a number that, in the direct calculation, seems to fall out of the sky.

The Möbius viewpoint demystifies it completely. That "constant $3$" is nothing more than the discriminant $\Delta = 6$ for the Catalan recurrence, seen after a normalization. What looked like a lucky arithmetic accident special to the Catalan numbers is really the universal invariant $\Delta = \gamma\beta - \alpha\delta$ shining through one particular example. The same constant governs $\binom{2n}{n}$, $n!$, $2^n$, and $1/n!$ — you just get a different value each time.

### From a dichotomy to a trichotomy

This story grew out of a study of the *total* counts $H_d(n)$ arising in a family of number triangles indexed by a parameter $d$. The first two members are old friends: for $d = 1$ the totals are exactly $2^n$, and for $d = 2$ they are the Catalan numbers $C_n$. An earlier result established a **sharp dichotomy** between them — $2^n$ is the borderline log-linear case, while $C_n$ is strictly log-convex.

The Möbius discriminant reveals that this dichotomy was two-thirds of a bigger picture. Log-linearity ($\Delta = 0$) is not one of two options; it is the razor-thin *boundary* separating two open regions, log-convex ($\Delta > 0$) on one side and log-concave ($\Delta < 0$) on the other. Once you have the third regime, and a natural sequence living in it (the reciprocal factorials), the dichotomy becomes a genuine **trichotomy**, cleanly indexed by the sign of a single number. The three regimes are provably distinct and mutually exclusive: a strictly log-convex sequence can be neither log-linear nor log-concave, and so on.

### Why this matters

Sequences that count things are the raw material of combinatorics, probability, and theoretical computer science, and their log-behavior controls a great deal of downstream structure — unimodality, tail estimates, positivity of associated polynomials, concentration of random variables built from them. Usually each such fact is proved by a bespoke argument tailored to the sequence at hand.

The Möbius discriminant replaces a shelf of individual proofs with one lever. Whenever a sequence grows by multiplying by a linear-over-linear ratio — a condition satisfied by a remarkable swath of the classical sequences — you no longer argue; you *compute a sign*. The Catalan numbers, central binomial coefficients, factorials, powers of two, and reciprocal factorials become five turns of the same dial. And because the criterion is exact rather than asymptotic, it tells you the behavior holds from the very first step, with no exceptions hiding in the early terms.

Sometimes the deepest unifications are also the simplest to state. Here, the entire qualitative shape of a counting sequence — accelerating, steady, or decelerating — is written in the sign of $\gamma\beta - \alpha\delta$. One number, three worlds.
