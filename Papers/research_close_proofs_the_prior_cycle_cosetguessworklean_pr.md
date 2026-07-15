# Running Products and Primitive Parts: Mixed-Radix Uniqueness and Fibonacci Primitive Divisors

## Abstract

Two forms of arithmetic novelty are studied through a common structural method: isolate the contribution inherited from earlier stages and examine the residual. First, a mixed-radix positional system is defined from a sequence of bases $b_i$ and running products $R_i=\prod_{j<i}b_j$. Valid digit strings have unique values, and the factorial number system is identified exactly with the specialization $b_i=i+1$. Consequently, uniqueness of factorial representations follows directly from general mixed-radix uniqueness. Second, for the Fibonacci sequence, strong divisibility reduces the detection of primitive prime divisors at index $n$ to exclusion at positive proper divisors of $n$. A primitive part is constructed by repeatedly stripping from $F_n$ all common prime-power factors with Fibonacci numbers at proper divisor indices. If that part exceeds $1$, any of its prime factors is primitive. Exact finite evaluation of this criterion, together with the prime-index case, yields: every $F_n$ with $13\le n\le 10000$ has a primitive prime divisor. Algorithms, complexity considerations, examples, applications, and the precise boundary between the finite result and the unbounded problem are presented.

## 1. Introduction

A positional numeral system separates an integer into layers. The lowest layer records a remainder, division removes it, and the process repeats. A divisibility sequence has a related but arithmetically richer layering: a term contains factors inherited from earlier terms, and a primitive factor is one appearing for the first time.

This paper develops these ideas in two settings. The first is the general mixed-radix number system. Rather than using a fixed base, it permits a base sequence $b_0,b_1,\ldots$. The accumulated products of these bases are the place weights. The main structural theorem is uniqueness of valid digit strings. The factorial number system then emerges without additional machinery: choosing $b_i=i+1$ makes the $i$th running product equal to $i!$.

The second setting is the Fibonacci sequence. A primitive prime divisor of $F_n$ is a prime dividing $F_n$ but no earlier positive-index term. The identity

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}
$$

shows that non-primitivity can always be witnessed at a positive proper divisor of $n$. This permits an explicit primitive-part construction: remove from $F_n$ every prime power shared with $F_d$ as $d$ ranges over the proper divisors of $n$. A nontrivial survivor supplies a primitive prime.

The resulting Fibonacci theorem is deliberately quantitative and finite: the construction has been exhaustively evaluated for $13\le n\le 10000$. No claim for larger indices is inferred from that evaluation. This distinction is mathematically essential and also clarifies the remaining route to an unbounded theorem: prove a suitable lower bound for the primitive part.

## 2. Mixed-radix positional systems

### 2.1. Definitions

Let $b=(b_i)_{i\ge 0}$ be a sequence of positive integers. Define the **running product** or **radix product** by

$$
R_0=1,\qquad R_i=\prod_{j=0}^{i-1}b_j\quad (i>0).
$$

Thus $R_{i+1}=b_iR_i$. Given a digit sequence $c=(c_i)_{i\ge 0}$ and a length $k$, define its truncated mixed-radix value by

$$
V_b(c;k)=\sum_{i=0}^{k-1}c_iR_i.
$$

The sequence $c$ is **valid through length $k$** if

$$
0\le c_i<b_i\qquad\text{for every }0\le i<k.
$$

When all $b_i=B$, the weights are $R_i=B^i$, recovering ordinary base-$B$ notation. The changing-base formulation includes many other encodings, including factorial digits and finite products of heterogeneous cyclic choices.

For nondegenerate extraction and the standard range theorem, it is natural to assume $b_i\ge 2$. The uniqueness statement itself also accommodates a base $1$ place: validity then forces the corresponding digit to be $0$.

### 2.2. The lower-block bound

**Lemma 2.1 (Lower-block bound).** If $c$ is valid through length $m$, then

$$
0\le V_b(c;m)<R_m.
$$

**Proof sketch.** Nonnegativity is immediate. For the strict upper bound, use induction on $m$. The empty sum is $0<R_0=1$. At the next stage,

$$
V_b(c;m+1)=V_b(c;m)+c_mR_m.
$$

By induction, $V_b(c;m)\le R_m-1$, while validity gives $c_m\le b_m-1$. Hence

$$
V_b(c;m+1)\le (R_m-1)+(b_m-1)R_m=b_mR_m-1=R_{m+1}-1.
$$

This bound formalizes the basic place-value principle: all lower positions together cannot equal one unit of the next position.

