# The Alexander Polynomial of a Torus Knot as an Arithmetic Object

### A complete divisor-spectrum invariant, its numerical-semigroup dictionary, and provable obstructions to computational use

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

The Alexander polynomial $\Delta_{a,b}$ of the torus knot $T(a,b)$, for coprime
$a,b > 1$, factors over $\mathbb{Z}$ into cyclotomic polynomials indexed by the
*divisor spectrum* $S(a,b) = \{d : d \mid ab,\ d \nmid a,\ d \nmid b\}$. We develop the
consequences of this identification in three directions.

*Arithmetic.* For an odd semiprime $N = pq$, the polynomial $A_N(X) = (X^N+1)/(X+1)$,
the Alexander polynomial of $T(2,N)$, factors as
$\Phi_{2p}\Phi_{2q}\Phi_{2pq}$, whose irreducible factor degrees are
$\{p-1,\,q-1,\,(p-1)(q-1)\}$; from the largest of these, $\varphi(N)$, the pair $(p,q)$
is recovered as the roots of $Y^2 - (N+1-\varphi(N))Y + N$. We prove that the invariant
is *complete* on torus knots: $\Delta_{a,b}$ determines $(a,b)$, via a three-step maximum
extraction from the spectrum. We prove a $\gcd$-compatibility law
$\gcd(A_M, A_N) = A_{\gcd(M,N)}$ over $\mathbb{Q}$, with degree readout
$\deg\gcd + 1 = \gcd(M,N)$, and an explicit *join defect* correcting the failure of
$N \mapsto A_N$ to be a lattice homomorphism.

*Combinatorics.* We establish a coefficientwise dictionary between $\Delta_{a,b}$ and
the numerical semigroup $\langle a,b\rangle$: $\Delta_{a,b} = 1 - (1-X)G_{a,b}$ where
$G_{a,b}$ is the gap generating polynomial, so that
$[X^n]\Delta_{a,b} = \mathbb{1}[n \in \langle a,b\rangle] - \mathbb{1}[n-1 \in \langle a,b\rangle]$.
Consequences include: all coefficients lie in $\{0,\pm1\}$; palindromicity of the knot
invariant is *equivalent* to symmetry of $\langle a,b\rangle$; Sylvester's genus formula
$2\,\#\mathrm{Gaps}(a,b) = (a-1)(b-1)$; and a **support law**
$\#\operatorname{supp}\Delta_{a,b} = 2\beta(a,b)+1$ with $\beta$ the number of maximal
gap runs, giving the sharp lower bound $\#\operatorname{supp}\Delta_{a,b} \ge \max(a,b)$,
with equality exactly for the pencil $T(2,N)$ (where the count is $N$) and strict
inequality on the staircase family $T(a,a+1)$ (where the count is $2a-1$).

*Obstructions.* Each apparent shortcut is closed by a theorem. The knot determinant
$\Delta_{a,b}(-1)$ obeys a trichotomy: it equals $1$ when $ab$ is odd and equals the odd
parameter otherwise — never a new divisor. The support bound shows any materialization of
$\Delta_{a,b}$ costs $\Omega(\max(a,b))$ symbols, exponential in the $O(\log ab)$ bits
specifying the knot. And the cheap coefficient readout that *is* available — the least
positive index with coefficient $+1$ is $\min(a,b)$, and
$\deg\Delta_{a,b}/(\min(a,b)-1) + 1 = \max(a,b)$ — returns exactly the input parameters.
The bridge between knot theory and factorization is thus faithful and complete as an
encoding, and provably inert as an algorithm.

**Keywords:** torus knot, Alexander polynomial, cyclotomic polynomial, divisor spectrum,
numerical semigroup, Frobenius number, integer factorization, complete invariant.

---

## 1. Introduction

### 1.1 The phenomenon

Let $p \ne q$ be odd primes and $N = pq$. Consider the polynomial
$$A_N(X) \;=\; \frac{X^N+1}{X+1} \;=\; \sum_{k=0}^{N-1} (-1)^k X^{N-1-k},$$
the Alexander polynomial of the torus knot $T(2,N)$. Its factorization into irreducibles
over $\mathbb{Q}$ is
$$A_{pq}(X) \;=\; \Phi_{2p}(X)\,\Phi_{2q}(X)\,\Phi_{2pq}(X),$$
with degrees $p-1$, $q-1$, $(p-1)(q-1)$. The largest is Euler's totient $\varphi(N)$,
and from it
$$p+q \;=\; N + 1 - \varphi(N), \qquad pq = N,$$
so that $p,q$ are the roots of $Y^2 - (N+1-\varphi(N))Y + N$. For $N = 143$ the degree
multiset is $\{10,12,120\}$, giving $p+q = 24$ and hence $\{p,q\} = \{11,13\}$.

A topological invariant of a circle embedded in $S^3$ therefore contains the
factorization of an integer, in a completely explicit and recoverable form. The purpose
of this paper is to determine precisely how much of an encoding this is, and precisely
why it is not an algorithm.

### 1.2 Contributions

1. **A cyclotomic definition of $\Delta_{a,b}$** as a product over the divisor spectrum,
   from which the classical rational expression is derived rather than assumed
   (§2), together with degree, factor count, and normalization.
2. **Completeness** (§3): $\Phi_d \mid \Delta_{a,b} \iff d \in S(a,b)$, and $\Delta_{a,b}$
   determines the pair $(a,b)$ by three maxima. Torus knots are separated by their
   Alexander polynomials.
3. **The lattice bridge** (§4): $\gcd(A_M,A_N) = A_{\gcd(M,N)}$ over $\mathbb{Q}$ with
   degree readout; polynomial coprimality $\iff$ integer coprimality; an exact join defect
   with degree $\gcd + \operatorname{lcm} - M - N$; squarefreeness of $\Delta_{a,b}$ over
   $\mathbb{Q}$.
