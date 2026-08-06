# How Much Room Does Truth Take Up?

## A coastline made of theorems

Ask how long the coastline of Britain is and you get a famously unsatisfying answer: it depends on your ruler. Measure with a $100$-kilometre stick and you get one number; measure with a $1$-metre stick and you get a much bigger one. The honest description is not a length at all but a *dimension* — a number, typically somewhere between $1$ and $2$, that records how fast the measured length blows up as the ruler shrinks. Coastlines, snowflakes, lungs, lightning: nature is full of objects that live between the integers.

This article is about applying that same ruler to a very different kind of object: the set of true statements.

Here is the picture. Fix a formal language in which every statement is written as a finite string of bits — a sequence of $0$s and $1$s. This is not exotic; it is what a computer does to a mathematical claim before it can even store it. Among all $2^n$ possible bit strings of length $n$, only some are the statements that a given body of mathematics accepts as true. Call that collection the *theory*. The question is: how big is it?

Counting is the wrong measure, because the answer always grows exponentially and always sits between $1$ and $2^n$. The right measure is the *exponential rate*. If a theory accepts about $2^{dn}$ strings of length $n$, then $d$ is the number we want, and $d$ turns out to be exactly a fractal dimension — a box-counting dimension of the space of infinite bit sequences, where the "boxes" are the sets of sequences agreeing on their first $n$ bits.

Formally, write $\mathrm{count}(T,n)$ for the number of length-$n$ statements a theory $T$ accepts, and define the *finite-scale estimate*
$$
\delta_T(n) \;=\; \frac{\log_2 \mathrm{count}(T,n)}{n}.
$$
The **fractal dimension** of the theory is the limiting value of these estimates as the strings get longer:
$$
\dim T \;=\; \limsup_{n \to \infty} \frac{\log_2 \mathrm{count}(T,n)}{n}.
$$
This is exactly the box-counting recipe $\log(\text{number of boxes})/\log(1/\text{box size})$, with boxes of size $2^{-n}$.

## The two easy facts, and why they matter

Two facts are immediate and worth stating because they pin the scale.

**Every theory has dimension between $0$ and $1$.** The upper bound is just the observation that a theory cannot accept more than all $2^n$ strings of length $n$, so $\log_2 \mathrm{count}(T,n) \le n$ and every finite estimate is at most $1$. The lower bound is that counts are never negative, so every finite estimate is at least $0$. Take the $\limsup$ and the interval $[0,1]$ survives.

**Bigger theories have bigger dimension.** If $T$ accepts every string that $T'$ accepts (and possibly more), then $\mathrm{count}(T',n) \le \mathrm{count}(T,n)$ at every length, so the finite estimates are ordered, so the limits are ordered. Dimension is monotone under inclusion. Adding axioms — or, rather, admitting more statements — can never shrink the dimension.

So dimension is a genuinely order-respecting size measure on theories, valued in the unit interval. The interesting question is: **which numbers in $[0,1]$ actually occur?**

## A first data point: the half-information theory

Consider a theory in which every second bit of a statement is *forced*. Concretely: the bits in even positions are free — a legal statement may have either value there — while the bits in odd positions must be $0$. A string of length $n$ is accepted exactly when it obeys this rule.

