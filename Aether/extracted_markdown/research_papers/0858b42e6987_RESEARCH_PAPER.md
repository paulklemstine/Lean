# Strong Divisibility Sequences: A Single Axiom Unifying Fibonacci and Mersenne Primitive-Divisor Theory

## Abstract

A *strong divisibility sequence* is a sequence of natural numbers
$u : \mathbb{N} \to \mathbb{N}$ satisfying the single identity
$u_{\gcd(m,n)} = \gcd(u_m, u_n)$ for all $m, n$. We show that this one axiom is
the complete structural foundation underlying the classical theory of primitive
divisors and ranks of apparition. Without any further hypotheses about the
sequence, we derive: the weak divisibility law $m \mid n \Rightarrow u_m \mid u_n$;
a sharp *meet law* characterizing divisors of $u_{\gcd(m,n)}$; the *uniqueness* of
the primitive index of any modulus; a *pinning law* showing that a primitive
divisor at index $n$ divides exactly the terms at multiples of $n$; a *join law*
governing simultaneous apparitions of two (and of finitely many) primitive
divisors via least common multiples; and exact *counting/density* formulas for
apparition indices. We instantiate the abstract theory at two concrete sequences —
the Fibonacci sequence $F_n$ and the Mersenne-type family $u_n = a^n - 1$ — thereby
recovering the entire Fibonacci primitive-divisor theory and producing the
analogous Mersenne theory simultaneously and for free. The unifying message is
that the "rank of apparition" is a property of one gcd identity rather than of any
particular sequence. All results have been formalized and machine-verified.

**Keywords:** strong divisibility sequence, primitive divisor, rank of apparition,
Fibonacci numbers, Mersenne numbers, Lucas sequence, gcd lattice, arithmetic
density.

---

## 1. Introduction

The Fibonacci sequence enjoys a remarkable arithmetic property discovered in the
19th century: the greatest common divisor of two Fibonacci numbers is itself a
Fibonacci number, indexed by the gcd of the original indices,
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$
An identical statement holds for the sequence $a^n - 1$ (the Mersenne numbers when
$a = 2$):
$$\gcd(a^m - 1,\ a^n - 1) = a^{\gcd(m,n)} - 1.$$
From such identities flows a rich classical theory: every term acquires new prime
factors ("primitive divisors") at well-defined indices ("ranks of apparition"),
those ranks behave periodically, and the joint apparition of several primes is
controlled by least common multiples. Historically this theory was developed
sequence-by-sequence — first for Fibonacci, then re-derived for Lucas sequences,
Mersenne numbers, and so on.

This paper isolates the precise hypothesis those developments actually require. We
abstract the gcd identity into a property of an arbitrary sequence and prove that
the *entire* primitive-divisor / apparition calculus follows from it alone. The
Fibonacci and Mersenne theories then appear as two instantiations of a single
abstract theory. The abstraction is not merely cosmetic: it pinpoints which facts
are *structural* (free from the gcd axiom) versus *quantitative* (depending on the
growth of $u_n$), and so clarifies exactly where deeper results such as
Carmichael's and Zsygmondy's theorems require genuinely new input.

### Contributions

