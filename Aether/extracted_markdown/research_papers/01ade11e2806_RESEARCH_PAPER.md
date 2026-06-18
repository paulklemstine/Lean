# The Entry-Point Invariant of Strong Divisibility Sequences: Fractal Injectivity of Primitive Divisors

## Abstract

We isolate the rank of apparition (entry point) of a *strong divisibility sequence* — a
sequence `u : ℕ → ℕ` satisfying the renormalization identity
`gcd(u(m), u(n)) = u(gcd(m, n))` — as a first-class arithmetic invariant, and we develop
its theory entirely from that single identity. We prove three structural theorems that
depend on nothing but the renormalization identity and the minimality of the entry point:
(i) the entry point divides every index of appearance (`entry_dvd`), with no primality
hypothesis; (ii) a primitive divisor pins the entry point (`entry_eq_of_primitive`); and
(iii) **fractal injectivity** — a fixed modulus is a primitive divisor of at most one term
(`primitive_divisor_inj`), so distinct indices have disjoint primitive-divisor sets. These
abstract results instantiate with no further work at the Fibonacci numbers `u = F` (via
`gcd(F(m), F(n)) = F(gcd(m, n))`) and at the base-`a` Mersenne/repunit sequence
`u(n) = aⁿ − 1` (via `gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`). For the Fibonacci model we
additionally establish the law of apparition `m | F(k) ⟺ entry(m) | k`, the
characterization of primitive prime divisors `p` is primitive for `F(n)` iff `entry(p) = n`,
and an existence theorem — every prime divides some Fibonacci number — proved by a
reversible-dynamics pigeonhole argument on the pair-map modulo `p`. The organizing
methodological lesson is to *prove properties of the invariant the self-similarity induces,
rather than properties of the raw sequence.*

**Keywords:** strong divisibility sequence, rank of apparition, entry point, primitive
divisor, Fibonacci numbers, Mersenne numbers, Pisano period, Carmichael's theorem.

**MSC:** 11B39 (Fibonacci and Lucas numbers), 11A05 (multiplicative structure), 11B50
(sequences and sets).

---

## 1. Introduction

Édouard Lucas and R. D. Carmichael studied, around the turn of the twentieth century, the
prime factors of recurrent sequences such as the Fibonacci numbers
`F = 1, 1, 2, 3, 5, 8, 13, 21, …`. A central notion is the **primitive prime divisor**: a
prime `p` is a primitive divisor of `F(n)` if `p | F(n)` but `p ∤ F(k)` for all
`0 < k < n`. Carmichael's theorem asserts that `F(n)` has a primitive prime divisor for
every `n ≥ 13`. The mechanism that organizes this theory is the **rank of apparition**, or
**entry point**, of a modulus `m`: the least positive index `k` with `m | F(k)`.

The standard treatments tie the entry point tightly to the Fibonacci numbers and to
explicit computations with their values. The present work makes a structural observation:
the essential facts about the entry point depend on *one identity only*, the
**renormalization** (strong-divisibility) identity

```
gcd(u(m), u(n)) = u(gcd(m, n)).
```

This identity expresses a fractal self-similarity: the divisibility lattice of the values
`u(1), u(2), …` is a faithful scale-copy of the divisibility lattice of the indices
`1, 2, …`. We extract the entry point as the invariant this self-similarity induces, and we
prove the structural theory once, abstractly, for any sequence satisfying the identity. The
Fibonacci numbers and the base-`a` Mersenne/repunit numbers `aⁿ − 1` are then two
instantiations obtained at no further cost.

The conceptual headline is **fractal injectivity**: a fixed modulus can be a primitive
divisor of at most one term. The self-similar lattice forbids a modulus from making a
first appearance twice. We prove this in three short steps, each a consequence of the
renormalization identity and minimality.

### 1.1 Contributions

1. An abstract typeclass-free development of the entry-point invariant for strong
   divisibility sequences, with the structural theorems `entry_dvd`,
   `entry_eq_of_primitive`, `primitive_divisor_inj`, `primitive_divisor_distinct`.
2. Two concrete instantiations: Fibonacci (`fib_primitive_divisor_inj`) and base-`a`
   Mersenne/repunit (`mersenne_primitive_divisor_inj`).
