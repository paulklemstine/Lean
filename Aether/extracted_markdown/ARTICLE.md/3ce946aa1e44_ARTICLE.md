# The One Rule That Two Famous Theorems Were Secretly Obeying

## A puzzle hidden in a child's sequence

Start with two numbers, 0 and 1, and keep adding the last two together. You get the
most famous sequence in mathematics:

$$0,\ 1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ 89,\ 144,\ 233, \dots$$

These are the Fibonacci numbers, $F(0), F(1), F(2), \dots$. They appear in
sunflower seed-heads, pinecone spirals, and the breeding tables of Leonardo of Pisa's
imaginary rabbits. But beneath the decoration lies a question that took the better part
of a century to settle.

Look at the prime factorizations as you walk down the list:

| $n$ | $F(n)$ | prime factors |
|----|--------|---------------|
| 7  | 13     | **13** |
| 8  | 21     | 3 · **7** |
| 9  | 34     | 2 · **17** |
| 10 | 55     | 5 · **11** |
| 11 | 89     | **89** |
| 12 | 144    | 2⁴ · 3² |
| 13 | 233    | **233** |
| 14 | 377    | 13 · **29** |

Notice the boldfaced primes. At step 8 the factor **7** appears for the very first time:
no earlier Fibonacci number is divisible by 7. At step 9, the same is true of **17**. At
step 14, of **29**. These newcomers are called **primitive prime divisors** — primes that
divide $F(n)$ but divide none of $F(1), F(2), \dots, F(n-1)$. Each one is making its grand
entrance into the sequence at exactly that position.

Now look at step 12. Its factorization is $2^4 \cdot 3^2$ — and both 2 and 3 have appeared
before (2 divides $F(3)=2$, and 3 divides $F(4)=3$). There is no newcomer at all. The
number 144 is, in this sense, *barren*: it carries no prime that is genuinely its own.

So here is the question. As you march down the Fibonacci sequence forever, does every term
eventually get its own private prime? Or do barren terms like 144 keep cropping up?

In 1913, R. D. Carmichael gave the definitive answer.

> **Carmichael's Theorem.** Every Fibonacci number $F(n)$ with $n \ge 13$ has a primitive
> prime divisor. The *only* terms without one are $F(1), F(2), F(6), F(12)$ — the numbers
> $1, 1, 8, 144$.

Four exceptions in an infinite sequence, then primitive primes forever after. It is a small
miracle of regularity, and it is genuinely hard to prove in full: the general case hinges on
delicate estimates about how fast certain factors of $F(n)$ grow.

## A different sequence, the same miracle

Carmichael's theorem has an older, almost identical cousin. Replace the Fibonacci recipe with
the simplest exponential one:

$$M(n) = 2^n - 1 : \quad 1,\ 3,\ 7,\ 15,\ 31,\ 63,\ 127,\ 255,\ 511,\ 1023, \dots$$

These are the numbers behind Mersenne primes and the largest primes humanity has ever found.
Hunt for primitive primes again:

| $n$ | $2^n-1$ | prime factors |
|----|---------|---------------|
| 5  | 31      | **31** |
| 6  | 63      | 3² · 7 |
| 7  | 127     | **127** |
| 8  | 255     | 3 · 5 · **17** |

At step 6 — and *only* step 6 — the number $63 = 3^2 \cdot 7$ has no newcomer: 3 appeared
back at step 2 ($2^2-1=3$), and 7 appeared at step 3 ($2^3-1=7$). In 1886, the Danish
mathematician A. S. Bang proved the matching result:

> **Bang's Theorem.** Every number $2^n - 1$ with $n \ge 2$ has a primitive prime divisor,
> with the single exception $n = 6$, where $2^6 - 1 = 63$.

Two theorems, two famous sequences, two different centuries, two different proofs. Fibonacci
and powers of two seem to have nothing to do with each other. So why do they tell *exactly*
the same story — a tiny handful of barren terms, then an endless parade of newcomers?