### 2.3. Uniqueness

**Theorem 2.2 (Mixed-Radix Uniqueness).** Let $c$ and $d$ be valid digit sequences through length $k$. If

$$
V_b(c;k)=V_b(d;k),
$$

then

$$
c_i=d_i\qquad\text{for every }i<k.
$$

**Proof sketch by successive remainders.** Reduce the equality modulo $b_0$. Since $R_0=1$ and $b_0$ divides every $R_i$ for $i>0$, one obtains $c_0\equiv d_0\pmod{b_0}$. Both digits lie in the same complete residue interval $[0,b_0)$, so $c_0=d_0$. Subtract the common first digit and divide by $b_0$. The resulting equality is the mixed-radix value equality for the shifted base and digit sequences. Iteration proves equality at every position.

An alternative proof chooses the greatest index $m$ at which the strings differ. The contribution at position $m$ has absolute value at least $R_m$, whereas Lemma 2.1 bounds the total possible discrepancy below $m$ by less than $R_m$. Higher contributions agree by choice of $m$, yielding a contradiction.

### 2.4. Extraction and existence

For bases $b_i\ge 2$, digits can be extracted from an integer $N$ by repeated Euclidean division:

$$
c_i=N_i\bmod b_i,\qquad N_{i+1}=\left\lfloor\frac{N_i}{b_i}\right\rfloor,
$$

starting with $N_0=N$. The reconstruction identity after $t$ steps is

$$
N=\sum_{i=0}^{t-1}c_iR_i+N_tR_t.
$$

It follows by induction from $N_i=c_i+b_iN_{i+1}$. If $0\le N<R_k$, then $N_k=0$, so

$$
N=V_b(c;k).
$$

Each extracted digit satisfies $0\le c_i<b_i$. Together with Theorem 2.2, this gives the expected bijection between integers in $[0,R_k)$ and valid strings of length $k$. Although the present results emphasize uniqueness and the factorial specialization, this extraction procedure is the natural computational realization of the theory.

## 3. The factorial number system as a specialization

### 3.1. Factorial digits

The **factorial number system** assigns weight $i!$ to digit position $i$. A length-$k$ digit string has value

$$
V_!(c;k)=\sum_{i=0}^{k-1}c_i i!,
$$

and is valid when

$$
0\le c_i\le i.
$$

The digit at position $0$ is necessarily $0$. This convention is compatible with $0!=1$ and gives a uniform indexing rule.

### 3.2. Bridge theorem

**Theorem 3.1 (Factorial–Mixed-Radix Bridge).** Set $b_i=i+1$. Then, for every $i$,

$$
R_i=i!.
$$

For every digit sequence $c$ and length $k$,

$$
V_b(c;k)=V_!(c;k),
$$

and mixed-radix validity through length $k$ is equivalent to factorial validity through length $k$.

**Proof sketch.** The running-product identity is

$$
R_i=\prod_{j=0}^{i-1}(j+1)=1\cdot2\cdots i=i!.
$$

Substituting this equality term by term into the mixed-radix value gives the factorial value. The digit inequality $c_i<b_i=i+1$ is equivalent, for natural-number digits, to $c_i\le i$.

**Corollary 3.2 (Uniqueness of Factorial Representations).** If $c$ and $d$ are valid factorial digit sequences through length $k$ and

$$
\sum_{i=0}^{k-1}c_i i!=\sum_{i=0}^{k-1}d_i i!,
$$

then $c_i=d_i$ for every $i<k$.

**Proof sketch.** By Theorem 3.1, the hypotheses are precisely mixed-radix validity and equality for the bases $b_i=i+1$. The conclusion follows from Theorem 2.2.

### 3.3. Example and application

Repeated division by $1,2,3,4,\ldots$ can be started harmlessly at base $1$, producing a forced zero digit, or operationally at base $2$. For $N=463$, the valid factorial expansion is

$$
463=0\cdot0!+1\cdot1!+0\cdot2!+1\cdot3!+4\cdot4!+3\cdot5!.
$$

The low-to-high digits are $(0,1,0,1,4,3)$, and each satisfies $c_i\le i$.

Factorial digits naturally rank permutations. For a permutation of $m$ ordered objects, the coefficient of $(m-1)!$ selects the first object among $m$ choices, the coefficient of $(m-2)!$ selects the next among the remaining $m-1$, and so on. The changing digit bounds exactly match the shrinking choice sets. Uniqueness guarantees that two valid selection histories cannot have the same rank.

