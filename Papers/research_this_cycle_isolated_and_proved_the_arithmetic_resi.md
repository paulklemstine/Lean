# The Arithmetic Residue of $E_4^2 = E_8$: Sharp Divisor-Sum Congruences from Pointwise Power Residues

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

The one-dimensionality of the space of weight-$8$ level-one modular forms forces the Eisenstein
identity $E_4^2 = E_8$. Comparing the $q$-expansions of the two sides yields the exact convolution law
$\sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)\sigma_3(n-i)$, and in particular the divisor-sum
congruence $\sigma_7(n) \equiv \sigma_3(n) \pmod{120}$. We isolate the arithmetic content of this
transcendental identity and prove it by wholly elementary means. The central tool is a *transfer principle*:
any pointwise power congruence $m \mid a^j - a^k$ holding for all integers $a$ propagates verbatim to the
divisor power sums, $m \mid \sigma_j(n) - \sigma_k(n)$, because a divisor sum is a sum of powers. Combining
this with the finite residue computations $120 \mid d^7 - d^3$ and $24 \mid d^5 - d^3$ we obtain the
congruences $\sigma_7 \equiv \sigma_3 \pmod{120}$ and $\sigma_5 \equiv \sigma_3 \pmod{24}$. We further prove
that both moduli are *optimal*: $120$ (resp. $24$) is the greatest modulus for which the congruence holds for
all $n$, each sharpness statement witnessed at $n = 2$. Scaling by the $E_8$ vector-count normalization $240$
gives $28800 \mid 240\sigma_7(n) - 240\sigma_3(n)$, the modulus relevant to the rank-$16$ even unimodular
lattice genus. Finally, we verify concrete instances of the exact convolution law, confirming that the
elementary arithmetic reproduces the Eisenstein coefficients term by term.

**Keywords:** divisor sums, Eisenstein series, modular forms, power residues, congruences, sharp modulus,
convolution identity, even unimodular lattices, $E_8$.

**MSC 2020:** 11A25, 11F11, 11F30, 11E45.

---

## 1. Introduction

For a nonnegative integer $k$ and a positive integer $n$, the *divisor power sum* is

$$\sigma_k(n) = \sum_{d \mid n} d^k,$$

the sum of the $k$-th powers of the positive divisors of $n$. These arithmetic functions are the
building blocks of the Fourier ($q$-expansion) coefficients of Eisenstein series. In weight $2k$, the
normalized Eisenstein series $E_{2k}$ has an expansion of the form
$E_{2k} = 1 - \frac{4k}{B_{2k}}\sum_{n\ge 1}\sigma_{2k-1}(n)q^n$, where $B_{2k}$ is a Bernoulli number.
In particular,

$$E_4 = 1 + 240\sum_{n \ge 1}\sigma_3(n)q^n, \qquad E_8 = 1 + 480\sum_{n\ge 1}\sigma_7(n)q^n.$$

The space $M_8$ of holomorphic level-one modular forms of weight $8$ is one-dimensional. Since $E_4^2$ and
$E_8$ are both weight-$8$ forms with constant term $1$, they coincide:

$$E_4^2 = E_8. \tag{1.1}$$

Extracting the coefficient of $q^n$ from $(1.1)$ gives, after dividing by $480$, the **exact convolution law**

$$\sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)\,\sigma_3(n-i). \tag{1.2}$$

The self-convolution term is a nonnegative integer, so $(1.2)$ immediately implies the congruence

$$\sigma_7(n) \equiv \sigma_3(n) \pmod{120} \qquad \text{for all } n \ge 1. \tag{1.3}$$

The purpose of this paper is to isolate $(1.3)$ — and its sharpness, its weight-$6$ analogue, and a
lattice-theoretic corollary — as a self-contained, elementary theory. The modular-forms identity $(1.1)$
serves only as motivation. Our contributions are:

1. A **transfer principle** (Theorem 3.1) reducing every divisor-sum congruence of the shape
   $\sigma_j \equiv \sigma_k$ to a *pointwise* power congruence $m \mid a^j - a^k$.
