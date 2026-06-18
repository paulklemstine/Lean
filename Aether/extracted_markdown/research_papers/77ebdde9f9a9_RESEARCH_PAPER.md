# Entry Points of Strong Divisibility Sequences: A Structural Unification of Fibonacci and Mersenne Primitive-Divisor Theory

## Abstract

The *entry point* (or *rank of apparition*) of a prime `p` in an integer
sequence `a : ℕ → ℕ` is the least index `k > 0` such that `p ∣ a(k)`. For the
Fibonacci sequence this object is the classical engine behind Carmichael's
primitive-divisor theorem; for the sequences `b^n − 1` it underlies the
Bang–Zsygmondy theorem. We isolate the single algebraic property responsible for
the entire entry-point calculus — **strong divisibility**, the identity
`a(gcd(m, n)) = gcd(a(m), a(n))` — and rebuild the theory over it from scratch.
Working only from this hypothesis (and, where boundary behaviour matters, the
normalization `a(0) = 0`), we prove the divisibility bridge
`p ∣ a(n) ⇔ z(p) ∣ n`, the primitivity characterization `IsPrimitive(p, n) ⇔
z(p) = n`, uniqueness of the index at which a prime is primitive, a join law
expressing simultaneous appearance through the least common multiple of entry
points, its finite-family generalization, and exact counting/density formulas for
appearance indices. The Fibonacci and Mersenne theories then become *instances of
a single development*, verified by checking one gcd identity each
(`gcd(F(m), F(n)) = F(gcd(m, n))` and `gcd(b^m − 1, b^n − 1) = b^{gcd(m,n)} − 1`).
As a corollary the join law yields a genuinely new "simultaneous apparition"
statement for the Mersenne family at no additional cost. The development is fully
formalized and machine-checked; here we present the mathematics, with proof
sketches in place of formal scripts.

**Keywords:** rank of apparition, entry point, strong divisibility sequence,
primitive divisor, Fibonacci numbers, Mersenne numbers, Carmichael's theorem,
Bang–Zsygmondy theorem, divisibility lattice.

---

## 1. Introduction

### 1.1 Two classical patterns

Two well-studied integer families exhibit a strikingly parallel divisibility
behaviour. For the Fibonacci numbers `F(1)=1, F(2)=1, F(3)=2, …`, a prime `p`
that divides some `F(k)` first does so at a uniquely determined index `z(p)`, and
thereafter divides `F(n)` exactly when `z(p) ∣ n`. For the Mersenne-type numbers
`M_b(n) = b^n − 1` the same is true: each prime `p ∤ b` has a least index `z(p)`
(its multiplicative order considerations notwithstanding) such that `p ∣ M_b(n)`
iff `z(p) ∣ n`.

These statements are usually proved by family-specific means: the Fibonacci case
via the Lucas/Binet apparatus and properties of `gcd(F(m), F(n))`, the Mersenne
case via the order of `b` in `(ℤ/pℤ)^×`. The parallelism begs for a common cause.

### 1.2 The unifying hypothesis

We extract the operative property as the following definition.

> **Definition (strong divisibility sequence).** A sequence `a : ℕ → ℕ` is a
> *strong divisibility sequence* if
> `a(gcd(m, n)) = gcd(a(m), a(n))` for all `m, n ∈ ℕ`.

Equivalently, `a` is a morphism of meet-semilattices from `(ℕ, gcd)` to `(ℕ, gcd)`.
Both motivating families satisfy it (Section 5), and we show in Sections 2–4 that
*every* component of the entry-point theory is a logical consequence of this one
hypothesis. The result is a single, reusable calculus; the classical Fibonacci
and Mersenne theorems are recovered by instantiation, and at least one new
theorem (the Mersenne join law) emerges for free.

### 1.3 Contributions

1. A self-contained, hypothesis-minimal theory of entry points: the divisibility
   bridge, primitivity characterization, uniqueness, join law, finite-family join
   law, and density formulas, each derived from strong divisibility alone.
2. A clean conceptual identification: *a primitive divisor of `a(n)` is exactly a
   prime whose entry point equals `n`* — primitivity is "maximal order" in the
   pulled-back divisor lattice.
3. Instantiation to `Nat.fib` and `b^n − 1` (and the trivial identity sequence),
   recovering the Fibonacci primitive-divisor theory and producing a new Mersenne
   simultaneous-apparition theorem.
4. A precise localization of what strong divisibility *cannot* deliver — the
   *existence* of primitive divisors — and why (it is the only place sequence
   growth enters), framing the remaining open problems.

