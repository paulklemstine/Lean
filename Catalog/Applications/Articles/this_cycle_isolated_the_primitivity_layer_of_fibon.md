# The Sequence That Remembers Its Factors

## One law to rule the Fibonacci numbers

Take the most famous sequence in mathematics — the Fibonacci numbers, where
each term is the sum of the two before it:

```
1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, ...
```

Pick a number, say the third Fibonacci number, **2**. Now scan down the list
and circle every Fibonacci number that 2 divides: 2, 8, 34, 144, 610, ...
These sit at positions 3, 6, 9, 12, 15 — exactly the multiples of 3. Try the
number **5**, which is the fifth Fibonacci number. The Fibonacci numbers it
divides — 5, 55, 610, ... — sit at positions 5, 10, 15, ..., the multiples
of 5. The pattern is uncanny and exact: *each Fibonacci number announces, by
its own position, precisely which later Fibonacci numbers it will divide.*

This is not a coincidence about rabbits. It is a shadow of a single algebraic
law, and the surprising news of this work is that the law has almost nothing to
do with Fibonacci at all. Strip away everything Fibonacci-specific and you are
left with one clean equation that, all by itself, forces the entire intricate
divisibility behaviour above. The same equation governs the numbers
`2^n − 1` (the home of the Mersenne primes that power record-breaking
prime hunts), the numbers `a^n − 1` for any base `a`, and a whole zoo of other
sequences. They all march to the same drum.

This article tells the story of that one law, the rigidity it imposes, and the
exact "calendar" of divisibility it produces.

## The magic equation

A sequence is just a list of whole numbers indexed by position:
`u(1), u(2), u(3), ...`. We say it is a **strong divisibility sequence** if it
obeys the following rule for every pair of positions `m` and `n`:

> **The strong divisibility law.**
> `u(gcd(m, n)) = gcd(u(m), u(n)).`

In words: *the greatest common divisor of two terms equals the term sitting at
the greatest common divisor of their positions.* The "gcd" — greatest common
divisor — is the largest number dividing both of its arguments. The law says
that the sequence intertwines two completely different worlds: the arithmetic
of **positions** (down in the index) and the arithmetic of **values** (the
actual sizes of the terms). Take the gcd downstairs, in the indices, and it is
faithfully reproduced upstairs, among the values.

The Fibonacci numbers satisfy this. For instance the 12th Fibonacci number is
144 and the 18th is 2584; their gcd is 8, which is exactly the 6th Fibonacci
number — and 6 is the gcd of 12 and 18. The numbers `a^n − 1` satisfy it too:
the gcd of `2^12 − 1 = 4095` and `2^18 − 1 = 262143` is 63, and 63 is
`2^6 − 1`. One equation, two famous families, identical behaviour.

The thesis of this work is radical in its simplicity: **every structural fact
about how primitive divisors and "ranks of apparition" behave in the Fibonacci
numbers is a logical consequence of this single equation, and of nothing
else.** Prove it once, abstractly, and you have proved it for Fibonacci, for
Mersenne, for Lucas sequences, and for any future sequence that happens to obey
the law.

## A free gift: the weak law

The strong law immediately hands us a weaker but useful cousin. Suppose a
position `m` divides a position `n` — for example, 4 divides 12. Then `m` is its
own gcd with `n` (the gcd of 4 and 12 is 4), and the strong law collapses to:

> **The weak divisibility law.** If `m` divides `n`, then `u(m)` divides `u(n)`.

So the 4th Fibonacci number (3) divides the 12th (144); the 4th term of
`2^n − 1` (which is 15) divides the 12th (4095). This "weak law" is the famous
classical fact that Fibonacci numbers at multiples of a position are divisible
by the term there. Here it costs nothing — it falls out of the strong law in a
single line, with no special pleading about Fibonacci.

## The meet law: a divisor's-eye view

Now comes the first genuinely sharp tool. Fix any number `d` you like — a
candidate divisor, not necessarily prime, not necessarily related to the
sequence. Then:

> **The meet law.**
> `d` divides `u(gcd(m, n))`  if and only if  `d` divides *both* `u(m)` and `u(n)`.