3. For the Fibonacci model, the law of apparition, the primitive-prime-divisor
   characterization, and an existence theorem via reversible pigeonhole on the pair-map.
4. A methodological principle — *prove the property of the invariant, not the raw
   sequence* — that renders every proof a few lines.

---

## 2. Definitions

Throughout, `u : ℕ → ℕ` is an arbitrary sequence of natural numbers and `gcd` denotes the
greatest common divisor on `ℕ` (with the conventions `gcd(0, n) = n`).

**Definition 2.1 (Strong divisibility sequence / renormalization identity).**
A sequence `u` is a *strong divisibility sequence* if

```
∀ m n,  gcd(u(m), u(n)) = u(gcd(m, n)).                         (RN)
```

We refer to (RN) as the *renormalization identity*. It encodes the self-similarity of the
divisibility lattice under the map `n ↦ u(n)`.

**Definition 2.2 (Entry point / rank of apparition).**
The *entry point* of a modulus `m` in `u` is

```
entry(m) = the least k > 0 with m | u(k),   if such k exists;
entry(m) = 0,                               otherwise.
```

Formally `entry(m) = Nat.find h` when `h : ∃ k, 0 < k ∧ m | u(k)` holds, and `0`
otherwise. The fallback value `0` never triggers for the moduli of interest, because
existence is guaranteed (Theorem 6.1) for `u = F` and `m > 0`.

**Definition 2.3 (Primitive divisor).**
A modulus `m` is a *primitive divisor* of the index `n`, written `IsPrimitive(m, n)`, if

```
0 < n,   m | u(n),   and   ∀ k, 0 < k → k < n → ¬ (m | u(k)).
```

That is, `u(n)` is the first positive term that `m` divides — the *first appearance* of
`m` in the sequence.

---

## 3. Divisibility transports along the index lattice

The renormalization identity immediately yields the "downward" half of the lattice
correspondence: divisibility of indices forces divisibility of values.

**Lemma 3.1 (`dvd_of_dvd`).** *If `u` satisfies (RN) and `d | n`, then `u(d) | u(n)`.*

*Proof sketch.* Since `d | n`, we have `gcd(d, n) = d`, so by (RN),
`gcd(u(d), u(n)) = u(gcd(d, n)) = u(d)`. The equation `gcd(u(d), u(n)) = u(d)` is exactly
the statement `u(d) | u(n)` (a gcd equals its left argument iff the left divides the
right). ∎

This is the only place we need the "easy" direction; it is recorded for completeness and
reused implicitly in the concrete models.

---

## 4. The rank of apparition divides the index

The central structural fact requires *no primality* and *no fib-specific value*. It is a
pure consequence of (RN) and the minimality built into `entry`.

**Theorem 4.1 (`entry_dvd`).** *Let `u` satisfy (RN). If `0 < n` and `m | u(n)`, then
`entry(m) | n`.*

*Proof sketch.* Existence of an index of appearance holds (witnessed by `n`), so write
`e = entry(m) = Nat.find h`, which satisfies `0 < e` and `m | u(e)`. Because `m | u(n)`
and `m | u(e)`, we have `m | gcd(u(n), u(e))`, which by (RN) equals `u(gcd(n, e))`. Thus
`m | u(gcd(n, e))`, and `gcd(n, e) > 0` since `e > 0`. By minimality of `e = Nat.find h`,
no positive index smaller than `e` can be an index of appearance; hence
`e ≤ gcd(n, e)`. But `gcd(n, e) | e` gives `gcd(n, e) ≤ e`. Therefore `gcd(n, e) = e`,
i.e. `e | n`. ∎

The proof is the abstract distillate of the Fibonacci argument
(`FibonacciApparition.fib_dvd_iff_fibEntry_dvd`): pull two appearances into a single gcd
appearance, then let minimality collapse the gcd.

**Lemma 4.2 (`entry_pos_and_dvd`).** *If `0 < n` and `m | u(n)`, then `0 < entry(m)` and
`m | u(entry(m))`.* (Immediate from `Nat.find_spec`.)

---

## 5. Fractal injectivity: a modulus is born only once

**Lemma 5.1 (`entry_eq_of_primitive`).** *Let `u` satisfy (RN). If `IsPrimitive(m, n)`,
then `entry(m) = n`.*

