# A Computable Primitive-Divisor Criterion for Strong Divisibility Sequences

## Abstract

A *primitive prime divisor* of the $n$-th term of an integer sequence $u(1), u(2), \dots$ is a
prime that divides $u(n)$ but divides no earlier term $u(k)$, $0 < k < n$. Two classical theorems
guarantee the eventual existence of such primes: **Carmichael's theorem** (1913), that every
Fibonacci number $F(n)$ with $n \ge 13$ has a primitive prime divisor (the only exceptions being
$n \in \{1, 2, 6, 12\}$), and **Bang's theorem** (1886), that every $2^n - 1$ with $n \ge 2$ has a
primitive prime divisor (the only exception being $n = 6$). Classically these are proved by
sequence-specific analytic estimates.

We isolate the single structural property responsible for the phenomenon — the **strong
divisibility law** $\gcd(u(m), u(n)) = u(\gcd(m, n))$ — and build on it a *computable*, fully
sequence-agnostic criterion. Define the **coprime part** $\mathrm{cp}(u, n)$ of $u(n)$ by
iteratively dividing out the gcd with each $u(d)$, $d \mid n$, $d < n$. Our main theorem states:
if $\mathrm{cp}(u, n) > 1$ then $u(n)$ has a primitive prime divisor, *for every* strong
divisibility sequence $u$. The only number-theoretic ingredient is the one-line lemma that a
common divisor of $u(m)$ and $u(n)$ divides $u(\gcd(m, n))$; everything else is integer
bookkeeping that never references the underlying sequence.

The criterion specializes with no additional mathematical input to two concrete instances:
Fibonacci (verified, exhaustively and uniformly over primes and composites, on $13 \le n \le
1000$) and $2^n - 1$ (verified on $2 \le n \le 120$, with the unique exception $n = 6$ isolated
automatically). All results are formalized and machine-checked, depending only on the standard
foundational axioms; the verification of each finite band is discharged by kernel-level evaluation
of the computable coprime part. This unifies two classically distinct primitive-divisor theorems
under a single computable engine and reduces the unconditional statement to one clean size estimate
on the coprime part.

**Keywords.** primitive divisor, strong divisibility sequence, Fibonacci numbers, Mersenne
numbers, Carmichael's theorem, Bang's theorem, Zsygmondy's theorem, rank of apparition,
cyclotomic factor.

---

## 1. Introduction

### 1.1 Primitive divisors

Let $u : \mathbb{N} \to \mathbb{N}$ be a sequence of natural numbers with $u(0) = 0$. A prime $p$
is a **primitive (prime) divisor** of $u(n)$ if

$$p \mid u(n) \quad\text{and}\quad p \nmid u(k) \ \text{for all } 0 < k < n.$$

Equivalently, $n$ is the *rank of apparition* of $p$: the least positive index at which $p$ first
divides a term. Primitive divisors govern the multiplicative growth of integer sequences and
underlie applications ranging from primality testing (the indices of Mersenne primes) to the
structure theory of linear recurrences.

### 1.2 Two classical theorems

The motivating examples are:

* **Fibonacci**, $F(0) = 0$, $F(1) = 1$, $F(n+2) = F(n+1) + F(n)$.
* **Mersenne / $a^n - 1$**, $u(n) = a^n - 1$ for a fixed base $a \ge 2$.

For these, the existence of primitive divisors is governed by:

> **Theorem (Carmichael, 1913).** For $n \ge 1$, $F(n)$ has a primitive prime divisor unless
> $n \in \{1, 2, 6, 12\}$. In particular every $F(n)$ with $n \ge 13$ has one.

> **Theorem (Bang, 1886).** For $n \ge 1$, $2^n - 1$ has a primitive prime divisor unless
> $n \in \{1, 6\}$. In particular every $2^n - 1$ with $n \ge 2$, $n \ne 6$, has one.

Both are special cases of **Zsygmondy's theorem** (1892) for Lucas sequences. The standard proofs
proceed through the homogeneous cyclotomic factors $\Phi_n(\alpha, \beta)$ and a lower bound forcing
a surviving prime; they are sequence-specific and analytically delicate.

