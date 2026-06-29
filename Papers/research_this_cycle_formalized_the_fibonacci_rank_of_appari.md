# The Fibonacci Rank of Apparition as a Local-to-Global Sheaf

## Abstract

The *rank of apparition* of a modulus `m`, written `rank(m)`, is the least
positive index `k` for which `m` divides the Fibonacci number `F(k)`. We
develop `rank` as a structure-preserving dictionary — a local-to-global section
over the divisibility lattice of moduli — and establish four interlocking
results. (1) The **law of apparition**: for `m > 0`, `m ∣ F(n)` if and only if
`rank(m) ∣ n`. Crucially, the existence of the rank is obtained *structurally*,
not analytically: the Fibonacci shift `(a, b) ↦ (b, a + b)` is a permutation of
the finite set `(Z/mZ)²` (its inverse is `(a, b) ↦ (b − a, a)`), so its orbit
through `(0, 1)` must return, forcing some positive `F(k) ≡ 0 (mod m)`. (2) The
**primitivity bridge**: `m` is a primitive divisor of `F(n)` if and only if
`rank(m) = n`; this collapses an avoidance condition over all earlier indices
into a single local equation, recasting the foundation of Carmichael's
primitive-divisor theorem in stalk-level terms. (3) The **gluing law**: for
coprime `a, b`, `rank(a·b) = lcm(rank(a), rank(b))`, exhibiting `rank` as a
join-morphism. (4) The **local-to-global reconstruction**:
`rank(n) = lcm_{p ∣ n} rank(p^{v_p(n)})`, reconstructing the global rank from
prime-power stalks. All results are formalized and machine-checked with no
unproven steps, relying only on the standard foundational axioms. We give full
statements, proof sketches, algorithms, applications, and open problems.

**Keywords:** Fibonacci numbers, rank of apparition, entry point, Pisano period,
strong divisibility sequence, primitive divisors, Carmichael's theorem,
local-to-global, sheaf, lattice morphism.

---

## 1. Introduction

The Fibonacci sequence `F` is defined by `F(0) = 0`, `F(1) = 1`, and
`F(n+2) = F(n) + F(n+1)`. Among its many arithmetic regularities, the most
fundamental is the *rank of apparition* (also called the *entry point* or
*Fibonacci entry point*): for a modulus `m`, the smallest positive index at
which `m` divides a Fibonacci number. Empirically, the set of indices `n` with
`m ∣ F(n)` is always the set of multiples of this single number. Our purpose is
to give a self-contained, fully verified development of this phenomenon and to
organize it under a single conceptual banner: **`rank` is a local-to-global
section over the divisibility site of moduli.**

The Fibonacci sequence is a *strong divisibility sequence*: it satisfies the
identity `gcd(F(m), F(n)) = F(gcd(m, n))`. This single identity, together with a
finiteness argument for existence, is the engine behind every result below.

The development is organized into a *spine* (existence and the core
biconditional) and a *new layer* (the four headline theorems). We summarize the
spine in §2, prove the headline results in §3–§6, give algorithms in §7,
applications in §8, and open directions in §9.

### Results at a glance

| Name | Statement | Hypotheses |
|---|---|---|
| `fib_dvd_iff_fibRank_dvd` | `m ∣ F(n) ⇔ rank(m) ∣ n` | `m > 0` |
| `isPrimitive_iff_fibRank_eq` | `IsPrimitive(m, n) ⇔ rank(m) = n` | `m, n > 0` |
| `fibRank_mul_coprime` | `rank(a·b) = lcm(rank a, rank b)` | `gcd(a,b)=1` |
| `fibRank_finset_prod_coprime` | `rank(∏ f) = lcm_i rank(f i)` | pairwise coprime |
| `fibRank_eq_factorization_lcm` | `rank(n) = lcm_{p∣n} rank(p^{v_p(n)})` | — |

---

## 2. The spine: definitions and the existence theorem

### 2.1 Having a rank

**Definition (HasFibRank).** A modulus `m` *has a rank of apparition* if it
divides some positive-index Fibonacci number:
`HasFibRank(m) :≡ ∃ k, 0 < k ∧ m ∣ F(k)`.

### 2.2 The Fibonacci shift permutation

**Definition (fibStep).** For a modulus `m`, the *Fibonacci shift* is the map on
pairs over `Z/mZ`
```
fibStep(m) : (Z/mZ)² → (Z/mZ)²,   (a, b) ↦ (b, a + b),
```
with two-sided inverse `(a, b) ↦ (b − a, a)`. The inverse encodes the
*reversibility* of the recurrence: `F(k−1) = F(k+1) − F(k)`. Being invertible,
`fibStep(m)` is an honest permutation of the finite set `(Z/mZ)²`.