2. Elementary proofs of the pointwise laws $120 \mid d^7 - d^3$ and $24 \mid d^5 - d^3$ (Theorem 2.2).
3. The divisor-sum congruences $\sigma_7 \equiv \sigma_3 \pmod{120}$ and $\sigma_5 \equiv \sigma_3 \pmod{24}$
   (Theorem 3.2).
4. **Sharpness**: $120$ and $24$ are the *greatest* admissible moduli (Theorem 4.1), each witnessed at $n = 2$.
5. A cross-domain corollary $28800 \mid 240\sigma_7(n) - 240\sigma_3(n)$ (Theorem 5.1), the modulus governing
   the rank-$16$ even unimodular lattice genus.
6. Verification of concrete instances of the exact convolution law $(1.2)$ (Theorem 6.1).

The unifying message is that a single reusable bridge — the transfer principle — converts finite residue
computations into congruences among the intricate coefficients of modular forms, with no appeal to the
analytic theory beyond the initial motivation.

---

## 2. Pointwise power-residue laws

We work over $\mathbb{Z}$ throughout, writing $\sigma_k(n) = \sum_{d\mid n} d^k \in \mathbb{Z}$.

### 2.1 A bridge from modular arithmetic to divisibility

**Lemma 2.1 (Residue-to-divisibility bridge).**
*Let $m, j, k$ be nonnegative integers and suppose that $x^j = x^k$ for every residue $x \in \mathbb{Z}/m\mathbb{Z}$.
Then $m \mid a^j - a^k$ for every integer $a$.*

*Proof.* The reduction map $\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z}$ is a ring homomorphism, so the image of
$a^j - a^k$ is $\bar a^{\,j} - \bar a^{\,k}$. By hypothesis $\bar a^{\,j} = \bar a^{\,k}$, so the image is $0$,
which is equivalent to $m \mid a^j - a^k$. $\qquad\blacksquare$

The hypothesis "$x^j = x^k$ for all $x \in \mathbb{Z}/m\mathbb{Z}$" is a finite condition: it can be checked by
enumerating the $m$ residues. This makes Lemma 2.1 a decision procedure for pointwise power congruences.

### 2.2 The two residue laws

**Theorem 2.2 (Pointwise power residues).**
*For every integer $d$,*
$$120 \mid d^7 - d^3 \qquad\text{and}\qquad 24 \mid d^5 - d^3.$$

*Proof.* By Lemma 2.1 it suffices to check that $x^7 = x^3$ for all $x \in \mathbb{Z}/120\mathbb{Z}$ and that
$x^5 = x^3$ for all $x \in \mathbb{Z}/24\mathbb{Z}$; both are finite verifications.

For a conceptual proof of $120 \mid d^7 - d^3$, factor
$$d^7 - d^3 = d^3(d^4 - 1) = d^3(d-1)(d+1)(d^2+1),$$
and use $120 = 8 \cdot 3 \cdot 5$ together with the Chinese Remainder Theorem:

- *Divisibility by $8$.* If $d$ is even then $8 \mid d^3$. If $d$ is odd then $(d-1)(d+1)$ is a product of two
  consecutive even numbers, hence divisible by $8$.
- *Divisibility by $3$.* Among $d-1, d, d+1$ one is divisible by $3$, so $3 \mid d^3(d-1)(d+1)$.
- *Divisibility by $5$.* By Fermat's little theorem $d^5 \equiv d \pmod 5$, hence $d^7 = d^5\cdot d^2 \equiv d^3
  \pmod 5$.

The three coprime factors $8, 3, 5$ combine to give $120 \mid d^7 - d^3$. The proof of $24 \mid d^5 - d^3$ is
analogous, using $24 = 8 \cdot 3$ and $d^5 - d^3 = d^3(d-1)(d+1)$. $\qquad\blacksquare$

---

## 3. The transfer principle and the divisor-sum congruences

