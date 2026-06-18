# Entry-Point Duality for the Fibonacci Sequence and Its Consequences for Primitive Divisors

## Abstract

The *entry point* (or *rank of apparition*) of a modulus `p` with respect to the
Fibonacci sequence `F` is the least positive index `k` at which `p ∣ F(k)`,
written `z(p)`. We isolate a single biconditional — the **entry-point duality**

> `p ∣ F(n)  ⟺  z(p) ∣ n`,

valid for *arbitrary* integers `p` (with no primality hypothesis) — and show that
a cluster of classical and folklore results are immediate corollaries of it. From
the duality we derive (i) the strong-divisibility law `F(m) ∣ F(n) ⟺ m ∣ n` for
`m ≥ 3`, obtained as the special case `p = F(m)`; (ii) a clean characterization
of primitive prime divisors, namely that a prime `p` is a primitive divisor of
`F(n)` (for `n > 0`) iff `z(p) = n`; and (iii) an explicit, verifiable form of
Carmichael's 1913 primitive-divisor theorem on the range `1 ≤ n ≤ 40`,
`n ∉ {1,2,6,12}`, witnessed by a tabulated least primitive prime divisor for each
index. The entire development rests on only two Fibonacci-specific inputs: the gcd
identity `gcd(F(a), F(b)) = F(gcd(a,b))` and the one-directional divisibility law
`m ∣ n ⟹ F(m) ∣ F(n)`. The contribution is conceptual consolidation: the
duality unifies several previously separate, often primality-restricted lemmas
into one statement, and recasts Carmichael's theorem as a surjectivity statement
about the single arithmetic function `z`.

**Keywords:** Fibonacci sequence, rank of apparition, entry point, primitive prime
divisor, Carmichael's theorem, strong divisibility sequence.

---

## 1. Introduction

The Fibonacci sequence `F(0) = 0`, `F(1) = 1`, `F(n+2) = F(n+1) + F(n)` is the
prototypical *strong divisibility sequence*: its terms encode arithmetic
structure with unusual fidelity. Two facts express this fidelity compactly. First,
the **gcd identity**
```
gcd(F(a), F(b)) = F(gcd(a, b)),
```
which says the Fibonacci sequence commutes with greatest common divisors. Second,
the **monotone divisibility law**
```
m ∣ n  ⟹  F(m) ∣ F(n).
```

A modulus `p` may divide many Fibonacci numbers. The set of indices `n` with
`p ∣ F(n)` has a remarkably rigid shape: it is precisely the set of multiples of
a single integer, the *entry point* `z(p)` (also called the rank of apparition or
the Fibonacci entry point). Establishing this rigidity, and exploring its
consequences, is the goal of this paper.

Our organizing principle is that one biconditional — the entry-point duality —
governs *all* divisibility relations `p ∣ F(n)`. We prove it for arbitrary `p`,
deliberately dropping the primality hypothesis that often accompanies such
statements, and then harvest a series of classical consequences as special cases.

### 1.1 Contributions

1. **Entry-point duality** (Theorem 3.1): `p ∣ F(n) ⟺ z(p) ∣ n`, for all `p, n`.
2. **Primitivity characterization** (Theorem 4.2): for `n > 0`, a prime `p` is a
   primitive divisor of `F(n)` iff `z(p) = n`.
3. **Strong divisibility law** (Theorem 5.2): `F(m) ∣ F(n) ⟺ m ∣ n` for `m ≥ 3`,
   recovered as the case `p = F(m)`.
4. **Verifiable Carmichael theorem** (Theorem 6.1): on `1 ≤ n ≤ 40`,
   `n ∉ {1,2,6,12}`, an explicit table of least primitive prime divisors
   certifies that `F(n)` has a primitive divisor.

The mathematical components are classical; the value added is the demonstration
that they are facets of one fact, with minimal hypotheses, and the reduction of
Carmichael's theorem to a surjectivity statement about `z`.

---

## 2. Definitions

Throughout, `F : ℕ → ℕ` is the Fibonacci sequence with `F(0) = 0`, `F(1) = 1`,
and `F(n+2) = F(n+1) + F(n)`. Divisibility, gcd, and "prime" are taken over the
natural numbers. We adopt the convention that `0 ∣ x` holds iff `x = 0`.

