# A Unified Rank-of-Apparition Engine for Strong Divisibility Sequences

## Abstract

We isolate the order-theoretic core shared by two classical divisibility laws — the Fibonacci law `F(a) ∣ F(b) ⟺ a ∣ b` and the Mersenne law `aᵐ − 1 ∣ aⁿ − 1 ⟺ m ∣ n` — and prove them as two instances of a single general engine. The engine takes as its only structural input the **strong divisibility identity** `u(gcd(m,n)) = gcd(u(m), u(n))`. From this one hypothesis we construct the **rank of apparition** function `rank u m` (the least positive index k with `m ∣ u(k)`) and prove four headline results: (1) the *spine* `m ∣ u(n) ⟺ rank u m ∣ n`, characterizing the divisibility pattern as exactly periodic; (2) the *order-morphism law* `b ∣ a ⟹ rank u b ∣ rank u a`; (3) *rigidity* `rank u (u k) = k` under positivity and strict growth; and (4) the *value biconditional* `u(a) ∣ u(b) ⟺ a ∣ b`. The two classical laws then follow mechanically by verifying the gcd identity and growth for `Nat.fib` and for `n ↦ aⁿ − 1`. The development is fully formalized and machine-checked; this paper presents the mathematics, the proof sketches, and the algorithmic content. The Mersenne index biconditional, in particular, is derived here as a first-class theorem of the unified engine rather than re-proved by hand.

**Keywords:** strong divisibility sequence, rank of apparition, Fibonacci numbers, Mersenne numbers, divisibility lattice, gcd identity, Lucas sequences.

---

## 1. Introduction

A *divisibility sequence* is an integer sequence `u : ℕ → ℕ` for which `m ∣ n ⟹ u(m) ∣ u(n)`: divisibility of indices implies divisibility of values. A *strong* divisibility sequence (SDS) satisfies the stronger, lattice-flavored identity

> `u(gcd(m, n)) = gcd(u(m), u(n))`.

The two most celebrated examples are the Fibonacci numbers `F(n)` and the sequences `n ↦ aⁿ − 1` (which specialize, at `a = 2`, to the Mersenne numbers). Both are classically known to satisfy

- **Fibonacci:** `F(a) ∣ F(b) ⟺ a ∣ b` (for `a ≥ 3`), and
- **Mersenne:** `aᵐ − 1 ∣ aⁿ − 1 ⟺ m ∣ n` (for `a ≥ 2`, `m ≥ 1`).

Historically these are proved by separate, sequence-specific arguments. Two threads in the catalog mirrored this fragmentation: one development built the rank-of-apparition machinery (`fibRank`, the spine `fibRank_dvd_iff`, rigidity `fibRank_fib`, the biconditional `fib_dvd_fib_iff`) but *only* for Fibonacci; a second development introduced the abstract `IsStrongDivSeq` notion together with primitivity theory and the two instances `fib_isStrongDivSeq`, `mersenne_isStrongDivSeq` — but never built a rank function and never derived a value biconditional.

This paper unifies the two. We lift the entire rank machinery from `Nat.fib` to an arbitrary strong divisibility sequence, deriving the spine, the order-morphism law, rigidity, and the value biconditional from the single hypothesis `IsStrongDivSeq u`. The two classical theorems then drop out as instances of one engine — and the Mersenne index biconditional is obtained as a genuine corollary rather than reproved.

The conceptual stance is Grothendieck-style unification: the gcd-meet law `IsStrongDivSeq` *is* the abstract Pisano/order mechanism; Fibonacci and `aⁿ − 1` are two specializations of one truth.

---

## 2. Definitions

Throughout, `u : ℕ → ℕ` is a sequence of natural numbers and `gcd` denotes the natural-number greatest common divisor (with `gcd(0, n) = n`).

**Definition 2.1 (Strong divisibility sequence).**
`u` is a *strong divisibility sequence* if
> `IsStrongDivSeq u  :⟺  ∀ m n, u(gcd(m, n)) = gcd(u(m), u(n))`.

**Definition 2.2 (Has a rank).**
A modulus `m` *has a rank of apparition* in `u` if it divides some positive-index value:
> `HasRank u m  :⟺  ∃ k, 0 < k ∧ m ∣ u(k)`.

