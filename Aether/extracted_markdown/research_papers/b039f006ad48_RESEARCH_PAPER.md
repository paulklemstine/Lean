# Conserved Quantities along Reduction Paths: A Unified Length Functional for Cryptographic Hybrids and Fibonacci Divisibility

## Abstract

We identify a single mathematical structure underlying two superficially
unrelated theories: the quantitative calculus of cryptographic security
reductions (the hybrid argument and reduction composition) and the
primitive-divisor (Carmichael) argument for Fibonacci numbers. In both cases the
governing object is a **non-negative length/valuation functional on a discrete
path**, together with the morphisms that conserve or contract it. On the
cryptographic side this functional is *path length* in a pseudo-metric space
whose points are games and whose distance is distinguishing advantage; the
hybrid argument is the iterated triangle inequality, reduction composition is
Lipschitz contraction, and the advantage-loss factor is a Lipschitz constant. On
the number-theoretic side the functional is the gcd-valuation of the Fibonacci
map, whose defining conservation law `gcd(F(m), F(n)) = F(gcd(m, n))` is the
homotopy-invariant heart of the primitive-divisor argument. We state and prove
six results making this precise: a generalized endpoint bound, a concatenation
additivity law, a Lipschitz path-contraction theorem (which subsumes both the
additive hybrid bound and the multiplicative composition law), an end-to-end
reduction estimate, the Fibonacci gcd-conservation law, and a clean
self-contained "primitivity bridge" lemma. A notable byproduct is that the
Lipschitz contraction theorem requires no sign hypothesis on the Lipschitz
constant, making it strictly more general than its motivation demands. All
results are fully formalized and machine-checked, depending only on the standard
foundational axioms.

**Keywords.** pseudo-metric space, hybrid argument, security reduction, Lipschitz
map, path length, triangle inequality, Fibonacci numbers, greatest common
divisor, primitive divisor, Carmichael's theorem, conservation law.

---

## 1. Introduction

Provable security rests on two quantitative engines. The **hybrid argument**
bounds the distinguishability of two "far apart" games by the sum of the
distinguishabilities of a chain of intermediate games. **Reduction composition**
tracks how the multiplicative "loss factors" of chained reductions accumulate.
Traditionally these are treated as distinct accounting disciplines: one additive,
one multiplicative.

Independently, in elementary and analytic number theory, the strong divisibility
property of the Fibonacci sequence,
```
gcd(F(m), F(n)) = F(gcd(m, n)),
```
drives the proof of Carmichael's primitive divisor theorem: for all but finitely
many n, the Fibonacci number F(n) possesses a prime factor dividing no earlier
Fibonacci number.

The thesis of this paper is that these two theories are instances of one
structure. Define a non-negative **length functional** on a discrete path
together with a class of **morphisms** that conserve or contract it. Then:

- the hybrid argument is sub-additivity of length along a path (the iterated
  triangle inequality);
- reduction composition is contraction of length under a Lipschitz morphism;
- the Carmichael bridge is conservation of a gcd-valuation under the Fibonacci
  morphism of the divisor lattice.

We make this precise with definitions and six theorems, each proved by a short
structural argument. The development is self-contained; everything needed is
stated inline below.

---

## 2. The length functional on a discrete path

We work in a **pseudo-metric space**: a type `α` equipped with a distance
function `dist : α × α → ℝ` satisfying `dist(x, x) = 0`, symmetry, and the
triangle inequality, but *not* necessarily the separation axiom
(`dist(x, y) = 0 ⇒ x = y`). This is exactly the right setting for cryptography,
where two distinct games may be perfectly indistinguishable (distance zero)
without being literally equal.

A **discrete path** (or walk) is simply a function `f : ℕ → α`. In the
cryptographic reading, `f(i)` is the `i`-th game in a hybrid sequence; in the
geometric reading, the successive waypoints of a journey.

> **Definition 2.1 (Path length).** For a path `f : ℕ → α` in a pseudo-metric
> space and `n ∈ ℕ`, the *path length* through the first `n` steps is
> ```
> pathLength(f, n)  :=  Σ_{i=0}^{n-1} dist(f(i), f(i+1)).
> ```

This single functional is the protagonist. Its elementary properties:

> **Lemma 2.2 (Base case).** `pathLength(f, 0) = 0`.
>
> *Proof.* The sum over the empty range is zero. ∎

