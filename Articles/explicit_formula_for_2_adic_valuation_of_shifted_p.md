# The Hidden Clockwork Inside Perrin's Numbers

## A sequence that counts in circles

Some sequences of numbers are famous. The Fibonacci numbers — $1, 1, 2, 3, 5, 8, 13, \dots$ — decorate sunflowers, pinecones, and textbook covers. Their quieter cousin, the **Perrin sequence**, deserves the same fame. It begins

$$3,\ 0,\ 2,\ 3,\ 2,\ 5,\ 5,\ 7,\ 10,\ 12,\ 17,\ 22,\ 29,\ 39,\ 51,\ \dots$$

and it is built by a beautifully simple rule: after the first three terms $R_0 = 3$, $R_1 = 0$, $R_2 = 2$, every new term is the sum of the term *two* places back and the term *three* places back:

$$R_{n+3} = R_{n+1} + R_n.$$

So $R_5 = R_3 + R_2 = 3 + 2 = 5$, and $R_{12} = R_{10} + R_9 = 17 + 12 = 29$, and so on forever. Just like the Fibonacci numbers grow at the rate of the golden ratio, the Perrin numbers grow at the rate of a lesser-known constant called the **plastic number**, $\rho \approx 1.3247$, the unique real solution of $x^3 = x + 1$.

This article is about a question that sounds almost childish but turns out to hide a delicate, self-repeating structure: **if you subtract $1$ from a Perrin number, how many times is the result divisible by $2$?**

## Counting factors of two

Take any whole number and keep dividing it by $2$ until you can't anymore. The number of times you succeed is called its **2-adic valuation**, written $\nu_2$. For instance, $\nu_2(40) = 3$ because $40 = 2^3 \cdot 5$, while $\nu_2(7) = 0$ because $7$ is already odd. The 2-adic valuation is the mathematician's way of measuring "how even" a number is.

Now form the *shifted Perrin numbers* $R_m - 1$ and ask for $\nu_2(R_m - 1)$. The first few shifted values are

$$R_m - 1:\quad 2,\ -1,\ 1,\ 2,\ 1,\ 4,\ 4,\ 6,\ 9,\ 11,\ 16,\ 21,\ 28,\ 38,\ \dots$$

and their valuations are

$$\nu_2(R_m - 1):\quad 1,\ 0,\ 0,\ 1,\ 0,\ 2,\ 2,\ 1,\ 0,\ 0,\ 4,\ 0,\ 2,\ 1,\ \dots$$

At first glance this list looks random. Mostly small numbers — zeros, ones, twos — and then, out of nowhere, a $4$ at position $m = 10$. What governs this? Is there a formula, or is the sequence genuinely chaotic?

The answer, remarkably, is that there **is** a formula — but it is a formula with a twist. The regular part is completely explicit and repeats with a short period. The irregular part hides in exactly three places, and there it repeats not by staying the same, but by *refining itself* at finer and finer scales, like a coastline that keeps revealing new detail as you zoom in.

## The engine: everything runs on a clock

The key observation is that the Perrin sequence, when viewed *modulo a power of two*, runs on a clock. If we only keep track of remainders after dividing by $2$, the sequence

$$3, 0, 2, 3, 2, 5, 5, 7, \dots \pmod 2 \;\longrightarrow\; 1, 0, 0, 1, 0, 1, 1, 1, \dots$$

repeats with period $7$. Keep track of remainders modulo $8$, and the period stretches to $28$. Modulo $16$, it becomes $56$. The pattern is exact and clean:

> **Periodicity.** For every power $2^k$, the Perrin sequence reduced modulo $2^k$ is purely periodic with period $7 \cdot 2^{k-1}$.

Each time we demand one more binary digit of precision, the clock's period doubles. This single fact — a period that doubles predictably — is the mainspring of the entire story.

## Level one: parity in a glance

The coarsest clock, modulo $2$, already tells us when $\nu_2(R_m - 1) = 0$; that is, when $R_m - 1$ is odd, which happens exactly when $R_m$ is even.

> **Parity Theorem.** $\nu_2(R_m - 1) = 0$ if and only if $m \bmod 7 \in \{1, 2, 4\}$.

The set $\{1, 2, 4\}$ is exactly the positions in one period of length $7$ where the Perrin number comes out even. So a full three of every seven Perrin numbers give a shifted value that is odd, contributing valuation zero. This is the "background noise" of the sequence, and it is completely pinned down by a period-$7$ rule.

## Level two: an explicit formula for almost everyone

Refine the clock to modulo $8$ (period $28$) and something wonderful happens: the valuation becomes a fixed, knowable constant on almost every residue class. Define a lookup table $\nu(r)$ on the $28$ residues $r = m \bmod 28$:

- $\nu(r) = 1$ for $r \in \{0, 3, 7, 13, 14, 17, 21, 27\}$;
- $\nu(r) = 2$ for $r \in \{5, 6, 12, 20, 24\}$;
- $\nu(r) = 0$ for the twelve residues where $R_m$ is even.

