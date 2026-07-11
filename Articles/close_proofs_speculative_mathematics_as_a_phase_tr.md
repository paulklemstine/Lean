# The Staircase Hidden in the Fibonacci Numbers

## When growth happens all at once

Some things in nature change smoothly, and some things change in jumps. Heat a
block of ice and its temperature climbs steadily — until, at exactly zero
degrees, something abrupt happens: the whole solid reorganizes into liquid. Add
one more link to a random network and, right at a critical density, isolated
clusters suddenly fuse into a single spanning web. Physicists call these
moments *phase transitions*: long stretches of quiet, incremental change,
punctuated by sudden, sharp reorganizations.

Mathematical discovery often feels the same way. For years a subject inches
forward, and then a single idea snaps all the scattered fragments into place.
This article is about a small, exact, and beautiful instance of that pattern —
one that lives inside the most famous sequence in all of mathematics, the
Fibonacci numbers, and that behaves not like a smooth curve but like a
staircase, rising in perfectly quantized steps.

The Fibonacci numbers are
$$F_0 = 0,\ F_1 = 1,\ F_2 = 1,\ F_3 = 2,\ F_4 = 3,\ F_5 = 5,\ F_6 = 8,\ F_7 = 13,\ \dots$$
each the sum of the two before it. They appear in sunflower spirals, in the
branching of trees, in the analysis of algorithms, and in the deep arithmetic
of the whole numbers. The result we celebrate here is about that last, hidden
face: how prime numbers divide the Fibonacci sequence, and how the *amount* by
which they divide it grows in sudden, unit-sized jumps.

## The question: how deeply does a prime divide?

Pick a prime number $p$ — say $p = 11$. Scan down the Fibonacci list and ask:
which terms does $11$ divide? You find $F_{10} = 55 = 5 \cdot 11$, and then
$F_{20} = 6765 = 3 \cdot 5 \cdot 11 \cdot 41$, and $F_{30}$, and $F_{40}$, and
so on — every tenth term. The number $10$ is called the *rank of apparition* of
$11$: the first place the prime shows up. After that, it reappears at every
multiple of its rank, like clockwork.

But there is a subtler question than *whether* a prime divides a term. We can
ask *how deeply* it divides — how many factors of $p$ we can pull out. This
depth is called the **$p$-adic valuation**, written $v_p$. For example
$v_{11}(55) = 1$ because $55 = 11^1 \cdot 5$, while $v_2(8) = 3$ because
$8 = 2^3$. The valuation measures the "altitude" of a prime inside a number.

Now watch what happens to that altitude as we walk along the multiples of the
rank. Take $p = 11$ again, whose rank is $10$:
$$v_{11}(F_{10}) = 1, \quad v_{11}(F_{110}) = 2, \quad v_{11}(F_{1210}) = 3, \dots$$
Each time we multiply the index by $11$, the altitude of $11$ climbs by
*exactly one*. Not by two, not by a fluctuating amount — by one, cleanly, every
single time. This is the staircase: a discrete, perfectly regular ascent hiding
inside an exponentially exploding sequence.

## The theorem: a sharp, quantized step

Here is the precise statement, the centerpiece of this work.

> **Fibonacci Lifting-the-Exponent Theorem.** Let $p$ be an *odd* prime, and
> suppose $p$ already divides the Fibonacci number $F_m$ (with $m \ge 1$). Then
> $$v_p\big(F_{m p}\big) = v_p\big(F_m\big) + 1.$$

In words: once a prime has appeared in the sequence, multiplying the index by
that prime raises the prime's depth by exactly one. The transition is *sharp* —
each application of the operation "multiply the index by $p$" moves the system
up precisely one quantized level, the arithmetic analogue of a phase boundary
crossed cleanly rather than smeared out.

The word *odd* in the hypothesis is not decorative; it is the whole story. For
$p = 2$ the staircase breaks. Because of the doubling identity
$F_{2k} = F_k \cdot L_k$ (where $L_k$ is the companion Lucas number), the power
of $2$ can leap by more than one at a step. The single-step law is a phenomenon
of *odd* primes, and the proof pinpoints exactly why.

## The engine: a binomial expansion in disguise

How do you prove such a thing? The key is a startling identity that lets you
"factor" a Fibonacci number sitting at a composite index. The golden ratio
$\varphi = \tfrac{1+\sqrt 5}{2}$ satisfies $\varphi^2 = \varphi + 1$, and more
generally
$$\varphi^{\,m+1} = F_{m+1}\,\varphi + F_m.$$
Raise both sides to the $n$-th power and expand with the ordinary binomial
theorem. Because $\varphi$ is irrational, the "rational part" and the
"$\varphi$-part" of the two sides must match independently — like matching real
and imaginary parts of a complex equation. Reading off the coefficient of
$\varphi$ produces a clean, exact formula:

> **Multiple-Index Binomial Expansion.** For all whole numbers $m$ and $n$,
> $$F_{(m+1)\,n} \;=\; \sum_{j=0}^{n} \binom{n}{j}\, F_m^{\,n-j}\, F_{m+1}^{\,j}\, F_j.$$

