# When Do Fibonacci Numbers Land on a Multiple? The Hidden Clockwork of Apparition

## A simple question with a surprisingly deep answer

Start writing down the Fibonacci numbers, the most famous sequence in
mathematics. Each one is the sum of the two before it:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, ...
```

Now pick any whole number you like — say 7 — and ask a deceptively
childlike question: *which* Fibonacci numbers are multiples of 7?

Scan the list. The first multiple of 7 you meet is 21, the eighth
Fibonacci number. Keep going and you find that 987 (the sixteenth) is a
multiple of 7, and 46368 (the twenty-fourth) is too. The positions where
7 "appears" are 8, 16, 24, 32, ... — exactly the multiples of 8.

Try the same with 4. The Fibonacci multiples of 4 sit at positions
6, 12, 18, 24, ... — the multiples of 6. Try 5, and you find positions
5, 10, 15, 20, ... — the multiples of 5.

A startling pattern emerges. For *every* modulus you choose, the
positions where it appears in the Fibonacci sequence form a perfectly
regular arithmetic ladder: all the multiples of some single special
number. That special number is called the **rank of apparition**, and it
is the secret heartbeat of the Fibonacci sequence. This article is about
its hidden clockwork — and a clean new theorem describing how the
heartbeat of a *product* relates to the heartbeats of its *factors*.

## The rank of apparition

Let us name the object precisely. For a positive whole number `m`, the
**rank of apparition** of `m`, which we write `α(m)`, is the position of
the *first* Fibonacci number divisible by `m`. From the experiments
above:

- `α(2) = 3`, because the third Fibonacci number, 2, is the first even one.
- `α(3) = 4`, because the fourth Fibonacci number is 3.
- `α(4) = 6`, because the sixth Fibonacci number, 8, is the first multiple of 4.
- `α(5) = 5`, because the fifth Fibonacci number is 5.
- `α(7) = 8`, because the eighth Fibonacci number, 21, is the first multiple of 7.

The first remarkable fact is that `α(m)` *always exists*: every positive
modulus eventually divides some Fibonacci number. Why should that be
true? The proof is a beautiful pigeonhole argument. Watch the Fibonacci
numbers not as integers but as *remainders* after dividing by `m`. Each
step depends only on the previous two remainders, so the engine driving
the sequence is the **pair** `(F(n), F(n+1))` reduced modulo `m`. There
are only finitely many possible pairs — at most `m²` of them — so as the
sequence marches on forever, some pair must eventually recur. And here is
the elegant twist: the Fibonacci rule is *reversible*. From the pair at
one moment you can compute the pair one step *earlier* by subtraction.
So once a pair repeats, you can rewind both copies in lockstep all the
way back to the very beginning, proving the sequence of pairs is purely
periodic. Somewhere inside that first cycle, the remainder must hit zero —
and that is the apparition.

The second remarkable fact is the regularity we noticed by hand. It has a
name: the **law of apparition**.

> **Law of Apparition.** For any modulus `m > 0`, the Fibonacci number
> `F(k)` is divisible by `m` *if and only if* the rank of apparition
> `α(m)` divides the position `k`.

In symbols: `m ∣ F(k)  ⇔  α(m) ∣ k`. This is why the appearances of 7
land exactly on positions 8, 16, 24, ... — they are precisely the
multiples of `α(7) = 8`. The law turns a question about an infinite,
fast-growing sequence into a question about a single small number.

The engine behind the law is one of the most elegant identities in all of
number theory, due to Édouard Lucas:

> the greatest common divisor of `F(m)` and `F(n)` equals `F(gcd(m, n))`.

Fibonacci numbers "commute with the gcd." From this, the law of
apparition follows almost mechanically: if `m` divides both `F(k)` and
`F(α(m))`, then it divides their gcd, which is `F(gcd(k, α(m)))`. But
`α(m)` was the *smallest* index that works, so `gcd(k, α(m))` cannot be
smaller — it must equal `α(m)` itself, meaning `α(m)` divides `k`.

## The new question: factoring the heartbeat

Here is where this cycle of work picks up the thread. The law of
apparition tells us everything about a *single* modulus. But whole
numbers have *structure*: they factor into primes. A natural and
ambitious question is whether the rank of apparition respects that
structure. If I know the heartbeats `α(m)` and `α(n)`, can I predict the
heartbeat `α(m·n)` of the product?

The answer, it turns out, is a crisp and satisfying *yes* — provided
`m` and `n` share no common factor. This is the headline result.

> **Coprime Multiplicativity of Apparition.** If `m` and `n` are
> positive and coprime (their gcd is 1), then
> `α(m·n) = lcm(α(m), α(n))`,
> the least common multiple of the two ranks.

In words: *the heartbeat of a coprime product is the least common
multiple of the heartbeats of its parts.*

Let us test it. Take `m = 2` and `n = 5`, which are coprime. We have
`α(2) = 3` and `α(5) = 5`, so the theorem predicts
`α(10) = lcm(3, 5) = 15`. And indeed, the fifteenth Fibonacci number is
610 = 10 × 61, the first multiple of 10 in the sequence. The clockwork
checks out.

Why is this true? The argument is a perfect example of a
*local-to-global* principle, the same philosophy behind the Chinese
Remainder Theorem. Saying that `m·n` divides a Fibonacci number `F(k)` is
— *because `m` and `n` are coprime* — exactly the same as saying that
both `m` divides `F(k)` and `n` divides `F(k)`. Now apply the law of
apparition twice: the first condition means `α(m)` divides `k`, the
second means `α(n)` divides `k`. A number divisible by both `α(m)` and
`α(n)` is precisely a number divisible by their least common multiple.
So the set of positions where `m·n` appears is the ladder of multiples of
`lcm(α(m), α(n))` — which means that least common multiple *is* the rank
`α(m·n)`. The proof is short, but it ties together three ideas — the law
of apparition, the Chinese Remainder Theorem, and the lcm — into a single
elegant knot.

## Where the clockwork jams: the coprime caveat

A good theorem is sharpened by knowing exactly when it fails. The
coprimality condition is not decoration — it is essential. The simplest
possible violation makes the point vividly. Take `m = n = 2`, which are
emphatically *not* coprime. The formula would predict

`α(4) = lcm(α(2), α(2)) = lcm(3, 3) = 3`.

But we computed earlier that `α(4) = 6`, not 3! The fourth Fibonacci
number is 3, the fifth is 5 — neither divisible by 4 — and only at the
sixth, which is 8, does a multiple of 4 first appear. The naive formula
is off by a factor of exactly 2.

That factor of 2 is not noise; it is a fingerprint. It is the signature of
what number theorists call **Wall's phenomenon**: the subtle extra
"delay" that occurs when a prime appears to a higher power. The lcm
formula is blind to it. This single example reveals the deep architecture
of the whole subject: the theory of the rank of apparition splits cleanly
into two halves.

1. **The coprime half**, governed by the Chinese Remainder Theorem, is
   now *completely understood*. To find the rank of any modulus, factor it
   into prime powers and take the least common multiple of their ranks.
2. **The prime-power half** — understanding `α(p)`, `α(p²)`, `α(p³)`, ...
   for a single prime `p` — is genuinely hard and brushes up against
   famous open problems.

## The functorial backbone

What makes the coprime story click into place is a humble but powerful
supporting fact, a kind of "monotonicity" of the heartbeat:

> **Divisibility Monotonicity.** If `a` divides `b`, then `α(a)` divides
> `α(b)`.

This says the rank of apparition is *order-preserving* with respect to
divisibility: coarser moduli have ranks that divide the ranks of finer
ones. It is the structural glue that lets local data about prime-power
factors be assembled into global statements. From it flow two clean
companion facts, free of charge: the rank of a greatest common divisor
divides the gcd of the ranks, and the lcm of two ranks divides the rank
of the lcm of the moduli. The heartbeat function behaves like a
well-mannered map between two lattices of divisibility — almost a perfect
algebraic morphism, defected only by the prime-power delay.

## The frontier: prime powers and a million-dollar-flavored mystery

The coprime theorem reduces *everything* to the prime-power tower. What
happens as we climb it? We know one rung for certain:

> **The prime-power tower starts climbing.** For a prime `p`, the rank
> `α(p)` divides `α(p²)`.

The conjecture — strongly believed, abundantly verified, but tied to deep
unsolved questions — is that each step up the tower either *stays put* or
*multiplies the rank by `p`*. The case where it stays put on the very
first step (`α(p²) = α(p)`) defines a **Wall–Sun–Sun prime**, an object
so elusive that none has ever been found, despite searches past `2^64`.
Whether any exist at all is a celebrated open problem with surprising
links to Fermat's Last Theorem. So the innocent question we started with —
*which Fibonacci numbers are multiples of a given number?* — leads, after
just a few honest steps, straight to the edge of the known mathematical
universe.

## Why it matters beyond Fibonacci

This is not a quirk of one sequence. The Fibonacci numbers are the most
famous member of a vast family of **Lucas sequences** — including the
Pell numbers, the Mersenne numbers, and many others — built from the same
kind of two-term recurrence. The entire argument above used only two
ingredients: the law of apparition and the gcd identity. Both hold,
suitably stated, for every well-behaved Lucas sequence. So the coprime
multiplicativity theorem is really a *template*: one proof that, once
written abstractly, covers Fibonacci, Pell, Mersenne, and Lucas numbers
all at once.

These ranks of apparition are also the workhorses behind primality
testing and the study of *primitive prime divisors* — primes that appear
in a sequence for the very first time at a given index. Carmichael's
celebrated theorem, that every Fibonacci number beyond the twelfth has a
brand-new prime factor never seen earlier, is most naturally phrased in
exactly this language: a prime `p` is a primitive divisor of `F(n)`
precisely when `α(p) = n`. The rank of apparition is the lens that brings
the whole landscape into focus.

## The takeaway

From a child's question — *when does a Fibonacci number land on a
multiple of seven?* — we have uncovered a hidden clock. Every modulus has
a heartbeat, its rank of apparition, that exists for all moduli and
dictates exactly where it appears. For coprime moduli, those heartbeats
combine by the simplest rule imaginable: take their least common
multiple. The single place the rule breaks — repeated prime factors —
turns out to mark the boundary between the fully understood and the deeply
mysterious. That is mathematics at its most satisfying: a clean answer
that, in the very act of being clean, points unmistakably at the next
great unknown.
