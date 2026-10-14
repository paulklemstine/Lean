# The Door Between One-Third and Two-Thirds

*How a puzzle about differences of numbers became a gatekeeper for faster factoring — and why six clever attacks bounced off it*

---

## A puzzle you can state to a child

Pick a number $n$, say $n = 12$. Now choose two small bags of whole numbers, call them $S$ and $T$. From them, form every **positive difference** $s - t$ with $s$ taken from $S$, $t$ taken from $T$, and $t < s$. The challenge is this:

> Every number $1, 2, 3, \dots, n$ must divide at least one of your differences.

If you manage it, we say $S$ and $T$ form a **divisibility covering** of $[n] = \{1, 2, \dots, n\}$.

Here is a solution for $n = 12$. Take $T = \{0\}$ and

$$S = \{\,1\cdot 2\cdot 3\cdot 4,\; 5\cdot 6\cdot 7\cdot 8,\; 9\cdot 10\cdot 11\cdot 12\,\} = \{24,\ 1680,\ 11880\}.$$

The differences are just the elements of $S$ themselves, and each number from $1$ to $12$ obviously divides the block that contains it. Three numbers in $S$, one number in $T$, done.

That was easy because we were allowed to use enormous numbers. The game becomes interesting — and, it turns out, connected to one of the oldest problems in computing — once we impose a **budget**. We want $S$ and $T$ to be *small* (few elements), and we want their elements to be *not too large*. How small and how large can we get away with, simultaneously?

## Why anyone cares: factoring

Multiplying two primes is easy; recovering them from their product is believed to be hard, and much of today's public-key cryptography is built on that belief. Most fast factoring methods are *randomised*. If you insist on a **deterministic** algorithm — one that never flips a coin and always gives the answer within its stated time bound — the best known running times are far worse, of the form $N^{c+o(1)}$ for a number $N$ to be factored, and shaving the constant $c$ is a genuine event.

In recent work, Chris Umans and Shuo Wang connected deterministic factoring to exactly our covering puzzle. Their framework measures a covering with three exponents:

- $|S| \le n^{\beta_S}$ and $|T| \le n^{\beta_T}$ — the bags have polynomially many elements;
- every element is at most $\exp(n^{\alpha})$ — the numbers may be astronomically large, but in a controlled way.

According to their analysis, a covering at the symmetric point $(\alpha, \beta) = (1/3, 1/3)$ (meaning $\beta_S = \beta_T = 1/3$ and $\alpha = 1/3$) would push the exponent of deterministic factoring from $1/5$ down to $1/6$. They also wrote, candidly, that they *do not know* whether the natural lower limit can actually be reached.

So: a puzzle about differences, with the speed of a fundamental algorithm hanging on the answer. This article is about what we can say for sure about that puzzle, and about an honest failure to solve it.

## Units matter: the double exponential

Before anything else, a warning that tripped up real experiments. The bound on the elements is

$$\text{element} \le \exp(n^{\alpha}),$$

so $\alpha$ lives *two* logarithms down. If your construction's largest element is $M$, the honest way to read off $\alpha$ is

$$\alpha_{\text{measured}} = \frac{\ln \ln M}{\ln n}.$$

It is tempting to compute $\ln M / \ln n$ instead — that is how one usually reads off an exponent. But for $M = \exp(n^{1/3})$ the correct formula returns exactly $1/3$, while the tempting one returns $n^{1/3}/\ln n$, which **grows without bound**: about $7$ when $n$ is a million, about $362$ when $n$ is a trillion. An experiment using the wrong unit is not measuring a slightly different number — it is measuring a different quantity altogether. One can prove both halves cleanly: the double-log reading recovers $\alpha$ exactly from $M=\exp(n^\alpha)$ and never overstates it when $M \le \exp(n^\alpha)$, while the single-log reading tends to infinity.

## The wall: why you cannot be too stingy

Now the first real theorem. How small can the budget be?

Think about the **product of all the positive differences**, $D = \prod (s - t)$. If every $i \le n$ divides some difference, then every $i \le n$ divides $D$, so the least common multiple of $1, 2, \dots, n$ divides $D$:

$$\operatorname{lcm}(1, 2, \dots, n) \;\big|\; D.$$

