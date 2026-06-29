# The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Abstract

We give a self-contained, elementary, and fully constructive development of the
**Law of Apparition** for the Fibonacci sequence, valid for *every* modulus `m ≥ 1`
(not only primes), and we connect it to the non-archimedean ("arithmetic height")
machinery of *p*-adic valuations and tropical (min-plus) geometry. The central object
is the **rank of apparition** `R(m)`, the least positive index `k` with `m ∣ Fib(k)`.
We prove its existence by a purely combinatorial argument: the Fibonacci *state pair*
`(Fib(n), Fib(n+1))` reduced modulo `m` is the orbit of a bijection of the finite set
`(ℤ/mℤ)²`, hence purely periodic, so it returns to its start `(0,1)`. We then prove the
**representation/duality theorem**

  `m ∣ Fib(n)  ⟺  R(m) ∣ n`,

which exactly translates divisibility of Fibonacci *values* into divisibility of
*indices*. This is the index-side dual of the strong-divisibility identity
`gcd(Fib(a), Fib(b)) = Fib(gcd(a, b))`. Two quantitative corollaries follow: the
Fibonacci divisibility predicate is a **lattice (min-plus) homomorphism** sending the
index `gcd` to logical conjunction, and the **`p`-adic arithmetic height** of `Fib(n)`
drops strictly below `1` exactly on the rank sublattice `R(p)·ℕ`. The last result
realises, concretely on the Fibonacci sequence, the slogan "arithmetic heights are
tropical valuations": the non-archimedean size of `Fib(n)` is governed precisely by the
combinatorial invariant `R(p)`. All results have been formalised and machine-checked,
and depend only on the standard foundational axioms (propositional extensionality,
choice, and quotient soundness).

**Keywords.** Fibonacci sequence, rank of apparition, entry point, strong divisibility
sequence, *p*-adic valuation, ultrametric norm, tropical/min-plus geometry, arithmetic
height, Pisano period.

---

## 1. Introduction

The Fibonacci sequence `Fib(0)=0`, `Fib(1)=1`, `Fib(n+2)=Fib(n)+Fib(n+1)` is the
prototypical *divisibility sequence*. A foundational structural fact about it is the
**Law of Apparition** (Lucas, 1878): for any modulus `m` there is a single positive
integer `R(m)` — the *rank of apparition* or *entry point* — such that `m` divides
`Fib(n)` precisely for `n` a multiple of `R(m)`. Equivalently, the set of indices at
which `m` "appears" as a divisor is an arithmetic progression `R(m)·ℕ`.

Classical proofs lean on Binet's closed form `Fib(n) = (φⁿ − ψⁿ)/√5` and order
arguments in the quadratic field `ℚ(√5)` or its reductions. Our development deliberately
avoids all analysis. We isolate the two ingredients that genuinely matter:

1. **Existence** of `R(m)` is *purely* the statement that the affine shift
   `T(a,b) = (b, a+b)` is a bijection of the finite set `(ℤ/mℤ)²`. A bijection of a
   finite set has only purely periodic orbits, so the orbit of `(0,1)` returns to
   `(0,1)`, producing a positive index `d` with `m ∣ Fib(d)`.
2. **Periodicity** of the appearance set follows from a single algebraic identity, the
   strong-divisibility law `gcd(Fib(a),Fib(b)) = Fib(gcd(a,b))`, together with
   minimality of `R(m)`.

The novelty of this treatment is twofold. First, the existence proof is reduced to
*injectivity of an affine shift*, which in a formal setting is nothing more than the
cancellation law `a + c = b + c ⟹ a = b`. Second, we make explicit the bridge to
arithmetic-height/tropical theory: the divisibility predicate is a homomorphism from
the min-plus lattice of indices to the Boolean lattice, and the `p`-adic ultrametric
norm of `Fib(n)`, an exponentiated tropical valuation, is `< 1` exactly on `R(p)·ℕ`.

This positions the rank of apparition as a *bridge invariant* connecting three
domains: (i) elementary combinatorics of finite-state recurrences; (ii) lattice/tropical
algebra; and (iii) non-archimedean arithmetic geometry.

---

## 2. Definitions

