# The Rank of Apparition: A Self-Contained Primitive-Divisor Criterion for Strong Divisibility Sequences

## Abstract

A *strong divisibility sequence* is a sequence of natural numbers `u : ℕ → ℕ` satisfying the identity `u(gcd(m, n)) = gcd(u(m), u(n))` for all indices `m, n`. The Fibonacci sequence and every sequence of the form `u(n) = aⁿ − 1` are strong divisibility sequences. Such sequences obey a classical *law of apparition*: for each divisor `p` there is a distinguished index — the rank of apparition — that controls exactly where `p` divides the sequence. Prior abstract treatments could exploit such a "primitive index" only when it was supplied externally as a hypothesis. In this work we close that gap by defining the rank of apparition canonically as a least element,

> `rank(u, p) := inf { k : k > 0 and p ∣ u(k) }`,

and developing the complete apparition theory from this one definition. Our main results, all established for an arbitrary strong divisibility sequence, are: (1) the rank is always a primitive index — `p` is a primitive divisor of `u(rank(u, p))` whenever `p` appears at all; (2) the **strong primitive-divisor criterion** `p ∣ u(m) ⟺ rank(u, p) ∣ m`; (3) uniqueness in computable form, `IsPrimitive(u, p, n) ⟺ n = rank(u, p)` for `n > 0`; and (4) the **join law in ranks** `(p ∣ u(n) ∧ q ∣ u(n)) ⟺ lcm(rank(u, p), rank(u, q)) ∣ n`. Specializing recovers the Fibonacci law of apparition and the law of apparition for `aⁿ − 1` from a single definition and a single proof. For the Mersenne family the rank coincides with the multiplicative order of `a` modulo `p`, identifying a divisibility-theoretic invariant with a group-theoretic one.

**Keywords:** strong divisibility sequence, rank of apparition, primitive divisor, law of apparition, Fibonacci numbers, Mersenne numbers, multiplicative order.

---

## 1. Introduction

Let `u : ℕ → ℕ`. We call `u` a *divisibility sequence* if `m ∣ n` implies `u(m) ∣ u(n)`, and a *strong divisibility sequence* if the sharper identity

> `u(gcd(m, n)) = gcd(u(m), u(n))`

holds for all `m, n`. The Fibonacci sequence `F` satisfies `gcd(F_m, F_n) = F_{gcd(m,n)}`, and for every base `a` the sequence `n ↦ aⁿ − 1` satisfies `gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`. These two families are the prototypical examples and the historical sources of the theory.

A *primitive divisor* of `u(n)` is a number that divides `u(n)` but divides none of `u(1), …, u(n−1)`. The existence and structure of primitive divisors is governed by a single index attached to each potential divisor: the **rank of apparition**, the first positive index at which the divisor appears. Classical statements include Carmichael's theorem (every Fibonacci number `F_n` with `n ≥ 13` has a primitive prime divisor) and Bang's / Zsygmondy's theorem (every `2ⁿ − 1` with `n ≠ 1, 6` has a primitive prime divisor). Underlying both is the apparition law: a prime `p` divides `u(m)` if and only if `m` is a multiple of `rank(p)`.

The difficulty in an abstract treatment is the *manufacture* of the rank. A structural theory phrased in terms of an arbitrary "primitive index `n`" can prove that *if* `p` is primitive at some `n` then divisibility of `u(m)` by `p` is equivalent to `n ∣ m`, and that such `n` is unique. But it cannot, from those statements alone, produce the index `n` from `p`. The present work supplies that missing constructor as an infimum and then re-derives the entire theory as a self-contained criterion phrased purely in terms of the rank.

### Contributions

1. A canonical, parameter-free definition of the rank of apparition for an arbitrary strong divisibility sequence, as the infimum of the set of positive appearance indices (Section 3).
2. The theorem that the rank is always a primitive index, removing the need to assume a primitive index exists (Section 4).
3. The strong primitive-divisor criterion `p ∣ u(m) ⟺ rank(u, p) ∣ m` (Section 5).
4. A computable uniqueness statement: the unique primitive index equals the rank (Section 4).
5. The join law in ranks via least common multiples (Section 6).
6. Specialization to the Fibonacci and `aⁿ − 1` families, recovering both classical laws of apparition; and the identification of the rank with the multiplicative order for the Mersenne family (Section 7).

