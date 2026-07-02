# The Fifth-Power Congruence Modulo Five and Its Pythagorean Consequences

## Abstract

We give a fully elementary, self-contained proof that for every integer $a$, the quantity $a^5 - a$ is divisible by $5$ — the case $p = 5$ of Fermat's little theorem — using nothing beyond the arithmetic of remainders. The argument reduces an assertion about infinitely many integers to a finite case analysis over the five residues modulo $5$. We then develop the surrounding structure: the table of quadratic residues modulo $5$ (namely $\{0, 1, 4\}$), and we use it to derive a classical consequence for Pythagorean triples — every triple $(a,b,c)$ with $a^2 + b^2 = c^2$ contains an entry divisible by $5$, and, in concert with the analogous obstructions modulo $3$ and $4$, the product $abc$ is always divisible by $60$ with $60$ sharp. We situate the $p=5$ identity within the general family $a^k - a$, whose universal modulus is the product of primes $p$ with $(p-1) \mid (k-1)$, and we discuss algorithmic and cryptographic ramifications. All results are stated inline with complete proof sketches.

## 1. Introduction

The congruence
$$
a^5 \equiv a \pmod 5, \qquad \text{equivalently} \qquad 5 \mid a^5 - a,
$$
holding for every integer $a$, is the specialization to the prime $5$ of Fermat's little theorem. While the general theorem admits slick proofs via group theory (Lagrange's theorem applied to the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$) or combinatorics (necklace counting), our aim here is a maximally elementary treatment of the single prime $p = 5$, requiring only the notion of division with remainder. The elementary route has two virtues: it is transparent, and it exposes the residue table of squares modulo $5$, which turns out to be the shared engine behind a family of Pythagorean divisibility facts.

The paper is organized as follows. Section 2 fixes definitions. Section 3 proves the main congruence by residue case analysis and by a factorization argument. Section 4 develops the quadratic-residue structure modulo $5$. Section 5 derives the Pythagorean consequences. Section 6 generalizes to arbitrary fixed exponents. Section 7 gives algorithms, Section 8 applications, and Section 9 discussion and future work.

## 2. Definitions and preliminaries

Throughout, $a, b, c, n$ denote integers and $p$ a prime.

**Definition 2.1 (Divisibility).** For integers $m, n$, we write $m \mid n$ ("$m$ divides $n$") if there exists an integer $k$ with $n = mk$.

**Definition 2.2 (Congruence).** For a positive integer $m$, we write $a \equiv b \pmod m$ if $m \mid (a - b)$. This is an equivalence relation compatible with addition and multiplication: if $a \equiv a'$ and $b \equiv b' \pmod m$, then $a + b \equiv a' + b'$ and $ab \equiv a'b' \pmod m$.

**Definition 2.3 (Residue).** The *residue* of $a$ modulo $m$ is the unique integer $r$ with $0 \le r < m$ and $a \equiv r \pmod m$. Every integer is congruent to exactly one of $0, 1, \dots, m-1$.

**Definition 2.4 (Quadratic residue).** A residue $r$ modulo $m$ is a *quadratic residue* if $r \equiv x^2 \pmod m$ for some integer $x$; otherwise it is a *quadratic non-residue*.

**Definition 2.5 (Pythagorean triple).** A *Pythagorean triple* is an ordered triple $(a, b, c)$ of positive integers with $a^2 + b^2 = c^2$.

We will use the following standard fact, itself an immediate consequence of division with remainder.

**Lemma 2.6 (Five-way residue decomposition).** For every integer $a$, exactly one of the following holds:
$$
a \bmod 5 \in \{0, 1, 2, 3, 4\}.
$$
Equivalently, there is a unique integer $q$ and residue $r \in \{0,1,2,3,4\}$ with $a = r + 5q$.

*Proof.* Division with remainder of $a$ by $5$. $\qquad\blacksquare$

## 3. The main congruence