> **Lemma 2.3 (Recurrence).**
> `pathLength(f, n+1) = pathLength(f, n) + dist(f(n), f(n+1))`.
>
> *Proof.* Split off the last summand of `Σ_{i=0}^{n}` via the range-successor
> identity. ∎

> **Lemma 2.4 (Non-negativity).** `0 ≤ pathLength(f, n)`.
>
> *Proof.* A finite sum of distances, each `≥ 0`, is `≥ 0`. ∎

These three lemmas establish that `pathLength` is a well-behaved, monotone,
non-negative accumulator — the discrete analogue of arc length.

---

## 3. Conservation laws of reduction paths

### 3.1 The endpoint bound (generalized hybrid argument)

> **Theorem 3.1 (Endpoint bound).** For every path `f : ℕ → α` in a pseudo-metric
> space and every `n`,
> ```
> dist(f(0), f(n))  ≤  pathLength(f, n).
> ```
>
> *Proof sketch.* This is the iterated triangle inequality. By induction on `n`:
> the base case is `dist(f(0), f(0)) = 0`. For the step, the triangle inequality
> gives `dist(f(0), f(n+1)) ≤ dist(f(0), f(n)) + dist(f(n), f(n+1))`; apply the
> inductive hypothesis to the first term and Lemma 2.3 to recognize the right
> side as `pathLength(f, n+1)`. Equivalently, this is the standard
> `dist_le_range_sum_dist` telescoping bound. ∎

**Cryptographic reading.** This is precisely the *hybrid argument*. With the
advantage between games as distance, the distinguishability of the extreme games
`f(0)` and `f(n)` is at most the sum of the per-step distinguishabilities. The
classical statement
```
|d(0) − d(n)|  ≤  Σ_{i<n} |d(i) − d(i+1)|
```
for a real advantage coordinate `d : ℕ → ℝ` is the special case `α = ℝ` with
`dist(x, y) = |x − y|`. Theorem 3.1 lifts it to any pseudo-metric space.

### 3.2 Concatenation additivity (triangle conservation law)

> **Theorem 3.2 (Concatenation additivity).** For any `k ≤ n`,
> ```
> pathLength(f, n)  =  pathLength(f, k)  +  Σ_{i=k}^{n-1} dist(f(i), f(i+1)).
> ```
>
> *Proof sketch.* Partition the index range `[0, n) = [0, k) ⊔ [k, n)` and split
> the defining sum accordingly (the `sum_range_add_sum_Ico` identity). The first
> block is `pathLength(f, k)` by definition; the second block is the displayed
> tail sum. ∎

This is the *conservation law* of path length: the functional is additive under
concatenation of sub-paths. It is the structural form of the triangle
conservation law `|a − c| ≤ |a − b| + |b − c|`, now phrased as an exact equality
of accumulated length rather than an inequality of endpoints. Operationally it
justifies inserting intermediate games at any position while keeping the
advantage budget balanced.

### 3.3 Lipschitz contraction (unified composition law)

A **reduction** is a map `φ : α → β` between pseudo-metric spaces. It is
**K-Lipschitz** (for `K ∈ ℝ`) if
```
dist(φ(x), φ(y))  ≤  K · dist(x, y)   for all x, y.
```
The constant `K` is the *advantage-loss factor*: it quantifies how much the
reduction can amplify distinguishing power.

> **Theorem 3.3 (Lipschitz path contraction).** If `φ : α → β` is K-Lipschitz,
> then for every path `f` and every `n`,
> ```
> pathLength(φ ∘ f, n)  ≤  K · pathLength(f, n).
> ```
>
> *Proof sketch.* Expand both path lengths as sums. For each step,
> `dist(φ(f(i)), φ(f(i+1))) ≤ K · dist(f(i), f(i+1))` by the Lipschitz
> hypothesis. Sum over `i ∈ [0, n)` (monotonicity of finite sums) and pull the
> constant `K` outside the sum (`mul_sum`). ∎

**Two laws in one.** Theorem 3.3 subsumes both classical engines:

- the **multiplicative** law is the constant `K` factored out front; chaining a
  `K₁`-Lipschitz reduction with a `K₂`-Lipschitz reduction yields a
  `(K₂K₁)`-Lipschitz composite, recovering "loss factors multiply";
- the **additive** law is the path length `pathLength(f, n)` inside, which by
  Theorem 3.1 governs the per-step accumulation of advantage, recovering the
  hybrid/PRG-stretch amplification bound `|d(0) − d(n)| ≤ n·ε` when each step is
  bounded by `ε`.