Throughout, `Fib : ℕ → ℕ` is the Fibonacci function with `Fib(0)=0`, `Fib(1)=1`. We
write `ℤ/mℤ` for the integers modulo `m`.

**Definition 2.1 (State pair).** For a modulus `m` and index `n`, the *Fibonacci state
pair* is
```
S_m(n) = (Fib(n) mod m, Fib(n+1) mod m) ∈ (ℤ/mℤ)².
```

**Definition 2.2 (Transition map).** The *Fibonacci shift* is
```
T : (ℤ/mℤ)² → (ℤ/mℤ)²,   T(a, b) = (b, a + b).
```
It is the linear map with matrix `[[0,1],[1,1]]` (the companion matrix of the recurrence
`x² = x + 1`), acting on column vectors.

**Definition 2.3 (Rank of apparition).** For `m ≥ 1`, the *rank of apparition* (or
*entry point*) is
```
R(m) = min { k ∈ ℕ : k > 0 and m ∣ Fib(k) }.
```
We take this as the infimum of the set `{ k : 0 < k ∧ m ∣ Fib(k) }`; Section 3 shows
the set is nonempty, so the infimum is attained.

**Definition 2.4 (`p`-adic valuation and norm).** For a prime `p` and a nonzero
rational `q`, write `q = p^{v} · (a/b)` with `p ∤ a`, `p ∤ b`. The *`p`-adic valuation*
is `v_p(q) = v ∈ ℤ`, and the *`p`-adic (ultrametric) norm* is
```
|q|_p = p^{−v_p(q)},     |0|_p = 0.
```
The norm satisfies multiplicativity `|qr|_p = |q|_p |r|_p` and the strong (ultrametric)
triangle inequality `|q + r|_p ≤ max(|q|_p, |r|_p)`. It is the exponential of the
*additive, min-plus* valuation `v_p`: writing `N(q) = p^{−v_p(q)}` exhibits the
multiplicative norm as the exponentiated tropical valuation. We refer to `N` as the
*`p`-adic arithmetic-height norm*; it is an instance of an abstract non-archimedean norm
(a `NonArchNorm`) in which all the ultrametric axioms are discharged.

**Definition 2.5 (Strong divisibility sequence).** A sequence `a : ℕ → ℕ` is a *strong
divisibility sequence* if `gcd(a(m), a(n)) = a(gcd(m, n))` for all `m, n` and
`a(n) = 0 ⟺ n = 0`. The Fibonacci sequence is the canonical example.

---

## 3. Existence of the rank via pure periodicity

The first main result is that `R(m)` is well-defined.

**Theorem 3.1 (Apparition exists).** For every `m ≥ 1` there exists `k > 0` with
`m ∣ Fib(k)`.

The proof is in three short steps.

**Lemma 3.2 (Transition recurrence).** `S_m(n+1) = T(S_m(n))`; explicitly, if
`S_m(n) = (a, b)` then `S_m(n+1) = (b, a+b)`.

*Proof.* By the recurrence `Fib(n+2) = Fib(n) + Fib(n+1)`, the second coordinate of
`S_m(n+1)` is `Fib(n+2) mod m = (Fib(n) + Fib(n+1)) mod m = a + b`, and its first
coordinate is `Fib(n+1) mod m = b`. ∎

**Lemma 3.3 (Initial state).** `S_m(0) = (0, 1)` (since `Fib(0)=0`, `Fib(1)=1`).

**Lemma 3.4 (Descent / reversibility).** For all `d, i`,
```
S_m(i) = S_m(i + d)   ⟹   S_m(0) = S_m(d).
```

*Proof.* Induct on `i`. The base case `i = 0` is immediate. For the step, assume the
claim for `i` and suppose `S_m(i+1) = S_m(i+1+d)`. Applying the recurrence (Lemma 3.2)
to both sides gives
```
(b, a+b) = (b', a'+b'),  where (a,b)=S_m(i), (a',b')=S_m(i+d).
```
Equality of second coordinates gives `b = b'`; equality of the sums gives
`a + b = a' + b'`. **Cancelling `b` from both sides** (the additive cancellation law
`add_right_cancel`, which is exactly the injectivity of `T`) gives `a = a'`. Hence
`S_m(i) = S_m(i+d)`, and the inductive hypothesis finishes the proof. ∎