All results are formalized and machine-verified with no remaining gaps; the
statements below are exactly those proved, with informal proof sketches.

---

## 2. The strong divisibility law and its immediate consequences

Throughout, `a : ℕ → ℕ` is a strong divisibility sequence, i.e.
`a(gcd(m, n)) = gcd(a(m), a(n))` for all `m, n`. We write `x ∣ y` for "x divides
y" and `gcd`, `lcm` for the usual operations on `ℕ`.

### 2.1 Weak divisibility (monotonicity)

> **Lemma 2.1 (index divisibility implies value divisibility).**
> If `m ∣ n` then `a(m) ∣ a(n)`.

*Proof sketch.* If `m ∣ n` then `gcd(m, n) = m`. Substituting into the strong
divisibility identity gives `a(m) = gcd(a(m), a(n))`, and the gcd of two numbers
divides the second, so `a(m) ∣ a(n)`. ∎

Lemma 2.1 is the familiar "divisibility sequence" property; it is a strictly
weaker statement than strong divisibility, recovered here as a one-line corollary.

### 2.2 The meet law for arbitrary divisors

> **Lemma 2.2 (meet law).** For every `d, m, n ∈ ℕ`,
> `d ∣ a(gcd(m, n)) ⇔ (d ∣ a(m) ∧ d ∣ a(n))`.

*Proof sketch.* Rewrite `a(gcd(m, n))` as `gcd(a(m), a(n))` by the hypothesis,
then apply the standard fact `d ∣ gcd(x, y) ⇔ d ∣ x ∧ d ∣ y`. ∎

Specializing `d = p` a prime gives the **gcd bridge**: if `p ∣ a(m)` and
`p ∣ a(n)`, then `p ∣ a(gcd(m, n))`. This is the workhorse of Section 3.

---

## 3. Entry points and the divisibility bridge

### 3.1 Definition

> **Definition (entry point).** For `p ∈ ℕ` such that `p ∣ a(k)` for some `k > 0`,
> the *entry point* (rank of apparition) is
> `z(p) = min { k > 0 : p ∣ a(k) }`.
> When no such `k` exists we set `z(p) = 0` by convention.

The well-definedness of the minimum is the least-number principle: the set
`{ k > 0 : p ∣ a(k) }`, when nonempty, has a least element. We record three
defining facts.

> **Lemma 3.1 (entry-point package).** If `∃ k > 0, p ∣ a(k)`, then:
> (i) `z(p) > 0`; (ii) `p ∣ a(z(p))`; (iii) for all `m` with `0 < m < z(p)`,
> `p ∤ a(m)`.

*Proof sketch.* All three are immediate from the characterization of the least
element: it lies in the set (giving (i), (ii)) and nothing strictly smaller and
positive does (giving (iii)). ∎

### 3.2 The master theorem

> **Theorem 3.2 (divisibility bridge).** Suppose `∃ k > 0, p ∣ a(k)`. Then for
> all `n`,
> `p ∣ a(n) ⇔ z(p) ∣ n`.

*Proof sketch.*
(⇐) If `z(p) ∣ n`, then `a(z(p)) ∣ a(n)` by Lemma 2.1, and `p ∣ a(z(p))` by
Lemma 3.1(ii), so `p ∣ a(n)` by transitivity.

(⇒) Suppose `p ∣ a(n)` but, for contradiction, `z(p) ∤ n`. Let `g = gcd(z(p), n)`.
Since `g ∣ z(p)` we have `g ≤ z(p)`; and `z(p) ∤ n` forces `g ≠ z(p)`, hence
`g < z(p)`. Also `g > 0` (as `z(p) > 0`). Now `p ∣ a(z(p))` and `p ∣ a(n)`, so by
the gcd bridge (Lemma 2.2 with `d = p`) `p ∣ a(g)`. This contradicts the
minimality clause Lemma 3.1(iii), which forbids `p ∣ a(m)` for `0 < m < z(p)`.
Therefore `z(p) ∣ n`. ∎

Theorem 3.2 is the entire content of the two opening observations: the infinite
divisibility pattern of any prime is governed by the single integer `z(p)`.

---

## 4. Primitivity, uniqueness, and joint apparition

### 4.1 Primitive divisors as maximal entry points

> **Definition (primitive divisor).** `p` is a *primitive divisor* of `a(n)`,
> written `IsPrimitive(p, n)`, if `p ∣ a(n)` and `p ∤ a(k)` for all `k` with
> `0 < k < n`.

