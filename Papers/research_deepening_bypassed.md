# A Fibonacci–Pythagorean Bridge and the Index-Level Law of Strong Divisibility Sequences

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We develop two connected strands of elementary number theory and expose the
common structure beneath them. First, we prove a *Fibonacci–Pythagorean bridge*:
from four consecutive Fibonacci numbers $F_n, F_{n+1}, F_{n+2}, F_{n+3}$ one
constructs the legs $A = F_n F_{n+3}$ and $B = 2 F_{n+1} F_{n+2}$ and the
hypotenuse $C = F_{n+1}^2 + F_{n+2}^2$, obtaining an exact Pythagorean identity
$A^2 + B^2 = C^2$ for every $n$; moreover the hypotenuse is itself a Fibonacci
number, $C = F_{2n+3}$. The two smallest instances reproduce the classical
triples $(3,4,5)$ and $(5,12,13)$. Second, we isolate the abstract engine behind
several classical divisibility laws: for any *strong divisibility sequence* with
distinct terms, term divisibility is equivalent to index divisibility,
$a_m \mid a_n \iff m \mid n$. This single theorem yields the Fibonacci
strong-divisibility law, the Mersenne-type law $a^m - 1 \mid a^n - 1 \iff m \mid
n$ for $a \ge 2$, and an index test for Fibonacci primes: if $F_n$ is prime then
$n = 4$ or $n$ is prime. We give complete proof sketches, numerical illustrations,
algorithms, and a set of conjectures extending the framework.

## 1. Introduction

The Fibonacci sequence $F_0 = 0$, $F_1 = 1$, $F_{n+2} = F_{n+1} + F_n$ and the
Pythagorean relation $a^2 + b^2 = c^2$ are two of the most heavily studied
objects in elementary mathematics, yet they are usually treated in separate
compartments — one belonging to arithmetic and recurrences, the other to
Euclidean geometry. A classical construction attributed to Raine and later
systematized by Horadam ties them together: consecutive Fibonacci numbers can be
assembled into Pythagorean triples. This paper gives a clean, fully explicit
account of that bridge and pins down its hypotenuse exactly.

Running underneath the Fibonacci divisibility phenomena is a more general
principle. The Fibonacci numbers form a *strong divisibility sequence*: the gcd
of two terms is the term indexed by the gcd of the indices. So do the sequences
$a^n - 1$. We extract the abstract lemma that makes both work and show that, for
injective (equivalently, distinct-valued) strong divisibility sequences,
divisibility of terms is *literally* divisibility of indices. From this vantage
point the Fibonacci prime-index test is a two-line corollary.

The paper is organized as follows. Section 2 fixes definitions. Section 3 proves
the Fibonacci–Pythagorean bridge. Section 4 develops the strong-divisibility
characterization and its two canonical instances. Section 5 derives the Fibonacci
prime-index test. Section 6 presents algorithms; Section 7, applications and
numerics; Section 8, discussion and open problems.

## 2. Definitions and preliminaries

**Definition 2.1 (Fibonacci sequence).** The Fibonacci numbers are defined by
$F_0 = 0$, $F_1 = 1$, and $F_{n+2} = F_{n+1} + F_n$ for all $n \ge 0$. We use the
standard facts $F_{n+2} = F_n + F_{n+1}$ and the *addition formula*
$$F_{m+k+1} = F_m F_k + F_{m+1} F_{k+1}. \tag{2.1}$$

**Definition 2.2 (Fibonacci triangle data).** For $n \in \mathbb{N}$ set
$$A_n = F_n\,F_{n+3},\qquad B_n = 2\,F_{n+1}\,F_{n+2},\qquad C_n = F_{n+1}^2 + F_{n+2}^2.$$
We call $(A_n, B_n, C_n)$ the *Fibonacci–Pythagorean data at index $n$*.

**Definition 2.3 (Divisibility sequence).** A sequence $a : \mathbb{N} \to
\mathbb{N}$ is a *divisibility sequence* if $m \mid n$ implies $a_m \mid a_n$.

**Definition 2.4 (Strong divisibility sequence).** A sequence $a : \mathbb{N} \to
\mathbb{N}$ is a *strong divisibility sequence* if
$$\gcd(a_m, a_n) = a_{\gcd(m,n)} \qquad \text{for all } m, n \in \mathbb{N}. \tag{2.2}$$
Every strong divisibility sequence is a divisibility sequence: if $m \mid n$ then
$\gcd(m,n) = m$, so $\gcd(a_m, a_n) = a_m$, i.e. $a_m \mid a_n$.

