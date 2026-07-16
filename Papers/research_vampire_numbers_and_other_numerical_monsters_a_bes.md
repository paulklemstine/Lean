# Prime Fangs on the Decimal Vampire Residue Curve

**Aristotle**  
**July 16, 2026**

## Abstract

A decimal digit-permutation factorization is an identity $v=xy$ in which the multiset of decimal digits of $v$ equals the combined multiset of digits of $x$ and $y$. Classical vampire numbers add length and trailing-zero conventions, but the permutation condition itself already imposes a strong arithmetic constraint. Preservation of digit sum gives $xy\equiv x+y\pmod 9$, equivalently $(x-1)(y-1)\equiv1\pmod9$. This curve contains exactly six ordered residue pairs: $(0,0)$, $(2,2)$, $(3,6)$, $(5,8)$, $(6,3)$, and $(8,5)$. We study its intersection with primality. If both factors are prime, divisibility by three excludes half of the six points, leaving only $(2,2)$, $(5,8)$, and $(8,5)$. All three have product congruent to $4$ modulo nine. Thus every digit-permutation product with two prime fangs is congruent to $4$ modulo nine and is not divisible by three. We give complete proof sketches, search algorithms based on digit-frequency vectors and residue bucketing, illustrative computations, and a careful account of what the local theorem does—and does not—imply about existence and density. We conclude with precise open problems concerning square-root density, existence in even-length decades, prime-fang infinitude, and vanishing density for balanced ghost factorizations.

## 1. Introduction

The identity

$$
1260=21\cdot60
$$

is remarkable because the digits of the factors, taken together, are exactly the digits of the product. Such identities are traditionally associated with vampire numbers: the product is the vampire, and its factors are its fangs. The terminology is recreational, but the mathematics combines several serious themes. Decimal words are combinatorial objects; multiplication is arithmetic; factorization introduces algorithmic cost; and primality supplies additional local restrictions.

A brute-force treatment regards decimal digits as labels inspected only after multiplication. The central observation of this paper is that the digit condition has an algebraic projection. Decimal digit multisets determine digit sums, and digit sums determine residues modulo nine. Therefore every admissible factorization lies on a fixed affine congruence curve. For unrestricted factors this curve has six points modulo nine. For prime factors it has only three, and the corresponding products concentrate in a single residue class.

The argument is elementary, universal, and independent of decimal length. It does not prove that prime-fang vampire products exist in abundance, or even infinitely often. Instead, it identifies exact necessary conditions that any such product must satisfy. This distinction between a local obstruction and a global existence theorem organizes both the theoretical discussion and the computational pipeline.

The paper proceeds as follows. Section 2 fixes definitions, including the distinction between classical vampire numbers and the broader digit-permutation relation. Section 3 derives the decimal residue curve. Section 4 enumerates its six points. Section 5 intersects the curve with primality and proves the concentration law. Section 6 presents algorithms and complexity bounds. Section 7 gives examples and rejection certificates. Sections 8 and 9 discuss neighboring numerical “monsters,” applications, limitations, and future questions.

## 2. Definitions and conventions

### 2.1 Decimal digit multisets

For a nonnegative integer $n$ and a digit $d\in\{0,1,\ldots,9\}$, let $c_d(n)$ denote the number of occurrences of $d$ in the ordinary decimal expansion of $n$. We use the conventional expansion without leading zeros; the number $0$ has the one-digit expansion $0$.

The **digit-frequency vector** of $n$ is

$$
C(n)=(c_0(n),c_1(n),\ldots,c_9(n)).
$$

This vector records the decimal digit multiset exactly. Two nonnegative integers have the same digit multiset if and only if their digit-frequency vectors agree.

### 2.2 Digit-permutation factorizations

**Definition 2.1 (Decimal digit-permutation factorization).** A triple of positive integers $(v,x,y)$ is a decimal digit-permutation factorization if

$$
v=xy
$$

and

$$
C(v)=C(x)+C(y),
$$

where addition of frequency vectors is coordinatewise.

The factors $x$ and $y$ are called **fangs**. The definition is symmetric in the fangs. It captures the exact combinatorial property needed below and deliberately imposes no length convention.

**Definition 2.2 (Classical vampire number).** A positive integer $v$ is a classical vampire number if it has an even number $2n$ of decimal digits and admits a factorization $v=xy$ such that $x$ and $y$ each have $n$ digits, $C(v)=C(x)+C(y)$, and $x$ and $y$ do not both end in zero.

