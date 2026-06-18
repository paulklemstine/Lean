# The Other Half of the Golden Sequence

## A hidden twin, and the question it answers

Almost everyone has met the Fibonacci numbers. They start

$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ 89,\ 144,\ \dots$$

where each number is the sum of the two before it. They appear in the spiral of a
sunflower, the branching of a tree, the proportions admired by Renaissance painters,
and — less romantically but far more deeply — in the inner machinery of number theory.

Far fewer people have met the Fibonacci numbers' fraternal twin: the **Lucas numbers**.
They obey the *exact same rule* — add the last two to get the next — but they begin from
a different seed:

$$2,\ 1,\ 3,\ 4,\ 7,\ 11,\ 18,\ 29,\ 47,\ 76,\ 123,\ 199,\ \dots$$

That single change in starting values produces a sequence that walks in lockstep beside
Fibonacci forever, never quite touching it, yet bound to it by a web of beautiful
identities. The Lucas numbers are not a curiosity. They are the missing half of a story
that the Fibonacci numbers can only half-tell.

This article is about that story — and about a clean, complete answer to a deceptively
simple question:

> **Given a prime number $p$, exactly which Lucas numbers does $p$ divide?**

The answer turns out to be governed by a single quantity attached to $p$ — its
*Fibonacci entry point* — and the bridge that carries us from Fibonacci to Lucas is one
of the oldest and most elegant identities in the subject.

## Entry points: where a number first appears

Pick any whole number $m$ — say $m = 7$. Now scan down the Fibonacci sequence and ask:
*when does $7$ first divide a Fibonacci number?*

$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ \mathbf{21},\ \dots$$

The eighth Fibonacci number is $21 = 3 \times 7$. So $7$ "appears" at index $8$. We say
the **rank of apparition** (or *entry point*) of $7$ is $8$, and write $\alpha(7) = 8$.

This is not a fluke of small numbers. A foundational fact — proved here from scratch — is
that **every** positive number $m$ eventually divides some Fibonacci number with a
positive index. The proof is a gem of pure pigeonhole reasoning. Look at consecutive pairs

$$(F_0, F_1),\ (F_1, F_2),\ (F_2, F_3),\ \dots$$

and reduce each pair modulo $m$. There are only $m^2$ possible pairs of remainders, so
somewhere down the line a pair must repeat. But the Fibonacci rule is *reversible* — if you
know two consecutive values you can run the recurrence backward as easily as forward — so
the first repeat must be the very starting pair $(0, 1)$ coming around again. The moment it
does, a Fibonacci number has hit a multiple of $m$. The sequence of remainders is periodic,
and inside every period sits a zero.

This guarantees the entry point $\alpha(m)$ is always well defined. And entry points are not
merely *some* index where $m$ shows up — they organize *all* of them. The **ideal-structure
theorem** says:

$$m \mid F_k \quad\Longleftrightarrow\quad \alpha(m) \mid k.$$

In words: $m$ divides exactly those Fibonacci numbers whose index is a multiple of the entry
point. For $m = 7$, with $\alpha(7) = 8$, this predicts $7$ divides $F_8, F_{16}, F_{24}, \dots$
and *no others*. The Fibonacci divisibility pattern of any number is a perfectly regular
arithmetic progression of indices. This single fact is the engine behind Carmichael's
celebrated primitive-divisor theorem, and it is why entry points sit at the heart of the
theory.

So the Fibonacci side of the story is tidy and complete. But it is only half the picture —
because nothing here tells us a thing about the **Lucas** numbers.

## The doubling bridge

Here is the identity that changes everything. It is classical, going back to the
nineteenth-century work of Édouard Lucas himself, and it links the two sequences at *double*
the index:

$$\boxed{\,F_{2n} = F_n \cdot L_n\,}$$

Read it slowly. The Fibonacci number at an *even* position $2n$ factors perfectly into the
Fibonacci number at position $n$ times the *Lucas* number at position $n$. For instance:

$$F_{10} = 55 = 5 \times 11 = F_5 \times L_5, \qquad F_{12} = 144 = 8 \times 18 = F_6 \times L_6.$$

This is the **doubling bridge**, and it is the load-bearing beam of the whole construction.
It tells us that the even-index Fibonacci numbers are quietly built out of Lucas numbers. If
we want to understand when a prime divides a Lucas number, we can instead ask when it divides
the *even-index Fibonacci number that the Lucas number helps build* — and the ideal-structure
theorem already answers that.

But there is a subtlety. When $p$ divides $F_{2n} = F_n \cdot L_n$, primality tells us $p$
divides $F_n$ *or* $p$ divides $L_n$ — but which one? To separate the two factors cleanly, we
need to know they don't overlap. That is the role of the next ingredient.

## Coprime cousins

Fibonacci and Lucas numbers at the same index almost never share a factor. The precise
statement, proved here, is:

$$\gcd(L_n, F_n) \ \big|\ 2.$$

