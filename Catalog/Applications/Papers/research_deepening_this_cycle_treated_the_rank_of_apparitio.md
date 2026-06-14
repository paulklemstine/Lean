# The Fibonacci Rank of Apparition as a Galois Adjunction `fibRank ⊣ fib`

## Abstract

The *rank of apparition* `fibRank m` of a modulus `m` is the least positive index
`k` for which `m` divides the Fibonacci number `F(k)`. The classical **Law of
Apparition** states that `m ∣ F(n) ⇔ fibRank m ∣ n`. We recast this equivalence,
usually treated as an ad-hoc arithmetic identity, as the **defining inequality of
a Galois adjunction** `fibRank ⊣ fib` between the divisibility order on moduli and
the divisibility order on indices. After pinning the boundary value
`fibRank 0 = 0` so that the equivalence holds *unrestrictedly* for every `m`, we
realize the divisibility relation on `ℕ` as a lattice (`⊓ = gcd`, `⊔ = lcm`) and
exhibit the rank/Fibonacci pair as a genuine `GaloisConnection`. From the abstract
Galois-connection theory we then derive — uniformly and without further arithmetic
— monotonicity of both maps, the closure operator `c(m) = F(fibRank m)` and its
contractive dual kernel `fibRank ∘ fib`, their idempotence, and a **representation
theorem** identifying the closure's fixed points with the set of Fibonacci values.
The capstone is a *unification*: the strong-divisibility identity
`F(gcd(a,b)) = gcd(F(a), F(b))` and the rank law
`fibRank(lcm(a,b)) = lcm(fibRank a, fibRank b)` — previously proved independently
— are shown to be one and the same phenomenon, namely that a right adjoint
preserves meets while a left adjoint preserves joins. We close with the
arithmetic-height corollary that the `p`-adic norm of `F(n)` drops below 1 exactly
on the index sublattice `fibRank p · ℕ`.

**Keywords:** Fibonacci numbers, rank of apparition, Galois connection,
adjunction, divisibility lattice, closure operator, strong divisibility,
representation theorem, p-adic valuation.

---

## 1. Introduction

The Fibonacci sequence `F(0) = 0`, `F(1) = 1`, `F(n+2) = F(n) + F(n+1)` carries an
arithmetic structure far richer than its elementary recurrence suggests. Two
classical facts illustrate the point:

1. **Strong divisibility:** `F(gcd(a, b)) = gcd(F(a), F(b))`.
2. **Law of apparition:** every modulus `m ≥ 1` divides infinitely many Fibonacci
   numbers, and the positions at which it does so form an arithmetic progression
   `fibRank m · ℕ`, where `fibRank m` is the *rank of apparition* — the least
   positive `k` with `m ∣ F(k)`.

These results are typically presented as standalone arithmetic lemmas, proved by
periodicity of the Pisano sequence and the gcd identity. The present work argues
that they are not independent facts at all, but shadows of a single categorical
structure: a **Galois adjunction**

> `fibRank ⊣ fib`,   with defining inequality   `fibRank m ∣ n  ⇔  m ∣ F(n)`,

between the divisibility-ordered set of moduli and the divisibility-ordered set of
indices. Once this is recognized, the entire apparatus of Galois-connection theory
— monotonicity of adjoints, closure/kernel operators and their idempotence,
preservation of meets by right adjoints and joins by left adjoints — applies
verbatim, and the classical results reappear as instances.

All statements below have been verified in a proof assistant and are reported as
theorems; the present document gives mathematical statements and proof sketches.

---

## 2. Preliminaries and definitions

### 2.1 The Fibonacci state pair and existence of the rank

We work over the natural numbers `ℕ`. Write `F(n)` for the `n`-th Fibonacci
number.

**Definition 2.1 (Rank of apparition).**
For `m : ℕ`,
```
fibRank m := sInf { k : ℕ | 0 < k ∧ m ∣ F(k) }.
```
That is, `fibRank m` is the least positive index at which `m` appears as a divisor
of a Fibonacci number, with the convention `sInf ∅ = 0`.

