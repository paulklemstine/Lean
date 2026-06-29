# A Formally Verified AKS Polynomial Criterion for Primality

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Cryptography / Computational Number Theory

## Abstract

We present a complete, machine-verified proof of the *AKS polynomial criterion*
for primality: for every integer $n \ge 2$ and every unit $a$ in the ring
$\mathbb{Z}/n\mathbb{Z}$,
$$n \text{ is prime} \iff (X + a)^n = X^n + a \quad \text{in } (\mathbb{Z}/n\mathbb{Z})[X].$$
This equivalence is the algebraic core of the Agrawal–Kayal–Saxena deterministic
polynomial-time primality test. The forward direction is the Frobenius
endomorphism identity combined with Fermat's little theorem. The reverse
direction is established constructively: for composite $n$ with least prime
factor $q$, the coefficient of $X^q$ in $(X + a)^n$ is shown to be nonzero,
witnessing failure of the identity. The crux is a pair of arithmetic facts about
binomial coefficients — the identity $q\binom{n}{q} = n\binom{n-1}{q-1}$ and the
congruence $\binom{n-1}{q-1} \equiv 1 \pmod q$ — from which we derive that $n
\nmid \binom{n}{q}$. We give full statements, proof sketches, an algorithmic
realization, numerical demonstrations including the Carmichael number $561$, and
a discussion of applications to cryptography and directions toward the complete
deterministic algorithm. All results have been formalized and verified with no
remaining gaps.

## 1. Introduction

Primality testing is foundational to public-key cryptography: RSA key generation,
Diffie–Hellman parameter selection, and DSA all require large, certified primes.
The question of whether primality can be decided *deterministically* in time
polynomial in the number of digits of $n$ was resolved affirmatively by Agrawal,
Kayal, and Saxena in 2002 (*"PRIMES is in P"*). Their algorithm rests on a
polynomial generalization of Fermat's little theorem.

The classical Fermat test uses the scalar congruence $a^n \equiv a \pmod n$,
which is necessary but not sufficient for primality: *Carmichael numbers* satisfy
it for all bases while being composite. The AKS insight is to lift the test from
scalars to *polynomials*. The scalar congruence $a^n \equiv a$ becomes the
polynomial identity $(X + a)^n \equiv X^n + a$, and — crucially — this lifted
identity is both necessary and sufficient for primality. The present work
formalizes exactly this sufficiency-and-necessity statement, which we call the
**AKS polynomial criterion**.

We work over the commutative ring $R = \mathbb{Z}/n\mathbb{Z}$ and its polynomial
ring $R[X]$. The notation $C\,a$ denotes the constant polynomial with value $a$,
and $X$ the indeterminate. Throughout, $n \ge 2$ and $a$ is a *unit* of $R$
(equivalently $\gcd(a, n) = 1$).

### 1.1 Contributions

1. A formally verified proof of the forward implication (Theorem
   `aks_forward`): primality implies the polynomial identity.
2. A formally verified proof of the reverse implication via an explicit
   witnessing coefficient (Theorems `coeff_Xq_ne_zero`, `aks_reverse`).
3. Verified supporting number theory: the binomial recurrence
   `mul_choose_eq`, the congruence `choose_pred_eq_one_mod`, and the
   non-divisibility `not_dvd_choose_of_prime_dvd`.
4. The assembled equivalence (Theorem `aks_criterion`).
5. An algorithmic realization, numerical demonstrations, and a separation
   from the Fermat test on the Carmichael number $561$.

## 2. Preliminaries and Definitions

**Definition 2.1 (Clock arithmetic ring).** For $n \ge 1$, $\mathbb{Z}/n\mathbb
{Z}$ is the ring of integers modulo $n$, with elements $\{0, 1, \dots, n-1\}$ and
arithmetic performed modulo $n$.

**Definition 2.2 (Unit).** An element $a \in \mathbb{Z}/n\mathbb{Z}$ is a *unit*
if there exists $b$ with $ab = 1$. Equivalently, $\gcd(a, n) = 1$. We write
`IsUnit a`.

