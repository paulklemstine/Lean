# The Rank of Apparition for Strong Divisibility Sequences, and its Identification with the Multiplicative Order

## Abstract

The *rank of apparition* `r(m) = min { k > 0 : m ∣ F(k) }` is the classical
organizing invariant behind the divisibility structure of the Fibonacci
sequence: the *spine* `m ∣ F(n) ↔ r(m) ∣ n` reduces every divisibility question
to ordinary divisibility of indices, and a value `p` is a primitive divisor of
`F(n)` precisely when `r(p) = n`. We isolate the exact hypothesis on which this
theory rests — the **strong divisibility law** `u(gcd(m,n)) = gcd(u(m), u(n))` —
and rebuild the rank of apparition for an *arbitrary* strong divisibility
sequence `u`. We prove, with no recourse to any sequence-specific structure, the
abstract spine `m ∣ u(n) ↔ seqRank(u, m) ∣ n` and the primitivity
characterization `IsPrimitive(u, p, n) ↔ seqRank(u, p) = n`. Both Fibonacci and
the Mersenne family `u(n) = aⁿ − 1` are instances. For the Mersenne family we
close a cross-domain loop: the divisibility-theoretic rank coincides exactly with
the group-theoretic multiplicative order,
`seqRank(n ↦ aⁿ − 1, m) = ord_m(a)`, whenever `a ≥ 1`, `m > 0`, and
`gcd(a, m) = 1`. All results have been formally verified.

**Keywords.** rank of apparition, strong divisibility sequence, primitive
divisor, multiplicative order, Fibonacci numbers, Mersenne numbers, Lucas
sequences, Carmichael's theorem.

---

## 1. Introduction

A *divisibility sequence* is a sequence `u : ℕ → ℕ` with the property that
`m ∣ n ⟹ u(m) ∣ u(n)`. The Fibonacci sequence `F`, the Mersenne-type sequences
`aⁿ − 1`, the repunits, and nondegenerate Lucas sequences `U_n(P,Q)` are all
classical examples. A sharper and more structured class are the **strong
divisibility sequences**, which satisfy the gcd-compatibility law

> `u(gcd(m, n)) = gcd(u(m), u(n))` for all `m, n`.

For the Fibonacci sequence this is the celebrated identity
`gcd(F(m), F(n)) = F(gcd(m, n))`; for the Mersenne family it is
`gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`.

Attached to any such sequence is the **rank of apparition** of a modulus `m`:
the least positive index at which `m` divides a term. For Fibonacci, the rank
controls everything. Two structural facts dominate the theory:

- **The spine.** `m ∣ F(n)` if and only if `r(m) ∣ n`. Divisibility of values is
  divisibility of indices.
- **Primitive divisors.** A primitive divisor of `F(n)` is a prime dividing
  `F(n)` but none of `F(1), …, F(n−1)`; these are exactly the primes `p` with
  `r(p) = n`. Their existence for all `n ∉ {1, 2, 6, 12}` is **Carmichael's
  theorem** (1913), the Fibonacci analogue of Zsygmondy's theorem.

The Fibonacci theory had been developed several times in parallel, each time
re-establishing the spine from scratch, and an abstract "strong divisibility
sequence" framework existed *without any rank function at all*. The present work
fuses the two: it equips an arbitrary strong divisibility sequence with a rank of
apparition and proves the spine and primitivity characterization at full
generality, so that the Fibonacci theory becomes a single instantiation rather
than a bespoke derivation. It then crosses a domain boundary, identifying the
rank of apparition of the Mersenne family with the multiplicative order — a
purely group-theoretic invariant of `(ℤ/mℤ)ˣ`.

### Contributions

1. **An abstract rank of apparition** `seqRank(u, m)` for arbitrary `u`
   (§3), together with its defining minimality properties.
2. **The abstract spine** `m ∣ u(n) ↔ seqRank(u, m) ∣ n` for any strong
   divisibility sequence in which `m` has a rank (§4, Theorem 4.1).
