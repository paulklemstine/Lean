# Multiplicative Cyclotomic Norms, Additive Braid Writhe, and Finite-Range Primitive Divisors

**Author:** Aristotle  
**Date:** July 18, 2026

## Abstract

We study three exact algebraic certificates that compress structured objects into tractable arithmetic data. First, integer polynomials evaluated at a primitive cube root of unity are represented in Eisenstein coordinates, where the quadratic norm $N(a+b\omega)=a^2-ab+b^2$ is multiplicative. We prove the iteration formula $N(x^k)=N(x)^k$ and use it to analyze three specified polynomial signatures. Their values are $1$, $2+2\omega$, and $-1-\omega$, with norms $1$, $4$, and $1$; hence the middle signature is separated from both comparators, while the other two necessarily collide under this statistic. Second, we use exponent-sum writhe on Artin braid groups. Since every generator has writhe $1$, the map $k\mapsto\sigma_i^k$ is injective on natural numbers, and in particular the standard two-strand trefoil word $\sigma_1^3$ is nonidentity. We explain why zero writhe does not classify braids and why braid nonidentity must not be conflated with classification of knot closures. Third, we state a completely certified finite-range primitive-divisor result: every Fibonacci number $F_n$ with $13\le n\le10000$ has a prime divisor absent from all earlier positive Fibonacci terms. Algorithms for Eisenstein evaluation, norm iteration, writhe calculation, and primitive-divisor search are given, together with complexity analyses and applications. The common theme is calibrated invariance: each certificate is exact and useful within a sharply delimited scope.

## 1. Introduction

An invariant replaces a complicated object by simpler data while respecting a chosen equivalence or operation. The value of an invariant depends on two complementary facts: it must preserve enough structure to prove something, and its information loss must be understood well enough to avoid overclaiming.

This paper examines that balance in three settings. The first is cyclotomic arithmetic. Evaluation of an integer polynomial at a cube root of unity sends an arbitrarily long coefficient list into a two-dimensional lattice. A quadratic norm then sends the lattice point to a nonnegative integer. The resulting compression is strong enough to distinguish one proposed signature from two alternatives and to obey an exact exponential law under repeated multiplication. It is not strong enough to distinguish all three signatures.

The second setting is the Artin braid group. Writhe sends a braid to the integer obtained by summing signed crossings in a braid word. It immediately distinguishes all nonnegative powers of any fixed generator and proves that a familiar trefoil braid word is not the identity. Yet balanced words lie in its kernel, so writhe cannot classify all braids. Moreover, braid equality and isotopy of braid closures are different relations.

The third setting is the Fibonacci sequence. A primitive prime divisor of $F_n$ is a prime that divides $F_n$ but no earlier positive term. Such a prime acts as a certificate that index $n$ contributes new divisibility. We record the result throughout the finite interval $13\le n\le10000$. The finite upper endpoint is part of the theorem and prevents an unjustified transition from bounded computation to an unbounded assertion.

These examples support a unified principle: useful mathematical compression requires an exact definition, a compatibility theorem, a demonstration, and an explicit account of failure modes.

## 2. Eisenstein arithmetic and cyclotomic evaluation

### 2.1. Definitions

Fix a complex number $\omega$ satisfying

$$
\omega^2+\omega+1=0.
$$

It follows that $\omega^3=1$ and $\omega\ne1$. The ring of **Eisenstein integers** is

$$
\mathbb Z[\omega]=\{a+b\omega:a,b\in\mathbb Z\}.
$$

We identify $a+b\omega$ with the coordinate pair $(a,b)$. Reducing $\omega^2$ via $\omega^2=-1-\omega$ gives

$$
(a+b\omega)(c+d\omega)
=(ac-bd)+(ad+bc-bd)\omega.
$$

Thus coordinate multiplication is

$$
(a,b)\star(c,d)=(ac-bd,\,ad+bc-bd).
$$

The **Eisenstein squared norm** is the map $N:\mathbb Z[\omega]\to\mathbb N$ defined by

$$
N(a+b\omega)=a^2-ab+b^2.
$$

The expression is nonnegative because

$$
a^2-ab+b^2=\left(a-\frac b2\right)^2+\frac34b^2.
$$

For $x\in\mathbb Z[\omega]$, define natural powers recursively by $x^0=1$ and $x^{k+1}=xx^k$.

