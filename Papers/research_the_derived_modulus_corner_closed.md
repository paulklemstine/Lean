# The Derived-Modulus Corner, Closed: An Exact Classification of Polynomial Moduli That Cannot See a Factorization

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

Let $N = pq$ be a semiprime. A *derived modulus* is an integer $M = f(N)$
obtained by evaluating a fixed integer polynomial $f$ at $N$; the canonical
examples are $N \pm 1$, $N^2 + 1$, the third cyclotomic value
$\Phi_3(N) = N^2+N+1$, and $2N \pm 1$. We ask whether arithmetic invariants of
$M$ can carry information about the factorization of $N$ that is not already a
function of $N$. We prove that they cannot, and we determine the exact boundary
of the obstruction.

The central identity is $N \mid f(N) - f(0)$, from which
$\gcd(N, f(N)) = \gcd(N, f(0))$: the overlap between a number and its polynomial
derived modulus is *frozen at the constant term*, uniformly in $N$. Calling $f$
**transparent** when $f(0) = \pm 1$, we prove an exact classification:
$\gcd(N, f(N)) = 1$ for every integer $N$ **if and only if** $f$ is transparent,
with an explicit witness $N$ whenever transparency fails. We show that
transparent polynomials form a multiplicative monoid stable under precomposition
with any constant-term-free polynomial, so that the entire multiplicative and
substitutional closure of a transparent family remains invisible to $N$: no
product, iterate, or substitution escapes.

Three further layers sharpen the picture. (i) A *resultant law*: for integer
polynomials $f, g$ not both constant, $\gcd(f(N), g(N)) \mid \mathrm{Res}(f,g)$
for all $N$, so a finite family of derived moduli carries only $O(1)$ common
arithmetic uniformly in $N$. (ii) A *spectrum theorem*: the set of primes that
can ever divide $N^2+1$ is exactly $\{2\} \cup \{p \equiv 1 \bmod 4\}$, and for
$\Phi_3$ exactly $\{3\} \cup \{p \equiv 1 \bmod 3\}$ — fixed sets of split
primes of $\mathbb{Q}(i)$ and $\mathbb{Q}(\zeta_3)$, independent of $N$; in
particular the prime factors of a Blum integer are excluded by congruence from
ever appearing in $N^2+1$. (iii) A *freshness theorem*: the prime support of a
transparent derived modulus family is infinite, yet no prime in it divides the
corresponding $N$ — factoring the derived modulus is a fresh, unbounded problem
whose answer is guaranteed irrelevant.

Finally we identify the exact frontier. All proofs use only the property
$a - b \mid F(a) - F(b)$ (*congruence transport*); the transporting maps form a
subring of $\mathbb{Z}^{\mathbb{Z}}$ closed under composition, and the barrier
and its classification hold verbatim there. Outside the class the barrier
provably fails: the exponential modulus $F(N) = 2^N - 1$ does not transport
congruences, satisfies $\gcd(N, 2^N-1) > 1$ for infinitely many $N$, and indeed
$\gcd(253, 2^{253}-1) = 23$ with $253 = 11 \cdot 23$ — a complete factorization.
The only remaining route is an external hint sharing a prime with $N$; we show
exactly $p+q-1$ of the $pq$ residues are useful, a density of at most $2/B$ when
both factors exceed $B$.

**Keywords:** derived modulus, semiprime, resultant, cyclotomic polynomial,
split primes, congruence transport, no-go theorem, superselection.

---

## 1. Introduction

### 1.1 The question

Fix a semiprime $N = pq$ with $p, q$ distinct odd primes. All information about
$p$ and $q$ is contained in $N$, but is computationally inaccessible. A
recurring idea in the search for structural attacks is to *change the modulus*:
instead of studying $N$, study a nearby integer built from $N$, hoping that the
new integer's arithmetic is more forthcoming.

Formally, fix $f \in \mathbb{Z}[X]$ and set
$$M = f(N).$$
We call $M$ a **derived modulus** and $f$ its **generating polynomial**. The
family under investigation, motivated by both classical constructions
($p \pm 1$ methods, cyclotomic polynomials) and by naive intuition, is

$$\mathcal{F} = \{\, X-1,\ X+1,\ X^2+1,\ X^2+X+1,\ 2X-1,\ 2X+1 \,\}.$$

For each $f \in \mathcal{F}$ one computes an arithmetic invariant $C(M)$ — least
prime factor, number of prime factors with or without multiplicity, a class
number, a Jacobi-symbol statistic — and asks whether $C(f(N))$ carries
information about $(p, q)$ beyond what $N$ already determines.

### 1.2 The confound, and the honest coordinate

An empirical study must be careful about a specific trap. For balanced
semiprimes, $p \approx q \approx \sqrt N$; therefore any statistic that tracks
the magnitude of $N$ will *appear* correlated with $p$ and with $p+q$ across a
batch of $N$ of varying size. This is a confound, not a signal.

The factorization-specific coordinate is the **gap** $|p - q|$, which varies
within the fiber of semiprimes of a given size. A genuine factor signal must
move with $|p-q|$ at fixed $N$-scale.

Empirically it does not. Across the tested batches, invariants $C(M)$ correlated
with $N$ at levels $0.66$–$0.95$, while their correlation with $|p-q|$ remained
inside the permutation null at every setting examined: in a residual control
with $n = 40$, the observed correlations were at most $0.26$ against a $95$th
null percentile of $0.29$–$0.31$. Additionally, several invariants were found to
be *degenerate*: $N \pm 1$ is always even for odd $N$, so the least-prime-factor
invariant equals $2$ identically.

