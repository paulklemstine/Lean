# One Rule to Bind Them: The Hidden Skeleton Behind Fibonacci and Mersenne Numbers

## A number that always shows up first

Pick a prime number — say 11. Now march through the Fibonacci sequence, the
famous list where each number is the sum of the previous two:

```
F:  1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, ...
n:  1  2  3  4  5  6   7   8   9  10  11   12   13  ...
```

When does 11 first appear as a divisor? It skips right past 5, 8, 13, 21, 34,
and finally divides 55 — the tenth Fibonacci number. So we say that **10 is the
entry point of 11**: the first place 11 manages to sneak into the sequence.

Here is the small miracle. Once you know that 11 first divides the tenth
Fibonacci number, you know *every* Fibonacci number it will ever divide: exactly
the ones whose index is a multiple of 10. The 20th, the 30th, the 40th — yes.
Everything else — never. The single number 10 controls the entire infinite
pattern of where 11 lives in the Fibonacci world.

Mathematicians have known this fact about Fibonacci numbers for over a century.
It is the backbone of a celebrated 1913 result of R. D. Carmichael about
"primitive" prime divisors, and it hides inside countless puzzles about golden
ratios and rabbit populations. The entry point even has a dignified old name:
the **rank of apparition**, the index at which a prime first *makes its
appearance*.

This article is about a discovery that the same backbone holds up a structure
nobody expected it to — and that the proof, once you find the right vantage
point, needs almost nothing about Fibonacci numbers at all.

## The same trick, a completely different sequence

Leave the rabbits behind and consider a sequence from a different corner of
arithmetic: the numbers one less than a power of two.

```
M:  1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, ...
n:  1  2  3   4   5   6    7    8    9    10  ...
```

These are the **Mersenne numbers** `2^n - 1`, the raw material of the largest
known primes and a cornerstone of computer arithmetic (a string of `n` ones in
binary is exactly `2^n - 1`). Ask the same question: when does the prime 7 first
divide one of them? It divides `2^3 - 1 = 7` immediately. Entry point 3.

And now the punchline: 7 divides `2^n - 1` *exactly* when `n` is a multiple of 3.
The 6th term `63 = 7 × 9`, yes. The 9th term `511 = 7 × 73`, yes. Everything in
between, never. One number — the entry point 3 — again controls an entire
infinite divisibility pattern.

Two sequences with nothing obvious in common. One is built from addition (each
term is a sum), the other from multiplication (each term is a power). One is
woven from the golden ratio; the other from doubling. Yet both obey the *same
law*: a prime's behaviour across the whole infinite sequence is dictated by a
single number, its entry point, and the prime divides the `n`-th term precisely
when the entry point divides `n`.

When two unrelated objects behave identically, a mathematician's instinct is to
ask: *what is the real reason?* Strip away the costumes — golden ratios, powers
of two — and find the one structural fact that is doing all the work.

## The one rule that explains everything

Here is that fact. It is a statement about how a sequence interacts with the
*greatest common divisor* (gcd), the largest number dividing two given numbers.

> A sequence `a(1), a(2), a(3), …` is called a **strong divisibility sequence**
> if, for every pair of positions `m` and `n`,
>
> **the gcd of `a(m)` and `a(n)` equals `a(gcd(m, n))`.**

Read that slowly, because it is the whole story. It says the sequence converts
"greatest common divisor of positions" into "greatest common divisor of values"
without distortion. The gcd of the 12th and 18th terms is the 6th term, because
`gcd(12, 18) = 6`. The sequence is a faithful translator between two worlds of
divisibility.

It is a striking, rigid demand, and most sequences fail it spectacularly. But
the Fibonacci numbers satisfy it exactly:

```
gcd(F(12), F(18)) = gcd(144, 2584) = 8 = F(6),   and gcd(12, 18) = 6. ✓
```

And so do the Mersenne numbers `b^n - 1` for any base `b`:

```
gcd(2^12 - 1, 2^18 - 1) = gcd(4095, 262143) = 63 = 2^6 - 1,   gcd(12,18)=6. ✓
```

That shared rule is the secret skeleton. Everything you can prove about entry
points follows from it and from nothing else — not from any special feature of
either family.

## Building the whole theory from a single brick

Let us see how much we can squeeze out of that one rule. Suppose `a` is any
strong divisibility sequence.

**First consequence — bigger positions inherit divisibility.** If a position `m`
divides a position `n`, then the value `a(m)` divides the value `a(n)`. Why? If
`m` divides `n`, then `gcd(m, n)` is just `m`. The rule then says
`gcd(a(m), a(n)) = a(m)`, which is precisely the statement that `a(m)` divides
`a(n)`. One line. (This already recovers the well-known fact that the 6th
Fibonacci number, 8, divides the 12th, 144.)

**The entry point appears.** For a prime `p` that divides *some* term, define its
**entry point** `z(p)` as the smallest position `k > 0` with `p` dividing `a(k)`.
This number exists by the simplest possible principle — among any nonempty
collection of positive whole numbers, there is a smallest one.

**The master theorem — entry point controls everything.** Here is the result
that explained both of our opening observations at once:

> **A prime `p` divides `a(n)` if and only if its entry point `z(p)` divides `n`.**

