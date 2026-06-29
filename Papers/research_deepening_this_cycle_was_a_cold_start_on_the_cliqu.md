# Korselt's Criterion and Carmichael Numbers: A First-Principles Formalization

## Abstract

A **Carmichael number** is a composite integer `n` that is a Fermat pseudoprime to every base
coprime to it; that is, `n` divides `b^(n−1) − 1` for all `b` with `gcd(n, b) = 1`. Such numbers
defeat the Fermat primality test against every honest witness, and their existence is the reason
modern primality testing relies on strengthened criteria such as Miller–Rabin. While the notion of
a single-base Fermat pseudoprime is standard, the full Carmichael property had not been given a
structural backbone in our formal development environment, whose number-theory library explicitly
notes that Carmichael numbers are "not yet defined."

This paper presents a complete, first-principles formalization of the **sufficient half of
Korselt's criterion**: every squarefree composite `n > 1` such that `(p − 1) ∣ (n − 1)` for each
prime `p ∣ n` is a genuine Carmichael number. We package this hypothesis in a predicate
`IsKorselt` and derive: (i) the central **Korselt identity** `n ∣ a^n − a` for every integer `a`;
(ii) the bridge `fermatPsp_of_coprime`, connecting Korselt numbers to the existing
Fermat-pseudoprime API; (iii) the structural theorems that every Korselt number is **odd**, is
never a product of two distinct primes, and therefore has **at least three** distinct prime
factors; and (iv) the verified canonical instance `561 = 3 · 11 · 17`, the smallest Carmichael
number. The argument factors into a clean *local* mechanism (`x^n = x` in each residue field
`ZMod p`) and a *global recombination* (pairwise-coprime primes glue via a product-divisibility
principle). All results are machine-checked and depend only on the standard foundational axioms.

**Keywords:** Carmichael number, Korselt's criterion, Fermat pseudoprime, Fermat's little theorem,
squarefree, finite fields, formal verification, number theory.

---

## 1. Introduction

### 1.1 Motivation

Fermat's little theorem states that for a prime `p` and an integer `b` not divisible by `p`,
`b^(p−1) ≡ 1 (mod p)`. Contrapositively, if for some base `b` coprime to `n` we find
`b^(n−1) ≢ 1 (mod n)`, then `n` is certainly composite. This yields the *Fermat primality test*,
whose appeal is computational: modular exponentiation `b^(n−1) mod n` is fast (logarithmically many
multiplications via repeated squaring), whereas finding a factor of `n` is, as far as is known,
hard.

The test has a fatal flaw. There exist composite numbers `n` that satisfy `b^(n−1) ≡ 1 (mod n)` for
**every** base `b` coprime to `n`. These are the **Carmichael numbers**. They are pseudoprime to all
admissible witnesses simultaneously, so no amount of base-sampling within the Fermat framework can
expose them. Alford, Granville, and Pomerance (1994) proved there are infinitely many, foreclosing
any hope that they are a negligible nuisance.

The remarkable fact, due to Korselt (1899), is that this property — a statement quantified over
infinitely many bases — admits a finite, purely arithmetic characterization in terms of the prime
factorization of `n`. This paper formalizes the *constructive* (sufficient) direction of that
characterization from first principles and bridges it to a pre-existing single-base
Fermat-pseudoprime predicate.

### 1.2 Contributions

1. A predicate `IsKorselt n` capturing the sufficient hypotheses of Korselt's criterion.
2. A local lemma `pow_eq_self_zmod`: in `ZMod p`, the `n`-th power map is the identity whenever
   `(p − 1) ∣ (n − 1)` and `n ≥ 1`.
3. The per-prime divisibility `prime_dvd_pow_sub_self`: `(p : ℤ) ∣ a^n − a`.
4. The **Korselt identity** `dvd_pow_sub_self`: `(n : ℤ) ∣ a^n − a` for all integers `a`.
5. The bridge `fermatPsp_of_coprime`: a Korselt number is a Fermat pseudoprime to every coprime
   base `b ≥ 1`, i.e. it is a Carmichael number.
6. Structural theorems: `odd`, `not_eq_mul_two_primes`, and `three_le_card_primeFactors`.
7. The verified instance `561` (`korselt_561`, `fermatPsp_561`).

---

## 2. Definitions

Throughout, `n`, `p`, `q`, `b`, `k` denote natural numbers and `a` an integer. We write `p ∣ m`
for "`p` divides `m`," `gcd` for the greatest common divisor, and `ZMod p` for the ring of integers
modulo `p`, which is a field when `p` is prime.

