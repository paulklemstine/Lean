# The Number That Never Makes a Prime

## A riddle hidden in the powers of two

Pick a whole number $k$. Now build an infinite family of numbers from it by
multiplying by powers of two and adding one:

$$k\cdot 2^1 + 1,\quad k\cdot 2^2 + 1,\quad k\cdot 2^3 + 1,\quad \dots$$

For most starting values of $k$, this sequence is a fountain of primes. Take
$k = 1$: you get $3, 5, 9, 17, 33, 65, 129, 257, \dots$, and scattered through it
are the famous Fermat-style primes $3, 5, 17, 257$. Take $k = 3$ and you again
stumble onto primes almost immediately. Number theorists long believed that *every*
odd $k$ must eventually produce a prime in this list — after all, the numbers grow,
they thin out, but primes keep appearing forever, so why should any starting value
be forbidden from ever hitting one?

In 1960, the Polish mathematician Wacław Sierpiński proved something startling:
there exist odd numbers $k$ for which $k\cdot 2^n + 1$ is **never** prime — not for
$n = 1$, not for $n = 2$, not for any $n$ at all, no matter how far you go. Such a
number is called a **Sierpiński number**. It is a starting value that has been
permanently exiled from the world of primes.

This raises an irresistible question: *what is the smallest Sierpiński number?* In
1962 John Selfridge found a candidate that has resisted every attempt to dethrone
it for more than sixty years:

$$\boxed{78557}$$

This article tells the story of *why* $78557$ never makes a prime — a story whose
hero is not a giant calculation but a single, elegant idea called a **covering
system**. It is one of those rare arguments where, instead of checking infinitely
many numbers one by one, we trap all of them at once inside a finite net.

## The trick: catch infinitely many fish with a finite net

Here is the problem in its rawest form. To show $78557$ is a Sierpiński number we
must show that *every* number in the infinite list

$$78557\cdot 2^1 + 1,\quad 78557\cdot 2^2 + 1,\quad 78557\cdot 2^3 + 1,\quad \dots$$

is composite — that each one has a factor other than $1$ and itself. We cannot check
infinitely many numbers. So we need a structural reason, a guarantee that applies to
all of them simultaneously.

The covering-system idea is this. Suppose we could find a small fixed list of primes —
call them the **covering primes** — with the magical property that *for every
exponent $n$, at least one prime on the list divides $78557\cdot 2^n + 1$.* Then the
sequence can never be prime: every term is divisible by one of a handful of small
primes (and is far bigger than any of them), so every term is composite. The infinite
problem collapses to checking that the net has no holes.

For $78557$ the covering primes are exactly seven small numbers:

$$\{3,\ 5,\ 7,\ 13,\ 19,\ 37,\ 73\}.$$

The remaining question is: how do we *guarantee* that one of these seven always lands
a hit, for every one of the infinitely many exponents?

## Powers of two run in circles

The secret is that powers of two, when viewed through the lens of a fixed prime, are
not chaotic — they cycle. Look at the remainders of $2^n$ when you divide by $7$:

$$2^1 = 2,\ 2^2 = 4,\ 2^3 = 8 \equiv 1,\ 2^4 \equiv 2,\ 2^5 \equiv 4,\ 2^6 \equiv 1,\ \dots$$

The pattern $2, 4, 1, 2, 4, 1, \dots$ repeats with period $3$. We say the
*multiplicative order of $2$ modulo $7$* is $3$. Every prime $p$ has such a period:
modulo $3$ the cycle has length $2$, modulo $5$ it has length $4$, modulo $13$ length
$12$, and so on.

This periodicity is the engine of the whole argument, and it is worth stating
precisely. If a prime $p$ satisfies $2^m \equiv 1 \pmod p$, then $2^n$ depends only on
the remainder of $n$ upon division by $m$:

> **The Clockwork Lemma.** If $2^m \equiv 1 \pmod p$ and $n$ leaves remainder $a$ when
> divided by $m$, then $2^n \equiv 2^a \pmod p$.

In words: once you know where $n$ sits inside one period, you know the value of $2^n$
modulo $p$ for free. The powers of two are a clock, and only the hour matters, not how
many full days have passed.

A companion fact lets us turn this into a statement about our actual sequence:

> **The Transfer Lemma.** If a prime $p$ divides $78557\cdot 2^a + 1$, and
> $2^n \equiv 2^a \pmod p$, then $p$ also divides $78557\cdot 2^n + 1$.

So if $p$ catches the term at exponent $a$, it automatically catches the term at every
exponent $n$ that sits at the same hour on $p$'s clock. One verified hit pays for an
entire arithmetic progression of exponents.

## The seven-cog machine

Now we can assemble the net. Each covering prime patrols a particular set of exponents,
described by a congruence — "all $n$ leaving a fixed remainder modulo a fixed number."
For $78557$ the assignment is:

| If the exponent $n$ satisfies... | then this prime divides $78557\cdot 2^n+1$ |
|---|---|
| $n \equiv 0 \pmod 2$ | $3$ |
| $n \equiv 1 \pmod 4$ | $5$ |
| $n \equiv 1 \pmod 3$ | $7$ |
| $n \equiv 11 \pmod{12}$ | $13$ |
| $n \equiv 15 \pmod{18}$ | $19$ |
| $n \equiv 27 \pmod{36}$ | $37$ |
| $n \equiv 3 \pmod 9$ | $73$ |