This is the strong law re-read through the eyes of a single divisor. The set of
positions where `d` "appears" as a factor is closed under taking gcds: if `d`
shows up at position `m` and at position `n`, it shows up at their gcd. This is
the technical heart from which everything else flows, and it holds for *any*
`d` whatsoever — no primality, no size conditions.

## Primitive divisors: the first appearance

Here is the central character of the story. We say `p` is a **primitive
divisor** of `u(n)` if:

- `p` divides `u(n)`, but
- `p` divides *none* of the earlier terms `u(1), u(2), ..., u(n−1)`.

In other words, position `n` is the *very first time* `p` ever appears as a
factor. For the Fibonacci numbers, 11 first appears as a factor at position 10
(the 10th Fibonacci number is 55 = 5 × 11), and never before — so 11 is a
primitive divisor of the 10th Fibonacci number. Number theorists call this first
position the **rank of apparition** or **entry point** of `p`: the moment `p`
enters the stage.

Primitive divisors are the atoms of divisibility for these sequences. And they
turn out to be astonishingly rigid.

## Rigidity: a factor can debut only once

> **Uniqueness of the debut.** A given number `p` can be a primitive divisor of
> at most one positive position. If `p` is primitive for `u(m)` and also
> primitive for `u(n)`, with both positions positive, then `m = n`.

The proof is a one-line clash of definitions, and it is so elementary it does
not even need the strong law. Suppose `p` debuts at two different positions,
say `m < n`. Being primitive at `n` means `p` divides *nothing* before position
`n` — in particular not `u(m)`. But being primitive at `m` means `p` *does*
divide `u(m)`. Contradiction. A factor cannot make its first entrance twice.

This is what makes the "rank of apparition" a well-defined label in the first
place: every primitive divisor carries exactly one position-tag, its debut. The
labelling is unambiguous.

There is one subtle catch, and the abstract viewpoint exposes it beautifully.
Why insist the positions be *positive*? Because of position zero. In the
abstract setting we typically have `u(0) = 0`, and *everything* divides zero, so
*every* number "divides `u(0)`" vacuously — making every number a primitive
divisor of position 0. Position zero is a degenerate trapdoor. The Fibonacci
sequence hides this because `F(0) = 0` is so familiar we forget it is special;
the abstract treatment forces us to name the assumption `u(0) = 0` out loud and
to bar position zero from the uniqueness theorem.

## The calendar: a primitive divisor's whole future

Rigidity tells us *when* a primitive divisor debuts. The next theorem tells us
its entire future, forever:

> **The pinning law.** If `p` is a primitive divisor of `u(n)` (with `n`
> positive), then for every position `m`:
> `p` divides `u(m)`  if and only if  `n` divides `m`.

Once `p` debuts at position `n`, it reappears at *exactly* the multiples of `n`
— positions `n, 2n, 3n, ...` — and at no others. The debut position becomes a
perfect calendar of every future appearance. This is precisely the "circle the
multiples" pattern we noticed at the very start, now proved in full generality.

The proof is short and pretty. One direction is the weak law: if `n` divides
`m`, then `u(n)` divides `u(m)`, and since `p` divides `u(n)` it divides `u(m)`
too. The other direction uses the meet law: if `p` divides `u(m)`, then because
`p` also divides `u(n)`, the meet law says `p` divides the term at
`gcd(n, m)`. But that gcd is at most `n`, and primitivity forbids `p` from
appearing before position `n`. The only way out is `gcd(n, m) = n`, which is
exactly the statement that `n` divides `m`.

## The join law: when two factors meet

Single primitive divisors keep tidy calendars. What happens when you ask two of
them to appear *simultaneously*?

Suppose `p` is primitive for `u(a)` — so `p` appears at multiples of `a` — and
`q` is primitive for `u(b)` — so `q` appears at multiples of `b`. When does a
single term `u(n)` contain *both* factors at once?

> **The join law.** `p` and `q` both divide `u(n)`  if and only if
> `lcm(a, b)` divides `n`.

