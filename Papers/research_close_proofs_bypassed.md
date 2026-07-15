# Divisor-Stripped Fibonacci Parts and the Mixed-Radix Structure of Factorial Numerals

## Abstract

This paper develops two complementary arithmetic themes: the detection of first-occurring prime factors in Fibonacci numbers and the realization of factorial numerals as a canonical mixed-radix system. For the Fibonacci sequence, we use the strong divisibility identity $\gcd(F_m,F_n)=F_{\gcd(m,n)}$ to reduce primitivity against all earlier indices to nondivisibility at positive proper divisors of the target index. We define a divisor-stripped primitive part by repeatedly removing from $F_n$ every factor shared with $F_d$ for $d\mid n$, $0<d<n$. If this residue exceeds $1$, its least prime factor is primitive at index $n$. An exhaustive exact-integer certificate, combined with the prime-index and composite-index structural arguments, yields a primitive prime divisor for every $F_n$ with $13\le n\le10{,}000$. The upper bound is explicit and essential; no unbounded conclusion is claimed.

For numeral systems, we define finite mixed-radix values using running products $B_i=\prod_{j<i}b_j$ and local digit bounds $0\le c_i<b_i$. We state the general uniqueness theorem and specialize to $b_i=i+1$. Since $B_i=i!$, mixed-radix evaluation and validity coincide exactly with factorial-number-system evaluation and validity. Factorial representation uniqueness follows as a direct specialization of mixed-radix uniqueness. We give algorithms, correctness arguments, complexity analyses, numerical examples, applications, and a program for extending both theories.

## 1. Introduction

A prime divisor of a sequence term can carry two kinds of information. It may be inherited, having already appeared in an earlier term, or it may be genuinely new at the current index. Primitive prime divisors isolate the second phenomenon. In a strong divisibility sequence, inherited divisibility has a rigid geometry: common factors at indices $m$ and $n$ descend to the greatest common divisor of those indices. This turns an apparently linear search through all earlier terms into a search over the much smaller divisor lattice.

A comparable compression occurs in positional notation. The visible conventions of decimal, sexagesimal, and factorial notation differ, but their common mechanism is a sequence of local radices and the running products of those radices. Once that mechanism is isolated, evaluation, validity, digit extraction, and uniqueness can be studied uniformly.

The paper has two principal aims. First, it gives a self-contained account of a certified interval theorem for primitive prime divisors of Fibonacci numbers. The theorem covers every index from $13$ through $10{,}000$. Its proof has two layers: a structural reduction valid for arbitrary positive indices and a finite exact calculation certifying positivity of the stripped residue throughout the interval. Second, it explains the factorial number system as the mixed-radix specialization $b_i=i+1$ and derives factorial uniqueness from the general uniqueness theorem.

These aims are linked by a common strategy. One removes inherited structure—old Fibonacci factors in the first setting, notation-specific presentation in the second—and studies the canonical residue.

## 2. Fibonacci preliminaries

### 2.1. The sequence and divisibility

The Fibonacci sequence $(F_n)_{n\ge0}$ is defined by

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

For integers $a,b$, the notation $a\mid b$ means that $b=aq$ for some integer $q$. All divisibility statements below concern nonnegative integers, and all primes are positive rational primes.

The fundamental structural identity is the following.

> **Theorem 2.1 (Strong divisibility of Fibonacci numbers).** For all nonnegative integers $m$ and $n$,
>
> $$
> \gcd(F_m,F_n)=F_{\gcd(m,n)}.
> $$

**Proof sketch.** The Fibonacci addition identities imply a Euclidean reduction for indices: when $m\ge n$, the common divisors of $F_m$ and $F_n$ are the common divisors of $F_{m-n}$ and $F_n$. Iterating in parallel with the Euclidean algorithm reduces the pair $(m,n)$ to $(\gcd(m,n),0)$. Since $F_0=0$, the terminal greatest common divisor is $F_{\gcd(m,n)}$. This argument also accounts for the cases where one index is zero.

