# New Digits and New Primes: Two Stories About Mathematical Structure

Mathematics often advances when an object that looks special is recognized as one member of a larger family. A familiar numeral system turns out to be a particular mixed-radix machine. A prime factor of a Fibonacci number turns out to carry a timestamp: the first index at which it appears. These two stories live in different neighborhoods of number theory, yet they share a method. First identify the structure that matters; then transport a general principle through that structure; finally draw the boundary between what has been established and what still requires new ideas.

The first story concerns how integers are written. The second concerns when primes first appear in the Fibonacci sequence. Together they illustrate a kind of mathematical compression: many local calculations become consequences of a small number of organizing ideas.

## Beyond tens, hundreds, and thousands

In ordinary decimal notation, every position has the same base. The rightmost digit counts units, the next counts tens, then hundreds, and so on. The place values are

$$
1,10,10^2,10^3,\ldots.
$$

But a positional system need not use the same base at every step. Timekeeping already offers an everyday mixed-radix example: seconds roll over after $60$, minutes after $60$, and hours after $24$. The rule changes from position to position.

Let the radix at position $i$ be a positive integer $b_i$. Define the corresponding place values by

$$
B_0=1,\qquad B_i=\prod_{j=0}^{i-1}b_j\quad(i>0).
$$

A digit sequence $c_0,c_1,\ldots,c_{k-1}$ then represents

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
$$

The natural validity condition is $0\le c_i<b_i$ for each $i<k$. Under suitable radices, valid finite strings have unique values: if two valid strings of the same length represent the same integer, then their corresponding digits agree.

Now choose a particularly elegant sequence of radices:

$$
b_i=i+1.
$$

The place value at position $i$ becomes

$$
B_i=\prod_{j=0}^{i-1}(j+1)=i!.
$$

Thus the resulting mixed-radix expression is

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_i i!.
$$

This is the factorial number system, also called factoradic notation. Its digit in position $i$ must satisfy $0\le c_i<i+1$. The first position has only the digit $0$; the next permits $0$ or $1$; the next permits $0,1,2$; and so forth.

The central bridge is now immediate but powerful.

**Factorial–mixed-radix equivalence.** For every finite digit sequence, evaluating it in the mixed-radix system with radices $b_i=i+1$ gives exactly its factorial value $\sum_{i<k}c_i i!$. Moreover, mixed-radix validity is exactly the condition $c_i<i+1$ for every $i<k$.

The proof has only two moving parts. The running product of the first $i$ radices is $i!$, and the digit bound $c_i<b_i$ becomes $c_i<i+1$. Yet this bridge does more than rename expressions. It transfers the general uniqueness theorem for mixed-radix notation directly to factoradics.

**Uniqueness of factorial representation.** If two length-$k$ digit strings satisfy $0\le c_i<i+1$ and $0\le d_i<i+1$ for all $i<k$, and

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
$$

then $c_i=d_i$ for every $i<k$.

This is why factoradic notation is useful in combinatorics. Since there are exactly $i+1$ choices for the digit in position $i$, the first $k$ positions encode

$$
1\cdot2\cdot3\cdots k=k!
$$

possible valid strings. Those strings naturally rank and unrank permutations of $k$ objects. A quotient-and-remainder algorithm extracts the digits: divide by $2$, then by $3$, then by $4$, and continue. The successive remainders automatically satisfy the required bounds.

For example, $463$ has factoradic expansion

$$
463=3\cdot5!+4\cdot4!+1\cdot3!+0\cdot2!+1\cdot1!+0\cdot0!.
$$

The digit string is therefore $341010$ when written from the largest factorial place to the smallest. Its validity can be checked position by position, and uniqueness says there is no second valid string of the same range with value $463$.

## Prime factors with birthdays

The Fibonacci sequence begins with $F_0=0$, $F_1=1$, and

$$
F_{n+2}=F_{n+1}+F_n.
$$

Its early terms are $0,1,1,2,3,5,8,13,21,34,55,\ldots$. As the terms grow, prime factors appear and reappear. The prime $2$ first divides $F_3=2$ and later divides $F_6=8$. The prime $3$ first divides $F_4=3$ and later divides $F_8=21$. This suggests assigning each prime a first-appearance index.

A prime $p$ is a **primitive prime divisor** of $F_n$ if $p$ divides $F_n$ but divides no earlier positive-index Fibonacci number:

$$
p\mid F_n,\qquad p\nmid F_k\quad\text{for every }0<k<n.
$$

The established result considered here is deliberately finite and exact.

**Certified primitive-divisor theorem.** For every integer $n$ with $13\le n\le10000$, there exists a prime $p$ that is a primitive prime divisor of $F_n$.

The interval matters. The claim is not being silently stretched beyond the argument that supports it. Within this range, prime and composite indices are handled by complementary ideas.

