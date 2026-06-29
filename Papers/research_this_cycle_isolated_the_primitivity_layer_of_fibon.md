# Strong Divisibility Sequences: An Axiomatic Theory of Primitive Divisors and Apparition

## Abstract

We isolate the single algebraic axiom underlying the divisibility theory of the
Fibonacci numbers and show that the entire structural layer of *primitivity* and
*apparition* depends on it alone. A sequence `u : ℕ → ℕ` is a **strong
divisibility sequence** if `u(gcd(m, n)) = gcd(u(m), u(n))` for all `m, n`. From
this one identity we derive, for an arbitrary such `u`: the classical weak
divisibility law (`m ∣ n ⇒ u(m) ∣ u(n)`) as a free corollary; a sharp *meet
law* characterizing divisibility at gcd-indices for an arbitrary divisor;
*rigidity* of primitive divisors (a value is primitive for at most one positive
index); a *pinning law* showing a primitive divisor of `u(n)` divides exactly
the terms at multiples of `n`; a *join law* describing simultaneous apparition of
two — and of finitely many — primitive divisors in terms of the least common
multiple of their indices; and exact *counting/density* results that turn the
qualitative apparition predicate into lattice-point counts. The Fibonacci
sequence and the family `n ↦ a^n − 1` (the Mersenne / `a^n − 1` sequences) are
recorded as instances, so the theory subsumes Fibonacci, Mersenne, and Lucas-type
apparition theory under one signature. We also pinpoint the precise boundary fact
(`u(0) = 0`) silently used in the Fibonacci-specific development, and we delimit
the theory against the analytic *existence* question (Carmichael's primitive
divisor theorem), which lies outside its scope. All results have been formalized
and machine-checked.

**Keywords.** strong divisibility sequence, primitive divisor, rank of
apparition, entry point, Fibonacci numbers, Mersenne numbers, Lucas sequences,
gcd–lcm lattice, divisibility density.

**MSC (informal).** 11B39 (Fibonacci and Lucas numbers), 11A05 (multiplicative
structure, divisibility), 11B83 (special sequences).

---

## 1. Introduction

The Fibonacci sequence `F : ℕ → ℕ`, defined by `F(0) = 0`, `F(1) = 1`,
`F(n+2) = F(n+1) + F(n)`, exhibits a rich divisibility theory. Two classical
facts organize most of it:

- **(Weak)** `m ∣ n ⇒ F(m) ∣ F(n)` (Fibonacci numbers at multiples of an index
  are divisible by the term there).
- **(Strong)** `gcd(F(m), F(n)) = F(gcd(m, n))` (the gcd of two Fibonacci numbers
  is the Fibonacci number at the gcd of the indices).

Around these orbit the notions of the **rank of apparition** (or **entry
point**) of an integer `p` — the least positive index `n` with `p ∣ F(n)` — and
of a **primitive divisor** of `F(n)` — an integer dividing `F(n)` but none of
`F(1), ..., F(n−1)`. A companion development in this catalog
(`FibonacciPrimitiveDivisors.lean`) proved the rigidity and apparition laws for
these notions *directly* from (Strong), deliberately avoiding the `Nat.find`
machinery used to define entry points elsewhere.

The present work executes the obvious but powerful next step: it *forgets that
the sequence is Fibonacci*. We retain only the abstract property

> `u(gcd(m, n)) = gcd(u(m), u(n))`   for all `m, n ∈ ℕ`,

call a sequence satisfying it a **strong divisibility sequence**, and re-derive
the *entire* primitivity/apparition backbone for an arbitrary such `u`. The
payoff is twofold. First, **economy of hypotheses**: we learn exactly which facts
each theorem actually consumes — for example, uniqueness of primitive divisors
needs neither (Strong) nor (Weak), while the pinning law needs (Strong) but
nothing about size or primality. Second, **cross-domain reuse**: the family
`u(n) = a^n − 1` is a strong divisibility sequence (a classical gcd identity), so
the same theorems instantly govern Mersenne numbers `2^n − 1` and, more broadly,
the multiplicative-order theory of `a` modulo a prime. The Lean development is
`Catalog/Applications/StrongDivisibilitySequences.lean`.