**Definition 2.3 (Polynomial ring).** $(\mathbb{Z}/n\mathbb{Z})[X]$ is the ring
of polynomials with coefficients in $\mathbb{Z}/n\mathbb{Z}$. For $p \in R[X]$,
$p.\mathrm{coeff}\, k$ denotes the coefficient of $X^k$.

**Definition 2.4 (Binomial coefficient).** $\binom{n}{k}$ is the number of
$k$-element subsets of an $n$-element set, with the conventions $\binom{n}{0} = 1$
and $\binom{n}{k} = 0$ for $k > n$.

**Definition 2.5 (Modular congruence).** For naturals $a, b, m$, we write $a
\equiv b \pmod m$ (Lean: `a ≡ b [MOD m]`) to mean $a \bmod m = b \bmod m$.

**Definition 2.6 (Least prime factor).** For $n \ge 2$, $\mathrm{minFac}(n)$ is
the smallest prime dividing $n$. If $n$ is prime, $\mathrm{minFac}(n) = n$;
otherwise $\mathrm{minFac}(n) < n$.

We rely on three classical inputs, each available in formalized form:

- **Frobenius / freshman's dream:** in a commutative ring of prime characteristic
  $p$, $(x + y)^p = x^p + y^p$.
- **Fermat's little theorem (ring form):** for prime $p$, every $a \in \mathbb
  {Z}/p\mathbb{Z}$ satisfies $a^p = a$.
- **Expansion of $(X + Ca)^n$:** $\bigl((X + Ca)^n\bigr).\mathrm{coeff}\, k =
  \binom{n}{k}\, a^{\,n-k}$.

## 3. Main Results

### 3.1 Forward direction

**Theorem 3.1 (`aks_forward`).** If $n$ is prime, then for every $a \in \mathbb
{Z}/n\mathbb{Z}$,
$$(X + Ca)^n = X^n + Ca \quad \text{in } (\mathbb{Z}/n\mathbb{Z})[X].$$

*Proof sketch.* Since $n$ is prime, $\mathbb{Z}/n\mathbb{Z}$ has characteristic
$n$, so the Frobenius identity `add_pow_char` gives $(X + Ca)^n = X^n + (Ca)^n$.
The constant-polynomial map is a ring homomorphism, so $(Ca)^n = C(a^n)$. By
Fermat's little theorem in ring form (`ZMod.pow_card`), $a^n = a$, hence $(Ca)^n
= Ca$. Combining, $(X + Ca)^n = X^n + Ca$. $\qquad\blacksquare$

This direction needs no unit hypothesis on $a$: it holds for every coefficient.

### 3.2 Binomial arithmetic

**Theorem 3.2 (`mul_choose_eq`).** For $1 \le q \le n$,
$$q \cdot \binom{n}{q} = n \cdot \binom{n-1}{q-1}.$$

*Proof sketch.* Write $n = m + 1$ and $q = j + 1$. The absorption identity
`Nat.add_one_mul_choose_eq` states $(m+1)\binom{m}{j} = (j+1)\binom{m+1}{j+1}$,
i.e. $n\binom{n-1}{q-1} = q\binom{n}{q}$; rearranging gives the claim. The
boundary cases $n = 0$ or $q = 0$ are excluded by the hypotheses and dispatched
by linear arithmetic. $\qquad\blacksquare$

Combinatorially, both sides count pairs (a $q$-subset $S$ of $[n]$, a
distinguished element of $S$): the left side chooses $S$ then its chairman; the
right side chooses the chairman from $[n]$ then the remaining $q-1$ members from
the other $n-1$ elements.

**Theorem 3.3 (`choose_pred_eq_one_mod`).** If $q$ is prime, $q \mid n$, and $q
\le n$, then
$$\binom{n-1}{q-1} \equiv 1 \pmod q.$$

