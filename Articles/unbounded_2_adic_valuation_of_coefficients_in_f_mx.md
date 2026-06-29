# The Sequence That Cannot Stop Folding: Powers, Parity, and a Hidden Sierpiński Triangle

## A coin that remembers

Flip a coin again and again and write down the results — heads, tails, tails, heads — and you get pure noise. There is no pattern, no memory, nothing to predict. Now imagine a different kind of "coin," one that is completely deterministic yet looks, at first glance, just as patternless. This is the **Thue–Morse sequence**, one of the most quietly famous objects in mathematics.

Here is the recipe. Take any whole number $n$. Write it in binary. Count how many $1$'s appear. If that count is even, record a $+1$; if it is odd, record a $-1$. That single rule produces an infinite string of signs:

$$+1, -1, -1, +1, -1, +1, +1, -1, \dots$$

In symbols, define the **Thue–Morse sign** of $n$ as

$$\mathrm{tmsign}(n) = (-1)^{s_2(n)},$$

where $s_2(n)$ is the number of $1$-bits in the binary expansion of $n$ — equivalently, the digit sum of $n$ written in base $2$. So $\mathrm{tmsign}(0)=+1$ (zero ones), $\mathrm{tmsign}(1)=-1$ (one one), $\mathrm{tmsign}(3)=+1$ (two ones in $11_2$), and so on.

This sequence has a remarkable history. It was used by Axel Thue and Marston Morse over a century ago to build infinite strings that never repeat themselves in certain ways. It tells you how to share a cake fairly between two greedy children. It governs the "fairest" tournament schedules. And it hides, as we will see, an unexpected fractal.

## Turning a sequence into a power and asking what survives

Mathematicians love to package a sequence into a single algebraic object: a **generating function**. We collect the signs as the coefficients of an infinite polynomial in a variable $x$:

$$f(x) = \sum_{n \ge 0} \mathrm{tmsign}(n)\, x^n = 1 - x - x^2 + x^3 - x^4 + x^5 + x^6 - x^7 + \cdots$$

There is a beautiful closed form for this series. It factors as an infinite product over the powers of two:

$$f(x) = \prod_{k \ge 0} \left(1 - x^{2^k}\right) = (1-x)(1-x^2)(1-x^4)(1-x^8)\cdots$$

That product is exactly why the binary digits of $n$ control the signs: choosing whether to take the $-x^{2^k}$ term from each factor is the same as choosing the binary digits of an exponent, and each chosen factor contributes one more minus sign.

Now comes the central question of this story. What happens when we **raise $f$ to a power**? Fix an integer $m \ge 2$ and expand

$$f(x)^m = \sum_{n \ge 0} t_m(n)\, x^n.$$

The new coefficients $t_m(n)$ are no longer just $\pm 1$. They are honest integers, sometimes large, sometimes zero, and they encode how the Thue–Morse signs interfere with themselves $m$ times over. Computing one of them means summing many products of signs — the operation algebraists call a **convolution**. Concretely, the coefficients obey the bookkeeping rule of polynomial multiplication:

$$t_{m+1}(n) = \sum_{k=0}^{n} t_m(k)\, \mathrm{tmsign}(n-k),$$

starting from $t_1(n) = \mathrm{tmsign}(n)$.

These numbers $t_m(n)$ are subtle. A natural and surprisingly hard question, raised by Maciej Gawron, Piotr Miska, and Maciej Ulas, asks how *divisible by two* they can become. The **2-adic valuation** $\nu_2(N)$ of an integer $N$ counts how many times $2$ divides it: $\nu_2(12) = 2$ because $12 = 2^2 \cdot 3$, while $\nu_2(7) = 0$ because $7$ is odd. The conjecture is that the valuations $\nu_2(t_m(n))$ are **unbounded** — for every target $k$, no matter how large, some coefficient is divisible by $2^k$.

