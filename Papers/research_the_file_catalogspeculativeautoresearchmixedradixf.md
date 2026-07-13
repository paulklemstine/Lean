# A Unified Positional Numeration Theory: The Mixed-Radix Bijection and the Factorial Bridge

## Abstract

Positional numeral systems — ordinary base-$N$ notation, the factorial number
system (factoradics) used in combinatorics, and the mixed-radix representations
that appear in clocks, calendars, and computer arithmetic — are traditionally
developed as separate theories. We present a single parameterized theory that
subsumes all of them. Fixing an arbitrary sequence of bases $b_0, b_1, b_2,
\dots$ and the running products $P_k = \prod_{i<k} b_i$, we establish three
foundational facts uniformly: (i) every valid length-$k$ numeral has value below
$P_k$; (ii) every integer below $P_k$ is realized by explicit digit extraction
(existence); and (iii) distinct valid numerals have distinct values (uniqueness).
Combining existence and uniqueness yields a canonical bijection
$$\{0,1,\dots,P_k-1\} \;\cong\; \prod_{i<k}\{0,\dots,b_i-1\},$$
requiring no positivity hypothesis on the bases. Specializing $b_i = N$ recovers
the uniqueness and existence of standard positional notation; specializing
$b_i = i+1$, together with the telescoping identity $\prod_{i<k}(i+1) = k!$,
recovers the factorial number system and yields the combinatorial count
$\#\{\text{length-}k\text{ factoradic tuples}\} = k!$. In particular, the classical
uniqueness theorem for factoradics is derived strictly as a corollary of the
general uniqueness theorem — a genuine unification rather than a restatement. We
give definitions, full statements with proof sketches, algorithms for
conversion, applications to permutation ranking, and directions for extending the
theory to dynamics and order.

## 1. Introduction

A positional numeral system encodes an integer as a finite string of digits, each
weighted by a place value. The decimal system weights digits by powers of ten;
binary by powers of two. Less familiar but equally fundamental is the **factorial
number system**, or *factoradic*, in which the $i$-th place has value $i!$ and the
$i$-th digit ranges over $0, \dots, i$. Factoradics are the natural coordinates
for permutations: they underlie the ranking and unranking algorithms that convert
between an arrangement of $k$ objects and an integer in $\{0, \dots, k! - 1\}$.

These systems are usually presented in isolation, each with its own proofs of the
two properties every place-value system must have: **existence** (every number in
range has a representation) and **uniqueness** (the representation is one-of-a-kind).
The purpose of this paper is to show that all of them are instances of a single
**mixed-radix** theory, and that their foundational theorems are corollaries of
one general result. The unifying device is elementary but powerful: allow the base
to vary from place to place, track the running product of bases, and prove the two
properties once, for all base sequences simultaneously.

Our main structural result is a bijection between the integers below the running
product and the tuples of valid digits (Theorem 4.1). Existence and uniqueness are
its two halves. From it, ordinary numerals (Section 5) and factoradics (Section 6)
follow by specialization, and a combinatorial counting identity emerges as a
by-product (Theorem 4.2). A notable feature is that the bijection is stated and
proved with **no positivity assumption** on the bases: when a base is zero, both
sides collapse to the empty set and the statement holds vacuously.

## 2. Definitions

Throughout, $b : \mathbb{N} \to \mathbb{N}$ is a sequence of **bases** and
$k \in \mathbb{N}$ a length. Digit sequences are functions $c : \mathbb{N} \to
\mathbb{N}$; only the first $k$ entries matter for a length-$k$ numeral.

**Definition 2.1 (Running product).** The *running product* of the first $k$
bases is
$$ P_k \;=\; \operatorname{radixProd}(b, k) \;=\; \prod_{i<k} b_i, \qquad P_0 = 1. $$
It satisfies the recurrence $P_{k+1} = P_k \cdot b_k$.

**Definition 2.2 (Value).** The *value* of a digit sequence $c$ over $k$ places is
$$ \operatorname{value}(b, c, k) \;=\; \sum_{i<k} c_i \left( \prod_{j<i} b_j \right) \;=\; \sum_{i<k} c_i\, P_i. $$
The weight of place $i$ is the running product $P_i$ of all lower bases.

**Definition 2.3 (Validity).** A digit sequence $c$ is *valid* for $b$ over $k$
places, written $\operatorname{Valid}(b, c, k)$, if $c_i < b_i$ for all $i < k$.

**Definition 2.4 (Digit extraction).** The *digit map* extracts the $i$-th digit
of an integer $n$:
$$ \operatorname{digit}(b, n)_i \;=\; \left\lfloor \frac{n}{P_i} \right\rfloor \bmod b_i. $$
This is the formal counterpart of repeated division-with-remainder.

