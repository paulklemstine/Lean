# The Fibonacci Rank-of-Apparition Map as a Lattice Adjoint

## Abstract

The *rank of apparition* (entry point) of a positive integer `m` is the least positive index `k` such that `m` divides the `k`-th Fibonacci number `F(k)`. Treating the positive integers as a lattice under divisibility, with meet `gcd` and join `lcm`, we study the map `entry : (ℕ₊, ∣) → (ℕ₊, ∣)` purely through the *apparition law*

```
m | F(n)   ⟺   entry(m) | n.
```

We show that this single law — a Galois connection (adjunction) between the divisibility lattice and itself, with `entry` as left adjoint to the Fibonacci map `F` — forces `entry` to be a unital, monotone **join (lcm) homomorphism**:

```
entry(1) = 1,    a | b ⟹ entry(a) | entry(b),    entry(lcm(a,b)) = lcm(entry(a), entry(b)),
```

and a one-sided inverse (retraction) of `F` on indices `k ≥ 3`:

```
entry(F(k)) = k    (k ≥ 3).
```

Strikingly, none of these results require any further appeal to the Fibonacci recurrence beyond the apparition law itself: each is obtained by translating a divisibility statement about `F` into a statement about indices and applying elementary `ℕ`-divisibility. The general theory of adjunctions predicts both the success (joins are preserved by a left adjoint) and the *expected failure* of the dual meet law `entry(gcd(a,b)) = gcd(entry(a), entry(b))`, which we exhibit failing concretely. These structural facts are the algebraic backbone needed to assemble combined Pisano/apparition data of a composite modulus from its prime-power parts, the structural core of Lucas-sequence primality certificates. The development builds on a first-principles divisibility theory of Fibonacci numbers grounded in the single identity `F(gcd(m,n)) = gcd(F(m), F(n))`, and all results are formally verified.

**Keywords:** rank of apparition, entry point, Fibonacci sequence, divisibility lattice, Galois connection, adjoint functor, lattice homomorphism, Lucas sequences, primality testing, Pisano period.

---

## 1. Introduction

The Fibonacci sequence, defined by `F(1) = F(2) = 1` and `F(n+2) = F(n+1) + F(n)`, is the archetypal **strong divisibility sequence**: it transports the divisibility structure of the indices into the divisibility structure of its values. The single most economical expression of this is the classical gcd identity

```
F(gcd(m, n)) = gcd(F(m), F(n)),                              (★)
```

a lattice homomorphism from `(ℕ, ∣)` (on indices) into `(ℕ, ∣)` (on values). The forward divisibility implication `m | n ⟹ F(m) | F(n)` is elementary and standard; the genuinely sharp content of (★) is the converse, which (together with strict monotonicity of `F` on indices `≥ 2`) makes Fibonacci divisibility *faithful*.

Sitting atop this divisibility theory is the **rank of apparition** (or **entry point**) of a modulus, a notion going back to Lucas: the least positive index at which a multiple of the modulus appears. The rank of apparition is the central computational object of Lucas-sequence primality testing, because it linearizes the otherwise-expensive question "does `m` divide this enormous Fibonacci number?" into the trivial divisibility test on indices furnished by the *apparition law* (Theorem 3.1 below).

This paper isolates and proves the **algebraic backbone** of the rank-of-apparition map. We regard

```
entry : (ℕ₊, ∣) → (ℕ₊, ∣)
```

as a morphism of divisibility lattices and determine exactly which lattice structure it preserves. The organizing principle is that the apparition law is literally an **adjunction**: `entry` is left adjoint to `F`. From this perspective the main theorems are instances of a much older slogan — *a left adjoint preserves all joins, but need not preserve meets* — specialized to the self-adjunction of the divisibility lattice. The slogan simultaneously predicts the central positive result (preservation of `lcm`) and the licensed failure of the dual statement (preservation of `gcd`).

### 1.1 Contributions

1. **Unitality** (Theorem 4.1): `entry(1) = 1`.
2. **Monotonicity** (Theorem 4.2): `a | b ⟹ entry(a) | entry(b)`.
3. **Join-homomorphism law** (Theorem 4.3, central result): `entry(lcm(a,b)) = lcm(entry(a), entry(b))`.
4. **Retraction of `F`** (Theorem 4.4): `entry(F(k)) = k` for all `k ≥ 3`, sharp at the boundary.
5. A conceptual synthesis (Section 5): all four results follow from the apparition law alone, viewed as an adjunction, with the meet-defect (failure of the `gcd` law) explained structurally and exhibited numerically.