Here `lcm` is the least common multiple — the smallest number that both `a` and
`b` divide. The logic is exactly the logic of overlapping calendars. `p` is
busy at multiples of `a`; `q` is busy at multiples of `b`; they are *both* busy
precisely at the common multiples of `a` and `b`, which are the multiples of
`lcm(a, b)`. The meet of two factors lives at the **join** (least common
multiple) of their two debut positions. Apparition at a gcd downstairs;
co-apparition at an lcm. The two lattice operations — meet and join — show up as
two faces of the same theory.

This is not limited to two factors. For any finite collection of primitive
divisors with debut positions `g(1), g(2), ..., g(k)`, all of them divide
`u(n)` simultaneously if and only if the least common multiple of all the debut
positions divides `n`. The proof is a clean induction, peeling off one factor at
a time.

## Counting the appointments: density

Because the calendar is so exact, we can *count*. How many of the first `N`
positions are appointment days for a primitive divisor of debut position `n`?
The appointment days are the multiples of `n`, so among positions `1, 2, ..., N`
there are exactly `⌊N / n⌋` of them — the floor of `N` divided by `n`.

> **The density law.** Among the first `N` positions, the number of appearances
> of a primitive divisor of position `n` is exactly `⌊N / n⌋`. Its long-run
> density is therefore `1/n`.

For two factors at once, the joint density is `1 / lcm(a, b)`. A primitive
divisor of position 7 shows up one position in seven; a primitive divisor of
position 4 and one of position 6 coincide one position in twelve, because
`lcm(4, 6) = 12`. The qualitative "if and only if" hardens into an exact count
of lattice points — the natural bridge from pure divisibility to the analytic
study of how often events happen.

## Why this matters beyond the rabbits

The punchline is the **unification**. The very same theorems, with the very same
proofs, immediately apply to the sequence `a^n − 1`. The strong divisibility law
for `a^n − 1` is a classical fact: `gcd(a^m − 1, a^n − 1) = a^{gcd(m,n)} − 1`.
Feed that into the abstract machine and out comes a complete theory of primitive
divisors for `a^n − 1` — for free.

That family is not academic. The numbers `2^p − 1` are the **Mersenne numbers**,
and the largest known prime numbers on Earth are Mersenne primes, found by the
worldwide GIMPS computing project. A *primitive* prime divisor of `2^n − 1` is a
prime whose multiplicative order is exactly `n`; the pinning law is, in disguise,
the statement that such a prime divides `2^m − 1` exactly when `n` divides `m` —
the backbone of how we reason about the periods of `2` modulo a prime. The same
"entry point" idea drives Lucas-style primality tests, the design of
pseudo-random number generators, and the analysis of repeating decimals (the
length of the repeating block of `1/p` in base `a` is precisely the entry point
of `p` in the `a^n − 1` sequence).

Even music and rhythm feel the join law: two repeating patterns of lengths `a`
and `b` realign every `lcm(a, b)` beats — the same least-common-multiple pulse
that governs when two primitive divisors co-appear.

## The honest edge of the map

One famous question deliberately lies *outside* this theory, and it is worth
naming. We have described, with complete precision, *where* a primitive divisor
appears once it exists. We have said nothing about *whether* one exists. The
deep classical result here is **Carmichael's theorem**: every Fibonacci number
beyond the 12th has at least one primitive prime divisor, with a short, explicit
list of exceptions. That is a statement about *existence*, and existence is a
question of *size* — you have to show a certain number is big enough to harbour a
brand-new prime. Our calendar-and-counting machinery is silent on size. It is
the perfect bookkeeping department for primitive divisors; it is not the
factory that produces them. Knowing exactly which department handles which
question is itself a kind of clarity.

## The moral

Mathematics prizes the moment when a tangle of special facts turns out to be one
fact wearing many costumes. The divisibility patterns of the Fibonacci numbers
look like a property of the Fibonacci numbers. They are not. They are a property
of a single equation — `u(gcd(m,n)) = gcd(u(m), u(n))` — that the Fibonacci
numbers merely happen to satisfy, along with `a^n − 1` and an open-ended family
of relatives. Pin down the equation, and the rigidity of debuts, the calendar of
appearances, the join law for coincidences, and the exact densities all follow
in a few lines each. The rabbits were never the point. The law was.
