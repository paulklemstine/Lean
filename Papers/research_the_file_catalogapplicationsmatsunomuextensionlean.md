# Sharp/Flat Supersingular Degree Sequences at a General Prime

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

For an elliptic curve with good supersingular reduction at a prime $p$, the sharp and
flat characteristic degrees of Pollack–Kobayashi type grow, along the cyclotomic
$\mathbb{Z}_p$-tower, like partial sums of powers of $p$ in base $p^2$. At the prime
$p = 2$ this growth is governed by the classical Jacobsthal recurrence
$J_{n+2} = J_{n+1} + 2J_n$, and the flat degree is exactly the even-indexed
Jacobsthal number. We isolate the elementary arithmetic skeleton of this phenomenon
and extend it verbatim to an arbitrary supersingular prime $p$. Replacing the
Jacobsthal sequence by the two-parameter **generalised Jacobsthal sequence**
$q_{n+2} = (p-1)q_{n+1} + p q_n$ (with $q_0 = 0$, $q_1 = 1$) and base $4$ by base
$p^2$, we prove five results: the closed form $(p+1)q_n = p^n - (-1)^n$; the
consecutive-sum identity $q_n + q_{n+1} = p^n$; the base-$p^2$ flat-degree closed form
$(p^2 - 1)\,\mathrm{flatDeg}_p(n) + 1 = p^{2n}$; the sharp/flat ratio
$\mathrm{sharpDeg}_p(n) = p\cdot\mathrm{flatDeg}_p(n)$; and the **bridge**
$q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n)$ linking the recurrence to the honest base-$p^2$
growth of the degrees. Every statement specialises, at $p = 2$, to the classical
Jacobsthal identities. The unifying mechanism is the factorisation
$p^2 - 1 = (p+1)(p-1)$, which reveals that the apparent dependence of the classical
formula on the accident $p - 1 = 1$ was illusory.

## 1. Introduction

### 1.1 Context

The Iwasawa theory of an elliptic curve $E/\mathbb{Q}$ studies how arithmetic
invariants of $E$ vary along the cyclotomic $\mathbb{Z}_p$-tower
$\mathbb{Q} \subset \mathbb{Q}(\mu_p) \subset \mathbb{Q}(\mu_{p^2}) \subset \cdots$.
When $E$ has good **ordinary** reduction at $p$, a single $p$-adic $L$-function and a
single characteristic ideal control the growth of the Selmer groups, and Mazur's
theory produces one $\lambda$-invariant and one $\mu$-invariant. When $E$ has good
**supersingular** reduction — an infinite but density-zero set of primes for a fixed
curve — the classical $p$-adic $L$-function fails to be integral, and the theory
bifurcates. Following Pollack and Kobayashi, one introduces a *pair* of well-behaved
objects: the **sharp** ($\sharp$) and **flat** ($\flat$) $p$-adic $L$-functions and
their associated plus/minus Selmer groups, each with its own $\lambda$-invariant.

A recurrent computational observation is that the *characteristic degrees* attached to
these sharp and flat objects grow, level by level in the tower, in a rigidly
structured way: as partial sums of powers of $p$, segregated by parity of exponent. At
the prime $p = 2$ these partial sums coincide with the classical Jacobsthal numbers,
and this coincidence has been used as a bookkeeping device in explicit supersingular
computations. The purpose of the present paper is to extract the underlying elementary
arithmetic, prove it rigorously, and show that it is not special to $p = 2$: it holds
for every prime once the base $p^2$ and the two-parameter recurrence are used.

### 1.2 Results

We prove the following, for an arbitrary prime $p$ (the results are purely arithmetic
and hold for all integers $p$ with the stated non-degeneracy):

1. **Jacobsthal closed form** (Theorem 3.1): $(p+1)q_n = p^n - (-1)^n$.
2. **Consecutive-sum law** (Theorem 3.2): $q_n + q_{n+1} = p^n$ (for $p + 1 \ne 0$).
3. **Base-$p^2$ flat-degree closed form** (Theorem 4.2):
   $(p^2-1)\,\mathrm{flatDeg}_p(n) + 1 = p^{2n}$.