This paper proves that all of these observations are forced.

### 1.3 The physical framing

The framing that organizes the results is a **superselection rule**. Read $N$ as
the *state* of a system and $f$ as an *apparatus* producing an observable
$f(N)$. Because $f$ respects congruences, the observable lies in the algebra
generated by $N$, and therefore cannot resolve the internal degeneracy of the
state — the *factorization fiber*, the set of semiprimes with the same value of
$N$-derived data. The spectrum theorem of §5 makes this precise in the strongest
form: the set of eigenvalues (primes) available to the observable is a property
of the apparatus $f$ alone.

### 1.4 Contributions

1. **Frozen overlap** (§3): $\gcd(N, f(N)) = \gcd(N, f(0))$ for all $f, N$.
2. **Exact classification** (§3): universal coprimality holds iff $f(0) = \pm 1$,
   with explicit witnesses in the failure case.
3. **Closure** (§4): transparency is a submonoid, stable under substitution;
   the full closure of $\mathcal{F}$ is invisible to $N$.
4. **Resultant law** (§4): $\gcd(f(N), g(N)) \mid \mathrm{Res}(f,g)$, hence
   uniform $O(1)$ multi-modulus overlap.
5. **Spectrum theorem** (§5): exact, $N$-independent prime spectra for the
   quadratic moduli; congruence exclusion for Blum integers.
6. **Freshness** (§6): infinite prime support, but never a factor of $N$.
7. **Congruence transport and its boundary** (§7): the natural generality of the
   barrier, and a proof that $2^N-1$ is outside it and leaks.
8. **The hint frontier** (§8): exact count $p+q-1$ and density bound $2/B$.

---

## 2. Definitions and conventions

Throughout, $\mathbb{Z}[X]$ denotes the ring of integer polynomials, and for
$f \in \mathbb{Z}[X]$ and $N \in \mathbb{Z}$ we write $f(N)$ for the evaluation.
$\gcd$ of integers is taken to be a non-negative integer, with $\gcd(a,b)=0$ iff
$a=b=0$.

**Definition 2.1 (Derived modulus).** For $f \in \mathbb{Z}[X]$ and
$N \in \mathbb{Z}$, the *derived modulus* is $M = f(N)$.

**Definition 2.2 (The tested family).** $\mathcal{F}$ is the six-element family
$f_0 = X-1$, $f_1 = X+1$, $f_2 = X^2+1$, $f_3 = X^2+X+1 = \Phi_3(X)$,
$f_4 = 2X-1$, $f_5 = 2X+1$.

**Definition 2.3 (Transparency).** $f \in \mathbb{Z}[X]$ is *transparent* if
$f(0) = 1$ or $f(0) = -1$; equivalently $|f(0)| = 1$.

**Definition 2.4 (Congruence transport).** A map $F : \mathbb{Z} \to \mathbb{Z}$
*transports congruences* if $(a - b) \mid (F(a) - F(b))$ for all $a, b$;
equivalently $a \equiv b \pmod m \Rightarrow F(a) \equiv F(b) \pmod m$ for all
$m$.

**Definition 2.5 (Prime support / spectrum).** For $f \in \mathbb{Z}[X]$,
$$S_f = \{\, p \text{ prime} : \exists N \in \mathbb{Z},\ p \mid f(N) \,\}.$$

**Definition 2.6 (Useful hint).** Given $N = pq$, an integer $h$ is a *useful
hint* if $\gcd(N, h) \notin \{1, N\}$, i.e. the gcd attack returns a proper
nontrivial divisor.

---

## 3. The frozen overlap and the classification

### 3.1 The mechanism

**Lemma 3.1 (Difference divisibility).** For every $f \in \mathbb{Z}[X]$ and all
$a, b \in \mathbb{Z}$, $(a - b) \mid (f(a) - f(b))$. In particular
$N \mid f(N) - f(0)$.

*Proof.* Write $f = \sum_k c_k X^k$. Then
$f(a) - f(b) = \sum_k c_k (a^k - b^k)$, and
$a^k - b^k = (a-b)\sum_{j<k} a^j b^{k-1-j}$ for each $k \geq 1$; the $k=0$ terms
cancel. $\square$

**Theorem 3.2 (Frozen overlap).** For every $f \in \mathbb{Z}[X]$ and every
$N \in \mathbb{Z}$,
$$\gcd\bigl(N, f(N)\bigr) = \gcd\bigl(N, f(0)\bigr).$$

*Proof sketch.* Let $d = \gcd(N, f(N))$. Then $d \mid N$, hence by Lemma 3.1
$d \mid f(N) - f(0)$; combined with $d \mid f(N)$ this gives $d \mid f(0)$, so
$d \mid \gcd(N, f(0))$. Symmetrically, $\gcd(N, f(0))$ divides $N$ and hence
$f(N)-f(0)$, therefore divides $f(N)$, therefore divides $d$. Two-sided
divisibility of non-negative integers gives equality. $\square$

Theorem 3.2 is the whole no-go in embryonic form: the arithmetic shared between
$N$ and its derived modulus does not depend on $N$ at all beyond the value
$f(0)$. It is a *constant of the apparatus*.

**Corollary 3.3 (Uniform bound).** $\gcd(N, f(N)) \mid |f(0)|$ for all $N$.

**Corollary 3.4 (Common-divisor transfer).** If $d \mid N$ and $d \mid f(N)$
then $d \mid f(0)$.