## 4. Fibonacci divisibility and first appearances

### 4.1. Definitions

Let the Fibonacci sequence be

$$
F_0=0,\qquad F_1=1,\qquad F_{n+2}=F_{n+1}+F_n.
$$

A prime $p$ is a **primitive prime divisor** of $F_n$ if

$$
p\mid F_n
$$

and

$$
p\nmid F_k\qquad\text{for every integer }k\text{ with }0<k<n.
$$

The **entry point** of a prime $p$, when it exists, is the least positive integer $\alpha(p)$ such that $p\mid F_{\alpha(p)}$. In these terms, $p$ is primitive at $n$ exactly when $\alpha(p)=n$.

The central structural input is the strong divisibility law.

**Theorem 4.1 (Strong Divisibility of Fibonacci Numbers).** For all nonnegative integers $m,n$,

$$
\gcd(F_m,F_n)=F_{\gcd(m,n)}.
$$

This identity implies that common prime divisors of two Fibonacci terms descend to the term indexed by the greatest common divisor of their indices.

### 4.2. Reduction to proper divisors

**Lemma 4.2 (Common-Divisor Descent).** If $p\mid F_n$ and $p\mid F_k$, then

$$
p\mid F_{\gcd(n,k)}.
$$

**Proof sketch.** The prime $p$ divides $\gcd(F_n,F_k)$. By Theorem 4.1 this greatest common divisor equals $F_{\gcd(n,k)}$.

**Lemma 4.3 (Proper-Divisor Witness for Non-Primitivity).** Let $n>0$, and suppose a prime $p$ divides $F_n$. If $p$ is not primitive at $n$, then there exists a positive proper divisor $d$ of $n$ such that $p\mid F_d$.

**Proof sketch.** Non-primitivity supplies $k$ with $0<k<n$ and $p\mid F_k$. Put $d=\gcd(n,k)$. Then $d\mid n$, $d>0$, and $d\le k<n$. Lemma 4.2 gives $p\mid F_d$.

**Corollary 4.4 (Proper-Divisor Reduction).** Suppose $p$ is prime and $p\mid F_n$. If $p$ divides no $F_d$ with $d$ a positive proper divisor of $n$, then $p$ is primitive at $n$.

The corollary is the contrapositive of Lemma 4.3. It is algorithmically decisive: one need not compare $F_n$ with all earlier Fibonacci numbers.

### 4.3. Prime indices

**Proposition 4.5 (Prime-Index Case).** If $n\ge 3$ is prime, then $F_n$ has a primitive prime divisor.

**Proof sketch.** Since $F_n>1$ for $n\ge 3$, it has a prime factor $p$. The only positive proper divisor of prime $n$ is $1$, and $F_1=1$, so $p\nmid F_1$. Corollary 4.4 shows that $p$ is primitive.

This isolates the substantive finite computation to composite indices.

## 5. The primitive-part construction

### 5.1. Complete gcd stripping

For positive integers $r$ and $m$, define **complete stripping of $m$ from $r$** by the terminating process

$$
r\leftarrow r/\gcd(r,m)
$$

whenever $\gcd(r,m)>1$. The process stops because each nontrivial update strictly decreases the positive integer $r$. Denote the final value by $S(r,m)$.

Let $D(n)$ be the set of positive proper divisors of $n$. The **Fibonacci primitive part** considered here is obtained by starting with $F_n$ and applying complete stripping against $F_d$ for each $d\in D(n)$:

$$
\Phi(n)=S(\cdots S(S(F_n,F_{d_1}),F_{d_2})\cdots,F_{d_t}),
$$

where $D(n)=\{d_1,\ldots,d_t\}$. The order does not affect the intended prime-support interpretation: complete stripping removes every prime power whose prime occurs in the stripping argument. For the criterion below, a fixed enumeration suffices.

### 5.2. Stripping invariants

**Lemma 5.1 (Divisibility Invariant).** For all positive $r,m$, the survivor $S(r,m)$ divides $r$.

**Proof sketch.** Each update divides the current value by one of its divisors. A composition of such updates remains a divisor of the initial value.

**Lemma 5.2 (Coprimality Invariant).** For all positive $r,m$, the survivor satisfies

$$
\gcd(S(r,m),m)=1.
$$

**Proof sketch.** If a common prime remained, the gcd would exceed $1$ and another stripping step would be possible, contradicting termination. More explicitly, each update removes the current gcd; strict descent ensures termination, and the stopping condition is precisely gcd equal to $1$.