For an integer polynomial $p(t)=\sum_{j=0}^m c_jt^j$, its **cube-root signature** is $p(\omega)\in\mathbb Z[\omega]$, and its **cube-root norm statistic** is $N(p(\omega))$.

### 2.2. Multiplicativity

**Theorem 2.1 (Eisenstein norm multiplicativity).** For all $x,y\in\mathbb Z[\omega]$,

$$
N(xy)=N(x)N(y).
$$

**Proof sketch.** Write $x=a+b\omega$ and $y=c+d\omega$. Their product has coordinates

$$
u=ac-bd,
\qquad
v=ad+bc-bd.
$$

Substitution gives $N(xy)=u^2-uv+v^2$. Expanding and collecting terms yields

$$
u^2-uv+v^2=(a^2-ab+b^2)(c^2-cd+d^2).
$$

which is $N(x)N(y)$. An alternative conceptual proof uses complex conjugation: since $\overline\omega=\omega^2$, one has $N(x)=x\overline{x}$, and therefore $N(xy)=xy\overline{x}\,\overline{y}=N(x)N(y)$. $\square$

**Corollary 2.2 (Power law).** For every $x\in\mathbb Z[\omega]$ and every natural number $k$,

$$
N(x^k)=N(x)^k.
$$

**Proof sketch.** Induct on $k$. At $k=0$, $x^0=1$ and both sides equal $1$. Assuming the result at $k$, Theorem 2.1 gives

$$
N(x^{k+1})=N(xx^k)=N(x)N(x^k)=N(x)N(x)^k=N(x)^{k+1}.
$$

This completes the induction. $\square$

The corollary gives exact growth, not merely an asymptotic estimate. If $N(x)=q$, then the norm after $k$ repeated multiplications is precisely $q^k$.

### 2.3. Evaluation of three signatures

Consider three integer-polynomial signatures specified by their cube-root values:

$$
S_{\mathrm{lin}}=1,
\qquad
S_{\mathrm{cre}}=2+2\omega,
\qquad
S_{\mathrm{conf}}=-1-\omega.
$$

Their norms are calculated directly:

$$
N(S_{\mathrm{lin}})=N(1)=1,
$$

$$
N(S_{\mathrm{cre}})=N(2+2\omega)=2^2-2\cdot2+2^2=4,
$$

and

$$
N(S_{\mathrm{conf}})=N(-1-\omega)=(-1)^2-(-1)(-1)+(-1)^2=1.
$$

**Theorem 2.3 (Selective separation).** The cube-root norm statistic separates the creative signature from each of the linear and confused signatures:

$$
N(S_{\mathrm{cre}})=4\ne1=N(S_{\mathrm{lin}})=N(S_{\mathrm{conf}}).
$$

**Proof sketch.** This is the direct calculation above. $\square$

**Proposition 2.4 (Norm collision).** The cube-root norm statistic does not separate the linear and confused signatures.

**Proof sketch.** Both norms equal $1$. Therefore no decision rule based only on this single integer can distinguish these two inputs. $\square$

This collision has a structural explanation. Evaluation at $\omega$ already identifies powers whose exponents agree modulo $3$. Passing from $p(\omega)$ to $N(p(\omega))$ then identifies lattice points related by the symmetries of the hexagonal norm. The statistic is consequently a many-to-one map.

### 2.4. Algorithmic evaluation

Horner's method evaluates $p(\omega)$ without constructing large powers. Starting with $z=0$, process coefficients from highest degree to lowest and replace $z$ by $z\omega+c_j$. Each step uses a constant number of integer additions and multiplications.

**Algorithm 2.5 (Horner evaluation in Eisenstein coordinates).** Given coefficients $c_0,\ldots,c_m$, initialize $(a,b)=(0,0)$. For $j=m,m-1,\ldots,0$, multiply $(a,b)$ by $(0,1)$ using $\star$, then add $(c_j,0)$. Return $(a,b)$ and $a^2-ab+b^2$.

With unit-cost integer arithmetic, this uses $O(m)$ operations and $O(1)$ auxiliary coordinate storage. Bit complexity depends on coefficient sizes, although reduction modulo $\omega^2+\omega+1$ keeps the algebraic dimension fixed.

To compute $x^k$, binary exponentiation requires $O(\log k)$ Eisenstein multiplications rather than $k$ sequential multiplications. If only the norm is required, Corollary 2.2 reduces the task to integer exponentiation of $N(x)$.

## 3. Writhe in Artin braid groups

### 3.1. Braid groups and exponent sum

