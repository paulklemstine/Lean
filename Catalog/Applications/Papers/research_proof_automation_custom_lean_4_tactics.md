# Strong Divisibility Sequences as Lattice Homomorphisms: Finitary Meet/Join Laws and Coprimality Propagation

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Bridges (Number Theory ↔ Lattice Theory)

---

## Abstract

A *strong divisibility sequence* is a sequence `a : ℕ → ℕ` satisfying `a(0) = 0` and the meet law
`gcd(a(m), a(n)) = a(gcd(m, n))`. This single identity is the structure shared by the Fibonacci
numbers, the Mersenne/repunit sequences `bⁿ − 1`, and the identity sequence. We develop the
*order-theoretic* side of these axioms: a strong divisibility sequence is precisely an
**inf-homomorphism and sup-semihomomorphism of the divisibility lattice `(ℕ, ∣, gcd, lcm)`**. We
establish (i) the binary join sub-law `lcm(a(m), a(n)) ∣ a(lcm(m, n))`, derived purely from
divisibility monotonicity; (ii) coprimality propagation, governed by the single boundary condition
`a(1) = 1`, including the collapse `gcd(a(m), a(n)) = a(1)` for coprime indices; (iii) the finitary
generalizations of both laws — the meet law as an exact equality over arbitrary finite families and
the join law as a divisibility; and (iv) a product law for pairwise-coprime indices. The recurring
phenomenon is a structural asymmetry: meet is preserved *exactly*, while join is preserved only *up
to divisibility*. Specializing to the `fibSDS` and `mersenneSDS` instances yields cross-domain
corollaries, including coprimality of Fibonacci numbers at coprime indices and the residual identity
`gcd(bᵐ − 1, bⁿ − 1) = b − 1 = a(1)` for coprime `m, n`. All results are fully machine-verified.

---

## 1. Introduction

### 1.1 Motivation

Two classical families of integer sequences exhibit a striking gcd-transport property. The Fibonacci
numbers `Fₙ` satisfy `gcd(Fₘ, Fₙ) = F_gcd(m,n)`, and the Mersenne numbers satisfy
`gcd(bᵐ − 1, bⁿ − 1) = b^gcd(m,n) − 1`. Historically, each family carried its own theory of *ranks of
apparition* (entry points) and *primitive divisors* — for Fibonacci through Carmichael's theorem, for
`bⁿ − 1` through Zsygmondy's theorem. These theories look superficially different but share a common
algebraic backbone.

The abstraction that captures this backbone is the **strong divisibility sequence**. The key
observation of the present work is that the defining axiom is not merely an arithmetic identity but a
*lattice-homomorphism property*. The natural numbers under divisibility form a lattice with meet
`gcd` and join `lcm`; the strong-divisibility axiom states that the sequence `a` preserves the meet.
This reframing immediately suggests asking whether `a` also preserves the join, whether it preserves
these operations over finite families, and how arithmetic notions like coprimality interact with the
lattice top elements.

### 1.2 Contributions

We answer these questions completely.

1. **Binary join sub-law** (`lcm_dvd_index`): `lcm(a(m), a(n)) ∣ a(lcm(m, n))`, derived from
   monotonicity alone.
2. **Coprimality collapse and propagation** (`gcd_indices_coprime`, `coprime_of_coprime`): coprime
   indices force `gcd(a(m), a(n)) = a(1)`, and coprime values exactly when `a(1) = 1`.
3. **Finitary meet law** (`finset_gcd_eq`): exact equality `Finset.gcd t (a ∘ g) = a(Finset.gcd t g)`.
4. **Finitary join sub-law** (`finset_lcm_dvd`): divisibility `Finset.lcm t (a ∘ g) ∣ a(Finset.lcm t g)`.
5. **Pairwise coprimality and product law** (`pairwise_coprime`, `prod_dvd_index`): if `a(1) = 1`,
   pairwise-coprime indices give pairwise-coprime values and `∏ a(g(i)) ∣ a(∏ g(i))`.
6. **Cross-domain corollaries** for Fibonacci (`fib_finset_gcd`, `fib_finset_lcm_dvd`,
   `fib_coprime_of_coprime`, `fib_lcm_dvd`, `fib_prod_dvd`) and Mersenne (`mersenne_gcd_coprime`).