**Theorem 3.5 (Barrier 1/5: finitely many shared primes).** If $f(0) \neq 0$,
the set
$$\{\, p \text{ prime} : \exists N,\ p \mid N \text{ and } p \mid f(N) \,\}$$
is finite; indeed it is contained in the set of prime divisors of $f(0)$.

*Proof.* Immediate from Corollary 3.4 and the finiteness of the divisor set of a
nonzero integer. $\square$

### 3.2 The classification

**Theorem 3.6 (Classification of transparent moduli).** For $f \in \mathbb{Z}[X]$,
$$\bigl(\forall N \in \mathbb{Z},\ \gcd(N, f(N)) = 1\bigr) \iff f(0) = \pm 1 .$$

*Proof sketch.* ($\Leftarrow$) By Corollary 3.3 the gcd divides $|f(0)| = 1$.

($\Rightarrow$) Contrapositive. Suppose $|f(0)| \neq 1$.
*Case $f(0) = 0$*: take $N = 2$. Lemma 3.1 gives $2 \mid f(2) - f(0) = f(2)$, so
$2 \mid \gcd(2, f(2))$ and the gcd exceeds $1$.
*Case $|f(0)| \geq 2$*: let $r$ be the least prime factor of $|f(0)|$ and take
$N = r$. Then $r \mid f(r) - f(0)$ by Lemma 3.1 and $r \mid f(0)$ by choice, so
$r \mid f(r)$; hence $r \mid \gcd(r, f(r))$, which is therefore $> 1$. $\square$

Two features deserve emphasis. First, this is a genuine *classification*: the
barrier is not a sufficient condition dressed as an obstruction, but an exact
characterization of the invisible class. Second, when transparency fails, the
witnesses are the finitely many $N$ divisible by a prime factor of $f(0)$ — a
list computable from $f$ alone, entirely independent of any factorization of
$N$. Even the leaks are uninformative.

### 3.3 The tested family

**Proposition 3.7.** Every $f \in \mathcal{F}$ satisfies $f(0) = \pm 1$, hence
$\gcd(N, f(N)) = 1$ for every integer $N$.

Explicit Bézout certificates make this effective and certificate-checkable:
$$1\cdot N + (-1)(N-1) = 1, \quad (-1)N + 1\cdot(N+1) = 1,$$
$$(-N)N + 1\cdot(N^2+1) = 1, \quad (-N-1)N + 1\cdot(N^2+N+1) = 1,$$
$$2N + (-1)(2N-1) = 1, \quad (-2)N + 1\cdot(2N+1) = 1.$$

**Corollary 3.8 (Headline no-go).** If $p$ is prime, $f$ transparent, and
$p \mid N$, then $p \nmid f(N)$. In particular for $N = pq$ neither prime factor
divides any derived modulus of $\mathcal{F}$, so no divisibility-based invariant
of $f(N)$ can expose $p$ or $q$.

### 3.4 Degeneracy of the empirical invariants

The experiment's observation that several invariants are constants is also a
theorem.

**Proposition 3.9.** Let $N$ be odd, $N \geq 3$. Then:
(i) $\mathrm{lpf}(N+1) = \mathrm{lpf}(N-1) = 2$;
(ii) $N^2 + 1 \equiv 2 \pmod 8$, hence $\mathrm{lpf}(N^2+1) = 2$ and
$v_2(N^2+1) = 1$ exactly.

*Proof.* (i) $N \pm 1$ is even and $\geq 2$. (ii) Write $N = 2k+1$; then
$N^2+1 = 4k(k+1) + 2$, and $k(k+1)$ is even, so $N^2+1 \equiv 2 \bmod 8$.
$\square$

Three of the six candidate invariants are therefore *identically constant* on
the class of odd inputs and carry zero bits. Any nonzero measured correlation
for them is a measurement artifact.

### 3.5 Coarse-graining

**Theorem 3.10 (Congruence transport for polynomials).** If
$N \equiv N' \pmod m$ then $f(N) \equiv f(N') \pmod m$, for every
$f \in \mathbb{Z}[X]$ and every modulus $m$.

*Proof.* $m \mid N - N' \mid f(N) - f(N')$ by Lemma 3.1. $\square$

Consequently every residue-type invariant of a derived modulus is a function of
a residue of $N$: it *coarse-grains* $N$ and never refines it. Two semiprimes in
the same residue class modulo $m$ produce derived moduli in the same residue
class modulo $m$, simultaneously for all six members of $\mathcal{F}$. This is
the exact arithmetic content of the empirical finding that $C(M)$ is a function
of $N$ and that its apparent dependence on $p$ and $p+q$ is the $N$-confound.

---

## 4. Closure: no combination escapes

A natural objection to §3 is that the six moduli were examined individually. We
close that loophole in two independent ways: by algebraic closure of the
transparent class, and by a uniform resultant bound on multi-modulus
interactions.

### 4.1 The transparent monoid

**Proposition 4.1.** $1$ is transparent, and if $f, g$ are transparent so is
$fg$, since $(fg)(0) = f(0)g(0) \in \{1, -1\}$. Hence the transparent
polynomials form a submonoid of $(\mathbb{Z}[X], \cdot)$. By induction, the
product of any finite list of transparent polynomials is transparent.

**Proposition 4.2 (Substitution stability).** If $f$ is transparent and
$g \in \mathbb{Z}[X]$ has $g(0) = 0$, then $f \circ g$ is transparent, since
$(f \circ g)(0) = f(g(0)) = f(0)$.

Substitutions of the form $N \mapsto 2N$, $N \mapsto N^k$, $N \mapsto N^2 + N$
all satisfy $g(0) = 0$.

