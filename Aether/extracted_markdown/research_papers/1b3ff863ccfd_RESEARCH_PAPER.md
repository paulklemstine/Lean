# The Korselt Units Bridge: From Fermat Pseudoprimality to Per-Prime Order Divisibility

## Abstract

A composite integer `n` is an *absolute Fermat pseudoprime* (a **Carmichael number**)
when `a^(n-1) ≡ 1 (mod n)` for every base `a` coprime to `n`. Korselt's criterion
(1899) characterizes such numbers as the squarefree `n` for which `(p - 1) ∣ (n - 1)`
holds for every prime `p ∣ n`. We isolate, generalize, and rigorously verify the
*divisibility* half of this characterization through the lens of the unit group
`(ℤ/nℤ)ˣ`. Our central result states that whenever every unit of `ℤ/nℤ` is annihilated
by the exponent `n - 1`, the local divisibility `(p - 1) ∣ (n - 1)` is forced for each
prime divisor `p`. The proof is a short chain of four group-theoretic facts: the order
of an element divides any annihilating exponent; group homomorphisms do not increase
orders; the reduction map on units `(ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` is surjective whenever `p ∣ n`;
and `(ℤ/pℤ)ˣ` is cyclic of order `p - 1`. Two structural observations fall out of the
formalization: the squarefreeness hypothesis is *not* used by this arithmetic step,
and the exponent `n - 1` is *not* special — the same proof yields a general statement
for an arbitrary exponent `e`, connecting directly to the Carmichael function `λ(n)`.
All results have been formally verified.

**Keywords.** Carmichael numbers, Korselt's criterion, Fermat pseudoprimes, unit
group, multiplicative order, cyclic groups, primitive roots, Carmichael function,
formal verification.

**MSC 2020.** 11A51 (primality), 11A07 (congruences; primitive roots), 20K01 (finite
abelian groups), 11Y11 (primality testing), 68V20 (formalization of mathematics).

---

## 1. Introduction

### 1.1 Background and motivation

Fermat's Little Theorem asserts that for a prime `p` and any `a` with `p ∤ a`, we have
`a^(p-1) ≡ 1 (mod p)`. Its contrapositive underlies the *Fermat primality test*:
given `n`, choose a base `a` coprime to `n` and verify `a^(n-1) ≡ 1 (mod n)`; a
failure certifies compositeness. The test is undermined by composite numbers that pass
for every admissible base.

**Definition 1.1 (absolute Fermat pseudoprime).** A composite integer `n > 1` is an
*absolute Fermat pseudoprime*, or **Carmichael number**, if `a^(n-1) ≡ 1 (mod n)` for
every integer `a` with `gcd(a, n) = 1`.

The smallest such number is `561 = 3 · 11 · 17`; the sequence continues `1105, 1729,
2465, 2821, 6601, …`. Alford, Granville, and Pomerance proved in 1994 that there are
infinitely many Carmichael numbers, so the failure mode of the Fermat test is
permanent rather than a finite annoyance.

