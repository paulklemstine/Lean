# One Family of Number Systems, and a Fingerprint Hidden in the Fibonacci Sequence

## Two ways of writing numbers that turn out to be one

Every schoolchild learns to write numbers in base ten. The string $2026$ means
$2\cdot 10^3 + 0\cdot 10^2 + 2 \cdot 10^1 + 6\cdot 10^0$. Change the base to two,
and the same idea gives binary; change it to sixteen and you get the hexadecimal
of computer memory dumps. The recipe is always the same: pick a base $N$, allow
digits $0, 1, \dots, N-1$, and read a string of digits as a sum of powers of $N$.

But powers of a fixed base are not the only "place values" worth using. Consider
instead the **factorial number system**, sometimes called *factoradic*. Here the
place values are not $1, N, N^2, N^3, \dots$ but the factorials
$$0! = 1,\quad 1! = 1,\quad 2! = 2,\quad 3! = 6,\quad 4! = 24,\quad \dots$$
and the rule for digits changes too: the digit in the place worth $i!$ is allowed
to be anything from $0$ up to $i$ — no larger. So the units place ($0!$) always
holds a $0$, the next place ($1!$) holds $0$ or $1$, the next ($2!$) holds $0$,
$1$, or $2$, and so on. This strange-looking system is not a curiosity. It is
exactly the machinery behind *ranking permutations*: every reordering of a deck
of cards corresponds to one factoradic number, and counting through the
factoradics in order lists every shuffle exactly once. It is the arithmetic that
sits underneath the Lehmer code and the algorithms that generate permutations in
lexicographic order.

At first glance base-ten and factoradic look like different animals. One uses
powers, the other uses factorials; one caps digits at a constant $N-1$, the other
at a sliding bound $i$. The central idea of this work is that **they are two
instances of a single, more general number system**, and that once you see the
general system, all the good properties of each special case follow from one
theorem proved once.

## The general system: let the base change at every step

The unifying object is the **mixed-radix number system**. Instead of a single
base $N$, fix an entire *sequence* of bases $b_0, b_1, b_2, \dots$, one for each
position. The place value of position $i$ is no longer a power but a **running
product** of the earlier bases,
$$P_i \;=\; b_0\, b_1 \cdots b_{i-1} \;=\; \prod_{j<i} b_j,$$
with the convention that the empty product $P_0 = 1$. A string of digits
$c_0, c_1, \dots, c_{k-1}$ then denotes the number
$$\text{value} \;=\; \sum_{i<k} c_i \, P_i \;=\; c_0 P_0 + c_1 P_1 + \cdots + c_{k-1} P_{k-1},$$
and a digit string is called **valid** when each digit stays below its own local
base: $c_i < b_i$ for every position $i$.

Everyday life is full of mixed-radix systems even if nobody calls them that. Time
is one: seconds run $0$–$59$, minutes run $0$–$59$, hours run $0$–$23$, so the
bases are $60, 60, 24, \dots$. Old British currency, with its pennies, shillings,
and pounds, was another. The point of the mathematics is that all of these,
together with ordinary base-$N$ and factoradic, are governed by the same rules.

Two choices of the base sequence recover our two starting examples exactly:

- Take **every base equal to $N$**, i.e. $b_i = N$ for all $i$. Then the running
  product is $P_i = N^i$, the validity condition $c_i < N$ is the familiar
  digit rule, and the mixed-radix value is precisely the ordinary base-$N$
  numeral.
- Take the **base at position $i$ to be $i+1$**, i.e. $b_i = i+1$. Then the
  running product telescopes into a factorial,
  $$P_i \;=\; \prod_{j<i}(j+1) \;=\; 1\cdot 2 \cdots i \;=\; i!,$$
  and the validity condition $c_i < i+1$ is exactly the factoradic bound
  $c_i \le i$. This is the factorial number system, on the nose.

That single identity — that the running product of $1, 2, 3, \dots, i$ is the
factorial $i!$ — is the hinge on which the whole unification turns.

## The one theorem that does all the work

What makes a number system *usable* is that each number has exactly one valid
representation: no ambiguity, no wasted strings. For base ten this is the fact
that $2026$ and $02026$ aside, no two genuinely different digit strings name the
same number. The general statement is:

> **Uniqueness Theorem.** For any sequence of bases, if two valid digit strings
> of the same length have the same value, then they are identical digit for
> digit.

The proof is refreshingly elementary and, crucially, *uniform* — it never needs
to know which base sequence you chose. It rests on two observations. The first is
a **size bound**: a valid string of length $k$ can never reach the running
product $P_k$. Intuitively, even if every digit is as large as allowed, the total
$\sum_{i<k} c_i P_i$ with $c_i = b_i - 1$ telescopes to exactly $P_k - 1$, one
short of $P_k$. The second is a pair of **splitting identities**: given a valid
string of length $k+1$, dividing its value by the running product $P_k$ recovers
the top digit $c_k$, while taking the remainder recovers the value of the lower
$k$ digits. In symbols,
$$\text{value} \div P_k = c_k, \qquad \text{value} \bmod P_k = \text{(lower part)}.$$
These are exactly the operations of Euclidean division, and they peel off one
digit at a time. Feeding this into an induction, one shows that equal values
force equal top digits and equal lower parts, and the digits match all the way
down. No counting arguments, no bijections, no appeal to how many strings there
are — just arithmetic.