For a positive integer $n$, the Artin braid group on $n+1$ strands is generated by $\sigma_1,\ldots,\sigma_n$, subject to

$$
\sigma_i\sigma_j=\sigma_j\sigma_i
\quad\text{when }|i-j|\ge2,
$$

and

$$
\sigma_i\sigma_{i+1}\sigma_i
=
\sigma_{i+1}\sigma_i\sigma_{i+1}.
$$

A braid word is a product of symbols $\sigma_i$ and $\sigma_i^{-1}$. Define the exponent sum of a word by adding $1$ for each $\sigma_i$ and $-1$ for each $\sigma_i^{-1}$.

Both defining relations preserve exponent sum: the commuting relation has two positive letters on each side, and the braid relation has three. Cancellation of $\sigma_i\sigma_i^{-1}$ removes one positive and one negative letter. Hence exponent sum descends to a well-defined function $w$ on braid elements. It satisfies

$$
w(\beta\gamma)=w(\beta)+w(\gamma),
\qquad
w(1)=0,
\qquad
w(\sigma_i)=1.
$$

We call $w(\beta)$ the **writhe** of the braid $\beta$.

### 3.2. Injectivity on generator powers

**Theorem 3.1 (Distinct natural powers of a generator).** Fix any Artin generator $\sigma_i$. The map

$$
\mathbb N\longrightarrow B_{n+1},
\qquad
k\longmapsto\sigma_i^k,
$$

is injective.

**Proof sketch.** Suppose $\sigma_i^a=\sigma_i^b$. Apply writhe to both sides. Additivity and $w(\sigma_i)=1$ imply

$$
a=w(\sigma_i^a)=w(\sigma_i^b)=b.
$$

Thus $a=b$. $\square$

The same calculation extends to integer powers and exhibits the subgroup generated by $\sigma_i$ as infinite cyclic. The natural-power form is enough to show that every braid group with at least one Artin generator is infinite.

### 3.3. A nonidentity certificate

In the two-strand braid group, the word $\sigma_1^3$ is a standard braid whose closure gives the usual trefoil representative.

**Corollary 3.2 (Trefoil-word nonidentity).** The braid $\sigma_1^3$ is not the identity braid.

**Proof sketch.** Its writhe is $3$, while the identity has writhe $0$. Equal braids have equal writhe, so they cannot be equal. Equivalently, Theorem 3.1 says that $\sigma_1^3\ne\sigma_1^0$. $\square$

The statement concerns equality in the braid group. It should not be enlarged without additional theory. A braid word can be closed to form a link, but distinct braids may have isotopic closures. Closure equivalence is governed not only by braid relations but also by Markov moves. Thus nonidentity of $\sigma_1^3$ certifies a property of the braid representative; identifying or classifying the resulting knot requires closure-sensitive invariants and theorems.

### 3.4. Kernel and limitations

**Proposition 3.3 (Balanced words have zero writhe).** If a braid word contains the same total number of positive and negative generator occurrences, then its writhe is zero.

**Proof sketch.** The exponent sum is the number of positive letters minus the number of negative letters. Equal counts give zero. $\square$

The converse is false as a classification principle: zero writhe does not force a braid to be the identity. For example, commutators have zero writhe because additivity gives

$$
w(\alpha\beta\alpha^{-1}\beta^{-1})
=w(\alpha)+w(\beta)-w(\alpha)-w(\beta)=0,
$$

although braid groups with sufficiently many strands contain nontrivial commutators. Writhe is therefore a one-way nontriviality detector: $w(\beta)\ne0$ implies $\beta\ne1$, but $w(\beta)=0$ is inconclusive.

This limitation parallels Proposition 2.4. Both the Eisenstein norm and writhe intentionally collapse information. The first forgets lattice direction; the second records only total exponent sum and forgets generator order and index.

### 3.5. Writhe algorithm

Given a signed word represented by nonzero integers, with $i$ denoting $\sigma_i$ and $-i$ denoting $\sigma_i^{-1}$, writhe is computed by summing signs.

**Algorithm 3.4 (Signed exponent-sum certificate).** Initialize $s=0$. For each letter $\ell$, add $1$ if $\ell>0$ and $-1$ if $\ell<0$. Return $s$.

For a word of length $L$, the running time is $O(L)$ and auxiliary space is $O(1)$. The result can immediately refute identity when nonzero. It cannot confirm identity when zero.

## 4. Primitive prime divisors in a finite Fibonacci range

### 4.1. Definitions

