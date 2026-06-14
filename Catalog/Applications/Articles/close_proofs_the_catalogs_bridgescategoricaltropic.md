# The Hidden Clockwork of the Fibonacci Numbers

## A question a child could ask

Here are the first Fibonacci numbers, the sequence where each term is the sum of the two before it:

```
F:  0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, ...
n:  0  1  2  3  4  5  6   7   8   9  10  11   12   13   14   15   16
```

Pick a number — say 7. Now scan the list and ask: *which* Fibonacci numbers does 7 divide?

You will not have to scan very far. The eighth term, `F(8) = 21`, is the first one 7 goes into. Keep going and the next multiple of 7 is `F(16) = 987 = 7 × 141`. Then `F(24)`. Then `F(32)`. The multiples of 7 appear like clockwork at indices 8, 16, 24, 32, … — *exactly* the multiples of 8.

Try 11. Its first appearance is `F(10) = 55 = 11 × 5`. After that, 11 divides `F(20)`, `F(30)`, `F(40)`, and nothing in between. The multiples of 11 land precisely on the multiples of 10.

This is not a coincidence, and it is not special to 7 and 11. It is a law — one of the oldest and most beautiful facts in number theory, sometimes called the **law of apparition**. Every whole number `m` has a special index, its **rank of apparition** `z(m)`: the first place it shows up as a divisor in the Fibonacci sequence. And once you know that one index, you know *all* of them, because:

> **`m` divides the `n`-th Fibonacci number if and only if `z(m)` divides `n`.**

In symbols, writing `F(n)` for the `n`-th Fibonacci number:

$$ m \mid F(n) \iff z(m) \mid n. $$

For 7 the rank is `z(7) = 8`; for 11 it is `z(11) = 10`; for 2 it is `z(2) = 3` (the first even Fibonacci number is `F(3) = 2`); for 5 it is `z(5) = 5` itself. The whole infinite tapestry of "which Fibonacci numbers are divisible by `m`" collapses into a single number.

This article is about that law — why it is true, why it is best understood as a kind of *translation device*, and how it secretly connects the Fibonacci numbers to ideas as modern as tropical geometry and the *p*-adic numbers used in cryptography and arithmetic geometry.

## Divisibility of values, divisibility of indices

The slogan worth carrying away is this:

> **The law of apparition trades a hard question about Fibonacci *values* for an easy question about *indices*.**

"Does 144 divide `F(1000)`?" sounds like it requires you to compute `F(1000)`, a 209-digit monster. But you don't need the monster. You only need to know that `z(144) = 12`, and then the answer is just: *does 12 divide 1000?* It does not (1000 = 83 × 12 + 4), so 144 does **not** divide `F(1000)`. A question about an astronomically large number became a one-line division problem.

This translation is a genuine *duality*. On one side sits the messy world of Fibonacci numbers and what divides them. On the other side sits the clean world of ordinary divisibility among the indices `1, 2, 3, …`. The rank-of-apparition map `m ↦ z(m)` is the dictionary between the two worlds, and the law of apparition says the dictionary is perfect — no information is lost in translation.

There is a companion identity that makes the same point from a different angle. The Fibonacci numbers satisfy what is called a **strong divisibility law**:

$$ \gcd\big(F(m),\, F(n)\big) = F\big(\gcd(m,n)\big). $$

In words: the greatest common divisor of two Fibonacci numbers is itself a Fibonacci number — the one whose index is the gcd of the two original indices. For example `gcd(F(12), F(18)) = gcd(144, 2584) = 8 = F(6) = F(gcd(12,18))`. The law of apparition is the "index-side dual" of this identity: where the strong divisibility law moves a gcd *inside* the Fibonacci function, the law of apparition moves divisibility *out* to the indices.

## Why is it true? A finite machine that must repeat

