# New Digits and New Primes: Two Stories About Mathematical First Appearances

Every familiar numeral hides a choice. In decimal, the places have weights $1,10,100,1000,\ldots$, and every digit lies between $0$ and $9$. Change either rule and a different arithmetic landscape appears. At the same time, a very different-looking sequence—the Fibonacci numbers—raises its own question about novelty: when does a prime factor appear for the first time?

These two stories meet at an organizing idea. Complicated objects become intelligible when one separates what is inherited from earlier stages from what is genuinely new. For positional notation, the inherited structure is the running product of the bases. For Fibonacci numbers, it is the collection of prime factors already present at earlier divisor indices. Once those old contributions are isolated, uniqueness in one setting and primitive prime divisors in the other become visible.

## A numeral system whose base changes at every step

A mixed-radix system begins with a sequence of positive integer bases $b_0,b_1,b_2,\ldots$. Define its place weights by

$$
R_0=1,\qquad R_i=\prod_{j=0}^{i-1}b_j\quad (i\ge 1).
$$

A finite digit string $c_0,\ldots,c_{k-1}$ represents

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iR_i.
$$

The string is valid when $0\le c_i<b_i$ for every $i<k$. Ordinary base-$B$ notation is the constant choice $b_i=B$, which gives $R_i=B^i$. But constancy is not required. Timekeeping already uses mixed units: seconds roll into minutes at $60$, minutes into hours at $60$, and hours into days at $24$. Combinatorial ranking schemes use changing bases to label permutations without repetition.

The crucial fact is that the weights telescope. Since $R_{i+1}=b_iR_i$, every valid lower block satisfies

$$
0\le \sum_{i=0}^{m-1}c_iR_i<R_m.
$$

This inequality says that all positions below $m$, even at their largest valid digits, cannot reach one unit of position $m$. It is the true engine of positional notation.

**Mixed-Radix Uniqueness Theorem.** Suppose $c$ and $d$ are valid digit strings of length $k$ for the same bases. If $V_b(c;k)=V_b(d;k)$, then $c_i=d_i$ for every $i<k$.

To see why, reduce the equality modulo $b_0$. Every weight except $R_0$ is divisible by $b_0$, so the two first digits are congruent modulo $b_0$. Both lie in the interval from $0$ to $b_0-1$, hence they are equal. Subtract that common digit and divide by $b_0$. The same argument now applies to the shifted base sequence. Repeating the step recovers every digit. Equivalently, one may compare the highest position where the strings differ: the discrepancy there is at least one full unit $R_m$, while all lower discrepancies together have magnitude less than $R_m$, an impossibility.

This theorem tells us something broader than “place-value notation works.” It identifies the minimal architecture needed for it to work: bounded digits and multiplicatively accumulated place weights.

## Why factorials are place values

Now choose the changing bases

$$
b_i=i+1.
$$

Then

$$
R_i=\prod_{j=0}^{i-1}(j+1)=i!.
$$

The value formula becomes

$$
V(c;k)=\sum_{i=0}^{k-1}c_i i!,
$$

and validity becomes $0\le c_i\le i$. The zeroth digit must be $0$, because its base is $1$; this harmless convention makes the indexing line up exactly with factorials.

**Factorial–Mixed-Radix Bridge Theorem.** For bases $b_i=i+1$, mixed-radix place weights equal $i!$, the mixed-radix value equals the factorial-place value, and mixed-radix validity is exactly the condition $0\le c_i\le i$.

The proof is simply the product identity above, applied term by term in the value sum and in the digit bounds. Yet its consequence is substantial.

**Factorial Representation Uniqueness Theorem.** If two valid factorial digit strings $c$ and $d$ of length $k$ satisfy

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
$$

then $c_i=d_i$ for every $i<k$.

No special factorial trick is needed. This is the general mixed-radix uniqueness theorem evaluated at one base sequence. For example,

$$
463=3\cdot 5!+4\cdot 4!+1\cdot 3!+0\cdot 2!+1\cdot 1!+0\cdot 0!,
$$

so its factorial digits, read from the $5!$ place downward, are $341010$. Such encodings are useful in ranking permutations: successive factorial digits choose among successively shorter lists of available objects.

## The Fibonacci sequence and the search for a new prime

Turn now to the Fibonacci sequence,

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

A prime $p$ is called a **primitive prime divisor** of $F_n$ if

$$
p\mid F_n
$$

but

$$
p\nmid F_k\qquad\text{for every }0<k<n.
$$

The word “primitive” records a first appearance. For instance, $F_{12}=144$ has prime factors $2$ and $3$, but neither is new: both divide earlier Fibonacci numbers. By contrast, $F_{13}=233$, and $233$ first appears at index $13$.

Why should a factor found only by checking divisor indices be new among *all* earlier indices? The answer is the strong divisibility identity

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

Suppose $p$ divides both $F_n$ and an earlier $F_k$. Then $p$ divides their greatest common divisor, hence