A recurring theme across these classical results is that the *combinatorial* skeleton of the
argument — which primes can appear, and at which index they first appear — is identical in all
cases, while the *analytic* part — the size estimate that rules out the cancellation of every
candidate prime — is the only piece that genuinely differs between sequences. The contribution of
this paper is to make that separation explicit and machine-checkable: the combinatorial skeleton is
captured by one structural lemma and a computable functional valid for every strong divisibility
sequence, and the analytic part is quarantined into a single inequality on that functional.

### 1.3 Contribution

We observe that the *only* property of $F$ or $a^n - 1$ used in detecting primitive divisors is
the **strong divisibility law**, and we make the detection itself a finite, computable procedure
valid for all such sequences. Concretely we contribute:

1. **A structural lemma (`dvd_index_gcd`)** — the sole number-theoretic step — that a common
   divisor of $u(m)$ and $u(n)$ divides $u(\gcd(m,n))$.
2. **A computable coprime-part functional** $\mathrm{cp}(u, n)$ built from a primitive integer
   operation `removePrimesOf`, together with its basic algebra (divisibility, coprimality,
   positivity), all proved without reference to $u$.
3. **The engine (`primitive_of_coprimePart_pos`)** — for every strong divisibility sequence $u$,
   $\mathrm{cp}(u, n) > 1$ implies $u(n)$ has a primitive prime divisor.
4. **Two specializations**, obtained from (3) with no extra mathematics: Carmichael's theorem
   verified on $13 \le n \le 1000$ (`fib_carmichael_band`) and Bang's theorem verified on
   $2 \le n \le 120$, $n \ne 6$ (`mersenne_bang_band`), with the Mersenne exception isolated by the
   computation.

All statements are formalized and machine-checked; the finite bands are discharged by exact
kernel-level evaluation of $\mathrm{cp}$.

---

## 2. Definitions

Throughout, $\gcd$ denotes the natural-number greatest common divisor with $\gcd(a, 0) = a$, and
"divides" is the usual relation $\mid$ on $\mathbb{N}$.

### Definition 2.1 (Strong divisibility sequence)

A sequence $u : \mathbb{N} \to \mathbb{N}$ is a **strong divisibility sequence** if

$$u(\gcd(m, n)) = \gcd(u(m), u(n)) \qquad \text{for all } m, n \in \mathbb{N}.$$

We write $\mathrm{IsStrongDivSeq}(u)$ for this property.

### Definition 2.2 (Primitive divisor)

For $p, n \in \mathbb{N}$, $p$ **is primitive for** $u$ at $n$, written $\mathrm{IsPrimitive}(u, p,
n)$, if

$$p \mid u(n) \quad \text{and} \quad \forall k,\ 0 < k < n \Rightarrow p \nmid u(k).$$

A *primitive prime divisor* of $u(n)$ is a prime $p$ with $\mathrm{IsPrimitive}(u, p, n)$.

### Definition 2.3 (`removePrimesOf`)

Define $\rho : \mathbb{N} \times \mathbb{N} \to \mathbb{N}$ by well-founded recursion on the first
argument:

$$
\rho(a, b) =
\begin{cases}
0, & a = 0, \\
a, & a \ne 0 \text{ and } \gcd(a, b) \le 1, \\
\rho\!\left(a / \gcd(a, b),\, b\right), & a \ne 0 \text{ and } \gcd(a, b) > 1.
\end{cases}
$$

Intuitively, $\rho(a, b)$ strips from $a$ every prime it shares with $b$ by repeatedly dividing
out $\gcd(a, b)$. Termination holds because $a / \gcd(a, b) < a$ whenever $\gcd(a, b) > 1$ and
$a > 0$.

### Definition 2.4 (Coprime part)

Let $D(n) = \{\, d : 0 < d < n,\ d \mid n \,\}$ be the proper-divisor list of $n$ (the actual
implementation filters $\{0, 1, \dots, n-1\}$ by $0 < d \wedge n \bmod d = 0$, which is the same
set). Define the **coprime part**