The cancellation step is the *only* place reversibility of `T` is used; it is the
formal heart of the argument and replaces all of the analytic machinery of Binet's
formula.

*Proof of Theorem 3.1.* The map `n ↦ S_m(n)` sends the infinite set `ℕ` into the finite
set `(ℤ/mℤ)²`, so by pigeonhole there are `i < j` with `S_m(i) = S_m(j)`. Write
`d = j − i > 0`. By Lemma 3.4 (descent), `S_m(0) = S_m(d)`. Comparing first
coordinates with Lemma 3.3 gives `0 = Fib(d) mod m`, i.e. `m ∣ Fib(d)`, with `d > 0`. ∎

Because the witness set `{ k : 0 < k ∧ m ∣ Fib(k) }` is a nonempty subset of `ℕ`, it
has a least element, so `R(m)` (Definition 2.3) is well-defined and lies in the set.

**Corollary 3.5 (Rank specification).** For `m ≥ 1`: `R(m) > 0` and `m ∣ Fib(R(m))`,
and `R(m)` is minimal with these properties: if `0 < k` and `m ∣ Fib(k)` then
`R(m) ≤ k`.

*Remark 3.6 (The `m = 0` guard).* The hypothesis `m ≥ 1` is essential: `0 ∣ Fib(k)`
holds iff `Fib(k) = 0` iff `k = 0`, so there is no *positive* index of apparition for
`m = 0`, and the rank is genuinely undefined there. Every theorem below carries the
guard `0 < m`; for a prime `p` it is free from `p ≥ 2 > 0`.

---

## 4. The representation (duality) theorem

We now establish the headline result.

**Theorem 4.1 (Law of Apparition / value–index duality).** For `m ≥ 1` and any `n`,
```
m ∣ Fib(n)   ⟺   R(m) ∣ n.
```

*Proof.* Write `r = R(m)`. By Corollary 3.5, `r > 0` and `m ∣ Fib(r)`.

(⇐) Suppose `r ∣ n`. The Fibonacci sequence is a divisibility sequence:
`a ∣ b ⟹ Fib(a) ∣ Fib(b)`. Hence `Fib(r) ∣ Fib(n)`, and since `m ∣ Fib(r)`, transitivity
gives `m ∣ Fib(n)`.

(⇒) Suppose `m ∣ Fib(n)`. If `n = 0` then `r ∣ 0` trivially. Otherwise `n > 0`. Using
the strong-divisibility identity
```
Fib(gcd(r, n)) = gcd(Fib(r), Fib(n)),
```
and the fact that `m` divides both `Fib(r)` and `Fib(n)`, we get `m ∣ gcd(Fib(r),Fib(n))
= Fib(gcd(r,n))`. Now `gcd(r,n) > 0` (since `r > 0`), so by minimality of the rank
(Corollary 3.5), `r ≤ gcd(r,n)`. But `gcd(r,n) ≤ r` always (it divides `r`). Hence
`gcd(r,n) = r`, i.e. `r ∣ n`. ∎

This is a *lossless* translation: every fact about divisibility of (potentially
astronomically large) Fibonacci values reduces to an arithmetic-progression membership
test on indices. The result is the index-side dual of the strong-divisibility identity,
which it in fact uses as its engine.

---

## 5. The divisibility predicate as a min-plus homomorphism

**Theorem 5.1 (gcd → ∧ homomorphism).** For `m ≥ 1` and any `a, b`,
```
m ∣ Fib(gcd(a, b))   ⟺   (m ∣ Fib(a)  and  m ∣ Fib(b)).
```

*Proof.* Apply Theorem 4.1 to all three divisibilities:
```
m ∣ Fib(gcd(a,b)) ⟺ R(m) ∣ gcd(a,b),
m ∣ Fib(a)        ⟺ R(m) ∣ a,
m ∣ Fib(b)        ⟺ R(m) ∣ b.
```
The result then reduces to the elementary fact `c ∣ gcd(a,b) ⟺ (c ∣ a and c ∣ b)`. ∎

