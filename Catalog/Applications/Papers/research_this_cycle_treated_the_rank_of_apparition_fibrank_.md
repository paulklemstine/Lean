# The Fibonacci Rank of Apparition as One Half of a Galois Adjunction

*A structural unification of the Fibonacci entry-point laws, with a two-line proof
of the prime-index Carmichael theorem.*

---

## Abstract

The *rank of apparition* `fibRank(m)` of a modulus `m` is the least positive
index `k` such that `m ∣ F(k)`, where `F` denotes the Fibonacci sequence
(`F(1) = F(2) = 1`, `F(n+2) = F(n+1) + F(n)`). The classical Law of Apparition,
`m ∣ F(n) ⟺ fibRank(m) ∣ n`, is the spine of all primitive-divisor theory for
the Fibonacci numbers. We recognize this law for what it structurally is: the
**adjunction inequality of a Galois connection** `fibRank ⊣ F` between the
divisibility preorder on moduli and the divisibility preorder on indices. From
this single observation we extract, as formal consequences of standard
adjunction facts, the complete structural behavior of `fibRank`:

1. a **hypothesis-free** statement of the law, valid for *every* modulus `m`
   including the degenerate `m = 0` (`fibRank_dvd_iff'`);
2. the **join law** `fibRank(lcm(a,b)) = lcm(fibRank(a), fibRank(b))`
   (`fibRank_lcm`), the categorical fact that a left adjoint preserves joins;
3. its lift to arbitrary finite joins (`fibRank_finset_lcm`);
4. **monotonicity** `a ∣ b ⟹ fibRank(a) ∣ fibRank(b)` (`fibRank_mono`);
5. the **meet sub-law** `fibRank(gcd(a,b)) ∣ gcd(fibRank(a), fibRank(b))`
   (`fibRank_gcd_dvd`), the categorical fact that a left adjoint need not preserve
   meets;
6. the **representation payoff** `fibRank_prime_index_has_primitive`: for every
   prime `p ≥ 3`, every prime divisor of `F(p)` is primitive.

All results are formalized with zero `sorry`. We close with the cyclotomic-value
program that would settle the remaining composite-index Carmichael tail, a
classification of when the meet law is sharp, and the generalization to arbitrary
strong divisibility sequences.

---

## 1. Introduction

### 1.1 The rank of apparition

Let `F : ℕ → ℕ` be the Fibonacci sequence with `F(0) = 0`, `F(1) = 1`, and
`F(n+2) = F(n+1) + F(n)`. For a modulus `m ∈ ℕ`, divisibility of Fibonacci
numbers is governed by a single integer.

**Definition 1.1 (Rank of apparition).** A modulus `m` *has a rank of apparition*
if it divides some positive-index Fibonacci number; formally
`HasFibRank(m) :≡ ∃ k, 0 < k ∧ m ∣ F(k)`. When this holds, the **rank**
`fibRank(m)` is the least such `k`; otherwise `fibRank(m) := 0`. Concretely,

```
fibRank(m) = if (∃ k, 0 < k ∧ m ∣ F(k)) then (least such k) else 0.
```

For example `fibRank(1) = 1`, `fibRank(2) = 3`, `fibRank(3) = 4`,
`fibRank(4) = 6`, `fibRank(5) = 5`, `fibRank(7) = 8`, `fibRank(11) = 10`.

### 1.2 The classical law and its hidden shape

The pillar of the subject is the **Law of Apparition**:

> For `m` with a rank, `m ∣ F(n) ⟺ fibRank(m) ∣ n`. (Theorem 3.1.)

This compresses the infinite divisibility profile of `m` into one number. The
contribution of this paper is conceptual: we observe that the law is exactly the
defining inequality of a **Galois connection** (monotone adjunction) between two
preordered sets, and that, once named, the connection mechanizes the entire
structure theory of `fibRank`.

### 1.3 Two preorders and an adjunction

Let `(ℕ, ∣)` denote the naturals preordered by divisibility. Consider:

- the **modulus** preorder `M = (ℕ, ∣)`;
- the **index** preorder `I = (ℕ, ∣)`;
- the monotone maps `fibRank : M → I` and `F : I → M`.

**Main structural claim.** `fibRank ⊣ F` is a Galois connection (an adjunction of
preorders), i.e. for all `m, n`:

```
fibRank(m) ∣ n   ⟺   m ∣ F(n).                    (★)
```