**Definition 2.5 (Specializations).**
- **Base-$N$:** the constant sequence $b_i = N$. Then $P_k = N^k$.
- **Factoradic:** the sequence $b_i = i + 1$. Then $P_k = k!$ (Lemma 3.1).

## 3. The telescoping hinge

The single identity connecting the general theory to factorials is the following.

**Lemma 3.1 (Factorial running product).** For all $k$,
$$ \operatorname{radixProd}(i \mapsto i+1,\; k) \;=\; \prod_{i<k} (i+1) \;=\; k!. $$

*Proof.* Induction on $k$. The base case is $P_0 = 1 = 0!$. For the step,
$P_{k+1} = P_k \cdot (k+1) = k! \cdot (k+1) = (k+1)!$ by the recurrence for the
running product and the definition of the factorial. $\square$

For completeness we record the parallel identity for constant bases.

**Lemma 3.2 (Base-$N$ running product).**
$\operatorname{radixProd}(i \mapsto N,\; k) = N^k.$

*Proof.* Immediate induction: $P_{k+1} = P_k \cdot N = N^k \cdot N = N^{k+1}$. $\square$

Lemma 3.1 is the crux of the entire unification. Because the factoradic place
values are exactly the running products $P_i = i!$, the factoradic is not merely
*analogous* to a positional system — it *is* the mixed-radix system with bases
$b_i = i + 1$, and every general theorem applies to it verbatim.

## 4. The general theory

We first record the two foundational facts, then package them into a bijection.

**Proposition 4.1 (Boundedness).** If $c$ is valid over $k$ places, then
$\operatorname{value}(b, c, k) < P_k$.

*Proof sketch.* Induction on $k$. For $k = 0$ the value is $0 < 1 = P_0$. For the
step, split the sum: $\operatorname{value}(b, c, k+1) = \operatorname{value}(b, c, k)
+ c_k P_k$. By the inductive hypothesis the first term is $\le P_k - 1$, and
validity gives $c_k \le b_k - 1$, so the total is at most
$(P_k - 1) + (b_k - 1)P_k = b_k P_k - 1 = P_{k+1} - 1 < P_{k+1}$. $\square$

**Proposition 4.2 (Existence).** For every $n < P_k$,
$$ \operatorname{value}\big(b,\; \operatorname{digit}(b, n),\; k\big) \;=\; n. $$
That is, extracting the digits of $n$ and re-evaluating returns $n$.

*Proof sketch.* Induction on $k$, unwinding the division algorithm. The identity
$n = P_k \lfloor n / P_k \rfloor + (n \bmod P_k)$ organizes the digits so that the
low $k$ digits reconstruct $n \bmod P_k$ and the leading digit accounts for the
quotient; when $n < P_k$ the quotient contributions vanish and the sum telescopes
back to $n$. The digits produced are automatically valid because each is reduced
modulo its base. $\square$

**Proposition 4.3 (Uniqueness).** If $c$ and $d$ are both valid over $k$ places
and $\operatorname{value}(b, c, k) = \operatorname{value}(b, d, k)$, then
$c_i = d_i$ for all $i < k$.

*Proof sketch.* The value is $\sum_{i<k} c_i P_i$ with $0 \le c_i < b_i$ and place
weights $P_i$ satisfying $P_{i+1} = b_i P_i$. This is precisely a base-mixed radix
representation, so reducing the common value modulo $P_1 = b_0$ isolates $c_0 =
d_0$; subtracting and dividing by $b_0$ reduces to the same problem over
$b_1, b_2, \dots$ with $k - 1$ places, and induction finishes. Equivalently, both
digit sequences equal $\operatorname{digit}(b, n)$ for their common value $n$ by
Proposition 4.2. $\square$

We now assemble these into the central object.

**Theorem 4.1 (The mixed-radix bijection).** For every base sequence $b$ and
length $k$ there is a bijection
$$ \Phi : \{0, 1, \dots, P_k - 1\} \;\xrightarrow{\ \cong\ }\; \prod_{i<k} \{0, 1, \dots, b_i - 1\}, $$
where the codomain is the set of valid digit tuples. The forward map sends $n$ to
its tuple of extracted digits, $\Phi(n)_i = \operatorname{digit}(b, n)_i$, and the
inverse map sends a valid tuple $c$ to $\operatorname{value}(b, \bar c, k)$, where
$\bar c$ pads $c$ with zeros beyond place $k$.

*Proof sketch.* The forward map is well defined: each extracted digit
$\operatorname{digit}(b,n)_i = \lfloor n/P_i\rfloor \bmod b_i$ lies in
$\{0,\dots,b_i-1\}$ whenever $b_i > 0$, and positivity of every in-range base is
forced by $P_k > 0$ (which holds because $n < P_k$). The inverse map is well
defined by Proposition 4.1 (padded tuples have value $< P_k$). That the two maps
are mutually inverse is exactly the pair of foundational propositions:
composing inverse-then-forward and using Proposition 4.3 recovers the original
tuple (injectivity of evaluation), while composing forward-then-inverse and using
Proposition 4.2 recovers the original integer (existence). No positivity
hypothesis on $b$ is needed: if some $b_i = 0$ then $P_k = 0$, both sides are
empty, and the empty map is trivially a bijection. $\square$

