# The Number That Always Divides: A Small Miracle Hidden in $a^5 - a$

## A puzzle you can check on your fingers

Pick any whole number you like. Call it $a$. Now compute $a^5 - a$: raise your number to the fifth power, then subtract the number itself. Try $a = 2$: we get $2^5 - 2 = 32 - 2 = 30$. Try $a = 3$: $3^5 - 3 = 243 - 3 = 240$. Try $a = 7$: $7^5 - 7 = 16807 - 7 = 16800$.

Look at those answers: $30$, $240$, $16800$. Every one of them is divisible by $5$. That is not a coincidence, and it is not luck. It is a theorem, and it is the modest headline of this article:

> **For every integer $a$, the number $a^5 - a$ is a multiple of $5$.**

But once you start staring at $30$, $240$, and $16800$, you notice something more. All three are divisible not just by $5$, but by $30$. And $30 = 2 \cdot 3 \cdot 5$. Is *that* a coincidence? It is not. The deeper truth is:

> **For every integer $a$, the number $a^5 - a$ is a multiple of $30$.**

This little cascade — from "divisible by $5$" to "divisible by $30$" — is a perfect miniature of how mathematics works. A concrete question ("is $a^5 - a$ always divisible by $5$?") turns out to be a special case of a grand pattern (Fermat's Little Theorem), and answering it carefully reveals that the true answer is *stronger and cleaner* than the question demanded.

## The grand pattern: Fermat's Little Theorem

Back in the seventeenth century, Pierre de Fermat noticed a beautiful regularity about prime numbers. In modern language, his **Little Theorem** says:

> **If $p$ is a prime number, then for every integer $a$, the number $a^p - a$ is a multiple of $p$.**

Set $p = 5$ and you get exactly our headline. Set $p = 2$ and you learn that $a^2 - a = a(a-1)$ is always even — which is obvious, since one of two consecutive numbers must be even. Set $p = 3$ and you learn $a^3 - a$ is always a multiple of $3$. Set $p = 7$, $p = 11$, $p = 101$ — the pattern never breaks, as long as the exponent is prime.

Why should primes be special here? The cleanest way to see it is to change *what world we count in*.

## Counting on a clock

Ordinary arithmetic runs along an infinite number line. But there is another, cozier kind of arithmetic that runs around a **clock**. On a $12$-hour clock, $10 + 5$ is not $15$; it is $3$, because after passing $12$ we start over. Mathematicians call this **modular arithmetic**, and they can build a clock with any number of hours they like.

The magic of Fermat's Little Theorem is easiest to see on a clock with a *prime* number of hours — say a $5$-hour clock, whose only readings are $0, 1, 2, 3, 4$. On this clock, addition, subtraction, and multiplication all behave beautifully: in fact, a clock with a prime number of hours forms what algebraists call a **field**, a number system where every nonzero element has a genuine reciprocal, just like the rational or real numbers.

On such a prime clock, a remarkable identity holds: **raising any hour to the $p$-th power sends it right back to itself.** In symbols, on the $p$-hour clock,
$$x^p = x \quad \text{for every } x.$$
On the $5$-hour clock you can verify this by hand: $0^5 = 0$, $1^5 = 1$, $2^5 = 32 = 6\cdot5 + 2$ reads as $2$, $3^5 = 243 = 48\cdot5 + 3$ reads as $3$, and $4^5 = 1024 = 204\cdot5 + 4$ reads as $4$. Every hour returns home.

Now translate back. Saying "$a^5$ and $a$ read the same on the $5$-hour clock" is *exactly* saying "$a^5 - a$ is a multiple of $5$." The clock identity $x^5 = x$ and our headline theorem are two descriptions of the very same fact. This is the whole engine, and it is worth stating as its own principle:

> **The bridge principle.** An integer $m$ is a multiple of $p$ precisely when it reads as $0$ on the $p$-hour clock.

Feed the clock identity $a^p = a$ through this bridge and Fermat's Little Theorem falls out for every prime $p$ at once — no separate argument for each prime, no case-by-case checking. That single unified mechanism, rather than an ad-hoc analysis of what $a$ leaves as a remainder when divided by $5$, is the elegant heart of the matter.

## Why the answer is really $30$

The clock argument, applied to the primes $2$, $3$, and $5$ separately, tells us that $a^5 - a$ is *simultaneously* a multiple of each. For $p = 5$ this is Fermat directly. For $p = 3$: on a $3$-hour clock $x^3 = x$, and since $a^5 = a^3 \cdot a^2$ collapses appropriately, one checks $a^5 - a$ is a multiple of $3$. For $p = 2$: $a^5 - a$ is a product of consecutive-ish integers and is always even.

Here is the punchline. If a number is divisible by $2$, by $3$, and by $5$, and if these divisors share no common factor with one another — which primes never do — then the number is automatically divisible by their *product*. This is the principle that **coprime divisors multiply**: divisibility by pairwise-coprime numbers combines into divisibility by their product. Since $2 \cdot 3 \cdot 5 = 30$, we conclude:
$$30 \mid a^5 - a \quad \text{for every integer } a.$$
The requested theorem asked only for $5$. The mathematics *gives us $30$ for free* — three times as strong.

## A second window: the factorisation

There is a completely elementary way to see the same phenomenon, one that uses no clocks at all. A little algebra reveals a hidden structure inside $a^5 - a$:
$$a^5 - a = a\,(a-1)\,(a+1)\,(a^2+1).$$
You can expand the right-hand side and watch it collapse back to $a^5 - a$. This factorisation is a small marvel: it displays $a^5 - a$ as $a$ times its two immediate neighbours $a-1$ and $a+1$, times the quadratic $a^2 + 1$.

The three factors $a-1$, $a$, $a+1$ are **three consecutive integers**. Among any three consecutive integers, one must be a multiple of $3$, and at least one must be even — so their product already carries a factor of $6$. Chasing the factor of $5$ is a slightly more delicate residue check, but the factorisation makes the divisibility by $2$ and $3$ almost visible to the naked eye. The two windows — the clock and the factorisation — illuminate the same theorem from different sides.

## Consequences that ripple outward

Once you own a clean fact, it starts paying dividends. Two immediate consequences follow with almost no extra work.

First, a **congruence**: since $a^5 - a$ is always a multiple of $5$, the numbers $a^5$ and $a$ always leave the *same remainder* when divided by $5$. Written compactly,
$$a^5 \equiv a \pmod 5.$$
This is the "clock" phrasing of the theorem, and it is exactly the form that appears when you want to compute enormous fifth powers modulo $5$ instantly: you never actually raise anything to the fifth power; you just read off $a$.

Second, a statement about **running totals**. Consider the sum
$$\sum_{k=0}^{n-1} \bigl(k^5 - k\bigr) = (0^5-0) + (1^5-1) + (2^5-2) + \cdots + \bigl((n-1)^5 - (n-1)\bigr).$$
Every single term is a multiple of $5$. A sum of multiples of $5$ is again a multiple of $5$. Therefore the whole sum is divisible by $5$, for every $n$ — a fact that would be tedious to guess from the raw numbers but is transparent once you know each summand's secret.

## The horizon: how far does this go?

The story does not end at $5$, or even at $30$. It opens onto a landscape.

Ask the natural next question: for a general exponent $n$, what is the *largest* fixed number $M(n)$ that divides $a^n - a$ for **every** integer $a$? For $n = 5$ we have discovered $M(5) = 30$. The conjectured general answer is strikingly clean: $M(n)$ is the product of exactly those primes $p$ for which $p - 1$ divides $n - 1$. For $n = 5$, we need $p - 1 \mid 4$, which the primes $2, 3, 5$ satisfy (since $1, 2, 4$ all divide $4$) — and indeed $2 \cdot 3 \cdot 5 = 30$. This universal divisor is always **squarefree**: no prime ever appears twice, because the arithmetic on a clock with $p^2$ hours is simply too roomy to force the identity.

That single formula ties our humble puzzle to some of the most celebrated objects in number theory. When you push the exponent to its extreme, the condition becomes **Korselt's criterion**, the fingerprint of the famous **Carmichael numbers** — composite numbers that masquerade as primes in Fermat's test. Our $30 \mid a^5 - a$ is nothing less than a baby instance of that criterion, a first step onto a road that leads to the frontier of what we know about pseudoprimes and primality testing.

## The moral

We began with a party trick — $a^5 - a$ is always divisible by $5$ — that you can check on a handful of examples. We ended by seeing that trick as the shadow of a universal law: the identity $x^p = x$ on a prime clock, transported back to ordinary integers by a single bridge, then sharpened by the observation that coprime divisors multiply. Along the way the answer grew from $5$ to $30$, an algebraic factorisation appeared out of nowhere, congruences and sums fell into our lap, and a horizon opened toward Carmichael numbers.

That is the quiet pleasure of number theory. The smallest questions, asked precisely and answered honestly, keep handing you more than you asked for.