---

## 2. Preliminaries: the divisibility lattice and the foundational theory

### 2.1 The divisibility lattice

Order the positive integers by divisibility: `a ≤ b` iff `a | b`. This is a lattice with

- bottom element `1` (divides everything);
- meet `a ∧ b = gcd(a, b)`;
- join `a ∨ b = lcm(a, b)`.

We freely use the standard universal characterizations
```
d | gcd(a,b) ⟺ (d | a ∧ d | b),         lcm(a,b) | m ⟺ (a | m ∧ b | m).        (2.1)
```

A **divisibility-ideal extensionality** principle will be used repeatedly:

> **Lemma 2.1 (dvd_ext).** If `x, y ∈ ℕ` satisfy `∀ n, (x | n ⟺ y | n)`, then `x = y`.
>
> *Proof.* Apply the hypothesis at `n = y` to get `y | x` (from `y | y`), and at `n = x` to get `x | y`; conclude by antisymmetry of `∣` on `ℕ`. ∎

In lattice terms, an element is determined by its principal up-set (the set of its multiples); two elements with equal principal ideals coincide. This is the workhorse that converts each "homomorphism" claim into a pointwise divisibility equivalence.

### 2.2 The foundational Fibonacci divisibility theory

We take as given the following first-principles results, themselves derived solely from identity (★) together with strict monotonicity of `F` on `{k : k ≥ 2}`.

- **(F1) Injectivity.** `F(m) = F(n) ⟺ m = n` for `m, n ≥ 2`.
- **(F2) Unit indices.** `F(k) = 1 ⟺ k ∈ {1, 2}`.
- **(F3) Converse divisibility law.** For `m ≥ 3`: `F(m) | F(n) ⟺ m | n`. (The forward direction `m | n ⟹ F(m) | F(n)`, valid for all `m`, is the standard `Nat.fib_dvd`.)
- **(F4) Coprimality criterion.** `gcd(F(m), F(n)) = 1 ⟺ gcd(m, n) ∈ {1, 2}`.
- **(F5) Existence of the entry point.** For every `m > 0` there is `k > 0` with `m | F(k)`.

Result (F5) is the well-definedness of the rank of apparition; we sketch its proof because it is the only place the recurrence (rather than (★)) is essential.

> **Proposition 2.2 (Entry existence, (F5)).** For every `m > 0` there exists `k > 0` with `m | F(k)`.
>
> *Proof sketch.* Consider the map `k ↦ (F(k) mod m, F(k+1) mod m)` into the finite set `{0,…,m-1}²`. By pigeonhole it is not injective, so there exist `i < j` with `(F(i), F(i+1)) ≡ (F(j), F(j+1)) (mod m)`. The Fibonacci step `(a,b) ↦ (b, a+b)` is invertible over `ℤ/mℤ` (its inverse is `(a,b) ↦ (b−a, a)`), so the congruence can be propagated downward from index `i` to index `0`, yielding `F(j−i) ≡ F(0) = 0 (mod m)` with `j − i > 0`. Hence `k = j − i` works. ∎

This is exactly the Pisano-period argument; the entry point is the least positive `k` it produces.

### 2.3 Definition of the map

> **Definition 2.3 (Rank of apparition).** For `m > 0`, the **entry point** (rank of apparition) is
> ```
> entry(m) = min { k > 0 : m | F(k) },
> ```
> well defined by Proposition 2.2. We record two immediate properties:
> - **(E1) Positivity:** `entry(m) > 0`.
> - **(E2) Membership:** `m | F(entry(m))`.

---

## 3. The apparition law as an adjunction

The structural pivot of the entire development is the following.

> **Theorem 3.1 (Apparition law).** For every `m > 0` and every `n`,
> ```
> m | F(n)   ⟺   entry(m) | n.
> ```
>
> *Proof sketch.* (⟸) If `entry(m) | n`, then `F(entry(m)) | F(n)` by the forward divisibility law, and `m | F(entry(m))` by (E2); compose. (⟹) Suppose `m | F(n)`. Using (★), `m | gcd(F(entry(m)), F(n)) = F(gcd(entry(m), n))`, so `gcd(entry(m), n)` is a positive apparition index for `m`. By minimality of `entry(m)` and `gcd(entry(m), n) ≤ entry(m)`, we get `gcd(entry(m), n) = entry(m)`, i.e. `entry(m) | n`. ∎