This is the workhorse. It expresses a far-off Fibonacci number as a binomial-type
sum built from two adjacent ones. To prove the lifting-the-exponent law, set
$n = p$, an odd prime, and study the sum term by term through the lens of the
valuation $v_p$.

Something delightful now happens. In the sum
$$F_{mp} \;=\; \sum_{j=0}^{p} \binom{p}{j}\, F_{m-1}^{\,p-j}\, F_m^{\,j}\, F_j,$$
almost every term is *deeply* divisible by $p$ and therefore invisible at the
relevant altitude:

- The **interior binomial coefficients** $\binom{p}{j}$ for $1 < j < p$ are all
  divisible by $p$ — a classical fact that makes Pascal's triangle "flatten"
  modulo a prime.
- The **powers** $F_m^{\,j}$ for $j \ge 2$ contribute at least twice the current
  depth, since $p$ already divides $F_m$.

Add these up and every term with $j \ge 2$ carries depth at least $v_p(F_m) + 2$
— they all sit *above* the step we care about. The $j = 0$ term vanishes because
$F_0 = 0$. What survives, alone at the critical altitude, is the single $j = 1$
term:
$$p \cdot F_{m-1}^{\,p-1} \cdot F_m.$$
Its depth is exactly $v_p(F_m) + 1$: one factor of $p$ from the coefficient, the
original depth from $F_m$, and *nothing extra* from $F_{m-1}$, because
consecutive Fibonacci numbers are coprime — so $p$ cannot divide $F_{m-1}$. One
term rises to the new level; all others overshoot it. The valuation of the whole
sum is therefore pinned to precisely $v_p(F_m) + 1$.

This is the mathematical picture of a sharp transition: a competition among many
contributions in which exactly *one* achieves the critical threshold while the
rest are pushed strictly beyond it. The single surviving term is the order
parameter of the phase change.

## Why it matters: intrinsic primes and the shape of the sequence

This exact step law is not a curiosity; it is a precision instrument. Sequences
like the Fibonacci numbers are governed by one of the jewels of number theory,
the theory of **primitive divisors** — the statement that (with a short list of
small exceptions) every term $F_n$ contains a brand-new prime that has never
divided any earlier term. This is the Fibonacci face of the celebrated
Zsigmondy and Carmichael theorems.

To make such statements airtight you must control not only *which* primes appear
but *with what multiplicity*. The lifting-the-exponent law does exactly that: it
proves that an *intrinsic* prime — one making its debut at index $n$ — enters
with multiplicity exactly one, never doubled up, never hidden. The staircase
climbs one step at a time, and that regularity is what lets one prove there is
always room for a fresh prime. In this way the small, sharp local law underwrites
a sweeping global theorem about the arithmetic architecture of the sequence.

## The bigger idea: discovery as percolation

The staircase inside the Fibonacci numbers is a metaphor made rigorous. It is
the arithmetic embodiment of the broader thesis that motivates this work:
important transitions — in physics, in networks, and even in the growth of
knowledge itself — are frequently **sharp thresholds** rather than gentle
slopes. A monotone process, one that only ever accumulates and never undoes its
progress, tends to concentrate all of its drama at a single critical point.

To make that intuition precise, consider *positional number systems* with mixed
bases — the familiar decimal system uses base ten everywhere, but one can let the
$i$-th digit run over its own base $b_i$. The most elegant such system is the
*factorial number system*, whose $i$-th place has base $i + 1$, so that a word of
length $n$ can represent every value up to $(n+1)! - 1$. Ask a monotone yes/no
question about the value a word represents — for instance, "is the value at least
$N$?" As the word grows longer, the answer flips from *no* to *yes* exactly once,
at a **critical length**, and never flips back. That single crossing is a sharp
threshold: the discrete cousin of a percolation transition, and a template for
the sudden reorganizations that punctuate long stretches of incremental work.

Three natural conjectures grow from this seed. First, that *every* monotone
representational event of this kind has a computable critical length — a definite
tipping point one can calculate in advance. Second, that sharpness is preserved
under combination: run two independent threshold processes together, and "both
succeed" tips at the *later* of the two critical lengths while "either succeeds"
tips at the *earlier* one, a clean max/min calculus for compound transitions.
Third, that among all such systems with comparably small bases, the factorial
system is the *slowest to percolate* — its capacity crosses each target later
than any competitor — because its running product of bases grows as slowly as the
rules allow.

## The moral

Growth is not always gradual. Sometimes it is a staircase — flat, then a clean
step, then flat again — and the deepest understanding comes from finding the
single term, the single crossing, the single link that tips the whole system to
its next level. The Fibonacci lifting-the-exponent law is a jewel-sized example:
an exact, quantized, sharp transition, proved by isolating the one contribution
that reaches the critical height while all others sail past it. In its small,
precise way it shows how a phase transition looks from the inside — and why the
mathematics of sudden change is as beautiful as it is useful.
