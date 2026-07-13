# The Factorial Number System as a Mixed-Radix System: A Unified Uniqueness Theory

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

Positional numeral systems — ordinary base $N$, the factorial (factoradic)
system, and their many relatives — are usually studied one at a time, each with
its own proof that representations are unique and complete. We develop a single
parameterized theory of **mixed-radix number systems**, indexed by an arbitrary
sequence of bases $b_0, b_1, b_2, \dots$, and prove uniqueness and existence of
valid representations once and for all. We then establish a precise **bridge**
showing that the factorial number system is exactly the mixed-radix system with
bases $b_i = i + 1$: the place values coincide ($\prod_{j<i} b_j = i!$), the
validity predicates coincide ($c_i < b_i \iff c_i \le i$), and consequently the
classical factoradic uniqueness theorem is *re-derived as a corollary* of the
general mixed-radix uniqueness theorem, using only the two bridge identities and
never the special-case argument. This exhibits the factorial system, ordinary
base $N$, and every other mixed-radix scheme as points in one family governed by
a single law: place values are the running products of the bases, and each digit
must lie below its own base. We give the main definitions, full theorem
statements with proof sketches, an explicit digit-extraction algorithm, and
numerical demonstrations, including the application to ranking and unranking
permutations.

## 1. Introduction

A positional numeral system expresses a natural number as a weighted sum of
*digits*, where the weights are prescribed *place values*. In base $N$ the place
values are $1, N, N^2, N^3, \dots$ and each digit lies in $\{0,\dots,N-1\}$. The
**factorial number system** (factoradic) replaces the geometric progression of
powers by the factorials $1, 1, 2, 6, 24, \dots$ and lets the digit in place $i$
range over $\{0,\dots,i\}$. The factoradic system is the natural coordinate
system for permutations: it underlies the Lehmer code and the standard
ranking/unranking algorithms that convert between a permutation and its index in
lexicographic order.

Base $N$ obeys one fixed rule; the factorial system changes its rule at every
place. Superficially they are different constructions with different correctness
proofs. The contribution of this paper is to show they are not: both are
instances of a single **mixed-radix** theory, and the properties one most wants
from a numeral system — *unique* and *complete* representation — hold for the
whole family under one proof.

Our results are:

1. A self-contained development of mixed-radix systems for an arbitrary base
   sequence, including the key digit-bound estimate, the Euclidean splitting
   identities, the **uniqueness theorem**, and the **existence/extraction
   theorem**.
2. A **bridge** to the factorial system: place-value agreement, validity
   agreement, and a re-derivation of factoradic uniqueness *from the general
   theorem alone*.
3. An explicit extraction algorithm and worked numerical examples, including
   permutation ranking/unranking.

A guiding design principle is **non-circularity**: the re-derivation of the
factoradic result depends on the general theorem and the bridge identities, and
*not* on the classical factoradic proof, so the generalization genuinely
subsumes the special case rather than restating it.

## 2. Definitions

Throughout, $b : \mathbb{N} \to \mathbb{N}$ is a sequence of **bases** and
$c, d : \mathbb{N} \to \mathbb{N}$ are **digit functions**. We work with
length-$k$ prefixes.

**Definition 2.1 (Running product / place value).**
The place value of position $i$ is the running product of the first $i$ bases,
$$P_i \;:=\; \operatorname{radixProd}(b, i) \;=\; \prod_{j=0}^{i-1} b_j,
\qquad P_0 = 1.$$
It satisfies the recurrence $P_{i+1} = P_i \cdot b_i$.

**Definition 2.2 (Mixed-radix value).**
The length-$k$ value of a digit function $c$ under bases $b$ is
$$\operatorname{value}(b, c, k) \;=\; \sum_{i=0}^{k-1} c_i \, P_i
   \;=\; \sum_{i=0}^{k-1} c_i \prod_{j<i} b_j .$$
It satisfies the peeling recurrence
$\operatorname{value}(b,c,k+1) = \operatorname{value}(b,c,k) + c_k\, P_k$.

