# A Unified Theory of Positional Number Systems: The Factorial System as a Mixed-Radix Instance

## Abstract

We develop the theory of **mixed-radix positional number systems** — positional
representations in which each column may carry its own base — and prove, in full
generality and from first principles, that valid representations of a fixed length
are unique and that they exist for every number below the running product of the
bases. We then establish a precise **bridge**: the classical **factorial number
system** (factoradic) is exactly the mixed-radix system whose base at column $i$
is $i+1$. Three bridge theorems show that the place values agree ($\prod_{j<i}(j+1)
= i!$), that the validity conditions agree ($c_i < i+1 \iff c_i \le i$), and that
the uniqueness theorem for the factorial system is a strict corollary of the
general mixed-radix uniqueness theorem. The development is deliberately
non-circular: uniqueness is proved directly from a digit-bound estimate and two
Euclidean splitting identities, without recourse to cardinality, surjectivity, or
any bijection theorem. Ordinary base-$N$ numerals arise as the companion instance
$b_i = N$, exhibiting decimal, binary, and factoradic representations as three
points in one parameterized family.

**Keywords:** mixed-radix, factorial number system, factoradic, positional
notation, place value, uniqueness of representation, Lehmer code, Euclidean
division.

## 1. Introduction

The decimal expansion $2025 = 2\cdot 10^3 + 0\cdot 10^2 + 2\cdot 10 + 5$ is the
prototype of a *positional* number system: a sequence of place values (here, the
powers of ten) together with digits below a fixed base. Constant-base systems —
decimal, binary, hexadecimal, sexagesimal — are the ones taught in school, but the
constancy of the base is an unnecessary restriction. If we allow the base to vary
from column to column, we obtain the **mixed-radix** systems, and among them, as a
particularly clean special case, the **factorial number system** whose place
values are the factorials $1, 1, 2, 6, 24, 120, \dots$.

The purpose of this paper is twofold. First, we give a self-contained account of
mixed-radix systems, culminating in the two theorems that make any positional
system usable — **uniqueness** and **existence** of representations. Second, we
prove that the factorial number system is *literally* the mixed-radix instance
$b_i = i+1$, so that every structural result about the general theory transports to
the factoradic for free. The technical heart is that uniqueness never uses the
*specific* running product; it uses only that the running product is positive,
which a single valid digit already guarantees.

The paper is organized as follows. Section 2 fixes definitions. Section 3 proves
the digit-bound estimate. Section 4 proves the Euclidean splitting identities.
Section 5 proves uniqueness. Section 6 proves existence. Section 7 establishes the
factorial bridge and re-derives factoradic uniqueness as a corollary. Section 8
records the base-$N$ instance and boundary cases. Section 9 discusses applications,
notably permutation ranking via the Lehmer code. Section 10 collects future
directions.

## 2. Definitions

Throughout, $\mathbb{N} = \{0,1,2,\dots\}$, and a **base sequence** is a function
$b : \mathbb{N} \to \mathbb{N}$. A **digit function** is a function $c : \mathbb{N}
\to \mathbb{N}$.

**Definition 2.1 (Running product / place value).** For a base sequence $b$ and
length $k \in \mathbb{N}$, the *running product* is
$$
P_b(k) \;=\; \prod_{i<k} b_i,
$$
with $P_b(0) = 1$. The number $P_b(i)$ is the *place value* of column $i$. It
satisfies the recurrence $P_b(k+1) = P_b(k)\cdot b_k$.

**Definition 2.2 (Mixed-radix value).** The *length-$k$ value* of a digit function
$c$ under base sequence $b$ is
$$
V_b(c,k) \;=\; \sum_{i<k} c_i \, P_b(i).
$$
It satisfies $V_b(c,0) = 0$ and the recurrence $V_b(c,k+1) = V_b(c,k) + c_k\,
P_b(k)$.

**Definition 2.3 (Validity).** A digit function $c$ is *valid up to length $k$*,
written $\mathrm{Valid}_b(c,k)$, if
$$
c_i < b_i \qquad \text{for all } i < k.
$$
Validity is monotone in length: $\mathrm{Valid}_b(c,k+1)$ implies
$\mathrm{Valid}_b(c,k)$.

**Definition 2.4 (Factoradic value and validity).** The *factoradic value* of a
digit function $c$ is $F(c,k) = \sum_{i<k} c_i \, i!$, and $c$ is *factoradic-valid*
up to $k$, written $\mathrm{ValidF}(c,k)$, if $c_i \le i$ for all $i<k$.

The two constant/varying special cases we care about are $b_i = N$ (ordinary base
$N$) and $b_i = i+1$ (the factorial system).

## 3. The Digit-Bound Estimate