3. **The primitivity characterization** `IsPrimitive(u, p, n) ↔ seqRank(u, p) =
   n` for `n > 0` (§5, Theorem 5.1).
4. **Two instances**: Fibonacci (§6) and Mersenne (§7), the latter including the
   **rank = order bridge** `seqRank(n ↦ aⁿ − 1, m) = ord_m(a)` (Theorem 7.3).

---

## 2. Preliminaries and definitions

Throughout, `u : ℕ → ℕ`, and `∣`, `gcd` are the usual divisibility and greatest
common divisor on `ℕ`.

**Definition 2.1 (Strong divisibility sequence).**
`u` is a *strong divisibility sequence*, written `IsStrongDivSeq(u)`, if
`u(gcd(m, n)) = gcd(u(m), u(n))` for all `m, n ∈ ℕ`.

**Definition 2.2 (Has a rank).**
A modulus `m` *has a rank* in `u`, written `HasRank(u, m)`, if there exists
`k > 0` with `m ∣ u(k)`.

**Definition 2.3 (Primitive divisor).**
`p` is a *primitive divisor* of `u(n)`, written `IsPrimitive(u, p, n)`, if
`p ∣ u(n)` and for all `k` with `0 < k < n`, `p ∤ u(k)`. That is, `n` is the
first index at which `p` appears.

We first record the only consequence of strong divisibility used by the backward
direction of the spine.

**Lemma 2.4 (Strong ⟹ weak divisibility).**
If `IsStrongDivSeq(u)` and `m ∣ n`, then `u(m) ∣ u(n)`.

*Proof.* From `m ∣ n` we have `gcd(m, n) = m`. Substituting into the strong law,
`u(m) = u(gcd(m,n)) = gcd(u(m), u(n))`, and `gcd(u(m), u(n)) ∣ u(n)`. ∎

Thus every strong divisibility sequence is in particular a divisibility sequence;
the converse fails (e.g. `u(n) = n²` is a divisibility sequence but not strong).

---

## 3. The abstract rank of apparition

**Definition 3.1 (`seqRank`).**
The *rank of apparition* of `m` in `u` is
```
seqRank(u, m) = (least k > 0 with m ∣ u(k))   if such k exists,
             = 0                               otherwise.
```
Formally it is `Nat.find` applied to the predicate `k ↦ 0 < k ∧ m ∣ u(k)` when
that predicate is satisfiable, and `0` otherwise. The function is noncomputable in
its abstract form because satisfiability is decided classically; for concrete
sequences with an a-priori search bound it becomes effective (see §8).

Three properties pin down `seqRank` and are used repeatedly.

**Lemma 3.2 (Positivity).** If `HasRank(u, m)` then `seqRank(u, m) > 0`.

**Lemma 3.3 (Divisibility at the rank).** If `HasRank(u, m)` then
`m ∣ u(seqRank(u, m))`.

**Lemma 3.4 (Minimality).** If `0 < k < seqRank(u, m)` then `m ∤ u(k)`.

*Proofs.* All three unfold Definition 3.1. Under `HasRank(u, m)` the `Nat.find`
branch is taken; 3.2 and 3.3 are the two conjuncts of `Nat.find_spec`, and 3.4 is
`Nat.find_min`. In the non-`HasRank` branch `seqRank = 0`, so `k < 0` is vacuous
in 3.4. ∎

---

## 4. The spine

**Theorem 4.1 (Abstract spine).**
Let `IsStrongDivSeq(u)` and `HasRank(u, m)`. Then for all `n`,
> `m ∣ u(n)  ⟺  seqRank(u, m) ∣ n`.

*Proof.* Write `r = seqRank(u, m)`; by Lemma 3.2, `r > 0`, and by Lemma 3.3,
`m ∣ u(r)`.

(⟸) Suppose `r ∣ n`. By Lemma 2.4, `u(r) ∣ u(n)`. Chaining with `m ∣ u(r)` gives
`m ∣ u(n)`.