**Lemma 5.3 (Primitive-Part Invariants).** The integer $\Phi(n)$ divides $F_n$. Moreover, for every positive proper divisor $d$ of $n$,

$$
\gcd(\Phi(n),F_d)=1.
$$

**Proof sketch.** Divisibility follows by repeated application of Lemma 5.1. When the stage corresponding to $d$ is processed, Lemma 5.2 makes the current survivor coprime to $F_d$. Every later survivor divides that current value, and a divisor of a number coprime to $F_d$ remains coprime to $F_d$.

### 5.3. Criterion for a primitive divisor

**Theorem 5.4 (Primitive-Part Criterion).** Let $n\ge 3$. If

$$
\Phi(n)>1,
$$

then $F_n$ has a primitive prime divisor.

**Proof sketch.** Choose a prime $p$ dividing $\Phi(n)$. By Lemma 5.3, $\Phi(n)\mid F_n$, so $p\mid F_n$. The same lemma says that $\Phi(n)$ is coprime to every $F_d$ at a positive proper divisor $d$ of $n$, so $p$ divides none of those terms. Corollary 4.4 then proves that $p$ is primitive.

The criterion separates the problem into two independent obligations: a structural argument, already contained in Theorem 5.4, and a quantitative or computational argument proving $\Phi(n)>1$ on the desired range.

## 6. The finite primitive-divisor theorem

**Theorem 6.1 (Composite Indices in the Finite Range).** If $n$ is composite and

$$
13\le n\le 10000,
$$

then $F_n$ has a primitive prime divisor.

**Proof sketch.** Exhaustive exact evaluation of the primitive-part algorithm on every composite integer in the stated interval yields $\Phi(n)>1$. Theorem 5.4 then produces a primitive prime divisor.

The evaluation uses integer arithmetic only. For each $n$, proper divisors are enumerated; Fibonacci values are computed exactly; and repeated gcd division produces $\Phi(n)$. No numerical approximation enters the predicate $\Phi(n)>1$.

**Theorem 6.2 (Finite Fibonacci Primitive-Divisor Theorem).** For every integer $n$ satisfying

$$
13\le n\le 10000,
$$

there exists a prime $p$ such that

$$
p\mid F_n
$$

and

$$
p\nmid F_k\qquad\text{for all }0<k<n.
$$

**Proof sketch.** If $n$ is prime, apply Proposition 4.5. If $n$ is composite, apply Theorem 6.1. These cases exhaust all integers in the interval.

### 6.1. Why the upper bound is essential

Theorem 6.2 states exactly what its two ingredients prove. The structural criterion is unbounded, but the inequality $\Phi(n)>1$ has here been established by exhaustive evaluation only through $10000$. Therefore the upper bound cannot be discarded without a new mathematical estimate.

A promising target is the stronger inequality

$$
\Phi(n)>n
$$

for composite $n\ge 13$. Such a bound immediately implies $\Phi(n)>1$ and would therefore close the structural argument for all such $n$. Establishing it is expected to require both exponential growth estimates for Fibonacci numbers and precise control of the powers of primes inherited from earlier terms.

## 7. Algorithms and complexity

### 7.1. Mixed-radix digit extraction

Given $N$, a base list $b_0,\ldots,b_{k-1}$, and $0\le N<R_k$, perform $k$ Euclidean divisions. At stage $i$, output $N\bmod b_i$ and replace $N$ by $\lfloor N/b_i\rfloor$. Correctness follows from the reconstruction invariant in Section 2.4.

With schoolbook arithmetic and $L$-bit inputs, the bit complexity depends on division costs and is roughly $O(kL^2)$ in a conservative model; using fast division lowers the arithmetic factor. Storage is $O(k+L)$ for the digit list and current quotient. For factorial representation, the bases are $1,2,3,\ldots$, and the same algorithm applies without modification.

### 7.2. Primitive-part extraction

For each positive proper divisor $d$ of $n$, repeatedly compute $g=\gcd(r,F_d)$ and set $r\leftarrow r/g$ until $g=1$. Euclid's algorithm makes each gcd polynomial in the bit lengths of its operands. Every successful stripping step at least halves $r$, so there are at most $\lfloor\log_2 F_n\rfloor=O(n)$ successful steps overall for one divisor, and generally far fewer because an entire gcd is removed at once.

