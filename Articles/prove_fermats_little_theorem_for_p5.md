# The Number Five Keeps a Secret

Pick any whole number you like. Square it, square that, and multiply once more, so that you have raised your number to the fifth power. Now subtract the number you started with. Whatever you began with — $2$, $-17$, a billion — the result you get is always, without exception, a multiple of five.

Try it. Start with $2$: the fifth power is $32$, and $32 - 2 = 30 = 5 \times 6$. Start with $3$: the fifth power is $243$, and $243 - 3 = 240 = 5 \times 48$. Start with $7$: the fifth power is $16807$, and $16807 - 7 = 16800 = 5 \times 3360$. The pattern never breaks. This is the small, sharp fact at the heart of this article:

> **For every integer $a$, the number $a^5 - a$ is a multiple of $5$.**

It looks like a curiosity, a party trick with numbers. But behind it lies a beautiful piece of structure — the arithmetic of *remainders* — and that structure quietly governs everything from the shapes of right triangles to the design of modern cryptography.

## Remainders are the real numbers

The secret to understanding $a^5 - a$ is to stop looking at the number $a$ itself and start looking at its **remainder when divided by five**. Every integer leaves one of exactly five remainders: $0, 1, 2, 3,$ or $4$. Mathematicians call these the *residues modulo $5$*, and the surprising truth is that for many questions, the residue is all that matters.

Why? Because remainders respect addition and multiplication. If two numbers leave the same remainder mod $5$, then their squares do too, their cubes do too, and so on. So to check whether $a^5 - a$ is divisible by $5$ for *all* integers, we don't need to test infinitely many numbers. We only need to test five representatives — one for each possible remainder — and the rest follow for free.

Let us do exactly that. Write each residue $r$ and compute $r^5 - r$ modulo $5$:

- $r = 0$: $\;0^5 - 0 = 0$, divisible by $5$. ✓
- $r = 1$: $\;1^5 - 1 = 0$, divisible by $5$. ✓
- $r = 2$: $\;2^5 - 2 = 32 - 2 = 30 = 5 \times 6$. ✓
- $r = 3$: $\;3^5 - 3 = 243 - 3 = 240 = 5 \times 48$. ✓
- $r = 4$: $\;4^5 - 4 = 1024 - 4 = 1020 = 5 \times 204$. ✓

Five checks, and we are done. Because every integer shares its remainder with one of these five, and because raising to a power preserves remainders, the divisibility we verified for the representatives holds for *all* integers. The infinite has been tamed by the finite.

There is an even cleaner way to see the same thing. Split $a^5 - a$ into a product:
$$
a^5 - a = a\,(a^4 - 1) = a\,(a-1)(a+1)(a^2+1).
$$
Among the three consecutive integers $a-1, a, a+1$ we already capture some of the story, but the piece that pins down the factor of five is $a^2 + 1$ working together with $a$. The residue calculation above is really a statement that these factors conspire so that one of them always brings in a five.

## The fingerprint of squares

To see *why* five is special here, look at what squares look like modulo $5$. Take each residue and square it:
$$
0^2 \equiv 0,\quad 1^2 \equiv 1,\quad 2^2 \equiv 4,\quad 3^2 \equiv 4,\quad 4^2 \equiv 1 \pmod 5.
$$
The squares only ever land on $\{0, 1, 4\}$. The values $2$ and $3$ are *never* squares modulo $5$; they are the **quadratic non-residues**. This little table — the fingerprint of squaring mod $5$ — is the engine driving our result and several of its cousins.

Here is the connection. Fermat's celebrated observation, specialized to the prime five, says that raising to the fifth power sends every residue back to itself:
$$
a^5 \equiv a \pmod 5.
$$
That is precisely the statement $a^5 - a \equiv 0$. And it is no accident that the exponent is five and the modulus is five: for a prime $p$, raising to the $p$-th power is the identity map on residues. The number of loops it takes for repeated squaring and multiplying to return home is governed by $p - 1 = 4$, and $5 - 1 = 4$ divides the exponent gap $5 - 1 = 4$ exactly. That divisibility of exponents is the deep reason the pattern exists.