That is a statement about *infinitely deep* divisibility hiding inside a sequence built from coin-like signs. This package proves the foundational, exactly-verifiable layer of that story: a precise law for *when* these coefficients are even, odd, or richly divisible.

## The first surprise: the signs all become equal

Divisibility by $2$ is the same as asking a parity question — even or odd? So the right place to look is "modulo $2$," the world where we only remember the remainder after dividing by two. In that world $+1$ and $-1$ become indistinguishable, because $-1$ and $+1$ leave the same remainder when divided by $2$.

This is the first clean theorem of the package, and it is almost shockingly simple once stated:

> **Every Thue–Morse sign is $1$ modulo $2$.**
> Formally, $\mathrm{tmsign}(n) \equiv 1 \pmod 2$ for all $n$.

All the intricate $\pm$ structure — the very thing that makes Thue–Morse interesting — evaporates the moment we stop caring about signs. Modulo $2$, the elaborate sequence collapses to the dullest sequence imaginable: a flat line of $1$'s.

But this "collapse" is not a dead end. It is a doorway. If every sign is just $1$, then convolving with the signs is the same as convolving with the all-ones sequence — and convolving with all-ones is nothing but **taking running totals**.

## Running totals, Pascal's triangle, and the hockey stick

Convolving a sequence with $1, 1, 1, \dots$ replaces each term by the sum of all terms up to it — a cumulative sum. Do it once and you smooth the sequence; do it twice and you smooth it again; do it $m$ times and something classical emerges.

Iterated running sums of the constant sequence $1$ are exactly the diagonals of **Pascal's triangle**. The reason is a famous identity sometimes called the **hockey-stick identity**: summing a diagonal run of binomial coefficients produces a single binomial coefficient one step deeper. Stacking $m$ layers of summation onto the all-ones sequence therefore lands precisely on a binomial coefficient.

Carrying this reasoning through the modulo-$2$ world yields the centerpiece of the package — a complete description of the **parity shadow** of every power of $f$:

> **The parity of the $m$-th power coefficients is a single binomial coefficient.**
> For all $m, n \ge 0$,
> $$t_{m+1}(n) \equiv \binom{n+m}{m} \pmod 2.$$

Read that again, because it is doing a great deal of work. The left side is built from a hopelessly tangled $m$-fold self-interference of a non-repeating sign sequence. The right side is one entry of Pascal's triangle. Modulo $2$, they are the same. The chaos of Thue–Morse, raised to any power, is governed by the simplest combinatorial object in mathematics.

The proof is an induction on the power $m$. The base case $m=0$ just says the first power equals the signs, which are all $1$ modulo $2$. The inductive step rewrites the $(m{+}2)$-fold convolution using the recurrence, replaces every sign by $1$ (the collapse theorem), invokes the induction hypothesis to turn each summand into a binomial coefficient, and then collapses the whole sum with the hockey-stick identity. Every step is elementary; the magic is in how cleanly they compose.

## The fractal in the answer

Here is where the picture becomes beautiful. Which binomial coefficients $\binom{N}{r}$ are **odd**? The answer is one of the gems of nineteenth-century number theory, **Kummer's** and **Lucas's** theorem: $\binom{N}{r}$ is odd exactly when the binary digits of $r$ are "contained in" those of $N$ — every $1$ in $r$ sits under a $1$ in $N$, with no carrying when you add $r$ to $N-r$ in binary.

Color the odd entries of Pascal's triangle black and the even ones white, and you get the **Sierpiński triangle**, the most famous fractal of self-similar holes. Our parity law says that the even/odd pattern of the coefficients of *every power* $f(x)^m$ is literally a slice through this fractal. The places where $t_m(n)$ is even — the first whisper of $2$-adic divisibility — are dictated by a Sierpiński gasket.

So the question "when do these power coefficients become divisible by two?" has a fractal answer. Divisibility is not scattered randomly; it is organized by the carry patterns of binary addition, the same patterns that carve the holes in Sierpiński's triangle.

## Two powers we can read off completely