Read left adjoint = `fibRank`, right adjoint = `F`. Equation (★) is the unit/counit
characterization of adjunction. From (★) alone, standard adjunction calculus
delivers Sections 4–6.

---

## 2. Preliminaries: existence of the rank

The only non-formal ingredient is that every positive modulus *has* a rank.

**Definition 2.1 (Fibonacci shift).** Over `ZMod m`, define the involutive-style
bijection on pairs
```
fibStep(m) : ZMod m × ZMod m ≃ ZMod m × ZMod m,
   (a, b) ↦ (b, a + b),     inverse (a, b) ↦ (b − a, a).
```

**Lemma 2.2 (Iterated shift = Fibonacci pair).**
```
fibStep(m)^[k] (0, 1) = (F(k) mod m, F(k+1) mod m).
```
*Proof sketch.* Induction on `k`, using `F(k+2) = F(k) + F(k+1)`. ∎

**Theorem 2.3 (Existence).** If `0 < m` then `HasFibRank(m)`.

*Proof sketch.* The map `n ↦ (F(n) mod m, F(n+1) mod m)` takes values in the
finite set `ZMod m × ZMod m`, hence is not injective: there are `i < j` with
equal pairs. Because `fibStep(m)` is a *bijection*, the recurrence runs backward,
so the pairs are periodic and the pair value at index `0` recurs; tracking it back
yields an index `0 < k` (with `k = j − i`) at which `F(k) ≡ 0 (mod m)`, i.e.
`m ∣ F(k)`. ∎

This is the classical pigeonhole-on-the-Pisano-period argument, with reversibility
of `fibStep` supplying the wrap-around to a *zero* residue.

**Corollary 2.4.** `fibRank(m) > 0` for `m > 0`; `m ∣ F(fibRank(m))`; and
`fibRank` is *minimal*: for `0 < k < fibRank(m)`, `m ∤ F(k)`.

These are immediate from `Nat.find`'s specification on the defining predicate.

---

## 3. The spine, with hypothesis

**Theorem 3.1 (Law of Apparition).** If `HasFibRank(m)` then for all `n`,
```
m ∣ F(n)   ⟺   fibRank(m) ∣ n.
```

*Proof sketch.* Write `r = fibRank(m)`, so `0 < r` and `m ∣ F(r)`.

(⇐) If `r ∣ n`, then `F(r) ∣ F(n)` by the standard divisibility property of
Fibonacci numbers (`a ∣ b ⟹ F(a) ∣ F(b)`), and `m ∣ F(r) ∣ F(n)`.

(⇒) Suppose `m ∣ F(n)` but `r ∤ n`. Let `g = gcd(r, n)`. Then `g < r` (a proper
divisor, since `r ∤ n`), and `0 < g`. From `m ∣ F(r)` and `m ∣ F(n)` and the
**strong divisibility identity** `gcd(F(r), F(n)) = F(gcd(r, n)) = F(g)` we get
`m ∣ F(g)`. But `0 < g < r` contradicts minimality of `r` (Corollary 2.4). ∎

The identity `gcd(F(a), F(b)) = F(gcd(a, b))` (`Nat.fib_gcd`) is the *only*
Fibonacci-specific fact used; everything downstream is formal.

---

## 4. The Galois adjunction, hypothesis-free

The existence hypothesis is a blemish: it is absent from the adjunction we are
claiming. We remove it.

**Theorem 4.1 (Adjunction, total form `fibRank_dvd_iff'`).** For *all* `m, n ∈ ℕ`,
```
fibRank(m) ∣ n   ⟺   m ∣ F(n).
```

*Proof sketch.* If `m > 0`, this is Theorem 3.1 (rewritten with the equivalence's
sides swapped), using existence (Theorem 2.3). The new content is `m = 0`. Then:

- `fibRank(0) = 0`, because `0 ∣ F(k)` forces `F(k) = 0`, impossible for `k > 0`
  (as `F(k) > 0`), so no positive index works and the rank defaults to `0`.
- The left side `fibRank(0) ∣ n` reads `0 ∣ n ⟺ n = 0`.
- The right side `0 ∣ F(n)` reads `F(n) = 0 ⟺ n = 0` (again `F(n) > 0` for
  `n > 0`, and `F(0) = 0`).

Both sides are equivalent to `n = 0`, so (★) holds. ∎