**Definition 2.3 (Rank of apparition).**
The *rank of apparition* of `m` in `u` is the least positive index at which `m` appears as a divisor, or `0` if none exists:
> `rank u m  :=  if (∃ k, 0 < k ∧ m ∣ u(k)) then (least such k) else 0`.

The three basic facts attaching `rank` to its specification are:

- `rank_pos`: if `HasRank u m`, then `0 < rank u m`.
- `dvd_rank`: if `HasRank u m`, then `m ∣ u(rank u m)`.
- `rank_min`: if `0 < k < rank u m`, then `¬ (m ∣ u(k))` — minimality below the rank.

These follow immediately from the well-ordering definition of "least positive index."

---

## 3. The weak divisibility law

We first observe that strength implies the ordinary divisibility-sequence property — for free.

**Lemma 3.1 (`IsStrongDivSeq.dvd_of_dvd`).**
If `IsStrongDivSeq u` and `m ∣ n`, then `u(m) ∣ u(n)`.

*Proof.* From `m ∣ n` we get `gcd(m, n) = m`. Specializing the strong identity at `(m, n)` and rewriting,
`u(m) = u(gcd(m, n)) = gcd(u(m), u(n))`.
Since `gcd(u(m), u(n))` divides `u(n)`, so does `u(m)`. ∎

This single line already gives one direction of every divisibility law below; the strength of the hypothesis is doing the work that, sequence by sequence, normally requires explicit induction.

---

## 4. The spine

The central theorem characterizes the *entire* set of indices at which a modulus appears: it is exactly the set of multiples of its rank. This is the order-theoretic engine on which everything rests.

**Theorem 4.1 (Spine, `rank_dvd_iff`).**
Let `IsStrongDivSeq u`, and suppose `HasRank u m`. Then for every `n`,
> `m ∣ u(n)  ⟺  rank u m ∣ n`.

*Proof sketch.* Write `r = rank u m`. By `rank_pos`, `r > 0`; by `dvd_rank`, `m ∣ u(r)`.

(⟸) If `r ∣ n`, then `u(r) ∣ u(n)` by the weak law (Lemma 3.1), and `m ∣ u(r) ∣ u(n)`.

(⟹) Suppose `m ∣ u(n)` but, for contradiction, `r ∤ n`. Consider `g = gcd(r, n)`. Since `r ∤ n`, `g` is a *proper* divisor of `r`, hence `0 < g < r`. Now `m` divides both `u(r)` and `u(n)`, so `m ∣ gcd(u(r), u(n)) = u(gcd(r, n)) = u(g)` by the strong identity. But `g` is a positive index strictly below the rank `r`, so `rank_min` says `m ∤ u(g)` — contradiction. Hence `r ∣ n`. ∎

The proof is the crux of the whole theory: minimality of the rank collides with the meet identity, and the collision forces periodicity. This generalizes the Fibonacci-specific `fibRank_dvd_iff` (which leaned on `Nat.fib_gcd`) to the bare `IsStrongDivSeq` hypothesis.

---

## 5. The order-morphism law

**Theorem 5.1 (`rank_dvd_of_dvd`).**
Let `IsStrongDivSeq u` and assume a totality witness `hex : ∀ m, 0 < m → HasRank u m`. If `0 < a` and `b ∣ a`, then
> `rank u b ∣ rank u a`.

*Proof.* From `b ∣ a` and `a > 0` we get `b > 0`, so `a` and `b` both have ranks. By `dvd_rank`, `a ∣ u(rank u a)`, hence `b ∣ a ∣ u(rank u a)`, i.e. `b ∣ u(rank u a)`. Applying the spine (Theorem 4.1) to `b` at index `rank u a` gives `rank u b ∣ rank u a`. ∎

Thus `rank` is a morphism of divisibility posets: it carries the divisibility order on moduli to the divisibility order on ranks.

---

## 6. Rigidity

To upgrade the weak law to a biconditional we need to know the rank of a value the sequence itself produces. Under positivity and strict growth this is pinned exactly.

