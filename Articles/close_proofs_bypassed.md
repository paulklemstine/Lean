# New Prime Footprints in Fibonacci Numbers—and the Hidden Unity of Numeral Systems

## Two stories about what survives

Mathematics often advances by asking what remains after familiar structure has been removed. Strip an image down to its edges and a shape emerges. Cancel the repeated notes in a melody and its motif becomes audible. Remove every inherited prime factor from a Fibonacci number and, remarkably often, a genuinely new prime remains.

That first idea leads to a concrete theorem about the Fibonacci sequence. The second story in this article concerns positional notation: once the accidental features of decimal notation are removed, ordinary bases, clocks, calendars, and factorial numerals all become instances of one mixed-radix design. Their common architecture explains not only how to evaluate digit strings but why valid representations are unique.

The two subjects are different, yet their proofs share a philosophy. Define the reusable part of a structure, isolate the residue that carries new information, and prove that the residue cannot imitate anything earlier.

## A prime that appears for the first time

The Fibonacci sequence begins

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

Thus its first terms are $0,1,1,2,3,5,8,13,21,34,55,89,\ldots$.
A **primitive prime divisor** of $F_n$ is a prime $p$ such that $p\mid F_n$ but

$$
p\nmid F_k\qquad\text{for every }1\le k<n.
$$

The word “primitive” refers to the index, not to the size of the prime. The prime $p$ is making its first appearance as a divisor of a positive-index Fibonacci number at exactly time $n$.

For example, $F_{14}=377=13\cdot29$. The prime $13$ is not new: it already divides $F_7=13$. But $29$ divides none of $F_1,\ldots,F_{13}$, so $29$ is primitive at index $14$. Likewise,

$$
F_{15}=610=2\cdot5\cdot61,
$$

and $61$ is the new arrival.

The central result is a certified finite-range form of the primitive-divisor phenomenon:

> **Primitive Divisor Theorem on the Certified Interval.** For every integer $n$ with $13\le n\le 10{,}000$, there exists a prime $p$ dividing $F_n$ that divides no $F_k$ with $1\le k<n$.

The upper endpoint matters. The theorem says exactly what has been established: a structural argument coupled to an exhaustive finite certificate covers the entire interval, but it does not by itself prove the unbounded tail beyond $10{,}000$.

## Why checking all earlier terms is unnecessary

At first glance, testing whether $p$ is primitive at index $n$ seems to require comparing $F_n$ with every earlier Fibonacci number. The decisive simplification comes from the **strong divisibility identity**

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

Suppose $p$ divides both $F_n$ and some earlier $F_k$. Then $p$ divides their greatest common divisor, hence

$$
p\mid F_{\gcd(n,k)}.
$$

Because $1\le k<n$, the integer $d=\gcd(n,k)$ is a positive proper divisor of $n$. This proves the following bridge principle.

> **Proper-Divisor Reduction.** If a prime $p$ divides $F_n$ but divides no $F_d$ for any positive proper divisor $d$ of $n$, then $p$ is a primitive prime divisor of $F_n$.

This is a dramatic compression. Instead of inspecting all $n-1$ earlier indices, one need only inspect the divisor lattice of $n$. For a large integer with few divisors, that can be an enormous saving.

## Stripping away inherited factors

The reduction suggests an algorithm. Begin with $R=F_n$. For each positive proper divisor $d$ of $n$, repeatedly replace $R$ by

$$
R\leftarrow \frac{R}{\gcd(R,F_d)}
$$

until $\gcd(R,F_d)=1$. After all proper divisors have been processed, call the result $P_n$, the **divisor-stripped primitive part** of $F_n$.

Two properties are built into this construction. First, $P_n$ divides $F_n$. Second, $P_n$ is coprime to every $F_d$ with $d$ a positive proper divisor of $n$. Consequently, if $P_n>1$, its least prime factor $p$ divides $F_n$ but none of those divisor-indexed terms. The proper-divisor reduction then makes $p$ primitive.

> **Primitive-Part Criterion.** If $P_n>1$, then the least prime factor of $P_n$ is a primitive prime divisor of $F_n$.

For composite $n$ in the range $13\le n\le10{,}000$, an exhaustive exact-integer evaluation shows $P_n>1$. For prime indices in the same interval, the corresponding prime-index structural result supplies a primitive divisor directly. Together these two branches prove the certified-interval theorem.

The method is more than a table of factorizations. It separates the reasoning into a universal mathematical engine and a bounded calculation. Strong divisibility explains why proper divisors suffice. Repeated greatest-common-divisor stripping guarantees that every inherited factor is removed, even when it occurs to a high power. The least-prime-factor argument extracts a witness. The finite certificate only has to establish the clean numerical inequality $P_n>1$.

## A practical fingerprint for recurrence sequences

A useful way to picture the process is as arithmetic archaeology. Each proper divisor $d$ marks an earlier structural layer inside $F_n$. The stripping procedure brushes away every prime power attached to those layers without needing to identify the primes one by one. If a residue survives, it cannot belong to any divisor-indexed layer. Strong divisibility then says it cannot belong to any earlier layer at all. The residue is therefore not merely unexplained; it is certified new.