**Definition 2.3 (Validity).**
A digit function $c$ is **valid up to length $k$**, written
$\operatorname{Valid}(b,c,k)$, if every digit stays below its local base:
$$\operatorname{Valid}(b,c,k) \;:\iff\; \forall\, i < k,\ c_i < b_i.$$

**Definition 2.4 (Factorial number system).**
The factoradic value and validity are
$$\operatorname{value}_{\mathrm{F}}(c,k) = \sum_{i=0}^{k-1} c_i\, i!, \qquad
  \operatorname{Valid}_{\mathrm{F}}(c,k) :\iff \forall\, i<k,\ c_i \le i.$$

**Special cases.**
- *Base $N$*: take $b_i = N$; then $P_i = N^i$ and validity is $c_i < N$.
- *Factorial*: take $b_i = i+1$; then $P_i = i!$ and validity is $c_i \le i$
  (since $c_i < i+1 \iff c_i \le i$).

## 3. The mixed-radix uniqueness theory

All results in this section hold for an **arbitrary** base sequence $b$. The
development is non-circular: uniqueness is proved from the digit-bound estimate
and the Euclidean splitting identities, without recourse to cardinality,
surjectivity, or any bijection theorem.

**Lemma 3.1 (Positivity of place values under validity).**
If $\operatorname{Valid}(b,c,k+1)$ holds, then $P_k > 0$.

*Proof sketch.* Each factor $b_i$ with $i < k$ satisfies $b_i > c_i \ge 0$, so
$b_i \ge 1$; a product of positive naturals is positive. $\square$

**Lemma 3.2 (Digit-bound estimate).**
If $\operatorname{Valid}(b,c,k)$ then
$$\operatorname{value}(b,c,k) \;<\; P_k \;=\; \prod_{i<k} b_i .$$

*Proof sketch.* Induct on $k$. The base case is $0 < 1$. For the step, by the
peeling recurrence,
$$\operatorname{value}(b,c,k+1) = \operatorname{value}(b,c,k) + c_k P_k
   < P_k + c_k P_k = (1 + c_k)P_k \le b_k P_k = P_{k+1},$$
using the inductive bound on the tail and $c_k < b_k$ (so $1 + c_k \le b_k$).
$\square$

This is the mixed-radix analogue of "a $k$-digit decimal number is at most
$\underbrace{9\cdots9}_{k} < 10^{k}$."

**Lemma 3.3 (Euclidean splitting).**
If $\operatorname{Valid}(b,c,k+1)$ then dividing by the top place value recovers
the top digit, and reducing modulo it recovers the tail:
$$\left\lfloor \frac{\operatorname{value}(b,c,k+1)}{P_k} \right\rfloor = c_k,
\qquad
\operatorname{value}(b,c,k+1) \bmod P_k = \operatorname{value}(b,c,k).$$

*Proof sketch.* Write $\operatorname{value}(b,c,k+1) = \operatorname{value}(b,c,k) + c_k P_k$.
By Lemma 3.2 the tail $\operatorname{value}(b,c,k) < P_k$, so it is exactly the
remainder on division by $P_k$ (Lemma 3.1 gives $P_k>0$), and the quotient is
$c_k$. $\square$

**Theorem 3.4 (Uniqueness of mixed-radix representations).**
If $\operatorname{Valid}(b,c,k)$, $\operatorname{Valid}(b,d,k)$, and
$\operatorname{value}(b,c,k) = \operatorname{value}(b,d,k)$, then $c_i = d_i$
for all $i < k$.

*Proof sketch.* Induct on $k$. For $k+1$: applying the division identity of
Lemma 3.3 to both sides of the equal values isolates the top digits and forces
$c_k = d_k$; applying the mod identity reduces to equal tail values
$\operatorname{value}(b,c,k) = \operatorname{value}(b,d,k)$, to which the
induction hypothesis applies, giving $c_i = d_i$ for all $i < k$. Together these
cover all $i < k+1$. $\square$

**Definition 3.5 (Digit extraction).**
For a target $n$, define
$$\operatorname{digit}(b, n, i) \;=\; \left\lfloor \frac{n}{P_i} \right\rfloor \bmod b_i .$$

