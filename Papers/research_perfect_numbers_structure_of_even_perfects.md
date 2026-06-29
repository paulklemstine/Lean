# The Abundancy Index Framework for Perfect Numbers: Structure of Even Perfects and the Deficiency of Prime Powers

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (Number Theory)

---

## Abstract

We develop a self-contained framework for the structural study of perfect numbers organized around a single rational invariant, the **abundancy index** $A(n) = \sigma(n)/n$, where $\sigma$ is the sum-of-divisors function. We show that this invariant sorts the positive integers into the classical perfect/deficient/abundant trichotomy and that perfection is equivalent to the identity $A(n) = 2$. We prove that $A$ is multiplicative on coprime arguments, compute it explicitly on primes and prime powers, and establish that **every prime power is strictly deficient**. From this we derive the first genuine structure theorem: no perfect number is a prime power. We give the abundancy-theoretic derivation of the Euclid–Euler classification of even perfect numbers, $n = 2^{p-1}(2^p - 1)$ with $2^p - 1$ prime, and explain how the same deficiency estimate, iterated, drives Nielsen's lower bound that an odd perfect number must have at least $101$ distinct prime factors. We close with a reciprocal-sum identity for perfect numbers and a list of falsifiable conjectures pointing to further structure theorems. All central results have been formally verified.

---

## 1. Introduction

A positive integer $n$ is **perfect** if it equals the sum of its proper divisors. The smallest examples — $6, 28, 496, 8128$ — were already studied in antiquity. Two structural questions remain open after more than two thousand years: whether there are infinitely many (even) perfect numbers, and whether any **odd** perfect number exists.

The modern organizing principle for these questions is a single arithmetic invariant. Writing $\sigma(n)$ for the sum of all positive divisors of $n$ (including $n$ itself), the **abundancy index** is the rational number

$$A(n) = \frac{\sigma(n)}{n}.$$

This paper assembles, from first principles and with formally verified proofs, the core of the abundancy framework: the equivalence between perfection and $A(n) = 2$; the multiplicativity of $A$ on coprime arguments; the exact value of $A$ on prime powers; the uniform strict deficiency of prime powers; and the resulting impossibility of a prime-power perfect number. We then place the classical Euclid–Euler theorem and the modern Nielsen bound for odd perfects within this single, unified picture.

The narrative we want to make precise is this: **perfection is a balancing act**. The atoms of multiplication — prime powers — are all strictly deficient ($A < 2$). The value $2$ can only be reached by multiplying several deficient atoms together until their abundancies, which are multiplicative, conspire to land exactly on $2$. This single observation explains why no perfect number is a prime power, why even perfects take the Euclid–Euler form, and why odd perfects (if they exist) must recruit a great many primes.

---

## 2. Definitions and conventions

Throughout, $n, m, p, k$ denote nonnegative integers, with $p$ reserved for primes. We work with $\sigma = \sigma_1$, the sum-of-(first-power-of-)divisors function:

$$\sigma(n) = \sum_{d \mid n} d.$$

All abundancy statements are made for $n > 0$; the value $A(0) = \sigma(0)/0$ is undefined and excluded.

**Definition 2.1 (Abundancy index).** For $n > 0$, the abundancy index is the rational number
$$A(n) = \frac{\sigma(n)}{n} \in \mathbb{Q}.$$

**Definition 2.2 (Deficient).** A positive integer $n$ is *deficient* if $A(n) < 2$.

**Definition 2.3 (Abundant).** A positive integer $n$ is *abundant* if $A(n) > 2$.

**Definition 2.4 (Perfect).** A positive integer $n$ is *perfect* if the sum of its proper divisors equals $n$; equivalently $\sigma(n) = 2n$.

These three definitions partition the positive integers, since for each $n > 0$ exactly one of $A(n) < 2$, $A(n) = 2$, $A(n) > 2$ holds.

---

## 3. Perfection as an abundancy identity

The first result certifies that the abundancy reformulation is faithful to the classical definition.

**Lemma 3.1 (Reconstruction of $\sigma$).** For $n > 0$,
$$\sigma(n) = A(n) \cdot n.$$