**Lemma (fibStep_iterate).** Iterating the shift from the seed `(0, 1)` yields
consecutive Fibonacci pairs:
```
fibStep(m)^[k] (0, 1) = (F(k) mod m,  F(k+1) mod m).
```
*Proof sketch.* Induction on `k`. The base case `k = 0` is `(0, 1)`. The step
uses `fibStep`'s definition and `F(k+2) = F(k) + F(k+1)`. ∎

### 2.3 Existence of the rank

**Theorem (hasFibRank_of_pos).** Every `m > 0` has a rank of apparition.

*Proof sketch.* The map `n ↦ (F(n) mod m, F(n+1) mod m)` takes values in the
finite set `(Z/mZ)²`, so it cannot be injective; by pigeonhole there exist
`i < j` with `F(i) ≡ F(j)` and `F(i+1) ≡ F(j+1) (mod m)`. By `fibStep_iterate`,
this says `fibStep(m)^[i](0,1) = fibStep(m)^[j](0,1)`. Since `fibStep(m)` is a
*permutation*, it is injective, so we may cancel (equivalently, apply the inverse
`i` times) to back-step both sides to index 0, obtaining
`fibStep(m)^[j−i](0,1) = (0,1)`. Reading the first coordinate gives
`F(j−i) ≡ 0 (mod m)` with `j − i > 0`, i.e. `m ∣ F(j−i)`. ∎

The argument is purely finite and structural: the *size* of Fibonacci numbers
is never used, only the invertibility of the recurrence modulo `m`. This is the
abstract mechanism underlying the **Pisano period**.

### 2.4 The rank function and its basic properties

**Definition (fibRank).**
`rank(m) = fibRank(m) := Nat.find` of the predicate `∃ k, 0 < k ∧ m ∣ F(k)` when
it holds, and `0` otherwise. For `m ≥ 1`, existence is `hasFibRank_of_pos`.

The least-element characterization yields three immediate facts:

- **fibRank_pos:** if `HasFibRank(m)` then `rank(m) > 0`.
- **dvd_fib_fibRank:** if `HasFibRank(m)` then `m ∣ F(rank(m))`.
- **fibRank_min:** for `0 < k < rank(m)`, `¬ (m ∣ F(k))` (minimality).

### 2.5 The core biconditional

**Theorem (fibRank_dvd_iff).** If `HasFibRank(m)`, then for all `n`,
`m ∣ F(n) ⇔ rank(m) ∣ n`.

*Proof sketch.* Write `r = rank(m)`; we know `r > 0` and `m ∣ F(r)`.

(⇐) If `r ∣ n`, then `F(r) ∣ F(n)` because Fibonacci is a divisibility sequence
(`Nat.fib_dvd`), and `m ∣ F(r) ∣ F(n)`.

(⇒) Suppose `m ∣ F(n)` but, for contradiction, `r ∤ n`. Let `g = gcd(r, n)`.
Then `g < r` (a proper divisor of `r`, since `r ∤ n`). The strong divisibility
identity `gcd(F(r), F(n)) = F(gcd(r, n)) = F(g)` (`Nat.fib_gcd`) combined with
`m ∣ F(r)` and `m ∣ F(n)` gives `m ∣ gcd(F(r), F(n)) = F(g)`. But `g > 0` and
`g < r`, contradicting minimality `fibRank_min`. ∎

This biconditional is the workhorse: every headline theorem is a corollary.

---

## 3. The law of apparition

**Theorem (fib_dvd_iff_fibRank_dvd).** For `m > 0` and any `n`,
```
m ∣ F(n)  ⇔  rank(m) ∣ n.
```

*Proof.* Combine `hasFibRank_of_pos(m)` (existence) with `fibRank_dvd_iff`
(the core biconditional). ∎

**Interpretation.** The set `{ n : m ∣ F(n) }` is exactly the set of multiples
of `rank(m)`. The law is a faithful dictionary between two divisibility
lattices: the lattice of *moduli* (ordered by `∣`) and the lattice of *indices*
(ordered by `∣`). Everything that follows is a structural consequence of this
one fact.

**Examples.** `rank(2) = 3` (F(3)=2); `rank(7) = 8` (F(8)=21); `rank(11) = 10`
(F(10)=55). Hence 7 divides exactly F(8), F(16), F(24), ....

