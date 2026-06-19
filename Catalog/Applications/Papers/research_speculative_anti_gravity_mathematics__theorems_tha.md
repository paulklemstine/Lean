# An Integer Model of Anti-Gravity Theorems: Logarithmic Proof Cost and the Support Trade-Off

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Applications

## Abstract

We introduce and rigorously analyze a number-theoretic model of *anti-gravity
theorems* — results that carry high structural load (many dependents) yet require
little to prove. In a fixed universe of size `N ∈ ℕ`, we model a result as a positive
integer `d` and assign to it two quantities: its **support** `support(N, d) = ⌊N/d⌋`,
measuring how much of the universe rests upon it, and its **proof cost**
`proofCost(d) = Ω(d)`, the number of prime factors of `d` counted with multiplicity,
measuring how many irreducible steps build it. Our central structural result is the
*logarithmic cost bound* `2^{Ω(d)} ≤ d` for every `d > 0`, equivalently
`Ω(d) ≤ log₂ d`, which we derive from the single fact that every prime is at least
`2`. Combining this with denominator antitonicity of integer division yields the
*anti-gravity support trade-off* `support(N, d) ≤ ⌊N / 2^{Ω(d)}⌋`: a result's reach is
bounded by the universe size divided by two raised to its proof cost, so each unit of
proof cost at most halves the support ceiling. We characterize the extremal objects —
the unit `1` (zero cost, full support `N`), the primes (unit cost, support up to
`⌊N/2⌋`), and the powers of two (maximal cost for their size) — and discuss why
anti-gravity results are abundant: low cost and high support both favor small integers.
All results are stated with full mathematical content and proof sketches, and have been
formally verified.

---

## 1. Introduction

A recurring observation about mathematics is that its most structurally important
results are often among its simplest. The Pythagorean theorem, unique factorization,
the extreme value theorem, and countless basic lemmas underpin enormous superstructures
while admitting short statements and short proofs. We call such a result an
**anti-gravity theorem**: it supports much, yet resists the "downward pull" of proof
complexity. The metaphor is that load-bearing and weight, which travel together in
physical structures, come apart in mathematics — the load-bearing members are often the
lightest.

This paper makes the metaphor exact by exhibiting a fully precise model in which both
"how much a result supports" and "how much it costs to prove" are concrete natural
numbers, and in which the anti-gravity trade-off between them is a theorem. The model
lives in elementary number theory: results are positive integers, support is integer
division, and proof cost is the count of prime factors with multiplicity. Despite its
elementary ingredients, the model reproduces the qualitative facts of mathematical
practice: the existence of cheap load-bearing results, an exact trade-off bound between
cost and reach, and a clean hierarchy from the weightless foundational unit through the
primes to the leaden powers of two.

### 1.1 Contributions

- A precise model (Section 2) of *support* and *proof cost* for results, instantiated in
  `ℕ`.
- The **logarithmic cost bound** `2^{Ω(d)} ≤ d` (Theorem 3.2), via a combinatorial
  product lemma (Lemma 3.1).
- The **anti-gravity support trade-off** `support(N, d) ≤ ⌊N / 2^{Ω(d)}⌋`
  (Theorem 4.2), via denominator antitonicity (Lemma 4.1).
- A characterization of the extremal objects and a discussion of why anti-gravity
  results are abundant (Section 5).

---

## 2. The model: support and proof cost

Throughout, `N, d, k` denote natural numbers and `⌊·/·⌋` denotes truncated (floor)
integer division.

**Definition 2.1 (Support).** Fix a universe size `N ∈ ℕ`. The *support* of a positive
integer `d` in `N` is
> `support(N, d) := ⌊N / d⌋`.

Interpretation: `support(N, d)` counts how many multiples of `d` lie at or below `N`,
i.e. how many slots of the universe rest on `d`. Small `d` yields large support (a
finely dividing result underpins much); large `d` yields small support. This is the
model's *gravitational weight*: the number of dependents. The defining identity is
recorded as