*Proof.* By definition $A(n) = \sigma(n)/n$, and since $n > 0$ the denominator is a nonzero rational; multiplying back gives $\sigma(n) = A(n)\, n$ via cancellation $\frac{\sigma(n)}{n}\cdot n = \sigma(n)$. $\quad\blacksquare$

**Theorem 3.2 (Perfection $\Leftrightarrow$ abundancy two).** For $n > 0$,
$$A(n) = 2 \iff n \text{ is perfect.}$$

*Proof.* Since $n > 0$, clearing the denominator gives the chain
$$A(n) = 2 \iff \frac{\sigma(n)}{n} = 2 \iff \sigma(n) = 2n.$$
The rightmost equality is, by Definition 2.4, exactly the statement that $n$ is perfect (the sum of all divisors being $2n$ is equivalent to the sum of *proper* divisors being $n$). $\quad\blacksquare$

This theorem is the keystone: it converts a statement about a *sum* into a statement about the *size of a single fraction*, opening the door to multiplicative techniques.

---

## 4. Multiplicativity

The sum-of-divisors function $\sigma$ is multiplicative: $\sigma(mn) = \sigma(m)\sigma(n)$ whenever $\gcd(m,n) = 1$, because each divisor of $mn$ factors uniquely as (divisor of $m$)(divisor of $n$). The abundancy index inherits this.

**Theorem 4.1 (Multiplicativity on coprime arguments).** If $\gcd(m, n) = 1$, then
$$A(mn) = A(m)\, A(n).$$

*Proof.* By multiplicativity of $\sigma$, $\sigma(mn) = \sigma(m)\sigma(n)$. Hence
$$A(mn) = \frac{\sigma(mn)}{mn} = \frac{\sigma(m)\sigma(n)}{m\, n} = \frac{\sigma(m)}{m}\cdot\frac{\sigma(n)}{n} = A(m)\,A(n). \quad\blacksquare$$

**Consequence.** Writing the prime factorization $n = \prod_i p_i^{a_i}$, the factors $p_i^{a_i}$ are pairwise coprime, so
$$A(n) = \prod_i A\!\left(p_i^{a_i}\right).$$
The global invariant is the product of purely local invariants. To understand $A$ everywhere it suffices to understand it on prime powers.

---

## 5. Abundancy of primes and prime powers

**Lemma 5.1 (Primes).** For a prime $p$,
$$A(p) = \frac{p+1}{p} = 1 + \frac{1}{p}.$$

*Proof.* The divisors of $p$ are $1$ and $p$, so $\sigma(p) = p + 1$, and division by $p$ gives the result. $\quad\blacksquare$

**Lemma 5.2 (Prime powers, geometric form).** For a prime $p$ and $k \ge 1$,
$$\sigma(p^k) = \frac{p^{k+1} - 1}{p - 1}, \qquad A(p^k) = \sum_{i=0}^{k} p^{-i} = 1 + \frac1p + \cdots + \frac1{p^k}.$$

*Proof.* The divisors of $p^k$ are $1, p, \dots, p^k$, whose sum is the geometric series $\frac{p^{k+1}-1}{p-1}$. Dividing by $p^k$ and reindexing $i \mapsto k - i$ yields the reciprocal sum. $\quad\blacksquare$

The reciprocal-sum form makes the next estimate transparent: as $k \to \infty$ the sum increases monotonically to $\frac{1}{1 - 1/p} = \frac{p}{p-1}$, which is $\le 2$ precisely when $p \ge 2$.

**Theorem 5.3 (Primes are deficient).** Every prime $p$ is deficient: $A(p) < 2$.

*Proof.* $A(p) = 1 + 1/p$ and $p \ge 2$ gives $1/p \le 1/2 < 1$, so $A(p) < 2$. Equivalently, $\frac{p+1}{p} < 2 \iff p + 1 < 2p \iff 1 < p$, true for every prime. $\quad\blacksquare$

**Theorem 5.4 (Prime powers are deficient).** For every prime $p$ and every $k \ge 1$, the prime power $p^k$ is deficient: $A(p^k) < 2$.