**Definition 2.5 (Pythagorean triple).** A triple $(A, B, C)$ of positive
integers is *Pythagorean* if $A^2 + B^2 = C^2$. It is *non-degenerate* if
$A, B > 0$.

## 3. The Fibonacci–Pythagorean bridge

### 3.1 The Pythagorean identity

**Theorem 3.1 (Fibonacci–Pythagorean Identity).** For every $n \in \mathbb{N}$,
$$A_n^2 + B_n^2 = C_n^2,$$
that is, $(F_n F_{n+3})^2 + (2 F_{n+1} F_{n+2})^2 = (F_{n+1}^2 + F_{n+2}^2)^2.$

*Proof sketch.* Write $x = F_n$ and $y = F_{n+1}$. The recurrence gives
$F_{n+2} = x + y$ and $F_{n+3} = F_{n+1} + F_{n+2} = x + 2y$. Substituting,
$$A_n = x(x + 2y) = x^2 + 2xy,\qquad B_n = 2y(x+y) = 2xy + 2y^2,$$
$$C_n = y^2 + (x+y)^2 = x^2 + 2xy + 2y^2.$$
Expanding both sides as polynomials in $x, y$,
$$A_n^2 + B_n^2 = (x^2 + 2xy)^2 + (2xy + 2y^2)^2 = x^4 + 4x^3y + 8x^2y^2 + 8xy^3 + 4y^4,$$
$$C_n^2 = (x^2 + 2xy + 2y^2)^2 = x^4 + 4x^3y + 8x^2y^2 + 8xy^3 + 4y^4.$$
The two expressions are identical, so the equation holds as a polynomial identity
in $x$ and $y$, hence for every $n$. $\qquad\blacksquare$

The proof requires no induction beyond one unfolding of the recurrence: the
identity is genuinely *polynomial*.

### 3.2 The hypotenuse is a Fibonacci number

**Theorem 3.2 (Fibonacci Hypotenuse Theorem).** For every $n \in \mathbb{N}$,
$$C_n = F_{n+1}^2 + F_{n+2}^2 = F_{2n+3}.$$

*Proof sketch.* Apply the addition formula (2.1) with $m = k = n+1$:
$$F_{(n+1)+(n+1)+1} = F_{n+1} F_{n+1} + F_{n+2} F_{n+2} = F_{n+1}^2 + F_{n+2}^2.$$
Since $(n+1)+(n+1)+1 = 2n+3$, the left side is $F_{2n+3}$, giving the claim.
$\qquad\blacksquare$

### 3.3 The triple theorem and non-degeneracy

**Theorem 3.3 (Fibonacci–Pythagorean Triple Theorem).** For every $n \in
\mathbb{N}$,
$$(F_n F_{n+3})^2 + (2 F_{n+1} F_{n+2})^2 = F_{2n+3}^2.$$

*Proof.* Combine Theorem 3.1 and Theorem 3.2: $A_n^2 + B_n^2 = C_n^2 =
F_{2n+3}^2$. $\qquad\blacksquare$

**Theorem 3.4 (Non-degeneracy).** For every $n \ge 1$, both legs are strictly
positive: $A_n > 0$ and $B_n > 0$. Hence $(A_n, B_n, F_{2n+3})$ is a genuine
non-degenerate right triangle.

*Proof sketch.* For $n \ge 1$ all of $F_n, F_{n+1}, F_{n+2}, F_{n+3}$ are
positive (the Fibonacci numbers are positive from index $1$ onward). Products of
positive integers are positive, so $A_n = F_n F_{n+3} > 0$ and $B_n = 2 F_{n+1}
F_{n+2} > 0$. $\qquad\blacksquare$

**Remark 3.5 (Primitivity).** The triples need not be primitive. For $n = 3$ the
data is $(16, 30, 34) = 2\cdot(8, 15, 17)$. Thus we make no primitivity claim;
the construction produces valid but sometimes non-primitive triples. Because
$C_n = F_{2n+3}$, the hypotenuses realized by genuine triangles ($n \ge 1$) are
exactly the odd-index Fibonacci numbers $F_5, F_7, F_9, \dots$