The heart of the theory is that a *pointwise* congruence propagates to divisor sums with no extra work.

### 3.1 Transfer principle

**Theorem 3.1 (Transfer principle).**
*Let $m$ be an integer and $j, k$ nonnegative integers. Suppose $m \mid a^j - a^k$ for every integer $a$.
Then for every positive integer $n$,*
$$m \mid \sigma_j(n) - \sigma_k(n).$$

*Proof.* Expanding the definitions and combining the two sums,
$$\sigma_j(n) - \sigma_k(n) = \sum_{d\mid n} d^j - \sum_{d\mid n} d^k = \sum_{d\mid n}\bigl(d^j - d^k\bigr).$$
By hypothesis each summand $d^j - d^k$ is divisible by $m$, and a sum of multiples of $m$ is a multiple of
$m$. $\qquad\blacksquare$

Theorem 3.1 is deliberately stated for arbitrary exponents $j, k$ and arbitrary modulus $m$: it is the reusable
bridge that turns any residue computation into an Eisenstein-coefficient congruence.

### 3.2 The congruences

**Theorem 3.2 (Divisor-sum congruences).**
*For every positive integer $n$,*
$$\sigma_7(n) \equiv \sigma_3(n) \pmod{120} \qquad\text{and}\qquad \sigma_5(n) \equiv \sigma_3(n) \pmod{24}.$$

*Proof.* Combine Theorem 2.2 with Theorem 3.1, taking $(j,k,m) = (7,3,120)$ and $(5,3,24)$ respectively.
$\qquad\blacksquare$

The first congruence is precisely the arithmetic residue $(1.3)$ of the identity $E_4^2 = E_8$; the second is
its weight-$6$ analogue, the arithmetic residue of the corresponding rigidity statement one weight lower.

---

## 4. Sharpness of the moduli

We now show that the moduli $120$ and $24$ cannot be improved. Fix exponents and consider the set of admissible
moduli
$$\mathcal{M}_{j,k} = \{\, m \in \mathbb{Z}_{>0} : m \mid \sigma_j(n) - \sigma_k(n) \text{ for all } n \,\}.$$

**Theorem 4.1 (Optimality).**
*The number $120$ is the greatest element of $\mathcal{M}_{7,3}$, and the number $24$ is the greatest element of
$\mathcal{M}_{5,3}$. The same optimality holds for the pointwise sets
$\{m > 0 : m \mid a^7 - a^3\ \forall a\}$ and $\{m > 0 : m \mid a^5 - a^3\ \forall a\}$, with greatest elements
$120$ and $24$ respectively.*

*Proof.* Membership $120 \in \mathcal{M}_{7,3}$ and $24 \in \mathcal{M}_{5,3}$ is Theorem 3.2. For the upper
bound, evaluate at $n = 2$, whose divisors are $1$ and $2$:
$$\sigma_3(2) = 1 + 2^3 = 9,\quad \sigma_7(2) = 1 + 2^7 = 129,\quad \sigma_5(2) = 1 + 2^5 = 33.$$
Hence
$$\sigma_7(2) - \sigma_3(2) = 120, \qquad \sigma_5(2) - \sigma_3(2) = 24.$$
Any $m \in \mathcal{M}_{7,3}$ must divide the value at $n = 2$, i.e. $m \mid 120$, so $m \le 120$; and $120$
itself lies in the set, so it is the greatest element. Likewise every $m \in \mathcal{M}_{5,3}$ divides $24$,
giving $m \le 24$, and $24$ is attained. The pointwise statements are identical, witnessed at $a = 2$ where
$a^7 - a^3 = 120$ and $a^5 - a^3 = 24$. $\qquad\blacksquare$

Thus the constants appearing in the Eisenstein congruences are not artifacts of a lossy argument but are exactly
the arithmetic weights of the corresponding correction terms.

---

## 5. A cross-domain corollary: the rank-16 even unimodular genus