How many such strings are there? Exactly $2^{\#\{\text{free positions below } n\}}$, and roughly half of all positions are free, so the count is about $2^{n/2}$. Divide the logarithm by $n$ and the finite estimates converge to $1/2$. This theory has fractal dimension exactly one half.

That is a pretty result, and it invites a suspicion: is $1/2$ special? Is there something canonical about half-information? Or is $1/2$ just an accident of the particular pattern chosen?

## The answer: nothing is special about one half

The main theorem says the $1/2$ is an accident of the pattern, and that the fractal dimension is nothing more nor less than **the asymptotic density of information-bearing coordinates**.

To make this precise, fix a *modulus* $m \ge 1$ and a set $R \subseteq \{0,1,\dots,m-1\}$ of *admissible residues*. Define the **periodic density theory** $D(m,R)$: a length-$n$ string is accepted exactly when every coordinate $i$ with $i \bmod m \notin R$ carries the value $0$. In words, position $i$ is free if and only if its residue modulo $m$ is admissible; otherwise it is frozen. The half-information theory above is $D(2,\{0\})$.

> **Density Theorem.** For every modulus $m \ge 1$ and every set of admissible residues $R \subseteq \{0,\dots,m-1\}$, the periodic density theory $D(m,R)$ has fractal dimension exactly
> $$\dim D(m,R) \;=\; \frac{|R|}{m}.$$
> Moreover the finite-scale estimates do not merely have this $\limsup$: they genuinely converge to it.

The proof is a piece of clean combinatorics followed by a squeeze. Let $F(n)$ be the number of admissible positions below $n$ — the number of $i < n$ with $i \bmod m \in R$.

*Step 1: an exact count.* A string is accepted precisely when each frozen coordinate is $0$ and each free coordinate is arbitrary. The accepted set is therefore a product: two choices at each of the $F(n)$ free positions, one choice at each of the rest. So
$$
\mathrm{count}(D(m,R),n) \;=\; 2^{F(n)},
$$
exactly — no approximation. This collapses the logarithm completely: the finite-scale estimate is simply $F(n)/n$, a ratio of integers.

*Step 2: periodicity.* Sliding the window by one full period adds exactly $|R|$ admissible positions:
$$
F(n+m) \;=\; F(n) + |R|.
$$
The reason is that the positions $n, n+1, \dots, n+m-1$ form a complete residue system modulo $m$, so among them exactly the $|R|$ residues in $R$ occur, each once.

*Step 3: a two-sided sandwich.* Iterating the periodicity from $F(0)=0$ gives $F(mq) = |R|\,q$ exactly at multiples of the period. Since $F$ is nondecreasing, an arbitrary $n$ is trapped between the nearest multiples of $m$ below and above it:
$$
|R| \left\lfloor \frac{n}{m} \right\rfloor \;\le\; F(n) \;\le\; |R| \left\lfloor \frac{n}{m} \right\rfloor + |R|.
$$
The two ends differ by only $|R|$ — a constant, independent of $n$.

*Step 4: the squeeze.* Divide by $n$. Since $\lfloor n/m \rfloor / n \to 1/m$, both ends converge to $|R|/m$, and the additive slack $|R|/n$ vanishes. In fact the estimate is quantitative: for every $n \ge 1$,
$$
\left| \frac{F(n)}{n} - \frac{|R|}{m} \right| \;\le\; \frac{|R|}{n},
$$
so the convergence is at rate $O(1/n)$. Since the estimates converge, the $\limsup$ equals the limit, and the dimension is $|R|/m$. $\blacksquare$

Notice what the proof never used: the *identity* of the admissible residues. Whether you free positions $\{0,1\}$ out of every three or positions $\{0,2\}$ out of every three, you get dimension $2/3$. Only the cardinality $|R|$ matters. That indifference is exactly what makes the next theorem work.

## Every rational dimension is a dimension of truth

Because we may choose $m$ and $|R|$ freely, we can hit any ratio we like.

> **Realization Theorem.** Every rational number in $[0,1]$ is the fractal dimension of some theory. Precisely, for natural numbers $p \le q$ with $q \ge 1$, the periodic density theory of modulus $q$ that frees exactly the residues $\{0,1,\dots,p-1\}$ has fractal dimension exactly $p/q$.

The proof is a single line given the Density Theorem: $R = \{0,\dots,p-1\}$ is a subset of $\{0,\dots,q-1\}$ with $|R| = p$, so the dimension is $p/q$.

This is not an abstract existence statement. It is a recipe. Want a theory of dimension $3/7$? Take strings, free the positions congruent to $0,1,2 \pmod 7$, and force the rest to zero. Its dimension is $3/7$, on the nose, and the finite-scale estimates converge to it at rate $O(1/n)$.

The three landmark values fall out as instances of the same law:

- **Dimension $1$**: modulus $1$, all residues admissible. Every coordinate is free, the theory is the whole space of $2^n$ strings, and the dimension is $1$. Maximal informational richness.
- **Dimension $1/2$**: modulus $2$, one admissible residue. The half-information theory, recovered as a special case rather than a curiosity.
- **Dimension $0$**: modulus $1$, no residue admissible. Every coordinate is frozen, exactly one string of each length is accepted, and the dimension is $0$. A theory with a unique statement at every length carries no exponential information at all.

Because both endpoints are attained, the universal bounds $0 \le \dim T \le 1$ are sharp: no strictly better universal inequality exists.

## What the number means

It is tempting to read fractal dimension as "how much is true", but that is not quite it. Every one of these theories has infinitely many accepted statements. What dimension measures is the **exponential rate of informational freedom** — the fraction of a statement's description that is genuinely at your disposal, as opposed to being determined by the rules of the theory.

Seen that way, the number has a compression reading. A theory of dimension $d$ is one whose length-$n$ statements can be losslessly described using about $dn$ bits instead of $n$: a statement of the theory is compressible by a factor of $d$. Dimension $1$ means incompressible — knowing you are in the theory tells you nothing. Dimension $0$ means totally determined — the theory's constraints supply all the information, and there is nothing left to specify. Dimension $1/2$ means half the bits are prescribed by the theory and half are yours to choose.

There is also an *anti-Cantor* flavour to the result worth naming. The classical middle-thirds Cantor set has box dimension $\log 2/\log 3 \approx 0.6309$, an irrational number, and it is the archetype of a fractal built by deleting according to a fixed rule. Here the periodic density theories are Cantor-type subsets of the space of infinite bit sequences too — deleting according to a fixed rule — but the deletions happen coordinate-by-coordinate rather than by scaling, and this makes the achievable dimensions the rationals. The rational spectrum is an artefact of periodicity, not a limitation of the framework: replacing the periodic pattern by an arbitrary set of free coordinates of asymptotic density $d$ makes the same squeeze argument yield dimension $d$, so with an aperiodic pattern of irrational density, irrational dimensions appear immediately. What the theorem establishes is that the rationals are already all there, realized by patterns as simple as "free every third coordinate".

## Why the $\limsup$, and not a limit

A pedantic-looking choice in the definition earns its keep here. Why $\limsup$ rather than $\lim$?

Because for a general theory the finite-scale estimates need not converge. Imagine a theory whose free-coordinate density oscillates: long stretches where almost every coordinate is free, alternating with much longer stretches where almost none is. Choose the stretch lengths to grow fast enough and $\delta_T(n)$ will swing back and forth without settling — approaching $1$ along one subsequence and $0$ along another. There is no limit to speak of. The $\limsup$ still exists, still lies in $[0,1]$, and still records the theory's most generous asymptotic rate.

The periodic density theories are the well-behaved case, and one of the small pleasures of the Density Theorem is that it says so explicitly: for them the $\limsup$ is a genuine limit, with an $O(1/n)$ error bound attached. Regularity of the pattern buys convergence; the $\limsup$ is there for when regularity fails.

The monotonicity theorem needs the $\limsup$ formulation too, and it needs one more piece of care: what if a theory accepts *nothing* at some length? Then $\mathrm{count} = 0$ and $\log_2 0$ is undefined. The convention here is $\log_2 0 = 0$, so an empty level contributes an estimate of $0$ — the smallest possible value, which is exactly the right behaviour for a monotonicity statement. Empty levels can only push the dimension down, never up.

## A ruler for theories

What has been built is a size measure for bodies of mathematical truth, defined by counting, valued in $[0,1]$, monotone under inclusion, with both endpoints attained, and — this is the content of the main theorem — with a complete and constructive account of every rational value it can take.

The number is not mystical. It is a rate: the exponential growth rate of the accepted statements, equivalently the asymptotic density of information-bearing coordinates, equivalently the compressibility of the theory's statements. What makes it satisfying is that these three readings coincide exactly, and that the coincidence can be checked on explicit examples with an exact formula, $\mathrm{count} = 2^{F(n)}$, holding at every finite length rather than only in the limit.

The next time someone asks how big a theory is, there is now a number to hand them — and a construction that will produce a theory of any rational size they name.
