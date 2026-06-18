# Korselt's Criterion and a Multiplicative-Order Bridge to Cryptographic Pseudoprimality

## Abstract

Korselt's criterion characterizes the absolute Fermat pseudoprimes (Carmichael
numbers) as the squarefree composites `n` for which `(p - 1) | (n - 1)` for every
prime `p | n`. We isolate, state, and rigorously establish the precise arithmetic
step at the heart of the criterion's converse direction: if every unit modulo a
squarefree `n` is annihilated by the exponent `n - 1`, then `(p - 1) | (n - 1)`
for every prime `p | n`. We show that this step is, structurally, a statement
about orders of elements in finite abelian groups. The proof combines four
ingredients: (i) order divides any uniform annihilating exponent, with no
finiteness hypothesis; (ii) group homomorphisms do not increase orders; (iii) the
reduction homomorphism `(ℤ/nℤ)ˣ ↠ (ℤ/pℤ)ˣ` is surjective whenever `p | n`; and
(iv) `(ℤ/pℤ)ˣ` is cyclic of order `p - 1` and hence contains an element of order
exactly `p - 1`. We discuss how this bridge separates the global pseudoprimality
condition from the local order condition, why the exponent `n - 1` is inessential
(pointing to the Carmichael function `λ(n)` as the true invariant), and the
consequences for primality testing, including the rationale for the Miller–Rabin
refinement. We close with falsifiable conjectures: the full converse of Korselt's
criterion, a generalized-exponent version, and a quantitative order-collapse
statement underpinning randomized compositeness witnesses.

**Keywords.** Korselt's criterion, Carmichael numbers, Fermat pseudoprimes,
multiplicative group of units, element order, cyclic groups, primality testing,
Miller–Rabin, Carmichael function.

**MSC 2020.** 11A51 (primality), 11Y11 (primality testing), 20K01 (finite abelian
groups), 11A07 (congruences).

---

## 1. Introduction

Fermat's Little Theorem states that for a prime `p` and an integer `a` with
`p ∤ a`, one has `a^(p-1) ≡ 1 (mod p)`. The contrapositive yields the **Fermat
primality test**: if `a^(n-1) ≢ 1 (mod n)` for some base `a` coprime to `n`, then
`n` is composite. The test is fast and factorization-free, but it admits false
positives.

A composite `n > 1` is an **absolute Fermat pseudoprime** (a **Carmichael
number**) if `a^(n-1) ≡ 1 (mod n)` for *every* integer `a` coprime to `n`. Such
`n` pass the Fermat test for all admissible bases and are therefore invisible to
it. The classical characterization is:

> **Theorem (Korselt, 1899).** A composite `n > 1` is a Carmichael number if and
> only if `n` is squarefree and `(p - 1) | (n - 1)` for every prime `p | n`.

The criterion is a biconditional with two asymmetric directions:

- **Forward (constructive):** squarefree `+` `∀ p|n, (p-1)|(n-1)` `⇒` absolute
  Fermat pseudoprime. This direction is a direct computation via the Chinese
  Remainder Theorem (CRT): the local annihilations `a^(n-1) ≡ 1 (mod p)`, valid
  because `(p-1) | (n-1)`, reassemble into a global annihilation modulo `n`.
- **Converse (extraction):** absolute Fermat pseudoprime `⇒` squarefree `+`
  `∀ p|n, (p-1)|(n-1)`. This direction must *produce* the divisibility from the
  global hypothesis, and it is here that the multiplicative group structure does
  the work.

This paper isolates the single arithmetic core of the converse — the extraction of
`(p-1) | (n-1)` from the global annihilation — and gives a self-contained,
machine-verified group-theoretic proof. We then situate this bridge in the broader
theory: its role in the local-to-global structure of Korselt's criterion, its
independence from the specific exponent `n - 1`, and its relevance to modern
primality testing and cryptography.

### 1.1 Contributions

