# The Staircase in Pascal's Triangle That Counts Like Fibonacci

## A secret path through a familiar landscape

Almost everyone meets Pascal's triangle early. You start with a $1$ at the top,
and every number below is the sum of the two numbers above it. Out tumble the
binomial coefficients $\binom{n}{k}$ — the counts that tell you how many ways
you can choose $k$ things from $n$. The triangle is so orderly, so endlessly
re-explored, that it can feel like there is nothing left to find in it.

There is always something left to find.

This is the story of a particular *staircase* you can walk through Pascal's
triangle. Instead of reading a row straight across, you take a measured,
diagonal climb: one step down, two steps over; one step down, two steps over.
Add up the numbers you land on, and something startling happens. The totals are
not random. They are the Fibonacci numbers — but not all of them. They are
exactly the Fibonacci numbers sitting at *odd* positions: $1, 2, 5, 13, 34, 89,
233, \dots$

The headline result, proved rigorously, is the clean identity

$$\sum_{k=0}^{n}\binom{n+k}{2k} = F_{2n+1},$$

where $F_m$ is the $m$-th Fibonacci number (with the usual convention
$F_0 = 0$, $F_1 = 1$, $F_2 = 1$, $F_3 = 2$, and so on). The left side is a sum
of binomial coefficients — pure Pascal's triangle. The right side is a single
Fibonacci number. Two of the most famous objects in all of mathematics, sitting
on opposite ends of an equals sign.

## What the sum actually says

Let us make the staircase concrete. Fix a row number $n$. Now form the sum

$$A(n) = \binom{n+0}{0} + \binom{n+1}{2} + \binom{n+2}{4} + \binom{n+3}{6} + \cdots$$

In each term the *top* of the binomial coefficient grows by one and the
*bottom* grows by two. That is the "one down, two over" rhythm. The sum stops
on its own: once $2k$ exceeds $n+k$, the binomial coefficient is zero, so only
finitely many terms survive (the terms with $k$ from $0$ up to $n$).

Take $n = 2$:

$$A(2) = \binom{2}{0} + \binom{3}{2} + \binom{4}{4} = 1 + 3 + 1 = 5.$$

And indeed $5 = F_5$. Take $n = 3$:

$$A(3) = \binom{3}{0} + \binom{4}{2} + \binom{5}{4} + \binom{6}{6} = 1 + 6 + 5 + 1 = 13 = F_7.$$

The pattern marches on without a single exception:

| $n$ | the staircase sum $A(n)$ | which Fibonacci number |
|----:|----:|:----|
| $0$ | $1$   | $F_1$ |
| $1$ | $2$   | $F_3$ |
| $2$ | $5$   | $F_5$ |
| $3$ | $13$  | $F_7$ |
| $4$ | $34$  | $F_9$ |
| $5$ | $89$  | $F_{11}$ |
| $6$ | $233$ | $F_{13}$ |
| $7$ | $610$ | $F_{15}$ |

The odd-indexed Fibonacci numbers, in perfect order. This is the theorem named
`pascalRiordanA_eq_fib` in the formal development behind this article.

## Why on earth should this be true?

A clean fact deserves a clean reason. The reason here is a beautiful piece of
bookkeeping, and the secret is to *not* study the staircase alone. You study it
together with a slightly shifted twin.

Define the twin sum by sliding the bottom index up by one:

$$B(n) = \binom{n+0}{1} + \binom{n+1}{3} + \binom{n+2}{5} + \cdots
       = \sum_{k=0}^{n}\binom{n+k}{2k+1}.$$

This is the same staircase, but landing on the *odd* lower indices instead of
the even ones. Its values are the *even*-indexed Fibonacci numbers:

$$B(0)=0,\quad B(1)=1,\quad B(2)=3,\quad B(3)=8,\quad B(4)=21,\quad B(5)=55,\dots$$

that is, $B(n) = F_{2n}$ (the companion theorem, `pascalRiordanB_eq_fib`).

Now watch how the two sums talk to each other. The whole engine is the single
defining rule of Pascal's triangle, the rule every schoolchild learns:

$$\binom{m+1}{r} = \binom{m}{r-1} + \binom{m}{r}.$$

Apply this rule term by term to the twin sum $B$, and the dust settles into a
remarkably simple statement:

$$B(n+1) = A(n) + B(n).$$

In words: to grow the odd-landing staircase by one level, add the previous
even-landing staircase to the previous odd-landing one. This is the lemma
`pascalRiordanB_succ`, and it is a *pure* Pascal step — nothing but the
schoolbook rule, applied carefully.

Apply Pascal's rule once more, this time to the even-landing sum $A$, and a
second relation appears:

$$A(n+1) = A(n) + B(n+1).$$

This is the lemma `pascalRiordanA_succ`. Together the two relations form a
tiny, self-contained machine:

$$B(n+1) = A(n) + B(n), \qquad A(n+1) = A(n) + B(n+1).$$

Start it up with $A(0) = 1$ and $B(0) = 0$ and turn the crank:

- $B(1) = A(0) + B(0) = 1$, then $A(1) = A(0) + B(1) = 2$.
- $B(2) = A(1) + B(1) = 3$, then $A(2) = A(1) + B(2) = 5$.
- $B(3) = A(2) + B(2) = 8$, then $A(3) = A(2) + B(3) = 13$.