### 2.2. Primitive prime divisors and entry indices

> **Definition 2.2 (Primitive prime divisor).** Let $n>0$. A prime $p$ is a primitive prime divisor of $F_n$ if
>
> $$
> p\mid F_n
> $$
>
> and
>
> $$
> p\nmid F_k\qquad\text{for every integer }k\text{ with }0<k<n.
> $$

Equivalently, $n$ is the first positive index at which $p$ divides a Fibonacci number. This motivates a second definition.

> **Definition 2.3 (Fibonacci entry index).** If a prime $p$ divides at least one positive-index Fibonacci number, its entry index $z(p)$ is the least positive integer $r$ such that $p\mid F_r$.

The entry index provides an alternative language: $p$ is primitive at $n$ exactly when $z(p)=n$.

> **Lemma 2.4 (Entry-index divisibility).** If $p$ is prime, $n>0$, and $p\mid F_n$, then $z(p)\mid n$.

**Proof sketch.** Let $r=z(p)$ and set $g=\gcd(n,r)$. Strong divisibility gives $p\mid F_g$ because $p$ divides both $F_n$ and $F_r$. Since $g>0$ and $g\le r$, the minimality of $r$ forces $g=r$. Hence $r\mid n$.

This lemma says that the indices at which a fixed prime occurs are constrained by its first occurrence. For the present purpose, an even more direct reduction is useful.

> **Lemma 2.5 (Proper-divisor reduction).** Let $n>0$, and let $p$ be a prime dividing $F_n$. Suppose
>
> $$
> p\nmid F_d
> $$
>
> for every positive proper divisor $d$ of $n$. Then $p$ is a primitive prime divisor of $F_n$.

**Proof sketch.** Assume instead that $p\mid F_k$ for some $0<k<n$. By Theorem 2.1,

$$
p\mid\gcd(F_n,F_k)=F_{\gcd(n,k)}.
$$

The integer $d=\gcd(n,k)$ is positive, divides $n$, and satisfies $d\le k<n$. It is therefore a positive proper divisor of $n$, contradicting the hypothesis.

The importance of Lemma 2.5 is algorithmic as well as conceptual. It replaces $n-1$ potential comparisons by comparisons indexed by the positive proper divisors of $n$.

## 3. The divisor-stripped primitive part

### 3.1. Repeated stripping

A single greatest-common-divisor division may not remove every factor shared by two numbers. For example, if one number contains a higher power of a common prime than the other, repeated removal is required.

> **Definition 3.1 (Complete stripping operation).** For positive integers $R$ and $M$, define $S(R,M)$ by the following terminating process. While $\gcd(R,M)>1$, replace $R$ with $R/\gcd(R,M)$. When the greatest common divisor becomes $1$, return the current value.

The operation has two immediate invariants.

> **Lemma 3.2 (Divisibility and coprimality after stripping).** For positive integers $R$ and $M$:
>
> 1. $S(R,M)\mid R$;
> 2. $\gcd(S(R,M),M)=1$.

**Proof sketch.** Each update divides the current value by one of its divisors, so every intermediate value and the output divide the original $R$. Whenever an update occurs, the current value strictly decreases because the divisor is at least $2$. Termination follows by descent in the positive integers. The loop stops precisely when the current value is coprime to $M$.

### 3.2. Primitive part

Let

$$
D(n)=\{d\in\mathbb Z:0<d<n,\ d\mid n\}
$$

be the set of positive proper divisors of $n$.

> **Definition 3.3 (Divisor-stripped Fibonacci primitive part).** Fix any ordering $d_1,\ldots,d_t$ of $D(n)$. Set $R_0=F_n$ and recursively define
>
> $$
> R_j=S(R_{j-1},F_{d_j})\qquad(1\le j\le t).
> $$
>
> The final residue $P_n=R_t$ is called the divisor-stripped primitive part of $F_n$.

The construction as used here fixes an explicit order, so no order-independence claim is needed. The properties required by the argument hold for any chosen order.