The most striking thing about the law of apparition is how little machinery it actually needs. You might expect to need the famous closed-form (Binet's formula, with its golden ratio and square roots), or some delicate analysis. You need none of it. You need one idea: **a machine with finitely many states must eventually repeat.**

Here is the machine. To generate Fibonacci numbers you only ever need to remember the *last two*. So define the **state** at step `n` to be the pair

$$ S(n) = \big(F(n),\ F(n+1)\big). $$

The rule for advancing is just the Fibonacci rule itself, written as a transformation of pairs:

$$ T(a, b) = (b,\ a + b). $$

Apply `T` to `(F(n), F(n+1))` and you get `(F(n+1), F(n+2))` — the next state. The whole sequence is one transformation applied over and over, starting from `S(0) = (0, 1)`.

Now do everything **modulo `m`** — that is, only keep track of remainders after dividing by `m`. Then each coordinate of the state is one of the `m` possible remainders `0, 1, …, m−1`, so there are only `m × m` possible states in total. A *finite* number of states.

Watch the state evolve. It marches `S(0), S(1), S(2), …`, forever, through a set with only finitely many rooms. By the pigeonhole principle it *must* revisit a room: there are indices `i < j` with `S(i) = S(j)` modulo `m`.

The final ingredient is that the transformation `T` is **reversible** — it is a bijection of the finite set of states. (Knowing `(b, a+b)` you can recover `(a, b)`: the first coordinate is `b`, and `a = (a+b) − b`. That subtraction is exactly the cancellation law `add_right_cancel` in the formal proof.) A reversible machine on a finite set has no "merging" paths and no tails: every orbit is a clean loop. So if the state at step `i` equals the state at step `j`, you can "rewind" both by `i` steps and conclude that the state at step `0` equals the state at step `j − i`. That is:

$$ S(0) = S(d) \pmod m, \qquad d = j - i > 0. $$

But `S(0) = (0, 1)`. So `S(d) = (0, 1)` modulo `m` too — and the very first coordinate of that equation says `F(d) ≡ 0 \pmod m`, i.e. **`m` divides `F(d)`** for some positive `d`. The rank of apparition exists.

That's the whole existence proof: a finite reversible machine returns to its starting room, and the starting room has a `0` in the Fibonacci slot. No golden ratio required.

Once existence is in hand, the rank `z(m)` is simply the *smallest* such positive `d`, and the full law of apparition `m \mid F(n) \iff z(m) \mid n` follows by combining this minimality with the strong divisibility identity `F(\gcd(m,n)) = \gcd(F(m), F(n))`. If `m` divides both `F(n)` and `F(z(m))`, it divides `F(\gcd(n, z(m)))`; minimality then forces `\gcd(n, z(m)) = z(m)`, which is exactly `z(m) \mid n`. The reverse direction is the easy half: if `z(m) \mid n` then `F(z(m)) \mid F(n)`, and `m \mid F(z(m))`, so `m \mid F(n)`.

## The rank map is a "tropical" homomorphism

Now we get to the part that connects this ancient observation to strikingly modern mathematics.

Look again at the dictionary `m ↦ z(m)`. How does it behave when we combine moduli? Suppose we want a Fibonacci number divisible by *both* `a` and `b`. That means divisible by their least common multiple, `lcm(a, b)`. The rank map handles this perfectly:

$$ z\big(\operatorname{lcm}(a, b)\big) = \operatorname{lcm}\big(z(a),\, z(b)\big). $$

This is the **join law**, and it is exact: the rank of the lcm is the lcm of the ranks. For instance, `z(4) = 6` and `z(6) = 12`; their lcm is 12, and indeed `z(lcm(4,6)) = z(12) = 12 = lcm(6, 12)`. The map respects "least common multiple" on the nose. (Earlier work in this area only knew this when `a` and `b` shared no common factor; the version above holds for *all* positive `a, b`.)

But here is a delicious subtlety. The "dual" operation to lcm is gcd, the greatest common divisor — the *meet* rather than the *join*. Does the rank map respect gcd too? Almost, but not quite. We always have a one-way bound,

$$ z\big(\gcd(a, b)\big) \ \big|\ \gcd\big(z(a),\, z(b)\big), $$

and this bound is genuinely *strict* in general. The cleanest witness is again `a = 4`, `b = 6`. The gcd of 4 and 6 is 2, and `z(2) = 3`. But `gcd(z(4), z(6)) = gcd(6, 12) = 6`. And `3 ≠ 6` — indeed 3 divides 6, matching the bound, but the two sides do not agree. So the rank map is a **join-homomorphism but not a meet-homomorphism**. It is "half" a lattice map, and the join half is the sharp, beautiful one.

Why call any of this "tropical"? In **tropical mathematics** — a flourishing field with applications from optimization to algebraic geometry to the analysis of neural networks — one replaces ordinary addition and multiplication with the operations *minimum* and *plus* (the "min-plus" or tropical semiring). Lattice operations like gcd and lcm are exactly this kind of structure: gcd behaves like a "min" and lcm like a "max" on the divisibility ordering. The law of apparition says the rank map is a structure-preserving morphism between two such tropical worlds — and the asymmetry we just found (join exact, meet only a bound) is precisely the sort of one-sided inequality that pervades tropical geometry.

## From divisibility to *size*: the *p*-adic bridge

There is one more layer, and it is the deepest. It reinterprets "divisibility" as a notion of *distance* — and in doing so links the Fibonacci numbers to the *p*-adic numbers, the alternative number systems that underpin large swaths of modern number theory and some cryptographic constructions.

Fix a prime `p`. The *p*-adic way of measuring the "size" of an integer is upside-down from the usual one: a number is **small** when it is **highly divisible** by `p`. Formally, the *p*-adic absolute value `|x|_p` of a nonzero integer is `p^{-v}`, where `v` counts how many factors of `p` divide `x`. So a number divisible by `p` has *p*-adic size strictly less than 1, and the more times `p` divides it, the closer to 0 it sits.

Translate the law of apparition into this language and something elegant pops out. For a prime `p`,

$$ |F(n)|_p < 1 \iff p \mid F(n) \iff z(p) \mid n. $$

In plain terms: *the `p`-adic Fibonacci numbers get small exactly along the arithmetic progression `z(p), 2z(p), 3z(p), …`.* The combinatorial gadget `z(p)` — the rank of apparition — is the precise controller of when a Fibonacci number is *p*-adically small. The "non-archimedean size" of `F(n)` is governed entirely by a single counting number.

This connects to a sweeping theme: **arithmetic heights as tropical valuations.** A *valuation* is a function that measures *p*-divisibility, and the bridge between the multiplicative world of sizes and the additive world of valuations is the exponential. The exact identity is

$$ |q|_p = \exp\!\big(-v_p(q)\cdot \log p\big), $$

where `v_p(q)` is the *p*-adic valuation. The valuation `v_p` lives in the tropical (min-plus) world: it turns products into sums and satisfies the *strong triangle inequality* `v_p(x + y) \ge \min(v_p(x), v_p(y))`, the hallmark of an **ultrametric**. The map `t ↦ \exp(-t)` is the dictionary translating that tropical valuation into an honest distance. Under this dictionary the *p*-adic size *is* a tropical valuation in disguise — and the rank of apparition tells you exactly where, along the Fibonacci sequence, that valuation dips.

So the journey is complete. We started with a question a child could ask — *which Fibonacci numbers does 7 divide?* — and followed it down through a perfect duality between values and indices, through a finite reversible machine that must repeat, through a one-sided tropical homomorphism, and out the far side into the *p*-adic geometry where "divisible" means "small" and an ancient counting number quietly governs the size of numbers with hundreds of digits.

## Why it matters

The law of apparition is not a museum piece. The rank of apparition is the backbone of *primitive divisor* theory — the study, going back to Carmichael, of the prime factors that appear in a Fibonacci number *for the very first time*. A prime `p` is a primitive divisor of `F(n)` precisely when its rank of apparition equals `n` (`z(p) = n`), so the entire delicate theory of which Fibonacci numbers introduce brand-new prime factors reduces to statements about one arithmetic function. The same rank governs the Pisano periods (the cycle lengths of Fibonacci numbers modulo `m`) that show up in pseudorandom number generation, and it is a workhorse in primality testing built on Lucas sequences.

And the broader lesson — that a divisibility relation can be a *valuation*, that a valuation is a *tropical* object, and that the exponential translates between them — is exactly the kind of unifying bridge that lets a result about the most familiar sequence in mathematics speak the language of the most modern. The Fibonacci numbers, it turns out, keep a hidden clock; the rank of apparition is how you read it.