**A pleasant generalization.** The proof never uses `0 ≤ K`. The termwise bounds
are summed directly, so the theorem holds for *any* real `K`. The non-negativity
of a Lipschitz constant — true and automatic from a single step — is simply never
needed. The hypothesis was therefore dropped, and the statement is strictly more
general than the cryptographic motivation required.

### 3.4 The end-to-end reduction bound

> **Theorem 3.4 (End-to-end bound).** If `φ : α → β` is K-Lipschitz, then for
> every path `f` and every `n`,
> ```
> dist(φ(f(0)), φ(f(n)))  ≤  K · pathLength(f, n).
> ```
>
> *Proof sketch.* Apply the endpoint bound (Theorem 3.1) to the reduced path
> `φ ∘ f`:
> ```
> dist(φ(f(0)), φ(f(n))) = dist((φ∘f)(0), (φ∘f)(n)) ≤ pathLength(φ ∘ f, n),
> ```
> then apply Lipschitz contraction (Theorem 3.3) to bound
> `pathLength(φ ∘ f, n) ≤ K · pathLength(f, n)`. Compose the two inequalities. ∎

This is the headline quantitative estimate a working cryptographer quotes: after
applying a reduction with loss factor `K`, the distinguishability between the
extreme games is bounded by `K` times the total advantage budget. It is the
entire quantitative content of a security proof reduced to two structural
lemmas.

---

## 4. The number-theoretic dual: gcd conservation

We now exhibit the *same* conserved-quantity pattern in number theory, with the
gcd in place of the metric distance and the Fibonacci map in place of the
reduction.

Write `F(n)` for the `n`-th Fibonacci number (`F(0) = 0`, `F(1) = 1`,
`F(n+2) = F(n) + F(n+1)`).

> **Theorem 4.1 (Fibonacci gcd conservation).** For all `m, n ∈ ℕ`,
> ```
> gcd(F(m), F(n))  =  F(gcd(m, n)).
> ```
>
> *Proof sketch.* This is the strong divisibility property of the Fibonacci
> sequence (`Nat.fib_gcd`). It follows from the addition formula
> `F(m+n) = F(m)F(n+1) + F(m−1)F(n)` together with the consecutive-coprimality
> `gcd(F(n), F(n+1)) = 1`, by running the Euclidean algorithm simultaneously on
> the indices and the values. ∎

**Conservation reading.** The Fibonacci map `n ↦ F(n)` is a *morphism of the
divisor lattice*: it carries the meet operation (gcd) on indices faithfully to
the meet operation (gcd) on values. Where a K-Lipschitz reduction *contracts* its
length functional by `K`, the Fibonacci morphism *exactly preserves* its
gcd-valuation. Conservation is the limiting case `K = 1` of contraction — an
advantage-preserving morphism.

### 4.1 The primitivity bridge

The payoff is a clean, self-contained restatement of the conserved-quantity heart
of Carmichael's primitive divisor argument.

> **Theorem 4.2 (Primitivity bridge).** Let `n > 0` and let `p` be a (prime or
> arbitrary) natural number with `p ∣ F(n)`. Suppose that for every *proper*
> positive divisor `d` of `n` (i.e. `d ∣ n`, `0 < d`, `d < n`) we have
> `p ∤ F(d)`. Then for every `k` with `0 < k < n`, we have `p ∤ F(k)`.
>
> *Proof sketch.* Suppose toward a contradiction that `p ∣ F(k)` for some
> `0 < k < n`. Then `p` divides both `F(n)` and `F(k)`, hence `p ∣ gcd(F(n),
> F(k))`. By the conservation law (Theorem 4.1), `gcd(F(n), F(k)) = F(gcd(n,
> k))`, so `p ∣ F(gcd(n, k))`. Now `g := gcd(n, k)` is a positive divisor of `n`
> (it divides `n`, and `g > 0` since `n > 0`) and `g ≤ k < n`, so `g` is a
> *proper* positive divisor of `n`. This contradicts the hypothesis that `p ∤
> F(d)` for all proper positive divisors `d`. ∎

**Why the bridge matters.** Carmichael's theorem requires showing a prime is
*primitive*: it divides `F(n)` but no earlier Fibonacci number. Naively this is
an infinite check over all `k < n`. Theorem 4.2 collapses it to a *finite* check
over the proper divisors of `n` — purely via gcd conservation. The single
algebraic substitution `gcd(F(n), F(k)) ↦ F(gcd(n, k))` performs the same
structural move as the cryptographic reduction shrinking an entire path in one
step: a conserved quantity reduces a global statement to a local one.

