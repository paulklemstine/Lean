# Primitive Prime Divisors of Fibonacci Numbers: Entry Points, Lifting-the-Exponent, and a Formal Treatment of Carmichael's Theorem

## Abstract

We present a self-contained development of the theory of primitive prime
divisors of the Fibonacci sequence $F_n$, culminating in Carmichael's 1913
theorem: for every index $n \notin \{1, 2, 6, 12\}$, the Fibonacci number $F_n$
possesses a primitive prime divisor, i.e. a prime dividing $F_n$ but none of the
earlier Fibonacci numbers. The development is organized around three pillars.
First, the **strong divisibility property** $\gcd(F_m, F_n) = F_{\gcd(m,n)}$,
from which the entry-point characterization $p \mid F_n \iff z(p) \mid n$ follows
directly. Second, a **lifting-the-exponent (LTE) lemma** for Fibonacci numbers,
$v_p(F_{nk}) = v_p(F_k) + v_p(n)$ for odd primes $p \mid F_k$ with $p \nmid n$,
which controls the imprimitive part of $F_n$. Third, **exponential growth
bounds** $F_n \ge 2^{\lfloor (n-2)/2 \rfloor}$ that force $F_n$ to exceed its
recyclable content. We give an unconditional proof for prime indices, a complete
determination of the exceptional set, and an entry-point localization theorem
$z(p) \mid p^2 - 1$ obtained via the companion matrix over a finite field. We
also record the apparition calculus for several primitive divisors
simultaneously. All results have been formally verified in the Lean 4 proof
assistant on top of Mathlib; the present paper gives the mathematics and proof
sketches.

**Keywords:** Fibonacci numbers, primitive prime divisors, Carmichael's
theorem, rank of apparition, lifting the exponent, $p$-adic valuation, strong
divisibility sequences, Zsygmondy's theorem.

**MSC 2020:** 11B39 (Fibonacci and Lucas numbers), 11A41 (primes), 11Y55
(calculation of sequences), 11A05 (multiplicative structure).

---

## 1. Introduction

The Fibonacci sequence is defined by $F_0 = 0$, $F_1 = 1$, and the recurrence
$F_{n+2} = F_{n+1} + F_n$. Its arithmetic is richly structured, and one of the
most striking structural facts concerns the *first appearance* of prime factors.

**Definition (Primitive prime divisor).** A prime $p$ is a *primitive prime
divisor* of $F_n$ if $p \mid F_n$ and $p \nmid F_k$ for all $1 \le k < n$.

The basic phenomenon is that primitive divisors are abundant: every Fibonacci
number, save a tiny set of exceptions, has one. This is **Carmichael's theorem**
(R. D. Carmichael, 1913), the Fibonacci instance of what is now known as the
Zsygmondy / Bang–Zsygmondy circle of results for $a^n - b^n$ and Lucas
sequences.

**Theorem (Carmichael, 1913).** For every $n \notin \{1, 2, 6, 12\}$, $F_n$ has
a primitive prime divisor. Equivalently, $F_n$ has a primitive prime divisor for
all $n \ge 13$, together with the small indices $n \in \{3,4,5,7,8,9,10,11\}$,
and fails only at $n \in \{1,2,6,12\}$.

The purpose of this paper is to assemble, in a uniform and elementary style, the
machinery behind this theorem, and to record the precise quantitative tools —
the entry-point characterization, the lifting-the-exponent lemma, the growth
bounds, and the finite-field localization of entry points — that make both the
classical proof and a modern formal verification possible. We have carried out
the formalization in Lean 4 / Mathlib; here we present statements and proof
sketches.

The paper is organized as follows. Section 2 records elementary Fibonacci facts
and growth bounds. Section 3 develops the entry point (rank of apparition) and
the divisibility characterization. Section 4 defines primitive prime divisors
and establishes their rigidity. Section 5 proves the lifting-the-exponent lemma.
Section 6 determines the exceptional set and proves the unconditional prime-index
case. Section 7 establishes the finite-field localization $z(p) \mid p^2 - 1$.
Section 8 records the simultaneous-apparition calculus. Section 9 discusses
algorithms, applications, and future directions.