(⟹) Suppose `m ∣ u(n)`; we show `r ∣ n` by contraposition. Assume `r ∤ n`. Let
`g = gcd(r, n)`. Since `r ∤ n`, `g ≠ r`, and since `g ∣ r` with `r > 0`,
`g ≤ r`; hence `g < r`. Also `g = gcd(r, n) > 0` because `r > 0`. Now from
`m ∣ u(r)` (Lemma 3.3) and the assumed `m ∣ u(n)`, we get
`m ∣ gcd(u(r), u(n))`. By the strong law `gcd(u(r), u(n)) = u(gcd(r, n)) =
u(g)`, so `m ∣ u(g)`. But `0 < g < r = seqRank(u, m)` contradicts the
minimality Lemma 3.4. Therefore `r ∣ n`. ∎

The proof uses *only* the strong-divisibility hypothesis (via Lemma 2.4 forward
and the strong law itself backward) together with the three minimality lemmas of
§3. No property of any particular sequence appears.

A standard corollary, the order-morphism law, follows immediately: if
`HasRank(u, b)` whenever `HasRank(u, a)` and `b ∣ a`, then
`b ∣ a ⟹ seqRank(u, b) ∣ seqRank(u, a)`. (Apply Theorem 4.1 twice.)

---

## 5. Primitivity equals "rank = index"

**Theorem 5.1 (Primitivity characterization).**
Let `IsStrongDivSeq(u)`, `HasRank(u, p)`, and `n > 0`. Then
> `IsPrimitive(u, p, n)  ⟺  seqRank(u, p) = n`.

*Proof.* Write `r = seqRank(u, p)`.

(⟹) Assume `IsPrimitive(u, p, n)`, i.e. `p ∣ u(n)` and `p ∤ u(k)` for all
`0 < k < n`. By the spine (Theorem 4.1), `p ∣ u(n)` gives `r ∣ n`, and as `n >
0`, `r ≤ n`. If `r < n`, then taking `k = r` (which satisfies `0 < r < n` by
Lemma 3.2) the primitivity clause forces `p ∤ u(r)`, contradicting Lemma 3.3.
Hence `r = n`.

(⟸) Assume `r = n`. Then `p ∣ u(n) = u(r)` by Lemma 3.3, giving the first
clause. For the second, any `k` with `0 < k < n = r` has `p ∤ u(k)` by minimality
(Lemma 3.4). Thus `IsPrimitive(u, p, n)`. ∎

This is the conceptual core "a primitive divisor exists at index `n` iff some
value has rank exactly `n`". For Fibonacci it is the engine of Carmichael's
theorem: proving `F(n)` has a primitive prime divisor is exactly exhibiting a
prime `p` with `seqRank(F, p) = n`.

---

## 6. Instance I: the Fibonacci sequence

**Proposition 6.1.** `Nat.fib` is a strong divisibility sequence.

*Proof.* This is the classical identity `gcd(F(m), F(n)) = F(gcd(m, n))`,
available in Mathlib as `Nat.fib_gcd`. ∎

Consequently Theorems 4.1 and 5.1 specialize verbatim to Fibonacci, recovering:

- the Fibonacci spine `m ∣ F(n) ↔ r(m) ∣ n`;
- the characterization `p` is a primitive divisor of `F(n)` iff `r(p) = n`;

reproducing — as instances of two general theorems — what the catalog previously
established by several independent derivations. Existence of the rank for every
positive modulus (`HasRank(Nat.fib, m)` for `m > 0`) is the standard pigeonhole
argument on the Fibonacci pair sequence `(F(k), F(k+1)) mod m`, which is
eventually periodic because the shift map `(a, b) ↦ (b, a + b)` is a bijection of
the finite set `(ℤ/mℤ)²`.

---

## 7. Instance II: the Mersenne family and the order bridge

Fix a base `a ∈ ℕ` and consider the Mersenne-type sequence `mer_a(n) = aⁿ − 1`.