**Theorem 3.1 (Fermat's little theorem, $p = 5$).** For every integer $a$,
$$
5 \mid a^5 - a.
$$

*Proof (residue case analysis).* By Lemma 2.6 write $a = r + 5q$ with $r \in \{0,1,2,3,4\}$. Because congruence is compatible with multiplication, $a^5 - a \equiv r^5 - r \pmod 5$, so it suffices to verify the claim for the five representatives:

| $r$ | $r^5$ | $r^5 - r$ | multiple of $5$ |
|----|-------|-----------|------------------|
| $0$ | $0$    | $0$        | $5 \cdot 0$ |
| $1$ | $1$    | $0$        | $5 \cdot 0$ |
| $2$ | $32$   | $30$       | $5 \cdot 6$ |
| $3$ | $243$  | $240$      | $5 \cdot 48$ |
| $4$ | $1024$ | $1020$     | $5 \cdot 204$ |

In every row $r^5 - r$ is a multiple of $5$; hence so is $a^5 - a$. $\qquad\blacksquare$

For completeness we record the explicit witnesses that make the case analysis fully constructive. Substituting $a = r + 5q$ and expanding, one obtains $a^5 - a = 5 \cdot Q_r(q)$ for an integer polynomial $Q_r$ in $q$:

- $r=0$: $a^5 - a = 5\,(625 q^5 - q)$;
- $r=1$: $a^5 - a = 5\,(625 q^5 + 625 q^4 + 250 q^3 + 50 q^2 + 4 q)$;
- $r=2$: $a^5 - a = 5\,(625 q^5 + 1250 q^4 + 1000 q^3 + 400 q^2 + 79 q + 6)$;
- $r=3$: $a^5 - a = 5\,(625 q^5 + 1875 q^4 + 2250 q^3 + 1350 q^2 + 404 q + 48)$;
- $r=4$: $a^5 - a = 5\,(625 q^5 + 2500 q^4 + 4000 q^3 + 3200 q^2 + 1279 q + 204)$.

Each identity is verified by expanding both sides as polynomials in $q$; the exhibited integer coefficient is the required cofactor, giving an explicit $k$ with $a^5 - a = 5k$.

*Alternative proof (factorization).* Factor
$$
a^5 - a = a(a^4 - 1) = a(a-1)(a+1)(a^2 + 1).
$$
If $a \equiv 0, 1,$ or $4 \pmod 5$, then respectively $a$, $a - 1$, or $a + 1$ is divisible by $5$. The remaining residues are $a \equiv 2$ and $a \equiv 3$; in both, $a^2 \equiv 4 \pmod 5$, so $a^2 + 1 \equiv 0 \pmod 5$. Thus one factor is always divisible by $5$. $\qquad\blacksquare$

**Corollary 3.2.** The divisibility $5 \mid a^5 - a$ holds in particular for every integer in any finite range; e.g. for all $a$ with $-1000 \le a \le 1000$. This is an immediate instance of Theorem 3.1 and requires no separate computation.

## 4. Quadratic residues modulo five

**Proposition 4.1 (Square table mod $5$).** The set of quadratic residues modulo $5$ is exactly $\{0, 1, 4\}$. Concretely,
$$
0^2 \equiv 0,\quad 1^2 \equiv 1,\quad 2^2 \equiv 4,\quad 3^2 \equiv 4,\quad 4^2 \equiv 1 \pmod 5.
$$
The residues $2$ and $3$ are quadratic non-residues.

*Proof.* Direct evaluation over the five residues, using that $x^2 \bmod 5$ depends only on $x \bmod 5$. $\qquad\blacksquare$

**Proposition 4.2 (Sums of two squares mod $5$).** If $a, b$ are both coprime to $5$, then
$$
a^2 + b^2 \bmod 5 \in \{0, 2, 3\}.
$$
Moreover, of these, only $0$ is itself a quadratic residue modulo $5$.

*Proof.* By Proposition 4.1, each nonzero square is $1$ or $4$ mod $5$. The three unordered sums are $1+1 = 2$, $1 + 4 = 5 \equiv 0$, and $4 + 4 = 8 \equiv 3$. Comparing $\{0, 2, 3\}$ with the residue set $\{0,1,4\}$ from Proposition 4.1 shows only $0$ is a square. $\qquad\blacksquare$

## 5. Pythagorean consequences

**Theorem 5.1 (Every Pythagorean triple contains a multiple of five).** For every Pythagorean triple $(a, b, c)$, at least one of $a, b, c$ is divisible by $5$.

*Proof.* Suppose neither leg is divisible by $5$, i.e. $5 \nmid a$ and $5 \nmid b$. By Proposition 4.2, $c^2 = a^2 + b^2 \equiv 0, 2,$ or $3 \pmod 5$. But $c^2$ is a square, so by Proposition 4.1 it must be $\equiv 0, 1,$ or $4 \pmod 5$. The only common value is $0$, forcing $c^2 \equiv 0$ and hence $5 \mid c$ (as $5$ is prime). Therefore in all cases some entry is divisible by $5$. $\qquad\blacksquare$

*Examples.* $(3,4,\mathbf{5})$, $(\mathbf{5},12,13)$, $(8,\mathbf{15},17)$, $(\mathbf{20},21,29)$, $(9,\mathbf{40},41)$ — the boldface entry is the guaranteed multiple of $5$.

**Theorem 5.2 (Universal divisor $60$, sharp).** For every Pythagorean triple $(a,b,c)$, the product $abc$ is divisible by $60$, and $60$ is the largest integer dividing $abc$ for all triples.

*Proof (sketch).* Three independent congruence obstructions cooperate:

1. *Factor $4$.* In a primitive triple one leg is even; a residue analysis modulo $4$ shows the even leg is in fact divisible by $4$. Scaling to imprimitive triples preserves the factor.
2. *Factor $3$.* Squares modulo $3$ lie in $\{0,1\}$; if neither leg were divisible by $3$ then $a^2 + b^2 \equiv 2 \pmod 3$, which is not a square, a contradiction. Hence $3$ divides some entry.
3. *Factor $5$.* Theorem 5.1.

Since $3, 4, 5$ are pairwise coprime, their contributions multiply to give $3 \cdot 4 \cdot 5 = 60 \mid abc$. Sharpness follows from the triple $(3,4,5)$, whose product is exactly $3 \cdot 4 \cdot 5 = 60$; no larger constant can divide $60$. $\qquad\blacksquare$

## 6. The general fixed-power congruence

Theorem 3.1 belongs to the family of identities $a^k - a$.

**Theorem 6.1 (Universal modulus of $a^k - a$).** Fix an integer $k \ge 2$. The largest integer $m$ such that $m \mid a^k - a$ for all integers $a$ is
$$
m = \prod_{\substack{p \text{ prime} \\ (p-1) \mid (k-1)}} p,
$$
the product of all primes $p$ for which $p - 1$ divides $k - 1$.

*Proof (sketch).* For a prime $p$: by Fermat's little theorem $a^{p} \equiv a \pmod p$, and more generally $a^{1 + t(p-1)} \equiv a \pmod p$ for all $t \ge 0$ (for $a$ coprime to $p$ raise $a^{p-1} \equiv 1$ to the $t$-th power; for $p \mid a$ both sides are $0$). Hence if $(p-1) \mid (k-1)$ then $a^k \equiv a \pmod p$ for all $a$, so $p \mid a^k - a$. Conversely, if $(p-1) \nmid (k-1)$, choose a primitive root $g$ modulo $p$; then $g^{k} \not\equiv g \pmod p$, so $p \nmid g^k - g$ and $p$ cannot divide the universal modulus. No prime power $p^2$ can be forced, since $a = p$ gives $a^k - a = p(p^{k-1} - 1)$ with $p \nmid p^{k-1}-1$. Squarefreeness and the stated product follow. $\qquad\blacksquare$

**Corollary 6.2.** For $k = 5$, the primes with $(p-1) \mid 4$ are $p \in \{2, 3, 5\}$, so $a^5 - a$ is universally divisible by $2 \cdot 3 \cdot 5 = 30$, strengthening Theorem 3.1. For $k = 3$, the primes with $(p-1)\mid 2$ are $\{2,3\}$, recovering the classical $6 \mid a^3 - a$.

## 7. Algorithms

We describe the computational procedures that accompany the theory.

**Algorithm A (Residue-reduction verifier).** To confirm $5 \mid a^5 - a$ for arbitrary $a$ without large-number arithmetic: compute $r = a \bmod 5$, then check that $r^5 - r \equiv 0 \pmod 5$ from the precomputed table. Complexity $O(1)$ per input after building the size-$5$ table. This mirrors the proof of Theorem 3.1: correctness rests on the congruence-compatibility of powers.

**Algorithm B (Universal-modulus computation).** To compute the sharp modulus of $a^k - a$ (Theorem 6.1): enumerate primes $p$ up to $k$ (a prime with $p - 1 \mid k - 1$ satisfies $p \le k$), test whether $(p-1) \mid (k-1)$, and multiply the qualifying primes. Complexity $O(k \log\log k)$ using a sieve.

**Algorithm C (Pythagorean five-witness).** Given a triple $(a,b,c)$, return which entry Theorem 5.1 guarantees is divisible by $5$: scan $a, b, c$ and report the first divisible by $5$. Correctness is Theorem 5.1; complexity $O(1)$.

## 8. Applications

**Modular reduction and hashing.** The identity $a^5 \equiv a \pmod 5$ is a template for *power-preserving* maps used in checksum and hashing schemes over prime fields, where raising to a power fixes the field elementwise.

**Public-key cryptography.** The RSA cryptosystem encrypts via $c = m^e \bmod N$ and decrypts via $m = c^d \bmod N$, relying on the identity $m^{ed} \equiv m$ — a direct generalization of the fixed-power congruence studied here to composite moduli via the Chinese Remainder Theorem and Euler's theorem. The $p = 5$ case is the smallest nontrivial prime illustration of the mechanism.

**Diophantine filtering.** Theorem 5.1 and Proposition 4.2 provide instant necessary conditions ("sieves") that prune candidate solutions to quadratic Diophantine equations by inspecting residues modulo $5$, avoiding costly searches.

## 9. Discussion and future work

The elementary proof of $5 \mid a^5 - a$ illustrates a recurring theme: infinite arithmetic assertions collapse to finite residue computations. The same residue table that proves the congruence forces a factor of five into every Pythagorean triple and, combined with the modulo-$3$ and modulo-$4$ obstructions, yields the sharp universal divisor $60$ for the product $abc$.

Several directions invite further study: pinning the exact universal modulus of $a^k - a$ for all $k$ (Theorem 6.1) and its interaction with Carmichael numbers; characterizing which residues are representable as sums of two squares modulo a prime and relating this to hypotenuse structure; and quantifying the density of fixed points of the map $x \mapsto x^m$ across prime and composite moduli. These are elaborated in the accompanying future-directions notes.

## Appendix: worked numerical instances

- $a = 2$: $a^5 - a = 30 = 5 \cdot 6$.
- $a = 7$: $a^5 - a = 16800 = 5 \cdot 3360 = 30 \cdot 560$ (illustrating the stronger $30 \mid a^5-a$).
- $a = -3$: $a^5 - a = -243 + 3 = -240 = 5 \cdot(-48)$.
- Triple $(20,21,29)$: $20 = 5\cdot 4$ is the guaranteed multiple of five; product $20\cdot21\cdot29 = 12180 = 60 \cdot 203$.
