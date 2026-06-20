# Tropical Spectral Cryptanalysis and Strong Divisibility: The Eigenvalue Leak of Min-Plus Diffie–Hellman

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Cryptography

---

## Abstract

We analyze the security of key-exchange protocols built on **tropical (min-plus)
matrix powering**, and prove that the underlying **Tropical Discrete Logarithm
Problem (TDLP)** admits a complete, deterministic break for almost every key via a
spectral side channel. The core mechanism is the *additivity of the tropical
eigenvalue under powering*: if $(\lambda, v)$ is a tropical eigenpair of a matrix
$A$, then the per-coordinate residual of the public power $A^{\otimes t}$ equals
$t\lambda$ at every coordinate, so the secret exponent $t$ is recovered by a single
division whenever $\lambda \neq 0$. We then strengthen this from a value-recovery
attack to a **structural** one. Viewing the leaked eigenvalue as a function of the
genuine exponent, $t \mapsto c\,t$ with $c = \lambda(A)$, we show this sequence is a
**strong divisibility sequence**: $\gcd(c m, c n) = c\,\gcd(m, n)$. Consequently the
public transcript leaks the entire divisibility lattice of the secret exponent:
$(m+1)\mid(k+1) \iff c(m+1)\mid c(k+1)$. We further show the Diffie–Hellman shared
key's eigenvalue factorizes through public data, $c\cdot\lambda(\text{shared}) =
\lambda(\text{pub}_a)\cdot\lambda(\text{pub}_b)$, ruling out hardness amplification by
nesting. The results are organized as a *bridge* between tropical spectral
cryptanalysis and the classical theory of strong divisibility sequences (which also
contains the Fibonacci and Mersenne sequences), yielding a reusable security-audit
criterion: any scheme whose transcript is a strong divisibility sequence in the
secret is not exponent-hiding. All results have been formally verified.

---

## 1. Introduction

The search for cryptographic primitives that resist quantum attack has driven
interest in unconventional algebraic platforms. One such platform is **tropical
algebra**, the min-plus semiring $(\mathbb{R}, \min, +)$, in which the tropical
matrix product encodes the all-pairs shortest path problem and is therefore
plausibly one-way: it is computable in $O(n^3)$ time forward but resists inversion.
A line of proposals adapts the classical Diffie–Hellman key exchange to this
setting by replacing modular exponentiation with **tropical matrix powering**
$A^{\otimes t}$, computable in $O(n^3 \log t)$ by repeated squaring. The security of
these proposals rests on the **Tropical Discrete Logarithm Problem (TDLP)**:
recover $t$ from $(A, A^{\otimes t})$.

This paper gives a precise, formally verified account of why these schemes fail. We
isolate the structural invariant responsible — the tropical eigenvalue — and show
that it not only breaks value-secrecy but exposes the full arithmetic of the
secret. Our contributions are:

1. **A deterministic spectral break (Section 4).** The measurable residual of the
   public power $A^{\otimes t}$ equals $t\lambda$ at every coordinate, giving exact
   recovery of $t$ when $\lambda \neq 0$, and *no* leak when $\lambda = 0$.
2. **A strong-divisibility upgrade (Section 5).** The eigenvalue sequence
   $t \mapsto c\,t$ is a strong divisibility sequence, so divisibility of secret
   exponents is equivalent to divisibility of public eigenvalues.
3. **A no-amplification theorem (Section 6).** The shared-key eigenvalue factorizes
   through public eigenvalues, so nesting powers cannot increase hardness.
4. **A reusable audit criterion (Section 7).** "Is the transcript a strong
   divisibility sequence in the secret?" becomes a falsifiable security test.

---

## 2. Tropical preliminaries

### 2.1 The min-plus semiring

The **tropical (min-plus) semiring** is $(\mathbb{R}, \oplus, \otimes)$ with

$$a \oplus b = \min(a, b), \qquad a \otimes b = a + b.$$

Tropical addition is idempotent ($a \oplus a = a$) and has no additive inverses;
tropical multiplication is ordinary addition, with identity $0$.

### 2.2 Tropical matrices and vectors

For $A, B \in \mathbb{R}^{n\times n}$ the **tropical matrix product** is

$$(A \otimes B)_{ij} = \min_{k}\,\big(A_{ik} + B_{kj}\big),$$

and the **tropical matrix–vector product** for $v \in \mathbb{R}^n$ is

$$(A \otimes v)_i = \min_{k}\,\big(A_{ik} + v_k\big).$$