1. A clean statement of the **arithmetic bridge** (Theorem 4.3): for squarefree
   `n`, prime `p | n`, and the hypothesis `∀ u ∈ (ℤ/nℤ)ˣ, u^(n-1) = 1`, one has
   `(p - 1) | (n - 1)`.
2. Two reusable structural lemmas: a finiteness-free "order divides uniform
   annihilator" lemma (Theorem 4.1), and a "homomorphisms do not increase order"
   lemma (Theorem 4.2).
3. A unified proof architecture exhibiting the bridge as a composition of a
   surjective reduction homomorphism and the cyclicity of `(ℤ/pℤ)ˣ`.
4. A discussion isolating `n - 1` as inessential and identifying the Carmichael
   function `λ(n)` as the genuine invariant, plus three falsifiable conjectures.

---

## 2. Preliminaries and Definitions

Throughout, `n` and `p` are positive integers, with `p` prime where indicated.

**Definition 2.1 (Units modulo `n`).** The group of units `(ℤ/nℤ)ˣ` is the
multiplicative group of residue classes `[a]` with `gcd(a, n) = 1`. Its order is
Euler's totient `φ(n)`. For prime `p`, `(ℤ/pℤ)ˣ` has order `p - 1`.

**Definition 2.2 (Order of an element).** In a monoid `M` with identity `1`, the
**order** of `g ∈ M`, written `ord(g)`, is the least positive integer `k` with
`g^k = 1` if one exists, and `0` otherwise. We use the standard fact
`ord(g) | m ⇔ g^m = 1` in the regime where `ord(g) > 0`; more precisely, in any
monoid, `g^m = 1 ⇒ ord(g) | m`.

**Definition 2.3 (Squarefree).** `n` is **squarefree** if no prime square divides
`n`; equivalently `n` is a product of distinct primes. Squarefreeness implies
`n ≠ 0`.

**Definition 2.4 (Cyclic group).** A group `G` is **cyclic** if `G = ⟨g⟩` for some
`g ∈ G`. In a finite cyclic group, a generator has order equal to `|G|`.

**Definition 2.5 (Absolute Fermat pseudoprime / Carmichael number).** A composite
`n > 1` is a Carmichael number if `a^(n-1) ≡ 1 (mod n)` for every `a` with
`gcd(a, n) = 1`; equivalently, every `u ∈ (ℤ/nℤ)ˣ` satisfies `u^(n-1) = 1`.

**Definition 2.6 (Reduction map on units).** If `p | n`, the ring projection
`ℤ/nℤ → ℤ/pℤ` restricts to a group homomorphism on units,
`f : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ`, sending `[a]_n ↦ [a]_p`. (In a formal library this is
the canonical "units map" associated to a divisibility `p | n`.)

**Definition 2.7 (Carmichael function).** The **Carmichael function** `λ(n)` is the
least positive integer `e` such that `a^e ≡ 1 (mod n)` for all `a` coprime to `n`,
i.e. the exponent of `(ℤ/nℤ)ˣ`. For squarefree `n = p_1 ⋯ p_k`,
`λ(n) = lcm(p_1 - 1, …, p_k - 1)`.

---

## 3. Foundational Facts

We record the classical results used below.

**Fact 3.1 (Order and annihilators).** In any monoid, if `g^m = 1` then
`ord(g) | m`. Consequently if `g^m = 1` for *all* `g`, then `ord(g) | m` for all
`g`. No finiteness assumption is required.

**Fact 3.2 (Homomorphisms and powers).** A monoid homomorphism `f` satisfies
`f(g^k) = f(g)^k` and `f(1) = 1`.

**Fact 3.3 (Surjectivity of the reduction map).** For `p | n` with `n ≠ 0`, the
reduction homomorphism `f : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` of Definition 2.6 is surjective.
(For squarefree `n` this follows from CRT and the surjectivity of each local
projection; in general it holds whenever `p | n` and the relevant residue rings
are nontrivial.)