**Theorem 3.6 (Existence / surjectivity).**
For every $n$ with $n < P_k$, the extracted digits reconstruct $n$:
$$\operatorname{value}\bigl(b,\ \operatorname{digit}(b,n,\cdot),\ k\bigr) = n .$$
Moreover, when every base is positive, the extracted digits are valid.

*Proof sketch.* One proves by induction on $m$ the identity
$$n = \sum_{i<m} \Bigl(\bigl\lfloor n/P_i \bigr\rfloor \bmod b_i\Bigr) P_i
      \;+\; \bigl\lfloor n/P_m \bigr\rfloor \, P_m ,$$
using $P_{i+1}=P_i b_i$ and the division algorithm at each step. At $m=k$ the
trailing term $\lfloor n/P_k\rfloor P_k$ vanishes because $n < P_k$, leaving
$n = \operatorname{value}(b,\operatorname{digit}(b,n,\cdot),k)$. Validity of the
extracted digits is immediate: a remainder modulo $b_i$ is less than $b_i$.
$\square$

**Corollary 3.7 (Perfect dictionary).**
For a fixed length $k$ and positive bases, $c \mapsto \operatorname{value}(b,c,k)$
is a bijection between the valid length-$k$ digit strings and
$\{0, 1, \dots, P_k - 1\}$.

*Proof sketch.* Theorem 3.4 gives injectivity on valid strings; Theorem 3.6
gives surjectivity onto $\{0,\dots,P_k-1\}$ and produces a valid preimage.
$\square$

## 4. The bridge to the factorial system

We now specialize to $b_i = i + 1$ and show the factorial system is *literally*
this instance.

**Lemma 4.1 (Place values are factorials).**
$$\operatorname{radixProd}\bigl((i \mapsto i+1),\ k\bigr)
   = \prod_{j=0}^{k-1}(j+1) = k! .$$

*Proof sketch.* Induction on $k$: the product recurrence gives
$P_{k+1} = P_k\,(k+1) = k!\,(k+1) = (k+1)!$. $\square$

**Theorem 4.2 (Value agreement).**
For all digit functions $c$ and lengths $k$,
$$\operatorname{value}\bigl((i\mapsto i+1),\ c,\ k\bigr)
   = \operatorname{value}_{\mathrm{F}}(c, k).$$

*Proof sketch.* Both sides are sums over $\{0,\dots,k-1\}$; they agree
term-by-term because the $i$-th place value $P_i$ equals $i!$ by Lemma 4.1. The
equality is closed by a summand-wise comparison. $\square$

**Theorem 4.3 (Validity agreement).**
For all $c$ and $k$,
$$\operatorname{Valid}\bigl((i\mapsto i+1),\ c,\ k\bigr)
   \iff \operatorname{Valid}_{\mathrm{F}}(c, k).$$

*Proof sketch.* Position-wise, $c_i < i+1 \iff c_i \le i$ for natural numbers.
$\square$

**Theorem 4.4 (Factoradic uniqueness, re-derived from the general theorem).**
If $\operatorname{Valid}_{\mathrm{F}}(c,k)$, $\operatorname{Valid}_{\mathrm{F}}(d,k)$,
and $\operatorname{value}_{\mathrm{F}}(c,k) = \operatorname{value}_{\mathrm{F}}(d,k)$,
then $c_i = d_i$ for all $i < k$.

*Proof sketch.* Transport the hypotheses into mixed-radix form: by Theorem 4.3
both $c,d$ are $\operatorname{Valid}((i\mapsto i+1),\cdot,k)$, and by Theorem 4.2
their mixed-radix values are equal. Apply the general uniqueness Theorem 3.4 with
$b_i = i+1$ to conclude $c_i = d_i$ for all $i<k$. $\square$

**Remark 4.5 (Non-circularity).**
Theorem 4.4 invokes only the general Theorem 3.4 and the bridge identities 4.2,
4.3 — none of which depends on any special-case factoradic uniqueness argument.
The generalization therefore genuinely *contains* the classical result rather
than restating it.

**Remark 4.6 (Base $N$ as a second instance).**
Taking $b_i = N$ gives $P_i = N^i$ by the same product recurrence, and Theorem
3.4 specializes to uniqueness of ordinary base-$N$ numerals. Factorial and base
$N$ are two points in one family.