We additionally realize a *quantitative* layer: because a primitive divisor's
apparition set is exactly an arithmetic progression of indices, the number of
apparitions in a window `[1, N]` is an exact floor count, and the long-run
density is the reciprocal of the index.

### 1.1 Contributions

1. A definition `IsStrongDivSeq u := ∀ m n, u(gcd(m, n)) = gcd(u(m), u(n))`, and
   the proof that the weak law `m ∣ n ⇒ u(m) ∣ u(n)` is a one-line corollary.
2. The **meet law** `d ∣ u(gcd(m, n)) ↔ d ∣ u(m) ∧ d ∣ u(n)` for an arbitrary
   divisor `d`.
3. **Rigidity**: a value is a primitive divisor of at most one positive index,
   together with the boundary lemma exposing the role of `u(0) = 0`.
4. The **pinning law**: a primitive divisor of `u(n)` divides `u(m)` iff `n ∣ m`.
5. The **join laws**: pairwise and finite-family simultaneous apparition governed
   by `lcm`.
6. **Counting/density**: exact cardinalities `N / n` and `N / lcm(a, b)` of
   apparition indices in `[1, N]`.
7. Two instances — `Nat.fib` and `n ↦ a^n − 1` — transporting all results to
   the Fibonacci and Mersenne/`a^n − 1` families.

---

## 2. Definitions

Throughout, `u : ℕ → ℕ`, and `gcd`, `lcm` are the natural-number greatest common
divisor and least common multiple, with the standard conventions
`gcd(0, n) = n` and `lcm(0, n) = 0`.

**Definition 2.1 (Strong divisibility sequence).**
`u` is a *strong divisibility sequence*, written `IsStrongDivSeq u`, if
```
∀ m n ∈ ℕ,   u(gcd(m, n)) = gcd(u(m), u(n)).
```

**Definition 2.2 (Primitive divisor).**
For `p, n ∈ ℕ`, `p` is a *primitive divisor* of `u(n)`, written
`IsPrimitive u p n`, if
```
p ∣ u(n)   and   ∀ k, (0 < k ∧ k < n) ⇒ ¬ (p ∣ u(k)).
```
That is, `p` divides `u(n)` but no earlier positive-index term. The least `n` for
which `p ∣ u(n)` (when it exists and is positive) is the *rank of apparition* or
*entry point* of `p`; if `p` is a primitive divisor of `u(n)` with `n > 0`, then
`n` is exactly that entry point.

**Remark 2.3.** Definition 2.2 is purely combinatorial: it mentions only the
divisibility relation between `p` and the values `u(k)`. No order, growth, or
primality of `p` is assumed. This is why several results below need no algebraic
hypothesis at all.

---

## 3. Elementary consequences of the strong-divisibility law

**Theorem 3.1 (Weak divisibility law).**
If `IsStrongDivSeq u` and `m ∣ n`, then `u(m) ∣ u(n)`.

*Proof sketch.* `m ∣ n` gives `gcd(m, n) = m`. Hence
`u(m) = u(gcd(m, n)) = gcd(u(m), u(n))` by (Strong), and
`gcd(u(m), u(n)) ∣ u(n)`. ∎

This recovers Mathlib's `Nat.fib_dvd` as the special case `u = Nat.fib`. The
content is that the *weak* law is not an independent axiom but a free corollary of
the *strong* one.

**Theorem 3.2 (Meet law).**
If `IsStrongDivSeq u`, then for all `d, m, n ∈ ℕ`,
```
d ∣ u(gcd(m, n))   ↔   d ∣ u(m) ∧ d ∣ u(n).
```

*Proof sketch.* Rewrite the left side with (Strong) to `d ∣ gcd(u(m), u(n))`,
then apply the universal property of gcd (`d ∣ gcd(x, y) ↔ d ∣ x ∧ d ∣ y`). ∎

Theorem 3.2 is the technical engine of the paper. Note its generality: `d` is an
*arbitrary* divisor, not a primitive one, not prime, not related to `u`. It says
the family of index-sets `{ n : d ∣ u(n) }` behaves like a meet-semilattice under
gcd of indices.

---

## 4. Rigidity of primitive divisors

**Theorem 4.1 (Boundary at zero).**
If `u(0) = 0`, then `IsPrimitive u p 0` for every `p`.