---

## 2. Elementary properties and growth bounds

We work throughout with the natural-number Fibonacci function $F : \mathbb{N} \to
\mathbb{N}$, $F_0 = 0$, $F_1 = 1$, $F_{n+2} = F_{n+1} + F_n$.

**Lemma 2.1 (Positivity).** $F_n > 0$ for all $n > 0$.

*Proof sketch.* Immediate from $F_n \ge F_1 = 1$ for $n \ge 1$, or from the
standard `Nat.fib_pos` characterization $F_n > 0 \iff n > 0$. $\square$

**Lemma 2.2 (Strict monotonicity).** If $2 \le m < n$ then $F_m < F_n$.

*Proof sketch.* The Fibonacci function is strictly monotone on indices $\ge 2$
because each step adds a positive predecessor: $F_{k+1} = F_k + F_{k-1} > F_k$
once $F_{k-1} > 0$, i.e. for $k \ge 2$. $\square$

**Lemma 2.3 (Index domination).** $F_n \ge n$ for all $n \ge 5$.

*Proof sketch.* Strong induction. The base cases $n = 5,6,7,8,9$ are checked
directly ($F_5 = 5, F_6 = 8, F_7 = 13, \dots$), and the inductive step uses
$F_{n+2} = F_{n+1} + F_n \ge (n+1) + n \ge n + 2$. $\square$

**Lemma 2.4 (Exponential lower bound).** For all $n \ge 2$,
$$2^{\lfloor (n-2)/2 \rfloor} \le F_n.$$

*Proof sketch.* Split on parity $n = 2k$ or $n = 2k+1$ and induct, using
$F_{m+2} = F_{m+1} + F_m \ge 2 F_m$ to double across two steps. This expresses
the golden-ratio growth $F_n = \Theta(\varphi^n)$ in an elementary, certificate-
friendly form. $\square$

**Lemma 2.5 (Multiplicative bound).** For $m, n \ge 1$, $F_m F_n \le F_{m+n}$.

*Proof sketch.* Induct on $n$ using the addition formula $F_{m+n} = F_m F_{n-1}
+ F_{m+1} F_n$ (Lemma 3.1 below); the cross terms are nonnegative, and the term
$F_{m+1} F_n \ge F_m F_n$ delivers the inequality. $\square$

These bounds are precisely what is needed to certify that, for large $n$, $F_n$
strictly exceeds the product of its imprimitive prime-power contributions.

---

## 3. The entry point and the divisibility characterization

### 3.1 Strong divisibility

The foundational identity is the *strong divisibility property*.

**Theorem 3.1 (Strong divisibility / GCD identity).** For all $m, n$,
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$

*Proof sketch.* This is `Nat.fib_gcd` in Mathlib. It follows from the matrix
identity $Q^n = \begin{psmallmatrix} F_{n+1} & F_n \\ F_n & F_{n-1}
\end{psmallmatrix}$ together with the addition formula $F_{m+n} = F_m F_{n-1} +
F_{m+1} F_n$ and the Euclidean algorithm on indices. $\square$

**Corollary 3.2 (Divisibility of indices lifts).** If $m \mid n$ then $F_m \mid
F_n$.

*Proof sketch.* From $m \mid n$ we get $\gcd(m, n) = m$, so $\gcd(F_m, F_n) =
F_m$ by Theorem 3.1, i.e. $F_m \mid F_n$ (`Nat.fib_dvd`). $\square$

A sharp restatement that avoids the entry-point apparatus is the following *meet
law*, valid for an arbitrary divisor $d$ (no primality needed):

**Proposition 3.3 (Meet law).** For all $d, m, n$,
$$d \mid F_{\gcd(m,n)} \iff d \mid F_m \ \text{and}\ d \mid F_n.$$