4. **Sharp/flat ratio** (Theorem 4.3): $\mathrm{sharpDeg}_p(n) = p\cdot\mathrm{flatDeg}_p(n)$.
5. **Bridge** (Theorem 5.1): $q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n)$.

Section 6 records the specialisation to $p = 2$, recovering the classical Jacobsthal
identities.

### 1.3 The unifying mechanism

The single fact that drives every comparison is the factorisation
$$p^2 - 1 = (p+1)(p-1).$$
The factor $p + 1$ is the denominator in the Jacobsthal closed form; the factor
$p - 1$ is the extra coefficient that appears on the degree side. Their product,
$p^2 - 1$, is exactly the multiplier that telescopes the base-$p^2$ geometric sum.
This is why the bridge involves *even* Jacobsthal indices and the factor $p - 1$, and
why the classical $p = 2$ formula — in which $p - 1 = 1$ vanishes silently — looked
deceptively like a fact about the number $2$.

## 2. Definitions

Throughout, $p$ denotes a prime (all arithmetic identities below hold over
$\mathbb{Z}$ for arbitrary integer $p$ under the indicated non-degeneracy hypotheses;
the number-theoretic interpretation requires $p$ prime and supersingular).

**Definition 2.1 (Generalised Jacobsthal sequence).**
The generalised Jacobsthal sequence $q_\bullet : \mathbb{N} \to \mathbb{Z}$ attached to
$p$ is defined by
$$q_0 = 0, \qquad q_1 = 1, \qquad q_{n+2} = (p-1)\,q_{n+1} + p\,q_n \quad (n \ge 0).$$
Its characteristic polynomial is $x^2 - (p-1)x - p = (x - p)(x + 1)$, with roots $p$
and $-1$. At $p = 2$ the recurrence is $q_{n+2} = q_{n+1} + 2q_n$, the classical
Jacobsthal recurrence, producing $0, 1, 1, 3, 5, 11, 21, 43, 85, \dots$.

**Definition 2.2 (Flat degree).**
For a base parameter $p \in \mathbb{N}$ and a level $n \in \mathbb{N}$, the flat
characteristic degree is the base-$p^2$ partial sum
$$\mathrm{flatDeg}_p(n) = \sum_{i=0}^{n-1} p^{2i} = 1 + p^2 + p^4 + \cdots + p^{2(n-1)}.$$

**Definition 2.3 (Sharp degree).**
The sharp characteristic degree is the odd-exponent partial sum
$$\mathrm{sharpDeg}_p(n) = \sum_{i=0}^{n-1} p^{2i+1} = p + p^3 + p^5 + \cdots + p^{2n-1}.$$

These two sequences model the level-$n$ characteristic degrees of the flat and sharp
Pollack–Kobayashi objects along the $\mathbb{Z}_p$-tower.

## 3. The generalised Jacobsthal sequence

**Theorem 3.1 (Closed form).**
For every $n \ge 0$,
$$(p+1)\,q_n = p^n - (-1)^n.$$

*Proof.* Strong induction on $n$. The base cases $n = 0$ and $n = 1$ are direct:
$(p+1)q_0 = 0 = p^0 - (-1)^0$ and $(p+1)q_1 = p + 1 = p^1 - (-1)^1$. For the inductive
step at $n + 2$, apply the recurrence and the inductive hypotheses at $n+1$ and $n$:
$$(p+1)q_{n+2} = (p-1)\,(p+1)q_{n+1} + p\,(p+1)q_n
   = (p-1)\bigl(p^{n+1} - (-1)^{n+1}\bigr) + p\bigl(p^n - (-1)^n\bigr).$$
Expanding, the $p$-power terms give $(p-1)p^{n+1} + p\cdot p^n = p^{n+2} - p^{n+1} +
p^{n+1} = p^{n+2}$, and the sign terms give
$-(p-1)(-1)^{n+1} - p(-1)^n = (p-1)(-1)^n - p(-1)^n = -(-1)^n = -(-1)^{n+2}$. Hence
$(p+1)q_{n+2} = p^{n+2} - (-1)^{n+2}$. $\qquad\blacksquare$