**Definition 2.2 (State pair).**
For a modulus `m`, define the *state pair* map
```
fibState m n := (F(n) mod m, F(n+1) mod m) ∈ ZMod m × ZMod m.
```
The Fibonacci recurrence gives the shift
`fibState m (n+1) = ( (fibState m n).2 , (fibState m n).1 + (fibState m n).2 )`,
i.e. the linear map `T(a, b) = (b, a + b)`, with initial state
`fibState m 0 = (0, 1)`.

**Lemma 2.3 (Existence of the rank).**
For every `m` with `0 < m`, there exists `k > 0` with `m ∣ F(k)`. Consequently
`fibRank m` is a well-defined positive integer, `m ∣ F(fibRank m)`, and `fibRank m`
is minimal with these properties.

*Proof sketch.* The map `T(a,b) = (b, a+b)` is a bijection of the finite set
`ZMod m × ZMod m` (its inverse is `(a, b) ↦ (b - a, a)`). The orbit of any state
under a finite bijection is purely periodic; in particular the orbit of `(0,1)`
returns to `(0,1)`. Concretely, by the pigeonhole principle the infinite sequence
`n ↦ fibState m n` repeats: `fibState m i = fibState m j` for some `i < j`. A
descent argument — repeatedly cancelling via the injectivity of `T`
(`add_right_cancel`) — pushes this coincidence down to `fibState m 0 = fibState m d`
where `d = j - i > 0`. Reading the first coordinate gives `F(d) ≡ 0 (mod m)`, hence
`m ∣ F(d)`. Membership and minimality of `fibRank m` then follow from `Nat.sInf_mem`
and `Nat.sInf_le`. ∎

### 2.2 The boundary value

**Lemma 2.4 (`fibRank_zero`).** `fibRank 0 = 0`.

*Proof sketch.* `0 ∣ F(k) ⇔ F(k) = 0 ⇔ k = 0`, so the witness set
`{ k | 0 < k ∧ 0 ∣ F(k) }` is empty and `sInf ∅ = 0`. ∎

---

## 3. The Law of Apparition, unrestricted

**Theorem 3.1 (Law of Apparition, `m > 0`).**
For `0 < m` and all `n`,
```
m ∣ F(n)  ⇔  fibRank m ∣ n.
```

*Proof sketch.*
(⇐) If `fibRank m ∣ n` then `F(fibRank m) ∣ F(n)` by the divisibility property
`a ∣ b ⇒ F(a) ∣ F(b)` (`Nat.fib_dvd`); since `m ∣ F(fibRank m)` by Lemma 2.3,
transitivity yields `m ∣ F(n)`.
(⇒) Suppose `m ∣ F(n)` with `n > 0` (the case `n = 0` is trivial). Set
`r = fibRank m`. From `m ∣ F(r)` and `m ∣ F(n)` and the strong divisibility
identity `F(gcd(r, n)) = gcd(F(r), F(n))` we get `m ∣ F(gcd(r, n))`. As
`gcd(r, n) > 0`, minimality of `r` forces `r ≤ gcd(r, n)`, while `gcd(r,n) ∣ r`
gives `gcd(r, n) ≤ r`. Hence `gcd(r, n) = r`, i.e. `r ∣ n`. ∎

**Theorem 3.2 (Unrestricted Law of Apparition, `fib_dvd_iff_rank_dvd_all`).**
For *every* `m` (including `m = 0`) and all `n`,
```
m ∣ F(n)  ⇔  fibRank m ∣ n.
```

*Proof sketch.* For `m > 0` this is Theorem 3.1. For `m = 0`, both sides express
`n = 0`: the left side is `0 ∣ F(n) ⇔ F(n) = 0 ⇔ n = 0`, and the right side is
`fibRank 0 ∣ n = 0 ∣ n ⇔ n = 0` using `fibRank 0 = 0` (Lemma 2.4). ∎

Theorem 3.2 is the crucial upgrade: a Galois connection requires its defining
inequality to hold *with no exceptions*, so the `m = 0` boundary must be included.

---

## 4. The divisibility lattice and the adjunction

### 4.1 The lattice `DvdNat`

A naive synonym `DvdNat := ℕ` carrying the divisibility order would clash with the
canonical linear order on `ℕ` (instance resolution would silently pick `⊓ = min`
rather than `gcd`). We therefore use a one-field structure wrapper.

