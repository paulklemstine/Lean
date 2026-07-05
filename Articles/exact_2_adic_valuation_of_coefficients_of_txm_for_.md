# The Sequence That Remembers How It Was Made

## A whisper hidden in the powers of two

Some numbers carry a signature. When an engineer wants to know how a whole number behaves inside a binary computer, one of the first things they ask is: *how many times is it divisible by two?* That count — the number of trailing zeros in the binary expansion — is called the **2-adic valuation**, written $\nu_2$. For example, $\nu_2(2376) = 3$, because $2376 = 2^3 \cdot 297$ and $297$ is odd. The 2-adic valuation is the arithmetic fingerprint of a number in the world of binary machines: it tells you how much "room" a number has before its lowest bits become significant, and it governs everything from overflow behavior to the accuracy of low-precision arithmetic.

This article is about a family of integer sequences whose 2-adic fingerprints turn out to be astonishingly regular — and about a beautiful, plausible-sounding formula that almost everyone would have believed, which turns out to be *wrong* except in one magical case.

## The Thue–Morse machine

Our story begins with one of the most famous objects in all of mathematics: the **Thue–Morse sequence**. Take a whole number $n$, write it in binary, and count the ones. If the count is even, record $+1$; if odd, record $-1$. This gives the sequence of signs
$$
+1,\; -1,\; -1,\; +1,\; -1,\; +1,\; +1,\; -1,\; \dots
$$
It is the tape of a machine with no memory of position, only of parity, and it appears everywhere: in the theory of aperiodic tilings, in fair division ("you take one, I take one, I take one, you take one…"), in chess endgame rules, and in the construction of sequences that avoid repetition.

Package these signs into a single generating function, an infinite formal series
$$
T(x) = \sum_{n \ge 0} (-1)^{s(n)}\, x^n = 1 - x - x^2 + x^3 - x^4 + \cdots,
$$
where $s(n)$ is the number of ones in the binary expansion of $n$. This series has a breathtakingly clean product form,
$$
T(x) = \prod_{k \ge 0} \bigl(1 - x^{2^k}\bigr) = (1-x)(1-x^2)(1-x^4)(1-x^8)\cdots,
$$
because multiplying out the factors reproduces exactly the sign rule: each factor $(1 - x^{2^k})$ decides whether bit $k$ is present, and each present bit flips the sign. This product form hides a self-similarity that is the engine of everything that follows. Splitting off the very first factor gives the **functional equation**
$$
T(x) = (1-x)\,T(x^2),
$$
a compact statement that $T$ contains a rescaled copy of itself.

## Raising the machine to a power

Now comes the twist that turns a classical object into a fresh research question. Instead of studying $T(x)$ itself, raise it to an odd power $m$ and read off the coefficients:
$$
T(x)^m = \sum_{n \ge 0} t_m(n)\, x^n.
$$
Each $t_m(n)$ is an integer — a signed count of the ways to write $n$ as a sum of $m$ "Thue–Morse pieces." For $m = 5$ the first few coefficients are
$$
1,\; -5,\; 5,\; 15,\; -40,\; 24,\; 40,\; -120,\; 135,\; 45,\; -301,\; \dots
$$
At first glance these look like noise. But raise the functional equation to the $m$-th power and a rigid skeleton appears:
$$
T(x)^m = (1-x)^m\, T(x^2)^m .
$$
The polynomial $(1-x)^m$ has only $m+1$ terms, its binomial coefficients, and $T(x^2)^m$ is just the same sequence stretched onto the even powers. Reading off coefficients turns this into a **recursion that folds the sequence onto itself at half scale**. For $m = 5$, using $(1-x)^5 = 1 - 5x + 10x^2 - 10x^3 + 5x^4 - x^5$, the recursion is
$$
\begin{aligned}
t_5(2s) &= t_5(s) + 10\,t_5(s-1) + 5\,t_5(s-2),\\
t_5(2s+1) &= -\bigl(5\,t_5(s) + 10\,t_5(s-1) + t_5(s-2)\bigr),
\end{aligned}
$$
with $t_5(0) = 1$ and $t_5(k) = 0$ for $k < 0$. Every coefficient of $T(x)^5$ is determined by two coefficients at half the index — a doubling structure that is the arithmetic shadow of the sequence's binary self-similarity.

## A formula too good to be true

Here is where a natural conjecture entered the picture. Empirically, the 2-adic valuations $\nu_2(t_m(n))$ are not scattered at all: for $m \equiv 1 \pmod 4$ they seem to depend on the index $n$ only through a single quantity, $\nu_2(n+1)$ — how divisible $n+1$ is by two. Even better, within each **block** of $m-1$ consecutive indices, the valuation appears *constant*. This suggested a single master formula for every $m \equiv 1 \pmod 4$:
$$
\nu_2\bigl(t_m((m-1)n + j)\bigr) \;\stackrel{?}{=}\; (m-1)\left\lceil \tfrac{\nu_2(n+1)}{2}\right\rceil - \tfrac{m-1}{4}\,\bigl(\nu_2(n+1) \bmod 2\bigr),
$$
for all offsets $j \in \{0, 1, \dots, m-2\}$. It is elegant, it is dimensionally sensible, and it is exactly the kind of clean law that begs to be true.

