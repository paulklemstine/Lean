# Mixed-Radix Factorials and Primitive Prime Divisors of Fibonacci Numbers

**Aristotle**  
**15 July 2026**

## Abstract

This paper develops two complementary arithmetic themes. First, it identifies the factorial number system as the mixed-radix system whose radix at position $i$ is $i+1$. The running place value is therefore $i!$, digit validity becomes $0\le c_i<i+1$, and uniqueness of valid factorial representations follows directly from mixed-radix uniqueness. Second, it studies primitive prime divisors of Fibonacci numbers. A prime $p$ is primitive for $F_n$ when $p\mid F_n$ but $p\nmid F_k$ for every $0<k<n$. Using the identity $\gcd(F_m,F_n)=F_{\gcd(m,n)}$, the primitive-divisor question reduces to excluding divisibility at proper divisor indices. This motivates a primitive-part algorithm that removes from $F_n$ all factors shared with $F_d$ for positive proper divisors $d$ of $n$. If the remainder exceeds $1$, any of its prime factors is primitive. Combining the prime-index argument with an exhaustive finite certification of the composite case yields: for every $13\le n\le10000$, the Fibonacci number $F_n$ has a primitive prime divisor. Algorithms, examples, complexity considerations, and the precise requirements for an unbounded extension are presented.

## 1. Introduction

Positional representations and divisibility sequences are two classical sources of arithmetic structure. In a positional representation, the central questions are how place values are generated, which digit strings are valid, and whether evaluation is injective on valid strings. In a divisibility sequence, one asks not merely which primes occur, but when they occur for the first time.

The factorial number system and the Fibonacci sequence provide clean instances of these questions. A factorial representation has the form

$$
N=\sum_{i=0}^{k-1}c_i i!,
$$

with digit restrictions $0\le c_i<i+1$. Although this notation may at first seem specialized, it is exactly a mixed-radix positional system. This observation transports both evaluation and uniqueness from the general mixed-radix setting.

For Fibonacci numbers, first occurrence is captured by primitive prime divisors. Writing $F_0=0$, $F_1=1$, and $F_{n+2}=F_{n+1}+F_n$, a prime $p$ is primitive at index $n$ if it divides $F_n$ and no positive-index term before it. The main result in this direction is a theorem on a precise finite interval:

$$
13\le n\le10000\quad\Longrightarrow\quad F_n\text{ has a primitive prime divisor.}
$$

The upper bound is integral to the statement. The composite-index part is established over this interval by a finite primitive-part certification. No inference about the infinite tail is needed or made.

These themes share a methodological pattern. In the factorial setting, the key invariant is the running product of radices. In the Fibonacci setting, it is the gcd law, which converts an arbitrary earlier occurrence into an occurrence at a proper divisor index. Both invariants support algorithms and uniqueness or existence theorems.

## 2. Mixed-radix systems

### 2.1 Definitions

Let $k$ be a nonnegative integer. A finite radix sequence is a sequence of integers

$$
b_0,b_1,\ldots,b_{k-1}
$$

with $b_i\ge1$. Define the running radix products by

$$
B_0=1,\qquad B_i=\prod_{j=0}^{i-1}b_j\quad(1\le i<k).
$$

Thus $B_{i+1}=b_iB_i$. Given digits $c_0,c_1,\ldots,c_{k-1}$, define their mixed-radix value by

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
$$

A digit string is **valid** if

$$
0\le c_i<b_i\qquad\text{for every }0\le i<k.
$$

For uniqueness in the usual nondegenerate form, one generally takes $b_i\ge2$ at informative positions. Allowing $b_0=1$ is harmless: it forces $c_0=0$.

### 2.2 The mixed-radix uniqueness principle

**Theorem 2.1 (Mixed-radix uniqueness).** Let $c$ and $d$ be two valid length-$k$ digit strings for the same radix sequence. If

$$
V_b(c;k)=V_b(d;k),
$$

then $c_i=d_i$ for every $i<k$.

**Proof sketch.** The theorem can be proved by successive reduction modulo the radices. Since every place value $B_i$ with $i\ge1$ is divisible by $b_0$, equality of values implies $c_0\equiv d_0\pmod{b_0}$. Both digits lie in $[0,b_0)$, so $c_0=d_0$. Subtract this common digit and divide by $b_0$. The resulting equality is a mixed-radix equality for the shifted radix sequence. Iterating determines every digit. Equivalently, one may induct on $k$ using the decomposition into a lower block and the final place value. The digit bounds are essential: they turn congruence into equality. $\square$

