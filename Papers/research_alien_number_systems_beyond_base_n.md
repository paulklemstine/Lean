# A Direct, Non-Circular Proof of Uniqueness for the Factorial Number System

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Computation

## Abstract

The factorial number system (factoradic) represents a natural number $n$ as a mixed-radix
expansion $n = \sum_{i} c_i \cdot i!$ subject to the per-position digit bound $c_i \le i$.
Like every positional numeral system, its usefulness rests on a uniqueness theorem:
distinct legal digit strings denote distinct numbers. The standard proofs of this fact are
*indirect*, routing through a counting/cardinality argument (there are $k!$ legal length-$k$
strings and $k!$ integers below $k!$, hence the encoding is a bijection). We present and
formally verify a **direct, local** proof that never counts anything. It rests on two
ingredients: (i) a tight digit-bound estimate showing that a valid length-$k$ value is
strictly below $k!$, and (ii) two mixed-radix *splitting identities* recovering the top
digit by division and the lower part by remainder. Uniqueness then follows by a one-line
induction. We additionally give an explicit digit-extraction map and prove an existence
(surjectivity) theorem: every $n < k!$ equals the factoradic value of its own extracted
digits. We discuss the algorithmic content (streaming encode/decode), the connection to
Lehmer codes and permutation ranking, and a uniform generalization to arbitrary
mixed-radix systems. All results have been formally verified in Lean 4 with Mathlib.

---

## 1. Introduction

A positional numeral system is, abstractly, a choice of *place values* $w_0, w_1, w_2, \dots$
together with *digit bounds* that prevent two strings from denoting the same quantity. The
familiar base-$N$ systems take $w_i = N^i$ and digits in $\{0, \dots, N-1\}$. The factorial
number system is the canonical *mixed-radix* system: the place values are the factorials
$w_i = i!$ and the digit in position $i$ is bounded by $i$.

The factorial number system is more than a curiosity. It is the arithmetic backbone of the
Lehmer code, the classical bijection between integers in $\{0, \dots, n!-1\}$ and the
permutations of an $n$-element set, and it therefore underlies constant-space permutation
ranking/unranking used in combinatorial generation. Its correctness — as a numeral system —
is the assertion that the encoding is a bijection, whose heart is *uniqueness*: no two legal
digit strings denote the same number.

**Contribution.** We give a proof of uniqueness that is *direct and non-circular*: it does
not pass through surjectivity, cardinality, `Finset.card`, or any bijection/enumeration
theorem. The argument is purely local — it shows each digit can be recovered by a single
division-with-remainder — and is therefore both shorter and more reusable than the usual
counting argument. We complement uniqueness with an explicit extraction map and an existence
theorem, recovering the full bijection while keeping the uniqueness proof self-standing.

All statements below are formalized in Lean 4 over Mathlib. We present them here with
ordinary mathematical notation and proof sketches.

---

## 2. Definitions

Throughout, digit functions are maps $c : \mathbb{N} \to \mathbb{N}$, and $k!$ denotes the
factorial of $k$.

**Definition 2.1 (Factoradic value).** The *length-$k$ factoradic value* of a digit function
$c$ is
$$\operatorname{value}(c, k) \;=\; \sum_{i \in \{0, \dots, k-1\}} c_i \cdot i!.$$

**Definition 2.2 (Validity).** A digit function $c$ is *valid up to length $k$*, written
$\operatorname{Valid}(c, k)$, if
$$\forall i < k, \quad c_i \le i.$$

Two immediate structural facts:

- **Base case.** $\operatorname{value}(c, 0) = 0$ (empty sum).
- **Recurrence (peeling the top digit).**
  $$\operatorname{value}(c, k+1) = \operatorname{value}(c, k) + c_k \cdot k!.$$
- **Monotonicity of validity.** If $\operatorname{Valid}(c, k+1)$ then
  $\operatorname{Valid}(c, k)$, since the bound holds for a superset of indices.

**Definition 2.3 (Explicit digit extraction).** For a natural number $n$, define
$$\operatorname{digit}(n, i) \;=\; \left\lfloor \frac{n}{i!} \right\rfloor \bmod (i+1).$$