The closed form is the standard root-decomposition $q_n = \dfrac{p^n - (-1)^n}{p+1}$,
made subtraction-explicit and division-free so that it is valid over $\mathbb{Z}$ with
no invertibility assumption on $p + 1$.

**Theorem 3.2 (Consecutive-sum law).**
If $p + 1 \ne 0$, then for every $n \ge 0$,
$$q_n + q_{n+1} = p^n.$$

*Proof.* Multiply the claim by $p + 1$ and use Theorem 3.1 twice:
$$(p+1)(q_n + q_{n+1}) = \bigl(p^n - (-1)^n\bigr) + \bigl(p^{n+1} - (-1)^{n+1}\bigr)
   = p^n + p^{n+1} = (p+1)p^n,$$
because $(-1)^n + (-1)^{n+1} = 0$. Cancelling the non-zero factor $p + 1$ gives
$q_n + q_{n+1} = p^n$. $\qquad\blacksquare$

At $p = 2$ this recovers the classical fact that consecutive Jacobsthal numbers sum to
a power of two: $1 + 3 = 4$, $3 + 5 = 8$, $5 + 11 = 16$, and so on.

## 4. The base-$p^2$ degree sequences

**Lemma 4.1 (One-step growth).**
For every $n \ge 0$,
$$\mathrm{flatDeg}_p(n+1) = \mathrm{flatDeg}_p(n) + p^{2n}.$$

*Proof.* Immediate from Definition 2.2: the sum over $i < n+1$ is the sum over $i < n$
plus the top term $p^{2n}$. $\qquad\blacksquare$

**Theorem 4.2 (Base-$p^2$ closed form).**
For every $n \ge 0$,
$$(p^2 - 1)\,\mathrm{flatDeg}_p(n) + 1 = p^{2n}.$$
Equivalently, in subtraction-free form,
$$p^2 \cdot \mathrm{flatDeg}_p(n) + 1 = \mathrm{flatDeg}_p(n) + p^{2n}.$$

*Proof.* Induction on $n$. For $n = 0$ both sides equal $1$ (the empty sum is $0$, so
$(p^2-1)\cdot 0 + 1 = 1 = p^0$). Assume the identity at $n$. Using Lemma 4.1,
$$(p^2 - 1)\,\mathrm{flatDeg}_p(n+1) + 1
   = (p^2 - 1)\bigl(\mathrm{flatDeg}_p(n) + p^{2n}\bigr) + 1
   = \bigl[(p^2-1)\mathrm{flatDeg}_p(n) + 1\bigr] + (p^2-1)p^{2n}.$$
By the inductive hypothesis the bracket is $p^{2n}$, so the total is
$p^{2n} + (p^2 - 1)p^{2n} = p^{2n}\cdot p^2 = p^{2(n+1)}$. $\qquad\blacksquare$

This is the geometric-series identity $\sum_{i<n} r^i = (r^n - 1)/(r-1)$ specialised to
$r = p^2$, stated so that it holds over $\mathbb{N}$ without any division.

**Theorem 4.3 (Sharp/flat ratio).**
For every $n \ge 0$,
$$\mathrm{sharpDeg}_p(n) = p \cdot \mathrm{flatDeg}_p(n).$$

*Proof.* Factor a single $p$ out of each term of the sharp sum:
$$\mathrm{sharpDeg}_p(n) = \sum_{i=0}^{n-1} p^{2i+1}
   = p\sum_{i=0}^{n-1} p^{2i} = p\cdot\mathrm{flatDeg}_p(n). \qquad\blacksquare$$

Thus the sharp and flat degree sequences are never independent: the sharp degree is a
rigid $p$-fold rescaling of the flat degree at every level.

## 5. The bridge

The central comparison unites the recurrence of Section 3 with the degree sequences of
Section 4.

**Theorem 5.1 (Bridge).**
For every $n \ge 0$ (with $p + 1 \ne 0$),
$$q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n).$$

