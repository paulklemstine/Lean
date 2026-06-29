# The Music Hidden in Powers of Two: How Repunits Tame an Infinite Product

## A puzzle that refuses to settle down

Imagine you are handed an infinite multiplication problem. Not a sum, but a product — and not of numbers, but of polynomials. You start with the term $(1 - x)$, then multiply by $(1 - x^2)$, then by $(1 - x^4)$, then $(1 - x^8)$, and so on forever, each new factor using the next power of two as its exponent. And to make it interesting, you square every factor. The object you are building is

$$\prod_{i=0}^{\infty} \left(1 - x^{2^i}\right)^2 = (1-x)^2 (1-x^2)^2 (1-x^4)^2 (1-x^8)^2 \cdots$$

If you patiently multiply this out, you get an infinite string of coefficients — one number in front of $x^0$, one in front of $x^1$, one in front of $x^2$, and so on. Call the coefficient of $x^n$ by the name $T(n)$. The first few values are

$$1, \; -2, \; 1, \; 2, \; -2, \; \dots$$

a jagged, sign-flipping sequence of integers. Now comes the deceptively simple question that has occupied number theorists: **does this sequence stay bounded, or do its values eventually grow without limit?** In other words, is there some ceiling $B$ such that $|T(n)| \le B$ for every $n$, or can you always find an index $n$ where $|T(n)|$ blows past any ceiling you name?

This is the kind of question that looks like it should have an easy answer and doesn't. The coefficients dance around near zero for a long time. They look almost tame. But appearances deceive.

## The Gawron–Miska–Ulas conjecture

The general version of this puzzle replaces the number $2$ with any integer **base** $b \ge 2$, and replaces the exponent $2$ on each factor with any integer **multiplicity** $m \ge 2$. For each choice of $b$ and $m$ we get a sequence

$$T_{b,m}(n) = \text{the coefficient of } x^n \text{ in } \prod_{i=0}^{\infty} \left(1 - x^{b^i}\right)^m.$$

The conjecture of Gawron, Miska, and Ulas states a single clean prophecy: **for every base $b \ge 2$ and every multiplicity $m \ge 2$, the sequence $T_{b,m}(n)$ is unbounded.** No matter how high you set the bar, there is always some coefficient that leaps over it.

The original work settled the case $b = 2$ — the powers-of-two product we started with — for all multiplicities $m$. But the conjecture is about *all* bases at once: base three, base ten, base ninety-seven. What happens when the exponents marching off to infinity are $1, 3, 9, 27, \dots$ instead of $1, 2, 4, 8, \dots$? The published proof for base two leans on heavy machinery (the theory of so-called "automatic" and "regular" sequences) that does not transfer cleanly to other bases.

This article tells the story of a different, base-blind argument that cracks the case $m = 2$ for **every** base $b \ge 2$ at once — and does so with a tool so elementary it could be explained to a curious high-schooler. The secret weapon is a special family of numbers called **repunits**, and a self-similar "echo" equation that the product satisfies.

## Self-similarity: the product talks to itself

The first beautiful fact is that this infinite product is *self-similar*. Look again at the factors: $(1-x)^m$, then $(1-x^b)^m$, then $(1-x^{b^2})^m$, and so on. Every factor except the first is just the *previous list of factors* with $x$ replaced by $x^b$. Replacing $x$ with $x^b$ is an operation mathematicians call **expansion** — it stretches a polynomial out, spacing its terms apart by a factor of $b$.

This observation produces a remarkably tidy equation. Let $Q_N(x)$ denote the truncated product up to the factor with exponent $b^N$:

$$Q_N(x) = \prod_{i=0}^{N} \left(1 - x^{b^i}\right)^m.$$

Then the next truncation factors as

$$Q_{N+1}(x) = (1 - x)^m \cdot Q_N\!\left(x^b\right).$$