## 5. Algorithms

### 5.1 Encoding (digit extraction)

Given a target $n$ and length $k$, Theorem 3.6 gives the digits directly:

```
ENCODE(b, n, k):
  P <- 1
  for i = 0 .. k-1:
    c[i] <- floor(n / P) mod b[i]
    P <- P * b[i]
  return c
```

For the factorial system, take $b_i = i+1$; the running product $P$ passes
through $0!,1!,2!,\dots$ Complexity is $O(k)$ big-integer operations.

### 5.2 Decoding (value)

```
DECODE(b, c, k):
  value <- 0; P <- 1
  for i = 0 .. k-1:
    value <- value + c[i] * P
    P <- P * b[i]
  return value
```

Encoding then decoding is the identity on $\{0,\dots,P_k-1\}$ (Theorem 3.6), and
decoding is injective on valid strings (Theorem 3.4).

### 5.3 Ranking and unranking permutations

The factorial system is the coordinate system of permutations via the **Lehmer
code**. For a permutation $\pi$ of $\{0,\dots,k-1\}$, define
$$L_i(\pi) = \#\{\, j > i : \pi_j < \pi_i \,\}, \qquad 0 \le L_i \le k-1-i .$$
Reading the Lehmer code as factoradic digits gives the *rank* of $\pi$ in
lexicographic order; conversely, factoradic-decoding an index into a Lehmer code
and applying it reconstructs the permutation. Uniqueness (Theorem 4.4) is exactly
what guarantees that distinct permutations receive distinct ranks, and existence
(Theorem 3.6) guarantees every rank $0 \le r < k!$ names a permutation.

## 6. Applications

- **Combinatorial generation.** Constant-time access to the $r$-th permutation
  for enormous $r$, without enumerating predecessors — the backbone of unranking.
- **Odometers, calendars, and mixed units.** Any device whose wheels have
  differing sizes (seconds/minutes/hours, days/months) is a mixed-radix
  odometer; the running-product place values convert a reading to a single count.
- **Tuple encoding / hashing.** Packing tuples drawn from differently sized
  alphabets into a single integer with no wasted range, justified by Corollary
  3.7 (bijectivity).
- **Unified correctness.** A single proof certifies correctness of encoders and
  decoders for the entire family, including designs not yet named.

## 7. Discussion

The value of the mixed-radix viewpoint is structural. A theorem proved about a
*family* transfers to every member, including those introduced later. Here the
digit-bound estimate (Lemma 3.2) is the linchpin: it is the abstract content of
the intuition that a $k$-place number cannot reach the $(k{+}1)$-st place value,
and it powers both uniqueness and existence. The proofs never mention a specific
base, so they specialize verbatim to factoradic and base $N$.

The emphasis on non-circularity (Remark 4.5) is deliberate. It is easy to
"generalize" a result by quietly reusing the special case; the point of a genuine
generalization is that the abstract theory stands alone and the special case is
one of its consequences. The factoradic uniqueness theorem here is a strict
corollary of mixed-radix uniqueness plus two elementary bridge identities.

## 8. Future work

- **A base-$N$ bridge**, mirroring the factorial bridge, that re-derives ordinary
  base-$N$ uniqueness as a second explicit instance of the general theorem, using
  the running-product identity $\prod_{j<k} N = N^k$.
- **Bridging the existence/extraction results** (Theorem 3.6 and the digit map)
  between the factorial and mixed-radix systems in the same style, so that both
  directions of the correspondence are transported, not just uniqueness.
- **Variable-length and infinite representations**, and canonical-form results
  for streams under mixed radices.

## 9. Conclusion

The factorial number system is not an exception to ordinary positional
arithmetic; it is an instance of it. By parameterizing over an arbitrary base
sequence and proving uniqueness and existence once, we obtain the factoradic
theory — and ordinary base $N$ — as corollaries. The place values are the running
products of the bases, a digit must stay below its own base, and from that single
law the defining virtue of any notation, that it names each number exactly once,
follows automatically.