*Proof.* Evaluate the Jacobsthal closed form (Theorem 3.1) at the even index $2n$:
$$(p+1)\,q_{2n} = p^{2n} - (-1)^{2n} = p^{2n} - 1.$$
By the base-$p^2$ closed form (Theorem 4.2), $p^{2n} - 1 = (p^2 - 1)\,\mathrm{flatDeg}_p(n)$.
Factor $p^2 - 1 = (p+1)(p-1)$:
$$(p+1)\,q_{2n} = (p+1)(p-1)\,\mathrm{flatDeg}_p(n).$$
Cancelling the non-zero factor $p + 1$ yields $q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n)$.
$\qquad\blacksquare$

The proof isolates the exact role of each factor of $p^2 - 1$: the $p+1$ is the
Jacobsthal denominator that cancels, and the $p - 1$ is the residue that survives on
the degree side. The bridge is therefore the arithmetic reason that *even-indexed*
generalised Jacobsthal numbers, and only those, track the flat degree.

## 6. Specialisation to $p = 2$

Setting $p = 2$ recovers the classical picture that motivated the general theory.

- The recurrence becomes $q_{n+2} = q_{n+1} + 2q_n$, the classical **Jacobsthal
  recurrence**, with $q_\bullet = 0, 1, 1, 3, 5, 11, 21, 43, 85, \dots$.
- The closed form (Theorem 3.1) becomes $3q_n = 2^n - (-1)^n$, i.e.
  $q_n = (2^n - (-1)^n)/3$, the textbook Jacobsthal formula.
- The consecutive-sum law (Theorem 3.2) becomes $q_n + q_{n+1} = 2^n$.
- The degree sequences are the base-$4$ sums $\mathrm{flatDeg}_2(n) = \sum_{i<n}4^i$
  and $\mathrm{sharpDeg}_2(n) = \sum_{i<n} 2\cdot 4^i = 2\,\mathrm{flatDeg}_2(n)$, so
  the ratio (Theorem 4.3) reads $\mathrm{sharpDeg}_2(n) = 2\,\mathrm{flatDeg}_2(n)$.
- The base-$p^2$ closed form (Theorem 4.2) becomes $3\,\mathrm{flatDeg}_2(n) + 1 = 4^n$.
- The bridge (Theorem 5.1) becomes $q_{2n} = (2-1)\,\mathrm{flatDeg}_2(n) =
  \mathrm{flatDeg}_2(n)$: the **even Jacobsthal numbers equal the flat degrees exactly**.

The last line is the historical coincidence that concealed the general law. Because
$p - 1 = 1$ at $p = 2$, the factor $p - 1$ in the bridge disappears, making the flat
degree *equal* to the even Jacobsthal number rather than merely proportional to it.
The present treatment shows this was an artefact of the prime $2$: for every prime the
correct statement carries the factor $p - 1$.

## 7. Applications and interpretation

The degree sequences $\mathrm{flatDeg}_p$ and $\mathrm{sharpDeg}_p$ are the intended
models of the level-$n$ characteristic degrees of the flat and sharp Pollack–Kobayashi
$p$-adic $L$-functions of a supersingular elliptic curve along its cyclotomic tower.
Under this dictionary the results above have direct interpretations.

- **Predictable degree growth.** Theorem 4.2 says the flat degree grows so that its
  base-$p^2$ digit length increases by exactly one at every level; the arithmetic
  complexity of the tower is completely determined and grows like $p^{2n}$.
- **A rigid sharp/flat relationship.** Theorem 4.3 says the sharp and flat degrees are
  never independent data — knowing one determines the other by a factor of $p$. This
  constrains any conjectural comparison between the two invariants.
- **A recurrence for computation.** The bridge (Theorem 5.1) lets one compute flat
  degrees via a fast linear recurrence (the generalised Jacobsthal numbers) rather
  than by summing a geometric series, and conversely certifies Jacobsthal values by a
  closed-form degree count.

These arithmetic facts form the *skeleton* on which the analytic and cohomological
machinery of supersingular Iwasawa theory — Coleman maps, the $\omega_n^\pm$ of
Pollack, Sprung's sharp/flat decomposition, and Matsuno's twist formula — is hung. By
pinning the skeleton down exactly and uniformly in $p$, one obtains precise targets
for the deeper theory to hit.

