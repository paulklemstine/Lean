# The Divisor Factorization of Torus-Knot OAM Spectra

## Abstract

A *knotted light* beam is an optical field whose phase-singularity core traces a
knot $K$ in space. A physical conjecture links the quantized orbital-angular-momentum
(OAM) values such a beam may carry to the roots of the Alexander polynomial
$\Delta_K$ of that knot. For the family of $T(2,n)$ torus knots the Alexander
polynomial is the alternating geometric sum
$A_n(X) = 1 - X + X^2 - \cdots + X^{n-1}$. It was previously known that, for an odd
**prime** $p$, this polynomial coincides with a single cyclotomic polynomial,
$A_p = \Phi_{2p}$. We remove the primality hypothesis and establish the general
structural law: **for every odd $n$**, the $T(2,n)$ Alexander polynomial factors as
the product of cyclotomic polynomials $\Phi_{2d}$ over the nontrivial divisors of
$n$,
$$
A_n(X) \;=\; \prod_{\substack{d \mid n \\ d > 1}} \Phi_{2d}(X).
$$
Consequently the OAM spectrum of a $T(2,n)$ beam is a disjoint union of
primitive-root layers, one layer of primitive $2d$-th roots of unity for each
nontrivial divisor $d \mid n$. We derive: (i) a master product identity
$\prod_{d \mid n}\Phi_{2d} = X^n + 1$ for odd $n$; (ii) the exact layer count
$\tau(n) - 1$; (iii) a primality criterion — a single layer occurs iff $n$ is
prime; (iv) a nested prime-power stratification
$A_{p^k} = \prod_{i=1}^{k}\Phi_{2p^i}$; and (v) the total channel count $n-1$,
equal to $\sum_{d \mid n,\, d>1}\varphi(2d)$. All results are stated and proved for
general odd $n$, with the earlier prime case recovered as a corollary.

**Keywords:** torus knot, Alexander polynomial, cyclotomic polynomial, orbital
angular momentum, knotted light, divisor lattice, roots of unity, Galois orbit.

---

## 1. Introduction

### 1.1 Knotted light and its OAM spectrum

Structured light fields can be engineered so that their optical vortices — the
one-dimensional loci where the field amplitude vanishes and the phase is undefined
— form linked and knotted curves as the field propagates. These *knotted light*
configurations realize genuine knots $K \subset \mathbb{R}^3$ within a coherent
beam. A coherent beam also carries **orbital angular momentum**: the azimuthal
winding of its phase contributes quantized units of angular momentum along the
propagation axis.

A physical conjecture ties these two features together: the admissible OAM
eigenvalues of a knotted beam are governed by the roots of the **Alexander
polynomial** $\Delta_K(X)$ of the knot $K$ traced by its vortex core. The Alexander
polynomial is a classical isotopy invariant of $K$; encoding OAM data in its roots
turns an optical spectral question into an algebraic one. The purpose of this paper
is to determine that algebraic structure, exactly and in full generality, for the
$T(2,n)$ torus-knot family.

### 1.2 The $T(2,n)$ family and its Alexander polynomial

The torus knot $T(2,n)$ (for odd $n \ge 3$) wraps twice meridionally and $n$ times
longitudinally around a standard torus; $T(2,3)$ is the trefoil, $T(2,5)$ the
cinquefoil, and so on. Its Alexander polynomial (suitably normalized) is the
alternating geometric sum
$$
A_n(X) \;=\; \sum_{k=0}^{n-1} (-1)^k X^k
\;=\; 1 - X + X^2 - \cdots + X^{\,n-1}.
$$
We treat $A_n \in \mathbb{Z}[X]$ as the object of study for all odd $n \ge 1$
(with $A_1 = 1$ the empty case). The whole paper rests on one elementary identity.

**Fundamental identity.** For all $n$,
$$
A_n(X)\,(X + 1) \;=\; X^n + 1. \tag{F}
$$
This is immediate: $(X+1)\sum_{k=0}^{n-1}(-1)^kX^k$ telescopes, all interior terms
cancelling and leaving $(-1)^{n-1}X^n + 1 = X^n + 1$ when $n$ is odd.

### 1.3 Cyclotomic polynomials

For $m \ge 1$, the $m$-th **cyclotomic polynomial** $\Phi_m(X) \in \mathbb{Z}[X]$
is the monic polynomial whose roots are exactly the primitive $m$-th roots of
unity. Two standard facts are used throughout:
$$
X^m - 1 \;=\; \prod_{d \mid m} \Phi_d(X), \tag{C}
$$
and each $\Phi_m$ is irreducible over $\mathbb{Q}$, hence represents a single
Galois-conjugacy orbit of roots of unity. We recall $\Phi_1 = X - 1$,
$\Phi_2 = X + 1$, $\Phi_6 = X^2 - X + 1$, and $\deg \Phi_m = \varphi(m)$ with
$\varphi$ Euler's totient.