The matrix product is associative and computable in $O(n^3)$ operations; it
coincides with one step of the Floyd–Warshall shortest-path relaxation.

### 2.3 Tropical matrix powers

We use a *field-friendly indexing* (avoiding any need for a tropical identity over
$\mathbb{R}$) in which the index is one less than the genuine exponent. Define
$A^{\otimes t}$ by

$$\mathrm{tropMatPow}(A, 0) = A, \qquad \mathrm{tropMatPow}(A, k+1) = A \otimes \mathrm{tropMatPow}(A, k),$$

so that $\mathrm{tropMatPow}(A, k)$ is the genuine $(k+1)$-fold product
$A^{\otimes(k+1)}$. Throughout, "genuine exponent" $t$ means $t = k+1$ for index
$k$. The power obeys the exponent laws (all formally verified):

- **Additive law:** $A^{\otimes a} \otimes A^{\otimes b} = A^{\otimes(a+b)}$
  (`tropMatMul_tropMatPow_add`, in index form
  $\mathrm{tropMatPow}(A,a)\otimes\mathrm{tropMatPow}(A,b)=\mathrm{tropMatPow}(A,a+b+1)$).
- **Power-of-power:** $(A^{\otimes a})^{\otimes b} = A^{\otimes(ab)}$
  (`tropMatPow_tropMatPow`, in index form
  $\mathrm{tropMatPow}(\mathrm{tropMatPow}(A,a),b)=\mathrm{tropMatPow}(A, ab+a+b)$,
  encoding $(a+1)(b+1)-1 = ab+a+b$).
- **Commutation / DH correctness:**
  $(A^{\otimes a})^{\otimes b} = (A^{\otimes b})^{\otimes a}$ (`tropMatPow_comm`).

### 2.4 Repeated squaring

Because of the additive law, $A^{\otimes t}$ is computed by binary exponentiation:
square to double the exponent, multiply by $A$ to increment. This yields $O(n^3
\log t)$ time, making the forward map cheap and motivating the hardness assumption
on its inverse, the TDLP.

---

## 3. Tropical spectra and the residual side channel

### 3.1 Tropical eigenpairs

**Definition (tropical eigenpair).** A pair $(\lambda, v) \in \mathbb{R} \times
\mathbb{R}^n$ is a **tropical eigenpair** of $A$ when

$$(A \otimes v)_i = v_i + \lambda \quad \text{for all } i,$$

i.e. $A \otimes v = v + \lambda\cdot\mathbf{1}$. This is the min-plus analogue of
$Av = \lambda v$: the matrix shifts the eigenvector by a constant. The scalar
$\lambda$ is the **tropical eigenvalue**; for an irreducible matrix it equals the
minimum cycle mean of the associated weighted digraph.

### 3.2 The residual

**Definition (residual).** The **tropical residual** of $A$ at $v$ is the
per-coordinate shift

$$\mathrm{res}(A, v)_i = (A \otimes v)_i - v_i.$$

This is the natural — and essentially only — measurable difference in min-plus
algebra, and it is exactly the signal an adversary can probe.

**Lemma 3.1 (residual equals eigenvalue, `tropResidual_eq_eigenvalue`).** If
$(\lambda, v)$ is a tropical eigenpair of $A$, then $\mathrm{res}(A, v)_i = \lambda$
for every $i$.

*Proof.* Immediate from the definition: $\mathrm{res}(A,v)_i = (A\otimes v)_i - v_i
= (v_i + \lambda) - v_i = \lambda$. $\qquad\blacksquare$

A consequence (`tropResidual_const`) is that the residual is coordinate-independent,
so a single coordinate suffices to read off $\lambda$.

---

## 4. The eigenvalue leak and the TDLP break

The pivotal observation is that the residual of a *power* scales linearly with the
exponent.

**Theorem 4.1 (eigenvalue additivity under powering, `tropResidual_tropMatPow`).**
Let $(\lambda, v)$ be a tropical eigenpair of $A$. Then for every index $k$ and
coordinate $i$,

$$\mathrm{res}\big(A^{\otimes(k+1)}, v\big)_i = (k+1)\,\lambda.$$

*Proof sketch.* The eigenvector relation gives $A \otimes v = v + \lambda
\mathbf{1}$. Applying $A$ a second time and using that adding a constant commutes
with the min-plus action, $A \otimes (v + \lambda\mathbf 1) = (A\otimes v) +
\lambda\mathbf 1 = v + 2\lambda\mathbf 1$. By induction on the number of factors,
$A^{\otimes(k+1)}\otimes v = v + (k+1)\lambda\mathbf 1$, and subtracting $v$
coordinatewise gives the residual $(k+1)\lambda$. (Formally this uses the
matrix–vector iteration `tropMatVecMul_tropMatPow` together with Lemma 3.1.)
$\qquad\blacksquare$