The following positivity fact is the *only* place base positivity is used, and it
is extracted from validity rather than assumed.

**Lemma 3.1 (Positivity from validity).** If $\mathrm{Valid}_b(c,k+1)$, then
$P_b(k) > 0$.

*Proof.* For each $i<k$, validity at $i$ gives $c_i < b_i$, so $b_i \ge c_i + 1
\ge 1$. A product of positive naturals is positive, hence $P_b(k) = \prod_{i<k}
b_i > 0$. $\qquad\blacksquare$

**Theorem 3.2 (Digit-bound estimate).** If $\mathrm{Valid}_b(c,k)$, then
$$
V_b(c,k) \;<\; P_b(k).
$$

*Proof.* Induction on $k$. For $k=0$, $V_b(c,0)=0 < 1 = P_b(0)$. Assume the claim
for $k$ and suppose $\mathrm{Valid}_b(c,k+1)$. By monotonicity,
$\mathrm{Valid}_b(c,k)$ holds, so the inductive hypothesis gives $V_b(c,k) <
P_b(k)$, i.e. $V_b(c,k) \le P_b(k) - 1$. Validity at $k$ gives $c_k \le b_k - 1$.
Using the recurrences,
$$
V_b(c,k+1) = V_b(c,k) + c_k P_b(k) \le (P_b(k)-1) + (b_k-1)P_b(k) = b_k P_b(k) - 1
= P_b(k+1) - 1,
$$
so $V_b(c,k+1) < P_b(k+1)$. $\qquad\blacksquare$

Intuitively, a length-$k$ odometer with drifting bases rolls over exactly at
$P_b(k)$.

## 4. The Euclidean Splitting Identities

Because every column below the top has weight strictly under $P_b(k)$, integer
division by $P_b(k)$ separates the leading digit from the tail.

**Theorem 4.1 (Splitting by division).** If $\mathrm{Valid}_b(c,k+1)$, then
$$
\left\lfloor V_b(c,k+1) / P_b(k) \right\rfloor = c_k.
$$

*Proof.* Write $V_b(c,k+1) = V_b(c,k) + c_k P_b(k)$. By Theorem 3.2 (applied to
the length-$k$ truncation, valid by monotonicity), $V_b(c,k) < P_b(k)$, and by
Lemma 3.1 $P_b(k) > 0$. Hence $\lfloor V_b(c,k)/P_b(k)\rfloor = 0$, and
$$
\left\lfloor (V_b(c,k) + c_k P_b(k))/P_b(k)\right\rfloor = c_k +
\left\lfloor V_b(c,k)/P_b(k)\right\rfloor = c_k. \qquad\blacksquare
$$

**Theorem 4.2 (Splitting by remainder).** If $\mathrm{Valid}_b(c,k+1)$, then
$$
V_b(c,k+1) \bmod P_b(k) = V_b(c,k).
$$

*Proof.* Again $V_b(c,k+1) = V_b(c,k) + c_k P_b(k)$. The term $c_k P_b(k)$ is
divisible by $P_b(k)$, so the residue is $V_b(c,k) \bmod P_b(k)$, which equals
$V_b(c,k)$ since $V_b(c,k) < P_b(k)$ by Theorem 3.2. $\qquad\blacksquare$

## 5. Uniqueness

**Theorem 5.1 (Uniqueness of valid mixed-radix representations).** If
$\mathrm{Valid}_b(c,k)$, $\mathrm{Valid}_b(d,k)$, and $V_b(c,k) = V_b(d,k)$, then
$c_i = d_i$ for all $i < k$.

*Proof.* Induction on $k$. The base case $k=0$ is vacuous. For the inductive step,
assume the claim for $k$ and suppose the hypotheses hold for $k+1$. By Theorem 4.1
applied to both strings,
$$
c_k = \left\lfloor V_b(c,k+1)/P_b(k)\right\rfloor
    = \left\lfloor V_b(d,k+1)/P_b(k)\right\rfloor = d_k,
$$
using $V_b(c,k+1) = V_b(d,k+1)$. By Theorem 4.2 applied to both strings,
$$
V_b(c,k) = V_b(c,k+1) \bmod P_b(k) = V_b(d,k+1) \bmod P_b(k) = V_b(d,k).
$$
By monotonicity of validity and the inductive hypothesis, $c_i = d_i$ for all
$i<k$. Together with $c_k = d_k$, this gives $c_i = d_i$ for all $i < k+1$.
$\qquad\blacksquare$

The proof uses only the definition of validity, Theorems 3.2/4.1/4.2, and
induction. It does not invoke cardinality, surjectivity, or any bijection or
enumeration theorem — a point worth stressing, since it is what makes the theory
non-circular and lets existence be proved *afterward* without threat to
uniqueness.