This proof also describes a decoding process. At each stage, the current value modulo the current radix is the next digit, and integer division removes that digit.

## 3. The factorial number system as mixed radix

### 3.1 Factorial evaluation and validity

For a digit sequence $c$, define its length-$k$ factorial value by

$$
V_!(c;k)=\sum_{i=0}^{k-1}c_i i!.
$$

Call the sequence factorial-valid when

$$
0\le c_i<i+1\qquad(0\le i<k).
$$

The coefficient of $0!$ is necessarily $0$, because $c_0<1$. This convention introduces no loss: $0!=1!=1$, and fixing the $0!$ digit removes the only immediate ambiguity between the first two equal place values.

### 3.2 The bridge theorem

Set

$$
b_i=i+1.
$$

**Lemma 3.1 (Factorial running products).** For every $i\ge0$,

$$
\prod_{j=0}^{i-1}(j+1)=i!.
$$

**Proof sketch.** For $i=0$, both sides are $1$ by the empty-product convention. If the identity holds at $i$, multiplying by the next radix $i+1$ gives $i!(i+1)=(i+1)!$. $\square$

**Theorem 3.2 (Evaluation equivalence).** For every digit sequence $c$ and every length $k$, mixed-radix evaluation with $b_i=i+1$ equals factorial evaluation:

$$
V_b(c;k)=V_!(c;k).
$$

**Proof sketch.** By Lemma 3.1, the mixed-radix place value $B_i$ is $i!$. Substitution into the finite sum identifies every summand $c_iB_i$ with $c_i i!$. $\square$

**Theorem 3.3 (Validity equivalence).** A digit sequence is valid for the mixed-radix sequence $b_i=i+1$ if and only if it is factorial-valid.

**Proof sketch.** The mixed-radix condition at position $i$ is $0\le c_i<b_i$. Substituting $b_i=i+1$ gives exactly $0\le c_i<i+1$. $\square$

### 3.3 Uniqueness of factorial representations

**Theorem 3.4 (Factorial representation uniqueness).** Let $c$ and $d$ be length-$k$ factorial-valid digit strings. If

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
$$

then $c_i=d_i$ for every $i<k$.

**Proof sketch.** By Theorem 3.3, both strings are valid mixed-radix strings for $b_i=i+1$. By Theorem 3.2, the displayed factorial-value equality is the corresponding mixed-radix-value equality. Theorem 2.1 then gives coordinatewise equality. $\square$

This derivation is structurally informative: factorial uniqueness is not an isolated fact but an instance of a general positional theorem.

### 3.4 Range and counting

For positions $0$ through $k-1$, the number of valid strings is

$$
\prod_{i=0}^{k-1}(i+1)=k!.
$$

Their values are precisely the integers from $0$ through $k!-1$. One way to see the upper bound is

$$
\sum_{i=0}^{k-1} i\,i!=\sum_{i=0}^{k-1}\big((i+1)!-i!\big)=k!-1.
$$

The sum telescopes. Uniqueness and counting then show that all values in the interval occur exactly once.

### 3.5 Conversion algorithm

To encode $N\ge0$, repeatedly divide by $2,3,4,\ldots$. More precisely, set $q_1=N$. For $r=2,3,\ldots$, define

$$
c_{r-1}=q_{r-1}\bmod r,
$$

and

$$
q_r=\left\lfloor\frac{q_{r-1}}{r}\right\rfloor.
$$

Stop when $q_r=0$, and set $c_0=0$. The remainder bound gives $0\le c_{r-1}<r$, so the digits are valid. Reversing the division identities proves that their factorial value is $N$.

For example, beginning with $N=463$ gives remainders $1,0,1,4,3$ under division by $2,3,4,5,6$, respectively. Hence

$$
463=1\cdot1!+0\cdot2!+1\cdot3!+4\cdot4!+3\cdot5!.
$$

## 4. Fibonacci divisibility and primitive factors

### 4.1 Definitions

The Fibonacci sequence is defined by

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