This is the candidate inverse map: given $n$, it reads off the factoradic digits directly.

---

## 3. Main Results

### 3.1 The digit-bound estimate

**Theorem 3.1 (`value_lt`).** If $\operatorname{Valid}(c, k)$ then
$$\operatorname{value}(c, k) < k!.$$

*Proof sketch.* Induction on $k$. The base case $k = 0$ is $0 < 1$. For the step, assume
$\operatorname{value}(c, k) < k!$ under $\operatorname{Valid}(c, k)$. By the recurrence,
$$\operatorname{value}(c, k+1) = \operatorname{value}(c, k) + c_k \cdot k! < k! + c_k \cdot k!
  = (1 + c_k)\,k!.$$
Since validity gives $c_k \le k$, we have $1 + c_k \le k + 1$, hence
$\operatorname{value}(c, k+1) < (k+1)\,k! = (k+1)!$. $\quad\blacksquare$

The estimate is tight: maximizing every digit gives
$\sum_{i=0}^{k-1} i \cdot i! = k! - 1$, so the length-$k$ values cover exactly
$\{0, 1, \dots, k!-1\}$.

This theorem is the only quantitative input to everything that follows, and it is proved
using nothing but the definition of validity and elementary inequalities.

### 3.2 The mixed-radix splitting identities

**Theorem 3.2 (`splitting_div`).** If $\operatorname{Valid}(c, k+1)$ then
$$\left\lfloor \frac{\operatorname{value}(c, k+1)}{k!} \right\rfloor = c_k.$$

*Proof sketch.* By the recurrence,
$\operatorname{value}(c, k+1) = \operatorname{value}(c, k) + c_k \cdot k!$. Divide by $k!$:
the term $c_k \cdot k!$ contributes exactly $c_k$, and the residual
$\lfloor \operatorname{value}(c, k) / k! \rfloor = 0$ because, by Theorem 3.1 applied to the
truncation $\operatorname{Valid}(c, k)$, we have $\operatorname{value}(c, k) < k!$.
$\quad\blacksquare$

**Theorem 3.3 (`splitting_mod`).** If $\operatorname{Valid}(c, k+1)$ then
$$\operatorname{value}(c, k+1) \bmod k! = \operatorname{value}(c, k).$$

*Proof sketch.* Again by the recurrence, $\operatorname{value}(c, k+1)$ differs from
$\operatorname{value}(c, k)$ by a multiple of $k!$, so they are congruent mod $k!$. Since
$\operatorname{value}(c, k) < k!$ (Theorem 3.1), the remainder equals
$\operatorname{value}(c, k)$ exactly. $\quad\blacksquare$

Together these say: the top digit is the quotient by the leading place value, and the lower
part is the remainder. They are the loop invariant of any streaming positional decoder.

### 3.3 Uniqueness — the central theorem

**Theorem 3.4 (`value_unique`).** If $\operatorname{Valid}(c, k)$,
$\operatorname{Valid}(d, k)$, and $\operatorname{value}(c, k) = \operatorname{value}(d, k)$,
then $c_i = d_i$ for all $i < k$.

*Proof sketch.* Induction on $k$. The base case $k = 0$ is vacuous (no index $i < 0$).

For the step, suppose the values agree at length $k+1$. Applying $\operatorname{splitting\_div}$
to both sides recovers the top digits:
$$c_k = \left\lfloor \frac{\operatorname{value}(c, k+1)}{k!} \right\rfloor
      = \left\lfloor \frac{\operatorname{value}(d, k+1)}{k!} \right\rfloor = d_k.$$
Applying $\operatorname{splitting\_mod}$ to both sides reduces the equality to the tails:
$$\operatorname{value}(c, k) = \operatorname{value}(c, k+1) \bmod k!
  = \operatorname{value}(d, k+1) \bmod k! = \operatorname{value}(d, k).$$
The induction hypothesis (with the truncated validity from monotonicity) gives $c_i = d_i$
for all $i < k$. Combined with $c_k = d_k$, this covers all $i < k+1$. $\quad\blacksquare$