*Proof sketch.* By Theorem 4.1, `entry(m) | n`, so `entry(m) ≤ n`. By Lemma 4.2,
`entry(m) > 0` and `m | u(entry(m))`. If `entry(m) < n`, the primitivity clause
`∀ k, 0 < k → k < n → ¬(m | u(k))` applied to `k = entry(m)` contradicts
`m | u(entry(m))`. Hence `entry(m) = n`. ∎

**Theorem 5.2 (Fractal injectivity, `primitive_divisor_inj`).** *Let `u` satisfy (RN). If
`IsPrimitive(m, n₁)` and `IsPrimitive(m, n₂)`, then `n₁ = n₂`.*

*Proof sketch.* By Lemma 5.1, `n₁ = entry(m) = n₂`. ∎

The brevity is the point: once primitivity is identified with the fiber `entry(m) = n`,
"at most one first appearance" is the well-definedness of a function.

**Corollary 5.3 (`primitive_divisor_distinct`).** *Let `u` satisfy (RN). If `n₁ ≠ n₂` and
`IsPrimitive(m, n₁)`, then `¬ IsPrimitive(m, n₂)`.*

*Proof sketch.* Contrapositive of Theorem 5.2. ∎

These four results — Theorem 4.1, Lemma 5.1, Theorem 5.2, Corollary 5.3 — constitute the
abstract core. None of them mentions Fibonacci numbers.

---

## 6. The Fibonacci model

The Fibonacci numbers satisfy (RN) by the classical identity of Lucas.

**Lemma 6.0 (`fib_strong_div`).** *`gcd(F(m), F(n)) = F(gcd(m, n))` for all `m, n`.*
(This is `Nat.fib_gcd`, restated.)

Consequently, every abstract result above specializes:

**Theorem 6.1 (`fib_primitive_divisor_inj`).** *A modulus `m` is a primitive divisor of at
most one Fibonacci number: if `IsPrimitive(F; m, n₁)` and `IsPrimitive(F; m, n₂)`, then
`n₁ = n₂`.* (Theorem 5.2 with `u = F`.)

We now record the Fibonacci-specific refinements that re-introduce the values.

### 6.1 The law of apparition

**Theorem 6.2 (Law of apparition, `fib_dvd_iff_fibEntry_dvd`).** *For `m > 0` and any `k`,*

```
m | F(k)   ⟺   entry(m) | k.
```

*Proof sketch.* (⇐) If `entry(m) | k`, then `F(entry(m)) | F(k)` by the divisibility
property of Fibonacci numbers (`Nat.fib_dvd`), and `m | F(entry(m))` by Lemma 4.2; chain
to get `m | F(k)`. (⇒) Contrapositive: suppose `entry(m) ∤ k`. Then
`g := gcd(k, entry(m))` is a positive index strictly below `entry(m)`, so by minimality
`m ∤ F(g)`. But if `m | F(k)` then `m | gcd(F(k), F(entry(m))) = F(g)` (by `Nat.fib_gcd`
and Lemma 4.2), a contradiction. ∎

The law of apparition collapses the infinite question "which Fibonacci numbers does `m`
divide?" into the single invariant `entry(m)`: the set of indices of appearance is exactly
the multiples of `entry(m)`.

### 6.2 Characterization of primitive prime divisors

**Theorem 6.3 (`prime_primitive_divisor_iff`).** *For a prime `p` and `n > 0`,*

```
( p | F(n)  ∧  ∀ k, 0 < k → k < n → ¬ p | F(k) )   ⟺   entry(p) = n.
```

*Proof sketch.* (⇒) `p | F(n)` gives `entry(p) ≤ n`; primitivity forbids
`entry(p) < n`; hence equality (this is Lemma 5.1 specialized, with the minimality bound
supplied by `fibEntry_le`). (⇐) `entry(p) = n` gives `p | F(n)` by Lemma 4.2, and the
no-earlier-appearance clause by minimality (`fibEntry_min`). ∎

This recasts Carmichael's primitive-divisor theorem as a statement about the level sets of
the entry-point function: `F(n)` has a primitive prime divisor iff some prime has entry
point exactly `n`.

**Corollary 6.4 (`primitive_divisor_unique_index`).** *Distinct indices `m ≠ n` have
disjoint sets of primitive prime divisors.* (Theorem 6.3 + Theorem 5.2.)

