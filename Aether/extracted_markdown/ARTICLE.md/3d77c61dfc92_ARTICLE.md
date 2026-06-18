# When a Permutation Decides Divisibility: The Hidden Clockwork of Fibonacci Numbers

## A puzzle hiding in plain sight

The Fibonacci numbers are the most famous sequence in mathematics. Start with
0 and 1, and keep adding the two most recent terms:

```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, ...
```

They appear in the spirals of sunflowers, the branching of trees, the breeding
of rabbits, and the keys of modern cryptography. But underneath their gentle
growth lies a surprisingly rigid arithmetic skeleton, and this article is about
one of its sharpest bones: the **rank of apparition**.

Pick any whole number — say, 7. Now ask a simple question: *which* Fibonacci
numbers does 7 divide? Run down the list and check:

```
F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8, F(7)=13, F(8)=21=7·3, ...
```

The first Fibonacci number that 7 divides is F(8) = 21. And here is the
remarkable part. Once 7 has "appeared" at position 8, it reappears like
clockwork at positions 16, 24, 32, 40, ... — at every multiple of 8, and at
*no other* position. Try it: F(16) = 987 = 7 · 141, F(24) = 46368 = 7 · 6624.
Never at position 9, 10, 11, ..., 15. Exactly the multiples of 8.

That first appearance, the number 8, is called the **rank of apparition** of 7.
The pattern we just observed is no accident — it is a precise law, and the goal
of this article is to explain why it holds, and how it turns the messy question
"which Fibonacci numbers does *m* divide?" into a piece of clean, predictable
machinery.

## The law of apparition

Let us write `rank(m)` for the rank of apparition of a number `m`: the smallest
positive index `k` such that `m` divides `F(k)`. The central theorem says:

> **The Law of Apparition.** For any `m > 0`,
> *`m` divides `F(n)` if and only if `rank(m)` divides `n`.*

In symbols: `m ∣ F(n)  ⇔  rank(m) ∣ n`.

This single statement is the whole story of *when* a number divides a Fibonacci
number. The "which positions?" question always has the same shape of answer:
the multiples of one special number. For 7, that number is 8. For 11, the rank
turns out to be 10 (F(10) = 55 = 11 · 5), so 11 divides exactly
F(10), F(20), F(30), .... For 2, the rank is 3 (F(3) = 2), so the even Fibonacci
numbers sit at positions 3, 6, 9, 12, ... — every third one, which you can
confirm by eye: 2, 8, 34, 144, ....

The law is a *dictionary*. On one side sits the world of **moduli** — the
numbers `m` we divide by — ordered by divisibility. On the other side sits the
world of **indices** — the positions `n` in the Fibonacci sequence — also
ordered by divisibility. The function `rank` translates faithfully between the
two. And like any good translation, it preserves structure, as we will see.

## Why does apparition happen at all?

Before celebrating the law, we should ask the more basic question: why is there
a first appearance at all? Why must *every* number `m` divide *some* Fibonacci
number? It is not obvious. Could there be a stubborn `m` that never shows up?

The answer is one of the most elegant arguments in elementary number theory,
and it has nothing to do with the size of Fibonacci numbers. It is about a
**permutation** — a reversible shuffle of a finite deck of cards.

Here is the idea. The Fibonacci rule "add the last two" can be repackaged as a
move on *pairs* of numbers. Think of the state of the sequence as a pair
`(a, b)` of consecutive terms. One step forward turns `(a, b)` into `(b, a + b)`:
the new "last two" are the old second term and their sum. Starting from the
seed `(0, 1)` and stepping repeatedly, you generate exactly the consecutive
Fibonacci pairs:

```
(0,1) → (1,1) → (1,2) → (2,3) → (3,5) → (5,8) → ...
```

Now work *modulo m* — that is, keep only the remainders after dividing by `m`.
There are only finitely many possible pairs of remainders: exactly `m²` of
them. So as we step forward forever through an infinite list of positions, but
land in a finite set of pairs, we must eventually repeat. That is the
**pigeonhole principle**: infinitely many pigeons, finitely many holes.