**Non-circularity.** The proof uses only Theorems 3.1–3.3, each of which is established from
arithmetic and the definition of validity. It does *not* invoke surjectivity, cardinality,
counting, or any bijection/enumeration result. In the formal development the optional
existence and extraction results (Section 3.4) are declared strictly *after* `value_unique`,
so they cannot participate in its proof.

### 3.4 Explicit extraction and existence

**Theorem 3.5 (`digit_valid`).** For every $n$ and $k$, the extracted digit function
$\operatorname{digit}(n, \cdot)$ is valid up to length $k$.

*Proof sketch.* By definition $\operatorname{digit}(n, i) = (\lfloor n/i! \rfloor) \bmod (i+1)$
is a remainder modulo $i+1$, hence at most $i$. $\quad\blacksquare$

**Theorem 3.6 (`value_digit`, existence/surjectivity).** If $n < k!$ then
$$\operatorname{value}(\operatorname{digit}(n, \cdot), k) = n.$$

*Proof sketch.* One proves the telescoping identity, for all $k$,
$$n = \left(\sum_{i=0}^{k-1} \left(\left\lfloor \tfrac{n}{i!}\right\rfloor \bmod (i+1)\right) i!\right)
      + \left\lfloor \frac{n}{k!} \right\rfloor \cdot k!,$$
by induction on $k$ using the quotient/remainder decomposition
$\lfloor n/i! \rfloor = (\lfloor n/i!\rfloor \bmod (i+1)) + (i+1)\lfloor n/(i+1)! \rfloor$ at
each step (note $(i+1)! = (i+1)\cdot i!$). Specializing to the given $k$ and using
$n < k! \Rightarrow \lfloor n/k! \rfloor = 0$ kills the trailing term, leaving
$n = \operatorname{value}(\operatorname{digit}(n,\cdot), k)$. $\quad\blacksquare$

**Corollary 3.7 (Bijection).** The map sending a valid length-$k$ digit function to its
value is a bijection between valid length-$k$ digit strings and $\{0, 1, \dots, k!-1\}$.
Injectivity is `value_unique` (Theorem 3.4); surjectivity is `value_digit` (Theorem 3.6)
together with the range bound `value_lt` (Theorem 3.1).

---

## 4. Algorithms

The splitting identities are not merely proof tools; they *are* the conversion algorithms.

### 4.1 Encoding (integer → factoradic)

Repeatedly divide by an increasing sequence of moduli. To encode $n$ into $k$ digits:

```
ENCODE(n, k):
  for i = 1 to k:
    c[i-1] = n mod i        # digit in position i-1 is bounded by i-1
    n      = n div i
  return c
```

The loop invariant is exactly $\operatorname{splitting\_mod}$ / $\operatorname{splitting\_div}$
restated for the running quotient. Each step costs one division; total work is $O(k)$
big-integer divisions (or $O(k^2)$ machine operations on $k$-digit numbers). This is more
efficient than naively evaluating $\operatorname{digit}(n,i) = \lfloor n/i!\rfloor \bmod (i+1)$,
which recomputes growing factorials.

### 4.2 Decoding (factoradic → integer)

A Horner-style fold reconstructs the value without materializing factorials:

```
DECODE(c, k):
  acc = 0
  for i = k-1 down to 1:
    acc = (acc + c[i]) * i    # combines place values incrementally
  return acc + c[0]
```

This computes $\operatorname{value}(c, k)$ in $O(k)$ multiply–adds. Correctness is the
recurrence of Definition 2.1 read in reverse.

### 4.3 Lehmer code (permutation ↔ integer)

To rank a permutation $\pi$ of $\{0, \dots, n-1\}$: compute the inversion-count vector
$L_i = \#\{j > i : \pi_j < \pi_i\}$, which satisfies $0 \le L_i \le n-1-i$ — a valid
factoradic digit string — then decode it. To unrank an integer $r < n!$: encode $r$ into a
factoradic string and convert the digit vector back to a permutation by repeated
selection-and-deletion. `value_unique` guarantees ranking is injective; `value_digit`
guarantees every rank is realized.

