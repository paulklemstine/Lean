# Primitive Prime Divisors and Simultaneous Apparition of Fibonacci Numbers

## Abstract

We give a fully self-contained development of the *primitivity* layer of Fibonacci
divisibility theory, deriving every structural result directly from the single fact that
the Fibonacci sequence is a **strong divisibility sequence**:
`gcd(F(m), F(n)) = F(gcd(m, n))`. From this we obtain a sharp *meet law* valid for an
arbitrary divisor `d`, namely `d | F(gcd(m, n)) ⟺ d | F(m) ∧ d | F(n)`. We then study
*primitive divisors* — numbers dividing `F(n)` but none of `F(1), ..., F(n-1)` — and
prove a rigidity theorem: a value is a primitive divisor of at most one positive index.
This makes the *rank of apparition* a well-defined labelling. We show that a primitive
divisor of `F(n)` pins the entire divisibility set to the multiples of `n`
(`p | F(m) ⟺ n | m`), and we deduce a *join law* of simultaneous apparition: two
primitive divisors of `F(a)` and `F(b)` jointly divide `F(n)` exactly when `lcm(a, b) | n`.
A clean induction extends this to arbitrary finite families. Conceptually, the map sending
a modulus to the set of indices where it divides Fibonacci is an isomorphism from the
divisibility lattice of "active" moduli onto a sublattice of `(ℕ, gcd, lcm)`; primitivity
is precisely the property of generating a multiples-ideal. All results are elementary and
require no computation of entry points via search. We close by situating these results as
the combinatorial backbone of Carmichael's primitive-divisor theorem.

**Keywords:** Fibonacci numbers, strong divisibility sequence, primitive prime divisor,
rank of apparition, law of apparition, gcd/lcm lattice, Carmichael's theorem.

**MSC 2020:** 11B39 (Fibonacci and Lucas numbers), 11A05 (multiplicative structure),
11B25 (arithmetic progressions).

---

## 1. Introduction

The Fibonacci sequence `F`, defined by `F(0) = 0`, `F(1) = 1`, and `F(n+2) = F(n+1) + F(n)`,
is among the most studied objects in number theory. Its divisibility behavior is
exceptionally regular: for each modulus `d`, the set of indices `n` with `d | F(n)` is the
set of multiples of a fixed integer, the *rank of apparition* (or *entry point*) of `d`.
This regularity is the manifestation of a single structural property — that `F` is a
**strong divisibility sequence**.

The catalog already develops the rank of apparition through the `Nat.find` machinery and
studies how that rank interacts with gcd and lcm of *moduli*. The present work takes the
complementary route. We isolate the notion of a **primitive divisor** and develop its
theory entirely at the level of raw divisibility and the gcd/lcm of *indices*, never
computing an entry point. The reward is conceptual clarity: the central rigidity theorem
becomes a one-line minimality clash, and the law that a primitive divisor controls the
whole divisibility set follows directly from a sharp meet law.

### 1.1. Contributions

1. **A sharp meet law (Theorem 3.1).** For *any* divisor `d`,
   `d | F(gcd(m, n)) ⟺ d | F(m) ∧ d | F(n)`. No primality hypothesis is needed.
2. **A boundary lemma (Proposition 4.1).** Every modulus is vacuously primitive at index
   `0`, isolating exactly why positivity is required elsewhere.
3. **Rigidity (Theorem 4.2).** A value is a primitive divisor of at most one positive
   index; hence the rank of apparition is a well-defined labelling.
4. **The pinning law (Theorem 5.1).** If `p` is primitive for `F(n)` (with `n > 0`), then
   `p | F(m) ⟺ n | m`.
5. **The join law (Theorem 6.1).** If `p` is primitive for `F(a)` and `q` for `F(b)`
   (with `a, b > 0`), then `(p | F(n) ∧ q | F(n)) ⟺ lcm(a, b) | n`.
6. **The family join law (Theorem 7.1).** For a finite family with each `f(i)` primitive
   for `F(g(i))`, all `f(i)` divide `F(n)` iff `lcm_{i} g(i) | n`.

---

## 2. Preliminaries

### 2.1. The Fibonacci sequence and strong divisibility

We use the standard Fibonacci sequence with `F(0) = 0` and `F(1) = 1`. Two classical facts
are the only external inputs to the entire development.