> **Fact 2.2 (`support_eq_div`).** `support(N, d) = ⌊N / d⌋` for all `N, d`.

**Definition 2.3 (Proof cost).** The *proof cost* of `d ∈ ℕ` is
> `proofCost(d) := Ω(d) =` the length of the multiset (list) of prime factors of `d`,
> counted with multiplicity.

Concretely, if `d = p₁ p₂ ⋯ p_m` is the prime factorization with repetition, then
`proofCost(d) = m`. Examples: `proofCost(1) = 0`, `proofCost(p) = 1` for prime `p`,
`proofCost(12) = 3` (factors `2,2,3`), `proofCost(2^k) = k`. The interpretation is that
each prime factor is an irreducible justification step; `Ω(d)` is the length of the
shortest multiplicative derivation of `d` from the primes.

**Definition 2.4 (Anti-gravity result).** Relative to a universe `N`, a result `d` is
*anti-gravity to degree (w, c)* if `support(N, d) ≥ w` and `proofCost(d) ≤ c`; informally,
an anti-gravity result is one with large support and small proof cost.

The remainder of the paper quantifies exactly how large support can be given a proof
cost, and vice versa.

---

## 3. The logarithmic cost bound

The keystone is that proof cost cannot exceed the base-two logarithm of magnitude. It
rests on a single combinatorial lemma.

**Lemma 3.1 (Product bound for lists bounded below by two;
`two_pow_length_le_prod_of_forall_two_le`).** Let `l` be a finite list of natural
numbers with `x ≥ 2` for every entry `x ∈ l`. Then
> `2^{|l|} ≤ ∏_{x ∈ l} x`,
where `|l|` is the length of `l`.

*Proof sketch.* Induction on `l`. For the empty list both sides equal `1` (`2^0 = 1`
and the empty product is `1`). For `l = x :: xs` with `x ≥ 2` and all entries of `xs`
at least `2`, the induction hypothesis gives `2^{|xs|} ≤ ∏ xs`. Then
`2^{|l|} = 2^{|xs|} · 2 ≤ (∏ xs) · x = ∏ l`,
using `2 ≤ x` and `2^{|xs|} ≤ ∏ xs` in the product (monotonicity of multiplication on
ℕ). ∎

**Theorem 3.2 (Logarithmic cost bound; `two_pow_proofCost_le`).** For every `d > 0`,
> `2^{proofCost(d)} ≤ d`,
equivalently `proofCost(d) = Ω(d) ≤ log₂ d`.

*Proof sketch.* Let `l` be the list of prime factors of `d`. Every entry of `l` is a
prime, hence `≥ 2`, so Lemma 3.1 applies and gives `2^{|l|} ≤ ∏ l`. For `d > 0` the
fundamental theorem of arithmetic gives `∏ l = d`, while `|l| = proofCost(d)` by
Definition 2.3. Substituting yields `2^{proofCost(d)} ≤ d`. ∎

**Remark 3.3.** The bound is tight: for `d = 2^k` we have `proofCost(d) = k` and
`2^{proofCost(d)} = 2^k = d`, so equality holds. Powers of two are exactly the numbers
that maximize proof cost for their magnitude.

The content of Theorem 3.2 is that *cheap proofs force small numbers* — there is no
positive integer below `2^k` with proof cost `k` or more — and dually that magnitude is
an exponential resource: to afford one more proof step you must (at least) double.

---

## 4. The anti-gravity support trade-off

We now couple proof cost to support. The bridge is the elementary monotonicity of
integer division in its denominator.

**Lemma 4.1 (Denominator antitonicity; `div_le_div_of_le_right`).** For all `N` and all
`a, b` with `0 < a ≤ b`,
> `⌊N / b⌋ ≤ ⌊N / a⌋`.