**Theorem 4.2 (Counting identity).** The number of valid length-$k$ digit tuples
equals the running product:
$$ \#\Big( \prod_{i<k} \{0,\dots,b_i-1\} \Big) \;=\; \prod_{i<k} b_i \;=\; P_k. $$

*Proof.* The codomain of $\Phi$ is a finite product of sets of sizes $b_0, \dots,
b_{k-1}$, hence has cardinality $\prod_{i<k} b_i$. By Theorem 4.1 it is in
bijection with $\{0, \dots, P_k - 1\}$, which has $P_k$ elements. $\square$

Theorem 4.2 gives the running product a purely combinatorial meaning: the bound
$P_k$ that controls the arithmetic is *also* the count of admissible digit
tuples.

## 5. Corollary: ordinary base-$N$ numerals

Specializing to the constant base sequence $b_i = N$ and using $P_k = N^k$
(Lemma 3.2) recovers the classical foundations of positional notation.

**Corollary 5.1 (Uniqueness of base-$N$ numerals).** If $c$ and $d$ are digit
sequences with $c_i, d_i < N$ for all $i < k$ and they have the same base-$N$
value $\sum_{i<k} c_i N^i = \sum_{i<k} d_i N^i$, then $c_i = d_i$ for all $i < k$.

*Proof.* Immediate from Proposition 4.3 with $b_i = N$. $\square$

**Corollary 5.2 (Existence of base-$N$ numerals).** Every $n < N^k$ equals the
base-$N$ value of its own extracted digits.

*Proof.* Proposition 4.2 with $b_i = N$, using $P_k = N^k$. $\square$

**Corollary 5.3 (Base-$N$ bijection).** There is a bijection
$$ \{0, 1, \dots, N^k - 1\} \;\cong\; \{0, \dots, N-1\}^k. $$

*Proof.* Theorem 4.1 with $b_i = N$, transported along $P_k = N^k$. $\square$

These are the standard statements that a $k$-digit base-$N$ string is a faithful,
lossless encoding of exactly the integers $0$ through $N^k - 1$.

## 6. Corollary: the factorial number system

Specializing to $b_i = i + 1$ and invoking the hinge $P_k = k!$ (Lemma 3.1)
recovers the factoradic. Two small **bridge lemmas** align the general definitions
with the classical factoradic ones.

**Lemma 6.1 (Value bridge).** For bases $b_i = i + 1$, the mixed-radix value
coincides with the factoradic value:
$$ \operatorname{value}(i \mapsto i+1,\; c,\; k) \;=\; \sum_{i<k} c_i \cdot i!. $$

*Proof.* Term-by-term the place weight is $P_i = \prod_{j<i}(j+1) = i!$ by
Lemma 3.1; summing over $i < k$ gives the claim. $\square$

**Lemma 6.2 (Validity bridge).** Mixed-radix validity for $b_i = i+1$ coincides
with factoradic validity: $c_i < i + 1 \iff c_i \le i$.

*Proof.* The two inequalities are equivalent for natural numbers
($c_i < i + 1$ iff $c_i \le i$). $\square$

**Corollary 6.3 (Uniqueness of factoradics, derived).** If $c$ and $d$ satisfy
$c_i \le i$ and $d_i \le i$ for all $i < k$ and
$\sum_{i<k} c_i\, i! = \sum_{i<k} d_i\, i!$, then $c_i = d_i$ for all $i < k$.

*Proof.* Translate the hypotheses through Lemmas 6.1 and 6.2 into mixed-radix form
for $b_i = i+1$ and apply the general uniqueness theorem, Proposition 4.3. $\square$

We emphasize that Corollary 6.3 is obtained *purely* from the general Proposition
4.3, transported along the bridge lemmas; it does not invoke any independent
factoradic uniqueness result. This confirms that the mixed-radix theory genuinely
subsumes the factorial system rather than merely paralleling it, and the
derivation is non-circular.

**Corollary 6.4 (Factoradic bijection).** There is a bijection
$$ \{0, 1, \dots, k! - 1\} \;\cong\; \{0\} \times \{0,1\} \times \cdots \times \{0, \dots, k-1\} \;=\; \prod_{i<k} \{0, \dots, i\}. $$

*Proof.* Theorem 4.1 with $b_i = i+1$, transported along $P_k = k!$. $\square$

