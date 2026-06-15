# The Arithmetic Heart of Korselt's Criterion: A Verified Bridge from the Universal Fermat Condition to Local Divisibility

## Abstract

We present a fully rigorous development of the central arithmetic implication underlying Korselt's criterion for Carmichael numbers. The classical criterion states that a composite integer `n` is a Carmichael number if and only if `n` is squarefree and `(p − 1) ∣ (n − 1)` for every prime `p ∣ n`. The deep direction is the extraction of the *local divisibility* conditions from the *global* behavior of `n` under exponentiation. We isolate this extraction as a self-contained theorem: if every unit of the residue ring `ℤ/nℤ` satisfies `u^(n−1) = 1` — the universal Fermat condition restricted to coprime bases — then for every prime divisor `p` of `n` one has `(p − 1) ∣ (n − 1)`. The proof proceeds in three movements: (i) transport of the universal Fermat condition along the surjective unit-reduction homomorphism `(ℤ/nℤ)ˣ ↠ (ℤ/pℤ)ˣ`; (ii) the elementary order-divides-exponent principle valid in any monoid; and (iii) the cyclicity of `(ℤ/pℤ)ˣ`, which forces the order of a primitive root to equal `p − 1`. A noteworthy by-product of the formal development is that the squarefreeness hypothesis, customarily quoted as part of Korselt's criterion, is *not* required for this local-divisibility step. We give full statements of all supporting lemmas, complete proof sketches, an algorithmic interpretation as a Carmichael-number recognizer, and a discussion of the broader "transport along a surjection" proof pattern.

**Keywords:** Carmichael numbers, Korselt's criterion, Fermat pseudoprimes, cyclic groups, primitive roots, unit groups, order of an element, primality testing.

**MSC 2020:** 11A51 (primality), 11A07 (congruences; primitive roots), 20K01 (finite abelian groups).

---

## 1. Introduction

### 1.1 Fermat's test and its impostors

Fermat's Little Theorem asserts that for a prime `p` and an integer `a` with `p ∤ a`,
```
a^(p−1) ≡ 1 (mod p).
```
The contrapositive yields a one-sided primality test: if `a^(n−1) ≢ 1 (mod n)` for some base `a` coprime to `n`, then `n` is composite. The test is computationally cheap, but it admits *absolute* counterexamples: composite numbers `n` for which `a^(n−1) ≡ 1 (mod n)` for **every** `a` coprime to `n`. These are the **Carmichael numbers**. The smallest is `561 = 3 · 11 · 17`; the sequence continues `1105, 1729, 2465, 2821, 6601, …`, and Alford, Granville, and Pomerance proved in 1994 that there are infinitely many.

### 1.2 Korselt's criterion

The structural classification is due to A. Korselt (1899):

> **Korselt's criterion.** A composite integer `n > 1` is a Carmichael number if and only if `n` is squarefree and for every prime `p ∣ n` we have `(p − 1) ∣ (n − 1)`.

The criterion replaces an infinite verification (over all coprime bases) by a finite one (over the prime factors of `n`). Its mathematical content splits into two directions. The *converse* (Korselt conditions ⟹ Carmichael) is a Chinese-Remainder-Theorem assembly. The *forward* direction (Carmichael ⟹ Korselt conditions) is where the structural insight lives: it must manufacture the clean divisibility relation `(p − 1) ∣ (n − 1)` from the mere fact that `n` fools Fermat's test universally.

### 1.3 Contribution

We formalize and prove, from first principles against a modern proof-assistant library, the **arithmetic core** of the forward direction:

> **Theorem A (Local divisibility from the universal Fermat condition).**
> Let `n ≥ 1` and let `p` be a prime with `p ∣ n`. If every unit `u ∈ (ℤ/nℤ)ˣ` satisfies `u^(n−1) = 1`, then `(p − 1) ∣ (n − 1)`.

We present Theorem A together with three supporting lemmas, each stated in full generality and proved. The development is entirely constructive at the level of group theory and requires no analytic input. We further observe (Section 6) that **squarefreeness is not used** in the proof of Theorem A, a small but genuine sharpening of the usual presentation.

---

## 2. Preliminaries and notation

Throughout, `n` and `p` are positive integers with `p` prime and `p ∣ n`. We write:

- `ℤ/nℤ` for the ring of integers modulo `n`;
- `(ℤ/nℤ)ˣ` for its **group of units**, i.e. the multiplicative group of residues coprime to `n`. Its order is Euler's totient `φ(n)`;
- `orderOf g` for the **order** of an element `g` of a monoid: the least `k > 0` with `g^k = 1` (and `0` if no such `k` exists, a case that does not arise in a finite group);
- `1` for the multiplicative identity of whichever group is in scope.