### 3.1 The categorical reading

Theorem 3.1 has the exact shape of a **Galois connection** between the poset `(ℕ₊, ∣)` and itself:

```
entry(m) | n   ⟺   m | F(n).
```

That is, `entry ⊣ F`: `entry` is the **left adjoint** and the Fibonacci map `F` (restricted to apparition-relevant indices) is the **right adjoint**. Two general consequences of being a left adjoint will be invoked:

- **(A1) Left adjoints preserve joins.** Hence `entry` should send `lcm` to `lcm`.
- **(A2) Left adjoints need not preserve meets.** Hence `entry` is *not* expected to send `gcd` to `gcd`; at best a lax inequality `entry(gcd) | gcd(entry)` holds.

The remainder of the paper makes (A1) and (A2) precise and proves them elementarily, by hand, directly from Theorem 3.1 — confirming that no further appeal to the recurrence is needed.

---

## 4. Main results

Throughout, `a, b > 0`. Positivity of `lcm(a,b)` and of `F(k)` for the relevant indices is routine and suppressed.

### 4.1 Unitality

> **Theorem 4.1 (Unital).** `entry(1) = 1`.
>
> *Proof.* `1 | F(k)` for all `k`, so by Theorem 3.1, `entry(1) | n` for all `n`. Taking `n = 1` gives `entry(1) | 1`, hence `entry(1) = 1` (using `entry(1) > 0`). Equivalently, `1` is the least positive index with `1 | F(1) = 1`. ∎

The bottom element of the divisibility lattice is sent to the bottom element — the unitality required of a lattice homomorphism.

### 4.2 Monotonicity

> **Theorem 4.2 (Monotone for `∣`).** If `a | b` then `entry(a) | entry(b)`.
>
> *Proof.* By Theorem 3.1, `entry(a) | entry(b) ⟺ a | F(entry(b))`. Now `a | b` and `b | F(entry(b))` (property (E2)), so `a | F(entry(b))` by transitivity. ∎

This is order-preservation in the divisibility order, the monotone backbone underlying the join law.

### 4.3 The join-homomorphism law (central result)

> **Theorem 4.3 (Join homomorphism).** For all `a, b > 0`,
> ```
> entry(lcm(a, b)) = lcm(entry(a), entry(b)).
> ```
>
> *Proof.* By Lemma 2.1 it suffices to show, for every `n`, the equivalence of principal ideals
> ```
> entry(lcm(a,b)) | n   ⟺   lcm(entry(a), entry(b)) | n.
> ```
> Chase both sides through Theorem 3.1 and the lattice law (2.1) for `lcm`:
> ```
> entry(lcm(a,b)) | n
>   ⟺ lcm(a,b) | F(n)                         (apparition law, Thm 3.1)
>   ⟺ a | F(n)  ∧  b | F(n)                    (lcm divides, (2.1))
>   ⟺ entry(a) | n  ∧  entry(b) | n            (apparition law on each factor)
>   ⟺ lcm(entry(a), entry(b)) | n.            (lcm divides, (2.1))
> ```
> Both endpoints have the same principal ideal, so the two entry points are equal by Lemma 2.1. ∎

This is the categorical statement (A1) made arithmetic. Conceptually: a Fibonacci index supports a multiple of `lcm(a,b)` iff it simultaneously supports a multiple of `a` and a multiple of `b`; the set of such indices is the intersection of two arithmetic progressions `entry(a)·ℕ` and `entry(b)·ℕ`, whose common indices form the progression `lcm(entry(a), entry(b))·ℕ`. The least positive common index is `lcm(entry(a), entry(b))`.

### 4.4 Retraction of the Fibonacci map

> **Theorem 4.4 (`entry` retracts `F`).** For all `k ≥ 3`,
> ```
> entry(F(k)) = k.
> ```
>
> *Proof.* Two divisibilities, then antisymmetry.
> - `entry(F(k)) | k`: apply Theorem 3.1 with `m = F(k)`, `n = k`; the hypothesis `F(k) | F(k)` holds trivially.
> - `k | entry(F(k))`: by (E2), `F(k) | F(entry(F(k)))`; since `k ≥ 3`, the converse divisibility law (F3) gives `k | entry(F(k))`.
>
> Antisymmetry yields equality. ∎

