# The Newcomers: How Every Fibonacci Number Brings a Prime That Has Never Appeared Before

## A sequence everyone knows, hiding a secret almost no one does

Start with two ones, and keep adding the last two numbers together. You get the
most famous sequence in mathematics:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, ...
```

These are the Fibonacci numbers, written `F(1), F(2), F(3), ...`. They appear in
sunflower spirals, pinecones, the breeding of idealized rabbits, the analysis of
algorithms, and the proportions admired by Renaissance painters. School children
meet them; number theorists never stop studying them.

Now look at the same list, but factor each number into primes:

```
F(1)  = 1
F(2)  = 1
F(3)  = 2          = 2
F(4)  = 3          = 3
F(5)  = 5          = 5
F(6)  = 8          = 2^3
F(7)  = 13         = 13
F(8)  = 21         = 3 · 7
F(9)  = 34         = 2 · 17
F(10) = 55         = 5 · 11
F(11) = 89         = 89
F(12) = 144        = 2^4 · 3^2
F(13) = 233        = 233
```

Run your eye down the right-hand column and watch for **the first time each prime
ever appears**. The prime `2` makes its debut at `F(3)`. The prime `3` debuts at
`F(4)`. Then `5` at `F(5)`, `13` at `F(7)`, `7` at `F(8)`, `17` at `F(9)`,
`11` at `F(10)`, `89` at `F(11)`, `233` at `F(13)`.

Here is the striking pattern. Almost every Fibonacci number, when you factor it,
contains **at least one brand-new prime** — a prime that has never divided any
earlier Fibonacci number. Mathematicians call such a prime a **primitive prime
divisor**. It is a prime that is making its first-ever appearance in the
sequence, and it is "born" exactly at that Fibonacci number.

`F(8) = 21 = 3 · 7`. The `3` is old news — it already showed up in `F(4) = 3`.
But the `7` is new: no earlier Fibonacci number is divisible by `7`. So `7` is the
primitive prime divisor of `F(8)`. Every Fibonacci number seems to host such a
newcomer.

Almost every one. There are a precious few exceptions.

## The four numbers that break the rule

Look very carefully and you will find that not every Fibonacci number brings a
newcomer. There are exactly four exceptions:

- `F(1) = 1` — has no prime factors at all.
- `F(2) = 1` — same.
- `F(6) = 8 = 2^3` — its only prime is `2`, which already appeared at `F(3)`.
- `F(12) = 144 = 2^4 · 3^2` — its only primes are `2` and `3`, both already
  seen at `F(3)` and `F(4)`.

`F(6)` and `F(12)` are the interesting failures. They are genuine Fibonacci
numbers, larger than `1`, yet every single prime in their factorization is a
recycled veteran. No newcomer is born.

In 1913 the American mathematician Robert Daniel Carmichael proved a beautiful
and exact theorem: **these four are the only exceptions, ever.**

> **Carmichael's Theorem (1913).** For every index `n` outside the set
> `{1, 2, 6, 12}`, the Fibonacci number `F(n)` has a primitive prime divisor —
> a prime dividing `F(n)` but dividing no earlier Fibonacci number.

In other words, from `F(13) = 233` onward, *every* Fibonacci number, forever,
introduces a prime to the world that the sequence has never used before. The
threshold `13` is sharp: it is the smallest index past which the rule never fails
again.

This article is about that theorem, why it is true, and a modern twist: a
**completely rigorous, exhaustively certified proof** of the statement across a
vast range of cases, built from two clean ideas that anyone can follow.

## Two kinds of Fibonacci number, two kinds of proof

The secret to attacking Carmichael's theorem is to notice that the index `n` —
the *position* in the sequence, not the value — comes in two flavors, and they
behave completely differently.

- When `n` is a **prime number** (like `7`, `11`, `13`, `17`), the argument is
  short, clean, and works for all primes at once with no computation.
- When `n` is **composite** (like `8 = 2·4`, `12 = 3·4`, `15 = 3·5`), the
  argument is subtler, because composite indices can inherit primes from several
  smaller Fibonacci numbers, and the inheritance is irregular.

The proof we describe handles the prime case with a single elegant idea and the
composite case with a verified algorithm. Let us take them in turn.

## The master key: a divisibility law that mirrors arithmetic

Everything rests on one remarkable property of the Fibonacci sequence, a fact so
clean it feels like magic the first time you see it:

> **The GCD law.** The greatest common divisor of two Fibonacci numbers is itself
> a Fibonacci number — specifically,
> `gcd(F(m), F(n)) = F(gcd(m, n))`.

Read that again. The operation "greatest common divisor" on the *values* `F(m)`
and `F(n)` corresponds *exactly* to "greatest common divisor" on the *indices*
`m` and `n`. The Fibonacci map carries the arithmetic of the indices faithfully
into the arithmetic of the values.

For example, `gcd(F(12), F(8)) = gcd(144, 21) = 3`, and indeed
`F(gcd(12,8)) = F(4) = 3`. The indices share the factor `4`; so the values share
exactly `F(4)`.

From the GCD law one squeezes out the single tool that drives the whole proof:

> **Strong divisibility.** If a prime `p` divides both `F(n)` and `F(k)`, then `p`
> divides `F(gcd(n,k))`.

Why? If `p` divides `F(n)` and `p` divides `F(k)`, then `p` divides their gcd,
which is `gcd(F(n), F(k)) = F(gcd(n,k))`. A prime that haunts two Fibonacci
numbers must already haunt the Fibonacci number sitting at the gcd of their
indices. This one sentence is the engine of everything that follows.

## The prime case: a one-paragraph miracle

Suppose `n` is a prime number, at least `3` — say `n = 13`. Take *any* prime `p`
that divides `F(13) = 233`. (Here `233` is itself prime, but the argument never
needs that.) We claim `p` is automatically a newcomer: it divides no earlier
Fibonacci number at all.

Suppose, for contradiction, that `p` also divided some earlier `F(k)` with
`0 < k < 13`. By strong divisibility, `p` would then divide `F(gcd(13, k))`. But
`13` is prime, so `gcd(13, k)` is either `13` or `1`. Since `k < 13`, the gcd
cannot be `13`; it must be `1`. Hence `p` divides `F(1) = 1`.

But no prime divides `1`. Contradiction. So `p` divides no earlier Fibonacci
number, and `p` is a primitive prime divisor.

That is the entire argument. It proves something even stronger than Carmichael
asked for at prime indices: **when `n` is prime, every single prime factor of
`F(n)` is a newcomer.** No exceptions, no computation, no special cases — just the
GCD law and the fact that `F(1) = 1`. (One only needs `F(n) > 1` so that `F(n)`
has a prime factor to begin with, which holds for all `n ≥ 3`.)

This clean half of the theorem is captured in a single precise statement:

> **Prime-index Carmichael (verified).** For every prime `n ≥ 3` there exists a
> prime `p` with `p ∣ F(n)` and `p ∤ F(k)` for all `0 < k < n`.

## The composite case: stripping away the veterans

Composite indices are harder, and you can feel why by looking at `F(12) = 144`.
Its index `12` has many proper divisors — `1, 2, 3, 4, 6` — and each contributes
its own primes: `F(2)=1`, `F(3)=2`, `F(4)=3`, `F(6)=8`. By the time you reach
`F(12)`, the primes `2` and `3` have all been claimed, and `144 = 2^4·3^2` has
nothing left to offer. That is precisely why `12` is an exception.

So for a composite index we need to *measure* how much of `F(n)` is genuinely new.
The idea is delightfully concrete. Start with the value `F(n)`. Then, for every
proper divisor `d` of `n`, repeatedly divide out any common factor with `F(d)`,
peeling away the inherited primes one layer at a time. What survives is the
**primitive part** of `F(n)`: the portion built entirely from newcomers.

The peeling is done by a tiny, transparent routine. To strip all factors that a
running residue `r` shares with a number `m`:

1. Compute `g = gcd(r, m)`.
2. If `g = 1`, stop — `r` shares nothing with `m`.
3. Otherwise replace `r` by `r / g` and repeat.

Applying this for every proper divisor's Fibonacci number leaves the primitive
part, call it `primPart(n)`. Two facts make it a valid certificate:

- **It really divides `F(n)`.** Every step only divides the residue, so the final
  result is a genuine divisor of the original `F(n)`.
- **It is coprime to every inherited Fibonacci number.** By construction, the
  surviving part shares no prime with any `F(d)` for a proper divisor `d` of `n`.

Here is the punchline. Suppose the primitive part exceeds `1`. Then it has a
smallest prime factor `p`. This `p` divides `F(n)` (because the primitive part
does), and `p` divides no `F(d)` for any proper divisor `d` of `n` (because the
primitive part is coprime to all of them). And now the GCD law finishes the job:
any earlier index `k < n` with `p ∣ F(k)` would force `p ∣ F(gcd(n,k))`, where
`gcd(n,k)` is a *proper divisor* of `n` — contradicting coprimality. So `p`
divides no earlier Fibonacci number at all. It is a newcomer.

In short:

> **Primitive-part certificate (verified).** For `n ≥ 3`, if `primPart(n) > 1`,
> then `F(n)` has a primitive prime divisor — namely the smallest prime factor of
> `primPart(n)`.

The exceptional indices are exactly the ones where this certificate vanishes:
`primPart(6) = 1` and `primPart(12) = 1`, because their Fibonacci numbers are
built entirely from recycled primes.

## Letting the computer certify the rest

For the prime case we have a complete, computation-free proof. For composite
indices, all that remains is to confirm `primPart(n) > 1` whenever `n` is
composite and at least `13`. This is a finite check per number, and a computer can
do it at blistering speed.

The verified theorem states it crisply:

> **Range certificate (verified by exhaustive computation).** For every `n` with
> `13 ≤ n ≤ 10000`, either `n` is prime, or `primPart(n) > 1`.

Combine the three pieces — the prime-index miracle, the primitive-part
certificate, and the exhaustive range check — and you obtain a fully rigorous,
exhaustively certified proof of Carmichael's theorem for **every index from `13`
to `10000`**:

> **Main result (verified).** For every `n` with `13 ≤ n ≤ 10000`, the Fibonacci
> number `F(n)` has a primitive prime divisor.

What makes this special is not that Carmichael's theorem is in doubt — it has been
known for over a century — but that the *entire chain of reasoning*, from the GCD
law through the stripping algorithm to the ten-thousand-case computation, has been
driven down to a standard of certainty that leaves no gaps. Every divisibility
step, every edge case, and every line of the ten-thousand-case computation is
pinned down completely and checked without exception.

## Why stop at ten thousand?

The honest answer is that the composite case beyond a computed range is the deep
heart of Carmichael's theorem, and it cannot be brute-forced forever. To climb
past any finite ceiling you need an *analytic* lever, and the classical one has a
wonderful name: **Lifting the Exponent**.

The phenomenon it captures is this. Each prime `p` has a Fibonacci "entry point"
`z(p)`: the smallest index at which `p` first appears. (For `p = 7`, the entry
point is `8`, because `F(8) = 21` is the first multiple of `7`.) After that, `p`
divides `F(n)` exactly when `z(p)` divides `n`. The Lifting-the-Exponent law says,
precisely, how the *power* of `p` in `F(n)` grows: for an odd prime with entry
point `m`,

```
(power of p in F(mk)) = (power of p in F(m)) + (power of p in k).
```

This formula pins down exactly how much of a large Fibonacci number is "old," and
because Fibonacci numbers grow exponentially — roughly like the golden ratio
raised to the `n` — the old part can never keep up. Past a modest threshold there
is always room left over for a newcomer. Turning that growth race into a finished
rigorous proof is the natural next chapter, and the groundwork here — the
GCD law, the entry-point picture, the primitive-part certificate — is exactly the
scaffolding such a proof would stand on.

## The bigger picture: newcomers everywhere

Carmichael's theorem is one bright instance of a sweeping principle in number
theory. Sequences that grow by a fixed recurrence — Fibonacci numbers, Lucas
numbers, the numbers `2^n - 1` and `a^n - b^n` — tend to keep introducing fresh
primes. The grand generalization, the **Bilu–Hanrot–Voutier theorem** of 2001,
shows that *every* Lucas and Lehmer sequence has a primitive prime divisor for all
sufficiently large indices, with the finite list of exceptions completely
classified. Carmichael's Fibonacci result, proved nearly a century earlier, is the
gateway example: simple enough to state to a curious teenager, deep enough to
anchor a whole theory.

And there is something quietly moving about the statement itself. The Fibonacci
sequence is one of the most studied objects in all of mathematics, computed and
recomputed for centuries. Yet it never exhausts itself. Past its twelfth term it
never repeats its prime palette; every new value, forever, contributes a prime
that the world of Fibonacci numbers has never seen. An old, familiar sequence that
is nonetheless infinitely, reliably new — that is the small miracle Carmichael
discovered, and that modern rigorous methods now certify, step by careful step.