*Proof sketch.* `p ∣ u(0) = 0` holds because everything divides `0`; the
minimality clause `∀ k, 0 < k ∧ k < 0 ⇒ ...` is vacuous. ∎

**Theorem 4.2 (Uniqueness of apparition).**
For `m, n > 0`, if `IsPrimitive u p m` and `IsPrimitive u p n`, then `m = n`.

*Proof sketch.* Suppose without loss of generality `m < n`. Primitivity at `n`
forbids `p ∣ u(k)` for every `k` with `0 < k < n`; taking `k = m` gives
`¬ (p ∣ u(m))`. But primitivity at `m` gives `p ∣ u(m)`, a contradiction. The
symmetric case `n < m` is identical, so `m = n`. ∎

Theorem 4.2 requires **neither** (Strong) **nor** (Weak): it is a direct clash of
the definitional minimality conditions. Together, Theorems 4.1 and 4.2 explain
the necessity of the positivity hypotheses: index `0` is a degenerate point at
which *every* value is vacuously primitive (whenever `u(0) = 0`), so uniqueness
can only be asserted among positive indices. For `u = Nat.fib`, `u(0) = 0` is
automatic; in the abstract setting it must be named explicitly, which is the
precise extra fact the Fibonacci proofs silently used.

---

## 5. The pinning law

**Theorem 5.1 (Pinning law).**
If `IsStrongDivSeq u`, `n > 0`, and `IsPrimitive u p n`, then for all `m`,
```
p ∣ u(m)   ↔   n ∣ m.
```

*Proof sketch.*
- (⇐) If `n ∣ m`, then `u(n) ∣ u(m)` by Theorem 3.1, and `p ∣ u(n)` by
  hypothesis, so `p ∣ u(m)`.
- (⇒) Suppose `p ∣ u(m)`. Since also `p ∣ u(n)`, the meet law (Theorem 3.2)
  gives `p ∣ u(gcd(n, m))`. Now `gcd(n, m) ∣ n`, so `gcd(n, m) ≤ n`, and
  `gcd(n, m) > 0` because `n > 0`. If `gcd(n, m) < n`, primitivity at `n` would
  forbid `p ∣ u(gcd(n, m))`, a contradiction. Hence `gcd(n, m) = n`, i.e.
  `n ∣ m`. ∎

This upgrades the qualitative existence of an entry point into a complete,
two-sided divisibility test: the apparition set of a primitive divisor of index
`n` is exactly the set `{ m : n ∣ m }` of multiples of `n`.

---

## 6. Simultaneous apparition: the join law

**Theorem 6.1 (Pairwise join law).**
If `IsStrongDivSeq u`, `a, b > 0`, `IsPrimitive u p a`, and `IsPrimitive u q b`,
then for all `n`,
```
(p ∣ u(n) ∧ q ∣ u(n))   ↔   lcm(a, b) ∣ n.
```

*Proof sketch.* By the pinning law (Theorem 5.1), `p ∣ u(n) ↔ a ∣ n` and
`q ∣ u(n) ↔ b ∣ n`. Hence the conjunction is equivalent to `a ∣ n ∧ b ∣ n`,
which by the universal property of lcm (`a ∣ n ∧ b ∣ n ↔ lcm(a, b) ∣ n`) is
`lcm(a, b) ∣ n`. ∎

Pairing this with the meet law (Theorem 3.2) reveals the lattice picture:
*apparition at a gcd of indices, co-apparition at an lcm of indices.* The map
sending a primitive divisor to its entry point intertwines divisibility of
divisors with the gcd–lcm lattice on `ℕ`.

**Theorem 6.2 (Finite-family join law).**
Let `s` be a finite index set, and `f, g : ι → ℕ` functions such that for every
`i ∈ s`, `g(i) > 0` and `IsPrimitive u (f i) (g i)`. Then for all `n`,
```
(∀ i ∈ s, f(i) ∣ u(n))   ↔   (lcm_{i ∈ s} g(i)) ∣ n,
```
where `lcm_{i ∈ s} g(i)` is the least common multiple over the family (with the
empty product convention `lcm_{∅} = 1`).