**Definition 4.1 (`DvdNat`).** `DvdNat` is the type with a single field
`val : ℕ`, equipped with the lattice structure
```
a ≤ b   :=  a.val ∣ b.val,
a ⊓ b   :=  ⟨gcd a.val b.val⟩,
a ⊔ b   :=  ⟨lcm a.val b.val⟩.
```
The lattice axioms hold by the standard facts `dvd_refl`, `dvd_trans`,
`Nat.dvd_antisymm`, `Nat.dvd_gcd`/`Nat.gcd_dvd_*`, and `Nat.lcm_dvd`/`Nat.dvd_lcm_*`.

**Definition 4.2 (Transported maps).**
```
rankD m := ⟨fibRank m.val⟩ : DvdNat → DvdNat,
fibD  n := ⟨F(n.val)⟩      : DvdNat → DvdNat.
```

### 4.2 The Galois connection

**Theorem 4.3 (The apparition adjunction, `fibRank_gc`).**
`rankD` and `fibD` form a Galois connection on `DvdNat`:
```
GaloisConnection rankD fibD,    i.e.    rankD m ≤ n  ⇔  m ≤ fibD n
```
for all `m, n : DvdNat`, equivalently `fibRank m.val ∣ n.val ⇔ m.val ∣ F(n.val)`.

*Proof sketch.* Unfolding `≤`, `rankD`, `fibD` reduces the goal precisely to
Theorem 3.2 (with sides swapped), which holds for all naturals. ∎

In adjunction terminology `rankD` (i.e. `fibRank`) is the **left adjoint** and
`fibD` (i.e. `fib`) the **right adjoint**.

**Theorem 4.4 (Monotonicity).**
Both adjoints are monotone for divisibility:
```
a ∣ b ⇒ fibRank a ∣ fibRank b      (monotone_fibRank),
a ∣ b ⇒ F(a) ∣ F(b)                 (monotone_fib_dvd).
```

*Proof sketch.* `GaloisConnection.monotone_l` and `GaloisConnection.monotone_u`
applied to Theorem 4.3. (The second recovers the classical `Nat.fib_dvd`.) ∎

---

## 5. Closure, kernel, and the representation theorem

Every Galois connection `l ⊣ u` yields a **closure operator** `u ∘ l` on the
domain of `l` and a **kernel (interior) operator** `l ∘ u` on the domain of `u`.
Here:

* closure on moduli:  `c(m) := F(fibRank m)`;
* kernel on indices:  `k(n) := fibRank(F(n))`.

**Theorem 5.1 (Extensivity / contractivity).**
```
m ∣ F(fibRank m)        (dvd_fib_fibRank),       — closure is extensive
fibRank(F(n)) ∣ n        (fibRank_fib_dvd_self).  — kernel is contractive
```

*Proof sketch.* These are `GaloisConnection.le_u_l` and `GaloisConnection.l_u_le`.
The first also follows directly from `m ∣ F(fibRank m)` (Lemma 2.3). ∎

**Theorem 5.2 (Idempotence).**
```
F(fibRank(F(n))) = F(n)            (fib_fibRank_fib),
fibRank(F(fibRank m)) = fibRank m   (fibRank_fib_fibRank).
```

*Proof sketch.* These are the standard adjunction triangle identities
`u ∘ l ∘ u = u` and `l ∘ u ∘ l = l` (`GaloisConnection.u_l_u_eq_u`,
`GaloisConnection.l_u_l_eq_l`), transported through the `DvdNat` wrapper. ∎

**Theorem 5.3 (Representation theorem, `closure_fixedPoint_iff_isFib`).**
The fixed points of the closure operator `c(m) = F(fibRank m)` are *exactly* the
Fibonacci values:
```
F(fibRank m) = m  ⇔  ∃ k, F(k) = m.
```

*Proof sketch.*
(⇒) If `F(fibRank m) = m`, then `m` is literally `F(k)` for `k = fibRank m`.
(⇐) If `m = F(k)` for some `k`, apply idempotence (Theorem 5.2): then
`F(fibRank m) = F(fibRank(F(k))) = F(k) = m`. (The degenerate values
`F(0) = 0`, `F(1) = F(2) = 1` are handled by the unrestricted boundary
conventions.) ∎