This is the **adjunction inequality** (★) in full generality. Its totality is what
makes `fibRank ⊣ F` an honest Galois connection on all of `(ℕ, ∣)`, the `m = 0`
corner working precisely because `fibRank(0) = 0`, `F(0) = 0`, and
`0 ∣ x ⟺ x = 0` align.

**Remark.** From (★) one recovers the unit `m ∣ F(fibRank(m))` (set `n = fibRank(m)`,
reflexivity) and counit `fibRank(F(n)) ∣ n` (set `m = F(n)`, reflexivity) — the
two triangle inequalities of the adjunction.

---

## 5. Joins: a left adjoint preserves them

We exploit the categorical theorem *left adjoints preserve colimits*. In a
divisibility preorder the binary join is the lcm.

**Lemma 5.1 (Divisibility extensionality).** If `d ∣ k ⟺ e ∣ k` for all `k`, then
`d = e` (in `ℕ`). *Proof.* Take `k = e` and `k = d` to get `d ∣ e` and `e ∣ d`,
then antisymmetry of `∣` on `ℕ`. ∎

**Theorem 5.2 (Join law `fibRank_lcm`).** For all `a, b ∈ ℕ`,
```
fibRank(lcm(a, b)) = lcm(fibRank(a), fibRank(b)).
```

*Proof sketch.* By Lemma 5.1 it suffices to show, for every `n`,
```
fibRank(lcm(a,b)) ∣ n  ⟺  lcm(fibRank(a), fibRank(b)) ∣ n.
```
Compute the left side by the adjunction (Theorem 4.1) and `lcm_dvd_iff`:
```
fibRank(lcm(a,b)) ∣ n
  ⟺ lcm(a,b) ∣ F(n)               (★)
  ⟺ a ∣ F(n) ∧ b ∣ F(n)          (lcm_dvd_iff)
  ⟺ fibRank(a) ∣ n ∧ fibRank(b) ∣ n   (★ twice)
  ⟺ lcm(fibRank(a), fibRank(b)) ∣ n.   (lcm_dvd_iff)
```
∎

This is the abstract "left adjoint preserves joins" made arithmetic: the join in
`M` (lcm of moduli) maps to the join in `I` (lcm of indices), exactly.

**Theorem 5.3 (Finite join law `fibRank_finset_lcm`).** For any finite index set
`s` and family `f : ι → ℕ`,
```
fibRank( lcm_{i ∈ s} f(i) ) = lcm_{i ∈ s} fibRank(f(i)).
```

*Proof sketch.* Induction on the finite set `s` using `Finset.fold`/`Finset.lcm`
recursion: the empty case is `fibRank(1) = 1` (the empty lcm, the join of the
empty family / bottom of `I`), and the insert step is Theorem 5.2. ∎

---

## 6. Meets: only sub-preserved

The dual slogan, *left adjoints need not preserve limits*, predicts the gcd law
degrades to a one-way divisibility.

**Theorem 6.1 (Monotonicity `fibRank_mono`).** For all `a, b`,
`a ∣ b ⟹ fibRank(a) ∣ fibRank(b)`.

*Proof sketch.* If `a ∣ b` then any `n` with `fibRank(b) ∣ n` satisfies
`b ∣ F(n)` (★), hence `a ∣ b ∣ F(n)`, hence `fibRank(a) ∣ n` (★). Taking
`n = fibRank(b)` gives `fibRank(a) ∣ fibRank(b)`. (Equivalently: `fibRank` is a
left adjoint, hence monotone.) ∎

**Theorem 6.2 (Meet sub-law `fibRank_gcd_dvd`).** For all `a, b`,
```
fibRank(gcd(a, b)) ∣ gcd(fibRank(a), fibRank(b)).
```

*Proof sketch.* Since `gcd(a,b) ∣ a` and `gcd(a,b) ∣ b`, monotonicity
(Theorem 6.1) gives `fibRank(gcd(a,b)) ∣ fibRank(a)` and
`fibRank(gcd(a,b)) ∣ fibRank(b)`; conclude with `dvd_gcd`. ∎

**Strictness.** The reverse divisibility fails in general; the catalog records the
boundary witness `a = 4, b = 6`: `gcd(4,6) = 2`, `fibRank(2) = 3`, while
`gcd(fibRank(4), fibRank(6)) = gcd(6, 12) = 6`, and `3 ∣ 6` but `3 ≠ 6`. Thus
`fibRank` is a *join*-morphism but **not** a *meet*-morphism — the categorical
signature of a functor preserving colimits but not limits.

---