**Theorem 6.1 (Rigidity, `rank_self`).**
Suppose `0 < k`, that `u(j) > 0` for all `j > 0`, and that `u` is strictly increasing strictly below `k` in the sense that `u(j) < u(k)` for all `0 < j < k`. Then
> `rank u (u(k)) = k`.

*Proof.* Trivially `u(k) ∣ u(k)`, so `k` is one index of appearance, with `k > 0`. To see it is the *least*: for any `j` with `0 < j < k` we have `0 < u(j) < u(k)`, and a positive number strictly smaller than `u(k)` cannot be divisible by `u(k)`. Hence `u(k) ∤ u(j)` for all such `j`, so `k` is the least positive index at which `u(k)` appears: `rank u (u(k)) = k`. ∎

This is the abstract version of the Fibonacci result `fibRank_fib`; strict growth replaces Fibonacci-specific monotonicity. The strict-growth hypothesis is *sharp*: a plateau such as `F(1) = F(2) = 1` breaks rigidity, which is precisely why the Fibonacci instance requires `k ≥ 3`.

---

## 7. The value biconditional

**Theorem 7.1 (Value biconditional, `value_dvd_iff`).**
Suppose `IsStrongDivSeq u`, that `u(j) > 0` for all `j > 0`, and that `u(j) < u(a)` for all `0 < j < a` (with `0 < a`). Suppose moreover that every positive modulus has a rank. Then for all `b`,
> `u(a) ∣ u(b)  ⟺  a ∣ b`.

*Proof.* By rigidity (Theorem 6.1), `rank u (u(a)) = a`. The value `u(a)` certainly has a rank (it divides `u(a)`). Apply the spine (Theorem 4.1) to the modulus `u(a)`:
`u(a) ∣ u(b) ⟺ rank u (u(a)) ∣ b ⟺ a ∣ b`. ∎

The spine is what converts a statement about *values* into a statement about *indices*; rigidity supplies the identification `rank u (u(a)) = a`. Together they upgrade the one-directional weak law into a clean biconditional in a single step.

---

## 8. The two classical instances

Both classical theorems are obtained by verifying the two ingredients — the gcd identity and strict growth — for a concrete sequence, then invoking Theorem 7.1.

### 8.1 Fibonacci

The Fibonacci sequence satisfies the strong identity `F(gcd(m, n)) = gcd(F(m), F(n))` (classical; `Nat.fib_gcd`), and is strictly increasing from index 3 onward (`2 = F(3) < F(4) = 3 < F(5) = 5 < ...`); it is positive for positive indices. Hence:

**Corollary 8.1 (`fib_dvd_fib_iff`).** For `a ≥ 3` and any `b`,
> `F(a) ∣ F(b) ⟺ a ∣ b`.

The bound `a ≥ 3` is forced by the plateau `F(1) = F(2) = 1`, which violates strict growth below index 2. This recovers the dedicated Fibonacci development as a special case of the engine.

### 8.2 Mersenne / `aⁿ − 1`

For a fixed base `a ≥ 2`, the sequence `n ↦ aⁿ − 1` satisfies the strong identity `gcd(aᵐ − 1, aⁿ − 1) = a^gcd(m,n) − 1` (classical), is positive for positive indices, and is strictly increasing. Hence:

**Corollary 8.2 (`mersenne_dvd_iff`, new).** For `a ≥ 2`, `m ≥ 1`, and any `n`,
> `aᵐ − 1 ∣ aⁿ − 1 ⟺ m ∣ n`.

At `a = 2` this is the classical Mersenne divisibility law `2ᵐ − 1 ∣ 2ⁿ − 1 ⟺ m ∣ n`. The catalog previously recorded the SDS *instance* for `aⁿ − 1` but never extracted the index biconditional; here it is a one-line corollary of the unified engine.

---

## 9. Algorithms

The engine is constructive enough to drive direct computation. We describe two core algorithms.

### 9.1 Computing the rank of apparition

Given a sequence oracle `u` and a modulus `m` known to have a rank, the rank is found by linear search:

```
function RANK(u, m):
    k ← 1
    while m does not divide u(k):
        k ← k + 1
    return k
```

