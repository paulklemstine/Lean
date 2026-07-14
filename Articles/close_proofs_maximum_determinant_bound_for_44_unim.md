# One Theory of Counting: How the Factorial Number System Is Just a Base in Disguise

## A tale of two ways to write a number

Every child learns to write numbers the same way. The string $2025$ means
$2\cdot 10^3 + 0\cdot 10^2 + 2\cdot 10 + 5$. The trick is *place value*: each
position carries a weight, and here the weights are the powers of ten —
$1, 10, 100, 1000, \dots$. Computers do the same thing with weights that are
powers of two. Base sixty survives in our clocks. But there is nothing sacred
about a *constant* base. What if the weight of each position were allowed to
grow as you move to the left?

That single relaxation opens the door to the **mixed-radix number systems** —
positional systems in which every column can have its own base. And hiding
inside that family, it turns out, is one of the most elegant number systems in
all of combinatorics: the **factorial number system**, or *factoradic*, whose
place values are not $1, 10, 100, \dots$ but the factorials $1, 1, 2, 6, 24,
120, \dots$.

This article is about a clean, complete proof that these two ideas are, quite
literally, *the same idea*. The factorial number system is not merely *analogous*
to a positional system — it *is* a positional system, the one you get by choosing
the base of column $i$ to be exactly $i+1$. Once you see this, every good property
of counting in bases — that each number has one and only one representation —
falls out of a single general theorem, and the factorial system inherits it for
free.

## Mixed-radix: letting the base drift

Fix an infinite sequence of **bases** $b_0, b_1, b_2, \dots$, each a positive
whole number. The *place value* of column $i$ is the running product of all the
bases to its right,
$$
P_i \;=\; b_0 \cdot b_1 \cdots b_{i-1} \;=\; \prod_{j<i} b_j,
$$
with the convention $P_0 = 1$ (an empty product). A string of **digits**
$c_0, c_1, \dots, c_{k-1}$ then names the number
$$
\text{value}(b, c, k) \;=\; \sum_{i<k} c_i \, P_i.
$$
For this to behave like honest counting we impose one rule, the **validity**
condition: each digit must be smaller than its own local base,
$$
0 \le c_i < b_i \qquad \text{for every } i<k.
$$

Two familiar systems are instantly recovered:

- **Ordinary base $N$.** Take every base equal to $N$, so $b_i = N$. Then the
  running product is $P_i = N^i$, and the validity condition is the usual "each
  digit is one of $0,1,\dots,N-1$." This is decimal, binary, hexadecimal —
  all of them.
- **The factorial system.** Take $b_i = i+1$, so the bases are $1, 2, 3, 4,
  \dots$. Then the running product telescopes into a factorial,
  $$
  P_i \;=\; 1\cdot 2 \cdots i \;=\; i!,
  $$
  and the validity condition $c_i < i+1$ says exactly $0 \le c_i \le i$. The
  first digit is always $0$; the next is $0$ or $1$; the next is $0,1,2$; and so
  on. That widening staircase of allowed digits is the signature of the
  factoradic.

So the two most important positional systems in mathematics are just two points
in one continuous family, distinguished only by which sequence of bases you feed
in.

## The one property that matters: uniqueness

The reason place-value systems are useful is that they are *unambiguous*. In
decimal, $2025$ names one number, and one number is named by one string of
digits (ignoring leading zeros). If representations could collide, arithmetic
would be chaos. So the central theorem of any positional system is:

> **Uniqueness.** If two valid digit strings of the same length name the same
> number, then they are identical digit-for-digit.

Here is the beautiful part. This theorem is true for *arbitrary* mixed-radix
bases, and its proof needs almost nothing — no counting arguments, no
appeals to how many numbers there are, no clever bijections. It rests on two
small observations and an induction.

**First observation — the size bound.** A valid length-$k$ string can never
reach the running product $P_k$; it always stays strictly below it:
$$
\text{value}(b, c, k) \;<\; P_k \;=\; \prod_{i<k} b_i.
$$
The reason is a one-line induction. The largest digit in the top column is
$b_{k-1}-1$, contributing at most $(b_{k-1}-1)P_{k-1}$, and everything below it
already fits under $P_{k-1}$ by the inductive hypothesis. Adding these gives at
most $P_{k-1} + (b_{k-1}-1)P_{k-1} = b_{k-1}P_{k-1} = P_k$, and the strict
inequality survives. Intuitively: a full odometer of length $k$ rolls over
exactly at $P_k$.

