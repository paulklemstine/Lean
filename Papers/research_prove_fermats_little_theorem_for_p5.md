# The Congruence $a^5 \equiv a \pmod 5$: Fermat's Little Theorem at a Prime, with Field-Theoretic, Elementary, and Combinatorial Proofs

## Abstract

We give a complete and self-contained account of the divisibility statement $5 \mid a^5 - a$ for every integer $a$, situating it as the special case $p = 5$ of Fermat's Little Theorem. We present three independent proofs that illuminate different facets of the phenomenon: (i) a structural proof via the Frobenius endomorphism of the finite field $\mathbb{F}_5$, in which raising to the fifth power is literally the identity map; (ii) an elementary proof by the factorization $a^5 - a = (a-1)a(a+1)(a^2+1)$ together with an exhaustive residue analysis modulo $5$; and (iii) a combinatorial/probabilistic proof counting aperiodic necklaces of prime length, where divisibility by $5$ appears as the orbit-size of a free cyclic group action. We state the general theorem for arbitrary primes, prove it in the same field-theoretic framework, and discuss extensions to composite moduli, culminating in Korselt's criterion for Carmichael numbers. Throughout, the guiding theme is that "$p$-th powering is the identity" is a synchronization statement about the cyclic structure of modular arithmetic.

---

## 1. Introduction

Among the first surprises a student of number theory encounters is that certain algebraic combinations of an integer are *always* divisible by a fixed number, regardless of the integer chosen. The cleanest example attached to the prime $5$ is:

$$\boxed{\,5 \mid a^5 - a \quad \text{for every integer } a.\,}$$

Numerically: $3^5 - 3 = 240 = 5\cdot 48$; $2^5 - 2 = 30 = 5\cdot 6$; $10^5 - 10 = 99990 = 5\cdot 19998$; and $(-4)^5 - (-4) = -1024 + 4 = -1020 = 5 \cdot (-204)$.

This is the instance $p = 5$ of **Fermat's Little Theorem**, which asserts $p \mid a^p - a$ for every prime $p$ and integer $a$. The purpose of this paper is to record, in fully self-contained form, why the statement holds, to give three conceptually distinct proofs, and to place the result in the broader landscape of modular arithmetic and its generalizations.

The three proofs are not redundant. The field-theoretic proof reveals *why $5$ works and $6$ does not*: primality is precisely what makes the residue ring a field. The elementary proof is verifiable by hand and requires no abstraction. The combinatorial proof recasts an arithmetic congruence as the shadow of a symmetry group acting freely, connecting the result to probability and the theory of random cyclic structures.

## 2. Preliminaries and Definitions

**Definition 2.1 (Divisibility).** For integers $m, n$, we say $m$ *divides* $n$, written $m \mid n$, if there exists an integer $k$ with $n = mk$.

**Definition 2.2 (Congruence).** For integers $a, b$ and a positive integer $n$, we write $a \equiv b \pmod n$ if $n \mid (a - b)$. Congruence modulo $n$ is an equivalence relation compatible with addition and multiplication.

**Definition 2.3 (The residue ring $\mathbb{Z}/n\mathbb{Z}$).** The set of congruence classes modulo $n$ forms a commutative ring with $n$ elements under the induced addition and multiplication. We denote it $\mathbb{Z}/n\mathbb{Z}$, and write $\mathbb{F}_p$ when $n = p$ is prime.

**Definition 2.4 (Field).** A *field* is a commutative ring in which every nonzero element has a multiplicative inverse.

**Proposition 2.5.** $\mathbb{Z}/n\mathbb{Z}$ is a field if and only if $n$ is prime.

*Proof sketch.* If $n = p$ is prime and $0 < a < p$, then $\gcd(a, p) = 1$, so by Bézout's identity there exist integers $x, y$ with $ax + py = 1$, whence $ax \equiv 1 \pmod p$ and $x$ is the inverse of $a$. Conversely, if $n = de$ with $1 < d, e < n$, then $d$ is a nonzero zero divisor and cannot be invertible. $\square$