*Proof sketch.* Pass to the field $\mathbb{Z}/q\mathbb{Z}$ via `ZMod.
natCast_eq_natCast_iff`. Expand the falling factorial:
$$(n-1)^{\underline{q-1}} = (q-1)! \cdot \binom{n-1}{q-1}$$
using `Nat.descFactorial_eq_factorial_mul_choose`. Since $q \mid n$, we have $n
\equiv 0$, so $n - 1 \equiv -1$ in $\mathbb{Z}/q\mathbb{Z}$, and the descending
product becomes
$$(n-1)^{\underline{q-1}} = \prod_{i=0}^{q-2}(n-1-i) \equiv \prod_{i=0}^{q-2}(-1-i)
= (-1)^{q-1}\,(q-1)!.$$
Equating the two expressions for the falling factorial modulo $q$ and cancelling
the unit $(q-1)!$ (nonzero modulo the prime $q$ by Wilson-type reasoning /
`hq.dvd_factorial`), we obtain $\binom{n-1}{q-1} \equiv (-1)^{q-1} \pmod q$. For
$q$ odd, $(-1)^{q-1} = 1$; the case $q = 2$ is checked directly. Hence
$\binom{n-1}{q-1} \equiv 1$. $\qquad\blacksquare$

**Theorem 3.4 (`not_dvd_choose_of_prime_dvd`).** If $n \ge 2$, $q$ is prime, $q
\mid n$, and $q < n$, then
$$n \nmid \binom{n}{q}.$$

*Proof sketch.* Suppose for contradiction $n \mid \binom{n}{q}$, say $\binom{n}
{q} = n k$. From Theorem 3.2, $q \binom{n}{q} = n \binom{n-1}{q-1}$, so $q n k =
n \binom{n-1}{q-1}$, giving $\binom{n-1}{q-1} = q k$, i.e. $q \mid \binom{n-1}
{q-1}$. But Theorem 3.3 gives $\binom{n-1}{q-1} \equiv 1 \pmod q$, so its
remainder modulo $q$ is $1$, not $0$. Since $q \ge 2$, $1 \ne 0 \bmod q$, a
contradiction. $\qquad\blacksquare$

### 3.3 The witnessing coefficient

**Theorem 3.5 (`coeff_Xq_ne_zero`).** If $n \ge 2$, $a$ is a unit, $q$ is prime,
$q \mid n$, and $q < n$, then the coefficient of $X^q$ in $(X + Ca)^n$ is nonzero
in $\mathbb{Z}/n\mathbb{Z}$:
$$\bigl((X + Ca)^n\bigr).\mathrm{coeff}\, q \ne 0.$$

*Proof sketch.* By the binomial expansion, $\bigl((X + Ca)^n\bigr).\mathrm{coeff}
\, q = \binom{n}{q}\, a^{\,n-q}$ in $\mathbb{Z}/n\mathbb{Z}$. By Theorem 3.4, $n
\nmid \binom{n}{q}$, so $\binom{n}{q} \ne 0$ in $\mathbb{Z}/n\mathbb{Z}$. Since
$a$ is a unit, so is $a^{n-q}$, and multiplying a nonzero element by a unit
cannot yield zero. Hence the product is nonzero. $\qquad\blacksquare$

### 3.4 Reverse direction and the criterion

**Theorem 3.6 (`aks_reverse`).** If $n \ge 2$, $a$ is a unit, and $n$ is *not*
prime, then
$$(X + Ca)^n \ne X^n + Ca.$$

*Proof sketch.* Let $q = \mathrm{minFac}(n)$. Since $n \ge 2$ is composite, $q$
is prime (`Nat.minFac_prime`), $q \mid n$ (`Nat.minFac_dvd`), and $q < n$
(strict because $n$ is composite). The right-hand side $X^n + Ca$ has zero
coefficient at $X^q$, because $0 < q < n$ excludes both the $X^n$ term and the
constant term. The left-hand side has nonzero coefficient at $X^q$ by Theorem
3.5. Hence the polynomials differ. $\qquad\blacksquare$

**Theorem 3.7 (`aks_criterion`).** For $n \ge 2$ and $a$ a unit in $\mathbb{Z}/n
\mathbb{Z}$,
$$n \text{ is prime} \iff (X + Ca)^n = X^n + Ca.$$

*Proof sketch.* ($\Rightarrow$) Theorem 3.1. ($\Leftarrow$) Contrapositive: if
$n$ were composite, Theorem 3.6 would make the identity fail; so the identity
forces primality. $\qquad\blacksquare$

## 4. Algorithmic Realization

The criterion yields a clean (if not yet polynomial-time) decision procedure.

**Algorithm AKS-Single-Base.** *Input:* $n \ge 2$. *Output:* `PRIME` or
`COMPOSITE`.