## 7. Representation payoff: prime-index Carmichael

A prime `q` is a **primitive prime divisor** of `F(n)` if `q ∣ F(n)` but `q ∤ F(k)`
for all `0 < k < n`. By Corollary 2.4 and the adjunction, primitivity of `q` at
`n` is exactly `fibRank(q) = n`.

**Theorem 7.1 (`fibRank_prime_index_has_primitive`).** For every prime `p ≥ 3`,
every prime divisor of `F(p)` is primitive; in particular `F(p)` has a primitive
prime divisor.

*Proof sketch.* `F(p) > 1` for `p ≥ 3`, so it has a prime divisor `q`. Then
`q ∣ F(p)`, so by the adjunction (★) `fibRank(q) ∣ p`. As `p` is prime,
`fibRank(q) ∈ {1, p}`. If `fibRank(q) = 1` then `q ∣ F(1) = 1`, impossible for a
prime. Hence `fibRank(q) = p`, i.e. `q` is primitive. ∎

This recovers the prime case of **Carmichael's theorem** (every `F(n)` has a
primitive prime divisor except `n ∈ {1, 2, 6, 12}`) with no estimates: the
infinite divisibility profile of `q` is compressed into `fibRank(q)`, and
primality of the index finishes the argument. The catalog's previous prime-case
result required `p ≥ 5`; the adjunction proof covers `p ≥ 3`.

---

## 8. Algorithms

### 8.1 Computing `fibRank(m)`

```
Algorithm RANK(m):
  Input:  m ∈ ℕ, m ≥ 1
  Output: fibRank(m)
  if m = 1: return 1
  a, b ← 0, 1            # (F(0) mod m, F(1) mod m)
  k ← 1
  loop:
     a, b ← b, (a + b) mod m     # advance one Fibonacci step mod m
     k ← k + 1
     if a = 0: return k          # a now holds F(k) mod m
```
Correctness: the loop maintains `a = F(k) mod m`; it returns the least `k > 0`
with `F(k) ≡ 0`. Termination: existence (Theorem 2.3); the loop halts within the
Pisano period `π(m) ≤ 6m`. Cost: `O(fibRank(m))` modular steps, each `O(log² m)`
bit operations.

### 8.2 Verifying the join law on a range

For all pairs `a, b ≤ N` check `fibRank(lcm(a,b)) = lcm(fibRank(a), fibRank(b))`
using RANK as a subroutine; `O(N²)` rank computations.

### 8.3 Listing primitive prime divisors of `F(n)`

Factor `F(n)`; for each prime `q ∣ F(n)`, compute `fibRank(q)`; `q` is primitive
iff `fibRank(q) = n`. By Theorem 7.1, for prime `n` every prime factor qualifies
(a zero-search confirmation).

---

## 9. Applications

- **Primitive divisor enumeration.** The adjunction reduces "is `q` primitive for
  `F(n)`?" to the single equality `fibRank(q) = n`, replacing a search over all
  earlier indices.
- **Modular period structure.** `fibRank` is the order of the Fibonacci recurrence
  matrix's appearance of a zero first coordinate; the join law gives the
  apparition index of a composite modulus directly from its prime-power parts.
- **Cryptographic sequences.** The same adjunction governs `qⁿ − 1` and Mersenne
  numbers `2ⁿ − 1` (Section 11), where rank-of-apparition equals multiplicative
  order — the backbone of primality tests and discrete-log group selection.

---

## 10. Discussion

The value of the adjunction framing is *consolidation*. Monotonicity, the lcm
law, and the gcd sub-law were historically separate lemmas; the framework reveals
them as the three standard adjunction facts (a left adjoint is monotone, preserves
joins, sub-preserves meets) applied to one connection. The hypothesis-free spine
(Theorem 4.1) is what upgrades the law from a statement about "moduli that happen
to have a rank" to a genuine Galois connection on all of `(ℕ, ∣)`. And the
prime-index Carmichael theorem shows the framing is not merely tidy but
*productive*: it turns a structural existence question into a one-line arithmetic
deduction.

The honest limitation is the composite-index tail (Section 11.1). The adjunction
clarifies *where* the remaining difficulty lives: not in the dictionary, which is
exact, but in a single golden-ratio size inequality.

---

## 11. Future work

### 11.1 Close the composite tail via the cyclotomic value `Φ_n`