The dominant practical cost is handling the $O(n)$-bit integer $F_n$ and the relevant Fibonacci terms. Fast doubling computes $F_t$ using $O(\log t)$ big-integer multiplication stages. Enumerating divisors by trial division takes $O(\sqrt n)$ small-integer tests; scanning all $d<n$ is simpler but asymptotically inferior. The demonstration implementation favors clarity and exactness over optimized asymptotics.

### 7.3. Direct validation

For modest $n$, a candidate primitive prime can be checked directly by testing divisibility against $F_1,\ldots,F_{n-1}$. This costs more than the proper-divisor reduction but provides an independent explanatory view. The reduction replaces $n-1$ prior terms by the usually much smaller set $D(n)$.

## 8. Applications and broader interpretation

Mixed-radix systems occur whenever choices have position-dependent capacities. Calendar arithmetic, angular units, tensor indexing, combinatorial ranking, and scheduling all exhibit heterogeneous place sizes. The running-product viewpoint gives a single correctness argument for their encoders and decoders. The factorial specialization is especially important for permutation ranking and unranking: it turns a permutation into an integer without collisions and supports exact recovery.

Primitive divisors describe the arrival of new arithmetic information in recurrence sequences. They influence multiplicative orders, periodicity modulo primes, and the factorization patterns of sequence terms. The proper-divisor reduction is valuable because it changes the shape of the search. Instead of asking whether a factor appeared anywhere in a long history, one asks whether it occurs on a small index lattice controlled by divisibility.

The conceptual parallel is therefore one of residualization. In mixed radix, the remainder modulo the current base is retained while the quotient carries the unresolved higher places. In the Fibonacci setting, common gcd factors are removed while the coprime residual carries the genuinely new prime support. Both procedures succeed because an invariant links local elimination to a global uniqueness or novelty statement.

## 9. Discussion and limitations

The factorial bridge is exact and unrestricted: every length, every digit sequence, and every relevant value identity follows from the running-product equality $R_i=i!$. It shows that factorial uniqueness is not an isolated theorem but a direct instance of a general positional principle.

The Fibonacci result has a different logical profile. Strong divisibility and the primitive-part criterion hold generally. The finite interval arises only in the nontriviality step for composite indices. It would be incorrect to present finite evaluation as an argument for all larger $n$. The clean separation of structure from magnitude is useful precisely because it identifies the missing theorem: a lower bound for $\Phi(n)$.

There is also a computational distinction between removing shared prime support and factoring $F_n$. Complete gcd stripping does not require a full factorization of each Fibonacci number. It uses gcd computations to remove inherited support and factors only a nontrivial survivor when a witness prime is desired. This can be substantially more tractable than complete factorization, although the integers still grow linearly in bit length with $n$.

## 10. Future work

Three directions are immediate.

First, the extraction procedure should be packaged as a uniform theorem for arbitrary base sequences with $b_i\ge 2$: integers below $R_k$ are in bijection with valid length-$k$ digit strings, and one base-independent algorithm computes the bijection and its inverse. The reconstruction invariant already contains the core proof.

Second, the finite Fibonacci theorem points to a single quantitative conjecture: for every composite $n\ge 13$, the primitive part satisfies $\Phi(n)>n$. Since Theorem 5.4 needs only $\Phi(n)>1$, this stronger estimate would supply ample margin. The likely proof combines golden-ratio growth of $F_n$ with upper bounds on inherited factors.

Third, those inherited factors should be governed by a lifting-the-exponent law. If $\alpha(p)$ is the entry point of a prime $p$, one expects the $p$-adic valuation of $F_n$ to equal the valuation at $F_{\alpha(p)}$ plus the valuation of $n/\alpha(p)$ whenever $\alpha(p)\mid n$, with suitable attention to exceptional primes and with analogues for regular Lucas sequences. Such a law would turn prime-power multiplicities in Fibonacci terms into arithmetic of their indices.

## 11. Conclusion

The running product $R_i=\prod_{j<i}b_j$ contains the essential geometry of positional notation. It yields a lower-block bound, uniqueness of valid mixed-radix strings, and the factorial number system by the specialization $b_i=i+1$. In parallel, the Fibonacci strong-divisibility identity funnels every earlier occurrence of a prime factor down to a proper divisor index. Complete gcd stripping then produces a primitive part whose nontriviality guarantees a genuinely new prime.

These ingredients establish a precise finite theorem: every Fibonacci number $F_n$ with $13\le n\le 10000$ possesses a primitive prime divisor. The argument also makes its own frontier explicit. The passage beyond $10000$ is not a matter of further finite checking in principle, but of proving growth and valuation estimates strong enough to ensure that the primitive residual never disappears.