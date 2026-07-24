# Sharp Euler Prime Runs, Discriminants, and the Arithmetic Footprint of 163

**Aristotle** · **24 July 2026**

## Abstract

For a nonnegative integer $p$, consider Euler’s quadratic $f_p(n)=n^2+n+p$. This paper develops an elementary structural account of a **sharp prime run**, meaning that $f_p(n)$ is prime for every $0\le n<p-1$ and fails to be prime at $n=p-1$. The endpoint is universally forced: $f_p(p-1)=p^2$. We establish that every sharp run for $p\ge2$ consists of exactly $p-1$ distinct primes in $[p,p^2)$; that $p$ itself is prime; and, for $p\ge3$, that $(p,p+2)$ is a twin-prime pair. Direct finite primality checks give sharp runs for $p=11,17,41$, of lengths $10,16,40$. Their negative discriminants have magnitudes $43,67,163$. We then record the exact identities $960^3+744=884736744$, $5280^3+744=147197952744$, and $640320^3+744=262537412640768744$, together with their modular consequences. Finally, $163$ is shown to be the maximum of the explicitly specified set $\{1,2,3,7,11,19,43,67,163\}$. We carefully distinguish these exact elementary results from the deeper class-number classification and from transcendental near-integer estimates.

## 1. Introduction

The polynomial

$$
f_{41}(n)=n^2+n+41
$$

is renowned because it is prime for all integers $n$ from $0$ through $39$. Its fame is often intertwined with the exceptional behavior of the discriminant $-163$ and with the near-integrality of $e^{\pi\sqrt{163}}$. Those themes belong to a broad theory involving binary quadratic forms, class numbers, modular functions, and complex multiplication. Nevertheless, a substantial common arithmetic footprint can be isolated using only integers, finite primality tests, and elementary inequalities.

The organizing idea is to treat $n^2+n+p$ uniformly in the parameter $p$. The endpoint $n=p-1$ always produces $p^2$, so there is a natural maximum possible initial prime run. If all earlier values are prime, the run is called sharp. This definition turns the examples $p=11,17,41$ into instances of a general phenomenon rather than three disconnected computations.

Three structural facts then follow. First, the parameter $p$ is itself the zeroth value and must be prime. Second, provided $p\ge3$, the next value is $p+2$, producing a twin-prime pair. Third, the polynomial is strictly increasing and its proper run values remain below $p^2$; hence a sharp run places exactly $p-1$ distinct primes in $[p,p^2)$.

Completing the square gives a second viewpoint:

$$
4f_p(n)=(2n+1)^2+(4p-1).
$$

Thus the magnitude $D_p=4p-1$ of the quadratic’s negative discriminant is intrinsic to the run. The parameters $11,17,41$ yield $D_p=43,67,163$. These three values also appear in exact cube-plus-$744$ identities associated classically with singular moduli. The present treatment establishes the integer identities and their congruences, while clearly identifying the further work needed to connect them analytically to exponential near-integers.

## 2. Definitions and elementary identities

Throughout, $\mathbb N$ denotes the nonnegative integers.

**Definition 2.1 (Euler quadratic).** For $p,n\in\mathbb N$, define

$$
f_p(n)=n^2+n+p=p+n(n+1).
$$

**Definition 2.2 (Sharp Euler prime run).** A parameter $p$ has a sharp Euler prime run if

$$
f_p(n)\text{ is prime for every }0\le n<p-1,
$$

and $f_p(p-1)$ is not prime. For $p\ge2$, the proper indices are precisely $0,1,\ldots,p-2$, so there are $p-1$ of them.

**Definition 2.3 (Discriminant magnitude).** Define

$$
D_p=4p-1.
$$

The polynomial $x^2+x+p$ has discriminant $1-4p=-D_p$, so $D_p$ is the positive magnitude of that negative discriminant.

**Definition 2.4 (Run-value set).** For $p\in\mathbb N$, let

$$
R_p=\{f_p(n):0\le n<p-1\}.
$$

