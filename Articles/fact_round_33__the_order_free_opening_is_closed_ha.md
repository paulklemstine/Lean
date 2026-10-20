# The Lever That Isn't There: Why a Better Clock Can't Speed Up Harvey's Factoring Algorithm

*How a triangle of three competing costs pins the best deterministic factoring exponent at one fifth — and why a celebrated new tool for finding "large-order" elements cannot move it.*

---

## A puzzle with no randomness allowed

Take a large number $N$ that you know is the product of two primes, $N = pq$. Find $p$.

Every schoolchild knows the slowest way: try dividing $N$ by $2, 3, 5, 7, \dots$ until something works. If $p$ and $q$ are about the same size, you need roughly $\sqrt{N} = N^{1/2}$ trial divisions. For a 600-digit number, that is a 300-digit count of operations — longer than the age of the universe by an absurd margin.

Modern practice is far cleverer. The number field sieve, the workhorse behind record factorizations, runs in time that grows more slowly than any power of $N$. But it relies on heuristics: plausible but unproven assumptions about how often certain numbers are smooth. Randomised algorithms with fully rigorous analyses also exist. So there is a sharper, stranger question that mathematicians care about:

> **If you are not allowed to flip coins and not allowed to assume any unproven conjecture, how fast can you provably factor $N$?**

This is the world of *deterministic, rigorous* factoring, and it moves slowly. In 1974 Pollard and Strassen reached roughly $N^{1/4}$. That exponent stood for about half a century, improved only by logarithmic factors. Then, in 2020, David Harvey broke through with an algorithm running in time roughly

$$N^{1/5}\,(\log N)^{16/5}.$$

Since then, a whole line of research has tried to push the exponent below $1/5$. One of the most promising ideas involved *elements of large multiplicative order* — numbers whose powers take a very long time to cycle back to $1$ modulo $N$. Early in 2026, Harvey and Hittmeir published deterministic methods for finding such elements without needing any extra hypotheses. Naturally people asked: *now that large-order elements come for free, can Harvey's algorithm be rebalanced to beat $1/5$?*

This article explains why the answer is a clean, definite **no** — and why that negative answer is itself useful, because it tells us exactly where the real bottleneck lives.

## The ingredients: pairs, baby steps, and a clock

To understand the obstruction, you need a cartoon of how Harvey's algorithm works. It has three moving parts.

**1. Lehman's pairs.** In 1974 R. Sherman Lehman observed that if $N = pq$, then for some small integers $a$ and $b$ the ratio $a/b$ is an excellent approximation to $q/p$. Then $4abN = (aq + bp)^2 - (aq - bp)^2$ is very close to a perfect square, and that near-square can reveal the factors. Harvey's algorithm sets a budget $r$ and considers the whole family of candidate pairs

$$\{(a,b) : 1 \le ab \le r\},$$

of which there are about $r \log r$. One of these is the "good pair" that cracks $N$; the algorithm doesn't know which.

**2. Baby steps and giant steps.** For each candidate pair, the algorithm must solve a search problem inside the multiplicative group modulo $N$. It uses the classical *baby-step giant-step* trick: precompute a table of $m$ consecutive powers $\alpha, \alpha^2, \dots, \alpha^m$ of some element $\alpha$ (the baby steps), then leap through the search space in strides of length $m$ (the giant steps), checking each landing point against the table. A table of size $m$ divides the number of giant steps by $m$.

**3. The clock.** The element $\alpha$ is like the hand of a clock that ticks around the multiplicative group. Its *order* — the number of ticks before it returns to $1$ — limits how many genuinely distinct baby steps you can take. If the order is smaller than $m$, the table contains repeats, and the trick breaks down. So we need

$$m \le \operatorname{ord}_N(\alpha).$$

This is the only point where large-order elements come in. And that is why people hoped the new order-finding results would matter.

## Three costs pulling against each other

Measure everything in powers of $N$: write $r = N^a$ for the pair budget and $m = N^b$ for the size of the baby-step table. Up to logarithmic factors, the algorithm pays for three things:

- **The pair leg:** handling the roughly $r$ candidate pairs costs about $N^a$.
- **The baby-step leg:** building the table costs about $N^b$.
- **The giant-step leg:** the remaining search costs about $N^{1/2}/(r^{1/2}m)$, which is $N^{1/2 - a/2 - b}$.

The total running time is governed by the largest of the three, so the cost exponent is

$$c(a,b) = \max\left\{\, a,\; b,\; \tfrac12 - \tfrac a2 - b \,\right\}.$$

This is a tug-of-war. Raising $a$ (more pairs) shrinks the giant-step leg but swells the pair leg. Raising $b$ (bigger table) does the same with the baby-step leg. The best you can do is to make all three legs equal: $a = b = \tfrac12 - \tfrac a2 - b$, which solves to $a = b = 1/5$. That is where Harvey's exponent comes from.