Define the Fibonacci sequence by

$$
F_0=0,
\qquad
F_1=1,
\qquad
F_{n+2}=F_{n+1}+F_n.
$$

A prime $p$ is a **primitive prime divisor** of $F_n$ if

$$
p\mid F_n
$$

and

$$
p\nmid F_k
\quad\text{for every integer }k\text{ with }0<k<n.
$$

Primitivity is index-sensitive. A prime may divide many later Fibonacci numbers but is primitive only at its first positive index of appearance.

### 4.2. The finite-range theorem

**Theorem 4.1 (Primitive divisors from index $13$ through $10000$).** For every integer $n$ with

$$
13\le n\le10000,
$$

there exists a prime $p$ such that $p\mid F_n$ and $p\nmid F_k$ for all $k$ satisfying $0<k<n$.

**Proof sketch.** Split according to whether $n$ is prime or composite. For prime $n$ in the stated range, the prime-index primitive-divisor argument yields a prime factor of $F_n$ absent from every earlier positive Fibonacci term. For composite $n$, isolate the factor of $F_n$ coprime to the product of all earlier terms, equivalently the portion supported on prime factors whose first Fibonacci occurrence is exactly $n$. A complete finite check on composite indices in the range establishes that this coprime part exceeds $1$. Any prime factor of it divides $F_n$ and no earlier $F_k$, so it is primitive. The prime and composite cases cover every $n$ in the interval. $\square$

The theorem's quantifiers are important. It is a uniform assertion for all $9988$ indices in a stated interval, but it does not by itself assert an unbounded theorem for all $n\ge13$. An infinite extension would require a separate tail argument, such as a valid growth estimate or a general primitive-divisor theorem.

### 4.3. Examples and computation

At index $13$,

$$
F_{13}=233,
$$

and $233$ divides no earlier positive Fibonacci number. At index $14$,

$$
F_{14}=377=13\cdot29.
$$

The factor $13$ is not primitive because $13\mid F_7$, whereas $29$ first appears at index $14$. At index $15$,

$$
F_{15}=610=2\cdot5\cdot61,
$$

and $61$ supplies the primitive factor.

A straightforward demonstration algorithm computes $F_n$, factors it, and for each prime factor finds the least positive index at which the Fibonacci recurrence is zero modulo that prime. A factor is primitive precisely when this first index equals $n$.

**Algorithm 4.2 (Primitive Fibonacci divisor search).** Compute $F_n$. Factor $F_n$ into distinct primes. For each factor $p$, iterate the Fibonacci recurrence modulo $p$ from index $1$ through $n$ and record the first zero. Return those primes whose first zero occurs at $n$.

Using trial division, factorization costs $O(\sqrt{F_n})$ arithmetic divisions in the worst case, which is suitable only for small demonstrations because $F_n$ grows exponentially in $n$. Once factors are known, modular first-occurrence testing takes $O(n)$ modular additions per factor and constant auxiliary state. More advanced integer factorization and rank-of-apparition methods are needed for large indices.

## 5. A unified view: homomorphisms, norms, and first occurrence

The three settings differ, but each certificate is compatible with a central operation.

For Eisenstein integers, multiplication in a rank-two lattice becomes multiplication in $\mathbb N$:

$$
N(xy)=N(x)N(y).
$$

For braids, concatenation becomes addition in $\mathbb Z$:

$$
w(\beta\gamma)=w(\beta)+w(\gamma).
$$

For Fibonacci divisibility, a primitive prime records the least index at which a modular recurrence reaches zero. It converts a global history of divisibility into a first-occurrence certificate.

These compatibilities make the certificates computationally useful. Exponential norm growth can be obtained without expanding powers. A nonzero writhe refutes braid identity without solving the full word problem. A primitive divisor witnesses new arithmetic content without comparing complete factorizations of all earlier terms.

The losses are equally systematic. The norm is invariant under symmetries of the Eisenstein lattice, so different points can share a norm. Writhe is the abelian exponent-sum quotient, so it annihilates balanced structure. Primitive-divisor searches depend on factorization or equivalent divisibility information and become computationally costly at large indices.

## 6. Applications

Cyclotomic evaluation is a compact spectral filter. Because $\omega^3=1$, it groups polynomial coefficients by residue class modulo $3$. It can be used to detect three-periodic structure, analyze cyclic recurrences, or produce exact integer-valued features. The power law is particularly useful when signatures are composed multiplicatively: repeated composition produces predictable norm growth.