4. **The semigroup dictionary** (§5): the gap generating identity, the coefficient law,
   the $\{0,\pm1\}$ bound, semigroup symmetry from palindromicity, and Sylvester's genus
   formula.
5. **The support law and its sharpness** (§6): $\#\operatorname{supp}\Delta_{a,b} =
   2\beta(a,b)+1$; the bound $\ge \max(a,b)$; equality for $T(2,N)$; the staircase count
   $2a-1$.
6. **The obstruction package** (§7): the determinant trichotomy, the exponential support
   cost, the symmetry of the factor degrees in $p$ and $q$, and the cheap readout that
   returns only the input.

### 1.3 Notation

$\Phi_d \in \mathbb{Z}[X]$ is the $d$-th cyclotomic polynomial, monic, irreducible, of
degree $\varphi(d)$, with $X^n - 1 = \prod_{d \mid n} \Phi_d$. For $n \ge 1$,
$\operatorname{Div}(n)$ is the set of positive divisors, $\tau(n) = \#\operatorname{Div}(n)$.
$\langle a,b\rangle = \{ai + bj : i,j \in \mathbb{Z}_{\ge 0}\}$ is the numerical
semigroup generated by $a$ and $b$; its elements are *representable*, its complement in
$\mathbb{Z}_{\ge 0}$ consists of *gaps*. For a polynomial $f$, $\operatorname{supp} f$ is
the set of indices of nonzero coefficients.

---

## 2. The divisor spectrum and the Alexander polynomial of $T(a,b)$

**Definition 2.1 (Divisor spectrum).** For $a,b \ge 1$, the *divisor spectrum* of the
torus knot $T(a,b)$ is
$$S(a,b) \;=\; \{\, d \ge 1 \;:\; d \mid ab,\ d \nmid a,\ d \nmid b \,\}.$$

**Definition 2.2 (Torus Alexander polynomial).**
$$\Delta_{a,b}(X) \;=\; \prod_{d \in S(a,b)} \Phi_d(X) \;\in\; \mathbb{Z}[X].$$

Defining the invariant this way avoids any division and makes the factorization into
irreducibles part of the definition. That it agrees with the classical object is the
content of the next theorem.

**Theorem 2.3 (Defining identity).** For coprime $a,b \ge 1$,
$$(X^{ab}-1)(X-1) \;=\; \Delta_{a,b}(X)\,(X^{a}-1)(X^{b}-1).$$

*Proof sketch.* Expand each factor as a cyclotomic product:
$X^{ab}-1 = \prod_{d \mid ab}\Phi_d$, $X^a - 1 = \prod_{d \mid a}\Phi_d$,
$X^b - 1 = \prod_{d\mid b}\Phi_d$ and $X - 1 = \Phi_1$. Because $a$ and $b$ are coprime,
every divisor of $ab$ factors uniquely as a product of a divisor of $a$ and a divisor of
$b$; in particular $\operatorname{Div}(a) \cap \operatorname{Div}(b) = \{1\}$ and
$\operatorname{Div}(a) \cup \operatorname{Div}(b)$ is exactly the complement of $S(a,b)$
inside $\operatorname{Div}(ab)$. Hence
$$\prod_{d \in \operatorname{Div}(ab)\setminus S(a,b)} \Phi_d \cdot \Phi_1
= \Big(\prod_{d\mid a}\Phi_d\Big)\Big(\prod_{d\mid b}\Phi_d\Big),$$
the extra $\Phi_1$ compensating for the double counting of $d = 1$. Multiplying by
$\Delta_{a,b} = \prod_{d \in S(a,b)}\Phi_d$ gives the claim. $\square$

Thus $\Delta_{a,b} = \dfrac{(X^{ab}-1)(X-1)}{(X^a-1)(X^b-1)}$, the classical Alexander
polynomial of $T(a,b)$, and it is monic.

**Theorem 2.4 (Degree).** For coprime $a,b \ge 1$,
$\deg \Delta_{a,b} = (a-1)(b-1)$.

*Proof sketch.* $\deg \Delta_{a,b} = \sum_{d \in S(a,b)}\varphi(d)$. Summing $\varphi$
over all divisors of $ab$ gives $ab$; summing over $\operatorname{Div}(a)$ and
$\operatorname{Div}(b)$ gives $a$ and $b$, and their intersection contributes
$\varphi(1) = 1$ twice. Hence $\sum_{d \in S}\varphi(d) = ab - a - b + 1$. $\square$

The degree is twice the Seifert genus of $T(a,b)$, and $(a-1)(b-1) = ab-a-b+1$ is the
*conductor* of $\langle a,b\rangle$ — a coincidence explained structurally in §5.

**Theorem 2.5 (Number of irreducible factors).** For coprime $a,b \ge 1$,
$$\#S(a,b) \;=\; (\tau(a)-1)(\tau(b)-1),$$
so $\Delta_{a,b}$ is a product of $(\tau(a)-1)(\tau(b)-1)$ distinct irreducible
cyclotomic polynomials.

*Proof sketch.* $\operatorname{Div}(ab) \cong \operatorname{Div}(a) \times
\operatorname{Div}(b)$ by coprimality, so $\tau(ab) = \tau(a)\tau(b)$, and the excluded
set has $\tau(a) + \tau(b) - 1$ elements. Then
$\tau(a)\tau(b) - \tau(a) - \tau(b) + 1 = (\tau(a)-1)(\tau(b)-1)$. $\square$

**Theorem 2.6 (Normalization).** For coprime $a,b$, $\Delta_{a,b}(1) = 1$.

*Proof sketch.* $\Phi_d(1) = \ell$ if $d$ is a power of a prime $\ell$, and
$\Phi_d(1) = 1$ otherwise. No $d \in S(a,b)$ is a prime power: if $d = \ell^k$ divided
$ab$ with $a,b$ coprime, then $\ell$ divides exactly one of $a,b$, say $a$, whence
$\ell^k \mid a$ and $d \mid a$, contradicting $d \in S$. Hence every factor evaluates to
$1$ at $X = 1$. $\square$