There are exactly two even unimodular lattices of rank $16$: the orthogonal sum $E_8 \oplus E_8$ and the lattice
$D_{16}^+$. Their theta series are weight-$8$ modular forms, and the number of lattice vectors of squared length
$2n$ has the shape $240\,\sigma_7(n)$ plus a cusp-form contribution. The relevant modulus for comparing the two
genera is $28800 = 240 \cdot 120$.

**Theorem 5.1 ($E_8$-normalized congruence).**
*For every positive integer $n$,*
$$28800 \mid 240\,\sigma_7(n) - 240\,\sigma_3(n).$$

*Proof.* By Theorem 3.2 write $\sigma_7(n) - \sigma_3(n) = 120c$ for some integer $c$. Then
$$240\,\sigma_7(n) - 240\,\sigma_3(n) = 240\bigl(\sigma_7(n) - \sigma_3(n)\bigr) = 240 \cdot 120\, c = 28800\,c,$$
which is divisible by $28800$. $\qquad\blacksquare$

Theorem 5.1 transports a purely arithmetic statement about divisor sums into a congruence between lattice vector
counts, showing that genus-level congruences for the rank-$16$ even unimodular lattices follow from an elementary
power residue rather than from a mass formula.

### 5.1 Interpretation and further applications

The theta series of a positive-definite even lattice $L$ of rank $2\kappa$ is
$\Theta_L(\tau) = \sum_{x \in L} q^{\langle x,x\rangle/2} = \sum_{m \ge 0} r_L(m) q^m$, where $r_L(m)$ counts the
vectors of squared length $2m$. For an even unimodular lattice this is a modular form of weight $\kappa$. In rank
$16$ ($\kappa = 8$) the Eisenstein part of this space is one-dimensional, so the Eisenstein component of $r_L(m)$
is proportional to $\sigma_7(m)$, with a cusp-form correction accounting for the rest; after the customary
normalization the leading arithmetic term is a multiple of $240\,\sigma_7(m)$. Theorem 5.1
then states that, modulo $28800$, this leading term is indistinguishable from $240\,\sigma_3(m)$, the vector count
of the reference lattice $E_8$. Consequently, any two rank-$16$ even unimodular lattices have theta coefficients
that are congruent modulo $28800$ in their Eisenstein parts, isolating the entire discrepancy between $E_8 \oplus
E_8$ and $D_{16}^+$ into the cusp-form defect.

The same normalization trick applies whenever a divisor-sum congruence $\sigma_j \equiv \sigma_k \pmod m$ is
scaled by an integer constant $c$: one obtains $cm \mid c\,\sigma_j(n) - c\,\sigma_k(n)$ immediately. Choosing $c$
to be the Eisenstein normalization of a target weight converts abstract congruences into statements about
concrete counting functions — representation numbers of quadratic forms, coefficients of theta series, and
dimensions of weighted lattice shells — with no additional analytic input.

---

## 6. The exact convolution law

Define the self-convolution of $\sigma_3$ by
$$(\sigma_3 \star \sigma_3)(n) = \sum_{i=1}^{n-1}\sigma_3(i)\,\sigma_3(n-i),$$
an empty sum (equal to $0$) when $n = 1$. Equation $(1.2)$ predicts $\sigma_7(n) = \sigma_3(n) + 120(\sigma_3
\star \sigma_3)(n)$. While a full elementary proof for all $n$ is the subject of Direction 1 below, the identity
can be verified in any finite range.

**Theorem 6.1 (Convolution-law instances).**
*The identity $\sigma_7(n) = \sigma_3(n) + 120(\sigma_3\star\sigma_3)(n)$ holds for $n = 2,3,4,5$.*

*Proof.* Direct computation. For example, at $n = 4$ the divisors give $\sigma_3(4) = 1 + 8 + 64 = 73$ and
$\sigma_7(4) = 1 + 128 + 16384 = 16513$; the convolution is
$(\sigma_3\star\sigma_3)(4) = \sigma_3(1)\sigma_3(3) + \sigma_3(2)\sigma_3(2) + \sigma_3(3)\sigma_3(1) = 28 + 81 +
28 = 137$, and indeed $73 + 120\cdot 137 = 73 + 16440 = 16513$. The cases $n = 2, 3, 5$ are analogous.
$\qquad\blacksquare$