$$
p\mid F_{\gcd(n,k)}.
$$

Because $0<k<n$, the index $\gcd(n,k)$ is a positive proper divisor of $n$. Thus every old prime factor of $F_n$ leaves evidence at a proper divisor index.

**Proper-Divisor Reduction Lemma.** If a prime $p$ divides $F_n$ and fails to divide $F_d$ for every positive proper divisor $d$ of $n$, then $p$ is a primitive prime divisor of $F_n$.

This lemma converts a search through every earlier term into a search through the much smaller divisor lattice of $n$.

## Stripping away the past

Define the **primitive part** $\Phi(n)$ computationally as follows. Begin with $r=F_n$. For each positive proper divisor $d$ of $n$, repeatedly replace $r$ by

$$
r/\gcd(r,F_d)
$$

while the greatest common divisor exceeds $1$. When every such $d$ has been processed, the remaining integer is $\Phi(n)$. Repetition matters: it removes the full multiplicity of every prime shared with $F_d$, not merely one copy.

Two elementary invariants explain the method. First, every update replaces $r$ by a divisor of $r$, so $\Phi(n)$ divides $F_n$. Second, after stripping against $F_d$, the survivor is coprime to $F_d$; later stripping only takes divisors, so coprimality persists. Therefore, if $\Phi(n)>1$, any prime factor $p$ of $\Phi(n)$ divides $F_n$ and no $F_d$ at a positive proper divisor $d$ of $n$. The proper-divisor reduction lemma then makes $p$ primitive.

**Primitive-Part Criterion.** If $n\ge 3$ and $\Phi(n)>1$, then $F_n$ has a primitive prime divisor.

The argument chooses any prime factor of $\Phi(n)$, uses divisibility to place it in $F_n$, uses the stripping invariants to exclude all proper divisor indices, and finally invokes strong divisibility to exclude every earlier positive index.

## A precise finite theorem

The structural criterion can be combined with exact finite evaluation.

**Finite Fibonacci Primitive-Divisor Theorem.** For every integer $n$ with

$$
13\le n\le 10000,
$$

there exists a prime $p$ such that $p\mid F_n$ and $p\nmid F_k$ for every $0<k<n$.

For composite $n$ in this interval, the primitive part obtained by complete gcd stripping is greater than $1$. The criterion above then supplies a primitive prime divisor. For prime $n$, the divisor structure is especially simple: the only positive proper divisor is $1$, and $F_1=1$ contributes no prime factors; since $F_n>1$ for $n\ge 3$, a prime factor of $F_n$ is automatically primitive. Combining the prime and composite cases proves the stated interval.

The upper endpoint is part of the theorem, not decoration. A finite evaluation establishes exactly a finite statement. Extending it to every $n\ge 13$ requires an additional argument, not a leap of rhetoric.

## Two algorithms, one philosophy

Digit extraction and primitive-factor extraction both peel away inherited structure.

For mixed radix, one repeatedly computes

$$
c_i=N\bmod b_i,\qquad N\leftarrow \left\lfloor N/b_i\right\rfloor.
$$

Each remainder is the new information visible at the current place; division removes that place and exposes the next. In the Fibonacci problem, gcd stripping computes what is shared with an earlier divisor index and divides it away. What remains is new.

The analogy is not an identity—the objects and theorems are different—but it is a useful design principle. When a mathematical construction is layered, ask for a quotient, remainder, or coprime residual that separates the present layer from its predecessors.

This principle also changes how one computes. To recover digits, there is no need to compare a value against every possible string: local remainder operations determine the string directly. To find new Fibonacci prime support, there is no need to factor every earlier term or compare against the whole prefix of the sequence: greatest common divisors at proper divisor indices capture all possible inheritance. In both cases, structure replaces brute-force history. That matters in applications, where the represented integers or recurrence terms can be enormous even when their descriptions—the base list or the index—remain compact.

There is also a lesson about mathematical boundaries. A general reduction and a finite evaluation are different kinds of evidence. The reduction explains why a nontrivial residual is decisive at every index; the evaluation establishes that the residual is nontrivial on a stated interval. Keeping these roles separate makes the theorem both stronger in meaning and more honest in scope.

The next natural goals follow directly. A single base-independent digit extractor should give a bijection between integers below $\prod_{i<k}b_i$ and valid length-$k$ strings. For Fibonacci numbers, a growth estimate such as $\Phi(n)>n$ for composite $n\ge 13$ would turn the finite theorem into an unbounded one once the relevant multiplicities are controlled. That control is expected to come from an entry-point valuation law: if $\alpha$ is the first index with $p\mid F_\alpha$, then the power of $p$ in later divisible terms should track the power of $p$ in the index ratio $n/\alpha$.

Both stories begin with familiar sequences—factorials and Fibonacci numbers—and end with a sharper understanding of novelty. A digit is new information after lower places are removed. A primitive prime is new arithmetic after earlier divisor terms are removed. In each case, the mathematics succeeds by making “first appearance” precise.