> **Lemma 3.4 (Primitive-part divisibility).** For every positive integer $n$,
>
> $$
> P_n\mid F_n.
> $$

**Proof sketch.** Apply the divisibility statement in Lemma 3.2 at each stripping stage and compose the resulting divisibilities.

> **Lemma 3.5 (Coprimality with divisor-indexed terms).** For every $d\in D(n)$,
>
> $$
> \gcd(P_n,F_d)=1.
> $$

**Proof sketch.** At the stage corresponding to $d$, complete stripping makes the current residue coprime to $F_d$. Every later residue divides that current residue. A divisor of a number coprime to $F_d$ is also coprime to $F_d$.

We can now extract a primitive prime whenever the residue is nontrivial.

> **Theorem 3.6 (Primitive-part criterion).** If $P_n>1$, then $F_n$ has a primitive prime divisor. More precisely, the least prime factor of $P_n$ is prime, divides $F_n$, and divides no $F_k$ with $0<k<n$.

**Proof sketch.** Let $p$ be the least prime factor of $P_n$. By Lemma 3.4, $p\mid F_n$. By Lemma 3.5, $p$ cannot divide $F_d$ for any $d\in D(n)$, since otherwise $p$ would divide their greatest common divisor. Lemma 2.5 then shows that $p$ is primitive at $n$.

This theorem isolates the computational burden into a single inequality: $P_n>1$.

## 4. The certified Fibonacci interval

### 4.1. Finite certificate

The exact calculation underlying the interval result evaluates the divisor-stripped primitive part for each relevant index. It establishes the following statement.

> **Proposition 4.1 (Composite-index residue certificate).** For every composite integer $n$ satisfying
>
> $$
> 13\le n\le10{,}000,
> $$
>
> the divisor-stripped primitive part satisfies $P_n>1$.

The calculation uses arbitrary-precision integer arithmetic, exact greatest common divisors, and exact integer division. It does not rely on floating-point approximations or probabilistic factorization. The calculation need not factor the full Fibonacci number: once $P_n>1$, its least prime factor is available in principle as the witness required by Theorem 3.6.

> **Theorem 4.2 (Composite indices in the certified interval).** If $n$ is composite and $13\le n\le10{,}000$, then $F_n$ has a primitive prime divisor.

**Proof sketch.** Proposition 4.1 gives $P_n>1$. Apply Theorem 3.6.

For prime indices, a structural prime-index result supplies the complementary branch.

> **Theorem 4.3 (Prime-index branch).** If $n$ is prime and $n\ge13$, then $F_n$ has a primitive prime divisor.

**Proof sketch.** At a prime index, the only positive proper divisor is $1$, and $F_1=1$ contributes no prime factor. The prime-index divisibility analysis therefore forces a prime divisor of $F_n$ whose entry index is $n$; equivalently, that divisor is primitive. The lower threshold excludes the small exceptional behavior relevant to the general primitive-divisor phenomenon.

Combining the two cases yields the principal Fibonacci result.

> **Theorem 4.4 (Primitive divisors throughout the certified interval).** For every integer $n$ with
>
> $$
> 13\le n\le10{,}000,
> $$
>
> there exists a prime $p$ such that
>
> $$
> p\mid F_n
> $$
>
> and
>
> $$
> p\nmid F_k\qquad\text{for every }0<k<n.
> $$

**Proof sketch.** If $n$ is prime, apply Theorem 4.3. If $n$ is composite, apply Theorem 4.2.

The bound $n\le10{,}000$ is load-bearing. The structural lemmas apply without that bound, but Proposition 4.1 is a finite certificate. An unbounded theorem requires an additional uniform growth argument for $P_n$.

### 4.2. Numerical illustrations

Several small examples show how old and new prime factors separate:

$$
F_{14}=377=13\cdot29.
$$

Here $13\mid F_7$, whereas $29$ divides no earlier positive-index Fibonacci number. Thus $29$ is primitive at $14$.

Similarly,

$$
F_{15}=610=2\cdot5\cdot61.
$$