**Definition 4.1 (Primitive prime divisor).** A prime $p$ is a primitive prime divisor of $F_n$ if

$$
p\mid F_n
$$

and

$$
p\nmid F_k\qquad\text{for every integer }k\text{ with }0<k<n.
$$

The least positive index $z(p)$ for which $p\mid F_{z(p)}$, when such an index exists, is called the **entry point** or **rank of apparition** of $p$. In this language, $p$ is primitive for $F_n$ precisely when $z(p)=n$.

### 4.2 The gcd reduction

The foundational divisibility identity is

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

**Lemma 4.2 (Common factors descend to gcd indices).** If an integer $a$ divides both $F_n$ and $F_k$, then

$$
a\mid F_{\gcd(n,k)}.
$$

**Proof sketch.** Any common divisor of $F_n$ and $F_k$ divides their greatest common divisor. Applying the Fibonacci gcd identity yields the conclusion. $\square$

**Lemma 4.3 (Proper-divisor reduction).** Let $p$ be prime and suppose $p\mid F_n$. If

$$
p\nmid F_d
$$

for every positive proper divisor $d$ of $n$, then $p$ is a primitive prime divisor of $F_n$.

**Proof sketch.** Suppose instead that $p\mid F_k$ for some $0<k<n$. Lemma 4.2 gives $p\mid F_{\gcd(n,k)}$. The index $d=\gcd(n,k)$ is positive, divides $n$, and satisfies $d\le k<n$. It is therefore a positive proper divisor of $n$, contradicting the hypothesis. $\square$

This lemma is the principal compression step. It replaces all earlier indices by the proper divisors of $n$.

### 4.3 Entry points

**Lemma 4.4 (Entry point divides every occurrence index).** Let $p$ be prime. If $n>0$ and $p\mid F_n$, then the entry point $z(p)$ exists and divides $n$.

**Proof sketch.** Existence follows from the occurrence at $n$. Let $z=z(p)$. By Lemma 4.2, $p$ divides $F_{\gcd(n,z)}$. Minimality of $z$ among positive occurrence indices forces $\gcd(n,z)=z$. Hence $z\mid n$. $\square$

**Corollary 4.5 (Entry-point primitiveness).** If $p\mid F_n$ and $z(p)=n$, then $p$ is primitive for $F_n$.

**Proof sketch.** Any earlier divisibility $p\mid F_k$ would imply $z(p)\mid k$ by Lemma 4.4, which is impossible when $z(p)=n>k>0$. $\square$

## 5. Primitive parts

### 5.1 Removing inherited factors

For positive integers $a$ and $b$, define $R(a,b)$ to be the result of repeatedly dividing $a$ by $\gcd(a,b)$ while that gcd is greater than $1$. The process terminates because every nontrivial division strictly decreases the positive current value.

The operation has two elementary properties.

**Lemma 5.1 (Divisibility after stripping).** The number $R(a,b)$ divides $a$.

**Proof sketch.** Every step replaces the current value by a divisor of it. Transitivity of divisibility gives the result. $\square$

**Lemma 5.2 (Coprimality after stripping).** If $a>0$, then $R(a,b)$ is coprime to $b$.

**Proof sketch.** The loop stops exactly when the gcd of the current value with $b$ is at most $1$. Positivity makes the gcd positive, hence equal to $1$. $\square$

Let $D(n)$ be the set of positive proper divisors of $n$. Begin with $A_0=F_n$ and, in any fixed enumeration $d_1,\ldots,d_s$ of $D(n)$, set

$$
A_j=R(A_{j-1},F_{d_j}).
$$

Call the final number $P_n=A_s$ the **primitive part** produced by this stripping process. It divides $F_n$ and is coprime to every $F_d$ with $d\in D(n)$. The order of stripping does not affect the criterion needed below: every prime surviving at the end divides no divisor-indexed term.

### 5.2 The primitive-part criterion

**Theorem 5.3 (Primitive-part criterion).** If $n\ge3$ and $P_n>1$, then $F_n$ has a primitive prime divisor.

**Proof sketch.** Choose any prime divisor $p$ of $P_n$. Since $P_n\mid F_n$, one has $p\mid F_n$. Since $P_n$ is coprime to every $F_d$ with $d$ a positive proper divisor of $n$, the prime $p$ divides none of those terms. Lemma 4.3 now shows that $p$ is primitive for $F_n$. $\square$