**Proposition 4.3 (Composition law).** For any $f, g \in \mathbb{Z}[X]$ and any
$N$,
$$\gcd\bigl(N,\ f(g(N))\bigr) = \gcd\bigl(N,\ f(g(0))\bigr).$$

*Proof.* Apply Theorem 3.2 to the polynomial $f \circ g$ and evaluate its
constant term. $\square$

**Theorem 4.4 (The corner is closed).** Let $L$ be any finite list of members of
$\mathcal{F}$ (repetitions allowed), let $P = \prod_{f \in L} f$, and let
$g \in \mathbb{Z}[X]$ with $g(0) = 0$. Then
$$\gcd\bigl(N,\ (P \circ g)(N)\bigr) = 1 \quad \text{for every } N \in \mathbb{Z}.$$

*Proof.* Each member of $\mathcal{F}$ is transparent (Prop. 3.7); $P$ is
transparent by Prop. 4.1; $P \circ g$ is transparent by Prop. 4.2; apply Theorem
3.6. $\square$

**Corollary 4.5 (Full product).** For every integer $N$,
$$\gcd\Bigl(N,\ (N-1)(N+1)(N^2+1)(N^2+N+1)(2N-1)(2N+1)\Bigr) = 1 .$$

No product of the tested moduli, and no iterate such as $(2N)^2+1$, can expose a
factor of $N$.

### 4.2 The resultant law

Products are one form of multi-modulus attack; *cross-talk* between two moduli is
another. The resultant $\mathrm{Res}(f,g)$ — the determinant of the Sylvester
matrix — controls it exactly.

**Theorem 4.6 (Resultant law).** Let $f, g \in \mathbb{Z}[X]$ with
$\deg f \neq 0$ or $\deg g \neq 0$. Then for every $N \in \mathbb{Z}$,
$$\gcd\bigl(f(N),\ g(N)\bigr) \ \big|\ \mathrm{Res}(f,g).$$

*Proof sketch.* The Sylvester–Bézout identity supplies $u, v \in \mathbb{Z}[X]$
with $u f + v g = \mathrm{Res}(f,g)$ as polynomials (the right side a constant).
Evaluating at $N$ gives $u(N) f(N) + v(N) g(N) = \mathrm{Res}(f,g)$. Any common
divisor of $f(N)$ and $g(N)$ divides the left side, hence the constant on the
right. $\square$

**Corollary 4.7 (Uniform numerical bound).** If $\mathrm{Res}(f,g) \neq 0$ then
$\gcd(f(N), g(N)) \leq |\mathrm{Res}(f,g)|$ for every $N$.

**Corollary 4.8 (Multi-modulus boundedness).** For any finite list
$L \subset \mathbb{Z}[X]$ of non-constant polynomials with pairwise nonzero
resultants, there exists a single constant $B$ — the maximum of
$|\mathrm{Res}(f,g)|$ over $f, g \in L$ — with
$\gcd(f(N), g(N)) \leq B$ for all $f, g \in L$ and all $N \in \mathbb{Z}$.

For the tested family the constants are minuscule. Explicit Bézout certificates
give, for all $N$:

| pair | overlap divides |
|---|---|
| $(N-1, N+1)$ | $2$ |
| $(N-1, N^2+1)$ | $2$ |
| $(N-1, N^2+N+1)$ | $3$ |
| $(N-1, 2N-1)$ | $1$ |
| $(N-1, 2N+1)$ | $3$ |
| $(N+1, N^2+1)$ | $2$ |
| $(N+1, N^2+N+1)$ | $1$ |
| $(N+1, 2N-1)$ | $3$ |
| $(N+1, 2N+1)$ | $1$ |
| $(N^2+1, N^2+N+1)$ | $1$ |
| $(N^2+1, 2N-1)$ | $5$ |
| $(N^2+1, 2N+1)$ | $5$ |
| $(N^2+N+1, 2N-1)$ | $7$ |
| $(N^2+N+1, 2N+1)$ | $3$ |
| $(2N-1, 2N+1)$ | $1$ |

**Theorem 4.9 (Uniform pairwise bound, with sharpness).** Any two distinct
members of $\mathcal{F}$ satisfy $\gcd(f(N), g(N)) \leq 7$ for every $N$. The
bounds are attained: $\gcd(2^2+1, 2\cdot 2 + 1) = 5$ at $N = 2$, and
$\gcd(4-1, 4^2+4+1) = 3$ at $N = 4$; hence they cannot be improved to $1$.

The interpretation is decisive: adding a second derived modulus contributes at
most $O(1)$ new arithmetic, uniformly in $N$, and that $O(1)$ is a fixed
property of the polynomial pair. There is nothing $N$-dependent to amplify.

---

## 5. The spectrum belongs to the apparatus

The gcd barrier says the derived modulus shares nothing with $N$. A second,
logically independent obstruction says something stronger about *which primes can
occur at all*.

**Theorem 5.1 (Order constraint, $X^2+1$).** Let $p$ be an odd prime with
$p \mid N^2 + 1$ for some integer $N$. Then $p \equiv 1 \pmod 4$.

*Proof sketch.* Modulo $p$ we have $N^2 \equiv -1$, so $N^4 \equiv 1$ while
$N^2 \not\equiv 1$ (else $p \mid 2$). Hence the multiplicative order of $N$
modulo $p$ divides $4$ but not $2$, so it is exactly $4$. By Lagrange,
$4 \mid p - 1$. $\square$