Thus `entry ∘ F = id` on `{k : k ≥ 3}`, exhibiting `F` as a poset embedding of `(ℕ_{≥3}, ∣)` into `(ℕ₊, ∣)` on which `entry` is the retraction. The bound `k ≥ 3` is **sharp**: `F(1) = F(2) = 1` with `entry(1) = 1`, so the retraction equation fails at `k = 2` (it would assert `entry(1) = 2`). This is exactly the boundary where `F` ceases to be injective (cf. (F1)/(F2)), so the retraction is valid precisely where the embedding is.

---

## 5. Discussion: the adjoint synthesis and the meet defect

### 5.1 One law, four theorems

The conceptual payload is that **Theorems 4.1–4.4 require no Fibonacci input beyond the apparition law (Theorem 3.1).** Every proof reduces a divisibility question about `F` to a divisibility question about indices and then closes with elementary `ℕ`-arithmetic (`Nat.dvd_antisymm`, the `lcm` universal property, transitivity). The recurrence appears exactly once in the whole edifice — in establishing existence of the entry point (Proposition 2.2) — and is invisible thereafter. The apparition law is the *only* interface between Fibonacci-specific content and the order theory.

### 5.2 Why joins succeed and meets fail

Reading Theorem 3.1 as the adjunction `entry ⊣ F` immediately classifies which structure survives:

- **Joins are preserved** because `entry` is a *left* adjoint (A1); this is Theorem 4.3.
- **Meets are not preserved** because left adjoints only laxly interact with meets (A2). The lax inequality that *does* hold follows from monotonicity (Theorem 4.2): since `gcd(a,b) | a` and `gcd(a,b) | b`,
  ```
  entry(gcd(a,b)) | entry(a)   and   entry(gcd(a,b)) | entry(b),
  ```
  hence by (2.1)
  ```
  entry(gcd(a,b)) | gcd(entry(a), entry(b)).                          (5.1)
  ```
  The *direction* of (5.1) is forced; equality is not.

**The defect is real.** Take `a = 3`, `b = 7`. Then `gcd(3,7) = 1`, so `entry(gcd(3,7)) = entry(1) = 1`. But `entry(3) = 4`, `entry(7) = 8`, so `gcd(entry(3), entry(7)) = gcd(4, 8) = 4 ≠ 1`. The lax inequality `1 | 4` holds (consistent with (5.1)), while the naive equality `entry(gcd) = gcd(entry)` fails by a factor of `4`. This single counterexample certifies that `entry` is *not* a meet-homomorphism, in exact agreement with the categorical prediction (A2).

### 5.3 Application: assembling apparition data of composite moduli

The join law is precisely the tool needed to compute apparition data of a composite modulus from its prime-power parts. If `m = ∏ pᵢ^{eᵢ}`, then `m = lcm_i(pᵢ^{eᵢ})` (the prime powers are pairwise coprime, so their lcm is their product), and by iterating Theorem 4.3,
```
entry(m) = lcm_i ( entry(pᵢ^{eᵢ}) ).                                  (5.2)
```
This reduces the global problem to the local problems `entry(p^e)`, which are exactly the quantities tabulated in Lucas-sequence primality work (the rank of apparition modulo a prime power, governed by the law of apparition for `p` and its `p`-adic lifting). Formula (5.2) is the structural justification for that prime-power reduction; the monotonicity law (Theorem 4.2) supplies the divisibility containments used to bound and certify the local data.

---

## 6. Algorithms

### 6.1 Computing the entry point (rank of apparition)

The naive definition computes `F(k) mod m` for `k = 1, 2, 3, …` until a zero residue appears, requiring only `O(1)` integers of size `< m` if Fibonacci residues are advanced iteratively modulo `m`. The number of steps is `entry(m)`, which is bounded by the Pisano period `π(m) ≤ 6m`, so the procedure is `O(m)` modular additions in the worst case. (For large `m` one factors `m` and applies (5.2), reducing to the prime-power cases.)