---

## 5. Applications

- **Constant-space permutation iteration.** Unranking lets a generator emit the $r$-th
  permutation directly, enabling parallel enumeration (each worker handles a contiguous range
  of ranks) and random sampling of permutations via a single uniform draw in $[0, n!)$.
- **Combinatorial compression.** A permutation of $n$ items carries $\log_2(n!)$ bits of
  information; the factoradic/Lehmer encoding attains this bound, giving an
  information-optimal serialization of orderings.
- **Mixed-radix arithmetic.** The same splitting machinery underlies primorial-base systems
  used in residue number systems and Cantor's mixed-radix expansions appearing in
  combinatorics and cryptographic encodings.
- **Verified solvers.** A formally verified, executable unranking routine supplies
  proof-producing search and SAT/SMT preprocessing with a trustworthy, constant-space
  iterator over permutations.

---

## 6. Discussion

The contrast between the *counting* proof and the *splitting* proof of uniqueness is
instructive. The counting proof establishes a bijection by matching two finite sets of the
same cardinality; it is global and inherently tied to the finiteness of the index range. The
splitting proof is local: it shows that *each individual digit is a computable function of the
value* (quotient and remainder), so two strings with equal value must agree digit by digit.
The local view is more robust — it generalizes verbatim to systems where global counting is
awkward — and it is constructive, since the extraction it describes is literally the decoding
algorithm.

A subtle but important point in the formal development is *non-circularity*. It is easy to
write a uniqueness proof that secretly relies on surjectivity (e.g., "the map is a bijection,
hence injective"), which inverts the logical dependency one usually wants. Here, `value_unique`
depends only on `value_lt`, `splitting_div`, and `splitting_mod`, all of which are pure
arithmetic; the existence results are quarantined after it. This makes uniqueness usable as a
standalone lemma — for instance, to certify ranking injectivity without first building the
entire bijection.

---

## 7. Future Directions

**A uniform theory of mixed-radix positional systems.** The splitting argument is not special
to factorials: it works for any sequence of place values $w_0 = 1$, $w_{i+1} = b_i \cdot w_i$
with per-position digit bound $c_i < b_i$. One can abstract `value`, `Valid`, `value_lt`,
`splitting_div`, `splitting_mod`, and `value_unique` over an arbitrary base sequence
$b : \mathbb{N} \to \mathbb{N}$ with $b_i \ge 1$, recovering standard base-$B$ numerals
($b_i = B$), factoradics ($b_i = i+1$), and primorial/Cantor systems as instances. Uniqueness
of a positional representation depends only on the local quotient–remainder splitting at each
place value, never on global counting, so a single generic proof subsumes every mixed-radix
system at once.

**Verified Lehmer codes and permutation (un)ranking.** Building on `value_unique` and
`value_digit`, one can define `rank`/`unrank` functions, prove they are mutually inverse, and
certify lexicographic monotonicity of the ranking. The inversion-count vector of a permutation
is exactly a valid digit function, so the already-proven uniqueness and existence theorems
transfer the bijection from numbers to permutations with no new counting argument.

**Extraction of certified, efficient conversion algorithms.** The `digit` extractor and
`value` reconstructor are mathematically clean but not optimized; naive evaluation recomputes
factorials. One can give a tail-recursive, single-pass division algorithm for encoding and a
Horner-style pass for decoding, prove these refine `value`/`digit`, and extract them to
executable code. The splitting identities `splitting_div` and `splitting_mod` are exactly the
loop invariant of the streaming algorithm, so correctness is a direct corollary of existing
lemmas rather than a fresh induction.

---

## 8. Conclusion

We have given a direct, non-circular proof that the factorial number system represents every
natural number uniquely, resting only on a tight digit-bound estimate and two
quotient/remainder splitting identities. The same identities furnish efficient encoding and
decoding algorithms and connect the system to permutation ranking via the Lehmer code. The
local, splitting-based viewpoint generalizes cleanly to arbitrary mixed-radix systems, pointing
toward a single uniform uniqueness theorem for all positional numeral systems.
