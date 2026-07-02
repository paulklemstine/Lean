# The Number Five and a Secret Shared by Every Integer

Pick any whole number you like. It can be small like $3$, enormous like $8{,}675{,}309$, or negative like $-42$. Now raise it to the fifth power, and subtract the number you started with. The result — no matter which number you chose — is always evenly divisible by $5$.

Try it. Take $3$. Then $3^5 = 243$, and $243 - 3 = 240$, which is $5 \times 48$. Take $2$. Then $2^5 = 32$, and $32 - 2 = 30 = 5 \times 6$. Take $7$. Then $7^5 = 16807$, and $16807 - 7 = 16800 = 5 \times 3360$. The pattern never breaks. This is the statement that

$$a^5 - a \text{ is a multiple of } 5 \quad \text{for every integer } a.$$

At first this looks like a coincidence — a small numerical curiosity. But it is a shadow cast by one of the most beautiful facts in all of mathematics, and following that shadow back to its source leads us through prime numbers, finite arithmetic, and even the theory of random strings of beads.

## A tiny world with five numbers

To understand why $5$ divides $a^5 - a$, forget about the infinitely long number line for a moment and imagine instead a world with only five numbers in it: $0, 1, 2, 3, 4$. This is the world of **clock arithmetic modulo $5$**. Just as a $12$-hour clock wraps around so that $13$ o'clock is the same as $1$ o'clock, in this world we only care about the *remainder* a number leaves when divided by $5$. So $7$ becomes $2$, $10$ becomes $0$, and $-1$ becomes $4$.

The claim that $5$ divides $a^5 - a$ is exactly the claim that, in this five-element world,

$$a^5 = a \quad \text{for every } a.$$

In other words: **raising to the fifth power does absolutely nothing.** It sends $0$ to $0$, $1$ to $1$, $2$ to $2$, $3$ to $3$, and $4$ to $4$. We can check this by hand. Working modulo $5$: $2^5 = 32 = 30 + 2$ leaves remainder $2$; $3^5 = 243 = 240 + 3$ leaves remainder $3$; $4^5 = 1024 = 1020 + 4$ leaves remainder $4$. Fifth powering is the identity map. It is a machine that returns whatever you feed it, untouched.

Why five? Because five is *prime*. And this is where a single grand theorem enters the story.

## Fermat's Little Theorem

In the seventeenth century, Pierre de Fermat noticed a remarkable regularity about prime numbers. Stated in the language of remainders, **Fermat's Little Theorem** says:

> If $p$ is a prime number, then for every integer $a$, the quantity $a^p - a$ is divisible by $p$.

Our five-fact is simply the case $p = 5$. But the theorem is far grander: $7$ divides $a^7 - a$, $11$ divides $a^{11} - a$, $101$ divides $a^{101} - a$, and so on forever, one clean statement for every prime in existence.

The modern explanation is startlingly short, and it rests on turning the five-element world into a genuine number system — a **field**. A field is a place where you can add, subtract, multiply, and (crucially) divide by anything nonzero, exactly as with ordinary fractions. When $p$ is prime, the clock-arithmetic world modulo $p$ is a field: every nonzero element has a reciprocal. When $p$ is *not* prime, this fails — for instance, modulo $6$ the number $2$ has no reciprocal, because no multiple of $2$ ever leaves remainder $1$.

In any *finite* field with exactly $q$ elements, there is an iron law: raising to the $q$-th power is the identity map, $x^q = x$ for every element $x$. This single fact — sometimes called the statement that the **Frobenius map is the identity** — is the engine. The field modulo $5$ has exactly five elements, so raising to the fifth power is the identity, and $a^5 = a$ for all $a$. Divisibility by $5$ falls out immediately. Nothing about the number $5$ was special except that it was prime; the same argument works verbatim for $7$, for $11$, for any prime at all.

## An honest, hands-on proof for the number five

The finite-field argument is elegant, but for the specific case of $5$ there is a completely elementary proof that a curious reader can verify with nothing more than patience. It begins with a piece of algebra that anyone can check by expanding:

$$a^5 - a = (a-1)\,a\,(a+1)\,(a^2+1).$$

Now look at the three consecutive integers sitting in that product: $a-1$, $a$, and $a+1$. Among any run of consecutive integers, remainders modulo $5$ cycle through $0,1,2,3,4$. So we simply ask: what is the remainder of $a$ when divided by $5$?

- If $a$ leaves remainder $0$, then $a$ itself is a multiple of $5$, and the product is too.
- If $a$ leaves remainder $1$, then $a - 1$ is a multiple of $5$.
- If $a$ leaves remainder $4$, then $a + 1$ is a multiple of $5$.
- If $a$ leaves remainder $2$ or $3$, then $a^2$ leaves remainder $4$ (since $2^2 = 4$ and $3^2 = 9$ leaves $4$), so $a^2 + 1$ leaves remainder $0$ — a multiple of $5$.

Every possible case produces a factor divisible by $5$, so the whole product is. The five-fact is proved by hand, no abstraction required. Two roads — one soaring, one grounded — arrive at the same summit.

## Beads on a string: probability enters

Here is where the story takes an unexpected turn toward probability and combinatorics. There is a way to *see* the number $a^5 - a$ as counting something concrete.

Imagine you have beads in $a$ different colors, and you want to make a necklace of $5$ beads arranged in a circle. If you first lay them in a row, there are $a^5$ possible strings of five beads. Among these, exactly $a$ are "boring" — the single-color strings where all five beads match (one for each color). Remove those, and $a^5 - a$ strings remain, each using at least two colors.

Now bend each string into a circle. Because $5$ is prime, a genuinely multicolored circular arrangement of five beads has exactly $5$ distinct rotations, all different from one another — you can spin the necklace to five different starting points and never see a repeat. (This is special to prime lengths; a necklace of length $6$ can repeat after just three rotations, like the pattern red-blue-red-blue-red-blue.) So the $a^5 - a$ non-boring strings split perfectly into bundles of $5$, one bundle per genuine necklace. The number of bundles is a whole number, which forces $a^5 - a$ to be a multiple of $5$.

This "necklace proof" reframes an arithmetic fact as a statement about **symmetry**: the group of rotations acts freely on non-repeating strings of prime length, chopping them into equal piles. Phrased probabilistically, if you generate a random non-constant string of prime length $p$, its rotation-orbit has exactly $p$ members with certainty. Divisibility by $5$ is no accident of arithmetic — it is the visible fingerprint of a hidden symmetry.

## Why any of this matters

A fact about the number $5$ might seem like a museum piece, but Fermat's Little Theorem is the beating heart of modern digital security. Every time you visit a secure website, your browser and the server perform arithmetic in exactly these finite worlds, raising enormous numbers to enormous powers and relying on the predictable behavior that Fermat first glimpsed. The theorem underlies primality testing — fast methods to decide whether a gigantic number is prime — and it is the foundation on which the RSA cryptosystem is built.

It also opens onto deep unexplored country. What happens when the modulus is *not* prime? For most composite numbers the clean identity $a^n \equiv a$ fails. But astonishingly, a rare breed of composite numbers — the **Carmichael numbers**, beginning with $561$ — masquerade as primes by satisfying it anyway. The exact boundary between the numbers that enjoy this "universal power" property and those that don't is governed by an elegant divisibility rule, and charting that boundary remains a lively area of number theory.

So the next time you raise a number to the fifth power and subtract, and find a multiple of $5$ staring back, remember: you are not looking at a coincidence. You are looking at a prime number, a finite field, a spinning necklace, and the arithmetic that quietly guards the modern world.