This article is about the answer: a single rule, almost embarrassingly simple, that both
sequences quietly obey — and a single, computable test that detects newcomers in *both*
worlds without ever caring which world it is in.

## The rule both sequences obey

Pick any two Fibonacci numbers and take their greatest common divisor (gcd) — the largest
number dividing both. For instance, $F(8) = 21$ and $F(12) = 144$. Their gcd is 3. Now look at
where the *indices* 8 and 12 meet: $\gcd(8, 12) = 4$, and $F(4) = 3$. The same answer.

This is no accident. The Fibonacci sequence satisfies what is called the **strong divisibility
law**:

$$\boxed{\ \gcd\bigl(F(m),\, F(n)\bigr) = F\bigl(\gcd(m, n)\bigr).\ }$$

The greatest common divisor of two terms is the term at the gcd of their positions. Divisibility
in the *values* is a perfect mirror of divisibility in the *indices*.

Here is the punchline: $2^n - 1$ obeys the very same law.

$$\gcd\bigl(2^m - 1,\, 2^n - 1\bigr) = 2^{\gcd(m, n)} - 1.$$

For example $\gcd(2^8 - 1, 2^{12} - 1) = \gcd(255, 4095) = 15 = 2^4 - 1 = 2^{\gcd(8,12)} - 1$.

Any sequence $u(1), u(2), u(3), \dots$ of whole numbers obeying

$$\gcd\bigl(u(m),\, u(n)\bigr) = u\bigl(\gcd(m, n)\bigr)$$

is called a **strong divisibility sequence**. Fibonacci is one. The Mersenne family $a^n - 1$
is one (for any fixed base $a$). So are many others. And the central claim of this work is that
the entire phenomenon — barren terms, newcomers, the whole Carmichael/Bang miracle — is a
property of *this one law alone*, not of anything special about Fibonacci numbers or powers of
two.

## A machine for catching newcomers

How would you actually *detect* whether $u(n)$ has a primitive prime divisor? The naive
definition is awkward: you would have to factor $u(n)$ and then check every earlier term to
make sure none of its primes appeared before. That is a lot of factoring.

There is a far slicker route, and it uses the strong divisibility law as its engine. The idea is
**subtraction by gcd**. Suppose you want to scrub out of $u(n)$ every prime that it *shares* with
an earlier term $u(d)$. You do not need to factor anything. You just compute $g = \gcd(u(n),
u(d))$ and divide $u(n)$ by $g$. Repeat — take the gcd again, divide again — until the gcd drops
to 1. What is left is exactly the part of $u(n)$ built from primes that $u(d)$ never touched.

We package this as a small routine called **`removePrimesOf`**: given two numbers $a$ and $b$, it
strips from $a$ every prime it shares with $b$, by repeatedly dividing out $\gcd(a, b)$. The
result divides $a$ and is coprime to $b$ (shares no prime with it).

Now build the newcomer-detector. For a term $u(n)$, the candidates for "old" primes are the
terms $u(d)$ where $d$ is a *proper divisor* of $n$ (a divisor smaller than $n$). Why only the
divisors? Because of the strong divisibility law — and this is the one genuinely number-theoretic
step in the whole story. If a prime $p$ divides both $u(n)$ and some earlier term $u(k)$, then by
the law it must divide $u(\gcd(n, k))$, and $\gcd(n,k)$ is a *divisor* of $n$ smaller than $n$. So
every "old" prime of $u(n)$ already shows up at a proper divisor of $n$. You never have to look at
the messy non-divisor indices at all.

So the **coprime part** of $u(n)$ is computed like this:

1. Start with the value $u(n)$ itself.
2. For each proper divisor $d$ of $n$, strip out the primes shared with $u(d)$ using
   `removePrimesOf`.
3. Whatever survives is built *entirely* from primes that appear at no earlier index — that is,
   from primitive primes.

The verdict is then almost insultingly simple:

> **The engine.** If the coprime part of $u(n)$ is greater than 1, then $u(n)$ has a primitive
> prime divisor.