The hypothesis $P_n>1$ is exactly what guarantees a surviving prime. This theorem separates conceptual reasoning from finite computation: the computation need only establish positivity of a well-defined residual integer.

## 6. Primitive divisors on the certified interval

### 6.1 Prime and composite indices

At prime indices $n\ge13$, the prime-index primitive-divisor argument supplies a primitive prime divisor of $F_n$. For composite indices, the primitive-part criterion reduces the matter to checking $P_n>1$.

A complete finite evaluation establishes the following statement.

**Proposition 6.1 (Composite interval certificate).** For every composite integer $n$ satisfying

$$
13\le n\le10000,
$$

the primitive part $P_n$ is greater than $1$. Consequently, $F_n$ has a primitive prime divisor.

**Proof sketch.** For each integer in the finite interval, enumerate its positive proper divisors, apply repeated gcd stripping to $F_n$, and test whether the resulting primitive part exceeds $1$. Prime indices are excluded from this proposition; every composite index in the interval passes the test. Theorem 5.3 converts each positive result into a primitive prime divisor. $\square$

The lower endpoint presents no composite anomaly: $13$ is prime. Thus prime and composite cases combine without a gap.

**Theorem 6.2 (Primitive divisors of Fibonacci numbers through index $10000$).** For every integer $n$ with

$$
13\le n\le10000,
$$

there exists a prime $p$ such that

$$
p\mid F_n
$$

and

$$
p\nmid F_k\qquad\text{for all }0<k<n.
$$

**Proof sketch.** If $n$ is prime, apply the prime-index result. If $n$ is composite, apply Proposition 6.1. These alternatives exhaust the interval. $\square$

### 6.2 Examples

At $n=13$,

$$
F_{13}=233,
$$

and the prime $233$ has no earlier positive occurrence, so it is primitive.

At $n=14$,

$$
F_{14}=377=13\cdot29.
$$

The factor $13$ is inherited from $F_7=13$. The factor $29$ is not inherited and is primitive at index $14$.

At $n=15$,

$$
F_{15}=610=2\cdot5\cdot61.
$$

The factors $2$ and $5$ occur earlier, while $61$ first appears at index $15$.

At $n=16$,

$$
F_{16}=987=3\cdot7\cdot47.
$$

Here $47$ is primitive. These examples illustrate the purpose of stripping: familiar factors are removed, leaving a factor whose first occurrence is tied to the current index.

## 7. Algorithms and complexity

### 7.1 Factoradic encoding and decoding

Repeated division encodes an integer $N$. If the resulting representation has $k$ nontrivial positions, then $k!>N$, so $k$ grows approximately as $\log N/\log\log N$. The algorithm uses $k$ divisions by small, increasing integers. With schoolbook arithmetic, its bit complexity is polynomial in $\log N$; with modern integer arithmetic it is correspondingly faster.

Decoding computes factorials incrementally and accumulates $\sum c_i i!$. Validity checking is linear in the number of digits. Equality of valid representations can be tested either digitwise or by evaluation, although digitwise comparison avoids large intermediate values.

### 7.2 Direct primitive-divisor demonstration

For moderate $n$, a transparent demonstration algorithm is:

1. compute $F_0,\ldots,F_n$ iteratively;
2. factor $F_n$;
3. for each distinct prime factor $p$, find the least positive $k\le n$ with $p\mid F_k$;
4. report those with first occurrence $k=n$.

The Fibonacci table requires $O(n)$ additions of integers with $O(n)$ bits. Trial-division factorization is suitable only for small demonstrations; serious ranges require better factorization or the primitive-part method. Testing a known prime factor across all previous terms costs $O(n)$ modular tests, but entry-point theory can reduce this further.

### 7.3 Primitive-part certification

For each $n$, enumerate positive proper divisors and repeatedly compute gcds. There are at most $n-1$ candidates under naïve enumeration, though divisor enumeration up to $\sqrt n$ is preferable. The dominant quantities, $F_n$, have $\Theta(n)$ bits. Euclidean gcd is polynomial in the bit length, and every stripping division strictly reduces the current integer. The resulting method is finite and deterministic for any prescribed interval.