**Examples.** $n=1: (3,4,5)$ with hypotenuse $F_5 = 5$. $n=2: (5,12,13)$ with
hypotenuse $F_7 = 13$. $n=3$: $A_3 = F_3 F_6 = 2 \cdot 8 = 16$, $B_3 = 2 F_4 F_5
= 2\cdot 3\cdot 5 = 30$, $C_3 = F_4^2 + F_5^2 = 9 + 25 = 34 = F_9$, giving
$(16,30,34)$ (non-primitive). $n=4$: $A_4 = F_4 F_7 = 3\cdot 13 = 39$, $B_4 = 2
F_5 F_6 = 2\cdot 5\cdot 8 = 80$, $C_4 = F_5^2 + F_6^2 = 25 + 64 = 89 = F_{11}$,
i.e. $(39, 80, 89)$, which is primitive.

## 4. The index-level law of strong divisibility sequences

### 4.1 The characterization

**Theorem 4.1 (Strong Divisibility Characterization).** Let $a : \mathbb{N} \to
\mathbb{N}$ be a strong divisibility sequence whose terms are distinct (i.e.
$a$ is injective). Then for all $m, n \in \mathbb{N}$,
$$a_m \mid a_n \quad\Longleftrightarrow\quad m \mid n.$$

*Proof sketch.* ($\Rightarrow$) Suppose $a_m \mid a_n$. Then $\gcd(a_m, a_n) =
a_m$. By the strong divisibility property (2.2), $\gcd(a_m, a_n) = a_{\gcd(m,n)}$,
so $a_{\gcd(m,n)} = a_m$. Injectivity gives $\gcd(m, n) = m$, which is exactly the
statement $m \mid n$.

($\Leftarrow$) Suppose $m \mid n$. Then $\gcd(m, n) = m$, so by (2.2)
$\gcd(a_m, a_n) = a_{\gcd(m,n)} = a_m$; since the gcd divides $a_n$, we conclude
$a_m \mid a_n$. $\qquad\blacksquare$

The theorem converts an arithmetic question about the *values* of a sequence into
a purely combinatorial question about the divisibility lattice $(\mathbb{N},
\mid)$ of the *indices*.

### 4.2 Fibonacci instance

The Fibonacci sequence satisfies $\gcd(F_m, F_n) = F_{\gcd(m,n)}$, the classical
strong divisibility law. On the range of indices $\ge 3$ the sequence is strictly
increasing, hence injective, and Theorem 4.1 recovers:

**Corollary 4.2 (Fibonacci divisibility law).** For indices where the Fibonacci
sequence is strictly increasing, $F_m \mid F_n \iff m \mid n$.

(The global statement requires care at the small repeated value $F_1 = F_2 = 1$;
the divisibility direction $m \mid n \Rightarrow F_m \mid F_n$ holds for all
indices, since Fibonacci is a strong divisibility sequence.)

### 4.3 Mersenne-type instance

**Theorem 4.3 (Mersenne divisibility law).** Fix an integer $a \ge 2$. Then for
all $m, n \in \mathbb{N}$,
$$a^m - 1 \mid a^n - 1 \quad\Longleftrightarrow\quad m \mid n.$$

*Proof sketch.* The sequence $M_k = a^k - 1$ is a strong divisibility sequence:
$\gcd(a^m - 1, a^n - 1) = a^{\gcd(m,n)} - 1$, a classical identity. For $a \ge 2$
the map $k \mapsto a^k - 1$ is strictly increasing, hence injective (this reduces
to injectivity of $k \mapsto a^k$, valid because $a \ge 2$). Theorem 4.1 then
gives the equivalence directly. $\qquad\blacksquare$

With $a = 2$ this is the familiar statement $2^m - 1 \mid 2^n - 1 \iff m \mid n$,
governing the Mersenne numbers.

## 5. An index test for Fibonacci primes

**Theorem 5.1 (Fibonacci Prime Index Test).** If $F_n$ is prime, then $n = 4$ or
$n$ is prime.