The final condition prevents artificial examples obtained by appending matching zeros. Every classical vampire factorization is a digit-permutation factorization, so all results proved for Definition 2.1 apply to Definition 2.2.

**Definition 2.3 (Prime-fang factorization).** A digit-permutation factorization $v=xy$ is a prime-fang factorization if both $x$ and $y$ are prime.

This definition should not be confused with looser terminology in which only one fang is prime. The concentration theorem requires primality of both factors.

### 2.3 Digit sums

Define the decimal digit sum by

$$
s(n)=\sum_{d=0}^{9}d\,c_d(n).
$$

If $C(v)=C(x)+C(y)$, then coordinatewise addition immediately yields

$$
s(v)=s(x)+s(y).
$$

The standard decimal congruence is

$$
n\equiv s(n)\pmod9.
$$

It follows from writing $n=\sum_i a_i10^i$ and using $10^i\equiv1\pmod9$. These two elementary facts create the bridge from digit combinatorics to modular arithmetic.

## 3. The decimal vampire residue curve

**Lemma 3.1 (Digit-sum conservation).** If $v=xy$ is a decimal digit-permutation factorization, then

$$
s(v)=s(x)+s(y).
$$

**Proof sketch.** For each digit $d$, the defining multiset identity gives $c_d(v)=c_d(x)+c_d(y)$. Multiply by $d$, sum from $0$ to $9$, and distribute the sum. $\square$

**Lemma 3.2 (Casting out nines).** Every nonnegative integer $n$ satisfies

$$
n\equiv s(n)\pmod9.
$$

**Proof sketch.** Express $n$ in base ten as $n=\sum_i a_i10^i$. Since $10\equiv1\pmod9$, each power $10^i$ is congruent to $1$, giving $n\equiv\sum_i a_i=s(n)\pmod9$. $\square$

Combining these lemmas with $v=xy$ gives the fundamental congruence.

**Theorem 3.3 (Decimal residue-curve theorem).** If $v=xy$ is a decimal digit-permutation factorization, then

$$
xy\equiv x+y\pmod9,
$$

or equivalently,

$$
(x-1)(y-1)\equiv1\pmod9.
$$

**Proof sketch.** By Lemma 3.2 and digit-sum conservation,

$$
v\equiv s(v)=s(x)+s(y)\equiv x+y\pmod9.
$$

Substitute $v=xy$ and add $1-x-y$ to both sides. $\square$

The shifted equation explains the geometry of the restriction. In the ring $\mathbb Z/9\mathbb Z$, the residue of $x-1$ must be a unit and $y-1$ must be its inverse. Thus the solutions form a translated graph of inversion on the unit group.

This interpretation generalizes. In base $b$, preservation of a base-$b$ digit multiset implies

$$
(x-1)(y-1)\equiv1\pmod{b-1},
$$

because $b\equiv1\pmod{b-1}$. Decimal notation is the case $b=10$.

## 4. Exact enumeration of the unrestricted residue pairs

The units modulo nine are

$$
(\mathbb Z/9\mathbb Z)^\times=\{1,2,4,5,7,8\}.
$$

Their inverses are

$$
1^{-1}=1,\quad2^{-1}=5,\quad4^{-1}=7,
$$

$$
5^{-1}=2,\quad7^{-1}=4,\quad8^{-1}=8.
$$

Since $x-1$ and $y-1$ must be inverse units, adding one to each coordinate produces a complete list.

**Theorem 4.1 (Six-point residue sieve).** Every decimal digit-permutation factorization $v=xy$ satisfies

$$
(x\bmod9,y\bmod9)\in S,
$$

where

$$
S=\{(0,0),(2,2),(3,6),(5,8),(6,3),(8,5)\}.
$$

Conversely, these are exactly the ordered residue pairs satisfying the residue-curve equation $(x-1)(y-1)\equiv1\pmod9$.

**Proof sketch.** Put $a=x-1$ and $b=y-1$ modulo nine. The equation $ab=1$ forces $a$ to be one of the six units and $b=a^{-1}$. Enumerating the inverse pairs and translating by $(1,1)$ gives

$$
(1,1)\mapsto(2,2),\qquad(2,5)\mapsto(3,6),
$$

