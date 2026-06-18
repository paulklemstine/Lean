# The Apparition–Order Bridge: A Local-to-Global Dictionary for Ranks of Apparition in Strong Divisibility Sequences

## Abstract

The **rank of apparition** (or **entry point**) of a prime `p` in an integer
sequence is the least positive index at which `p` divides a term. For strong
divisibility sequences — sequences satisfying `a(0) = 0` and
`gcd(a(m), a(n)) = a(gcd(m, n))` — the entry point is a fundamental
order-theoretic invariant governing the global distribution of a prime across the
sequence. This paper isolates and proves the **representation theorem** for the
Mersenne / repunit family `a(n) = bⁿ − 1`: the entry point of a prime `p ∤ b` is
**equal** to the multiplicative order of `b` in the residue field `ℤ/pℤ`. This is
a local-to-global statement in miniature — a single global, infinite,
order-theoretic invariant is computed by one finite, local group-order in the
residue field. We derive two corollaries: a **support law** identifying the set
of indices divisible by `p` with the principal arithmetic progression generated
by the entry point, and **Fermat descent**, the divisibility
`entryPoint(p) ∣ p − 1`. We specialize the support law to the Fibonacci sequence,
tying the result to the Fibonacci–Carmichael primitive-divisor program. All
results are formalized in the Lean 4 proof assistant atop Mathlib; this paper
gives the mathematics, definitions, statements, and proof sketches in
self-contained form.

**Keywords:** rank of apparition, entry point, strong divisibility sequence,
multiplicative order, Mersenne numbers, Fibonacci numbers, primitive prime
divisors, local-to-global, Fermat's little theorem.

**MSC (informal):** 11B39 (Fibonacci and Lucas numbers), 11A07 (congruences,
primitive roots), 11B83 (special sequences), 11A41 (primes).

---

## 1. Introduction

### 1.1 Background and motivation

Let `a : ℕ → ℕ` be a sequence of natural numbers and `p` a prime. The classical
**rank of apparition** of `p` (terminology going back to Lucas) is the least
`k > 0` with `p ∣ a(k)`, when such a `k` exists. For the Fibonacci sequence and
for the Mersenne/repunit sequences `bⁿ − 1`, the rank of apparition organizes the
entire pattern of divisibility: a prime, once it appears, reappears at regularly
spaced indices, and the spacing is the rank of apparition itself.

This regularity is not a numerical accident. It is a consequence of a single
algebraic axiom — the **strong divisibility** identity — shared by the Fibonacci
sequence, the Mersenne/repunit sequences, and the identity sequence. A companion
development (summarized in §2) shows that the *entire* rank-of-apparition theory
(monotonicity, the meet and join laws, primitive-divisor rigidity, and the
characterization `p ∣ a(n) ↔ entryPoint(p) ∣ n`) is generic over strong
divisibility sequences.

The present paper supplies the missing **local layer** for the Mersenne family.
The abstract theory tells us that the entry point exists and that appearances are
governed by it, but it does not, by itself, tell us *what number the entry point
is*. We prove that for `a(n) = bⁿ − 1` and `p ∤ b`, the entry point is exactly the
multiplicative order of `b` in `ℤ/pℤ`. This is the "stalk computation" that makes
the order-theoretic invariant concretely computable, and it exhibits the
rank-of-apparition theory as a textbook local-to-global phenomenon.

### 1.2 Contributions

1. **The stalk reduction** (Theorem 4.1): for `b ≥ 1` and any `p, n`,
   `p ∣ bⁿ − 1 ⟺ (b mod p)ⁿ = 1` in `ℤ/pℤ`.
2. **The Apparition–Order Bridge** (Theorem 5.1): for a prime `p ∤ b`,
   `entryPoint(bⁿ − 1, p) = orderOf(b mod p)`.
3. **Fermat descent** (Theorem 5.2): `entryPoint(bⁿ − 1, p) ∣ p − 1`.
4. **The support law** (Theorem 3.1) and its **Fibonacci specialization**
   (Theorem 6.1): the set of indices `n` at which `p` divides the term is the
   principal arithmetic progression of multiples of the entry point.

---

## 2. Preliminaries: strong divisibility sequences and the entry point

We recall the abstract framework on which the Bridge rests.