*Proof sketch.* Induction on the finite set `s`. The empty case reduces to
`True ↔ 1 ∣ n`. For the inductive step `s = {i} ∪ s'` with `i ∉ s'`: the
universal quantifier splits as the conjunction of "`f(i) ∣ u(n)`" and "all of
`s'`"; the first is `g(i) ∣ n` by Theorem 5.1, the second is
`lcm_{s'} g ∣ n` by the inductive hypothesis, and
`g(i) ∣ n ∧ lcm_{s'} g ∣ n ↔ lcm({g(i)} ∪ image) ∣ n` by the lcm-insert
identity. ∎

---

## 7. Counting and density

Because a primitive divisor's apparition set is an arithmetic progression of
indices, apparitions can be counted exactly. We count over the window of the
first `N` positive indices `{1, 2, ..., N}`, encoded as `{ e + 1 : e ∈ range N }`.

**Theorem 7.1 (Apparition count / density).**
If `IsStrongDivSeq u`, `n > 0`, and `IsPrimitive u p n`, then for all `N`,
```
#{ e ∈ range N : p ∣ u(e + 1) } = N / n        (integer division).
```
Consequently the natural density of apparition indices of `p` is `1/n`.

*Proof sketch.* By the pinning law, `p ∣ u(e + 1) ↔ n ∣ (e + 1)`. The number of
multiples of `n` in `{1, ..., N}` is exactly `⌊N / n⌋` (Mathlib's
`Nat.card_multiples`), giving the stated cardinality. Dividing by `N` and letting
`N → ∞` yields density `1/n`. ∎

**Theorem 7.2 (Simultaneous apparition count).**
If `IsStrongDivSeq u`, `a, b > 0`, `IsPrimitive u p a`, and
`IsPrimitive u q b`, then for all `N`,
```
#{ e ∈ range N : p ∣ u(e + 1) ∧ q ∣ u(e + 1) } = N / lcm(a, b).
```
Hence the joint density of common-apparition indices is `1 / lcm(a, b)`.

*Proof sketch.* By the join law (Theorem 6.1) the predicate is equivalent to
`lcm(a, b) ∣ (e + 1)`; count multiples of `lcm(a, b)` in `{1, ..., N}` as in
Theorem 7.1. ∎

These theorems convert the lattice-theoretic apparition laws into the exact
combinatorics of arithmetic progressions, the natural bridge between the
divisibility lattice and analytic number theory.

---

## 8. Instances

The abstract theory is vacuous without models. Two are recorded; each is a
two-line instance, after which *every* theorem of Sections 3–7 applies verbatim.

**Proposition 8.1 (Fibonacci).** `IsStrongDivSeq Nat.fib`.

*Proof.* This is exactly `Nat.fib_gcd : Nat.fib (gcd m n) = gcd (Nat.fib m)
(Nat.fib n)`. Since `Nat.fib 0 = 0`, the boundary hypothesis of Theorem 4.1 also
holds. ∎

Instantiating Sections 3–7 at `u = Nat.fib` recovers, verbatim, the results of
`FibonacciPrimitiveDivisors.lean`: the Fibonacci meet law, uniqueness of
primitive Fibonacci divisors, the index-divisibility test, and the Fibonacci join
laws.

**Proposition 8.2 (Mersenne / `a^n − 1`).** For any `a ∈ ℕ`,
`IsStrongDivSeq (fun n => a^n − 1)`.

*Proof.* This is the classical identity
`gcd(a^m − 1, a^n − 1) = a^{gcd(m, n)} − 1` (Mathlib's
`Nat.pow_sub_one_gcd_pow_sub_one`). Note `a^0 − 1 = 0`, so Theorem 4.1 applies
here too. ∎

For `a = 2` this is the **Mersenne** sequence `2^n − 1`. A primitive prime
divisor of `2^n − 1` is precisely a prime `p` whose multiplicative order
`ord_p(2)` equals `n`; Theorem 5.1 then reads "`p ∣ 2^m − 1 ↔ ord_p(2) ∣ m`",
the order-divisibility theorem, and Theorem 6.1 governs primes whose order is the
lcm of two prescribed orders. For general `a`, the entry point of a prime `p` in
`a^n − 1` is the multiplicative order of `a` modulo `p`, which also equals the
length of the repeating block in the base-`a` expansion of `1/p`.

---

## 9. Applications

