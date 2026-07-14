# When Rabbits Meet Right Angles: The Hidden Geometry of Fibonacci Numbers

## A tale of two ancient patterns

Two of the oldest patterns in mathematics were born far apart. One is the
**Pythagorean relation**, $a^2 + b^2 = c^2$, the rule that governs every right
triangle and that surveyors, sailors, and architects have leaned on for four
thousand years. The other is the **Fibonacci sequence**,

$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ \dots$$

in which each number is the sum of the two before it. Fibonacci introduced it in
1202 to model the breeding of rabbits, but it turns up everywhere: in the spiral
of a sunflower, the branching of a tree, the growth of a nautilus shell.

At first glance these two patterns have nothing to say to each other. One is
about *shape*; the other is about *growth*. This article is about a bridge
between them — a simple recipe that turns any four consecutive Fibonacci numbers
into a perfect right triangle, and, remarkably, always lands its longest side
exactly on another Fibonacci number. Along the way we will meet a second, deeper
idea: a single principle about "divisibility sequences" that simultaneously
explains a curious fact about Fibonacci numbers and an equally curious fact about
numbers of the form $2^n - 1$.

## The recipe

Pick any starting point $n$ and look at four Fibonacci numbers in a row:

$$F_n,\quad F_{n+1},\quad F_{n+2},\quad F_{n+3}.$$

Now build two "legs" of a triangle out of them:

- **Leg $A$** is the product of the *outer* two: $A = F_n \cdot F_{n+3}$.
- **Leg $B$** is *twice* the product of the *inner* two: $B = 2\,F_{n+1}\,F_{n+2}$.

Then form the number

$$C = F_{n+1}^{\,2} + F_{n+2}^{\,2}.$$

The claim is that $A$, $B$, and $C$ are the two legs and the hypotenuse of a
genuine right triangle:

$$A^2 + B^2 = C^2.$$

Let us try it. Take $n = 2$, so the four Fibonacci numbers are $1, 2, 3, 5$.
Then

$$A = 1 \cdot 5 = 5,\qquad B = 2 \cdot 2 \cdot 3 = 12,\qquad C = 2^2 + 3^2 = 13.$$

And indeed $5^2 + 12^2 = 25 + 144 = 169 = 13^2$. Out of the humble sequence
$1,2,3,5$ we have produced the famous $(5, 12, 13)$ triangle.

Try $n = 1$: the numbers are $1, 1, 2, 3$, giving $A = 1\cdot 3 = 3$,
$B = 2\cdot 1\cdot 2 = 4$, $C = 1 + 4 = 5$ — the most famous right triangle of
all, $(3, 4, 5)$. The two most iconic Pythagorean triples in history fall out of
the very first steps of the rabbit sequence.

## Why it always works

There is no magic here, only algebra — but the algebra is elegant. Because
Fibonacci numbers obey $F_{n+2} = F_n + F_{n+1}$, every one of the four numbers
can be written in terms of just two of them, say $x = F_n$ and $y = F_{n+1}$:

$$F_{n+2} = x + y,\qquad F_{n+3} = x + 2y.$$

Substituting into the recipe, the two legs become
$A = x(x+2y) = x^2 + 2xy$ and $B = 2y(x+y) = 2xy + 2y^2$, while the candidate
hypotenuse is $C = y^2 + (x+y)^2$. Expanding $A^2 + B^2$ and $C^2$ as ordinary
polynomials in $x$ and $y$, both sides collapse to the *same* expression. The
identity is not a coincidence that must be checked case by case; it is a single
polynomial truth that holds for **every** $n$ at once. This is the essence of the
result we call the **Fibonacci–Pythagorean Identity**.

## The surprise: the hypotenuse is itself a Fibonacci number

Here is where the story turns from pretty to astonishing. Look again at the
hypotenuses we found: $5$ for $n=1$, and $13$ for $n=2$. Both are Fibonacci
numbers! This is not a fluke. The hypotenuse always satisfies

$$C = F_{n+1}^{\,2} + F_{n+2}^{\,2} = F_{2n+3}.$$

That the *sum of the squares* of two consecutive Fibonacci numbers is again a
single Fibonacci number — with an index that neatly doubles — is a classical
gem. It follows from the **Fibonacci addition formula**

$$F_{m+k+1} = F_m F_k + F_{m+1} F_{k+1},$$

which tells you how to "jump ahead" in the sequence. Setting $m = k = n+1$ turns
the right-hand side into exactly $F_{n+1}^2 + F_{n+2}^2$ and the left-hand side
into $F_{2n+3}$. We call this the **Fibonacci Hypotenuse Theorem**.

Putting the two theorems together gives the headline result, the
**Fibonacci–Pythagorean Triple Theorem**: for every $n$,