The unifying theme is the **meet/join asymmetry**: an exact equality for gcd, a one-directional
divisibility for lcm, visible uniformly at every arity.

---

## 2. Definitions and basic structure

### Definition 2.1 (Strong divisibility sequence)

A **strong divisibility sequence** is a structure consisting of a function `a : ℕ → ℕ` together with
two axioms:

- **(Z)** `a(0) = 0`;
- **(M)** for all `m, n ∈ ℕ`, `gcd(a(m), a(n)) = a(gcd(m, n))`.

We write `s.a` for the underlying function of `s : StrongDivSeq`.

### Definition 2.2 (Divisibility lattice)

The set `ℕ` ordered by `x ⪯ y :⟺ x ∣ y` is a lattice: the meet (greatest lower bound) of `x` and `y`
is `gcd(x, y)`, the join (least upper bound) is `lcm(x, y)`, the bottom element is `1` (which divides
everything), and the top element is `0` (which is divisible by everything). Axiom (M) states that `a`
is a *meet-homomorphism*: it commutes with `gcd`.

### Lemma 2.3 (Divisibility monotonicity, `dvd_of_dvd`)

If `m ∣ n` then `a(m) ∣ a(n)`.

*Proof sketch.* If `m ∣ n` then `gcd(m, n) = m`, so by (M),
`gcd(a(m), a(n)) = a(gcd(m, n)) = a(m)`. Since `gcd(a(m), a(n)) ∣ a(n)` always, we conclude
`a(m) ∣ a(n)`. ∎

Lemma 2.3 is the workhorse: it says `a` is order-preserving with respect to the divisibility order. It
is the *only* tool needed for every join-direction result below.

### Lemma 2.4 (Meet bridge, `dvd_gcd_iff`)

For all `d, m, n`: `d ∣ a(gcd(m, n)) ⟺ d ∣ a(m) ∧ d ∣ a(n)`.

*Proof sketch.* Rewrite `a(gcd(m, n)) = gcd(a(m), a(n))` by (M); then apply the standard equivalence
`d ∣ gcd(x, y) ⟺ d ∣ x ∧ d ∣ y`. ∎

---

## 3. The binary lattice laws

### 3.1 The meet law specialized to coprime indices

### Theorem 3.1 (Coprime collapse, `gcd_indices_coprime`)

If `gcd(m, n) = 1` then `gcd(a(m), a(n)) = a(1)`.

*Proof sketch.* By (M), `gcd(a(m), a(n)) = a(gcd(m, n))`; substitute `gcd(m, n) = 1`. ∎

The content of Theorem 3.1 is conceptual: coprime indices are exactly the pairs whose meet is the
bottom element `1` of the index lattice, and the meet law sends that bottom element to the fixed value
`a(1)`. Whether this value is itself the bottom element `1` of the *value* lattice is the crux of
coprimality propagation.

### Theorem 3.2 (Coprimality propagation, `coprime_of_coprime`)

If `a(1) = 1` and `gcd(m, n) = 1`, then `gcd(a(m), a(n)) = 1`; i.e. `a(m)` and `a(n)` are coprime.

*Proof sketch.* By Theorem 3.1, `gcd(a(m), a(n)) = a(1)`, and `a(1) = 1` by hypothesis. ∎

The hypothesis `a(1) = 1` is the requirement that the bottom of the index lattice map to the bottom of
the value lattice. Fibonacci satisfies it (`F₁ = 1`); the Mersenne sequence does not in general
(`b¹ − 1 = b − 1`), which precisely explains the nonzero residual in §6.

### 3.2 The join sub-law

### Theorem 3.3 (Binary join sub-law, `lcm_dvd_index`)

For all `m, n`: `lcm(a(m), a(n)) ∣ a(lcm(m, n))`.

*Proof sketch.* By Lemma 2.3 applied to the two divisibilities `m ∣ lcm(m, n)` and `n ∣ lcm(m, n)`,
we get `a(m) ∣ a(lcm(m, n))` and `a(n) ∣ a(lcm(m, n))`. The defining universal property of `lcm`
(`lcm(x, y) ∣ z ⟺ x ∣ z ∧ y ∣ z`) then yields `lcm(a(m), a(n)) ∣ a(lcm(m, n))`. ∎