> **Theorem 4.1 (primitivity = maximal order).** Suppose `∃ k > 0, p ∣ a(k)` and
> `n > 0`. Then `IsPrimitive(p, n) ⇔ z(p) = n`.

*Proof sketch.*
(⇒) Assume `IsPrimitive(p, n)`. Since `p ∣ a(n)` and `n > 0`, the minimality of
`z(p)` gives `z(p) ≤ n`. If `z(p) < n`, then primitivity at `n` would forbid
`p ∣ a(z(p))`, contradicting Lemma 3.1(ii); hence `z(p) = n`.
(⇐) Assume `z(p) = n`. Then `p ∣ a(z(p)) = a(n)` by Lemma 3.1(ii), and for any
`k` with `0 < k < n = z(p)`, Lemma 3.1(iii) gives `p ∤ a(k)`. So
`IsPrimitive(p, n)`. ∎

Notably the (⇒) direction requires *no* strong divisibility hypothesis: it is a
statement about the entry point alone. Primitivity is thus an order-theoretic
notion — "the prime appears here first and not before" — and strong divisibility
enters only to relate it to the divisibility lattice via Theorem 3.2.

### 4.2 Uniqueness

> **Theorem 4.2 (uniqueness of primitivity index).** If `m, n > 0`,
> `IsPrimitive(p, m)`, and `IsPrimitive(p, n)`, then `m = n`.

*Proof sketch.* Without loss of generality suppose `m < n`. Primitivity at `n`
forbids `p ∣ a(m)`, while primitivity at `m` asserts `p ∣ a(m)` — a direct
contradiction. Hence `m = n`. (No structural hypothesis is used; this is pure
minimality.) ∎

Equivalently: a prime is a primitive divisor of at most one term, namely the term
at its entry point. This is consistent with — and follows again from —
Theorem 4.1, since `z(p)` is a single number.

### 4.3 The join law

> **Theorem 4.3 (simultaneous apparition).** Let `a', b' > 0`, let `p` be a
> primitive divisor of `a(a')` and `q` a primitive divisor of `a(b')`. Then for
> all `n`,
> `(p ∣ a(n) ∧ q ∣ a(n)) ⇔ lcm(a', b') ∣ n`.

*Proof sketch.* By Theorem 4.1 (or directly via the pinning corollary of
Theorem 3.2), `p ∣ a(n) ⇔ a' ∣ n` and `q ∣ a(n) ⇔ b' ∣ n`. Hence both hold iff
`a' ∣ n` and `b' ∣ n`, which by the universal property of the least common
multiple is equivalent to `lcm(a', b') ∣ n`. ∎

> **Theorem 4.4 (finite-family join law).** Let `t` be a finite index set, `f, g`
> functions with `g(i) > 0` and `f(i)` a primitive divisor of `a(g(i))` for each
> `i ∈ t`. Then for all `n`,
> `(∀ i ∈ t, f(i) ∣ a(n)) ⇔ (lcm_{i ∈ t} g(i)) ∣ n`.

*Proof sketch.* Induction on the finite set. The empty case reduces to
`1 ∣ n`. The insertion step combines the single-index pinning with
`lcm(x, S) ∣ n ⇔ x ∣ n ∧ S ∣ n`. ∎

### 4.4 Counting and density

The join structure has an exact arithmetic-density face. Throughout, indices are
shifted by one so that index `0` (at which everything divides `a(0) = 0`) is
excluded; `⌊·⌋` denotes integer division.

> **Theorem 4.5 (apparition count).** If `n > 0` and `p` is a primitive divisor
> of `a(n)`, then for every `N`,
> `#{ e ∈ {0, …, N−1} : p ∣ a(e + 1) } = ⌊N / n⌋`.

*Proof sketch.* By the pinning corollary of Theorem 3.2, `p ∣ a(e+1) ⇔ n ∣ (e+1)`,
so the count equals the number of multiples of `n` in `{1, …, N}`, which is
`⌊N/n⌋`. ∎

In particular, appearance indices of a prime with entry point `n` have natural
density exactly `1/n`.

> **Theorem 4.6 (joint apparition count).** With `p, q` primitive for `a(a')`,
> `a(b')` respectively (`a', b' > 0`),
> `#{ e ∈ {0, …, N−1} : p ∣ a(e+1) ∧ q ∣ a(e+1) } = ⌊N / lcm(a', b')⌋`.

