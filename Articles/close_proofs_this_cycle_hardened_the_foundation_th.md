# The Secret Arithmetic of Rabbits: How Fibonacci Numbers Keep a Perfect Ledger

## A sequence that everyone knows

Start with two ones. Add them to get two. Add the last two to get three. Keep
going forever:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, ...
```

These are the **Fibonacci numbers**, named after the thirteenth-century
mathematician Leonardo of Pisa, who introduced them to Europe through a playful
puzzle about breeding rabbits. They are the most famous sequence in mathematics.
They appear in the spiral of a sunflower, the branching of a tree, the keys of a
piano, and the proportions artists call the golden ratio. They are so familiar
that it is easy to assume there is nothing left to discover about them.

That assumption is wrong.

Underneath the gentle surface of "just keep adding" lies a hidden machine — a
piece of arithmetic so clean and so powerful that it deserves its own name. Call
it the **Fibonacci Divisibility Calculus**. It is a perfect translation device, a
dictionary that converts statements about the *positions* of Fibonacci numbers
into statements about the *numbers themselves*. Once you see it, you can never
un-see it, and a host of deep facts about Fibonacci numbers fall out almost for
free.

This article is the story of that machine, the single law it runs on, and the
sharp, surprising theorem it produces.

## The question behind the question

Here is an innocent-looking puzzle. Look at the third Fibonacci number, which is
2. Which Fibonacci numbers are even — that is, divisible by 2?

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...
         ^        ^           ^
        F(3)     F(6)        F(9)
```

The even ones are F(3) = 2, F(6) = 8, F(9) = 34, F(12) = 144, ... — exactly every
*third* one. Now look at F(4) = 3. Which Fibonacci numbers are divisible by 3?
They are F(4) = 3, F(8) = 21, F(12) = 144, ... — exactly every *fourth* one. And
the multiples of F(5) = 5? They sit at positions 5, 10, 15, 20, ... — every
*fifth*.

A pattern is screaming at us. The Fibonacci numbers divisible by F(m) seem to be
precisely those whose position is a multiple of m. In symbols, writing F(n) for
the n-th Fibonacci number:

> **F(m) divides F(n) exactly when m divides n.**

If this is true, it is remarkable. It says the divisibility of the *values* is a
flawless mirror of the divisibility of their *positions*. The arithmetic of the
sequence is governed entirely by the arithmetic of the humble counting numbers
that index it.

But is it true? And if so, why?

## One law to rule them all

Everything flows from a single, beautiful identity. To state it we need one piece
of standard vocabulary: the **greatest common divisor**, written gcd. The gcd of
two numbers is the largest number that divides both of them. For example
gcd(12, 18) = 6, and gcd(10, 15) = 5.

The cornerstone of the whole theory is this:

> **The Strong Divisibility Law.** For all positions m and n,
> F(gcd(m, n)) = gcd(F(m), F(n)).

Read it slowly, because it is doing something almost magical. On the left, we
take the gcd of two *positions*, then look up the Fibonacci number there. On the
right, we look up two Fibonacci *values*, then take their gcd. The law says these
two completely different procedures always land on the same number.

Let us check it on an example. Take m = 12 and n = 18.

* The left side: gcd(12, 18) = 6, and F(6) = 8.
* The right side: F(12) = 144 and F(18) = 2584. Their gcd is gcd(144, 2584) = 8.

Both sides equal 8. Try any other pair; it never fails. Take m = 9, n = 15:
gcd(9,15) = 3, F(3) = 2; meanwhile F(9) = 34, F(15) = 610, and gcd(34, 610) = 2.
Again, perfect agreement.

A sequence that obeys this law — where the gcd of two terms is itself a term of
the sequence, sitting at the gcd of the indices — is called a **strong
divisibility sequence**. The Fibonacci numbers are the most famous example in all
of mathematics. This one identity is the engine room. Every other result in this
article is a short walk from it.

## Four theorems, one engine

From the Strong Divisibility Law we extract a complete "calculus" — a small,
sharp toolkit. Here are its four theorems, stated plainly.

### 1. The law itself

**F(gcd(m, n)) = gcd(F(m), F(n)).** This is our engine, restated as the first
tool. It deserves top billing because everything else is built from it.

### 2. Coprime positions give coprime values

Two numbers are **coprime** if they share no common factor bigger than 1 — that
is, their gcd is 1. For instance 8 and 9 are coprime, even though neither is
prime. The second theorem says:

> **If m and n are coprime, then F(m) and F(n) are coprime.**

Why does this follow instantly? If gcd(m, n) = 1, then the left side of the law
is F(1) = 1. So the right side, gcd(F(m), F(n)), must also be 1 — which is exactly
the statement that F(m) and F(n) share no common factor. For example, 4 and 9 are
coprime, and indeed F(4) = 3 and F(9) = 34 are coprime (3 and 34 share nothing).

This is the kind of fact that would be a slog to prove by brute force but falls
out of the law in a single line.

### 3. The sharp divisibility characterization

This is the headline result — the answer to the puzzle we started with.