## 6. Existence

**Definition 6.1 (Digit extraction).** For a base sequence $b$ and $n \in
\mathbb{N}$, define
$$
\mathrm{digit}_b(n)(i) \;=\; \left\lfloor n / P_b(i)\right\rfloor \bmod b_i.
$$

**Lemma 6.2 (Extracted digits are valid).** If $b_i > 0$ for all $i$, then
$\mathrm{Valid}_b(\mathrm{digit}_b(n), k)$ for all $n,k$.

*Proof.* $\mathrm{digit}_b(n)(i) = (\cdot) \bmod b_i < b_i$ whenever $b_i > 0$.
$\qquad\blacksquare$

**Theorem 6.3 (Existence / surjectivity).** If $n < P_b(k)$, then
$$
V_b(\mathrm{digit}_b(n), k) = n.
$$
No separate positivity hypothesis on the bases is needed: $n < P_b(k)$ already
forces $P_b(k) > 0$, whence each $b_i > 0$ for $i<k$.

*Proof.* One proves by induction on $m$ the telescoping identity
$$
n = \sum_{i<m} \big(\lfloor n/P_b(i)\rfloor \bmod b_i\big) P_b(i) \;+\;
\lfloor n/P_b(m)\rfloor \, P_b(m),
$$
using $\lfloor n/P_b(m+1)\rfloor = \lfloor \lfloor n/P_b(m)\rfloor / b_m\rfloor$
and the division algorithm $\lfloor n/P_b(m)\rfloor = (\lfloor n/P_b(m)\rfloor
\bmod b_m) + b_m\lfloor n/P_b(m)\rfloor$-type expansion at each step. Specializing
to $m = k$ and using $n < P_b(k) \Rightarrow \lfloor n/P_b(k)\rfloor = 0$ collapses
the trailing term, leaving $n = V_b(\mathrm{digit}_b(n), k)$. $\qquad\blacksquare$

**Corollary 6.4 (Bijection).** For every $k$, the map $c \mapsto V_b(c,k)$
restricts to a bijection between valid length-$k$ digit strings and the interval
$\{0,1,\dots,P_b(k)-1\}$.

*Proof.* Theorem 3.2 shows the image lands in the interval; Theorem 6.3 shows the
map is onto (via $\mathrm{digit}_b$); Theorem 5.1 shows it is injective.
$\qquad\blacksquare$

## 7. The Factorial Bridge

We now specialize to $b_i = i+1$ and connect to the factoradic definitions of 2.4.

**Lemma 7.1 (Running product is the factorial).** For $b_i = i+1$,
$$
P_b(k) = \prod_{j<k}(j+1) = k!.
$$

*Proof.* Induction on $k$: $P_b(0) = 1 = 0!$, and $P_b(k+1) = P_b(k)\cdot(k+1) =
k!\,(k+1) = (k+1)!$. $\qquad\blacksquare$

**Theorem 7.2 (Place values agree).** For all $c$ and $k$,
$$
V_{(i+1)}(c,k) = F(c,k) = \sum_{i<k} c_i\, i!.
$$

*Proof.* Term by term, $c_i\,P_b(i) = c_i\, i!$ by Lemma 7.1; sum over $i<k$.
$\qquad\blacksquare$

**Theorem 7.3 (Validity conditions agree).** For all $c$ and $k$,
$$
\mathrm{Valid}_{(i+1)}(c,k) \iff \mathrm{ValidF}(c,k).
$$

*Proof.* At each $i<k$ the two conditions are $c_i < i+1$ and $c_i \le i$, which
are equivalent for natural numbers. $\qquad\blacksquare$

**Theorem 7.4 (Factoradic uniqueness, re-derived).** If $\mathrm{ValidF}(c,k)$,
$\mathrm{ValidF}(d,k)$, and $F(c,k) = F(d,k)$, then $c_i = d_i$ for all $i<k$.

*Proof.* By Theorem 7.3 both strings are $\mathrm{Valid}_{(i+1)}$ up to $k$, and by
Theorem 7.2 their mixed-radix values coincide with their factoradic values, so
$V_{(i+1)}(c,k) = V_{(i+1)}(d,k)$. Apply the general uniqueness Theorem 5.1 with
$b_i = i+1$. $\qquad\blacksquare$

Thus the factoradic uniqueness theorem is *not* a separate fact but a strict
instance of the general theorem; the generalization genuinely subsumes the special
case rather than merely restating it. Correspondingly, factoradic existence — every
$n<k!$ has a unique valid length-$k$ factoradic string — is the specialization of
Corollary 6.4.

## 8. The Base-$N$ Instance and Boundary Cases