This is the classical normalization $\Delta_K(1) = \pm 1$ satisfied by knots, recovered
here from a purely arithmetic statement about prime powers.

### 2.1 The arithmetic pencil $a = 2$

**Proposition 2.7.** For odd $N > 1$, $S(2,N) = \{2d : d \mid N,\ d > 1\}$, so
$$\Delta_{2,N} \;=\; \prod_{\substack{d \mid N\\ d>1}} \Phi_{2d} \;=\; A_N \;=\;
\frac{X^N+1}{X+1}.$$

*Proof sketch.* Divisors of $2N$ are $d$ and $2d$ for $d \mid N$. An odd $d$ divides
$N$, so is excluded; $2d$ divides $2$ only when $d=1$, and never divides the odd $N$.
The identity with $(X^N+1)/(X+1)$ follows from Theorem 2.3 with $a = 2$. $\square$

**Theorem 2.8 (Semiprime degree spectrum).** For distinct odd primes $p,q$ and $N = pq$,
$$A_N \;=\; \Phi_{2p}\Phi_{2q}\Phi_{2pq},$$
and the multiset of degrees of the irreducible factors is $\{p-1,\ q-1,\ (p-1)(q-1)\}$.

*Proof sketch.* The divisors of $N$ exceeding $1$ are $p,q,pq$; apply Proposition 2.7
and $\varphi(2m) = \varphi(m)$ for odd $m$. $\square$

**Corollary 2.9 (Recovery).** With $m = \max\{p-1,q-1,(p-1)(q-1)\} = \varphi(N)$ and
$s = N + 1 - m$, one has $p+q = s$ and
$$p = \frac{s - \sqrt{s^2-4N}}{2}, \qquad q = \frac{s + \sqrt{s^2-4N}}{2}.$$

*Proof sketch.* $\varphi(pq) = (p-1)(q-1) = pq - p - q + 1$, so $s = p+q$; then $p,q$ are
the roots of $Y^2 - sY + N$, and Vieta plus $p<q$ fixes which root is which. $\square$

The same pipeline runs through $T(p,q)$ directly: $\deg \Delta_{p,q} = (p-1)(q-1) =
\varphi(pq)$, so the *degree alone* of the Alexander polynomial of $T(p,q)$ suffices.
Its cost is quantified in §7.

---

## 3. Completeness: the polynomial determines the knot

**Theorem 3.1 (The polynomial knows its spectrum).** For $d \ge 1$,
$$\Phi_d \mid \Delta_{a,b} \quad\Longleftrightarrow\quad d \in S(a,b).$$

*Proof sketch.* ($\Leftarrow$) is immediate from Definition 2.2. For ($\Rightarrow$),
$\Phi_d$ is irreducible, hence prime in the unique factorization domain $\mathbb{Z}[X]$;
so if it divides the product $\prod_{e \in S}\Phi_e$ it divides some factor $\Phi_e$.
Both are monic and irreducible, so $\Phi_d = \Phi_e$, and cyclotomic polynomials of
distinct indices are distinct, giving $d = e \in S(a,b)$. $\square$

**Corollary 3.2.** $\Delta_{a,b} = \Delta_{a',b'} \implies S(a,b) = S(a',b')$.

**Definition 3.3 (Co-spectrum).** $C(a,b) = \operatorname{Div}(ab) \setminus S(a,b)$;
explicitly, $d \in C(a,b)$ iff $d \mid ab$ and ($d \mid a$ or $d \mid b$).

**Theorem 3.4 (Three maxima).** Let $a,b$ be coprime with $1 < a < b$. Then:

1. $\max S(a,b) = ab$;
2. $\max C(a,b) = b$;
3. $\max\{\, d \in C(a,b) : d \nmid b \,\} = a$.

*Proof sketch.* (1) $ab \in S(a,b)$ since $ab \nmid a$ and $ab \nmid b$ for $a,b>1$; and
every element of $S$ divides $ab$, hence is at most $ab$. (2) $b \in C(a,b)$; any
$d \in C$ divides $a$ or $b$, hence $d \le \max(a,b) = b$. (3) $a \in C(a,b)$ and
$a \nmid b$ by coprimality with $a > 1$; conversely any $d \in C$ with $d \nmid b$ must
divide $a$, hence $d \le a$. $\square$

**Theorem 3.5 (Completeness of the invariant).** Let $a,b$ and $a',b'$ be coprime pairs
with $1 < a < b$ and $1 < a' < b'$. If $\Delta_{a,b} = \Delta_{a',b'}$ then $a = a'$ and
$b = b'$.

*Proof sketch.* By Corollary 3.2 the spectra agree; by Theorem 3.4(1) their maxima give
$ab = a'b'$; therefore $\operatorname{Div}(ab) = \operatorname{Div}(a'b')$ and the
co-spectra agree; by 3.4(2), $b = b'$; by 3.4(3) applied to the (now identical) filtered
sets, $a = a'$. $\square$

**Theorem 3.6 (The recovery pipeline).** For coprime $1 < a < b$, the following four
statements hold simultaneously, and constitute an algorithm reading $(a,b)$ off
$\Delta_{a,b}$:
(i) for every $d \ge 1$, $d \in S(a,b) \iff \Phi_d \mid \Delta_{a,b}$;
(ii) $\max S(a,b) = ab$;
(iii) $\max C(a,b) = b$;
(iv) $\max\{d \in C(a,b) : d \nmid b\} = a$.

Note the shape of the algorithm: every step quantifies over $\operatorname{Div}(ab)$.
The recovery is a *divisor-enumeration* procedure; it presupposes the factorization it
appears to produce. This is the first, structural form of the obstruction.

---

## 4. The lattice bridge

Write $A_N = \Delta_{2,N}$ for odd $N$, and $A_N^{\mathbb{Q}}$ for its image in
$\mathbb{Q}[X]$ (monic, so the normalized gcd is unambiguous).