This is a set rather than a multiset; below, strict monotonicity shows that no values are lost when duplicates are removed.

**Definition 2.5 (Explicit Heegner list).** In this paper the phrase “explicit Heegner list” refers solely to the finite set

$$
H=\{1,2,3,7,11,19,43,67,163\}.
$$

Use of this name does not itself establish any class-number characterization of the set.

The endpoint identity drives the entire structure.

**Lemma 2.6 (Square boundary).** If $p\ge1$, then

$$
f_p(p-1)=p^2.
$$

**Proof sketch.** Expand directly:

$$
(p-1)^2+(p-1)+p=p^2-2p+1+p-1+p=p^2.
$$

No primality information is needed. $\square$

**Corollary 2.7 (Universal endpoint obstruction).** If $p\ge2$, then $f_p(p-1)$ is composite. Consequently, no initial prime run can include every index through $p-1$.

**Proof sketch.** By Lemma 2.6 the endpoint equals $p^2$. Since $p\ge2$, this has the nontrivial factorization $p\cdot p$. $\square$

This explains the word “sharp”: such a run reaches every index before the first universally prescribed obstruction.

## 3. Monotonicity and interval geometry

The values of the quadratic have a simple difference law.

**Lemma 3.1 (Strict increase).** For every $p\in\mathbb N$, the sequence $n\mapsto f_p(n)$ is strictly increasing.

**Proof sketch.** For every $n\ge0$,

$$
f_p(n+1)-f_p(n)=2n+2>0.
$$

Equivalently, if $a<b$, then

$$
f_p(b)-f_p(a)=(b-a)(a+b+1)>0.
$$

Thus $f_p(a)<f_p(b)$. $\square$

**Corollary 3.2 (Injectivity).** For fixed $p$, if $f_p(a)=f_p(b)$ for nonnegative integers $a,b$, then $a=b$.

**Proof sketch.** A strictly increasing function on a linearly ordered set is injective. $\square$

The lower endpoint of the run-value interval is immediate, and the upper endpoint follows either from monotonicity or direct algebra.

**Lemma 3.3 (Proper values lie below the square).** Let $p,n\in\mathbb N$ satisfy $n+2\le p$. Then

$$
p\le f_p(n)<p^2.
$$

**Proof sketch.** The lower bound follows from $f_p(n)=p+n(n+1)$. The condition $n+2\le p$ is equivalent to $n<p-1$. By strict increase,

$$
f_p(n)<f_p(p-1)=p^2.
$$

One may also maximize the expression at $n=p-2$, obtaining

$$
f_p(p-2)=p^2-2p+2<p^2
$$

for $p\ge2$. $\square$

The successive gaps are also forced:

$$
f_p(1)-f_p(0)=2,
$$

$$
f_p(2)-f_p(1)=4,
$$

and in general the gap after index $n$ is $2n+2$. Thus $R_p$, when prime, is not an arbitrary prime sample but the image of the convex sequence $n\mapsto n(n+1)$ translated by $p$.

## 4. Structural consequences of a sharp run

We first extract primality of the parameter.

**Theorem 4.1 (Parameter primality).** Let $p\ge2$. If $p$ has a sharp Euler prime run, then $p$ is prime.

**Proof sketch.** Since $0<p-1$, the sharp-run hypothesis includes the value at $n=0$. But

$$
f_p(0)=p.
$$

Therefore $p$ is prime. $\square$

The next index yields a stronger local condition.

**Theorem 4.2 (Twin-prime consequence).** Let $p\ge3$. If $p$ has a sharp Euler prime run, then both $p$ and $p+2$ are prime.

**Proof sketch.** Theorem 4.1 gives primality of $p$. Since $1<p-1$ when $p\ge3$, the run includes $n=1$. Hence

$$
f_p(1)=1+1+p=p+2
$$

is prime. The two primes differ by $2$, so $(p,p+2)$ is a twin-prime pair. $\square$

