# When a Number First Appears: The Hidden Clockwork of the Fibonacci Sequence

## A simple question with a surprising answer

Write down the Fibonacci numbers, the most famous sequence in mathematics:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, ...
```

Each one is the sum of the two before it. Now pick your favorite whole number — say
**7** — and ask an innocent question:

> *Which Fibonacci numbers are divisible by 7?*

Scan the list. The first multiple of 7 you meet is **21**, the eighth Fibonacci
number. Keep going and you find that the *next* multiple of 7 is **987** (the
sixteenth), then comes **46368** (the twenty-fourth), and so on. The pattern of
positions is unmistakable:

```
8, 16, 24, 32, 40, ...
```

Every eighth Fibonacci number, and *only* every eighth, is divisible by 7. Try the
number **11** instead and you discover that 11 divides exactly the Fibonacci numbers
in positions 10, 20, 30, 40, … . Try **13**: the magic positions are 7, 14, 21,
28, … .

This is not a coincidence, and it is not special to 7, 11, or 13. It is a law — one of
the oldest and most elegant facts in number theory, the **Law of Apparition**. It says
that for *every* number `m`, there is a single special position, call it the **rank of
apparition** `R(m)`, such that

> **`m` divides the `n`-th Fibonacci number if and only if `R(m)` divides `n`.**

For 7 the rank is 8; for 11 it is 10; for 13 it is 7. Once you know that one number,
you know *everything* about where `m` shows up in the Fibonacci sequence. The
appearance of a divisor is governed by a clock that ticks once every `R(m)` steps.

This article is about that clock — why it must exist, what it secretly is, and how a
single idea ties together three seemingly unrelated corners of mathematics: the
combinatorics of repeating patterns, the *p*-adic "sizes" of numbers used in modern
number theory, and the min-plus arithmetic of tropical geometry.

## Why a clock must exist at all

The first miracle is that the rank of apparition exists in the first place. Why should
the multiples of `m` appear at perfectly regular intervals, rather than scattered
unpredictably?

The classical answer reaches for Binet's formula, the golden ratio, square roots of
five, and a fair amount of algebra. But there is a far cleaner reason, and it is the
heart of the formalized work behind this article. It rests on a single childlike
observation.

To compute Fibonacci numbers you only ever need to remember **two** of them at a time.
Hold the pair `(current, next)` in your hands. To take one step forward, replace it by
`(next, current + next)`. Starting from `(0, 1)`:

```
(0,1) → (1,1) → (1,2) → (2,3) → (3,5) → (5,8) → (8,13) → ...
```

Now do the whole thing **modulo `m`** — that is, only ever keep the remainders after
dividing by `m`. Because remainders mod `m` can only take `m` different values, a pair
of remainders can only take `m × m` different values. There are infinitely many steps
but only finitely many possible states, so **the sequence of pairs must eventually
repeat**. This is the pigeonhole principle in its purest form: infinitely many pigeons,
finitely many holes.

Here is the subtle part that makes everything work. The forward step
`T(a, b) = (b, a+b)` is *reversible*: from `(b, a+b)` you can recover `(a, b)` by
subtracting. A reversible process can't have a "lasso" shape where a tail leads into a
loop — every state has exactly one predecessor, so the orbit must be a *pure cycle*
that comes all the way back to where it started. Therefore the pair of remainders
returns to its starting value `(0, 1)`. And the moment the pair returns to `(0, 1)`,
the "current" Fibonacci value is back to `0` mod `m` — meaning we have found a positive
index `k` with `m` dividing the `k`-th Fibonacci number.

That is the entire existence proof: **a reversible walk on a finite set of states must
cycle, so a Fibonacci multiple of `m` must appear.** No golden ratio, no analysis —
just "finite" plus "reversible." In the formal development this reversibility is
captured by the single algebraic fact that you can *cancel* a common term from both
sides of an equation (`add_right_cancel`).

## From "a multiple appears" to "the multiples are a clock"

Existence is only half the story. The deeper claim is that the appearances are
*perfectly periodic* — governed by that single rank `R(m)`. This is where a second
classical jewel enters, the **strong divisibility** of the Fibonacci sequence:

> The greatest common divisor of two Fibonacci numbers is itself a Fibonacci number,
> indexed by the greatest common divisor of the positions:
> **`gcd(Fib(a), Fib(b)) = Fib(gcd(a, b))`.**

For example, `gcd(Fib(12), Fib(8)) = gcd(144, 21) = 3 = Fib(4) = Fib(gcd(12, 8))`. The
Fibonacci sequence translates the arithmetic of *positions* (their gcd) into the
arithmetic of *values* (their gcd), faithfully.

Combine this with the rank. Suppose `m` divides both `Fib(R(m))` and `Fib(n)`. Then `m`
divides their gcd, which is `Fib(gcd(R(m), n))`. So `gcd(R(m), n)` is *also* a position
where a multiple of `m` appears. But `R(m)` was defined to be the **smallest** such
position, and `gcd(R(m), n)` can't be larger than `R(m)`. The only way out is that
`gcd(R(m), n) = R(m)` — which is exactly the statement that **`R(m)` divides `n`**.

Run the argument backwards (using that `Fib(a)` divides `Fib(b)` whenever `a` divides
`b`) and you get the full equivalence: `m` divides `Fib(n)` *exactly when* `R(m)`
divides `n`. The clock is real, and its period is the rank of apparition.

What just happened is a genuine **duality**. A hard question about *divisibility of
values* — does this gigantic Fibonacci number have `m` as a factor? — has been
translated, with zero loss of information, into a trivial question about *divisibility
of indices*: is `n` a multiple of `R(m)`? The Fibonacci sequence acts as a perfect
dictionary between two worlds.

## The dictionary respects structure

A good dictionary doesn't just translate words; it translates grammar. The apparition
law does exactly this. Consider the operation of taking the greatest common divisor of
two positions. On the value side, divisibility by `m` of `Fib(gcd(a, b))` turns out to
be the same as divisibility of `Fib(a)` **and** `Fib(b)` simultaneously:

> **`m` divides `Fib(gcd(a, b))`   if and only if   `m` divides `Fib(a)` and `m`
> divides `Fib(b)`.**

In words: the `gcd` of indices is sent to logical **AND**. This is what mathematicians
call a *lattice homomorphism*, and it has a striking second face. In **tropical
mathematics** — an arithmetic where "addition" is replaced by "take the minimum" and
"multiplication" by ordinary "+" — the gcd of exponents behaves exactly like a
minimum operation. So the apparition law quietly says: *the minimum-like operation on
positions becomes a logical conjunction on divisibility.* The Fibonacci dictionary is
not just faithful; it is a homomorphism between a tropical (min-plus) structure and a
Boolean (and/or) one.

## The size of a number, seen through a *p*-adic lens

There is one more world this clock unlocks, and it is the one that makes the whole
story feel modern.

In everyday life, "how big is a number" means its distance from zero. But number
theorists have a completely different, equally rigorous notion of size, one tailored to
a chosen prime `p`. The **`p`-adic size** of an integer is *small* precisely when the
number is *highly divisible* by `p`. By this yardstick, 7, 49, and 343 are *tiny* from
the viewpoint of the prime 7, while a number not divisible by 7 has size exactly 1.
Formally, if `p` divides a number `v` to the power `k`, its `p`-adic size is `p^{-k}`,
so more factors of `p` mean a smaller size. This is the foundation of *p*-adic analysis
and shows up everywhere from Fermat's Last Theorem to modern cryptography.

The `p`-adic size is a so-called **ultrametric norm**: it satisfies an unusually strong
triangle inequality (`size(a+b) ≤ max(size(a), size(b))`) and it is the exponential of
an additive, tropical valuation — exactly the "size = `p` raised to minus a min-plus
quantity" picture. This is the bridge between classical heights and tropical geometry
that the broader project formalizes.

Now ask: *when is the `p`-adic size of a Fibonacci number strictly less than 1?*
Precisely when `p` divides it. And by the apparition law, that happens precisely when
`R(p)` divides the index. So we arrive at the article's capstone, proven rigorously:

> **The `p`-adic size of `Fib(n)` is less than 1 if and only if the rank of apparition
> `R(p)` divides `n`.**

The non-archimedean, ultrametric, *tropical* size of a Fibonacci number — an object
from the frontier of arithmetic geometry — is controlled exactly by a humble piece of
combinatorics: the period of a reversible clock on a finite grid of remainders. The
abstract notion of "arithmetic height as a tropical valuation" is here pinned down,
concretely and completely, on the most famous sequence in mathematics.

## A worked tour

Let's make all of this tangible with the prime `p = 7`, whose rank is `R(7) = 8`.

| `n` | `Fib(n)` | divisible by 7? | `7`-adic size | `8` divides `n`? |
|----:|---------:|:---------------:|:-------------:|:----------------:|
| 6   | 8        | no              | 1             | no               |
| 7   | 13       | no              | 1             | no               |
| 8   | 21       | **yes**         | **1/7**       | **yes**          |
| 9   | 34       | no              | 1             | no               |
| 16  | 987      | **yes**         | **1/7**       | **yes**          |
| 24  | 46368    | **yes**         | **1/7**       | **yes**          |

Every prediction lines up. The "yes" rows are exactly the multiples of 8, and at those
rows — and only those — the `7`-adic size dips below 1.

There is even a beautiful classical bound on how big the rank can be. The forward step
`T(a, b) = (b, a+b)` is exactly multiplication by the matrix `[[0,1],[1,1]]`, the
companion matrix of the golden ratio. Reading the clock as the order of this matrix
over the integers mod `p` gives the *Pisano-style* bound that `R(p)` divides
`p − (5 | p)`, where `(5 | p)` is `+1` or `−1` depending on whether 5 is a perfect
square modulo `p`. For `p = 7`, five is *not* a square mod 7, so the bound is
`7 − (−1) = 8` — and indeed `R(7) = 8`, hitting the bound exactly. For `p = 11`, five
*is* a square, the bound is `11 − 1 = 10`, and `R(11) = 10`. The clock can never tick
slower than this simple arithmetic predicts.

## Why this matters

It would be easy to dismiss this as a charming curiosity about a children's sequence.
That would be a mistake, for three reasons.

**First, it is a template.** The proof used almost nothing about Fibonacci specifically
— only that the sequence is a *strong divisibility sequence* (its gcd law) and that it
is nonzero past the start. Exactly the same clock exists for the sequences `q^n − 1`
(central to the theory of finite fields and cyclic groups), for general Lucas
sequences, and for elliptic divisibility sequences (which underpin elliptic-curve
cryptography). One abstract notion of "rank of apparition" governs them all.

**Second, it reframes a hard open problem.** A *primitive prime divisor* of `Fib(n)` is
a prime that divides `Fib(n)` but none of the earlier Fibonacci numbers. The apparition
law makes this notion crisp: a prime `p` is a primitive divisor of `Fib(n)` exactly
when `R(p) = n`. Carmichael's celebrated theorem — that almost every Fibonacci number
has a primitive prime divisor — becomes the single, sharply stated claim that the rank
function `R` hits every position past the twelfth. Recasting an analytic problem as a
combinatorial one is exactly how progress is made.

**Third, it is a bridge.** The result physically connects two research traditions that
usually never speak: the elementary, hands-on world of integer recurrences and the
sophisticated machinery of *p*-adic heights and tropical valuations. The same fact, the
rank of apparition, is simultaneously a statement about repeating remainders, about
gcd-to-AND homomorphisms, and about the non-archimedean size of numbers. When one idea
wears three costumes, mathematicians take notice — because the costume changes are
exactly where new theorems hide.

## The one-sentence summary

Behind the friendly face of the Fibonacci sequence runs a reversible clock on a finite
grid of remainders. That clock must cycle, and when it does, it dictates — with perfect
regularity and across three different mathematical languages — exactly when, and how
strongly, any number you choose first *appears*.