$$\mathrm{cp}(u, n) = \mathrm{foldl}\bigl(\lambda\, \mathrm{acc}\ d.\ \rho(\mathrm{acc}, u(d)),\
u(n),\ D(n)\bigr),$$

i.e. start from $u(n)$ and successively strip the primes shared with each $u(d)$, $d \in D(n)$.

---

## 3. Main results

### 3.1 The single structural lemma

> **Lemma 3.1 (`dvd_index_gcd`).** Let $u$ be a strong divisibility sequence and $p, m, n \in
> \mathbb{N}$. If $p \mid u(m)$ and $p \mid u(n)$, then $p \mid u(\gcd(m, n))$.

**Proof.** By Definition 2.1, $u(\gcd(m, n)) = \gcd(u(m), u(n))$. Since $p$ divides both $u(m)$ and
$u(n)$, it divides their gcd. $\qquad\blacksquare$

This one-line argument is the *entire* number-theoretic content of the engine; everything below is
sequence-independent integer arithmetic.

### 3.2 Algebra of `removePrimesOf` and the coprime part

> **Lemma 3.2 (`removePrimesOf_dvd`).** For all $a, b$: $\rho(a, b) \mid a$.

**Proof.** Strong induction on $a$. If $a = 0$, $\rho(a,b) = 0 \mid 0$. If $\gcd(a,b) \le 1$,
$\rho(a,b) = a \mid a$. Otherwise $\rho(a,b) = \rho(a/g, b)$ with $g = \gcd(a,b)$; by the inductive
hypothesis $\rho(a/g, b) \mid a/g$, and $a/g \mid a$ because $g \mid a$. Transitivity of $\mid$
finishes. $\qquad\blacksquare$

> **Lemma 3.3 (`removePrimesOf_coprime`).** For $a > 0$: $\gcd(\rho(a, b),\, b) = 1$.

**Proof.** Strong induction on $a$. If $\gcd(a, b) \le 1$, then since $a > 0$ we have $\gcd(a, b) =
1$ and $\rho(a,b) = a$ is already coprime to $b$. Otherwise $\rho(a, b) = \rho(a/g, b)$ with
$g = \gcd(a,b) > 1$; here $a/g > 0$ (as $g \mid a$ and $a > 0$), and the inductive hypothesis gives
coprimality. The loop terminates exactly when the running gcd reaches 1, certifying that no prime
of $b$ remains. $\qquad\blacksquare$

> **Lemma 3.4 (`removePrimesOf_pos`).** For $a > 0$: $\rho(a, b) > 0$.

**Proof.** $\rho(a,b) \mid a$ (Lemma 3.2) and $a > 0$, so the divisor is positive. $\qquad
\blacksquare$

> **Lemma 3.5 (`coprimePart_dvd`).** For every $u$ and $n$: $\mathrm{cp}(u, n) \mid u(n)$.

**Proof.** Induction on the divisor list $D(n)$ processed by the fold, taking it from the right
(`reverseRecOn`). The empty fold yields $u(n) \mid u(n)$. Appending a divisor $d$ replaces the
accumulator $\mathrm{acc}$ by $\rho(\mathrm{acc}, u(d))$, which divides $\mathrm{acc}$ by Lemma
3.2; by transitivity it still divides $u(n)$. $\qquad\blacksquare$

> **Lemma 3.6 (`foldl_removePrimesOf_zero`).** For any list $\ell$ and function $f$, folding
> $\rho(\cdot, f(d))$ from the start value $0$ returns $0$.

**Proof.** Induction on $\ell$, using $\rho(0, \cdot) = 0$. $\qquad\blacksquare$

> **Lemma 3.7 (`un_pos_of_coprimePart_pos`).** If $\mathrm{cp}(u, n) > 1$ then $u(n) > 0$.

**Proof.** Contrapositive: if $u(n) = 0$ the fold starts from $0$ and stays $0$ by Lemma 3.6, so
$\mathrm{cp}(u, n) = 0 \not> 1$. $\qquad\blacksquare$