---

## 4. The primitivity bridge

**Definition (IsPrimitive).** `m` is a *primitive divisor* of `F(n)` if it
divides `F(n)` but no earlier positive-index Fibonacci number:
```
IsPrimitive(m, n) :≡ m ∣ F(n)  ∧  ∀ k, 0 < k → k < n → ¬ (m ∣ F(k)).
```

**Theorem (isPrimitive_iff_fibRank_eq).** For `m, n > 0`,
```
IsPrimitive(m, n)  ⇔  rank(m) = n.
```

*Proof sketch.*

(⇒) Suppose `IsPrimitive(m, n)`. From `m ∣ F(n)` and the law of apparition,
`rank(m) ∣ n`, so `rank(m) ≤ n`. If `rank(m) < n`, then `m ∣ F(rank(m))` with
`0 < rank(m) < n` contradicts the avoidance clause of primitivity. Hence
`rank(m) = n`.

(⇐) Suppose `rank(m) = n`. Then `m ∣ F(rank(m)) = F(n)` (`dvd_fib_fibRank`),
establishing the divisibility clause. For the avoidance clause, take any `k` with
`0 < k < n = rank(m)`; minimality (`fibRank_min`) gives `¬ (m ∣ F(k))`. ∎

**Significance.** The naive definition of primitivity is a *global avoidance
condition*: a quantified statement over *all* earlier indices. The bridge
collapses it to a single *local* equation `rank(m) = n`. This is precisely the
reformulation needed to attack R. D. Carmichael's primitive-divisor theorem
(1913): every Fibonacci number `F(n)` with `n ∉ {1, 2, 6, 12}` possesses a
primitive prime divisor. Under the bridge, "F(n) has a primitive divisor"
becomes "some prime `p` has `rank(p) = n`," converting an existence-of-avoidance
statement into an existence-of-rank-value statement amenable to Lifting-the-
Exponent estimates on the *primitive part* of `F(n)`.

A small supporting lemma (`nat_eq_of_dvd_iff`): if `d ∣ k ⇔ e ∣ k` for all `k`,
then `d = e` (apply at `k = e` and `k = d` and use antisymmetry of `∣`). This
lets one promote the law of apparition's pointwise divisibility equivalence to
genuine equalities of ranks, which is the technical key to the gluing laws.

---

## 5. The gluing law for coprime products

**Theorem (fibRank_mul_coprime).** If `gcd(a, b) = 1` (and `a, b > 0`), then
```
rank(a·b) = lcm(rank(a), rank(b)).
```

*Proof sketch.* Use `nat_eq_of_dvd_iff`: it suffices to show, for every index
`n`,
```
rank(a·b) ∣ n  ⇔  lcm(rank a, rank b) ∣ n.
```
Chase both sides through the law of apparition and coprimality:
```
rank(a·b) ∣ n
  ⇔ a·b ∣ F(n)                         (law of apparition)
  ⇔ a ∣ F(n)  ∧  b ∣ F(n)              (a, b coprime ⇒ a·b ∣ x ⇔ a∣x ∧ b∣x)
  ⇔ rank(a) ∣ n  ∧  rank(b) ∣ n        (law of apparition, twice)
  ⇔ lcm(rank a, rank b) ∣ n.           (universal property of lcm)
```
Since the two ranks divide exactly the same set of `n`, they are equal. ∎

**Interpretation.** `rank` is a **join-morphism**: it carries the join (lcm) on
coprime moduli to the join (lcm) on indices. The coprimality hypothesis is what
turns "divides the product" into "divides each factor," the CRT-style splitting
that makes the stalks independent.

**Worked example.** `rank(4) = 6`, `rank(9) = 12`, so
`rank(36) = lcm(6, 12) = 12`; indeed F(12) = 144 = 36 · 4.

---

## 6. Local-to-global reconstruction

### 6.1 Arbitrary coprime families

**Theorem (fibRank_finset_prod_coprime).** Let `f : ι → ℕ` be a family that is
pairwise coprime on a finite set `S` (with each `f i > 0`). Then
```
rank(∏_{i ∈ S} f i) = lcm_{i ∈ S} rank(f i),
```
where the right-hand side is the `Finset.lcm` of the ranks.