A companion **Existence Theorem** closes the loop: every number below $P_k$ *does*
arise from some valid length-$k$ string, obtained by the obvious extraction
$c_i = \lfloor n / P_i \rfloor \bmod b_i$. Together, uniqueness and existence say
that the valid length-$k$ strings are in perfect one-to-one correspondence with
the numbers $0, 1, \dots, P_k - 1$.

Because the theorem is proved once for a general base sequence, it *specializes
for free*. The classical uniqueness of factoradic representations — the fact that
underpins permutation ranking — is not proved separately here; it is read off as
the case $b_i = i+1$. The uniqueness of ordinary base-$N$ numerals is the case
$b_i = N$. One argument, two (and infinitely many more) classical corollaries.
The factorial system and standard positional notation are revealed as two points
in a single continuous family of "alien number systems."

A subtle but satisfying point: the derivation of the factoradic result from the
general one is genuinely a *reduction*, not a disguised restatement. The bridge
transports the general uniqueness theorem across the identity $P_i = i!$ and the
matching of the two validity conditions, and it never secretly reuses a
standalone factoradic proof. The generalization truly subsumes the special case.

## A fingerprint in the Fibonacci numbers

The second thread of this work lives in a very different corner of arithmetic:
the Fibonacci sequence
$$F_1 = 1,\ F_2 = 1,\ F_3 = 2,\ F_4 = 3,\ F_5 = 5,\ F_6 = 8,\ F_7 = 13,\ F_8 = 21,\ \dots,$$
each term the sum of the two before it. Fibonacci numbers are famous for their
divisibility magic: $F_m$ divides $F_n$ whenever $m$ divides $n$, and more
sharply, the greatest common divisor of $F_m$ and $F_n$ is $F_{\gcd(m,n)}$. This
last fact means the Fibonacci sequence mirrors the multiplicative structure of
the natural numbers with uncanny fidelity.

A prime number $p$ is called a **primitive prime divisor** of $F_n$ if $p$
divides $F_n$ but divides *no earlier* Fibonacci number $F_1, \dots, F_{n-1}$. In
other words, $p$ makes its very first appearance in the sequence at position $n$.
It is a kind of birthmark: a prime that marks $F_n$ as its point of entry into
the Fibonacci world. The question is whether every term (past the small,
exceptional cases) carries such a birthmark.

> **Fibonacci Primitive-Divisor Theorem (verified range).** For every $n$ with
> $13 \le n \le 10000$, the Fibonacci number $F_n$ has a primitive prime divisor:
> a prime $p$ that divides $F_n$ but divides none of $F_1, F_2, \dots, F_{n-1}$.

This is the Fibonacci case of a celebrated result of Carmichael from 1913, itself
a specialization of the Zsygmondy primitive-divisor theorem. The exceptions
below $13$ are real and instructive: $F_1 = F_2 = 1$ have no prime divisors at
all; $F_6 = 8 = 2^3$ contributes no *new* prime because $2$ already divided
$F_3 = 2$; and $F_{12} = 144 = 2^4 \cdot 3^2$ likewise recycles the primes $2$
and $3$ from earlier terms. Past $n = 12$, however, the birthmark always appears.

The engine behind the theorem is the notion of the **primitive part** of $F_n$:
the portion of $F_n$ left after dividing out every prime that already occurred in
an earlier Fibonacci number. Concretely, one starts with $F_n$ and, for each
proper divisor $d$ of $n$, strips away all common factors with $F_d$. Because
$\gcd(F_n, F_d) = F_{\gcd(n,d)}$, this cleanly removes exactly the "old" part of
$F_n$. If what remains exceeds $1$, then whatever prime survives must be brand
new — a primitive divisor. The whole difficulty of the theorem is showing that
this leftover primitive part is genuinely bigger than $1$; equivalently, that
$F_n$ is not built entirely from recycled primes.

For $13 \le n \le 10000$ this can be checked head-on: compute each primitive part
and confirm it exceeds $1$. That is what the verified statement above rests on —
an exhaustive, exact integer computation across the whole range, combined with a
bridge lemma that turns "no proper divisor of $n$ shares the surviving prime"
into the full primitivity condition "no earlier term at all shares it."

The unbounded statement — that the birthmark persists for *every* $n > 12$,
forever — is true and classical, but its complete proof needs a quantitative
lower bound on the primitive part that comes from evaluating a cyclotomic
polynomial at the golden ratio. That growth estimate is the one missing gear, and
it marks the natural frontier for extending the result beyond any finite range.
The honest, fully established claim is the one above: across the first ten
thousand positions past the exceptional zone, no Fibonacci number is a mere echo
of its predecessors. Each one announces itself with a prime of its own.

## Why this matters

The two results share a moral. In the numeration story, a single well-chosen
generalization — letting the base vary from digit to digit — dissolves the
apparent gap between counting in tens and counting in factorials, and turns a
handful of separate uniqueness theorems into corollaries of one. In the Fibonacci
story, a single structural idea — peeling away recycled primes to expose a
primitive part — turns a statement about "first appearances" into a concrete,
checkable computation.

Both are small monuments to a recurring pleasure in mathematics: the moment when
several things you thought were different snap into focus as one thing seen from
different angles. A clock, a factoradic permutation code, and a binary memory
address are the same kind of object. And ten thousand Fibonacci numbers, however
tangled their factorizations, each still manage to carry a signature that is
theirs alone.