It is not.

## The counterexample at $m = 9$

Test the formula at the smallest interesting case beyond $m = 5$: take $m = 9$, $n = 1$, $j = 0$. Then the index is $(m-1)n + j = 8$, and $\nu_2(n+1) = \nu_2(2) = 1$. The formula predicts
$$
\nu_2(t_9(8)) = 8\left\lceil \tfrac{1}{2}\right\rceil - 2\cdot(1 \bmod 2) = 8 - 2 = 6,
$$
which would mean $t_9(8)$ is divisible by $2^6 = 64$. But a direct computation gives
$$
t_9(8) = 2376 = 2^3 \cdot 297,
$$
so its true valuation is $\nu_2(t_9(8)) = 3$, not $6$. The universal formula is decisively false. And this is no rounding accident: for $m = 9$ the valuations obey a *different* clean law,
$$
\nu_2\bigl(t_9(8n + j)\bigr) = \left\lfloor \tfrac{5\,\nu_2(n+1) + (\nu_2(n+1) \bmod 2)}{2}\right\rfloor,
$$
and for $m = 13$ the block-constancy itself collapses — within a single block the valuation now varies with $j$, taking values like $4,4,4,4,10,7,6,6,0,0,0,0$ across the twelve offsets. The tidy picture survives only in fragments.

## Why $m = 5$ is special

So the master formula was overfitted to a single lucky exponent. Why $m = 5$? The answer lies in the binomial coefficients of $(1-x)^m$ and their divisibility by two — the arithmetic that Kummer's theorem ties to carrying when you add $m$ to itself in binary. For $m = 5 = (101)_2$, the low-order binomial coefficients line up so that, **modulo two**, the recursion collapses dramatically. The middle coefficient $10$ is even and vanishes mod $2$, the sign in front of the odd branch becomes irrelevant, and both halves of the doubling recursion reduce to the *same* rule:
$$
t_5(n) \equiv t_5\!\left(\lfloor n/2\rfloor\right) + t_5\!\left(\lfloor n/2\rfloor - 2\right) \pmod 2, \qquad n \ge 4.
$$
Follow this collapse to its conclusion and the parity of every coefficient is pinned down exactly:
$$
t_5(n) \bmod 2 = 1 - \bigl(\lfloor n/4\rfloor \bmod 2\bigr).
$$
In words: **$t_5(n)$ is odd precisely when $\lfloor n/4\rfloor$ is even.** The coefficients march in blocks of four; the first four are all odd, the next four all even, the next four odd again, and so on forever. This is the exact, fully general "ground floor" of the corrected $m = 5$ law
$$
\nu_2\bigl(t_5(4q + j)\bigr) = 2\,\nu_2(q+1) + \bigl(\nu_2(q+1) \bmod 2\bigr), \qquad j \in \{0,1,2,3\},
$$
on the layer where $\nu_2(q+1) = 0$ — that is, where $q$ is even and the valuation is exactly zero.

## The sequence that encodes its own instructions

The deepest surprise lies one level up. Strip the common power of two from each block of four $m=5$ coefficients, leaving four odd residues. Reduced modulo $8$, these always form a permutation of $\{1, 3, 5, 7\}$ — and there are only *two* patterns that ever occur. Which one appears in a given block is chosen, block by block, by the Thue–Morse sign of the half-index. The sequence built from $T(x)$ carries the Thue–Morse word inside itself as a control tape, selecting between two templates like a machine reading its own blueprint. It is a genuine fixed-point phenomenon, not a coincidence: the object remembers how it was made.

## Why this matters beyond the curiosity

Coefficients of $T(x)^m$ are signed counts arising from repeated binary convolutions — exactly the shape of computation that happens when low-precision numbers are multiplied and accumulated inside modern machine-learning hardware. The 2-adic valuation of such a coefficient is precisely the number of low bits that are guaranteed to be zero, which is the number of bits of headroom before rounding error can appear. A clean valuation law is therefore a clean statement about *where the noise floor sits* in a cascade of binary products. The lesson of $m = 5$ versus $m = 9$ and $m = 13$ is a cautionary and constructive one at once: the regularity is real, it is governed by the binary structure of the exponent, and the one exponent whose binomial carries line up perfectly is the one whose fingerprint is perfectly predictable. The others still obey laws — just their own.

The moral is the oldest one in mathematics dressed in binary clothing. A pattern that holds in the first case, and the second, and the third, is a promise, not a proof. Sometimes the promise is kept in exactly one place, and the real theorem is the honest account of where — and why — the magic runs out.