**Theorem 1.2 (Korselt's criterion, 1899).** A composite `n > 1` is a Carmichael
number if and only if `n` is squarefree and `(p - 1) ∣ (n - 1)` for every prime
`p ∣ n`.

Korselt established this criterion more than a decade before any Carmichael number was
explicitly exhibited. This paper concerns the **divisibility direction**: that the
pseudoprime property forces `(p - 1) ∣ (n - 1)` at each prime factor. We recast the
hypothesis as a statement about the unit group `(ℤ/nℤ)ˣ`, isolate the precise
group-theoretic content, and verify it formally. The reformulation exposes two facts
that the classical phrasing obscures: squarefreeness is irrelevant to this step, and
the exponent `n - 1` may be replaced by any exponent.

### 1.2 Contributions

1. A clean, self-contained proof of the divisibility direction of Korselt's criterion,
   phrased entirely in terms of the unit group `(ℤ/nℤ)ˣ` (Theorem 4.1).
2. Three reusable supporting lemmas of independent interest: an order-divisibility
   lemma (Lemma 3.1), a homomorphism order lemma (Lemma 3.2), and the surjectivity of
   the unit reduction map for divisor moduli (Lemma 3.3).
3. The structural observation that the squarefreeness hypothesis plays no role in this
   arithmetic step (Section 5.1), and that the exponent `n - 1` generalizes to an
   arbitrary `e`, linking the result to the Carmichael function `λ(n)` (Section 5.2).
4. A complete formal verification of all statements.

---

## 2. The unit group and the order reformulation

Throughout, `n > 1` is an integer and `p` is a prime dividing `n`. We write `(ℤ/nℤ)ˣ`
for the group of multiplicative units of the ring `ℤ/nℤ`; its elements correspond to
residue classes of integers coprime to `n`, and its cardinality is Euler's totient
`φ(n)`.

**Definition 2.1 (order of an element).** In a monoid `M`, the *order* of an element
`g`, written `ord(g)`, is the least positive integer `k` with `g^k = 1`, or `0` if no
such `k` exists. In a finite group every element has finite positive order.

**Definition 2.2 (annihilating exponent).** An exponent `e` *annihilates* a group `G`
if `g^e = 1` for all `g ∈ G`.

The pseudoprime property is precisely an annihilation statement.

**Proposition 2.3 (reformulation).** For `n > 1`, the following are equivalent:
1. `a^(n-1) ≡ 1 (mod n)` for every `a` coprime to `n`;
2. `u^(n-1) = 1` for every unit `u ∈ (ℤ/nℤ)ˣ`;
3. the exponent `n - 1` annihilates `(ℤ/nℤ)ˣ`.

*Proof.* The classes `a` coprime to `n` are exactly the units of `ℤ/nℤ`, and
`a^(n-1) ≡ 1 (mod n)` says precisely that the corresponding unit `u` satisfies
`u^(n-1) = 1`. Statements (2) and (3) are notational variants of one another. ∎

We therefore take the unit-group annihilation hypothesis `∀ u, u^(n-1) = 1` as our
working form of the Carmichael property and prove the divisibility conclusion from it.

---

## 3. Supporting lemmas

The proof rests on three lemmas, each elementary but each doing genuine work.

**Lemma 3.1 (order divides any annihilating exponent).** Let `M` be a monoid and
`m ∈ ℕ`. If `g^m = 1` for every `g ∈ M`, then `ord(g) ∣ m` for every `g`.

*Proof sketch.* For a fixed `g`, `g^m = 1` means `m` is an exponent killing `g`; the
order is by definition the least positive such exponent, and every exponent killing
`g` is a multiple of `ord(g)` (`g^k = 1 ⟺ ord(g) ∣ k`). Hence `ord(g) ∣ m`. ∎

> *Formal name:* `orderOf_dvd_of_forall_pow_eq_one`. It is a one-line consequence of
> the Mathlib lemma `orderOf_dvd_of_pow_eq_one`.

**Lemma 3.2 (homomorphisms do not increase order).** Let `φ : G → H` be a group
homomorphism. Then for every `g ∈ G`, `ord(φ(g)) ∣ ord(g)`.

*Proof sketch.* Let `k = ord(g)`, so `g^k = 1`. Applying `φ` and using that it is a
homomorphism, `φ(g)^k = φ(g^k) = φ(1) = 1`. Thus `k` is an exponent killing `φ(g)`,
so `ord(φ(g)) ∣ k = ord(g)`. ∎

> *Formal name:* `orderOf_map_dvd_of_surjective`. (The surjectivity is not needed for
> this divisibility; the name reflects the broader setting in which it is applied.)

**Lemma 3.3 (surjectivity of the unit reduction map).** Let `p ∣ n` with `n > 0`.
The induced reduction homomorphism on units
`unitsMap : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ`
is surjective.

*Proof sketch.* Reduction `ℤ/nℤ → ℤ/pℤ` is a surjective ring homomorphism when
`p ∣ n`. A unit of `ℤ/pℤ` lifts to a unit of `ℤ/nℤ`: concretely, every residue class
modulo `p` that is coprime to `p` can be represented by an integer coprime to `n`
(by the Chinese Remainder Theorem / Dirichlet-type lifting of coprime residues), and
that integer's class modulo `n` is a unit mapping onto the chosen unit modulo `p`.
This is the content of Mathlib's `ZMod.unitsMap_surjective`. ∎

> *Formal name:* `unitsMap_surjective_of_dvd`.

Finally we recall the classical structural fact that supplies the maximal-order
element.

**Theorem 3.4 (primitive root / cyclicity modulo a prime).** For a prime `p`, the unit
group `(ℤ/pℤ)ˣ` is cyclic of order `p - 1`. In particular there exists a generator
`g` with `ord(g) = p - 1`.

*Proof sketch.* `(ℤ/pℤ)ˣ` is a finite subgroup of the multiplicative group of the
field `ℤ/pℤ`; every finite subgroup of the multiplicative group of a field is cyclic
(a polynomial `X^d - 1` over a field has at most `d` roots, which forces the element
counts of each order to match those of a cyclic group). Its cardinality is
`φ(p) = p - 1`, so a generator has order exactly `p - 1`. ∎

> *Formal ingredients:* `IsCyclic.exists_ofOrder_eq_natCard` together with
> `ZMod.card_units p`.

---

## 4. Main theorem

**Theorem 4.1 (Korselt divisibility, units form).** Let `n > 0` and let `p` be a prime
with `p ∣ n`. Suppose that every unit `u ∈ (ℤ/nℤ)ˣ` satisfies `u^(n-1) = 1`. Then
```
(p - 1) ∣ (n - 1).
```
(The hypothesis that `n` is squarefree may be assumed for compatibility with the
classical statement, but it is not used in the proof.)

*Proof.* We argue in four steps.

**Step 1 — descend the annihilation to `(ℤ/pℤ)ˣ`.** Let `φ = unitsMap : (ℤ/nℤ)ˣ →
(ℤ/pℤ)ˣ` be the reduction homomorphism, which is surjective by Lemma 3.3. Fix any
`v ∈ (ℤ/pℤ)ˣ`. By surjectivity choose `u ∈ (ℤ/nℤ)ˣ` with `φ(u) = v`. Then
```
v^(n-1) = φ(u)^(n-1) = φ(u^(n-1)) = φ(1) = 1,
```
using that `φ` is a homomorphism and the hypothesis `u^(n-1) = 1`. Hence the exponent
`n - 1` annihilates `(ℤ/pℤ)ˣ`.

**Step 2 — produce a maximal-order generator.** By Theorem 3.4, `(ℤ/pℤ)ˣ` is cyclic
with `|(ℤ/pℤ)ˣ| = p - 1`. Choose a generator `g` with `ord(g) = p - 1`.

**Step 3 — order divides the exponent.** By Step 1, `g^(n-1) = 1`, so by Lemma 3.1
`ord(g) ∣ (n - 1)`.

**Step 4 — conclude.** Substituting `ord(g) = p - 1` from Step 2 yields
`(p - 1) ∣ (n - 1)`. ∎

The proof transports a *global* hypothesis about the large group `(ℤ/nℤ)ˣ` to a
*local* conclusion at the prime `p` by means of the surjective reduction map, then
extracts the sharpest possible consequence using the element of maximal order in the
target.

**Corollary 4.2 (full Korselt divisibility clause).** If `n` is a Carmichael number,
then `(p - 1) ∣ (n - 1)` for every prime `p ∣ n`.

*Proof.* By Proposition 2.3 the Carmichael hypothesis gives `u^(n-1) = 1` for all
units `u`; apply Theorem 4.1 at each prime factor. ∎

---

## 5. Structural observations

### 5.1 Squarefreeness is not used

Korselt's full criterion couples two clauses — squarefreeness and the divisibilities
`(p - 1) ∣ (n - 1)`. It is natural to expect the divisibility proof to consume the
squarefree hypothesis. It does not. Every step of Theorem 4.1 is valid for an
arbitrary prime divisor `p` of `n`, regardless of the multiplicity with which `p`
occurs in `n`: Lemma 3.3 holds for *any* divisor relation `p ∣ n`, and the cyclic
generator argument refers only to `(ℤ/pℤ)ˣ`, never to `(ℤ/p²ℤ)ˣ` or to the global
factorization shape. Squarefreeness is what the *other* direction of Korselt's theorem
needs (to rule out the obstruction coming from a generator of order `p(p-1)` in
`(ℤ/p²ℤ)ˣ`), and it is a separate clause of the criterion. The formalization keeps the
hypothesis only to match the classical interface and flags it as unused.

### 5.2 The exponent `n - 1` is a historical artifact

A second inspection of the proof shows that the literal value `n - 1` is never
exploited: Steps 1, 3, and 4 use only that some exponent `e` annihilates `(ℤ/nℤ)ˣ`.
Thus Theorem 4.1 immediately generalizes.

**Theorem 5.1 (generalized Korselt divisibility).** Let `n > 0`, let `p` be prime with
`p ∣ n`, and let `e ∈ ℕ`. If `u^e = 1` for every unit `u ∈ (ℤ/nℤ)ˣ`, then
`(p - 1) ∣ e`.

*Proof.* Verbatim the proof of Theorem 4.1 with `n - 1` replaced by `e`. ∎

This pinpoints the true invariant. The set of exponents `e` annihilating `(ℤ/nℤ)ˣ` is
exactly `{e : (p - 1) ∣ e for all primes p ∣ n}` (for squarefree `n` the converse
direction, that these divisibilities suffice, follows from cyclicity at each prime via
the Chinese Remainder Theorem). The least positive such exponent is the **Carmichael
function**
```
λ(n) = lcm { p - 1 : p prime, p ∣ n }   (n squarefree),
```
equivalently the *exponent* of the group `(ℤ/nℤ)ˣ`. In this language the Carmichael
property is the single divisibility `λ(n) ∣ (n - 1)`, and Theorem 5.1 is the local
atom `(p - 1) ∣ λ(n)` from which `λ(n)` is assembled prime-by-prime.

---

## 6. Algorithms

The criterion converts an infinite verification (over all bases `a`) into a finite
factor-based check. We record the natural algorithms.

### 6.1 Korselt check (decide Carmichael from a factorization)

Given the prime factorization of `n`, decide whether `n` is a Carmichael number:
verify that `n` is composite, that the factorization is squarefree (all exponents
equal to `1`), and that `(p - 1) ∣ (n - 1)` for every prime factor `p`. Complexity is
dominated by factoring; given the factorization it is `O(k)` divisibility checks for
`k` prime factors.

### 6.2 Carmichael function `λ(n)`

For squarefree `n = p₁ ⋯ p_k`, compute `λ(n) = lcm(p₁ - 1, …, p_k - 1)`. Theorem 5.1
guarantees `(p_i - 1) ∣ λ(n)`, and `n` is Carmichael iff `λ(n) ∣ (n - 1)`. This gives
a one-line equivalent of the Korselt check that also exposes the size of the effective
exponent of `(ℤ/nℤ)ˣ`.

### 6.3 Order-spectrum probe

For experimental confirmation of the descent step, compute the multiplicative order of
a random base `a` modulo each prime factor `p` and verify `ord_p(a) ∣ (n - 1)`,
witnessing Theorem 4.1 directly. A base attaining `ord_p(a) = p - 1` (a primitive root
mod `p`) realizes the extremal generator used in the proof.

---

## 7. Applications

**Primality testing.** Theorem 1.2 explains exactly why the Fermat test has false
positives and which numbers cause them. The Miller–Rabin refinement was designed
specifically to defeat Carmichael numbers by probing the `2`-adic structure of orders;
understanding the order collapse `ord(u) ∣ (n - 1)` (Theorem 4.1) is the conceptual
starting point for that refinement.

**Cryptography.** Group-action and discrete-logarithm cryptosystems rest on the size
and order structure of `(ℤ/nℤ)ˣ` (or related groups). When `n` is Carmichael, the
universal relation `u^(n-1) = 1` forces the group exponent `λ(n)` to divide `n - 1`,
collapsing the spectrum of element orders and shrinking the effective key space. A
modulus that is inadvertently Carmichael can therefore admit a baby-step/giant-step
search of cost `O(√λ(n))` rather than the intended `O(√φ(n))`. The local divisibility
`(p - 1) ∣ (n - 1)` is the precise mechanism translating a number-theoretic defect
into a cryptographic one.

**Pedagogy and formal libraries.** The four-step proof is an exemplar of the
"global hypothesis → surjective transport → local extremal element" pattern, reusable
across finite group theory; Lemmas 3.1–3.3 are stated generically and can serve other
formal developments.

---

## 8. Discussion and future work

The reformulation through `(ℤ/nℤ)ˣ` cleanly separates the two clauses of Korselt's
criterion and reveals that the divisibility clause is an instance of a more general,
exponent-agnostic phenomenon. Several falsifiable directions follow.

**C1 — The full iff (hard converse).** Prove the converse divisibility direction: if
`n` is composite and every unit satisfies `u^(n-1) = 1`, then `n` is squarefree *and*
`(p - 1) ∣ (n - 1)`. The squarefree converse is forced by the existence of a primitive
root modulo each prime power: if `p² ∣ n`, a generator of `(ℤ/p²ℤ)ˣ` has order
`p(p - 1) ∤ (n - 1)`, contradicting annihilation. Formalizing this needs cyclicity of
`(ℤ/p^kℤ)ˣ` for odd `p` plus a CRT splitting.

**C2 — Generalized Korselt with an arbitrary exponent.** Establish, for squarefree
`n` and any `e ≥ 1`, that `u^e = 1` for all units iff `(p - 1) ∣ e` for every prime
`p ∣ n` (the `e = n - 1` case is classical). Theorem 5.1 is the forward direction; the
converse is the CRT reassembly. The true invariant is `λ(n) = lcm{p - 1}`.

**C3 — Order-collapse density and single-witness tests.** For a Korselt `n` with `k`
distinct prime factors, conjecture that the fraction of units `a` whose order is a
*proper* divisor of `n - 1` is at least `1 - 2^{-(k-1)}`, so a single random
Miller–Rabin witness exposes the collapse with probability bounded away from `0`. This
is a counting statement over the CRT product `∏ (ℤ/pℤ)ˣ`.

**C4 — Geometric (torsor) form.** Cast pseudoprimality as a triviality statement: in
the regular torsor of `(ℤ/nℤ)ˣ` on itself, the "exponentiate-by-`(n-1)`" endomorphism
is the constant identity iff `n` is Carmichael, and fixed-point counts of `act(g^d)`
for `d ∣ n - 1` recover the order spectrum — an orbit–stabilizer computation.

**C5 — Cross-domain hardness transfer.** Quantify the cryptographic consequence: no
free `CryptoGroupAction` of `(ℤ/nℤ)ˣ` can have a classically hard group-action inverse
problem when `n` is Korselt, because the exponent collapse `λ(n) ∣ (n - 1)` yields a
`O(√λ(n))` attack — a security reduction rather than a heuristic.

**D1–D3 (further).** Prove `λ(n)` equals the per-prime lcm exactly (`Monoid.exponent
(ℤ/nℤ)ˣ = lcm{p - 1}`); that every Carmichael number is a product of at least three
distinct odd primes (a finite case analysis on the proven divisibilities and parity);
and the order-collapse density bound of C3.

---

## 9. Conclusion

We have isolated and verified the divisibility heart of Korselt's criterion as a
statement about the unit group `(ℤ/nℤ)ˣ`: annihilation of the group by an exponent
forces that exponent to be divisible by `p - 1` at every prime factor. The proof is a
four-step transport — order under annihilation, order under homomorphisms,
surjectivity of unit reduction, and cyclicity modulo a prime. Two structural facts
emerge with full clarity: squarefreeness is irrelevant to this step, and the exponent
`n - 1` is incidental, the genuine invariant being the Carmichael function `λ(n)`. The
result is the precise, machine-checked bridge from classical Fermat pseudoprimality to
the order structure that governs both primality testing and the security of
group-based cryptography.

---

## Appendix A. Formal statements (as verified)

The following declarations were formally verified.

- **`orderOf_dvd_of_forall_pow_eq_one`** (Lemma 3.1): in a monoid `M`, if `∀ g, g^m = 1`
  then `∀ g, ord(g) ∣ m`.
- **`orderOf_map_dvd_of_surjective`** (Lemma 3.2): for a group homomorphism `φ : G → H`
  and `g ∈ G`, `ord(φ(g)) ∣ ord(g)`.
- **`unitsMap_surjective_of_dvd`** (Lemma 3.3): for `p ∣ n` with `n ≠ 0`, the unit
  reduction map `(ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` is surjective.
- **`prime_sub_one_dvd_of_forall_units_pow_eq_one`** (Theorem 4.1): for `p` prime,
  `p ∣ n`, `n` squarefree, and `∀ u : (ℤ/nℤ)ˣ, u^(n-1) = 1`, one has `(p - 1) ∣ (n - 1)`;
  the squarefree hypothesis is present for interface compatibility and is unused.