Theorem 5.3 identifies the apparition adjunction with the canonical projection of
the modulus lattice onto `range F`: `c` rounds each `m` *upward* (Theorem 5.1) to
its "Fibonacci shadow," and the shadow space is precisely the set of Fibonacci
numbers.

---

## 6. Unification: strong divisibility and the rank law are one theorem

This is the conceptual capstone. We use the universal Galois-connection facts:

* a **right adjoint preserves meets**: `u(x ⊓ y) = u(x) ⊓ u(y)`
  (`GaloisConnection.u_inf`);
* a **left adjoint preserves joins**: `l(x ⊔ y) = l(x) ⊔ l(y)`
  (`GaloisConnection.l_sup`).

In `DvdNat`, meet is `gcd` and join is `lcm`.

**Theorem 6.1 (Strong divisibility as meet-preservation, `fib_gcd_eq_adjunction`).**
```
F(gcd(a, b)) = gcd(F(a), F(b)).
```

*Proof sketch.* Apply `GaloisConnection.u_inf` to the right adjoint `fibD` at
`⟨a⟩, ⟨b⟩`, then read off the underlying naturals via `DvdNat.inf_val`. This
recovers the classical `Nat.fib_gcd`. ∎

**Theorem 6.2 (Rank law as join-preservation, `fibRank_lcm_eq_adjunction`).**
For `a, b > 0`,
```
fibRank(lcm(a, b)) = lcm(fibRank a, fibRank b).
```

*Proof sketch.* Apply `GaloisConnection.l_sup` to the left adjoint `rankD` at
`⟨a⟩, ⟨b⟩`, then read off via `DvdNat.sup_val`. This recovers the lattice join
law `FibonacciApparitionLattice.fibEntry_lcm`. ∎

Thus the two classical jewels are the *same* adjunction fact applied to the two
adjoints. Strong divisibility is no longer an arithmetic accident: it is the
meet-preservation that *every* right adjoint enjoys, and the rank law is its
mirror image for the left adjoint.

It is worth noting the asymmetry that the lattice analysis already detected: the
left adjoint `fibRank` preserves joins (`lcm`) exactly, but does **not** in
general preserve meets — `fibRank(gcd(a,b))` only *divides* `gcd(fibRank a,
fibRank b)`, with strict inequality possible (e.g. `a = 4, b = 6`). Dually `fib`
preserves meets (`gcd`) exactly. This is precisely the adjunction-theoretic
expectation: a left adjoint need not preserve meets, nor a right adjoint joins.

---

## 7. Arithmetic-height corollary

For a prime `p`, the `p`-adic norm `padicNorm p` measures non-archimedean size:
`padicNorm p x < 1` iff `p ∣ x` (for integers `x`).

**Theorem 7.1 (`padicNorm_fib_lt_one_iff`).**
For a prime `p` and all `n`,
```
padicNorm p (F(n)) < 1  ⇔  fibRank p ∣ n.
```

*Proof sketch.* `padicNorm.int_lt_one_iff` reduces `padicNorm p (F(n)) < 1` to
`p ∣ F(n)`, which by Theorem 3.1 (using `p > 0`) is `fibRank p ∣ n`. ∎

Hence the `p`-adic size of `F(n)` is governed *entirely* by the index: the set of
indices where `F(n)` becomes `p`-adically small is exactly the arithmetic
progression `fibRank p · ℕ`. The rank of apparition is the precise combinatorial
controller of the non-archimedean valuation of the Fibonacci sequence.

---

## 8. Algorithms

The adjunction is not merely conceptual; it yields efficient procedures.

**Algorithm 8.1 (Computing `fibRank m`).** Iterate the state pair
`(F(k), F(k+1)) mod m` from `(0, 1)`, advancing by `T(a,b) = (b, a+b) mod m`, and
return the first `k > 0` with first coordinate `0`. By Lemma 2.3 this halts within
the Pisano period `π(m) ≤ 6m`, so the cost is `O(m)` modular additions and `O(1)`
memory.