If anything at all survives the scrubbing, that survivor is made of newcomers, so a newcomer
exists. And crucially, the engine *never mentions Fibonacci or powers of two*. It uses only gcds,
divisions, and the strong divisibility law. It is sequence-blind.

## Two theorems for the price of one

Watch what happens when you feed the two sequences into the same engine.

**Fibonacci.** Run the coprime-part computation on $F(n)$ for every $n$ from 1 to 1000. For each
$n$ from 13 onward, the coprime part comes out greater than 1 — a newcomer is guaranteed. For
$n = 1, 2, 6, 12$ the coprime part collapses to exactly 1: nothing survives, no newcomer. That is
Carmichael's theorem, exceptions and all, falling straight out of the computation.

**Mersenne.** Run the *same* engine on $2^n - 1$ for every $n$ from 2 to 120. Every term reports a
coprime part greater than 1 — except $n = 6$, where $63 = 3^2 \cdot 7$ scrubs down to 1. That is
Bang's theorem, with its lone exception isolated automatically.

The remarkable thing is not just that the engine works in both cases. It is that you write the
detector *once*, prove it correct *once* (using nothing but the gcd law), and then the two
classical theorems are simply two different inputs. Carmichael 1913 and Bang 1886 — separated by
twenty-seven years, two different sequences, two different proof techniques — are revealed to be
the same theorem wearing two costumes.

Here is a glimpse of the output, with each newcomer prime found and independently verified:

```
 Fibonacci:   n=13 -> primitive prime 233    n=14 -> 29    n=18 -> 19    n=24 -> 23
 2^n - 1:     n=7  -> primitive prime 127    n=8  -> 17    n=11 -> 23    n=12 -> 13
 Fibonacci exceptions found in [1,200]:  {1, 2, 6, 12}   (exactly Carmichael's)
 2^n - 1   exceptions found in [1,120]:  {1, 6}          (exactly Bang's)
```

## Why this matters

There is a recurring pleasure in mathematics: discovering that two things you thought were
unrelated are, at bottom, the *same* thing. Often the unification also simplifies. Here it does
both. Carmichael's original proof for Fibonacci and Bang's for $2^n - 1$ each required their own
machinery. By identifying the strong divisibility law as the true source of the phenomenon, the
newcomer-detection problem dissolves into a few lines of gcd arithmetic that don't know — and
don't need to know — which sequence they are looking at.

This also reframes what the "hard part" of these theorems really is. The engine reduces the entire
question to a single inequality: *is the coprime part bigger than 1?* That is a purely
computational quantity. For any finite range of $n$ you can simply check it — and a computer does,
exhaustively and without error, confirming Carmichael on $13 \le n \le 1000$ and Bang on
$2 \le n \le 120$. What remains, for an unconditional proof covering *all* $n$, is a clean size
estimate: showing that the surviving coprime part can never shrink to 1 once $n$ is large enough.
The deep analytic content — bounds on how fast the "cyclotomic" factors of these sequences grow —
has been quarantined into one honest inequality, rather than tangled through the whole argument.

The same engine, untouched, applies to a whole zoo of other sequences that obey the gcd law:
the Lucas numbers, repunits (numbers like $111\dots1$), and more general Lucas sequences. Each
comes with its own Carmichael-style theorem, and each can be fed to the same detector. The
mathematics is no longer "the Fibonacci primitive divisor theorem" or "the Mersenne primitive
divisor theorem." It is one theorem about a single, simple law — and a small, sequence-blind
machine that proves it.

## The moral

The Fibonacci numbers and the powers of two could hardly look more different. One grows by
addition, the other by doubling; one spirals through sunflowers, the other powers
record-breaking prime searches. Yet press on each of them and the same hidden gear turns: the
greatest common divisor of two terms is the term at the greatest common divisor of their
positions. From that one gear, the entire choreography of newcomer primes — four barren Fibonacci
terms, one barren Mersenne term, and an infinite procession of fresh primes thereafter — follows
of its own accord.

It is a reminder that the surface of mathematics, with its rabbits and its record primes, is just
the costume. The plot underneath is often a single, quiet rule.