The factors $2$ and $5$ occur earlier, while $61$ first occurs at index $15$.
For $n=20$,

$$
F_{20}=6765=3\cdot5\cdot11\cdot41.
$$

The factors $3$, $5$, and $11$ occur at earlier indices, while $41$ is primitive at $20$.

These examples illustrate why mere nontrivial factorization of $F_n$ is insufficient. The index of first occurrence is the essential datum.

## 5. Mixed-radix numeral systems

### 5.1. Running products, values, and validity

Let $b=(b_0,b_1,b_2,\ldots)$ be a sequence of positive integers, called radices. Define its running products by

$$
B_0=1,\qquad B_i=\prod_{j=0}^{i-1}b_j\quad(i\ge1).
$$

Thus $B_{i+1}=b_iB_i$.

> **Definition 5.1 (Finite mixed-radix value).** For a digit sequence $c=(c_0,c_1,\ldots)$ and a length $k$, define
>
> $$
> V_b(c;k)=\sum_{i=0}^{k-1}c_iB_i.
> $$

> **Definition 5.2 (Validity).** The first $k$ digits of $c$ are valid for $b$ if
>
> $$
> 0\le c_i<b_i\qquad\text{for every }0\le i<k.
> $$

Positive radices are sufficient for the abstract uniqueness statement. In useful nondegenerate numeral systems one usually assumes $b_i\ge2$; allowing $b_i=1$ simply forces the corresponding digit to be zero.

The running product $B_k$ is the size of the represented initial interval.

> **Lemma 5.3 (Range bound).** If $c$ is valid through length $k$, then
>
> $$
> 0\le V_b(c;k)<B_k.
> $$

**Proof sketch.** Induct on $k$. The recurrence

$$
V_b(c;k+1)=V_b(c;k)+c_kB_k
$$

and the bounds $V_b(c;k)<B_k$ and $c_k<b_k$ give

$$
V_b(c;k+1)<B_k+(b_k-1)B_k=b_kB_k=B_{k+1}.
$$

A sharpened induction uses the integer inequality $V_b(c;k)\le B_k-1$ to make the final step immediate.

### 5.2. Uniqueness and extraction

> **Theorem 5.4 (Mixed-radix uniqueness).** Let $b_i>0$ for every $i<k$. If $c$ and $d$ are valid through length $k$ and
>
> $$
> V_b(c;k)=V_b(d;k),
> $$
>
> then
>
> $$
> c_i=d_i\qquad\text{for every }0\le i<k.
> $$

**Proof sketch.** The lowest digit is determined by reduction modulo $b_0$, because $B_0=1$ and every $B_i$ with $i>0$ is divisible by $b_0$. Validity places both $c_0$ and $d_0$ in the same complete residue interval $[0,b_0)$, so congruence implies equality. Subtract the common lowest digit and divide by $b_0$. The remaining equality is a mixed-radix equality for the shifted radix sequence. Induction recovers all digits.

The proof gives a constructive inverse.

> **Algorithm 5.5 (Successive quotient-and-remainder extraction).** Given $0\le x<B_k$, set $q_0=x$. For $i=0,\ldots,k-1$, define
>
> $$
> c_i=q_i\bmod b_i,\qquad q_{i+1}=\left\lfloor\frac{q_i}{b_i}\right\rfloor.
> $$
>
> Then $0\le c_i<b_i$ and $x=V_b(c;k)$.

**Correctness sketch.** At every step, Euclidean division gives $q_i=c_i+b_iq_{i+1}$. Substituting these identities recursively yields

$$
x=c_0+b_0c_1+b_0b_1c_2+\cdots+B_{k-1}c_{k-1}+B_kq_k.
$$

The bound $x<B_k$ forces $q_k=0$, leaving $x=V_b(c;k)$. Validity follows from the remainder bounds. Theorem 5.4 gives uniqueness.

Together, range, existence, and uniqueness establish a bijection between valid length-$k$ digit vectors and the integers in $[0,B_k)$.

## 6. Factorial numerals as mixed-radix numerals