### 2.1 Definition (Strong divisibility sequence)

A **strong divisibility sequence** is a structure consisting of a function
`a : ℕ → ℕ` together with two axioms:

- **(Vanishing)** `a(0) = 0`.
- **(Strong divisibility)** `gcd(a(m), a(n)) = a(gcd(m, n))` for all `m, n ∈ ℕ`.

We write `s` for such a structure and `s.a` for its underlying sequence.

**Examples.**
- **Fibonacci** `fibSDS`: `a(n) = Fₙ`. The axiom is the identity
  `gcd(Fₘ, Fₙ) = F₍gcd(m,n)₎`.
- **Mersenne/repunit** `mersenneSDS(b)`: `a(n) = bⁿ − 1`. The axiom is
  `gcd(bᵐ − 1, bⁿ − 1) = b^(gcd(m,n)) − 1`.
- **Identity** `idSDS`: `a(n) = n`. The axiom is `gcd(m, n) = gcd(m, n)`.

### 2.2 Structural facts (from the axioms alone)

The following are proved generically over `s` and are used below.

- **(Monotonicity)** If `m ∣ n` then `s.a(m) ∣ s.a(n)`. *Proof:* `m ∣ n` gives
  `gcd(m, n) = m`, so `gcd(s.a(m), s.a(n)) = s.a(m)`, whence `s.a(m) ∣ s.a(n)`.
- **(Meet law)** `d ∣ s.a(gcd(m, n)) ⟺ d ∣ s.a(m) ∧ d ∣ s.a(n)`. *Proof:*
  rewrite `s.a(gcd(m, n))` as `gcd(s.a(m), s.a(n))` and use `d ∣ gcd(x, y) ⟺
  d ∣ x ∧ d ∣ y`.

### 2.3 Definition (Primitive divisor and entry point)

A natural number `p` is a **primitive divisor at index `n`**, written
`s.IsPrimitive(p, n)`, if `p ∣ s.a(n)` and `p ∤ s.a(k)` for all `0 < k < n`.

The **entry point** (rank of apparition) of `p` is

```
entryPoint(s, p) = the least k > 0 with p ∣ s.a(k),   if such k exists;
                 = 0,                                  otherwise.
```

When `p` appears at all (i.e. `∃ k > 0, p ∣ s.a(k)`), the entry point is itself a
primitive index: `s.IsPrimitive(p, entryPoint(s, p))`.

### 2.4 The appearance law

The cornerstone of the abstract theory is:

> **Lemma 2.1 (Appearance law).** If `p` appears (`∃ k > 0, p ∣ s.a(k)`), then for
> every `n`,
> ```
> p ∣ s.a(n)  ⟺  entryPoint(s, p) ∣ n.
> ```

*Proof sketch.* (⟸) `entryPoint(s,p) ∣ n` gives `s.a(entryPoint) ∣ s.a(n)` by
monotonicity, and `p ∣ s.a(entryPoint)` by definition. (⟹) If `p ∣ s.a(n)`, then
since also `p ∣ s.a(entryPoint)`, the meet law gives `p ∣ s.a(gcd(entryPoint, n))`.
As `gcd(entryPoint, n) ≤ entryPoint` and the entry point is minimal among positive
indices of apparition, we must have `gcd(entryPoint, n) = entryPoint`, i.e.
`entryPoint ∣ n`. ∎

This is the global, order-theoretic skeleton. The remaining sections add the local
flesh for the Mersenne family.

---

## 3. The support sheaf and its global sections

We package the appearance law as an equality of index sets. View the assignment
`n ↦ { p : p ∣ s.a(n) }` as a "support sheaf" over the additive index semigroup
`(ℕ, +)`. Its *global sections at the prime `p`* are the indices where `p` lives.

### 3.1 Theorem (Support law)

> **Theorem 3.1.** Let `s` be a strong divisibility sequence and `p` a number that
> appears (`∃ k > 0, p ∣ s.a(k)`). Then
> ```
> { n : p ∣ s.a(n) }  =  { n : entryPoint(s, p) ∣ n }.
> ```

That is, the support of `p` is exactly the principal arithmetic progression
generated by the entry point.

*Proof sketch.* Pointwise this is Lemma 2.1; extensionality of sets repackages
the biconditional `p ∣ s.a(n) ⟺ entryPoint(s, p) ∣ n` as the asserted set
equality. ∎