> **For m at least 3: F(m) divides F(n) if and only if m divides n.**

The "if" direction (m divides n forces F(m) to divide F(n)) is the easy,
classical half. The "only if" direction is the real prize, and the Strong
Divisibility Law makes it almost effortless. Suppose F(m) divides F(n). Then
gcd(F(m), F(n)) is just F(m) itself. But by the law, that gcd equals
F(gcd(m, n)). So we have

```
F(gcd(m, n)) = F(m).
```

Now comes the one extra ingredient: for positions of 2 and up, the Fibonacci
numbers are *strictly increasing*, so no value is repeated. Two Fibonacci numbers
can only be equal if they sit at the same position. Therefore gcd(m, n) = m,
which is precisely the statement that m divides n. Done.

**Why the catch "m at least 3"?** Here lies a delightful subtlety. The sequence
opens with F(1) = 1 and F(2) = 1 — the *same value twice*. That single repeated 1
is the one flaw in the mirror. Because F(1) = F(2) = 1, and 1 divides absolutely
everything, the value F(2) divides every F(n). But "2 divides n" is false for odd
n. So the clean "if and only if" genuinely breaks at m = 2. Step past that one
defect — demand m at least 3 — and the calculus becomes flawless. The hypothesis
is not a technicality to be apologized for; it is *exactly sharp*, pinpointing the
unique blemish in an otherwise perfect correspondence.

### 4. The descent step

The fourth tool is a workhorse used in deeper number theory:

> **If a number p divides both F(m) and F(n), then p divides F(gcd(m, n)).**

This too is immediate from the law: if p divides both F(m) and F(n), it divides
their gcd, which by the law *is* F(gcd(m, n)). This "descent" — pushing a common
divisor down to the gcd of the indices — is the key step in one of the crown
jewels of the subject, **Carmichael's primitive divisor theorem**, which says
that (with two small exceptions) every Fibonacci number introduces a brand-new
prime factor never seen earlier in the sequence. Our humble descent lemma is the
gear that makes that grand machine turn.

## The bigger picture: a logarithm in disguise

Step back and admire what we have built. Multiplication and divisibility are
"hard" — factoring a large number is the basis of modern cryptography. Addition
and counting are "easy". A *logarithm* is the classic bridge between the two: it
turns multiplication into addition.

The Fibonacci Divisibility Calculus is a logarithm of a different kind. It turns
the tangled multiplicative question "does this big number F(m) divide that bigger
number F(n)?" into the childishly simple additive question "does m divide n?"
The intricate factor structure of an enormous Fibonacci number — F(100) already
has 21 digits — is completely legible from its tiny index. To know everything
about how F(60) factors against the rest of the sequence, you never need to
compute F(60) at all. You just factor 60.

There is an even finer layer beneath this. Mathematicians study the **rank of
apparition** of a prime p: the first position where p shows up as a factor. The
prime 2 first appears at position 3 (F(3) = 2); the prime 11 first appears at
position 10 (F(10) = 55 = 5 x 11). The conjecture, strongly suggested by our
calculus, is that a prime p divides F(n) exactly when its rank of apparition
divides n. The rank of apparition would then be the true "logarithm" — the
function that linearizes the entire factor lattice of the Fibonacci numbers into
ordinary divisibility of integers. Our descent step is precisely the tool that
makes the rank well defined and minimal. The skeleton is in place; the frontier
beckons.

## Why this matters

It is tempting to file this under "cute facts about a famous sequence". That
would be a mistake. Three threads make it genuinely important.

**It is a template.** The Fibonacci numbers are not the only strong divisibility
sequence. Lucas sequences, elliptic divisibility sequences, and the numbers
arising in the theory of elliptic curves all obey versions of the same law. The
calculus we developed is a *blueprint* that transfers to all of them. Learn it
once on rabbits; apply it across number theory.

**It connects to the hardest problems.** Strong divisibility sequences and their
primitive divisors sit at the heart of questions about prime distribution,
Diophantine equations, and the security assumptions behind cryptographic systems.
The clean descent step we isolated is a load-bearing beam in those cathedrals.

**It is a case study in mathematical elegance.** The entire calculus rests on one
identity. From that single seed grow coprimality, the sharp divisibility
characterization, and the descent lemma — and the one imperfection in the whole
edifice (the repeated 1 at the start) is captured by the one small hypothesis
"m at least 3". Mathematics rarely gets cleaner than this: a maximal harvest of
consequences from a minimal assumption, with every boundary case understood
exactly.

## The takeaway

The next time you see the Fibonacci numbers spiraling through a pinecone, remember
that they are also keeping a secret ledger. Every entry in that ledger — which
number divides which, which factors appear where — is determined in advance by the
plain arithmetic of the positions 1, 2, 3, 4, ... The values may grow
astronomically, but their divisibility never strays from the simple counting that
indexes them.

That is the quiet miracle of the Fibonacci Divisibility Calculus. Out of "just
keep adding" comes a perfect dictionary between the easy world of counting and the
hard world of factoring — a dictionary with exactly one typo, on the very first
page, and not a single error after.