**Definition 2.6 (Frobenius endomorphism).** In a commutative ring of prime characteristic $p$, the map $x \mapsto x^p$ is a ring homomorphism, called the *Frobenius endomorphism*. It is additive because in characteristic $p$ all intermediate binomial coefficients $\binom{p}{k}$ for $0 < k < p$ are divisible by $p$, so $(x+y)^p = x^p + y^p$.

## 3. The Main Result and Its Proofs

### 3.1 Statement

**Theorem 3.1 (Fermat's Little Theorem, integer form).** *Let $p$ be a prime and $a$ an integer. Then $p \mid a^p - a$.*

**Corollary 3.2 (The case $p = 5$).** *For every integer $a$, $\;5 \mid a^5 - a$.*

We now prove Theorem 3.1 in full generality, then specialize; afterward we give two further proofs specific to (but not limited to) $p = 5$.

### 3.2 Proof I: The Frobenius endomorphism on a finite field

The central algebraic fact is the following.

**Lemma 3.3 (Power map on a finite field).** *In a finite field $F$ with exactly $q$ elements, every element $x \in F$ satisfies $x^q = x$.*

*Proof sketch.* The nonzero elements $F^\times$ form a group of order $q - 1$ under multiplication. By Lagrange's theorem, $x^{q-1} = 1$ for every $x \in F^\times$. Multiplying by $x$ gives $x^q = x$ for all $x \neq 0$, and the identity $x^q = x$ holds trivially at $x = 0$. Hence $x^q = x$ throughout $F$. $\square$

*Proof of Theorem 3.1.* Reduce modulo $p$. The ring $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$ is a field with exactly $p$ elements (Proposition 2.5). By Lemma 3.3 with $q = p$, we have $\bar a^{\,p} = \bar a$ in $\mathbb{F}_p$ for the class $\bar a$ of $a$. Equivalently, $a^p \equiv a \pmod p$, i.e. $p \mid a^p - a$. $\square$

Specializing to $p = 5$ proves Corollary 3.2. The content of this proof is that **fifth-powering is the identity map on $\mathbb{F}_5$** — the Frobenius endomorphism $x \mapsto x^5$ equals $\mathrm{id}_{\mathbb{F}_5}$. Direct verification: $0^5=0$, $1^5=1$, $2^5 = 32 \equiv 2$, $3^5 = 243 \equiv 3$, $4^5 = 1024 \equiv 4 \pmod 5$.

This proof also explains the necessity of primality: if $n$ is composite, $\mathbb{Z}/n\mathbb{Z}$ is not a field, $\mathbb{Z}/n\mathbb{Z}^\times$ has order $\varphi(n) < n - 1$, and the argument breaks down. Indeed $a^n \equiv a \pmod n$ fails for most composite $n$ (e.g. $2^4 = 16 \equiv 0 \not\equiv 2 \pmod 4$).

### 3.3 Proof II: Elementary factorization and residue analysis

**Lemma 3.4 (Factorization).** *For every integer $a$,*
$$a^5 - a = (a-1)\,a\,(a+1)\,(a^2 + 1).$$

*Proof.* Expand: $(a-1)a(a+1) = a(a^2 - 1) = a^3 - a$, and $(a^3 - a)(a^2+1) = a^5 + a^3 - a^3 - a = a^5 - a$. $\square$

*Proof of Corollary 3.2.* Consider the residue $r = a \bmod 5 \in \{0,1,2,3,4\}$ and show $5$ divides one of the factors in Lemma 3.4:

| $r = a \bmod 5$ | Divisible factor | Reason |
|---|---|---|
| $0$ | $a$ | $5 \mid a$ |
| $1$ | $a - 1$ | $a - 1 \equiv 0$ |
| $2$ | $a^2 + 1$ | $2^2 + 1 = 5 \equiv 0$ |
| $3$ | $a^2 + 1$ | $3^2 + 1 = 10 \equiv 0$ |
| $4$ | $a + 1$ | $a + 1 \equiv 0$ |

In every case exactly one factor is a multiple of $5$, so the product $a^5 - a$ is divisible by $5$. $\square$

The key observation for $r \in \{2,3\}$ is that squares modulo $5$ take only the values $\{0,1,4\}$; the value $4$ arises precisely at $r = 2, 3$, making $a^2 + 1 \equiv 0$. This proof requires no field theory and can be checked entirely by finite computation.

### 3.4 Proof III: Aperiodic necklaces and a free group action

We recast the quantity $a^5 - a$ as a count of combinatorial objects, exposing the divisibility as an orbit-counting phenomenon.

**Setup.** Fix an alphabet of $a$ symbols (colors). A *string* of length $p$ is an ordered tuple $(x_0, x_1, \dots, x_{p-1})$ with each $x_i$ drawn from the alphabet; there are $a^p$ strings. The *cyclic group* $C_p = \mathbb{Z}/p\mathbb{Z}$ acts by rotation: $\sigma \cdot (x_0, \dots, x_{p-1}) = (x_{p-1}, x_0, \dots, x_{p-2})$.

**Lemma 3.5 (Free action on non-constant strings, prime length).** *Let $p$ be prime. A string of length $p$ is fixed by some nontrivial rotation if and only if it is constant (all symbols equal). Consequently, $C_p$ acts freely on the set of non-constant strings, and every such orbit has exactly $p$ elements.*

*Proof sketch.* Suppose a rotation by $k$ steps, $1 \le k \le p-1$, fixes the string. Since $p$ is prime, $\gcd(k, p) = 1$, so $k$ generates all of $C_p$; hence the string is fixed by *every* rotation, forcing all symbols equal. The contrapositive gives the claim, and by the orbit–stabilizer theorem an orbit with trivial stabilizer has size $|C_p| = p$. $\square$

*Proof of Theorem 3.1 (combinatorial).* There are exactly $a$ constant strings (one per symbol), so there are $a^p - a$ non-constant strings. By Lemma 3.5 these partition into orbits of size exactly $p$; if there are $N$ orbits then $a^p - a = pN$. In particular $p \mid a^p - a$. $\square$

For $p = 5$: the number of genuine $5$-bead necklaces on $a$ colors is $(a^5 - a)/5$. **Probabilistic phrasing.** Draw a string of prime length $p$ uniformly at random and condition on it being non-constant; then its rotation-orbit has exactly $p$ members with probability $1$. Divisibility by $p$ is the arithmetic shadow of this free symmetry.

## 4. Algorithms

We describe the constructive procedures underlying the demonstrations.

**Algorithm A (Residue-class witness).** Given $a$, determine which factor of $(a-1)a(a+1)(a^2+1)$ certifies divisibility by $5$, returning both the witnessing factor and the quotient $(a^5-a)/5$. Complexity: $O(1)$ arithmetic operations (on fixed-size inputs).

**Algorithm B (Necklace counter).** Given alphabet size $a$ and prime length $p$, count aperiodic necklaces as $(a^p - a)/p$ and verify integrality by explicit orbit enumeration for small $p$. Enumeration complexity: $O(p\cdot a^p)$; closed-form complexity: $O(\log p)$ multiplications via fast exponentiation.

**Algorithm C (Frobenius table).** Build the map $x \mapsto x^p$ on $\mathbb{Z}/p\mathbb{Z}$ and check it equals the identity, confirming Lemma 3.3 computationally. Complexity: $O(p \log p)$.

## 5. Applications

- **Primality testing.** The Fermat test uses the contrapositive of Theorem 3.1: if $a^n \not\equiv a \pmod n$ for some $a$, then $n$ is composite. This underlies fast probabilistic primality screening.
- **Public-key cryptography.** The RSA cryptosystem's correctness rests on Euler's generalization of Fermat's Little Theorem; the prime case is the conceptual seed.
- **Cyclic redundancy and coding.** Arithmetic in $\mathbb{F}_p$ and its extensions, where $x^q = x$ characterizes the base field inside $\mathbb{F}_{q^k}$, is foundational to error-correcting codes.

## 6. Extensions to Composite Moduli

The field-theoretic proof suggests immediately what can go wrong and be repaired for composite $n$.

**Definition 6.1 (Carmichael number).** A composite number $n$ is a *Carmichael number* if $a^n \equiv a \pmod n$ for every integer $a$.

**Theorem 6.2 (Korselt's criterion).** *A composite $n > 1$ satisfies $a^n \equiv a \pmod n$ for all integers $a$ if and only if $n$ is squarefree and $p - 1 \mid n - 1$ for every prime $p \mid n$.*

*Proof idea.* By the Chinese Remainder Theorem the condition factors prime-by-prime. Squarefreeness eliminates nilpotent obstructions (a repeated prime factor $p^2 \mid n$ makes $p^n \equiv 0 \not\equiv p$); the condition $p - 1 \mid n - 1$ synchronizes the exponent with the order $p-1$ of each cyclic group $\mathbb{F}_p^\times$, so that $a^{n} \equiv a \pmod p$ for all $a$. $\square$

The smallest Carmichael number is $561 = 3 \cdot 11 \cdot 17$, and indeed $2 \mid 560$, $10 \mid 560$, $16 \mid 560$. Thus the clean identity that $5$ enjoys because it is prime is enjoyed by a rare family of composites for a subtler, synchronization-based reason.

## 7. Discussion

Three proofs of one small fact reveal three mathematical worldviews. Algebraically, $5 \mid a^5 - a$ because fifth-powering is the identity endomorphism of a five-element field. Elementarily, it is because five consecutive-ish factors cover every residue. Combinatorially, it is because a prime-order cyclic group shreds non-constant strings into equal orbits. That a single congruence admits such varied explanations is characteristic of number theory, where arithmetic, algebra, and combinatorics repeatedly converge.

The unifying slogan is *synchronization*: "power = identity" holds precisely when the exponent lands on a common period of the cyclic structure. For a prime the structure is a single clock of period $p - 1$ (plus the fixed point $0$), and $p$-th powering closes the loop. For composite moduli one must synchronize several clocks at once — the content of Korselt's criterion.

## 8. Future Directions

1. **Universal exponents beyond primes.** For fixed modulus $n$, the congruence $a^k \equiv a \pmod n$ holds for all $a$ exactly when the exponent $k$ synchronizes every cyclic component; for squarefree $n$ the least such $k > 1$ is governed by $\mathrm{lcm}\{p - 1 : p \mid n\}$. The identity-map viewpoint invites a systematic study of how far it survives when the modulus is composite and the ambient object is only a ring.

2. **Squarefree = universal-power modulus.** Korselt's criterion (Theorem 6.2) marks the exact boundary between moduli that do and do not enjoy the universal-power property. The $p = 5$ result is the smallest nontrivial instance of the family whose composite members are the Carmichael numbers (beginning at $561$); charting this boundary is the immediate generalization.

3. **A probabilistic necklace interpretation.** For every prime $p$ and alphabet size $a$, the count $a^p - a$ is exactly $p$ times the number of aperiodic circular strings of length $p$; equivalently, a uniformly random non-constant string of prime length has a rotation-orbit of size exactly $p$ with probability one. This Burnside-style bridge connects elementary number theory to the theory of random symmetric structures.

## References

- P. de Fermat, correspondence (1640).
- Standard treatments of finite fields, the Frobenius endomorphism, and Korselt's criterion in introductory algebraic number theory.