*Proof sketch.* Suppose $F_n$ is prime and $n \notin \{4\}$ is composite, say
$n = jk$ with $1 < j < n$. Since $j \mid n$ and Fibonacci is a strong
divisibility sequence, $F_j \mid F_n$. As $F_n$ is prime, $F_j \in \{1, F_n\}$.
For indices $j \ge 3$ we have $F_j \ge 2$ and $F_j < F_n$ (strict monotonicity),
so neither alternative can hold — a contradiction. The remaining possibilities
require $j \le 2$ for every nontrivial factor $j$ of $n$; combined with $n$
composite this forces $n = 4$ (whose only proper nontrivial factor is $2$, with
$F_2 = 1$). Hence $n = 4$ or $n$ is prime. $\qquad\blacksquare$

**Remark 5.2 (The exception is genuine).** $F_4 = 3$ is prime though $4$ is
composite, so the exceptional index cannot be removed. It arises precisely
because the injectivity argument of Theorem 4.1 needs indices $\ge 3$, while the
small indices $0, 1, 2$ (where $F_0 = 0$, $F_1 = F_2 = 1$) require separate
handling. Conversely, the test is only a *necessary* condition: $F_{19} = 4181 =
37 \times 113$ is composite despite $19$ being prime.

## 6. Algorithms

### 6.1 Generating Fibonacci–Pythagorean triples

Given $N$, produce $\{(A_n, B_n, C_n) : 1 \le n \le N\}$ with $C_n = F_{2n+3}$,
each certified to satisfy $A_n^2 + B_n^2 = C_n^2$. The cost is dominated by
computing Fibonacci numbers up to index $2N+3$, which is $O(N)$ additions on
big integers.

### 6.2 Divisibility oracle via indices

To test whether $a_m \mid a_n$ for a strong divisibility sequence with distinct
terms, Theorem 4.1 lets us bypass the (possibly enormous) terms entirely and test
$m \mid n$ in $O(1)$ arithmetic. This is an exponential speedup for the Mersenne
family, where $a^n - 1$ has $\Theta(n)$ digits.

### 6.3 Fibonacci prime index sieve

To search for Fibonacci primes up to index $N$: by Theorem 5.1 it suffices to
test $F_n$ for primality only at $n = 4$ and at prime $n$, skipping all other
composite indices — a substantial pruning of the search space.

## 7. Applications and numerics

- **Triple generation.** The construction furnishes an explicit infinite family
  of Pythagorean triples indexed by the odd-index Fibonacci numbers as
  hypotenuses, useful as test data and as a source of Diophantine examples.
- **Fast divisibility.** The index-level law provides constant-time divisibility
  testing for Mersenne-type sequences, relevant to the theory of repunits and to
  primality pre-screening.
- **Prime search pruning.** The prime-index test focuses Fibonacci-prime searches
  onto prime indices (plus $n=4$), matching the strategy used in record
  computations of large Fibonacci primes.

Sample values:

| $n$ | $(A_n, B_n, C_n)$ | $C_n = F_{2n+3}$ | primitive? |
|-----|-------------------|------------------|------------|
| 1   | $(3, 4, 5)$       | $F_5 = 5$        | yes        |
| 2   | $(5, 12, 13)$     | $F_7 = 13$       | yes        |
| 3   | $(16, 30, 34)$    | $F_9 = 34$       | no         |
| 4   | $(39, 80, 89)$    | $F_{11} = 89$    | yes        |
| 5   | $(105, 208, 233)$ | $F_{13} = 233$   | yes        |

## 8. Discussion and open problems

The two strands share a philosophy: rather than verifying an infinite family case
by case, one isolates the *single* structural fact — a polynomial identity in the
first case, an abstract gcd law in the second — from which the whole family
follows. This is what allows the Fibonacci and Mersenne divisibility laws to be
proved *simultaneously* as instances of one theorem, and what makes the
Pythagorean identity a matter of pure algebra rather than induction.

Several natural questions remain, detailed in the Future Directions. Chief among
them: a uniform primitive-divisor threshold for all injective strong divisibility
sequences; the density of prime indices among Fibonacci primes; a complete parity
classification of which Fibonacci numbers arise as hypotenuses of the
construction and when the resulting triples are primitive; and whether the finite
"exceptional index set" of a strong divisibility sequence is an invariant of its
growth exponent alone.

## References (classical background)

- Fibonacci addition and strong divisibility laws (classical folklore of the
  Fibonacci sequence).
- Raine's and Horadam's constructions of Pythagorean triples from Fibonacci
  numbers.
- Carmichael's and Bang's theorems on primitive prime divisors of Fibonacci
  numbers and of $a^n - 1$.