- **Mersenne primes and multiplicative order.** Via Proposition 8.2 with `a = 2`,
  the pinning law is the statement that a prime divides `2^m − 1` exactly at
  multiples of its order. This is foundational to the analysis of Mersenne
  numbers and to Lucas–Lehmer-style reasoning about their factors.

- **Repeating decimals / base-`a` periods.** The entry point of `p` in
  `a^n − 1` is the period of `1/p` in base `a`. The join law (Theorem 6.1) then
  predicts exactly when two primes induce a common period structure.

- **Joint divisibility densities.** Theorems 7.1–7.2 give explicit densities for
  how often (Fibonacci, Mersenne, ...) terms are divisible by a fixed factor, or
  by a pair of factors, providing closed-form lattice-point counts for sieve- and
  density-type questions.

- **Cross-domain consolidation.** Any future sequence proven to be a strong
  divisibility sequence (general Lucas sequences `U_n`, division polynomials of
  elliptic curves over suitable rings, etc.) inherits the whole apparition theory
  at the cost of a single lemma, eliminating duplicated developments.

---

## 10. Discussion: what is and is not in scope

The theory is a complete *bookkeeping* calculus for primitive divisors: given
that a primitive divisor exists at index `n`, it determines exactly where (and
how often) it and its companions reappear. It is, by design, silent on the
*existence* question:

> **Carmichael's primitive divisor theorem.** Every Fibonacci number `F(n)` with
> `n` outside a finite exceptional set (`n ∈ {1, 2, 6, 12}`, equivalently for
> `n ≥ 13`) has a primitive prime divisor.

Existence is an *analytic / size* statement: one must show the "primitive part"
of `u(n)` exceeds `1`, typically via a cyclotomic factorization
`F(n) = ∏_{d ∣ n} Φ_d` and a lower bound on `Φ_n` after removing bounded
intrinsic factors. None of the divisibility identities in this paper produce such
a bound. The relationship is complementary: Theorems 4.2 and 5.1 reduce
"`p` is a primitive divisor of `u(n)`" to the clean index statement "`p` is a
prime with entry point exactly `n`", so the missing ingredient for Carmichael's
theorem is *only* the size estimate, not the divisibility bookkeeping — which is
exactly what this paper supplies in full.

A second boundary phenomenon is the failure of the entry-point map to be a *meet*
homomorphism: while it respects joins (lcm), it is only a lax morphism for meets
(gcd), with the smallest Fibonacci witness at indices `4` and `6`. The join half
of that picture is precisely Theorem 6.1.

---

## 11. Future work

A detailed program appears in the package's *Future Directions*. In brief:

1. **Existence (the Carmichael tail).** Supply the size estimate that, combined
   with Theorems 4.2 and 5.1, yields a full formal proof of Carmichael's theorem
   and discharges the remaining `sorry` for composite `n > 10000` in the
   catalog's `CarmichaelProof.lean`.

2. **The quadratic-residue law.** Prove `e(p) ∣ p − (5/p)` for primes `p ≠ 5`
   (Legendre symbol `(5/p)`), giving an effective bound `e(p) ≤ p + 1` on
   Fibonacci entry points, by combining the congruence `p ∣ F_{p − (5/p)}` with
   Theorem 5.1.

3. **Further instances.** Verify `IsStrongDivSeq` for general Lucas sequences and
   record the resulting apparition theory as automatic corollaries.

4. **Lattice isomorphism.** Combine Theorem 4.2 with the catalog's
   `fibEntry_lcm` / `fibEntry_gcd_not_exact` to characterize the entry-point map
   as an injective join-homomorphism, locating exactly where the meet structure
   fails.

5. **Analytic density.** Pass from the exact counts of Theorems 7.1–7.2 to
   limiting densities and joint distributions over families of primitive
   divisors.

---

## 12. Conclusion

A single equation, `u(gcd(m, n)) = gcd(u(m), u(n))`, generates the complete
structural theory of primitive divisors and apparition: the weak law, the meet
law, rigidity of debuts, the pinning calendar, the pairwise and finite join laws,
and exact apparition densities. Fibonacci and `a^n − 1` are merely two instances.
By tracking, theorem by theorem, exactly which hypothesis is consumed, the
axiomatic treatment both clarifies the classical Fibonacci theory and transports
it, at the cost of one lemma per instance, across the divisibility sequences of
number theory.