One direction is the inheritance fact above: if `z(p)` divides `n`, then `a(z(p))`
divides `a(n)`, and since `p` divides `a(z(p))`, it divides `a(n)` too. The other
direction is the clever half, and it is pure gcd-judo. Suppose `p` divides `a(n)`
but, contrary to the claim, `z(p)` does *not* divide `n`. Then `gcd(z(p), n)` is
strictly smaller than `z(p)`. But the rule guarantees that `p` divides
`a(gcd(z(p), n))` — because `p` divides both `a(z(p))` and `a(n)`, and the value
at a gcd of positions is the gcd of the values. We have found a *smaller*
position where `p` appears, contradicting the very definition of `z(p)` as the
smallest. The contradiction forces `z(p)` to divide `n` after all.

That is the entire proof. No golden ratio. No powers of two. Just the one
translation rule and the principle that every nonempty set of positive integers
has a least element.

## Primitivity is just "maximum order"

There is a beautiful reformulation lurking here. Call a prime `p` a **primitive
divisor** of `a(n)` if `p` divides `a(n)` but divides none of the earlier terms
`a(1), …, a(n-1)`. Primitive divisors are the genuinely *new* primes a sequence
manufactures at each step — they are what make Carmichael's theorem and its
cousins so deep.

From the master theorem, "primitive" collapses to something almost trivial to
state:

> **`p` is a primitive divisor of `a(n)` if and only if `z(p) = n`.**

A primitive divisor is nothing more than a prime whose entry point lands *exactly*
on `n`. Primitivity, that subtle-sounding notion, is revealed to be the cleanest
possible condition: the entry point hits this index first, and never before.

A free bonus comes with it: **a given prime can be a primitive divisor of at most
one term in the whole sequence.** Its entry point `z(p)` is a single number, so
there is exactly one index it can be primitive for. Primes are monogamous with
respect to first appearances.

## Two primes, one rhythm

The structure keeps giving. Suppose `p` first appears at position `a` and `q`
first appears at position `b`. When do *both* divide the same term `a(n)`? By the
master theorem, `p` requires `a | n` and `q` requires `b | n`. Both happen
exactly when `n` is a multiple of the **least common multiple** of `a` and `b`:

> **Both `p` and `q` divide `a(n)` if and only if `lcm(a, b)` divides `n`.**

So two primes fall into step with each other at a fixed beat — the lcm of their
individual entry points — and the pattern of their joint appearances is itself
just another arithmetic progression. The same is true for any finite collection
of primes at once: their common appearances are governed by the lcm of all their
entry points.

This even has a *quantitative* face. Among the first `N` positions, the fraction
that are appearance-points of a prime with entry point `n` is exactly `1/n`
(rounded down, it's `⌊N/n⌋` of them). The entry point doesn't just decide *where*
a prime appears — it pins down *how often*: a prime of entry point `n` shows up
with density precisely `1/n`. Two primes with entry points `a` and `b` coincide
with density `1/lcm(a, b)`. The arithmetic of appearance becomes the arithmetic
of fractions.

## Why this is more than a tidy repackaging

It would be enough of a pleasure to learn that one rule explains the Fibonacci
and Mersenne patterns. But the real prize is what the abstraction *buys* you.

Before, Fibonacci entry points and Mersenne entry points were two separate
theories, proved separately, each leaning on its own special toolkit. After, they
are **one theorem applied twice.** To get the Fibonacci version, you check the
single fact `gcd(F(m), F(n)) = F(gcd(m, n))`. To get the Mersenne version, you
check `gcd(2^m - 1, 2^n - 1) = 2^{gcd(m,n)} - 1`. Both are short, classical
verifications. Everything else — the master theorem, primitivity, the lcm rhythm,
the densities — is inherited wholesale, with not a single new argument.

That means brand-new statements arrive *for free*. The "two-prime rhythm"
above, applied to Mersenne numbers, is a genuinely new fact about the divisors of
`b^n - 1` — and it required no work beyond noticing that the Mersenne sequence
passes the one entrance exam. The identity sequence `a(n) = n` passes it too
(trivially), and there the whole theory degenerates into the ordinary
arithmetic of divisibility, reassuring us that the framework contains the
familiar world as its simplest special case.

This is the recurring dream of mathematics: to find that scattered phenomena are
shadows of a single structure. The "strong divisibility" rule is that structure
for entry points. It tells us that whenever a sequence faithfully translates gcds
of positions into gcds of values, an entire calculus of first appearances snaps
into place — divisibility, primitivity, joint rhythms, and densities — none of it
caring whether the sequence was born from rabbits, from doubling, or from
something not yet imagined.

## The frontier

One question this lens sharpens but does not yet settle is the deepest one:
*does* a brand-new primitive prime always appear? For Fibonacci numbers the
answer is yes for every index beyond a small handful of exceptions (the largest
being the 12th, whose value `144 = 2^4 × 3^2` recycles only old primes) — this is
Carmichael's theorem. For Mersenne-type numbers the analogous yes is the
classical Bang–Zsygmondy theorem.

The framework here reveals exactly *why* these two famous results are siblings:
both ask for a prime whose entry point is maximal — equal to `n` itself. The
entry-point machinery handles, uniformly and completely, the question of *where a
prime lives once it exists*. What it deliberately leaves open is the question of
*existence* — guaranteeing a fresh prime at each new index — because that, and
only that, requires knowing how fast the sequence grows. Fibonacci numbers grow
like powers of the golden ratio; Mersenne numbers like powers of two. The growth
is the one ingredient the pure gcd-rule cannot supply.

And that is a satisfying place to stand. We have cleanly separated a problem into
the part that is *structural* — now understood completely and shared across every
strong divisibility sequence — and the part that is *analytic*, about size and
growth. The skeleton is finished. What remains is to measure the flesh.