*Proof.* By Lemma 5.2, the inequality $A(p^k) < 2$ is, after multiplying by the positive quantity $p^k(p-1)$, equivalent to
$$\frac{p^{k+1} - 1}{p - 1} < 2 p^k \iff p^{k+1} - 1 < 2 p^k (p - 1) \iff 0 < p^{k}(p - 2) + 1.$$
For every prime $p \ge 2$ the right-hand quantity is strictly positive: if $p = 2$ it equals $1 > 0$; if $p \ge 3$ then $p^k(p-2) \ge 1 > 0$. Hence $A(p^k) < 2$. $\quad\blacksquare$

Theorem 5.4 is the central structural lever of the whole framework: the multiplicative atoms are *uniformly* and *strictly* deficient, with abundancy bounded above by the ceiling $\frac{p}{p-1}$.

---

## 6. First structure theorem: no perfect prime power

**Theorem 6.1 (No perfect number is a prime power).** If $n$ is perfect, then $n$ is not of the form $p^k$ for a single prime $p$ and $k \ge 1$.

*Proof.* If $n = p^k$ were perfect, then by Theorem 3.2 we would have $A(n) = 2$. But Theorem 5.4 gives $A(p^k) < 2$, a contradiction. $\quad\blacksquare$

**Interpretation.** Perfection is irreducibly multi-prime. The exact value $2$ cannot be produced by any single prime, no matter how high the exponent; it must emerge from the *product* of several local abundancies, each strictly below $2$, combining through Theorem 4.1. This is the qualitative seed of every sharp lower bound on the number of prime factors of perfect numbers, including Nielsen's for the odd case (Section 9).

**Corollary 6.2.** Every perfect number has at least two distinct prime factors.

*Proof.* A positive integer with at most one distinct prime factor is $1$ or a prime power $p^k$. The number $1$ has $A(1) = 1 \ne 2$, and prime powers are excluded by Theorem 6.1. $\quad\blacksquare$

---

## 7. A reciprocal-sum identity

**Theorem 7.1 (Reciprocals of divisors).** For any $n > 0$,
$$\sum_{d \mid n} \frac{1}{d} = A(n).$$
In particular, if $n$ is perfect then $\sum_{d \mid n} \frac1d = 2$.

*Proof.* The map $d \mapsto n/d$ is an involution on the set of divisors of $n$. Hence
$$\sum_{d \mid n} \frac{1}{d} = \sum_{d \mid n} \frac{1}{n/d} = \frac1n \sum_{d \mid n} d = \frac{\sigma(n)}{n} = A(n).$$
The perfect-number case follows from Theorem 3.2. $\quad\blacksquare$

For $n = 6$: $\frac11 + \frac12 + \frac13 + \frac16 = \frac{6+3+2+1}{6} = 2$, as predicted.

---

## 8. The Euclid–Euler theorem through abundancy

A **Mersenne prime** is a prime of the form $M_p = 2^p - 1$ (which forces $p$ itself to be prime).

**Theorem 8.1 (Euclid–Euler).** An even positive integer $n$ is perfect if and only if
$$n = 2^{p-1}(2^p - 1) \quad\text{with } 2^p - 1 \text{ prime.}$$

*Abundancy-theoretic sketch.*

*(Sufficiency, Euclid.)* Let $q = 2^p - 1$ be prime and $n = 2^{p-1} q$. The factors $2^{p-1}$ and $q$ are coprime (one is a power of $2$, the other odd), so by Theorem 4.1,
$$A(n) = A(2^{p-1})\, A(q).$$
By Lemma 5.2, $A(2^{p-1}) = \frac{2^p - 1}{2^{p-1}}$, and by Lemma 5.1, $A(q) = \frac{q+1}{q} = \frac{2^p}{2^p - 1}$. Therefore
$$A(n) = \frac{2^p - 1}{2^{p-1}} \cdot \frac{2^p}{2^p - 1} = \frac{2^p}{2^{p-1}} = 2,$$
so $n$ is perfect by Theorem 3.2.

*(Necessity, Euler.)* Let $n$ be an even perfect number and write $n = 2^{k} m$ with $k \ge 1$ and $m$ odd. Coprimality and $\sigma(n) = 2n$ give $\sigma(2^k)\sigma(m) = 2^{k+1} m$, i.e. $(2^{k+1} - 1)\sigma(m) = 2^{k+1} m$. Since $2^{k+1} - 1$ is odd and divides $2^{k+1} m$, it divides $m$; writing $m = (2^{k+1}-1)\,c$ yields $\sigma(m) = 2^{k+1} c = m + c$. But $m$ and $c$ are distinct divisors of $m$ (as $c \mid m$ and $c < m$), so $\sigma(m) \ge m + c$ with equality only if these are the *only* divisors of $m$ — forcing $c = 1$ and $m = 2^{k+1} - 1$ prime. Hence $n = 2^{k}(2^{k+1} - 1)$ with $2^{k+1} - 1$ prime; setting $p = k+1$ gives the stated form. $\quad\blacksquare$