**On the hypotheses.** Positivity `n > 0` is genuinely needed: it guarantees
`gcd(n, k)` is a *positive* proper divisor of `n`, keeping the conserved quantity
inside the range where local non-divisibility is assumed. The result holds for
arbitrary `p` (no primality assumption is required for the bridge itself);
primality enters only when one subsequently argues that a primitive prime
*exists*.

---

## 5. The unifying dictionary

The two theories are now visibly one. The following dictionary makes the
correspondence explicit.

| Concept                       | Cryptography                          | Number theory                        |
|-------------------------------|---------------------------------------|--------------------------------------|
| Underlying space              | pseudo-metric space of games          | divisor lattice of ℕ                 |
| Points                        | games `f(i)`                          | indices `n`                          |
| Conserved coordinate          | advantage = `dist`                    | gcd-valuation                        |
| Functional on a path          | `pathLength` (Def. 2.1)               | gcd along the lattice                |
| Sub-additivity / telescoping  | endpoint bound (Thm 3.1)              | strong divisibility (Thm 4.1)        |
| Concatenation law             | additivity (Thm 3.2)                  | multiplicativity of gcd over factors |
| Morphism                      | K-Lipschitz reduction `φ`             | Fibonacci map `n ↦ F(n)`             |
| Effect on the quantity        | contracts by `K` (Thm 3.3)           | preserves exactly, `K = 1` (Thm 4.1) |
| Headline estimate             | end-to-end bound (Thm 3.4)            | primitivity bridge (Thm 4.2)         |

The two laws needed everywhere are (a) sub-additivity along a path and (b)
conservation/contraction under a morphism. The entire quantitative theory — in
both fields — is the interplay of these two laws.

---

## 6. Algorithms

The structural theorems are constructive and yield directly executable
procedures.

### 6.1 Path length accumulation

Computing `pathLength(f, n)` is a left fold accumulating consecutive distances in
`O(n)` distance evaluations. The recurrence (Lemma 2.3) shows the accumulation is
incremental: extending a path by one game costs a single distance evaluation,
enabling online/streaming computation of advantage budgets as hybrids are added.

### 6.2 End-to-end bound certification

Given per-step distance bounds `b(i) ≥ dist(f(i), f(i+1))` and a Lipschitz
constant `K`, the certified end-to-end bound is `K · Σ b(i)`. Theorems 3.1, 3.3,
3.4 guarantee this is a valid upper bound on `dist(φ(f(0)), φ(f(n)))`. This is the
machine-checkable core of a concrete security proof: feed in the per-hybrid gaps
and the loss factor, read out the final advantage bound.

### 6.3 Primitive-divisor screening

To find a primitive prime divisor of `F(n)`, Theorem 4.2 reduces the search to:
(i) enumerate the proper divisors `d` of `n`; (ii) compute the "primitive part"
of `F(n)` by stripping every prime factor it shares with any `F(d)`; (iii) report
any remaining prime factor. Crucially, step (ii) iterates only over divisors of
`n` — typically `O(d(n))` terms, where `d(n)` is the number of divisors — rather
than over all `k < n`. The gcd conservation law guarantees the screening is
sound.

---

## 7. Applications

**Modular security proofs.** Theorem 3.4 turns a security argument into a
pipeline: assemble a path of games, bound each consecutive gap, supply a
Lipschitz reduction, and read off the end-to-end advantage. Concatenation
additivity (Theorem 3.2) lets independent sub-proofs be developed separately and
glued, with the advantage budgets automatically summing correctly.

**PRG stretch and amplification.** When each of `n` hybrid steps is bounded by a
uniform `ε`, Theorem 3.1 gives `dist(f(0), f(n)) ≤ n·ε`, recovering the standard
pseudo-random-generator stretch-amplification bound as an immediate corollary.

**Carmichael primitive divisors.** Theorem 4.2 is the reusable engine of the
primitive-divisor existence theorem: it eliminates the per-index search,
replacing an infinite verification by a finite divisor screen. The same lemma
underlies entry-point/rank-of-apparition arguments for general moduli.

---

## 8. Discussion and future work

The conserved-quantity viewpoint is more than a notational convenience; it
suggests a research program.

