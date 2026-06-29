# The Hidden Bookkeeping of Binary Addition

## A puzzle about counting ones

Write a number in binary and count its ones. The number $13$ is $1101$ in binary, so it has three ones. The number $14$ is $1110$ — also three ones. The number $15$ is $1111$, four ones; and $16$ jumps all the way down to $10000$, a single solitary one.

That little counting function — the number of $1$'s in the binary expansion of $n$ — is one of the most studied objects in number theory. Mathematicians call it the **binary digit sum** and write it $s_2(n)$. It shows up in the theory of prime numbers, in the design of error-correcting codes, in the analysis of algorithms, and in the strange fractal-like patterns that appear when you plot it.

Here is a question that sounds almost childishly simple. Pick a fixed step size $t$ — say $t = 1$, or $t = 5$, or $t = 1000$. Now walk through the integers $n = 0, 1, 2, 3, \dots$ and, for each one, compare two digit sums: the digit sum of $n$, and the digit sum of $n + t$. Sometimes adding $t$ makes the digit sum go up; sometimes it makes it go down. **How often does it go up (or stay equal)?**

Concretely, define
$$c_t = \text{the fraction of integers } n \text{ for which } s_2(n+t) \ge s_2(n).$$

If digit sums were just random noise, you'd expect this fraction to be right around one half — adding $t$ should be equally likely to raise or lower the count. The surprising truth, conjectured by the cryptographer and mathematician **Thomas Cusick**, is that the answer is *always strictly more than one half*. Adding a fixed number to $n$ has a persistent, structural bias toward **raising** the binary digit sum.

This article tells the story of why that bias exists, and how it can be pinned down with a clean, explicit formula. The centerpiece is an inequality with a beautifully specific right-hand side:
$$c_t \;\ge\; \frac{1}{2} + \frac{1}{2^{\,2 s_2(t) + 1}}.$$

The bias never vanishes, and its size is controlled by a single number: how many ones are in the binary expansion of the step $t$.

## Why would there be any bias at all?

The intuition that adding $t$ should be "fair" — equally likely to raise or lower the digit sum — feels compelling. To see why it's wrong, we need to think about what actually happens, bit by bit, when you add two binary numbers.

Adding in binary is exactly like adding in decimal, except you carry whenever a column reaches $2$ instead of $10$. And carries are the whole story. Consider adding $t = 1$ to various numbers:

- $n = 4 = 100$. Then $n+1 = 101$. No carry happened. Digit sum went from $1$ to $2$ — it went **up**.
- $n = 5 = 101$. Then $n+1 = 110$. One carry. Digit sum stayed at $2$ — **equal**.
- $n = 3 = 011$. Then $n+1 = 100$. Two carries cascaded. Digit sum went from $2$ down to $1$ — it went **down**.

Notice the pattern. When there are no carries, every $1$ in $t$ simply adds a fresh $1$ to the result, and the digit sum climbs. When carries pile up, ones get consumed: two ones in a column collapse into a single one carried to the next column, a net loss. **Carries are the only thing that can make a digit sum drop.**

This is the key reframing, and it is worth stating as a precise law.

## The carry identity: a conservation law for ones

When you add $n$ and $t$ in binary, define the **carry count** — call it $\mathrm{carries}(t,n)$ — as the total number of carry operations performed. Then the following exact identity holds for *all* $n$ and $t$:
$$s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t).$$

Read it out loud: the ones you end up with, plus the ones you "lost" to carries, equals the ones you started with on both sides. It is a conservation law. Every carry destroys exactly one unit of digit sum; nothing else can.

Rearranged, it says
$$s_2(n+t) = s_2(n) + s_2(t) - \mathrm{carries}(t,n).$$

Now the original question dissolves into something cleaner. The inequality $s_2(n+t) \ge s_2(n)$ is *exactly equivalent* to
$$\mathrm{carries}(t,n) \le s_2(t).$$

In words: **adding $t$ raises the digit sum if and only if the addition produces at most as many carries as there are ones in $t$.** This is the conceptual heart of the whole subject. A question about digit sums has become a question about counting carries.

There is a gorgeous bridge that makes the carry count rigorous and computable, due to the 19th-century mathematician **Ernst Kummer**. Kummer discovered that the number of carries when you add $n$ and $t$ in base $p$ is precisely the exponent of $p$ in the binomial coefficient $\binom{n+t}{t}$. In base $2$ this gives
$$\mathrm{carries}(t,n) = v_2\!\binom{n+t}{t},$$
where $v_2(m)$ counts how many times $2$ divides $m$. So the carries in a binary addition are secretly encoded in how even a binomial coefficient is. This is the definition used to make everything precise: the carry count is *defined* as $v_2\binom{n+t}{t}$, and Kummer's theorem then delivers the conservation law above.

## A worked example you can check by hand

Take $t = 1$, so $s_2(t) = 1$. The reformulation says the digit sum goes up or stays equal precisely when the number of carries is at most $1$. When does adding $1$ produce two or more carries? Exactly when $n$ ends in a run of two or more ones — that is, when $n$ ends in $\dots 11$ in binary. A run of $k$ trailing ones causes $k$ carries.