> **Explicit Valuation Theorem.** For every $m$ whose residue mod $28$ is **not** one of $\{10, 19, 26\}$,
> $$\nu_2(R_m - 1) = \nu(m \bmod 28) \in \{0, 1, 2\}.$$

That covers $25$ of the $28$ residue classes — roughly $89\%$ of all whole numbers — with a formula you could evaluate in your head. Want $\nu_2(R_{100} - 1)$? Since $100 \bmod 28 = 16$, and $16$ is one of the "even" residues, the answer is $0$: $R_{100} - 1$ is odd. No need to compute the gigantic number $R_{100}$ at all.

## Level three: the three renegades and the fractal within

That leaves three residues out in the cold: $m \equiv 10, 19, 26 \pmod{28}$. These are precisely the positions where $R_m \equiv 1 \pmod 8$ — where the shifted number is divisible by a full $8$ and the simple table breaks down. Here the valuation is not constant. At $m = 10$ it is $4$; elsewhere in the same class it can be $5$, $6$, $9$, and higher. What tames this apparent chaos is the doubling clock.

Refine one more step, to modulo $16$ (period $56$). Each of the three renegade classes now splits cleanly into **two** finer classes, and in each pair the behavior separates perfectly:

> **Refinement Theorem.** Every $m$ with $m \bmod 28 \in \{10, 19, 26\}$ satisfies $8 \mid R_m - 1$ (so $\nu_2 \ge 3$). Passing to residues mod $56$, each such class splits into one class on which $\nu_2(R_m - 1) = 3$ **exactly**, and one class on which $\nu_2(R_m - 1) \ge 4$.

For example, the class $m \equiv 10 \pmod{28}$ splits into $m \equiv 38 \pmod{56}$, where the valuation locks in at exactly $3$, and $m \equiv 10 \pmod{56}$, where it climbs to $4$ or beyond. The class $m \equiv 26$ splits the other way: $m \equiv 26 \pmod{56}$ freezes at $3$, while $m \equiv 54 \pmod{56}$ keeps climbing.

This is the fractal heart of the sequence. At each new level of precision, exactly one "child" residue survives to carry the ever-larger valuations, while its sibling settles into a fixed value. The survivors form an infinite nested chain — a single thread of residues along which the valuation grows without bound. It is a **ruler sequence** in disguise: the same tick-tick-TICK-tick pattern that marks the inch, half-inch, and quarter-inch lines on a measuring tape, where a few special positions carry ever-taller marks.

One clean consequence: because the survivor set is never empty, the valuation $\nu_2(R_m - 1)$ eventually takes **every** natural number as a value. The first time each height is reached: valuation $0$ at $m=1$, $1$ at $m=3$, $2$ at $m=5$, $3$ at $m=26$, $4$ at $m=10$, $5$ at $m=110$, and so on up the ladder forever.

## Why anyone should care: a Diophantine payoff

This is more than a curiosity. Number theorists love equations that ask when a sequence value can also be a perfect square — the most famous being **Brocard's problem**, which asks for which $n$ the quantity $n! + 1$ is a perfect square (only three solutions are known, and whether there are others is still open after more than a century).

The Perrin analogue, the **Perrin–Brocard equation**, asks:

$$R_m = x^2 + 1, \qquad \text{equivalently} \qquad R_m - 1 = x^2.$$

Here the valuation formula earns its keep, through one elementary fact: **a perfect square always has an even 2-adic valuation.** ($x^2 = 2^{2\nu_2(x)} \cdot (\text{odd})$.) So the moment we know $\nu_2(R_m - 1)$ is *odd*, we know $R_m - 1$ cannot be a square, and that value of $m$ is eliminated instantly.

Look back at the explicit table. On the residues $\{0, 3, 7, 13, 14, 17, 21, 27\}$ the valuation is exactly $1$ — odd. Every single $m$ in those eight classes is disqualified without any further work. A hard search over infinitely many candidates collapses, class by class, into a short finite list. Combined with the exponential growth $R_m \sim \rho^m$, which bounds how large the remaining candidates can be, the valuation formula turns an open-ended hunt into a finite, checkable computation.

## The bigger picture

What makes this story satisfying is how a single structural fact — a period that doubles under each refinement — organizes everything else. The parity rule, the explicit table, the three renegades, the fractal refinement, and the Diophantine application all flow from that one doubling clock. And the mechanism is not special to Perrin: any sequence obeying a rule of the form $R_{n+3} = a\,R_{n+1} + b\,R_n$ with $b$ odd should carry the same kind of doubling clock and the same kind of explicit-plus-fractal valuation law. Perrin, with $a = b = 1$, is simply the cleanest window into a phenomenon that runs through a whole family of sequences.

The next time you see the Perrin numbers listed as a mere footnote to Fibonacci, remember that hidden inside them is a two-adic clockwork: mostly regular, occasionally wild, and — once you find the right lens — completely understood.
