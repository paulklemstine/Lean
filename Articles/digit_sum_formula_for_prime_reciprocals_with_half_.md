# The Secret Symmetry Hidden in Repeating Decimals

Take out a calculator, or better yet a pencil, and divide $1$ by $7$. You get a
number that never settles down:

$$\frac{1}{7} = 0.142857\,142857\,142857\ldots$$

The block $142857$ repeats forever. Now do something a child might do out of
boredom: add up the digits in one copy of that block.

$$1 + 4 + 2 + 8 + 5 + 7 = 27.$$

Try another fraction, $1/13$:

$$\frac{1}{13} = 0.076923\,076923\ldots, \qquad 0+7+6+9+2+3 = 27.$$

The same answer. Try $1/17$, $1/19$, $1/23$ — with a bit of patience you keep
landing on multiples of $9$, and there is a startling regularity to *which*
multiple you get. This is not a coincidence, and it is not magic. It is a
theorem, and behind it lies one of the prettiest small facts in number theory:
**the two halves of a repeating decimal are secretly mirror images of each
other.**

## A pattern begging for an explanation

Let us fix some language. Pick a base $b$ (for everyday decimals, $b = 10$) and a
prime $p$ that does not divide $b$. The fraction $1/p$ has a repeating expansion
in base $b$, and the length of the repeating block — call it $l$ — is a famous
quantity: it is the *multiplicative order* of $b$ modulo $p$, the smallest
positive power $l$ for which $b^l$ leaves remainder $1$ when divided by $p$.

For $b = 10$ and $p = 7$, that order is $6$, and indeed the block $142857$ has
six digits. For $p = 13$ the order is again $6$. In both cases the block splits
neatly down the middle:

$$142\,|\,857, \qquad 076\,|\,923.$$

Look at the two halves of $142857$. The first half is $142$; the second is
$857$. Add them digit by digit:

$$1+8 = 9, \quad 4+5 = 9, \quad 2+7 = 9.$$

Every column sums to $9$. The two halves are *nines-complements*: each digit in
the bottom half is exactly $9$ minus the digit above it. The same holds for
$076$ and $923$: $0+9 = 9$, $7+2 = 9$, $6+3 = 9$. This is the phenomenon known
since the nineteenth century as **Midy's theorem**, and once you see it, the
digit sum is no longer mysterious. If the block has $l$ digits, its two halves
have $l/2$ columns, each summing to $b - 1$ (that is, to $9$ in base ten). So the
total digit sum is forced to be

$$\frac{b-1}{2}\,\cdot\, l.$$

For $b = 10$, $l = 6$: the sum is $\tfrac{9}{2}\cdot 6 = 27$. Mystery solved —
twice over.

## Why the halves are complements

Why should the second half of a period be the nines-complement of the first?
The heart of the matter is a single algebraic fact. The repeating block of
$1/p$, read as an integer, is exactly

$$N = \frac{b^{\,l} - 1}{p},$$

the number you get when you compute $b^l - 1$ (a string of $l$ copies of the top
digit $b-1$) and divide by $p$. Splitting the block into two halves of length
$h = l/2$ amounts to writing $b^l - 1 = (b^h - 1)(b^h + 1)$.

Now comes the pivot. Because $l$ is the *order* of $b$, the power $b^h$ is a
square root of $1$ modulo $p$ that is **not** equal to $1$ (otherwise the period
would be shorter than $l$). In the arithmetic of a prime, the only square roots
of $1$ are $+1$ and $-1$. So $b^h$ must be congruent to $-1$:

$$b^{\,h} \equiv -1 \pmod p.$$

This is the fingerprint of an *even* order, and it is the true engine of the
whole story. It means $p$ divides $b^h + 1$, so we may set $k = (b^h+1)/p$ and
write the block as

$$N = \frac{(b^h-1)(b^h+1)}{p} = k \,(b^h - 1).$$

Multiplying any integer $k$ between $1$ and $b^h - 1$ by the "all-nines" number
$b^h - 1$ produces precisely a two-halves complementary pattern: the top half
encodes $k - 1$ and the bottom half encodes its nines-complement. Adding the
columns gives $(b-1)$ each time, $h$ times over. That is Midy's theorem, stripped
to its skeleton.

## The main result: reading off the exact answer

The pattern above tells us the digit sum is $(b-1)\,l/2$ *whenever the period is
even*. The final step is to express the period length in the cleanest possible
way. Every even period can be written by peeling off powers of two from $p - 1$.
Concretely, suppose the order of $b$ modulo $p$ equals

$$l = \frac{p-1}{2^{m}}$$

for some integer $m \ge 0$, and suppose in addition that $p \equiv 1
\pmod{2^{m+1}}$. This last congruence is exactly the condition that guarantees
$l$ is even — no more, no less. Under these hypotheses the digit sum has a
beautiful closed form.