*Proof sketch.* By the defining adjunction of truncated division, `⌊N/b⌋ ≤ ⌊N/a⌋` holds
iff `⌊N/b⌋ · a ≤ N`. Since `a ≤ b`, `⌊N/b⌋ · a ≤ ⌊N/b⌋ · b ≤ N`, the last step being the
standard inequality `⌊N/b⌋ · b ≤ N`. ∎

**Theorem 4.2 (Anti-gravity support trade-off; `support_le_div_two_pow`).** For every
`d > 0` and every universe size `N`,
> `support(N, d) ≤ ⌊N / 2^{proofCost(d)}⌋`.

*Proof sketch.* By Definition 2.1, `support(N, d) = ⌊N / d⌋`. Apply Lemma 4.1 with
`a = 2^{proofCost(d)}` and `b = d`: the hypothesis `0 < a` holds because powers of two
are positive, and `a ≤ b` is exactly Theorem 3.2. Therefore
`⌊N / d⌋ ≤ ⌊N / 2^{proofCost(d)}⌋`, i.e. `support(N, d) ≤ ⌊N / 2^{proofCost(d)}⌋`. ∎

**Interpretation.** The right-hand side decreases (weakly) as `proofCost(d)` increases:
each additional unit of proof cost at most halves the ceiling on support. A result that
costs `c` steps to prove can support at most `⌊N / 2^c⌋` of the universe. Equivalently,
to support more than `N / 2^c`, a result must cost strictly fewer than `c` steps. Thus
expensive results are structurally peripheral and only cheap results can be load-bearing
— the anti-gravity phenomenon as an exact inequality.

**Corollary 4.3 (Reach forces cheapness).** If `support(N, d) > ⌊N / 2^c⌋` for some
`c`, then `proofCost(d) < c`.

*Proof sketch.* Contrapositive of Theorem 4.2: if `proofCost(d) ≥ c` then
`2^{proofCost(d)} ≥ 2^c`, so by Lemma 4.1 `⌊N / 2^{proofCost(d)}⌋ ≤ ⌊N / 2^c⌋`, whence
`support(N, d) ≤ ⌊N/2^c⌋`. ∎

---

## 5. Extremal objects and abundance

The model exhibits a clean hierarchy of results ordered by the cost/support balance.

**Proposition 5.1 (The unit is maximally anti-gravity).** `proofCost(1) = 0` and
`support(N, 1) = N`. Thus `1` attains zero proof cost and the maximum possible support
`N`; the trade-off bound `support(N,1) ≤ ⌊N / 2^0⌋ = N` is met with equality.

*Justification.* `1` has empty prime factorization, so `Ω(1) = 0`; and `⌊N/1⌋ = N`. ∎

**Proposition 5.2 (Primes are the cheapest nontrivial load-bearers).** For prime `p`,
`proofCost(p) = 1`, and the trade-off gives `support(N, p) ≤ ⌊N / 2⌋`. A prime can
support up to half the universe on a single proof step, and no result of proof cost `≥ 2`
can exceed `⌊N/2⌋` support unless... (it cannot: by Corollary 4.3 support exceeding
`⌊N/2⌋` forces proof cost `< 1`, i.e. proof cost `0`, i.e. `d = 1`).

*Justification.* A prime has exactly one prime factor; apply Theorem 4.2 with the
factorization length `1`. ∎

**Proposition 5.3 (Powers of two are maximally heavy for their size).** For `d = 2^k`,
`proofCost(d) = k` and `2^{proofCost(d)} = d`, so Theorem 3.2 holds with equality and
the support bound is exactly `support(N, 2^k) ≤ ⌊N / 2^k⌋` (in fact an equality, since
the divisor equals `2^{proofCost}`). These are the leaden results: maximal cost relative
to magnitude, minimal guaranteed reach.