1. A minimal axiomatization: `IsStrongDivSeq u :≡ ∀ m\, n,\ u_{\gcd(m,n)} = \gcd(u_m, u_n)$.
2. Ten generic theorems proved from this axiom alone (Sections 3–6), covering the
   meet law, uniqueness, the pinning law, the join law and its finite-family
   version, and exact counting formulas.
3. Two instantiations (Section 7): the Fibonacci sequence and the family
   $a^n - 1$, recovering and unifying their primitive-divisor theories.
4. A clean separation of structural from quantitative content, framing the open
   Carmichael/Zsygmondy direction (Section 9).

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, $\gcd$ and $\operatorname{lcm}$ are
the natural-number greatest-common-divisor and least-common-multiple, and $a \mid b$
denotes divisibility. We adopt the conventions $\gcd(0, n) = n$ and $\gcd(m, 0) = m$.

**Definition 2.1 (Strong divisibility sequence).**
A sequence $u : \mathbb{N} \to \mathbb{N}$ is a *strong divisibility sequence* if
$$\boxed{\,u_{\gcd(m,n)} = \gcd(u_m, u_n)\quad\text{for all } m, n \in \mathbb{N}.\,}$$
We write `IsStrongDivSeq u` for this property.

**Definition 2.2 (Primitive divisor / rank of apparition).**
For $p, n \in \mathbb{N}$, we say $p$ is a *primitive divisor* of $u$ at index $n$,
written `IsPrimitive u p n`, if
$$p \mid u_n \quad\text{and}\quad \forall k,\ (0 < k < n) \Rightarrow p \nmid u_k.$$
That is, $p$ divides the $n$-th term but none of the earlier positive-index terms.
The index $n$ is then called the *rank of apparition* of $p$.

These two definitions are the only primitives of the theory. Notably,
Definition 2.1 implies nothing about $u_0$ on its own; where the boundary value
matters (Theorem 4.1) we add the hypothesis $u_0 = 0$, which holds for all natural
instances.

---

## 3. Elementary consequences of the axiom

**Theorem 3.1 (Weak divisibility law — `IsStrongDivSeq.dvd_of_dvd`).**
If $u$ is a strong divisibility sequence and $m \mid n$, then $u_m \mid u_n$.

*Proof sketch.* Since $m \mid n$, we have $\gcd(m, n) = m$. Applying the axiom,
$u_m = u_{\gcd(m,n)} = \gcd(u_m, u_n)$. A greatest common divisor divides each of
its arguments, so $\gcd(u_m, u_n) \mid u_n$, hence $u_m \mid u_n$. $\qquad\blacksquare$

This shows every strong divisibility sequence is, in particular, an ordinary
*divisibility sequence*; the weak law is a free corollary of the strong one.

**Theorem 3.2 (Meet law — `IsStrongDivSeq.dvd_gcd_index_iff`).**
If $u$ is a strong divisibility sequence then for all $d, m, n$,
$$d \mid u_{\gcd(m,n)} \iff \big(d \mid u_m \ \text{and}\ d \mid u_n\big).$$

*Proof sketch.* Rewrite $u_{\gcd(m,n)}$ as $\gcd(u_m, u_n)$ via the axiom. The
universal property of gcd states precisely that $d \mid \gcd(u_m, u_n)$ iff $d$
divides both $u_m$ and $u_n$. $\qquad\blacksquare$

Theorem 3.2 is the lattice "meet" law at the level of raw divisors and is the
workhorse for the pinning and join laws below.

---

## 4. Rigidity of primitivity

**Theorem 4.1 (Index $0$ is vacuously primitive — `isPrimitive_zero_everything`).**
If $u_0 = 0$ then for every $p$, `IsPrimitive u p 0` holds.

*Proof sketch.* Since $u_0 = 0$ and every number divides $0$, the first clause
$p \mid u_0$ holds. The minimality clause quantifies over $k$ with $0 < k < 0$,
which is vacuous. $\qquad\blacksquare$

This explains why positivity of the index is the natural hypothesis everywhere
below: index $0$ is primitive for *every* modulus and so must be excluded from any
uniqueness statement.

**Theorem 4.2 (Uniqueness of the rank — `isPrimitive_unique`).**
If $0 < m$, $0 < n$, and $p$ is primitive at both $m$ and $n$, then $m = n$.

*Proof sketch.* Suppose $m \ne n$; without loss of generality $m < n$. Primitivity
at $n$ requires $p \nmid u_k$ for all $k$ with $0 < k < n$; taking $k = m$ gives
$p \nmid u_m$. But primitivity at $m$ asserts $p \mid u_m$ — a contradiction.
Remarkably, this argument uses *only* Definition 2.2 and not the gcd axiom:
primitivity is so rigid that uniqueness is immediate. $\qquad\blacksquare$

---

## 5. The pinning law

**Theorem 5.1 (Pinning law — `dvd_iff_index_dvd_of_primitive`).**
Let $u$ be a strong divisibility sequence, let $0 < n$, and suppose $p$ is
primitive at $n$. Then for all $m$,
$$p \mid u_m \iff n \mid m.$$

*Proof sketch.*
($\Leftarrow$) If $n \mid m$ then $u_n \mid u_m$ by the weak divisibility law
(Theorem 3.1). Since $p \mid u_n$, transitivity gives $p \mid u_m$.

($\Rightarrow$) Suppose $p \mid u_m$. Also $p \mid u_n$. By the meet law
(Theorem 3.2), $p \mid u_{\gcd(n,m)}$. Now $\gcd(n,m) \le n$ and $\gcd(n,m) > 0$
(as $n > 0$). If $\gcd(n,m) < n$, then by primitivity at $n$ we would have
$p \nmid u_{\gcd(n,m)}$, a contradiction. Hence $\gcd(n,m) = n$, i.e. $n \mid m$.
$\qquad\blacksquare$

Theorem 5.1 upgrades the abstract apparition relation into a concrete, fully
periodic divisibility test: a primitive divisor at index $n$ divides exactly the
terms whose index is a multiple of $n$.

---

## 6. The join law and counting

**Theorem 6.1 (Join law — `simultaneous_apparition`).**
Let $u$ be a strong divisibility sequence with $0 < a$, $0 < b$, $p$ primitive at
$a$, and $q$ primitive at $b$. Then for all $n$,
$$\big(p \mid u_n \ \text{and}\ q \mid u_n\big) \iff \operatorname{lcm}(a,b) \mid n.$$

*Proof sketch.* By the pinning law, $p \mid u_n \iff a \mid n$ and
$q \mid u_n \iff b \mid n$. Their conjunction is "$n$ is a common multiple of $a$
and $b$," equivalent to $\operatorname{lcm}(a,b) \mid n$ by the universal property
of lcm. $\qquad\blacksquare$

**Theorem 6.2 (Finite-family join law — `simultaneous_apparition_finset`).**
Let $u$ be a strong divisibility sequence, $s$ a finite index set, and
$f, g : \iota \to \mathbb{N}$ with $g_i > 0$ and $f_i$ primitive at $g_i$ for every
$i \in s$. Then for all $n$,
$$\Big(\forall i \in s,\ f_i \mid u_n\Big) \iff \operatorname{lcm}_{i \in s} g_i \ \big|\ n.$$

*Proof sketch.* By induction on $s$ using `Finset.lcm`. For the forward direction,
each $f_i \mid u_n$ gives $g_i \mid n$ (pinning law), and a number divisible by
every $g_i$ is divisible by their lcm. Conversely, if the lcm divides $n$ then
$g_i \mid n$ for each $i$, so $f_i \mid u_n$ by pinning. The empty case uses
$\operatorname{lcm}(\varnothing) = 1 \mid n$. $\qquad\blacksquare$

**Theorem 6.3 (Apparition count — `apparition_count`).**
Let $u$ be a strong divisibility sequence, $0 < n$, and $p$ primitive at $n$. Then
for every $N$,
$$\#\{\,e \in \{0, \dots, N-1\} : p \mid u_{e+1}\,\} = \left\lfloor \frac{N}{n} \right\rfloor.$$

*Proof sketch.* By the pinning law the predicate $p \mid u_{e+1}$ is equivalent to
$n \mid (e+1)$. The number of integers in $\{1, \dots, N\}$ divisible by $n$ is
exactly $\lfloor N/n \rfloor$ (a standard counting lemma). $\qquad\blacksquare$

The $+1$ shift excludes index $0$ (where everything divides), aligning the count
with the standard "number of multiples up to $N$" formula. Theorem 6.3 says the
*natural density* of the apparition indices of a primitive divisor at index $n$ is
exactly $1/n$.

**Theorem 6.4 (Joint apparition count — `simultaneous_apparition_count`).**
Under the hypotheses of Theorem 6.1, for every $N$,
$$\#\{\,e \in \{0, \dots, N-1\} : p \mid u_{e+1} \ \text{and}\ q \mid u_{e+1}\,\}
= \left\lfloor \frac{N}{\operatorname{lcm}(a,b)} \right\rfloor.$$

*Proof sketch.* By the join law the joint predicate is equivalent to
$\operatorname{lcm}(a,b) \mid (e+1)$; apply the same multiples-counting lemma as in
Theorem 6.3. $\qquad\blacksquare$

The joint apparition density is thus $1/\operatorname{lcm}(a,b)$ — a direct bridge
from the apparition lattice to arithmetic density.

---

## 7. Concrete instances

**Theorem 7.1 (Fibonacci — `fib_isStrongDivSeq`).**
The Fibonacci sequence $F : \mathbb{N} \to \mathbb{N}$ is a strong divisibility
sequence.

*Proof sketch.* This is exactly the classical identity
$F_{\gcd(m,n)} = \gcd(F_m, F_n)$. $\qquad\blacksquare$

Consequently every theorem of Sections 3–6 specializes to Fibonacci, recovering
the full classical apparition theory: uniqueness of the Fibonacci rank of
apparition, the periodicity $p \mid F_m \iff \operatorname{rank}(p) \mid m$, the
lcm-governed simultaneous apparitions, and the $1/n$ density of apparition indices.

**Theorem 7.2 (Mersenne / $a^n - 1$ — `mersenne_isStrongDivSeq`).**
For every base $a \in \mathbb{N}$, the sequence $u_n = a^n - 1$ is a strong
divisibility sequence.

*Proof sketch.* This is the identity
$\gcd(a^m - 1,\ a^n - 1) = a^{\gcd(m,n)} - 1$ (with the degenerate base $a = 0$
checked directly). $\qquad\blacksquare$

Therefore the *identical* theorems hold verbatim for $a^n - 1$. In particular, for
$a = 2$ we obtain a complete primitive-divisor and apparition theory for the
Mersenne numbers: each prime $p$ has a unique rank $n$ (its multiplicative order
issues aside, this is the index where $p$ debuts), $p \mid 2^m - 1$ exactly at the
multiples of that rank, two primes co-appear at the lcm of their ranks, and the
densities are $1/n$ and $1/\operatorname{lcm}(a,b)$ respectively. The Fibonacci and
Mersenne theories are literally the same theorems applied to two instances.

A third trivial instance, the identity sequence $u_n = n$, also satisfies the axiom
and provides a useful sanity check: here every prime $p$ is primitive at index $p$,
the pinning law reduces to $p \mid m \iff p \mid m$, and the density of multiples
of $p$ is $1/p$.

---

## 7b. Worked numerical examples

To make the abstract theory tangible, we trace its statements through concrete
integers in both instances.

**Fibonacci (Theorem 7.1).** The first Fibonacci numbers are
$F_1, F_2, \dots = 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, \dots$.
Consider the prime $p = 11$. Scanning, $11 \nmid F_k$ for $k < 10$ but
$11 \mid F_{10} = 55$, so the rank of apparition of $11$ is $10$, and $11$ is
primitive at index $10$ (Definition 2.2). The pinning law (Theorem 5.1) then
asserts $11 \mid F_m \iff 10 \mid m$; indeed $11$ divides exactly
$F_{10} = 55, F_{20} = 6765, F_{30} = 832040, \dots$ and no other Fibonacci
numbers. The meet law is visible in $\gcd(F_{12}, F_{18}) = \gcd(144, 2584) = 8 =
F_6 = F_{\gcd(12,18)}$.

Now add $q = 13$, which first divides $F_7 = 13$, so its rank is $7$. The join law
(Theorem 6.1) predicts that $11$ and $13$ first co-occur at index
$\operatorname{lcm}(10, 7) = 70$, and recur at every multiple of $70$. Direct
computation confirms $F_{70}$ is the smallest Fibonacci number divisible by both.
The counting law (Theorem 6.3) predicts that among the first $N = 1000$ indices,
$11$ appears $\lfloor 1000/10 \rfloor = 100$ times and $13$ appears
$\lfloor 1000/7 \rfloor = 142$ times; their joint appearances number
$\lfloor 1000/70 \rfloor = 14$ (Theorem 6.4). All three counts agree exactly with
brute-force enumeration.

**Mersenne (Theorem 7.2).** Take $a = 2$, so $u_n = 2^n - 1$ gives
$1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, \dots$. The meet law reads
$\gcd(2^{12} - 1, 2^{18} - 1) = \gcd(4095, 262143) = 63 = 2^6 - 1 =
2^{\gcd(12,18)} - 1$. The weak law gives $2^3 - 1 = 7 \mid 2^6 - 1 = 63$ because
$3 \mid 6$. Every structural statement that held for Fibonacci holds here with the
identical proof — this is the unification in action: the rank of apparition of a
prime $p$ in $2^n - 1$ is exactly the multiplicative order of $2$ modulo $p$, and
the pinning law recovers the classical fact that $p \mid 2^m - 1$ precisely when
that order divides $m$.

The trivial instance $u_n = n$ provides a degenerate sanity check: every prime $p$
is primitive at index $p$, the pinning law collapses to the tautology
$p \mid m \iff p \mid m$, and the apparition density $1/p$ matches the density of
multiples of $p$ among the integers.

## 8. Algorithms and applications

The constructive content of the theory yields simple, efficient algorithms.

**Rank of apparition.** To compute the rank of a modulus $p$ in a strong
divisibility sequence, scan $n = 1, 2, 3, \dots$ and return the first $n$ with
$p \mid u_n$. Theorem 4.2 guarantees this is well-defined, and Theorem 5.1
guarantees that once found, the full divisibility pattern is the arithmetic
progression $\{n, 2n, 3n, \dots\}$ — so no further scanning is ever needed.

**Membership test.** To decide whether $p \mid u_m$ for arbitrary large $m$,
compute the rank $n$ once, then test $n \mid m$ — an $O(1)$ check replacing direct
computation of the (possibly astronomically large) term $u_m$.

**Joint apparition.** To find where primes $p$ and $q$ first co-appear, compute
their ranks $a, b$ and return $\operatorname{lcm}(a, b)$ (Theorem 6.1).

**Counting / density.** To count apparition indices below $N$, return
$\lfloor N/n \rfloor$ (Theorem 6.3); for joint apparitions,
$\lfloor N/\operatorname{lcm}(a,b)\rfloor$ (Theorem 6.4). These give exact answers
without enumeration.

Applications include: fast factor-pattern prediction for Fibonacci and
Mersenne-type numbers; analysis of cycle structure in linear-feedback and
pseudorandom generators (whose periods are governed by $a^n - 1$ type sequences);
and a uniform framework for teaching apparition theory across multiple sequences at
once.

---

## 9. Discussion and future work

The principal conceptual outcome is a *separation of concerns*. Every theorem in
Sections 3–6 is **structural**: it follows from the gcd axiom alone and says
nothing about how large the terms are. By contrast, the famous existence results —
Carmichael's theorem (every Fibonacci number past a small exceptional set has a
primitive divisor) and Zsygmondy's theorem (its analogue for $a^n - 1$ and more
general Lucas sequences) — are **quantitative**: they assert that the supply of new
primes never dries up, which depends on lower bounds for the cyclotomic-type
"primitive part" of $u_n$, not merely on the divisibility lattice.

This suggests a clean path forward.

**Direction 1 — A generic cyclotomic lower bound.** State and prove, for strong
divisibility sequences of *Lucas type* (those arising from $(\alpha^n - \beta^n)/
(\alpha - \beta)$ with $|\alpha| > 1 \ge |\beta|$ and $\alpha\beta = \pm 1$), the
inequality $\Phi_n > n$ for all but finitely many $n$, where
$\Phi_n = \prod_{d \mid n} u_d^{\mu(n/d)}$ is the Möbius-defined primitive part.
Combined with the structural results above (in particular the characterization of
primitivity via the rank), such a single quantitative bound discharges the
existence-of-primitive-divisor tail uniformly. The key observation is that the
obstruction to a primitive divisor is *exactly one* intrinsic prime, dividing
$\Phi_n$ to the first power and bounded by $n$; a bound $\Phi_n > n$ — far weaker
than the full strength of Carmichael's original argument — therefore suffices, and
that bound is a property of the sequence's growth, not of any particular instance.

**Direction 2 — Beyond Lucas type.** Identify the broadest class of strong
divisibility sequences (elliptic divisibility sequences, sequences from algebraic
groups) for which a primitive-part growth bound holds, giving a single theorem that
specializes to Fibonacci, Mersenne, and elliptic cases simultaneously.

**Direction 3 — Density refinements.** The counting formulas (Theorems 6.3–6.4)
give exact finite counts. A natural extension is to average over moduli and obtain
mean apparition densities, connecting the apparition lattice to analytic number
theory (e.g. average orders and the distribution of ranks).

**Direction 4 — Effective bounds and computation.** Turn the structural algorithms
of Section 8 into certified, complexity-analyzed routines, and tabulate ranks of
apparition for the Fibonacci and Mersenne families to large bounds as empirical
input to Direction 1.

---

## 10. Conclusion

A single equation, $u_{\gcd(m,n)} = \gcd(u_m, u_n)$, is the entire structural
backbone of primitive-divisor and apparition theory. From it we derive — with no
further hypotheses — the weak divisibility law, the meet law, uniqueness of ranks,
the pinning law, the join law and its finite-family form, and exact counting
formulas. The Fibonacci numbers and the Mersenne-type family $a^n - 1$ are merely
two instances of this one axiom, and so share a single theory. The "rank of
apparition" is revealed not as a fact about the golden ratio or powers of two, but
as a fact about one gcd identity. What remains genuinely hard — the eventual
existence of primitive divisors — is precisely the quantitative residue that the
axiom does not see, and is the natural target for future work.