**Definition 2.1 (Entry point / rank of apparition).**
For `p ∈ ℕ`, define
```
z(p) = fibEntry(p) = the least k > 0 with p ∣ F(k),   if such a k exists,
                   = 0,                                  otherwise.
```
Equivalently, `z(p)` is `min { k > 0 : p ∣ F(k) }` when the set is nonempty, and
`0` when it is empty. (In the formal development this is phrased with a decidable
existence test and a least-witness operator.)

Two remarks. The existence set is nonempty for every `p ≥ 1` because `F` is
unbounded and, in fact, `p ∣ F(z(p))` always holds with `z(p)` finite for `p ≥ 1`;
the value `0` is a defensive convention covering degenerate inputs. The choice
`F(0) = 0`, divisible by everything, makes the boundary case `n = 0` uniform: it
is handled by `0 ∣ n ⟺ n = 0`.

**Definition 2.2 (Primitive prime divisor).**
A prime `p` is a **primitive prime divisor** of `F(n)` if
```
p is prime,   p ∣ F(n),   and   ∀ k, (0 < k < n) ⟹ ¬ (p ∣ F(k)).
```
That is, `F(n)` is the first Fibonacci number (at a positive index) that `p`
divides.

---

## 3. The Entry-Point Duality

The technical engine is a one-line consequence of the gcd identity.

**Lemma 3.0 (Two appearances collapse to one).**
If `p ∣ F(a)` and `p ∣ F(b)`, then `p ∣ F(gcd(a, b))`.

*Proof.* From `p ∣ F(a)` and `p ∣ F(b)` we get `p ∣ gcd(F(a), F(b))`. By the gcd
identity `gcd(F(a), F(b)) = F(gcd(a, b))`, hence `p ∣ F(gcd(a, b))`. ∎

**Theorem 3.1 (Entry-point duality).**
For all `p, n ∈ ℕ`,
```
p ∣ F(n)  ⟺  z(p) ∣ n.
```

*Proof.* We treat the two implications.

*(⟹) Suppose `p ∣ F(n)`.* If `p` has no entry point (the existence set is empty),
then in particular `p ∤ F(k)` for all `k > 0`; combined with `p ∣ F(n)` this
forces `n = 0` (using `F(0) = 0`), and then `z(p) = 0 ∣ 0` holds. Otherwise
`z(p) > 0` and `p ∣ F(z(p))` by definition. Apply Lemma 3.0 with `a = n`,
`b = z(p)`:
```
p ∣ F(gcd(n, z(p))).
```
Let `g = gcd(n, z(p))`. Then `g ∣ z(p)`, so `g ≤ z(p)`; and `g > 0` because
`z(p) > 0` (a gcd with a positive argument that divides it is positive whenever
the witnessed index is positive). Now `g` is a positive index at which `p`
divides `F(g)`. By minimality of `z(p)` we cannot have `g < z(p)`, so `g = z(p)`.
But `g = gcd(n, z(p))` divides `n`, hence `z(p) ∣ n`.

*(⟸) Suppose `z(p) ∣ n`.* If `z(p) = 0` then `n = 0` and `p ∣ F(0) = 0`
trivially. Otherwise `p ∣ F(z(p))` by definition, and `z(p) ∣ n` gives
`F(z(p)) ∣ F(n)` by the monotone divisibility law; transitivity yields
`p ∣ F(n)`. ∎

The proof uses *only* Lemma 3.0 (hence the gcd identity), the monotone
divisibility law, minimality of `z(p)`, and the convention `0 ∣ x ⟺ x = 0`. No
primality of `p` is invoked at any step. This generality is essential for the
strong divisibility law in Section 5, where `p = F(m)` is composite in general.

---

## 4. Primitive Divisors as a Single Equation

The duality converts the negative, quantified condition defining primitivity into
a single equation about `z`.

**Lemma 4.1.** For `n > 0` and a prime `p` with `p ∣ F(n)`: there exists
`0 < k < n` with `p ∣ F(k)` **iff** `z(p) < n`.