Writhe is an inexpensive preprocessing invariant for braid computations. Before attempting normal forms or more sophisticated representations, one may compute writhe. A mismatch immediately proves two braids unequal. The distinct-powers theorem also supplies a simple source of infinite families and excludes accidental periodicity of a generator.

Primitive divisors are relevant to recurrence arithmetic, order calculations modulo primes, and certificates of novelty in divisibility sequences. If $p$ is primitive at index $n$, then the Fibonacci sequence modulo $p$ reaches zero for the first time at $n$, encoding a precise modular period constraint.

## 7. Discussion and safeguards

Three safeguards govern interpretation.

First, a separating statistic need not be a classifier. The values $1$, $4$, and $1$ prove selective separation but disprove three-way separation. Any application that treats the norm as a total ranking discards the observed collision.

Second, the equivalence relation must match the invariant. Writhe is well-defined for braid equality. A knot or link obtained by closing a braid is studied under ambient isotopy, and Markov moves can change the braid representative. Claims about closures require an invariant shown to respect the relevant moves.

Third, bounded evidence must remain bounded in the theorem statement. The Fibonacci conclusion is complete for $13\le n\le10000$. Extending it beyond the upper endpoint requires a mathematically independent proof of the tail.

These are not merely cautions; they are part of the results. A calibrated invariant comes with both a theorem of sensitivity and a theorem or example of insensitivity.

## 8. Future work

For cyclotomic signatures, one can reduce collisions by retaining the full Eisenstein coordinate $p(\omega)$ instead of only its norm, or by evaluating at several roots of unity. A multi-frequency signature could preserve computational simplicity while separating examples that collide at one frequency.

For braids, writhe can be combined with noncommutative representations, normal forms, or closure invariants. An efficient hierarchy would begin with writhe and invoke more expensive tests only when simpler invariants collide. A separate development should distinguish invariance under braid relations, conjugation, stabilization, and Reidemeister moves.

For Fibonacci numbers, the natural next step is an unbounded primitive-divisor theorem supported by a genuine tail argument. Computationally, trial division should be replaced by efficient factorization and modular rank-of-apparition algorithms. Conceptually, analogous first-occurrence questions may be asked for Lucas sequences and other divisibility recurrences.

A further research program concerns Boolean-poset avoidance through linear closure. Four directions are especially concrete: obtaining explicit finite constants that improve on three middle layers for weakly $D_6$-free families; generalizing rank-based constructions to representable matroids; proving stability results for near-extremal weakly $D_6$-free families; and resolving whether weakly $D_5$-free families exceed three middle layers by a positive asymptotic proportion.

## 9. Reproducible numerical experiments

The formulas in this paper support three transparent experiments. First, represent an Eisenstein integer by a pair of ordinary integers. Coordinate multiplication and the norm formula then permit exact calculations with no floating-point approximation to $\omega$. Testing a sample such as $x=2+\omega$, whose norm is $3$, gives the sequence $N(x^k)=1,3,9,27,\ldots$. This simultaneously illustrates multiplicativity and checks the exponent convention at $k=0$.

Second, encode a braid word as a list of signed generator indices. The words $\sigma_1^k$ have lists consisting of $k$ positive entries and hence writhe $k$. A balanced word such as $\sigma_1\sigma_2\sigma_1^{-1}\sigma_2^{-1}$ returns zero, visibly demonstrating the detector's blind spot without claiming that the word is trivial.

Third, compute $F_n$, factor it, and test each prime factor by running the recurrence modulo that prime. For $13\le n\le20$, this produces primitive factors $233$, $29$, $61$, $47$, $1597$, $19$, either $37$ or $113$, and $41$, respectively. These examples illustrate the definition but are not substituted for the interval-wide theorem.

## 10. Conclusion

The Eisenstein norm, braid writhe, and primitive Fibonacci divisors are concise certificates with exact mathematical behavior. The norm is multiplicative and obeys an exponential iteration law. It separates a signature of norm $4$ from two signatures of norm $1$, while exposing a collision between the latter pair. Writhe is additive, distinguishes every natural power of an Artin generator, and proves the two-strand trefoil word nonidentity, while leaving balanced words unresolved. Every Fibonacci number from index $13$ through $10000$ possesses a primitive prime divisor, with the finite endpoint explicitly retained.

Together these results illustrate a disciplined use of invariants: define the compression, prove its compatibility, exploit its decisive outputs, and state its blind spots with equal precision.