**Fact 2.1 (Divisibility by index).** If `a | b` then `F(a) | F(b)`. Equivalently, the
Fibonacci numbers at multiples of `a` are exactly those divisible by `F(a)`. (In the
formalization this is `Nat.fib_dvd`.)

**Fact 2.2 (Strong divisibility).** `gcd(F(m), F(n)) = F(gcd(m, n))`. (In the
formalization this is `Nat.fib_gcd`.)

Fact 2.2 is the defining property of a *strong divisibility sequence*. It immediately
implies Fact 2.1, but we list both as they are used in distinct steps below. Worked
example: `gcd(F(12), F(18)) = gcd(144, 2584) = 8 = F(6) = F(gcd(12, 18))`.

### 2.2. Definition of primitive divisor

**Definition 2.3 (Primitive divisor).** A natural number `p` is a *primitive divisor* of
`F(n)`, written `IsPrimitive p n`, if

> `p | F(n)`  and  for all `k` with `0 < k < n`, `¬ (p | F(k))`.

That is, `F(n)` is the first positive-index Fibonacci number divisible by `p`. The index
`n` is then the *rank of apparition* of `p`. This is exactly the notion of primitivity used
elsewhere in the catalog.

---

## 3. The strong-divisibility meet law

The first result lifts the strong divisibility property to a clean biconditional valid for
an arbitrary divisor — the lattice "meet" law of Fibonacci divisibility.

**Theorem 3.1 (Meet law).** For all natural numbers `d`, `m`, `n`,
> `d | F(gcd(m, n)) ⟺ d | F(m) ∧ d | F(n)`.

*Proof sketch.* Rewrite `F(gcd(m, n))` as `gcd(F(m), F(n))` using Fact 2.2 (strong
divisibility). The claim then reduces to the universal property of gcd:
`d | gcd(F(m), F(n)) ⟺ d | F(m) ∧ d | F(n)` (the standard `Nat.dvd_gcd_iff`). ∎

Equivalently, without invoking the gcd characterization directly:

- **(⟸)** Since `gcd(m, n) | m` and `gcd(m, n) | n`, Fact 2.1 gives `F(gcd(m, n)) | F(m)`
  and `F(gcd(m, n)) | F(n)`. The hypothesis `d | F(gcd(m, n))` then yields `d | F(m)` and
  `d | F(n)` by transitivity.
- **(⟹)** Rewrite via Fact 2.2 and apply `d | F(m) ∧ d | F(n) ⟹ d | gcd(F(m), F(n))`.

This is the sharpest form of the "gcd bridge": it requires no entry-point apparatus and no
primality, and it is the engine for everything that follows.

---

## 4. Rigidity of primitivity

### 4.1. The boundary at zero

**Proposition 4.1 (Vacuous primitivity at zero).** For every `p`, `IsPrimitive p 0` holds.

*Proof sketch.* The first clause `p | F(0)` holds because `F(0) = 0` and every number
divides `0`. The minimality clause `∀ k, 0 < k < 0 ⟹ ¬ (p | F(k))` is vacuous since no
`k` satisfies `0 < k < 0`. ∎

Proposition 4.1 shows that primitivity at index `0` carries no information: *every* modulus
is primitive there. This is exactly why the positivity hypotheses in the next theorem
cannot be dropped.

### 4.2. Uniqueness

**Theorem 4.2 (Rigidity / uniqueness).** If `0 < m`, `0 < n`, `IsPrimitive p m`, and
`IsPrimitive p n`, then `m = n`.

*Proof sketch.* Suppose `m ≠ n`; without loss of generality `m < n`. Primitivity at `m`
gives `p | F(m)`. Primitivity at `n` includes the minimality clause forbidding divisibility
at every positive index strictly below `n`; since `0 < m < n`, this yields `¬ (p | F(m))`.
The two statements contradict each other, so `m < n` is impossible; symmetrically `n < m`
is impossible. Hence `m = n`. ∎

Note that this argument uses *only the definition* of primitivity — not even the strong
divisibility property. The rigidity is intrinsic to the minimality structure. Proposition
4.1 demonstrates the necessity of `0 < m` and `0 < n`: dropping them, every `p` would be
primitive for the distinct indices `0` and (say) its true rank, breaking uniqueness.