*Proof.* If such a `k` exists, then by Theorem 3.1 `z(p) ∣ k`, so `z(p) ≤ k < n`.
Conversely, if `z(p) < n`, then `k = z(p)` is itself such an index (positive,
below `n`, and `p ∣ F(z(p))`). ∎

**Theorem 4.2 (Primitivity characterization).**
For `n > 0`, a prime `p` is a primitive prime divisor of `F(n)` **iff**
```
p is prime,   p ∣ F(n),   and   z(p) = n.
```

*Proof.* (⟹) Assume `p` is a primitive divisor of `F(n)`. Then `p` is prime and
`p ∣ F(n)`, so `z(p) ∣ n` (Theorem 3.1) and thus `z(p) ≤ n`. If `z(p) < n`, then
`k = z(p)` is a positive index below `n` with `p ∣ F(k)`, contradicting
primitivity. Hence `z(p) = n`.

(⟸) Assume `p` prime, `p ∣ F(n)`, and `z(p) = n`. For any `k` with `0 < k < n`,
suppose `p ∣ F(k)`. Then `z(p) ∣ k` (Theorem 3.1), so `n = z(p) ≤ k < n`, a
contradiction. Hence no such `k` exists and `p` is primitive. ∎

Theorem 4.2 is the conceptual hinge of the paper: the *qualitative* notion "first
appearance" is identified with the *equational* condition `z(p) = n`. Every
downstream statement about primitive divisors can therefore be phrased — and, on
finite ranges, mechanically decided — through the entry-point function.

---

## 5. Strong Divisibility as a Special Case

We now compute the entry point of a Fibonacci number and recover the strong
divisibility law.

**Lemma 5.1 (Entry point of a Fibonacci number).**
For `m ≥ 3`, `z(F(m)) = m`.

*Proof.* Write `p = F(m)`; note `p ≥ 2` since `F(m) ≥ F(3) = 2`. Trivially
`p ∣ F(m)`, so by Theorem 3.1 `z(p) ∣ m`, giving `z(p) ≤ m`. In the other
direction, `z(p) ∣ m` and the monotone divisibility law give
`F(z(p)) ∣ F(m) = p`; also `p = F(m) ∣ F(z(p))`? — more carefully: from
`p ∣ F(z(p))` (definition of entry point) and `F(z(p)) ∣ F(m) = p` we obtain
`F(z(p)) = p = F(m)` by antisymmetry of divisibility. Since `F` is strictly
increasing on indices `≥ 2` (`F(2) = 1 < F(3) = 2 < F(4) = 3 < ⋯`), the equality
`F(z(p)) = F(m)` with `F(m) ≥ 2` forces `z(p) = m`. (The strict monotonicity is
used to rule out the only other index with the same Fibonacci value, namely the
pair `F(1) = F(2) = 1`, which is excluded because `F(m) ≥ 2`.) ∎

**Theorem 5.2 (Strong divisibility law).**
For `m ≥ 3` and any `n`,
```
F(m) ∣ F(n)  ⟺  m ∣ n.
```

*Proof.* Apply Theorem 3.1 with `p = F(m)`:
`F(m) ∣ F(n) ⟺ z(F(m)) ∣ n`. By Lemma 5.1, `z(F(m)) = m`, so the right side is
`m ∣ n`. ∎

Thus the strong divisibility property — frequently proved as a standalone theorem
— is the instance `p = F(m)` of the duality. The cases `m ∈ {1, 2}` are excluded
only because `F(1) = F(2) = 1` divides everything, making the statement degenerate
there.

---

## 6. A Verifiable Carmichael Theorem

**Theorem 6.0 (Carmichael, 1913).** For every `n ∉ {1, 2, 6, 12}`, the Fibonacci
number `F(n)` possesses a primitive prime divisor.

The four exceptions are sharp: `F(1) = F(2) = 1` are units; `F(6) = 8 = 2³` with
`z(2) = 3 < 6`; `F(12) = 144 = 2⁴·3²` with `z(2) = 3`, `z(3) = 4`, both `< 12`.

By Theorem 4.2, exhibiting a primitive divisor of `F(n)` is equivalent to
exhibiting a prime `p` with `p ∣ F(n)` and `z(p) = n`. On any finite range this
is a *decidable* certificate: pick the witness, check primality, check
divisibility, check the first-appearance condition. We package this for
`1 ≤ n ≤ 40`.