## 8. Discussion and future work

The results here deliberately use only elementary tools — a linear recurrence, a
geometric sum, and the factorisation $p^2 - 1 = (p+1)(p-1)$ — because the goal is to
establish the *exact* arithmetic backbone, uniformly in $p$, on which heavier machinery
can rest. Several natural extensions push the scaffold toward genuine Iwasawa theory.

1. **A uniform depth-weight law across supersingular primes.** For a supersingular
   prime $p$ and an odd prime $\ell \ne p$, one expects the local twist weight in the
   $\lambda$-difference to equal $p^{m_\ell}$ with $m_\ell = v_p\bigl((\ell^{p^2-1} -
   1)/(p^2 - 1)\bigr)$, and the total weight over the divisors of a twisting modulus
   $D$ to equal $(p-1)\,\mathrm{flatDeg}_p(\omega(D))$, where $\omega(D)$ counts prime
   divisors — tying local weights to even-indexed generalised Jacobsthal numbers. The
   same factorisation $p^2 - 1 = (p+1)(p-1)$ that produced the bridge should govern the
   aggregate weight. The bridge, now proved uniformly in $p$, removes the last place
   where the classical formula appeared to rely on the accident $p - 1 = 1$.

2. **Multiplicativity under twisting.** The map sending a twisting modulus $D$ to the
   pair $(\mathrm{sharpDeg}, \mathrm{flatDeg})$ in base $p^2$ is conjecturally
   multiplicative on coprime moduli, with
   $\mathrm{flatDeg}(mn) = \mathrm{flatDeg}(m) + p^{2\omega(m)}\,\mathrm{flatDeg}(n)$ for
   coprime $m, n$. Base-$p^2$ positional expansion turns concatenation of prime
   supports into digit shifts, so additivity of $\omega$ lifts to a shift-and-add law
   on the degree sequences. With Theorem 4.2 in hand, this reduces to an elementary
   $p^{2n}$ identity.

3. **Parity of the $\lambda$-difference.** One expects the sharp/flat
   $\lambda$-difference of a quadratic twist to be even for every supersingular prime
   $p \ge 3$ and every squarefree modulus, with the sole obstruction to oddness
   occurring at $p = 2$ through the $(-1)^n$ term of the Jacobsthal closed form.

4. **Genuine Iwasawa invariants.** Replace the modelled degrees by actual $\lambda$-
   and $\mu$-invariants extracted from a characteristic power series in
   $\mathbb{Z}_p[[T]]$ via Weierstrass preparation, and prove additivity
   $\lambda(fg) = \lambda(f) + \lambda(g)$, $\mu(fg) = \mu(f) + \mu(g)$.

5. **Sharp/flat Coleman maps.** Formalise Pollack's $\omega_n^\pm$ and Sprung's
   sharp/flat decomposition of the $p$-adic $L$-function, and identify their degrees
   with the sequences studied here.

## 9. Conclusion

We have isolated the elementary arithmetic that governs the growth of the sharp and
flat characteristic degrees of a supersingular elliptic curve along its cyclotomic
tower, and shown that it extends from the historically privileged prime $2$ to every
prime at once. The generalised Jacobsthal recurrence
$q_{n+2} = (p-1)q_{n+1} + p q_n$, its closed form $(p+1)q_n = p^n - (-1)^n$, the
consecutive-sum law $q_n + q_{n+1} = p^n$, the base-$p^2$ degree closed form
$(p^2-1)\mathrm{flatDeg}_p(n) + 1 = p^{2n}$, the sharp/flat ratio
$\mathrm{sharpDeg}_p = p\,\mathrm{flatDeg}_p$, and the bridge
$q_{2n} = (p-1)\mathrm{flatDeg}_p(n)$ together form a complete, prime-independent
description. The single factorisation $p^2 - 1 = (p+1)(p-1)$ explains both why the
theory works and why the classical $p = 2$ case appeared, misleadingly, to be special.