By the spine (Theorem 4.1), once `k = rank u m` is found, the complete set of appearance indices is `{ k, 2k, 3k, ... }` — no further search is needed. Complexity is `O(rank u m)` oracle calls. For Fibonacci moduli the rank (the *Pisano entry point*) is `O(m)`, giving an efficient divisibility test.

### 9.2 Deciding value divisibility without factoring

The value biconditional (Theorem 7.1) reduces a divisibility test on potentially astronomically large values `u(a), u(b)` to a tiny test on the indices:

```
function VALUE_DIVIDES(a, b):       # tests u(a) | u(b)
    return (a divides b)            # by Theorem 7.1
```

This is the algorithmic payoff: testing whether `F(1000) ∣ F(7000)`, or whether `2^89 − 1 ∣ 2^267 − 1`, never touches the giant numbers themselves — it is settled by `1000 ∣ 7000` (false) and `89 ∣ 267` (true: `267 = 3 × 89`) respectively, in constant time.

---

## 10. Applications

- **Primality and primitivity.** The rank/spine structure underlies Lucas-style primality testing (e.g. the Lucas–Lehmer test for Mersenne primes) and the study of *primitive prime divisors* (Zsygmondy's theorem): a prime `p` is primitive for `u(n)` when `rank u p = n`, i.e. `n` is the first index where `p` appears.
- **Fast divisibility queries.** Corollary 8.2 turns divisibility among exponentially large numbers `aⁿ − 1` into divisibility among exponents, a routine subroutine in computational number theory and cryptographic parameter checking.
- **Conceptual auditing.** By exhibiting both classical laws as one theorem, the engine isolates *exactly* the hypotheses (gcd identity + positivity + strict growth) responsible — clarifying, for instance, why Fibonacci needs `a ≥ 3` while `aⁿ − 1` does not.

---

## 11. Discussion

The unification has two payoffs beyond economy. First, it *explains* the coincidence: the shared law is not about golden ratios or binary arithmetic but about the meet identity `u(gcd(m,n)) = gcd(u(m), u(n))`, and any sequence with this identity — named or not — obeys it. Second, it *delimits* the hypotheses precisely. The spine (Theorem 4.1) needs *only* the gcd identity and existence of a rank; positivity and growth enter solely to pin `rank u (u(k)) = k`. The sharpness of strict growth is visible in the `a ≥ 3` Fibonacci restriction.

A subtle point worth highlighting: the spine is *strictly weaker in hypotheses* than the value biconditional, and is correspondingly more reusable. Many downstream arguments (primitive divisors, periodicity of residues) need only the spine, not rigidity.

---

## 12. Future work

(See the dedicated Future Directions for the full program.) The two principal lines are:

1. **A generic primitive-divisor theorem (Zsygmondy through one engine).** For strong divisibility sequences with sufficient growth, every `u(n)` with `n` large should carry a primitive prime divisor. The value biconditional already pins every *non-primitive* contribution to the `u(d)` for proper divisors `d ∣ n`; a counting bound `u(n) > ∏_{d ∣ n, d < n} u(d)` would mechanically force a leftover primitive factor. Primitivity becomes a growth inequality rather than a new idea.

2. **Closing the Carmichael composite tail.** Instantiating the primitive-divisor program at `Nat.fib`, where `F(n) ≍ φⁿ` while the product over proper divisors grows like `φ^{n/2 + o(n)}`, should discharge a remaining composite-case gap by a clean lower bound `primPart(n) ≥ φ^{n/2}/poly > 1`.

---

## 13. Conclusion

From the single identity `u(gcd(m,n)) = gcd(u(m), u(n))` we built a rank-of-apparition engine and proved, in full generality, the spine `m ∣ u(n) ⟺ rank u m ∣ n`, the order-morphism law, rigidity `rank u (u(k)) = k`, and the value biconditional `u(a) ∣ u(b) ⟺ a ∣ b`. The Fibonacci law and the Mersenne law are two instances of this one engine. The mathematics that once required two separate sequence-specific developments is now a single theorem with two corollaries — and the Mersenne index biconditional, previously unstated, falls out for free.
