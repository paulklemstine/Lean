# The Multiplicative Structure of the Fibonacci Rank of Apparition

## Abstract

The *rank of apparition* (or *entry point*) of a positive integer `m`,
denoted `α(m)`, is the least positive index `k` such that `m` divides the
`k`-th Fibonacci number `F(k)`. Classically, the **law of apparition**
states that `m ∣ F(k)` if and only if `α(m) ∣ k`, reducing a question
about an infinite, exponentially growing sequence to a single arithmetic
invariant. In this work we study how `α` interacts with the
*multiplicative structure* of its argument. Our central result is that
`α` is an **lcm-homomorphism on the coprime-modulus monoid**: for coprime
`m, n > 0`,
```
α(m·n) = lcm(α(m), α(n)).
```
We show coprimality is necessary and sharp — already at `m = n = 2` the
identity fails, with `α(4) = 6` while `lcm(α(2), α(2)) = lcm(3, 3) = 3`,
a discrepancy of exactly the prime `2`. This gap is the visible trace of
*Wall's phenomenon*, the prime-power delay that the lcm formula cannot
detect, and it cleanly separates the theory into a fully understood
coprime (Chinese-Remainder) part and a hard prime-power (Wall) part. We
develop the supporting infrastructure: divisibility-monotonicity of `α`
(making it a monotone map of divisibility lattices), an evaluation
principle pinning down concrete values, and the base case of the
prime-power divisibility tower `α(p) ∣ α(p²)`. All results have been
formally verified in a proof assistant. We close with five research
directions, including a conjectural Chinese-Remainder reconstruction of
the full entry point and the connection to Wall–Sun–Sun primes.

**Keywords:** Fibonacci numbers, rank of apparition, entry point, law of
apparition, Lucas sequences, Chinese Remainder Theorem, Wall–Sun–Sun
primes, primitive prime divisors.

---

## 1. Introduction

The Fibonacci sequence `(F(k))` is defined by `F(0) = 0`, `F(1) = 1`, and
`F(k+2) = F(k+1) + F(k)`:
```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, ...
```
A foundational question in the arithmetic of `(F(k))` is the *divisibility
problem*: for a fixed modulus `m`, characterize the set
`D(m) = { k > 0 : m ∣ F(k) }`. Empirically this set is always a nonempty
arithmetic progression of the form `{ α(m), 2·α(m), 3·α(m), ... }`, where
`α(m)` is the smallest element. This invariant `α(m)` is the **rank of
apparition** (also *entry point* or *Fibonacci entry point*) of `m`.

The classical theory establishes two pillars:

1. **Well-definedness** — every `m > 0` divides some positive Fibonacci
   number, so `α(m)` exists.
2. **The law of apparition** — `m ∣ F(k) ⇔ α(m) ∣ k`.

This paper takes the next structural step. Whereas the law of apparition
is a statement about a *single* modulus, we ask how `α` behaves under the
*multiplication* of moduli, i.e. how the invariant respects the
factorization of `m`. We prove that on coprime factors `α` converts
products into least common multiples, and we delineate exactly why this
must fail on non-coprime factors. Together these results reduce the
computation of `α(m)` to the prime-power case, isolating the residual
difficulty into a single well-known hard problem.

### 1.1 Notation and conventions

Throughout, `F(k)` is the `k`-th Fibonacci number with `F(0) = 0`,
`F(1) = 1`. For positive integers we write `gcd` and `lcm` for the
greatest common divisor and least common multiple, `a ∣ b` for "a
divides b", and `Coprime(m, n)` for `gcd(m, n) = 1`. All ranks are
considered for `m > 0`.

---

## 2. Definitions

**Definition 2.1 (Rank of apparition / entry point).**
For `m > 0`, the *rank of apparition* is
```
α(m) = min { k > 0 : m ∣ F(k) }.
```
(For completeness one may set `α(m) = 0` when no such `k` exists; by
Theorem 3.1 this fallback never occurs for `m > 0`.)

**Definition 2.2 (Pair sequence modulo `m`).**
The *Fibonacci pair sequence* modulo `m` is
```
P_m(n) = ( F(n) mod m, F(n+1) mod m ) ∈ (Z/mZ) × (Z/mZ).
```
The Fibonacci recurrence makes `P_m` a deterministic dynamical system on
the finite set `(Z/mZ)²`: `P_m(n+1)` is a function of `P_m(n)`.

**Definition 2.3 (Primitive prime divisor).**
A prime `p` is a *primitive prime divisor* of `F(n)` if `p ∣ F(n)` and
`p ∤ F(k)` for all `0 < k < n`.

---

## 3. Foundational results (the single-modulus theory)

We restate the classical backbone, which our new results build upon.