---

## 7. Existence: every prime divides some Fibonacci number

Fractal injectivity is an "at most one" statement. The complementary "at least one" — that
`entry(p)` exists at all — is proved by a reversible-dynamics argument, independent of any
heavy `native_decide` computation.

**Definition 7.1 (Pair-map).** For modulus `m`, set
`fibPair(m, n) = (F(n) mod m, F(n+1) mod m) ∈ (ℤ/mℤ)²`. The Fibonacci recurrence makes
`n ↦ fibPair(m, n)` a deterministic dynamical system on the finite torus `(ℤ/mℤ)²`.

**Lemma 7.2 (Backward determinism, `fibPair_back`).** *If
`fibPair(m, a+1) = fibPair(m, b+1)` then `fibPair(m, a) = fibPair(m, b)`.*

*Proof sketch.* The recurrence `F(n+2) = F(n) + F(n+1)` is invertible over `ℤ/mℤ`: from a
successor pair `(F(n+1), F(n+2))` one recovers `F(n) = F(n+2) − F(n+1)`. Equal successor
pairs therefore force equal predecessor pairs via subtraction in the ring. ∎

**Lemma 7.3 (Descent to the origin, `fibPair_descent`).** *If `i ≤ j` and
`fibPair(m, i) = fibPair(m, j)`, then `fibPair(m, 0) = fibPair(m, j − i)`.*

*Proof sketch.* Iterate Lemma 7.2 exactly `i` times, rewinding both orbits in lockstep
back to time `0`. ∎

**Theorem 7.4 (Existence, `exists_pos_dvd_fib`).** *For every `m > 0` there is `k > 0`
with `m | F(k)`.*

*Proof sketch.* The image `{ (F(n) mod m, F(n+1) mod m) : n ∈ ℕ }` lies in the finite set
`(ℤ/mℤ)²`, so by pigeonhole there exist `i < j` with
`fibPair(m, i) = fibPair(m, j)`. By Lemma 7.3, `fibPair(m, 0) = fibPair(m, j − i)`, whose
first coordinate gives `F(j − i) ≡ F(0) = 0 (mod m)`, i.e. `m | F(j − i)`, with
`j − i > 0`. ∎

Together with `entry`'s definition, Theorem 7.4 shows `entry(m) > 0` for all `m > 0`
(`fibEntry_pos`). Backward determinism upgrades the existence to a *pure periodicity*
statement: the orbit through `(0, 1)` returns exactly to its start, with period the
**Pisano period** `π(m)`, and `entry(m) | π(m)`.

**Corollary 7.5 (Infinitely many Fibonacci-dividing primes).** *Infinitely many distinct
primes divide some Fibonacci number.*

*Proof sketch.* Each prime divides some `F(k)` (Theorem 7.4), and by fractal injectivity
(Theorem 6.1) no prime is the primitive divisor of two distinct indices; since arbitrarily
large `F(n)` exist and each acquires primitive prime divisors, the set of such primes is
unbounded. ∎

---

## 8. The Mersenne / repunit model

The same theory transfers verbatim to the base-`a` sequence `u(n) = aⁿ − 1`.

**Lemma 8.1 (`mersenne_strong_div`).** *For any base `a`,
`gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1`.* (This is
`Nat.pow_sub_one_gcd_pow_sub_one`, restated.)

**Theorem 8.2 (`mersenne_primitive_divisor_inj`).** *A modulus is a primitive divisor of
at most one base-`a` number `aⁿ − 1`.* (Theorem 5.2 with `u(n) = aⁿ − 1`.)

For `a = 2` this is the entry-point statement underlying the study of Mersenne primes:
the prime 7 debuts at `2³ − 1 = 7`, then reappears (non-primitively) in
`2⁶ − 1 = 63`, `2⁹ − 1 = 511`, …, exactly at multiples of `entry(7) = 3`. The
abstraction makes clear that "Mersenne primitivity" and "Fibonacci primitivity" are the
*same theorem* in two divisibility sequences.

---

## 9. Multiplicativity of the entry point (Fibonacci)

The renormalization identity records the `gcd ↦ gcd` half of the lattice morphism. Its
dual is multiplicativity on coprime moduli.