This is the "global sections" description that makes precise the slogan from the
companion arc: a prime, once it appears, reappears at exactly the multiples of its
entry point.

---

## 4. The stalk reduction

To compute the entry point for the Mersenne family we descend to the residue field
`ℤ/pℤ`. The bridge between divisibility of integers and equations in the residue
field is the following reduction.

### 4.1 Theorem (Stalk reduction)

> **Theorem 4.1.** Let `b ≥ 1`, let `p` be a positive modulus, and let `n ∈ ℕ`.
> Then, in the ring `ℤ/pℤ`,
> ```
> p ∣ bⁿ − 1   ⟺   (b mod p)ⁿ = 1.
> ```

*Proof sketch.* Since `b ≥ 1` we have `bⁿ ≥ 1`, so `bⁿ − 1` is a genuine
(non-truncated) natural subtraction. Reduce modulo `p`: `p ∣ bⁿ − 1` is equivalent
to the cast `(bⁿ − 1 mod p) = 0`. By compatibility of the natural-number cast with
honest subtraction, this cast equals `(b mod p)ⁿ − 1`. Hence the condition is
`(b mod p)ⁿ − 1 = 0`, i.e. `(b mod p)ⁿ = 1`. ∎

The hypothesis `b ≥ 1` is exactly what guarantees the subtraction `bⁿ − 1` is
honest in ℕ; this is the only fine print in the entire development. In the Bridge
below the relevant case is `p ∤ b`, which forces `b ≠ 0` (since `p ∣ 0`), so no
extra hypothesis is needed there.

---

## 5. The Apparition–Order Bridge

We now assemble the global appearance law (Lemma 2.1), the stalk reduction
(Theorem 4.1), and the definition of multiplicative order into the representation
theorem.

### 5.1 Theorem (Apparition–Order Bridge)

> **Theorem 5.1.** Let `p` be prime and `b ∈ ℕ` with `p ∤ b`. Then, in the residue
> field `ℤ/pℤ`,
> ```
> entryPoint(mersenneSDS(b), p)  =  orderOf(b mod p).
> ```

*Proof sketch.* We show the two natural numbers have identical sets of multiples;
two naturals with the same multiples are equal. Fix `n`. Then:

```
entryPoint(mersenneSDS(b), p) ∣ n
   ⟺  p ∣ bⁿ − 1                       (appearance law, Lemma 2.1)
   ⟺  (b mod p)ⁿ = 1                   (stalk reduction, Theorem 4.1)
   ⟺  orderOf(b mod p) ∣ n             (definition of multiplicative order).
```

The first equivalence needs `p` to appear at all in `mersenneSDS(b)`; this is
witnessed by `n = p − 1`, because Fermat's little theorem gives
`(b mod p)^(p−1) = 1` (here `b mod p ≠ 0` since `p ∤ b`), so by the stalk reduction
`p ∣ b^(p−1) − 1` with `p − 1 > 0`. The third equivalence is the defining property
of `orderOf`. Chaining the three equivalences shows the two numbers divide exactly
the same `n`, hence by antisymmetry of divisibility they are equal. ∎

**Remark (formalization detail).** In the Lean development the equality is proved
by `le_antisymm`, establishing each of the two divisibilities `entryPoint ∣ order`
and `order ∣ entryPoint` and converting to inequalities via `Nat.le_of_dvd` (both
quantities are positive: `entryPoint > 0` because `p` appears, and `order > 0`
because `b mod p` is a nonzero element of the finite field). The direction
`order ∣ entryPoint` uses that `p ∣ b^(entryPoint) − 1` (entry point is primitive),
reduced by Theorem 4.1 to `(b mod p)^(entryPoint) = 1`, which forces
`order ∣ entryPoint`. The direction `entryPoint ∣ order` uses
`(b mod p)^(order) = 1` and the stalk reduction in reverse, then the appearance
law.

### 5.2 Theorem (Fermat descent)

> **Theorem 5.2.** Let `p` be prime and `b ∈ ℕ` with `p ∤ b`. Then
> ```
> entryPoint(mersenneSDS(b), p)  ∣  p − 1.
> ```