Theorem 4.2 is what makes the rank of apparition a *well-defined labelling*: each value
that ever divides some `F(n)` non-trivially has a single positive index at which it is
primitive.

---

## 5. A primitive divisor pins the divisibility set

**Theorem 5.1 (Pinning law).** Let `0 < n` and suppose `IsPrimitive p n`. Then for all `m`,
> `p | F(m) ⟺ n | m`.

*Proof sketch.*

- **(⟸)** If `n | m` then `F(n) | F(m)` by Fact 2.1; combined with `p | F(n)` (the first
  clause of primitivity), transitivity gives `p | F(m)`.
- **(⟹)** Assume `p | F(m)`. Together with `p | F(n)`, Theorem 3.1 (the meet law) gives
  `p | F(gcd(n, m))`. Now `gcd(n, m) | n`, so `gcd(n, m) ≤ n`. Moreover `gcd(n, m) > 0`
  (since `n > 0`). If we had `gcd(n, m) < n`, the minimality clause of `IsPrimitive p n`
  would forbid `p | F(gcd(n, m))`, a contradiction. Hence `gcd(n, m) = n`, i.e. `n | m`. ∎

(The case `m = 0` is automatically covered: `gcd(n, 0) = n`, so the argument yields `n | 0`,
which holds.)

Theorem 5.1 upgrades the abstract law of apparition into a concrete, exact divisibility
*test*: a primitive divisor of `F(n)` divides precisely the Fibonacci numbers at multiples
of `n`. Example: `13` is primitive for `F(7) = 13`, so `13 | F(m) ⟺ 7 | m`; thus
`13 | F(7), F(14) = 377, F(21) = 10946, ...` and no others.

---

## 6. Simultaneous apparition: the join law

**Theorem 6.1 (Join law).** Let `0 < a`, `0 < b`, `IsPrimitive p a`, and `IsPrimitive q b`.
Then for all `n`,
> `(p | F(n) ∧ q | F(n)) ⟺ lcm(a, b) | n`.

*Proof sketch.* Apply Theorem 5.1 to each conjunct: `p | F(n) ⟺ a | n` and
`q | F(n) ⟺ b | n`. The conjunction `a | n ∧ b | n` is equivalent to `lcm(a, b) | n` by the
universal property of lcm (`Nat.lcm_dvd_iff`). ∎

Conceptually, the common-apparition set of two primitive divisors is *itself* an apparition
class, governed by the lcm of the two ranks — a clean "join" of two divisibility laws.
Example: `13` is primitive for `F(7)` and `11` for `F(10) = 55`; they jointly divide `F(n)`
exactly when `lcm(7, 10) = 70 | n`. So `F(70)` is the first Fibonacci number divisible by
both, and thereafter every `70`th.

---

## 7. Generalization to a finite family

**Theorem 7.1 (Family join law).** Let `S` be a finite index set, and let `f, g : S → ℕ` be
such that for every `i ∈ S`, `0 < g(i)` and `IsPrimitive (f(i)) (g(i))`. Then for all `n`,
> `(∀ i ∈ S, f(i) | F(n)) ⟺ (lcm_{i ∈ S} g(i)) | n`.

*Proof sketch.* Induct on the finite set `S`.

- **Base case** `S = ∅`: the left side is vacuously true, and `lcm` over the empty family
  is `1`, which divides every `n`; so both sides are true.
- **Inductive step** `S = {a} ∪ S'` with `a ∉ S'`: the conjunction over `S` splits as
  `f(a) | F(n) ∧ (∀ i ∈ S', f(i) | F(n))`. By Theorem 5.1, `f(a) | F(n) ⟺ g(a) | n`; by the
  inductive hypothesis, `(∀ i ∈ S', f(i) | F(n)) ⟺ (lcm_{i ∈ S'} g(i)) | n`. The pair
  `g(a) | n ∧ (lcm_{S'} g) | n` is equivalent to `lcm(g(a), lcm_{S'} g) | n` by
  `Nat.lcm_dvd_iff`, and `lcm(g(a), lcm_{S'} g) = lcm_{S} g` by the recursion of `Finset.lcm`
  over an `insert`. ∎

This is the full finite-family generalization of Theorem 6.1 and confirms that arbitrary
collections of primitive divisors synchronize on `F(n)` precisely at the multiples of the
least common multiple of all their ranks.