$$
(4,7)\mapsto(5,8),\qquad(5,2)\mapsto(6,3),
$$

$$
(7,4)\mapsto(8,5),\qquad(8,8)\mapsto(0,0).
$$

No other pairs can occur because no other residue is a unit. Direct substitution verifies that all six listed pairs solve the congruence. $\square$

The converse in Theorem 4.1 concerns only the modular equation. It does not assert that every listed residue pair occurs in an actual digit-permutation factorization. The theorem is an exact local sieve, not a characterization of the global digit condition.

For the example $1260=21\cdot60$, the fang residues are $(3,6)$ modulo nine, one of the six admissible points, while $1260\equiv0\pmod9$. This example also anticipates why primality changes the picture: $21$ and $60$ are both divisible by three.

## 5. Prime fangs

### 5.1 Elementary prime restrictions

**Lemma 5.1 (Prime divisibility by three).** If $p$ is prime and $3\mid p$, then $p=3$.

**Proof sketch.** The only positive divisors of a prime are $1$ and the prime itself. Since $3$ divides $p$ and $3\ne1$, one has $p=3$. $\square$

**Corollary 5.2.** A prime cannot be congruent to $0$ or $6$ modulo nine.

**Proof sketch.** Either residue makes the prime divisible by three. Lemma 5.1 would force the prime to equal $3$, whose residue modulo nine is $3$, a contradiction. $\square$

A prime can be congruent to $3$ modulo nine only in the exceptional case $p=3$. This subtlety must be retained when eliminating the mixed points $(3,6)$ and $(6,3)$.

### 5.2 The three-point intersection

**Theorem 5.3 (Prime-Fang Residue Sieve).** Let $v=xy$ be a decimal digit-permutation factorization. If $x$ and $y$ are prime, then

$$
(x\bmod9,y\bmod9)\in
\{(2,2),(5,8),(8,5)\}.
$$

**Proof sketch.** Theorem 4.1 leaves six possibilities. The pair $(0,0)$ is impossible by Corollary 5.2. In the pair $(3,6)$, the second fang has residue $6$ and therefore cannot be prime. More explicitly, the first fang could only be the exceptional prime $3$, but the second is divisible by three and is not equal to $3$. The pair $(6,3)$ is excluded symmetrically. The remaining possibilities are exactly $(2,2)$, $(5,8)$, and $(8,5)$. $\square$

Thus primality cuts the unrestricted modular search space in half. More strikingly, multiplication maps all three surviving points to the same residue.

**Theorem 5.4 (Prime-Fang Concentration Law).** Let $v=xy$ be a decimal digit-permutation factorization with both $x$ and $y$ prime. Then

$$
v\equiv4\pmod9.
$$

**Proof sketch.** By Theorem 5.3, the ordered fang residues are one of $(2,2)$, $(5,8)$, or $(8,5)$. Their products satisfy

$$
2\cdot2=4,
$$

$$
5\cdot8=40\equiv4\pmod9,
$$

and

$$
8\cdot5=40\equiv4\pmod9.
$$

Since $v=xy$, the conclusion follows. $\square$

**Corollary 5.5 (Exclusion of divisibility by three).** Under the hypotheses of Theorem 5.4,

$$
3\nmid v.
$$

**Proof sketch.** The congruence $v\equiv4\pmod9$ implies $v\equiv1\pmod3$, so $v$ is not divisible by three. $\square$

The concentration law is independent of fang length, product length, and trailing-zero conventions. It therefore applies to every classical prime-fang vampire factorization, while also covering unbalanced or nonclassical digit-permutation products.

## 6. Algorithms

### 6.1 Exact digit-multiset testing

For a nonnegative integer $n$, its digit-frequency vector can be computed by repeated division by ten. Comparing $C(x)+C(y)$ with $C(xy)$ takes time linear in the number of decimal digits and constant auxiliary space if ten counters are treated as fixed storage.

**Algorithm 6.1 (Frequency-vector witness test).** Given positive integers $x$ and $y$:

1. Compute $v=xy$.
2. Initialize two vectors of ten zero counters.
3. Count every decimal digit of $x$ and $y$ into the first vector.
4. Count every decimal digit of $v$ into the second vector.
5. Accept exactly when the vectors agree.

If $D$ is the total number of digits processed, the running time is $O(D)$ and the counter storage is $O(1)$. Sorting digit strings gives an alternative $O(D\log D)$ method, but frequency vectors are simpler and asymptotically sharper.