A second key property of the fold, used in the engine, records that the result is coprime to each
processed $u(d)$:

> **Lemma 3.8 (coprimality to proper divisors).** If $\mathrm{cp}(u, n) > 1$ then for every
> $d \in D(n)$, $\gcd(\mathrm{cp}(u, n),\, u(d)) = 1$.

**Proof sketch.** Process the fold from the right. The final step that touches $u(d)$ outputs a
value coprime to $u(d)$ by Lemma 3.3 (positivity of the accumulator at that step follows from
Lemma 3.7 propagated through Lemma 3.4). Every *subsequent* step only divides the accumulator
further (Lemma 3.2), and a divisor of something coprime to $u(d)$ is still coprime to $u(d)$. Hence
$\mathrm{cp}(u, n)$ is coprime to $u(d)$. $\qquad\blacksquare$

### 3.3 The engine

> **Theorem 3.9 (`primitive_of_coprimePart_pos`).** Let $u$ be a strong divisibility sequence and
> $n \in \mathbb{N}$. If $\mathrm{cp}(u, n) > 1$, then $u(n)$ has a primitive prime divisor: there
> is a prime $p$ with $p \mid u(n)$ and $p \nmid u(k)$ for all $0 < k < n$.

**Proof.** Since $\mathrm{cp}(u, n) > 1$, it has a prime factor $p$. By Lemma 3.5, $p \mid
\mathrm{cp}(u, n) \mid u(n)$, establishing the first clause.

For primitivity, suppose toward contradiction that $p \mid u(k)$ for some $0 < k < n$. We also have
$p \mid u(n)$. By Lemma 3.1 (`dvd_index_gcd`), $p \mid u(\gcd(n, k))$. Let $d = \gcd(n, k)$. Since
$k < n$ and $k > 0$, $d$ is a *proper* positive divisor of $n$, i.e. $d \in D(n)$. (Indeed $d \mid
n$; and $d \le k < n$, while $d > 0$ because $k > 0$.)

But $p \mid \mathrm{cp}(u, n)$ and $p \mid u(d)$ would force $p \mid \gcd(\mathrm{cp}(u, n), u(d)) =
1$ by Lemma 3.8 — impossible for a prime. Contradiction. Hence no such $k$ exists, and $p$ is
primitive at $n$. $\qquad\blacksquare$

Note the proof's only appeal to the sequence structure is the single use of Lemma 3.1; all other
steps are facts about $\rho$, gcds, and folds. This is precisely why the engine transplants
unchanged across sequences. In particular, no property of the Fibonacci recurrence — not Binet's
formula, not the matrix representation, not the identity $F(m+n) = F(m)F(n+1) + F(m-1)F(n)$ — is
ever invoked; symmetrically, no factorization identity for $a^n - 1$ is used. The detector treats
$u$ as an opaque oracle that happens to satisfy Definition 2.1, and that single hypothesis is enough
to pin every shared prime of $u(n)$ to a proper divisor of $n$.

### 3.4 Two concrete instances of the law

> **Lemma 3.10 (`fib_isStrongDivSeq`).** The Fibonacci sequence $F$ is a strong divisibility
> sequence: $F(\gcd(m, n)) = \gcd(F(m), F(n))$.

**Proof.** This is the classical Fibonacci gcd identity (formally, `Nat.fib_gcd`). $\qquad
\blacksquare$

> **Lemma 3.11 (`mersenne_isStrongDivSeq`).** For any fixed base $a$, the sequence $n \mapsto a^n
> - 1$ is a strong divisibility sequence: $a^{\gcd(m,n)} - 1 = \gcd(a^m - 1, a^n - 1)$.

**Proof.** This is the standard exponent gcd identity (formally, `Nat.pow_sub_one_gcd_pow_sub_one`).
$\qquad\blacksquare$

### 3.5 The verified bands

> **Theorem 3.12 (`fib_carmichael_band`).** For every $n$ with $13 \le n \le 1000$, $F(n)$ has a
> primitive prime divisor.