**Theorem 5.2 (Order constraint, $\Phi_3$).** Let $p \neq 3$ be a prime with
$p \mid N^2 + N + 1$. Then $p \equiv 1 \pmod 3$.

*Proof sketch.* From $N^2 + N + 1 \equiv 0$ we get
$N^3 - 1 = (N-1)(N^2+N+1) \equiv 0$, so $N^3 \equiv 1$. If $N \equiv 1$ then
$N^2+N+1 \equiv 3$, forcing $p = 3$, excluded. So the order of $N$ is exactly
$3$ and $3 \mid p-1$. $\square$

**Theorem 5.3 (Converses).** Every prime $p \equiv 1 \pmod 4$ divides $N^2+1$
for some $N$, and every prime $p \equiv 1 \pmod 3$ divides $N^2+N+1$ for some
$N$.

*Proof sketch.* The multiplicative group $(\mathbb{Z}/p)^\times$ is cyclic of
order $p-1$. If $4 \mid p-1$ it contains an element $N$ of order $4$; then $N^2$
has order $2$, so $N^2 \equiv -1$ and $p \mid N^2+1$. If $3 \mid p-1$ it contains
an element $N$ of order $3$; then $N^3 \equiv 1$ and $N \not\equiv 1$, so
$N^2+N+1 \equiv 0$ since $(N-1)(N^2+N+1) \equiv 0$ with $N - 1$ invertible.
$\square$

**Theorem 5.4 (Spectrum theorem).** For a prime $p$:
$$p \in S_{X^2+1} \iff p = 2 \text{ or } p \equiv 1 \!\!\pmod 4,$$
$$p \in S_{X^2+X+1} \iff p = 3 \text{ or } p \equiv 1 \!\!\pmod 3.$$
Equivalently, as sets of primes,
$$\{\,p : \exists N,\ p \mid N^2+1\,\} = \{2\} \cup \{p \equiv 1 \bmod 4\},$$
$$\{\,p : \exists N,\ p \mid N^2+N+1\,\} = \{3\} \cup \{p \equiv 1 \bmod 3\}.$$

These are precisely the primes that split in $\mathbb{Q}(i)$ and in
$\mathbb{Q}(\zeta_3)$ respectively (together with the ramified prime). The
crucial structural point:

**Corollary 5.5 ($N$-independence of the spectrum).** The set of primes
available to the observable $N \mapsto N^2+1$ is one fixed arithmetic
progression, the same for every $N$, determined by the splitting field of the
generating polynomial. No feature of the spectrum can vary with the
factorization of $N$.

This is the superselection rule in its sharpest form: *the spectrum is a property
of the apparatus, never of the state.*

### 5.1 Congruence exclusion for cryptographic moduli

**Theorem 5.6 (Blum rigidity).** If $p$ is prime with $p \equiv 3 \pmod 4$, then
$p \nmid M^2 + 1$ for **every** integer $M$.

*Proof.* Immediate from Theorem 5.1: such a $p$ is odd and not $\equiv 1 \bmod 4$.
$\square$

**Corollary 5.7 (Double barrier for Blum integers).** Let $N = pq$ be a Blum
integer, $p \equiv q \equiv 3 \pmod 4$. Then $p \nmid N^2 + 1$, for two entirely
independent reasons: the gcd/polynomial barrier of Theorem 3.6, and the
congruence exclusion of Theorem 5.6 — the latter excluding $p$ from $M^2+1$ for
*all* $M$, not merely $M = N$.

**Theorem 5.8 (Companion exclusion).** If $p \equiv 2 \pmod 3$ is prime then
$p \nmid M^2 + M + 1$ for every integer $M$.

Roughly half of all primes are excluded from each quadratic modulus purely by
congruence. Because standard cryptographic prime generation frequently *selects*
$p \equiv 3 \bmod 4$, the excluded half is exactly the interesting half.

---

## 6. Freshness: factoring the derived modulus does not help

Suppose an adversary succeeds in factoring $M = f(N)$ completely. Two theorems
show the effort is wasted.

**Theorem 6.1 (Euclid step / fresh prime).** Let $f \in \mathbb{Z}[X]$ be
transparent with $f(0) = 1$ and non-constant. For every finite set $S$ of primes
there exists $N$ and a prime $r \notin S$ with $r \mid f(N)$.

*Proof sketch.* Choose $N$ a large multiple of $\prod_{s \in S} s$, large enough
that $|f(N)| > 1$. For each $s \in S$, $s \mid N$, hence $f(N) \equiv f(0) = 1
\pmod s$, so $s \nmid f(N)$. Since $|f(N)| > 1$, it has a prime factor, and that
factor lies outside $S$. $\square$

**Corollary 6.2 (Infinite support).** For non-constant transparent $f$, the
prime support $S_f$ is infinite; equivalently, the primes required to factor
derived moduli exceed every bound. For the three moduli $X^2+1$, $X^2+X+1$ and
$2X+1$ this is explicit.

**Theorem 6.3 (Freshness is useless).** If $f$ is transparent and $r$ is a prime
with $r \mid f(N)$, then $r \nmid N$.

*Proof.* Otherwise $r \mid \gcd(N, f(N)) = 1$. $\square$

**Corollary 6.4 (Synthesis of the two barriers).** For the modulus $N^2+1$: its
prime support is infinite — so factoring it is a *fresh* factorization problem
of unbounded difficulty — and no prime in that support ever divides the
corresponding $N$ — so the fresh problem's answer is guaranteed irrelevant to
factoring $N$.