Specializing the parity law gives crisp, human-readable facts about the low powers — the cases one can check by hand and the ones that anchor the whole theory.

**The first power is always odd.** Because every sign is $\pm 1$, the coefficient $t_1(n) = \mathrm{tmsign}(n)$ is odd for every $n$:

> $t_1(n) \equiv 1 \pmod 2$ for all $n$.

This is the trivial floor: the first power has no $2$-adic divisibility at all. To find deep divisibility you must go to higher powers.

**The square has the parity of $n+1$.** Setting $m=1$ in the parity law uses $\binom{n+1}{1} = n+1$ and gives a wonderfully simple rule:

> $t_2(n) \equiv n + 1 \pmod 2.$

Equivalently:

> **The squared coefficient $t_2(n)$ is odd exactly when $n$ is even.**

So in the square $f(x)^2$, evenness of the coefficient is perfectly synchronized with the parity of its position: even positions give odd coefficients, odd positions give even ones. Half of all the coefficients of the square are divisible by $2$ — and the parity law tells you precisely which half.

## From parity to infinite depth

These parity statements are the *first floor* of a tower. Knowing when $t_m(n)$ is divisible by $2$ is the entry point to asking how *often* it is divisible — whether $\nu_2(t_m(n))$ can be made as large as we please.

The square is the perfect test case, and here the story has a spectacular punchline. Look at the coefficients sitting at the **Mersenne positions** $n = 2^k - 1$ (the numbers $1, 3, 7, 15, 31, \dots$ whose binary expansions are all $1$'s). For the square, these coefficients are not merely divisible by high powers of two — they are powers of two, on the nose:

$$t_2(2^k - 1) = (-2)^k.$$

Each time you climb to the next Mersenne number you pick up exactly one more clean factor of $2$. The valuation marches off to infinity in lockstep, $\nu_2(t_2(2^k-1)) = k$, settling the unboundedness conjecture for $m=2$ in the sharpest possible form. The humble parity rule $t_2(n) \equiv n+1$ is the $k=1$ shadow of this exact law, and the modulo-$2$ collapse is the engine that makes the whole contraction run.

The pattern continues, conjecturally, across all powers. Computational evidence suggests the valuation along Mersenne positions grows *linearly* — like $c_m \cdot k$ for a slope $c_m$ that depends on $m$ — with the cleanest behavior at powers of two ($m = 2, 4, 8$ all give slope $1$) and a curious $3/2$ slope at $m = 3$ and $m = 5$. There is even a delicate twist: for odd $m \ge 3$, some coefficients vanish outright, $t_m(n) = 0$, which one might generously call "infinite divisibility." The parity shadow rules out *random* vanishing — since binomial coefficients are never all even, any genuine zero must come from a higher, more delicate cancellation in the full integers, not from the modulo-$2$ picture.

## Why it matters

At one level this is a story about a single quirky sequence. At another, it is a parable about a recurring miracle in mathematics: a wildly complicated object, viewed through the right lens, becomes utterly transparent. The lens here is reduction modulo $2$, and the transparency it reveals is a binomial coefficient — and behind that, a fractal.

These power coefficients are not idle curiosities. Thue–Morse-style sequences and their convolutions appear in the analysis of digital sums, in the construction of sequences that resist repetition, in the spectral theory of aperiodic crystals, and in the arithmetic of automatic sequences. Understanding the $2$-adic texture of $f(x)^m$ — exactly when its coefficients are even, and how deeply they are divisible — is a step toward understanding a whole family of such generating functions.

And there is a deeper aesthetic lesson. The number $2$ plays a triple role here: it is the base in which we write the numbers, it is the prime whose divisibility we measure, and it is the spacing of the gaps in the infinite product that defines $f$. When all three twos line up — base, prime, and product — the result is not coincidence but structure: signs that collapse, sums that telescope, and a fractal that surfaces, unbidden, from a sequence that simply refuses to stop folding.