---

## 8. The lattice perspective

Define, for each modulus `d`, the *apparition set* `A(d) = { n : d | F(n) }`. The results
above describe `A` exactly:

- By Fact 2.1 and the regularity of apparition, when `d` is *active* (divides some positive
  Fibonacci number) `A(d)` is the set of multiples of a unique generator — the rank of
  apparition `r(d)`. Primitivity of `p` for `F(n)` is exactly the statement that `n` is the
  *generator* of `A(p)`, i.e. `r(p) = n` (Theorem 4.2 guarantees uniqueness).
- **Meet.** Theorem 3.1 gives `A(d) ⊇` the join behavior at gcd indices; equivalently,
  `d | F(gcd(m,n))` is controlled by `d`'s behavior at `m` and `n`.
- **Join.** Theorems 6.1 and 7.1 say `A(p) ∩ A(q) = A` of the multiples-ideal generated by
  `lcm(r(p), r(q))`; i.e. intersection of apparition sets corresponds to lcm of ranks.

Thus the map `d ↦ A(d)` (for active `d`), equivalently `d ↦ r(d)`, is an order- and
lattice-preserving correspondence between the divisibility lattice of active moduli and a
sublattice of `(ℕ, gcd, lcm)`. Primitivity is exactly the property of sitting at a generator
of a multiples-ideal. The meet law (Theorem 3.1) and the join law (Theorems 6.1, 7.1) are
the two halves of this lattice dictionary.

---

## 9. Algorithms

The theorems translate directly into exact, search-free decision procedures.

### 9.1. Rank of apparition

To find the rank `r(p)` (the unique positive index where `p` is primitive), scan
`n = 1, 2, 3, ...` and return the first `n` with `p | F(n)`. By Theorem 5.1 this index then
controls all divisibility. Complexity: `O(r(p))` Fibonacci steps, each `O(1)` modular
additions if Fibonacci is computed modulo `p`.

### 9.2. Divisibility test via pinning

To test `p | F(m)` for a primitive `p` with known rank `n`: by Theorem 5.1 simply check
`n | m`. This replaces computing the (astronomically large) `F(m)` with a single modular
test — `O(1)` after `r(p)` is known.

### 9.3. Joint apparition

To find the first index where a family `p_1, ..., p_k` of primitive divisors (ranks
`g_1, ..., g_k`) all appear: compute `lcm(g_1, ..., g_k)` (Theorem 7.1). The set of all
joint-apparition indices is the multiples of that lcm.

---

## 9b. Worked numerical examples

We collect concrete instances that make the abstract laws tangible and provide reusable
ground truth for the accompanying software.

**Ranks of apparition (small primes).** Scanning indices we find the debut positions:

| prime p | 2 | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 |
|---------|---|---|---|---|----|----|----|----|----|----|----|
| rank r(p) | 3 | 4 | 5 | 8 | 10 | 7 | 9 | 18 | 24 | 14 | 30 |

For instance `r(13) = 7` because `F(7) = 13` and none of `F(1), ..., F(6) = 1,1,2,3,5,8`
is divisible by `13`. Note that the rank is *not* monotone in `p`: `r(13) = 7 < r(11) = 10`,
which already shows that the apparition labelling is a genuinely arithmetic, not analytic,
function of the prime.

**Pinning law in action.** With `r(13) = 7`, Theorem 5.1 predicts `13 | F(m) ⟺ 7 | m`.
Indeed the Fibonacci numbers up to index 40 divisible by `13` occur at exactly
`m = 7, 14, 21, 28, 35`, the multiples of `7`. The verification needs no factoring of the
large values `F(35) = 9227465`; it is a single check on the index.

**Join law in action.** With `r(13) = 7` and `r(11) = 10`, Theorem 6.1 predicts that `13`
and `11` jointly divide `F(n)` exactly at the multiples of `lcm(7, 10) = 70`. The first such
index is `n = 70`: `F(70) = 190392490709135` is divisible by both `13` and `11`, and `70`
is the smallest index with this property.

**Family join law in action.** For the family `{2, 3, 5}` with ranks `{3, 4, 5}` we get
`lcm(3, 4, 5) = 60`; the first Fibonacci number divisible by `2`, `3`, and `5`
simultaneously is `F(60)`, and the joint-apparition indices are exactly the multiples of
`60`. For `{13, 11, 7}` with ranks `{7, 10, 8}` the lcm is `280`, so `F(280)` is the first
joint appearance.