### 6.2 Residue-first enumeration

Suppose one seeks all balanced $n$-digit fang pairs. Let

$$
L=10^{n-1},\qquad U=10^n-1,
$$

and $N=U-L+1=9\cdot10^{n-1}$. A naive ordered search examines $N^2$ pairs; symmetry permits restricting to $x\le y$, but the order remains quadratic.

**Algorithm 6.2 (Six-point residue-bucket search).** Partition the interval $[L,U]$ by residue modulo nine. Examine only bucket pairs corresponding to

$$
(0,0),(2,2),(3,6),(5,8),(6,3),(8,5).
$$

For each candidate pair, multiply, enforce the desired product length and trailing-zero convention, and then run Algorithm 6.1.

Under approximately uniform residue distribution, the residue sieve retains about $6/81=2/27$ of ordered pairs, a reduction by a factor near $13.5$. This is a heuristic average for workload, not a density theorem for vampire numbers. The worst-case asymptotic pair count remains $O(N^2)$, while each digit check costs $O(n)$.

### 6.3 Prime-fang enumeration

For prime fangs, first enumerate primes in $[L,U]$ with a sieve of Eratosthenes or a segmented sieve. Bucket the primes by residue modulo nine, retaining only classes $2$, $5$, and $8$. Test pairings $(2,2)$, $(5,8)$, and $(8,5)$, with an ordering convention to avoid duplicates.

**Algorithm 6.3 (Prime-fang residue search).** Given a decimal fang length $n$:

1. Generate all $n$-digit primes.
2. Place each prime into its residue bucket modulo nine.
3. Form candidate pairs only from buckets $(2,2)$ and $(5,8)$, treating $(8,5)$ as the symmetric orientation when unordered pairs are desired.
4. Multiply each pair and reject unless the product has the required length.
5. Reject unless $v\equiv4\pmod9$; this check is redundant after correct bucketing but is useful as an integrity check.
6. Compare digit-frequency vectors.
7. Report every surviving factorization.

If $P$ is the number of primes in the fang interval, pair generation remains $O(P^2)$ in the worst case, and each exact digit check costs $O(n)$. The prime number theorem suggests $P$ is on the order of $N/\log(10^n)$, but no asymptotic assumption is needed for correctness. The modular theorem reduces constants and provides auditable rejection certificates.

## 7. Numerical illustrations

### 7.1 A classical witness

For $1260=21\cdot60$, the combined fang digits are $2,1,6,0$, exactly the product digits $1,2,6,0$. Its frequency vectors agree, and

$$
(21\bmod9,60\bmod9)=(3,6).
$$

The pair lies on the unrestricted six-point curve. It does not lie on the prime-fang curve because neither fang is prime.

### 7.2 Residue rejection

Consider any proposed prime-fang digit-permutation product $v$ with $v\equiv1\pmod9$. No factorization details are needed: Theorem 5.4 rejects it immediately. Similarly, a proposed pair of prime fangs with residues $(2,5)$ modulo nine is impossible because it does not satisfy the three-point sieve. These are mathematical certificates of nonexistence for the proposed witness, not probabilistic warnings.

### 7.3 Exhausting the local curve

An enumeration of the $81$ ordered pairs $(a,b)$ with $0\le a,b<9$ and $(a-1)(b-1)\equiv1\pmod9$ returns exactly the six pairs in Theorem 4.1. Filtering out residues impossible for primes, while treating residue $3$ with its exceptional prime carefully, leaves the three points in Theorem 5.3. Their products are all $4$ modulo nine. This finite table illustrates the local algebra, while the theorems explain why the same table governs factors of every size.

## 8. Related numerical monsters and applications

Digit-constrained factorization supports many variants, but their definitions must be explicit.

A **balanced ghost factorization** may be defined as a product of two $n$-digit integers whose $2n$-digit product shares no digit value with either factor. This uses set disjointness of digit alphabets rather than multiset equality. If the factors use a set $A\subseteq\{0,\ldots,9\}$ of digit values, every product digit must lie in the complement. As $|A|$ grows, the allowed output alphabet shrinks. This suggests entropy and occupancy methods, complicated by carries and multiplication correlations.