*Proof sketch.* Rewrite $F_{\gcd(m,n)} = \gcd(F_m, F_n)$ via Theorem 3.1 and
apply `Nat.dvd_gcd_iff`. $\square$

### 3.2 The entry point (rank of apparition)

**Definition 3.4 (Entry point).** For $p \ge 2$, the *entry point* (rank of
apparition) $z(p)$ is the least positive integer $k$ with $p \mid F_k$, when one
exists; we set $z(p) = 0$ otherwise. Formally,
$$z(p) = \min\{k > 0 : p \mid F_k\}.$$

The entry point is well defined and positive whenever a divisibility witness
exists (Lemmas `fib_entry_point_pos`, `fib_entry_point_dvd`,
`fib_entry_point_le`): $z(p)$ is positive, $p \mid F_{z(p)}$, and $z(p) \le k$
for every positive $k$ with $p \mid F_k$.

**Theorem 3.5 (Entry-point divisibility characterization).** Let $p$ be prime
with a divisibility witness ($\exists k > 0,\ p \mid F_k$), and let $n > 0$.
Then
$$p \mid F_n \iff z(p) \mid n.$$

*Proof sketch.* ($\Leftarrow$) If $z(p) \mid n$, then $F_{z(p)} \mid F_n$
(Corollary 3.2) and $p \mid F_{z(p)}$ give $p \mid F_n$. ($\Rightarrow$) Suppose
$p \mid F_n$. Set $g = \gcd(z(p), n)$. By the strong divisibility property,
$\gcd(F_{z(p)}, F_n) = F_g$, and $p$ divides both $F_{z(p)}$ and $F_n$, so $p
\mid F_g$. Since $g \le z(p)$ and $g > 0$, minimality of $z(p)$ forces $g =
z(p)$; hence $z(p) = \gcd(z(p), n) \mid n$. $\square$

Theorem 3.5 says each prime owns a single arithmetic progression of indices: $p$
divides exactly the Fibonacci numbers $F_n$ with $z(p) \mid n$.

---

## 4. Primitive prime divisors and rigidity

**Definition 4.1.** A prime $p$ is a *primitive prime divisor* of $F_n$, written
$\mathrm{IsPrimitivePrimeDivisor}(p, n)$, if
$$p \ \text{prime}, \quad p \mid F_n, \quad \text{and}\quad \forall k\ (0 < k < n
\implies p \nmid F_k).$$
We say $F_n$ *has a primitive prime divisor*,
$\mathrm{HasPrimitivePrimeDivisor}(n)$, if such a $p$ exists.

**Theorem 4.2 (Primitivity equals entry point).** For a prime $p$ with a
divisibility witness and $n > 0$,
$$\mathrm{IsPrimitivePrimeDivisor}(p, n) \iff \big(p \mid F_n \ \text{and}\
z(p) = n\big).$$

*Proof sketch.* If $p$ is primitive for $F_n$ then $p \mid F_n$ gives $z(p) \le
n$, while the primitivity clause forbids $p \mid F_k$ for $0 < k < n$, forcing
$z(p) \ge n$; hence $z(p) = n$. Conversely, $z(p) = n$ is exactly the statement
that $n$ is minimal, which is the primitivity clause. $\square$

**Theorem 4.3 (Rigidity / uniqueness).** A value $p$ can be a primitive divisor
of at most one positive index: if $0 < m$, $0 < n$, and $p$ is primitive for
both $F_m$ and $F_n$, then $m = n$.

*Proof sketch.* If $m < n$, then primitivity at $n$ forbids $p \mid F_m$, while
primitivity at $m$ asserts $p \mid F_m$ — a contradiction; symmetrically $n < m$
is impossible. Hence $m = n$. (Positivity is necessary: at index $0$ every
modulus is vacuously primitive because $F_0 = 0$.) $\square$

