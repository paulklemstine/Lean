# The Hidden Lattice Inside the Fibonacci Numbers

## A puzzle about when one Fibonacci number divides another

Write out the Fibonacci numbers, the sequence everyone meets in school:

```
F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8, F(7)=13, F(8)=21, F(9)=34, F(10)=55, F(11)=89, F(12)=144, ...
```

Now ask a simple question: **when does one Fibonacci number divide another?** Take
`F(4) = 3`. It divides `F(8) = 21`, `F(12) = 144`, `F(16) = 987`, and so on — exactly the
Fibonacci numbers whose index is a multiple of 4. Take `F(6) = 8`. It divides `F(12) = 144`,
`F(18) = 2584`, ... — exactly the indices that are multiples of 6.

A pattern leaps out. A Fibonacci number `F(a)` divides `F(b)` precisely when the *index* `a`
divides the *index* `b`. This is a small miracle: a fact about the values of a complicated,
exponentially growing sequence becomes a fact about the humble divisibility of their indices.

This article is about a single, clean structural law that explains this miracle — and then,
astonishingly, explains the very same phenomenon for a sequence that looks nothing like
Fibonacci: the numbers `2^n - 1`, `3^n - 1`, `10^n - 1`, and their cousins. The punchline is
that both sequences carry a hidden **lattice**, and a certain natural map between lattices
preserves one of its two operations exactly. Let us build up to it.

## The rank of apparition

Fix a number `m`, say `m = 7`. Scan the Fibonacci numbers until `7` first divides one of
them:

```
F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8, F(7)=13, F(8)=21
```

There it is: `7 | F(8) = 21`. The number `8` is called the **rank of apparition** of `7` — the
index at which `7` first "appears" as a divisor in the Fibonacci sequence. Some call it the
*Fibonacci entry point*. We write `rank(7) = 8`.

Three facts about the rank make it powerful:

1. **It always exists.** No matter which `m ≥ 1` you choose, some Fibonacci number is divisible
   by it. This is not obvious — it is a pigeonhole argument in disguise. Look at consecutive
   Fibonacci pairs `(F(k), F(k+1))` reduced modulo `m`. There are only `m²` possible pairs, so
   eventually a pair repeats. Because the Fibonacci rule `(a, b) ↦ (b, a+b)` is *reversible*
   (you can recover `a` from `b` and `a+b`), a repeat forces the pattern back to `(0, 1)`,
   which is exactly the pair `(F(0), F(1))`. The gap is an index `k > 0` with `m | F(k)`. (The
   reversibility is the abstract heart of the famous *Pisano period*.)

2. **It is the master key.** Everything about divisibility in the Fibonacci sequence collapses
   into one biconditional, which we call the **spine**:

   > **The Spine.** For any `m ≥ 1` and any index `n`:
   > `m | F(n)` **if and only if** `rank(m) | n`.

   In words: `m` divides the `n`-th Fibonacci number exactly when its rank divides `n`. So once
   you know the single number `rank(m)`, you know *every* Fibonacci number that `m` divides —
   they are precisely `F(rank(m)), F(2·rank(m)), F(3·rank(m)), ...`. The seemingly random
   appearances of `7` as a divisor are perfectly periodic, with period `rank(7) = 8`.

3. **It pins the Fibonacci numbers to their own indices.** For `k ≥ 3`, the rank of `F(k)` is
   `k` itself: `rank(F(k)) = k`. (For example `rank(F(8)) = rank(21) = 8`, since `21 = 3·7` and
   the first Fibonacci number divisible by `21` is `F(8)`.) Combine this with the spine and the
   schoolroom miracle falls out instantly: for `a ≥ 3`,
   `F(a) | F(b)` ⇔ `rank(F(a)) | b` ⇔ `a | b`.

The spine is the whole game. It translates statements about gigantic Fibonacci values into
statements about tiny indices.

## The same skeleton lives elsewhere

Here is where the story turns. The proof of the spine never used anything specifically
"Fibonacci." It used one property:

> **Strong divisibility.** A sequence `u(1), u(2), u(3), ...` is a *strong divisibility
> sequence* if, for all `m, n`,
> `u(gcd(m, n)) = gcd(u(m), u(n))`.

The greatest common divisor of two values is the value at the greatest common divisor of the
indices. The Fibonacci sequence satisfies this (`gcd(F(m), F(n)) = F(gcd(m, n))`, a classical
theorem). But so does another, utterly different-looking sequence:

> **The Mersenne-type sequence.** Fix `a ≥ 2` and set `u(n) = aⁿ − 1`. Then
> `gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`.

For `a = 2` this is `1, 3, 7, 15, 31, 63, 127, ...` — the Mersenne numbers. They grow
exponentially, they have no recurrence relation resembling Fibonacci's, and yet they obey the
identical gcd law.