*Proof sketch.* Theorem 4.3 rewrites the joint predicate as `lcm(a', b') ∣ (e+1)`;
count the multiples as before. ∎

Thus joint appearances have density `1/lcm(a', b')` — the analytic shadow of the
join law.

---

## 5. Instances

We exhibit the framework's reach by verifying the single hypothesis for three
sequences. Each verification is short and classical; all theorems of Sections 2–4
then transfer automatically.

### 5.1 Fibonacci

> **Proposition 5.1.** `Nat.fib` is a strong divisibility sequence:
> `gcd(F(m), F(n)) = F(gcd(m, n))`.

This is the classical Fibonacci gcd identity (`Nat.fib_gcd`), together with
`F(0) = 0`. Consequently every result of Sections 2–4 specializes to Fibonacci.
In particular:

- **(Theorem 3.2)** `p ∣ F(n) ⇔ z(p) ∣ n` — the rank-of-apparition law.
- **(Theorem 4.1)** `p` is a primitive divisor of `F(n) ⇔ z(p) = n`.
- **(Theorem 4.3)** For primitive divisors `p` of `F(a')` and `q` of `F(b')`,
  `(p ∣ F(n) ∧ q ∣ F(n)) ⇔ lcm(a', b') ∣ n`.

The third is exactly the Fibonacci "simultaneous apparition" theorem, recovered
as an instance.

### 5.2 Mersenne / repunit numbers

> **Proposition 5.2.** For every base `b`, the sequence `n ↦ b^n − 1` is a strong
> divisibility sequence: `gcd(b^m − 1, b^n − 1) = b^{gcd(m, n)} − 1`.

This is the classical identity (`Nat.pow_sub_one_gcd_pow_sub_one`), with the
boundary value `b^0 − 1 = 0`. The framework then yields, *for free*, the Mersenne
analogues of every theorem, including a statement with no prior bespoke proof in
the development:

> **Corollary 5.3 (Mersenne join law).** Fix `b`. Let `a', b' > 0`, let `p` be a
> primitive divisor of `b^{a'} − 1` and `q` of `b^{b'} − 1`. Then for all `n`,
> `(p ∣ b^n − 1 ∧ q ∣ b^n − 1) ⇔ lcm(a', b') ∣ n`.

This is a Zsygmondy-flavoured simultaneous-apparition statement obtained purely by
instantiation of Theorem 4.3.

### 5.3 The identity sequence

> **Proposition 5.4.** `n ↦ n` is (trivially) a strong divisibility sequence:
> `gcd(m, n) = gcd(m, n)`.

Here the framework degenerates: the entry point of a prime `p` is `p` itself, and
Theorem 3.2 reads `p ∣ n ⇔ p ∣ n`. This confirms that ordinary divisibility is
the simplest special case of the theory, a useful sanity check.

---

## 6. Algorithmic content

The theory is constructive enough to drive direct computation.

**Computing an entry point.** Given a sequence oracle `a(·)` and a prime `p` known
to divide some term, `z(p)` is found by scanning `k = 1, 2, 3, …` until
`p ∣ a(k)`. By Theorem 3.2 the scan is guaranteed to terminate at `z(p)`, after
which the *entire* divisibility set `{ n : p ∣ a(n) }` is the set of multiples of
`z(p)` — no further sequence evaluation is needed.

**Deciding divisibility in O(1) sequence calls.** To decide `p ∣ a(n)` for many
values of `n`, compute `z(p)` once, then answer each query by the single test
`z(p) ∣ n`. This converts an a-priori unbounded search into one modular check.

**Detecting primitivity.** To test whether `p` is primitive for `a(n)`, compute
`z(p)` and compare with `n` (Theorem 4.1). Equivalently, verify `p ∣ a(n)` and
`p ∤ a(d)` for the proper divisors `d` of `n` — but Theorem 3.2 shows the latter
reduces to checking `z(p) = n`.

**Joint and density queries.** Theorems 4.3–4.6 turn questions about the
simultaneous appearance of several primes, and about counting appearance indices
up to `N`, into lcm computations and a single integer division `⌊N / lcm⌋`.

---

## 7. Applications

- **Fibonacci entry points and Carmichael's theorem.** The framework supplies the
  complete "where does a prime live" half of Carmichael's primitive-divisor
  theorem for Fibonacci numbers, reducing the theorem to the existence of a prime
  with `z(p) = n` (Section 8).