Their greatest common divisor is always $1$ or $2$ — never more. The proof leans on a
gorgeous quadratic identity, also established from scratch, that ties the two sequences
together at every index:

$$L_n^{\,2} - 5\,F_n^{\,2} = 4 \cdot (-1)^n.$$

Try it: $L_5^2 - 5F_5^2 = 121 - 125 = -4 = 4 \cdot (-1)^5$, and
$L_6^2 - 5F_6^2 = 324 - 320 = 4 = 4 \cdot (-1)^6$. Any common divisor of $L_n$ and $F_n$ must
divide the left side, hence must divide $4$; a short parity argument trims this down to
dividing $2$.

The consequence is decisive. If $p$ is an **odd** prime, it cannot divide $2$, so it cannot
divide both $F_n$ and $L_n$ at once. The two factors of $F_{2n} = F_n \cdot L_n$ are, from an
odd prime's point of view, perfectly disjoint. Now we can finally untangle them.

## The marquee result

Put the pieces together. Let $p$ be an odd prime with Fibonacci entry point $r = \alpha(p)$.
We ask: when does $p \mid L_n$?

By the doubling bridge, $p \mid L_n$ certainly implies $p \mid F_{2n}$ (since $L_n$ is a
factor of $F_{2n}$). By the ideal-structure theorem, $p \mid F_{2n}$ means $r \mid 2n$.
Conversely, if $r \mid 2n$, then $p$ divides $F_{2n} = F_n \cdot L_n$, so it divides one of
the factors — and because the two are coprime for an odd prime, it divides *exactly* one. It
lands on $L_n$ precisely when it *misses* $F_n$, i.e. precisely when $r \nmid n$. This yields
the clean criterion:

$$\boxed{\,p \mid L_n \quad\Longleftrightarrow\quad r \mid 2n \ \text{ and } \ r \nmid n\,}$$

In plain language: **a prime divides the Lucas number $L_n$ exactly when its entry point
reaches the index only *after* doubling it.** The Lucas "apparition set" of an odd prime is
the set of indices the entry point can touch through $2n$ but not through $n$ alone.

Let's watch it work with $p = 7$, whose entry point is $r = 8$. The criterion says $7 \mid L_n$
iff $8 \mid 2n$ but $8 \nmid n$ — that is, $4 \mid n$ but $8 \nmid n$. So $n = 4, 12, 20, 28, \dots$:

$$L_4 = 7,\quad L_{12} = 322 = 7 \times 46,\quad L_{20} = 15127 = 7 \times 2161, \quad \dots$$

and indeed $7$ divides none of the Lucas numbers in between. The pattern is exact, and it was
predicted entirely from a single number — the Fibonacci entry point of $7$ — without ever
computing a Lucas number directly.

## Why this is satisfying

There is a particular kind of pleasure in number theory when two objects that look different
turn out to be two faces of one coin. The Fibonacci entry point was, for decades, told as a
*Fibonacci-only* story: it answered Fibonacci divisibility questions and powered Fibonacci
theorems. The doubling bridge reveals that the same entry point silently controls the Lucas
numbers too. One quantity, $\alpha(p)$, governs both worlds. The rank of apparition is not a
Fibonacci gadget after all — it is a two-sided object, and the criterion
$p \mid L_n \iff (r \mid 2n \wedge r \nmid n)$ is its Lucas face.

There is also a hidden pattern lurking in that criterion, visible once you think in terms of
*powers of two*. The condition "$r \mid 2n$ but $r \nmid n$" is really a statement about how
many factors of $2$ live inside $n$ versus inside $r$. If you write $r = 2^a \cdot s$ and
$n = 2^b \cdot t$ with $s$ and $t$ odd, the condition forces $b$ to equal exactly $a - 1$: the
index $n$ must carry one fewer factor of $2$ than the entry point does. Out of all the ways an
index could relate to the entry point, precisely one "two-adic layer" makes a prime divide the
Lucas number. The arithmetic that began with rabbits and sunflowers ends in a crisp statement
about binary digits.

## The wider view

The numbers in this story — Fibonacci, Lucas, entry points — are not idle decorations. They
sit at the foundation of how we understand the prime factors of recurrence sequences, a theme
that runs from Lucas's nineteenth-century primality tests (still used, in refined form, to
certify the enormous primes of modern cryptography) to Carmichael's primitive-divisor theorem
and beyond. Every time a result about Fibonacci numbers gets a Lucas companion, the theory
becomes more symmetric, more complete, and more powerful.

What began as a question a curious student might ask — *which Lucas numbers does $7$ divide?* —
turns out to have an answer of real elegance, assembled from a handful of classical identities:
the doubling bridge $F_{2n} = F_n L_n$, the quadratic law $L_n^2 - 5F_n^2 = 4(-1)^n$, the near-
coprimality $\gcd(L_n, F_n) \mid 2$, the pigeonhole guarantee that entry points exist at all,
and the ideal-structure theorem that organizes Fibonacci divisibility into clean arithmetic
progressions. Each is beautiful on its own. Together, they hand us the other half of the golden
sequence.