**Theorem 9.1 (`fibEntry_mul_coprime`).** *For coprime `a, b > 0`,*

```
entry(a · b) = lcm(entry(a), entry(b)).
```

*Proof sketch.* (⊇) `a·b | F(k)` iff `a | F(k)` and `b | F(k)` (coprimality), iff
`entry(a) | k` and `entry(b) | k` (law of apparition, Theorem 6.2), iff
`lcm(entry(a), entry(b)) | k`. Taking the least such `k` gives both inequalities at once;
the least `k` divisible by `lcm(entry(a), entry(b))` is `lcm(entry(a), entry(b))` itself. ∎

This reduces all entry-point computation to the prime-power case: with multiplicativity in
hand, knowing `entry(pᵏ)` for each prime power determines `entry(n)` for all `n`.

---

## 10. Algorithms

Two computational routines accompany the theory; both avoid manipulating the astronomically
large sequence values directly.

**Algorithm A (Entry point by modular iteration).** To compute `entry(m)` for the
Fibonacci model, iterate the pair-map `(0, 1) → (1, 1) → …` modulo `m`, stopping at the
first index `k > 0` whose first coordinate is `0`. By Theorem 7.4 the loop terminates
within `m² + 1` steps. Complexity: `O(entry(m))` modular additions, each on numbers
`< m`. No big-integer arithmetic is needed.

**Algorithm B (Pisano period and divisibility certificate).** Iterate the pair-map until
it returns to `(0, 1)`; the number of steps is `π(m)`. By backward determinism the orbit is
purely periodic, so `entry(m) | π(m)`, giving a fast certificate that `entry(m) | k ⟺ m |
F(k)` for any queried `k` via `k mod entry(m)`.

---

## 11. Applications and discussion

- **Carmichael's theorem, reframed.** Theorem 6.3 shows `F(n)` has a primitive prime
  divisor iff some prime has entry point `n`. Fractal injectivity (Theorem 6.1) then makes
  the assignment "index `n` ↦ its primitive primes" a partial injection from primes to
  indices, the structural bridge from pointwise existence to global density statements.

- **Cross-domain reuse.** The Mersenne instantiation shows the value of abstracting over
  (RN): the same proof serves Fibonacci numbers, repunits `aⁿ − 1`, and — by the same
  template — any strong divisibility sequence (Lucas sequences with `gcd(P, Q) = 1`,
  `q`-integers, elliptic divisibility sequences).

- **Computation without giants.** Every quantity here is computed by modular iteration on
  `(ℤ/mℤ)²`. The exponential growth of `F(n)` and `aⁿ − 1` never enters the runtime.

- **Methodological lesson.** Comparing `u(m)` and `u(n)` directly is intractable. Factoring
  every question through the invariant `entry` turns the structural theorems into one-liners.
  *Find the invariant the self-similarity induces; prove injectivity and periodicity of the
  invariant, not of the raw sequence.*

---

## 11.5 Worked examples

To make the invariant concrete we record a small table of Fibonacci entry points, computed
by modular iteration on the pair-map (no large values formed):

| prime `p` | `entry(p)` | first appearance `F(entry(p))` |
|----------:|-----------:|-------------------------------:|
| 2  | 3  | F(3) = 2     |
| 3  | 4  | F(4) = 3     |
| 5  | 5  | F(5) = 5     |
| 7  | 8  | F(8) = 21    |
| 11 | 10 | F(10) = 55   |
| 13 | 7  | F(7) = 13    |
| 17 | 9  | F(9) = 34    |
| 19 | 18 | F(18) = 2584 |
| 23 | 24 | F(24) = 46368|

The law of apparition (Theorem 6.2) is visible directly: for `m = 7`, with `entry(7) = 8`,
the Fibonacci indices `k ≤ 40` with `7 | F(k)` are exactly `8, 16, 24, 32, 40` — the
multiples of `8`. For `m = 4`, with `entry(4) = 6`, they are `6, 12, 18, 24, 30, 36`.