All results are formally verified and depend only on the standard foundational axioms.

---

## 2. Preliminaries and notation

Throughout, `u : ℕ → ℕ` denotes a sequence of natural numbers, `gcd` and `lcm` are the natural-number greatest common divisor and least common multiple (with the conventions `gcd(0, n) = n`, `lcm(0, n) = 0`), and `∣` denotes divisibility. We write `a ∣ b` for "`a` divides `b`."

**Definition 2.1 (Strong divisibility sequence).** `u` is a *strong divisibility sequence*, written `IsStrongDivSeq(u)`, if

> `u(gcd(m, n)) = gcd(u(m), u(n))` for all `m, n : ℕ`.

**Definition 2.2 (Primitive divisor).** For `p, n : ℕ`, `p` is a *primitive divisor* of `u(n)`, written `IsPrimitive(u, p, n)`, if

> `p ∣ u(n)` and for all `k` with `0 < k < n` we have `¬ (p ∣ u(k))`.

That is, `p` divides the `n`-th term and no earlier positive-index term.

We record two standard facts about strong divisibility sequences that are used below; both follow from Definition 2.1.

**Lemma 2.3 (Weak divisibility law).** If `IsStrongDivSeq(u)` and `m ∣ n`, then `u(m) ∣ u(n)`.

*Proof sketch.* From `m ∣ n` we have `gcd(m, n) = m`, so the defining identity gives `u(m) = u(gcd(m,n)) = gcd(u(m), u(n))`, and the right-hand side divides `u(n)` by definition of gcd. ∎

**Lemma 2.4 (Index uniqueness of primitivity).** A value is a primitive divisor for at most one positive index: if `IsPrimitive(u, p, m)` and `IsPrimitive(u, p, n)` with `0 < m`, `0 < n`, then `m = n`. (No strong-divisibility hypothesis is needed.)

*Proof sketch.* If `m < n`, primitivity at `n` forbids `p ∣ u(m)`, contradicting `p ∣ u(m)` from primitivity at `m`; symmetric for `n < m`. ∎

---

## 3. The rank of apparition

We now introduce the central object.

**Definition 3.1 (Appearance).** `p` *appears* in `u`, written `Appears(u, p)`, if

> `∃ k, 0 < k ∧ p ∣ u(k)`.

**Definition 3.2 (Rank of apparition).** The *rank of apparition* of `p` in `u` is

> `rank(u, p) := inf { k : 0 < k ∧ p ∣ u(k) }`,

the least positive index at which `p` divides `u`. By convention, if `p` never appears (the set is empty) the infimum is `0`.

The infimum here is the least element of a nonempty set of natural numbers, which exists whenever `p` appears. The following three lemmas are the immediate structural consequences of "least element" and form the engine of the entire theory.

**Lemma 3.3 (Membership).** If `Appears(u, p)`, then `0 < rank(u, p)` and `p ∣ u(rank(u, p))`.

*Proof sketch.* The appearance set is nonempty, so its infimum is a member of the set; membership unpacks to exactly the two stated conjuncts. ∎

We name the two halves: **rank_pos** (`0 < rank(u, p)`) and **rank_dvd** (`p ∣ u(rank(u, p))`).

**Lemma 3.4 (Minimality).** For every `k` with `0 < k` and `p ∣ u(k)`, we have `rank(u, p) ≤ k`.

*Proof sketch.* `k` is a member of the appearance set, and the infimum is a lower bound. ∎

These two properties — the rank is itself an appearance index (Lemma 3.3) and it is below every appearance index (Lemma 3.4) — say precisely that the rank is a *first* appearance, which we make formal next.

---

## 4. The rank is the unique primitive index

**Theorem 4.1 (The rank is primitive).** If `Appears(u, p)`, then `IsPrimitive(u, p, rank(u, p))`.