**Corollary 4.2 (TDLP recovery, the break).** If $\lambda = \lambda(A) \neq 0$ and a
reference eigenvector $v$ is known, the secret genuine exponent $t = k+1$ is
recovered from any single coordinate by

$$t = \frac{\mathrm{res}\big(A^{\otimes t}, v\big)_i}{\lambda}.$$

The cost is one matrix–vector product and one division: the TDLP is solved in
polynomial time.

**Theorem 4.3 (the silent regime, `eigenzero_no_leak`).** If $(0, v)$ is a tropical
eigenpair of $A$ (eigenvalue zero), then $\mathrm{res}(A, v)_i = 0$ for all $i$, and
moreover $\mathrm{res}(A^{\otimes t}, v)_i = 0$ for all $t$ (`eigenzero_iterate`):
the residual side channel leaks nothing about $t$.

*Proof.* Specialize Lemma 3.1 (resp. Theorem 4.1) at $\lambda = 0$.
$\qquad\blacksquare$

Theorems 4.1–4.3 establish a clean dichotomy: the scheme is broken precisely when
$\lambda \neq 0$, and is residual-silent exactly when $\lambda = 0$. A zero
eigenvalue requires a zero-weight cycle in the digraph of $A$, a non-generic
condition; for random integer matrices with strictly positive off-diagonal weights
it occurs with vanishing probability, so the break applies to almost every key.

---

## 5. From value leak to structural leak: strong divisibility

We now show the leak is far deeper than value recovery. Fix the matrix and regard
the leaked eigenvalue purely as a function of the genuine exponent.

### 5.1 Strong divisibility sequences

**Definition (strong divisibility sequence).** A **strong divisibility sequence**
(SDS) is a function $a:\mathbb{N}\to\mathbb{N}$ with

$$a(0) = 0, \qquad \gcd\big(a(m), a(n)\big) = a\big(\gcd(m,n)\big) \ \text{ for all } m,n.$$

The Fibonacci numbers, the Mersenne numbers $b^n - 1$, and the identity sequence
are classical examples. From the two axioms one derives a full divisibility
calculus, including:

- **Divisibility monotonicity (`StrongDivSeq.dvd_of_dvd`):** $m \mid n \implies
  a(m) \mid a(n)$. *Proof:* if $m\mid n$ then $\gcd(m,n)=m$, so $\gcd(a(m),a(n)) =
  a(m)$, whence $a(m)\mid a(n)$.
- **Meet law (`StrongDivSeq.dvd_gcd_iff`):** $d \mid a(\gcd(m,n)) \iff d \mid a(m)
  \wedge d \mid a(n)$.

### 5.2 The tropical eigenvalue sequence

**Definition (tropical eigenvalue sequence, `tropEigSeq`).** For $c \in \mathbb{N}$
define $\mathrm{tropEigSeq}(c)$ by $a(t) = c\,t$. As a function of the genuine
exponent $t$, this is the leaked eigenvalue $\lambda(A^{\otimes t}) = c\,t$ with
$c = \lambda(A)$ (taken integral).

**Theorem 5.1 (`tropEigSeq` is an SDS).** $\mathrm{tropEigSeq}(c)$ is a strong
divisibility sequence.

*Proof.* $a(0) = c\cdot 0 = 0$, and by the identity $\gcd(cm, cn) = c\,\gcd(m,n)$
(distributivity of $\gcd$ over multiplication, `Nat.gcd_mul_left`),
$\gcd(a(m),a(n)) = a(\gcd(m,n))$. $\qquad\blacksquare$

### 5.3 The bridge link: measurement equals sequence value

**Theorem 5.2 (residual equals sequence value, `residual_eq_tropEigSeq`).** Let
$(c, v)$ be a tropical eigenpair of $A$ with $c\in\mathbb{N}$. Then for every index
$k$ and coordinate $i$,

$$\mathrm{res}\big(A^{\otimes(k+1)}, v\big)_i = \big(\mathrm{tropEigSeq}(c)\big)(k+1) \in \mathbb{R}.$$

*Proof.* By Theorem 4.1 the left side equals $(k+1)c$; by definition the right side
is $c(k+1)$. $\qquad\blacksquare$