**Definition 6.1 (Witness table).** Define `w : ℕ → ℕ` by the least primitive
prime divisor at each index (and `0` at the exceptional indices):

```
w(3)=2    w(4)=3    w(5)=5    w(7)=13   w(8)=7    w(9)=17   w(10)=11
w(11)=89  w(13)=233 w(14)=29  w(15)=61  w(16)=47  w(17)=1597 w(18)=19
w(19)=37  w(20)=41  w(21)=421 w(22)=199 w(23)=28657 w(24)=23 w(25)=3001
w(26)=521 w(27)=53  w(28)=281 w(29)=514229 w(30)=31 w(31)=557 w(32)=2207
w(33)=19801 w(34)=3571 w(35)=141961 w(36)=107 w(37)=73 w(38)=9349
w(39)=135721 w(40)=2161    w(n)=0 otherwise (incl. n ∈ {1,2,6,12}).
```

**Theorem 6.2 (Verified Carmichael on `n ≤ 40`).**
For every `n` with `1 ≤ n ≤ 40` and `n ∉ {1, 2, 6, 12}`, `w(n)` is a primitive
prime divisor of `F(n)`; i.e. `w(n)` is prime, `w(n) ∣ F(n)`, and for all
`0 < k < n`, `w(n) ∤ F(k)`.

*Proof.* For each of the 34 admissible indices the three conditions are a finite
computation: primality of `w(n)`, the divisibility `w(n) ∣ F(n)`, and the absence
of earlier appearances (equivalently `z(w(n)) = n` via Theorem 4.2). Direct
evaluation confirms all cases. ∎

The structure of the table is instructive. When `n` is prime, `F(n)` is
frequently prime itself (e.g. `F(13) = 233`, `F(17) = 1597`, `F(23) = 28657`,
`F(29) = 514229`), and is its own primitive divisor. When `n` is composite, the
witness is the *new* prime not contributed by proper-divisor terms (e.g. `w(8)=7`
beyond `F(4)=3, F(2)=1`; `w(10)=11` beyond `F(5)=5, F(2)=1`; `w(14)=29` beyond
`F(7)=13, F(2)=1`). Every value satisfies `z(w(n)) = n`.

---

## 7. Algorithms

Two computational primitives underlie the verifications.

**Algorithm 7.1 (Entry point by linear scan).** Compute `z(p)` by scanning
indices `k = 1, 2, 3, …` and returning the first with `p ∣ F(k)`. With Fibonacci
numbers reduced modulo `p` (so the state stays bounded), each step is `O(1)`
arithmetic on integers `< p`. The Pisano period bounds the scan length by
`O(p²)` in the worst case (and `O(p)` for many `p`), so the algorithm always
terminates for `p ≥ 1`.

**Algorithm 7.2 (Primitive-witness search).** To find the least primitive prime
divisor of `F(n)`: factor `F(n)`, and return the least prime factor `p` with
`z(p) = n` (equivalently, `p ∤ F(d)` for every proper divisor index `d ∣ n`,
`d < n`). By Theorem 4.2 this is exactly the primitivity test. The cost is
dominated by factoring `F(n)`; the entry-point check on each candidate is cheap
when done modulo `p`.

Both are realized in the accompanying demonstration code.

---

## 8. Applications

- **Modular periodicity / Pisano structure.** The duality says the "appearance
  set" `{ n : p ∣ F(n) }` is exactly the ideal `z(p)·ℕ`. This is the
  divisibility skeleton beneath the Pisano period and underlies fast tests for
  "does `p` divide some Fibonacci number in a range".
- **Primality and pseudoprime tests.** Entry-point conditions feature in
  Fibonacci-based probable-prime tests (e.g. relations between `z(p)` and `p ± 1`
  for primes `p`); the duality is the structural fact that legitimizes reasoning
  about a single `z(p)` rather than the whole appearance set.
- **Carmichael witnesses.** Theorem 4.2 turns "produce a primitive divisor" into
  "produce `p` with `z(p) = n`", a decidable certificate format suitable for
  machine-checkable tables (Section 6) and for witness-generating algorithms
  (Section 7).

---