Set this side by side with how the Fibonacci numbers themselves are generated —
each one the sum of the two before it — and the two processes are revealed to be
the very same dance, merely renamed. The coupled machine *is* the Fibonacci
recurrence, split into its even and odd halves. That is the heart of the proof,
captured formally in the lemma `pascalRiordan_pair`, which establishes both
closed forms — $A(n) = F_{2n+1}$ and $B(n) = F_{2n}$ — in one simultaneous
induction.

## The fingerprint: a recurrence of its own

Once you know the two halves interlock, you can eliminate the twin entirely and
let the staircase sum stand on its own legs. The result is a self-referential
rule that never mentions Fibonacci, never mentions binomials, and never mentions
the twin:

$$A(n+2) = 3\,A(n+1) - A(n).$$

This is the theorem `pascalRiordan_three_term`. Check it against the table:
$3 \cdot 5 - 2 = 13$; $3 \cdot 13 - 5 = 34$; $3 \cdot 34 - 13 = 89$. Every step
lands on the next entry. This "multiply by three, subtract the one before"
pattern is the unmistakable fingerprint of the odd-indexed Fibonacci numbers.
They satisfy it because the full Fibonacci sequence does: stepping two indices
at a time turns the familiar "add the previous two" into exactly this "triple
minus one back."

There is a deeper reason this particular recurrence appears, and it connects to
a piece of classical mathematics called a *generating function*. If you encode
the whole infinite sequence $A(0), A(1), A(2), \dots$ into a single power series

$$G(x) = A(0) + A(1)\,x + A(2)\,x^2 + A(3)\,x^3 + \cdots,$$

then the recurrence $A(n+2) = 3A(n+1) - A(n)$ is exactly the algebraic
statement that

$$G(x) = \frac{1 - x}{1 - 3x + x^2}.$$

The denominator $1 - 3x + x^2$ is the algebraic echo of the coefficients in
"$3 \cdot (\text{previous}) - 1 \cdot (\text{the one before})$." This rational
function is a known signature of the odd-indexed Fibonacci sequence, and it is
the analytic shadow cast by the combinatorial fact we proved.

## Riordan arrays: the machine behind the curtain

Why did this particular staircase — one down, two over — behave so well? The
honest answer is that it was not chosen at random. It is a single column read
out of a structured object called a **Riordan array**.

A Riordan array is a way of building an infinite triangle of numbers from a pair
of power series. You pick a "seed" series and a "multiplier" series, and the
array's columns are successive products. The array in our story is built from
the pair

$$\left(\frac{1}{1-x}, \ \frac{x}{(1-x)^2}\right),$$

and a direct computation shows its entry in row $n$, column $k$ is precisely

$$t_{n,k} = \binom{n+k}{2k}.$$

So the staircase sum $A(n)$ is nothing other than the *sum of an entire row* of
this Riordan array. Riordan arrays are prized exactly because their rows,
columns, and diagonals have predictable generating functions; the Fibonacci
identity is what falls out when you sum a row of this especially elegant one.
The array itself is catalogued in the Online Encyclopedia of Integer Sequences
as A085478, and its odd-indexed-Fibonacci row sums as A001519 — independent
confirmation that the path we walked is a well-trodden landmark, now pinned down
with full rigor.

## Why a small identity matters

It is tempting to file a result like this under "cute" and move on. That would
be a mistake, for three reasons.

First, **it is a bridge.** Binomial coefficients are the language of counting:
committees, lattice paths, coin flips. Fibonacci numbers are the language of
growth: rabbit populations, phyllotaxis in sunflowers, the proportions that
recur in art and architecture. An exact identity between them means that any
counting problem whose answer is this staircase sum *is secretly a growth
problem*, and vice versa. Bridges like this are how one field's hard question
becomes another field's easy one.

Second, **it is a template.** The proof technique — refuse to study one sequence
in isolation, pair it with a shifted twin, and let Pascal's rule couple them —
is a reusable strategy. The same "one down, two over" idea generalizes to "one
down, $m$ over," and the expectation is that those staircases obey their own
fixed recurrences of higher order, opening a whole family of identities relating
binomial diagonals to Fibonacci-like and Chebyshev-like sequences.

Third, **it is now certain.** Patterns that hold for the first eight, or eighty,
or eight thousand cases can still fail. Mathematics is littered with conjectures
that looked ironclad until a giant counterexample appeared. The identity here is
not "checked"; it is *proved*, by an induction that covers every natural number
$n$ at once. The table above is no longer a list of coincidences. It is a
guarantee, valid forever.

## The view from the top of the staircase

Step back and look at what just happened. We took the most over-studied object
in elementary mathematics, walked through it on a gentle diagonal, added up what
we found, and discovered the Fibonacci numbers hiding in plain sight — every
other one of them, in perfect order. We explained it not with heavy machinery
but with the single rule that defines Pascal's triangle, applied to a pair of
sums that hold hands and grow together. And we distilled the whole phenomenon
into one self-contained law, $A(n+2) = 3A(n+1) - A(n)$, whose generating
function $(1-x)/(1-3x+x^2)$ is the odd-Fibonacci sequence's calling card.

Pascal's triangle and the Fibonacci numbers were never strangers. The staircase
was always there, waiting for someone to climb it. The pleasure of mathematics
is that there is always another staircase — and that, once in a while, you can
prove exactly where it leads.