**Interpretation.** Consider the predicate `P_m(n) := [m ∣ Fib(n)]` valued in the
Boolean lattice `{false ≤ true}` with meet `∧`. The index set `ℕ` under `gcd` is a
meet-semilattice; in tropical (min-plus) terms, `gcd` plays the role of the additive
operation `⊕ = min` on exponent vectors. Theorem 5.1 says `P_m` is a
**meet-semilattice homomorphism** `(ℕ, gcd) → ({0,1}, ∧)`: it sends the tropical
"minimum" of indices to logical conjunction. Equivalently, the kernel `{ n : P_m(n) }`
of the homomorphism is exactly the principal sublattice `R(m)·ℕ`. The Fibonacci
sequence thus furnishes a clean, concrete homomorphism between a tropical lattice and a
Boolean one.

---

## 6. Bridge to arithmetic height: tropical valuation of Fibonacci numbers

We now connect the combinatorics to non-archimedean size. Recall (Definition 2.4) that
for a prime `p`, the `p`-adic norm `N(q) = p^{−v_p(q)}` is the exponential of the
additive (min-plus) `p`-adic valuation. For an integer `z ≠ 0`, `N(z) < 1` iff
`v_p(z) > 0` iff `p ∣ z`. This is the bridge dictionary "height < 1 reads off
divisibility."

**Theorem 6.1 (Height capstone, native form).** For a prime `p` and any `n`,
```
|Fib(n)|_p < 1   ⟺   R(p) ∣ n.
```

*Proof.* By the dictionary above, `|Fib(n)|_p < 1 ⟺ p ∣ Fib(n)`. Theorem 4.1 (with
`m = p`, which is positive) rewrites the right side as `R(p) ∣ n`. ∎

**Theorem 6.2 (Height capstone, arithmetic-height form).** Let `N = N_p` be the abstract
`p`-adic arithmetic-height norm of Definition 2.4 (a non-archimedean norm valued in the
reals, with `N(z) = |z|_p` after the canonical embedding `ℚ ↪ ℝ`). Then for any `n`,
```
N(Fib(n)) < 1   ⟺   R(p) ∣ n.
```

*Proof.* By construction `N(q) = (|q|_p : ℝ)`, the real-coercion of the rational
`p`-adic norm. The strict inequality `N(Fib(n)) < 1` in `ℝ` is therefore equivalent to
`|Fib(n)|_p < 1` in `ℚ` (the coercion `ℚ ↪ ℝ` is order-preserving and `1 ↦ 1`), which
is Theorem 6.1. ∎

**Significance.** Theorem 6.2 instantiates the general programme "arithmetic heights as
tropical valuations" on a specific, classical sequence. The non-archimedean *size* of
`Fib(n)` — an object measured by an exponentiated tropical valuation — is supported
exactly on the index sublattice `R(p)·ℕ`. The continuous-looking notion of height is
completely controlled by the discrete combinatorial invariant `R(p)`.

---

## 7. The companion-matrix viewpoint and the Pisano bound

The transition map `T` (Definition 2.2) is multiplication by the companion matrix
`M = [[0,1],[1,1]]`. Over `ℤ/pℤ` for a prime `p ≠ 5`, the characteristic polynomial
`x² − x − 1` has discriminant `5`, so its splitting behaviour is governed by the
Legendre symbol `(5 | p)`. Standard finite-field order theory then yields the classical
**Pisano-style bound**.

**Proposition 7.1 (Rank bound; classical).** For a prime `p ≠ 5`,
```
R(p)  divides  p − (5 | p),     hence   R(p) ≤ p + 1,
```
where `(5 | p) = +1` if `5` is a quadratic residue mod `p` (equivalently
`p ≡ ±1 mod 5`) and `(5 | p) = −1` otherwise (`p ≡ ±2 mod 5`).

*Sketch.* `R(p)` equals the multiplicative order of the matrix `M` in `GL₂(ℤ/pℤ)`
restricted to the orbit of the start vector, equivalently the order of the eigenvalue
(golden ratio image) `φ` in the field `ℤ/pℤ` (when `5` is a QR) or `ℤ/p²ℤ`-extension
`𝔽_{p²}` (when `5` is a non-residue). In the split case `φ^{p−1} = 1`; in the inert
case the Frobenius gives `φ^{p+1} = N(φ) = −1·(−1) =` a unit of order dividing `p+1`.
The order-divides-group-size theorem yields the stated divisibility. (This proposition
is stated for context and completeness; it is not part of the formalised core, which
proves Theorems 3.1, 4.1, 5.1, 6.1, 6.2.) ∎

