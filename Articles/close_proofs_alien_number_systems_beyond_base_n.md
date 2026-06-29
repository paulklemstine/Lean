# Alien Number Systems: Beyond Base-N

## A counting machine with a different rule on every wheel

Imagine the odometer of a car. As you drive, the rightmost wheel spins
through $0, 1, 2, \dots, 9$ and then, on the tenth click, rolls back to $0$
while nudging its neighbor forward by one. Every wheel obeys the same law:
ten clicks and you carry. That single, uniform rule — "ten, then carry" — is
the decimal system, base $10$. Computers use the same machine with two-position
wheels (base $2$); the ancient Babylonians used wheels with sixty positions
(base $60$).

But why should *every* wheel obey the *same* rule? What if the rightmost wheel
carried after $2$ clicks, the next after $3$, the next after $4$, and so on —
each wheel with its own private rule? You would have built an **alien number
system**: a counting machine in which the base can change from one position to
the next. Mathematicians call this a **mixed-radix** system, and far from being
a curiosity, it is the hidden grandparent of *all* the familiar bases. Decimal,
binary, hexadecimal — every one of them is a single, special setting of a much
more general dial.

This article tells the story of that general dial: what it is, why it works
perfectly (no number is ever ambiguous, no number is ever unrepresentable), and
how two famous systems — ordinary base-$N$ and the elegant **factorial number
system** — fall out as two points in one unified family.

## The machine, precisely

Fix a list of bases, one per wheel, written least-significant-first:
$$bs = [b_0, b_1, b_2, \dots, b_{k-1}].$$
The rightmost wheel carries after $b_0$ clicks, the next after $b_1$, and so on.
A list of digits $ds = [d_0, d_1, \dots, d_{k-1}]$ then names a number by the
nested "Horner" rule
$$\mathrm{mval}(bs, ds) = d_0 + b_0\bigl(d_1 + b_1\bigl(d_2 + b_2(\cdots)\bigr)\bigr).$$
Read inside-out, this says exactly what an odometer does: each wheel's value is
scaled by the product of the capacities of all the wheels to its right.

Two sanity checks anchor the idea.

- **Decimal.** Take every base equal to $10$, i.e. $bs = [10,10,10]$. Then the
  digit list $[3,2,7]$ (remember, least significant first) names
  $3 + 10(2 + 10\cdot 7) = 723$. The familiar number, recovered.
- **Factorial.** Take the bases $bs = [2,3,4,5]$. Then $[0,2,0,4]$ names
  $0 + 2(2 + 3(0 + 4\cdot 4)) = 0 + 2\cdot 2 + 0 + 4\cdot 24 = 100$. We have just
  written $100$ as $2\cdot 2! + 4\cdot 4!$ — its *factoradic* form.

The factorial system is the poster child of an alien base: its wheels carry
after $2, 3, 4, 5, \dots$ clicks. It is genuinely non-uniform, yet it counts
just as faithfully as decimal.

## Reading a number off the wheels

To go the other way — from a number $n$ back to its digits — the machine is
greedy and recursive. The rightmost digit is simply the remainder $n \bmod b_0$;
then you divide, $n \mapsto n / b_0$, hand the quotient to the *remaining* wheels,
and repeat. In symbols,
$$\mathrm{mdigits}(b_0 :: bs', \, n) = (n \bmod b_0) :: \mathrm{mdigits}(bs', \, n/b_0).$$
This is precisely how you make change with coins, or how you convert to binary by
repeated halving. Nothing exotic — just division with remainder, applied wheel by
wheel.

The first guarantee is a clean structural fact: **the digit list always has
exactly as many entries as there are bases.** Feed in $k$ wheels and you get back
$k$ digits, no matter what number you started with.

## The master law: why nothing gets lost

Here is the keystone of the whole theory. Define the **capacity** of the machine
to be the product of all its bases,
$$\mathrm{cap}(bs) = b_0 \cdot b_1 \cdots b_{k-1}.$$
For decimal with three wheels the capacity is $10^3 = 1000$ (you can count
$0$ through $999$). For the factorial bases $[2,3,4,5]$ the capacity is
$2\cdot3\cdot4\cdot5 = 120 = 5!$. The capacity is the alien generalization of
"$b^k$": it is exactly how many distinct numbers the machine can name.

The **master reconstruction law** states:
$$\mathrm{mval}\bigl(bs, \, \mathrm{mdigits}(bs, n)\bigr) = n \bmod \mathrm{cap}(bs).$$
In words: read a number onto the wheels, then read it back off, and you recover
$n$ — exactly, as long as $n$ was below the capacity; and if $n$ was too big, you
recover $n$ wrapped around modulo the capacity, just like an odometer rolling
past its maximum. The proof is a short induction whose inductive step collapses to
a single classical identity about how remainders behave under multiplication
($n \bmod (b \cdot m)$ splits into a low part and a high part). Everything else in
the theory is a corollary of this one law.

Two immediate consequences:

- **Exact round-trips.** If $n < \mathrm{cap}(bs)$, then reading $n$ onto the
  wheels and back returns $n$ on the nose. No information is lost for numbers the
  machine can actually hold.
- **Valid digits.** As long as every base is positive, the extracted digits are
  always *legal*: the $i$-th digit is strictly less than $b_i$. A wheel never
  shows a value it cannot physically display.

## No number is ambiguous

A counting system is only trustworthy if every number has *exactly one* name.
Decimal would be useless if $42$ could also be written as, say, $3\,\$\,8$ for some
other legal digit string. The alien system passes this test perfectly, and the
argument splits into two halves that fit together like a key in a lock.

