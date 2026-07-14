# The Arithmetic of Changing Bases

## How clocks, calendars, factorials, and computer addresses share one positional language

Most of us learn positional notation through a system that never changes its mind. In decimal, every position has ten choices. A digit in one column is worth ten times the same digit in the column to its right. This regularity is so familiar that it can feel inseparable from the idea of a number system.

But daily life is full of numerals whose bases change from position to position. A clock counts $60$ seconds to a minute, $60$ minutes to an hour, and $24$ hours to a day. A calendar mixes weeks, months, and years. Some algorithms index permutations using columns whose capacities are $1,2,3,4,\ldots$. Memory layouts, tensor coordinates, and nested counters use yet other sequences.

All of these are **mixed-radix systems**. Beneath their irregular surfaces lies a remarkably clean arithmetic. It explains why valid digit strings are unique, gives a direct formula for extracting every digit, identifies exactly when addition needs no carrying, and shows that the digits already extracted never change when we ask for a longer representation.

The central surprise is that the right object is not the list of local bases by itself. It is the sequence of cumulative capacities—the running products.

## A staircase of place values

Choose a sequence of nonnegative integer bases

$$
b_0,b_1,b_2,\ldots.
$$

Define the running products by

$$
P_0=1,\qquad P_k=\prod_{j<k}b_j.
$$

Thus $P_{k+1}=P_kb_k$. The number $P_i$ is the place value of position $i$. A length-$k$ digit string $c_0,\ldots,c_{k-1}$ has value

$$
V_k(c)=\sum_{i<k}c_iP_i.
$$

It is valid when

$$
0\le c_i<b_i\qquad (i<k).
$$

For a clock-like system with bases $60,60,24$, the place values are $1,60,3600$, so the digits naturally count seconds, minutes, and hours. For the factorial system, choose $b_i=i+1$. Then

$$
P_i=1\cdot2\cdots i=i!,
$$

and validity becomes $c_i\le i$. The familiar factoradic expansion is therefore not a separate trick: it is one point in the mixed-radix landscape.

A useful interpretation is that $P_k$ is the capacity of the first $k$ positions. When the bases are positive, every valid length-$k$ numeral lies between $0$ and $P_k-1$. More strongly, every integer in that interval appears exactly once.

## The universal representation theorem

**Universal Mixed-Radix Representation Theorem.** For any sequence of nonnegative integer bases and any length $k$, two valid length-$k$ digit strings with the same value agree in every position. Every integer $n$ with $0\le n<P_k$ has a valid representation, obtained from

$$
d_i(n)=\left\lfloor\frac{n}{P_i}\right\rfloor\bmod b_i.
$$

Consequently, when valid strings exist, evaluation gives a one-to-one correspondence between valid length-$k$ strings and the integers from $0$ through $P_k-1$.

The proof is a repeated version of ordinary quotient-and-remainder arithmetic. Split the top position from the lower positions:

$$
V_{k+1}(c)=V_k(c)+c_kP_k.
$$

Validity forces $V_k(c)<P_k$. Dividing by $P_k$ therefore discards the lower block and exposes the top digit:

$$
\left\lfloor\frac{V_{k+1}(c)}{P_k}\right\rfloor=c_k.
$$

If two valid strings have equal values, their top digits are equal. Subtracting the common top contribution leaves equal lower values, and the argument repeats downward. This proves uniqueness. Conversely, quotient and remainder at each place yield the extraction formula.

Even a zero base does not require an artificial exception. If $b_i=0$, no natural-number digit can satisfy $c_i<0$, so any length reaching that position has no valid strings. The theorem remains logically correct: the apparently degenerate case empties the representation space rather than corrupting uniqueness.

## A master identity for truncation

Digit extraction is often presented as an algorithm tied to a chosen word length. Here it has a stronger character. The formula for $d_i(n)$ mentions only $n$, $P_i$, and $b_i$; it does not mention a terminal length.

This locality produces the central reconstruction law.

**Truncated Reconstruction Theorem.** For every natural number $n$ and every length $k$,

$$
\sum_{i<k}d_i(n)P_i=n\bmod P_k.
$$

In words, evaluating the first $k$ extracted digits gives exactly the remainder of $n$ after division by the capacity of those positions.

The mechanism is a telescoping Euclidean decomposition. At each stage,

$$
\left\lfloor\frac{n}{P_i}\right\rfloor
=b_i\left\lfloor\frac{n}{P_{i+1}}\right\rfloor+d_i(n).
$$

After multiplying by $P_i$, the quotient term becomes a multiple of $P_{i+1}$. Summing these identities cancels the intermediate quotients, leaving

$$
n=\sum_{i<k}d_i(n)P_i+
\left\lfloor\frac{n}{P_k}\right\rfloor P_k.
$$

The first term is therefore $n\bmod P_k$.

This is more than a reconstruction recipe. It says a finite display is the exact low-capacity shadow of an integer. A three-field clock does not merely show an approximation to elapsed seconds; it shows the residue modulo the clock’s total cycle.

## Digits that do not move

Since $P_{i+1}$ divides every later running product $P_k$ whenever $i<k$, reducing a number modulo a later capacity cannot change its residue modulo the earlier capacity. That observation yields a stability law.