A key Fibonacci identity is

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

Suppose a prime $p$ divides both $F_n$ and an earlier term $F_k$. Then $p$ divides $F_{\gcd(n,k)}$. Since $0<k<n$, the index $\gcd(n,k)$ is a proper divisor of $n$. Consequently, to prove that a prime factor of $F_n$ is primitive, it is enough to show that it divides none of the Fibonacci numbers $F_d$ associated with positive proper divisors $d$ of $n$.

This reduces a search through every earlier index to a much smaller search through the divisor structure of $n$.

The reduction leads to the **primitive part** of $F_n$. Begin with $F_n$. For every positive proper divisor $d$ of $n$, remove from the current number all prime factors shared with $F_d$. What remains is coprime to every such $F_d$. If the remainder is greater than $1$, it has a prime divisor $p$. That prime still divides $F_n$, but it divides none of the divisor-indexed earlier terms. The greatest-common-divisor identity then shows that $p$ cannot divide any $F_k$ with $0<k<n$. It is primitive.

This gives a clean implication.

**Primitive-part criterion.** If the primitive part of $F_n$ is greater than $1$, then $F_n$ possesses a primitive prime divisor.

The finite interval $13\le n\le10000$ is settled by evaluating this criterion across the composite indices, while prime indices are covered by the corresponding prime-index argument. The number $13$ itself causes no gap: it is prime.

A few examples show the phenomenon. Since

$$
F_{13}=233,
$$

and $233$ is prime, it is primitive at index $13$. Also,

$$
F_{14}=377=13\cdot29.
$$

The factor $13$ appeared earlier at $F_7=13$, but $29$ did not divide any $F_k$ for $0<k<14$, so $29$ is primitive. At index $15$,

$$
F_{15}=610=2\cdot5\cdot61,
$$

and $61$ is the new prime.

## An algorithmic lens

Both stories produce practical algorithms.

For factoradics, repeated Euclidean division gives the canonical digits. Starting with a nonnegative integer $N$, divide by $2$ and record the remainder as the coefficient of $1!$; divide the quotient by $3$ and record the remainder as the coefficient of $2!$; continue with divisors $4,5,\ldots$ until the quotient is zero. A leading coefficient at $0!$ is necessarily zero. Re-evaluation by $\sum c_i i!$ recovers $N$.

For Fibonacci primitive divisors, one may compute $F_n$, factor it, and test each prime factor against earlier Fibonacci terms. A more structural test computes the first index of divisibility for each prime factor: the factor is primitive exactly when that first index equals $n$. For modest examples this is transparent and fast. For an entire interval, the primitive-part criterion exploits divisor structure and avoids treating all earlier terms independently.

The two algorithms look unrelated, but their logic rhymes. Factoradic conversion discovers the correct local digit by a remainder, knowing that the radix bounds guarantee uniqueness. Primitive-divisor search discovers a genuinely new factor by stripping away everything explained by proper divisors, knowing that the Fibonacci gcd identity propagates any earlier occurrence down to a divisor index.

## Why boundaries are part of the theorem

There is a final lesson in the upper limit $10000$. Classical number theory contains broader primitive-divisor results, but an argument based on a finite interval proves a finite-interval theorem. Extending it requires genuine quantitative estimates, for example growth bounds on a cyclotomic primitive component of $F_n$, or an independent general primitive-divisor theorem.

That distinction is not a technical footnote. It is part of mathematical communication. A theorem is strongest when its statement exactly matches its support. Here the support yields a complete result for every $n$ from $13$ through $10000$, inclusive, and it identifies precisely what an unbounded extension would need.

Likewise, the factorial-number-system result gains strength from being placed in the right general family. Instead of proving uniqueness by an isolated argument, one recognizes factorial notation as mixed radix with $b_i=i+1$ and inherits uniqueness from the general positional principle.

There are practical echoes of this structural viewpoint. Factorial digits provide a natural coordinate system for permutations: each digit records a choice among the objects that remain, so a permutation can be ranked by one integer and reconstructed without ambiguity. Primitive Fibonacci factors provide a different kind of coordinate: a prime whose first occurrence is $n$ acts as an arithmetic marker for that index. In both cases, a complicated object is given a compact address.

These addresses are dependable because their proofs expose exactly what could go wrong. Factorial digits could be ambiguous without their position-dependent bounds; primitive factors could be mistaken for new arrivals without the gcd reduction to earlier indices. The hypotheses are therefore not decoration. They are the guardrails that make the encoding meaningful.

One story builds upward, from general radices to factorial digits. The other strips downward, from a Fibonacci number to the factors unexplained by its proper divisors. Both succeed by finding the right invariant: running products in one case, first occurrence in the other. And both show how mathematical structure turns a mass of calculations into a comprehensible theorem.