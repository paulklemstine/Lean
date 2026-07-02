# The Number That Always Divides: A Journey Through Fifth Powers

Pick any whole number you like. Square it, then square it again, then multiply by the original once more — in other words, raise it to the fifth power. Now subtract the number you started with. Something quietly miraculous happens: the answer is *always* a multiple of five.

Try it. Start with $2$: we have $2^5 = 32$, and $32 - 2 = 30$, which is $5 \times 6$. Start with $3$: $3^5 = 243$, and $243 - 3 = 240 = 5 \times 48$. Start with $7$: $7^5 = 16807$, and $16807 - 7 = 16800 = 5 \times 3360$. No matter what integer you feed in — positive, negative, or zero — the machine spits out a multiple of five.

This is the statement we will explore:

> **For every integer $a$, the quantity $a^5 - a$ is divisible by $5$.**

It looks like a small curiosity. But it is a doorway. Behind it lies one of the most elegant patterns in all of number theory, a pattern that governs prime numbers, secret codes, and the very last digit of enormous computations. Let us walk through it.

## A pattern hiding in the differences

The most down-to-earth way to see *why* the pattern holds is to watch how $a^5 - a$ behaves as we march from one integer to the next. Suppose we already know that $n^5 - n$ is a multiple of $5$. What happens when we step up to $n+1$?

Here algebra hands us a gift. If you patiently expand $(n+1)^5$ using the binomial theorem and simplify, you discover a beautiful identity:

$$(n+1)^5 - (n+1) = (n^5 - n) + 5\,(n^4 + 2n^3 + 2n^2 + n).$$

Look at what this says. The value at $n+1$ equals the value at $n$, *plus* an explicit chunk that is visibly five times a whole number. So if $n^5 - n$ was already a multiple of five, then $(n+1)^5 - (n+1)$ is a multiple of five as well: we simply added another multiple of five to it.

This is the domino effect mathematicians call **induction**. We knock over the first domino by checking the starting case — when $a = 0$, we get $0^5 - 0 = 0$, which is certainly a multiple of five. Then the identity guarantees each domino topples the next: from $0$ we reach $1$, from $1$ we reach $2$, and so on forever. A symmetric argument, subtracting instead of adding, carries the pattern into the negative integers. Every integer is covered.

There is something deeply satisfying here. We never had to check infinitely many cases. We found a single algebraic law — that the *gap* between consecutive values is always a clean multiple of five — and let it ripple across the entire number line.

## The same truth, told through a product

There is a second way to see the pattern, and it reveals hidden structure. The expression $a^5 - a$ factors completely into a product of simpler pieces:

$$a^5 - a = (a-1)\,a\,(a+1)\,(a^2 + 1).$$

Read the first three factors aloud: $a-1$, $a$, $a+1$. Those are three *consecutive* integers. Among any three consecutive integers, one must be a multiple of three, and at least one must be even. That single observation already tells us $a^5 - a$ is divisible by both $2$ and $3$.

And the divisibility by five? That falls out too, once you notice that the five residue classes — the possible remainders when you divide by five — each get sent back to themselves under the fifth-power map. Whatever remainder $a$ leaves upon division by five, $a^5$ leaves the very same remainder, so their difference is swallowed by five.

The factorization does more than re-prove the result. It shows us that five was never the whole story.

## Sharpening five into thirty

If $a^5 - a$ is divisible by $2$, by $3$, and by $5$ all at once, and these three numbers share no common factor, then it must be divisible by their product:

$$2 \times 3 \times 5 = 30.$$

This is the reasoning behind the **Chinese Remainder Theorem**: independent divisibility by coprime numbers glues together into divisibility by their product. So the real theorem is sharper than we first suspected:

> **For every integer $a$, the quantity $a^5 - a$ is divisible by $30$.**

Go back to our examples. $2^5 - 2 = 30$. $3^5 - 3 = 240 = 30 \times 8$. $7^5 - 7 = 16800 = 30 \times 560$. Every single one is a multiple of thirty, not merely of five. The table of values $0, 0, 30, 240, 1020, 3120, 7770, 16800, 32760, \ldots$ marches forward in perfect step-thirty rhythm.

## A fingerprint on the last digit

Here is a consequence you can check in your head. Because $a^5 - a$ is divisible by both $2$ and $5$, it is divisible by $10$. And divisibility by ten is exactly a statement about *last digits*: it means $a^5$ ends in the same decimal digit as $a$.

$$a^5 \equiv a \pmod{10}.$$

Watch it work. $2^5 = 32$ ends in $2$. $3^5 = 243$ ends in $3$. $7^5 = 16807$ ends in $7$. $8^5 = 32768$ ends in $8$. The fifth power leaves your number's final digit completely untouched.

This has a delightful ripple effect. Since raising to the fifth power preserves the last digit, doing it again changes nothing: $a^{25}$, $a^{125}$, and every tower of iterated fifth powers all end in the same digit as $a$ itself. The fifth-power map, viewed through the narrow window of last digits, is a perfect *fixed-point machine* — it moves nothing.

## The grand pattern: Fermat's Little Theorem

Now for the revelation. The number five is not special. What is special is that five is *prime*. The identical phenomenon holds for every prime number:

> **Fermat's Little Theorem.** For every prime $p$ and every integer $a$, the quantity $a^p - a$ is divisible by $p$.

For $p = 2$: $a^2 - a = a(a-1)$ is always even. For $p = 3$: $a^3 - a$ is always a multiple of three. For $p = 5$: our theorem. For $p = 7$: $a^7 - a$ is always a multiple of seven. Our little discovery about fifth powers is a single instance of a law that stretches across all the primes.

Why does prime-ness matter so much? The cleanest explanation lives in *modular arithmetic* — the arithmetic of remainders. When $p$ is prime, the nonzero remainders modulo $p$ form a structure so rigid that raising anything to the $p$-th power sends it right back where it started. Composite numbers lack this rigidity, and the pattern breaks. It is prime-ness, quietly, that makes the whole edifice stand.

And this is not merely elegant. Fermat's Little Theorem is the beating heart of modern cryptography. Every time you send a credit card number over the internet, algorithms descended directly from this theorem scramble and unscramble your data using the arithmetic of primes. The observation that $a^5 - a$ is always a multiple of five is a first, gentle glimpse of the machinery that keeps the digital world secure.

## Why this matters

What begins as a party trick — "your fifth power ends in the same digit!" — turns out to be the tip of a very deep iceberg. We saw three distinct proofs, each illuminating a different facet:

- an **inductive** argument, showing the pattern propagates because consecutive values differ by a multiple of five;
- a **factorization**, exposing three consecutive integers and thereby divisibility by $2$, $3$, and $5$ at once;
- a **modular** argument, revealing the pattern as one prime's shadow of the universal Fermat's Little Theorem.

The same fact, seen from three angles, becomes three different kinds of knowledge. That is the quiet joy of mathematics: a humble observation about the number thirty, followed far enough, opens onto primes, remainders, and the secret codes that protect us all.

The next time someone hands you an integer, raise it to the fifth power and subtract. Hand back a multiple of thirty, and know that you are holding a small piece of a very large and very beautiful truth.