Theorem 3.3 is the order-theoretic heart of the asymmetry. Note what the proof does *not* use: it
never invokes axiom (M) directly, only its monotonicity consequence (Lemma 2.3). This is why join is
preserved merely up to divisibility: monotonicity places `lcm(a(m), a(n))` below `a(lcm(m, n))`, but
nothing forces equality. Indeed equality fails: for Fibonacci, `lcm(F₄, F₆) = lcm(3, 8) = 24` while
`F_lcm(4,6) = F₁₂ = 144`, and `24 ∣ 144` strictly.

---

## 4. Finitary lattice laws

We promote both binary laws to arbitrary finite families indexed by a `Finset t` with a function
`g : ι → ℕ`, using `Finset.gcd` and `Finset.lcm` (the iterated `GCDMonoid` operations, which coincide
on ℕ with the iterated `Nat.gcd`/`Nat.lcm` after the normalization bridge).

### Theorem 4.1 (Finitary meet law, `finset_gcd_eq`)

For any finite index set `t` and `g : ι → ℕ`,
```
Finset.gcd t (fun i ↦ a(g(i)))  =  a( Finset.gcd t g ).
```

*Proof sketch.* Induction on `t` via `Finset.induction`.

- **Empty case.** `Finset.gcd ∅ f = 0` for any `f`, and the right side is `a(Finset.gcd ∅ g) = a(0) = 0`
  by axiom (Z). Both sides equal `0`.
- **Insert step.** For `t' = insert c t` with `c ∉ t`, expand both sides with `Finset.gcd_insert`:
  the left becomes `gcd(a(g(c)), Finset.gcd t (a ∘ g))`, which by the induction hypothesis equals
  `gcd(a(g(c)), a(Finset.gcd t g))`. After transporting `GCDMonoid.gcd` to `Nat.gcd` via the
  normalization bridge, axiom (M) rewrites this to `a(gcd(g(c), Finset.gcd t g)) = a(Finset.gcd t' g)`.

The induction interleaves `Finset.gcd_insert` with the `gcd = Nat.gcd` coercion at each step. ∎

### Theorem 4.2 (Finitary join sub-law, `finset_lcm_dvd`)

For any finite index set `t` and `g : ι → ℕ`,
```
Finset.lcm t (fun i ↦ a(g(i)))  ∣  a( Finset.lcm t g ).
```

*Proof sketch.* Induction on `t`.

- **Empty case.** `Finset.lcm ∅ f = 1`, which divides everything; in particular `1 ∣ a(Finset.lcm ∅ g)`.
- **Insert step.** For `t' = insert c t`, `Finset.lcm_insert` gives the left side as
  `lcm(a(g(c)), Finset.lcm t (a ∘ g))`. By `lcm_dvd` it suffices to show each argument divides
  `a(Finset.lcm t' g)`. The first follows from Lemma 2.3 applied to `g(c) ∣ Finset.lcm t' g`. The
  second follows by chaining the induction hypothesis with Lemma 2.3 applied to
  `Finset.lcm t g ∣ Finset.lcm t' g`. ∎

The two boundary cases reproduce the lattice picture exactly: the empty meet matches `a(0) = 0` (the
gcd-top of ℕ), and the empty join is the lcm-unit `1`, whose image divides everything as the sub-law
demands.

---

## 5. Pairwise coprimality and the product law

### Theorem 5.1 (Pairwise coprimality propagation, `pairwise_coprime`)

Suppose `a(1) = 1`. If the indices `{g(i) : i ∈ t}` are pairwise coprime, then the values
`{a(g(i)) : i ∈ t}` are pairwise coprime.

*Proof sketch.* For distinct `i, j ∈ t`, `gcd(g(i), g(j)) = 1` by hypothesis, so Theorem 3.2 gives
`gcd(a(g(i)), a(g(j))) = 1`. ∎

### Theorem 5.2 (Coprime-index product law, `prod_dvd_index`)

Suppose `a(1) = 1`. If the indices `{g(i) : i ∈ t}` are pairwise coprime, then
```
∏_{i ∈ t} a(g(i))  ∣  a( ∏_{i ∈ t} g(i) ).
```