## A one-line proof that 1/5 is optimal in this model

Is $1/5$ truly the best, or did we just guess a balance point? There is a beautiful certificate. Take a weighted average of the three legs with weights $\tfrac15, \tfrac25, \tfrac25$:

$$\tfrac15\cdot a \;+\; \tfrac25\cdot b \;+\; \tfrac25\left(\tfrac12 - \tfrac a2 - b\right) \;=\; \tfrac15.$$

The $a$'s cancel and the $b$'s cancel; what remains is exactly $1/5$ for *every* choice of $a$ and $b$. A maximum is always at least any weighted average, so

$$c(a,b) \;\ge\; \tfrac15 \quad\text{for all } a, b.$$

Moreover, equality forces all three legs to equal $1/5$ at once, so the minimiser $a = b = 1/5$ is **unique**.

Now look at what is *not* in this picture. The order of $\alpha$ appears nowhere in the three legs. The triangle that pins $1/5$ — pair budget against baby steps against giant steps — is **entirely order-free**.

## What the clock actually controls

So where does the order of $\alpha$ live? Only in a constraint: the table size $m = N^b$ cannot exceed the order $N^\omega$. In exponent form, $b \le \omega$.

Add that constraint and re-solve the tug-of-war. The answer is a crisp formula:

$$\text{best exponent with order } N^\omega \;=\; \max\left\{\tfrac15,\; \tfrac{1-2\omega}{3}\right\}.$$

Read it carefully:

- If $\omega \ge 1/5$ — that is, if $\alpha$ has order at least $N^{1/5}$ — the optimum is exactly $1/5$. The constraint is slack. In the language of economics, it has a **zero shadow price**: making the order larger, even making it maximal, buys absolutely nothing.
- If $\omega < 1/5$, the optimum is $(1-2\omega)/3 > 1/5$. A short clock *hurts*.

So the order of $\alpha$ can only ever be an obstacle, never an accelerator. Once you have an element of order at least $N^{1/5}$, you are done worrying about it. And because the optimum is uniquely attained at $b = 1/5$, achieving $1/5$ actually *requires* an order of at least $N^{1/5}$ — but nothing more.

## Keeping the logarithms honest

Exponent arithmetic hides logarithmic factors, and in factoring those can matter. So the same argument was carried out for Harvey's full running-time bound. With $L = \log_2 N$, the bound reads

$$T(r,m) \;=\; \left(\frac{\sqrt N}{\sqrt r\, m} + r\right) L^4 \;+\; m L^2 .$$

Call the three summands $X = rL^4$, $Y = \sqrt N L^4/(\sqrt r\, m)$ and $Z = mL^2$. A little algebra shows that

$$X \cdot Y^2 \cdot Z^2 \;=\; N L^{16}$$

no matter what $r$ and $m$ are. Now the weighted arithmetic–geometric mean inequality (with the same weights $\tfrac15, \tfrac25, \tfrac25$) gives

$$T \;=\; X + Y + Z \;\ge\; \tfrac15 X + \tfrac25 Y + \tfrac25 Z \;\ge\; X^{1/5}Y^{2/5}Z^{2/5} \;=\; N^{1/5}L^{16/5}.$$

So, writing $F = N^{1/5}L^{16/5}$, **every** choice of $r$ and $m$ costs at least $F$. And at the explicit choice $r = N^{1/5}L^{-4/5}$, $m = N^{1/5}L^{6/5}$, all three summands equal $F$ exactly, so the cost is $3F$. The optimum is pinned in the narrow window $[F, 3F]$.

Here is the punchline. Whatever extra cost the order of $\alpha$ adds to the algorithm — in Harvey's analysis it shows up as the work of processing spurious "hits" in a hash table — it is a *nonnegative* additional term. Adding a nonnegative term cannot drive the total below $F$. In particular, if order-finding were *literally free*, the window would still be $[F, 3F]$. **The 2026 large-order results are structurally incapable of moving Harvey's exponent.**

## Even buying the clock is cheap

There is a second way order could matter: what if *producing* a large-order element were expensive? A December 2025 result of Gao, Feng, Hu and Pan gives a deterministic procedure that, for a target $\delta$ in a suitable range, outputs an element of order larger than $\delta$ (or a factor of $N$, or a proof that $N$ is prime) in time about $\delta^{1/2}$, up to logarithms. So producing an element of order $N^\omega$ costs about $N^{\omega/2}$.

Fold that cost into the model: total exponent $\max\{c(a,b),\, \omega/2\}$. Since the table size satisfies $b \le c(a,b)$, setting $\omega = b$ gives $\omega/2 = b/2 \le c(a,b)$ whenever $b \ge 0$. Production is **dominated everywhere** — it never changes the cost at all — and the joint optimum stays exactly $1/5$. For instance, getting an element of order $N^{1/3}$ costs only about $N^{1/6}$, comfortably below $N^{1/5}$.