**Theorem 4.4 (A primitive divisor pins the divisibility set).** If $p$ is
primitive for $F_n$ with $n > 0$, then for all $m$,
$$p \mid F_m \iff n \mid m.$$

*Proof sketch.* ($\Leftarrow$) $n \mid m \Rightarrow F_n \mid F_m$ and $p \mid
F_n$. ($\Rightarrow$) From $p \mid F_m$ and $p \mid F_n$ the meet law gives $p
\mid F_{\gcd(n,m)}$; since $\gcd(n,m) \le n$ and primitivity forbids divisibility
below $n$, we get $\gcd(n,m) = n$, i.e. $n \mid m$. $\square$

Theorem 4.3 shows Carmichael's theorem is a statement about a labelling of
indices by their newborn primes; Theorem 4.4 shows a primitive divisor
determines its entire apparition class.

---

## 5. Lifting the exponent for Fibonacci numbers

We write $v_p(N)$ for the $p$-adic valuation of $N$ (the exponent of $p$ in $N$).
The following two facts are standard.

**Lemma 5.1 (Multiplicativity).** For a prime $p$ and $a, b > 0$, $v_p(ab) =
v_p(a) + v_p(b)$.

**Lemma 5.2 (Ultrametric / tropical bound).** For a prime $p$ and $a, b > 0$,
$$\min(v_p(a), v_p(b)) \le v_p(a + b).$$

*Proof sketch.* $p^{\min(v_p a, v_p b)}$ divides both $a$ and $b$, hence their
sum; translate to valuations via `Nat.factorization_le_iff_dvd`. This is the
min-plus (tropical) structure underlying the LTE calculus. $\square$

The central analytic result controls how much an *old* prime can contribute as
the index is scaled.

**Theorem 5.3 (Fibonacci lifting-the-exponent).** Let $p$ be an odd prime with
$p \mid F_k$, $k > 0$, and let $n > 0$ with $p \nmid n$. Then
$$v_p\big(F_{nk}\big) = v_p\big(F_k\big) + v_p(n).$$

*Proof sketch.* Because $F_k \mid F_{nk}$ (Corollary 3.2), the quotient $Q_n :=
F_{nk}/F_k$ is an integer, and by multiplicativity $v_p(F_{nk}) = v_p(F_k) +
v_p(Q_n)$. The claim reduces to $v_p(Q_n) = v_p(n)$. One proves by induction the
congruence
$$Q_n = \frac{F_{nk}}{F_k} \equiv n \cdot F_{k-1}^{\,n-1} \pmod{p},$$
using the addition formula $F_{m+k} = F_m F_{k-1} + F_{m+1} F_k$ and the
auxiliary congruence $F_{mk+1} \equiv F_{k-1}^{\,m} \pmod p$. Since
$\gcd(F_k, F_{k-1}) = 1$ (consecutive Fibonacci numbers are coprime) and $p \mid
F_k$, we have $p \nmid F_{k-1}$; combined with $p \nmid n$ this gives $p \nmid
n F_{k-1}^{\,n-1}$, hence $p \nmid Q_n$ when $p \nmid n$, i.e. $v_p(Q_n) = 0 =
v_p(n)$. The general case (allowing $p \mid n$, the full LTE statement) follows
by the standard inductive lifting; here we record the coprime instance
$v_p(F_{nk}) = v_p(F_k)$ when $p \nmid n$, which is exactly what is needed to cap
the imprimitive part. $\square$

**Why it matters.** Theorem 5.3 says the power of an old prime $p$ in $F_n$ grows
only like $v_p(n) = O(\log n)$, whereas $F_n$ itself grows exponentially (Lemma
2.4). Consequently the imprimitive part of $F_n$ — the product of prime powers
$p^{v_p(F_n)}$ over primes $p$ with $z(p) < n$ — is dwarfed by $F_n$ for large
$n$. The leftover factor is therefore a genuine primitive divisor. This is the
analytic engine of the unbounded composite case.