> **Digit Sum Theorem for Half-Order Periods.** *Let $p \ge 3$ be a prime and
> $b \ge 2$ an integer not divisible by $p$. If the multiplicative order of $b$
> modulo $p$ equals $l = (p-1)/2^{m}$ and $p \equiv 1 \pmod{2^{m+1}}$, then the
> sum of the base-$b$ digits in one full period of $1/p$ is*
> $$\frac{(b-1)(p-1)}{2^{\,m+1}}.$$

Since $l = (p-1)/2^m$, the quantity $(b-1)(p-1)/2^{m+1}$ is just a rewriting of
$(b-1)\,l/2$ — the same "half of the all-nines total" we discovered by hand. The
theorem simply packages it in terms of $p$ and $m$, which is convenient because
$m$ measures *how many times two divides out of the period*.

Let us re-derive our two examples from the formula. For $p = 7$, $b = 10$: the
order is $6 = 12/2^0$, so $m = 0$, and $7 \equiv 1 \pmod 2$. The formula gives
$\tfrac{9 \cdot 6}{2} = 27$. For $p = 13$: the order is $6 = 12 / 2^1$, so
$m = 1$, and $13 \equiv 1 \pmod 4$. The formula gives $\tfrac{9 \cdot 12}{4} =
27$. Both check.

## The moving parts, made honest

It is worth being precise about the three ingredients, because each does real
work.

**The repeating block is an integer division.** The claim that the period of
$1/p$ is the base-$b$ representation of $N = (b^l - 1)/p$ (padded with leading
zeros to length $l$) is standard, and the leading zeros are harmless: a zero
contributes nothing to a digit sum. So it is legitimate to compute the digit sum
of the plain integer $N$, ignoring padding entirely.

**Even order forces a $-1$.** The single most important line is $b^h \equiv -1
\pmod p$. It follows because $b^l = (b^h)^2 \equiv 1$, so $b^h$ is a square root
of unity; and $b^h \not\equiv 1$ because $h < l$ and $l$ is the *smallest*
exponent giving $1$. In a field — and integers modulo a prime form a field — a
nonzero square root of $1$ other than $1$ can only be $-1$.

**Complements sum to $b - 1$.** The combinatorial payoff is the nines-complement
identity: for any digit-length $h$ and any $c$ smaller than $b^h$, the base-$b$
digit sum of $c$ and the digit sum of $b^h - 1 - c$ together equal $(b-1)h$.
Intuitively, $c$ and its complement fill each of the $h$ digit slots with a pair
that adds to $b-1$. This is proved by a clean induction on the number of digits,
peeling off one digit at a time.

Put together: $N = k(b^h - 1) = (k-1)b^h + (b^h - k)$ places the number $k-1$ in
the high $h$ digits and its complement $b^h - k = (b^h - 1) - (k - 1)$ in the low
$h$ digits, so the digit sum is $(b-1)h = (b-1)(p-1)/2^{m+1}$.

## Why this is more than a party trick

The identity $142857 \to 27$ looks like recreational arithmetic, but the
machinery underneath connects several currents of mathematics. The number
$142857$ is *cyclic*: multiply it by $2, 3, 4, 5, 6$ and you get the same six
digits in rotated order. That, too, is a shadow of the order of $10$ modulo $7$
being maximal. The appearance of $-1$ as a square root of unity is the same
phenomenon that governs quadratic residues, the law of quadratic reciprocity,
and the behavior of Gauss sums. And the "complementary halves" structure is a
baby case of functional equations that reappear, dramatically magnified, in the
symmetry of $L$-functions.

There is also a computational moral. To find the digit sum you do **not** need to
carry out the long division and add up potentially millions of digits. You need
only the order of $b$ modulo $p$ and one congruence check. The digit sum is then
read off from a formula. A brute-force approach scales with the length of the
period; the structural approach scales with the cost of a modular exponentiation.
For large primes this is the difference between feasible and hopeless.

## What lies just beyond the horizon

The theorem is sharp in a satisfying way: the exact halving $(b-1)l/2$ is tied
precisely to the order being even. When the order is *odd*, the two-halves mirror
disappears and the digit sum drops below $(b-1)l/2$ by a genuine, positive
deficit. Understanding that deficit is the natural next quest. The evidence
points to a surprising culprit: the missing symmetry is measured by a
*Dedekind sum*, a delicate lattice-counting gadget that turns the
digit-combinatorics question into a problem about how the powers $b^i \bmod p$
scatter across the number line. Averaged over many primes, these fluctuations
appear to be orchestrated by generalized Bernoulli numbers and special values of
$L$-functions — the same objects that sit at the center of modern number theory.

So the next time a repeating decimal scrolls past on your screen, remember: those
digits are not random noise. They come in mirrored pairs, they know the order of
$10$ modulo their denominator, and hidden in their sum is a small, exact, and
genuinely beautiful piece of arithmetic.