*Proof sketch.* Induction on `S` using `fibRank_mul_coprime` at each insertion
step. When a new index `j` is added, the product over `S` is coprime to `f j`
(pairwise coprimality), so the binary gluing law applies:
`rank(f j · ∏_S f) = lcm(rank(f j), rank(∏_S f)) = lcm(rank(f j), lcm_S rank)`.
Associativity of `lcm` finishes the induction. ∎

### 6.2 The prime-power reconstruction

**Theorem (fibRank_eq_factorization_lcm).** For any `n`,
```
rank(n) = lcm_{p ∈ supp(n)} rank(p^{v_p(n)}),
```
where `supp(n)` is the set of prime divisors of `n` and `v_p(n)` is the
`p`-adic valuation (the exact exponent of `p` in `n`).

*Proof sketch.* The prime-power components `p^{v_p(n)}` for distinct primes `p`
are pairwise coprime, and their product is `n` (unique factorization). Apply
`fibRank_finset_prod_coprime` with `f(p) = p^{v_p(n)}` over `S = supp(n)`. ∎

**Interpretation — the sheaf picture.** This is the local-to-global statement in
full. Think of the divisibility order on moduli as the underlying *site*; to
each prime-power "point" `p^{v_p(n)}` attach the *stalk datum* `rank(p^{v_p(n)})`;
the gluing law guarantees these local data are compatible; and the global
*section* `rank(n)` is reconstructed as their lcm. The rank function is, in this
precise sense, a section of a sheaf of apparition over the divisibility site.

**Worked example.** `60 = 2² · 3 · 5`; `rank(4) = 6`, `rank(3) = 4`,
`rank(5) = 5`; therefore `rank(60) = lcm(6, 4, 5) = 60`.

---

## 7. Algorithms

### 7.1 Direct rank via the shift permutation

The existence proof is constructive. Iterate `fibStep` modulo `m` from `(0, 1)`
until the first coordinate is `0`; the number of steps is `rank(m)`. This uses
`O(rank(m))` modular additions and `O(1)` memory (two residues), never forming a
large Fibonacci number.

```
function fibRankDirect(m):
    if m == 1: return 1
    a, b ← 0, 1
    k ← 0
    repeat:
        a, b ← b, (a + b) mod m
        k ← k + 1
    until a == 0
    return k
```

### 7.2 Rank by local-to-global reconstruction

For composite `m`, factor `m = ∏ p^e`, compute each prime-power rank by §7.1,
and take the lcm (Theorem `fibRank_eq_factorization_lcm`). This replaces one long
walk of length `rank(m)` (which can be as large as `m` or `6m/5`) by several
short walks of length `rank(p^e)`.

```
function fibRankFactored(m):
    if m == 1: return 1
    result ← 1
    for each prime power p^e in factorization(m):
        result ← lcm(result, fibRankDirect(p^e))
    return result
```

### 7.3 Verifying primitivity

By the bridge (Theorem `isPrimitive_iff_fibRank_eq`), `IsPrimitive(m, n)` reduces
to the single test `fibRank(m) == n`, avoiding the naive `O(n)` scan over all
earlier Fibonacci numbers.

---

## 8. Applications

1. **Computing entry points at scale.** The reconstruction theorem turns a
   global walk into a handful of short local walks, the standard speedup for
   tabulating Fibonacci entry points.

2. **Primitive divisors and Carmichael's theorem.** The bridge restates "F(n)
   has a primitive prime divisor" as "some prime has rank exactly `n`," the
   reformulation used in Lifting-the-Exponent attacks on the primitive-divisor
   problem.

3. **Primality and pseudoprime tests.** For a prime `p`, the rank divides
   `p − (5/p)` (the Legendre symbol), so entry points feed Fibonacci-based
   primality and Lucas pseudoprime tests.

4. **Pisano periods.** The shift permutation `fibStep(m)` has order equal to the
   Pisano period `π(m)`, and `rank(m) ∣ π(m)` with quotient in `{1, 2, 4}`.
   The same permutation-group datum that produces `rank` (its order on the orbit
   of `(0,1)`) produces `π` (its full order), unifying the two invariants.

5. **General Lucas sequences.** The only property of `F` actually used is the
   invertibility of the companion matrix `[[0,1],[1,1]]` modulo `m`. For a Lucas
   sequence `U(P, Q)`, the matrix `[[0,1],[−Q,P]]` is invertible modulo `m`
   exactly when `gcd(Q, m) = 1`, pinpointing the natural domain on which the
   entire theory lifts verbatim.

---

## 9. Discussion and future work