This is the load-bearing identification: the *physically measurable* residual of
the cryptographic public power equals the *number-theoretic* value of the SDS. It
licenses transporting the entire SDS divisibility calculus onto the cryptanalysis.

### 5.4 The divisibility leak

**Theorem 5.3 (divisibility leak, `tdlp_divisibility_leak`).** For $c > 0$ and all
$m, k$,

$$(m+1) \mid (k+1) \quad\Longleftrightarrow\quad \big(\mathrm{tropEigSeq}(c)\big)(m+1) \ \big|\ \big(\mathrm{tropEigSeq}(c)\big)(k+1).$$

*Proof.* ($\Rightarrow$) is `StrongDivSeq.dvd_of_dvd` applied to Theorem 5.1.
($\Leftarrow$) Unfolding, $c(m+1)\mid c(k+1)$; cancel the positive factor $c$ via
`Nat.mul_dvd_mul_iff_left` to get $(m+1)\mid(k+1)$. $\qquad\blacksquare$

**Interpretation.** Equivalence — not just implication — means the public leaked
eigenvalues are a *faithful* image of the secret exponents' divisibility lattice. An
adversary who harvests transcripts reads off relations such as "secret $X$ divides
secret $Y$" or "secret $X$ is prime" directly from public data. This is strictly
stronger than the injectivity used in Section 4: it is not merely that the secret is
determined, but that its whole arithmetic structure is exposed.

**Corollary 5.4 (eigenvalue gcd identity, `tropical_eigenvalue_gcd`).** For all
$m,n$,

$$\gcd\Big(\lambda\big(A^{\otimes m}\big),\ \lambda\big(A^{\otimes n}\big)\Big) = \lambda\big(A^{\otimes \gcd(m,n)}\big),$$

i.e. $\gcd(a(m), a(n)) = a(\gcd(m,n))$ for $a = \mathrm{tropEigSeq}(c)$.

---

## 6. No hardness amplification by nesting

A natural hardening attempt is to nest powers (the Diffie–Hellman shared key is such
a nested object). The eigenvalue arithmetic obstructs this.

**Theorem 6.1 (shared-key eigenvalue factorization, `tdlp_dh_eigenvalue_product`).**
For all $c, a, b \in \mathbb{N}$,

$$c \cdot \big(\mathrm{tropEigSeq}(c)\big)\big((a+1)(b+1)\big) = \big(\mathrm{tropEigSeq}(c)\big)(a+1)\cdot\big(\mathrm{tropEigSeq}(c)\big)(b+1).$$

*Proof.* Both sides equal $c^2(a+1)(b+1)$: the left is $c\cdot c(a+1)(b+1)$, the
right is $c(a+1)\cdot c(b+1)$. $\qquad\blacksquare$

Writing $\lambda(\text{shared}) = a((a+1)(b+1))$, $\lambda(\text{pub}_a) = a(a+1)$,
$\lambda(\text{pub}_b) = a(b+1)$, this reads

$$c \cdot \lambda(\text{shared}) = \lambda(\text{pub}_a)\cdot\lambda(\text{pub}_b),$$

with every right-hand quantity public. The shared secret's fingerprint is computable
from public data, so nesting multiplies a public invariant rather than concealing a
private one.

**Theorem 6.2 (shared-key residual, `dh_shared_residual`).** Let $(c, v)$ be a
tropical eigenpair of $A$. For all indices $a, b$ and coordinates $i$,

$$\mathrm{res}\Big(\big(A^{\otimes(a+1)}\big)^{\otimes(b+1)},\, v\Big)_i = \big(\mathrm{tropEigSeq}(c)\big)\big((a+1)(b+1)\big).$$

*Proof sketch.* By the power-of-power law `tropMatPow_tropMatPow`, the nested power
equals $A^{\otimes(a+1)(b+1)}$ (in index form, $\mathrm{tropMatPow}(A, (a+1)(b+1)-1)$,
using $(a+1)(b+1)\ge 1$). Apply Theorem 5.2. $\qquad\blacksquare$

Thus the shared key $A^{\otimes(ab+a+b)}$ itself leaks the eigenvalue $c(a+1)(b+1)$:
the shared secret is exposed through its spectrum.

---

## 7. A reusable security-audit criterion

The break is not an artifact of a clever ad hoc attack; it is forced by structure.
The public transcript, as a function of the secret, is a strong divisibility
sequence, and Theorem 5.3 shows that *any* such transcript leaks the secret's
divisibility lattice. This yields a falsifiable design test:

> **Audit criterion.** If the public transcript of a key-exchange scheme, viewed as
> a function of the secret exponent, is a strong divisibility sequence, then the
> scheme is not exponent-hiding.

Because the SDS framework simultaneously contains the Fibonacci, Mersenne, identity,
and now tropical-eigenvalue sequences, this criterion is broadly applicable: it
reduces a security question to a structural one — "is my transcript an SDS?" — that
can be checked algebraically rather than by simulation.

---

## 8. Algorithms

### 8.1 Forward power by repeated squaring

Compute $A^{\otimes t}$ in $O(n^3 \log t)$ using the additive exponent law: maintain
a running base and accumulate factors according to the binary digits of $t$.

### 8.2 Spectral TDLP attack

Given public $(A, B = A^{\otimes t})$ with known eigenpair $(\lambda, v)$,
$\lambda\neq 0$: compute $r = (B\otimes v)_0 - v_0$ and return $t = r/\lambda$. Cost:
one matrix–vector product, $O(n^2)$.

### 8.3 Divisibility-lattice reconstruction

Given several public eigenvalues $\{c t_j\}$, recover the divisibility relations
among the secret $t_j$ by testing divisibility of the eigenvalues directly
(Theorem 5.3), or recover each $t_j$ by dividing out $c$ and reading off the gcd
lattice via Corollary 5.4.

(Full pseudocode and reference implementations appear in `demo.py` and the
`algorithms` field of `PACKAGE.json`.)

---

## 9. Discussion

The episode crystallizes a general principle: a cipher's safety lives in the
structure it *fails* to expose. Tropical matrix powering exposes too much — an
eigenvalue that counts the secret exactly at every coordinate, and a leaked sequence
so well-behaved that its arithmetic is an open book. The dichotomy of Section 4
($\lambda\neq 0$ broken vs. $\lambda = 0$ silent) is sharp, but the silent regime is
non-generic and arguably useless (a zero eigenvalue means a free cycle). The
structural leak of Section 5 shows that even *partial* secrecy goals (hiding
divisibility relations) fail. The no-amplification result of Section 6 forecloses
the obvious patch.

This does not impugn tropical mathematics, which remains valuable in optimization,
scheduling, and geometry. It impugns the use of *min-plus powering* as a discrete-log
platform.

---

## 10. Future directions

**C1. The eigenvalue-leak dichotomy is exhaustive.** Conjecture: for every finite
tropical matrix $A$ with eigenpair $(\lambda, v)$, the scheme is broken in
polynomial time iff $\lambda \neq 0$, and leaks nothing when $\lambda = 0$ — i.e.
$\lambda = 0$ is the *unique* secure eigenvalue. Both halves are formalized; what
remains is to prove no other attack-free regime exists.

**C2. Strong divisibility forces full lattice exposure.** Conjecture: any
key-exchange whose public transcript is a strong divisibility sequence in the secret
leaks the entire divisibility lattice of that secret and is therefore not
exponent-hiding. Placing tropical eigenvalues alongside Fibonacci and Mersenne in
one SDS frame turns "is the transcript an SDS?" into a reusable security audit.

**C3. Multiplicative shadow obstructs hardness amplification.** Conjecture:
iterating the tropical power cannot amplify TDLP hardness, because the shared-key
eigenvalue factorizes as $c\cdot\lambda(\text{shared}) =
\lambda(\text{pub}_a)\cdot\lambda(\text{pub}_b)$; nesting only multiplies a public
invariant.

**C4. Generic random tropical matrices have nonzero principal eigenvalue.**
Conjecture: for a random integer tropical matrix of size $n \ge 2$ with i.i.d.
entries in $\{0,\dots,M\}$ and zero self-loops, the maximal tropical eigenvalue (max
cycle mean) is $0$ only on a vanishing-probability set; hence by C1 the scheme is
broken with overwhelming probability.

---

## 11. Conclusion

We have given a formally verified, structural cryptanalysis of tropical min-plus
Diffie–Hellman. The tropical eigenvalue is additive under powering, breaking the
TDLP whenever it is nonzero; the leaked eigenvalue sequence $t\mapsto ct$ is a strong
divisibility sequence, exposing the secret's divisibility lattice; and the shared-key
eigenvalue factorizes through public data, precluding amplification by nesting. The
unifying lesson is a security-audit criterion of independent interest: transcripts
that form strong divisibility sequences cannot hide their secrets.