**Algorithm 8.2 (Fast divisibility test).** To decide `m ∣ F(n)` for astronomically
large `n`: compute `r = fibRank m` (Algorithm 8.1), then return `r ∣ n`. This
replaces computing the `O(n)`-bit number `F(n)` with a single `O(m)` precomputation
and a trivial division — the operational content of Theorem 3.2.

**Algorithm 8.3 (Fibonacci-shadow rounding).** Given any `m`, compute
`c(m) = F(fibRank m)`. By Theorem 5.3 this is the least Fibonacci multiple of the
closure, and `c` is idempotent, so it is a genuine normalization onto `range F`.

---

## 9. Applications

* **Cryptographic and pseudorandom sequence analysis.** Linear recurrences modulo
  `m` underlie many pseudorandom generators; the rank of apparition is exactly the
  parameter controlling when residues vanish, and the adjunction gives a clean
  algebra (Theorems 6.1–6.2) for combining moduli via `gcd`/`lcm`.
* **Fast structural divisibility.** Algorithm 8.2 turns infeasible value-level
  divisibility queries into trivial index-level ones.
* **Number-theoretic valuation control.** Theorem 7.1 pinpoints the `p`-adic
  vanishing locus of Fibonacci numbers, relevant to studying `p`-adic Fibonacci
  analogues and Wall's question on `fibRank(p) = fibRank(p^2)`.
* **A worked template for "arithmetic identity = adjunction".** The pattern —
  promote a biconditional `f(x) ≤ y ⇔ x ≤ g(y)` to a Galois connection, then
  harvest closure, kernel, and meet/join preservation — applies to many other
  arithmetic functions defined by minimality (orders of elements, multiplicative
  orders, entry points of other Lucas sequences).

---

## 10. Discussion and future work

The methodological message is that the Law of Apparition was *always* an
adjunction; recognizing this collapses a list of separately-proved identities into
one principle and explains why strong divisibility holds (meet-preservation is
forced for any right adjoint). The representation theorem (Theorem 5.3) gives the
adjunction a crisp geometric meaning: projection onto the Fibonacci shadow space.

Directions for further development:

1. **Bundled `ClosureOperator` packaging and a quotient representation.** Promote
   the closure `c(m) = F(fibRank m)` to a bundled closure operator and describe
   `range F` as the associated quotient/sublattice of fixed points, making the
   "Fibonacci shadow" a first-class object.
2. **General Lucas sequences.** The state-pair existence argument (Lemma 2.3) and
   the gcd identity hold for nondegenerate Lucas sequences `U_n(P, Q)`; the entire
   adjunction should transport, yielding strong-divisibility and rank-law analogues
   uniformly.
3. **Wall–Sun–Sun phenomena.** Use the height corollary (Theorem 7.1) and the
   adjunction's interaction with prime powers to study when
   `fibRank(p) = fibRank(p^2)`.
4. **Categorical generalization.** Interpret `fibRank ⊣ fib` as an adjunction of
   thin categories and ask which arithmetic functions, ordered by divisibility,
   admit adjoints — a divisibility-theoretic analogue of the adjoint functor
   theorem.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| `fibRank_zero` | `fibRank 0 = 0` |
| `fib_dvd_iff_rank_dvd_all` | `m ∣ F(n) ⇔ fibRank m ∣ n`, all `m` |
| `fibRank_gc` | `GaloisConnection rankD fibD` |
| `monotone_fibRank`, `monotone_fib_dvd` | both adjoints are divisibility morphisms |
| `dvd_fib_fibRank`, `fibRank_fib_dvd_self` | closure extensive / kernel contractive |
| `fib_fibRank_fib`, `fibRank_fib_fibRank` | idempotence of closure / kernel |
| `closure_fixedPoint_iff_isFib` | fixed points of `F ∘ fibRank` = `range F` |
| `fib_gcd_eq_adjunction` | `F(gcd a b) = gcd(F a, F b)` (meet-preservation) |
| `fibRank_lcm_eq_adjunction` | `fibRank(lcm a b) = lcm(fibRank a, fibRank b)` (join-preservation) |
| `padicNorm_fib_lt_one_iff` | `padicNorm p (F n) < 1 ⇔ fibRank p ∣ n` |

All results are `sorry`-free and depend only on the standard kernel-checked axioms.