### 6.1. Factorial evaluation

> **Definition 6.1 (Factorial numeral).** A length-$k$ factorial digit vector is a sequence $c_0,\ldots,c_{k-1}$ satisfying
>
> $$
> 0\le c_i<i+1.
> $$
>
> Its value is
>
> $$
> W(c;k)=\sum_{i=0}^{k-1}c_i i!.
> $$

The zeroth digit necessarily vanishes because $0\le c_0<1$. This redundant-looking position makes the indexing align exactly with factorial weights.

Choose the mixed-radix sequence

$$
b_i=i+1.
$$

Then its running products satisfy

$$
B_i=\prod_{j=0}^{i-1}(j+1)=i!.
$$

This elementary identity yields the bridge.

> **Theorem 6.2 (Factorial place-value agreement).** For $b_i=i+1$, every digit sequence $c$, and every finite length $k$,
>
> $$
> V_b(c;k)=W(c;k).
> $$

**Proof sketch.** Replace each running product $B_i$ in the mixed-radix sum by $i!$ using the product identity above. The two finite sums then coincide term by term.

> **Theorem 6.3 (Factorial validity agreement).** For $b_i=i+1$, a digit vector is mixed-radix valid through length $k$ if and only if it is factorial-valid through length $k$.

**Proof sketch.** The mixed-radix bound at position $i$ is $0\le c_i<b_i$. Substituting $b_i=i+1$ gives exactly $0\le c_i<i+1$.

The two agreements imply the desired uniqueness result without a separate factorial-specific argument.

> **Theorem 6.4 (Factorial representation uniqueness).** Suppose $c$ and $d$ satisfy
>
> $$
> 0\le c_i<i+1,\qquad 0\le d_i<i+1
> $$
>
> for every $0\le i<k$. If
>
> $$
> \sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
> $$
>
> then $c_i=d_i$ for every $0\le i<k$.

**Proof sketch.** By Theorem 6.3, both vectors are valid for the mixed-radix sequence $b_i=i+1$. By Theorem 6.2, equality of factorial values is equality of mixed-radix values. Theorem 5.4 then gives coordinatewise equality.

A corresponding existence statement follows from Algorithm 5.5.

> **Corollary 6.5 (Canonical factorial representation on an initial interval).** Every integer $x$ with $0\le x<k!$ has a unique representation
>
> $$
> x=\sum_{i=0}^{k-1}c_i i!,
> $$
>
> where $0\le c_i<i+1$.

**Proof sketch.** For $b_i=i+1$, the total running product is $B_k=k!$. Apply mixed-radix extraction for existence and Theorem 6.4 for uniqueness.

## 7. Algorithms and complexity

### 7.1. Primitive-part computation

For a target index $n$, the primitive-part pipeline is:

1. compute $F_n$ by iteration or fast doubling;
2. enumerate positive proper divisors $d$ of $n$;
3. compute $F_d$ for each such divisor;
4. repeatedly divide the current residue by its greatest common divisor with $F_d$;
5. if the final residue exceeds $1$, extract a prime factor and report it as primitive.

Trial enumeration finds divisors in $O(\sqrt n)$ arithmetic tests. Fast doubling computes $F_m$ in $O(\log m)$ big-integer multiplications. The stripping loop strictly decreases the bit length whenever a nontrivial common factor is removed; across one divisor, it performs at most $O(\log F_n)=O(n)$ divisions in the extremely conservative worst case. In practice, far fewer iterations occur. Greatest-common-divisor computation is quasi-linear in operand bit length with modern algorithms.

The important conceptual feature is that full factorization of every earlier Fibonacci number is unnecessary. GCD stripping removes shared prime powers collectively.

### 7.2. Mixed-radix conversion

To encode $x$ in radices $b_0,\ldots,b_{k-1}$, successive Euclidean divisions produce the digits. The algorithm uses exactly $k$ remainder operations and $k$ quotient operations. With school arithmetic, its bit complexity is the sum of the division costs on progressively smaller quotients. Evaluation computes the running weights and accumulates $\sum c_iB_i$ in $O(k)$ big-integer multiplications and additions.