The lower bound $p\ge3$ is necessary for this argument. At $p=2$, the proper run contains only the index $0$; index $1$ is already the square boundary, and no conclusion about $p+2=4$ could be true.

We now formulate the central packing result.

**Theorem 4.3 (Sharp-run prime packing).** Let $p\ge2$ have a sharp Euler prime run. Then:

1. $R_p$ has cardinality $p-1$;
2. every member of $R_p$ is prime;
3. every $m\in R_p$ satisfies $p\le m<p^2$.

In particular, the run supplies exactly $p-1$ distinct primes in $[p,p^2)$.

**Proof sketch.** The index set $\{0,1,\ldots,p-2\}$ has $p-1$ elements. By Corollary 3.2, distinct indices have distinct images under $f_p$, so $|R_p|=p-1$. Primality of every image is exactly the proper part of the sharp-run hypothesis. Lemma 3.3 places every image in $[p,p^2)$. $\square$

This theorem should not be misread as saying that these are all primes in the interval. It states that the polynomial constructs a distinguished subset of exactly $p-1$ primes there.

**Corollary 4.4 (Forced arithmetic ladder).** Under the assumptions of Theorem 4.3,

$$
R_p=\{p+k(k+1):0\le k\le p-2\},
$$

and all displayed values are prime and distinct.

**Proof sketch.** This is the identity $f_p(k)=p+k(k+1)$ combined with the sharp-run hypothesis and injectivity. $\square$

## 5. The sharp runs for 43, 67, and 163

The three principal instances arise at $p=11,17,41$. Their sharpness consists of a finite prime table together with the universal boundary lemma.

**Theorem 5.1 (Discriminant-$43$ run).** The polynomial $n^2+n+11$ is prime for every $0\le n\le9$, and its next value is

$$
f_{11}(10)=11^2=121.
$$

Thus it has a sharp ten-term prime run.

**Proof sketch.** Evaluate the ten values and apply trial division by primes not exceeding their square roots. They are

$$
11,13,17,23,31,41,53,67,83,101.
$$

Each is prime. Lemma 2.6 gives the composite boundary $121$. $\square$

**Theorem 5.2 (Discriminant-$67$ run).** The polynomial $n^2+n+17$ is prime for every $0\le n\le15$, and

$$
f_{17}(16)=17^2=289.
$$

Thus it has a sharp sixteen-term prime run.

**Proof sketch.** The values are

$$
17,19,23,29,37,47,59,73,89,107,127,149,173,199,227,257.
$$

Finite trial division proves each prime, while the endpoint identity gives $289=17^2$. $\square$

**Theorem 5.3 (Discriminant-$163$ run).** The polynomial $n^2+n+41$ is prime for every $0\le n\le39$, and

$$
f_{41}(40)=41^2=1681.
$$

Thus it has a sharp forty-term prime run.

**Proof sketch.** Generate the forty values $41+n(n+1)$ and test divisibility by every prime at most the square root of each value. None has a proper divisor. The first values are $41,43,47,53,61,71$ and the final proper value is $1601$. The next value is the composite square $1681$. $\square$

Combining Theorems 4.2 and 4.3 with these examples gives:

**Corollary 5.4 (Twin pairs and packings).** The pairs $(11,13)$, $(17,19)$, and $(41,43)$ are twin-prime pairs. The three runs contain respectively $10$, $16$, and $40$ distinct primes in the intervals $[11,121)$, $[17,289)$, and $[41,1681)$.

**Proof sketch.** Apply Theorem 4.2 and Theorem 4.3 to each sharp run. $\square$

## 6. Discriminants

Completing the square connects the polynomial to a negative quadratic discriminant:

$$
4f_p(n)=4n^2+4n+4p=(2n+1)^2+(4p-1).
$$

The quadratic $x^2+x+p$ has discriminant $1-4p$, whose magnitude is $D_p=4p-1$.

**Theorem 6.1 (Exact discriminant correspondence).** The sharp-run parameters $11$, $17$, and $41$ have discriminant magnitudes

$$
D_{11}=43,\qquad D_{17}=67,\qquad D_{41}=163.
$$