That lcm is huge — it is roughly $e^{n}$ (this is essentially the prime number theorem in disguise). We need only a crude, completely elementary version of this. Consider the central binomial coefficient $\binom{2k}{k}$. A classical fact going back to Legendre and Kummer says that for every prime $p$, the largest power of $p$ dividing $\binom{2k}{k}$ is at most $2k$. A prime power that is at most $2k$ divides $\operatorname{lcm}(1,\dots,2k)$; so the whole binomial coefficient divides the lcm. And $\binom{2k}{k}$ is the largest of the $2k+1$ terms of $(1+1)^{2k} = 4^k$, which gives $4^k \le 2k\binom{2k}{k}$ (the two outer terms $1+1$ are absorbed into the largest middle term).

On the other side, $D$ is a product of at most $|S|\cdot|T|$ factors, each at most $M$. Chaining everything together:

> **The Counting Wall.** If $S, T$ cover $[2k]$ and every element of $S$ is at most $M$, then
> $$4^k \;\le\; 2k \cdot M^{|S|\,|T|}.$$

Translate into exponents. With $|S| \le n^{\beta_S}$, $|T| \le n^{\beta_T}$ and $M \le \exp(n^\alpha)$, taking logarithms gives

$$(n-1)\ln 2 \;\le\; \ln n + n^{\alpha + \beta_S + \beta_T}.$$

The left side grows like $n$. If $\alpha + \beta_S + \beta_T < 1$, the right side grows like a smaller power of $n$, and the inequality must eventually fail. Hence:

> **The Exponent Constraint.** If coverings with exponents $(\alpha, \beta_S, \beta_T)$ exist for all large $n$, then $\alpha + \beta_S + \beta_T \ge 1$.

At the symmetric point $\beta_S = \beta_T = \beta$ this is $\alpha \ge 1 - 2\beta$; at $\beta = 1/3$ it says $\alpha \ge 1/3$. The Umans–Wang target sits **exactly on the wall**, with zero slack. Every bit of the counting budget would have to be used perfectly.

## The easy side: the block covering

What can we actually *build*? The example from the start generalises. Choose a block length $L$, chop $[n]$ into consecutive blocks of $L$ integers, put each block's product into $S$, and set $T = \{0\}$. This always works. If we want $|S| \le n^\beta$, we need about $n^{1-\beta}$ numbers per block — the proof uses $L = \lceil 2n^{1-\beta} \rceil$ — and then every block product is at most $(n+L)^L$, whose logarithm is about $3 n^{1-\beta}\ln(4n)$. That is below $n^\alpha$ for every $\alpha > 1 - \beta$, once $n$ is large enough.

> **The Trivial Covering.** For $0 < \beta \le 1$ and every $\alpha > 1 - \beta$, block products with $T = \{0\}$ give coverings with $|S| \le n^{\beta}$, $|T| = 1$, and elements at most $\exp(n^\alpha)$, for all large $n$.

Combine this with the wall at $\beta_T = 0$ (one element in $T$ means $n^0$), and something sharp falls out:

> **The One-Sided Frontier.** When $T$ has a single element, coverings exist for every $\alpha > 1 - \beta$ and for no $\alpha < 1 - \beta$. Nothing one-sided beats the block construction.

This matters because the target needs $\alpha = 1/3$ while one-sided constructions are stuck at $\alpha \approx 2/3$. **Any covering at $(1/3, 1/3)$ must make the set $T$ do real work.** The second bag cannot be decoration.

## The sandwich

Put the two directions together at $\beta = 1/3$:

> **The Sandwich Theorem.** If $(\alpha, 1/3, 1/3)$ is achievable then $\alpha \ge 1/3$. Conversely, every $\alpha > 2/3$ is achievable (even with $|T| = 1$).

So the entire open question is the interval

$$\frac13 \;\le\; \alpha \;\le\; \frac23 .$$

There were three different statements floating around that are easy to confuse, and the sandwich separates them cleanly:

1. **A trivial boundary**, $\alpha + \beta \le 1$ (up to lower-order terms) — the region where the easy construction lives.
2. **The counting constraint**, $\alpha \ge 1 - 2\beta$ — the real lower wall, coming from the lcm argument.
3. **The trivial covering point**, $\alpha = 1 - \beta$ — what block products achieve.

At $\beta = 1/3$, statement 2 gives $1/3$ and statement 3 gives $2/3$. The whole mystery lives in between.

## Two more tools, and one trap

**A budget for large primes.** Every prime $p$ between $y$ and $n$ must divide the difference product $D$. Each such prime contributes a factor at least $y$, so

$$y^{\,\pi(n) - \pi(y)} \;\le\; M^{|S|\,|T|},$$