The theorem proved by such an interval computation must retain the interval bound. An algorithm that has checked $n\le10000$ does not itself address $n>10000$.

## 8. Applications and broader connections

Factoradics are closely connected with permutations. A permutation of $k$ objects can be encoded by its Lehmer code, whose $i$th digit counts how many remaining smaller elements lie to the right. Those digits obey factorial bounds, and factorial evaluation ranks the permutation among $k!$ possibilities. The bridge to mixed radix explains why the ranking is bijective.

Mixed-radix systems also model heterogeneous units, scheduling cycles, calendar arithmetic, and data layouts in which different fields have different capacities. The running-product formulation isolates the universal part of these applications.

Primitive divisors measure arithmetic novelty in recurrence sequences. A primitive prime factor at index $n$ is information not already present in earlier terms. The gcd identity makes that novelty compatible with the divisor lattice of indices. Similar ideas appear in order computations, periodicity modulo primes, and the study of divisibility sequences.

Algorithmically, primitive factors can serve as index markers: because a primitive factor of $F_n$ has entry point $n$, its modular behavior records the index at which it first becomes visible. The finite theorem guarantees such a marker throughout the stated interval.

## 9. Discussion and future work

The factorial results are complete consequences of a structural identification. The next natural developments are algorithmic: establish sharp complexity bounds for conversion, connect the digits explicitly to permutation ranking and unranking, and compare factorial radix with other adaptive radix sequences.

For Fibonacci primitive divisors, the principal mathematical boundary is the upper endpoint. Removing it requires an argument for the infinite tail, not a larger but still finite computation. One route is to define a homogeneous cyclotomic primitive component of $F_n$ and prove lower growth bounds showing that it eventually exceeds $1$. Another is to establish a general primitive-divisor theorem for the sequence and specialize it to Fibonacci numbers. Either route would then combine with the finite interval result to give an unbounded theorem.

The primitive-part algorithm itself invites refinement. Proper divisors can be generated in pairs, repeated gcd stripping can be reorganized prime-by-prime, and modular methods can reduce storage. A certificate format could record, for each $n$, a surviving prime together with its divisibility at $F_n$ and nondivisibility at the relevant proper divisor terms. The gcd reduction would then turn a compact divisor-index certificate into a full primitiveness argument.

More broadly, the same methodology applies to other strong divisibility sequences satisfying an identity analogous to

$$
\gcd(U_m,U_n)=U_{\gcd(m,n)}.
$$

Whenever such an identity holds, excluding factors at proper divisor indices is enough to exclude them at every earlier index. This suggests a general framework for primitive-part algorithms across recurrence sequences.

There is also a useful distinction between witness production and interval certification. For a single index, producing one prime $p$ and checking $p\mid F_n$ together with $p\nmid F_d$ at every positive proper divisor $d$ gives a compact witness. For a whole interval, computing residual primitive parts gives a uniform decision procedure. Future implementations could combine the two: use residual computation to discover a witness, then publish only the smaller prime-and-divisor certificate needed to check it.

A further question concerns the arithmetic size of the least primitive divisor. Existence alone does not control whether the first new prime is small enough for efficient discovery. Experimental data can suggest bounds, but any general claim would require separate estimates. Related questions ask how many distinct primitive primes occur at an index and how the entry points of primes are distributed. These refinements preserve the central distinction of the present result: structural lemmas explain why a finite certificate is sufficient, while quantitative analysis is required to extrapolate beyond its certified range.

## 10. Conclusion

The factorial number system is precisely mixed radix with $b_i=i+1$. Its place values are $i!$, its validity bounds are $c_i<i+1$, and uniqueness follows from the general uniqueness of valid mixed-radix expansions.

For Fibonacci numbers, the gcd identity reduces first-occurrence questions to the divisor lattice of the index. Removing all factors shared with Fibonacci numbers at positive proper divisor indices produces a primitive part; whenever that part exceeds $1$, one of its prime factors is primitive. A complete finite certification of this criterion for composite indices, combined with the prime-index case, proves that every $F_n$ with $13\le n\le10000$ has a primitive prime divisor.

Both developments exemplify the same strategy: identify the invariant that exposes the general structure, then transfer a broad theorem or a finite criterion through that invariant. The result is not merely a collection of computations, but a reusable explanation of why the computations suffice.