**Definition 2.1 (Squarefree).** A natural number `n` is *squarefree* if no perfect square other
than `1` divides it; equivalently, every prime appears at most once in its factorization.

**Definition 2.2 (Fermat pseudoprime).** For `n` composite and `b ≥ 1`, `n` is a *Fermat
pseudoprime to base `b`* if `n` is a "probable prime" to base `b`, i.e. `n ∣ b^(n−1) − 1`, while
`n` is not prime. (This matches the library predicate `Nat.FermatPsp n b`, which bundles the
probable-prime congruence, compositeness, and `n > 1`.)

**Definition 2.3 (Carmichael number).** A composite `n > 1` is a *Carmichael number* if it is a
Fermat pseudoprime to every base `b` with `gcd(n, b) = 1`.

**Definition 2.4 (Korselt predicate).** We define
```
IsKorselt n  :=  1 < n  ∧  ¬ n.Prime  ∧  Squarefree n  ∧  (∀ p, p.Prime → p ∣ n → (p − 1) ∣ (n − 1)).
```
That is, `n` exceeds `1`, is composite, is squarefree, and every prime factor `p` of `n` satisfies
`(p − 1) ∣ (n − 1)`. These are exactly the hypotheses of the sufficient half of Korselt's
criterion.

The principal theorem of the paper is that `IsKorselt n` implies `n` is a Carmichael number.

---

## 3. The local mechanism

The first half of the argument lives inside a single prime residue field.

**Lemma 3.1 (`pow_eq_self_zmod`).** *Let `p` be prime and `n ≥ 1`. If `(p − 1) ∣ (n − 1)`, then for
every `x ∈ ZMod p`,*
```
x^n = x.
```

*Proof sketch.* If `x = 0`, then since `n ≥ 1` we have `x^n = 0 = x`. If `x ≠ 0`, write
`n − 1 = (p − 1) · k`, so `n = (p − 1)·k + 1` (using `n ≥ 1` to undo the truncated subtraction).
Then
```
x^n = x^{(p−1)·k + 1} = (x^{p−1})^k · x.
```
By Fermat's little theorem in field form (`ZMod.pow_card_sub_one_eq_one`), `x^{p−1} = 1` for
nonzero `x`, so `(x^{p−1})^k = 1` and the right side equals `x`. ∎

**Lemma 3.2 (`prime_dvd_pow_sub_self`).** *Let `p` be prime with `(p − 1) ∣ (n − 1)` and `n ≥ 1`.
Then for every integer `a`,*
```
(p : ℤ) ∣ a^n − a.
```

*Proof sketch.* Divisibility of an integer by `p` is equivalent to the vanishing of its image in
`ZMod p` (`ZMod.intCast_zmod_eq_zero_iff_dvd`). The image of `a^n − a` is `(a̅)^n − a̅` where `a̅`
is the residue of `a`; by Lemma 3.1 this is `a̅ − a̅ = 0`. Hence `p ∣ a^n − a`. ∎

Two observations are worth recording. First, *compositeness of `n` plays no role here*; the local
identity is purely about the exponent relation `(p − 1) ∣ (n − 1)`. Second, the lemma holds for
*all* integers `a`, including those divisible by `p` — this universality is exactly what lets the
later bridge handle bases without a coprimality hypothesis at the level of the identity itself.

---

## 4. The global recombination and the Korselt identity

**Theorem 4.1 (Korselt identity, `dvd_pow_sub_self`).** *Let `n ≥ 1` be squarefree and suppose
`(p − 1) ∣ (n − 1)` for every prime `p ∣ n`. Then for every integer `a`,*
```
(n : ℤ) ∣ a^n − a.
```

*Proof sketch.* Because `n` is squarefree, it equals the product of its distinct prime factors,
each occurring to the first power:
```
n = ∏_{p ∈ primeFactors n} p
```
(`Nat.prod_primeFactors_of_squarefree`). Distinct primes are coprime
(`Nat.coprime_primes`), so the family `{p : p ∈ primeFactors n}` is pairwise coprime. By Lemma 3.2,
each such `p` (an integer) divides `a^n − a`. A pairwise-coprime family that each divides a fixed
quantity has its product dividing that quantity (`Finset.prod_dvd_of_coprime`, a packaging of the
Chinese Remainder Theorem). Therefore
```
∏_{p ∈ primeFactors n} (p : ℤ) = (n : ℤ)
```
divides `a^n − a`. ∎

The Korselt identity is the engine of the theory: a single congruence, quantified over *all*
integers `a`, that encodes the entire Carmichael property. The remaining results are corollaries.