where $\pi(x)$ counts primes up to $x$. At the target, with $y = n^{2/3}$, the left side and the right side are of the same order of magnitude: the large primes alone nearly exhaust the budget. Any successful covering would have to pack roughly $n^{1/3}/\log n$ large primes into a typical difference, with almost no waste.

**A polynomial picture.** Allow integers and set $P_T(X) = \prod_{t \in T} (X - t)$. If $S$ and $T$ share no element and cover $[n]$, then the single integer

$$R = \prod_{s \in S} P_T(s) = \prod_{s\in S}\prod_{t\in T}(s-t)$$

(a resultant of the polynomials whose roots are $S$ and $T$, up to sign) is **nonzero** and **divisible by $\operatorname{lcm}(1,\dots,n)$**. The covering problem becomes the problem of making one specific integer of size about $e^{n}$ divisible by another integer of size about $e^n$.

**The trap: overlap.** Why insist that $S$ and $T$ be disjoint (or that $t < s$)? Because otherwise the puzzle is trivial: with $S = T = \{a\}$, the difference $a - a = 0$ is divisible by everything. A covering "found" by a program that forgot this guard is no covering at all. Several experiments were caught exactly this way.

## Six attacks, zero coverings

With this map in hand, a coordinated attempt was made to break through the door. Six strategy families were built and run, each against a harness that checked the covering property on **all** of $[n]$, composites included, with the disjointness guard switched on:

1. **Multi-scale difference covers** — layering classical difference-set ideas at several scales.
2. **Smooth-number differences** — making differences products of small primes, as in factor-base methods.
3. **Prime-power / valuation structure** — arranging $s - t$ to hit prescribed prime-power valuations.
4. **Interval and Cantor-style structured sets** — sets with self-similar gaps.
5. **Assembling many primorial arithmetic progressions** — gluing together the arithmetic-progression building blocks from the original framework.
6. **A lower-bound attack** — trying to prove that the door is closed.

Each run was then attacked by two independent adversarial reviewers who re-ran the harness. The verdict was unanimous: **fifteen out of fifteen reviews found no genuine covering at the target.** Several runs had over-claimed success; the reviews forced the claims to be withdrawn. The commonest culprits were exactly the traps above: forgetting composites, dropping the disjointness guard, or measuring $\alpha$ in the wrong unit.

Experiments with a disjointness-guarded greedy search tell the same story. At the traded point $(\alpha, \beta) = (1/2, 2/3)$ greedy search covers all of $[n]$. At the target $(1/3, 1/3)$ it reaches only about $40$–$54\%$ coverage. But look at the traded point through the sandwich: since $1/2 > 1 - 2/3$, it already lies in the region the block construction reaches — even $(2/5, 2/3)$ with a single-element $T$ is achievable. The experimental "success" lives in territory that was never in doubt. The open interval was never entered.

The lower-bound attack fared no better. Proving that $\alpha = 1/3$ is *impossible* at $\beta = 1/3$ would show that a constraint in a published framework is not tight — itself a significant result — and nothing in the counting machinery forbids the target, since it sits exactly on the boundary, not beyond it.

## What we know, and what we don't

Here is the honest ledger.

**Proved:** the Counting Wall; the Exponent Constraint $\alpha + \beta_S + \beta_T \ge 1$; the Trivial Covering for every $\alpha > 1-\beta$; the exact One-Sided Frontier $\alpha = 1 - \beta$; the Sandwich $1/3 \le \alpha$ (forced) and $\alpha > 2/3$ (achieved) at $\beta = 1/3$; the large-prime budget; the resultant reformulation; the necessity of the disjointness guard; and the correctness of the double-logarithmic unit.

**Not achieved:** a covering at $(1/3, 1/3)$, and equally, a proof that none exists. The question is open in **both** directions, and each direction would be a real result.

**Learned:** the door is not a soft opening that a clever search will stumble through. Unstructured search fails, six structured families fail, and the counting argument leaves the target with no slack whatsoever. A solution, if one exists, must be genuinely two-sided, must fit large primes into differences with near-perfect efficiency, and is probably not built by the Chinese remainder theorem in the obvious way — a natural conjecture is that such constructions are secretly one-sided and hence stuck at $\alpha \approx 1 - \beta$.

There is a certain beauty in a problem this clean. Two small bags of integers; one divisibility condition; an inequality that a high-school student can follow; and between $1/3$ and $2/3$, an interval whose resolution would change what we know about how fast a computer can deterministically take a number apart.