**Theorem 3.1 (Existence of apparition).**
For every `m > 0` there exists `k > 0` with `m ∣ F(k)`; hence `α(m)` is
well-defined and positive.

*Proof sketch.* Consider the pair sequence `P_m` of Definition 2.2. It
takes values in the finite set `(Z/mZ)²`, so by the pigeonhole principle
there exist `i < j` with `P_m(i) = P_m(j)`. The recurrence
`F(n+2) = F(n) + F(n+1)` is invertible modulo `m`
(`F(n) = F(n+2) − F(n+1)`), so the pair map is *backward deterministic*:
`P_m(a+1) = P_m(b+1)` forces `P_m(a) = P_m(b)`. Iterating this descent `i`
times from the coincidence `P_m(i) = P_m(j)` yields
`P_m(0) = P_m(j − i)`. Reading off the first coordinate gives
`F(j − i) ≡ F(0) = 0 (mod m)`, i.e. `m ∣ F(j − i)` with `j − i > 0`. ∎

**Lemma 3.2 (Minimality characterization).**
`α(m)` is the least positive `k` with `m ∣ F(k)`; equivalently, `m ∣ F(α(m))`
and `m ∤ F(k)` for every `0 < k < α(m)`.

**Theorem 3.3 (Law of apparition).**
For `m > 0` and any `k ≥ 0`,
```
m ∣ F(k)  ⇔  α(m) ∣ k.
```

*Proof sketch.* ( ⇐ ) If `α(m) ∣ k` then `F(α(m)) ∣ F(k)` by the
standard divisibility property `a ∣ b ⇒ F(a) ∣ F(b)`, and `m ∣ F(α(m))`,
so `m ∣ F(k)`. ( ⇒ ) Suppose `m ∣ F(k)`. Using Lucas's identity
`gcd(F(k), F(α(m))) = F(gcd(k, α(m)))` (Lemma 3.4), `m` divides both
`F(k)` and `F(α(m))`, hence `m ∣ F(gcd(k, α(m)))`. By minimality of
`α(m)`, the positive index `gcd(k, α(m))` cannot be smaller than `α(m)`;
since it also divides `α(m)` it must equal `α(m)`, giving `α(m) ∣ k`. ∎

**Lemma 3.4 (Lucas gcd identity).**
For all `m, n ≥ 0`, `gcd(F(m), F(n)) = F(gcd(m, n))`.

**Theorem 3.5 (Primitive divisor characterization).**
For a prime `p` and `n > 0`, `p` is a primitive prime divisor of `F(n)`
if and only if `α(p) = n`.

*Proof sketch.* If `p` is primitive then `p ∣ F(n)` gives `α(p) ≤ n`,
while primitivity forbids `α(p) < n`, so `α(p) = n`. Conversely
`α(p) = n` gives `p ∣ F(n)` by Lemma 3.2, and minimality gives the
no-earlier-divisor condition. ∎

This recasts Carmichael's primitive-divisor theorem in the language of
the entry point and motivates understanding `α` as a function of the
multiplicative structure of `m`.

---

## 4. The multiplicative structure (main results)

### 4.1 Divisibility-monotonicity: the functorial backbone

**Theorem 4.1 (Divisibility-monotonicity).**
If `a ∣ b` (with `a, b > 0`), then `α(a) ∣ α(b)`.

*Proof sketch.* By Lemma 3.2, `b ∣ F(α(b))`. Since `a ∣ b`, also
`a ∣ F(α(b))`. Applying the law of apparition (Theorem 3.3) to the
modulus `a` and index `α(b)` yields `α(a) ∣ α(b)`. ∎

Theorem 4.1 says `α` is order-preserving from the divisibility poset of
moduli to the divisibility poset of indices: it is a *monotone map of
divisibility lattices*. This is the structural glue used below. Two
immediate lattice corollaries follow purely from `gcd(a,b) ∣ a ∣ lcm(a,b)`:

**Corollary 4.2 (gcd lower bound).**
`α(gcd(a, b)) ∣ gcd(α(a), α(b))`.

**Corollary 4.3 (lcm upper bound).**
`lcm(α(a), α(b)) ∣ α(lcm(a, b))`.

*Proof sketch.* For 4.2, `gcd(a,b) ∣ a` and `gcd(a,b) ∣ b` give
`α(gcd(a,b)) ∣ α(a)` and `α(gcd(a,b)) ∣ α(b)` by Theorem 4.1, hence
`α(gcd(a,b))` divides their gcd. For 4.3, `a ∣ lcm(a,b)` and
`b ∣ lcm(a,b)` give `α(a), α(b) ∣ α(lcm(a,b))`, hence their lcm divides
`α(lcm(a,b))`. ∎

### 4.2 An evaluation principle