### 1.4 Contributions

The prior state of the art identified $A_p = \Phi_{2p}$ for odd prime $p$. We show
that primality was never essential; it merely forced $n$ to have a single divisor
$> 1$. Our contributions are:

1. **A master product identity** (Theorem 3.1): for odd $n > 0$,
   $\prod_{d \mid n}\Phi_{2d} = X^n + 1$.
2. **The divisor factorization** (Theorem 4.1): for odd $n > 0$,
   $A_n = \prod_{d \mid n,\, d>1}\Phi_{2d}$.
3. **Structural corollaries** (Section 5): the layer count $\tau(n) - 1$, the
   primality criterion, the prime-power stratification, and the degree/channel
   count $n-1$.

---

## 2. Divisor combinatorics for $2n$ with $n$ odd

The factorization hinges on how the divisors of $2n$ behave when $n$ is odd.

**Lemma 2.1 (Odd divisors).** *If $n$ is odd and $d \mid n$, then $d$ is odd.*

*Proof.* A divisor of an odd number cannot be even, since an even divisor would
force $2 \mid n$. $\square$

**Lemma 2.2 (Divisor split).** *For every $n \ge 1$,*
$$
\mathrm{Div}(2n) \;=\; \mathrm{Div}(n)\;\cup\;\{\,2d : d \in \mathrm{Div}(n)\,\},
$$
*where $\mathrm{Div}(m)$ denotes the set of positive divisors of $m$.*

*Proof.* Since $\mathrm{Div}(2) = \{1, 2\}$ and divisors are multiplicative over the
coprime-free product $2 \cdot n$, every divisor of $2n$ is $1\cdot d$ or $2 \cdot d$
for some $d \mid n$; conversely all such products divide $2n$. $\square$

**Lemma 2.3 (Disjointness).** *If $n$ is odd, then $\mathrm{Div}(n)$ and
$\{2d : d \mid n\}$ are disjoint.*

*Proof.* An element of the second set is even; by Lemma 2.1 every element of the
first set is odd. An even number equal to an odd number is impossible. $\square$

Moreover the doubling map $d \mapsto 2d$ is injective, so
$|\{2d : d \mid n\}| = \tau(n)$.

---

## 3. The master product identity

**Theorem 3.1 (Master identity).** *For odd $n > 0$,*
$$
\prod_{d \mid n} \Phi_{2d}(X) \;=\; X^n + 1.
$$

*Proof.* Work in $R = \mathbb{Z}[X]$. Apply (C) at $2n$ and at $n$:
$$
\prod_{e \mid 2n}\Phi_e = X^{2n} - 1, \qquad
\prod_{d \mid n}\Phi_d = X^{n} - 1.
$$
By the divisor split (Lemma 2.2) and disjointness (Lemma 2.3), together with
injectivity of $d \mapsto 2d$,
$$
\prod_{e \mid 2n}\Phi_e
= \Big(\prod_{d \mid n}\Phi_d\Big)\Big(\prod_{d \mid n}\Phi_{2d}\Big)
= (X^n - 1)\prod_{d \mid n}\Phi_{2d}.
$$
Hence $(X^n - 1)\prod_{d \mid n}\Phi_{2d} = X^{2n} - 1 = (X^n - 1)(X^n + 1)$.
Since $X^n - 1 \ne 0$ and $R$ is an integral domain, cancel it to obtain
$\prod_{d \mid n}\Phi_{2d} = X^n + 1$. $\square$

Intuitively, Theorem 3.1 isolates the "even part" of the factorization of
$X^{2n} - 1$: the divisors $2d$ (with $d \mid n$) contribute precisely the factor
$X^n + 1$, complementary to the odd part $X^n - 1$.

---

## 4. The divisor factorization of $A_n$

**Theorem 4.1 (Divisor factorization).** *For every odd $n > 0$,*
$$
A_n(X) \;=\; \prod_{\substack{d \mid n \\ d > 1}} \Phi_{2d}(X).
$$

*Proof.* Let $P = \prod_{d \mid n,\, d>1}\Phi_{2d}$. Separate the $d = 1$ term from
the master identity. The only divisor of $n$ that is not $> 1$ is $d = 1$, and
$\Phi_{2\cdot 1} = \Phi_2 = X + 1$. Thus, by Theorem 3.1,
$$
P \cdot (X + 1)
= \Big(\prod_{\substack{d \mid n \\ d > 1}}\Phi_{2d}\Big)\Phi_2
= \prod_{d \mid n}\Phi_{2d}
= X^n + 1.
$$
Comparing with the fundamental identity (F), $A_n(X)(X+1) = X^n + 1 = P(X+1)$.
Since $X + 1 \ne 0$ and $\mathbb{Z}[X]$ is a domain, cancel $X+1$ to get
$A_n = P$. $\square$