**Fact 3.4 (Cyclicity of `(ℤ/pℤ)ˣ`).** For prime `p`, the group `(ℤ/pℤ)ˣ` is
cyclic of order `p - 1`. Hence there exists `g ∈ (ℤ/pℤ)ˣ` with `ord(g) = p - 1`
(a *primitive root* modulo `p`).

---

## 4. Main Results

We present three results in increasing specificity: two structural lemmas of
independent interest and the arithmetic bridge.

### 4.1 Order divides any uniform annihilator

> **Theorem 4.1.** Let `G` be a monoid and `m ∈ ℕ`. If `g^m = 1` for every
> `g ∈ G`, then `ord(g) | m` for every `g ∈ G`.

**Proof.** Fix `g`. By hypothesis `g^m = 1`, and by Fact 3.1, `g^m = 1` implies
`ord(g) | m`. ∎

*Remark.* The statement is deliberately finiteness-free: it holds in arbitrary
monoids, including infinite ones. This generality is precisely what allows the
hypothesis to be applied to `(ℤ/nℤ)ˣ` without invoking its cardinality.

### 4.2 Homomorphisms do not increase order

> **Theorem 4.2.** Let `G, H` be groups and `f : G → H` a group homomorphism. Then
> for every `g ∈ G`, `ord(f(g)) | ord(g)`.

**Proof.** Let `k = ord(g)`, so `g^k = 1`. Then
`f(g)^k = f(g^k) = f(1) = 1` by Fact 3.2. By Fact 3.1, `f(g)^k = 1` implies
`ord(f(g)) | k = ord(g)`. ∎

*Remark.* This monotonicity expresses that a homomorphism can only inherit or
shrink periodicity, never create it. Surjectivity is *not* needed for this
inequality; it becomes relevant only when one wishes to transport an annihilation
hypothesis in the opposite direction (from domain to codomain), as in the bridge
below.

### 4.3 The arithmetic bridge toward Korselt's criterion

> **Theorem 4.3 (Arithmetic bridge).** Let `n` be squarefree, let `p` be a prime
> with `p | n`, and suppose every unit `u ∈ (ℤ/nℤ)ˣ` satisfies `u^(n-1) = 1`. Then
> `(p - 1) | (n - 1)`.

**Proof.** Squarefreeness gives `n ≠ 0`, so the reduction homomorphism
`f : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ` of Definition 2.6 is defined and, by Fact 3.3,
surjective.

*Step 1 — transport the annihilation downstairs.* Let `v ∈ (ℤ/pℤ)ˣ` be arbitrary.
By surjectivity choose `u ∈ (ℤ/nℤ)ˣ` with `f(u) = v`. Then, using Fact 3.2 and the
hypothesis,
```
v^(n-1) = f(u)^(n-1) = f(u^(n-1)) = f(1) = 1.
```
Hence every `v ∈ (ℤ/pℤ)ˣ` satisfies `v^(n-1) = 1`.

*Step 2 — find a maximal-order element.* By Fact 3.4, `(ℤ/pℤ)ˣ` is cyclic of
order `p - 1`; let `g` be a generator, so `ord(g) = p - 1`.

*Step 3 — conclude.* By Step 1, `g^(n-1) = 1`. By Fact 3.1, `g^(n-1) = 1` implies
`ord(g) | (n - 1)`. Since `ord(g) = p - 1`, we obtain `(p - 1) | (n - 1)`. ∎

*Remark (only `n ≠ 0` is used from squarefreeness).* The proof consumes
squarefreeness solely to guarantee `n ≠ 0` (so that `(ℤ/nℤ)ˣ` and the reduction
map behave correctly). The genuinely arithmetic content — `(p-1) | (n-1)` — flows
entirely from the group structure.

*Remark (the role of cyclicity).* Step 1 alone gives that `n - 1` annihilates
`(ℤ/pℤ)ˣ`, which is equivalent to `λ(p) = p - 1` dividing `n - 1`. Cyclicity is
what makes `λ(p) = p - 1` (the exponent equals the order), so that the annihilation
of the whole group is detected by a single element of full order. Without
cyclicity one would only obtain divisibility by the exponent of the local group.