**Length-Independent Normal Form Theorem.** If $i<k$, then

$$
d_i(n\bmod P_k)=d_i(n).
$$

In particular,

$$
d_i(n\bmod P_{i+1})=d_i(n).
$$

Thus extending a representation from $k$ positions to $k+1$ positions never revises any digit already computed. The infinite stream

$$
d_0(n),d_1(n),d_2(n),\ldots
$$

is a canonical object, and every finite representation is simply its prefix.

This matters in streaming computation. Imagine an encoder that initially allocates only enough positions for a small range, then grows as needed. A poor numeral scheme might require rewriting old data when its horizon expands. Mixed-radix extraction does not. Earlier digits depend only on earlier cumulative capacities, so they are stable under lengthening.

The same principle appears in multidimensional indexing. If a data array has axis lengths $b_0,b_1,\ldots$, then a linear address $n$ converts to coordinates by the same formula $d_i(n)$. Adding an outer axis does not alter the coordinates on existing inner axes. This is exactly the normal-form theorem in computational clothing.

## Addition before carrying

Carrying can make positional arithmetic seem nonlinear, but evaluation itself is perfectly linear. For any two digit lists $c$ and $e$,

$$
V_k(c+e)=V_k(c)+V_k(e),
$$

where $(c+e)_i=c_i+e_i$. This identity needs no validity assumption. It is simply distributivity inside the weighted sum.

The only question is whether the pointwise sum is still a legal numeral.

**Carry-Free Addition Theorem.** Suppose

$$
c_i+e_i<b_i\qquad (i<k).
$$

Then the extracted digits of the numerical sum are exactly the pointwise sums:

$$
d_i\bigl(V_k(c)+V_k(e)\bigr)=c_i+e_i
\qquad (i<k).
$$

The proof has two steps. Linearity identifies the numerical sum with $V_k(c+e)$. The strict inequalities make $c+e$ valid. The uniqueness theorem then says that extracting digits from this value must recover $c+e$ itself.

Conversely, a position with

$$
b_i\le c_i+e_i
$$

is precisely a position where the raw pointwise sum is not a valid digit. That is the local signature of a forced carry. Notice the careful scope: the theorem completely characterizes additions with no carries anywhere in the chosen block. A full theory of interacting carry chains asks further questions about how overflow propagates across positions.

Consider bases $(10,6,4)$ and digit strings $(7,2,1)$ and $(2,3,1)$. Their pointwise sum is $(9,5,2)$, valid because $9<10$, $5<6$, and $2<4$. The values are

$$
7+2\cdot10+1\cdot60=87
$$

and

$$
2+3\cdot10+1\cdot60=92.
$$

Their sum is $179$, while $(9,5,2)$ evaluates to

$$
9+5\cdot10+2\cdot60=179.
$$

No normalization is needed. But replacing the first digits by $8$ and $5$ creates $13\ge10$, so position $0$ cannot remain as written; a carry is unavoidable.

## One language, many machines

The factorial number system illustrates the unifying power of the framework. Setting $b_i=i+1$ gives $P_i=i!$, so

$$
V_k(c)=\sum_{i<k}c_i i!,\qquad 0\le c_i\le i.
$$

Uniqueness is no longer a special factorial phenomenon. It follows from the same top-digit division used for clocks and array coordinates. Factoradics are important because they encode permutation ranks, but their arithmetic belongs to a much broader family.

Mixed-radix systems also model nested cyclic processes: counters in simulations, schedules with heterogeneous periods, conversion among units, and hierarchical storage layouts. The reconstruction theorem says that the low-order state of such a process is a residue modulo its cumulative cycle. The stability theorem says this state survives the addition of higher levels. The carry-free theorem tells us when two states may be combined coordinate by coordinate without a normalization pass.

These results separate three ideas that ordinary decimal notation tends to blur. **Evaluation** is a linear weighted sum. **Validity** is a collection of local inequalities. **Normalization** is the process of turning an arbitrary coefficient list into the unique valid list with the same residue. Once separated, the theory becomes modular and reusable.

## The horizon beyond finite strings

Several natural problems now come into focus. One is a complete theory of carry patterns: how local overflows propagate, and when two different base sequences produce the same carries over a fixed interval. Another is to characterize digit-sum congruences in systems where the bases vary.

The length-independent digit stream points farther still. The residues

$$
n\bmod P_1,\quad n\bmod P_2,\quad n\bmod P_3,\ldots
$$

are compatible because each earlier modulus divides each later one. Such compatible towers are the raw material of completion theories analogous to $p$-adic numbers. Constant base $p$ produces the familiar powers $p^k$; arbitrary running products suggest a flexible family of mixed-radix completions.

The deepest lesson is elementary. A positional system does not need a constant base to have exact arithmetic. It needs a divisibility staircase of place values, quotient-and-remainder extraction, and local digit bounds. From those ingredients come uniqueness, reconstruction, stable prefixes, and a transparent criterion for carry-free addition.

Decimal notation is only the most uniform member of this family. Clocks, factorials, coordinates, and nested counters are not awkward exceptions. They are all expressions of the same arithmetic architecture.