**Interpretation.** The roots of $A_n$ are exactly the union, over nontrivial
divisors $d \mid n$, of the primitive $2d$-th roots of unity. Every such root lies
on the unit circle, at an angle that is an odd multiple of $\pi/d$; there are no
spurious or off-circle roots. The OAM spectrum of a $T(2,n)$ beam is therefore a
*disjoint union of primitive-root layers* indexed by the nontrivial divisor lattice
of $n$, each layer being a single irreducible Galois orbit.

---

## 5. Structural corollaries

Throughout, $\tau(n)$ is the number of positive divisors of $n$ and $\varphi$ is
Euler's totient.

**Corollary 5.1 (Layer count).** *For $n > 0$, the number of primitive-root layers
equals the number of nontrivial divisors,*
$$
\#\{d \mid n : d > 1\} \;=\; \tau(n) - 1.
$$

*Proof.* The set $\{d \mid n : d > 1\}$ is $\mathrm{Div}(n)\setminus\{1\}$, and
$1 \in \mathrm{Div}(n)$, so its cardinality is $\tau(n) - 1$. $\square$

**Corollary 5.2 (Primality criterion).** *For $n \ge 2$, the OAM spectrum has
exactly one primitive-root layer if and only if $n$ is prime:*
$$
\#\{d \mid n : d > 1\} = 1 \iff n \text{ prime}.
$$

*Proof.* By Corollary 5.1 the count is $\tau(n) - 1$, which equals $1$ iff
$\tau(n) = 2$, i.e. iff $n$ is prime. Equivalently: a single divisor $> 1$ means
$n$ itself is the only such divisor, which characterizes primes. $\square$

When $n = p$ is an odd prime, Theorem 4.1 collapses to the single factor
$A_p = \Phi_{2p}$, recovering the previously known cyclotomic identification of the
prime torus-knot spectrum.

**Corollary 5.3 (Prime-power stratification).** *For an odd prime $p$ and $k \ge 0$,*
$$
A_{p^k}(X) \;=\; \prod_{i=1}^{k} \Phi_{2p^i}(X),
$$
*an empty product (equal to $1$) when $k = 0$.*

*Proof.* The divisors of $p^k$ greater than $1$ are exactly $p, p^2, \dots, p^k$,
i.e. $\{p^i : 1 \le i \le k\}$. Substituting these into Theorem 4.1 (valid since
$p^k$ is odd) and re-indexing by $i$ gives the stated nested product. $\square$

The chain of divisors $1 \mid p \mid p^2 \mid \cdots \mid p^k$ means each step from
$p^{k}$ to $p^{k+1}$ adjoins a single new outer layer $\Phi_{2p^{k+1}}$, and the
map $\zeta \mapsto \zeta^{p}$ sends layer $i+1$ onto layer $i$ — a precise
self-similarity of the spectrum under $p$-fold angular rescaling.

**Corollary 5.4 (Channel count / degree).** *For odd $n > 0$,*
$$
\deg A_n \;=\; n - 1, \qquad\text{equivalently}\qquad
\sum_{\substack{d \mid n \\ d > 1}} \varphi(2d) \;=\; n - 1.
$$

*Proof.* From (F), $\deg\big(A_n (X+1)\big) = \deg(X^n + 1) = n$. The leading term
of $A_n$ (for odd $n$) is $X^{n-1}$ with unit coefficient, so $A_n(X+1)$ has
nonvanishing leading coefficient and $\deg A_n + \deg(X+1) = n$, giving
$\deg A_n = n - 1$. On the other hand, degrees add across the factorization of
Theorem 4.1 and $\deg \Phi_{2d} = \varphi(2d)$, yielding the totient identity. $\square$

For odd $d$ one has $\varphi(2d) = \varphi(d)$, so Corollary 5.4 is a refinement of
the classical $\sum_{d \mid n}\varphi(d) = n$ with the $d = 1$ term removed.

---

## 6. Worked examples

- **$n = 3$ (trefoil).** Divisors $> 1$: $\{3\}$. One layer:
  $A_3 = \Phi_6 = X^2 - X + 1$. Roots: primitive $6$-th roots of unity
  $e^{\pm i\pi/3}$. Channels: $2 = \varphi(6)$.
- **$n = 5$ (cinquefoil).** Divisors $> 1$: $\{5\}$. One layer:
  $A_5 = \Phi_{10} = X^4 - X^3 + X^2 - X + 1$. Channels: $4 = \varphi(10)$.