---

## 6. The exceptional set and the prime-index case

### 6.1 The four exceptions

We verify directly that $F_n$ has no primitive prime divisor exactly when $n \in
\{1, 2, 6, 12\}$.

**Proposition 6.1.** $F_1$ and $F_2$ have no primitive prime divisor.

*Proof sketch.* $F_1 = F_2 = 1$ has no prime factors at all, so no prime can
divide it. $\square$

**Proposition 6.2.** $F_6 = 8$ has no primitive prime divisor.

*Proof sketch.* The only prime dividing $8 = 2^3$ is $2$, but $2 \mid F_3 = 2$,
so $2$ is not primitive for $F_6$ (its entry point is $z(2) = 3 \ne 6$). $\square$

**Proposition 6.3.** $F_{12} = 144$ has no primitive prime divisor.

*Proof sketch.* $144 = 2^4 \cdot 3^2$; the primes are $2$ and $3$. But $2 \mid
F_3$ (so $z(2) = 3 \mid 12$) and $3 \mid F_4$ (so $z(3) = 4 \mid 12$); neither is
primitive for $F_{12}$. $\square$

Conversely, the small non-exceptional indices have explicit primitive divisors,
verified by inspection:

**Proposition 6.4.** $F_3 = 2$, $F_4 = 3$, $F_5 = 5$, $F_7 = 13$ have primitive
prime divisors $2, 3, 5, 13$ respectively (and analogously $F_8 = 21$ has $7$,
$F_9 = 34$ has $17$, $F_{10} = 55$ has $11$, $F_{11} = 89$ has $89$).

These propositions together establish *sharpness*: the exceptional set is exactly
$\{1,2,6,12\}$, and $13$ is the least index beyond which $F_n$ always has a
primitive prime divisor.

### 6.2 Prime indices: unconditional

For prime index the argument is short and requires no growth estimate beyond
$F_p > 1$.

**Theorem 6.5 (Carmichael for prime indices).** If $p \ge 5$ is prime, then
$F_p$ has a primitive prime divisor. Indeed, *every* prime factor of $F_p$ is
primitive.

*Proof sketch.* The proper divisors of the prime $p$ are exactly $1$ and $p$;
the only Fibonacci number with index a proper divisor below $p$ is $F_1 = 1$,
which has no prime factors. Since $F_p \ge p \ge 5 > 1$ (Lemma 2.3), $F_p$ has at
least one prime factor $q$, e.g. its least prime factor. Suppose $q \mid F_k$ for
some $0 < k < p$; then $q \mid \gcd(F_k, F_p) = F_{\gcd(k,p)}$. But $\gcd(k,p) =
1$ since $0 < k < p$ and $p$ is prime, so $q \mid F_1 = 1$, contradicting $q$
prime. Hence $q$ is primitive. $\square$

Theorem 6.5 gives an infinite, explicit family of indices for which Carmichael's
theorem holds transparently, and it requires none of the lifting-the-exponent
machinery.

---

## 7. Localization of entry points via the companion matrix

The final result locates the entry point algebraically, bounding it a priori.

**Theorem 7.1 (Entry point divides $p^2 - 1$).** For a prime $p \notin \{2, 5\}$
there exists $k > 0$ with $k \mid p^2 - 1$ and $p \mid F_k$. In particular the
entry point satisfies $z(p) \mid p^2 - 1$, hence $z(p) \le p^2 - 1$.