**Corollary 6.5 (Factoradic count).** The number of valid length-$k$ factoradic
tuples is $k!$:
$$ \#\Big( \prod_{i<k} \{0, \dots, i\} \Big) \;=\; k!. $$

*Proof.* Theorem 4.2 with $b_i = i+1$ and $P_k = k!$. $\square$

Corollary 6.5 is the combinatorial punchline: factoradic tuples of length $k$ are
in bijection with a set of size $k!$, matching the number of permutations of $k$
objects — the reason the factoradic is the canonical index system for
permutations.

## 7. Algorithms

The constructive proofs above yield conversion algorithms directly.

**Algorithm 7.1 (Encode: integer $\to$ mixed-radix tuple).** Given bases $b$ and
$n < P_k$, produce the digit tuple.
```
for i = 0, 1, ..., k-1:
    c[i] = n mod b[i]
    n    = n div b[i]
return (c[0], ..., c[k-1])
```
Correctness is Proposition 4.2; the loop realizes $\operatorname{digit}(b, n)$ by
successive division. Complexity: $O(k)$ big-integer operations.

**Algorithm 7.2 (Decode: mixed-radix tuple $\to$ integer).** Given valid digits
$c$, produce $\operatorname{value}(b, c, k) = \sum_i c_i P_i$ by Horner's rule
from the top:
```
n = 0
for i = k-1, k-2, ..., 0:
    n = n * b[i] + c[i]
return n
```
Correctness is the definition of value; Horner's scheme factors the place weights.
Complexity: $O(k)$.

Setting $b_i = i + 1$ turns these into the factoradic encode/decode routines, and
setting $b_i = N$ into standard radix conversion. The pair are exact inverses by
Theorem 4.1.

## 8. Applications

**Permutation ranking and unranking.** The factoradic bijection (Corollary 6.4)
is the engine of permutation enumeration. A factoradic tuple $(c_0, \dots,
c_{k-1})$ with $c_i \le i$ is precisely a *Lehmer code*, which selects, at each
step, the $c_i$-th remaining element. Composing the factoradic bijection with the
Lehmer-code correspondence gives an explicit, computable order isomorphism between
$\{0, \dots, k! - 1\}$ and the $k!$ permutations of a $k$-element set. This is used
in scheduling, randomized testing, and any setting that must address arrangements
by a single integer.

**Uniform mixed bases in the wild.** Timekeeping ($b = (60, 60, 24, 7, \dots)$),
calendars, and byte/word layouts are all mixed-radix systems; Theorem 4.1
guarantees their conversions are lossless and unambiguous with no per-system proof.

**A single foundation for arithmetic.** Because existence, uniqueness, and the
counting identity are proved once, any downstream development — carry propagation,
comparison, canonical forms — can be built against the general interface and
inherited by every specialization simultaneously.

## 9. Discussion

The technical heart of the unification is twofold. First, allowing the base to
vary per place turns three separately proved theories into one. Second, the
telescoping identity $\prod_{i<k}(i+1) = k!$ (Lemma 3.1) identifies the factoradic
place values with the running products, so that factoradics become a literal
instance rather than an analogy. The resulting bijection (Theorem 4.1) is the
cleanest possible expression of "a number is its digits," and the counting
identity (Theorem 4.2) reinterprets the arithmetic bound $P_k$ combinatorially.

A design choice worth highlighting is the deliberate absence of a positivity
hypothesis on the bases. Many treatments of positional systems assume every base
exceeds $1$; here the degenerate case $b_i = 0$ is absorbed automatically, since
it forces $P_k = 0$ and empties both sides of the bijection. This makes the theory
total and reduces the number of special cases downstream.

## 10. Future directions

- **Permutation ranking.** Compose the factoradic bijection with the Lehmer-code
  correspondence to obtain an explicit order isomorphism between $\{0,\dots,k!-1\}$
  and the permutations of a $k$-element set — a third, combinatorial face of the
  same theory.
- **Carry propagation and successor dynamics.** Formalize the "add one with
  carries" successor map on digit tuples and prove it corresponds under the
  bijection to $n \mapsto n + 1 \pmod{P_k}$, upgrading the static correspondence
  to an isomorphism of cyclic successor structures.
- **Monotonicity and order.** Prove that the bijection is an order isomorphism
  when the tuple side carries the appropriate (reverse-)lexicographic order,
  connecting numeric magnitude to dictionary order on digits.

## 11. Conclusion

A single mixed-radix theory — bases that may vary per place, weighted by running
products — provides existence, uniqueness, and a counting identity that hold for
every positional system at once. Its central bijection specializes to the
foundations of ordinary base-$N$ notation and, via the telescoping identity
$\prod_{i<k}(i+1) = k!$, to the factorial number system, whose classical
uniqueness theorem is recovered strictly as a corollary. What appear to be
distinct numeration systems are two windows onto one parameterized structure.