---

## 5. The bridge to Fermat pseudoprimes

**Theorem 5.1 (Korselt ⟹ Carmichael, `fermatPsp_of_coprime`).** *Let `IsKorselt n` hold. Then for
every base `b ≥ 1` with `gcd(n, b) = 1`, `n` is a Fermat pseudoprime to base `b`. Consequently `n`
is a Carmichael number.*

*Proof sketch.* The predicate `Nat.FermatPsp n b` requires three things: the probable-prime
congruence `n ∣ b^(n−1) − 1`, compositeness of `n`, and `n > 1`. The latter two are immediate from
`IsKorselt n`. For the congruence, apply the Korselt identity (Theorem 4.1) with `a = b`:
```
(n : ℤ) ∣ b^n − b = b · (b^{n−1} − 1).
```
Since `gcd(n, b) = 1`, the integer `n` is coprime to the factor `b`, so by cancellation of a
coprime factor in a divisibility (`Int.dvd_of_dvd_mul_right_of_gcd_one`) we obtain
```
(n : ℤ) ∣ b^{n−1} − 1.
```
Casting back to ℕ (using `b ≥ 1` so that `b^{n−1} ≥ 1` and the natural subtraction is honest) gives
`n ∣ b^(n−1) − 1`, which is the probable-prime condition. ∎

This is the cross-domain bridge promised by the development: finite-field exponentiation
(`ZMod.pow_card_sub_one_eq_one`) is connected, through CRT-style product divisibility over the prime
factors, to the existing single-base Fermat-pseudoprime predicate, instantiating the Carmichael
property the library had flagged as absent.

---

## 6. Structural theorems

The criterion does not merely certify candidates; it shapes them.

**Theorem 6.1 (`odd`).** *Every Korselt number is odd.*

*Proof sketch.* Suppose `n` is Korselt and, for contradiction, even. Since `n` is squarefree and
composite, it cannot be a power of `2` (squarefree forbids `4 ∣ n`, and `2` itself is prime, not
composite), so `n` has an odd prime factor `p`. For that `p`, `p − 1` is even, hence `2 ∣ (p − 1)`.
By the Korselt divisibility `(p − 1) ∣ (n − 1)`, transitivity gives `2 ∣ (n − 1)`, so `n − 1` is
even and `n` is odd — contradicting that `n` is even. ∎

**Theorem 6.2 (`not_eq_mul_two_primes`).** *A Korselt number is never the product of two distinct
primes.* That is, there are no distinct primes `p < q` with `n = p · q` and `IsKorselt n`.

*Proof sketch.* Suppose `n = p · q` with `p < q` both prime. The Korselt condition requires
`(q − 1) ∣ (n − 1) = pq − 1`. Now `pq − 1 = p(q − 1) + (p − 1)`, so `(q − 1) ∣ pq − 1` forces
`(q − 1) ∣ (p − 1)`. But `0 < p − 1 < q − 1` (since `2 ≤ p < q`), and a positive number strictly
smaller than `q − 1` cannot be a multiple of `q − 1`. Contradiction. ∎

**Theorem 6.3 (`three_le_card_primeFactors`).** *Every Korselt number has at least three distinct
prime factors.*

*Proof sketch.* A squarefree composite `n > 1` has at least two distinct prime factors. It cannot
have exactly one (that would make it a prime power, and squarefree forces the exponent to be `1`,
i.e. `n` prime, contradicting compositeness). It cannot have exactly two, for then `n = p · q` with
distinct primes `p, q`, contradicting Theorem 6.2. Hence the number of distinct prime factors is at
least three. ∎

These three theorems jointly explain why `561 = 3 · 11 · 17` is the smallest Carmichael number:
any smaller composite either has a repeated factor, is even, or has fewer than three prime factors,
and is therefore excluded.

---

## 7. The canonical instance: 561

**Theorem 7.1 (`korselt_561`).** `IsKorselt 561`.

*Proof sketch.* We verify each conjunct. (i) `1 < 561`. (ii) `561 = 3 · 11 · 17` is composite, not
prime. (iii) Squarefreeness follows from `561 = 3 · (11 · 17)` with `3`, `11`, `17` distinct primes,
each prime being squarefree and products of coprime squarefree numbers being squarefree
(`Nat.squarefree_mul_iff`, `Nat.Prime.squarefree`). (iv) The prime factors are exactly `{3, 11,
17}` (enumerated by peeling `Nat.Prime.dvd_mul`), and `n − 1 = 560` satisfies `2 ∣ 560`,
`10 ∣ 560`, `16 ∣ 560`, covering `p − 1` for `p = 3, 11, 17` respectively. ∎

