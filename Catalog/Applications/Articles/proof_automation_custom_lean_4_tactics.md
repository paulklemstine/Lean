# The Hidden Lattice Inside Fibonacci

## One rule that ties number theory to the algebra of order

Take the Fibonacci numbers — that famous parade where each term is the sum of the two before it:

```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, ...
```

Most people meet them through rabbits, sunflowers, or the golden ratio. But there is a quieter,
stranger fact about Fibonacci numbers, one that has fascinated number theorists for over a century.
It concerns **greatest common divisors**.

Pick two positions in the sequence, say the 12th and the 8th. The greatest common divisor of those
two Fibonacci numbers turns out to be the Fibonacci number whose position is the greatest common
divisor of 12 and 8. In symbols:

```
gcd(F₁₂, F₈) = gcd(144, 21) = 3 = F₄ = F_gcd(12, 8).
```

This is not a coincidence of small numbers. It is a theorem: **for all m and n,**

```
gcd(Fₘ, Fₙ) = F_gcd(m, n).
```

The Fibonacci sequence *transports* greatest common divisors. The operation "take the gcd" on the
inside (of the indices) matches "take the gcd" on the outside (of the values). The same magic
appears in a completely different setting: the **Mersenne numbers** `bⁿ − 1` (think of 1, 3, 7, 15,
31 for `b = 2`). There too, `gcd(bᵐ − 1, bⁿ − 1) = b^gcd(m, n) − 1`.

What do Fibonacci numbers and `2ⁿ − 1` have in common? Almost nothing on the surface — one is built
from a golden-ratio recurrence, the other from raw exponentiation. The answer this work makes
precise is: **they obey the same single rule**, and that rule alone forces a rich, predictable
structure. The structure is not really about numbers at all. It is about *order* — about lattices.

---

## What is a strong divisibility sequence?

Let us name the rule. A sequence of natural numbers `a(0), a(1), a(2), ...` is a **strong
divisibility sequence** if it satisfies just two axioms:

1. **It starts at zero:** `a(0) = 0`.
2. **It transports gcd:** `gcd(a(m), a(n)) = a(gcd(m, n))` for every pair of indices `m` and `n`.

That's the whole definition. Fibonacci is one. Each Mersenne sequence `bⁿ − 1` is one. The trivial
sequence `a(n) = n` is one (gcd of indices is literally gcd of values). And — this is the punchline —
*everything* you can prove from those two axioms holds for **all** of them at once.

The deepest theme of this work is that this innocent gcd rule is secretly a statement about a famous
algebraic object: the **divisibility lattice**.

---

## A detour: the lattice of divisibility

Forget sequences for a moment. Look at the natural numbers, but reorder them. Instead of the usual
"less than" order, say that `x ≤ y` whenever **x divides y**. Under this order:

- `2 ≤ 6` (because 2 divides 6), but 2 and 5 are incomparable (neither divides the other).
- The **meet** (greatest lower bound) of two numbers is their **greatest common divisor**, `gcd`.
- The **join** (least upper bound) of two numbers is their **least common multiple**, `lcm`.
- The number `1` is the bottom (it divides everything); `0` is the top (everything divides 0).

This is a *lattice*: a set with a well-behaved meet and join. The divisibility lattice is one of the
most beautiful structures in elementary mathematics, because it converts arithmetic (factoring) into
geometry (order).

Now reread the strong-divisibility axiom with lattice eyes. The rule

```
gcd(a(m), a(n)) = a(gcd(m, n))
```

says exactly: **the map `a` carries the meet of the indices to the meet of the values.** In the
language of order theory, `a` is a **meet-homomorphism** (an "inf-homomorphism") of the divisibility
lattice. The gcd rule that looked like an arithmetic curiosity is really a structure-preservation
law.

This raises an irresistible question. The lattice has *two* operations, meet and join. We know `a`
preserves meet. **Does it preserve join?** Does `a` carry the least common multiple of the indices to
the least common multiple of the values?

---

## The asymmetry: meet is exact, join only divides

Here the story turns subtle, and beautiful. Test it on Fibonacci. Take indices 4 and 6:

```
lcm(F₄, F₆) = lcm(3, 8) = 24,   but   F_lcm(4,6) = F₁₂ = 144.
```

These are *not* equal. So `a` does **not** preserve join exactly. But notice: 24 **divides** 144.
The image of the lcm is always at least as divisible. This is no accident. The work proves, for every
strong divisibility sequence, the **join sub-law**:

```
lcm(a(m), a(n))  divides  a(lcm(m, n)).
```

In lattice language: `a` is only a **join-sub-homomorphism**. The join of the images sits *below*
(divides) the image of the join. So a strong divisibility sequence is a lopsided creature: it
preserves meet **on the nose**, but join only **up to divisibility**. This asymmetry — exact for gcd,
mere divisibility for lcm — is the central structural insight of the whole programme.

Why the asymmetry? The meet law is *given* to us as an axiom. The join law, by contrast, has to be
*derived*, and the only tool available is **monotonicity**: if `m` divides `n`, then `a(m)` divides
`a(n)`. (This itself follows from the gcd axiom: if `m | n` then `gcd(m,n) = m`, so
`gcd(a(m), a(n)) = a(m)`, meaning `a(m)` divides `a(n)`.) Monotonicity is enough to push the lcm of
the images underneath the image of the lcm — but not enough to make them equal.

---

## From pairs to crowds: the finitary laws