**Theorem 4.1 (Divisibility transfer).** If $d \mid M$ with $d, M$ odd, then
$A_d \mid A_M$ in $\mathbb{Z}[X]$.

*Proof sketch.* By Proposition 2.7 the factor set of $A_d$ is $\{2e : e\mid d, e>1\}
\subseteq \{2e : e \mid M, e > 1\}$. $\square$

**Theorem 4.2 (Euclid on knots).** For odd $M,N$ and $f \in \mathbb{Q}[X]$,
$$f \mid A_M^{\mathbb{Q}} \text{ and } f \mid A_N^{\mathbb{Q}} \iff f \mid A^{\mathbb{Q}}_{\gcd(M,N)}.$$
Consequently
$$\gcd\big(A_M^{\mathbb{Q}},\,A_N^{\mathbb{Q}}\big) \;=\; A^{\mathbb{Q}}_{\gcd(M,N)}.$$

*Proof sketch.* ($\Leftarrow$) is Theorem 4.1 twice. For ($\Rightarrow$), the divisors of
$A_M$ are products of $\Phi_{2d}$ with $d \mid M$, $d>1$; a common divisor uses only
indices $d$ dividing both, i.e. $d \mid \gcd(M,N)$. Equality of the gcds follows from
mutual divisibility and monicity. A Bézout argument in the ring supplies the key step:
an element that is a $(-1)$-th root of unity in the appropriate sense for two odd
exponents $M,N$ is one for $\gcd(M,N)$, since positive natural numbers $s,t$ exist with
$sM - tN = \gcd(M,N)$ and $s,t$ of controlled parity. $\square$

**Corollary 4.3 (Degree readout).** $\deg\gcd(A_M^{\mathbb{Q}},A_N^{\mathbb{Q}}) + 1 =
\gcd(M,N)$.

*Proof sketch.* $\deg A_n = n-1$ for odd $n \ge 1$, and $A_1 = 1$. $\square$

**Corollary 4.4 (Coprimality).** $A_M^{\mathbb{Q}}$ and $A_N^{\mathbb{Q}}$ are coprime in
$\mathbb{Q}[X]$ if and only if $M$ and $N$ are coprime integers.

This is a genuine bridge: Euclid's algorithm on integers is mirrored exactly by
Euclid's algorithm on knot invariants, degrees translating to values. It is also, as
noted in §7, no help for factoring: computing $\gcd(A_M, A_N)$ requires materializing
polynomials of degree $M-1$ and $N-1$.

**Theorem 4.5 (Join defect).** For odd $M,N$ define
$$C_{M,N} \;=\; \prod_{\substack{d \mid \operatorname{lcm}(M,N),\ d>1 \\ d \nmid M,\ d \nmid N}} \Phi_{2d}.$$
Then
$$A_M \cdot A_N \cdot C_{M,N} \;=\; A_{\gcd(M,N)}\cdot A_{\operatorname{lcm}(M,N)},$$
and, in degrees,
$$\deg C_{M,N} + M + N \;=\; \gcd(M,N) + \operatorname{lcm}(M,N).$$
Moreover $C_{M,N} = 1$ if and only if $M \mid N$ or $N \mid M$.

*Proof sketch.* Index sets: $\operatorname{Div}(M)^{>1} \cup \operatorname{Div}(N)^{>1}
\subseteq \operatorname{Div}(\operatorname{lcm})^{>1}$ with intersection
$\operatorname{Div}(\gcd)^{>1}$; inclusion–exclusion on the multiset of cyclotomic
indices yields the identity, with $C_{M,N}$ collecting exactly the indices of
$\operatorname{lcm}$ lying in neither $\operatorname{Div}(M)$ nor $\operatorname{Div}(N)$.
The degree form follows since $\deg A_n = n - 1$ and the four "$-1$"s cancel in pairs.
The defect is trivial iff that index set is empty, i.e. iff every divisor of the lcm
divides $M$ or $N$, which for the lcm of two numbers happens exactly under
comparability. $\square$

**Theorem 4.6 (Squarefreeness).** For $a,b \ge 1$, $\Delta_{a,b}$ is separable, hence
squarefree, over $\mathbb{Q}$. Equivalently, the Alexander module
$\mathbb{Q}[X]/(\Delta_{a,b})$ is a product of *distinct* cyclotomic fields.

*Proof sketch.* $\Delta_{a,b}$ divides $X^{ab}-1$, which is separable over $\mathbb{Q}$
(its derivative $ab\,X^{ab-1}$ shares no root with it), and a divisor of a separable
polynomial is separable. $\square$

---

## 5. The numerical-semigroup dictionary

Fix coprime $a,b > 1$ and write $c = (a-1)(b-1)$ for the conductor. Call
$n \in \mathbb{Z}_{\ge 0}$ *representable* if $n = ai + bj$ for some
$i,j \in \mathbb{Z}_{\ge 0}$, i.e. $n \in \langle a,b\rangle$, and a *gap* otherwise.

**Lemma 5.1 (Conductor).** Every $n \ge c$ is representable, and $c - 1 = ab-a-b$ is a
gap (the Frobenius number).

**Definition 5.2 (Gap polynomial).** $G_{a,b}(X) = \sum_{g \text{ gap}} X^{g}$, a
polynomial of degree $c-1$.

**Theorem 5.3 (Gap generating identity).** For coprime $a,b>1$,
$$\Delta_{a,b}(X) \;=\; 1 - (1-X)\,G_{a,b}(X).$$

*Proof sketch.* Multiply both sides by $X^b - 1$ and use the *cancelled form* of the
defining identity, $\Delta_{a,b}\,(X^{b}-1) = \big(\sum_{i<b} X^{ai}\big)(X-1)$, which is
Theorem 2.3 after cancelling $X^a - 1$ against the geometric factor. The right-hand side
becomes, after the same multiplication, the identity
$(1-X^{b})G_{a,b} = \sum_{k<b}X^{k} - \sum_{i<b}X^{ai}$, which says that in each residue
window of length $b$ the gaps are precisely the non-multiples of $a$ in the Apéry set
— a direct count using the unique representation $n = ai+bj$ with $i < b$. $\square$