To exhibit concrete values and counterexamples one must compute `α`,
which is defined by a minimization. The following principle converts a
"divides here, nowhere earlier" certificate into an equality.

**Lemma 4.4 (Evaluation principle).**
Let `m > 0` and `e > 0`. If `m ∣ F(e)` and `m ∤ F(k)` for all
`0 < k < e`, then `α(m) = e`.

*Proof sketch.* The hypothesis `m ∣ F(e)` gives `α(m) ≤ e`; the
no-earlier-divisor hypothesis with Lemma 3.2 gives `α(m) ≥ e`. ∎

**Lemma 4.5 (Small values).**
`α(2) = 3` and `α(4) = 6`.

*Proof sketch.* For `α(2) = 3`: `F(1) = F(2) = 1` are odd, `F(3) = 2` is
even; apply Lemma 4.4 with `e = 3`. For `α(4) = 6`: `F(1..5) = 1,1,2,3,5`
are not multiples of 4, while `F(6) = 8` is; apply Lemma 4.4 with
`e = 6`. ∎

The value `α(4) = 6` is the first prime-power value exhibiting Wall delay
and is the crux of the sharpness result below.

### 4.3 Coprime multiplicativity — the headline theorem

**Theorem 4.6 (Coprime lcm-homomorphism).**
If `m, n > 0` and `gcd(m, n) = 1`, then
```
α(m·n) = lcm(α(m), α(n)).
```

*Proof sketch.* We show both `α(m·n)` and `lcm(α(m), α(n))` generate the
same set of indices `k` with `m·n ∣ F(k)`, equivalently that they
divide each other.

Fix any `k`. Because `gcd(m, n) = 1`,
```
m·n ∣ F(k)  ⇔  m ∣ F(k)  and  n ∣ F(k)
```
(the elementary fact that coprime divisors of a common multiple multiply,
`Nat.Coprime.mul_dvd_of_dvd_of_dvd`). Applying the law of apparition
(Theorem 3.3) to each conjunct:
```
m ∣ F(k) ⇔ α(m) ∣ k,    n ∣ F(k) ⇔ α(n) ∣ k.
```
Therefore
```
m·n ∣ F(k)  ⇔  α(m) ∣ k  and  α(n) ∣ k  ⇔  lcm(α(m), α(n)) ∣ k.
```
But by the law of apparition applied to the modulus `m·n`,
`m·n ∣ F(k) ⇔ α(m·n) ∣ k`. Two positive integers (`α(m·n)` and
`lcm(α(m), α(n))`) that divide exactly the same set of `k` are equal.
Concretely: taking `k = lcm(α(m), α(n))` shows `α(m·n) ∣ lcm(α(m),α(n))`,
and taking `k = α(m·n)` shows `lcm(α(m), α(n)) ∣ α(m·n)`; antisymmetry of
divisibility finishes. ∎

The proof is a textbook *local-to-global* (Chinese-Remainder) argument:
the multiplicative splitting of the divisibility condition is exactly CRT,
and the law of apparition transports it to the index level where lcm
appears.

**Example 4.7.** `α(10) = lcm(α(2), α(5)) = lcm(3, 5) = 15`, and indeed
`F(15) = 610 = 10·61` is the first Fibonacci multiple of 10.

### 4.4 Sharpness: coprimality is necessary

**Theorem 4.8 (Failure without coprimality).**
The identity of Theorem 4.6 fails for `m = n = 2`:
```
α(4) = 6  ≠  3 = lcm(α(2), α(2)) = lcm(3, 3).
```

*Proof sketch.* Immediate from Lemma 4.5: `α(4) = 6` and `α(2) = 3`, so
`lcm(3, 3) = 3 ≠ 6`. ∎

The discrepancy is exactly a factor of `2`, the prime being squared. This
is the *prime-power delay* invisible to the lcm formula and is the
structural reason the theory bifurcates into a coprime part (fully solved
by Theorem 4.6) and a prime-power part (Section 4.5).

### 4.5 The prime-power tower

**Theorem 4.9 (Prime-power divisibility, base case).**
For a prime `p`, `α(p) ∣ α(p²)`.

*Proof sketch.* `p ∣ p²`, so Theorem 4.1 gives `α(p) ∣ α(p²)`. ∎

This is the first rung of the divisibility tower
`α(p) ∣ α(p²) ∣ α(p³) ∣ ...`, each step following from Theorem 4.1
applied to `p^k ∣ p^{k+1}`. The *exact ratios* of successive rungs are
the content of the conjectures in Section 6.

---

## 5. Algorithms

Theorem 4.6 yields a fast, fully *local* algorithm for the entry point
once the prime-power values are known.