The balancing-act reading is explicit in the sufficiency direction: $A(2^{p-1}) < 2$ is deficient, and it is multiplied by the prime abundancy $A(2^p-1) > 1$, which is calibrated *exactly* to lift the product back to $2$.

---

## 9. Odd perfect numbers and Nielsen's bound

No odd perfect number is known, and none exists below extremely large computational bounds, yet their nonexistence is unproven. The abundancy framework explains precisely what an odd perfect number is up against.

An odd number's prime support consists only of odd primes $p \ge 3$. Each local factor obeys
$$A(p^a) = \sum_{i=0}^{a} p^{-i} < \frac{p}{p - 1},$$
so by multiplicativity
$$A(n) = \prod_{p^a \,\|\, n} A(p^a) \; < \; \prod_{p \mid n} \frac{p}{p-1}.$$
Perfection demands $A(n) = 2$, hence the strict lower bound
$$\prod_{p \mid n} \frac{p}{p - 1} > 2.$$
The factors $\frac{p}{p-1}$ over the smallest odd primes are $\frac32, \frac54, \frac76, \frac{11}{10}, \dots$, each barely above $1$, and the partial products $\prod_{p \le x}\frac{p}{p-1}$ grow only like $\log x$ (Mertens' theorem). Reaching a product exceeding $2$ therefore requires a large number of distinct odd primes — and refined versions of exactly this accounting are the engine of:

**Theorem 9.1 (Nielsen, 2015).** An odd perfect number, if one exists, has at least $101$ distinct prime factors (and at least $300\,$ prime factors counted with multiplicity, by later work).

The proof in the literature sharpens the crude product bound above with careful case analysis on small primes and exponents, but the conceptual core — the strict deficiency of prime powers established here as Theorem 5.4 — is the same inequality iterated and optimized. The deficiency of the atoms is precisely the obstruction that forces odd perfects, should they exist, to be vast multi-prime objects.

---

## 10. Algorithms

The framework is constructive and yields simple, exact-arithmetic algorithms.

**Algorithm A (Abundancy classification).** Given $n > 0$, compute $\sigma(n)$ by summing divisors, form the exact rational $A(n) = \sigma(n)/n$, and compare with $2$ to classify $n$ as deficient, perfect, or abundant. Complexity $O(\sqrt{n})$ using divisor pairing $d \leftrightarrow n/d$.

**Algorithm B (Euclid–Euler generator).** For each prime exponent $p$, test whether $M_p = 2^p - 1$ is prime (e.g. by Lucas–Lehmer); when it is, emit the even perfect number $2^{p-1} M_p$. This enumerates *all* even perfect numbers by Theorem 8.1.

**Algorithm C (Local-factor abundancy product).** Factor $n = \prod p_i^{a_i}$, compute each local abundancy $A(p_i^{a_i}) = (p_i^{a_i+1}-1)/(p_i^{a_i}(p_i-1))$ exactly, and multiply. This realizes Theorem 4.1 and avoids enumerating divisors.

---

## 11. Applications

- **Search pruning for odd perfects.** The bound $\prod_{p\mid n}\frac{p}{p-1} > 2$ (Section 9) immediately rules out candidate prime supports that are too small or too large-primed, the workhorse pruning rule in computational searches.
- **Multiplicative number theory pedagogy.** The framework is a compact, fully rigorous illustration of how multiplicativity reduces global arithmetic questions to local (prime-power) computations.
- **Friendly and sociable numbers.** $A(n)$ generalizes directly: two numbers are *friendly* when they share an abundancy index, and the same multiplicative machinery governs that theory.

---

## 12. Discussion

The strength of the abundancy viewpoint is that it isolates the two logically distinct halves of perfect-number theory. The condition $A(n) = 2$ (perfection) is a *value* statement — an exact $\sigma$-identity proved by clearing denominators (Theorem 3.2). The deficiency results are *comparison* statements — geometric-series estimates proved by a single positivity inequality, $p^k(p-2)+1 > 0$ (Theorem 5.4). Multiplicativity (Theorem 4.1) is the glue that lets local comparisons assemble into global structure (Theorem 6.1, Section 9).

A subtle point is the exclusion of $n = 0$: the index $A(0) = \sigma(0)/0$ is the meaningless $0/0$, so all statements are quantified over $n > 0$. The reciprocal identity (Theorem 7.1) is proved by the divisor involution rather than by case enumeration, and so holds for all $n > 0$ uniformly.

---

## 13. Future directions

The following conjectures are falsifiable and each names a concrete next formalization target.

**13.1 Strict deficiency forces many prime factors (toward Nielsen).** For every fixed bound $B$, a perfect number with abundancy index exactly $2$ and at most $k$ distinct prime factors must satisfy $\prod_{p \mid n} \frac{p}{p-1} \ge 2$; since $\prod \frac{p}{p-1}$ over the $k$ smallest odd primes grows only logarithmically, an *odd* perfect number needs $k$ larger than any fixed $B$. The key insight is that $A(n) = \prod_{p^a \| n} \frac{\sigma(p^a)}{p^a} < \prod_{p \mid n}\frac{p}{p-1}$, so perfection imposes a multiplicative lower bound on the prime support that small prime sets cannot meet. This is the same inequality (Theorem 5.4) iterated, a direct formalizable path from $k \ge 2$ toward the spirit of Nielsen's $k \ge 101$.

**13.2 Euler's form of odd perfect numbers.** If $n$ is an odd perfect number then $n = p^a m^2$ with $p$ prime, $p \equiv a \equiv 1 \pmod 4$, and $p \nmid m$. The key insight is that $\sigma(n) = 2n$ with $n$ odd forces $\sigma(n) \equiv 2 \pmod 4$, so exactly one prime-power factor contributes the single factor of $2$ to $\sigma$, pinning its exponent and residue. The abundancy/$\sigma$-multiplicativity API already isolates per-prime contributions; the remaining work is a mod-$4$ parity bookkeeping over $\sigma(p^a)$.

**13.3 No perfect number is a perfect square.** No perfect number $n$ is a perfect square. The key insight is that if $n$ is a square then $\sigma(n)$ is odd (each local factor $1 + p + \cdots + p^{2a}$ has an odd number of odd terms), whereas a perfect number has $\sigma(n) = 2n$ even — an immediate parity contradiction. We already have $\sigma(n) = 2n$ directly; the only missing lemma is "$n$ a square $\Rightarrow \sigma(n)$ odd."

**13.4 Even perfect numbers are sums of consecutive odd cubes.** For every even perfect number $n > 6$, writing $n = 2^{p-1}(2^p - 1)$, one has $n = 1^3 + 3^3 + 5^3 + \cdots + (2^{(p+1)/2} - 1)^3$ (the sum of the first $2^{(p-1)/2}$ odd cubes). The key insight is the identity $\sum_{j=1}^{t}(2j-1)^3 = t^2(2t^2 - 1)$, which for $t = 2^{(p-1)/2}$ equals $2^{p-1}(2^p - 1)$ exactly.

**13.5 Triangular $\Rightarrow$ perfect is exactly the Mersenne-prime locus.** Among triangular numbers $T_m = m(m+1)/2$, $T_m$ is perfect if and only if $m = 2^p - 1$ for a Mersenne prime $2^p - 1$. (Every even perfect number is triangular; the conjecture pins down which triangular numbers are perfect.)

---

## 14. Conclusion

A single rational invariant, the abundancy index $A(n) = \sigma(n)/n$, organizes the theory of perfect numbers into a clean, provable architecture. Perfection is the identity $A(n) = 2$; multiplicativity reduces $A$ to its prime-power values; and those values are uniformly, strictly less than $2$. From this one deficiency fact follow the impossibility of prime-power perfects, the abundancy derivation of the Euclid–Euler classification, and the conceptual mechanism behind Nielsen's $101$-prime lower bound for odd perfects. The framework turns an ancient curiosity into a precise study of how deficient atoms must combine to achieve perfection.