*Proof sketch.* We verify the two clauses of Definition 2.2 at `n = rank(u, p)`. First, `p ∣ u(rank(u, p))` is exactly Lemma 3.3 (rank_dvd). Second, suppose for contradiction that some `k` with `0 < k < rank(u, p)` had `p ∣ u(k)`. Then Lemma 3.4 gives `rank(u, p) ≤ k`, contradicting `k < rank(u, p)`. Hence no earlier positive index works, and `p` is primitive at the rank. ∎

This is the decisive removal of a hypothesis: where prior abstract theory required the caller to *provide* a primitive index `n` before any apparition statement could be invoked, Theorem 4.1 *manufactures* one canonically from `p` alone. Combined with uniqueness (Lemma 2.4), the primitive index becomes computable.

**Theorem 4.2 (Computable uniqueness).** For `0 < n`,

> `IsPrimitive(u, p, n) ⟺ n = rank(u, p)`.

*Proof sketch.* (⇐) If `n = rank(u, p)`, then `p` appears (witnessed by `n` together with `p ∣ u(n)`, which holds because `IsPrimitive` would supply it — more directly, `n = rank(u, p) > 0` forces the appearance set nonempty), and Theorem 4.1 gives `IsPrimitive(u, p, rank(u, p)) = IsPrimitive(u, p, n)`. (⇒) From `IsPrimitive(u, p, n)` we get `Appears(u, p)` (witnessed by `n` and `p ∣ u(n)`), hence `IsPrimitive(u, p, rank(u, p))` by Theorem 4.1. Now both `n` and `rank(u, p)` are positive primitive indices, so Lemma 2.4 forces `n = rank(u, p)`. ∎

Thus the unique primitive index promised by the classical theory is not merely unique but *named*: it is the rank.

---

## 5. The strong primitive-divisor criterion

We now reach the central theorem, valid for every strong divisibility sequence.

**Theorem 5.1 (Strong primitive-divisor criterion).** Let `IsStrongDivSeq(u)` and `Appears(u, p)`. Then for all `m`,

> `p ∣ u(m) ⟺ rank(u, p) ∣ m`.

*Proof sketch.* Write `r := rank(u, p)`. By Theorem 4.1, `p` is a primitive divisor of `u(r)`, with `r > 0` (Lemma 3.3).

(⇐) If `r ∣ m`, then `u(r) ∣ u(m)` by the weak divisibility law (Lemma 2.3), and since `p ∣ u(r)` (Lemma 3.3) we conclude `p ∣ u(m)`.

(⇒) Suppose `p ∣ u(m)`; we show `r ∣ m`. Since also `p ∣ u(r)`, `p` divides `gcd(u(r), u(m))`, which by the strong-divisibility identity equals `u(gcd(r, m))`. Thus `p ∣ u(gcd(r, m))`. Now `gcd(r, m) ∣ r`, so `gcd(r, m) ≤ r`. If `r ∤ m`, then `gcd(r, m) < r`, and since `gcd(r, m) > 0` (as `r > 0`), this is a positive appearance index strictly below the rank — contradicting minimality (Lemma 3.4). Hence `r ∣ m`. ∎

Equivalently: the set of indices at which `p` divides `u` is *exactly* the set of multiples of `rank(u, p)`. This single biconditional, phrased with no externally supplied index, is the abstract law of apparition.

---

## 6. The join law in ranks

The criterion linearizes naturally to several divisors at once.

**Theorem 6.1 (Join law in ranks).** Let `IsStrongDivSeq(u)`, `Appears(u, p)`, and `Appears(u, q)`. Then for all `n`,

> `(p ∣ u(n) ∧ q ∣ u(n)) ⟺ lcm(rank(u, p), rank(u, q)) ∣ n`.

*Proof sketch.* Apply Theorem 5.1 to each conjunct: `p ∣ u(n) ⟺ rank(u, p) ∣ n` and `q ∣ u(n) ⟺ rank(u, q) ∣ n`. Their conjunction is `rank(u, p) ∣ n ∧ rank(u, q) ∣ n`, which is equivalent to `lcm(rank(u, p), rank(u, q)) ∣ n` by the universal property of lcm. ∎