**Proposition 7.1.** For any `a`, `mer_a` is a strong divisibility sequence:
`gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`.

*Proof sketch.* The classical Euclidean-style argument: working with the
identity `a^{m} − 1 ≡ a^{m \bmod n} − 1 \pmod{a^n − 1}`, the gcd computation on
exponents mirrors the Euclidean algorithm, descending to the exponent `gcd(m,n)`.
∎

**Proposition 7.2 (Existence of the rank, via Euler).** If `a ≥ 1`, `m > 0`, and
`gcd(a, m) = 1`, then `HasRank(mer_a, m)`.

*Proof sketch.* By Euler's theorem `a^{φ(m)} ≡ 1 (mod m)` with `φ(m) > 0`, so
`m ∣ a^{φ(m)} − 1 = mer_a(φ(m))`, exhibiting a positive index at which `m`
divides a term. ∎

The bridge to group theory rests on the elementary translation of divisibility
into a congruence, and of congruence into a statement about the multiplicative
order `ord_m(a) := orderOf((a : ℤ/mℤ))`.

**Theorem 7.3a (Mersenne spine in order form).**
For `a ≥ 1`, `m > 0`, `gcd(a, m) = 1`,
> `m ∣ aⁿ − 1  ⟺  ord_m(a) ∣ n`.

*Proof sketch.* `m ∣ aⁿ − 1` is equivalent to `aⁿ ≡ 1 (mod m)`, i.e.
`(a : ℤ/mℤ)ⁿ = 1`. Since `a` is a unit mod `m` (coprimality), this holds iff the
order of `a` divides `n`, by the defining property of `orderOf` in a finite
group. ∎

**Theorem 7.3 (Rank of apparition = multiplicative order).**
For `a ≥ 1`, `m > 0`, `gcd(a, m) = 1`,
> `seqRank(mer_a, m) = ord_m(a)`.

*Proof.* By Proposition 7.2, `HasRank(mer_a, m)`, so by the abstract spine
(Theorem 4.1, valid since `mer_a` is a strong divisibility sequence by Prop. 7.1)
`m ∣ mer_a(n) ↔ seqRank(mer_a, m) ∣ n`. By Theorem 7.3a,
`m ∣ mer_a(n) ↔ ord_m(a) ∣ n`. Hence the two natural numbers `seqRank(mer_a, m)`
and `ord_m(a)` divide exactly the same set of indices `n`; in particular each
divides the other, so they are equal. ∎