For factorial radices, the extraction rules become

$$
c_i=q_i\bmod(i+1),\qquad q_{i+1}=\left\lfloor\frac{q_i}{i+1}\right\rfloor.
$$

This is the standard arithmetic core of permutation ranking and unranking.

## 8. Applications and interpretation

Primitive divisors distinguish a recurrence term by a prime signature absent from its history. This can be useful wherever divisibility sequences encode periods or synchronization. The entry index $z(p)$ acts as a period marker: knowing that $p$ is primitive for $F_n$ certifies that no smaller positive index produces divisibility by $p$.

The proper-divisor reduction is broadly portable. For any sequence $(A_n)$ satisfying a strong divisibility law of the form

$$
\gcd(A_m,A_n)=A_{\gcd(m,n)},
$$

a prime dividing $A_n$ is primitive if it avoids $A_d$ at every positive proper divisor $d$ of $n$. Thus divisor lattices can replace linear histories in other recurrence and divisibility sequences.

Mixed-radix systems model heterogeneous units: seconds, minutes, and hours; multi-level counters; hierarchical storage layouts; and combinatorial ranking schemes. The factorial specialization is especially important for permutations. At one stage of selecting an ordered arrangement there may be $i+1$ remaining choices, exactly matching the digit bound $c_i<i+1$. The resulting Lehmer-style code is unique because factorial numerals are unique.

The bridge also clarifies what data determine a numeral system. Running products determine place values and the size $B_k$ of each representable initial interval. This suggests a rigidity principle: truncation-compatible, place-preserving isomorphisms should exist precisely when two systems have the same running products. Successive quotients $B_{i+1}/B_i$ would then recover the local radices whenever division is nondegenerate.

## 9. Limitations and future work

The certified Fibonacci theorem stops at $10{,}000$. Its structural component does not fail beyond that point; rather, the finite residue certificate supplies no information there. The central open task in this framework is to prove a uniform lower bound $P_n>1$ for all sufficiently large $n$.

One route is analytic. Binet’s formula expresses $F_n$ through the dominant root $\varphi=(1+\sqrt5)/2$. The logarithm of $F_n$ grows essentially linearly with $n$, while inherited contributions arise from proper divisors. A successful estimate must control those contributions uniformly, not merely term by term. A Möbius-weighted cyclotomic factorization may organize the cancellation more sharply.

For mixed-radix systems, the next step is functoriality under truncation and refinement. Digit extraction is naturally compatible with dropping high positions. Refinement—splitting one radix into several factors—should correspond to associativity of running products. A complete treatment would formulate canonical equivalences between valid digit vectors and initial intervals and prove that these equivalences commute with such changes.

A second direction is classification. If two positive mixed-radix systems admit truncation-compatible, place-preserving numeral isomorphisms, interval cardinalities should force equality of running products. Conversely, equal running products should induce the required isomorphisms. Establishing this equivalence would identify running products as complete invariants of the place-preserving structure.

## 10. Conclusion

The Fibonacci part of this paper turns primitivity into a residue problem. Strong divisibility reduces all earlier indices to proper divisors; repeated GCD stripping removes inherited factors; and any prime left in a residue greater than $1$ is primitive. An exact finite certificate then gives a primitive prime divisor for every Fibonacci index $n$ satisfying $13\le n\le10{,}000$.

The numeral-system part turns factorial notation into a structural specialization. With radices $b_i=i+1$, running products are $i!$, validity bounds are $c_i<i+1$, and mixed-radix values are factorial values. General mixed-radix uniqueness therefore yields factorial uniqueness immediately.

Both developments demonstrate the value of isolating canonical structure. Removing inherited Fibonacci factors reveals new primes; removing notation-specific conventions reveals one general positional theory. The resulting theorems are precise about both their reach and their boundaries, and they identify concrete next steps toward unbounded primitive-divisor estimates and a functorial theory of mixed-radix representation.