- **$n = 9$.** Divisors $> 1$: $\{3, 9\}$. Two nested layers:
  $A_9 = \Phi_6 \cdot \Phi_{18}$, with $\deg = \varphi(6) + \varphi(18) = 2 + 6 = 8
  = 9 - 1$.
- **$n = 15$.** Divisors $> 1$: $\{3, 5, 15\}$. Three layers:
  $A_{15} = \Phi_6\,\Phi_{10}\,\Phi_{30}$, with
  $\varphi(6) + \varphi(10) + \varphi(30) = 2 + 4 + 8 = 14 = 15 - 1$.
- **$n = 27 = 3^3$.** Nested tower $A_{27} = \Phi_6\,\Phi_{18}\,\Phi_{54}$, with
  layer sizes $2, 6, 18$ summing to $26 = 27 - 1$.

---

## 7. Algorithms

We record two effective procedures implied by the theory.

**Algorithm A (Spectrum stratification).** Given odd $n$, output the OAM layers.
Compute $\mathrm{Div}(n)$, drop $d = 1$, and for each remaining $d$ emit the layer
"primitive $2d$-th roots of unity" of size $\varphi(2d)$. Correctness is Theorem
4.1; complexity is dominated by factoring/divisor enumeration, $O(\sqrt{n})$ trial
division plus $O(\tau(n))$ totient evaluations.

**Algorithm B (Optical primality test).** Given $n \ge 2$, stratify as in Algorithm
A and report "prime" iff exactly one layer results. Correctness is Corollary 5.2.

**Algorithm C (Factorization verifier).** Independently compute $A_n$ by the
alternating sum and by the cyclotomic product $\prod_{d\mid n,\,d>1}\Phi_{2d}$, and
confirm equality of coefficient vectors. This certifies Theorem 4.1 on any given
$n$.

---

## 8. Applications and discussion

- **Optical mode design.** The stratification prescribes exactly which primitive
  roots of unity a $T(2,n)$ beam should support, giving a target spectrum for
  hologram synthesis. Choosing $n$ with a prescribed divisor lattice engineers a
  prescribed layering of OAM channels.
- **Number theory made visible.** The primality criterion (Corollary 5.2) turns a
  spectral count into an arithmetic test; more broadly, the *multiset* of layer
  sizes $\{\varphi(2d)\}$ encodes the divisor structure of $n$.
- **Robust invariance.** Because each layer is an irreducible cyclotomic factor —
  a single Galois orbit — the decomposition is canonical: it cannot be refined
  further over $\mathbb{Q}$, so the layers are intrinsic features, not artifacts of
  a particular coordinatization.

---

## 9. Future directions

The following continuations are natural and testable.

1. **Galois-orbit fingerprinting.** Since each layer is an irreducible orbit, the
   unordered layer list $\{2d : d \mid n,\, d > 1\}$ should be a complete invariant
   of a beam within the $T(2,\cdot)$ family: two such beams have spectra related by
   a field automorphism iff $m = n$. The divisor lattice, and hence $n$, is
   recoverable from the layer degrees $\varphi(2d)$.

2. **The non-cyclotomic exception.** The torus family sits entirely on the unit
   circle. Contrast with the figure-eight knot $4_1$, whose Alexander polynomial
   $X^2 - 3X + 1$ has real reciprocal ("metallic") roots off the circle. A
   quadratic palindrome $X^2 - bX + 1$ is crystalline (roots on the circle) exactly
   for $|b| \le 1$ and metallic exactly for $|b| \ge 2$; every $T(2,p)$ sits at
   $b = 1$ while $4_1$ sits at $b = 3$, suggesting $4_1$ is the unique small
   metallic exception among knots of degree $\le 2$.

3. **Harmonic self-similarity of prime-power beams.** For an odd prime $p$, the
   $T(2,p^{k+1})$ spectrum is the $T(2,p^k)$ spectrum plus one outer layer of
   primitive $2p^{k+1}$-th roots, with $\zeta \mapsto \zeta^p$ carrying layer $j+1$
   onto layer $j$: exact self-similarity under $p$-fold angular zoom.

---

## 10. Conclusion

For every odd $n$, the $T(2,n)$ torus-knot Alexander polynomial is the product of
the cyclotomic polynomials $\Phi_{2d}$ over the nontrivial divisors $d$ of $n$.
Physically, the OAM spectrum of a $T(2,n)$ knotted-light beam is a disjoint union
of primitive-root layers, one per nontrivial divisor, with total channel count
$n-1$, layer count $\tau(n) - 1$, and a single layer precisely when $n$ is prime.
The arithmetic of $n$ is thereby written directly into the geometry of the beam.