We use the following two standard structural facts, both classical:

- **(Reduction homomorphism.)** For `p ∣ n` there is a ring homomorphism `ℤ/nℤ → ℤ/pℤ` given by further reduction, inducing a group homomorphism on units, the **unit-reduction map**
  ```
  reduce : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ.
  ```
- **(Gauss's primitive root theorem.)** For a prime `p`, the group `(ℤ/pℤ)ˣ` is **cyclic** of order `p − 1`.

---

## 3. Supporting lemmas

### 3.1 Order divides any universal exponent

The first lemma is purely monoid-theoretic and isolates the elementary principle that an order divides every exponent annihilating the whole structure.

> **Lemma 1 (Order divides a universal exponent).**
> Let `M` be a monoid and `m ∈ ℕ`. If `g^m = 1` for every `g ∈ M`, then for every `g ∈ M`, `orderOf g ∣ m`.

*Proof sketch.* Fix `g`. By hypothesis `g^m = 1`. The defining universal property of the order of an element states that `orderOf g ∣ m` precisely when `g^m = 1`. Apply it. ∎

The same underlying fact (`g^m = 1 ⟹ orderOf g ∣ m`) is the workhorse; Lemma 1 simply packages it for a hypothesis quantified over all elements, which is exactly the shape produced by the universal Fermat condition.

### 3.2 Homomorphisms contract orders

The second lemma records that group homomorphisms can only shrink (divide) orders. It is not logically required for the streamlined proof of Theorem A but clarifies why transporting the condition is legitimate and is of independent interest.

> **Lemma 2 (Orders divide along homomorphisms).**
> Let `φ : G → H` be a group homomorphism. Then for every `g ∈ G`, `orderOf (φ g) ∣ orderOf g`.

*Proof sketch.* Let `k = orderOf g`, so `g^k = 1`. Then
```
(φ g)^k = φ(g^k) = φ(1) = 1,
```
using that `φ` preserves powers and the identity. By the order-divides-exponent property, `orderOf (φ g) ∣ k`. ∎

### 3.3 Surjectivity of unit reduction

The third lemma is the arithmetic crux that connects the global group to the local one.

> **Lemma 3 (Surjectivity of unit reduction).**
> Let `n ≥ 1` and `p ∣ n`. The unit-reduction homomorphism
> ```
> reduce : (ℤ/nℤ)ˣ → (ℤ/pℤ)ˣ
> ```
> is surjective.

*Proof sketch.* This is the multiplicative content of the Chinese Remainder Theorem. Given a residue `v` coprime to `p`, one must produce an integer `u` coprime to *every* prime power dividing `n` and congruent to `v` modulo `p`. Writing `n = p^a · m` with `gcd(p, m) = 1`, choose `u ≡ v (mod p^a)` (lifting a unit mod `p` to a unit mod `p^a`, possible since the reduction `(ℤ/p^aℤ)ˣ ↠ (ℤ/pℤ)ˣ` is itself surjective) and `u ≡ 1 (mod m)`; such a `u` exists by CRT and is a unit mod `n` mapping to `v`. ∎

In the formal development this is supplied directly by the library's surjectivity result for the canonical units map associated to a divisibility `p ∣ n`.

---

## 4. The main theorem

> **Theorem A (Local divisibility from the universal Fermat condition).**
> Let `n ≥ 1` and let `p` be prime with `p ∣ n`. Suppose
> ```
> (★)   ∀ u ∈ (ℤ/nℤ)ˣ,  u^(n−1) = 1.
> ```
> Then `(p − 1) ∣ (n − 1)`.

### 4.1 Proof

**Movement 1 — Transport (★) to `(ℤ/pℤ)ˣ`.**
We claim every `v ∈ (ℤ/pℤ)ˣ` satisfies `v^(n−1) = 1`. By Lemma 3, `reduce` is surjective, so choose `u ∈ (ℤ/nℤ)ˣ` with `reduce(u) = v`. Since `reduce` is a group homomorphism it preserves powers and the identity, hence
```
v^(n−1) = reduce(u)^(n−1) = reduce(u^(n−1)) = reduce(1) = 1,
```
the third equality by (★). This proves the local universal condition
```
(★ₚ)   ∀ v ∈ (ℤ/pℤ)ˣ,  v^(n−1) = 1.
```

**Movement 2 — Extract an order divisibility.**
Apply Lemma 1 to the finite group `M = (ℤ/pℤ)ˣ` with exponent `m = n − 1`. Condition `(★ₚ)` is exactly the hypothesis of Lemma 1, so for every `g ∈ (ℤ/pℤ)ˣ`,
```
orderOf g ∣ (n − 1).
```

**Movement 3 — Invoke cyclicity.**
By Gauss's theorem, `(ℤ/pℤ)ˣ` is cyclic of order `p − 1`. Cyclicity provides a generator `g` whose order equals the group order; formally, there exists `g` with `orderOf g = |(ℤ/pℤ)ˣ| = p − 1` (using `|(ℤ/pℤ)ˣ| = p − 1`). For this `g`, Movement 2 gives `orderOf g ∣ (n − 1)`, and substituting `orderOf g = p − 1` yields
```
(p − 1) ∣ (n − 1).
```
∎

### 4.2 Remarks on the proof

- **No squarefreeness.** Nowhere did the argument use that `n` is squarefree. The hypothesis `(★)` together with `p ∣ n` suffices. We retain a squarefreeness parameter in the formal interface (to match the conventional statement of Korselt's criterion), but it is provably inert for this step. See Section 6.
- **Where the strength comes from.** The conclusion is `(p − 1) ∣ (n − 1)`, not merely `exponent((ℤ/pℤ)ˣ) ∣ (n − 1)`. The upgrade is supplied entirely by cyclicity: in a cyclic group the exponent equals the order. Without a primitive root, Movement 3 collapses and one obtains only the weaker statement about the group exponent.

---

## 5. Algorithmic interpretation

Theorem A is the soundness lemma behind a finite **Carmichael recognizer**. The classical criterion, read algorithmically, is:

```
function isCarmichael(n):
    if n < 3 or isPrime(n):            return false
    factor n = p₁^a₁ · … · p_k^a_k
    if any aᵢ > 1:                      return false      # not squarefree
    for each prime pᵢ:
        if (n − 1) mod (pᵢ − 1) ≠ 0:    return false      # Korselt local condition
    return true
```

Theorem A guarantees that the **local condition loop is necessary**: any composite that passes the universal Fermat test (equivalently, that is a Carmichael number) must clear every `(pᵢ − 1) ∣ (n − 1)` check. Thus a number failing any single check provably fails the universal Fermat condition — the test is *complete* against Carmichael numbers. The converse direction of Korselt's criterion (CRT assembly) guarantees *soundness*: passing all checks, plus squarefreeness, is sufficient. Together they make the displayed routine an exact recognizer, with cost dominated by factoring `n`.

A second, base-oriented reading: the universal Fermat condition `(★)` is equivalent to `λ(n) ∣ (n − 1)`, where `λ` is the Carmichael function (the exponent of `(ℤ/nℤ)ˣ`). Theorem A is then the implication `λ(n) ∣ (n−1) ⟹ (p−1) ∣ (n−1)`, recovering each local condition from the global exponent condition.

---

## 6. On the redundancy of squarefreeness

We make precise the claim that squarefreeness is unnecessary in Theorem A.

> **Proposition (Inertness of squarefreeness).** The conclusion `(p − 1) ∣ (n − 1)` of Theorem A holds under hypotheses `p ∣ n` and `(★)` alone; adding "`n` squarefree" neither strengthens nor is used by the proof.

*Justification.* Inspect the proof of Theorem A: Movements 1–3 invoke only (i) `p ∣ n` (to obtain `reduce` and its surjectivity, Lemma 3), (ii) `(★)`, and (iii) the cyclicity and order of `(ℤ/pℤ)ˣ`, which depend only on `p` being prime. None of these mention the multiplicity of `p` in `n`. ∎

This does not contradict Korselt's criterion: squarefreeness is genuinely required for the *converse* assembly (a non-squarefree `n` can satisfy all local divisibilities yet fail to be Carmichael, because `(ℤ/p^aℤ)ˣ` for `a ≥ 2` is not annihilated by `p − 1`). The point is simply that the *forward, local-divisibility extraction* — Theorem A — is logically prior to and independent of squarefreeness.

---

## 7. Worked example: `n = 561`

Let `n = 561 = 3 · 11 · 17`, so `n − 1 = 560`. We verify the chain for `p = 17`.

1. `reduce : (ℤ/561ℤ)ˣ ↠ (ℤ/17ℤ)ˣ` is surjective (Lemma 3).
2. Assuming `(★)` for `561` (which holds, as `561` is Carmichael), every `v ∈ (ℤ/17ℤ)ˣ` satisfies `v^560 = 1` (Movement 1).
3. Hence every order in `(ℤ/17ℤ)ˣ` divides `560` (Movement 2).
4. `(ℤ/17ℤ)ˣ` is cyclic of order `16`, with primitive root `g = 3` (indeed `3` has order `16` mod `17`); since `orderOf 3 = 16 ∣ 560` we conclude `16 ∣ 560` (Movement 3). Indeed `560 = 16 · 35`.

The same holds for `p = 3` (`2 ∣ 560`) and `p = 11` (`10 ∣ 560`). Conversely, `15 = 3 · 5` fails: `(5 − 1) = 4 ∤ 14 = 15 − 1`, so `15` cannot be Carmichael — and indeed it is not, e.g. `2^14 = 16384 ≡ 4 ≢ 1 (mod 15)`.

---

## 8. The proof pattern in a wider landscape

Theorem A exemplifies a recurring three-step template:

1. **Transport** a universal hypothesis from a large object to a smaller, better-understood one along a *surjection* (here, unit reduction).
2. **Extract** a divisibility / annihilation statement using a structural invariant (here, order divides exponent).
3. **Sharpen** the extracted statement using special structure of the target (here, cyclicity makes exponent = order).

The same template recurs across mathematics. In algebraic topology, a four-term exact sequence `A → B → C → D` with vanishing ends `A, D` forces the middle map `B → C` to be an isomorphism — *transport* (exactness) plus *sharpening* (vanishing) deliver a rigid conclusion (e.g. `π₃(S²) ≅ ℤ` via the Hopf fibration). In information geometry, local Fisher-metric data is transported and sharpened into global curvature invariants. Recognizing the template is itself a payoff of careful formalization: it reveals that an apparently number-theoretic result shares its skeleton with computations far afield.

---

## 9. Discussion and future work

**Completing Korselt.** Theorem A is the local-extraction half of the forward direction. A complete formal Korselt's criterion additionally requires: (a) the converse CRT assembly; (b) the squarefreeness necessity in the *converse*; and (c) the equivalence between "Carmichael" (all bases, including non-units in the sense `a^n ≡ a`) and the universal unit condition `(★)`. Each is within reach using the same library infrastructure.

**Carmichael function.** Recasting `(★)` as `λ(n) ∣ (n − 1)` and developing the Carmichael function `λ` as the group exponent would let Theorem A be stated as a clean divisibility transfer `λ(n) ∣ (n−1) ⟹ (p−1) ∣ (n−1)` and connect to Lehmer's totient problem and related open questions.

**Quantitative refinements.** Building on the recognizer of Section 5, one can formalize bounds such as Erdős's heuristic for the count of Carmichael numbers up to `x`, or the Alford–Granville–Pomerance infinitude theorem — substantial targets that all rest on the local condition isolated here.

**The order-contraction lemma.** Lemma 2 (orders divide along homomorphisms) is a reusable primitive; it underlies, for instance, the statement that quotient maps cannot increase order, and could anchor a small library on order behavior under morphisms.

---

## 10. Conclusion

We have isolated and rigorously proved the arithmetic heart of Korselt's criterion: the universal Fermat condition on the units of `ℤ/nℤ` forces, for each prime `p ∣ n`, the divisibility `(p − 1) ∣ (n − 1)`. The proof is a clean three-movement argument — transport along the surjective unit reduction, order-divides-exponent, and cyclicity of `(ℤ/pℤ)ˣ` — and, as a small bonus, reveals that the customary squarefreeness hypothesis is inert for this step. Beyond the specific result, the development showcases a transport-and-sharpen template that unifies it with computations in topology and geometry, and it lays a verified foundation on which a complete formalization of Carmichael-number theory can be built.

---

## Appendix: Statements as formalized

For reference, the four results correspond to the following formal statements (variable names lightly normalized):

- **Lemma 1.** `∀ (M : Monoid) (m : ℕ), (∀ g : M, g^m = 1) → ∀ g : M, orderOf g ∣ m`.
- **Lemma 2.** `∀ (φ : G →* H) (g : G), orderOf (φ g) ∣ orderOf g`.
- **Lemma 3.** `∀ {n p : ℕ} [NeZero n] (h : p ∣ n), Function.Surjective (unitReduce h)`, where `unitReduce h : (ℤ/nℤ)ˣ →* (ℤ/pℤ)ˣ`.
- **Theorem A.** `∀ {n : ℕ} [NeZero n] (p : ℕ) [Fact p.Prime], p ∣ n → Squarefree n → (∀ u : (ℤ/nℤ)ˣ, u^(n−1) = 1) → (p − 1) ∣ (n − 1)`, where the `Squarefree n` hypothesis is retained for interface compatibility but is unused.