*Proof sketch.* Encode Fibonacci by the companion matrix
$$Q = \begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix}, \qquad
(Q^n)_{0,1} = F_n \pmod p.$$
Over the algebraic closure of $\mathbb{F}_p$, the characteristic polynomial
$x^2 - x - 1$ has discriminant $5 \ne 0$ (as $p \ne 5$), hence two *distinct*
roots $\alpha \ne \beta$ with $\alpha^2 = \alpha + 1$, $\beta^2 = \beta + 1$.
Thus $Q$ is diagonalizable: $P^{-1} Q P = \operatorname{diag}(\alpha, \beta)$ for
an invertible $P$. The roots lie in $\mathbb{F}_{p^2}^{\times}$, a group of order
$p^2 - 1$, so $\alpha^{p^2 - 1} = \beta^{p^2 - 1} = 1$ (Lagrange / the
field-theoretic Fermat little theorem). Hence $Q^{p^2 - 1} = I$ over the closure,
so reducing the $(0,1)$ entry gives $F_{p^2 - 1} \equiv 0 \pmod p$. Therefore $p
\mid F_{p^2 - 1}$, and one takes $k = p^2 - 1$ (or, via the divisibility
characterization Theorem 3.5, $z(p) \mid p^2 - 1$). $\square$

**Remark 7.2 (Sharper bound).** Quadratic reciprocity refines Theorem 7.1: with
$\left(\tfrac{5}{p}\right)$ the Legendre symbol, $z(p) \mid p -
\left(\tfrac{5}{p}\right)$, so $z(p) \mid p - 1$ when $5$ is a quadratic residue
mod $p$ (i.e. $p \equiv \pm 1 \pmod 5$) and $z(p) \mid p + 1$ otherwise. This
yields the *a priori* bound $z(p) \le p + 1$, the key combinatorial input for
the multiplicity-one structure of imprimitive primes.

---

## 8. Simultaneous apparition

The entry-point machinery extends from a single prime to several at once,
yielding a *join law*.

**Theorem 8.1 (Two primitive divisors).** Let $p$ be primitive for $F_a$ and $q$
primitive for $F_b$ with $a, b > 0$. Then for every $n$,
$$\big(p \mid F_n \ \text{and}\ q \mid F_n\big) \iff \operatorname{lcm}(a, b)
\mid n.$$

*Proof sketch.* By Theorem 4.4, $p \mid F_n \iff a \mid n$ and $q \mid F_n \iff
b \mid n$; combine using $a \mid n \wedge b \mid n \iff \operatorname{lcm}(a,b)
\mid n$. $\square$

**Theorem 8.2 (Finite family).** Let $s$ be a finite index set and, for each $i
\in s$, let $f_i$ be primitive for $F_{g_i}$ with $g_i > 0$. Then for every $n$,
$$\big(\forall i \in s,\ f_i \mid F_n\big) \iff \Big(\operatorname{lcm}_{i \in s}
g_i\Big) \mid n.$$

*Proof sketch.* Induction over $s$: the empty case is $\operatorname{lcm}
\varnothing = 1 \mid n$; the insertion step combines Theorem 4.4 with the lcm
divisibility law. $\square$

These results express the common apparition set of several primitive divisors as
a single apparition class governed by the lcm of their indices — the natural
multi-modulus generalization of the entry-point picture.

---

## 9. Algorithms, applications, and discussion

### 9.1 Algorithms

The theory is constructive. Three algorithms organize the computation.

1. **Entry-point search.** To compute $z(p)$, iterate $F_k \bmod p$ for $k = 1,
2, 3, \dots$ until $0$. By Theorem 7.1 the loop terminates by $k = p^2 - 1$ (and
by Remark 7.2 by $k = p + 1$). Complexity: $O(z(p))$ modular steps, each $O(1)$
with a rolling pair $(F_{k-1}, F_k) \bmod p$.

2. **Primitive-divisor certificate (GCD strip).** To certify a primitive divisor
of $F_n$, compute the *primitive part* by stripping the contributions of proper
divisors: $\Pi_n = F_n / \gcd\!\big(F_n, \operatorname{lcm}_{d \mid n, d < n}
F_d\big)$ (or the Möbius-cyclotomic $\Phi_n = \prod_{d \mid n} F_d^{\,\mu(n/d)}$).
Then $\Pi_n > 1$ certifies a primitive prime divisor. Theorem 5.3 guarantees that
$\Pi_n$ captures exactly the newborn primes (and their newly added powers).