**Proof sketch.** Substitute into $D_p=4p-1$:

$$
4\cdot11-1=43,
$$

$$
4\cdot17-1=67,
$$

$$
4\cdot41-1=163.
$$

$\square$

This identity is the elementary bridge to the language of imaginary quadratic orders. It does not, by itself, show that any order has class number one. Such a conclusion requires a theory of ideal classes or reduced binary quadratic forms.

## 7. Exact cube-plus-$744$ arithmetic

The discriminants $43$, $67$, and $163$ are also associated with three distinguished cube bases. The following statements are exact integer equalities.

**Theorem 7.1 (Cube-plus-$744$ identities).** One has

$$
960^3+744=884736744,
$$

$$
5280^3+744=147197952744,
$$

and

$$
640320^3+744=262537412640768744.
$$

**Proof sketch.** Integer multiplication gives

$$
960^3=884736000,
$$

$$
5280^3=147197952000,
$$

and

$$
640320^3=262537412640768000.
$$

Adding $744$ yields the displayed identities. $\square$

**Corollary 7.2 (Common modular signature).** The corresponding remainders are

$$
884736744\bmod 960^3=744,
$$

$$
147197952744\bmod 5280^3=744,
$$

and

$$
262537412640768744\bmod 640320^3=744.
$$

**Proof sketch.** Each integer has the form $a^3+744$, and $0\le744<a^3$ for each listed base $a$. Division by $a^3$ therefore leaves remainder $744$. $\square$

In the analytic theory, $744$ is the constant term in the expansion $j(q)=q^{-1}+744+196884q+\cdots$ of the modular $j$-invariant. Establishing the exact integer identities above is an arithmetic endpoint. Deriving rigorous inequalities for $e^{\pi\sqrt{43}}$, $e^{\pi\sqrt{67}}$, or $e^{\pi\sqrt{163}}$ requires the additional analytic bridge supplied by singular moduli and controlled bounds on the remaining series terms.

## 8. The explicit nine-element list

**Theorem 8.1 (Finite-list maximality).** For

$$
H=\{1,2,3,7,11,19,43,67,163\},
$$

one has $43,67,163\in H$, and $163$ is the maximum element of $H$.

**Proof sketch.** Membership follows by inspection. Comparing each of the nine displayed integers with $163$ shows that every $h\in H$ satisfies $h\le163$, while $163\in H$. $\square$

This theorem concerns the stated finite set only. It is not a proof that $H$ exhausts all negative fundamental discriminants of class number one. The latter is the Stark–Heegner classification and requires deep number theory.

## 9. Algorithms and reproducible computation

### 9.1 Primality testing

For an integer $m\ge2$, trial division tests whether any integer $d$ with $2\le d\le\lfloor\sqrt m\rfloor$ divides $m$. It suffices to test $2$ and then odd candidates. If $m$ is composite, at least one factor is no larger than $\sqrt m$.

For a sharp-run test, evaluate $f_p(n)$ for all $0\le n<p-1$, test each value for primality, and verify the boundary identity. Since every proper value is less than $p^2$, trial division requires $O(p)$ candidate divisors per value and there are $O(p)$ values, yielding $O(p^2)$ elementary divisibility tests in the straightforward model. Space usage is $O(p)$ if all values are stored and $O(1)$ if they are streamed.

### 9.2 Packing construction

To construct $R_p$, iterate $n=0,1,\ldots,p-2$, compute $p+n(n+1)$, and insert each result. Strict monotonicity means insertion order is already sorted and duplicate detection is unnecessary. The construction uses $O(p)$ arithmetic operations apart from primality testing.

### 9.3 Cube and congruence checks

For each pair $(a,N)$, compute $a^3+744$ and compare with $N$; then compute $N\bmod a^3$. Exponentiation by repeated squaring takes $O(\log3)$ multiplications here—effectively two multiplications—while bit complexity depends on the operand length. These computations use exact integers and introduce no floating-point error.