But repetition alone is not quite enough — we need the repeat to bring us back
to the *start*, the pair `(0, 1)`, because that is the pair sitting at position
0 (and the "0" in its first slot is what signals that `m` divides a Fibonacci
number). This is where reversibility enters. The forward move `(a, b) ↦ (b, a+b)`
has an exact inverse: `(a, b) ↦ (b − a, a)`. You can always undo a step, because
the previous term is "current sum minus current last," which is just the
Fibonacci recurrence read backwards: `F(k−1) = F(k+1) − F(k)`. A move that can
always be undone is a **permutation** of the finite set of pairs.

Permutations of a finite set have a wonderful property: they have finite
*order*. Repeat any reversible shuffle of a finite deck enough times and you
return precisely to where you began. So our Fibonacci step, applied to the seed
`(0, 1)`, must eventually cycle back to `(0, 1)`. At that returning moment, the
first coordinate is again 0 — meaning `m` divides that Fibonacci number. The
first such return is exactly the rank of apparition.

This is a beautiful inversion of expectations. One might guess that proving "`m`
always divides some Fibonacci number" requires *analysis* — estimating how big
Fibonacci numbers get, invoking growth rates and the golden ratio. It requires
none of that. It is pure, finite, structural reasoning: a reversible move on a
finite set must cycle. The size of the Fibonacci numbers is irrelevant; only
the *invertibility of the recurrence* matters. (Insiders will recognize this as
the abstract version of the **Pisano period**, the period with which Fibonacci
numbers repeat modulo `m`.)

## Primitivity: the first time is special

Some appearances are more special than others. Consider a prime `p` and the
Fibonacci number `F(n)`. We say `p` is a **primitive divisor** of `F(n)` if `p`
divides `F(n)` but divides *none* of the earlier Fibonacci numbers
`F(1), F(2), ..., F(n−1)`. In other words, `F(n)` is the *debut* of `p` — its
very first appearance.

There is a clean, almost tautological-looking bridge here, and it is the second
headline result:

> **The Primitivity Bridge.** For `m, n > 0`, the number `m` is a primitive
> divisor of `F(n)` *if and only if* `rank(m) = n`.