This is the fourth barrier in the taxonomy: the large invariants ($\Omega$,
class numbers) that one might hope to compute for $N^2+1$ or $\Phi_3(N)$ require
that modulus's own factorization, which is a new hard problem whose solution
does not transfer.

---

## 7. The natural generality of the barrier, and its boundary

### 7.1 Congruence transport

Inspecting every proof above, exactly one property of the modulus map is used:
$a - b \mid F(a) - F(b)$. We therefore state the theory at that level.

**Theorem 7.1 (Abstract barrier).** If $F : \mathbb{Z} \to \mathbb{Z}$
transports congruences, then $\gcd(N, F(N)) = \gcd(N, F(0))$ for every $N$.

*Proof.* Identical to Theorem 3.2, using $N \mid F(N) - F(0)$. $\square$

**Theorem 7.2 (Abstract classification).** For a congruence-transporting $F$,
$$\bigl(\forall N,\ \gcd(N, F(N)) = 1\bigr) \iff F(0) = \pm 1 .$$

*Proof sketch.* ($\Leftarrow$) By Theorem 7.1 the gcd divides $|F(0)| = 1$.
($\Rightarrow$) Taking $N = 0$ in Theorem 7.1, $\gcd(0, F(0)) = |F(0)| = 1$.
$\square$

**Theorem 7.3 (Algebraic structure).** The congruence-transporting maps contain
all constants and the identity, are closed under $+$, $-$ and $\cdot$ (hence
form a subring of $\mathbb{Z}^{\mathbb{Z}}$), and are closed under composition.

*Proof sketch.* Additivity is immediate. For products use
$F(a)G(a) - F(b)G(b) = (F(a)-F(b))G(a) + F(b)(G(a)-G(b))$. For composition,
$a - b \mid G(a) - G(b) \mid F(G(a)) - F(G(b))$. $\square$

Since every polynomial transports congruences (Lemma 3.1), Theorems 7.1–7.3
generalize the entire development of §§3–4.

### 7.2 The exponential modulus is outside the class — and leaks

**Definition 7.4.** The *exponential derived modulus* is $F(N) = 2^{N} - 1$
(defined via $|N|$ for negative $N$).

**Theorem 7.5 (Outside the class).** $F(N) = 2^N - 1$ does not transport
congruences: with $a = 6$, $b = 0$, we have $a - b = 6$ and
$F(6) - F(0) = 63 - 0 = 63$, and $6 \nmid 63$.

**Theorem 7.6 (Leak criterion).** For an odd prime $p$,
$$p \mid 2^N - 1 \iff \mathrm{ord}_p(2) \mid N.$$
Hence if $p \mid N$ and $\mathrm{ord}_p(2) \mid N$, then $p \mid \gcd(N, 2^N-1)$.

**Theorem 7.7 (Infinitely many leaks).** For every $k \geq 1$,
$3 \mid \gcd(6(k+1),\ 2^{6(k+1)} - 1)$, since $\mathrm{ord}_3(2) = 2 \mid 6(k+1)$
and $3 \mid 6(k+1)$. Consequently
$$\{\, N : \gcd(N, 2^N - 1) > 1 \,\}$$
is infinite — in sharp contrast to Theorem 3.5, where only finitely many primes
can *ever* be shared.

**Theorem 7.8 (A complete factorization from the exponential modulus).**
$$\gcd\bigl(253,\ 2^{253} - 1\bigr) = 23, \qquad 253 = 11 \cdot 23 .$$

*Proof sketch.* $\mathrm{ord}_{23}(2) = 11$ because $2^{11} - 1 = 2047 = 23 \cdot 89$
and $11$ is prime; since $11 \mid 253$, Theorem 7.6 gives $23 \mid 2^{253}-1$.
Conversely $\mathrm{ord}_{11}(2) = 10 \nmid 253$, so $11 \nmid 2^{253}-1$. Since
the gcd divides $253 = 11 \cdot 23$ and is divisible by $23$ but not $11$, it
equals $23$. $\square$

**Theorem 7.9 (Necessity of the polynomial hypothesis).** All six polynomial
derived moduli are coprime to $N$ for every $N$; the exponential modulus shares
a factor with $N$ for infinitely many $N$ and at $N = 253$ recovers a complete
factorization. Therefore the no-go is exactly a theorem about the
congruence-transporting class, and its boundary is genuinely reached.

Two caveats keep this honest. First, the leak condition
$\mathrm{ord}_p(2) \mid N$ depends on the *value* of $N$, not on any residue of
$N$, which is precisely why no polynomial construction can imitate it. Second,
this is not a factoring algorithm: computing $2^N \bmod N$ is cheap, but the
leaky $N$ form a sparse set, and for a random semiprime with large prime factors
the probability that $\mathrm{ord}_p(2) \mid N$ is negligible. (This is,
recognizably, the mechanism behind the classical $p-1$ method, which requires the
smoothness of $p-1$ — an assumption the standard prime generation deliberately
defeats.)

---

## 8. The hint frontier: what a second modulus would have to be

If no derived modulus helps, the only remaining route is an *external hint*: a
number $h$, obtained from outside the algebra generated by $N$, that happens to
share a prime with $N$. We quantify that frontier exactly.

**Theorem 8.1 (Four outcomes).** For $N = pq$ with $p, q$ distinct primes and any
$h$, $\gcd(N, h) \in \{1, p, q, N\}$.

**Theorem 8.2 (Exact criterion).** $\gcd(pq, h) = p$ if and only if $p \mid h$
and $q \nmid h$.

**Theorem 8.3 (Recovery).** If $\gcd(N, h) = p$ then $q = N / \gcd(N,h)$; a
single useful hint yields the complete factorization.