In words: to grow the product by one factor, peel off a copy of $(1-x)^m$ at the front and **stretch the rest by base $b$**. This is a *Mahler-type functional equation* — named after Kurt Mahler, who studied power series that satisfy such self-referential rules. In the formal development this identity is the lemma `factor_succ`, and it is the engine that drives everything that follows.

There is a companion fact that makes the infinite product tractable on a computer and on paper alike. Because the factor $(1 - x^{b^{N+1}})^m$ only introduces new terms of degree $b^{N+1}$ and higher — degrees far larger than $N$ itself — the coefficient of $x^n$ stops changing once you have included enough factors. Precisely: as long as $N \ge n$, the coefficient of $x^n$ in $Q_N$ equals the coefficient in the full infinite product. This *finite-equals-infinite* principle (the lemma `coeff_eq_of_le`) means we never have to wrestle with an actual infinite object; a large-enough finite polynomial captures the truth exactly. It is the rigorous justification for defining $T_{b,m}(n)$ as the coefficient of $x^n$ in the finite product $\prod_{i=0}^{n}(1-x^{b^i})^m$.

## Repunits: the all-ones numbers

Now for the heroes of the story. A **repunit** in base $b$ is a number whose base-$b$ representation is all ones. In base ten these are the familiar numbers $1, 11, 111, 1111, \dots$. In base $b$ the $k$-th repunit is

$$R_k = 1 + b + b^2 + \cdots + b^{k-1} = \underbrace{11\cdots1}_{k \text{ ones}} \text{ (base } b).$$

They obey the simplest possible growth rule: to get the next repunit, multiply by $b$ and add one,

$$R_{k+1} = b \cdot R_k + 1.$$

(So $R_0 = 0$, $R_1 = 1$, $R_2 = b+1$, $R_3 = b^2 + b + 1$, and so on.) These all-ones indices turn out to be exactly the spots where the coefficient sequence $T_{b,2}$ reaches its dramatic peaks.

## The collapse: why $T_{b,2}(R_{k+1}) = -2\,T_{b,2}(R_k)$

Here is where the magic happens. Set $m = 2$, so the squared factor is

$$(1 - x)^2 = 1 - 2x + x^2,$$

a polynomial with only three terms, at degrees $0$, $1$, and $2$. Apply the self-similarity equation at the repunit. We want the coefficient of $x^{R_{k+1}}$, and since $R_{k+1} = b \cdot R_k + 1$, we are asking for the coefficient at a degree that is **one more than a multiple of $b$**.

Now look at the two pieces of the factored product $Q_{k+1}(x) = (1-x)^2 \cdot Q_k(x^b)$. The stretched piece $Q_k(x^b)$ contains **only powers of $x$ that are multiples of $b$** — every exponent has been multiplied by $b$. The front piece $(1-x)^2 = 1 - 2x + x^2$ contributes shifts of $0$, $1$, or $2$. To land on the target degree $b \cdot R_k + 1$, which is $1 \pmod b$, we must combine a multiple-of-$b$ degree from the stretched piece with a shift from the front piece that makes the residues match.

- The shift of $0$ (the constant term $1$) keeps the residue at $0 \pmod b$ — **misses** the target residue $1$.
- The shift of $2$ (the $x^2$ term) lands on residue $2 \pmod b$ — also **misses** (as long as $b \ge 2$, residue $2$ is not residue $1$, except in base $2$ where it wraps to $0$ — still a miss).
- Only the shift of $1$ (the middle $-2x$ term) hits residue $1 \pmod b$ exactly.

So two of the three terms vanish, and a single survivor remains. The lone middle coefficient $-2$ multiplies the coefficient of $x^{R_k}$ in $Q_k$, giving the breathtakingly simple recurrence

$$T_{b,2}(R_{k+1}) = -2 \cdot T_{b,2}(R_k).$$

This is the lemma `T_repunit_step`. The interior structure of $(1-x)^2$ — having exactly one "middle" term — is what causes the clean collapse, and it is precisely why the trick works so uniformly across every base.

## The closed form and the punchline