Read it like a set of patrol beats. The prime $3$ covers every even exponent — half of
all numbers in one stroke. The prime $5$ takes a quarter of what's left. The remaining
primes mop up the increasingly rare exponents that slip through. The largest modulus is
$36$, which is the least common multiple of all the periods involved. Because of the
Clockwork Lemma, *the entire infinite question reduces to checking the $36$ exponents
$n = 0, 1, 2, \dots, 35$.* If those $36$ residues are all covered — and they are — then
periodicity guarantees every exponent forever is covered too.

You can check the corners of the machine by hand. Take $n = 35$. It is odd, so $3$
misses. $35 \bmod 4 = 3$, not $1$, so $5$ misses. $35 \bmod 3 = 2$, so $7$ misses.
$35 \bmod 12 = 11$ — a hit! The prime $13$ divides $78557\cdot 2^{35} + 1$. The net
holds. Run through all $36$ residues and not a single one escapes; every exponent in the
universe falls into at least one patrol beat. That is the whole proof of compositeness,
compressed into a table you could write on a napkin.

## What "covering" really means

Behind the table lies a clean piece of mathematics worth naming in its own right. A
**congruence class** is the set of all integers leaving a fixed remainder $a$ when
divided by a fixed modulus $m$ (with $0 \le a < m$). A **covering system** is a finite
collection of congruence classes whose union is *all* the integers — every number, no
matter how large, lands in at least one class.

Covering systems were introduced by Paul Erdős in the 1930s and are deceptively subtle.
It is easy to cover the integers if you allow the trivial class "everything modulo $1$,"
but covering with *distinct, larger* moduli is a delicate combinatorial art. The Sierpiński
argument bolts a covering system onto number theory: it pairs each congruence class with a
prime, so that "land in this class" implies "be divisible by this prime."

The bridge that makes congruence classes fit together so neatly is the **Chinese
Remainder Theorem**, a result over fifteen centuries old. It says that if two moduli
share no common factor, then you can always find a number with any prescribed pair of
remainders. In the language of covering systems: congruence classes with coprime moduli
are always *compatible* — they overlap. This is the structural glue that lets a designer
of covering systems mix periods like $4$, $9$, and $25$ freely without fear that two beats
contradict each other.

There is also a hard limit on how cheaply you can cover. If every patrol beat uses the
*same* modulus $m$, then you are forced to use at least $m$ of them — one for each
possible remainder. This is a pigeonhole fact: $m$ distinct remainders cannot be covered
by fewer than $m$ classes. Real covering systems escape this tax precisely by using a
*variety* of moduli, letting a small modulus like $2$ shoulder half the load while large
moduli handle the stragglers. The $78557$ system is a small masterpiece of this
balancing act: seven primes, seven moduli, perfect coverage with no waste large enough to
remove.

## The verification, made finite

One genuinely beautiful feature of the argument is that an infinite claim becomes a
finite computation. The periodicity of every patrol beat means the coverage pattern
repeats with period equal to the least common multiple of all the moduli — here, $36$.
Formally:

> **Finite Verification.** A covering system covers *every* natural number if and only if
> it covers each of the residues $0, 1, \dots, L-1$, where $L$ is the least common multiple
> of the moduli.

So to certify the seven-cog machine, you check $36$ cases and you are done — for all
eternity. This is the difference between a hope and a proof: not "we tested it up to a
billion," but "we tested it for one full period, and the period is all there is."

## The unconquered summit: is 78557 really the smallest?

Sierpiński proved such numbers exist; Selfridge produced $78557$ and its seven-cog
covering. But proving that $78557$ is the *smallest* Sierpiński number is a different and
far harder task — and it remains **open to this day.**

To dethrone $78557$ you would have to show that every odd number below it eventually does
produce a prime. The vast majority were eliminated long ago by simply finding such a
prime. But a handful of stubborn holdouts remain. For each surviving candidate $k$, the
challenge is starkly concrete:

> **Find a single exponent $n$ for which $k\cdot 2^n + 1$ is prime.**

For the smallest holdout, $k = 21181$, distributed computing projects have tested
exponents into the tens of millions without success. Nobody has found a prime; nobody has
proved one cannot exist. The number sits in a strange limbo — almost certainly not a
Sierpiński number, but not yet proven innocent. If even one of these holdouts turned out
to be a genuine Sierpiński number smaller than $78557$, the sixty-year-old guess would
collapse.

So the final picture is a tale of two certainties. That $78557$ never makes a prime is
secured by an argument so tight it fits in a table of seven rows — a finite net thrown
over an infinite sea. That $78557$ is the *smallest* such number is a conjecture hanging
on a thread, waiting for a single prime to be found among a few astronomically large
candidates. The same multiplication, $k \cdot 2^n + 1$, gives us one of mathematics'
cleanest finished proofs and one of its most tantalizing open problems, side by side.

## Why the idea endures

The covering-system trick is bigger than $78557$. The very same machinery — periodicity of
$b^n$ modulo $p$, a covering of the exponents, the Chinese Remainder Theorem stitching the
pieces together — proves the existence of analogous "forbidden" starting values for
$k\cdot b^n + 1$ in other bases, and for **Riesel numbers**, where one studies
$k\cdot 2^n - 1$ instead. Each variation reuses the identical skeleton: powers run in
circles, a finite table catches every exponent, and an infinite question is settled in a
single page.

That is the quiet power on display here. Faced with infinity, the mathematician does not
flinch and start counting. They look for the hidden clockwork — the period that makes the
endless repeat itself — and then they only have to look once.