Because the spine only needs strong divisibility, it holds verbatim for these sequences too.
Define the rank of `m` in `u` as the least positive `k` with `m | u(k)`. Then `m | u(n)` iff
`rank(m) | n`. For the Mersenne sequence this recovers another classical gem:
`(aᵐ − 1) | (aⁿ − 1)` iff `m | n`. The familiar fact that `2^m − 1` divides `2^n − 1` exactly
when `m | n` is the *same theorem* as the Fibonacci divisibility miracle, wearing a different
costume.

## The missing law: how ranks meet the lcm

Everything above was already understood. The rank was known to be **monotone**: if `b` divides
`a`, then `rank(b)` divides `rank(a)`. In the language of order theory, `rank` respects the
divisibility ordering. But monotonicity is a soft statement. The sharper question — the one
this work answers — is structural:

> **How does the rank interact with combining two moduli?**

The natural way to combine two numbers `a` and `b` in the world of divisibility is the **least
common multiple**, `lcm(a, b)` — the smallest number that both divide. The lcm is the *join* in
the lattice of natural numbers ordered by divisibility. Its partner, the *meet*, is the gcd.

The central new result is that **the rank preserves joins exactly**:

> **The Join Law.** For any strong divisibility sequence `u`, and any `a, b` that have ranks,
> `rank(lcm(a, b)) = lcm(rank(a), rank(b))`.

The rank of a least common multiple is the least common multiple of the ranks. This is not an
inequality, not a one-sided divisibility — it is an exact equation. In the language of abstract
algebra, **the rank of apparition is a homomorphism of join-semilattices**: it carries the
operation `lcm` on moduli to the operation `lcm` on ranks, faithfully.

Two beautiful consequences specialize the law to the two worlds:

- **Fibonacci.** `rank(lcm(a, b)) = lcm(rank(a), rank(b))`. The Fibonacci entry point of a
  least common multiple is the least common multiple of the entry points. For example,
  `rank(2) = 3` (the first Fibonacci number divisible by 2 is `F(3) = 2`) and `rank(3) = 4`
  (the first divisible by 3 is `F(4) = 3`), so `rank(lcm(2,3)) = rank(6) = lcm(3,4) = 12` — and
  indeed `F(12) = 144 = 6 · 24` is the first Fibonacci multiple of 6.

- **Mersenne.** In the sequence `aᵏ − 1`, the join law reads
  `rank(lcm(aᵐ − 1, aⁿ − 1)) = lcm(m, n)`. The same abstract identity, now a statement about
  exponential numbers.

There is even a clean corollary for *coprime* moduli, where the lcm is just the product:

> **Coprime entry-point law.** If `a` and `b` share no common factor, then
> `rank(a · b) = lcm(rank(a), rank(b))`.

## Why only the join — and never the meet

A natural reflex is to expect a symmetric "meet law": surely
`rank(gcd(a, b)) = gcd(rank(a), rank(b))`? It is false, and the failure is instructive.

Monotonicity guarantees only the one-sided divisibility
`gcd(rank(a), rank(b)) | rank(gcd(a, b))`,
and the reverse can break. A small Fibonacci experiment shows it: ranks do not turn gcd of
moduli into gcd of ranks. The deep reason is that `rank` behaves like a *lower adjoint* — the
kind of map that, by general nonsense, preserves joins but is free to distort meets. The join
side is rigid; the meet side is loose. This asymmetry is not a gap in our knowledge but a
genuine feature of the structure: the rank is a join-homomorphism, full stop, and *not* a
lattice isomorphism.

That clean dividing line — joins preserved exactly, meets only half-preserved — is the real
content. It tells you precisely how much of the arithmetic of moduli survives the passage to
their ranks.

## Why a working mathematician should care

Strung together, the picture is this. Two famous divisibility miracles — `F(a) | F(b) ⇔ a | b`
and `(2^a − 1) | (2^b − 1) ⇔ a | b` — are not coincidences and not even cousins. They are the
**same theorem**, instances of a single engine that runs on one hypothesis (strong
divisibility) and turns on one biconditional (the spine). The new join law completes the
structural portrait of that engine: the rank of apparition is not merely an order-preserving
map but a *semilattice homomorphism*, carrying least common multiples to least common multiples
on the nose, while honestly failing to do the same for greatest common divisors.

This is the lattice-theoretic core of what number theorists loosely call the "Law of
Apparition." It packages a swath of classical results — Fibonacci entry points, Mersenne
divisibility, primitive prime divisors — into one preserved operation, and it does so for every
strong divisibility sequence at once: Fibonacci, Mersenne, Lucas sequences, and beyond. When
you next see a sequence whose gcd law holds, you already know, for free, that its rank function
respects least common multiples. That is the kind of leverage a good structural theorem buys.

The hidden lattice was there all along, threaded invisibly through the Fibonacci numbers and
their exponential relatives. The join law is the thread pulled taut.