## 10. Applications and interpretation

The packing theorem offers a constructive lower bound on the number of primes in a specified interval whenever a sharp run is known. It also supplies an immediate obstruction: if either $p$ or $p+2$ is composite for $p\ge3$, then $p$ cannot support a sharp run. More generally, if a small prime divides $p+n(n+1)$ for some proper index $n$, the run must fail at or before that index.

The fixed gap law makes modular sieving particularly natural. For a prime $q$, failures occur at solutions of

$$
n^2+n+p\equiv0\pmod q.
$$

This quadratic congruence identifies residue classes of forbidden indices. The boundary obstruction is the special case $q=p$ and $n=p-1$, where the value is divisible by $p$ twice.

The discriminant identity points toward Rabinowitsch’s criterion: for suitable prime $p$, primality of $n^2+n+p$ throughout $0\le n\le p-2$ is related to class number one for discriminant $1-4p$. The present results establish the prime-run side and its structural consequences for $p=11,17,41$; they do not establish the equivalence.

## 11. Scope and limitations

Four distinctions prevent overstatement.

First, the exact cube-plus-$744$ identities do not alone prove a bound on $e^{\pi\sqrt D}$. A certified near-integer theorem needs explicit interval estimates for $\pi$, $\sqrt D$, and the exponential, or a rigorous $j$-invariant tail estimate.

Second, maximality of $163$ in the displayed nine-element set is a finite comparison, not an unbounded classification theorem.

Third, the prime-packing theorem gives $p-1$ distinguished primes inside $[p,p^2)$; it does not enumerate every prime in that interval.

Fourth, no unrestricted uniqueness claim for near-integrality of $e^{\pi\sqrt n}$ follows. Any such claim should specify a bounded search range or additional arithmetic hypotheses; heuristic distribution considerations make global uniqueness implausible without substantial qualification.

## 12. Future work

A first extension is to articulate the full arithmetic ladder: under a sharp run, every $p+k(k+1)$ for $0\le k\le p-2$ is prime, with forced successive gaps $2,4,6,\ldots$. This is already implicit in Corollary 4.4 and can be used to derive explicit lower bounds for the prime-counting function.

A second direction is a systematic modular obstruction theory. For each small prime $q$, solving $n^2+n+p\equiv0\pmod q$ describes residue classes where a run must break. Combining these local constraints may sharply restrict candidate parameters.

A third direction is the full Rabinowitsch equivalence between sharp prime runs and class number one for discriminant $1-4p$. A self-contained treatment through reduced positive binary quadratic forms would connect the elementary staircase to algebraic number theory.

A fourth direction is analytic: define the modular $j$-invariant, evaluate the relevant singular moduli, and prove quantitative tail bounds. Together with rational interval bounds for elementary transcendental functions, this would establish the famous near-integer estimates without relying on unqualified decimal output.

Finally, bounded searches for near-integer behavior should be accompanied by explicit error certification. A meaningful theorem could assert uniqueness of $163$ within a stated finite range $n\le N$, rather than asserting unrestricted uniqueness.

## 13. Conclusion

The family $f_p(n)=n^2+n+p$ contains a universal endpoint: $f_p(p-1)=p^2$. When every earlier value is prime, this endpoint turns a long prime run into a sharp and rigid object. Such a run forces $p$ to be prime, forces $(p,p+2)$ to be a twin-prime pair when $p\ge3$, and packs exactly $p-1$ distinct primes into $[p,p^2)$.

The parameters $11$, $17$, and $41$ realize this pattern with runs of lengths $10$, $16$, and $40$. Completing the square associates them with discriminant magnitudes $43$, $67$, and $163$. Exact integer arithmetic then supplies three cube-plus-$744$ identities and their common modular signature. Within the explicit set $\{1,2,3,7,11,19,43,67,163\}$, the final value is maximal.

Together these statements form an elementary arithmetic chain reaching from Euler’s polynomial to the distinctive footprint of $163$. The deeper class-number and transcendental results begin precisely where this chain ends.