A **werewolf factorization** requires a convention before analysis: “exactly one shared digit” might mean one shared occurrence or one shared digit value. The latter can be stated as requiring the intersection of the product’s digit-value set with the union of the factors’ digit-value sets to have cardinality one. Different conventions are mathematically different problems.

Prime-fang factorizations have sometimes been grouped under “zombie” terminology, but examples involving one prime and one composite factor do not satisfy the literal two-prime definition. Theorems 5.3–5.5 concern exactly two prime fangs.

The algorithms have pedagogical and computational applications. They demonstrate how an invariant turns a global combinatorial test into a local prefilter. The same architecture appears in checksums, database query planning, constraint programming, and cryptanalytic sieving: compute a cheap invariant, reject impossible candidates, and reserve expensive exact comparison for survivors.

The base-$b$ extension also shows that the phenomenon is not intrinsically decimal. In every positional base, digit-multiset conservation projects modulo $b-1$ onto a translated inverse curve. The geometry and prime restrictions then depend on the arithmetic of $b-1$. Bases for which $b-1$ has different unit-group structure produce different local bestiaries.

## 9. Scope and limitations

The residue theorems are necessary conditions. They do not prove that a residue-admissible pair has matching digits, that a product has the correct length, or that the fangs are prime. Many candidates on the modular curve fail all three tests.

No density law follows from the six-point count alone. Treating residues as uniformly random would supply a local factor, but decimal digit occupancy, multiplication carries, factor sizes, and repeated factorizations create dependencies. In particular, the claim that vampire density scales as $1/\sqrt n$ requires a carefully normalized counting model and substantial new analysis.

Likewise, the prime-fang concentration law does not establish the existence of even one prime-fang example under every classical convention, nor does it establish infinitude. It says that if such examples exist, all are confined to a rigid local pattern.

The ghost-density question also requires a balanced formulation. Without fixed fang and product lengths, apparent scarcity can be caused by trivial size effects rather than digit avoidance. A precise asymptotic model should specify whether pairs or products are sampled, how multiplicity is counted, and whether leading zeros are excluded.

## 10. Future directions

### 10.1 Square-root density with precise normalization

Let $V(n)$ be the proportion of $2n$-digit decimal integers that admit a classical vampire factorization with two $n$-digit fangs. Determine whether

$$
\sqrt n\,V(n)
$$

converges to a positive finite constant, and identify that constant if it exists. A credible model must combine multinomial digit occupancy with the modular unit-curve constraint $(x-1)(y-1)\equiv1\pmod9$. Stratification by digit-frequency profile may separate occupancy effects from multiplication effects.

### 10.2 Existence in every even-length decade

For every integer $k\ge1$, determine whether

$$
[10^{2k},10^{2k+2})
$$

contains a classical vampire number. A uniform constructive family would be stronger than isolated witnesses. Such a construction must preserve product length, leading digits, the entire digit multiset, and the six-point residue condition.

### 10.3 Infinitude of prime-fang products

Determine whether infinitely many decimal digit-permutation factorizations have two prime fangs. Every example must use residues $(2,2)$, $(5,8)$, or $(8,5)$ modulo nine, and its product must be congruent to $4$ modulo nine. The problem resembles the search for primes inside a highly constrained digital family; the local theorem can guide targeted computation and future sieve methods.

### 10.4 Vanishing density of balanced ghost factorizations

Fix $n$-digit factors whose product has $2n$ digits and shares no digit value with either factor. Prove that the proportion of such pairs tends to zero, preferably with an exponential upper bound. Digit-alphabet occupancy gives a plausible entropy mechanism, while carry propagation is the main source of dependence.

## 11. Conclusion

Exact preservation of decimal digits forces far more than a visual coincidence. Every digit-permutation factorization lies on the curve

$$
(x-1)(y-1)\equiv1\pmod9,
$$

whose decimal solution set consists of six ordered residue pairs. Requiring both fangs to be prime removes the three points involving residues divisible by three, leaving $(2,2)$, $(5,8)$, and $(8,5)$. Multiplication sends all three to $4$ modulo nine. Therefore every prime-fang digit-permutation product is congruent to $4$ modulo nine and is not divisible by three.

This local concentration law supplies a clean theorem, an efficient computational filter, and a foundation for sharper questions. The broader lesson is methodological: a complicated global combinatorial condition may cast a small algebraic shadow, and finding that shadow is often the first step from an entertaining pattern to a systematic theory.
