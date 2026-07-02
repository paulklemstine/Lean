# The Number That Never Escapes: Why $a^5 - a$ Is Always a Multiple of Thirty

Pick any whole number you like. Cube it, square it, do whatever you please — but here is a specific recipe: raise your number to the fifth power, then subtract the number you started with. Try it with $2$: you get $2^5 - 2 = 32 - 2 = 30$. Try it with $3$: $3^5 - 3 = 243 - 3 = 240$. Try it with $7$: $7^5 - 7 = 16807 - 7 = 16800$. And with $10$: $10^5 - 10 = 99990$.

Now look at those answers: $30$, $240$, $16800$, $99990$. Every single one is divisible by $5$. In fact, every single one is divisible by $30$. This is not a coincidence, and it is not luck. It is a theorem — a statement that is *provably* true for **every** integer, positive, negative, or zero, without a single exception among the infinitely many numbers you could try.

This article is about *why* that happens. The surprise is not just that the pattern holds, but how deep and how simple the reason turns out to be. What looks like a curious arithmetical accident is in fact a shadow cast by one of the most elegant facts in all of mathematics.

## A Very Old Idea in Disguise

The claim that $a^5 - a$ is always divisible by $5$ is a special case of a result discovered by Pierre de Fermat in the seventeenth century, now called **Fermat's Little Theorem**. In its cleanest form it says:

> **Fermat's Little Theorem.** If $p$ is a prime number, then for *every* integer $a$, the quantity $a^p - a$ is divisible by $p$.

Set $p = 5$ and you get exactly our claim: $a^5 - a$ is divisible by $5$. Set $p = 2$ and you learn that $a^2 - a$ is always even (which makes sense — $a^2 - a = a(a-1)$ is a product of two consecutive integers, one of which must be even). Set $p = 3$ and $a^3 - a$ is always divisible by $3$.

The word "prime" is doing enormous work here. The theorem is *false* if $p$ is not prime. For instance, $a^4 - a$ is not always divisible by $4$: take $a = 2$ and you get $16 - 2 = 14$, which is not a multiple of $4$. Primeness is the secret ingredient, and understanding *why* it matters is the heart of the story.

## Clock Arithmetic: The Right Way to Think About "Divisible By"

To see why the theorem is true, we need to change how we look at numbers. Instead of asking "what is this number?", we ask "what is its remainder when divided by $5$?"

This is the arithmetic of a clock. On a $12$-hour clock, $15$ o'clock is the same as $3$ o'clock, because $15$ and $3$ leave the same remainder when divided by $12$. Mathematicians write this as $15 \equiv 3 \pmod{12}$ and say "$15$ is congruent to $3$ modulo $12$."

For our problem we use a $5$-hour clock. Every integer collapses onto one of just five positions: $0, 1, 2, 3, 4$. Saying "$a^5 - a$ is divisible by $5$" is *exactly* the same as saying "$a^5$ and $a$ land on the same position on the $5$-clock," i.e. $a^5 \equiv a \pmod 5$.

So the entire infinite claim — one statement for each of infinitely many integers — reduces to checking just **five** cases, one for each clock position:

| $a \bmod 5$ | $a^5 \bmod 5$ | equal? |
|:---:|:---:|:---:|
| $0$ | $0^5 = 0$ | ✓ |
| $1$ | $1^5 = 1$ | ✓ |
| $2$ | $2^5 = 32 \equiv 2$ | ✓ |
| $3$ | $3^5 = 243 \equiv 3$ | ✓ |
| $4$ | $4^5 = 1024 \equiv 4$ | ✓ |

Five checks, five successes. Because every integer is congruent to one of these five residues, and because raising to the fifth power respects clock arithmetic (remainders of products are products of remainders), the pattern holds for *all* integers at once. This is the first miracle of modular arithmetic: it turns an infinite problem into a finite one.

## Why Fifth Powers Are the Identity

Staring at that table, something remarkable jumps out. On the $5$-clock, raising to the fifth power *does nothing at all*: $0 \mapsto 0$, $1 \mapsto 1$, $2 \mapsto 2$, $3 \mapsto 3$, $4 \mapsto 4$. The map "raise to the fifth power" is the **identity map** modulo $5$.

Why should that be? Here is the beautiful reason. Throw away the number $0$ and look at the four nonzero positions $\{1, 2, 3, 4\}$. Under multiplication modulo $5$, these four form a self-contained world — multiply any two of them and you stay inside the set (you never hit $0$, precisely because $5$ is prime and cannot be split into smaller factors). This world has exactly $4$ elements.

There is a general principle governing such finite multiplicative worlds: **raise any element to the power equal to the size of the world, and you return to $1$.** Since our world has $4$ elements, every nonzero residue $a$ satisfies $a^4 \equiv 1 \pmod 5$. Multiply both sides by $a$ and you get $a^5 \equiv a$. For $a \equiv 0$ the statement $0^5 \equiv 0$ is obvious. That covers every case — and it explains, without brute force, why the fifth power is the identity.