1. Choose a unit $a$ modulo $n$ (e.g. $a = 1$, always a unit).
2. Compute $P \gets (X + a)^n \bmod n$ in $(\mathbb{Z}/n\mathbb{Z})[X]$ by
   repeated squaring of polynomials.
3. Compute $Q \gets X^n + a$.
4. If $P = Q$ return `PRIME`, else return `COMPOSITE`.

By Theorem 3.7 this is *correct for every $n$* — there is no error probability
and no Carmichael loophole. Its cost is dominated by step 2: the polynomial
$(X + a)^n$ has degree $n$, so each multiplication touches $\Theta(n)$
coefficients and there are $\Theta(\log n)$ squarings, giving roughly $\tilde O
(n)$ ring operations — exponential in the bit-length of $n$. The full AKS
algorithm removes this blow-up by reducing modulo $X^r - 1$ for a small $r =
O((\log n)^c)$, keeping polynomials of degree $< r$, and by checking $O(\sqrt
{r}\log n)$ bases; that reduction is the subject of Future Direction 1 below and
is *not* part of the present formalization. The verified content is the exact
correctness of the *unbounded-degree* identity, which is the algorithm's logical
foundation.

## 5. Numerical Demonstrations

The accompanying `demo.py` realizes Algorithm AKS-Single-Base with explicit
polynomial arithmetic over $\mathbb{Z}/n\mathbb{Z}$ and confirms every theorem
empirically.