$$\bigl(F_n F_{n+3}\bigr)^2 + \bigl(2 F_{n+1} F_{n+2}\bigr)^2 = F_{2n+3}^{\,2}.$$

Every four consecutive rabbits generate a right triangle whose hypotenuse is a
rabbit of odd index. The construction (for genuine triangles, $n \ge 1$) sweeps out $F_5 = 5, F_7 =
13, F_9 = 34, F_{11} = 89, \dots$ as hypotenuses — precisely the Fibonacci numbers
at odd positions.

One honest caveat: these triangles are real but not always "primitive" (that is,
the three sides sometimes share a common factor). For $n = 3$ the recipe yields
$(16, 30, 34)$, which is just $2 \times (8, 15, 17)$. And to be sure we always
have an *actual* triangle rather than a degenerate one, we note that for every
$n \ge 1$ both legs are strictly positive — no vanishing side sneaks in.

## A deeper current: divisibility that mirrors the index

The Fibonacci sequence hides a second secret, one it shares with an entirely
different family of numbers. Consider the question: *when does one Fibonacci
number divide another?* The answer is beautiful in its simplicity:

$$F_m \text{ divides } F_n \quad\Longleftrightarrow\quad m \text{ divides } n.$$

For example, $F_3 = 2$ divides $F_6 = 8$ and $F_9 = 34$ and $F_{12} = 144$ — the
multiples of $3$ — and no others. Divisibility among the *values* perfectly
echoes divisibility among the *positions*.

Now consider a seemingly unrelated family, the numbers $M_n = a^n - 1$ for a
fixed base $a \ge 2$ (with $a = 2$ these are the **Mersenne numbers**
$1, 3, 7, 15, 31, 63, \dots$). They obey exactly the same law:

$$a^m - 1 \text{ divides } a^n - 1 \quad\Longleftrightarrow\quad m \text{ divides } n.$$

Why should two such different sequences behave identically? Because both are
instances of a single abstract structure called a **strong divisibility
sequence** — a sequence $a_1, a_2, a_3, \dots$ in which the greatest common
divisor of two terms is the term at the greatest common divisor of their indices:

$$\gcd(a_m, a_n) = a_{\gcd(m,n)}.$$

From this one property, plus the mild assumption that the terms are all distinct,
a short argument shows that **term divisibility is exactly index divisibility**:
$a_m \mid a_n$ if and only if $m \mid n$. If $a_m$ divides $a_n$, then
$\gcd(a_m, a_n) = a_m$; but the gcd equals $a_{\gcd(m,n)}$, so $a_{\gcd(m,n)} =
a_m$, and distinctness forces $\gcd(m,n) = m$, i.e. $m \mid n$. The converse runs
the same way in reverse. This is the **Strong Divisibility Characterization**,
and the Fibonacci and Mersenne laws are simply its two most famous children.

## A test for Fibonacci primes

The divisibility law has a striking consequence. Suppose $F_n$ is a prime number.
Could $n$ be composite, say $n = jk$ with $1 < j, k < n$? Then $F_j$ would divide
$F_n$ — but a prime has no divisors strictly between $1$ and itself, so $F_j$
would have to be $1$ or $F_n$. Chasing this through, one finds that the *index*
of a Fibonacci prime must itself be prime, with a single, unavoidable exception:

$$F_n \text{ prime} \quad\Longrightarrow\quad n = 4 \ \text{ or } \ n \text{ is prime.}$$

The exception is real: $F_4 = 3$ is prime even though $4$ is not. It is forced by
the small-index edge cases where the "distinct terms" assumption first takes
hold. Every other Fibonacci prime sits at a prime index: $F_3 = 2$, $F_5 = 5$,
$F_7 = 13$, $F_{11} = 89$, $F_{13} = 233$, and so on. This **Fibonacci Prime
Index Test** does not settle the still-open question of whether there are
infinitely many Fibonacci primes, but it tells us exactly where to look.

## Why it matters

Bridges between mathematical worlds are more than curiosities. The link between
Fibonacci growth and Pythagorean shape means that a fact proved on one side can
be transported to the other: the addition formula that governs how the sequence
races ahead becomes a statement about the side lengths of triangles. The strong
divisibility principle is even more powerful, because it is *domain-agnostic*:
any sequence obeying the gcd law — and there are many, from Fibonacci-like
recurrences to $a^n - 1$ to certain elliptic-curve sequences — inherits the whole
package at once, including the search rules for primes.

There is a modern moral, too. Both the triangle recipe and the divisibility
principle were established not by checking millions of examples but by finding the
*one identity* or *one abstract property* that makes the whole infinite family
work simultaneously. That is the mathematician's version of leverage: prove it
once, in the right generality, and reap the harvest everywhere. The rabbits of
1202 and the right angles of antiquity turn out to be speaking the same language
— we only had to find the dictionary.