**Theorem 5.4 (Coefficient law).** For all $n \ge 0$,
$$[X^n]\,\Delta_{a,b} \;=\; \mathbb{1}\big[n \in \langle a,b\rangle\big] \;-\;
\mathbb{1}\big[n \ge 1 \text{ and } n-1 \in \langle a,b\rangle\big].$$

*Proof sketch.* Extract coefficients in Theorem 5.3, using
$[X^n]G_{a,b} = \mathbb{1}[n \text{ is a gap}]$ and
$[X^n]\big(X\,G_{a,b}\big) = \mathbb{1}[n-1 \text{ is a gap}]$; the four sign cases
collapse to the stated difference of indicators. $\square$

**Corollary 5.5 (Coefficient bound).** Every coefficient of $\Delta_{a,b}$ lies in
$\{-1,0,1\}$.

**Corollary 5.6 (Cheap readout of $\min$).** $[X^{\min(a,b)}]\Delta_{a,b} = 1$, and
$[X^n]\Delta_{a,b} \ne 1$ for $1 \le n < \min(a,b)$.

*Proof sketch.* For $0 < n < \min(a,b)$, $n$ is not representable (any nonzero
representation is at least $\min(a,b)$), so by Theorem 5.4 the coefficient is $0$ for
$n \ge 2$ and $-1$ at $n=1$. At $n=\min(a,b)$ the value $n$ is representable while
$n-1$ is a gap, giving $+1$. $\square$

**Theorem 5.7 (Two-number readout).** For coprime $a,b>1$, let $m$ be the least positive
index with $[X^m]\Delta_{a,b} = 1$ and $D = \deg\Delta_{a,b}$. Then
$$m = \min(a,b), \qquad \frac{D}{m-1}+1 = \max(a,b),$$
so the unordered pair $\{a,b\}$ is recovered from two glances at the polynomial.

*Proof sketch.* Combine Corollary 5.6 with $D = (a-1)(b-1)$ and exact division. $\square$

**Theorem 5.8 (Palindromicity).** For coprime $a,b \ge 1$, $\Delta_{a,b}$ is
palindromic: its reverse equals itself; equivalently
$[X^i]\Delta_{a,b} = [X^{c-i}]\Delta_{a,b}$ for $0 \le i \le c$.

*Proof sketch.* Each $\Phi_d$ with $d \ge 2$ is self-reciprocal (its root set is closed
under $\zeta \mapsto \zeta^{-1}$ and it is monic with constant term $1$), and reversal is
multiplicative on products of polynomials with nonzero constant term. No $d = 1$ occurs
in $S(a,b)$. $\square$

**Theorem 5.9 (Symmetry of $\langle a,b\rangle$, from knot symmetry).** For coprime
$a,b>1$ and $0 \le n < c$,
$$n \in \langle a,b\rangle \quad\Longleftrightarrow\quad c-1-n \notin \langle a,b\rangle.$$

*Proof sketch.* Feed Theorem 5.8 through the coefficient law of Theorem 5.4: the identity
$[X^n]\Delta = [X^{c-n}]\Delta$ becomes a relation among four indicators at $n$, $n-1$,
$c-1-n$ and $c-n$; an induction on $n$, seeded by $n=0$ (where $0$ is representable and
$c-1$ is the Frobenius gap), propagates the equivalence upward. $\square$

Thus the classical *symmetry of the numerical semigroup generated by two coprime
integers* is a consequence of the palindromicity of a knot invariant — the dictionary
transports a topological symmetry to an arithmetic one.