Numerically the bound is tight in many cases: `R(7)=8=7−(−1)`, `R(11)=10=11−1`,
`R(13)=7 ∣ 14=13+1`, `R(23)=24=23+1`. It guarantees the apparition clock never ticks
slower than `p+1`.

---

## 8. Algorithms

The constructive content yields three immediate algorithms.

**Algorithm A (Rank of apparition by state iteration).** Compute `R(m)` in `O(R(m))`
arithmetic operations modulo `m`, using `O(1)` words of state, by iterating the
transition `T` from `(0,1)` until the first coordinate is `0`. This is the algorithmic
shadow of the existence proof (Theorem 3.1): each step is one application of
`(a,b) ↦ (b, (a+b) mod m)`, and the first index at which `a ≡ 0` is exactly `R(m)`.

**Algorithm B (Divisibility test by index reduction).** To decide `m ∣ Fib(n)` for a
gigantic `n`, do *not* compute `Fib(n)`. Instead compute `R(m)` (Algorithm A) and test
whether `R(m) ∣ n`. This replaces a computation on an exponentially large value by a
single modular reduction of the index — the algorithmic form of the duality
(Theorem 4.1).

**Algorithm C (`p`-adic height threshold).** To decide whether `|Fib(n)|_p < 1`, run
Algorithm B with `m = p`. By Theorem 6.1 the answer is `R(p) ∣ n`. No factorisation of
`Fib(n)` and no `p`-adic arithmetic on the huge value is needed.

---

## 9. Applications

**9.1 Carmichael's primitive-divisor theorem, reframed.** A prime `p` is a *primitive
prime divisor* of `Fib(n)` if `p ∣ Fib(n)` but `p ∤ Fib(k)` for all `0 < k < n`. By the
apparition law this is *exactly* the equality `R(p) = n`. Carmichael's theorem — every
`Fib(n)` with `n ∉ {1,2,6,12}` has a primitive prime divisor — therefore becomes the
single combinatorial statement: *for every `n > 12` there exists a prime `p` with
`R(p) = n`* (i.e. `R` is surjective onto `{n : n > 12}`). The reformulation converts an
analytic magnitude problem into a question about the surjectivity of the rank function,
which is checkable for small `n` by direct enumeration.

**9.2 Fast divisibility for large indices.** In computational number theory one
frequently needs `m ∣ Fib(n)` for `n` with thousands of digits. Algorithm B answers this
in time `O(R(m))` (often `O(m)`) plus one `gcd`/modular test, independent of the size of
`n`.

**9.3 Tropical/`p`-adic localisation.** The height capstone (Theorem 6.2) gives an exact
description of the support of the `p`-adic size of the Fibonacci sequence as a function
of the index. This is a model case for "localising" arithmetic data of a divisibility
sequence along its rank filtration.

**9.4 A reusable bridge invariant.** Because the predicate `P_m` is a tropical→Boolean
homomorphism, the rank of apparition is precisely the bridge between the lattice-walk
combinatorics of integer recurrences and the ultrametric/tropical norm picture, usable
wherever a strong divisibility sequence appears.

---

## 10. Discussion