Interpretation: the indices at which `p` and `q` *simultaneously* appear form the multiples of the least common multiple of their ranks. Two independent apparition "frequencies" synchronize at the lcm of their periods — a discrete analogue of beat phenomena. The result extends by induction to any finite family of divisors, with the lcm taken over all their ranks.

---

## 7. Specializations and the order bridge

The power of the abstract criterion is that concrete laws drop out by supplying a single structural fact per family.

### 7.1 Fibonacci

The Fibonacci sequence satisfies `gcd(F_m, F_n) = F_{gcd(m,n)}`, hence `IsStrongDivSeq(F)`. Theorem 5.1 specializes immediately.

**Corollary 7.1 (Fibonacci law of apparition).** If `Appears(F, p)`, then for all `m`,

> `p ∣ F_m ⟺ rank(F, p) ∣ m`.

For example, `rank(F, 7) = 8` (since `F_8 = 21 = 3 · 7` and `7 ∤ F_k` for `k < 8`), so `7 ∣ F_m` exactly when `8 ∣ m`; and `rank(F, 11) = 10` (since `F_{10} = 55 = 5 · 11`), so `11 ∣ F_m` exactly when `10 ∣ m`.

### 7.2 The `aⁿ − 1` family

For each base `a`, the sequence `u(n) = aⁿ − 1` satisfies `gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`, hence `IsStrongDivSeq`.

**Corollary 7.2 (Law of apparition for `aⁿ − 1`).** If `p` appears in `u(n) = aⁿ − 1`, then for all `m`,

> `p ∣ aᵐ − 1 ⟺ rank(u, p) ∣ m`.

For `a = 2`: `rank(u, 7) = 3` (since `2³ − 1 = 7`), so `7 ∣ 2ᵐ − 1` exactly when `3 ∣ m`.

### 7.3 The rank–order identity

For the family `aⁿ − 1` the rank has a transparent group-theoretic meaning. Working modulo `p`, `p ∣ aⁿ − 1` is equivalent to `aⁿ ≡ 1 (mod p)`, i.e. `(a mod p)ⁿ = 1` in the ring `ℤ/pℤ`. The least positive such `n` is by definition the **multiplicative order** of `a` modulo `p`. Therefore, whenever `a` is a unit modulo `p` (i.e. `gcd(a, p) = 1`, guaranteeing appearance via Euler's theorem `a^{φ(p)} ≡ 1`),

> `rank(aⁿ − 1, p) = ord_p(a)`,

the rank of apparition of `p` equals the multiplicative order of `a` modulo `p`. Composed with Corollary 7.2 this reproduces the standard fact `p ∣ aᵐ − 1 ⟺ ord_p(a) ∣ m`. A divisibility-theoretic least-witness and a group-theoretic order are thus literally the same natural number.

---

## 8. Algorithms

The definitions are directly computable for the Fibonacci and `aⁿ − 1` families, yielding simple algorithms.

**Algorithm A (Rank of apparition).** *Input:* a procedure computing `u(k)`, a divisor `p`, and a search bound `K`. *Output:* the least `k ∈ [1, K]` with `p ∣ u(k)`, or "not found." Iterate `k = 1, 2, …, K`; return the first `k` with `u(k) ≡ 0 (mod p)`. For `aⁿ − 1` one computes `aᵏ mod p` incrementally (multiply by `a`, reduce mod `p`) so each step is `O(log p)` and the loop is bounded by `ord_p(a) ≤ p − 1`.

**Algorithm B (Apparition test).** *Input:* `p`, index `m`. *Output:* whether `p ∣ u(m)`. Compute `r = rank(u, p)` by Algorithm A, then return `r ∣ m` (Theorem 5.1). This replaces a direct (and possibly astronomically large) computation of `u(m)` with a divisibility check on indices.

**Algorithm C (Joint apparition).** *Input:* `p`, `q`, index `n`. *Output:* whether `p ∣ u(n) ∧ q ∣ u(n)`. Compute `rank(u, p)` and `rank(u, q)`, form `L = lcm(rank(u, p), rank(u, q))`, return `L ∣ n` (Theorem 6.1).

The mathematical content of these algorithms is exactly the equivalences of Theorems 5.1 and 6.1: they are correct *because* the divisibility set is the multiples of the rank.

---

## 9. Applications

- **Index-only divisibility.** Theorem 5.1 turns a question about an enormous term `u(m)` into a divisibility question about the small index `m` and the rank. For Fibonacci numbers with millions of digits, "does 7 divide `F_m`?" reduces to "is `m` a multiple of 8?"
- **Primality and order computations.** Via Section 7.3, computing the rank in `2ⁿ − 1` computes the multiplicative order of 2 modulo `p`, a primitive used throughout primality testing, finite-field arithmetic, and the security analysis of discrete-logarithm-based cryptography.
- **Synchronization and design.** The join law (Theorem 6.1) predicts the indices at which several prescribed factors co-occur, useful wherever periodic divisibility constraints must be aligned.
- **A portable theory.** Any newly discovered sequence proved to satisfy the gcd identity instantly inherits the complete apparition calculus — existence of a unique computable rank, the divisibility criterion, and the join law — with no further proof.

---

## 10. Discussion

The conceptual move in this work is to replace an *assumed* primitive index by a *constructed* one. Once the rank is defined as a least element, the two facts "the rank appears" and "nothing earlier appears" are immediate, and from them the entire apparition theory follows by the single structural identity of strong divisibility sequences. No properties of Fibonacci numbers or of exponentiation are used anywhere in the general theorems; the concrete laws are obtained purely by exhibiting the gcd identity for each family.

The criterion also clarifies the logical dependencies. The backward direction of Theorem 5.1 needs only the *weak* divisibility law (Lemma 2.3), itself a corollary of strong divisibility. The forward direction is where strong divisibility is essential: it is the descent of a common divisor of `u(r)` and `u(m)` to `u(gcd(r, m))` that creates the contradiction with minimality. This isolates the strong-divisibility hypothesis to exactly one step.

A boundary subtlety is the role of appearance. When `p` does not appear, the rank is `0` by convention and the criterion's equivalence degenerates (`rank ∣ m` would hold for all `m`). All main theorems therefore carry an appearance hypothesis, which for the `aⁿ − 1` family is exactly coprimality of `a` and `p` (Euler's theorem provides the witness).