**Every legal name points below the capacity.** If a digit list is *valid* — each
digit $d_i$ strictly below its base $b_i$ — then the value it denotes is strictly
less than the capacity:
$$\mathrm{mval}(bs, ds) < \mathrm{cap}(bs).$$
This is the alien generalization of the obvious fact that a $3$-digit decimal
number is at most $999 < 1000$. It is the "telescoping estimate": each digit,
being below its base, contributes just little enough that the running total can
never reach the product of all the bases.

**Every value has a unique legal name.** Combining the bound above with the master
law, one proves that a valid digit list is recovered *exactly* by the greedy
extraction from the value it denotes:
$$\mathrm{mdigits}\bigl(bs, \, \mathrm{mval}(bs, ds)\bigr) = ds.$$
Two different legal digit lists therefore cannot name the same number — if they
did, feeding that shared number back into $\mathrm{mdigits}$ would have to return
both lists, which is impossible. **Uniqueness, proved without ever counting.**

This last point is worth savoring. A lazier proof might argue by a pigeonhole or
cardinality count: "there are exactly $\mathrm{cap}(bs)$ legal digit lists and
exactly $\mathrm{cap}(bs)$ numbers below the capacity, so the map between them must
be a bijection." That works, but it is *circular* in spirit — it assumes the very
counting structure it is trying to establish. The development here is
deliberately **non-circular**: uniqueness comes directly from the digit-bound
estimate and Euclidean division (divide to get the top digit, take the remainder
to get the rest), never from a cardinality argument. The honesty of the argument
is part of its beauty.

## The crowning bijection

Put the two halves together and you get the theorem that crowns the theory. For
any list of positive bases, there is a perfect one-to-one correspondence
$$\{0, 1, \dots, \mathrm{cap}(bs)-1\} \;\longleftrightarrow\; \{\text{valid digit lists}\}.$$
Every number in the range names exactly one legal configuration of the wheels,
and every legal configuration names exactly one number. The machine neither
double-counts nor leaves gaps. This is the alien generalization of the statement
that the $k$-digit base-$b$ strings are in bijection with $\{0, \dots, b^k - 1\}$ —
the foundational fact that makes positional notation work at all.

## Two famous systems, one family

The payoff of generality is unification. Set the dial two different ways and two
celebrated systems emerge.

**Uniform base-$b$.** Choose $k$ copies of the same base, $bs = [b, b, \dots, b]$.
The capacity collapses to $b^k$, and the alien evaluation $\mathrm{mval}$ literally
*becomes* the standard base-$b$ evaluation used throughout mathematics (the map
that turns a digit list into a number, $\sum_i d_i b^i$). The classical theorem
that every $n < b^k$ has a unique length-$k$ base-$b$ expansion is recovered, word
for word, as the uniform instance of the alien round-trip. Ordinary positional
notation is not replaced — it is *contained*.

**The factorial system.** Choose the ascending bases $bs = [2, 3, 4, \dots, k+1]$.
The capacity telescopes — $2\cdot 3\cdots(k+1) = (k+1)!$ — and the digit at
position $i$ is bounded by $i+1$. This is the **factoradic** representation, where
$$n = c_0\cdot 0! + c_1\cdot 1! + c_2\cdot 2! + \cdots, \qquad 0 \le c_i \le i.$$
It is the natural numbering of *permutations* (the $n$-th permutation in
lexicographic order is read straight off the factoradic digits of $n$), and it is
the alien system par excellence: a different rule on every wheel, yet flawless.

The factorial system can also be developed entirely on its own terms, and doing so
illuminates the same machinery from a second angle. Here a length-$k$ value is
$$\mathrm{value}(c, k) = \sum_{i<k} c_i \cdot i!, \qquad \text{valid when } c_i \le i,$$
and the three pillars reappear in undisguised arithmetic form:

- **The digit bound** — a valid length-$k$ value is strictly below $k!$ — the
  telescoping estimate again.
- **Splitting by division** — dividing a valid length-$(k+1)$ value by $k!$
  recovers the top digit $c_k$ exactly, and taking the remainder recovers the
  lower part. This is Euclidean division by $k!$ doing all the work.
- **Direct uniqueness** — peel off the top digit by division, reduce the rest by
  the remainder, and induct. Same numbers in, same digits out, with no detour
  through counting.

Existence comes afterward, via an explicit formula for the $i$-th factoradic
digit, $\mathrm{digit}(n, i) = (n / i!) \bmod (i+1)$, which is shown to be valid and
to reconstruct any $n < k!$.

## Why this matters

The lesson is one mathematics keeps teaching: the most familiar object is often a
special case of something simpler and more honest. We learn decimal as a fixed,
god-given rule, then meet binary and hexadecimal as separate skills. The
mixed-radix viewpoint reveals them as one knob turned to different settings — and
in the same breath it hands us the factorial system, time-zone arithmetic
(seconds, minutes, hours, days carry at $60, 60, 24, \dots$), the way we count in
weeks and months, and the clean indexing of permutations.

Most importantly, the unification is *honest*. Uniqueness is not smuggled in by
counting the very thing we want to count; it is earned, position by position, from
nothing but the bound "each digit is below its base" and the oldest tool in
arithmetic — division with remainder. Turn the dial to all-tens and you get the
odometer you have known since childhood. Turn it to $2, 3, 4, 5, \dots$ and you get
the factorial machine. Either way, the deep guarantee is the same: **every number
has exactly one name, and every name a number.** That is what it means for a
counting system — alien or familiar — to truly count.