*Proof sketch.* By Theorem 5.1 the factors `a(g(i))` are pairwise coprime. In a decomposition monoid
such as ℕ, pairwise coprimality (routed through `IsRelPrime` via `Nat.coprime_iff_isRelPrime`)
upgrades a family of divisibilities into a divisibility of the product: it suffices that each
`a(g(i)) ∣ a(∏ g)`. Each such divisibility follows from Lemma 2.3 applied to `g(i) ∣ ∏ g`. The
product-of-coprimes lemma (`Finset.prod_dvd_of_isRelPrime`) then assembles the factors. ∎

**Remark (subtlety).** The ring-theoretic notion `IsCoprime` is strictly stronger than `Nat.Coprime`
on ℕ. The product law must therefore be routed through `IsRelPrime`, exploiting that ℕ is a
`DecompositionMonoid`. This is a genuine formalization subtlety rather than a mathematical one.

---

## 6. Cross-domain corollaries

### 6.1 Instances

- **Fibonacci** (`fibSDS`): `a = Nat.fib`, with (Z) `fib 0 = 0` and (M) `Nat.fib_gcd`. Crucially
  `F₁ = 1`, so the `a(1) = 1` hypothesis holds and all coprimality results apply.
- **Mersenne/repunit** (`mersenneSDS b`): `a(n) = bⁿ − 1`, with (M) given by
  `Nat.pow_sub_one_gcd_pow_sub_one`. Here `a(1) = b − 1`, so coprimality of values fails in general.
- **Identity** (`idSDS`): `a(n) = n`, the trivial strong divisibility sequence.

### 6.2 Fibonacci corollaries

### Corollary 6.1 (`fib_coprime_of_coprime`)
If `gcd(m, n) = 1` then `gcd(Fₘ, Fₙ) = 1`.
*From Theorem 3.2 with `fibSDS` and `F₁ = 1`.*

### Corollary 6.2 (`fib_lcm_dvd`)
`lcm(Fₘ, Fₙ) ∣ F_lcm(m,n)`.
*From Theorem 3.3 with `fibSDS`.*

### Corollary 6.3 (`fib_finset_gcd`)
`Finset.gcd t (fun i ↦ F_{g(i)}) = F_{Finset.gcd t g}`.
*From Theorem 4.1 with `fibSDS`.*

### Corollary 6.4 (`fib_finset_lcm_dvd`)
`Finset.lcm t (fun i ↦ F_{g(i)}) ∣ F_{Finset.lcm t g}`.
*From Theorem 4.2 with `fibSDS`.*

### Corollary 6.5 (`fib_prod_dvd`)
For pairwise-coprime indices, `∏ F_{g(i)} ∣ F_{∏ g(i)}`.
*From Theorem 5.2 with `fibSDS`.*

### 6.3 Mersenne corollary

### Corollary 6.6 (`mersenne_gcd_coprime`)
If `gcd(m, n) = 1` then `gcd(bᵐ − 1, bⁿ − 1) = b − 1`.

*Proof sketch.* Theorem 3.1 applied to `mersenneSDS b` gives `gcd(bᵐ − 1, bⁿ − 1) = a(1) = b − 1`.
The residual `b − 1` is precisely the image of the lattice bottom `1`, explaining why coprimality of
values fails for `b > 2`. ∎

This corollary crystallizes the role of the `a(1) = 1` hypothesis: the residual that obstructs
coprimality propagation is *always* `a(1)`, and the framework computes it uniformly.

---

## 7. Algorithms

The framework is constructive enough to drive direct numerical verification. Two algorithms are
central.

### Algorithm 7.1 (Finitary meet/join verifier)

Given a strong divisibility sequence `a` (as a callable), a finite family of indices `g₁, ..., gₖ`,
verify both finitary laws numerically:
- compute `G = gcd(g₁, ..., gₖ)` and check `gcd(a(g₁), ..., a(gₖ)) = a(G)`;
- compute `L = lcm(g₁, ..., gₖ)` and check `lcm(a(g₁), ..., a(gₖ)) ∣ a(L)`.

Complexity: with `k` indices and values bounded by `M`, the gcd/lcm folds are `O(k log M)` integer
operations; evaluating `a` dominates if `a` is expensive (e.g. `O(n)` additions for `Fₙ`).

### Algorithm 7.2 (Coprime-index product checker)