*Proof sketch.* By Theorem 5.1 the entry point equals `orderOf(b mod p)`. The
multiplicative order of any nonzero element of `ℤ/pℤ` divides the order of the
group of units `(ℤ/pℤ)ˣ`, which is `p − 1`. Concretely, Fermat's little theorem
gives `(b mod p)^(p−1) = 1`, and the order divides any exponent that returns the
element to 1; hence `orderOf(b mod p) ∣ p − 1`. ∎

This is the local "speed limit": the rank of apparition never exceeds `p − 1` and
in fact divides it, recovering the classical bound used throughout primality
testing and primitive-divisor theory.

---

## 6. Fibonacci specialization (catalog gluing)

The support law of §3 is generic; specializing it to `fibSDS` recovers the
global-section form of the Fibonacci rank-of-apparition law.

### 6.1 Theorem (Fibonacci support law)

> **Theorem 6.1.** Let `p` appear in the Fibonacci sequence
> (`∃ k > 0, p ∣ Fₖ`). Then
> ```
> { n : p ∣ Fₙ }  =  { n : entryPoint(fibSDS, p) ∣ n }.
> ```

*Proof sketch.* Direct specialization of Theorem 3.1 to `s = fibSDS`, whose
underlying sequence is `Nat.fib`. ∎

This is the global-section form of the rank-of-apparition law underlying the
Fibonacci–Carmichael primitive-divisor program: a prime divides `Fₙ` precisely on
the multiples of its Fibonacci entry point. (Unlike the Mersenne case there is no
single closed-form "order" in a field of residues for the Fibonacci entry point;
the Bridge of §5 is special to the multiplicative family `bⁿ − 1`.)

---

## 7. Worked examples

**Example 7.1 (base 2, prime 7).** Powers of 2 modulo 7 are `2, 4, 1, 2, 4, 1, …`,
so `orderOf(2 mod 7) = 3`. By Theorem 5.1, `entryPoint(2ⁿ − 1, 7) = 3`: indeed 7
divides `2³ − 1 = 7`, `2⁶ − 1 = 63`, `2⁹ − 1 = 511`, and no other terms. Theorem
5.2 predicts `3 ∣ 7 − 1 = 6`. ✓

**Example 7.2 (base 2, prime 23).** Powers of 2 modulo 23: the order of 2 is 11
(`2¹¹ = 2048 = 1 mod 23`). So `entryPoint(2ⁿ − 1, 23) = 11`, and `11 ∣ 23 − 1 =
22`. ✓ This is the classical fact that 23 first divides a Mersenne number at
exponent 11 (`2¹¹ − 1 = 2047 = 23 × 89`).

**Example 7.3 (base 10, prime 7 — repunits).** `10ⁿ − 1 = 9 × Rₙ` where
`Rₙ = 11…1` is the `n`-th repunit. The order of 10 modulo 7 is 6, so 7 first
divides `10ⁿ − 1` (equivalently divides `Rₙ`) at `n = 6` — the famous fact that
`1/7 = 0.142857…` has period 6. ✓

**Example 7.4 (Fibonacci, prime 11).** 11 divides `F₁₀ = 55` and reappears at
`F₂₀, F₃₀, …`. By Theorem 6.1 the support of 11 is the multiples of its entry
point 10. ✓

---

## 8. Algorithms

### 8.1 Computing the entry point via the order

The Bridge yields an efficient algorithm. Instead of generating the (rapidly
exploding) integers `bⁿ − 1`, work modulo `p`.

```
function MersenneEntryPoint(b, p):           # p prime, p ∤ b
    require p prime and (b mod p) ≠ 0
    x ← b mod p
    acc ← x
    k ← 1
    while acc ≠ 1:
        acc ← (acc · x) mod p
        k ← k + 1
    return k                                  # = orderOf(b mod p) = entry point
```

Complexity: `O(entryPoint · log p)` arithmetic on numbers `< p²`. By Fermat
descent (Theorem 5.2) the loop runs at most `p − 1` times; with divisor-enumeration
over `p − 1` one obtains an `O(d(p−1) · log² p)`-style refinement (test each divisor
`d` of `p − 1` for `xᵈ = 1` via fast exponentiation and return the least).

### 8.2 Support enumeration