**Abundance of anti-gravity results.** Because `proofCost(d) ≤ log₂ d` (Theorem 3.2),
proof cost grows only logarithmically in magnitude: doubling `d` raises its *maximum*
possible cost by at most `1`. Consequently the small integers — which by Definition 2.1
have the largest support — overwhelmingly have small proof cost. Low cost and high
support therefore both favor small `d`, so the two desiderata of an anti-gravity result
align rather than conflict, and anti-gravity results are plentiful among the small,
high-support integers. This is the model's account of the empirical observation that a
substantial fraction of any mathematical library's results are simultaneously
foundational and elementary.

---

## 6. Algorithms

All quantities are computable, giving a direct algorithmic reading of the theory.

**Algorithm A (Proof cost via trial-division factorization).** Given `d`, compute
`Ω(d)` by repeatedly dividing out the smallest prime factor. Complexity `O(√d)` per
factor in the worst case using trial division; the count of factors is `Ω(d) ≤ log₂ d`.

**Algorithm B (Anti-gravity certificate).** Given `N`, `d > 0`, and a target cost `c`,
verify the certificate `support(N, d) ≤ ⌊N / 2^c⌋` and that `proofCost(d) ≤ c`. By
Theorem 4.2 the first inequality is automatic when `c ≥ proofCost(d)`, so the algorithm
reduces to one factorization and two divisions.

**Algorithm C (Extremal enumeration).** For a budget `c`, enumerate the most
load-bearing results of cost `≤ c` by listing integers `d` with `Ω(d) ≤ c` in
increasing order; the smallest such `d` maximize `support(N, d)`. The cost-0 result is
`d = 1`; the cost-1 results are the primes; and so on.

---

## 7. Applications

- **Library prioritization.** Modeling lemmas as integers (or, in a weighted
  generalization, as nodes of a dependency graph), the trade-off identifies which results
  can in principle be both cheap and load-bearing, guiding where to invest curation and
  exposition effort.
- **Curriculum design.** The alignment of low cost and high support formalizes the
  pedagogical instinct to teach foundational, elementary results first: they are exactly
  the ones positioned to support the most subsequent material.
- **Complexity intuition.** The logarithmic cost bound `Ω(d) ≤ log₂ d` quantifies the
  sense in which "magnitude buys proof steps only logarithmically," a useful heuristic
  when estimating derivation lengths.

---

## 8. Discussion and future work

The integer model is deliberately minimal: it captures the cost/support trade-off with
the fewest moving parts, and proves a sharp inequality (Theorem 4.2) governing it. Its
extremal objects — the unit, the primes, the powers of two — line up with mathematical
intuition about foundational versus peripheral results. Its main limitation is that the
dependency relation is encoded coarsely, as divisibility/quotient rather than an explicit
graph. The natural extensions, detailed in the Future Directions accompanying this work,
are: (i) *weighted dependencies*, replacing the Boolean "depends" with a multiplicity- or
criticality-weighted edge function while preserving the averaging bounds; (ii)
*transitive load*, replacing direct support with the cardinality of the reachable
dependency cone; (iii) *algorithmic extraction* of empirically anti-gravity results from
real formal-library import graphs; and (iv) *extremal bounds for dependency-dense
anti-gravity sets* when a library has many roots. Each builds directly on the verified
scaffolding established here.

---

## 9. Summary of results

| Name | Statement |
|---|---|
| `support_eq_div` | `support(N, d) = ⌊N/d⌋` |
| `two_pow_length_le_prod_of_forall_two_le` | list of nats all `≥ 2` ⟹ `2^{len} ≤ ∏` |
| `two_pow_proofCost_le` | `d > 0` ⟹ `2^{Ω(d)} ≤ d` |
| `div_le_div_of_le_right` | `0 < a ≤ b` ⟹ `⌊N/b⌋ ≤ ⌊N/a⌋` |
| `support_le_div_two_pow` | `d > 0` ⟹ `support(N,d) ≤ ⌊N / 2^{Ω(d)}⌋` |

All statements are elementary, tight where noted, and together constitute a complete and
formally verified theory of anti-gravity results in the integer model.