**Proposition 8.1 (Base-$N$).** For the constant base sequence $b_i = N$, the
running product is $P_b(k) = N^k$, and validity is the usual "each digit lies in
$\{0,\dots,N-1\}$." Standard base-$N$ uniqueness and existence are therefore also
instances of Theorems 5.1 and 6.3.

*Proof.* $\prod_{i<k} N = N^k$. $\qquad\blacksquare$

**Boundary — length zero.** At $k=0$, every value function collapses to the empty
sum $0$ and validity holds vacuously; the empty string represents $0$ in every
system simultaneously. This is the shared degenerate endpoint of the whole family.

**Boundary — a zero base.** If some $b_i = 0$, then no digit satisfies $c_i < 0$,
so $\mathrm{Valid}_b(c,k)$ is unsatisfiable for $k > i$. Every theorem quantified
over valid representations then holds without exception (vacuously true, not false):
the system simply has no valid strings reaching that column. The equivalence in
Theorem 7.3 also isolates the only *superficial* discrepancy between the two
conventions — the strict bound $c_i < i+1$ versus the non-strict bound $c_i \le i$ —
which are identical constraints on $\mathbb{N}$.

## 9. Applications

**Permutation ranking (Lehmer code).** Because valid length-$k$ factoradic strings
biject with $\{0,\dots,k!-1\}$ (Corollary 6.4 at $b_i=i+1$) and $k!$ counts the
permutations of $k$ symbols, the factoradic gives an explicit, arithmetic bijection
between integers and permutations. Under the Lehmer correspondence, the digit $c_i$
records how many of the yet-unused symbols are skipped at step $i$; counting up in
factoradic then enumerates permutations in lexicographic order. This yields $O(k)$
or $O(k\log k)$ **ranking** (permutation $\to$ index) and **unranking** (index $\to$
permutation) without materializing intermediate permutations — the standard route to
"give me the millionth permutation" queries.

**Variable-radix arithmetic and encodings.** The mixed-radix framing shows that any
sequence of positive bases yields a faithful positional encoding of an interval,
useful for combinatorial number systems, clock/calendar arithmetic (bases $60, 60,
24, \dots$), and product-space indexing where each coordinate has a distinct range.

**A single proof obligation.** Practically, one proves uniqueness/existence *once*,
generically, and reuses it across decimal, binary, factoradic, and bespoke
mixed-radix encodings, rather than re-establishing the same properties per system.

## 10. Discussion and Future Directions

The conceptual message is that *place value* — not any particular base — is what
guarantees unique representation. The digit-bound estimate (odometer rollover at the
running product) plus Euclidean splitting is the entire engine; the base sequence is
a parameter. The factorial system and base-$N$ numerals are two points in one family.

Several concrete directions follow.

1. **Uniqueness for every eventually-positive base sequence.** Conjecture: if
   $b_i \ge 1$ for all $i<k$, then every $n < P_b(k)$ has a unique valid length-$k$
   representation, and dropping positivity at a single index $i$ collapses the family
   from that index on while leaving the truncation below $i$ intact. Uniqueness never
   uses the specific running product, only its positivity — which one valid digit
   forces.

2. **Carry-free positional arithmetic.** Conjecture: there is an addition algorithm
   on length-$k$ mixed-radix strings whose per-position work depends only on the local
   bases $b_i, b_{i+1}$, producing the sum's representation without ever forming the
   integer value, correct precisely when the running products are positive. Place
   values factor multiplicatively through the running product, so a carry at position
   $i$ is governed solely by $b_i$.

3. **Factoradic digit sums as permutation statistics.** Conjecture: under the
   Lehmer bijection between $\{0,\dots,k!-1\}$ and permutations of $k$ letters, the
   factoradic digit sum of $n$ equals the number of inversions of the corresponding
   permutation, and the largest nonzero factoradic position equals the largest
   descent. The digit at position $i$ counts exactly the elements to its right that are
   smaller — a local inversion count.

4. **Growth of primitive parts.** Conjecture (from the companion investigation): for
   every composite $n > 12$, the Fibonacci number $F(n)$ has a primitive prime divisor,
   and the primitive part of $F(n)$ exceeds $n$ for all sufficiently large $n$, driven
   by the cyclotomic-type magnitude $\sim \varphi^{\phi(n)}$ eventually dwarfing any
   single absorbed prime factor.

## 11. Conclusion

We have given a self-contained, non-circular development of mixed-radix positional
number systems — uniqueness, existence, and their bijective consequence — and shown
that the factorial number system is precisely the mixed-radix instance $b_i = i+1$.
The three bridge theorems (place values agree, validity agrees, uniqueness inherited)
demonstrate that the classical factoradic results are corollaries of the general
theory, with base-$N$ numerals as a parallel instance. One theorem, proved once for a
drifting base, governs all of positional counting.