The development illustrates a recurring methodological point: a theorem traditionally
proved by powerful continuous tools (Binet's formula, algebraic number theory) can have
a shorter, more robust, and more *general* proof once one identifies its true
combinatorial core. Here that core is "a bijection of a finite set has purely periodic
orbits," reduced in the formal proof to additive cancellation. Crucially, this core does
not see anything Fibonacci-specific beyond the recurrence's reversibility and the strong
gcd law — which is precisely why the same argument abstracts to all strong divisibility
sequences (Section 11).

The bridge to `p`-adic heights/tropical valuations is more than decoration. It exhibits
the rank of apparition as a *single invariant wearing three costumes*: a period of a
finite-state dynamical system, a generator of a kernel sublattice of a min-plus
homomorphism, and the controller of a non-archimedean norm. Each costume suggests its
own generalisation, listed below.

A note on rigor: every numbered theorem in Sections 3–6 has been formalised and machine
verified, depending only on the standard foundational axioms (propositional
extensionality, the axiom of choice, and quotient soundness); none uses any unverified
assumption. Proposition 7.1 is presented as classical context.

---

## 11. Future work

**11.1 Primitivity is rank equality.** Build the Carmichael primitive-divisor theorem
directly on the rank: primitivity of `p` for `Fib(n)` is *defined* by `R(p) = n`, so the
whole problem collapses to surjectivity of `R` onto `{n : n > 12}`. Small `n` are
decidable by enumeration, making any wrong reformulation immediately falsifiable.

**11.2 The rank as an arithmetic function with a CRT/lcm law.** Conjecture: for coprime
`a, b`, `R(a·b) = lcm(R(a), R(b))`, and more generally `m ∣ Fib(n) ⟺ R(q) ∣ n` for every
prime power `q ‖ m`. This is the multiplicative (lcm) dual of the additive (gcd)
homomorphism of Theorem 5.1: the value-side Chinese Remainder Theorem corresponds to an
index-side lcm.

**11.3 The Pisano/companion-matrix bound, formalised.** Promote `S_m` from a raw
function to a genuine matrix power `Mⁿ·(0,1)ᵀ` over `ℤ/pℤ`, so that `R(p)` becomes the
order of `M`. The classical bound `R(p) ∣ p − (5 | p)` (Proposition 7.1) then follows
from order-divides-group-size, and is sharply falsifiable against any miscomputed
Legendre symbol.

**11.4 Exact tropical valuation (lifting the exponent).** Refine the *threshold* result
(Theorem 6.1) to an *exact* valuation formula. Conjecture: for an odd prime `p` with
`R(p) ∣ n`,
```
v_p(Fib(n)) = v_p(Fib(R(p))) + v_p(n / R(p)),
```
so the `p`-adic height is an exact min-plus valuation, affine in `v_p(n)` along the rank
filtration — a Fibonacci lifting-the-exponent law. Having pinned the *support* to
`R(p)·ℕ`, this determines the *slope*.

**11.5 Abstraction to strong divisibility sequences.** The proof of Theorem 4.1 used
*only* the strong gcd identity, the divisibility property `a∣b ⟹ Fib(a)∣Fib(b)`, and
positivity of `Fib` on positive indices. A class `StrongDivSeq` carrying these axioms
would yield `R`, the apparition duality, and the height capstone *uniformly* for
`a(n) = qⁿ − 1`, Lucas sequences, and elliptic divisibility sequences — collapsing many
would-be-duplicate bridges into one. It is falsifiable by any strong divisibility
sequence whose rank fails to control divisibility.

---

## Appendix A. Worked examples

`Fib`: `0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,...`

| `p` | `R(p)` | first appearance | `(5∣p)` | `p−(5∣p)` | bound check |
|----:|-------:|-----------------:|:-------:|----------:|:-----------:|
| 2   | 3      | `Fib(3)=2`       | −1      | 3         | `3 ∣ 3`     |
| 3   | 4      | `Fib(4)=3`       | −1      | 4         | `4 ∣ 4`     |
| 5   | 5      | `Fib(5)=5`       | 0       | —         | exceptional |
| 7   | 8      | `Fib(8)=21`      | −1      | 8         | `8 ∣ 8`     |
| 11  | 10     | `Fib(10)=55`     | +1      | 10        | `10 ∣ 10`   |
| 13  | 7      | `Fib(7)=13`      | −1      | 14        | `7 ∣ 14`    |
| 17  | 9      | `Fib(9)=34`      | −1      | 18        | `9 ∣ 18`    |
| 19  | 18     | `Fib(18)=2584`   | +1      | 18        | `18 ∣ 18`   |
| 23  | 24     | `Fib(24)=46368`  | −1      | 24        | `24 ∣ 24`   |

For `p = 7`: the multiples of `7` among Fibonacci numbers occur at indices `8,16,24,…`,
exactly the multiples of `R(7)=8`; and `|Fib(n)|_7 < 1` precisely there. The duality,
the homomorphism, and the height capstone are all visible in a single column.