Pairs are nice, but mathematicians want *families*. What if you take not two indices but a whole
finite collection `g(i)` for `i` ranging over some index set? Does the picture survive?

It does, and cleanly. By induction, the two laws lift to arbitrary finite families:

- **Finitary meet law (exact):**
  ```
  gcd over i of a(g(i))  =  a( gcd over i of g(i) ).
  ```
  Computing the gcd of a whole bag of values `a(g(i))` is the same as feeding the gcd of all the
  indices through `a`. Exactly equal.

- **Finitary join sub-law (divides):**
  ```
  lcm over i of a(g(i))  divides  a( lcm over i of g(i) ).
  ```
  The lcm of the values always divides the value at the lcm of the indices.

The base cases are quietly poetic. For the empty family, the gcd is `0` (the lattice top under gcd
on ℕ, here matched by `a(0) = 0`), and the lcm is `1` — whose image `a(1)` then divides everything,
exactly as the sub-law demands. The two boundary values `a(0) = 0` and `a(1)` are precisely the
hinges on which the whole induction swings.

---

## Coprimality and a tale of two top elements

Here is where the framework starts to *predict* things you might never have guessed.

Two numbers are **coprime** if their gcd is 1 — they share no prime factors. Suppose two indices `m`
and `n` are coprime. What is `gcd(a(m), a(n))`? The meet law answers instantly:

```
gcd(a(m), a(n)) = a(gcd(m, n)) = a(1).
```

The gcd of the values collapses to a single fixed number: `a(1)`, the value of the sequence at the
index 1. So whether coprime indices give coprime *values* hinges entirely on **one number**:
**is `a(1) = 1`?**

- For Fibonacci, `F₁ = 1`. So coprime indices give coprime Fibonacci numbers:
  `gcd(F₇, F₁₀) = gcd(13, 55) = 1`. The index 1, the "top" of the index lattice, maps to the value
  1, the "top" of the value lattice. Coprimality propagates perfectly.

- For Mersenne, `b¹ − 1 = b − 1`, which is *not* 1 (unless `b = 2`). So coprime indices do **not**
  give coprime values; instead, `gcd(bᵐ − 1, bⁿ − 1) = b − 1` for coprime `m, n`. The leftover
  `b − 1` is exactly `a(1)`. The framework doesn't just tolerate this discrepancy — it *explains*
  it. The residual is always the image of the top element.

This is the kind of unification that makes the abstraction worth it. A single condition, `a(1) = 1`,
governs whether coprimality survives the sequence, and it does so for Fibonacci, Mersenne, and every
other strong divisibility sequence simultaneously.

The coprimality story scales up too. If `a(1) = 1` and a finite family of indices is **pairwise
coprime** (every two of them coprime), then the corresponding values are pairwise coprime as well.
And pairwise-coprime values whose gcds are all 1 multiply nicely: their product divides the value at
the product of the indices,

```
product over i of a(g(i))  divides  a( product over i of g(i) ),
```

a clean "product law" that, for Fibonacci with `a(1) = 1`, recovers classical facts about products
of Fibonacci numbers at coprime indices.

---

## Why this matters

It is tempting to file all this under "cute identities about Fibonacci numbers." That would miss the
point entirely. The real content is a change of *perspective*:

**Number-theoretic facts about specific sequences are shadows of order-theoretic facts about a single
abstract map.**

Once you see that Fibonacci, Mersenne, repunits, and the identity sequence are all the *same kind of
object* — a meet-homomorphism and join-sub-homomorphism of the divisibility lattice — you stop
proving the same theorem over and over for each sequence. You prove it once, abstractly, and harvest
every instance for free. The "primitive divisor" theory that took mathematicians decades to build for
Fibonacci numbers, and separately for Mersenne numbers (the famous Zsygmondy theory), turns out to
rest on the *two axioms* and nothing else.

This is the essence of a **bridge**: a single structural idea standing between two fields. On one
bank, classical number theory with its gcds, lcms, and primitive divisors. On the other, order theory
with its lattices, meets, joins, and homomorphisms. The strong divisibility sequence is the bridge,
and walking across it converts hard, sequence-specific arithmetic into easy, universal algebra.

There is also a lesson in *asymmetry*. We are trained to expect symmetry in mathematics — if meet is
preserved, surely join is too. But here the structure is genuinely lopsided: exact for one operation,
mere divisibility for the other. Recognizing and *quantifying* such asymmetries is often where the
real mathematics lives. The gap between `lcm(a(m), a(n))` and `a(lcm(m, n))` is not a flaw in the
theory; it *is* the theory. It measures precisely how far a strong divisibility sequence falls short
of being a perfect lattice homomorphism — and for Fibonacci, that gap closes exactly when one index
divides the other.

---

## The takeaway

Strip away the rabbits and the golden ratio, and the Fibonacci sequence reveals a skeleton made of
pure order. The same skeleton holds up `2ⁿ − 1`, `bⁿ − 1`, and the humble counting numbers. That
skeleton is the divisibility lattice, and the rule that animates it is a single line:

```
gcd(a(m), a(n)) = a(gcd(m, n)).
```

From that one line flow monotonicity, the exact finitary meet law, the divides-only join law,
coprimality propagation governed by the lone number `a(1)`, and product laws for coprime indices —
all at once, for an entire family of famous sequences. It is a small miracle of mathematical economy:
two axioms, a whole theory, and a bridge between two worlds that looked, until you found the right
vantage point, completely unrelated.