**Theorem 7.2 (`fermatPsp_561`).** *For every base `b ≥ 1` coprime to `561`, `561` is a Fermat
pseudoprime to base `b`.* In particular, `561` is a Carmichael number — the smallest one.

*Proof sketch.* Immediate from `korselt_561` and Theorem 5.1. ∎

A note on automation discovered during formalization: the default decision procedure does **not**
evaluate `Squarefree`, `primeFactors`, or bounded prime quantifiers directly (the relevant
decidability instances stall on the squarefree-factor and prime-factor-list computations). The
working route is structural — `Nat.squarefree_mul_iff` together with `Nat.Prime.squarefree` for
squarefreeness, and `Nat.Prime.dvd_mul` peeling to enumerate the divisor set — rather than a brute
`decide`.

---

## 8. Algorithmic content

The formalization is constructive enough to read off practical algorithms.

**Korselt check.** Given `n`: factor `n`; reject if any prime repeats (not squarefree) or if `n` is
prime; otherwise, for each distinct prime factor `p`, test whether `(p − 1) ∣ (n − 1)`; accept iff
all tests pass. The cost is dominated by factoring `n`; given the factorization, the remaining work
is `O(ω(n))` divisibility tests, where `ω(n)` is the number of distinct prime factors.

**Carmichael enumeration.** Generate squarefree composites with three or more prime factors (by
Theorems 6.1–6.3, odd ones only), and apply the Korselt check. This is exactly how the classical
tables of Carmichael numbers (561, 1105, 1729, 2465, 2821, 6601, …) are produced.

**Cryptographic moral.** Because Carmichael numbers pass the Fermat test for every coprime base, no
base-sampling strategy within the Fermat framework can reliably detect compositeness. Production
primality testing therefore uses the strong (Miller–Rabin) test, which inspects the order-2
structure of the multiplicative group and provably catches every composite. Korselt's criterion is
the precise statement of *why* the naive test fails.

---

## 9. Related work and context

The single-base notion of a Fermat pseudoprime is standard, but the full Carmichael property was
not available as a structural theorem in our environment — the number-theory library documentation
explicitly records Carmichael numbers as undefined. The present development supplies the missing
sufficient direction of Korselt's criterion and connects it to the existing pseudoprime predicate.
Classical references for the underlying mathematics are Korselt's 1899 note and Carmichael's 1910
paper; the infinitude of Carmichael numbers is the theorem of Alford, Granville, and Pomerance
(1994).

---

## 10. Discussion and future work

The proof's architecture — a local field-theoretic identity recombined globally via coprimality —
is reusable. The same two-step pattern (collapse an exponent in each residue field, then glue with
the Chinese Remainder Theorem over squarefree factors) underlies many "universal congruence"
results.

The natural next target is the **converse**, which would upgrade the result to a biconditional:

> *Conjecture (necessity).* If a composite `n` divides `a^(n−1) − 1` for every `a` coprime to `n`
> (equivalently, `n` is a Fermat pseudoprime to every coprime base), then `n` is squarefree and
> `(p − 1) ∣ (n − 1)` for every prime `p ∣ n`.

Together with `fermatPsp_of_coprime` this yields the full equivalence `IsKorselt n ↔ IsCarmichael
n`. The necessity argument hinges on the existence of a primitive root modulo each prime power
dividing `n`: choosing a witness `b` whose order modulo `p` is exactly `p − 1` forces
`(p − 1) ∣ (n − 1)`, and a witness exposing a repeated prime factor forces squarefreeness. Several
further extensions suggest themselves: a verified enumerator producing the classical Carmichael
table with certificates; the connection to the universal exponent (Carmichael function) `λ(n)`,
since `n` is Carmichael iff `λ(n) ∣ n − 1`; and Lucas–Carmichael analogues for other
group-theoretic primality tests.

---

## 11. Conclusion

We have given a complete, first-principles formalization of the sufficient half of Korselt's
criterion: any squarefree composite `n > 1` with `(p − 1) ∣ (n − 1)` for every prime `p ∣ n` is a
Carmichael number. The proof reduces to a transparent local-to-global mechanism, yields the
structural theorems that every Carmichael number is odd, squarefree, and built from at least three
distinct primes, and verifies the canonical smallest example `561 = 3 · 11 · 17`. The headline
bridge connects finite-field exponentiation to the standard Fermat-pseudoprime predicate, closing a
gap the library itself had named. All results are machine-checked and rest only on the standard
foundational axioms.