Given `a` with `a(1) = 1` and pairwise-coprime indices, verify `∏ a(g(i)) ∣ a(∏ g(i))` and report the
cofactor `a(∏ g(i)) / ∏ a(g(i))`. The pairwise-coprimality precondition is checked in `O(k²)` gcd
computations.

---

## 8. Applications

- **Unified primitive-divisor theory.** Carmichael's theorem (Fibonacci) and Zsygmondy's theorem
  (`bⁿ − 1`) share the entry-point machinery; the lattice laws here describe the *order structure* on
  which that machinery sits, providing a uniform language for both.
- **Fast coprimality certificates.** Corollary 6.1 gives an `O(log)` certificate that `Fₘ, Fₙ` are
  coprime: just verify `gcd(m, n) = 1`. No factoring of the (exponentially large) Fibonacci numbers is
  needed.
- **Divisor lattices of recurrence sequences.** The finitary laws describe how divisors of values at
  composite indices assemble from divisors at the index lattice, relevant to sieve constructions and
  to the design of recurrence-based pseudorandom or hashing primitives.

---

## 9. Discussion

The central phenomenon is the **meet/join asymmetry**: `a` is an exact inf-homomorphism but only a
sup-*semi*-homomorphism of `(ℕ, ∣)`. This asymmetry is not a defect of the proof technique; it is a
structural feature, traceable to the fact that the meet law is *axiomatic* while the join law is a
*consequence of monotonicity*. Monotonicity can only place the join of images below the image of the
join. The gap between `lcm(a(m), a(n))` and `a(lcm(m, n))` measures the failure of `a` to be a full
lattice homomorphism.

A second organizing principle is the role of the lattice **bottom element** `1`. Coprimality is the
statement that two indices meet at `1`; the meet law sends that meet to `a(1)`; and coprimality
*propagates* exactly when `a(1) = 1`. This single equation cleanly separates the well-behaved
Fibonacci case from the residual-bearing Mersenne case, and the residual is always exactly `a(1)`.

---

## 10. Future directions

This cycle established the lattice-theoretic side of the strong-divisibility-sequence programme,
complementing the primitive-divisor / entry-point theory. Several precise conjectures follow.

1. **Multiplicative-order bridge.** For `b ≥ 2` and a prime `p ∤ b`, the Mersenne entry point should
   equal the multiplicative order: `entryPoint p = orderOf (b : (ZMod p)ˣ)`, bridging the abstract
   entry point to a concrete group invariant.
2. **Lucas U-sequences are strong divisibility sequences.** For coprime `P, Q`, the Lucas sequence
   `Uₙ(P, Q)` satisfies `gcd(Uₘ, Uₙ) = U_gcd(m,n)` and `U₁ = 1`, hence is a strong divisibility
   sequence with `a(1) = 1`. Every theorem here would then hold for Pell numbers (`P=2, Q=−1`),
   Jacobsthal numbers (`P=1, Q=−2`), and the whole Lucas family in one stroke.
3. **Sharp join law.** The join sub-law `lcm(a(m), a(n)) ∣ a(lcm(m, n))` should be an *equality* iff
   the indices are comparable under `∣` (or `a` is multiplicatively rigid). For Fibonacci,
   `lcm(Fₘ, Fₙ) = F_lcm(m,n)` iff `m ∣ n` or `n ∣ m` — quantifying exactly how far `a` is from a
   sup-homomorphism.
4. **Coprime-index product equality up to residual.** Strengthen the product law: when `a(1) = 1` and
   indices are pairwise coprime, `∏ a(g(i))` should equal the relevant "primitive-part" radical of
   `a(∏ g(i))`, refining the divisibility to an exact factorization.

---

## 11. Conclusion

Stripped of arithmetic incident, a strong divisibility sequence is a single morphism of the
divisibility lattice: exact on meets, sub-homomorphic on joins. From the two axioms `a(0) = 0` and
`gcd(a(m), a(n)) = a(gcd(m, n))` flow monotonicity, an exact finitary meet law, a divides-only
finitary join law, coprimality propagation gated by `a(1) = 1`, and a coprime-index product law — all
holding uniformly for Fibonacci, Mersenne, repunit, and identity sequences. The bridge converts
sequence-specific number theory into universal order theory, and reveals that the celebrated
gcd-transport property of the Fibonacci numbers is, at bottom, a statement about lattices.