```
function ENTRY(m):                       # m ≥ 1
    if m == 1: return 1
    a, b := 0, 1                         # a = F(0) mod m, b = F(1) mod m
    k := 1
    while b != 0:
        a, b := b, (a + b) mod m         # advance one Fibonacci step mod m
        k := k + 1
    return k
```

### 6.2 Verifying the join-homomorphism law

```
function CHECK_JOIN(N):                   # verifies Theorem 4.3 for all a,b ≤ N
    for a in 1..N:
      for b in 1..N:
        if ENTRY(lcm(a,b)) != lcm(ENTRY(a), ENTRY(b)):
            return ("counterexample", a, b)     # never occurs
    return "join law holds on all pairs ≤ N"
```

### 6.3 Composite reduction via prime powers (Formula (5.2))

```
function ENTRY_VIA_FACTORS(m):
    if m == 1: return 1
    result := 1
    for (p, e) in factorize(m):                  # m = ∏ p^e
        result := lcm(result, ENTRY(p^e))         # iterate join law (Thm 4.3)
    return result                                 # == ENTRY(m)
```

---

## 7. Related work and context

The gcd identity (★) and the forward divisibility law are classical (Lucas, 19th century). The rank of apparition and the law of apparition (Theorem 3.1) are likewise classical for Lucas sequences and underlie Lucas–Lehmer–style primality testing. What is new here is the explicit, formally verified treatment of `entry` as a **morphism of divisibility lattices**, organized through the **adjunction** `entry ⊣ F`, and in particular the join-homomorphism law (Theorem 4.3) together with the structural explanation of the meet defect (Section 5.2). These lattice-theoretic statements are not present in standard libraries, and the adjoint viewpoint cleanly separates the one piece of genuine Fibonacci input (Proposition 2.2 / Theorem 3.1) from the formal consequences.

---

## 8. Future directions

### 8.1 The meet defect, quantified
Conjecture: for all `a, b > 0`, the lax containment `entry(gcd(a,b)) | gcd(entry(a), entry(b))` of (5.1) is an equality iff `a` and `b` are powers of a single common prime, and otherwise the quotient
```
gcd(entry(a), entry(b)) / entry(gcd(a,b))
```
can be made arbitrarily large. This would pin the morphism's type exactly: it is a join-homomorphism that fails to be a meet-homomorphism by an unbounded but precisely characterizable amount. The easy containment is already in hand from Theorem 4.2; the falsifiable content (unbounded defect) is a finite search away.

### 8.2 Coprime multiplicativity and prime-power reduction
Conjecture: for coprime `a, b > 0`, `entry(a·b) = lcm(entry(a), entry(b))`, hence `entry(m)` is determined by its prime-power values `entry(p^e)`. Since `lcm(a,b) = a·b` for coprime `a,b`, this specializes Theorem 4.3 directly; formalizing it makes (5.2) a theorem rather than a derived formula and gives a complete reduction of `entry` to the prime-power case.

### 8.3 Toward general Lucas sequences
The only Fibonacci-specific inputs are the gcd identity (★) and entry-point existence (Proposition 2.2). Both hold, mutatis mutandis, for general non-degenerate Lucas sequences `U_n(P, Q)`. The adjoint framework should therefore transfer verbatim, yielding rank-of-apparition lattice homomorphisms for the entire Lucas family used in primality certificates — a uniform structural theory of apparition for strong divisibility sequences.

---

## Appendix A. Worked numerical table

| m | entry(m) | first multiple F(entry(m)) |
|---|---|---|
| 1 | 1 | F(1) = 1 |
| 2 | 3 | F(3) = 2 |
| 3 | 4 | F(4) = 3 |
| 4 | 6 | F(6) = 8 |
| 5 | 5 | F(5) = 5 |
| 6 | 12 | F(12) = 144 |
| 7 | 8 | F(8) = 21 |
| 8 | 6 | F(6) = 8 |
| 10 | 15 | F(15) = 610 |
| 13 | 7 | F(7) = 13 |

Join-law checks: `entry(lcm(2,3)) = entry(6) = 12 = lcm(3,4) = lcm(entry(2), entry(3))`; `entry(lcm(2,5)) = entry(10) = 15 = lcm(3,5) = lcm(entry(2), entry(5))`. Retraction check: `entry(F(7)) = entry(13) = 7`. Meet defect: `entry(gcd(3,7)) = entry(1) = 1` but `gcd(entry(3), entry(7)) = gcd(4,8) = 4`.