**Algorithm 5.1 (Entry point by prime-power assembly).**
Given `m > 0` with prime factorization `m = ∏ pᵢ^{eᵢ}`:
1. For each prime power `pᵢ^{eᵢ}`, compute `α(pᵢ^{eᵢ})` directly (by
   scanning Fibonacci residues, or via the prime-power recursion of
   Section 6).
2. Return `lcm_i α(pᵢ^{eᵢ})`.

Correctness follows by iterating Theorem 4.6: `pᵢ^{eᵢ}` is coprime to the
product of the remaining prime-power factors, so the two-factor identity
applies at each step (this is Conjecture 6.1, proven inductively from
Theorem 4.6 as base case). The cost of step 1 is the dominant term; step
2 is `O(#distinct primes)` lcm operations.

**Algorithm 5.2 (Direct entry point by residue scan).**
Compute `α(m)` from scratch by iterating the pair sequence `P_m` of
Definition 2.2 modulo `m`, returning the first index `k > 0` with
`F(k) ≡ 0 (mod m)`. Termination is guaranteed by Theorem 3.1, and the
number of iterations is at most the Pisano period `π(m) ≤ 6m`, so the
algorithm runs in `O(m)` modular additions.

---

## 6. Conjectures and future work

**Conjecture 6.1 (CRT reconstruction).**
For any `m > 0` with `m = ∏ pᵢ^{eᵢ}`,
`α(m) = lcm_i α(pᵢ^{eᵢ})`. *Approach:* induct on the number of distinct
prime factors using Theorem 4.6; the inductive step is coprime because
`pᵉ` is coprime to the remaining cofactor. This reduces all entry-point
computation to the prime-power case.

**Conjecture 6.2 (Prime-power dichotomy / Wall).**
For every prime `p` and `k ≥ 1`, either `α(p^{k+1}) = α(p^k)` or
`α(p^{k+1}) = p·α(p^k)`; the first alternative at `k = 1` holds iff `p` is
a *Wall–Sun–Sun prime* (none known below `2^64`). *Approach:* lifting-the-
exponent applied to `F(α(p)·p^j)` to control `p`-adic valuations;
Theorem 4.9 supplies the divisibility half.

**Conjecture 6.3 (Lattice morphism).**
The inequalities of Corollaries 4.2–4.3 become equalities up to the
prime-power defect; in particular Theorem 4.6 makes the lcm bound 4.3 an
equality on coprime moduli.

**Conjecture 6.4 (Pisano period ratio).**
The Pisano period `π(m)` is a multiple of `α(m)`, with
`π(m)/α(m) ∈ {1, 2, 4}`. *Approach:* analyze the order of `F(α(m)+1)` in
the unit group `(Z/mZ)ˣ` using the pair-sequence dynamics of
Definition 2.2.

**Conjecture 6.5 (Lucas-sequence generalization).**
For a Lucas sequence `U_n(P, Q)` with `gcd(P, Q) = 1` and nonzero
discriminant, the analogous entry point satisfies
`α_U(m·n) = lcm(α_U(m), α_U(n))` for coprime `m, n`. *Approach:* reprove
Theorem 4.6 abstractly from its two genuine inputs — divisibility-
monotonicity (Theorem 4.1) and the gcd identity
`gcd(U_m, U_n) = U_{gcd(m,n)}` — then specialize at `P = Q = 1`. One proof
would then cover Fibonacci, Pell, Mersenne, and Lucas numbers
simultaneously.

---

## 7. Discussion

The results assembled here complete the *coprime* structure theory of the
Fibonacci rank of apparition. The headline Theorem 4.6 shows `α` is an
lcm-homomorphism on the coprime-modulus monoid; Theorem 4.8 shows this is
sharp; and Theorems 4.1–4.9 supply the monotonicity, evaluation, and
prime-power infrastructure. The conceptual payoff is a clean dichotomy:
the entry point is *completely local* in its coprime behavior and reduces
entirely (modulo Conjecture 6.1) to the prime-power tower, whose exact
behavior is precisely the locus of classical open problems (Wall–Sun–Sun
primes). The same architecture — built only from the law of apparition
and the Lucas gcd identity — transfers verbatim to general Lucas
sequences, suggesting these theorems are best understood as instances of a
single, modular template rather than as facts about Fibonacci numbers
specifically.

All theorems stated above have been formally verified in a proof
assistant, eliminating any uncertainty in the chain of reasoning,
including the sharpness counterexample and the prime-power base case.

---

## References

- E. Lucas, *Théorie des fonctions numériques simplement périodiques*,
  Amer. J. Math. 1 (1878).
- R. D. Carmichael, *On the numerical factors of the arithmetic forms
  αⁿ ± βⁿ*, Ann. of Math. 15 (1913).
- D. D. Wall, *Fibonacci series modulo m*, Amer. Math. Monthly 67 (1960).