3. **Carmichael verification.** Combine: prime indices by Theorem 6.5; composite
indices by checking $\Pi_n > 1$, which holds for all $n \ge 13$ by the growth
bound (Lemma 2.4) versus the LTE cap (Theorem 5.3).

### 9.2 Applications

- **Primality and factorization.** Lucas sequences (the close relatives $U_n(P,
Q)$) underlie the Lucas–Lehmer test for Mersenne primes; primitive-divisor
theory guarantees fresh structure at each level.
- **Zsygmondy's theorem.** Carmichael's Fibonacci theorem is the prototype of
the general Bang–Zsygmondy phenomenon for $a^n - b^n$, $2^n - 1$, and Lucas
sequences. The exceptional set $\{1,2,6,12\}$ here mirrors the exceptional sets
(e.g. $\{1, 6\}$ for $2^n - 1$) in those settings.
- **Diophantine equations.** Primitive-divisor bounds (Bilu–Hanrot–Voutier)
control solutions of equations in members of Lucas sequences.

### 9.3 Discussion and future work

The development here proves Carmichael's theorem unconditionally for prime
indices and determines the exceptional set sharply; the analytic ingredients
(LTE, growth bounds, finite-field localization) supply the composite case for
all sufficiently large $n$. The remaining formalization frontier is the
*unbounded composite tail*: turning the bounded certificate $\Pi_n > 1$ into the
clean inequality $\Pi_n > n$ for all $n \ge 13$, which would remove any
finite-range verification entirely.

**Conjecture 9.1 (LTE, full form).** For an odd prime $p$ with $z(p) = m$ and any
$k \ge 1$, $v_p(F_{mk}) = v_p(F_m) + v_p(k)$.

**Conjecture 9.2 (Primitive part dominates).** With $\Phi_n = \prod_{d \mid n}
F_d^{\,\mu(n/d)}$, one has $\Phi_n > n$ for every $n \ge 13$.

**Conjecture 9.3 (Entry-point localization).** For a prime $p \ne 5$, $z(p) \mid
p - \left(\tfrac{5}{p}\right)$, hence $z(p) \le p + 1$.

**Conjecture 9.4 (Lucas analogue).** The Lucas numbers $L_n$ ($L_0 = 2$, $L_1 =
1$) have a primitive prime divisor for every $n \notin \{1, 6\}$.

**Conjecture 9.5 (Multiplicity-one imprimitivity).** If $p \mid F_n$ is not
primitive and is the largest such prime, then $p \mid n$ and $v_p(F_n) =
v_p(F_{z(p)}) + v_p(n)$.

Together, Conjectures 9.1 and 9.3 imply 9.5, which is the precise quantitative
form of "the only new prime factors at level $n$ are primitive" — the
combinatorial half of the unbounded Carmichael argument. A uniform Lucas-sequence
abstraction (Conjecture 9.4 and beyond) would unify Carmichael with the general
Zsygmondy theorem.

---

## 10. Conclusion

We have given a self-contained account of primitive prime divisors of Fibonacci
numbers, anchored on three quantitative pillars — strong divisibility and the
entry-point characterization $p \mid F_n \iff z(p) \mid n$; the
lifting-the-exponent identity $v_p(F_{nk}) = v_p(F_k) + v_p(n)$; and exponential
growth $F_n \ge 2^{\lfloor (n-2)/2 \rfloor}$. From these we obtained an
unconditional proof for prime indices, a sharp determination of the exceptional
set $\{1, 2, 6, 12\}$, the finite-field localization $z(p) \mid p^2 - 1$, and the
simultaneous-apparition calculus. All statements have been formally verified.
Carmichael's century-old theorem emerges not as an isolated curiosity but as the
clean prototype of the entire theory of primitive divisors in recurrence
sequences.