- **Primes (freshman's dream).** For $n \in \{2,3,5,7,11,13\}$, the identity
  $(X + a)^n = X^n + a$ holds for *every* unit $a$, illustrating Theorem 3.1.
- **Composites and the witnessing coefficient.** For $n \in \{4,6,8,9,12,15,21,
  25\}$, the identity fails, and the surviving coefficient is exactly $\binom{n}
  {q}\bmod n$ at $q = \mathrm{minFac}(n)$, as predicted by Theorem 3.5. For
  instance $n = 9$: $q = 3$, $\binom{9}{3} \equiv 3 \pmod 9 \ne 0$.
- **Carmichael separation.** For $n = 561 = 3 \cdot 11 \cdot 17$, the Fermat
  congruence $a^{561} \equiv a$ holds for all tested bases, yet the AKS identity
  fails: $q = 3$ and $\binom{561}{3} \equiv 187 \pmod{561}$. AKS detects the
  composite the Fermat test cannot.
- **Binomial identity.** $q\binom{n}{q} = n\binom{n-1}{q-1}$ checked for $(n,q)
  \in \{(10,3),(12,4),(21,3),(561,3)\}$ (Theorem 3.2).
- **Congruence.** $\binom{n-1}{q-1} \equiv 1 \pmod q$ checked at $q = \mathrm
  {minFac}(n)$ for $n \in \{6,12,15,21,561\}$ (Theorem 3.3).

## 6. Applications

**Cryptographic key generation.** RSA and discrete-log systems need certified
large primes. Probabilistic tests (Miller–Rabin) are used in practice for speed,
but a *deterministic, unconditionally correct* criterion such as AKS is valuable
as a final certificate and as a specification against which fast tests are
validated. The verified equivalence here removes any doubt about the algebraic
core of that certificate.

**Distinguishing from Fermat-style tests.** The Carmichael number $561$ makes
concrete why the polynomial lift is strictly stronger than the scalar Fermat
test. Any system relying on Fermat-only checks is, in principle, defeatable by
Carmichael inputs; the AKS criterion is not.

**A trustworthy specification.** Because the criterion is machine-checked, it can
serve as a reference oracle for testing optimized but unverified primality code:
discrepancies on any input reveal bugs in the optimized implementation.

## 7. Discussion

The proof exhibits a recurring theme in elementary number theory: prime
characteristic both *creates* and *detects* structure. In the forward direction,
prime characteristic annihilates the middle binomial terms (Frobenius),
collapsing the expansion. In the reverse direction, the *absence* of that
collapse is pinned to a single coefficient $\binom{n}{q}$, and the same
prime-divisibility analysis — now applied to $q = \mathrm{minFac}(n)$ rather than
to $n$ itself — guarantees that coefficient survives. The technical heart is
remarkably small: one binomial recurrence and one congruence, combined by a
one-line contradiction.

A subtle point worth emphasizing is the role of the unit hypothesis. It is used
*only* in the reverse direction (Theorem 3.5), to ensure $a^{n-q}$ cannot
silently zero out the surviving coefficient. The forward direction holds for all
$a$. This asymmetry is faithfully reflected in the formal statements.

The formalization also makes the case analysis explicit where informal proofs
often gloss: the congruence $\binom{n-1}{q-1} \equiv 1 \pmod q$ genuinely
requires separating $q = 2$ from odd primes because of the $(-1)^{q-1}$ factor,
and the boundary conditions $1 \le q \le n$ in the binomial recurrence must be
tracked to avoid vacuous or ill-typed natural-number subtraction.

## 8. Future Directions

The single-base criterion is the algebraic keystone; several natural extensions
remain.

1. **Introspective-base AKS bound.** Establish an explicit polylogarithmic bound
   $B(n)$ such that $n$ is prime iff $(X + a)^n = X^n + a$ in $(\mathbb{Z}/n
   \mathbb{Z})[X]/(X^r - 1)$ for all $1 \le a \le B(n)$ with $r = O((\log n)^c)$.
   This upgrades the exact criterion to the full deterministic polynomial-time
   algorithm. The algebraic obstruction (the coefficient $\binom{n}{q}$) is
   already isolated; what remains is the cyclotomic order/coprime-base counting
   after quotienting by $X^r - 1$.

2. **Monier–Rabin $1/4$ error bound.** Prove that for every odd composite $n >
   9$, the number of Miller–Rabin non-witnesses in $(\mathbb{Z}/n\mathbb{Z})^
   \times$ is at most $\varphi(n)/4$. The strong-liar set lies in a proper
   subgroup of $(\mathbb{Z}/n\mathbb{Z})^\times$; bounding its index by $4$ is
   the whole game, leaning on the CRT decomposition of the unit group.

3. **AKS strictly dominates Fermat on every Carmichael number.** Show that for
   *every* Carmichael number $n$, the Fermat congruence holds for all bases yet
   the AKS identity fails for some base coprime to $n$, generalizing the $561$
   separation to the entire family. The needed ingredient is Korselt's
   criterion ($n$ squarefree and $(p-1) \mid (n-1)$ for each prime $p \mid n$).

4. **Characterizing Carmichael numbers.** Prove that a composite $n$ satisfies
   $a^n \equiv a \pmod n$ for all $a$ if and only if $n$ is squarefree and
   $(p-1) \mid (n-1)$ for every prime $p \mid n$ (Korselt's criterion).

## 9. Conclusion

We have given a fully machine-verified proof that the polynomial identity $(X +
a)^n = X^n + a$ over $\mathbb{Z}/n\mathbb{Z}$ holds exactly when $n$ is prime,
together with all supporting binomial number theory. The forward direction is
classical algebra; the reverse direction is a constructive unmasking of every
composite via a single surviving binomial coefficient at its least prime factor.
This equivalence is the verified foundation on which the deterministic
polynomial-time AKS algorithm is built, and it cleanly separates from the
classical Fermat test on Carmichael numbers such as $561$.

## Appendix: Index of Verified Results

| Name | Statement |
|------|-----------|
| `aks_forward` | $n$ prime $\Rightarrow (X+Ca)^n = X^n + Ca$ |
| `mul_choose_eq` | $q\binom{n}{q} = n\binom{n-1}{q-1}$ for $1 \le q \le n$ |
| `choose_pred_eq_one_mod` | $q$ prime, $q \mid n \Rightarrow \binom{n-1}{q-1} \equiv 1 \pmod q$ |
| `not_dvd_choose_of_prime_dvd` | $q$ prime, $q \mid n$, $q < n \Rightarrow n \nmid \binom{n}{q}$ |
| `coeff_Xq_ne_zero` | coefficient of $X^q$ in $(X+Ca)^n$ is nonzero |
| `aks_reverse` | $n$ composite $\Rightarrow (X+Ca)^n \ne X^n + Ca$ |
| `aks_criterion` | $n$ prime $\iff (X+Ca)^n = X^n + Ca$ |