**Theorem 8.4 (Exact count of useful hints).** For distinct primes $p, q$,
$$\#\{\, h \in \{0, 1, \ldots, pq-1\} : \gcd(pq, h) \neq 1 \,\} = p + q - 1 .$$

*Proof.* The complementary count is Euler's totient
$\varphi(pq) = (p-1)(q-1)$, and $pq - (p-1)(q-1) = p + q - 1$. $\square$

**Theorem 8.5 (Density of the frontier).** If $p, q > B \geq 1$ are distinct
primes, the useful-hint density satisfies
$$\frac{p + q - 1}{pq} \ \leq\ \frac{2}{B}.$$

*Proof sketch.* $(p+q-1)B \leq (p+q)B \leq pq + qp = 2pq$ using $B \leq q$ and
$B \leq p$. $\square$

For cryptographic parameters ($B \sim 2^{1024}$) the density is negligible: an
unstructured external hint is useless with overwhelming probability.

**Theorem 8.6 (Derived hints are always on the useless side).** For every
semiprime $N = pq$ and every $f \in \mathcal{F}$,
$$\gcd\bigl(N,\ |f(N)|\bigr) = 1 .$$
In particular $\gcd(N, |f(N)|) \neq p$: derived data sits strictly inside the
trivial class, for every $N$ simultaneously.

The dichotomy is now complete. Useful hints exist and are exactly characterized
(Theorem 8.2), they are rare (Theorem 8.5), and derived moduli provably never
produce one (Theorem 8.6). Any future progress along this line must therefore
come from *hint amplification*: an external source of a number sharing a prime
with $N$. That is a strictly different problem, outside the classical uniform
hint-free surface.

---

## 9. Algorithms

The results above are all effective, and each corresponds to a short algorithm
that can be run on concrete inputs.

**Algorithm A (Frozen-overlap verification).** Given $f$ and a range of $N$,
compute $\gcd(N, f(N))$ and $\gcd(N, f(0))$ and compare. By Theorem 3.2 they
agree for every $N$; the algorithm is $O(R \cdot (\deg f + \log^2 N))$ over a
range of $R$ values.

**Algorithm B (Transparency classification and witness search).** Given $f$,
test $|f(0)| = 1$. If transparent, report universal coprimality. If not,
construct the witness: $N = 2$ when $f(0) = 0$, else $N = \mathrm{lpf}(|f(0)|)$;
verify $\gcd(N, f(N)) > 1$. Cost is dominated by the factorization of the single
constant $f(0)$.

**Algorithm C (Resultant bound certification).** Given $f, g$, build the
$(\deg f + \deg g) \times (\deg f + \deg g)$ Sylvester matrix and compute its
determinant by exact fraction-free elimination; the result bounds
$\gcd(f(N), g(N))$ for all $N$ by Theorem 4.6. Complexity
$O((\deg f + \deg g)^3)$ ring operations.

**Algorithm D (Spectrum membership test).** Given a prime $p$, decide whether
$p$ can divide $N^2+1$ (resp. $N^2+N+1$) for some $N$ by testing
$p = 2 \lor p \equiv 1 \bmod 4$ (resp. $p = 3 \lor p \equiv 1 \bmod 3$). This is
$O(1)$ and requires no knowledge of $N$ — the operational content of Corollary
5.5.

**Algorithm E (Exponential-leak scan).** For each candidate $N$, compute
$g = \gcd(N, 2^N - 1 \bmod N)$ by fast modular exponentiation, cost
$O(\log^3 N)$. When $g \notin \{1, N\}$, $g$ is a nontrivial factor. This
realizes Theorem 7.8 and, by contrast, demonstrates the sparsity of leaks.

**Algorithm F (Hint frontier census).** For a small semiprime $N = pq$,
enumerate $h < N$ and count those with $\gcd(N, h) \neq 1$, verifying the value
$p+q-1$ of Theorem 8.4 and the density bound of Theorem 8.5.

---

## 10. Discussion

### 10.1 What kind of result this is

Negative results in this area are usually *heuristic barriers*: statements that
a class of techniques is "unlikely to work" or that a natural approach reduces to
a problem believed hard. What is unusual here is that the obstruction is an
*exact classification*. We do not merely show that the six tested moduli fail;
we characterize the failure precisely — universal invisibility $\iff$ unit
constant term — exhibit the witnesses when the characterization's hypothesis
fails, prove that the invisible class is closed under exactly the operations an
attacker has available, and then locate the boundary of the whole argument by
producing a construction just outside it that provably leaks.

### 10.2 The superselection reading

Interpreting $N$ as a state and $f$ as an apparatus, the results assemble into a
superselection rule with three layers:

1. **Algebra layer** (Theorem 3.2). The observable $f(N)$ lies in the algebra
   generated by $N$; its overlap with $N$ is a c-number, $\gcd(N, f(0))$.
2. **Coarse-graining layer** (Theorem 3.10). Residue observables of $f(N)$
   factor through residues of $N$: they can only lose resolution.
3. **Spectrum layer** (Corollary 5.5). The set of available eigenvalues is fixed
   by the apparatus's splitting field, so no spectral statistic can vary with the
   internal degeneracy of the state.

The factorization fiber is a *superselection sector*: two semiprimes with the
same relevant $N$-data are indistinguishable to every observable in the algebra.

### 10.3 Relation to classical factoring methods