The development illustrates a recurring theme: **local data, correctly glued,
determines global structure.** The rank function is an exact join-morphism
between two divisibility lattices, and the prime-power decomposition
reconstructs every global rank from local stalk ranks. Two structural facts
deserve emphasis. First, existence is *structural*, not analytic: a reversible
move on a finite set must cycle, so apparition is forced without any growth
estimate. Second, primitivity is *rank-maximality*: an avoidance condition over
all earlier indices is exactly a single rank equation.

### Open directions

**(1) Closing the Carmichael tail via stalks.** A primitive divisor of `F(n)`
exists for composite `13 ≤ n ≤ 10000` by direct computation, with the infinite
tail `n > 10000` open. *Conjecture:* every composite `n ≥ 13` admits a prime `p`
with `rank(p) = n`, produced uniformly from a Lifting-the-Exponent bound on the
primitive part `primPart(n) = F(n) / ∏_{d ∣ n, d < n}(local factors)`. The bridge
converts "primitive divisor exists" into "some prime has rank exactly `n`," and a
prime fails to have rank `n` only if it divides an earlier `F(d)` (`d ∣ n`,
`d < n`); LTE bounds the multiplicity such primes can carry, so once `F(n)` is
large enough the primitive part exceeds 1.

**(2) The meet (gcd) obstruction as a cohomological defect.** The join law
`rank(lcm(a,b)) = lcm(rank a, rank b)` is exact, but the meet law fails:
`rank(gcd(a, b)) ∣ gcd(rank a, rank b)` is strict in general (witness `a = 4`,
`b = 6`). *Conjecture:* the defect `δ(a, b) := gcd(rank a, rank b)/rank(gcd a b)`
is multiplicative in the prime stalks and equals `1` exactly when no prime
sub-divides both ranks beyond their gcd — i.e. `δ` is the order of a 1-cocycle
obstruction to `rank` being a full lattice homomorphism. With the prime-power
reconstruction in hand, `δ(a, b)` reduces to a finite product over
`supp(a) ∩ supp(b)`, making multiplicativity a decidable target.

**(3) The global period sheaf.** Let `π(m)` be the Pisano period. Classically
`rank(m) ∣ π(m)` with `π(m)/rank(m) ∈ {1, 2, 4}`. *Conjecture:* `m ↦ π(m)` is the
global section of the same sheaf, with `π(lcm(a,b)) = lcm(π a, π b)` and
`π(p^{k+1}) = p · π(p^k)` for `p` not a Wall–Sun–Sun prime; the ratio
`π(m)/rank(m)` is locally constant on stalks. The key is `π(m) = orderOf(fibStep m)`
— the same finite-group datum that produced `rank`, read globally.

**(4) Apparition for arbitrary Lucas sequences.** Replace `F` by a
non-degenerate Lucas sequence `U(P, Q)` (a strong divisibility sequence when
`gcd(P, Q) = 1`). *Conjecture:* every theorem lifts verbatim — existence via the
shift `(a, b) ↦ (b, P·b − Q·a)` (a permutation of `(Z/mZ)²` when `gcd(Q, m) = 1`),
the law of apparition, the primitivity bridge, and the reconstruction — yielding
a `rank_{P,Q}` presheaf on moduli coprime to `Q`. The natural site is pinned down
by invertibility of `[[0,1],[−Q,P]]` modulo `m`.

**(5) The inverse problem and the fibers of `rank`.** `rank` maps the moduli
lattice onto the index lattice. *Conjecture:* for each index `n`, the fiber
`{ m : rank(m) = n }` has a maximum element `M(n) = primPart(n)` (every modulus of
rank `n` divides `M(n)`), so the fiber is exactly the divisor set of `M(n)` minus
moduli of strictly smaller rank, and `n ↦ M(n)` is multiplicative-up-to-gcd. The
bridge identifies the fiber of `rank` at `n` with the divisors of `F(n)` avoiding
all earlier `F(d)` — exactly the primitive part.

---

## 10. Conclusion

We have presented a compact, fully verified theory of the Fibonacci rank of
apparition organized around a single principle: `rank` is a local-to-global
section over the divisibility site of moduli. Four theorems — the law of
apparition, the primitivity bridge, the coprime gluing law, and the prime-power
reconstruction — show that the global arithmetic of Fibonacci divisibility is
glued, exactly and predictably, from local prime-power data. The engine
throughout is elementary and structural: the Fibonacci recurrence is a
reversible permutation of a finite state space, and that single fact forces
apparition, drives the divisibility dictionary, and underlies the gluing laws
that reconstruct the whole from its parts.