**Second observation — splitting off the top digit.** Because every lower column
has weight below $P_{k-1}$, the top digit and the rest live in separate scales.
Dividing the value by $P_{k-1}$ and rounding down peels off exactly the top
digit,
$$
\left\lfloor \text{value}(b, c, k)/P_{k-1}\right\rfloor = c_{k-1},
$$
while the remainder mod $P_{k-1}$ is precisely the value of the shorter string
$c_0,\dots,c_{k-2}$. Division and remainder cleanly separate "the leading digit"
from "everything else."

**The induction.** Now suppose two valid strings $c$ and $d$ of length $k$ name
the same number. Dividing by $P_{k-1}$ shows their top digits agree: $c_{k-1} =
d_{k-1}$. Taking the remainder shows the two shorter strings also name the same
number, and by induction they agree everywhere below. Hence $c$ and $d$ are
identical. Uniqueness proved — for *every* choice of positive bases at once.

There is even a companion **existence** theorem, proved just as cleanly: every
number $n$ below the running product $P_k$ *does* have a valid length-$k$
representation, obtained by the greedy extraction $c_i = \lfloor n/P_i\rfloor \bmod
b_i$. Together, uniqueness and existence say that mixed-radix strings of length
$k$ are in perfect one-to-one correspondence with the integers $0,1,\dots,P_k-1$.

## The bridge: three short theorems

To pin the factorial system down as a special case, we need only verify that the
factoradic definitions really *are* the mixed-radix definitions at $b_i = i+1$.
That is the content of three bridge results.

**Theorem 1 (Place values agree).** For the base sequence $b_i = i+1$, the
mixed-radix value of any digit string equals its factoradic value:
$$
\text{value}\big((i{+}1),\, c,\, k\big) \;=\; \sum_{i<k} c_i \, i!.
$$
The whole proof is the running-product identity $\prod_{j<i}(j+1) = i!$, applied
column by column.

**Theorem 2 (Validity agrees).** The mixed-radix rule $c_i < i+1$ and the
factoradic rule $c_i \le i$ are the *same* constraint on whole numbers, because
$c_i < i+1$ and $c_i \le i$ say identical things about a natural number.

**Theorem 3 (Uniqueness, inherited).** Because both the values and the validity
conditions coincide, the general mixed-radix uniqueness theorem applies verbatim
to the factorial system. Every number below $k!$ has exactly one valid factoradic
string of length $k$, and this is now a *corollary* of the general theorem rather
than a separately proved fact.

The payoff is conceptual economy. One theorem, proved once for an arbitrary drift
of bases, simultaneously governs decimal, binary, the factorial system, and every
exotic "alien number system" in between.

## Why the factorial system earns its keep

The factoradic is not a curiosity. Its digit strings of length $k$ biject with
$0,1,\dots,k!-1$ — and $k!$ is exactly the number of ways to arrange $k$ objects.
This is no accident. There is a classical dictionary, the *Lehmer code*, that
turns each factoradic string into a permutation: the digit $c_i$ records how many
of the still-unused symbols you skip when choosing the next one. Under this
dictionary, counting in factoradic *is* listing permutations in lexicographic
order. Want the millionth permutation of ten objects without generating the first
$999{,}999$? Write $1{,}000{,}000$ in factoradic and read off the Lehmer code.
This is how algorithms "unrank" permutations in the blink of an eye.

The mixed-radix viewpoint also explains a subtle boundary case with grace. What
if some base were $0$? Then *no* digit could satisfy $c_i < 0$, so there would be
no valid strings using that column at all — the system simply has nothing to say
there, and every theorem about valid representations holds without exception,
vacuously. And at length zero, the empty string names $0$ in every system at once;
that is the shared origin from which all the towers of place values grow.

## The bigger picture

What makes this story satisfying is that it replaces a pile of look-alike facts
with one structural insight. We tend to teach base ten, base two, and the
factorial system as separate islands, each with its own uniqueness proof, its own
folklore. But they are governed by a single mechanism: a running product of bases,
digits capped below each local base, and an odometer that rolls over exactly at
the product. Uniqueness is not a feature of tens, or twos, or factorials — it is a
feature of *place value itself*, and it survives any drift in the bases so long
as each stays positive.

Seen this way, the factorial number system is not an oddity smuggled in from
combinatorics. It is what you get when you let the base grow by one at every step
— an entirely natural inhabitant of the same universe as the decimals on your
receipts. Counting, in all its guises, is one theory.