**1. A fundamental-groupoid structure for games.** Replace the index set `ℕ` by an
arbitrary directed graph of games, define the length functional over walks, and
quotient by the relation "same endpoints, equal length." The hybrid argument
says the only homotopy-invariant of a game walk is its endpoint distance, so
every legitimate hybrid proof is a homotopy of walks with non-increasing length.
With Theorems 3.1 and 3.2 in hand, the concatenation and endpoint axioms of a
length-graded groupoid are already established; only the quotient construction
remains.

**2. Sharpness of the Lipschitz bound.** Conjecture: Theorem 3.3 is tight — for
every `K` and `n` there is a pseudo-metric pair, a `K`-Lipschitz `φ`, and a path
`f` with `pathLength(φ ∘ f, n) = K · pathLength(f, n)`. Equality forces `φ` to be
a dilation on every consecutive pair, so tightness is equivalent to the existence
of a geodesic path on which `φ` attains its constant at every step. The witness
`α = β = ℝ`, `φ(x) = Kx`, `f(i) = i` should certify it mechanically.

**3. A multiplicative Lipschitz law for the Fibonacci valuation.** The `p`-adic
valuation `v_p(F(n))` along the divisor lattice should obey a Lipschitz-type law
analogous to Theorem 3.3, with the gcd as the lattice meet. Conjecture:
`v_p(F(n))` is a monotone, sub-additive functional on the divisor lattice whose
steps are controlled by the rank of apparition. Quantifying the valuation gained
per divisor step would upgrade primitive-divisor *existence* to primitive-divisor
*counting*.

**4. Closing the Carmichael infinite tail.** The finite verification of
Carmichael's theorem discharges composite `n` up to a fixed bound by
brute-force, leaving the tail open. Theorem 4.2 reduces primitivity to a single
inequality about the size of the primitive part of `F(n)`; combining it with a
Zsygmondy/Carmichael lower bound on the size of `F(n)` relative to the product of
earlier `F(d)` would force the primitive part to exceed 1 for all large `n`,
eliminating the case analysis in favor of an analytic growth estimate.

**5. An ∞-categorical localization inverting negligible reductions.** Define the
advantage-preserving reductions (`K = 1`) and localize the category of game path
spaces at the morphisms whose constant is negligible in the security parameter.
Conjecture: the localization identifies exactly the computationally
indistinguishable games, so indistinguishability *is* isomorphism in the
localized ∞-category. Theorem 3.4 makes advantage a functorial length the
localization must send to zero; the weak equivalences are closed under
composition (by the multiplicative law), the precondition for a calculus of
fractions.

---

## 9. Conclusion

A single non-negative length functional on a discrete path, together with the
morphisms that conserve or contract it, accounts for both the quantitative
calculus of cryptographic reductions and the divisibility heart of the Fibonacci
primitive-divisor theorem. The hybrid argument is the iterated triangle
inequality (Theorem 3.1); reduction composition is Lipschitz contraction
(Theorem 3.3); their composite is the end-to-end reduction bound (Theorem 3.4);
and the Carmichael bridge is gcd conservation (Theorems 4.1, 4.2). Advantage,
path length, and gcd-valuation are three readings of one conserved coordinate.
Sub-additivity along a path and conservation/contraction under a morphism are the
only two laws required; the entire quantitative theory is their interplay.

---

## Appendix: Formal statements

For reference, the precise formal statements of the six main results (in the
pseudo-metric setting and over the natural numbers) are as follows.

- **Endpoint bound.** `dist (f 0) (f n) ≤ pathLength f n`.
- **Concatenation.** For `k ≤ n`,
  `pathLength f n = pathLength f k + Σ_{i ∈ Ico k n} dist (f i) (f (i+1))`.
- **Lipschitz contraction.** If `∀ x y, dist (φ x) (φ y) ≤ K * dist x y`, then
  `pathLength (φ ∘ f) n ≤ K * pathLength f n`.
- **End-to-end bound.** Under the same hypothesis,
  `dist (φ (f 0)) (φ (f n)) ≤ K * pathLength f n`.
- **Fibonacci gcd conservation.** `Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)`.
- **Primitivity bridge.** For `0 < n`, `p ∣ F(n)`, and `(∀ d, d ∣ n → 0 < d →
  d < n → ¬ p ∣ F(d))`: `∀ k, 0 < k → k < n → ¬ p ∣ F(k)`.

All are machine-checked and depend only on the standard foundational axioms
(`propext`, `Classical.choice`, `Quot.sound`); the two number-theoretic results
use no choice.