By the support law (Theorem 3.1 / 6.1), once the entry point `e` is known, the set
of indices `n ≤ N` with `p ∣ a(n)` is simply `{e, 2e, 3e, …} ∩ [1, N]`, computable
in `O(N / e)` without any divisibility tests.

---

## 9. Applications

- **Primality testing and large-prime search.** Mersenne primes `2ᵖ − 1` are the
  largest known primes; trial division by small primes `q` is governed by whether
  `p` is a multiple of `entryPoint(2ⁿ − 1, q) = orderOf(2 mod q)`. The Bridge turns
  a question about an astronomically large integer into a clock computation.
- **Cryptography.** The multiplicative order modulo a prime is the central security
  parameter in Diffie–Hellman and discrete-log systems; the Bridge identifies it
  with the rank of apparition, so structural results transfer between the two
  viewpoints.
- **Primitive prime divisors (Bang/Carmichael/Zsygmondy).** A prime `q` is a
  primitive divisor of `bⁿ − 1` iff `entryPoint(q) = n`, i.e. `orderOf(b mod q) =
  n`. The Bridge is the computational and conceptual backbone of these classical
  existence theorems, and the support law shows their "appearances are periodic"
  structure.

---

## 10. Discussion

The Apparition–Order Bridge exhibits the rank-of-apparition theory as a
local-to-global program in miniature. The global object — the support sheaf
`n ↦ { p : p ∣ a(n) }` over the additive index semigroup — is, at each prime
stalk, completely determined by a single local datum: the multiplicative order of
`b` in the residue field. The dictionary is the composite

```
(global) appearance law  ∘  (local) orderOf characterization,
```

glued by the natural-cast stalk reduction. Two divisors with identical
multiples-sets are equal, which is what pins `entryPoint = orderOf`.

The abstraction to strong divisibility sequences is what makes this clean: the
global half of the argument never mentions powers or golden ratios, only the two
structural axioms. The Mersenne family then admits an extra, multiplicative
local structure (a residue *field* with a cyclic unit group), and it is exactly
this extra structure that produces the closed-form `orderOf`. The Fibonacci family
shares the global half (Theorem 6.1) but not the local closed form, which is why
its entry point, while equally well-defined and equally periodic, has no analogous
single-field order formula.

---

## 11. Future directions

(Provided by the antecedent development; reproduced for context.)

The Carmichael arc aims to prove that every Fibonacci number `F(n)` with `n ≥ 13`
carries a *primitive prime divisor*. The prime-index case is, on inspection, not a
Fibonacci fact at all but a fact about *every strong divisibility sequence
normalized by `u(1) = 1`*: a prime `q ∣ u(p)` has rank dividing the prime `p`, and
the rank cannot be 1 (else `q ∣ u(1) = 1`), so the rank equals `p` and `q` is
primitive. The same one-line engine call yields both the Fibonacci/Carmichael
prime case and Bang's theorem at prime exponents (`2ᵖ − 1` has a primitive prime
divisor). What remains genuinely open is the *composite* case for large `n`, where
the "every prime divisor is automatically primitive" phenomenon breaks: a prime
dividing `u(mk)` may have rank a proper divisor of `mk`. This is the true content
of Carmichael/Zsygmondy and the spine of the next cycle.

---

## 12. Summary of results

| # | Result | Statement |
|---|--------|-----------|
| Thm 3.1 | Support law | `{n : p ∣ s.a(n)} = {n : entryPoint(s,p) ∣ n}` (p appears) |
| Thm 4.1 | Stalk reduction | `p ∣ bⁿ − 1 ⟺ (b mod p)ⁿ = 1` (b ≥ 1) |
| Thm 5.1 | Apparition–Order Bridge | `entryPoint(bⁿ − 1, p) = orderOf(b mod p)` (p prime, p ∤ b) |
| Thm 5.2 | Fermat descent | `entryPoint(bⁿ − 1, p) ∣ p − 1` (p prime, p ∤ b) |
| Thm 6.1 | Fibonacci support law | `{n : p ∣ Fₙ} = {n : entryPoint(fibSDS,p) ∣ n}` (p appears) |

All statements are formalized and machine-checked. The mathematics requires only
elementary number theory (gcd identities, Fermat's little theorem) and the basic
theory of multiplicative order in finite fields.