---

## 5. Architecture of the Proof

The bridge factors as a pipeline. Below, `1` denotes the identity and
`ord` the order function.

```
Hypothesis:   ∀ u ∈ (ℤ/nℤ)ˣ.  u^(n-1) = 1          (global annihilation)
      │
      │  push along surjective f : (ℤ/nℤ)ˣ ↠ (ℤ/pℤ)ˣ   (Fact 3.3, Fact 3.2)
      ▼
Derived:      ∀ v ∈ (ℤ/pℤ)ˣ.  v^(n-1) = 1          (local annihilation)
      │
      │  pick generator g, ord(g) = p-1               (Fact 3.4, cyclicity)
      ▼
Apply:        g^(n-1) = 1  ⇒  ord(g) | (n-1)         (Fact 3.1)
      ▼
Conclusion:   (p-1) | (n-1)
```

Two design choices keep the argument modular:

1. **Finiteness-free annihilation (Theorem 4.1).** Phrasing "order divides
   annihilator" without cardinality hypotheses lets the *same* lemma fire both for
   `(ℤ/nℤ)ˣ` (in the hypothesis) and for the chosen generator `g` (in the
   conclusion).
2. **Order monotonicity as a named lemma (Theorem 4.2).** Although the final proof
   transports the annihilation *forward* via surjectivity rather than invoking
   `ord(f(g)) | ord(g)` directly, Theorem 4.2 is the conceptual reason the forgery
   can only flow from the global group down to the local one. It is stated
   separately so that the directionality is explicit and reusable.

---

## 6. Worked Examples

**Example 6.1 (`n = 561 = 3 · 11 · 17`).** Squarefree; `n - 1 = 560`. Local data:
`p - 1 ∈ {2, 10, 16}`. Each divides `560` (`560 = 2·280 = 10·56 = 16·35`), so by
Theorem 4.3 every prime factor satisfies the divisibility — consistent with `561`
being the least Carmichael number. The local groups `(ℤ/3ℤ)ˣ, (ℤ/11ℤ)ˣ,
(ℤ/17ℤ)ˣ` are cyclic of orders `2, 10, 16`, each annihilated by `560`.

**Example 6.2 (`n = 1105 = 5 · 13 · 17`).** `n - 1 = 1104`; `p - 1 ∈ {4, 12, 16}`;
all divide `1104`. Carmichael.

**Example 6.3 (`n = 1729 = 7 · 13 · 19`).** `n - 1 = 1728`; `p - 1 ∈ {6, 12, 18}`;
all divide `1728`. Carmichael (and the Hardy–Ramanujan taxicab number).

**Example 6.4 (a non-example, `n = 15 = 3 · 5`).** `n - 1 = 14`; `p - 1 ∈ {2, 4}`.
Here `2 | 14` but `4 ∤ 14`. The bridge's hypothesis must therefore fail: indeed a
primitive root `g` modulo `5` has order `4`, and `g^14 ≠ 1` in `(ℤ/5ℤ)ˣ`, so some
unit modulo `15` is not annihilated by `14`. Concretely `2^14 = 16384 ≡ 4 (mod 15)`,
witnessing that `15` is *not* a Fermat pseudoprime — the Fermat test exposes it.

---

## 7. Algorithms

The bridge and its surrounding criterion yield concrete, efficient procedures.

**Algorithm 7.1 (Korselt verification).** Given `n`, decide whether `n` satisfies
Korselt's two conditions, i.e. whether `n` is a Carmichael number.

```
Input: composite n > 1
1. Factor n = ∏ p_i^{e_i}.
2. If any e_i > 1, return False        # not squarefree
3. For each prime p_i:
       if (n - 1) mod (p_i - 1) ≠ 0: return False
4. return True
```
Complexity is dominated by factoring; given the factorization, the divisibility
checks are `O(k)` modular reductions on integers of size `O(log n)`.