Fractal injectivity (Theorem 6.1) is illustrated by listing primitive prime divisors index
by index. Reading `n = 3, 4, 5, 7, 8, 9, 10, 11, 13, 14, …` the primitive primes are
`2, 3, 5, 13, 7, 17, 11, 89, 233, 29, …`: each prime occurs in exactly one row, and once
a prime has appeared it never returns as a *primitive* divisor. (The only Fibonacci numbers
without a primitive prime divisor are `F(1) = F(2) = 1`, `F(6) = 8`, and `F(12) = 144`,
in accordance with Carmichael's theorem.)

Multiplicativity (Theorem 9.1) is checked on coprime pairs: `entry(6) = 12 =
lcm(entry(2), entry(3)) = lcm(3, 4)`; `entry(15) = 20 = lcm(entry(3), entry(5)) =
lcm(4, 5)`; `entry(63) = 24 = lcm(entry(7), entry(9)) = lcm(8, 12)`.

For the Mersenne model `u(n) = 2ⁿ − 1` the entry points are smaller: `entry(3) = 2`
(`2² − 1 = 3`), `entry(7) = 3` (`2³ − 1 = 7`), `entry(31) = 5` (`2⁵ − 1 = 31`). The prime
`7` is a primitive divisor of `2ⁿ − 1` only at `n = 3`, exactly as fractal injectivity
(Theorem 8.2) predicts.

## 11.6 Related work

The rank of apparition originates with Lucas (1878) and the primitive-divisor question with
Carmichael (1913), who proved that `F(n)` has a primitive prime divisor for all `n ≥ 13`;
Bilu, Hanrot and Voutier (2001) settled the analogous question for general Lucas and
Lehmer sequences. Strong divisibility sequences — sequences with
`gcd(u(m), u(n)) = u(gcd(m, n))` — are a classical theme (Ward, Hall), encompassing
Fibonacci and Lucas numbers, repunits and Mersenne numbers `aⁿ − 1`, resultant sequences,
and elliptic divisibility sequences. The present contribution is not a new theorem about
any single sequence but a *separation of concerns*: it shows that the entry-point
structural theory (the entry point divides the index; primitivity is a singleton fiber)
depends on the renormalization identity alone, so that the Fibonacci and Mersenne results
are two faces of one abstract statement. The reversible pair-map argument for existence is
a finite-dynamics packaging of the standard periodicity proof, with backward determinism
making the orbit purely periodic and hence the Pisano period exact.

## 12. Future work

1. **Prime-power refinement (lifting-the-exponent).** For an odd prime `p` with
   `e = entry(p)` and `v` the `p`-adic valuation of `u(e)`, conjecturally
   `entry(p^{k+1}) = p · entry(pᵏ)` once `k ≥ v`, and `= entry(pᵏ)` below `v`. With
   Theorem 9.1 this would yield a closed multiplicative formula for `entry(n)`. The failure
   case isolates the Wall–Sun–Sun phenomenon (`p²` dividing `F(e)`).

2. **Abstract multiplicativity.** Extend Theorem 9.1 to any strong divisibility sequence
   with total entry map: `entry(a·b) = lcm(entry(a), entry(b))` for coprime `a, b`.

3. **Quantitative Pisano bound.** Formalize `π(p)` as a `Nat.find`, prove pure periodicity
   from backward determinism (Lemma 7.2), and derive `entry(p) | π(p)` and `π(p) ≤ p² − 1`.

4. **General Lucas sequences via a typeclass.** Package (RN) as a `StrongDivisibilitySequence`
   typeclass and export the entire entry-point theory to Mersenne numbers, `q`-integers, and
   elliptic divisibility sequences from a single proof.

5. **Density of primitive-divisor indices.** Combine fractal injectivity with Carmichael
   existence to bound below the count of distinct Fibonacci-dividing primes up to `x`,
   conjecturally growing like `x / log φ` with `φ` the golden ratio.

---

## 13. Conclusion

By promoting the rank of apparition from proof-internal scaffolding to a first-class
invariant of strong divisibility sequences, we obtained the entire structural theory —
"the entry point divides the index," "primitivity pins the entry point," and "a modulus is
born only once" — from the single renormalization identity `gcd(u(m), u(n)) = u(gcd(m, n))`.
The Fibonacci and Mersenne models inherit the results for free, and the existence half is
secured by reversible pigeonhole on the finite pair-map. The unifying principle is to study
the invariant the self-similarity induces, where intractable comparisons of giant values
become trivial comparisons of small integers.