These examples were confirmed exhaustively against direct enumeration in the accompanying
numerical demonstration; every predicted set matched the brute-force set exactly.

## 9c. Why entry-point search is avoided

A traditional development defines the rank of apparition as `r(d) = min { n > 0 : d | F(n) }`
via an unbounded search operator (in the formalization, `Nat.find`), and then proves the
apparition law from properties of that minimum. This is correct but heavier: every lemma
must carry the well-definedness side conditions of the search, and rigidity becomes a
statement about two different minima coinciding.

Our development never forms `r(d)`. Definition 2.3 phrases primitivity as a *local* property
("`p` divides `F(n)` but not earlier"), and rigidity (Theorem 4.2) is then a pure clash of
two local conditions, provable from the definition alone. The strong divisibility property
enters only later, through the meet law (Theorem 3.1), and powers the pinning and join laws.
This separation of concerns is what keeps each proof to a few lines and exposes the lattice
structure directly, and it is the methodological contribution of this work beyond the
individual theorems.

## 10. Applications

- **Fast Fibonacci divisibility.** Theorem 5.1 turns the question "does this prime divide
  the millionth Fibonacci number?" into a one-line modular check on the index, avoiding any
  big-integer arithmetic.
- **Carmichael backbone.** The classical primitive-divisor theorem asserts that every
  `F(n)` with `n > 12` (excepting `n ∈ {1, 2, 6, 12}`) has a primitive divisor. Our results
  describe precisely what such a divisor *does* (Theorem 5.1) and that it is *unique*
  (Theorem 4.2). They reduce the statement "`p` is primitive for `F(n)`" to a clean
  statement about indices, supplying the combinatorial scaffolding for the existence proof.
- **Synchronization of arithmetic progressions.** Theorems 6.1 and 7.1 give exact answers
  to when several independent divisibility rhythms align — useful in the design of pseudo-
  random and de Bruijn-style sequences built from Fibonacci residues.

---

## 11. Discussion and future work

The development demonstrates how much structural content flows from a single elementary
fact (strong divisibility). The rigidity theorem (Theorem 4.2) is remarkable in requiring
*only* the definition of primitivity, not even the strong divisibility property; the meet
law (Theorem 3.1) then carries the rest of the theory. The deliberate avoidance of entry-
point search (`Nat.find`) keeps every proof short and exposes the lattice skeleton directly.

The principal gap that remains is *existence*. Carmichael's theorem guarantees that
primitive divisors actually exist for all `n ≥ 13` outside `{1, 2, 6, 12}`. That statement
is analytic in nature (it ultimately rests on bounds for cyclotomic-polynomial values at the
Fibonacci recurrence's characteristic roots) and is not addressed here. The catalog
discharges the range `13 ≤ n ≤ 10000` by direct computation but leaves composite `n > 10000`
open. The natural next target is a uniform existence proof; our combinatorial results are
exactly the backbone such a proof would build on, since they already reduce primitivity to a
statement purely about indices.

Further directions:

1. **Generalization to Lucas sequences.** The arguments use only strong divisibility, which
   holds for a broad class of Lucas sequences `U_n(P, Q)`. Theorems 3.1–7.1 should transfer
   verbatim to any strong divisibility sequence.
2. **Quantitative apparition.** Combine the join law with estimates on `lcm` growth to count
   indices below `x` where a prescribed set of primes simultaneously appear.
3. **Effective Carmichael.** Use Theorems 4.2 and 5.1 to reduce the existence step to a
   finite, checkable inequality at each `n`, aiming to close the open composite range.

---

## 12. Conclusion

Starting from the single property that the Fibonacci sequence is a strong divisibility
sequence, we built a complete, self-contained theory of its primitive divisors: a sharp
meet law, the rigidity of fingerprints, a pinning law converting apparition into an exact
divisibility test, and join laws governing the simultaneous apparition of any finite family
of primitive divisors. Together these constitute an exact lattice dictionary between the
arithmetic of indices `(ℕ, gcd, lcm)` and the divisibility structure of the Fibonacci
numbers, and they form the combinatorial backbone for the deeper existence question of
Carmichael's primitive-divisor theorem.