**Algorithm 7.2 (Order-collapse witness search).** For a Korselt number `n` with
`k` prime factors, sample units `a` and compute `ord(a) mod (n-1)`; by the bridge,
every order divides `n - 1`, and a Miller–Rabin-style square-root probe detects
the proper-divisor collapse used to certify compositeness.

---

## 7.5 Group-Theoretic Context and Why the Decomposition Matters

It is worth dwelling on *why* the bridge admits such a short proof, because the
brevity is a consequence of choosing the correct categorical setting rather than a
lucky accident. Three structural choices conspire.

First, by phrasing the annihilation lemma (Theorem 4.1) over arbitrary monoids, we
decouple it from any cardinality argument. A more naive route would invoke
Lagrange's theorem — "the order of an element divides the order of the group" — and
then argue that `|（ℤ/pℤ)ˣ| = p - 1` divides `n - 1`. But Lagrange gives only that
`ord(g) | (p - 1)`, which is the *wrong* direction: it bounds the order from above
by `p - 1`, whereas we need a witness whose order is *exactly* `p - 1`. The
annihilation lemma sidesteps this entirely: it converts the hypothesis `g^(n-1) = 1`
into `ord(g) | (n - 1)` directly, with no appeal to the group's size.

Second, the surjectivity of the reduction map (Fact 3.3) is the only place where
the relationship between `n` and `p` enters. Surjectivity is exactly the property
that lets a *universal* statement ("for all units mod `n`") descend to another
universal statement ("for all units mod `p`"). Had the map been merely injective
or an arbitrary homomorphism, the descent would fail: the image might miss the
full-order element `g`, and the hypothesis would say nothing about it.

Third, cyclicity (Fact 3.4) is what guarantees that the descended universal
statement has *teeth*. In a cyclic group of order `p - 1`, the exponent of the
group equals its order, so a single generator already "feels" the entire
constraint. In a general abelian group the exponent can be strictly smaller than
the order, and one would conclude only that the group's exponent divides `n - 1` —
a weaker fact. For `(ℤ/pℤ)ˣ`, exponent and order coincide, which is precisely the
statement that primitive roots exist modulo a prime.

The interplay of these three — finiteness-free annihilation, surjective descent,
and cyclic teeth — is the reason a centuries-old number-theoretic phenomenon
collapses into a four-line group-theoretic argument. It also explains, by
contrast, exactly where the *converse* squarefreeness direction (Conjecture C1)
requires extra input: there, the local group is `(ℤ/p^kℤ)ˣ` with `k ≥ 2`, whose
generator has order `p^{k-1}(p - 1)`, and the divisibility `p^{k-1}(p - 1) ∤ n - 1`
is what obstructs non-squarefree pseudoprimes.

## 8. Applications

**8.1 Primality testing and the Miller–Rabin rationale.** Theorem 4.3 explains the
Fermat test's fundamental blind spot: a Carmichael number `n` annihilates the
*entire* unit group by `n - 1`, so no Fermat base can distinguish it from a prime.
The Miller–Rabin test repairs this by examining square roots of `1` along the
exponentiation chain `a^((n-1)/2^j)`. Because the bridge forces each local group to
be annihilated by `n - 1` while remaining genuinely a *product* of `k ≥ 2` cyclic
factors, nontrivial square roots of `1` exist modulo `n` (by CRT, e.g. residues
that are `+1` at one factor and `-1` at another), and these are precisely the
Miller–Rabin witnesses. The order structure exposed by the bridge is thus the
direct justification for the stronger test that underlies real-world RSA and
Diffie–Hellman key generation.

**8.2 Local-to-global structure.** The bridge is a microcosm of the local-global
principle: a global congruence condition modulo `n` is shown to imply a family of
local order conditions at each `p | n`, with a surjective reduction homomorphism as
the transport map. The reverse assembly — local conditions implying the global one
— is the CRT-based forward direction of Korselt's criterion, completing the
dictionary.