This is the deep reason primeness matters. When $p$ is prime, the nonzero residues form a flawless multiplicative system — a *field* — in which every nonzero element has a multiplicative inverse and no two nonzero numbers ever multiply to zero. That perfect structure is what forces $a^p \equiv a$. When $p$ is not prime, the structure cracks: some nonzero residues multiply together to give zero, the tidy "return to $1$" rule breaks, and the pattern collapses.

## The Bonus: It's Really Divisible by Thirty

Now for the part that elevates a textbook exercise into something genuinely satisfying. We claimed at the start that $a^5 - a$ is divisible not just by $5$ but by $30$. Where do the extra factors come from?

The number $30$ factors as $30 = 2 \times 3 \times 5$, a product of three distinct primes. The strategy is to prove divisibility by each prime *separately* and then combine them. This combination is legitimate precisely because $2$, $3$, and $5$ share no common factors: if a number is divisible by each of several pairwise-coprime numbers, it is divisible by their product.

- **Divisible by $2$.** We can factor $a^5 - a = a(a^4 - 1) = a(a^2-1)(a^2+1) = (a-1)\,a\,(a+1)(a^2+1)$. Among the three consecutive integers $a-1$, $a$, $a+1$, at least one is even. So the product is even.
- **Divisible by $3$.** Among the three consecutive integers $a-1$, $a$, $a+1$, one must be a multiple of $3$. So the product is divisible by $3$. (Equivalently, this is Fermat's Little Theorem with $p=3$: $a^3 \equiv a$, hence $a^5 = a^4\cdot a \equiv a^2\cdot a = a^3 \equiv a$.)
- **Divisible by $5$.** This is exactly the theorem we proved above.

Since $a^5 - a$ is divisible by $2$, by $3$, and by $5$, and these primes are mutually coprime, it is divisible by their product $2 \cdot 3 \cdot 5 = 30$.

A charming feature of $a^5 - a$ is that it wears its secrets in more than one costume. It can be written as
$$a^5 - a = (a-1)\,a\,(a+1)\,(a^2+1),$$
which exposes the three consecutive integers responsible for the factors of $2$ and $3$. It can *also* be written as
$$a^5 - a = (a^2 + 1)(a^3 - a) = (a^2 - a)(a^3 + a^2 + a + 1),$$
and these alternative factorizations are exactly the tools one uses to pin down the small-prime divisibilities cleanly. The same polynomial, seen from two angles, hands you two different proofs.

## The Larger Pattern

Once you see the mechanism, an irresistible question arises: for which exponents $n$ does $a^n - a$ have a *universal* divisor — a fixed number that divides it for every integer $a$?

The answer is astonishingly clean. For each exponent $n$, there is a largest such universal divisor, call it $D(n)$, and it is always **squarefree** (a product of distinct primes, no repeats). A prime $p$ belongs to this product exactly when $p - 1$ divides $n - 1$. For $n = 5$ we ask which primes $p$ satisfy $(p-1) \mid 4$: the divisors of $4$ are $1, 2, 4$, corresponding to $p - 1 \in \{1, 2, 4\}$, i.e. $p \in \{2, 3, 5\}$. Their product is $2 \cdot 3 \cdot 5 = 30$ — precisely the strengthened divisor we found. The theory predicts the answer exactly.

This same criterion explains classic curiosities. Why is $a^7 - a$ always divisible by $42 = 2\cdot 3 \cdot 7$? Because the primes with $(p-1) \mid 6$ are $2, 3, 7$. Why is $a^{13} - a$ divisible by $2730 = 2\cdot3\cdot5\cdot7\cdot13$? Because $(p-1)\mid 12$ for $p \in \{2,3,5,7,13\}$. A single divisibility test on exponents governs an entire infinite family of results.

## Where the Magic Stops

Part of understanding a theorem is knowing where it fails. The clean "fifth power is the identity" behavior lives modulo a prime because the nonzero residues form a field. Push to a *prime power* — say, work modulo $p^2$ instead of $p$ — and the field structure degenerates. There is no exponent $n > 1$ that makes $a^n \equiv a$ hold for all integers modulo $p^2$ when $p$ is an odd prime, even though the corresponding statement modulo $p$ is true. The perfect fixed-point property is a delicate gift of primeness, and it does not survive the move to $p^2$.

There is even a probabilistic echo. If you pick a random integer between $1$ and $N$ and ask whether a fixed prime $p$ divides $a^n - a$, then as $N$ grows the fraction of successes tends to $1$ whenever $(p-1) \mid (n-1)$ — the divisor is *guaranteed* — and tends to $1/p$ otherwise, exactly the odds that a random integer happens to be a multiple of $p$. The universal divisor $D(n)$ is precisely the set of primes for which the odds are not odds at all, but a certainty.

## The Moral

We began with a party trick: raise a number to the fifth power, subtract the number, and marvel that the result is always a multiple of thirty. We end with a glimpse of a vast and orderly landscape. Behind the trick stands Fermat's Little Theorem; behind that stands the arithmetic of clocks; behind *that* stands the structure of finite fields, where primeness turns a chaotic set of numbers into a perfectly behaved multiplicative universe.

The infinite is tamed by the finite: infinitely many integers, all obeying one rule, because there are only five positions on the clock and each one checks out. That is the quiet power of number theory — to take a statement about *everything* and prove it by understanding *one small, perfect world*.