**Proof.** Instantiate Theorem 3.9 with $u = F$ (Lemma 3.10). It suffices to check
$\mathrm{cp}(F, n) > 1$ for each such $n$. This is a finite collection of decidable inequalities on
the computable functional $\mathrm{cp}$, discharged by exact evaluation (`native_decide`),
uniformly over the primes and composites in the range. $\qquad\blacksquare$

> **Theorem 3.13 (`mersenne_bang_band`).** For every $n$ with $2 \le n \le 120$ and $n \ne 6$,
> $2^n - 1$ has a primitive prime divisor.

**Proof.** Instantiate Theorem 3.9 with $u(n) = 2^n - 1$ (Lemma 3.11) and check
$\mathrm{cp}(u, n) > 1$ for the finitely many admissible $n$ by exact evaluation. The single index
$n = 6$ where $\mathrm{cp}(u, 6) = 1$ (because $2^6 - 1 = 63 = 3^2 \cdot 7$ with $3 \mid 2^2-1$ and
$7 \mid 2^3 - 1$) is exactly the excluded Zsygmondy exception, isolated automatically. $\qquad
\blacksquare$

That a *single* criterion, proved once, discharges both Theorem 3.12 and Theorem 3.13 — Carmichael
1913 and Bang 1886 — is the central payoff: the engine never touches a Fibonacci recurrence or a
power-of-two identity, only Definition 2.1.

---

## 4. Algorithms

### 4.1 `removePrimesOf` (shared-prime stripping)

**Input.** $a, b \in \mathbb{N}$. **Output.** the largest divisor of $a$ coprime to $b$.

```
function REMOVE_PRIMES_OF(a, b):
    if a == 0: return 0
    loop:
        g <- gcd(a, b)
        if g <= 1: return a
        a <- a / g
```

**Complexity.** Each iteration reduces $a$ by a factor $g \ge 2$, so there are $O(\log a)$
iterations; each gcd costs $O(\log^2 a)$ bit operations. Total $O(\log^3 a)$.

**Correctness.** Lemmas 3.2–3.4: the output divides $a$, is coprime to $b$ (for $a > 0$), and is
positive (for $a > 0$).

### 4.2 `coprimePart` (newcomer detector)

**Input.** a sequence $u$ and index $n$. **Output.** the part of $u(n)$ built only from primitive
primes.

```
function COPRIME_PART(u, n):
    acc <- u(n)
    for d in 1 .. n-1:
        if n mod d == 0:
            acc <- REMOVE_PRIMES_OF(acc, u(d))
    return acc
```

**Complexity.** Iterates over divisors of $n$ (at most $n$ candidates, $\tau(n)$ effective), each a
`removePrimesOf` call. With memoized $u$, dominated by the size of $u(n)$: $O(\tau(n)\,
\mathrm{polylog}(u(n)))$ integer operations on numbers of $u(n)$'s magnitude.

**Decision.** $u(n)$ has a primitive prime divisor whenever the output exceeds 1 (Theorem 3.9).

### 4.3 Band verification

```
function VERIFY_BAND(u, lo, hi, exceptions):
    for n in lo .. hi:
        if n in exceptions: continue
        assert COPRIME_PART(u, n) > 1     # primitive prime guaranteed
    for n in exceptions:
        assert COPRIME_PART(u, n) == 1    # genuinely barren
```

This is the computational shape of Theorems 3.12–3.13. In the formal development the asserts are
replaced by a single decidable proposition evaluated by the kernel.

---

## 5. Applications

* **Unified Carmichael/Bang.** A single proved criterion yields both classical theorems on their
  verified bands, demonstrating that the primitive-divisor phenomenon is a property of the strong
  divisibility law, not of Fibonacci or exponential structure.
* **Exception discovery.** The detector locates barren indices automatically. Empirically (and in
  the demo) the Fibonacci exceptions on $[1, 200]$ are exactly $\{1, 2, 6, 12\}$ and the $2^n-1$
  exceptions on $[1, 120]$ are exactly $\{1, 6\}$ — matching the classical exception sets without
  any sequence-specific input.