This distinction matters computationally. Factoring a large Fibonacci number can be difficult, whereas computing greatest common divisors is comparatively efficient. The method delays factorization until after inherited material has been removed, and even then only one prime factor of the surviving residue is needed. It converts a potentially expensive historical search into a sequence of exact, structured cancellations.

Primitive divisors serve as temporal fingerprints. If a prime $p$ first occurs at $F_n$, then observing divisibility by $p$ identifies an arithmetic period tied to $n$. Similar “first occurrence” ideas arise in periodicity tests, pseudorandom sequence design, and the study of divisibility sequences.

The key insight is reusable: whenever a sequence satisfies a law resembling

$$
\gcd(A_m,A_n)=A_{\gcd(m,n)},
$$

questions about all earlier indices can collapse to questions about proper divisors. The divisor lattice becomes a compressed record of the sequence’s past.

There is also a methodological lesson in the bound $10{,}000$. A computation can establish every case in a finite interval, but no amount of rhetoric turns that into an infinite theorem. To remove the upper bound, one needs a uniform growth estimate showing that the primitive part eventually exceeds $1$. A promising route compares the dominant term in Binet’s formula with the cumulative contribution from proper divisors, perhaps organized through a Möbius-weighted cyclotomic factorization.

## Positional notation without a fixed base

The second story begins with a familiar observation. Decimal digits use place weights

$$
1,10,10^2,10^3,\ldots,
$$

because every position has radix $10$. But many everyday systems change radix from one position to the next. Time uses $60$ seconds per minute, $60$ minutes per hour, and $24$ hours per day. A mixed-radix system captures all of these at once.

Choose positive integers $b_0,b_1,b_2,\ldots$. Define the running products

$$
B_0=1,\qquad B_i=\prod_{j=0}^{i-1}b_j\quad(i\ge1).
$$

For digits $c_0,\ldots,c_{k-1}$, define their value by

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
$$

The digit string is **valid** when

$$
0\le c_i<b_i\qquad(0\le i<k).
$$

Fixed-base notation appears when every $b_i=N$, for then $B_i=N^i$. But a more surprising specialization arises from

$$
b_i=i+1.
$$

Its running products are

$$
B_i=\prod_{j=0}^{i-1}(j+1)=i!.
$$

So the associated value is

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_i i!,
$$

with validity condition $0\le c_i<i+1$. This is precisely the factorial number system.

> **Factorial Bridge Theorem.** For the radix sequence $b_i=i+1$, mixed-radix place values equal factorial place values, mixed-radix validity is exactly factorial-digit validity, and mixed-radix evaluation equals factorial evaluation.

The bridge is exact, not metaphorical. The same digit vector denotes the same integer under both descriptions.

## Why valid mixed-radix expansions are unique

Mixed-radix notation inherits the essential rigidity of ordinary positional notation.

> **Mixed-Radix Uniqueness Theorem.** Let every radix $b_i$ be positive. If two valid length-$k$ digit vectors $c$ and $d$ satisfy $V_b(c;k)=V_b(d;k)$, then $c_i=d_i$ for every $0\le i<k$.

The proof follows the carries. Reducing the common value modulo $b_0$ recovers the first digit because every higher place weight is divisible by $b_0$. Subtract that digit and divide by $b_0$; the same argument recovers the next digit. Repetition determines the entire vector.

Specializing to $b_i=i+1$ yields the factorial result.

> **Factorial Uniqueness Theorem.** If $c$ and $d$ satisfy $0\le c_i,d_i<i+1$ for $0\le i<k$ and
>
> $$
> \sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
> $$
>
> then $c_i=d_i$ for every $0\le i<k$.

This representation has concrete uses. Factorial digits encode permutations through inversion counts: the digit bounds $c_i<i+1$ match the number of choices available at successive stages. Ranking and unranking permutations therefore become arithmetic in a positional system whose bases grow with position.

## One pattern, two mathematical worlds

The Fibonacci theorem and the mixed-radix bridge do not share subject matter, but they share an intellectual move. In the Fibonacci case, inherited factors are stripped away until only genuinely new divisibility remains. In the numeral case, notation is stripped down to running products and local digit bounds, revealing factorial numerals as one point in a broad family.

Both stories reward precise scope. The primitive-divisor theorem is complete on $13\le n\le10{,}000$ and openly identifies the analytic estimate needed beyond that range. The factorial bridge is fully general at every finite length and points toward stronger questions: whether digit extraction is natural under refinement, and whether two place-preserving mixed-radix systems are isomorphic exactly when their running products agree.

Mathematics becomes clearer when we know which features are inherited, which are structural, and which are truly new. Sometimes the survivor is a prime appearing for the first time. Sometimes it is a universal numeral system hiding beneath familiar notation. In both cases, what remains after stripping away the old is where the real information lives.