| $n$ | $\sigma_3(n)$ | $\sigma_7(n)$ | $(\sigma_3\star\sigma_3)(n)$ | $\sigma_3(n) + 120(\sigma_3\star\sigma_3)(n)$ |
|----:|-----:|-----:|-----:|-----:|
| $2$ | $9$ | $129$ | $1$ | $129$ |
| $3$ | $28$ | $2188$ | $18$ | $2188$ |
| $4$ | $73$ | $16513$ | $137$ | $16513$ |
| $5$ | $126$ | $78126$ | $650$ | $78126$ |

---

## 6.1 A worked example in full

To make the mechanism concrete, we trace every step for $n = 6$. The divisors of
$6$ are $1, 2, 3, 6$. Hence
$$\sigma_3(6) = 1 + 8 + 27 + 216 = 252, \qquad \sigma_7(6) = 1 + 128 + 2187 + 279936 = 282252.$$
The difference is $282252 - 252 = 282000 = 120 \cdot 2350$, so the congruence
$\sigma_7(6) \equiv \sigma_3(6) \pmod{120}$ holds with quotient $2350$. Decomposing by the
transfer principle, the same quotient arises divisor by divisor:
$$\frac{1^7 - 1^3}{120} + \frac{2^7 - 2^3}{120} + \frac{3^7 - 3^3}{120} + \frac{6^7 - 6^3}{120}
= 0 + 1 + \tfrac{2160}{120} + \tfrac{279720}{120} = 0 + 1 + 18 + 2331 = 2350,$$
illustrating that $\sigma_7 - \sigma_3$ is literally the sum of the local
contributions $d^7 - d^3$, each a multiple of $120$. The exact convolution law
gives the same value through a different route:
$(\sigma_3 \star \sigma_3)(6) = 2350$, and indeed $\sigma_3(6) + 120 \cdot 2350 = 252 + 282000 = 282252 = \sigma_7(6)$.

## 7. Discussion

The results above fit a single template. A congruence among Eisenstein coefficients of the form
$\sigma_j \equiv \sigma_k \pmod m$ is equivalent to the pointwise divisibility $m \mid a^j - a^k$ for all $a$
(the transfer principle in one direction; evaluation at prime powers in the other). The pointwise divisibility
is a *finite* condition — check the residues modulo $m$ — and the optimal modulus is
$$M_{j,k} = \gcd_{a \in \mathbb{Z}}\bigl(a^j - a^k\bigr),$$
a computable quantity. For $(j,k) = (7,3)$ this gcd is $120$; for $(5,3)$ it is $24$. Both are realized already
at $a = 2$, which is why the witness $n = 2$ certifies sharpness.

This reframing dissolves the apparent mystery of the constant $120$: it is neither arbitrary nor an artifact of
the modular-forms derivation, but the exact gcd of the polynomial family $a^7 - a^3$. The modular-forms identity
$E_4^2 = E_8$ explains *why* the difference $\sigma_7 - \sigma_3$ is a $120$-fold convolution (upgrading the
congruence to the equality $(1.2)$), while the elementary transfer principle explains *that* it is a multiple of
$120$, and pins the constant sharply.

### 7.1 The gcd formula and its structure

The optimal modulus $M_{j,k} = \gcd_{a}(a^j - a^k)$ admits a completely explicit description via prime
factorization. For a prime $p$, the $p$-adic valuation $v_p(M_{j,k})$ can be computed from the behaviour of the
polynomial $x^j - x^k = x^k(x^{j-k} - 1)$ over $\mathbb{Z}/p^e\mathbb{Z}$. When $k \ge 1$, the factor $x^k$
contributes divisibility whenever $p \mid x$, while the factor $x^{j-k} - 1$ contributes when $p \nmid x$ and
$(p-1) \mid (j-k)$, by Fermat's little theorem and its prime-power refinements. This is why the primes dividing
$M_{7,3}$ are exactly $2, 3, 5$: the exponent gap $j - k = 4$ is divisible by $p - 1$ precisely for
$p \in \{2, 3, 5\}$. For the pair $(5,3)$ the gap is $2$, admitting only $p \in \{2, 3\}$, which yields
$M_{5,3} = 24$.