A recurrence that multiplies by $-2$ at each step, starting from $T_{b,2}(R_0) = T_{b,2}(0) = 1$, has an instantly recognizable solution:

$$\boxed{\,T_{b,2}(R_k) = (-2)^k\,}$$

for every base $b \ge 2$ and every $k$. This is the central closed-form result, the lemma `T_repunit`. Taking absolute values strips off the sign:

$$\left| T_{b,2}(R_k) \right| = 2^k.$$

And now the conjecture falls out effortlessly. Suppose someone hands you any ceiling $B$, however enormous. Powers of two grow without limit, so choose $k$ large enough that $2^k > B$. Then the coefficient at the repunit index $R_k$ satisfies

$$\left| T_{b,2}(R_k) \right| = 2^k > B.$$

We have found an index where the sequence overshoots the ceiling. Since $B$ was arbitrary, the sequence $T_{b,2}$ is **unbounded** — for every base $b \ge 2$. This is the theorem `T_two_unbounded`:

> For every base $b \ge 2$ and every bound $B$, there exists an index $n$ such that $|T_{b,2}(n)| > B$.

The proof is a small marvel of leverage: an infinite, sign-tangled product is conquered by watching what happens along a single sparse sequence of all-ones indices, where almost everything cancels and a clean doubling survives.

## A revealing contrast: when $m = 1$, the music goes quiet

To appreciate why the multiplicity $m \ge 2$ matters, consider the un-squared product with $m = 1$:

$$\prod_{i=0}^{\infty} \left(1 - x^{b^i}\right) = (1-x)(1-x^b)(1-x^{b^2}) \cdots$$

Here the coefficients never escape the range $\{-1, 0, 1\}$ — that is, $|T_{b,1}(n)| \le 1$ for all $n$. The sequence is *bounded*. The single factor $(1-x)$ has no middle term to seed a doubling; it only ever adds or subtracts one copy at a time. The leap from bounded to unbounded happens the moment you square, because $(1-x)^2 = 1 - 2x + x^2$ introduces that pivotal coefficient $-2$ in the middle. The number $2$ in "$(-2)^k$" is, quite literally, the middle binomial coefficient $\binom{2}{1}$ of the squared factor. The unboundedness is *built from* that one number.

## Why this is hard, and what remains

If the argument is so clean, why isn't the whole conjecture solved? The honest answer lies in the interior of $(1-x)^m$ for larger $m$. When $m = 2$ the squared factor has a single middle term, and the collapse leaves exactly one survivor. But for $m = 3$, $m = 4$, and beyond, the expansion $(1-x)^m$ has *several* interior terms — the binomial coefficients $\binom{m}{1}, \binom{m}{2}, \dots$ — and at the repunit residues more than one of them can survive. Instead of a tidy doubling, you get a **multi-term recurrence** that couples each repunit value to several of its lower neighbours through a fixed transfer operator. The clean column $m = 2$ is exactly the case where this operator is a single number, $-2$.

For example, in base $3$ with multiplicity $4$, the repunit values run $1, -4, 17, -76, 353, \dots$ — emphatically *not* $(-4)^k$. The growth is still there, but it is governed by the eigenvalues of a small matrix rather than a single ratio. Settling the genuinely open corner — small base, large exponent, $2 \le b < m$ — is a matter of showing that the relevant transfer matrix has spectral radius greater than one. That is a finite, checkable computation for each $(b, m)$, and it points toward a complete, base-uniform resolution of the conjecture.

## The takeaway

What makes this story satisfying is the way a single structural idea — self-similarity under "stretch by $b$" — converts an unwieldy infinite product into an arithmetic about all-ones numbers. The repunits are the resonant frequencies of the product; pluck the string at those indices and you hear a pure tone, $(-2)^k$, ringing louder and louder without bound. The deep theorems about automatic sequences are not wrong, but they are not necessary here. Sometimes the most general truth wears the most elementary clothes, and a problem stated for *every* base is solved not by handling each base separately, but by finding the one identity that never noticed which base it was in.