## Why right triangles care

The domain of this work is *Pythagorean* — the study of right triangles with whole-number sides, the triples $(a, b, c)$ with $a^2 + b^2 = c^2$ such as $(3,4,5)$, $(5,12,13)$, and $(8,15,17)$. What could the fifth-power identity possibly have to do with triangles?

Look again at the fingerprint of squares mod $5$: a square is always $0$, $1$, or $4$. Now ask which residues a sum of two squares $a^2 + b^2$ can produce. If neither leg is a multiple of five, each square is $1$ or $4$, and the possible sums modulo $5$ are
$$
1+1 = 2,\quad 1+4 = 0,\quad 4+4 = 3 \pmod 5.
$$
For $c^2$ to be a genuine square, it must itself be $0$, $1$, or $4$ mod $5$ — and among the sums just listed, only $0$ qualifies. The value $0$ forces $5 \mid c$. In every other case, one of the two legs must already have been a multiple of five.

The conclusion is striking: **in every Pythagorean triple, at least one of the three numbers $a, b, c$ is divisible by $5$.** Check the classics: $(3,4,5)$ has its $5$; $(5,12,13)$ has its $5$; $(8,15,17)$ hides it in the $15$; $(20,21,29)$ hides it in the $20$. The residue table you used to prove the fifth-power identity is the very same table that forces a five into every right triangle.

This is one of three cooperating "obstructions." A parallel analysis modulo $4$ shows one leg is always divisible by four, and modulo $3$ shows one side is always divisible by three. Because $3$, $4$, and $5$ share no common factors, they combine: the product $a \cdot b \cdot c$ of any Pythagorean triple is always divisible by $3 \times 4 \times 5 = 60$. And the humble triangle $(3,4,5)$, whose product is exactly $60$, shows that no larger universal divisor is possible. Five is the final, decisive ingredient in that classical fact.

## A pattern that scales

Once you see the mechanism, you cannot help asking: what about other exponents? The identity $a^5 \equiv a \pmod 5$ is a member of an infinite family. Its most famous sibling is
$$
a^3 - a = (a-1)\,a\,(a+1),
$$
a product of three consecutive integers, hence always divisible by $6 = 2 \times 3$. Our result adds a five to the pantheon.

The general principle is elegant. For a fixed exponent $k$, the largest constant that divides $a^k - a$ for *every* integer $a$ is the product of all primes $p$ for which $p - 1$ divides $k - 1$. For $k = 3$ the relevant primes are $2$ and $3$ (since $1$ and $2$ both divide $2$), giving $6$. For $k = 5$, the primes $p$ with $p - 1 \mid 4$ are $2, 3,$ and $5$, giving $2 \times 3 \times 5 = 30$. So in fact $a^5 - a$ is *always* divisible by thirty — a strengthening of the divisibility by five that we proved, and one that the same residue technique delivers with a little more bookkeeping.

## Why such a small fact matters

It is tempting to dismiss $a^5 \equiv a \pmod 5$ as trivial. It is anything but. This single congruence is a shard of one of the most consequential ideas in all of mathematics: that arithmetic performed on remainders forms a self-contained world with its own laws. That world is where prime numbers reveal their structure, where the security of internet communication is built (the RSA cryptosystem is, at its core, an elaborate use of exactly this kind of power-then-recover identity), and where deep questions about equations over the integers are made tractable by shrinking them to finite tables.

The proof we gave has a philosophical charm too. A statement about *infinitely many* integers was settled by checking *five* cases. This is the recurring miracle of modular arithmetic: the right change of viewpoint collapses an unmanageable infinity into a handful of possibilities you can hold in your hand. The number five keeps a secret — and the secret, once revealed, is that you only ever needed to look in five places.

From a card trick with fifth powers, to the hidden five in every right triangle, to the machinery guarding your online life, the same small idea echoes outward. That is the quiet power of a good theorem: it is never really about the number you started with. It is about the pattern that was there all along.