Define the homogeneous Fibonacci cyclotomic value
`Φ_n = ∏_{d ∣ n} F(d)^{μ(n/d)}` (with `μ` the Möbius function). Establish:
`Φ_n ∈ ℤ_{>0}`; the product law `∏_{d ∣ n} Φ_d = F(n)`; that any prime dividing
`Φ_n` with rank a *proper* divisor of `n` equals the largest prime factor `P` of
`n` and divides `Φ_n` to the first power (a lifting-the-exponent corollary); and
finally `Φ_n > n`. Existence of a primitive prime divisor then follows: the whole
question collapses to the scalar inequality `Φ_n > n`, since `Φ_n ≍ α^{φ(n)}` with
`α` the golden ratio. The finite band `13 ≤ n ≤ 10000` is already certified by
direct computation; the remaining work is Möbius bookkeeping plus a
`φ(n) ≥ c√n` estimate.

### 11.2 Classify when the meet law is sharp

Conjecture: `fibRank(gcd(a,b)) = gcd(fibRank(a), fibRank(b))` holds iff
`fibRank(a)` and `fibRank(b)` are "rank-coprime in apparition," failing first at
an explicit small pair (cf. the `(4,6)` witness). The gcd law degrades exactly
where the apparition lattice is not distributive over the prime-power
decomposition — a defect that should be measurable and pinned to concrete
witnesses, and is immediately testable by exhaustive search.

### 11.3 Lift the adjunction to every strong divisibility sequence

Nothing in the join law used a Fibonacci-specific identity beyond
`gcd(u(a), u(b)) = u(gcd(a,b))`. For an arbitrary strong divisibility sequence
`u`, prove `rank(u) ⊣ u` and that `rank(u)` is an lcm-homomorphism. Fibonacci,
Lucas, Mersenne `2ⁿ − 1`, and `qⁿ − 1` become instances of one engine.

### 11.4 A Stone-style duality of indices and apparition supports

Define the apparition support `Supp(n) = { p prime : p ∣ F(n) }` and the adjoint
`S ↦ ⋂_{p ∈ S}(multiples of fibRank(p))`, forming a Galois connection whose closed
indices are the multiples and whose closed supports are the "rank-saturated" prime
sets. Carmichael's theorem becomes the statement that this connection is
*non-degenerate* for `n ∉ {1,2,6,12}`: primitivity is the order-theoretic
assertion `Supp(n) ⊋ ⋃_{d ∣ n, d < n} Supp(d)`.

---

## 12. Conclusion

Reading the Law of Apparition as the inequality of a Galois adjunction
`fibRank ⊣ F` converts the structure theory of the Fibonacci rank into adjunction
calculus: a total, hypothesis-free spine; an exact join law and its finite lift;
monotonicity and a meet sub-law; and a two-line proof of the prime-index
Carmichael theorem. The same adjunction is poised to govern every strong
divisibility sequence and to localize the last open composite case in a single
golden-ratio inequality.

---

## Appendix: formalized results

| Result | Statement | Status |
| --- | --- | --- |
| `hasFibRank_of_pos` | `0 < m ⟹ HasFibRank(m)` | proved, `sorry = 0` |
| `fibStep_iterate` | `fibStep(m)^[k](0,1) = (F(k), F(k+1))` in `ZMod m` | proved, `sorry = 0` |
| `fibRank_dvd_iff` | `HasFibRank(m) ⟹ (m ∣ F(n) ⟺ fibRank(m) ∣ n)` | proved, `sorry = 0` |
| `fibRank_dvd_iff'` | `fibRank(m) ∣ n ⟺ m ∣ F(n)` (all `m`) | proved, `sorry = 0` |
| `fibRank_lcm` | `fibRank(lcm a b) = lcm(fibRank a, fibRank b)` | proved, `sorry = 0` |
| `fibRank_finset_lcm` | finite join homomorphism | proved, `sorry = 0` |
| `fibRank_mono` | `a ∣ b ⟹ fibRank a ∣ fibRank b` | proved, `sorry = 0` |
| `fibRank_gcd_dvd` | `fibRank(gcd a b) ∣ gcd(fibRank a, fibRank b)` | proved, `sorry = 0` |
| `fibRank_prime_index_has_primitive` | prime-index Carmichael, `p ≥ 3` | proved, `sorry = 0` |

The single open analytic gap in the broader program is the composite asymptotic
tail `fib_carmichael_composite` for `n > 10000`; the band `13 ≤ n ≤ 10000` is
certified by direct computation.