**Theorem 5.10 (Sylvester's genus formula).** For coprime $a,b>1$,
$$2\,\#\mathrm{Gaps}(a,b) \;=\; (a-1)(b-1),$$
i.e. the number of gaps equals the Seifert genus of $T(a,b)$, and the degree of
$\Delta_{a,b}$ is twice the gap count.

*Proof sketch.* The involution $n \mapsto c-1-n$ on $\{0,\dots,c-1\}$ exchanges
representables and gaps by Theorem 5.9, so the two classes partition a set of size $c$
into equinumerous halves. $\square$

---

## 6. The support law

**Definition 6.1 (Jumps).** For coprime $a,b>1$ set
$$U(a,b) = \{\,1 \le n \le c : n \in \langle a,b\rangle,\ n-1 \notin \langle a,b\rangle\,\}, \qquad
D(a,b) = \{\,1 \le n \le c : n \notin \langle a,b\rangle,\ n-1 \in \langle a,b\rangle\,\}.$$
Elements of $U$ are entries into the semigroup; elements of $D$ are exits, i.e. the
starting points of maximal runs of consecutive gaps. Write $\beta(a,b) = \#D(a,b)$.

**Lemma 6.2 (Balance).** $\#U(a,b) = \#D(a,b)$.

*Proof sketch.* By Theorem 5.4 the coefficient of $\Delta_{a,b}$ is $+1$ on $U$, $-1$ on
$D$, and $0$ at every other positive index; the constant term is $1$. Summing all
coefficients gives $\Delta_{a,b}(1) = 1$ (Theorem 2.6), hence
$1 + \#U - \#D = 1$. $\square$

**Theorem 6.3 (Support description).**
$$\operatorname{supp}\Delta_{a,b} \;=\; \{0\} \,\cup\, U(a,b) \,\cup\, D(a,b),$$
a disjoint union.

**Theorem 6.4 (Support law).** For coprime $a,b > 1$,
$$\#\operatorname{supp}\Delta_{a,b} \;=\; 2\,\beta(a,b) + 1,$$
where $\beta(a,b)$ is the number of maximal runs of gaps of $\langle a,b\rangle$.

*Proof sketch.* Combine Theorem 6.3, Lemma 6.2, and disjointness. $\square$

**Lemma 6.5 (Runs are short).** No run of consecutive gaps has length $\ge a$: among any
$a$ consecutive nonnegative integers one is a multiple of $a$, hence representable.
Consequently $\#\mathrm{Gaps}(a,b) \le \beta(a,b)\,(a-1)$.

*Proof sketch.* Map each gap $g$ to the pair $(\mathrm{start}(g),\, g - \mathrm{start}(g))$
where $\mathrm{start}(g)$ is the first element of $g$'s run. This is injective into
$D(a,b) \times \{0,\dots,a-2\}$, since a run has length at most $a-1$. $\square$

**Theorem 6.6 (Run-count bound).** For coprime $a,b>1$, $\ 2\beta(a,b) \ge b-1$.

*Proof sketch.* Sylvester (Theorem 5.10) gives $2\#\mathrm{Gaps} = (a-1)(b-1)$; Lemma 6.5
gives $\#\mathrm{Gaps} \le \beta(a-1)$. Hence $(a-1)(b-1) \le 2\beta(a-1)$ and cancel
$a-1 > 0$. $\square$

**Theorem 6.7 (Support lower bound).** For coprime $a,b>1$,
$$\#\operatorname{supp}\Delta_{a,b} \;\ge\; \max(a,b).$$

*Proof sketch.* By Theorems 6.4 and 6.6, $\#\operatorname{supp} = 2\beta+1 \ge b$; the
invariant is symmetric in $a$ and $b$ (the spectrum is), so also $\ge a$. $\square$

**Theorem 6.8 (Sharpness on the arithmetic pencil).** For odd $N > 1$,
$$\#\operatorname{supp} A_N \;=\; N, \qquad \beta(2,N) = \frac{N-1}{2}.$$

*Proof sketch.* For $a = 2$, Lemma 6.5 says runs have length at most $1$, so each gap is
its own run: $\beta = \#\mathrm{Gaps}$. Sylvester then gives $\beta = (N-1)/2$, and the
support law yields $N$. (Directly: $A_N$ has $N$ coefficients, all $\pm 1$.) $\square$

**Theorem 6.9 (Staircase family).** For $a > 1$, the semigroup $\langle a, a+1\rangle$
has exactly $a-1$ maximal gap runs, and
$$\#\operatorname{supp}\Delta_{a,a+1} \;=\; 2a-1 \;=\; a + (a+1) - 2.$$
For $a \ge 3$ this strictly exceeds $\max(a,a+1) = a+1$, so the bound of Theorem 6.7 is
not tight in general.

*Proof sketch.* Membership test: $n \in \langle a,a+1\rangle \iff n \bmod a \le
\lfloor n/a \rfloor$. The exits are therefore exactly the numbers $k(a+1)+1$ for
$0 \le k < a-1$, giving $\beta = a-1$; apply Theorem 6.4. $\square$

Both families for which a closed formula is available realize the value $a+b-2$
(for $T(2,N)$: $2+N-2 = N$; for $T(a,a+1)$: $2a-1$). This coincidence does **not**
persist: for $T(5,7)$ one computes $\beta(5,7) = 8$ and hence
$\#\operatorname{supp}\Delta_{5,7} = 17$, while $a+b-2 = 10$. The support count is
governed by the run structure of $\langle a,b\rangle$, which is genuinely finer than
$a+b$; the two families above are exactly the cases where the runs degenerate (length
$1$ everywhere for $a=2$; a single arithmetic progression of run starts for
$b = a+1$).

---

## 7. Obstructions: why the bridge does not compute

### 7.1 Exponential materialization cost

**Theorem 7.1.** Writing down $\Delta_{a,b}$ requires at least $\max(a,b)$ nonzero
coefficients (Theorem 6.7), and $\deg \Delta_{a,b} = (a-1)(b-1)$. For the arithmetic
pencil, $\#\operatorname{supp} A_N = N \ge 2^{\lfloor \log_2 N\rfloor}$.

Since the knot $T(a,b)$ is specified by $O(\log ab)$ bits, the invariant is exponentially
large in the input. No representation trick evades the bound: it counts nonzero
coefficients, an invariant of the polynomial, not of a chosen encoding of it. (A
succinct *implicit* representation such as the closed rational form is of course
available — but from that form the factor degrees are exactly what is not visible.)

**Theorem 7.2 (Pipeline cost through $T(p,q)$).** For odd primes $2 < p < q$,
$$2\deg\Delta_{p,q} + 1 \;\ge\; pq,$$
i.e. the polynomial whose degree carries the answer has degree at least $(N-1)/2$.

*Proof sketch.* $\deg \Delta_{p,q} = (p-1)(q-1) = \varphi(pq)$, and
$2(p-1)(q-1)+1 \ge pq$ whenever $p \ge 3$, by expanding
$2(p-1)(q-1) - pq + 1 = pq - 2p - 2q + 3 \ge 0$ for $p \ge 3, q \ge 4$. $\square$

### 7.2 The determinant collapses

The *determinant* of a knot is $|\Delta_K(-1)|$, a single integer computable from a
Seifert or Goeritz matrix without materializing the polynomial. If it ever produced a
nontrivial divisor of $N$, the exponential barrier would be irrelevant. It does not.

**Lemma 7.3.** For odd $n>1$, $\Phi_n(-1) = 1$.

**Theorem 7.4 (Determinant trichotomy).** For coprime $a,b \ge 1$:
$$\Delta_{a,b}(-1) \;=\; \begin{cases} 1, & a,b \text{ both odd},\\
a, & b \text{ even},\\ b, & a \text{ even}.\end{cases}$$
In particular the value is always one of $1$, $a$, $b$.

*Proof sketch.* If both are odd, every $d \in S(a,b)$ is odd (a divisor of the odd $ab$)
and $>1$, so each factor contributes $1$ by Lemma 7.3. If $b$ is even and $a$ odd, use
the cancelled identity $\Delta_{a,b}(X^{a}-1) = \big(\sum_{i<a}X^{bi}\big)(X-1)$
evaluated at $X=-1$: the left side is $\Delta_{a,b}\cdot(-2)$ and the right side is
$a \cdot (-2)$ because $(-1)^{bi} = 1$ for even $b$. $\square$

**Corollary 7.5 (No new factor).** For coprime $a,b>1$, the determinant of $T(a,b)$ is
one of $1, a, b$ — never a divisor of $ab$ other than a given parameter. In particular
$\det T(2,N) = N$ (the input) and $\det T(p,q) = 1$ (no information).

### 7.3 The cheap readout is uninformative

Theorem 5.7 provides an $O(1)$-glance readout of $\{a,b\}$. Specialized to the pencil it
returns $m = 2$ and $D/(m-1)+1 = N$: exactly the input parameters. The information one
can obtain cheaply is precisely the information one already had. Everything beyond it —
the interior factor degrees — requires the divisor enumeration of §3.

### 7.4 Symmetry of the degree data

Even granted the multiset $\{p-1, q-1, (p-1)(q-1)\}$, the data is symmetric in $p$ and
$q$: the recovery of Corollary 2.9 must go through the quadratic $Y^2-sY+N$, and no step
distinguishes the two primes before the square root is taken. There is no route by which
partial information about the spectrum leaks one prime without the other.

### 7.5 Summary of the barrier

| Route | Cost / outcome | Obstruction |
|---|---|---|
| Write $A_N$, factor it | $\ge N$ nonzero coefficients | Theorem 6.7/6.8 |
| Degree of $\Delta_{p,q}$ | $\varphi(N) \ge (N-1)/2$ | Theorem 7.2 |
| Determinant $\Delta(-1)$ | $1$, $a$ or $b$ | Theorem 7.4 |
| Cheap coefficient readout | returns $\{2,N\}$ | Theorem 5.7 |
| Spectrum maxima | enumerates $\operatorname{Div}(N)$ | Theorem 3.6 |
| Knot gcd | needs $A_M$, $A_N$ explicitly | Theorem 4.2 |

Every route is closed, and closed by a theorem rather than by absence of ingenuity in a
particular attempt. This is what makes the object interesting: it is a fully faithful
encoding of the factorization with a *proved* inaccessibility layer.

---

## 8. Algorithms

Three procedures are worth isolating, with honest complexity statements. Throughout,
$N$ denotes the integer of interest and $L = \log_2 N$ its bit length.

**Algorithm A (Spectrum construction).** Given coprime $a,b$, output $S(a,b)$ and hence
the cyclotomic factorization of $\Delta_{a,b}$. Enumerate $\operatorname{Div}(ab)$
(requires the factorization of $ab$), keep $d$ with $d\nmid a$, $d\nmid b$. Cost:
$O(\tau(ab))$ after factoring; the degrees are then $\varphi(d)$.

**Algorithm B (Coefficient evaluation by semigroup membership).** Given coprime $a,b>1$
and $n \le (a-1)(b-1)$, compute $[X^n]\Delta_{a,b}$ in $O(\min(a,b))$ arithmetic
operations: test representability of $n$ and $n-1$ by scanning $j$ with $bj \le n$ and
checking $a \mid (n-bj)$, then apply the coefficient law. This produces individual
coefficients cheaply; producing all of them is what costs $\Omega(\max(a,b))$.

**Algorithm C (Semiprime recovery from the degree spectrum).** Given the multiset of
irreducible factor degrees $\{p-1,q-1,(p-1)(q-1)\}$ of $A_N$, set $m$ to be the maximum,
$s = N+1-m$, $\delta = \sqrt{s^2-4N}$, and output $((s-\delta)/2, (s+\delta)/2)$. Cost:
$O(1)$ arithmetic operations on $L$-bit integers — the *only* cheap step in the chain,
and the one whose input is the expensive object.

---

## 9. Applications and interpretation

**As a case study in representation.** The pair (information present, information
accessible) is the central distinction in computational complexity, and this object
exhibits it in a form where both halves are theorems. The Alexander polynomial of
$T(2,N)$ *determines* the factorization of $N$ and *is determined by* it, yet every
computationally cheap functional of the polynomial that we can identify — determinant,
value at $1$, low-order coefficients, degree — is provably a function of $N$ alone.

**As a transport of theorems.** The dictionary of §5 is a two-way street with real
traffic:

- Knot $\to$ arithmetic: palindromicity of the Alexander polynomial gives symmetry of
  $\langle a,b\rangle$ (Theorem 5.9);
- Arithmetic $\to$ knot: Sylvester's gap count gives $\deg \Delta_{a,b} = 2g$ with $g$
  the Seifert genus (Theorem 5.10);
- Combinatorics $\to$ complexity: the run structure of gaps gives the exact support count
  and hence the materialization cost (Theorems 6.4, 6.7).

**As a source of sparse-polynomial data.** The polynomials $\Delta_{a,b}$ are extremal
objects: degree $(a-1)(b-1)$, coefficients in $\{0,\pm1\}$, support $2\beta+1$, all
irreducible factors cyclotomic. They form a natural test family for sparse-polynomial
factorization algorithms, where the answer is known in closed form and the sparsity
varies from $\Theta(\max(a,b))$ up to substantially more.

**Comparison with the Jones polynomial.** The Jones polynomial of $T(a,b)$ (for odd $a$)
satisfies
$$(1-X^2)\,J_{a,b}(X) \;=\; 1 - X^{a+1} - X^{b+1} + X^{a+b},$$
with $J_{a,b}(1) = 1$, $J_{a,b} = J_{b,a}$ and $\deg J_{a,b} = a+b-2$. Combining with
$\deg\Delta_{a,b} = (a-1)(b-1)$ gives a *knot-theoretic Vieta*:
$$a+b = \deg J_{a,b} + 2, \qquad ab = \deg \Delta_{a,b} + \deg J_{a,b} + 1,$$
so the two degrees are equivalent data to the elementary symmetric functions of $a$ and
$b$, hence determine $\{a,b\}$ as the roots of $Y^2 - (a+b)Y + ab$. Note that the
Jones numerator has only four terms, but $J_{a,b}$ itself is not sparse: e.g.
$J_{5,7} = 1 + X^2 + X^4 - X^8 - X^{10}$, and the count grows linearly in $\min(a,b)$.
The four-term object is the numerator, not the invariant.

---

## 10. Discussion and future work

Fifteen strands of development converge on a single object. The results now established
are: the cyclotomic spectrum description of $\Delta_{a,b}$ with degree, factor count and
normalization; the $\gcd$ law with degree readout; completeness of the invariant on
torus knots; irreducibility of $\Delta_{a,b}$ exactly when both parameters are prime,
with the $T(p,q)$ pipeline and its cost; palindromicity; the join defect and
squarefreeness; cyclotomic reciprocity; the full determinant law; the semigroup
dictionary with symmetry and Sylvester's formula; the cheap two-number readout; the
support law with its lower bound and the exact values on the pencil and the staircase.

Open directions in the same circle of ideas:

1. **The exact support count in general.** The closed formulas above cover the pencil
   $T(2,N)$ and the staircase $T(a,a+1)$; the example $\beta(5,7)=8$ shows that no
   formula linear in $a+b$ can hold in general. What is the exact value of $\beta(a,b)$,
   i.e. the number of maximal gap runs of $\langle a,b\rangle$, as an arithmetic function
   of the pair? A closed form would upgrade the bound
   $\#\operatorname{supp}\Delta_{a,b}\ge\max(a,b)$ to an identity.
2. **Beyond two generators.** Torus *links* and iterated torus knots (cables) have
   Alexander polynomials that are again cyclotomic products, and their spectra encode
   several parameters at once; the semigroup on the other side becomes
   $\langle a_1,\dots,a_k\rangle$, where Sylvester's formula fails and the gap structure
   is genuinely harder. What is the correct support law there?
3. **Other invariants under the same lens.** Which knot invariants of $T(a,b)$ are
   provably functions of $\min(a,b)$ and $\max(a,b)$ alone, evaluable in
   $\operatorname{poly}(\log ab)$ time? A classification would delineate exactly the
   accessible boundary of the encoding.
4. **Quantitative sparsity for general cyclotomic products.** The support law is special
   to products over a divisor spectrum. For an arbitrary squarefree product of
   cyclotomics, how does the support size depend on the index set?
5. **The lattice structure.** The join defect measures the failure of $N \mapsto A_N$ to
   be a lattice homomorphism, with degree $\gcd + \operatorname{lcm} - M - N$. Is there a
   knot-theoretic operation on $T(2,M)$ and $T(2,N)$ realizing the defect polynomial as
   an invariant of a third knot or link?

---

## Appendix A. Worked example: $N = 143$

$N = 143 = 11 \cdot 13$. Divisors greater than $1$: $11, 13, 143$. Hence
$$A_{143} \;=\; \Phi_{22}\,\Phi_{26}\,\Phi_{286},$$
with degrees $\varphi(22) = 10$, $\varphi(26) = 12$, $\varphi(286) = 120$; total
$142 = 143-1$ as required. Then $m = 120 = \varphi(143)$, $s = 143+1-120 = 24$,
$s^2-4N = 576-572 = 4$, $\sqrt{4} = 2$, and $\{p,q\} = \{(24-2)/2, (24+2)/2\} =
\{11,13\}$.

Consistency checks: $A_{143}(1) = 1$; $A_{143}(-1) = 143$ (determinant trichotomy with
$a=2$ even, odd parameter $143$); $\#\operatorname{supp}A_{143} = 143$;
$\deg\Delta_{11,13} = 120 = \varphi(143)$, and $\Delta_{11,13} = \Phi_{143}$ is
irreducible, reflecting that both parameters are prime.

## Appendix B. Worked example: the semigroup dictionary for $T(5,7)$

$\langle 5,7\rangle$ has conductor $c = 4\cdot 6 = 24$ and gaps
$$1,2,3,4,6,8,9,11,13,16,18,23,$$
twelve of them, confirming $2\cdot 12 = 24 = (5-1)(7-1)$. Symmetry: $n \leftrightarrow
23-n$ exchanges gaps and non-gaps, e.g. $0 \leftrightarrow 23$, $5 \leftrightarrow 18$,
$7\leftrightarrow 16$. Maximal gap runs: $\{1,2,3,4\}, \{6\}, \{8,9\}, \{11\}, \{13\},
\{16\}, \{18\}, \{23\}$, so $\beta = 8$ and the support law predicts
$\#\operatorname{supp}\Delta_{5,7} = 17$. Applying the coefficient law index by index:
$$\Delta_{5,7} = 1 - X + X^5 - X^6 + X^{7} - X^{8} + X^{10} - X^{11} + X^{12} - X^{13}
+ X^{14} - X^{16} + X^{17} - X^{18} + X^{19} - X^{23} + X^{24},$$
exactly $17$ nonzero coefficients, all $\pm 1$, palindromic of degree $24$. Consistency:
$\Delta_{5,7}(1) = 1$; $\Delta_{5,7}(-1) = 1$ since both parameters are odd; the least
positive index with coefficient $+1$ is $5 = \min(5,7)$, and
$24/(5-1) + 1 = 7 = \max(5,7)$; the spectrum is
$S(5,7) = \{35\}$, so $\Delta_{5,7} = \Phi_{35}$ is irreducible of degree
$\varphi(35) = 24$, as it must be since $5$ and $7$ are both prime. The lower bound
$17 \ge \max(5,7)$ holds with a large margin.