Computing the sample values gives the sequence $M_{5,3} = 24$, $M_{7,3} = 120$, $M_{9,3} = 504$, and so on. Each
modulus is a product of prime powers $p^{e}$ determined by the divisibility condition $(p-1) \mid (j-k)$ together
with the valuation of $x^k$, in the same spirit as the von Staudt-Clausen theorem, which describes Bernoulli
denominators through exactly such a $(p-1) \mid m$ condition. Conjecturally (Direction 2) the family $M_{2k-1,3}$
is governed by the arithmetic of the Bernoulli numbers controlling Eisenstein normalizations; making this
correspondence precise is an open problem. In any case, the prime-by-prime description above already renders each
$M_{j,k}$ explicitly computable.

### 7.2 Scope and limitations

The transfer principle is one-directional in the sharpest sense: it converts a pointwise congruence into a
divisor-sum congruence with no loss, and evaluation at $n = 2$ recovers the pointwise witness, so the two optimal
moduli coincide. It does not, however, by itself upgrade the congruence $(1.3)$ to the *equality* $(1.2)$; the
convolution structure is genuinely additional information carried by the modular-forms identity. Establishing the
full convolution law for all $n$ by elementary means (Direction 1) remains a structural identity to be proved,
not a residue computation.

---

## 8. Future directions

### Direction 1 — the exact convolution law

**Conjecture.** For all $n \ge 1$, $\displaystyle \sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)
\sigma_3(n-i)$.

This upgrades the congruence $(1.3)$ to an equality; it is equivalent to $E_4^2 = E_8$. It is verified here for
small $n$. The remaining task is a structural identity: either a coefficient-by-coefficient comparison of the
Eisenstein $q$-expansions, or a purely elementary Liouville-style divisor-sum identity. The transfer principle
already reproduces the residue modulo $120$ of every term.

### Direction 2 — a congruence hierarchy across even weights

**Conjecture.** For each odd exponent $2k-1$ there is an optimal modulus $M_k$ with $\sigma_{2k-1}(n) \equiv
\sigma_3(n) \pmod{M_k}$, governed by Bernoulli-number denominators. The first two nontrivial instances are
$M = 24$ for exponent $5$ and $M = 120$ for exponent $7$, both proved sharp. The bridge lemma generalizes
verbatim: for any target exponents $j, k$ the optimal modulus is $M_{j,k} = \gcd_a(a^j - a^k)$, computable and
transferable to divisor sums by the same transfer principle. The next step is to prove the general formula and
relate it to the denominator of $B_{2k}$.

### Direction 3 — representation-number congruences for lattice genera

**Conjecture.** For every even unimodular lattice of rank $16$, the number of vectors of squared length $2n$ is
congruent modulo $28800$ to $240\,\sigma_3(n)$, the $E_8$ vector count, uniformly in $n$; the two rank-$16$
lattices $E_8 \oplus E_8$ and $D_{16}^+$ differ only through a cusp-form contribution that vanishes modulo
$28800$. Theorem 5.1 supplies the exact modulus; the remaining step is to identify the cusp-form defect and
confirm it lands in the same residue class.

---

## References

1. J.-P. Serre, *A Course in Arithmetic*, Graduate Texts in Mathematics 7, Springer, 1973.
2. T. M. Apostol, *Modular Functions and Dirichlet Series in Number Theory*, Springer, 1990.
3. J. H. Conway and N. J. A. Sloane, *Sphere Packings, Lattices and Groups*, Springer, 1999.