## 9. Discussion

The mathematical content of Sections 3–6 is classical: the gcd identity, the
strong divisibility law, and Carmichael's theorem are all well known. What the
present treatment adds is *architecture*. A single biconditional, proved without a
primality hypothesis, subsumes:

- the forward, prime-restricted lemma "`p ∣ F(n) ⟹ z(p) ∣ n`" (the easy half of
  Theorem 3.1, specialized to primes);
- "the entry point of `F(m)` is `m`" (Lemma 5.1);
- the strong divisibility law (Theorem 5.2, the case `p = F(m)`);
- the primitive-divisor characterization (Theorem 4.2, the equality case).

Dropping primality is not mere generality for its own sake: it is precisely what
allows `F(m)` to be substituted for `p`, which is how strong divisibility becomes
a corollary rather than an independent theorem. The minimal input footprint — the
gcd identity and the monotone divisibility law — also clarifies *why* the result
is true: minimality plus the gcd identity collapse two simultaneous appearances
into one appearance at the gcd.

---

## 10. Future Work

**Closed-form lower bound on the primitive part.** Let `Φ*(n)` denote the
primitive part of `F(n)` (the product of its primitive prime factors). Conjecture:
for composite `n ≥ 14`, `Φ*(n) > n`, hence `Φ*(n) > 1`. The primitive part tracks
the cyclotomic factor `Φ_n(φ, ψ)` at the recurrence roots `φ = (1+√5)/2`,
`ψ = (1-√5)/2`, so `log Φ*(n) = φ_E(n)·log φ + o(φ_E(n))` with `φ_E` Euler's
totient; once `φ_E(n)` is shown to dominate `log n`, the bound is uniform and
upgrades the finite Carmichael certificate to a full proof.

**Lifting the exponent.** For a prime `p` with entry point `z = z(p)` and `z ∣ n`,
conjecturally `v_p(F(n)) = v_p(F(z)) + v_p(n/z)`, making the `p`-adic valuation an
affine function of `v_p(n)`. This bounds non-primitive contributions to `F(n)` by
`n` itself, the slack needed to make the size bound `Φ*(n) > n` sufficient.

**Eventual surjectivity of `z`.** By Theorem 4.2, Carmichael's theorem is
equivalent to: there is `N₀` such that for all `n ≥ N₀`, some prime `p` has
`z(p) = n` — i.e. `p ↦ z(p)` is eventually surjective. This detaches the problem
from Fibonacci specifics and invites sieve/density methods.

**Homological packaging.** Order indices `{1, …, N}` by divisibility; the boundary
map sending `n` to its maximal proper divisors, paired with the primitive-prime
indicator (a diagonal cochain by Theorem 4.2), yields a 2-term complex whose
homology dimension counts indices with primitive divisors — `N − 4` for large `N`,
the four exceptions being `1, 2, 6, 12`.

**Reflection-based certificate.** Promote the entry-point scan to a structurally
terminating `firstPrimitiveDivisor : ℕ → ℕ` and prove correctness by reflection on
the decidable equation `z(p) = n`, removing kernel-trusted reflection from the
axiom footprint of the finite Carmichael certificate.

---

## 11. Conclusion

The entry-point duality `p ∣ F(n) ⟺ z(p) ∣ n` is a small statement with large
reach. Holding for arbitrary `p`, it organizes the divisibility theory of the
Fibonacci sequence around a single arithmetic function, recovers the strong
divisibility law and the primitive-divisor characterization as special cases, and
recasts Carmichael's theorem as a surjectivity statement amenable to both finite
certification and asymptotic attack. The clock hidden inside the Fibonacci numbers
— each divisor's first appearance and the regular ticks that follow — is captured
in full by one equation.

---

## References (classical background)

- E. Lucas, *Théorie des fonctions numériques simplement périodiques*,
  Amer. J. Math. 1 (1878).
- R. D. Carmichael, *On the numerical factors of the arithmetic forms αⁿ ± βⁿ*,
  Ann. of Math. 15 (1913), 30–70.
- Standard identities `gcd(F(a),F(b)) = F(gcd(a,b))` and `m ∣ n ⟹ F(m) ∣ F(n)`
  for the Fibonacci sequence.