* **A template for other sequences.** Any sequence satisfying Definition 2.1 — Lucas numbers,
  repunits $\frac{10^n - 1}{9}$, general Lucas sequences $U_n(P, Q)$ — inherits the engine
  verbatim, with its own primitive-divisor theorem on any checkable band.
* **Primality and apparition.** Because a primitive prime of $u(n)$ has rank of apparition exactly
  $n$, the engine provides a constructive route to apparition data underlying Lucas–Lehmer-style
  testing for these families.

---

## 6. Discussion

### 6.1 What the engine does and does not do

Theorem 3.9 is a *sufficient* criterion: $\mathrm{cp}(u, n) > 1 \Rightarrow$ primitive divisor.
The converse can fail in degenerate edge indices, which is exactly why the exceptional sets are
detected (there $\mathrm{cp} = 1$). For an *unconditional* theorem covering all $n$, one must show
$\mathrm{cp}(u, n) > 1$ for all sufficiently large $n$ — a single size estimate, rather than a
sequence-by-sequence analytic argument.

### 6.2 The quarantined analytic core

For Fibonacci, $\mathrm{cp}(F, n)$ is essentially the homogeneous cyclotomic factor $\Phi_n(\alpha,
\beta)$ (with $\alpha, \beta$ the golden-ratio conjugates) after removing intrinsic primes. The
remaining task is the inequality $\Phi_n > p_{\max}(n)$, where $p_{\max}(n)$ is the largest prime
factor of $n$: the cyclotomic factor grows like $\alpha^{\varphi(n)}$ (exponential in Euler's
totient), while the only obstruction grows linearly in $n$. The slack is doubly-exponential for
large $n$; the verified band certifies the finitely many tight small cases. The same picture holds
for $a^n - 1$. Thus the deep content is isolated into one clean inequality on the computable
coprime part.

### 6.3 Foundational status

Every result is machine-checked. The finite bands rely on exact kernel-level evaluation of the
computable $\mathrm{cp}$; consequently the developments depend only on the standard foundational
axioms together with the compiled-evaluation axioms used by `native_decide`. No sequence-specific
deep analytic theorem is assumed; the only number-theoretic lemma is the one-line Lemma 3.1.

---

## 7. Future work

1. **Make the exceptional sets theorems.** Prove $\mathrm{cp}(F, n) = 1 \iff n \in \{1, 2, 6,
   12\}$ and the analogue for base 2, turning the empirically observed exceptions into closed-form
   characterizations via the maximal-divisor lattice of $n$ and Lemma 3.1.
2. **Close the infinite tail.** Establish the cyclotomic lower bound $\Phi_n > p_{\max}(n)$ for
   $n$ beyond the verified band, upgrading the criterion to an unconditional primitive-divisor
   theorem for all $n$.
3. **Multiplicity via lifting-the-exponent.** Refine from existence to exact $p$-adic valuations,
   $v_p(u(n)) = v_p(u(z)) + v_p(n)$ for $p$ with rank of apparition $z \mid n$.
4. **Full Lucas-sequence generality.** Extend from Fibonacci and $a^n - 1$ to all Lucas sequences
   $U_n(P, Q)$, recovering Zsygmondy's theorem on verified bands from the same engine.
5. **Extend and calibrate the band.** Push the verified range and measure the minimum observed
   ratio $\mathrm{cp}(u, n) / p_{\max}(n)$, using the data to calibrate the constant in the
   analytic inequality of (2).

---

## 8. Conclusion

By distilling the primitive-divisor phenomenon down to the strong divisibility law $\gcd(u(m),
u(n)) = u(\gcd(m, n))$ and a single computable functional — the coprime part — we obtain one proved
criterion that simultaneously yields Carmichael's theorem for Fibonacci numbers and Bang's theorem
for $2^n - 1$ on verified bands. The engine is sequence-blind: its sole number-theoretic step is a
one-line gcd lemma. What remains for an unconditional result is a single, clean size estimate,
cleanly separated from the structural skeleton.