Trailing ones are easy to count. The number $n$ ends in at least two ones exactly when $n + 1$ is divisible by $4$ — equivalently, when $n \equiv 3 \pmod 4$. So for the step $t = 1$:
$$s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3.$$

Out of every four consecutive integers, exactly three of them satisfy this (all but the one congruent to $3$). Therefore, for $t = 1$, the density is **exactly**
$$c_1 = \frac{3}{4} = \frac{1}{2} + \frac{1}{4}.$$

Compare this to the promised lower bound. For $t = 1$ we have $s_2(t) = 1$, so the bound predicts
$$c_1 \ge \frac{1}{2} + \frac{1}{2^{2\cdot 1 + 1}} = \frac{1}{2} + \frac{1}{8} = \frac{5}{8}.$$

And indeed $\tfrac{3}{4} = \tfrac{6}{8} \ge \tfrac{5}{8}$. The bias is real, the formula holds, and there's even room to spare. This $t=1$ case is not hand-waving — it is a fully rigorous count, proved by tracking residues modulo $4$ across every block of four integers: in any window $[0, 4m)$ exactly $3m$ integers pass the test.

## Why the gap can never close

The explicit bound $c_t \ge \tfrac12 + 2^{-(2 s_2(t)+1)}$ says the bias toward rising digit sums is not a fluke of small examples — it persists for every step size, and you can write down exactly how big it has to be. The gap shrinks as $t$ gets "bushier" (more ones in its binary expansion), but it never reaches zero. For a step like $t = 7 = 111$ with three ones, the guaranteed surplus is $2^{-7} = 1/128$ — small, but stubbornly positive.

Where does that bias come from, structurally? The "no-carry" scenario is the engine. Whenever you can add $t$ to $n$ without triggering a single carry, the digit sum jumps by the *maximum possible amount*: $s_2(n+t) = s_2(n) + s_2(t)$, a clean gain of $s_2(t)$. These no-carry configurations are plentiful — and they tilt the scales. A simple, fully rigorous way to see that they never run out: take any $t$, pick a bit position $L$ high enough that $2^L$ sits strictly above all the bits of $t$, and then $t + 2^L$ has digit sum exactly $s_2(t) + 1$, because the new top bit can't collide with anything. Sprinkling such "fresh high bits" produces infinitely many integers $n$ on which the Cusick inequality holds — for instance the whole sparse family $n = 2^{j+t}$. The good set is never finite.

The full quantitative bound requires more than a handful of witnesses; it requires understanding the *entire distribution* of carry counts as $n$ ranges over all integers. That distribution is governed by a kind of finite machine — a weighted automaton that reads the binary digits of $t$ and tracks the propagation of carries. The size of that machine depends only on $s_2(t)$, which is exactly why $s_2(t)$ is the number that appears in the final formula. The deep part of Cusick's conjecture is showing that this machine's long-run behavior produces precisely the density $\tfrac12 + 2^{-(2 s_2(t)+1)}$ or better.

## The shape of the argument

Step back and admire the architecture, because it is a model of how good mathematics works.

1. **A question about digit sums** ($s_2(n+t) \ge s_2(n)$) looked irreducibly arithmetic and messy.
2. **A conservation law** ($s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t)$) turned it into a clean statement about carries.
3. **A classical bridge** (Kummer's theorem, $\mathrm{carries}(t,n) = v_2\binom{n+t}{t}$) made the carry count rigorous and connected it to binomial coefficients.
4. **The reformulation** ($s_2(n) \le s_2(n+t) \iff \mathrm{carries}(t,n) \le s_2(t)$) revealed the true object of study.
5. **Explicit cases and witnesses** ($c_1 = 3/4$ exactly; infinitely many solutions for every $t$) anchored the abstract claim in checkable ground truth.

Each step trades a hard problem for an equivalent but more transparent one. By the end, an intimidating density question about the digits of arbitrary integers has become a statement about a small, well-understood machine.

## Why anyone should care

Binary digit sums are not an idle curiosity. They are the **Hamming weight** of a number — the count of set bits — which is the basic currency of coding theory, cryptography, and computer architecture. Processors have dedicated instructions ("popcount") to compute them. The behavior of digit sums under addition controls how errors propagate, how certain hash functions mix, and how random-looking sequences are generated from simple arithmetic.

Cusick's bias says something philosophically pointed: arithmetic is *not* symmetric with respect to digit complexity. Adding a fixed amount to a number is, on balance, more likely to make it "heavier" in bits than lighter. That asymmetry is a fingerprint of the carry mechanism — the same mechanism that makes binary addition a fundamentally directional, cascading process rather than a symmetric shuffle.

And the explicit bound turns a qualitative surprise ("the bias is positive") into a quantitative law ("the bias is at least $2^{-(2 s_2(t)+1)}$"). It tells you not just that the scales are tipped, but exactly how far they must lean — with the lean controlled entirely by the binary complexity of the step you take.

There is a satisfying moral here. The most innocent-seeming questions about counting digits open onto a hidden world of carries, binomial coefficients, and finite automata — and within that world, the apparent randomness of digit sums resolves into precise, provable structure. The ones in your numbers are doing careful bookkeeping, and the books, it turns out, are never quite balanced.