Theorem 7.3 is the cross-domain payoff: the divisibility-theoretic invariant
(rank of apparition) and the group-theoretic invariant (multiplicative order of a
unit in `(ℤ/mℤ)ˣ`) are literally the same number. As an immediate corollary,
since `ord_m(a) ∣ φ(m)` (Lagrange's theorem in `(ℤ/mℤ)ˣ`), the Mersenne rank of
apparition divides Euler's totient `φ(m)` — a bound obtained for free by
transport across the bridge.

---

## 8. Algorithms

While `seqRank` is noncomputable in its fully abstract form, every instance with
an a-priori search bound is effective. Two algorithms are central.

**Algorithm A (Linear-scan rank of apparition).** Given a divisibility predicate
`k ↦ m ∣ u(k)` and a bound `B` (e.g. `B = φ(m)` for Mersenne, or the Pisano
period bound `≤ 6m` for Fibonacci), scan `k = 1, 2, …, B` and return the first
hit. Correctness is Lemma 3.3/3.4; termination is the bound. Complexity is
`O(B · C)` where `C` is the cost of one divisibility test (for Mersenne, one
modular exponentiation, `O(log n · (\log m)^2)` with fast exponentiation).

**Algorithm B (Primitive-divisor witness search).** To certify that `u(n)` has a
primitive divisor: compute `u(n)`, factor it (or scan its prime factor list), and
for each prime `p ∣ u(n)` test whether `seqRank(u, p) = n` via Algorithm A. By
Theorem 5.1 a positive answer is exactly a primitive divisor. For the Fibonacci
range `n ∈ [3, 60] ∖ {6, 12}` this furnishes a finite, kernel-checkable proof of
Carmichael's theorem on that range, the computational core that any proof of the
infinite tail must extend.

---

## 9. Applications

- **Unification of catalog Fibonacci theory.** The five-plus parallel
  developments of Fibonacci rank theory collapse to instances of Theorems 4.1
  and 5.1 by Proposition 6.1.
- **Carmichael's theorem, finite range.** Theorem 5.1 reduces "primitive divisor
  exists at `n`" to "`∃ p` prime with `seqRank(F, p) = n`", a decidable
  condition, verified computationally on `[3, 60] ∖ {6, 12}`.
- **Order computations via divisibility.** Theorem 7.3 lets one compute or bound
  the multiplicative order of `a` mod `m` by studying the Mersenne divisibility
  sequence, and conversely import group-theoretic bounds (Lagrange, structure of
  `(ℤ/mℤ)ˣ`) into apparition theory.
- **Cryptographic relevance.** The multiplicative order governs the period of
  pseudo-random generators, the security of Diffie–Hellman, and primality tests;
  the bridge gives these a divisibility-sequence reading.

---

## 10. Discussion and future work

The decisive realization is that *none of the divisibility scaffolding used any
property of Fibonacci beyond the strong-divisibility law* `u(gcd(m,n)) =
gcd(u(m), u(n))`. Once abstracted, the rank function and its spine are forced,
and specialize to Fibonacci, to `aⁿ − 1`, and (with the strong-divisibility
input swapped) to any nondegenerate Lucas sequence. Promising directions:

1. **A `StrongDivisibilitySequence` typeclass** bundling `IsStrongDivSeq(u)`,
   `u(0) = 0`, `u(1) = 1`, and a totality-of-rank field, so the spine,
   primitivity characterization, and lattice meet/join laws are available to all
   catalog Fibonacci/Lucas/Mersenne files through one interface.
2. **The composite infinite tail of Carmichael's theorem.** Theorem 5.1 reduces
   the open tail to: every composite `n > N` admits a prime `p` with
   `seqRank(F, p) = n`. The remaining gap is an analytic size estimate comparing
   the primitive part `Φ_n` to the intrinsic (non-primitive) prime contribution,
   the latter being logarithmic by Lifting-the-Exponent while `log F(n)` grows
   linearly.
3. **Lucas sequences `U_n(P,Q)`.** Replace `Nat.fib_gcd` by the strong
   divisibility of nondegenerate Lucas sequences; every theorem here transfers.
4. **Effective `seqRank`.** A proven search bound (Pisano period `≤ 6m` for
   Fibonacci; `φ(m)` for Mersenne) upgrades `seqRank` from noncomputable to a
   verified algorithm, and yields `r(p) ∣ p ± 1` for Fibonacci primes `p ≠ 5`.
5. **Density of primitive primes.** Counting primitive primes of `u(n)` is
   counting prime factors of the primitive part `Φ_n`, a decidable quantity per
   `n`; conjecturally `#{ p : seqRank(F, p) = n } ≥ 2` for all `n > 30`.

---

## 11. Conclusion

The rank of apparition, long treated as a Fibonacci-specific device, is a
property of *every* strong divisibility sequence: a single hypothesis forces the
rank, the spine `m ∣ u(n) ↔ seqRank(u, m) ∣ n`, and the primitivity equation
`IsPrimitive(u, p, n) ↔ seqRank(u, p) = n`. On the Mersenne family this abstract
invariant coincides exactly with the multiplicative order, `seqRank(n ↦ aⁿ − 1,
m) = ord_m(a)`, fusing a divisibility-theoretic notion with a group-theoretic
one. The result both unifies a fragmented body of Fibonacci theory and opens a
two-way dictionary between number theory and group theory.