- **Mersenne numbers and Bang–Zsygmondy.** Identically, the framework gives the
  positional theory for `b^n − 1`, isolating Bang–Zsygmondy as the existence
  statement `∃ p, z(p) = n` for `n` outside a finite set.
- **Repunit and cyclotomic-type sequences.** Any sequence passing the gcd test —
  including base-`b` repunits `(b^n − 1)/(b − 1)` in suitable normalizations —
  inherits the entire calculus.
- **Density heuristics.** Theorems 4.5–4.6 give exact finite-`N` counts (not just
  asymptotics) for appearance and joint-appearance indices, useful in sieving and
  in primality-test design where one needs the frequency of small prime factors.

---

## 8. Discussion: what strong divisibility cannot see

The framework is deliberately *structural*: it determines where a prime appears
once it appears, but is silent on whether genuinely new primes appear at all. The
existence of a primitive divisor of `a(n)` — equivalently a prime with `z(p) = n`
— is the content of Carmichael's theorem (Fibonacci) and Bang–Zsygmondy
(`b^n − 1`), and it provably *cannot* follow from strong divisibility alone: the
hypothesis is invariant under reindexing tricks that preserve gcd structure but
destroy growth, and existence of primitive divisors fails for sequences with
insufficient growth (e.g., bounded or slowly-growing strong divisibility
sequences). The missing ingredient is a *size* estimate:

- Fibonacci numbers satisfy `F(n) ≈ φ^n / √5` (golden-ratio growth);
- Mersenne numbers satisfy `b^n − 1 ≈ b^n` (exponential growth).

A counting/telescoping argument then shows that the "non-primitive part" of
`a(n)` — the contribution of primes whose entry points are proper divisors of `n`
— divides a product over proper divisors `d ∣ n`, and growth forces a genuine
excess, i.e. a primitive prime, for all large `n`. The clean separation achieved
here — *structure* (this paper, complete) versus *growth* (open in general) — is
itself a contribution: it tells the prospective prover of an existence theorem
exactly which single quantitative input must be supplied, and that nothing else
about the family matters.

---

## 9. Future work

1. **A growth-augmented framework.** Add to "strong divisibility sequence" a
   single quantitative field — an effective bound asserting that `a(n)` outgrows
   the product of its intrinsic divisors — and prove a *family-independent*
   existence theorem: for all `n` outside an explicit finite set, `a(n)` has a
   prime with `z(p) = n`. Specializing the growth field to `Nat.fib` recovers
   Carmichael; specializing to `b^n − 1` recovers Bang–Zsygmondy. The positional
   half proven here is the input such a theorem consumes.

2. **Cyclotomic/Möbius primitive part.** Study `Φ_n = ∏_{d ∣ n} a(d)^{μ(n/d)}`,
   the Möbius "primitive part." Theorem 3.2 already forces every non-primitive
   prime factor of `a(n)` to have entry point a *proper* divisor of `n`; combined
   with a growth estimate, `Φ_n` should carry a primitive prime past an explicit
   threshold.

3. **Lucas sequences.** Every nondegenerate Lucas sequence `U_n(P, Q)` with
   `gcd(P, Q) = 1` is a strong divisibility sequence, so the present theory
   transfers verbatim; the existence/exceptional-set question becomes a finite,
   computable problem depending only on `(P, Q)`.

4. **A uniform Zsygmondy statement for `a^n − b^n`.** For coprime `a > b ≥ 1`,
   `a^n − b^n` is strong-divisibility-like and the entry point is the
   multiplicative order of `a/b` mod `p`. The same "primitivity = maximal order"
   identification frames Bang–Zsygmondy in exactly the language of Theorem 4.1.

5. **Density refinements.** Promote the exact finite-`N` counts (Theorems 4.5–4.6)
   to asymptotic laws for the *prime* entry-point distribution `#{ p ≤ x :
   z(p) = n }`, connecting to Artin-type primitive-root problems via the
   multiplicative-order interpretation of entry points.

---

## 10. Conclusion

A single semilattice identity — `a(gcd(m, n)) = gcd(a(m), a(n))` — supports the
complete positional theory of prime appearances: the divisibility bridge, the
identification of primitivity with maximal entry point, uniqueness, the lcm join
law and its finite-family form, and exact appearance densities. Fibonacci and
Mersenne primitive-divisor theory cease to be separate subjects and become two
instances of one development, with new statements (the Mersenne join law)
appearing for free. What remains genuinely open — the *existence* of primitive
divisors — is precisely and only the analytic question of growth, now cleanly
quarantined from the structural theory that this work completes.