Theorem 7.6 is recognizably the engine of the classical $p-1$ method: the
exponential modulus leaks precisely when the order of the base modulo a factor
divides the exponent. The taxonomy here explains why $p-1$-type methods are the
*only* survivors of this family: they are exactly the constructions that fail
congruence transport. Modern prime generation defeats them by requiring $p-1$ to
have a large prime factor — that is, by making the leak condition
astronomically unlikely — which is entirely consistent with our sparsity
observation.

### 10.4 Scope and limitations

Several honest limitations:

- The barrier concerns invariants computed *from* $N$ by
  congruence-transporting maps. Attacks that use additional structure — lattice
  reduction on partially known bits, side channels, quantum period-finding — lie
  outside the hypothesis and are unaffected.
- The empirical component (correlations, permutation nulls) is a statistical
  finding on finite batches; the theorems here are what make it non-accidental,
  but the theorems concern divisibility and spectra, not every conceivable
  invariant. What they do establish is that *any* invariant that is a function of
  residues of $f(N)$, or of the divisibility relations between $N$ and $f(N)$,
  or of the prime spectrum of $f$, cannot carry factor-specific information.
- The exponential leak is a boundary marker, not an attack.

### 10.5 Verdict

The multi-modulus corner is closed. Derived moduli of polynomial (more
generally, congruence-transporting) type carry no factor-specific signal, and no
combination of them can. The only route that remains open in this direction is
external hint amplification, whose target set has density at most $2/B$.

---

## 11. Future directions

### C1 (Galois superselection)

**Conjecture.** For irreducible $f \in \mathbb{Z}[X]$ with splitting field $K_f$
and Galois group $G$, the spectrum
$$S_f = \{\, p \text{ prime} : \exists N,\ p \mid f(N) \,\}$$
equals, up to finitely many primes, the set of $p$ whose Frobenius class in $G$
fixes at least one root of $f$; and membership $p \in S_f$ is decidable from $p$
alone. Consequently no invariant of $f(N)$ distinguishes two semiprimes with the
same $N$.

The key insight is that the two spectra proved here — $p = 2$ or
$p \equiv 1 \bmod 4$, and $p = 3$ or $p \equiv 1 \bmod 3$ — are the abelian,
cyclotomic shadow of a general Frobenius criterion: the spectrum is a property of
the apparatus $f$, never of the state $N$. The natural next target is the
non-abelian case, e.g. $f = X^3 - X - 1$ with $G = S_3$. The conjecture would be
falsified by exhibiting any $f$ whose spectrum depends on more than the residue
class of $p$ (equivalently, on more than a Chebotarev condition).

### C2 (Sharp resultant law for the multi-modulus lattice)

The divisibility half is proved above (Theorem 4.6, Corollaries 4.7–4.8): the
overlap of any two derived moduli divides $\mathrm{Res}(f,g)$, with a uniform
bound and a finite-family version. What remains open is the **attainment half**:
for coprime $f, g \in \mathbb{Z}[X]$, characterize exactly which divisors of
$\mathrm{Res}(f,g)$ are attained as $\gcd(f(N), g(N))$, and with what density in
$N$. Sharpness examples exist ($5$ at $N=2$ for $(X^2+1, 2X+1)$; $3$ at $N=4$ for
$(X-1, \Phi_3)$), suggesting the attained set is governed by the local solvability
of the pair modulo prime powers dividing the resultant.

### C3 (Hint amplification frontier)

Since derived moduli always land on the useless side, quantify the *amplification*
problem directly: given an external number $h$ with a known weak correlation to a
factor of $N$, how many independent such hints are needed before a useful one
appears? The density bound $2/B$ gives the base rate; the question is whether
structured (non-uniform) hint distributions can beat it, and by how much, under
explicit hardness assumptions.

### C4 (Beyond congruence transport)

Classify the maps $F$ that fail congruence transport in a *controlled* way — for
instance, those with $a - b \mid F(a) - F(b)$ for all $a, b$ in a fixed
congruence class, or those satisfying transport modulo a fixed conductor. The
exponential modulus is the canonical example; a systematic theory would explain
which "almost-transporting" constructions can leak and at what density.

### C5 (Degeneracy-corrected invariants)

Three of the six tested invariants are provably constant (Proposition 3.9). A
finer experiment would use *degeneracy-corrected* invariants — e.g.
$\mathrm{lpf}((N^2+1)/2)$ rather than $\mathrm{lpf}(N^2+1)$, or the odd part's
number of prime factors — and re-run the permutation-null analysis. The
prediction from Corollary 5.5 is that even the corrected invariants remain inside
the null, since their spectra are still $N$-independent; a violation would be a
genuine surprise and would falsify the superselection reading.

---

## 12. Conclusion

We have closed the derived-modulus corner. The identity $N \mid f(N) - f(0)$
freezes the entire overlap between a semiprime and any polynomial derived modulus
at the constant term; universal invisibility is *exactly* the condition
$f(0) = \pm 1$; the invisible class is a monoid closed under products and
substitution, so no combination escapes; pairwise interactions are bounded by
resultants, uniformly in $N$; the prime spectra of the quadratic moduli are fixed
sets of split primes, so nothing spectral can vary with the factorization; the
prime support is infinite but never touches $N$, so factoring the derived modulus
is a fresh problem with a guaranteed-irrelevant answer; the whole argument runs at
the level of congruence-transporting maps; and just outside that class the
exponential modulus $2^N-1$ leaks, factoring $253 = 11 \cdot 23$ outright. The
only escape is external information, whose useful fraction is at most $2/B$.

A function of $N$ is a function of $N$. Coarse-graining never refines. To see the
factorization one must bring in something that did not come from $N$.