## So where is the real lever?

Negative results are most valuable when they redirect effort. This one points squarely at the pair leg: the term $r$ that counts Lehman's candidate pairs is the one leg that the baby-step table does nothing to shrink.

Suppose you had a *filter*: a way to throw away all but a $1/s$ fraction of the candidate pairs while guaranteeing the good pair survives. Write $s = N^\sigma$. Two very different kinds of filter emerge:

- A **generative** filter produces only the surviving pairs, never touching the others. Then the pair leg and the giant-step leg both shrink by $\sigma$, and the best exponent becomes exactly $$\tfrac15 - \tfrac{3\sigma}{5}.$$ Reaching $1/6$ needs $\sigma = 1/18$, i.e. compression by a factor $N^{1/18}$.
- An **evaluated** filter must look at every pair to decide whether to keep it. Then only the giant-step leg shrinks, and the best exponent is exactly $$\tfrac15 - \tfrac{2\sigma}{5}.$$ Reaching $1/6$ now needs a much stronger compression, $\sigma = 1/12$.

Is there a cheap filter of either kind? The obvious candidates are *congruence sieves*: keep only pairs whose residues modulo some small prime $\ell$ lie in a chosen set — say, those where $ab$ is a quadratic residue. But here is a simple and decisive observation. If the good pair is *residue-uniform* — if, as $N$ ranges over balanced semiprimes, every residue class modulo $\ell$ occurs as the class of the good pair for some $N$ — then any sieve that never wrongly discards the good pair must accept **every** class. Its compression factor is exactly $1$. Experiments on random balanced semiprimes show precisely this uniformity: the residues of $ab$ for the good pair fill out every class modulo $3, 5, 7$ and $11$. Congruence sieves act on the right object, but they sieve nothing.

## A cautionary pseudoprime

Not every structured shortcut is useless — it is just confined to special numbers. Consider the Fermat test: compute $x^{N-1} \bmod N$. For a prime, the answer is always $1$. For $N = pq$ there is a neat identity: modulo $p$,

$$x^{pq-1} = x^{q-1},$$

because $pq - 1 = (q-1) + q(p-1)$ and $x^{p-1} = 1$ modulo $p$ by Fermat's little theorem. So if $p - 1$ divides $q - 1$, then $x^{N-1} \equiv 1 \pmod p$ for every $x$ not divisible by $p$, and

$$\gcd\left(x^{N-1} - 1,\; N\right) = p$$

as soon as $q$ fails to divide $x^{N-1} - 1$.

The smallest example is a famous one: $341 = 11 \times 31$, the smallest number that fools the base-$2$ Fermat test, since $2^{340} \equiv 1 \pmod{341}$. Note that $10$ divides $30$. Base $2$ is "too lucky" — it gives $1$ modulo both primes — but base $3$ gives $\gcd(3^{340} - 1, 341) = 11$ at once. A large Euler gap, meaning a large $\gcd(p-1, q-1)$, makes $N$ easy. But such $N$ are rare: this is a promise class, not a route to factoring general numbers.

## The shape of the frontier

What did we learn?

1. **Harvey's $1/5$ is pinned by an order-free triangle.** The three legs — pair budget, baby steps, giant steps — balance at $1/5$ with a certificate that never mentions the order of anything.
2. **Order is a constraint, not a lever.** With order $N^\omega$ the optimum is $\max\{1/5, (1-2\omega)/3\}$; beyond $\omega = 1/5$ the order has zero value.
3. **The logarithms agree.** The full running time lies in $[F, 3F]$ with $F = N^{1/5}(\log N)^{16/5}$, and no nonnegative order-dependent term — including zero — changes that.
4. **Producing large order is cheap.** At cost about $N^{\omega/2}$, it never affects the exponent.
5. **The real target is the pair family.** A generative filter compressing Lehman's pairs by $N^{1/18}$, or an evaluated one compressing by $N^{1/12}$, would reach $1/6$. Simple congruence sieves cannot help.

One caveat is worth stating clearly. Everything here concerns the cost structure of one family of algorithms. $N^{1/5}$ is an **upper bound** on the deterministic state of the art, not a proven floor: nobody knows any unconditional superpolynomial lower bound for factoring in any reasonable model. What has been ruled out is a specific hope — that better clocks would speed up this particular machine. To go below $1/5$ along these lines, one has to break the balance between Lehman's pair budget and the smoothness-sieve work, or abandon the baby-step giant-step motif altogether.

Sometimes the most useful thing a mathematician can do is take a lever that everyone is reaching for and show, cleanly, that it was never connected to anything. Then everyone can reach for the right one.