---

## 11. Future directions

**Direction 1 — Multiplicativity of the rank over coprime divisors.** *Conjecture:* for a strong divisibility sequence `u` and coprime appearing divisors `p`, `q` (i.e. `gcd(p, q) = 1`), the product `p · q` appears and

> `rank(u, p · q) = lcm(rank(u, p), rank(u, q))`.

This strengthens the join law (Theorem 6.1): where the join law governs the *common* apparition set by the lcm of ranks, the conjecture asserts that the rank of the *product* divisor equals that lcm exactly. It is falsifiable by a single counterexample with `p · q ∣ u(n)` for some `n` not a multiple of `lcm(rank(u, p), rank(u, q))`. The key observation is that for coprime `p, q`, `p · q ∣ u(n)` is equivalent to `p ∣ u(n) ∧ q ∣ u(n)`, so the join law should collapse to a rank identity. Coprimality is precisely the hypothesis that turns the conjunction of divisibilities into divisibility by the product.

Further natural targets include: a fully general counting law expressing the density `1 / rank(u, p)` of appearance indices in `[1, N]`; extension to Lucas sequences and elliptic divisibility sequences; and an effective bound on the rank in terms of `p` for specific families (for `aⁿ − 1`, `rank ≤ p − 1`).

---

## 12. Conclusion

By defining the rank of apparition as the least positive appearance index, we obtain a self-contained primitive-divisor criterion for arbitrary strong divisibility sequences: the rank is always the unique primitive index (Theorems 4.1, 4.2), divisibility is exactly the multiples of the rank (Theorem 5.1), and joint divisibility is the multiples of the lcm of ranks (Theorem 6.1). Specialization recovers the Fibonacci and `aⁿ − 1` laws of apparition from one definition and one proof, and for the Mersenne family identifies the rank with the multiplicative order. The theory is portable: any sequence satisfying the gcd identity inherits the whole calculus automatically.