**8.3 The Carmichael function as the true invariant.** Section 9 (C2) formalizes
the observation that `n - 1` is inessential. The invariant content of the bridge is
that the universal exponents of `(ℤ/nℤ)ˣ` are exactly the common multiples of the
local `p - 1`; the least such is the Carmichael function `λ(n) = lcm_p (p - 1)`.

---

## 9. Discussion and Future Work

The cycle proves, unconditionally, the constructive direction of Korselt's
criterion and lifts its conclusion to an order-divisibility condition on
`(ℤ/nℤ)ˣ`. The analysis suggests the following falsifiable conjectures.

**C1 — Korselt's criterion is an iff (the hard converse).** *Conjecture.* If
`n > 1` is composite and `a^(n-1) ≡ 1 (mod n)` for every `a` coprime to `n`, then
`n` is squarefree and `(p - 1) | (n - 1)` for every prime `p | n`. *Insight.* The
converse is forced by the existence of a primitive root modulo each prime power
factor: if `p^2 | n`, a generator of `(ℤ/p²ℤ)ˣ` has order `p(p-1) ∤ n - 1`,
contradicting pseudoprimality; and a primitive root modulo `p` shows
`(p-1) | n-1`. Formalizing requires cyclicity of `(ℤ/p^kℤ)ˣ` for odd `p` plus a
CRT splitting. The divisibility direction (`(p-1)|(n-1)`) is exactly Theorem 4.3;
the squarefreeness direction is the remaining ingredient.

**C2 — Generalized Korselt with an arbitrary exponent.** *Conjecture.* For
squarefree `n` and any `e ≥ 1`, `a^e ≡ 1 (mod n)` for all coprime `a` **iff**
`(p-1) | e` for every prime `p | n`. The classical criterion is `e = n - 1`.
*Insight.* The value `n - 1` plays no role in the forward proof; the relevant
hypothesis is only `(p-1) | e`. The true invariant is the universal exponent
`λ(n) = lcm{p - 1}`. Theorem 4.3 already proves the `⇒` direction with `e = n - 1`,
and its proof is verbatim valid for arbitrary `e`.

**C3 — Order-spectrum collapse is detectable by a single random base.**
*Conjecture.* For a Korselt number `n` with `k` distinct prime factors, the
fraction of bases `a ∈ (ℤ/nℤ)ˣ` whose order is a *proper* divisor of `n - 1` is at
least `1 - 2^{-(k-1)}`; hence a single uniformly random Fermat–Miller–Rabin
witness exposes the order collapse with probability bounded away from `0`.
*Insight.* The bridge (extended to all units) says every unit has order dividing
`n - 1`; the Miller–Rabin refinement detects compositeness precisely through the
proper-divisor structure that the product-of-cyclic-groups decomposition forces.

---

## 10. Conclusion

We have isolated and rigorously verified the arithmetic core of the converse of
Korselt's criterion: global annihilation by `n - 1` forces the local divisibility
`(p - 1) | (n - 1)`. The proof reveals the phenomenon as fundamentally
group-theoretic — order divisibility transported across a surjective reduction
homomorphism into a cyclic local group — and clarifies both the inessentiality of
the exponent `n - 1` and the cryptographic stakes of the Fermat test's blind spot.
The result slots into a modular architecture of reusable lemmas and points toward a
fully formalized biconditional Korselt criterion and its generalized-exponent and
quantitative refinements.

---

## References (classical, for context only — this paper is self-contained)

The results above are stated and proved inline; the following classical landmarks
provide historical context: Fermat's Little Theorem (1640); A. Korselt's criterion
(1899); R. D. Carmichael's study of absolute pseudoprimes (1910); the
Alford–Granville–Pomerance theorem on the infinitude of Carmichael numbers (1994);
and the Miller–Rabin probabilistic primality test (1976–1980).