Read it slowly: "primitive divisor of `F(n)`" means "first appears at position
`n`," and `rank(m) = n` means "the first position where `m` appears is `n`."
Said that way it sounds obvious — but the power is in what it *replaces*. The
naive definition of primitivity is an **avoidance condition**: a statement about
*all* earlier indices simultaneously ("`m` divides none of `F(1)` through
`F(n−1)`"). The bridge collapses this infinite-looking checklist into a single
equation: `rank(m) = n`. A global property over many positions becomes one local
fact about one number.

Why does anyone care? Because primitive divisors are the engine behind a
celebrated theorem of R. D. Carmichael (1913): *almost every* Fibonacci number
has a primitive divisor — a brand-new prime that has never divided any earlier
Fibonacci number. (The handful of exceptions are tiny: F(1), F(2), F(6) = 8,
and F(12) = 144.) This means the Fibonacci sequence is a relentless *factory of
new primes*: as you march along it, fresh prime factors keep being born. The
primitivity bridge is exactly the tool that turns "show a new prime appears"
into "show some prime has rank exactly `n`," a far more tractable target.

## The translation respects structure

A dictionary is most useful when it preserves grammar, not just vocabulary. The
rank function does exactly this, and the way it does so is the heart of the
"local-to-global" theme.

Suppose `a` and `b` are **coprime** — they share no common factor (like 4 and
9, or 8 and 25). Then:

> **Gluing Law.** If `a` and `b` are coprime, then
> `rank(a·b) = lcm(rank(a), rank(b))`,
> the least common multiple of their individual ranks.

For example, take `a = 4` and `b = 9`. The rank of 4 is 6 (F(6) = 8 = 4·2, and
4 divides no earlier Fibonacci number). The rank of 9 is 12 (F(12) = 144 = 9·16).
The law predicts `rank(36) = lcm(6, 12) = 12`. And indeed, 36 first divides
F(12) = 144 = 36 · 4. The whole behavior of 36 is *assembled* from the behaviors
of its coprime pieces 4 and 9, glued by the least common multiple.

This is more than a computational convenience — it is a statement that `rank` is
a **join-morphism**: it carries the "join" operation (least common multiple) on
moduli to the join operation on indices. The dictionary preserves the lattice
grammar.

Push this idea to its limit and you reach the fourth and most powerful result.
Every number `n` factors uniquely into prime powers — for instance
`360 = 2³ · 3² · 5`. The prime powers are coprime to one another, so the gluing
law applies to all of them at once:

> **Local-to-Global Reconstruction.** For any `n`,
> `rank(n) = lcm over all primes p dividing n of rank(p^(v_p(n)))`,
> where `v_p(n)` is the exact power of `p` in `n`.

The grand `rank` of any number is *reconstructed* from the ranks of its
prime-power "stalks." To know how a complicated number `m` interacts with the
entire Fibonacci sequence, you need only understand each prime power inside it
separately, then take a least common multiple. The global truth is **glued from
local data** — which is precisely the structure mathematicians call a *sheaf*.
The divisibility relations among numbers play the role of an underlying space;
the rank of each prime power is the local data attached to a point; and the
gluing law guarantees these local pieces fit together into one coherent global
section.

## A worked example, end to end

Let us trace `m = 60` all the way through. Its prime factorization is
`60 = 2² · 3 · 5`.

- `rank(4) = 6`: the first Fibonacci number divisible by 4 is F(6) = 8.
- `rank(3) = 4`: F(4) = 3.
- `rank(5) = 5`: F(5) = 5.

Reconstruction gives `rank(60) = lcm(6, 4, 5) = 60`. So 60 first divides F(60),
and thereafter divides exactly F(60), F(120), F(180), .... We computed the rank
of a fairly large modulus without ever generating a single huge Fibonacci
number beyond the tiny ranks of its prime-power parts. That is the practical
payoff of the local-to-global viewpoint.

## Where the joints don't fit — and why that's interesting

The gluing law works perfectly for "join" (least common multiple). But what
about "meet" (greatest common divisor)? Here the dictionary develops a flaw.
While it is always true that `rank(gcd(a, b))` divides `gcd(rank(a), rank(b))`,
the two need not be equal. The classic witness is `a = 4`, `b = 6`: their gcd is
2, with `rank(2) = 3`, but `gcd(rank(4), rank(6)) = gcd(6, 12) = 6`, and 3 is a
*strict* divisor of 6.

This asymmetry — perfect for joins, leaky for meets — is not a defect to be
swept away but a genuine invariant to be measured. The ratio between the two
sides is a kind of *obstruction*, a local defect that detects when the rank
function fails to be a perfect lattice homomorphism. Understanding exactly when
and how much it leaks is one of the open research threads this work opens.

## The bigger picture

What began as a parlor trick — "7 divides exactly every eighth Fibonacci
number" — has unfolded into a small, complete theory with four interlocking
theorems:

1. **The law of apparition** turns divisibility into a clean "rank divides
   index" condition.
2. **The primitivity bridge** identifies first appearances with rank equality,
   linking the local rank to Carmichael's grand theorem on the birth of new
   primes.
3. **The gluing law** shows the rank respects coprime products via least common
   multiples.
4. **The reconstruction theorem** assembles every rank from its prime-power
   stalks.

The unifying lesson is one of the deepest in modern mathematics: **local data,
correctly glued, determines global structure.** Knowing how each prime power
behaves tells you how every number behaves. And the engine that makes the whole
thing run is not heavy analytic machinery but a single, almost childlike
observation — that adding the last two numbers is a *reversible* move, and a
reversible move on a finite set must, eventually, come home.

The next time you see the Fibonacci numbers spiraling through a pinecone,
remember that hidden inside their gentle growth is a perfectly tuned clock,
ticking out divisibility with the precision of a permutation cycling back to its
start.
